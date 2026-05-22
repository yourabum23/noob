-- Larp Hub - Kill All + Auto Equip + MAX ANTI-REJOIN + Tiny Island Safe
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- ==================== SETTINGS ====================
local killAllEnabled = true
local autoEquipEnabled = true
local hopEnabled = true

local minPlayersToHop = 7
local targetMinPlayers = 7
local maxPreferredPlayers = 18

local safeIslandEnabled = true
-- =================================================

local disableAllGUIs = true

-- MAX BLACKLIST
getgenv().AvoidedServers = getgenv().AvoidedServers or {}
local maxAvoid = 60

local function addToAvoidList(jobId)
    if not table.find(getgenv().AvoidedServers, jobId) then
        table.insert(getgenv().AvoidedServers, jobId)
        if #getgenv().AvoidedServers > maxAvoid then
            table.remove(getgenv().AvoidedServers, 1)
        end
    end
end

addToAvoidList(game.JobId)

-- ====================== TINY ISLAND SAFE ======================
local tinyIslandCFrame = CFrame.new(-4.25, 221, 1963.6)

local function teleportToTinyIsland()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = tinyIslandCFrame
        print("🛡️ Teleported to Tiny Island Safe Spot!")
    end
end

if safeIslandEnabled then
    task.spawn(function()
        while safeIslandEnabled do
            teleportToTinyIsland()
            task.wait(7)
        end
    end)
end

getgenv().safe = teleportToTinyIsland

local function applyPerformanceBoost()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        setfpscap(9999)
       
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
        end
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
            task.wait(5)
        end
    end)
end

-- ====================== SERVER HOP (Ultra Aggressive) ======================
local hasHopped = false

local function findBestServer()
    local success, result = pcall(function()
        local goodServers = {}
        local cursor = ""
       
        print("🔍 Full scanning Muscle Legends servers...")
        for page = 1, 50 do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
           
            local response = HttpService:GetAsync(url)
            local data = HttpService:JSONDecode(response)
           
            for _, server in ipairs(data.data) do
                local plrs = server.playing
                if plrs >= targetMinPlayers and plrs <= maxPreferredPlayers 
                   and plrs < server.maxPlayers 
                   and not table.find(getgenv().AvoidedServers, server.id) then
                    table.insert(goodServers, server)
                end
            end
           
            cursor = data.nextPageCursor
            if not cursor then break end
            task.wait(0.04)
        end
       
        if #goodServers == 0 then return nil end
       
        table.sort(goodServers, function(a, b) return a.playing > b.playing end)
       
        local top = math.min(20, #goodServers)
        for i = top, 2, -1 do
            local j = math.random(i)
            goodServers[i], goodServers[j] = goodServers[j], goodServers[i]
        end
       
        return goodServers[1]
    end)
   
    return success and result or nil
end

local function serverHop(reason)
    if hasHopped then return end
    hasHopped = true
   
    print("🔄 " .. reason .. " | Avoiding " .. #getgenv().AvoidedServers .. " servers...")
    task.wait(4) -- Extra long delay to break rejoin pattern
   
    local bestServer = findBestServer()
   
    if bestServer then
        addToAvoidList(bestServer.id)
        print("🎯 Found " .. bestServer.playing .. " players → Smart Hop")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, player)
    else
        print("⚠️ NO GOOD SERVER → FORCING BLIND RANDOM HOP")
        task.wait(2.5)
        addToAvoidList(game.JobId)
        TeleportService:Teleport(game.PlaceId, player)  -- Blind hop is most effective
    end
end

if hopEnabled then
    task.spawn(function()
        while hopEnabled and not hasHopped do
            local current = #game.Players:GetPlayers()
            if current < minPlayersToHop then
                serverHop("Player count dropped to " .. current)
                break
            end
            task.wait(2)
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
            task.wait(0.15)
        end
    end)
end

-- ====================== KILL ALL (FIXED) ======================
task.spawn(function()
    applyPerformanceBoost()
    disableGUIs()
   
    while killAllEnabled and not hasHopped do
        -- Removed safe mode pause so killing always works
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.6) continue
        end
       
        local rightHand = char:FindFirstChild("RightHand")
        local leftHand = char:FindFirstChild("LeftHand")
        if not (rightHand and leftHand) then 
            task.wait(0.4) continue 
        end
       
        for _, target in ipairs(game.Players:GetPlayers()) do
            if target == player then continue end
            local tChar = target.Character
            if not tChar then continue end
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                pcall(function()
                    firetouchinterest(rightHand, tRoot, 1)
                    firetouchinterest(leftHand, tRoot, 1)
                    task.wait(0.02)
                    firetouchinterest(rightHand, tRoot, 0)
                    firetouchinterest(leftHand, tRoot, 0)
                   
                    player.muscleEvent:FireServer("punch", "rightHand")
                    player.muscleEvent:FireServer("punch", "leftHand")
                end)
            end
        end
        task.wait(0.22)
    end
end)

print("✅ Script Loaded & Fixed")
print(" → Kill All always active | Tiny Island safe mode")
print(" → Max Anti-Rejoin (50+ pages + Blind hop)")
print(" → Type safe() for manual safe teleport")
