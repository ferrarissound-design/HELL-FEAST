local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local waitStarted = os.clock()
while player:GetAttribute("TotalRuns") == nil and os.clock() - waitStarted < 6 do
	task.wait(0.1)
end

if (player:GetAttribute("TotalRuns") or 0) > 0 then
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastTutorial"
gui.ResetOnSpawn = false
gui.DisplayOrder = 15
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0, 1)
card.Position = UDim2.new(0, 18, 1, -82)
card.Size = UDim2.fromOffset(330, 92)
card.BackgroundColor3 = Color3.fromRGB(25, 16, 21)
card.BackgroundTransparency = 0.08
card.BorderSizePixel = 0
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120, 55, 72)
stroke.Thickness = 2
stroke.Parent = card

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1, -20, 0, 28)
heading.Position = UDim2.fromOffset(10, 8)
heading.BackgroundTransparency = 1
heading.Text = "FIRST DESCENT"
heading.TextColor3 = Color3.fromRGB(208, 158, 183)
heading.Font = Enum.Font.GothamBlack
heading.TextSize = 16
heading.TextXAlignment = Enum.TextXAlignment.Left
heading.Parent = card

local objective = Instance.new("TextLabel")
objective.Size = UDim2.new(1, -20, 0, 46)
objective.Position = UDim2.fromOffset(10, 36)
objective.BackgroundTransparency = 1
objective.TextColor3 = Color3.fromRGB(245, 225, 216)
objective.Font = Enum.Font.GothamMedium
objective.TextSize = 15
objective.TextWrapped = true
objective.TextXAlignment = Enum.TextXAlignment.Left
objective.TextYAlignment = Enum.TextYAlignment.Top
objective.Parent = card

local stage = 1
local finished = false
local stages = {
	[1] = "Equip the Rusty Cleaver and kill one demon.",
	[2] = "Take the glowing demon part and graft it onto your body.",
	[3] = "Find a Lost Soul and capture it.",
	[4] = "Return to HELL KITCHEN and cook something.",
	[5] = "Good. Now survive, build your body, and prepare for THE BUTCHER.",
}

local function hasAnyGraft()
	for _, slot in ipairs({"HEAD", "EYE", "LEFT_ARM", "RIGHT_ARM", "LEGS", "BACK"}) do
		local value = player:GetAttribute("Part_" .. slot)
		if value and value ~= "" then
			return true
		end
	end
	return false
end

local function animateAdvance()
	card.Size = UDim2.fromOffset(346, 96)
	TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
		Size = UDim2.fromOffset(330, 92),
	}):Play()
end

local function refresh()
	if finished then
		return
	end

	local nextStage = stage
	if stage == 1 and (player:GetAttribute("Kills") or 0) >= 1 then
		nextStage = 2
	elseif stage == 2 and hasAnyGraft() then
		nextStage = 3
	elseif stage == 3 and (player:GetAttribute("Souls") or 0) >= 1 then
		nextStage = 4
	elseif stage == 4 and (player:GetAttribute("CookedCount") or 0) >= 1 then
		nextStage = 5
	end

	if nextStage ~= stage then
		stage = nextStage
		animateAdvance()
	end

	objective.Text = stages[stage]

	if stage == 5 then
		finished = true
		task.delay(7, function()
			TweenService:Create(card, TweenInfo.new(0.5), {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 18, 1, 20),
			}):Play()
			for _, child in ipairs(card:GetDescendants()) do
				if child:IsA("TextLabel") then
					TweenService:Create(child, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
				elseif child:IsA("UIStroke") then
					TweenService:Create(child, TweenInfo.new(0.45), {Transparency = 1}):Play()
				end
			end
			task.delay(0.6, function()
				gui:Destroy()
			end)
		end)
	end
end

for _, attribute in ipairs({
	"Kills", "Souls", "CookedCount",
	"Part_HEAD", "Part_EYE", "Part_LEFT_ARM", "Part_RIGHT_ARM", "Part_LEGS", "Part_BACK",
}) do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end

objective.Text = stages[stage]
refresh()
