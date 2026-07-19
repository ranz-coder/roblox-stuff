-- =============================================================================
-- PROJECT: LAPER GANK ADMIN - ANDROID MOBILE EDITION
-- AESTHETIC: Dark UI, Purple & Blue Accents, Rounded Cards
-- COMPATIBILITY: 100% Delta Executor (Mobile Touch Safe)
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

-- -----------------------------------------------------------------------------
-- [1] EXECUTOR PARENTING BYPASS (Mencegah Layar Kosong)
-- -----------------------------------------------------------------------------
local targetParent = CoreGui
pcall(function()
    if type(gethui) == "function" then
        targetParent = gethui()
    end
end)
if not targetParent or not pcall(function() return targetParent.Name end) then
    targetParent = localPlayer:WaitForChild("PlayerGui")
end

local guiName = "LaperGankMobileApp"
local oldGui = targetParent:FindFirstChild(guiName)
if oldGui then oldGui:Destroy() end

-- State Variables
local selectedPlayer = nil
local isTeleporting = false
local ESP = { Box = false, Name = false }

-- -----------------------------------------------------------------------------
-- [2] TOUCH-SAFE DRAG MODULE (Khusus Layar Sentuh Android)
-- -----------------------------------------------------------------------------
local function MakeMobileDraggable(dragHandle, frameToMove)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frameToMove.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frameToMove.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- -----------------------------------------------------------------------------
-- [3] UI CONSTRUCTION (TEMA ANDROID DARK + UNGU/BIRU)
-- -----------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = targetParent

-- MAIN DASHBOARD (Abu-abu Gelap)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 340)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Aksen Garis Ungu di sekeliling dashboard
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(138, 43, 226) -- Ungu Mencolok
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- HEADER (Area Drag)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
header.BackgroundTransparency = 0.5
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
MakeMobileDraggable(header, mainFrame) -- Jadikan header bisa diseret

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LAPER GANK HUB"
title.TextColor3 = Color3.fromRGB(0, 191, 255) -- Biru Mencolok
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- TOMBOL CLOSE & MINIMIZE (Gaya Aplikasi Android)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -65, 0.5, -15)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Parent = header

-- SCROLLING FRAME (Kisi Naskah Berbasis Kartu)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 140)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 50)
scrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
scrollFrame.Active = true
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = scrollFrame
Instance.new("UIPadding", scrollFrame).PaddingTop = UDim.new(0, 5)

-- CONTAINER KONTROL MELAYANG (Action Buttons)
local actionContainer = Instance.new("Frame")
actionContainer.Size = UDim2.new(0.9, 0, 0, 130)
actionContainer.Position = UDim2.new(0.05, 0, 0, 200)
actionContainer.BackgroundTransparency = 1
actionContainer.Parent = mainFrame

local uiListAction = Instance.new("UIListLayout")
uiListAction.SortOrder = Enum.SortOrder.LayoutOrder
uiListAction.Padding = UDim.new(0, 8)
uiListAction.Parent = actionContainer

-- TOMBOL TELEPORT (Aksen Biru)
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, 0, 0, 38)
teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
teleportBtn.Text = "TELEPORT (PILIH PLAYER)"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 12
teleportBtn.LayoutOrder = 1
teleportBtn.Parent = actionContainer
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 8)
local tpStroke = Instance.new("UIStroke")
tpStroke.Color = Color3.fromRGB(0, 191, 255) -- Biru
tpStroke.Thickness = 1
tpStroke.Parent = teleportBtn

-- TOMBOL ESP BOX (Aksen Ungu)
local espBoxBtn = Instance.new("TextButton")
espBoxBtn.Size = UDim2.new(1, 0, 0, 35)
espBoxBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
espBoxBtn.Text = "ESP BOX: OFF"
espBoxBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
espBoxBtn.Font = Enum.Font.GothamBold
espBoxBtn.TextSize = 11
espBoxBtn.LayoutOrder = 2
espBoxBtn.Parent = actionContainer
Instance.new("UICorner", espBoxBtn).CornerRadius = UDim.new(0, 8)
local boxStroke = Instance.new("UIStroke")
boxStroke.Color = Color3.fromRGB(138, 43, 226) -- Ungu
boxStroke.Thickness = 1
boxStroke.Parent = espBoxBtn

-- TOMBOL ESP NAME (Aksen Ungu)
local espNameBtn = Instance.new("TextButton")
espNameBtn.Size = UDim2.new(1, 0, 0, 35)
espNameBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
espNameBtn.Text = "ESP NAME: OFF"
espNameBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
espNameBtn.Font = Enum.Font.GothamBold
espNameBtn.TextSize = 11
espNameBtn.LayoutOrder = 3
espNameBtn.Parent = actionContainer
Instance.new("UICorner", espNameBtn).CornerRadius = UDim.new(0, 8)
local nameStroke = Instance.new("UIStroke")
nameStroke.Color = Color3.fromRGB(138, 43, 226) -- Ungu
nameStroke.Thickness = 1
nameStroke.Parent = espNameBtn

