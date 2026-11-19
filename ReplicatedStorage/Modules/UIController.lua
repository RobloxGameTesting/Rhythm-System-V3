local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)

local color = Color3.fromRGB(46, 40, 36)
local color2 = Color3.fromRGB(255, 149, 51)
local color3 = Color3.fromRGB(240, 232, 222)
local color4 = Color3.fromRGB(150, 138, 128)
local color5 = Color3.fromRGB(255, 149, 51)

local GothamBold = Enum.Font.GothamBold

local v = {
	[ModeManager.Rhythm] = { Label = "RHYTHM", Tooltip = "Switch to Free Play" },
	[ModeManager.FreePlay] = { Label = "FREE PLAY", Tooltip = "Return to Rhythm" }
}

local udim = UDim2.new(0, 44, 0, 24)
local udim2 = UDim2.new(0, 18, 0, 18)

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

local freePlayControlsGui = nil
local switchModeButton = nil
local track = nil
local thumb = nil
local modeLabel = nil
local v2 = false

local function applyCorner(parent, cornerRadius) -- 2 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = cornerRadius
	uiCorner.Parent = parent
	return uiCorner
end

local function applyModeToButton(mode)
	if not switchModeButton then
		return
	end

	local v3 = v[mode]

	if not v3 then
		warn("[UIController] Tidak ada MODE_DISPLAY untuk mode:", (tostring(mode)))
		return
	end

	switchModeButton:SetAttribute("Mode", mode)

	local v4 = mode == ModeManager.FreePlay
	local v5 = v4 and udim.X.Offset - udim2.X.Offset - 3 or 3

	TweenService:Create(track, tweenInfo, {
		BackgroundColor3 = v4 and color2 or color
	}):Play()
	TweenService:Create(thumb, tweenInfo, { Position = UDim2.new(0, v5, 0.5, 0) }):Play()

	modeLabel.Text = v3.Label
	modeLabel.TextColor3 = v4 and color5 or color4
end

local function buildGui(parent)
	freePlayControlsGui = Instance.new("ScreenGui")
	freePlayControlsGui.Name = "FreePlayControlsGui"
	freePlayControlsGui.ResetOnSpawn = false
	freePlayControlsGui.IgnoreGuiInset = true
	freePlayControlsGui.Enabled = false

	local modeSwitchWrap = Instance.new("Frame")
	modeSwitchWrap.Name = "ModeSwitchWrap"
	modeSwitchWrap.AnchorPoint = Vector2.new(1, 0.5)
	modeSwitchWrap.Position = UDim2.new(1, -14, 0.5, 0)
	modeSwitchWrap.Size = UDim2.new(0, 60, 0, 44)
	modeSwitchWrap.BackgroundTransparency = 1
	modeSwitchWrap.Parent = freePlayControlsGui

	modeLabel = Instance.new("TextLabel")
	modeLabel.Name = "ModeLabel"
	modeLabel.AnchorPoint = Vector2.new(0.5, 0)
	modeLabel.Position = UDim2.new(0.5, 0, 0, 0)
	modeLabel.Size = UDim2.new(1, 0, 0, 14)
	modeLabel.BackgroundTransparency = 1
	modeLabel.Font = GothamBold
	modeLabel.TextSize = 10
	modeLabel.TextColor3 = color4
	modeLabel.Text = ""
	modeLabel.Parent = modeSwitchWrap

	switchModeButton = Instance.new("TextButton")
	switchModeButton.Name = "SwitchModeButton"
	switchModeButton.AnchorPoint = Vector2.new(0.5, 1)
	switchModeButton.Position = UDim2.new(0.5, 0, 1, 0)
	switchModeButton.Size = udim
	switchModeButton.BackgroundTransparency = 1
	switchModeButton.AutoButtonColor = false
	switchModeButton.Text = ""
	switchModeButton.Parent = modeSwitchWrap

	track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, 0, 1, 0)
	track.BackgroundColor3 = color
	track.BorderSizePixel = 0
	track.Parent = switchModeButton
	applyCorner(track, UDim.new(1, 0)) -- inferred equivalent call

	thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.AnchorPoint = Vector2.new(0, 0.5)
	thumb.Position = UDim2.new(0, 3, 0.5, 0)
	thumb.Size = udim2
	thumb.BackgroundColor3 = color3
	thumb.BorderSizePixel = 0
	thumb.Parent = track
	applyCorner(thumb, UDim.new(1, 0)) -- inferred equivalent call

	freePlayControlsGui.Parent = parent
	applyModeToButton(ModeManager.GetMode())

	switchModeButton.Activated:Connect(function()
		ModeManager.Toggle()
	end)

	if not v2 then
		v2 = true
		ModeManager.OnChanged(function(p)
			applyModeToButton(p)
		end)
	end
end

local UIController = {}

function UIController.Initialize(parent)
	if freePlayControlsGui then
		return
	end

	buildGui(parent)
end

function UIController.SetVisible(enabled)
	if not freePlayControlsGui then
		return
	end

	freePlayControlsGui.Enabled = enabled
end

function UIController.Destroy()
	if freePlayControlsGui then
		freePlayControlsGui:Destroy()
		freePlayControlsGui = nil
	end

	switchModeButton = nil
	track = nil
	thumb = nil
	modeLabel = nil
end

return UIController