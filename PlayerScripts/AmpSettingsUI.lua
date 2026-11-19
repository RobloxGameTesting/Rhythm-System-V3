local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")
local SetAmpVolume = RemoteEvents:WaitForChild("SetAmpVolume")
local SetAmpSwing = RemoteEvents:WaitForChild("SetAmpSwing")

local AmpAccessRequest = RemoteEvents:WaitForChild("AmpAccessRequest")
local AmpAccessRelease = RemoteEvents:WaitForChild("AmpAccessRelease")
local AmpRemoteEdit = RemoteEvents:WaitForChild("AmpRemoteEdit")
local AmpAccessLockSet = RemoteEvents:WaitForChild("AmpAccessLockSet")
local AmpAccessNotice = RemoteEvents:WaitForChild("AmpAccessNotice")
local AmpAccessRevoked = RemoteEvents:WaitForChild("AmpAccessRevoked")
local AmpRemoteApply = RemoteEvents:WaitForChild("AmpRemoteApply")
local AmpRemoteRestore = RemoteEvents:WaitForChild("AmpRemoteRestore")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local v = { GuitarRhythm = true, GuitarLead = true, Bass = true }

local function percentToRigMaster(p) -- 3 equivalent calls inferred from this helper
	if p <= 30 then
		return 0.7 * p / 30
	end

	return 0.7 + (p - 30) / 70 * 0.30000000000000004
end

local function rigMasterToPercent(p) -- 3 equivalent calls inferred from this helper
	if p <= 0.7 then
		return p / 0.7 * 30
	end

	return 30 + (p - 0.7) / 0.30000000000000004 * 70
end

local function percentToRhythmScale(p) -- 5 equivalent calls inferred from this helper
	if p <= 30 then
		return p / 30
	end

	return 1 + (p - 30) / 70 * 0.5
end

local v2 = {
	OnKnobChanged = function() end,
	OnKnobSet = function() end
}

local v3 = nil
local adornee = nil
local flag = false

local v4 = 30
local v5 = true

local ampSettingsPrompt = Instance.new("BillboardGui")
ampSettingsPrompt.Name = "AmpSettingsPrompt"
ampSettingsPrompt.Size = UDim2.new(0, 160, 0, 40)
ampSettingsPrompt.StudsOffset = Vector3.new(0, 2, 0)
ampSettingsPrompt.AlwaysOnTop = true
ampSettingsPrompt.Enabled = false
ampSettingsPrompt.Parent = PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 0.3
textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 16
textLabel.Text = "Amp Settings\nClick"
textLabel.Parent = ampSettingsPrompt

local v6 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v7 = v6 and 8 or 0
local ampSettingsPromptMobile = nil

local function refreshMobilePrompt() -- 4 equivalent calls inferred from this helper
	if not ampSettingsPromptMobile then
		return
	end

	local enabled

	if adornee == nil then
		enabled = false
	else
		enabled = not flag
	end

	if enabled then
		ampSettingsPromptMobile.Adornee = adornee
	end

	ampSettingsPromptMobile.Enabled = enabled
end

ampSettingsPromptMobile = Instance.new("BillboardGui")
ampSettingsPromptMobile.Name = "AmpSettingsPromptMobile"
ampSettingsPromptMobile.Size = UDim2.new(0, 170, 0, 48)
ampSettingsPromptMobile.StudsOffset = Vector3.new(0, 2, 0)
ampSettingsPromptMobile.AlwaysOnTop = true
ampSettingsPromptMobile.Active = true
ampSettingsPromptMobile.ResetOnSpawn = false
ampSettingsPromptMobile.Enabled = false
ampSettingsPromptMobile.Parent = PlayerGui

local ampSettingsButton = Instance.new("TextButton")
ampSettingsButton.Name = "AmpSettingsButton"
ampSettingsButton.Size = UDim2.new(1, 0, 1, 0)
ampSettingsButton.BackgroundColor3 = Color3.new(0, 0, 0)
ampSettingsButton.BackgroundTransparency = 0.3
ampSettingsButton.TextColor3 = Color3.new(1, 1, 1)
ampSettingsButton.Font = Enum.Font.GothamBold
ampSettingsButton.TextSize = 16
ampSettingsButton.Text = v6 and "Amp Settings\nTap" or "Amp Settings\nClick"
ampSettingsButton.AutoButtonColor = false
ampSettingsButton.Parent = ampSettingsPromptMobile

ampSettingsButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		ampSettingsButton.BackgroundTransparency = 0.05
	end
end)
ampSettingsButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		ampSettingsButton.BackgroundTransparency = 0.3
	end
end)

local AmpControlBridge = require(ReplicatedStorage.Modules.AmpControlBridge)

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local Amp = StyledTheme.Amp

local GothamBlack = Enum.Font.GothamBlack
local GothamBold = Enum.Font.GothamBold
local Gotham = Enum.Font.Gotham

local v8 = {
	{ Label = "GAIN", Field = "Gain", Default = 0, Max = 0.9 },
	{ Label = "BASS", Field = "Bass", Default = 0.5 },
	{ Label = "MID", Field = "Middle", Default = 0.5 },
	{ Label = "TREBLE", Field = "Treble", Default = 0.5 },
	{ Label = "PRESENCE", Field = "Presence", Default = 0.5 },
	{ Label = "MASTER", Field = "Master", Default = 0.7 }
}

local ampSettingsUI = Instance.new("ScreenGui")
ampSettingsUI.Name = "AmpSettingsUI"
ampSettingsUI.ResetOnSpawn = false

ampSettingsUI.DisplayOrder = 70
ampSettingsUI.Enabled = false
ampSettingsUI.Parent = PlayerGui

local udim = v6 and UDim2.new(0.5, 0, 0.5, 14) or UDim2.new(0.5, 0, 0.5, 0)

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = udim
panel.Size = UDim2.new(0, v6 and 740 or 560, 0, 0)
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.BackgroundColor3 = Amp.BG_PANEL
panel.BackgroundTransparency = 0.18
panel.BorderSizePixel = 0

panel.Active = true
panel.Parent = ampSettingsUI

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 14)
uiCorner.Parent = panel
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Amp.BORDER
uiStroke.Thickness = 1
uiStroke.Parent = panel

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Padding = UDim.new(0, 14)
uiListLayout.Parent = panel

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 18)
uiPadding.PaddingBottom = UDim.new(0, 18)
uiPadding.PaddingLeft = UDim.new(0, 18)
uiPadding.PaddingRight = UDim.new(0, 18)
uiPadding.Parent = panel

local uiScale = Instance.new("UIScale")
uiScale.Parent = panel

local function fitPanelToViewport()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v9 = panel.AbsoluteSize.Y / uiScale.Scale

	if v9 <= 0 then
		return
	end

	local guiInset = GuiService:GetGuiInset()
	local v10 = currentCamera.ViewportSize.Y - guiInset.Y - 24
	local v11

	if v6 then
		v10 = currentCamera.ViewportSize.Y - guiInset.Y - 40 - 12
		v11 = 0.4
	else
		v11 = 0.5
	end

	local scale = math.clamp(v10 / v9, v11, 1)

	if v6 then
		local v12 = panel.AbsoluteSize.X / uiScale.Scale

		if v12 > 0 then
			scale = math.min(scale, (math.clamp((currentCamera.ViewportSize.X - 24) / v12, v11, 1)))
		end
	end

	if math.abs(scale - uiScale.Scale) > 0.005 then
		uiScale.Scale = scale
	end
end

panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitPanelToViewport)

local CurrentCamera = workspace.CurrentCamera

if CurrentCamera then
	CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitPanelToViewport)
end

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundTransparency = 1
header.LayoutOrder = -1
header.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -236, 1, 0)
title.BackgroundTransparency = 1
title.Text = "AMP SETTINGS"
title.Font = GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Amp.TEXT
title.Parent = header

local udim2 = UDim2.new(0, 34, 0, 18)
local udim3 = UDim2.new(0, 14, 0, 14)

