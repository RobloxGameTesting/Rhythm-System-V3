local ChartDifficultyRatings = require(script.Parent.Parent.ChartDifficultyRatings)

local DifficultyBadge = {}
DifficultyBadge.DotSize = 10

local function resolveTier(value) -- 3 equivalent calls inferred from this helper
	if type(value) ~= "string" then
		return nil
	end

	local v = string.upper(value)
	return if ChartDifficultyRatings.Colors[v] then v else nil
end

function DifficultyBadge.WillRender(value): boolean
	return resolveTier(value) ~= nil -- inferred equivalent call
end

function DifficultyBadge.Create(parent, value, value2)
	local tier = resolveTier(value) -- inferred equivalent call

	if not tier then
		return nil
	end

	local difficultyBadge = Instance.new("Frame")
	difficultyBadge.Name = "DifficultyBadge"
	difficultyBadge.Size = UDim2.fromOffset(DifficultyBadge.DotSize, DifficultyBadge.DotSize)
	difficultyBadge.BackgroundColor3 = ChartDifficultyRatings.Colors[tier]
	difficultyBadge.BorderSizePixel = 0
	difficultyBadge.LayoutOrder = value2 or 0
	difficultyBadge:SetAttribute("Tier", tier)
	difficultyBadge.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = difficultyBadge

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.fromRGB(0, 0, 0)
	uiStroke.Transparency = 0.7
	uiStroke.Parent = difficultyBadge

	return difficultyBadge
end

function DifficultyBadge:Update(value)
	local tier = resolveTier(value) -- inferred equivalent call

	if not tier then
		return
	end

	self.BackgroundColor3 = ChartDifficultyRatings.Colors[tier]
	self:SetAttribute("Tier", tier)
end

return DifficultyBadge