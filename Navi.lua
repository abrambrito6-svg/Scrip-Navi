-- Navi v3 | MVS | filtro por ROL real - solo en partida - hitbox fisico+visual - autofire sin mouse
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local CS=game:GetService("CollectionService")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera

local CFG={ESP=false,HBEsp=false,Auto=false,MaxDist=1200,HBSize=6,POV=120}
local ESP={}
local HBDraw={}
local HBPart={}
local cache={}
local matchActive=false

local ATTRS={"Role","Team","role","team","roleName"}

local function roleKey(s)
    local n=string.lower(s)
    if n:find("murder") or n:find("asesin") then return "M" end
    if n:find("sheriff") or n:find("sherif") then return "S" end
    if n:find("innocent") or n:find("inocen") then return "I" end
end

local function roleOf(p)
    if p.Team and p.Team.Name~="" then
        local k=roleKey(p.Team.Name)
        if k then return k end
    end
    for _,a in ipairs(ATTRS) do
        local v=p:GetAttribute(a)
        if type(v)~="string" and p.Character then v=p.Character:GetAttribute(a) end
        if type(v)=="string" then local k=roleKey(v) if k then return k end end
    end
    local ch=p.Character
    if ch then
        for _,t in ipairs(CS:GetTags(ch)) do local k=roleKey(t) if k then return k end end
        local tool=ch:FindFirstChildOfClass("Tool")
        if tool then
            local n=string.lower(tool.Name)
            if n:find("knife") or n:find("cuchill") then return "M" end
            if n:find("gun") or n:find("pistol") or n:find("revolver") or n:find("sherif") then return "S" end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        local any=false
        for _,p in ipairs(Players:GetPlayers()) do
            cache[p]=roleOf(p)
            if p~=LP and cache[p] then any=true end
        end
        matchActive=(cache[LP]~=nil) or any
        task.wait(0.25)
    end
end)

local function isEnemy(p)
    if p==LP or not p.Parent then return false end
    local r=cache[p]
    if not r then return false end
    local me=cache[LP]
    if me=="M" then return r~="M" end
    return r=="M"
end

-- ===== ESP caja =====
local function makeESP(p)
    if ESP[p] then return end
    local d={Box=Drawing.new("Square"),Name=Drawing.new("Text"),Dist=Drawing.new("Text"),
             Role=Drawing.new("Text"),HP=Drawing.new("Square"),HPbg=Drawing.new("Square"),Tr=Drawing.new("Line")}
    d.Box.Thickness=1 d.Box.Color=Color3.fromRGB(255,60,60)
    d.Name.Size=14 d.Name.Center=true d.Name.Outline=true d.Name.Color=Color3.new(1,1,1)
    d.Dist.Size=12 d.Dist.Center=true d.Dist.Outline=true d.Dist.Color=Color3.fromRGB(220,220,220)
    d.Role.Size=12 d.Role.Center=true d.Role.Outline=true d.Role.Color=Color3.fromRGB(255,200,60)
    d.Tr.Thickness=1 d.Tr.Color=Color3.fromRGB(255,60,60)
    d.HPbg.Filled=true d.HPbg.Color=Color3.fromRGB(30,30,30)
    d.HP.Filled=true d.HP.Color=Color3.fromRGB(0,255,0)
    ESP[p]=d
end

-- ===== Hitbox visual (cubo 3D) =====
local EDGES={{1,2},{2,4},{4,3},{3,1},{5,6},{6,8},{8,7},{7,5},{1,5},{2,6},{3,7},{4,8}}
local function makeHB(p)
    if HBDraw[p] then return end
    local t={Lbl=Drawing.new("Text"),Edges={}}
    t.Lbl.Size=11 t.Lbl.Center=true t.Lbl.Outline=true t.Lbl.Color=Color3.fromRGB(255,255,0) t.Lbl.Text="HITBOX"
    for i=1,12 do
        local l=Drawing.new("Line")
        l.Thickness=1.5 l.Color=Color3.fromRGB(255,255,0)
        t.Edges[i]=l
    end
    HBDraw[p]=t
end

local function hide(t)
    for _,v in pairs(t) do
        if type(v)=="table" then for _,x in pairs(v) do x.Visible=false end
        else v.Visible=false end
    end
end

local function cubePoints(cf,size)
    local h=size/2 local pts={} local i=1
    for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
        pts[i]=cf*Vector3.new(x*h,y*h,z*h) i=i+1
    end end end
    return pts
end

-- ===== Hitbox fisico =====
local function hbPart(p)
    local part=HBPart[p]
    if part and part.Parent then return part end
    part=Instance.new("Part")
    part.Name="NaviHitbox"
    part.Anchored=true
    part.CanCollide=false
    part.CanQuery=true
    part.CanTouch=false
    part.Transparency=0.82
    part.Color=Color3.fromRGB(255,255,0)
    part.Material=Enum.Material.ForceField
    part.Size=Vector3.new(CFG.HBSize,CFG.HBSize,CFG.HBSize)
    part.Parent=WS
    HBPart[p]=part
    return part
end

