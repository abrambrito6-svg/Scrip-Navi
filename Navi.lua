--[[
	═══════════════════════════════════════════════════════════════════
	 Zenith -- Duelos | HUB -- By Navi   [v1.1]
	 ---------------------------------------------------------------
	 · ESP completo + Esqueleto por Motor6D (R6 y R15) + Cajas 2D
	 · Lista de roles en vivo: Murderer ROJO / Sheriff AZUL / Inocente BLANCO
	 · Aimlock con FOV visual, WallCheck, AutoShoot
	 · Kill Aura / Auto Stab / Teleport-Stab
	 · Fly, Noclip, Speed
	 · Auto Farm de monedas + Auto Rejoin + Anti-AFK
	 · Minimizar a burbuja flotante (tecla RightShift para abrir/cerrar)
	═══════════════════════════════════════════════════════════════════
]]

--=====================================================================
-- 1. SERVICIOS Y VARIABLES
--=====================================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local Workspace           = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser         = game:GetService("VirtualUser")
local TeleportService     = game:GetService("TeleportService")
local LP                  = Players.LocalPlayer
local Camera              = Workspace.CurrentCamera

local DRAWING_OK = (typeof(Drawing) == "table" or type(Drawing) == "table")

local function getGuiParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	return game:GetService("CoreGui")
end

pcall(function()
	local old = getGuiParent():FindFirstChild("ZenithHub")
	if old then old:Destroy() end
	local oldB = getGuiParent():FindFirstChild("ZenithBubble")
	if oldB then oldB:Destroy() end
end)

--=====================================================================
-- 2. CONFIGURACIÓN
--=====================================================================
local Config = {
	ESPGlow      = false,
	ESPNames     = false,
	ESPRole      = true,
	ESPDistance  = false,
	ESPSkeleton  = false,
	ESPLines     = false,
	ESPBox       = false,
	ESPGunDrop   = false,
	ESPFOVCircle = false,

	Aimlock      = false,
	AimMode      = "Cercano",
	AimFOV       = 220,
	AimSmooth    = 0.35,
	WallCheck    = true,
	AutoShoot    = false,
	KillAura     = false,
	KillAuraRange= 25,
	AutoStab     = false,

	Fly          = false,
	FlySpeed     = 50,
	Noclip       = false,
	Speed        = false,
	WalkSpeed    = 60,

	AutoCoin     = false,
	FarmRadius   = 150,
	AutoRejoin   = false,
	AntiAFK      = false,
}
getgenv().Zenith = Config

local RoleColor = {
	Murderer = Color3.fromRGB(255, 55, 55),
	Sheriff  = Color3.fromRGB(70, 145, 255),
	Innocent = Color3.fromRGB(255, 255, 255),
}
local RoleTag = { Murderer = "MURDER", Sheriff = "SHERIFF", Innocent = "INOCENTE" }

local Theme = {
	Bg        = Color3.fromRGB(13, 13, 16),
	Panel     = Color3.fromRGB(20, 20, 25),
	Panel2    = Color3.fromRGB(26, 26, 32),
	Accent    = Color3.fromRGB(150, 70, 255),
	AccentDim = Color3.fromRGB(95, 45, 165),
	Text      = Color3.fromRGB(235, 235, 242),
	Sub       = Color3.fromRGB(140, 140, 152),
	Stroke    = Color3.fromRGB(48, 48, 58),
}

--=====================================================================
-- 3. HELPERS
--=====================================================================
local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	if parent then inst.Parent = parent end
	return inst
end

local function corner(parent, r)
	return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, parent)
end

local function stroke(parent, color, thickness)
	return new("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function alive(player)
	local char = player.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	return char and hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") ~= nil
end

local function getRoot(player)
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function isValid(player)
	return player and player.Parent and player ~= LP
end

--=====================================================================
-- 4. DETECCIÓN DE ROLES
--=====================================================================
local RoleCache = {}

local function detectRole(player)
	local char = player.Character

	for _, obj in ipairs({player, char}) do
		if obj then
			local ok, attr = pcall(function()
				return obj:GetAttribute("Role") or obj:GetAttribute("role")
			end)
			if ok and type(attr) == "string" then
				local l = attr:lower()
				if l:find("murder") then return "Murderer" end
				if l:find("sheriff") then return "Sheriff" end
				if l:find("innocent") then return "Innocent" end
			end
		end
	end

	local hasKnife, hasGun = false, false
	local backpack = player:FindFirstChild("Backpack")
	for _, container in ipairs({char, backpack}) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") then
					local n = item.Name:lower()
					if n:find("knife") or n:find("cuchillo") then
						hasKnife = true
					elseif n:find("gun") or n:find("revolver") or n:find("pistol") then
						hasGun = true
					end
				end
			end
		end
	end
	if hasKnife then return "Murderer" end
	if hasGun   then return "Sheriff"  end

	local pgui = player:FindFirstChild("PlayerGui")
	if pgui then
		for _, name in ipairs({"Role", "RoleTag", "RoleLabel"}) do
			local tag = pgui:FindFirstChild(name, true)
			if tag and (tag:IsA("TextLabel") or tag:IsA("StringValue")) then
				local l = tostring(tag.Text or tag.Value or ""):lower()
				if l:find("murder") then return "Murderer" end
				if l:find("sheriff") then return "Sheriff" end
			end
		end
	end

	return "Innocent"
end

local function getRole(player)
	local c = RoleCache[player]
	if c and (tick() - c.t) < 0.6 then return c.role end
	local role = "Innocent"
	pcall(function() role = detectRole(player) end)
	RoleCache[player] = {role = role, t = tick()}
	return role
end

--=====================================================================
-- 5. GUI BASE / NOTIFICACIONES
--=====================================================================
local ScreenGui, NotifyHolder

local function notify(text, color)
	if not NotifyHolder then return end
	local box = new("Frame", {
		Size = UDim2.fromOffset(250, 38),
		BackgroundColor3 = Theme.Panel2,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
	}, NotifyHolder)
	corner(box, 6)
	stroke(box, color or Theme.Accent)

	local bar = new("Frame", {
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = color or Theme.Accent,
		BorderSizePixel = 0,
	}, box)
	corner(bar, 3)

	new("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
	}, box)

	box.Position = UDim2.new(1, 20, 1, -50)
	TweenService:Create(box, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
		Position = UDim2.new(1, -260, 1, -50),
	}):Play()

	task.delay(2.6, function()
		local t = TweenService:Create(box, TweenInfo.new(0.25), {
			Position = UDim2.new(1, 20, 1, -50),
			BackgroundTransparency = 1,
		})
		t:Play()
		t.Completed:Wait()
		box:Destroy()
	end)
