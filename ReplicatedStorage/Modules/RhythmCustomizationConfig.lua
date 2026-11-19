local RhythmCustomizationConfig = {}

RhythmCustomizationConfig.Shapes = {
	"Circle",
	"Rounded",
	"Pill",
	"Square",
	"Hero",
	"Diamond",
	"Arrow"
}
RhythmCustomizationConfig.DefaultShape = "Circle"
local shapeSet = {}

for _, shape in ipairs(RhythmCustomizationConfig.Shapes) do
	shapeSet[shape] = true
end

function RhythmCustomizationConfig.IsValidShape(p): boolean
	return shapeSet[p] == true
end

RhythmCustomizationConfig.JudgmentTypes = { "Perfect", "Great", "Good", "OK", "Miss", "Wrong" }

local judgmentTypeSet = {}

for _, judgmentType in ipairs(RhythmCustomizationConfig.JudgmentTypes) do
	judgmentTypeSet[judgmentType] = true
end

function RhythmCustomizationConfig.IsValidJudgmentType(p): boolean
	return judgmentTypeSet[p] == true
end

RhythmCustomizationConfig.LaneCountBuckets = { 2, 3, 4, 5 }

local laneCountBucketSet = {}

for _, laneCountBucket in ipairs(RhythmCustomizationConfig.LaneCountBuckets) do
	laneCountBucketSet[laneCountBucket] = true
end

function RhythmCustomizationConfig.IsValidLaneCount(p): boolean
	return laneCountBucketSet[p] == true
end

RhythmCustomizationConfig.ColorFields = {
	"NoteInner",
	"NoteOuter",
	"ReceptorRing",
	"ReceptorPress"
}

function RhythmCustomizationConfig.SerializeColor(data)
	if typeof(data) == "Color3" then
		return { R = data.R, G = data.G, B = data.B }
	end

	return nil
end

function RhythmCustomizationConfig.DeserializeColor(data)
	if typeof(data) == "table" and type(data.R) == "number" then
		return Color3.new(math.clamp(data.R, 0, 1), math.clamp(data.G, 0, 1), (math.clamp(data.B, 0, 1)))
	end

	return nil
end

RhythmCustomizationConfig.JudgmentDefaultColors = {
	Perfect = Color3.fromRGB(140, 170, 110),
	Great = Color3.fromRGB(90, 130, 155),
	Good = Color3.fromRGB(175, 150, 70),
	OK = Color3.fromRGB(160, 105, 55),
	Miss = Color3.fromRGB(130, 40, 35),
	Wrong = Color3.fromRGB(110, 55, 110)
}

RhythmCustomizationConfig.DefaultLaneAccentColors = {
	Color3.fromRGB(75, 95, 60),
	Color3.fromRGB(120, 40, 35),
	Color3.fromRGB(150, 125, 45),
	Color3.fromRGB(55, 80, 95),
	Color3.fromRGB(150, 85, 30)
}

function RhythmCustomizationConfig.GetDefaultAccentColor(p)
	local defaultLaneAccentColors = RhythmCustomizationConfig.DefaultLaneAccentColors
	return defaultLaneAccentColors[(p - 1) % #defaultLaneAccentColors + 1]
end

function RhythmCustomizationConfig.ValidateColorData(data): boolean
	if typeof(data) ~= "table" then
		return false
	end

	return type(data.R) == "number" and type(data.G) == "number" and type(data.B) == "number"
end

function RhythmCustomizationConfig.ValidateLaneColorEntry(p): boolean
	if typeof(p) ~= "table" then
		return false
	end

	for _, colorField in ipairs(RhythmCustomizationConfig.ColorFields) do
		if p[colorField] ~= nil and not RhythmCustomizationConfig.ValidateColorData(p[colorField]) then
			return false
		end
	end

	return true
end

function RhythmCustomizationConfig.ValidateLaneColors(items): boolean
	if typeof(items) ~= "table" then
		return false
	end

	for k, item in pairs(items) do
		local v = tonumber(k)

		if not (v and RhythmCustomizationConfig.IsValidLaneCount(v) and typeof(item) == "table") then
			return false
		end

		for i = 1, v do
			local v2 = item[i]

			if v2 ~= nil and v2 ~= false and not RhythmCustomizationConfig.ValidateLaneColorEntry(v2) then
				return false
			end
		end
	end

	return true
end

function RhythmCustomizationConfig.ValidateJudgmentColors(items): boolean
	if typeof(items) ~= "table" then
		return false
	end

	for k, item in pairs(items) do
		if
			not RhythmCustomizationConfig.IsValidJudgmentType(k)
			or item ~= false and not RhythmCustomizationConfig.ValidateColorData(item)
		then
			return false
		end
	end

	return true
end

RhythmCustomizationConfig.ThemePresetNames = {
	"Default",
	"Classic",
	"Neon",
	"Arcade",
	"Monochrome",
	"Fire",
	"Ice",
	"Cyber",
	"Pastel",
	"Custom"
}

local themePresetNameSet = {}

for _, themePresetName in ipairs(RhythmCustomizationConfig.ThemePresetNames) do
	themePresetNameSet[themePresetName] = true
end

function RhythmCustomizationConfig.IsValidThemePresetName(value): boolean
	return type(value) == "string" and themePresetNameSet[value] == true
end

return RhythmCustomizationConfig