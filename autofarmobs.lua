-- Larp Hub - Kill All + Auto Equip + ULTRA ANTI-REJOIN + Big Servers Only
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ==================== SETTINGS ====================
local killAllEnabled = true
local autoEquipEnabled = true
local hopEnabled = true

local minPlayersToHop = 7
local targetMinPlayers = 12      -- Only hop to servers with 12+
local maxPreferredPlayers = 19   -- Up to full servers
-- =================================================

local disableAllGUIs = true
local freezeInAirEnabled = true
local freezeHeight = 10000

-- ULTRA BLACKLIST
getgenv().AvoidedServers = getgenv().AvoidedServers or {}
local maxAvoid = 80

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
    
    freezeConnection = RunService.Heartbeat:Connect(function()
        if root and root.Parent then
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            local currentPos = root.Position
            root.CFrame = CFrame.new(currentPos.X, freezeHeight, currentPos.Z)
        end
    end)
end

task.spawn(function()
    if freezeInAirEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(1.5)
            freezePlayerInAir()
        end)
        if player.Character then
            task.wait(1.5)
            freezePlayerInAir()
        end
    end
end)

local function applyPerformanceBoost()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
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
            task.wait(5)
        end
    end)
end

-- ====================== ULTRA SERVER HOP (Big Servers) ======================
local hasHopped = false

local function findBestServer()
    local success, result = pcall(function()
        local goodServers = {}
        local cursor = ""
       
        print("🔍 Scanning for BIG servers (12-45 players)...")
        for page = 1, 70 do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
           
            local response = HttpService:GetAsync(url)
            local data = HttpService:JSONDecode(response)
           
            for _, server in ipairs(data.data) do
                local plrs = server.playing
                if plrs >= targetMinPlayers 
                   and plrs <= maxPreferredPlayers 
                   and not table.find(getgenv().AvoidedServers, server.id) then
                    table.insert(goodServers, server)
                end
            end
           
            cursor = data.nextPageCursor
            if not cursor then break end
            task.wait(0.025)
        end
       
        if #goodServers == 0 then return nil end
       
        -- Sort by HIGHEST players first
        table.sort(goodServers, function(a, b)
            return a.playing > b.playing
        end)
       
        return goodServers[1]
    end)
   
    return success and result or nil
end

local function serverHop(reason)
    if hasHopped then return end
    hasHopped = true
   
    print("🔄 " .. reason .. " | Avoiding " .. #getgenv().AvoidedServers .. " servers | Searching big servers...")
    task.wait(4.5) -- Longer delay to prevent rejoin
    
    local bestServer = findBestServer()
   
    if bestServer then
        addToAvoidList(bestServer.id)
        print("🎯 Hopping to BIG server (" .. bestServer.playing .. " players)")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, player)
    else
        print("⚠️ No big server found → FORCING BLIND HOP")
        task.wait(3)
        addToAvoidList(game.JobId)
        TeleportService:Teleport(game.PlaceId, player) -- Strongest anti-rejoin
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
        if not (rightHand and leftHand) then task.wait(0.4) continue end
       
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
                    task.wait(0.01)
                    firetouchinterest(rightHand, tRoot, 0)
                    firetouchinterest(leftHand, tRoot, 0)
                   
                    player.muscleEvent:FireServer("punch", "rightHand")
                    player.muscleEvent:FireServer("punch", "leftHand")
                end)
            end
        end
        task.wait(0.15)
    end
end)

print("✅ Script Loaded - ULTRA Anti-Rejoin + Big Servers")
print(" → Only hops to 12+ players | Stronger blacklist")
