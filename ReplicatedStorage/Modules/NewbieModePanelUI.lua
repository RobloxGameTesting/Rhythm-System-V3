local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local NewbieModeState = require(ReplicatedStorage.Modules.NewbieModeState)

local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local Presets = NewbieModeState.Presets

local NewbieModePanelUI = {}
NewbieModePanelUI.__index = NewbieModePanelUI

local function screenRect(p) -- 3 equivalent calls inferred from this helper
	return p.AbsolutePosition + GuiService:GetGuiInset(), p.AbsoluteSize
end

local function pointInObject(p, p2, p3): boolean -- 2 equivalent calls inferred from this helper
	local v, v2 = screenRect(p2) -- inferred equivalent call
	return p.X >= v.X - p3 and p.X <= v.X + v2.X + p3 and p.Y >= v.Y - p3 and p.Y <= v.Y + v2.Y + p3
end

local function addCorner(parent, cornerRadius) -- 10 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = cornerRadius
	uiCorner.Parent = parent
	return uiCorner
end

local function makeInfoLabel(content, text, layoutOrder)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 0, 0)
	textLabel.AutomaticSize = Enum.AutomaticSize.Y
	textLabel.Font = StyledTheme.Fonts.Regular
	textLabel.TextSize = StyledTheme.TextSize.S
	textLabel.TextColor3 = StyledTheme.Colors.TextSecondary
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Text = text
	textLabel.LayoutOrder = layoutOrder
	textLabel.Parent = content
	return textLabel
end

local function makePillButton(parent, label, size, p) -- 5 equivalent calls inferred from this helper
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Size = size
	textButton.BackgroundColor3 = p and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface
	textButton.Font = StyledTheme.Fonts.Bold
	textButton.TextSize = StyledTheme.TextSize.S
	textButton.TextColor3 = p and StyledTheme.Colors.AccentText or StyledTheme.Colors.TextPrimary
	textButton.Text = label
	textButton.Parent = parent
	addCorner(textButton, StyledTheme.Radius.Pill) -- inferred equivalent call
	return textButton
end

local function makeCheckbox(frame)
	local textButton = Instance.new("TextButton")
	textButton.AnchorPoint = Vector2.new(1, 0.5)
	textButton.Position = UDim2.new(1, 0, 0.5, 0)
	textButton.Size = UDim2.new(0, 26, 0, 26)
	textButton.AutoButtonColor = false
	textButton.Text = ""
	textButton.BackgroundColor3 = StyledTheme.Colors.Surface
	textButton.Parent = frame
	addCorner(textButton, StyledTheme.Radius.Large) -- inferred equivalent call

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = StyledTheme.Stroke.Thickness
	uiStroke.Color = StyledTheme.Colors.Border
	uiStroke.Parent = textButton

	local frame2 = Instance.new("Frame")
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.Size = UDim2.new(0, 10, 0, 10)
	frame2.BackgroundColor3 = StyledTheme.Colors.AccentText
	frame2.BorderSizePixel = 0
	frame2.Visible = false
	frame2.Parent = textButton
	addCorner(frame2, StyledTheme.Radius.Pill) -- inferred equivalent call

	local function setState(visible)
		textButton.BackgroundColor3 = visible and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface
		uiStroke.Color = visible and StyledTheme.Colors.Accent or StyledTheme.Colors.Border
		frame2.Visible = visible
	end

	return textButton, setState
end

