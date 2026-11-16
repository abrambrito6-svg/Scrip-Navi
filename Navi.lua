
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
        if not checkcaller() and getgenv().Roxh
... (Tiempo restante: 47 KB)