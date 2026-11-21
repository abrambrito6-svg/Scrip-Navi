--[[ =====================================================================
     NAVI ONYX  ·  UI v2  (interfaz propia, sin WindUI)
     Fondo: imagen rotativa preservada
     ===================================================================== ]]

if getgenv().NaviCleanup then pcall(getgenv().NaviCleanup) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer
local player = LP

local isEnemy, estaEnLobby, IsInMatchStrict
local esEnemigoValido, esCuchillo, esPistola

local function getCamera() return workspace.CurrentCamera end

--========================= PALETA =========================
local C = {
	bg1      = Color3.fromRGB(24, 3, 5),
	bg2      = Color3.fromRGB(66, 6, 11),
	panel    = Color3.fromRGB(18, 2, 4),
	panel2   = Color3.fromRGB(30, 4, 7),
	stroke   = Color3.fromRGB(150, 16, 28),
	accent   = Color3.fromRGB(226, 32, 46),
	accent2  = Color3.fromRGB(255, 66, 78),
	text     = Color3.fromRGB(243, 234, 234),
	dim      = Color3.fromRGB(172, 118, 124),
	track    = Color3.fromRGB(42, 6, 10),
	white    = Color3.fromRGB(255, 255, 255),
}

local F = { bold = Enum.Font.GothamBold, med = Enum.Font.GothamMedium, reg = Enum.Font.Gotham }

local function new(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then i[k] = v end
	end
	if parent then i.Parent = parent end
	return i
end

local function tw(o, t, props)
	local tween = TweenService:Create(o, TweenInfo.new(t or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

--========================= GUI RAIZ =========================
local gui = new("ScreenGui", {
	Name = "Navi", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
if gethui then pcall(function() gui.Parent = gethui() end) end
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local main = new("Frame", {
	Size = UDim2.fromOffset(820, 462),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.bg1, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
new("UICorner", { CornerRadius = UDim.new(0, 12) }, main)
new("UIStroke", { Color = C.stroke, Thickness = 1.5, Transparency = 0.15 }, main)
new("UIGradient", {
	Color = ColorSequence.new(C.bg2, C.bg1),
	Rotation = 90, Transparency = NumberSequence.new(0.15, 0.35),
}, main)

-- FONDO (intacto, no se toca)
local bgImage = new("ImageLabel", {
	Name = "Fondo", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
	Image = "rbxassetid://126573191582738", ImageTransparency = 0.55,
	ScaleType = Enum.ScaleType.Crop, ZIndex = 1,
}, main)
new("UICorner", { CornerRadius = UDim.new(0, 12) }, bgImage)

local bgIds = {
	"126573191582738", "87524321260822", "1234567890",
	"9876543210", "1122334455", "5544332211",
}

task.spawn(function()
	local index = 1
	while gui.Parent do
		task.wait(5)
		index = index % #bgIds + 1
		tw(bgImage, 0.45, { ImageTransparency = 1 })
		task.wait(0.45)
		bgImage.Image = "rbxassetid://" .. bgIds[index]
		tw(bgImage, 0.45, { ImageTransparency = 0.55 })
	end
end)

--========================= NOTIFICACIONES =========================
local notifyHolder = new("Frame", {
	Size = UDim2.new(0, 250, 1, -24), Position = UDim2.new(1, -264, 0, 12),
	BackgroundTransparency = 1, ZIndex = 60,
}, gui)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, notifyHolder)

local function notify(text, on)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.panel2,
		BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
	}, notifyHolder)
	new("UICorner", { CornerRadius = UDim.new(0, 7) }, card)
	local stroke = new("UIStroke", { Color = on and C.accent or C.dim, Transparency = 1 }, card)
	new("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = on and C.accent or C.dim, BorderSizePixel = 0 }, card)
	local lbl = new("TextLabel", {
		Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1, Font = F.med, TextSize = 12, TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = text, TextTransparency = 1,
	}, card)
	tw(card, 0.15, { BackgroundTransparency = 0.1 })
	tw(stroke, 0.15, { Transparency = 0.2 })
	tw(lbl, 0.15, { TextTransparency = 0 })
	task.delay(2.4, function()
		tw(card, 0.2, { BackgroundTransparency = 1 })
		tw(stroke, 0.2, { Transparency = 1 })
		tw(lbl, 0.2, { TextTransparency = 1 })
		task.wait(0.25)
		card:Destroy()
	end)
end

--========================= HEADER =========================
local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = C.panel,
	BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 5,
}, main)
new("UIStroke", { Color = C.stroke, Thickness = 1, Transparency = 0.55 }, header)

local logo = new("Frame", {
	Size = UDim2.fromOffset(38, 38), Position = UDim2.new(0, 14, 0, 7),
	BackgroundColor3 = Color3.fromRGB(12, 1, 2), BorderSizePixel = 0, ZIndex = 6,
}, header)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, logo)
new("UIStroke", { Color = C.accent, Thickness = 1.5 }, logo)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = F.bold,
	TextSize = 22, TextColor3 = C.accent, Text = "N",
}, logo)

new("TextLabel", {
	Size = UDim2.fromOffset(130, 20), Position = UDim2.new(0, 62, 0, 8),
	BackgroundTransparency = 1, Font = F.bold, TextSize = 15, TextColor3 = C.accent,
	TextXAlignment = Enum.TextXAlignment.Left, Text = "NAVI ONYX",
}, header)
new("TextLabel", {
	Size = UDim2.fromOffset(160, 16), Position = UDim2.new(0, 62, 0, 27),
	BackgroundTransparency = 1, Font = F.reg, TextSize = 10, TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left, Text = "hub de duelos · v2.0",
}, header)

local pingLbl = new("TextLabel", {
	Size = UDim2.fromOffset(70, 16), Position = UDim2.new(0, 200, 0, 18),
	BackgroundTransparency = 1, Font = F.med, TextSize = 11, TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left, Text = "PING: --",
}, header)
task.spawn(function()
	while gui.Parent do
		local ok, v = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		pingLbl.Text = "PING: " .. (ok and math.floor(v) or 0) .. "ms"
		task.wait(1)
	end
end)

local searchBox = new("TextBox", {
	Size = UDim2.fromOffset(190, 30), Position = UDim2.new(1, -246, 0, 11),
	BackgroundColor3 = Color3.fromRGB(10, 1, 2), BackgroundTransparency = 0.35,
	BorderSizePixel = 0, Font = F.reg, TextSize = 12, TextColor3 = C.text,
	PlaceholderText = "Buscar...", PlaceholderColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Text = "",
	ZIndex = 6,
}, header)
new("UICorner", { CornerRadius = UDim.new(0, 7) }, searchBox)
new("UIStroke", { Color = C.stroke, Transparency = 0.6 }, searchBox)
new("UIPadding", { PaddingLeft = UDim.new(0, 9) }, searchBox)

