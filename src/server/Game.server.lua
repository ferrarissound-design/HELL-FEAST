local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))
local Progression = require(script.Parent:WaitForChild("Progression"))

Players.RespawnTime = 3

local world = World.Build()
local demonsFolder = world:WaitForChild("Demons")
local soulsFolder = world:WaitForChild("LostSouls")
local dropsFolder = world:WaitForChild("Drops")
local hazardsFolder = world:WaitForChild("Hazards")
local kitchen = world:WaitForChild("HellKitchen")
local stationsFolder = kitchen:WaitForChild("CookStations")
local upgradePads = kitchen:WaitForChild("UpgradePads")

local remotes = ReplicatedStorage:FindFirstChild("HellFeastRemotes") or Instance.new("Folder")
remotes.Name = "HellFeastRemotes"
remotes.Parent = ReplicatedStorage

local notifyRemote = remotes:FindFirstChild("Notify") or Instance.new("RemoteEvent")
notifyRemote.Name = "Notify"
notifyRemote.Parent = remotes

local decisionVoteRemote = remotes:FindFirstChild("DecisionVote") or Instance.new("RemoteEvent")
decisionVoteRemote.Name = "DecisionVote"
decisionVoteRemote.Parent = remotes

local feedbackRemote = remotes:FindFirstChild("Feedback") or Instance.new("RemoteEvent")
feedbackRemote.Name = "Feedback"
feedbackRemote.Parent = remotes

local dashRemote = remotes:FindFirstChild("Dash") or Instance.new("RemoteEvent")
dashRemote.Name = "Dash"
dashRemote.Parent = remotes

local debugRemote = remotes:FindFirstChild("DebugCommand") or Instance.new("RemoteEvent")
debugRemote.Name = "DebugCommand"
debugRemote.Parent = remotes

local runActive = false
local decisionOpen = false
local currentRunId = 0
local currentCircle = 1
local circleBossDefeated = false
local lastAttackAt = {}
local lastDashAt = {}
local hazardTouchAt = {}
local lastRecoveryAt = {}
local lastSanctuaryNoticeAt = {}
local votes = {}

Workspace:SetAttribute("RunState", "BOOTING")
Workspace:SetAttribute("RunTimeLeft", Config.RunDuration)
Workspace:SetAttribute("Circle", 1)
Workspace:SetAttribute("BossAlive", false)
Workspace:SetAttribute("DecisionOpen", false)

local function notify(player, text)
	notifyRemote:FireClient(player, text)
end

local getCharacterHumanoid

local function feedback(player, kind, payload)
	if player then
		feedbackRemote:FireClient(player, kind, payload or {})
	end
end

local function feedbackAll(kind, payload)
	for _, player in ipairs(Players:GetPlayers()) do
		feedback(player, kind, payload)
	end
end

local function damagePlayersInRadius(position, radius, amount, feedbackKind)
	for _, player in ipairs(Players:GetPlayers()) do
		local character, humanoid = getCharacterHumanoid(player)
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and humanoid and humanoid.Health > 0
			and not isPlayerProtected(player, root)
			and (root.Position - position).Magnitude <= radius then
			humanoid:TakeDamage(amount)
			if feedbackKind then
				feedback(player, feedbackKind, {Position = position, Damage = amount})
			end
		end
	end
end

local function pointSegmentDistance(point, a, b)
	local ab = b - a
	local lengthSquared = ab:Dot(ab)
	if lengthSquared <= 0.001 then
		return (point - a).Magnitude
	end
	local t = math.clamp((point - a):Dot(ab) / lengthSquared, 0, 1)
	return (point - (a + ab * t)).Magnitude
end

local function damagePlayersAlongSegment(a, b, width, amount, feedbackKind)
	for _, player in ipairs(Players:GetPlayers()) do
		local character, humanoid = getCharacterHumanoid(player)
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and humanoid and humanoid.Health > 0 and not isPlayerProtected(player, root) then
			local point = Vector3.new(root.Position.X, a.Y, root.Position.Z)
			if pointSegmentDistance(point, a, b) <= width then
				humanoid:TakeDamage(amount)
				if feedbackKind then
					feedback(player, feedbackKind, {Position = root.Position, Damage = amount})
				end
			end
		end
	end
end

local function notifyAll(text)
	for _, player in ipairs(Players:GetPlayers()) do
		notify(player, text)
	end
end

getCharacterHumanoid = function(player)
	local character = player.Character
	if not character then
		return nil, nil
	end
	return character, character:FindFirstChildOfClass("Humanoid")
end


local function flatDistanceFromKitchen(position)
	local kitchenPosition = Config.Navigation.KitchenPosition
	local dx = position.X - kitchenPosition.X
	local dz = position.Z - kitchenPosition.Z
	return math.sqrt(dx * dx + dz * dz)
end

local function isInSanctuaryPosition(position)
	return flatDistanceFromKitchen(position) <= Config.Safety.SanctuaryRadius
end

local function isPlayerProtected(player, root)
	if not root then
		return true
	end
	if isInSanctuaryPosition(root.Position) then
		return true
	end
	return Workspace:GetServerTimeNow() < (player:GetAttribute("ArrivalProtectedUntil") or 0)
end

local function connectHazard(hazard)
	if not hazard:IsA("BasePart") then
		return
	end

	hazard.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		hazardTouchAt[player] = hazardTouchAt[player] or {}
		local lastTouch = hazardTouchAt[player][hazard] or 0
		local cooldown = hazard:GetAttribute("HazardCooldown") or Config.Hazards.LavaCooldown
		local now = os.clock()
		if now - lastTouch < cooldown then
			return
		end

		hazardTouchAt[player][hazard] = now
		local damage = hazard:GetAttribute("HazardDamage") or Config.Hazards.LavaDamage
		humanoid:TakeDamage(damage)
		feedback(player, "ENVIRONMENT_HIT", {Damage = damage})
	end)
end

for _, hazard in ipairs(hazardsFolder:GetChildren()) do
	connectHazard(hazard)
end
hazardsFolder.ChildAdded:Connect(connectHazard)

local function maxHungerFor(player)
	local level = player:GetAttribute("Upgrade_Metabolism") or 0
	return Config.Hunger.Max + level * Config.Upgrades.Metabolism.MaxHungerPerLevel
end

local function maxHealthFor(player)
	local level = player:GetAttribute("Upgrade_Vitality") or 0
	return 100 + level * Config.Upgrades.Vitality.MaxHealthPerLevel
end

local function clampHungerFor(player, value)
	return math.clamp(value, 0, maxHungerFor(player))
end


