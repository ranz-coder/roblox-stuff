-- =============================================================================
-- VIOLENCE DISTRICT — ADMIN GUI (Full Local Client)
-- Taruh di: StarterPlayerScripts (sebagai LocalScript)
-- Semua aksi berjalan murni di client (tanpa RemoteEvent/Server Script).
-- =============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- -----------------------------------------------------------------------------
-- PALET WARNA
-- -----------------------------------------------------------------------------
local COLOR_BG        = Color3.fromRGB(24, 24, 28)
local COLOR_CARD      = Color3.fromRGB(34, 34, 40)
local COLOR_CARD_HOVER= Color3.fromRGB(44, 42, 54)
local COLOR_PURPLE    = Color3.fromRGB(139, 92, 246)
local COLOR_BLUE      = Color3.fromRGB(59, 130, 246)
local COLOR_TEXT      = Color3.fromRGB(235, 235, 240)
local COLOR_SUBTEXT   = Color3.fromRGB(150, 150, 160)
local COLOR_DANGER    = Color3.fromRGB(239, 68, 68)

-- -----------------------------------------------------------------------------
-- ROOT GUI
-- -----------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "VD_AdminGUI_Local"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Folder lokal untuk menampung ESP agar rapi
local espFolder = Instance.new("Folder")
espFolder.Name = "VD_ESP_Folder"
espFolder.Parent = gui

-- -----------------------------------------------------------------------------
-- HELPER: rounded corner + drag
-- -----------------------------------------------------------------------------
local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = inst
    return c
end

local function enableDrag(dragHandle, moveFrame)
    local dragging = false
    local dragStart, startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        moveFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveFrame.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)
end

-- =============================================================================
-- ADMIN PANEL 
-- =============================================================================
local panel = Instance.new("Frame")
panel.Name = "AdminPanel"
panel.Size = UDim2.new(0, 260, 0, 380)
panel.Position = UDim2.new(0.5, -130, 0.5, -190)
panel.BackgroundColor3 = COLOR_BG
panel.BorderSizePixel = 0
panel.Active = true
panel.Visible = true -- Langsung terbuka
panel.Parent = gui
corner(panel, 16)

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = COLOR_BLUE
panelStroke.Thickness = 1
panelStroke.Transparency = 0.5
panelStroke.Parent = panel

-- TOP BAR (drag handle)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = COLOR_CARD
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.Parent = panel
corner(topBar, 16)

local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 12)
topBarCover.Position = UDim2.new(0, 0, 1, -12)
topBarCover.BackgroundColor3 = COLOR_CARD
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new(COLOR_PURPLE, COLOR_BLUE)
titleGradient.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -76, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VD ADMIN (LOCAL)"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -68, 0.5, -15)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Parent = topBar

enableDrag(topBar, panel)

-- SECTION LABEL
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -28, 0, 18)
listLabel.Position = UDim2.new(0, 14, 0, 50)
listLabel.BackgroundTransparency = 1
listLabel.Text = "PLAYERS"
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 11
listLabel.TextColor3 = COLOR_SUBTEXT
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = panel

-- SCROLLING PLAYER LIST
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -28, 0, 140)
scrollFrame.Position = UDim2.new(0, 14, 0, 72)
scrollFrame.BackgroundColor3 = COLOR_CARD
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = COLOR_PURPLE
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Active = true
scrollFrame.Parent = panel
corner(scrollFrame, 10)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 6)
listPadding.PaddingLeft = UDim.new(0, 6)
listPadding.PaddingRight = UDim.new(0, 6)
listPadding.Parent = scrollFrame

-- TELEPORT BUTTON
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -28, 0, 40)
teleportBtn.Position = UDim2.new(0, 14, 0, 222)
teleportBtn.BackgroundColor3 = COLOR_CARD
teleportBtn.Text = "SELECT A PLAYER"
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 12
teleportBtn.TextColor3 = COLOR_SUBTEXT
teleportBtn.Parent = panel
corner(teleportBtn, 10)

