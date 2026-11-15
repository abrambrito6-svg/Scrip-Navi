local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui            = game:GetService("CoreGui")
local Stats              = game:GetService("Stats")
local LP        = Players.LocalPlayer
local StartTime = os.time()

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Custom = {
    Pumpkin = {Accent="#FF7A1A", Background="#120A06", Outline="#FF9A3C", Text="#FFE9D2", Placeholder="#9A6A45", Button="#2A1409", Icon="#FFB066", Dialog="#1A0E08"},
    Witch   = {Accent="#A15BFF", Background="#0C0714", Outline="#B98AFF", Text="#EBDDFF", Placeholder="#7A5AA8", Button="#1D1030", Icon="#C9A6FF", Dialog="#120A20"},
    Blood   = {Accent="#E01E37", Background="#12060A", Outline="#FF4D63", Text="#FFD9DE", Placeholder="#A04555", Button="#2A0A12", Icon="#FF7A8A", Dialog="#1A080D"},
    Ghost   = {Accent="#3DFFB0", Background="#06120F", Outline="#7DFFD0", Text="#DDFFF2", Placeholder="#4F9A82", Button="#0B2A22", Icon="#8CFFD8", Dialog="#081A15"},
}
for name, p in pairs(Custom) do
    WindUI:AddTheme({
        Name = name,
        Accent = Color3.fromHex(p.Accent), Background = Color3.fromHex(p.Background),
        Outline = Color3.fromHex(p.Outline), Text = Color3.fromHex(p.Text),
        Placeholder = Color3.fromHex(p.Placeholder), Button = Color3.fromHex(p.Button),
        Icon = Color3.fromHex(p.Icon), Dialog = Color3.fromHex(p.Dialog),
    })
end
local ThemeList = {}
pcall(function() for name in pairs(WindUI:GetThemes()) do table.insert(ThemeList, name) end end)
if #ThemeList == 0 then ThemeList = {"Dark", "Light", "Witch"} end
table.sort(ThemeList)
local ThemeName = "Witch"

local function GetAccent()
    local t = Custom[ThemeName]
    if t then return Color3.fromHex(t.Accent) end
    return Color3.fromRGB(161, 91, 255)
end

local Strings = {
    en = {
        TAB_HOME = "Home", TAB_SILENT = "Silent", TAB_VISUALS = "Visuals", TAB_CHEATS = "Cheats", TAB_SETTINGS = "Settings",
        USER_ID = "User ID", PLACE_ID = "Place ID",
        PLAYERS = "Players", PING = "Ping",
        SILENT_AIM = "Silent Aim", AREA = "Target Area", FOV = "FOV Radius", SHOW_FOV = "Show FOV Circle",
        AREA_HEAD = "Head", AREA_TORSO = "Torso", AREA_FULL = "Full Body",
        ESP_NAME = "Name", ESP_BOX = "Box", ESP_SKELETON = "Skeleton", ESP_PLAYER = "Player ESP", ESP_MODE = "ESP Selector",
        ESP_COLOR = "ESP Color",
        MODE_HIGHLIGHT = "Highlight", MODE_FILL = "Fill", MODE_OUTLINE = "Outline",
        CH_SPEED = "Speed", CH_JUMP = "Infinite Jump",
        THEME = "Interface Color", LANGUAGE = "Language",
    },
    es = {
        TAB_HOME = "Inicio", TAB_SILENT = "Silent", TAB_VISUALS = "Visuales", TAB_CHEATS = "Cheats", TAB_SETTINGS = "Configuración",
        USER_ID = "ID de usuario", PLACE_ID = "Place ID",
        PLAYERS = "Jugadores", PING = "Ping",
        SILENT_AIM = "Silent Aim", AREA = "Zona objetivo", FOV = "Radio del FOV", SHOW_FOV = "Mostrar círculo FOV",
        AREA_HEAD = "Cabeza", AREA_TORSO = "Torso", AREA_FULL = "Cuerpo completo",
        ESP_NAME = "Nombre", ESP_BOX = "Cuadrado", ESP_SKELETON = "Esqueleto", ESP_PLAYER = "ESP al jugador", ESP_MODE = "Selector de ESP",
        ESP_COLOR = "Color del ESP",
        MODE_HIGHLIGHT = "Resaltado", MODE_FILL = "Relleno", MODE_OUTLINE = "Contorno",
        CH_SPEED = "Velocidad", CH_JUMP = "Salto infinito",
        THEME = "Color de la interfaz", LANGUAGE = "Idioma",
    },
}
local Lang = "en"
local function T(k) return (Strings[Lang] and Strings[Lang][k]) or Strings.en[k] or k end

