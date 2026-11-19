local InstrumentWrongSounds = {}

InstrumentWrongSounds.Sounds = {
	GuitarLead = {
		"rbxassetid://123003483276894",
		"rbxassetid://113516687460139",
		"rbxassetid://78696453172559",
		"rbxassetid://126786706375230"
	},
	GuitarRhythm = {
		"rbxassetid://126786706375230",
		"rbxassetid://78696453172559",
		"rbxassetid://113516687460139",
		"rbxassetid://123003483276894"
	},
	Bass = {
		"rbxassetid://102501061797066",
		"rbxassetid://140719799373886",
		"rbxassetid://116387432414919",
		"rbxassetid://139388277810407"
	},
	Drum = {
		"rbxassetid://87718915208940",
		"rbxassetid://104063110212538",
		"rbxassetid://110923386781698",
		"rbxassetid://87718915208940"
	},
	Keyboard = {
		"rbxassetid://98603230606019",
		"rbxassetid://118310959265164",
		"rbxassetid://140143714477337",
		"rbxassetid://105808787792608"
	},
	Piano = {
		"rbxassetid://71413988434276",
		"rbxassetid://120283591997950",
		"rbxassetid://109679669446374",
		"rbxassetid://87251899153525"
	}
}

function InstrumentWrongSounds.GetRandomSoundId(p)
	local sound = InstrumentWrongSounds.Sounds[p]

	if sound and #sound ~= 0 then
		return sound[math.random(1, #sound)]
	end

	return nil
end

return InstrumentWrongSounds