-- // Muscle Masters - Super Fast Weight Lifting Script
-- Auto finds and uses the best weights / dumbbells

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

local rs = game:GetService("ReplicatedStorage")
local ws = workspace

local strengthMultiplier = 99999999

print("🔥 Muscle Masters Auto Weights Script Loaded")

-- Anti-AFK
player.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Find Best Weight / Dumbbell
local function getBestWeight()
    local best = nil
    local bestScore = 0
    
    for _, obj in pairs(ws:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("weight") or n:find("dumbbell") or n:find("barbell") or n:find("heavy") or n:find("king") or n:find("emperor") then
            local score = 0
            if n:find("emperor") or n:find("ultimate") then score = 1000
            elseif n:find("king") or n:find("legend") then score = 700
            elseif n:find("heavy") or n:find("pro") then score = 400
            else score = 100
            end
            if score > bestScore then
                bestScore = score
                best = obj
            end
        end
    end
    return best
end

-- Aggressive Weight Lifting Loop
spawn(function()
    while true do
        task.wait(0.3)
        
        local weight = getBestWeight()
        if weight then
            local targetPart = weight:FindFirstChildWhichIsA("BasePart") or weight.PrimaryPart or weight
            
            if targetPart then
                -- Teleport close to the weight
                root.CFrame = targetPart.CFrame * CFrame.new(0, 3, 2)
                task.wait(0.2)
                
                -- Spam ALL proximity prompts on the weight
                for _, prompt in pairs(weight:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt, 0)
                        task.wait(0.03)
                    end
                end
            end
        end
    end
end)

-- Insane Strength Spam
spawn(function()
    while true do
        task.wait(0.007)
        
        pcall(function()
            local remotes = {"TrainEvent", "StrengthEvent", "LiftEvent", "WeightEvent", "RepEvent", "GainStrength", "WorkoutEvent"}
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
    Title = "Muscle Masters";
    Text = "Auto Best Weights + Super Fast Gains ON 💪";
    Duration = 8;
})
