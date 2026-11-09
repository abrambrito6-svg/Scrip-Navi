--[[
    NEXUS-HUB | DUELOS -- By Navi
    v6: ESP 3D tipo caja roja + Auto Shot conectado al ESP
--]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local StarterGui        = game:GetService("StarterGui")
local Stats             = game:GetService("Stats")
local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera

local BG_URL = "https://files.catbox.moe/cjy2y9.jpg"
local GUNS = {"gun", "revolver", "pistol", "blaster", "laser", "chroma", "rifle", "sniper"}

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
    -- ESP
    espBox          = false,
    espName         = false,
    espDistance     = false,
    espColor        = Color3.fromRGB(255, 45, 45),
    espRange        = 220,
    -- Auto shot
    autoShoot       = false,
    autoEquip       = true,
    shootDelay      = 0.18,
    -- Varios
    invisible       = false,
    safeMode        = true,
    bgOpacity       = 0.5,
    killRange       = 200,
    farmEvent       = false,
    farmStreak      = false,
}

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

local function getHRP(plr)
    local char = plr and plr.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function isAlive(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function distTo(plr)
    local part = getHRP(plr)
    if not part then return 9999 end
    return (Camera.CFrame.Position - part.Position).Magnitude
end

-- Solo jugadores dentro de la partida (el lobby queda fuera por distancia)
local function inRange(plr, range)
    if plr == LocalPlayer or not isAlive(plr) then return false end
    return distTo(plr) <= range
end

local function loadAsset(url, name)
    local ok, res = pcall(function()
        if not isfile(name) then writefile(name, game:HttpGet(url)) end
        return getcustomasset(name)
    end)
    if ok then return res end
end

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

local BgLayer = Instance.new("Frame")
BgLayer.Size = UDim2.fromScale(1, 1)
BgLayer.BackgroundTransparency = 1
BgLayer.ZIndex = 1
BgLayer.Parent = Main

local bgVeil
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

    bgVeil = Instance.new("Frame")
    bgVeil.Size = UDim2.fromScale(1, 1)
    bgVeil.BackgroundColor3 = Theme.bg
    bgVeil.BackgroundTransparency = Config.bgOpacity
    bgVeil.BorderSizePixel = 0
    bgVeil.ZIndex = 2
    bgVeil.Parent = BgLayer
    round(bgVeil, 12)
else
    bgVeil = Instance.new("Frame")
    bgVeil.Size = UDim2.fromScale(1, 1)
    bgVeil.BackgroundColor3 = Theme.bg
    bgVeil.BackgroundTransparency = 0.1
    bgVeil.ZIndex = 2
    bgVeil.Parent = BgLayer
end

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 38)
Top.BackgroundTransparency = 1
Top.ZIndex = 3
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Theme.text
Title.TextStrokeTransparency = 0.4
Title.ZIndex = 4
Title.Text = "Nexus-HUB | Duelos -- By Navi"
Title.Parent = Top

local Ping = Instance.new("TextLabel")
Ping.Size = UDim2.fromOffset(52, 20)
Ping.Position = UDim2.new(1, -132, 0, 9)
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
Badge.Position = UDim2.new(1, -76, 0, 9)
Badge.BackgroundColor3 = Theme.accent
Badge.BackgroundTransparency = 0.15
Badge.Font = Enum.Font.GothamBold
Badge.TextSize = 10
Badge.TextColor3 = Color3.new(1, 1, 1)
Badge.Text = "HUB"
Badge.ZIndex = 4
Badge.Parent = Top
round(Badge, 6)

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.fromOffset(22, 22)
Mini.Position = UDim2.new(1, -52, 0, 8)
Mini.BackgroundTransparency = 1
Mini.Font = Enum.Font.GothamBold
Mini.TextSize = 18
Mini.TextColor3 = Theme.accent
Mini.Text = "–"
Mini.ZIndex = 4
Mini.Parent = Top

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
Content.BackgroundTransparency = 0.62
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

