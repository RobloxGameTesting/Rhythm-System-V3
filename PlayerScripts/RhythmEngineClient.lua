local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
require(ReplicatedStorage.Modules.StarPowerSongConfig)
local ChartLoader = require(ReplicatedStorage.Modules.ChartLoader)
local ChartUnavailableNotice = require(ReplicatedStorage.Modules.ChartUnavailableNotice)
local HitDetector = require(ReplicatedStorage.Modules.HitDetector)
local NoteLaneUI = require(ReplicatedStorage.Modules.NoteLaneUI)
local NoteLaneUI3D = require(ReplicatedStorage.Modules.NoteLaneUI3D)
local ThemeState = require(ReplicatedStorage.Modules.ThemeState)
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
require(ReplicatedStorage.Modules.LaneModeConverter)
local DrumLayoutBuilder = require(ReplicatedStorage.Modules.DrumLayoutBuilder)
local StarPowerUI = require(ReplicatedStorage.Modules.StarPowerUI)
local StarPowerReadyFx = require(ReplicatedStorage.Modules.StarPowerReadyFx)
local LiveStatsHUD = require(ReplicatedStorage.Modules.LiveStatsHUD)
local ScreenShake = require(ReplicatedStorage.Modules.ScreenShake)
local VignetteEffect = require(ReplicatedStorage.Modules.VignetteEffect)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local MovementConflictGuard = require(ReplicatedStorage.Modules.MovementConflictGuard)
local InputRouter = require(ReplicatedStorage.Modules.InputRouter)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)
local LocalPerformanceSignal = require(ReplicatedStorage.Modules.LocalPerformanceSignal)
local InstrumentLifecycleSignal = require(ReplicatedStorage.Modules.InstrumentLifecycleSignal)
local JudgmentScoreConfig = require(ReplicatedStorage.Modules.JudgmentScoreConfig)
local DrumAnimator = require(ReplicatedStorage.Modules.DrumAnimator)
local ThemeSwitchToast = require(ReplicatedStorage.Modules.ThemeSwitchToast)
local NewbieModeState = require(ReplicatedStorage.Modules.NewbieModeState)
local NewbieModifierPipeline = require(ReplicatedStorage.Modules.NewbieModifierPipeline)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")
local SongSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate")
local KeyModeUpdate = RemoteEvents:WaitForChild("KeyModeUpdate")
local DrumPreferenceUpdate = RemoteEvents:WaitForChild("DrumPreferenceUpdate")
local ReportRhythmJudgment = RemoteEvents:WaitForChild("ReportRhythmJudgment")
local SetAutoPlayMode = RemoteEvents:WaitForChild("SetAutoPlayMode")
local ReportLiveChartInfo = RemoteEvents:WaitForChild("ReportLiveChartInfo")
local ReportStarPowerActivation = RemoteEvents:WaitForChild("ReportStarPowerActivation")
local ReportStarPowerEnd = RemoteEvents:WaitForChild("ReportStarPowerEnd")
local BroadcastStarPowerBand = RemoteEvents:WaitForChild("BroadcastStarPowerBand")
local ReportStreakNotice = RemoteEvents:WaitForChild("ReportStreakNotice")

local SongTrulyFinished = RemoteEvents:WaitForChild("SongTrulyFinished")
local ReportFinalStats = RemoteEvents:WaitForChild("ReportFinalStats")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PerformanceEvent = Remotes:WaitForChild("PerformanceEvent")
local InstrumentLifecycleEvent = Remotes:WaitForChild("InstrumentLifecycleEvent")

local LocalPlayer = Players.LocalPlayer

local color = Color3.fromRGB(150, 30, 25)

local function getRenderer() -- 2 equivalent calls inferred from this helper
	return if ThemeState.Get() == "3D" then NoteLaneUI3D else NoteLaneUI
end

local instrumentType = nil
local v = nil

local v2 = false
local v3 = nil

local v4 = nil
local v5 = 0
local now = nil

local v6 = 5
local v7 = { DoublePedalEnabled = false, FlipEnabled = false }

local v8 = nil
local v9 = nil
local v10 = nil
local v11 = NoteLaneUI

local v12 = nil
local getAmpElapsed

local v13 = 0
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = {}
local v18 = {}
local v19 = {}

local count = 0
local total = 0
local maxCombo = 0

local wasAutoPlayed = false

local v20 = false

local count2 = 0
local count3 = 0
local total2 = 0
local count4 = 0

local total3 = 0
local v21 = nil

local v22 = { LastAt = -1000000000, MinGap = 0.4 }

local v23 = nil

local v24 = 0
local flag = false
local count5 = 0
local v25 = 0
local v26 = 0
local v27 = 0
local lastTime = 0
local heartbeatConnection = nil
local v28 = 1

local v29 = 0
local total4 = 0

local function getStarPowerMultiplier() -- 2 equivalent calls inferred from this helper
	if flag then
		return RhythmEngineConfig.StarPowerScoreMultiplier * (v29 + 1)
	end

	return 1
end

local function isAutoStarPowerEnabled(): boolean
	local success, result = pcall(function()
		return SettingsState.GetAutoStarPower()
	end)
	return not success or result == nil or result ~= false
end

local v30 = nil

local StarPowerSkillWindowSize = RhythmEngineConfig.StarPowerSkillWindowSize
local v31 = {}
local v32 = 0
local v36 = 0
local v37 = 0
local v38 = 0.5

local v39 = { GuitarLead = true, GuitarRhythm = true, Bass = true }

local v40 = {
	Drum = function(p, p2, list)
		local reactionTypes

		if list then
			reactionTypes = {}

			for _, item in ipairs(list) do
				table.insert(reactionTypes, item.ReactionType)
			end
		end

		return {
			ResolvedHand = DrumAnimator.ResolveHandForReaction(p, p2.ReactionType, reactionTypes)
		}
	end
}

local function firePerformanceEventFor(eventType, p, judgmentQuality, p2)
	local noteData = { ChartLane = p.ChartLane, ReactionType = p.ReactionType }

	local v42 = v40[instrumentType]

	if v42 then
		local character = LocalPlayer.Character

		if character then
			local v43 = v42(character, p, p2)

			for k, v44 in pairs(v43) do
				noteData[k] = v44
			end
		end
	end

	local v43 = {
		InstrumentType = instrumentType,
		EventType = eventType,
		JudgmentQuality = judgmentQuality,
		NoteData = noteData
	}

	PerformanceEvent:FireServer(v43)
	LocalPerformanceSignal:Fire(v43)
end

local function firePerformanceEvent(eventType, p, judgmentQuality)
	if not instrumentType then
		return
	end

	local representedNotes = p.RepresentedNotes

	if not representedNotes or #representedNotes == 0 then
		return
	end

	if v39[instrumentType] then
		firePerformanceEventFor(eventType, representedNotes[1], judgmentQuality)
		return
	end

	for _, representedNote in ipairs(representedNotes) do
		firePerformanceEventFor(eventType, representedNote, judgmentQuality, representedNotes)
	end
end

local function pushRollingJudgment(p) -- 1 equivalent call inferred from this helper
	v32 = v32 % StarPowerSkillWindowSize + 1

	if v31[v32] then
		v37 -= v31[v32]
	else
		v36 = math.min(v36 + 1, StarPowerSkillWindowSize)
	end

	v31[v32] = p
	v37 += p
end

local function refreshSkillFraction() -- 2 equivalent calls inferred from this helper
	v38 = math.clamp(
		(v36 > 0 and v37 / v36 or 0.5) + math.clamp(
			count / RhythmEngineConfig.StarPowerComboBonusDivisor,
			0,
			RhythmEngineConfig.StarPowerComboBonusMax
		),
		0,
		1
	)
end

local function resetSkillTracking() -- 2 equivalent calls inferred from this helper
	v31 = {}
	v32 = 0
	v36 = 0
	v37 = 0
	v38 = 0.5
end

local v41 = { Plan = nil, LastAt = -1000000000, SpShown = false, SpAt = -1000000000 }

