--[[ =====================================================================
     NAVI ONYX · v3.0
     Interfaz de dos columnas · minimizar · config persistente
     ===================================================================== ]]

if getgenv().NaviCleanup then
	pcall(getgenv().NaviCleanup)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer
local player = LP

local isEnemy, estaEnLobby, IsInMatchStrict
local esEnemigoValido, esCuchillo, esPistola

local function getCamera()
	return workspace.CurrentCamera
end

--=============================== PALETA ===============================
local C = {
	bg1     = Color3.fromRGB(26, 3, 6),
	bg2     = Color3.fromRGB(74, 7, 12),
	panel   = Color3.fromRGB(19, 2, 4),
	panel2  = Color3.fromRGB(32, 4, 8),
	stroke  = Color3.fromRGB(158, 18, 30),
	accent  = Color3.fromRGB(228, 30, 44),
	accent2 = Color3.fromRGB(255, 74, 86),
	text    = Color3.fromRGB(244, 236, 236),
	dim     = Color3.fromRGB(176, 122, 128),
	track   = Color3.fromRGB(58, 8, 14),
	white   = Color3.fromRGB(255, 255, 255),
}

local FB = Enum.Font.GothamBold
local FM = Enum.Font.GothamMedium
local FR = Enum.Font.Gotham

local function new(class, props, parent)
	local inst = Instance.new(class)
	local par = parent
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				par = v
			else
				inst[k] = v
			end
		end
	end
	if par then
		inst.Parent = par
	end
	return inst
end

local function tw(obj, dur, props)
	local t = TweenService:Create(obj, TweenInfo.new(dur or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

--=============================== CONFIG ===============================
local CONFIG_DIR = "Navi_Onyx"
local CONFIG_FILE = CONFIG_DIR .. "/config.json"
local flags = {}

local function tieneArchivos()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local guardando = false
local function guardarConfig()
	if not tieneArchivos() then
		return
	end
	local data = {}
	for flag, obj in pairs(flags) do
		data[flag] = obj.Value
	end
	pcall(function()
		if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(CONFIG_DIR) then
			makefolder(CONFIG_DIR)
		end
		writefile(CONFIG_FILE, HttpService:JSONEncode(data))
	end)
end

local function guardarDiferido()
	if guardando then
		return
	end
	guardando = true
	task.delay(0.8, function()
		guardando = false
		guardarConfig()
	end)
end

local function cargarConfig()
	if not tieneArchivos() or not isfile(CONFIG_FILE) then
		return 0
	end
	local ok, raw = pcall(readfile, CONFIG_FILE)
	if not ok or type(raw) ~= "string" then
		return 0
	end
	local ok2, data = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not ok2 or type(data) ~= "table" then
		return 0
	end
	local aplicados = 0
	for flag, valor in pairs(data) do
		local obj = flags[flag]
		if obj and obj.Set then
			pcall(obj.Set, obj, valor, true)
			aplicados = aplicados + 1
		end
	end
	return aplicados
end

--=============================== GUI RAIZ ===============================
local gui = new("ScreenGui", {
	Name = "Navi",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
})
if gethui then
	pcall(function()
		gui.Parent = gethui()
	end)
end
if not gui.Parent then
	gui.Parent = LP:WaitForChild("PlayerGui")
end

getgenv().NaviCleanup = function()
	gui:Destroy()
end

local build = function()

local main = new("Frame", {
	Size = UDim2.fromOffset(840, 470),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.bg1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 12) }, main)
new("UIStroke", { Color = C.stroke, Thickness = 1.5, Transparency = 0.1 }, main)
new("UIGradient", {
	Color = ColorSequence.new(C.bg2, C.bg1),
	Rotation = 90,
	Transparency = NumberSequence.new(0.1, 0.3),
}, main)

-- FONDO (no se toca)
local bgImage = new("ImageLabel", {
	Name = "Fondo",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = "rbxassetid://126573191582738",
	ImageTransparency = 0.55,
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 1,
}, main)
new("UICorner", { CornerRadius = UDim.new(0, 12) }, bgImage)

local bgIds = {
	"126573191582738",
	"87524321260822",
	"126573191582738",
	"87524321260822",
}

task.spawn(function()
	local index = 1
	while main.Parent do
		task.wait(5)
		index = index % #bgIds + 1
		tw(bgImage, 0.45, { ImageTransparency = 1 })
		task.wait(0.45)
		bgImage.Image = "rbxassetid://" .. bgIds[index]
		tw(bgImage, 0.45, { ImageTransparency = 0.55 })
	end
end)

--=========================== NOTIFICACIONES ===========================
local notifyHolder = new("Frame", {
	Size = UDim2.new(0, 258, 1, -24),
	Position = UDim2.new(1, -272, 0, 12),
	BackgroundTransparency = 1,
	ZIndex = 60,
}, gui)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, notifyHolder)

local function notify(texto, encendido)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = C.panel2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, notifyHolder)
	new("UICorner", { CornerRadius = UDim.new(0, 7) }, card)
	local stroke = new("UIStroke", { Color = encendido and C.accent or C.dim, Transparency = 1 }, card)
	new("Frame", {
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = encendido and C.accent or C.dim,
		BorderSizePixel = 0,
	}, card)
	local lbl = new("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 11, 0, 0),
		BackgroundTransparency = 1,
		Font = FM,
		TextSize = 12,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = texto,
		TextTransparency = 1,
	}, card)

	tw(card, 0.15, { BackgroundTransparency = 0.05 })
	tw(stroke, 0.15, { Transparency = 0.15 })
	tw(lbl, 0.15, { TextTransparency = 0 })

	task.delay(2.3, function()
		tw(card, 0.2, { BackgroundTransparency = 1 })
		tw(stroke, 0.2, { Transparency = 1 })
		tw(lbl, 0.2, { TextTransparency = 1 })
		task.wait(0.25)
		card:Destroy()
	end)
end

--=============================== HEADER ===============================
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 54),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 5,
}, main)
new("UIStroke", { Color = C.stroke, Thickness = 1, Transparency = 0.45 }, header)

new("TextLabel", {
	Size = UDim2.fromOffset(160, 20),
	Position = UDim2.new(0, 16, 0, 17),
	BackgroundTransparency = 1,
	Font = FB,
	TextSize = 15,
	TextColor3 = C.accent,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "NAVI ONYX",
}, header)

local logo = new("Frame", {
	Size = UDim2.fromOffset(40, 40),
	Position = UDim2.new(0.5, -20, 0, 7),
	BackgroundColor3 = Color3.fromRGB(10, 1, 2),
	BorderSizePixel = 0,
	ZIndex = 6,
}, header)
new("UICorner", { CornerRadius = UDim.new(0, 9) }, logo)
new("UIStroke", { Color = C.accent, Thickness = 2 }, logo)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Font = FB,
	TextSize = 24,
	TextColor3 = C.accent,
	Text = "N",
}, logo)

new("TextLabel", {
	Size = UDim2.fromOffset(34, 18),
	Position = UDim2.new(0.5, 32, 0, 18),
	BackgroundTransparency = 1,
	Font = FM,
	TextSize = 11,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "34",
}, header)

local pingLbl = new("TextLabel", {
	Size = UDim2.fromOffset(74, 18),
	Position = UDim2.new(0.5, 62, 0, 18),
	BackgroundTransparency = 1,
	Font = FM,
	TextSize = 11,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "PING: --",
}, header)

new("TextLabel", {
	Size = UDim2.fromOffset(50, 18),
	Position = UDim2.new(0.5, 134, 0, 18),
	BackgroundTransparency = 1,
	Font = FM,
	TextSize = 11,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "VER: 3.0",
}, header)

task.spawn(function()
	while main.Parent do
		local ok, v = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		pingLbl.Text = "PING: " .. (ok and math.floor(v) or 0) .. "ms"
		task.wait(1)
	end
end)

