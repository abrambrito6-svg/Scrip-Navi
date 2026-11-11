-- Navi v4 | MVS | rol por inventario - partida por timer - dispara con la PISTOLA - panel minimizable
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local CS=game:GetService("CollectionService")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera

local CFG={ESP=false,HBEsp=false,Auto=false,Melee=false,MaxDist=1200,HBSize=6,POV=120}
local ESP={}
local HBDraw={}
local HBPart={}
local cache={}
local inRound=false

local function roleKey(s)
    local n=string.lower(tostring(s))
    if n:find("murder") or n:find("asesin") then return "M" end
    if n:find("sheriff") or n:find("sherif") then return "S" end
    if n:find("innocent") or n:find("inocen") then return "I" end
end

local function isGun(n)
    n=string.lower(n)
    return n:find("gun") or n:find("pistol") or n:find("revolver") or n:find("sherif") or n:find("pistola")
end
local function isKnife(n)
    n=string.lower(n)
    return n:find("knife") or n:find("cuchill") or n:find("dagger")
end

local function scanTools(p)
    local gun,knife=false,false
    local function check(cont)
        if not cont then return end
        for _,o in ipairs(cont:GetChildren()) do
            if o:IsA("Tool") then
                if isGun(o.Name) then gun=true end
                if isKnife(o.Name) then knife=true end
            end
        end
    end
    check(p.Character)
    check(p:FindFirstChild("Backpack"))
    if gun then return "S" end
    if knife then return "M" end
end

local ATTRS={"Role","Team","role","team","RoleName","TeamName","Class","class"}
local function roleOf(p)
    if p.Team and p.Team.Name~="" then
        local k=roleKey(p.Team.Name) if k then return k end
    end
    for _,a in ipairs(ATTRS) do
        local v=p:GetAttribute(a)
        if type(v)~="string" and p.Character then v=p.Character:GetAttribute(a) end
        if type(v)=="string" then local k=roleKey(v) if k then return k end end
    end
    for _,c in ipairs(p:GetChildren()) do
        if c:IsA("StringValue") or c:IsA("IntValue") then
            local k=roleKey(c.Name) or roleKey(c.Value)
            if k then return k end
        end
    end
    local ch=p.Character
    if ch then
        for _,t in ipairs(CS:GetTags(ch)) do local k=roleKey(t) if k then return k end end
        for _,c in ipairs(ch:GetChildren()) do
            if c:IsA("StringValue") then local k=roleKey(c.Value) if k then return k end end
        end
    end
    return scanTools(p)
end

-- temporizador de ronda en pantalla => estamos en partida
local function roundTimerOn()
    local pg=LP:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _,d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") and d.Visible then
            local t=d.Text
            if #t==5 and t:match("^%d%d:%d%d$") then return true end
        end
    end
    return false
end

task.spawn(function()
    while true do
        local any=false
        for _,p in ipairs(Players:GetPlayers()) do
            cache[p]=roleOf(p)
            if p~=LP and cache[p] then any=true end
        end
        inRound=roundTimerOn() and (cache[LP]~=nil or any)
        task.wait(0.3)
    end
end)

local function isEnemy(p)
    if p==LP or not p.Parent then return false end
    local r=cache[p]
    if not r then return false end
    local me=cache[LP]
    if me=="M" then return r~="M" end
    if me=="S" or me=="I" then return r=="M" end
    return true
end

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

local function hbPart(p)
    local part=HBPart[p]
    if part and part.Parent then return part end
    part=Instance.new("Part")
    part.Name="NaviHitbox" part.Anchored=true part.CanCollide=false
    part.CanQuery=true part.CanTouch=false part.Transparency=0.82
    part.Color=Color3.fromRGB(255,255,0) part.Material=Enum.Material.ForceField
    part.Size=Vector3.new(CFG.HBSize,CFG.HBSize,CFG.HBSize)
    part.Parent=WS
    HBPart[p]=part
    return part
end
local function clearHB(p) if HBPart[p] then HBPart[p]:Destroy() HBPart[p]=nil end end

local function updateESP()
    if not (inRound and CFG.ESP) then
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
                d.Role.Text=(cache[p]=="M" and "MURDERER" or (cache[p]=="S" and "SHERIFF" or "?"))
                d.Role.Visible=true
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
    if not (inRound and CFG.HBEsp) then
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

