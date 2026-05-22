-- // Muscle Masters - Best Bench Auto Train + Sit Fix
-- Now actually gets on the bench properly

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local virtualUser = game:GetService("VirtualUser")

-- Settings
local autoTrainEnabled = true
local autoRebirthEnabled = true
local strengthMultiplier = 9999999

print("🔥 Muscle Masters Best Bench Script v2 Loaded")

-- Anti-AFK
player.Idled:Connect(function()
    virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Find Best Bench (improved detection)
local function getBestBench()
    local bestBench = nil
    local bestScore = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("bench") or name:find("press") or name:find("king") or name:find("emperor") or name:find("legend") then
            
            local score = 0
            if name:find("emperor") or name:find("ultimate") then score = 1000
            elseif name:find("king") or name:find("legend") then score = 700
            elseif name:find("pro") or name:find("advanced") then score = 300
            else score = 100
            end
            
            if score > bestScore then
                bestScore = score
                bestBench = obj
            end
        end
    end
    return bestBench
end

-- Improved: Go to bench and sit properly
spawn(function()
    while autoTrainEnabled do
        task.wait(0.8)
        
        local bench = getBestBench()
        if bench and humanoidRootPart and humanoid then
            -- Find seat or main part
            local seat = bench:FindFirstChildWhichIsA("Seat") or bench:FindFirstChild("Seat") 
                       or bench:FindFirstChildWhichIsA("BasePart")
            
            if seat then
                -- Teleport directly on top / in front properly
                humanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(0, math.rad(180), 0)
                task.wait(0.4)
                
                -- Force sit if possible
                if seat:IsA("Seat") and not seat.Occupant then
                    humanoid.Sit = true
                    task.wait(0.2)
                    seat:Sit(humanoid)
                end
                
                -- Spam proximity prompts on the bench
                for _, prompt in pairs(bench:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt, 0)
                    end
                end
            end
        end
    end
end)

-- Super Fast Training (Remote + Prompts)
spawn(function()
    while autoTrainEnabled do
        task.wait(0.01)
        
        pcall(function()
            -- Fire main training remote
            local remotes = {"TrainEvent", "StrengthEvent", "LiftEvent", "BenchEvent", "WorkoutEvent"}
            for _, rName in ipairs(remotes) do
                local remote = replicatedStorage:FindFirstChild(rName) or replicatedStorage:FindFirstChild(rName, true)
                if remote then
                    remote:FireServer(strengthMultiplier)
                end
            end
            
            -- Extra prompt spam
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and (v.Name:lower():find("bench") or v.Name:lower():find("lift") or v.Name:lower():find("press")) then
                    fireproximityprompt(v, 0)
                end
            end
        end)
    end
end)

-- Auto Rebirth (unchanged)
spawn(function()
    while autoRebirthEnabled do
        task.wait(1)
        pcall(function()
            local rebirthRemote = replicatedStorage:FindFirstChild("RebirthEvent") 
                               or replicatedStorage:FindFirstChild("Rebirth") 
                               or replicatedStorage:FindFirstChild("RebirthRequest")
            if rebirthRemote then
                rebirthRemote:FireServer()
            end
        end)
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Muscle Masters";
    Text = "Best Bench Auto-Sit + Super Fast Train Fixed!";
    Duration = 8;
})

print("✅ Now properly sitting on the best bench!")
