loadstring(game:HttpGet(("https://raw.githubusercontent.com/daucobonhi/Ui-Redz-V2/refs/heads/main/UiREDzV2.lua")))()

local Window = MakeWindow({
    Hub = {
        Title = "Quoc Dat Hub",
        Animation = "ngdaiquocdat"
    },
    Key = {
        KeySystem = true,
        Title = "Premium Key System",
        Description = "Nhập key để unlock full farm\nKey free: quocdatpro123",
        KeyLink = "https://pastebin.com/raw/ABC123DEF", -- thay link thật
        Keys = {"quocdatpro123", "ngdaiquocdatVIP", "1"},
        Notifi = {
            Notifications = true,
            CorrectKey = "Key đúng! Farm pro sẵn sàng... 🔥",
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

-- Tab riêng cho Auto Farm kiểu pull
local TabAutoFarm = MakeTab({Name = "Auto Farm Pull + Fly"})

getgenv().PullFarm = false  -- Biến toggle

AddButton(TabAutoFarm, {
    Name = "🚀 BẬT/TẮT Pull Farm 10m + Bay Đánh",
    Callback = function()
        getgenv().PullFarm = not getgenv().PullFarm
        
        if not getgenv().PullFarm then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Quoc Dat Hub",
                Text = "Pull Farm đã TẮT!",
                Duration = 4
            })
            return
        end

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Pull Farm BẬT",
            Text = "Đang gom quái 10m dưới chân + bay trên đầu! Spam skill đi bro 🔥",
            Duration = 6
        })

        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")

        -- === FLY ABOVE (bay ở trên) ===
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 12500
        bg.Parent = root

        -- === PULL + FARM LOOP ===
        spawn(function()
            while getgenv().PullFarm and character and root.Parent do
                -- Bay cố định ở trên (cao 15 studs)
                local hoverPos = root.Position + Vector3.new(0, 15, 0)
                bv.Velocity = (hoverPos - root.Position) * 15

                -- Gom quái trong 10m
                for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 
                       and enemy:FindFirstChild("HumanoidRootPart") then
                        
                        local dist = (enemy.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist <= 15 and dist > 3 then  -- \~10m
                            enemy.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, -5, 0)  -- dưới chân
                            enemy.HumanoidRootPart.Velocity = Vector3.new(0, -20, 0)  -- kéo mạnh xuống
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end

            -- Dọn dẹp khi tắt
            if bv and bv.Parent then bv:Destroy() end
            if bg and bg.Parent then bg:Destroy() end
        end)
    end
})

-- Button load Redz Hub (giữ nguyên như cũ)
AddButton(MakeTab({Name = "Redz Hub Full"}), {
    Name = "Load Redz Hub (Full Features)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()
    end
})
