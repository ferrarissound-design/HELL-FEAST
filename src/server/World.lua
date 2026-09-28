local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local World = {}
local ROOT_NAME = "HellFeastWorld"

local function makePart(parent, name, size, position, material, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Material = material or Enum.Material.Slate
	part.Color = color or Color3.fromRGB(70, 60, 62)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makePrompt(parent, actionText, objectText, holdDuration)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = holdDuration or 0.35
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function billboard(parent, text, offset, size, color)
	local gui = Instance.new("BillboardGui")
	gui.Size = size or UDim2.fromOffset(180, 42)
	gui.StudsOffset = offset or Vector3.new(0, 4.5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = color or Color3.fromRGB(255, 222, 210)
	label.TextStrokeTransparency = 0.55
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui

	return gui
end

local function buildRoad(parent, fromPosition, toPosition, color)
	local flatFrom = Vector3.new(fromPosition.X, 0.15, fromPosition.Z)
	local flatTo = Vector3.new(toPosition.X, 0.15, toPosition.Z)
	local delta = flatTo - flatFrom
	local length = delta.Magnitude
	local road = makePart(parent, "HellRoad", Vector3.new(7, 0.35, length), (flatFrom + flatTo) / 2, Enum.Material.Cobblestone, color)
	road.CFrame = CFrame.lookAt(road.Position, flatTo)
	return road
end

local function buildBonePillar(parent, position, height)
	local shaft = makePart(parent, "BonePillar", Vector3.new(2.5, height, 2.5), position + Vector3.new(0, height / 2, 0), Enum.Material.Limestone, Color3.fromRGB(180, 166, 145))
	shaft.CFrame *= CFrame.Angles(math.rad(math.random(-8, 8)), 0, math.rad(math.random(-8, 8)))

	local cap = makePart(parent, "BoneCap", Vector3.new(4.5, 1.2, 4.5), position + Vector3.new(0, height, 0), Enum.Material.Limestone, Color3.fromRGB(165, 148, 132))
	cap.Shape = Enum.PartType.Ball
end

local function buildDeadTree(parent, position, scale)
	local trunk = makePart(parent, "CharredTree", Vector3.new(1.8 * scale, 10 * scale, 1.8 * scale), position + Vector3.new(0, 5 * scale, 0), Enum.Material.Wood, Color3.fromRGB(48, 35, 34))
	trunk.CFrame *= CFrame.Angles(0, math.rad(math.random(0, 359)), math.rad(math.random(-9, 9)))

	for _, branchInfo in ipairs({
		{Vector3.new(4.5, 0.8, 0.8), Vector3.new(1.7, 2.5, 0), 25},
		{Vector3.new(3.7, 0.7, 0.7), Vector3.new(-1.4, 1.1, 0.3), -32},
	}) do
		local branch = makePart(parent, "CharredBranch", branchInfo[1] * scale, trunk.Position + branchInfo[2] * scale, Enum.Material.Wood, Color3.fromRGB(48, 35, 34))
		branch.CFrame = CFrame.new(branch.Position) * CFrame.Angles(0, math.rad(math.random(0, 359)), math.rad(branchInfo[3]))
	end
end

local function buildSoulCage(parent, position)
	local cage = Instance.new("Model")
	cage.Name = "SoulCage"
	cage.Parent = parent

	makePart(cage, "Base", Vector3.new(7, 1, 7), position, Enum.Material.Metal, Color3.fromRGB(70, 54, 55))
	for x = -2.5, 2.5, 2.5 do
		for z = -2.5, 2.5, 2.5 do
			if math.abs(x) == 2.5 or math.abs(z) == 2.5 then
				makePart(cage, "Bar", Vector3.new(0.35, 7, 0.35), position + Vector3.new(x, 4, z), Enum.Material.Metal, Color3.fromRGB(75, 60, 62))
			end
		end
	end

	local soul = makePart(cage, "SoulGlow", Vector3.new(2, 3.5, 2), position + Vector3.new(0, 3.3, 0), Enum.Material.Neon, Color3.fromRGB(135, 120, 190))
	soul.Shape = Enum.PartType.Ball
	soul.CanCollide = false

	local light = Instance.new("PointLight")
	light.Color = soul.Color
	light.Range = 16
	light.Brightness = 1.6
	light.Parent = soul
end

local function buildLavaCrack(parent, position, length, angle)
	local surfacePosition = Vector3.new(position.X, 0.64, position.Z)
	local crack = makePart(parent, "LavaCrack", Vector3.new(length, 0.20, 1.55), surfacePosition, Enum.Material.Neon, Color3.fromRGB(255, 75, 20))
	crack.CFrame = CFrame.new(surfacePosition) * CFrame.Angles(0, math.rad(angle), 0)
	crack.CanCollide = false
	crack.CanTouch = true
	crack:SetAttribute("HazardDamage", Config.Hazards.LavaDamage)
	crack:SetAttribute("HazardCooldown", Config.Hazards.LavaCooldown)

	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 75, 20)
	glow.Range = 10
	glow.Brightness = 0.7
	glow.Parent = crack
end

local function buildRegionBeacon(parent, region)
	local pillar = makePart(parent, region.DisplayName .. "Beacon", Vector3.new(2.5, 9, 2.5), region.Center + Vector3.new(0, 4.5, 0), Enum.Material.Slate, region.Color)
	local light = Instance.new("PointLight")
	light.Color = region.Color
	light.Range = 24
	light.Brightness = 1.8
	light.Parent = pillar
	billboard(pillar, region.DisplayName, Vector3.new(0, 6.5, 0), UDim2.fromOffset(210, 44), Color3.fromRGB(255, 235, 220))
end

local function buildRegion(parent, hazards, key, region)
	local model = Instance.new("Model")
	model.Name = key
	model.Parent = parent

	local floor = makePart(model, "RegionFloor", Vector3.new(0.8, region.Radius * 2, region.Radius * 2), region.Center + Vector3.new(0, 0.08, 0), Enum.Material.Rock, region.Color)
	floor.Shape = Enum.PartType.Cylinder
	floor.CFrame = CFrame.new(floor.Position) * CFrame.Angles(0, 0, math.rad(90))
	floor.Transparency = 0.12

	buildRegionBeacon(model, region)

	if key == "AshFields" then
		for i = 1, 9 do
			local angle = (i / 9) * math.pi * 2
			local radius = 19 + (i % 3) * 8
			buildDeadTree(model, region.Center + Vector3.new(math.cos(angle) * radius, 0.5, math.sin(angle) * radius), 0.75 + (i % 2) * 0.25)
		end
	elseif key == "BoneYard" then
		for i = 1, 10 do
			local angle = (i / 10) * math.pi * 2
			local radius = 18 + (i % 4) * 6
			buildBonePillar(model, region.Center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius), 6 + (i % 4) * 3)
		end
	elseif key == "CinderRun" then
		for i = 1, 11 do
			local angle = (i / 11) * math.pi * 2
			local radius = 12 + (i % 4) * 8
			buildLavaCrack(hazards, region.Center + Vector3.new(math.cos(angle) * radius, 0.25, math.sin(angle) * radius), 8 + (i % 5) * 3, (i * 31) % 180)
		end
	elseif key == "SoulPens" then
		for _, offset in ipairs({
			Vector3.new(-20, 0.5, -12),
			Vector3.new(18, 0.5, -15),
			Vector3.new(-15, 0.5, 18),
			Vector3.new(20, 0.5, 16),
		}) do
			buildSoulCage(model, region.Center + offset)
		end
	end

	return model
