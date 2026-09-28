local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local feedback = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("Feedback")

local localFolder = Instance.new("Folder")
localFolder.Name = "HellFeastLocalAtmosphere"
localFolder.Parent = Workspace

local activeMotes = 0
local lowFx = false
local maxMotes = 20

local function updateQuality()
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local mode = player:GetAttribute("SessionFXMode") or "AUTO"

	if mode == "LOW" then
		lowFx = true
	elseif mode == "HIGH" then
		lowFx = false
	else
		lowFx = UserInputService.TouchEnabled or viewport.Y < 520 or viewport.X < 800
	end

	maxMotes = lowFx and 8 or 20
	player:SetAttribute("LowFX", lowFx)
end

updateQuality()

local function shardColor(demonType)
	local colors = {
		Imp = Color3.fromRGB(165, 65, 50),
		Brute = Color3.fromRGB(115, 55, 48),
		Watcher = Color3.fromRGB(135, 80, 165),
		FurnaceHound = Color3.fromRGB(230, 90, 35),
		Crawler = Color3.fromRGB(155, 145, 125),
		Butcher = Color3.fromRGB(185, 38, 42),
	}
	return colors[demonType] or Color3.fromRGB(145, 65, 70)
end

local function makeShard(position, color, scale, lifetime)
	local shard = Instance.new("Part")
	shard.Name = "LocalHellShard"
	shard.Anchored = true
	shard.CanCollide = false
	shard.CanTouch = false
	shard.CanQuery = false
	shard.Material = Enum.Material.Neon
	shard.Color = color
	shard.Size = Vector3.new(0.22, 0.65, 0.22) * scale
	shard.CFrame = CFrame.new(position)
		* CFrame.Angles(
			math.rad(math.random(0, 359)),
			math.rad(math.random(0, 359)),
			math.rad(math.random(0, 359))
		)
	shard.Parent = localFolder

	local direction = Vector3.new(
		math.random(-100, 100) / 100,
		math.random(20, 100) / 100,
		math.random(-100, 100) / 100
	)
	if direction.Magnitude < 0.1 then
		direction = Vector3.new(0, 1, 0)
	end

	local distance = math.random(35, 80) / 10 * scale
	TweenService:Create(shard, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = position + direction.Unit * distance,
		Transparency = 1,
		Size = shard.Size * 0.15,
	}):Play()
	Debris:AddItem(shard, lifetime + 0.1)
end

local function demonDeath(payload)
	if typeof(payload.Position) ~= "Vector3" then
		return
	end

	local boss = payload.IsBoss == true
	local count = lowFx and (boss and 9 or 4) or (boss and 18 or 7)
	local scale = boss and 1.7 or 1
	local color = shardColor(payload.DemonType)

	local flash = Instance.new("Part")
	flash.Name = "LocalDeathFlash"
	flash.Anchored = true
	flash.CanCollide = false
	flash.CanTouch = false
	flash.CanQuery = false
	flash.Shape = Enum.PartType.Ball
	flash.Material = Enum.Material.Neon
	flash.Color = color
	flash.Transparency = 0.18
	flash.Size = Vector3.new(2, 2, 2) * scale
	flash.Position = payload.Position
	flash.Parent = localFolder

	TweenService:Create(flash, TweenInfo.new(boss and 0.55 or 0.30, Enum.EasingStyle.Quad), {
		Size = Vector3.new(12, 12, 12) * scale,
		Transparency = 1,
	}):Play()
	Debris:AddItem(flash, 0.65)

	for _ = 1, count do
		makeShard(payload.Position, color, scale, boss and 0.8 or 0.48)
	end
end

local function soulCapture(payload)
	if typeof(payload.Position) ~= "Vector3" then
		return
	end

	local orb = Instance.new("Part")
	orb.Name = "LocalSoulCapture"
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanTouch = false
	orb.CanQuery = false
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Color = Color3.fromRGB(175, 160, 235)
	orb.Size = Vector3.new(2.6, 2.6, 2.6)
	orb.Position = payload.Position
	orb.Transparency = 0.1
	orb.Parent = localFolder

	local light = Instance.new("PointLight")
	light.Color = orb.Color
	light.Range = 18
	light.Brightness = 2.2
	light.Parent = orb

	TweenService:Create(orb, TweenInfo.new(0.58, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = payload.Position + Vector3.new(0, 7, 0),
		Size = Vector3.new(0.25, 0.25, 0.25),
		Transparency = 1,
	}):Play()
	TweenService:Create(light, TweenInfo.new(0.58), {
		Brightness = 0,
		Range = 2,
	}):Play()
	Debris:AddItem(orb, 0.7)
