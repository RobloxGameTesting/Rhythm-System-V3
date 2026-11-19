local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent

local Theme = require(parent.Theme)
local Retro = require(parent.Retro)
local FilterBar = require(parent.FilterBar)
local PrimaryButton = require(parent.PrimaryButton)
local SegmentedSlider = require(parent.SegmentedSlider)
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)

local LaptopStemConfigPanel = {}
LaptopStemConfigPanel.__index = LaptopStemConfigPanel

local v = { "Drum", "Bass", "GuitarRhythm", "GuitarLead", "Keyboard", "Piano" }

local items = { "OFF", "5s", "10s", "15s" }

local function formatVolume(p) -- 1 equivalent call inferred from this helper
	return string.format("%d%%", (math.round(p * 100)))
end

local function createMiniToggle(toggleHolder)
	local checkbox = Instance.new("TextButton")
	checkbox.Name = "Checkbox"
	checkbox.Text = ""
	checkbox.AutoButtonColor = false
	checkbox.AnchorPoint = Vector2.new(0.5, 0.5)
	checkbox.Position = UDim2.new(0.5, 0, 0.5, 0)
	checkbox.Size = UDim2.new(0, 16, 0, 16)

	checkbox.BackgroundColor3 = Color3.fromRGB(95, 95, 108)
	checkbox.Parent = toggleHolder

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Small
	uiCorner.Parent = checkbox

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Theme.Colors.Accent
	uiStroke.Transparency = 0
	uiStroke.Parent = checkbox

	local checkIcon = Instance.new("ImageLabel")
	checkIcon.Name = "CheckIcon"
	checkIcon.BackgroundTransparency = 1
	checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	checkIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	checkIcon.Size = UDim2.new(0.72, 0, 0.72, 0)
	checkIcon.Image = "rbxassetid://12690727184"
	checkIcon.ImageColor3 = Color3.new(1, 1, 1)
	checkIcon.ScaleType = Enum.ScaleType.Fit
	checkIcon.Visible = false
	checkIcon.Parent = checkbox

	local lockedLabel = Instance.new("TextLabel")
	lockedLabel.Name = "LockedLabel"
	lockedLabel.BackgroundTransparency = 1
	lockedLabel.Size = UDim2.new(1, 0, 1, 0)
	lockedLabel.Font = Theme.Fonts.Medium
	lockedLabel.TextSize = Theme.TextSize.XS
	lockedLabel.TextColor3 = Theme.Colors.Danger
	lockedLabel.TextXAlignment = Enum.TextXAlignment.Center
	lockedLabel.TextWrapped = true
	lockedLabel.Text = "In Use"
	lockedLabel.Visible = false
	lockedLabel.Parent = toggleHolder

	local state = false
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = checkbox

	local miniToggle = {
		["Toggled"] = bindableEvent.Event,
		GetState = function(self)
			return state
		end,
		SetState = function(self, p, p2)
			if state == p then
				return
			end

			state = p

			checkIcon.Visible = state

			if not p2 then
				bindableEvent:Fire(state)
			end
		end,
		SetLocked = function(self, visible)
			checkbox.Visible = not visible
			lockedLabel.Visible = visible
		end
	}

	checkbox.MouseButton1Click:Connect(function()
		miniToggle:SetState(not state)
	end)

	miniToggle:SetState(false, true)
	return miniToggle
end

