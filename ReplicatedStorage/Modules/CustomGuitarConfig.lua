local CustomGuitarConfig = {}
CustomGuitarConfig.MAX_SLOTS = 3
CustomGuitarConfig.NAME_MAX = 20
CustomGuitarConfig.DEFAULT_NAME = "Custom Guitar"
CustomGuitarConfig.SKIN_ID_PREFIX = "Custom"
CustomGuitarConfig.Palette = {
	{ Name = "White", Color = Color3.fromRGB(245, 245, 245) },
	{ Name = "Black", Color = Color3.fromRGB(22, 22, 26) },
	{ Name = "Charcoal", Color = Color3.fromRGB(70, 72, 80) },
	{ Name = "Silver", Color = Color3.fromRGB(176, 180, 188) },
	{ Name = "Gold", Color = Color3.fromRGB(212, 175, 55) },
	{ Name = "Red", Color = Color3.fromRGB(200, 30, 40) },
	{ Name = "Crimson", Color = Color3.fromRGB(140, 15, 35) },
	{ Name = "Orange", Color = Color3.fromRGB(240, 120, 30) },
	{ Name = "Yellow", Color = Color3.fromRGB(245, 205, 50) },
	{ Name = "Lime", Color = Color3.fromRGB(130, 200, 60) },
	{ Name = "Green", Color = Color3.fromRGB(30, 140, 70) },
	{ Name = "Teal", Color = Color3.fromRGB(20, 160, 160) },
	{ Name = "Sky", Color = Color3.fromRGB(90, 180, 240) },
	{ Name = "Blue", Color = Color3.fromRGB(35, 90, 200) },
	{ Name = "Navy", Color = Color3.fromRGB(20, 35, 100) },
	{ Name = "Purple", Color = Color3.fromRGB(120, 60, 190) },
	{ Name = "Violet", Color = Color3.fromRGB(170, 100, 230) },
	{ Name = "Pink", Color = Color3.fromRGB(255, 120, 180) },
	{ Name = "Hot Pink", Color = Color3.fromRGB(240, 40, 140) },
	{ Name = "Cream", Color = Color3.fromRGB(238, 228, 198) },
	{ Name = "Natural Wood", Color = Color3.fromRGB(214, 160, 98) },
	{ Name = "Dark Wood", Color = Color3.fromRGB(92, 56, 28) },
	{ Name = "Rosewood", Color = Color3.fromRGB(64, 32, 24) },
	{ Name = "Mint", Color = Color3.fromRGB(150, 230, 200) }
}

CustomGuitarConfig.FinishOrder = { "Gloss", "Satin", "Metallic", "Pearl" }
CustomGuitarConfig.Finishes = {
	Gloss = { Label = "Gloss", Material = Enum.Material.SmoothPlastic },
	Satin = { Label = "Satin", Material = Enum.Material.Plastic },
	Metallic = { Label = "Metallic", Material = Enum.Material.Metal },
	Pearl = { Label = "Pearl", Material = Enum.Material.Foil }
}
CustomGuitarConfig.DEFAULT_FINISH = "Gloss"
CustomGuitarConfig.SlotOrder = { "Body", "Neck", "Fretboard", "Pickguard", "Accents" }
CustomGuitarConfig.SlotLabels = {
	Body = "Body",
	Neck = "Neck & Headstock",
	Fretboard = "Fretboard",
	Pickguard = "Pickguard",
	Accents = "Knobs & Hardware"
}

