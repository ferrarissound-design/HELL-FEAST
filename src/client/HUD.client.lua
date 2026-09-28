local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local notifyRemote = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("Notify")

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(310, 180)
panel.Position = UDim2.fromOffset(18, 18)
panel.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(125, 48, 52)
stroke.Transparency = 0.15
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
timer.Size = UDim2.fromOffset(130, 32)
timer.Position = UDim2.new(1, -142, 0, 8)
timer.BackgroundTransparency = 1
timer.TextColor3 = Color3.fromRGB(255, 130, 100)
timer.TextXAlignment = Enum.TextXAlignment.Right
timer.Font = Enum.Font.GothamBold
timer.TextSize = 20
timer.Parent = panel

local hungerText = Instance.new("TextLabel")
hungerText.Size = UDim2.new(1, -20, 0, 24)
hungerText.Position = UDim2.fromOffset(10, 48)
hungerText.BackgroundTransparency = 1
hungerText.TextColor3 = Color3.fromRGB(245, 225, 205)
hungerText.TextXAlignment = Enum.TextXAlignment.Left
hungerText.Font = Enum.Font.GothamBold
hungerText.TextSize = 16
hungerText.Parent = panel

local hungerBack = Instance.new("Frame")
hungerBack.Size = UDim2.new(1, -20, 0, 17)
hungerBack.Position = UDim2.fromOffset(10, 74)
hungerBack.BackgroundColor3 = Color3.fromRGB(62, 43, 42)
hungerBack.BorderSizePixel = 0
hungerBack.Parent = panel
Instance.new("UICorner", hungerBack).CornerRadius = UDim.new(1, 0)

local hungerFill = Instance.new("Frame")
hungerFill.Size = UDim2.fromScale(1, 1)
hungerFill.BackgroundColor3 = Color3.fromRGB(235, 111, 62)
hungerFill.BorderSizePixel = 0
hungerFill.Parent = hungerBack
Instance.new("UICorner", hungerFill).CornerRadius = UDim.new(1, 0)

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1, -20, 0, 38)
stats.Position = UDim2.fromOffset(10, 101)
stats.BackgroundTransparency = 1
stats.TextColor3 = Color3.fromRGB(220, 210, 205)
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextYAlignment = Enum.TextYAlignment.Top
stats.Font = Enum.Font.GothamMedium
stats.TextSize = 15
stats.Parent = panel

local parts = Instance.new("TextLabel")
parts.Size = UDim2.new(1, -20, 0, 35)
parts.Position = UDim2.fromOffset(10, 140)
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
notification.Size = UDim2.new(0.78, 0, 0, 58)
notification.BackgroundColor3 = Color3.fromRGB(35, 18, 22)
notification.BackgroundTransparency = 1
notification.TextTransparency = 1
notification.TextColor3 = Color3.fromRGB(255, 225, 210)
notification.TextWrapped = true
notification.Font = Enum.Font.GothamBold
notification.TextSize = 19
notification.BorderSizePixel = 0
notification.Parent = gui
Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 12)

local hint = Instance.new("TextLabel")
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -20)
hint.Size = UDim2.new(0.9, 0, 0, 48)
hint.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
hint.BackgroundTransparency = 0.2
hint.TextColor3 = Color3.fromRGB(245, 230, 220)
hint.Text = "Kill demons → graft their parts   |   Capture Lost Souls → cook at HELL KITCHEN"
hint.TextWrapped = true
hint.Font = Enum.Font.GothamMedium
hint.TextSize = 15
hint.BorderSizePixel = 0
hint.Parent = gui
Instance.new("UICorner", hint).CornerRadius = UDim.new(0, 12)

task.delay(12, function()
	TweenService:Create(hint, TweenInfo.new(0.6), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
end)

local noticeVersion = 0
local function showNotice(text)
	noticeVersion += 1
	local version = noticeVersion
	notification.Text = tostring(text)
	TweenService:Create(notification, TweenInfo.new(0.18), {
		TextTransparency = 0,
		BackgroundTransparency = 0.15,
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

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local slots = {"HEAD", "EYE", "LEFT_ARM", "RIGHT_ARM", "LEGS", "BACK"}

local function refresh()
	local hunger = player:GetAttribute("Hunger") or Config.Hunger.Max
	hungerText.Text = string.format("HUNGER  %d%%", math.floor(hunger + 0.5))
	hungerFill.Size = UDim2.fromScale(math.clamp(hunger / Config.Hunger.Max, 0, 1), 1)

	local state = Workspace:GetAttribute("RunState") or ""
	local timeLeft = Workspace:GetAttribute("RunTimeLeft") or 0
	timer.Text = state .. "  " .. formatTime(timeLeft)

	stats.Text = string.format(
		"Souls: %d     Demon DNA: %d\nKills: %d     Power: x%.2f",
		player:GetAttribute("Souls") or 0,
		player:GetAttribute("DemonDNA") or 0,
		player:GetAttribute("Kills") or 0,
		player:GetAttribute("DamageMultiplier") or 1
	)

	local equipped = {}
	for _, slot in ipairs(slots) do
		local value = player:GetAttribute("Part_" .. slot)
		if value and value ~= "" then
			table.insert(equipped, value)
		end
	end
	parts.Text = #equipped > 0 and ("GRAFTS: " .. table.concat(equipped, " / ")) or "GRAFTS: none"
end

for _, attribute in ipairs({
	"Hunger", "Souls", "DemonDNA", "Kills", "DamageMultiplier",
	"Part_HEAD", "Part_EYE", "Part_LEFT_ARM", "Part_RIGHT_ARM", "Part_LEGS", "Part_BACK",
}) do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end

Workspace:GetAttributeChangedSignal("RunState"):Connect(refresh)
Workspace:GetAttributeChangedSignal("RunTimeLeft"):Connect(refresh)

refresh()
