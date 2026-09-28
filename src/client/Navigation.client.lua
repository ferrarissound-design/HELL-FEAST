local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastNavigation"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

local nav = Instance.new("Frame")
nav.Name = "NavigationPanel"
nav.AnchorPoint = Vector2.new(0.5, 0)
nav.Position = UDim2.new(0.5, 0, 0, 12)
nav.Size = UDim2.fromOffset(260, 72)
nav.BackgroundColor3 = Color3.fromRGB(24, 16, 20)
nav.BackgroundTransparency = 0.16
nav.BorderSizePixel = 0
nav.Parent = gui

local navCorner = Instance.new("UICorner")
navCorner.CornerRadius = UDim.new(0, 14)
navCorner.Parent = nav

local navStroke = Instance.new("UIStroke")
navStroke.Color = Color3.fromRGB(118, 64, 69)
navStroke.Thickness = 2
navStroke.Transparency = 0.28
navStroke.Parent = nav

local arrow = Instance.new("TextLabel")
arrow.AnchorPoint = Vector2.new(0.5, 0.5)
arrow.Position = UDim2.fromOffset(36, 36)
arrow.Size = UDim2.fromOffset(46, 46)
arrow.BackgroundTransparency = 1
arrow.Text = "▲"
arrow.TextColor3 = Color3.fromRGB(255, 180, 135)
arrow.Font = Enum.Font.GothamBlack
arrow.TextSize = 30
arrow.Parent = nav

local targetLabel = Instance.new("TextLabel")
targetLabel.Position = UDim2.fromOffset(66, 8)
targetLabel.Size = UDim2.fromOffset(182, 28)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.fromRGB(245, 225, 214)
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextSize = 15
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = nav

local regionLabel = Instance.new("TextLabel")
regionLabel.Position = UDim2.fromOffset(66, 36)
regionLabel.Size = UDim2.fromOffset(182, 25)
regionLabel.BackgroundTransparency = 1
regionLabel.TextColor3 = Color3.fromRGB(188, 157, 193)
regionLabel.Font = Enum.Font.Gotham
regionLabel.TextSize = 13
regionLabel.TextXAlignment = Enum.TextXAlignment.Left
regionLabel.Parent = nav

local hungerAlert = Instance.new("TextLabel")
hungerAlert.Name = "HungerAlert"
hungerAlert.AnchorPoint = Vector2.new(0.5, 0)
hungerAlert.Position = UDim2.new(0.5, 0, 0, 90)
hungerAlert.Size = UDim2.fromOffset(290, 44)
hungerAlert.BackgroundColor3 = Color3.fromRGB(100, 45, 30)
hungerAlert.BackgroundTransparency = 1
hungerAlert.TextTransparency = 1
hungerAlert.TextColor3 = Color3.fromRGB(255, 225, 190)
hungerAlert.Font = Enum.Font.GothamBlack
hungerAlert.TextSize = 16
hungerAlert.Text = ""
hungerAlert.BorderSizePixel = 0
hungerAlert.Visible = true
hungerAlert.Parent = gui

local alertCorner = Instance.new("UICorner")
alertCorner.CornerRadius = UDim.new(0, 12)
alertCorner.Parent = hungerAlert

local zoneBanner = Instance.new("TextLabel")
zoneBanner.Name = "ZoneBanner"
zoneBanner.AnchorPoint = Vector2.new(0.5, 0.5)
zoneBanner.Position = UDim2.fromScale(0.5, 0.26)
zoneBanner.Size = UDim2.fromOffset(360, 64)
zoneBanner.BackgroundTransparency = 1
zoneBanner.TextTransparency = 1
zoneBanner.TextColor3 = Color3.fromRGB(240, 212, 195)
zoneBanner.TextStrokeTransparency = 0.65
zoneBanner.Font = Enum.Font.GothamBlack
zoneBanner.TextSize = 26
zoneBanner.Parent = gui

local currentRegion = ""
local lastAlertLevel = 0

local function flat(vector)
	return Vector3.new(vector.X, 0, vector.Z)
end

