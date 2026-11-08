
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local StarterGui        = game:GetService("StarterGui")
local Stats             = game:GetService("Stats")
local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera
local Mouse             = LocalPlayer:GetMouse()

local BG_URL = "https://files.catbox.moe/cjy2y9.jpg"

local Theme = {
    bg      = Color3.fromRGB(20, 18, 32),
    panel   = Color3.fromRGB(30, 27, 48),
    stroke  = Color3.fromRGB(62, 54, 94),
    accent  = Color3.fromRGB(178, 120, 255),
    accent2 = Color3.fromRGB(255, 110, 180),
    text    = Color3.fromRGB(238, 235, 248),
    sub     = Color3.fromRGB(148, 142, 168),
    green   = Color3.fromRGB(96, 220, 140),
    red     = Color3.fromRGB(255, 92, 92),
}

local Config = {
    aimBot          = false,
    aimSmooth       = 0.25,
    aimFov          = 120,
    aimPart         = "Head",
    prediction      = 0.0,
    silentAim       = false,
    silentFov       = 150,
    showFov         = true,
    autoShoot       = false,
    shootDelay      = 0.15,
    autoEquip       = true,
    espBox          = false,
    espName         = false,
    espDistance     = false,
    espTracer       = false,
    espTeamCheck    = true,
    invisible       = false,
    safeMode        = true,
    farmEvent       = false,
    farmStreak      = false,
}

--=====================================================================
-- UTILIDADES
--=====================================================================
local function round(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

local function stroke(obj, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.stroke
    s.Thickness = thick or 1
    s.Transparency = 0.35
    s.Parent = obj
end

local function drag(frame, handle)
    local dragging, startPos, startFrame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            startFrame = frame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startPos
            frame.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + d.X,
                                       startFrame.Y.Scale, startFrame.Y.Offset + d.Y)
        end
    end)
end

local function waitSafe(base)
    task.wait(Config.safeMode and base * 2 or base)
end

local function getChar(plr)
    plr = plr or LocalPlayer
    return plr.Character
end

local function getPart(plr)
    local char = plr.Character
    if not char then return nil end
    local p = char:FindFirstChild(Config.aimPart) or char:FindFirstChild("HumanoidRootPart")
    if p and p:IsA("BasePart") then return p end
end

local function isAlive(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

-- Descarga el fondo (executor) -> asset local
local function loadAsset(url, name)
    local ok, res = pcall(function()
        if not isfile(name) then
            writefile(name, game:HttpGet(url))
        end
        return getcustomasset(name)
    end)
    if ok then return res end
end

--=====================================================================
-- GUI
--=====================================================================
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local old = parentGui:FindFirstChild("NexusHubDuels")
if old then old:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "NexusHubDuels"
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true
Screen.DisplayOrder = 999
Screen.Parent = parentGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(560, 380)
Main.Position = UDim2.new(0.5, -280, 0.5, -190)
Main.BackgroundColor3 = Theme.bg
Main.BackgroundTransparency = 0.04
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Screen
round(Main, 12)
stroke(Main, Theme.accent, 1.4)

-- Fondo con imagen
local BgLayer = Instance.new("Frame")
BgLayer.Size = UDim2.fromScale(1, 1)
BgLayer.BackgroundTransparency = 1
BgLayer.ZIndex = 1
BgLayer.Parent = Main

local bgAsset = loadAsset(BG_URL, "navi_bg.jpg")
if bgAsset then
    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.fromScale(1, 1)
    Img.BackgroundTransparency = 1
    Img.Image = bgAsset
    Img.ScaleType = Enum.ScaleType.Crop
    Img.ZIndex = 1
    Img.Parent = BgLayer
    round(Img, 12)

    local Veil = Instance.new("Frame")
    Veil.Size = UDim2.fromScale(1, 1)
    Veil.BackgroundColor3 = Theme.bg
    Veil.BackgroundTransparency = 0.32
    Veil.BorderSizePixel = 0
    Veil.ZIndex = 2
    Veil.Parent = BgLayer
    round(Veil, 12)
else
    local Veil = Instance.new("Frame")
    Veil.Size = UDim2.fromScale(1, 1)
    Veil.BackgroundColor3 = Theme.bg
    Veil.BackgroundTransparency = 0.1
    Veil.ZIndex = 2
    Veil.Parent = BgLayer
end

-- Barra superior
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 38)
Top.BackgroundTransparency = 1
Top.ZIndex = 3
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Theme.text
Title.ZIndex = 4
Title.Text = "Nexus-HUB | Duelos -- By Navi"
Title.Parent = Top

