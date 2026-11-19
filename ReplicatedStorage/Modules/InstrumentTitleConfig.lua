local InstrumentTitleConfig = {}

InstrumentTitleConfig.Roles = {
	GuitarLead = { Title = "Guitarist", Color = "7EC8E3" },
	GuitarRhythm = { Title = "Guitarist", Color = "3B82F6" },
	Bass = { Title = "Bassist", Color = "A855F7" },
	Drum = { Title = "Drummer", Color = "FF7A1A" },
	Keyboard = { Title = "Keyboardist", Color = "22D3EE" },
	Piano = { Title = "Pianist", Color = "F5F0E6" }
}

InstrumentTitleConfig.VocalistRole = { Title = "Vocalist", Color = "FF4757" }

function InstrumentTitleConfig.GetRole(p)
	return InstrumentTitleConfig.Roles[p]
end

return InstrumentTitleConfig