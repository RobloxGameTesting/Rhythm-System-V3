local PreviewConfig = {}

PreviewConfig.Defaults = {
	StartOffset = 20,
	Duration = 20,
	Volume = 0.18,
	FadeIn = 0.6,
	FadeOut = 0.3
}

PreviewConfig.Songs = {
	Creep = {
		StartOffset = 123,
		Duration = 25,
		Volume = 0.18,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	Hysteria = {
		StartOffset = 163,
		Duration = 25,
		Volume = 0.06,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["A Miserable"] = {
		StartOffset = 134,
		Duration = 25,
		Volume = 0.1,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["A Little Piece Of Heaven"] = {
		StartOffset = 0,
		Duration = 25,
		Volume = 0.08,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["Canon Rock"] = {
		StartOffset = 105,
		Duration = 25,
		Volume = 0.06,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["Don't Look Back In Anger"] = {
		StartOffset = 3,
		Duration = 25,
		Volume = 0.08,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	Eyeless = {
		StartOffset = 22,
		Duration = 25,
		Volume = 0.05,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	Floods = {
		StartOffset = 370,
		Duration = 25,
		Volume = 0.08,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["Join Me"] = {
		StartOffset = 17,
		Duration = 25,
		Volume = 0.07,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["Please '' Let Me Get What I Want"] = {
		StartOffset = 25,
		Duration = 25,
		Volume = 0.09,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["Pretty Fly (for a White Guy)"] = {
		StartOffset = 15,
		Duration = 25,
		Volume = 0.11,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["Seize The Day"] = {
		StartOffset = 50,
		Duration = 25,
		Volume = 0.1,
		FadeIn = 0.7,
		FadeOut = 0.3
	},
	["Sweet Child O' Mine"] = {
		StartOffset = 16,
		Duration = 25,
		Volume = 0.09,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["Welcome To The Jungle"] = {
		StartOffset = 4,
		Duration = 25,
		Volume = 0.09,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	territorial = {
		StartOffset = 26,
		Duration = 25,
		Volume = 0.06,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	["The Winner Takes It All"] = {
		StartOffset = 0,
		Duration = 16,
		Volume = 0.04,
		FadeIn = 0.6,
		FadeOut = 0.3
	},
	Always = {
		StartOffset = 0,
		Duration = 17,
		Volume = 0.02,
		FadeIn = 0.6,
		FadeOut = 0.3
	}
}

function PreviewConfig.Get(p)
	local v = PreviewConfig.Songs[p] or {}
	local defaults = PreviewConfig.Defaults
	return {
		StartOffset = v.StartOffset or defaults.StartOffset,
		Duration = v.Duration or defaults.Duration,
		Volume = v.Volume or defaults.Volume,
		FadeIn = v.FadeIn or defaults.FadeIn,
		FadeOut = v.FadeOut or defaults.FadeOut
	}
end

return PreviewConfig