end

--=====================================================================
-- 6. COMPONENTES
--=====================================================================
local function makeToggle(parent, text, default, callback)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
	}, parent)

	new("TextLabel", {
		Size = UDim2.new(1, -52, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
	}, row)

	local switch = new("Frame", {
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -38, 0.5, -10),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
	}, row)
	corner(switch, 10)
	local st = stroke(switch, Theme.Stroke)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.Sub,
		BorderSizePixel = 0,
	}, switch)
	corner(knob, 7)

	local state = default and true or false
	local api = {}

	function api.Set(value, silent)
		state = value and true or false
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = UDim2.fromOffset(state and 21 or 3, 3),
			BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Theme.Sub,
		}):Play()
		TweenService:Create(switch, TweenInfo.new(0.18), {
			BackgroundColor3 = state and Theme.Accent or Theme.Panel2,
		}):Play()
		st.Color = state and Theme.Accent or Theme.Stroke
		if not silent and callback then pcall(callback, state) end
	end

	new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
	}, switch).MouseButton1Click:Connect(function()
		api.Set(not state)
	end)

	if state then api.Set(true, true) end
	return api
end

local function makeSlider(parent, text, min, max, default, callback)
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, parent)

	local label = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
	}, wrap)

	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 5),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
	}, wrap)
	corner(bar, 3)

	local fill = new("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, bar)
	corner(fill, 3)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(11, 11),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, bar)
	corner(knob, 6)

	local value = default
	local dragging = false

	local function apply(v, silent)
		value = math.clamp(v, min, max)
		local alpha = (value - min) / (max - min)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		label.Text = text .. ": " .. tostring(math.floor(value + 0.5))
		if not silent and callback then pcall(callback, value) end
	end

	local function fromInput(posX)
		local rel = (posX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
		apply(min + (max - min) * math.clamp(rel, 0, 1))
	end

	new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
	}, bar).MouseButton1Down:Connect(function()
		dragging = true
		fromInput(UserInputService:GetMouseLocation().X)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			fromInput(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	apply(default, true)
	return {Set = function(v) apply(v, true) end}
end

local function makeButton(parent, text, callback)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Text = text,
		AutoButtonColor = false,
	}, parent)
	corner(btn, 6)
	stroke(btn, Theme.Stroke)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.AccentDim}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Panel2}):Play()
	end)
	btn.MouseButton1Click:Connect(function() pcall(callback) end)
	return btn
end

local function sectionTitle(parent, text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = string.upper(text),
	}, parent)
end

--=====================================================================
-- 7. ESP
--=====================================================================
local ESPFolder = new("Folder", {Name = "ZenithESP"})
pcall(function() ESPFolder.Parent = getGuiParent() end)

local ESPData = {}