local textLabel2 = Instance.new("TextLabel")
textLabel2.AnchorPoint = Vector2.new(1, 0.5)
textLabel2.Position = UDim2.new(1, -76 - v7, 0.5, 0)
textLabel2.Size = UDim2.new(0, 60, 1, 0)
textLabel2.BackgroundTransparency = 1
textLabel2.Text = "SWING"
textLabel2.Font = GothamBold
textLabel2.TextSize = 10
textLabel2.TextXAlignment = Enum.TextXAlignment.Right
textLabel2.TextColor3 = Amp.TEXT_MUTED
textLabel2.Parent = header

local swingToggle = Instance.new("TextButton")
swingToggle.Name = "SwingToggle"
swingToggle.AnchorPoint = Vector2.new(1, 0.5)
swingToggle.Position = UDim2.new(1, -34 - v7, 0.5, 0)
local size

if v6 then
	size = UDim2.new(0, 52, 0, 30) or udim2
else
	size = udim2
end

swingToggle.Size = size
swingToggle.BackgroundTransparency = 1
swingToggle.AutoButtonColor = false
swingToggle.Text = ""
swingToggle.Parent = header

local track = Instance.new("Frame")
track.Name = "Track"
track.AnchorPoint = Vector2.new(1, 0.5)
track.Position = UDim2.new(1, 0, 0.5, 0)
track.Size = udim2
track.BackgroundColor3 = Amp.SWING_OFF
track.BorderSizePixel = 0
track.Parent = swingToggle

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(1, 0)
uiCorner2.Parent = track

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0, 0.5)
frame.Position = UDim2.new(0, 2, 0.5, 0)
frame.Size = udim3
frame.BackgroundColor3 = Amp.TEXT
frame.BorderSizePixel = 0
frame.Parent = track

local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(1, 0)
uiCorner3.Parent = frame

local ownerLabel = Instance.new("TextLabel")
ownerLabel.Name = "OwnerLabel"
ownerLabel.Size = UDim2.new(1, 0, 0, 14)
ownerLabel.BackgroundTransparency = 1
ownerLabel.Font = GothamBold
ownerLabel.TextSize = 12
ownerLabel.TextXAlignment = Enum.TextXAlignment.Left
ownerLabel.TextColor3 = Amp.TEXT_MUTED
ownerLabel.Text = ""
ownerLabel.Visible = false
ownerLabel.LayoutOrder = 0
ownerLabel.Parent = panel

local lockButton = Instance.new("TextButton")
lockButton.Name = "LockButton"
lockButton.AnchorPoint = Vector2.new(1, 0.5)
lockButton.Position = UDim2.new(1, -(146 + v7), 0.5, 0)
lockButton.Size = v6 and UDim2.new(0, 64, 0, 28) or UDim2.new(0, 58, 0, 22)
lockButton.Text = "LOCK"
lockButton.Font = GothamBold
lockButton.TextSize = 10
lockButton.BackgroundColor3 = Amp.BG_CARD
lockButton.BackgroundTransparency = 0.12
lockButton.TextColor3 = Amp.TEXT_MUTED
lockButton.AutoButtonColor = false
lockButton.Visible = false
lockButton.ZIndex = 2
lockButton.Parent = header

local uiCorner4 = Instance.new("UICorner")
uiCorner4.CornerRadius = UDim.new(0, 6)
uiCorner4.Parent = lockButton

local function makeCaption(name, text, p, p2)
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = name
	textLabel3.AnchorPoint = Vector2.new(1, 0)
	textLabel3.Position = UDim2.new(1, -(p + v7), 0, v6 and 31 or 26)
	textLabel3.Size = UDim2.new(0, p2, 0, 14)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = Gotham
	textLabel3.TextSize = 10
	textLabel3.TextXAlignment = Enum.TextXAlignment.Right
	textLabel3.TextYAlignment = Enum.TextYAlignment.Top
	textLabel3.TextColor3 = Amp.TEXT_MUTED
	textLabel3.TextTransparency = 0.15
	textLabel3.Text = text
	textLabel3.Parent = header
	return textLabel3
end

local caption = makeCaption("LockCaption", "Others can access", 146, 150)
local caption2 = makeCaption("SwingCaption", "Feedback swing", 34, 100)
caption.Visible = lockButton.Visible
lockButton:GetPropertyChangedSignal("Visible"):Connect(function()
	caption.Visible = lockButton.Visible
end)

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, 0, 0.5, 0)
closeButton.Size = v6 and UDim2.new(0, 34, 0, 34) or UDim2.new(0, 26, 0, 26)
closeButton.Text = "X"
closeButton.Font = GothamBold
closeButton.TextSize = 13
closeButton.BackgroundColor3 = Amp.BG_CARD
closeButton.BackgroundTransparency = 0.12
closeButton.AutoButtonColor = false
closeButton.TextColor3 = Amp.TEXT_MUTED
closeButton.ZIndex = 2
closeButton.Parent = header

local uiCorner5 = Instance.new("UICorner")
uiCorner5.CornerRadius = UDim.new(0, 7)
uiCorner5.Parent = closeButton

local v9 = false
local v10 = nil
local position = nil
local position2 = nil

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v9 = true
		position = input.Position
		position2 = panel.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				v9 = false
			end
		end)
	end
end)

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		v10 = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == v10 and v9 then
		local v11 = input.Position - position
		panel.Position = UDim2.new(
			position2.X.Scale,
			position2.X.Offset + v11.X,
			position2.Y.Scale,
			position2.Y.Offset + v11.Y
		)
	end
end)

local function createSection(parent, text, layoutOrder, udim4)
	local frame2 = Instance.new("Frame")
	frame2.Name = text .. "Section"
	frame2.Size = udim4 or UDim2.new(1, 0, 0, 0)
	frame2.AutomaticSize = Enum.AutomaticSize.Y
	frame2.BackgroundColor3 = Amp.BG_CARD
	frame2.BackgroundTransparency = 0.12
	frame2.BorderSizePixel = 0
	frame2.LayoutOrder = layoutOrder
	frame2.Parent = parent

	local uiCorner6 = Instance.new("UICorner")
	uiCorner6.CornerRadius = UDim.new(0, 10)
	uiCorner6.Parent = frame2

	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.PaddingTop = UDim.new(0, 12)
	uiPadding2.PaddingBottom = UDim.new(0, 12)
	uiPadding2.PaddingLeft = UDim.new(0, 14)
	uiPadding2.PaddingRight = UDim.new(0, 14)
	uiPadding2.Parent = frame2

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.FillDirection = Enum.FillDirection.Vertical
	uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout2.Padding = UDim.new(0, 10)
	uiListLayout2.Parent = frame2

	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Size = UDim2.new(1, 0, 0, 14)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Text = text
	textLabel3.Font = GothamBold
	textLabel3.TextSize = 11
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.TextColor3 = Amp.TEXT_MUTED
	textLabel3.LayoutOrder = 0
	textLabel3.Parent = frame2

	return frame2
end

local topRow = Instance.new("Frame")
topRow.Name = "TopRow"
topRow.Size = UDim2.new(1, 0, 0, 0)
topRow.AutomaticSize = Enum.AutomaticSize.Y
topRow.BackgroundTransparency = 1
topRow.LayoutOrder = 2
topRow.Parent = panel

local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Top
uiListLayout2.Padding = UDim.new(0, 12)
uiListLayout2.Parent = topRow

local section = createSection(topRow, "MASTER VOLUME", 2, UDim2.new(0, 260, 0, 0))

local textLabel3 = Instance.new("TextLabel")
textLabel3.Size = UDim2.new(1, 0, 0, 28)
textLabel3.BackgroundTransparency = 1
textLabel3.Font = GothamBlack
textLabel3.TextSize = 22
textLabel3.TextColor3 = Amp.TEXT
textLabel3.LayoutOrder = 1
textLabel3.Parent = section

