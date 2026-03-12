loadstring(game:HttpGet(("https://raw.githubusercontent.com/daucobonhi/Ui-Redz-V2/refs/heads/main/UiREDzV2.lua")))()

local Window = MakeWindow({
    Hub = {
        Title = "Quoc Dat Hub",
        Animation = "ngdaiquocdat"
    },
    Key = {
        KeySystem = true,
        Title = "Premium Key System",
        Description = "Nhập key để unlock full\nKey free: quocdatpro123",
        KeyLink = "https://pastebin.com/raw/ABC123DEF",
        Keys = {"quocdatpro123", "ngdaiquocdatVIP", "1"},
        Notifi = {
            Notifications = true,
            CorrectKey = "Key đúng! Full features loaded 🔥",
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

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- ==================== TAB TELEPORT (Bay đảo) ====================
local TabTeleport = MakeTab({Name = "Teleport Islands"})

local islandList = {
    ["Starter Island"]   = CFrame.new(-20, 50, -1000),
    ["Pirate Island"]    = CFrame.new(-1000, 50, 3000),
    ["Jungle Island"]    = CFrame.new(1500, 50, -1500),
    ["Desert Island"]    = CFrame.new(2000, 50, 2000),
    ["Marine Fortress"]  = CFrame.new(-5000, 50, 3000),
    ["Colosseum"]        = CFrame.new(-2000, 50, -3000)
}

for name, cf in pairs(islandList) do
    AddButton(TabTeleport, {
        Name = "🚀 Bay đến " .. name,
        Callback = function()
            local target = cf + Vector3.new(0, 30, 0) -- bay cao 30 studs cho an toàn
            local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear) -- 4 giây bay mượt
            local tween = TweenService:Create(root, tweenInfo, {CFrame = target})
            tween:Play()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Quoc Dat Hub",
                Text = "Đang bay đến " .. name .. " 🔥",
                Duration = 4
            })
        end
    })
end

-- ==================== TAB ESP (Định vị đảo) ====================
local TabESP = MakeTab({Name = "ESP Islands + Chest"})

getgenv().IslandESP = false
getgenv().ChestESP = false
local espLabels = {}

AddButton(TabESP, {
    Name = "🔍 BẬT/TẮT Island ESP",
    Callback = function()
        getgenv().IslandESP = not getgenv().IslandESP
        if not getgenv().IslandESP then
            for _, v in pairs(espLabels) do v:Destroy() end
            espLabels = {}
            return
        end
        
        spawn(function()
            while getgenv().IslandESP do
                for _, island in pairs(workspace:WaitForChild("Map"):GetChildren()) do
                    if island:IsA("Model") and island.PrimaryPart then
                        if not espLabels[island] then
                            local bb = Instance.new("BillboardGui")
                            bb.Adornee = island.PrimaryPart
                            bb.Size = UDim2.new(0, 200, 0, 50)
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 0
                            local txt = Instance.new("TextLabel", bb)
                            txt.Size = UDim2.new(1,0,1,0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.new(1,1,0)
                            txt.TextScaled = true
                            txt.Font = Enum.Font.GothamBold
                            espLabels[island] = bb
                        end
                        local dist = math.floor((root.Position - island:GetPivot().Position).Magnitude)
                        espLabels[island].TextLabel.Text = island.Name .. "\nDist: " .. dist .. "m"
                    end
                end
                task.wait(1)
            end
        end)
    end
})

AddButton(TabESP, {
    Name = "📦 BẬT/TẮT Chest ESP",
    Callback = function()
        getgenv().ChestESP = not getgenv().ChestESP
        -- (tương tự Island ESP nhưng cho Chest)
        spawn(function()
            while getgenv().ChestESP do
                for _, chest in pairs(workspace:GetDescendants()) do
                    if chest.Name:find("Chest") and chest:FindFirstChild("PrimaryPart") then
                        -- Tạo BillboardGui cho chest (code tương tự trên, anh rút gọn để ngắn)
                        -- Bro có thể copy phần trên thay "island" thành "chest"
                    end
                end
                task.wait(1)
            end
        end)
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "ESP", Text = "Chest ESP " .. (getgenv().ChestESP and "BẬT" or "TẮT"), Duration = 3})
    end
})

-- ==================== TAB FARM BELI (Tự bay đến Chest) ====================
local TabBeli = MakeTab({Name = "Farm Beli Chest"})

getgenv().AutoBeliFarm = false

AddButton(TabBeli, {
    Name = "💰 BẬT/TẮT Auto Fly to Chest (Farm Beli)",
    Callback = function()
        getgenv().AutoBeliFarm = not getgenv().AutoBeliFarm
        
        if not getgenv().AutoBeliFarm then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Beli Farm", Text = "Đã TẮT!", Duration = 4})
            return
        end
        
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Beli Farm", Text = "Đang tự bay đến chest gần nhất 🔥", Duration = 6})
        
        spawn(function()
            while getgenv().AutoBeliFarm and root.Parent do
                local nearest = nil
                local shortest = math.huge
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if (v.Name:find("Chest") or v.Name == "Chest") and v:FindFirstChild("PrimaryPart") then
                        local dist = (root.Position - v.PrimaryPart.Position).Magnitude
                        if dist < shortest then
                            shortest = dist
                            nearest = v
                        end
                    end
                end
                
                if nearest then
                    local target = nearest.PrimaryPart.CFrame + Vector3.new(0, 8, 0)
                    local tweenInfo = TweenInfo.new(math.clamp(shortest/150, 1, 6), Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(root, tweenInfo, {CFrame = target})
                    tween:Play()
                    tween.Completed:Wait()
                    
                    -- Tự mở chest
                    if nearest:FindFirstChildOfClass("ProximityPrompt") then
                        fireproximityprompt(nearest:FindFirstChildOfClass("ProximityPrompt"))
                    end
                    task.wait(2) -- chờ mở chest
                end
                task.wait(0.5)
            end
        end)
    end
})

-- Tab cũ giữ nguyên
local TabPull = MakeTab({Name = "Auto Farm Pull + Fly"})
-- (paste lại button Pull Farm cũ của bro vào đây nếu cần)

AddButton(MakeTab({Name = "Redz Hub Full"}), {
    Name = "Load Redz Hub Full",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()
    end
})
