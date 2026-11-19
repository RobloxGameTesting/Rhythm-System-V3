local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local AudioRig = require(ReplicatedStorage.Modules.AudioRig)
local PedalChain = require(ReplicatedStorage.Modules.PedalChain)
local AmpChain = require(ReplicatedStorage.Modules.AmpChain)
local CabinetChain = require(ReplicatedStorage.Modules.CabinetChain)
local FreePlaySoundAdapter = require(ReplicatedStorage.Modules.FreePlaySoundAdapter)
local FreePlayAutoMuteConfig = require(ReplicatedStorage.Modules.FreePlayAutoMuteConfig)
local FreePlaySustainExtender = require(ReplicatedStorage.Modules.FreePlaySustainExtender)
local FreePlayVibrato = require(ReplicatedStorage.Modules.FreePlayVibrato)
local FreePlayDrumRules = require(ReplicatedStorage.Modules.FreePlayDrumRules)
local FreePlayPianoRules = require(ReplicatedStorage.Modules.FreePlayPianoRules)
local state = FreePlayPianoRules.NewState()
local FreePlayAutoVolume = require(ReplicatedStorage.Modules.FreePlayAutoVolume)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Debris = game:GetService("Debris")

local AudioEngine = {}

local v = nil
local soundGroup2 = nil
local v2 = nil

local v3 = {}
local v4 = nil

local object = setmetatable({}, { __mode = "k" })

local object2 = setmetatable({}, { __mode = "k" })

local v5 = FreePlayDrumRules.NewTracker()

local v6 = {}

local v7 = {}
local instances = {}

local v8 = {}

local v9 = {}

local v10 = nil

local function setLimiterMode(p) -- 1 equivalent call inferred from this helper
	if not (v10 and v10.Parent) then
		return
	end

	local threshold = p and -4 or -8
	local ratio = p and 6 or 15

	if v10.Threshold ~= threshold then
		v10.Threshold = threshold
	end

	if v10.Ratio ~= ratio then
		v10.Ratio = ratio
	end
end

local function laneKeyFor(data, p) -- 7 equivalent calls inferred from this helper
	return tostring(data.String or "") .. ":" .. tostring(data.Fret or "") .. ":" .. tostring(data.Pad or "") .. ":" .. tostring(data.Note or "") .. ":" .. tostring(p)
end

local function fadeThenStop(instance, duration)
	if instance and FreePlaySustainExtender.Release(instance, duration) or not (instance and instance.Parent) then
		return
	end

	local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Volume = 0
	})
	tween:Play()
	tween.Completed:Once(function()
		pcall(function()
			instance:Stop()
		end)
	end)
end

local function demoteToFaint(instance, duration)
	if instance and FreePlaySustainExtender.Demote(instance, 0.18, duration) then
		return
	end

	if instance and instance.Parent then
		TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Volume = 0.18
		}):Play()
	end
end

local function fadeStopAndDestroy(instance, duration, p, p2)
	if
		instance and FreePlaySustainExtender.Release(instance, duration, p, p2)
		or not (instance and instance.Parent)
	then
		return
	end

	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, p or Enum.EasingStyle.Linear, p2 or Enum.EasingDirection.Out),
		{ Volume = 0 }
	)

	tween.Completed:Once(function()
		pcall(function()
			instance:Stop()
		end)
		instance:Destroy()
	end)
	tween:Play()
end

local function removeFromList(list, p) -- 4 equivalent calls inferred from this helper
	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end
end

local function overlapForget(p, p2) -- 4 equivalent calls inferred from this helper
	local v11 = v7[p]

	if v11 then
		removeFromList(v11, p2) -- inferred equivalent call

		if #v11 == 0 then
			v7[p] = nil
		end
	end

	removeFromList(instances, p2) -- inferred equivalent call
end

