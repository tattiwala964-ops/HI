local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "C00LKIDHub"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Create main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0.5, -100, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Make frame draggable
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Create title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "C00LKID Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Function to create buttons
local function createButton(name, yPos, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.9, 0, 0, 40)
	button.Position = UDim2.new(0.05, 0, 0, yPos)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.Text = name
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 18
	button.Parent = frame
	button.MouseButton1Click:Connect(callback)
	return button
end

-- Variables for spin feature
local isSpinning = false
local spinConnection

-- Super Jump - Fixed with BodyVelocity for true super jump effect
createButton("Super Jump", 40, function()
	if humanoid and rootPart then
		-- Create temporary BodyVelocity for super jump
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
		bodyVelocity.Velocity = Vector3.new(0, 100, 0) -- Jump height
		bodyVelocity.Parent = rootPart

		-- Remove BodyVelocity after jump
		game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
	end
end)

-- Speed Boost
createButton("Speed Boost", 90, function()
	if humanoid then
		humanoid.WalkSpeed = 50  -- Default is 16
	end
end)

-- Reset
createButton("Reset", 140, function()
	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		if isSpinning then
			isSpinning = false
			if spinConnection then
				spinConnection:Disconnect()
			end
		end
		humanoid.Health = 0  -- Respawn player
	end
end)

-- Toggle Spin
createButton("Toggle Spin", 190, function()
	if humanoid and rootPart then
		isSpinning = not isSpinning
		if isSpinning then
			spinConnection = RunService.RenderStepped:Connect(function()
				rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
			end)
		else
			if spinConnection then
				spinConnection:Disconnect()
			end
		end
	end
end)

-- Kick (client-side teleport of another player)
createButton("Kick Player", 240, function()
	local otherPlayers = Players:GetPlayers()
	for _, targetPlayer in ipairs(otherPlayers) do
		if targetPlayer ~= player and targetPlayer.Character then
			local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				targetRoot.CFrame = CFrame.new(0, 1000, 0)  -- Teleport far up (client visual)
				break
			end
		end
	end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	if isSpinning then
		if spinConnection then
			spinConnection:Disconnect()
		end
		spinConnection = RunService.RenderStepped:Connect(function()
			rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
		end)
	end
end)
