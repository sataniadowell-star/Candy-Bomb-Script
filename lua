-- 🍭 CANDY BOMB DETECTOR v4.1 | DELTA EXECUTOR FIXED
-- Escape Tsunami For Brainrot - Enemy Red Highlights + Aesthetic GUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Settings
local DETECT_DISTANCE = 120
local SCAN_INTERVAL = 0.1
local highlights = {}
local detectedBombs = {}
local minimized = false
local dragging = false

-- Enemy Bomb Check
local function isEnemyBomb(part)
    local names = {"Bomb", "bomb", "TNT", "💣", "Explosive", "mine", "trap", "Enemy"}
    for _, name in ipairs(names) do
        if string.find(string.lower(part.Name), name) then
            return true
        end
    end
    return part:FindFirstChild("Bomb") ~= nil or part:GetAttribute("IsBomb")
end

-- Red Highlight
local function addHighlight(part)
    if highlights[part] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "EnemyBombHighlight"
    highlight.FillColor = Color3.fromRGB(255, 40, 40)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 60)
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0
    highlight.Parent = part
    highlights[part] = highlight
    
    -- Pulse effect
    spawn(function()
        while highlight.Parent do
            TweenService:Create(highlight, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {FillTransparency = 0.1}):Play()
            wait(0.8)
        end
    end)
end

local function removeHighlight(part)
    if highlights[part] then
        highlights[part]:Destroy()
        highlights[part] = nil
    end
end

-- Scan Function
local function scanBombs()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return 0
    end
    
    local playerPos = character.HumanoidRootPart.Position
    local bombCount = 0
    
    -- Cleanup old highlights
    for part, _ in pairs(detectedBombs) do
        if not part.Parent then
            removeHighlight(part)
            detectedBombs[part] = nil
        end
    end
    
    -- Find enemy bombs
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") and part ~= character.HumanoidRootPart then
                    local distance = (part.Position - playerPos).Magnitude
                    if distance <= DETECT_DISTANCE and isEnemyBomb(part) then
                        detectedBombs[part] = true
                        addHighlight(part)
                        bombCount = bombCount + 1
                    end
                end
            end
        elseif obj:IsA("BasePart") then
            local distance = (obj.Position - playerPos).Magnitude
            if distance <= DETECT_DISTANCE and isEnemyBomb(obj) then
                detectedBombs[obj] = true
                addHighlight(obj)
                bombCount = bombCount + 1
            end
        end
    end
    
    return bombCount
end

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CandyBombDetector"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, minimized and 45 or 130)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.2
stroke.Parent = mainFrame

-- Header (Draggable)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🍭 BOMB SCANNER"
titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Minimize Button
local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 30, 0, 30)
minButton.Position = UDim2.new(1, -35, 0, 2.5)
minButton.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
minButton.Text = "−"
minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minButton.TextScaled = true
minButton.Font = Enum.Font.GothamBold
minButton.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minButton

-- Bomb Counter
local bombFrame = Instance.new("Frame")
bombFrame.Size = UDim2.new(1, -20, 0, 50)
bombFrame.Position = UDim2.new(0, 10, 0, 40)
bombFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
bombFrame.BorderSizePixel = 0
bombFrame.Visible = not minimized
bombFrame.Parent = mainFrame

local bombCorner = Instance.new("UICorner")
bombCorner.CornerRadius = UDim.new(0, 8)
bombCorner.Parent = bombFrame

local bombLabel = Instance.new("TextLabel")
bombLabel.Size = UDim2.new(1, 0, 1, 0)
bombLabel.BackgroundTransparency = 1
bombLabel.Text = "0 ENEMY BOMBS"
bombLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
bombLabel.TextScaled = true
bombLabel.Font = Enum.Font.GothamBold
bombLabel.Parent = bombFrame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 1, -30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔍 Scanning..."
statusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Visible = not minimized
statusLabel.Parent = mainFrame

-- Drag Functionality
local dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Minimize Toggle
minButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 220, 0, minimized and 45 or 130)
    }):Play()
    
    minButton.Text = minimized and "+" or "−"
    bombFrame.Visible = not minimized
    statusLabel.Visible = not minimized
end)

-- Main Scanning Loop
spawn(function()
    while true do
        local bombCount = scanBombs()
        bombLabel.Text = bombCount .. " ENEMY BOMBS"
        
        if bombCount > 0 then
            bombFrame.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
            bombLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "🚨 " .. bombCount .. " BOMBS DETECTED!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            bombFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
            bombLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            statusLabel.Text = "✅ NO BOMBS - SAFE"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        end
        
        wait(SCAN_INTERVAL)
    end
end)

print("✅ Candy Bomb Detector v4.1 LOADED SUCCESSFULLY!")
print("🔴 Red highlights show ENEMY BOMBS!")
print("🎮 Drag header • Click − to minimize")-- Status Bar
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
