-- =============================================================================
-- PROJECT NAME: Laper Gank Admin TP - Optimized & Bulletproof Edition
-- DESIGN SPECIFICATION: Compact Modern Dark HUD Framework
-- =============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
if not localPlayer then return end

-- =============================================================================
-- 1. AUTO-DETECT GUI PARENT (ANTI-ERROR EXECUTOR)
-- =============================================================================
local targetGuiParent = nil
if type(gethui) == "function" then
    targetGuiParent = gethui()
elseif pcall(function() return CoreGui.Name end) then
    targetGuiParent = CoreGui
else
    targetGuiParent = localPlayer:WaitForChild("PlayerGui", 10)
end

-- Hapus versi lama jika ada saat re-execute
local oldGui = targetGuiParent:FindFirstChild("LaperGankAdminTeleport")
if oldGui then oldGui:Destroy() end

-- =============================================================================
-- 2. STATE & SETTINGS
-- =============================================================================
local selectedPlayer = nil
local isTeleporting = false

local EspSettings = {
    GeneratorAura = false,
    StatusOverlay = true
}

local AuraContainer = Instance.new("Folder")
AuraContainer.Name = "LaperGank_Auras"
AuraContainer.Parent = workspace

-- =============================================================================
-- 3. CORE UTILITIES
-- =============================================================================
local function makeDraggable(gui, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
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
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function getPlayerStatus(player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return "Dead" end
    local char = player.Character
    local hum = char.Humanoid
    
    if char:FindFirstChild("Hooked") or char:FindFirstChild("Sacrificed") or hum.PlatformStand then
        return "Hooked"
    end
    if hum.Health <= 0 then
        return "Dead"
    elseif hum.Health < 30 or char:FindFirstChild("Bleeding") or hum.WalkSpeed < 8 then
        return "Bleeding"
    elseif hum.Health < 100 then
        return "Injured"
    end
    return "Healthy"
end

-- =============================================================================
-- 4. UI GENERATION
-- =============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaperGankAdminTeleport"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGuiParent

-- MAIN CONTAINER
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 240)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- TOPBAR FRAME
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 10)
topBarCover.Position = UDim2.new(0, 0, 1, -10)
topBarCover.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

makeDraggable(mainFrame, topBar)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LAPER GANK ADMIN"
title.TextColor3 = Color3.fromRGB(255, 60, 60)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- BUTTONS: CLOSE & MINIMIZE
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -27, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -54, 0.5, -11)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = topBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

-- DROPDOWN TARGET SELECTION
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 35)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 48)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
dropdownBtn.Text = "Pilih Target..."
dropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
dropdownBtn.Font = Enum.Font.GothamMedium
dropdownBtn.TextSize = 12
dropdownBtn.Parent = mainFrame
Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6)

-- EXECUTE BUTTON
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.9, 0, 0, 35)
teleportBtn.Position = UDim2.new(0.05, 0, 0, 90)
teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
teleportBtn.Text = "EXECUTE TELEPORT"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 12
teleportBtn.Parent = mainFrame
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 6)

-- UTILITIES PANEL (Auras)
local utilityFrame = Instance.new("Frame")
utilityFrame.Size = UDim2.new(0.9, 0, 0, 90)
utilityFrame.Position = UDim2.new(0.05, 0, 0, 135)
utilityFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
utilityFrame.BorderSizePixel = 0
utilityFrame.Parent = mainFrame
Instance.new("UICorner", utilityFrame).CornerRadius = UDim.new(0, 6)

local toggleGenBtn = Instance.new("TextButton")
toggleGenBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleGenBtn.Position = UDim2.new(0.05, 0, 0, 10)
toggleGenBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
toggleGenBtn.Text = "OBJECTIVE AURA: OFF"
toggleGenBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleGenBtn.Font = Enum.Font.GothamBold
toggleGenBtn.TextSize = 11
toggleGenBtn.Parent = utilityFrame
Instance.new("UICorner", toggleGenBtn).CornerRadius = UDim.new(0, 5)

local toggleStatusBtn = Instance.new("TextButton")
toggleStatusBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleStatusBtn.Position = UDim2.new(0.05, 0, 0, 48)
toggleStatusBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
toggleStatusBtn.Text = "STATUS OVERLAY: ON"
toggleStatusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleStatusBtn.Font = Enum.Font.GothamBold
toggleStatusBtn.TextSize = 11
toggleStatusBtn.Parent = utilityFrame
Instance.new("UICorner", toggleStatusBtn).CornerRadius = UDim.new(0, 5)

-- SCROLLING PLAYER LIST
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 130)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 85)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.Visible = false
scrollFrame.ZIndex = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.Parent = scrollFrame