end

function World.Build()
	local old = Workspace:FindFirstChild(ROOT_NAME)
	if old then
		old:Destroy()
	end

	Lighting.ClockTime = 1.5
	Lighting.Brightness = 1.15
	Lighting.FogStart = 100
	Lighting.FogEnd = 390
	Lighting.Ambient = Color3.fromRGB(66, 32, 38)
	Lighting.OutdoorAmbient = Color3.fromRGB(30, 18, 25)

	local atmosphere = Lighting:FindFirstChild("HellFeastAtmosphere") or Instance.new("Atmosphere")
	atmosphere.Name = "HellFeastAtmosphere"
	atmosphere.Density = 0.34
	atmosphere.Haze = 2
	atmosphere.Color = Color3.fromRGB(145, 85, 85)
	atmosphere.Decay = Color3.fromRGB(70, 22, 28)
	atmosphere.Parent = Lighting

	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace

	local arena = Instance.new("Folder")
	arena.Name = "Arena"
	arena.Parent = root

	local hazards = Instance.new("Folder")
	hazards.Name = "Hazards"
	hazards.Parent = root

	local regions = Instance.new("Folder")
	regions.Name = "Regions"
	regions.Parent = root

	makePart(arena, "BasaltGround", Vector3.new(330, 4, 330), Vector3.new(0, -2, 0), Enum.Material.Basalt, Color3.fromRGB(45, 38, 42))

	local lava = makePart(arena, "LavaUnderworld", Vector3.new(390, 2, 390), Vector3.new(0, -4.5, 0), Enum.Material.Neon, Color3.fromRGB(255, 70, 18))
	lava.CanCollide = false

	local bossRing = makePart(arena, "BossRing", Vector3.new(1, 82, 82), Config.Navigation.BossPosition + Vector3.new(0, -5.8, 0), Enum.Material.CrackedLava, Color3.fromRGB(85, 47, 45))
	bossRing.Shape = Enum.PartType.Cylinder
	bossRing.CFrame = CFrame.new(bossRing.Position) * CFrame.Angles(0, 0, math.rad(90))
	billboard(bossRing, "THE SLAUGHTER PIT", Vector3.new(0, 5, 0), UDim2.fromOffset(220, 44))

	local roads = Instance.new("Folder")
	roads.Name = "Roads"
	roads.Parent = arena
	for _, region in pairs(Config.Regions) do
		buildRoad(roads, Vector3.new(0, 0, 0), region.Center, Color3.fromRGB(60, 48, 50))
	end
	buildRoad(roads, Vector3.new(0, 0, -18), Vector3.new(0, 0, -96), Color3.fromRGB(68, 42, 42))

	for key, region in pairs(Config.Regions) do
		buildRegion(regions, hazards, key, region)
	end

	local kitchen = Instance.new("Model")
	kitchen.Name = "HellKitchen"
	kitchen.Parent = root

	makePart(kitchen, "KitchenFloor", Vector3.new(48, 2, 40), Vector3.new(0, 1, 0), Enum.Material.Cobblestone, Color3.fromRGB(76, 60, 64))

	for _, wallInfo in ipairs({
		{Vector3.new(48, 7, 2), Vector3.new(0, 4.5, 19)},
		{Vector3.new(2, 7, 40), Vector3.new(-23, 4.5, 0)},
		{Vector3.new(2, 7, 40), Vector3.new(23, 4.5, 0)},
	}) do
		local wall = makePart(kitchen, "KitchenWall", wallInfo[1], wallInfo[2], Enum.Material.Brick, Color3.fromRGB(65, 45, 48))
		wall.CanCollide = true
	end

	local kitchenBeacon = makePart(kitchen, "KitchenBeacon", Vector3.new(3.2, 13, 3.2), Vector3.new(0, 7, -17), Enum.Material.Neon, Color3.fromRGB(230, 95, 50))
	kitchenBeacon.CanCollide = false
	local kitchenLight = Instance.new("PointLight")
	kitchenLight.Color = kitchenBeacon.Color
	kitchenLight.Range = 45
	kitchenLight.Brightness = 2.2
	kitchenLight.Parent = kitchenBeacon
	billboard(kitchenBeacon, "HELL KITCHEN", Vector3.new(0, 9, 0), UDim2.fromOffset(230, 46))

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HellSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(9, 1, 9)
	spawn.Position = Vector3.new(0, 3, 10)
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(220, 80, 60)
	spawn.Parent = kitchen

	local recipes = {
		{ key = "HellPie", label = "HELL PIE", pos = Vector3.new(-14, 4, -5) },
		{ key = "SoulBurger", label = "SOUL BURGER", pos = Vector3.new(0, 4, -5) },
		{ key = "SinnerStew", label = "SINNER STEW", pos = Vector3.new(14, 4, -5) },
	}

	local stations = Instance.new("Folder")
	stations.Name = "CookStations"
	stations.Parent = kitchen

	for _, recipe in ipairs(recipes) do
		local station = makePart(stations, recipe.key, Vector3.new(9, 6, 8), recipe.pos, Enum.Material.Metal, Color3.fromRGB(92, 45, 36))
		station:SetAttribute("Recipe", recipe.key)
		makePrompt(station, "Cook", recipe.label, 0.45)
		billboard(station, recipe.label, Vector3.new(0, 4.5, 0), UDim2.fromOffset(150, 36))
	end

	local upgradePads = Instance.new("Folder")
	upgradePads.Name = "UpgradePads"
	upgradePads.Parent = kitchen

	local upgrades = {
		{key = "Vitality", label = "VITALITY", pos = Vector3.new(-12, 2.4, 13), color = Color3.fromRGB(115, 45, 50)},
		{key = "Metabolism", label = "METABOLISM", pos = Vector3.new(0, 2.4, 13), color = Color3.fromRGB(100, 68, 42)},
		{key = "Butchery", label = "BUTCHERY", pos = Vector3.new(12, 2.4, 13), color = Color3.fromRGB(72, 45, 95)},
	}

	for _, info in ipairs(upgrades) do
		local pad = makePart(upgradePads, info.key, Vector3.new(8, 2.8, 7), info.pos, Enum.Material.Metal, info.color)
		pad:SetAttribute("UpgradeKey", info.key)
		makePrompt(pad, "Upgrade", info.label, 0.6)
		billboard(pad, info.label, Vector3.new(0, 3.2, 0), UDim2.fromOffset(145, 34))
	end

	local altar = makePart(kitchen, "DecisionAltar", Vector3.new(8, 6, 5), Vector3.new(0, 4, 24), Enum.Material.Slate, Color3.fromRGB(62, 38, 74))
	billboard(altar, "ESCAPE / DESCEND", Vector3.new(0, 4.5, 0), UDim2.fromOffset(220, 40))

	local demons = Instance.new("Folder")
	demons.Name = "Demons"
	demons.Parent = root

	local souls = Instance.new("Folder")
	souls.Name = "LostSouls"
	souls.Parent = root

	local drops = Instance.new("Folder")
	drops.Name = "Drops"
	drops.Parent = root

	return root
end

function World.ApplyCircleStyle(circle)
	circle = math.max(1, circle or 1)
	local palette = {
		[1] = {
			Ambient = Color3.fromRGB(66, 32, 38),
			Atmosphere = Color3.fromRGB(145, 85, 85),
			FogEnd = 390,
		},
		[2] = {
			Ambient = Color3.fromRGB(72, 28, 18),
			Atmosphere = Color3.fromRGB(175, 85, 55),
			FogEnd = 340,
		},
		[3] = {
			Ambient = Color3.fromRGB(38, 25, 72),
			Atmosphere = Color3.fromRGB(92, 68, 160),
			FogEnd = 300,
		},
	}

	local style = palette[math.clamp(circle, 1, 3)]
	Lighting.Ambient = style.Ambient
	Lighting.FogEnd = style.FogEnd

	local atmosphere = Lighting:FindFirstChild("HellFeastAtmosphere")
	if atmosphere then
		atmosphere.Color = style.Atmosphere
		atmosphere.Density = 0.32 + (circle - 1) * 0.05
	end
end

return World
