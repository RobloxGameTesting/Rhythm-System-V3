local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local OverdrivePedalType = {
	CurrentVersion = 1,
	DefaultParameters = { Drive = 0.3, Tone = 0.5, Level = 0.5 },
	ParameterRanges = {
		Drive = { 0, 1 },
		Tone = { 0, 1 },
		Level = { 0, 1 }
	},
	EffectClassName = "DistortionSoundEffect",
	PrimaryIntensityParam = "Drive",
	ApplyParameters = function(p, p2)
		p.Level = p2.Drive * 0.5
	end
}

PedalNodeTypeRegistry.Register("Overdrive", OverdrivePedalType)

return OverdrivePedalType