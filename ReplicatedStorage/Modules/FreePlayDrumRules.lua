local TweenService = game:GetService("TweenService")

local FreePlayDrumKits = require(script.Parent:WaitForChild("FreePlayDrumKits"))

local FreePlayDrumRules = {}
FreePlayDrumRules.RETRIGGER_FADE = 0.04
FreePlayDrumRules.HIHAT_CUT_FADE = 0.05
FreePlayDrumRules.CHOKE_FADE = 0.15
FreePlayDrumRules.NOTE_MAX_LIFETIME = 8
FreePlayDrumRules.NOTE_END_FADE = 0.5
FreePlayDrumRules.CAP_FADE = 0.12
local v = {
	HighCrash = true,
	Splash = true,
	MediumCrash = true,
	FootHiHat = true,
	RideEdge = true,
	RideBell = true,
	OpenHiHat = true,
	China = true
}

local v2 = {
	FootHiHat = { "OpenHiHat" }
}

function FreePlayDrumRules.IsDrum(p): boolean
	return p == "Drum"
end

function FreePlayDrumRules.SelectionKit(p, p2)
	return FreePlayDrumKits.SelectionKit(p, p2)
end

function FreePlayDrumRules.PadVolume(p, p2)
	return FreePlayDrumKits.GetVolume(p, p2)
end

function FreePlayDrumRules.MixValues(p, p2)
	return FreePlayDrumKits.GetMixValues(p, p2)
end

local v3 = { 22, 0.14, 0.25 }
local v4 = { 28, 0.14, 0.25 }
local v5 = { 20, 0.16, 0.25 }
local v6 = { 40, 0.28, 0.15 }
local v7 = {
	BassDrum = { 14, 0.1, 0.25 },
	Snare = v3,
	SideStick = v3,
	HighTom = v4,
	MidTom = v4,
	FloorTom = v4,
	FootHiHat = v5,
	OpenHiHat = v5,
	RideEdge = v6,
	RideBell = v6,
	HighCrash = v6,
	MediumCrash = v6,
	Splash = v6,
	China = v6,
	Cowbell = { 14, 0.1, 0.25 }
}

function FreePlayDrumRules.ApplyHumanize(p, p2, value)
	local v8 = math.clamp(type(value) == "number" and value or FreePlayDrumKits.HUMANIZE.DEFAULT, 0, 100) / 100

	if v8 <= 0 then
		return p2, 1, 1
	end

	local v9

	if type(p2) == "table" then
		v9 = p2[p] or nil
	end

	if type(v9) == "table" then
		local layerCount = FreePlayDrumKits.GetLayerCount(v9.Kit, p)

		if layerCount > 1 and math.random() < v8 * 0.4 then
			local velocity = v9.Velocity or 1
			local v10 = math.random(2) == 1 and -1 or 1
			local v11 = velocity + v10

			if v11 < 1 or layerCount < v11 then
				v11 = velocity - v10
			end

			local velocity2 = math.clamp(v11, 1, layerCount)

			if velocity2 ~= velocity then
				p2 = table.clone(p2)
				p2[p] = { Kit = v9.Kit, Velocity = velocity2 }
			end
		end
	end

	local v10 = v7[p]
	local v11, v12

	if v10 and math.random() >= (v10[3] or 0.25) then
		v11 = 2 ^ ((math.random() * 2 - 1) * v10[1] * v8 / 1200)
		v12 = 1 + (math.random() * 2 - 1) * v10[2] * v8
	else
		v11 = 1
		v12 = 1
	end

	return p2, v11, v12
end

function FreePlayDrumRules.ReverbWetLevel(value)
	return (1 - math.clamp(value, 0, 100) / 100) * -30
end

function FreePlayDrumRules:EnsurePadGroup(p, parent, name, reverbPct, value)
	reverbPct = reverbPct or 0
	value = value or 0
	local v8 = self[p]

	if not v8 or not v8.Group or v8.Group.Parent == nil then
		local soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = name
		soundGroup.Volume = 1
		soundGroup.Parent = parent

		local bassEQ = Instance.new("EqualizerSoundEffect")
		bassEQ.Name = "BassEQ"
		bassEQ.Priority = 0
		bassEQ.LowGain = 0
		bassEQ.MidGain = 0
		bassEQ.HighGain = 0
		bassEQ.Enabled = false
		bassEQ.Parent = soundGroup

		local padReverb = Instance.new("ReverbSoundEffect")
		padReverb.Name = "PadReverb"
		padReverb.Priority = 1
		padReverb.DecayTime = 1.8
		padReverb.Density = 1
		padReverb.Diffusion = 1
		padReverb.DryLevel = 0
		padReverb.WetLevel = FreePlayDrumRules.ReverbWetLevel(reverbPct)
		padReverb.Enabled = reverbPct > 0
		padReverb.Parent = soundGroup

		local bassLimiter = Instance.new("CompressorSoundEffect")
		bassLimiter.Name = "BassLimiter"
		bassLimiter.Priority = 2
		bassLimiter.Threshold = -8
		bassLimiter.Ratio = 15
		bassLimiter.GainMakeup = 0
		bassLimiter.Enabled = false
		bassLimiter.Parent = soundGroup

		v8 = {
			Group = soundGroup,
			Reverb = padReverb,
			BassEq = bassEQ,
			Limiter = bassLimiter,
			ReverbPct = reverbPct,
			BassDb = 0
		}
		self[p] = v8
	end

	if v8.ReverbPct ~= reverbPct then
		v8.Reverb.WetLevel = FreePlayDrumRules.ReverbWetLevel(reverbPct)
		v8.Reverb.Enabled = reverbPct > 0
		v8.ReverbPct = reverbPct
	end

	if v8.BassDb == value then
		return v8.Group
	end

	v8.BassEq.LowGain = value
	v8.BassEq.Enabled = value ~= 0
	v8.Limiter.Enabled = value > 0
	v8.BassDb = value

	return v8.Group
