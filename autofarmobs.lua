-- Larp Hub - Kill All + Auto Equip + ULTRA ANTI-REJOIN + 7-18 Players Only
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- ==================== SETTINGS ====================
local killAllEnabled = true
local autoEquipEnabled = true
local hopEnabled = true

local minPlayersToHop = 6          -- Hop if below this
local targetMinPlayers = 7         -- Minimum players
local maxPreferredPlayers = 18     -- Maximum players (changed to 18)

local scanPages = 150              -- Deep scan
local hopDelay = 5
-- =================================================

local disableAllGUIs = true
local freezeInAirEnabled = true
local freezeHeight = 10000

-- ULTRA BLACKLIST
getgenv().AvoidedServers = getgenv().AvoidedServers or {}
local maxAvoid = 150

local function addToAvoidList(jobId)
    if not table.find(getgenv().AvoidedServers, jobId) then
        table.insert(getgenv().AvoidedServers, jobId)
        if #getgenv().AvoidedServers > maxAvoid then
            table.remove(getgenv().AvoidedServers, 1)
        end
    end
end

addToAvoidList(game.JobId)

-- ====================== FREEZE IN AIR ======================
local freezeConnection = nil
local function freezePlayerInAir()
    if not freezeInAirEnabled then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    root.CFrame = root.CFrame * CFrame.new(0, freezeHeight, 0)
    
    if freezeConnection then freezeConnection:Disconnect() end
    freezeConnection = RunService.Heartbeat:Connect(function()
        if root and root.Parent then
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            local pos = root.Position
            root.CFrame = CFrame.new(pos.X, freezeHeight, pos.Z)
        end
    end)
end

task.spawn(function()
    if freezeInAirEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(1.8)
            freezePlayerInAir()
        end)
        if player.Character then
            task.wait(1.8)
            freezePlayerInAir()
        end
    end
end)

-- ====================== PERFORMANCE & GUI ======================
local function applyPerformanceBoost()
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

-- ====================== SERVER HOP (7-18 Players) ======================
local hasHopped = false

local function findBestServer()
    local success, result = pcall(function()
        local goodServers = {}
        local cursor = ""

        print("🔍 Scanning for servers with 7-18 players...")

        for page = 1, scanPages do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor and cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local response = HttpService:GetAsync(url)
            local data = HttpService:JSONDecode(response)

            for _, server in ipairs(data.data or {}) do
                local plrs = server.playing or 0
                if plrs >= targetMinPlayers 
                   and plrs <= maxPreferredPlayers 
                   and not table.find(getgenv().AvoidedServers, server.id) 
                   and server.id ~= game.JobId then
                    
                    table.insert(goodServers, {
                        id = server.id,
                        playing = plrs,
                        maxPlayers = server.maxPlayers or 50
                    })
                end
            end

            cursor = data.nextPageCursor
            if not cursor then break end
            task.wait(0.025)
        end

        if #goodServers == 0 then return nil end

        -- Sort by highest players first (within 7-18)
        table.sort(goodServers, function(a, b)
            return a.playing > b.playing
        end)

        print("✅ Found " .. #goodServers .. " good servers. Best: " .. goodServers[1].playing .. " players")
        return goodServers[1]
    end)

    return success and result or nil
end

local function serverHop(reason)
    if hasHopped then return end
    hasHopped = true

    print("🔄 " .. reason .. " | Blacklisted: " .. #getgenv().AvoidedServers)
    task.wait(hopDelay)

    local bestServer = findBestServer()

    if bestServer then
        addToAvoidList(bestServer.id)
        print("🎯 Hopping to " .. bestServer.playing .. " players server")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, player)
    else
        print("⚠️ No 7-18 player servers found → Blind hop")
        task.wait(3)
        addToAvoidList(game.JobId)
        TeleportService:Teleport(game.PlaceId, player)
    end
end

-- Auto Hop Logic
if hopEnabled then
    task.spawn(function()
        while hopEnabled and not hasHopped do
            local current = #game.Players:GetPlayers()
            if current < minPlayersToHop then
                serverHop("Player count dropped to " .. current)
                break
            end
            task.wait(2.5)
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

    while killAllEnabled and not hasHopped do
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
        task.wait(0.12)
    end
end)

print("✅ Script Loaded - Targeting 7 to 18 Players")
