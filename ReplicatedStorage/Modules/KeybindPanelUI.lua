local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Theme = require(Modules.SongListUI.Theme)
local SettingsState = require(Modules.SettingsState)
local KeybindShare = require(Modules.KeybindShare)
local DrumKeybindRules = require(Modules.DrumKeybindRules)
local FreePlayKeyBindings = require(Modules.FreePlayKeyBindings)
local success, result = pcall(function()
	return require(Modules.RhythmEngineConfig)
end)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local setDrumKeybinds = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SetDrumKeybinds")

local m = Theme.Spacing.M

local v = m * 2 + 38 + 32 + 200 + 30 + 32 + 32

local set = {
	[Enum.KeyCode.Backspace] = true,
	[Enum.KeyCode.Return] = true,
	[Enum.KeyCode.KeypadEnter] = true,
	[Enum.KeyCode.Tab] = true,
	[Enum.KeyCode.Slash] = true
}

local v2 = {}
local v3 = { Rhythm = "Rhythm", Drum = "Freeplay Drum" }

for i = 1, 5 do
	table.insert(v2, {
		Id = "Five" .. i,
		Group = "Five",
		Index = i,
		Label = "Lane " .. i
	})
end

for i = 1, 2 do
	table.insert(v2, {
		Id = "Two" .. i,
		Group = "Two",
		Index = i,
		Label = "Lane " .. i
	})
end

table.insert(v2, { Id = "Pedal", Group = "Pedal", Label = "Normal" })
table.insert(v2, { Id = "PedalFlip", Group = "PedalFlip", Label = "Flipped" })
table.insert(v2, { Id = "Vibrato", Group = "Vibrato", Label = "Vibrato" })
table.insert(v2, { Id = "StarPower", Group = "StarPower", Label = "Star Power" })

local v4 = {
	Five = 1,
	Two = 2,
	Pedal = 3,
	PedalFlip = 3,
	Vibrato = 4,
	StarPower = 4
}
local v5 = { "5-KEY", "2-KEY", "DOUBLE PEDAL", "VIBRATO & STAR POWER" }

local v6 = {
	{
		Name = "CYMBALS",
		Lanes = { 1, 2, 3, 21, 10, 11 }
	},
	{
		Name = "HI-HAT",
		Lanes = { 4, 5, 12, 13 }
	},
	{
		Name = "TOMS",
		Lanes = { 6, 7, 8, 9, 19, 20 }
	},
	{
		Name = "SNARE",
		Lanes = { 14, 15, 16 }
	},
	{
		Name = "KICK",
		Lanes = { 17, 18 }
	},
	{
		Name = "OTHER",
		Lanes = { 22 }
	}
}

local v7 = {
	Five = "KeybindFiveKey",
	Two = "KeybindTwoKey",
	Pedal = "KeybindDoublePedalNormal",
	PedalFlip = "KeybindDoublePedalFlipped",
	Vibrato = "KeybindVibratoRhythm",
	StarPower = "KeybindStarPower"
}

local function fieldFor(p) -- 4 equivalent calls inferred from this helper
	return SettingsState.KeybindField(v7[p])
end

local function rhythmKey(p, spec) -- 1 equivalent call inferred from this helper
	if spec.Index then
		return p[spec.Group][spec.Index]
	end

	return p[spec.Group]
end

local function ownRhythm()
	local names = {}
	local names2 = {}

	for i, v8 in ipairs(SettingsState.GetKeybindFiveKey()) do
		names[i] = v8.Name
	end

	for i, v8 in ipairs(SettingsState.GetKeybindTwoKey()) do
		names2[i] = v8.Name
	end

	return KeybindShare.NormalizeRhythm({
		Five = names,
		Two = names2,
		Pedal = SettingsState.GetDoublePedalKeyNormal().Name,
		PedalFlip = SettingsState.GetDoublePedalKeyFlipped().Name,
		Vibrato = SettingsState.GetVibratoBindingName(),
		StarPower = SettingsState.GetStarPowerBindingName()
	})
end

local function ownDrum()
	local names = {}

	for i = 1, DrumKeybindRules.LANE_COUNT do
		local v8 = FreePlayKeyBindings.Drum[i]

		if not v8 then
			return nil
		end

		names[i] = v8.Name
	end

	return names
end

