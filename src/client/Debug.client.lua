local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

if not RunService:IsStudio() then
	return
end

local player = Players.LocalPlayer
local debugRemote = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("DebugCommand")

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastDebug"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 50
gui.Parent = player:WaitForChild("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Position = UDim2.new(1, -126, 0, 68)
toggle.Size = UDim2.fromOffset(108, 36)
toggle.BackgroundColor3 = Color3.fromRGB(52, 39, 58)
toggle.BorderSizePixel = 0
toggle.Text = "DEV PANEL"
toggle.TextColor3 = Color3.fromRGB(245, 225, 215)
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 13
toggle.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggle

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -18, 0, 112)
panel.Size = UDim2.fromOffset(290, 470)
panel.BackgroundColor3 = Color3.fromRGB(22, 17, 24)
panel.BackgroundTransparency = 0.04
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(118, 76, 132)
panelStroke.Thickness = 2
panelStroke.Transparency = 0.15
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 28)
title.Position = UDim2.fromOffset(12, 8)
title.BackgroundTransparency = 1
title.Text = "HELL FEAST • STUDIO QA"
title.TextColor3 = Color3.fromRGB(236, 211, 229)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 34)
status.Position = UDim2.fromOffset(12, 34)
status.BackgroundTransparency = 1
status.Text = "BUILD ? • QA WAITING"
status.TextColor3 = Color3.fromRGB(195, 177, 190)
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.Parent = panel

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(12, 72)
scroll.Size = UDim2.new(1, -24, 1, -84)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = scroll

local function section(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -4, 0, 28)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(180, 142, 190)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 12
	label.Parent = scroll
end

local function button(text, action, payload)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 38)
	b.BackgroundColor3 = Color3.fromRGB(48, 35, 51)
	b.BackgroundTransparency = 0.05
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(235, 218, 216)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Parent = scroll

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 9)
	c.Parent = b

	b.Activated:Connect(function()
		debugRemote:FireServer(action, payload)
	end)
end

section("PLAYER / FAILURE TESTS")
button("Restore HP + Hunger", "HEAL_FEED")
button("Set Hunger → 10", "LOW_HUNGER")
button("+3 Lost Souls", "SOULS")
button("Kill Player", "KILL_SELF")
button("Test OOB Recovery", "OOB_TEST")
button("Save Profile Now", "SAVE_NOW")
button("Teleport → HELL KITCHEN", "TP_KITCHEN")
button("Teleport → SLAUGHTER PIT", "TP_BOSS")

section("RUN / BOSS")
button("Circle 1", "CIRCLE", 1)
button("Circle 2", "CIRCLE", 2)
button("Circle 3", "CIRCLE", 3)
button("Spawn THE BUTCHER Now", "BOSS_NOW")
button("Force Butcher Phase II", "PHASE_2")
button("Force Butcher Phase III", "PHASE_3")
button("Set Butcher → 1 HP", "BOSS_1HP")
button("Clear Demons / Souls / Drops", "CLEAR")

section("SPAWN DEMONS")
button("Spawn Imp", "SPAWN", "Imp")
button("Spawn Horned Brute", "SPAWN", "Brute")
button("Spawn Watcher", "SPAWN", "Watcher")
button("Spawn Furnace Hound", "SPAWN", "FurnaceHound")
button("Spawn Bone Crawler", "SPAWN", "Crawler")

section("GRAFTS")
button("Graft Imp Legs", "GRAFT", "ImpLegs")
button("Graft Brute Arm", "GRAFT", "BruteArm")
button("Graft Watcher Eye", "GRAFT", "WatcherEye")
button("Graft Demon Horn", "GRAFT", "DemonHorn")
button("Graft Demon Wings", "GRAFT", "DemonWings")
button("Graft Claw Arm", "GRAFT", "ClawArm")
button("Graft Butcher Arm", "GRAFT", "ButcherArm")

local function refreshStatus()
	local buildId = Workspace:GetAttribute("BuildId") or "?"
	local qaStatus = Workspace:GetAttribute("QAStatus") or "WAITING"
	local passed = Workspace:GetAttribute("QAPassed") or 0
	local failed = Workspace:GetAttribute("QAFailed") or 0

	status.Text = string.format("%s • QA %s • %d PASS / %d FAIL", buildId, qaStatus, passed, failed)
	if qaStatus == "PASS" then
		status.TextColor3 = Color3.fromRGB(145, 225, 165)
	elseif qaStatus == "FAIL" then
		status.TextColor3 = Color3.fromRGB(255, 120, 110)
	else
		status.TextColor3 = Color3.fromRGB(195, 177, 190)
	end
end

for _, attribute in ipairs({"BuildId", "QAStatus", "QAPassed", "QAFailed"}) do
	Workspace:GetAttributeChangedSignal(attribute):Connect(refreshStatus)
end
refreshStatus()

toggle.Activated:Connect(function()
	panel.Visible = not panel.Visible
	toggle.Text = panel.Visible and "CLOSE DEV" or "DEV PANEL"
end)
