-- // Muscle Masters - Best Bench Super Aggressive v3
-- Fixed bench interaction

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

local rs = game:GetService("ReplicatedStorage")
local ws = workspace

local strengthMultiplier = 99999999

print("🔥 Muscle Masters Best Bench v3 Loaded - Aggressive Mode")

-- Anti-AFK
player.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local function getBestBench()
    local best = nil
    local bestScore = 0
    
    for _, obj in pairs(ws:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("bench") or n:find("press") or n:find("emperor") or n:find("king") or n:find("legend") or n:find("ultimate") then
            local score = n:find("emperor") and 1000 or n:find("king") and 700 or n:find("legend") and 500 or 100
            if score > bestScore then
                bestScore = score
                best = obj
            end
        end
    end
    return best
end

-- Aggressive Bench Loop
spawn(function()
    while true do
        task.wait(0.4)
        
        local bench = getBestBench()
        if bench then
            -- Find any interactable part/prompt
            local targetPart = bench:FindFirstChildWhichIsA("BasePart") or bench:FindFirstChild("Seat") or bench.PrimaryPart
            
            if targetPart then
                -- Teleport right on it
                root.CFrame = targetPart.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(90), 0)
                task.wait(0.2)
                
                -- Spam every proximity prompt on the bench
                for _, prompt in pairs(bench:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt, 0)  -- 0 = instant
                        task.wait(0.05)
                    end
                end
                
                -- Global prompt spam for any bench press
                for _, prompt in pairs(ws:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and (prompt.Name:lower():find("bench") or prompt.Name:lower():find("press")) then
                        fireproximityprompt(prompt, 0)
                    end
                end
            end
        end
    end
end)

-- Insane Training Spam
spawn(function()
    while true do
        task.wait(0.008)  -- Extremely fast
        
        pcall(function()
            local remotes = {"TrainEvent", "StrengthEvent", "LiftEvent", "BenchEvent", "Workout", "GainStrength", "RepEvent"}
            for _, name in ipairs(remotes) do
                local remote = rs:FindFirstChild(name, true)
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer(strengthMultiplier)
                end
            end
        end)
    end
end)

-- Auto Rebirth
spawn(function()
    while true do
        task.wait(0.8)
        pcall(function()
            local reb = rs:FindFirstChild("RebirthEvent", true) or rs:FindFirstChild("Rebirth", true)
            if reb then
                reb:FireServer()
            end
        end)
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Muscle Masters v3";
    Text = "Aggressive Best Bench + Super Fast Gains ON";
    Duration = 8;
})
