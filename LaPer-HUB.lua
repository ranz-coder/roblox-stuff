-- =============================================================================
-- PROJECT: Laper Gank Admin - CYBERPUNK EDITION (Bug-Free & Optimized)
-- THEME: Neon Cyberpunk HUD (Cyan / Magenta / Dark Void)
-- =============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
if not localPlayer then return end

-- =============================================================================
-- 1. SECURE GUI INJECTION (ANTI-ERROR)
-- =============================================================================
local targetGuiParent
if type(gethui) == "function" then
    targetGuiParent = gethui()
elseif pcall(function() return CoreGui.Name end) then
    targetGuiParent = CoreGui
else
    targetGuiParent = localPlayer:WaitForChild("PlayerGui", 10)
end

local oldGui = targetGuiParent:FindFirstChild("LaperGank_CyberpunkHUD")
if oldGui then oldGui:Destroy() end

-- =============================================================================
-- 2. CYBERPUNK COLOR PALETTE & SETTINGS
-- =============================================================================
local C_BG         = Color3.fromRGB(15, 15, 20)      -- Void Black
local C_SURFACE    = Color3.fromRGB(25, 25, 33)      -- Dark Grey
local C_CYAN       = Color3.fromRGB(0, 240, 255)     -- Neon Cyan
local C_MAGENTA    = Color3.fromRGB(255, 0, 85)      -- Neon Magenta
local C_YELLOW     = Color3.fromRGB(250, 250, 50)    -- Warning Yellow
local C_TEXT       = Color3.fromRGB(220, 230, 255)   -- Bright HUD Text

local FONT_TECH    = Enum.Font.Michroma
local FONT_CODE    = Enum.Font.Code

local isTeleporting = false
local selectedPlayer = nil
local EspSettings = { GeneratorAura = false, StatusOverlay = true }

local AuraContainer = Instance.new("Folder")
AuraContainer.Name = "LG_CyberAuras"
AuraContainer.Parent = workspace

-- =============================================================================
-- 3. CORE UTILITIES
-- =============================================================================
-- Better Dragging System
local function makeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Hover Effect Utility
local function addHoverEffect(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

-- Neon Stroke Generator
local function createNeonStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- =============================================================================
-- 4. CYBERPUNK UI CONSTRUCTION
-- =============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaperGank_CyberpunkHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGuiParent

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 260)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
mainFrame.BackgroundColor3 = C_BG
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
createNeonStroke(mainFrame, C_CYAN, 2)

-- HEADER / TOPBAR
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = C_CYAN
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LAPER_GANK // SYS_ADMIN"
title.TextColor3 = C_BG
title.Font = FONT_TECH
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

makeDraggable(topBar, mainFrame)

-- MIN & CLOSE BUTTONS
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = C_MAGENTA
closeBtn.Text = "X"
closeBtn.TextColor3 = C_TEXT
closeBtn.Font = FONT_CODE
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar
addHoverEffect(closeBtn, C_MAGENTA, Color3.fromRGB(200, 0, 50))

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.BackgroundColor3 = C_SURFACE
minBtn.Text = "_"
minBtn.TextColor3 = C_CYAN
minBtn.Font = FONT_CODE
minBtn.TextSize = 16
minBtn.BorderSizePixel = 0
minBtn.Parent = topBar
addHoverEffect(minBtn, C_SURFACE, Color3.fromRGB(40, 40, 50))

-- DROPDOWN (TARGET SELECTOR)
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 35)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 45)
dropdownBtn.BackgroundColor3 = C_SURFACE
dropdownBtn.Text = "  > AWAITING_TARGET..."
dropdownBtn.TextColor3 = C_TEXT
dropdownBtn.Font = FONT_CODE
dropdownBtn.TextSize = 12
dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
dropdownBtn.Parent = mainFrame
createNeonStroke(dropdownBtn, C_CYAN, 1)
addHoverEffect(dropdownBtn, C_SURFACE, Color3.fromRGB(35, 35, 45))

-- EXECUTE BUTTON
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.9, 0, 0, 40)
teleportBtn.Position = UDim2.new(0.05, 0, 0, 90)
teleportBtn.BackgroundColor3 = C_SURFACE
teleportBtn.Text = "[ INITIATE_JUMP ]"
teleportBtn.TextColor3 = C_MAGENTA
teleportBtn.Font = FONT_TECH
teleportBtn.TextSize = 12
teleportBtn.Parent = mainFrame
createNeonStroke(teleportBtn, C_MAGENTA, 1)
addHoverEffect(teleportBtn, C_SURFACE, Color3.fromRGB(45, 20, 30))

-- SCANNER TOGGLES
local scanLabel = Instance.new("TextLabel")
scanLabel.Size = UDim2.new(0.9, 0, 0, 15)
scanLabel.Position = UDim2.new(0.05, 0, 0, 145)
scanLabel.BackgroundTransparency = 1
scanLabel.Text = "// SENSOR MODULES"
scanLabel.TextColor3 = C_CYAN
scanLabel.Font = FONT_CODE
scanLabel.TextSize = 11
scanLabel.TextXAlignment = Enum.TextXAlignment.Left
scanLabel.Parent = mainFrame

