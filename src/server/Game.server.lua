local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))

Players.RespawnTime = 3

local world = World.Build()
local demonsFolder = world:WaitForChild("Demons")
local soulsFolder = world:WaitForChild("LostSouls")
local dropsFolder = world:WaitForChild("Drops")
local stationsFolder = world:WaitForChild("HellKitchen"):WaitForChild("CookStations")

local remotes = ReplicatedStorage:FindFirstChild("HellFeastRemotes") or Instance.new("Folder")
remotes.Name = "HellFeastRemotes"
remotes.Parent = ReplicatedStorage

local notifyRemote = remotes:FindFirstChild("Notify") or Instance.new("RemoteEvent")
notifyRemote.Name = "Notify"
notifyRemote.Parent = remotes

local dnaStore = DataStoreService:GetDataStore("HellFeast_DemonDNA_v1")
local runActive = false
local currentRunId = 0
local lastAttackAt = {}

Workspace:SetAttribute("RunState", "BOOTING")
Workspace:SetAttribute("RunTimeLeft", Config.RunDuration)
Workspace:SetAttribute("Circle", 1)

local function notify(player, text)
	notifyRemote:FireClient(player, text)
end

local function clampHunger(value)
	return math.clamp(value, 0, Config.Hunger.Max)
end

local function getCharacterHumanoid(player)
	local character = player.Character
	if not character then
		return nil, nil
	end
	return character, character:FindFirstChildOfClass("Humanoid")
end

local function clearPartVisuals(character)
	for _, child in ipairs(character:GetChildren()) do
		if string.sub(child.Name, 1, 3) == "HF_" then
			child:Destroy()
		end
	end
end

local function makeVisualPart(parent, name, target, size, offset, color, shape)
	if not target then
		return
	end
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.Neon
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Shape = shape or Enum.PartType.Block
	part.CFrame = target.CFrame * offset
	part.Parent = parent

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = target
	weld.Part1 = part
	weld.Parent = part
end

local function applyPartVisual(player, partName)
	local partData = Config.Parts[partName]
	local character = player.Character
	if not partData or not character then
		return
	end

	local visualName = "HF_" .. partData.Slot
	local old = character:FindFirstChild(visualName)
	if old then
		old:Destroy()
	end

	local holder = Instance.new("Folder")
	holder.Name = visualName
	holder.Parent = character

	local head = character:FindFirstChild("Head")
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
	local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
	local leftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg")
	local rightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")

	if partName == "WatcherEye" and head then
		makeVisualPart(holder, "ThirdEye", head, Vector3.new(0.55, 0.55, 0.22), CFrame.new(0, 0.2, -0.55), Color3.fromRGB(255, 70, 70), Enum.PartType.Ball)
	elseif partName == "DemonHorn" and head then
		makeVisualPart(holder, "Horn", head, Vector3.new(0.45, 1.5, 0.45), CFrame.new(0, 1.0, 0) * CFrame.Angles(0, 0, math.rad(18)), Color3.fromRGB(120, 25, 25))
	elseif partName == "BruteArm" and leftArm then
		makeVisualPart(holder, "BruteArm", leftArm, Vector3.new(1.5, 2.6, 1.5), CFrame.new(), Color3.fromRGB(120, 45, 40))
	elseif partName == "ClawArm" and rightArm then
		makeVisualPart(holder, "Claw", rightArm, Vector3.new(1.0, 2.3, 1.0), CFrame.new(0, -0.3, 0), Color3.fromRGB(150, 35, 35))
	elseif partName == "ImpLegs" then
		makeVisualPart(holder, "LeftImpFoot", leftFoot, Vector3.new(1.2, 0.7, 1.8), CFrame.new(0, -0.25, -0.3), Color3.fromRGB(170, 45, 35))
		makeVisualPart(holder, "RightImpFoot", rightFoot, Vector3.new(1.2, 0.7, 1.8), CFrame.new(0, -0.25, -0.3), Color3.fromRGB(170, 45, 35))
	elseif partName == "DemonWings" and torso then
		makeVisualPart(holder, "LeftWing", torso, Vector3.new(0.45, 3.4, 2.2), CFrame.new(-1.4, 0.2, 1.0) * CFrame.Angles(0, 0, math.rad(-25)), Color3.fromRGB(90, 25, 35))
		makeVisualPart(holder, "RightWing", torso, Vector3.new(0.45, 3.4, 2.2), CFrame.new(1.4, 0.2, 1.0) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(90, 25, 35))
	end