local frame2 = Instance.new("Frame")
frame2.Size = UDim2.new(1, 0, 0, 44)
frame2.BackgroundTransparency = 1
frame2.LayoutOrder = 2
frame2.Parent = section

local uiListLayout3 = Instance.new("UIListLayout")
uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
uiListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout3.Padding = UDim.new(0, 8)
uiListLayout3.Parent = frame2

local function createRoundButton(text, frame3, layoutOrder)
	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(0, 44, 0, 44)
	textButton.Text = text
	textButton.Font = GothamBold
	textButton.TextSize = 22
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = Amp.KNOB_DISABLED
	textButton.BackgroundTransparency = 0.12
	textButton.TextColor3 = Amp.TEXT
	textButton.LayoutOrder = layoutOrder
	textButton.Parent = frame3
	local uiCorner6 = Instance.new("UICorner")
	uiCorner6.CornerRadius = UDim.new(1, 0)
	uiCorner6.Parent = textButton
	return textButton
end

local roundButton = createRoundButton("-", frame2, 1)

local volumeSlider = Instance.new("Frame")
volumeSlider.Name = "VolumeSlider"
volumeSlider.Size = UDim2.new(0, 128, 0, 44)
volumeSlider.BackgroundTransparency = 1
volumeSlider.Active = true
volumeSlider.LayoutOrder = 2
volumeSlider.Parent = frame2

local track2 = Instance.new("Frame")
track2.Name = "Track"
track2.AnchorPoint = Vector2.new(0, 0.5)
track2.Position = UDim2.new(0, 9, 0.5, 0)
track2.Size = UDim2.new(1, -18, 0, 6)
track2.BackgroundColor3 = Amp.KNOB_DISABLED
track2.BorderSizePixel = 0
track2.Parent = volumeSlider

local uiCorner6 = Instance.new("UICorner")
uiCorner6.CornerRadius = UDim.new(1, 0)
uiCorner6.Parent = track2

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Amp.ACCENT
fill.BorderSizePixel = 0
fill.Parent = track2

local uiCorner7 = Instance.new("UICorner")
uiCorner7.CornerRadius = UDim.new(1, 0)
uiCorner7.Parent = fill

local thumb = Instance.new("Frame")
thumb.Name = "Thumb"
thumb.AnchorPoint = Vector2.new(0.5, 0.5)
thumb.Position = UDim2.new(0, 0, 0.5, 0)
thumb.Size = UDim2.new(0, 18, 0, 18)
thumb.BackgroundColor3 = Amp.TEXT
thumb.BorderSizePixel = 0
thumb.ZIndex = 2
thumb.Parent = track2

local uiCorner8 = Instance.new("UICorner")
uiCorner8.CornerRadius = UDim.new(1, 0)
uiCorner8.Parent = thumb

local function refreshVolumeSlider(p) -- 1 equivalent call inferred from this helper
	local v11 = math.clamp(p / 100, 0, 1)
	fill.Size = UDim2.new(v11, 0, 1, 0)
	thumb.Position = UDim2.new(v11, 0, 0.5, 0)
end

local function fn() end

local v11 = false
local v12 = nil

local function percentFromX(x) -- 2 equivalent calls inferred from this helper
	local x2 = track2.AbsoluteSize.X

	if x2 <= 0 then
		return nil
	end

	return (math.clamp(math.round((x - track2.AbsolutePosition.X) / x2 * 100), 0, 100))
end

volumeSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v11 = true
		v12 = input
		local v13 = percentFromX(input.Position.X) -- inferred equivalent call

		if v13 then
			fn(v13)
		end

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				v11 = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not v11 then
		return
	end

	if input == v12 or input.UserInputType == Enum.UserInputType.MouseMovement then
		local v13 = percentFromX(input.Position.X) -- inferred equivalent call

		if v13 then
			fn(v13)
		end
	end
end)

local roundButton2 = createRoundButton("+", frame2, 3)

local section2 = createSection(panel, "AMPLIFIER", 1, UDim2.new(1, 0, 0, 0))

local frame3 = Instance.new("Frame")

local v13 = {
	ChipW = 62,
	BodyH = 68,
	BtnTop = 72,
	BtnH = v6 and 28 or 20,
	Step = 0.05
}

frame3.Size = UDim2.new(1, 0, 0, v13.BtnTop + v13.BtnH + 4)
frame3.BackgroundTransparency = 1
frame3.LayoutOrder = 1
frame3.Parent = section2

local uiListLayout4 = Instance.new("UIListLayout")
uiListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout4.FillDirection = Enum.FillDirection.Horizontal
uiListLayout4.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout4.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout4.Padding = UDim.new(0, 6)
uiListLayout4.Parent = frame3

local v14 = {}

local v15 = {}

local function clamp01(p) -- 5 equivalent calls inferred from this helper
	if p < 0 then
		return 0
	end

	return if p > 1 then 1 else p
end

local v16 = nil

local function isRemoteTarget(): boolean -- 7 equivalent calls inferred from this helper
	return v16 ~= nil and v16.IsRemote == true
end

local function fireAmpParameter(p, p2)
	if not isRemoteTarget() then -- inferred equivalent call
		AmpControlBridge.FireAmpParameterChanged(p, p2)

		return
	end

	local v17

	if p == "Master" then
		v17 = percentToRhythmScale(rigMasterToPercent(p2)) -- inferred equivalent call
	end

	AmpRemoteEdit:FireServer(v16.AmpPart, p, p2, v17)
end

local function sendVolumeScale(p) -- 3 equivalent calls inferred from this helper
	if isRemoteTarget() then -- inferred equivalent call
		return
	end

	SetAmpVolume:FireServer(p)
end

local ampNoticeUI = Instance.new("ScreenGui")
ampNoticeUI.Name = "AmpNoticeUI"
ampNoticeUI.ResetOnSpawn = false
ampNoticeUI.IgnoreGuiInset = true
ampNoticeUI.DisplayOrder = 80
ampNoticeUI.Parent = PlayerGui

local notice = Instance.new("TextLabel")
notice.Name = "Notice"
notice.AnchorPoint = Vector2.new(0.5, 0)
notice.Position = UDim2.new(0.5, 0, 0, 70)
notice.Size = UDim2.fromOffset(0, 0)
notice.AutomaticSize = Enum.AutomaticSize.XY
notice.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
notice.BackgroundTransparency = 0.15
notice.TextColor3 = Color3.fromRGB(240, 240, 240)
notice.Font = Enum.Font.GothamMedium
notice.TextSize = 15
notice.Visible = false
notice.Parent = ampNoticeUI

local uiPadding2 = Instance.new("UIPadding")
uiPadding2.PaddingTop = UDim.new(0, 8)
uiPadding2.PaddingBottom = UDim.new(0, 8)
uiPadding2.PaddingLeft = UDim.new(0, 14)
uiPadding2.PaddingRight = UDim.new(0, 14)
uiPadding2.Parent = notice

local uiCorner9 = Instance.new("UICorner")
uiCorner9.CornerRadius = UDim.new(0, 8)
uiCorner9.Parent = notice

local count = 0
local function fn2(p)
	count += 1
	local v17 = count
	notice.Text = tostring(p)
	notice.Visible = true
	task.delay(3.5, function()
		if count == v17 then
			notice.Visible = false
		end
	end)
end

