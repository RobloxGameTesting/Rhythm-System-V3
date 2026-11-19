local TweenService = game:GetService("TweenService")
local StyledTheme = require(script.Parent.StyledTheme)

local FilterBar = {}
FilterBar.__index = FilterBar

local function createChip(parent, text, layoutOrder)
	local textButton = Instance.new("TextButton")
	textButton.Name = "Chip_" .. text
	textButton.AutomaticSize = Enum.AutomaticSize.X
	textButton.Size = UDim2.new(0, 0, 1, 0)
	textButton.BackgroundColor3 = StyledTheme.Colors.Surface
	textButton.AutoButtonColor = false
	textButton.Font = StyledTheme.Fonts.Medium
	textButton.TextSize = StyledTheme.TextSize.M
	textButton.TextColor3 = StyledTheme.Colors.TextSecondary
	textButton.Text = text
	textButton.LayoutOrder = layoutOrder
	textButton.Parent = parent

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, StyledTheme.Spacing.L)
	uiPadding.PaddingRight = UDim.new(0, StyledTheme.Spacing.L)
	uiPadding.Parent = textButton

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Pill
	uiCorner.Parent = textButton

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = StyledTheme.Stroke.Thickness
	uiStroke.Color = StyledTheme.Colors.Border
	uiStroke.Transparency = StyledTheme.Stroke.TransparencyDefault
	uiStroke.Parent = textButton

	return textButton, uiStroke
end

local function bindChipClick(state, chip, selected) -- 2 equivalent calls inferred from this helper
	chip.MouseButton1Click:Connect(function()
		if state._selected == selected then
			return
		end

		state._selected = selected
		state._refreshVisuals()
		state._selectedEvent:Fire(selected)
	end)
end

function FilterBar.new(parent, options)
	local v = options or {}
	local items = v.items or { "All" }

	local filterBar = Instance.new("ScrollingFrame")
	filterBar.Name = "FilterBar"
	filterBar.BackgroundTransparency = 1
	filterBar.Size = v.size or UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightM)
	filterBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	filterBar.AutomaticCanvasSize = Enum.AutomaticSize.X
	filterBar.ScrollingDirection = Enum.ScrollingDirection.X
	filterBar.ScrollBarThickness = StyledTheme.Sizes.ScrollBarThickness
	filterBar.ScrollBarImageColor3 = StyledTheme.Colors.TextSecondary
	filterBar.LayoutOrder = v.layoutOrder or 0
	filterBar.Parent = parent

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, StyledTheme.Spacing.S)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Parent = filterBar

	local object = setmetatable({
		Instance = filterBar,
		_chips = {},
		_selected = v.default or items[1]
	}, FilterBar)

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = filterBar
	object.Selected = bindableEvent.Event
	object._selectedEvent = bindableEvent

	local function refreshVisuals()
		for _, chip in ipairs(object._chips) do
			local v2 = chip.label == object._selected
			local accent = v2 and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface
			local accentText = v2 and StyledTheme.Colors.AccentText or StyledTheme.Colors.TextSecondary
			local accent2 = v2 and StyledTheme.Colors.Accent or StyledTheme.Colors.Border
			local transparencyActive = v2 and StyledTheme.Stroke.TransparencyActive
				or StyledTheme.Stroke.TransparencyDefault

			TweenService:Create(
				chip.chip,
				TweenInfo.new(
					StyledTheme.Animation.Normal,
					StyledTheme.Animation.EasingStyle,
					StyledTheme.Animation.EasingDirection
				),
				{ BackgroundColor3 = accent }
			):Play()
			TweenService:Create(
				chip.stroke,
				TweenInfo.new(
					StyledTheme.Animation.Normal,
					StyledTheme.Animation.EasingStyle,
					StyledTheme.Animation.EasingDirection
				),
				{ Color = accent2, Transparency = transparencyActive }
			):Play()
			chip.chip.TextColor3 = accentText
		end
	end
	object._refreshVisuals = refreshVisuals

	for i, item in ipairs(items) do
		local chip, stroke = createChip(filterBar, item, i)
		bindChipClick(object, chip, item) -- inferred equivalent call
		table.insert(object._chips, { chip = chip, stroke = stroke, label = item })
	end

	refreshVisuals()

	return object
end

function FilterBar:GetSelected()
	return self._selected
end

function FilterBar:SetItems(list, p)
	for _, chip in ipairs(self._chips) do
		chip.chip:Destroy()
	end

	self._chips = {}
	self._selected = p or list[1]

	for i, item in ipairs(list) do
		local chip, stroke = createChip(self.Instance, item, i)
		bindChipClick(self, chip, item) -- inferred equivalent call
		table.insert(self._chips, { chip = chip, stroke = stroke, label = item })
	end

	self._refreshVisuals()
end

function FilterBar:SetSelected(selected, p)
	if self._selected == selected then
		return
	end

	self._selected = selected
	self._refreshVisuals()

	if not p then
		self._selectedEvent:Fire(selected)
	end
end

function FilterBar:Destroy()
	self.Instance:Destroy()
end

return FilterBar