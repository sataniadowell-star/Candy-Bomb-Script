-- 🍭 CANDY BOMB DETECTOR v2.1 | DELTA EXECUTOR READY
-- Escape Tsunami For Brainrot - Trading Plaza Candy Game
-- Paste in Delta > Execute = DONE!

local Players=game:GetService("Players"),RunService=game:GetService("RunService"),TweenService=game:GetService("TweenService"),HttpService=game:GetService("HttpService")
local player=Players.LocalPlayer,playerGui=player:WaitForChild("PlayerGui")

local CANDY_SLOTS=12,DETECT_DISTANCE=100,SCAN_INTERVAL=.1
local BOMB_COLOR=Color3.fromRGB(255,0,0),GLOW_INTENSITY=1.5
local highlights={},detectedBombs={}

local function createHighlight(part)
 if highlights[part]then return end
 local highlight=Instance.new("Highlight")highlight.Name="BombHighlight"
 highlight.FillColor=BOMB_COLOR,highlight.OutlineColor=Color3.fromRGB(255,255,0)
 highlight.FillTransparency=.3,highlight.OutlineTransparency=0,highlight.Parent=part
 spawn(function()while highlight.Parent do
  local tween=TweenService:Create(highlight,TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{FillTransparency=.1})
  tween:Play()wait(.5)end end)highlights[part]=highlight
end

local function removeHighlight(part)
 if highlights[part]then highlights[part]:Destroy()highlights[part]=nil end
end

local function isBomb(part)
 local bombNames={"Bomb","bomb","Explosive","TNT","💣","mine"}
 local bombParents={"Bomb","EnemyBomb","Trap"}
 for _,name in pairs(bombNames)do if string.find(string.lower(part.Name),name)then return true end end
 if part.Parent then for _,parentName in pairs(bombParents)do if string.find(string.lower(part.Parent.Name),parentName)then return true end end end
 if part:FindFirstChild("Bomb")or part:GetAttribute("IsBomb")or part:FindFirstChild("Explosion")then return true end
 return false
end

local function findPlayerCandyArea()
 local character=player.Character if not character then return nil end
 local humanoidRootPart=character:FindFirstChild("HumanoidRootPart")if not humanoidRootPart then return nil end
 local candyAreas={}local searchAreas=workspace:GetDescendants()
 for _,obj in pairs(searchAreas)do if obj:IsA("BasePart")or obj:IsA("Model")then
  local name=string.lower(obj.Name)if string.find(name,"candy")or string.find(name,player.Name:lower())or string.find(name,"player")or string.find(name,"slot")then table.insert(candyAreas,obj)end end end
 table.sort(candyAreas,function(a,b)local distA=(a.Position-humanoidRootPart.Position).Magnitude local distB=(b.Position-humanoidRootPart.Position).Magnitude return distA<distB end)
 return candyAreas[1]
end

local function scanForBombs()
 local character=player.Character if not character or not character:FindFirstChild("HumanoidRootPart")then return end
 local playerPos=character.HumanoidRootPart.Position local candyArea=findPlayerCandyArea()
 for part,_ in pairs(detectedBombs)do if not part.Parent then removeHighlight(part)detectedBombs[part]=nil end end
 for _,obj in pairs(workspace:GetDescendants())do if obj:IsA("BasePart")and obj~=character.HumanoidRootPart then
  local distance=(obj.Position-playerPos).Magnitude if distance<=DETECT_DISTANCE then if isBomb(obj)then
   local isOnMyCandy=true if candyArea then local candyDist=(obj.Position-candyArea.Position).Magnitude isOnMyCandy=candyDist<=20 end
   if isOnMyCandy then detectedBombs[obj]=true createHighlight(obj)else removeHighlight(obj)detectedBombs[obj]=nil end end end end end end
end

local function createNotification()
 local screenGui=Instance.new("ScreenGui")screenGui.Name="BombDetectorGUI"screenGui.Parent=playerGui
 local frame=Instance.new("Frame")frame.Size=UDim2.new(0,250,0,80)frame.Position=UDim2.new(0,20,0,20)
 frame.BackgroundColor3=Color3.fromRGB(50,50,50)frame.BackgroundTransparency=.2 frame.BorderSizePixel=0 frame.Parent=screenGui
 local corner=Instance.new("UICorner")corner.CornerRadius=UDim.new(0,10)corner.Parent=frame
 local title=Instance.new("TextLabel")title.Size=UDim2.new(1,0,.4,0)title.BackgroundTransparency=1
 title.Text="🍭 CANDY BOMB DETECTOR"title.TextColor3=Color3.fromRGB(255,255,0)title.TextScaled=true
 title.Font=Enum.Font.GothamBold title.Parent=frame
 local status=Instance.new("TextLabel")status.Name="StatusLabel"status.Size=UDim2.new(1,0,.6,0)status.Position=UDim2.new(0,0,.4,0)
 status.BackgroundTransparency=1 status.Text="🚀 Delta Loaded - Scanning..."status.TextColor3=Color3.fromRGB(0,255,0)
 status.TextScaled=true status.Font=Enum.Font.Gotham status.Parent=frame return status
end

local statusLabel=createNotification()
spawn(function()while true do local bombCount=0 for _ in pairs(detectedBombs)do bombCount=bombCount+1 end
 if statusLabel then if bombCount>0 then statusLabel.Text="🚨 "..bombCount.." ENEMY BOMB"..(bombCount>1 and"S"or"").." DETECTED!"
  statusLabel.TextColor3=Color3.fromRGB(255,0,0)else statusLabel.Text="✅ No bombs detected"statusLabel.TextColor3=Color3.fromRGB(0,255,0)end end
 scanForBombs()wait(SCAN_INTERVAL)end end)

print("🍭 Candy Bomb Detector v2.1 LOADED! Red = ENEMY BOMBS!")
