local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastSettings"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 45
gui.Parent = player:WaitForChild("PlayerGui")

if player:GetAttribute("SessionFXMode") == nil then
	player:SetAttribute("SessionFXMode", "AUTO")
end
if player:GetAttribute("ReducedFlashes") == nil then
	player:SetAttribute("ReducedFlashes", false)
end
if player:GetAttribute("HideDamageNumbers") == nil then
	player:SetAttribute("HideDamageNumbers", false)
end
if player:GetAttribute("ReducedMotion") == nil then
	player:SetAttribute("ReducedMotion", false)
end

local function rounded(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 10)
	corner.Parent = parent
end

local openButton = Instance.new("TextButton")
openButton.Name = "SettingsButton"
openButton.AnchorPoint = Vector2.new(1, 0)
openButton.Position = UDim2.new(1, -148, 0, 18)
openButton.Size = UDim2.fromOffset(108, 42)
openButton.BackgroundColor3 = Color3.fromRGB(43, 32, 45)
openButton.BackgroundTransparency = 0.08
openButton.BorderSizePixel = 0
openButton.Text = "SETTINGS"
openButton.TextColor3 = Color3.fromRGB(225, 208, 218)
openButton.Font = Enum.Font.GothamBlack
openButton.TextSize = 13
openButton.Parent = gui
rounded(openButton, 12)

local panel = Instance.new("Frame")
panel.Name = "SettingsPanel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -18, 0, 68)
panel.Size = UDim2.fromOffset(320, 300)
panel.BackgroundColor3 = Color3.fromRGB(23, 17, 24)
panel.BackgroundTransparency = 0.03
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
rounded(panel, 16)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(105, 70, 112)
stroke.Thickness = 2
stroke.Transparency = 0.15
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -68, 0, 42)
title.Position = UDim2.fromOffset(14, 8)
title.BackgroundTransparency = 1
title.Text = "SETTINGS"
title.TextColor3 = Color3.fromRGB(242, 222, 222)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 10)
close.Size = UDim2.fromOffset(42, 36)
close.BackgroundColor3 = Color3.fromRGB(69, 38, 44)
close.BorderSizePixel = 0
close.Text = "×"
close.TextColor3 = Color3.fromRGB(250, 220, 215)
close.Font = Enum.Font.GothamBlack
close.TextSize = 22
close.Parent = panel
rounded(close, 10)

local list = Instance.new("Frame")
list.Position = UDim2.fromOffset(14, 58)
list.Size = UDim2.new(1, -28, 1, -72)
list.BackgroundTransparency = 1
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 9)
layout.Parent = list

local function row(labelText, valueText, callback)
	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 48)
	rowFrame.BackgroundColor3 = Color3.fromRGB(38, 29, 40)
	rowFrame.BackgroundTransparency = 0.08
	rowFrame.BorderSizePixel = 0
	rowFrame.Parent = list
	rounded(rowFrame, 10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.58, -10, 1, 0)
	label.Position = UDim2.fromOffset(10, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(222, 205, 208)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -8, 0.5, 0)
	button.Size = UDim2.new(0.40, 0, 0, 34)
	button.BackgroundColor3 = Color3.fromRGB(72, 49, 72)
	button.BorderSizePixel = 0
	button.Text = valueText()
	button.TextColor3 = Color3.fromRGB(245, 225, 218)
	button.Font = Enum.Font.GothamBlack
	button.TextSize = 12
	button.Parent = rowFrame
	rounded(button, 9)

	button.Activated:Connect(function()
		callback()
		button.Text = valueText()
	end)

	return button
end

local fxModes = {"AUTO", "HIGH", "LOW"}
row("Visual effects", function()
	return player:GetAttribute("SessionFXMode") or "AUTO"
end, function()
	local current = player:GetAttribute("SessionFXMode") or "AUTO"
	local index = table.find(fxModes, current) or 1
	index = index % #fxModes + 1
	player:SetAttribute("SessionFXMode", fxModes[index])
end)

row("Reduced flashes", function()
	return player:GetAttribute("ReducedFlashes") == true and "ON" or "OFF"
end, function()
	player:SetAttribute("ReducedFlashes", not (player:GetAttribute("ReducedFlashes") == true))
end)

row("Damage numbers", function()
	return player:GetAttribute("HideDamageNumbers") == true and "OFF" or "ON"
end, function()
	player:SetAttribute("HideDamageNumbers", not (player:GetAttribute("HideDamageNumbers") == true))
end)

row("Camera motion", function()
	return player:GetAttribute("ReducedMotion") == true and "OFF" or "ON"
end, function()
	player:SetAttribute("ReducedMotion", not (player:GetAttribute("ReducedMotion") == true))
end)

openButton.Activated:Connect(function()
	panel.Visible = not panel.Visible
end)

close.Activated:Connect(function()
	panel.Visible = false
end)
