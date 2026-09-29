local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("HellFeastRemotes")
local notifyRemote = remotes:WaitForChild("Notify")
local decisionVoteRemote = remotes:WaitForChild("DecisionVote")

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function rounded(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
	return corner
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(340, 252)
panel.Position = UDim2.fromOffset(16, 16)
panel.BackgroundColor3 = Color3.fromRGB(27, 17, 22)
panel.BackgroundTransparency = 0.10
panel.BorderSizePixel = 0
panel.Parent = gui
rounded(panel, 14)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(125, 48, 52)
stroke.Transparency = 0.12
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.fromOffset(10, 7)
title.BackgroundTransparency = 1
title.Text = "HELL FEAST"
title.TextColor3 = Color3.fromRGB(255, 215, 200)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.Parent = panel

local timer = Instance.new("TextLabel")
timer.Size = UDim2.fromOffset(170, 32)
timer.Position = UDim2.new(1, -180, 0, 8)
timer.BackgroundTransparency = 1
timer.TextColor3 = Color3.fromRGB(255, 130, 100)
timer.TextXAlignment = Enum.TextXAlignment.Right
timer.Font = Enum.Font.GothamBold
timer.TextSize = 18
timer.Parent = panel

local circleLabel = Instance.new("TextLabel")
circleLabel.Size = UDim2.new(1, -20, 0, 22)
circleLabel.Position = UDim2.fromOffset(10, 40)
circleLabel.BackgroundTransparency = 1
circleLabel.TextColor3 = Color3.fromRGB(190, 155, 210)
circleLabel.TextXAlignment = Enum.TextXAlignment.Left
circleLabel.Font = Enum.Font.GothamBold
circleLabel.TextSize = 14
circleLabel.Parent = panel

local healthText = Instance.new("TextLabel")
healthText.Size = UDim2.new(1, -20, 0, 20)
healthText.Position = UDim2.fromOffset(10, 64)
healthText.BackgroundTransparency = 1
healthText.TextColor3 = Color3.fromRGB(235, 220, 216)
healthText.TextXAlignment = Enum.TextXAlignment.Left
healthText.Font = Enum.Font.GothamBold
healthText.TextSize = 14
healthText.Text = "HEALTH"
healthText.Parent = panel

local healthBack = Instance.new("Frame")
healthBack.Size = UDim2.new(1, -20, 0, 14)
healthBack.Position = UDim2.fromOffset(10, 86)
healthBack.BackgroundColor3 = Color3.fromRGB(58, 40, 44)
healthBack.BorderSizePixel = 0
healthBack.Parent = panel
rounded(healthBack, 7)

local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1, 1)
healthFill.BackgroundColor3 = Color3.fromRGB(188, 72, 70)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBack
rounded(healthFill, 7)

local hungerText = Instance.new("TextLabel")
hungerText.Size = UDim2.new(1, -20, 0, 20)
hungerText.Position = UDim2.fromOffset(10, 105)
hungerText.BackgroundTransparency = 1
hungerText.TextColor3 = Color3.fromRGB(245, 225, 205)
hungerText.TextXAlignment = Enum.TextXAlignment.Left
hungerText.Font = Enum.Font.GothamBold
hungerText.TextSize = 14
hungerText.Parent = panel

local hungerBack = Instance.new("Frame")
hungerBack.Size = UDim2.new(1, -20, 0, 14)
hungerBack.Position = UDim2.fromOffset(10, 127)
hungerBack.BackgroundColor3 = Color3.fromRGB(62, 43, 42)
hungerBack.BorderSizePixel = 0
hungerBack.Parent = panel
rounded(hungerBack, 7)

local hungerFill = Instance.new("Frame")
hungerFill.Size = UDim2.fromScale(1, 1)
hungerFill.BackgroundColor3 = Color3.fromRGB(235, 111, 62)
hungerFill.BorderSizePixel = 0
hungerFill.Parent = hungerBack
rounded(hungerFill, 7)

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1, -20, 0, 42)
stats.Position = UDim2.fromOffset(10, 150)
stats.BackgroundTransparency = 1
stats.TextColor3 = Color3.fromRGB(220, 210, 205)
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextYAlignment = Enum.TextYAlignment.Top
stats.Font = Enum.Font.GothamMedium
stats.TextSize = 13
stats.Parent = panel