local R6Bones = {
	{"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
	{"Torso","Left Leg"}, {"Torso","Right Leg"},
}
local R15Bones = {
	{"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
}

local function makeText(size, outline)
	if not DRAWING_OK then return nil end
	local t = Drawing.new("Text")
	t.Size = size
	t.Center = true
	t.Outline = outline
	t.OutlineColor = Color3.new(0, 0, 0)
	t.Visible = false
	return t
end

local function makeLine(thickness)
	if not DRAWING_OK then return nil end
	local l = Drawing.new("Line")
	l.Thickness = thickness
	l.Transparency = 1
	l.Visible = false
	return l
end

local function makeSquare(thickness)
	if not DRAWING_OK then return nil end
	local s = Drawing.new("Square")
	s.Thickness = thickness
	s.Filled = false
	s.Transparency = 1
	s.Visible = false
	return s
end

-- Construye la lista de huesos desde los Motor6D del personaje (R6 y R15)
local function buildBones(char)
	local joints = {}
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("Motor6D") then
			local a, b = d.Part0, d.Part1
			if a and b and a.Name ~= "HumanoidRootPart" and b.Name ~= "HumanoidRootPart" then
				table.insert(joints, {a, b})
			end
		end
	end

	if #joints == 0 then
		local table_ = char:FindFirstChild("UpperTorso") and R15Bones or R6Bones
		for _, pair in ipairs(table_) do
			local a = char:FindFirstChild(pair[1])
			local b = char:FindFirstChild(pair[2])
			if a and b then table.insert(joints, {a, b}) end
		end
	end
	return joints
end

local function buildESP(player)
	if player == LP or ESPData[player] then return end

	local data = {
		highlight = new("Highlight", {
			FillTransparency = 0.65,
			OutlineTransparency = 0.1,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			Enabled = false,
		}, ESPFolder),
		name = makeText(13, true),
		roleTxt = makeText(12, true),
		dist = makeText(11, true),
		line = makeLine(1.4),
		box = makeSquare(1.2),
		bones = {},
		joints = {},
		jointChar = nil,
	}

	ESPData[player] = data
end

local function destroyESP(player)
	local data = ESPData[player]
	if not data then return end
	ESPData[player] = nil
	pcall(function() data.highlight:Destroy() end)
	for _, key in ipairs({"name", "roleTxt", "dist", "line", "box"}) do
		local d = data[key]
		if d then d:Remove() end
	end
	for _, l in ipairs(data.bones) do
		if l then l:Remove() end
	end
end

local function ensureBoneLines(data, count)
	while #data.bones < count do
		local l = makeLine(1.2)
		if not l then break end
		data.bones[#data.bones + 1] = l
	end
end

local function hideAll(data)
	for _, key in ipairs({"name", "roleTxt", "dist", "line", "box"}) do
		local d = data[key]
		if d then d.Visible = false end
	end
	for _, l in ipairs(data.bones) do
		if l then l.Visible = false end
	end
end

local function updateESPFor(player)
	local data = ESPData[player]
	if not data then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local head = char and char:FindFirstChild("Head")
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	local ok   = root and head and hum and hum.Health > 0

	local role  = getRole(player)
	local color = RoleColor[role] or RoleColor.Innocent

	data.highlight.Adornee = ok and char or nil
	data.highlight.FillColor = color
	data.highlight.OutlineColor = color
	data.highlight.Enabled = Config.ESPGlow and ok and true or false

	if not ok then hideAll(data) return end

	local headPos = head.Position

	-- Nombres
	if data.name then
		local onScreen, sp = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 2.1, 0))
		data.name.Visible = Config.ESPNames and onScreen
		if data.name.Visible then
			data.name.Position = Vector2.new(sp.X, sp.Y)
			data.name.Text = player.Name
			data.name.Color = color
		end
	end

	-- Rol
	if data.roleTxt then
		local onScreen, sp = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 1.5, 0))
		data.roleTxt.Visible = Config.ESPRole and onScreen
		if data.roleTxt.Visible then
			data.roleTxt.Position = Vector2.new(sp.X, sp.Y)
			data.roleTxt.Text = RoleTag[role] or role
			data.roleTxt.Color = color
		end
	end

	-- Distancia
	if data.dist then
		local myRoot = getRoot(LP)
		local d = myRoot and math.floor((myRoot.Position - headPos).Magnitude) or 0
		local onScreen, sp = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.9, 0))
		data.dist.Visible = Config.ESPDistance and onScreen
		if data.dist.Visible then
			data.dist.Position = Vector2.new(sp.X, sp.Y)
			data.dist.Text = tostring(d) .. " studs"
			data.dist.Color = color
		end
	end

	-- Línea al centro inferior
	if data.line then
		local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
		local onScreen, sp = Camera:WorldToViewportPoint(headPos)
		data.line.Visible = Config.ESPLines and onScreen
		if data.line.Visible then
			data.line.From = center
			data.line.To = Vector2.new(sp.X, sp.Y)
			data.line.Color = color
		end
	end

	-- Caja 2D
	if data.box then
		local top = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 1.1, 0))
		local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.6, 0))
		if Config.ESPBox and top.Z > 0 and bottom.Z > 0 then
			local h = math.abs(bottom.Y - top.Y)
			local w = h * 0.55
			data.box.Position = Vector2.new(top.X - w / 2, top.Y)
			data.box.Size = Vector2.new(w, h)
			data.box.Color = color
			data.box.Visible = true
		else
			data.box.Visible = false
		end
	end

	-- Esqueleto
	if Config.ESPSkeleton then
		if data.jointChar ~= char or #data.joints == 0 then
			data.jointChar = char
			data.joints = buildBones(char)
		end
		ensureBoneLines(data, #data.joints)

		for i, joint in ipairs(data.joints) do
			local l = data.bones[i]
			if l then
				local pa = Camera:WorldToViewportPoint(joint[1].Position)
				local pb = Camera:WorldToViewportPoint(joint[2].Position)
				if pa.Z > 0 and pb.Z > 0 then
					l.From = Vector2.new(pa.X, pa.Y)
					l.To   = Vector2.new(pb.X, pb.Y)
					l.Color = color
					l.Visible = true
				else
					l.Visible = false
				end
			end
		end
		for i = #data.joints + 1, #data.bones do
			if data.bones[i] then data.bones[i].Visible = false end
		end
	else
		for _, l in ipairs(data.bones) do
			if l then l.Visible = false end
		end
	end
end

-- ---------- Arma tirada ----------
local GunDrops = {}

local function isGunDrop(inst)
	if not inst:IsA("BasePart") then return false end
	local n = inst.Name:lower()
	if n:find("drop") and (n:find("gun") or n:find("knife") or n:find("weapon")) then return true end
	return n == "gundrop" or n == "gundropped" or n == "droppedgun"
end

local function addGunDrop(part)
	if GunDrops[part] then return end
	local hl = new("Highlight", {
		FillColor = Color3.fromRGB(255, 190, 60),
		OutlineColor = Color3.fromRGB(255, 190, 60),
		FillTransparency = 0.5,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		Adornee = part,
		Enabled = false,
	}, ESPFolder)
	local txt = makeText(12, true)
	GunDrops[part] = {hl = hl, txt = txt}
end

local function scanGunDrops()
	for _, inst in ipairs(Workspace:GetDescendants()) do
		if isGunDrop(inst) then addGunDrop(inst) end
	end
end

Workspace.DescendantAdded:Connect(function(inst)
	if isGunDrop(inst) then addGunDrop(inst) end
end)
Workspace.DescendantRemoving:Connect(function(inst)
	local d = GunDrops[inst]
	if d then
		GunDrops[inst] = nil
		pcall(function() d.hl:Destroy() end)
		if d.txt then d.txt:Remove() end
	end
end)

local function updateGunDrops()
	for part, d in pairs(GunDrops) do
		if not part.Parent then
			GunDrops[part] = nil
			pcall(function() d.hl:Destroy() end)
			if d.txt then d.txt:Remove() end
		else
			d.hl.Enabled = Config.ESPGunDrop
			if d.txt then
				local onScreen, sp = Camera:WorldToViewportPoint(part.Position + Vector3.new(0, 1.2, 0))
				d.txt.Visible = Config.ESPGunDrop and onScreen
				if d.txt.Visible then
					d.txt.Position = Vector2.new(sp.X, sp.Y)
					d.txt.Text = "ARMA: " .. part.Name
					d.txt.Color = Color3.fromRGB(255, 190, 60)
				end
			end
		end
	end
end

--=====================================================================
-- 8. COMBATE
--=====================================================================
local CurrentTarget = nil
local rayParams = RaycastParams.new()
pcall(function() rayParams.FilterType = Enum.RaycastFilterType.Exclude end)

local fovCircle, aimTracer
if DRAWING_OK then
	fovCircle = Drawing.new("Circle")
	fovCircle.Thickness = 1.5
	fovCircle.Transparency = 0.7
	fovCircle.Color = Theme.Accent
	fovCircle.Filled = false
	fovCircle.Visible = false

	aimTracer = makeLine(1.5)
	if aimTracer then aimTracer.Color = Color3.fromRGB(255, 255, 255) end
end

local function hasWallClear(targetPart)
	if not Config.WallCheck then return true end
	local origin = Camera.CFrame.Position
	rayParams.FilterDescendantsInstances = {LP.Character, targetPart.Parent}
	local res = Workspace:Raycast(origin, targetPart.Position - origin, rayParams)
	return res == nil
end

local function pickTarget()
	local best, bestScore = nil, math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, p in ipairs(Players:GetPlayers()) do
		if isValid(p) and alive(p) then
			local char = p.Character
			local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
			if part then
				local role = getRole(p)
				local valid = true
				if Config.AimMode == "Murderer" and role ~= "Murderer" then valid = false end
				if Config.AimMode == "Sheriff"  and role ~= "Sheriff"  then valid = false end
				if valid and hasWallClear(part) then
					local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local score = (Vector2.new(sp.X, sp.Y) - center).Magnitude
						if score <= Config.AimFOV and score < bestScore then
							best, bestScore = part, score
						end
					end
				end
			end
		end
	end
	return best
end

local function aimStep()
	if fovCircle then
		fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		fovCircle.Radius = Config.AimFOV
		fovCircle.Visible = Config.ESPFOVCircle
	end

	if not Config.Aimlock then
		CurrentTarget = nil
		if aimTracer then aimTracer.Visible = false end
		return
	end

	local target = pickTarget()
	if target then
		CurrentTarget = target
		Camera.CFrame = Camera.CFrame:Lerp(
			CFrame.lookAt(Camera.CFrame.Position, target.Position),
			math.clamp(Config.AimSmooth, 0.05, 1)
		)
		pcall(function()
			local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
			local cur = UserInputService:GetMouseLocation()
			mousemoverel(center.X - cur.X, center.Y - cur.Y)
		end)
		if aimTracer then
			local sp = Camera:WorldToViewportPoint(target.Position)
			aimTracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
			aimTracer.To = Vector2.new(sp.X, sp.Y)
			aimTracer.Visible = Config.ESPFOVCircle
		end
	else
		CurrentTarget = nil
		if aimTracer then aimTracer.Visible = false end
	end
end

local function getEquipped(name)
	local char = LP.Character
	if not char then return nil end
	local tool = char:FindFirstChild(name)
	if tool and tool:IsA("Tool") then return tool end
	return nil
end

local function clickCenter()
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
		task.wait(0.03)
		VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
	end)
