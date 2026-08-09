if _G.AutofarmRunning then return end
_G.AutofarmRunning = true
_G.AutofarmEnabled = true

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrentGame = Workspace.Values.CurrentGame

local function log(msg)
    print("[AutoFarm] " .. os.date("%H:%M:%S") .. " | " .. msg)
end

local PlayerKillerSettings = { Enabled = true, OnlyHeadshots = true }

local function killAndReturn()
    log("Убиваем и возвращаемся в лобби")
    PlayerKillerSettings.Enabled = false
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.Health = 0 end
    task.wait(2)
    local button = LocalPlayer.PlayerGui:WaitForChild("Spectating").SpectateScreen.Content.ButtonOptions.ReturnLobby
    if button and button:IsA("GuiButton") then
        for _, c in pairs(getconnections(button.MouseButton1Click)) do c:Fire() end
    end
end

local function waitForValue(value)
    log("Ожидаем: " .. value)
    while CurrentGame.Value ~= value do task.wait(0.5) end
    log("Получили: " .. value)
end

local function startKiller()
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

while _G.AutofarmEnabled do
    pcall(function()
        local teleported = false
        task.spawn(function()
            while not teleported do
                if Workspace:FindFirstChild("Shop") then
                    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(185, 66, -26)
                    teleported = true
                end
                task.wait(0.1)
            end
        end)

        task.wait(1)
        LocalPlayer:SetAttribute("__OwnsPermGuard", true)
        local enrollFolder = LocalPlayer.PlayerGui:WaitForChild("UIHolderScreenInset"):WaitForChild("EnrollForGuardAsk")

        if getconnections then
            local b1 = enrollFolder:WaitForChild("HeaderPrompt"):WaitForChild("Green"):WaitForChild("Green")
            for _, c in pairs(getconnections(b1.MouseButton1Click)) do pcall(function() c:Fire() end) end
            task.wait(0.5)

            local b2 = enrollFolder:WaitForChild("RankSelection"):WaitForChild("EquipTier1")
            for _, c in pairs(getconnections(b2.MouseButton1Click)) do pcall(function() c:Fire() end) end
            task.wait(0.5)

            local b3 = enrollFolder:WaitForChild("RankConfirmation"):WaitForChild("Green"):WaitForChild("Green")
            for _, c in pairs(getconnections(b3.MouseButton1Click)) do pcall(function() c:Fire() end) end
            task.wait(1)

            startKiller()

            -- Ждём конца RedLightGreenLight
log("Ждём конца RedLightGreenLight")
while CurrentGame.Value == "RedLightGreenLight" do task.wait(0.5) end
log("CurrentGame: '" .. tostring(CurrentGame.Value) .. "'")

-- Ждём 2 анчора
log("Ждём 2 появления и исчезновения Anchor")
local anchorCount = 0
local anchorDetected = false

while anchorCount < 2 do
    local liveFolder = Workspace:FindFirstChild("Live")
    local anchorExists = false

    if liveFolder then
        for _, model in pairs(liveFolder:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Anchor") then
                anchorExists = true
                break
            end
        end
    end

    if anchorExists and not anchorDetected then
        anchorDetected = true
        log("Anchor появился (" .. (anchorCount + 1) .. ")")
    elseif not anchorExists and anchorDetected then
        anchorDetected = false
        anchorCount = anchorCount + 1
        log("Anchor исчез (" .. anchorCount .. ")")
    end

    task.wait(0.5)
end

log("2 анчора отработали - начинаем отсчёт 40 секунд")

-- Теперь проверяем StairWalkWay в течение 40 секунд
local checkStart = tick()
local hasStairs = false
while tick() - checkStart < 40 do
    if CurrentGame.Value == "StairWalkWay" then
        hasStairs = true
        break
    end
    task.wait(0.5)
end

if not hasStairs then
    log("StairWalkWay не появился - умираем")
    killAndReturn()
    _G.AutofarmRunning = false
    return
end

-- Цепочка StairWalkWay -> DalgonaWaiting -> Dalgona
log("StairWalkWay есть - идём по цепочке")
waitForValue("DalgonaWaiting")
waitForValue("Dalgona")

log("Ждём конца Dalgona")
while CurrentGame.Value == "Dalgona" do task.wait(0.5) end
log("Dalgona закончилась - умираем")

killAndReturn()
_G.AutofarmRunning = false
task.wait(3)
