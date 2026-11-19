local object = setmetatable({}, { __mode = "k" })

local function disconnectArrow(parent) -- 1 equivalent call inferred from this helper
	local v = object[parent]

	if v then
		for _, connection in ipairs(v) do
			connection:Disconnect()
		end

		object[parent] = nil
	end
end

local function roundPx(p) -- 2 equivalent calls inferred from this helper
	return (math.max(1, (math.floor(p + 0.5))))
end

local function addCorner(parent, udim) -- 2 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = udim
	uiCorner.Parent = parent
end

local function addOutline(parent, data) -- 2 equivalent calls inferred from this helper
	if not data then
		return
	end

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = data.Color
	uiStroke.Thickness = data.Thickness
	uiStroke.Transparency = data.Transparency
	uiStroke.Parent = parent
end

local function buildArrow(parent, p, p2, zIndex, data)
	local v = roundPx(p * 0.94 * p2) -- inferred equivalent call
	local v2 = v / 2
	local v3 = roundPx(p * 0.34 * p2) -- inferred equivalent call
	local v4 = v2 + p * 0.3 * p2
	local v5 = -v4 / 2 + v2
	local v6 = v5 - p * 0.08 * p2
	local v7 = v4 / 2
	local udim = UDim.new(0, (math.max(1, (math.floor(p * 0.04 * p2)))))
	local v8 = data and math.ceil(data.Thickness) + 1 or 0

	local arrowShaft = Instance.new("Frame")
	arrowShaft.Name = "ArrowShaft"
	arrowShaft.AnchorPoint = Vector2.new(0.5, 0.5)
	arrowShaft.Position = UDim2.new(0.5, 0, 0.5, (v6 + v7) / 2)
	arrowShaft.Size = UDim2.fromOffset(v3, v7 - v6)
	arrowShaft.BorderSizePixel = 0
	arrowShaft.ZIndex = zIndex
	addCorner(arrowShaft, udim) -- inferred equivalent call
	addOutline(arrowShaft, data) -- inferred equivalent call
	arrowShaft.Parent = parent

	local arrowHead = Instance.new("Frame")
	arrowHead.Name = "ArrowHead"
	arrowHead.AnchorPoint = Vector2.new(0.5, 1)
	arrowHead.Position = UDim2.new(0.5, 0, 0.5, v5)
	arrowHead.Size = UDim2.fromOffset(v + v8 * 2, v2 + v8)
	arrowHead.BackgroundTransparency = 1
	arrowHead.BorderSizePixel = 0
	arrowHead.ClipsDescendants = true
	arrowHead.ZIndex = zIndex + 1
	arrowHead.Parent = parent

	local v9 = v / 1.4142135623730951
	local arrowTip = Instance.new("Frame")
	arrowTip.Name = "ArrowTip"
	arrowTip.AnchorPoint = Vector2.new(0.5, 0.5)
	arrowTip.Position = UDim2.new(0.5, 0, 1, 0)
	arrowTip.Size = UDim2.fromOffset(v9, v9)
	arrowTip.Rotation = 45
	arrowTip.BorderSizePixel = 0
	arrowTip.ZIndex = zIndex + 1
	addCorner(arrowTip, udim) -- inferred equivalent call
	addOutline(arrowTip, data) -- inferred equivalent call
	arrowTip.Parent = arrowHead

	return { arrowShaft, arrowTip }
end

