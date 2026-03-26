-- 🍭 AESTHETIC CANDY BOMB DETECTOR v4.0 | DELTA EXECUTOR
-- Escape Tsunami For Brainrot - Trading Plaza | Enemy Bomb Scanner

local Players,TweenService,RunService=game:GetService("Players"),game:GetService("TweenService"),game:GetService("RunService")
local player=Players.LocalPlayer,playerGui=player:WaitForChild("PlayerGui")

-- Config
local DETECT_DISTANCE=120,SCAN_INTERVAL=.08
local highlights={},detectedBombs={},isScanning=true,minimized=false

-- Enemy Bomb Detection
local function isEnemyBomb(part)
 local enemyNames={"Bomb","bomb","TNT","💣","Explosive","mine","trap"}
 for _,name in pairs(enemyNames)do if string.find(string.lower(part.Name),name)then return true end end
 return part:FindFirstChild("Bomb")or part:GetAttribute("IsBomb")or part.Name:lower():find("enemy")
end

local function createRedHighlight(part)
 if highlights[part]then return end
 local hl=Instance.new("Highlight")hl.Name="EnemyBombRed"
 hl.FillColor=Color3.fromRGB(255,30,30),hl.OutlineColor=Color3.fromRGB(255,255,50)
 hl.FillTransparency=.2,hl.OutlineTransparency=0,hl.Parent=part
 
 -- Pulsing Animation
 spawn(function()
  while hl.Parent do
   TweenService:Create(hl,TweenInfo.new(.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{FillTransparency=.1}):Play()
   wait(.6)
  end
 end)
 highlights[part]=hl
end

local function removeHighlight(part)
 if highlights[part]then highlights[part]:Destroy()highlights[part]=nil end
end

local function scanEnemyBombs()
 if not isScanning then return 0 end
 local char=player.Character if not char or not char:FindFirstChild("HumanoidRootPart")then return 0 end
 local pos=char.HumanoidRootPart.Position local count=0
 
 -- Cleanup
 for part,_ in pairs(detectedBombs)do if not part.Parent then removeHighlight(part)detectedBombs[part]=nil end end
 
 -- Scan
 for _,obj in pairs(workspace:GetDescendants())do
  if obj:IsA("BasePart")and(obj.Parent~=char)and(obj.Position-pos).Magnitude<=DETECT_DISTANCE then
   if isEnemyBomb(obj)then detectedBombs[obj]=true createRedHighlight(obj)count=count+1 end
  end
 end
 return count
end

-- 🖼️ AESTHETIC COMPACT GUI (200x120)
local sg=Instance.new("ScreenGui")sg.Name="CandyBombGUI"sg.ResetOnSpawn=false sg.Parent=playerGui

local mainFrame=Instance.new("Frame")
mainFrame.Size=UDim2.new(0,200,0,minimized and 40 or 120)
mainFrame.Position=UDim2.new(0,15,0,15)
mainFrame.BackgroundColor3=Color3.fromRGB(15,20,30)
mainFrame.BorderSizePixel=0 mainFrame.Parent=sg

-- Glass Effect
local ug=Instance.new("UIGradient")
ug.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(30,40,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,15,25))}
ug.Rotation=45 ug.Parent=mainFrame

local corner=Instance.new("UICorner")corner.CornerRadius=UDim.new(0,12)corner.Parent=mainFrame
local stroke=Instance.new("UIStroke")stroke.Color=Color3.fromRGB(100,150,255)stroke.Thickness=1.5 stroke.Transparency=.3 stroke.Parent=mainFrame

-- Header Bar (Draggable)
local header=Instance.new("Frame")header.Size=UDim2.new(1,0,0,.33)header.BackgroundTransparency=1 header.Parent=mainFrame

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-40,1,0)title.BackgroundTransparency=1
title.Text="🍭 BOMB SCANNER"title.TextColor3=Color3.fromRGB(255,220,100)
title.TextScaled=true title.Font=Enum.Font.GothamBold title.TextXAlignment=Enum.TextXAlignment.Left
title.Position=UDim2.new(0,10,0,0) title.Parent=header

-- Minimize Button
local minBtn=Instance.new("TextButton")
minBtn.Size=UDim2.new(0,25,0,25)minBtn.Position=UDim2.new(1,-30,0,7.5)
minBtn.BackgroundColor3=Color3.fromRGB(255,80,80)minBtn.Text="−"minBtn.TextColor3=Color3.new(1)
minBtn.TextScaled=true minBtn.Font=Enum.Font.GothamBold minBtn.Parent=header

local minCorner=Instance.new("UICorner")minCorner.CornerRadius=UDim.new(0,6)minCorner.Parent=minBtn

-- Bomb Counter (Main Content)
local bombFrame=Instance.new("Frame")bombFrame.Size=UDim2.new(1,-10,0,50)
bombFrame.Position=UDim2.new(0,5,0,.4)bombFrame.BackgroundTransparency=1 bombFrame.Parent=mainFrame