local function clearHB(p)
    if HBPart[p] then HBPart[p]:Destroy() HBPart[p]=nil end
end

-- ===== Loop principal =====
local function updateESP()
    if not (matchActive and CFG.ESP) then
        for _,d in pairs(ESP) do hide(d) end
        return
    end
    for p,d in pairs(ESP) do
        local ch=p.Character
        local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if not ch or not hum or not hrp or not isEnemy(p) then
            hide(d)
        else
            local pos,on=Cam:WorldToViewportPoint(hrp.Position)
            local dist=(hrp.Position-Cam.CFrame.Position).Magnitude
            if not on or dist>CFG.MaxDist then
                hide(d)
            else
                local s=1900/dist
                local w=s*0.62 local hh=s*1.25
                local x=pos.X-w/2 local y=pos.Y-hh/2
                d.Box.Size=Vector2.new(w,hh) d.Box.Position=Vector2.new(x,y) d.Box.Visible=true
                d.Name.Position=Vector2.new(pos.X,y-34) d.Name.Text=p.Name d.Name.Visible=true
                d.Role.Position=Vector2.new(pos.X,y-20)
                d.Role.Text=(cache[p]=="M" and "MURDERER" or "SHERIFF") d.Role.Visible=true
                d.Dist.Position=Vector2.new(pos.X,y+hh+5) d.Dist.Text=math.floor(dist).."m" d.Dist.Visible=true
                local hp=hum.Health/hum.MaxHealth
                d.HPbg.Size=Vector2.new(w+4,5) d.HPbg.Position=Vector2.new(x-2,y-8) d.HPbg.Visible=true
                d.HP.Size=Vector2.new((w+4)*hp,5) d.HP.Position=Vector2.new(x-2,y-8)
                d.HP.Color=Color3.fromRGB(255*(1-hp),255*hp,0) d.HP.Visible=true
                d.Tr.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
                d.Tr.To=Vector2.new(pos.X,pos.Y+hh/2) d.Tr.Visible=true
            end
        end
    end
end

local function updateHB()
    if not (matchActive and CFG.HBEsp) then
        for _,t in pairs(HBDraw) do hide(t) end
        for p in pairs(HBPart) do clearHB(p) end
        return
    end
    for p,t in pairs(HBDraw) do
        local ch=p.Character
        local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if not ch or not hrp or not isEnemy(p) then
            hide(t) clearHB(p)
        else
            local dist=(hrp.Position-Cam.CFrame.Position).Magnitude
            if dist>CFG.MaxDist then
                hide(t) clearHB(p)
            else
                local part=hbPart(p)
                part.Size=Vector3.new(CFG.HBSize,CFG.HBSize,CFG.HBSize)
                part.CFrame=hrp.CFrame
                local pts=cubePoints(hrp.CFrame,CFG.HBSize)
                for i,e in ipairs(EDGES) do
                    local a,onA=Cam:WorldToViewportPoint(pts[e[1]])
                    local b,onB=Cam:WorldToViewportPoint(pts[e[2]])
                    local l=t.Edges[i]
                    if onA and onB then
                        l.From=Vector2.new(a.X,a.Y) l.To=Vector2.new(b.X,b.Y) l.Visible=true
                    else l.Visible=false end
                end
                local top,onT=Cam:WorldToViewportPoint(hrp.Position+Vector3.new(0,CFG.HBSize/2+0.7,0))
                t.Lbl.Position=Vector2.new(top.X,top.Y-14)
                t.Lbl.Text="HITBOX "..CFG.HBSize
                t.Lbl.Visible=onT
            end
        end
    end
end

-- ===== Autofire sin mouse =====
local lastShot=0
local function getTarget()
    local best,bd=nil,CFG.MaxDist
    for _,p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health>0 then
                local sp,on=Cam:WorldToViewportPoint(hrp.Position)
                local d=(hrp.Position-Cam.CFrame.Position).Magnitude
                if on and d<bd and sp.Z>0 then bd=d best=hrp end
            end
        end
    end
    return best
end

local function autoFire()
    if not (matchActive and CFG.Auto) then return end
    if os.clock()<lastShot then return end
    local t=getTarget()
    if not t then return end
    local from=Cam.CFrame.Position
    Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(from,t.Position),0.45)
    local tool=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
        lastShot=os.clock()+0.14
    else
        lastShot=os.clock()+0.1
    end
end

for _,p in ipairs(Players:GetPlayers()) do
    if p~=LP then makeESP(p) makeHB(p) end
