-- =============================================================================
-- PROJECT NAME: Laper Gank Hub - Android Dasbor Mobile Edition
-- AESTHETIC: Dark Grey Base, Vibrant Purple & Blue Neon Accents
-- OPTIMIZATION: Delta Executor Native Compatibility (Anti-Blank Layer)
-- =============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local selectedPlayer = nil
local isTeleporting = false

local ESPSettings = {
	Box = false,
	Name = false
}

-- -----------------------------------------------------------------------------
-- [1] NOTIFIKASI SYSTEM & EXECUTOR PROTECTION
-- -----------------------------------------------------------------------------
local function showNotification(title, text, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = duration or 5
		})
	end)
end

local isSupported = true
if not isSupported then
	showNotification("LaperGank", "LaperGank gak mendukung", 5)
	return
end

-- Delta Mobile Touch Drag Handler
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
-- [2] RENDERING ANDROID MOBILE DASHBOARD HUD
-- -----------------------------------------------------------------------------
local targetParent = type(gethui) == "function" and gethui() or CoreGui
local oldGui = targetParent:FindFirstChild("LaperGankAdminTeleport")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaperGankAdminTeleport"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = targetParent

showNotification("LaperGank", "LaperGank mendukung", 5)

-- Main Frame (Latar Abu-abu Gelap)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 340)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Aksen Garis Tepi Ungu Mencolok
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(138, 43, 226)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Top Bar Header
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 10)
topBarCover.Position = UDim2.new(0, 0, 1, -10)
topBarCover.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

makeDraggable(mainFrame, topBar)

-- Judul Aplikasi (Aksen Biru Neon)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LAPER GANK HUB"
title.TextColor3 = Color3.fromRGB(0, 191, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Tombol Kontrol Aksi (Android Style)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -58, 0.5, -12)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Parent = topBar

-- Kisi Pusat Naskah Berbasis Kartu (Permanent Player List)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 130)
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
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = scrollFrame
Instance.new("UIPadding", scrollFrame).PaddingTop = UDim.new(0, 4)

-- Kisi Tombol Kontrol Melayang
local actionGrid = Instance.new("Frame")
actionGrid.Size = UDim2.new(0.9, 0, 0, 140)
actionGrid.Position = UDim2.new(0.05, 0, 0, 190)
actionGrid.BackgroundTransparency = 1
actionGrid.Parent = mainFrame

local uiListAction = Instance.new("UIListLayout")
uiListAction.SortOrder = Enum.SortOrder.LayoutOrder
uiListAction.Padding = UDim.new(0, 8)
uiListAction.Parent = actionGrid

-- Tombol Teleport Utama (Aksen Biru)
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, 0, 0, 38)
teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
teleportBtn.Text = "PILIH TARGET DI KISI"
teleportBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 12
teleportBtn.LayoutOrder = 1
teleportBtn.Parent = actionGrid
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 8)
local tpStroke = Instance.new("UIStroke")
tpStroke.Color = Color3.fromRGB(0, 191, 255)
tpStroke.Thickness = 1
tpStroke.Parent = teleportBtn

-- Tombol Toggle ESP Box (Aksen Ungu)
local espBoxBtn = Instance.new("TextButton")
espBoxBtn.Size = UDim2.new(1, 0, 0, 34)
espBoxBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
espBoxBtn.Text = "TOGGLE ESP BOX: OFF"
espBoxBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
espBoxBtn.Font = Enum.Font.GothamBold
espBoxBtn.TextSize = 11
espBoxBtn.LayoutOrder = 2
espBoxBtn.Parent = actionGrid
Instance.new("UICorner", espBoxBtn).CornerRadius = UDim.new(0, 8)
local boxStroke = Instance.new("UIStroke")
boxStroke.Color = Color3.fromRGB(138, 43, 226)
boxStroke.Thickness = 1
boxStroke.Parent = espBoxBtn

-- Tombol Toggle ESP Username (Aksen Ungu)
local espNameBtn = Instance.new("TextButton")
espNameBtn.Size = UDim2.new(1, 0, 0, 34)
espNameBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
espNameBtn.Text = "TOGGLE USERNAME ESP: OFF"
espNameBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
espNameBtn.Font = Enum.Font.GothamBold
espNameBtn.TextSize = 11
espNameBtn.LayoutOrder = 3
espNameBtn.Parent = actionGrid
Instance.new("UICorner", espNameBtn).CornerRadius = UDim.new(0, 8)
local nameStroke = Instance.new("UIStroke")
nameStroke.Color = Color3.fromRGB(138, 43, 226)
nameStroke.Thickness = 1
nameStroke.Parent = espNameBtn

-- Floating Minimize Icon (Menggunakan Aset Yang Diminta)
local minIcon = Instance.new("ImageButton")
minIcon.Size = UDim2.new(0, 50, 0, 50)
minIcon.Position = UDim2.new(0.5, -25, 0.8, -25)
minIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
minIcon.Image = "rbxassetid://128042443413755"
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false
minIcon.Active = true
minIcon.Parent = screenGui
Instance.new("UICorner", minIcon).CornerRadius = UDim.new(1, 0)
local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(0, 191, 255)
iconStroke.Thickness = 2
iconStroke.Parent = minIcon

