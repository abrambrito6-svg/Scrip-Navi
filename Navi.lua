--[[
	ONYX  |  Duelos HUB  |  By Navi
	loadstring(game:HttpGet("https://raw.githubusercontent.com/abrambrito6-svg/Scrip-Navi/main/Navi.lua"))()
--]]

if getgenv().Onyx and getgenv().Onyx.Unload then
	pcall(function() getgenv().Onyx.Unload() end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local nc = newcclosure or function(f) return f end

local CONFIG = {
	Name = "Onyx",
	Sub = "Duelos | HUB",
	By = "By Navi",
	Version = "v1.0.0",
	Background = "https://files.catbox.moe/dohhak.jpg",
	Discord = "https://discord.gg/",
	Keybind = Enum.KeyCode.RightShift,
}

local T = {
	Bg = Color3.fromRGB(10, 10, 12),
	Panel = Color3.fromRGB(16, 16, 19),
	Card = Color3.fromRGB(22, 22, 26),
	Line = Color3.fromRGB(38, 38, 44),
	Text = Color3.fromRGB(238, 238, 242),
	Dim = Color3.fromRGB(132, 132, 142),
	Accent = Color3.fromRGB(240, 240, 245),
	Off = Color3.fromRGB(52, 52, 60),
}

local F
local okFont = pcall(function()
	F = {
		Reg = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
		Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
	}
end)
if not okFont or not F then
	F = { Reg = Font.fromEnum(Enum.Font.Gotham), Bold = Font.fromEnum(Enum.Font.GothamBold) }
end

local Lang = {
	es = {
		combat = "COMBATE", general = "GENERAL", hub = "HUB",
		search = "Buscar funcion...",
		knife = "Cuchillo", gun = "Arma", aim = "Aim", hitbox = "Hitbox",
		player = "Player", visuals = "Visuals", misc = "Misc",
		settings = "Ajustes", profiles = "Perfiles",
		kill_all = "Matar a todos", kill_all_d = "Camina hacia los enemigos y les tira cuchillos",
		keep_kill = "Mantener Matar a todos", keep_kill_d = "Reengancha la funcion sola",
		auto_knife = "Cuchillo automatico", auto_knife_d = "Tira el cuchillo sin parar",
		equip_knife = "Equipar cuchillo solo", equip_knife_d = "Lo saca cuando hace falta",
		inf_knife = "Cuchillo infinito", inf_knife_d = "Rafaga de lanzamientos",
		reload_bar = "Indicador de recarga", reload_bar_d = "Muestra cuando el arma recarga",
		silent = "Silent aim", silent_d = "Redirige el disparo al enemigo",
		silent_part = "Parte del silent aim", silent_chance = "Chance de acierto", silent_fov = "FOV del silent",
		auto_shoot = "Disparo automatico", auto_shoot_d = "Dispara solo cuando hay objetivo",
		draw_gun = "Sacar arma", draw_gun_d = "Equipa el arma al instante",
		save_gun = "Guardar arma", save_gun_d = "La vuelve a guardar",
		aimbot = "Aimbot (camlock)", aimbot_d = "La camara sigue al enemigo",
		aim_part = "Parte del aimbot", aim_fov = "FOV del aimbot", aim_smooth = "Suavizado",
		hitbox_on = "Hitbox", hitbox_on_d = "Agranda la hitbox de los enemigos",
		hitbox_size = "Tamano de hitbox", show_hitbox = "Mostrar hitbox", hitbox_op = "Opacidad",
		hitbox_color = "Color de hitbox",
		walkspeed = "Velocidad", jump = "Fuerza de salto",
		inf_jump = "Salto infinito", fly = "Volar", fly_speed = "Velocidad de vuelo",
		antiafk = "Anti-AFK", reset = "Reaparecer",
		esp = "ESP", esp_d = "Se ve a traves de las paredes",
		esp_box = "Cajas", esp_name = "Nombres", esp_dist = "Distancia",
		esp_hp = "Barra de vida", esp_tracer = "Trazos", chams = "Chams (resaltado)",
		fullbright = "Fullbright", nofog = "Quitar niebla",
		fps = "Boost FPS", jobid = "Copiar Job ID", rejoin = "Rejoin", hop = "Server hop",
		keybind = "Tecla para abrir/cerrar", scale = "Escala del panel", bg_on = "Fondo",
		notif = "Notificaciones", fovcircle = "Circulo de FOV", unload = "Desinstalar",
		save = "Guardar config", load = "Cargar config", del = "Borrar config",
		discord = "Discord", reload = "Recargar script", info = "Informacion",
		players = "EN SERVIDOR", copy = "Copiado",
	},
	en = {
		combat = "COMBAT", general = "GENERAL", hub = "HUB",
		search = "Search feature...",
		knife = "Knife", gun = "Gun", aim = "Aim", hitbox = "Hitbox",
		player = "Player", visuals = "Visuals", misc = "Misc",
		settings = "Settings", profiles = "Profiles",
		kill_all = "Kill all", kill_all_d = "Walks to enemies and throws knives",
		keep_kill = "Keep Kill all", keep_kill_d = "Re-engages on its own",
		auto_knife = "Auto knife", auto_knife_d = "Throws the knife nonstop",
		equip_knife = "Auto equip knife", equip_knife_d = "Equips it when needed",
		inf_knife = "Infinite knife", inf_knife_d = "Spam throws",
		reload_bar = "Reload indicator", reload_bar_d = "Shows when the gun reloads",
		silent = "Silent aim", silent_d = "Redirects shots to the enemy",
		silent_part = "Silent aim part", silent_chance = "Hit chance", silent_fov = "Silent FOV",
		auto_shoot = "Auto shoot", auto_shoot_d = "Shoots when a target is found",
		draw_gun = "Draw gun", draw_gun_d = "Equips the gun instantly",
		save_gun = "Holster gun", save_gun_d = "Puts it back",
		aimbot = "Aimbot (camlock)", aimbot_d = "Camera follows the enemy",
		aim_part = "Aimbot part", aim_fov = "Aimbot FOV", aim_smooth = "Smoothing",
		hitbox_on = "Hitbox", hitbox_on_d = "Expands enemy hitboxes",
		hitbox_size = "Hitbox size", show_hitbox = "Show hitbox", hitbox_op = "Opacity",
		hitbox_color = "Hitbox color",
		walkspeed = "WalkSpeed", jump = "JumpPower",
		inf_jump = "Infinite jump", fly = "Fly", fly_speed = "Fly speed",
		antiafk = "Anti-AFK", reset = "Respawn",
		esp = "ESP", esp_d = "Visible through walls",
		esp_box = "Boxes", esp_name = "Names", esp_dist = "Distance",
		esp_hp = "Health bar", esp_tracer = "Tracers", chams = "Chams (highlight)",
		fullbright = "Fullbright", nofog = "No fog",
		fps = "FPS boost", jobid = "Copy Job ID", rejoin = "Rejoin", hop = "Server hop",
		keybind = "Toggle key", scale = "Panel scale", bg_on = "Background",
		notif = "Notifications", fovcircle = "FOV circle", unload = "Uninstall",
		save = "Save config", load = "Load config", del = "Delete config",
		discord = "Discord", reload = "Reload script", info = "Info",
		players = "IN SERVER", copy = "Copied",
	},
}
Lang.pt = Lang.en
local LangKey = "es"
local function L(k)
	local t = Lang[LangKey]
	return (t and t[k]) or Lang.es[k] or k
end

local S = {
	KillAll = false, KeepKill = false, AutoKnife = false, EquipKnife = true, InfKnife = false,
	ReloadBar = true,
	Silent = false, SilentPart = "Head", SilentChance = 100, SilentFOV = 320,
	AutoShoot = false,
	Aimbot = false, AimPart = "Head", AimFOV = 260, AimSmooth = 0.22,
	Hitbox = false, HitboxSize = 20, ShowHitbox = true, HitboxOp = 6.5,
	HitboxColor = Color3.fromRGB(255, 60, 60),
	ESP = false, ESPBox = true, ESPName = true, ESPDist = true, ESPHP = true,
	ESPTracer = false, Chams = true,
	WalkSpeed = 16, JumpPower = 50, InfJump = false, Fly = false, FlySpeed = 60,
	AntiAFK = false, Fullbright = false, NoFog = false,
	Notif = true, FovCircle = true, Bg = true, Scale = 1,
	KeybindName = "RightShift",
}

local Connections = {}
local function conn(c)
	table.insert(Connections, c)
	return c
end

local function new(class, props, children)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then o[k] = v end
	end
	for _, ch in ipairs(children or {}) do ch.Parent = o end
	if props and props.Parent then o.Parent = props.Parent end
	return o
end

local function tw(o, t, p)
	local a = TweenService:Create(o, TweenInfo.new(t or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
	a:Play()
	return a
end

local Gui = new("ScreenGui", {
	Name = "Onyx",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

local Blur = new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.45,
	Visible = false,
	Parent = Gui,
})

local Main = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(628, 418),
	BackgroundColor3 = T.Bg,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Parent = Gui,
}, {
	new("UICorner", { CornerRadius = UDim.new(0, 12) }),
	new("UIStroke", { Color = T.Line, Thickness = 1 }),
})

local Scale = new("UIScale", { Parent = Main, Scale = 1 })

local BgImage = new("ImageLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ImageTransparency = 0.55,
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 0,
	Parent = Main,
})
local BgShade = new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = T.Bg,
	BackgroundTransparency = 0.35,
	ZIndex = 1,
	Parent = Main,
})
new("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.55, 0.72),
		NumberSequenceKeypoint.new(1, 0.94),
	}),
	Parent = BgShade,
})

