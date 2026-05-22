-- // Muscle Masters - Super Fast Strength + Best Bench Script
-- Auto trains on the BEST bench available

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local virtualUser = game:GetService("VirtualUser")

-- Settings
local autoTrainEnabled = true
local autoRebirthEnabled = true
local useBestBench = true
local strengthMultiplier = 9999999

print("🔥 Muscle Masters Best Bench Script Loaded")

-- Anti-AFK
player.Idled:Connect(function()
    virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Function to find and go to the BEST bench
local function getBestBench()
    local bestBench = nil
    local bestValue = 0
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("Part") then
            local name = v.Name:lower()
            if name:find("bench") or name:find("press") or name:find("weight") then
                
                -- Prioritize higher tier benches (Muscle King, Emperor, etc.)
                local value = 0
                if name:find("emperor") or name:find("king") then value = 1000
                elseif name:find("legend") or name:find("ultimate") then value = 500
                elseif name:find("pro") or name:find("advanced") then value = 200
                elseif name:find("basic") then value = 50
                end
                
                if value > bestValue then
                    bestValue = value
                    bestBench = v
                end
            end
        end
    end
    return bestBench
end

-- Teleport to best bench + train on it
spawn(function()
    while useBestBench and autoTrainEnabled do
        task.wait(0.5)
        
        local bench = getBestBench()
        if bench and humanoidRootPart then
            -- Teleport near the best bench
            local root = bench:FindFirstChild("HumanoidRootPart") or bench:FindFirstChildWhichIsA("BasePart")
            if root then
                humanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 5, 3)
                task.wait(0.3)
            end
        end
    end
end)

-- Super Fast Training Loop (Best Bench Focused)
spawn(function()
    while autoTrainEnabled do
        task.wait(0.01)
        
        pcall(function()
            -- Fire training remote
            local trainRemote = replicatedStorage:FindFirstChild("TrainEvent") 
                              or replicatedStorage:FindFirstChild("StrengthEvent")
                              or replicatedStorage:FindFirstChild("LiftEvent")
            
            if trainRemote then
                trainRemote:FireServer(strengthMultiplier)
            end
            
            -- Fire proximity prompts on benches
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and (v.Name:lower():find("bench") or v.Name:lower():find("press") or v.Name:lower():find("lift")) then
                    fireproximityprompt(v, 0)
                end
            end
        end)
    end
end)

-- Auto Rebirth
spawn(function()
    while autoRebirthEnabled do
        task.wait(1)
        
        pcall(function()
            local rebirthRemote = replicatedStorage:FindFirstChild("RebirthEvent") 
                               or replicatedStorage:FindFirstChild("Rebirth") 
                               or replicatedStorage:FindFirstChild("RebirthRequest")
            
            if rebirthRemote then
                local rebirths = player.leaderstats:FindFirstChild("Rebirths") or player:FindFirstChild("Rebirths")
                if rebirths then
                    rebirthRemote:FireServer()
                end
            end
        end)
    end
end)

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "Muscle Masters Script";
    Text = "Super Fast Strength + Best Bench Auto-Train Activated 💪";
    Duration = 6;
})

print("✅ Now training on the best benches automatically!")
