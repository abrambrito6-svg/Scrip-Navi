--==================================================================
--  Zenith -- Duelos | HUB -- By Navi
--  Murder Mystery 2 | Script único y autocontenido
--==================================================================
--  Estructura:  Utilidades -> GUI -> ESP -> Combat -> Movimiento
--               -> AutoFarm -> Misc -> Loops -> Print final
--==================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local CoreGui        = game:GetService("CoreGui")
local WS             = workspace
local LP             = Players.LocalPlayer
local Camera         = WS.CurrentCamera

WS:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if WS.CurrentCamera then Camera = WS.CurrentCamera end
end)

--==================================================================
-- 1) UTILIDADES GENERALES
--==================================================================

local function create(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			obj[k] = v
		end
	end
	obj.Parent = parent
	return obj
end

-- Padre del GUI (CoreGui con fallback a PlayerGui)
local GuiParent
do
	local ok = pcall(function()
		local g = Instance.new("ScreenGui")
		g.Parent = CoreGui
		g:Destroy()
	end)
	GuiParent = ok and CoreGui or LP:WaitForChild("PlayerGui")
end

-- Paleta / tema
local Theme = {
	Bg      = Color3.fromRGB(10, 10, 14),
	Bg2     = Color3.fromRGB(18, 18, 24),
	Bg3     = Color3.fromRGB(34, 34, 44),
	Accent  = Color3.fromRGB(139, 92, 246),
	Accent2 = Color3.fromRGB(168, 85, 247),
	Text    = Color3.fromRGB(232, 232, 240),
	Sub     = Color3.fromRGB(150, 150, 165),
	Red     = Color3.fromRGB(255, 70, 70),
	Blue    = Color3.fromRGB(70, 150, 255),
	White   = Color3.fromRGB(255, 255, 255),
}

local COLORS = { Murderer = Theme.Red, Sheriff = Theme.Blue, Innocent = Theme.White }

-- Estado global del script
local State = {
	ESP = false, Glow = true, Names = true, Dist = true, Skel = true, Tracer = true, WeaponESP = true,
	Aimlock = false, AutoShoot = false, WallCheck = true, KillAura = false, AuraRadius = 18, AutoStab = false,
	Fly = false, FlySpeed = 60, Noclip = false, Speed = false, SpeedValue = 32,
	AutoFarm = false, Minimized = false,
}

local Roles = {}
local Connections = {}

local function bind(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Connections, c)
	return c
end

--==================================================================
-- 2) SISTEMA DE NOTIFICACIONES
--==================================================================

local NotifGui = create("ScreenGui", {
	Name = "ZenithNotifs", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, Parent = GuiParent,
})
local NotifHolder = create("Frame", {
	Size = UDim2.new(0, 260, 1, -40), Position = UDim2.new(1, -280, 0, 20),
	BackgroundTransparency = 1, Parent = NotifGui,
}, nil)
create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifHolder })

