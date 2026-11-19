local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalboardRegistry = require(ReplicatedStorage.Modules.PedalboardRegistry)

PedalboardRegistry.Register({
	Family = "Bass",
	PreAmpNodes = {
		{ Id = "Compressor", InputFrom = nil },
		{ Id = "BassOverdrive", InputFrom = "Compressor" }
	},
	PostAmpNodes = {
		{ Id = "Chorus", InputFrom = nil }
	}
})

return true