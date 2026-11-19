local GenreColorConfig = {
	Colors = {
		["Alternative Rock"] = "4FA8D8",
		DSBM = "37474F",
		Emo = "6B1E2B",
		Grindcore = "8B0000",
		Metal = "71797E",
		["Metal - Groove"] = "C77B3E",
		["Metal - Heavy"] = "5C6670",
		["Metal - Nu"] = "7CFF6B",
		["New wave"] = "00E5FF",
		Pop = "FFD93D",
		["Pop - Indo"] = "FF6F91",
		["Pop - Punk - Indo"] = "FF6B6B",
		["Pop - Rock - Indo"] = "FF9F45",
		Punk = "FF2F92",
		Rock = "E5533D",
		["Rock - Britpop"] = "5AC8FA",
		["Rock - Gothic"] = "6A0DAD",
		["Rock - Neoclassical"] = "D4AF37",
		["Rock - Surf - Indo"] = "40E0D0",
		Shoegaze = "B39DDB",
		Solo = "AAAAAA"
	},
	DefaultColor = "CCCCCC",
	KeywordFallbacks = {
		{ Keyword = "Metal", Color = "71797E" },
		{ Keyword = "Punk", Color = "FF2F92" },
		{ Keyword = "Rock", Color = "E5533D" },
		{ Keyword = "Pop", Color = "FFD93D" }
	}
}

function GenreColorConfig.GetColor(value)
	if typeof(value) ~= "string" or value == "" then
		return GenreColorConfig.DefaultColor
	end

	local color = GenreColorConfig.Colors[value]

	if color then
		return color
	end

	for _, keywordFallback in ipairs(GenreColorConfig.KeywordFallbacks) do
		if string.find(value, keywordFallback.Keyword) then
			return keywordFallback.Color
		end
	end

	return GenreColorConfig.DefaultColor
end

return GenreColorConfig