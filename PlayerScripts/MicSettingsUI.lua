local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("TweenService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MicStateUpdate = RemoteEvents:WaitForChild("MicStateUpdate")
local SetMicOn = RemoteEvents:WaitForChild("SetMicOn")
local SetMicVolume = RemoteEvents:WaitForChild("SetMicVolume")
local PutBackMic = RemoteEvents:WaitForChild("PutBackMic")
local CloseMicSettings = RemoteEvents:WaitForChild("CloseMicSettings")
local SetBVocalOn = RemoteEvents:WaitForChild("SetBVocalOn")
local SetBVocalVolume = RemoteEvents:WaitForChild("SetBVocalVolume")
local SetMicReverb = RemoteEvents:WaitForChild("SetMicReverb")
local SetMicEcho = RemoteEvents:WaitForChild("SetMicEcho")
local ClaimVocalist = RemoteEvents:WaitForChild("ClaimVocalist")
local ReleaseVocalist = RemoteEvents:WaitForChild("ReleaseVocalist")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local UISkin = require(ReplicatedStorage.Modules.SongListUI.UISkin)

local color = Color3.fromRGB(88, 210, 150)
local color2 = Color3.fromRGB(255, 165, 60)
local color3 = Color3.fromRGB(235, 80, 80)

local function getPingColorHex(vocalistSyncPingMs) -- 1 equivalent call inferred from this helper
	local v

	if vocalistSyncPingMs < 30 then
		v = color
	else
		v = if vocalistSyncPingMs <= 150 then color2 else color3
	end

	return "#" .. v:ToHex()
end

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local color4 = Color3.fromRGB(18, 18, 20)
local color5 = Color3.fromRGB(28, 28, 31)
Color3.fromRGB(50, 50, 55)
local color6 = Color3.fromRGB(240, 180, 70)
local color7 = Color3.fromRGB(25, 20, 10)
local color8 = Color3.fromRGB(240, 240, 242)
local color9 = Color3.fromRGB(150, 150, 155)
local color10 = Color3.fromRGB(120, 120, 125)

local color11 = Color3.fromRGB(36, 36, 40)

local color12 = Color3.fromRGB(88, 210, 150)
local color13 = Color3.fromRGB(15, 30, 22)
local color14 = Color3.fromRGB(235, 90, 90)
local color15 = Color3.fromRGB(40, 15, 15)

local GothamBold = Enum.Font.GothamBold
local GothamMedium = Enum.Font.GothamMedium
local Gotham = Enum.Font.Gotham

local v = nil
local v2 = 100
local v3 = false
local v4 = false
local v5 = 50
local v6 = true
local v7 = 0
local v8 = 100
local flag = false

local vocalistUserId = nil
local vocalistName = nil

local micSettingsUI = Instance.new("ScreenGui")
micSettingsUI.Name = "MicSettingsUI"
micSettingsUI.ResetOnSpawn = false
micSettingsUI.IgnoreGuiInset = true
micSettingsUI.DisplayOrder = 1000
micSettingsUI.Enabled = false
micSettingsUI.Parent = PlayerGui

local success, result = pcall(function()
	return require(ReplicatedStorage.Modules.PlayerLoadingState)
end)

if success and result then
	micSettingsUI:GetPropertyChangedSignal("Enabled"):Connect(function()
		result.ReportMicSettingsOpen(micSettingsUI.Enabled)
	end)

	micSettingsUI.Destroying:Connect(function()
		result.ReportMicSettingsOpen(false)
	end)
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.Size = UDim2.new(0, 320, 0, 444)
panel.BackgroundColor3 = color4
panel.BackgroundTransparency = 0.3
panel.BorderSizePixel = 0
panel.Parent = micSettingsUI

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.new(0, 0, 0)
uiStroke.Thickness = 1
uiStroke.Transparency = 0.2
uiStroke.Parent = panel

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "MIC SETTINGS"
title.Font = GothamBold
title.TextSize = 16
title.TextColor3 = color6
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "X"
closeButton.Font = GothamMedium
closeButton.TextSize = 16
closeButton.TextColor3 = color9
closeButton.BackgroundTransparency = 1
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -34, 0, 6)
closeButton.Parent = panel

local frame = Instance.new("Frame")
frame.BackgroundColor3 = color5
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Size = UDim2.new(1, -20, 0, 70)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.Parent = panel

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 8)
uiCorner2.Parent = frame

local textLabel = Instance.new("TextLabel")
textLabel.Text = "VOLUME"
textLabel.Font = GothamMedium
textLabel.TextSize = 13
textLabel.TextColor3 = color9
textLabel.BackgroundTransparency = 1
textLabel.Size = UDim2.new(1, -20, 0, 18)
textLabel.Position = UDim2.new(0, 10, 0, 6)
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Parent = frame

