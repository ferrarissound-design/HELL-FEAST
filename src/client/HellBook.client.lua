local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local feedback = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "HellBookAndResults"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 18
gui.Parent = player:WaitForChild("PlayerGui")

local function rounded(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 2
	s.Transparency = transparency or 0
	s.Parent = parent
end

local bookButton = Instance.new("TextButton")
bookButton.Name = "HellBookButton"
bookButton.AnchorPoint = Vector2.new(1, 0)
bookButton.Position = UDim2.new(1, -18, 0, 18)
bookButton.Size = UDim2.fromOffset(118, 42)
bookButton.BackgroundColor3 = Color3.fromRGB(45, 31, 44)
bookButton.BackgroundTransparency = 0.08
bookButton.BorderSizePixel = 0
bookButton.Text = "HELL BOOK"
bookButton.TextColor3 = Color3.fromRGB(235, 210, 205)
bookButton.Font = Enum.Font.GothamBlack
bookButton.TextSize = 14
bookButton.Parent = gui
rounded(bookButton, 12)
stroke(bookButton, Color3.fromRGB(115, 70, 95), 2, 0.2)

local bookFrame = Instance.new("Frame")
bookFrame.Name = "HellBookFrame"
bookFrame.AnchorPoint = Vector2.new(0.5, 0.5)
bookFrame.Position = UDim2.fromScale(0.5, 0.5)
bookFrame.Size = UDim2.new(0.88, 0, 0.82, 0)
bookFrame.BackgroundColor3 = Color3.fromRGB(23, 16, 22)
bookFrame.BackgroundTransparency = 0.02
bookFrame.BorderSizePixel = 0
bookFrame.Visible = false
bookFrame.Parent = gui
rounded(bookFrame, 18)
stroke(bookFrame, Color3.fromRGB(120, 67, 91), 2, 0.08)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 48)
title.Position = UDim2.fromOffset(18, 10)
title.BackgroundTransparency = 1
title.Text = "HELL BOOK"
title.TextColor3 = Color3.fromRGB(245, 215, 205)
title.Font = Enum.Font.GothamBlack
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = bookFrame

local progress = Instance.new("TextLabel")
progress.Size = UDim2.new(1, -105, 0, 26)
progress.Position = UDim2.fromOffset(18, 52)
progress.BackgroundTransparency = 1
progress.TextColor3 = Color3.fromRGB(185, 155, 175)
progress.Font = Enum.Font.GothamBold
progress.TextSize = 13
progress.TextXAlignment = Enum.TextXAlignment.Left
progress.Parent = bookFrame

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -14, 0, 14)
close.Size = UDim2.fromOffset(48, 42)
close.BackgroundColor3 = Color3.fromRGB(72, 39, 46)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 222, 215)
close.Font = Enum.Font.GothamBlack
close.TextSize = 24
close.BorderSizePixel = 0
close.Parent = bookFrame
rounded(close, 10)

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -36, 0, 40)
tabs.Position = UDim2.fromOffset(18, 84)
tabs.BackgroundTransparency = 1
tabs.Parent = bookFrame

local demonTab = Instance.new("TextButton")
demonTab.Size = UDim2.new(0.5, -5, 1, 0)
demonTab.BackgroundColor3 = Color3.fromRGB(86, 43, 48)
demonTab.Text = "DEMONS"
demonTab.TextColor3 = Color3.fromRGB(245, 220, 210)
demonTab.Font = Enum.Font.GothamBlack
demonTab.TextSize = 14
demonTab.BorderSizePixel = 0
demonTab.Parent = tabs
rounded(demonTab, 10)

local partTab = Instance.new("TextButton")
partTab.AnchorPoint = Vector2.new(1, 0)
partTab.Position = UDim2.new(1, 0, 0, 0)
partTab.Size = UDim2.new(0.5, -5, 1, 0)
partTab.BackgroundColor3 = Color3.fromRGB(49, 37, 52)
partTab.Text = "GRAFTS"
partTab.TextColor3 = Color3.fromRGB(210, 190, 205)
partTab.Font = Enum.Font.GothamBlack
partTab.TextSize = 14
partTab.BorderSizePixel = 0
partTab.Parent = tabs
rounded(partTab, 10)

local scroller = Instance.new("ScrollingFrame")
scroller.Size = UDim2.new(1, -36, 1, -142)
scroller.Position = UDim2.fromOffset(18, 132)
scroller.BackgroundTransparency = 1
scroller.BorderSizePixel = 0
scroller.ScrollBarThickness = 5
scroller.CanvasSize = UDim2.fromOffset(0, 0)
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.Parent = bookFrame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.Parent = scroller

local activeTab = "DEMONS"

