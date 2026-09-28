local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local feedback = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastEffects"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local damageFlash = Instance.new("Frame")
damageFlash.Name = "DamageFlash"
damageFlash.Size = UDim2.fromScale(1, 1)
damageFlash.BackgroundColor3 = Color3.fromRGB(170, 15, 25)
damageFlash.BackgroundTransparency = 1
damageFlash.BorderSizePixel = 0
damageFlash.Parent = gui

local hitMarker = Instance.new("TextLabel")
hitMarker.AnchorPoint = Vector2.new(0.5, 0.5)
hitMarker.Position = UDim2.fromScale(0.5, 0.5)
hitMarker.Size = UDim2.fromOffset(60, 60)
hitMarker.BackgroundTransparency = 1
hitMarker.Text = "×"
hitMarker.TextColor3 = Color3.fromRGB(255, 236, 220)
hitMarker.TextTransparency = 1
hitMarker.Font = Enum.Font.GothamBlack
hitMarker.TextSize = 38
hitMarker.Rotation = 45
hitMarker.Parent = gui

local pulse = Instance.new("Frame")
pulse.AnchorPoint = Vector2.new(0.5, 0.5)
pulse.Position = UDim2.fromScale(0.5, 0.5)
pulse.Size = UDim2.fromScale(1, 1)
pulse.BackgroundColor3 = Color3.fromRGB(110, 35, 70)
pulse.BackgroundTransparency = 1
pulse.BorderSizePixel = 0
pulse.Parent = gui

local bossFrame = Instance.new("Frame")
bossFrame.Name = "BossFrame"
bossFrame.AnchorPoint = Vector2.new(0.5, 0)
bossFrame.Position = UDim2.new(0.5, 0, 0, 98)
bossFrame.Size = UDim2.new(0.64, 0, 0, 62)
bossFrame.BackgroundColor3 = Color3.fromRGB(25, 13, 17)
bossFrame.BackgroundTransparency = 0.08
bossFrame.BorderSizePixel = 0
bossFrame.Visible = false
bossFrame.Parent = gui

local bossCorner = Instance.new("UICorner")
bossCorner.CornerRadius = UDim.new(0, 12)
bossCorner.Parent = bossFrame

local bossStroke = Instance.new("UIStroke")
bossStroke.Thickness = 2
bossStroke.Color = Color3.fromRGB(180, 56, 50)
bossStroke.Parent = bossFrame

local bossTitle = Instance.new("TextLabel")
bossTitle.Size = UDim2.new(1, -18, 0, 28)
bossTitle.Position = UDim2.fromOffset(9, 4)
bossTitle.BackgroundTransparency = 1
bossTitle.Text = "THE BUTCHER"
bossTitle.TextColor3 = Color3.fromRGB(255, 195, 150)
bossTitle.Font = Enum.Font.GothamBlack
bossTitle.TextSize = 20
bossTitle.Parent = bossFrame

local bossBack = Instance.new("Frame")
bossBack.Size = UDim2.new(1, -20, 0, 16)
bossBack.Position = UDim2.fromOffset(10, 38)
bossBack.BackgroundColor3 = Color3.fromRGB(65, 38, 38)
bossBack.BorderSizePixel = 0
bossBack.Parent = bossFrame
local bossBackCorner = Instance.new("UICorner")
bossBackCorner.CornerRadius = UDim.new(1, 0)
bossBackCorner.Parent = bossBack

local bossFill = Instance.new("Frame")
bossFill.Size = UDim2.fromScale(1, 1)
bossFill.BackgroundColor3 = Color3.fromRGB(198, 60, 48)
bossFill.BorderSizePixel = 0
bossFill.Parent = bossBack
local bossFillCorner = Instance.new("UICorner")
bossFillCorner.CornerRadius = UDim.new(1, 0)
bossFillCorner.Parent = bossFill

local function flashDamage(strength)
	strength = strength or 0.28
	damageFlash.BackgroundTransparency = math.clamp(1 - strength, 0.5, 0.92)
	TweenService:Create(damageFlash, TweenInfo.new(0.32), {BackgroundTransparency = 1}):Play()
end

