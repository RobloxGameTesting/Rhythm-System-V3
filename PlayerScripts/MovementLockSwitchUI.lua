local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local MovementLockState = require(Modules:WaitForChild("MovementLockState"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local ThemeState = require(Modules:WaitForChild("ThemeState"))
local NoteLaneUI = require(Modules:WaitForChild("NoteLaneUI"))
local NoteLaneUI3D = require(Modules:WaitForChild("NoteLaneUI3D"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(15, 15, 14)
local color2 = Color3.fromRGB(34, 34, 32)
local color3 = Color3.fromRGB(64, 62, 58)
local color4 = Color3.fromRGB(86, 84, 80)
local color5 = Color3.fromRGB(222, 220, 214)
local color6 = Color3.fromRGB(104, 102, 98)
local color7 = Color3.fromRGB(204, 162, 72)

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and 1 or 15 / 14
local v2 = 140 * v
local v3 = 79 * v
local v4 = 16 * v

local v5 = 122 * v

local movementLockSwitchUI = Instance.new("ScreenGui")
movementLockSwitchUI.Name = "MovementLockSwitchUI"
movementLockSwitchUI.ResetOnSpawn = false
movementLockSwitchUI.IgnoreGuiInset = true
movementLockSwitchUI.DisplayOrder = 120
movementLockSwitchUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
movementLockSwitchUI.Parent = PlayerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundTransparency = 1
root.BorderSizePixel = 0
root.Size = UDim2.fromScale(1, 1)
root.Parent = movementLockSwitchUI

local plate = Instance.new("TextButton")
plate.Name = "Plate"
plate.AnchorPoint = Vector2.new(0.5, 0)
plate.Size = UDim2.fromOffset(150, 24)
plate.Position = UDim2.fromOffset(81, 6)
plate.BackgroundColor3 = color
plate.BackgroundTransparency = 0.08
plate.BorderSizePixel = 0
plate.AutoButtonColor = false
plate.Text = ""
plate.Visible = false
plate.Parent = root

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 3)
uiCorner.Parent = plate

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1
uiStroke.Color = color4
uiStroke.Transparency = 0.15
uiStroke.Parent = plate

local label = Instance.new("TextLabel")
label.Name = "Label"
label.BackgroundTransparency = 1
label.Position = UDim2.new(0, 8, 0, 0)
label.Size = UDim2.new(1, -54, 1, 0)
label.Font = Enum.Font.SpecialElite
label.TextSize = 11
label.TextXAlignment = Enum.TextXAlignment.Left
label.Text = "Keybind Lock"
label.TextColor3 = color5
label.Parent = plate

local track = Instance.new("Frame")
track.Name = "Track"
track.AnchorPoint = Vector2.new(1, 0.5)
track.Position = UDim2.new(1, -8, 0.5, 0)
track.Size = UDim2.fromOffset(34, 16)
track.BackgroundColor3 = color3
track.BorderSizePixel = 0
track.Parent = plate

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(1, 0)
uiCorner2.Parent = track

local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Thickness = 1
uiStroke2.Color = color4
uiStroke2.Transparency = 0.3
uiStroke2.Parent = track

local thumb = Instance.new("Frame")
thumb.Name = "Thumb"
thumb.Size = UDim2.fromOffset(12, 12)
thumb.Position = UDim2.new(0, 20, 0.5, -6)
thumb.BackgroundColor3 = color7
thumb.BorderSizePixel = 0
thumb.Parent = track

local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(1, 0)
uiCorner3.Parent = thumb

local function refreshVisual(p)
	local isEnabled = MovementLockState.IsEnabled()

	local tweenInfo = TweenInfo.new(p and 0.15 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(thumb, tweenInfo, {
		Position = UDim2.new(0, isEnabled and 20 or 2, 0.5, -6),
		BackgroundColor3 = isEnabled and color7 or color6
	}):Play()
	TweenService:Create(track, tweenInfo, {
		BackgroundColor3 = isEnabled and color3 or color
	}):Play()
	label.TextColor3 = isEnabled and color5 or color6
end

plate.Activated:Connect(function()
	MovementLockState.SetEnabled(not MovementLockState.IsEnabled())
end)
plate.MouseEnter:Connect(function()
	plate.BackgroundColor3 = color2
end)
plate.MouseLeave:Connect(function()
	plate.BackgroundColor3 = color
end)

MovementLockState.OnChanged(function()
	refreshVisual(true)
end)
refreshVisual(false)

local function findStarBar() -- 1 equivalent call inferred from this helper
	local starPowerUI = PlayerGui:FindFirstChild("StarPowerUI")
	local meterContainer = starPowerUI and starPowerUI:FindFirstChild("MeterContainer", true)

	if meterContainer and starPowerUI.Enabled and meterContainer.Visible and meterContainer.AbsoluteSize.X > 0 then
		return meterContainer
	end

	return nil
end

local function getVibratoPanelRect(p, p2)
	local rhythmVibratoHUD = PlayerGui:FindFirstChild("RhythmVibratoHUD")
	local rhythmVibratoHUDContainer = rhythmVibratoHUD and rhythmVibratoHUD:FindFirstChild("Container")

	if rhythmVibratoHUDContainer and rhythmVibratoHUDContainer.Visible then
		local panel = rhythmVibratoHUDContainer:FindFirstChild("Panel")

		if panel and panel.AbsoluteSize.X > 0 then
			return panel.AbsolutePosition, panel.AbsoluteSize
		end
	end

	local starBar = findStarBar() -- inferred equivalent call

	if starBar then
		local absolutePosition = starBar.AbsolutePosition
		local absoluteSize = starBar.AbsoluteSize
		local v6 = absolutePosition.X + absoluteSize.X + 22
		local noteLaneUI3D = PlayerGui:FindFirstChild("NoteLaneUI3D")

		if v6 + v2 > p.X + p2.X - 6 and not (noteLaneUI3D and noteLaneUI3D.Enabled) then
			v6 = absolutePosition.X - 22 - v2
		end

		local v7 = math.clamp(v6, p.X + 6, (math.max(p.X + 6, p.X + p2.X - v2 - 6)))

		local v8 = absolutePosition.Y + absoluteSize.Y / 2
		return Vector2.new(v7, v8 - v3 / 2), Vector2.new(v2, v3)
	else
		local v6 = p.X + p2.X - v2 - v4 - 14
		local v7 = p.Y + p2.Y / 2
		return Vector2.new(v6, v7 - v3 / 2), Vector2.new(v2, v3)
	end
end

local function getRockMeterRect(absolutePosition, absoluteSize)
	local rockMeterUI = PlayerGui:FindFirstChild("RockMeterUI")
	local rockMeterUIContainer = rockMeterUI and rockMeterUI:FindFirstChild("Container")

	if rockMeterUIContainer and rockMeterUIContainer.Visible then
		local plate2 = rockMeterUIContainer:FindFirstChild("Plate")

		if plate2 and plate2.AbsoluteSize.X > 0 then
			return plate2.AbsolutePosition, plate2.AbsoluteSize
		end
	end

	local vibratoPanelRect, v6 = getVibratoPanelRect(absolutePosition, absoluteSize)
	return Vector2.new(vibratoPanelRect.X, vibratoPanelRect.Y + v6.Y + 10), Vector2.new(v6.X, v5)
end

local function isNoteLaneVisible() -- 1 equivalent call inferred from this helper
	return (ThemeState.Get() == "3D" and NoteLaneUI3D or NoteLaneUI).IsVisible()
end

RunService.RenderStepped:Connect(function()
	local visible

	if
		MovementLockState.IsApplicable()
		and UserInputService.KeyboardEnabled
		and not (ModeManager.IsFreePlay() or SessionCameraSettings.GetIsMenuOpen())
		and isNoteLaneVisible() -- inferred equivalent call
	then
		local absolutePosition = root.AbsolutePosition
		local absoluteSize = root.AbsoluteSize
		local rockMeterRect, v6 = getRockMeterRect(absolutePosition, absoluteSize)

		local v7 = rockMeterRect.X + v6.X / 2 - absolutePosition.X
		local v8 = rockMeterRect.Y + v6.Y + 8 - absolutePosition.Y
		local v9 = math.clamp(v7, 81, (math.max(81, absoluteSize.X - 75 - 6)))
		local v10 = math.clamp(v8, 6, (math.max(6, absoluteSize.Y - 24 - 6)))
		plate.Position = UDim2.fromOffset(math.floor(v9 + 0.5), (math.floor(v10 + 0.5)))
		visible = true
	else
		visible = false
	end

	if plate.Visible ~= visible then
		plate.Visible = visible
	end
end)