-- ===== armas =====
local function findTool(pred)
    local ch=LP.Character
    if ch then
        for _,o in ipairs(ch:GetChildren()) do
            if o:IsA("Tool") and pred(o.Name) then return o,true end
        end
    end
    local bp=LP:FindFirstChild("Backpack")
    if bp then
        for _,o in ipairs(bp:GetChildren()) do
            if o:IsA("Tool") and pred(o.Name) then return o,false end
        end
    end
end

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

local lastShot=0
local equipping=false
local function autoFire()
    if not (inRound and (CFG.Auto or CFG.Melee)) then return end
    if os.clock()<lastShot then return end
    local t=getTarget()
    if not t then return end
    local ch=LP.Character
    local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.45)
    local tool,equipped
    if CFG.Auto then
        tool,equipped=findTool(isGun)
        if not tool and CFG.Melee then tool,equipped=findTool(isKnife) end
    elseif CFG.Melee then
        tool,equipped=findTool(isKnife)
    end
    if not tool then lastShot=os.clock()+0.15 return end
    if not equipped then
        if equipping then return end
        equipping=true
        pcall(function() hum:EquipTool(tool) end)
        task.delay(0.15,function() equipping=false end)
        lastShot=os.clock()+0.25
        return
    end
    pcall(function() tool:Activate() end)
    lastShot=os.clock()+(CFG.Auto and 0.14 or 0.5)
end

for _,p in ipairs(Players:GetPlayers()) do if p~=LP then makeESP(p) makeHB(p) end end
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
gui.Name="NaviV4" gui.ResetOnSpawn=false gui.Parent=game:GetService("CoreGui")

local fr=Instance.new("Frame")
fr.Size=UDim2.new(0,215,0,392) fr.Position=UDim2.new(0,18,0,90)
fr.BackgroundColor3=Color3.fromRGB(18,18,22) fr.BorderSizePixel=0 fr.Active=true fr.Parent=gui
Instance.new("UICorner",fr).CornerRadius=UDim.new(0,9)

local ttl=Instance.new("TextLabel")
ttl.Size=UDim2.new(1,-58,0,30) ttl.BackgroundColor3=Color3.fromRGB(32,32,40)
ttl.Text="Navi v4 | MVS" ttl.TextColor3=Color3.new(1,1,1)
ttl.Font=Enum.Font.GothamBold ttl.TextSize=14 ttl.Parent=fr
Instance.new("UICorner",ttl).CornerRadius=UDim.new(0,9)

local minBtn=Instance.new("TextButton")
minBtn.Size=UDim2.new(0,26,0,26) minBtn.Position=UDim2.new(1,-54,0,2)
minBtn.BackgroundColor3=Color3.fromRGB(50,50,60) minBtn.Text="-" minBtn.TextColor3=Color3.new(1,1,1)
minBtn.Font=Enum.Font.GothamBold minBtn.TextSize=16 minBtn.Parent=fr
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,6)

local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,26,0,26) closeBtn.Position=UDim2.new(1,-26,0,2)
closeBtn.BackgroundColor3=Color3.fromRGB(60,45,45) closeBtn.Text="x" closeBtn.TextColor3=Color3.new(1,1,1)
closeBtn.Font=Enum.Font.GothamBold closeBtn.TextSize=14 closeBtn.Parent=fr
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)

local st=Instance.new("TextLabel")
st.Size=UDim2.new(1,-16,0,16) st.Position=UDim2.new(0,8,0,31)
st.BackgroundTransparency=1 st.Text="Estado: lobby | Rol: ?" st.TextColor3=Color3.fromRGB(150,150,160)
st.Font=Enum.Font.GothamBold st.TextSize=11 st.Parent=fr
task.spawn(function()
    while true do
        local me=cache[LP]
        local rn=me=="M" and "Murderer" or (me=="S" and "Sheriff" or (me=="I" and "Innocent" or "?"))
        st.Text="Estado: "..(inRound and "EN PARTIDA" or "lobby").." | Rol: "..rn
        st.TextColor3=inRound and Color3.fromRGB(0,220,120) or Color3.fromRGB(150,150,160)
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

toggle("ESP Enemigos",51,"ESP")
toggle("Hitbox Visual",87,"HBEsp")
toggle("Auto Disparar (pistola)",123,"Auto")
toggle("Auto Cuchillo",159,"Melee")

local lb=Instance.new("TextLabel")
lb.Size=UDim2.new(1,-16,0,18) lb.Position=UDim2.new(0,8,0,196)
lb.BackgroundTransparency=1 lb.Text="Hitbox: 6" lb.TextColor3=Color3.fromRGB(255,255,0)
lb.Font=Enum.Font.GothamBold lb.TextSize=11 lb.Parent=fr

local function stepBtn(txt,x,delta)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,96,0,26) b.Position=UDim2.new(0,x,0,216)
    b.BackgroundColor3=Color3.fromRGB(45,45,55) b.Text=txt
    b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamBold b.TextSize=12 b.Parent=fr
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        CFG.HBSize=math.clamp(CFG.HBSize+delta,1,40)
        lb.Text="Hitbox: "..CFG.HBSize
    end)