end

local function spawnAshMote()
	if activeMotes >= maxMotes then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	activeMotes += 1

	local mote = Instance.new("Part")
	mote.Name = "LocalAsh"
	mote.Anchored = true
	mote.CanCollide = false
	mote.CanTouch = false
	mote.CanQuery = false
	mote.Material = Enum.Material.Neon
	mote.Color = Color3.fromRGB(140, 88, 72)
	local size = math.random(8, 22) / 100
	mote.Size = Vector3.new(size, size, size)
	mote.Transparency = math.random(35, 68) / 100
	mote.Position = root.Position + Vector3.new(
		math.random(-32, 32),
		math.random(2, 17),
		math.random(-32, 32)
	)
	mote.Parent = localFolder

	local mode = Workspace:GetAttribute("DirectorMode") or "STALK"
	local drift = mode == "HUNT" and 12 or mode == "QUIET" and 6 or 9
	local duration = math.random(24, 45) / 10

	TweenService:Create(mote, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Position = mote.Position + Vector3.new(
			math.random(-drift, drift),
			math.random(4, 10),
			math.random(-drift, drift)
		),
		Transparency = 1,
	}):Play()

	task.delay(duration + 0.05, function()
		activeMotes = math.max(0, activeMotes - 1)
		if mote.Parent then
			mote:Destroy()
		end
	end)
end

feedback.OnClientEvent:Connect(function(kind, payload)
	payload = payload or {}
	if kind == "DEMON_DEATH" then
		demonDeath(payload)
	elseif kind == "SOUL_CAPTURE" then
		soulCapture(payload)
	end
end)


task.spawn(function()
	while localFolder.Parent do
		local world = Workspace:FindFirstChild("HellFeastWorld")
		local souls = world and world:FindFirstChild("LostSouls")
		if souls then
			local now = Workspace:GetServerTimeNow()
			for index, soul in ipairs(souls:GetChildren()) do
				local root = soul.PrimaryPart
				local light = root and root:FindFirstChild("SoulLight")
				if light and light:IsA("PointLight") then
					local wave = math.sin(now * 2.4 + index * 0.85)
					light.Brightness = 1.35 + wave * 0.35
					light.Range = 13 + wave * 1.8
				end

				local highlight = soul:FindFirstChild("SoulHighlight")
				if highlight and highlight:IsA("Highlight") then
					local wave = math.sin(now * 1.8 + index * 0.7)
					highlight.FillTransparency = 0.60 + wave * 0.08
				end
			end
		end
		task.wait(lowFx and 0.16 or 0.08)
	end
end)

task.spawn(function()
	while localFolder.Parent do
		local mode = Workspace:GetAttribute("DirectorMode") or "STALK"
		local circle = Workspace:GetAttribute("Circle") or 1
		spawnAshMote()

		local interval = 0.42
		if mode == "HUNT" then
			interval = 0.25
		elseif mode == "QUIET" then
			interval = 0.65
		end
		interval = math.max(0.18, interval - (circle - 1) * 0.06)
		if lowFx then
			interval *= 1.8
		end
		task.wait(interval)
	end
end)

local cameraViewportConnection

local function bindCamera(camera)
	if cameraViewportConnection then
		cameraViewportConnection:Disconnect()
		cameraViewportConnection = nil
	end
	if camera then
		cameraViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateQuality)
	end
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindCamera(Workspace.CurrentCamera)
	updateQuality()
end)
bindCamera(Workspace.CurrentCamera)
player:GetAttributeChangedSignal("SessionFXMode"):Connect(updateQuality)

player.AncestryChanged:Connect(function(_, parent)
	if not parent and localFolder.Parent then
		localFolder:Destroy()
	end
end)