local function notify(title, text, dur)
	if not S.Notif then return end
	local card = new("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(272, 58),
		BackgroundColor3 = T.Card,
		BackgroundTransparency = 1,
		Parent = Gui,
		ZIndex = 50,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0, 9) }),
		new("UIStroke", { Color = T.Line, Transparency = 1 }),
	})
	local stroke = card:FindFirstChildOfClass("UIStroke")
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = T.Accent,
		BorderSizePixel = 0, Parent = card,
	})
	local ti = new("TextLabel", {
		Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1, FontFace = F.Bold, TextSize = 13,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = title, TextTransparency = 1, Parent = card,
	})
	local tx = new("TextLabel", {
		Position = UDim2.fromOffset(12, 27), Size = UDim2.new(1, -24, 0, 22),
		BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 11,
		TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, Text = text, TextTransparency = 1, Parent = card,
	})
	tw(card, 0.2, { BackgroundTransparency = 0 })
	tw(ti, 0.2, { TextTransparency = 0 })
	tw(tx, 0.2, { TextTransparency = 0 })
	tw(stroke, 0.2, { Transparency = 0 })
	tw(bar, dur or 2, { Size = UDim2.new(0, 0, 0, 2) })
	task.delay(dur or 2, function()
		if card and card.Parent then
			tw(card, 0.2, { BackgroundTransparency = 1 })
			tw(ti, 0.2, { TextTransparency = 1 })
			tw(tx, 0.2, { TextTransparency = 1 })
			tw(stroke, 0.2, { Transparency = 1 })
			task.delay(0.25, function() card:Destroy() end)
		end
	end)
end

local Top = new("Frame", {
	Size = UDim2.new(1, 0, 0, 56),
	BackgroundTransparency = 1,
	ZIndex = 5,
	Parent = Main,
})
new("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = T.Line,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	Parent = Top,
})
new("Frame", {
	Position = UDim2.fromOffset(14, 13),
	Size = UDim2.fromOffset(30, 30),
	BackgroundColor3 = T.Accent,
	Parent = Top,
}, {
	new("UICorner", { CornerRadius = UDim.new(1, 0) }),
	new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		FontFace = F.Bold, TextSize = 16, TextColor3 = T.Bg, Text = "O",
	}),
})
new("TextLabel", {
	Position = UDim2.fromOffset(54, 11), Size = UDim2.fromOffset(150, 18),
	BackgroundTransparency = 1, FontFace = F.Bold, TextSize = 15,
	TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
	Text = CONFIG.Name, Parent = Top,
})
new("TextLabel", {
	Position = UDim2.fromOffset(54, 29), Size = UDim2.fromOffset(230, 14),
	BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 11,
	TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
	Text = CONFIG.Sub .. "  ·  " .. CONFIG.By, Parent = Top,
})
new("Frame", {
	Position = UDim2.fromOffset(196, 14), Size = UDim2.fromOffset(1, 12),
	BackgroundColor3 = T.Line, BorderSizePixel = 0, Parent = Top,
})
new("TextLabel", {
	Position = UDim2.fromOffset(204, 13), Size = UDim2.fromOffset(52, 15),
	BackgroundColor3 = T.Card, FontFace = F.Bold, TextSize = 10,
	TextColor3 = T.Dim, Text = CONFIG.Version, Parent = Top,
}, { new("UICorner", { CornerRadius = UDim.new(0, 4) }) })

local Info = new("TextLabel", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -96, 0, 12),
	Size = UDim2.fromOffset(100, 16), BackgroundTransparency = 1,
	FontFace = F.Reg, TextSize = 11, TextColor3 = T.Dim,
	TextXAlignment = Enum.TextXAlignment.Right, Text = "0 FPS", Parent = Top,
})
local Online = new("TextLabel", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -96, 0, 29),
	Size = UDim2.fromOffset(100, 14), BackgroundTransparency = 1,
	FontFace = F.Reg, TextSize = 10, TextColor3 = T.Dim,
	TextXAlignment = Enum.TextXAlignment.Right, Text = "0 " .. L("players"), Parent = Top,
})

local function iconBtn(text, x, cb)
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 13),
		Size = UDim2.fromOffset(26, 26), BackgroundColor3 = T.Card,
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = Top,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0, 6) }),
		new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			FontFace = F.Bold, TextSize = 13, TextColor3 = T.Dim, Text = text,
		}),
	})
	local lbl = b:FindFirstChildOfClass("TextLabel")
	conn(b.MouseEnter:Connect(function()
		tw(b, 0.15, { BackgroundTransparency = 0 })
		lbl.TextColor3 = T.Text
	end))
	conn(b.MouseLeave:Connect(function()
		tw(b, 0.15, { BackgroundTransparency = 1 })
		lbl.TextColor3 = T.Dim
	end))
	conn(b.MouseButton1Click:Connect(cb))
	return b
