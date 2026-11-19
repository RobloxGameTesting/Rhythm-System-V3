local v = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
game:GetService("ContextActionService")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
require(ReplicatedStorage.Modules.ThemeState)
local RhythmCustomizationConfig = require(ReplicatedStorage.Modules.RhythmCustomizationConfig)
local RhythmShapeGeometry = require(ReplicatedStorage.Modules.RhythmShapeGeometry)
local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
local LayoutEditorUI = require(script.Parent:WaitForChild("LayoutEditorUI"))
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)

local result = v.LocalPlayer:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
v = RemoteEvents:WaitForChild("InstrumentHUDUpdate")
local KeyModeUpdate = RemoteEvents:WaitForChild("KeyModeUpdate")
local v2 = nil
local v3 = 5

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local Settings = StyledTheme.Settings

local v4 = UDim.new(0, 10)
local udim = UDim.new(0, 8)

local v5 = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local v6 = {
	ButtonSizeMultiplier = v5 and 1.36 or 1,
	ButtonSpacingExtra = v5 and 26 or 0,
	ButtonOpacity = 0.55,
	NoteSpeedMultiplier = 1,
	KeybindFiveKey = { "X", "C", "V", "B", "N" },
	KeybindTwoKey = { "X", "C" },
	KeybindDoublePedalNormal = "Z",
	KeybindVibratoRhythm = "LeftControl",
	KeybindStarPower = "Space",
	KeybindFiveKeyPad = { "ButtonL2", "ButtonL1", "ButtonR1", "ButtonR2", "ButtonB" },
	KeybindTwoKeyPad = { "ButtonL1", "ButtonR1" },
	KeybindDoublePedalNormalPad = "ButtonA",
	KeybindDoublePedalFlippedPad = "ButtonX",
	KeybindStarPowerPad = "ButtonSelect",
	ControllerType = "Gamepad",
	Theme = "2D",
	FirstPersonFOV = 90,
	AudioOffsetMs = 0,
	ShakeEnabled = true,
	HitEffectEnabled = true,
	HitSparkleEnabled = true,
	AutoStarPower = true,
	JudgmentPopEnabled = true,
	HideOwnJudgmentText = false,
	HideAllJudgmentText = false,
	WrongSoundEnabled = true,
	ReduceMotionEnabled = false,
	ShowPerfStats = true,
	HudOpacity = 1,
	StarPowerBarOpacity = 1,
	BandFeedOpacity = 1,
	StreakNoticeOpacity = 1,
	HudOpacityLinked = false,
	HudOpacityAll = 1,
	HudKeepContentClear = true,
	HudContentOpacity = 1,
	FreePlayOpacity = 0.58,
	TouchChartEnabled = true
}

local flag = false
local v7 = nil
local mouseBehavior = nil

do
	local function getViewportSize() -- 4 equivalent calls inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			return currentCamera.ViewportSize
		end

		return Vector2.new(800, 600)
	end
end

do
	local function getTopbarInsetHeight()
		local success, result2 = pcall(function()
			return GuiService:GetGuiInset()
		end)

		local v8 = not (success and result2) and 0 or result2.Y

		return v8 <= 0 and 36 or v8
	end
end

do
	local function computeDropdownTopOffset()
		local success, result2 = pcall(function()
			return GuiService:GetGuiInset()
		end)

		local v8 = not (success and result2) and 0 or result2.Y

		return (v8 <= 0 and 36 or v8) + -8
	end
end

do
	local function computeAvailableSize()
		local viewportSize = getViewportSize() -- inferred equivalent call
		local success, result2, v8 = pcall(function()
			return GuiService:GetGuiInset()
		end)
		local v9, v10

		if success and result2 and v8 then
			v9 = result2.Y
			v10 = v8.Y
		else
			v9 = 0
			v10 = 0
		end

		return viewportSize.X, viewportSize.Y - v9 - v10
	end
end

do
	local function computeDropdownScale()
		local viewportSize = getViewportSize() -- inferred equivalent call
		local success, result2, v8 = pcall(function()
			return GuiService:GetGuiInset()
		end)
		local v9, v10

		if success and result2 and v8 then
			v9 = result2.Y
			v10 = v8.Y
		else
			v9 = 0
			v10 = 0
		end

		local x = viewportSize.X
		local v11 = viewportSize.Y - v9 - v10

		local v12 = x - 24
		local success2, result3 = pcall(function()
			return GuiService:GetGuiInset()
		end)

		local v13 = not (success2 and result3) and 0 or result3.Y

		local v14 = v11 - ((v13 <= 0 and 36 or v13) + -8) - 8

		local v15 = math.min(v12 / 340, v14 / 520)

		if v5 then
			return (math.clamp(v15 * 1.2, 0.65, 9.6))
		end

		return (math.clamp(v15, 0.65, 1.25))
	end
end

local settingsMenuUI = Instance.new("ScreenGui")
settingsMenuUI.Name = "SettingsMenuUI"
settingsMenuUI.ResetOnSpawn = false
settingsMenuUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
settingsMenuUI.DisplayOrder = 100
settingsMenuUI.IgnoreGuiInset = true
settingsMenuUI.Parent = result

