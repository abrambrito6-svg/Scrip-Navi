--[[  Nexus-HUB | Brainrot -- By Navi  ]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local cfg = {
	esp = false,
	boxes = true,
	names = true,
	dist = true,
	espRange = 500,
	speed = false,
	speedVal = 60,
	noclip = false,
}

local function getRoot(plr)
	local ch = plr.Character
	if not ch then return nil end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	return ch:FindFirstChild("HumanoidRootPart")
end

-- ===== ESP =====
local espObj = {}

local function removeEsp(plr)
	local e = espObj[plr]
	if not e then return end
	for _, o in ipairs(e) do pcall(function() o:Destroy() end) end
	espObj[plr] = nil
end

local function clearEspAll()
	for plr in pairs(espObj) do removeEsp(plr) end
end

local function makeEsp(plr, root)
	local objs = {}

	local box = Instance.new("BoxHandleAdornment")
	box.Size = Vector3.new(3.2, 5.8, 3.2)
	box.Adornee = root
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Color3 = Color3.fromRGB(255, 165, 40)
	box.Transparency = 0.35
	box.Parent = root
	table.insert(objs, box)

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(180, 42)
	bb.StudsOffset = Vector3.new(0, 2.9, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = root
	bb.Parent = root

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.fromScale(1, 1)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.TextSize = 14
	txt.TextColor3 = Color3.fromRGB(255, 255, 255)
	txt.TextStrokeTransparency = 0.3
	txt.Text = plr.Name
	txt.Parent = bb
	table.insert(objs, bb)

	espObj[plr] = objs
	return objs
end

local function updateEsp()
	for plr in pairs(espObj) do
		if not plr.Parent or plr == LP or not getRoot(plr) then removeEsp(plr) end
	end
	local myRoot = getRoot(LP)
	if not myRoot then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and getRoot(plr) then
			local root = getRoot(plr)
			local d = math.floor((myRoot.Position - root.Position).Magnitude)
			if d <= cfg.espRange then
				local objs = espObj[plr]
				if not objs or objs[1].Adornee ~= root then
					removeEsp(plr)
					objs = makeEsp(plr, root)
				end
				objs[1].Visible = cfg.boxes
				objs[1].Color3 = (d <= 90) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 175, 45)
				objs[2].Enabled = cfg.names or cfg.dist
				local lbl = objs[2]:FindFirstChildOfClass("TextLabel")
				if lbl then
					lbl.Text = (cfg.names and plr.Name or "") .. (cfg.dist and ("   [" .. d .. "]") or "")
				end
			else
				removeEsp(plr)
			end
		end
	end
end

-- ===== ACCIONES =====
local function tpTo(plr)
	local me = getRoot(LP)
	local r = getRoot(plr)
	if me and r then
		me.CFrame = r.CFrame * CFrame.new(0, 3, 4)
	end
end

local function applySpeed()
	local ch = LP.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = cfg.speed and cfg.speedVal or 16
		hum.JumpPower = 55
	end
end

local function applyNoclip()
	local ch = LP.Character
	if not ch then return end
	for _, p in ipairs(ch:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = not cfg.noclip
		end
	end
end

LP.CharacterAdded:Connect(function()
	task.wait(1)
	clearEspAll()
	applySpeed()
end)

Players.PlayerRemoving:Connect(function(p) removeEsp(p) end)

RunService.Heartbeat:Connect(function()
	if cfg.esp then pcall(updateEsp) end
	if cfg.noclip then pcall(applyNoclip) end
end)

task.spawn(function()
	while true do
		if cfg.speed then pcall(applySpeed) end
		task.wait(0.2)
	end
end)
-- ===== INTERFAZ =====
local gui = Instance.new("ScreenGui")
gui.Name = "NexusBrainrot"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok = pcall(function() gui.Parent = CoreGui end)
if not ok or not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local BANNER = "https://files.catbox.moe/dohhak.jpg"

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 402)
main.Position = UDim2.new(0, 14, 0, 90)
main.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local head = Instance.new("ImageLabel")
head.Size = UDim2.new(1, 0, 0, 78)
head.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
head.BorderSizePixel = 0
head.Image = BANNER
head.ScaleType = Enum.ScaleType.Crop
head.Parent = main
Instance.new("UICorner", head).CornerRadius = UDim.new(0, 12)

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shade.BackgroundTransparency = 0.35
shade.BorderSizePixel = 0
shade.Parent = head
Instance.new("UICorner", shade).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 18)
title.Position = UDim2.fromOffset(12, 44)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeTransparency = 0.2
title.Text = "Nexus-HUB | Brainrot"
title.Parent = main

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -60, 0, 12)
sub.Position = UDim2.fromOffset(12, 61)
sub.BackgroundTransparency = 1
sub.Font = Enum.Font.Gotham
sub.TextSize = 9
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextColor3 = Color3.fromRGB(200, 200, 215)
sub.TextStrokeTransparency = 0.4
sub.Text = "By Navi"
sub.Parent = main

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(26, 26)
minBtn.Position = UDim2.new(1, -34, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
minBtn.BackgroundTransparency = 0.25
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Parent = main
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 7)

