local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local feedback = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastEffects"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local hitSound = Instance.new("Sound")
hitSound.Name = "HellFeastHit"
hitSound.SoundId = "rbxasset://sounds/swordslash.wav"
hitSound.Volume = 0.24
hitSound.PlaybackSpeed = 1.12
hitSound.Parent = SoundService

local rewardSound = Instance.new("Sound")
rewardSound.Name = "HellFeastReward"
rewardSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
rewardSound.Volume = 0.28
rewardSound.PlaybackSpeed = 0.82
rewardSound.Parent = SoundService

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


local fullPulse
local phaseBannerVersion = 0

local phaseBanner = Instance.new("TextLabel")
phaseBanner.AnchorPoint = Vector2.new(0.5, 0.5)
phaseBanner.Position = UDim2.fromScale(0.5, 0.34)
phaseBanner.Size = UDim2.fromOffset(420, 76)
phaseBanner.BackgroundTransparency = 1
phaseBanner.TextTransparency = 1
phaseBanner.TextColor3 = Color3.fromRGB(255, 205, 155)
phaseBanner.TextStrokeTransparency = 0.55
phaseBanner.Font = Enum.Font.GothamBlack
phaseBanner.TextSize = 30
phaseBanner.TextWrapped = true
phaseBanner.Parent = gui

local function showBossPhase(phase)
	phaseBannerVersion += 1
	local version = phaseBannerVersion

	if phase == 2 then
		phaseBanner.Text = "THE BUTCHER\nPHASE II"
		phaseBanner.TextColor3 = Color3.fromRGB(255, 165, 105)
		bossStroke.Color = Color3.fromRGB(220, 90, 50)
		bossFill.BackgroundColor3 = Color3.fromRGB(220, 85, 45)
	elseif phase == 3 then
		phaseBanner.Text = "FRENZY\nPHASE III"
		phaseBanner.TextColor3 = Color3.fromRGB(255, 100, 90)
		bossStroke.Color = Color3.fromRGB(255, 55, 55)
		bossFill.BackgroundColor3 = Color3.fromRGB(235, 45, 45)
	else
		return
	end

	phaseBanner.TextTransparency = 0
	phaseBanner.Size = UDim2.fromOffset(470, 86)
	TweenService:Create(phaseBanner, TweenInfo.new(0.24, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(420, 76),
	}):Play()
	fullPulse(phase == 3 and Color3.fromRGB(150, 20, 25) or Color3.fromRGB(130, 50, 25))

	task.delay(1.55, function()
		if version ~= phaseBannerVersion then
			return
		end
		TweenService:Create(phaseBanner, TweenInfo.new(0.42), {
			TextTransparency = 1,
		}):Play()
	end)
end

local function flashDamage(strength, color)
	strength = strength or 0.28
	damageFlash.BackgroundColor3 = color or Color3.fromRGB(170, 15, 25)
	if player:GetAttribute("ReducedFlashes") == true then
		strength *= 0.35
	end
	damageFlash.BackgroundTransparency = math.clamp(1 - strength, 0.72, 0.96)
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
	if player:GetAttribute("HideDamageNumbers") == true then
		return
	end
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

fullPulse = function(color)
	pulse.BackgroundColor3 = color
	pulse.BackgroundTransparency = player:GetAttribute("ReducedFlashes") == true and 0.94 or 0.78
	TweenService:Create(pulse, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
end


local function telegraphColor(tone)
	if tone == "WATCHER" then
		return Color3.fromRGB(180, 80, 225)
	elseif tone == "HOUND" then
		return Color3.fromRGB(255, 115, 35)
	elseif tone == "BUTCHER" then
		return Color3.fromRGB(220, 45, 38)
	elseif tone == "BRUTE" then
		return Color3.fromRGB(205, 110, 70)
	end
	return Color3.fromRGB(230, 100, 70)
end

local function createCircleTelegraph(payload)
	if typeof(payload.Position) ~= "Vector3" then
		return
	end

	local radius = tonumber(payload.Radius) or 6
	local duration = tonumber(payload.Duration) or 0.6
	local ring = Instance.new("Part")
	ring.Name = "LocalAttackTelegraph"
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanTouch = false
	ring.CanQuery = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Neon
	ring.Color = telegraphColor(payload.Tone)
	ring.Transparency = 0.42
	ring.Size = Vector3.new(0.16, radius * 2, radius * 2)
	ring.CFrame = CFrame.new(payload.Position.X, 0.68, payload.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = Workspace

	local light = Instance.new("PointLight")
	light.Color = ring.Color
	light.Brightness = 0.6
	light.Range = math.min(radius * 1.6, 32)
	light.Parent = ring

	TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Transparency = 0.1,
		Color = Color3.fromRGB(255, 235, 220),
	}):Play()
	Debris:AddItem(ring, duration + 0.08)