local upgrades = Instance.new("TextLabel")
upgrades.Size = UDim2.new(1, -20, 0, 22)
upgrades.Position = UDim2.fromOffset(10, 194)
upgrades.BackgroundTransparency = 1
upgrades.TextColor3 = Color3.fromRGB(205, 170, 140)
upgrades.TextXAlignment = Enum.TextXAlignment.Left
upgrades.Font = Enum.Font.Gotham
upgrades.TextSize = 12
upgrades.Parent = panel

local parts = Instance.new("TextLabel")
parts.Size = UDim2.new(1, -20, 0, 34)
parts.Position = UDim2.fromOffset(10, 216)
parts.BackgroundTransparency = 1
parts.TextColor3 = Color3.fromRGB(188, 154, 205)
parts.TextWrapped = true
parts.TextXAlignment = Enum.TextXAlignment.Left
parts.TextYAlignment = Enum.TextYAlignment.Top
parts.Font = Enum.Font.Gotham
parts.TextSize = 12
parts.Parent = panel

local notification = Instance.new("TextLabel")
notification.AnchorPoint = Vector2.new(0.5, 0)
notification.Position = UDim2.new(0.5, 0, 0, 28)
notification.Size = UDim2.new(0.74, 0, 0, 62)
notification.BackgroundColor3 = Color3.fromRGB(35, 18, 22)
notification.BackgroundTransparency = 1
notification.TextTransparency = 1
notification.TextColor3 = Color3.fromRGB(255, 225, 210)
notification.TextWrapped = true
notification.Font = Enum.Font.GothamBold
notification.TextSize = 19
notification.BorderSizePixel = 0
notification.Parent = gui
rounded(notification, 12)

local hint = Instance.new("TextLabel")
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -18)
hint.Size = UDim2.new(0.92, 0, 0, 52)
hint.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
hint.BackgroundTransparency = 0.16
hint.TextColor3 = Color3.fromRGB(245, 230, 220)
hint.Text = "Kill demons → graft parts   |   Capture Lost Souls → cook   |   Beat THE BUTCHER → escape or descend"
hint.TextWrapped = true
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 14
hint.BorderSizePixel = 0
hint.Parent = gui
rounded(hint, 12)

task.delay(14, function()
	TweenService:Create(hint, TweenInfo.new(0.6), {
		TextTransparency = 1,
		BackgroundTransparency = 1,
	}):Play()
end)

local decisionFrame = Instance.new("Frame")
decisionFrame.Name = "DecisionFrame"
decisionFrame.AnchorPoint = Vector2.new(0.5, 0.5)
decisionFrame.Position = UDim2.fromScale(0.5, 0.52)
decisionFrame.Size = UDim2.new(0.88, 0, 0, 210)
decisionFrame.BackgroundColor3 = Color3.fromRGB(24, 14, 21)
decisionFrame.BackgroundTransparency = 0.04
decisionFrame.BorderSizePixel = 0
decisionFrame.Visible = false
decisionFrame.Parent = gui
rounded(decisionFrame, 18)

local decisionStroke = Instance.new("UIStroke")
decisionStroke.Color = Color3.fromRGB(170, 65, 80)
decisionStroke.Thickness = 3
decisionStroke.Parent = decisionFrame

local decisionTitle = Instance.new("TextLabel")
decisionTitle.Size = UDim2.new(1, -24, 0, 66)
decisionTitle.Position = UDim2.fromOffset(12, 10)
decisionTitle.BackgroundTransparency = 1
decisionTitle.Text = "THE BUTCHER IS DEAD\nWHAT NOW?"
decisionTitle.TextColor3 = Color3.fromRGB(255, 220, 205)
decisionTitle.TextWrapped = true
decisionTitle.Font = Enum.Font.GothamBlack
decisionTitle.TextSize = 22
decisionTitle.Parent = decisionFrame

local escapeButton = Instance.new("TextButton")
escapeButton.Size = UDim2.new(0.46, 0, 0, 82)
escapeButton.Position = UDim2.new(0.03, 0, 0, 100)
escapeButton.BackgroundColor3 = Color3.fromRGB(80, 104, 75)
escapeButton.TextColor3 = Color3.fromRGB(245, 245, 225)
escapeButton.Text = "ESCAPE\nBank Demon DNA"
escapeButton.TextWrapped = true
escapeButton.Font = Enum.Font.GothamBold
escapeButton.TextSize = 17
escapeButton.Parent = decisionFrame
rounded(escapeButton, 14)