end

local function recomputeStats(player)
	local damageMultiplier = 1
	local hungerMultiplier = 1
	local walkSpeedBonus = 0

	for partName, data in pairs(Config.Parts) do
		local equipped = player:GetAttribute("Part_" .. data.Slot)
		if equipped == partName then
			damageMultiplier *= data.DamageMultiplier or 1
			hungerMultiplier *= data.HungerMultiplier or 1
			walkSpeedBonus += data.WalkSpeedBonus or 0
		end
	end

	player:SetAttribute("DamageMultiplier", damageMultiplier)
	player:SetAttribute("HungerMultiplier", hungerMultiplier)

	local _, humanoid = getCharacterHumanoid(player)
	if humanoid then
		humanoid.WalkSpeed = 16 + walkSpeedBonus
	end
end

local function resetBody(player)
	for _, data in pairs(Config.Parts) do
		player:SetAttribute("Part_" .. data.Slot, "")
	end
	player:SetAttribute("DamageMultiplier", 1)
	player:SetAttribute("HungerMultiplier", 1)

	if player.Character then
		clearPartVisuals(player.Character)
	end
	recomputeStats(player)
end

local function equipPart(player, partName)
	local data = Config.Parts[partName]
	if not data then
		return
	end

	local attribute = "Part_" .. data.Slot
	local previous = player:GetAttribute(attribute)
	player:SetAttribute(attribute, partName)
	applyPartVisual(player, partName)
	recomputeStats(player)

	if previous and previous ~= "" and previous ~= partName then
		notify(player, string.format("%s replaced %s", data.DisplayName, previous))
	else
		notify(player, data.DisplayName .. " grafted onto your body")
	end
end

local function saveDNA(player)
	local amount = player:GetAttribute("DemonDNA") or 0
	task.spawn(function()
		pcall(function()
			dnaStore:SetAsync(tostring(player.UserId), amount)
		end)
	end)
end

local function loadDNA(player)
	local amount = 0
	pcall(function()
		amount = dnaStore:GetAsync(tostring(player.UserId)) or 0
	end)
	player:SetAttribute("DemonDNA", amount)
end

local function giveWeapon(player)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack or backpack:FindFirstChild("Rusty Cleaver") then
		return
	end

	local tool = Instance.new("Tool")
	tool.Name = "Rusty Cleaver"
	tool.ToolTip = "Cut down demons. Their bodies are upgrades."
	tool.CanBeDropped = false
	tool.RequiresHandle = true

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.6, 3.1, 0.7)
	handle.Material = Enum.Material.Metal
	handle.Color = Color3.fromRGB(95, 85, 82)
	handle.CanCollide = false
	handle.Parent = tool

	tool.Parent = backpack

	tool.Activated:Connect(function()
		if not runActive then
			return
		end

		local now = os.clock()
		if now - (lastAttackAt[player] or 0) < Config.Combat.AttackCooldown then
			return
		end
		lastAttackAt[player] = now

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end

		local nearest
		local nearestDistance = Config.Combat.AttackRange
		for _, demon in ipairs(demonsFolder:GetChildren()) do
			local body = demon.PrimaryPart
			if body and (demon:GetAttribute("Health") or 0) > 0 then
				local distance = (body.Position - root.Position).Magnitude
				if distance <= nearestDistance then
					nearest = demon
					nearestDistance = distance
				end
			end
		end

		if nearest then
			local multiplier = player:GetAttribute("DamageMultiplier") or 1
			local damage = Config.Combat.BaseDamage * multiplier
			nearest:SetAttribute("LastHitUserId", player.UserId)
			nearest:SetAttribute("Health", math.max(0, (nearest:GetAttribute("Health") or 0) - damage))
		end
	end)
end

local function randomArenaPosition()
	local angle = math.random() * math.pi * 2
	local radius = Config.Spawning.SpawnRadiusMin + math.random() * (Config.Spawning.SpawnRadiusMax - Config.Spawning.SpawnRadiusMin)
	return Vector3.new(math.cos(angle) * radius, 3, math.sin(angle) * radius)
end

