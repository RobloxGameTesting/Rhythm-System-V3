local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OpenSongMenuRequest = script.Parent:WaitForChild("OpenSongMenuRequest")
local PutBackHoldStart = script.Parent:WaitForChild("PutBackHoldStart")
local PutBackHoldCancel = script.Parent:WaitForChild("PutBackHoldCancel")

local InputRouter = require(ReplicatedStorage.Modules.InputRouter)
local FreePlayController = require(ReplicatedStorage.Modules.FreePlayController)
local FreePlayProfileRegistry = require(ReplicatedStorage.Modules.FreePlayProfileRegistry)

local FreePlayKeyBindings = require(ReplicatedStorage.Modules.FreePlayKeyBindings)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)
local FreePlayAnimationAdapter = require(ReplicatedStorage.Modules.FreePlayAnimationAdapter)
local FreePlayReplicationAdapter = require(ReplicatedStorage.Modules.FreePlayReplicationAdapter)
local FreePlayAssetPreloader = require(ReplicatedStorage.Modules.FreePlayAssetPreloader)

local AudioRig = require(ReplicatedStorage.Modules.AudioRig)
local AmpControlBridge = require(ReplicatedStorage.Modules.AmpControlBridge)
local AudioEngine = require(ReplicatedStorage.Modules.AudioEngine)
local AmpSyncClient = require(ReplicatedStorage.Modules.AmpSyncClient)

local AudioRigStore = require(ReplicatedStorage.Modules.AudioRigStore)

local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)

require(ReplicatedStorage.Modules.GuitarLeadProfile)
require(ReplicatedStorage.Modules.GuitarRhythmProfile)
require(ReplicatedStorage.Modules.BassProfile)
require(ReplicatedStorage.Modules.KeyboardProfile)
require(ReplicatedStorage.Modules.DrumProfile)
require(ReplicatedStorage.Modules.PianoProfile)

require(ReplicatedStorage.Modules.NoiseGatePedalType)
require(ReplicatedStorage.Modules.CompressorPedalType)
require(ReplicatedStorage.Modules.OverdrivePedalType)
require(ReplicatedStorage.Modules.DistortionPedalType)
require(ReplicatedStorage.Modules.BassOverdrivePedalType)
require(ReplicatedStorage.Modules.ChorusPedalType)
require(ReplicatedStorage.Modules.DelayPedalType)
require(ReplicatedStorage.Modules.ReverbPedalType)

require(ReplicatedStorage.Modules.GuitarPedalboardDefinition)
require(ReplicatedStorage.Modules.BassPedalboardDefinition)

local color = Color3.fromRGB(18, 18, 20)
local color2 = Color3.fromRGB(235, 235, 238)
local color3 = Color3.fromRGB(150, 150, 155)

local instrumentHUD = Instance.new("ScreenGui")
instrumentHUD.Name = "InstrumentHUD"
instrumentHUD.ResetOnSpawn = false
instrumentHUD.Enabled = false
instrumentHUD.Parent = PlayerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(0.5, 1)
container.Position = UDim2.new(0.5, 0, 1, -24)
container.Size = UDim2.new(0, 220, 0, 62)
container.BackgroundColor3 = color
container.BackgroundTransparency = 0.15
container.Parent = instrumentHUD

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = container

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 2)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = container

local function createHintLabel(p, p2)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -12, 0, 16)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 12
	textLabel.RichText = true
	textLabel.Text = string.format(
		"<font color=\"rgb(%d,%d,%d)\">%s</font>  <font color=\"rgb(%d,%d,%d)\">%s</font>",
		color2.R * 255,
		color2.G * 255,
		color2.B * 255,
		p,
		color3.R * 255,
		color3.G * 255,
		color3.B * 255,
		p2
	)

	textLabel.Parent = container
	return textLabel
end

