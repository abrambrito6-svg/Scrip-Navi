-- Navi.lua | MVS | Sin aliados - Solo en partida - Hitbox - POV - AutoFire estable
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local VIM=game:GetService("VirtualInputManager")
local LP=Players.LocalPlayer
local Cam=Workspace.CurrentCamera
local inGame=false
local myTeam=nil
local CFG={ESP=false,Auto=false,Hitbox=false,MaxDist=1000,Expand=5,POV=120}
local ESP={}
local HB={}
local Tracer={}

local function isEnemy(p)
    if p==LP then return false end
    local t=p.Team and p.Team.Name or "None"
    if myTeam==nil or myTeam=="None" or t=="None" then return true end
    return t~=myTeam
end

local function stateCheck()
    local c=LP.Character
    if not c then inGame=false return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health<=0 then inGame=false return end
    myTeam=LP.Team and LP.Team.Name or "None"
    inGame=true
end

local function makeESP(p)
    if ESP[p] then return end
    ESP[p]={
        Box=Drawing.new("Square"),Name=Drawing.new("Text"),
        Dist=Drawing.new("Text"),HP=Drawing.new("Square"),
        HPbg=Drawing.new("Square"),Tr=Drawing.new("Line")
    }
    local d=ESP[p]
    d.Box.Thickness=1 d.Box.Filled=false d.Box.Color=Color3.fromRGB(255,0,0)
    d.Name.Size=14 d.Name.Center=true d.Name.Outline=true d.Name.Color=Color3.fromRGB(255,255,255)
    d.Dist.Size=12 d.Dist.Center=true d.Dist.Outline=true d.Dist.Color=Color3.fromRGB(200,200,200)
    d.Tr.Thickness=1 d.Tr.Color=Color3.fromRGB(255,0,0)
    d.HPbg.Filled=true d.HPbg.Color=Color3.fromRGB(40,40,40)
    d.HP.Filled=true d.HP.Color=Color3.fromRGB(0,255,0)
end

local function makeHB(p)
    if HB[p] then return end
    HB[p]={Box=Drawing.new("Square"),Lbl=Drawing.new("Text"),Top=Drawing.new("Text")}
    local d=HB[p]
    d.Box.Thickness=2 d.Box.Filled=false d.Box.Color=Color3.fromRGB(255,255,0)
    d.Lbl.Size=11 d.Lbl.Center=true d.Lbl.Outline=true d.Lbl.Color=Color3.fromRGB(255,255,0)
    d.Lbl.Text="HITBOX"
    d.Top.Size=10 d.Top.Center=true d.Top.Outline=true d.Top.Color=Color3.fromRGB(255,200,0)
end

local function hideAll(tbl)
    for _,d in pairs(tbl) do
        for _,v in pairs(d) do v.Visible=false end
    end
end

local function updateESP()
    if not inGame then hideAll(ESP) hideAll(HB) return end
    for p,d in pairs(ESP) do
        local c=p.Character
        local h=c and c:FindFirstChildOfClass("Humanoid")
        local r=c and c:FindFirstChild("HumanoidRootPart")
        if not CFG.ESP or not c or not h or not r or not isEnemy(p) then
            for _,v in pairs(d) do v.Visible=false end
        else
            local pos,on=Cam:WorldToViewportPoint(r.Position)
            local dist=(r.Position-Cam.CFrame.Position).Magnitude
            if not on or dist>CFG.MaxDist then
                for _,v in pairs(d) do v.Visible=false end
            else
                local s=2000/dist
                local w=s*0.6 local hgt=s*1.2
                local x=pos.X-w/2 local y=pos.Y-hgt/2
                d.Box.Size=Vector2.new(w,hgt) d.Box.Position=Vector2.new(x,y) d.Box.Visible=true
                d.Name.Position=Vector2.new(pos.X,y-20) d.Name.Text=p.Name d.Name.Visible=true
                d.Dist.Position=Vector2.new(pos.X,y+hgt+5) d.Dist.Text=math.floor(dist).."m" d.Dist.Visible=true
                local hp=h.Health/h.MaxHealth
                d.HPbg.Size=Vector2.new(w+4,6) d.HPbg.Position=Vector2.new(x-2,y-10) d.HPbg.Visible=true
                d.HP.Size=Vector2.new((w+4)*hp,6) d.HP.Position=Vector2.new(x-2,y-10)
                d.HP.Color=Color3.fromRGB(255*(1-hp),255*hp,0) d.HP.Visible=true
                d.Tr.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
                d.Tr.To=Vector2.new(pos.X,pos.Y+hgt/2) d.Tr.Visible=true
            end
        end
    end
    for p,d in pairs(HB) do
        local c=p.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        if not CFG.Hitbox or not r or not isEnemy(p) then
            for _,v in pairs(d) do v.Visible=false end
        else
            local pos,on=Cam:WorldToViewportPoint(r.Position)
            local dist=(r.Position-Cam.CFrame.Position).Magnitude
            if not on then
                for _,v in pairs(d) do v.Visible=false end
            else
                local sz=((CFG.Expand*2)+4)*100/dist
                d.Box.Size=Vector2.new(sz,sz) d.Box.Position=Vector2.new(pos.X-sz/2,pos.Y-sz/2) d.Box.Visible=true
                d.Lbl.Position=Vector2.new(pos.X,pos.Y-sz/2-15) d.Lbl.Text="HITBOX +"..CFG.Expand d.Lbl.Visible=true
                d.Top.Position=Vector2.new(pos.X,pos.Y+sz/2+5) d.Top.Text="Size: "..((CFG.Expand*2)+4) d.Top.Visible=true
            end
        end
    end