dashRemote.OnServerEvent:Connect(function(player, requestedDirection)
	if not runActive then
		return
	end

	local now = os.clock()
	if now - (lastDashAt[player] or 0) < Config.Movement.DashCooldown then
		return
	end

	local character, humanoid = getCharacterHumanoid(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end

	local hunger = player:GetAttribute("Hunger") or 0
	if hunger < Config.Movement.DashHungerCost then
		notify(player, "Too hungry to dash.")
		return
	end

	local direction
	if typeof(requestedDirection) == "Vector3" then
		direction = Vector3.new(requestedDirection.X, 0, requestedDirection.Z)
	end
	if not direction or direction.Magnitude < 0.1 then
		local look = root.CFrame.LookVector
		direction = Vector3.new(look.X, 0, look.Z)
	end
	if direction.Magnitude < 0.1 then
		return
	end

	direction = direction.Unit
	lastDashAt[player] = now
	player:SetAttribute("Hunger", clampHungerFor(player, hunger - Config.Movement.DashHungerCost))
	root.AssemblyLinearVelocity = Vector3.new(
		direction.X * Config.Movement.DashSpeed,
		root.AssemblyLinearVelocity.Y,
		direction.Z * Config.Movement.DashSpeed
	)
	feedback(player, "DASH", {Cooldown = Config.Movement.DashCooldown})
end)

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
	elseif (partName == "BruteArm" or partName == "ButcherArm") and leftArm then
		local butcher = partName == "ButcherArm"
		makeVisualPart(
			holder,
			butcher and "ButcherArm" or "BruteArm",
			leftArm,
			butcher and Vector3.new(1.85, 3.0, 1.85) or Vector3.new(1.5, 2.6, 1.5),
			CFrame.new(),
			butcher and Color3.fromRGB(105, 28, 30) or Color3.fromRGB(120, 45, 40)
		)
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
	local damageMultiplier = 1 + (player:GetAttribute("Upgrade_Butchery") or 0) * Config.Upgrades.Butchery.DamagePerLevel
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
	player:SetAttribute("MaxHunger", maxHungerFor(player))

	local _, humanoid = getCharacterHumanoid(player)
	if humanoid then
		local oldMax = humanoid.MaxHealth
		local newMax = maxHealthFor(player)
		local healthRatio = oldMax > 0 and humanoid.Health / oldMax or 1
		humanoid.MaxHealth = newMax
		humanoid.Health = math.clamp(newMax * healthRatio, 1, newMax)
		humanoid.WalkSpeed = math.max(10, 16 + walkSpeedBonus)
	end

	local hunger = player:GetAttribute("Hunger") or maxHungerFor(player)
	player:SetAttribute("Hunger", clampHungerFor(player, hunger))
end

local function resetBody(player)
	for _, data in pairs(Config.Parts) do
		player:SetAttribute("Part_" .. data.Slot, "")
	end

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
	player:SetAttribute("RunGrafts", (player:GetAttribute("RunGrafts") or 0) + 1)
	applyPartVisual(player, partName)
	recomputeStats(player)

	if Progression.Discover(player, "Part", partName) then
		player:SetAttribute("RunDiscoveries", (player:GetAttribute("RunDiscoveries") or 0) + 1)
		notify(player, "HELL BOOK UPDATED • " .. data.DisplayName)
		feedback(player, "DISCOVERY", {Category = "PART", Name = data.DisplayName})
	end

	if previous and previous ~= "" and previous ~= partName then
		notify(player, string.format("%s replaced %s.", data.DisplayName, previous))
	else
		notify(player, data.DisplayName .. " grafted onto your body.")
	end
	feedback(player, "GRAFT", {Name = data.DisplayName, Slot = data.Slot})
end

local function savePlayer(player)
	task.spawn(function()
		Progression.Save(player)
	end)
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
	handle.Size = Vector3.new(0.7, 3.2, 0.8)
	handle.Material = Enum.Material.Metal
	handle.Color = Color3.fromRGB(95, 85, 82)
	handle.CanCollide = false
	handle.Parent = tool

	local blade = Instance.new("Part")
	blade.Name = "Blade"
	blade.Size = Vector3.new(1.25, 2.25, 0.28)
	blade.Material = Enum.Material.Metal
	blade.Color = Color3.fromRGB(130, 120, 115)
	blade.CanCollide = false
	blade.Massless = true
	blade.CFrame = handle.CFrame * CFrame.new(0.55, 1.8, 0)
	blade.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = blade
	weld.Parent = blade

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

		if isInSanctuaryPosition(root.Position) then
			if now - (lastSanctuaryNoticeAt[player] or 0) >= 2 then
				lastSanctuaryNoticeAt[player] = now
				notify(player, "SANCTUARY • weapons are sealed inside HELL KITCHEN.")
			end
			return
		end

		local nearest
		local nearestScore = math.huge
		local rootForward = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
		if rootForward.Magnitude > 0.01 then
			rootForward = rootForward.Unit
		end
		local assistDot = math.cos(math.rad(Config.Combat.AssistAngleDegrees * 0.5))

		for _, demon in ipairs(demonsFolder:GetChildren()) do
			local body = demon.PrimaryPart
			if body and (demon:GetAttribute("Health") or 0) > 0 then
				local offset = body.Position - root.Position
				local distance = offset.Magnitude
				if distance <= Config.Combat.AttackRange then
					local flat = Vector3.new(offset.X, 0, offset.Z)
					local facing = 1
					if flat.Magnitude > 0.01 and rootForward.Magnitude > 0.01 then
						facing = rootForward:Dot(flat.Unit)
					end

					local eligible = distance <= Config.Combat.CloseAssistRange or facing >= assistDot
					if eligible then
						local score = distance + (1 - facing) * Config.Combat.AssistFacingWeight
						if score < nearestScore then
							nearest = demon
							nearestScore = score
						end
					end
				end
			end
		end

		if nearest then
			local targetBody = nearest.PrimaryPart
			if targetBody then
				local flatTarget = Vector3.new(targetBody.Position.X, root.Position.Y, targetBody.Position.Z)
				local direction = flatTarget - root.Position
				if direction.Magnitude > 0.05 then
					root.CFrame = CFrame.lookAt(root.Position, flatTarget)
					local horizontalVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
					if horizontalVelocity.Magnitude < Config.Combat.AttackLungeSpeed then
						root.AssemblyLinearVelocity += direction.Unit * Config.Combat.AttackLungeSpeed
					end
				end
			end

			local multiplier = player:GetAttribute("DamageMultiplier") or 1
			local damage = Config.Combat.BaseDamage * multiplier
			nearest:SetAttribute("LastHitUserId", player.UserId)
			nearest:SetAttribute("Health", math.max(0, (nearest:GetAttribute("Health") or 0) - damage))
			feedback(player, "HIT", {
				Damage = math.floor(damage + 0.5),
				Position = nearest.PrimaryPart and nearest.PrimaryPart.Position or root.Position,
				IsBoss = nearest:GetAttribute("IsBoss") == true,
			})
		end
	end)
end

local demonRegions = {
	Imp = "AshFields",
	Brute = "BoneYard",
	Watcher = "SoulPens",
	FurnaceHound = "CinderRun",
	Crawler = "BoneYard",
}

local regionKeys = {"AshFields", "BoneYard", "CinderRun", "SoulPens"}

