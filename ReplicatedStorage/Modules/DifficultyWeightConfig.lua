local RhythmEngineConfig = require(script.Parent.RhythmEngineConfig)

local DifficultyWeightConfig = {}

DifficultyWeightConfig.TierWeights = { Normal = 1, Medium = 0.9, Easy = 0.75, Baby = 0.55 }
DifficultyWeightConfig.LanePenaltyPerLaneRemoved = 0.04
DifficultyWeightConfig.MinFactor = 0.3

local function segmentFactor(tier, lanes, value) -- 2 equivalent calls inferred from this helper
	local v = DifficultyWeightConfig.TierWeights[tier] or 1
	local v2

	if typeof(lanes) == "number" and typeof(value) == "number" then
		local v3 = math.max(0, value - lanes)
		v2 = 1 - DifficultyWeightConfig.LanePenaltyPerLaneRemoved * v3
	else
		v2 = 1
	end

	return (math.max(DifficultyWeightConfig.MinFactor, v * v2))
end

function DifficultyWeightConfig.Evaluate(list, p, value)
	local v = RhythmEngineConfig.LaneCount[p]

	if typeof(list) ~= "table" or #list == 0 then
		return {
			Factor = 1,
			Tier = "Normal",
			Lanes = v,
			NativeLanes = v,
			Mixed = false
		}
	end

	local t = list[#list].t or 0

	if typeof(value) ~= "number" or not (t < value and value) then
		value = t + 1
	end

	local v2 = {}
	local total = 0
	local total2 = 0
	local v3 = {}

	for i, item in ipairs(list) do
		local v4 = i == 1 and 0 or item.t
		local v5

		if i < #list then
			v5 = list[i + 1].t or value
		else
			v5 = value
		end

		local v6 = math.max(0, v5 - v4)
		local v7 = tostring(item.tier) .. ":" .. tostring(item.lanes)
		local v8 = v2[v7]

		if not v8 then
			v8 = { Tier = item.tier, Lanes = item.lanes, Seconds = 0 }
			v2[v7] = v8
			table.insert(v3, v7)
		end

		v8.Seconds += v6
		total += v6 * segmentFactor(item.tier, item.lanes, v) -- inferred equivalent call
		total2 += v6
	end

	if total2 <= 0 then
		local item = list[1]
		return {
			Factor = math.floor(segmentFactor(item.tier, item.lanes, v) * 1000 + 0.5) / 1000, -- inferred equivalent call
			Tier = item.tier,
			Lanes = item.lanes or v,
			NativeLanes = v,
			Mixed = false
		}
	else
		local v4 = nil
		local count = 0

		for _, v5 in ipairs(v3) do
			local v6 = v2[v5]

			if not v4 or v6.Seconds > v4.Seconds then
				v4 = v6
			end

			if v6.Seconds / total2 >= 0.05 then
				count += 1
			end
		end

		return {
			Factor = math.floor(total / total2 * 1000 + 0.5) / 1000,
			Tier = v4.Tier,
			Lanes = v4.Lanes or v,
			NativeLanes = v,
			Mixed = count > 1
		}
	end
end

DifficultyWeightConfig.RetentionFloorByTier = {
	Normal = 0.9,
	Medium = 0.2,
	Easy = 0.12,
	Baby = 0.12
}

DifficultyWeightConfig.RetentionFloorLaneFactor = { 0.3, 0.5, 0.63, 0.65 }

function DifficultyWeightConfig.MinRetentionFloor(list, p)
	local v = RhythmEngineConfig.LaneCount[p]
	local v2 = (typeof(list) ~= "table" or not (#list > 0 and list)) and {
		{ tier = "Normal" }
	} or list
	local v3 = nil

	for _, v4 in ipairs(v2) do
		local v5 = DifficultyWeightConfig.RetentionFloorByTier[v4.tier]
			or DifficultyWeightConfig.RetentionFloorByTier.Baby
		local v6

		if typeof(v4.lanes) == "number" and typeof(v) == "number" and v4.lanes < v then
			local v7 = math.max(1, (math.floor(v4.lanes)))
			v6 = DifficultyWeightConfig.RetentionFloorLaneFactor[v7]
				or DifficultyWeightConfig.RetentionFloorLaneFactor[4]
		else
			v6 = 1
		end

		local v7 = v5 * v6

		if not v3 or v7 < v3 then
			v3 = v7
		end
	end

	return v3 or DifficultyWeightConfig.RetentionFloorByTier.Normal
end

return DifficultyWeightConfig