--[[
	═══════════════════════════════════════════════════════════════════
	 Zenith -- Duelos | HUB -- By Navi
	 ---------------------------------------------------------------
	 · ESP completo (Glow / Nombres / Distancia / Esqueleto / Líneas / Arma tirada)
	 · Aimlock con WallCheck, prioridad por rol y AutoShoot
	 · Kill Aura / Auto Stab / Teleport-Stab
	 · Fly, Noclip, Speed
	 · UI propia, oscura, arrastrable, con pestañas y toggles
	 ---------------------------------------------------------------
	 Uso:  loadstring(game:HttpGet("URL_DEL_SCRIPT"))()
	═══════════════════════════════════════════════════════════════════
]]

--=====================================================================
-- 1. SERVICIOS Y VARIABLES
--=====================================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Workspace          = game:GetService("Workspace")
local VirtualInputManager= game:GetService("VirtualInputManager")
local LP                 = Players.LocalPlayer
local Camera             = Workspace.CurrentCamera

local DRAWING_OK = (typeof(Drawing) == "table" or type(Drawing) == "table")

-- Contenedor del GUI (gethui si el executor lo soporta)
local function getGuiParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	return game:GetService("CoreGui")
end

-- Limpieza de ejecuciones previas
pcall(function()
	local old = getGuiParent():FindFirstChild("ZenithHub")
	if old then old:Destroy() end
end)

--=====================================================================
-- 2. CONFIGURACIÓN GLOBAL
--=====================================================================
local Config = {
	-- ESP
	ESPGlow      = false,
	ESPNames     = false,
	ESPDistance  = false,
	ESPSkeleton  = false,
	ESPLines     = false,
	ESPGunDrop   = false,
	-- Combate
	Aimlock      = false,
	AimMode      = "Cercano",   -- "Cercano" | "Murderer" | "Sheriff"
	AimFOV       = 220,
	AimSmooth    = 0.35,
	WallCheck    = true,
	AutoShoot    = false,
	KillAura     = false,
	KillAuraRange= 25,
	AutoStab     = false,
	-- Movimiento
	Fly          = false,
	FlySpeed     = 50,
	Noclip       = false,
	Speed        = false,
	WalkSpeed    = 60,
}
getgenv().Zenith = Config

local RoleColor = {
	Murderer = Color3.fromRGB(255, 65, 65),
	Sheriff  = Color3.fromRGB(70, 145, 255),
	Innocent = Color3.fromRGB(70, 230, 130),
}

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
-- 3. HELPERS GENERALES
--=====================================================================
local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
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

--=====================================================================
-- 4. DETECCIÓN DE ROLES (varios métodos, con caché)
--=====================================================================
local RoleCache = {}

local function detectRole(player)
	local char = player.Character

	-- 4.1 Atributos modernos en Player / Character
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

	-- 4.2 Herramientas (Knife = Murderer, Gun = Sheriff)
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

	-- 4.3 Etiqueta de rol en PlayerGui
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
	if c and (tick() - c.t) < 1 then
		return c.role
	end
	local role = "Innocent"
	pcall(function() role = detectRole(player) end)
	RoleCache[player] = {role = role, t = tick()}
	return role
end

local function roleColor(player)
	return RoleColor[getRole(player)] or RoleColor.Innocent
end

--=====================================================================
-- 5. GUI
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