end
stepBtn("-",8,-1)
stepBtn("+",104,1)

local pb=Instance.new("TextButton")
pb.Size=UDim2.new(1,-16,0,26) pb.Position=UDim2.new(0,8,0,248)
pb.BackgroundColor3=Color3.fromRGB(45,45,55) pb.Text="POV: "..CFG.POV
pb.TextColor3=Color3.new(1,1,1) pb.Font=Enum.Font.GothamBold pb.TextSize=11 pb.Parent=fr
Instance.new("UICorner",pb).CornerRadius=UDim.new(0,6)
pb.MouseButton1Click:Connect(function()
    CFG.POV=CFG.POV+10 if CFG.POV>140 then CFG.POV=70 end
    if Cam then Cam.FieldOfView=CFG.POV end
    pb.Text="POV: "..CFG.POV
end)

local ds=Instance.new("TextButton")
ds.Size=UDim2.new(1,-16,0,26) ds.Position=UDim2.new(0,8,0,280)
ds.BackgroundColor3=Color3.fromRGB(45,45,55) ds.Text="Distancia max: "..CFG.MaxDist
ds.TextColor3=Color3.new(1,1,1) ds.Font=Enum.Font.GothamBold ds.TextSize=11 ds.Parent=fr
Instance.new("UICorner",ds).CornerRadius=UDim.new(0,6)
ds.MouseButton1Click:Connect(function()
    CFG.MaxDist=CFG.MaxDist+300 if CFG.MaxDist>3000 then CFG.MaxDist=300 end
    ds.Text="Distancia max: "..CFG.MaxDist
end)

local ref=Instance.new("TextButton")
ref.Size=UDim2.new(1,-16,0,24) ref.Position=UDim2.new(0,8,0,312)
ref.BackgroundColor3=Color3.fromRGB(45,45,55) ref.Text="Refrescar roles"
ref.TextColor3=Color3.new(1,1,1) ref.Font=Enum.Font.GothamBold ref.TextSize=11 ref.Parent=fr
Instance.new("UICorner",ref).CornerRadius=UDim.new(0,6)
ref.MouseButton1Click:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do cache[p]=roleOf(p) end
end)

local info=Instance.new("TextLabel")
info.Size=UDim2.new(1,-16,0,40) info.Position=UDim2.new(0,8,0,342)
info.BackgroundTransparency=1 info.Text="Rol detectado por inventario. Si sale '?' usa Refrescar roles."
info.TextColor3=Color3.fromRGB(120,120,135) info.Font=Enum.Font.Gotham
info.TextSize=10 info.TextWrapped=true info.TextXAlignment=Enum.TextXAlignment.Left
info.Parent=fr

local minimized=false
minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    fr.Size=UDim2.new(0,215,0,minimized and 32 or 392)
    for _,c in ipairs(fr:GetChildren()) do
        if c~=ttl and c~=minBtn and c~=closeBtn and c:IsA("GuiObject") then c.Visible=not minimized end
    end
    minBtn.Text=minimized and "+" or "-"
end)
closeBtn.MouseButton1Click:Connect(function()
    CFG.ESP=false CFG.HBEsp=false CFG.Auto=false CFG.Melee=false
    for _,d in pairs(ESP) do hide(d) end
    for _,t in pairs(HBDraw) do hide(t) end
    for p in pairs(HBPart) do clearHB(p) end
    gui.Enabled=false
end)

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

print("[Navi v4] cargado")