local function createAmpKnob(frame4, label, field, layoutOrder, max, options)
	local v17 = max or 1
	local v18 = options or {}

	local toActual = v18.ToActual or function(p)
		return p * v17
	end

	local fromActual = v18.FromActual or function(p)
		return p / v17
	end

	local function fireKnob(p) -- 3 equivalent calls inferred from this helper
		fireAmpParameter(field, toActual(p))

		if v18.OnChanged then
			v18.OnChanged(p)
		end
	end
	local frame5 = Instance.new("Frame")
	frame5.Name = field .. "Chip"
	frame5.Size = UDim2.new(0, v13.ChipW, 1, 0)
	frame5.BackgroundColor3 = Amp.KNOB_DISABLED
	frame5.BackgroundTransparency = 0.12
	frame5.BorderSizePixel = 0
	frame5.LayoutOrder = layoutOrder
	frame5.Parent = frame4

	local uiCorner10 = Instance.new("UICorner")
	uiCorner10.CornerRadius = UDim.new(0, 8)
	uiCorner10.Parent = frame5

	local percentBox = Instance.new("TextBox")
	percentBox.Name = "PercentBox"
	percentBox.AnchorPoint = Vector2.new(0.5, 0)
	percentBox.Position = UDim2.new(0.5, 0, 0, 2)
	percentBox.Size = UDim2.new(1, -4, 0, 14)
	percentBox.BackgroundTransparency = 1
	percentBox.Font = GothamBold
	percentBox.TextSize = 10
	percentBox.TextColor3 = Amp.ACCENT
	percentBox.Text = "50%"
	percentBox.ClearTextOnFocus = false
	percentBox.PlaceholderText = ""
	percentBox.Parent = frame5

	local frame6 = Instance.new("Frame")
	frame6.Name = "KnobDial"
	frame6.AnchorPoint = Vector2.new(0.5, 0)
	frame6.Position = UDim2.new(0.5, 0, 0, 22)
	frame6.Size = UDim2.new(0, 24, 0, 24)
	frame6.BackgroundColor3 = Amp.BG_CARD
	frame6.BorderSizePixel = 0
	frame6.Parent = frame5
	local uiCorner11 = Instance.new("UICorner")
	uiCorner11.CornerRadius = UDim.new(1, 0)
	uiCorner11.Parent = frame6

	local needle = Instance.new("Frame")
	needle.Name = "Needle"
	needle.AnchorPoint = Vector2.new(0.5, 1)
	needle.Position = UDim2.new(0.5, 0, 0.5, 0)
	needle.Size = UDim2.new(0, 2, 0, 10)
	needle.BackgroundColor3 = Amp.ACCENT
	needle.BorderSizePixel = 0
	needle.Parent = frame6
	local uiCorner12 = Instance.new("UICorner")
	uiCorner12.CornerRadius = UDim.new(1, 0)
	uiCorner12.Parent = needle

	local textLabel4 = Instance.new("TextLabel")
	textLabel4.AnchorPoint = Vector2.new(0.5, 1)
	textLabel4.Position = UDim2.new(0.5, 0, 0, v13.BodyH - 4)
	textLabel4.Size = UDim2.new(1, -4, 0, 12)
	textLabel4.BackgroundTransparency = 1
	textLabel4.Font = Gotham
	textLabel4.TextSize = 8
	textLabel4.TextColor3 = Amp.TEXT_MUTED
	textLabel4.Text = label
	textLabel4.Parent = frame5

	local v19 = 0.5
	local v20 = false
	local connections = {}
	local v21 = false

	local function applyVisual(p) -- 5 equivalent calls inferred from this helper
		v19 = p
		needle.Rotation = -135 + 270 * p

		if not v21 then
			percentBox.Text = string.format("%d%%", (math.round(p * 100)))
		end
	end

	local function disconnectDrag()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		connections = {}
	end

	local function beginDrag(input)
		v20 = true
		local y = input.Position.Y
		local v22 = v19

		disconnectDrag()

		table.insert(connections, UserInputService.InputChanged:Connect(function(input2)
			if
				not v20
				or input2.UserInputType ~= Enum.UserInputType.MouseMovement
				and input2.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			local v23 = clamp01(v22 + (y - input2.Position.Y) / 160) -- inferred equivalent call
			applyVisual(v23) -- inferred equivalent call
			fireKnob(v23) -- inferred equivalent call
		end))

		table.insert(connections, UserInputService.InputEnded:Connect(function(input2)
			if
				input2.UserInputType == Enum.UserInputType.MouseButton1
				or input2.UserInputType == Enum.UserInputType.Touch
			then
				v20 = false
				disconnectDrag()
			end
		end))
	end

	if v6 then
		frame6 = Instance.new("Frame")
		frame6.Name = "KnobHitArea"
		frame6.AnchorPoint = Vector2.new(0.5, 0)
		frame6.Position = UDim2.new(0.5, 0, 0, 16)
		frame6.Size = UDim2.new(1, 0, 0, 36)
		frame6.BackgroundTransparency = 1
		frame6.ZIndex = 2
		frame6.Parent = frame5
	end

	frame6.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			beginDrag(input)
		end
	end)

	percentBox.Focused:Connect(function()
		v21 = true
		percentBox.Text = tostring((math.round(v19 * 100)))
	end)

	percentBox.FocusLost:Connect(function()
		v21 = false
		local v22 = tonumber((percentBox.Text:gsub("[^%-%d%.]", "")))
		local v23

		if v22 then
			v23 = clamp01(v22 / 100) or v19 -- inferred equivalent call
		else
			v23 = v19
		end

		applyVisual(v23) -- inferred equivalent call
		fireKnob(v23) -- inferred equivalent call
	end)

	local function stepValue(p) -- 1 equivalent call inferred from this helper
		local v22 = clamp01(math.round((v19 + p * v13.Step) * 100) / 100) -- inferred equivalent call
		applyVisual(v22) -- inferred equivalent call
		fireKnob(v22) -- inferred equivalent call
	end

	local function makeStepButton(text, p, position3)
		local textButton = Instance.new("TextButton")
		textButton.Name = p < 0 and "StepMinus" or "StepPlus"
		textButton.Position = position3
		textButton.Size = UDim2.new(0.5, -4, 0, v13.BtnH)
		textButton.Text = text
		textButton.Font = GothamBold
		textButton.TextSize = v6 and 18 or 14
		textButton.AutoButtonColor = false
		textButton.BackgroundColor3 = Amp.BG_CARD
		textButton.BackgroundTransparency = 0.1
		textButton.TextColor3 = Amp.TEXT
		textButton.Parent = frame5

		local uiCorner13 = Instance.new("UICorner")
		uiCorner13.CornerRadius = UDim.new(0, 5)
		uiCorner13.Parent = textButton

		textButton.MouseEnter:Connect(function()
			textButton.TextColor3 = Amp.ACCENT
		end)
		textButton.MouseLeave:Connect(function()
			textButton.TextColor3 = Amp.TEXT
		end)
		textButton.Activated:Connect(function()
			stepValue(p) -- inferred equivalent call
		end)
	end

	makeStepButton("-", -1, UDim2.new(0, 3, 0, v13.BtnTop))
	makeStepButton("+", 1, UDim2.new(0.5, 1, 0, v13.BtnTop))
	applyVisual(v19) -- inferred equivalent call

	v15[field] = function()
		return toActual(v19)
	end

	v14[field] = function(p)
		local v22 = clamp01(fromActual(p)) -- inferred equivalent call
		applyVisual(v22) -- inferred equivalent call

		if v18.OnSet then
			v18.OnSet(v22)
		end
	end
end

for i, v17 in ipairs(v8) do
	local v18

	if v17.Field == "Master" then
		v18 = { ToActual = 0, FromActual = 0, OnChanged = 0, OnSet = 0 }
		function v18.ToActual(p)
			return percentToRigMaster(p * 100) -- inferred equivalent call
		end

		function v18.FromActual(p)
			return rigMasterToPercent(p) / 100 -- inferred equivalent call
		end

		function v18.OnChanged(p)
			v2.OnKnobChanged(p)
		end
		function v18.OnSet(p)
			v2.OnKnobSet(p)
		end
	end

	createAmpKnob(frame3, v17.Label, v17.Field, i, v17.Max, v18)
end

local frame4 = Instance.new("Frame")
frame4.Size = UDim2.new(1, 0, 0, v6 and 30 or 22)
frame4.BackgroundTransparency = 1
frame4.LayoutOrder = 2
frame4.Parent = section2