local hintLabel = createHintLabel("G", "Song List")
hintLabel.LayoutOrder = 1
local hintLabel2 = createHintLabel("R Shift", "Free Play")
hintLabel2.LayoutOrder = 2
local hintLabel3 = createHintLabel("Backspace", "Unequip")
hintLabel3.LayoutOrder = 3

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	hintLabel.Visible = false
	hintLabel3.Visible = false
	hintLabel2.Visible = false
	container.Visible = false

	local mobileButtons = Instance.new("Frame")
	mobileButtons.Name = "MobileButtons"
	mobileButtons.AnchorPoint = Vector2.new(1, 1)
	mobileButtons.Position = UDim2.new(1, -16, 1, -170)

	mobileButtons.Size = UDim2.new(0, 84, 0, 126)
	mobileButtons.BackgroundTransparency = 1
	mobileButtons.Parent = instrumentHUD

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Vertical
	uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Top
	uiListLayout2.Padding = UDim.new(0, 6)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder

	local topRow = Instance.new("Frame")
	topRow.Name = "TopRow"
	topRow.Position = UDim2.new(0, 0, 0, 0)
	topRow.Size = UDim2.new(1, 0, 1, 0)
	topRow.BackgroundTransparency = 1
	topRow.Parent = mobileButtons
	uiListLayout2.Parent = topRow

	local function createMobileButton(text, text2, color4, layoutOrder, p)
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.new(0, 84, 0, 38)
		textButton.LayoutOrder = layoutOrder
		textButton.BackgroundColor3 = color
		textButton.BackgroundTransparency = 0.25
		textButton.AutoButtonColor = false
		textButton.Text = ""
		textButton.Parent = p or topRow

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(0, 8)
		uiCorner2.Parent = textButton

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = color4
		uiStroke.Transparency = 0.4
		uiStroke.Thickness = 1
		uiStroke.Parent = textButton

		local mainLabel = Instance.new("TextLabel")
		mainLabel.Name = "MainLabel"
		mainLabel.Size = UDim2.new(1, 0, 0, 16)
		mainLabel.Position = UDim2.new(0, 0, 0, 4)
		mainLabel.BackgroundTransparency = 1
		mainLabel.TextColor3 = color4
		mainLabel.Font = Enum.Font.GothamBold
		mainLabel.TextSize = 11
		mainLabel.Text = text
		mainLabel.Parent = textButton

		local captionLabel = Instance.new("TextLabel")
		captionLabel.Name = "CaptionLabel"
		captionLabel.Size = UDim2.new(1, -6, 0, 14)
		captionLabel.Position = UDim2.new(0, 3, 0, 20)
		captionLabel.BackgroundTransparency = 1
		captionLabel.TextColor3 = color3
		captionLabel.Font = Enum.Font.Gotham
		captionLabel.TextSize = 8
		captionLabel.TextScaled = true
		captionLabel.Text = text2
		captionLabel.Parent = textButton

		local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MaxTextSize = 8
		uiTextSizeConstraint.Parent = captionLabel

		return textButton
	end

	local mobileButton = createMobileButton("Song List", "Browse", Color3.fromRGB(88, 210, 150), 1)
	local mobileButton2 = createMobileButton("Unequip", "Put it away", Color3.fromRGB(235, 90, 90), 2)

	local mobileButton3 = createMobileButton("Free Play", "Play freely", Color3.fromRGB(255, 149, 51), 3, topRow)
	local v = 0

	mobileButton3.Activated:Connect(function()
		local now = os.clock()

		if now - v < 0.25 then
			return
		end

		v = now

		if ModeManager.IsFreePlay() then
			return
		end

		ModeManager.SetFreePlay()
	end)

	local function refreshFreePlayButtonVisibility() -- 1 equivalent call inferred from this helper
		mobileButton3.Visible = not ModeManager.IsFreePlay()
	end
	ModeManager.OnChanged(refreshFreePlayButtonVisibility)
	refreshFreePlayButtonVisibility() -- inferred equivalent call
	mobileButton.MouseButton1Click:Connect(function()
		OpenSongMenuRequest:Fire()
	end)

	mobileButton2.MouseButton1Down:Connect(function()
		PutBackHoldStart:Fire()
	end)
	mobileButton2.MouseButton1Up:Connect(function()
		PutBackHoldCancel:Fire()
	end)
	mobileButton2.MouseLeave:Connect(function()
		PutBackHoldCancel:Fire()
	end)

	local function refreshMobileButtonsVisibility() -- 1 equivalent call inferred from this helper
		mobileButtons.Visible = not SessionCameraSettings.GetIsMenuOpen()
			and PlayerGui:GetAttribute("AmpPanelOpen") ~= true
	end
	SessionCameraSettings.OnChanged(refreshMobileButtonsVisibility)
	PlayerGui:GetAttributeChangedSignal("AmpPanelOpen"):Connect(refreshMobileButtonsVisibility)
	refreshMobileButtonsVisibility() -- inferred equivalent call
end

InputRouter.SetFreePlayHandlers({
	Press = FreePlayController.Press,
	Release = FreePlayController.Release,
	Mute = FreePlayController.MuteAll,
	Pedal = FreePlayController.SetPedal,
	PedalLockToggle = FreePlayController.TogglePedalLock
})

FreePlayController.SetProfileProvider(FreePlayProfileRegistry.Get)
FreePlayController.SetSoundAdapter(AudioEngine)
FreePlayController.SetAnimationAdapter(FreePlayAnimationAdapter)
FreePlayController.SetReplicationAdapter(FreePlayReplicationAdapter)

local v = nil
local flag = false

local v2 = nil