local function nearestLivingPlayer(position)
	local bestPlayer
	local bestDistance = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		local character, humanoid = getCharacterHumanoid(player)
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and humanoid and humanoid.Health > 0 then
			local d = (root.Position - position).Magnitude
			if d < bestDistance then
				bestDistance = d
				bestPlayer = player
			end
		end
	end
	return bestPlayer, bestDistance
end

local function dropPart(position, partName)
	local data = Config.Parts[partName]
	if not data then
		return
	end

	local drop = Instance.new("Part")
	drop.Name = partName
	drop.Shape = Enum.PartType.Ball
	drop.Size = Vector3.new(2.2, 2.2, 2.2)
	drop.Anchored = true
	drop.CanCollide = false
	drop.Material = Enum.Material.Neon
	drop.Color = Color3.fromRGB(180, 60, 80)
	drop.Position = position + Vector3.new(0, 2.2, 0)
	drop.Parent = dropsFolder

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Graft"
	prompt.ObjectText = data.DisplayName
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = drop

	local taken = false
	prompt.Triggered:Connect(function(player)
		if taken then
			return
		end
		taken = true
		equipPart(player, partName)
		drop:Destroy()
	end)

	task.delay(35, function()
		if drop.Parent then
			drop:Destroy()
		end
	end)
end

local function chooseDemonType()
	local roll = math.random()
	if roll < 0.57 then
		return "Imp"
	elseif roll < 0.82 then
		return "Brute"
	else
		return "Watcher"
	end
end

