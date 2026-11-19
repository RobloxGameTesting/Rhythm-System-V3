local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local PianoHandAnimator = require(ReplicatedStorage.Modules.PianoHandAnimator)
local AvatarTypeVerify = require(ReplicatedStorage.Modules.AvatarTypeVerify)

local v = { [8408487610] = true, [817083265] = true, [8783077524] = true }

local LocalPlayer = Players.LocalPlayer

local v2 = {
	{ key = "ElbowPullInFraction", step = 0.05 },
	{ key = "PoleDownRatio", step = 0.1 },
	{ key = "PoleForwardRatio", step = 0.25 },
	{ key = "PoleInwardLeftRatio", step = 0.1 },
	{ key = "PoleInwardRightRatio", step = 0.1 },
	{ key = "MaxCorrectionRatio", step = 0.1 }
}

local v3 = nil
local clone = nil
local v4 = {}
local clone2 = nil

local function refreshLivePose() -- 3 equivalent calls inferred from this helper
	local character = LocalPlayer.Character

	if not character then
		warn("[PianoPoseTuning] no character, cannot refresh pose")
		return
	end

	PianoHandAnimator.Cleanup(character)
	PianoHandAnimator.Setup(character, clone)
	print("[PianoPoseTuning] pose refreshed")
end

local function updateLabels()
	for _, v5 in ipairs(v2) do
		local v6 = v4[v5.key]

		if v6 then
			v6.Text = string.format("%.3f", clone[v5.key])
		end
	end
end

local function changeValue(key, p) -- 2 equivalent calls inferred from this helper
	local v5 = clone[key]
	clone[key] = v5 + p
	print(string.format("[PianoPoseTuning] %s: %.3f -> %.3f (delta %.3f)", key, v5, clone[key], p))
	updateLabels()
	refreshLivePose() -- inferred equivalent call
end

local function printValues()
	local _character = LocalPlayer.Character
	local v5 = tostring(AvatarTypeVerify.GetAvatarType(LocalPlayer))
	print(string.format(
		"[PianoPoseTuning] category=%s -- copy into AvatarBundleDatabase.PianoPoseOverridesByCategory:",
		v5
	))
	print(string.format(
		"\t%s = {\n\t\tElbowPullInFraction = %.4f,\n\t\tPoleDownRatio = %.4f,\n\t\tPoleForwardRatio = %.4f,\n\t\tPoleInwardLeftRatio = %.4f,\n\t\tPoleInwardRightRatio = %.4f,\n\t\tMaxCorrectionRatio = %.4f,\n\t},",
		v5,
		clone.ElbowPullInFraction,
		clone.PoleDownRatio,
		clone.PoleForwardRatio,
		clone.PoleInwardLeftRatio,
		clone.PoleInwardRightRatio,
		clone.MaxCorrectionRatio
	))
end

