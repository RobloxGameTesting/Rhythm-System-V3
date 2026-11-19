local FreePlayDrumKits = {}
FreePlayDrumKits.DEFAULT = "Normal"
FreePlayDrumKits.KIT_ORDER = { "Normal", "BlackFreitag", "BlastBeatsSnare1", "BlastBeatsSnare2" }

FreePlayDrumKits.DISPLAY_NAME = {
	Normal = "Normal",
	BlackFreitag = "Black Freitag",
	BlastBeatsSnare1 = "Blast Beats Snare 1",
	BlastBeatsSnare2 = "Blast Beats Snare 2"
}

FreePlayDrumKits.PADS = {
	"HighCrash",
	"Splash",
	"MediumCrash",
	"FootHiHat",
	"HighTom",
	"MidTom",
	"RideEdge",
	"RideBell",
	"OpenHiHat",
	"Snare",
	"SideStick",
	"BassDrum",
	"FloorTom",
	"China",
	"Cowbell"
}

FreePlayDrumKits.PAD_DISPLAY_NAME = {
	HighCrash = "High Crash",
	Splash = "Splash",
	MediumCrash = "Medium Crash",
	FootHiHat = "Foot Hi-Hat",
	HighTom = "High Tom",
	MidTom = "Mid Tom",
	RideEdge = "Ride Edge",
	RideBell = "Ride Bell",
	OpenHiHat = "Open Hi-Hat",
	Snare = "Snare",
	SideStick = "Side Stick",
	BassDrum = "Kick",
	FloorTom = "Floor Tom",
	China = "China",
	Cowbell = "Cowbell"
}

FreePlayDrumKits.CATEGORIES = {
	{
		Name = "Snare",
		Pads = { "Snare" }
	},
	{
		Name = "Side Stick",
		Pads = { "SideStick" }
	},
	{
		Name = "Kick",
		Pads = { "BassDrum" }
	},
	{
		Name = "Tom",
		Pads = { "HighTom", "MidTom", "FloorTom" }
	},
	{
		Name = "Hi-Hat",
		Pads = { "FootHiHat", "OpenHiHat" }
	},
	{
		Name = "Ride",
		Pads = { "RideEdge", "RideBell" }
	},
	{
		Name = "Crash",
		Pads = { "HighCrash", "MediumCrash" }
	},
	{
		Name = "Splash",
		Pads = { "Splash" }
	},
	{
		Name = "China",
		Pads = { "China" }
	},
	{
		Name = "Cowbell",
		Pads = { "Cowbell" }
	}
}

local v = {
	BlackFreitag = {
		Snare = {
			Layers = {
				{ Label = "105", Sound = "rbxassetid://95638800984200" },
				{ Label = "110", Sound = "rbxassetid://105971923235786" },
				{ Label = "115", Sound = "rbxassetid://77503483350212" },
				{ Label = "120", Sound = "rbxassetid://130477151353824" },
				{ Label = "125", Sound = "rbxassetid://75642170023754" },
				{ Label = "129", Sound = "rbxassetid://91694304088664" }
			}
		},
		RideBell = {
			Layers = {
				{ Label = "105", Sound = "rbxassetid://87864737613885" },
				{ Label = "110", Sound = "rbxassetid://135387110737478" }
			}
		},
		BassDrum = {
			Layers = {
				{ Label = "105", Sound = "rbxassetid://101211209505048" },
				{ Label = "110", Sound = "rbxassetid://137089711969725" },
				{ Label = "115", Sound = "rbxassetid://136470127520624" },
				{ Label = "119", Sound = "rbxassetid://97812817223263" }
			}
		},
		HighTom = {
			Layers = {
				{ Label = "110", Sound = "rbxassetid://131412926455963" },
				{ Label = "115", Sound = "rbxassetid://75817564194366" },
				{ Label = "120", Sound = "rbxassetid://119871267371744" },
				{ Label = "125", Sound = "rbxassetid://93814155349246" },
				{ Label = "127", Sound = "rbxassetid://75464406918006" }
			}
		},
		MidTom = {
			Layers = {
				{ Label = "210", Sound = "rbxassetid://120479593648271" },
				{ Label = "220", Sound = "rbxassetid://120826580547507" },
				{ Label = "225", Sound = "rbxassetid://101867653291141" },
				{ Label = "230", Sound = "rbxassetid://136751953181460" }
			}
		},
		FloorTom = {
			Layers = {
				{ Label = "110", Sound = "rbxassetid://96304829538101" },
				{ Label = "115", Sound = "rbxassetid://122015776234619" },
				{ Label = "120", Sound = "rbxassetid://139003318116764" },
				{ Label = "125", Sound = "rbxassetid://110442736535588" },
				{ Label = "130", Sound = "rbxassetid://109570574213214" }
			}
		},
		FootHiHat = {
			Layers = {
				{ Label = "103", Sound = "rbxassetid://110321586874575" },
				{ Label = "105", Sound = "rbxassetid://140340328304106" },
				{ Label = "110", Sound = "rbxassetid://119887905406103" },
				{ Label = "115", Sound = "rbxassetid://77263329768012" }
			}
		},
		OpenHiHat = {
			Layers = {
				{ Label = "103", Sound = "rbxassetid://82603892240622" },
				{ Label = "105", Sound = "rbxassetid://127144500099487" },
				{ Label = "110", Sound = "rbxassetid://135392450693985" },
				{ Label = "113", Sound = "rbxassetid://80833139302255" }
			}
		},
		RideEdge = {
			Layers = {
				{ Label = "101", Sound = "rbxassetid://83821948358311" },
				{ Label = "105", Sound = "rbxassetid://81657773329669" }
			}
		},
		HighCrash = {
			Layers = {
				{ Label = "105", Sound = "rbxassetid://124971570558790" },
				{ Label = "110", Sound = "rbxassetid://76140261852875" }
			}
		},
		China = {
			Layers = {
				{ Label = "105", Sound = "rbxassetid://86150423562831" },
				{ Label = "109", Sound = "rbxassetid://77668337476457" },
				{ Label = "110", Sound = "rbxassetid://140128354236107" },
				{ Label = "115", Sound = "rbxassetid://94400888831056" }
			}
		}
	},
	BlastBeatsSnare1 = {
		Snare = {
			Layers = {
				{ Label = "1", Sound = "rbxassetid://114968314621425" }
			}
		}
	},
	BlastBeatsSnare2 = {
		Snare = {
			Layers = {
				{ Label = "1", Sound = "rbxassetid://113924505294633" }
			}
		}
	}
}