local LocOK = pcall(function()
    WindUI:Localization({
        Enabled = true, Prefix = "loc:", DefaultLanguage = "en",
        Translations = {en = Strings.en, es = Strings.es},
    })
end) and typeof(WindUI.SetLanguage) == "function"

local function L(k) return LocOK and ("loc:" .. k) or T(k) end
local function Opt(v)
    if type(v) == "table" then return v.Title or v.Name or v[1] end
    return v
end
local function Names(strKeys)
    local t = {}
    for i, k in ipairs(strKeys) do t[i] = T(k) end
    return t
end
local function KeyFromName(name, strKeys, keys)
    for i, k in ipairs(strKeys) do
        if name == Strings.en[k] or name == Strings.es[k] then return keys[i] end
    end
end

local ModeKeys = {"Highlight", "Fill", "Outline"}
local ModeStr  = {"MODE_HIGHLIGHT", "MODE_FILL", "MODE_OUTLINE"}
local AreaKeys = {"Head", "Torso", "Full"}
local AreaStr  = {"AREA_HEAD", "AREA_TORSO", "AREA_FULL"}

local HAS_DRAWING = Drawing ~= nil and Drawing.new ~= nil
local Unloaded = false

local function getParent()
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and ui then return ui end
    if pcall(function() return CoreGui.Name end) then return CoreGui end
    return LP:WaitForChild("PlayerGui")
end
local Holder = Instance.new("Folder")
Holder.Name = "UniversalESP"
Holder.Parent = getParent()

local function newDraw(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props or {}) do d[k] = v end
    return d
end

local function IsEnemy(plr)
    if plr == LP then return false end
    local myTeam, theirTeam = LP.Team, plr.Team
    if myTeam and theirTeam then
        if myTeam == theirTeam then return false end
        if LP.TeamColor == plr.TeamColor then return false end
        if myTeam.Color == theirTeam.Color then return false end
        if myTeam.TeamColor == theirTeam.TeamColor then return false end
        return true
    end
    return true
end

local function Notify() end

local Silent = {Enabled = false, FOV = 250, Area = "Full", Target = nil, CamPos = Vector3.zero, RootPos = Vector3.zero}
local ShowFOV = false
local ESP    = {Name = false, Box = false, Skeleton = false, Player = false, Mode = "Highlight", Color = Color3.fromRGB(161, 91, 255)}
local Cheat  = {Speed = 0, Jump = 0}

local FOVCircle
if HAS_DRAWING then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness    = 2
    FOVCircle.NumSides     = 72
    FOVCircle.Radius       = Silent.FOV
    FOVCircle.Filled       = false
    FOVCircle.Color        = GetAccent()
    FOVCircle.Transparency = 0.55
    FOVCircle.Visible      = false
end

local AimService = {}
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
RayParams.IgnoreWater = true
pcall(function() RayParams.RespectCanCollide = true end)

