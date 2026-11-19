local GradeConfig = {}

GradeConfig.Thresholds = {
	{ Grade = "S", MinPercent = 95 },
	{ Grade = "A", MinPercent = 90 },
	{ Grade = "B", MinPercent = 80 },
	{ Grade = "C", MinPercent = 70 },
	{ Grade = "D", MinPercent = 60 },
	{ Grade = "F", MinPercent = 0 }
}

function GradeConfig.GetGrade(p)
	for _, threshold in ipairs(GradeConfig.Thresholds) do
		if threshold.MinPercent <= p then
			return threshold.Grade
		end
	end

	return "F"
end

GradeConfig.BandSPlusMinPercent = 98

function GradeConfig.GetBandGrade(p)
	if GradeConfig.BandSPlusMinPercent <= p then
		return "S+"
	end

	return GradeConfig.GetGrade(p)
end

return GradeConfig