local function notify(text, color)
	color = color or Theme.Accent
	local box = create("Frame", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Bg2, BackgroundTransparency = 0.08, Parent = NotifHolder,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
	create("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = color, Parent = box })
	create("TextLabel", {
		Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = text, TextTruncate = Enum.TextTruncate.AtEnd, Parent = box,
	})
	box.BackgroundTransparency = 1
	TweenService:Create(box, TweenInfo.new(0.2), { BackgroundTransparency = 0.08 }):Play()
	task.delay(3, function()
		if box.Parent then
			local t = TweenService:Create(box, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
			t:Play()
			t.Completed:Connect(function() box:Destroy() end)
		end
	end)
end

--==================================================================
-- 3) DETECCIÓN DE ROLES (MM2)
--==================================================================

-- Métodos: RoleGui propio, atributos, herramienta equipada/mochila
local function detectRole(plr)
	if plr == LP then
		local pg = LP:FindFirstChild("PlayerGui")
		local rg = pg and pg:FindFirstChild("RoleGui")
		if rg then
			for _, d in ipairs(rg:GetDescendants()) do
				if d:IsA("TextLabel") then
					local t = d.Text
					if t:find("Murder") then return "Murderer" end
					if t:find("Sheriff") then return "Sheriff" end
					if t:find("Innocent") then return "Innocent" end
				end
			end
		end
	end

	local char = plr.Character
	if char then
		local attr = char:GetAttribute("Role") or plr:GetAttribute("Role")
		if typeof(attr) == "string" then
			if attr:find("Murder") then return "Murderer" end
			if attr:find("Sheriff") then return "Sheriff" end
		end
		if char:FindFirstChild("Knife") then return "Murderer" end
		if char:FindFirstChild("Gun") then return "Sheriff" end
	end

	local bp = plr:FindFirstChild("Backpack")
	if bp then
		if bp:FindFirstChild("Knife") then return "Murderer" end
		if bp:FindFirstChild("Gun") then return "Sheriff" end
	end

	return "Innocent"
end

local function scanRoles()
	local murderer, sheriff
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
			local r = detectRole(plr)
			Roles[plr] = r
			if r == "Murderer" then murderer = plr.Name end
			if r == "Sheriff" then sheriff = plr.Name end
		else
			Roles[plr] = Roles[plr] or "Innocent"
		end
	end
	Roles[LP] = Roles[LP] or "Innocent"
	return murderer, sheriff
end

--==================================================================
-- 4) MARCADOR PERMANENTE DE ROLES EN PANTALLA
--==================================================================

local RoleGui = create("ScreenGui", {
	Name = "ZenithRoles", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 90, Parent = GuiParent,
})
local RoleBox = create("Frame", {
	Size = UDim2.new(0, 230, 0, 62), Position = UDim2.new(0, 18, 1, -96),
	BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.25, BorderSizePixel = 0, Parent = RoleGui,
})
create("UICorner", { CornerRadius = UDim.new(0, 8) }, RoleBox)
create("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 0.4 }, RoleBox)

local MurdererLabel = create("TextLabel", {
	Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 6), BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Red,
	TextXAlignment = Enum.TextXAlignment.Left, Text = "Murderer: --", Parent = RoleBox,
})
local SheriffLabel = create("TextLabel", {
	Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 0, 32), BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Blue,
	TextXAlignment = Enum.TextXAlignment.Left, Text = "Sheriff: --", Parent = RoleBox,
})

task.spawn(function()
	while RoleGui.Parent do
		local murderer, sheriff = scanRoles()
		MurdererLabel.Text = "Murderer: " .. (murderer or "--")
		SheriffLabel.Text = "Sheriff: " .. (sheriff or "--")
		task.wait(0.6)
	end
end)

--==================================================================
-- 5) ESP (GLOW, NOMBRES, DISTANCIA, ESQUELETO, LÍNEAS, ARMAS)
--==================================================================

local hasDrawing = false
do
	local ok = pcall(function()
		local l = Drawing.new("Line")
		l:Remove()
	end)
	hasDrawing = ok
end

local ESPData = {}
local Highlights = {}

local BONES_R15 = {
	Head = "Head", UpperTorso = "UpperTorso", LowerTorso = "LowerTorso",
	LUA = "LeftUpperArm", LLA = "LeftLowerArm", LH = "LeftHand",
	RUA = "RightUpperArm", RLA = "RightLowerArm", RH = "RightHand",
	LUL = "LeftUpperLeg", LLL = "LeftLowerLeg", LF = "LeftFoot",
	RUL = "RightUpperLeg", RLL = "RightLowerLeg", RF = "RightFoot",
}