-- ===== ICONO MINIMIZADO =====
local mini = Instance.new("ImageButton")
mini.Size = UDim2.fromOffset(54, 54)
mini.Position = UDim2.new(0, 14, 0, 90)
mini.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mini.BorderSizePixel = 0
mini.Image = BANNER
mini.ScaleType = Enum.ScaleType.Crop
mini.Visible = false
mini.Active = true
mini.Parent = gui
Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 12)

local miniTag = Instance.new("TextLabel")
miniTag.Size = UDim2.new(1, 0, 0, 12)
miniTag.Position = UDim2.new(0, 0, 1, -13)
miniTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniTag.BackgroundTransparency = 0.35
miniTag.BorderSizePixel = 0
miniTag.Font = Enum.Font.GothamBold
miniTag.TextSize = 9
miniTag.TextColor3 = Color3.fromRGB(255, 255, 255)
miniTag.Text = "NEXUS"
miniTag.Parent = mini

local function setMinimized(v)
	main.Visible = not v
	mini.Visible = v
end

minBtn.MouseButton1Click:Connect(function()
	mini.Position = main.Position
	setMinimized(true)
end)
mini.MouseButton1Click:Connect(function()
	main.Position = mini.Position
	setMinimized(false)
end)

-- ===== ARRASTRAR =====
local dragging, dragStart, startPos = false, nil, nil
head.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
	end
end)
mini.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = i.Position
		startPos = mini.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if not dragging then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local delta = i.Position - dragStart
		local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		main.Position = pos
		mini.Position = pos
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ===== LISTA =====
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -88)
list.Position = UDim2.fromOffset(8, 84)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 110)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = main

local lay = Instance.new("UIListLayout")
lay.Padding = UDim.new(0, 6)
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.Parent = list
lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 8)
end)

local function mkSection(text)
	local f = Instance.new("TextLabel")
	f.Size = UDim2.new(1, -16, 0, 18)
	f.BackgroundTransparency = 1
	f.Font = Enum.Font.GothamBold
	f.TextSize = 10
	f.TextXAlignment = Enum.TextXAlignment.Left
	f.TextColor3 = Color3.fromRGB(145, 145, 168)
	f.Text = text
	f.Parent = list
end

local function mkToggle(text, key)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, -16, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(24, 24, 31)
	row.BorderSizePixel = 0
	row.Text = ""
	row.AutoButtonColor = false
	row.Parent = list
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -62, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = Color3.fromRGB(215, 215, 228)
	lbl.Text = text
	lbl.Parent = row

	local sw = Instance.new("TextLabel")
	sw.Size = UDim2.fromOffset(44, 20)
	sw.Position = UDim2.new(1, -54, 0.5, -10)
	sw.BackgroundColor3 = Color3.fromRGB(44, 44, 54)
	sw.Font = Enum.Font.GothamBold
	sw.TextSize = 10
	sw.TextColor3 = Color3.fromRGB(150, 150, 165)
	sw.Text = "OFF"
	sw.Parent = row
	Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 6)

	local function paint()
		sw.Text = cfg[key] and "ON" or "OFF"
		sw.BackgroundColor3 = cfg[key] and Color3.fromRGB(52, 150, 90) or Color3.fromRGB(44, 44, 54)
		sw.TextColor3 = cfg[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 165)
	end
	paint()

	row.MouseButton1Click:Connect(function()
		cfg[key] = not cfg[key]
		paint()
		if key == "esp" and not cfg[key] then clearEspAll() end
		if key == "speed" or key == "noclip" then applySpeed(); applyNoclip() end
	end)
	return row
end