local textButton = Instance.new("TextButton")
textButton.Text = "-"
textButton.Font = GothamBold
textButton.TextSize = 16
textButton.TextColor3 = color8
textButton.BackgroundColor3 = color4
textButton.Size = UDim2.new(0, 32, 0, 32)
textButton.Position = UDim2.new(0, 10, 0, 28)
textButton.Parent = frame
local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(1, 0)
uiCorner3.Parent = textButton

local frame2 = Instance.new("Frame")
frame2.BackgroundColor3 = color11
frame2.BorderSizePixel = 0
frame2.Active = true
frame2.Size = UDim2.new(1, -140, 0, 8)
frame2.Position = UDim2.new(0, 58, 0, 40)
frame2.Parent = frame
local uiCorner4 = Instance.new("UICorner")
uiCorner4.CornerRadius = UDim.new(1, 0)
uiCorner4.Parent = frame2

local frame3 = Instance.new("Frame")
frame3.BackgroundColor3 = color6
frame3.BorderSizePixel = 0
frame3.Size = UDim2.new(0.67, 0, 1, 0)
frame3.Parent = frame2
local uiCorner5 = Instance.new("UICorner")
uiCorner5.CornerRadius = UDim.new(1, 0)
uiCorner5.Parent = frame3

local sliderHandle = Instance.new("Frame")
sliderHandle.Name = "SliderHandle"
sliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
sliderHandle.Position = UDim2.new(1, 0, 0.5, 0)
sliderHandle.Size = UDim2.new(0, 16, 0, 16)
sliderHandle.BackgroundColor3 = color8
sliderHandle.BorderSizePixel = 0
sliderHandle.ZIndex = 2
sliderHandle.Parent = frame3
local uiCorner6 = Instance.new("UICorner")
uiCorner6.CornerRadius = UDim.new(1, 0)
uiCorner6.Parent = sliderHandle

local textButton2 = Instance.new("TextButton")
textButton2.Text = "+"
textButton2.Font = GothamBold
textButton2.TextSize = 16
textButton2.TextColor3 = color8
textButton2.BackgroundColor3 = color4
textButton2.Size = UDim2.new(0, 32, 0, 32)
textButton2.Position = UDim2.new(1, -42, 0, 28)
textButton2.Parent = frame
local uiCorner7 = Instance.new("UICorner")
uiCorner7.CornerRadius = UDim.new(1, 0)
uiCorner7.Parent = textButton2

local textLabel2 = Instance.new("TextLabel")
textLabel2.Text = "100%"
textLabel2.Font = Gotham
textLabel2.TextSize = 12
textLabel2.TextColor3 = color9
textLabel2.BackgroundTransparency = 1
textLabel2.Size = UDim2.new(1, -20, 0, 14)
textLabel2.Position = UDim2.new(0, 10, 1, -18)
textLabel2.TextXAlignment = Enum.TextXAlignment.Right
textLabel2.Parent = frame

local function buildSliderRow(p, text)
	local frame4 = Instance.new("Frame")
	frame4.BackgroundColor3 = color5
	frame4.BackgroundTransparency = 0.15
	frame4.BorderSizePixel = 0
	frame4.Size = UDim2.new(1, -20, 0, 40)
	frame4.Position = UDim2.new(0, 10, 0, p)
	frame4.Parent = panel
	local uiCorner8 = Instance.new("UICorner")
	uiCorner8.CornerRadius = UDim.new(0, 8)
	uiCorner8.Parent = frame4

	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Text = text
	textLabel3.Font = GothamMedium
	textLabel3.TextSize = 10
	textLabel3.TextColor3 = color9
	textLabel3.BackgroundTransparency = 1
	textLabel3.Size = UDim2.new(0, 46, 1, 0)
	textLabel3.Position = UDim2.new(0, 10, 0, 0)
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.Parent = frame4

	local frame5 = Instance.new("Frame")
	frame5.BackgroundColor3 = color11
	frame5.BorderSizePixel = 0
	frame5.Active = true
	frame5.Size = UDim2.new(1, -140, 0, 8)
	frame5.Position = UDim2.new(0, 58, 0.5, -4)
	frame5.Parent = frame4
	local uiCorner9 = Instance.new("UICorner")
	uiCorner9.CornerRadius = UDim.new(1, 0)
	uiCorner9.Parent = frame5

	local frame6 = Instance.new("Frame")
	frame6.BackgroundColor3 = color6
	frame6.BorderSizePixel = 0
	frame6.Size = UDim2.new(0, 0, 1, 0)
	frame6.Parent = frame5
	local uiCorner10 = Instance.new("UICorner")
	uiCorner10.CornerRadius = UDim.new(1, 0)
	uiCorner10.Parent = frame6

	local sliderHandle2 = Instance.new("Frame")
	sliderHandle2.Name = "SliderHandle"
	sliderHandle2.AnchorPoint = Vector2.new(0.5, 0.5)
	sliderHandle2.Position = UDim2.new(1, 0, 0.5, 0)
	sliderHandle2.Size = UDim2.new(0, 14, 0, 14)
	sliderHandle2.BackgroundColor3 = color8
	sliderHandle2.BorderSizePixel = 0
	sliderHandle2.ZIndex = 2
	sliderHandle2.Parent = frame6
	local uiCorner11 = Instance.new("UICorner")
	uiCorner11.CornerRadius = UDim.new(1, 0)
	uiCorner11.Parent = sliderHandle2

	local textLabel4 = Instance.new("TextLabel")
	textLabel4.Text = "0%"
	textLabel4.Font = Gotham
	textLabel4.TextSize = 11
	textLabel4.TextColor3 = color9
	textLabel4.BackgroundTransparency = 1
	textLabel4.Size = UDim2.new(0, 44, 1, 0)
	textLabel4.Position = UDim2.new(1, -48, 0, 0)
	textLabel4.TextXAlignment = Enum.TextXAlignment.Right
	textLabel4.Parent = frame4

	return frame5, frame6, sliderHandle2, textLabel4
