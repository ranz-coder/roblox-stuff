local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer

-- Fungsi Notifikasi Bawaan Asli Anda
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

-- Deteksi Parent UI yang Aman untuk Delta (Bypass Freeze/Blank Screen)
local targetParent = type(gethui) == "function" and gethui() or CoreGui
if not targetParent or not pcall(function() return targetParent.Name end) then
	targetParent = localPlayer:WaitForChild("PlayerGui")
end

-- Bersihkan Sisa Instansi GUI Lama
local oldGui = targetParent:FindFirstChild("LaperGankAdminTeleport")
if oldGui then oldGui:Destroy() end

-- Inisialisasi ScreenGui Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaperGankAdminTeleport"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = targetParent

showNotification("LaperGank", "LaperGank mendukung", 5)

-- -----------------------------------------------------------------------------
-- MODUL TOUCH DRAG (Dioptimalkan Khusus HP Android)
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
-- DESAIN DASBOR ANDROID MOBILE HUD
-- -----------------------------------------------------------------------------

-- Frame Utama (Latar Abu-abu Gelap Ramping)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 200)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Aksen Garis Tepi Ungu Neon Mencolok
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(138, 43, 226)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Top Bar Header
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 38)
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

-- Tombol Kontrol Android Style (Menggunakan .Activated)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -56, 0.5, -12)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.Parent = topBar

-- Dropdown Pilihan Player (Aksen Biru Neon)
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 38)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 52)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
dropdownBtn.Text = "Pilih Target..."
dropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
dropdownBtn.Font = Enum.Font.GothamMedium
dropdownBtn.TextSize = 13
dropdownBtn.Parent = mainFrame
Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 8)
local dropStroke = Instance.new("UIStroke")
dropStroke.Color = Color3.fromRGB(0, 191, 255)
dropStroke.Thickness = 1
dropStroke.Parent = dropdownBtn

-- Tombol Teleport Utama (Aksen Ungu Neon)
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.9, 0, 0, 38)
teleportBtn.Position = UDim2.new(0.05, 0, 0, 102)
teleportBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
teleportBtn.Text = "EXECUTE TELEPORT"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 13
teleportBtn.Parent = mainFrame
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 8)
local telStroke = Instance.new("UIStroke")
telStroke.Color = Color3.fromRGB(138, 43, 226)
telStroke.Thickness = 1
telStroke.Parent = teleportBtn

-- Scrolling Frame Kisi Naskah Berbasis Kartu Daftar Player
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 110)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 95)
scrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.Visible = false
scrollFrame.ZIndex = 5
scrollFrame.Active = true
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)
local scrollStroke = Instance.new("UIStroke")
scrollStroke.Color = Color3.fromRGB(0, 191, 255)
scrollStroke.Thickness = 1
scrollStroke.Parent = scrollFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.Name
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = scrollFrame
Instance.new("UIPadding", scrollFrame).PaddingTop = UDim.new(0, 4)

-- Floating Minimize Icon (Menggunakan Aset Roblox Spesifik Anda)
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
-- SINKRONISASI AKTIVITAS DRIVER UTAMA (.ACTIVATED IMPLEMENTATION)
-- -----------------------------------------------------------------------------
local selectedPlayer = nil
local isTeleporting = false

closeBtn.Activated:Connect(function() 
	screenGui:Destroy() 
end)

minBtn.Activated:Connect(function()
	mainFrame.Visible = false
	minIcon.Visible = true
	minIcon.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + 105, 0, mainFrame.AbsolutePosition.Y + 75)
end)

minIcon.Activated:Connect(function()
	minIcon.Visible = false
	mainFrame.Visible = true
end)

-- Sinkronisasi Pengisian Kartu Player ke Dalam Kisi
local function updatePlayerList()
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0.95, 0, 0, 32)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			btn.Text = "  " .. player.Name
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 12
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.ZIndex = 6
			btn.Parent = scrollFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			
			btn.Activated:Connect(function()
				selectedPlayer = player
				dropdownBtn.Text = player.Name
				scrollFrame.Visible = false
			end)
		end
	end
end

dropdownBtn.Activated:Connect(function()
	if isTeleporting then return end
	scrollFrame.Visible = not scrollFrame.Visible
	if scrollFrame.Visible then updatePlayerList() end
end)

-- Sistem Driver Teleport INSTAN Tanpa Delay Detik
teleportBtn.Activated:Connect(function()
	if isTeleporting then return end
	
	if not selectedPlayer or not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
		dropdownBtn.Text = "Target Tidak Ditemukan!"
		task.wait(1.5)
		dropdownBtn.Text = "Pilih Target..."
		return
	end
	
	local myChar = localPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	
	isTeleporting = true
	scrollFrame.Visible = false
	
	-- Proses Instan Teleportasi Langsung (Seketika)
	if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
		local targetCFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
		myChar.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, 3)
	else
		showNotification("LaperGank Error", "Gagal memuat koordinat target!", 3)
	end
	
	-- Reset State Tombol Instan
	teleportBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	teleportBtn.Text = "EXECUTE TELEPORT"
	dropdownBtn.Text = "Pilih Target..."
	selectedPlayer = nil
	isTeleporting = false
end)
