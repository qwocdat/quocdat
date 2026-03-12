-- Custom Key System cho Quoc Dat Hub (keyless nhưng có thời hạn ví dụ)
local validKeys = {
    ["quocdat123"] = {expire = os.time() + 86400 * 7},  -- 7 ngày từ lúc nhập
    ["1"] = {expire = os.time() + 86400 * 30},  -- 30 ngày
    -- Thêm key khác nếu muốn, bro edit table này
}

-- UI Key đơn giản (dùng Roblox UI native, đẹp cơ bản)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "QuocDatKeyGui"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Quoc Dat Hub Key"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(0.8, 0, 0, 40)
Input.Position = UDim2.new(0.1, 0, 0.3, 0)
Input.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Input.TextColor3 = Color3.new(1,1,1)
Input.PlaceholderText = "Nhập key (ví dụ: quocdatpro123)"
Input.Text = ""
Input.Parent = Frame

local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.8, 0, 0, 40)
Submit.Position = UDim2.new(0.1, 0, 0.6, 0)
Submit.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Submit.Text = "Unlock Hub"
Submit.TextColor3 = Color3.new(1,1,1)
Submit.Font = Enum.Font.GothamBold
Submit.Parent = Frame

local Notif = Instance.new("TextLabel")
Notif.Size = UDim2.new(1, 0, 0, 30)
Notif.Position = UDim2.new(0, 0, 0.85, 0)
Notif.BackgroundTransparency = 1
Notif.TextColor3 = Color3.fromRGB(255, 100, 100)
Notif.TextScaled = true
Notif.Parent = Frame

Submit.MouseButton1Click:Connect(function()
    local key = Input.Text
    if validKeys[key] then
        local exp = validKeys[key].expire
        if os.time() < exp then
            Notif.Text = "Key đúng! Loading Quoc Dat Hub..."
            Notif.TextColor3 = Color3.fromRGB(0, 255, 150)
            
            -- Load Redz Hub thật
            loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()
            
            -- Đổi hết tên + logo NGAY LẬP TỨC
            spawn(function()
                task.wait(3)  -- Chờ Redz load UI
                
                local playerGui = game.Players.LocalPlayer.PlayerGui
                local function rename()
                    for _, obj in ipairs(playerGui:GetDescendants()) do
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            local t = obj.Text
                            t = t:gsub("Redz", "Quoc Dat")
                            t = t:gsub("Redz Hub", "Quoc Dat Hub")
                            t = t:gsub("by Redz", "by Quoc Dat")
                            t = t:gsub("RedzHub", "Quoc Dat Hub")
                            obj.Text = t
                        end
                        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                            obj.Image = "rbxassetid://16561180435"  -- Icon QD pro (thay nếu muốn khác)
                            obj.Size = UDim2.new(0, 70, 0, 70)
                        end
                    end
                end
                
                -- Loop đổi tên mãi mãi (để tab mới cũng đổi)
                game:GetService("RunService").Heartbeat:Connect(rename)
                rename()  -- Chạy lần đầu
                
                -- Notify thành công
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Quoc Dat Hub",
                    Text = "Đổi tên + logo thành công! UI giờ là Quoc Dat Hub 🔥",
                    Duration = 6
                })
            end)
            
            -- Xóa key UI sau 2s
            task.delay(2, function() ScreenGui:Destroy() end)
        else
            Notif.Text = "Key hết hạn! Liên hệ admin lấy mới."
        end
    else
        Notif.Text = "Key sai! Thử lại bro 😤"
    end
end)
