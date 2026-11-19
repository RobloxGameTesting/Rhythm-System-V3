local Theme = require(script.Parent.Theme)

local v = { "GuitarRhythm", "GuitarLead", "Bass", "Drum", "Keyboard", "Piano" }

local function countAvailable(p, list)
	local count = 0
	local count2 = 0

	for _, item in ipairs(list) do
		count += 1

		if p[item] then
			count2 += 1
		end
	end

	return count2, count
end

local InstrumentIndicator = {}

function InstrumentIndicator.Create(parent, options, value, p)
	local count = 0
	local v2 = options or {}
	local count2 = 0

	for _, v3 in ipairs(p or v) do
		count += 1

		if v2[v3] then
			count2 += 1
		end
	end

	local instrumentIndicator = Instance.new("TextLabel")
	instrumentIndicator.Name = "InstrumentIndicator"
	instrumentIndicator.AutomaticSize = Enum.AutomaticSize.X
	instrumentIndicator.Size = UDim2.new(0, 0, 0, Theme.Sizes.ControlHeightS)
	instrumentIndicator.BackgroundColor3 = Theme.Colors.Surface
	instrumentIndicator.LayoutOrder = value or 0
	instrumentIndicator.Font = Theme.Fonts.Medium
	instrumentIndicator.TextSize = Theme.TextSize.XS
	instrumentIndicator.TextColor3 = Theme.Colors.TextSecondary
	instrumentIndicator.Text = string.format("%d/%d", count2, count)
	instrumentIndicator.Parent = parent

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, Theme.Spacing.S)
	uiPadding.PaddingRight = UDim.new(0, Theme.Spacing.S)
	uiPadding.Parent = instrumentIndicator

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Small
	uiCorner.Parent = instrumentIndicator

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = Theme.Stroke.Thickness
	uiStroke.Color = Theme.Colors.Border
	uiStroke.Transparency = Theme.Stroke.TransparencyDefault
	uiStroke.Parent = instrumentIndicator

	return instrumentIndicator
end

function InstrumentIndicator:Update(options, p)
	if not self then
		return
	end

	local count = 0
	local v2 = options or {}
	local count2 = 0

	for _, v3 in ipairs(p or v) do
		count += 1

		if v2[v3] then
			count2 += 1
		end
	end

	if self:IsA("TextLabel") then
		self.Text = string.format("%d/%d", count2, count)
	end
end

return InstrumentIndicator