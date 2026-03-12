loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()

-- ==================== ĐỔI TÊN + LOGO + STATUS NGAY LẬP TỨC ====================
spawn(function()
    task.wait(3)  -- chờ Redz load UI (nếu máy yếu tăng lên 5)

    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local RunService = game:GetService("RunService")

    -- === LOOP ĐỔI TÊN LIÊN TỤC (đổi luôn mọi lúc, kể cả tab mới hiện) ===
    local function renameAll()
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
                local text = gui.Text
                text = text:gsub("Redz", "Quoc Dat")
                text = text:gsub("Redz Hub", "Quoc Dat Hub")
                text = text:gsub("by Redz", "by Quoc Dat")
                text = text:gsub("RedzHub", "Quoc Dat Hub")
                text = text:gsub("Hub", "Quoc Dat Hub")  -- đổi tất cả Hub
                gui.Text = text
            end
        end

        -- Đổi logo nút bấm thành QD (tìm mọi ImageLabel/ImageButton)
        for _, img in ipairs(playerGui:GetDescendants()) do
            if img:IsA("ImageLabel") or img:IsA("ImageButton") then
                -- Thay logo Redz bằng chữ QD đẹp (asset Roblox sẵn)
                img.Image = "rbxassetid://16561180435"  -- logo QD to, đẹp, pro
                img.Size = UDim2.new(0, 80, 0, 80)
            end
        end
    end

    -- Chạy loop đổi tên mỗi 0.5s (đổi ngay và mãi mãi)
    RunService.Heartbeat:Connect(function()
        renameAll()
    end)

    -- ==================== THÊM DÒNG TRẠNG THÁI + PIN ====================
    local statusGui = Instance.new("ScreenGui")
    statusGui.Name = "QuocDatStatus"
    statusGui.Parent = playerGui
    statusGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Position = UDim2.new(0, 0, 1, -40)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    frame.BorderSizePixel = 0
    frame.Parent = statusGui

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = frame

    spawn(function()
        while true do
            local pin = math.random(75, 98)  -- pin giả mượt
            statusLabel.Text = "Trạng thái: Đang chạy | Pin: " .. pin .. "% | Quoc Dat Hub"
            task.wait(5)
        end
    end)

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Quoc Dat Hub",
        Text = "Đã đổi tên + logo + status thành công! UI giờ là Quoc Dat Hub 100% 🔥",
        Duration = 8
    })
end)
