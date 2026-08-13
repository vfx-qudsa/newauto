if _G.AutofarmRunning then return end
_G.AutofarmRunning = true
_G.AutofarmEnabled = true

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerKillerSettings = {
    Enabled = true,
    OnlyHeadshots = true,
    TargetDistance = 1000
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

        if getconnections and type(getconnections) == "function" then
            -- Button 1
            local headerPrompt = enrollFolder:FindFirstChild("HeaderPrompt")
            if headerPrompt then
                local green1 = headerPrompt:FindFirstChild("Green")
                if green1 then
                    local button1 = green1:FindFirstChild("Green")
                    if button1 then
                        local connections = getconnections(button1.MouseButton1Click)
                        if connections then
                            for _, connection in pairs(connections) do
                                pcall(function() connection:Fire() end)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
            
            -- Button 2
            local rankSelection = enrollFolder:FindFirstChild("RankSelection")
            if rankSelection then
                local button2 = rankSelection:FindFirstChild("EquipTier1")
                if button2 then
                    local connections = getconnections(button2.MouseButton1Click)
                    if connections then
                        for _, connection in pairs(connections) do
                            pcall(function() connection:Fire() end)
                        end
                    end
                end
            end
            task.wait(0.5)
            
            -- Button 3
            local rankConfirmation = enrollFolder:FindFirstChild("RankConfirmation")
            if rankConfirmation then
                local green2 = rankConfirmation:FindFirstChild("Green")
                if green2 then
                    local button3 = green2:FindFirstChild("Green")
                    if button3 then
                        local connections = getconnections(button3.MouseButton1Click)
                        if connections then
                            for _, connection in pairs(connections) do
                                pcall(function() connection:Fire() end)
                            end
                        end
                    end
                end
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
        end

        task.wait(5)
    end)
end

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

                                local spectating = LocalPlayer.PlayerGui:FindFirstChild("Spectating")
                                if spectating then
                                    local spectateScreen = spectating:FindFirstChild("SpectateScreen")
                                    if spectateScreen then
                                        local content = spectateScreen:FindFirstChild("Content")
                                        if content then
                                            local buttonOptions = content:FindFirstChild("ButtonOptions")
                                            if buttonOptions then
                                                local button = buttonOptions:FindFirstChild("ReturnLobby")
                                                if button and button:IsA("GuiButton") then
                                                    button:Activate()
                                                end
                                            end
                                        end
                                    end
                                end

                                PlayerKillerSettings.Enabled = false
                                _G.AutofarmRunning = false
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

_G.AutofarmRunning = false