local CONNECTIONS_R15 = {
	{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LUA" }, { "LUA", "LLA" }, { "LLA", "LH" },
	{ "UpperTorso", "RUA" }, { "RUA", "RLA" }, { "RLA", "RH" },
	{ "LowerTorso", "LUL" }, { "LUL", "LLL" }, { "LLL", "LF" },
	{ "LowerTorso", "RUL" }, { "RUL", "RLL" }, { "RLL", "RF" },
}

local CONNECTIONS_R6 = {
	{ "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
	{ "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}

local function clearESP(plr)
	local d = ESPData[plr]
	if d then
		for _, l in ipairs(d.lines) do pcall(function() l:Remove() end) end
		for _, t in ipairs(d.texts) do pcall(function() t:Remove() end) end
		if d.tracer then pcall(function() d.tracer:Remove() end) end
		if d.billboard then d.billboard:Destroy() end
		ESPData[plr] = nil
	end
	local h = Highlights[plr]
	if h then pcall(function() h:Destroy() end); Highlights[plr] = nil end
end

local function buildESP(plr)
	if ESPData[plr] or plr == LP then return end
	local data = { lines = {}, texts = {} }

	if hasDrawing then
		for _ = 1, 20 do
			local l = Drawing.new("Line")
			l.Thickness = 1.6
			l.Transparency = 1
			l.Visible = false
			table.insert(data.lines, l)
		end
		local nameT = Drawing.new("Text")
		nameT.Size = 14; nameT.Center = true; nameT.Outline = true
		nameT.OutlineColor = Color3.new(0, 0, 0); nameT.Visible = false
		data.texts[1] = nameT; data.nameText = nameT

		local distT = Drawing.new("Text")
		distT.Size = 13; distT.Center = true; distT.Outline = true
		distT.OutlineColor = Color3.new(0, 0, 0); distT.Visible = false
		data.texts[2] = distT; data.distText = distT

		local tr = Drawing.new("Line")
		tr.Thickness = 1; tr.Transparency = 0.45; tr.Visible = false
		data.tracer = tr
	else
		-- Fallback sin Drawing: BillboardGui
		local bb = create("BillboardGui", {
			Name = "ZenithESP", Size = UDim2.new(0, 160, 0, 32), StudsOffset = Vector3.new(0, 2.6, 0),
			AlwaysOnTop = true, Enabled = false, Parent = plr.Character,
		})
		local lbl = create("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold, TextSize = 14, TextStrokeTransparency = 0,
			TextColor3 = Theme.White, Text = plr.Name, Parent = bb,
		})
		data.billboard = bb
		data.billboardLabel = lbl
	end

	ESPData[plr] = data
end

local function updateESP(plr)
	local data = ESPData[plr]
	if not data then return end

	local char = plr.Character
	local head = char and char:FindFirstChild("Head")
	local hum  = char and char:FindFirstChildOfClass("Humanoid")

	local function hideAll()
		for _, l in ipairs(data.lines) do l.Visible = false end
		if data.nameText then data.nameText.Visible = false end
		if data.distText then data.distText.Visible = false end
		if data.tracer then data.tracer.Visible = false end
		if data.billboard then data.billboard.Enabled = false end
	end

	if not (char and head and hum and hum.Health > 0) then
		hideAll()
		return
	end

	local role = Roles[plr] or "Innocent"
	local color = COLORS[role] or Theme.White
	local headPos = head.Position
	local dist = math.floor((Camera.CFrame.Position - headPos).Magnitude)

	-- Glow (Highlight)
	if State.Glow then
		local h = Highlights[plr]
		if not h then
			h = create("Highlight", {
				FillColor = color, FillTransparency = 0.72, OutlineColor = color,
				OutlineTransparency = 0.1, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = char,
			})
			Highlights[plr] = h
		end
		h.FillColor = color
		h.OutlineColor = color
	else
		if Highlights[plr] then Highlights[plr]:Destroy(); Highlights[plr] = nil end
	end

	-- Nombres / distancia
	local screenPos, onScreen = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 1.3, 0))

	if data.nameText then
		data.nameText.Visible = State.Names and onScreen
		if data.nameText.Visible then
			data.nameText.Text = plr.Name .. " [" .. role .. "]"
			data.nameText.Color = color
			data.nameText.Position = Vector2.new(screenPos.X, screenPos.Y - 32)
		end
	end

	if data.distText then
		data.distText.Visible = State.Dist and onScreen
		if data.distText.Visible then
			data.distText.Text = tostring(dist) .. "m"
			data.distText.Color = color
			data.distText.Position = Vector2.new(screenPos.X, screenPos.Y - 16)
		end
	end

	if data.billboard then
		data.billboard.Enabled = State.Names and onScreen
		if data.billboardLabel then
			data.billboardLabel.Text = plr.Name .. " [" .. role .. "]"
			data.billboardLabel.TextColor3 = color
		end
	end

	-- Líneas (tracer)
	if data.tracer then
		data.tracer.Visible = State.Tracer and onScreen
		if data.tracer.Visible then
			data.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			data.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
			data.tracer.Color = color
		end
	end

	-- Esqueleto
	for _, l in ipairs(data.lines) do l.Visible = false end
	if State.Skel and hasDrawing then
		local isR15 = hum.RigType == Enum.HumanoidRigType.R15
		local conns = isR15 and CONNECTIONS_R15 or CONNECTIONS_R6
		local idx = 0
		for _, pair in ipairs(conns) do
			local a, b
			if isR15 then
				a = char:FindFirstChild(BONES_R15[pair[1]])
				b = char:FindFirstChild(BONES_R15[pair[2]])
			else
				a = char:FindFirstChild(pair[1])
				b = char:FindFirstChild(pair[2])
			end
			if a and b then
				local sa, oa = Camera:WorldToViewportPoint(a.Position)
				local sb, ob = Camera:WorldToViewportPoint(b.Position)
				if oa and ob then
					idx = idx + 1
					local line = data.lines[idx]
					if line then
						line.From = Vector2.new(sa.X, sa.Y)
						line.To = Vector2.new(sb.X, sb.Y)
						line.Color = color
						line.Visible = true
					end
				end
			end
		end
	end
end

-- Armas tiradas en el suelo
local weaponDrawings = {}

local function updateWeapons()
	for _, d in pairs(weaponDrawings) do pcall(function() d:Remove() end) end
	weaponDrawings = {}
	if not (State.ESP and State.WeaponESP and hasDrawing) then return end

	for _, obj in ipairs(WS:GetChildren()) do
		if obj:IsA("Tool") and (obj.Name == "Knife" or obj.Name == "Gun") then
			local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
			if handle then
				local sp, on = Camera:WorldToViewportPoint(handle.Position)
				if on then
					local txt = Drawing.new("Text")
					txt.Size = 14; txt.Center = true; txt.Outline = true
					txt.OutlineColor = Color3.new(0, 0, 0)
					txt.Color = (obj.Name == "Knife") and Theme.Red or Theme.Blue
					txt.Text = "[ " .. obj.Name .. " ]"
					txt.Position = Vector2.new(sp.X, sp.Y)
					txt.Visible = true
					table.insert(weaponDrawings, txt)
				end
			end
		end
	end
end

bind(RunService.RenderStepped, function()
	for plr in pairs(ESPData) do
		if State.ESP then updateESP(plr) else
			local d = ESPData[plr]
			for _, l in ipairs(d.lines) do l.Visible = false end
			if d.nameText then d.nameText.Visible = false end
			if d.distText then d.distText.Visible = false end
			if d.tracer then d.tracer.Visible = false end
			if d.billboard then d.billboard.Enabled = false end
			if Highlights[plr] then Highlights[plr]:Destroy(); Highlights[plr] = nil end
		end
	end
end)

--==================================================================
-- 6) COMBAT / AIM
--==================================================================