end

local sliderRow, parent, parent2, v9 = buildSliderRow(128, "REVERB")
local sliderRow2, parent3, parent4, v10 = buildSliderRow(174, "ECHO")

local frame4 = Instance.new("Frame")
frame4.BackgroundColor3 = color5
frame4.BackgroundTransparency = 0.15
frame4.BorderSizePixel = 0
frame4.Size = UDim2.new(1, -20, 0, 84)
frame4.Position = UDim2.new(0, 10, 0, 222)
frame4.Parent = panel
local uiCorner8 = Instance.new("UICorner")
uiCorner8.CornerRadius = UDim.new(0, 8)
uiCorner8.Parent = frame4

local textLabel3 = Instance.new("TextLabel")
textLabel3.Text = "BACKING VOCAL"
textLabel3.Font = GothamMedium
textLabel3.TextSize = 13
textLabel3.TextColor3 = color9
textLabel3.BackgroundTransparency = 1
textLabel3.Size = UDim2.new(1, -90, 0, 18)
textLabel3.Position = UDim2.new(0, 10, 0, 6)
textLabel3.TextXAlignment = Enum.TextXAlignment.Left
textLabel3.Parent = frame4

local textLabel4 = Instance.new("TextLabel")
textLabel4.Text = "Unavailable -- more than 1 song is playing on this stage"
textLabel4.Font = Gotham
textLabel4.TextSize = 10
textLabel4.TextColor3 = color10
textLabel4.BackgroundTransparency = 1
textLabel4.Size = UDim2.new(1, -20, 0, 14)
textLabel4.Position = UDim2.new(0, 10, 1, -16)
textLabel4.TextXAlignment = Enum.TextXAlignment.Left
textLabel4.Visible = false
textLabel4.Parent = frame4

local textButton3 = Instance.new("TextButton")
textButton3.Text = "OFF"
textButton3.Font = GothamMedium
textButton3.TextSize = 12
textButton3.TextColor3 = color9
textButton3.BackgroundColor3 = color4
textButton3.Size = UDim2.new(0, 60, 0, 22)
textButton3.Position = UDim2.new(1, -70, 0, 5)
textButton3.Parent = frame4
local uiCorner9 = Instance.new("UICorner")
uiCorner9.CornerRadius = UDim.new(0, 6)
uiCorner9.Parent = textButton3

local textButton4 = Instance.new("TextButton")
textButton4.Text = "-"
textButton4.Font = GothamBold
textButton4.TextSize = 16
textButton4.TextColor3 = color8
textButton4.BackgroundColor3 = color4
textButton4.Size = UDim2.new(0, 28, 0, 28)
textButton4.Position = UDim2.new(0, 10, 0, 42)
textButton4.Parent = frame4
local uiCorner10 = Instance.new("UICorner")
uiCorner10.CornerRadius = UDim.new(1, 0)
uiCorner10.Parent = textButton4

local frame5 = Instance.new("Frame")
frame5.BackgroundColor3 = color11
frame5.BorderSizePixel = 0
frame5.Size = UDim2.new(1, -140, 0, 8)
frame5.Position = UDim2.new(0, 58, 0, 52)
frame5.Parent = frame4
local uiCorner11 = Instance.new("UICorner")
uiCorner11.CornerRadius = UDim.new(1, 0)
uiCorner11.Parent = frame5