local searchBox = new("TextBox", {
	Size = UDim2.fromOffset(186, 30),
	Position = UDim2.new(1, -262, 0, 12),
	BackgroundColor3 = Color3.fromRGB(10, 1, 2),
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
	Font = FR,
	TextSize = 12,
	TextColor3 = C.text,
	PlaceholderText = "Buscar...",
	PlaceholderColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	Text = "",
	ZIndex = 6,
}, header)
new("UICorner", { CornerRadius = UDim.new(0, 7) }, searchBox)
new("UIStroke", { Color = C.stroke, Transparency = 0.55 }, searchBox)
new("UIPadding", { PaddingLeft = UDim.new(0, 9) }, searchBox)

local minBtn = new("TextButton", {
	Size = UDim2.fromOffset(22, 22),
	Position = UDim2.new(1, -66, 0, 15),
	BackgroundTransparency = 1,
	Font = FB,
	TextSize = 16,
	TextColor3 = C.dim,
	Text = "–",
}, header)

local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(22, 22),
	Position = UDim2.new(1, -38, 0, 15),
	BackgroundTransparency = 1,
	Font = FB,
	TextSize = 16,
	TextColor3 = C.dim,
	Text = "×",
}, header)

--======================= BOTÓN FLOTANTE REABRIR =======================
local reopen = new("TextButton", {
	Size = UDim2.fromOffset(44, 44),
	Position = UDim2.fromOffset(24, 24),
	BackgroundColor3 = C.accent,
	BorderSizePixel = 0,
	Font = FB,
	TextSize = 20,
	TextColor3 = C.white,
	Text = "N",
	Visible = false,
	AutoButtonColor = false,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, reopen)
new("UIStroke", { Color = C.accent2, Thickness = 1.5 }, reopen)

local function minimizar()
	main.Visible = false
	reopen.Visible = true
end

local function restaurar()
	main.Visible = true
	reopen.Visible = false
end

minBtn.MouseButton1Click:Connect(minimizar)
closeBtn.MouseButton1Click:Connect(minimizar)
reopen.MouseButton1Click:Connect(restaurar)

do
	local arrastrando = false
	local inicio, inicioPos
	reopen.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = true
			inicio = i.Position
			inicioPos = reopen.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not arrastrando then
			return
		end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - inicio
			reopen.Position = UDim2.new(inicioPos.X.Scale, inicioPos.X.Offset + d.X, inicioPos.Y.Scale, inicioPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = false
		end
	end)
end

--=============================== CUERPO ===============================
local body = new("Frame", {
	Size = UDim2.new(1, 0, 1, -80),
	Position = UDim2.new(0, 0, 0, 54),
	BackgroundTransparency = 1,
	ZIndex = 4,
}, main)

local sidebar = new("Frame", {
	Size = UDim2.new(0, 172, 1, -10),
	Position = UDim2.new(0, 10, 0, 5),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ZIndex = 5,
}, body)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, sidebar)
new("UIStroke", { Color = C.stroke, Transparency = 0.5 }, sidebar)
new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, sidebar)
new("UIPadding", {
	PaddingTop = UDim.new(0, 8),
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8),
}, sidebar)

local content = new("Frame", {
	Size = UDim2.new(1, -194, 1, -10),
	Position = UDim2.new(0, 186, 0, 5),
	BackgroundTransparency = 1,
	ZIndex = 5,
}, body)

local footer = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 26),
	Position = UDim2.new(0, 0, 1, -28),
	BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Font = FM,
	TextSize = 11,
	TextColor3 = C.dim,
	Text = "Navi Onyx v3.0",
}, main)
new("UIStroke", { Color = C.stroke, Transparency = 0.65 }, footer)

--============================= COMPONENTES =============================
local tabs = {}
local activeTab

local function makeTab(nombre, icono)
	local page = new("ScrollingFrame", {
		Name = nombre,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 5,
	}, content)
	new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10) }, page)

	local fila = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, page)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, fila)

	local function columna(orden)
		local col = new("Frame", {
			Size = UDim2.new(0, 296, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = orden,
		}, fila)
		new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, col)
		return col
	end

	local colA = columna(1)
	local colB = columna(2)

	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = C.accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = FM,
		TextSize = 12.5,
		TextColor3 = C.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "  " .. icono .. "    " .. nombre,
		AutoButtonColor = false,
	}, sidebar)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

	local tab = { page = page, btn = btn, colA = colA, colB = colB, usarA = true, rows = {} }
	tabs[#tabs + 1] = tab

	btn.MouseButton1Click:Connect(function()
		if activeTab == tab then
			return
		end
		for _, t in ipairs(tabs) do
			t.page.Visible = false
			tw(t.btn, 0.12, { BackgroundTransparency = 1, TextColor3 = C.dim })
		end
		activeTab = tab
		page.Visible = true
		tw(btn, 0.12, { BackgroundTransparency = 0.12, TextColor3 = C.white })
	end)

	return tab
end

local function addRow(tab, parent, titulo, alto)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, alto or 32),
		BackgroundColor3 = C.panel2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, row)
	local lbl = new("TextLabel", {
		Size = UDim.new(1, -96),
		BackgroundTransparency = 1,
		Font = FM,
		TextSize = 12.5,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Text = titulo,
	}, row)
	tab.rows[#tab.rows + 1] = { row = row, nombre = titulo }
	row.MouseEnter:Connect(function()
		row.BackgroundTransparency = 0.85
	end)
	row.MouseLeave:Connect(function()
		row.BackgroundTransparency = 1
	end)
	return row, lbl
end

local function addSection(tab, titulo)
	tab.usarA = not tab.usarA
	local parent = tab.usarA and tab.colA or tab.colB

	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
	new("UIStroke", { Color = C.stroke, Transparency = 0.45 }, card)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 7),
		PaddingBottom = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, card)

	local head = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Font = FB,
		TextSize = 12,
		TextColor3 = C.accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = titulo,
	}, card)
	tab.rows[#tab.rows + 1] = { row = head, nombre = titulo }

	local linea = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.stroke,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
	}, card)

	return card
end

local function addToggle(tab, parent, o)
	local valor = o.Default or false
	local row = addRow(tab, parent, o.Title, 32)

	local pill = new("Frame", {
		Size = UDim2.fromOffset(40, 20),
		Position = UDim2.new(1, -46, 0.5, -10),
		BackgroundColor3 = valor and C.accent or C.track,
		BorderSizePixel = 0,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)
	new("UIStroke", { Color = C.stroke, Transparency = 0.3 }, pill)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(0, valor and 21 or 2, 0.5, -8),
		BackgroundColor3 = C.white,
		BorderSizePixel = 0,
	}, pill)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

	local obj = { Value = valor }

	function obj:Set(v, silencioso)
		v = not not v
		self.Value = v
		tw(pill, 0.14, { BackgroundColor3 = v and C.accent or C.track })
		tw(knob, 0.14, { Position = UDim2.new(0, v and 21 or 2, 0.5, -8) })
		if not silencioso then
			notify(o.Title .. (v and " activado" or " desactivado"), v)
			guardarDiferido()
		end
		if o.Callback then
			task.spawn(o.Callback, v)
		end
	end

	local click = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
	}, row)
	click.MouseButton1Click:Connect(function()
		obj:Set(not obj.Value)
	end)

	if o.Flag then
		flags[o.Flag] = obj
	end
	return obj
end