local function overlapPush(p, instance)
	local instances2 = v7[p]

	if not instances2 then
		instances2 = {}
		v7[p] = instances2
	end

	table.insert(instances2, instance)
	instance.Destroying:Once(function()
		overlapForget(p, instance) -- inferred equivalent call
	end)
end

local function overlapRegister(p, audioEngineNote)
	table.insert(instances, audioEngineNote)
	audioEngineNote.Destroying:Once(function()
		overlapForget(p, audioEngineNote) -- inferred equivalent call
	end)

	while #instances > FreePlayAutoMuteConfig.OVERLAP_MAX_VOICES do
		local v11 = table.remove(instances, 1)

		for k, v12 in pairs(v3) do
			if v12 == v11 then
				v3[k] = nil
				break
			end
		end

		for k, v12 in pairs(v7) do
			removeFromList(v12, v11) -- inferred equivalent call

			if #v12 == 0 then
				v7[k] = nil
			end
		end

		if v4 == v11 then
			v4 = nil
		end

		fadeStopAndDestroy(v11, FreePlayAutoMuteConfig.OVERLAP_CAP_FADE)
	end
end

local function applyMasterOutput(p, p2) -- 3 equivalent calls inferred from this helper
	local attribute = LocalPlayer and LocalPlayer:GetAttribute(FreePlayAutoVolume.ATTRIBUTE)

	if typeof(attribute) == "number" then
		p2.Volume = FreePlayAutoVolume.ToGroupVolume(attribute, p.Amp ~= nil)
	else
		p2.Volume = (p.Amp and p.Amp.Master or 1) * p.Volume
	end
end

if LocalPlayer then
	LocalPlayer:GetAttributeChangedSignal(FreePlayAutoVolume.ATTRIBUTE):Connect(function()
		if v and soundGroup2 then
			applyMasterOutput(v, soundGroup2) -- inferred equivalent call
		end
	end)
end

local function onRigChanged(p, p2)
	if p ~= v or not v2 then
		return
	end

	PedalChain.Update(v2.PreAmp, p2)
	AmpChain.Update(v2.Amp, p2)
	CabinetChain.Update(v2.Cabinet, p2)
	PedalChain.Update(v2.PostAmp, p2)

	if p2 and (p2.Volume or p2.Amp and table.find(p2.Amp, "Master")) then
		applyMasterOutput(p, soundGroup2) -- inferred equivalent call
	end
end

local function destroyCurrentChains()
	if v2 then
		PedalChain.Destroy(v2.PreAmp)
		AmpChain.Destroy(v2.Amp)
		CabinetChain.Destroy(v2.Cabinet)
		PedalChain.Destroy(v2.PostAmp)
		v2 = nil
	end

	if soundGroup2 then
		soundGroup2:Destroy()
		soundGroup2 = nil
	end
end

function AudioEngine.SetRig(p)
	destroyCurrentChains()
	v = p
	v3 = {}
	v4 = nil
	v8 = {}
	v9 = {}
	v10 = nil
	v7 = {}
	instances = {}
	v5 = FreePlayDrumRules.NewTracker()
	v6 = {}

	FreePlayPianoRules.MuteAll(state, 0.1)

	if not p then
		return
	end

	local soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "AudioRig_" .. tostring(p.OwnerUserId)
	soundGroup.Parent = SoundService
	soundGroup2 = soundGroup

	local preAmp = PedalChain.BuildPreAmp(p, soundGroup, 0)
	local amp = AmpChain.Build(p, soundGroup, preAmp.nextPriority or 0)
	local cabinet = CabinetChain.Build(p, soundGroup, amp.nextPriority or 0)
	local postAmp = PedalChain.BuildPostAmp(p, soundGroup, cabinet.nextPriority or 0)

	v2 = { PreAmp = preAmp, Amp = amp, Cabinet = cabinet, PostAmp = postAmp }

	local outputLimiter = Instance.new("CompressorSoundEffect")
	outputLimiter.Name = "OutputLimiter"
	outputLimiter.Priority = postAmp.nextPriority or 0
	outputLimiter.Threshold = -8
	outputLimiter.Ratio = 15
	outputLimiter.GainMakeup = 0
	outputLimiter.Enabled = true
	outputLimiter.Parent = soundGroup
	v10 = outputLimiter
	applyMasterOutput(p, soundGroup) -- inferred equivalent call
	AudioRig.OnChanged(p, onRigChanged)