-- ---------- Componentes ----------
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
		if not silent and callback then
			pcall(callback, state)
		end
	end

	local click = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
	}, switch)

	click.MouseButton1Click:Connect(function()
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
		if not silent and callback then
			pcall(callback, value)
		end
	end

	local function fromInput(posX)
		local rel = (posX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
		apply(min + (max - min) * math.clamp(rel, 0, 1))
	end

	new("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
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
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
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
	btn.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
	return btn
end

local function sectionTitle(parent, text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = string.upper(text),
	}, parent)
end

--=====================================================================
-- 6. ESP
--=====================================================================
local ESPFolder = new("Folder", {Name = "ZenithESP"})
pcall(function() ESPFolder.Parent = getGuiParent() end)

local ESPData = {}   -- [player] = {highlight, name, dist, lines[], bones[], role}

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

local function buildESP(player)
	if player == LP or ESPData[player] then return end

	local data = {
		highlight = new("Highlight", {
			FillTransparency = 0.65,
			OutlineTransparency = 0.15,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			Enabled = false,
		}, ESPFolder),
		name = makeText(13, true),
		dist = makeText(11, true),
		line = makeLine(1.4),
		bones = {},
		role = "Innocent",
	}

	for i = 1, #R15Bones do
		data.bones[i] = makeLine(1.2)
	end

	ESPData[player] = data
end

local function destroyESP(player)
	local data = ESPData[player]
	if not data then return end
	ESPData[player] = nil
	pcall(function() data.highlight:Destroy() end)
	if data.name then data.name:Remove() end
	if data.dist then data.dist:Remove() end
	if data.line then data.line:Remove() end
	for _, l in ipairs(data.bones) do
		if l then l:Remove() end
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
	data.role = role

	-- Glow
	data.highlight.Adornee = ok and char or nil
	data.highlight.FillColor = color
	data.highlight.OutlineColor = color
	data.highlight.Enabled = Config.ESPGlow and ok and true or false

	if not ok then
		if data.name then data.name.Visible = false end
		if data.dist then data.dist.Visible = false end
		if data.line then data.line.Visible = false end
		for _, l in ipairs(data.bones) do if l then l.Visible = false end end
		return
	end

	local headPos = head.Position

	-- Nombres
	if data.name then
		local onScreen, screenPos = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 1.6, 0))
		data.name.Visible = Config.ESPNames and onScreen
		if data.name.Visible then
			data.name.Position = Vector2.new(screenPos.X, screenPos.Y)
			data.name.Text = string.format("%s [%s]", player.Name, role)
			data.name.Color = color
		end
	end

	-- Distancia
	if data.dist then
		local myRoot = getRoot(LP)
		local d = myRoot and math.floor((myRoot.Position - headPos).Magnitude) or 0
		local onScreen, screenPos = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.9, 0))
		data.dist.Visible = Config.ESPDistance and onScreen
		if data.dist.Visible then
			data.dist.Position = Vector2.new(screenPos.X, screenPos.Y)
			data.dist.Text = tostring(d) .. " studs"
			data.dist.Color = color
		end
	end

	-- Líneas al centro
	if data.line then
		local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
		local onScreen, screenPos = Camera:WorldToViewportPoint(headPos)
		data.line.Visible = Config.ESPLines and onScreen
		if data.line.Visible then
			data.line.From = center
			data.line.To = Vector2.new(screenPos.X, screenPos.Y)
			data.line.Color = color
		end
	end

	-- Esqueleto
	local bones = (char:FindFirstChild("UpperTorso") and R15Bones) or R6Bones
	for i, l in ipairs(data.bones) do
		local bone = bones[i]
		if l then
			if bone and Config.ESPSkeleton then
				local a = char:FindFirstChild(bone[1])
				local b = char:FindFirstChild(bone[2])
				if a and b then
					local pa = Camera:WorldToViewportPoint(a.Position)
					local pb = Camera:WorldToViewportPoint(b.Position)
					if pa.Z > 0 and pb.Z > 0 then
						l.From = Vector2.new(pa.X, pa.Y)
						l.To   = Vector2.new(pb.X, pb.Y)
						l.Color = color
						l.Visible = true
					else
						l.Visible = false
					end
				else
					l.Visible = false
				end
			else
				l.Visible = false
			end
		end
	end
end

-- ---------- ESP de arma tirada ----------
local GunDrops = {}

local function isGunDrop(inst)
	if not inst:IsA("BasePart") then return false end
	local n = inst.Name:lower()
	if n:find("drop") and (n:find("gun") or n:find("knife") or n:find("weapon")) then return true end
	if n == "gundrop" or n == "gundropped" or n == "droppedgun" then return true end
	return false
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
-- 7. AIMLOCK / COMBATE
--=====================================================================
local CurrentTarget = nil
local rayParams = RaycastParams.new()
pcall(function() rayParams.FilterType = Enum.RaycastFilterType.Exclude end)

local function hasWallClear(targetPart)
	if not Config.WallCheck then return true end
	local origin = Camera.CFrame.Position
	local dir = targetPart.Position - origin
	rayParams.FilterDescendantsInstances = {LP.Character, targetPart.Parent}
	local res = Workspace:Raycast(origin, dir, rayParams)
	return res == nil
end

local function pickTarget()
	local best, bestScore = nil, math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and alive(p) then
			local 