function NewbieModePanelUI.new(p)
	local self = setmetatable({}, NewbieModePanelUI)

	local v = p

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local newbieModePanelScreenGui = Instance.new("ScreenGui")
	newbieModePanelScreenGui.Name = "NewbieModePanelScreenGui"
	newbieModePanelScreenGui.ResetOnSpawn = false
	newbieModePanelScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	newbieModePanelScreenGui.DisplayOrder = 95
	newbieModePanelScreenGui.Enabled = false
	newbieModePanelScreenGui.Parent = playerGui

	local newbieModePanel = Instance.new("Frame")
	newbieModePanel.Name = "NewbieModePanel"
	newbieModePanel.Size = UDim2.new(0, 330, 0, 0)
	newbieModePanel.AutomaticSize = Enum.AutomaticSize.Y
	newbieModePanel.BackgroundColor3 = StyledTheme.Colors.Background
	newbieModePanel.BackgroundTransparency = 0.02
	newbieModePanel.Active = true
	newbieModePanel.Parent = newbieModePanelScreenGui
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = newbieModePanel
	addCorner(newbieModePanel, StyledTheme.Radius.Large) -- inferred equivalent call

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = StyledTheme.Stroke.Thickness
	uiStroke.Color = Color3.new(0, 0, 0)
	uiStroke.Transparency = 0.2
	uiStroke.Parent = newbieModePanel

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Parent = newbieModePanel

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 12)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 12)
	uiPadding.PaddingBottom = UDim.new(0, 12)
	uiPadding.Parent = content

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = content

	local count = 0
	local function nextOrder() -- 14 equivalent calls inferred from this helper
		count += 1
		return count
	end

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.BackgroundColor3 = StyledTheme.Colors.Surface
	closeButton.Size = UDim2.new(0, 24, 0, 24)
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -12, 0, 12)
	closeButton.Text = ""
	closeButton.AutoButtonColor = false
	closeButton.ZIndex = 3
	closeButton.Parent = newbieModePanel
	addCorner(closeButton, StyledTheme.Radius.Pill) -- inferred equivalent call

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 12, 0, 2)
	frame.Rotation = 45
	frame.BackgroundColor3 = StyledTheme.Colors.TextSecondary
	frame.BorderSizePixel = 0
	frame.ZIndex = 4
	frame.Parent = closeButton
	local clone = frame:Clone()
	clone.Rotation = -45
	clone.Parent = closeButton

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -32, 0, 24)
	textLabel.Font = StyledTheme.Fonts.Bold
	textLabel.TextSize = StyledTheme.TextSize.XL
	textLabel.TextColor3 = StyledTheme.Colors.TextPrimary
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = "DIFFICULTY"
	textLabel.LayoutOrder = nextOrder() -- inferred equivalent call
	textLabel.Parent = content

	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(1, 0, 0, 18)
	textLabel2.Font = StyledTheme.Fonts.Medium
	textLabel2.TextSize = StyledTheme.TextSize.M
	textLabel2.TextColor3 = StyledTheme.Colors.TextPrimary
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Text = "Preset"
	textLabel2.LayoutOrder = nextOrder() -- inferred equivalent call
	textLabel2.Parent = content

	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.new(1, 0, 0, 24)
	frame2.LayoutOrder = nextOrder() -- inferred equivalent call
	frame2.Parent = content

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.Padding = UDim.new(0, 6)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = frame2

	local pillButtons = {}

	for i, preset in ipairs(Presets) do
		local pillButton = makePillButton( -- inferred equivalent call
			frame2,
			preset.Label,
			UDim2.new(1 / #Presets, -math.ceil((#Presets - 1) * 6 / #Presets), 1, 0),
			false
		)
		pillButton.LayoutOrder = i
		pillButtons[i] = pillButton
	end

	makeInfoLabel(content, "Presets fill the fields below. Press Apply to use them.", nextOrder()) -- inferred equivalent call

	local frame3 = Instance.new("Frame")
	frame3.BackgroundTransparency = 1
	frame3.Size = UDim2.new(1, 0, 0, 22)
	frame3.LayoutOrder = nextOrder() -- inferred equivalent call
	frame3.Parent = content

	local pillButton = makePillButton(frame3, "Check All", UDim2.new(0, 88, 1, 0), true) -- inferred equivalent call

	local textLabel3 = Instance.new("TextLabel")
	textLabel3.BackgroundTransparency = 1
	textLabel3.Position = UDim2.new(0, 96, 0, 0)
	textLabel3.Size = UDim2.new(1, -96, 1, 0)
	textLabel3.Font = StyledTheme.Fonts.Regular
	textLabel3.TextSize = StyledTheme.TextSize.S
	textLabel3.TextColor3 = StyledTheme.Colors.TextSecondary
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel3.Text = "Turns on Density + Complexity"
	textLabel3.Parent = frame3

	local frame4 = Instance.new("Frame")
	frame4.BackgroundTransparency = 1
	frame4.Size = UDim2.new(1, 0, 0, 22)
	frame4.LayoutOrder = nextOrder() -- inferred equivalent call
	frame4.Parent = content

	local textLabel4 = Instance.new("TextLabel")
	textLabel4.BackgroundTransparency = 1
	textLabel4.Size = UDim2.new(0.5, 0, 1, 0)
	textLabel4.Font = StyledTheme.Fonts.Medium
	textLabel4.TextSize = StyledTheme.TextSize.M
	textLabel4.TextColor3 = StyledTheme.Colors.TextPrimary
	textLabel4.TextXAlignment = Enum.TextXAlignment.Left
	textLabel4.Text = "Note Speed"
	textLabel4.Parent = frame4

	local pillButton2 = makePillButton(frame4, "Reset", UDim2.new(0, 48, 0, 20), false) -- inferred equivalent call
	pillButton2.AnchorPoint = Vector2.new(1, 0.5)
	pillButton2.Position = UDim2.new(1, 0, 0.5, 0)

	local textLabel5 = Instance.new("TextLabel")
	textLabel5.AnchorPoint = Vector2.new(1, 0.5)
	textLabel5.Position = UDim2.new(1, -54, 0.5, 0)
	textLabel5.Size = UDim2.new(0, 56, 1, 0)
	textLabel5.BackgroundTransparency = 1
	textLabel5.Font = StyledTheme.Fonts.Bold
	textLabel5.TextSize = StyledTheme.TextSize.M
	textLabel5.TextColor3 = StyledTheme.Colors.Accent
	textLabel5.TextXAlignment = Enum.TextXAlignment.Right
	textLabel5.Text = "1.00x"
	textLabel5.Parent = frame4

	local frame5 = Instance.new("Frame")
	frame5.BackgroundTransparency = 1
	frame5.Size = UDim2.new(1, 0, 0, 18)
	frame5.LayoutOrder = nextOrder() -- inferred equivalent call
	frame5.Parent = content

	local frame6 = Instance.new("Frame")
	frame6.AnchorPoint = Vector2.new(0, 0.5)
	frame6.Position = UDim2.new(0, 0, 0.5, 0)
	frame6.Size = UDim2.new(1, 0, 0, 6)
	frame6.BackgroundColor3 = StyledTheme.Colors.Surface
	frame6.Parent = frame5
	addCorner(frame6, StyledTheme.Radius.Pill) -- inferred equivalent call

	local frame7 = Instance.new("Frame")
	frame7.Size = UDim2.new(0, 0, 1, 0)
	frame7.BackgroundColor3 = StyledTheme.Colors.Accent
	frame7.BorderSizePixel = 0
	frame7.Parent = frame6
	addCorner(frame7, StyledTheme.Radius.Pill) -- inferred equivalent call

	local textButton = Instance.new("TextButton")
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.Position = UDim2.new(0, 0, 0.5, 0)
	textButton.Size = UDim2.new(0, 16, 0, 16)
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = StyledTheme.Colors.TextPrimary
	textButton.Parent = frame6
	addCorner(textButton, StyledTheme.Radius.Pill) -- inferred equivalent call

	makeInfoLabel(content, "How fast notes fall. Lower = slower.", nextOrder()) -- inferred equivalent call

	local function setSliderVisual(noteSpeed)
		local v2 = math.clamp(noteSpeed, 0.5, 3)
		local v3 = (v2 - 0.5) / 2.5
		frame7.Size = UDim2.new(v3, 0, 1, 0)
		textButton.Position = UDim2.new(v3, 0, 0.5, 0)
		textLabel5.Text = string.format("%.2fx", v2)
	end

	local v2 = false
	local function updateFromInputX(x) -- 2 equivalent calls inferred from this helper
		local x2 = frame6.AbsolutePosition.X
		local x3 = frame6.AbsoluteSize.X

		if x3 <= 0 then
			return
		end

		local v3 = math.floor((math.clamp((x - x2) / x3, 0, 1) * 2.5 + 0.5) * 20 + 0.5) / 20
		NewbieModeState.SetNoteSpeed(v3)
	end

	local function beginDrag(p2)
		if p2.UserInputType == Enum.UserInputType.MouseButton1 or p2.UserInputType == Enum.UserInputType.Touch then
			v2 = true
			updateFromInputX(p2.Position.X) -- inferred equivalent call
		end
	end
	textButton.InputBegan:Connect(beginDrag)
	frame5.InputBegan:Connect(beginDrag)
	UserInputService.InputChanged:Connect(function(input)
		if
			v2
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			updateFromInputX(input.Position.X) -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v2 = false
		end
	end)

	pillButton2.Activated:Connect(function()
		NewbieModeState.SetNoteSpeed(1)
	end)

	local function makeIntensityRow(text, text3, p2, callback)
		local frame8 = Instance.new("Frame")
		frame8.BackgroundTransparency = 1
		frame8.Size = UDim2.new(1, 0, 0, 28)
		frame8.LayoutOrder = nextOrder() -- inferred equivalent call
		frame8.Parent = content

		local textLabel6 = Instance.new("TextLabel")
		textLabel6.BackgroundTransparency = 1
		textLabel6.Size = UDim2.new(1, -88, 1, 0)
		textLabel6.Font = StyledTheme.Fonts.Medium
		textLabel6.TextSize = StyledTheme.TextSize.M
		textLabel6.TextColor3 = StyledTheme.Colors.TextPrimary
		textLabel6.TextXAlignment = Enum.TextXAlignment.Left
		textLabel6.Text = text
		textLabel6.Parent = frame8

		local checkbox, setState = makeCheckbox(frame8)

		local textBox = Instance.new("TextBox")
		textBox.AnchorPoint = Vector2.new(1, 0.5)
		textBox.Position = UDim2.new(1, -34, 0.5, 0)
		textBox.Size = UDim2.new(0, 46, 0, 26)
		textBox.BackgroundColor3 = StyledTheme.Colors.Surface
		textBox.Font = StyledTheme.Fonts.Bold
		textBox.TextSize = StyledTheme.TextSize.M
		textBox.TextColor3 = StyledTheme.Colors.TextPrimary
		textBox.PlaceholderText = "0-10"
		textBox.PlaceholderColor3 = StyledTheme.Colors.TextSecondary
		textBox.ClearTextOnFocus = false
		textBox.Text = "0"
		textBox.Parent = frame8
		addCorner(textBox, StyledTheme.Radius.Large) -- inferred equivalent call

		makeInfoLabel(content, text3, nextOrder()) -- inferred equivalent call

		local v3 = 5

		local function refresh() -- 2 equivalent calls inferred from this helper
			local v4 = NewbieModeState.GetConfig()[p2] or 0

			if v4 > 0 then
				v3 = v4
			end

			textBox.Text = tostring(v4)
			setState(v4 > 0)
		end

		checkbox.Activated:Connect(function()
			if (NewbieModeState.GetConfig()[p2] or 0) > 0 then
				callback(0)
			else
				callback(v3)
			end
		end)

		textBox.FocusLost:Connect(function()
			local text2 = tonumber(textBox.Text)

			if text2 == nil then
				refresh() -- inferred equivalent call
			else
				local v4 = math.clamp(math.floor(text2 + 0.5), 0, 10)

				if v4 ~= (NewbieModeState.GetConfig()[p2] or 0) then
					callback(v4)
					return
				end

				refresh() -- inferred equivalent call
			end
		end)

		return refresh
	end

	local intensityRow = makeIntensityRow(
		"Note Density",
		"The higher the number, the more notes are removed from crowded sections. Default: 0.",
		"NoteDensity",
		NewbieModeState.SetNoteDensity
	)

	local intensityRow2 = makeIntensityRow(
		"Pattern Complexity",
		"The higher the number, the more chords and fast note clusters are simplified. Default: 0.",
		"PatternComplexity",
		NewbieModeState.SetPatternComplexity
	)

	local frame8 = Instance.new("Frame")
	frame8.BackgroundTransparency = 1
	frame8.Size = UDim2.new(1, 0, 0, 20)
	frame8.LayoutOrder = nextOrder() -- inferred equivalent call
	frame8.Parent = content

	local textLabel6 = Instance.new("TextLabel")
	textLabel6.BackgroundTransparency = 1
	textLabel6.Size = UDim2.new(0.5, 0, 1, 0)
	textLabel6.Font = StyledTheme.Fonts.Medium
	textLabel6.TextSize = StyledTheme.TextSize.M
	textLabel6.TextColor3 = StyledTheme.Colors.TextPrimary
	textLabel6.TextXAlignment = Enum.TextXAlignment.Left
	textLabel6.Text = "Lane Count"
	textLabel6.Parent = frame8

	local pillButton3 = makePillButton(frame8, "Reset All", UDim2.new(0, 72, 0, 20), false) -- inferred equivalent call
	pillButton3.AnchorPoint = Vector2.new(1, 0.5)
	pillButton3.Position = UDim2.new(1, 0, 0.5, 0)

	local frame9 = Instance.new("Frame")
	frame9.BackgroundTransparency = 1
	frame9.Size = UDim2.new(1, 0, 0, 28)
	frame9.LayoutOrder = nextOrder() -- inferred equivalent call
	frame9.Parent = content

	local uiListLayout3 = Instance.new("UIListLayout")
	uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout3.Padding = UDim.new(0, 6)
	uiListLayout3.Parent = frame9

	makeInfoLabel(content, "Fewer lanes by merging nearby ones.", nextOrder()) -- inferred equivalent call

	local v3 = {}
	local v4 = nil

	local function getLaneOptions() -- 2 equivalent calls inferred from this helper
		return v4 and RhythmEngineConfig.NewbieLaneCountOptions[v4] or { 2, 3, 4, 5 }
	end

	local function refreshLaneCountBoxes()
		local laneCount = NewbieModeState.GetConfig().LaneCount

		for k, v5 in pairs(v3) do
			local v6 = laneCount == k
			v5.BackgroundColor3 = v6 and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface
			v5.TextColor3 = v6 and StyledTheme.Colors.AccentText or StyledTheme.Colors.TextSecondary
		end
	end

	local function rebuildLaneCountOptions()
		for _, v5 in pairs(v3) do
			v5:Destroy()
		end

		v3 = {}

		for i, v5 in ipairs(getLaneOptions()) do -- inferred equivalent call
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = "Lane_" .. v5
			textButton2.Text = tostring(v5)
			textButton2.AutoButtonColor = false
			textButton2.Size = UDim2.new(0, 44, 1, 0)
			textButton2.LayoutOrder = i
			textButton2.Font = StyledTheme.Fonts.Medium
			textButton2.TextSize = StyledTheme.TextSize.M
			textButton2.BackgroundColor3 = StyledTheme.Colors.Surface
			textButton2.TextColor3 = StyledTheme.Colors.TextSecondary
			textButton2.Parent = frame9
			addCorner(textButton2, StyledTheme.Radius.Large) -- inferred equivalent call

			textButton2.Activated:Connect(function()
				if NewbieModeState.GetConfig().LaneCount == v5 then
					NewbieModeState.SetLaneCount(nil)
				else
					NewbieModeState.SetLaneCount(v5)
				end
			end)

			v3[v5] = textButton2
		end

		refreshLaneCountBoxes()
	end

	instrumentHUDUpdate.OnClientEvent:Connect(function(p2, p3)
		v4 = p2 and p3 or nil

		local laneCount = NewbieModeState.GetConfig().LaneCount

		if laneCount ~= nil then
			local v5 = false

			for _, v6 in ipairs(getLaneOptions()) do -- inferred equivalent call
				if v6 == laneCount then
					v5 = true
					break
				end
			end

			if not v5 then
				NewbieModeState.SetLaneCount(nil)
			end
		end

		rebuildLaneCountOptions()
	end)

	local pillButton4 = makePillButton(content, "Apply", UDim2.new(1, 0, 0, 30), true) -- inferred equivalent call
	pillButton4.TextSize = StyledTheme.TextSize.M
	pillButton4.LayoutOrder = nextOrder() -- inferred equivalent call

	local function updateCheckAllButton() -- 1 equivalent call inferred from this helper
		local config = NewbieModeState.GetConfig()
		local v5

		if (config.NoteDensity or 0) > 0 then
			v5 = (config.PatternComplexity or 0) > 0
		else
			v5 = false
		end

		pillButton.Text = v5 and "Uncheck All" or "Check All"
		textLabel3.Text = v5 and "Turns off Density + Complexity" or "Turns on Density + Complexity"
	end

	local function updatePresetHighlight()
		local config = NewbieModeState.GetConfig()

		for i, preset in ipairs(Presets) do
			local v5

			if config.NoteSpeed == preset.NoteSpeed and (config.NoteDensity or 0) == preset.Density then
				v5 = (config.PatternComplexity or 0) == preset.Complexity
			else
				v5 = false
			end

			local v6 = pillButtons[i]
			v6.BackgroundColor3 = v5 and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface
			v6.TextColor3 = v5 and StyledTheme.Colors.AccentText or StyledTheme.Colors.TextPrimary
		end
	end

	local function refreshAll()
		setSliderVisual(NewbieModeState.GetConfig().NoteSpeed or SettingsState.GetNoteSpeedMultiplier())
		intensityRow()
		intensityRow2()
		refreshLaneCountBoxes()
		updateCheckAllButton() -- inferred equivalent call
		updatePresetHighlight()
	end

	NewbieModeState.OnChanged(refreshAll)

	pillButton.Activated:Connect(function()
		local config = NewbieModeState.GetConfig()

		if (config.NoteDensity or 0) > 0 and (config.PatternComplexity or 0) > 0 then
			NewbieModeState.ClearPreset()
		else
			NewbieModeState.ApplyPreset()
		end
	end)

	for i, preset in ipairs(Presets) do
		pillButtons[i].Activated:Connect(function()
			NewbieModeState.SetAll({
				NoteSpeed = preset.NoteSpeed,
				NoteDensity = preset.Density,
				PatternComplexity = preset.Complexity,
				LaneCount = NewbieModeState.GetConfig().LaneCount
			})
		end)
	end

	local function close() -- 3 equivalent calls inferred from this helper
		v2 = false
		v = p
		newbieModePanelScreenGui.Enabled = false
	end

	pillButton3.Activated:Connect(function()
		NewbieModeState.Disable()
	end)

	closeButton.Activated:Connect(close)

	pillButton4.Activated:Connect(function()
		NewbieModeState.RequestApply()
		close() -- inferred equivalent call
	end)

	UserInputService.InputBegan:Connect(function(input)
		if
			not newbieModePanelScreenGui.Enabled
			or input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local v5 = Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()

		if pointInObject(v5, newbieModePanel, 3) or v and v.Parent and pointInObject(v5, v, 0) then -- inferred equivalent call
			return
		end

		close() -- inferred equivalent call
	end)

	local function positionPanel()
		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
		local v5 = (newbieModePanel.AbsoluteSize.Y > 0 and newbieModePanel.AbsoluteSize.Y or 440) / uiScale.Scale
		local ignoreGuiInset

		if v == nil then
			ignoreGuiInset = false
		else
			ignoreGuiInset = v ~= p
		end

		newbieModePanelScreenGui.IgnoreGuiInset = ignoreGuiInset
		local vector2 = newbieModePanelScreenGui.IgnoreGuiInset and Vector2.new(0, 0) or GuiService:GetGuiInset()

		if ignoreGuiInset and v.Parent then
			local v6, v7 = screenRect(v) -- inferred equivalent call
			local v8 = v6.Y + v7.Y + 8
			local scale = math.clamp((viewportSize.Y - v8 - 8) / v5, 0.55, 1)
			uiScale.Scale = scale
			local v9 = math.clamp(viewportSize.X - 12 - scale * 330, 8, (math.max(8, viewportSize.X - scale * 330 - 8)))
			newbieModePanel.AnchorPoint = Vector2.new(0, 0)
			newbieModePanel.Position = UDim2.fromOffset(v9 - vector2.X, v8 - vector2.Y)
		else
			uiScale.Scale = 1
			local v6, v7

			if v and v.Parent then
				local v8, v9 = screenRect(v) -- inferred equivalent call
				v6 = v8.X + v9.X - 330
				v7 = v8.Y + v9.Y + 8
			else
				v6 = (viewportSize.X - 330) / 2
				v7 = (viewportSize.Y - v5) / 2
			end

			local v8 = math.clamp(v6, 8, (math.max(8, viewportSize.X - 330 - 8)))
			local v9 = math.clamp(v7, 8, (math.max(8, viewportSize.Y - v5 - 8)))

			newbieModePanel.AnchorPoint = Vector2.new(0, 0)
			newbieModePanel.Position = UDim2.fromOffset(v8 - vector2.X, v9 - vector2.Y)
		end
	end

	function self:Show(p2)
		v = p2 or p
		refreshAll()
		rebuildLaneCountOptions()
		newbieModePanelScreenGui.Enabled = true
		positionPanel()

		task.defer(positionPanel)
	end

	function self:Hide()
		close() -- inferred equivalent call
	end

	function self:Toggle()
		if newbieModePanelScreenGui.Enabled then
			self:Hide()
		else
			self:Show()
		end
	end

	self._panelScreenGui = newbieModePanelScreenGui
	self._panel = newbieModePanel

	refreshAll()
	rebuildLaneCountOptions()

	NewbieModePanelUI.Current = self

	return self
end

return NewbieModePanelUI