end

local Side = new("Frame", {
	Position = UDim2.fromOffset(0, 56),
	Size = UDim2.new(0, 148, 1, -56),
	BackgroundTransparency = 1,
	ZIndex = 4,
	Parent = Main,
})
new("Frame", {
	Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = T.Line, BackgroundTransparency = 0.4, BorderSizePixel = 0, Parent = Side,
})
local Search = new("Frame", {
	Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -20, 0, 28),
	BackgroundColor3 = T.Card, Parent = Side,
}, { new("UICorner", { CornerRadius = UDim.new(0, 7) }) })
new("TextLabel", {
	Position = UDim2.fromOffset(9, 0), Size = UDim2.fromOffset(12, 28),
	BackgroundTransparency = 1, FontFace = F.Bold, TextSize = 12,
	TextColor3 = T.Dim, Text = "/",
})
local SearchBox = new("TextBox", {
	Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -32, 1, 0),
	BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 11,
	TextColor3 = T.Text, PlaceholderText = L("search"),
	PlaceholderColor3 = T.Dim, Text = "", ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = Search,
})

local SideList = new("ScrollingFrame", {
	Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 1, -50),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 2, ScrollBarImageColor3 = T.Line,
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Side,
}, {
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
})

local Content = new("ScrollingFrame", {
	Position = UDim2.fromOffset(148, 56),
	Size = UDim2.new(1, -148, 1, -56),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 2, ScrollBarImageColor3 = T.Line,
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ZIndex = 3, Parent = Main,
}, {
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 16),
		PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 16),
	}),
})

local dragging, dragStart, startPos = false, nil, nil
conn(Top.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging, dragStart, startPos = true, i.Position, Main.Position
	end
end))
conn(UserInputService.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end))
conn(UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end))

local function fitScale()
	local vp = Workspace.CurrentCamera.ViewportSize
	local s = math.min(1, (vp.X - 24) / 628, (vp.Y - 24) / 418) * S.Scale
	Scale.Scale = math.clamp(s, 0.45, 1.15)
end
conn(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale))

local Float = new("TextButton", {
	Position = UDim2.new(0, 18, 0.5, 0),
	Size = UDim2.fromOffset(46, 46),
	BackgroundColor3 = T.Card, Text = "", AutoButtonColor = false,
	Visible = false, Parent = Gui, ZIndex = 60,
}, {
	new("UICorner", { CornerRadius = UDim.new(1, 0) }),
	new("UIStroke", { Color = T.Line }),
	new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		FontFace = F.Bold, TextSize = 17, TextColor3 = T.Text, Text = "O",
	}),
})

local function setPanel(v)
	if v then
		Main.Visible = true
		Blur.Visible = true
		Float.Visible = false
		fitScale()
		Scale.Scale = Scale.Scale * 0.93
		tw(Scale, 0.18, { Scale = math.clamp(Scale.Scale / 0.93, 0.45, 1.15) })
	else
		Main.Visible = false
		Blur.Visible = false
		Float.Visible = true
	end
end

local fDrag, fStart, fPos, fMoved = false, nil, nil, false
conn(Float.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		fDrag, fStart, fPos, fMoved = true, i.Position, Float.Position, false
	end
end))
conn(UserInputService.InputChanged:Connect(function(i)
	if fDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - fStart
		if math.abs(d.X) + math.abs(d.Y) > 4 then fMoved = true end
		Float.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
	end
end))
conn(UserInputService.InputEnded:Connect(function(i)
	if fDrag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
		fDrag = false
		if not fMoved then setPanel(true) end
	end
end))

iconBtn("–", -46, function() setPanel(false) end)
iconBtn("x", -14, function()
	pcall(function() getgenv().Onyx.Unload() end)
end)

local function getCam() return Workspace.CurrentCamera end

local function isEnemy(plr)
	if plr == LP then return false end
	local char = plr.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	local myG, g = LP:GetAttribute("Game"), plr:GetAttribute("Game")
	if myG and g and myG ~= g then return false end
	local myT, t = LP:GetAttribute("Team"), plr:GetAttribute("Team")
	if myT and t and myT == t then return false end
	return true
end

local function partOf(char, name)
	if not char then return nil end
	local p = char:FindFirstChild(name)
	if p and p:IsA("BasePart") then return p end
	return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function getTarget(maxDist, fov, partName)
	local cam = getCam()
	if not cam then return nil end
	local myChar = LP.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or cam.CFrame.Position
	local center = cam.ViewportSize / 2
	local best, bestScore
	for _, plr in ipairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			local p = partOf(plr.Character, partName or "Head")
			if p then
				local d = (p.Position - origin).Magnitude
				if d <= (maxDist or 900) then
					local sp, on = cam:WorldToViewportPoint(p.Position)
					if on and sp.Z > 0 then
						local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
						if d2 <= (fov or 320) then
							local score = d2 + d * 0.04
							if not bestScore or score < bestScore then bestScore, best = score, p end
						end
					end
				end
			end
		end
	end
	return best
end

local function currentTool()
	local char = LP.Character
	return char and char:FindFirstChildOfClass("Tool") or nil
end
local function hasGun()
	local t = currentTool()
	if not t then return false end
	local n = t.Name:lower()
	return t:FindFirstChild("fire") ~= nil or n:match("gun") or n:match("revolver") or n:match("pistol")
end
local function hasKnife()
	local t = currentTool()
	if not t then return false end
	local n = t.Name:lower()
	return t:FindFirstChild("throw") ~= nil or n:match("knife") or n:match("cuchillo")
end
local function equip(kind)
	local bp = LP:FindFirstChild("Backpack")
	local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if not bp or not hum then return end
	for _, t in ipairs(bp:GetChildren()) do
		if t:IsA("Tool") then
			local n = t.Name:lower()
			local ok = (kind == "gun" and (t:FindFirstChild("fire") or n:match("gun") or n:match("revolver")))
				or (kind == "knife" and (t:FindFirstChild("throw") or n:match("knife")))
			if ok then
				hum:EquipTool(t)
				return
			end
		end
	end
end

local oldIndex
local hookOK = pcall(function()
	oldIndex = hookmetamethod(game, "__index", nc(function(self, k)
		if S.Silent and self == Mouse and (k == "Hit" or k == "Target") and (hasGun() or hasKnife()) then
			if math.random(1, 100) <= S.SilentChance then
				local t = getTarget(900, S.SilentFOV, S.SilentPart)
				if t then
					if k == "Target" then return t end
					local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
					local o = root and root.Position or getCam().CFrame.Position
					local dir = t.Position - o
					if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, 1) end
					return CFrame.lookAt(t.Position, t.Position + dir.Unit)
				end
			end
		end
		return oldIndex(self, k)
	end))
end)