-- ESP TOGGLES
local espBoxBtn = Instance.new("TextButton")
espBoxBtn.Size = UDim2.new(1, -28, 0, 38)
espBoxBtn.Position = UDim2.new(0, 14, 0, 270)
espBoxBtn.BackgroundColor3 = COLOR_CARD
espBoxBtn.Text = "ESP BOX: OFF"
espBoxBtn.Font = Enum.Font.GothamBold
espBoxBtn.TextSize = 12
espBoxBtn.TextColor3 = COLOR_SUBTEXT
espBoxBtn.Parent = panel
corner(espBoxBtn, 10)

local espNameBtn = Instance.new("TextButton")
espNameBtn.Size = UDim2.new(1, -28, 0, 38)
espNameBtn.Position = UDim2.new(0, 14, 0, 314)
espNameBtn.BackgroundColor3 = COLOR_CARD
espNameBtn.Text = "ESP NAME: OFF"
espNameBtn.Font = Enum.Font.GothamBold
espNameBtn.TextSize = 12
espNameBtn.TextColor3 = COLOR_SUBTEXT
espNameBtn.Parent = panel
corner(espNameBtn, 10)

-- FLOATING MINIMIZE ICON
local minIcon = Instance.new("ImageButton")
minIcon.Size = UDim2.new(0, 52, 0, 52)
minIcon.Position = UDim2.new(0, 20, 1, -90)
minIcon.BackgroundColor3 = COLOR_BG
minIcon.Image = "" 
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false
minIcon.Active = true
minIcon.Parent = gui
corner(minIcon, 26)

local minIconStroke = Instance.new("UIStroke")
minIconStroke.Color = COLOR_PURPLE
minIconStroke.Thickness = 2
minIconStroke.Parent = minIcon

local minIconLabel = Instance.new("TextLabel")
minIconLabel.Size = UDim2.new(1, 0, 1, 0)
minIconLabel.BackgroundTransparency = 1
minIconLabel.Text = "VD"
minIconLabel.Font = Enum.Font.GothamBold
minIconLabel.TextSize = 14
minIconLabel.TextColor3 = COLOR_TEXT
minIconLabel.Parent = minIcon

enableDrag(minIcon, minIcon)

-- -----------------------------------------------------------------------------
-- STATE & LOCAL FUNCTIONS
-- -----------------------------------------------------------------------------
local selectedPlayer = nil
local espBoxOn, espNameOn = false, false
local playerCards = {}
local activeESPs = {}