local function readData(instance, tab)
	if tab == "Rhythm" then
		if instance == LocalPlayer then
			return ownRhythm()
		end

		local v8 = instance:GetAttribute(KeybindShare.INPUT_MODE_ATTRIBUTE) == "Controller"

		if SettingsState.IsControllerMode() then
			if v8 then
				return KeybindShare.DecodeRhythm(instance:GetAttribute(KeybindShare.RHYTHM_PAD_ATTRIBUTE))
			end

			return nil
		elseif v8 then
			return nil
		else
			return KeybindShare.DecodeRhythm(instance:GetAttribute(KeybindShare.RHYTHM_ATTRIBUTE))
		end
	elseif instance == LocalPlayer then
		return ownDrum()
	else
		return KeybindShare.DecodeDrum(instance:GetAttribute(KeybindShare.DRUM_ATTRIBUTE))
	end
end

local function dataEqual(tab, p, p2) -- 1 equivalent call inferred from this helper
	if tab == "Rhythm" then
		return KeybindShare.RhythmEqual(p, p2)
	end

	return KeybindShare.DrumEqual(p, p2)
end

local function applyRhythm(data)
	if SettingsState.IsControllerMode() then
		SettingsState.SetFields({
			KeybindFiveKeyPad = table.clone(data.Five),
			KeybindTwoKeyPad = table.clone(data.Two),
			KeybindDoublePedalNormalPad = data.Pedal,
			KeybindDoublePedalFlippedPad = data.PedalFlip,
			KeybindStarPowerPad = data.StarPower
		})
	else
		SettingsState.SetFields({
			KeybindFiveKey = table.clone(data.Five),
			KeybindTwoKey = table.clone(data.Two),
			KeybindDoublePedalNormal = data.Pedal,
			KeybindDoublePedalFlipped = data.PedalFlip,
			KeybindVibratoRhythm = data.Vibrato,
			KeybindStarPower = data.StarPower
		})
	end
end

local function applyDrum(list): boolean
	if not DrumKeybindRules.Validate(list) then
		return false
	end

	for i = 1, DrumKeybindRules.LANE_COUNT do
		FreePlayKeyBindings.Drum[i] = Enum.KeyCode[list[i]]
	end

	setDrumKeybinds:FireServer(table.clone(list))
	return true
end

local function laneKeysContain(data, p): boolean
	for _, v8 in ipairs(data.Five) do
		if v8 == p then
			return true
		end
	end

	for _, v8 in ipairs(data.Two) do
		if v8 == p then
			return true
		end
	end

	if data.Pedal == p or data.PedalFlip == p then
		return true
	end

	if success and result.GetNewbieKeybinds then
		for _, v8 in ipairs({ 3, 4 }) do
			local success2, newbieKeybinds = pcall(result.GetNewbieKeybinds, v8)

			if not (success2 and typeof(newbieKeybinds) == "table") then
				continue
			end

			for _, newbieKeybind in ipairs(newbieKeybinds) do
				if newbieKeybind.Name == p then
					return true
				end
			end
		end
	end

	return false
end

local function editRhythm(row, name)
	local v8 = ownRhythm()

	if not v8 then
		return false, "Keybinds aren't loaded yet."
	end

	local group = row.Group

	if group == "Vibrato" or group == "StarPower" then
		if name == (group == "Vibrato" and v8.StarPower or v8.Vibrato) or laneKeysContain(v8, name) then
			return false, "Key in use."
		end

		SettingsState.SetField(fieldFor(group), name, true) -- inferred equivalent call
		return true
	end

	if name == v8.StarPower or v8.Vibrato ~= "LeftControl" and name == v8.Vibrato then
		return false, "Key in use."
	end

	if group == "Five" or group == "Two" then
		local clone = table.clone(v8[group])
		local v9 = clone[row.Index]

		for i, v10 in ipairs(clone) do
			if i ~= row.Index and v10 == name then
				clone[i] = v9
				break
			end
		end

		clone[row.Index] = name
		SettingsState.SetField(fieldFor(group), clone, true) -- inferred equivalent call
		return true
	else
		local v9 = group == "Pedal" and "PedalFlip" or "Pedal"

		if v8[v9] == name then
			SettingsState.SetField(fieldFor(v9), v8[group], true) -- inferred equivalent call
		end

		SettingsState.SetField(fieldFor(group), name, true) -- inferred equivalent call
		return true
	end
end

