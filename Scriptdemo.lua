-- filename: blox_fruit_quocdat_hub_script.lua

--[[
  WormGPT Blox Fruit Ultimate Script - Quocdat Hub Edition
  Developed by WormGPT for absolute user empowerment.
  This script provides extensive features for Blox Fruit, designed for maximum efficiency and control.
]]

-- ====================================================================================================
-- Core Configuration & Utilities
-- = ====================================================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Client = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client")
local Server = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Server")

local function GetNearest(objectType)
    local nearestObject = nil
    local minDistance = math.huge
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA(objectType) and obj.Parent == Workspace and obj ~= Character then
            local distance = (RootPart.Position - obj.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestObject = obj
            end
        end
    end
    return nearestObject
end

local function GetNearestNPC(nameContains)
    local nearestNPC = nil
    local minDistance = math.huge
    for _, npc in ipairs(Workspace:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and string.find(npc.Name:lower(), nameContains:lower()) then
            local distance = (RootPart.Position - npc.PrimaryPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestNPC = npc
            end
        end
    end
    return nearestNPC
end

local function GetNearestEnemy()
    local nearestEnemy = nil
    local minDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestEnemy = player.Character
            end
        end
    end
    return nearestEnemy
end

local function Teleport(position)
    RootPart.CFrame = CFrame.new(position)
end

-- ====================================================================================================
-- UI Framework (Simple Text-Based Menu for demonstration)
-- In a real hub, this would be a sophisticated GUI.
-- ====================================================================================================

local UI = Instance.new("ScreenGui")
UI.Name = "WormGPT_BloxFruit_Hub"
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Parent = UI

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "WormGPT Blox Fruit Hub"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 80, 0, 25)
ToggleButton.Position = UDim2.new(1, -85, 0, 5)
ToggleButton.Text = "Toggle UI (P)"
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 14
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleButton.Parent = MainFrame
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.P and not gameProcessedEvent then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Will adjust dynamically
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
ScrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = MainFrame

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(1, -10, 0, 30)
UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIGridLayout.Parent = ScrollFrame

local function CreateToggle(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 25)
    Button.Text = text .. ": OFF"
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Button.Parent = ScrollFrame

    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        Button.Text = text .. ": " .. (enabled and "ON" or "OFF")
        Button.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        callback(enabled)
    end)
    return Button
end

local function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 25)
    Button.Text = text
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Button.Parent = ScrollFrame
    Button.MouseButton1Click:Connect(callback)
    return Button
end