local function entryReady(p): boolean
	if type(p) ~= "table" or type(p.Layers) ~= "table" or #p.Layers == 0 then
		return false
	end

	for _, layer in ipairs(p.Layers) do
		if type(layer.Sound) ~= "string" or layer.Sound == "" or layer.Sound == "rbxassetid://0" then
			return false
		end
	end

	return true
end

local function volumes(snare) -- 4 equivalent calls inferred from this helper
	return {
		HighCrash = 0.6,
		Splash = 1,
		MediumCrash = 1,
		FootHiHat = 1,
		HighTom = 1,
		MidTom = 1,
		RideEdge = 1,
		RideBell = 1,
		OpenHiHat = 1,
		Snare = snare,
		SideStick = 1,
		BassDrum = 1,
		FloorTom = 1,
		China = 1,
		Cowbell = 1
	}
end

local v2 = {
	Normal = volumes(2.5), -- inferred equivalent call
	BlackFreitag = volumes(1), -- inferred equivalent call
	BlastBeatsSnare1 = volumes(0.48), -- inferred equivalent call
	BlastBeatsSnare2 = volumes(0.55) -- inferred equivalent call
}

v2.BlackFreitag.RideBell = 3

v2.BlackFreitag.BassDrum = 1
v2.BlackFreitag.HighTom = 1
v2.BlackFreitag.MidTom = 0.85
v2.BlackFreitag.FloorTom = 1.8
v2.BlackFreitag.FootHiHat = 3
v2.BlackFreitag.OpenHiHat = 3
v2.BlackFreitag.RideEdge = 3.5
v2.BlackFreitag.HighCrash = 1.3
v2.BlackFreitag.China = 2.6

local v3 = {
	BlackFreitag = {
		Snare = false,
		RideBell = { 4.3, 0.5 },
		BassDrum = { 1.95, 0.12 },
		HighTom = { 2.3, 0.2 },
		MidTom = { 2.25, 0.16 },
		FloorTom = { 2.3, 0.17 },
		FootHiHat = { 0.34, 0.1 },
		OpenHiHat = { 4.6, 0.5 },
		RideEdge = { 6.6, 0.5 },
		HighCrash = { 3, 0.4 },
		China = { 4, 0.5 }
	},
	BlastBeatsSnare1 = { Snare = false },
	BlastBeatsSnare2 = {
		Snare = { 0.2, 0.07 }
	}
}

function FreePlayDrumKits.IsValidKit(value): boolean
	return type(value) == "string" and FreePlayDrumKits.DISPLAY_NAME[value] ~= nil
end