local function addQuadrant(parent, p, p2, p3, p4, zIndex)
	local v = p / 2
	local v2 = p2 / 2
	local v3 = p3 > 0 and 0 or -v
	local v4 = p4 > 0 and 0 or -v2

	local rhombusQuarter = Instance.new("Frame")
	rhombusQuarter.Name = "RhombusQuarter"
	rhombusQuarter.AnchorPoint = Vector2.new(0, 0)
	rhombusQuarter.Position = UDim2.fromOffset(v3, v4)
	rhombusQuarter.Size = UDim2.fromOffset(v, v2)
	rhombusQuarter.BackgroundTransparency = 1
	rhombusQuarter.BorderSizePixel = 0
	rhombusQuarter.ClipsDescendants = true
	rhombusQuarter.ZIndex = zIndex
	rhombusQuarter.Parent = parent

	local v5 = p3 * v
	local v6 = p4 * v2
	local v7 = 0 - v5
	local v8 = v6 - 0
	local v9 = math.sqrt(v7 * v7 + v8 * v8)
	local selected = v7 / v9
	local v10 = v8 / v9
	local selected2 = -v10
	local v11

	if selected2 * (0 - v5) + selected * 0 < 0 then
		v11 = -selected
		v10 = -v10
		selected2 = -selected2
		selected = -selected
	else
		v11 = selected
	end

	local midpoint = (v5 + 0) / 2
	local midpoint2 = (0 + v6) / 2
	local v12 = midpoint + selected2 * (v9 / 2)
	local v13 = midpoint2 + selected * (v9 / 2)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.AnchorPoint = Vector2.new(0.5, 0.5)
	fill.Position = UDim2.fromOffset(v12 - v3, v13 - v4)
	fill.Size = UDim2.fromOffset(v9 * 2, v9)
	fill.Rotation = math.deg((math.atan2(v10, v11)))
	fill.BorderSizePixel = 0
	fill.ZIndex = zIndex
	fill.Parent = rhombusQuarter
	return fill, midpoint, midpoint2, selected2, selected, v9
end

local function buildRhombus(parent, p, p2, zIndex, data)
	local v = math.max(2, p)
	local v2 = math.max(2, p2)
	local rhombus = {}

	for _, v3 in ipairs({ 1, -1 }) do
		for _, v4 in ipairs({ 1, -1 }) do
			local v5, v6, v7, v8, v9, v10 = addQuadrant(parent, v, v2, v3, v4, zIndex)
			table.insert(rhombus, v5)

			if not data then
				continue
			end

			local thickness = data.Thickness
			local rhombusEdge = Instance.new("Frame")
			rhombusEdge.Name = "RhombusEdge"
			rhombusEdge.AnchorPoint = Vector2.new(0.5, 0.5)

			rhombusEdge.Position = UDim2.fromOffset(v6 - v8 * (thickness / 2), v7 - v9 * (thickness / 2))
			rhombusEdge.Size = UDim2.fromOffset(v10 + thickness, thickness)
			rhombusEdge.Rotation = math.deg((math.atan2(-v8, v9)))
			rhombusEdge.BackgroundColor3 = data.Color
			rhombusEdge.BackgroundTransparency = data.Transparency
			rhombusEdge.BorderSizePixel = 0
			rhombusEdge.ZIndex = zIndex + 2
			rhombusEdge.Parent = parent
		end
	end

	return rhombus
end

local function bindFill(parent, list, instance)
	local function sync() -- 1 equivalent call inferred from this helper
		for _, item in ipairs(list) do
			item.BackgroundColor3 = instance.BackgroundColor3
			item.BackgroundTransparency = instance.BackgroundTransparency
		end
	end

	sync() -- inferred equivalent call
	local connections = object[parent]
	table.insert(connections, instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(sync))
	table.insert(connections, instance:GetPropertyChangedSignal("BackgroundTransparency"):Connect(sync))
end

local function applyArrow(parent, p, uiStroke, p2)
	local v = p2 or function(parent2, p3, zIndex, p4)
		return buildArrow(parent2, p, p3, zIndex, p4)
	end

	parent.Size = UDim2.new(0, 0, 0, 0)
	parent.Rotation = 0
	object[parent] = {}
	local v2

	if uiStroke then
		v2 = {
			Color = uiStroke.Color,
			Thickness = uiStroke.Thickness,
			Transparency = uiStroke.Transparency
		}

		uiStroke.Enabled = false
	end

	local shapeExtra = Instance.new("Frame")
	shapeExtra.Name = "ShapeExtra"
	shapeExtra.AnchorPoint = Vector2.new(0.5, 0.5)
	shapeExtra.Position = UDim2.new(0.5, 0, 0.5, 0)
	shapeExtra.Size = UDim2.new(0, 0, 0, 0)
	shapeExtra.BackgroundTransparency = 1
	shapeExtra.BorderSizePixel = 0
	shapeExtra.ZIndex = parent.ZIndex
	shapeExtra.Parent = parent

	bindFill(parent, v(shapeExtra, 1, parent.ZIndex, v2), parent)

	local function buildInner(instance)
		local innerArrow = shapeExtra:FindFirstChild("InnerArrow")

		if innerArrow then
			innerArrow:Destroy()
		end

		local innerArrow2 = Instance.new("Frame")
		innerArrow2.Name = "InnerArrow"
		innerArrow2.AnchorPoint = Vector2.new(0.5, 0.5)
		innerArrow2.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerArrow2.Size = UDim2.new(0, 0, 0, 0)
		innerArrow2.BackgroundTransparency = 1
		innerArrow2.BorderSizePixel = 0
		innerArrow2.ZIndex = parent.ZIndex + 2
		innerArrow2.Parent = shapeExtra
		bindFill(parent, v(innerArrow2, 0.5, parent.ZIndex + 3, nil), instance)
		table.insert(object[parent], instance.Destroying:Connect(function()
			innerArrow2:Destroy()
		end))
	end

	local innerGem = parent:FindFirstChild("InnerGem")

	if innerGem and innerGem:IsA("GuiObject") then
		buildInner(innerGem)
	end

	table.insert(object[parent], parent.ChildAdded:Connect(function(instance)
		if instance:IsA("UIStroke") then
			instance.Enabled = false
		elseif instance.Name == "InnerGem" and instance:IsA("GuiObject") then
			buildInner(instance)
		end
	end))
