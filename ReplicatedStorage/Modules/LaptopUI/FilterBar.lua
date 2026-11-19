local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Retro = require(script.Parent.Retro)
local Theme = require(script.Parent.Theme)

local FilterBar = {}
FilterBar.__index = FilterBar

local s = Theme.TextSize.S

local xs = Theme.Spacing.XS

local function createChip(parent, text, layoutOrder, chipHeight)
	local v = chipHeight ~= nil
	local frame = Instance.new("Frame")
	frame.Name = "Chip_" .. text
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.Size = v and UDim2.new(0, 0, 0, chipHeight) or UDim2.new(0, 0, 1, 0)
	frame.BackgroundColor3 = Theme.Colors.Surface

	frame.LayoutOrder = layoutOrder
	frame.Parent = parent

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Parent = frame

	local uiPadding = Instance.new("UIPadding")

	local v2 = v and 7 or Theme.Spacing.M
	uiPadding.PaddingLeft = UDim.new(0, v2)
	uiPadding.PaddingRight = UDim.new(0, v2)
	uiPadding.Parent = frame

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Medium
	uiCorner.Parent = frame
	Retro.AddGloss(frame)

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = Theme.Stroke.Thickness
	uiStroke.Color = Theme.Colors.Border
	uiStroke.Transparency = Theme.Stroke.TransparencyDefault
	uiStroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Theme.Fonts.Medium

	label.TextSize = v and s or Theme.TextSize.M
	label.TextColor3 = Theme.Colors.TextSecondary
	label.Text = text
	label.Parent = frame

	return frame, uiStroke, label
end

