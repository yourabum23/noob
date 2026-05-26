-- Larp Hub - Kill All + Auto Equip + ULTRA ANTI-REJOIN + 45s Auto Hop
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- ==================== SETTINGS ====================
local killAllEnabled = true
local autoEquipEnabled = true
local hopEnabled = false
local performanceBoostEnabled = false
local hopAfterSeconds = 45
-- =================================================

setfpscap(60)

local disableAllGUIs = false

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
                    if gui:IsA("ScreenGui") then gui.Enabled = false end
                end
            end)
            task.wait(6)
        end
    end)
end

-- ====================== SERVER HOP ======================
local hasHopped = false
local function GETOUT(reason)
    if hasHopped then return end
    hasHopped = true
    print("🔄 " .. (reason or "Hopping") .. " | Timer complete")
 
    local Services = setmetatable({}, { __index = function(self, name)
        return cloneref(game:GetService(name))
    end})
    
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    local servers = {}
    
    local success, req = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    end)
    
    if success and req then
        local body = Services.HttpService:JSONDecode(req)
        if body and body.data then
            for _, v in ipairs(body.data) do
                if v.playing and v.maxPlayers and v.playing < v.maxPlayers and v.id ~= JobId then
                    table.insert(servers, v.id)
                end
            end
        end
    end
    
    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        addToAvoidList(chosen)
        print("🎯 Hopping to new server")
        TeleportService:TeleportToPlaceInstance(PlaceId, chosen, player)
    else
        print("⚠️ No servers, retrying...")
        hasHopped = false
        task.wait(5)
    end
end

if hopEnabled then
    task.spawn(function()
        while hopEnabled do
            task.wait(hopAfterSeconds)
            if not hasHopped then
                GETOUT("Auto hop timer")
            end
        end
    end)
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

-- ====================== KILL ALL (Stable No Crash Version) ======================
task.spawn(function()
    applyPerformanceBoost()
    disableGUIs()

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local muscleEvent = ReplicatedStorage:FindFirstChild("muscleEvent") or player:FindFirstChild("muscleEvent")

    while killAllEnabled do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.3) continue
        end
  
        local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
        
        if not (rightHand and leftHand) then
            task.wait(0.25) continue
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
                    
                    task.wait(0.006)   -- Increased to reduce lag
                    
                    firetouchinterest(rightHand, tRoot, 0)
                    firetouchinterest(leftHand, tRoot, 0)
                end)
            end
        end
       
        task.wait(0.085)   -- Main delay - very important for stability
    end
end)

print("✅ Script Loaded | Full Kill All | Auto Hop Every " .. hopAfterSeconds .. "s")