local bombIcon=Instance.new("TextLabel")bombIcon.Size=UDim2.new(0,40,1,0)bombIcon.BackgroundTransparency=1
bombIcon.Text="💣"bombIcon.TextSize=28 bombIcon.TextColor3=Color3.fromRGB(255,100,100)
bombIcon.Font=Enum.Font.SourceSansBold bombIcon.Parent=bombFrame

local bombCount=Instance.new("TextLabel")bombCount.Size=UDim2.new(1,-45,1,0)bombCount.Position=UDim2.new(0,.25,0,0)
bombCount.BackgroundTransparency=1 bombCount.Text="0"bombCount.TextColor3=Color3.fromRGB(0,255,150)
bombCount.TextScaled=true bombCount.Font=Enum.Font.GothamBlack bombCount.TextXAlignment=Enum.TextXAlignment.Left
bombCount.Parent=bombFrame

local bombText=Instance.new("TextLabel")bombText.Size=UDim2.new(1,-45,0,20)
bombText.Position=UDim2.new(0,.25,1,-20)bombText.BackgroundTransparency=1
bombText.Text="ENEMY BOMBS"bombText.TextColor3=Color3.fromRGB(150,180,200)
bombText.TextScaled=true bombText.Font=Enum.Font.Gotham bombText.TextXAlignment=Enum.TextXAlignment.Left
bombText.Parent=bombFrame

-- Status Bar
local status=Instance.new("TextLabel")status.Size=UDim2.new(1,-10,0,20)
status.Position=UDim2.new(0,5,1,-25)status.BackgroundTransparency=1
status.Text="🔍 ACTIVE SCANNING..."status.TextColor3=Color3.fromRGB(100,200,255)
status.TextScaled=true status.Font=Enum.Font.GothamSemibold status.Parent=mainFrame

-- ✨ DRAG SYSTEM
local dragging,dragInput,startPos,startSize
header.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then
 dragging=true dragInput=input startPos=mainFrame.Position end end)

game:GetService("UserInputService").InputChanged:Connect(function(input)if dragging and input==dragInput then
 local delta=input.Position-dragInput.Position mainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)end end)

header.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

-- 🎛️ MINIMIZE/MAXIMIZE
minBtn.MouseButton1Click:Connect(function()
 minimized=not minimized
 TweenService:Create(mainFrame,TweenInfo.new(.3,Enum.EasingStyle.Back),{Size=UDim2.new(0,200,0,minimized and 40 or 120)}):Play()
 minBtn.Text=minimized and"+"or"−"
 bombFrame.Visible=not minimized
 status.Visible=not minimized
end)

-- 🔄 MAIN SCAN LOOP
spawn(function()
 while wait(SCAN_INTERVAL)do
  local bombs=scanEnemyBombs()
  bombCount.Text=bombs>0 and bombs or"0"
  
  if bombs>0 then
   bombCount.TextColor3=Color3.fromRGB(255,80,80)
   bombFrame.BackgroundColor3=Color3.fromRGB(40,15,15)
   status.Text="🚨 "..bombs.." ENEMY BOMB"..(bombs>1 and"S"or"").." DETECTED!"
   status.TextColor3=Color3.fromRGB(255,100,100)
  else
   bombCount.TextColor3=Color3.fromRGB(0,255,150)
   bombFrame.BackgroundColor3=Color3.fromRGB(15,30,20)
   status.Text="✅ NO BOMBS - SAFE"
   status.TextColor3=Color3.fromRGB(100,255,150)
  end
 end
end)

print("🎨 Aesthetic Candy Bomb Detector v4.0 LOADED!")
print("🔴 RED HIGHLIGHTS = ENEMY BOMBS ON YOUR CANDY!")toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -45, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

-- Drag Script
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Main Loop
spawn(function()
    while true do
        local bombCount = scanBombs()
        bombLabel.Text = bombCount .. " ENEMY BOMBS"
        
        if bombCount > 0 then
            bombFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            bombLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.Text = "🚨 " .. bombCount .. " BOMBS ON YOUR CANDY!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            bombFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            bombLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            statusLabel.Text = "✅ Safe - No enemy bombs detected"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
        
        wait(SCAN_INTERVAL)
    end
end)

-- Toggle Detection
toggleBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    if guiOpen then
        mainFrame.Visible = true
        toggleBtn.Text = "HIDE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    else
        mainFrame.Visible = false
        toggleBtn.Text = "SHOW"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    end
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 320, 0, 50)
        minimizeBtn.Text = "+"
        titleLabel.Visible = true
        bombFrame.Visible = false
        statusLabel.Visible = false
        toggleBtn.Position = UDim2.new(0, 10, 1, -45)
    else
        mainFrame.Size = UDim2.new(0, 320, 0, 220)
        minimizeBtn.Text = "−"
        titleLabel.Visible = true
        bombFrame.Visible = true
        statusLabel.Visible = true
        toggleBtn.Position = UDim2.new(1, -110, 1, -45)
    end
end)

print("🍭 Candy Bomb Detector GUI v3.0 LOADED!")
print("Red highlights = ENEMY BOMBS on your candy!")