local descendButton = Instance.new("TextButton")
descendButton.Size = UDim2.new(0.46, 0, 0, 82)
descendButton.Position = UDim2.new(0.51, 0, 0, 100)
descendButton.BackgroundColor3 = Color3.fromRGB(111, 48, 63)
descendButton.TextColor3 = Color3.fromRGB(255, 225, 220)
descendButton.Text = "DESCEND\nKeep grafts. Risk everything."
descendButton.TextWrapped = true
descendButton.Font = Enum.Font.GothamBold
descendButton.TextSize = 17
descendButton.Parent = decisionFrame
rounded(descendButton, 14)

local voteStatus = Instance.new("TextLabel")
voteStatus.Size = UDim2.new(1, -20, 0, 20)
voteStatus.Position = UDim2.new(0, 10, 1, -24)
voteStatus.BackgroundTransparency = 1
voteStatus.TextColor3 = Color3.fromRGB(210, 190, 190)
voteStatus.Text = ""
voteStatus.Font = Enum.Font.Gotham
voteStatus.TextSize = 12
voteStatus.Parent = decisionFrame

local noticeVersion = 0
local function showNotice(text)
	noticeVersion += 1
	local version = noticeVersion
	notification.Text = tostring(text)
	TweenService:Create(notification, TweenInfo.new(0.18), {
		TextTransparency = 0,
		BackgroundTransparency = 0.12,
	}):Play()

	task.delay(3.2, function()
		if version ~= noticeVersion then
			return
		end
		TweenService:Create(notification, TweenInfo.new(0.4), {
			TextTransparency = 1,
			BackgroundTransparency = 1,
		}):Play()
	end)
end

notifyRemote.OnClientEvent:Connect(showNotice)

escapeButton.Activated:Connect(function()
	decisionVoteRemote:FireServer("ESCAPE")
end)

descendButton.Activated:Connect(function()
	decisionVoteRemote:FireServer("DESCEND")
end)

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local slots = {"HEAD", "EYE", "LEFT_ARM", "RIGHT_ARM", "LEGS", "BACK"}