local function section(page, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = Theme.accent
    l.TextStrokeTransparency = 0.5
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = string.upper(text)
    l.ZIndex = 5
    l.Parent = page
end

local function toggle(page, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Theme.bg
    row.BackgroundTransparency = 0.45
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
    row.BackgroundTransparency = 0.45
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
        label.Text = text .. ": " .. string.format("%.0f", value)
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

local function swatches(page, text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Theme.bg
    row.BackgroundTransparency = 0.45
    row.ZIndex = 4
    row.Parent = page
    round(row, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextColor3 = Theme.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.ZIndex = 5
    label.Parent = row

    local colors = {
        Color3.fromRGB(255, 45, 45),
        Color3.fromRGB(255, 110, 180),
        Color3.fromRGB(178, 120, 255),
        Color3.fromRGB(110, 220, 255),
        Color3.fromRGB(120, 255, 160),
        Color3.fromRGB(255, 210, 100),
        Color3.fromRGB(255, 255, 255),
    }

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0.6, -14, 0, 22)
    holder.Position = UDim2.new(0.4, 2, 0.5, -11)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 5
    holder.Parent = row

    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Horizontal
    list.Padding = UDim.new(0, 4)
    list.Parent = holder

    for _, col in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(20, 20)
        b.BackgroundColor3 = col
        b.Text = ""
        b.ZIndex = 6
        b.Parent = holder
        round(b, 10)
        b.MouseButton1Click:Connect(function() callback(col) end)
    end
    return row
end

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Nexus-HUB", Text = msg, Duration = 3,
        })
    end)
end

-- ==================== FIN DE LA PARTE 1 ====================

local pHome  = makePage("Inicio", "⌂")
local pVis   = makePage("Visual", "◉")
local pShot  = makePage("Auto Shot", "◎")
local pKill  = makePage("Kill All", "☠")
local pInv   = makePage("Invisible", "👻")
local pCheat = makePage("Tramposo", "⚡")
local pFarm  = makePage("Zona de farmeo", "⚙")

section(pHome, "Estado")
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 60)
status.BackgroundColor3 = Theme.bg
status.BackgroundTransparency = 0.45
status.Font = Enum.Font.GothamMedium
status.TextSize = 11
status.TextWrapped = true
status.TextColor3 = Theme.sub
status.Text = "ESP: OFF | Auto Shot: OFF | detectados: 0"
status.ZIndex = 5
status.Parent = pHome
round(status, 8)

button(pHome, "Reiniciar personaje", function()
    pcall(function() LocalPlayer.Character:BreakJoints() end)
end)
button(pHome, "Minimizar panel", function() Main.Visible = false Float.Visible = true end)

section(pVis, "ESP")
toggle(pVis, "Caja 3D en el jugador", false, function(v) Config.espBox = v end)
toggle(pVis, "Nombre arriba", false, function(v) Config.espName = v end)
toggle(pVis, "Distancia", false, function(v) Config.espDistance = v end)
swatches(pVis, "Color", function(col) Config.espColor = col end)
slider(pVis, "Rango (solo partida)", 40, 400, 220, function(v) Config.espRange = v end)

section(pShot, "Auto Shot (depende del ESP)")
toggle(pShot, "Auto Shot (dispara al del ESP)", false, function(v) Config.autoShoot = v end)
toggle(pShot, "Sacar arma de fuego sola", true, function(v) Config.autoEquip = v end)
slider(pShot, "Cadencia", 0.05, 0.8, 0.18, function(v) Config.shootDelay = v end)
button(pShot, "Sacar arma ahora", function() if equipGun then equipGun() end end)

