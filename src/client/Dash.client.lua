local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local dashRemote = ReplicatedStorage:WaitForChild("HellFeastRemotes"):WaitForChild("Dash")

local gui = Instance.new("ScreenGui")
gui.Name = "HellFeastDash"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 12
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "DashButton"
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(1, -26, 1, -112)
button.Size = UDim2.fromOffset(92, 92)
button.BackgroundColor3 = Color3.fromRGB(82, 42, 58)
button.BackgroundTransparency = 0.08
button.TextColor3 = Color3.fromRGB(255, 225, 210)
button.Text = "DASH"
button.Font = Enum.Font.GothamBlack
button.TextSize = 19
button.BorderSizePixel = 0
button.AutoButtonColor = true
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(185, 90, 95)
stroke.Thickness = 2
stroke.Parent = button

local hint = Instance.new("TextLabel")
hint.Name = "KeyboardHint"
hint.AnchorPoint = Vector2.new(1, 1)
hint.Position = UDim2.new(1, -30, 1, -205)
hint.Size = UDim2.fromOffset(160, 24)
hint.BackgroundTransparency = 1
hint.Text = "Shift / Q"
hint.TextColor3 = Color3.fromRGB(190, 165, 170)
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.Parent = gui
hint.Visible = not UserInputService.TouchEnabled

local readyAt = 0
local localCooldown = Config.Movement.DashCooldown

local function getDirection()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
		local move = humanoid.MoveDirection
		return Vector3.new(move.X, 0, move.Z).Unit
	end

	local look = root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude > 0.1 then
		return flat.Unit
	end

	return nil
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
	TweenService:Create(camera, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
		FieldOfView = base + 7,
	}):Play()

	task.delay(0.1, function()
		if camera.Parent then
			TweenService:Create(camera, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
				FieldOfView = base,
			}):Play()
		end
	end)
end

local function combatActive()
	local state = Workspace:GetAttribute("RunState")
	return state == "HELL RUN" or state == "BOSS"
end

local function tryDash()
	if not combatActive() then
		return
	end

	local now = os.clock()
	if now < readyAt then
		return
	end

	local direction = getDirection()
	if not direction then
		return
	end

	local hunger = player:GetAttribute("Hunger") or 0
	if hunger < Config.Movement.DashHungerCost then
		button.Text = "TOO HUNGRY"
		task.delay(0.7, function()
			if os.clock() >= readyAt then
				button.Text = "DASH"
			end
		end)
		return
	end

	readyAt = now + localCooldown
	dashRemote:FireServer(direction)
	cameraKick()

	button.Size = UDim2.fromOffset(104, 104)
	TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(92, 92),
	}):Play()
end

button.Activated:Connect(tryDash)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.RightShift
		or input.KeyCode == Enum.KeyCode.Q then
		tryDash()
	end
end)

task.spawn(function()
	while gui.Parent do
		local remaining = readyAt - os.clock()
		if not combatActive() then
			button.Text = "WAIT"
			button.BackgroundTransparency = 0.42
			button.AutoButtonColor = false
		elseif remaining > 0 then
			button.Text = string.format("%.1f", remaining)
			button.BackgroundTransparency = 0.34
			button.AutoButtonColor = false
		else
			button.Text = "DASH"
			button.BackgroundTransparency = 0.08
			button.AutoButtonColor = true
		end
		task.wait(0.05)
	end
end)
