-- Larp Hub - Kill All + Auto Equip + ULTRA ANTI-REJOIN
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- ==================== SETTINGS ====================
local killAllEnabled = true
local autoEquipEnabled = true
local hopEnabled = true
local performanceBoostEnabled = true
local disableAllGUIs = true
local hopAfterSeconds = 40
-- =================================================

setfpscap(50)

-- ULTRA BLACKLIST
getgenv().AvoidedServers = getgenv().AvoidedServers or {}
local maxAvoid = 400

local function addToAvoidList(jobId)
    if not table.find(getgenv().AvoidedServers, jobId) then
        table.insert(getgenv().AvoidedServers, jobId)
        if #getgenv().AvoidedServers > maxAvoid then
            table.remove(getgenv().AvoidedServers, 1)
        end
    end
end
addToAvoidList(game.JobId)

-- ====================== PERFORMANCE ======================
local function applyPerformanceBoost()
    if not performanceBoostEnabled then return end
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1e5
        Lighting.FogStart = 1e5
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        setfpscap(9999)
    end)
end

local function disableGUIs()
    if not disableAllGUIs then return end
    task.spawn(function()
        while disableAllGUIs do
            pcall(function()
                for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and not gui:FindFirstChild("LarpHubStats") then
                        gui.Enabled = false
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- ====================== STATS GUI (Kills Tracker) ======================
local function createStatsGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LarpHubStats"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 110)
    frame.Position = UDim2.new(1, -230, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Larp Hub - Kills"
    title.TextColor3 = Color3.fromRGB(247, 241, 141)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local totalKills = Instance.new("TextLabel")
    totalKills.Size = UDim2.new(1, 0, 0, 30)
    totalKills.Position = UDim2.new(0, 0, 0, 35)
    totalKills.BackgroundTransparency = 1
    totalKills.Text = "Total Kills: 0"
    totalKills.TextColor3 = Color3.fromRGB(255, 255, 255)
    totalKills.TextScaled = true
    totalKills.Font = Enum.Font.Gotham
    totalKills.Parent = frame

    local gainedKills = Instance.new("TextLabel")
    gainedKills.Size = UDim2.new(1, 0, 0, 30)
    gainedKills.Position = UDim2.new(0, 0, 0, 65)
    gainedKills.BackgroundTransparency = 1
    gainedKills.Text = "Gained This Server: 0"
    gainedKills.TextColor3 = Color3.fromRGB(0, 255, 100)
    gainedKills.TextScaled = true
    gainedKills.Font = Enum.Font.Gotham
    gainedKills.Parent = frame

    return totalKills, gainedKills
end

-- ====================== AUTO EQUIP ======================
if autoEquipEnabled then
    task.spawn(function()
        while autoEquipEnabled do
            local char = player.Character
            if char then
                local punch = player.Backpack:FindFirstChild("Punch")
                if punch and not char:FindFirstChild("Punch") then
                    punch.Parent = char
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ====================== IMPROVED KILL ALL ======================
task.spawn(function()
    applyPerformanceBoost()
    disableGUIs()

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local muscleEvent = ReplicatedStorage:FindFirstChild("muscleEvent") or player:FindFirstChild("muscleEvent")

    local totalKillsLabel, gainedKillsLabel = createStatsGUI()

    local leaderstats = player:WaitForChild("leaderstats")
    local killsStat = leaderstats:WaitForChild("Kills")
    local initialKills = killsStat.Value

    while killAllEnabled do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.25) continue
        end
        
        local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
      
        if not (rightHand and leftHand) then
            task.wait(0.2) continue
        end

        for _, target in ipairs(game.Players:GetPlayers()) do
            if target == player then continue end
      
            local isFriend = false
            pcall(function()
                isFriend = player:IsFriendsWith(target.UserId)
            end)
            if isFriend then continue end
      
            local tChar = target.Character
            if not tChar then continue end
    
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
    
            if tRoot and tHum and tHum.Health > 0 then
                pcall(function()
                    firetouchinterest(rightHand, tRoot, 1)
                    firetouchinterest(leftHand, tRoot, 1)
                  
                    if muscleEvent then
                        muscleEvent:FireServer("punch", "rightHand")
                        muscleEvent:FireServer("punch", "leftHand")
                    end
                  
                    task.wait(0.0045)
                  
                    firetouchinterest(rightHand, tRoot, 0)
                    firetouchinterest(leftHand, tRoot, 0)
                end)
            end
        end
     
        -- Update GUI
        local currentKills = killsStat.Value
        totalKillsLabel.Text = "Total Kills: " .. currentKills
        gainedKillsLabel.Text = "Gained This Server: " .. (currentKills - initialKills)
        
        task.wait(0.068)
    end
end)

print("✅ Script Loaded | Improved Kill All + Stats GUI")
