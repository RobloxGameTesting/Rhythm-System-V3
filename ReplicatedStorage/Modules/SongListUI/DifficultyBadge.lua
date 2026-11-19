local ChartDifficultyRatings = require(script.Parent.Parent.ChartDifficultyRatings)

local DifficultyBadge = {}
DifficultyBadge.DotSize = 12
local v = {
	{ w = 10, h = 10, rot = 8, a = 0 },
	{ w = 8, h = 11, rot = -19, a = 0.15 },
	{ w = 11, h = 7, rot = 33, a = 0.25 }
}

local v2 = { EASY = -6, MEDIUM = 9, HARD = -3, INSANE = 12 }

local function resolveTier(value) -- 5 equivalent calls inferred from this helper
	if type(value) ~= "string" then
		return nil
	end

	local v3 = string.upper(value)
	return if ChartDifficultyRatings.Colors[v3] then v3 else nil
end

local function inkOf(tier) -- 1 equivalent call inferred from this helper
	return ChartDifficultyRatings.InkColors and ChartDifficultyRatings.InkColors[tier]
		or ChartDifficultyRatings.Colors[tier]
end

local function applyTier(instance, tier)
	instance:SetAttribute("Tier", tier)
	local blob = instance:FindFirstChild("Blob")

	if not blob then
		return
	end

	blob.Rotation = v2[tier] or 0
	local backgroundColor = inkOf(tier) -- inferred equivalent call

	for _, child in ipairs(blob:GetChildren()) do
		if child:GetAttribute("InkLayer") then
			child.BackgroundColor3 = backgroundColor
		end
	end
end

function DifficultyBadge.TierFor(data, value)
	if type(data) ~= "table" then
		return nil
	end

	local instrumentAvailability = data.instrumentAvailability

	if
		type(value) == "string"
		and type(data.instrumentDifficulty) == "table"
		and type(instrumentAvailability) == "table"
		and instrumentAvailability[value] ~= nil
	then
		return resolveTier(data.instrumentDifficulty[value]) -- inferred equivalent call
	end

	return resolveTier(data.difficulty) -- inferred equivalent call
end

function DifficultyBadge.WillRender(value): boolean
	return resolveTier(value) ~= nil -- inferred equivalent call
end

local function buildDot(value, p)
	local difficultyBadge = Instance.new("Frame")
	difficultyBadge.Name = "DifficultyBadge"
	local v3 = p or DifficultyBadge.DotSize
	local v4 = v3 / DifficultyBadge.DotSize
	difficultyBadge.Size = UDim2.fromOffset(v3, v3)
	difficultyBadge.BackgroundTransparency = 1
	difficultyBadge.BorderSizePixel = 0
	difficultyBadge.LayoutOrder = value or 0

	local blob = Instance.new("Frame")
	blob.Name = "Blob"
	blob.BackgroundTransparency = 1
	blob.AnchorPoint = Vector2.new(0.5, 0.5)
	blob.Position = UDim2.new(0.5, 0, 0.5, 0)
	blob.Size = UDim2.fromScale(1, 1)
	blob.Parent = difficultyBadge

	for i, v5 in ipairs(v) do
		local frame = Instance.new("Frame")
		frame.Name = "Layer" .. i
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.Size = UDim2.fromOffset(v5.w * v4, v5.h * v4)
		frame.Rotation = v5.rot
		frame.BackgroundTransparency = math.min(1, v5.a + 0.12)
		frame.BorderSizePixel = 0
		frame:SetAttribute("InkLayer", true)
		frame.Parent = blob

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.3, 0)
		uiCorner.Parent = frame
	end

	local scratch = Instance.new("Frame")
	scratch.Name = "Scratch"
	scratch.AnchorPoint = Vector2.new(0.5, 0.5)
	scratch.Position = UDim2.new(0.5, 0, 0.5, 0)
	scratch.Size = UDim2.fromOffset(14 * v4, (math.max(1, (math.floor(v4 + 0.5)))))
	scratch.Rotation = -38
	scratch.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	scratch.BackgroundTransparency = 0.55
	scratch.BorderSizePixel = 0
	scratch.ZIndex = 2
	scratch.Parent = blob

	return difficultyBadge
end

function DifficultyBadge.Create(parent, value, p, p2)
	local tier = resolveTier(value) -- inferred equivalent call

	if not tier then
		return nil
	end

	local dot = buildDot(p, p2)
	applyTier(dot, tier)
	dot.Parent = parent

	return dot
end

local v3 = { -6, 9, -3, 12 }
function DifficultyBadge.CreateColored(parent, backgroundColor, p, p2, value)
	local dot = buildDot(p, p2)
	local blob = dot:FindFirstChild("Blob")

	if blob then
		blob.Rotation = v3[((value or 1) - 1) % #v3 + 1]

		for _, child in ipairs(blob:GetChildren()) do
			if child:GetAttribute("InkLayer") then
				child.BackgroundColor3 = backgroundColor
			end
		end
	end

	dot.Parent = parent

	return dot
end

function DifficultyBadge.Update(p, value)
	local tier = resolveTier(value) -- inferred equivalent call

	if not tier then
		return
	end

	applyTier(p, tier)
end

return DifficultyBadge