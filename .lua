if _G.AutofarmRunning then return end
_G.AutofarmRunning = true
_G.AutofarmEnabled = true

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
            
            local lastShot = 0
            RunService.Heartbeat:Connect(function()
                if not PlayerKillerSettings.Enabled then return end
                
                local now = tick()
                if now - lastShot < 0.08 then return end
                lastShot = now
                
                pcall(function()
                    local Character = LocalPlayer.Character
                    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    local gun = Character and Character:FindFirstChildOfClass("Tool")
                    local liveFolder = Workspace:FindFirstChild("Live")
                    
                    if not (gun and HumanoidRootPart and liveFolder) then return end
                    
                    local hits = {}
                    local rootPos = HumanoidRootPart.Position
                    
                    for _, model in ipairs(liveFolder:GetChildren()) do
                        if model:IsA("Model")
                            and model.Name ~= LocalPlayer.Name
                            and model:FindFirstChild("HumanoidRootPart")
                            and model:FindFirstChild("GuardCanKill")
                        then
                            local targetRoot = model:FindFirstChild("HumanoidRootPart")
                            local humanoid = model:FindFirstChild("Humanoid")
                            
                            if targetRoot and humanoid and humanoid.Health > 0 then
                                hits[model.Name] = "Head"
                            end
                        end
                    end
                    
                    if next(hits) then
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes then
                            local remote = remotes:FindFirstChild("FiredGunClient")
                            if remote then
                                remote:FireServer(gun, {
                                    ClientRayNormal = Vector3.new(0, 1, 0),
                                    FiredGun = true,
                                    SecondaryHitTargets = {},
                                    ClientRayInstance = Workspace,
                                    ClientRayPosition = rootPos,
                                    bulletCF = CFrame.new(rootPos),
                                    HitTargets = hits,
                                    bulletSizeC = Vector3.new(0.01, 0.01, 5),
                                    NoMuzzleFX = false,
                                    FirePosition = rootPos
                                })
                            end
                        end
                    end
                end)
            end)

            task.spawn(function()
                local anchorDetected = false
                local disappearCount = 0

                while PlayerKillerSettings.Enabled do
                    pcall(function()
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
                                    PlayerKillerSettings.Enabled = false
                                    _G.AutofarmRunning = false
                                    break
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)

            task.wait(3)
        end

        task.wait(5)
    end)
end

_G.AutofarmRunning = false