-- MINIMIZE ICON
local minIcon = Instance.new("ImageButton")
minIcon.Size = UDim2.new(0, 50, 0, 50)
minIcon.Position = UDim2.new(0.5, -25, 0.8, -25)
minIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
minIcon.Image = "rbxassetid://128042443413755"
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false
minIcon.ZIndex = 100
minIcon.Parent = screenGui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1, 0)
makeDraggable(minIcon, minIcon)

-- =============================================================================
-- 5. LOGIC & MECHANICS
-- =============================================================================

local function updatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local pStatus = getPlayerStatus(player)
            local statusColor = Color3.fromRGB(255, 255, 255)
            local textSuffix = ""
            
            if EspSettings.StatusOverlay then
                if pStatus == "Hooked" then
                    statusColor = Color3.fromRGB(255, 0, 0)
                    textSuffix = " [HOOKED]"
                elseif pStatus == "Bleeding" then
                    statusColor = Color3.fromRGB(255, 140, 0)
                    textSuffix = " [DOWNED]"
                elseif pStatus == "Injured" then
                    statusColor = Color3.fromRGB(255, 255, 100)
                    textSuffix = " [INJURED]"
                elseif pStatus == "Dead" then
                    statusColor = Color3.fromRGB(100, 100, 100)
                    textSuffix = " [DEAD]"
                end
            end
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
            btn.Text = "  " .. player.Name .. textSuffix
            btn.TextColor3 = statusColor
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 6
            btn.Parent = scrollFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = player
                dropdownBtn.Text = player.Name .. textSuffix
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
            highlight.Name = "GeneratorAura"
            highlight.Adornee = obj
            
            local isWorking = obj:FindFirstChild("Progress") or obj:FindFirstChild("Active")
            highlight.FillColor = isWorking and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(0, 180, 255)
            
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0.1
            highlight.Parent = AuraContainer
        end
    end
end

RunService.Heartbeat:Connect(function()
    if EspSettings.GeneratorAura then
        for _, highlight in ipairs(AuraContainer:GetChildren()) do
            if highlight:IsA("Highlight") and highlight.Adornee then
                local obj = highlight.Adornee
                if obj:FindFirstChild("Working") or (obj:FindFirstChild("Progress") and obj.Progress.Value > 0) then
                    highlight.FillColor = Color3.fromRGB(0, 255, 100)
                end
            end
        end
    end
end)

-- =============================================================================
-- 6. CONNECTIONS & BINDS
-- =============================================================================

closeBtn.MouseButton1Click:Connect(function() 
    AuraContainer:Destroy()
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minIcon.Visible = true
    minIcon.Position = mainFrame.Position
end)

minIcon.MouseButton1Click:Connect(function()
    minIcon.Visible = false
    mainFrame.Visible = true
    mainFrame.Position = minIcon.Position
end)

dropdownBtn.MouseButton1Click:Connect(function()
    if isTeleporting then return end
    scrollFrame.Visible = not scrollFrame.Visible
    if scrollFrame.Visible then updatePlayerList() end
end)

toggleGenBtn.MouseButton1Click:Connect(function()
    EspSettings.GeneratorAura = not EspSettings.GeneratorAura
    if EspSettings.GeneratorAura then
        toggleGenBtn.Text = "OBJECTIVE AURA: ON"
        toggleGenBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        toggleGenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyObjectiveAuras()
    else
        toggleGenBtn.Text = "OBJECTIVE AURA: OFF"
        toggleGenBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        toggleGenBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        AuraContainer:ClearAllChildren()
    end
end)

toggleStatusBtn.MouseButton1Click:Connect(function()
    EspSettings.StatusOverlay = not EspSettings.StatusOverlay
    if EspSettings.StatusOverlay then
        toggleStatusBtn.Text = "STATUS OVERLAY: ON"
        toggleStatusBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        toggleStatusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleStatusBtn.Text = "STATUS OVERLAY: OFF"
        toggleStatusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        toggleStatusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    if scrollFrame.Visible then updatePlayerList() end
end)

teleportBtn.MouseButton1Click:Connect(function()
    if isTeleporting then return end
    
    if not selectedPlayer or not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        dropdownBtn.Text = "Target Tidak Ditemukan!"
        dropdownBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
        task.wait(1.5)
        dropdownBtn.Text = "Pilih Target..."
        dropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        selectedPlayer = nil
        return
    end
    
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    isTeleporting = true
    scrollFrame.Visible = false
    teleportBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    
    -- Tactical Ticking Countdown
    for i = 3, 1, -1 do
        teleportBtn.Text = "TELEPORTING IN " .. i .. "s..."
        task.wait(1)
    end
    
    -- Final Check before execution
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
        myChar.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, 3)
    end
    
    teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    teleportBtn.Text = "EXECUTE TELEPORT"
    dropdownBtn.Text = "Pilih Target..."
    dropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectedPlayer = nil
    isTeleporting = false
end)