local function click()
	local cam = getCam()
	if not cam then return end
	local vp = cam.ViewportSize
	local x, y = vp.X / 2, vp.Y / 2
	pcall(function() VirtualInputManager:SendMouseMoveEvent(x, y, game) end)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	task.wait(0.02)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local ReloadBar = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 34),
	Size = UDim2.fromOffset(64, 4), BackgroundColor3 = T.Card,
	BackgroundTransparency = 1, Parent = Gui, ZIndex = 70,
}, {
	new("UICorner", { CornerRadius = UDim.new(1, 0) }),
	new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.Accent, BorderSizePixel = 0 },
		{ new("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
})
local ReloadFill = ReloadBar:FindFirstChildOfClass("Frame")

local function reloadFlash()
	ReloadFill.Size = UDim2.fromScale(0, 1)
	ReloadBar.BackgroundTransparency = 0.35
	tw(ReloadFill, 0.85, { Size = UDim2.fromScale(1, 1) })
	task.delay(0.9, function() ReloadBar.BackgroundTransparency = 1 end)
end

local function shoot()
	local t = currentTool()
	if t then
		local fire = t:FindFirstChild("fire")
		if fire and fire:IsA("RemoteEvent") then
			local tgt = getTarget(900, S.SilentFOV, S.SilentPart)
			local cam = getCam()
			local hit = tgt and cam and CFrame.lookAt(tgt.Position, tgt.Position + (tgt.Position - cam.CFrame.Position).Unit)
			local ok = pcall(function() fire:FireServer(hit or Mouse.Hit, tgt or Mouse.Target) end)
			if ok then return end
		end
	end
	click()
end

local function throwKnife()
	local t = currentTool()
	if t then
		local r = t:FindFirstChild("throw") or t:FindFirstChild("Throw")
		if r and r:IsA("RemoteEvent") then
			local tgt = getTarget(900, 9999, "Head")
			if tgt then
				local ok = pcall(function() r:FireServer(tgt.Position) end)
				if ok then return end
			end
		end
	end
	click()
end

local killToken = 0
local function killAll()
	killToken = killToken + 1
	local token = killToken
	if S.EquipKnife then equip("knife") end
	while S.KillAll and token == killToken do
		local t = getTarget(2000, 9999, "Head")
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not t or not hum or not root then
			task.wait(0.15)
		else
			local d = (t.Position - root.Position).Magnitude
			if d > 16 then
				hum:MoveTo(t.Position)
				task.wait(0.08)
			else
				hum:MoveTo(t.Position)
				if hasKnife() then throwKnife() else equip("knife") end
				task.wait(0.3)
			end
		end
	end
end

local HbSaved = {}
local function applyHitbox(plr)
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if not HbSaved[hrp] then
		HbSaved[hrp] = { Size = hrp.Size, Transparency = hrp.Transparency, Color = hrp.Color, CanCollide = hrp.CanCollide }
	end
	local s = S.HitboxSize
	hrp.Size = Vector3.new(s, s, s)
	hrp.Color = S.HitboxColor
	hrp.Transparency = S.ShowHitbox and (1 - S.HitboxOp / 10) or 1
	hrp.CanCollide = false
end
local function clearHitbox(plr)
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and HbSaved[hrp] then
		local o = HbSaved[hrp]
		hrp.Size, hrp.Transparency, hrp.Color, hrp.CanCollide = o.Size, o.Transparency, o.Color, o.CanCollide
		HbSaved[hrp] = nil
	end
end

local ESPData = {}
local function createESP(plr)
	if ESPData[plr] then return end
	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Visible = false
	box.Color = Color3.fromRGB(240, 240, 245)
	local nm = Drawing.new("Text")
	nm.Size = 13
	nm.Center = true
	nm.Outline = true
	nm.Visible = false
	nm.Color = Color3.fromRGB(255, 255, 255)
	local ds = Drawing.new("Text")
	ds.Size = 12
	ds.Center = true
	ds.Outline = true
	ds.Visible = false
	ds.Color = Color3.fromRGB(200, 200, 210)
	local hp = Drawing.new("Square")
	hp.Thickness = 0
	hp.Filled = true
	hp.Visible = false
	hp.Color = Color3.fromRGB(80, 230, 120)
	local tr = Drawing.new("Line")
	tr.Thickness = 1
	tr.Visible = false
	tr.Color = Color3.fromRGB(240, 240, 245)
	tr.Transparency = 0.5
	local hl = Instance.new("Highlight")
	hl.FillColor = Color3.fromRGB(240, 240, 245)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.72
	hl.OutlineTransparency = 1
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	ESPData[plr] = { box = box, name = nm, dist = ds, hp = hp, tracer = tr, hl = hl }
end
local function destroyESP(plr)
	local d = ESPData[plr]
	if not d then return end
	for _, k in ipairs({ "box", "name", "dist", "hp", "tracer" }) do
		pcall(function() d[k]:Remove() end)
	end
	pcall(function() d.hl:Destroy() end)
	ESPData[plr] = nil
end

conn(RunService.RenderStepped:Connect(function()
	local cam = getCam()
	if not cam then return end
	for plr, d in pairs(ESPData) do
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local head = char and char:FindFirstChild("Head")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local show = S.ESP and char and hrp and head and hum and hum.Health > 0 and isEnemy(plr)
		if not show then
			d.box.Visible = false
			d.name.Visible = false
			d.dist.Visible = false
			d.hp.Visible = false
			d.tracer.Visible = false
			if d.hl.Parent ~= nil then d.hl.Enabled = false end
		else
			d.hl.Enabled = S.Chams
			if d.hl.Parent ~= char then d.hl.Parent = char end
			local sp, on = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
			local rp = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.7, 0))
			if on and sp.Z > 0 then
				local h = math.clamp(math.abs(rp.Y - sp.Y), 12, 700)
				local w = h * 0.52
				local x, y = sp.X - w / 2, sp.Y
				d.box.Size = Vector2.new(w, h)
				d.box.Position = Vector2.new(x, y)
				d.box.Visible = S.ESPBox
				d.name.Position = Vector2.new(sp.X, y - 16)
				d.name.Text = plr.Name
				d.name.Visible = S.ESPName
				d.dist.Position = Vector2.new(sp.X, y + h + 2)
				d.dist.Text = math.floor((hrp.Position - cam.CFrame.Position).Magnitude) .. "m"
				d.dist.Visible = S.ESPDist
				d.hp.Size = Vector2.new(3, h)
				d.hp.Position = Vector2.new(x - 6, y)
				d.hp.Color = Color3.fromRGB(80, 230, 120):Lerp(Color3.fromRGB(235, 70, 70), 1 - hum.Health / hum.MaxHealth)
				d.hp.Visible = S.ESPHP
				d.tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
				d.tracer.To = Vector2.new(sp.X, y + h)
				d.tracer.Visible = S.ESPTracer
			else
				d.box.Visible = false
				d.name.Visible = false
				d.dist.Visible = false
				d.hp.Visible = false
				d.tracer.Visible = false
			end
		end
	end
end))