local function clearEntries()
	for _, child in ipairs(scroller:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function effectText(data)
	local effects = {}
	if data.DamageMultiplier then
		table.insert(effects, string.format("Damage ×%.2f", data.DamageMultiplier))
	end
	if data.WalkSpeedBonus then
		table.insert(effects, string.format("Speed %+d", data.WalkSpeedBonus))
	end
	if data.HungerMultiplier then
		table.insert(effects, string.format("Hunger ×%.2f", data.HungerMultiplier))
	end
	return table.concat(effects, "  •  ")
end

local function entryCard(name, note, discovered, accent)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 88)
	card.BackgroundColor3 = discovered and Color3.fromRGB(39, 29, 36) or Color3.fromRGB(29, 26, 29)
	card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0
	card.Parent = scroller
	rounded(card, 12)
	stroke(card, discovered and accent or Color3.fromRGB(70, 65, 69), 1.5, discovered and 0.2 or 0.55)

	local heading = Instance.new("TextLabel")
	heading.Size = UDim2.new(1, -20, 0, 28)
	heading.Position = UDim2.fromOffset(10, 8)
	heading.BackgroundTransparency = 1
	heading.Text = discovered and name or "???"
	heading.TextColor3 = discovered and Color3.fromRGB(245, 221, 210) or Color3.fromRGB(130, 125, 130)
	heading.Font = Enum.Font.GothamBlack
	heading.TextSize = 16
	heading.TextXAlignment = Enum.TextXAlignment.Left
	heading.Parent = card

	local body = Instance.new("TextLabel")
	body.Size = UDim2.new(1, -20, 0, 42)
	body.Position = UDim2.fromOffset(10, 38)
	body.BackgroundTransparency = 1
	body.Text = discovered and note or "Not yet recorded in the HELL BOOK."
	body.TextColor3 = discovered and Color3.fromRGB(202, 187, 184) or Color3.fromRGB(112, 108, 112)
	body.Font = Enum.Font.Gotham
	body.TextSize = 13
	body.TextWrapped = true
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Parent = card
end

local function counts()
	local demons = 0
	local parts = 0
	for _, key in ipairs(Config.HellBook.DemonOrder) do
		if player:GetAttribute("Book_Demon_" .. key) == true then
			demons += 1
		end
	end
	for _, key in ipairs(Config.HellBook.PartOrder) do
		if player:GetAttribute("Book_Part_" .. key) == true then
			parts += 1
		end
	end
	return demons, parts
end

local function refreshBook()
	local demonCount, partCount = counts()
	progress.Text = string.format(
		"DEMONS %d/%d   •   GRAFTS %d/%d   •   BEST CIRCLE %d",
		demonCount,
		#Config.HellBook.DemonOrder,
		partCount,
		#Config.HellBook.PartOrder,
		player:GetAttribute("BestCircle") or 0
	)

	clearEntries()

	if activeTab == "DEMONS" then
		demonTab.BackgroundColor3 = Color3.fromRGB(86, 43, 48)
		partTab.BackgroundColor3 = Color3.fromRGB(49, 37, 52)

		for _, key in ipairs(Config.HellBook.DemonOrder) do
			local data = Config.Demons[key]
			local discovered = player:GetAttribute("Book_Demon_" .. key) == true
			entryCard(
				data and data.DisplayName or key,
				Config.HellBook.DemonNotes[key] or "Recorded demon.",
				discovered,
				Color3.fromRGB(132, 64, 62)
			)
		end
	else
		partTab.BackgroundColor3 = Color3.fromRGB(76, 52, 87)
		demonTab.BackgroundColor3 = Color3.fromRGB(49, 37, 52)

		for _, key in ipairs(Config.HellBook.PartOrder) do
			local data = Config.Parts[key]
			local discovered = player:GetAttribute("Book_Part_" .. key) == true
			local note = data and string.format("%s slot  •  %s", data.Slot, effectText(data)) or "Recorded graft."
			entryCard(
				data and data.DisplayName or key,
				note,
				discovered,
				Color3.fromRGB(108, 72, 130)
			)
		end
	end
end

bookButton.Activated:Connect(function()
	bookFrame.Visible = not bookFrame.Visible
	if bookFrame.Visible then
		refreshBook()
	end
end)

close.Activated:Connect(function()
	bookFrame.Visible = false
end)

demonTab.Activated:Connect(function()
	activeTab = "DEMONS"
	refreshBook()
end)

partTab.Activated:Connect(function()
	activeTab = "PARTS"
	refreshBook()
end)

for _, key in ipairs(Config.HellBook.DemonOrder) do
	player:GetAttributeChangedSignal("Book_Demon_" .. key):Connect(function()
		if bookFrame.Visible then
			refreshBook()
		end
	end)
end

for _, key in ipairs(Config.HellBook.PartOrder) do
	player:GetAttributeChangedSignal("Book_Part_" .. key):Connect(function()
		if bookFrame.Visible then
			refreshBook()
		end
	end)
end

local discoveryBanner = Instance.new("TextLabel")
discoveryBanner.Name = "DiscoveryBanner"
discoveryBanner.AnchorPoint = Vector2.new(0.5, 0.5)
discoveryBanner.Position = UDim2.fromScale(0.5, 0.78)
discoveryBanner.Size = UDim2.fromOffset(380, 60)
discoveryBanner.BackgroundColor3 = Color3.fromRGB(38, 25, 36)
discoveryBanner.BackgroundTransparency = 1
discoveryBanner.TextTransparency = 1
discoveryBanner.TextColor3 = Color3.fromRGB(245, 215, 202)
discoveryBanner.Font = Enum.Font.GothamBlack
discoveryBanner.TextSize = 18
discoveryBanner.TextWrapped = true
discoveryBanner.BorderSizePixel = 0
discoveryBanner.Parent = gui
rounded(discoveryBanner, 14)