end

local function createLineTelegraph(payload)
	if typeof(payload.Start) ~= "Vector3" or typeof(payload.Finish) ~= "Vector3" then
		return
	end

	local duration = tonumber(payload.Duration) or 0.7
	local width = tonumber(payload.Width) or 4
	local startPosition = Vector3.new(payload.Start.X, 0.72, payload.Start.Z)
	local endPosition = Vector3.new(payload.Finish.X, 0.72, payload.Finish.Z)
	local delta = endPosition - startPosition
	if delta.Magnitude <= 0.1 then
		return
	end

	local strip = Instance.new("Part")
	strip.Name = "LocalChargeTelegraph"
	strip.Anchored = true
	strip.CanCollide = false
	strip.CanTouch = false
	strip.CanQuery = false
	strip.Material = Enum.Material.Neon
	strip.Color = telegraphColor(payload.Tone)
	strip.Transparency = 0.46
	strip.Size = Vector3.new(width * 2, 0.16, delta.Magnitude)
	strip.CFrame = CFrame.lookAt((startPosition + endPosition) / 2, endPosition)
	strip.Parent = Workspace

	TweenService:Create(strip, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Transparency = 0.08,
		Color = Color3.fromRGB(255, 225, 190),
	}):Play()
	Debris:AddItem(strip, duration + 0.08)
end

local healthChangedConnection

local function bindHumanoid(character)
	if healthChangedConnection then
		healthChangedConnection:Disconnect()
		healthChangedConnection = nil
	end

	local humanoid = character:WaitForChild("Humanoid", 8)
	if not humanoid then
		return
	end

	local lastHealth = humanoid.Health
	healthChangedConnection = humanoid.HealthChanged:Connect(function(newHealth)
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

	if kind == "TELEGRAPH_CIRCLE" then
		createCircleTelegraph(payload)
	elseif kind == "TELEGRAPH_LINE" then
		createLineTelegraph(payload)
	elseif kind == "BUTCHER_SLAM" then
		flashDamage(0.48)
		fullPulse(Color3.fromRGB(130, 25, 25))
	elseif kind == "HIT" then
		showHitMarker(payload.IsBoss == true)
		floatingDamage(payload.Position, payload.Damage or 0, payload.IsBoss == true)
		hitSound.PlaybackSpeed = payload.IsBoss and 0.82 or (1.05 + math.random() * 0.18)
		hitSound:Play()
	elseif kind == "KILL" then
		fullPulse(payload.IsBoss and Color3.fromRGB(145, 45, 30) or Color3.fromRGB(80, 35, 65))
	elseif kind == "GRAFT" then
		fullPulse(Color3.fromRGB(92, 46, 135))
		rewardSound.PlaybackSpeed = 0.70
		rewardSound:Play()
	elseif kind == "COOK" then
		fullPulse(Color3.fromRGB(130, 82, 35))
		rewardSound.PlaybackSpeed = 1.10
		rewardSound:Play()
	elseif kind == "WATCHER_BOLT" then
		flashDamage(0.36)
	elseif kind == "HOUND_CHARGE" then
		flashDamage(0.44)
	elseif kind == "ENVIRONMENT_HIT" then
		flashDamage(0.34, Color3.fromRGB(235, 85, 25))
	elseif kind == "ENEMY_HIT" then
		flashDamage(0.26)
	elseif kind == "BOSS_PHASE" then
		showBossPhase(tonumber(payload.Phase) or 1)
	elseif kind == "BUTCHER_CROSS" then
		flashDamage(0.43)
	elseif kind == "BOSS_SPAWN" then
		rewardSound.PlaybackSpeed = 0.55
		rewardSound:Play()
		bossStroke.Color = Color3.fromRGB(180, 56, 50)
		bossFill.BackgroundColor3 = Color3.fromRGB(198, 60, 48)
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
			local phase = boss:GetAttribute("BossPhase") or 1
			bossFrame.Visible = true
			local suffix = phase == 3 and "  •  FRENZY" or phase == 2 and "  •  PHASE II" or ""
			bossTitle.Text = string.format("THE BUTCHER%s   %d / %d", suffix, math.ceil(health), maxHealth)
			bossFill.Size = UDim2.fromScale(math.clamp(health / math.max(1, maxHealth), 0, 1), 1)
		elseif Workspace:GetAttribute("BossAlive") ~= true then
			bossFrame.Visible = false
		end
	end
end)
