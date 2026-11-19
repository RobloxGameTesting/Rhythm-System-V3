local StyledTheme = require(script.Parent.StyledTheme)

local InstrumentIcons = {}

local v = {
	GuitarRhythm = "134471756990100",
	GuitarLead = "121469275127418",
	Bass = "99396957590730",
	Drum = "92093132033974",
	Keyboard = "116736398223985",
	Piano = "103475207999276"
}

InstrumentIcons.Order = { "GuitarRhythm", "GuitarLead", "Bass", "Drum", "Keyboard", "Piano" }

local v2 = {
	GuitarRhythm = Vector2.new(231, 231),
	GuitarLead = Vector2.new(232, 218),
	Bass = Vector2.new(224, 232),
	Drum = Vector2.new(232, 170),
	Keyboard = Vector2.new(232, 133),
	Piano = Vector2.new(213, 232)
}

function InstrumentIcons.GetSize(p, p2)
	local v3 = v2[p]

	if not v3 then
		return Vector2.new(p2, p2)
	end

	local v4 = math.max(v3.X, v3.Y)
	local v5 = p2 * math.min(v3.X + 4, 256) / v4
	local v6 = p2 * math.min(v3.Y + 4, 256) / v4
	return Vector2.new(math.floor(v5 + 0.5), (math.floor(v6 + 0.5)))
end

function InstrumentIcons.Get(p)
	local v3 = v[p]

	if v3 then
		return "rbxassetid://" .. v3
	end

	return nil
end

local v3 = {
	playing = StyledTheme.Colors.Success,
	auto = Color3.fromRGB(120, 120, 128),
	equipped = Color3.fromRGB(240, 140, 50)
}

local color = Color3.new(1, 1, 1)

function InstrumentIcons.GetStateColor(p)
	return v3[p] or color
end

function InstrumentIcons.GetAll()
	local all = {}

	for _, v4 in ipairs(InstrumentIcons.Order) do
		table.insert(all, InstrumentIcons.Get(v4))
	end

	return all
end

return InstrumentIcons