local toggleGenBtn = Instance.new("TextButton")
toggleGenBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleGenBtn.Position = UDim2.new(0.05, 0, 0, 165)
toggleGenBtn.BackgroundColor3 = C_SURFACE
toggleGenBtn.Text = "OBJ_SCANNER: OFFLINE"
toggleGenBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
toggleGenBtn.Font = FONT_CODE
toggleGenBtn.TextSize = 11
toggleGenBtn.Parent = mainFrame
local genStroke = createNeonStroke(toggleGenBtn, Color3.fromRGB(100, 100, 100), 1)

local toggleBioBtn = Instance.new("TextButton")
toggleBioBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleBioBtn.Position = UDim2.new(0.05, 0, 0, 205)
toggleBioBtn.BackgroundColor3 = C_CYAN
toggleBioBtn.Text = "BIO_OVERLAY: ONLINE"
toggleBioBtn.TextColor3 = C_BG
toggleBioBtn.Font = FONT_CODE
toggleBioBtn.TextSize = 11
toggleBioBtn.Parent = mainFrame
local bioStroke = createNeonStroke(toggleBioBtn, C_CYAN, 1)

-- SCROLLING PLAYER LIST
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 130)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 85)
scrollFrame.BackgroundColor3 = C_BG
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = C_CYAN
scrollFrame.Visible = false
scrollFrame.ZIndex = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
scrollFrame.Parent = mainFrame
createNeonStroke(scrollFrame, C_CYAN, 1)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.PaddingLeft = UDim.new(0, 5)
listPadding.PaddingRight = UDim.new(0, 5)
listPadding.Parent = scrollFrame

-- FLOATING MINIMIZE ICON (CYBER STYLE)
local minIcon = Instance.new("ImageButton")
minIcon.Size = UDim2.new(0, 45, 0, 45)
minIcon.Position = UDim2.new(0.5, -22, 0.8, -22)
minIcon.BackgroundColor3 = C_BG
minIcon.Image = "rbxassetid://128042443413755"
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false
minIcon.ZIndex = 100
minIcon.Parent = screenGui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1, 0)
createNeonStroke(minIcon, C_CYAN, 2)
makeDraggable(minIcon, minIcon)

-- =============================================================================
-- 5. MECHANICS & LOGIC
-- =============================================================================

local function getPlayerStatus(player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return "Dead" end
    local char = player.Character
    local hum = char.Humanoid
    
    if char:FindFirstChild("Hooked") or char:FindFirstChild("Sacrificed") or hum.PlatformStand then
        return "Hooked"
    end
    if hum.Health <= 0 then return "Dead" end
    if hum.Health < 30 or char:FindFirstChild("Bleeding") or hum.WalkSpeed < 8 then return "Downed" end
    if hum.Health < 100 then return "Injured" end
    return "Healthy"
end

local function updatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local pStatus = getPlayerStatus(player)
            local statusColor = C_TEXT
            local textSuffix = ""
            
            if EspSettings.StatusOverlay then
                if pStatus == "Hooked" then
                    statusColor = C_MAGENTA
                    textSuffix = " [CRITICAL: HOOKED]"
                elseif pStatus == "Downed" then
                    statusColor = C_YELLOW
                    textSuffix = " [WARN: DOWNED]"
                elseif pStatus == "Injured" then
                    statusColor = Color3.fromRGB(255, 170, 0)
                    textSuffix = " [WARN: INJURED]"
                elseif pStatus == "Dead" then
                    statusColor = Color3.fromRGB(100, 100, 100)
                    textSuffix = " [OFFLINE]"
                else
                    statusColor = C_CYAN
                    textSuffix = " [NOMINAL]"
                end
            end
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BackgroundColor3 = C_SURFACE
            btn.Text = "> " .. player.Name .. textSuffix
            btn.TextColor3 = statusColor
            btn.Font = FONT_CODE
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            btn.ZIndex = 6
            btn.Parent = scrollFrame
            addHoverEffect(btn, C_SURFACE, Color3.fromRGB(40, 40, 50))
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = player
                dropdownBtn.Text = "  > TARGET: " .. player.Name
                dropdownBtn.TextColor3 = statusColor
                scrollFrame.Visible = false
            end)
        end
    end
end

local function applyObjectiveAuras()
    AuraContainer:ClearAllChildren()
    if not EspSettings.GeneratorAura then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(string.lower(obj.Name), "generator") or string.find(string.lower(obj.Name), "gate")) then
            local highlight = Instance.new("Highlight")
            highlight.Name = "CyberAura"
            highlight.Adornee = obj
            highlight.FillColor = C_CYAN
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = C_CYAN
            highlight.OutlineTransparency = 0
            highlight.Parent = AuraContainer
        end
    end
