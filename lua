-- 🍭 CANDY BOMB DETECTOR v3.0 | FULL GUI | DELTA EXECUTOR
-- Escape Tsunami For Brainrot - Trading Plaza Candy Game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Config
local DETECT_DISTANCE = 100
local SCAN_INTERVAL = 0.1
local highlights = {}
local detectedBombs = {}
local guiOpen = true

-- Bomb Detection
local function isBomb(part)
    local bombNames = {"Bomb", "bomb", "Explosive", "TNT", "💣", "mine"}
    for _, name in pairs(bombNames) do 
        if string.find(string.lower(part.Name), name) then return true end 
    end
    return part:FindFirstChild("Bomb") or part:GetAttribute("IsBomb")
end

local function createHighlight(part)
    if highlights[part] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "BombHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Parent = part
    highlights[part] = highlight
end

local function removeHighlight(part)
    if highlights[part] then 
        highlights[part]:Destroy() 
        highlights[part] = nil 
    end
end

local function scanBombs()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return 0 end
    
    local playerPos = character.HumanoidRootPart.Position
    local bombCount = 0
    
    for part, _ in pairs(detectedBombs) do
        if not part.Parent then 
            removeHighlight(part) 
            detectedBombs[part] = nil 
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent ~= character then
            local distance = (obj.Position - playerPos).Magnitude
            if distance <= DETECT_DISTANCE and isBomb(obj) then
                detectedBombs[obj] = true
                createHighlight(obj)
                bombCount = bombCount + 1
            end
        end
    end
    return bombCount
end

-- 🔥 ADVANCED GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CandyBombDetector"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 200, 255)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🍭 CANDY BOMB DETECTOR"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Bomb Counter
local bombFrame = Instance.new("Frame")
bombFrame.Size = UDim2.new(1, -20, 0, 60)
bombFrame.Position = UDim2.new(0, 10, 0, 55)
bombFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
bombFrame.Parent = mainFrame

local bombCorner = Instance.new("UICorner")
bombCorner.CornerRadius = UDim.new(0, 8)
bombCorner.Parent = bombFrame

local bombLabel = Instance.new("TextLabel")
bombLabel.Size = UDim2.new(1, 0, 1, 0)
bombLabel.BackgroundTransparency = 1
bombLabel.Text = "0 ENEMY BOMBS"
bombLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
bombLabel.TextScaled = true
bombLabel.Font = Enum.Font.GothamBold
bombLabel.Parent = bombFrame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 125)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔍 Scanning for enemy bombs..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 35)
toggleBtn.Position = UDim2.new(1, -110, 1, -45)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.Text = "TOGGLE"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
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