local function createDemon(demonType)
	local data = Config.Demons[demonType]
	if not data then
		return
	end

	local model = Instance.new("Model")
	model.Name = data.DisplayName
	model:SetAttribute("DemonType", demonType)
	model:SetAttribute("Health", data.MaxHealth)
	model:SetAttribute("MaxHealth", data.MaxHealth)
	model:SetAttribute("LastHitUserId", 0)
	model.Parent = demonsFolder

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Anchored = true
	body.CanCollide = true
	body.Material = Enum.Material.Slate
	body.Color = demonType == "Watcher" and Color3.fromRGB(95, 55, 110)
		or demonType == "Brute" and Color3.fromRGB(105, 45, 40)
		or Color3.fromRGB(150, 55, 45)
	body.Size = data.BodyScale
	body.Position = randomArenaPosition()
	body.Parent = model
	model.PrimaryPart = body

	local eye = Instance.new("Part")
	eye.Name = "Eye"
	eye.Anchored = true
	eye.CanCollide = false
	eye.Shape = Enum.PartType.Ball
	eye.Material = Enum.Material.Neon
	eye.Color = Color3.fromRGB(255, 105, 85)
	eye.Size = Vector3.new(0.8, 0.8, 0.8)
	eye.CFrame = body.CFrame * CFrame.new(0, data.BodyScale.Y * 0.18, -data.BodyScale.Z * 0.52)
	eye.Parent = model

	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthBillboard"
	gui.Size = UDim2.fromOffset(120, 30)
	gui.StudsOffset = Vector3.new(0, data.BodyScale.Y * 0.7, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body
	local hpLabel = Instance.new("TextLabel")
	hpLabel.Size = UDim2.fromScale(1, 1)
	hpLabel.BackgroundTransparency = 0.3
	hpLabel.BackgroundColor3 = Color3.fromRGB(25, 15, 18)
	hpLabel.TextColor3 = Color3.fromRGB(255, 225, 220)
	hpLabel.TextScaled = true
	hpLabel.Font = Enum.Font.GothamBold
	hpLabel.Parent = gui

	local dead = false
	local lastDemonAttack = 0

	local healthConnection
	healthConnection = model:GetAttributeChangedSignal("Health"):Connect(function()
		local hp = model:GetAttribute("Health") or 0
		hpLabel.Text = string.format("%s  %d/%d", data.DisplayName, math.ceil(hp), data.MaxHealth)
		if hp <= 0 and not dead then
			dead = true
			if healthConnection then
				healthConnection:Disconnect()
			end

			local killerId = model:GetAttribute("LastHitUserId") or 0
			local killer = Players:GetPlayerByUserId(killerId)
			if killer then
				killer:SetAttribute("Kills", (killer:GetAttribute("Kills") or 0) + 1)
			end

			local dropName = data.PartDrop
			if math.random() < 0.12 then
				local rare = {"DemonHorn", "DemonWings", "ClawArm"}
				dropName = rare[math.random(1, #rare)]
			end
			dropPart(body.Position, dropName)
			model:Destroy()
		end
	end)
	model:SetAttribute("Health", data.MaxHealth)

	task.spawn(function()
		while model.Parent and not dead and runActive do
			local targetPlayer, distance = nearestLivingPlayer(body.Position)
			if targetPlayer then
				local character, humanoid = getCharacterHumanoid(targetPlayer)
				local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
				if targetRoot and humanoid then
					local current = body.Position
					local flatTarget = Vector3.new(targetRoot.Position.X, current.Y, targetRoot.Position.Z)
					local delta = flatTarget - current
					if delta.Magnitude > 0.01 then
						local step = math.min(data.WalkSpeed * 0.12, delta.Magnitude)
						local nextPosition = current + delta.Unit * step
						local look = CFrame.lookAt(nextPosition, flatTarget)
						model:PivotTo(look)
					end

					if distance <= data.AttackRange and os.clock() - lastDemonAttack >= data.AttackCooldown then
						lastDemonAttack = os.clock()
						humanoid:TakeDamage(data.Damage)
					end
				end
			end
			task.wait(0.12)
		end
	end)
end

local function createLostSoul()
	local model = Instance.new("Model")
	model.Name = "Lost Soul"
	model.Parent = soulsFolder

	local root = Instance.new("Part")
	root.Name = "Soul"
	root.Anchored = true
	root.CanCollide = false
	root.Size = Vector3.new(2.3, 4.2, 2.0)
	root.Material = Enum.Material.ForceField
	root.Color = Color3.fromRGB(185, 190, 210)
	root.Position = randomArenaPosition()
	root.Parent = model
	model.PrimaryPart = root

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Anchored = true
	head.CanCollide = false
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.7, 1.7, 1.7)
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(210, 205, 198)
	head.CFrame = root.CFrame * CFrame.new(0, 2.7, 0)
	head.Parent = model

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Capture"
	prompt.ObjectText = "Lost Soul"
	prompt.HoldDuration = 0.65
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = root

	local captured = false
	prompt.Triggered:Connect(function(player)
		if captured then
			return
		end
		captured = true
		player:SetAttribute("Souls", (player:GetAttribute("Souls") or 0) + 1)
		notify(player, "Lost Soul captured. Take it to the kitchen.")
		model:Destroy()
	end)
end

local function cook(player, recipeName)
	local recipe = Config.Recipes[recipeName]
	if not recipe then
		return
	end

	local souls = player:GetAttribute("Souls") or 0
	if souls < recipe.SoulCost then
		notify(player, string.format("Need %d Lost Soul%s", recipe.SoulCost, recipe.SoulCost == 1 and "" or "s"))
		return
	end

	player:SetAttribute("Souls", souls - recipe.SoulCost)
	player:SetAttribute("Hunger", clampHunger((player:GetAttribute("Hunger") or 0) + recipe.HungerRestore))

	local _, humanoid = getCharacterHumanoid(player)
	if humanoid and recipe.Heal and recipe.Heal > 0 then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + recipe.Heal)
	end

	if recipe.SlowHungerSeconds then
		player:SetAttribute("SlowHungerUntil", Workspace:GetServerTimeNow() + recipe.SlowHungerSeconds)
	end

	notify(player, recipe.DisplayName .. " eaten")
end

for _, station in ipairs(stationsFolder:GetChildren()) do
	local prompt = station:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Triggered:Connect(function(player)
			cook(player, station:GetAttribute("Recipe"))
		end)
	end
end

local function resetPlayerForRun(player)
	player:SetAttribute("Hunger", Config.Hunger.Max)
	player:SetAttribute("Souls", 0)
	player:SetAttribute("Kills", 0)
	player:SetAttribute("SlowHungerUntil", 0)
	player:SetAttribute("StarveTime", 0)
	resetBody(player)

	local _, humanoid = getCharacterHumanoid(player)
	if humanoid then
		humanoid.Health = humanoid.MaxHealth
	end
end

local function setupPlayer(player)
	player:SetAttribute("Hunger", Config.Hunger.Max)
	player:SetAttribute("Souls", 0)
	player:SetAttribute("Kills", 0)
	player:SetAttribute("DamageMultiplier", 1)
	player:SetAttribute("HungerMultiplier", 1)
	player:SetAttribute("SlowHungerUntil", 0)
	player:SetAttribute("StarveTime", 0)

	for _, data in pairs(Config.Parts) do
		player:SetAttribute("Part_" .. data.Slot, "")
	end

	loadDNA(player)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 8)
		task.wait(0.4)
		clearPartVisuals(character)

		if humanoid then
			humanoid.Died:Connect(function()
				resetBody(player)
				player:SetAttribute("Hunger", 60)
				player:SetAttribute("Souls", 0)
				notify(player, "You died. Your grafted demon body was lost.")
			end)
		end

		task.wait(0.5)
		giveWeapon(player)
		recomputeStats(player)
	end)

	if player.Character then
		task.defer(function()
			giveWeapon(player)
			recomputeStats(player)
		end)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	saveDNA(player)
	lastAttackAt[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end

task.spawn(function()
	while true do
		task.wait(1)
		if runActive then
			for _, player in ipairs(Players:GetPlayers()) do
				local character, humanoid = getCharacterHumanoid(player)
				if character and humanoid and humanoid.Health > 0 then
					local hunger = player:GetAttribute("Hunger") or Config.Hunger.Max
					local hungerMultiplier = player:GetAttribute("HungerMultiplier") or 1
					local slowUntil = player:GetAttribute("SlowHungerUntil") or 0
					local slowMultiplier = Workspace:GetServerTimeNow() < slowUntil and 0.5 or 1

					if hunger > 0 then
						hunger -= Config.Hunger.BaseDrainPerSecond * hungerMultiplier * slowMultiplier
						player:SetAttribute("Hunger", clampHunger(hunger))
						player:SetAttribute("StarveTime", 0)
					else
						local starveTime = (player:GetAttribute("StarveTime") or 0) + 1
						player:SetAttribute("StarveTime", starveTime)
						if starveTime > Config.Hunger.StarvationGraceSeconds then
							humanoid:TakeDamage(Config.Hunger.StarvationDamagePerSecond)
						end
					end
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.Spawning.DemonInterval)
		if runActive and #demonsFolder:GetChildren() < Config.Spawning.MaxDemons then
			createDemon(chooseDemonType())
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.Spawning.SoulInterval)
		if runActive and #soulsFolder:GetChildren() < Config.Spawning.MaxSouls then
			createLostSoul()
		end
	end