local Ping = Instance.new("TextLabel")
Ping.Size = UDim2.fromOffset(52, 20)
Ping.Position = UDim2.new(1, -102, 0, 9)
Ping.BackgroundColor3 = Theme.green
Ping.BackgroundTransparency = 0.2
Ping.Font = Enum.Font.GothamBold
Ping.TextSize = 10
Ping.TextColor3 = Color3.new(1, 1, 1)
Ping.Text = "0 ms"
Ping.ZIndex = 4
Ping.Parent = Top
round(Ping, 6)

local Badge = Instance.new("TextLabel")
Badge.Size = UDim2.fromOffset(38, 20)
Badge.Position = UDim2.new(1, -46, 0, 9)
Badge.BackgroundColor3 = Theme.accent
Badge.BackgroundTransparency = 0.15
Badge.Font = Enum.Font.GothamBold
Badge.TextSize = 10
Badge.TextColor3 = Color3.new(1, 1, 1)
Badge.Text = "HUB"
Badge.ZIndex = 4
Badge.Parent = Top
round(Badge, 6)

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(22, 22)
Close.Position = UDim2.new(1, -26, 0, 8)
Close.BackgroundTransparency = 1
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.TextColor3 = Theme.sub
Close.Text = "×"
Close.ZIndex = 4
Close.Parent = Top

drag(Main, Top)

-- Sidebar
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 132, 1, -46)
Side.Position = UDim2.fromOffset(8, 42)
Side.BackgroundTransparency = 1
Side.ZIndex = 3
Side.Parent = Main

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 3)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = Side

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -152, 1, -56)
Content.Position = UDim2.fromOffset(144, 46)
Content.BackgroundColor3 = Theme.panel
Content.BackgroundTransparency = 0.55
Content.ZIndex = 3
Content.Parent = Main
round(Content, 10)
stroke(Content)

local Pages, tabButtons = {}, {}

local function makePage(name, glyph)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.panel
    btn.BackgroundTransparency = 0.6
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = Theme.sub
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. glyph .. "  " .. name
    btn.ZIndex = 4
    btn.Parent = Side
    round(btn, 8)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 4
    page.Parent = Content

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    Pages[name] = page
    tabButtons[name] = btn
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do p.Visible = (n == name) end
        for n, b in pairs(tabButtons) do
            b.BackgroundTransparency = (n == name) and 0.25 or 0.6
            b.TextColor3 = (n == name) and Theme.accent or Theme.sub
        end
    end)
    return page
end