local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -34, 0, 14),
	BackgroundTransparency = 1, Font = F.bold, TextSize = 16, TextColor3 = C.dim,
	Text = "×",
}, header)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

--========================= CUERPO =========================
local body = new("Frame", {
	Size = UDim2.new(1, 0, 1, -78), Position = UDim2.new(0, 0, 0, 52),
	BackgroundTransparency = 1, ZIndex = 4,
}, main)

local sidebar = new("Frame", {
	Size = UDim2.new(0, 168, 1, -10), Position = UDim2.new(0, 10, 0, 5),
	BackgroundColor3 = C.panel, BackgroundTransparency = 0.2,
	BorderSizePixel = 0, ZIndex = 5,
}, body)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, sidebar)
new("UIStroke", { Color = C.stroke, Transparency = 0.55 }, sidebar)
new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, sidebar)
new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, sidebar)

local content = new("Frame", {
	Size = UDim2.new(1, -190, 1, -10), Position = UDim2.new(0, 182, 0, 5),
	BackgroundTransparency = 1, ZIndex = 5,
}, body)

local footer = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 1, -26),
	BackgroundColor3 = C.panel, BackgroundTransparency = 0.35, BorderSizePixel = 0,
	Font = F.med, TextSize = 11, TextColor3 = C.dim, Text = "Navi Onyx · v2.0",
}, main)
new("UIStroke", { Color = C.stroke, Transparency = 0.7 }, footer)

--========================= COMPONENTES =========================
local tabs = {}
local activeTab

local function makeTab(name, icon)
	local page = new("ScrollingFrame", {
		Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false, ZIndex = 5,
	}, content)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10) }, page)

	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.accent,
		BackgroundTransparency = 1, BorderSizePixel = 0, Font = F.med,
		TextSize = 12, TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
		Text = "  " .. icon .. "   " .. name, AutoButtonColor = false,
	}, sidebar)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

	local tab = { page = page, btn = btn, rows = {} }
	tabs[#tabs + 1] = tab

	btn.MouseButton1Click:Connect(function()
		if activeTab == tab then return end
		for _, t in ipairs(tabs) do
			t.page.Visible = false
			tw(t.btn, 0.12, { BackgroundTransparency = 1, TextColor3 = C.dim })
		end
		activeTab = tab
		page.Visible = true
		tw(btn, 0.12, { BackgroundTransparency = 0.15, TextColor3 = C.white })
	end)

	return tab
end

local function addRow(tab, parent, title, h)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, h or 32), BackgroundColor3 = C.panel2,
		BackgroundTransparency = 1, BorderSizePixel = 0,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, row)
	local lbl = new("TextLabel", {
		Size = UDim.new(1, -96), BackgroundTransparency = 1, Font = F.med,
		TextSize = 12.5, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = title,
	}, row)
	tab.rows[#tab.rows + 1] = { row = row, name = title }
	row.MouseEnter:Connect(function() row.BackgroundTransparency = 0.88 end)
	row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)
	return row, lbl
end

local function addSection(tab, title)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.panel,
		BackgroundTransparency = 0.15, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, tab.page)
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
	new("UIStroke", { Color = C.stroke, Transparency = 0.5 }, card)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }, card)

	local head = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = F.bold,
		TextSize = 11.5, TextColor3 = C.accent, TextXAlignment = Enum.TextXAlignment.Left,
		Text = title,
	}, card)
	tab.rows[#tab.rows + 1] = { row = head, name = title }
	return card
end

local function addToggle(tab, parent, o)
	local value = o.Default or false
	local row, lbl = addRow(tab, parent, o.Title, 32)

	local pill = new("Frame", {
		Size = UDim2.fromOffset(38, 19), Position = UDim2.new(1, -44, 0.5, -9.5),
		BackgroundColor3 = value and C.accent or C.track, BorderSizePixel = 0,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(15, 15), Position = UDim2.new(0, value and 20 or 2, 0.5, -7.5),
		BackgroundColor3 = C.white, BorderSizePixel = 0,
	}, pill)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

	local obj = { Value = value }
	function obj:Set(v, silent)
		v = not not v
		self.Value = v
		tw(pill, 0.14, { BackgroundColor3 = v and C.accent or C.track })
		tw(knob, 0.14, { Position = UDim2.new(0, v and 20 or 2, 0.5, -7.5) })
		if not silent then
			notify(o.Title .. (v and " activado" or " desactivado"), v)
		end
		if o.Callback then task.spawn(o.Callback, v) end
	end

	local click = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
	}, row)
	click.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
	return obj
end

local function addSlider(tab, parent, o)
	local value = o.Default or o.Min
	local row, lbl = addRow(tab, parent, o.Title, 34)
	lbl.Text = o.Title .. ": " .. tostring(value)

	local bar = new("Frame", {
		Size = UDim2.new(1, -12, 0, 5), Position = UDim2.new(0, 6, 0, 24),
		BackgroundColor3 = C.track, BorderSizePixel = 0,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0,
	}, bar)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

	local obj = { Value = value }
	local function refresh()
		local alpha = (obj.Value - o.Min) / math.max(o.Max - o.Min, 1e-6)
		fill.Size = UDim2.fromScale(alpha, 1)
		lbl.Text = o.Title .. ": " .. (o.Format and o.Format(obj.Value) or tostring(math.floor(obj.Value * 100 + 0.5) / 100))
	end

	function obj:Set(v, silent)
		self.Value = math.clamp(v, o.Min, o.Max)
		refresh()
		if not silent and o.Callback then task.spawn(o.Callback, self.Value) end
	end

	local dragging = false
	local function update(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		obj:Set(o.Min + (o.Max - o.Min) * rel)
	end

	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			update(i.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	refresh()
	return obj
end

local function addDropdown(tab, parent, o)
	local value = o.Default or (o.Options and o.Options[1]) or ""
	local row, lbl = addRow(tab, parent, o.Title, 32)

	local box = new("TextButton", {
		Size = UDim2.fromOffset(120, 22), Position = UDim2.new(1, -126, 0.5, -11),
		BackgroundColor3 = C.track, BorderSizePixel = 0, Font = F.reg,
		TextSize = 11, TextColor3 = C.text, Text = tostring(value), TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
	new("UIStroke", { Color = C.stroke, Transparency = 0.5 }, box)

	local open = false
	local list = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = C.panel, BorderSizePixel = 0, ClipsDescendants = true,
		Visible = false, ZIndex = 20,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, list)
	new("UIStroke", { Color = C.stroke, Transparency = 0.4 }, list)
	new("UIListLayout", { Padding = UDim.new(0, 1) }, list)
	new("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3) }, list)

	local obj = { Value = value }
	function obj:Set(v, silent)
		self.Value = v
		box.Text = tostring(v)
		if not silent and o.Callback then task.spawn(o.Callback, v) end
	end

	for _, opt in ipairs(o.Options or {}) do
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = C.panel2,
			BackgroundTransparency = 1, BorderSizePixel = 0, Font = F.reg,
			TextSize = 11, TextColor3 = C.dim, Text = opt, ZIndex = 21,
		}, list)
		new("UICorner", { CornerRadius = UDim.new(0, 4) }, b)
		b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.75 b.TextColor3 = C.white end)
		b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 b.TextColor3 = C.dim end)
		b.MouseButton1Click:Connect(function()
			obj:Set(opt)
			open = false
			list.Visible = false
			list.Size = UDim2.new(1, 0, 0, 0)
		end)
	end

	box.MouseButton1Click:Connect(function()
		open = not open
		list.Visible = open
		list.Size = open and UDim2.new(1, 0, 0, math.min(#(o.Options or {}) * 21 + 6, 130)) or UDim2.new(1, 0, 0, 0)
	end)
	return obj
end

local function addButton(tab, parent, o)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.accent,
		BackgroundTransparency = 0.35, BorderSizePixel = 0, Font = F.bold,
		TextSize = 12, TextColor3 = C.text, Text = o.Title, AutoButtonColor = false,
	}, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
	new("UIStroke", { Color = C.accent, Transparency = 0.4 }, b)
	b.MouseEnter:Connect(function() tw(b, 0.1, { BackgroundTransparency = 0.1 }) end)
	b.MouseLeave:Connect(function() tw(b, 0.1, { BackgroundTransparency = 0.35 }) end)
	b.MouseButton1Click:Connect(function()
		if o.Callback then task.spawn(o.Callback) end
	end)
	tab.rows[#tab.rows + 1] = { row = b, name = o.Title }
	return b
end

local function addInput(tab, parent, o)
	local row, lbl = addRow(tab, parent, o.Title, 32)
	lbl.Size = UDim.new(1, -150)
	local box = new("TextBox", {
		Size = UDim2.fromOffset(130, 22), Position = UDim2.new(1, -136, 0.5, -11),
		BackgroundColor3 = C.track, BorderSizePixel = 0, Font = F.reg,
		TextSize = 11, TextColor3 = C.text, PlaceholderText = o.Placeholder or "",
		PlaceholderColor3 = C.dim, Text = "", ClearTextOnFocus = false,
	}, row)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
	new("UIStroke", { Color = C.stroke, Transparency = 0.5 }, box)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, box)
	return box
end

local function addParagraph(tab, parent, text)
	local p = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Font = F.reg,
		TextSize = 11, TextColor3 = C.dim, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, Text = text,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, parent)
	return p
