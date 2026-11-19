local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaneModeConverter = require(ReplicatedStorage.Modules.LaneModeConverter)
local NoteDensityReducer = require(ReplicatedStorage.Modules.NoteDensityReducer)
local PatternComplexitySimplifier = require(ReplicatedStorage.Modules.PatternComplexitySimplifier)
local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)

local v = {}

local function cloneChartNotes(list)
	local chartNotes = table.create(#list)

	for i, item in ipairs(list) do
		local representedNotes

		if item.RepresentedNotes then
			representedNotes = table.create(#item.RepresentedNotes)

			for j, representedNote in ipairs(item.RepresentedNotes) do
				representedNotes[j] = representedNote
			end
		end

		chartNotes[i] = {
			Lane = item.Lane,
			Time = item.Time,
			Duration = item.Duration,
			ReactionType = item.ReactionType,
			RepresentedNotes = representedNotes
		}
	end

	return chartNotes
end

return {
	Apply = function(p, p2, data, p3, p4)
		local joined = table.concat({
			tostring(p),
			tostring(p3),
			tostring(data.NoteDensity or 0),
			tostring(data.PatternComplexity or 0),
			(tostring(data.LaneCount))
		}, "|")

		local v2 = v[joined]

		if v2 then
			return v2
		end

		local notes = cloneChartNotes(p2)

		if (data.NoteDensity or 0) > 0 then
			notes = NoteDensityReducer.Reduce(notes, data.NoteDensity)
		end

		if (data.PatternComplexity or 0) > 0 then
			notes = PatternComplexitySimplifier.Simplify(notes, data.PatternComplexity)
		end

		local laneCount = data.LaneCount or p4

		if laneCount == p4 then
			laneCount = p4
		else
			local convertToN = LaneModeConverter.ConvertToN(notes, p4, laneCount, p3)
			notes = LaneModeConverter.DedupeOverlaps(
				convertToN,
				RhythmEngineConfig.TwoKeyDedupeMinGapSeconds,
				laneCount
			)
		end

		local v3 = { Notes = notes, LaneCount = laneCount }

		v[joined] = v3
		return v3
	end
}