section(pKill, "Kill All")
slider(pKill, "Rango de teletransporte", 30, 400, 200, function(v) Config.killRange = v end)
button(pKill, "Kill All (solo la partida)", function()
    if killAllOnce then killAllOnce() end
end)
button(pKill, "Volver al spawn", function()
    local hrp = getHRP(LocalPlayer)
    if hrp then
        hrp.CFrame = CFrame.new(0, 25, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end)

section(pInv, "Invisible")
toggle(pInv, "Modo invisible", false, function(v) Config.invisible = v end)

section(pCheat, "Ajustes")
slider(pCheat, "Opacidad del fondo", 0.1, 0.85, 0.5, function(v)
    Config.bgOpacity = v
    if bgVeil then bgVeil.BackgroundTransparency = v end
end)
toggle(pCheat, "Modo seguro (recomendado)", true, function(v) Config.safeMode = v end)
button(pCheat, "Apagar todo", function()
    Config.autoShoot = false
    Config.espBox = false
    Config.espName = false
    Config.espDistance = false
    Config.farmEvent = false
    Config.farmStreak = false
    Config.invisible = false
    notify("Todo apagado")
end)

section(pFarm, "Automatización")
toggle(pFarm, "Farmear evento", false, function(v) Config.farmEvent = v end)
toggle(pFarm, "Farmear racha", false, function(v) Config.farmStreak = v end)
button(pFarm, "Buscar partida (PLAY)", function()
    for _, g in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if g:IsA("TextButton") and string.upper(g.Text):find("PLAY") then
            pcall(function() g:Activate() end)
            break
        end
    end
end)

for n, p in pairs(Pages) do p.Visible = (n == "Inicio") end
tabButtons["Inicio"].BackgroundTransparency = 0.25
tabButtons["Inicio"].TextColor3 = Theme.accent

local Float = Instance.new("TextButton")
Float.Size = UDim2.fromOffset(46, 46)
Float.Position = UDim2.fromOffset(18, 120)
Float.BackgroundColor3 = Theme.bg
Float.BackgroundTransparency = 0.1
Float.Font = Enum.Font.GothamBold
Float.TextSize = 18
Float.TextColor3 = Theme.accent
Float.Text = "N"
Float.Visible = false
Float.ZIndex = 60
Float.Parent = Screen
round(Float, 999)
stroke(Float, Theme.accent, 1.6)

local fDrag, fStart, fMoved = false, nil, false
Float.MouseButton1Down:Connect(function()
    fDrag = true
    fMoved = false
    fStart = UserInputService:GetMouseLocation()
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        if fDrag and not fMoved then
            Main.Visible = true
            Float.Visible = false
        end
        fDrag = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if fDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local pos = UserInputService:GetMouseLocation()
        if fStart and (pos - fStart).Magnitude > 6 then fMoved = true end
        Float.Position = UDim2.fromOffset(pos.X - 23, pos.Y - 23)
    end
end)

Mini.MouseButton1Click:Connect(function()
    Main.Visible = false
    Float.Visible = true
end)
Close.MouseButton1Click:Connect(function() Screen:Destroy() end)

--==================== ARMAS ====================
local function getGun()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local n = tool.Name:lower()
        for _, k in ipairs(GUNS) do
            if n:find(k) then return tool end
        end
    end
end

function equipGun()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local current = getGun()
    if current then return current end
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            for _, k in ipairs(GUNS) do
                if n:find(k) then
                    pcall(function() hum:EquipTool(t) end)
                    return t
                end
            end
        end
    end
end

local function shoot()
    local gun = getGun()
    if gun then
        pcall(function() gun:Activate() end)
    else
        pcall(function() mouse1click() end)
    end
end

--==================== ESP (caja 3D) ====================
local espFolder = Instance.new("Folder")
espFolder.Name = "NexusESP"
espFolder.Parent = Camera

local espData = {}

local function clearEsp(plr)
    local d = espData[plr]
    if d then
        pcall(function() d.box:Destroy() end)
        pcall(function() d.gui:Destroy() end)
        espData[plr] = nil
    end
end

local function buildEsp(plr)
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local head = char:FindFirstChild("Head") or hrp

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Config.espColor
    box.Transparency = 0.65
    box.Size = Vector3.new(4, 5.5, 4)
    box.Parent = espFolder

    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(150, 34)
    gui.StudsOffset = Vector3.new(0, 3.6, 0)
    gui.AlwaysOnTop = true
    gui.Adornee = head
    gui.Parent = espFolder

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 18)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 13
    nameLbl.TextColor3 = Config.espColor
    nameLbl.TextStrokeTransparency = 0.15
    nameLbl.Text = plr.Name
    nameLbl.Parent = gui

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, 0, 0, 14)
    distLbl.Position = UDim2.fromOffset(0, 18)
    distLbl.BackgroundTransparency = 1
    distLbl.Font = Enum.Font.GothamMedium
    distLbl.TextSize = 11
    distLbl.TextColor3 = Config.espColor
    distLbl.TextStrokeTransparency = 0.15
    distLbl.Text = ""
    distLbl.Parent = gui

    espData[plr] = { box = box, gui = gui, name = nameLbl, dist = distLbl }
end

local function refreshEsp()
    for _, plr in ipairs(Players:GetPlayers()) do
        if inRange(plr, Config.espRange) then
            if not espData[plr] or not espData[plr].box.Parent then
                clearEsp(plr)
                buildEsp(plr)
            end
        else
            clearEsp(plr)
        end
    end
    for plr in pairs(espData) do
        if not plr.Parent then clearEsp(plr) end
    end
end

Players.PlayerRemoving:Connect(clearEsp)