local function randomArenaPosition(regionKey)
	local region = regionKey and Config.Regions[regionKey]
	if not region then
		regionKey = regionKeys[math.random(1, #regionKeys)]
		region = Config.Regions[regionKey]
	end

	local angle = math.random() * math.pi * 2
	local radius = math.sqrt(math.random()) * math.max(8, region.Radius - 7)
	return Vector3.new(
		region.Center.X + math.cos(angle) * radius,
		3,
		region.Center.Z + math.sin(angle) * radius
	)
end

local function nearestLivingPlayer(position)
	local bestPlayer
	local bestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character, humanoid = getCharacterHumanoid(player)
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and humanoid and humanoid.Health > 0 and not isPlayerProtected(player, root) then
			local distance = (root.Position - position).Magnitude
			if distance < bestDistance then
				bestDistance = distance
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
	drop.Size = Vector3.new(2.3, 2.3, 2.3)
	drop.Anchored = true
	drop.CanCollide = false
	drop.Material = Enum.Material.Neon
	drop.Color = partName == "ButcherArm" and Color3.fromRGB(255, 45, 60) or Color3.fromRGB(180, 60, 80)
	drop.Position = position + Vector3.new(0, 2.4, 0)
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

	task.delay(40, function()
		if drop.Parent then
			drop:Destroy()
		end
	end)
end

local function chooseDemonType(circle)
	local options = {"Imp", "Brute", "Watcher"}
	if circle >= 2 then
		table.insert(options, "FurnaceHound")
	end
	if circle >= 3 then
		table.insert(options, "Crawler")
		table.insert(options, "Crawler")
	end

	local roll = math.random()
	if circle == 1 then
		if roll < 0.56 then
			return "Imp"
		elseif roll < 0.82 then
			return "Brute"
		else
			return "Watcher"
		end
	end

	return options[math.random(1, #options)]
end

local function bodyColorFor(demonType)
	local colors = {
		Imp = Color3.fromRGB(150, 55, 45),
		Brute = Color3.fromRGB(105, 45, 40),
		Watcher = Color3.fromRGB(95, 55, 110),
		FurnaceHound = Color3.fromRGB(175, 70, 28),
		Crawler = Color3.fromRGB(110, 105, 92),
		Butcher = Color3.fromRGB(88, 24, 28),
	}
	return colors[demonType] or Color3.fromRGB(120, 50, 50)
end

local function addDemonAccent(model, body, demonType)
	local function accent(name, size, offset, color, material, shape, rotation)
		local part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Size = size
		part.Color = color
		part.Material = material or Enum.Material.Slate
		part.Shape = shape or Enum.PartType.Block
		part.CFrame = body.CFrame * CFrame.new(offset) * (rotation or CFrame.new())
		part.Parent = model
		return part
	end

	if demonType == "Imp" then
		accent("LeftHorn", Vector3.new(0.35, 1.4, 0.35), Vector3.new(-0.6, body.Size.Y * 0.56, 0), Color3.fromRGB(65, 25, 25), Enum.Material.Slate, nil, CFrame.Angles(0, 0, math.rad(-18)))
		accent("RightHorn", Vector3.new(0.35, 1.4, 0.35), Vector3.new(0.6, body.Size.Y * 0.56, 0), Color3.fromRGB(65, 25, 25), Enum.Material.Slate, nil, CFrame.Angles(0, 0, math.rad(18)))
	elseif demonType == "Brute" then
		accent("LeftShoulder", Vector3.new(2.4, 2.4, 2.4), Vector3.new(-body.Size.X * 0.56, body.Size.Y * 0.22, 0), Color3.fromRGB(78, 31, 30), Enum.Material.Rock, Enum.PartType.Ball)
		accent("RightShoulder", Vector3.new(2.4, 2.4, 2.4), Vector3.new(body.Size.X * 0.56, body.Size.Y * 0.22, 0), Color3.fromRGB(78, 31, 30), Enum.Material.Rock, Enum.PartType.Ball)
	elseif demonType == "Watcher" then
		local halo = accent("EyeHalo", Vector3.new(4.4, 0.35, 4.4), Vector3.new(0, body.Size.Y * 0.12, -body.Size.Z * 0.58), Color3.fromRGB(180, 75, 210), Enum.Material.Neon, Enum.PartType.Cylinder, CFrame.Angles(math.rad(90), 0, 0))
		halo.Transparency = 0.25
	elseif demonType == "FurnaceHound" then
		for _, x in ipairs({-1, 1}) do
			for _, z in ipairs({-1.4, 1.4}) do
				accent("BurningLeg", Vector3.new(0.7, 2.1, 0.7), Vector3.new(x * body.Size.X * 0.28, -body.Size.Y * 0.65, z), Color3.fromRGB(255, 95, 25), Enum.Material.Neon)
			end
		end
		accent("FurnaceCore", Vector3.new(1.4, 1.4, 1.4), Vector3.new(0, 0, -body.Size.Z * 0.54), Color3.fromRGB(255, 190, 55), Enum.Material.Neon, Enum.PartType.Ball)
	elseif demonType == "Crawler" then
		for i = -2, 2 do
			accent("BoneSpike", Vector3.new(0.4, 1.8, 0.4), Vector3.new(i * 0.7, body.Size.Y * 0.62, i % 2 == 0 and 0.4 or -0.4), Color3.fromRGB(195, 185, 160), Enum.Material.Limestone, nil, CFrame.Angles(math.rad(i * 6), 0, math.rad(i * 8)))
		end
	elseif demonType == "Butcher" then
		accent("Apron", Vector3.new(body.Size.X * 0.72, body.Size.Y * 0.62, 0.4), Vector3.new(0, -0.8, -body.Size.Z * 0.53), Color3.fromRGB(80, 64, 58), Enum.Material.Fabric)
		accent("Cleaver", Vector3.new(2.6, 6.6, 0.65), Vector3.new(body.Size.X * 0.62, -0.6, 0), Color3.fromRGB(150, 145, 138), Enum.Material.Metal, nil, CFrame.Angles(0, 0, math.rad(-18)))
		accent("ChefCrown", Vector3.new(4.8, 2.2, 4.8), Vector3.new(0, body.Size.Y * 0.60, 0), Color3.fromRGB(170, 155, 145), Enum.Material.Fabric, Enum.PartType.Ball)
	end
end

local function createDemon(demonType, circle, forcedPosition)
	local data = Config.Demons[demonType]
	if not data then
		return nil
	end

	circle = circle or currentCircle
	local healthScale = 1 + (circle - 1) * Config.Circle.HealthMultiplierPerCircle
	local damageScale = 1 + (circle - 1) * Config.Circle.DamageMultiplierPerCircle
	local playerScale = data.IsBoss and (1 + math.max(0, #Players:GetPlayers() - 1) * 0.30) or 1
	local maxHealth = math.floor(data.MaxHealth * healthScale * playerScale)
	local damage = data.Damage * damageScale

	local model = Instance.new("Model")
	model.Name = data.DisplayName
	model:SetAttribute("DemonType", demonType)
	model:SetAttribute("Health", maxHealth)
	model:SetAttribute("MaxHealth", maxHealth)
	model:SetAttribute("LastHitUserId", 0)
	model:SetAttribute("IsBoss", data.IsBoss == true)
	model:SetAttribute("BossPhase", data.IsBoss and 1 or 0)
	model.Parent = demonsFolder

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Anchored = true
	body.CanCollide = true
	body.Material = data.IsBoss and Enum.Material.CrackedLava or Enum.Material.Slate
	body.Color = bodyColorFor(demonType)
	body.Size = data.BodyScale
	body.Position = forcedPosition or randomArenaPosition(demonRegions[demonType])
	body.Parent = model
	model.PrimaryPart = body

	local eye = Instance.new("Part")
	eye.Name = "Eye"
	eye.Anchored = true
	eye.CanCollide = false
	eye.Shape = Enum.PartType.Ball
	eye.Material = Enum.Material.Neon
	eye.Color = data.IsBoss and Color3.fromRGB(255, 210, 70) or Color3.fromRGB(255, 105, 85)
	eye.Size = data.IsBoss and Vector3.new(1.6, 1.6, 1.6) or Vector3.new(0.8, 0.8, 0.8)
	eye.CFrame = body.CFrame * CFrame.new(0, data.BodyScale.Y * 0.18, -data.BodyScale.Z * 0.52)
	eye.Parent = model

	if data.IsBoss then
		local rageLight = Instance.new("PointLight")
		rageLight.Name = "RageLight"
		rageLight.Color = Color3.fromRGB(255, 90, 50)
		rageLight.Range = 22
		rageLight.Brightness = 1.2
		rageLight.Parent = body
	end

	addDemonAccent(model, body, demonType)

	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthBillboard"
	gui.Size = data.IsBoss and UDim2.fromOffset(260, 42) or UDim2.fromOffset(130, 30)
	gui.StudsOffset = Vector3.new(0, data.BodyScale.Y * 0.7, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Size = UDim2.fromScale(1, 1)
	hpLabel.BackgroundTransparency = 0.18
	hpLabel.BackgroundColor3 = Color3.fromRGB(25, 15, 18)
	hpLabel.TextColor3 = data.IsBoss and Color3.fromRGB(255, 170, 100) or Color3.fromRGB(255, 225, 220)
	hpLabel.TextScaled = true
	hpLabel.Font = Enum.Font.GothamBlack
	hpLabel.Parent = gui

	local dead = false
	local lastDemonAttack = 0

	local healthConnection
	healthConnection = model:GetAttributeChangedSignal("Health"):Connect(function()
		local health = model:GetAttribute("Health") or 0
		hpLabel.Text = string.format("%s  %d/%d", data.DisplayName, math.ceil(health), maxHealth)

		if data.IsBoss and health > 0 and not dead then
			local ratio = health / math.max(1, maxHealth)
			local nextPhase = 1
			if ratio <= Config.Butcher.PhaseThreeHealthRatio then
				nextPhase = 3
			elseif ratio <= Config.Butcher.PhaseTwoHealthRatio then
				nextPhase = 2
			end

			local currentPhase = model:GetAttribute("BossPhase") or 1
			if nextPhase > currentPhase then
				model:SetAttribute("BossPhase", nextPhase)

				if nextPhase == 2 then
					body.Color = Color3.fromRGB(120, 30, 28)
					eye.Color = Color3.fromRGB(255, 125, 45)
					notifyAll("THE BUTCHER ENTERS PHASE II • THE KITCHEN OPENS")
					feedbackAll("BOSS_PHASE", {Phase = 2})
					task.defer(function()
						if model.Parent and runActive then
							createDemon("Imp", circle, Vector3.new(body.Position.X - 10, 3, body.Position.Z + 8))
							createDemon("Imp", circle, Vector3.new(body.Position.X + 10, 3, body.Position.Z + 8))
						end
					end)
				elseif nextPhase == 3 then
					body.Color = Color3.fromRGB(155, 22, 26)
					body.Material = Enum.Material.Neon
					eye.Color = Color3.fromRGB(255, 220, 70)
					local rageLight = body:FindFirstChild("RageLight")
					if rageLight and rageLight:IsA("PointLight") then
						rageLight.Brightness = 3.2
						rageLight.Range = 36
						rageLight.Color = Color3.fromRGB(255, 45, 35)
					end
					notifyAll("THE BUTCHER IS FRENZIED • PHASE III")
					feedbackAll("BOSS_PHASE", {Phase = 3})
					task.defer(function()
						if model.Parent and runActive then
							createDemon("Brute", circle, Vector3.new(body.Position.X, 3, body.Position.Z + 12))
						end
					end)
				end
			end
		end

		if health > 0 or dead then
			return
		end

		dead = true
		if healthConnection then
			healthConnection:Disconnect()
		end

		local killerId = model:GetAttribute("LastHitUserId") or 0
		local killer = Players:GetPlayerByUserId(killerId)
		if killer then
			killer:SetAttribute("Kills", (killer:GetAttribute("Kills") or 0) + 1)
			killer:SetAttribute("TotalKills", (killer:GetAttribute("TotalKills") or 0) + 1)
			if data.IsBoss then
				killer:SetAttribute("TotalBossKills", (killer:GetAttribute("TotalBossKills") or 0) + 1)
			end
			if Progression.Discover(killer, "Demon", demonType) then
				killer:SetAttribute("RunDiscoveries", (killer:GetAttribute("RunDiscoveries") or 0) + 1)
				notify(killer, "HELL BOOK UPDATED • " .. data.DisplayName)
				feedback(killer, "DISCOVERY", {Category = "DEMON", Name = data.DisplayName})
			end
			local dnaMultiplier = 1 + (circle - 1) * Config.Circle.DNARewardMultiplierPerCircle
			local dnaGain = math.max(1, math.floor((data.DNA or 1) * dnaMultiplier))
			killer:SetAttribute("RunDNA", (killer:GetAttribute("RunDNA") or 0) + dnaGain)
			notify(killer, string.format("+%d unbanked Demon DNA", dnaGain))
			feedback(killer, "KILL", {Demon = data.DisplayName, DNA = dnaGain, IsBoss = data.IsBoss == true})
		end

		local dropName = data.PartDrop
		if not data.IsBoss and math.random() < 0.12 then
			local rare = {"DemonHorn", "DemonWings", "ClawArm"}
			dropName = rare[math.random(1, #rare)]
		end

		dropPart(body.Position, dropName)

		feedbackAll("DEMON_DEATH", {
			Position = body.Position,
			DemonType = demonType,
			IsBoss = data.IsBoss == true,
		})

		if data.IsBoss then
			circleBossDefeated = true
			Workspace:SetAttribute("BossAlive", false)
			notifyAll("THE BUTCHER HAS FALLEN. Decide whether to escape or descend.")
		end

		model:Destroy()
	end)
	model:SetAttribute("Health", maxHealth)

	task.spawn(function()
		local lastSlam = os.clock()
		local lastSpecial = os.clock()
		local lastCrossCut = os.clock()
		model:SetAttribute("AttackBusy", false)
		while model.Parent and not dead and runActive do
			if not data.IsBoss and isInSanctuaryPosition(body.Position) then
				local center = Config.Navigation.KitchenPosition
				local away = Vector3.new(body.Position.X - center.X, 0, body.Position.Z - center.Z)
				if away.Magnitude < 0.1 then
					away = Vector3.new(0, 0, 1)
				end
				local safeRadius = Config.Safety.SanctuaryRadius + Config.Safety.SanctuaryDemonBuffer
				local retreat = Vector3.new(
					center.X + away.Unit.X * safeRadius,
					body.Position.Y,
					center.Z + away.Unit.Z * safeRadius
				)
				model:PivotTo(CFrame.lookAt(retreat, retreat + away.Unit))
			end

			local targetPlayer, distance = nearestLivingPlayer(body.Position)
			if targetPlayer then
				local character, humanoid = getCharacterHumanoid(targetPlayer)
				local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
				if targetRoot and humanoid then
					local current = body.Position
					local flatTarget = Vector3.new(targetRoot.Position.X, current.Y, targetRoot.Position.Z)
					local delta = flatTarget - current

					if delta.Magnitude > 0.01 and model:GetAttribute("AttackBusy") ~= true then
						local speedMultiplier = 1
						if data.IsBoss then
							local phase = model:GetAttribute("BossPhase") or 1
							if phase >= 3 then
								speedMultiplier = Config.Butcher.PhaseThreeSpeedMultiplier
							elseif phase >= 2 then
								speedMultiplier = Config.Butcher.PhaseTwoSpeedMultiplier
							end
						end
						local step = math.min(data.WalkSpeed * speedMultiplier * 0.12, delta.Magnitude)
						local nextPosition = current + delta.Unit * step
						model:PivotTo(CFrame.lookAt(nextPosition, flatTarget))
					end

					if distance <= data.AttackRange and os.clock() - lastDemonAttack >= data.AttackCooldown then
						lastDemonAttack = os.clock()

						if demonType == "Brute" and model:GetAttribute("AttackBusy") ~= true then
							model:SetAttribute("AttackBusy", true)
							local slamPosition = Vector3.new(body.Position.X, targetRoot.Position.Y, body.Position.Z)
							feedbackAll("TELEGRAPH_CIRCLE", {
								Position = slamPosition,
								Radius = 7,
								Duration = 0.6,
								Tone = "BRUTE",
							})
							task.delay(0.6, function()
								if model.Parent and runActive then
									local currentCharacter, currentHumanoid = getCharacterHumanoid(targetPlayer)
									local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
									if currentRoot and currentHumanoid and currentHumanoid.Health > 0 and (currentRoot.Position - body.Position).Magnitude <= 7.5 then
										currentHumanoid:TakeDamage(damage)
										feedback(targetPlayer, "ENEMY_HIT", {Demon = data.DisplayName})
										local knock = currentRoot.Position - body.Position
										if knock.Magnitude > 0.01 then
											currentRoot.AssemblyLinearVelocity += knock.Unit * 34 + Vector3.new(0, 18, 0)
										end
									end
								end
								if model.Parent then
									model:SetAttribute("AttackBusy", false)
								end
							end)
						else
							humanoid:TakeDamage(damage)
							feedback(targetPlayer, "ENEMY_HIT", {Demon = data.DisplayName})

							if demonType == "Crawler" then
								targetPlayer:SetAttribute("Hunger", clampHungerFor(targetPlayer, (targetPlayer:GetAttribute("Hunger") or 0) - 7))
								notify(targetPlayer, "Bone Crawler tore away your hunger.")
							end
						end
					end

					if demonType == "Watcher" and distance > 8 and distance <= 30 and os.clock() - lastSpecial >= 4.2 and model:GetAttribute("AttackBusy") ~= true then
						lastSpecial = os.clock()
						model:SetAttribute("AttackBusy", true)
						local targetPosition = Vector3.new(targetRoot.Position.X, targetRoot.Position.Y, targetRoot.Position.Z)
						feedbackAll("TELEGRAPH_CIRCLE", {
							Position = targetPosition,
							Radius = 5.5,
							Duration = 0.75,
							Tone = "WATCHER",
						})
						task.delay(0.75, function()
							if model.Parent and runActive then
								damagePlayersInRadius(targetPosition, 5.5, damage * 0.7, "WATCHER_BOLT")
							end
							if model.Parent then
								model:SetAttribute("AttackBusy", false)
							end
						end)
					elseif demonType == "FurnaceHound" and distance > 7 and distance <= 32 and os.clock() - lastSpecial >= 5 and model:GetAttribute("AttackBusy") ~= true then
						lastSpecial = os.clock()
						model:SetAttribute("AttackBusy", true)
						local startPosition = Vector3.new(body.Position.X, targetRoot.Position.Y, body.Position.Z)
						local charge = flatTarget - body.Position
						if charge.Magnitude > 0.01 then
							local endPosition = startPosition + charge.Unit * math.min(18, charge.Magnitude)
							feedbackAll("TELEGRAPH_LINE", {
								Start = startPosition,
								Finish = endPosition,
								Width = 4.5,
								Duration = 0.7,
								Tone = "HOUND",
							})
							task.delay(0.7, function()
								if model.Parent and runActive then
									local faceTarget = Vector3.new(endPosition.X, body.Position.Y, endPosition.Z)
									model:PivotTo(CFrame.lookAt(faceTarget, faceTarget + charge.Unit))
									damagePlayersAlongSegment(startPosition, endPosition, 4.5, damage * 1.25, "HOUND_CHARGE")
								end
								if model.Parent then
									model:SetAttribute("AttackBusy", false)
								end
							end)
						else
							model:SetAttribute("AttackBusy", false)
						end
					end
				end
			end

			if data.IsBoss then
				local phase = model:GetAttribute("BossPhase") or 1
				local slamCooldown = 7
				local slamRadius = 28
				local slamWarning = 1.25
				if phase >= 3 then
					slamCooldown = Config.Butcher.PhaseThreeSlamCooldown
					slamRadius = 32
					slamWarning = 0.9
				elseif phase >= 2 then
					slamCooldown = Config.Butcher.PhaseTwoSlamCooldown
					slamRadius = 30
					slamWarning = 1.05
				end

				if phase >= 2 and os.clock() - lastCrossCut >= (phase >= 3 and Config.Butcher.FrenzyCrossCutCooldown or Config.Butcher.CrossCutCooldown) and model:GetAttribute("AttackBusy") ~= true then
					lastCrossCut = os.clock()
					model:SetAttribute("AttackBusy", true)

					local center = Vector3.new(body.Position.X, 3, body.Position.Z)
					local forward = Vector3.new(body.CFrame.LookVector.X, 0, body.CFrame.LookVector.Z)
					if forward.Magnitude < 0.1 then
						forward = Vector3.new(0, 0, -1)
					else
						forward = forward.Unit
					end
					local right = Vector3.new(-forward.Z, 0, forward.X)
					local range = Config.Butcher.CrossCutRange

					local lineAStart = center - forward * range
					local lineAEnd = center + forward * range
					local lineBStart = center - right * range
					local lineBEnd = center + right * range
					local warning = phase >= 3 and 0.72 or 0.9

					feedbackAll("TELEGRAPH_LINE", {
						Start = lineAStart,
						Finish = lineAEnd,
						Width = Config.Butcher.CrossCutWidth,
						Duration = warning,
						Tone = "BUTCHER",
					})
					feedbackAll("TELEGRAPH_LINE", {
						Start = lineBStart,
						Finish = lineBEnd,
						Width = Config.Butcher.CrossCutWidth,
						Duration = warning,
						Tone = "BUTCHER",
					})
					notifyAll(phase >= 3 and "FRENZY CROSS-CUT!" or "BUTCHER CROSS-CUT!")

					task.delay(warning, function()
						if model.Parent and runActive then
							local cutDamage = damage * Config.Butcher.CrossCutDamageMultiplier
							damagePlayersAlongSegment(lineAStart, lineAEnd, Config.Butcher.CrossCutWidth, cutDamage, "BUTCHER_CROSS")
							damagePlayersAlongSegment(lineBStart, lineBEnd, Config.Butcher.CrossCutWidth, cutDamage, "BUTCHER_CROSS")
						end
						if model.Parent then
							model:SetAttribute("AttackBusy", false)
						end
					end)
				elseif os.clock() - lastSlam >= slamCooldown and model:GetAttribute("AttackBusy") ~= true then
					lastSlam = os.clock()
					model:SetAttribute("AttackBusy", true)
					local slamPosition = Vector3.new(body.Position.X, 3, body.Position.Z)
					feedbackAll("TELEGRAPH_CIRCLE", {
						Position = slamPosition,
						Radius = slamRadius,
						Duration = slamWarning,
						Tone = "BUTCHER",
					})
					notifyAll(phase >= 3 and "FRENZY SLAM • DASH!" or "BUTCHER SLAM • MOVE!")
					task.delay(slamWarning, function()
						if model.Parent and runActive then
							damagePlayersInRadius(slamPosition, slamRadius, damage * (phase >= 3 and 0.82 or 0.7), "BUTCHER_SLAM")
						end
						if model.Parent then
							model:SetAttribute("AttackBusy", false)
						end
					end)
				end
			end

			task.wait(0.12)
		end
	end)

	return model
end

local function createLostSoul(forcedPosition)
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
	root.Position = forcedPosition or (math.random() < 0.68 and randomArenaPosition("SoulPens") or randomArenaPosition())
	root.Parent = model
	model.PrimaryPart = root

	local soulLight = Instance.new("PointLight")
	soulLight.Name = "SoulLight"
	soulLight.Color = Color3.fromRGB(160, 145, 220)
	soulLight.Range = 14
	soulLight.Brightness = 1.4
	soulLight.Parent = root

	local highlight = Instance.new("Highlight")
	highlight.Name = "SoulHighlight"
	highlight.FillColor = Color3.fromRGB(150, 135, 215)
	highlight.FillTransparency = 0.62
	highlight.OutlineColor = Color3.fromRGB(220, 215, 255)
	highlight.OutlineTransparency = 0.35
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model

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
		local capturePosition = root.Position
		player:SetAttribute("Souls", (player:GetAttribute("Souls") or 0) + 1)
		player:SetAttribute("SoulsCaptured", (player:GetAttribute("SoulsCaptured") or 0) + 1)
		notify(player, "Lost Soul captured. Take it to HELL KITCHEN.")
		feedback(player, "SOUL_CAPTURE", {Position = capturePosition})
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
		notify(player, string.format("Need %d Lost Soul%s.", recipe.SoulCost, recipe.SoulCost == 1 and "" or "s"))
		return
	end

	player:SetAttribute("Souls", souls - recipe.SoulCost)
	player:SetAttribute("Hunger", clampHungerFor(player, (player:GetAttribute("Hunger") or 0) + recipe.HungerRestore))

	local _, humanoid = getCharacterHumanoid(player)
	if humanoid and recipe.Heal and recipe.Heal > 0 then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + recipe.Heal)
	end

	if recipe.SlowHungerSeconds then
		player:SetAttribute("SlowHungerUntil", Workspace:GetServerTimeNow() + recipe.SlowHungerSeconds)
	end

	player:SetAttribute("CookedCount", (player:GetAttribute("CookedCount") or 0) + 1)
	notify(player, recipe.DisplayName .. " eaten.")
	feedback(player, "COOK", {Name = recipe.DisplayName})
end

for _, station in ipairs(stationsFolder:GetChildren()) do
	local prompt = station:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Triggered:Connect(function(player)
			cook(player, station:GetAttribute("Recipe"))
		end)
	end
end

for _, pad in ipairs(upgradePads:GetChildren()) do
	local prompt = pad:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Triggered:Connect(function(player)
			local key = pad:GetAttribute("UpgradeKey")
			local success, message = Progression.TryUpgrade(player, Config, key)
			notify(player, message)

			if success then
				recomputeStats(player)
				savePlayer(player)
			end
		end)
	end
end

decisionVoteRemote.OnServerEvent:Connect(function(player, choice)
	if not decisionOpen then
		return
	end

	if choice ~= "ESCAPE" and choice ~= "DESCEND" then
		return
	end

	if currentCircle >= Config.MaxCircle and choice == "DESCEND" then
		return
	end

	votes[player.UserId] = choice
	player:SetAttribute("DecisionVote", choice)
	notify(player, "Vote locked: " .. choice)
end)

local function resetPlayerForNewRun(player)
	resetBody(player)
	local maxHunger = maxHungerFor(player)
	player:SetAttribute("Hunger", maxHunger)
	player:SetAttribute("MaxHunger", maxHunger)
	player:SetAttribute("Souls", 0)
	player:SetAttribute("Kills", 0)
	player:SetAttribute("RunDNA", 0)
	player:SetAttribute("CookedCount", 0)
	player:SetAttribute("SoulsCaptured", 0)
	player:SetAttribute("RunGrafts", 0)
	player:SetAttribute("RunDeaths", 0)
	player:SetAttribute("RunDiscoveries", 0)
	player:SetAttribute("SlowHungerUntil", 0)
	player:SetAttribute("StarveTime", 0)
	player:SetAttribute("DecisionVote", "")
	player:SetAttribute("ArrivalProtectedUntil", Workspace:GetServerTimeNow() + Config.Safety.ArrivalGraceSeconds)
	player:SetAttribute("InSanctuary", true)

	local _, humanoid = getCharacterHumanoid(player)
	if humanoid then
		humanoid.MaxHealth = maxHealthFor(player)
		humanoid.Health = humanoid.MaxHealth
	end
end

local function prepareDescend(player)
	local maxHunger = maxHungerFor(player)
	local hunger = player:GetAttribute("Hunger") or 0
	player:SetAttribute("Hunger", math.min(maxHunger, hunger + Config.Hunger.DescendRestore))
	player:SetAttribute("DecisionVote", "")

	local _, humanoid = getCharacterHumanoid(player)
	if humanoid then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.35)
	end
end

local function setupPlayer(player)
	player:SetAttribute("Hunger", Config.Hunger.Max)
	player:SetAttribute("MaxHunger", Config.Hunger.Max)
	player:SetAttribute("Souls", 0)
	player:SetAttribute("Kills", 0)
	player:SetAttribute("RunDNA", 0)
	player:SetAttribute("CookedCount", 0)
	player:SetAttribute("SoulsCaptured", 0)
	player:SetAttribute("RunGrafts", 0)
	player:SetAttribute("RunDeaths", 0)
	player:SetAttribute("RunDiscoveries", 0)
	player:SetAttribute("DamageMultiplier", 1)
	player:SetAttribute("HungerMultiplier", 1)
	player:SetAttribute("SlowHungerUntil", 0)
	player:SetAttribute("StarveTime", 0)
	player:SetAttribute("DecisionVote", "")
	player:SetAttribute("ArrivalProtectedUntil", Workspace:GetServerTimeNow() + Config.Safety.ArrivalGraceSeconds)
	player:SetAttribute("InSanctuary", true)

	for _, data in pairs(Config.Parts) do
		player:SetAttribute("Part_" .. data.Slot, "")
	end

	Progression.Load(player, Config)
	recomputeStats(player)
	player:SetAttribute("Hunger", maxHungerFor(player))

	player.CharacterAdded:Connect(function(character)
		player:SetAttribute("ArrivalProtectedUntil", Workspace:GetServerTimeNow() + Config.Safety.ArrivalGraceSeconds)
		local humanoid = character:WaitForChild("Humanoid", 8)
		task.wait(0.35)
		clearPartVisuals(character)
		recomputeStats(player)

		if humanoid then
			humanoid.Health = humanoid.MaxHealth
			humanoid.Died:Connect(function()
				if runActive then
					player:SetAttribute("RunDeaths", (player:GetAttribute("RunDeaths") or 0) + 1)
					local runDNA = player:GetAttribute("RunDNA") or 0
					local lost = math.floor(runDNA * 0.20)
					player:SetAttribute("RunDNA", math.max(0, runDNA - lost))
					resetBody(player)
					player:SetAttribute("Hunger", math.min(maxHungerFor(player), 60))
					player:SetAttribute("Souls", 0)
					notify(player, string.format("Death stripped your grafts. %d unbanked DNA lost.", lost))
				end
			end)
		end

		task.wait(0.35)
		giveWeapon(player)
	end)

	if player.Character then
		task.defer(function()
			player:SetAttribute("ArrivalProtectedUntil", Workspace:GetServerTimeNow() + Config.Safety.ArrivalGraceSeconds)
			recomputeStats(player)
			giveWeapon(player)
		end)
	end

	if runActive then
		task.delay(1, function()
			if player.Parent then
				notify(player, string.format("Joined Circle %d in progress • %ds arrival protection.", currentCircle, Config.Safety.ArrivalGraceSeconds))
			end
		end)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	lastAttackAt[player] = nil
	lastDashAt[player] = nil
	hazardTouchAt[player] = nil
	lastRecoveryAt[player] = nil
	lastSanctuaryNoticeAt[player] = nil
	votes[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		Progression.Save(player)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		for _, player in ipairs(Players:GetPlayers()) do
			local character, humanoid = getCharacterHumanoid(player)
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and humanoid and humanoid.Health > 0 then
				local inSanctuary = isInSanctuaryPosition(root.Position)
				player:SetAttribute("InSanctuary", inSanctuary)

				local position = root.Position
				local outOfBounds = position.Y < Config.Safety.RecoveryMinY
					or math.abs(position.X) > Config.Safety.RecoveryMaxAbsX
					or math.abs(position.Z) > Config.Safety.RecoveryMaxAbsZ

				if outOfBounds then
					local now = os.clock()
					if now - (lastRecoveryAt[player] or 0) >= Config.Safety.RecoveryCooldown then
						lastRecoveryAt[player] = now
						root.AssemblyLinearVelocity = Vector3.zero
						root.CFrame = CFrame.new(Config.Navigation.KitchenPosition + Vector3.new(0, 3, 8))
						player:SetAttribute("ArrivalProtectedUntil", Workspace:GetServerTimeNow() + Config.Safety.ArrivalGraceSeconds)
						notify(player, "The abyss returned you to HELL KITCHEN.")
					end
				end
			end
		end

		task.wait(0.5)
		if runActive then
			for _, player in ipairs(Players:GetPlayers()) do
				local _, humanoid = getCharacterHumanoid(player)
				if humanoid and humanoid.Health > 0 then
					local hunger = player:GetAttribute("Hunger") or maxHungerFor(player)
					local hungerMultiplier = player:GetAttribute("HungerMultiplier") or 1
					local slowUntil = player:GetAttribute("SlowHungerUntil") or 0
					local slowMultiplier = Workspace:GetServerTimeNow() < slowUntil and 0.5 or 1

					if hunger > 0 then
						hunger -= Config.Hunger.BaseDrainPerSecond * hungerMultiplier * slowMultiplier
						player:SetAttribute("Hunger", clampHungerFor(player, hunger))
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

local function equippedGraftCount(player)
	local count = 0
	for _, data in pairs(Config.Parts) do
		local equipped = player:GetAttribute("Part_" .. data.Slot)
		if equipped and equipped ~= "" then
			count += 1
		end
	end
	return count
end

local function directorSnapshot()
	local living = 0
	local healthTotal = 0
	local hungerTotal = 0
	local graftTotal = 0
	local hungriestPlayer
	local hungriestRatio = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character, humanoid = getCharacterHumanoid(player)
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and root and humanoid.Health > 0 then
			living += 1
			healthTotal += humanoid.Health / math.max(1, humanoid.MaxHealth)

			local hungerRatio = (player:GetAttribute("Hunger") or 0) / math.max(1, maxHungerFor(player))
			hungerTotal += hungerRatio
			graftTotal += equippedGraftCount(player)

			if hungerRatio < hungriestRatio then
				hungriestRatio = hungerRatio
				hungriestPlayer = player
			end
		end
	end

	if living == 0 then
		return {
			Living = 0,
			AverageHealth = 1,
			AverageHunger = 1,
			AverageGrafts = 0,
			HungriestPlayer = nil,
			HungriestRatio = 1,
		}
	end

	return {
		Living = living,
		AverageHealth = healthTotal / living,
		AverageHunger = hungerTotal / living,
		AverageGrafts = graftTotal / living,
		HungriestPlayer = hungriestPlayer,
		HungriestRatio = hungriestRatio,
	}
end

local function calculateDirectorPressure(snapshot)
	if snapshot.Living <= 0 then
		return Config.Director.MinPressure
	end

	local remaining = Workspace:GetAttribute("RunTimeLeft") or Config.RunDuration
	local progress = 1 - math.clamp(remaining / Config.RunDuration, 0, 1)
	local pressure = Config.Director.BasePressure
	pressure += progress * Config.Director.LateRunBoost
	pressure += math.max(0, currentCircle - 1) * Config.Director.CircleBoost
	pressure += math.max(0, snapshot.Living - 1) * Config.Director.ExtraPlayerBoost
	pressure += math.clamp(snapshot.AverageGrafts / 4, 0, 1) * Config.Director.PowerBoost
	pressure -= math.max(0, 1 - snapshot.AverageHealth) * Config.Director.LowHealthRelief

	if snapshot.AverageHunger < 0.45 then
		local hungerDistress = (0.45 - snapshot.AverageHunger) / 0.45
		pressure -= hungerDistress * Config.Director.LowHungerRelief
	end

	return math.clamp(pressure, Config.Director.MinPressure, Config.Director.MaxPressure)
end

local function directorModeFor(pressure)
	if pressure >= 0.74 then
		return "HUNT"
	elseif pressure <= 0.34 then
		return "QUIET"
	end
	return "STALK"
end

Workspace:SetAttribute("DirectorPressure", Config.Director.BasePressure)
Workspace:SetAttribute("DirectorMode", "STALK")
Workspace:SetAttribute("DirectorDemonCap", Config.Director.BaseDemonCap)

task.spawn(function()
	local nextDemonAt = 0
	local nextSoulAt = 0
	local lastEmergencySoulAt = 0

	while true do
		task.wait(Config.Director.TickSeconds)

		if not runActive or Workspace:GetAttribute("RunState") == "BOSS" then
			Workspace:SetAttribute("DirectorMode", "STALK")
			continue
		end

		local now = os.clock()
		local snapshot = directorSnapshot()
		local pressure = calculateDirectorPressure(snapshot)
		local mode = directorModeFor(pressure)

		local demonCap = Config.Director.BaseDemonCap
			+ math.max(0, snapshot.Living - 1) * Config.Director.DemonCapPerPlayer
			+ math.max(0, currentCircle - 1) * Config.Director.DemonCapPerCircle
			+ math.floor(pressure * Config.Director.MaxExtraPressureCap + 0.5)

		local soulTarget = math.min(
			Config.Spawning.MaxSouls + math.max(0, snapshot.Living - 1),
			math.max(3, snapshot.Living * Config.Director.SoulFloorPerPlayer)
		)

		Workspace:SetAttribute("DirectorPressure", pressure)
		Workspace:SetAttribute("DirectorMode", mode)
		Workspace:SetAttribute("DirectorDemonCap", demonCap)

		if now >= nextDemonAt and #demonsFolder:GetChildren() < demonCap then
			createDemon(chooseDemonType(currentCircle), currentCircle)

			local interval = Config.Director.SpawnIntervalSlow
				- (Config.Director.SpawnIntervalSlow - Config.Director.SpawnIntervalFast) * pressure
			nextDemonAt = now + interval
		end

		if now >= nextSoulAt and #soulsFolder:GetChildren() < soulTarget then
			createLostSoul()
			local soulInterval = Config.Spawning.SoulInterval + pressure * 3
			nextSoulAt = now + soulInterval
		end

		if snapshot.HungriestPlayer
			and snapshot.HungriestRatio <= Config.Director.EmergencySoulHungerRatio
			and (snapshot.HungriestPlayer:GetAttribute("Souls") or 0) <= 0
			and now - lastEmergencySoulAt >= Config.Director.EmergencySoulCooldown then

			local character = snapshot.HungriestPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				local right = root.CFrame.RightVector
				local spawnPosition = root.Position + Vector3.new(right.X, 0, right.Z) * 14
				createLostSoul(Vector3.new(spawnPosition.X, 3, spawnPosition.Z))
				lastEmergencySoulAt = now
				notify(snapshot.HungriestPlayer, "A Lost Soul surfaced nearby.")
			end
		end
	end
end)

local function clearFolder(folder)
	for _, child in ipairs(folder:GetChildren()) do
		child:Destroy()
	end
end

local function clearRunEntities(includeDrops)
	clearFolder(demonsFolder)
	clearFolder(soulsFolder)
	if includeDrops then
		clearFolder(dropsFolder)
	end
end


local function findBoss()
	for _, demon in ipairs(demonsFolder:GetChildren()) do
		if demon:GetAttribute("IsBoss") == true then
			return demon
		end
	end
	return nil
end

debugRemote.OnServerEvent:Connect(function(player, action, payload)
	if not RunService:IsStudio() then
		return
	end

	if action == "HEAL_FEED" then
		player:SetAttribute("Hunger", maxHungerFor(player))
		local _, humanoid = getCharacterHumanoid(player)
		if humanoid then
			humanoid.Health = humanoid.MaxHealth
		end
		notify(player, "DEBUG • health and hunger restored.")
	elseif action == "SOULS" then
		player:SetAttribute("Souls", (player:GetAttribute("Souls") or 0) + 3)
		notify(player, "DEBUG • +3 Lost Souls.")
	elseif action == "GRAFT" and type(payload) == "string" and Config.Parts[payload] then
		equipPart(player, payload)
		notify(player, "DEBUG • grafted " .. Config.Parts[payload].DisplayName)
	elseif action == "SPAWN" and type(payload) == "string" and Config.Demons[payload] and not Config.Demons[payload].IsBoss then
		if not runActive then
			notify(player, "DEBUG • wait for HELL RUN to start.")
			return
		end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local spawnPosition = root and (root.Position + root.CFrame.LookVector * 18) or randomArenaPosition(demonRegions[payload])
		createDemon(payload, currentCircle, Vector3.new(spawnPosition.X, 3, spawnPosition.Z))
		notify(player, "DEBUG • spawned " .. Config.Demons[payload].DisplayName)
	elseif action == "BOSS_NOW" then
		if not runActive then
			notify(player, "DEBUG • wait for HELL RUN to start.")
			return
		end
		for _, demon in ipairs(demonsFolder:GetChildren()) do
			if demon:GetAttribute("IsBoss") == true then
				demon:Destroy()
			end
		end
		circleBossDefeated = false
		Workspace:SetAttribute("RunState", "BOSS")
		Workspace:SetAttribute("BossAlive", true)
		Workspace:SetAttribute("RunTimeLeft", Config.BossWindow)
		feedbackAll("BOSS_SPAWN", {Circle = currentCircle})
		createDemon("Butcher", currentCircle, Config.Navigation.BossPosition)
		notifyAll("DEBUG • THE BUTCHER spawned immediately.")
	elseif action == "PHASE_2" then
		local boss = findBoss()
		if boss then
			local maxHealth = boss:GetAttribute("MaxHealth") or 1
			boss:SetAttribute("Health", math.max(1, math.floor(maxHealth * (Config.Butcher.PhaseTwoHealthRatio - 0.02))))
			notify(player, "DEBUG • forced Butcher Phase II.")
		else
			notify(player, "DEBUG • spawn THE BUTCHER first.")
		end
	elseif action == "PHASE_3" then
		local boss = findBoss()
		if boss then
			local maxHealth = boss:GetAttribute("MaxHealth") or 1
			boss:SetAttribute("Health", math.max(1, math.floor(maxHealth * (Config.Butcher.PhaseThreeHealthRatio - 0.02))))
			notify(player, "DEBUG • forced Butcher Phase III.")
		else
			notify(player, "DEBUG • spawn THE BUTCHER first.")
		end
	elseif action == "CIRCLE" and type(payload) == "number" then
		currentCircle = math.clamp(math.floor(payload), 1, Config.MaxCircle)
		Workspace:SetAttribute("Circle", currentCircle)
		World.ApplyCircleStyle(currentCircle)
		notifyAll(string.format("DEBUG • switched to Circle %d.", currentCircle))
	elseif action == "TP_KITCHEN" or action == "TP_BOSS" then
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local target = action == "TP_BOSS" and Config.Navigation.BossPosition or Config.Navigation.KitchenPosition
			root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
		end
	elseif action == "CLEAR" then
		clearRunEntities(true)
		Workspace:SetAttribute("BossAlive", false)
		notify(player, "DEBUG • entities cleared.")
	end
end)

local function awardRun(player, multiplier, reason)
	local unbanked = player:GetAttribute("RunDNA") or 0
	local award = math.max(0, math.floor(unbanked * (multiplier or 1)))
	local previousBest = player:GetAttribute("BestCircle") or 0
	local newBest = math.max(previousBest, currentCircle)
	local isNewBest = newBest > previousBest

	local result = {
		Reason = reason,
		Circle = currentCircle,
		Kills = player:GetAttribute("Kills") or 0,
		Cooked = player:GetAttribute("CookedCount") or 0,
		Souls = player:GetAttribute("SoulsCaptured") or 0,
		Grafts = player:GetAttribute("RunGrafts") or 0,
		Deaths = player:GetAttribute("RunDeaths") or 0,
		Discoveries = player:GetAttribute("RunDiscoveries") or 0,
		DNA = award,
		NewBest = isNewBest,
	}

	player:SetAttribute("DemonDNA", (player:GetAttribute("DemonDNA") or 0) + award)
	player:SetAttribute("BestCircle", newBest)
	player:SetAttribute("TotalRuns", (player:GetAttribute("TotalRuns") or 0) + 1)
	player:SetAttribute("RunDNA", 0)
	savePlayer(player)
	feedback(player, "RUN_RESULT", result)
	resetBody(player)
	notify(player, string.format("%s +%d banked Demon DNA.", reason, award))
end

local function conductDecision()
	decisionOpen = true
	votes = {}
	Workspace:SetAttribute("DecisionOpen", true)
	Workspace:SetAttribute("RunState", "DECISION")

	for _, player in ipairs(Players:GetPlayers()) do
		player:SetAttribute("DecisionVote", "")
	end

	for remaining = Config.DecisionDuration, 0, -1 do
		Workspace:SetAttribute("RunTimeLeft", remaining)
		task.wait(1)
	end

	decisionOpen = false
	Workspace:SetAttribute("DecisionOpen", false)

	local escapeVotes = 0
	local descendVotes = 0
	for _, player in ipairs(Players:GetPlayers()) do
		local vote = votes[player.UserId]
		if vote == "DESCEND" then
			descendVotes += 1
		else
			escapeVotes += 1
		end
	end

	if descendVotes > escapeVotes then
		return "DESCEND"
	end
	return "ESCAPE"
end

local function runCircle()
	circleBossDefeated = false
	runActive = true
	Workspace:SetAttribute("Circle", currentCircle)
	Workspace:SetAttribute("RunState", "HELL RUN")
	Workspace:SetAttribute("RunTimeLeft", Config.RunDuration)
	Workspace:SetAttribute("BossAlive", false)
	World.ApplyCircleStyle(currentCircle)

	clearRunEntities(true)

	local openingImps = 3 + currentCircle
	for _ = 1, openingImps do
		createDemon("Imp", currentCircle)
	end
	if currentCircle >= 2 then
		createDemon("FurnaceHound", currentCircle)
	end
	if currentCircle >= 3 then
		createDemon("Crawler", currentCircle)
	end

	for _ = 1, 3 do
		createLostSoul()
	end

	notifyAll(string.format("CIRCLE %d. Feed. Graft. Survive.", currentCircle))

	for remaining = Config.RunDuration, 0, -1 do
		Workspace:SetAttribute("RunTimeLeft", remaining)

		if remaining == Config.BossWindow then
			Workspace:SetAttribute("RunState", "BOSS")
			Workspace:SetAttribute("BossAlive", true)
			notifyAll("THE BUTCHER ENTERS THE SLAUGHTER PIT.")
			for _, player in ipairs(Players:GetPlayers()) do
				feedback(player, "BOSS_SPAWN", {Circle = currentCircle})
			end
			createDemon("Butcher", currentCircle, Vector3.new(0, 6, -108))
		end

		if circleBossDefeated then
			break
		end

		task.wait(1)
	end

	if not circleBossDefeated then
		runActive = false
		Workspace:SetAttribute("BossAlive", false)
		Workspace:SetAttribute("RunState", "FAILED")
		clearRunEntities(true)
		notifyAll("THE BUTCHER LIVES. The circle devours your unbanked reward.")

		for _, player in ipairs(Players:GetPlayers()) do
			local consolation = math.floor((player:GetAttribute("RunDNA") or 0) * 0.25)
			player:SetAttribute("RunDNA", consolation)
			awardRun(player, 1, "Consolation:")
		end

		task.wait(8)
		return "END"
	end

	runActive = false
	clearFolder(demonsFolder)
	clearFolder(soulsFolder)

	if currentCircle >= Config.MaxCircle then
		Workspace:SetAttribute("RunState", "ESCAPED")
		Workspace:SetAttribute("RunTimeLeft", 8)
		notifyAll("DEEPEST CIRCLE CLEARED. Your haul is secured.")

		for _, player in ipairs(Players:GetPlayers()) do
			awardRun(player, 1.5, "Deep escape:")
		end

		task.wait(8)
		return "END"
	end

	local choice = conductDecision()
	if choice == "DESCEND" then
		notifyAll("THE GATE OPENS DOWNWARD. Your grafts remain.")
		for _, player in ipairs(Players:GetPlayers()) do
			prepareDescend(player)
		end
		task.wait(3)
		return "DESCEND"
	end

	Workspace:SetAttribute("RunState", "ESCAPED")
	Workspace:SetAttribute("RunTimeLeft", 8)
	for _, player in ipairs(Players:GetPlayers()) do
		awardRun(player, 1, "Escaped:")
	end
	task.wait(8)
	return "END"
end

local function runLoop()
	while true do
		currentRunId += 1
		currentCircle = 1

		for _, player in ipairs(Players:GetPlayers()) do
			resetPlayerForNewRun(player)
		end

		local running = true
		while running do
			local result = runCircle()
			if result == "DESCEND" then
				currentCircle += 1
			else
				running = false
			end
		end

		runActive = false
		decisionOpen = false
		Workspace:SetAttribute("DecisionOpen", false)
		clearRunEntities(true)

		for remaining = Config.IntermissionDuration, 0, -1 do
			Workspace:SetAttribute("RunState", "INTERMISSION")
			Workspace:SetAttribute("RunTimeLeft", remaining)
			task.wait(1)
		end
	end
end

task.spawn(runLoop)
