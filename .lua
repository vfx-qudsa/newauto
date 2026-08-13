local PlayerKillerSettings = {
    Enabled = true,
    OnlyHeadshots = true,
    TargetDistance = 1000,
    GatherEnabled = true
}

while _G.AutofarmEnabled do
    pcall(function()
        local teleported = false
        task.spawn(function()
            while not teleported do
                if Workspace:FindFirstChild("Shop") then
                    local humanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                    humanoidRootPart.CFrame = CFrame.new(185, 66, -26)
                    teleported = true
                    break
                end
                task.wait(0.1)
            end
        end)
        
        task.wait(1)
        
        LocalPlayer:SetAttribute("__OwnsPermGuard", true)
        local enrollFolder = LocalPlayer.PlayerGui:WaitForChild("UIHolderScreenInset"):WaitForChild("EnrollForGuardAsk")

        if getconnections then
            pcall(function()
                local button1 = enrollFolder:WaitForChild("HeaderPrompt"):WaitForChild("Green"):WaitForChild("Green")
                for _, connection in pairs(getconnections(button1.MouseButton1Click)) do
                    pcall(function() connection:Fire() end)
                end
            end)
            task.wait(0.5)
            
            pcall(function()
                local button2 = enrollFolder:WaitForChild("RankSelection"):WaitForChild("EquipTier1")
                for _, connection in pairs(getconnections(button2.MouseButton1Click)) do
                    pcall(function() connection:Fire() end)
                end
            end)
            task.wait(0.5)
            
            pcall(function()
                local button3 = enrollFolder:WaitForChild("RankConfirmation"):WaitForChild("Green"):WaitForChild("Green")
                for _, connection in pairs(getconnections(button3.MouseButton1Click)) do
                    pcall(function() connection:Fire() end)
                end
            end)
            task.wait(1)
            
            PlayerKillerSettings.Enabled = true
            
            -- Сбор игроков
            task.spawn(function()
                while PlayerKillerSettings.GatherEnabled do
                    pcall(function()
                        local Character = LocalPlayer.Character
                        local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                        local liveFolder = Workspace:FindFirstChild("Live")
                        
                        if liveFolder and HumanoidRootPart then
                            local gatherPos = HumanoidRootPart.Position + Vector3.new(0, 5, 0)
                            
                            for _, model in pairs(liveFolder:GetChildren()) do
                                if model:IsA("Model")
                                    and model.Name ~= LocalPlayer.Name
                                    and model:FindFirstChild("HumanoidRootPart")
                                    and model:FindFirstChild("GuardCanKill")
                                then
                                    model:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(gatherPos)
                                end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
            
            -- Убийство
            task.spawn(function()
                while PlayerKillerSettings.Enabled do
                    pcall(function()
                        local Character = LocalPlayer.Character
                        local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                        local liveFolder = Workspace:FindFirstChild("Live")
                        local tool = Character and Character:FindFirstChildOfClass("Tool")
                        
                        if liveFolder and tool and HumanoidRootPart then
                            for _, model in pairs(liveFolder:GetChildren()) do
                                if model:IsA("Model")
                                    and model.Name ~= LocalPlayer.Name
                                    and model:FindFirstChild("HumanoidRootPart")
                                    and model:FindFirstChild("GuardCanKill")
                                then
                                    local humanoid = model:FindFirstChild("Humanoid")
                                    
                                    if humanoid and humanoid.Health > 0 then
                                        local hitPart = (PlayerKillerSettings.OnlyHeadshots and model:FindFirstChild("Head"))
                                            or model:FindFirstChild("HumanoidRootPart")
                                        
                                        if hitPart then
                                            pcall(function()
                                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(
                                                    tool,
                                                    {
                                                        ClientRayNormal = (hitPart.Position - HumanoidRootPart.Position).Unit,
                                                        FiredGun = true,
                                                        ClientRayInstance = hitPart,
                                                        HitTargets = {hitPart},
                                                        ClientRayPosition = hitPart.Position,
                                                        FirePosition = HumanoidRootPart.Position,
                                                        Value = 1,
                                                        Ammo = 1
                                                    }
                                                )
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end)
end