local function buildScrollIndicator(object, filterBar, scrollingFrame, p)
	local scrollHit = Instance.new("Frame")
	scrollHit.Name = "ScrollHit"
	scrollHit.BackgroundTransparency = 1
	scrollHit.BorderSizePixel = 0
	scrollHit.Active = true
	scrollHit.Position = UDim2.new(0, 0, 0, p + 1)
	scrollHit.Size = UDim2.new(1, 0, 0, 9)
	scrollHit.Parent = filterBar

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundColor3 = Theme.Colors.Border
	track.BackgroundTransparency = 0.35
	track.BorderSizePixel = 0
	track.Position = UDim2.new(0, 0, 0, 2)
	track.Size = UDim2.new(1, 0, 0, 4)
	track.Visible = false
	track.Parent = scrollHit

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Small
	uiCorner.Parent = track

	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.BackgroundColor3 = Theme.Colors.TextSecondary
	thumb.BackgroundTransparency = 0.25
	thumb.BorderSizePixel = 0
	thumb.Size = UDim2.new(0, 48, 1, 0)
	thumb.Parent = track

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = Theme.Radius.Small
	uiCorner2.Parent = thumb

	local function maxScroll() -- 4 equivalent calls inferred from this helper
		return (math.max(0, scrollingFrame.AbsoluteCanvasSize.X - scrollingFrame.AbsoluteWindowSize.X))
	end

	local function updateThumb()
		local x = scrollingFrame.AbsoluteWindowSize.X
		local x2 = scrollingFrame.AbsoluteCanvasSize.X
		local v = maxScroll() -- inferred equivalent call

		if x <= 0 or v <= 1 then
			track.Visible = false
			return
		end

		track.Visible = true
		local x3 = scrollHit.AbsoluteSize.X
		local v2 = math.clamp(math.floor(x3 * x / x2), 48, (math.max(48, x3)))

		local v3 = math.clamp(scrollingFrame.CanvasPosition.X / v, 0, 1)
		thumb.Size = UDim2.new(0, v2, 1, 0)
		thumb.Position = UDim2.new(0, math.floor(v3 * math.max(0, x3 - v2) + 0.5), 0, 0)
	end

	local v = false
	local v2 = 0
	local filterBarDragCapture = nil
	local connections = {}

	local function isPress(input): boolean -- 3 equivalent calls inferred from this helper
		return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
	end

	local function scrollToPointerX(p2)
		local v3 = maxScroll() -- inferred equivalent call
		local v4 = scrollHit.AbsoluteSize.X - thumb.AbsoluteSize.X

		if v3 <= 0 or v4 <= 0 then
			return
		end

		local v5 = p2 - scrollHit.AbsolutePosition.X - v2
		scrollingFrame.CanvasPosition = Vector2.new(math.clamp(v5 / v4, 0, 1) * v3, 0)
	end

	local function onPointerMoved(p2)
		if
			v
			and (p2.UserInputType == Enum.UserInputType.MouseMovement or p2.UserInputType == Enum.UserInputType.Touch)
		then
			local x = p2.Position.X
			local v3 = maxScroll() -- inferred equivalent call
			local v4 = scrollHit.AbsoluteSize.X - thumb.AbsoluteSize.X

			if not (v3 <= 0) then
				if v4 <= 0 then
					return
				end

				local v5 = x - scrollHit.AbsolutePosition.X - v2
				scrollingFrame.CanvasPosition = Vector2.new(math.clamp(v5 / v4, 0, 1) * v3, 0)
			end
		end
	end

	local function endDrag()
		if not v then
			return
		end

		v = false
		thumb.BackgroundTransparency = 0.25

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)

		if filterBarDragCapture then
			filterBarDragCapture:Destroy()
			filterBarDragCapture = nil
		end
	end

	local function beginDrag()
		v = true
		thumb.BackgroundTransparency = 0
		local layerCollector = filterBar:FindFirstAncestorWhichIsA("LayerCollector")

		if layerCollector then
			filterBarDragCapture = Instance.new("Frame")
			filterBarDragCapture.Name = "FilterBarDragCapture"
			filterBarDragCapture.BackgroundTransparency = 1
			filterBarDragCapture.BorderSizePixel = 0
			filterBarDragCapture.Active = true
			filterBarDragCapture.Size = UDim2.fromScale(1, 1)
			filterBarDragCapture.ZIndex = 1000
			filterBarDragCapture.Parent = layerCollector
			table.insert(connections, filterBarDragCapture.InputChanged:Connect(onPointerMoved))
			table.insert(connections, filterBarDragCapture.InputEnded:Connect(function(input)
				if isPress(input) then -- inferred equivalent call
					endDrag()
				end
			end))
		end
	end

	table.insert(object._connections, scrollHit.InputBegan:Connect(function(input)
		if not (isPress(input) and track.Visible) then -- inferred equivalent call
			return
		end

		local x = input.Position.X
		local x2 = thumb.AbsolutePosition.X
		local v3

		if x2 <= x then
			v3 = x <= x2 + thumb.AbsoluteSize.X
		else
			v3 = false
		end

		if v3 then
			v2 = x - x2
		else
			v2 = thumb.AbsoluteSize.X / 2
		end

		beginDrag()

		if not v3 then
			local v4 = maxScroll() -- inferred equivalent call
			local v5 = scrollHit.AbsoluteSize.X - thumb.AbsoluteSize.X

			if not (v4 <= 0) then
				if v5 <= 0 then
					return
				end

				local v6 = x - scrollHit.AbsolutePosition.X - v2
				scrollingFrame.CanvasPosition = Vector2.new(math.clamp(v6 / v5, 0, 1) * v4, 0)
			end
		end
	end))
	table.insert(object._connections, scrollHit.InputChanged:Connect(onPointerMoved))

	table.insert(object._connections, UserInputService.InputEnded:Connect(function(input)
		if isPress(input) then -- inferred equivalent call
			endDrag()
		end
	end))

	table.insert(object._connections, scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateThumb))
	table.insert(
		object._connections,
		scrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateThumb)
	)
	table.insert(
		object._connections,
		scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateThumb)
	)
	table.insert(object._connections, scrollHit:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateThumb))
	updateThumb()

	object._endDrag = endDrag
end