end

local function addColor(tab, parent, o)
	local row = addRow(tab, parent, o.Title, 32)
	local holder = new("Frame", {
		Size = UDim2.fromOffset(130, 20), Position = UDim2.new(1, -136, 0.5, -10),
		BackgroundTransparency = 1,
	}, row)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3) }, holder)
	local presets = {
		Color3.fromRGB(255, 40, 50), Color3.fromRGB(255, 140, 30),
		Color3.fromRGB(255, 235, 60), Color3.fromRGB(70, 255, 120),
		Color3.fromRGB(60, 200, 255), Color3.fromRGB(160, 100, 255),
		Color3.fromRGB(255, 255, 255),
	}
	for _, col in ipairs(presets) do
		local sw = new("TextButton", {
			Size = UDim2.fromOffset(14, 14), BackgroundColor3 = col,
			BorderSizePixel = 0, Text = "",
		}, holder)
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, sw)
		sw.MouseButton1Click:Connect(function()
			if o.Callback then task.spawn(o.Callback, col) end
		end)
	end
end

local function applySearch(query)
	query = query:lower()
	for _, t in ipairs(tabs) do
		for _, r in ipairs(t.rows) do
			r.row.Visible = (query == "" or r.name:lower():find(query, 1, true) ~= nil)
		end
	end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function() applySearch(searchBox.Text) end)

--========================= ARRASTRE =========================
do
	local dragging, startPos, startMouse
	header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startMouse = i.Position
			startPos = main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - startMouse
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

--========================= HELPERS =========================
local function getExecutor()
	local ok, name = pcall(function() return identifyexecutor() end)
	if ok and name then return tostring(name) end
	return "Desconocido"
end

local function getGameName()
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
	end)
	return ok and info and info.Name or "Desconocido"
end

local function isLobby()
	local char = LP.Character
	if not char then return true end
	if char:FindFirstChildOfClass("ForceField") then return true end
	if LP.Team and (LP.Team.Name == "Spectators" or LP.Team.Name == "Lobby") then return true end
	local rs = char:FindFirstChild("GameInProgress")
	return rs and rs:GetAttribute("Value") == false
end
estaEnLobby = isLobby

local function isTeammate(pl)
	if not LP.Team or not pl.Team then return false end
	return pl.Team == LP.Team
end

-- scoreboard del juego
local dmvsTeamResolverState = { InGame = false, Snapshot = {}, Dirty = true, LastRefresh = 0 }
local dmvsScoreboard

local function dmvsGetInGameScoreboard()
	local pg = LP:FindFirstChild("PlayerGui")
	local m = pg and pg:FindFirstChild("Main")
	local g = m and m:FindFirstChild("MainGameFrame")
	return g and g:FindFirstChild("IngameScore")
end

local function dmvsInvalidateScoreboard() dmvsTeamResolverState.Dirty = true end

local function dmvsRefreshScoreboardTeams(force)
	local now = os.clock()
	if not force and not dmvsTeamResolverState.Dirty and now - dmvsTeamResolverState.LastRefresh < 2 then return end
	dmvsTeamResolverState.LastRefresh = now
	dmvsTeamResolverState.Dirty = false
	dmvsScoreboard = dmvsGetInGameScoreboard()
	local snap = {}
	if dmvsScoreboard then
		for _, row in ipairs(dmvsScoreboard:GetDescendants()) do
			if row:IsA("TextLabel") and row.Text ~= "" then
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl ~= LP and (row.Text == pl.Name or row.Text == pl.DisplayName) then
						local enemy = string.find(string.lower(row.Name), "enem") ~= nil
							or string.find(string.lower(row.Parent.Name), "enem") ~= nil
						if enemy then snap[pl] = true end
					end
				end
			end
		end
	end
	dmvsTeamResolverState.Snapshot = snap
	dmvsTeamResolverState.InGame = dmvsScoreboard ~= nil
end

task.spawn(function()
	while gui.Parent do
		task.wait(2)
		dmvsRefreshScoreboardTeams()
	end
end)

isEnemy = function(pl)
	dmvsRefreshScoreboardTeams()
	return dmvsTeamResolverState.Snapshot[pl] == true
end

esCuchillo = function(tool)
	if not tool or not tool:IsA("Tool") then return false end
	return tool:FindFirstChild("Slash") ~= nil or tool:FindFirstChild("SlashStart") ~= nil
end

esPistola = function(tool)
	if not tool or not tool:IsA("Tool") then return false end
	return tool:FindFirstChild("showBeam") ~= nil
end

