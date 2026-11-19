local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local BassOverdrivePedalType = {
	CurrentVersion = 1,
	DefaultParameters = { Drive = 0.3, Tone = 0.35, Level = 0.5 },
	ParameterRanges = {
		Drive = { 0, 1 },
		Tone = { 0, 1 },
		Level = { 0, 1 }
	},
	EffectClassName = "DistortionSoundEffect",
	PrimaryIntensityParam = "Drive",
	ApplyParameters = function(p, p2)
		p.Level = p2.Drive * 0.4
	end
}

PedalNodeTypeRegistry.Register("BassOverdrive", BassOverdrivePedalType)

return BassOverdrivePedalType