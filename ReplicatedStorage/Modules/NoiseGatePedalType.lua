local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local NoiseGatePedalType = {
	CurrentVersion = 1,
	DefaultParameters = { Threshold = 0.1 },
	ParameterRanges = {
		Threshold = { 0, 1 }
	},
	EffectClassName = nil,
	ApplyParameters = nil
}

PedalNodeTypeRegistry.Register("NoiseGate", NoiseGatePedalType)

return NoiseGatePedalType