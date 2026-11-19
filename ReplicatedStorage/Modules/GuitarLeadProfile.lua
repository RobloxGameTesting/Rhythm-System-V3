local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FreePlayProfileRegistry = require(ReplicatedStorage.Modules.FreePlayProfileRegistry)

local v = {}
local GuitarLeadProfile = {}

for i = 1, 6 do
	for j = 0, 12 do
		v[(i - 1) * 13 + j + 1] = {
			String = i,
			Fret = j,
			Velocity = 1,
			Sustain = false,
			Muted = false,
			Technique = "Pick"
		}
	end
end

function GuitarLeadProfile.GetLaneAction(_, p)
	return v[p]
end

FreePlayProfileRegistry.Register("GuitarLead", GuitarLeadProfile)

return GuitarLeadProfile