local function addSlider(tab, parent, o)
	local valor = o.Default or o.Min
	local row, lbl = addRow(tab, parent, o.Title, 36)
	lbl.TextWrapped = false

	local bar = new("Frame", {
		Size = UDim2.new(1, -14, 0, 5),
		Position = UDim2.new(0, 7, 0, 26),
		BackgroundColor3 = C.track,
		BorderSizePixel = 0,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
	}, bar)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

	local obj = { Value = valor }

	local function refrescar()
		local alpha = (obj.Value - o.Min) / math.max(o.Max - o.Min, 0.000001)
		fill.Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
		local mostrado = math.floor(obj.Value * 100 + 0.5) / 100
		lbl.Text = o.Title .. ": " .. tostring(mostrado)
	end

	function obj:Set(v, silencioso)
		self.Value = math.clamp(v, o.Min, o.Max)
		refrescar()
		if not silencioso then
			guardarDiferido()
		end
		if o.Callback then
			task.spawn(o.Callback, self.Value)
		end
	end

	local arrastrando = false

	local function actualizar(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		obj:Set(o.Min + (o.Max - o.Min) * rel)
	end

	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = true
			actualizar(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not arrastrando then
			return
		end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			actualizar(i.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = false
		end
	end)

	refrescar()
	if o.Flag then
		flags[o.Flag] = obj
	end
	return obj
end

local function addDropdown(tab, parent, o)
	local valor = o.Default or (o.Options and o.Options[1]) or ""
	local row = addRow(tab, parent, o.Title, 32)

	local box = new("TextButton", {
		Size = UDim2.fromOffset(126, 22),
		Position = UDim2.new(1, -132, 0.5, -11),
		BackgroundColor3 = C.track,
		BorderSizePixel = 0,
		Font = FR,
		TextSize = 11,
		TextColor3 = C.text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = tostring(valor),
		ZIndex = 8,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
	new("UIStroke", { Color = C.stroke, Transparency = 0.4 }, box)

	local list = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 30,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, list)
	new("UIStroke", { Color = C.stroke, Transparency = 0.35 }, list)
	new("UIListLayout", { Padding = UDim.new(0, 1) }, list)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 3),
		PaddingBottom = UDim.new(0, 3),
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
	}, list)

	local obj = { Value = valor }

	function obj:Set(v, silencioso)
		self.Value = v
		box.Text = tostring(v)
		if not silencioso then
			guardarDiferido()
		end
		if o.Callback then
			task.spawn(o.Callback, v)
		end
	end

	local opciones = o.Options or {}
	for _, opt in ipairs(opciones) do
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = C.panel2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = FR,
			TextSize = 11,
			TextColor3 = C.dim,
			Text = opt,
			ZIndex = 31,
		}, list)
		new("UICorner", { CornerRadius = UDim.new(0, 4) }, b)
		b.MouseEnter:Connect(function()
			b.BackgroundTransparency = 0.75
			b.TextColor3 = C.white
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundTransparency = 1
			b.TextColor3 = C.dim
		end)
		b.MouseButton1Click:Connect(function()
			obj:Set(opt)
			list.Visible = false
			list.Size = UDim2.new(1, 0, 0, 0)
		end)
	end

	local abierto = false
	box.MouseButton1Click:Connect(function()
		abierto = not abierto
		list.Visible = abierto
		if abierto then
			list.Size = UDim2.new(1, 0, 0, math.min(#opciones * 21 + 6, 132))
		else
			list.Size = UDim2.new(1, 0, 0, 0)
		end
	end)

	if o.Flag then
		flags[o.Flag] = obj
	end
	return obj
end

local function addButton(tab, parent, o)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = C.accent,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Font = FB,
		TextSize = 12,
		TextColor3 = C.text,
		Text = o.Title,
		AutoButtonColor = false,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
	new("UIStroke", { Color = C.accent, Transparency = 0.35 }, b)
	b.MouseEnter:Connect(function()
		tw(b, 0.1, { BackgroundTransparency = 0.08 })
	end)
	b.MouseLeave:Connect(function()
		tw(b, 0.1, { BackgroundTransparency = 0.35 })
	end)
	b.MouseButton1Click:Connect(function()
		if o.Callback then
			task.spawn(o.Callback)
		end
	end)
	tab.rows[#tab.rows + 1] = { row = b, nombre = o.Title }
	return b
end

local function addInput(tab, parent, o)
	local row, lbl = addRow(tab, parent, o.Title, 32)
	lbl.Size = UDim.new(1, -150)
	local box = new("TextBox", {
		Size = UDim2.fromOffset(134, 22),
		Position = UDim2.new(1, -140, 0.5, -11),
		BackgroundColor3 = C.track,
		BorderSizePixel = 0,
		Font = FR,
		TextSize = 11,
		TextColor3 = C.text,
		PlaceholderText = o.Placeholder or "",
		PlaceholderColor3 = C.dim,
		Text = "",
		ClearTextOnFocus = false,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
	new("UIStroke", { Color = C.stroke, Transparency = 0.45 }, box)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, box)
	return box
end

local function addParagraph(tab, parent, texto)
	return new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Font = FR,
		TextSize = 11,
		TextColor3 = C.dim,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = texto,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, parent)
end

local function addColor(tab, parent, o)
	local row = addRow(tab, parent, o.Title, 32)
	local holder = new("Frame", {
		Size = UDim2.fromOffset(134, 20),
		Position = UDim2.new(1, -140, 0.5, -10),
		BackgroundTransparency = 1,
	}, row)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 3),
	}, holder)

	local presets = {
		Color3.fromRGB(255, 40, 50),
		Color3.fromRGB(255, 140, 30),
		Color3.fromRGB(255, 235, 60),
		Color3.fromRGB(70, 255, 120),
		Color3.fromRGB(60, 200, 255),
		Color3.fromRGB(160, 100, 255),
		Color3.fromRGB(255, 255, 255),
	}
	for _, col in ipairs(presets) do
		local sw = new("TextButton", {
			Size = UDim2.fromOffset(15, 15),
			BackgroundColor3 = col,
			BorderSizePixel = 0,
			Text = "",
		}, holder)
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, sw)
		sw.MouseButton1Click:Connect(function()
			if o.Callback then
				task.spawn(o.Callback, col)
			end
		end)
	end
end

local function aplicarBusqueda(q)
	q = string.lower(q)
	for _, t in ipairs(tabs) do
		for _, r in ipairs(t.rows) do
			if q == "" then
				r.row.Visible = true
			else
				r.row.Visible = string.find(string.lower(r.nombre), q, 1, true) ~= nil
			end
		end
	end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	aplicarBusqueda(searchBox.Text)
end)

--============================= ARRASTRE =============================
do
	local arrastrando = false
	local inicio, inicioPos
	header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = true
			inicio = i.Position
			inicioPos = main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not arrastrando then
			return
		end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - inicio
			main.Position = UDim2.new(inicioPos.X.Scale, inicioPos.X.Offset + d.X, inicioPos.Y.Scale, inicioPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			arrastrando = false
		end
	end)
end

--============================== HELPERS ==============================
local function getExecutor()
	local ok, nombre = pcall(function()
		return identifyexecutor()
	end)
	if ok and nombre then
		return tostring(nombre)
	end
	return "Desconocido"
end

local function getGameName()
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
	end)
	if ok and info then
		return info.Name
	end
	return "Desconocido"
end

local function isLobby()
	local char = LP.Character
	if not char then
		return true
	end
	if char:FindFirstChildOfClass("ForceField") then
		return true
	end
	if LP.Team and (LP.Team.Name == "Spectators" or LP.Team.Name == "Lobby") then
		return true
	end
	local rs = char:FindFirstChild("GameInProgress")
	if rs then
		return rs:GetAttribute("Value") == false
	end
	return false
end
estaEnLobby = isLobby

local function isTeammate(pl)
	if not LP.Team or not pl.Team then
		return false
	end
	return pl.Team == LP.Team
end

local resolver = { InGame = false, Snapshot = {}, Dirty = true, Ultimo = 0 }

local function getScoreboard()
	local pg = LP:FindFirstChild("PlayerGui")
	local m = pg and pg:FindFirstChild("Main")
	local g = m and m:FindFirstChild("MainGameFrame")
	return g and g:FindFirstChild("IngameScore")
end