--=====================================================================
-- COMPONENTES
--=====================================================================
local function section(page, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = Theme.accent
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = string.upper(text)
    l.ZIndex = 5
    l.Parent = page
end

local function toggle(page, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Theme.bg
    row.BackgroundTransparency = 0.5
    row.ZIndex = 4
    row.Parent = page
    round(row, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -58, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextWrapped = true
    label.TextColor3 = Theme.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.ZIndex = 5
    label.Parent = row

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(38, 19)
    box.Position = UDim2.new(1, -48, 0.5, -9)
    box.BackgroundColor3 = Color3.fromRGB(70, 64, 92)
    box.ZIndex = 5
    box.Parent = row
    round(box, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(15, 15)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.ZIndex = 6
    knob.Parent = box
    round(knob, 10)

    local state = default or false
    local function render()
        TweenService:Create(box, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Theme.accent or Color3.fromRGB(70, 64, 92)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.fromOffset(21, 2) or UDim2.fromOffset(2, 2)
        }):Play()
    end

    local click = Instance.new("TextButton")
    click.Size = UDim2.fromScale(1, 1)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.ZIndex = 7
    click.Parent = row

    click.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then callback(state) end
    end)
    render()
    return row
end

local function slider(page, text, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Theme.bg
    row.BackgroundTransparency = 0.5
    row.ZIndex = 4
    row.Parent = page
    round(row, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.fromOffset(10, 3)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextColor3 = Theme.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text .. ": " .. tostring(default)
    label.ZIndex = 5
    label.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 5)
    bar.Position = UDim2.new(0, 10, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(58, 52, 78)
    bar.ZIndex = 5
    bar.Parent = row
    round(bar, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
    fill.BackgroundColor3 = Theme.accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 6
    fill.Parent = bar
    round(fill, 4)

    local function set(value)
        value = math.clamp(value, min, max)
        fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
        label.Text = text .. ": " .. string.format("%.2f", value)
        callback(value)
    end

    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(1, 0, 1, 0)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""
    dragBtn.ZIndex = 7
    dragBtn.Parent = bar

    local down = false
    dragBtn.MouseButton1Down:Connect(function() down = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then down = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if down and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            set(min + (max - min) * rel)
        end
    end)
    return row
end

local function dropdown(page, text, options, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Theme.bg
    row.BackgroundTransparency = 0.5
    row.ZIndex = 4
    row.Parent = page
    round(row, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextColor3 = Theme.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.ZIndex = 5
    label.Parent = row

    local current = 1
    for i, o in ipairs(options) do if o == default then current = i end end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -14, 0, 22)
    btn.Position = UDim2.new(0.5, 4, 0.5, -11)
    btn.BackgroundColor3 = Theme.panel
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextColor3 = Theme.accent
    btn.Text = options[current]
    btn.ZIndex = 6
    btn.Parent = row
    round(btn, 6)

    btn.MouseButton1Click:Connect(function()
        current = current % #options + 1
        btn.Text = options[current]
        if callback then callback(options[current]) end
    end)
    return row
end

local function button(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.accent
    btn.BackgroundTransparency = 0.2
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.ZIndex = 5
    btn.Parent = page
    round(btn, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Nexus-HUB", Text = msg, Duration = 3,
        })
    end)
end

--=====================================================================
-- PÁGINAS
--=====================================================================
local pHome  = makePage("Inicio", "⌂")
local pAim   = makePage("AimBot", "◎")
local pVis   = makePage("Visual", "◉")
local pKill  = makePage("Kill All", "☠")
local pInv   = makePage("Invisible", "👻")
local pCheat = makePage("Tramposo", "⚡")
local pFarm  = makePage("Zona de farmeo", "⚙")

section(pHome, "Estado")
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 46)
status.BackgroundColor3 = Theme.bg
status.BackgroundTransparency = 0.5
status.Font = Enum.Font.GothamMedium
status.TextSize = 11
status.TextWrapped = true
status.TextColor3 = Theme.sub
status.Text = "AimBot: OFF  |  Silent: OFF  |  ESP: OFF"
status.ZIndex = 5
status.Parent = pHome
round(status, 8)

button(pHome, "Reiniciar personaje", function()
    pcall(function() LocalPlayer.Character:BreakJoints() end)
end)
button(pHome, "Cerrar y recargar", function()
    Screen:Destroy()
end)

section(pAim, "Auto Shoot")
toggle(pAim, "Auto Shoot (disparo automático)", false, function(v) Config.autoShoot = v end)
toggle(pAim, "Equipar arma sola", true, function(v) Config.autoEquip = v end)
dropdown(pAim, "Parte del cuerpo", {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}, "Head", function(v)
    Config.aimPart = v
end)
slider(pAim, "Cadencia", 0.05, 0.6, 0.15, function(v) Config.shootDelay = v end)

section(pAim, "AimBot de cámara")
toggle(pAim, "AimBot", false, function(v) Config.aimBot = v end)
slider(pAim, "Suavizado", 0.02, 1, 0.25, function(v) Config.aimSmooth = v end)
slider(pAim, "FOV", 20, 400, 120, function(v) Config.aimFov = v end)
slider(pAim, "Predicción", 0, 0.5, 0, function(v) Config.prediction = v end)

section(pVis, "ESP")
toggle(pVis, "Resaltado (cajas)", false, function(v) Config.espBox = v end)
toggle(pVis, "Nombres", false, function(v) Config.espName = v end)
toggle(pVis, "Distancia", false, function(v) Config.espDistance = v end)
toggle(pVis, "Trazadores", false, function(v) Config.espTracer = v end)
toggle(pVis, "Ignorar mi equipo", true, function(v) Config.espTeamCheck = v end)

section(pVis, "Silent Aim + FOV")
toggle(pVis, "Silent Aim", false, function(v) Config.silentAim = v end)
toggle(pVis, "Mostrar círculo FOV", true, function(v) Config.showFov = v end)
slider(pVis, "FOV Silent", 20, 500, 150, function(v) Config.silentFov = v end)

section(pKill, "Kill All")
button(pKill, "Kill All (seguro, uno por uno)", function()
    if killAllOnce then killAllOnce() end
end)
button(pKill, "Volver al spawn", function()
    local char = getChar()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(0, 25, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end)

section(pInv, "Invisible")
toggle(pInv, "Modo invisible", false, function(v) Config.invisible = v end)

section(pCheat, "Anti-kick")
toggle(pCheat, "Modo seguro (recomendado)", true, function(v) Config.safeMode = v end)
button(pCheat, "Apagar todo", function()
    Config.autoShoot = false
    Config.aimBot = false
    Config.silentAim = false
    Config.espBox = false
    Config.espName = false
    Config.espDistance = false
    Config.espTracer = false
    Config.farmEvent = false
    Config.farmStreak = false
    Config.invisible = false
    notify("Todo apagado")
end)
button(pCheat, "Copiar mi posición", function()
    local hrp = getChar() and getChar():FindFirstChild("HumanoidRootPart")
    if hrp then
        setclipboard(tostring(hrp.CFrame))
        notify("Posición copia