-- Objetivo = el más cercano que YA está en el ESP
local function getEspTarget()
    local best, bestDist = nil, math.huge
    for plr in pairs(espData) do
        if isAlive(plr) then
            local hrp = getHRP(plr)
            if hrp then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = distTo(plr)
                    if d < bestDist then best, bestDist = plr, d end
                end
            end
        end
    end
    return best
end

local teleportLock = false
function killAllOnce()
    if teleportLock then return end
    teleportLock = true
    local hrp = getHRP(LocalPlayer)
    if not hrp then teleportLock = false return end

    if Config.autoEquip then equipGun() end
    local origin = hrp.CFrame
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and distTo(plr) <= Config.killRange then
            local target = getHRP(plr)
            if target then
                count = count + 1
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = target.CFrame * CFrame.new(0, 0, -2.5)
                waitSafe(0.2)
                shoot()
                waitSafe(0.15)
            end
        end
    end
    waitSafe(0.2)
    hrp.CFrame = origin
    hrp.AssemblyLinearVelocity = Vector3.zero
    teleportLock = false
    notify("Kill All: " .. count .. " enemigos")
end

local lastShot, espAcc = 0, 0
local farmIndex = 1
local detected = 0

RunService.RenderStepped:Connect(function(dt)
    espAcc = espAcc + dt
    if espAcc >= 0.05 then
        espAcc = 0
        local anyEsp = Config.espBox or Config.espName or Config.espDistance
        if anyEsp then
            refreshEsp()
            detected = 0
            for plr, d in pairs(espData) do
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    detected = detected + 1
                    d.box.Enabled = Config.espBox
                    d.box.Color3 = Config.espColor
                    pcall(function()
                        d.box.Size = char:GetExtentsSize() * 1.12
                    end)
                    d.gui.Enabled = Config.espName or Config.espDistance
                    d.name.Visible = Config.espName
                    d.name.TextColor3 = Config.espColor
                    d.dist.Visible = Config.espDistance
                    d.dist.Text = math.floor(distTo(plr)) .. "m"
                    d.dist.TextColor3 = Config.espColor
                end
            end
        else
            detected = 0
            for plr in pairs(espData) do clearEsp(plr) end
        end
    end

    -- Auto Shot: solo a lo que el ESP tiene marcado
    if Config.autoShoot then
        local target = getEspTarget()
        if target then
            if Config.autoEquip then equipGun() end
            local delay = Config.safeMode and Config.shootDelay * 1.4 or Config.shootDelay
            if os.clock() - lastShot >= delay then
                lastShot = os.clock()
                shoot()
            end
        end
    end
end)

task.spawn(function()
    local originals = {}
    while Screen.Parent do
        if Config.invisible then
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if (p:IsA("BasePart") and p.Name ~= "HumanoidRootPart")
                    or p:IsA("Decal") or p:IsA("Texture") then
                        if originals[p] == nil then originals[p] = p.Transparency end
                        p.Transparency = 1
                    end
                end
            end
        else
            for p, t in pairs(originals) do pcall(function() p.Transparency = t end) end
            originals = {}
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while Screen.Parent do
        task.wait(0.2)
        if (Config.farmEvent or Config.farmStreak) and not teleportLock then
            local hrp = getHRP(LocalPlayer)
            local list = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if inRange(plr, Config.killRange) then table.insert(list, plr) end
            end
            if hrp and #list > 0 then
                farmIndex = farmIndex % #list + 1
                local target = getHRP(list[farmIndex])
                if target then
                    hrp.CFrame = target.CFrame * CFrame.new(0, 0, -2.5)
                    task.wait(Config.safeMode and 0.4 or 0.25)
                    shoot()
                end
            end
        end
    end
end)

task.spawn(function()
    while Screen.Parent do
        local ok, ping = pcall(function()
            return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if ok and ping then
            Ping.Text = ping .. " ms"
            Ping.BackgroundColor3 = ping < 150 and Theme.green
                or (ping < 350 and Color3.fromRGB(240, 190, 90) or Theme.red)
        end
        status.Text = string.format("ESP: %s | Auto Shot: %s | detectados: %d",
            (Config.espBox or Config.espName or Config.espDistance) and "ON" or "OFF",
            Config.autoShoot and "ON" or "OFF",
            detected)
        task.wait(1)
    end
end)

notify("Nexus-HUB v6 cargado")
print("[Nexus-HUB] v6 cargado")