local function resetStreakNotice() -- 2 equivalent calls inferred from this helper
	v41.Plan = nil
	v41.LastAt = -1000000000
	v41.SpShown = false
	v41.SpAt = -1000000000
end

local v42 = false
local lastTime2 = -1e999
local function setReadyZone(p)
	if p == v42 then
		return
	end

	v42 = p
	StarPowerReadyFx.SetZone(p, v11.GetReceptorPoints)

	if p then
		if not v20 and os.clock() - lastTime2 >= 1.5 and v11.ShowStreakNotice then
			v11.ShowStreakNotice("StarPowerPrompt")
		end
	else
		lastTime2 = os.clock()

		if v11.DismissStreakNotice then
			v11.DismissStreakNotice("StarPowerPrompt")
		end
	end
end

local function noteStarPowerReady()
	local v43 = v24 / RhythmEngineConfig.StarPowerMax
	local l3 = RhythmEngineConfig.StarPowerThresholds.L3
	setReadyZone(not flag and l3 - (v42 and 0.02 or 1e-6) <= v43)

	if v42 and v11.SetStarPowerPromptCharge then
		local v44 = math.clamp((v43 - l3) / math.max(1e-6, 1 - l3), 0, 1)
		StarPowerReadyFx.SetIntensity(v44)
		local setStarPowerPromptCharge = v11.SetStarPowerPromptCharge
		local success, result = pcall(function()
			return SettingsState.GetAutoStarPower()
		end)

		setStarPowerPromptCharge(v44, not success or result == nil or result ~= false)
	end
end