local frame6 = Instance.new("Frame")
frame6.BackgroundColor3 = color6
frame6.BorderSizePixel = 0
frame6.Size = UDim2.new(0.5, 0, 1, 0)
frame6.Parent = frame5
local uiCorner12 = Instance.new("UICorner")
uiCorner12.CornerRadius = UDim.new(1, 0)
uiCorner12.Parent = frame6

local sliderHandle2 = Instance.new("Frame")
sliderHandle2.Name = "SliderHandle"
sliderHandle2.AnchorPoint = Vector2.new(0.5, 0.5)
sliderHandle2.Position = UDim2.new(1, 0, 0.5, 0)
sliderHandle2.Size = UDim2.new(0, 14, 0, 14)
sliderHandle2.BackgroundColor3 = color8
sliderHandle2.BorderSizePixel = 0
sliderHandle2.ZIndex = 2
sliderHandle2.Parent = frame6
local uiCorner13 = Instance.new("UICorner")
uiCorner13.CornerRadius = UDim.new(1, 0)
uiCorner13.Parent = sliderHandle2

local textButton5 = Instance.new("TextButton")
textButton5.Text = "+"
textButton5.Font = GothamBold
textButton5.TextSize = 16
textButton5.TextColor3 = color8
textButton5.BackgroundColor3 = color4
textButton5.Size = UDim2.new(0, 28, 0, 28)
textButton5.Position = UDim2.new(1, -38, 0, 42)
textButton5.Parent = frame4
local uiCorner14 = Instance.new("UICorner")
uiCorner14.CornerRadius = UDim.new(1, 0)
uiCorner14.Parent = textButton5

local textLabel5 = Instance.new("TextLabel")
textLabel5.Text = "50%"
textLabel5.Font = Gotham
textLabel5.TextSize = 11
textLabel5.TextColor3 = color9
textLabel5.BackgroundTransparency = 1
textLabel5.Size = UDim2.new(1, -20, 0, 14)
textLabel5.Position = UDim2.new(0, 10, 1, -16)
textLabel5.TextXAlignment = Enum.TextXAlignment.Right
textLabel5.Parent = frame4

local micStatusDot = Instance.new("Frame")
micStatusDot.Name = "MicStatusDot"
micStatusDot.BorderSizePixel = 0
micStatusDot.Size = UDim2.new(0, 14, 0, 14)
micStatusDot.Position = UDim2.new(0, 10, 0, 325)
micStatusDot.Parent = panel
local uiCorner15 = Instance.new("UICorner")
uiCorner15.CornerRadius = UDim.new(1, 0)
uiCorner15.Parent = micStatusDot

local micStatusLabel = Instance.new("TextLabel")
micStatusLabel.Name = "MicStatusLabel"
micStatusLabel.Text = "OFF"
micStatusLabel.Font = GothamBold
micStatusLabel.TextSize = 14
micStatusLabel.BackgroundTransparency = 1
micStatusLabel.Size = UDim2.new(0, 55, 0, 36)
micStatusLabel.Position = UDim2.new(0, 32, 0, 314)
micStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
micStatusLabel.Parent = panel

local textButton6 = Instance.new("TextButton")
textButton6.Text = "TURN ON MIC"
textButton6.Font = GothamBold
textButton6.TextSize = 14
textButton6.TextColor3 = color7
textButton6.BackgroundColor3 = color6
textButton6.Size = UDim2.new(0, 213, 0, 36)
textButton6.Position = UDim2.new(0, 97, 0, 314)
textButton6.Parent = panel
local uiCorner16 = Instance.new("UICorner")
uiCorner16.CornerRadius = UDim.new(0, 6)
uiCorner16.Parent = textButton6

local putBackButton = Instance.new("TextButton")
putBackButton.Name = "PutBackButton"
putBackButton.Text = "PUT BACK MIC"
putBackButton.Font = GothamBold
putBackButton.TextSize = 14
putBackButton.TextColor3 = color8
putBackButton.BackgroundColor3 = color5
putBackButton.Size = UDim2.new(1, -20, 0, 36)
putBackButton.Position = UDim2.new(0, 10, 0, 356)
putBackButton.Parent = panel
local uiCorner17 = Instance.new("UICorner")
uiCorner17.CornerRadius = UDim.new(0, 6)
uiCorner17.Parent = putBackButton

local listenSelfRow = Instance.new("Frame")
listenSelfRow.Name = "ListenSelfRow"
listenSelfRow.BackgroundColor3 = color5
listenSelfRow.BackgroundTransparency = 0.15
listenSelfRow.BorderSizePixel = 0
listenSelfRow.Size = UDim2.new(1, -20, 0, 36)
listenSelfRow.Position = UDim2.new(0, 10, 0, 398)
listenSelfRow.Parent = panel
local uiCorner18 = Instance.new("UICorner")
uiCorner18.CornerRadius = UDim.new(0, 8)
uiCorner18.Parent = listenSelfRow