local function regionAt(position)
	local kitchenDistance = (flat(position) - flat(Config.Navigation.KitchenPosition)).Magnitude
	if kitchenDistance <= 32 then
		return "HELL KITCHEN"
	end

	local bossDistance = (flat(position) - flat(Config.Navigation.BossPosition)).Magnitude
	if bossDistance <= 46 then
		return "THE SLAUGHTER PIT"
	end

	local nearestName = "THE WASTES"
	local nearestDistance = math.huge
	for _, region in pairs(Config.Regions) do
		local distance = (flat(position) - flat(region.Center)).Magnitude
		if distance <= region.Radius and distance < nearestDistance then
			nearestDistance = distance
			nearestName = region.DisplayName
		end
	end

	return nearestName
end

local function announceRegion(name)
	if name == currentRegion then
		return
	end

	currentRegion = name
	zoneBanner.Text = name
	zoneBanner.TextTransparency = 0
	zoneBanner.Position = UDim2.fromScale(0.5, 0.28)
	TweenService:Create(zoneBanner, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Position = UDim2.fromScale(0.5, 0.24),
	}):Play()

	task.delay(1.4, function()
		if currentRegion == name then
			TweenService:Create(zoneBanner, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
		end
	end)
end

local function setAlert(level)
	if level == lastAlertLevel then
		return
	end
	lastAlertLevel = level

	if level == 0 then
		TweenService:Create(hungerAlert, TweenInfo.new(0.3), {
			TextTransparency = 1,
			BackgroundTransparency = 1,
		}):Play()
		return
	end

	hungerAlert.Text = level == 2 and "STARVING • RETURN TO HELL KITCHEN" or "HUNGRY • FIND FOOD OR RETURN TO KITCHEN"
	hungerAlert.BackgroundColor3 = level == 2 and Color3.fromRGB(120, 32, 30) or Color3.fromRGB(100, 58, 30)
	hungerAlert.TextTransparency = 0
	hungerAlert.BackgroundTransparency = 0.12
	hungerAlert.Size = UDim2.fromOffset(310, 48)
	TweenService:Create(hungerAlert, TweenInfo.new(0.18, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(290, 44),
	}):Play()
end

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local camera = Workspace.CurrentCamera
	if not root or not camera then
		return
	end

	local bossAlive = Workspace:GetAttribute("BossAlive") == true
	local hunger = player:GetAttribute("Hunger") or Config.Hunger.Max
	local maxHunger = player:GetAttribute("MaxHunger") or Config.Hunger.Max
	local hungerRatio = hunger / math.max(1, maxHunger)

	local targetPosition
	local targetName
	if bossAlive then
		targetPosition = Config.Navigation.BossPosition
		targetName = "THE BUTCHER"
	else
		targetPosition = Config.Navigation.KitchenPosition
		targetName = hungerRatio <= Config.Navigation.LowHungerThreshold / 100 and "HELL KITCHEN • FOOD" or "HELL KITCHEN"
	end

	local toTarget = flat(targetPosition - root.Position)
	local distance = toTarget.Magnitude
	if distance > 0.01 then
		local direction = toTarget.Unit
		local forward = flat(camera.CFrame.LookVector)
		local right = flat(camera.CFrame.RightVector)
		if forward.Magnitude > 0.01 and right.Magnitude > 0.01 then
			forward = forward.Unit
			right = right.Unit
			local forwardDot = math.clamp(forward:Dot(direction), -1, 1)
			local rightDot = math.clamp(right:Dot(direction), -1, 1)
			local angle = math.deg(math.atan2(rightDot, forwardDot))
			arrow.Rotation = angle
		end
	end

	targetLabel.Text = string.format("%s  •  %d studs", targetName, math.floor(distance + 0.5))

	local regionName = regionAt(root.Position)
	regionLabel.Text = regionName
	announceRegion(regionName)

	if hungerRatio <= Config.Navigation.CriticalHungerThreshold / 100 then
		setAlert(2)
	elseif hungerRatio <= Config.Navigation.LowHungerThreshold / 100 then
		setAlert(1)
	else
		setAlert(0)
	end

	if bossAlive then
		navStroke.Color = Color3.fromRGB(175, 65, 55)
		arrow.TextColor3 = Color3.fromRGB(255, 120, 85)
	elseif hungerRatio <= Config.Navigation.LowHungerThreshold / 100 then
		navStroke.Color = Color3.fromRGB(160, 90, 45)
		arrow.TextColor3 = Color3.fromRGB(255, 175, 95)
	else
		navStroke.Color = Color3.fromRGB(118, 64, 69)
		arrow.TextColor3 = Color3.fromRGB(255, 180, 135)
	end
end)
