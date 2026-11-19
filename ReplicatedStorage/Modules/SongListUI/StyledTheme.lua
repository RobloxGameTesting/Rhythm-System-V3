local Theme = require(script.Parent.Theme)
local function deepCopy(items)
	local result = {}

	for k, item in pairs(items) do
		item = type(item) == "table" and deepCopy(item) or item
		result[k] = item
	end

	return result
end

local v = {
	BG = Color3.fromRGB(22, 22, 26),
	CARD = Color3.fromRGB(34, 34, 40),
	CARD_ACTIVE = Color3.fromRGB(50, 50, 58),
	TEXT = Color3.fromRGB(245, 245, 247),
	TEXT_DIM = Color3.fromRGB(160, 160, 170),
	ACCENT = Color3.fromRGB(88, 210, 150),
	WARNING = Color3.fromRGB(255, 190, 80),
	DANGER = Color3.fromRGB(144, 55, 47),
	BORDER = Color3.fromRGB(60, 60, 70),
	BUTTON = Color3.fromRGB(23, 23, 27),
	BTN = Color3.fromRGB(45, 45, 52),
	INPUT = Color3.fromRGB(18, 18, 22),
	CAPSULE = Color3.fromRGB(30, 29, 34),
	DARKTEXT = Color3.fromRGB(18, 30, 24),
	LIGHT = Color3.fromRGB(228, 228, 236)
}

local v2 = {
	BG_PANEL = Color3.fromRGB(9, 8, 7),
	BG_CARD = Color3.fromRGB(15, 13, 12),
	BORDER = Color3.fromRGB(40, 33, 28),
	ACCENT = Color3.fromRGB(196, 94, 34),
	ACCENT_DIM = Color3.fromRGB(70, 44, 26),
	TEXT = Color3.fromRGB(226, 218, 208),
	TEXT_MUTED = Color3.fromRGB(128, 116, 106),
	KNOB_DISABLED = Color3.fromRGB(24, 21, 19),
	SWING_ON = Color3.fromRGB(76, 148, 90),
	SWING_OFF = Color3.fromRGB(38, 34, 31),
	NAME_SELF = Color3.fromRGB(110, 200, 120),
	NAME_OTHER = Color3.fromRGB(235, 200, 120)
}

local v3 = deepCopy(Theme)
v3.Style = "Default"
v3.Settings = deepCopy(v)
v3.Amp = deepCopy(v2)

local styles = {}
styles.Default = {
	Colors = deepCopy(Theme.Colors),
	Fonts = deepCopy(Theme.Fonts),
	TextSize = deepCopy(Theme.TextSize),
	Radius = deepCopy(Theme.Radius)
}

