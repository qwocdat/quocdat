-- Load Redz Hub thật (UI gốc)
loadstring(game:HttpGet("https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"))()

-- Đổi tên title thành Quoc Dat Hub (chạy ngầm sau khi UI load)
spawn(function()
    task.wait(4)  -- chờ Redz load UI xong (nếu lag thì tăng lên 6)
    
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local coreGui = game:GetService("CoreGui")
    
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and (gui.Text:find("Redz") or gui.Text:find("Hub") or gui.Name == "Title") then
            gui.Text = "Quoc Dat Hub"
        end
    end
    
    for _, gui in ipairs(coreGui:GetDescendants()) do
        if gui:IsA("TextLabel") and (gui.Text:find("Redz") or gui.Text:find("Hub")) then
            gui.Text = "Quoc Dat Hub"
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Quoc Dat Hub",
        Text = "Đã đổi tên thành Quoc Dat Hub thành công! 🔥",
        Duration = 5
    })
end)