local function hasLineOfSight(from, to)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LP.Character, Camera }
	local res = WS:Raycast(from, to - from, params)
	return res == nil
end

local function getTarget(maxScreen)
	maxScreen = maxScreen or 220
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local best, bestScore, bestPos = nil, math.huge, nil

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local char = plr.Character
			local head = char:FindFirstChild("Head")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if head and hum and hum.Health > 0 then
				local pos = head.Position
				if (Camera.CFrame.Position - pos).Magnitude < 400 then
					local sp, on = Camera:WorldToViewportPoint(pos)
					if on and sp.Z > 0 then
						local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
						if sd < maxScreen then
							local clear = true
							if State.WallCheck then clear = hasLineOfSight(Camera.CFrame.Position, pos) end
							if clear then
								local score = sd
								local role = Roles[plr]
								if role == "Murderer" then score = score * 0.3
								elseif role == "Sheriff" then score = score * 0.9 end
								if score < bestScore then
									bestScore = score
									best = plr
									bestPos = pos
								end
							end
						end
					end
				end
			end
		end
	end
	return best, bestPos
end

local function getEquipped()
	local char = LP.Character
	return char and char:FindFirstChildOfClass("Tool")
end

bind(RunService.RenderStepped, function()
	if State.Aimlock then
		local _, pos = getTarget()
		if pos then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, pos)
		end
	end
end)

-- Auto Shoot
task.spawn(function()
	while true do
		task.wait(0.08)
		if State.AutoShoot then
			local tool = getEquipped()
			if tool and tool.Name == "Gun" then
				local t = getTarget()
				if t then
					pcall(function() tool:Activate() end)
				end
			end
		end
	end
end)

