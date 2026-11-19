local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FreePlayProfileRegistry = require(ReplicatedStorage.Modules.FreePlayProfileRegistry)

local v = {
	"C",
	"C#",
	"D",
	"D#",
	"E",
	"F",
	"F#",
	"G",
	"G#",
	"A",
	"A#",
	"B"
}

local v2 = {}
local PianoProfile = {}

for i = 1, 61 do
	local v3 = i - 1
	local v4 = math.floor(v3 / 12) + 2
	v2[i] = {
		Note = v[v3 % 12 + 1] .. tostring(v4),
		Velocity = 1,
		Sustain = false
	}
end

PianoProfile.LaneCount = 61

function PianoProfile.GetLaneAction(_, p)
	return v2[p]
end

FreePlayProfileRegistry.Register("Piano", PianoProfile)

return PianoProfile