IsInMatchStrict = function()
	dmvsRefreshScoreboardTeams()
	return dmvsTeamResolverState.InGame
end

esEnemigoValido = function(pl)
	if not pl or pl == LP then return false end
	local char = pl.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if char:FindFirstChildOfClass("ForceField") then return false end
	if estaEnLobby() then return false end
	if isEnemy(pl) then return true end
	if not dmvsTeamResolverState.InGame then return not isTeammate(pl) end
	return false
end

-- para ESP/esqueleto: sin depender del lobby ni del scoreboard
local function esObjetivoVisual(pl)
	if not pl or pl == LP then return false end
	local char = pl.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	return not isTeammate(pl)
end

local function getCercano(radio, partName, usarAtras)
	local mejor, mejorDist
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	for _, pl in ipairs(Players:GetPlayers()) do
		if esEnemigoValido(pl) then
			local c = pl.Character
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local parte = c:FindFirstChild(partName) or c:FindFirstChild("HumanoidRootPart")
				if parte then
					local d = (parte.Position - hrp.Position).Magnitude
					if d <= radio and (not mejorDist or d < mejorDist) then
						mejor, mejorDist = parte, d
					end
				end
			end
		end
	end
	return mejor
end

--========================= ESTADO GLOBAL DE OBJETIVO =========================
local PRIORITY = { telekill = 0, autoShoot = 1, faked = 2, silent = 3 }
local targetSlots = {}

local function resolverObjetivo()
	local best, bestPrio = nil, math.huge
	for k, v in pairs(targetSlots) do
		local prio = PRIORITY[k] or 99
		if v and v.Parent and prio < bestPrio then best, bestPrio = v, prio end
	end
	getgenv().NaviTargetPart = best
end

local function setTarget(slot, part)
	targetSlots[slot] = part
	resolverObjetivo()
end

--========================= PESTAÑAS =========================
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
	addParagraph(Home, s, "Bienvenido a Navi Onyx v2.")
	addParagraph(Home, s, "Ejecutor: " .. getExecutor())
	addParagraph(Home, s, "Juego: " .. getGameName())
	addParagraph(Home, s, "Jugador: " .. LP.DisplayName .. " (@" .. LP.Name .. ")")
	addParagraph(Home, s, "Cierra la ventana con la × de arriba. Vuelve a ejecutar el script para reinstanciarla.")

	local s2 = addSection(Home, "ATAJOS")
	addParagraph(Home, s2, "Ninguno asignado todavía. Usa los toggles de cada pestaña.")

	local s3 = addSection(Home, "ESTADO")
	local statusLbl = addParagraph(Home, s3, "Lobby: --")
	task.spawn(function()
		while gui.Parent do
			task.wait(0.5)
			statusLbl.Text = "Lobby: " .. (estaEnLobby() and "sí" or "no")
				.. "  ·  Scoreboard: " .. (dmvsTeamResolverState.InGame and "detectado" or "no detectado")
		end
	end)
end

--========================= AIMBOT =========================
local aimbotEnabled = false
local silentAimEnabled = false
local silentAimFovEnabled = false
local fovVisible = false
local fovRadius = 120
local silentTargetPart = "Cabeza"
local autoShootEnabled = false
local autoShootTargetPart = "Cabeza"
local autoShootAgresivoEnabled = false
local altoFireEnabled = false
local autoSacarArmaEnabled = false
local autoShotFakedEnabled = false

do
	local s = addSection(Aimbot, "AIMBOT")
	addToggle(Aimbot, s, { Title = "Aimbot", Default = false, Callback = function(v) aimbotEnabled = v end })
	addSlider(Aimbot, s, { Title = "Campo de visión", Min = 10, Max = 800, Default = 120, Callback = function(v) fovRadius = v end })
	addToggle(Aimbot, s, { Title = "Mostrar círculo FOV", Default = false, Callback = function(v) fovVisible = v end })
	addDropdown(Aimbot, s, { Title = "Parte del objetivo", Options = { "Cabeza", "Torso", "Cuerpo completo" }, Default = "Cabeza", Callback = function(v) autoShootTargetPart = v end })

	local s2 = addSection(Aimbot, "SILENT AIM")
	addToggle(Aimbot, s2, { Title = "Silent aim", Default = false, Callback = function(v) silentAimEnabled = v end })
	addToggle(Aimbot, s2, { Title = "Limitar al FOV", Default = false, Callback = function(v) silentAimFovEnabled = v end })
	addDropdown(Aimbot, s2, { Title = "Parte (silent)", Options = { "Cabeza", "Torso", "Cuerpo completo" }, Default = "Cabeza", Callback = function(v) silentTargetPart = v end })

	local s3 = addSection(Aimbot, "AUTO DISPARO")
	addToggle(Aimbot, s3, { Title = "Auto sacar arma", Default = false, Callback = function(v) autoSacarArmaEnabled = v end })
	addToggle(Aimbot, s3, { Title = "Auto shot", Default = false, Callback = function(v) autoShootEnabled = v end })
	addToggle(Aimbot, s3, { Title = "Auto shot agresivo", Default = false, Callback = function(v) autoShootAgresivoEnabled = v end })
	addToggle(Aimbot, s3, { Title = "Alto fire", Default = false, Callback = function(v) altoFireEnabled = v end })
	addToggle(Aimbot, s3, { Title = "Auto shot faked", Default = false, Callback = function(v) autoShotFakedEnabled = v end })
	addSlider(Aimbot, s3, { Title = "Cadencia", Min = 0.05, Max = 1, Default = 0.2, Callback = function(v) end })
end

-- FOV circle
local fovCircle
do
	local function asegurar()
		if fovCircle then return end
		local ok, d = pcall(function()
			return Drawing.new("Circle")
		end)
		if ok then fovCircle = d end
	end
	RunService.RenderStepped:Connect(function()
		if not fovVisible then
			if fovCircle then fovCircle.Visible = false end
			return
		end
		asegurar()
		if not fovCircle then return end
		local cam = getCamera()
		fovCircle.Visible = true
		fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
		fovCircle.Radius = fovRadius
		fovCircle.Thickness = 1.5
		fovCircle.Color = Color3.fromRGB(226, 32, 46)
		fovCircle.Transparency = 0.35
	end)
end

--========================= VISUALES / ESP =========================
local espEnabled = false
local skeletonEnabled = false
local SkeletonColor = Color3.fromRGB(255, 40, 50)
local MAX_ESP = 1500
local espFolder = new("Folder", { Name = "NaviESP" }, gui)
local activeSkeletons = {}
local espConns = {}

