-- Larp Hub - Kill All + Auto Equip + ULTRA ANTI-REJOIN + 30s Auto Hop
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- ==================== SETTINGS ====================
local killAllEnabled = true
local autoEquipEnabled = true
local hopEnabled = true
local performanceBoostEnabled = true

local hopAfterSeconds = 30  -- Change this if you want different time
-- =================================================

local disableAllGUIs = true

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

-- ====================== SERVER HOP SYSTEM ======================
local hasHopped = false

local function GETOUT(reason)
    if hasHopped then return end
    hasHopped = true
   
    print("🔄 " .. (reason or "Hopping") .. " | 30s timer complete")
   
    local Services = setmetatable({}, {
        __index = function(self, name)
            local success, cache = pcall(function()
                return cloneref(game:GetService(name))
            end)
            if success then
                rawset(self, name, cache)
                return cache
            else
                error("Invalid Service: " .. tostring(name))
            end
        end
    })
   
    local PlaceId, JobId = game.PlaceId, game.JobId
    local servers = {}
   
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = Services.HttpService:JSONDecode(req)
   
    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers)
               and v.playing < v.maxPlayers and v.id ~= JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end
   
    if #servers >= 1 then
        local chosen = servers[math.random(1, #servers)]
        addToAvoidList(chosen)
        print("🎯 Hopping to new server")
        Services.TeleportService:TeleportToPlaceInstance(PlaceId, chosen, game.Players.LocalPlayer)
    else
        print("⚠️ No available servers, retrying in 5s...")
        hasHopped = false
        task.wait(5)
    end
end

-- ====================== 30 SECOND AUTO HOP (Every Server) ======================
if hopEnabled then
    task.spawn(function()
        while hopEnabled do
            task.wait(hopAfterSeconds)
            if not hasHopped then
                GETOUT("30 seconds reached")
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

-- ====================== KILL ALL ======================
task.spawn(function()
    applyPerformanceBoost()
    disableGUIs()
  
    while killAllEnabled do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5) continue
        end
   
        local rightHand = char:FindFirstChild("RightHand")
        local leftHand = char:FindFirstChild("LeftHand")
        if not (rightHand and leftHand) then
            task.wait(0.4) continue
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
                    task.wait(0.008)
                    firetouchinterest(rightHand, tRoot, 0)
                    firetouchinterest(leftHand, tRoot, 0)
               
                    player.muscleEvent:FireServer("punch", "rightHand")
                    player.muscleEvent:FireServer("punch", "leftHand")
                end)
            end
        end
        task.wait(0.08)
    end
end)

print("✅ Script Loaded | Auto Hop Every " .. hopAfterSeconds .. " Seconds")
