-- Larp Hub - Kill All + Auto Equip + ULTRA ANTI-REJOIN
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- ==================== SETTINGS ====================
local killAllEnabled = true
local autoEquipEnabled = true
local hopEnabled = false
local performanceBoostEnabled = false
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
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local muscleEvent = ReplicatedStorage:FindFirstChild("muscleEvent") or player:FindFirstChild("muscleEvent")

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
                    else
                        player.muscleEvent:FireServer("punch", "rightHand")
                        player.muscleEvent:FireServer("punch", "leftHand")
                    end
                  
                    task.wait(0.0045)
                  
                    firetouchinterest(rightHand, tRoot, 0)
                    firetouchinterest(leftHand, tRoot, 0)
                end)
            end
        end
     
        task.wait(0.068)
    end
end)

print("✅ Script Loaded | Improved Kill All Active")