local result = Instance.new("Frame")
result.Name = "ResultFrame"
result.AnchorPoint = Vector2.new(0.5, 0.5)
result.Position = UDim2.fromScale(0.5, 0.5)
result.Size = UDim2.new(0.82, 0, 0, 350)
result.BackgroundColor3 = Color3.fromRGB(22, 15, 20)
result.BackgroundTransparency = 0.02
result.BorderSizePixel = 0
result.Visible = false
result.Parent = gui
rounded(result, 18)
stroke(result, Color3.fromRGB(130, 68, 74), 3, 0.08)

local resultTitle = Instance.new("TextLabel")
resultTitle.Size = UDim2.new(1, -30, 0, 66)
resultTitle.Position = UDim2.fromOffset(15, 16)
resultTitle.BackgroundTransparency = 1
resultTitle.Text = "HELL RUN COMPLETE"
resultTitle.TextColor3 = Color3.fromRGB(255, 213, 190)
resultTitle.Font = Enum.Font.GothamBlack
resultTitle.TextSize = 26
resultTitle.TextWrapped = true
resultTitle.Parent = result

local resultStats = Instance.new("TextLabel")
resultStats.Size = UDim2.new(1, -36, 0, 190)
resultStats.Position = UDim2.fromOffset(18, 92)
resultStats.BackgroundTransparency = 1
resultStats.TextColor3 = Color3.fromRGB(222, 203, 197)
resultStats.Font = Enum.Font.GothamMedium
resultStats.TextSize = 17
resultStats.TextWrapped = true
resultStats.TextXAlignment = Enum.TextXAlignment.Left
resultStats.TextYAlignment = Enum.TextYAlignment.Top
resultStats.Parent = result

local resultClose = Instance.new("TextButton")
resultClose.AnchorPoint = Vector2.new(0.5, 1)
resultClose.Position = UDim2.new(0.5, 0, 1, -20)
resultClose.Size = UDim2.new(0.72, 0, 0, 50)
resultClose.BackgroundColor3 = Color3.fromRGB(91, 48, 53)
resultClose.BorderSizePixel = 0
resultClose.Text = "RETURN TO HELL"
resultClose.TextColor3 = Color3.fromRGB(255, 225, 210)
resultClose.Font = Enum.Font.GothamBlack
resultClose.TextSize = 16
resultClose.Parent = result
rounded(resultClose, 13)

resultClose.Activated:Connect(function()
	result.Visible = false
end)

local discoveryVersion = 0
local function showDiscovery(payload)
	discoveryVersion += 1
	local version = discoveryVersion
	discoveryBanner.Text = string.format("NEW HELL BOOK ENTRY
%s • %s", payload.Category or "ENTRY", payload.Name or "UNKNOWN")
	discoveryBanner.BackgroundTransparency = 0.10
	discoveryBanner.TextTransparency = 0
	discoveryBanner.Size = UDim2.fromOffset(410, 68)
	TweenService:Create(discoveryBanner, TweenInfo.new(0.22, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(380, 60),
	}):Play()

	task.delay(2.4, function()
		if version ~= discoveryVersion then
			return
		end
		TweenService:Create(discoveryBanner, TweenInfo.new(0.35), {
			BackgroundTransparency = 1,
			TextTransparency = 1,
		}):Play()
	end)
end

local function showResult(payload)
	bookFrame.Visible = false
	local newBest = payload.NewBest == true
	resultTitle.Text = newBest
		and string.format("NEW BEST • CIRCLE %d", payload.Circle or 1)
		or string.format("HELL RUN • CIRCLE %d", payload.Circle or 1)

	resultStats.Text = string.format(
		"%s

DEMONS KILLED   %d
LOST SOULS      %d
MEALS COOKED    %d
GRAFTS USED     %d
DEATHS          %d
NEW DISCOVERIES %d

DEMON DNA BANKED   +%d",
		payload.Reason or "Run ended.",
		payload.Kills or 0,
		payload.Souls or 0,
		payload.Cooked or 0,
		payload.Grafts or 0,
		payload.Deaths or 0,
		payload.Discoveries or 0,
		payload.DNA or 0
	)

	result.Visible = true
	result.Size = UDim2.new(0.25, 0, 0, 350)
	TweenService:Create(result, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(0.82, 0, 0, 350),
	}):Play()
end

feedback.OnClientEvent:Connect(function(kind, payload)
	if kind == "DISCOVERY" then
		showDiscovery(payload or {})
	elseif kind == "RUN_RESULT" then
		showResult(payload or {})
	end
end)

Workspace:GetAttributeChangedSignal("RunState"):Connect(function()
	local state = Workspace:GetAttribute("RunState")
	if state == "HELL RUN" or state == "BOSS" then
		result.Visible = false
	end
end)

refreshBook()
