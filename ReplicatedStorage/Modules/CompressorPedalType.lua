local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local CompressorPedalType = {
	CurrentVersion = 1,
	DefaultParameters = { Threshold = 0.5, Ratio = 0.3, Level = 0.5 },
	ParameterRanges = {
		Threshold = { 0, 1 },
		Ratio = { 0, 1 },
		Level = { 0, 1 }
	},
	EffectClassName = "CompressorSoundEffect",
	ApplyParameters = function(p, data)
		p.Threshold = -60 + data.Threshold * 60
		p.Ratio = 1 + data.Ratio * 19
		p.GainMakeup = data.Level * 20
	end
}

PedalNodeTypeRegistry.Register("Compressor", CompressorPedalType)

return CompressorPedalType