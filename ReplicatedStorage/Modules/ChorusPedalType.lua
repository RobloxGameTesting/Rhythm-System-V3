local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local ChorusPedalType = {
	CurrentVersion = 1,
	DefaultParameters = { Rate = 0.5, Depth = 0.3, Mix = 0.15 },
	ParameterRanges = {
		Rate = { 0, 1 },
		Depth = { 0, 1 },
		Mix = { 0, 1 }
	},
	EffectClassName = "ChorusSoundEffect",
	PrimaryIntensityParam = "Mix",
	ApplyParameters = function(p, data)
		p.Rate = data.Rate * 10
		p.Depth = data.Depth
		p.Mix = data.Mix
	end
}

PedalNodeTypeRegistry.Register("Chorus", ChorusPedalType)

return ChorusPedalType