-- -----------------------------------------------------------------------------
-- LOKAL: REFRESH PLAYER LIST
-- -----------------------------------------------------------------------------
local function refreshPlayerList()
    for _, card in pairs(playerCards) do
        card:Destroy()
    end
    playerCards = {}

    local list = Players:GetPlayers() -- Ambil langsung dari client
    
    for _, ply in ipairs(list) do
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(1, 0, 0, 32)
        card.BackgroundColor3 = COLOR_CARD_HOVER
        card.Text = "  " .. ply.Name
        card.TextColor3 = COLOR_TEXT
        card.Font = Enum.Font.GothamMedium
        card.TextSize = 12
        card.TextXAlignment = Enum.TextXAlignment.Left
        card.AutoButtonColor = false
        card.Parent = scrollFrame
        corner(card, 8)

        card.Activated:Connect(function()
            selectedPlayer = ply.Name
            for _, c in pairs(playerCards) do
                c.BackgroundColor3 = COLOR_CARD_HOVER
            end
            card.BackgroundColor3 = COLOR_PURPLE
            teleportBtn.Text = "TELEPORT TO " .. ply.Name
            teleportBtn.BackgroundColor3 = COLOR_PURPLE
            teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        table.insert(playerCards, card)
    end
end

-- -----------------------------------------------------------------------------
-- LOKAL: ESP SYSTEM
-- -----------------------------------------------------------------------------
local function clearESP(player)
    if activeESPs[player.Name] then
        for _, obj in pairs(activeESPs[player.Name]) do
            if obj then obj:Destroy() end
        end
        activeESPs[player.Name] = nil
    end
end

local function applyESP(player)
    if player == localPlayer then return end
    clearESP(player)

    local char = player.Character
    if not char then return end

    activeESPs[player.Name] = {}

    -- ESP BOX (menggunakan bawaan Roblox Highlight)
    if espBoxOn then
        local hl = Instance.new("Highlight")
        hl.FillColor = COLOR_PURPLE
        hl.OutlineColor = COLOR_BLUE
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0
        hl.Adornee = char
        hl.Parent = espFolder
        table.insert(activeESPs[player.Name], hl)
    end

    -- ESP NAME (menggunakan BillboardGui)
    if espNameOn then
        local head = char:FindFirstChild("Head")
        if head then
            local bgui = Instance.new("BillboardGui")
            bgui.Name = "ESPName"
            bgui.Adornee = head
            bgui.Size = UDim2.new(0, 100, 0, 30)
            bgui.StudsOffset = Vector3.new(0, 2, 0)
            bgui.AlwaysOnTop = true
            bgui.Parent = espFolder

            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = player.Name
            txt.TextColor3 = COLOR_TEXT
            txt.TextStrokeTransparency = 0
            txt.TextStrokeColor3 = Color3.new(0,0,0)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12
            txt.Parent = bgui
            
            table.insert(activeESPs[player.Name], bgui)
        end
    end
end

local function updateAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        applyESP(p)
    end
end

Players.PlayerAdded:Connect(function(player)
    if panel.Visible then refreshPlayerList() end
    player.CharacterAdded:Connect(function()
        task.wait(1) -- tunggu character render utuh
        applyESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if panel.Visible then refreshPlayerList() end
    clearESP(player)
end)

-- Hubungkan ESP ke pemain yang sudah ada di dalam game
for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function()
        task.wait(1)
        applyESP(p)
    end)
end

-- Refresh awal
refreshPlayerList()

-- -----------------------------------------------------------------------------
-- CLOSE / MINIMIZE
-- -----------------------------------------------------------------------------
closeBtn.Activated:Connect(function()
    espBoxOn = false
    espNameOn = false
    updateAllESP()
    
    panel.Visible = false
    minIcon.Visible = false
end)

minBtn.Activated:Connect(function()
    panel.Visible = false
    minIcon.Visible = true
end)

minIcon.Activated:Connect(function()
    minIcon.Visible = false
    panel.Visible = true
end)

-- -----------------------------------------------------------------------------
-- ESP TOGGLES
-- -----------------------------------------------------------------------------
espBoxBtn.Activated:Connect(function()
    espBoxOn = not espBoxOn
    updateAllESP()
    
    if espBoxOn then
        espBoxBtn.Text = "ESP BOX: ON"
        espBoxBtn.BackgroundColor3 = COLOR_BLUE
        espBoxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        espBoxBtn.Text = "ESP BOX: OFF"
        espBoxBtn.BackgroundColor3 = COLOR_CARD
        espBoxBtn.TextColor3 = COLOR_SUBTEXT
    end
end)

espNameBtn.Activated:Connect(function()
    espNameOn = not espNameOn
    updateAllESP()
    
    if espNameOn then
        espNameBtn.Text = "ESP NAME: ON"
        espNameBtn.BackgroundColor3 = COLOR_BLUE
        espNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        espNameBtn.Text = "ESP NAME: OFF"
        espNameBtn.BackgroundColor3 = COLOR_CARD
        espNameBtn.TextColor3 = COLOR_SUBTEXT
    end
end)

-- -----------------------------------------------------------------------------
-- LOKAL: TELEPORT (Memindahkan HumanoidRootPart Client Secara Langsung)
-- -----------------------------------------------------------------------------
teleportBtn.Activated:Connect(function()
    if not selectedPlayer then return end
    
    local targetPlayer = Players:FindFirstChild(selectedPlayer)
    if not targetPlayer then
        teleportBtn.Text = "PLAYER LEFT"
        teleportBtn.BackgroundColor3 = COLOR_DANGER
        task.wait(1.2)
        teleportBtn.Text = "SELECT A PLAYER"
        teleportBtn.BackgroundColor3 = COLOR_CARD
        teleportBtn.TextColor3 = COLOR_SUBTEXT
        selectedPlayer = nil
        return
    end
    
    local myChar = localPlayer.Character
    local targetChar = targetPlayer.Character
    
    if myChar and targetChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        
        if myRoot and targetRoot then
            -- Pindahkan karakter lokal langsung ke target offset sedikit agar tidak stuck
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
        end
    end
end)
