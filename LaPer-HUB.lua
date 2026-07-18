-- =============================================================================
-- VIOLENCE DISTRICT — ADMIN GUI (Full Local Client - FIXED)
-- Taruh di: StarterPlayerScripts (sebagai LocalScript)
-- =============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- -----------------------------------------------------------------------------
-- PALET WARNA & ASSETS
-- -----------------------------------------------------------------------------
local COLOR_BG        = Color3.fromRGB(24, 24, 28)
local COLOR_CARD      = Color3.fromRGB(34, 34, 40)
local COLOR_CARD_HOVER= Color3.fromRGB(44, 42, 54)
local COLOR_PURPLE    = Color3.fromRGB(139, 92, 246)
local COLOR_BLUE      = Color3.fromRGB(59, 130, 246)
local COLOR_TEXT      = Color3.fromRGB(235, 235, 240)
local COLOR_SUBTEXT   = Color3.fromRGB(150, 150, 160)
local COLOR_DANGER    = Color3.fromRGB(239, 68, 68)

-- Asset ID untuk icon minimize sesuai permintaan
local MINIMIZE_ICON_ID = "rbxassetid://128042443413755"

-- -----------------------------------------------------------------------------
-- STATE GLOBAL
-- -----------------------------------------------------------------------------
local selectedPlayerName = nil
local espBoxOn, espNameOn = false, false
local activeESPs = {}

-- -----------------------------------------------------------------------------
-- ROOT GUI
-- -----------------------------------------------------------------------------
-- Hapus GUI lama jika ada (untuk keperluan testing/re-run script)
local oldGui = playerGui:FindFirstChild("VD_AdminGUI_Local")
if oldGui then oldGui:Destroy() end

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
-- HELPER UTILITY
-- -----------------------------------------------------------------------------
local function corner(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = inst
	return c
end

-- Fungsi Drag yang diperbaiki agar lebih responsif
local function enableDrag(dragHandle, moveFrame)
	local dragging, dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = moveFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
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
			moveFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- =============================================================================
-- BUAT ELEMEN GUI (Urutan disesuaikan agar referensi tombol valid)
-- =============================================================================

-- 1. FLOATING MINIMIZE ICON (Dibuat dulu agar bisa direferensikan di fungsi panel)
local minIcon = Instance.new("ImageButton")
minIcon.Name = "MinimizeIcon"
-- Ukuran disesuaikan permintaan: 0, 50, 0, 50
minIcon.Size = UDim2.new(0, 50, 0, 50)
-- Posisi default di kanan bawah
minIcon.Position = UDim2.new(1, -70, 1, -70)
minIcon.BackgroundColor3 = COLOR_BG
minIcon.Image = MINIMIZE_ICON_ID
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.Visible = false -- Sembunyi di awal
minIcon.Active = true
minIcon.ZIndex = 10
minIcon.Parent = gui
corner(minIcon, 25) -- Membuatnya bulat

local minIconStroke = Instance.new("UIStroke")
minIconStroke.Color = COLOR_PURPLE
minIconStroke.Thickness = 2
minIconStroke.Parent = minIcon

-- Fallback text jika image tidak load
local minIconLabel = Instance.new("TextLabel")
minIconLabel.Size = UDim2.new(1, 0, 1, 0)
minIconLabel.BackgroundTransparency = 1
minIconLabel.Text = "VD"
minIconLabel.Font = Enum.Font.GothamBold
minIconLabel.TextSize = 14
minIconLabel.TextColor3 = COLOR_TEXT
minIconLabel.ZIndex = 11
minIconLabel.Visible = (minIcon.Image == "")
minIconLabel.Parent = minIcon

enableDrag(minIcon, minIcon)

-- 2. MAIN ADMIN PANEL
local panel = Instance.new("Frame")
panel.Name = "AdminPanel"
panel.Size = UDim2.new(0, 260, 0, 380)
panel.Position = UDim2.new(0.5, -130, 0.5, -190)
panel.BackgroundColor3 = COLOR_BG
panel.BorderSizePixel = 0
panel.Active = true
panel.Visible = true -- Langsung muncul
panel.Parent = gui
corner(panel, 16)

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = COLOR_BLUE
panelStroke.Thickness = 1
panelStroke.Transparency = 0.5
panelStroke.Parent = panel

-- TOP BAR (drag handle)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = COLOR_CARD
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.Parent = panel
corner(topBar, 16)

local topBarCover = Instance.new("Frame") -- Menutup corner bawah topbar
topBarCover.Size = UDim2.new(1, 0, 0, 12)
topBarCover.Position = UDim2.new(0, 0, 1, -12)
topBarCover.BackgroundColor3 = COLOR_CARD
topBarCover.BorderSizePixel = 0
topBarCover.ZIndex = 1
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
title.ZIndex = 2
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.ZIndex = 2
closeBtn.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -68, 0.5, -15)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.ZIndex = 2
minBtn.Parent = topBar

enableDrag(topBar, panel) -- Aktifkan drag pada topbar

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
scrollFrame.Name = "PlayerListScroll"
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
teleportBtn.Name = "TeleportBtn"
teleportBtn.Size = UDim2.new(1, -28, 0, 40)
teleportBtn.Position = UDim2.new(0, 14, 0, 222)
teleportBtn.BackgroundColor3 = COLOR_CARD
teleportBtn.Text = "SELECT A PLAYER"
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 12
teleportBtn.TextColor3 = COLOR_SUBTEXT
teleportBtn.AutoButtonColor = true
teleportBtn.Parent = panel
corner(teleportBtn, 10)

