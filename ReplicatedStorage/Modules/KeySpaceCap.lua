local KeySpaceCap = {}

function KeySpaceCap.IsSpace(p): boolean
	if p == nil then
		return false
	end

	if typeof(p) == "EnumItem" then
		return p == Enum.KeyCode.Space
	end

	return p == "Space"
end

function KeySpaceCap.Create(guiObject, p, p2, p3, textStrokeColor, value, value2)
	local zIndex = (guiObject:IsA("GuiObject") and guiObject.ZIndex or 1) + 1

	local spaceCapIcon = Instance.new("Frame")
	spaceCapIcon.Name = "SpaceCapIcon"
	spaceCapIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	spaceCapIcon.Position = UDim2.fromScale(0.5, 0.5)
	spaceCapIcon.Size = UDim2.fromOffset(p, p2)
	spaceCapIcon.BackgroundTransparency = 1
	spaceCapIcon.BorderSizePixel = 0
	spaceCapIcon.ZIndex = zIndex

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, (math.max(2, (math.floor(p2 * 0.35)))))
	uiCorner.Parent = spaceCapIcon

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = p3
	uiStroke.Thickness = math.max(1, (math.floor(p2 * 0.06)))
	uiStroke.Transparency = value2 or 0.5
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = spaceCapIcon

	local spaceText = Instance.new("TextLabel")
	spaceText.Name = "SpaceText"
	spaceText.Size = UDim2.fromScale(1, 1)
	spaceText.BackgroundTransparency = 1
	spaceText.Font = Enum.Font.GothamBlack
	spaceText.Text = "SPACE"
	spaceText.TextSize = math.max(7, (math.floor(p2 * 0.55)))
	spaceText.TextColor3 = p3
	spaceText.TextStrokeColor3 = textStrokeColor
	spaceText.TextStrokeTransparency = value or 0.2
	spaceText.TextXAlignment = Enum.TextXAlignment.Center
	spaceText.TextYAlignment = Enum.TextYAlignment.Center
	spaceText.ZIndex = zIndex + 1
	spaceText.Parent = spaceCapIcon

	spaceCapIcon.Parent = guiObject
	return spaceCapIcon
end

return KeySpaceCap