local function refresh()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local health = humanoid and humanoid.Health or 0
	local maxHealth = humanoid and humanoid.MaxHealth or 100
	healthText.Text = string.format("HEALTH  %d / %d", math.ceil(health), math.ceil(maxHealth))
	healthFill.Size = UDim2.fromScale(math.clamp(health / math.max(1, maxHealth), 0, 1), 1)
	if health / math.max(1, maxHealth) <= 0.30 then
		healthFill.BackgroundColor3 = Color3.fromRGB(225, 62, 62)
	else
		healthFill.BackgroundColor3 = Color3.fromRGB(188, 72, 70)
	end

	local hunger = player:GetAttribute("Hunger") or Config.Hunger.Max
	local maxHunger = player:GetAttribute("MaxHunger") or Config.Hunger.Max
	hungerText.Text = string.format("HUNGER  %d / %d", math.floor(hunger + 0.5), maxHunger)
	hungerFill.Size = UDim2.fromScale(math.clamp(hunger / math.max(1, maxHunger), 0, 1), 1)

	local state = Workspace:GetAttribute("RunState") or ""
	local timeLeft = Workspace:GetAttribute("RunTimeLeft") or 0
	local circle = Workspace:GetAttribute("Circle") or 1
	timer.Text = state .. "  " .. formatTime(timeLeft)
	local directorMode = Workspace:GetAttribute("DirectorMode") or "STALK"
	circleLabel.Text = string.format(
		"CIRCLE %d / %d    BEST: %d    HELL: %s",
		circle,
		Config.MaxCircle,
		player:GetAttribute("BestCircle") or 0,
		directorMode
	)

	stats.Text = string.format(
		"Souls: %d     Banked DNA: %d\nUnbanked DNA: %d     Kills: %d     Power: x%.2f",
		player:GetAttribute("Souls") or 0,
		player:GetAttribute("DemonDNA") or 0,
		player:GetAttribute("RunDNA") or 0,
		player:GetAttribute("Kills") or 0,
		player:GetAttribute("DamageMultiplier") or 1
	)

	local readOnly = player:GetAttribute("ProgressionReadOnly") == true
	upgrades.Text = string.format(
		"VITALITY %d   METABOLISM %d   BUTCHERY %d%s",
		player:GetAttribute("Upgrade_Vitality") or 0,
		player:GetAttribute("Upgrade_Metabolism") or 0,
		player:GetAttribute("Upgrade_Butchery") or 0,
		readOnly and "   • SAVE READ-ONLY" or ""
	)
	upgrades.TextColor3 = readOnly and Color3.fromRGB(255, 135, 120) or Color3.fromRGB(205, 170, 140)

	local equipped = {}
	for _, slot in ipairs(slots) do
		local value = player:GetAttribute("Part_" .. slot)
		if value and value ~= "" then
			table.insert(equipped, value)
		end
	end
	parts.Text = #equipped > 0 and ("GRAFTS: " .. table.concat(equipped, " / ")) or "GRAFTS: none"

	local decisionOpen = Workspace:GetAttribute("DecisionOpen") == true
	local decisionEligible = player:GetAttribute("DecisionEligible") == true
	local vote = player:GetAttribute("DecisionVote") or ""
	local canVote = decisionEligible and vote == ""
	decisionFrame.Visible = decisionOpen
	descendButton.Visible = circle < Config.MaxCircle
	escapeButton.Active = canVote
	escapeButton.AutoButtonColor = canVote
	descendButton.Active = canVote
	descendButton.AutoButtonColor = canVote
	escapeButton.BackgroundTransparency = canVote and 0 or 0.42
	descendButton.BackgroundTransparency = canVote and 0 or 0.42
	if decisionOpen and circle >= Config.MaxCircle then
		decisionTitle.Text = "DEEPEST CIRCLE CLEARED\nESCAPE WITH YOUR HAUL"
	else
		decisionTitle.Text = "THE BUTCHER IS DEAD\nWHAT NOW?"
	end

	local escapeVotes = Workspace:GetAttribute("DecisionEscapeVotes") or 0
	local descendVotes = Workspace:GetAttribute("DecisionDescendVotes") or 0
	local eligible = Workspace:GetAttribute("DecisionEligible") or 0
	local remaining = Workspace:GetAttribute("RunTimeLeft") or 0

	if decisionOpen and not decisionEligible then
		voteStatus.Text = "JOINED LATE • following the group decision"
	elseif vote ~= "" then
		voteStatus.Text = string.format(
			"YOUR VOTE: %s   •   ESCAPE %d  /  DESCEND %d   •   %ds",
			vote,
			escapeVotes,
			descendVotes,
			math.max(0, math.floor(remaining))
		)
	elseif decisionOpen then
		voteStatus.Text = string.format(
			"ESCAPE %d  /  DESCEND %d   •   %d voters   •   %ds",
			escapeVotes,
			descendVotes,
			eligible,
			math.max(0, math.floor(remaining))
		)
	else
		voteStatus.Text = ""
	end
end

for _, attribute in ipairs({
	"Hunger", "MaxHunger", "Souls", "DemonDNA", "RunDNA", "Kills", "DamageMultiplier", "BestCircle",
	"Upgrade_Vitality", "Upgrade_Metabolism", "Upgrade_Butchery", "DecisionVote", "DecisionEligible", "ProgressionReadOnly",
	"Part_HEAD", "Part_EYE", "Part_LEFT_ARM", "Part_RIGHT_ARM", "Part_LEGS", "Part_BACK",
}) do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end

for _, attribute in ipairs({
	"RunState", "RunTimeLeft", "Circle", "DecisionOpen", "DirectorMode",
	"DecisionEscapeVotes", "DecisionDescendVotes", "DecisionEligible",
}) do
	Workspace:GetAttributeChangedSignal(attribute):Connect(refresh)
end

local healthConnections = {}

local function bindHealth(character)
	for _, connection in ipairs(healthConnections) do
		connection:Disconnect()
	end
	table.clear(healthConnections)

	local humanoid = character:WaitForChild("Humanoid", 8)
	if not humanoid then
		refresh()
		return
	end

	table.insert(healthConnections, humanoid.HealthChanged:Connect(refresh))
	table.insert(healthConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(refresh))
	refresh()
end

player.CharacterAdded:Connect(bindHealth)
if player.Character then
	task.spawn(bindHealth, player.Character)
end

refresh()