do
	local v8 = {}
	v8.AudioCalibrateUI = require(script.Parent:WaitForChild("AudioCalibrateUI"))

	do
		local ThemeSwitchToast = require(ReplicatedStorage.Modules.ThemeSwitchToast)
		v8.Toast = ThemeSwitchToast.new(settingsMenuUI)
	end

	v8.WasInSessionForReminder = false
	v8.CheckedPostGameplayReminder = false
	RemoteEvents:WaitForChild("SongSessionStatusUpdate").OnClientEvent:Connect(function(wasInSessionForReminder)
		if v8.WasInSessionForReminder and not (wasInSessionForReminder or v8.CheckedPostGameplayReminder) then
			v8.CheckedPostGameplayReminder = true

			if not SettingsState.GetHasCalibratedAudioOffset() then
				v8.Toast:Show("Haven't calibrated your audio offset yet? Try it in Settings > Audio > Timing!", 8)
			end
		end

		v8.WasInSessionForReminder = wasInSessionForReminder
	end)

	v8.ModeManager = require(ReplicatedStorage.Modules.ModeManager)

	do
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end

	local gearButton = Instance.new("TextButton")
	gearButton.Name = "GearButton"
	gearButton.AnchorPoint = Vector2.new(1, 0.5)
	gearButton.Size = UDim2.new(0, 70, 0, 30)
	result = UDim2.new

	local function fn()
		return GuiService:GetGuiInset()
	end

	do
		local success, result2 = pcall(fn)

		local v9 = not (success and result2) and 0 or result2.Y

		gearButton.Position = result(1, -12, 0, (v9 <= 0 and 36 or v9) / 2)
	end

	gearButton.BackgroundColor3 = Color3.fromRGB(23, 23, 27)
	gearButton.Text = "Settings"
	gearButton.TextSize = 11
	gearButton.TextColor3 = Color3.fromRGB(245, 245, 247)
	gearButton.Font = Enum.Font.GothamBold
	gearButton.ZIndex = 10
	gearButton.Parent = settingsMenuUI

	result = Instance.new("UICorner")
	result.CornerRadius = udim
	result.Parent = gearButton

	result = Instance.new("UIStroke")
	result.Color = Color3.fromRGB(60, 60, 70)
	result.Transparency = 0.5
	result.Thickness = 1
	result.Parent = gearButton

	local dropdown = Instance.new("Frame")
	dropdown.Name = "Dropdown"
	dropdown.AnchorPoint = Vector2.new(1, 0)
	result = UDim2.new

	do
		local success, result2 = pcall(fn)

		local v9 = not (success and result2) and 0 or result2.Y

		dropdown.Position = result(1, -12, 0, (v9 <= 0 and 36 or v9) + -8)
	end

	dropdown.Size = UDim2.new(0, 340, 0, 520)
	dropdown.BackgroundColor3 = Settings.BG
	dropdown.BackgroundTransparency = 1
	dropdown.BorderSizePixel = 0
	dropdown.Visible = false
	dropdown.ZIndex = 10
	dropdown.ClipsDescendants = true
	dropdown.Parent = settingsMenuUI

	result = Instance.new("UIStroke")
	result.Color = Settings.BORDER
	result.Transparency = 0.5
	result.Thickness = 1
	result.Parent = dropdown

	result = Instance.new("UICorner")
	result.CornerRadius = v4
	result.Parent = dropdown

	local responsiveScale = Instance.new("UIScale")
	responsiveScale.Name = "ResponsiveScale"
	result = workspace.CurrentCamera
	local v9

	if result then
		v9 = result.ViewportSize
	else
		v9 = Vector2.new(800, 600)
	end

	local success, parent2
	success, result, parent2 = pcall(function()
		return GuiService:GetGuiInset()
	end)
	local calibrateCaption

	if success and result and parent2 then
		calibrateCaption = result.Y
		result = parent2.Y
	else
		calibrateCaption = 0
		result = 0
	end

	parent2 = v9.X

	do
		local v10 = v9.Y - calibrateCaption - result

		result = parent2 - 24
		local success2, result2 = pcall(fn)

		local v11 = not (success2 and result2) and 0 or result2.Y

		local v12 = v10 - ((v11 <= 0 and 36 or v11) + -8) - 8

		v9 = math.min(result / 340, v12 / 520)
	end

	if v5 then
		result = math.clamp(v9 * 1.2, 0.65, 9.6)
	else
		result = math.clamp(v9, 0.65, 1.25)
	end

	responsiveScale.Scale = result
	responsiveScale.Parent = dropdown

	result = Instance.new("Frame")
	result.Name = "Glass"
	result.Size = UDim2.new(1, 0, 1, 0)
	result.BackgroundColor3 = Color3.new(0, 0, 0)
	result.BackgroundTransparency = 0.55
	result.ZIndex = 9
	result.Parent = dropdown
	v9 = Instance.new("UICorner")
	v9.CornerRadius = v4
	v9.Parent = result

	result = Instance.new("Frame")
	result.Name = "SearchFrame"
	result.Position = UDim2.new(0, 10, 0, 8)
	result.Size = UDim2.new(1, -20, 0, 28)
	result.BackgroundColor3 = Settings.CARD
	result.BackgroundTransparency = 0.25
	result.ZIndex = 11
	result.Parent = dropdown

	v9 = Instance.new("UICorner")
	v9.CornerRadius = udim
	v9.Parent = result

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Position = UDim2.new(0, 30, 0, 0)
	searchBox.Size = UDim2.new(1, -60, 1, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search settings..."
	searchBox.TextColor3 = Settings.TEXT
	searchBox.PlaceholderColor3 = Settings.TEXT_DIM
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 11
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = 11
	searchBox.Parent = result

	local clearBtn = Instance.new("TextButton")
	clearBtn.Name = "ClearBtn"
	clearBtn.Position = UDim2.new(1, -26, 0, 3)
	clearBtn.Size = UDim2.new(0, 22, 0, 22)
	clearBtn.BackgroundTransparency = 1
	clearBtn.Text = "X"
	clearBtn.TextColor3 = Settings.TEXT_DIM
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = 11
	clearBtn.ZIndex = 11
	clearBtn.Parent = result
	clearBtn.Visible = false

	local tabs = Instance.new("ScrollingFrame")
	tabs.Name = "Tabs"
	tabs.Position = UDim2.new(0, 10, 0, 42)
	tabs.Size = UDim2.new(1, -20, 0, 30)
	tabs.BackgroundTransparency = 1
	tabs.ScrollBarThickness = 0
	tabs.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabs.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabs.ZIndex = 11
	tabs.Parent = dropdown

	result = Instance.new("UIListLayout")
	result.FillDirection = Enum.FillDirection.Horizontal
	result.Padding = UDim.new(0, 4)
	result.VerticalAlignment = Enum.VerticalAlignment.Center
	result.SortOrder = Enum.SortOrder.LayoutOrder
	result.Parent = tabs

	result = Instance.new("UIPadding")
	result.PaddingLeft = UDim.new(0, 2)
	result.PaddingRight = UDim.new(0, 2)
	result.Parent = tabs

	local v10 = { "Gameplay", "Controls", "Visual", "Colors", "Audio" }
	local v11 = {
		Gameplay = "Gameplay",
		Controls = "Controls",
		Visual = "Visual",
		Colors = "Colors",
		Audio = "Audio",
		Access = "Accessibility"
	}
	local v12 = {}
	local v13 = {}

	for i, v14 in ipairs(v10) do
		local textButton = Instance.new("TextButton")
		textButton.LayoutOrder = i
		textButton.Name = v14 .. "Tab"
		textButton.Size = UDim2.new(0, 0, 1, -4)
		textButton.AutomaticSize = Enum.AutomaticSize.X
		textButton.BackgroundColor3 = Settings.CARD
		textButton.BackgroundTransparency = 1
		textButton.Text = v11[v14]
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 10
		textButton.TextColor3 = Settings.TEXT_DIM
		textButton.ZIndex = 11
		textButton.Parent = tabs

		do
			local v15 = Instance.new("UIPadding")
			v15.PaddingLeft = UDim.new(0, 10)
			v15.PaddingRight = UDim.new(0, 10)
			v15.Parent = textButton

			v15 = Instance.new("UICorner")
			v15.CornerRadius = udim
			v15.Parent = textButton
		end

		v12[v14] = textButton
	end

	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.Position = UDim2.new(0, 10, 0, 80)
	content.Size = UDim2.new(1, -20, 1, -96)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 4
	content.ScrollBarImageColor3 = Settings.TEXT_DIM
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.ScrollingDirection = Enum.ScrollingDirection.Y
	content.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	content.ZIndex = 11
	content.Parent = dropdown

	result = Instance.new("UIListLayout")
	result.Padding = UDim.new(0, 8)
	result.Parent = content

	result = Instance.new("UIPadding")
	result.PaddingBottom = UDim.new(0, 14)
	result.Parent = content

	for _, v14 in ipairs(v10) do
		local frame = Instance.new("Frame")
		frame.Name = v14 .. "Panel"
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.BackgroundTransparency = 1
		frame.Visible = false
		frame.ZIndex = 11
		frame.Parent = content

		do
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.Padding = UDim.new(0, 8)
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Parent = frame
		end

		v13[v14] = frame
	end

	local flag2 = false
	local v14 = "Gameplay"

	local function setActiveCategory(p)
		if flag2 then
			return
		end

		v14 = p

		if p ~= "Colors" then
			local ColorsPreview = require(ReplicatedStorage.Modules.ColorsPreview)
			ColorsPreview.Stop()
		end

		for _, v15 in ipairs(v10) do
			local v16 = v12[v15]
			local v17 = v15 == p
			TweenService:Create(v16, TweenInfo.new(0.12), {
				BackgroundColor3 = v17 and Settings.CARD_ACTIVE or Settings.CARD,
				BackgroundTransparency = v17 and 0 or 1,
				TextColor3 = v17 and Settings.TEXT or Settings.TEXT_DIM
			}):Play()
		end

		for _, v15 in ipairs(v10) do
			v13[v15].Visible = v15 == p
		end

		if v8.Remeasure then
			v8.Remeasure(v13[p])
		end
	end

	for k, v15 in pairs(v12) do
		v15.MouseButton1Click:Connect(function()
			setActiveCategory(k)
		end)
	end

	do
		local function applySearch(text)
			if text == "" then
				flag2 = false
				searchBox.Text = ""
				clearBtn.Visible = false

				for _, v15 in ipairs(v10) do
					local v16 = v13[v15]

					for _, frame in ipairs(v16:GetChildren()) do
						if frame:IsA("Frame") and frame.Name == "Card" then
							frame.Visible = true
						end
					end
				end

				for _, v15 in ipairs(v10) do
					v12[v15].Visible = true
				end

				setActiveCategory(v14)
			else
				flag2 = true
				local lower = text:lower()

				for _, v15 in ipairs(v10) do
					local v16 = v13[v15]
					local visible = false

					for _, frame in ipairs(v16:GetChildren()) do
						if not (frame:IsA("Frame") and frame.Name == "Card") then
							continue
						end

						local flag3 = false

						for _, guiObject in ipairs(frame:GetDescendants()) do
							if
								(guiObject:IsA("TextLabel") or guiObject:IsA("TextButton"))
								and guiObject.Text:lower():find(lower, 1, true)
							then
								flag3 = true
								break
							end
						end

						frame.Visible = flag3

						if flag3 then
							visible = true
						end
					end

					v16.Visible = visible
				end

				for _, v15 in ipairs(v10) do
					v12[v15].Visible = false
				end
			end
		end

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = searchBox.Text
			clearBtn.Visible = text ~= ""
			applySearch(text)
		end)
	end

	clearBtn.MouseButton1Click:Connect(function()
		searchBox.Text = ""
		clearBtn.Visible = false
		searchBox:ReleaseFocus()
	end)

	local function makeCard(parent)
		local card = Instance.new("Frame")
		card.Name = "Card"
		card.Size = UDim2.new(1, 0, 0, 0)
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.BackgroundColor3 = Settings.CARD
		card.BackgroundTransparency = 0.25
		card.ZIndex = 11
		card.Parent = parent

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = udim
		uiCorner.Parent = card

		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingTop = UDim.new(0, 10)
		uiPadding.PaddingBottom = UDim.new(0, 10)
		uiPadding.PaddingLeft = UDim.new(0, 12)
		uiPadding.PaddingRight = UDim.new(0, 12)
		uiPadding.Parent = card

		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Padding = UDim.new(0, 8)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = card

		return card
	end

	local function makeSectionLabel(parent, text)
		local sectionLabel = Instance.new("TextLabel")
		sectionLabel.Name = "SectionLabel"
		sectionLabel.Size = UDim2.new(1, 0, 0, 20)
		sectionLabel.BackgroundTransparency = 1
		sectionLabel.Font = Enum.Font.GothamBold
		sectionLabel.TextSize = 15
		sectionLabel.TextColor3 = Settings.ACCENT
		sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
		sectionLabel.Text = text
		sectionLabel.ZIndex = 11
		sectionLabel.Parent = parent

		local underline = Instance.new("Frame")
		underline.Name = "Underline"
		underline.AnchorPoint = Vector2.new(0, 1)
		underline.Position = UDim2.new(0, 0, 1, 2)
		underline.Size = UDim2.new(1, 0, 0, 1)
		underline.BackgroundColor3 = Settings.BORDER
		underline.BackgroundTransparency = 0.45
		underline.BorderSizePixel = 0
		underline.ZIndex = 11
		underline.Parent = sectionLabel
		return sectionLabel
	end

	local function makeSlider(parent, text, min, max, p, callback, fn2, callback2, layoutOrder)
		local sliderRow = Instance.new("Frame")
		sliderRow.Name = "SliderRow"

		if layoutOrder then
			sliderRow.LayoutOrder = layoutOrder
		end

		sliderRow.Size = UDim2.new(1, 0, 0, 44)
		sliderRow.BackgroundTransparency = 1
		sliderRow.ZIndex = 11
		sliderRow.Parent = parent

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(0.5, 0, 0, 14)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = Settings.TEXT
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = text
		label.ZIndex = 11
		label.Parent = sliderRow

		local percent = Instance.new("TextLabel")
		percent.Name = "Percent"
		percent.AnchorPoint = Vector2.new(1, 0)
		percent.Position = UDim2.new(1, -40, 0, 0)
		percent.Size = UDim2.new(0, 40, 0, 14)
		percent.BackgroundTransparency = 1
		percent.Font = Enum.Font.GothamBold
		percent.TextSize = 11
		percent.TextColor3 = Settings.WARNING
		percent.TextXAlignment = Enum.TextXAlignment.Right
		percent.ZIndex = 11
		percent.Parent = sliderRow

		local resetBtn = Instance.new("TextButton")
		resetBtn.Name = "ResetBtn"
		resetBtn.AnchorPoint = Vector2.new(1, 0)
		resetBtn.Position = UDim2.new(1, 0, 0, -2)
		resetBtn.Size = UDim2.new(0, 36, 0, 18)
		resetBtn.BackgroundTransparency = 1
		resetBtn.Text = "Reset"
		resetBtn.TextColor3 = Settings.TEXT_DIM
		resetBtn.Font = Enum.Font.GothamBold
		resetBtn.TextSize = 9
		resetBtn.TextXAlignment = Enum.TextXAlignment.Right
		resetBtn.ZIndex = 12
		resetBtn.Parent = sliderRow

		local track = Instance.new("Frame")
		track.Name = "Track"
		track.Size = UDim2.new(1, 0, 0, 6)
		track.Position = UDim2.new(0, 0, 0, 22)
		track.BackgroundColor3 = Settings.INPUT
		track.ZIndex = 11
		track.Active = true
		track.Parent = sliderRow

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = track

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.BackgroundColor3 = Settings.WARNING
		fill.BorderSizePixel = 0
		fill.ZIndex = 11
		fill.Parent = track

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(1, 0)
		uiCorner2.Parent = fill

		local knob = Instance.new("Frame")
		knob.Name = "Knob"
		knob.Size = UDim2.new(0, 12, 0, 12)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new(0, 0, 0.5, 0)
		knob.BackgroundColor3 = Settings.TEXT
		knob.ZIndex = 13
		knob.Active = true
		knob.Parent = track

		local uiCorner3 = Instance.new("UICorner")
		uiCorner3.CornerRadius = UDim.new(1, 0)
		uiCorner3.Parent = knob

		local hitArea = Instance.new("Frame")
		hitArea.Name = "HitArea"
		hitArea.AnchorPoint = Vector2.new(0, 0.5)
		hitArea.Position = UDim2.new(0, 0, 0, 22)
		hitArea.Size = UDim2.new(1, 0, 0, 36)
		hitArea.BackgroundTransparency = 1
		hitArea.ZIndex = 10
		hitArea.Active = true
		hitArea.Parent = sliderRow

		local function refresh()
			local v15 = callback()
			local v16 = math.clamp((v15 - min) / (max - min), 0, 1)
			fill.Size = UDim2.new(v16, 0, 1, 0)
			knob.Position = UDim2.new(v16, 0, 0.5, 0)

			if callback2 then
				percent.Text = callback2(v15)
			else
				percent.Text = tostring((math.floor(v16 * 100))) .. "%"
			end
		end

		local flag3 = false

		local function setFromInput(position) -- 2 equivalent calls inferred from this helper
			fn2(min + math.clamp((position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1) * (max - min))
			refresh()
		end

		local function beginDrag() -- 2 equivalent calls inferred from this helper
			flag3 = true
			content.ScrollingEnabled = false
		end

		local function endDrag() -- 1 equivalent call inferred from this helper
			if flag3 then
				flag3 = false
				content.ScrollingEnabled = true
			end
		end

		hitArea.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				beginDrag() -- inferred equivalent call
				setFromInput(input.Position) -- inferred equivalent call
			end
		end)

		knob.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				beginDrag() -- inferred equivalent call
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if
				flag3
				and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			then
				setFromInput(input.Position) -- inferred equivalent call
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				endDrag() -- inferred equivalent call
			end
		end)

		resetBtn.MouseButton1Click:Connect(function()
			fn2(p)
			refresh()
		end)

		local RunService2 = game:GetService("RunService")
		hitArea.Selectable = true
		hitArea.NextSelectionLeft = hitArea
		hitArea.NextSelectionRight = hitArea
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 6, 1, 0)
		local uiCorner4 = Instance.new("UICorner")
		uiCorner4.CornerRadius = UDim.new(0, 6)
		uiCorner4.Parent = frame
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Settings.WARNING
		uiStroke.Thickness = 2
		uiStroke.Parent = frame
		hitArea.SelectionImageObject = frame

		local renderSteppedConnection = nil
		local function readDirection(): number
			local v15 = UserInputService:GetConnectedGamepads()[1] or Enum.UserInputType.Gamepad1

			if UserInputService:IsGamepadButtonDown(v15, Enum.KeyCode.DPadLeft) then
				return -1
			end

			if UserInputService:IsGamepadButtonDown(v15, Enum.KeyCode.DPadRight) then
				return 1
			end

			local success2, result2 = pcall(function()
				return UserInputService:GetGamepadState(v15)
			end)

			if not (success2 and result2) then
				return 0
			end

			for _, v16 in ipairs(result2) do
				if v16.KeyCode ~= Enum.KeyCode.Thumbstick1 then
					continue
				end

				if v16.Position.X > 0.5 then
					return 1
				end

				if v16.Position.X < -0.5 then
					return -1
				end

				break
			end

			return 0
		end

		hitArea.SelectionGained:Connect(function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			local v15 = 0
			local total = 0
			local total2 = 0.35
			renderSteppedConnection = RunService2.RenderStepped:Connect(function(dt)
				local v16 = readDirection()

				if v16 == 0 then
					v15 = 0
					total = 0
					total2 = 0.35
				else
					local flag4 = false

					if v16 == v15 then
						total += dt

						if total2 <= total then
							total2 += 0.07
							flag4 = true
						end
					else
						v15 = v16
						total = 0
						total2 = 0.35
						flag4 = true
					end

					if flag4 then
						fn2((math.clamp(callback() + v16 * (max - min) / 20, min, max)))
						refresh()
					end
				end
			end)
		end)
		hitArea.SelectionLost:Connect(function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)
		sliderRow.Destroying:Connect(function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)

		refresh()
		return { Refresh = refresh, Row = sliderRow }
	end

	local function makeActionRow(parent, text, text2, onMouseButton1Click)
		local actionRow = Instance.new("Frame")
		actionRow.Name = "ActionRow"
		actionRow.Size = UDim2.new(1, 0, 0, 28)
		actionRow.BackgroundTransparency = 1
		actionRow.ZIndex = 11
		actionRow.Parent = parent

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(0.5, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = Settings.TEXT
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = true
		label.Text = text
		label.ZIndex = 11
		label.Parent = actionRow

		local actionBtn = Instance.new("TextButton")
		actionBtn.Name = "ActionBtn"
		actionBtn.AnchorPoint = Vector2.new(1, 0.5)
		actionBtn.Position = UDim2.new(1, 0, 0.5, 0)
		actionBtn.Size = UDim2.new(0, 90, 0, 26)
		actionBtn.BackgroundColor3 = Settings.BTN
		actionBtn.Text = text2
		actionBtn.TextColor3 = Settings.TEXT
		actionBtn.Font = Enum.Font.GothamBold
		actionBtn.TextSize = 10
		actionBtn.ZIndex = 11
		actionBtn.Parent = actionRow

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = udim
		uiCorner.Parent = actionBtn

		if onMouseButton1Click then
			actionBtn.MouseButton1Click:Connect(onMouseButton1Click)
		end

		return actionBtn
	end

	local function makeComingSoonRow(result2, text)
		local comingSoonRow = Instance.new("Frame")
		comingSoonRow.Name = "ComingSoonRow"
		comingSoonRow.Size = UDim2.new(1, 0, 0, 22)
		comingSoonRow.BackgroundTransparency = 1
		comingSoonRow.ZIndex = 11
		comingSoonRow.Parent = result2

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(0.6, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = Settings.TEXT_DIM
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = text
		label.ZIndex = 11
		label.Parent = comingSoonRow

		local badge = Instance.new("TextLabel")
		badge.Name = "Badge"
		badge.AnchorPoint = Vector2.new(1, 0.5)
		badge.Position = UDim2.new(1, 0, 0.5, 0)
		badge.Size = UDim2.new(0, 80, 0, 18)
		badge.BackgroundTransparency = 1
		badge.Font = Enum.Font.GothamMedium
		badge.TextSize = 10
		badge.TextColor3 = Settings.TEXT_DIM
		badge.TextXAlignment = Enum.TextXAlignment.Right
		badge.Text = "Soon"
		badge.ZIndex = 11
		badge.Parent = comingSoonRow
	end

	local function makeToggleRow(parent, text, callback, fn2)
		local toggleRow = Instance.new("Frame")
		toggleRow.Name = "ToggleRow"
		toggleRow.Size = UDim2.new(1, 0, 0, 24)
		toggleRow.BackgroundTransparency = 1
		toggleRow.ZIndex = 11
		toggleRow.Parent = parent

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(0.65, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = Settings.TEXT
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = text
		label.ZIndex = 11
		label.Parent = toggleRow

		local toggleTrack = Instance.new("TextButton")
		toggleTrack.Name = "ToggleTrack"
		toggleTrack.AnchorPoint = Vector2.new(1, 0.5)
		toggleTrack.Position = UDim2.new(1, 0, 0.5, 0)
		toggleTrack.Size = UDim2.new(0, 40, 0, 20)
		toggleTrack.AutoButtonColor = false
		toggleTrack.Text = ""
		toggleTrack.BackgroundColor3 = Settings.BUTTON
		toggleTrack.ZIndex = 11
		toggleTrack.Parent = toggleRow

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = toggleTrack

		local knob = Instance.new("Frame")
		knob.Name = "Knob"
		knob.AnchorPoint = Vector2.new(0, 0.5)
		knob.Position = UDim2.new(0, 2, 0.5, 0)
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.BackgroundColor3 = Settings.TEXT
		knob.ZIndex = 12
		knob.Parent = toggleTrack

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(1, 0)
		uiCorner2.Parent = knob

		local function refresh()
			local v15 = callback() and true or false
			local udim2 = v15 and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Position = udim2
			}):Play()
			toggleTrack.BackgroundColor3 = v15 and Settings.ACCENT or Settings.BUTTON
		end

		toggleTrack.MouseButton1Click:Connect(function()
			fn2(not (callback() and true or false))
			refresh()
		end)

		refresh()
		return { Refresh = refresh }
	end

	function v8.MakeStepperRow(parent, text, text2, min, max, p, value, callback, callback2, layoutOrder)
		local stepperRow = Instance.new("Frame")
		stepperRow.Name = "StepperRow"

		if layoutOrder then
			stepperRow.LayoutOrder = layoutOrder
		end

		stepperRow.Size = UDim2.new(1, 0, 0, 0)
		stepperRow.AutomaticSize = Enum.AutomaticSize.Y
		stepperRow.BackgroundTransparency = 1
		stepperRow.ZIndex = 11
		stepperRow.Parent = parent

		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Padding = UDim.new(0, 6)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = stepperRow

		local topLine = Instance.new("Frame")
		topLine.Name = "TopLine"
		topLine.LayoutOrder = 1
		topLine.Size = UDim2.new(1, 0, 0, 30)
		topLine.BackgroundTransparency = 1
		topLine.ZIndex = 11
		topLine.Parent = stepperRow

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(0.42, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = Settings.TEXT
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = text
		label.ZIndex = 11
		label.Parent = topLine

		local capsule = Instance.new("Frame")
		capsule.Name = "Capsule"
		capsule.AnchorPoint = Vector2.new(1, 0.5)
		capsule.Position = UDim2.new(1, 0, 0.5, 0)
		capsule.Size = UDim2.new(0, 128, 0, 28)
		capsule.BackgroundColor3 = Settings.CAPSULE
		capsule.ZIndex = 11
		capsule.Parent = topLine

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = capsule

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Settings.ACCENT
		uiStroke.Transparency = 0.6
		uiStroke.Thickness = 1
		uiStroke.Parent = capsule

		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Parent = capsule

		local minusBtn = Instance.new("TextButton")
		minusBtn.Name = "MinusBtn"
		minusBtn.LayoutOrder = 1
		minusBtn.Size = UDim2.new(0, 34, 1, 0)
		minusBtn.BackgroundTransparency = 1
		minusBtn.AutoButtonColor = false
		minusBtn.Text = "−"
		minusBtn.TextColor3 = Settings.TEXT
		minusBtn.Font = Enum.Font.GothamBold
		minusBtn.TextSize = 16
		minusBtn.ZIndex = 12
		minusBtn.Parent = capsule

		local value2 = Instance.new("TextBox")
		value2.Name = "Value"
		value2.LayoutOrder = 2
		value2.Size = UDim2.new(0, 60, 1, 0)
		value2.BackgroundTransparency = 1
		value2.Font = Enum.Font.GothamBold
		value2.TextSize = 12
		value2.TextColor3 = Settings.ACCENT
		value2.TextXAlignment = Enum.TextXAlignment.Center
		value2.ClearTextOnFocus = false
		value2.ZIndex = 12
		value2.Parent = capsule

		local plusBtn = Instance.new("TextButton")
		plusBtn.Name = "PlusBtn"
		plusBtn.LayoutOrder = 3
		plusBtn.Size = UDim2.new(0, 34, 1, 0)
		plusBtn.BackgroundTransparency = 1
		plusBtn.AutoButtonColor = false
		plusBtn.Text = "+"
		plusBtn.TextColor3 = Settings.TEXT
		plusBtn.Font = Enum.Font.GothamBold
		plusBtn.TextSize = 16
		plusBtn.ZIndex = 12
		plusBtn.Parent = capsule

		local description = Instance.new("TextLabel")
		description.Name = "Description"
		description.LayoutOrder = 2
		description.Size = UDim2.new(1, 0, 0, 0)
		description.AutomaticSize = Enum.AutomaticSize.Y
		description.BackgroundTransparency = 1
		description.Font = Enum.Font.Gotham
		description.TextSize = 9
		description.TextColor3 = Settings.TEXT_DIM
		description.TextWrapped = true
		description.TextXAlignment = Enum.TextXAlignment.Left
		description.Text = text2
		description.ZIndex = 11
		description.Parent = stepperRow

		local function refresh() -- 4 equivalent calls inferred from this helper
			value2.Text = tostring(callback()) .. (value or "")
		end

		value2.FocusLost:Connect(function()
			local match = value2.Text:match("%-?%d+")

			if match then
				callback2((math.clamp(tonumber(match), min, max)))
			end

			refresh() -- inferred equivalent call
		end)

		SettingsState.OnChanged(refresh)

		minusBtn.MouseButton1Click:Connect(function()
			callback2((math.clamp(callback() - p, min, max)))
			refresh() -- inferred equivalent call
		end)

		plusBtn.MouseButton1Click:Connect(function()
			callback2((math.clamp(callback() + p, min, max)))
			refresh() -- inferred equivalent call
		end)
		refresh() -- inferred equivalent call
		return { Refresh = refresh }
	end

	function v8:EnableDragScroll(p, p2)
		self.ScrollingEnabled = false

		local v15 = false
		local v16 = false
		local v17 = 0
		local v18 = 0

		local function axisValue(p3) -- 4 equivalent calls inferred from this helper
			return p == "x" and p3.X or p3.Y
		end

		local function withinFrame(x, y): boolean -- 2 equivalent calls inferred from this helper
			local absolutePosition = self.AbsolutePosition
			local absoluteSize = self.AbsoluteSize
			return absolutePosition.X <= x
				and x <= absolutePosition.X + absoluteSize.X
				and absolutePosition.Y <= y
				and y <= absolutePosition.Y + absoluteSize.Y
		end

		local function maxCanvas() -- 1 equivalent call inferred from this helper
			if p == "x" then
				return (math.max(0, self.AbsoluteCanvasSize.X - self.AbsoluteSize.X))
			end

			return (math.max(0, self.AbsoluteCanvasSize.Y - self.AbsoluteSize.Y))
		end

		local function setCanvas(value) -- 2 equivalent calls inferred from this helper
			local v19 = math.clamp(value, 0, maxCanvas()) -- inferred equivalent call

			if p == "x" then
				self.CanvasPosition = Vector2.new(v19, self.CanvasPosition.Y)
			else
				self.CanvasPosition = Vector2.new(self.CanvasPosition.X, v19)
			end
		end

		UserInputService.InputBegan:Connect(function(input)
			if
				input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
				and (not p2 or input.UserInputType ~= Enum.UserInputType.MouseButton2)
			then
				return
			end

			if not withinFrame(input.Position.X, input.Position.Y) then -- inferred equivalent call
				return
			end

			v15 = true
			v16 = false
			v17 = axisValue(input.Position) -- inferred equivalent call
			v18 = axisValue(self.CanvasPosition) -- inferred equivalent call
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				if withinFrame(input.Position.X, input.Position.Y) then -- inferred equivalent call
					setCanvas(axisValue(self.CanvasPosition) - input.Position.Z * 40) -- inferred equivalent call
				end
			else
				if
					not v15
					or input.UserInputType ~= Enum.UserInputType.MouseMovement
					and input.UserInputType ~= Enum.UserInputType.Touch
				then
					return
				end

				local v19 = axisValue(input.Position) - v17 -- inferred equivalent call

				if not v16 and math.abs(v19) < 4 then
					return
				end

				v16 = true
				setCanvas(v18 - v19) -- inferred equivalent call
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
				or p2 and input.UserInputType == Enum.UserInputType.MouseButton2
			then
				v15 = false
			end
		end)
	end

	function v8.AddStroke(parent, color, thickness)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = color
		uiStroke.Thickness = thickness
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = parent
		return uiStroke
	end

	v8.EnableDragScroll(tabs, "x")
	v8.EnableDragScroll(content, "y")

	local gameplay = v13.Gameplay

	result = makeCard(gameplay)
	makeSectionLabel(result, "Note Speed")
	local slider = makeSlider(
		result,
		"Note Fall Speed",
		0.5,
		3,
		v6.NoteSpeedMultiplier,
		SettingsState.GetNoteSpeedMultiplier,
		function(p)
			SettingsState.SetField("NoteSpeedMultiplier", p)
		end
	)

	result = makeCard(gameplay)
	makeSectionLabel(result, "Lane Opacity")
	local slider2 = makeSlider(
		result,
		"Fret Button Opacity",
		0.2,
		1,
		v6.ButtonOpacity,
		SettingsState.GetButtonOpacity,
		function(p)
			SettingsState.SetField("ButtonOpacity", p)
		end
	)

	local v15 = {
		Default = {
			HighwayCamElevation = 41,
			HighwayCamFov = 55,
			HighwayCamZoom = 0.62,
			HighwayCamHitY = 0.63,
			HighwayCamLength = 58,
			HighwayCamCustom = false
		},
		ClassicSize = {
			HighwayCamElevation = 32,
			HighwayCamFov = 35,
			HighwayCamZoom = 0.7,
			HighwayCamHitY = 0.55,
			HighwayCamLength = 36,
			HighwayCamCustom = true
		}
	}

	local card = makeCard(gameplay)
	makeSectionLabel(card, "Highway Camera (3D)")
	makeActionRow(card, "Default view", "Default", function()
		SettingsState.SetFields(v15.Default)
	end)
	makeActionRow(card, "Classic Size", "Classic Size", function()
		SettingsState.SetFields(v15.ClassicSize)
	end)
	local v16 = {}

	do
		local function addHighwayCamSlider(p, p2, p3, p4, p5, p6, p7)
			local slider3 = makeSlider(card, p, p3, p4, p5, p6, function(p8)
				SettingsState.SetHighwayCam(p2, p8)
			end, p7)
			table.insert(v16, slider3)
			return slider3
		end
	end

	do
		local v17 = "HighwayCamElevation"
		table.insert(
			v16,
			makeSlider(
				card,
				"Camera Angle (higher = steeper)",
				18,
				50,
				41,
				SettingsState.GetHighwayCamElevation,
				function(p)
					SettingsState.SetHighwayCam(v17, p)
				end,
				function(p)
					return string.format("%d deg", (math.floor(p + 0.5)))
				end
			)
		)
	end

	do
		local v17 = "HighwayCamFov"
		table.insert(
			v16,
			makeSlider(card, "Perspective (lower = flatter)", 25, 60, 55, SettingsState.GetHighwayCamFov, function(p)
				SettingsState.SetHighwayCam(v17, p)
			end, function(p)
				return string.format("%d deg", (math.floor(p + 0.5)))
			end)
		)
	end

	do
		local v17 = "HighwayCamZoom"
		table.insert(v16, makeSlider(card, "Highway Size", 0.5, 0.88, 0.62, SettingsState.GetHighwayCamZoom, function(p)
			SettingsState.SetHighwayCam(v17, p)
		end, function(p)
			return string.format("%d%%", (math.floor(p * 100 + 0.5)))
		end))
	end

	do
		local v17 = "HighwayCamHitY"
		table.insert(
			v16,
			makeSlider(
				card,
				"Hit Line Position (higher = lower on screen)",
				0.2,
				0.7,
				0.63,
				SettingsState.GetHighwayCamHitY,
				function(p)
					SettingsState.SetHighwayCam(v17, p)
				end,
				function(p)
					return string.format("%d%%", (math.floor(p * 100 + 0.5)))
				end
			)
		)
	end

	do
		local v17 = "HighwayCamLength"
		table.insert(v16, makeSlider(card, "Highway Length", 30, 60, 58, SettingsState.GetHighwayCamLength, function(p)
			SettingsState.SetHighwayCam(v17, p)
		end, function(p)
			return string.format("%d", (math.floor(p + 0.5)))
		end))
	end

	SettingsState.OnChanged(function()
		for _, v17 in ipairs(v16) do
			v17.Refresh()
		end
	end)

	result = makeCard(gameplay)
	makeSectionLabel(result, "Mobile")

	local ColorsPreview = require(ReplicatedStorage.Modules.ColorsPreview)
	local KeyArrowIcon = require(ReplicatedStorage.Modules.KeyArrowIcon)

	local count = 0
	local function nextOrder() -- 12 equivalent calls inferred from this helper
		count += 1
		return count
	end

	v9 = Instance.new("Frame")
	v9.Name = "PreviewRow"
	v9.LayoutOrder = nextOrder() -- inferred equivalent call
	v9.Size = UDim2.new(1, 0, 0, 34)
	v9.BackgroundTransparency = 1
	v9.ZIndex = 11
	v9.Parent = result

	parent2 = Instance.new("TextLabel")
	parent2.Name = "Title"
	parent2.Position = UDim2.new(0, 0, 0, 2)
	parent2.Size = UDim2.new(1, -100, 0, 14)
	parent2.BackgroundTransparency = 1
	parent2.Font = Enum.Font.GothamBold
	parent2.TextSize = 13
	parent2.TextColor3 = Settings.ACCENT
	parent2.TextXAlignment = Enum.TextXAlignment.Left
	parent2.Text = "Live Preview"
	parent2.ZIndex = 11
	parent2.Parent = v9

	parent2 = Instance.new("TextLabel")
	parent2.Name = "Subtitle"
	parent2.Position = UDim2.new(0, 0, 0, 18)
	parent2.Size = UDim2.new(1, -100, 0, 14)
	parent2.BackgroundTransparency = 1
	parent2.Font = Enum.Font.Gotham
	parent2.TextSize = 9
	parent2.TextColor3 = Settings.TEXT_DIM
	parent2.TextXAlignment = Enum.TextXAlignment.Left
	parent2.TextTruncate = Enum.TextTruncate.AtEnd
	parent2.Text = "See your changes live"
	parent2.ZIndex = 11
	parent2.Parent = v9

	do
		local previewBtn = Instance.new("TextButton")
		previewBtn.Name = "PreviewBtn"
		previewBtn.AnchorPoint = Vector2.new(1, 0.5)
		previewBtn.Position = UDim2.new(1, 0, 0.5, 0)
		previewBtn.Size = UDim2.new(0, 92, 0, 28)
		previewBtn.BackgroundColor3 = Settings.BTN
		previewBtn.Text = "Preview"
		previewBtn.TextColor3 = Settings.TEXT
		previewBtn.Font = Enum.Font.GothamBold
		previewBtn.TextSize = 10
		previewBtn.ZIndex = 11
		previewBtn.Parent = v9
		v9 = Instance.new("UICorner")
		v9.CornerRadius = udim
		v9.Parent = previewBtn

		local previewHint = Instance.new("TextLabel")
		previewHint.Name = "PreviewHint"
		previewHint.LayoutOrder = nextOrder() -- inferred equivalent call
		previewHint.Size = UDim2.new(1, 0, 0, 12)
		previewHint.BackgroundTransparency = 1
		previewHint.Font = Enum.Font.Gotham
		previewHint.TextSize = 9
		previewHint.TextColor3 = Settings.TEXT_DIM
		previewHint.TextXAlignment = Enum.TextXAlignment.Left
		previewHint.TextWrapped = true
		previewHint.AutomaticSize = Enum.AutomaticSize.Y
		previewHint.Text = "Preview unavailable while a song is playing"
		previewHint.Visible = false
		previewHint.ZIndex = 11
		previewHint.Parent = result

		do
			local function refreshPreviewButton() -- 2 equivalent calls inferred from this helper
				local isActive = ColorsPreview.IsActive()
				local v17 = isActive or ColorsPreview.CanStart()
				previewBtn.Text = isActive and "Preview ON" or "Preview"

				if isActive then
					previewBtn.BackgroundColor3 = Settings.ACCENT
					previewBtn.TextColor3 = Settings.DARKTEXT
				else
					previewBtn.BackgroundColor3 = Settings.BTN
					previewBtn.TextColor3 = v17 and Settings.TEXT or Settings.TEXT_DIM
				end

				previewHint.Visible = not v17
			end

			previewBtn.MouseButton1Click:Connect(function()
				if ColorsPreview.IsActive() then
					ColorsPreview.Stop()
				elseif ColorsPreview.CanStart() then
					ColorsPreview.Start(5)
				end

				refreshPreviewButton() -- inferred equivalent call
			end)

			ColorsPreview.OnStopped(refreshPreviewButton)
		end

		gameplay:GetPropertyChangedSignal("Visible"):Connect(function()
			if not gameplay.Visible then
				ColorsPreview.Stop()
			end
		end)
		dropdown:GetPropertyChangedSignal("Visible"):Connect(function()
			if not (dropdown.Visible or LayoutEditorUI.IsOpen()) then
				ColorsPreview.Stop()
			end
		end)
		task.spawn(function()
			while true do
				task.wait(0.3)

				if dropdown.Visible and gameplay.Visible then
					refreshPreviewButton() -- inferred equivalent call
				end
			end
		end)
	end

	v9 = Instance.new("Frame")
	v9.Name = "LinkRow"
	v9.LayoutOrder = nextOrder() -- inferred equivalent call
	v9.Size = UDim2.new(1, 0, 0, 24)
	v9.BackgroundTransparency = 1
	v9.ZIndex = 11
	v9.Parent = result

	parent2 = Instance.new("TextLabel")
	parent2.Name = "Label"
	parent2.Size = UDim2.new(1, -30, 1, 0)
	parent2.BackgroundTransparency = 1
	parent2.Font = Enum.Font.GothamMedium
	parent2.TextSize = 11
	parent2.TextColor3 = Settings.TEXT
	parent2.TextXAlignment = Enum.TextXAlignment.Left
	parent2.Text = "Link Width & Height"
	parent2.ZIndex = 11
	parent2.Parent = v9

	parent2 = Instance.new("TextButton")
	parent2.Name = "LinkCheck"
	parent2.AnchorPoint = Vector2.new(1, 0.5)
	parent2.Position = UDim2.new(1, 0, 0.5, 0)
	parent2.Size = UDim2.new(0, 22, 0, 22)
	parent2.AutoButtonColor = false
	parent2.Text = ""
	parent2.BackgroundColor3 = Settings.BTN
	parent2.ZIndex = 11
	parent2.Parent = v9
	v9 = Instance.new("UICorner")
	v9.CornerRadius = UDim.new(0, 6)
	v9.Parent = parent2
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1.5
	uiStroke.Color = Settings.TEXT_DIM
	uiStroke.Parent = parent2

	local tick = Instance.new("Frame")
	tick.Name = "Tick"
	tick.AnchorPoint = Vector2.new(0.5, 0.5)
	tick.Position = UDim2.new(0.5, 0, 0.5, 0)
	tick.Size = UDim2.new(0, 12, 0, 12)
	tick.BackgroundColor3 = Settings.ACCENT
	tick.BorderSizePixel = 0
	tick.ZIndex = 12
	tick.Parent = parent2
	v9 = Instance.new("UICorner")
	v9.CornerRadius = UDim.new(0, 3)
	v9.Parent = tick

	do
		local function refreshLink() -- 2 equivalent calls inferred from this helper
			local buttonSizeLinked = SettingsState.GetButtonSizeLinked()
			tick.Visible = buttonSizeLinked
			uiStroke.Color = buttonSizeLinked and Settings.ACCENT or Settings.TEXT_DIM
		end
	end

	parent2.MouseButton1Click:Connect(function()
		SettingsState.SetButtonSizeLinked(not SettingsState.GetButtonSizeLinked())
		refreshLink() -- inferred equivalent call
	end)
	v9 = SettingsState.GetButtonSizeLinked()
	tick.Visible = v9
	uiStroke.Color = v9 and Settings.ACCENT or Settings.TEXT_DIM

	local function fmtScale(p)
		return string.format("%.2fx", p)
	end

	do
		local function round2(p) -- 2 equivalent calls inferred from this helper
			return math.floor(p * 100 + 0.5) / 100
		end
	end

	v9 = v6.ButtonSizeMultiplier
	parent2 = SettingsState.GetButtonWidthMultiplier
	nextOrder() -- inferred equivalent call
	local slider3 = makeSlider(result, "Button Width", 0.5, 2.5, v9, parent2, function(p)
		SettingsState.SetButtonWidthMultiplier(round2(p)) -- inferred equivalent call
	end, fmtScale, count)

	v9 = v6.ButtonSizeMultiplier
	parent2 = SettingsState.GetButtonHeightMultiplier
	nextOrder() -- inferred equivalent call
	local slider4 = makeSlider(result, "Button Height", 0.5, 2.5, v9, parent2, function(p)
		SettingsState.SetButtonHeightMultiplier(round2(p)) -- inferred equivalent call
	end, fmtScale, count)

	v9 = v6.ButtonSpacingExtra
	parent2 = SettingsState.GetButtonSpacingExtra
	nextOrder() -- inferred equivalent call
	local slider5 = makeSlider(result, "Button Spacing", 0, 60, v9, parent2, function(p)
		SettingsState.SetField("ButtonSpacingExtra", (math.floor(p + 0.5)))
	end, function(p)
		return string.format("%dpx", (math.floor(p + 0.5)))
	end, count)

	local function fmtSigned(p)
		return string.format("%+d", (math.floor(p + 0.5)))
	end

	nextOrder() -- inferred equivalent call
	local slider6 = makeSlider(result, "Move Left / Right", -250, 250, 0, function()
		return SettingsState.GetButtonGroupOffset().X
	end, function(p)
		SettingsState.SetButtonGroupOffset(math.floor(p + 0.5), SettingsState.GetButtonGroupOffset().Y)
	end, fmtSigned, count)
	nextOrder() -- inferred equivalent call
	local slider7 = makeSlider(result, "Move Up / Down", -150, 150, v5 and 66 or 0, function()
		return SettingsState.GetButtonGroupOffset().Y
	end, function(p)
		SettingsState.SetButtonGroupOffset(SettingsState.GetButtonGroupOffset().X, (math.floor(p + 0.5)))
	end, fmtSigned, count)

	do
		local function nudge(p, p2) -- 2 equivalent calls inferred from this helper
			local buttonGroupOffset = SettingsState.GetButtonGroupOffset()
			SettingsState.SetButtonGroupOffset(
				math.clamp(buttonGroupOffset.X + p, -250, 250),
				(math.clamp(buttonGroupOffset.Y + p2, -150, 150))
			)
		end
	end

	do
		local nudgeRow = Instance.new("Frame")
		nudgeRow.Name = "NudgeRow"
		nudgeRow.LayoutOrder = nextOrder() -- inferred equivalent call
		nudgeRow.Size = UDim2.new(1, 0, 0, 30)
		nudgeRow.BackgroundTransparency = 1
		nudgeRow.ZIndex = 11
		nudgeRow.Parent = result

		v9 = Instance.new("UIListLayout")
		v9.FillDirection = Enum.FillDirection.Horizontal
		v9.HorizontalAlignment = Enum.HorizontalAlignment.Center
		v9.VerticalAlignment = Enum.VerticalAlignment.Center
		v9.Padding = UDim.new(0, 6)
		v9.SortOrder = Enum.SortOrder.LayoutOrder
		v9.Parent = nudgeRow

		do
			local count2 = 0
			local function makeNudgeButton(layoutOrder, p, p2, p3)
				local textButton = Instance.new("TextButton")
				textButton.Name = "Nudge" .. layoutOrder
				textButton.LayoutOrder = layoutOrder
				textButton.Size = UDim2.new(0, 44, 0, 28)
				textButton.AutoButtonColor = true
				textButton.BackgroundColor3 = Settings.BTN
				textButton.Text = ""
				textButton.ZIndex = 11
				textButton.Parent = nudgeRow
				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = udim
				uiCorner.Parent = textButton
				KeyArrowIcon.Create(textButton, p, 16, Settings.TEXT, Color3.fromRGB(14, 12, 10), 1)

				textButton.MouseButton1Down:Connect(function()
					count2 += 1
					local v17 = count2
					nudge(p2, p3) -- inferred equivalent call
					task.spawn(function()
						task.wait(0.35)

						while count2 == v17 do
							nudge(p2, p3) -- inferred equivalent call
							task.wait(0.05)
						end
					end)
				end)
				local function release()
					count2 += 1
				end
				textButton.MouseButton1Up:Connect(release)
				textButton.MouseLeave:Connect(release)
				return textButton
			end

			makeNudgeButton(1, KeyArrowIcon.GetRotation("Left"), -4, 0)
			makeNudgeButton(2, KeyArrowIcon.GetRotation("Right"), 4, 0)
			makeNudgeButton(3, KeyArrowIcon.GetRotation("Up"), 0, -4)
			makeNudgeButton(4, KeyArrowIcon.GetRotation("Down"), 0, 4)
		end

		v9 = Instance.new("TextButton")
		v9.Name = "CenterBtn"
		v9.LayoutOrder = 5
		v9.Size = UDim2.new(0, 64, 0, 28)
		v9.BackgroundColor3 = Settings.BTN
		v9.Text = "Center"
		v9.TextColor3 = Settings.TEXT
		v9.Font = Enum.Font.GothamBold
		v9.TextSize = 10
		v9.ZIndex = 11
		v9.Parent = nudgeRow
	end

	parent2 = Instance.new("UICorner")
	parent2.CornerRadius = udim
	parent2.Parent = v9
	v9.MouseButton1Click:Connect(function()
		SettingsState.SetButtonGroupOffset(0, 0)
	end)

	v9 = makeActionRow(result, "Button Position", "Edit Layout", function()
		dropdown.Visible = false
		flag = false
		v7 = nil

		local ColorsPreview2 = require(ReplicatedStorage.Modules.ColorsPreview)
		ColorsPreview2.Stop()
		LayoutEditorUI.Show()

		if LayoutEditorUI.IsOpen() then
			task.spawn(function()
				while LayoutEditorUI.IsOpen() do
					task.wait(0.1)
				end

				SessionCameraSettings.SetMenuOpen(false)
			end)
		else
			SessionCameraSettings.SetMenuOpen(false)
		end
	end).Parent
	v9.LayoutOrder = nextOrder() -- inferred equivalent call

	do
		local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
		v9 = TouchChart.IsDeviceEligible()
	end

	v8.TouchChart = makeToggleRow(result, "Touch Chart", SettingsState.GetTouchChartEnabled, function(p)
		SettingsState.SetTouchChartEnabled(p)
		v8.Toast:Show(p and "Touch Chart Enabled" or "Touch Chart Disabled")
	end)
	parent2 = result:FindFirstChild("ToggleRow")

	if parent2 then
		parent2.Name = "TouchChartRow"
		parent2.LayoutOrder = nextOrder() -- inferred equivalent call
		parent2.Visible = v9
	end

	parent2 = Instance.new("TextLabel")
	parent2.Name = "TouchChartHint"
	parent2.LayoutOrder = nextOrder() -- inferred equivalent call
	parent2.Size = UDim2.new(1, 0, 0, 12)
	parent2.BackgroundTransparency = 1
	parent2.Font = Enum.Font.Gotham
	parent2.TextSize = 9
	parent2.TextColor3 = Settings.TEXT_DIM
	parent2.TextXAlignment = Enum.TextXAlignment.Left
	parent2.TextWrapped = true
	parent2.AutomaticSize = Enum.AutomaticSize.Y
	parent2.Text = "Chords of 3+ notes show only 2; the extra notes are hit automatically. Score is unchanged."
	parent2.Visible = v9
	parent2.ZIndex = 11
	parent2.Parent = result

	local v17 = {
		Refresh = function()
			refreshLink() -- inferred equivalent call
			slider3.Refresh()
			slider4.Refresh()
			slider6.Refresh()
			slider7.Refresh()
		end
	}

	result = makeCard(gameplay)
	makeSectionLabel(result, "More Options")
	v8.Shake = makeToggleRow(result, "Camera Shake", SettingsState.GetShakeEnabled, function(p)
		SettingsState.SetShakeEnabled(p)
		v8.Toast:Show(p and "Camera Shake Enabled" or "Camera Shake Disabled")
	end)

	v8.StarPowerCard = makeCard(gameplay)
	makeSectionLabel(v8.StarPowerCard, "Star Power")
	v8.AutoStarPower = makeToggleRow(
		v8.StarPowerCard,
		"Auto-activate Star Power",
		SettingsState.GetAutoStarPower,
		function(p)
			SettingsState.SetAutoStarPower(p)
			v8.Toast:Show(p and "Auto-activate Star Power Enabled" or "Auto-activate Star Power Disabled")
		end
	)
	makeComingSoonRow(result, "Performance Mode")

	v8.ResetFooter = Instance.new("Frame")
	v8.ResetFooter.Name = "ResetFooter"
	v8.ResetFooter.Position = UDim2.new(0, 10, 1, -44)
	v8.ResetFooter.Size = UDim2.new(1, -20, 0, 28)
	v8.ResetFooter.BackgroundTransparency = 1
	v8.ResetFooter.ZIndex = 11
	v8.ResetFooter.Parent = dropdown
	content.Size = UDim2.new(1, -20, 1, -134)

	local resetAllBtn = Instance.new("TextButton")
	resetAllBtn.Name = "ResetAllBtn"
	resetAllBtn.Size = UDim2.new(1, 0, 1, 0)
	resetAllBtn.BackgroundColor3 = Settings.DANGER
	resetAllBtn.Text = "Reset All"
	resetAllBtn.TextColor3 = Settings.TEXT
	resetAllBtn.Font = Enum.Font.GothamBold
	resetAllBtn.TextSize = 11
	resetAllBtn.ZIndex = 11
	resetAllBtn.Parent = v8.ResetFooter

	result = Instance.new("UICorner")
	result.CornerRadius = udim
	result.Parent = resetAllBtn

	result = v13.Controls

	v9 = makeCard(result)
	makeSectionLabel(v9, "Timing")

	v8.AudioOffsetStepper = v8.MakeStepperRow(
		v9,
		"Audio Offset",
		"If notes feel out of sync with what you hear (common with Bluetooth audio or a TV), nudge this - or use Calibrate below to auto-detect it.",
		-500,
		500,
		1,
		" ms",
		SettingsState.GetAudioOffsetMs,
		function(p)
			SettingsState.SetAudioOffsetMs(p)
		end,
		1
	)

	parent2 = Instance.new("TextButton")
	parent2.Name = "CalibrateBtn"
	parent2.LayoutOrder = 2
	parent2.Size = UDim2.new(1, 0, 0, 34)
	parent2.BackgroundColor3 = Settings.ACCENT
	parent2.Text = "Calibrate Timing"
	parent2.TextColor3 = Settings.DARKTEXT
	parent2.Font = Enum.Font.GothamBold
	parent2.TextSize = 12
	parent2.ZIndex = 11
	parent2.Parent = v9

	calibrateCaption = Instance.new("UICorner")
	calibrateCaption.CornerRadius = udim
	calibrateCaption.Parent = parent2

	calibrateCaption = Instance.new("TextLabel")
	calibrateCaption.Name = "CalibrateCaption"
	calibrateCaption.LayoutOrder = 3
	calibrateCaption.Size = UDim2.new(1, 0, 0, 14)
	calibrateCaption.BackgroundTransparency = 1
	calibrateCaption.Font = Enum.Font.Gotham
	calibrateCaption.TextSize = 9
	calibrateCaption.TextColor3 = Settings.TEXT_DIM
	calibrateCaption.TextXAlignment = Enum.TextXAlignment.Center
	calibrateCaption.TextWrapped = true
	calibrateCaption.AutomaticSize = Enum.AutomaticSize.Y
	calibrateCaption.Text = "Tap along to a short beat and we'll set the offset for you."
	calibrateCaption.ZIndex = 11
	calibrateCaption.Parent = v9

	parent2.MouseButton1Click:Connect(function()
		v8.AudioCalibrateUI.Show()
	end)

	local actionRows = {}
	local actionRows2 = {}
	local v18 = nil

	do
		local card2 = makeCard(result)
		makeSectionLabel(card2, "Input Device").LayoutOrder = 1
		local v19 = {}

		local function makeChoiceRow(layoutOrder, text, list, fn2, fn3, p)
			local choiceRow = Instance.new("Frame")
			choiceRow.Name = "ChoiceRow"
			choiceRow.Size = UDim2.new(1, 0, 0, 46)
			choiceRow.BackgroundTransparency = 1
			choiceRow.LayoutOrder = layoutOrder
			choiceRow.ZIndex = 11
			choiceRow.Parent = p or card2

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 0, 14)
			textLabel.BackgroundTransparency = 1
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextSize = 11
			textLabel.TextColor3 = Settings.TEXT
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.Text = text
			textLabel.ZIndex = 11
			textLabel.Parent = choiceRow

			local frame = Instance.new("Frame")
			frame.Position = UDim2.new(0, 0, 0, 18)
			frame.Size = UDim2.new(1, 0, 0, 26)
			frame.BackgroundTransparency = 1
			frame.ZIndex = 11
			frame.Parent = choiceRow
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.FillDirection = Enum.FillDirection.Horizontal
			uiListLayout.Padding = UDim.new(0, 4)
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Parent = frame

			local v20 = {}

			for i, item in ipairs(list) do
				local textButton = Instance.new("TextButton")
				textButton.Name = item .. "Choice"
				textButton.LayoutOrder = i
				textButton.Size = UDim2.new(0, 96, 0, 26)
				textButton.BackgroundColor3 = Settings.BTN
				textButton.AutoButtonColor = true
				textButton.Text = item
				textButton.TextColor3 = Settings.TEXT
				textButton.Font = Enum.Font.GothamBold
				textButton.TextSize = 10
				textButton.ZIndex = 11
				textButton.Parent = frame

				local image = ({
					Keyboard = "rbxassetid://121332782788896",
					Controller = "rbxassetid://12684121161"
				})[item]

				if image then
					local uiPadding = Instance.new("UIPadding")
					uiPadding.PaddingLeft = UDim.new(0, 22)
					uiPadding.Parent = textButton
					local deviceIcon = Instance.new("ImageLabel")
					deviceIcon.Name = "DeviceIcon"
					deviceIcon.BackgroundTransparency = 1
					deviceIcon.Position = UDim2.new(0, -18, 0.5, -9)
					deviceIcon.Size = UDim2.fromOffset(18, 18)
					deviceIcon.Image = image
					deviceIcon.ScaleType = Enum.ScaleType.Fit
					deviceIcon.ZIndex = 12
					deviceIcon.Parent = textButton
				end

				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = udim
				uiCorner.Parent = textButton
				v20[item] = textButton
				textButton.MouseButton1Click:Connect(function()
					fn3(item)

					for _, v21 in ipairs(v19) do
						v21()
					end

					if v8.RefreshKeybindDisplay then
						v8.RefreshKeybindDisplay()
					end
				end)
			end

			local function refresh()
				local v21 = fn2()

				for k, v22 in pairs(v20) do
					v22.BackgroundColor3 = k == v21 and Settings.ACCENT or Settings.BTN
				end
			end
			table.insert(v19, refresh)
			refresh()
		end

		makeChoiceRow(2, "Mode", { "Auto", "Keyboard", "Controller" }, function()
			return SettingsState.GetInputModeSetting()
		end, function(p)
			SettingsState.SetField("InputMode", p, true)
			SettingsState.SetField("InputModeChosen", true, true)
		end)

		makeChoiceRow(3, "Button icons (Controller)", { "Auto", "Xbox", "PlayStation" }, function()
			return SettingsState.GetControllerGlyphStyle()
		end, function(p)
			SettingsState.SetField("ControllerGlyphStyle", p, true)
		end)

		v9 = Instance.new("TextLabel")
		v9.Name = "InputNote"
		v9.Size = UDim2.new(1, 0, 0, 22)
		v9.BackgroundTransparency = 1
		v9.Font = Enum.Font.Gotham
		v9.TextSize = 9
		v9.TextColor3 = Settings.TEXT_DIM
		v9.TextWrapped = true
		v9.AutomaticSize = Enum.AutomaticSize.Y
		v9.TextXAlignment = Enum.TextXAlignment.Left
		v9.Text = "Auto: console uses Controller, other devices use Keyboard. Keyboard and Controller keybinds are saved separately, so switching never overwrites the other set."
		v9.ZIndex = 11
		v9.LayoutOrder = 4
		v9.Parent = card2

		function v8.RefreshInputCard()
			for _, v20 in ipairs(v19) do
				v20()
			end
		end

		v9 = makeCard(result)
		makeSectionLabel(v9, "Controller Vibration")
		v8.VibrationToggle = makeToggleRow(v9, "Vibration (Wrong, invite, countdown)", function()
			return SettingsState.IsVibrationEnabled()
		end, function(p)
			SettingsState.SetField("VibrationEnabled", p, true)
		end)

		v9 = require
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local v20 = v9(ReplicatedStorage2.Modules.ControllerPresets)
		v9 = makeCard(result)
		makeSectionLabel(v9, "Controller Layout").LayoutOrder = 1
		v8.LayoutCard = v9

		local presetNote = Instance.new("TextLabel")
		presetNote.Name = "PresetNote"
		presetNote.Size = UDim2.new(1, 0, 0, 22)
		presetNote.BackgroundTransparency = 1
		presetNote.Font = Enum.Font.Gotham
		presetNote.TextSize = 9
		presetNote.TextColor3 = Settings.TEXT_DIM
		presetNote.TextWrapped = true
		presetNote.AutomaticSize = Enum.AutomaticSize.Y
		presetNote.TextXAlignment = Enum.TextXAlignment.Left
		presetNote.ZIndex = 11
		presetNote.LayoutOrder = 3
		presetNote.Parent = v9

		makeChoiceRow(2, "Layout (replaces your controller keybinds)", v20.Order, function()
			return SettingsState.GetControllerType()
		end, function(p)
			v20.Apply(SettingsState, p)
		end, v9)

		local function refreshPresetNote() -- 1 equivalent call inferred from this helper
			presetNote.Text = v20.Descriptions[SettingsState.GetControllerType()] or ""
		end
		table.insert(v19, refreshPresetNote)
		refreshPresetNote() -- inferred equivalent call
	end

	do
		local v19 = { 1, 2, 3, 4, 5, "DoublePedal" }
		local v20 = nil
		parent2 = makeActionRow(v9, "Quick Setup", "Start", nil)

		if parent2.Parent and parent2.Parent:IsA("GuiObject") then
			parent2.Parent.LayoutOrder = 4
		end

		local quickSetupPrompt = Instance.new("TextLabel")
		quickSetupPrompt.Name = "QuickSetupPrompt"
		quickSetupPrompt.Size = UDim2.new(1, 0, 0, 22)
		quickSetupPrompt.BackgroundTransparency = 1
		quickSetupPrompt.Font = Enum.Font.GothamBold
		quickSetupPrompt.TextSize = 10
		quickSetupPrompt.TextColor3 = Settings.WARNING
		quickSetupPrompt.TextWrapped = true
		quickSetupPrompt.AutomaticSize = Enum.AutomaticSize.Y
		quickSetupPrompt.TextXAlignment = Enum.TextXAlignment.Left
		quickSetupPrompt.Text = "Press Start, then hit each pad / fret in order."
		quickSetupPrompt.ZIndex = 11
		quickSetupPrompt.LayoutOrder = 5
		quickSetupPrompt.Parent = v9

		local function laneLabel(p)
			if p == "DoublePedal" then
				return "Double Pedal (second kick)"
			end

			local drum = SettingsState.GetControllerType() == "Drums" and RhythmEngineConfig.LaneNames.Drum
				or RhythmEngineConfig.LaneNames.GuitarLead
			return string.format("Lane %d (%s)", p, drum and drum[p] or "?")
		end

		do
			local function showQuickPrompt() -- 2 equivalent calls inferred from this helper
				local v21 = v20 and v19[v20]

				if v21 then
					quickSetupPrompt.Text = string.format("Step %d/%d: hit the pad for %s", v20, #v19, laneLabel(v21))
				else
					quickSetupPrompt.Text = "Press Start, then hit each pad / fret in order."
				end
			end
		end

		function v8.QuickSetupAdvance()
			if not v20 then
				return
			end

			v20 += 1
			local v21 = v19[v20]

			if v21 then
				v7 = v21
				showQuickPrompt() -- inferred equivalent call
			else
				v20 = nil
				quickSetupPrompt.Text = "Done! Your layout is saved."
			end
		end
		function v8.QuickSetupCancel()
			if v20 then
				v20 = nil
				quickSetupPrompt.Text = "Quick Setup cancelled (that button is already used). Press Start to retry."
			end
		end
		parent2.MouseButton1Click:Connect(function()
			v20 = 1
			v7 = v19[1]
			showQuickPrompt() -- inferred equivalent call
		end)
	end

	function v8.KeyDisplay(p)
		local success2, result2 = pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			return require(ReplicatedStorage2.Modules.ControllerGlyphs).Display(p)
		end)

		if success2 and result2 then
			return result2
		end

		return p and p.Name or "?"
	end

	local card2 = makeCard(result)
	makeSectionLabel(card2, "Preset Keybind").LayoutOrder = 1

	local presetRow = Instance.new("Frame")
	presetRow.Name = "PresetRow"
	presetRow.Size = UDim2.new(1, 0, 0, 26)
	presetRow.BackgroundTransparency = 1
	presetRow.ZIndex = 11
	presetRow.LayoutOrder = 2
	presetRow.Parent = card2

	v9 = Instance.new("UIListLayout")
	v9.FillDirection = Enum.FillDirection.Horizontal
	v9.Padding = UDim.new(0, 4)
	v9.Parent = presetRow

	local function refreshKeybindDisplay()
		local keybindFiveKey = SettingsState.GetKeybindFiveKey()

		for i, v19 in ipairs(actionRows) do
			local v20 = keybindFiveKey and keybindFiveKey[i]
			v19.Text = v20 and v8.KeyDisplay(v20) or "?"
		end

		local keybindTwoKey = SettingsState.GetKeybindTwoKey()

		for i, v19 in ipairs(actionRows2) do
			local v20 = keybindTwoKey and keybindTwoKey[i]
			v19.Text = v20 and v8.KeyDisplay(v20) or "?"
		end

		if v18 then
			local doublePedalKeyNormal = SettingsState.GetDoublePedalKeyNormal()
			v18.Text = doublePedalKeyNormal and v8.KeyDisplay(doublePedalKeyNormal) or "?"
		end

		local isControllerMode = SettingsState.IsControllerMode()
		card2.Visible = not isControllerMode

		if v8.LayoutCard then
			v8.LayoutCard.Visible = isControllerMode
		end

		if v8.FiveKeyTitle then
			v8.FiveKeyTitle.Text = isControllerMode and "Controller Keybind (5-Key)" or "Keyboard Keybind (5-Key)"
		end

		if v8.RefreshInputCard then
			v8.RefreshInputCard()
		end

		if v8.VibratoRebind then
			v8.VibratoRebind.Text = SettingsState.GetVibratoBindingDisplay()
		end

		if v8.StarPowerRebind then
			v8.StarPowerRebind.Text = SettingsState.GetStarPowerBindingDisplay()
		end
	end

	v8.RefreshKeybindDisplay = refreshKeybindDisplay

	do
		local function makePresetButton(text, list, list2)
			local textButton = Instance.new("TextButton")
			textButton.Name = text .. "Preset"
			textButton.Size = UDim2.new(0, 90, 0, 26)
			textButton.BackgroundColor3 = Settings.BTN
			textButton.Text = text
			textButton.TextColor3 = Settings.TEXT
			textButton.Font = Enum.Font.GothamBold
			textButton.TextSize = 10
			textButton.ZIndex = 11
			textButton.Parent = presetRow

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = udim
			uiCorner.Parent = textButton

			textButton.MouseButton1Click:Connect(function()
				SettingsState.SetField("KeybindFiveKey", list)
				SettingsState.SetField("KeybindTwoKey", list2)

				local starPowerBindingName = SettingsState.GetStarPowerBindingName()
				local flag3 = false

				for _, item in ipairs(list) do
					if item == starPowerBindingName then
						flag3 = true
					end
				end

				for _, item in ipairs(list2) do
					if item == starPowerBindingName then
						flag3 = true
					end
				end

				if flag3 then
					SettingsState.SetField("KeybindStarPower", "H", true)

					if v8.Toast then
						v8.Toast:Show("Star Power key moved to H (it clashed with a lane key)")
					end
				end

				refreshKeybindDisplay()
			end)
		end

		makePresetButton("XCVBN (Default)", { "X", "C", "V", "B", "N" }, { "F", "J" })
		makePresetButton("ASJKL (Classic)", { "A", "S", "J", "K", "L" }, { "A", "L" })
		makePresetButton("←↓↑→ Space", { "Left", "Down", "Up", "Right", "Space" }, { "Left", "Right" })
	end

	v9 = Instance.new("TextLabel")
	v9.Name = "PresetNote"
	v9.Size = UDim2.new(1, 0, 0, 22)
	v9.BackgroundTransparency = 1
	v9.Font = Enum.Font.Gotham
	v9.TextSize = 9
	v9.TextColor3 = Settings.TEXT_DIM
	v9.TextWrapped = true
	v9.AutomaticSize = Enum.AutomaticSize.Y
	v9.TextXAlignment = Enum.TextXAlignment.Left
	v9.Text = "Movement keys matching your keybind are locked only while playing a song."
	v9.ZIndex = 11
	v9.LayoutOrder = 3
	v9.Parent = card2

	do
		local card3 = makeCard(result)
		v8.FiveKeyTitle = makeSectionLabel(card3, "Keyboard Keybind (5-Key)")

		for i = 1, 5 do
			local actionRow = makeActionRow(card3, "Lane " .. i, "...", nil)
			table.insert(actionRows, actionRow)
			actionRow.MouseButton1Click:Connect(function()
				v7 = i
				actionRow.Text = SettingsState.IsControllerMode() and "Press a button..." or "Press a key..."
			end)
		end
	end

	do
		local card3 = makeCard(result)
		makeSectionLabel(card3, "2-Key (Mobile, 2-Thumb)")

		for i = 1, 2 do
			local actionRow = makeActionRow(card3, "Slot " .. i, "...", nil)
			table.insert(actionRows2, actionRow)
			actionRow.MouseButton1Click:Connect(function()
				v7 = "TwoKey" .. i
				actionRow.Text = SettingsState.IsControllerMode() and "Press a button..." or "Press a key..."
			end)
		end
	end

	v9 = makeCard(result)
	makeSectionLabel(v9, "Double Pedal (Drum)")
	v18 = makeActionRow(v9, "Double Pedal", "...", function()
		v7 = "DoublePedal"
	end)

	v9 = makeCard(result)
	makeSectionLabel(v9, "Vibrato (Guitar/Bass, Rhythm)")

	v8.VibratoRebind = makeActionRow(v9, "Vibrato Key", "...", function()
		v7 = "Vibrato"
		v8.VibratoRebind.Text = "Press input..."
	end)

	makeActionRow(v9, "Default: Left Ctrl", "Reset", function()
		v7 = nil
		SettingsState.SetField("KeybindVibratoRhythm", "LeftControl")
		refreshKeybindDisplay()
	end)

	parent2 = Instance.new("TextLabel")
	parent2.Name = "VibratoNote"
	parent2.Size = UDim2.new(1, 0, 0, 46)
	parent2.BackgroundTransparency = 1
	parent2.Font = Enum.Font.Gotham
	parent2.TextSize = 9
	parent2.TextColor3 = Settings.TEXT_DIM
	parent2.TextWrapped = true
	parent2.AutomaticSize = Enum.AutomaticSize.Y
	parent2.TextXAlignment = Enum.TextXAlignment.Left
	parent2.TextYAlignment = Enum.TextYAlignment.Top
	parent2.Text = "Press a keyboard key, Right/Middle Click or a controller button. Used in Rhythm mode while holding a hold note; Free Play keeps Left Ctrl. Left Click is reserved, and the key can't be one of your lane keys."
	parent2.ZIndex = 11
	parent2.Parent = v9

	v9 = makeCard(result)
	makeSectionLabel(v9, "Star Power (Rhythm)")

	v8.StarPowerRebind = makeActionRow(v9, "Star Power Key", "...", function()
		v7 = "StarPower"
		v8.StarPowerRebind.Text = "Press input..."
	end)

	makeActionRow(v9, "Default: Space", "Reset", function()
		v7 = nil
		local v19 = false

		for _, v20 in ipairs(SettingsState.GetKeybindFiveKey()) do
			if v20 == Enum.KeyCode.Space then
				v19 = true
			end
		end

		for _, v20 in ipairs(SettingsState.GetKeybindTwoKey()) do
			if v20 == Enum.KeyCode.Space then
				v19 = true
			end
		end

		if v19 or SettingsState.GetVibratoBindingName() == "Space" then
			if v8.Toast then
				v8.Toast:Show("Space is already used by a lane/vibrato key")
			end
		else
			SettingsState.SetField("KeybindStarPower", "Space")
		end

		refreshKeybindDisplay()
	end)

	result = Instance.new("TextLabel")
	result.Name = "StarPowerNote"
	result.Size = UDim2.new(1, 0, 0, 46)
	result.BackgroundTransparency = 1
	result.Font = Enum.Font.Gotham
	result.TextSize = 9
	result.TextColor3 = Settings.TEXT_DIM
	result.TextWrapped = true
	result.AutomaticSize = Enum.AutomaticSize.Y
	result.TextXAlignment = Enum.TextXAlignment.Left
	result.TextYAlignment = Enum.TextYAlignment.Top
	result.Text = "Press a keyboard key, Right/Middle Click or a controller button. Activates Star Power while a song is playing. Left Click is reserved, and the key can't be one of your lane keys or your vibrato key."
	result.ZIndex = 11
	result.Parent = v9

	local set = {
		[Enum.KeyCode.Escape] = true,
		[Enum.KeyCode.Backspace] = true,
		[Enum.KeyCode.Return] = true
	}

	local visual = v13.Visual

	v8.PerfCard = makeCard(visual)
	v8.PerfCard.LayoutOrder = -1
	makeSectionLabel(v8.PerfCard, "Performance Display")
	v8.ShowPerfStats = makeToggleRow(v8.PerfCard, "Show FPS & Ping", SettingsState.GetShowPerfStats, function(p)
		SettingsState.SetShowPerfStats(p)
		v8.Toast:Show(p and "FPS & Ping Display Shown" or "FPS & Ping Display Hidden")
	end)

	result = makeCard(visual)
	makeSectionLabel(result, "Theme")

	do
		local function uiStyleLabel(): string -- 4 equivalent calls inferred from this helper
			if SettingsState.GetUIStyle() == "NewUI" then
				return "New UI"
			end

			return "Default"
		end

		local actionRow = makeActionRow(result, "UI Style", uiStyleLabel(), function() end) -- inferred equivalent call
		actionRow.MouseButton1Click:Connect(function()
			local v19 = SettingsState.GetUIStyle() == "NewUI" and "Default" or "NewUI"
			SettingsState.SetUIStyle(v19)
			actionRow.Text = uiStyleLabel() -- inferred equivalent call

			if v8.Toast then
				v8.Toast:Show("UI style: " .. uiStyleLabel()) -- inferred equivalent call
			end
		end)
		SettingsState.OnChanged(function()
			actionRow.Text = uiStyleLabel() -- inferred equivalent call
		end)
	end

	result = makeCard(visual)
	makeSectionLabel(result, "Camera")
	local slider8 = makeSlider(
		result,
		"First Person FOV",
		60,
		120,
		v6.FirstPersonFOV,
		SessionCameraSettings.GetFirstPersonFOV,
		function(p)
			SessionCameraSettings.SetFirstPersonFOV((math.floor(p)))
		end,
		function(p)
			return (tostring((math.floor(p))))
		end
	)

	do
		local card3 = makeCard(visual)
		makeSectionLabel(card3, "HUD Opacity")

		do
			local HudPreview = require(ReplicatedStorage.Modules.HudPreview)
			result = Instance.new("Frame")
			result.Name = "PreviewRow"
			result.Size = UDim2.new(1, 0, 0, 34)
			result.BackgroundTransparency = 1
			result.ZIndex = 11
			result.Parent = card3

			v9 = Instance.new("TextLabel")
			v9.Name = "Title"
			v9.Position = UDim2.new(0, 0, 0, 2)
			v9.Size = UDim2.new(1, -100, 0, 14)
			v9.BackgroundTransparency = 1
			v9.Font = Enum.Font.GothamBold
			v9.TextSize = 13
			v9.TextColor3 = Settings.ACCENT
			v9.TextXAlignment = Enum.TextXAlignment.Left
			v9.Text = "Live Preview"
			v9.ZIndex = 11
			v9.Parent = result

			v9 = Instance.new("TextLabel")
			v9.Name = "Subtitle"
			v9.Position = UDim2.new(0, 0, 0, 18)
			v9.Size = UDim2.new(1, -100, 0, 14)
			v9.BackgroundTransparency = 1
			v9.Font = Enum.Font.Gotham
			v9.TextSize = 9
			v9.TextColor3 = Settings.TEXT_DIM
			v9.TextXAlignment = Enum.TextXAlignment.Left
			v9.TextTruncate = Enum.TextTruncate.AtEnd
			v9.Text = "See the HUD with sample data"
			v9.ZIndex = 11
			v9.Parent = result

			local previewBtn = Instance.new("TextButton")
			previewBtn.Name = "PreviewBtn"
			previewBtn.AnchorPoint = Vector2.new(1, 0.5)
			previewBtn.Position = UDim2.new(1, 0, 0.5, 0)
			previewBtn.Size = UDim2.new(0, 92, 0, 28)
			previewBtn.BackgroundColor3 = Settings.BTN
			previewBtn.Text = "Preview"
			previewBtn.TextColor3 = Settings.TEXT
			previewBtn.Font = Enum.Font.GothamBold
			previewBtn.TextSize = 10
			previewBtn.ZIndex = 11
			previewBtn.Parent = result
			result = Instance.new("UICorner")
			result.CornerRadius = udim
			result.Parent = previewBtn

			local previewHint = Instance.new("TextLabel")
			previewHint.Name = "PreviewHint"
			previewHint.Size = UDim2.new(1, 0, 0, 12)
			previewHint.BackgroundTransparency = 1
			previewHint.Font = Enum.Font.Gotham
			previewHint.TextSize = 9
			previewHint.TextColor3 = Settings.TEXT_DIM
			previewHint.TextXAlignment = Enum.TextXAlignment.Left
			previewHint.TextWrapped = true
			previewHint.AutomaticSize = Enum.AutomaticSize.Y
			previewHint.Text = "Preview unavailable while a song is playing or another preview is on"
			previewHint.Visible = false
			previewHint.ZIndex = 11
			previewHint.Parent = card3

			do
				local function refreshPreviewButton2() -- 2 equivalent calls inferred from this helper
					local isActive = HudPreview.IsActive()
					local v19 = isActive or HudPreview.CanStart()
					previewBtn.Text = isActive and "Preview ON" or "Preview"

					if isActive then
						previewBtn.BackgroundColor3 = Settings.ACCENT
						previewBtn.TextColor3 = Settings.DARKTEXT
					else
						previewBtn.BackgroundColor3 = Settings.BTN
						previewBtn.TextColor3 = v19 and Settings.TEXT or Settings.TEXT_DIM
					end

					previewHint.Visible = not v19
				end

				previewBtn.MouseButton1Click:Connect(function()
					if HudPreview.IsActive() then
						HudPreview.Stop()
					elseif HudPreview.CanStart() then
						HudPreview.Start()
					end

					refreshPreviewButton2() -- inferred equivalent call
				end)

				HudPreview.OnStopped(refreshPreviewButton2)
			end

			visual:GetPropertyChangedSignal("Visible"):Connect(function()
				if not visual.Visible then
					HudPreview.Stop()
				end
			end)
			dropdown:GetPropertyChangedSignal("Visible"):Connect(function()
				if not (dropdown.Visible or LayoutEditorUI.IsOpen()) then
					HudPreview.Stop()
				end
			end)
			task.spawn(function()
				while true do
					task.wait(0.3)

					if dropdown.Visible and visual.Visible then
						refreshPreviewButton2() -- inferred equivalent call
					end
				end
			end)
		end

		v8.OpacitySliders = {}

		do
			local rows = {}
			local row = nil

			local function applyLinkedVisibility() -- 3 equivalent calls inferred from this helper
				local hudOpacityLinked = SettingsState.GetHudOpacityLinked()

				if row then
					row.Visible = hudOpacityLinked
				end

				for _, v19 in ipairs(rows) do
					v19.Visible = not hudOpacityLinked
				end
			end

			do
				local function percentText(p)
					return tostring((math.floor(p * 100 + 0.5))) .. "%"
				end

				local toggleRow = makeToggleRow(
					card3,
					"Control all with one slider",
					SettingsState.GetHudOpacityLinked,
					function(p)
						SettingsState.SetField("HudOpacityLinked", p)
						applyLinkedVisibility() -- inferred equivalent call
					end
				)
				result = makeSlider(card3, "All HUD", 0.1, 1, v6.HudOpacityAll, function()
					return SettingsState.GetHudOpacityAll()
				end, function(p)
					SettingsState.SetField("HudOpacityAll", math.floor(p * 100 + 0.5) / 100)
				end, percentText)

				row = result.Row
				table.insert(v8.OpacitySliders, result)

				do
					local function addOpacitySlider(p, p2, p3)
						local slider9 = makeSlider(card3, p, 0.1, 1, v6[p2], function()
							return SettingsState.GetOpacity(p3)
						end, function(p4)
							SettingsState.SetField(p2, math.floor(p4 * 100 + 0.5) / 100)
						end, percentText)

						table.insert(v8.OpacitySliders, slider9)
						table.insert(rows, slider9.Row)
					end

					addOpacitySlider("Stats HUD", "HudOpacity", "Hud")
					addOpacitySlider("Star Power Bar", "StarPowerBarOpacity", "StarPower")
					addOpacitySlider("Band Score Feed", "BandFeedOpacity", "BandFeed")
					addOpacitySlider("Streak Notice", "StreakNoticeOpacity", "StreakNotice")
				end

				local row2 = nil
				local function applyContentVisibility() -- 3 equivalent calls inferred from this helper
					if row2 then
						row2.Visible = SettingsState.GetHudKeepContentClear()
					end
				end
				local toggleRow2 = makeToggleRow(
					card3,
					"Keep important content clear",
					SettingsState.GetHudKeepContentClear,
					function(p)
						SettingsState.SetField("HudKeepContentClear", p)
						applyContentVisibility() -- inferred equivalent call
					end
				)
				result = makeSlider(card3, "Content Opacity", 0.1, 1, v6.HudContentOpacity, function()
					return SettingsState.GetHudContentOpacity()
				end, function(p)
					SettingsState.SetField("HudContentOpacity", math.floor(p * 100 + 0.5) / 100)
				end, percentText)

				row2 = result.Row
				table.insert(v8.OpacitySliders, result)
				applyContentVisibility() -- inferred equivalent call
				table.insert(v8.OpacitySliders, {
					Refresh = function()
						toggleRow.Refresh()
						applyLinkedVisibility() -- inferred equivalent call
						toggleRow2.Refresh()
						applyContentVisibility() -- inferred equivalent call
					end
				})
			end

			applyLinkedVisibility() -- inferred equivalent call
		end

		result = Instance.new("TextLabel")
		result.Name = "OpacityHint"
		result.Size = UDim2.new(1, 0, 0, 0)
		result.AutomaticSize = Enum.AutomaticSize.Y
		result.BackgroundTransparency = 1
		result.Font = Enum.Font.Gotham
		result.TextSize = 10
		result.TextColor3 = Settings.TEXT_DIM
		result.TextWrapped = true
		result.TextXAlignment = Enum.TextXAlignment.Left
		result.Text = "Stats HUD = Rock Meter, live score/multiplier, live stats (notes hit / accuracy), vibrato, and band score panel. 100% = fully solid; lower = more transparent. Tick \"Control all with one slider\" to use a single slider for everything. With \"Keep important content clear\", numbers, key text, bar fills and indicator colors stay readable while only the decoration fades."
		result.ZIndex = 11
		result.Parent = card3
	end

	result = makeCard(visual)
	makeSectionLabel(result, "Free Play")

	do
		local slider9 = makeSlider(
			result,
			"Keyboard Opacity",
			0.2,
			1,
			v6.FreePlayOpacity,
			SettingsState.GetFreePlayOpacity,
			function(p)
				SettingsState.SetField("FreePlayOpacity", math.floor(p * 100 + 0.5) / 100)
			end,
			function(p)
				return tostring((math.floor(p * 100 + 0.5))) .. "%"
			end
		)

		table.insert(v8.OpacitySliders, slider9)
	end

	v9 = Instance.new("TextLabel")
	v9.Name = "FreePlayOpacityHint"
	v9.Size = UDim2.new(1, 0, 0, 0)
	v9.AutomaticSize = Enum.AutomaticSize.Y
	v9.BackgroundTransparency = 1
	v9.Font = Enum.Font.Gotham
	v9.TextSize = 10
	v9.TextColor3 = Settings.TEXT_DIM
	v9.TextWrapped = true
	v9.TextXAlignment = Enum.TextXAlignment.Left
	v9.Text = "How solid the Free Play keyboard looks. Lower = more see-through, higher = more solid. Applies to the New UI style."
	v9.ZIndex = 11
	v9.Parent = result

	result = makeCard(visual)
	makeSectionLabel(result, "More Options")
	v8.HitEffect = makeToggleRow(result, "Hit Effect: Screen Glow", SettingsState.GetHitEffectEnabled, function(p)
		SettingsState.SetHitEffectEnabled(p)
		v8.Toast:Show(p and "Hit Effect: Screen Glow Enabled" or "Hit Effect: Screen Glow Disabled")
	end)
	v8.HitSparkle = makeToggleRow(result, "Hit Effect: Sparkles", SettingsState.GetHitSparkleEnabled, function(p)
		SettingsState.SetHitSparkleEnabled(p)
		v8.Toast:Show(p and "Hit Effect: Sparkles Enabled" or "Hit Effect: Sparkles Disabled")
	end)
	v8.JudgmentPop = makeToggleRow(
		result,
		"Judgment Text: Pop Animation",
		SettingsState.GetJudgmentPopEnabled,
		function(p)
			SettingsState.SetJudgmentPopEnabled(p)
			v8.Toast:Show(p and "Judgment Text: Pop Animation Enabled" or "Judgment Text: Pop Animation Disabled")
		end
	)

	result = makeCard(visual)
	makeSectionLabel(result, "Judgment Text")
	v8.HideOwn = makeToggleRow(result, "Hide My Judgment Text", SettingsState.GetHideOwnJudgmentText, function(p)
		SettingsState.SetHideOwnJudgmentText(p)
		v8.Toast:Show(p and "Judgment Text: Hide Mine Enabled" or "Judgment Text: Hide Mine Disabled")
	end)
	v8.HideAll = makeToggleRow(
		result,
		"Hide Everyone's Judgment Text",
		SettingsState.GetHideAllJudgmentText,
		function(p)
			SettingsState.SetHideAllJudgmentText(p)
			v8.Toast:Show(p and "Judgment Text: Hide Everyone's Enabled" or "Judgment Text: Hide Everyone's Disabled")
		end
	)

	v8.StageLightingCard = makeCard(visual)
	makeSectionLabel(v8.StageLightingCard, "Stage Lighting")
	v8.StageLightingLite = makeToggleRow(
		v8.StageLightingCard,
		"Lite Mode (smoother on mobile)",
		SettingsState.GetStageLightingLite,
		function(p)
			SettingsState.SetStageLightingLite(p)
			v8.Toast:Show(p and "Stage Lighting: Lite Mode Enabled" or "Stage Lighting: Lite Mode Disabled")
		end
	)
	v8.StageLightingReduceFlash = makeToggleRow(
		v8.StageLightingCard,
		"Reduce Flashing (photosensitivity)",
		SettingsState.GetStageLightingReduceFlash,
		function(p)
			SettingsState.SetStageLightingReduceFlash(p)
			v8.Toast:Show(p and "Stage Lighting: Reduce Flashing Enabled" or "Stage Lighting: Reduce Flashing Disabled")
		end
	)

	task.spawn(function()
		local moderatorQuery = RemoteEvents:WaitForChild("ModeratorQuery", 30)

		if not moderatorQuery then
			return
		end

		local v19 = nil

		for _ = 1, 6 do
			local success2, result2 = pcall(function()
				return moderatorQuery:InvokeServer("Init")
			end)

			if success2 and typeof(result2) == "table" then
				v19 = result2
				break
			end

			task.wait(2)
		end

		if typeof(v19) ~= "table" or (v19.Tier or 0) < 1 and v19.IsTester ~= true then
			return
		end

		local v20 = v19.IsTester and "TEST" or "MODS"
		v8.ModeratorCard = makeCard(visual)
		v8.ModeratorCard.LayoutOrder = 100
		makeSectionLabel(v8.ModeratorCard, v19.IsTester and "Tester" or "Moderator")
		v8.ShowModsButton = makeToggleRow(
			v8.ModeratorCard,
			"Show " .. v20 .. " Button",
			SettingsState.GetShowModsButton,
			function(p)
				SettingsState.SetShowModsButton(p)
				v8.Toast:Show(p and v20 .. " Button Shown" or v20 .. " Button Hidden")
			end
		)
	end)

	local colorPickerOverlay = Instance.new("Frame")
	colorPickerOverlay.Name = "ColorPickerOverlay"
	colorPickerOverlay.Size = UDim2.new(1, 0, 1, 0)
	colorPickerOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	colorPickerOverlay.BackgroundTransparency = 0.5
	colorPickerOverlay.Visible = false
	colorPickerOverlay.Active = true
	colorPickerOverlay.ZIndex = 50
	colorPickerOverlay.Parent = settingsMenuUI

	local colorPickerPanel = Instance.new("Frame")
	colorPickerPanel.Name = "ColorPickerPanel"
	colorPickerPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	colorPickerPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	colorPickerPanel.Size = UDim2.new(0, 230, 0, 300)
	colorPickerPanel.BackgroundColor3 = Settings.CARD
	colorPickerPanel.ZIndex = 51
	colorPickerPanel.Parent = colorPickerOverlay

	result = Instance.new("UICorner")
	result.CornerRadius = v4
	result.Parent = colorPickerPanel

	result = Instance.new("UIStroke")
	result.Color = Settings.BORDER
	result.Thickness = 1
	result.Parent = colorPickerPanel

	result = Instance.new("UIPadding")
	result.PaddingTop = UDim.new(0, 12)
	result.PaddingBottom = UDim.new(0, 12)
	result.PaddingLeft = UDim.new(0, 12)
	result.PaddingRight = UDim.new(0, 12)
	result.Parent = colorPickerPanel

	result = Instance.new("UIListLayout")
	result.Padding = UDim.new(0, 6)
	result.SortOrder = Enum.SortOrder.LayoutOrder
	result.Parent = colorPickerPanel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.LayoutOrder = 1
	title.Size = UDim2.new(1, 0, 0, 16)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 12
	title.TextColor3 = Settings.TEXT
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Pick a color"
	title.ZIndex = 51
	title.Parent = colorPickerPanel

	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.LayoutOrder = 2
	preview.Size = UDim2.new(1, 0, 0, 34)
	preview.BackgroundColor3 = Color3.new(1, 1, 1)
	preview.ZIndex = 51
	preview.Parent = colorPickerPanel
	result = Instance.new("UICorner")
	result.CornerRadius = udim
	result.Parent = preview

	local backgroundColor = Color3.new(1, 1, 1)
	local v19 = 255
	local v20 = 255
	local v21 = 255
	local hexBox = nil

	do
		local function updatePreview() -- 5 equivalent calls inferred from this helper
			preview.BackgroundColor3 = backgroundColor

			if hexBox then
				hexBox.Text = string.format("#%02X%02X%02X", v19, v20, v21)
			end
		end
	end

	local slider9 = makeSlider(colorPickerPanel, "R", 0, 255, 255, function()
		return v19
	end, function(p)
		v19 = math.floor(p)
		backgroundColor = Color3.fromRGB(v19, v20, v21)
		updatePreview() -- inferred equivalent call
	end, function(p)
		return (tostring((math.floor(p))))
	end, 3)

	local slider10 = makeSlider(colorPickerPanel, "G", 0, 255, 255, function()
		return v20
	end, function(p)
		v20 = math.floor(p)
		backgroundColor = Color3.fromRGB(v19, v20, v21)
		updatePreview() -- inferred equivalent call
	end, function(p)
		return (tostring((math.floor(p))))
	end, 4)

	local slider11 = makeSlider(colorPickerPanel, "B", 0, 255, 255, function()
		return v21
	end, function(p)
		v21 = math.floor(p)
		backgroundColor = Color3.fromRGB(v19, v20, v21)
		updatePreview() -- inferred equivalent call
	end, function(p)
		return (tostring((math.floor(p))))
	end, 5)

	hexBox = Instance.new("TextBox")
	hexBox.Name = "HexBox"
	hexBox.LayoutOrder = 6
	hexBox.Size = UDim2.new(1, 0, 0, 26)
	hexBox.BackgroundColor3 = Settings.INPUT
	hexBox.TextColor3 = Settings.TEXT
	hexBox.Font = Enum.Font.Code
	hexBox.TextSize = 12
	hexBox.ClearTextOnFocus = false
	hexBox.Text = "#FFFFFF"
	hexBox.ZIndex = 51
	hexBox.Parent = colorPickerPanel
	result = Instance.new("UICorner")
	result.CornerRadius = udim
	result.Parent = hexBox

	hexBox.FocusLost:Connect(function(p)
		if not p then
			return
		end

		local v22 = hexBox.Text:gsub("#", "")

		if #v22 == 6 and v22:match("^%x+$") then
			v19 = tonumber(v22:sub(1, 2), 16)
			v20 = tonumber(v22:sub(3, 4), 16)
			v21 = tonumber(v22:sub(5, 6), 16)
			backgroundColor = Color3.fromRGB(v19, v20, v21)
			updatePreview() -- inferred equivalent call
			slider9.Refresh()
			slider10.Refresh()
			slider11.Refresh()
		end
	end)

	result = Instance.new("Frame")
	result.Name = "ButtonsRow"
	result.LayoutOrder = 7
	result.Size = UDim2.new(1, 0, 0, 30)
	result.BackgroundTransparency = 1
	result.ZIndex = 51
	result.Parent = colorPickerPanel
	v4 = Instance.new("UIListLayout")
	v4.FillDirection = Enum.FillDirection.Horizontal
	v4.Padding = UDim.new(0, 8)
	v4.SortOrder = Enum.SortOrder.LayoutOrder
	v4.Parent = result

	v4 = Instance.new("TextButton")
	v4.LayoutOrder = 1
	v4.Size = UDim2.new(0.48, 0, 1, 0)
	v4.BackgroundColor3 = Settings.BTN
	v4.Text = "Cancel"
	v4.TextColor3 = Settings.TEXT
	v4.Font = Enum.Font.GothamBold
	v4.TextSize = 11
	v4.ZIndex = 51
	v4.Parent = result
	v9 = Instance.new("UICorner")
	v9.CornerRadius = udim
	v9.Parent = v4

	v9 = Instance.new("TextButton")
	v9.LayoutOrder = 2
	v9.Size = UDim2.new(0.48, 0, 1, 0)
	v9.BackgroundColor3 = Settings.ACCENT
	v9.Text = "Apply"
	v9.TextColor3 = Color3.new(0, 0, 0)
	v9.Font = Enum.Font.GothamBold
	v9.TextSize = 11
	v9.ZIndex = 51
	v9.Parent = result
	result = Instance.new("UICorner")
	result.CornerRadius = udim
	result.Parent = v9

	local v22 = nil

	do
		local function closeColorPicker() -- 2 equivalent calls inferred from this helper
			colorPickerOverlay.Visible = false
			v22 = nil
		end

		v4.MouseButton1Click:Connect(closeColorPicker)
	end

	v9.MouseButton1Click:Connect(function()
		if v22 then
			v22(backgroundColor)
		end

		closeColorPicker() -- inferred equivalent call
	end)

	colorPickerOverlay.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local absolutePosition = colorPickerPanel.AbsolutePosition
			local absoluteSize = colorPickerPanel.AbsoluteSize
			local position = input.Position

			if
				position.X < absolutePosition.X
				or position.X > absolutePosition.X + absoluteSize.X
				or position.Y < absolutePosition.Y
				or position.Y > absolutePosition.Y + absoluteSize.Y
			then
				closeColorPicker() -- inferred equivalent call
			end
		end
	end)

	local function openColorPicker(text, backgroundColor3, fn2)
		backgroundColor = backgroundColor3
		v19 = math.floor(backgroundColor3.R * 255 + 0.5)
		v20 = math.floor(backgroundColor3.G * 255 + 0.5)
		v21 = math.floor(backgroundColor3.B * 255 + 0.5)
		title.Text = text
		updatePreview() -- inferred equivalent call
		slider9.Refresh()
		slider10.Refresh()
		slider11.Refresh()
		v22 = fn2
		colorPickerOverlay.Visible = true
	end

	local function makeColorSwatch(frame, p)
		local swatch = Instance.new("TextButton")
		swatch.Name = "Swatch"
		swatch.Size = UDim2.new(0, p, 0, p)
		swatch.Text = ""
		swatch.AutoButtonColor = false
		swatch.BackgroundColor3 = Color3.new(1, 1, 1)
		swatch.ZIndex = 11
		swatch.Parent = frame
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = swatch
		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.Color = Settings.BORDER
		uiStroke2.Thickness = 1
		uiStroke2.Parent = swatch
		return swatch
	end

	local function makeShapePreviewGem(shapePreviewRow, p, noteOuter, noteInner, rhythmShape)
		local previewGem = Instance.new("Frame")
		previewGem.Name = "PreviewGem"
		previewGem.AnchorPoint = Vector2.new(0.5, 0.5)
		previewGem.Position = UDim2.new(0.5, 0, 0.5, 0)
		previewGem.BackgroundColor3 = noteOuter
		previewGem.BorderSizePixel = 0
		previewGem.ZIndex = 12
		previewGem.Parent = shapePreviewRow
		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.Color = Color3.fromRGB(8, 8, 9)
		uiStroke2.Thickness = 2
		uiStroke2.Transparency = 0.2
		uiStroke2.Parent = previewGem
		RhythmShapeGeometry.Apply(previewGem, rhythmShape, p)

		if not noteInner then
			return previewGem
		end

		local innerGem = Instance.new("Frame")
		innerGem.Name = "InnerGem"
		innerGem.AnchorPoint = Vector2.new(0.5, 0.5)
		innerGem.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerGem.Size = UDim2.new(0.5, 0, 0.5, 0)
		innerGem.BackgroundColor3 = noteInner
		innerGem.BorderSizePixel = 0
		innerGem.ZIndex = 13
		innerGem.Parent = previewGem
		local uiCorner = previewGem:FindFirstChildOfClass("UICorner")
		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = uiCorner and uiCorner.CornerRadius or UDim.new(0, 4)
		uiCorner2.Parent = innerGem

		return previewGem
	end

	local colors = v13.Colors

	local v23 = 2

	local function randomLaneColorSet()
		local v24 = math.random()
		local v25 = 0.55 + math.random() * 0.3
		local v26 = 0.55 + math.random() * 0.3
		local color = Color3.fromHSV(v24, v25, v26)
		return {
			NoteInner = Color3.fromHSV(v24, math.max(0, v25 - 0.25), (math.min(1, v26 + 0.2))),
			NoteOuter = color,
			ReceptorRing = Color3.fromHSV(v24, v25, (math.max(0.3, v26 - 0.15))),
			ReceptorPress = Color3.fromHSV(v24, math.max(0, v25 - 0.15), (math.min(1, v26 + 0.3)))
		}
	end

	local function randomLaneSetForHue(p, p2, p3)
		local color = Color3.fromHSV(p, p2, p3)
		return {
			NoteInner = Color3.fromHSV(p, math.max(0, p2 - 0.25), (math.min(1, p3 + 0.2))),
			NoteOuter = color,
			ReceptorRing = Color3.fromHSV(p, p2, (math.max(0.3, p3 - 0.15))),
			ReceptorPress = Color3.fromHSV(p, math.max(0, p2 - 0.15), (math.min(1, p3 + 0.3)))
		}
	end

	local fn2

	local function randomizeAllLanes(p)
		local v24 = math.random()
		local v25 = {}

		for i = 1, p do
			v25[i] = randomLaneSetForHue(
				(v24 + (i - 1) / p) % 1,
				0.55 + math.random() * 0.25,
				0.6 + math.random() * 0.2
			)
		end

		SettingsState.SetRhythmLaneColorsForBucket(p, v25)
		fn2()
	end

	local v24 = {
		Classic = 0.55,
		Neon = 0.83,
		Arcade = 0.08,
		Monochrome = 0,
		Fire = 0.02,
		Ice = 0.55,
		Cyber = 0.5,
		Pastel = 0.75
	}

	local function applyPreset(p, themePresetName)
		if themePresetName == "Default" then
			SettingsState.ResetRhythmLaneSet(p)
			SettingsState.SetRhythmThemePreset("Default")
			fn2()
		else
			local v25 = v24[themePresetName] or math.random()
			local v26 = {}

			for i = 1, p do
				v26[i] = randomLaneSetForHue(
					(v25 + (i - 1) * 0.09) % 1,
					themePresetName == "Pastel" and 0.35 or themePresetName == "Monochrome" and 0.05 or 0.7,
					themePresetName == "Monochrome" and (i - 1) * 0.12 + 0.35 or 0.75
				)
			end

			SettingsState.SetRhythmLaneColorsForBucket(p, v26)
			SettingsState.SetRhythmThemePreset(themePresetName)
			fn2()
		end
	end

	do
		local function applySmartTheme(laneCountBucket) -- 1 equivalent call inferred from this helper
			randomizeAllLanes(laneCountBucket)
			SettingsState.SetRhythmJudgmentColors(RhythmCustomizationConfig.JudgmentDefaultColors)
			SettingsState.SetRhythmThemePreset("Custom")
			fn2()
		end
	end

	result = makeCard(colors)
	result.LayoutOrder = 1
	makeSectionLabel(result, "Note Shape")

	local shapeRow = Instance.new("ScrollingFrame")
	shapeRow.Name = "ShapeRow"
	shapeRow.Size = UDim2.new(1, 0, 0, 34)
	shapeRow.BackgroundTransparency = 1
	shapeRow.BorderSizePixel = 0
	shapeRow.ScrollingDirection = Enum.ScrollingDirection.X
	shapeRow.CanvasSize = UDim2.new(0, 0, 0, 0)
	shapeRow.AutomaticCanvasSize = Enum.AutomaticSize.X
	shapeRow.ScrollBarThickness = 4
	shapeRow.ScrollBarImageColor3 = Settings.TEXT_DIM
	shapeRow.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	shapeRow.ZIndex = 11
	shapeRow.Parent = result
	v4 = Instance.new("UIPadding")
	v4.PaddingLeft = UDim.new(0, 2)
	v4.PaddingRight = UDim.new(0, 2)
	v4.PaddingBottom = UDim.new(0, 6)
	v4.Parent = shapeRow
	v4 = Instance.new("UIListLayout")
	v4.FillDirection = Enum.FillDirection.Horizontal
	v4.Padding = UDim.new(0, 4)
	v4.SortOrder = Enum.SortOrder.LayoutOrder
	v4.Parent = shapeRow
	local v25 = {}

	for i, shape in ipairs(RhythmCustomizationConfig.Shapes) do
		local textButton = Instance.new("TextButton")
		textButton.LayoutOrder = i
		textButton.Name = shape .. "Btn"
		textButton.Size = UDim2.new(0, 78, 0, 26)
		textButton.BackgroundColor3 = Settings.BTN
		textButton.Text = shape
		textButton.TextColor3 = Settings.TEXT
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 10
		textButton.ZIndex = 11
		textButton.Parent = shapeRow

		do
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = udim
			uiCorner.Parent = textButton
		end

		textButton.MouseButton1Click:Connect(function()
			SettingsState.SetRhythmShape(shape)
			fn2()
		end)
		v25[shape] = textButton
	end

	v8.EnableDragScroll(shapeRow, "x", true)

	local shapePreviewRow = Instance.new("Frame")
	shapePreviewRow.Name = "ShapePreviewRow"
	shapePreviewRow.Size = UDim2.new(1, 0, 0, 40)
	shapePreviewRow.BackgroundTransparency = 1
	shapePreviewRow.ZIndex = 11
	shapePreviewRow.Parent = result

	local shapePreviewGems = {}

	local function clearShapePreviewGems()
		for _, v26 in ipairs(shapePreviewGems) do
			v26:Destroy()
		end

		shapePreviewGems = {}
	end

	local function refreshShapePreview()
		clearShapePreviewGems()
		local v26 = v23
		local rhythmShape = SettingsState.GetRhythmShape()
		local rhythmLaneColors = SettingsState.GetRhythmLaneColors(v26)

		for i = 1, v26 do
			local v27 = rhythmLaneColors and rhythmLaneColors[i]
			local noteOuter = v27 and v27.NoteOuter or RhythmCustomizationConfig.GetDefaultAccentColor(i)
			local noteInner = v27 and v27.NoteInner or nil
			local shapePreviewGem = makeShapePreviewGem(shapePreviewRow, 26, noteOuter, noteInner, rhythmShape)
			shapePreviewGem.Position = UDim2.new(0, (i - 1) * 36 + 16, 0.5, 0)
			table.insert(shapePreviewGems, shapePreviewGem)
		end
	end

	local function refreshShapeTab()
		local rhythmShape = SettingsState.GetRhythmShape()

		for k, v26 in pairs(v25) do
			v26.BackgroundColor3 = k == rhythmShape and Settings.ACCENT or Settings.BTN
		end

		refreshShapePreview()
	end

	makeActionRow(result, "Reset Shape", "Reset", function()
		SettingsState.ResetRhythmShape()
		fn2()
	end)

	result = Instance.new("Frame")
	result.Name = "BucketSwitchRow"
	result.LayoutOrder = 2
	result.Size = UDim2.new(1, 0, 0, 0)
	result.AutomaticSize = Enum.AutomaticSize.Y
	result.BackgroundTransparency = 1
	result.ZIndex = 11
	result.Parent = colors
	v4 = makeCard(result)
	makeSectionLabel(v4, "Lane Colors")
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 26)
	frame.BackgroundTransparency = 1
	frame.ZIndex = 11
	frame.Parent = v4
	result = Instance.new("UIListLayout")
	result.FillDirection = Enum.FillDirection.Horizontal
	result.Padding = UDim.new(0, 4)
	result.SortOrder = Enum.SortOrder.LayoutOrder
	result.Parent = frame

	local v26 = {}
	local v27 = {}

	local function setActiveBucket(p)
		v23 = p

		for k, v28 in pairs(v26) do
			v28.Visible = k == p
		end

		for k, v28 in pairs(v27) do
			v28.BackgroundColor3 = k == p and Settings.CARD_ACTIVE or Settings.BTN
		end

		refreshShapePreview()

		local ColorsPreview2 = require(ReplicatedStorage.Modules.ColorsPreview)
		ColorsPreview2.SetLaneCount(p)
	end

	for i, laneCountBucket in ipairs(RhythmCustomizationConfig.LaneCountBuckets) do
		local textButton = Instance.new("TextButton")
		textButton.LayoutOrder = i
		textButton.Name = laneCountBucket .. "LaneBtn"
		textButton.Size = UDim2.new(0, 64, 0, 26)
		textButton.BackgroundColor3 = Settings.BTN
		textButton.Text = laneCountBucket .. " Lane"
		textButton.TextColor3 = Settings.TEXT
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 10
		textButton.ZIndex = 11
		textButton.Parent = frame

		do
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = udim
			uiCorner.Parent = textButton
		end

		textButton.MouseButton1Click:Connect(function()
			setActiveBucket(laneCountBucket)
		end)
		v27[laneCountBucket] = textButton
	end

	do
		local ColorsPreview2 = require(ReplicatedStorage.Modules.ColorsPreview)

		result = makeCard(colors)
		result.Name = "PreviewHeaderCard"
		result.LayoutOrder = 0

		v4 = Instance.new("Frame")
		v4.Name = "PreviewHeaderRow"
		v4.Size = UDim2.new(1, 0, 0, 34)
		v4.BackgroundTransparency = 1
		v4.ZIndex = 11
		v4.Parent = result

		v9 = Instance.new("TextLabel")
		v9.Name = "Title"
		v9.Position = UDim2.new(0, 0, 0, 2)
		v9.Size = UDim2.new(1, -100, 0, 14)
		v9.BackgroundTransparency = 1
		v9.Font = Enum.Font.GothamBold
		v9.TextSize = 13
		v9.TextColor3 = Settings.ACCENT
		v9.TextXAlignment = Enum.TextXAlignment.Left
		v9.Text = "Live Preview"
		v9.ZIndex = 11
		v9.Parent = v4

		v9 = Instance.new("TextLabel")
		v9.Name = "Subtitle"
		v9.Position = UDim2.new(0, 0, 0, 18)
		v9.Size = UDim2.new(1, -100, 0, 14)
		v9.BackgroundTransparency = 1
		v9.Font = Enum.Font.Gotham
		v9.TextSize = 9
		v9.TextColor3 = Settings.TEXT_DIM
		v9.TextXAlignment = Enum.TextXAlignment.Left
		v9.TextTruncate = Enum.TextTruncate.AtEnd
		v9.Text = "Notes & buttons, live"
		v9.ZIndex = 11
		v9.Parent = v4

		local previewBtn = Instance.new("TextButton")
		previewBtn.Name = "PreviewBtn"
		previewBtn.AnchorPoint = Vector2.new(1, 0.5)
		previewBtn.Position = UDim2.new(1, 0, 0.5, 0)
		previewBtn.Size = UDim2.new(0, 92, 0, 28)
		previewBtn.BackgroundColor3 = Settings.BTN
		previewBtn.Text = "Preview"
		previewBtn.TextColor3 = Settings.TEXT
		previewBtn.Font = Enum.Font.GothamBold
		previewBtn.TextSize = 10
		previewBtn.ZIndex = 11
		previewBtn.Parent = v4
		v4 = Instance.new("UICorner")
		v4.CornerRadius = udim
		v4.Parent = previewBtn

		local previewHint = Instance.new("TextLabel")
		previewHint.Name = "PreviewHint"
		previewHint.LayoutOrder = 5
		previewHint.Size = UDim2.new(1, 0, 0, 12)
		previewHint.BackgroundTransparency = 1
		previewHint.Font = Enum.Font.Gotham
		previewHint.TextSize = 9
		previewHint.TextColor3 = Settings.TEXT_DIM
		previewHint.TextXAlignment = Enum.TextXAlignment.Left
		previewHint.TextWrapped = true
		previewHint.AutomaticSize = Enum.AutomaticSize.Y
		previewHint.Text = "Preview unavailable while a song is playing"
		previewHint.Visible = false
		previewHint.ZIndex = 11
		previewHint.Parent = result

		local function refreshPreviewButton3() -- 1 equivalent call inferred from this helper
			local isActive = ColorsPreview2.IsActive()
			local v28 = isActive or ColorsPreview2.CanStart()
			previewBtn.Text = isActive and "Preview ON" or "Preview"

			if isActive then
				previewBtn.BackgroundColor3 = Settings.ACCENT
				previewBtn.TextColor3 = Settings.DARKTEXT
			else
				previewBtn.BackgroundColor3 = Settings.BTN
				previewBtn.TextColor3 = v28 and Settings.TEXT or Settings.TEXT_DIM
			end

			previewHint.Visible = not v28
		end

		previewBtn.MouseButton1Click:Connect(function()
			if ColorsPreview2.IsActive() then
				ColorsPreview2.Stop()
			elseif ColorsPreview2.CanStart() then
				ColorsPreview2.Start(v23)
			end

			refreshPreviewButton3() -- inferred equivalent call
		end)

		ColorsPreview2.OnStopped(refreshPreviewButton3)

		colors:GetPropertyChangedSignal("Visible"):Connect(function()
			if not colors.Visible then
				ColorsPreview2.Stop()
			end
		end)
		dropdown:GetPropertyChangedSignal("Visible"):Connect(function()
			if not (dropdown.Visible or LayoutEditorUI.IsOpen()) then
				ColorsPreview2.Stop()
			end
		end)

		task.spawn(function()
			while true do
				task.wait(0.3)

				if dropdown.Visible and colors.Visible then
					pcall(refreshPreviewButton3)
				end
			end
		end)
		task.defer(refreshPreviewButton3)
	end

	do
		local v28 = {}

		for _, laneCountBucket in ipairs(RhythmCustomizationConfig.LaneCountBuckets) do
			local parent = Instance.new("Frame")
			parent.Name = laneCountBucket .. "LanePanel"
			parent.LayoutOrder = 2 + laneCountBucket
			parent.Size = UDim2.new(1, 0, 0, 0)
			parent.AutomaticSize = Enum.AutomaticSize.Y
			parent.BackgroundTransparency = 1
			parent.Visible = laneCountBucket == v23
			parent.ZIndex = 11
			parent.Parent = colors
			local parent3 = Instance.new("UIListLayout")
			parent3.Padding = UDim.new(0, 6)
			parent3.SortOrder = Enum.SortOrder.LayoutOrder
			parent3.Parent = parent
			v26[laneCountBucket] = parent

			do
				local card3 = makeCard(parent)
				v28[laneCountBucket] = {}

				for i = 1, laneCountBucket do
					local parent4 = Instance.new("Frame")
					parent4.Name = "Lane" .. i .. "Row"
					parent4.Size = UDim2.new(1, 0, 0, 34)
					parent4.BackgroundTransparency = 1
					parent4.ZIndex = 11
					parent4.Parent = card3

					local parent5 = Instance.new("TextLabel")
					parent5.Size = UDim2.new(0, 42, 1, 0)
					parent5.BackgroundTransparency = 1
					parent5.Font = Enum.Font.GothamBold
					parent5.TextSize = 10
					parent5.TextColor3 = Settings.TEXT_DIM
					parent5.TextXAlignment = Enum.TextXAlignment.Left
					parent5.Text = "Lane " .. i
					parent5.ZIndex = 11
					parent5.Parent = parent4

					local frame2 = Instance.new("Frame")
					frame2.Position = UDim2.new(0, 46, 0, 0)
					frame2.Size = UDim2.new(0, 140, 1, 0)
					frame2.BackgroundTransparency = 1
					frame2.ZIndex = 11
					frame2.Parent = parent4
					parent5 = Instance.new("UIListLayout")
					parent5.FillDirection = Enum.FillDirection.Horizontal
					parent5.VerticalAlignment = Enum.VerticalAlignment.Center
					parent5.Padding = UDim.new(0, 6)
					parent5.SortOrder = Enum.SortOrder.LayoutOrder
					parent5.Parent = frame2

					local colorSwatchesByColorField = { Lane = i }

					for j, colorField in ipairs(RhythmCustomizationConfig.ColorFields) do
						local colorSwatch = makeColorSwatch(frame2, 22)
						colorSwatch.LayoutOrder = j
						colorSwatchesByColorField[colorField] = colorSwatch
						local v29 = i
						local v30 = colorField
						colorSwatch.MouseButton1Click:Connect(function()
							openColorPicker("Lane " .. v29 .. " - " .. v30, colorSwatch.BackgroundColor3, function(p)
								SettingsState.SetRhythmLaneColor(laneCountBucket, v29, v30, p)
								fn2()
							end)
						end)
					end

					parent5 = Instance.new("TextButton")
					parent5.AnchorPoint = Vector2.new(1, 0.5)
					parent5.Position = UDim2.new(1, 0, 0.5, 0)
					parent5.Size = UDim2.new(0, 66, 0, 22)
					parent5.BackgroundColor3 = Settings.BTN
					parent5.Text = "Random"
					parent5.TextColor3 = Settings.TEXT
					parent5.Font = Enum.Font.GothamBold
					parent5.TextSize = 9
					parent5.ZIndex = 11
					parent5.Parent = parent4
					parent4 = Instance.new("UICorner")
					parent4.CornerRadius = udim
					parent4.Parent = parent5

					do
						local v29 = i
						parent5.MouseButton1Click:Connect(function()
							SettingsState.SetRhythmLaneColorSet(laneCountBucket, v29, randomLaneColorSet())
							fn2()
						end)
					end

					v28[laneCountBucket][i] = colorSwatchesByColorField
				end

				parent = Instance.new("Frame")
				parent.Size = UDim2.new(1, 0, 0, 26)
				parent.BackgroundTransparency = 1
				parent.ZIndex = 11
				parent.Parent = card3
			end

			parent3 = Instance.new("UIListLayout")
			parent3.FillDirection = Enum.FillDirection.Horizontal
			parent3.Padding = UDim.new(0, 6)
			parent3.SortOrder = Enum.SortOrder.LayoutOrder
			parent3.Parent = parent

			parent3 = Instance.new("TextButton")
			parent3.LayoutOrder = 1
			parent3.Size = UDim2.new(1 / 3, -4, 1, 0)
			parent3.BackgroundColor3 = Settings.BTN
			parent3.Text = "Reset " .. laneCountBucket .. "-Lane"
			parent3.TextColor3 = Color3.fromRGB(232, 110, 100)
			parent3.Font = Enum.Font.GothamBold
			parent3.TextSize = 9
			parent3.ZIndex = 11
			parent3.Parent = parent

			do
				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = udim
				uiCorner.Parent = parent3
				v8.AddStroke(parent3, Settings.DANGER, 1)

				parent3.MouseButton1Click:Connect(function()
					SettingsState.ResetRhythmLaneSet(laneCountBucket)
					fn2()
				end)

				parent3 = Instance.new("TextButton")
				parent3.LayoutOrder = 2
				parent3.Size = UDim2.new(1 / 3, -4, 1, 0)
				parent3.BackgroundColor3 = Settings.ACCENT
				parent3.Text = "Smart Theme"
				parent3.TextColor3 = Settings.DARKTEXT
				parent3.Font = Enum.Font.GothamBold
				parent3.TextSize = 9
				parent3.ZIndex = 11
				parent3.Parent = parent
				uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = udim
				uiCorner.Parent = parent3
			end

			parent3.MouseButton1Click:Connect(function()
				applySmartTheme(laneCountBucket) -- inferred equivalent call
			end)

			parent3 = Instance.new("TextButton")
			parent3.LayoutOrder = 3
			parent3.Size = UDim2.new(1 / 3, -4, 1, 0)
			parent3.BackgroundColor3 = Settings.BTN
			parent3.Text = "Randomize All"
			parent3.TextColor3 = Settings.TEXT
			parent3.Font = Enum.Font.GothamBold
			parent3.TextSize = 9
			parent3.ZIndex = 11
			parent3.Parent = parent
			parent = Instance.new("UICorner")
			parent.CornerRadius = udim
			parent.Parent = parent3

			parent3.MouseButton1Click:Connect(function()
				randomizeAllLanes(laneCountBucket)
			end)
		end

		setActiveBucket(2)

		result = makeCard(colors)
		result.LayoutOrder = 20
		makeSectionLabel(result, "Theme Presets")

		do
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Size = UDim2.new(1, 0, 0, 30)
			scrollingFrame.BackgroundTransparency = 1
			scrollingFrame.ScrollBarThickness = 0
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
			scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
			scrollingFrame.ZIndex = 11
			scrollingFrame.Parent = result
			v4 = Instance.new("UIListLayout")
			v4.FillDirection = Enum.FillDirection.Horizontal
			v4.Padding = UDim.new(0, 4)
			v4.SortOrder = Enum.SortOrder.LayoutOrder
			v4.Parent = scrollingFrame

			for i, themePresetName in ipairs(RhythmCustomizationConfig.ThemePresetNames) do
				if themePresetName == "Custom" then
					continue
				end

				local textButton = Instance.new("TextButton")
				textButton.LayoutOrder = i
				textButton.Size = UDim2.new(0, 70, 0, 26)
				textButton.BackgroundColor3 = Settings.BTN
				textButton.Text = themePresetName
				textButton.TextColor3 = Settings.TEXT
				textButton.Font = Enum.Font.GothamBold
				textButton.TextSize = 9
				textButton.ZIndex = 11
				textButton.Parent = scrollingFrame

				do
					local uiCorner = Instance.new("UICorner")
					uiCorner.CornerRadius = udim
					uiCorner.Parent = textButton
				end

				textButton.MouseButton1Click:Connect(function()
					applyPreset(v23, themePresetName)
				end)
			end

			v8.EnableDragScroll(scrollingFrame, "x", true)
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 0, 16)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Gotham
		textLabel.TextSize = 9
		textLabel.TextColor3 = Settings.TEXT_DIM
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = "Active: Default"
		textLabel.ZIndex = 11
		textLabel.Parent = result

		local card3 = makeCard(colors)
		card3.LayoutOrder = 21
		makeSectionLabel(card3, "Judgement Text")
		local colorSwatchesByJudgmentType = {}

		for _, judgmentType in ipairs(RhythmCustomizationConfig.JudgmentTypes) do
			local frame2 = Instance.new("Frame")
			frame2.Size = UDim2.new(1, 0, 0, 22)
			frame2.BackgroundTransparency = 1
			frame2.ZIndex = 11
			frame2.Parent = card3

			do
				local textLabel2 = Instance.new("TextLabel")
				textLabel2.Size = UDim2.new(0.7, 0, 1, 0)
				textLabel2.BackgroundTransparency = 1
				textLabel2.Font = Enum.Font.GothamMedium
				textLabel2.TextSize = 10
				textLabel2.TextColor3 = Settings.TEXT
				textLabel2.TextXAlignment = Enum.TextXAlignment.Left
				textLabel2.Text = judgmentType
				textLabel2.ZIndex = 11
				textLabel2.Parent = frame2
			end

			local colorSwatch = makeColorSwatch(frame2, 20)
			colorSwatch.AnchorPoint = Vector2.new(1, 0.5)
			colorSwatch.Position = UDim2.new(1, 0, 0.5, 0)
			colorSwatchesByJudgmentType[judgmentType] = colorSwatch

			colorSwatch.MouseButton1Click:Connect(function()
				openColorPicker("Judgement - " .. judgmentType, colorSwatch.BackgroundColor3, function(p)
					SettingsState.SetRhythmJudgmentColor(judgmentType, p)
					fn2()
				end)
			end)
		end

		makeActionRow(card3, "Reset Judgement Colors", "Reset", function()
			SettingsState.ResetRhythmJudgment()
			fn2()
		end)

		result = makeCard(colors)
		result.LayoutOrder = 22
		makeSectionLabel(result, "Reset All Colors")
		makeActionRow(result, "Restore shape, all lanes & judgement to default", "Reset All", function()
			SettingsState.ResetRhythmAll()
			fn2()
		end)

		fn2 = function()
			for k, v29 in pairs(v28) do
				local rhythmLaneColors = SettingsState.GetRhythmLaneColors(k)

				for k2, v30 in pairs(v29) do
					local v31 = rhythmLaneColors and rhythmLaneColors[k2]
					local defaultAccentColor = RhythmCustomizationConfig.GetDefaultAccentColor(k2)

					for _, colorField in ipairs(RhythmCustomizationConfig.ColorFields) do
						local v32 = v30[colorField]
						local backgroundColor2

						if v31 then
							backgroundColor2 = v31[colorField] or defaultAccentColor
						else
							backgroundColor2 = defaultAccentColor
						end

						v32.BackgroundColor3 = backgroundColor2
					end
				end
			end

			for k, v29 in pairs(colorSwatchesByJudgmentType) do
				v29.BackgroundColor3 = SettingsState.GetRhythmJudgmentColor(k)
					or RhythmCustomizationConfig.JudgmentDefaultColors[k]
			end

			textLabel.Text = "Active: " .. SettingsState.GetRhythmThemePreset()
			refreshShapeTab()
		end
	end

	fn2()

	result = makeCard(v13.Audio)
	makeSectionLabel(result, "Audio")
	v4 = Instance.new("TextLabel")
	v4.Name = "AudioNote"
	v4.Size = UDim2.new(1, 0, 0, 28)
	v4.BackgroundTransparency = 1
	v4.Font = Enum.Font.Gotham
	v4.TextSize = 10
	v4.TextColor3 = Settings.TEXT_DIM
	v4.TextWrapped = true
	v4.AutomaticSize = Enum.AutomaticSize.Y
	v4.TextXAlignment = Enum.TextXAlignment.Left
	v4.Text = "Amp volume is controlled from the panel near your amp in-game."
	v4.ZIndex = 11
	v4.Parent = result

	v8.WrongSound = makeToggleRow(result, "Wrong Note Sound", SettingsState.GetWrongSoundEnabled, function(p)
		SettingsState.SetWrongSoundEnabled(p)
		v8.Toast:Show(p and "Wrong Note Sound Enabled" or "Wrong Note Sound Disabled")
	end)

	result = makeCard(v13.Visual)
	makeSectionLabel(result, "Accessibility")
	v8.ReduceMotion = makeToggleRow(result, "Reduce Motion", SettingsState.GetReduceMotionEnabled, function(p)
		SettingsState.SetReduceMotionEnabled(p)

		if p then
			SettingsState.SetFields({
				ShakeEnabled = false,
				HitEffectEnabled = false,
				HitSparkleEnabled = false,
				JudgmentPopEnabled = false
			})
		else
			SettingsState.SetFields({
				ShakeEnabled = v6.ShakeEnabled,
				HitEffectEnabled = v6.HitEffectEnabled,
				HitSparkleEnabled = v6.HitSparkleEnabled,
				JudgmentPopEnabled = v6.JudgmentPopEnabled
			})
		end

		v8.Shake.Refresh()
		v8.HitEffect.Refresh()
		v8.HitSparkle.Refresh()
		v8.JudgmentPop.Refresh()
		v8.Toast:Show(p and "Reduce Motion Enabled" or "Reduce Motion Disabled")
	end)

	function v8.Remeasure(folder)
		task.defer(function()
			for _, label in ipairs(folder:GetDescendants()) do
				if not (label:IsA("TextLabel") and label.AutomaticSize == Enum.AutomaticSize.Y) then
					continue
				end

				label.AutomaticSize = Enum.AutomaticSize.None
				label.AutomaticSize = Enum.AutomaticSize.Y
			end
		end)
	end

	function v8.Reorganize()
		local function findCard(instance, p)
			for _, frame2 in ipairs(instance:GetChildren()) do
				if not (frame2:IsA("Frame") and frame2.Name == "Card") then
					continue
				end

				local sectionLabel = frame2:FindFirstChild("SectionLabel")

				if sectionLabel and sectionLabel.Text == p then
					return frame2
				end
			end

			return nil
		end

		local gameplay2 = v13.Gameplay
		local controls = v13.Controls
		local visual2 = v13.Visual
		local audio = v13.Audio

		local card3 = findCard(controls, "Timing")

		if card3 then
			card3.LayoutOrder = -1
			card3.Parent = audio
		end

		local card4 = findCard(gameplay2, "More Options")
		local card5 = findCard(visual2, "Camera")

		local toggleRow = card4 and card5 and card4:FindFirstChild("ToggleRow")

		if toggleRow then
			toggleRow.Parent = card5
			card4:Destroy()
		end

		local card6 = findCard(visual2, "More Options")

		if card6 then
			card6.SectionLabel.Text = "Effects"
		end

		for k, layoutOrder in pairs({
			["Performance Display"] = -1,
			Theme = 0,
			Camera = 1,
			["HUD Opacity"] = 2,
			Effects = 3,
			Accessibility = 4,
			["Judgment Text"] = 5,
			["Stage Lighting"] = 6
		}) do
			local card7 = findCard(visual2, k)

			if card7 then
				card7.LayoutOrder = layoutOrder
			end
		end
	end
	v8.Reorganize()

	do
		local flag3 = false
		local thread = nil

		resetAllBtn.MouseButton1Click:Connect(function()
			if flag3 then
				if thread then
					task.cancel(thread)
					thread = nil
				end

				flag3 = false

				SettingsState.ResetLayout()
				SettingsState.SetFields({
					NoteSpeedMultiplier = v6.NoteSpeedMultiplier,
					ButtonOpacity = v6.ButtonOpacity,
					ButtonSizeMultiplier = v6.ButtonSizeMultiplier,
					ButtonSpacingExtra = v6.ButtonSpacingExtra,
					AudioOffsetMs = v6.AudioOffsetMs,
					KeybindFiveKey = v6.KeybindFiveKey,
					KeybindTwoKey = v6.KeybindTwoKey,
					KeybindDoublePedalNormal = v6.KeybindDoublePedalNormal,
					KeybindVibratoRhythm = v6.KeybindVibratoRhythm,
					KeybindStarPower = v6.KeybindStarPower,
					KeybindFiveKeyPad = table.clone(v6.KeybindFiveKeyPad),
					KeybindTwoKeyPad = table.clone(v6.KeybindTwoKeyPad),
					KeybindDoublePedalNormalPad = v6.KeybindDoublePedalNormalPad,
					KeybindDoublePedalFlippedPad = v6.KeybindDoublePedalFlippedPad,
					KeybindStarPowerPad = v6.KeybindStarPowerPad,
					ControllerType = v6.ControllerType,
					AutoStarPower = v6.AutoStarPower,
					ShakeEnabled = v6.ShakeEnabled,
					HitEffectEnabled = v6.HitEffectEnabled,
					HitSparkleEnabled = v6.HitSparkleEnabled,
					JudgmentPopEnabled = v6.JudgmentPopEnabled,
					HideOwnJudgmentText = v6.HideOwnJudgmentText,
					HideAllJudgmentText = v6.HideAllJudgmentText,
					WrongSoundEnabled = v6.WrongSoundEnabled,
					ReduceMotionEnabled = v6.ReduceMotionEnabled,
					ShowPerfStats = v6.ShowPerfStats,
					HudOpacity = v6.HudOpacity,
					StarPowerBarOpacity = v6.StarPowerBarOpacity,
					BandFeedOpacity = v6.BandFeedOpacity,
					StreakNoticeOpacity = v6.StreakNoticeOpacity,
					HudOpacityLinked = v6.HudOpacityLinked,
					HudOpacityAll = v6.HudOpacityAll,
					HudKeepContentClear = v6.HudKeepContentClear,
					HudContentOpacity = v6.HudContentOpacity,
					FreePlayOpacity = v6.FreePlayOpacity,
					StageLightingLite = SettingsState.GetStageLightingLiteDefault(),
					StageLightingReduceFlash = false,
					TouchChartEnabled = v6.TouchChartEnabled,
					HighwayCamElevation = 41,
					HighwayCamFov = 55,
					HighwayCamZoom = 0.62,
					HighwayCamHitY = 0.63,
					HighwayCamLength = 58
				})

				for _, v28 in ipairs(v16) do
					v28.Refresh()
				end

				v8.Shake.Refresh()
				v8.HitEffect.Refresh()
				v8.HitSparkle.Refresh()
				v8.JudgmentPop.Refresh()
				v8.HideOwn.Refresh()
				v8.HideAll.Refresh()
				v8.WrongSound.Refresh()
				v8.TouchChart.Refresh()
				v8.AutoStarPower.Refresh()
				v8.ReduceMotion.Refresh()
				v8.ShowPerfStats.Refresh()
				v8.StageLightingLite.Refresh()
				v8.StageLightingReduceFlash.Refresh()

				for _, opacitySlider in ipairs(v8.OpacitySliders) do
					opacitySlider.Refresh()
				end

				v8.AudioOffsetStepper.Refresh()

				SessionCameraSettings.SetFirstPersonFOV(v6.FirstPersonFOV)
				slider8.Refresh()

				SettingsState.ResetRhythmAll()
				fn2()

				resetAllBtn.Text = "Reset All"
				resetAllBtn.BackgroundColor3 = Settings.DANGER
			else
				flag3 = true
				resetAllBtn.Text = "Click again to confirm"
				resetAllBtn.BackgroundColor3 = Settings.WARNING

				thread = task.delay(3, function()
					flag3 = false
					resetAllBtn.Text = "Reset All"
					resetAllBtn.BackgroundColor3 = Settings.DANGER
					thread = nil
				end)
			end
		end)
	end

	do
		local function openMenu()
			if flag then
				return
			end

			flag = true

			SessionCameraSettings.SetMenuOpen(true)

			mouseBehavior = UserInputService.MouseBehavior
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true

			content.ScrollingEnabled = true

			local function fn3()
				return GuiService:GetGuiInset()
			end

			local success2, result2 = pcall(fn3)

			local v28 = not (success2 and result2) and 0 or result2.Y

			dropdown.Position = UDim2.new(1, -12, 0, (v28 <= 0 and 36 or v28) + -8)
			local viewportSize = getViewportSize() -- inferred equivalent call
			local success3, result3, v29 = pcall(function()
				return GuiService:GetGuiInset()
			end)
			local v30, v31

			if success3 and result3 and v29 then
				v30 = result3.Y
				v31 = v29.Y
			else
				v30 = 0
				v31 = 0
			end

			local x = viewportSize.X
			local v32 = viewportSize.Y - v30 - v31

			local v50 = x - 24
			local success4, result4 = pcall(fn3)

			local v51 = not (success4 and result4) and 0 or result4.Y

			local v52 = v32 - ((v51 <= 0 and 36 or v51) + -8) - 8

			local v53 = math.min(v50 / 340, v52 / 520)
			local scale

			if v5 then
				scale = math.clamp(v53 * 1.2, 0.65, 9.6)
			else
				scale = math.clamp(v53, 0.65, 1.25)
			end

			responsiveScale.Scale = scale

			searchBox.Text = ""
			clearBtn.Visible = false
			flag2 = false

			dropdown.Visible = true
			dropdown.BackgroundTransparency = 1
			dropdown.Size = UDim2.new(0, 340, 0, 0)

			refreshKeybindDisplay()
			setActiveCategory(v14)

			TweenService:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.6,
				Size = UDim2.new(0, 340, 0, 520)
			}):Play()

			TweenService:Create(gearButton, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(50, 50, 58)
			}):Play()
		end

		local function closeMenu()
			if not flag then
				return
			end

			flag = false
			v7 = nil

			v8.AudioCalibrateUI.Hide()

			SessionCameraSettings.SetMenuOpen(false)

			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			mouseBehavior = nil

			content.ScrollingEnabled = true

			TweenService:Create(dropdown, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 340, 0, 0)
			}):Play()

			TweenService:Create(gearButton, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(23, 23, 27)
			}):Play()

			task.delay(0.2, function()
				if not flag then
					dropdown.Visible = false
					refreshKeybindDisplay()
				end
			end)
		end

		gearButton.MouseButton1Click:Connect(function()
			if flag then
				closeMenu()
			else
				openMenu()
			end
		end)

		RunService:BindToRenderStep("SettingsMenuMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
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

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if v8.ModeManager.IsFreePlay() then
				return
			end

			if input.KeyCode == Enum.KeyCode.Backquote and not gameProcessed then
				if flag then
					closeMenu()
				else
					openMenu()
				end
			end
		end)

		do
			local function onViewportChanged()
				local function fn3()
					return GuiService:GetGuiInset()
				end

				local success2, result2 = pcall(fn3)

				local v28 = not (success2 and result2) and 0 or result2.Y

				local v29 = v28 <= 0 and 36 or v28

				gearButton.Size = UDim2.new(0, 70, 0, 30)
				gearButton.Position = UDim2.new(1, -12, 0, v29 / 2)
				dropdown.Position = UDim2.new(1, -12, 0, v29 + -8)

				if flag then
					local viewportSize = getViewportSize() -- inferred equivalent call
					local success3, result3, v30 = pcall(function()
						return GuiService:GetGuiInset()
					end)
					local v31, v32

					if success3 and result3 and v30 then
						v31 = result3.Y
						v32 = v30.Y
					else
						v31 = 0
						v32 = 0
					end

					local x = viewportSize.X
					local v50 = viewportSize.Y - v31 - v32

					local v51 = x - 24
					local success4, result4 = pcall(fn3)

					local v52 = not (success4 and result4) and 0 or result4.Y

					local v53 = v50 - ((v52 <= 0 and 36 or v52) + -8) - 8

					local v54 = math.min(v51 / 340, v53 / 520)
					local scale

					if v5 then
						scale = math.clamp(v54 * 1.2, 0.65, 9.6)
					else
						scale = math.clamp(v54, 0.65, 1.25)
					end

					responsiveScale.Scale = scale
				end
			end

			local function connectViewportListener()
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged)
				end
			end

			result = workspace.CurrentCamera

			if result then
				result:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged)
			end

			workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectViewportListener)
		end

		do
			local GuiService2 = game:GetService("GuiService")

			do
				local function isGamepadInput(input): boolean -- 1 equivalent call inferred from this helper
					if string.sub(input.UserInputType.Name, 1, 7) == "Gamepad" then
						return true
					end

					local name = input.KeyCode.Name
					return string.sub(name, 1, 6) == "Button" or string.sub(name, 1, 4) == "DPad"
				end
			end

			local function focusMenu()
				local selectedObject = v12[v14] or v12[v10[1]]

				if selectedObject and selectedObject.Visible then
					GuiService2.SelectedObject = selectedObject
				end
			end

			local function stepCategory(p)
				if flag2 then
					return
				end

				local v28 = ((table.find(v10, v14) or 1) - 1 + p) % #v10 + 1
				setActiveCategory(v10[v28])
				content.CanvasPosition = Vector2.new(0, 0)
				local selectedObject = v12[v10[v28]]

				if selectedObject then
					GuiService2.SelectedObject = selectedObject
				end
			end

			UserInputService.InputBegan:Connect(function(input)
				if not isGamepadInput(input) or UserInputService:GetFocusedTextBox() then -- inferred equivalent call
					return
				end

				local keyCode = input.KeyCode

				if keyCode == Enum.KeyCode.ButtonY then
					if not SettingsState.IsControllerMode() or v8.ModeManager.IsFreePlay() then
						return
					end

					if flag then
						closeMenu()
						GuiService2.SelectedObject = nil
					else
						openMenu()
						task.defer(focusMenu)
					end
				else
					if not flag or v7 then
						return
					end

					if keyCode == Enum.KeyCode.ButtonB then
						closeMenu()
						GuiService2.SelectedObject = nil
					elseif keyCode == Enum.KeyCode.ButtonL1 then
						stepCategory(-1)
					elseif keyCode == Enum.KeyCode.ButtonR1 then
						stepCategory(1)
					end
				end
			end)
		end

		do
			local controllerHintY = Instance.new("ImageLabel")
			controllerHintY.Name = "ControllerHintY"
			controllerHintY.BackgroundTransparency = 1
			controllerHintY.Size = UDim2.fromOffset(16, 16)
			controllerHintY.Position = UDim2.new(0, 4, 0.5, -8)
			controllerHintY.ZIndex = (gearButton.ZIndex or 1) + 2
			controllerHintY.ScaleType = Enum.ScaleType.Fit

			do
				local success2, result2 = pcall(function()
					return UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonY)
				end)

				controllerHintY.Image = success2 and result2 or ""
			end

			controllerHintY.Visible = false
			controllerHintY.Parent = gearButton
			local uiPadding = Instance.new("UIPadding")
			uiPadding.Parent = gearButton
			local function updateGearHint()
				local visible = SettingsState.IsControllerMode() and controllerHintY.Image ~= ""
				controllerHintY.Visible = visible

				gearButton.TextXAlignment = visible and Enum.TextXAlignment.Right or Enum.TextXAlignment.Center
				gearButton.TextSize = visible and 10 or 11
				uiPadding.PaddingRight = UDim.new(0, visible and 6 or 0)
			end
			SettingsState.OnChanged(updateGearHint)
			updateGearHint()
		end

		RunService:BindToRenderStep("SettingsMenuPadScroll", Enum.RenderPriority.Camera.Value + 51, function(p)
			if not flag then
				return
			end

			local success2, result2 = pcall(function()
				return UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
			end)

			if not (success2 and result2) then
				return
			end

			for _, v28 in ipairs(result2) do
				if v28.KeyCode == Enum.KeyCode.Thumbstick2 then
					local y = v28.Position.Y

					if not (math.abs(y) > 0.2) then
						break
					end

					local v29 = math.max(0, content.AbsoluteCanvasSize.Y - content.AbsoluteSize.Y)
					local v30 = math.clamp(content.CanvasPosition.Y - y * 900 * p, 0, v29)
					content.CanvasPosition = Vector2.new(0, v30)
					break
				end
			end
		end)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.Escape and flag and not gameProcessed then
				closeMenu()
				return
			end

			if not (flag and v7) then
				return
			end

			local userInputType = input.UserInputType
			local name = nil
			local isControllerMode = SettingsState.IsControllerMode()
			local v28

			if v7 == "Vibrato" then
				v28 = false
			else
				v28 = v7 ~= "StarPower"
			end

			if v7 == "Vibrato" or v7 == "StarPower" or isControllerMode and v28 then
				if
					(userInputType == Enum.UserInputType.MouseButton2 or userInputType == Enum.UserInputType.MouseButton3)
					and not (isControllerMode and v28)
				then
					name = userInputType.Name
				elseif string.sub(userInputType.Name, 1, 7) == "Gamepad" then
					name = input.KeyCode.Name

					if string.sub(name, 1, 6) ~= "Button" and string.sub(name, 1, 4) ~= "DPad" then
						return
					end
				end
			end

			if
				gameProcessed and not name
				or isControllerMode and v28 and not name
				or not name and userInputType ~= Enum.UserInputType.Keyboard
			then
				return
			end

			if name or not set[input.KeyCode] then
				local v29 = name or input.KeyCode.Name

				local name2 = SettingsState.GetVibratoKeyRhythm().Name
				local function laneKeysContain(p): boolean
					for _, v30 in ipairs(SettingsState.GetKeybindFiveKey()) do
						if v30.Name == p then
							return true
						end
					end

					for _, v30 in ipairs(SettingsState.GetKeybindTwoKey()) do
						if v30.Name == p then
							return true
						end
					end

					if
						SettingsState.GetDoublePedalKeyNormal().Name == p
						or SettingsState.GetDoublePedalKeyFlipped().Name == p
					then
						return true
					end

					for _, v30 in ipairs({ 3, 4 }) do
						for _, v31 in ipairs(RhythmEngineConfig.GetNewbieKeybinds(v30) or {}) do
							if v31.Name == p then
								return true
							end
						end
					end

					return false
				end

				local function rejectKey(p)
					v7 = nil

					if v8.QuickSetupCancel then
						v8.QuickSetupCancel()
					end

					if not p then
						refreshKeybindDisplay()

						return
					end

					p.Text = "Key in use"
					task.delay(1.2, refreshKeybindDisplay)
				end

				if v7 == "Vibrato" then
					if laneKeysContain(v29) or v29 == SettingsState.GetStarPowerBindingName() then
						local vibratoRebind = v8.VibratoRebind
						v7 = nil

						if v8.QuickSetupCancel then
							v8.QuickSetupCancel()
						end

						if not vibratoRebind then
							refreshKeybindDisplay()

							return
						end

						vibratoRebind.Text = "Key in use"
						task.delay(1.2, refreshKeybindDisplay)
						return
					end

					SettingsState.SetField("KeybindVibratoRhythm", v29)
				elseif v7 == "StarPower" then
					if laneKeysContain(v29) or v29 == SettingsState.GetVibratoBindingName() then
						local starPowerRebind = v8.StarPowerRebind
						v7 = nil

						if v8.QuickSetupCancel then
							v8.QuickSetupCancel()
						end

						if not starPowerRebind then
							refreshKeybindDisplay()

							return
						end

						starPowerRebind.Text = "Key in use"
						task.delay(1.2, refreshKeybindDisplay)
						return
					end

					SettingsState.SetField(SettingsState.KeybindField("KeybindStarPower"), v29, true)
				elseif (name2 == "LeftControl" or v29 ~= name2) and v29 ~= SettingsState.GetStarPowerBindingName() then
					if typeof(v7) == "number" then
						local v30 = {}

						for i, v31 in ipairs(SettingsState.GetKeybindFiveKey()) do
							v30[i] = v31.Name
						end

						v30[v7] = v29
						SettingsState.SetField(SettingsState.KeybindField("KeybindFiveKey"), v30)
					elseif v7 == "TwoKey1" or v7 == "TwoKey2" then
						local v30 = {}

						for i, v31 in ipairs(SettingsState.GetKeybindTwoKey()) do
							v30[i] = v31.Name
						end

						v30[v7 == "TwoKey1" and 1 or 2] = v29
						SettingsState.SetField(SettingsState.KeybindField("KeybindTwoKey"), v30)
					elseif v7 == "DoublePedal" then
						SettingsState.SetField(SettingsState.KeybindField("KeybindDoublePedalNormal"), v29)
					end
				else
					local v30 = nil

					if typeof(v7) == "number" then
						v30 = actionRows[v7]
					elseif v7 == "TwoKey1" then
						v30 = actionRows2[1]
					elseif v7 == "TwoKey2" then
						v30 = actionRows2[2]
					elseif v7 == "DoublePedal" then
						v30 = v18
					end

					v7 = nil

					if v8.QuickSetupCancel then
						v8.QuickSetupCancel()
					end

					if not v30 then
						refreshKeybindDisplay()

						return
					end

					v30.Text = "Key in use"
					task.delay(1.2, refreshKeybindDisplay)
					return
				end

				v7 = nil

				if v8.QuickSetupAdvance then
					v8.QuickSetupAdvance()
				end

				refreshKeybindDisplay()
			else
				v7 = nil
				refreshKeybindDisplay()
			end
		end)
	end

	SettingsState.OnChanged(function()
		slider.Refresh()
		slider2.Refresh()
		v17.Refresh()
		slider5.Refresh()
		refreshKeybindDisplay()
		fn2()
		v8.Shake.Refresh()
		v8.HitEffect.Refresh()
		v8.HitSparkle.Refresh()
		v8.JudgmentPop.Refresh()
		v8.HideOwn.Refresh()
		v8.HideAll.Refresh()
		v8.WrongSound.Refresh()
		v8.ReduceMotion.Refresh()
		v8.ShowPerfStats.Refresh()
		v8.StageLightingLite.Refresh()
		v8.StageLightingReduceFlash.Refresh()
		v8.AutoStarPower.Refresh()

		for _, opacitySlider in ipairs(v8.OpacitySliders) do
			opacitySlider.Refresh()
		end

		if v8.ShowModsButton then
			v8.ShowModsButton.Refresh()
		end
	end)

	SessionCameraSettings.OnChanged(function()
		slider8.Refresh()
	end)

	do
		local function getActiveLaneCountForColors() -- 1 equivalent call inferred from this helper
			if not v2 then
				return nil
			end

			if RhythmEngineConfig.TwoKeyEligible[v2] and v3 == 2 then
				return RhythmEngineConfig.TwoKeyLaneCount
			end

			return RhythmEngineConfig.LaneCount[v2]
		end
	end

	do
		local function autoSelectActiveBucket() -- 2 equivalent calls inferred from this helper
			local activeLaneCountForColors = getActiveLaneCountForColors() -- inferred equivalent call

			if
				activeLaneCountForColors
				and RhythmCustomizationConfig.IsValidLaneCount(activeLaneCountForColors)
				and activeLaneCountForColors ~= v23
			then
				setActiveBucket(activeLaneCountForColors)
			end
		end
	end

	v.OnClientEvent:Connect(function(p, p2, _)
		v2 = p and p2 or nil
		autoSelectActiveBucket() -- inferred equivalent call
	end)

	KeyModeUpdate.OnClientEvent:Connect(function(p)
		v3 = p
		autoSelectActiveBucket() -- inferred equivalent call
	end)
end

local UISkin = require(ReplicatedStorage.Modules.SongListUI.UISkin)
UISkin.AddRoot(settingsMenuUI)