end

function FreePlayDrumRules.EnsureReverbGroup(p, p2, p3, p4, p5)
	return FreePlayDrumRules.EnsurePadGroup(p, p2, p3, p4, p5, 0)
end

function FreePlayDrumRules.IsCymbal(p): boolean
	return v[p] == true
end

function FreePlayDrumRules.NewTracker()
	return { Voices = {}, Order = {} }
end

function FreePlayDrumRules.Add(p, p2, instance)
	local v8 = p.Voices[p2]

	if not v8 then
		v8 = {}
		p.Voices[p2] = v8
	end

	v8[instance] = true
	table.insert(p.Order, instance)
	instance.Destroying:Once(function()
		local voice = p.Voices[p2]

		if voice then
			voice[instance] = nil
		end

		local index = table.find(p.Order, instance)

		if index then
			table.remove(p.Order, index)
		end
	end)
end

local function takeAll(p, p2, fade, list)
	local voice = p.Voices[p2]

	if not voice then
		return
	end

	for k in pairs(voice) do
		voice[k] = nil
		local index = table.find(p.Order, k)

		if index then
			table.remove(p.Order, index)
		end

		table.insert(list, { Sound = k, Fade = fade })
	end
end

function FreePlayDrumRules.TakeForPress(p, p2, p3)
	local v8 = {}

	if v[p2] and p3 ~= true then
		takeAll(p, p2, FreePlayDrumRules.RETRIGGER_FADE, v8)
	end

	local v9 = v2[p2]

	if v9 then
		for _, v10 in ipairs(v9) do
			takeAll(p, v10, FreePlayDrumRules.HIHAT_CUT_FADE, v8)
		end
	end

	return v8
end

function FreePlayDrumRules.TrimOverflow(p, p2)
	local order = p.Order
	local result = {}

	while p2 < #order do
		local sound = table.remove(order, 1)

		for _, voice in pairs(p.Voices) do
			if voice[sound] then
				voice[sound] = nil
				break
			end
		end

		table.insert(result, { Sound = sound, Fade = FreePlayDrumRules.CAP_FADE })
	end

	return result
end

function FreePlayDrumRules.TakeChoke(p)
	local v8 = {}

	for k in pairs(v) do
		takeAll(p, k, FreePlayDrumRules.CHOKE_FADE, v8)
	end

	return v8
end

function FreePlayDrumRules.FadeOutAndDestroy(instance, duration)
	if not (instance and instance.Parent) then
		return
	end

	local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Volume = 0
	})
	tween.Completed:Once(function()
		pcall(function()
			instance:Stop()
		end)
		instance:Destroy()
	end)
	tween:Play()
end

function FreePlayDrumRules.ApplyCuts(list)
	for _, item in ipairs(list) do
		FreePlayDrumRules.FadeOutAndDestroy(item.Sound, item.Fade)
	end
end

local v8 = {
	BassDrum = { 0.19, 0.07 },
	SideStick = { 0.21, 0.06 },
	FootHiHat = { 0.26, 0.06 },
	Cowbell = { 0.36, 0.1 },
	Snare = { 0.52, 0.1 },
	HighTom = { 0.92, 0.15 },
	MidTom = { 1.15, 0.15 },
	FloorTom = { 1.2, 0.15 },
	OpenHiHat = { 1.4, 0.2 },
	Splash = { 1.35, 0.2 },
	RideEdge = { 1.7, 0.2 },
	China = { 1.85, 0.2 },
	RideBell = { 1.95, 0.2 },
	HighCrash = { 2.9, 0.25 },
	MediumCrash = { 3.8, 0.25 }
}

function FreePlayDrumRules.ScheduleTail(data, p, value, p2)
	local tail = FreePlayDrumKits.GetTail(FreePlayDrumKits.IsValidKit(p2) and p2 or FreePlayDrumKits.DEFAULT, p)

	if tail == false then
		return
	end

	local v9 = tail or v8[p]

	if not v9 then
		return
	end

	local v10 = (type(value) ~= "number" or not (value > 0.1 and value)) and 1 or value
	local v11 = v9[1] / v10
	local v12 = v9[2] / v10

	if data.IsLoaded then
		task.delay(v11, function()
			FreePlayDrumRules.FadeOutAndDestroy(data, v12)
		end)
	else
		task.spawn(function()
			local lastTime = os.clock()

			while data.Parent and not data.IsLoaded and os.clock() - lastTime < 5 do
				task.wait()
			end

			if not data.Parent then
				return
			end

			local v13

			if data.IsLoaded then
				v13 = v11 - data.TimePosition / v10
			else
				v13 = v11 - (os.clock() - lastTime)
			end

			if v13 > 0 then
				task.wait(v13)
			end

			FreePlayDrumRules.FadeOutAndDestroy(data, v12)
		end)
	end
end

return FreePlayDrumRules