end

local function playDrumAction(data, p, p2, p3, p4)
	local pad = data.Pad

	if not pad then
		return
	end

	if v10 and v10.Parent then
		if v10.Threshold ~= -8 then
			v10.Threshold = -8
		end

		if v10.Ratio ~= 15 then
			v10.Ratio = 15
		end
	end

	local v11, v12, v13 = FreePlayDrumRules.ApplyHumanize(
		pad,
		FreePlaySoundAdapter.GetLocalDrumSelection(),
		FreePlaySoundAdapter.GetLocalDrumHumanize()
	)

	local resolved, v14 = FreePlaySoundAdapter.Resolve(data, p, p2, p3, nil, v11)

	if not resolved then
		return
	end

	local v15 = (v14 or 1) * v12

	local selectionKit = FreePlayDrumRules.SelectionKit(FreePlaySoundAdapter.GetLocalDrumSelection(), pad)

	local playbackAnchor = FreePlaySoundAdapter.GetPlaybackAnchor()

	if not playbackAnchor then
		return
	end

	FreePlayDrumRules.ApplyCuts(FreePlayDrumRules.TakeForPress(v5, pad, p4))

	local audioEngineNote = Instance.new("Sound")
	audioEngineNote.Name = "AudioEngineNote"
	audioEngineNote.SoundId = resolved
	audioEngineNote.PlaybackSpeed = v15 or 1

	local mixValues, v16, v17 = FreePlayDrumRules.MixValues(FreePlaySoundAdapter.GetLocalDrumMix(), pad)
	audioEngineNote.Volume = math.min(10, 1 * FreePlayDrumRules.PadVolume(selectionKit, pad) * (mixValues / 100) * v13)

	if (v16 > 0 or v17 ~= 0) and soundGroup2 then
		audioEngineNote.SoundGroup = FreePlayDrumRules.EnsurePadGroup(
			v6,
			pad,
			soundGroup2,
			"DrumReverb_" .. pad,
			v16,
			v17
		)
	elseif soundGroup2 then
		audioEngineNote.SoundGroup = soundGroup2
	end

	audioEngineNote.Parent = playbackAnchor
	audioEngineNote:Play()

	FreePlayDrumRules.Add(v5, pad, audioEngineNote)

	if p4 then
		FreePlayDrumRules.ApplyCuts(FreePlayDrumRules.TrimOverflow(v5, FreePlayAutoMuteConfig.OVERLAP_MAX_VOICES))
	end

	FreePlayDrumRules.ScheduleTail(audioEngineNote, pad, v15, selectionKit)

	audioEngineNote.Ended:Once(function()
		audioEngineNote:Destroy()
	end)
	task.delay(FreePlayDrumRules.NOTE_MAX_LIFETIME - FreePlayDrumRules.NOTE_END_FADE, function()
		if audioEngineNote.Parent and audioEngineNote.IsPlaying then
			TweenService:Create(
				audioEngineNote,
				TweenInfo.new(FreePlayDrumRules.NOTE_END_FADE, Enum.EasingStyle.Linear),
				{ Volume = 0 }
			):Play()
		end
	end)
	Debris:AddItem(audioEngineNote, FreePlayDrumRules.NOTE_MAX_LIFETIME)
end

local v11 = nil
local function effectiveTone(p, p2)
	if v11 == nil then
		local success, result = pcall(function()
			return require(ReplicatedStorage.Modules.FreePlayAssetPreloader)
		end)

		v11 = success and result or false
	end

	if v11 and v11.GetEffectiveTone then
		local success, effectiveTone2 = pcall(v11.GetEffectiveTone, p, p2)

		if success then
			return effectiveTone2
		end
	end

	return p2
