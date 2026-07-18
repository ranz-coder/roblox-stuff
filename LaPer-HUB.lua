-- =============================================================================
-- PROJECT NAME: Laper Gank Admin TP - List Edition & Sibling Layering
-- =============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local selectedPlayer = nil
local isTeleporting = false

local EspSettings = {
    GeneratorAura = false,
    StatusOverlay = true
}

local AuraContainer = workspace:FindFirstChild("LaperGank_Auras")
if not AuraContainer then
    AuraContainer = Instance.new("Folder")
    AuraContainer.Name = "LaperGank_Auras"
    AuraContainer.Parent = workspace
end

-- -----------------------------------------------------------------------------
-- FUNGSI DRAGGABLE
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- GUI SETUP (MENGGUNAKAN NATURAL HIERARCHY / TANPA ZINDEX)
-- -----------------------------------------------------------------------------
local targetParent = type(gethui) == "function" and gethui() or CoreGui
local oldGui = targetParent:FindFirstChild("LaperGankAdminTeleport")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaperGankAdminTeleport"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- SOLUSI TERBAIK PENGGANTI ZINDEX MANUAL
screenGui.Parent = targetParent

-- MAIN FRAME (Diperbesar untuk menampung List)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 310) 
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- TOP BAR (Untuk Drag)
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

-- JUDUL
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

-- TOMBOL CLOSE & MINIMIZE
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

-- PERMANENT PLAYER LIST (Menggantikan Dropdown)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 120)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 45)
scrollFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.Parent = scrollFrame

-- EXECUTE TELEPORT BUTTON
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.9, 0, 0, 35)
teleportBtn.Position = UDim2.new(0.05, 0, 0, 175)
teleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) -- Default Redup
teleportBtn.Text = "PILIH PEMAIN DI LIST"
teleportBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 12
teleportBtn.Parent = mainFrame
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 6)

-- UTILITY FRAME (Aura & Status)
local utilityFrame = Instance.new("Frame")
utilityFrame.Size = UDim2.new(0.9, 0, 0, 80)
utilityFrame.Position = UDim2.new(0.05, 0, 0, 220)
utilityFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
utilityFrame.BorderSizePixel = 0
utilityFrame.Parent = mainFrame
Instance.new("UICorner", utilityFrame).CornerRadius = UDim.new(0, 6)

local toggleGenBtn = Instance.new("TextButton")
toggleGenBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleGenBtn.Position = UDim2.new(0.05, 0, 0, 8)
toggleGenBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
toggleGenBtn.Text = "OBJECTIVE AURA: OFF"
toggleGenBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleGenBtn.Font = Enum.Font.GothamBold
toggleGenBtn.TextSize = 11
toggleGenBtn.Parent = utilityFrame
Instance.new("UICorner", toggleGenBtn).CornerRadius = UDim.new(0, 5)

local toggleStatusBtn = Instance.new("TextButton")
toggleStatusBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleStatusBtn.Position = UDim2.new(0.05, 0, 0, 42)
toggleStatusBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
toggleStatusBtn.Text = "STATUS OVERLAY: ON"
toggleStatusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleStatusBtn.Font = Enum.Font.GothamBold
toggleStatusBtn.TextSize = 11
toggleStatusBtn.Parent = utilityFrame
Instance.new("UICorner", toggleStatusBtn).CornerRadius = UDim.new(0, 5)

-- MINIMIZE ICON DENGAN LOGO YANG DIMINTA
local minIcon = Instance.new("ImageButton")
minIcon.Size = UDim2.new(0, 50, 0, 50)
minIcon.Position = UDim2.new(0.5, -25, 0.8, -25)
minIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
minIcon.Image = "rbxassetid://128042443413755" -- << ASSET ID SUDAH TERPASANG
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false
minIcon.Parent = screenGui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1, 0)

makeDraggable(minIcon, minIcon)

-- -----------------------------------------------------------------------------
-- SISTEM LOGIKA & UPDATE LIST OTOMATIS
-- -----------------------------------------------------------------------------
local function getPlayerStatus(player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return "Dead" end
    local hum = player.Character.Humanoid
    if player.Character:FindFirstChild("Hooked") or hum.PlatformStand then return "Hooked" end
    if hum.Health <= 0 then return "Dead" end
    if hum.Health < 30 or hum.WalkSpeed < 8 then return "Bleeding" end
    if hum.Health < 100 then return "Injured" end
    return "Healthy"
end

local function updatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local statusColor = Color3.fromRGB(255, 255, 255)
            local textSuffix = ""
            
            if EspSettings.StatusOverlay then
                local pStatus = getPlayerStatus(player)
                if pStatus == "Hooked" then statusColor = Color3.fromRGB(255, 0, 0) textSuffix = " [HOOKED]"
                elseif pStatus == "Bleeding" then statusColor = Color3.fromRGB(255, 140, 0) textSuffix = " [DOWNED]"
                elseif pStatus == "Injured" then statusColor = Color3.fromRGB(255, 255, 100) textSuffix = " [INJURED]" end
            end
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            btn.Text = "  " .. player.Name .. textSuffix
            btn.TextColor3 = statusColor
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scrollFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            -- Ketika nama di list diklik
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = player
                
                -- Highlight list yang dipilih
                for _, b in ipairs(scrollFrame:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(45, 45, 50) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                
                -- Aktifkan Tombol Teleport
                teleportBtn.Text = "TELEPORT KE: " .. player.Name
                teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end
    end
end

-- Refresh List saat ada yang masuk/keluar
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList() -- Panggil pertama kali

-- -----------------------------------------------------------------------------
-- BINDING TOMBOL
-- -----------------------------------------------------------------------------
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

toggleGenBtn.MouseButton1Click:Connect(function()
    EspSettings.GeneratorAura = not EspSettings.GeneratorAura
    if EspSettings.GeneratorAura then
        toggleGenBtn.Text = "OBJECTIVE AURA: ON"
        toggleGenBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        toggleGenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    updatePlayerList()
end)

teleportBtn.MouseButton1Click:Connect(function()
    if isTeleporting or not selectedPlayer then return end
    
    local targetChar = selectedPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
        teleportBtn.Text = "TARGET HILANG!"
        teleportBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        task.wait(1.5)
        teleportBtn.Text = "PILIH PEMAIN DI LIST"
        teleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        selectedPlayer = nil
        return
    end
    
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    isTeleporting = true
    teleportBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    
    for i = 3, 1, -1 do
        teleportBtn.Text = "MENYIAPKAN TP " .. i .. "..."
        task.wait(1)
    end
    
    if selectedPlayer and targetChar:FindFirstChild("HumanoidRootPart") then
        myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
    
    teleportBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    teleportBtn.Text = "TELEPORT KE: " .. selectedPlayer.Name
    isTeleporting = false
end)
