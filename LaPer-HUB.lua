-- =============================================================================
-- SCRIPT UJI COBA: TELEPORT ONLY (MINIMALIST)
-- Fungsi: Menguji apakah fungsi CFrame Teleport diizinkan oleh eksekutor/game
-- =============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

-- Mencari tempat aman untuk UI (Executor Bypass)
local targetParent = pcall(gethui) and gethui() or CoreGui
if not pcall(function() local a = targetParent.Name end) then
    targetParent = localPlayer:WaitForChild("PlayerGui")
end

-- Hapus UI lama jika ada
local oldGui = targetParent:FindFirstChild("TestTeleportUI")
if oldGui then oldGui:Destroy() end

-- Buat UI Dasar
local gui = Instance.new("ScreenGui")
gui.Name = "TestTeleportUI"
gui.ResetOnSpawn = false
gui.Parent = targetParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 110)
frame.Position = UDim2.new(0.5, -100, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 60, 60)
frame.Active = true
frame.Draggable = true -- Memakai fungsi drag bawaan untuk tes cepat
frame.Parent = gui

-- Tombol Close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -25, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame

-- Kolom Ketik Nama
local inputName = Instance.new("TextBox")
inputName.Size = UDim2.new(0.9, 0, 0, 30)
inputName.Position = UDim2.new(0.05, 0, 0, 30)
inputName.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
inputName.PlaceholderText = "Ketik awalan nama..."
inputName.Font = Enum.Font.GothamMedium
inputName.TextSize = 14
inputName.Text = ""
inputName.ClearTextOnFocus = false
inputName.Parent = frame

-- Tombol Teleport
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 35)
tpBtn.Position = UDim2.new(0.05, 0, 0, 65)
tpBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
tpBtn.Text = "TEST TELEPORT"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 14
tpBtn.Parent = frame

-- LOGIKA TELEPORT DENGAN AUTO-COMPLETE
tpBtn.MouseButton1Click:Connect(function()
    local searchText = string.lower(inputName.Text)
    if searchText == "" then
        tpBtn.Text = "ISI NAMA DULU!"
        task.wait(1)
        tpBtn.Text = "TEST TELEPORT"
        return
    end

    local targetPlayer = nil
    
    -- Mencari pemain yang namanya berawalan huruf yang diketik
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            if string.sub(string.lower(p.Name), 1, #searchText) == searchText then
                targetPlayer = p
                break
            end
        end
    end

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = localPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            -- Proses Teleport (Langsung, tanpa hitung mundur untuk tes)
            myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            tpBtn.Text = "BERHASIL!"
            tpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            tpBtn.Text = "KARAKTERMU MATI!"
        end
    else
        tpBtn.Text = "TIDAK KETEMU!"
        tpBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end

    task.wait(1.5)
    tpBtn.Text = "TEST TELEPORT"
    tpBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