end

RunService.Heartbeat:Connect(function()
    if EspSettings.GeneratorAura then
        for _, highlight in ipairs(AuraContainer:GetChildren()) do
            if highlight:IsA("Highlight") and highlight.Adornee then
                local obj = highlight.Adornee
                -- Deteksi progres mekanik umum di banyak game
                if obj:FindFirstChild("Working") or (obj:FindFirstChild("Progress") and obj.Progress.Value > 0) then
                    highlight.FillColor = C_YELLOW
                    highlight.OutlineColor = C_YELLOW
                end
            end
        end
    end
end)

-- =============================================================================
-- 6. BUTTON BINDINGS
-- =============================================================================
closeBtn.MouseButton1Click:Connect(function() 
    AuraContainer:Destroy()
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minIcon.Visible = true
    minIcon.Position = UDim2.new(0, mainFrame.AbsolutePosition.X, 0, mainFrame.AbsolutePosition.Y)
end)

minIcon.MouseButton1Click:Connect(function()
    minIcon.Visible = false
    mainFrame.Visible = true
    mainFrame.Position = UDim2.new(0, minIcon.AbsolutePosition.X, 0, minIcon.AbsolutePosition.Y)
end)

dropdownBtn.MouseButton1Click:Connect(function()
    if isTeleporting then return end
    scrollFrame.Visible = not scrollFrame.Visible
    if scrollFrame.Visible then updatePlayerList() end
end)

toggleGenBtn.MouseButton1Click:Connect(function()
    EspSettings.GeneratorAura = not EspSettings.GeneratorAura
    if EspSettings.GeneratorAura then
        toggleGenBtn.Text = "OBJ_SCANNER: ONLINE"
        toggleGenBtn.BackgroundColor3 = C_CYAN
        toggleGenBtn.TextColor3 = C_BG
        genStroke.Color = C_CYAN
        applyObjectiveAuras()
    else
        toggleGenBtn.Text = "OBJ_SCANNER: OFFLINE"
        toggleGenBtn.BackgroundColor3 = C_SURFACE
        toggleGenBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        genStroke.Color = Color3.fromRGB(100, 100, 100)
        AuraContainer:ClearAllChildren()
    end
end)

toggleBioBtn.MouseButton1Click:Connect(function()
    EspSettings.StatusOverlay = not EspSettings.StatusOverlay
    if EspSettings.StatusOverlay then
        toggleBioBtn.Text = "BIO_OVERLAY: ONLINE"
        toggleBioBtn.BackgroundColor3 = C_CYAN
        toggleBioBtn.TextColor3 = C_BG
        bioStroke.Color = C_CYAN
    else
        toggleBioBtn.Text = "BIO_OVERLAY: OFFLINE"
        toggleBioBtn.BackgroundColor3 = C_SURFACE
        toggleBioBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        bioStroke.Color = Color3.fromRGB(100, 100, 100)
    end
    if scrollFrame.Visible then updatePlayerList() end
end)

-- TELEPORT EXECUTION (Bug Fix: Using PivotTo for reliable model teleport)
teleportBtn.MouseButton1Click:Connect(function()
    if isTeleporting then return end
    
    if not selectedPlayer or not selectedPlayer.Character or not selectedPlayer.Character.PrimaryPart then
        dropdownBtn.Text = "  > ERROR: TARGET_LOST"
        dropdownBtn.TextColor3 = C_MAGENTA
        task.wait(1.5)
        dropdownBtn.Text = "  > AWAITING_TARGET..."
        dropdownBtn.TextColor3 = C_TEXT
        selectedPlayer = nil
        return
    end
    
    local myChar = localPlayer.Character
    if not myChar or not myChar.PrimaryPart then return end
    
    isTeleporting = true
    scrollFrame.Visible = false
    
    -- GLITCH/WARNING VISUAL DURING COUNTDOWN
    teleportBtn.BackgroundColor3 = C_MAGENTA
    teleportBtn.TextColor3 = C_BG
    
    for i = 3, 1, -1 do
        teleportBtn.Text = "[ SYS_JUMP IN " .. i .. "s ]"
        task.wait(1)
    end
    
    -- Execute Teleport Securely
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character.PrimaryPart and myChar.PrimaryPart then
        local targetCFrame = selectedPlayer.Character.PrimaryPart.CFrame
        -- PivotTo is the modern, safe way to teleport entire models in Roblox
        myChar:PivotTo(targetCFrame * CFrame.new(0, 0, 4)) 
    end
    
    -- Reset State
    teleportBtn.BackgroundColor3 = C_SURFACE
    teleportBtn.TextColor3 = C_MAGENTA
    teleportBtn.Text = "[ INITIATE_JUMP ]"
    dropdownBtn.Text = "  > AWAITING_TARGET..."
    dropdownBtn.TextColor3 = C_TEXT
    selectedPlayer = nil
    isTeleporting = false
end)
