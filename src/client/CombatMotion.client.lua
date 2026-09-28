local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local bound = setmetatable({}, {__mode = "k"})

local function addTrail(tool)
	local blade = tool:FindFirstChild("Blade")
	if not blade or not blade:IsA("BasePart") or blade:FindFirstChild("SwingTrail") then
		return
	end

	local a0 = Instance.new("Attachment")
	a0.Name = "TrailTop"
	a0.Position = Vector3.new(0, blade.Size.Y * 0.48, 0)
	a0.Parent = blade

	local a1 = Instance.new("Attachment")
	a1.Name = "TrailBottom"
	a1.Position = Vector3.new(0, -blade.Size.Y * 0.48, 0)
	a1.Parent = blade

	local trail = Instance.new("Trail")
	trail.Name = "SwingTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.09
	trail.MinLength = 0.08
	trail.FaceCamera = true
	trail.LightEmission = 0.45
	trail.Color = ColorSequence.new(
		Color3.fromRGB(255, 225, 190),
		Color3.fromRGB(155, 45, 40)
	)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Enabled = false
	trail.Parent = blade
end

local function cameraKick()
	if player:GetAttribute("ReducedMotion") == true then
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local base = camera.FieldOfView
	TweenService:Create(camera, TweenInfo.new(0.07, Enum.EasingStyle.Quad), {
		FieldOfView = base + 3,
	}):Play()

	task.delay(0.08, function()
		if camera.Parent then
			TweenService:Create(camera, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
				FieldOfView = base,
			}):Play()
		end
	end)
end

local function swing(tool)
	if tool.Parent ~= player.Character or player:GetAttribute("InSanctuary") == true then
		return
	end

	local trail = tool:FindFirstChild("Blade") and tool.Blade:FindFirstChild("SwingTrail")
	local rest = tool.Grip
	local windup = rest * CFrame.new(0, 0.08, 0) * CFrame.Angles(math.rad(-12), 0, math.rad(48))
	local strike = rest * CFrame.new(0, -0.12, -0.08) * CFrame.Angles(math.rad(24), 0, math.rad(-70))

	if trail then
		trail.Enabled = true
	end

	local windupTween = TweenService:Create(tool, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Grip = windup,
	})
	windupTween:Play()

	task.delay(0.07, function()
		if not tool.Parent then
			return
		end
		cameraKick()
		local strikeTween = TweenService:Create(tool, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Grip = strike,
		})
		strikeTween:Play()

		task.delay(0.105, function()
			if tool.Parent then
				TweenService:Create(tool, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Grip = rest,
				}):Play()
			end
			if trail then
				task.delay(0.06, function()
					if trail.Parent then
						trail.Enabled = false
					end
				end)
			end
		end)
	end)
end

local function bindTool(tool)
	if not tool:IsA("Tool") or tool.Name ~= "Rusty Cleaver" or bound[tool] then
		return
	end

	bound[tool] = true
	addTrail(tool)
	tool.Activated:Connect(function()
		swing(tool)
	end)
end

local function scan(container)
	for _, child in ipairs(container:GetChildren()) do
		bindTool(child)
	end
	container.ChildAdded:Connect(bindTool)
end

local backpack = player:WaitForChild("Backpack")
scan(backpack)

local function onCharacter(character)
	scan(character)
end

player.CharacterAdded:Connect(onCharacter)
if player.Character then
	onCharacter(player.Character)
end