local function refrescarScoreboard(forzar)
	local ahora = os.clock()
	if not forzar and not resolver.Dirty and ahora - resolver.Ultimo < 2 then
		return
	end
	resolver.Ultimo = ahora
	resolver.Dirty = false

	local board = getScoreboard()
	local snap = {}
	if board then
		for _, fila in ipairs(board:GetDescendants()) do
			if fila:IsA("TextLabel") and fila.Text ~= "" then
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl ~= LP and (fila.Text == pl.Name or fila.Text == pl.DisplayName) then
						local n = string.lower(fila.Name)
						local pn = string.lower(fila.Parent.Name)
						if string.find(n, "enem") or string.find(pn, "enem") then
							snap[pl] = true
						end
					end
				end
			end
		end
	end
	resolver.Snapshot = snap
	resolver.InGame = board ~= nil
end

task.spawn(function()
	while gui.Parent do
		task.wait(2)
		refrescarScoreboard()
	end
end)

isEnemy = function(pl)
	refrescarScoreboard()
	return resolver.Snapshot[pl] == true
end

esCuchillo = function(tool)
	if not tool or not tool:IsA("Tool") then
		return false
	end
	return tool:FindFirstChild("Slash") ~= nil or tool:FindFirstChild("SlashStart") ~= nil
end

esPistola = function(tool)
	if not tool or not tool:IsA("Tool") then
		return false
	end
	return tool:FindFirstChild("showBeam") ~= nil
end

IsInMatchStrict = function()
	refrescarScoreboard()
	return resolver.InGame
end

esEnemigoValido = function(pl)
	if not pl or pl == LP then
		return false
	end
	local char = pl.Character
	if not char then
		return false
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return false
	end
	if char:FindFirstChildOfClass("ForceField") then
		return false
	end
	if estaEnLobby() then
		return false
	end
	if isEnemy(pl) then
		return true
	end
	if not resolver.InGame then
		return not isTeammate(pl)
	end
	return false
end

local function esObjetivoVisual(pl)
	if not pl or pl == LP then
		return false
	end
	local char = pl.Character
	if not char then
		return false
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return false
	end
	return not isTeammate(pl)
end

local function getCercano(radio, nombreParte)
	local mejor, mejorDist
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil
	end
	for _, pl in ipairs(Players:GetPlayers()) do
		if esEnemigoValido(pl) then
			local c = pl.Character
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local parte = c:FindFirstChild(nombreParte) or c:FindFirstChild("HumanoidRootPart")
				if parte then
					local d = (parte.Position - hrp.Position).Magnitude
					if d <= radio and (not mejorDist or d < mejorDist) then
						mejor = parte
						mejorDist = d
					end
				end
			end
		end
	end
	return mejor
end

--======================== ESTADO DE OBJETIVO ========================
local PRIORIDAD = { telekill = 0, autoShoot = 1, faked = 2, silent = 3 }
local slots = {}

local function resolverObjetivo()
	local mejor, mejorPrio = nil, math.huge
	for k, v in pairs(slots) do
		local p = PRIORIDAD[k] or 99
		if v and v.Parent and p < mejorPrio then
			mejor = v
			mejorPrio = p
		end
	end
	getgenv().NaviTargetPart = mejor
end

local function setTarget(slot, parte)
	slots[slot] = parte
	resolverObjetivo()
end

--============================== PESTAÑAS ==============================
local Home = makeTab("Home", "◆")
local Aimbot = makeTab("Aimbot", "◈")
local Visuales = makeTab("Visuales", "◉")
local Movimiento = makeTab("Movimiento", "➤")
local Animaciones = makeTab("Animaciones", "✦")
local AutoFarm = makeTab("AutoFarm", "▣")
local AutoKills = makeTab("AutoKills", "✖")
local Settings = makeTab("Settings", "⚙")

do
	local s = addSection(Home, "INFORMACIÓN")
	addParagraph(Home, s, "Bienvenido a Navi Onyx v3.")
	addParagraph(Home, s, "Ejecutor: " .. getExecutor())
	addParagraph(Home, s, "Juego: " .. getGameName())
	addParagraph(Home, s, "Jugador: @" .. LP.Name)

	local s2 = addSection(Home, "ESTADO")
	local statusLbl = addParagraph(Home, s2, "Lobby: --")
	task.spawn(function()
		while gui.Parent do
			task.wait(0.5)
			local lobby = estaEnLobby() and "sí" or "no"
			local board = resolver.InGame and "detectado" or "no detectado"
			statusLbl.Text = "Lobby: " .. lobby .. "  ·  Scoreboard: " .. board
		end
	end)

	local s3 = addSection(Home, "VENTANA")
	addParagraph(Home, s3, "El botón – minimiza el panel. Vuelve a abrirlo con el botón N flotante, sin reejecutar nada.")
	addParagraph(Home, s3, "La configuración se guarda sola y se restaura al ejecutar de nuevo.")
end

--=============================== AIMBOT ===============================
local aimbotEnabled = false
local silentAimEnabled = false
local silentAimFov = false
local fovVisible = false
local fovRadius = 120
local silentPart = "Cabeza"
local autoShoot = false
local autoShootPart = "Cabeza"
local autoShootAgresivo = false
local altoFire = false
local autoSacarArma = false
local autoFaked = false
local cadencia = 0.2

do
	local s = addSection(Aimbot, "AIMBOT")
	addToggle(Aimbot, s, { Title = "Aimbot", Flag = "aimbot", Default = false, Callback = function(v) aimbotEnabled = v end })
	addSlider(Aimbot, s, { Title = "Campo de visión", Flag = "fov", Min = 10, Max = 800, Default = 120, Callback = function(v) fovRadius = v end })
	addToggle(Aimbot, s, { Title = "Círculo FOV", Flag = "fovcircle", Default = false, Callback = function(v) fovVisible = v end })
	addDropdown(Aimbot, s, { Title = "Parte del objetivo", Flag = "aimpart", Options = { "Cabeza", "Torso", "Cuerpo completo" }, Default = "Cabeza", Callback = function(v) autoShootPart = v end })

	local s2 = addSection(Aimbot, "SILENT AIM")
	addToggle(Aimbot, s2, { Title = "Silent aim", Flag = "silent", Default = false, Callback = function(v) silentAimEnabled = v end })
	addToggle(Aimbot, s2, { Title = "Limitar al FOV", Flag = "silentfov", Default = false, Callback = function(v) silentAimFov = v end })
	addDropdown(Aimbot, s2, { Title = "Parte (silent)", Flag = "silentpart", Options = { "Cabeza", "Torso", "Cuerpo completo" }, Default = "Cabeza", Callback = function(v) silentPart = v end })

	local s3 = addSection(Aimbot, "AUTO DISPARO")
	addToggle(Aimbot, s3, { Title = "Auto sacar arma", Flag = "autogun", Default = false, Callback = function(v) autoSacarArma = v end })
	addToggle(Aimbot, s3, { Title = "Auto shot", Flag = "autoshot", Default = false, Callback = function(v) autoShoot = v end })
	addToggle(Aimbot, s3, { Title = "Auto shot agresivo", Flag = "autoshotagr", Default = false, Callback = function(v) autoShootAgresivo = v end })
	addToggle(Aimbot, s3, { Title = "Alto fire", Flag = "altofire", Default = false, Callback = function(v) altoFire = v end })
	addToggle(Aimbot, s3, { Title = "Auto shot faked", Flag = "autofaked", Default = false, Callback = function(v) autoFaked = v end })
	addSlider(Aimbot, s3, { Title = "Cadencia", Flag = "cadencia", Min = 0.05, Max = 1, Default = 0.2, Callback = function(v) cadencia = v end })
end

local fovCircle
RunService.RenderStepped:Connect(function()
	if not fovVisible then
		if fovCircle then
			fovCircle.Visible = false
		end
		return
	end
	if not fovCircle then
		local ok, d = pcall(function()
			return Drawing.new("Circle")
		end)
		if not ok then
			return
		end
		fovCircle = d
	end
	local cam = getCamera()
	if not cam then
		return
	end
	fovCircle.Visible = true
	fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	fovCircle.Radius = fovRadius
	fovCircle.Thickness = 1.5
	fovCircle.Color = C.accent
	fovCircle.Transparency = 0.35
end)