local textLabel6 = Instance.new("TextLabel")
textLabel6.Text = "LISTEN SELF\n(hear your own voice)"
textLabel6.TextWrapped = true
textLabel6.Font = GothamMedium
textLabel6.TextSize = 11
textLabel6.TextColor3 = color9
textLabel6.BackgroundTransparency = 1
textLabel6.Size = UDim2.new(1, -90, 1, 0)
textLabel6.Position = UDim2.new(0, 10, 0, 0)
textLabel6.TextXAlignment = Enum.TextXAlignment.Left
textLabel6.Parent = listenSelfRow

local listenSelfToggle = Instance.new("TextButton")
listenSelfToggle.Name = "ListenSelfToggle"
listenSelfToggle.Text = "OFF"
listenSelfToggle.Font = GothamMedium
listenSelfToggle.TextSize = 12
listenSelfToggle.TextColor3 = color9
listenSelfToggle.BackgroundColor3 = color4
listenSelfToggle.Size = UDim2.new(0, 60, 0, 22)
listenSelfToggle.Position = UDim2.new(1, -70, 0.5, -11)
listenSelfToggle.Parent = listenSelfRow
local uiCorner19 = Instance.new("UICorner")
uiCorner19.CornerRadius = UDim.new(0, 6)
uiCorner19.Parent = listenSelfToggle

local vocalistInfoBox = Instance.new("Frame")
vocalistInfoBox.Name = "VocalistInfoBox"
vocalistInfoBox.Position = UDim2.new(0.5, 170, 0.5, -222)
vocalistInfoBox.Size = UDim2.new(0, 270, 0, 320)
vocalistInfoBox.BackgroundColor3 = color4
vocalistInfoBox.BackgroundTransparency = 0.3
vocalistInfoBox.BorderSizePixel = 0
vocalistInfoBox.Parent = micSettingsUI
local uiCorner20 = Instance.new("UICorner")
uiCorner20.CornerRadius = UDim.new(0, 8)
uiCorner20.Parent = vocalistInfoBox
local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Color = Color3.new(0, 0, 0)
uiStroke2.Thickness = 1
uiStroke2.Transparency = 0.2
uiStroke2.Parent = vocalistInfoBox

local title2 = Instance.new("TextLabel")
title2.Name = "Title"
title2.Text = "CLAIM VOCALIST"
title2.Font = GothamBold
title2.TextSize = 14
title2.TextColor3 = color6
title2.BackgroundTransparency = 1
title2.Size = UDim2.new(1, -20, 0, 24)
title2.Position = UDim2.new(0, 10, 0, 10)
title2.TextXAlignment = Enum.TextXAlignment.Left
title2.Parent = vocalistInfoBox

local textLabel7 = Instance.new("TextLabel")
textLabel7.Text = [[
Voice chat has a tiny delay, so singing along live can sound off-beat to everyone else. Claim this and we'll speed up the instruments you hear (just for you), so your voice lines up right on time once it reaches other players. Doesn't touch scoring or gameplay, just your own audio.

Only one vocalist per stage at a time, and it stays active even if you close this panel.]]
textLabel7.Font = Gotham
textLabel7.TextSize = 12
textLabel7.TextColor3 = color9
textLabel7.TextWrapped = true
textLabel7.TextXAlignment = Enum.TextXAlignment.Left
textLabel7.TextYAlignment = Enum.TextYAlignment.Top
textLabel7.BackgroundTransparency = 1
textLabel7.Size = UDim2.new(1, -20, 0, 186)
textLabel7.Position = UDim2.new(0, 10, 0, 38)
textLabel7.Parent = vocalistInfoBox

local vocalistStatsLabel = Instance.new("TextLabel")
vocalistStatsLabel.Name = "VocalistStatsLabel"
vocalistStatsLabel.Font = Gotham
vocalistStatsLabel.TextSize = 12
vocalistStatsLabel.TextColor3 = color9
vocalistStatsLabel.TextWrapped = true
vocalistStatsLabel.RichText = true
vocalistStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
vocalistStatsLabel.TextYAlignment = Enum.TextYAlignment.Top
vocalistStatsLabel.BackgroundTransparency = 1
vocalistStatsLabel.Size = UDim2.new(1, -20, 0, 40)
vocalistStatsLabel.Position = UDim2.new(0, 10, 0, 228)
vocalistStatsLabel.Text = ""
vocalistStatsLabel.Parent = vocalistInfoBox