-- Auto Stab
task.spawn(function()
	while true do
		task.wait(0.12)
		if State.AutoStab then
			local tool = getEquipped()
			local char = LP.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if tool and tool.Name == "Knife" and hrp then
				local t = getTarget(320)
				if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
					local d = (t.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
					if d <= 10 then
						pcall(function() tool:Activate() end)
					end
				end
			end
		end
	end
end)

-- Kill Aura
task.spawn(function()
	while true do
		task.wait(0.15)
		if State.KillAura then
			local char = LP.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local tool = getEquipped()
			if hrp and tool then
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LP and plr.Character then
						local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
						local thum = plr.Character:FindFirstChildOfClass("Humanoid")
						if thrp and thum and thum.Health > 0 then
							if (thrp.Position - hrp.Position).Magnitude <= State.AuraRadius then
								pcall(function() tool:Activate() end)
								break
							end
						end
					end
				end
			end
		end
	end
end)

--==================================================================
-- 7) MOVIMIENTO
--==================================================================

local flyBV, flyBG

local function stopFly()
	if flyBV then flyBV:Destroy(); flyBV = nil end
	if flyBG then flyBG:Destroy(); flyBG = nil end
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

local function startFly()
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end
	stopFly()
	flyBV = create("BodyVelocity", {
		MaxForce = Vector3.new(1e5, 1e5, 1e5), P = 1250, Velocity = Vector3.zero, Parent = hrp,
	})
	flyBG = create("BodyGyro", {
		MaxTorque = Vector3.new(1e5, 1e5, 1e5), P = 2000, CFrame = Camera.CFrame, Parent = hrp,
	})
	hum.PlatformStand = true
end

bind(RunService.RenderStepped, function()
	if State.Fly and flyBV and flyBG then
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			local dir = hum.MoveDirection
			if dir.Magnitude > 0 then
				flyBV.Velocity = Camera.CFrame:VectorToWorldSpace(dir) * State.FlySpeed
			else
				flyBV.Velocity = Vector3.zero
			end
			flyBG.CFrame = Camera.CFrame
		end
	end
end)

bind(RunService.Stepped, function()
	if State.Noclip and LP.Character then
		for _, p in ipairs(LP.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

bind(LP.CharacterAdded, function(char)
	task.wait(1)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and State.Speed then hum.WalkSpeed = State.SpeedValue end
	if State.Fly then startFly() end
end)

--==================================================================
-- 8) AUTO FARM
--==================================================================

local function getHRP()
	local c = LP.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function findCoin()
	local hrp = getHRP()
	if not hrp then return nil end
	local best, bestD = nil, math.huge
	local function check(container)
		for _, obj in ipairs(container:GetChildren()) do
			if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
				local d = (obj.Position - hrp.Position).Magnitude
				if d < bestD then bestD = d; best = obj end
			end
		end
	end
	check(WS)
	for _, f in ipairs(WS:GetChildren()) do
		if f:IsA("Folder") or f:IsA("Model") then check(f) end
	end
	return best
end

local function tryQueue()
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return end
	for _, obj in ipairs(pg:GetDescendants()) do
		if obj:IsA("TextButton") then
			local n = obj.Name:lower()
			local t = (obj.Text or ""):lower()
			if n:find("play") or t:find("play") then
				pcall(function() obj.MouseButton1Click:Fire() end)
				pcall(function() obj:Activate() end)
				return true
			end
		end
	end
	return false
end

task.spawn(function()
	while true do
		task.wait(0.35)
		if State.AutoFarm then
			local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
			local hrp = getHRP()
			if hum and hrp and hum.Health > 0 then
				local coin = findCoin()
				if coin then
					hum:MoveTo(coin.Position)
				elseif not getEquipped() then
					tryQueue()
				end
			elseif hrp == nil then
				tryQueue()
			end
		end
	end
end)

--==================================================================
-- 9) CONSTRUCCIÓN DEL GUI
--==================================================================

local Main = create("Frame", {
	Name = "ZenithMain",
	Size = UDim2.new(0, 640, 0, 430),
	Position = UDim2.new(0.5, -320, 0.5, -215),
	BackgroundColor3 = Theme.Bg,
	BorderSizePixel = 0,
	Parent = create("ScreenGui", {
		Name = "ZenithHUB", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100, Parent = GuiParent,
	}),
})
create("UICorner", { CornerRadius = UDim.new(0, 10) }, Main)
create("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 0.5 }, Main)

-- Fondo con la imagen
local BgImage = create("ImageLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = "https://files.catbox.moe/cmrqdt.jpg",
	ImageTransparency = 0.55,
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 1,
	Parent = Main,
})
create("UICorner", { CornerRadius = UDim.new(0, 10) }, BgImage)
create("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.45,
	BorderSizePixel = 0, ZIndex = 2, Parent = Main,
})