local function Candidates(char, area)
    if area == "Head" then
        local p = char:FindFirstChild("Head")
        return p and {p} or {}
    elseif area == "Torso" then
        local list = {}
        for _, n in ipairs({"UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"}) do
            local p = char:FindFirstChild(n)
            if p then table.insert(list, p) end
        end
        return list
    else
        local list = {}
        local head = char:FindFirstChild("Head")
        if head then table.insert(list, head) end
        for _, n in ipairs({"UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"}) do
            local p = char:FindFirstChild(n)
            if p then table.insert(list, p) end
        end
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and not table.find(list, p) then
                table.insert(list, p)
            end
        end
        return list
    end
end

local function IsVisible(part, char, camPos)
    local res = workspace:Raycast(camPos, part.Position - camPos, RayParams)
    return res == nil or res.Instance:IsDescendantOf(char)
end

function AimService.GetTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local camPos = cam.CFrame.Position
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    RayParams.FilterDescendantsInstances = {LP.Character}

    local best, bestDist = nil, Silent.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsEnemy(plr) then
            local char = plr.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local rp, onRoot = cam:WorldToViewportPoint(root.Position)
                if onRoot and (Vector2.new(rp.X, rp.Y) - center).Magnitude <= Silent.FOV + 150 then
                    for _, part in ipairs(Candidates(char, Silent.Area)) do
                        local sp, on = cam:WorldToViewportPoint(part.Position)
                        if on and IsVisible(part, char, camPos) then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < bestDist then
                                best, bestDist = part, d
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function NearPlayer(origin)
    return (origin - Silent.CamPos).Magnitude <= 40 or (origin - Silent.RootPos).Magnitude <= 40
end

local function AimPoint(target, origin, dirMag)
    local pos = target.Position
    local vel = target.AssemblyLinearVelocity
    if vel and vel.Magnitude > 8 then
        local dist = (pos - origin).Magnitude
        local t = math.clamp(dist / math.max(dirMag, 1) * 0.02, 0, 0.12)
        pos = pos + vel * t
    end
    return pos
end

local RayMethods = {
    FindPartOnRay = true,
    FindPartOnRayWithIgnoreList = true,
    FindPartOnRayWithWhitelist = true,
}

local Hooked = false
pcall(function()
    if hookmetamethod and newcclosure and checkcaller and getnamecallmethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local target = Silent.Target
            if Silent.Enabled and target and target.Parent and self == workspace and not checkcaller() then
                local method = getnamecallmethod()
                if method == "Raycast" then
                    local args = table.pack(...)
                    local origin, dir = args[1], args[2]
                    if typeof(origin) == "Vector3" and typeof(dir) == "Vector3"
                        and dir.Magnitude >= 30 and NearPlayer(origin) then
                        local aim = AimPoint(target, origin, dir.Magnitude)
                        args[2] = (aim - origin).Unit * dir.Magnitude
                        return oldNamecall(self, table.unpack(args, 1, args.n))
                    end
                elseif RayMethods[method] then
                    local args = table.pack(...)
                    local ray = args[1]
                    if typeof(ray) == "Ray" and ray.Direction.Magnitude >= 30 and NearPlayer(ray.Origin) then
                        local aim = AimPoint(target, ray.Origin, ray.Direction.Magnitude)
                        args[1] = Ray.new(ray.Origin, (aim - ray.Origin).Unit * ray.Direction.Magnitude)
                        return oldNamecall(self, table.unpack(args, 1, args.n))
                    end
                end
            end
            return oldNamecall(self, ...)
        end))
        Hooked = true
    end
end)

local R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},
}
local ESPCache = {}

local function getEntry(plr)
    local e = ESPCache[plr]
    if not e then
        e = {Lines = {}}
        if HAS_DRAWING then
            e.Box  = newDraw("Square", {Thickness = 1, Filled = false, Visible = false})
            e.Name = newDraw("Text", {Size = 13, Center = true, Outline = true, Visible = false})
        end
        ESPCache[plr] = e
    end
    return e
