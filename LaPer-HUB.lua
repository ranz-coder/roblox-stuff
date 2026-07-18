-- =============================================================================
-- PROJECT NAME: Laper Gank Admin - DELTA MOBILE EDITION
-- FITUR: Player List TP, ESP Box, ESP Name, Minimize Logo
-- STATUS: 100% Touch Screen & Executor Safe API
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local selectedPlayer = nil
local isTeleporting = false

local ESPSettings = {
    Box = false,
    Name = false
}

-- -----------------------------------------------------------------------------
-- [DELTA BYPASS] MENCARI PARENT UI YANG AMAN
-- -----------------------------------------------------------------------------
local targetParent = CoreGui
if type(gethui) == "function" then
    pcall(function() targetParent = gethui() end)
end

-- Hapus UI lama jika di-execute ulang
local guiName = "LaperGankDeltaMobile"
local oldGui = targetParent:FindFirstChild(guiName)
if oldGui then oldGui:Destroy() end

-- -----------------------------------------------------------------------------
-- PEMBUATAN UI UTAMA (MOBILE OPTIMIZED)
-- -----------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = targetParent

-- FRAME UTAMA
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 320) -- Ukuran pas untuk layar Mobile
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- TOP BAR (Area Drag)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

-- Menutupi sudut bawah topbar agar menyatu dengan frame
local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 10)
topBarCover.Position = UDim2.new(0, 0, 1, -10)
topBarCover.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

-- JUDUL
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LAPER GANK ADMIN"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- TOMBOL CLOSE
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -32, 0.5, -15)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = topBar

-- TOMBOL MINIMIZE
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -62, 0.5, -15)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = topBar

-- SCROLLING FRAME (DAFTAR PEMAIN PERMANEN)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 120)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 45)
scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
scrollFrame.Active = true
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.Parent = scrollFrame

-- TOMBOL EKSEKUSI TELEPORT
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.9, 0, 0, 35)
teleportBtn.Position = UDim2.new(0.05, 0, 0, 175)
teleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
teleportBtn.Text = "PILIH TARGET DI LIST"
teleportBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 13
teleportBtn.Parent = mainFrame
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 6)

-- TOMBOL TOGGLE ESP BOX
local espBoxBtn = Instance.new("TextButton")
espBoxBtn.Size = UDim2.new(0.9, 0, 0, 35)
espBoxBtn.Position = UDim2.new(0.05, 0, 0, 220)
espBoxBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
espBoxBtn.Text = "ESP BOX: OFF"
espBoxBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
espBoxBtn.Font = Enum.Font.GothamBold
espBoxBtn.TextSize = 12
espBoxBtn.Parent = mainFrame
Instance.new("UICorner", espBoxBtn).CornerRadius = UDim.new(0, 6)

-- TOMBOL TOGGLE ESP NAME
local espNameBtn = Instance.new("TextButton")
espNameBtn.Size = UDim2.new(0.9, 0, 0, 35)
espNameBtn.Position = UDim2.new(0.05, 0, 0, 265)
espNameBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
espNameBtn.Text = "ESP NAME: OFF"
espNameBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
espNameBtn.Font = Enum.Font.GothamBold
espNameBtn.TextSize = 12
espNameBtn.Parent = mainFrame
Instance.new("UICorner", espNameBtn).CornerRadius = UDim.new(0, 6)

-- ICON MINIMIZE DENGAN LOGO
local minIcon = Instance.new("ImageButton")
minIcon.Size = UDim2.new(0, 50, 0, 50)
minIcon.Position = UDim2.new(0.5, -25, 0.8, -25)
minIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
minIcon.Image = "rbxassetid://128042443413755"
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false
minIcon.Active = true
minIcon.Parent = gui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1, 0)

-- -----------------------------------------------------------------------------
-- FUNGSI DRAG LAYAR SENTUH (MOBILE)
-- -----------------------------------------------------------------------------
local function enableDrag(dragArea, moveFrame)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            moveFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

enableDrag(topBar, mainFrame)
enableDrag(minIcon, minIcon)