end

local autoShootAccum = 0
local function autoShootStep(dt)
	if not (Config.Aimlock and Config.AutoShoot and CurrentTarget) then return end
	autoShootAccum += dt
	if autoShootAccum < 0.14 then return end
	autoShootAccum = 0
	if getEquipped("Gun") and hasWallClear(CurrentTarget) then
		clickCenter()
	end
end

local stabAccum = 0
local function combatAuraStep(dt)
	if not (Config.KillAura or Config.AutoStab) then return end
	local knife = getEquipped("Knife")
	if not knife then return end
	local myRoot = getRoot(LP)
	if not myRoot then return end

	stabAccum += dt
	if stabAccum < 0.28 then return end
	stabAccum = 0

	local radius = Config.KillAura and Config.KillAuraRange or 12
	for _, p in ipairs(Players:GetPlayers()) do
		if isValid(p) and alive(p) then
			local root = getRoot(p)
			if root and (root.Position - myRoot.Position).Magnitude <= radius then
				pcall(function() knife:Activate() end)
				break
			end
		end
	end
end

local function teleportStab(targets, label)
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then notify("Sin personaje", RoleColor.Murderer) return end
	local knife = getEquipped("Knife")
	if not knife then notify("Equipa el cuchillo primero", RoleColor.Murderer) return end
	if #targets == 0 then notify("Ningún objetivo válido", RoleColor.Murderer) return end

	notify("Atacando: " .. label, Theme.Accent)
	local origin = hrp.CFrame
	for _, p in ipairs(targets) do
		if alive(p) then
			local root = getRoot(p)
			if root then
				pcall(function() hrp.CFrame = root.CFrame * CFrame.new(0, 0, 3) end)
				task.wait(0.11)
				pcall(function() knife:Activate() end)
				task.wait(0.07)
			end
		end
	end
	pcall(function() hrp.CFrame = origin end)