end

function AudioEngine._playPiano(p, _, _, p2)
	local note = p.Note

	if not note then
		return
	end

	local resolved = FreePlaySoundAdapter.Resolve(p, "Piano", false, effectiveTone("Piano", p2))

	if not resolved then
		return
	end

	local playbackAnchor = FreePlaySoundAdapter.GetPlaybackAnchor()

	if not playbackAnchor then
		return
	end

	local audioEngineNote = Instance.new("Sound")
	audioEngineNote.Name = "AudioEngineNote"
	audioEngineNote.SoundId = resolved
	audioEngineNote.Volume = FreePlayPianoRules.VOLUME
	audioEngineNote.Parent = playbackAnchor
	audioEngineNote:Play()
	FreePlayPianoRules.OnPlay(state, audioEngineNote, note)
end

function AudioEngine.SetPedal(_, p)
	FreePlayPianoRules.SetPedal(state, p)
end

function AudioEngine.PlayAction(_, data, p, p2, p3, p4, p5, p6)
	if p == "Piano" then
		AudioEngine._playPiano(data, "Piano", p2, p3)
		return
	end

	if FreePlayDrumRules.IsDrum(p) then
		playDrumAction(data, p, p2, p3, p6 == true)
		return
	end

	local sustainFactor = FreePlayAutoMuteConfig.ToSustainFactor(p4)
	local v12

	if p5 == true then
		v12 = FreePlayAutoMuteConfig.IsAutoMuteInstrument(p)
	else
		v12 = false
	end

	if v12 then
		sustainFactor = nil
	end

	local v13

	if p6 == true then
		v13 = FreePlayAutoMuteConfig.IsAutoMuteInstrument(p)
	else
		v13 = false
	end

	if not (v and soundGroup2) then
		return
	end

	local v14 = effectiveTone(p, p3)

	local isDistortionTone = FreePlayAutoMuteConfig.IsDistortionTone(p, v14)
	setLimiterMode(not isDistortionTone) -- inferred equivalent call
	local resolved, playbackSpeed, timePosition = FreePlaySoundAdapter.Resolve(data, p, p2, v14)

	if not resolved then
		return
	end

	local playbackAnchor = FreePlaySoundAdapter.GetPlaybackAnchor()

	if not playbackAnchor then
		return
	end

	local audioEngineNote = Instance.new("Sound")
	audioEngineNote.Name = "AudioEngineNote"
	audioEngineNote.SoundId = resolved
	audioEngineNote.PlaybackSpeed = playbackSpeed

	if timePosition then
		audioEngineNote.TimePosition = timePosition
	end

	local v15 = laneKeyFor(data, p2) -- inferred equivalent call
	local v16 = v3[v15]
	local str

	if data.String and FreePlayAutoMuteConfig.IsAutoMuteInstrument(p) then
		str = tostring(data.String) or nil
	end

	if v16 and v13 then
		overlapPush(v15, v16)
	elseif v16 then
		if v4 == v16 then
			v4 = nil
		end

		if v12 or object2[v16] then
			fadeStopAndDestroy(v16, 0.04)
		else
			fadeStopAndDestroy(v16, 0.07)
		end
	end

	if str and not (v13 or v12) then
		local v17 = v8[str]

		if v17 and v17 ~= v16 and v17.Parent and not object2[v17] then
			for k, v18 in pairs(v3) do
				if v18 == v17 then
					v3[k] = nil

					if v4 == v17 then
						v4 = nil
					end

					fadeStopAndDestroy(v17, 0.07)
					break
				end
			end
		end
	end

	local volume

	if isDistortionTone and not v12 then
		local now = os.clock()
		local count = 0

		for i = #v9, 1, -1 do
			local v17 = v9[i]

			if v17.Sound.Parent and not (now - v17.Time > FreePlayAutoMuteConfig.DISTORTION.POLY_WINDOW) then
				count += 1
			else
				table.remove(v9, i)
			end
		end

		volume = 1 * FreePlayAutoMuteConfig.DistortionNoteGain(data.String, count)
		table.insert(v9, { Sound = audioEngineNote, Time = now })
	else
		volume = 1
	end

	audioEngineNote.Volume = volume
	audioEngineNote.SoundGroup = soundGroup2
	audioEngineNote.Parent = playbackAnchor
	audioEngineNote:Play()

	if FreePlayAutoMuteConfig.IsAutoMuteInstrument(p) then
		FreePlayVibrato.Register(audioEngineNote, playbackSpeed)
	end

	v3[v15] = audioEngineNote

	if not v12 then
		v4 = audioEngineNote
	end

	if str and not (v13 or v12) then
		v8[str] = audioEngineNote
	end

	if v13 then
		overlapRegister(v15, audioEngineNote)
	end

	local v17 = { Held = true }
	object[audioEngineNote] = v17

	local flag = false
	local function release() -- 5 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true

		if v3[v15] == audioEngineNote then
			v3[v15] = nil
		end

		overlapForget(v15, audioEngineNote) -- inferred equivalent call

		if v4 == audioEngineNote then
			v4 = nil
		end
	end

	if v12 then
		object2[audioEngineNote] = os.clock()
		audioEngineNote.Ended:Once(function()
			release() -- inferred equivalent call
			audioEngineNote:Destroy()
		end)

		if v13 then
			local OVERLAP_TREMOLO_PICK_FADE = FreePlayAutoMuteConfig.OVERLAP_TREMOLO_PICK_FADE
			task.delay(math.max(0, FreePlayAutoMuteConfig.TREMOLO_PICK_LIFETIME - OVERLAP_TREMOLO_PICK_FADE), function()
				if object2[audioEngineNote] and audioEngineNote.Parent then
					release() -- inferred equivalent call
					fadeStopAndDestroy(audioEngineNote, OVERLAP_TREMOLO_PICK_FADE)
				end
			end)
		else
			task.delay(FreePlayAutoMuteConfig.TREMOLO_PICK_LIFETIME, function()
				if object2[audioEngineNote] and audioEngineNote.Parent then
					release() -- inferred equivalent call
					audioEngineNote:Destroy()
				end
			end)
		end
	else
		if sustainFactor and FreePlayAutoMuteConfig.IsAutoMuteInstrument(p) then
			FreePlaySustainExtender.Start(audioEngineNote, timePosition or 0, release, sustainFactor)
			return
		end

		audioEngineNote.Ended:Once(function()
			release() -- inferred equivalent call
			audioEngineNote:Destroy()
		end)

		task.delay(7.5, function()
			if audioEngineNote.Parent and audioEngineNote.IsPlaying then
				TweenService:Create(audioEngineNote, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Volume = 0
				}):Play()
			end
		end)
		Debris:AddItem(audioEngineNote, 8)
		task.delay(8, release)

		if not sustainFactor and FreePlayAutoMuteConfig.IsAutoMuteInstrument(p) then
			local distortion = FreePlayAutoMuteConfig.DISTORTION
			local NORMAL_FADE_START = isDistortionTone and distortion.NORMAL_FADE_START
				or FreePlayAutoMuteConfig.NORMAL_FADE_START
			local NORMAL_FADE_DURATION = isDistortionTone and distortion.NORMAL_FADE_DURATION
				or FreePlayAutoMuteConfig.NORMAL_FADE_DURATION
			task.delay(NORMAL_FADE_START, function()
				if not audioEngineNote.Parent or v17.Held then
					return
				end

				release() -- inferred equivalent call
				fadeStopAndDestroy(audioEngineNote, NORMAL_FADE_DURATION)
			end)

			if isDistortionTone then
				task.delay(distortion.HELD_DECAY_START, function()
					if
						not audioEngineNote.Parent
						or v3[v15] ~= audioEngineNote and not table.find(instances, audioEngineNote)
					then
						return
					end

					TweenService:Create(
						audioEngineNote,
						TweenInfo.new(distortion.HELD_DECAY_TIME, Enum.EasingStyle.Linear),
						{
							Volume = audioEngineNote.Volume * distortion.HELD_FLOOR
						}
					):Play()
				end)
			end
		end
	end