local function makeStepButton(frame, text, layoutOrder, onMouseButton1Click)
	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(0, 34, 1, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.Font = Enum.Font.SourceSansBold
	textButton.TextScaled = true
	textButton.AutoButtonColor = true
	textButton.Text = text
	textButton.LayoutOrder = layoutOrder
	textButton.ZIndex = 5
	textButton.Parent = frame
	textButton.MouseButton1Click:Connect(onMouseButton1Click)
	return textButton
end

local function buildGui()
	local pianoPoseTuningGui = Instance.new("ScreenGui")
	pianoPoseTuningGui.Name = "PianoPoseTuningGui"
	pianoPoseTuningGui.ResetOnSpawn = false
	pianoPoseTuningGui.DisplayOrder = 100
	pianoPoseTuningGui.IgnoreGuiInset = true

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 340, 0, 300)
	main.Position = UDim2.new(0, 16, 0.5, -150)
	main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	main.BackgroundTransparency = 0.05

	main.Parent = pianoPoseTuningGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = main

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 3)
	uiListLayout.Parent = main

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 6)
	uiPadding.PaddingLeft = UDim.new(0, 6)
	uiPadding.PaddingRight = UDim.new(0, 6)
	uiPadding.Parent = main

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 0, 22)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextScaled = true
	textLabel.LayoutOrder = 0
	textLabel.Text = "Piano Pose Tuning"
	textLabel.Parent = main

	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, 0, 0, 16)
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextColor3 = Color3.fromRGB(180, 180, 180)
	textLabel2.Font = Enum.Font.SourceSans
	textLabel2.TextScaled = true
	textLabel2.LayoutOrder = 1
	textLabel2.Text = "Check F9 console to confirm clicks are registering"
	textLabel2.Parent = main

	for i, v5 in ipairs(v2) do
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 30)
		frame.BackgroundTransparency = 1
		frame.LayoutOrder = i + 1
		frame.Parent = main

		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout2.Padding = UDim.new(0, 4)
		uiListLayout2.Parent = frame

		local textLabel3 = Instance.new("TextLabel")
		textLabel3.Size = UDim2.new(0, 148, 1, 0)
		textLabel3.BackgroundTransparency = 1
		textLabel3.TextColor3 = Color3.new(1, 1, 1)
		textLabel3.Font = Enum.Font.SourceSans
		textLabel3.TextScaled = true
		textLabel3.TextXAlignment = Enum.TextXAlignment.Left
		textLabel3.LayoutOrder = 1
		textLabel3.Text = v5.key
		textLabel3.Parent = frame

		makeStepButton(frame, "-", 2, function()
			changeValue(v5.key, -v5.step) -- inferred equivalent call
		end)

		local textLabel4 = Instance.new("TextLabel")
		textLabel4.Size = UDim2.new(0, 62, 1, 0)
		textLabel4.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		textLabel4.TextColor3 = Color3.fromRGB(255, 230, 120)
		textLabel4.Font = Enum.Font.SourceSansBold
		textLabel4.TextScaled = true
		textLabel4.LayoutOrder = 3
		v4[v5.key] = textLabel4
		textLabel4.Parent = frame

		makeStepButton(frame, "+", 4, function()
			changeValue(v5.key, v5.step) -- inferred equivalent call
		end)
	end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 32)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = 100
	frame.Parent = main

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.Padding = UDim.new(0, 6)
	uiListLayout2.Parent = frame

	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(0, 140, 1, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(40, 110, 60)
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.Font = Enum.Font.SourceSansBold
	textButton.TextScaled = true
	textButton.Text = "Print Values (F9)"
	textButton.LayoutOrder = 1
	textButton.ZIndex = 5
	textButton.Parent = frame
	textButton.MouseButton1Click:Connect(printValues)

	local textButton2 = Instance.new("TextButton")
	textButton2.Size = UDim2.new(0, 90, 1, 0)
	textButton2.BackgroundColor3 = Color3.fromRGB(110, 90, 40)
	textButton2.TextColor3 = Color3.new(1, 1, 1)
	textButton2.Font = Enum.Font.SourceSansBold
	textButton2.TextScaled = true
	textButton2.Text = "Reset"
	textButton2.LayoutOrder = 2
	textButton2.ZIndex = 5
	textButton2.Parent = frame
	textButton2.MouseButton1Click:Connect(function()
		clone = table.clone(clone2)
		print("[PianoPoseTuning] reset to saved/database values")
		updateLabels()
		refreshLivePose() -- inferred equivalent call
	end)

	local textButton3 = Instance.new("TextButton")
	textButton3.Size = UDim2.new(0, 60, 1, 0)
	textButton3.BackgroundColor3 = Color3.fromRGB(110, 40, 40)
	textButton3.TextColor3 = Color3.new(1, 1, 1)
	textButton3.Font = Enum.Font.SourceSansBold
	textButton3.TextScaled = true
	textButton3.Text = "Close"
	textButton3.LayoutOrder = 3
	textButton3.ZIndex = 5
	textButton3.Parent = frame
	textButton3.MouseButton1Click:Connect(function()
		pianoPoseTuningGui:Destroy()
		v3 = nil
	end)

	return pianoPoseTuningGui
end

local function openTool()
	if not v[LocalPlayer.UserId] then
		return
	end

	local character = LocalPlayer.Character

	if not character then
		warn("[PianoPoseTuning] no character -- sit at the Piano first, then run /tunepose")
		return
	end

	if not character:FindFirstChild("LeftUpperArm") then
		warn("[PianoPoseTuning] character has no arms (R6 or malformed rig?) -- tool needs R15")
		return
	end

	if v3 then
		v3:Destroy()
	end

	local poseParams = PianoHandAnimator.GetPoseParams(character)
	clone2 = table.clone(poseParams)
	clone = table.clone(poseParams)
	print("[PianoPoseTuning] opened. category=" .. tostring(AvatarTypeVerify.GetAvatarType(LocalPlayer)) .. " -- you do NOT need an active song playing; equip the Piano (sit down) and the panel already live-previews the pose.")

	v3 = buildGui()
	v3.Parent = LocalPlayer:WaitForChild("PlayerGui")
	updateLabels()
	refreshLivePose() -- inferred equivalent call
end

task.spawn(function()
	local textChatCommands = TextChatService:WaitForChild("TextChatCommands", 5)

	if not textChatCommands then
		return
	end

	local tunePoseCommand = textChatCommands:FindFirstChild("TunePoseCommand")

	if tunePoseCommand then
		tunePoseCommand:Destroy()
	end

	local tunePoseCommand2 = Instance.new("TextChatCommand")
	tunePoseCommand2.Name = "TunePoseCommand"
	tunePoseCommand2.PrimaryAlias = "/tunepose"
	tunePoseCommand2.Parent = textChatCommands
	tunePoseCommand2.Triggered:Connect(function(player)
		if player.UserId == LocalPlayer.UserId then
			openTool()
		end
	end)
end)