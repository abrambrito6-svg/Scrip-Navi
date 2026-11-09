--[[  Nexus-HUB | Duelos -- By Navi  |  v9  ]]--
-- Apunta moviendo el MOUSE virtual al enemigo (raycast), no la camara sola

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DBG = { label = nil, last = "nada" }

local cfg = {
	esp = false,
	onlyEnemies = true,
	onlyInMatch = true,
	box = true,
	names = true,
	dist = true,
	espRange = 400,
	autoShot = false,
	shootRange = 120,
	killRange = 200,
	fireRate = 0.18,
	autoEquip = true,
	tapMode = true,
	snap = true,
	method = "Virtual",
	farm = false,
}

local GUN_PAT = "gun|pistol|revolver|shotgun|magnum|sniper|rifle|smg|uzi|deagle|colt|ak|m4|machine|weapon"
local MELEE_PAT = "knife|sword|bat|axe|hammer|melee"

local function getRoot(plr)
	local ch = plr.Character
	if not ch then return nil end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	return ch:FindFirstChild("HumanoidRootPart")
end

local function getGun()
	local ch = LP.Character
	if not ch then return nil end
	for _, t in ipairs(ch:GetChildren()) do
		if t:IsA("Tool") and t.Name:lower():match(GUN_PAT) then return t end
	end
	for _, t in ipairs(ch:GetChildren()) do
		if t:IsA("Tool") and not t.Name:lower():match(MELEE_PAT) then return t end
	end
	return nil
end

local function equipGun()
	local ch = LP.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local bp = LP:FindFirstChildOfClass("Backpack")
	if not hum or not bp then return false end
	for _, t in ipairs(bp:GetChildren()) do
		if t:IsA("Tool") and t.Name:lower():match(GUN_PAT) then
			pcall(function() hum:EquipTool(t) end)
			return true
		end
	end
	return false
end

local function isEnemy(plr)
	if plr == LP then return false end
	if cfg.onlyInMatch and LP.Team == nil then return false end
	if not getRoot(plr) then return false end
	if cfg.onlyEnemies then
		local myTeam = LP.Team
		if myTeam and plr.Team then return plr.Team ~= myTeam end
		if myTeam and not plr.Team then return false end
	end
	return true
end

-- ===== ESP =====
local espObj = {}

local function removeEsp(plr)
	local e = espObj[plr]
	if not e then return end
	for _, o in ipairs(e) do pcall(function() o:Destroy() end) end
	espObj[plr] = nil
end

local function makeEsp(plr, root)
	local objs = {}

	local box = Instance.new("BoxHandleAdornment")
	box.Size = Vector3.new(3, 5.6, 3)
	box.Adornee = root
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Color3 = Color3.fromRGB(255, 60, 60)
	box.Transparency = 0.4
	box.Parent = root
	table.insert(objs, box)

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(170, 40)
	bb.StudsOffset = Vector3.new(0, 2.8, 0)
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
		if not plr.Parent or not isEnemy(plr) then removeEsp(plr) end
	end
	local myRoot = getRoot(LP)
	if not myRoot then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			local root = getRoot(plr)
			if root then
				local d = math.floor((myRoot.Position - root.Position).Magnitude)
				if d <= cfg.espRange then
					local objs = espObj[plr]
					if not objs or objs[1].Adornee ~= root then
						removeEsp(plr)
						objs = makeEsp(plr, root)
					end
					objs[1].Color3 = (d <= cfg.shootRange)
						and Color3.fromRGB(255, 40, 40)
						or Color3.fromRGB(255, 175, 40)
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
end

-- ===== REMOTES DE DISPARO =====
local shootRemotes = {}

local function scanRemotes()
	table.clear(shootRemotes)
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if d:IsA("RemoteEvent") then
			local n = d.Name:lower()
			if n:match("shoot") or n:match("fire") or n:match("gun") then
				table.insert(shootRemotes, d)
			end
		end
	end
	return #shootRemotes
end

-- ===== APUNTADO Y DISPARO =====
local lastAim = nil
local lastFire = 0

local function aimAt(part)
	if not part then return end
	local vp = Camera.ViewportSize
	if cfg.snap then
		pcall(function()
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, part.Position)
		end)
	end
	local sp = Camera:WorldToViewportPoint(part.Position)
	local px = math.clamp(sp.X, 2, vp.X - 3)
	local py = math.clamp(sp.Y, 2, vp.Y - 3)
	lastAim = Vector2.new(px, py)
	pcall(function()
		VirtualInputManager:SendMouseMoveEvent(px, py, false, game)
	end)
end

local function shoot(part)
	if not part or not part.Parent then return end
	local gun = getGun()
	if not gun then
		if cfg.autoEquip then equipGun() end
		DBG.last = "sin arma"
		return
	end

	aimAt(part)
	local p = lastAim
	if not p then return end

	local m = cfg.method
	if m == "Virtual" or m == "Todo" then
		pcall(function() VirtualInputManager:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0) end)
		task.wait(cfg.tapMode and 0.05 or 0.012)
		pcall(function() VirtualInputManager:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0) end)
	end
	if m == "Activate" or m == "Todo" then
		pcall(function() gun:Activate() end)
		if cfg.tapMode then
			task.delay(0.05, function() pcall(function() gun:Deactivate() end) end)
		end
	end
	if m == "Remote" or m == "Todo" then
		for _, r in ipairs(shootRemotes) do
			pcall(function() r:FireServer() end)
		end
	end

	lastFire = os.clock()
	DBG.last = m .. " en " .. gun.Name
end