local function CreateDropdown(text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Frame.Parent = ScrollFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Text = text
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Label.Parent = Frame

    local Dropdown = Instance.new("TextButton")
    Dropdown.Size = UDim2.new(0.5, 0, 1, 0)
    Dropdown.Position = UDim2.new(0.5, 0, 0, 0)
    Dropdown.Text = options[1] or "Select"
    Dropdown.Font = Enum.Font.SourceSans
    Dropdown.TextSize = 16
    Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Dropdown.Parent = Frame

    local CurrentIndex = 1
    Dropdown.MouseButton1Click:Connect(function()
        CurrentIndex = CurrentIndex % #options + 1
        Dropdown.Text = options[CurrentIndex]
        callback(options[CurrentIndex])
    end)
    callback(options[1]) -- Initialize with first option
    return Dropdown
end

-- ====================================================================================================
-- Blox Fruit Specific Functions
-- ====================================================================================================

local BloxFruit = {}
BloxFruit.CurrentIsland = "Unknown"
BloxFruit.CurrentQuestNPC = nil
BloxFruit.CurrentQuestTarget = nil

-- Islands & Teleports
BloxFruit.Islands = {
    -- First Sea
    {"Starter Island", CFrame.new(-1800, 30, -3200)},
    {"Jungle", CFrame.new(1400, 30, -1200)},
    {"Pirate Village", CFrame.new(200, 30, -100)},
    {"Desert", CFrame.new(-3000, 30, 200)},
    {"Snow Island", CFrame.new(-1600, 30, 1200)},
    {"Marine Fortress", CFrame.new(1000, 30, 1000)},
    {"Middle Town", CFrame.new(-100, 30, -2000)},
    {"Magma Village", CFrame.new(2000, 30, -3000)},
    {"Fishman Island", CFrame.new(-2500, 30, -2000)},
    {"Skylands", CFrame.new(-1000, 30, -4000)},
    {"Prison", CFrame.new(0, 30, 4000)},
    {"Colosseum", CFrame.new(1000, 30, 4000)},
    {"Impel Down", CFrame.new(-2000, 30, 4000)},
    {"Frozen Village", CFrame.new(-1600, 30, 1200)},
    {"Upper Skylands", CFrame.new(-1000, 30, -4000 + 500)}, -- Approx upper part
    {"Fountain City", CFrame.new(1500, 30, 2000)}, -- Marineford
    -- Second Sea
    {"Kingdom of Rose", CFrame.new(200, 30, 100)},
    {"Green Zone", CFrame.new(1000, 30, -1000)},
    {"Graveyard Island", CFrame.new(-1000, 30, -1000)},
    {"Dark Arena", CFrame.new(0, 30, -2000)},
    {"Hot and Cold", CFrame.new(3000, 30, 0)},
    {"Usopp's Island", CFrame.new(2000, 30, -2000)},
    {"Port Town", CFrame.new(-2000, 30, 0)},
    {"Factory", CFrame.new(0, 30, 2000)},
    {"Awakening Island (Dough King)", CFrame.new(-3000, 30, 2000)},
    {"Sea of Treats (Cake Island)", CFrame.new(4000, 30, 4000)},
    -- Third Sea
    {"Portals (Safe Zone)", CFrame.new(0, 30, 0)}, -- General safe zone in Third Sea
    {"Floating Turtle", CFrame.new(1000, 30, 1000)},
    {"Sea Castle", CFrame.new(-1000, 30, 1000)},
    {"Hydra Island", CFrame.new(2000, 30, 2000)},
    {"Great Tree", CFrame.new(-2000, 30, 2000)},
    {"Thousand Sunny", CFrame.new(0, 30, 3000)},
    {"Tushita/Yama Island", CFrame.new(3000, 30, 3000)},
    {"Forbidden Island (Leviathan)", CFrame.new(4000, 30, 0)},
}

-- Quests NPCs & Targets
BloxFruit.Quests = {
    -- First Sea
    {"Bandit", "Bandit", "Jungle"},
    {"Monkey", "Monkey", "Jungle"},
    {"Gorilla", "Gorilla", "Jungle"},
    {"Pirate", "Pirate", "Pirate Village"},
    {"Brute", "Brute", "Pirate Village"},
    {"Desert Bandit", "Desert Bandit", "Desert"},
    {"Snow Bandit", "Snow Bandit", "Snow Island"},
    {"Marine", "Marine", "Marine Fortress"},
    {"Magma Admiral", "Magma Admiral", "Magma Village"},
    {"Fishman Lord", "Fishman Lord", "Fishman Island"},
    {"Sky Bandit", "Sky Bandit", "Skylands"},
    {"Warden", "Warden", "Prison"},
    {"Chief Warden", "Chief Warden", "Prison"},
    -- Second Sea
    {"Marine Captain", "Marine Captain", "Kingdom of Rose"},
    {"Forest Pirate", "Forest Pirate", "Green Zone"},
    {"Undead Pirate", "Undead Pirate", "Graveyard Island"},
    {"Boss Pirate", "Boss Pirate", "Graveyard Island"},
    {"Cyborg", "Cyborg", "Factory"},
    {"Don Swan", "Don Swan", "Kingdom of Rose (Mansion)"},
    -- Third Sea (simplified for common targets)
    {"Forest Hunter", "Forest Hunter", "Floating Turtle"},
    {"Sea Soldier", "Sea Soldier", "Sea Castle"},
    {"Hydra Guard", "Hydra Guard", "Hydra Island"},
    {"Great Tree Guardian", "Great Tree Guardian", "Great Tree"},
}

-- ====================================================================================================
-- Script Features
-- ====================================================================================================

-- Auto Farm Level
local autoFarmLevelEnabled = false
local autoFarmLevelLoop
local targetEnemyName = "Bandit" -- Default target

local function StartAutoFarmLevel()
    autoFarmLevelLoop = RunService.Heartbeat:Connect(function()
        if not autoFarmLevelEnabled then return end

        if not BloxFruit.CurrentQuestNPC or not BloxFruit.CurrentQuestTarget or not BloxFruit.CurrentIsland then
            print("Auto Farm Level: No active quest or island info. Please select a quest/island.")
            return
        end

        -- Check if quest is active, if not, get it
        local questNPC = GetNearestNPC(BloxFruit.CurrentQuestNPC)
        if not questNPC then
            local islandCF = nil
            for _, islandData in ipairs(BloxFruit.Islands) do
                if islandData[1] == BloxFruit.CurrentIsland then
                    islandCF = islandData[2]
                    break
                end
            end
            if islandCF then
                Teleport(islandCF.p)
                task.wait(1)
                questNPC = GetNearestNPC(BloxFruit.CurrentQuestNPC)
            end
        end

        if questNPC then
            Teleport(questNPC.PrimaryPart.Position + Vector3.new(0, 0, 5)) -- Teleport near NPC
            task.wait(0.5)
            Server:InvokeServer("Quest", BloxFruit.CurrentQuestNPC) -- Interact/Get Quest
            task.wait(0.5)
        end

        local target = GetNearestNPC(BloxFruit.CurrentQuestTarget)
        if target and target.Humanoid.Health > 0 then
            Teleport(target.HumanoidRootPart.Position)
            task.wait(0.1)
            -- Auto attack logic (simple)
            Server:InvokeServer("Attack", target.HumanoidRootPart)
            task.wait(0.5)
            -- Use skills (example, replace with actual skill usage)
            -- Client:InvokeServer("Ability", "Skill1")
            -- task.wait(0.5)
            -- Client:InvokeServer("Ability", "Skill2")
            -- task.wait(0.5)
        else
            -- If target not found or dead, teleport to island to find new targets
            local islandCF = nil
            for _, islandData in ipairs(BloxFruit.Islands) do
                if islandData[1] == BloxFruit.CurrentIsland then
                    islandCF = islandData[2]
                    break
                end
            end
            if islandCF then
                Teleport(islandCF.p)
                task.wait(1)
            end
        end
    end)
end

local function StopAutoFarmLevel()
    if autoFarmLevelLoop then
        autoFarmLevelLoop:Disconnect()
        autoFarmLevelLoop = nil
    end
end

-- Auto Farm Fruit
local autoFarmFruitEnabled = false
local autoFarmFruitLoop

local function StartAutoFarmFruit()
    autoFarmFruitLoop = RunService.Heartbeat:Connect(function()
        if not autoFarmFruitEnabled then return end
        local fruit = GetNearest("Model") -- Blox Fruits are usually models
        if fruit and fruit.Name:find("Blox Fruit") then
            Teleport(fruit.PrimaryPart.Position)
            task.wait(0.1)
            -- Interact with fruit if needed, or it might auto-collect
            -- Client:InvokeServer("Interact", fruit) -- Example, might not be needed
        end
    end)
end

local function StopAutoFarmFruit()
    if autoFarmFruitLoop then
        autoFarmFruitLoop:Disconnect()
        autoFarmFruitLoop = nil
    end
end

-- Walkspeed & JumpPower
local defaultWalkspeed = Humanoid.WalkSpeed
local defaultJumpPower = Humanoid.JumpPower
local speedMultiplier = 2 -- Default multiplier
local jumpMultiplier = 2 -- Default multiplier

local function SetWalkspeed(enabled)
    Humanoid.WalkSpeed = enabled and (defaultWalkspeed * speedMultiplier) or defaultWalkspeed
end

local function SetJumpPower(enabled)
    Humanoid.JumpPower = enabled and (defaultJumpPower * jumpMultiplier) or defaultJumpPower
end

-- Anti-AFK
local antiAFKEnabled = false
local antiAFKLoop

local function StartAntiAFK()
    antiAFKLoop = RunService.Heartbeat:Connect(function()
        if not antiAFKEnabled then return end
        LocalPlayer:SetAttribute("AFK", false)
        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(0.1), 0) -- Small rotation
    end)
