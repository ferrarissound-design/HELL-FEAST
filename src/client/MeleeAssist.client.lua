local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local highlight = Instance.new("Highlight")
highlight.Name = "LocalMeleeAssist"
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.fromRGB(255, 205, 160)
highlight.OutlineTransparency = UserInputService.TouchEnabled and 0.20 or 0.52
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.Enabled = false
highlight.Parent = Workspace

local function cleaverEquipped()
	local character = player.Character
	return character and character:FindFirstChild("Rusty Cleaver") ~= nil
end

local function bestTarget()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	local world = Workspace:FindFirstChild("HellFeastWorld")
	local demons = world and world:FindFirstChild("Demons")
	if not demons then
		return nil
	end

	local forward = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
	if forward.Magnitude > 0.01 then
		forward = forward.Unit
	end

	local best
	local bestScore = math.huge
	local assistDot = math.cos(math.rad(Config.Combat.AssistAngleDegrees * 0.5))

	for _, demon in ipairs(demons:GetChildren()) do
		local body = demon.PrimaryPart
		if body and (demon:GetAttribute("Health") or 0) > 0 then
			local offset = body.Position - root.Position
			local distance = offset.Magnitude
			if distance <= Config.Combat.AttackRange then
				local flat = Vector3.new(offset.X, 0, offset.Z)
				local facing = 1
				if flat.Magnitude > 0.01 and forward.Magnitude > 0.01 then
					facing = forward:Dot(flat.Unit)
				end

				if distance <= Config.Combat.CloseAssistRange or facing >= assistDot then
					local score = distance + (1 - facing) * Config.Combat.AssistFacingWeight
					if score < bestScore then
						best = demon
						bestScore = score
					end
				end
			end
		end
	end

	return best
end

local accumulator = 0
RunService.RenderStepped:Connect(function(dt)
	accumulator += dt
	if accumulator < 0.07 then
		return
	end
	accumulator = 0

	if not cleaverEquipped() or player:GetAttribute("InSanctuary") == true then
		highlight.Enabled = false
		highlight.Adornee = nil
		return
	end

	local target = bestTarget()
	if target then
		highlight.Adornee = target
		highlight.Enabled = true
		highlight.OutlineColor = target:GetAttribute("IsBoss") == true
			and Color3.fromRGB(255, 115, 80)
			or Color3.fromRGB(255, 205, 160)
	else
		highlight.Enabled = false
		highlight.Adornee = nil
	end
end)
