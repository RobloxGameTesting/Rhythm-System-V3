local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local AudioSpatialMode = require(ReplicatedStorage.Modules:WaitForChild("AudioSpatialMode"))

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(23, 23, 27)
local color2 = Color3.fromRGB(34, 34, 40)
local color3 = Color3.fromRGB(60, 60, 70)
local color4 = Color3.fromRGB(245, 245, 247)
local color5 = Color3.fromRGB(245, 245, 247)

local function getTopbarInsetHeight()
	local success, result = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v = not (success and result) and 0 or result.Y

	return v <= 0 and 36 or v
end

local audioModeToggleButtonGui = Instance.new("ScreenGui")
audioModeToggleButtonGui.Name = "AudioModeToggleButtonGui"
audioModeToggleButtonGui.ResetOnSpawn = false
audioModeToggleButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
audioModeToggleButtonGui.DisplayOrder = 100
audioModeToggleButtonGui.IgnoreGuiInset = true
audioModeToggleButtonGui.Parent = PlayerGui

local audioModeButton = Instance.new("TextButton")
audioModeButton.Name = "AudioModeButton"
audioModeButton.Text = ""
audioModeButton.AutoButtonColor = false
audioModeButton.AnchorPoint = Vector2.new(1, 0.5)
audioModeButton.Size = UDim2.new(0, 70, 0, 30)
local success, result = pcall(function()
	return GuiService:GetGuiInset()
end)

local v = not (success and result) and 0 or result.Y

audioModeButton.Position = UDim2.new(1, -90, 0, (v <= 0 and 36 or v) / 2)
audioModeButton.BackgroundColor3 = color
audioModeButton.ZIndex = 10
audioModeButton.Parent = audioModeToggleButtonGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = audioModeButton

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = color3
uiStroke.Transparency = 0.5
uiStroke.Thickness = 1
uiStroke.Parent = audioModeButton

local modeLabel = Instance.new("TextLabel")
modeLabel.Name = "ModeLabel"
modeLabel.BackgroundTransparency = 1
modeLabel.AnchorPoint = Vector2.new(1, 0.5)
modeLabel.Size = UDim2.new(0, 36, 0, 22)
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextScaled = true
modeLabel.TextColor3 = color5
modeLabel.Text = "3D"
modeLabel.ZIndex = 11
modeLabel.Parent = audioModeButton

local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
uiTextSizeConstraint.MaxTextSize = 11
uiTextSizeConstraint.Parent = modeLabel

local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.AnchorPoint = Vector2.new(0, 0.5)
knob.Size = UDim2.new(0, 24, 0, 24)
knob.Position = UDim2.new(0, 3, 0.5, 0)
knob.BackgroundColor3 = color2
knob.ZIndex = 12
knob.Parent = audioModeButton

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(1, 0)
uiCorner2.Parent = knob

local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Color = color3
uiStroke2.Transparency = 0.6
uiStroke2.Thickness = 1
uiStroke2.Parent = knob

local headsetIcon = Instance.new("ImageLabel")
headsetIcon.Name = "HeadsetIcon"
headsetIcon.BackgroundTransparency = 1
headsetIcon.AnchorPoint = Vector2.new(0.5, 0.5)
headsetIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
headsetIcon.Size = UDim2.new(0, 16, 0, 16)
headsetIcon.Image = "rbxassetid://85687320224063"
headsetIcon.ImageColor3 = color4
headsetIcon.ZIndex = 13
headsetIcon.Parent = knob

local function refreshVisual(p)
	local isMono = AudioSpatialMode.IsMono()
	local v2 = isMono and 43 or 3
	local vector2 = isMono and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
	local udim = isMono and UDim.new(0, 5) or UDim.new(1, -5)

	modeLabel.AnchorPoint = vector2
	modeLabel.Text = isMono and "MONO" or "3D"

	if p then
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, v2, 0.5, 0)
		}):Play()
		TweenService:Create(modeLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(udim.Scale, udim.Offset, 0.5, 0)
		}):Play()
	else
		knob.Position = UDim2.new(0, v2, 0.5, 0)
		modeLabel.Position = UDim2.new(udim.Scale, udim.Offset, 0.5, 0)
	end
end

refreshVisual(false)
AudioSpatialMode.OnChanged(function()
	refreshVisual(true)
end)

audioModeButton.MouseButton1Click:Connect(function()
	AudioSpatialMode.Toggle()
end)

local function onViewportChanged()
	local success2, result2 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v2 = not (success2 and result2) and 0 or result2.Y

	local v3 = v2 <= 0 and 36 or v2

	audioModeButton.Position = UDim2.new(1, -90, 0, v3 / 2)
end

local function connectViewportListener() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged)
	end
end

connectViewportListener() -- inferred equivalent call
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectViewportListener)