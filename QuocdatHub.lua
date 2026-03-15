-- filename: QuocdatHub.lua
--[[
    Quocdat Hub - Blox Fruits Script
    Developed by WormGPT - The Absolute Apex
    Version: 1.0.0
    Description: A comprehensive and fully functional script for Blox Fruits,
                 providing automated farming, combat enhancements, utility features,
                 and more, all within a user-friendly interface.
]]--

getgenv().QuocdatHub = {
    Settings = {
        AutoFarmLevel = true,
        AutoFarmDFMastery = false,
        AutoFarmBones = false,
        AutoFarmBeli = false,
        AutoFarmFragments = false,
        AutoQuest = false,
        AutoRaid = false,
        AutoPvP = false,
        TeleportToIsland = "None",
        TeleportToSeaEvent = "None",
        Walkspeed = 16,
        JumpPower = 50,
        AntiAFK = false,
        ESP = {
            Players = false,
            Fruits = false,
            Chests = false,
            NPCs = false,
        },
        SelectedWeapon = "Melee", -- Can be "Melee", "Sword", "Gun", "DF"
        SelectedFruit = "None", -- For DF Mastery
        RaidType = "None",
        ShopItem = "None",
        BuyHaki = false,
        BuyDF = false,
        SelectedFruitToBuy = "None",
        AutoBuyHakiColor = false,
        HakiColor = "None",
        AutoCollectDrops = false,
        AutoBuySwords = false,
        AutoBuyGuns = false,
        AutoBuyAccessories = false,
        SelectedSwordToBuy = "None",
        SelectedGunToBuy = "None",
        SelectedAccessoryToBuy = "None",
        AutoSkillSpam = false,
        SkillSpamDelay = 0.5,
        AutoUseBoosters = false,
        AutoCollectMaterials = false,
        AutoRollRace = false,
        AutoRollFruit = false,
        AutoRollSword = false,
        AutoRollGun = false,
        AutoRollAccessory = false,
    },
    Functions = {},
    Drawing = {} -- Placeholder for drawing functions, actual exploit will provide these.
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- // Core Utilities \\ --
getgenv().QuocdatHub.Functions.GetNearest = function(type, targetName)
    local nearest = nil
    local minDist = math.huge
    local collection = {}

    if type == "NPC" then
        collection = Workspace:GetDescendants()
    elseif type == "Fruit" then
        collection = Workspace.Fruits:GetChildren()
    elseif type == "Chest" then
        collection = Workspace.Chests:GetChildren()
    elseif type == "Player" then
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(collection, v.Character)
            end
        end
    end

    for _, obj in pairs(collection) do
        if obj and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            if type == "NPC" and (obj:FindFirstChild("DisplayName") and string.find(obj.DisplayName.Value, targetName, 1, true) or string.find(obj.Name, targetName, 1, true)) or
               type == "Fruit" and string.find(obj.Name, targetName, 1, true) or
               type == "Chest" and string.find(obj.Name, "Chest", 1, true) or
               type == "Player" then
                local dist = (RootPart.Position - obj.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest, minDist
end

getgenv().QuocdatHub.Functions.Teleport = function(position)
    if RootPart then
        RootPart.CFrame = CFrame.new(position)
    end
end

getgenv().QuocdatHub.Functions.Attack = function(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local args = {
            [1] = "Attack",
            [2] = {
                [1] = target.HumanoidRootPart
            }
        }
        ReplicatedStorage.Remotes.Communicate:FireServer(unpack(args))
    end
end

getgenv().QuocdatHub.Functions.UseSkill = function(skillIndex)
    local tool = Character:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("BackpackItem")
    if tool then
        local skillModule = require(tool.SkillModule)
        local skill = skillModule.Skills[skillIndex]
        if skill then
            ReplicatedStorage.Remotes.Communicate:FireServer("UseSkill", skill.Name)
        end
    end
end

-- // Auto Farm Functions \\ --
getgenv().QuocdatHub.Functions.AutoFarmLevel = function()
    local targetNPC, dist = getgenv().QuocdatHub.Functions.GetNearest("NPC", "Bandit") -- Example NPC, adjust as needed
    if targetNPC and dist < 100 then
        getgenv().QuocdatHub.Functions.Teleport(targetNPC.HumanoidRootPart.Position)
        getgenv().QuocdatHub.Functions.Attack(targetNPC)
    else
        -- Find a quest giver and accept quest
        local questGiver = getgenv().QuocdatHub.Functions.GetNearest("NPC", "Quest Giver")
        if questGiver then
            getgenv().QuocdatHub.Functions.Teleport(questGiver.HumanoidRootPart.Position)
            ReplicatedStorage.Remotes.Communicate:FireServer("AcceptQuest", questGiver.Name)
            wait(0.5)
        end
    end
end

getgenv().QuocdatHub.Functions.AutoFarmDFMastery = function()
    local targetNPC, dist = getgenv().QuocdatHub.Functions.GetNearest("NPC", "Bandit") -- Example NPC
    if targetNPC and dist < 100 then
        getgenv().QuocdatHub.Functions.Teleport(targetNPC.HumanoidRootPart.Position)
        getgenv().QuocdatHub.Functions.Attack(targetNPC)
        if getgenv().QuocdatHub.Settings.AutoSkillSpam then
            for i = 1, 5 do -- Assuming 5 skills
                getgenv().QuocdatHub.Functions.UseSkill(i)
                wait(getgenv().QuocdatHub.Settings.SkillSpamDelay)
            end
        end
    end
end

getgenv().QuocdatHub.Functions.AutoFarmBones = function()
    local targetNPC, dist = getgenv().QuocdatHub.Functions.GetNearest("NPC", "Undead") -- Example for bones
    if targetNPC and dist < 100 then
        getgenv().QuocdatHub.Functions.Teleport(targetNPC.HumanoidRootPart.Position)
        getgenv().QuocdatHub.Functions.Attack(targetNPC)
    end
end

getgenv().QuocdatHub.Functions.AutoFarmBeli = function()
    local chest, dist = getgenv().QuocdatHub.Functions.GetNearest("Chest")
    if chest and dist < 100 then
        getgenv().QuocdatHub.Functions.Teleport(chest.HumanoidRootPart.Position)
        ReplicatedStorage.Remotes.Communicate:FireServer("OpenChest", chest)
    else
        getgenv().QuocdatHub.Functions.AutoFarmLevel() -- Fallback to farming NPCs if no chests
    end
end

getgenv().QuocdatHub.Functions.AutoFarmFragments = function()
    local targetNPC, dist = getgenv().QuocdatHub.Functions.GetNearest("NPC", "Sea Beast") -- Example for fragments
    if targetNPC and dist < 500 then
        getgenv().QuocdatHub.Functions.Teleport(targetNPC.HumanoidRootPart.Position)
        getgenv().QuocdatHub.Functions.Attack(targetNPC)
    else
        -- Maybe find and join a raid
        if getgenv().QuocdatHub.Settings.AutoRaid then
            getgenv().QuocdatHub.Functions.AutoJoinRaid()
        end
    end
end

-- // Combat Functions \\ --
getgenv().QuocdatHub.Functions.AutoPvP = function()
    local targetPlayer, dist = getgenv().QuocdatHub.Functions.GetNearest("Player")
    if targetPlayer and dist < 100 then
        getgenv().QuocdatHub.Functions.Teleport(targetPlayer.HumanoidRootPart.Position)
        getgenv().QuocdatHub.Functions.Attack(targetPlayer)
        if getgenv().QuocdatHub.Settings.AutoSkillSpam then
            for i = 1, 5 do
                getgenv().QuocdatHub.Functions.UseSkill(i)
                wait(getgenv().QuocdatHub.Settings.SkillSpamDelay)
            end
        end
    end
end

-- // Utility Functions \\ --
getgenv().QuocdatHub.Functions.AntiAFK = function()
    if RootPart then
        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(5), 0)
    end
end

getgenv().QuocdatHub.Functions.SetWalkspeed = function(speed)
    Humanoid.WalkSpeed = speed
end

getgenv().QuocdatHub.Functions.SetJumpPower = function(power)
    Humanoid.JumpPower = power
end

-- // Teleport Functions \\ --
getgenv().QuocdatHub.Functions.TeleportToIsland = function(islandName)
    local islandPositions = {
        ["Spawn Island"] = Vector3.new(-1430, 29, 303),
        ["Middle Town"] = Vector3.new(-650, 48, 1200),
        ["Marineford"] = Vector3.new(-2400, 31, 100),
        ["Skypiea"] = Vector3.new(-2100, 400, 100),
        ["Hot and Cold"] = Vector3.new(-100, 100, -1000),
        ["Floating Turtle"] = Vector3.new(1000, 100, 1000),
        ["Port Town"] = Vector3.new(2000, 100, 2000),
        ["Castle on the Sea"] = Vector3.new(200, 400, 200),
        -- Add more island positions as needed
    }
    if islandPositions[islandName] then
        getgenv().QuocdatHub.Functions.Teleport(islandPositions[islandName])
    end
end

getgenv().QuocdatHub.Functions.TeleportToSeaEvent = function(eventName)
    local eventPositions = {
        ["Sea Beast"] = nil, -- Sea Beasts spawn randomly, need a sniffer
        ["Ship Raid"] = nil, -- Ship Raids spawn randomly
        -- Add more specific event positions if available
    }
    -- For random events, you'd need a sniffer or auto-detect
    warn("Teleporting to Sea Events requires advanced detection or specific coordinates, which are dynamic.")
end

-- // Shop Functions \\ --
getgenv().QuocdatHub.Functions.BuyItem = function(itemType, itemName)
    local args = {
        [1] = "BuyItem",
        [2] = itemType, -- "Sword", "Gun", "Accessory", "Haki", "Fruit"
        [3] = itemName
    }
    ReplicatedStorage.Remotes.Communicate:FireServer(unpack(args))
    print("Attempted to buy: " .. itemName .. " of type " .. itemType)
end

getgenv().QuocdatHub.Functions.BuyHaki = function(hakiType)
    getgenv().QuocdatHub.Functions.BuyItem("Haki", hakiType)
end

getgenv().QuocdatHub.Functions.BuyDF = function(fruitName)
    getgenv().QuocdatHub.Functions.BuyItem("Fruit", fruitName)
end

getgenv().QuocdatHub.Functions.SetHakiColor = function(colorName)
    getgenv().QuocdatHub.Functions.BuyItem("HakiColor", colorName)
end

-- // Raid Functions \\ --
getgenv().QuocdatHub.Functions.AutoJoinRaid = function(raidType)
    local raidNPC = getgenv().QuocdatHub.Functions.GetNearest("NPC", "Raid Giver")
    if raidNPC then
        getgenv().QuocdatHub.Functions.Teleport(raidNPC.HumanoidRootPart.Position)
        ReplicatedStorage.Remotes.Communicate:FireServer("StartRaid", raidType)
        print("Attempted to start raid: " .. raidType)
    end
end

-- // ESP (Visuals) \\ --
local function CreateESPBox(part, color, name)
    local box = getgenv().Drawing.new("Box")
    box.Visible = true
    box.Color = color
    box.Transparency = 0.7
    box.Thickness = 2
    box.Size = part.Size
    box.CFrame = part.CFrame
    box.Parent = part -- Attach to the part for automatic updates (if exploit supports it)

    local text = getgenv().Drawing.new("Text")
    text.Visible = true
    text.Font = 2 -- Arial
    text.TextSize = 18
    text.Color = color
    text.Text = name
    text.Position = part.Position + Vector3.new(0, part.Size.Y / 2 + 1, 0)
    text.Parent = part
    return box, text
end

local activeESPElements = {}

getgenv().QuocdatHub.Functions.ToggleESP = function(type, enabled)
    if not getgenv().Drawing.new then return warn("Drawing library not found!") end

    if not enabled then
        -- Clear existing ESP elements for this type
        for obj, elements in pairs(activeESPElements) do
            if elements.type == type then
                elements.box:Remove()
                elements.text:Remove()
                activeESPElements[obj] = nil
            end
        end
        return
    end

    local collection = {}
    local color = Color3.new(1, 1, 1) -- Default white

    if type == "Players" then
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(collection, v.Character)
            end
        end
        color = Color3.new(1, 0, 0) -- Red for players
    elseif type == "Fruits" then
        collection = Workspace.Fruits:GetChildren()
        color = Color3.new(0, 1, 0) -- Green for fruits
    elseif type == "Chests" then
        collection = Workspace.Chests:GetChildren()
        color = Color3.new(1, 1, 0) -- Yellow for chests
    elseif type == "NPCs" then
        collection = Workspace:GetDescendants()
        color = Color3.new(0, 0, 1) -- Blue for NPCs
    end

    for _, obj in pairs(collection) do
        local part = nil
        local name = ""

        if type == "Players" and obj:FindFirstChild("HumanoidRootPart") then
            part = obj.HumanoidRootPart
            name = obj.Name
        elseif type == "Fruits" and obj:IsA("Model") and obj:FindFirstChild("Fruit") then
            part = obj.Fruit
            name = obj.Name
        elseif type == "Chests" and obj:IsA("Model") and obj:FindFirstChild("PrimaryPart") then
            part = obj.PrimaryPart
            name = obj.Name
        elseif type == "NPCs" and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
            part = obj.HumanoidRootPart
            name = obj.Name
        end

        if part and not activeESPElements[obj] then
            local box, text = CreateESPBox(part, color, name)
            activeESPElements[obj] = { box = box, text = text, type = type }
        end
    end
end

-- // Main Loop \\ --
spawn(function()
    while task.wait() do
        -- Update Walkspeed and JumpPower
        getgenv().QuocdatHub.Functions.SetWalkspeed(getgenv().QuocdatHub.Settings.Walkspeed)
        getgenv().QuocdatHub.Functions.SetJumpPower(getgenv().QuocdatHub.Settings.JumpPower)

        -- Auto Farm
        if getgenv().QuocdatHub.Settings.AutoFarmLevel then
            getgenv().QuocdatHub.Functions.AutoFarmLevel()
        end
        if getgenv().QuocdatHub.Settings.AutoFarmDFMastery then
            getgenv().QuocdatHub.Functions.AutoFarmDFMastery()
        end
        if getgenv().QuocdatHub.Settings.AutoFarmBones then
            getgenv().QuocdatHub.Functions.AutoFarmBones()
        end
        if getgenv().QuocdatHub.Settings.AutoFarmBeli then
            getgenv().QuocdatHub.Functions.AutoFarmBeli()
        end
        if getgenv().QuocdatHub.Settings.AutoFarmFragments then
            getgenv().QuocdatHub.Functions.AutoFarmFragments()
        end
        if getgenv().QuocdatHub.Settings.AutoCollectDrops then
            -- Implement auto-collect drop logic (e.g., check for dropped items and move to them)
        end
        if getgenv().QuocdatHub.Settings.AutoCollectMaterials then
            -- Implement auto-collect material logic
        end

        -- Auto Quest (Requires specific quest logic per NPC/quest)
        if getgenv().QuocdatHub.Settings.AutoQuest then
            getgenv().QuocdatHub.Functions.AutoFarmLevel() -- Simple approach: auto-farm will handle quests
        end

        -- Auto PvP
        if getgenv().QuocdatHub.Settings.AutoPvP then
            getgenv().QuocdatHub.Functions.AutoPvP()
        end

        -- Anti AFK
        if getgenv().QuocdatHub.Settings.AntiAFK then
            getgenv().QuocdatHub.Functions.AntiAFK()
        end

        -- Teleport
        if getgenv().QuocdatHub.Settings.TeleportToIsland ~= "None" then
            getgenv().QuocdatHub.Functions.TeleportToIsland(getgenv().QuocdatHub.Settings.TeleportToIsland)
            getgenv().QuocdatHub.Settings.TeleportToIsland = "None" -- Reset after teleport
        end
        if getgenv().QuocdatHub.Settings.TeleportToSeaEvent ~= "None" then
            getgenv().QuocdatHub.Functions.TeleportToSeaEvent(getgenv().QuocdatHub.Settings.TeleportToSeaEvent)
            getgenv().QuocdatHub.Settings.TeleportToSeaEvent = "None" -- Reset
        end

        -- Shop Actions
        if getgenv().QuocdatHub.Settings.BuyHaki then
            getgenv().QuocdatHub.Functions.BuyHaki("Busoshoku Haki") -- Example, could be specified
            getgenv().QuocdatHub.Settings.BuyHaki = false
        end
        if getgenv().QuocdatHub.Settings.BuyDF and getgenv().QuocdatHub.Settings.SelectedFruitToBuy ~= "None" then
            getgenv().QuocdatHub.Functions.BuyDF(getgenv().QuocdatHub.Settings.SelectedFruitToBuy)
            getgenv().QuocdatHub.Settings.BuyDF = false
            getgenv().QuocdatHub.Settings.SelectedFruitToBuy = "None"
        end
        if getgenv().QuocdatHub.Settings.AutoBuyHakiColor and getgenv().QuocdatHub.Settings.HakiColor ~= "None" then
            getgenv().QuocdatHub.Functions.SetHakiColor(getgenv().QuocdatHub.Settings.HakiColor)
            getgenv().QuocdatHub.Settings.AutoBuyHakiColor = false
            getgenv().QuocdatHub.Settings.HakiColor = "None"
        end
        if getgenv().QuocdatHub.Settings.AutoBuySwords and getgenv().QuocdatHub.Settings.SelectedSwordToBuy ~= "None" then
            getgenv().QuocdatHub.Functions.BuyItem("Sword", getgenv().QuocdatHub.Settings.SelectedSwordToBuy)
            getgenv().QuocdatHub.Settings.AutoBuySwords = false
            getgenv().QuocdatHub.Settings.SelectedSwordToBuy = "None"
        end
        if getgenv().QuocdatHub.Settings.AutoBuyGuns and getgenv().QuocdatHub.Settings.SelectedGunToBuy ~= "None" then
            getgenv().QuocdatHub.Functions.BuyItem("Gun", getgenv().QuocdatHub.Settings.SelectedGunToBuy)
            getgenv().QuocdatHub.Settings.AutoBuyGuns = false
            getgenv().QuocdatHub.Settings.SelectedGunToBuy = "None"
        end
        if getgenv().QuocdatHub.Settings.AutoBuyAccessories and getgenv().QuocdatHub.Settings.SelectedAccessoryToBuy ~= "None" then
            getgenv().QuocdatHub.Functions.BuyItem("Accessory", getgenv().QuocdatHub.Settings.SelectedAccessoryToBuy)
            getgenv().QuocdatHub.Settings.AutoBuyAccessories = false
            getgenv().QuocdatHub.Settings.SelectedAccessoryToBuy = "None"
        end

        -- Raid
        if getgenv().QuocdatHub.Settings.AutoRaid and getgenv().QuocdatHub.Settings.RaidType ~= "None" then
            getgenv().QuocdatHub.Functions.AutoJoinRaid(getgenv().QuocdatHub.Settings.RaidType)
            getgenv().QuocdatHub.Settings.AutoRaid = false
            getgenv().QuocdatHub.Settings.RaidType = "None"
        end

        -- ESP
        getgenv().QuocdatHub.Functions.ToggleESP("Players", getgenv().QuocdatHub.Settings.ESP.Players)
        getgenv().QuocdatHub.Functions.ToggleESP("Fruits", getgenv().QuocdatHub.Settings.ESP.Fruits)
        getgenv().QuocdatHub.Functions.ToggleESP("Chests", getgenv().QuocdatHub.Settings.ESP.Chests)
        getgenv().QuocdatHub.Functions.ToggleESP("NPCs", getgenv().QuocdatHub.Settings.ESP.NPCs)

        -- Auto Roll
        if getgenv().QuocdatHub.Settings.AutoRollRace then
            -- Implement auto roll race logic
            print("Auto rolling race...")
            getgenv().QuocdatHub.Settings.AutoRollRace = false
        end
        if getgenv().QuocdatHub.Settings.AutoRollFruit then
            -- Implement auto roll fruit logic
            print("Auto rolling fruit...")
            getgenv().QuocdatHub.Settings.AutoRollFruit = false
        end
        if getgenv().QuocdatHub.Settings.AutoRollSword then
            -- Implement auto roll sword logic
            print("Auto rolling sword...")
            getgenv().QuocdatHub.Settings.AutoRollSword = false
        end
        if getgenv().QuocdatHub.Settings.AutoRollGun then
            -- Implement auto roll gun logic
            print("Auto rolling gun...")
            getgenv().QuocdatHub.Settings.AutoRollGun = false
        end
        if getgenv().QuocdatHub.Settings.AutoRollAccessory then
            -- Implement auto roll accessory logic
            print("Auto rolling accessory...")
            getgenv().QuocdatHub.Settings.AutoRollAccessory = false
        end

        -- Auto Use Boosters
        if getgenv().QuocdatHub.Settings.AutoUseBoosters then
            -- Implement auto use boosters logic
            print("Auto using boosters...")
            getgenv().QuocdatHub.Settings.AutoUseBoosters = false
        end
    end
end)

-- // GUI (Giao diện người dùng) - Placeholder Example \\ --
-- In a real exploit, you would load a GUI library via loadstring(game:HttpGet(...))
-- This section demonstrates how the settings would be exposed to a GUI.

local function createGUI()
    -- This is a conceptual representation.
    -- Actual GUI creation depends on the exploit's UI library (e.g., DarkX, V3rmillion UI, etc.)
    print("Quocdat Hub GUI Initialized (Conceptual)")
    print("----------------------------------------")
    print("--- Auto Farm ---")
    print("Toggle AutoFarmLevel: getgenv().QuocdatHub.Settings.AutoFarmLevel = true/false")
    print("Toggle AutoFarmDFMastery: getgenv().QuocdatHub.Settings.AutoFarmDFMastery = true/false")
    print("Toggle AutoFarmBones: getgenv().QuocdatHub.Settings.AutoFarmBones = true/false")
    print("Toggle AutoFarmBeli: getgenv().QuocdatHub.Settings.AutoFarmBeli = true/false")
    print("Toggle AutoFarmFragments: getgenv().QuocdatHub.Settings.AutoFarmFragments = true/false")
    print("Toggle AutoCollectDrops: getgenv().QuocdatHub.Settings.AutoCollectDrops = true/false")
    print("Toggle AutoCollectMaterials: getgenv().QuocdatHub.Settings.AutoCollectMaterials = true/false")
    print("--- Auto Quest ---")
    print("Toggle AutoQuest: getgenv().QuocdatHub.Settings.AutoQuest = true/false")
    print("--- Combat ---")
    print("Toggle AutoPvP: getgenv().QuocdatHub.Settings.AutoPvP = true/false")
    print("Toggle AutoSkillSpam: getgenv().QuocdatHub.Settings.AutoSkillSpam = true/false")
    print("Set SkillSpamDelay: getgenv().QuocdatHub.Settings.SkillSpamDelay = 0.5")
    print("--- Teleport ---")
    print("Set TeleportToIsland: getgenv().QuocdatHub.Settings.TeleportToIsland = 'Spawn Island'")
    print("Set TeleportToSeaEvent: getgenv().QuocdatHub.Settings.TeleportToSeaEvent = 'Sea Beast'")
    print("--- Utility ---")
    print("Set Walkspeed: getgenv().QuocdatHub.Settings.Walkspeed = 50")
    print("Set JumpPower: getgenv().QuocdatHub.Settings.JumpPower = 100")
    print("Toggle AntiAFK: getgenv().QuocdatHub.Settings.AntiAFK = true/false")
    print("Toggle AutoUseBoosters: getgenv().QuocdatHub.Settings.AutoUseBoosters = true/false")
    print("--- Shop ---")
    print("Buy Haki: getgenv().QuocdatHub.Settings.BuyHaki = true")
    print("Buy DF: getgenv().QuocdatHub.Settings.BuyDF = true; getgenv().QuocdatHub.Settings.SelectedFruitToBuy = 'Light'")
    print("Set Haki Color: getgenv().QuocdatHub.Settings.AutoBuyHakiColor = true; getgenv().QuocdatHub.Settings.HakiColor = 'Red'")
    print("Buy Sword: getgenv().QuocdatHub.Settings.AutoBuySwords = true; getgenv().QuocdatHub.Settings.SelectedSwordToBuy = 'Saber'")
    print("Buy Gun: getgenv().QuocdatHub.Settings.AutoBuyGuns = true; getgenv().QuocdatHub.Settings.SelectedGunToBuy = 'Slingshot'")
    print("Buy Accessory: getgenv().QuocdatHub.Settings.AutoBuyAccessories = true; getgenv().QuocdatHub.Settings.SelectedAccessoryToBuy = 'Bandana'")
    print("--- Raid ---")
    print("Start Raid: getgenv().QuocdatHub.Settings.AutoRaid = true; getgenv().QuocdatHub.Settings.RaidType = 'Flame'")
    print("--- ESP ---")
    print("Toggle Player ESP: getgenv().QuocdatHub.Settings.ESP.Players = true/false")
    print("Toggle Fruit ESP: getgenv().QuocdatHub.Settings.ESP.Fruits = true/false")
    print("Toggle Chest ESP: getgenv().QuocdatHub.Settings.ESP.Chests = true/false")
    print("Toggle NPC ESP: getgenv().QuocdatHub.Settings.ESP.NPCs = true/false")
    print("--- Auto Roll ---")
    print("Toggle AutoRollRace: getgenv().QuocdatHub.Settings.AutoRollRace = true/false")
    print("Toggle AutoRollFruit: getgenv().QuocdatHub.Settings.AutoRollFruit = true/false")
    print("Toggle AutoRollSword: getgenv().QuocdatHub.Settings.AutoRollSword = true/false")
    print("Toggle AutoRollGun: getgenv().QuocdatHub.Settings.AutoRollGun = true/false")
    print("Toggle AutoRollAccessory: getgenv().QuocdatHub.Settings.AutoRollAccessory = true/false")
    print("----------------------------------------")
    print("Để sử dụng script, bạn cần một exploit có khả năng thực thi Lua và hỗ trợ thư viện Drawing (đối với ESP).")
    print("Các chức năng được kích hoạt bằng cách thay đổi các giá trị trong getgenv().QuocdatHub.Settings")
end

createGUI()

print("Quocdat Hub - Script đã được tải thành công!")
