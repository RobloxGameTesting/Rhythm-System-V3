local v = { Up = 0, Right = 90, Down = 180, Left = 270 }

local vector2 = Vector2.new(0.5, 0.17)
local vector2_2 = Vector2.new(0.17, 0.5)
local vector2_3 = Vector2.new(0.83, 0.5)
local v2 = {
	{ vector2, (Vector2.new(0.5, 0.84)) },
	{ vector2, vector2_2 },
	{ vector2, vector2_3 }
}
local KeyArrowIcon = {}

function KeyArrowIcon.GetRotation(value)
	if value == nil then
		return nil
	end

	if typeof(value) == "EnumItem" then
		value = value.Name
	end

	if type(value) == "string" then
		return v[value]
	end

	return nil
end

local function addStroke(parent, p, p2, p3, backgroundColor, zIndex)
	local v3 = p2 - p
	local midpoint = (p + p2) / 2
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(midpoint.X, midpoint.Y)
	frame.Size = UDim2.fromScale(v3.Magnitude + p3, p3)
	frame.Rotation = math.deg((math.atan2(v3.Y, v3.X)))
	frame.BackgroundColor3 = backgroundColor
	frame.BorderSizePixel = 0
	frame.ZIndex = zIndex

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = frame

	frame.Parent = parent
end

function KeyArrowIcon.Create(guiObject, value, p, backgroundColor, backgroundColor2, value2)
	local zIndex = (guiObject:IsA("GuiObject") and guiObject.ZIndex or 1) + 1

	local arrowIcon = Instance.new("Frame")
	arrowIcon.Name = "ArrowIcon"
	arrowIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	arrowIcon.Position = UDim2.fromScale(0.5, 0.5)
	arrowIcon.Size = UDim2.fromOffset(p, p)
	arrowIcon.BackgroundTransparency = 1
	arrowIcon.BorderSizePixel = 0
	arrowIcon.Rotation = value or 0
	arrowIcon.ZIndex = zIndex

	local outline = Instance.new("CanvasGroup")
	outline.Name = "Outline"
	outline.BackgroundTransparency = 1
	outline.BorderSizePixel = 0
	outline.Size = UDim2.fromScale(1, 1)
	outline.GroupTransparency = value2 or 0
	outline.ZIndex = zIndex
	outline.Parent = arrowIcon

	for _, v3 in ipairs(v2) do
		addStroke(outline, v3[1], v3[2], 0.33, backgroundColor2, zIndex)
	end

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundTransparency = 1
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.ZIndex = zIndex + 1
	fill.Parent = arrowIcon

	for _, v3 in ipairs(v2) do
		addStroke(fill, v3[1], v3[2], 0.19, backgroundColor, zIndex + 1)
	end

	arrowIcon.Parent = guiObject
	return arrowIcon
end

return KeyArrowIcon