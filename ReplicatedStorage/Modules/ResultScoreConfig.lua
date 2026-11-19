local ResultScoreConfig = {
	MaxScore = 1000000,
	AccuracyWeight = 0.85,
	ComboWeight = 0.15,
	MinChartFraction = 0.2,
	FormulaVersion = 2,
	PresenceBreakGap = 4,
	PresenceRelativeFull = 0.7,
	MinChartWeight = 0.05,
	QualifiedCoverage = 0.9,
	EnforceTimingValidation = false,
	TimingMarginSeconds = 1.5,
	TimingSlackNotes = 8
}

function ResultScoreConfig.ComputePresence(list, value)
	if type(list) ~= "table" or #list < 2 or type(value) ~= "number" or value <= 0 then
		return 0
	end

	local clone = table.clone(list)
	table.sort(clone)
	local total = 0

	for i = 2, #clone do
		local v = clone[i] - clone[i - 1]

		if v <= ResultScoreConfig.PresenceBreakGap then
			total += v
		end
	end

	return (math.clamp(total / value, 0, 1))
end

function ResultScoreConfig.WeightFromPresence(value, value2)
	if type(value) == "number" and type(value2) == "number" and not (value2 <= 0) then
		return (math.clamp(
			value / (ResultScoreConfig.PresenceRelativeFull * value2),
			ResultScoreConfig.MinChartWeight,
			1
		))
	end

	return 1
end

function ResultScoreConfig.Compute(data)
	local v = math.max(0, data.JudgedCount or 0)
	local v2 = math.max(0, data.HitCount or 0)
	local v3

	if type(data.MinExpectedNotes) == "number" then
		v3 = math.floor((math.max(0, data.MinExpectedNotes)))
	else
		v3 = math.floor((data.RawChartNoteCount or 0) * ResultScoreConfig.MinChartFraction)
	end

	local v4 = math.max(data.TotalNotesClaim or 0, v, v3)

	if v4 <= 0 then
		return 0, 0, 0
	end

	local v5 = math.clamp((data.ScoreSum or 0) / (v4 * 100), 0, 1)

	local v6 = math.clamp(math.floor(data.MaxComboClaim or 0), 0, (math.min(v2, v4)))
	local v7 = v6 / v4

	local v8 = ResultScoreConfig.MaxScore * (ResultScoreConfig.AccuracyWeight * v5 + ResultScoreConfig.ComboWeight * v7)
	local v9 = math.clamp(data.ChartWeight or 1, 0, 1)
	local v10 = math.clamp(data.Coverage or 1, 0, 1)
	return math.floor(v8 * (data.DifficultyFactor or 1) * v9 * v10 + 0.5), v6, v4
end

return ResultScoreConfig