local set = {}
local DrumKeybindRules = {}
DrumKeybindRules.LANE_COUNT = 22
DrumKeybindRules.Defaults = {
	"E",
	"W",
	"R",
	"M",
	"X",
	"D",
	"F",
	"G",
	"H",
	"U",
	"I",
	"Comma",
	"Z",
	"C",
	"V",
	"S",
	"B",
	"N",
	"J",
	"K",
	"O",
	"A"
}

for i = 65, 90 do
	set[string.char(i)] = true
end

for _, v in ipairs({
	"Zero",
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
	"Backquote",
	"Minus",
	"Equals",
	"LeftBracket",
	"RightBracket",
	"BackSlash",
	"Semicolon",
	"Quote",
	"Comma",
	"Period",
	"Slash"
}) do
	set[v] = true
end

local v = {
	LeftShift = true,
	RightShift = true,
	LeftControl = true,
	RightControl = true,
	LeftAlt = true,
	RightAlt = true,
	LeftMeta = true,
	RightMeta = true
}

local v2 = {
	Zero = "0",
	One = "1",
	Two = "2",
	Three = "3",
	Four = "4",
	Five = "5",
	Six = "6",
	Seven = "7",
	Eight = "8",
	Nine = "9",
	Backquote = "`",
	Minus = "-",
	Equals = "=",
	LeftBracket = "[",
	RightBracket = "]",
	BackSlash = "\\",
	Semicolon = ";",
	Quote = "'",
	Comma = "Comma",
	Period = "Period",
	Slash = "Slash"
}

function DrumKeybindRules.IsAllowedName(value): boolean
	return typeof(value) == "string" and set[value] == true
end

function DrumKeybindRules.IsModifierName(p): boolean
	return v[p] == true
end

function DrumKeybindRules.DisplayName(p)
	return v2[p] or p
end

function DrumKeybindRules.CopyDefaults()
	local defaults = {}

	for i, default in ipairs(DrumKeybindRules.Defaults) do
		defaults[i] = default
	end

	return defaults
end

function DrumKeybindRules.Validate(list): boolean
	if typeof(list) ~= "table" then
		return false
	end

	local set2 = {}

	for i = 1, DrumKeybindRules.LANE_COUNT do
		local item = list[i]

		if DrumKeybindRules.IsAllowedName(item) and not set2[item] then
			set2[item] = true
		else
			return false
		end
	end

	for k in pairs(list) do
		if typeof(k) ~= "number" or k < 1 or DrumKeybindRules.LANE_COUNT < k or k % 1 ~= 0 then
			return false
		end
	end

	return true
end

return DrumKeybindRules