end

function AudioEngine.StopTremoloLane(_, data, p)
	if not data then
		return
	end

	local set = {
		[laneKeyFor(data, true)] = true, -- inferred equivalent call
		[laneKeyFor(data, false)] = true, -- inferred equivalent call
		[laneKeyFor(data, p)] = true -- inferred equivalent call
	}

	for k in set do
		local v12 = v3[k]
		local v13 = v12 and object2[v12]

		if not v13 then
			continue
		end

		object2[v12] = nil
		local v14 = object[v12]

		if v14 then
			v14.Held = false
		end

		v4 = v12
		Debris:AddItem(v12, 8)
		task.delay(math.max(0, FreePlayAutoMuteConfig.NORMAL_FADE_START - (os.clock() - v13)), function()
			if not v12.Parent then
				return
			end

			if v3[k] == v12 then
				v3[k] = nil
			end

			if v4 == v12 then
				v4 = nil
			end

			overlapForget(k, v12) -- inferred equivalent call
			fadeStopAndDestroy(v12, FreePlayAutoMuteConfig.NORMAL_FADE_DURATION)
		end)
	end
end

function AudioEngine.MuteAll(_)
	for k, v12 in pairs(v3) do
		v3[k] = nil
		fadeStopAndDestroy(
			v12,
			FreePlayAutoMuteConfig.MUTE_FADE_DURATION,
			FreePlayAutoMuteConfig.MUTE_EASING_STYLE,
			FreePlayAutoMuteConfig.MUTE_EASING_DIRECTION
		)
	end

	v4 = nil

	for k, list in pairs(v7) do
		v7[k] = nil

		for _, item in ipairs(list) do
			fadeStopAndDestroy(
				item,
				FreePlayAutoMuteConfig.MUTE_FADE_DURATION,
				FreePlayAutoMuteConfig.MUTE_EASING_STYLE,
				FreePlayAutoMuteConfig.MUTE_EASING_DIRECTION
			)
		end
	end

	instances = {}

	FreePlayDrumRules.ApplyCuts(FreePlayDrumRules.TakeChoke(v5))