function LaptopStemConfigPanel.new(parent2)
	local laptopStemConfigPanel = Instance.new("Frame")
	laptopStemConfigPanel.Name = "LaptopStemConfigPanel"
	laptopStemConfigPanel.BackgroundTransparency = 1
	laptopStemConfigPanel.Size = UDim2.new(1, 0, 1, 0)
	laptopStemConfigPanel.ClipsDescendants = true
	laptopStemConfigPanel.Visible = false
	laptopStemConfigPanel.Parent = parent2
	Retro.AttachScreenFrame(laptopStemConfigPanel)

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.Padding = UDim.new(0, Theme.Spacing.XS)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = laptopStemConfigPanel

	local uiPadding = Instance.new("UIPadding")

	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.PaddingTop = UDim.new(0, 10)
	uiPadding.PaddingBottom = UDim.new(0, 24)
	uiPadding.Parent = laptopStemConfigPanel

	local headerRow = Instance.new("Frame")
	headerRow.Name = "HeaderRow"

	headerRow.BackgroundColor3 = Color3.new(1, 1, 1)
	headerRow.Size = UDim2.new(1, -(Theme.Sizes.IconButtonSize + 6), 0, Theme.Sizes.IconButtonSize)
	headerRow.LayoutOrder = 1
	headerRow.Parent = laptopStemConfigPanel

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Medium
	uiCorner.Parent = headerRow
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new(Theme.Colors.TitleTop, Theme.Colors.TitleBottom)
	uiGradient.Parent = headerRow
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Theme.Colors.BorderHover
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = headerRow

	local backButton = Instance.new("TextButton")
	backButton.Name = "BackButton"
	backButton.AnchorPoint = Vector2.new(0, 0.5)
	backButton.Position = UDim2.new(0, 3, 0.5, 0)
	backButton.Size = UDim2.new(0, Theme.Sizes.IconButtonSize - 6, 0, Theme.Sizes.IconButtonSize - 6)
	backButton.BackgroundColor3 = Color3.fromRGB(96, 99, 108)
	backButton.AutoButtonColor = false
	backButton.Text = "<"
	backButton.Font = Theme.Fonts.Bold
	backButton.TextSize = Theme.TextSize.XL
	backButton.TextColor3 = Color3.new(1, 1, 1)
	backButton.Parent = headerRow

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = Theme.Radius.Small
	uiCorner2.Parent = backButton
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 1
	uiStroke2.Color = Color3.fromRGB(150, 153, 162)
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Parent = backButton
	Retro.AddGloss(backButton)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -(Theme.Sizes.IconButtonSize + 8), 1, 0)
	title.Position = UDim2.new(0, Theme.Sizes.IconButtonSize + 2, 0, 0)
	title.Font = Theme.Fonts.Bold
	title.TextSize = Theme.TextSize.L
	title.TextColor3 = Theme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Text = ""
	title.Parent = headerRow

	local instrumentScroll = Instance.new("ScrollingFrame")
	instrumentScroll.Name = "InstrumentScroll"
	instrumentScroll.BackgroundTransparency = 1
	instrumentScroll.BorderSizePixel = 0

	instrumentScroll.Size = UDim2.new(1, 0, 0, 0)
	instrumentScroll.AutomaticSize = Enum.AutomaticSize.None
	instrumentScroll.ScrollBarThickness = 8
	instrumentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	instrumentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	instrumentScroll.LayoutOrder = 2
	instrumentScroll.Parent = laptopStemConfigPanel

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Vertical
	uiListLayout2.Padding = UDim.new(0, 3)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = instrumentScroll

	local countInLabel = Instance.new("TextLabel")
	countInLabel.Name = "CountInLabel"
	countInLabel.BackgroundTransparency = 1
	countInLabel.Size = UDim2.new(1, 0, 0, 14)
	countInLabel.Font = Theme.Fonts.Medium
	countInLabel.TextSize = Theme.TextSize.XS
	countInLabel.TextColor3 = Theme.Colors.TextSecondary
	countInLabel.TextXAlignment = Enum.TextXAlignment.Left
	countInLabel.Text = "Count-In"
	countInLabel.LayoutOrder = 3
	countInLabel.Parent = laptopStemConfigPanel

	local countInRow = Instance.new("Frame")
	countInRow.Name = "CountInRow"
	countInRow.BackgroundTransparency = 1
	countInRow.Size = UDim2.new(1, 0, 0, 22)
	countInRow.LayoutOrder = 4
	countInRow.Parent = laptopStemConfigPanel

	local countInBar = FilterBar.new(countInRow, {
		items = items,
		size = UDim2.new(1, -(74 + Theme.Spacing.XS), 1, 0)
	})

	countInBar:SetItems(items, "OFF")

	local v2 = PrimaryButton.new(countInRow, { text = "Start", icon = "▶" })

	v2.Instance.AnchorPoint = Vector2.new(1, 0)
	v2.Instance.Position = UDim2.new(1, 0, 0, 0)
	v2.Instance.Size = UDim2.new(0, 74, 1, 0)

	local function relayout()
		local v3 = headerRow.AbsoluteSize.Y + countInLabel.AbsoluteSize.Y + countInRow.AbsoluteSize.Y + Theme.Spacing.XS * 3 + 10 + 24
		local v4 = math.max(0, laptopStemConfigPanel.AbsoluteSize.Y - v3)
		instrumentScroll.Size = UDim2.new(1, 0, 0, v4)
	end
	laptopStemConfigPanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
	relayout()

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = laptopStemConfigPanel
	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Parent = laptopStemConfigPanel

	local object = setmetatable({
		Instance = laptopStemConfigPanel,
		BackRequested = bindableEvent.Event,
		StartRequested = bindableEvent2.Event,
		_titleLabel = title,
		_scrollFrame = instrumentScroll,
		_countInBar = countInBar,
		_backRequestedEvent = bindableEvent,
		_startRequestedEvent = bindableEvent2,
		_currentSongId = nil,
		_autoToggles = {},
		_volumeValues = {},
		_volumeLabels = {},
		_nameLabels = {},
		_instrumentRows = {},
		_lockedState = {},
		_wasOnBeforeLock = {}
	}, LaptopStemConfigPanel)

	backButton.MouseButton1Click:Connect(function()
		bindableEvent:Fire()
	end)

	v2.Clicked:Connect(function()
		local set = {}
		local volumes = {}

		for k, autoToggle in pairs(object._autoToggles) do
			if not autoToggle:GetState() then
				continue
			end

			set[k] = true
			volumes[k] = object._volumeValues[k] or 1
		end

		bindableEvent2:Fire(object._currentSongId, {
			AutoInstruments = set,
			Volumes = volumes,
			CountIn = countInBar:GetSelected()
		})
	end)

	return object
