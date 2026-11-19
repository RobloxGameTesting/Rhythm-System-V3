local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalboardRegistry = require(ReplicatedStorage.Modules.PedalboardRegistry)

PedalboardRegistry.Register({
	Family = "Guitar",
	PreAmpNodes = {
		{ Id = "NoiseGate", InputFrom = nil },
		{ Id = "Compressor", InputFrom = "NoiseGate" },
		{ Id = "Overdrive", InputFrom = "Compressor" },
		{ Id = "Distortion", InputFrom = "Overdrive" }
	},
	PostAmpNodes = {
		{ Id = "Chorus", InputFrom = nil },
		{ Id = "Delay", InputFrom = "Chorus" },
		{ Id = "Reverb", InputFrom = "Delay" }
	}
})

return true