end

function AudioEngine.ReleaseAction(_, data, p, p2, p3)
	if not data then
		return
	end

	if p == "Piano" then
		if data.Note then
			FreePlayPianoRules.OnRelease(state, data.Note)
		end
	else
		local set = {
			[laneKeyFor(data, true)] = true, -- inferred equivalent call
			[laneKeyFor(data, false)] = true, -- inferred equivalent call
			[laneKeyFor(data, p2)] = true -- inferred equivalent call
		}

		for k in set do
			local v12 = v3[k]

			if v12 then
				local v13 = object[v12]

				if v13 then
					v13.Held = false
				end

				if p3 == true then
					v3[k] = nil

					if v4 == v12 then
						v4 = nil
					end

					fadeStopAndDestroy(v12, FreePlayAutoMuteConfig.AUTO_MUTE_FADE_DURATION)
				end
			end

			local v13 = v7[k]

			if not v13 then
				continue
			end

			for i = #v13, 1, -1 do
				local v14 = v13[i]
				local v15 = object[v14]

				if v15 then
					v15.Held = false
				end

				if p3 ~= true then
					continue
				end

				table.remove(v13, i)
				removeFromList(instances, v14) -- inferred equivalent call
				fadeStopAndDestroy(v14, FreePlayAutoMuteConfig.AUTO_MUTE_FADE_DURATION)
			end

			if #v13 == 0 then
				v7[k] = nil
			end
		end
	end
end

return AudioEngine