--=========================== VISUALES / ESP ===========================
local espEnabled = false
local skeletonEnabled = false
local SkeletonColor = Color3.fromRGB(255, 40, 50)
local MAX_ESP = 1500
local espFolder = new("Folder", { Name = "NaviESP" }, gui)
local esqueletos = {}

do
	local s = addSection(Visuales, "JUGADORES")
	addToggle(Visuales, s, { Title = "ESP", Flag = "esp", Default = false, Callback = function(v) espEnabled = v end })
	addToggle(Visuales, s, { Title = "Esqueleto ESP", Flag = "skeleton", Default = false, Callback = function(v) skeletonEnabled = v end })
	addColor(Visuales, s, { Title = "Color del esqueleto", Callback = function(col) SkeletonColor = col end })

	local s2 = addSection(Visuales, "HITBOX")
	local hitboxOn = false
	local hitboxTam = 3.5
	addToggle(Visuales, s2, { Title = "Hitbox expander", Flag = "hitbox", Default = false, Callback = function(v) hitboxOn = v end })
	addSlider(Visuales, s2, { Title = "Tamaño", Flag = "hitboxsize", Min = 1, Max = 12, Default = 3.5, Callback = function(v) hitboxTam = v end })

	task.spawn(function()
		while gui.Parent do
			task.wait(0.4)
			if not hitboxOn then
				continue
			end
			for _, pl in ipairs(Players:GetPlayers()) do
				if esObjetivoVisual(pl) then
					local char = pl.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp then
						local tam = Vector3.new(hitboxTam, hitboxTam, hitboxTam)
						local hb = char:FindFirstChild("Navi_HITBOX")
						if not hb then
							hb = new("Part", {
								Name = "Navi_HITBOX",
								Size = tam,
								Transparency = 0.75,
								CanCollide = false,
								CanQuery = true,
								Color = C.accent,
								Massless = true,
								Parent = char,
							})
							new("SelectionBox", { Adornee = hb, Color3 = C.accent, LineThickness = 0.02, Parent = hb })
							new("WeldConstraint", { Part0 = hrp, Part1 = hb, Parent = hb })
							hb.CFrame = hrp.CFrame
						elseif hb.Size ~= tam then
							hb.Size = tam
						end
					end
				end
			end
		end
	end)
end

local function limpiarESP(pl)
	local h = espFolder:FindFirstChild(pl.Name .. "Navi")
	if h then
		h:Destroy()
	end
	local char = pl.Character
	local hb = char and char:FindFirstChild("Navi_HITBOX")
	if hb then
		hb:Destroy()
	end
end

local function buscarParte(char, ...)
	for _, n in ipairs({ ... }) do
		local p = char:FindFirstChild(n)
		if p and p:IsA("BasePart") then
			return p
		end
	end
	return nil
end

local function limpiarEsqueleto(char)
	local rec = esqueletos[char]
	if not rec then
		return
	end
	for _, o in ipairs(rec) do
		if o and o.Parent then
			pcall(function()
				o:Destroy()
			end)
		end
	end
	esqueletos[char] = nil
end

