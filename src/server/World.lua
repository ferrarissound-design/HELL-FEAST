local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

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

local function billboard(parent, text, offset, size)
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
	label.TextColor3 = Color3.fromRGB(255, 222, 210)
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui

	return gui
end

local function buildBonePillar(parent, position, height)
	local shaft = makePart(parent, "BonePillar", Vector3.new(2.5, height, 2.5), position + Vector3.new(0, height / 2, 0), Enum.Material.Limestone, Color3.fromRGB(180, 166, 145))
	shaft.CFrame *= CFrame.Angles(math.rad(math.random(-8, 8)), 0, math.rad(math.random(-8, 8)))
	local cap = makePart(parent, "BoneCap", Vector3.new(4.5, 1.2, 4.5), position + Vector3.new(0, height, 0), Enum.Material.Limestone, Color3.fromRGB(165, 148, 132))
	cap.Shape = Enum.PartType.Ball
end

local function buildSoulCage(parent, position)
	local cage = Instance.new("Model")
	cage.Name = "SoulCage"
	cage.Parent = parent

	local base = makePart(cage, "Base", Vector3.new(7, 1, 7), position, Enum.Material.Metal, Color3.fromRGB(70, 54, 55))
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
end

local function buildLavaCrack(parent, position, length, angle)
	local crack = makePart(parent, "LavaCrack", Vector3.new(length, 0.35, 1.4), position, Enum.Material.Neon, Color3.fromRGB(255, 75, 20))
	crack.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(angle), 0)
	crack.CanCollide = false
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

	local ground = makePart(arena, "BasaltGround", Vector3.new(330, 4, 330), Vector3.new(0, -2, 0), Enum.Material.Basalt, Color3.fromRGB(45, 38, 42))

	local lava = makePart(arena, "LavaUnderworld", Vector3.new(390, 2, 390), Vector3.new(0, -4.5, 0), Enum.Material.Neon, Color3.fromRGB(255, 70, 18))
	lava.CanCollide = false

	local bossRing = makePart(arena, "BossRing", Vector3.new(1, 82, 82), Vector3.new(0, 0.2, -108), Enum.Material.CrackedLava, Color3.fromRGB(85, 47, 45))
	bossRing.Shape = Enum.PartType.Cylinder
	bossRing.CFrame = CFrame.new(0, 0.2, -108) * CFrame.Angles(0, 0, math.rad(90))
	billboard(bossRing, "THE SLAUGHTER PIT", Vector3.new(0, 5, 0), UDim2.fromOffset(220, 44))

	local landmarks = Instance.new("Folder")
	landmarks.Name = "Landmarks"
	landmarks.Parent = arena

	for i = 1, 18 do
		local angle = (i / 18) * math.pi * 2
		local radius = (i % 2 == 0) and 145 or 122
		buildBonePillar(landmarks, Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius), math.random(8, 17))
	end

	buildSoulCage(landmarks, Vector3.new(98, 0.5, 55))
	buildSoulCage(landmarks, Vector3.new(-92, 0.5, 68))
	buildSoulCage(landmarks, Vector3.new(78, 0.5, -72))

	for i = 1, 16 do
		local angle = math.random(0, 359)
		local radius = math.random(45, 145)
		buildLavaCrack(landmarks, Vector3.new(math.cos(math.rad(angle)) * radius, 0.1, math.sin(math.rad(angle)) * radius), math.random(10, 28), math.random(0, 179))
	end

	local kitchen = Instance.new("Model")
	kitchen.Name = "HellKitchen"
	kitchen.Parent = root

	local kitchenFloor = makePart(kitchen, "KitchenFloor", Vector3.new(48, 2, 40), Vector3.new(0, 1, 0), Enum.Material.Cobblestone, Color3.fromRGB(76, 60, 64))

	for _, wallInfo in ipairs({
		{Vector3.new(48, 7, 2), Vector3.new(0, 4.5, 19)},
		{Vector3.new(2, 7, 40), Vector3.new(-23, 4.5, 0)},
		{Vector3.new(2, 7, 40), Vector3.new(23, 4.5, 0)},
	}) do
		local wall = makePart(kitchen, "KitchenWall", wallInfo[1], wallInfo[2], Enum.Material.Brick, Color3.fromRGB(65, 45, 48))
		wall.CanCollide = true
	end

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