local FovC = Drawing.new("Circle")
FovC.Thickness = 1
FovC.Color = Color3.fromRGB(240, 240, 245)
FovC.Transparency = 0.35
FovC.Filled = false
FovC.Visible = false
conn(RunService.RenderStepped:Connect(function()
	local cam = getCam()
	if not cam then return end
	FovC.Position = cam.ViewportSize / 2
	FovC.Radius = S.Silent and S.SilentFOV or S.Aimbot and S.AimFOV or 0
	FovC.Visible = S.FovCircle and (S.Silent or S.Aimbot)
end))

conn(RunService.RenderStepped:Connect(function()
	if not S.Aimbot then return end
	local cam = getCam()
	local t = getTarget(900, S.AimFOV, S.AimPart)
	if t and cam then
		local goal = CFrame.lookAt(cam.CFrame.Position, t.Position)
		cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(1 - S.AimSmooth, 0.02, 1))
	end
end))

local acc = { shoot = 0, knife = 0 }
conn(RunService.Heartbeat:Connect(function()
	local now = os.clock()
	if S.KeepKill and not S.KillAll then
		S.KillAll = true
		task.spawn(killAll)
	end
	if S.AutoShoot then
		if not hasGun() then equip("gun") end
		if now - acc.shoot > 0.12 and hasGun() and getTarget(900, S.SilentFOV, S.SilentPart) then
			acc.shoot = now
			shoot()
			if S.ReloadBar then reloadFlash() end
		end
	end
	if S.AutoKnife or S.InfKnife then
		if not hasKnife() then
			if S.EquipKnife then equip("knife") end
		elseif now - acc.knife > (S.InfKnife and 0.05 or 0.3) then
			acc.knife = now
			throwKnife()
		end
	end
end))

conn(RunService.Heartbeat:Connect(function()
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = S.Fly and S.FlySpeed or S.WalkSpeed
		hum.JumpPower = S.JumpPower
		hum.UseJumpPower = true
	end
	if S.Hitbox then
		for _, plr in ipairs(Players:GetPlayers()) do
			if isEnemy(plr) then applyHitbox(plr) end
		end
	end
end))

conn(UserInputService.JumpRequest:Connect(function()
	if S.InfJump then
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end))

local flyBV, flyBG
conn(RunService.Heartbeat:Connect(function()
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if S.Fly and hrp then
		if not flyBV or flyBV.Parent ~= hrp then
			if flyBV then flyBV:Destroy() end
			if flyBG then flyBG:Destroy() end
			flyBV = Instance.new("BodyVelocity", hrp)
			flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			flyBV.Velocity = Vector3.zero
			flyBG = Instance.new("BodyGyro", hrp)
			flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
			flyBG.P = 1e4
		end
		local cam = getCam()
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
		flyBG.CFrame = cam.CFrame
		flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * S.FlySpeed or Vector3.zero
	else
		if flyBV then flyBV:Destroy(); flyBV = nil end
		if flyBG then flyBG:Destroy(); flyBG = nil end
	end
end))

conn(LP.CharacterAdded:Connect(function()
	task.wait(0.6)
	fitScale()
end))
conn(Players.PlayerAdded:Connect(function(p)
	if S.ESP and p ~= LP then createESP(p) end
end))
conn(Players.PlayerRemoving:Connect(destroyESP))

local function applyVisuals()
	if S.Fullbright then
		Lighting.Ambient = Color3.fromRGB(180, 180, 180)
		Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
		Lighting.Brightness = 2
	else
		Lighting.Ambient = Color3.fromRGB(70, 70, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.Brightness = 1
	end
	Lighting.FogEnd = S.NoFog and 1e6 or 1000
end

local Defs, ActivePage, PageBtns = {}, nil, {}
local saveCfg, loadCfg, delCfg, loadBg

local function createSection(parent, title)
	local head = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
		FontFace = F.Bold, TextSize = 10, TextColor3 = T.Dim,
		TextXAlignment = Enum.TextXAlignment.Left, Text = title, Parent = parent,
	})
	new("UIPadding", { PaddingTop = UDim.new(0, 4), Parent = head })
	local body = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y, Parent = parent,
	}, { new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
	return { head = head, body = body }
end

local function baseRow(parent, h)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, h or 32), BackgroundColor3 = T.Card,
		BackgroundTransparency = 1, Parent = parent,
	}, { new("UICorner", { CornerRadius = UDim.new(0, 7) }) })
	local fill = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.Card,
		BackgroundTransparency = 1, Parent = row,
	}, { new("UICorner", { CornerRadius = UDim.new(0, 7) }) })
	conn(row.MouseEnter:Connect(function() tw(fill, 0.15, { BackgroundTransparency = 0.35 }) end))
	conn(row.MouseLeave:Connect(function() tw(fill, 0.15, { BackgroundTransparency = 1 }) end))
	return row
end

local function createToggle(parent, text, desc, key, cb)
	local row = baseRow(parent, desc and 40 or 32)
	local lbl = new("TextLabel", {
		Position = UDim2.fromOffset(10, desc and 5 or 0), Size = UDim2.new(1, -56, 0, desc and 16 or 32),
		BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 12,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = text, Parent = row,
	})
	if desc then
		new("TextLabel", {
			Position = UDim2.fromOffset(10, 21), Size = UDim2.new(1, -56, 0, 14),
			BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 10,
			TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left, Text = desc, Parent = row,
		})
	end
	local pill = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(34, 18), BackgroundColor3 = T.Off, Parent = row,
	}, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(14, 14), BackgroundColor3 = T.Text, Parent = pill,
	}, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local function paint(v)
		tw(pill, 0.15, { BackgroundColor3 = v and T.Accent or T.Off })
		tw(knob, 0.15, { Position = v and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
		tw(knob, 0.15, { BackgroundColor3 = v and T.Bg or T.Text })
		lbl.TextColor3 = v and T.Text or T.Dim
	end
	paint(S[key] and true or false)

	local btn = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row })
	conn(btn.MouseButton1Click:Connect(function()
		S[key] = not S[key]
		paint(S[key])
		if cb then pcall(cb, S[key]) end
	end))
	local el = { row = row, text = text .. " " .. (desc or "") }
	return el
end

local function createSlider(parent, text, key, min, max, dec, cb)
	local row = baseRow(parent, 44)
	new("TextLabel", {
		Position = UDim2.fromOffset(10, 5), Size = UDim2.new(1, -60, 0, 14),
		BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 12,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = text, Parent = row,
	})
	local val = new("TextLabel", {
		Position = UDim2.new(1, -58, 0, 5), Size = UDim2.fromOffset(48, 14),
		BackgroundTransparency = 1, FontFace = F.Bold, TextSize = 11,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Right,
		Text = tostring(S[key]), Parent = row,
	})
	local track = new("Frame", {
		Position = UDim2.fromOffset(10, 27), Size = UDim2.new(1, -20, 0, 5),
		BackgroundColor3 = T.Line, BorderSizePixel = 0, Parent = row,
	}, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local fillBar = new("Frame", {
		Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.Accent,
		BorderSizePixel = 0, Parent = track,
	}, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(10, 10), BackgroundColor3 = T.Accent, Parent = track,
	}, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local function paint(v)
		local a = math.clamp((v - min) / (max - min), 0, 1)
		fillBar.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		val.Text = dec and string.format("%." .. dec .. "f", v) or tostring(math.floor(v))
	end
	paint(S[key])

	local sdrag = false
	local function fromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = min + rel * (max - min)
		if dec then
			v = tonumber(string.format("%." .. dec .. "f", v))
		else
			v = math.floor(v + 0.5)
		end
		S[key] = v
		paint(v)
		if cb then pcall(cb, v) end
	end
	conn(track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sdrag = true
			fromX(i.Position.X)
		end
	end))
	conn(UserInputService.InputChanged:Connect(function(i)
		if sdrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromX(i.Position.X)
		end
	end))
	conn(UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sdrag = false
		end
	end))
	return { row = row, text = text }
