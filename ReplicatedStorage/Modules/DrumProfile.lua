local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FreePlayProfileRegistry = require(ReplicatedStorage.Modules.FreePlayProfileRegistry)

local v = {
	"HighCrash",
	"Splash",
	"MediumCrash",
	"FootHiHat",
	"FootHiHat",
	"HighTom",
	"HighTom",
	"MidTom",
	"MidTom",
	"RideEdge",
	"RideBell",
	"OpenHiHat",
	"OpenHiHat",
	"Snare",
	"Snare",
	"SideStick",
	"BassDrum",
	"BassDrum",
	"FloorTom",
	"FloorTom",
	"China",
	"Cowbell"
}

local v2 = {}
local DrumProfile = {}

for i, pad in ipairs(v) do
	v2[i] = { Pad = pad, Velocity = 1 }
end

DrumProfile.LaneCount = #v

function DrumProfile.GetLaneAction(_, p)
	return v2[p]
end

FreePlayProfileRegistry.Register("Drum", DrumProfile)

return DrumProfile