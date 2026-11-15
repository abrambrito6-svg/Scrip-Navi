
local _version = "1.6.66"
local  EL01ROXHUB_UI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))()
local  EL01ROXHUB =
EL01ROXHUB_UI:CreateWindow({
    Title = "01ROXHUB | DUELS <font color='#FFD700'>[BETA]</font>",
    Author = "BY 01ROXHUB MATI HUB",
    Folder = "01ROXHUB",
    Acrylic = false,
    Transparent = false,
    NewElements = true,
    HideSearchBar = false,
    Background = "rbxassetid://87524321260822",
    BackgroundImageTransparency = 0.55,
    OpenButton = {
        Title = "OPEN 01ROXHUB",
        Icon = "swords",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 1.1,
        Enabled = true,
        Draggable = true,
        Scale = 0.9,
        Color = ColorSequence.new(Color3.fromRGB(20, 20, 20), Color3.fromRGB(0, 0, 0))
    },
    Topbar = { Height = 44, ButtonsType = "Default" }
})
EL01ROXHUB:SetSize(UDim2.fromOffset(580, 460))
EL01ROXHUB_UI:SetTheme("Dark")
task.spawn(function()
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local bgIds = {"rbxassetid://136946652149245", "rbxassetid://94536127566353", "rbxassetid://81982829204229", "rbxassetid://103770971295555"}
    local bgImage = nil
    for i = 1, 60 do
        for _,v in ipairs(CoreGui:GetDescendants()) do
            if v:IsA("ImageLabel") and v.Size.X.Scale > 0.5 and string.find(v.Image, "87524321260822") then
                bgImage = v
                break
            end
        end
        if bgImage then break end
        task.wait(0.2)
    end
    if not bgImage then return end
    bgImage.Image = bgIds[1]
    bgImage.ImageTransparency = 0.55
    local index = 1
    while true do
        task.wait(5)
        index = index % #bgIds + 1
        local tweenOut = TweenService:Create(bgImage, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        bgImage.Image = bgIds[index]
        local tweenIn = TweenService:Create(bgImage, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 0.55})
        tweenIn:Play()
    end
end)
local Home = EL01ROXHUB:Tab({ Title = "HOME", Icon = "house" })
local Aimbot = EL01ROXHUB:Tab({ Title = "AIMBOT", Icon = "crosshair" })
local Visuales = EL01ROXHUB:Tab({ Title = "VISUALES", Icon = "eye" })
local Movimiento = EL01ROXHUB:Tab({ Title = "MOVIMIENTO", Icon = "person-standing" })
local Animaciones = EL01ROXHUB:Tab({ Title = "ANIMACIONES", Icon = "footprints" })
local AutoFarm = EL01ROXHUB:Tab({ Title = "ALTO FARM", Icon = "coins" })
local AutoKills = EL01ROXHUB:Tab({ Title = "ALTO KILLS", Icon = "skull" })
local Settings = EL01ROXHUB:Tab({ Title = 
"SETTINGS", Icon = "settings" })
Settings:Section({ Title = "SETTINGS", Icon = "settings" })
local reviewText = ""
Settings:Input({
    Title = "ESCRIBE TU COMENTARIO",
    Value = "",
    Placeholder = "Escribe aquí...",
    Callback = function(text) reviewText = text end
})
Settings:Button({
    Title = "ENVIAR COMENTARIO",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local webhookUrl = "https://discord.com/api/webhooks/1570289852589805758/Kirv7QFS1IulSNGCBdrFx99IvyZ1eJt-aQ_3zqaNd_dlCUk0AI50fkUmaXfq93SH_vj7"
        local data = { username = "01ROXHUB", embeds = {{ title = "NUEVO COMENTARIO", description = reviewText, fields = {{name="USER", value=game.Players.LocalPlayer.Name}} }} }
        local req = request or http_request or (syn and syn.request)
        if req then req({ Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data) }) end
    end
})

Settings:Section({ Title = "RENDIMIENTO", Icon = "zap" })

local lowGraphicsCache = {}
Settings:Toggle({
    Title = "FPS BOOST",
    Icon = "flame",
    Default = false,
    Callback = function(v)
        local Lighting = game:GetService("Lighting")
        if v then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1000000
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                    if not lowGraphicsCache[obj] then lowGraphicsCache[obj] = obj.Material end
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end
        else
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
            for obj, mat in pairs(lowGraphicsCache) do
                if obj and obj.Parent then obj.Material = mat obj.CastShadow = true end
            end
            lowGraphicsCache = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = true end
                if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 0 end
            end
        end
    end
})

Settings:Toggle({
    Title = "ANTI LAG",
    Icon = "wind",
    Default = false,
    Callback = function(v)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Explosion") then
                obj.Enabled = not v
            end
        end
    end
})

local antiAfkConn = nil
Settings:Toggle({
    Title = "ANTI AFK",
    Icon = "clock",
    Default = false,
    Callback = function(v)
        if v then
            if getconnections then
                for _,c in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
                    c:Disable()
                end
            end
            antiAfkConn = game.Players.LocalPlayer.Idled:Connect(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(math.random(1,100), math.random(1,100)))
            end)
        else
            if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
            if getconnections then
                for _,c in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
                    c:Enable()
                end
            end
        end
    end
})

local stretchConn = nil
Settings:Toggle({
    Title = "STRETCHED",
    Icon = "maximize",
    Default = false,
    Callback = function(Value)
        local cam = workspace.CurrentCamera
        if Value then
            stretchConn = game:GetService("RunService").RenderStepped:Connect(function()
                if cam then
                    cam.CFrame = cam.CFrame * CFrame.new(0,0,0, 1.35,0,0, 0,1,0, 0,0,1)
                end
            end)
        else
            if stretchConn then
                stretchConn:Disconnect()
                stretchConn = nil
            end
        end
    end
})
local telaFFConn = nil
local telaFFOn = false
local telaForce = 1.4

Settings:Toggle({
    Title = "MOVIMIENTO TELA",
    Icon = "activity",
    Default = false,
    Callback = function(Value)
        telaFFOn = Value
        local LP = game.Players.LocalPlayer
        local RS = game:GetService("RunService")
        local TS = 0
        if Value then
            telaFFConn = RS.RenderStepped:Connect(function(dt)
                if not telaFFOn then return end
                local char = LP.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end
                if hum.MoveDirection.Magnitude > 0 then
                    TS += dt * 38
                    local side = math.sin(TS) * telaForce
                    hrp.CFrame = hrp.CFrame * CFrame.new(side * 0.85, 0, 0)
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.28)
                end
            end)
        else
            if telaFFConn then telaFFConn:Disconnect() telaFFConn = nil end
        end
    end
})

Settings:Slider({
    Title = "FUERZA ZIGZAG",
    Icon = "move",
    Value = { Min = 0.2, Max = 3, Default = 1.4 },
    Callback = function(v) telaForce = v end

})

local telaLejosConn = nil
local telaLejosOn = false
local lejosForce = 2.2

Settings:Toggle({
    Title = "GOD MODE",
    Icon = "zap",
    Default = false,
    Callback = function(Value)
        telaLejosOn = Value
        local LP = game.Players.LocalPlayer
        local RS = game:GetService("RunService")
        local TS = 0
        if Value then
            telaLejosConn = RS.RenderStepped:Connect(function(dt)
                if not telaLejosOn then return end
                local char = LP.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end
                if hum.MoveDirection.Magnitude > 0 then
                    TS += dt * 55
                    local side = math.sin(TS) * lejosForce
                    local up = math.cos(TS * 1.2) * (lejosForce * 0.6)
                    local front = math.sin(TS * 0.7) * (lejosForce * 0.5)
                    hrp.CFrame = hrp.CFrame * CFrame.new(side * 1.2, up * 0.7, front * 0.5)
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.32)
                end
            end)
        else
            if telaLejosConn then telaLejosConn:Disconnect() telaLejosConn = nil end
        end
    end
})

Settings:Slider({
    Title = "GOD MODE DISTANCIA",
    Icon = "move",
    Value = { Min = 0.5, Max = 4, Default = 2.2 },
    Callback = function(v) lejosForce = v end

})

local spinConn = nil
local spinOn = false
local spinSpeed = 30

Settings:Toggle({
    Title = "SPIN",
    Icon = "refresh-cw",
    Default = false,
    Callback = function(Value)
        spinOn = Value
        local LP = game.Players.LocalPlayer
        local RS = game:GetService("RunService")
        if Value then
            spinConn = RS.RenderStepped:Connect(function(dt)
                if not spinOn then return end
                local char = LP.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end)
        else
            if spinConn then spinConn:Disconnect() spinConn = nil end
        end
    end
})