local function applyFreePlayBindingsIfActive() -- 1 equivalent call inferred from this helper
	if not (ModeManager.IsFreePlay() and v2) then
		return
	end

	local freePlayKeyBinding = FreePlayKeyBindings[v2]

	if freePlayKeyBinding then
		InputRouter.SetActiveBindings(freePlayKeyBinding)
	else
		warn("[InstrumentHUD] Tidak ada FreePlayKeyBindings untuk instrumen:", v2)
	end
end

local function preloadFreePlayAssetsIfActive() -- 1 equivalent call inferred from this helper
	if not (ModeManager.IsFreePlay() and v2) then
		return
	end

	FreePlayAssetPreloader.EnsureLoaded(v2, FreePlayController.GetCurrentTone(), "Loading Free Play assets...")
end

ModeManager.OnChanged(function(p)
	if p == ModeManager.FreePlay then
		applyFreePlayBindingsIfActive() -- inferred equivalent call
		preloadFreePlayAssetsIfActive() -- inferred equivalent call
	end
end)

function AmpControlBridge.GetCurrentAmp()
	return v and v.Amp
end

local v3 = nil

AmpControlBridge.OnAmpParameterChanged(function(p, p2)
	if v then
		AudioRig.SetAmpParameter(v, p, p2)

		if v3 and v3[p] ~= nil then
			v3[p] = p2
		end
	end
end)

local function restoreRemoteAmp()
	local v4 = v3
	v3 = nil

	if not (v4 and v and v.Amp) then
		return
	end

	for k, v5 in pairs(v4) do
		if v.Amp[k] ~= v5 then
			AudioRig.SetAmpParameter(v, k, v5)
		end
	end
end

AmpControlBridge.OnRemoteAmpParameter(function(p, p2)
	if not (v and v.Amp) then
		return
	end

	if not v3 then
		v3 = {}

		for k, v4 in pairs(v.Amp) do
			v3[k] = v4
		end
	end

	AudioRig.SetAmpParameter(v, p, p2)
end)

AmpControlBridge.OnRemoteAmpRestore(restoreRemoteAmp)

local function resetRigAmpToDefault(p)
	if not (p and p.Amp) then
		return
	end

	local amp = {}
	local flag2 = false

	for k, v4 in pairs(AudioRig.GetDefaultAmp()) do
		if p.Amp[k] == v4 then
			continue
		end

		amp[k] = v4
		flag2 = true
	end

	if flag2 then
		AudioRig.ApplyPreset(p, { Amp = amp })
	end
end

local function trySave() -- 2 equivalent calls inferred from this helper
	if not v or v3 or not v.Meta.Dirty or flag then
		return
	end

	local v4 = v
	local revision = v.Meta.Revision
	flag = true

	AudioRigStore.RequestSave(v4, function(p)
		flag = false

		if not (p and v == v4 and v.Meta.Revision == revision) then
			return
		end

		AudioRig.MarkSaved(v)
	end)
end

task.spawn(function()
	while true do
		task.wait(30)
		trySave() -- inferred equivalent call
	end
end)

local v4 = (not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled) and true or false

local v5 = false

local function updateHudVisibility() -- 1 equivalent call inferred from this helper
	if not v4 then
		return
	end

	container.Visible = v5 and not ModeManager.IsFreePlay()
end

ModeManager.OnChanged(updateHudVisibility)

local count = 0

instrumentHUDUpdate.OnClientEvent:Connect(function(enabled, instrument)
	count += 1

	instrumentHUD.Enabled = enabled

	v5 = enabled
	updateHudVisibility() -- inferred equivalent call

	if enabled then
		FreePlayController.SetInstrument(instrument)
		v2 = instrument

		local v6 = count

		AudioRigStore.RequestLoad(function(data)
			if v6 ~= count then
				return
			end

			local v7

			if type(data) == "table" and data.OwnerUserId == LocalPlayer.UserId and data.Instrument == instrument then
				v7 = type(data.Meta) == "table"
			else
				v7 = false
			end

			local v8

			if v7 then
				v8 = AudioRig.RepairLoadedSnapshot(data)
			else
				v8 = AudioRig.New({ OwnerUserId = LocalPlayer.UserId, Instrument = instrument })
			end

			resetRigAmpToDefault(v8)
			v = v8
			v3 = nil
			AudioEngine.SetRig(v8)
			AmpSyncClient.SetRig(v8)
		end)
	else
		restoreRemoteAmp()
		resetRigAmpToDefault(v)
		trySave() -- inferred equivalent call
		v = nil
		v2 = nil

		if ModeManager.IsFreePlay() then
			InputRouter.ClearActiveBindings()
		end

		FreePlayController.SetInstrument(nil)
		AudioEngine.SetRig(nil)
		AmpSyncClient.SetRig(nil)
	end
end)