end

local function clearInstrumentRows(state)
	for _, instrumentRow in ipairs(state._instrumentRows) do
		instrumentRow:Destroy()
	end

	state._instrumentRows = {}
	state._autoToggles = {}
	state._volumeValues = {}
	state._volumeLabels = {}
	state._nameLabels = {}
	state._lockedState = {}
	state._wasOnBeforeLock = {}
end

local function buildInstrumentRow(data, text, layoutOrder)
	local frame = Instance.new("Frame")
	frame.Name = text .. "Row"
	frame.BackgroundColor3 = Theme.Colors.Surface
	frame.Size = UDim2.new(1, 0, 0, 20)
	frame.ClipsDescendants = true
	frame.LayoutOrder = layoutOrder
	frame.Parent = data._scrollFrame

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Small
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = Theme.Stroke.Thickness
	uiStroke.Color = Theme.Colors.Border
	uiStroke.Transparency = Theme.Stroke.TransparencyDefault
	uiStroke.Parent = frame

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, Theme.Spacing.S)
	uiPadding.PaddingRight = UDim.new(0, Theme.Spacing.XS)
	uiPadding.Parent = frame

	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.BackgroundTransparency = 1
	name.Size = UDim2.new(0.34, 0, 1, 0)

	name.Font = Theme.Fonts.Medium
	name.TextSize = Theme.TextSize.M
	name.TextColor3 = Theme.Colors.TextPrimary
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextYAlignment = Enum.TextYAlignment.Center
	name.TextTruncate = Enum.TextTruncate.AtEnd
	name.Text = text
	name.Parent = frame
	data._nameLabels[text] = name

	local volumeHolder = Instance.new("Frame")
	volumeHolder.Name = "VolumeHolder"
	volumeHolder.BackgroundTransparency = 1

	volumeHolder.Size = UDim2.new(0.6599999999999999, -(46 + Theme.Spacing.XS), 1, 0)
	volumeHolder.Position = UDim2.new(0.34, Theme.Spacing.XS, 0, 0)
	volumeHolder.Parent = frame

	data._volumeValues[text] = 1

	local function makeVolumeButton(text2, position)
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.new(0, 16, 0, 16)
		textButton.Position = position
		textButton.AnchorPoint = Vector2.new(0, 0.5)
		textButton.BackgroundColor3 = Theme.Colors.SurfaceSelected
		textButton.Text = text2
		textButton.Font = Theme.Fonts.Bold
		textButton.TextSize = Theme.TextSize.S
		textButton.TextColor3 = Theme.Colors.Accent
		textButton.AutoButtonColor = false
		textButton.Parent = volumeHolder
		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = Theme.Radius.Small
		uiCorner2.Parent = textButton
		return textButton
	end

	local volumeButton = makeVolumeButton("-", UDim2.new(0, 0, 0.5, 0))
	local volumeButton2 = makeVolumeButton("+", UDim2.new(1, -16, 0.5, 0))

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(1, 0.5)
	textLabel.Position = UDim2.new(1, -18, 0.5, 0)
	textLabel.Size = UDim2.new(0, 30, 1, 0)
	textLabel.Font = Theme.Fonts.Medium
	textLabel.TextSize = Theme.TextSize.S
	textLabel.TextColor3 = Theme.Colors.TextPrimary
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Text = string.format("%d%%", 100)
	textLabel.Parent = volumeHolder
	data._volumeLabels[text] = textLabel

	local fn
	local v2 = SegmentedSlider.new(volumeHolder, {
		steps = 21,
		gap = 1,
		anchorPoint = Vector2.new(0, 0.5),
		position = UDim2.new(0, 19, 0.5, 0),
		size = UDim2.new(1, -70, 0, 12),
		onSelect = function(p)
			fn((p - 1) * 0.1 + 0)
		end
	})

	fn = function(p)
		local v3 = math.floor(math.clamp((math.floor)(p / 0.1 + 0.5) * 0.1, 0, 2) * 100 + 0.5) / 100
		data._volumeValues[text] = v3
		textLabel.Text = formatVolume(v3) -- inferred equivalent call
		v2:SetIndex(math.floor((v3 - 0) / 0.1 + 0.5) + 1)
	end
	fn(1)

	volumeButton.MouseButton1Click:Connect(function()
		fn(data._volumeValues[text] - 0.1)
	end)
	volumeButton2.MouseButton1Click:Connect(function()
		fn(data._volumeValues[text] + 0.1)
	end)

	local toggleHolder = Instance.new("Frame")
	toggleHolder.Name = "ToggleHolder"
	toggleHolder.BackgroundTransparency = 1
	toggleHolder.Size = UDim2.new(0, 46, 1, 0)
	toggleHolder.Position = UDim2.new(1, -46, 0, 0)
	toggleHolder.Parent = frame

	local miniToggle = createMiniToggle(toggleHolder)

	miniToggle:SetState(true, true)
	data._autoToggles[text] = miniToggle

	table.insert(data._instrumentRows, frame)
