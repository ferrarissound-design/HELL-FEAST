local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local World = {}

local ROOT_NAME = "HellFeastWorld"

local function makePart(parent, name, size, position, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Material = material or Enum.Material.Slate
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

function World.Build()
	local old = Workspace:FindFirstChild(ROOT_NAME)
	if old then
		old:Destroy()
	end

	Lighting.ClockTime = 1.5
	Lighting.Brightness = 1.3
	Lighting.FogEnd = 430
	Lighting.Ambient = Color3.fromRGB(70, 35, 35)
	Lighting.OutdoorAmbient = Color3.fromRGB(35, 20, 25)

	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = Workspace

	local arena = Instance.new("Folder")
	arena.Name = "Arena"
	arena.Parent = root

	local ground = makePart(arena, "BasaltGround", Vector3.new(330, 4, 330), Vector3.new(0, -2, 0), Enum.Material.Basalt)
	ground.Color = Color3.fromRGB(48, 40, 43)

	local lava = makePart(arena, "LavaRing", Vector3.new(390, 2, 390), Vector3.new(0, -4.5, 0), Enum.Material.Neon)
	lava.Color = Color3.fromRGB(255, 75, 20)

	local kitchen = Instance.new("Model")
	kitchen.Name = "HellKitchen"
	kitchen.Parent = root

	local kitchenFloor = makePart(kitchen, "KitchenFloor", Vector3.new(42, 2, 34), Vector3.new(0, 1, 0), Enum.Material.Cobblestone)
	kitchenFloor.Color = Color3.fromRGB(80, 65, 65)

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
		{ key = "HellPie", label = "HELL PIE", pos = Vector3.new(-12, 4, -3) },
		{ key = "SoulBurger", label = "SOUL BURGER", pos = Vector3.new(0, 4, -3) },
		{ key = "SinnerStew", label = "SINNER STEW", pos = Vector3.new(12, 4, -3) },
	}

	local stations = Instance.new("Folder")
	stations.Name = "CookStations"
	stations.Parent = kitchen

	for _, recipe in ipairs(recipes) do
		local station = makePart(stations, recipe.key, Vector3.new(8, 6, 7), recipe.pos, Enum.Material.Metal)
		station.Color = Color3.fromRGB(90, 45, 35)
		station:SetAttribute("Recipe", recipe.key)
		makePrompt(station, "Cook", recipe.label, 0.5)
	end

	local partStation = makePart(kitchen, "PartStation", Vector3.new(7, 6, 7), Vector3.new(0, 4, 12), Enum.Material.Metal)
	partStation.Color = Color3.fromRGB(62, 45, 78)
	local sign = Instance.new("BillboardGui")
	sign.Name = "PartStationSign"
	sign.Size = UDim2.fromOffset(180, 45)
	sign.StudsOffset = Vector3.new(0, 4.5, 0)
	sign.AlwaysOnTop = true
	sign.Parent = partStation
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "DEMON PARTS"
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 220, 220)
	label.Font = Enum.Font.GothamBlack
	label.Parent = sign

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

return World