local function showHitMarker(isBoss)
	hitMarker.TextColor3 = isBoss and Color3.fromRGB(255, 170, 90) or Color3.fromRGB(255, 236, 220)
	hitMarker.TextTransparency = 0
	hitMarker.Size = UDim2.fromOffset(76, 76)
	TweenService:Create(hitMarker, TweenInfo.new(0.16), {
		TextTransparency = 1,
		Size = UDim2.fromOffset(48, 48),
	}):Play()
end

local function floatingDamage(position, amount, isBoss)
	if typeof(position) ~= "Vector3" then
		return
	end

	local anchor = Instance.new("Part")
	anchor.Name = "LocalDamageNumber"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Position = position + Vector3.new(math.random(-8, 8) / 10, 3.5, 0)
	anchor.Parent = Workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(110, 54)
	billboard.AlwaysOnTop = true
	billboard.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = tostring(amount)
	label.TextColor3 = isBoss and Color3.fromRGB(255, 175, 80) or Color3.fromRGB(255, 235, 215)
	label.TextStrokeTransparency = 0.35
	label.Font = Enum.Font.GothamBlack
	label.TextSize = isBoss and 28 or 22
	label.Parent = billboard

	TweenService:Create(anchor, TweenInfo.new(0.55), {Position = anchor.Position + Vector3.new(0, 3.2, 0)}):Play()
	TweenService:Create(label, TweenInfo.new(0.55), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	Debris:AddItem(anchor, 0.65)
end

local function fullPulse(color)
	pulse.BackgroundColor3 = color
	pulse.BackgroundTransparency = 0.78
	TweenService:Create(pulse, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
end

local function bindHumanoid(character)
	local humanoid = character:WaitForChild("Humanoid", 8)
	if not humanoid then
		return
	end

	local lastHealth = humanoid.Health
	humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth then
			local lost = lastHealth - newHealth
			flashDamage(math.clamp(0.20 + lost / math.max(1, humanoid.MaxHealth), 0.20, 0.48))
		end
		lastHealth = newHealth
	end)
end

player.CharacterAdded:Connect(bindHumanoid)
if player.Character then
	task.spawn(bindHumanoid, player.Character)
end

feedback.OnClientEvent:Connect(function(kind, payload)
	payload = payload or {}

	if kind == "HIT" then
		showHitMarker(payload.IsBoss == true)
		floatingDamage(payload.Position, payload.Damage or 0, payload.IsBoss == true)
	elseif kind == "KILL" then
		fullPulse(payload.IsBoss and Color3.fromRGB(145, 45, 30) or Color3.fromRGB(80, 35, 65))
	elseif kind == "GRAFT" then
		fullPulse(Color3.fromRGB(92, 46, 135))
	elseif kind == "COOK" then
		fullPulse(Color3.fromRGB(130, 82, 35))
	elseif kind == "WATCHER_BOLT" then
		flashDamage(0.36)
	elseif kind == "HOUND_CHARGE" then
		flashDamage(0.44)
	elseif kind == "ENEMY_HIT" then
		flashDamage(0.26)
	elseif kind == "BOSS_SPAWN" then
		bossFrame.Visible = true
		bossFrame.Size = UDim2.new(0.2, 0, 0, 62)
		TweenService:Create(bossFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
			Size = UDim2.new(0.64, 0, 0, 62),
		}):Play()
		fullPulse(Color3.fromRGB(130, 25, 25))
	end
end)

task.spawn(function()
	while true do
		task.wait(0.12)
		local root = Workspace:FindFirstChild("HellFeastWorld")
		local demons = root and root:FindFirstChild("Demons")
		local boss

		if demons then
			for _, demon in ipairs(demons:GetChildren()) do
				if demon:GetAttribute("IsBoss") == true then
					boss = demon
					break
				end
			end
		end

		if boss then
			local health = boss:GetAttribute("Health") or 0
			local maxHealth = boss:GetAttribute("MaxHealth") or 1
			bossFrame.Visible = true
			bossTitle.Text = string.format("THE BUTCHER   %d / %d", math.ceil(health), maxHealth)
			bossFill.Size = UDim2.fromScale(math.clamp(health / math.max(1, maxHealth), 0, 1), 1)
		elseif Workspace:GetAttribute("BossAlive") ~= true then
			bossFrame.Visible = false
		end
	end
end)