end

--=====================================================================
-- 9. MOVIMIENTO
--=====================================================================
local flyBV, flyBG, flyConn, noclipConn

local function setFly(on)
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if flyConn then flyConn:Disconnect() flyConn = nil end
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end

	if on and hrp then
		flyBV = new("BodyVelocity", {
			MaxForce = Vector3.new(1e6, 1e6, 1e6),
			Velocity = Vector3.zero, P = 1250,
		}, hrp)
		flyBG = new("BodyGyro", {
			MaxTorque = Vector3.new(1e6, 1e6, 1e6),
			P = 1250, D = 50, CFrame = hrp.CFrame,
		}, hrp)

		flyConn = RunService.Heartbeat:Connect(function()
			local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if not root or not flyBV or not flyBG then return end
			local cam = Camera.CFrame
			local dir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
			flyBV.Velocity = dir.Magnitude > 0 and (dir.Unit * Config.FlySpeed) or Vector3.zero
			flyBG.CFrame = cam
		end)
	end
end

local function setNoclip(on)
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	if not on then
		local char = LP.Character
		if char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") and p.CanCollide == false then
					pcall(function() p.CanCollide = true end)
				end
			end
		end
		return
	end
	noclipConn = RunService.Stepped:Connect(function()
		local char = LP.Character
		if not char then return end
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
		end
	end)
end

local function setSpeed(on)
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = on and Config.WalkSpeed or 16 end
end

--=====================================================================
-- 10. AUTO FARM
--=====================================================================
local farmAccum = 0

local function collectNearestCoin()
	local hrp = getRoot(LP)
	if not hrp then return end
	local nearest, dist = nil, Config.FarmRadius

	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("BasePart") and d.Name:lower():find("coin") then
			local m = (d.Position - hrp.Position).Magnitude
			if m < dist then nearest, dist = d, m end
		end
	end

	if nearest then
		pcall(function() hrp.CFrame = nearest.CFrame + Vector3.new(0, 3, 0) end)
		pcall(function()
			if firetouchinterest then
				firetouchinterest(hrp, nearest, 0)
				task.wait(0.03)
				firetouchinterest(hrp, nearest, 1)
			end
		end)
	end
end

local function farmStep(dt)
	if not Config.AutoCoin then return end
	farmAccum += dt
	if farmAccum < 0.35 then return end
	farmAccum = 0
	collectNearestCoin()
end

local function rejoin()
	notify("Reconectando...", Theme.Accent)
	pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end

local function enableAntiAFK(on)
	if on then
		LP.Idled:Connect(function()
			if Config.AntiAFK then
				pcall(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
				end)
			end
		end)
	end
end

--=====================================================================
-- 11. CONSTRUCCIÓN DEL GUI
--=====================================================================
local Main, Bubble

