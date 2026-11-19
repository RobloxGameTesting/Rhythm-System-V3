local StyledTheme = require(script.Parent.StyledTheme)
local ChartDifficultyRatings = require(script.Parent.Parent.ChartDifficultyRatings)

local DifficultyFilter = {}
DifficultyFilter.__index = DifficultyFilter

local v = {
	{ w = 11, h = 11, rot = 8, a = 0 },
	{ w = 9, h = 12, rot = -19, a = 0.15 },
	{ w = 12, h = 8, rot = 33, a = 0.25 }
}

local v2 = { EASY = -6, MEDIUM = 9, HARD = -3, INSANE = 12 }

local v3 = {
	{ w = 21, h = 17, rot = -14 },
	{ w = 17, h = 21, rot = 22 }
}

local function refreshCell(cell, visible)
	local v4 = visible and 0 or cell.hover and 0.18 or 0.35

	for _, layer in ipairs(cell.layers) do
		layer.frame.BackgroundTransparency = math.min(1, layer.a + v4)
	end

	cell.scratch.BackgroundTransparency = visible and 0.35 or 0.6

	for _, ring in ipairs(cell.rings) do
		ring.Visible = visible
	end
end

local function createCell(difficultyFilter, tier, layoutOrder, fn)
	local backgroundColor = ChartDifficultyRatings.InkColors and ChartDifficultyRatings.InkColors[tier]
		or ChartDifficultyRatings.Colors[tier]
	local rotation = v2[tier] or 0

	local textButton = Instance.new("TextButton")
	textButton.Name = "Ink_" .. tier
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundTransparency = 1
	textButton.Size = UDim2.new(0, 24, 1, 0)
	textButton.LayoutOrder = layoutOrder
	textButton.Parent = difficultyFilter

	local blob = Instance.new("Frame")
	blob.Name = "Blob"
	blob.BackgroundTransparency = 1
	blob.AnchorPoint = Vector2.new(0.5, 0.5)
	blob.Position = UDim2.new(0.5, 0, 0.5, 0)
	blob.Size = UDim2.fromOffset(14, 14)
	blob.Rotation = rotation
	blob.Parent = textButton

	local layers = {}

	for i, v4 in ipairs(v) do
		local frame = Instance.new("Frame")
		frame.Name = "Layer" .. i
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.Size = UDim2.fromOffset(v4.w, v4.h)
		frame.Rotation = v4.rot
		frame.BackgroundColor3 = backgroundColor
		frame.BorderSizePixel = 0
		frame.Parent = blob

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.3, 0)
		uiCorner.Parent = frame

		table.insert(layers, { frame = frame, a = v4.a })
	end

	local scratch = Instance.new("Frame")
	scratch.Name = "Scratch"
	scratch.AnchorPoint = Vector2.new(0.5, 0.5)
	scratch.Position = UDim2.new(0.5, 0, 0.5, 0)
	scratch.Size = UDim2.fromOffset(16, 1)
	scratch.Rotation = -38
	scratch.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	scratch.BorderSizePixel = 0
	scratch.ZIndex = 2
	scratch.Parent = blob

	local rings = {}

	for i, v4 in ipairs(v3) do
		local frame = Instance.new("Frame")
		frame.Name = "Ring" .. i
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.Size = UDim2.fromOffset(v4.w, v4.h)
		frame.Rotation = v4.rot
		frame.BackgroundTransparency = 1
		frame.Visible = false
		frame.ZIndex = 3
		frame.Parent = textButton

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = frame

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1
		uiStroke.Color = StyledTheme.Colors.TextPrimary
		uiStroke.Transparency = i == 1 and 0.15 or 0.4
		uiStroke.Parent = frame

		table.insert(rings, frame)
	end

	local cell = {
		tier = tier,
		button = textButton,
		layers = layers,
		scratch = scratch,
		rings = rings,
		hover = false
	}

	textButton.MouseEnter:Connect(function()
		cell.hover = true
		cell.refresh()
	end)
	textButton.MouseLeave:Connect(function()
		cell.hover = false
		cell.refresh()
	end)
	textButton.MouseButton1Click:Connect(function()
		fn(tier)
	end)

	return cell
end

function DifficultyFilter.new(parent, options)
	local v4 = options or {}

	local difficultyFilter = Instance.new("Frame")
	difficultyFilter.Name = "DifficultyFilter"
	difficultyFilter.BackgroundTransparency = 1
	difficultyFilter.Size = v4.height and UDim2.new(0, 0, 0, v4.height) or UDim2.new(0, 0, 1, 0)
	difficultyFilter.AutomaticSize = Enum.AutomaticSize.X
	difficultyFilter.LayoutOrder = v4.layoutOrder or 0
	difficultyFilter.Parent = parent

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = difficultyFilter

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = difficultyFilter

	local object = setmetatable(
		{ Instance = difficultyFilter, Toggled = bindableEvent.Event, _cells = {}, _selected = nil },
		DifficultyFilter
	)

	for i, v5 in ipairs(ChartDifficultyRatings.Order) do
		local cell = createCell(difficultyFilter, v5, i, function(p)
			bindableEvent:Fire(p)
		end)
		function cell.refresh()
			refreshCell(cell, object._selected == v5)
		end
		object._cells[v5] = cell
		cell.refresh()
	end

	return object
end

function DifficultyFilter:SetSelected(selected)
	self._selected = selected

	for _, cell in pairs(self._cells) do
		cell.refresh()
	end
end

function DifficultyFilter:GetSelected()
	return self._selected
end

function DifficultyFilter:Destroy()
	self.Instance:Destroy()
	self._cells = {}
end

return DifficultyFilter