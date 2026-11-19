local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
local HitDetector = {}

function HitDetector.FindClosestNote(list, p, p2)
	local v = 1e999
	local v2 = nil

	for i, item in ipairs(list) do
		if item.Lane ~= p or (item._judged or item._hidden) then
			continue
		end

		local v3 = math.abs(p2 - item.Time)

		if not (v3 <= RhythmEngineConfig.MissWindow and v3 < v) then
			continue
		end

		v2 = i
		v = v3
	end

	return v2, v
end

function HitDetector.GetJudgment(p)
	for _, hitWindow in ipairs(RhythmEngineConfig.HitWindows) do
		if p <= hitWindow.Seconds then
			return hitWindow.Judgment
		end
	end

	return if p <= RhythmEngineConfig.MissWindow then "Miss" else nil
end

function HitDetector.IsHoldReleaseValid(p, p2): boolean
	return p.Time + (p.Duration or 0) - RhythmEngineConfig.HoldReleaseTolerance <= p2
end

return HitDetector