end
Players.PlayerAdded:Connect(function(p) if p~=LP then makeESP(p) makeHB(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then for _,v in pairs(ESP[p]) do v:Remove() end ESP[p]=nil end
    if HBDraw[p] then
        HBDraw[p].Lbl:Remove()
        for _,l in ipairs(HBDraw[p].Edges) do l:Remove() end
        HBDraw[p]=nil
    end
    clearHB(p) cache[p]=nil
end)

RS.RenderStepped:Connect(function()
    updateESP()
    updateHB()
    autoFire()
end)

if Cam then Cam.FieldOfView=CFG.POV end

-- ===== UI =====
local gui=Instance.new("ScreenGui")
gui.Name="NaviV3" gui.ResetOnSpawn=false gui.Parent=game:GetService("CoreGui")

local fr=Instance.new("Frame")
fr.Size=UDim2.new(0,215,0,300) fr.Position=UDim2.new(0,18,0,90)
fr.BackgroundColor3=Color3.fromRGB(18,18,22) fr.BorderSizePixel=0 fr.Active=true fr.Parent=gui
Instance.new("UICorner",fr).CornerRadius=UDim.new(0,9)

local ttl=Instance.new("TextLabel")
ttl.Size=UDim2.new(1,0,0,30) ttl.BackgroundColor3=Color3.fromRGB(32,32,40)
ttl.Text="Navi v3 | MVS" ttl.TextColor3=Color3.new(1,1,1)
ttl.Font=Enum.Font.GothamBold ttl.TextSize=14 ttl.Parent=fr
Instance.new("UICorner",ttl).CornerRadius=UDim.new(0,9)

local st=Instance.new("TextLabel")
st.Size=UDim2.new(1,-16,0,18) st.Position=UDim2.new(0,8,0,32)
st.BackgroundTransparency=1 st.Text="Estado: lobby" st.TextColor3=Color3.fromRGB(150,150,160)
st.Font=Enum.Font.GothamBold st.TextSize=11 st.Parent=fr
task.spawn(function()
    while true do
        st.Text="Estado: "..(matchActive and "EN PARTIDA" or "lobby")
        st.TextColor3=matchActive and Color3.fromRGB(0,220,120) or Color3.fromRGB(150,150,160)
        task.wait(0.3)
    end
end)

local function toggle(txt,y,key)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-16,0,32) b.Position=UDim2.new(0,8,0,y)
    b.BackgroundColor3=Color3.fromRGB(45,45,55) b.Text=txt..": OFF"
    b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=12 b.Parent=fr
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]
        b.BackgroundColor3=CFG[key] and Color3.fromRGB(0,110,60) or Color3.fromRGB(45,45,55)
        b.Text=txt..": "..(CFG[key] and "ON" or "OFF")
    end)
end

toggle("ESP Enemigos",54,"ESP")
toggle("Hitbox Visual",90,"HBEsp")
toggle("Auto Disparar",126,"Auto")

local lb=Instance.new("TextLabel")
lb.Size=UDim2.new(1,-16,0,18) lb.Position=UDim2.new(0,8,0,164)
lb.BackgroundTransparency=1 lb.Text="Hitbox: 6" lb.TextColor3=Color3.fromRGB(255,255,0)
lb.Font=Enum.Font.GothamBold lb.TextSize=11 lb.Parent=fr

local function stepBtn(txt,y,delta)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,96,0,26) b.Position=UDim2.new(0,8+(delta>0 and 102 or 0),0,y)
    b.BackgroundColor3=Color3.fromRGB(45,45,55) b.Text=txt
    b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=11 b.Parent=fr
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        CFG.HBSize=math.clamp(CFG.HBSize+delta,1,40)
        lb.Text="Hitbox: "..CFG.HBSize
    end)
end
stepBtn("-",184,-1)
stepBtn("+",184,1)

local pb=Instance.new("TextButton")
pb.Size=UDim2.new(1,-16,0,26) pb.Position=UDim2.new(0,8,0,216)
pb.BackgroundColor3=Color3.fromRGB(45,45,55) pb.Text="POV: "..CFG.POV
pb.TextColor3=Color3.new(1,1,1) pb.Font=Enum.Font.GothamBold pb.TextSize=11 pb.Parent=fr
Instance.new("UICorner",pb).CornerRadius=UDim.new(0,6)
pb.MouseButton1Click:Connect(function()
    CFG.POV=CFG.POV+10 if CFG.POV>140 then CFG.POV=70 end
    if Cam then Cam.FieldOfView=CFG.POV end
    pb.Text="POV: "..CFG.POV
end)

local ds=Instance.new("TextButton")
ds.Size=UDim2.new(1,-16,0,26) ds.Position=UDim2.new(0,8,0,248)
ds.BackgroundColor3=Color3.fromRGB(45,45,55) ds.Text="Distancia max: "..CFG.MaxDist
ds.TextColor3=Color3.new(1,1,1) ds.Font=Enum.Font.GothamBold ds.TextSize=11 ds.Parent=fr
Instance.new("UICorner",ds).CornerRadius=UDim.new(0,6)
ds.MouseButton1Click:Connect(function()
    CFG.MaxDist=CFG.MaxDist+300 if CFG.MaxDist>3000 then CFG.MaxDist=300 end
    ds.Text="Distancia max: "..CFG.MaxDist
end)

-- arrastrar
local drag,dip,dsp
ttl.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true dip=i dsp=i.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
ttl.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dip=i end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i==dip then
        local d=i.Position-dsp
        fr.Position=UDim2.new(0,fr.Position.X.Offset+d.X,0,fr.Position.Y.Offset+d.Y)
        dsp=i.Position
    end
end)

print("[Navi v3] cargado - estado:", matchActive)