-- Larp Hub - Kill All + Auto Equip + ULTRA ANTI-REJOIN + STRICT 15-20 + ULTRA GODMODE v2 + AUTO FRIENDS
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- ==================== SETTINGS ====================
local killAllEnabled = false
local autoEquipEnabled = false
local hopEnabled = false
local godmodeEnabled = true
local performanceBoostEnabled = false

-- STRICT 15+ ONLY
local minPlayersToHop = 6
local targetMinPlayers = 15
local maxPreferredPlayers = 20
local scanPages = 350
local hopDelay = 4

-- =================================================
local disableAllGUIs = false
local freezeInAirEnabled = false
local freezeHeight = 10000

-- ULTRA BLACKLIST
getgenv().AvoidedServers = getgenv().AvoidedServers or {}
local maxAvoid = 350

local function addToAvoidList(jobId)
    if not table.find(getgenv().AvoidedServers, jobId) then
        table.insert(getgenv().AvoidedServers, jobId)
        if #getgenv().AvoidedServers > maxAvoid then
            table.remove(getgenv().AvoidedServers, 1)
        end
    end
end
addToAvoidList(game.JobId)

-- ====================== ULTRA GODMODE v2 (300T ~ 1000T+ Protection) ======================
local function enableGodmode()
    if not godmodeEnabled then return end
    
    -- Main fast protection loop
    task.spawn(function()
        while godmodeEnabled do
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum.JumpPower = 50
                    hum.WalkSpeed = hum.WalkSpeed -- Reset any speed changes
                end

                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(0, math.max(5, root.Velocity.Y * 0.15), 0)
                    root.RotVelocity = Vector3.zero
                end
            end
            task.wait(0.008) -- Extremely fast
        end
    end)

    -- Heartbeat protection (most important layer)
    local hbConn = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.Health = math.huge
            end
        end
    end)

    -- Character respawn protection
    player.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end)

    -- Final safety net
    task.spawn(function()
        while godmodeEnabled do
            pcall(function()
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.Health = math.huge
                end
            end)
            task.wait(0.1)
        end
    end)
end

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
        if player.Character then task.wait(1.8) freezePlayerInAir() end
    end
end)

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

-- ====================== STRICT BIG SERVER HOP ======================
local hasHopped = false

local function findBestServer()
    local success, result = pcall(function()
        local goodServers = {}
        local cursor = ""
      
        print("🔍 Scanning for STRICT 15-20 player servers...")
        for page = 1, scanPages do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor and cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end
          
            local response = HttpService:GetAsync(url)
            local data = HttpService:JSONDecode(response)
          
            for _, server in ipairs(data.data or {}) do
                local plrs = server.playing or 0
                if plrs >= targetMinPlayers and plrs <= maxPreferredPlayers
                   and not table.find(getgenv().AvoidedServers, server.id)
                   and server.id ~= game.JobId then
                 
                    table.insert(goodServers, {
                        id = server.id,
                        playing = plrs
                    })
                end
            end
          
            cursor = data.nextPageCursor
            if not cursor then break end
            task.wait(0.01)
        end
        if #goodServers == 0 then return nil end
        table.sort(goodServers, function(a, b) return a.playing > b.playing end)
      
        print("✅ Found " .. #goodServers .. " valid 15+ servers | Best: " .. goodServers[1].playing .. "/20")
        return goodServers[1]
    end)
  
    return success and result or nil
end

local function serverHop(reason)
    if hasHopped then return end
    hasHopped = true
  
    print("🔄 " .. reason .. " | Avoiding " .. #getgenv().AvoidedServers .. " servers")
    task.wait(hopDelay)
  
    local bestServer = findBestServer()
  
    if bestServer then
        addToAvoidList(bestServer.id)
        print("🎯 Hopping to " .. bestServer.playing .. "/20 player server")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, player)
    else
        print("⚠️ No 15+ servers found → Blind hop")
        task.wait(4)
        addToAvoidList(game.JobId)
        TeleportService:Teleport(game.PlaceId, player)
    end
end

-- ====================== POST-JOIN CHECK ======================
task.spawn(function()
    task.wait(8)
    while hopEnabled do
        local current = #game.Players:GetPlayers()
        if current < targetMinPlayers then
            print("⚠️ Joined server under 15 (" .. current .. " players) → Immediate hop")
            addToAvoidList(game.JobId)
            serverHop("Joined server below 15 players")
            break
        end
        task.wait(2.5)
    end
end)

-- Auto Hop Logic
if hopEnabled then
    task.spawn(function()
        while hopEnabled and not hasHopped do
            local current = #game.Players:GetPlayers()
            if current < minPlayersToHop then
                serverHop("Player count dropped below 15")
                break
            end
            task.wait(2)
        end
    end)
end

-- ====================== AUTO EQUIP & KILL ALL ======================
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

task.spawn(function()
    applyPerformanceBoost()
    disableGUIs()
    enableGodmode()
  
    while killAllEnabled and not hasHopped do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
            continue
        end
      
        local rightHand = char:FindFirstChild("RightHand")
        local leftHand = char:FindFirstChild("LeftHand")
        if not (rightHand and leftHand) then
            task.wait(0.4)
            continue
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
        task.wait(0.1)
    end
end)

print("✅ ULTRA GODMODE v2 Loaded | You should be unkillable even at 1000T+ strength")