local textButton7 = Instance.new("TextButton")
textButton7.Text = "CLAIM VOCALIST"
textButton7.Font = GothamBold
textButton7.TextSize = 14
textButton7.TextColor3 = color8
textButton7.BackgroundColor3 = color5
textButton7.Size = UDim2.new(1, -20, 0, 36)
textButton7.Position = UDim2.new(0, 10, 0, 274)
textButton7.Parent = vocalistInfoBox
local uiCorner21 = Instance.new("UICorner")
uiCorner21.CornerRadius = UDim.new(0, 6)
uiCorner21.Parent = textButton7
local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
uiTextSizeConstraint.MaxTextSize = 14
uiTextSizeConstraint.MinTextSize = 8
uiTextSizeConstraint.Parent = textButton7
textButton7.TextScaled = true

local function pal()
	if UISkin.Applied() ~= "NewUI" then
		return color6, color7, color4, color5, color8, color9, color10, color12, color13, color14, color15
	end

	local colors = StyledTheme.Styles.NewUI.Colors
	return
		colors.Accent,
		colors.AccentText,
		colors.Background,
		colors.Surface,
		colors.TextPrimary,
		colors.TextSecondary,
		colors.TextDisabled,
		colors.Success,
		Color3.fromRGB(12, 22, 15),
		colors.Danger,
		Color3.fromRGB(240, 236, 228)
end

local function refreshVisual()
	local backgroundColor, textColor, backgroundColor2, backgroundColor3, textColor2, textColor3, textColor4, v11, textColor5, v12, textColor6 = pal()
	textLabel2.Text = v2 .. "%"
	local v13 = (v2 - 20) / 130
	frame3.Size = UDim2.new(math.clamp(v13, 0, 1), 0, 1, 0)

	if v3 then
		textButton6.Text = "TURN OFF MIC"
		textButton6.BackgroundColor3 = v11
		textButton6.TextColor3 = textColor5
		micStatusLabel.Text = "ON"
		micStatusLabel.TextColor3 = v11
		micStatusDot.BackgroundColor3 = v11
	else
		textButton6.Text = "TURN ON MIC"
		textButton6.BackgroundColor3 = v12
		textButton6.TextColor3 = textColor6
		micStatusLabel.Text = "OFF"
		micStatusLabel.TextColor3 = v12
		micStatusDot.BackgroundColor3 = v12
	end

	textLabel5.Text = v5 .. "%"
	local v14 = (v5 - 0) / 100
	frame6.Size = UDim2.new(math.clamp(v14, 0, 1), 0, 1, 0)

	if v4 then
		textButton3.Text = "ON"
		textButton3.BackgroundColor3 = backgroundColor
		textButton3.TextColor3 = textColor
	else
		textButton3.Text = "OFF"
		textButton3.BackgroundColor3 = backgroundColor2
		textButton3.TextColor3 = textColor3
	end

	local v15 = v6
	textButton3.Active = v15
	textButton4.Active = v15
	textButton5.Active = v15
	frame5.Active = v15
	local backgroundTransparency = v15 and 0 or 0.65
	textButton3.BackgroundTransparency = backgroundTransparency
	textButton4.BackgroundTransparency = backgroundTransparency
	textButton5.BackgroundTransparency = backgroundTransparency
	frame6.BackgroundTransparency = backgroundTransparency
	sliderHandle2.BackgroundTransparency = backgroundTransparency
	textLabel5.Visible = v15
	textLabel4.Visible = not v15

	v9.Text = v7 .. "%"
	local v16 = v7 / 100
	parent.Size = UDim2.new(math.clamp(v16, 0, 1), 0, 1, 0)

	v10.Text = v8 .. "%"
	local v17 = v8 / 100
	parent3.Size = UDim2.new(math.clamp(v17, 0, 1), 0, 1, 0)

	if vocalistUserId == nil then
		textButton7.Text = "CLAIM VOCALIST"
		textButton7.BackgroundColor3 = backgroundColor3
		textButton7.TextColor3 = textColor2
		textButton7.Active = true
	elseif vocalistUserId == LocalPlayer.UserId then
		textButton7.Text = "VOCALIST: @" .. LocalPlayer.Name .. " -- PRESS TO RELEASE"
		textButton7.BackgroundColor3 = backgroundColor
		textButton7.TextColor3 = textColor
		textButton7.Active = true
	else
		textButton7.Text = "VOCALIST: @" .. (vocalistName or "?")
		textButton7.BackgroundColor3 = backgroundColor2
		textButton7.TextColor3 = textColor4
		textButton7.Active = false
	end

	if LocalPlayer:GetAttribute("MicListenSelf") == true then
		listenSelfToggle.Text = "ON"
		listenSelfToggle.BackgroundColor3 = backgroundColor
		listenSelfToggle.TextColor3 = textColor
	else
		listenSelfToggle.Text = "OFF"
		listenSelfToggle.BackgroundColor3 = backgroundColor2
		listenSelfToggle.TextColor3 = textColor3
	end

	updateVocalistStatsLabel()