local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.AnchorPoint = Vector2.new(1, 0)
resetButton.Position = UDim2.new(1, 0, 0, 0)
resetButton.Size = v6 and UDim2.new(0, 150, 0, 30) or UDim2.new(0, 130, 0, 22)
resetButton.Text = "RESET TO DEFAULT"
resetButton.Font = GothamBold
resetButton.TextSize = 9
resetButton.AutoButtonColor = false
resetButton.BackgroundColor3 = Amp.KNOB_DISABLED
resetButton.BackgroundTransparency = 0.12
resetButton.TextColor3 = Amp.TEXT_MUTED
resetButton.Parent = frame4

local uiCorner10 = Instance.new("UICorner")
uiCorner10.CornerRadius = UDim.new(0, 6)
uiCorner10.Parent = resetButton

resetButton.MouseEnter:Connect(function()
	TweenService:Create(resetButton, TweenInfo.new(0.1), { TextColor3 = Amp.ACCENT }):Play()
end)
resetButton.MouseLeave:Connect(function()
	TweenService:Create(resetButton, TweenInfo.new(0.1), { TextColor3 = Amp.TEXT_MUTED }):Play()
end)

resetButton.Activated:Connect(function()
	for _, v17 in ipairs(v8) do
		local v18 = v14[v17.Field]

		if v18 then
			v18(v17.Default)
		end

		fireAmpParameter(v17.Field, v17.Default)
	end

	sendVolumeScale(percentToRhythmScale(v4)) -- inferred equivalent call
end)

local AmpPresetRequest = RemoteEvents:WaitForChild("AmpPresetRequest")

local v17 = { "Gain", "Bass", "Middle", "Treble", "Presence" }
local v18 = v6 and 112 or 100
local v19 = v6 and 30 or 22
local v20 = v6 and 150 or 130
local v21 = v6 and 34 or 26
local v22 = {}
local flag2 = false
local v23 = nil
local count2 = 0
local flag3 = false
local v24 = nil

local function presetDisplayName(p) -- 6 equivalent calls inferred from this helper
	local v25 = v22[p]

	if v25 and type(v25.Name) == "string" and v25.Name ~= "" then
		return v25.Name
	end

	return "Preset " .. p
end

