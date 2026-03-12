loadstring(game:HttpGet(("https://raw.githubusercontent.com/daucobonhi/Ui-Redz-V2/refs/heads/main/UiREDzV2.lua")))()

-- Load Redz Hub SILENT ngay từ đầu (ẩn UI hoàn toàn)
getgenv().Hide_UI = true
getgenv().NoGUI = true
getgenv().SilentMode = true
getgenv().BackgroundRun = true
loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Quoc Dat Hub",
    Text = "Redz Hub đã load SILENT! UI Redz bị ẩn 100%\nGiờ control hết qua Quoc Dat Hub 🔥",
    Duration = 8
})

local Window = MakeWindow({
    Hub = {
        Title = "Quoc Dat Hub",           -- Giữ tên nhưng nội dung giống Redz
        Animation = "ngdaiquocdat | Redz Style 2026"
    },
    Key = {
        KeySystem = true,
        Title = "Premium Key System",
        Description = "Nhập key để mở Redz Style Hub",
        KeyLink = "https://pastebin.com/raw/ABC123DEF",
        Keys = {"quocdatpro123", "ngdaiquocdatVIP", "redzhub2026"},
        Notifi = {
            Notifications = true,
            CorrectKey = "Key đúng! Redz Style loaded 🔥",
            Incorrectkey = "Key sai bro ơi 😤",
            CopyKeyLink = "Copy link lấy key!"
        }
    }
})

MinimizeButton({
    Image = "http://www.roblox.com/asset/?id=83190276951914",
    Size = {60, 60},
    Color = Color3.fromRGB(15, 15, 25),
    Corner = true,
    Stroke = true,
    StrokeColor = Color3.fromRGB(0, 255, 150)
})

-- ==================== TAB FARM (giống Redz Hub 100%) ====================
local TabFarm = MakeTab({Name = "Farm"})

AddButton(TabFarm, {Name = "Auto Farm Level", Callback = function() getgenv().AutoFarm = true getgenv().AutoFarmLevel = true end})
AddButton(TabFarm, {Name = "Auto Quest", Callback = function() getgenv().AutoQuest = true end})
AddButton(TabFarm, {Name = "Auto Mastery", Callback = function() getgenv().AutoMastery = true end})
AddButton(TabFarm, {Name = "Auto Bone Farm", Callback = function() getgenv().AutoBone = true end})
AddButton(TabFarm, {Name = "Auto Boss Farm", Callback = function() getgenv().AutoBoss = true end})
AddButton(TabFarm, {Name = "Auto Sea Event", Callback = function() getgenv().AutoSeaEvent = true end})

-- ==================== TAB TELEPORT (giống Redz) ====================
local TabTeleport = MakeTab({Name = "Teleport"})

AddButton(TabTeleport, {Name = "Teleport to Starter Island", Callback = function() getgenv().Teleport = "Starter" end})
AddButton(TabTeleport, {Name = "Teleport to Pirate Island", Callback = function() getgenv().Teleport = "Pirate" end})
AddButton(TabTeleport, {Name = "Teleport to Desert", Callback = function() getgenv().Teleport = "Desert" end})
AddButton(TabTeleport, {Name = "Teleport to Colosseum", Callback = function() getgenv().Teleport = "Colosseum" end})
AddButton(TabTeleport, {Name = "Teleport to Cake Island", Callback = function() getgenv().Teleport = "Cake" end})

-- ==================== TAB ESP (giống Redz) ====================
local TabESP = MakeTab({Name = "ESP"})

AddButton(TabESP, {Name = "ESP Player", Callback = function() getgenv().ESP = true end})
AddButton(TabESP, {Name = "ESP Chest", Callback = function() getgenv().ChestESP = true end})
AddButton(TabESP, {Name = "ESP Island", Callback = function() getgenv().IslandESP = true end})
AddButton(TabESP, {Name = "ESP Fruit", Callback = function() getgenv().FruitESP = true end})

-- ==================== TAB RAID (giống Redz) ====================
local TabRaid = MakeTab({Name = "Raid"})

AddButton(TabRaid, {Name = "Auto Raid", Callback = function() getgenv().AutoRaid = true end})
AddButton(TabRaid, {Name = "Auto Awakened Raid", Callback = function() getgenv().AutoAwakenedRaid = true end})

-- ==================== TAB MISC (giống Redz) ====================
local TabMisc = MakeTab({Name = "Misc"})

AddButton(TabMisc, {Name = "FPS Boost", Callback = function() setfpscap(999) end})
AddButton(TabMisc, {Name = "Anti AFK", Callback = function() getgenv().AntiAFK = true end})
AddButton(TabMisc, {Name = "Join Pirates", Callback = function() getgenv().JoinTeam = "Pirates" end})
AddButton(TabMisc, {Name = "Join Marines", Callback = function() getgenv().JoinTeam = "Marines" end})

-- Button tắt tất cả (nếu cần)
AddButton(MakeTab({Name = "Settings"}), {
    Name = "TẮT TẤT CẢ AUTO",
    Callback = function()
        getgenv().AutoFarm = false
        getgenv().AutoQuest = false
        getgenv().AutoRaid = false
        getgenv().ESP = false
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Quoc Dat Hub", Text = "Đã tắt tất cả chức năng Redz!", Duration = 5})
    end
})