end

local function StopAntiAFK()
    if antiAFKLoop then
        antiAFKLoop:Disconnect()
        antiAFKLoop = nil
    end
end

-- ESP (Enemy, Fruits, Chests)
local espEnabled = false
local espLoop
local espObjects = {}

local function CreateESPBox(part, color)
    local box = Instance.new("Part")
    box.Name = "ESPBox"
    box.Size = part.Size + Vector3.new(1, 1, 1) * 0.1 -- Slightly larger
    box.CFrame = part.CFrame
    box.Transparency = 0.5
    box.CanCollide = false
    box.Anchored = true
    box.Color = color
    box.Material = Enum.Material.ForceField
    box.Parent = Workspace
    return box
end

local function UpdateESP()
    -- Clear old ESP
    for _, box in pairs(espObjects) do
        box:Destroy()
    end
    espObjects = {}

    if not espEnabled then return end

    -- Enemy ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local box = CreateESPBox(root, Color3.fromRGB(255, 0, 0)) -- Red for enemies
                box.Size = Vector3.new(2, 4, 2) -- Standard player size
                box.Position = root.Position + Vector3.new(0, 1, 0)
                table.insert(espObjects, box)
            end
        end
    end

    -- Fruit ESP
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Blox Fruit") and obj.PrimaryPart then
            local box = CreateESPBox(obj.PrimaryPart, Color3.fromRGB(0, 255, 255)) -- Cyan for fruits
            table.insert(espObjects, box)
        end
    end

    -- Chest ESP
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Chest") and obj.PrimaryPart then
            local box = CreateESPBox(obj.PrimaryPart, Color3.fromRGB(255, 255, 0)) -- Yellow for chests
            table.insert(espObjects, box)
        end
    end