local function invokePreset(p, p2, p3)
	local success, result = pcall(function()
		return AmpPresetRequest:InvokeServer(p, p2, p3)
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return { Ok = false, Reason = "Presets are unavailable right now." }
end

local function styleSmallButton(parent, text, frame5)
	parent.Text = text
	parent.Font = GothamBold
	parent.TextSize = 9
	parent.AutoButtonColor = false
	parent.BackgroundColor3 = Amp.KNOB_DISABLED
	parent.BackgroundTransparency = 0.12
	parent.TextColor3 = Amp.TEXT_MUTED
	parent.Parent = frame5
	local uiCorner11 = Instance.new("UICorner")
	uiCorner11.CornerRadius = UDim.new(0, 6)
	uiCorner11.Parent = parent
	parent.MouseEnter:Connect(function()
		TweenService:Create(parent, TweenInfo.new(0.1), { TextColor3 = Amp.ACCENT }):Play()
	end)
	parent.MouseLeave:Connect(function()
		TweenService:Create(parent, TweenInfo.new(0.1), { TextColor3 = Amp.TEXT_MUTED }):Play()
	end)
end

local function makeRowButton(text, p)
	local textButton = Instance.new("TextButton")
	textButton.AnchorPoint = Vector2.new(1, 0)
	textButton.Position = UDim2.new(1, -p, 0, 0)
	textButton.Size = UDim2.new(0, v18, 0, v19)
	styleSmallButton(textButton, text, frame4)
	return textButton
end

local loadPresetButton = makeRowButton("LOAD PRESET", v20 + 6)
loadPresetButton.Name = "LoadPresetButton"
local savePresetButton = makeRowButton("SAVE PRESET", v20 + 12 + v18)
savePresetButton.Name = "SavePresetButton"

local presetMenu = Instance.new("Frame")
presetMenu.Name = "PresetMenu"
presetMenu.AnchorPoint = Vector2.new(1, 1)
presetMenu.Position = UDim2.new(1, 0, 0, -6)
presetMenu.Size = UDim2.new(0, v6 and 300 or 260, 0, 0)
presetMenu.AutomaticSize = Enum.AutomaticSize.Y
presetMenu.BackgroundColor3 = Amp.BG_PANEL
presetMenu.BackgroundTransparency = 0.04
presetMenu.BorderSizePixel = 0
presetMenu.Active = true
presetMenu.Visible = false
presetMenu.ZIndex = 20
presetMenu.Parent = frame4

local uiCorner11 = Instance.new("UICorner")
uiCorner11.CornerRadius = UDim.new(0, 8)
uiCorner11.Parent = presetMenu
local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Color = Amp.BORDER
uiStroke2.Thickness = 1
uiStroke2.Parent = presetMenu
local uiPadding3 = Instance.new("UIPadding")
uiPadding3.PaddingTop = UDim.new(0, 8)
uiPadding3.PaddingBottom = UDim.new(0, 8)
uiPadding3.PaddingLeft = UDim.new(0, 8)
uiPadding3.PaddingRight = UDim.new(0, 8)
uiPadding3.Parent = presetMenu

local function makePage(layoutOrder)
	local frame5 = Instance.new("Frame")
	frame5.Size = UDim2.new(1, 0, 0, 0)
	frame5.AutomaticSize = Enum.AutomaticSize.Y
	frame5.BackgroundTransparency = 1
	frame5.LayoutOrder = layoutOrder
	frame5.Parent = presetMenu
	local uiListLayout5 = Instance.new("UIListLayout")
	uiListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout5.Padding = UDim.new(0, 4)
	uiListLayout5.Parent = frame5
	return frame5
end

local page = makePage(1)
local page2 = makePage(2)
page2.Visible = false

local function makeMenuLabel(page3, layoutOrder, textSize, p) -- 2 equivalent calls inferred from this helper
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.Size = UDim2.new(1, 0, 0, p)
	textLabel4.BackgroundTransparency = 1
	textLabel4.Font = GothamBold
	textLabel4.TextSize = textSize
	textLabel4.TextXAlignment = Enum.TextXAlignment.Left
	textLabel4.TextColor3 = Amp.TEXT_MUTED
	textLabel4.LayoutOrder = layoutOrder
	textLabel4.Parent = page3
	return textLabel4
end

local menuLabel = makeMenuLabel(page, 0, 10, 14) -- inferred equivalent call
local menuLabel2 = makeMenuLabel(page2, 0, 12, 22) -- inferred equivalent call
menuLabel2.TextColor3 = Amp.TEXT

local frame5 = Instance.new("Frame")
frame5.Size = UDim2.new(1, 0, 0, v21)
frame5.BackgroundTransparency = 1
frame5.LayoutOrder = 1
frame5.Parent = page2

local uiListLayout5 = Instance.new("UIListLayout")
uiListLayout5.FillDirection = Enum.FillDirection.Horizontal
uiListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout5.Padding = UDim.new(0, 6)
uiListLayout5.Parent = frame5

local textButton = Instance.new("TextButton")
textButton.Size = UDim2.new(0.5, -3, 1, 0)
textButton.LayoutOrder = 1
styleSmallButton(textButton, "OVERWRITE", frame5)
textButton.TextColor3 = Amp.ACCENT

local textButton2 = Instance.new("TextButton")
textButton2.Size = UDim2.new(0.5, -3, 1, 0)
textButton2.LayoutOrder = 2
styleSmallButton(textButton2, "CANCEL", frame5)

local v25 = {}

local function showListPage() -- 4 equivalent calls inferred from this helper
	v24 = nil
	page2.Visible = false
	page.Visible = true
end

local function renderPresetMenu()
	local v26 = v23 == "load"
	menuLabel.Text = v26 and "LOAD PRESET" or "SAVE TO PRESET"

	for i = 1, 3 do
		local v27 = v25[i]
		local v28 = v22[i]
		local v29 = flag2

		if v29 then
			if v28 == nil then
				v29 = false
			else
				v29 = v28.Empty == false
			end
		end

		local text

		if flag2 then
			if v29 then
				text = presetDisplayName(i) -- inferred equivalent call
			else
				text = "Preset " .. i .. " - Empty"
			end
		else
			text = "Loading..."
		end

		v27.Main.Text = text
		local active = flag2 and (not v26 or v29)
		v27.Main.Active = active
		v27.Main.TextColor3 = v29 and Amp.TEXT or Amp.TEXT_MUTED
		v27.Main.TextTransparency = active and 0 or 0.4
		v27.Rename.Visible = v29 and not v27.NameBox.Visible
		v27.Delete.Visible = v29 and not v27.NameBox.Visible
	end
end

local function closePresetMenu() -- 5 equivalent calls inferred from this helper
	count2 += 1
	v23 = nil
	presetMenu.Visible = false
	showListPage() -- inferred equivalent call

	for i = 1, 2 do
		local item = v25[i]

		if not item then
			continue
		end

		item.NameBox.Visible = false
		item.Main.Visible = true
	end

	local v26 = v25[3]

	if v26 then
		v26.NameBox.Visible = false
		v26.Main.Visible = true
	end
end

local function doSavePreset(p)
	if flag3 then
		return
	end

	flag3 = true
	local v26 = {}

	for _, v27 in ipairs(v17) do
		local v28 = v15[v27]

		if v28 then
			v26[v27] = v28()
		end
	end

	local v27 = invokePreset("Save", p, v26)
	flag3 = false

	if v27.Ok then
		v22 = v27.Slots or v22
		fn2(presetDisplayName(p) .. " saved") -- inferred equivalent call
		closePresetMenu() -- inferred equivalent call
	else
		fn2(v27.Reason or "Couldn't save preset.")

		if presetMenu.Visible then
			showListPage() -- inferred equivalent call
		end
	end
end

local function doLoadPreset(i)
	if flag3 then
		return
	end

	flag3 = true
	local v26 = v16
	local v27 = invokePreset("Get", i)
	flag3 = false

	if flag and v16 == v26 then
		if not v27.Ok or typeof(v27.Amp) ~= "table" then
			fn2(v27.Reason or "Couldn't load preset.")
			return
		end

		for _, v28 in ipairs(v17) do
			local v29 = v27.Amp[v28]

			if typeof(v29) ~= "number" then
				continue
			end

			local v30 = v14[v28]

			if v30 then
				v30(v29)
			end

			fireAmpParameter(v28, v29)
		end

		fn2(presetDisplayName(i) .. " loaded") -- inferred equivalent call
	end

	closePresetMenu() -- inferred equivalent call
end

local function doDeletePreset(slot)
	if flag3 then
		return
	end

	flag3 = true
	local v26 = presetDisplayName(slot) -- inferred equivalent call
	local v27 = invokePreset("Delete", slot)
	flag3 = false

	if v27.Ok then
		v22 = v27.Slots or v22
		fn2(v26 .. " deleted")
	else
		fn2(v27.Reason or "Couldn't delete preset.")
	end

	if presetMenu.Visible then
		showListPage() -- inferred equivalent call
		renderPresetMenu()
	end
end

local function showConfirm(kind, i) -- 2 equivalent calls inferred from this helper
	v24 = { Kind = kind, Slot = i }

	if kind == "delete" then
		menuLabel2.Text = "Delete " .. presetDisplayName(i) .. "?" -- inferred equivalent call
		textButton.Text = "DELETE"
	else
		menuLabel2.Text = "Overwrite " .. presetDisplayName(i) .. "?" -- inferred equivalent call
		textButton.Text = "OVERWRITE"
	end

	page.Visible = false
	page2.Visible = true
end

local function beginRename(i) -- 1 equivalent call inferred from this helper
	local v26 = v25[i]
	local v27 = v22[i]
	v26.Main.Visible = false
	v26.Rename.Visible = false
	v26.Delete.Visible = false
	v26.NameBox.Text = v27 and v27.Name or ""
	v26.NameBox.Visible = true
	v26.NameBox:CaptureFocus()
end

local function finishRename(i, p)
	local v26 = v25[i]
	local text = v26.NameBox.Text
	v26.NameBox.Visible = false
	v26.Main.Visible = true
	renderPresetMenu()

	local v27 = string.match(text, "^%s*(.-)%s*$") or ""

	if not p or v27 == "" or flag3 then
		return
	end

	flag3 = true
	local v28 = invokePreset("Rename", i, v27)
	flag3 = false

	if v28.Ok then
		v22 = v28.Slots or v22
		fn2("Preset renamed")
	else
		fn2(v28.Reason or "Couldn't rename preset.")
	end

	if presetMenu.Visible then
		renderPresetMenu()
	end
end

for i = 1, 3 do
	local frame6 = Instance.new("Frame")
	frame6.Name = "PresetRow" .. i
	frame6.Size = UDim2.new(1, 0, 0, v21)
	frame6.BackgroundTransparency = 1
	frame6.LayoutOrder = i
	frame6.Parent = page
	local v26 = v6 and 60 or 52
	local v27 = v6 and 56 or 48
	local main = Instance.new("TextButton")
	main.Name = "Main"
	main.Size = UDim2.new(1, -(v26 + v27 + 8), 1, 0)
	styleSmallButton(main, "", frame6)
	main.TextSize = v6 and 12 or 11
	main.TextXAlignment = Enum.TextXAlignment.Left
	main.TextTruncate = Enum.TextTruncate.AtEnd
	local uiPadding4 = Instance.new("UIPadding")
	uiPadding4.PaddingLeft = UDim.new(0, 8)
	uiPadding4.PaddingRight = UDim.new(0, 8)
	uiPadding4.Parent = main

	local rename = Instance.new("TextButton")
	rename.Name = "Rename"
	rename.AnchorPoint = Vector2.new(1, 0)
	rename.Position = UDim2.new(1, -(v27 + 4), 0, 0)
	rename.Size = UDim2.new(0, v26, 1, 0)
	styleSmallButton(rename, "RENAME", frame6)
	rename.Visible = false

	local delete = Instance.new("TextButton")
	delete.Name = "Delete"
	delete.AnchorPoint = Vector2.new(1, 0)
	delete.Position = UDim2.new(1, 0, 0, 0)
	delete.Size = UDim2.new(0, v27, 1, 0)
	styleSmallButton(delete, "DELETE", frame6)
	delete.Visible = false

	local nameBox = Instance.new("TextBox")
	nameBox.Name = "NameBox"
	nameBox.Size = UDim2.new(1, 0, 1, 0)
	nameBox.BackgroundColor3 = Amp.KNOB_DISABLED
	nameBox.BackgroundTransparency = 0.05
	nameBox.Font = GothamBold
	nameBox.TextSize = v6 and 12 or 11
	nameBox.TextColor3 = Amp.TEXT
	nameBox.PlaceholderText = "Preset name"
	nameBox.PlaceholderColor3 = Amp.TEXT_MUTED
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.ClearTextOnFocus = false
	nameBox.Visible = false
	nameBox.Parent = frame6

	local uiCorner12 = Instance.new("UICorner")
	uiCorner12.CornerRadius = UDim.new(0, 6)
	uiCorner12.Parent = nameBox
	local uiPadding5 = Instance.new("UIPadding")
	uiPadding5.PaddingLeft = UDim.new(0, 8)
	uiPadding5.PaddingRight = UDim.new(0, 8)
	uiPadding5.Parent = nameBox

	nameBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = nameBox.Text
		local v28 = utf8.len(text)

		if v28 and v28 > 20 then
			nameBox.Text = string.sub(text, 1, utf8.offset(text, 21) - 1)
		end
	end)

	v25[i] = {
		Row = frame6,
		Main = main,
		Rename = rename,
		Delete = delete,
		NameBox = nameBox
	}

	main.Activated:Connect(function()
		if flag3 or not flag2 then
			return
		end

		local v28 = v22[i]
		local v29

		if v28 == nil then
			v29 = false
		else
			v29 = v28.Empty == false
		end

		if v23 == "save" then
			if not v29 then
				doSavePreset(i)
				return
			end

			showConfirm("overwrite", i) -- inferred equivalent call
		elseif v23 == "load" and v29 then
			doLoadPreset(i)
		end
	end)

	rename.Activated:Connect(function()
		if flag3 then
			return
		end

		beginRename(i) -- inferred equivalent call
	end)

	delete.Activated:Connect(function()
		if flag3 then
			return
		end

		showConfirm("delete", i) -- inferred equivalent call
	end)

	nameBox.FocusLost:Connect(function(p)
		finishRename(i, p)
	end)
