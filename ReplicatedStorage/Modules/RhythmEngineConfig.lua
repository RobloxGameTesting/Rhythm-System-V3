local RhythmEngineConfig = {}

local v = { Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B, Enum.KeyCode.N }

RhythmEngineConfig.LaneCount = {
	GuitarLead = 5,
	GuitarRhythm = 5,
	Bass = 4,
	Drum = 5,
	Keyboard = 5,
	Piano = 5
}

RhythmEngineConfig.KeyBindings = {
	GuitarLead = v,
	GuitarRhythm = v,
	Bass = { Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B },
	Drum = v,
	Keyboard = v,
	Piano = v
}

RhythmEngineConfig.LaneNames = {
	GuitarLead = { "Green", "Red", "Yellow", "Blue", "Orange" },
	GuitarRhythm = { "Green", "Red", "Yellow", "Blue", "Orange" },
	Bass = { "Green", "Red", "Yellow", "Blue" },
	Keyboard = { "Green", "Red", "Yellow", "Blue", "Orange" },
	Piano = { "Green", "Red", "Yellow", "Blue", "Orange" },
	Drum = { "Kick", "Snare", "Hi-Hat", "Perc", "Cymbal" }
}

RhythmEngineConfig.DoublePedalEligible = { Drum = true }
RhythmEngineConfig.FlipEligible = { Drum = true }

RhythmEngineConfig.DoublePedalKeyNormal = Enum.KeyCode.Z
RhythmEngineConfig.DoublePedalKeyFlipped = Enum.KeyCode.M
RhythmEngineConfig.DoublePedalColor = Color3.fromRGB(25, 24, 22)
RhythmEngineConfig.DoublePedalLaneName = "Double Pedal"

RhythmEngineConfig.DoublePedalMinGapSeconds = 0.25

RhythmEngineConfig.HitWindows = {
	{ Judgment = "Perfect", Seconds = 0.05 },
	{ Judgment = "Great", Seconds = 0.1 },
	{ Judgment = "Good", Seconds = 0.15 },
	{ Judgment = "OK", Seconds = 0.18 }
}

RhythmEngineConfig.MissWindow = 0.2

RhythmEngineConfig.NoteApproachTime = 1.3

RhythmEngineConfig.HoldReleaseTolerance = 0.1

RhythmEngineConfig.BreakGapThreshold = 4

RhythmEngineConfig.TwoKeyEligible = {
	GuitarLead = true,
	GuitarRhythm = true,
	Bass = true,
	Keyboard = true,
	Piano = true,
	Drum = true
}

RhythmEngineConfig.TwoKeyLaneCount = 2

RhythmEngineConfig.TwoKeyBindings = { Enum.KeyCode.X, Enum.KeyCode.C }
RhythmEngineConfig.TwoKeyLaneNames = { "Left", "Right" }

RhythmEngineConfig.TwoKeyDedupeMinGapSeconds = 0.08

RhythmEngineConfig.NewbieLaneKeys = {
	Enum.KeyCode.X,
	Enum.KeyCode.C,
	Enum.KeyCode.V,
	Enum.KeyCode.B,
	Enum.KeyCode.N
}
RhythmEngineConfig.NewbieLaneNames = {
	[3] = { "Left", "Mid", "Right" },
	[4] = { "1", "2", "3", "4" }
}

function RhythmEngineConfig.GetNewbieKeybinds(p)
	local newbieKeybinds = {}

	for i = 1, p do
		newbieKeybinds[i] = RhythmEngineConfig.NewbieLaneKeys[i]
	end

	return newbieKeybinds
end

RhythmEngineConfig.NewbieLaneCountOptions = {
	GuitarLead = { 2, 3, 4, 5 },
	GuitarRhythm = { 2, 3, 4, 5 },
	Bass = { 2, 3, 4 },
	Keyboard = { 2, 3, 4, 5 },
	Piano = { 2, 3, 4, 5 },
	Drum = { 2, 3, 4, 5 }
}

RhythmEngineConfig.HoldBonusScore = 30

RhythmEngineConfig.StarPowerKey = Enum.KeyCode.Space
RhythmEngineConfig.StarPowerMax = 100

RhythmEngineConfig.StarPowerGainWeight = {
	Perfect = 1,
	Great = 0.7,
	Good = 0.4,
	OK = 0.15,
	Miss = -0.6,
	Wrong = -0.6
}

RhythmEngineConfig.StarPowerHoldBonusWeight = 0.3

RhythmEngineConfig.StarPowerTargetFillTimeFraction = 0.5

RhythmEngineConfig.StarPowerFullTimeFraction = 0.3
RhythmEngineConfig.StarPowerFullTimeMin = 35
RhythmEngineConfig.StarPowerFullTimeMax = 70
RhythmEngineConfig.StarPowerMaxNoteFraction = 0.6

RhythmEngineConfig.StarPowerAssumedAverageWeight = 0.75

RhythmEngineConfig.StarPowerMinNotesForFill = 50
RhythmEngineConfig.StarPowerMaxNotesForFill = 450
RhythmEngineConfig.StarPowerAssumedNoteDensity = 2.2

RhythmEngineConfig.StarPowerThresholds = { L1 = 0.33, L2 = 0.6, L3 = 0.9 }

RhythmEngineConfig.StarPowerAutoActivateFraction = 1

RhythmEngineConfig.StarPowerDuration = 24
RhythmEngineConfig.StarPowerActiveGainFactor = 0.5
RhythmEngineConfig.StarPowerMaxActiveSeconds = 60

RhythmEngineConfig.StarPowerBandBonusPerMember = 0.25
RhythmEngineConfig.StarPowerBandBonusMax = 0.75
RhythmEngineConfig.StarPowerScoreMultiplier = 2

RhythmEngineConfig.ComboNotesPerLevel = 10
RhythmEngineConfig.ComboMaxMultiplier = 4
RhythmEngineConfig.ComboBreakOnWrong = true

function RhythmEngineConfig.GetComboMultiplier(value)
	local v2 = math.floor(math.max(0, value or 0) / RhythmEngineConfig.ComboNotesPerLevel)
	return (math.min(RhythmEngineConfig.ComboMaxMultiplier, v2 + 1))
end

RhythmEngineConfig.StarPowerSkillWindowSize = 20
RhythmEngineConfig.StarPowerJudgmentWeight = {
	Perfect = 1,
	Great = 0.75,
	Good = 0.5,
	OK = 0.25,
	Miss = 0
}

RhythmEngineConfig.StarPowerComboBonusMax = 0.1
RhythmEngineConfig.StarPowerComboBonusDivisor = 50

return RhythmEngineConfig