end

function LaptopStemConfigPanel:ShowSong(currentSongId, p, p2)
	self._currentSongId = currentSongId
	self._titleLabel.Text = p2 or currentSongId or ""

	clearInstrumentRows(self)

	local v2 = p and SongConfig.Songs[p]
	local stems = v2 and v2.Stems or {}
	local v3 = 1

	for _, v4 in ipairs(v) do
		if not stems[v4] then
			continue
		end

		buildInstrumentRow(self, v4, v3)
		v3 += 1
	end

	self._countInBar:SetItems(items, "OFF")

	self.Instance.Visible = true
end

function LaptopStemConfigPanel:SetLockedInstruments(options)
	local v2 = options or {}

	for k, autoToggle in pairs(self._autoToggles) do
		local v3 = v2[k] == true
		local v4 = self._lockedState[k] == true

		if v3 and not v4 then
			self._wasOnBeforeLock[k] = autoToggle:GetState()
			autoToggle:SetState(false, true)
			autoToggle:SetLocked(true)
			local nameLabel = self._nameLabels[k]

			if nameLabel then
				nameLabel.TextColor3 = Theme.Colors.TextDisabled
			end
		elseif not v3 and v4 then
			autoToggle:SetLocked(false)
			local v5 = self._wasOnBeforeLock[k]
			autoToggle:SetState(v5 == nil or v5, true)
			self._wasOnBeforeLock[k] = nil
			local nameLabel = self._nameLabels[k]

			if nameLabel then
				nameLabel.TextColor3 = Theme.Colors.TextPrimary
			end
		end

		self._lockedState[k] = v3
	end
end

function LaptopStemConfigPanel.Hide(p)
	p.Instance.Visible = false
end

function LaptopStemConfigPanel:Destroy()
	self.Instance:Destroy()
end

return LaptopStemConfigPanel