end

textButton.Activated:Connect(function()
	local v26 = v24

	if not v26 then
		return
	end

	if v26.Kind == "delete" then
		doDeletePreset(v26.Slot)
	else
		doSavePreset(v26.Slot)
	end
end)

textButton2.Activated:Connect(showListPage)

for _, guiObject in ipairs(presetMenu:GetDescendants()) do
	if guiObject:IsA("GuiObject") then
		guiObject.ZIndex = 21
	end
end

local function openPresetMenu(p)
	if presetMenu.Visible and v23 == p then
		closePresetMenu() -- inferred equivalent call
	else
		v23 = p
		count2 += 1
		local v26 = count2
		showListPage() -- inferred equivalent call
		flag2 = false
		presetMenu.Visible = true
		renderPresetMenu()

		task.spawn(function()
			local v27 = invokePreset("List")

			if v26 ~= count2 or not presetMenu.Visible then
				return
			end

			if v27.Ok then
				v22 = v27.Slots or {}
				flag2 = true
				renderPresetMenu()
			else
				fn2(v27.Reason or "Presets are unavailable right now.")
				closePresetMenu() -- inferred equivalent call
			end
		end)
	end
end

savePresetButton.Activated:Connect(function()
	openPresetMenu("save")
end)

loadPresetButton.Activated:Connect(function()
	openPresetMenu("load")
end)

local function syncAmpKnobsFromRig()
	local remoteTarget = isRemoteTarget() -- inferred equivalent call
	local v26

	if remoteTarget then
		v26 = v16.Amp
	else
		v26 = AmpControlBridge.GetCurrentAmp and AmpControlBridge.GetCurrentAmp()
	end

	if not v26 then
		return
	end

	for _, v27 in ipairs(v8) do
		local v28 = v26[v27.Field]

		if type(v28) == "number" and v14[v27.Field] then
			v14[v27.Field](clamp01(v28)) -- inferred equivalent call
		end
	end
end

if v6 then
	local mobileColumns = Instance.new("Frame")
	mobileColumns.Name = "MobileColumns"
	mobileColumns.Size = UDim2.new(1, 0, 0, 0)
	mobileColumns.AutomaticSize = Enum.AutomaticSize.Y
	mobileColumns.BackgroundTransparency = 1
	mobileColumns.LayoutOrder = 1
	mobileColumns.Parent = panel

	local uiListLayout6 = Instance.new("UIListLayout")
	uiListLayout6.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout6.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout6.VerticalAlignment = Enum.VerticalAlignment.Top
	uiListLayout6.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout6.Padding = UDim.new(0, 12)
	uiListLayout6.Parent = mobileColumns

	local function makeColumn(layoutOrder, p)
		local frame6 = Instance.new("Frame")
		frame6.Name = "Column" .. layoutOrder
		frame6.Size = UDim2.new(0, p, 0, 0)
		frame6.AutomaticSize = Enum.AutomaticSize.Y
		frame6.BackgroundTransparency = 1
		frame6.LayoutOrder = layoutOrder
		frame6.Parent = mobileColumns

		local uiListLayout7 = Instance.new("UIListLayout")
		uiListLayout7.FillDirection = Enum.FillDirection.Vertical
		uiListLayout7.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiListLayout7.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout7.Padding = UDim.new(0, 14)
		uiListLayout7.Parent = frame6
		return frame6
	end

	local column = makeColumn(1, 430)
	local column2 = makeColumn(2, 262)

	section2.Parent = column
	topRow.Parent = column2
end

local function updateVolumeLabel() -- 4 equivalent calls inferred from this helper
	textLabel3.Text = v4 .. "%"
	refreshVolumeSlider(v4) -- inferred equivalent call
end

local function applyMasterPercent(p)
	v4 = math.clamp(math.round(p), 0, 100)
	updateVolumeLabel() -- inferred equivalent call
	local master = v14.Master

	if master then
		master(percentToRigMaster(v4)) -- inferred equivalent call
	end

	local v26 = percentToRigMaster(v4) -- inferred equivalent call

	if isRemoteTarget() then -- inferred equivalent call
		local v27 = percentToRhythmScale(rigMasterToPercent(v26)) -- inferred equivalent call
		AmpRemoteEdit:FireServer(v16.AmpPart, "Master", v26, v27)
	else
		AmpControlBridge.FireAmpParameterChanged("Master", v26)
	end

	sendVolumeScale(percentToRhythmScale(v4)) -- inferred equivalent call
end

function v2.OnKnobChanged(p)
	v4 = math.clamp(math.round(p * 100), 0, 100)
	updateVolumeLabel() -- inferred equivalent call
	sendVolumeScale(percentToRhythmScale(v4)) -- inferred equivalent call
end

fn = function(p)
	if p ~= v4 then
		applyMasterPercent(p)
	end
end

function v2.OnKnobSet(p)
	v4 = math.clamp(math.round(p * 100), 0, 100)
	updateVolumeLabel() -- inferred equivalent call
end

if v14.Master then
	v14.Master(0.7)
end

local function updateSwingButton()
	local v26 = v5

	if isRemoteTarget() then -- inferred equivalent call
		v26 = v16.SwingEnabled ~= false
	end

	local v27 = v26 and udim2.X.Offset - udim3.X.Offset - 2 or 2

	TweenService:Create(track, TweenInfo.new(0.15), {
		BackgroundColor3 = v26 and Amp.SWING_ON or Amp.SWING_OFF
	}):Play()
	TweenService:Create(frame, TweenInfo.new(0.15), { Position = UDim2.new(0, v27, 0.5, 0) }):Play()
end

local function refreshLockButton()
	local v26 = v16
	local v27

	if v26 == nil then
		v27 = false
	else
		v27 = v26.AmpPart:GetAttribute("AmpLocked") == true
	end

	lockButton.Text = v27 and "LOCKED" or "LOCK"
	lockButton.BackgroundColor3 = v27 and Amp.ACCENT or Amp.BG_CARD
	lockButton.BackgroundTransparency = v27 and 0 or 0.12
	lockButton.TextColor3 = v27 and Color3.fromRGB(20, 20, 20) or Amp.TEXT_MUTED
	caption.Text = v27 and "Others can't access" or "Others can access"
	caption.TextColor3 = v27 and Amp.ACCENT or Amp.TEXT_MUTED
end

local function applyTargetToUI()
	local v26 = v16

	if v26 and v26.TypeLabel then
		title.Text = "AMP SETTINGS - " .. string.upper(v26.TypeLabel)
	else
		title.Text = "AMP SETTINGS"
	end

	if v26 then
		if v26.OwnerUsername then
			ownerLabel.Text = "@" .. v26.OwnerUsername .. (v26.IsOwner and " (you)" or "")

			ownerLabel.TextColor3 = v26.IsOwner and Amp.NAME_SELF or Amp.NAME_OTHER
		else
			ownerLabel.Text = "No owner"
			ownerLabel.TextColor3 = Amp.TEXT_MUTED
		end

		ownerLabel.Visible = true
	else
		ownerLabel.Visible = false
	end

	lockButton.Visible = v26 ~= nil and v26.CanLock == true
	refreshLockButton()
	local v27 = not isRemoteTarget() -- inferred equivalent call

	textLabel2.TextTransparency = v27 and 0 or 0.5
	track.BackgroundTransparency = v27 and 0 or 0.5
	frame.BackgroundTransparency = v27 and 0 or 0.4
	caption2.TextTransparency = v27 and 0.15 or 0.6
	updateSwingButton()