end

return {
	Apply = function(self, p, p2, p3)
		local v = p3 or p2
		local v2 = math.sqrt(p2 * v)
		local v3 = math.min(p2, v)
		disconnectArrow(self) -- inferred equivalent call
		local shapeExtra = self:FindFirstChild("ShapeExtra")

		if shapeExtra then
			shapeExtra:Destroy()
		end

		local uiStroke = self:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Enabled = true
		end

		local v4 = self:FindFirstChildOfClass("UICorner")

		if not v4 then
			v4 = Instance.new("UICorner")
			v4.Parent = self
		end

		self.Rotation = 0

		if p == "Circle" then
			v4.CornerRadius = UDim.new(1, 0)
			self.Size = UDim2.new(0, p2, 0, v)
		elseif p == "Rounded" then
			v4.CornerRadius = UDim.new(0, (math.floor(v3 * 0.28)))
			self.Size = UDim2.new(0, p2, 0, v)
		elseif p == "Pill" then
			v4.CornerRadius = UDim.new(1, 0)
			self.Size = UDim2.new(0, math.floor(p2 * 1.5), 0, v)
		elseif p == "Square" then
			v4.CornerRadius = UDim.new(0, 0)
			self.Size = UDim2.new(0, p2, 0, v)
		elseif p == "Hero" then
			v4.CornerRadius = UDim.new(0, (math.floor(v3 * 0.22)))
			self.Size = UDim2.new(0, p2, 0, v)
			local shapeExtra2 = Instance.new("Frame")
			shapeExtra2.Name = "ShapeExtra"
			shapeExtra2.AnchorPoint = Vector2.new(0.5, 0.5)
			shapeExtra2.Position = UDim2.new(0.5, 0, 0.5, 0)
			shapeExtra2.Size = UDim2.new(0, math.floor(v3 * 0.5), 0, (math.floor(v3 * 0.5)))
			shapeExtra2.Rotation = 45
			shapeExtra2.BackgroundColor3 = self.BackgroundColor3
			shapeExtra2.BackgroundTransparency = self.BackgroundTransparency
			shapeExtra2.BorderSizePixel = 0
			shapeExtra2.ZIndex = self.ZIndex + 1
			shapeExtra2.Parent = self
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 3)
			uiCorner.Parent = shapeExtra2
		elseif p == "Arrow" then
			v4.CornerRadius = UDim.new(0, 3)
			applyArrow(self, v2, uiStroke)
		elseif math.abs(p2 - v) < 0.5 then
			v4.CornerRadius = UDim.new(0, 6)
			self.Size = UDim2.new(0, p2, 0, p2)
			self.Rotation = 45
		else
			v4.CornerRadius = UDim.new(0, 0)
			local v5 = p2 * 1.4142135623730951
			local v6 = v * 1.4142135623730951
			applyArrow(self, v2, uiStroke, function(parent, p4, zIndex, p5)
				return buildRhombus(parent, v5 * p4, v6 * p4, zIndex, p5)
			end)
		end
	end
}