end

local function createButton(parent, text, desc, cb)
	local row = baseRow(parent, desc and 38 or 30)
	local lbl = new("TextLabel", {
		Position = UDim2.fromOffset(10, desc and 4 or 0), Size = UDim2.new(1, -20, 0, desc and 15 or 30),
		BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 12,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = text, Parent = row,
	})
	if desc then
		new("TextLabel", {
			Position = UDim2.fromOffset(10, 19), Size = UDim2.new(1, -20, 0, 13),
			BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 10,
			TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left, Text = desc, Parent = row,
		})
	end
	local btn = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row })
	conn(btn.MouseButton1Click:Connect(function()
		pcall(cb)
		tw(lbl, 0.1, { TextColor3 = T.Accent })
		task.delay(0.15, function()
			if lbl and lbl.Parent then lbl.TextColor3 = T.Text end
		end)
	end))
	return { row = row, text = text .. " " .. (desc or "") }
end

local function createDropdown(parent, text, key, options, cb)
	local row = baseRow(parent, 32)
	new("TextLabel", {
		Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -120, 0, 32),
		BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 12,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = text, Parent = row,
	})
	local btn = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(100, 20), BackgroundColor3 = T.Bg, Text = "", Parent = row,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0, 5) }),
		new("UIStroke", { Color = T.Line }),
		new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, FontFace = F.Reg,
			TextSize = 11, TextColor3 = T.Dim, Text = tostring(S[key]),
		}),
	})
	local lbl = btn:FindFirstChildOfClass("TextLabel")
	local list = new("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 1, 3),
		Size = UDim2.fromOffset(100, #options * 19 + 6), BackgroundColor3 = T.Card,
		Visible = false, ZIndex = 40, Parent = row,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0, 6) }),
		new("UIStroke", { Color = T.Line }),
		new("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }),
		new("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3) }),
	})
	for _, opt in ipairs(options) do
		local ob = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "",
			AutoButtonColor = false, Parent = list,
		}, {
			new("TextLabel", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
				FontFace = F.Reg, TextSize = 11, TextColor3 = T.Dim, Text = opt,
			}),
		})
		local ol = ob:FindFirstChildOfClass("TextLabel")
		conn(ob.MouseEnter:Connect(function() ol.TextColor3 = T.Text end))
		conn(ob.MouseLeave:Connect(function() ol.TextColor3 = T.Dim end))
		conn(ob.MouseButton1Click:Connect(function()
			S[key] = opt
			lbl.Text = opt
			lbl.TextColor3 = T.Text
			list.Visible = false
			if cb then pcall(cb, opt) end
		end))
	end
	conn(btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end))
	return { row = row, text = text }
end

local Palette = {
	Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 140, 40), Color3.fromRGB(250, 220, 60),
	Color3.fromRGB(80, 230, 120), Color3.fromRGB(70, 200, 255), Color3.fromRGB(120, 120, 255),
	Color3.fromRGB(210, 90, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 120, 190),
	Color3.fromRGB(20, 20, 24),
}

local function createColor(parent, text, key, cb)
	local row = baseRow(parent, 32)
	new("TextLabel", {
		Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 0, 32),
		BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 12,
		TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = text, Parent = row,
	})
	local sw = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(38, 18), BackgroundColor3 = S[key], Text = "", Parent = row,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0, 5) }),
		new("UIStroke", { Color = T.Line }),
	})
	local pal = new("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 1, 3),
		Size = UDim2.fromOffset(146, 24), BackgroundColor3 = T.Card,
		Visible = false, ZIndex = 40, Parent = row,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0, 6) }),
		new("UIStroke", { Color = T.Line }),
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingTop = UDim.new(0, 4) }),
	})
	for _, c in ipairs(Palette) do
		local dot = new("TextButton", {
			Size = UDim2.fromOffset(10, 16), BackgroundColor3 = c, Text = "", Parent = pal,
		}, { new("UICorner", { CornerRadius = UDim.new(0, 3) }) })
		conn(dot.MouseButton1Click:Connect(function()
			S[key] = c
			sw.BackgroundColor3 = c
			pal.Visible = false
			if cb then pcall(cb, c) end
		end))
	end
	conn(sw.MouseButton1Click:Connect(function() pal.Visible = not pal.Visible end))
	return { row = row, text = text }
end