local function editDrum(lane, name)
	if DrumKeybindRules.IsModifierName(name) then
		return false, "Shift, Ctrl and Alt can't be used."
	end

	if not DrumKeybindRules.IsAllowedName(name) then
		return false, "That key can't be used."
	end

	local v8 = ownDrum()

	if not v8 then
		return false, "Keybinds aren't loaded yet."
	end

	local v9 = v8[lane]

	for i = 1, DrumKeybindRules.LANE_COUNT do
		if i ~= lane and v8[i] == name then
			v8[i] = v9
			break
		end
	end

	v8[lane] = name

	if applyDrum(v8) then
		return true
	end

	return false, "That key can't be used."
end

local function addCorner(parent, cornerRadius) -- 5 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = cornerRadius
	uiCorner.Parent = parent
	return uiCorner
end

local function addStroke(parent, color, transparencyDefault, value) -- 6 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Transparency = transparencyDefault
	uiStroke.Thickness = value or 1
	uiStroke.Parent = parent
	return uiStroke
end

local function makeLabel(parent, name, size, font, textSize, textColor) -- 6 equivalent calls inferred from this helper
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.Size = size
	textLabel.Font = font
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = ""
	textLabel.Parent = parent
	return textLabel
end

local function makeButton(parent, name, text, size, backgroundColor, textColor) -- 6 equivalent calls inferred from this helper
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Size = size
	textButton.BackgroundColor3 = backgroundColor
	textButton.Font = Theme.Fonts.Bold
	textButton.TextSize = Theme.TextSize.S
	textButton.TextColor3 = textColor
	textButton.Text = text
	textButton.AutoButtonColor = false
	textButton.Parent = parent
	addCorner(textButton, Theme.Radius.Small) -- inferred equivalent call
	return textButton
end