local function buildGUI()
	local parentGui = getGuiParent()

	ScreenGui = new("ScreenGui", {
		Name = "ZenithHub",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local ok = pcall(function() ScreenGui.Parent = parentGui end)
	if not ok then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

	NotifyHolder = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1}, ScreenGui)

	Main = new("Frame", {
		Size = UDim2.fromOffset(620, 430),
		Position = UDim2.new(0.5, -310, 0.5, -215),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, ScreenGui)
	corner(Main, 12)
	stroke(Main, Theme.Stroke)

	new("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = "https://files.catbox.moe/cmrqdt.jpg",
		ScaleType = Enum.ScaleType.Crop,
		ImageTransparency = 0.45,
		ZIndex = 1,
	}, Main)

	new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Bg,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, Main)

	local topBar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Color3.fromRGB(10, 10, 13),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, Main)

	new("TextLabel", {
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Zenith -- Duelos | HUB -- By Navi",
		ZIndex = 6,
	}, topBar)

	new("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, topBar)

	-- ---------- Burbuja flotante (minimizado) ----------
	Bubble = new("TextButton", {
		Name = "ZenithBubble",
		Size = UDim2.fromOffset(46, 46),
		Position = UDim2.new(0, 20, 0.5, -23),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.Accent,
		Text = "Z",
		AutoButtonColor = false,
		Visible = false,
	}, ScreenGui)
	corner(Bubble, 23)
	stroke(Bubble, Theme.Accent, 2)

	local function minimize()
		Main.Visible = false
		Bubble.Visible = true
	end

	local function restore()
		Main.Visible = true
		Bubble.Visible = false
	end

	Bubble.MouseButton1Click:Connect(function()
		Main.Visible = not Main.Visible
		Bubble.Visible = not Main.Visible
	end)

	-- Arrastre de la burbuja
	local bDrag, bStart, bPos = false, nil, nil
	Bubble.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			bDrag, bStart, bPos = true, input.Position, Bubble.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if bDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - bStart
			Bubble.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + d.X, bPos.Y.Scale, bPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then bDrag = false end
	end)

	-- Botones de ventana
	local close = new("TextButton", {
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -34, 0, 9),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Text = "X",
		AutoButtonColor = false,
		ZIndex = 7,
	}, topBar)
	corner(close, 6)
	close.MouseButton1Click:Connect(minimize)

	local mini = new("TextButton", {
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -62, 0, 9),
		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		Text = "-",
		AutoButtonColor = false,
		ZIndex = 7,
	}, topBar)
	corner(mini, 6)
	mini.MouseButton1Click:Connect(minimize)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			Main.Visible = not Main.Visible
			Bubble.Visible = not Main.Visible
		end
	end)

	-- Arrastre de la ventana
	local dragging, dragStart, startPos = false, nil, nil
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, dragStart, startPos = true, input.Position, Main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	-- Sidebar
	local sidebar = new("Frame", {
		Size = UDim2.new(0, 150, 1, -42),
		Position = UDim2.new(0, 0, 0, 42),
		BackgroundColor3 = Color3.fromRGB(10, 10, 13),
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, Main)
	new("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
	}, sidebar)

	local content = new("Frame", {
		Size = UDim2.new(1, -150, 1, -42),
		Position = UDim2.new(0, 150, 0, 42),
		BackgroundTransparency = 1,
		ZIndex = 4,
	}, Main)

	local pages = {}
	local function createPage(name)
		local page = new("ScrollingFrame", {
			Name = name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 4,
		}, content)
		local pad = new("Frame", {
			Size = UDim2.new(1, -24, 0, 0),
			Position = UDim2.fromOffset(14, 12),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 4,
		}, page)
		new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, pad)
		new("UIPadding", {PaddingBottom = UDim.new(0, 16)}, pad)
		pages[name] = page
		return pad
	end

	local tabButtons = {}
	local function createTab(name, order)
		local btn = new("TextButton", {
			Size = UDim2.new(1, -16, 0, 32),
			Position = UDim2.new(0, 8, 0, 8 + (order - 1) * 38),
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = Theme.Sub,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "  " .. name,
			AutoButtonColor = false,
			ZIndex = 5,
		}, sidebar)
		corner(btn, 6)
		btn.MouseButton1Click:Connect(function()
			for _, p in pairs(pages) do p.Visible = false end
			for _, b in pairs(tabButtons) do
				b.BackgroundColor3 = Theme.Panel
				b.TextColor3 = Theme.Sub
			end
			pages[name].Visible = true
			btn.BackgroundColor3 = Theme.AccentDim
			btn.TextColor3 = Theme.Text
		end)
		tabButtons[name] = btn
		return btn
	end

	new("TextLabel", {
		Size = UDim2.new(1, -16, 0, 26),
		Position = UDim2.new(0, 8, 1, -36),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = Theme.Sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "  Zenith v1.1 · By Navi",
	}, sidebar)

	--=================================================================
	-- ESP
	--=================================================================
	createTab("ESP", 1)
	local espPage = createPage("ESP")

	sectionTitle(espPage, "Jugadores")
	makeToggle(espPage, "ESP Glow (Highlight)", false, function(v)
		Config.ESPGlow = v
		notify(v and "ESP Glow: ON" or "ESP Glow: OFF", v and RoleColor.Innocent or RoleColor.Murderer)
	end)
	makeToggle(espPage, "Ver Nombres", false, function(v)
		Config.ESPNames = v
		notify(v and "Nombres: ON" or "Nombres: OFF", v and RoleColor.Innocent or RoleColor.Murderer)
	end)
	makeToggle(espPage, "Ver Rol", true, function(v)
		Config.ESPRole = v
	end)
	makeToggle(espPage, "Ver Distancia", false, function(v)
		Config.ESPDistance = v
		notify(v and "Distancia: ON" or "Distancia: OFF", v and RoleColor.Innocent or RoleColor.Murderer)
	end)
	makeToggle(espPage, "ESP Esqueleto", false, function(v)
		Config.ESPSkeleton = v
		notify(v and "Esqueleto: ON" or "Esqueleto: OFF", v and RoleColor.Innocent or RoleColor.Murderer)
	end)
	makeToggle(espPage, "ESP Líneas", false, function(v)
		Config.ESPLines = v
		notify(v and "Líneas: ON" or "Líneas: OFF", v and RoleColor.Innocent or RoleColor.Murderer)
	end)
	makeToggle(espPage, "ESP Cajas 2D", false, function(v)
		Config.ESPBox = v
		notify(v and "Cajas: ON" or "Cajas: OFF", v and RoleColor.Innocent or RoleColor.Murderer)
	end)
	makeToggle(espPage, "Círculo FOV + Tracer", false, function(v)
		Config.ESPFOVCircle = v
	end)

	sectionTitle(espPage, "Objetos")
	makeToggle(espPage, "ESP Arma Tirada", false, function(v)
		Config.ESPGunDrop = v
		notify(v and "Arma tirada: ON" or "Arma tirada: OFF", Color3.fromRGB(255, 190, 60))
	end)

	--=================================================================
	-- JUGADORES (lista de roles)
	--=================================================================
	createTab("Jugadores", 2)
	local listPage = createPage("Jugadores")
	sectionTitle(listPage, "Roles de la partida")

	local roleList = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, listPage)
	new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, roleList)

	--=================================================================
	-- COMBATE
	--=================================================================
	createTab("Combate", 3)
	local combatPage = createPage("Combate")

	sectionTitle(combatPage, "Aimlock")
	makeToggle(combatPage, "Aimlock", false, function(v)
		Config.Aimlock = v
		notify(v and "Aimlock: ON" or "Aimlock: OFF", v and RoleColor.Sheriff or RoleColor.Murderer)
	end)

	local modeRow = new("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1}, combatPage)
	local modeBtns = {}
	for i, m in ipairs({"Cercano", "Murderer", "Sheriff"}) do
		local b = new("TextButton", {
			Size = UDim2.new(1 / 3, -4, 1, 0),
			Position = UDim2.new((i - 1) / 3, 2, 0, 0),
			BackgroundColor3 = Theme.Panel2,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = Theme.Sub,
			Text = m,
			AutoButtonColor = false,
		}, modeRow)
		corner(b, 5)
		stroke(b, Theme.Stroke)
		modeBtns[m] = b
		b.MouseButton1Click:Connect(function()
			Config.AimMode = m
			for name, btn in pairs(modeBtns) do
				btn.BackgroundColor3 = (name == m) and Theme.AccentDim or Theme.Panel2
				btn.TextColor3 = (name == m) and Theme.Text or Theme.Sub
			end
			notify("Objetivo: " .. m, Theme.Accent)
		end)
	end
	modeBtns["Cercano"].BackgroundColor3 = Theme.AccentDim
	modeBtns["Cercano"].TextColor3 = Theme.Text

	makeSlider(combatPage, "FOV (píxeles)", 40, 600, 220, function(v) Config.AimFOV = v end)
	makeSlider(combatPage, "Suavidad", 0.05, 1, 0.35, function(v) Config.AimSmooth = v end)
	makeToggle(combatPage, "Wall Check", true, function(v) Config.WallCheck = v end)
	makeToggle(combatPage, "Auto Shoot", false, function(v)
		Config.AutoShoot = v
		notify(v and "Auto Shoot: ON" or "Auto Shoot: OFF", v and RoleColor.Sheriff or RoleColor.Murderer)
	end)

	sectionTitle(combatPage, "Cuchillo")
	makeToggle(combatPage, "Kill Aura", false, function(v)
		Config.KillAura = v
		notify(v and "Kill Aura: ON" or "Kill Aura: OFF", v and RoleColor.Murderer or Theme.Accent)
	end)
	makeSlider(combatPage, "Radio de Aura", 5, 60, 25, function(v) Config.KillAuraRange = v end)
	makeToggle(combatPage, "Auto Stab", false, function(v)
		Config.AutoStab = v
		notify(v and "Auto Stab: ON" or "Auto Stab: OFF", v and RoleColor.Murderer or Theme.Accent)
	end)

	sectionTitle(combatPage, "Acciones")
	makeButton(combatPage, "Matar al Sheriff", function()
		local list = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if isValid(p) and alive(p) and getRole(p) == "Sheriff" then table.insert(list, p) end
		end
		teleportStab(list, "Sheriff")
	end)
	makeButton(combatPage, "Matar a Todos", function()
		local list = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if isValid(p) and alive(p) then table.insert(list, p) end
		end
		teleportStab(list, "Todos")
	end)

	--=================================================================
	-- MOVIMIENTO
	--=================================================================
	createTab("Movimiento", 4)
	local movePage = createPage("Movimiento")

	sectionTitle(movePage, "Vuelo")
	makeToggle(movePage, "Volar (Fly)", false, function(v)
		Config.Fly = v
		setFly(v)
		notify(v and "Fly: ON" or "Fly: OFF", v and Theme.Accent or RoleColor.Murderer)
	end)
	makeSlider(movePage, "Velocidad de Vuelo", 10, 250, 50, function(v) Config.FlySpeed = v end)

	sectionTitle(movePage, "Terrestre")
	makeToggle(movePage, "Noclip", false, function(v)
		Config.Noclip = v
		setNoclip(v)
		notify(v and "Noclip: ON" or "Noclip: OFF", v and Theme.Accent or RoleColor.Murderer)
	end)
	makeToggle(movePage, "Caminar Rápido", false, function(v)
		Config.Speed = v
		setSpeed(v)
		notify(v and "Speed: ON" or "Speed: OFF", v and Theme.Accent or RoleColor.Murderer)
	end)
	makeSlider(movePage, "WalkSpeed", 20, 200, 60, function(v)
		Config.WalkSpeed = v
		if Config.Speed then setSpeed(true) end
	end)

	--=================================================================
	-- AUTO FARM
	--=================================================================
	createTab("Auto Farm", 5)
	local farmPage = createPage("Auto Farm")

	sectionTitle(farmPage, "Monedas")
	makeToggle(farmPage, "Auto Recolectar Monedas", false, function(v)
		Config.AutoCoin = v
		notify(v and "Auto Farm: ON" or "Auto Farm: OFF", v and RoleColor.Innocent or RoleColor.Murderer)
	end)
	makeSlider(farmPage, "Radio de farmeo", 30, 400, 150, function(v) Config.FarmRadius = v end)

	sectionTitle(farmPage, "Sesión")
	makeToggle(farmPage, "Anti-AFK", false, function(v)
		Config.AntiAFK = v
		notify(v and "Anti-AFK: ON" or "Anti-AFK: OFF", Theme.Accent)
	end)
	makeToggle(farmPage, "Auto Rejoin al morir", false, function(v)
		Config.AutoRejoin = v
		notify(v and "Auto Rejoin: ON" or "Auto Rejoin: OFF", Theme.Accent)
	end)
	makeButton(farmPage, "Rejoin ahora", rejoin)

	pages["ESP"].Visible = true
	tabButtons["ESP"].BackgroundColor3 = Theme.AccentDim
	tabButtons["ESP"].TextColor3 = Theme.Text
end

--=====================================================================
-- 12. LISTA DE ROLES (actualización)
--=====================================================================
local function refreshRoleList()
	if not roleList then return end
	for _, c in ipairs(roleList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local myRoot = getRoot(LP)
	local players = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if isValid(p) then table.insert(players, p) end
	end
	table.sort(players, function(a, b)
		local order = {Murderer = 1, Sheriff = 2, Innocent = 3}
		local ra, rb = order[getRole(a)], order[getRole(b)]
		if ra ~= rb then return ra < rb end
		return a.Name:lower() < b.Name:lower()
	end)

	for i, p in ipairs(players) do
		local role = getRole(p)
		local color = RoleColor[role]

		local row = new("Frame", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			LayoutOrder = i,
		}, roleList)
		corner(row, 5)

		new("Frame", {
			Size = UDim2.fromOffset(6, 6),
			Position = UDim2.new(0, 8, 0.5, -3),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, row)

		new("TextLabel", {
			Size = UDim2.new(1, -80, 1, 0),
			Position = UDim2.fromOffset(20, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = p.Name,
		}, row)

		local root = getRoot(p)
		local d = root and myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0

		new("TextLabel", {
			Size = UDim2.fromOffset(60, 26),
			Position = UDim2.new(1, -66, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 10,
			TextColor3 = Theme.Sub,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = RoleTag[role] .. " · " .. d,
		}, row)
	end
end

--=====================================================================
-- 13. CONEXIONES
--=====================================================================
for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
Players.PlayerAdded:Connect(function(p)
	buildESP(p)
	p.CharacterAdded:Connect(function() RoleCache[p] = nil end)
end)
Players.PlayerRemoving:Connect(function(p)
	destroyESP(p)
	RoleCache[p] = nil
end)

LP.CharacterAdded:Connect(function()
	RoleCache[LP] = nil
	task.wait(1)
	if Config.Fly then setFly(true) end
	if Config.Noclip then setNoclip(true) end
	if Config.Speed then setSpeed(true) end
end)

LP.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	hum.Died:Connect(function()
		if Config.AutoRejoin then
			task.wait(2)
			rejoin()
		end
	end)
end)

local scanAccum, listAccum = 0, 0
RunService.RenderStepped:Connect(function(dt)
	for player in pairs(ESPData) do updateESPFor(player) end
	updateGunDrops()

	scanAccum += dt
	if scanAccum > 2 then
		scanAccum = 0
		scanGunDrops()
	end

	listAccum += dt
	if listAccum > 0.5 then
		listAccum = 0
		refreshRoleList()
	end

	aimStep()
	autoShootStep(dt)
	combatAuraStep(dt)
	farmStep(dt)
end)

task.spawn(scanGunDrops)
enableAntiAFK(true)

--=====================================================================
-- 14. CARGA
--=====================================================================
buildGUI()
notify("Zenith cargado · RightShift para minimizar", Theme.Accent)

getgenv().ZenithAPI = { Config = Config, Notify = notify, GetRole = getRole }

print("Zenith -- Duelos | HUB -- By Navi loaded successfully")