Defs = {
	{ title = "knife", sections = {
		{ title = "knife", items = {
			{ t = "toggle", text = "kill_all", desc = "kill_all_d", key = "KillAll", cb = function(v)
				if v then task.spawn(killAll) end
			end },
			{ t = "toggle", text = "keep_kill", desc = "keep_kill_d", key = "KeepKill", cb = function(v)
				if not v then S.KillAll = false end
			end },
			{ t = "toggle", text = "auto_knife", desc = "auto_knife_d", key = "AutoKnife" },
			{ t = "toggle", text = "equip_knife", desc = "equip_knife_d", key = "EquipKnife" },
			{ t = "toggle", text = "inf_knife", desc = "inf_knife_d", key = "InfKnife" },
		} },
	} },
	{ title = "gun", sections = {
		{ title = "gun", items = {
			{ t = "toggle", text = "reload_bar", desc = "reload_bar_d", key = "ReloadBar" },
			{ t = "toggle", text = "silent", desc = "silent_d", key = "Silent" },
			{ t = "dropdown", text = "silent_part", key = "SilentPart",
				options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" } },
			{ t = "slider", text = "silent_chance", key = "SilentChance", min = 0, max = 100 },
			{ t = "slider", text = "silent_fov", key = "SilentFOV", min = 60, max = 800 },
			{ t = "toggle", text = "auto_shoot", desc = "auto_shoot_d", key = "AutoShoot" },
			{ t = "button", text = "draw_gun", desc = "draw_gun_d", cb = function() equip("gun") end },
			{ t = "button", text = "save_gun", desc = "save_gun_d", cb = function()
				local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum:UnequipTools() end
			end },
		} },
	} },
	{ title = "aim", sections = {
		{ title = "aim", items = {
			{ t = "toggle", text = "aimbot", desc = "aimbot_d", key = "Aimbot" },
			{ t = "dropdown", text = "aim_part", key = "AimPart", options = { "Head", "HumanoidRootPart", "UpperTorso" } },
			{ t = "slider", text = "aim_fov", key = "AimFOV", min = 60, max = 800 },
			{ t = "slider", text = "aim_smooth", key = "AimSmooth", min = 0, max = 1, dec = 2 },
		} },
	} },
	{ title = "hitbox", sections = {
		{ title = "hitbox", items = {
			{ t = "toggle", text = "hitbox_on", desc = "hitbox_on_d", key = "Hitbox", cb = function(v)
				if not v then
					for _, plr in ipairs(Players:GetPlayers()) do clearHitbox(plr) end
				end
			end },
			{ t = "slider", text = "hitbox_size", key = "HitboxSize", min = 5, max = 40 },
			{ t = "toggle", text = "show_hitbox", key = "ShowHitbox" },
			{ t = "slider", text = "hitbox_op", key = "HitboxOp", min = 0, max = 10, dec = 1 },
			{ t = "color", text = "hitbox_color", key = "HitboxColor" },
		} },
	} },
	{ title = "player", sections = {
		{ title = "player", items = {
			{ t = "slider", text = "walkspeed", key = "WalkSpeed", min = 16, max = 250 },
			{ t = "slider", text = "jump", key = "JumpPower", min = 50, max = 250 },
			{ t = "toggle", text = "inf_jump", key = "InfJump" },
			{ t = "toggle", text = "fly", key = "Fly" },
			{ t = "slider", text = "fly_speed", key = "FlySpeed", min = 20, max = 300 },
			{ t = "toggle", text = "antiafk", key = "AntiAFK" },
			{ t = "button", text = "reset", cb = function()
				if LP.Character then LP.Character:BreakJoints() end
			end },
		} },
	} },
	{ title = "visuals", sections = {
		{ title = "visuals", items = {
			{ t = "toggle", text = "esp", desc = "esp_d", key = "ESP", cb = function(v)
				if v then
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= LP then createESP(plr) end
					end
				else
					for plr in pairs(ESPData) do destroyESP(plr) end
				end
			end },
			{ t = "toggle", text = "esp_box", key = "ESPBox" },
			{ t = "toggle", text = "esp_name", key = "ESPName" },
			{ t = "toggle", text = "esp_dist", key = "ESPDist" },
			{ t = "toggle", text = "esp_hp", key = "ESPHP" },
			{ t = "toggle", text = "esp_tracer", key = "ESPTracer" },
			{ t = "toggle", text = "chams", key = "Chams" },
		} },
		{ title = "misc", items = {
			{ t = "toggle", text = "fullbright", key = "Fullbright", cb = applyVisuals },
			{ t = "toggle", text = "nofog", key = "NoFog", cb = applyVisuals },
		} },
	} },
	{ title = "misc", sections = {
		{ title = "misc", items = {
			{ t = "button", text = "fps", cb = function()
				pcall(function() settings().Rendering.QualityLevel = 1 end)
				Lighting.GlobalShadows = false
				notify("FPS", "Graficos al minimo")
			end },
			{ t = "button", text = "jobid", cb = function()
				pcall(function() setclipboard(game.JobId) end)
				notify("Job ID", L("copy"))
			end },
			{ t = "button", text = "rejoin", cb = function()
				game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
			end },
			{ t = "button", text = "hop", cb = function()
				local ok = pcall(function()
					local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
					local data = HttpService:JSONDecode(raw)
					for _, srv in ipairs(data.data or {}) do
						if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
							game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
							return
						end
					end
					notify("Server hop", "Sin servidores disponibles")
				end)
				if not ok then notify("Server hop", "Fallo la peticion") end
			end },
		} },
	} },
	{ title = "hub", sections = {
		{ title = "hub", items = {
			{ t = "button", text = "discord", cb = function()
				pcall(function() setclipboard(CONFIG.Discord) end)
				notify("Discord", L("copy"))
			end },
			{ t = "button", text = "reload", cb = function()
				pcall(function() getgenv().Onyx.Unload() end)
				task.wait(0.3)
				loadstring(game:HttpGet("https://raw.githubusercontent.com/abrambrito6-svg/Scrip-Navi/main/Navi.lua"))()
			end },
			{ t = "button", text = "info", cb = function()
				notify(CONFIG.Name .. " " .. CONFIG.Version, CONFIG.Sub .. " · " .. CONFIG.By)
			end },
		} },
	} },
	{ title = "settings", sections = {
		{ title = "settings", items = {
			{ t = "dropdown", text = "keybind", key = "KeybindName",
				options = { "RightShift", "LeftShift", "RightControl", "F1", "F2", "F3", "Z", "X", "V" },
				cb = function(opt) CONFIG.Keybind = Enum.KeyCode[opt] end },
			{ t = "slider", text = "scale", key = "Scale", min = 0.6, max = 1.15, dec = 2, cb = fitScale },
			{ t = "toggle", text = "bg_on", key = "Bg", cb = function(v)
				if v then
					loadBg()
				else
					BgImage.Image = ""
				end
			end },
			{ t = "toggle", text = "notif", key = "Notif" },
			{ t = "toggle", text = "fovcircle", key = "FovCircle" },
			{ t = "button", text = "unload", cb = function() getgenv().Onyx.Unload() end },
		} },
	} },
	{ title = "profiles", sections = {
		{ title = "profiles", items = {
			{ t = "button", text = "save", cb = function() saveCfg() end },
			{ t = "button", text = "load", cb = function() loadCfg() end },
			{ t = "button", text = "del", cb = function() delCfg() end },
		} },
	} },
}

local function showPage(page)
	ActivePage = page
	for _, d in ipairs(Defs) do
		if d._frame then d._frame.Visible = (d == page) end
		local b = PageBtns[d]
		if b then
			local on = d == page
			tw(b, 0.15, { BackgroundTransparency = on and 0 or 1 })
			tw(b:FindFirstChildOfClass("TextLabel"), 0.15, { TextColor3 = on and T.Text or T.Dim })
		end
	end
	Content.CanvasPosition = Vector2.zero
end

local function buildPages()
	for i, d in ipairs(Defs) do
		local btn = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = T.Card,
			BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
			LayoutOrder = i, Parent = SideList,
		}, {
			new("UICorner", { CornerRadius = UDim.new(0, 7) }),
			new("TextLabel", {
				Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0),
				BackgroundTransparency = 1, FontFace = F.Reg, TextSize = 12,
				TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left, Text = L(d.title),
			}),
			new("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(20, 14), BackgroundColor3 = T.Bg,
				BackgroundTransparency = 0.3, FontFace = F.Bold, TextSize = 9,
				TextColor3 = T.Dim, Text = tostring(#(d.sections[1] and d.sections[1].items or {})),
			}, { new("UICorner", { CornerRadius = UDim.new(0, 4) }) }),
		})
		d._btn = btn
		PageBtns[d] = btn
		conn(btn.MouseButton1Click:Connect(function() showPage(d) end))

		local frame = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y, Visible = false, Parent = Content,
		}, { new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
		d._frame = frame

		for _, sec in ipairs(d.sections) do
			local s = createSection(frame, L(sec.title))
			sec._head = s.head
			for _, it in ipairs(sec.items) do
				if it.t == "toggle" then
					it._el = createToggle(s.body, L(it.text), it.desc and L(it.desc) or nil, it.key, it.cb)
				elseif it.t == "slider" then
					it._el = createSlider(s.body, L(it.text), it.key, it.min, it.max, it.dec, it.cb)
				elseif it.t == "dropdown" then
					it._el = createDropdown(s.body, L(it.text), it.key, it.options, it.cb)
				elseif it.t == "color" then
					it._el = createColor(s.body, L(it.text), it.key, it.cb)
				elseif it.t == "button" then
					it._el = createButton(s.body, L(it.text), it.desc and L(it.desc) or nil, it.cb)
				end
			end
		end
	end
end

local function applySearch(q)
	q = q:lower()
	local firstHit
	for _, d in ipairs(Defs) do
		local anyPage = false
		for _, sec in ipairs(d.sections) do
			local anySec = false
			for _, it in ipairs(sec.items) do
				local ok = q == "" or (it._el and it._el.text:lower():find(q, 1, true) ~= nil)
				if it._el then it._el.row.Visible = ok end
				if ok then
					anySec = true
					anyPage = true
				end
			end
			if sec._head then sec._head.Visible = anySec end
		end
		if anyPage and not firstHit then firstHit = d end
	end
	if q ~= "" and firstHit then showPage(firstHit) end
end
conn(SearchBox:GetPropertyChangedSignal("Text"):Connect(function() applySearch(SearchBox.Text) end))

local LangBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -60, 0, 13),
	Size = UDim2.fromOffset(30, 26), BackgroundColor3 = T.Card, Text = "",
	BackgroundTransparency = 1, Parent = Top,
}, {
	new("UICorner", { CornerRadius = UDim.new(0, 6) }),
	new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		FontFace = F.Bold, TextSize = 10, TextColor3 = T.Dim, Text = "ES",
	}),
})
local LangList = new("Frame", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 1, 3),
	Size = UDim2.fromOffset(46, 60), BackgroundColor3 = T.Card, Visible = false,
	ZIndex = 60, Parent = LangBtn,
}, {
	new("UICorner", { CornerRadius = UDim.new(0, 6) }),
	new("UIStroke", { Color = T.Line }),
	new("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }),
	new("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3) }),
})
for _, code in ipairs({ "ES", "EN", "PT" }) do
	local ob = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 17), BackgroundTransparency = 1,
		Text = code, FontFace = F.Reg, TextSize = 10, TextColor3 = T.Dim, Parent = LangList,
	})
	conn(ob.MouseButton1Click:Connect(function()
		LangKey = code:lower()
		LangBtn:FindFirstChildOfClass("TextLabel").Text = code
		LangList.Visible = false
		SearchBox.PlaceholderText = L("search")
		Online.Text = tostring(#Players:GetPlayers()) .. " " .. L("players")
		for _, d in ipairs(Defs) do
			if d._frame then d._frame:Destroy(); d._frame = nil end
			if d._btn then d._btn:Destroy(); d._btn = nil end
			PageBtns = {}
			for _, sec in ipairs(d.sections) do
				sec._head = nil
				for _, it in ipairs(sec.items) do it._el = nil end
			end
		end
		buildPages()
		showPage(Defs[1])
	end))
end
conn(LangBtn.MouseButton1Click:Connect(function() LangList.Visible = not LangList.Visible end))

local ProfilePath = "Onyx/config.json"

saveCfg = function()
	local data = {}
	for k, v in pairs(S) do
		if type(v) == "Color3" then
			data[k] = { __c = true, v.R * 255, v.G * 255, v.B * 255 }
		elseif type(v) ~= "table" then
			data[k] = v
		end
	end
	local ok = pcall(function()
		if makefolder and isfolder and not isfolder("Onyx") then makefolder("Onyx") end
		writefile(ProfilePath, HttpService:JSONEncode(data))
	end)
	notify("Config", ok and "Guardado" or "Sin acceso a archivos")
end

loadCfg = function()
	local ok, raw = pcall(function() return readfile(ProfilePath) end)
	if not ok or not raw then
		notify("Config", "No existe")
		return
	end
	local dec = pcall(function() return HttpService:JSONDecode(raw) end)
	if not dec then
		notify("Config", "Archivo invalido")
		return
	end
	for k, v in pairs(dec) do
		if type(v) == "table" and v.__c then
			S[k] = Color3.fromRGB(v[1], v[2], v[3])
		else
			S[k] = v
		end
	end
	notify("Config", "Cargado (reabre el panel)")
end

delCfg = function()
	pcall(function() delfile(ProfilePath) end)
	notify("Config", "Borrado")
end

loadBg = function()
	if not S.Bg then return end
	task.spawn(function()
		local ok, res = pcall(function()
			local f = "onyx_bg.jpg"
			if isfile and isfile(f) then return getcustomasset(f) end
			local d = game:HttpGet(CONFIG.Background)
			writefile(f, d)
			return getcustomasset(f)
		end)
		if ok and res then
			BgImage.Image = res
			BgImage.ImageTransparency = 0.55
		end
	end)
end

local frames = 0
conn(RunService.RenderStepped:Connect(function() frames = frames + 1 end))
task.spawn(function()
	while Gui.Parent do
		local ping = 0
		pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
		Info.Text = frames .. " FPS  ·  " .. ping .. " ms"
		frames = 0
		Online.Text = tostring(#Players:GetPlayers()) .. " " .. L("players")
		task.wait(1)
	end
end)

task.spawn(function()
	while Gui.Parent do
		task.wait(45)
		if S.AntiAFK then
			pcall(function() game:GetService("VirtualUser"):CaptureController() end)
			pcall(function() game:GetService("VirtualUser"):ClickButton2(Vector2.zero) end)
		end
	end
end)

conn(RunService.RenderStepped:Connect(function()
	if not S.ReloadBar and ReloadBar.BackgroundTransparency ~= 1 then
		ReloadBar.BackgroundTransparency = 1
		ReloadFill.Size = UDim2.fromScale(1, 1)
	end
end))

conn(UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == CONFIG.Keybind then
		setPanel(not Main.Visible)
	end
end))

local function unload()
	getgenv().Onyx = nil
	for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
	for plr in pairs(ESPData) do destroyESP(plr) end
	for _, plr in ipairs(Players:GetPlayers()) do pcall(function() clearHitbox(plr) end) end
	pcall(function() FovC:Remove() end)
	pcall(function()
		Lighting.Ambient = Color3.fromRGB(70, 70, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.Brightness = 1
		Lighting.FogEnd = 1000
		Lighting.GlobalShadows = true
	end)
	if flyBV then pcall(function() flyBV:Destroy() end) end
	if flyBG then pcall(function() flyBG:Destroy() end) end
	pcall(function()
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
			hum.JumpPower = 50
		end
	end)
	pcall(function() Gui:Destroy() end)
	if oldIndex then pcall(function() hookmetamethod(game, "__index", oldIndex) end) end
end
getgenv().Onyx = { Unload = unload }

buildPages()
showPage(Defs[1])
fitScale()
applyVisuals()
loadBg()
notify(CONFIG.Name .. " " .. CONFIG.Version, CONFIG.Sub .. " · " .. CONFIG.By)
if not hookOK then
	task.delay(1, function() notify("Aviso", "Silent aim no disponible en este executor") end)
end
