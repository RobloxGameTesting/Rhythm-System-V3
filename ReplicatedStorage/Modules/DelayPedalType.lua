local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local DelayPedalType = {
	CurrentVersion = 1,
	DefaultParameters = { Time = 300, Feedback = 0.2, Mix = 0 },
	ParameterRanges = {
		Time = { 0, 2000 },
		Feedback = { 0, 0.95 },
		Mix = { 0, 1 }
	},
	EffectClassName = "EchoSoundEffect",
	PrimaryIntensityParam = "Mix",
	ApplyParameters = function(p, data)
		p.Delay = data.Time / 1000
		p.Feedback = data.Feedback
		p.WetLevel = -80 + data.Mix * 80
		p.DryLevel = 0
	end
}

PedalNodeTypeRegistry.Register("Delay", DelayPedalType)

return DelayPedalType