end)

local function clearRunEntities()
	for _, folder in ipairs({demonsFolder, soulsFolder, dropsFolder}) do
		for _, child in ipairs(folder:GetChildren()) do
			child:Destroy()
		end
	end
end

local function runLoop()
	while true do
		currentRunId += 1
		runActive = true
		Workspace:SetAttribute("RunState", "HELL RUN")
		Workspace:SetAttribute("RunTimeLeft", Config.RunDuration)

		clearRunEntities()

		for _, player in ipairs(Players:GetPlayers()) do
			resetPlayerForRun(player)
			notify(player, "HELL RUN " .. currentRunId .. " started. Feed. Graft. Survive.")
		end

		for _ = 1, 4 do
			createDemon("Imp")
		end
		for _ = 1, 3 do
			createLostSoul()
		end

		for remaining = Config.RunDuration, 0, -1 do
			Workspace:SetAttribute("RunTimeLeft", remaining)
			if remaining == 120 then
				for _, player in ipairs(Players:GetPlayers()) do
					notify(player, "BLOOD NIGHT: two minutes remain.")
				end
			end
			task.wait(1)
		end

		runActive = false
		Workspace:SetAttribute("RunState", "ESCAPED")
		clearRunEntities()

		for _, player in ipairs(Players:GetPlayers()) do
			local kills = player:GetAttribute("Kills") or 0
			local reward = 10 + kills * 2
			player:SetAttribute("DemonDNA", (player:GetAttribute("DemonDNA") or 0) + reward)
			saveDNA(player)
			resetBody(player)
			notify(player, string.format("Run survived. +%d Demon DNA. Your grafts dissolve.", reward))
		end

		for remaining = Config.IntermissionDuration, 0, -1 do
			Workspace:SetAttribute("RunState", "INTERMISSION")
			Workspace:SetAttribute("RunTimeLeft", remaining)
			task.wait(1)
		end
	end
end

task.spawn(runLoop)