end

function updateVocalistStatsLabel()
	if vocalistUserId == nil then
		vocalistStatsLabel.Text = "No one is singing right now. Claim to see your ping & sync delay here."
		return
	end

	if vocalistUserId ~= LocalPlayer.UserId then
		vocalistStatsLabel.Text = "Ping & sync delay are only visible to @" .. (vocalistName or "?") .. " themself."

		return
	end

	local vocalistSyncPingMs = LocalPlayer:GetAttribute("VocalistSyncPingMs")
	local vocalistSyncOffsetMs = LocalPlayer:GetAttribute("VocalistSyncOffsetMs")
	local v11

	if vocalistSyncPingMs then
		v11 = string.format("<font color=\"%s\">%d ms</font>", getPingColorHex(vocalistSyncPingMs), vocalistSyncPingMs) -- inferred equivalent call
	else
		v11 = "measuring..."
	end

	vocalistStatsLabel.Text = "Your ping: " .. v11 .. "   |   Sync delay added: " .. (vocalistSyncOffsetMs and vocalistSyncOffsetMs .. " ms" or "measuring...")
end

LocalPlayer:GetAttributeChangedSignal("VocalistSyncPingMs"):Connect(function()
	if flag and vocalistUserId == LocalPlayer.UserId then
		updateVocalistStatsLabel()
	end
end)

LocalPlayer:GetAttributeChangedSignal("VocalistSyncOffsetMs"):Connect(function()
	if flag and vocalistUserId == LocalPlayer.UserId then
		updateVocalistStatsLabel()
	end
end)

local mouseBehavior = nil
local mouseIconEnabled = nil
local walkSpeed = nil

local flag2 = false

local function getHumanoid() -- 2 equivalent calls inferred from this helper
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function lockCameraAndMouse() -- 1 equivalent call inferred from this helper
	if flag2 then
		return
	end

	flag2 = true

	mouseBehavior = UserInputService.MouseBehavior
	mouseIconEnabled = UserInputService.MouseIconEnabled
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	local humanoid = getHumanoid() -- inferred equivalent call

	if humanoid then
		walkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 0
	end
end

local function restoreCameraAndMouse() -- 3 equivalent calls inferred from this helper
	if not flag2 then
		return
	end

	flag2 = false

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	if mouseIconEnabled ~= nil then
		UserInputService.MouseIconEnabled = mouseIconEnabled
	end

	local humanoid = getHumanoid() -- inferred equivalent call

	if humanoid and walkSpeed then
		humanoid.WalkSpeed = walkSpeed
	end

	mouseBehavior = nil
	mouseIconEnabled = nil
	walkSpeed = nil
end

RunService:BindToRenderStep("MicSettingsMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
	if not flag or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		return
	end

	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	if not UserInputService.MouseIconEnabled then
		UserInputService.MouseIconEnabled = true
	end
end)

local function closePanel() -- 1 equivalent call inferred from this helper
	if not flag then
		return
	end

	flag = false
	micSettingsUI.Enabled = false
	restoreCameraAndMouse() -- inferred equivalent call

	if v then
		CloseMicSettings:FireServer(v)
	end
end

local function setupDragSlider(list, p, p2, p3, fn, fn2, fn3)
	local v11 = false
	local v12 = 0

	local function valueFromInputPosition(p4) -- 2 equivalent calls inferred from this helper
		local x = p.AbsolutePosition.X
		local x2 = p.AbsoluteSize.X

		if x2 <= 0 then
			return fn()
		end

		local v13 = math.clamp((p4.X - x) / x2, 0, 1)
		return (math.floor(p2 + v13 * (p3 - p2) + 0.5))
	end

	local function handleInput(position, p4) -- 2 equivalent calls inferred from this helper
		local v13 = valueFromInputPosition(position) -- inferred equivalent call
		fn2(v13)
		local now = os.clock()

		if p4 or now - v12 >= 0.1 then
			v12 = now
			fn3(v13)
		end
	end

	for _, item in ipairs(list) do
		item.Active = true
		item.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				v11 = true
				handleInput(input.Position, false) -- inferred equivalent call
			end
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		if
			v11
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			handleInput(input.Position, false) -- inferred equivalent call
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if
			v11
			and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
		then
			v11 = false
			local v13 = valueFromInputPosition(input.Position) -- inferred equivalent call
			fn2(v13)
			v12 = os.clock()
			fn3(v13)
		end
	end)
