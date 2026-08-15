if _G.AutofarmRunning then return end
_G.AutofarmRunning = true
_G.AutofarmEnabled = true

local LocalPlayer = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerKillerSettings = {
    Enabled = true,
    OnlyHeadshots = true,
    TargetDistance = 1000,
    HeartbeatConnection = nil
}

local function get_local_gun()
    local gun = nil

    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                gun = tool
                break
            end
        end
    end

    if not gun and LocalPlayer.Backpack then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                gun = tool
                break
            end
        end
    end

    return gun
end

local function teleport_to_shop()
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
end

local function click_enrollment_buttons()
    if not getconnections or type(getconnections) ~= "function" then
        return false
    end

    local enrollFolder = LocalPlayer.PlayerGui:WaitForChild("UIHolderScreenInset"):WaitForChild("EnrollForGuardAsk")

    -- Button 1
    local headerPrompt = enrollFolder:FindFirstChild("HeaderPrompt")
    if headerPrompt then
        local green1 = headerPrompt:FindFirstChild("Green")
        if green1 then
            local button1 = green1:FindFirstChild("Green")
            if button1 then
                local connections = getconnections(button1.MouseButton1Click)
                if connections then
                    for _, connection in ipairs(connections) do
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
                for _, connection in ipairs(connections) do
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
                    for _, connection in ipairs(connections) do
                        pcall(function() connection:Fire() end)
                    end
                end
            end
        end
    end
    task.wait(1)

    return true
end

local function start_killing_loop()
    local last = 0
    
    PlayerKillerSettings.HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not PlayerKillerSettings.Enabled then return end
        
        local now = tick()
        if now - last < 0.08 then return end
        last = now

        local gun = get_local_gun()
        if not gun then return end

        local hits = {}
        local live = Workspace:FindFirstChild("Live")
        
        if live then
            for _, model in ipairs(live:GetChildren()) do
                if model:IsA("Model")
                    and model.Name ~= LocalPlayer.Name
                    and model:FindFirstChild("HumanoidRootPart")
                    and model:FindFirstChild("GuardCanKill")
                then
                    local humanoid = model:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        hits[model.Name] = PlayerKillerSettings.OnlyHeadshots and "Head" or "HumanoidRootPart"
                    end
                end
            end
        end

        if next(hits) == nil then return end

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local remote = remotes and remotes:FindFirstChild("FiredGunClient")
        if not remote then return end

        local args = {
            gun,
            {
                ClientRayNormal = Vector3.new(0, 1, 0),
                FiredGun = true,
                SecondaryHitTargets = {},
                ClientRayInstance = Workspace,
                ClientRayPosition = Vector3.new(0, 0, 0),
                bulletCF = CFrame.new(),
                HitTargets = hits,
                bulletSizeC = Vector3.new(0.01, 0.01, 5),
                NoMuzzleFX = true,
                FirePosition = Vector3.new(0, 0, 0)
            }
        }

        pcall(function() remote:FireServer(unpack(args)) end)
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
                    
                    pcall(function()
                        local button = LocalPlayer.PlayerGui:WaitForChild("Spectating"):WaitForChild("SpectateScreen"):WaitForChild("Content"):WaitForChild("ButtonOptions"):WaitForChild("ReturnLobby")
                        if button and button:IsA("GuiButton") and getconnections then
                            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                                connection:Fire()
                            end
                        end
                    end)
                    
                    PlayerKillerSettings.Enabled = false
                    if PlayerKillerSettings.HeartbeatConnection then
                        PlayerKillerSettings.HeartbeatConnection:Disconnect()
                    end
                    _G.AutofarmRunning = false
                    break
                end
            end
        end
        task.wait(0.5)
    end
end)
task.wait(3)
