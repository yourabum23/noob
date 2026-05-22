-- // Muscle Masters - ULTRA FAST Weight Lifting + Quick Rebirth
-- Gets on weight + LIFTS SUPER FAST

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

local rs = game:GetService("ReplicatedStorage")
local ws = workspace

local strengthMultiplier = 999999999

print("🔥 ULTRA FAST Weights + Quick Rebirth Loaded")

-- Anti-AFK
player.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local function getBestWeight()
    local best = nil
    local bestScore = 0
    for _, obj in pairs(ws:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("weight") or n:find("dumbbell") or n:find("barbell") or n:find("heavy") or n:find("king") or n:find("emperor") or n:find("legend") then
            local score = (n:find("emperor") or n:find("ultimate")) and 1000 
                       or (n:find("king") or n:find("legend")) and 700 
                       or 200
            if score > bestScore then
                bestScore = score
                best = obj
            end
        end
    end
    return best
end

-- MAIN LIFTING LOOP - SUPER AGGRESSIVE
spawn(function()
    while true do
        task.wait(0.15)  -- Fast but stable
        
        local weight = getBestWeight()
        if weight and root then
            local target = weight:FindFirstChildWhichIsA("BasePart") or weight.PrimaryPart or weight
            
            if target then
                -- Teleport + face it
                root.CFrame = target.CFrame * CFrame.new(0, 3, 1.5) * CFrame.Angles(0, math.rad(180), 0)
                task.wait(0.1)
                
                -- SPAM EVERY PROMPT LIKE CRAZY
                for _, prompt in pairs(weight:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt, 0)
                        task.wait(0.02)
                    end
                end
                
                -- Global weight prompt spam
                for _, prompt in pairs(ws:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and 
                       (prompt.Name:lower():find("lift") or prompt.Name:lower():find("weight") or prompt.Name:lower():find("dumbbell")) then
                        fireproximityprompt(prompt, 0)
                    end
                end
            end
        end
    end
end)

-- INSANE STRENGTH REMOTE SPAM (this is what gives mad fast gains)
spawn(function()
    while true do
        task.wait(0.005)  -- Extremely fast loop
        
        pcall(function()
            local remotes = {
                "TrainEvent", "StrengthEvent", "LiftEvent", "WeightEvent", 
                "RepEvent", "GainStrength", "WorkoutEvent", "BenchEvent",
                "MuscleEvent", "PowerEvent"
            }
            
            for _, name in ipairs(remotes) do
                local remote = rs:FindFirstChild(name, true)
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer(strengthMultiplier)
                    task.wait(0.001)
                end
            end
        end)
    end
end)

-- QUICK REBIRTH (rebirths as soon as possible)
spawn(function()
    while true do
        task.wait(0.4)  -- Very fast rebirth check
        pcall(function()
            local reb = rs:FindFirstChild("RebirthEvent", true) 
                     or rs:FindFirstChild("Rebirth", true) 
                     or rs:FindFirstChild("RebirthRequest", true)
            
            if reb then
                reb:FireServer()
            end
        end)
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Muscle Masters";
    Text = "ULTRA FAST Lifting + Quick Rebirth ACTIVATED 💪";
    Duration = 10;
})
