--[[
    Zenith -- Duelos | HUB -- By Navi
    Versión estable
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Config
local Config = {
    ESP = {
        Glow = true,
        Names = true,
        Distance = true,
        Tracers = false
    },
    Aimlock = {
        Enabled = false,
        Smoothness = 0.18
    },
    Movement = {
        Fly = false,
        FlySpeed = 50,
        Speed = false,
        SpeedValue = 22,
        Noclip = false
    },
    Colors = {
        Murderer = Color3.fromRGB(255, 50, 50),
        Sheriff = Color3.fromRGB(50, 130, 255),
        Innocent = Color3.fromRGB(255, 255, 255)
    }
}

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ZenithESP"
ESPFolder.Parent = game.CoreGui

-- Crear GUI
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZenithHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 420, 0, 320)
    Main.Position = UDim2.new(0.5, -210, 0.5, -160)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Main

    -- Título
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 0, 36)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Zenith -- Duelos | HUB -- By Navi"
    Title.TextColor3 = Color3.fromRGB(220, 220, 255)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Main

    -- Botón Minimizar
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 3)
    MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Parent = Main

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn

    -- Botón Cerrar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Main

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Role Display
    local RoleLabel = Instance.new("TextLabel")
    RoleLabel.Name = "RoleLabel"
    RoleLabel.Size = UDim2.new(1, -20, 0, 32)
    RoleLabel.Position = UDim2.new(0, 10, 0, 42)
    RoleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    RoleLabel.Text = "Murderer: ---  |  Sheriff: ---"
    RoleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    RoleLabel.TextSize = 14
    RoleLabel.Font = Enum.Font.Gotham
    RoleLabel.Parent = Main

    local RoleCorner = Instance.new("UICorner")
    RoleCorner.CornerRadius = UDim.new(0, 6)
    RoleCorner.Parent = RoleLabel

    -- Contenedor de toggles
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -85)
    Container.Position = UDim2.new(0, 10, 0, 80)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 3
    Container.CanvasSize = UDim2.new(0, 0, 0, 420)
    Container.Parent = Main

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 5)
    List.Parent = Container

    -- Función crear toggle
    local function AddToggle(text, default, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
        Frame.Parent = Container

        local FCorner = Instance.new("UICorner")
        FCorner.CornerRadius = UDim.new(0, 6)
        FCorner.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -55, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(230, 230, 240)
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 40, 0, 20)
        Btn.Position = UDim2.new(1, -48, 0.5, -10)
        Btn.BackgroundColor3 = default and Color3.fromRGB(100, 60, 220) or Color3.fromRGB(55, 55, 65)
        Btn.Text = ""
        Btn.Parent = Frame

        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(1, 0)
        BCorner.Parent = Btn

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Parent = Btn

        local CCorner = Instance.new("UICorner")
        CCorner.CornerRadius = UDim.new(1, 0)
        CCorner.Parent = Circle

        local enabled = default
        Btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            Btn.BackgroundColor3 = enabled and Color3.fromRGB(100, 60, 220) or Color3.fromRGB(55, 55, 65)
            Circle:TweenPosition(enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            callback(enabled)
        end)
    end

    -- Toggles
    AddToggle("ESP Glow", true, function(v) Config.ESP.Glow = v end)
    AddToggle("Ver Nombres", true, function(v) Config.ESP.Names = v end)
    AddToggle("Ver Distancia", true, function(v) Config.ESP.Distance = v end)
    AddToggle("Aimlock", false, function(v) Config.Aimlock.Enabled = v end)
    AddToggle("Volar (Fly)", false, function(v) Config.Movement.Fly = v end)
    AddToggle("Caminar Rápido", false, function(v) Config.Movement.Speed = v end)
    AddToggle("Noclip", false, function(v) Config.Movement.Noclip = v end)

    -- Minimizar
    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 110, 0, 30)
    MiniBtn.Position = UDim2.new(0, 15, 0.5, -15)
    MiniBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    MiniBtn.Text = "Zenith | Abrir"
    MiniBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
    MiniBtn.TextSize = 13
    MiniBtn.Font = Enum.Font.GothamBold
    MiniBtn.Visible = false
    MiniBtn.Parent = ScreenGui

    local MiniCorner = Instance.new("UICorner")
    MiniCorner.CornerRadius = UDim.new(0, 8)
    MiniCorner.Parent = MiniBtn

    MinBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        MiniBtn.Visible = true
    end)

    MiniBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        MiniBtn.Visible = false
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        ESPFolder:Destroy()
    end)

    return ScreenGui, RoleLabel