-- Barra de título
local TitleBar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 38),
	BackgroundColor3 = Theme.Bg2,
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	ZIndex = 3,
	Parent = Main,
})
create("UICorner", { CornerRadius = UDim.new(0, 10) }, TitleBar)
create("Frame", {
	Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12),
	BackgroundColor3 = Theme.Bg2, BorderSizePixel = 0, ZIndex = 3, Parent = TitleBar,
})

create("TextLabel", {
	Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 14, 0, 0),
	BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14,
	TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
	Text = "Zenith -- Duelos | HUB -- By Navi", ZIndex = 4, Parent = TitleBar,
})

-- Botón minimizar
local MinBtn = create("TextButton", {
	Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -56, 0.5, -12),
	BackgroundColor3 = Theme.Bg3, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14,
	TextColor3 = Theme.Text, AutoButtonColor = false, ZIndex = 4, Parent = TitleBar,
})
create("UICorner", { CornerRadius = UDim.new(0, 6) }, MinBtn)

-- Botón cerrar
local CloseBtn = create("TextButton", {
	Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -28, 0.5, -12),
	BackgroundColor3 = Theme.Bg3, Text = "✕", Font = Enum.Font.GothamBold, TextSize = 13,
	TextColor3 = Theme.Red, AutoButtonColor = false, ZIndex = 4, Parent = TitleBar,
})
create("UICorner", { CornerRadius = UDim.new(0, 6) }, CloseBtn)

-- Botón flotante para restaurar
local FloatBtn = create("TextButton", {
	Name = "ZenithFloat",
	Size = UDim2.new(0, 52, 0, 52),
	Position = UDim2.new(0, 24, 0.5, -26),
	BackgroundColor3 = Theme.Bg,
	Text = "Z",
	Font = Enum.Font.GothamBlack,
	TextSize = 22,
	TextColor3 = Theme.Accent2,
	AutoButtonColor = false,
	Visible = false,
	Parent = create("ScreenGui", {
		Name = "ZenithFloatGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100, Parent = GuiParent,
	}),
})
create("UICorner", { CornerRadius = UDim.new(1, 0) }, FloatBtn)
create("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Transparency = 0.2 }, FloatBtn)

-- Contenedor del cuerpo
local Body = create("Frame", {
	Size = UDim2.new(1, 0, 1, -38), Position = UDim2.new(0, 0, 0, 38),
	BackgroundTransparency = 1, ZIndex = 3, Parent = Main,
})

-- Sidebar
local Sidebar = create("Frame", {
	Size = UDim2.new(0, 132, 1, -20), Position = UDim2.new(0, 10, 0, 10),
	BackgroundColor3 = Theme.Bg2, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = Body,
})
create("UICorner", { CornerRadius = UDim.new(0, 8) }, Sidebar)
create("UIListLayout", { Padding = UDim.new(0, 6), Parent = Sidebar })
create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, Sidebar)

-- Área de contenido
local ContentArea = create("Frame", {
	Size = UDim2.new(1, -162, 1, -20), Position = UDim2.new(0, 152, 0, 10),
	BackgroundColor3 = Theme.Bg2, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = Body,
})
create("UICorner", { CornerRadius = UDim.new(0, 8) }, ContentArea)

local Tabs = {}
local CurrentTab

local function makeTab(name)
	local page = create("ScrollingFrame", {
		Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Parent = ContentArea,
	})
	create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 8) }, page)
	create("UIListLayout", { Padding = UDim.new(0, 4), Parent = page })

	local btn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Bg3, BackgroundTransparency = 0.35,
		Text = name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Sub,
		AutoButtonColor = false, Parent = Sidebar,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

	Tabs[name] = { page = page, button = btn }
	return page
end

local function switchTab(name)
	for n, t in pairs(Tabs) do
		local active = (n == name)
		t.page.Visible = active
		t.button.TextColor3 = active and Theme.Text or Theme.Sub
		TweenService:Create(t.button, TweenInfo.new(0.15), {
			BackgroundColor3 = active and Theme.Accent or Theme.Bg3,
			BackgroundTransparency = active and 0.25 or 0.35,
		}):Play()
	end
	CurrentTab = name
end