do
	local s = addSection(Visuales, "JUGADORES")
	addToggle(Visuales, s, { Title = "ESP", Default = false, Callback = function(v) espEnabled = v end })
	addToggle(Visuales, s, { Title = "Esqueleto ESP", Default = false, Callback = function(v) skeletonEnabled = v end })
	addColor(Visuales, s, { Title = "Color del esqueleto", Callback = function(col) SkeletonColor = col end })

	local s2 = addSection(Visuales, "HITBOX")
	local hitboxEnabled = false
	local hitboxTamano = 3.5
	addToggle(Visuales, s2, { Title = "Hitbox expander", Default = false, Callback = function(v) hitboxEnabled = v end })
	addSlider(Visuales, s2, { Title = "Tamaño", Min = 1, Max = 12, Default = 3.5, Callback = function(v) hitboxTamano = v end })

	task.spawn(function()
		while gui.Parent do
			task.wait(0.4)
			if not hitboxEnabled then continue end
			for _, pl in ipairs(Players:GetPlayers()) do
				if esObjetivoVisual(pl) then
					local char = pl.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp then
						local hb = char:FindFirstChild("Navi_HITBOX")
						if not hb then
							hb = new("Part", {
								Name = "Navi_HITBOX", Size = Vector3.new(hitboxTamano, hitboxTamano, hitboxTamano),
								Transparency = 0.75, CanCollide = false, CanQuery = true,
								Color = C.accent, Massless = true, Parent = char,
							})
							new("SelectionBox", { Adornee = hb, Color3 = C.accent, LineThickness = 0.02, Parent = hb })
							local weld = new("WeldConstraint", { Part0 = hrp, Part1 = hb, Parent = hb })
							hb.CFrame = hrp.CFrame
						elseif hb.Size ~= Vector3.new(hitboxTamano, hitboxTamano, hitboxTamano) then
							hb.Size = Vector3.new(hitboxTamano, hitboxTamano, hitboxTamano)
						end
					end
				end
			end
		end
	end)
end

local function limpiarESP(pl)
	local h = espFolder:FindFirstChild(pl.Name .. "Navi")
	if h then h:Destroy() end
	local char = pl.Character
	if char then
		local hb = char:FindFirstChild("Navi_HITBOX")
		if hb then hb:Destroy() end
	end
end

-- ESQUELETO (reescrito)
local function buscarParte(char, ...)
	for _, n in ipairs({ ... }) do
		local p = char:FindFirstChild(n)
		if p and p:IsA("BasePart") then return p end
	end
	return nil
end

local function limpiarEsqueleto(char)
	local rec = activeSkeletons[char]
	if not rec then return end
	for _, o in ipairs(rec.todos) do
		if o and o.Parent then pcall(function() o:Destroy() end) end
	end
	activeSkeletons[char] = nil
end