-- -----------------------------------------------------------------------------
-- [4] FLOATING MINIMIZE ICON (Aset Roblox Spesifik)
-- -----------------------------------------------------------------------------
local minIcon = Instance.new("ImageButton")
minIcon.Size = UDim2.new(0, 50, 0, 50)
minIcon.Position = UDim2.new(0.5, -25, 0.1, 0)
minIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
minIcon.Image = "rbxassetid://128042443413755"
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false
minIcon.Active = true
minIcon.Parent = gui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1, 0)
local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(0, 191, 255)
iconStroke.Thickness = 2
iconStroke.Parent = minIcon
MakeMobileDraggable(minIcon, minIcon) -- Bisa diseret di layar

-- -----------------------------------------------------------------------------
-- [5] LOGIKA PEMAIN (Desain Kartu)
-- -----------------------------------------------------------------------------
local function updatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local card = Instance.new("TextButton")
            card.Size = UDim2.new(0.95, 0, 0, 32)
            card.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            card.Text = "  " .. player.Name
            card.TextColor3 = Color3.fromRGB(255, 255, 255)
            card.Font = Enum.Font.GothamMedium
            card.TextSize = 12
            card.TextXAlignment = Enum.TextXAlignment.Left
            card.Parent = scrollFrame
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            
            card.Activated:Connect(function()
                selectedPlayer = player
                for _, c in ipairs(scrollFrame:GetChildren()) do
                    if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(40, 40, 45) end
                end
                card.BackgroundColor3 = Color3.fromRGB(0, 191, 255) -- Warna Biru saat dipilih
                teleportBtn.Text = "TP: " .. string.upper(player.Name)
            end)
        end
    end
end
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- -----------------------------------------------------------------------------
-- [6] LOGIKA ESP (Lightweight)
-- -----------------------------------------------------------------------------
local function clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("LaperBox")
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            if hl then hl:Destroy() end
            if head and head:FindFirstChild("LaperName") then head.LaperName:Destroy() end
        end
    end
end

RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local char = p.Character
            
            -- Box ESP
            if ESP.Box then
                if not char:FindFirstChild("LaperBox") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "LaperBox"
                    hl.FillColor = Color3.fromRGB(138, 43, 226) -- Ungu
                    hl.OutlineColor = Color3.fromRGB(0, 191, 255) -- Biru
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0.2
                    hl.Parent = char
                end
            else
                local hl = char:FindFirstChild("LaperBox")
                if hl then hl:Destroy() end
            end
            
            -- Name ESP
            if ESP.Name then
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head and not head:FindFirstChild("LaperName") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "LaperName"
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = p.Name
                    txt.TextColor3 = Color3.fromRGB(0, 191, 255)
                    txt.TextStrokeTransparency = 0
                    txt.Font = Enum.Font.GothamBlack
                    txt.TextSize = 12
                    txt.Parent = bb
                    bb.Parent = head
                end
            else
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head and head:FindFirstChild("LaperName") then
                    head.LaperName:Destroy()
                end
            end
        end
    end
end)

-- -----------------------------------------------------------------------------
-- [7] INTERAKSI TOMBOL (DELTA/MOBILE SAFE)
-- -----------------------------------------------------------------------------
closeBtn.Activated:Connect(function()
    ESP.Box = false
    ESP.Name = false
    clearESP()
    gui:Destroy()
end)

minBtn.Activated:Connect(function()
    mainFrame.Visible = false
    minIcon.Visible = true
end)

minIcon.Activated:Connect(function()
    minIcon.Visible = false
    mainFrame.Visible = true
end)

espBoxBtn.Activated:Connect(function()
    ESP.Box = not ESP.Box
    espBoxBtn.Text = ESP.Box and "ESP BOX: ON" or "ESP BOX: OFF"
    espBoxBtn.TextColor3 = ESP.Box and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(200, 200, 200)
end)

espNameBtn.Activated:Connect(function()
    ESP.Name = not ESP.Name
    espNameBtn.Text = ESP.Name and "ESP NAME: ON" or "ESP NAME: OFF"
    espNameBtn.TextColor3 = ESP.Name and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(200, 200, 200)
end)

teleportBtn.Activated:Connect(function()
    if isTeleporting or not selectedPlayer then return end
    
    local targetChar = selectedPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        teleportBtn.Text = "TARGET TIDAK VALID!"
        task.wait(1.5)
        teleportBtn.Text = "TELEPORT (PILIH PLAYER)"
        selectedPlayer = nil
        return
    end
    
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    isTeleporting = true
    teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    teleportBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    
    for i = 2, 1, -1 do
        teleportBtn.Text = "MENYIAPKAN " .. i .. "s..."
        task.wait(0.5)
    end
    
    if selectedPlayer and targetChar:FindFirstChild("HumanoidRootPart") then
        myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
    
    teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportBtn.Text = "TP: " .. string.upper(selectedPlayer.Name)
    isTeleporting = false
end)
