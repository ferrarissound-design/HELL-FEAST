local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local feedback = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastDeathOverlay"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 40
gui.Parent = player:WaitForChild("PlayerGui")

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(20, 5, 9)
shade.BackgroundTransparency = 1
shade.BorderSizePixel = 0
shade.Visible = false
shade.Parent = gui

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.44)
title.Size = UDim2.new(0.88, 0, 0, 72)
title.BackgroundTransparency = 1
title.Text = "YOU DIED"
title.TextColor3 = Color3.fromRGB(245, 105, 95)
title.TextTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 38
title.Parent = shade

local detail = Instance.new("TextLabel")
detail.AnchorPoint = Vector2.new(0.5, 0)
detail.Position = UDim2.new(0.5, 0, 0.52, 0)
detail.Size = UDim2.new(0.88, 0, 0, 82)
detail.BackgroundTransparency = 1
detail.TextColor3 = Color3.fromRGB(235, 210, 205)
detail.TextTransparency = 1
detail.TextWrapped = true
detail.Font = Enum.Font.GothamBold
detail.TextSize = 17
detail.Parent = shade

local version = 0

local function showDeath(payload)
	version += 1
	local current = version
	local lostDNA = math.max(0, tonumber(payload.LostDNA) or 0)

	shade.Visible = true
	shade.BackgroundTransparency = player:GetAttribute("ReducedFlashes") == true and 0.72 or 0.48
	title.TextTransparency = 0
	detail.TextTransparency = 0
	title.Text = "YOU DIED"
	detail.Text = string.format(
		"Grafts stripped • Lost Souls dropped • %d unbanked DNA lost
Returning with a short protection veil.",
		lostDNA
	)

	task.delay(2.15, function()
		if current ~= version then
			return
		end
		TweenService:Create(shade, TweenInfo.new(0.55), {BackgroundTransparency = 1}):Play()
		TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
		TweenService:Create(detail, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
		task.delay(0.6, function()
			if current == version then
				shade.Visible = false
			end
		end)
	end)
end

feedback.OnClientEvent:Connect(function(kind, payload)
	if kind == "PLAYER_DEATH" then
		showDeath(payload or {})
	end
end)