Settings:Slider({
    Title = "VELOCIDAD SPIN",
    Icon = "zap",
    Value = { Min = 5, Max = 100, Default = 30 },
    Callback = function(v) spinSpeed = v end

})

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local Teams = game:GetService("Teams")
    local LocalPlayer = Players.LocalPlayer
    local ringModel = nil
    local segmentParts = {}
    local highlightMap = {}
    local updateConn = nil
    local playerLastTeleported = {}
    local _lastTeleportTime = 0
    local teleportCooldown = 0.001
    local ultraRadius = 20
    local ultraActive = false

    local function isLobby()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return true end
        if LocalPlayer.Team and LocalPlayer.Team.Name:lower():find("lobby") then return true end
        return false
    end
    local function isTeammate(pl)
        if Teams and LocalPlayer.Team and pl.Team then
            if pl.Team == LocalPlayer.Team then return true end
        end
        return false
    end
    local function proAfterImage()
        local char = LocalPlayer.Character
        if not char then return end
        for i=1,3 do
            task.spawn(function()
                local clone = char:Clone()
                clone.Parent = Workspace
                for _,v in pairs(clone:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Anchored = true
                        v.CanCollide = false
                        if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
                        v.Material = Enum.Material.Neon
                        v.Color = i==1 and Color3.fromRGB(0,220,255) or Color3.fromRGB(255,255,255)
                        TweenService:Create(v, TweenInfo.new(0.6), {Transparency = 1}):Play()
                    end
                end
                game.Debris:AddItem(clone, 0.7)
            end)
            task.wait(0.06)
        end
    end
    local function isPositionClear(fromPos, toPos, ignoreList)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = ignoreList or {}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        if Workspace:Raycast(fromPos, (toPos-fromPos).Unit * (toPos-fromPos).Magnitude, params) then return false end
        local down = Workspace:Raycast(toPos + Vector3.new(0,5,0), Vector3.new(0,-50,0), params)
        if not down or not down.Instance.CanCollide then return false end
        return true
    end
    local function findSafeTeleport(myPos, intrPos, baseOffset, ignoreList)
        local dir = Vector3.new(myPos.X-intrPos.X,0,myPos.Z-intrPos.Z)
        if dir.Magnitude < 0.001 then dir = Vector3.new(1,0,0) else dir = dir.Unit end
        local left = Vector3.new(-dir.Z,0,dir.X)
        local right = Vector3.new(dir.Z,0,-dir.X)
        local cands = {myPos + left*baseOffset, myPos + right*baseOffset}
        for _,cand in ipairs(cands) do
            if isPositionClear(myPos+Vector3.new(0,2,0), Vector3.new(cand.X,myPos.Y,cand.Z)+Vector3.new(0,2,0), ignoreList) then
                return Vector3.new(cand.X,myPos.Y,cand.Z)
            end
        end
        return nil
    end
    local function ClearUltra()
        if updateConn then updateConn:Disconnect() updateConn = nil end
        if ringModel then ringModel:Destroy() ringModel = nil end
        segmentParts = {}
        for _,hl in pairs(highlightMap) do if hl.Parent then hl:Destroy() end end
        highlightMap = {}
        ultraActive = false
    end
    local function StartUltraInstinct(radius)
        ClearUltra()
        ultraActive = true
        ultraRadius = radius
        local char = LocalPlayer.Character
        if not char or not char.PrimaryPart then return end
        ringModel = Instance.new("Model")
        ringModel.Name = "UltraInstinctRing"
        ringModel.Parent = Workspace
        
        local SEGMENTS = 36
        for i=1,SEGMENTS do
            local angle = (i-1)*(2*math.pi/SEGMENTS)

            local seg = Instance.new("Part")
            seg.Anchored = true
            seg.CanCollide = false
            seg.Size = Vector3.new(0.15, 0.12, 1.1) -- CORTA
            seg.Material = Enum.Material.Neon
            seg.Color = Color3.fromRGB(0, 230, 255)
            seg.Transparency = 0.05
            seg.Parent = ringModel
            
            local light = Instance.new("PointLight")
            light.Color = Color3.fromRGB(0,200,255)
            light.Range = 3
            light.Brightness = 2
            light.Shadows = false
            light.Parent = seg

            local pos = char.PrimaryPart.Position + Vector3.new(math.cos(angle)*radius, 0.08, math.sin(angle)*radius)
            seg.CFrame = CFrame.new(pos) * CFrame.Angles(0, -angle, 0)
            
            if i % 2 == 0 then
                local segInner = Instance.new("Part")
                segInner.Anchored = true
                segInner.CanCollide = false
                segInner.Size = Vector3.new(0.1, 0.08, 0.6)
                segInner.Material = Enum.Material.Neon
                segInner.Color = Color3.fromRGB(255,255,255)
                segInner.Transparency = 0.15
                segInner.Parent = ringModel
                local pos2 = char.PrimaryPart.Position + Vector3.new(math.cos(angle)*(radius-0.5), 0.08, math.sin(angle)*(radius-0.5))
                segInner.CFrame = CFrame.new(pos2) * CFrame.Angles(0, -angle, 0)
                table.insert(segmentParts, segInner)
            end
            
            table.insert(segmentParts, seg)
        end

        updateConn = RunService.RenderStepped:Connect(function()
            if isLobby() then return end
            if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
            local centerPos = LocalPlayer.Character.PrimaryPart.Position
            
            local spin = tick() * 0.8
            for idx,seg in ipairs(segmentParts) do
                if seg and seg.Parent then
                    local baseIndex = math.ceil(idx/1.5)
                    local isInner = seg.Size.Z < 0.7
                    local r = isInner and ultraRadius-0.5 or ultraRadius
                    local angle = ((idx-1)*(2*math.pi/36)) + (isInner and 0 or spin*0.1)
                    seg.CFrame = CFrame.new(centerPos + Vector3.new(math.cos(angle)*r, 0.08, math.sin(angle)*r)) * CFrame.Angles(0, -angle, 0)
                end
            end
            for _,pl in pairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and not isTeammate(pl) then
                    local ch = pl.Character
                    if ch and ch.PrimaryPart then
                        local dist = (ch.PrimaryPart.Position - centerPos).Magnitude
                        if dist <= ultraRadius then
                            if not highlightMap[pl] then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = ch
                                hl.FillColor = Color3.fromRGB(0,200,255)
                                hl.FillTransparency = 0.7
                                hl.OutlineColor = Color3.fromRGB(255,255,255)
                                hl.Parent = LocalPlayer.PlayerGui
                                highlightMap[pl] = hl
                            end
                            local now = tick()
                            if now - _lastTeleportTime >= teleportCooldown and (not playerLastTeleported[pl] or now - playerLastTeleported[pl] >= 0.001) then
                                local safe = findSafeTeleport(centerPos, ch.PrimaryPart.Position, ultraRadius+3, {LocalPlayer.Character, ringModel})
                                if safe then
                                    proAfterImage()
                                    pcall(function() LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(safe + Vector3.new(0,0.5,0)) end)
                                    _lastTeleportTime = now
                                    playerLastTeleported[pl] = now
                                end
                            end
                        else
                            if highlightMap[pl] then highlightMap[pl]:Destroy() highlightMap[pl]=nil end
                        end
                    end
                end
            end
        end)
    end

    Settings:Section({ Title = "VOIN", Icon = "zap", Opened = true })

    Settings:Toggle({
        Title = "VOIN WALK",
        Icon = "zap",
        Default = false,
        Callback = function(v)
            if v then StartUltraInstinct(ultraRadius) else ClearUltra() end
        end
    })

  Settings:Slider({
        Title = "RADIO",
        Icon = "circle",
        Value = { Min = 5, Max = 50, Default = 20 },
        Callback = function(v)
            ultraRadius = v
            if ultraActive then StartUltraInstinct(v) end
        end
    })
end

Settings:Dropdown({
    Title = "CAMBIAR TEMA",
    Icon = "palette",
    Values = {"Dark", "Light", "Midnight", "Red", "Rose", "Indigo", "Amber", "Violet", "Emerald"},
    Value = "Dark",
    Callback = function(v)
        EL01ROXHUB_UI:SetTheme(v)
    end
})

Settings:Button({
    Title = "REJOIN SERVIDOR",
    Icon = "refresh-cw",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

Settings:Button({
    Title = "SERVER HOP",
    Icon = "server",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local req = request or http_request or (syn and syn.request)
        if req then
            local res = req({Url = Api, Method = "GET"})
            if res.StatusCode == 200 then
                local data = HttpService:JSONDecode(res.Body)
                for _, s in pairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TPS:TeleportToPlaceInstance(game.PlaceId, s.id)
                        return
                    end
                end
            end
        else
            TPS:Teleport(game.PlaceId)
        end
    end
})



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local LP = Players.LocalPlayer
while not LP do task.wait() LP = Players.LocalPlayer end
local player = LP
local camera = workspace.CurrentCamera
local fovVisiblePreference = false
local fovRadius = 120
local autoShootEnabled = false
local autoShootAgresivoEnabled = false
local autoShootTargetPart = "Cabeza"
local altoFireEnabled = false
local autoSacarArmaEnabled = false
local silentAimManualEnabled = false
local silentAimFovEnabled = false
local silentAimTargetPart = "Cabeza"
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local activeESPs = {}
local MAX_ESP_DISTANCE = 1500
local serverDeadCharacters = setmetatable({}, { __mode = "k" })
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "01ROXHUB"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = LP:WaitForChild("PlayerGui")
local espFolder = Instance.new("Folder")
espFolder.Name = "01ROXHUB"
espFolder.Parent = screenGui
local isEnemy, estaEnLobby, IsInMatchStrict
local esEnemigoValido, esCuchillo, esPistola
local startTargetMonitor
do
local function dmvsDisconnectConnectionList(list)
    if not list then return end
    for i = #list, 1, -1 do local c = list[i] list[i] = nil if c and c.Connected then c:Disconnect() end end
end
local function dmvsIsTargetAlive(target)
    local character = target
    if typeof(target) == "Instance" and target:IsA("Player") then character = target.Character end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return humanoid.Health >= 5
end
local function dmvsGetInGameScoreboard()
    local gui = player:FindFirstChild("PlayerGui")
    local main = gui and gui:FindFirstChild("Main")
    local frame = main and main:FindFirstChild("MainGameFrame")
    return frame and frame:FindFirstChild("IngameScore") or nil
end
local dmvsTeamResolverState = { Snapshot = {}, Scoreboard = nil, InGame = false, LocalGame = nil, LastRefresh = 0, RefreshInterval = 2, Dirty = true, WatchConnections = {} }
local function dmvsInvalidateScoreboard() dmvsTeamResolverState.Dirty = true end
local function dmvsWatchScoreboard(score)
    local state = dmvsTeamResolverState
    if state.Scoreboard == score then return end
    dmvsDisconnectConnectionList(state.WatchConnections)
    state.Scoreboard = score
    if not score then return end
    local watchTeams
    watchTeams = function()
        dmvsInvalidateScoreboard()
        dmvsDisconnectConnectionList(state.WatchConnections)
        state.WatchConnections[#state.WatchConnections + 1] = score.ChildAdded:Connect(watchTeams)
        state.WatchConnections[#state.WatchConnections + 1] = score.ChildRemoved:Connect(watchTeams)
        for _, name in ipairs({"TeamRed", "TeamBlue"}) do
            local folder = score:FindFirstChild(name)
            if folder then
                state.WatchConnections[#state.WatchConnections + 1] = folder.ChildAdded:Connect(dmvsInvalidateScoreboard)
                state.WatchConnections[#state.WatchConnections + 1] = folder.ChildRemoved:Connect(dmvsInvalidateScoreboard)
            end
        end
    end
    watchTeams()
end
local function dmvsRefreshScoreboardTeams(force)
    local state = dmvsTeamResolverState
    local now = os.clock()
    local localGame = player:GetAttribute("Game")
    if not force and not state.Dirty and now - state.LastRefresh < state.RefreshInterval and state.LocalGame == localGame and (not state.Scoreboard or state.Scoreboard.Parent) then return state.Snapshot end
    state.LastRefresh = now
    state.LocalGame = localGame
    local snapshot = {}
    local score = dmvsGetInGameScoreboard()
    if score ~= state.Scoreboard then dmvsWatchScoreboard(score) end
    for _, teamName in ipairs({"TeamRed", "TeamBlue"}) do
        local teamFolder = score and score:FindFirstChild(teamName)
        if teamFolder then
            local team = teamName == "TeamRed" and "Red" or "Blue"
            for _, entry in ipairs(teamFolder:GetChildren()) do if entry:IsA("GuiObject") then snapshot[string.lower(entry.Name)] = team end end
        end
    end
    state.Snapshot = snapshot
    state.Dirty = false
    state.InGame = score ~= nil and snapshot[string.lower(player.Name)] ~= nil
    return snapshot
end
local dmvsInfectionState = { Active = false, LastRefresh = -math.huge, Targets = {} }
local function dmvsIsInfectionMode() return dmvsInfectionState.Active end
local function dmvsIsInfectedTarget(targetPlayer)
    if not targetPlayer then return false end
    return dmvsInfectionState.Active and dmvsInfectionState.Targets[targetPlayer] == true
end
local function dmvsInfectionMarkDirty() dmvsInfectionState.LastRefresh = -math.huge end
local function dmvsIsInSameGame(targetPlayer)
    if not targetPlayer or targetPlayer == player or not targetPlayer.Parent then return false end
    if dmvsIsInfectionMode() then return dmvsIsInfectedTarget(targetPlayer) end
    local roster = dmvsRefreshScoreboardTeams(false)
    if not dmvsTeamResolverState.InGame or not roster[string.lower(targetPlayer.Name)] then return false end
    local myGame = player:GetAttribute("Game") local targetGame = targetPlayer:GetAttribute("Game")
    if myGame ~= nil and myGame ~= "" and targetGame ~= nil and targetGame ~= "" then if myGame ~= targetGame then return false end end
    return true
end
local function dmvsResolvePlayerTeam(targetPlayer)
    if not targetPlayer then return nil end
    local snapshot = dmvsRefreshScoreboardTeams(false)
    local byName = snapshot[string.lower(targetPlayer.Name)]
    if byName then return byName end
    local attr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")
    if attr ~= nil and tostring(attr) ~= "" then return tostring(attr) end
    if targetPlayer.Team then return targetPlayer.Team.Name end
    return nil
end
local function dmvsPlayersAreEnemies(firstPlayer, secondPlayer)
    if not firstPlayer or not secondPlayer or firstPlayer == secondPlayer then return false end
    if dmvsIsInfectionMode() then return dmvsIsInfectedTarget(secondPlayer) end
    local firstTeam = dmvsResolvePlayerTeam(firstPlayer)
    local secondTeam = dmvsResolvePlayerTeam(secondPlayer)
    if firstTeam ~= nil and secondTeam ~= nil then return firstTeam ~= secondTeam end
    return true
end
local function updateMyTeam() dmvsInvalidateScoreboard() end
local function updateEnemy() dmvsInvalidateScoreboard() dmvsInfectionMarkDirty() end
local dmvsTeamPlayerConnections = {}
local function disconnectPlayerTeamEvents(p)
    local connections = dmvsTeamPlayerConnections[p]
    if connections then dmvsDisconnectConnectionList(connections) dmvsTeamPlayerConnections[p] = nil end
end
local function setupPlayerEvents(p)
    if not p or p == player or not p.Parent then return end
    disconnectPlayerTeamEvents(p)
    dmvsTeamPlayerConnections[p] = {
        p:GetPropertyChangedSignal("Team"):Connect(updateEnemy),
        p:GetAttributeChangedSignal("Team"):Connect(updateEnemy),
        p:GetAttributeChangedSignal("Game"):Connect(updateEnemy),
        p.CharacterAdded:Connect(function() dmvsInfectionMarkDirty() updateEnemy() end),
    }
    updateEnemy()
end
local RoxhubTargetConnections = {} local RoxhubTargetMonitorActive = false
local function RoxhubMonitorConnection(c) RoxhubTargetConnections[#RoxhubTargetConnections + 1] = c return c end
local function RoxhubStartTargetMonitor()
    if RoxhubTargetMonitorActive then return end
    RoxhubTargetMonitorActive = true
    local function localChanged() updateMyTeam() dmvsInfectionMarkDirty() end
    for _, name in ipairs({"Team", "TeamColor"}) do RoxhubMonitorConnection(player:GetPropertyChangedSignal(name):Connect(localChanged)) end
    for _, name in ipairs({"Team", "team", "Game", "MatchId"}) do RoxhubMonitorConnection(player:GetAttributeChangedSignal(name):Connect(localChanged)) end
    for _, other in ipairs(Players:GetPlayers()) do if other ~= player then setupPlayerEvents(other) end end
    RoxhubMonitorConnection(Players.PlayerAdded:Connect(function(other) setupPlayerEvents(other) dmvsInfectionMarkDirty() end))
    RoxhubMonitorConnection(Players.PlayerRemoving:Connect(function(other) disconnectPlayerTeamEvents(other) updateEnemy() end))
    dmvsInvalidateScoreboard() dmvsInfectionMarkDirty()
end
startTargetMonitor = RoxhubStartTargetMonitor
isEnemy = function(targetPlayer)
    if not dmvsIsInSameGame(targetPlayer) or not targetPlayer.Character then return false end
    if not dmvsIsTargetAlive(targetPlayer) then return false end
    return dmvsPlayersAreEnemies(player, targetPlayer)
end
estaEnLobby = function()
    local character = player.Character
    if not character then return true end
    if character:FindFirstChildOfClass("ForceField") then return true end
    if player.Team then local name = player.Team.Name:lower() if name:find("lobby") or name:find("spectat") or name:find("menu") or name:find("dead") then return true end end
    return false
end
IsInMatchStrict = function()
    if estaEnLobby() then return false end
    dmvsRefreshScoreboardTeams(false)
    return dmvsTeamResolverState.InGame or dmvsIsInfectionMode()
end
esEnemigoValido = function(other)
    if not isEnemy(other) then return false end
    local character = other.Character
    return character ~= nil and not character:FindFirstChildOfClass("ForceField") and dmvsIsTargetAlive(other)
end
esCuchillo = function(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Slash") or tool:FindFirstChild("SlashStart") then return true end
    return false
end
esPistola = function(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return tool:FindFirstChild("showBeam") ~= nil
end
end
startTargetMonitor()

local AtrasEnabled = false
local function GetCercanoAtras()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    if estaEnLobby() then return nil end
    if not IsInMatchStrict() then return nil end
    local myRoot = char.HumanoidRootPart
    local cercano, distMin = nil, 200
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health > 0 and esEnemigoValido(plr) then
                local d = (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if d < distMin then distMin = d cercano = plr end
            end
        end
    end
    return cercano
end
local function LoopAtrasSolo()
    while AtrasEnabled do
        if estaEnLobby() then task.wait(0.5) continue end
        local char = LP.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not myRoot then task.wait(0.2) continue end
        local Target = GetCercanoAtras()
        if Target and Target.Character then
            local TRoot = Target.Character:FindFirstChild("HumanoidRootPart")
            local THum = Target.Character:FindFirstChild("Humanoid")
            if TRoot and THum and THum.Health > 0 then
                while AtrasEnabled and THum.Health > 0 and TRoot.Parent do
                    if estaEnLobby() then break end
                    if not esEnemigoValido(Target) then break end
                    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if not r then break end
                    local behind = (TRoot.CFrame * CFrame.new(0, 0, 6)).Position
                    r.CFrame = CFrame.lookAt(behind, TRoot.Position)
                    r.AssemblyLinearVelocity = Vector3.zero
                    RunService.Heartbeat:Wait()
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end
AutoKills:Section({ Title = "AUTO KILLS", Icon = "skull" })
AutoKills:Toggle({
    Title = "TELEKILL [SOLO ARMA]",
    Value = false,
    Callback = function(v)
        AtrasEnabled = v
        altoFireEnabled = v
        autoShootEnabled = v
        autoShootAgresivoEnabled = v
        if v then task.spawn(LoopAtrasSolo) else getgenv().RoxhubTargetPart = nil end
    end
})

local function getExecutor()
    if identifyexecutor then local ok, exec = pcall(identifyexecutor) if ok and exec then return exec end end
    return "Delta"
end
local function getGameName()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then return info.Name end
    return "01ROXHUB"
end
local avatarThumb = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=420&h=420"
local gameThumb = "rbxthumb://type=GameIcon&id="..game.GameId.."&w=512&h=512"
Home:Section({ Title = "PERFIL", Icon = "user", Opened = true })
Home:Paragraph({ Title = "Usuario: "..LP.DisplayName, Desc = "Usuario: @"..LP.Name.."\nID: "..LP.UserId.."\nEdad de la cuenta: "..LP.AccountAge.." días", Image = avatarThumb, ImageSize = 60 })
Home:Section({ Title = "Sistema", Icon = "monitor", Opened = true })
Home:Paragraph({ Title = "EXECUTOR", Desc = "Ejecutor actual: "..getExecutor() })
Home:Section({ Title = "Información del Servidor", Icon = "server", Opened = true })
Home:Paragraph({ Title = "Juego Actual", Desc = getGameName().."\nPlace ID: "..game.PlaceId, Image = gameThumb, ImageSize = 60 })
Aimbot:Section({ Title = "AUTO SHOOT", Icon = "target" })
Aimbot:Toggle({
    Title = "ALTO FIRE [AGRESIVO]",
    Value = false,
    Callback = function(v)
        altoFireEnabled = v
        autoShootEnabled = v
    end
})
Aimbot:Toggle({ Title = "AUTO SHOOT [NORMAL]", Value = false, Callback = function(v) autoShootEnabled = v if not v and not autoShootAgresivoEnabled then getgenv().RoxhubTargetPart = nil end end })
Aimbot:Toggle({ Title = "AUTO SHOOT [AGRESIVO]", Value = false, Callback = function(v) autoShootAgresivoEnabled = v if not v and not autoShootEnabled then getgenv().RoxhubTargetPart = nil end end })
Aimbot:Dropdown({ Title = "TARGET PARTE", Values = {"Cabeza","Torso","Cuerpo Completo"}, Value = "Cabeza", Callback = function(v) autoShootTargetPart = v end })
Aimbot:Section({ Title = "SILENT AIM + FOV", Icon = "radar" })
Aimbot:Toggle({ Title = "SILENT AIM", Value = false, Callback = function(v) silentAimManualEnabled = v if not v and not autoShootEnabled and not autoShootAgresivoEnabled then getgenv().RoxhubTargetPart = nil end end })
Aimbot:Dropdown({ Title = "SILENT TARGET", Values = {"Cabeza","Torso","Cuerpo Completo"}, Value = "Cabeza", Callback = function(v) silentAimTargetPart = v end })
Aimbot:Toggle({ Title = "SILENT AIM [FOV]", Value = false, Callback = function(v) silentAimFovEnabled = v if not v and not silentAimManualEnabled and not autoShootEnabled and not autoShootAgresivoEnabled then getgenv().RoxhubTargetPart = nil end end })
Aimbot:Toggle({ Title = "MOSTRAR FOV", Value = false, Callback = function(v) fovVisiblePreference = v end })
Aimbot:Slider({ Title = "TAMAÑO DEL FOV", Value = { Min = 10, Max = 800, Default = 120 }, Callback = function(v) fovRadius = v end })
Aimbot:Toggle({ Title = "AUTO SACAR ARMA", Value = false, Callback = function(v) autoSacarArmaEnabled = v end })
Movimiento:Section({ Title = "MOVIMIENTO", Icon = "zap", Opened = true })
Movimiento:Toggle({
    Title = "INVISIBLE V6",
    Icon = "ghost",
    Default = false,
    Callback = function(state)
        local RunService = game:GetService("RunService")
        local lp = game:GetService("Players").LocalPlayer
        local DISTANCIA = 50
        local TRANSPARENCIA = 0.6

        local function RoxHub_SetInvisible(char, invisible)
            if not char then return end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    if v.Name ~= "HumanoidRootPart" then
                        v.Transparency = invisible and TRANSPARENCIA or 0
                    else
                        v.Transparency = 1
                    end
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = invisible and TRANSPARENCIA or 0
                end
            end
        end

        if not state then
            if _G.InvisCon then _G.InvisCon:Disconnect() _G.InvisCon = nil end
            _G.InvisActive = false
            if lp.Character then
                RoxHub_SetInvisible(lp.Character, false)
            end
            return
        end

        _G.InvisActive = true
        RoxHub_SetInvisible(lp.Character, true)

        if _G.InvisCon then _G.InvisCon:Disconnect() end
        _G.InvisCon = RunService.Heartbeat:Connect(function()
            if not _G.InvisActive then return end
            local Char = lp.Character
            if not Char then return end
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChild("Humanoid")
            if not Root or not Hum or Hum.Health <= 0 then return end
            local oldCF = Root.CFrame
            local oldCamOffset = Hum.CameraOffset
            local invisCF = oldCF * CFrame.new(0, -DISTANCIA, 0)
            Root.CFrame = invisCF
            Hum.CameraOffset = invisCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
            RunService.RenderStepped:Wait()
            if Root and Root.Parent and Hum.Health > 0 then
                Root.CFrame = oldCF
                Hum.CameraOffset = oldCamOffset
            end
        end)
    end
})

Movimiento:Toggle({
    Title = "FLY SPEED V1",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local lp = Players.LocalPlayer
        local PlayerGui = lp:WaitForChild("PlayerGui")
        if not state then
            local old = PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED")
            if old then old:Destroy() end
            if _G.FlyCon1 then _G.FlyCon1:Disconnect() _G.FlyCon1 = nil end
            if _G.FlyCon2 then _G.FlyCon2:Disconnect() _G.FlyCon2 = nil end
            if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            return
        end
        if PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED") then
            PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED"):Destroy()
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "01ROXHUB_FLYSPEED"
        gui.ResetOnSpawn = false
        gui.Parent = PlayerGui
        local SPEED = 0.75
        local V_SPEED = 1.1
        local mov = {W=false,A=false,S=false,D=false,Up=false,Down=false}
        local presionando = false
        local pad = Instance.new("Frame", gui)
        pad.Name = "01ROXHUB_FLYSPEED"
        pad.Size = UDim2.fromOffset(128,185)
        pad.AnchorPoint = Vector2.new(0.5,0.5)
        pad.Position = UDim2.fromScale(0.5,0.65)
        pad.BackgroundColor3 = Color3.fromRGB(10,25,75)
        pad.BackgroundTransparency = 0.3
        Instance.new("UICorner", pad).CornerRadius = UDim.new(0,16)
        local stroke = Instance.new("UIStroke", pad)
        stroke.Color = Color3.fromRGB(70,130,255)
        stroke.Thickness = 2
        pad.Active = true
        pad.Draggable = true
        local function crearAzul(pos, txt, sx, sy, name)
            local b = Instance.new("TextButton", pad)
            b.Name = name
            b.Size = UDim2.fromOffset(sx or 30, sy or 30)
            b.Position = pos
            b.Text = txt
            b.TextScaled = true
            b.Font = Enum.Font.GothamBold
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(15,35,90)
            b.AutoButtonColor = false
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
            local grad = Instance.new("UIGradient", b)
            grad.Color = ColorSequence.new(Color3.fromRGB(60,110,230), Color3.fromRGB(15,35,110))
            grad.Rotation = 90
            return b
        end
        local up = crearAzul(UDim2.fromOffset(49,8), "▲", 30, 30, "01ROXHUB")
        local left = crearAzul(UDim2.fromOffset(10,42), "◄", 30, 30, "01ROXHUB")
        local right = crearAzul(UDim2.fromOffset(88,42), "►", 30, 30, "01ROXHUB")
        local down = crearAzul(UDim2.fromOffset(49,76), "▼", 30, 30, "01ROXHUB")
        local upV = crearAzul(UDim2.fromOffset(10,110), "⬆", 30, 30, "01ROXHUB")
        local downV = crearAzul(UDim2.fromOffset(88,110), "⬇", 30, 30, "01ROXHUB")
        local bajar = crearAzul(UDim2.fromOffset(6,148), "BAJAR", 54, 28, "01ROXHUB")
        local subir = crearAzul(UDim2.fromOffset(68,148), "SUBIR", 54, 28, "01ROXHUB")
        bajar.BackgroundColor3 = Color3.fromRGB(25,35,75)
        subir.BackgroundColor3 = Color3.fromRGB(20,55,120)
        local function estaEnPartida()
            local rs = game:GetService("ReplicatedStorage")
            if rs:FindFirstChild("GameInProgress") or rs:FindFirstChild("InGame") then
                local v = rs:FindFirstChild("GameInProgress") or rs:FindFirstChild("InGame")
                if v and v:IsA("BoolValue") then
                    return v.Value
                end
            end
            local char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if (char.HumanoidRootPart.Position - Vector3.new(0,10,0)).Magnitude > 150 then
                    return true
                end
            end
            return false
        end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.IgnoreWater = true
        local function noclipPared()
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            rayParams.FilterDescendantsInstances = {char}
            local dir = Vector3.new(0,0,0)
            if mov.W then dir += workspace.CurrentCamera.CFrame.LookVector end
            if mov.S then dir -= workspace.CurrentCamera.CFrame.LookVector end
            if mov.A then dir -= workspace.CurrentCamera.CFrame.RightVector end
            if mov.D then dir += workspace.CurrentCamera.CFrame.RightVector end
            if mov.Up then dir += Vector3.new(0,1,0) end
            if mov.Down then dir += Vector3.new(0,-1,0) end
            if dir.Magnitude == 0 then return end
            local ray = workspace:Raycast(hrp.Position, dir.Unit * 4, rayParams)
            if ray and ray.Instance and ray.Instance.CanCollide then
                local pared = ray.Instance
                pared.CanCollide = false
                task.delay(0.4, function()
                    pcall(function() pared.CanCollide = true end)
                end)
            end
        end
        local function conectar(b, k)
            b.MouseButton1Down:Connect(function()
                mov[k] = true
                presionando = true
            end)
            b.MouseButton1Up:Connect(function()
                mov[k] = false
                if not mov.W and not mov.A and not mov.S and not mov.D and not mov.Up and not mov.Down then
                    presionando = false
                end
            end)
            b.MouseLeave:Connect(function()
                mov[k] = false
                if not mov.W and not mov.A and not mov.S and not mov.D and not mov.Up and not mov.Down then
                    presionando = false
                end
            end)
        end
        conectar(up,"W")
        conectar(left,"A")
        conectar(right,"D")
        conectar(down,"S")
        conectar(upV,"Up")
        conectar(downV,"Down")
        bajar.MouseButton1Click:Connect(function()
            SPEED = math.clamp(SPEED - 0.1, 0.2, 3)
            V_SPEED = math.clamp(V_SPEED - 0.1, 0.2, 3)
        end)
        subir.MouseButton1Click:Connect(function()
            SPEED = math.clamp(SPEED + 0.1, 0.2, 3)
            V_SPEED = math.clamp(V_SPEED + 0.1, 0.2, 3)
        end)
        if _G.FlyCon1 then _G.FlyCon1:Disconnect() end
        if _G.FlyCon2 then _G.FlyCon2:Disconnect() end
        _G.FlyCon1 = RunService.RenderStepped:Connect(function()
            if not PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED") then return end
            if not estaEnPartida() then
                pad.Visible = false
                return
            end
            pad.Visible = true
            if not presionando then return end
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if mov.Up or mov.Down or mov.W or mov.A or mov.S or mov.D then
                hum:ChangeState(Enum.HumanoidStateType.Flying)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X * 0.1, 0, hrp.AssemblyLinearVelocity.Z * 0.1)
            end
            noclipPared()
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.new(0,0,0)
            if mov.W then dir += Vector3.new(cam.LookVector.X,0,cam.LookVector.Z) end
            if mov.S then dir -= Vector3.new(cam.LookVector.X,0,cam.LookVector.Z) end
            if mov.A then dir -= Vector3.new(cam.RightVector.X,0,cam.RightVector.Z) end
            if mov.D then dir += Vector3.new(cam.RightVector.X,0,cam.RightVector.Z) end
            if dir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + dir.Unit * SPEED end
            if mov.Up then hrp.CFrame = hrp.CFrame + Vector3.new(0, V_SPEED, 0) end
            if mov.Down then hrp.CFrame = hrp.CFrame - Vector3.new(0, V_SPEED, 0) end
        end)
        _G.FlyCon2 = RunService.Heartbeat:Connect(function()
            if not presionando then
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum:GetState() == Enum.HumanoidStateType.Flying then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
    end
})


task.spawn(function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    while task.wait(0.15) do
        if not altoFireEnabled then continue end
        if estaEnLobby() then continue end
        if not IsInMatchStrict() then continue end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then continue end
        if not char:FindFirstChild("HumanoidRootPart") then continue end
        local origin = char:FindFirstChild("Head") and char.Head.Position or char.HumanoidRootPart.Position
        local hay = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and esEnemigoValido(p) and p.Character then
                local tp = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                if tp then
                    params.FilterDescendantsInstances = { char, p.Character }
                    if not workspace:Raycast(origin, tp.Position - origin, params) then hay = true break end
                end
            end
        end
        if hay then
            local gun = nil
            local bp = LP:FindFirstChildOfClass("Backpack")
            for _, t in ipairs(char:GetChildren()) do if esPistola(t) then gun = t break end end
            if not gun and bp then for _, t in ipairs(bp:GetChildren()) do if esPistola(t) then gun = t break end end end
            if gun and gun.Parent ~= char then pcall(function() hum:EquipTool(gun) end) end
        end
    end
end)
getgenv().RoxhubTargetPart = nil
local oldNamecall
if hookmetamethod and getnamecallmethod and checkcaller then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and getgenv().RoxhubTargetPart then
            if method == "Raycast" and self == workspace then
                local target = getgenv().RoxhubTargetPart
                if target and target.Parent then
                    local origin, direction, p3 = ...
                    if typeof(direction) == "Vector3" and direction.Magnitude > 20 then
                        local cameraOrigin = workspace.CurrentCamera.CFrame.Position
                        if (origin - cameraOrigin).Magnitude >= 1 then
                            local newDir = (target.Position - origin).Unit * 5000
                            return oldNamecall(self, origin, newDir, p3)
                        end
                    end
                else
                    getgenv().RoxhubTargetPart = nil
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end
task.spawn(function()
    local params = RaycastParams.new() params.FilterType = Enum.RaycastFilterType.Exclude
    while task.wait(0.1) do
        if (autoShootEnabled or autoShootAgresivoEnabled) and not estaEnLobby() then
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local arma = char:FindFirstChildOfClass("Tool")
            if not arma or not arma:FindFirstChild("Handle") then getgenv().RoxhubTargetPart = nil continue end
            if esCuchillo(arma) then getgenv().RoxhubTargetPart = nil continue end
            local closestPart = nil local shortest = math.huge
            local myPos = char.HumanoidRootPart.Position local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and esEnemigoValido(p) then
                    local enemyHum = p.Character and p.Character:FindFirstChild("Humanoid")
                    if enemyHum and enemyHum.Health > 0 then
                        params.FilterDescendantsInstances = { char, p.Character }
                        local function Proc(part)
                            local d = (part.Position - myPos).Magnitude
                            if d < shortest then
                                if not workspace:Raycast(headPos, part.Position - headPos, params) then shortest = d closestPart = part end
                            end
                        end
                        if autoShootAgresivoEnabled then for _, part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then Proc(part) end end
                        elseif autoShootTargetPart == "Cabeza" then local h = p.Character:FindFirstChild("Head") if h then Proc(h) end
                        elseif autoShootTargetPart == "Torso" then for _, n in ipairs({"UpperTorso","Torso","HumanoidRootPart"}) do local pt = p.Character:FindFirstChild(n) if pt then Proc(pt) end end
                        else for _, part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then Proc(part) end end end
                    end
                end
            end
            if closestPart then getgenv().RoxhubTargetPart = closestPart pcall(function() arma:Activate() task.delay(0.05, function() if arma.Parent == char then arma:Deactivate() end end) end) task.wait(0.2) else getgenv().RoxhubTargetPart = nil end
        end
    end
end)
task.spawn(function()
    local params = RaycastParams.new() params.FilterType = Enum.RaycastFilterType.Exclude
    while task.wait(0.1) do
        if (silentAimManualEnabled or silentAimFovEnabled) and not estaEnLobby() then
            local char = LP.Character if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local closestPart = nil local shortestCenter = math.huge local shortestDist = math.huge
            local myPos = char.HumanoidRootPart.Position local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and esEnemigoValido(p) then
                    local enemyHum = p.Character and p.Character:FindFirstChild("Humanoid")
                    if enemyHum and enemyHum.Health > 0 then
                        local parts = {}
                        if silentAimTargetPart == "Cabeza" then local h = p.Character:FindFirstChild("Head") if h then table.insert(parts, h) end
                        elseif silentAimTargetPart == "Torso" then for _, n in ipairs({"UpperTorso","Torso","HumanoidRootPart"}) do local pt = p.Character:FindFirstChild(n) if pt then table.insert(parts, pt) end end
                        else for _, part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then table.insert(parts, part) end end end
                        params.FilterDescendantsInstances = { char, p.Character }
                        for _, part in ipairs(parts) do
                            local dist = (part.Position - myPos).Magnitude
                            local pos2D, onScreen = camera:WorldToViewportPoint(part.Position)
                            local distToCenter = (Vector2.new(pos2D.X, pos2D.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                            local okFilter = false
                            if silentAimFovEnabled then if onScreen and distToCenter <= fovRadius and distToCenter < shortestCenter then okFilter = true end
                            elseif silentAimManualEnabled then if dist < shortestDist then okFilter = true end end
                            if okFilter then if not workspace:Raycast(headPos, part.Position - headPos, params) then if silentAimFovEnabled then shortestCenter = distToCenter closestPart = part else shortestDist = dist closestPart = part end end end
                        end
                    end
                end
            end
            if closestPart then getgenv().RoxhubTargetPart = closestPart else if not autoShootEnabled and not autoShootAgresivoEnabled then getgenv().RoxhubTargetPart = nil end end
        end
    end
end)
local function cleanESP(targetPlayer)
    if activeESPs[targetPlayer] then if activeESPs[targetPlayer].Highlight then activeESPs[targetPlayer].Highlight:Destroy() end activeESPs[targetPlayer] = nil end
end
local function WatchServerDeath(char)
    if not char then return end
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end
        hum.Died:Connect(function() serverDeadCharacters[char] = true local p = Players:GetPlayerFromCharacter(char) if p then cleanESP(p) end end)
    end)
end
for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then if p.Character then WatchServerDeath(p.Character) end p.CharacterAdded:Connect(function(c) WatchServerDeath(c) end) end end
Players.PlayerAdded:Connect(function(p) if p ~= LP then if p.Character then WatchServerDeath(p.Character) end p.CharacterAdded:Connect(function(c) WatchServerDeath(c) end) end end)
Visuales:Section({ Title = "VISUALES", Icon = "eye", Opened = true })
Visuales:Toggle({ Title = "ESP HIGHILGHT", Value = false, Callback = function(s) espEnabled = s if not s then for _, p in pairs(Players:GetPlayers()) do local h = espFolder:FindFirstChild(p.Name .. "01ROXHUB") if h then h:Destroy() end activeESPs[p] = nil end end end })
Visuales:Colorpicker({ Title = "COLOR DEL ESP", Default = Color3.fromRGB(255, 0, 0), Callback = function(c) espColor = c for _, v in pairs(activeESPs) do if v.Highlight then v.Highlight.FillColor = c end end end })
task.spawn(function()
    while task.wait(0.2) do
        if espEnabled and IsInMatchStrict() then
            local myChar = LP.Character local myHead = myChar and myChar:FindFirstChild("Head") local myPos = myHead and myHead.Position
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP then
                    local char = p.Character local dead = char and serverDeadCharacters[char] == true
                    if char and not dead and char:FindFirstChild("Head") and esEnemigoValido(p) then
                        local dist = myPos and (char.Head.Position - myPos).Magnitude or 0
                        if dist <= MAX_ESP_DISTANCE then
                            if activeESPs[p] and activeESPs[p].Char ~= char then cleanESP(p) end
                            if not activeESPs[p] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = p.Name .. "01ROXHUB"
                                highlight.FillTransparency = 0.6
                                highlight.OutlineTransparency = 1
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.FillColor = espColor
                                highlight.OutlineColor = espColor
                                highlight.Adornee = char
                                highlight.Parent = espFolder
                                activeESPs[p] = { Highlight = highlight, Char = char }
                            end
                            local espObj = activeESPs[p]
                            if espObj.Highlight.FillColor ~= espColor then espObj.Highlight.FillColor = espColor espObj.Highlight.OutlineColor = espColor end
                        else cleanESP(p) end
                    else cleanESP(p) end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do cleanESP(p) end
        end
    end
end)
local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    FOVCircle.Radius = fovRadius
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1
end
RunService.RenderStepped:Connect(function()
    if fovVisiblePreference and FOVCircle then
        FOVCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        FOVCircle.Radius = fovRadius
        FOVCircle.Visible = true
        if silentAimFovEnabled and getgenv().RoxhubTargetPart then FOVCircle.Color = Color3.fromRGB(0, 255, 0) else FOVCircle.Color = Color3.fromRGB(255, 255, 255) end
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end)
Players.PlayerRemoving:Connect(function(p) cleanESP(p) end)
local AllPacks = {
    Astronaut = { idle1= "rbxassetid://891621366", idle2="rbxassetid://891633237", walk="rbxassetid://891667138", run="rbxassetid://891636393", jump="rbxassetid://891627522", fall="rbxassetid://891617961" },
    Bubbly = { idle1="rbxassetid://910004836", idle2="rbxassetid://910009958", walk="rbxassetid://910034870", run="rbxassetid://910025107", jump="rbxassetid://910016857", fall="rbxassetid://910001910" },
    Cartoony = { idle1="rbxassetid://742637544", idle2="rbxassetid://742638445", walk="rbxassetid://742640026", run="rbxassetid://742638842", jump="rbxassetid://742637942", fall="rbxassetid://742637151" },
    Elder = { idle1="rbxassetid://845397899", idle2="rbxassetid://845400520", walk="rbxassetid://845403856", run="rbxassetid://845386501", jump="rbxassetid://845398858", fall="rbxassetid://845396048" },
    Knight = { idle1="rbxassetid://657595757", idle2="rbxassetid://657568135", walk="rbxassetid://657552124", run="rbxassetid://657564596", jump="rbxassetid://658409194", fall="rbxassetid://657600338" },
    Ninja = { idle1="rbxassetid://656117400", idle2="rbxassetid://656118341", walk="rbxassetid://656121766", run="rbxassetid://656118852", jump="rbxassetid://656117878", fall="rbxassetid://656115606" },
    Pirate = { idle1="rbxassetid://750781874", idle2="rbxassetid://750782770", walk="rbxassetid://750785693", run="rbxassetid://750783738", jump="rbxassetid://750782230", fall="rbxassetid://750780242" },
    Robot = { idle1="rbxassetid://616088211", idle2="rbxassetid://616089559", walk="rbxassetid://616095330", run="rbxassetid://616091570", jump="rbxassetid://616090535", fall="rbxassetid://616087089" },
    Stylish = { idle1="rbxassetid://616136790", idle2="rbxassetid://616138447", walk="rbxassetid://616146177", run="rbxassetid://616140816", jump="rbxassetid://616139451", fall="rbxassetid://616134815" },
    SuperHero = { idle1="rbxassetid://616111295", idle2="rbxassetid://616113536", walk="rbxassetid://616122287", run="rbxassetid://616117076", jump="rbxassetid://616115533", fall="rbxassetid://616108001" },
    Zombie = { idle1="rbxassetid://616158929", idle2="rbxassetid://616160636", walk="rbxassetid://616168032", run="rbxassetid://616163682", jump="rbxassetid://616161997", fall="rbxassetid://616157476" },
    Confident = { idle1="rbxassetid://1069977950", idle2="rbxassetid://1069987858", walk="rbxassetid://1070017263", run="rbxassetid://1070001516", jump="rbxassetid://1069984524", fall="rbxassetid://1069973677" },
}
local PackNames = {"Ninguno"} for name in pairs(AllPacks) do table.insert(PackNames, name) end table.sort(PackNames)
local SelectedPack = "Ninguno"
local function ApplyAnims(ids)
    local char = LP.Character if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") local Animate = char:FindFirstChild("Animate")
    if not hum or not Animate then return end
    local animator = hum:FindFirstChildOfClass("Animator") if animator then for _, t in pairs(animator:GetPlayingAnimationTracks()) do t:Stop(0) t:Destroy() end end
    local function setAnim(parentName, childName, newId) local p = Animate:FindFirstChild(parentName) if p then local a = p:FindFirstChild(childName) if a and a:IsA("Animation") then a.AnimationId = newId end end end
    pcall(setAnim, "idle", "Animation1", ids.idle1) pcall(setAnim, "idle", "Animation2", ids.idle2) pcall(setAnim, "walk", "WalkAnim", ids.walk) pcall(setAnim, "run", "RunAnim", ids.run) pcall(setAnim, "jump", "JumpAnim", ids.jump) pcall(setAnim, "fall", "FallAnim", ids.fall)
    task.wait(0.05) Animate.Enabled = false task.wait(0.05) Animate.Enabled = true hum:ChangeState(Enum.HumanoidStateType.Running)
end
Animaciones:Section({ Title = "Paquetes Completos", Icon = "package" })
Animaciones:Dropdown({ Title = "Elegir Paquete", Values = PackNames, Value = "Ninguno", Callback = function(v) SelectedPack = v end })
Animaciones:Button({ Title = "Aplicar Paquete Completo", Icon = "sparkles", Callback = function() if SelectedPack ~= "Ninguno" and AllPacks[SelectedPack] then ApplyAnims(AllPacks[SelectedPack]) end end })
Animaciones:Button({ Title = "Restaurar Default", Icon = "rotate-ccw", Callback = function() if LP.Character and LP.Character:FindFirstChild("Animate") then LP.Character:FindFirstChild("Animate"):Destroy() end end })
Animaciones:Section({ Title = "Mezclador de Animaciones", Icon = "layers" })
local Mix = { Reposo="Ninguno", Caminar="Ninguno", Correr="Ninguno", Saltar="Ninguno", Caer="Ninguno" }
Animaciones:Dropdown({ Title = "Reposo", Values = PackNames, Value = "Ninguno", Callback = function(v) Mix.Reposo = v end })
Animaciones:Dropdown({ Title = "Caminar", Values = PackNames, Value = "Ninguno", Callback = function(v) Mix.Caminar = v end })
Animaciones:Dropdown({ Title = "Correr", Values = PackNames, Value = "Ninguno", Callback = function(v) Mix.Correr = v end })
Animaciones:Dropdown({ Title = "Saltar", Values = PackNames, Value = "Ninguno", Callback = function(v) Mix.Saltar = v end })
Animaciones:Dropdown({ Title = "Caer", Values = PackNames, Value = "Ninguno", Callback = function(v) Mix.Caer = v end })
Animaciones:Button({ Title = "Combinar y Aplicar", Icon = "sparkles", Callback = function()
    local final = {
        idle1 = AllPacks[Mix.Reposo] and AllPacks[Mix.Reposo].idle1 or "rbxassetid://0",
        idle2 = AllPacks[Mix.Reposo] and AllPacks[Mix.Reposo].idle2 or "rbxassetid://0",
        walk = AllPacks[Mix.Caminar] and AllPacks[Mix.Caminar].walk or "rbxassetid://0",
        run = AllPacks[Mix.Correr] and AllPacks[Mix.Correr].run or "rbxassetid://0",
        jump = AllPacks[Mix.Saltar] and AllPacks[Mix.Saltar].jump or "rbxassetid://0",
        fall = AllPacks[Mix.Caer] and AllPacks[Mix.Caer].fall or "rbxassetid://0",
    }
    ApplyAnims(final)
end })
LP.CharacterAdded:Connect(function(char) char:WaitForChild("Animate", 5) if SelectedPack ~= "Ninguno" and AllPacks[SelectedPack] then task.wait(0.3) ApplyAnims(AllPacks[SelectedPack]) end end)

local Players01 = game:GetService("Players")
local ContentProvider01 = game:GetService("ContentProvider")
local RunService01 = game:GetService("RunService")
local LocalPlayer01 = Players01.LocalPlayer
local SHELL_NAME_01ROXHUB = "01ROXHUB_Shell"
local env01 = (getgenv and getgenv()) or _G
if env01.RoxhubAvatarCleanup then pcall(env01.RoxhubAvatarCleanup) end
local function withTimeout01(secs, fn)
    local res,done=nil,false
    task.spawn(function() local ok,r=pcall(fn) if ok then res=r end done=true end)
    local t0=os.clock() while not done and os.clock()-t0<secs do task.wait(0.05) end
    return res
end
local function preload01(model)
    local list={} for _,d in ipairs(model:GetDescendants()) do if d:IsA("MeshPart") or d:IsA("SpecialMesh") or d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceAppearance") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then list[#list+1]=d end end if #list==0 then return end withTimeout01(15,function() ContentProvider01:PreloadAsync(list) end)
end
local LEG_NAMES_01ROXHUB={LeftFoot=true,RightFoot=true,LeftLowerLeg=true,RightLowerLeg=true,["Left Leg"]=true,["Right Leg"]=true}
local State01={template=nil,desc=nil,shell=nil,sRoot=nil,shellParts={},char=nil,conns={},hidden={},pairList={},offset=CFrame.new(),fp=false,lastScan=0,sAnimator=nil,mirror={},animActive=false,c0Dirty=false}
local Build01={} local BuildOrder01={} local MAX_BUILDS_01=4
local function loadAsset01(id) local obj local ok=pcall(function() obj=game:GetObjects("rbxassetid://"..id)[1] end) if ok and obj then return obj end ok=pcall(function() obj=game:GetService("InsertService"):LoadAsset(id) end) if ok and obj then return obj end end
local function findClass01(obj,class) if not obj then return nil end if obj:IsA(class) then return obj end return obj:FindFirstChildWhichIsA(class,true) end
local function buildFromAssets01(desc) local model=Instance.new("Model") model.Name="AvatarSource01ROXHUB" local pending=0 local function async(fn) pending=pending+1 task.spawn(function() pcall(fn) pending=pending-1 end) end local bc=Instance.new("BodyColors") bc.HeadColor3=desc.HeadColor bc.TorsoColor3=desc.TorsoColor bc.LeftArmColor3=desc.LeftArmColor bc.RightArmColor3=desc.RightArmColor bc.LeftLegColor3=desc.LeftLegColor bc.RightLegColor3=desc.RightLegColor bc.Parent=model local function loadInto(id,class,rename) if id and id>0 then async(function() local o=findClass01(loadAsset01(id),class) if o then if rename then o.Name=rename end o.Parent=model end end) end end loadInto(desc.Shirt,"Shirt") loadInto(desc.Pants,"Pants") loadInto(desc.GraphicTShirt,"ShirtGraphic") loadInto(desc.Face,"Decal","face") local okA,accs=pcall(function() return desc:GetAccessories(true) end) if okA and type(accs)=="table" then for _,a in ipairs(accs) do if a.AssetId and a.AssetId>0 then async(function() local acc=findClass01(loadAsset01(a.AssetId),"Accessory") if acc then local wl=acc:FindFirstChildWhichIsA("WrapLayer",true) if wl then if a.Order then wl.Order=a.Order end if a.Puffiness then wl.Puffiness=a.Puffiness end end acc.Parent=model end end) end end end local t0=os.clock() while pending>0 and os.clock()-t0<25 do task.wait(0.05) end return model end
local function attachByAttachments01(model,acc) local handle=acc:FindFirstChild("Handle") if not handle or not handle:IsA("BasePart") then acc.Parent=model return false end for _,d in ipairs(handle:GetChildren()) do if d:IsA("Weld") or d:IsA("Motor6D") or d:IsA("WeldConstraint") then d:Destroy() end end for _,a in ipairs(handle:GetChildren()) do if a:IsA("Attachment") then local target for _,p in ipairs(model:GetChildren()) do if p:IsA("BasePart") then local t=p:FindFirstChild(a.Name) if t and t:IsA("Attachment") then target=t break end end end if target then local w=Instance.new("Weld") w.Name="AccessoryWeld01ROXHUB" w.Part0=handle w.Part1=target.Parent w.C0=a.CFrame w.C1=target.CFrame w.Parent=handle acc.Parent=model return true end end end acc.Parent=model return false end
local function prepShell01(model) for _,d in ipairs(model:GetDescendants()) do if d:IsA("LuaSourceContainer") or d:IsA("Tool") or d:IsA("ForceField") or d:IsA("Sound") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then pcall(function() d:Destroy() end) end end for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then pcall(function() d.Anchored=false d.CanCollide=false d.CanTouch=false d.CanQuery=false d.Massless=true end) end end local root=model:FindFirstChild("HumanoidRootPart") if root then root.Anchored=true end local h=model:FindFirstChildOfClass("Humanoid") if h then pcall(function() h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end) pcall(function() h.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff end) pcall(function() h.BreakJointsOnDeath=false end) pcall(function() h.RequiresNeck=false end) pcall(function() h.EvaluateStateMachine=false end) pcall(function() h.AutoRotate=false end) pcall(function() h.WalkSpeed=0 end) pcall(function() h.PlatformStand=true end) end end
local function templateFromDescription01(desc,rig) for attempt=1,3 do local m=withTimeout01(30,function() return Players01:CreateHumanoidModelFromDescription(desc,rig) end) if typeof(m)=="Instance" then local h=m:FindFirstChildOfClass("Humanoid") if m:FindFirstChild("HumanoidRootPart") and h and h.RigType==rig then return m end pcall(function() m:Destroy() end) end task.wait(0.3) end return nil end
local function templateFromAssets01(desc,char) local base local okc=pcall(function() char.Archivable=true for _,d in ipairs(char:GetDescendants()) do pcall(function() d.Archivable=true end) end for inst,t in pairs(State01.hidden) do if inst.Parent then inst.Transparency=t end end base=char:Clone() for inst in pairs(State01.hidden) do if inst.Parent then inst.Transparency=1 end end end) if not okc or not base then return nil end for _,d in ipairs(base:GetDescendants()) do if d:IsA("LuaSourceContainer") or d:IsA("Tool") or d:IsA("Accoutrement") or d:IsA("CharacterAppearance") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("Highlight") or d:IsA("ForceField") then pcall(function() d:Destroy() end) end end local src=buildFromAssets01(desc) for _,c in ipairs(src:GetChildren()) do if c:IsA("CharacterAppearance") then c.Parent=base end end local head=base:FindFirstChild("Head") local face=src:FindFirstChild("face") if head and face then for _,d in ipairs(head:GetChildren()) do if d:IsA("Decal") then d:Destroy() end end face.Parent=head end for _,a in ipairs(src:GetChildren()) do if a:IsA("Accoutrement") then attachByAttachments01(base,a) end end pcall(function() src:Destroy() end) return base end
local function lowestLeg01(model) local root=model:FindFirstChild("HumanoidRootPart") if not root then return nil end local cf={[root]=CFrame.identity} local joints={} for _,d in ipairs(model:GetDescendants()) do if d:IsA("Motor6D") and d.Part0 and d.Part1 then joints[#joints+1]=d end end local changed,guard=true,0 while changed and guard<30 do changed=false guard=guard+1 for _,j in ipairs(joints) do local a,b=j.Part0,j.Part1 if cf[a] and not cf[b] then cf[b]=cf[a]*j.C0*j.C1:Inverse() changed=true elseif cf[b] and not cf[a] then cf[a]=cf[b]*j.C1*j.C0:Inverse() changed=true end end end local low for p,c in pairs(cf) do if LEG_NAMES_01ROXHUB[p.Name] and p.Parent==model then local s=p.Size local ext=0.5*(math.abs(c.RightVector.Y)*s.X+math.abs(c.UpVector.Y)*s.Y+math.abs(c.LookVector.Y)*s.Z) local y=c.Position.Y-ext if not low or y<low then low=y end end end return low end
local function hideReal01(char) local function hide(p) if State01.hidden[p]==nil then State01.hidden[p]=p.Transparency end if p.Transparency~=1 then p.Transparency=1 end end for _,c in ipairs(char:GetChildren()) do if c:IsA("BasePart") and c.Name~="HumanoidRootPart" then hide(c) elseif c:IsA("Accoutrement") then for _,d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then hide(d) end end end end end
local function setShellLTM01(v) for _,p in ipairs(State01.shellParts) do pcall(function() p.LocalTransparencyModifier=v end) end end
local function unmount01() for _,c in ipairs(State01.conns) do pcall(function() c:Disconnect() end) end State01.conns={} if State01.shell then pcall(function() State01.shell:Destroy() end) end for inst,t in pairs(State01.hidden) do if inst.Parent then pcall(function() inst.Transparency=t end) end end State01.shell,State01.sRoot,State01.char=nil,nil,nil State01.shellParts,State01.hidden,State01.pairList={},{},{} State01.mirror,State01.sAnimator,State01.animActive,State01.c0Dirty={},nil,false,false State01.fp=false end
local function noCollide01() for _,p in ipairs(State01.shellParts) do if p.CanCollide then p.CanCollide=false end if p.CanTouch then p.CanTouch=false end if p.CanQuery then p.CanQuery=false end end end
local function poseTransform01(rm) local p0,p1=rm.Part0,rm.Part1 if p0 and p1 then return (p0.CFrame*rm.C0):Inverse()*(p1.CFrame*rm.C1) end return rm.Transform end
local function resetC001() for _,pr in ipairs(State01.pairList) do local sm=pr[2] if sm.Parent then sm.C0=pr[3] end end State01.c0Dirty=false end
local function syncPose01() local shell,char=State01.shell,State01.char if not shell or not char or not char.Parent then return end if State01.animActive then if State01.c0Dirty then resetC001() end return end for _,pr in ipairs(State01.pairList) do local rm,sm,baseC0=pr[1],pr[2],pr[3] if rm.Parent and sm.Parent then local ok,tr=pcall(poseTransform01,rm) if ok and tr then sm.C0=baseC0*tr end end end State01.c0Dirty=true end
local function mirrorAnimations01() local char,shell,sAnim=State01.char,State01.shell,State01.sAnimator if not char or not shell or not sAnim or not sAnim.Parent then State01.animActive=false return end local rHum=char:FindFirstChildOfClass("Humanoid") local rAnim=rHum and rHum:FindFirstChildOfClass("Animator") if not rAnim then State01.animActive=false return end local okT,tracks=pcall(function() return rAnim:GetPlayingAnimationTracks() end) if not okT or type(tracks)~="table" then State01.animActive=false return end local seen,count={},0 for _,rt in ipairs(tracks) do local anim=rt.Animation if anim and anim.AnimationId~="" then seen[rt]=true local m=State01.mirror[rt] if not m then local ok,st=pcall(function() return sAnim:LoadAnimation(anim) end) if ok and st then m=st State01.mirror[rt]=st pcall(function() st.Priority=rt.Priority st.Looped=rt.Looped st:Play(0.1,math.max(rt.WeightCurrent,0.01),rt.Speed) end) end end if m then pcall(function() if not m.IsPlaying then m:Play(0.1,math.max(rt.WeightCurrent,0.01),rt.Speed) end m.Priority=rt.Priority m.Looped=rt.Looped m:AdjustWeight(math.max(rt.WeightCurrent,0.01),0) m:AdjustSpeed(rt.Speed) local len=rt.Length if len and len>0 then local d=math.abs(m.TimePosition-rt.TimePosition) if rt.Looped then d=math.min(d,len-d) end if d>0.25 then m.TimePosition=rt.TimePosition end end end) count=count+1 end end end for rt,st in pairs(State01.mirror) do if not seen[rt] then pcall(function() st:Stop(0.1) end) State01.mirror[rt]=nil end end State01.animActive=count>0 end
local function onStep01() local shell,char,sRoot=State01.shell,State01.char,State01.sRoot if not shell or not char or not sRoot or not char.Parent then return end local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end local want=workspace.CurrentCamera or workspace if shell.Parent~=want then shell.Parent=want end for inst in pairs(State01.hidden) do if inst.Parent and inst.Transparency~=1 then inst.Transparency=1 end end noCollide01() sRoot.CFrame=hrp.CFrame*State01.offset mirrorAnimations01() syncPose01() local now=os.clock() if now-State01.lastScan>0.3 then State01.lastScan=now hideReal01(char) end local cam=workspace.CurrentCamera local head=char:FindFirstChild("Head") if cam and head then local fp=(cam.CFrame.Position-head.Position).Magnitude<1.6 if fp~=State01.fp then State01.fp=fp setShellLTM01(fp and 1 or 0) end end end
local function mount01(char,hum,template) unmount01() local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return false end local shell=template:Clone() shell.Name=SHELL_NAME_01ROXHUB local sRoot=shell:FindFirstChild("HumanoidRootPart") if not sRoot then shell:Destroy() return false end local sh=shell:FindFirstChildOfClass("Humanoid") local sAnimator if sh then pcall(function() sh.WalkSpeed=0 end) pcall(function() sh.JumpPower=0 end) pcall(function() sh.AutoRotate=false end) pcall(function() sh.PlatformStand=true end) sAnimator=sh:FindFirstChildOfClass("Animator") if not sAnimator then sAnimator=Instance.new("Animator") sAnimator.Parent=sh end end local list={} for _,rm in ipairs(char:GetDescendants()) do if rm:IsA("Motor6D") and rm.Parent and rm.Parent.Parent==char then local sp=shell:FindFirstChild(rm.Parent.Name) local sm=sp and sp:FindFirstChild(rm.Name) if sm and sm:IsA("Motor6D") then list[#list+1]={rm,sm,sm.C0} end end end local dy=0 local lowR,lowS=lowestLeg01(char),lowestLeg01(shell) if lowR and lowS then dy=math.clamp(lowR-lowS,-8,8) end State01.offset=CFrame.new(0,dy,0) sRoot.Anchored=true shell.PrimaryPart=sRoot shell:PivotTo(hrp.CFrame*State01.offset) local parts={} for _,d in ipairs(shell:GetDescendants()) do if d:IsA("BasePart") then pcall(function() d.CanCollide=false d.CanTouch=false d.CanQuery=false d.Massless=true end) parts[#parts+1]=d end end State01.shell,State01.sRoot,State01.char=shell,sRoot,char State01.sAnimator,State01.mirror,State01.animActive,State01.c0Dirty=sAnimator,{},false,false State01.shellParts,State01.pairList=parts,list State01.fp=false shell.Parent=workspace.CurrentCamera or workspace hideReal01(char) State01.lastScan=os.clock() State01.conns[#State01.conns+1]=RunService01.RenderStepped:Connect(onStep01) State01.conns[#State01.conns+1]=RunService01.Stepped:Connect(function() noCollide01() syncPose01() end) State01.conns[#State01.conns+1]=RunService01.Heartbeat:Connect(function() noCollide01() syncPose01() end) return true end
local function buildTemplate01(desc,rig,char) local template,mode=templateFromDescription01(desc,rig),"model" if not template then template,mode=templateFromAssets01(desc,char),"assets" end if not template then return nil end prepShell01(template) preload01(template) return template,mode end
local function evictBuilds01() while #BuildOrder01>MAX_BUILDS_01 do local victim for i,id in ipairs(BuildOrder01) do local b=Build01[id] if b and b.state~="building" and b.template~=State01.template then victim=i break end end if not victim then return end local id=table.remove(BuildOrder01,victim) local b=Build01[id] Build01[id]=nil if b and b.template then pcall(function() b.template:Destroy() end) end end end
local function ensureBuild01(entry) local char=LocalPlayer01.Character local hum=char and char:FindFirstChildOfClass("Humanoid") if not hum then return nil end local rig=hum.RigType local b=Build01[entry.id] if b and b.rig==rig and b.state~="failed" then return b end if b then local i=table.find(BuildOrder01,entry.id) if i then table.remove(BuildOrder01,i) end if b.template and b.template~=State01.template then pcall(function() b.template:Destroy() end) end end b={state="building",rig=rig} Build01[entry.id]=b BuildOrder01[#BuildOrder01+1]=entry.id task.spawn(function() local ok,t,mode=pcall(buildTemplate01,entry.desc,rig,char) if ok and t then b.template,b.mode,b.state=t,mode,"ready" else b.state="failed" end evictBuilds01() end) return b end
local current01=nil local busy01=false local applying01=false
local function resolveUser01(text) text=string.match(text or "","^%s*(.-)%s*$") if text=="" then return nil end local id,name if text:match("^%d+$") then id=tonumber(text) local ok,n=pcall(Players01.GetNameFromUserIdAsync,Players01,id) if ok then name=n else local ok2,id2=pcall(Players01.GetUserIdFromNameAsync,Players01,text) if ok2 then id=id2 else return nil end end else local ok,uid=pcall(Players01.GetUserIdFromNameAsync,Players01,text) if not ok then return nil end id=uid end if not name then local ok,n=pcall(Players01.GetNameFromUserIdAsync,Players01,id) name=ok and n or text end return id,name end
local function search01(text) if busy01 then return false end busy01=true local id,name=resolveUser01(text) if not id then busy01=false return false end local desc for _=1,3 do local ok,d=pcall(Players01.GetHumanoidDescriptionFromUserId,Players01,id) if ok and d then desc=d break end task.wait(0.3) end if not desc then busy01=false return false end current01={id=id,name=name,desc=desc} ensureBuild01(current01) busy01=false return true end
local function applyAvatar01(entry) local char=LocalPlayer01.Character local hum=char and char:FindFirstChildOfClass("Humanoid") local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hum or not hrp then return false end local b=ensureBuild01(entry) if not b then return false end if b.state=="building" then while b.state=="building" do task.wait(0.1) end end if b.state~="ready" or not b.template then Build01[entry.id]=nil return false end local template=b.template char=LocalPlayer01.Character hum=char and char:FindFirstChildOfClass("Humanoid") if not hum then return false end State01.template=template State01.desc=entry.desc return mount01(char,hum,template) end
local function copyCurrent01() if applying01 then return end if not current01 then return end applying01=true local cur=current01 local ok,success=pcall(applyAvatar01,cur) applying01=false return success end
local function restoreAvatar01() unmount01() State01.template,State01.desc=nil,nil end
LocalPlayer01.CharacterAdded:Connect(function(char)
    unmount01()
    local hum=char:WaitForChild("Humanoid",15) if not hum then return end
    char:WaitForChild("HumanoidRootPart",15) task.wait(0.4)
    if LocalPlayer01.Character~=char or not State01.template then return end
    while applying01 do task.wait(0.2) end
    local th=State01.template:FindFirstChildOfClass("Humanoid") if not th or th.RigType~=hum.RigType then return end
    mount01(char,hum,State01.template)
end)
local userParaCopiar01 = "Loser"
Animaciones:Section({ Title = "AVATAR", Icon = "user" })
Animaciones:Input({
    Title = "COPY AVATAR BETA",
    Callback = function(text)
        userParaCopiar01 = text
    end
})
Animaciones:Button({
    Title = "COPIAR AVATAR",
    Icon = "copy",
    Callback = function()
        if userParaCopiar01 == "" then return end
        task.spawn(function()
            if search01(userParaCopiar01) then
                copyCurrent01()
            end
        end)
    end
})
Animaciones:Button({
    Title = "QUITAR AVATAR",
    Icon = "trash",
    Callback = function()
        restoreAvatar01()
    end
})

local Creditos = EL01ROXHUB:Tab({ Title = "CRÉDITOS", Icon = "gem" })

Creditos:Section({ Title = "CRÉDITOS", Icon = "crown" })

Creditos:Paragraph({
    Title = "EL 01 ROX HUB",
    Desc = '<font color="#FFD700">[CREADOR]</font> \nDESARROLLADOR Y CREADOR DEL PROYECTO OPEN 01ROXHUB',
    Image = "rbxassetid://76111147434526",
    ImageSize = 75
})

Creditos:Paragraph({
    Title = "MATI HUB",
    Desc = '<font color="#FFD700">[CREADOR]</font> \nDESARROLLADOR Y CREADOR DEL PROYECTO OPEN 01ROXHUB',
    Image = "rbxassetid://138199482138345",
    ImageSize = 75
})

Visuales:Space()
Visuales:Divider()
Visuales:Space()
Visuales:Section({ Title = "HITBOX ESPANDER", Icon = "solar:box-bold" })

local hitboxEnabled = false
local hitboxInvisible = false
local hitboxSize = 3.5
local hitboxColor = Color3.fromRGB(255, 0, 0)

local function limpiarHitboxes()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        local character = targetPlayer.Character
        if character then
            local hitbox = character:FindFirstChild("01ROXHUB_HITBOX")
            if hitbox then hitbox:Destroy() end
        end
    end
end

Visuales:Toggle({
    Title = "HITBOX [VISIBLE]",
    Value = false,
    Callback = function(Value)
        hitboxEnabled = Value
        if not Value then limpiarHitboxes() end
    end
})

Visuales:Toggle({
    Title = "HITBOX [INVISIBLE]",
    Value = false,
    Callback = function(Value) hitboxInvisible = Value end
})

Visuales:Slider({
    Title = "TAMAÑO",
    Step = 0.5,
    Value = { Min = 1.0, Max = 18.0, Default = 3.5 },
    Callback = function(v) hitboxSize = v end
})

Visuales:Colorpicker({
    Title = "COLOR DE LA HITBOX",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c) hitboxColor = c end
})

task.spawn(function()
    while task.wait(0.2) do
        if not hitboxEnabled then continue end
        if not IsInMatchStrict() then
            limpiarHitboxes()
            continue
        end
        local tamanoObjetivo = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        local transObjetivo = hitboxInvisible and 1 or 0.6
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and isEnemy(targetPlayer) then
                local character = targetPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 then
                        local hitbox = character:FindFirstChild("01ROXHUB_HITBOX")
                        if not hitbox then
                            hitbox = Instance.new("Part")
                            hitbox.Name = "01ROXHUB_HITBOX"
                            hitbox.Size = tamanoObjetivo
                            hitbox.Transparency = transObjetivo
                            hitbox.Color = hitboxColor
                            hitbox.CanCollide = false
                            hitbox.Massless = true
                            hitbox.CanQuery = true
                            hitbox.CFrame = rootPart.CFrame
                            hitbox.Parent = character
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = rootPart
                            weld.Part1 = hitbox
                            weld.Parent = hitbox
                        else
                            if hitbox.Size ~= tamanoObjetivo then hitbox.Size = tamanoObjetivo end
                            if hitbox.Transparency ~= transObjetivo then hitbox.Transparency = transObjetivo end
                            if hitbox.Color ~= hitboxColor then hitbox.Color = hitboxColor end
                            if not hitbox.CanQuery then hitbox.CanQuery = true end
                        end
                    else
                        local hitbox = character:FindFirstChild("01ROXHUB_HITBOX")
                        if hitbox then hitbox:Destroy() end
                    end
                end
            else
                local char = targetPlayer.Character
                if char then
                    local hb = char:FindFirstChild("01ROXHUB_HITBOX")
                    if hb then hb:Destroy() end
                end
            end
        end
    end
end)
 
Settings:Section({ Title = "MODO STREAMER", Icon = "user-x" })

local spoofNameText = "01ROXHUB"
local isWorkspaceLooping = false

local function safeReplace(str, find, replace)
    local safeFind = find:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
    return (str:gsub(safeFind, replace))
end

local function processText(v, myName, myDisp)
    local parentGui = v:FindFirstAncestorWhichIsA("ScreenGui")
    if parentGui and (string.find(parentGui.Name, "WindUI") or string.find(parentGui.Name, "01ROXHUB")) then return end
    
    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
        local txt = v.Text
        local hasName = false
        
        if txt and txt ~= "" then
            if string.find(txt, myName, 1, true) or string.find(txt, myDisp, 1, true) then
                hasName = true
            end
        end
        
        if hasName then
            v.RichText = true
            local newText = safeReplace(v.Text, myName, spoofNameText)
            newText = safeReplace(newText, myDisp, spoofNameText)
            v.Text = newText
        end
    end
end

Settings:Toggle({
    Title = "OCULTAR NOMBRE",
    Default = false,
    Callback = function(state)
        isWorkspaceLooping = state
        if state then
            task.spawn(function()
                while isWorkspaceLooping do
                    task.wait(1)
                    pcall(function()
                        local myName = player.Name
                        local myDisp = player.DisplayName
                        for _, gui in ipairs(game:GetDescendants()) do
                            if gui:IsA("TextLabel") or gui:IsA("TextBox") or gui:IsA("TextButton") then
                                local txt = gui.Text
                                if txt and txt ~= "" then
                                    if string.find(txt, myName, 1, true) or string.find(txt, myDisp, 1, true) then
                                        processText(gui, myName, myDisp)
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

Settings:Input({
    Title = "NOMBRE FALSO",
    Placeholder = "XXX-XXXX-XXX",
    Value = "01ROXHUB",
    Callback = function(text)
        if text ~= "" then
            spoofNameText = text
        end
    end
})

local KillSoundEnabled = false
local SelectedKillSound = "Onichaaan"
local KillSoundVolume = 1

local KillSounds = {
    { Name = "ES HACKER",       Id = "126835547301650" },
    { Name = "DOMIDIOS VOLVÍ",         Id = "75227901457581" },
    { Name = "BOYKA APLICACIÓN",         Id = "74574513441326" },
    { Name = "AGÁRRATE DOMIDIOS",        Id = "132837271823305" },
    { Name = "MAMBO",    Id =  "131928826207735" },
    { Name = "SUAVE SUAVE",         Id = "107166596193919" },

    { Name = "ESTRELLA",          Id = "109296938403067" },

}

local KillSoundPlayer = Instance.new("Sound")
KillSoundPlayer.Name = "01ROXHUB_KillSound"
KillSoundPlayer.Volume = 1
KillSoundPlayer.Looped = false
KillSoundPlayer.Parent = game:GetService("SoundService")

local function GetKillSoundIdByName(soundName)
    for _, s in ipairs(KillSounds) do
        if s.Name == soundName then return s.Id end
    end
    return KillSounds[1].Id
end

local function PlayKillSound()
    if not KillSoundEnabled then return end
    KillSoundPlayer:Stop()
    KillSoundPlayer.SoundId = "rbxassetid://" .. GetKillSoundIdByName(SelectedKillSound)
    KillSoundPlayer.Volume = KillSoundVolume
    KillSoundPlayer:Play()
end

local lastKillSoundTime = 0
local function TryPlayKillSound()
    if not KillSoundEnabled then return end
    local now = tick()
    if now - lastKillSoundTime < 0.08 then return end
    lastKillSoundTime = now
    PlayKillSound()
end

local function SetupKillSoundDetector()
    local KILL_STAT_NAMES = { kos = true, kills = true, kill = true, ko = true, killed = true, eliminations = true, kills_count = true }
    local function HookStatValue(stat)
        if not stat or not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then return end
        if not KILL_STAT_NAMES[string.lower(stat.Name)] then return end
        if stat:GetAttribute("RoxhubKOHooked") then return end
        stat:SetAttribute("RoxhubKOHooked", true)
        local lastVal = stat.Value
        stat:GetPropertyChangedSignal("Value"):Connect(function()
            if stat.Value > lastVal then TryPlayKillSound() end
            lastVal = stat.Value
        end)
    end
    local function HookLeaderstatsContainer(container)
        if not container then return end
        for _, stat in ipairs(container:GetChildren()) do HookStatValue(stat) end
        container.ChildAdded:Connect(HookStatValue)
    end
    for _, attrName in ipairs({"KOs","Kills","kos","kills","KO","killed","Eliminations"}) do
        local lastVal = tonumber(LP:GetAttribute(attrName))
        LP:GetAttributeChangedSignal(attrName):Connect(function()
            local newVal = tonumber(LP:GetAttribute(attrName))
            if newVal ~= nil and lastVal ~= nil and newVal > lastVal then TryPlayKillSound() end
            lastVal = newVal
        end)
    end
    if LP:FindFirstChild("leaderstats") then HookLeaderstatsContainer(LP:FindFirstChild("leaderstats")) end
    LP.ChildAdded:Connect(function(child)
        if child.Name == "leaderstats" then HookLeaderstatsContainer(child) end
    end)
    local function HookKillOnCharacter(targetPlayer, character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        humanoid.Died:Connect(function()
            if not KillSoundEnabled then return end
            local tag = humanoid:FindFirstChild("creator")
            if tag and tag.Value == LP then TryPlayKillSound() end
        end)
    end
    local function HookKillPlayer(targetPlayer)
        if targetPlayer == LP then return end
        if targetPlayer.Character then task.spawn(HookKillOnCharacter, targetPlayer, targetPlayer.Character) end
        targetPlayer.CharacterAdded:Connect(function(c) HookKillOnCharacter(targetPlayer, c) end)
    end
    for _, p in ipairs(Players:GetPlayers()) do HookKillPlayer(p) end
    Players.PlayerAdded:Connect(HookKillPlayer)
end
SetupKillSoundDetector()

AutoKills:Toggle({
    Title = "SONIDO DE KILL",
    Value = false,
    Callback = function(v)
        KillSoundEnabled = v
        if not v then KillSoundPlayer:Stop() end
    end
})

local KillSoundDropdownValues = {}
for _, s in ipairs(KillSounds) do table.insert(KillSoundDropdownValues, s.Name) end

AutoKills:Dropdown({
    Title = "SONIDO DE MUERTE",
    Values = KillSoundDropdownValues,
    Value = "",
    Callback = function(selected) SelectedKillSound = selected end
})

AutoKills:Slider({
    Title = "VOLUMEN SONIDO",
    Value = { Min = 1, Max = 3, Default = 1 },
    Callback = function(v)
        KillSoundVolume = v
        KillSoundPlayer.Volume = v
    end
})