CustomGuitarConfig.Families = {
	StratHK = {
		Id = "StratHK",
		Name = "Stratocaster",
		Templates = {
			GuitarRhythm = "Custom_StratHK_GuitarRhythm",
			GuitarLead = "Custom_StratHK_GuitarLead"
		},
		PreviewFront = Vector3.new(0, 0, 1),
		Slots = {
			Body = { "Object_1" },
			Neck = { "Object_30_rest", "Headstock" },
			Fretboard = { "Object_30_fret" },
			Accents = { "Knob_VOLUME", "Bridge_Plate", "CavityCover" }
		},
		Defaults = { Body = 1, Neck = 21, Fretboard = 22, Accents = 4 }
	},
	KurtVandal = {
		Id = "KurtVandal",
		Name = "Vandal Strat",
		Templates = {
			GuitarRhythm = "Custom_KurtVandal_GuitarRhythm",
			GuitarLead = "Custom_KurtVandal_GuitarLead"
		},
		PreviewFront = Vector3.new(0, 0, 1),
		Slots = {
			Body = { "Object_1" },
			Neck = { "Object_30_rest" },
			Fretboard = { "Object_30_fret" },
			Pickguard = { "Object_29" },
			Accents = { "Knob_VOLUME", "Knob_TONE", "Object_28" }
		},
		Defaults = {
			Body = 1,
			Neck = 21,
			Fretboard = 22,
			Pickguard = 2,
			Accents = 4
		}
	}
}

CustomGuitarConfig.FamilyOrder = { "StratHK", "KurtVandal" }

function CustomGuitarConfig.GetFamily(value)
	if type(value) == "string" then
		return CustomGuitarConfig.Families[value]
	end

	return nil
end

function CustomGuitarConfig.GetColor(value)
	local v

	if type(value) == "number" then
		v = CustomGuitarConfig.Palette[value]
	else
		v = false
	end

	return v and v.Color or nil
end

function CustomGuitarConfig.GetSlotList(p)
	local slotList = {}

	for _, v in ipairs(CustomGuitarConfig.SlotOrder) do
		if p.Slots[v] then
			table.insert(slotList, v)
		end
	end

	return slotList
end

function CustomGuitarConfig.NewDesign(p)
	local family = CustomGuitarConfig.GetFamily(p)

	if not family then
		return nil
	end

	local colors = {}

	for k in pairs(family.Slots) do
		colors[k] = family.Defaults[k] or 1
	end

	return {
		Family = family.Id,
		Name = CustomGuitarConfig.DEFAULT_NAME,
		Finish = CustomGuitarConfig.DEFAULT_FINISH,
		Colors = colors
	}
end

function CustomGuitarConfig.Sanitize(data)
	if typeof(data) ~= "table" then
		return nil
	end

	local family = CustomGuitarConfig.GetFamily(data.Family)

	if not family then
		return nil
	end

	local design = CustomGuitarConfig.NewDesign(family.Id)

	if data.Finish ~= nil and CustomGuitarConfig.Finishes[data.Finish] then
		design.Finish = data.Finish
	end

	if typeof(data.Colors) == "table" then
		for k in pairs(family.Slots) do
			local color = data.Colors[k]

			if type(color) == "number" and color % 1 == 0 and CustomGuitarConfig.Palette[color] then
				design.Colors[k] = color
			end
		end
	end

	if type(data.Name) == "string" then
		local name = string.sub(
			data.Name:gsub("[%c]", ""):gsub("^%s+", ""):gsub("%s+$", ""),
			1,
			CustomGuitarConfig.NAME_MAX
		)

		if name ~= "" then
			design.Name = name
		end
	end

	return design
end

function CustomGuitarConfig.Signature(data)
	local family = CustomGuitarConfig.GetFamily(data.Family)

	if not family then
		return "invalid"
	end

	local v = { family.Id, data.Finish or CustomGuitarConfig.DEFAULT_FINISH }

	for _, v2 in ipairs(CustomGuitarConfig.SlotOrder) do
		if family.Slots[v2] then
			table.insert(v, v2 .. "=" .. tostring(data.Colors[v2]))
		end
	end

	return table.concat(v, "|")
end

function CustomGuitarConfig.SkinIdForSlot(p)
	return CustomGuitarConfig.SKIN_ID_PREFIX .. tostring(p)
end

function CustomGuitarConfig.SlotFromSkinId(value)
	if type(value) ~= "string" then
		return nil
	end

	local v = string.match(value, "^" .. CustomGuitarConfig.SKIN_ID_PREFIX .. "(%d+)$")
	local selected = v and tonumber(v)

	if selected and selected >= 1 and selected <= CustomGuitarConfig.MAX_SLOTS then
		return selected
	end

	return nil
end

return CustomGuitarConfig