-- Controles reutilizables
local function makeToggle(parent, text, default, callback)
	local row = create("Frame", { Size = UDim2.new(1, -16, 0, 28), BackgroundTransparency = 1, Parent = parent })
	create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = text, Parent = row,
	})
	local btn = create("TextButton", {
		Size = UDim2.new(0, 40, 0, 18), Position = UDim2.new(1, -44, 0.5, -9),
		BackgroundColor3 = Theme.Bg3, Text = "", AutoButtonColor = false, Parent = row,
	})
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, btn)
	local knob = create("Frame", {
		Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(190, 190, 200), Parent = btn,
	})
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

	local state = default
	local function render()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = state and Theme.Accent or Theme.Bg3 }):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {
			Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
			BackgroundColor3 = state and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 160),
		}):Play()
		if callback then callback(state) end
	end
	btn.MouseButton1Click:Connect(function()
		state = not state
		render()
	end)
	render()
	return { Set = function(v) if v ~= state then state = v; render() end end }
end

local function makeSlider(parent, text, min, max, default, callback)
	local row = create("Frame", { Size = UDim2.new(1, -16, 0, 42), BackgroundTransparency = 1, Parent = parent })
	local label = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = text .. "  [" .. tostring(default) .. "]", Parent = row,
	})
	local bar = create("TextButton", {
		Size = UDim2.new(1, -8, 0, 6), Position = UDim2.new(0, 0, 0, 28),
		BackgroundColor3 = Theme.Bg3, Text = "", AutoButtonColor = false, Parent = row,
	})
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
	local fill = create("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Theme.Accent, Parent = bar,
	})
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

	local value = default
	local dragging = false

	local function setFromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * rel + 0.5)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		label.Text = text .. "  [" .. tostring(value) .. "]"
		if callback then callback(value) end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	bind(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	bind(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return { Set = function(v)
		value = v
		fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
		label.Text = text .. "  [" .. tostring(v) .. "]"
	end }
end

local function makeButton(parent, text, callback, color)
	local btn = create("TextButton", {
		Size = UDim2.new(1, -16, 0, 28), BackgroundColor3 = color or Theme.Accent,
		BackgroundTransparency = 0.25, Text = text, Font = Enum.Font.GothamMedium,
		TextSize = 13, TextColor3 = Theme.Text, AutoButtonColor = false, Parent = parent,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
	btn.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
	return btn
end

local function makeLabel(parent, text, color)
	local lbl = create("TextLabel", {
		Size = UDim2.new(1, -16, 0, 22), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		TextSize = 12, TextColor3 = color or Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left,
		Text = text, Parent = parent,
	})
	return lbl
end

--==================================================================
-- 10) PESTAÑAS Y CONTROLES
--==================================================================

-- ESP
local espPage = makeTab("ESP")
makeToggle(espPage, "Activar ESP", false, function(v)
	State.ESP = v
	if v then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP then buildESP(plr) end
		end
		notify("ESP activado", Theme.Accent)
	else
		for plr in pairs(ESPData) do clearESP(plr) end
		notify("ESP desactivado", Theme.Sub)
	end
end)
makeToggle(espPage, "ESP Glow", true, function(v) State.Glow = v end)
makeToggle(espPage, "Ver Nombres", true, function(v) State.Names = v end)
makeToggle(espPage, "Ver Distancia", true, function(v) State.Dist = v end)
makeToggle(espPage, "ESP Esqueleto", true, function(v) State.Skel = v end)
makeToggle(espPage, "ESP Líneas", true, function(v) State.Tracer = v end)
makeToggle(espPage, "ESP Arma Tirada", true, function(v) State.WeaponESP = v end)
task.spawn(function()
	while true do
		task.wait(0.25)
		updateWeapons()
	end
end)

-- Combat
local combatPage = makeTab("Combat")
makeToggle(combatPage, "Aimlock (prioriza Murderer)", false, function(v)
	State.Aimlock = v
	if v then notify("Aimlock activado", Theme.Accent) end
end)
makeToggle(combatPage, "Auto Shoot", false, function(v) State.AutoShoot = v end)
makeToggle(combatPage, "Wall Check", true, function(v) State.WallCheck = v end)
makeToggle(combatPage, "Auto Stab", false, function(v) State.AutoStab = v end)
makeToggle(combatPage, "Kill Aura", false, function(v) State.KillAura = v end)
makeSlider(combatPage, "Radio de Aura", 5, 50, 18, function(v) State.AuraRadius = v end)

-- Movimiento
local movePage = makeTab("Movimiento")
makeToggle(movePage, "Fly", false, function(v)
	State.Fly = v
	if v then startFly(); notify("Fly activado", Theme.Accent) else stopFly() end
end)
makeSlider(movePage, "Velocidad de Fly", 20, 250, 60, function(v) State.FlySpeed = v end)
makeToggle(movePage, "Noclip", false, function(v)
	State.Noclip = v
	if not v and LP.Character then
		for _, p in ipairs(LP.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end)
makeToggle(movePage, "Speed (Caminar Rápido)", false, function(v)
	State.Speed = v
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = v and State.SpeedValue or 16 end
end)
makeSlider(movePage, "Velocidad al caminar", 16, 100, 32, function(v)
	State.SpeedValue = v
	if State.Speed then
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end
end)

-- AutoFarm
local farmPage = makeTab("AutoFarm")
makeToggle(farmPage, "Activar AutoFarm", false, function(v)
	State.AutoFarm = v
	notify(v and "AutoFarm activado" or "AutoFarm desactivado", v and Theme.Accent or Theme.Sub)
end)
makeButton(farmPage, "Ir a la moneda más cercana", function()
	local coin = findCoin()
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if coin and hum then
		hum:MoveTo(coin.Position)
		notify("Moneda marcada", Theme.Accent)
	else
		notify("No hay monedas cerca", Theme.Sub)
	end
end)
makeButton(farmPage, "Buscar partida (cola)", function()
	if tryQueue() then notify("Cola solicitada", Theme.Accent) else notify("Botón de partida no encontrado", Theme.Sub) end
end)
makeLabel(farmPage, "Recoge monedas y encola rondas automáticamente.", Theme.Sub)

-- Misc
local miscPage = makeTab("Misc")
makeButton(miscPage, "Revelar roles ahora", function()
	local m, s = scanRoles()
	MurdererLabel.Text = "Murderer: " .. (m or "--")
	SheriffLabel.Text = "Sheriff: " .. (s or "--")
	notify("Roles actualizados", Theme.Accent)
end)
makeButton(miscPage, "Reunirse de nuevo (Rejoin)", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
makeButton(miscPage, "Mostrar / Ocultar marcador de roles", function()
	RoleBox.Visible = not RoleBox.Visible
end, Theme.Bg3)
makeButton(miscPage, "Reiniciar personaje", function()
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = 0 end
end, Theme.Bg3)
makeLabel(miscPage, "Zenith HUB · By Navi · MM2", Theme.Accent)

switchTab("ESP")

--==================================================================
-- 11) ARRASTRE DE LA VENTANA
--==================================================================

local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)
bind(UIS.InputChanged, function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)
bind(UIS.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--==================================================================
-- 12) MINIMIZAR / RESTAURAR / CERRAR
--==================================================================

local function minimize()
	State.Minimized = true
	Main.Visible = false
	FloatBtn.Visible = true
end

local function restore()
	State.Minimized = false
	Main.Visible = true
	FloatBtn.Visible = false
end

MinBtn.MouseButton1Click:Connect(minimize)
FloatBtn.MouseButton1Click:Connect(restore)

CloseBtn.MouseButton1Click:Connect(function()
	-- Limpieza total
	for plr in pairs(ESPData) do clearESP(plr) end
	for _, d in pairs(weaponDrawings) do pcall(function() d:Remove() end) end
	for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
	stopFly()
	for _, guiName in ipairs({ "ZenithHUB", "ZenithFloatGui", "ZenithNotifs", "ZenithRoles" }) do
		local g = GuiParent:FindFirstChild(guiName)
		if g then g:Destroy() end
	end
	notify("Zenith cerrado", Theme.Sub)
end)

--==================================================================
-- 13) CICLO DE VIDA DE JUGADORES
--==================================================================

bind(Players.PlayerAdded, function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		if State.ESP then buildESP(plr) end
	end)
end)

bind(Players.PlayerRemoving, function(plr)
	clearESP(plr)
	Roles[plr] = nil
end)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LP then
		plr.CharacterAdded:Connect(function()
			task.wait(0.5)
			if State.ESP then buildESP(plr) end
		end)
		if State.ESP then buildESP(plr) end
	end
end

--==================================================================
-- 14) MENSAJE FINAL
--==================================================================

notify("Zenith cargado · By Navi", Theme.Accent)
print("Zenith -- Duelos | HUB -- By Navi | Loaded")