end

local function openPanel(p, data)
	v = p
	v2 = data.VolumePercent or 100
	v3 = data.State == "ON_STAGE_ON"
	v7 = data.ReverbPercent or 0
	v8 = data.EchoPercent or 100
	v4 = data.BVocalOn or false
	v5 = data.BVocalVolumePercent or 50
	vocalistUserId = data.VocalistUserId
	vocalistName = data.VocalistName
	v6 = data.BVocalAvailable == nil or data.BVocalAvailable

	refreshVisual()
	flag = true
	micSettingsUI.Enabled = true
	lockCameraAndMouse() -- inferred equivalent call
end

closeButton.MouseButton1Click:Connect(closePanel)

textButton.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v2 = math.clamp(v2 - 10, 20, 150)
	refreshVisual()
	SetMicVolume:FireServer(v, v2)
end)

textButton2.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v2 = math.clamp(v2 + 10, 20, 150)
	refreshVisual()
	SetMicVolume:FireServer(v, v2)
end)

setupDragSlider({ frame2, frame3, sliderHandle }, frame2, 20, 150, function()
	return v2
end, function(p)
	if not v then
		return
	end

	v2 = p
	refreshVisual()
end, function(p)
	if v then
		SetMicVolume:FireServer(v, p)
	end
end)

textButton6.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	SetMicOn:FireServer(v, not v3)
end)

putBackButton.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	local v11 = v
	flag = false
	micSettingsUI.Enabled = false
	restoreCameraAndMouse() -- inferred equivalent call
	v = nil
	PutBackMic:FireServer(v11)
end)

textButton7.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	if vocalistUserId == LocalPlayer.UserId then
		ReleaseVocalist:FireServer(v)
	elseif vocalistUserId == nil then
		ClaimVocalist:FireServer(v)
	end
end)

listenSelfToggle.MouseButton1Click:Connect(function()
	LocalPlayer:SetAttribute("MicListenSelf", LocalPlayer:GetAttribute("MicListenSelf") ~= true)
	refreshVisual()
end)

sliderRow.Active = true

setupDragSlider({ sliderRow, parent, parent2 }, sliderRow, 0, 100, function()
	return v7
end, function(p)
	if not v then
		return
	end

	v7 = p
	refreshVisual()
end, function(p)
	if v then
		SetMicReverb:FireServer(v, p)
	end
end)

setupDragSlider({ sliderRow2, parent3, parent4 }, sliderRow2, 0, 100, function()
	return v8
end, function(p)
	if not v then
		return
	end

	v8 = p
	refreshVisual()
end, function(p)
	if v then
		SetMicEcho:FireServer(v, p)
	end
end)

textButton3.MouseButton1Click:Connect(function()
	if v and v6 then
		SetBVocalOn:FireServer(v, not v4)
	end
end)

textButton4.MouseButton1Click:Connect(function()
	if not (v and v6) then
		return
	end

	v5 = math.clamp(v5 - 10, 0, 100)
	refreshVisual()
	SetBVocalVolume:FireServer(v, v5)
end)

textButton5.MouseButton1Click:Connect(function()
	if not (v and v6) then
		return
	end

	v5 = math.clamp(v5 + 10, 0, 100)
	refreshVisual()
	SetBVocalVolume:FireServer(v, v5)
end)

setupDragSlider({ frame5, frame6, sliderHandle2 }, frame5, 0, 100, function()
	return v5
end, function(p)
	if v and v6 then
		v5 = p
		refreshVisual()
	end
end, function(p)
	if v and v6 then
		SetBVocalVolume:FireServer(v, p)
	end
end)

UISkin.AddRoot(micSettingsUI)
SettingsState.OnChanged(function()
	task.delay(0.15, function()
		if flag then
			refreshVisual()
		end
	end)
end)

MicStateUpdate.OnClientEvent:Connect(function(p, data)
	if data.RequestOpenUI then
		if not flag or p ~= v then
			openPanel(p, data)
			return
		end

		closePanel() -- inferred equivalent call
	elseif flag and p == v then
		if data.State == "STORED" then
			flag = false
			micSettingsUI.Enabled = false
			restoreCameraAndMouse() -- inferred equivalent call
			v = nil
		else
			v2 = data.VolumePercent or v2
			v3 = data.State == "ON_STAGE_ON"
			v7 = data.ReverbPercent or v7
			v8 = data.EchoPercent or v8
			v4 = data.BVocalOn
			v5 = data.BVocalVolumePercent or v5
			vocalistUserId = data.VocalistUserId
			vocalistName = data.VocalistName

			if data.BVocalAvailable ~= nil then
				v6 = data.BVocalAvailable
			end

			refreshVisual()
		end
	end
end)