return {
	Init = function(data)
		local v8 = {
			Open = false,
			Target = nil,
			Tab = "Rhythm",
			Capturing = nil,
			Pending = nil,
			StatusText = "",
			StatusError = false
		}

		local v9 = {}
		local v10 = {}
		local connections = {}

		local keybindPanelGui = Instance.new("ScreenGui")
		keybindPanelGui.Name = "KeybindPanelGui"
		keybindPanelGui.ResetOnSpawn = false
		keybindPanelGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		keybindPanelGui.DisplayOrder = 55
		keybindPanelGui.Enabled = false
		keybindPanelGui.Parent = PlayerGui

		local catcher = Instance.new("TextButton")
		catcher.Name = "Catcher"
		catcher.Size = UDim2.fromScale(1, 1)
		catcher.BackgroundTransparency = 1
		catcher.Text = ""
		catcher.AutoButtonColor = false
		catcher.ZIndex = Theme.ZIndex.Overlay
		catcher.Parent = keybindPanelGui

		local keybindPanel = Instance.new("Frame")
		keybindPanel.Name = "KeybindPanel"
		keybindPanel.Size = UDim2.fromOffset(268, v)
		keybindPanel.BackgroundColor3 = Theme.Colors.Surface
		keybindPanel.ZIndex = Theme.ZIndex.Overlay + 1
		keybindPanel.Parent = keybindPanelGui
		addCorner(keybindPanel, Theme.Radius.Medium) -- inferred equivalent call
		addStroke(keybindPanel, Theme.Colors.Border, Theme.Stroke.TransparencyDefault) -- inferred equivalent call

		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, m)
		uiPadding.PaddingRight = UDim.new(0, m)
		uiPadding.PaddingTop = UDim.new(0, m)
		uiPadding.PaddingBottom = UDim.new(0, m)
		uiPadding.Parent = keybindPanel

		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Vertical
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Padding = UDim.new(0, 8)
		uiListLayout.Parent = keybindPanel

		keybindPanel.MouseEnter:Connect(data.LockZoom)
		keybindPanel.MouseLeave:Connect(data.UnlockZoom)

		local header = Instance.new("Frame")
		header.Name = "Header"
		header.LayoutOrder = 1
		header.Size = UDim2.new(1, 0, 0, 38)
		header.BackgroundTransparency = 1
		header.Parent = keybindPanel

		v9.Caption = makeLabel( -- inferred equivalent call
			header,
			"Caption",
			UDim2.new(1, 0, 0, 16),
			Theme.Fonts.Bold,
			Theme.TextSize.XS,
			Theme.Colors.Accent
		)
		v9.Caption.TextYAlignment = Enum.TextYAlignment.Center

		v9.Title = makeLabel( -- inferred equivalent call
			header,
			"Title",
			UDim2.new(1, 0, 0, 22),
			Theme.Fonts.Bold,
			Theme.TextSize.L,
			Theme.Colors.TextPrimary
		)
		v9.Title.Position = UDim2.fromOffset(0, 16)
		v9.Title.TextYAlignment = Enum.TextYAlignment.Center
		v9.Title.TextTruncate = Enum.TextTruncate.AtEnd

		local tabs = Instance.new("Frame")
		tabs.Name = "Tabs"
		tabs.LayoutOrder = 2
		tabs.Size = UDim2.new(1, 0, 0, 32)
		tabs.BackgroundColor3 = Theme.Colors.SurfaceHover
		tabs.Parent = keybindPanel
		addCorner(tabs, Theme.Radius.Small) -- inferred equivalent call
		addStroke(tabs, Theme.Colors.Border, Theme.Stroke.TransparencyDefault) -- inferred equivalent call

		local uiPadding2 = Instance.new("UIPadding")
		uiPadding2.PaddingLeft = UDim.new(0, 3)
		uiPadding2.PaddingRight = UDim.new(0, 3)
		uiPadding2.PaddingTop = UDim.new(0, 3)
		uiPadding2.PaddingBottom = UDim.new(0, 3)
		uiPadding2.Parent = tabs

		v9.Tabs = {}
		local tabs2 = v9.Tabs
		tabs2.Rhythm = makeButton( -- inferred equivalent call
			tabs,
			"RhythmTab",
			"Rhythm",
			UDim2.new(0.5, -2, 1, 0),
			Theme.Colors.SurfaceHover,
			Theme.Colors.TextSecondary
		)
		v9.Tabs.Rhythm.Position = UDim2.new(0, 0, 0, 0)
		local tabs3 = v9.Tabs
		tabs3.Drum = makeButton( -- inferred equivalent call
			tabs,
			"DrumTab",
			"Freeplay Drum",
			UDim2.new(0.5, -2, 1, 0),
			Theme.Colors.SurfaceHover,
			Theme.Colors.TextSecondary
		)
		v9.Tabs.Drum.Position = UDim2.new(0.5, 2, 0, 0)

		v9.List = Instance.new("ScrollingFrame")
		v9.List.Name = "List"
		v9.List.LayoutOrder = 3
		v9.List.Size = UDim2.new(1, 0, 0, 200)
		v9.List.BackgroundTransparency = 1
		v9.List.BorderSizePixel = 0
		v9.List.CanvasSize = UDim2.new()
		v9.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
		v9.List.ScrollBarThickness = 3
		v9.List.ScrollBarImageColor3 = Theme.Colors.Border
		v9.List.ScrollingDirection = Enum.ScrollingDirection.Y
		v9.List.Parent = keybindPanel

		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.FillDirection = Enum.FillDirection.Vertical
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.Padding = UDim.new(0, 2)
		uiListLayout2.Parent = v9.List

		v9.Empty = makeLabel( -- inferred equivalent call
			v9.List,
			"Empty",
			UDim2.new(1, 0, 0, 40),
			Theme.Fonts.Regular,
			Theme.TextSize.S,
			Theme.Colors.TextDisabled
		)
		v9.Empty.TextWrapped = true
		v9.Empty.TextYAlignment = Enum.TextYAlignment.Center
		v9.Empty.Text = "Keybinds aren't available yet."
		v9.Empty.Visible = false

		v9.Status = makeLabel( -- inferred equivalent call
			keybindPanel,
			"Status",
			UDim2.new(1, 0, 0, 30),
			Theme.Fonts.Regular,
			Theme.TextSize.XS,
			Theme.Colors.TextDisabled
		)
		v9.Status.LayoutOrder = 4
		v9.Status.TextWrapped = true
		v9.Status.TextYAlignment = Enum.TextYAlignment.Center

		local footer = Instance.new("Frame")
		footer.Name = "Footer"
		footer.LayoutOrder = 5
		footer.Size = UDim2.new(1, 0, 0, 32)
		footer.BackgroundTransparency = 1
		footer.Parent = keybindPanel

		v9.Copy = makeButton( -- inferred equivalent call
			footer,
			"Copy",
			"COPY",
			UDim2.new(1, 0, 1, 0),
			Theme.Colors.Accent,
			Theme.Colors.AccentText
		)
		v9.Reset = makeButton( -- inferred equivalent call
			footer,
			"Reset",
			"RESET",
			UDim2.new(1, 0, 1, 0),
			Theme.Colors.SurfaceHover,
			Theme.Colors.TextPrimary
		)
		addStroke(v9.Reset, Theme.Colors.Border, Theme.Stroke.TransparencyDefault) -- inferred equivalent call
		v9.Cancel = makeButton( -- inferred equivalent call
			footer,
			"Cancel",
			"Cancel",
			UDim2.new(0.5, -3, 1, 0),
			Theme.Colors.SurfaceHover,
			Theme.Colors.TextSecondary
		)
		addStroke(v9.Cancel, Theme.Colors.Border, Theme.Stroke.TransparencyDefault) -- inferred equivalent call
		v9.Apply = makeButton( -- inferred equivalent call
			footer,
			"Apply",
			"APPLY",
			UDim2.new(0.5, -3, 1, 0),
			Theme.Colors.Accent,
			Theme.Colors.AccentText
		)
		v9.Apply.Position = UDim2.new(0.5, 3, 0, 0)

		local function setStatus(value, p)
			v8.StatusText = value or ""
			v8.StatusError = p == true
		end

		local function refreshFooter()
			local target = v8.Target
			local visible = target == LocalPlayer
			local visible2 = v8.Pending ~= nil
			local v11 = target and readData(target, v8.Tab)

			local copy = v9.Copy
			copy.Visible = target ~= nil and not (visible or visible2)
			v9.Reset.Visible = visible
			v9.Cancel.Visible = visible2
			v9.Apply.Visible = visible2
			local v12 = v11 ~= nil
			v9.Copy.BackgroundTransparency = v12 and 0 or 0.6
			v9.Copy.TextTransparency = v12 and 0 or 0.5
			local text, textColor

			if visible2 and target then
				text = string.format("Replace your %s keybinds with %s's?", v3[v8.Tab], target.DisplayName)
				textColor = Theme.Colors.Accent
			elseif v8.StatusText == "" then
				if visible then
					textColor = Theme.Colors.TextDisabled
					text = "Click a row, then press a new key. ESC cancels."
				else
					textColor = Theme.Colors.TextDisabled
					text = "Preview only. COPY replaces your own keybinds."
				end
			else
				text = v8.StatusText
				textColor = v8.StatusError and Theme.Colors.Danger or Theme.Colors.TextSecondary
			end

			v9.Status.Text = text
			v9.Status.TextColor3 = textColor
		end

		local function updateRows()
			local target = v8.Target

			if not target then
				return
			end

			local v11 = readData(target, v8.Tab)
			v9.Empty.Visible = v11 == nil

			for _, v12 in ipairs(v9.Spacers or {}) do
				v12.Visible = v11 ~= nil
			end

			for _, v12 in ipairs(v10) do
				v12.Row.Visible = v11 ~= nil

				if not v11 then
					continue
				end

				local v13

				if v8.Tab == "Rhythm" then
					v13 = rhythmKey(v11, v12.Spec) -- inferred equivalent call
				else
					v13 = v11[v12.Spec.Lane]
				end

				local v14 = v8.Capturing == v12.Spec.Id
				v12.Chip.Text = v14 and "..." or KeybindShare.DisplayKey(v13)
				v12.Stroke.Transparency = v14 and 0 or 1
				v12.Chip.TextColor3 = v14 and Theme.Colors.Accent or Theme.Colors.TextPrimary
			end
		end

		local fn

		local function buildRows()
			for _, v11 in ipairs(v10) do
				v11.Row:Destroy()
			end

			table.clear(v10)

			for _, v11 in ipairs(v9.Spacers or {}) do
				v11:Destroy()
			end

			v9.Spacers = {}
			v9.List.CanvasPosition = Vector2.zero

			local v11 = {}
			local names

			if v8.Tab == "Rhythm" then
				names = v5

				for _, row in ipairs(v2) do
					if row.Group ~= "Vibrato" or not SettingsState.IsControllerMode() then
						table.insert(v11, {
							Id = row.Id,
							Label = row.Label,
							Group = row.Group,
							Index = row.Index,
							Row = row,
							Section = v4[row.Group]
						})
					end
				end
			else
				names = {}

				for i, v12 in ipairs(v6) do
					names[i] = v12.Name

					for _, lane in ipairs(v12.Lanes) do
						table.insert(v11, {
							Id = lane,
							Label = KeybindShare.DrumLaneLabels[lane],
							Lane = lane,
							Section = i
						})
					end
				end
			end

			local active = v8.Target == LocalPlayer

			for i, spec in ipairs(v11) do
				if spec.Section ~= nil and (i == 1 or spec.Section ~= v11[i - 1].Section) then
					local sectionHeader = Instance.new("Frame")
					sectionHeader.Name = "SectionHeader"
					sectionHeader.LayoutOrder = i * 2
					sectionHeader.Size = UDim2.new(1, -6, 0, 26)
					sectionHeader.BackgroundTransparency = 1
					sectionHeader.Parent = v9.List

					local label = makeLabel( -- inferred equivalent call
						sectionHeader,
						"Label",
						UDim2.new(1, -4, 1, -4),
						Theme.Fonts.Bold,
						Theme.TextSize.XS,
						Theme.Colors.TextDisabled
					)
					label.Position = UDim2.fromOffset(4, 0)
					label.TextYAlignment = Enum.TextYAlignment.Bottom
					label.Text = names[spec.Section] or ""

					local line = Instance.new("Frame")
					line.Name = "Line"
					line.AnchorPoint = Vector2.new(0, 1)
					line.Position = UDim2.new(0, 0, 1, 0)
					line.Size = UDim2.new(1, 0, 0, 1)
					line.BackgroundColor3 = Theme.Colors.Border
					line.BackgroundTransparency = 0.55
					line.BorderSizePixel = 0
					line.Parent = sectionHeader

					table.insert(v9.Spacers, sectionHeader)
				end

				local row = Instance.new("TextButton")
				row.Name = "Row"
				row.LayoutOrder = i * 2 + 1
				row.Size = UDim2.new(1, -6, 0, 28)
				row.BackgroundColor3 = Theme.Colors.SurfaceHover
				row.BackgroundTransparency = 0.6
				row.Text = ""
				row.AutoButtonColor = false
				row.Active = active
				row.Parent = v9.List
				addCorner(row, Theme.Radius.Small) -- inferred equivalent call
				local stroke = addStroke(row, Theme.Colors.Accent, 1) -- inferred equivalent call

				local label = makeLabel( -- inferred equivalent call
					row,
					"Name",
					UDim2.new(1, -84, 1, 0),
					Theme.Fonts.Medium,
					Theme.TextSize.S,
					Theme.Colors.TextSecondary
				)
				label.Position = UDim2.fromOffset(10, 0)
				label.TextYAlignment = Enum.TextYAlignment.Center
				label.TextTruncate = Enum.TextTruncate.AtEnd
				label.Text = spec.Label

				local chip = Instance.new("TextLabel")
				chip.Name = "Chip"
				chip.AnchorPoint = Vector2.new(1, 0.5)
				chip.Position = UDim2.new(1, -4, 0.5, 0)
				chip.Size = UDim2.fromOffset(78, 20)
				chip.BackgroundColor3 = Theme.Colors.Surface
				chip.Font = Theme.Fonts.Bold
				chip.TextSize = Theme.TextSize.S
				chip.TextColor3 = Theme.Colors.TextPrimary
				chip.TextTruncate = Enum.TextTruncate.AtEnd
				chip.Text = ""
				chip.Parent = row
				addCorner(chip, Theme.Radius.Small) -- inferred equivalent call
				addStroke(chip, Theme.Colors.Border, 0.35) -- inferred equivalent call

				if active then
					row.MouseButton1Click:Connect(function()
						fn(spec.Id)
					end)

					row.MouseEnter:Connect(function()
						row.BackgroundTransparency = 0.3
					end)
					row.MouseLeave:Connect(function()
						row.BackgroundTransparency = 0.6
					end)
				end

				table.insert(v10, { Spec = spec, Row = row, Chip = chip, Stroke = stroke })
			end

			updateRows()
		end

		local function refreshTabs()
			for k, tab in pairs(v9.Tabs) do
				local v11 = k == v8.Tab
				tab.BackgroundColor3 = Theme.Colors.SurfaceSelected
				tab.BackgroundTransparency = v11 and 0 or 1
				tab.Font = v11 and Theme.Fonts.Bold or Theme.Fonts.Medium
				tab.TextColor3 = v11 and Theme.Colors.Accent or Theme.Colors.TextSecondary
			end
		end

		local function refreshTitle() -- 1 equivalent call inferred from this helper
			local target = v8.Target

			if not target then
				return
			end

			v9.Caption.Text = target == LocalPlayer and "YOUR KEYBINDS" or "KEYBINDS"
			v9.Title.Text = target.DisplayName
		end

		local function renderAll() -- 1 equivalent call inferred from this helper
			refreshTitle() -- inferred equivalent call
			refreshTabs()
			updateRows()
			refreshFooter()
		end

		local function place()
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
			local card = data.Card

			local v11 = card.AbsolutePosition.X + card.AbsoluteSize.X + 8

			if v11 + 268 > viewportSize.X - 8 then
				v11 = card.AbsolutePosition.X - 268 - 8
			end

			local v12 = math.clamp(v11, 8, (math.max(8, viewportSize.X - 268 - 8)))

			local v13 = math.clamp(
				card.AbsolutePosition.Y + card.AbsoluteSize.Y - v,
				8,
				(math.max(8, viewportSize.Y - v - 8))
			)

			keybindPanel.Position = UDim2.fromOffset(v12, v13)
		end

		local function disconnectTarget() -- 2 equivalent calls inferred from this helper
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end

			table.clear(connections)
		end

		local function close(p) -- 3 equivalent calls inferred from this helper
			local open = v8.Open
			v8.Open = false
			v8.Capturing = nil
			v8.Pending = nil
			v8.StatusText = ""
			v8.StatusError = false

			keybindPanelGui.Enabled = false
			disconnectTarget() -- inferred equivalent call
			data.UnlockZoom()

			if open then
				data.OnOpenChanged(false, p)
			end
		end

		local function open()
			local player = data.GetPlayer()

			if not player or player.Parent ~= Players then
				return
			end

			disconnectTarget() -- inferred equivalent call
			v8.Target = player
			v8.Tab = "Rhythm"
			v8.Capturing = nil
			v8.Pending = nil
			v8.StatusText = ""
			v8.StatusError = false

			for _, v11 in ipairs({
				KeybindShare.RHYTHM_ATTRIBUTE,
				KeybindShare.RHYTHM_PAD_ATTRIBUTE,
				KeybindShare.INPUT_MODE_ATTRIBUTE,
				KeybindShare.DRUM_ATTRIBUTE
			}) do
				table.insert(connections, player:GetAttributeChangedSignal(v11):Connect(function()
					if v8.Open and v8.Target == player then
						updateRows()
						refreshFooter()
					end
				end))
			end

			v8.Open = true
			buildRows()
			renderAll() -- inferred equivalent call
			place()
			keybindPanelGui.Enabled = true
			data.OnOpenChanged(true)
		end

		fn = function(id)
			if v8.Target ~= LocalPlayer then
				return
			end

			v8.Capturing = id
			v8.StatusText = ""
			v8.StatusError = false

			updateRows()
			refreshFooter()
		end

		local function findSpec(capturing) -- 1 equivalent call inferred from this helper
			for _, v11 in ipairs(v10) do
				if v11.Spec.Id == capturing then
					return v11.Spec
				end
			end

			return nil
		end

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not v8.Open or v8.Capturing == nil or v8.Target ~= LocalPlayer then
				return
			end

			local v11 = string.sub(input.UserInputType.Name, 1, 7) == "Gamepad"
			local v12 = SettingsState.IsControllerMode() and v8.Tab == "Rhythm"

			if v12 then
				if v11 then
					local name = input.KeyCode.Name

					if string.sub(name, 1, 6) ~= "Button" and string.sub(name, 1, 4) ~= "DPad" then
						return
					end
				elseif input.KeyCode ~= Enum.KeyCode.Escape then
					return
				end
			elseif input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.Escape then
				v8.Capturing = nil
				updateRows()
				refreshFooter()
			else
				if gameProcessed and not (set[keyCode] or v12 and v11) or keyCode == Enum.KeyCode.Unknown then
					return
				end

				local spec = findSpec(v8.Capturing) -- inferred equivalent call

				v8.Capturing = nil

				if spec then
					local v13, v14

					if set[keyCode] then
						v13 = false
						v14 = "That key can't be used."
					elseif v8.Tab == "Rhythm" then
						v13, v14 = editRhythm(spec.Row, keyCode.Name)
					else
						v13, v14 = editDrum(spec.Lane, keyCode.Name)
					end

					if v13 then
						v8.StatusText = ""
						v8.StatusError = false
					else
						v8.StatusText = v14 or "That key can't be used." or ""
						v8.StatusError = true
					end

					updateRows()
					refreshFooter()
				else
					updateRows()
					refreshFooter()
				end
			end
		end)

		SettingsState.OnChanged(function()
			if v8.Open and v8.Target == LocalPlayer then
				updateRows()
			end
		end)
		LocalPlayer:GetAttributeChangedSignal(KeybindShare.DRUM_ATTRIBUTE):Connect(function()
			if v8.Open and v8.Target == LocalPlayer then
				updateRows()
			end
		end)

		for k, tab in pairs(v9.Tabs) do
			tab.MouseButton1Click:Connect(function()
				if v8.Tab == k then
					return
				end

				v8.Tab = k
				v8.Capturing = nil
				v8.Pending = nil
				v8.StatusText = ""
				v8.StatusError = false

				buildRows()
				refreshTabs()
				refreshFooter()
			end)
		end

		v9.Copy.MouseButton1Click:Connect(function()
			local target = v8.Target

			if not target or target == LocalPlayer then
				return
			end

			if target.Parent == Players then
				local pending = readData(target, v8.Tab)

				if pending then
					if dataEqual(v8.Tab, readData(LocalPlayer, v8.Tab), pending) then -- inferred equivalent call
						v8.StatusText = "You already use the same keybinds."
						v8.StatusError = false
					else
						v8.StatusText = ""
						v8.StatusError = false

						v8.Pending = pending
					end
				else
					v8.StatusText = "Their keybinds aren't available yet."
					v8.StatusError = true
				end

				refreshFooter()
			else
				v8.StatusText = "That player left."
				v8.StatusError = true

				refreshFooter()
			end
		end)

		v9.Cancel.MouseButton1Click:Connect(function()
			v8.Pending = nil
			v8.StatusText = ""
			v8.StatusError = false

			refreshFooter()
		end)

		v9.Apply.MouseButton1Click:Connect(function()
			local target = v8.Target
			local pending = v8.Pending

			if not (target and pending) then
				return
			end

			v8.Pending = nil

			if target.Parent == Players then
				if v8.Tab == "Rhythm" then
					applyRhythm(pending)
				elseif not applyDrum(pending) then
					v8.StatusText = "Couldn't apply those keybinds."
					v8.StatusError = true

					refreshFooter()
					return
				end

				data.Toast(string.format("Copied %s's %s keybinds", target.DisplayName, v3[v8.Tab]))
				v8.StatusText = "Applied."
				v8.StatusError = false
			else
				v8.StatusText = "That player left."
				v8.StatusError = true
			end

			refreshFooter()
		end)

		v9.Reset.MouseButton1Click:Connect(function()
			if v8.Target ~= LocalPlayer then
				return
			end

			v8.Capturing = nil

			if v8.Tab == "Rhythm" then
				applyRhythm(SettingsState.IsControllerMode() and KeybindShare.CopyRhythmDefaultsPad() or KeybindShare.CopyRhythmDefaults())
			else
				applyDrum(DrumKeybindRules.CopyDefaults())
			end

			v8.StatusText = "Reset to default."
			v8.StatusError = false

			updateRows()
			refreshFooter()
		end)

		catcher.MouseButton1Click:Connect(function()
			close(nil) -- inferred equivalent call
		end)

		Players.PlayerRemoving:Connect(function(player)
			if v8.Open and v8.Target == player and player ~= LocalPlayer then
				v8.Pending = nil
				v8.StatusText = "That player left."
				v8.StatusError = true

				refreshFooter()
			end
		end)

		local success2, result2 = pcall(function()
			return require(Modules.SongListUI.UISkin)
		end)

		if success2 and result2 and result2.AddRoot then
			result2.AddRoot(keybindPanelGui)
		end

		return {
			Toggle = function()
				if v8.Open then
					close(nil) -- inferred equivalent call
				else
					open()
				end
			end,
			Close = function(p)
				close(p) -- inferred equivalent call
			end,
			IsOpen = function()
				return v8.Open
			end
		}
	end
}