function FilterBar.new(parent, options)
	local v = options or {}
	local items = v.items or { "All" }

	local chipHeight = v.chipHeight
	local v2 = chipHeight ~= nil
	local v3

	if v2 then
		v3 = chipHeight + 2 or nil
	end

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
	scrollingFrame.ScrollBarImageColor3 = Theme.Colors.TextSecondary
	local filterBar

	if v2 then
		filterBar = Instance.new("Frame")
		filterBar.Name = "FilterBar"
		filterBar.BackgroundTransparency = 1
		filterBar.Size = v.size or UDim2.new(1, 0, 0, v3 + 3 + 4)
		filterBar.LayoutOrder = v.layoutOrder or 0
		filterBar.Parent = parent

		scrollingFrame.Name = "Chips"
		scrollingFrame.Size = UDim2.new(1, 0, 0, v3 + 1)
		scrollingFrame.ScrollBarThickness = 0

		scrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
		scrollingFrame.Parent = filterBar
	else
		scrollingFrame.Name = "FilterBar"
		scrollingFrame.Size = v.size or UDim2.new(1, 0, 0, Theme.Sizes.ControlHeightM)
		scrollingFrame.ScrollBarThickness = Theme.Sizes.ScrollBarThickness
		scrollingFrame.LayoutOrder = v.layoutOrder or 0
		scrollingFrame.Parent = parent
		filterBar = scrollingFrame
	end

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, v2 and xs or Theme.Spacing.S)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Parent = scrollingFrame

	local object = setmetatable({
		Instance = filterBar,
		_scroll = scrollingFrame,
		_chips = {},
		_chipHeight = chipHeight,
		_connections = {},
		_selected = v.default or items[1]
	}, FilterBar)

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = scrollingFrame
	object.Selected = bindableEvent.Event
	object._selectedEvent = bindableEvent

	local function refreshVisuals()
		for _, chip in ipairs(object._chips) do
			local v4 = chip.label == object._selected
			local accent = v4 and Theme.Colors.Accent or Theme.Colors.Surface
			local accentText = v4 and Theme.Colors.AccentText or Theme.Colors.TextSecondary
			local accent2 = v4 and Theme.Colors.Accent or Theme.Colors.Border
			local transparencyActive = v4 and Theme.Stroke.TransparencyActive or Theme.Stroke.TransparencyDefault

			TweenService:Create(
				chip.chip,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EasingStyle, Theme.Animation.EasingDirection),
				{ BackgroundColor3 = accent }
			):Play()
			TweenService:Create(
				chip.stroke,
				TweenInfo.new(Theme.Animation.Normal, Theme.Animation.EasingStyle, Theme.Animation.EasingDirection),
				{ Color = accent2, Transparency = transparencyActive }
			):Play()
			chip.textLabel.TextColor3 = accentText
		end
	end
	object._refreshVisuals = refreshVisuals

	for i, item in ipairs(items) do
		local chip, stroke, textLabel = createChip(scrollingFrame, item, i, chipHeight)
		table.insert(object._chips, {
			chip = chip,
			stroke = stroke,
			textLabel = textLabel,
			label = item
		})
	end

	refreshVisuals()

	local position = nil
	scrollingFrame.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			position = input.Position
		end
	end)
	scrollingFrame.InputEnded:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local v4 = position
		position = nil

		if not v4 or (input.Position - v4).Magnitude > 8 then
			return
		end

		local vector2 = Vector2.new(input.Position.X, input.Position.Y)

		for _, chip in ipairs(object._chips) do
			local absolutePosition = chip.chip.AbsolutePosition
			local absoluteSize = chip.chip.AbsoluteSize

			if
				vector2.X >= absolutePosition.X
				and vector2.X <= absolutePosition.X + absoluteSize.X
				and vector2.Y >= absolutePosition.Y
				and vector2.Y <= absolutePosition.Y + absoluteSize.Y
			then
				if object._selected == chip.label then
					break
				end

				object._selected = chip.label
				object._refreshVisuals()
				object._selectedEvent:Fire(chip.label)
				break
			end
		end
	end)

	if v2 then
		buildScrollIndicator(object, filterBar, scrollingFrame, v3)
	end

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
		local chip, stroke, textLabel = createChip(self._scroll, item, i, self._chipHeight)
		table.insert(self._chips, {
			chip = chip,
			stroke = stroke,
			textLabel = textLabel,
			label = item
		})
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
	if self._endDrag then
		self._endDrag()
	end

	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	table.clear(self._connections)
	self.Instance:Destroy()
end

return FilterBar