function FreePlayDrumKits.PadHasKit(value, value2)
	if value == FreePlayDrumKits.DEFAULT then
		return FreePlayDrumKits.PAD_DISPLAY_NAME[value2] ~= nil
	end

	local v4

	if type(value) == "string" then
		v4 = v[value] or nil
	end

	return v4 ~= nil and type(value2) == "string" and entryReady(v4[value2])
end

function FreePlayDrumKits.GetPadKits(p)
	local padKits = {}

	for _, v4 in ipairs(FreePlayDrumKits.KIT_ORDER) do
		if FreePlayDrumKits.PadHasKit(v4, p) then
			table.insert(padKits, v4)
		end
	end

	return padKits
end

function FreePlayDrumKits.GetLayerCount(p, p2)
	if p == FreePlayDrumKits.DEFAULT then
		return 1
	end

	if FreePlayDrumKits.PadHasKit(p, p2) then
		return #v[p][p2].Layers
	end

	return 0
end

function FreePlayDrumKits.GetLayerLabel(p, p2, p3)
	if not FreePlayDrumKits.PadHasKit(p, p2) or p == FreePlayDrumKits.DEFAULT then
		return nil
	end

	local layers = v[p][p2].Layers
	local layer = layers[math.clamp(math.floor(tonumber(p3) or 1), 1, #layers)]
	return layer and layer.Label or nil
end

function FreePlayDrumKits.GetSample(p, p2, p3)
	if p == FreePlayDrumKits.DEFAULT or not FreePlayDrumKits.PadHasKit(p, p2) then
		return nil
	end

	local layers = v[p][p2].Layers
	local v4 = tonumber(p3)
	return layers[math.clamp(v4 and v4 == v4 and math.floor(v4 + 0.5) or 1, 1, #layers)].Sound
end

function FreePlayDrumKits.GetBundleAssets(p, p2)
	local sounds = {}

	if FreePlayDrumKits.PadHasKit(p, p2) and p ~= FreePlayDrumKits.DEFAULT then
		for _, layer in ipairs(v[p][p2].Layers) do
			table.insert(sounds, layer.Sound)
		end
	end

	return sounds
end

function FreePlayDrumKits.BundleKey(p, p2)
	return tostring(p) .. ":" .. tostring(p2)
end

function FreePlayDrumKits.ParseBundleKey(value)
	if type(value) ~= "string" then
		return nil
	end

	local v4, v5 = string.match(value, "^(%w+):(%w+)$")

	if v4 and v5 and FreePlayDrumKits.PadHasKit(v4, v5) then
		return v4, v5
	end

	return nil
end

function FreePlayDrumKits.SanitizeSelection(p)
	if type(p) ~= "table" then
		return nil
	end

	local v4 = {}
	local v5 = false

	for _, v6 in ipairs(FreePlayDrumKits.PADS) do
		local v7 = p[v6]

		if type(v7) ~= "table" then
			continue
		end

		local kit = v7.Kit

		if not (type(kit) == "string" and kit ~= FreePlayDrumKits.DEFAULT and FreePlayDrumKits.PadHasKit(kit, v6)) then
			continue
		end

		local layerCount = FreePlayDrumKits.GetLayerCount(kit, v6)

		local velocity = v7.Velocity
		v4[v6] = {
			Kit = kit,
			Velocity = (type(velocity) ~= "number" or velocity ~= velocity or velocity == 1e999 or velocity == -1e999) and 1 or math.clamp(math.floor(velocity + 0.5), 1, layerCount)
		}
		v5 = true
	end

	return v5 and v4 or nil
end

function FreePlayDrumKits.SelectionKit(p, p2)
	local v4 = type(p) == "table" and p[p2] or nil

	if type(v4) == "table" and type(v4.Kit) == "string" then
		return v4.Kit
	end

	return FreePlayDrumKits.DEFAULT
end

FreePlayDrumKits.MIX = {
	VOLUME_DEFAULT = 100,
	VOLUME_MIN = 0,
	VOLUME_MAX = 300,
	VOLUME_STEP = 10,
	REVERB_DEFAULT = 20,
	REVERB_MIN = 0,
	REVERB_MAX = 100,
	REVERB_STEP = 5,
	BASS_DEFAULT = 0,
	BASS_MIN = -6,
	BASS_MAX = 6,
	BASS_STEP = 1
}

local function snapMix(value, p, min, max, p2) -- 6 equivalent calls inferred from this helper
	if type(value) == "number" and value == value and value ~= 1e999 and value ~= -1e999 then
		return (math.clamp(math.round(value / p2) * p2, min, max))
	end

	return p
end

function FreePlayDrumKits.SanitizeMix(p)
	if type(p) ~= "table" then
		return nil
	end

	local mix = FreePlayDrumKits.MIX
	local v4 = {}
	local v5 = false

	for _, v6 in ipairs(FreePlayDrumKits.PADS) do
		local v7 = p[v6]

		if type(v7) ~= "table" then
			continue
		end

		local volume = snapMix(v7.Volume, mix.VOLUME_DEFAULT, mix.VOLUME_MIN, mix.VOLUME_MAX, mix.VOLUME_STEP) -- inferred equivalent call
		local reverb = snapMix(v7.Reverb, mix.REVERB_DEFAULT, mix.REVERB_MIN, mix.REVERB_MAX, mix.REVERB_STEP) -- inferred equivalent call
		local bass = snapMix(v7.Bass, mix.BASS_DEFAULT, mix.BASS_MIN, mix.BASS_MAX, mix.BASS_STEP) -- inferred equivalent call

		if not (volume ~= mix.VOLUME_DEFAULT or reverb ~= mix.REVERB_DEFAULT or bass ~= mix.BASS_DEFAULT) then
			continue
		end

		v4[v6] = { Volume = volume, Reverb = reverb, Bass = bass }
		v5 = true
	end

	return v5 and v4 or nil
end

function FreePlayDrumKits.SanitizeMixFull(p)
	local mix = FreePlayDrumKits.MIX
	local result = {}

	for _, v4 in ipairs(FreePlayDrumKits.PADS) do
		local v5

		if type(p) == "table" then
			v5 = p[v4] or nil
		end

		local VOLUME_DEFAULT = mix.VOLUME_DEFAULT
		local REVERB_DEFAULT = mix.REVERB_DEFAULT
		local BASS_DEFAULT = mix.BASS_DEFAULT

		if type(v5) == "table" then
			local volume = v5.Volume
			VOLUME_DEFAULT = mix.VOLUME_DEFAULT
			VOLUME_DEFAULT = snapMix(volume, VOLUME_DEFAULT, mix.VOLUME_MIN, mix.VOLUME_MAX, mix.VOLUME_STEP) -- inferred equivalent call
			local reverb = v5.Reverb
			REVERB_DEFAULT = mix.REVERB_DEFAULT
			REVERB_DEFAULT = snapMix(reverb, REVERB_DEFAULT, mix.REVERB_MIN, mix.REVERB_MAX, mix.REVERB_STEP) -- inferred equivalent call
			local bass = v5.Bass
			BASS_DEFAULT = mix.BASS_DEFAULT
			BASS_DEFAULT = snapMix(bass, BASS_DEFAULT, mix.BASS_MIN, mix.BASS_MAX, mix.BASS_STEP) -- inferred equivalent call
		end

		result[v4] = { Volume = VOLUME_DEFAULT, Reverb = REVERB_DEFAULT, Bass = BASS_DEFAULT }
	end

	return result
end

function FreePlayDrumKits.GetMixValues(p, p2)
	local v4 = type(p) == "table" and p[p2] or nil

	if type(v4) == "table" then
		return
			v4.Volume or FreePlayDrumKits.MIX.VOLUME_DEFAULT,
			v4.Reverb or FreePlayDrumKits.MIX.REVERB_DEFAULT,
			v4.Bass or FreePlayDrumKits.MIX.BASS_DEFAULT
	end

	return FreePlayDrumKits.MIX.VOLUME_DEFAULT, FreePlayDrumKits.MIX.REVERB_DEFAULT, FreePlayDrumKits.MIX.BASS_DEFAULT
end

FreePlayDrumKits.HUMANIZE = { DEFAULT = 50, MIN = 0, MAX = 100, STEP = 10 }

function FreePlayDrumKits.SanitizeHumanize(value)
	local humanize = FreePlayDrumKits.HUMANIZE

	if type(value) ~= "number" or value ~= value or value == 1e999 or value == -1e999 then
		return nil
	end

	local v4 = math.clamp(math.round(value / humanize.STEP) * humanize.STEP, humanize.MIN, humanize.MAX)
	return if v4 ~= humanize.DEFAULT then v4 else nil
end

function FreePlayDrumKits.GetVolume(p, p2)
	local v4 = v2[p]
	local v5 = v4 and v4[p2]

	if type(v5) == "number" and v5 == v5 then
		return (math.clamp(v5, 0, 4))
	end

	return 1
end

function FreePlayDrumKits.GetTail(p, p2)
	local v4 = v3[p]

	if v4 == nil then
		return nil
	end

	return v4[p2]
end

return FreePlayDrumKits