end
local function hideDrawings(e)
    if e.Box then e.Box.Visible = false end
    if e.Name then e.Name.Visible = false end
    for _, l in ipairs(e.Lines) do l.Visible = false end
end
local function removeEntry(plr)
    local e = ESPCache[plr]
    if not e then return end
    pcall(function()
        if e.Box then e.Box:Remove() end
        if e.Name then e.Name:Remove() end
        for _, l in ipairs(e.Lines) do l:Remove() end
        if e.HL then e.HL:Destroy() end
    end)
    ESPCache[plr] = nil
end

local function updatePlayer(plr)
    local e = getEntry(plr)
    local char = plr.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp and hum.Health > 0 and IsEnemy(plr)) then
        hideDrawings(e)
        if e.HL then e.HL.Enabled = false end
        return
    end
    local color = ESP.Color
    if ESP.Player then
        if not e.HL then
            e.HL = Instance.new("Highlight")
            e.HL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            e.HL.Parent = Holder
        end
        e.HL.Adornee = char
        e.HL.Enabled = true
        e.HL.FillColor = color
        e.HL.OutlineColor = color
        if ESP.Mode == "Fill" then
            e.HL.FillTransparency, e.HL.OutlineTransparency = 0.35, 1
        elseif ESP.Mode == "Outline" then
            e.HL.FillTransparency, e.HL.OutlineTransparency = 1, 0
        else
            e.HL.FillTransparency, e.HL.OutlineTransparency = 0.5, 0
        end
    elseif e.HL then
        e.HL.Enabled = false
    end
    if not HAS_DRAWING then return end
    local cam = workspace.CurrentCamera
    local pos, on = cam:WorldToViewportPoint(hrp.Position)
    if not on then hideDrawings(e) return end
    local top = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
    local bot = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
    local h = math.abs(bot.Y - top.Y)
    local w = h * 0.6
    if ESP.Box then
        e.Box.Size = Vector2.new(w, h)
        e.Box.Position = Vector2.new(pos.X - w / 2, top.Y)
        e.Box.Color = color
        e.Box.Visible = true
    else e.Box.Visible = false end
    if ESP.Name then
        e.Name.Text = plr.DisplayName
        e.Name.Position = Vector2.new(pos.X, top.Y - 16)
        e.Name.Color = color
        e.Name.Visible = true
    else e.Name.Visible = false end
    if ESP.Skeleton then
        local list = (hum.RigType == Enum.HumanoidRigType.R15) and R15 or R6
        for i, pair in ipairs(list) do
            local line = e.Lines[i]
            if not line then
                line = newDraw("Line", {Thickness = 1, Visible = false})
                e.Lines[i] = line
            end
            local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
            if a and b then
                local pa = cam:WorldToViewportPoint(a.Position)
                local pb = cam:WorldToViewportPoint(b.Position)
                if pa.Z > 0 and pb.Z > 0 then
                    line.From = Vector2.new(pa.X, pa.Y)
                    line.To   = Vector2.new(pb.X, pb.Y)
                    line.Color = color
                    line.Visible = true
                else line.Visible = false end
            else line.Visible = false end
        end
        for i = #list + 1, #e.Lines do e.Lines[i].Visible = false end
    else
        for _, l in ipairs(e.Lines) do l.Visible = false end
    end
end

Players.PlayerRemoving:Connect(removeEntry)

local RenderLoop = RunService.RenderStepped:Connect(function()
    if Unloaded then return end
    local cam = workspace.CurrentCamera
    if cam then Silent.CamPos = cam.CFrame.Position end
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    Silent.RootPos = myRoot and myRoot.Position or Silent.CamPos

    Silent.Target = Silent.Enabled and AimService.GetTarget() or nil

    if FOVCircle then
        FOVCircle.Visible = ShowFOV and cam ~= nil
        if FOVCircle.Visible then
            local vp = cam.ViewportSize
            FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
            FOVCircle.Radius   = Silent.FOV
            FOVCircle.Color    = GetAccent()
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then updatePlayer(plr) end
    end
end)