end

local ScreenGui, RoleLabel = CreateGUI()

-- Detectar rol
local function GetRole(player)
    if not player.Character then return "Innocent" end
    local char = player.Character

    if char:FindFirstChild("Knife") then
        return "Murderer"
    end
    if char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then
        return "Sheriff"
    end
    return "Innocent"
end

-- ESP
local function ClearESP(player)
    local esp = ESPFolder:FindFirstChild(player.Name)
    if esp then
        esp:Destroy()
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    ClearESP(player)

    local char = player.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.Parent = ESPFolder
    highlight.Adornee = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Billboard"
    billboard.Size = UDim2.new(0, 160, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char:FindFirstChild("Head") or char

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.45, 0)
    distLabel.Position = UDim2.new(0, 0, 0.55, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.4
    distLabel.Parent = billboard

    return highlight, nameLabel, distLabel
end

-- Loop principal
local CurrentMurderer, CurrentSheriff = nil, nil

RunService.RenderStepped:Connect(function()
    CurrentMurderer = nil
    CurrentSheriff = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player \~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local role = GetRole(player)
            local color = Config.Colors.Innocent

            if role == "Murderer" then
                color = Config.Colors.Murderer
                CurrentMurderer = player
            elseif role == "Sheriff" then
                color = Config.Colors.Sheriff
                CurrentSheriff = player
            end

            local highlight = ESPFolder:FindFirstChild(player.Name)
            if not highlight then
                CreateESP(player)
                highlight = ESPFolder:FindFirstChild(player.Name)
            end

            if highlight then
                highlight.Enabled = Config.ESP.Glow
                highlight.FillColor = color
                highlight.OutlineColor = color
            end

            local billboard = player.Character and player.Character:FindFirstChild("Billboard")
            if billboard then
                local nameLabel = billboard:FindFirstChildOfClass("TextLabel")
                if nameLabel then
                    nameLabel.Visible = Config.ESP.Names
                    nameLabel.TextColor3 = color
                    nameLabel.Text = player.Name .. " [" .. role .. "]"
                end
            end
        else
            ClearESP(player)
        end
    end

    -- Actualizar texto de roles
    local mName = CurrentMurderer and CurrentMurderer.Name or "---"
    local sName = CurrentSheriff and CurrentSheriff.Name or "---"
    RoleLabel.Text = "Murderer: " .. mName .. "   |   Sheriff: " .. sName

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

    -- Aimlock simple
    if Config.Aimlock.Enabled and CurrentMurderer and CurrentMurderer.Character and CurrentMurderer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = CurrentMurderer.Character.HumanoidRootPart.Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Config.Aimlock.Smoothness)
    end
end)

-- Fly
local BodyVel = nil
RunService.Heartbeat:Connect(function()
    if Config.Movement.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if not BodyVel or BodyVel.Parent == nil then
            BodyVel = Instance.new("BodyVelocity")
            BodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVel.Parent = root
        end

        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-1,0) end

        if move.Magnitude > 0 then
            BodyVel.Velocity = move.Unit * Config.Movement.FlySpeed
        else
            BodyVel.Velocity = Vector3.zero
        end
    else
        if BodyVel then
            BodyVel:Destroy()
            BodyVel = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)

print("✅ Zenith -- Duelos | HUB -- By Navi cargado correctamente")