local function construirEsqueleto(char)
	if esqueletos[char] then
		return
	end
	local head = buscarParte(char, "Head")
	local hrp = buscarParte(char, "HumanoidRootPart")
	if not head or not hrp then
		return
	end

	local upper = buscarParte(char, "UpperTorso", "Torso")
	local lower = buscarParte(char, "LowerTorso", "Torso") or upper
	local luaA = buscarParte(char, "LeftUpperArm", "Left Arm")
	local llaA = buscarParte(char, "LeftLowerArm", "Left Arm") or luaA
	local lhA = buscarParte(char, "LeftHand", "Left Arm") or llaA
	local ruaA = buscarParte(char, "RightUpperArm", "Right Arm")
	local rlaA = buscarParte(char, "RightLowerArm", "Right Arm") or ruaA
	local rhA = buscarParte(char, "RightHand", "Right Arm") or rlaA
	local lul = buscarParte(char, "LeftUpperLeg", "Left Leg")
	local lll = buscarParte(char, "LeftLowerLeg", "Left Leg") or lul
	local lf = buscarParte(char, "LeftFoot", "Left Leg") or lll
	local rul = buscarParte(char, "RightUpperLeg", "Right Leg")
	local rll = buscarParte(char, "RightLowerLeg", "Right Leg") or rul
	local rf = buscarParte(char, "RightFoot", "Right Leg") or rll

	local rec = {}
	local beams = {}
	esqueletos[char] = rec

	local function att(part, pos)
		local a = new("Attachment", { Position = pos, Parent = part })
		rec[#rec + 1] = a
		return a
	end

	local function hueso(pA, oA, pB, oB)
		if not pA or not pB then
			return
		end
		local b = new("Beam", {
			Attachment0 = att(pA, oA),
			Attachment1 = att(pB, oB),
			Color = ColorSequence.new(SkeletonColor),
			LightEmission = 1,
			FaceCamera = true,
			Width0 = 0.055,
			Width1 = 0.055,
			Transparency = NumberSequence.new(skeletonEnabled and 0 or 1),
			Parent = char,
		})
		rec[#rec + 1] = b
		beams[#beams + 1] = b
	end

	hueso(head, Vector3.new(0, -0.5, 0), upper, Vector3.new(0, 0.85, 0))
	hueso(upper, Vector3.new(0, 0.6, 0), lower, Vector3.new(0, -0.6, 0))
	hueso(upper, Vector3.new(0.85, 0.55, 0), luaA, Vector3.new(0, 0.5, 0))
	hueso(luaA, Vector3.new(0, -0.4, 0), llaA, Vector3.new(0, 0.4, 0))
	hueso(llaA, Vector3.new(0, -0.4, 0), lhA, Vector3.new(0, 0.2, 0))
	hueso(upper, Vector3.new(-0.85, 0.55, 0), ruaA, Vector3.new(0, 0.5, 0))
	hueso(ruaA, Vector3.new(0, -0.4, 0), rlaA, Vector3.new(0, 0.4, 0))
	hueso(rlaA, Vector3.new(0, -0.4, 0), rhA, Vector3.new(0, 0.2, 0))
	hueso(lower, Vector3.new(0.45, -0.5, 0), lul, Vector3.new(0, 0.5, 0))
	hueso(lul, Vector3.new(0, -0.5, 0), lll, Vector3.new(0, 0.5, 0))
	hueso(lll, Vector3.new(0, -0.5, 0), lf, Vector3.new(0, 0.2, 0))
	hueso(lower, Vector3.new(-0.45, -0.5, 0), rul, Vector3.new(0, 0.5, 0))
	hueso(rul, Vector3.new(0, -0.5, 0), rll, Vector3.new(0, 0.5, 0))
	hueso(rll, Vector3.new(0, -0.5, 0), rf, Vector3.new(0, 0.2, 0))

	rec.beams = beams
end

local function actualizarEsqueleto(char)
	local rec = esqueletos[char]
	if not rec or not rec.beams then
		return
	end
	local pl = Players:GetPlayerFromCharacter(char)
	local visible = skeletonEnabled and pl and esObjetivoVisual(pl)
	for _, b in ipairs(rec.beams) do
		if b.Parent then
			b.Transparency = NumberSequence.new(visible and 0 or 1)
			b.Color = ColorSequence.new(SkeletonColor)
		end
	end
end

task.spawn(function()
	while gui.Parent do
		task.wait(0.3)
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		for _, pl in ipairs(Players:GetPlayers()) do
			local valido = esObjetivoVisual(pl)
			local cerca = false
			local otro = pl.Character
			local ohrp = otro and otro:FindFirstChild("HumanoidRootPart")
			if valido and hrp and ohrp then
				cerca = (ohrp.Position - hrp.Position).Magnitude <= MAX_ESP
			end

			local h = espFolder:FindFirstChild(pl.Name .. "Navi")
			if espEnabled and cerca then
				if not h then
					new("Highlight", {
						Name = pl.Name .. "Navi",
						Adornee = otro,
						FillColor = C.accent,
						FillTransparency = 0.7,
						OutlineColor = C.accent2,
						OutlineTransparency = 0.2,
						DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
						Parent = espFolder,
					})
				end
				if skeletonEnabled then
					construirEsqueleto(otro)
					actualizarEsqueleto(otro)
				end
			elseif h then
				h:Destroy()
			end

			if otro and esqueletos[otro] then
				actualizarEsqueleto(otro)
			end
		end
	end
end)

do
	local function vigilar(char)
		if not char then
			return
		end
		task.spawn(function()
			local hum = char:WaitForChild("Humanoid", 5)
			if hum then
				hum.Died:Connect(function()
					limpiarEsqueleto(char)
				end)
			end
		end)
		char.AncestryChanged:Connect(function()
			if not char.Parent then
				limpiarEsqueleto(char)
			end
		end)
	end

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl.Character then
			vigilar(pl.Character)
		end
		pl.CharacterAdded:Connect(vigilar)
	end
	Players.PlayerAdded:Connect(function(pl)
		pl.CharacterAdded:Connect(vigilar)
	end)
	Players.PlayerRemoving:Connect(function(pl)
		limpiarESP(pl)
		if pl.Character then
			limpiarEsqueleto(pl.Character)
		end
	end)
end

--============================= MOVIMIENTO =============================
local spinOn = false
local spinVel = 12
local zigzagOn = false
local zigzagFuerza = 1.2
local telaOn = false
local telaFuerza = 1.4
local invisOn = false
local flyOn = false
local flyVel = 0.75

do
	local s = addSection(Movimiento, "MOVIMIENTO")
	addToggle(Movimiento, s, { Title = "Spin", Flag = "spin", Default = false, Callback = function(v) spinOn = v end })
	addSlider(Movimiento, s, { Title = "Velocidad de spin", Flag = "spinvel", Min = 1, Max = 60, Default = 12, Callback = function(v) spinVel = v end })
	addToggle(Movimiento, s, { Title = "Zigzag", Flag = "zigzag", Default = false, Callback = function(v) zigzagOn = v end })
	addSlider(Movimiento, s, { Title = "Fuerza zigzag", Flag = "zigzagf", Min = 0.2, Max = 4, Default = 1.2, Callback = function(v) zigzagFuerza = v end })
	addToggle(Movimiento, s, { Title = "Movimiento tela", Flag = "tela", Default = false, Callback = function(v) telaOn = v end })
	addSlider(Movimiento, s, { Title = "Fuerza tela", Flag = "telaf", Min = 0.2, Max = 4, Default = 1.4, Callback = function(v) telaFuerza = v end })

	local s2 = addSection(Movimiento, "VUELO")
	addToggle(Movimiento, s2, { Title = "Volar", Flag = "fly", Default = false, Callback = function(v) flyOn = v end })
	addSlider(Movimiento, s2, { Title = "Velocidad de vuelo", Flag = "flyvel", Min = 0.1, Max = 4, Default = 0.75, Callback = function(v) flyVel = v end })
	addParagraph(Movimiento, s2, "WASD para moverte, Espacio subir, Ctrl bajar.")

	local s3 = addSection(Movimiento, "VISUAL")
	addToggle(Movimiento, s3, { Title = "Invisible", Flag = "invis", Default = false, Callback = function(v) invisOn = v end })
end

local TS = 0
RunService.RenderStepped:Connect(function(dt)
	local char = LP.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then
		return
	end
	local k = dt * 60

	if spinOn then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinVel) * k, 0)
	end

	if zigzagOn then
		hrp.CFrame = hrp.CFrame * CFrame.new(
			math.sin(tick() * 14) * zigzagFuerza * 0.3 * k,
			0,
			math.cos(tick() * 11) * zigzagFuerza * 0.3 * k
		)
	end

	if telaOn and hum.MoveDirection.Magnitude > 0 then
		TS = TS + dt * 38
		hrp.CFrame = hrp.CFrame * CFrame.new(math.sin(TS) * telaFuerza * 0.6 * k, 0, 0)
		hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.28 * k
	end

	if invisOn then
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
				v.LocalTransparencyModifier = 1
			end
		end
	end

	if flyOn then
		hum:ChangeState(Enum.HumanoidStateType.Flying)
		local cam = getCamera()
		if cam then
			local dir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				dir = dir + cam.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				dir = dir - cam.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				dir = dir - cam.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				dir = dir + cam.CFrame.RightVector
			end
			if dir.Magnitude > 0 then
				hrp.CFrame = hrp.CFrame + dir.Unit * flyVel * k
			end
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, flyVel * k, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			hrp.CFrame = hrp.CFrame - Vector3.new(0, flyVel * k, 0)
		end
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
end)

task.spawn(function()
	local antes = false
	while gui.Parent do
		task.wait(0.2)
		if antes ~= invisOn then
			antes = invisOn
			local char = LP.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and not invisOn then
				hum.CameraOffset = Vector3.zero
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("BasePart") then
						v.LocalTransparencyModifier = 0
					end
				end
			end
		end
	end
end)

--============================= ANIMACIONES ============================
local packs = {
	["Ninja"] = { idle = 656117400, walk = 656121766, run = 656118852, jump = 656117878, fall = 656115606 },
	["Zombie"] = { idle = 3489171152, walk = 3489187502, run = 3489176752, jump = 3489181340, fall = 3489177666 },
	["Levitar"] = { idle = 616006778, walk = 616008087, run = 616013216, jump = 616010382, fall = 616008936 },
	["Astronauta"] = { idle = 891621366, walk = 891633237, run = 891627514, jump = 891635357, fall = 891617961 },
	["Robot"] = { idle = 616088211, walk = 616090535, run = 616092998, jump = 616086039, fall = 616090808 },
	["Mago"] = { idle = 7077426394, walk = 7077457503, run = 7077446371, jump = 7077460573, fall = 7077453194 },
}

local listaPacks = {}
for k in pairs(packs) do
	listaPacks[#listaPacks + 1] = k
end
table.sort(listaPacks)

local function aplicarPack(nombre)
	local char = LP.Character
	local anim = char and char:FindFirstChild("Animate")
	local pack = packs[nombre]
	if not anim or not pack then
		notify("No se pudo aplicar", false)
		return
	end
	local function set(p, c, id)
		local node = anim:FindFirstChild(p)
		local a = node and node:FindFirstChild(c)
		if a and id then
			a.AnimationId = "rbxassetid://" .. id
		end
	end
	set("idle", "Animation1", pack.idle)
	set("walk", "WalkAnim", pack.walk)
	set("run", "RunAnim", pack.run)
	set("jump", "JumpAnim", pack.jump)
	set("fall", "FallAnim", pack.fall)
	notify("Animación aplicada: " .. nombre, true)
end

do
	local s = addSection(Animaciones, "PAQUETES")
	local sel = addDropdown(Animaciones, s, { Title = "Paquete", Flag = "pack", Options = listaPacks, Default = listaPacks[1] })
	addButton(Animaciones, s, { Title = "Aplicar", Callback = function() aplicarPack(sel.Value) end })
	addButton(Animaciones, s, { Title = "Restaurar default", Callback = function()
		local char = LP.Character
		local anim = char and char:FindFirstChild("Animate")
		if anim then
			anim:Destroy()
		end
		notify("Animaciones restauradas", true)
	end })
end

--============================== AUTO FARM =============================
local farmOn = false
local farmRadio = 60
local farmVel = 22
local farmCaminar = true
local farmPrompts = true
local farmPerseguir = false

do
	local s = addSection(AutoFarm, "RECOLECCIÓN")
	addToggle(AutoFarm, s, { Title = "Auto farm", Flag = "farm", Default = false, Callback = function(v) farmOn = v end })
	addSlider(AutoFarm, s, { Title = "Radio", Flag = "farmradio", Min = 10, Max = 200, Default = 60, Callback = function(v) farmRadio = v end })
	addSlider(AutoFarm, s, { Title = "Velocidad al caminar", Flag = "farmvel", Min = 16, Max = 60, Default = 22, Callback = function(v) farmVel = v end })
	addToggle(AutoFarm, s, { Title = "Caminar hacia objetos", Flag = "farmwalk", Default = true, Callback = function(v) farmCaminar = v end })
	addToggle(AutoFarm, s, { Title = "Usar proximity prompts", Flag = "farmprompt", Default = true, Callback = function(v) farmPrompts = v end })

	local s2 = addSection(AutoFarm, "COMBATE")
	addToggle(AutoFarm, s2, { Title = "Perseguir enemigos", Flag = "farmchase", Default = false, Callback = function(v) farmPerseguir = v end })
	addParagraph(AutoFarm, s2, "La recolección usa touch, prompts y click detectors a la vez.")
end

local NOMBRES = { "coin", "egg", "cash", "money", "gem", "token", "huevo", "moneda", "orb", "crate", "chest", "drop" }

local function esItem(obj)
	if not obj:IsA("BasePart") then
		return false
	end
	local n = string.lower(obj.Name)
	for _, k in ipairs(NOMBRES) do
		if string.find(n, k, 1, true) then
			return true
		end
	end
	return false
end

local function recolectar(hrp)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if esItem(obj) then
			local d = (obj.Position - hrp.Position).Magnitude
			if d <= farmRadio then
				if obj.CanTouch then
					pcall(firetouchinterest, hrp, obj, 0)
					pcall(firetouchinterest, hrp, obj, 1)
				end
				if farmPrompts then
					for _, pr in ipairs(obj:GetChildren()) do
						if pr:IsA("ProximityPrompt") and pr.Enabled then
							pcall(fireproximityprompt, pr)
						end
					end
				end
				for _, cd in ipairs(obj:GetChildren()) do
					if cd:IsA("ClickDetector") then
						pcall(fireclickdetector, cd)
					end
				end
			end
		elseif farmPrompts and obj:IsA("ProximityPrompt") and obj.Enabled then
			local padre = obj.Parent
			if padre and padre:IsA("BasePart") and (padre.Position - hrp.Position).Magnitude <= farmRadio then
				pcall(fireproximityprompt, obj)
			end
		end
	end
end

local function itemCercano(hrp)
	local mejor, mejorDist
	for _, obj in ipairs(workspace:GetDescendants()) do
		if esItem(obj) then
			local d = (obj.Position - hrp.Position).Magnitude
			if d <= farmRadio * 2.5 and (not mejorDist or d < mejorDist) then
				mejor = obj
				mejorDist = d
			end
		end
	end
	return mejor
end

task.spawn(function()
	local velOriginal = 16
	local guardado = false
	while task.wait(0.2) do
		if not farmOn then
			if guardado then
				local char = LP.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.WalkSpeed = velOriginal
				end
				guardado = false
			end
			continue
		end

		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp or hum.Health <= 0 then
			continue
		end

		if not guardado then
			velOriginal = hum.WalkSpeed
			guardado = true
		end

		recolectar(hrp)

		if farmCaminar then
			hum.WalkSpeed = farmVel
			local it = itemCercano(hrp)
			if it then
				hum:MoveTo(it.Position)
			end
		end

		if farmPerseguir then
			local enemigo = getCercano(300, "HumanoidRootPart")
			if enemigo then
				hum:MoveTo(enemigo.Position)
			end
		end
	end
end)

--============================== AUTO KILLS ============================
local atrasOn = false
local atrasActivo = false

do
	local s = addSection(AutoKills, "TELEKILL")
	addToggle(AutoKills, s, { Title = "Teleport detrás", Flag = "atras", Default = false, Callback = function(v)
		atrasOn = v
		if v then
			notify("Teleport detrás activado", true)
		end
	end })
	addButton(AutoKills, s, { Title = "Telekill completo", Callback = function()
		autoShoot = true
		autoShootAgresivo = true
		altoFire = true
		atrasOn = true
		notify("Telekill completo armado", true)
	end })
end

local function loopAtras()
	if atrasActivo then
		return
	end
	atrasActivo = true
	task.spawn(function()
		while atrasOn do
			RunService.Heartbeat:Wait()
			local char = LP.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local obj = getCercano(200, "HumanoidRootPart")
			if hrp and obj then
				hrp.CFrame = CFrame.lookAt(obj.CFrame.Position + obj.CFrame.LookVector * 2.6, obj.Position)
				hrp.AssemblyLinearVelocity = Vector3.zero
				setTarget("telekill", obj)
			else
				setTarget("telekill", nil)
			end
		end
		setTarget("telekill", nil)
		atrasActivo = false
	end)
end

task.spawn(function()
	while gui.Parent do
		task.wait(0.25)
		if atrasOn then
			loopAtras()
		end
	end
end)

--============================ SONIDO DE KILL ==========================
local killSounds = {
	["ES HACKER"] = "rbxassetid://131961136",
	["ONICHAAAN"] = "rbxassetid://1837835458",
	["TACTICAL"] = "rbxassetid://130791264",
	["BASS"] = "rbxassetid://142376088",
	["DING"] = "rbxassetid://3120926404",
}
local killSonidoOn = false
local killSonidoNombre = "ES HACKER"
local killVol = 1
local killPlayer = new("Sound", { Volume = 1, Parent = SoundService })

do
	local s = addSection(AutoKills, "SONIDO")
	addToggle(AutoKills, s, { Title = "Sonido de kill", Flag = "killsound", Default = false, Callback = function(v) killSonidoOn = v end })
	local opciones = {}
	for k in pairs(killSounds) do
		opciones[#opciones + 1] = k
	end
	table.sort(opciones)
	addDropdown(AutoKills, s, { Title = "Sonido", Flag = "killsoundid", Options = opciones, Default = "ES HACKER", Callback = function(v) killSonidoNombre = v end })
	addSlider(AutoKills, s, { Title = "Volumen", Flag = "killvol", Min = 0.1, Max = 3, Default = 1, Callback = function(v) killVol = v end })
end

local ultimoSonido = 0
local function reproducirKill()
	if not killSonidoOn then
		return
	end
	if os.clock() - ultimoSonido < 0.08 then
		return
	end
	ultimoSonido = os.clock()
	killPlayer.SoundId = killSounds[killSonidoNombre] or killSounds["ES HACKER"]
	killPlayer.Volume = killVol
	killPlayer:Play()
end

do
	local function vigilar(char)
		if not char then
			return
		end
		task.spawn(function()
			local hum = char:WaitForChild("Humanoid", 5)
			if not hum then
				return
			end
			hum.Died:Connect(function()
				local creador = hum:FindFirstChild("creator")
				if creador and creador.Value == LP then
					reproducirKill()
				end
			end)
		end)
	end
	if LP.Character then
		vigilar(LP.Character)
	end
	LP.CharacterAdded:Connect(vigilar)
end

--=============================== SETTINGS =============================
do
	local s = addSection(Settings, "RENDIMIENTO")
	addToggle(Settings, s, { Title = "FPS boost", Flag = "fpsboost", Default = false, Callback = function(v)
		local cache = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				cache[obj] = { mat = obj.Material, refl = obj.Reflectance, shadow = obj.CastShadow }
				pcall(function()
					obj.Material = Enum.Material.SmoothPlastic
					obj.Reflectance = 0
					obj.CastShadow = false
				end)
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				cache[obj] = { tr = obj.Transparency }
				pcall(function()
					obj.Transparency = 1
				end)
			end
		end
		if not v then
			for obj, d in pairs(cache) do
				if obj.Parent then
					pcall(function()
						if d.mat then
							obj.Material = d.mat
							obj.Reflectance = d.refl
							obj.CastShadow = d.shadow
						end
						if d.tr then
							obj.Transparency = d.tr
						end
					end)
				end
			end
		end
	end })

	addToggle(Settings, s, { Title = "Anti lag", Flag = "antilag", Default = false, Callback = function(v)
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
				pcall(function()
					obj.Enabled = not v
				end)
			end
		end
	end })

	local s2 = addSection(Settings, "UTILIDAD")
	local antiafkCon
	addToggle(Settings, s2, { Title = "Anti AFK", Flag = "antiafk", Default = false, Callback = function(v)
		if v and not antiafkCon then
			local vu = game:GetService("VirtualUser")
			antiafkCon = LP.Idled:Connect(function()
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		elseif not v and antiafkCon then
			antiafkCon:Disconnect()
			antiafkCon = nil
		end
	end })

	local s3 = addSection(Settings, "CONFIG")
	addButton(Settings, s3, { Title = "Guardar ahora", Callback = function()
		guardarConfig()
		notify("Configuración guardada", true)
	end })
	addButton(Settings, s3, { Title = "Borrar configuración", Callback = function()
		pcall(function()
			if tieneArchivos() and isfile(CONFIG_FILE) then
				writefile(CONFIG_FILE, "{}")
			end
		end)
		notify("Configuración borrada", false)
	end })
	addParagraph(Settings, s3, "Los cambios se guardan automáticamente. Al reejecutar el script se restauran solos.")

	local s4 = addSection(Settings, "VENTANA")
	addButton(Settings, s4, { Title = "Minimizar", Callback = minimizar })
	addParagraph(Settings, s4, "El botón N flotante reabre el panel sin reejecutar.")
end

--============================== SILENT AIM ============================
do
	if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" and type(checkcaller) == "function" then
		local viejo
		if type(getmetamethod) == "function" then
			local ok, m = pcall(getmetamethod, game, "__namecall")
			if ok then
				viejo = m
			end
		elseif type(getrawmetatable) == "function" then
			local ok, mt = pcall(getrawmetatable, game)
			if ok and mt then
				viejo = rawget(mt, "__namecall")
			end
		end

		if viejo then
			local nuevo
			nuevo = function(self, ...)
				if not silentAimEnabled then
					return viejo(self, ...)
				end
				local metodo = getnamecallmethod()
				if metodo == "Raycast" and self == workspace and not checkcaller() then
					local objetivo = getgenv().NaviTargetPart
					if objetivo and objetivo.Parent then
						local origen, direccion = ...
						if typeof(origen) == "Vector3" and typeof(direccion) == "Vector3" then
							local cam = getCamera()
							local camPos = cam and cam.CFrame.Position or Vector3.zero
							if direccion.Magnitude > 20 and (origen - camPos).Magnitude >= 1 then
								local parte = objetivo
								if silentPart == "Cuerpo completo" then
									local c = objetivo.Parent
									parte = c and c:FindFirstChild("HumanoidRootPart") or objetivo
								end
								local largo = math.max(direccion.Magnitude, 5000)
								return viejo(self, origen, (parte.Position - origen).Unit * largo, select(3, ...))
							end
						end
					end
				end
				return viejo(self, ...)
			end
			getgenv().NaviOldNamecall = viejo
			pcall(function()
				hookmetamethod(game, "__namecall", nuevo)
			end)
		end
	end
end

--============================= LOOP DE AIM ============================
local armaActual
local ultimoDisparo = 0

local function paramsLOS(char, objetivoChar)
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	local lista = { char, objetivoChar }
	for _, otro in ipairs(Players:GetPlayers()) do
		local c = otro.Character
		local hb = c and c:FindFirstChild("Navi_HITBOX")
		if hb then
			lista[#lista + 1] = hb
		end
	end
	p.FilterDescendantsInstances = lista
	return p
end

task.spawn(function()
	while gui.Parent do
		task.wait(0.1)
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local cam = getCamera()

		if aimbotEnabled and hrp and hum and cam then
			local parte = autoShootPart == "Cabeza" and "Head" or "HumanoidRootPart"
			local objetivo = getCercano(fovRadius, parte)
			if objetivo then
				cam.CFrame = CFrame.lookAt(cam.CFrame.Position, objetivo.Position)
			end
		end

		if silentAimEnabled then
			local parte = silentPart == "Cabeza" and "Head" or "HumanoidRootPart"
			setTarget("silent", getCercano(silentAimFov and fovRadius or 100000, parte))
		else
			setTarget("silent", nil)
		end

		if autoShoot or autoShootAgresivo or autoFaked then
			local arma = char and char:FindFirstChildOfClass("Tool")
			if arma and not esCuchillo(arma) then
				armaActual = arma
			end

			local parte = autoShootPart == "Cabeza" and "Head" or "HumanoidRootPart"
			local objetivo = getCercano(200, parte)

			if objetivo then
				local cuerpo = objetivo.Parent
				local apuntar = objetivo
				if autoShootPart == "Cuerpo completo" or autoShootAgresivo then
					apuntar = cuerpo and cuerpo:FindFirstChild("HumanoidRootPart") or objetivo
				end

				local params = paramsLOS(char, cuerpo)
				local ok, res = pcall(function()
					return workspace:Raycast(hrp.Position, apuntar.Position - hrp.Position, params)
				end)

				if ok and (not res or res.Instance:IsDescendantOf(cuerpo)) then
					setTarget("autoShoot", apuntar)
					if (autoShoot or autoShootAgresivo) and armaActual and os.clock() - ultimoDisparo > cadencia then
						ultimoDisparo = os.clock()
						pcall(function()
							armaActual:Activate()
						end)
						task.wait(0.1)
						pcall(function()
							armaActual:Deactivate()
						end)
					end
				else
					setTarget("autoShoot", nil)
				end
			else
				setTarget("autoShoot", nil)
			end
		end
	end
end)

getgenv().NaviCleanup = function()
	if fovCircle then
		pcall(function()
			fovCircle:Remove()
		end)
		fovCircle = nil
	end
	if getgenv().NaviOldNamecall and type(hookmetamethod) == "function" then
		pcall(function()
			hookmetamethod(game, "__namecall", getgenv().NaviOldNamecall)
		end)
		getgenv().NaviOldNamecall = nil
	end
	gui:Destroy()
end

tabs[1].btn.MouseButton1Click:Fire()
notify("Navi Onyx v3 cargado", true)

end

--============================= EJECUCIÓN =============================
local ok, err = xpcall(build, function(e)
	return tostring(e) .. "\n" .. debug.traceback()
end)

if not ok then
	warn("[Navi] " .. tostring(err))
	local fallback = Instance.new("ScreenGui")
	fallback.Name = "NaviError"
	fallback.ResetOnSpawn = false
	fallback.DisplayOrder = 999
	fallback.Parent = LP:WaitForChild("PlayerGui")
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 560, 0, 150)
	frame.Position = UDim2.fromScale(0.5, 0.2)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundColor3 = Color3.fromRGB(25, 3, 6)
	frame.BorderSizePixel = 0
	frame.Parent = fallback
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 1, -20)
	lbl.Position = UDim2.fromOffset(10, 10)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.TextColor3 = Color3.fromRGB(255, 120, 120)
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.Text = "Navi Onyx: error al construir la interfaz\n\n" .. tostring(err)
	lbl.Parent = frame
else
	local aplicados = 0
	pcall(function()
		aplicados = cargarConfig()
	end)
	if aplicados > 0 then
		task.wait(0.2)
		if gui.Parent then
			for _, child in ipairs(gui:GetChildren()) do
				if child:IsA("Frame") and child.Name == "notifyHolder" then
					break
				end
			end
		end
	end
end