local CheatLoop = RunService.Heartbeat:Connect(function(dt)
    if Unloaded then return end
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) or hum.Health <= 0 then return end
    if Cheat.Speed > 0 and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + hum.MoveDirection * (Cheat.Speed * dt)
    end
    if Cheat.Jump > 0 and hum.FloorMaterial == Enum.Material.Air then
        local holding = (not UserInputService:GetFocusedTextBox() and UserInputService:IsKeyDown(Enum.KeyCode.Space)) or hum.Jump
        if holding then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            hrp.CFrame = hrp.CFrame + Vector3.new(0, Cheat.Jump * dt, 0)
        end
    end
end)

local AvatarImg = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
local GameName = "Unknown"
local GameIcon = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info.Name then GameName = info.Name end
    if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
        GameIcon = "rbxassetid://" .. info.IconImageAssetId
    end
end)

local function GetPing()
    local v = 0
    pcall(function()
        v = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return v
end

local function UserDesc()
    return T("USER_ID") .. ": " .. LP.UserId
end

local function GameDesc()
    local count = #Players:GetPlayers()
    local max   = Players.MaxPlayers
    return T("PLACE_ID") .. ": " .. game.PlaceId
        .. "\n" .. T("PLAYERS") .. ": " .. count .. "/" .. max
        .. "\n" .. T("PING") .. ": " .. GetPing() .. " ms"
end

local function ManualTranslate(old, new)
    local root = WindUI.ScreenGui or getParent():FindFirstChild("WindUI")
    if not root then return end
    local map = {}
    for k, v in pairs(Strings[old]) do map[v] = Strings[new][k] end
    for _, d in ipairs(root:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton")) and map[d.Text] then
            d.Text = map[d.Text]
        end
    end
end

local Window = WindUI:CreateWindow({
    Title = "Universal",
    Icon = "globe",
    Folder = "UniversalHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = false,
    Theme = ThemeName,
    SideBarWidth = 180,
    HasOutline = true,
})

local function UpdateOpenButton()
    local accent = GetAccent()
    pcall(function()
        Window:EditOpenButton({
            Title = "Open HUB",
            Icon = "flame",
            CornerRadius = UDim.new(0, 14),
            StrokeThickness = 2,
            Color = ColorSequence.new(accent, accent:Lerp(Color3.new(0, 0, 0), 0.35)),
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Scale = 0.85,
        })
    end)
end
UpdateOpenButton()

local UserCard, GameCard, ModeDrop, AreaDrop

local function RefreshDropdown(drop, strKeys, keys, current)
    local names = Names(strKeys)
    pcall(function() drop:Refresh(names) end)
    pcall(function() drop:Select(names[table.find(keys, current) or 1]) end)
end

local function RefreshDynamic()
    pcall(function() UserCard:SetDesc(UserDesc()) end)
    pcall(function() GameCard:SetDesc(GameDesc()) end)
    RefreshDropdown(ModeDrop, ModeStr, ModeKeys, ESP.Mode)
    RefreshDropdown(AreaDrop, AreaStr, AreaKeys, Silent.Area)
end

local Home = Window:Tab({Title = L("TAB_HOME"), Icon = "house"})
UserCard = Home:Paragraph({
    Title = LP.DisplayName,
    Desc = UserDesc(),
    Image = AvatarImg,
    ImageSize = 56,
})
GameCard = Home:Paragraph({
    Title = GameName,
    Desc = GameDesc(),
    Image = GameIcon,
    ImageSize = 56,
})

local SilentTab = Window:Tab({Title = L("TAB_SILENT"), Icon = "crosshair"})
SilentTab:Toggle({Title = L("SILENT_AIM"), Value = false, Callback = function(v)
    Silent.Enabled = v
end})
AreaDrop = SilentTab:Dropdown({
    Title = L("AREA"),
    Values = Names(AreaStr),
    Value = Names(AreaStr)[3],
    Callback = function(v)
        local key = KeyFromName(Opt(v), AreaStr, AreaKeys)
        if key then Silent.Area = key end
    end,
})
SilentTab:Slider({
    Title = L("FOV"), Step = 1,
    Value = {Min = 50, Max = 267, Default = Silent.FOV},
    Callback = function(v) Silent.FOV = v end,
})
SilentTab:Toggle({Title = L("SHOW_FOV"), Value = false, Callback = function(v)
    ShowFOV = v
    if FOVCircle and not v then FOVCircle.Visible = false end
end})

local Vis = Window:Tab({Title = L("TAB_VISUALS"), Icon = "eye"})
Vis:Toggle({Title = L("ESP_NAME"), Value = false, Callback = function(v) ESP.Name = v end})
Vis:Toggle({Title = L("ESP_BOX"), Value = false, Callback = function(v) ESP.Box = v end})
Vis:Toggle({Title = L("ESP_SKELETON"), Value = false, Callback = function(v) ESP.Skeleton = v end})
Vis:Toggle({Title = L("ESP_PLAYER"), Value = false, Callback = function(v) ESP.Player = v end})
ModeDrop = Vis:Dropdown({
    Title = L("ESP_MODE"),
    Values = Names(ModeStr),
    Value = Names(ModeStr)[1],
    Callback = function(v)
        local key = KeyFromName(Opt(v), ModeStr, ModeKeys)
        if key then ESP.Mode = key end
    end,
})
Vis:Colorpicker({
    Title = L("ESP_COLOR"),
    Default = ESP.Color,
    Transparency = 0,
    Callback = function(c)
        if typeof(c) == "Color3" then ESP.Color = c end
    end,
})

local Cheats = Window:Tab({Title = L("TAB_CHEATS"), Icon = "zap"})
Cheats:Slider({Title = L("CH_SPEED"), Step = 1, Value = {Min = 0, Max = 50, Default = 0}, Callback = function(v) Cheat.Speed = v end})
Cheats:Slider({Title = L("CH_JUMP"), Step = 1, Value = {Min = 0, Max = 50, Default = 0}, Callback = function(v) Cheat.Jump = v end})

local Set = Window:Tab({Title = L("TAB_SETTINGS"), Icon = "settings"})
Set:Dropdown({
    Title = L("THEME"), Values = ThemeList, Value = ThemeName,
    Callback = function(v)
        v = Opt(v)
        if v == ThemeName then return end
        ThemeName = v
        WindUI:SetTheme(v)
        UpdateOpenButton()
        if FOVCircle then FOVCircle.Color = GetAccent() end
    end,
})
Set:Dropdown({
    Title = L("LANGUAGE"), Values = {"English", "Español"}, Value = "English",
    Callback = function(v)
        local code = (Opt(v) == "English") and "en" or "es"
        if code == Lang then return end
        local old = Lang
        Lang = code
        if LocOK then
            pcall(function() WindUI:SetLanguage(code) end)
        else
            ManualTranslate(old, code)
        end
        RefreshDynamic()
    end,
})

Window:SelectTab(1)

task.spawn(function()
    while not Unloaded do
        pcall(function() GameCard:SetDesc(GameDesc()) end)
        task.wait(1)
    end
end)

pcall(function()
    Window:OnDestroy(function()
        Unloaded = true
        Silent.Enabled, Silent.Target = false, nil
        ShowFOV = false
        Cheat.Speed, Cheat.Jump = 0, 0
        pcall(function() RenderLoop:Disconnect() end)
        pcall(function() CheatLoop:Disconnect() end)
        if FOVCircle then pcall(function() FOVCircle:Remove() end) end
        for plr in pairs(ESPCache) do removeEntry(plr) end
        pcall(function() Holder:Destroy() end)
    end)
end)