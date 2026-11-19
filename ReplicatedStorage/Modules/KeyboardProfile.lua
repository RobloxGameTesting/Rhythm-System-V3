local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FreePlayProfileRegistry = require(ReplicatedStorage.Modules.FreePlayProfileRegistry)

local v = {
	{ Note = "C4", Velocity = 1, Sustain = false },
	{ Note = "C#4", Velocity = 1, Sustain = false },
	{ Note = "D4", Velocity = 1, Sustain = false },
	{ Note = "D#4", Velocity = 1, Sustain = false },
	{ Note = "E4", Velocity = 1, Sustain = false }
}
local KeyboardProfile = {
	GetLaneAction = function(_, p)
		return v[p]
	end
}

FreePlayProfileRegistry.Register("Keyboard", KeyboardProfile)

return KeyboardProfile