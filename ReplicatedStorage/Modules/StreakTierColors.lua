local StreakTierColors = {}
StreakTierColors.StartStreak = 500
local v = { "#FFEB3B", "#167A2F", "#5B1F9E", "#A50F1A", "#000000" }

function StreakTierColors.GetHex(value)
	if typeof(value) ~= "number" or value < StreakTierColors.StartStreak then
		return nil
	end

	if value >= 1000 then
		return "#FFD700"
	end

	return v[math.clamp(math.floor((value - StreakTierColors.StartStreak) / 100) + 1, 1, #v)]
end

function StreakTierColors.GetColor3(p)
	local hex = StreakTierColors.GetHex(p)
	return hex and Color3.fromHex(hex) or nil
end

function StreakTierColors.NeedsBackdrop(value): boolean
	return typeof(value) == "number" and StreakTierColors.StartStreak + 100 <= value and value < 1000
end

return StreakTierColors