local function nearestEnemy(maxD)
	local myRoot = getRoot(LP)
	if not myRoot then return nil end
	local best, bestD = nil, maxD
	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			local r = getRoot(plr)
			if r then
				local d = (myRoot.Position - r.Position).Magnitude
				if d < bestD then best, bestD = r, d end
			end
		end
	end
	return best, bestD
end

local function updateDebug()
	if not DBG.label then return end
	local gun = getGun()
	DBG.label.Text = string.format("arma: %s  |  metodo: %s  |  remotos: %d  |  ultimo: %s",
		gun and gun.Name or "ninguna", cfg.method, #shootRemotes, DBG.last)
end
-- ===== INTERFAZ =====
local function clearEspAll()
	for plr in pairs(espObj) do removeEsp(plr) end
end

Players.PlayerRemoving:Connect(function(p) removeEsp(p) end)
LP.CharacterAdded:Connect(function() task.wait(1) clearEspAll() end)

local gui = Instance.new("ScreenGui")
gui.Name = "NexusDuelos"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok = pcall(function() gui.Parent = CoreGui end)
if not ok or not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(318, 430)
main.Position = UDim2.new(0, 14, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundTransparency = 1
bg.Image = "https://files.catbox.moe/dohhak.jpg"
bg.ImageTransparency = 0.72
bg.ScaleType = Enum.ScaleType.Crop
bg.Parent = main
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

local head = Instance.new("Frame")
head.Size = UDim2.new(1, 0, 0, 44)
head.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
head.BorderSizePixel = 0
head.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.Text = "Nexus-HUB | Duelos  v9"
title.Parent = head

local sub = Instance.new("TextLabel")
sub.Size = UDim2.fromOffset(120, 12)
sub.Position = UDim2.new(1, -132, 0, 30)
sub.BackgroundTransparency = 1
sub.Font = Enum.Font.Gotham
sub.TextSize = 9
sub.TextXAlignment = Enum.TextXAlignment.Right
sub.TextColor3 = Color3.fromRGB(120, 120, 135)
sub.Text = "By Navi"
sub.Parent = head

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -36, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Parent = head
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function() gui.Enabled = false end)

local dbg = Instance.new("TextLabel")
dbg.Size = UDim2.new(1, -24, 0, 14)
dbg.Position = UDim2.fromOffset(12, 48)
dbg.BackgroundTransparency = 1
dbg.Font = Enum.Font.Code
dbg.TextSize = 10
dbg.TextXAlignment = Enum.TextXAlignment.Left
dbg.TextColor3 = Color3.fromRGB(120, 220, 140)
dbg.Text = "cargando..."
dbg.Parent = main
DBG.label = dbg

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -70)
list.Position = UDim2.fromOffset(8, 64)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 105)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = main

local lay = Instance.new("UIListLayout")
lay.Padding = UDim.new(0, 6)
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.Parent = list
lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
end)

local function mkSection(text)
	local f = Instance.new("TextLabel")
	f.Size = UDim2.new(1, -16, 0, 20)
	f.BackgroundTransparency = 1
	f.Font = Enum.Font.GothamBold
	f.TextSize = 11
	f.TextXAlignment = Enum.TextXAlignment.Left
	f.TextColor3 = Color3.fromRGB(150, 150, 170)
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
	b.Size = UDim2.new(1, -16, 0, 34)
	b.BackgroundColor3 = Color3.fromRGB(48, 40, 92)
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

-- ===== CONTROLES =====
mkSection("ESP")
mkToggle("ESP activo", "esp")
mkToggle("Solo enemigos", "onlyEnemies")
mkToggle("Solo en partida", "onlyInMatch")
mkToggle("Cajas", "box")
mkToggle("Nombres", "names")
mkToggle("Distancia", "dist")
mkSlider("Rango ESP", "espRange", 20, 800)

mkSection("DISPARO")
mkToggle("Auto Shot", "autoShot")
mkToggle("Auto equipar arma", "autoEquip")
mkToggle("Tap (soltar gatillo)", "tapMode")
mkToggle("Girar camara al objetivo", "snap")
mkSlider("Rango de disparo", "shootRange", 10, 400)
mkSlider("Cadencia (ms)", "fireRate", 60, 600)

local methodBtn
methodBtn = mkButton("Metodo: " .. cfg.method, function()
	local order = { "Virtual", "Activate", "Remote", "Todo" }
	local i = table.find(order, cfg.method) or 1
	cfg.method = order[(i % #order) + 1]
	methodBtn.Text = "Metodo: " .. cfg.method
end)

mkButton("PROBAR TIRO (enemigo cercano)", function()
	local target = nearestEnemy(cfg.shootRange + 60)
	if target then
		shoot(target)
	else
		DBG.last = "sin enemigo cerca"
	end
end)

mkSection("EXTRA")
mkButton("Reescanear remotos", function()
	local n = scanRemotes()
	DBG.last = "remotos: " .. n
end)

mkButton("Kill All (tiro a todos)", function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			local r = getRoot(plr)
			if r then
				local myRoot = getRoot(LP)
				if myRoot and (myRoot.Position - r.Position).Magnitude <= cfg.killRange then
					shoot(r)
					task.wait(0.12)
				end
			end
		end
	end
end)

mkButton("Cerrar", function() gui.Enabled = false end)

-- ===== LOOPS =====
task.spawn(function()
	while gui.Parent do
		pcall(updateDebug)
		task.wait(0.25)
	end
end)

RunService.Heartbeat:Connect(function()
	if cfg.esp then pcall(updateEsp) else
		if next(espObj) then clearEspAll() end
	end
	if cfg.autoShot and LP.Team then
		local now = os.clock()
		if now - lastFire >= cfg.fireRate / 1000 then
			local target = nearestEnemy(cfg.shootRange)
			if target then shoot(target) end
		end
	end
end)

scanRemotes()
DBG.last = "listo"