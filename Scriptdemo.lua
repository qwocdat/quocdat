loadstring(game:HttpGet(("https://raw.githubusercontent.com/daucobonhi/Ui-Redz-V2/refs/heads/main/UiREDzV2.lua")))()

local Window = MakeWindow({
    Hub = {
        Title = "Quoc Dat Hub",
        Animation = "ngdaiquocdat | Premium 2026"
    },
    Key = {
        KeySystem = true,  -- Bắt buộc nhập key mới mở UI
        Title = "Premium Key System",
        Description = "Nhập key để unlock hub xịn\nKey free: quocdatpro123 (hoặc liên hệ admin)",
        KeyLink = "https://pastebin.com/raw/ABC123DEF",  -- Thay bằng link Discord/Pastebin thật của bro
        Keys = {
            "quocdatpro123",
            "ngdaiquocdatVIP",
            "redzhub2026",
            "gamezy161663"  -- Thêm key cá nhân hóa nếu muốn
        },
        Notifi = {
            Notifications = true,
            CorrectKey = "Key đúng! Loading Quoc Dat Hub... 🔥",
            Incorrectkey = "Key sai rồi bro! Thử lại hoặc lấy key mới nhé 😤",
            CopyKeyLink = "Đã copy link lấy key!"
        }
    }
})

-- Minimize button đẹp hơn tí
MinimizeButton({
    Image = "http://www.roblox.com/asset/?id=83190276951914",
    Size = {60, 60},
    Color = Color3.fromRGB(15, 15, 25),
    Corner = true,
    Stroke = true,
    StrokeColor = Color3.fromRGB(0, 255, 150)  -- Màu xanh neon cho pro
})

-- Tab chính
local TabFarm = MakeTab({Name = "Script Farm"})
local TabExtra = MakeTab({Name = "Extra Features"})

-- Button load Redz Hub mới (từ huy384 repo)
AddButton(TabFarm, {
    Name = "Redz Hub (Auto Farm + More)",
    Callback = function()
        -- Load script mới bro yêu cầu
        loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()
        
        -- Notify khi load thành công (tùy chọn)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Quoc Dat Hub",
            Text = "Redz Hub đã load! Chờ UI hiện lên bro 🔥",
            Duration = 6
        })
    end
})

-- Button ví dụ khác (thêm thoải mái)
AddButton(TabFarm, {
    Name = "Test Load (Print)",
    Callback = function()
        print("Test button chạy ok! Bro có thể paste script khác vào đây.")
    end
})

AddButton(TabExtra, {
    Name = "Coming Soon - Mirage/ESP",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Quoc Dat Hub",
            Text = "Feature đang dev! Update sớm bro ơi 🚀",
            Duration = 5
        })
    end
})