-- ESP TOGGLES
local espBoxBtn = Instance.new("TextButton")
espBoxBtn.Name = "EspBoxBtn"
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
espNameBtn.Name = "EspNameBtn"
espNameBtn.Size = UDim2.new(1, -28, 0, 38)
espNameBtn.Position = UDim2.new(0, 14, 0, 314)
espNameBtn.BackgroundColor3 = COLOR_CARD
espNameBtn.Text = "ESP NAME: OFF"
espNameBtn.Font = Enum.Font.GothamBold
espNameBtn.TextSize = 12
espNameBtn.TextColor3 = COLOR_SUBTEXT
espNameBtn.Parent = panel
corner(espNameBtn, 10)

-- -----------------------------------------------------------------------------
-- LOGIKA FUNGSI (Lokal Client)
-- -----------------------------------------------------------------------------

-- 1. Refresh Daftar Pemain
local function refreshPlayerList()
	-- Bersihkan list lama
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	selectedPlayerName = nil
	teleportBtn.Text = "SELECT A PLAYER"
	teleportBtn.BackgroundColor3 = COLOR_CARD
	teleportBtn.TextColor3 = COLOR_SUBTEXT

	-- Buat list baru
	for _, ply in ipairs(Players:GetPlayers()) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(1, 0, 0, 32)
		card.BackgroundColor3 = COLOR_CARD_HOVER
		card.Text = "  " .. ply.Name
		card.TextColor3 = COLOR_TEXT
		card.Font = Enum.Font.GothamMedium
		card.TextSize = 12
		card.TextXAlignment = Enum.TextXAlignment.Left
		card.AutoButtonColor = true
		card.Parent = scrollFrame
		corner(card, 8)

		card.Activated:Connect(function()
			selectedPlayerName = ply.Name
			-- Reset warna card lain
			for _, child in ipairs(scrollFrame:GetChildren()) do
				if child:IsA("TextButton") then child:BackgroundColor3 = COLOR_CARD_HOVER end
			end
			-- Highlight card ini
			card.BackgroundColor3 = COLOR_PURPLE
			-- Update tombol teleport
			teleportBtn.Text = "TELEPORT TO " .. ply.Name
			teleportBtn.BackgroundColor3 = COLOR_PURPLE
			teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
	end
end

-- 2. ESP System
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

	local objects = {}

	-- ESP BOX (Highlight)
	if espBoxOn then
		local hl = Instance.new("Highlight")
		hl.FillColor = COLOR_PURPLE
		hl.OutlineColor = COLOR_BLUE
		hl.FillTransparency = 0.6
		hl.OutlineTransparency = 0
		hl.Adornee = char
		hl.Parent = espFolder
		table.insert(objects, hl)
	end

	-- ESP NAME (BillboardGui)
	if espNameOn then
		local head = char:FindFirstChild("Head")
		if head then
			local bgui = Instance.new("BillboardGui")
			bgui.Name = "ESPName"
			bgui.Adornee = head
			bgui.Size = UDim2.new(0, 100, 0, 30)
			bgui.StudsOffset = Vector3.new(0, 2.5, 0)
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
			table.insert(objects, bgui)
		end
	end
	
	if #objects > 0 then activeESPs[player.Name] = objects end
end

local function updateAllESP()
	for _, p in ipairs(Players:GetPlayers()) do
		applyESP(p)
	end
end

-- -----------------------------------------------------------------------------
-- SETUP EVENTS & INTERACTIONS
-- -----------------------------------------------------------------------------

-- Tombol Close
closeBtn.Activated:Connect(function()
	print("Closing GUI")
	gui:Destroy() -- Menghapus seluruh GUI dari player
	-- Matikan ESP jika GUI dihancurkan
	espBoxOn = false
	espNameOn = false
	activeESPs = {}
	espFolder:ClearAllChildren()
end)

-- Tombol Minimize
minBtn.Activated:Connect(function()
	print("Minimizing GUI")
	panel.Visible = false
	minIcon.Visible = true
end)

-- Tombol Restore (Icon Kecil)
minIcon.Activated:Connect(function()
	print("Restoring GUI")
	minIcon.Visible = false
	panel.Visible = true
end)

-- Tombol Teleport
teleportBtn.Activated:Connect(function()
	if not selectedPlayerName then return end
	local targetPlayer = Players:FindFirstChild(selectedPlayerName)
	local myChar = localPlayer.Character
	
	if targetPlayer and targetPlayer.Character and myChar then
		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		
		if myRoot and targetRoot then
			-- Teleport ke target dengan offset sedikit di depan agar tidak stuck
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
			print("Teleported to " .. selectedPlayerName)
		end
	else
		teleportBtn.Text = "TARGET INVALID"
		teleportBtn.BackgroundColor3 = COLOR_DANGER
		task.wait(1)
		refreshPlayerList() -- reset state
	end
end)

-- Tombol ESP Box
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

-- Tombol ESP Name
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

-- Player Events
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
	clearESP(player)
	refreshPlayerList()
end)

-- Character Events (untuk update ESP saat respawn)
local function hookCharacter(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5) -- Tunggu karakter load penuh
		if espBoxOn or espNameOn then applyESP(player) end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	hookCharacter(p)
end
Players.PlayerAdded:Connect(hookCharacter)

-- -----------------------------------------------------------------------------
-- INITIALIZATION
-- -----------------------------------------------------------------------------
task.spawn(function()
	print("VD Admin GUI Loaded")
	refreshPlayerList() -- Isi daftar pemain segera setelah GUI dibuat
end)