makeDraggable(minIcon, minIcon)

-- -----------------------------------------------------------------------------
-- [3] MEKANIK INTERAKSI & DYNAMIC LOGIC MAPPING
-- -----------------------------------------------------------------------------

-- Sinkronisasi Pembaruan Kartu Player Aktif
local function updatePlayerList()
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local card = Instance.new("TextButton")
			card.Size = UDim2.new(0.95, 0, 0, 32)
			card.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
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
					if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(35, 35, 38) end
				end
				card.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Highlight Ungu saat dipilih
				teleportBtn.Text = "TELEPORT KE: " .. string.upper(player.Name)
				teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
		end
	end
end

-- Sistem ESP Ringan (Anti-Crash Execution Thread)
local function executeLightweightESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Character then
			local char = p.Character
			
			-- Integrasi Box ESP (Highlight Element)
			if ESPSettings.Box then
				if not char:FindFirstChild("LaperBox") then
					local hl = Instance.new("Highlight")
					hl.Name = "LaperBox"
					hl.FillColor = Color3.fromRGB(138, 43, 226)
					hl.OutlineColor = Color3.fromRGB(0, 191, 255)
					hl.FillTransparency = 0.5
					hl.OutlineTransparency = 0.1
					hl.Parent = char
				end
			else
				local hl = char:FindFirstChild("LaperBox")
				if hl then hl:Destroy() end
			end
			
			-- Integrasi Username ESP (Billboard Frame Element)
			if ESPSettings.Name then
				local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
				if head and not head:FindFirstChild("LaperName") then
					local bb = Instance.new("BillboardGui")
					bb.Name = "LaperName"
					bb.Size = UDim2.new(0, 180, 0, 40)
					bb.StudsOffset = Vector3.new(0, 2.5, 0)
					bb.AlwaysOnTop = true
					
					local txt = Instance.new("TextLabel")
					txt.Size = UDim2.new(1, 0, 1, 0)
					txt.BackgroundTransparency = 1
					txt.Text = p.Name
					txt.TextColor3 = Color3.fromRGB(0, 191, 255)
					txt.TextStrokeTransparency = 0.2
					txt.Font = Enum.Font.GothamBlack
					txt.TextSize = 11
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
end

-- -----------------------------------------------------------------------------
-- [4] ISOLASI DRIVER BUTTON LISTENERS (MOBILE ACTIVATED BINDING)
-- -----------------------------------------------------------------------------
closeBtn.Activated:Connect(function()
	ESPSettings.Box = false
	ESPSettings.Name = false
	pcall(function()
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				if p.Character:FindFirstChild("LaperBox") then p.Character.LaperBox:Destroy() end
				local h = p.Character:FindFirstChild("Head")
				if h and h:FindFirstChild("LaperName") then h.LaperName:Destroy() end
			end
		end
	end)
	screenGui:Destroy()
end)

minBtn.Activated:Connect(function()
	mainFrame.Visible = false
	minIcon.Visible = true
	minIcon.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + 105, 0, mainFrame.AbsolutePosition.Y + 145)
end)

minIcon.Activated:Connect(function()
	minIcon.Visible = false
	mainFrame.Visible = true
end)

espBoxBtn.Activated:Connect(function()
	ESPSettings.Box = not ESPSettings.Box
	espBoxBtn.Text = ESPSettings.Box and "TOGGLE ESP BOX: ON" or "TOGGLE ESP BOX: OFF"
	espBoxBtn.TextColor3 = ESPSettings.Box and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(200, 200, 200)
end)

espNameBtn.Activated:Connect(function()
	ESPSettings.Name = not ESPSettings.Name
	espNameBtn.Text = ESPSettings.Name and "TOGGLE USERNAME ESP: ON" or "TOGGLE USERNAME ESP: OFF"
	espNameBtn.TextColor3 = ESPSettings.Name and Color3.fromRGB(0, 191, 255) or Color3.fromRGB(200, 200, 200)
end)

-- Driver Script Teleport Asli dengan Countdown 3 Detik
teleportBtn.Activated:Connect(function()
	if isTeleporting or not selectedPlayer then return end
	
	if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
		teleportBtn.Text = "TARGET TIDAK DITEMUKAN!"
		task.wait(1.5)
		teleportBtn.Text = "PILIH TARGET DI KISI"
		return
	end
	
	local myChar = localPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	
	isTeleporting = true
	teleportBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
	
	for i = 3, 1, -1 do
		teleportBtn.Text = "TELEPORTING IN " .. i .. "s..."
		task.wait(1)
	end
	
	if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
		local targetCFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
		myChar.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, 3)
	else
		showNotification("LaperGank Error", "Gagal memuat koordinat target!", 3)
	end
	
	teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	teleportBtn.Text = "TELEPORT KE: " .. string.upper(selectedPlayer.Name)
	selectedPlayer = nil
	isTeleporting = false
end)

-- RUNNER SYSTEM INITIALIZATION (Isolasi Terakhir agar aman dari Interupsi Loader)
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

RunService.Heartbeat:Connect(function()
	pcall(executeLightweightESP)
end)