end

local function getTarget()
    local best=nil local bd=math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health>0 then
                local _,on=Cam:WorldToViewportPoint(r.Position)
                local d=(r.Position-Cam.CFrame.Position).Magnitude
                if on and d<bd and d<CFG.MaxDist then bd=d best=r end
            end
        end
    end
    return best
end

local fireCD=0
local function autoFire()
    if not CFG.Auto or not inGame then return end
    if tick()<fireCD then return end
    local t=getTarget()
    if t then
        local dir=(t.Position-Cam.CFrame.Position).Unit
        local aim=CFrame.new(Cam.CFrame.Position,Cam.CFrame.Position+dir)
        Cam.CFrame=Cam.CFrame:Lerp(aim,0.35)
        VIM:SendMouseButtonEvent(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2,0,true,game,1)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2,0,false,game,1)
        fireCD=tick()+0.12
    end
end

-- Inicializar
for _,p in pairs(Players:GetPlayers()) do if p~=LP then makeESP(p) makeHB(p) end end
Players.PlayerAdded:Connect(function(p) if p~=LP then makeESP(p) makeHB(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then for _,v in pairs(ESP[p]) do v:Remove() end ESP[p]=nil end
    if HB[p] then for _,v in pairs(HB[p]) do v:Remove() end HB[p]=nil end
end)

RunService.RenderStepped:Connect(function()
    stateCheck()
    updateESP()
    autoFire()
end)

-- POV (zoom out del campo de visión)
local function setPOV(v)
    CFG.POV=v
    if Cam then Cam.FieldOfView=v end
end
setPOV(120)

-- ===== UI =====
local gui=Instance.new("ScreenGui")
gui.Name="NaviGUI" gui.ResetOnSpawn=false
gui.Parent=game:GetService("CoreGui")

local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,200,0,240)
frame.Position=UDim2.new(0,20,0,100)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,8) corner.Parent=frame

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,32)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.Text="Navi | MVS" title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold title.TextSize=15
title.Parent=frame
local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(0,8) tc.Parent=title

-- arrastrar
local dragging,dragInput,dragStart
title.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true dragInput=i dragStart=i.Position
        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
title.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput=i end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i==dragInput then
        local delta=i.Position-dragStart
        frame.Position=UDim2.new(0,frame.Position.X.Offset+delta.X,0,frame.Position.Y.Offset+delta.Y)
        dragStart=i.Position
    end
end)

local function addToggle(text,y,key,default)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-16,0,34)
    b.Position=UDim2.new(0,8,0,y)
    b.BackgroundColor3=default and Color3.fromRGB(0,120,60) or Color3.fromRGB(45,45,55)
    b.Text=text..": "..(default and "ON" or "OFF")
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold b.TextSize=13
    b.Parent=frame
    local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,6) bc.Parent=b
    b.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]
        b.BackgroundColor3=CFG[key] and Color3.fromRGB(0,120,60) or Color3.fromRGB(45,45,55)
        b.Text=text..": "..(CFG[key] and "ON" or "OFF")
    end)
end

addToggle("ESP Enemigos",44,"ESP",false)
addToggle("Hitbox ESP",82,"Hitbox",false)
addToggle("Auto Disparar",120,"Auto",false)

-- Slider hitbox
local hl=Instance.new("TextLabel")
hl.Size=UDim2.new(1,-16,0,20)
hl.Position=UDim2.new(0,8,0,160)
hl.BackgroundTransparency=1 hl.Text="Hitbox Size: 5"
hl.TextColor3=Color3.fromRGB(255,255,0) hl.Font=Enum.Font.GothamBold hl.TextSize=12
hl.Parent=frame
local hs=Instance.new("TextButton")
hs.Size=UDim2.new(1,-16,0,28)
hs.Position=UDim2.new(0,8,0,182)
hs.BackgroundColor3=Color3.fromRGB(45,45,55) hs.Text="+ Aumentar  (toca = +1)"
hs.TextColor3=Color3.fromRGB(255,255,255) hs.Font=Enum.Font.GothamBold hs.TextSize=12
hs.Parent=frame
local hsc=Instance.new("UICorner") hsc.CornerRadius=UDim.new(0,6) hsc.Parent=hs
hs.MouseButton1Click:Connect(function()
    CFG.Expand=CFG.Expand+1
    if CFG.Expand>20 then CFG.Expand=1 end
    hl.Text="Hitbox Size: "..CFG.Expand
end)
local hs2=Instance.new("TextButton")
hs2.Size=UDim2.new(0,90,0,24)
hs2.Position=UDim2.new(0,8,0,214)
hs2.BackgroundColor3=Color3.fromRGB(45,45,55) hs2.Text="- Reducir"
hs2.TextColor3=Color3.fromRGB(255,255,255) hs2.Font=Enum.Font.GothamBold hs2.TextSize=11
hs2.Parent=frame
local hs2c=Instance.new("UICorner") hs2c.CornerRadius=UDim.new(0,6) hs2c.Parent=hs2
hs2.MouseButton1Click:Connect(function()
    CFG.Expand=CFG.Expand-1
    if CFG.Expand<1 then CFG.Expand=1 end
    hl.Text="Hitbox Size: "..CFG.Expand
end)

print("[Navi] Cargado")