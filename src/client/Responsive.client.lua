local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function ensureScale(target, name)
	if not target or not target:IsA("GuiObject") then
		return nil
	end
	local scale = target:FindFirstChild(name)
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = name
		scale.Parent = target
	end
	return scale
end

local function viewportProfile()
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local tiny = viewport.Y < 430 or viewport.X < 620
	local compact = tiny or viewport.Y < 620 or viewport.X < 960
	return viewport, tiny, compact
end

local function apply()
	local viewport, tiny, compact = viewportProfile()
	local touch = UserInputService.TouchEnabled

	local hud = playerGui:FindFirstChild("HellFeastHUD")
	if hud then
		local panel = hud:FindFirstChild("Panel")
		local scale = ensureScale(panel, "ResponsiveScale")
		if scale then
			scale.Scale = tiny and 0.72 or compact and 0.84 or 1
		end
		if panel then
			panel.Position = tiny and UDim2.fromOffset(8, 8) or UDim2.fromOffset(16, 16)
		end

		local decision = hud:FindFirstChild("DecisionFrame")
		local decisionScale = ensureScale(decision, "ResponsiveScale")
		if decisionScale then
			decisionScale.Scale = tiny and 0.84 or compact and 0.94 or 1
		end
	end

	local navigation = playerGui:FindFirstChild("HellFeastNavigation")
	if navigation then
		local nav = navigation:FindFirstChild("NavigationPanel")
		local navScale = ensureScale(nav, "ResponsiveScale")
		if navScale then
			navScale.Scale = tiny and 0.78 or compact and 0.90 or 1
		end
		if nav then
			if tiny then
				nav.Position = UDim2.new(0.5, 0, 0, 198)
			else
				nav.Position = UDim2.new(0.5, 0, 0, 12)
			end
		end

		local alert = navigation:FindFirstChild("HungerAlert")
		local alertScale = ensureScale(alert, "ResponsiveScale")
		if alertScale then
			alertScale.Scale = tiny and 0.82 or compact and 0.92 or 1
		end
		if alert then
			alert.Position = tiny and UDim2.new(0.5, 0, 0, 300) or UDim2.new(0.5, 0, 0, 118)
		end

		local zone = navigation:FindFirstChild("ZoneBanner")
		local zoneScale = ensureScale(zone, "ResponsiveScale")
		if zoneScale then
			zoneScale.Scale = tiny and 0.78 or compact and 0.90 or 1
		end
	end

	local dashGui = playerGui:FindFirstChild("HellFeastDash")
	if dashGui then
		local dash = dashGui:FindFirstChild("DashButton")
		if dash then
			if touch then
				local size = tiny and 76 or 84
				dash.Size = UDim2.fromOffset(size, size)
				dash.Position = UDim2.new(1, -22, 1, tiny and -198 or -210)
				dash.TextSize = tiny and 16 or 18
			else
				dash.Size = UDim2.fromOffset(92, 92)
				dash.Position = UDim2.new(1, -26, 1, -112)
				dash.TextSize = 19
			end
		end
	end

	local bookGui = playerGui:FindFirstChild("HellBookAndResults")
	if bookGui then
		local bookButton = bookGui:FindFirstChild("HellBookButton")
		local bookScale = ensureScale(bookButton, "ResponsiveScale")
		if bookScale then
			bookScale.Scale = tiny and 0.82 or compact and 0.92 or 1
		end

		local bookFrame = bookGui:FindFirstChild("HellBookFrame")
		if bookFrame then
			bookFrame.Size = tiny and UDim2.new(0.94, 0, 0.91, 0)
				or compact and UDim2.new(0.92, 0, 0.88, 0)
				or UDim2.new(0.88, 0, 0.82, 0)
		end

		local result = bookGui:FindFirstChild("ResultFrame")
		local resultScale = ensureScale(result, "ResponsiveScale")
		if resultScale then
			resultScale.Scale = tiny and 0.84 or compact and 0.94 or 1
		end

		local discovery = bookGui:FindFirstChild("DiscoveryBanner")
		local discoveryScale = ensureScale(discovery, "ResponsiveScale")
		if discoveryScale then
			discoveryScale.Scale = tiny and 0.80 or compact and 0.92 or 1
		end
	end

	local effects = playerGui:FindFirstChild("HellFeastEffects")
	if effects then
		local boss = effects:FindFirstChild("BossFrame")
		local bossScale = ensureScale(boss, "ResponsiveScale")
		if bossScale then
			bossScale.Scale = tiny and 0.82 or compact and 0.92 or 1
		end
		if boss and tiny then
			boss.Position = UDim2.new(0.5, 0, 0, 86)
		end
	end

	local tutorialGui = playerGui:FindFirstChild("HellFeastTutorial")
	if tutorialGui then
		local tutorialCard = tutorialGui:FindFirstChild("TutorialCard")
		local tutorialScale = ensureScale(tutorialCard, "ResponsiveScale")
		if tutorialScale then
			tutorialScale.Scale = tiny and 0.78 or compact and 0.90 or 1
		end
		if tutorialCard and tiny then
			tutorialCard.Position = UDim2.new(0, 10, 1, -76)
		end
	end

	local settingsGui = playerGui:FindFirstChild("HellFeastSettings")
	if settingsGui then
		local settingsButton = settingsGui:FindFirstChild("SettingsButton")
		local buttonScale = ensureScale(settingsButton, "ResponsiveScale")
		if buttonScale then
			buttonScale.Scale = tiny and 0.82 or compact and 0.92 or 1
		end

		local settingsPanel = settingsGui:FindFirstChild("SettingsPanel")
		local panelScale = ensureScale(settingsPanel, "ResponsiveScale")
		if panelScale then
			panelScale.Scale = tiny and 0.82 or compact and 0.92 or 1
		end
		if settingsPanel then
			settingsPanel.Position = tiny and UDim2.new(1, -12, 0, 64) or UDim2.new(1, -18, 0, 68)
		end
	end

	player:SetAttribute("CompactUI", compact)
	player:SetAttribute("TinyUI", tiny)
	player:SetAttribute("ViewportWidth", math.floor(viewport.X))
	player:SetAttribute("ViewportHeight", math.floor(viewport.Y))
end

local scheduled = false
local function scheduleApply()
	if scheduled then
		return
	end
	scheduled = true
	task.defer(function()
		scheduled = false
		apply()
	end)
end

playerGui.ChildAdded:Connect(function()
	task.delay(0.05, scheduleApply)
end)

local cameraViewportConnection

local function bindCamera(camera)
	if cameraViewportConnection then
		cameraViewportConnection:Disconnect()
		cameraViewportConnection = nil
	end
	if not camera then
		return
	end
	cameraViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(scheduleApply)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindCamera(Workspace.CurrentCamera)
	scheduleApply()
end)

bindCamera(Workspace.CurrentCamera)
task.delay(0.2, apply)
task.delay(1, apply)
