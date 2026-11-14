--[[
    Zenith -- Duelos | HUB -- By Navi
    Murder Mystery 2
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// Configuración
local Config = {
    ESP = {
        Enabled = false,
        Glow = false,
        Names = true,
        Distance = true,
        Skeleton = true,
        Tracers = false,
        DroppedGun = true
    },
    Aimlock = {
        Enabled = false,
        AutoShoot = false,
        WallCheck = true,
        TeamCheck = false,
        FOV = 180,
        Smoothness = 0.15
    },
    Combat = {
        KillAura = false,
        KillAuraRange = 25,
        AutoStab = false
    },
    Movement = {
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        Speed = false,
        SpeedValue = 25
    },
    AutoFarm = {
        Enabled = false
    },
    Colors = {
        Murderer = Color3.fromRGB(255, 40, 40),
        Sheriff = Color3.fromRGB(40, 120, 255),
        Innocent = Color3.fromRGB(255, 255, 255)
    }
}

--// Variables
local ESPObjects = {}
local Connections = {}
local IsMinimized = false
local CurrentMurderer = nil
local CurrentSheriff = nil

--// Utilidades
local function GetRole(player)
    if not player or not player.Character then return "Innocent" end
    local char = player.Character
    if char:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
        return "Murderer"
    end
    if char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then
        return "Sheriff"
    end
    -- Método alternativo (algunos servidores usan valores)
    local role = player:FindFirstChild("Role") or player:FindFirstChild("role")
    if role then
        local val = tostring(role.Value):lower()
        if val:find("murder") then return "Murderer" end
        if val:find("sheriff") then return "Sheriff" end
    end
    return "Innocent"
end

local function IsAlive(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZenithHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 480, 0, 360)
Main.Position = UDim2.new(0.5, -240, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Main

-- Background Image
local Background = Instance.new("ImageLabel")
Background.Name = "Background"
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundTransparency = 1
Background.Image = "https://files.catbox.moe/cmrqdt.jpg"
Background.ImageTransparency = 0.65
Background.ScaleType = Enum.ScaleType.Crop
Background.Parent = Main

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(0, 10)
BGCorner.Parent = Background

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Zenith -- Duelos | HUB -- By Navi"
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 2)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 680)
Content.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.Parent = Content

-- Role Display
local RoleDisplay = Instance.new("TextLabel")
RoleDisplay.Size = UDim2.new(1, 0, 0, 40)
RoleDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
RoleDisplay.Text = "Murderer: ---  |  Sheriff: ---"
RoleDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
RoleDisplay.TextSize = 14
RoleDisplay.Font = Enum.Font.Gotham
RoleDisplay.Parent = Content

local RoleCorner = Instance.new("UICorner")
RoleCorner.CornerRadius = UDim.new(0, 6)
RoleCorner.Parent = RoleDisplay

-- Función para crear toggles
local function CreateToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 34)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Frame.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 44, 0, 22)
    Toggle.Position = UDim2.new(1, -52, 0.5, -11)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(90, 50, 200) or Color3.fromRGB(50, 50, 60)
    Toggle.Text = ""
    Toggle.Parent = Frame

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = Toggle

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = Toggle

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = Circle

    local state = default
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.BackgroundColor3 = state and Color3.fromRGB(90, 50, 200) or Color3.fromRGB(50, 50, 60)
        Circle:TweenPosition(state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.15, true)
        callback(state)
    end)

    return Frame
end

-- Crear Toggles
CreateToggle("ESP Glow", false, function(v) Config.ESP.Glow = v end)
CreateToggle("Ver Nombres", true, function(v) Config.ESP.Names = v end)
CreateToggle("Ver Distancia", true, function(v) Config.ESP.Distance = v end)
CreateToggle("ESP Esqueleto", true, function(v) Config.ESP.Skeleton = v end)
CreateToggle("ESP Líneas", false, function(v) Config.ESP.Tracers = v end)
CreateToggle("ESP Arma Tirada", true, function(v) Config.ESP.DroppedGun = v end)

CreateToggle("Aimlock", false, function(v) Config.Aimlock.Enabled = v end)
CreateToggle("Auto Shoot", false, function(v) Config.Aimlock.AutoShoot = v end)
CreateToggle("Wall Check", true, function(v) Config.Aimlock.WallCheck = v end)
CreateToggle("Kill Aura", false, function(v) Config.Combat.KillAura = v end)
CreateToggle("Auto Stab", false, function(v) Config.Combat.AutoStab = v end)

CreateToggle("Volar (Fly)", false, function(v) Config.Movement.Fly = v end)
CreateToggle("Noclip", false, function(v) Config.Movement.Noclip = v end)
CreateToggle("Caminar Rápido", false, function(v) Config.Movement.Speed = v end)
CreateToggle("AutoFarm", false, function(v) Config.AutoFarm.Enabled = v end)

-- Minimizar
local MiniButton = Instance.new("TextButton")
MiniButton.Size = UDim2.new(0, 120, 0, 32)
MiniButton.Position = UDim2.new(0, 20, 0.5, -16)
MiniButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MiniButton.Text = "Zenith | Abrir"
MiniButton.TextColor3 = Color3.fromRGB(220, 220, 255)
MiniButton.TextSize = 13
MiniButton.Font = Enum.Font.GothamBold
MiniButton.Visible = false
MiniButton.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 8)
MiniCorner.Parent = MiniButton

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    Main.Visible = false
    MiniButton.Visible = true