end

local function closePanel()
	closePresetMenu() -- inferred equivalent call
	local v26 = v16
	v16 = nil
	flag = false
	ampSettingsUI.Enabled = false

	if ampSettingsUI:GetAttribute("ScrollLocked") then
		ampSettingsUI:SetAttribute("ScrollLocked", false)
		pcall(function()
			local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
			SessionCameraSettings.SetScrollBlocked(false)
		end)
	end

	applyTargetToUI()

	if v26 then
		AmpAccessRelease:FireServer(v26.AmpPart)
	end

	if v6 then
		PlayerGui:SetAttribute("AmpPanelOpen", false)
		refreshMobilePrompt() -- inferred equivalent call
	end
end

local function openPanel()
	flag = true
	panel.Position = udim
	applyTargetToUI()
	updateVolumeLabel() -- inferred equivalent call
	updateSwingButton()
	syncAmpKnobsFromRig()
	ampSettingsUI.Enabled = true

	if not ampSettingsUI:GetAttribute("ScrollLocked") then
		ampSettingsUI:SetAttribute("ScrollLocked", true)
		pcall(function()
			local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
			SessionCameraSettings.SetScrollBlocked(true)
		end)
	end

	if v6 then
		PlayerGui:SetAttribute("AmpPanelOpen", true)
		refreshMobilePrompt() -- inferred equivalent call
	end
end

local function resetLocalSettings() -- 1 equivalent call inferred from this helper
	v4 = 30
	v5 = true
end

local v26 = false

local function requestOpenPanel()
	if flag or v26 or not adornee then
		return
	end

	local ampPart = adornee
	v26 = true
	local success, result = pcall(function()
		return AmpAccessRequest:InvokeServer(ampPart)
	end)

	v26 = false

	if flag then
		return
	end

	if success and typeof(result) == "table" then
		if not result.Ok then
			fn2(result.Reason or "Can't open Amp Settings.")
			return
		end

		if adornee ~= ampPart then
			AmpAccessRelease:FireServer(ampPart)
			return
		end

		v16 = {
			AmpPart = ampPart,
			IsRemote = not result.IsOwner,
			IsOwner = result.IsOwner,
			TypeLabel = result.TypeLabel,
			OwnerUsername = result.OwnerUsername,
			CanLock = result.CanLock,
			SwingEnabled = result.SwingEnabled,
			Amp = result.Amp
		}

		openPanel()
	else
		local ampOwnerUserId = ampPart:GetAttribute("AmpOwnerUserId")

		if ampOwnerUserId ~= LocalPlayer.UserId and ampOwnerUserId ~= nil then
			fn2("Amp access is unavailable right now.")

			return
		end

		v16 = nil
		openPanel()
	end
end

roundButton.MouseButton1Click:Connect(function()
	applyMasterPercent(v4 - 5)
end)

roundButton2.MouseButton1Click:Connect(function()
	applyMasterPercent(v4 + 5)
end)

swingToggle.MouseButton1Click:Connect(function()
	if isRemoteTarget() then -- inferred equivalent call
		fn2("Only the amp owner can change Swing.")
		return
	end

	v5 = not v5
	updateSwingButton()
	SetAmpSwing:FireServer(v5)
end)

closeButton.MouseButton1Click:Connect(closePanel)

lockButton.Activated:Connect(function()
	if v16 and v16.CanLock then
		local ampLocked = v16.AmpPart:GetAttribute("AmpLocked") == true
		AmpAccessLockSet:FireServer(v16.AmpPart, not ampLocked)
	end
end)

local function hasAmpAccessRole(): boolean -- 1 equivalent call inferred from this helper
	local equippedInstrumentType = LocalPlayer:GetAttribute("EquippedInstrumentType")

	if
		equippedInstrumentType == "Drum"
		or equippedInstrumentType == "Piano"
		or equippedInstrumentType == "Keyboard"
	then
		return false
	end

	return LocalPlayer:GetAttribute("AmpAccessRole") == true or v3 ~= nil and v[v3] == true
end

local function findNearbyAmp(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local v27 = 6
	local v28 = nil

	for _, v29 in ipairs(CollectionService:GetTagged("InstrumentStand")) do
		if not v[v29:GetAttribute("InstrumentType")] then
			continue
		end

		local soundAnchor = v29:FindFirstChild("SoundAnchor")
		local value = soundAnchor and soundAnchor.Value

		if not (value and value:IsA("BasePart")) then
			continue
		end

		local magnitude = (humanoidRootPart.Position - value.Position).Magnitude

		if not (magnitude <= v27) then
			continue
		end

		v28 = value
		v27 = magnitude
	end

	return v28
end

local function computePromptText(instance, _)
	local ampEditorUserId = instance:GetAttribute("AmpEditorUserId")

	if ampEditorUserId and ampEditorUserId ~= LocalPlayer.UserId then
		return "Amp Settings\nIn use: " .. tostring(instance:GetAttribute("AmpEditorName") or "?")
	end

	if instance:GetAttribute("AmpLocked") == true and instance:GetAttribute("AmpOwnerUserId") ~= LocalPlayer.UserId then
		return "Amp Settings\nLocked"
	end

	return "Amp Settings\n" .. (v6 and "Tap" or "Click")
end

local v27 = nil

RunService.Heartbeat:Connect(function()
	if hasAmpAccessRole() then -- inferred equivalent call
		local character = LocalPlayer.Character

		if not character then
			return
		end

		local nearbyAmp = findNearbyAmp(character)

		if nearbyAmp ~= adornee then
			adornee = nearbyAmp
			v27 = nil

			if nearbyAmp then
				ampSettingsPrompt.Parent = nearbyAmp
			end

			ampSettingsPrompt.Enabled = false

			if flag and (not nearbyAmp or v16 and v16.AmpPart ~= nearbyAmp) then
				closePanel()
			end

			refreshMobilePrompt() -- inferred equivalent call
		end

		if adornee then
			local text = computePromptText(adornee, false)
			local v28 = text .. "|" .. tostring(adornee)

			if v28 ~= v27 then
				v27 = v28
				textLabel.Text = text

				if ampSettingsButton then
					ampSettingsButton.Text = computePromptText(adornee, true)
				end
			end
		end

		if flag then
			refreshLockButton()
		end
	else
		if adornee then
			adornee = nil
			ampSettingsPrompt.Enabled = false
			refreshMobilePrompt() -- inferred equivalent call
		end

		if flag then
			closePanel()
		end
	end
end)

if ampSettingsButton then
	ampSettingsButton.Activated:Connect(function()
		if adornee and not flag then
			requestOpenPanel()
		end
	end)
end

InstrumentHUDUpdate.OnClientEvent:Connect(function(p, p2)
	v3 = p and p2 or nil

	if not p then
		adornee = nil
		ampSettingsPrompt.Enabled = false
		closePanel()
		resetLocalSettings() -- inferred equivalent call
	end
end)

AmpAccessNotice.OnClientEvent:Connect(function(p)
	fn2(p)
end)

AmpAccessRevoked.OnClientEvent:Connect(function(p, p2)
	if flag and v16 and v16.AmpPart == p then
		v16 = nil
		closePanel()
	end

	if p2 then
		fn2(p2)
	end
end)

AmpRemoteApply.OnClientEvent:Connect(function(value, value2)
	if typeof(value) == "string" and typeof(value2) == "number" then
		AmpControlBridge.FireRemoteAmpParameter(value, value2)
	end
end)

AmpRemoteRestore.OnClientEvent:Connect(function()
	AmpControlBridge.FireRemoteAmpRestore()
end)

local success, result = pcall(function()
	local UISkin = require(ReplicatedStorage.Modules.SongListUI.UISkin)
	UISkin.AddRoot(ampSettingsUI)
end)

if not success then
	warn("[AmpSettingsUI] UISkin gagal: " .. tostring(result))
end