local function noteStreakMilestone()
	local v43 = v41
	local plan = v43.Plan

	if not plan then
		local total5 = math.max(0, (v8 and #v8 or 0) - total3)
		local v46 = v3 and SongConfig.Songs[v3]
		local duration = v46 and v46.Duration or 0
		local v47 = duration > 0 and total5 > 0 and total5 / duration or 3
		plan = {
			Total = total5,
			Enabled = total5 >= 80,
			Step = math.max(100, math.ceil(v47 * 16 / 100) * 100)
		}

		v43.Plan = plan
	end

	if
		not plan.Enabled
		or count ~= 50 and (not (count >= plan.Step) or count % plan.Step ~= 0)
		or plan.Total - count3 < 12
	then
		return
	end

	local now2 = os.clock()

	if now2 - v43.LastAt < 8 then
		return
	end

	v43.LastAt = now2

	if v11.ShowStreakNotice then
		v11.ShowStreakNotice("Streak", count)
	end

	ReportStreakNotice:FireServer("Streak", count)

	if count >= 600 then
		ScreenShake.Add(ScreenShake.INTENSITY_LIGHT)
	end
end

local function addStarPowerGain(p) -- 4 equivalent calls inferred from this helper
	if flag then
		if p > 0 then
			v25 = math.min(1, v25 + p * RhythmEngineConfig.StarPowerActiveGainFactor / RhythmEngineConfig.StarPowerMax)
		end
	else
		if p ~= 0 then
			v24 = math.clamp(v24 + p, 0, RhythmEngineConfig.StarPowerMax)
		end

		StarPowerUI.SetMeter(v24 / RhythmEngineConfig.StarPowerMax, v38)
		noteStarPowerReady()
	end
end

local function applyJudgment(p, p2, p3, p4)
	if p3 then
		wasAutoPlayed = true
	end

	pushRollingJudgment(RhythmEngineConfig.StarPowerJudgmentWeight[p] or 0) -- inferred equivalent call

	if p == "Miss" then
		count = 0
		ScreenShake.Add(ScreenShake.INTENSITY_MEDIUM)
		VignetteEffect.Flash(color)
		refreshSkillFraction() -- inferred equivalent call
		addStarPowerGain((RhythmEngineConfig.StarPowerGainWeight.Miss or 0) * v28) -- inferred equivalent call
	else
		local comboMultiplier = RhythmEngineConfig.GetComboMultiplier(count)
		count += 1

		if maxCombo < count then
			maxCombo = count
		end

		local v43 = JudgmentScoreConfig[p]
		local starPowerMultiplier = getStarPowerMultiplier() -- inferred equivalent call
		local v44 = v43 * comboMultiplier
		local v45 = v44 * starPowerMultiplier

		if starPowerMultiplier ~= 1 then
			v45 = math.floor(v45 + 0.5)
			total4 += v45 - v44
		end

		total += v45
		refreshSkillFraction() -- inferred equivalent call
		addStarPowerGain((RhythmEngineConfig.StarPowerGainWeight[p] or 0) * v28) -- inferred equivalent call

		if not (p3 or v20) then
			noteStreakMilestone()
		end
	end

	if v11.SetScoreState then
		v11.SetScoreState(total, count)
	end

	if not p4 then
		v11.ShowJudgment(p2, p, p3, count)
	end

	count3 += 1
	total2 += JudgmentScoreConfig[p] or 0

	if p ~= "Miss" then
		count2 += 1
	end

	local v43 = count3 > 0 and total2 / count3 or 0
	LiveStatsHUD.SetStats(count2, math.max(0, (v8 and #v8 or 0) - total3), count4, v43)
	LiveStatsHUD.NotifyJudgment(p, p3 or p4)

	if instrumentType then
		ReportRhythmJudgment:FireServer(instrumentType, p, p3)
	end
end

local function applyHoldBonus()
	local starPowerMultiplier = getStarPowerMultiplier() -- inferred equivalent call
	local comboMultiplier = RhythmEngineConfig.GetComboMultiplier(count)
	local v43 = RhythmEngineConfig.HoldBonusScore * comboMultiplier
	local v44 = v43 * starPowerMultiplier

	if starPowerMultiplier ~= 1 then
		v44 = math.floor(v44 + 0.5)
		total4 += v44 - v43
	end

	total += v44

	if v11 and v11.SetScoreState then
		v11.SetScoreState(total, count)
	end

	addStarPowerGain(RhythmEngineConfig.StarPowerHoldBonusWeight * v28) -- inferred equivalent call
end

local function computeStarPowerGainScale(_, value, duration)
	local v43 = RhythmEngineConfig
	value = value or 0
	local v44

	if duration == nil then
		v44 = false
	else
		v44 = duration > 0
	end

	local v45 = v43.StarPowerFullTimeMin

	if v44 then
		v45 = math.clamp(duration * v43.StarPowerFullTimeFraction, v43.StarPowerFullTimeMin, v43.StarPowerFullTimeMax)
	end

	local v46 = math.clamp(
		(v44 and value > 0 and value / duration or v43.StarPowerAssumedNoteDensity) * v45,
		v43.StarPowerMinNotesForFill,
		v43.StarPowerMaxNotesForFill
	)

	if value > 0 then
		v46 = math.min(v46, (math.max(1, value * v43.StarPowerMaxNoteFraction)))
	end

	return v43.StarPowerMax / (v46 * v43.StarPowerAssumedAverageWeight)
end

local function computeStarPowerLevel(p): number -- 1 equivalent call inferred from this helper
	local starPowerThresholds = RhythmEngineConfig.StarPowerThresholds

	if starPowerThresholds.L3 - 1e-6 <= p then
		return 3
	end

	if starPowerThresholds.L2 - 1e-6 <= p then
		return 2
	end

	return if starPowerThresholds.L1 - 1e-6 <= p then 1 else 0
end

local function stopStarPowerDrain() -- 5 equivalent calls inferred from this helper
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function reportStarPowerEnd() -- 3 equivalent calls inferred from this helper
	if instrumentType then
		ReportStarPowerEnd:FireServer(math.max(0, os.clock() - lastTime), total4)
	end
end

local function deactivateStarPower(p)
	if p ~= count5 then
		return
	end

	stopStarPowerDrain() -- inferred equivalent call
	reportStarPowerEnd() -- inferred equivalent call
	flag = false
	v25 = 0
	v24 = 0
	v29 = 0
	total4 = 0
	v41.SpShown = false
	ScreenShake.Add(ScreenShake.INTENSITY_LIGHT)

	if v11.PlayStarPowerEndShake then
		v11.PlayStarPowerEndShake()
	end

	StarPowerUI.SetMeter(0, v38)

	if v11.SetStarPowerAtmosphere then
		v11.SetStarPowerAtmosphere(false)
	end

	if v11.SetStarPowerVisual then
		v11.SetStarPowerVisual(false)
	end
end

local function startStarPowerDrain(p) -- 1 equivalent call inferred from this helper
	stopStarPowerDrain() -- inferred equivalent call
	local v43 = os.clock()
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if p == count5 then
			local now2 = os.clock()
			local v44 = math.clamp(now2 - v43, 0, 0.5)
			v43 = now2
			v25 = math.max(0, v25 - v44 / RhythmEngineConfig.StarPowerDuration)
			StarPowerUI.SetActiveResource(v25)

			if v25 <= 0 or now2 - lastTime >= RhythmEngineConfig.StarPowerMaxActiveSeconds then
				deactivateStarPower(p)
			end
		else
			stopStarPowerDrain() -- inferred equivalent call
		end
	end)
end

local function isNoteWindowActiveForStarPower(p): boolean
	for _, v43 in ipairs(v18) do
		if v43.Start <= p and p < v43.End then
			return false
		end
	end

	if not v8 or #v8 == 0 then
		return false
	end

	local v43 = 0

	for _, v44 in ipairs(v8) do
		local v45 = v44.Time + math.max(v44.Duration or 0, 0.05)

		if v43 < v45 then
			v43 = v45
		end
	end

	return not (v43 <= p)
end

local function tryActivateStarPower(p)
	if flag or not v12 then
		return
	end

	if isNoteWindowActiveForStarPower(getAmpElapsed()) then
		local v43 = v24 / RhythmEngineConfig.StarPowerMax
		local starPowerLevel = computeStarPowerLevel(v43) -- inferred equivalent call

		if starPowerLevel < 1 then
			return
		end

		v26 = starPowerLevel
		v27 = v43
		v25 = v43
		v24 = 0
		flag = true
		v29 = 0
		total4 = 0
		lastTime = os.clock()

		count5 += 1
		local v45 = count5

		ScreenShake.Add(ScreenShake.INTENSITY_MEDIUM)

		if v11.PlayStarPowerShake then
			v11.PlayStarPowerShake()
		end

		StarPowerUI.PlayActivationEffect(starPowerLevel)

		if v11.ShatterStreakNotice then
			v11.ShatterStreakNotice("StarPowerPrompt")
		elseif v11.DismissStreakNotice then
			v11.DismissStreakNotice("StarPowerPrompt")
		end

		if v42 ~= false then
			v42 = false
			StarPowerReadyFx.SetZone(false, v11.GetReceptorPoints)

			lastTime2 = os.clock()

			if v11.DismissStreakNotice then
				v11.DismissStreakNotice("StarPowerPrompt")
			end
		end

		StarPowerReadyFx.ActivationRumble()

		if v11.SetStarPowerAtmosphere then
			v11.SetStarPowerAtmosphere(true)
		end

		if v11.SetStarPowerVisual then
			v11.SetStarPowerVisual(true)
		end

		StarPowerUI.SetActiveResource(v25)
		startStarPowerDrain(v45) -- inferred equivalent call

		if instrumentType then
			ReportStarPowerActivation:FireServer(starPowerLevel, v3)
		end
	elseif not p then
		StarPowerUI.ShowActivationDenied("NO NOTES — WAIT")
	end
end

BroadcastStarPowerBand.OnClientEvent:Connect(function(value)
	if typeof(value) ~= "number" or value ~= value then
		return
	end

	local v43 = math.clamp(value, 0, RhythmEngineConfig.StarPowerBandBonusMax)

	if not flag then
		v29 = 0
		return
	end

	local v44 = v29 + 1e-6 < v43
	v29 = v43

	if v44 and v11.ShowStreakNotice then
		v11.ShowStreakNotice("BandBonus", (math.floor(v43 * 100 + 0.5)))
	end
end)

StarPowerUI.OnTapped(function()
	tryActivateStarPower(false)
end)

local function findAmpSound(instance, p, p2) -- 2 equivalent calls inferred from this helper
	if not instance then
		return nil
	end

	local soundAnchor = instance:FindFirstChild("SoundAnchor")
	local value = soundAnchor and soundAnchor.Value

	if value then
		return value:FindFirstChild(p .. "_" .. p2)
	end

	return nil
end

local v43 = 0
local v44 = nil
local v45 = nil
local v46 = 0
local v47 = 0
local v48 = false

getAmpElapsed = function()
	if not (v12 and v12.Parent) and v and v3 and instrumentType then
		v12 = findAmpSound(v, v3, instrumentType) -- inferred equivalent call
	end

	if not v12 then
		return 0
	end

	local segmentOffset = v12.Parent and v12.Parent:GetAttribute("SegmentOffset") or 0
	local v49 = segmentOffset + v12.TimePosition + v13 + SettingsState.GetAudioOffsetMs() / 1000

	local v50 = v3 and SongConfig.Songs[v3]
	local segments = v50 and v50.Segments

	if not (segments and instrumentType and segments[instrumentType]) then
		return v49
	end

	local now2 = os.clock()

	if v45 ~= nil and now2 - v46 > 1 then
		v45 = nil
		v44 = nil
		v48 = false
	end

	if v45 ~= nil and (segmentOffset ~= v43 or v44 ~= nil and v44 ~= v12) then
		v47 = now2 + 3
	end

	v43 = segmentOffset
	v44 = v12
	local v51

	if v45 == nil or not (now2 < v47 or v48) then
		v48 = false
		v51 = v49
	else
		local v52 = now2 - v46
		local v53 = v45 + v52
		local v54 = v49 - v53

		if math.abs(v54) <= 0.5 then
			local v55 = 0.35 * v52
			v51 = v53 + math.clamp(v54, -v55, v55)
			v48 = math.abs(v49 - v51) > 0.005
		else
			v48 = false
			v51 = v49
		end
	end

	v45 = v51
	v46 = now2
	return v51
end

local function getSyncOffset(p, p2) -- 1 equivalent call inferred from this helper
	local song = SongConfig.Songs[p]

	if song then
		return (song.Offset or 0) + (song.InstrumentOffsets and song.InstrumentOffsets[p2] or 0)
	end

	return 0
end

local function getEffectiveDrumConfig() -- 1 equivalent call inferred from this helper
	local clone = table.clone(RhythmEngineConfig)
	clone.DoublePedalKeyNormal = SettingsState.GetDoublePedalKeyNormal()
	clone.DoublePedalKeyFlipped = SettingsState.GetDoublePedalKeyFlipped()
	return clone
end

local function computeBreakPeriods(list, duration, breakGapThreshold)
	if #list == 0 or not duration then
		return {}
	end

	local v49 = {}

	for _, item in ipairs(list) do
		table.insert(v49, {
			Start = item.Time,
			End = item.Time + math.max(item.Duration or 0, 0.05)
		})
	end

	table.sort(v49, function(a, b): boolean
		return a.Start < b.Start
	end)

	local v50 = {}

	for _, v51 in ipairs(v49) do
		local v52 = v50[#v50]

		if v52 and v51.Start <= v52.End then
			v52.End = math.max(v52.End, v51.End)
		else
			table.insert(v50, { Start = v51.Start, End = v51.End })
		end
	end

	local result = {}

	if breakGapThreshold <= v50[1].Start then
		table.insert(result, { Start = 0, End = v50[1].Start })
	end

	for i = 1, #v50 - 1 do
		local start2 = v50[i].End
		local start = v50[i + 1].Start

		if breakGapThreshold <= start - start2 then
			table.insert(result, { Start = start2, End = start })
		end
	end

	return result
end

local function isTimeInBreakPeriod(ampElapsed): boolean -- 1 equivalent call inferred from this helper
	for _, v49 in ipairs(v18) do
		if v49.Start <= ampElapsed and ampElapsed < v49.End then
			return true
		end
	end

	return false
end

local v49 = nil
local v50 = -1
local v51 = nil
local v52 = 0

local function getChartEndTime()
	local v53 = v8

	if not v53 or #v53 == 0 then
		return nil
	end

	if v49 == v53 and v50 == #v53 then
		return v51
	end

	local v54 = 0

	for _, v55 in ipairs(v53) do
		local v56 = v55.Time + math.max(v55.Duration or 0, 0.05)

		if v54 < v56 then
			v54 = v56
		end
	end

	local v55 = #v53
	v49 = v53
	v50 = v55
	v51 = v54

	return v51
end

local function pressLane(p, p2)
	local v53

	if p2 == true then
		v53 = v20 or nil
	end

	if not v19[p] then
		v19[p] = true
		v11.SetLanePressed(p, true)
		ScreenShake.Add(ScreenShake.INTENSITY_LIGHT)
	end

	if v14 or not (v8 and v12) or v17[p] then
		return
	end

	local ampElapsed = getAmpElapsed()
	local closestNote, v54 = HitDetector.FindClosestNote(v8, p, ampElapsed)

	if closestNote then
		local v55 = v8[closestNote]
		local judgment = HitDetector.GetJudgment(v54)

		if not judgment then
			return
		end

		if judgment == "Miss" or not (v55.Duration > 0) then
			v55._judged = true
			applyJudgment(judgment, p, v53)

			if judgment ~= "Miss" then
				firePerformanceEvent("Hit", v55, judgment)
			end
		else
			v55._holding = true
			v17[p] = v55
			applyJudgment(judgment, p, v53)
			firePerformanceEvent("HoldStart", v55, judgment)
		end

		if v55._followers then
			local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
			TouchChart.OnJudged(
				v55,
				judgment,
				{ apply = applyJudgment, perf = firePerformanceEvent, holdBonus = applyHoldBonus },
				v53
			)
		end
	else
		if isTimeInBreakPeriod(ampElapsed) then -- inferred equivalent call
			return
		end

		local chartEndTime = getChartEndTime()

		if chartEndTime and chartEndTime <= ampElapsed then
			local now2 = os.clock()

			if instrumentType and now2 - v52 >= 0.08 then
				v52 = now2
				ReportRhythmJudgment:FireServer(instrumentType, "WrongSound")
			end
		else
			v11.ShowJudgment(p, "Wrong")

			if RhythmEngineConfig.ComboBreakOnWrong and count > 0 then
				count = 0

				if v11.SetScoreState then
					v11.SetScoreState(total, count)
				end
			end

			ScreenShake.Add(ScreenShake.INTENSITY_MEDIUM)
			pcall(function()
				local HapticFx = require(ReplicatedStorage.Modules.HapticFx)
				HapticFx.Play("Wrong")
			end)
			addStarPowerGain((RhythmEngineConfig.StarPowerGainWeight.Wrong or 0) * v28) -- inferred equivalent call

			count4 += 1
			local v55 = count3 > 0 and total2 / count3 or 0
			LiveStatsHUD.SetStats(count2, math.max(0, (v8 and #v8 or 0) - total3), count4, v55)

			if instrumentType then
				ReportRhythmJudgment:FireServer(instrumentType, "Wrong")
			end
		end
	end
end

local function releaseLane(p)
	if v19[p] then
		v19[p] = nil
		v11.SetLanePressed(p, false)
	end

	if v14 or not (v8 and v12) then
		return
	end

	local v53 = v17[p]

	if not v53 then
		return
	end

	v17[p] = nil
	v53._holding = false
	v53._judged = true

	firePerformanceEvent("HoldEnd", v53, nil)

	local ampElapsed = getAmpElapsed()
	local isHoldReleaseValid = HitDetector.IsHoldReleaseValid(v53, ampElapsed)

	if isHoldReleaseValid then
		applyHoldBonus()
	end

	if v53._followers then
		local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
		TouchChart.OnHoldReleased(v53, isHoldReleaseValid, {
			perf = firePerformanceEvent,
			holdBonus = applyHoldBonus
		})
	end
end

NoteLaneUI.OnLanePressed(pressLane)
NoteLaneUI.OnLaneReleased(releaseLane)

if NoteLaneUI3D.OnLanePressed then
	NoteLaneUI3D.OnLanePressed(pressLane)
end

if NoteLaneUI3D.OnLaneReleased then
	NoteLaneUI3D.OnLaneReleased(releaseLane)
end

local count6 = 0

local function startAutoPlayLoop() -- 2 equivalent calls inferred from this helper
	count6 += 1
	local v53 = count6

	task.spawn(function()
		while v20 and count6 == v53 do
			if v8 and v12 then
				local ampElapsed = getAmpElapsed()

				for _, v54 in ipairs(v8) do
					if v54._holding and v54.Duration and v54.Duration > 0 then
						if v54.Time + v54.Duration <= ampElapsed then
							releaseLane(v54.Lane)
						end
					elseif
						not v54._judged
						and not v54._holding
						and v54.Time <= ampElapsed
						and ampElapsed - v54.Time <= RhythmEngineConfig.MissWindow
					then
						pressLane(v54.Lane, true)

						if not (v54.Duration and v54.Duration > 0) then
							releaseLane(v54.Lane)
						end
					end
				end
			end

			task.wait()
		end
	end)
end

SetAutoPlayMode.OnClientEvent:Connect(function(p)
	if p == true and v8 then
		v20 = true
		startAutoPlayLoop() -- inferred equivalent call
	else
		v20 = false
		count6 += 1
	end
end)

local function computeInstrumentLayout(p, p2)
	local chartNotes = ChartLoader.GetChart(p2, p)

	if #chartNotes == 0 then
		return nil
	end

	local v54 = RhythmEngineConfig.LaneCount[p]

	local v55 = NewbieModeState.IsEnabled() and NewbieModeState.GetConfig() or nil
	local v56

	if RhythmEngineConfig.TwoKeyEligible[p] and v6 < v54 then
		v56 = v6
	end

	local laneCount3 = math.min(v55 and v55.LaneCount or v56 or v54, v54)

	local v58 = {
		NoteDensity = v55 and v55.NoteDensity or 0,
		PatternComplexity = v55 and v55.PatternComplexity or 0,
		LaneCount = laneCount3
	}

	local v59 = laneCount3 ~= v54 or v58.NoteDensity > 0 or v58.PatternComplexity > 0

	local function bindingsAndNamesFor(p3)
		if p3 == 2 then
			return SettingsState.GetKeybindTwoKey(), RhythmEngineConfig.TwoKeyLaneNames
		end

		return
			SettingsState.IsControllerMode() and SettingsState.GetKeybindFirstN(p3) or RhythmEngineConfig.GetNewbieKeybinds(p3),
			RhythmEngineConfig.NewbieLaneNames[p3]
	end

	local laneCount = nil
	local laneNames = nil
	local laneColors = nil
	local bindings

	if p == "Drum" then
		if laneCount3 == v54 then
			if v58.NoteDensity > 0 or v58.PatternComplexity > 0 then
				chartNotes = NewbieModifierPipeline.Apply(p2, chartNotes, v58, "Drum", v54).Notes
			end

			local v62 = DrumLayoutBuilder.Build(
				chartNotes,
				v7.DoublePedalEnabled,
				v7.FlipEnabled,
				getEffectiveDrumConfig(), -- inferred equivalent call
				SettingsState.GetKeybindFiveKey()
			)

			chartNotes = v62.Notes
			laneCount = v62.LaneCount
			bindings = v62.KeyBindings
			laneNames = v62.LaneNames
			laneColors = v62.LaneColors
		else
			local v62 = NewbieModifierPipeline.Apply(p2, chartNotes, v58, "Drum", v54)
			chartNotes = v62.Notes
			laneCount = v62.LaneCount
			local laneCount2 = v62.LaneCount

			if laneCount2 == 2 then
				bindings = SettingsState.GetKeybindTwoKey()
				laneNames = RhythmEngineConfig.TwoKeyLaneNames
			else
				bindings = SettingsState.IsControllerMode() and SettingsState.GetKeybindFirstN(laneCount2)
					or RhythmEngineConfig.GetNewbieKeybinds(laneCount2)
				laneNames = RhythmEngineConfig.NewbieLaneNames[laneCount2]
			end
		end
	elseif v59 then
		local v62 = NewbieModifierPipeline.Apply(p2, chartNotes, v58, p, v54)
		chartNotes = v62.Notes

		if laneCount3 == v54 then
			bindings = SettingsState.GetKeybindFiveKey()
		else
			laneCount = v62.LaneCount
			local laneCount2 = v62.LaneCount

			if laneCount2 == 2 then
				bindings = SettingsState.GetKeybindTwoKey()
				laneNames = RhythmEngineConfig.TwoKeyLaneNames
			else
				bindings = SettingsState.IsControllerMode() and SettingsState.GetKeybindFirstN(laneCount2)
					or RhythmEngineConfig.GetNewbieKeybinds(laneCount2)
				laneNames = RhythmEngineConfig.NewbieLaneNames[laneCount2]
			end
		end
	else
		bindings = SettingsState.GetKeybindFiveKey()
	end

	v4 = {
		Lanes = laneCount or v54,
		Custom = laneCount3 ~= v54
	}

	return {
		ChartNotes = chartNotes,
		LaneCount = laneCount,
		Bindings = bindings,
		LaneNames = laneNames,
		LaneColors = laneColors
	}
end

local function refreshMovementLock()
	if v2 and v9 then
		local clone = table.clone(v9)

		if
			instrumentType == "Drum"
			and (not RhythmEngineConfig.TwoKeyEligible.Drum or v6 ~= 2)
			and v7.DoublePedalEnabled
		then
			table.insert(
				clone,
				v7.FlipEnabled and SettingsState.GetDoublePedalKeyFlipped() or SettingsState.GetDoublePedalKeyNormal()
			)
		end

		if instrumentType then
			local FreePlayAutoMuteConfig = require(ReplicatedStorage.Modules.FreePlayAutoMuteConfig)

			if FreePlayAutoMuteConfig.IsAutoMuteInstrument(instrumentType) then
				table.insert(clone, SettingsState.GetVibratoKeyRhythm())
			end
		end

		table.insert(clone, SettingsState.GetStarPowerKey())
		table.insert(clone, SettingsState.StarPowerAltKey)

		local setLockedKeys = MovementConflictGuard.SetLockedKeys
		local MovementLockState = require(ReplicatedStorage.Modules.MovementLockState)
		setLockedKeys(MovementLockState.Resolve(clone))
	else
		MovementConflictGuard.UnlockAll()

		local MovementLockState = require(ReplicatedStorage.Modules.MovementLockState)
		MovementLockState.Resolve(nil)
	end
end

local MovementLockState = require(ReplicatedStorage.Modules.MovementLockState)
MovementLockState.OnEnabledChanged(refreshMovementLock)

local function liveRefreshBindingsFromSettings()
	if not (v2 and v8 and instrumentType and v3) then
		return
	end

	local v53 = computeInstrumentLayout(instrumentType, v3)

	if not v53 or (not v53.ChartNotes or #v53.ChartNotes ~= #v8) then
		return
	end

	for i, chartNote in ipairs(v53.ChartNotes) do
		v8[i].Lane = chartNote.Lane

		if chartNote.RepresentedNotes then
			v8[i].RepresentedNotes = chartNote.RepresentedNotes
		end
	end

	local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
	TouchChart.Apply(v8)

	v9 = v53.Bindings
	v10 = v53.LaneCount
	InputRouter.SetActiveBindings(v9)

	v11.Show(instrumentType, v53.LaneCount, v53.Bindings, v53.LaneNames, v53.LaneColors)

	refreshMovementLock()
end

SettingsState.OnChanged(liveRefreshBindingsFromSettings)

SettingsState.OnChanged(function()
	if v8 then
		local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
		TouchChart.Refresh(v8)
	end
end)

local function swapRendererLive()
	if not (v2 and v8 and instrumentType and v3) then
		return
	end

	local renderer = getRenderer() -- inferred equivalent call

	if renderer == v11 then
		return
	end

	local set = {}

	for k in pairs(v19) do
		set[k] = true
	end

	v11.Hide()
	v11 = renderer

	local v53 = computeInstrumentLayout(instrumentType, v3)

	if not v53 then
		return
	end

	v9 = v53.Bindings
	v10 = v53.LaneCount
	InputRouter.SetActiveBindings(v9)

	if v11.SetSongProfile then
		v11.SetSongProfile(SongConfig.Songs[v3])
	end

	if v11.SetKickBeats then
		v11.SetKickBeats(v15 and v15.Kicks or nil)
	end

	v11.Show(instrumentType, v53.LaneCount, v53.Bindings, v53.LaneNames, v53.LaneColors)

	for k in pairs(set) do
		v11.SetLanePressed(k, true)
	end

	if flag then
		if v11.SetStarPowerAtmosphere then
			v11.SetStarPowerAtmosphere(true)
		end

		if v11.SetStarPowerVisual then
			v11.SetStarPowerVisual(true)
		end
	end

	local v54 = v11.GetTrackWidth and v11.GetTrackWidth(v10) or nil
	local v55 = v11.GetTrackHeight and v11.GetTrackHeight() or nil
	local v56 = v11.GetTrackRightEdgeX and v11.GetTrackRightEdgeX() or nil
	local v57 = v11.GetTrackCenterY and v11.GetTrackCenterY() or nil
	StarPowerUI.Show(v54, v55, RhythmEngineConfig.StarPowerThresholds, v56, v57)

	if flag then
		StarPowerUI.SetActiveResource(v25)
	else
		StarPowerUI.SetMeter(v24 / RhythmEngineConfig.StarPowerMax, v38)
	end

	task.defer(function()
		if not (v11.GetTrackRightEdgeX or v11.GetTrackCenterY) then
			return
		end

		local v58 = v11.GetTrackRightEdgeX and v11.GetTrackRightEdgeX() or nil
		local v59 = v11.GetTrackCenterY and v11.GetTrackCenterY() or nil

		if v58 and v58 > 0 or v59 and v59 > 0 then
			StarPowerUI.Show(v54, v55, RhythmEngineConfig.StarPowerThresholds, v58, v59)
		end
	end)

	refreshMovementLock()
end

local themeSwitchToastGui = nil
local v53 = nil

local function ensureThemeSwitchToast() -- 3 equivalent calls inferred from this helper
	if v53 then
		return
	end

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	themeSwitchToastGui = Instance.new("ScreenGui")
	themeSwitchToastGui.Name = "ThemeSwitchToastGui"
	themeSwitchToastGui.ResetOnSpawn = false
	themeSwitchToastGui.IgnoreGuiInset = true
	themeSwitchToastGui.DisplayOrder = 50
	themeSwitchToastGui.Parent = playerGui

	v53 = ThemeSwitchToast.new(themeSwitchToastGui)
end

ThemeState.OnChanged(function(p)
	ensureThemeSwitchToast() -- inferred equivalent call
	v53:Show(string.format("Switched to %s Highways", p))
	swapRendererLive()
end)

local function setHighwayVisibleForMode(p)
	if not (v2 and v8) then
		return
	end

	if p == ModeManager.FreePlay then
		v11.Hide()
	else
		liveRefreshBindingsFromSettings()
	end
end

ModeManager.OnChanged(setHighwayVisibleForMode)

local function releaseAllPressedVisual()
	for k in pairs(v19) do
		v11.SetLanePressed(k, false)
	end

	v19 = {}
end

local function stopEngine()
	ChartUnavailableNotice.Hide()

	v20 = false
	count6 += 1
	MovementConflictGuard.UnlockAll()
	local MovementLockState2 = require(ReplicatedStorage.Modules.MovementLockState)
	MovementLockState2.Resolve(nil)

	v13 = 0
	v14 = nil
	v8 = nil
	v9 = nil
	v10 = nil
	InputRouter.ClearActiveBindings()
	v12 = nil
	v17 = {}
	v18 = {}
	releaseAllPressedVisual()
	count = 0
	total = 0
	maxCombo = 0

	count2 = 0
	count3 = 0
	total2 = 0
	count4 = 0
	total3 = 0
	v21 = nil
	LiveStatsHUD.Hide()

	if flag then
		reportStarPowerEnd() -- inferred equivalent call
	end

	if v42 ~= false then
		v42 = false
		StarPowerReadyFx.SetZone(false, v11.GetReceptorPoints)

		lastTime2 = os.clock()

		if v11.DismissStreakNotice then
			v11.DismissStreakNotice("StarPowerPrompt")
		end
	end

	stopStarPowerDrain() -- inferred equivalent call
	v24 = 0
	flag = false
	v25 = 0
	v26 = 0
	v29 = 0
	total4 = 0
	count5 += 1
	resetSkillTracking() -- inferred equivalent call
	resetStreakNotice() -- inferred equivalent call
	v30 = nil
	StarPowerUI.SetMeter(0, v38)
	StarPowerUI.Hide()
	v11.Hide()
end

local function buildCountdownBeats(p)
	if not p then
		return nil
	end

	local times = {}

	for _, v54 in ipairs(ChartLoader.GetChart(p, "Drum")) do
		if v54.Lane == 1 and typeof(v54.Time) == "number" then
			times[#times + 1] = v54.Time
		end
	end

	table.sort(times)

	return { Kicks = times }
end

local function startEngine()
	if not (v2 and v3 and instrumentType) then
		return
	end

	ChartUnavailableNotice.Hide()

	local ColorsPreview = require(ReplicatedStorage.Modules.ColorsPreview)
	ColorsPreview.Stop()

	v11.Hide()
	v11 = getRenderer() -- inferred equivalent call
	local now2 = os.clock()
	local v54 = computeInstrumentLayout(instrumentType, v3)
	local now3 = os.clock()

	if v54 then
		local chartNotes = v54.ChartNotes

		local laneCount = v54.LaneCount
		local bindings = v54.Bindings
		local laneNames = v54.LaneNames
		local laneColors = v54.LaneColors

		v9 = bindings or RhythmEngineConfig.KeyBindings[instrumentType]
		v10 = laneCount or RhythmEngineConfig.LaneCount[instrumentType]
		InputRouter.SetActiveBindings(v9)

		v15 = buildCountdownBeats(v3)

		if v11.SetKickBeats then
			v11.SetKickBeats(v15 and v15.Kicks or nil)
		end

		v8 = table.create(#chartNotes)

		for i, chartNote in ipairs(chartNotes) do
			v8[i] = {
				Lane = chartNote.Lane,
				Time = chartNote.Time,
				Duration = chartNote.Duration or 0,
				RepresentedNotes = chartNote.RepresentedNotes or {
					{ ChartLane = chartNote.Lane, ReactionType = chartNote.ReactionType }
				},
				_judged = false,
				_holding = false
			}
		end

		local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
		TouchChart.Apply(v8)

		count2 = 0
		count3 = 0
		total2 = 0
		count4 = 0
		total3 = 0
		v21 = nil
		LiveStatsHUD.SetStats(0, #v8, 0, 0)
		LiveStatsHUD.Show()

		local firstNoteTime = 1e999
		local child = ReplicatedStorage.Modules.ChartData:FindFirstChild(v3)

		if child then
			local success, result = pcall(require, child)

			if success and typeof(result) == "table" then
				for _, v56 in pairs(result) do
					if typeof(v56) ~= "table" then
						continue
					end

					for _, v57 in ipairs(v56) do
						if not (typeof(v57) == "table" and typeof(v57.Time) == "number" and v57.Time < firstNoteTime) then
							continue
						end

						firstNoteTime = v57.Time
					end
				end
			end
		end

		local song = SongConfig.Songs[v3]
		local bpm = song and song.BPM
		local drum = song and song.DefaultVolumes and song.DefaultVolumes.Drum or 1

		if firstNoteTime < 1e999 and bpm and bpm > 0 then
			local v56 = {
				InstrumentType = instrumentType,
				Lifecycle = "ClickSchedule",
				BPM = bpm,
				FirstNoteTime = firstNoteTime,
				PreRollRemaining = math.max(0, v5 - (os.clock() - (now or os.clock()))),
				Volume = drum
			}

			InstrumentLifecycleSignal:Fire(v56)
			InstrumentLifecycleEvent:FireServer(v56)
		end

		v17 = {}
		v19 = {}

		local duration = SongConfig.Songs[v3] and SongConfig.Songs[v3].Duration
		v13 = getSyncOffset(v3, instrumentType) -- inferred equivalent call
		v18 = computeBreakPeriods(v8, duration, RhythmEngineConfig.BreakGapThreshold)

		v28 = computeStarPowerGainScale(v3, #chartNotes, duration)

		if v5 and v5 > 0 then
			local v56 = (now or os.clock()) + v5

			if os.clock() < v56 then
				v14 = v56
				v16 = v5
				pcall(function()
					local HapticFx = require(ReplicatedStorage.Modules.HapticFx)
					HapticFx.Play("Countdown")
				end)
			else
				v14 = nil
			end
		else
			v14 = nil
		end

		if v11.SetSongProfile then
			v11.SetSongProfile(SongConfig.Songs[v3])
		end

		local v56 = not v14 and 0 or math.max(0, v14 - os.clock() - 4)

		local now4 = os.clock()
		v11.Show(instrumentType, laneCount, bindings, laneNames, laneColors, v56)
		local now5 = os.clock()
		refreshMovementLock()

		local v57 = v11.GetTrackWidth and v11.GetTrackWidth(v10) or nil
		local v58 = v11.GetTrackHeight and v11.GetTrackHeight() or nil
		local v59 = v11.GetTrackRightEdgeX and v11.GetTrackRightEdgeX() or nil
		local v60 = v11.GetTrackCenterY and v11.GetTrackCenterY() or nil
		StarPowerUI.Show(v57, v58, RhythmEngineConfig.StarPowerThresholds, v59, v60)
		StarPowerUI.SetMeter(0, 0.5)

		task.defer(function()
			if not (v11.GetTrackRightEdgeX or v11.GetTrackCenterY) then
				return
			end

			local v61 = v11.GetTrackRightEdgeX and v11.GetTrackRightEdgeX() or nil
			local v62 = v11.GetTrackCenterY and v11.GetTrackCenterY() or nil

			if v61 and v61 > 0 or v62 and v62 > 0 then
				StarPowerUI.Show(v57, v58, RhythmEngineConfig.StarPowerThresholds, v61, v62)
			end
		end)

		count = 0
		total = 0
		maxCombo = 0

		if v11 and v11.SetScoreState then
			v11.SetScoreState(0, 0)
		end

		wasAutoPlayed = false

		v20 = false
		count6 += 1

		if LocalPlayer:GetAttribute("AdminAutoPlay") == true then
			v20 = true
			startAutoPlayLoop() -- inferred equivalent call
		end

		if flag then
			reportStarPowerEnd() -- inferred equivalent call
		end

		if v42 ~= false then
			v42 = false
			StarPowerReadyFx.SetZone(false, v11.GetReceptorPoints)

			lastTime2 = os.clock()

			if v11.DismissStreakNotice then
				v11.DismissStreakNotice("StarPowerPrompt")
			end
		end

		stopStarPowerDrain() -- inferred equivalent call
		v24 = 0
		flag = false
		v25 = 0
		v26 = 0
		v29 = 0
		total4 = 0
		resetSkillTracking() -- inferred equivalent call
		resetStreakNotice() -- inferred equivalent call
		v30 = nil

		local v61 = v3
		local v62 = instrumentType
		local v63 = v
		task.spawn(function()
			local total5 = 0

			while total5 < 3 do
				if v3 ~= v61 or instrumentType ~= v62 then
					return
				end

				v12 = findAmpSound(v63, v61, v62) -- inferred equivalent call

				if v12 then
					return
				end

				task.wait(0.1)
				total5 += 0.1
			end

			warn("[RhythmEngineClient] Sound tidak ditemukan untuk timing:", v61, v62)
		end)

		local now6 = os.clock()
		print(("[RhythmEngineClient] startEngine %s/%s: total %.0f ms (chart+layout %.0f | notes+scan+hitung %.0f | renderer.Show %.0f) | event->selesai %.0f ms | pre-roll tersisa %.2f dtk"):format(
			tostring(v61),
			tostring(v62),
			(now6 - now2) * 1000,
			(now3 - now2) * 1000,
			(now4 - now3) * 1000,
			(now5 - now4) * 1000,
			(now6 - (now or now2)) * 1000,
			v14 and math.max(0, v14 - now6) or 0
		))
	else
		warn("[RhythmEngineClient] Chart kosong untuk:", v3, instrumentType)
		ChartUnavailableNotice.Show()
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if
		v2
		and SettingsState.MatchesStarPowerInput(input)
		and (not gameProcessed or MovementConflictGuard.IsLocked(input.KeyCode) or input.KeyCode == Enum.KeyCode.ButtonSelect)
	then
		local v54 = false

		if v9 and input.KeyCode ~= Enum.KeyCode.Unknown then
			for _, v56 in ipairs(v9) do
				if v56 == input.KeyCode then
					v54 = true
					break
				end
			end
		end

		if not v54 then
			tryActivateStarPower()
		end
	end

	if gameProcessed then
		return
	end

	local leftControl = ModeManager.IsFreePlay() and Enum.KeyCode.LeftControl or Enum.KeyCode.Space

	if input.KeyCode == leftControl and instrumentType == "Drum" and not v2 then
		local v54 = { InstrumentType = instrumentType, Lifecycle = "ManualStickClick" }

		InstrumentLifecycleSignal:Fire(v54)
		InstrumentLifecycleEvent:FireServer(v54)
	end
end)

InputRouter.SetRhythmHandlers({
	Press = function(p)
		pressLane(p)
	end,
	Release = function(p)
		releaseLane(p)
	end
})

local function setReceptorsVisible(p) -- 2 equivalent calls inferred from this helper
	local setReceptorsVisible2 = v11.SetReceptorsVisible

	if setReceptorsVisible2 then
		setReceptorsVisible2(p)
	end
end

local function getReceptorFadeInLead() -- 2 equivalent calls inferred from this helper
	local v54 = NewbieModeState.GetNoteSpeedOverride() or SettingsState.GetNoteSpeedMultiplier()

	local getReceptorAppearDuration = v11.GetReceptorAppearDuration
	local v55 = getReceptorAppearDuration and getReceptorAppearDuration() or 1
	return RhythmEngineConfig.NoteApproachTime / v54 + v55
end

local function shouldShowReceptors(p, p2): boolean
	return not (p and p2) or p.End - p.Start <= 10 or p2 <= getReceptorFadeInLead() -- inferred equivalent call
end

local function fastForwardStaleNotes(ampElapsed)
	local v54 = ampElapsed - RhythmEngineConfig.MissWindow
	local count7 = 0

	for _, v55 in ipairs(v8) do
		if v55._judged or v55._holding or not (v55.Time < v54) then
			continue
		end

		v55._judged = true
		v55._skipped = true
		count7 += 1
	end

	if count7 == 0 then
		return
	end

	total3 += count7
	local v55 = count3 > 0 and total2 / count3 or 0
	LiveStatsHUD.SetStats(count2, math.max(0, #v8 - total3), count4, v55)
	print(("[RhythmEngineClient] Posisi lagu melompat ke %.1f dtk -- %d not lama di-skip tanpa penalti (join tengah lagu / resync)."):format(
		ampElapsed,
		count7
	))
end

RunService.Heartbeat:Connect(function()
	if not v8 then
		return
	end

	if v14 then
		local v54 = v14 - os.clock()

		if v54 > 0 then
			if instrumentType ~= "Drum" then
				v11.ShowCountdown(v54, "PreRoll", v16, -v54, v15)
			end

			setReceptorsVisible(true) -- inferred equivalent call
			v11.SyncNotes(v8, -v54)
			return
		end

		v14 = nil
		v11.HideCountdown()
	end

	local ampElapsed = getAmpElapsed()

	if not v12 then
		return
	end

	local noteWindowActiveForStarPower = isNoteWindowActiveForStarPower(ampElapsed)

	if noteWindowActiveForStarPower ~= v30 then
		v30 = noteWindowActiveForStarPower
		StarPowerUI.SetNoteWindowActive(noteWindowActiveForStarPower)
	end

	if not flag and noteWindowActiveForStarPower then
		local v54 = RhythmEngineConfig.StarPowerMax * RhythmEngineConfig.StarPowerAutoActivateFraction
		local v55 = v24

		if v54 - 1e-6 <= v55 then
			local success, result = pcall(function()
				return SettingsState.GetAutoStarPower()
			end)

			if not success or result == nil or result ~= false then
				tryActivateStarPower(true)
			end
		end
	end

	if ampElapsed - (v21 or 0) > 1 then
		fastForwardStaleNotes(ampElapsed)
	end

	v21 = ampElapsed

	local isFreePlay = ModeManager.IsFreePlay()
	local total5 = 0

	for _, v54 in ipairs(v8) do
		if v54._hidden then
			if not v54._judged and ampElapsed - v54.Time > RhythmEngineConfig.MissWindow + 0.3 then
				v54._judged = true
				v54._skipped = true
				total3 += 1
			end
		elseif not v54._judged and not v54._holding and ampElapsed - v54.Time > RhythmEngineConfig.MissWindow then
			v54._judged = true

			if isFreePlay then
				v54._skipped = true
				total5 += 1

				if v54._followers then
					local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
					total5 += TouchChart.OnSkipped(v54)
				end
			else
				applyJudgment("Miss", v54.Lane)

				if v54._followers then
					local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
					TouchChart.OnJudged(v54, "Miss", {
						apply = applyJudgment,
						perf = firePerformanceEvent,
						holdBonus = applyHoldBonus
					})
				end
			end
		end
	end

	if total5 > 0 then
		total3 += total5
		local v54 = count3 > 0 and total2 / count3 or 0
		LiveStatsHUD.SetStats(count2, math.max(0, #v8 - total3), count4, v54)
		local now2 = os.clock()

		if instrumentType and now2 - v22.LastAt >= v22.MinGap then
			v22.LastAt = now2
			ReportRhythmJudgment:FireServer(instrumentType, "FreePlay")
		end
	end

	v11.SyncNotes(v8, ampElapsed)
	local v54 = nil
	local v55 = nil

	for _, v57 in ipairs(v18) do
		if v57.Start <= ampElapsed and ampElapsed < v57.End then
			v55 = v57.End - ampElapsed
			v54 = v57
			break
		end
	end

	setReceptorsVisible(not (v54 and v55) or v54.End - v54.Start <= 10 or v55 <= getReceptorFadeInLead()) -- inferred equivalent call
	local v58

	if v54 == nil then
		v58 = false
	else
		v58 = v54.Start > 0.001
	end

	if LocalPlayer:GetAttribute("PianoInBreak") ~= v58 then
		LocalPlayer:SetAttribute("PianoInBreak", v58)
	end

	if v55 then
		v11.ShowCountdown(v55, v54.Start <= 0.001 and "Intro" or "Break", v54.End - v54.Start, ampElapsed, v15)
	else
		v11.HideCountdown()
	end
end)

InstrumentHUDUpdate.OnClientEvent:Connect(function(p, p2, p3)
	local instrumentType2 = instrumentType

	instrumentType = p and p2 or nil
	v = p and p3 or nil

	if not p then
		if instrumentType2 and v2 then
			local v55 = { InstrumentType = instrumentType2, Lifecycle = "SessionEnd" }

			InstrumentLifecycleSignal:Fire(v55)
			InstrumentLifecycleEvent:FireServer(v55)
		end

		v2 = false
		stopEngine()
	end
end)

local function computeDifficultyTier(): string -- 2 equivalent calls inferred from this helper
	local config = NewbieModeState.GetConfig()
	local noteDensity = config.NoteDensity or 0
	local patternComplexity = config.PatternComplexity or 0

	if noteDensity <= 0 and patternComplexity <= 0 then
		return "Normal"
	end

	local midpoint = (noteDensity + patternComplexity) / 2

	if midpoint >= 8 then
		return "Baby"
	end

	return if midpoint >= 5 then "Easy" else "Medium"
end

local v54 = {}

local function recordDifficultyEvent(p)
	local v55 = math.max(0, tonumber(p) or 0)
	local tier = computeDifficultyTier() -- inferred equivalent call
	local lanes = v4 and v4.Lanes or nil
	local custom

	if v4 == nil then
		custom = false
	else
		custom = v4.Custom == true
	end

	local v58 = v54[#v54]

	local function sameAsNew(data): boolean -- 2 equivalent calls inferred from this helper
		return data ~= nil and data.tier == tier and data.lanes == lanes and data.custom == custom
	end

	if sameAsNew(v58) then -- inferred equivalent call
		return
	end

	if not (v58 and v55 - v58.t < 1) then
		table.insert(v54, { t = v55, tier = tier, lanes = lanes, custom = custom })
		return
	end

	v58.tier = tier
	v58.lanes = lanes
	v58.custom = custom

	if sameAsNew(v54[#v54 - 1]) then -- inferred equivalent call
		table.remove(v54)
	end
end

local function reportLiveChartInfo(ampElapsed) -- 2 equivalent calls inferred from this helper
	local v55 = math.max(0, (v8 and #v8 or 0) - total3)
	local difficultyTier = computeDifficultyTier() -- inferred equivalent call
	local lanes = v4 and v4.Lanes or nil
	ReportLiveChartInfo:FireServer(v55, difficultyTier, lanes, (math.max(0, tonumber(ampElapsed) or 0)))
end

SongSessionStatusUpdate.OnClientEvent:Connect(function(p, songName, value)
	local v55 = p and (not v2 or v3 ~= songName)

	if not p then
		local v56 = {
			Score = total,
			MaxCombo = maxCombo,
			SongName = songName,
			InstrumentType = instrumentType,
			TotalNotes = math.max(0, (v8 and #v8 or 0) - total3),
			WasAutoPlayed = wasAutoPlayed,
			AllNotesPassed = 0,
			DifficultyTimelineJson = 0
		}
		local allNotesPassed

		if v8 and #v8 ~= 0 then
			local flag2 = true

			for _, v58 in ipairs(v8) do
				if not (v58._judged or v58._holding) then
					allNotesPassed = false
					flag2 = false
					break
				end
			end

			if flag2 then
				allNotesPassed = true
			end
		else
			allNotesPassed = false
		end

		v56.AllNotesPassed = allNotesPassed

		local v58 = {}
		local v59 = false

		for _, v60 in ipairs(v54) do
			v59 = (v60.tier ~= "Normal" or v60.custom) and true or v59

			table.insert(v58, { t = v60.t, tier = v60.tier, lanes = v60.lanes })
		end

		local difficultyTimelineJson

		if v59 then
			local success, result = pcall(HttpService.JSONEncode, HttpService, v58)
			difficultyTimelineJson = success and result or nil
		end

		v56.DifficultyTimelineJson = difficultyTimelineJson
		v23 = v56
	end

	v2 = p
	v3 = p and songName or nil
	v5 = value or 0
	now = os.clock()

	if instrumentType then
		local v56 = {
			InstrumentType = instrumentType,
			Lifecycle = p and "SessionStart" or "SessionEnd",
			SongName = p and songName or nil
		}

		InstrumentLifecycleSignal:Fire(v56)
		InstrumentLifecycleEvent:FireServer(v56)
	end

	if not p then
		stopEngine()

		return
	end

	if v55 then
		v54 = {}
		recordDifficultyEvent(0)
	end

	if v55 and ModeManager.IsFreePlay() then
		ModeManager.SetRhythm()
	end

	startEngine()

	if v55 then
		recordDifficultyEvent(0)
	end

	reportLiveChartInfo(0) -- inferred equivalent call
end)

SongTrulyFinished.OnClientEvent:Connect(function(p)
	if not v23 then
		return
	end

	if p and p.SongName and p.SongName ~= v23.SongName then
		v23 = nil
		return
	end

	if p and p.Early == true and not v23.AllNotesPassed then
		v23 = nil
		return
	end

	ReportFinalStats:FireServer(
		v23.Score,
		v23.MaxCombo,
		v23.TotalNotes,
		v23.WasAutoPlayed,
		v23.DifficultyTimelineJson,
		v23.AllNotesPassed
	)
	v23 = nil
end)

local function swapNoteLayoutLive()
	if not (v2 and v8 and instrumentType and v3) then
		return
	end

	local v55 = computeInstrumentLayout(instrumentType, v3)

	if not (v55 and v55.ChartNotes) then
		return
	end

	local ampElapsed = getAmpElapsed()
	local v56 = v9

	local v57 = {}

	for _, v58 in ipairs(v8) do
		if v58._judged or v58.Time <= ampElapsed then
			table.insert(v57, v58)
		end
	end

	for _, chartNote in ipairs(v55.ChartNotes) do
		if ampElapsed < chartNote.Time then
			table.insert(v57, {
				Lane = chartNote.Lane,
				Time = chartNote.Time,
				Duration = chartNote.Duration or 0,
				RepresentedNotes = chartNote.RepresentedNotes or {
					{ ChartLane = chartNote.Lane, ReactionType = chartNote.ReactionType }
				},
				_judged = false,
				_holding = false
			})
		end
	end

	table.sort(v57, function(a, b): boolean
		return a.Time < b.Time
	end)

	v8 = v57

	local TouchChart = require(ReplicatedStorage.Modules.TouchChart)
	TouchChart.Apply(v8)

	local clone = table.clone(v55.Bindings)

	if v56 then
		for _, v58 in ipairs(v57) do
			if not v58._holding or not v56[v58.Lane] or clone[v58.Lane] then
				continue
			end

			clone[v58.Lane] = v56[v58.Lane]
		end
	end

	v9 = clone
	v10 = v55.LaneCount
	InputRouter.SetActiveBindings(v9)

	v11.Show(instrumentType, v55.LaneCount, v9, v55.LaneNames, v55.LaneColors)

	local duration = SongConfig.Songs[v3] and SongConfig.Songs[v3].Duration
	v18 = computeBreakPeriods(v8, duration, RhythmEngineConfig.BreakGapThreshold)
	v28 = computeStarPowerGainScale(v3, #v8, duration)

	local v58 = count3 > 0 and total2 / count3 or 0
	LiveStatsHUD.SetStats(count2, math.max(0, #v8 - total3), count4, v58)

	refreshMovementLock()

	recordDifficultyEvent(ampElapsed)
	reportLiveChartInfo(ampElapsed) -- inferred equivalent call
end

NewbieModeState.OnStructuralChanged(function()
	if v2 then
		recordDifficultyEvent(getAmpElapsed())
		swapNoteLayoutLive()
	end
end)

NewbieModeState.OnApplyRequested(function()
	if v2 then
		swapNoteLayoutLive()
	end
end)

KeyModeUpdate.OnClientEvent:Connect(function(p)
	v6 = p

	if v2 then
		swapNoteLayoutLive()
	end

	ensureThemeSwitchToast() -- inferred equivalent call
	local v55 = instrumentType and RhythmEngineConfig.LaneCount[instrumentType]

	if v55 then
		p = math.min(p, v55)
	end

	v53:Show(string.format("Switched to %d-Key Mode", p))
end)

DrumPreferenceUpdate.OnClientEvent:Connect(function(p)
	local v55 = v7
	v7 = p

	liveRefreshBindingsFromSettings()
	ensureThemeSwitchToast() -- inferred equivalent call

	if v55.DoublePedalEnabled ~= p.DoublePedalEnabled then
		v53:Show(p.DoublePedalEnabled and "Double Pedal Enabled" or "Double Pedal Disabled")
	elseif v55.FlipEnabled ~= p.FlipEnabled then
		v53:Show(p.FlipEnabled and "Left-Handed Mode Enabled" or "Left-Handed Mode Disabled")
	end
end)