end)

MiniButton.MouseButton1Click:Connect(function()
    IsMinimized = false
    Main.Visible = true
    MiniButton.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
end)

--// ESP System
local function ClearESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            elseif typeof(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    ClearESP(player)

    local objects = {}

    -- Highlight (Glow)
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character or player
    objects.Highlight = highlight

    -- Name + Distance
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character and player.Character:FindFirstChild("Head") or player.Character

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Parent = billboard

    objects.Billboard = billboard
    objects.NameLabel = nameLabel
    objects.DistLabel = distLabel

    ESPObjects[player] = objects
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player \~= LocalPlayer and IsAlive(player) then
            if not ESPObjects[player] then
                CreateESP(player)
            end

            local role = GetRole(player)
            local color = Config.Colors.Innocent
            if role == "Murderer" then
                color = Config.Colors.Murderer
                CurrentMurderer = player
            elseif role == "Sheriff" then
                color = Config.Colors.Sheriff
                CurrentSheriff = player
            end

            local objs = ESPObjects[player]
            if objs.Highlight then
                objs.Highlight.Enabled = Config.ESP.Glow
                objs.Highlight.FillColor = color
                objs.Highlight.OutlineColor = color
                objs.Highlight.Adornee = player.Character
            end

            if objs.NameLabel then
                objs.NameLabel.Visible = Config.ESP.Names
                objs.NameLabel.TextColor3 = color
                objs.NameLabel.Text = player.Name .. " [" .. role .. "]"
            end

            if objs.DistLabel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                objs.DistLabel.Visible = Config.ESP.Distance
                objs.DistLabel.TextColor3 = color
                objs.DistLabel.Text = dist .. " studs"
            end
        else
            ClearESP(player)
        end
    end

    -- Actualizar display de roles
    local murdName = CurrentMurderer and CurrentMurderer.Name or "---"
    local sherName = CurrentSheriff and CurrentSheriff.Name or "---"
    RoleDisplay.Text = "Murderer: " .. murdName .. "  |  Sheriff: " .. sherName
    RoleDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
end

--// Skeleton ESP (Drawing)
local SkeletonDrawings = {}

local function DrawSkeleton(player)
    if not Config.ESP.Skeleton then return end
    if not IsAlive(player) or player == LocalPlayer then return end

    local char = player.Character
    if not char then return end

    local role = GetRole(player)
    local color = Config.Colors.Innocent
    if role == "Murderer" then color = Config.Colors.Murderer
    elseif role == "Sheriff" then color = Config.Colors.Sheriff end

    local parts = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }

    if not SkeletonDrawings[player] then
        SkeletonDrawings[player] = {}
    end

    for i, pair in ipairs(parts) do
        local p1 = char:FindFirstChild(pair[1])
        local p2 = char:FindFirstChild(pair[2])
        if p1 and p2 then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(p1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(p2.Position)

            if not SkeletonDrawings[player][i] then
                local line = Drawing.new("Line")
                line.Thickness = 1.5
                line.Transparency = 1
                SkeletonDrawings[player][i] = line
            end

            local line = SkeletonDrawings[player][i]
            if onScreen1 or onScreen2 then
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Color = color
                line.Visible = true
            else
                line.Visible = false
            end
        end
    end
end

local function ClearSkeleton(player)
    if SkeletonDrawings[player] then
        for _, line in pairs(SkeletonDrawings[player]) do
            line:Remove()
        end
        SkeletonDrawings[player] = nil
    end
end

--// Aimlock
local function GetClosestPlayer()
    local closest = nil
    local shortest = Config.Aimlock.FOV
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player \~= LocalPlayer and IsAlive(player) then
            local role = GetRole(player)
            if role == "Murderer" or (role == "Sheriff" and not CurrentMurderer) then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if onScreen and dist < shortest then
                        if Config.Aimlock.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 500)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                            if not hit then
                                shortest = dist
                                closest = player
                            end
                        else
                            shortest = dist
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

--// Main Loop
Connections[#Connections+1] = RunService.RenderStepped:Connect(function()
    -- ESP
    UpdateESP()

    -- Skeleton
    for _, player in pairs(Players:GetPlayers()) do
        if Config.ESP.Skeleton then
            DrawSkeleton(player)
        else
            ClearSkeleton(player)
        end
    end

    -- Aimlock
    if Config.Aimlock.Enabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = target.Character.HumanoidRootPart
            local goal = CFrame.new(Camera.CFrame.Position, root.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, Config.Aimlock.Smoothness)
        end
    end

    -- Speed
    if Config.Movement.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.Movement.SpeedValue
    end

    -- Noclip
    if Config.Movement.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly simple
local FlyBV = nil
Connections[#Connections+1] = RunService.Heartbeat:Connect(function()
    if Config.Movement.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if not FlyBV then
            FlyBV = Instance.new("BodyVelocity")
            FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            FlyBV.Parent = root
        end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        FlyBV.Velocity = dir.Unit * Config.Movement.FlySpeed
    else
        if FlyBV then FlyBV:Destroy() FlyBV = nil end
    end
end)

-- Players leaving
Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
    ClearSkeleton(player)
end)

print("Zenith -- Duelos | HUB -- By Navi | Loaded successfully")