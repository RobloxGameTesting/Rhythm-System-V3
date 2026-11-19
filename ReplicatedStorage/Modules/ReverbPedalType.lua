local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local ReverbPedalType = {
	CurrentVersion = 1,
	DefaultParameters = { Decay = 0.25, Mix = 0.15, Damping = 0.5 },
	ParameterRanges = {
		Decay = { 0, 1 },
		Mix = { 0, 1 },
		Damping = { 0, 1 }
	},
	EffectClassName = "ReverbSoundEffect",
	PrimaryIntensityParam = "Mix",
	ApplyParameters = function(p, data)
		p.Density = data.Decay
		p.Diffusion = 1 - data.Damping
		p.WetLevel = -80 + data.Mix * 80
		p.DryLevel = 0
	end
}

PedalNodeTypeRegistry.Register("Reverb", ReverbPedalType)

return ReverbPedalType