local function construirEsqueleto(char)
	if activeSkeletons[char] then return end
	local head = buscarParte(char, "Head")
	local hrp = buscarParte(char, "HumanoidRootPart")
	if not (head and hrp) then return end

	local upper = buscarParte(char, "UpperTorso", "Torso")
	local lower = buscarParte(char, "LowerTorso", "Torso") or upper
	local lua_ = buscarParte(char, "LeftUpperArm", "Left Arm")
	local lla = buscarParte(char, "LeftLowerArm", "Left Arm") or lua_
	local lh  = buscarParte(char, "LeftHand", "Left Arm") or lla
	local rua = buscarParte(char, "RightUpperArm", "Right Arm")
	local rla = buscarParte(char, "RightLowerArm", "Right Arm") or rua
	local rh  = buscarParte(char, "RightHand", "Right Arm") or rla
	local lul = buscarParte(char, "LeftUpperLeg", "Left Leg")
	local lll = buscarParte(char, "LeftLowerLeg", "Left Leg") or lul
	local lf  = buscarParte(char, "LeftFoot", "Left Leg") or lll
	local rul = buscarParte(char, "RightUpperLeg", "Right Leg")
	local rll = buscarParte(char, "RightLowerLeg", "Right Leg") or rul
	local rf  = buscarParte(char, "RightFoot", "Right Leg") or rll

	local rec = { todos = {}, beams = {} }
	activeSkeletons[char] = rec

	local function att(part, pos)
		local a = new("Attachment", { Position = pos, Parent = part })
		rec.todos[#rec.todos + 1] = a
		return a
	end

	local function hueso(pA, oA, pB, oB)
		if not pA or not pB then return end
		local b = new("Beam", {
			Attachment0 = att(pA, oA), Attachment1 = att(pB, oB),
			Color = ColorSequence.new(SkeletonColor), LightEmission = 1,
			FaceCamera = true, Width0 = 0.055, Width1 = 0.055,
			Transparency = NumberSequence.new(skeletonEnabled and 0 or 1),
			Parent = char,
		})
		rec.todos[#rec.todos + 1] = b
		rec.beams[#rec.beams + 1] = b
	end

	hueso(head, Vector3.new(0, -0.5, 0), upper, Vector3.new(0, 0.85, 0))
	hueso(upper, Vector3.new(0, 0.6, 0), lower, Vector3.new(0, -0.6, 0))
	hueso(upper, Vector3.new(0.85, 0.55, 0), lua_, Vector3.new(0, 0.5, 0))
	hueso(lua_, Vector3.new(0, -0.4, 0), lla, Vector3.new(0, 0.4, 0))
	hueso(lla, Vector3.new(0, -0.4, 0), lh, Vector3.new(0, 0.2, 0))
	hueso(upper, Vector3.new(-0.85, 0.55, 0), rua, Vector3.new(0, 0.5, 0))
	hueso(rua, Vector3.new(0, -0.4, 0), rla, Vector3.new(0, 0.4, 0))
	hueso(rla, Vector3.new(0, -0.4, 0), rh, Vector3.new(0, 0.2, 0))
	hueso(lower, Vector3.new(0.45, -0.5, 0), lul, Vector3.new(0, 0.5, 0))
	hueso(lul, Vector3.new(0, -0.5, 0), lll, Vector3.new(0, 0.5, 0))
	hueso(lll, Vector3.new(0, -0.5, 0), lf, Vector3.new(0, 0.2, 0))
	hueso(lower, Vector3.new(-0.45, -0.5, 0), rul, Vector3.new(0, 0.5, 0))
	hueso(rul, Vector3.new(0, -0.5, 0), rll, Vector3.new(0, 0.5, 0))
	hueso(rll, Vector3.new(0, -0.5, 0), rf, Vector3.new(0, 0.2, 0))
end

local function actualizarEsqueleto(char)
	local rec = activeSkeletons[char]
	if not rec then return end
	local vis = skeletonEnabled and esObjetivoVisual(Players:GetPlayerFromCharacter(char))
	for _, b in ipairs(rec.beams) do
		if b.Parent then
			b.Transparency = NumberSequence.new(vis and 0 or 1)
			b.Color = ColorSequence.new(SkeletonColor)
		end
	end
end

task.spawn(function()
	while gui.Parent do
		task.wait(0.3)
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		for _, pl in ipairs(Players:GetPlayers()) do
			local valido = esObjetivoVisual(pl)
			local char = pl.Character
			local cerca = valido and hrp and char and char:FindFirstChild("HumanoidRootPart")
				and (char.HumanoidRootPart.Position - hrp.Position).Magnitude <= MAX_ESP

			local h = espFolder:FindFirstChild(pl.Name .. "Navi")
			if espEnabled and cerca then
				if not h then
					h = new("Highlight", {
						Name = pl.Name .. "Navi", Adornee = char,
						FillColor = C.accent, FillTransparency = 0.7,
						OutlineColor = C.accent2, OutlineTransparency = 0.2,
						DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = espFolder,
					})
				end
				if skeletonEnabled then
					construirEsqueleto(char)
					actualizarEsqueleto(char)
				end
			else
				if h then h:Destroy() end
			end
			if char and activeSkeletons[char] then actualizarEsqueleto(char) end
		end
	end
end)

do
	local function vigilar(char)
		if not char then return end
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.Died:Connect(function() limpiarEsqueleto(char) end)
		end
		char.AncestryChanged:Connect(function()
			if not char.Parent then limpiarEsqueleto(char) end
		end)
	end
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl.Character then vigilar(pl.Character) end
		pl.CharacterAdded:Connect(vigilar)
	end
	Players.PlayerAdded:Connect(function(pl)
		pl.CharacterAdded:Connect(vigilar)
	end)
	Players.PlayerRemoving:Connect(function(pl)
		limpiarESP(pl)
		if pl.Character then limpiarEsqueleto(pl.Character) end
	end)
end

--========================= MOVIMIENTO =========================
local spinEnabled = false
local spinSpeed = 12
local godModeEnabled = false
local godModeSpeed = 1.2
local telaEnabled = false
local telaForce = 1.4
local invisEnabled = false
local flyEnabled = false
local flySpeed = 0.75

do
	local s = addSection(Movimiento, "MOVIMIENTO")
	addToggle(Movimiento, s, { Title = "Spin", Default = false, Callback = function(v) spinEnabled = v end })
	addSlider(Movimiento, s, { Title = "Velocidad de spin", Min = 1, Max = 60, Default = 12, Callback = function(v) spinSpeed = v end })
	addToggle(Movimiento, s, { Title = "Zigzag", Default = false, Callback = function(v) godModeEnabled = v end })
	addSlider(Movimiento, s, { Title = "Fuerza zigzag", Min = 0.2, Max = 4, Default = 1.2, Callback = function(v) godModeSpeed = v end })
	addToggle(Movimiento, s, { Title = "Movimiento tela", Default = false, Callback = function(v) telaEnabled = v end })
	addSlider(Movimiento, s, { Title = "Fuerza tela", Min = 0.2, Max = 4, Default = 1.4, Callback = function(v) telaForce = v end })

	local s2 = addSection(Movimiento, "VUELO")
	addToggle(Movimiento, s2, { Title = "Volar", Default = false, Callback = function(v) flyEnabled = v end })
	addSlider(Movimiento, s2, { Title = "Velocidad de vuelo", Min = 0.1, Max = 4, Default = 0.75, Callback = function(v) flySpeed = v end })

	local s3 = addSection(Movimiento, "VISUAL")
	addToggle(Movimiento, s3, { Title = "Invisible", Default = false, Callback = function(v) invisEnabled = v end })
end

-- driver único de movimiento (independiente de FPS)
local TS = 0
RunService.RenderStepped:Connect(function(dt)
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end
	local k = dt * 60

	if spinEnabled then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed) * k, 0)
	end
	if godModeEnabled then
		hrp.CFrame = hrp.CFrame * CFrame.new(
			math.sin(tick() * 14) * godModeSpeed * 0.3 * k, 0,
			math.cos(tick() * 11) * godModeSpeed * 0.3 * k)
	end
	if telaEnabled and hum.MoveDirection.Magnitude > 0 then
		TS += dt * 38
		hrp.CFrame = hrp.CFrame * CFrame.new(math.sin(TS) * telaForce * 0.6 * k, 0, 0)
		hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.28 * k
	end
	if flyEnabled then
		hum:ChangeState(Enum.HumanoidStateType.Flying)
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += getCamera().CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= getCamera().CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= getCamera().CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += getCamera().CFrame.RightVector end
		if dir.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + dir.Unit * flySpeed * k
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, flySpeed * k, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			hrp.CFrame = hrp.CFrame - Vector3.new(0, flySpeed * k, 0)
		end
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
end)

-- invisible
do
	local function aplicar(char, on)
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
				pcall(function()
					if on then v.LocalTransparencyModifier = 1 else v.LocalTransparencyModifier = 0 end
				end)
			end
		end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			local cam = getCamera()
			hum.CameraOffset = on and Vector3.new(0, 0, 0) or Vector3.zero
			if on and cam then
				hum.CameraOffset = cam.CFrame:PointToObjectSpace(cam.CFrame.Position) * 0 + Vector3.new(0, 0, 0)
			end
		end
	end

	RunService.RenderStepped:Connect(function()
		if not invisEnabled then return end
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
				v.LocalTransparencyModifier = 1
			end
		end
	end)

	task.spawn(function()
		local was = false
		while gui.Parent do
			task.wait(0.2)
			if invisEnabled ~= was then
				was = invisEnabled
				local char = LP.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and not invisEnabled then
					hum.CameraOffset = Vector3.zero
					for _, v in ipairs(char:GetDescendants()) do
						if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
					end
				end
			end
		end
	end)
end

--========================= ANIMACIONES =========================
local packs = {
	["Ninja"] = { idle = 656117400, walk = 656121766, run = 656118852, jump = 656117878, fall = 656115606 },
	["Zombie"] = { idle = 3489171152, walk = 3489187502, run = 3489176752, jump = 3489181340, fall = 3489177666 },
	["Levitar"] = { idle = 616006778, walk = 616008087, run = 616013216, jump = 616010382, fall = 616008936 },
	["Astronauta"] = { idle = 891621366, walk = 891633237, run = 891627514, jump = 891635357, fall = 891617961 },
	["Robot"] = { idle = 616088211, walk = 616090535, run = 616092998, jump = 616086039, fall = 616090808 },
	["Mago"] = { idle = 7077426394, walk = 7077457503, run = 7077446371, jump = 7077460573, fall = 7077453194 },
}
local packNames = {}
for k in pairs(packs) do packNames[#packNames + 1] = k end

local function idsActuales(char)
	local anim = char and char:FindFirstChild("Animate")
	local out = {}
	if not anim then return out end
	local function g(p, c)
		local node = anim:FindFirstChild(p)
		local a = node and node:FindFirstChild(c)
		return a and a.AnimationId or ""
	end
	out.idle = g("idle", "Animation1")
	out.walk = g("walk", "WalkAnim")
	out.run = g("run", "RunAnim")
	out.jump = g("jump", "JumpAnim")
	out.fall = g("fall", "FallAnim")
	return out
end

local function aplicarPack(nombre)
	local char = LP.Character
	local anim = char and char:FindFirstChild("Animate")
	local pack = packs[nombre]
	if not anim or not pack then return end
	local base = idsActuales(char)
	local function s(p, c, id)
		local node = anim:FindFirstChild(p)
		local a = node and node:FindFirstChild(c)
		if a then a.AnimationId = "rbxassetid://" .. (id or 0) end
	end
	s("idle", "Animation1", pack.idle)
	s("walk", "WalkAnim", pack.walk)
	s("run", "RunAnim", pack.run)
	s("jump", "JumpAnim", pack.jump)
	s("fall", "FallAnim", pack.fall)
	notify("Animación aplicada: " .. nombre, true)
end

do
	local s = addSection(Animaciones, "PAQUETES")
	local lista = {}
	for _, n in ipairs(packNames) do lista[#lista + 1] = n end
	local sel = addDropdown(Animaciones, s, { Title = "Paquete", Options = lista, Default = lista[1] })
	addButton(Animaciones, s, { Title = "Aplicar", Callback = function() aplicarPack(sel.Value) end })
	addButton(Animaciones, s, { Title = "Restaurar default", Callback = function()
		local char = LP.Character
		local anim = char and char:FindFirstChild("Animate")
		if anim then anim:Destroy() end
		notify("Animaciones restauradas", true)
	end })
end

--========================= AUTO FARM =========================
local autoFarmEnabled = false
local farmRadio = 60
local farmVelocidad = 22
local farmCaminar = true
local farmPrompts = true
local farmPerseguir = false

do
	local s = addSection(AutoFarm, "RECOLECCIÓN")
	addToggle(AutoFarm, s, { Title = "Auto farm", Default = false, Callback = function(v) autoFarmEnabled = v end })
	addSlider(AutoFarm, s, { Title = "Radio", Min = 10, Max = 200, Default = 60, Callback = function(v) farmRadio = v end })
	addSlider(AutoFarm, s, { Title = "Velocidad al caminar", Min = 16, Max = 60, Default = 22, Callback = function(v) farmVelocidad = v end })
	addToggle(AutoFarm, s, { Title = "Caminar hacia objetos", Default = true, Callback = function(v) farmCaminar = v end })
	addToggle(AutoFarm, s, { Title = "Usar proximity prompts", Default = true, Callback = function(v) farmPrompts = v end })

	local s2 = addSection(AutoFarm, "COMBATE")
	addToggle(AutoFarm, s2, { Title = "Perseguir enemigos", Default = false, Callback = function(v) farmPerseguir = v end })
	addParagraph(AutoFarm, s2, "Perseguir usa el scoreboard del juego; si no se detecta, cae a 'cualquiera que no sea de tu equipo'.")
end

local NOMBRES_ITEM = { "coin", "egg", "cash", "money", "gem", "token", "huevo", "moneda", "orb", "crate", "chest" }

local function esItem(obj)
	if not obj:IsA("BasePart") then return false end
	local n = obj.Name:lower()
	for _, k in ipairs(NOMBRES_ITEM) do
		if n:find(k, 1, true) then return true end
	end
	return false
end

local function recolectar(hrp)
	local total = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if esItem(obj) then
			local d = (obj.Position - hrp.Position).Magnitude
			if d <= farmRadio then
				if obj.CanTouch then pcall(firetouchinterest, hrp, obj, 0) pcall(firetouchinterest, hrp, obj, 1) end
				if farmPrompts then
					for _, pr in ipairs(obj:GetChildren()) do
						if pr:IsA("ProximityPrompt") and pr.Enabled then pcall(fireproximityprompt, pr) end
					end
				end
				for _, cd in ipairs(obj:GetChildren()) do
					if cd:IsA("ClickDetector") then pcall(fireclickdetector, cd) end
				end
				total += 1
			end
		elseif farmPrompts and obj:IsA("ProximityPrompt") and obj.Enabled then
			local padre = obj.Parent
			if padre and padre:IsA("BasePart") and (padre.Position - hrp.Position).Magnitude <= farmRadio then
				pcall(fireproximityprompt, obj)
			end
		end
	end
	return total
end

local function itemCercano(hrp)
	local mejor, mejorDist
	for _, obj in ipairs(workspace:GetDescendants()) do
		if esItem(obj) then
			local d = (obj.Position - hrp.Position).Magnitude
			if d <= farmRadio * 2.5 and (not mejorDist or d < mejorDist) then
				mejor, mejorDist = obj, d
			end
		end
	end
	return mejor
end

task.spawn(function()
	local walkOriginal = 16
	local guardado = false
	while task.wait(0.2) do
		if not autoFarmEnabled then
			if guardado then
				local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = walkOriginal end
				guardado = false
			end
			continue
		end
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not (hum and hrp) or hum.Health <= 0 then continue end

		if not guardado then
			walkOriginal = hum.WalkSpeed
			guardado = true
		end

		recolectar(hrp)

		if farmCaminar then
			hum.WalkSpeed = farmVelocidad
			local it = itemCercano(hrp)
			if it then hum:MoveTo(it.Position) end
		end

		if farmPerseguir then
			local enemigo = getCercano(300, "HumanoidRootPart")
			if enemigo then hum:MoveTo(enemigo.Position) end
		end
	end
end)

--========================= AUTO KILLS =========================
local atrasEnabled = false
local loopAtrasActivo = false

do
	local s = addSection(AutoKills, "TELEKILL")
	addToggle(AutoKills, s, { Title = "Teleport detrás", Default = false, Callback = function(v) atrasEnabled = v end })
	addButton(AutoKills, s, { Title = "Telekill completo", Callback = function()
		autoShootEnabled = true
		autoShootAgresivoEnabled = true
		altoFireEnabled = true
		atrasEnabled = true
		notify("Telekill completo armado", true)
	end })
end

local function loopAtras()
	if loopAtrasActivo then return end
	loopAtrasActivo = true
	task.spawn(function()
		while task.wait() and atrasEnabled do
			local char = LP.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local obj = getCercano(200, "HumanoidRootPart")
			if hrp and obj then
				local destino = obj.CFrame * CFrame.new(0, 0, 2.6)
				hrp.CFrame = CFrame.lookAt(destino.Position, obj.Position)
				hrp.AssemblyLinearVelocity = Vector3.zero
				setTarget("telekill", obj)
			else
				setTarget("telekill", nil)
			end
			RunService.Heartbeat:Wait()
		end
		setTarget("telekill", nil)
		loopAtrasActivo = false
	end)
end
task.spawn(function()
	while task.wait(0.25) do
		if atrasEnabled then loopAtras() end
	end
end)

--========================= SONIDO DE KILL =========================
local killSounds = {
	["ES HACKER"] = "rbxassetid://131961136",
	["ONICHAAAN"] = "rbxassetid://1837835458",
	["TACTICAL"] = "rbxassetid://130791264",
	["BASS"] = "rbxassetid://142376088",
	["DING"] = "rbxassetid://3120926404",
}
local killSoundEnabled = false
local killSoundName = "ES HACKER"
local killSoundVol = 1
local killPlayer = new("Sound", { Volume = 1, Parent = game:GetService("SoundService") })

do
	local s = addSection(AutoKills, "SONIDO")
	addToggle(AutoKills, s, { Title = "Sonido de kill", Default = false, Callback = function(v) killSoundEnabled = v end })
	local opts = {}
	for k in pairs(killSounds) do opts[#opts + 1] = k end
	table.sort(opts)
	addDropdown(AutoKills, s, { Title = "Sonido", Options = opts, Default = "ES HACKER", Callback = function(v) killSoundName = v end })
	addSlider(AutoKills, s, { Title = "Volumen", Min = 0.1, Max = 3, Default = 1, Callback = function(v) killSoundVol = v end })
end

local ultimoSonido = 0
local function reproducirKill()
	if not killSoundEnabled then return end
	if os.clock() - ultimoSonido < 0.08 then return end
	ultimoSonido = os.clock()
	killPlayer.SoundId = killSounds[killSoundName] or killSounds["ES HACKER"]
	killPlayer.Volume = killSoundVol
	killPlayer:Play()
end

do
	local function vigilar(char)
		if not char then return end
		local hum = char:WaitForChild("Humanoid", 5)
		if not hum then return end
		hum.Died:Connect(function()
			local creador = hum:FindFirstChild("creator")
			local autor = creador and creador.Value
			if autor == LP then reproducirKill() end
		end)
	end
	if LP.Character then vigilar(LP.Character) end
	LP.CharacterAdded:Connect(vigilar)
end

--========================= SETTINGS =========================
do
	local s = addSection(Settings, "RENDIMIENTO")
	addToggle(Settings, s, { Title = "FPS boost", Default = false, Callback = function(v)
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
				pcall(function() obj.Transparency = 1 end)
			end
		end
		if v then
			cacheFps = cache
		else
			for obj, d in pairs(cache) do
				if obj.Parent then
					pcall(function()
						if d.mat then obj.Material = d.mat obj.Reflectance = d.refl obj.CastShadow = d.shadow end
						if d.tr then obj.Transparency = d.tr end
					end)
				end
			end
		end
	end })

	local antilag = false
	addToggle(Settings, s, { Title = "Anti lag", Default = false, Callback = function(v)
		antilag = v
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")
				or obj:IsA("Fire") or obj:IsA("Sparkles") then
				pcall(function() obj.Enabled = not v end)
			end
		end
	end })

	local s2 = addSection(Settings, "UTILIDAD")
	addToggle(Settings, s2, { Title = "Anti AFK", Default = false, Callback = function(v)
		local vu = game:GetService("VirtualUser")
		if v then
			LP.Idled:Connect(function()
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
			notify("Anti AFK activado", true)
		end
	end })
end

--========================= SILENT AIM (hook) =========================
do
	if getgenv().NaviOldNamecall then
		pcall(function() hookmetamethod(game, "__namecall", getgenv().NaviOldNamecall) end)
	end
	local viejo = getmetamethod(game, "__namecall")
	if viejo then
		local nuevo
		nuevo = function(self, ...)
			if not silentAimEnabled then return viejo(self, ...) end
			local metodo = getnamecallmethod()
			if metodo == "Raycast" and self == workspace and not checkcaller() then
				local objetivo = getgenv().NaviTargetPart
				if objetivo and objetivo.Parent then
					local origen, direccion = ...
					if typeof(origen) == "Vector3" and typeof(direccion) == "Vector3" then
						local cam = getCamera()
						local camPos = cam.CFrame.Position
						local usar = direccion.Magnitude > 20 and (origen - camPos).Magnitude >= 1
						if usar then
							local parte = objetivo
							if silentTargetPart == "Cuerpo completo" then
								local char = objetivo.Parent
								parte = char and char:FindFirstChild("HumanoidRootPart") or objetivo
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
		pcall(function() hookmetamethod(game, "__namecall", nuevo) end)
	end
end

--========================= LOOP DE APUNTADO =========================
local function paramsLOS(char, objetivoChar)
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	local lista = { char, objetivoChar }
	for _, otro in ipairs(Players:GetPlayers()) do
		local c = otro.Character
		local hb = c and c:FindFirstChild("Navi_HITBOX")
		if hb then lista[#lista + 1] = hb end
	end
	p.FilterDescendantsInstances = lista
	return p
end

local armaActual = nil
local ultimoDisparo = 0

task.spawn(function()
	while gui.Parent do
		task.wait(0.1)
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local cam = getCamera()

		if aimbotEnabled and hrp and hum and cam then
			local objetivo = getCercano(fovRadius, autoShootTargetPart == "Cabeza" and "Head" or "HumanoidRootPart")
			if objetivo then
				cam.CFrame = CFrame.lookAt(cam.CFrame.Position, objetivo.Position)
			end
		end

		if silentAimEnabled then
			local objetivo = getCercano(silentAimFovEnabled and fovRadius or math.huge, silentTargetPart == "Cabeza" and "Head" or "HumanoidRootPart")
			setTarget("silent", objetivo)
		else
			setTarget("silent", nil)
		end

		if autoShootEnabled or autoShootAgresivoEnabled or autoShotFakedEnabled then
			local arma = char and char:FindFirstChildOfClass("Tool")
			if arma and not esCuchillo(arma) then
				armaActual = arma
			end

			local objetivo = getCercano(200, autoShootTargetPart == "Cabeza" and "Head" or "HumanoidRootPart")

			if objetivo then
				local parte = objetivo
				if autoShootTargetPart == "Cuerpo completo" or autoShootAgresivoEnabled then
					local c = objetivo.Parent
					parte = c and c:FindFirstChild("HumanoidRootPart") or objetivo
				end

				local params = paramsLOS(char, parte.Parent)
				local ok, res = pcall(function()
					return workspace:Raycast(hrp.Position, parte.Position - hrp.Position, params)
				end)

				if ok and (not res or res.Instance:IsDescendantOf(parte.Parent)) then
					setTarget("autoShoot", parte)
					if (autoShootEnabled or autoShootAgresivoEnabled) and armaActual and os.clock() - ultimoDisparo > 0.2 then
						ultimoDisparo = os.clock()
						pcall(function() armaActual:Activate() end)
						task.wait(0.12)
						pcall(function() armaActual:Deactivate() end)
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

--========================= CLEANUP =========================
getgenv().NaviCleanup = function()
	if fovCircle then pcall(function() fovCircle:Remove() end) end
	if getgenv().NaviOldNamecall then
		pcall(function() hookmetamethod(game, "__namecall", getgenv().NaviOldNamecall) end)
		getgenv().NaviOldNamecall = nil
	end
	gui:Destroy()
end

-- abrir la primera pestaña
tabs[1].btn.MouseButton1Click:Fire()
notify("Navi Onyx v2 cargado", true)