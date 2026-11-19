local SkinConfig = {}

SkinConfig.Rarities = {
	Common = { Order = 1, Color = Color3.fromRGB(170, 170, 180) },
	Rare = { Order = 2, Color = Color3.fromRGB(80, 160, 255) },
	Epic = { Order = 3, Color = Color3.fromRGB(184, 108, 255) },
	Legendary = { Order = 4, Color = Color3.fromRGB(255, 176, 48) },
	Custom = { Order = 5, Color = Color3.fromRGB(255, 110, 190) }
}

SkinConfig.CardBackgrounds = {
	Default = "",
	Common = "",
	Rare = "",
	Epic = "",
	Legendary = ""
}

SkinConfig.CategoryByInstrument = { GuitarRhythm = "Guitar", GuitarLead = "Guitar", Bass = "Bass" }

SkinConfig.Categories = { "Guitar", "Bass" }

SkinConfig.Skins = {
	BlackHK = {
		Id = "BlackHK",
		Name = "Black Stratocaster HK",
		Category = "Guitar",
		Rarity = "Legendary",
		Description = "Cute was never meant to be this dark. A black Stratocaster made for players with attitude.",
		Templates = {
			GuitarRhythm = "BlackHK_GuitarRhythm_EquipModel",
			GuitarLead = "BlackHK_GuitarLead_EquipModel"
		},
		PreviewTemplate = "BlackHK_GuitarRhythm_EquipModel",
		PreviewFront = Vector3.new(0, 0, 1)
	},
	PinkHK = {
		Id = "PinkHK",
		Name = "Pink Stratocaster HK",
		Category = "Guitar",
		Rarity = "Epic",
		Description = "Cute on the outside. Loud on the inside. A legendary pink Strat made for players who refuse to blend in.",
		Templates = {
			GuitarRhythm = "PinkHK_GuitarRhythm_EquipModel",
			GuitarLead = "PinkHK_GuitarLead_EquipModel"
		},
		PreviewTemplate = "PinkHK_GuitarRhythm_EquipModel",
		PreviewFront = Vector3.new(0, 0, 1)
	},
	WhiteHK = {
		Id = "WhiteHK",
		Name = "White Stratocaster HK",
		Category = "Guitar",
		Rarity = "Epic",
		Description = "A clean white finish with the unmistakable cute attitude. Sweet, stylish, and ready to make some noise.",
		Templates = {
			GuitarRhythm = "WhiteHK_GuitarRhythm_EquipModel",
			GuitarLead = "WhiteHK_GuitarLead_EquipModel"
		},
		PreviewTemplate = "WhiteHK_GuitarRhythm_EquipModel",
		PreviewFront = Vector3.new(0, 0, 1)
	},
	KurtVandal = {
		Id = "KurtVandal",
		Name = "Kurt Vandal",
		Category = "Guitar",
		Rarity = "Legendary",
		Description = "kurt cobain",
		Templates = {
			GuitarRhythm = "KurtVandal_GuitarRhythm_EquipModel",
			GuitarLead = "KurtVandal_GuitarLead_EquipModel"
		},
		PreviewTemplate = "KurtVandal_GuitarRhythm_EquipModel",
		PreviewFront = Vector3.new(0, 0, 1)
	},
	RickyBass = {
		Id = "RickyBass",
		Name = "Ricky Bass",
		Category = "Bass",
		Rarity = "Epic",
		Description = "A brutal bass with a razor-sharp attitude. Built for the darkest stages.",
		Templates = { Bass = "RickyBass_Bass_EquipModel" },
		PreviewTemplate = "RickyBass_Bass_EquipModel",
		PreviewFront = Vector3.new(-1, 0, 0)
	},
	Custom1 = {
		Id = "Custom1",
		Name = "Custom Guitar 1",
		Category = "Guitar",
		Rarity = "Custom",
		IsCustom = true,
		Slot = 1,
		Description = "Built in Custom Guitar.",
		Templates = {}
	},
	Custom2 = {
		Id = "Custom2",
		Name = "Custom Guitar 2",
		Category = "Guitar",
		Rarity = "Custom",
		IsCustom = true,
		Slot = 2,
		Description = "Built in Custom Guitar.",
		Templates = {}
	},
	Custom3 = {
		Id = "Custom3",
		Name = "Custom Guitar 3",
		Category = "Guitar",
		Rarity = "Custom",
		IsCustom = true,
		Slot = 3,
		Description = "Built in Custom Guitar.",
		Templates = {}
	}
}

SkinConfig.Order = {
	"BlackHK",
	"PinkHK",
	"WhiteHK",
	"KurtVandal",
	"RickyBass",
	"Custom1",
	"Custom2",
	"Custom3"
}

function SkinConfig.Get(value)
	if type(value) == "string" then
		return SkinConfig.Skins[value]
	end

	return nil
end

function SkinConfig.GetCategoryForInstrument(p)
	return SkinConfig.CategoryByInstrument[p]
end

function SkinConfig.GetTemplateName(p, p2)
	local v = SkinConfig.Get(p)
	return v and v.Templates[p2] or nil
end

function SkinConfig.GetRarityColor(p)
	local rarity = SkinConfig.Rarities[p]
	return rarity and rarity.Color or Color3.fromRGB(170, 170, 180)
end

function SkinConfig.GetCardBackground(p)
	local v = SkinConfig.CardBackgrounds[p]

	if type(v) ~= "string" or v == "" then
		v = SkinConfig.CardBackgrounds.Default
	end

	return if type(v) == "string" and v ~= "" then v else nil
end

return SkinConfig