local function mkSlider(text, key, min, max)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -16, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(24, 24, 31)
	row.BorderSizePixel = 0
	row.Parent = list
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 0, 16)
	lbl.Position = UDim2.fromOffset(10, 4)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = Color3.fromRGB(210, 210, 225)
	lbl.Text = text .. ": " .. cfg[key]
	lbl.Parent = row

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 6)
	bar.Position = UDim2.new(0, 10, 0, 26)
	bar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	bar.BorderSizePixel = 0
	bar.Parent = row
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((cfg[key] - min) / (max - min), 1)
	fill.BackgroundColor3 = Color3.fromRGB(120, 90, 240)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

	local drag = Instance.new("TextButton")
	drag.Size = UDim2.fromScale(1, 1)
	drag.BackgroundTransparency = 1
	drag.Text = ""
	drag.Parent = bar

	local function set(px)
		local rel = math.clamp((px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local v = math.floor(min + (max - min) * rel + 0.5)
		cfg[key] = v
		fill.Size = UDim2.fromScale(rel, 1)
		lbl.Text = text .. ": " .. v
		if key == "speedVal" then applySpeed() end
	end

	drag.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			set(i.Position.X)
		end
	end)
	drag.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			if i.UserInputState ~= Enum.UserInputState.End then set(i.Position.X) end
		end
	end)
	return row
end

local function mkButton(text, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -16, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(46, 40, 90)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.fromRGB(235, 232, 255)
	b.Text = text
	b.Parent = list
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	b.MouseButton1Click:Connect(cb)
	return b
end

mkSection("MOVIMIENTO")
mkToggle("Speed (correr rapido)", "speed")
mkSlider("Velocidad", "speedVal", 20, 250)
mkToggle("Atravesar casas", "noclip")
mkButton("Volver a 16 (normal)", function()
	cfg.speed = false
	cfg.speedVal = 16
	applySpeed()
end)

mkSection("ESP")
mkToggle("ESP activo", "esp")
mkToggle("Cajas", "boxes")
mkToggle("Nombres", "names")
mkToggle("Distancia", "dist")
mkSlider("Rango ESP", "espRange", 50, 2000)

mkSection("JUGADORES")

local plrBox = Instance.new("Frame")
plrBox.Size = UDim2.new(1, -16, 0, 140)
plrBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
plrBox.BorderSizePixel = 0
plrBox.Parent = list
Instance.new("UICorner", plrBox).CornerRadius = UDim.new(0, 8)

local plrScroll = Instance.new("ScrollingFrame")
plrScroll.Size = UDim2.new(1, -8, 1, -8)
plrScroll.Position = UDim2.fromOffset(4, 4)
plrScroll.BackgroundTransparency = 1
plrScroll.BorderSizePixel = 0
plrScroll.ScrollBarThickness = 3
plrScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plrScroll.Parent = plrBox

local plrLay = Instance.new("UIListLayout")
plrLay.Padding = UDim.new(0, 4)
plrLay.Parent = plrScroll
plrLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	plrScroll.CanvasSize = UDim2.new(0, 0, 0, plrLay.AbsoluteContentSize.Y + 6)
end)

local function refreshPlayers()
	for _, c in ipairs(plrScroll:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			local row = Instance.new("TextButton")
			row.Size = UDim2.new(1, -4, 0, 26)
			row.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
			row.BorderSizePixel = 0
			row.Text = ""
			row.AutoButtonColor = false
			row.Parent = plrScroll
			Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

			local n = Instance.new("TextLabel")
			n.Size = UDim2.new(1, -50, 1, 0)
			n.Position = UDim2.fromOffset(8, 0)
			n.BackgroundTransparency = 1
			n.Font = Enum.Font.GothamMedium
			n.TextSize = 11
			n.TextXAlignment = Enum.TextXAlignment.Left
			n.TextTruncate = Enum.TextTruncate.AtEnd
			n.TextColor3 = Color3.fromRGB(220, 220, 232)
			n.Text = plr.Name
			n.Parent = row

			local tp = Instance.new("TextButton")
			tp.Size = UDim2.fromOffset(38, 18)
			tp.Position = UDim2.new(1, -44, 0.5, -9)
			tp.BackgroundColor3 = Color3.fromRGB(58, 120, 220)
			tp.BorderSizePixel = 0
			tp.Font = Enum.Font.GothamBold
			tp.TextSize = 10
			tp.TextColor3 = Color3.fromRGB(255, 255, 255)
			tp.Text = "TP"
			tp.Parent = row
			Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 5)
			tp.MouseButton1Click:Connect(function() tpTo(plr) end)
		end
	end
end

refreshPlayers()
task.spawn(function()
	while gui.Parent do
		refreshPlayers()
		task.wait(2)
	end
end)

mkButton("Minimizar", function()
	mini.Position = main.Position
	setMinimized(true)
end)