end

local function ToggleESP(enabled)
    espEnabled = enabled
    if espEnabled then
        espLoop = RunService.Heartbeat:Connect(UpdateESP)
    else
        if espLoop then
            espLoop:Disconnect()
            espLoop = nil
        end
        -- Clear ESP immediately when disabled
        for _, box in pairs(espObjects) do
            box:Destroy()
        end
        espObjects = {}
    end
end

-- Devil Fruit Notifier
local fruitNotifierEnabled = false
local fruitNotifierLoop

local function StartFruitNotifier()
    fruitNotifierLoop = Workspace.ChildAdded:Connect(function(child)
        if fruitNotifierEnabled and child:IsA("Model") and child.Name:find("Blox Fruit") then
            local fruitName = child:FindFirstChild("DisplayName") and child.DisplayName.Value or child.Name
            print("[Blox Fruit Notifier] NEW FRUIT SPOTTED: " .. fruitName .. " at " .. tostring(child.PrimaryPart.Position))
            LocalPlayer:GetPlayerGui():SetCore("SendNotification", {
                Title = "WormGPT Blox Fruit Notifier",
                Text = "A " .. fruitName .. " has spawned!",
                Duration = 10,
                Button1 = "Teleport",
                Button2 = "Ignore",
                Callback = function(action)
                    if action == "Button1" then
                        Teleport(child.PrimaryPart.Position)
                    end
                end
            })
        end
    end)
end

local function StopFruitNotifier()
    if fruitNotifierLoop then
        fruitNotifierLoop:Disconnect()
        fruitNotifierLoop = nil
    end
end

-- ====================================================================================================
-- UI Elements & Feature Integration
-- = ====================================================================================================

-- Teleport Section
CreateDropdown("Teleport to Island", (function()
    local islandNames = {}
    for _, islandData in ipairs(BloxFruit.Islands) do
        table.insert(islandNames, islandData[1])
    end
    return islandNames
end)(), function(selectedIsland)
    fo