styles.Default.Settings = deepCopy(v)
styles.Default.Amp = deepCopy(v2)
styles.NewUI = {
	Amp = {
		BG_PANEL = Color3.fromRGB(20, 20, 19),
		BG_CARD = Color3.fromRGB(15, 15, 14),
		BORDER = Color3.fromRGB(86, 84, 80),
		ACCENT = Color3.fromRGB(214, 108, 38),
		ACCENT_DIM = Color3.fromRGB(78, 46, 26),
		TEXT = Color3.fromRGB(222, 220, 214),
		TEXT_MUTED = Color3.fromRGB(158, 156, 150),
		KNOB_DISABLED = Color3.fromRGB(34, 34, 32),
		SWING_ON = Color3.fromRGB(204, 162, 72),
		SWING_OFF = Color3.fromRGB(48, 47, 44),
		NAME_SELF = Color3.fromRGB(150, 186, 112),
		NAME_OTHER = Color3.fromRGB(226, 188, 96)
	},
	Settings = {
		BG = Color3.fromRGB(20, 20, 19),
		CARD = Color3.fromRGB(15, 15, 14),
		CARD_ACTIVE = Color3.fromRGB(64, 62, 58),
		TEXT = Color3.fromRGB(222, 220, 214),
		TEXT_DIM = Color3.fromRGB(158, 156, 150),
		ACCENT = Color3.fromRGB(204, 162, 72),
		WARNING = Color3.fromRGB(214, 140, 48),
		DANGER = Color3.fromRGB(176, 38, 34),
		BORDER = Color3.fromRGB(86, 84, 80),
		BUTTON = Color3.fromRGB(12, 12, 11),
		BTN = Color3.fromRGB(34, 34, 32),
		INPUT = Color3.fromRGB(10, 10, 9),
		CAPSULE = Color3.fromRGB(24, 24, 22),
		DARKTEXT = Color3.fromRGB(28, 24, 20),
		LIGHT = Color3.fromRGB(198, 190, 170)
	},
	Colors = {
		Background = Color3.fromRGB(20, 20, 19),
		Surface = Color3.fromRGB(15, 15, 14),
		SurfaceHover = Color3.fromRGB(34, 34, 32),
		SurfaceSelected = Color3.fromRGB(64, 62, 58),
		Border = Color3.fromRGB(86, 84, 80),
		BorderHover = Color3.fromRGB(132, 130, 124),
		TextPrimary = Color3.fromRGB(222, 220, 214),
		TextSecondary = Color3.fromRGB(158, 156, 150),
		TextDisabled = Color3.fromRGB(104, 102, 98),
		Accent = Color3.fromRGB(204, 162, 72),
		AccentText = Color3.fromRGB(24, 22, 18),
		Success = Color3.fromRGB(62, 150, 92),
		Danger = Color3.fromRGB(176, 38, 34)
	},
	Fonts = {
		Regular = Enum.Font.SpecialElite,
		Medium = Enum.Font.SpecialElite,
		Bold = Enum.Font.Oswald
	},
	TextSize = {
		XS = 11,
		S = 11,
		M = 12,
		L = 13,
		XL = 14,
		XXL = 17
	},
	Radius = {
		Small = UDim.new(0, 2),
		Medium = UDim.new(0, 3),
		Large = UDim.new(0, 3),
		Pill = UDim.new(1, 0)
	}
}

v3.Grunge = {
	Tape = Color3.fromRGB(206, 190, 150),
	TapeDark = Color3.fromRGB(96, 90, 80),
	WindowStroke = Color3.fromRGB(8, 8, 8),
	EdgeWear = Color3.fromRGB(122, 120, 114),
	Rust = Color3.fromRGB(74, 42, 28),
	Metal = Color3.fromRGB(58, 56, 52)
}

v3.Styles = styles

local function colorKey(data) -- 6 equivalent calls inferred from this helper
	return string.format(
		"%d,%d,%d",
		math.floor(data.R * 255 + 0.5),
		math.floor(data.G * 255 + 0.5),
		(math.floor(data.B * 255 + 0.5))
	)
end

v3.ColorKey = colorKey

local maps = { NewUI = {}, Default = {} }

for k, color in pairs(styles.Default.Colors) do
	local color2 = styles.NewUI.Colors[k]

	if not color2 then
		continue
	end

	maps.NewUI[colorKey(color)] = color2 -- inferred equivalent call
	maps.Default[colorKey(color2)] = color -- inferred equivalent call
end

v3.Maps = maps

local settingsMaps = { NewUI = {}, Default = {} }

for k, setting in pairs(styles.Default.Settings) do
	local setting2 = styles.NewUI.Settings[k]

	if not setting2 then
		continue
	end

	settingsMaps.NewUI[colorKey(setting)] = setting2 -- inferred equivalent call
	settingsMaps.Default[colorKey(setting2)] = setting -- inferred equivalent call
end

v3.SettingsMaps = settingsMaps

local ampMaps = { NewUI = {}, Default = {} }

for k, v4 in pairs(styles.Default.Amp) do
	local v5 = styles.NewUI.Amp[k]

	if not v5 then
		continue
	end

	ampMaps.NewUI[colorKey(v4)] = v5 -- inferred equivalent call
	ampMaps.Default[colorKey(v5)] = v4 -- inferred equivalent call
end

v3.AmpMaps = ampMaps

function v3.Apply(style): boolean
	local v4 = styles[style]

	if not v4 then
		return false
	end

	for k, v5 in pairs(v4) do
		local v6 = v3[k]

		for k2, v7 in pairs(v5) do
			v6[k2] = v7
		end
	end

	v3.Style = style
	return true
end

function v3.IsNewUI(): boolean
	return v3.Style == "NewUI"
end

return v3