-- -----------------------------------------------------------------------------
-- SISTEM PLAYER LIST OTOMATIS
-- -----------------------------------------------------------------------------
local function updatePlayerList()
    -- Bersihkan list lama
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Isi dengan player aktif
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            btn.Text = "  " .. player.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scrollFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            -- [DELTA FIX] Menggunakan .Activated untuk sentuhan layar
            btn.Activated:Connect(function()
                selectedPlayer = player
                
                -- Reset warna tombol lain
                for _, b in ipairs(scrollFrame:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(45, 45, 50) end
                end
                -- Beri warna pada tombol yang dipilih
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                
                teleportBtn.Text = "TP KE: " .. player.Name
                teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- -----------------------------------------------------------------------------
-- SISTEM ESP (HIGHLIGHT BOX & NAME BILLBOARD)
-- -----------------------------------------------------------------------------
local function cleanESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local hl = player.Character:FindFirstChild("LaperBox")
            if hl then hl:Destroy() end
            
            local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if head then
                local bb = head:FindFirstChild("LaperName")
                if bb then bb:Destroy() end
            end
        end
    end
end

local function refreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local char = player.Character
            
            -- LOGIKA ESP BOX
            if ESPSettings.Box then
                local hl = char:FindFirstChild("LaperBox")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "LaperBox"
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                end
            else
                local hl = char:FindFirstChild("LaperBox")
                if hl then hl:Destroy() end
            end
            
            -- LOGIKA ESP NAME
            if ESPSettings.Name then
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head then
                    local bb = head:FindFirstChild("LaperName")
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name = "LaperName"
                        bb.Size = UDim2.new(0, 200, 0, 50)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = player.Name
                        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                        txt.TextStrokeTransparency = 0
                        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 13
                        txt.Parent = bb
                        bb.Parent = head
                    end
                end
            else
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head then
                    local bb = head:FindFirstChild("LaperName")
                    if bb then bb:Destroy() end
                end
            end
        end
    end
end

-- Update ESP menggunakan Heartbeat agar stabil di Eksekutor
RunService.Heartbeat:Connect(function()
    pcall(refreshESP)
end)

-- -----------------------------------------------------------------------------
-- BINDING TOMBOL INTERAKSI (MENGGUNAKAN .ACTIVATED)
-- -----------------------------------------------------------------------------

-- Tombol Tutup Total
closeBtn.Activated:Connect(function() 
    ESPSettings.Box = false
    ESPSettings.Name = false
    cleanESP()
    gui:Destroy() 
end)

-- Tombol Minimize
minBtn.Activated:Connect(function()
    mainFrame.Visible = false
    minIcon.Visible = true
    minIcon.Position = UDim2.new(0, mainFrame.AbsolutePosition.X, 0, mainFrame.AbsolutePosition.Y)
end)

-- Tombol Buka dari Minimize
minIcon.Activated:Connect(function()
    minIcon.Visible = false
    mainFrame.Visible = true
    mainFrame.Position = UDim2.new(0, minIcon.AbsolutePosition.X, 0, minIcon.AbsolutePosition.Y)
end)

-- Toggle ESP Box
espBoxBtn.Activated:Connect(function()
    ESPSettings.Box = not ESPSettings.Box
    if ESPSettings.Box then
        espBoxBtn.Text = "ESP BOX: ON"
        espBoxBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        espBoxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        espBoxBtn.Text = "ESP BOX: OFF"
        espBoxBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        espBoxBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- Toggle ESP Name
espNameBtn.Activated:Connect(function()
    ESPSettings.Name = not ESPSettings.Name
    if ESPSettings.Name then
        espNameBtn.Text = "ESP NAME: ON"
        espNameBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        espNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        espNameBtn.Text = "ESP NAME: OFF"
        espNameBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        espNameBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- Tombol Eksekusi Teleport
teleportBtn.Activated:Connect(function()
    if isTeleporting or not selectedPlayer then return end
    
    local targetChar = selectedPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        teleportBtn.Text = "TARGET HILANG!"
        teleportBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        task.wait(1.5)
        teleportBtn.Text = "PILIH TARGET DI LIST"
        teleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        selectedPlayer = nil
        return
    end
    
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    isTeleporting = true
    teleportBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    
    -- Efek delay taktis
    for i = 2, 1, -1 do
        teleportBtn.Text = "MENYIAPKAN TP " .. i .. "..."
        task.wait(0.5)
    end
    
    -- Proses Teleport (Bypass CFrame ke 3 Studs di belakang musuh)
    if selectedPlayer and targetChar:FindFirstChild("HumanoidRootPart") then
        myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
    
    teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    teleportBtn.Text = "TP KE: " .. selectedPlayer.Name
    isTeleporting = false
end)
