local function toGainDb(p) -- 4 equivalent calls inferred from this helper
	return (p - 0.5) * 24
end

local function computeEqValues(amp) -- 2 equivalent calls inferred from this helper
	return toGainDb(amp.Bass), toGainDb(amp.Middle), toGainDb(amp.Treble) + toGainDb(amp.Presence) * 0.5 -- inferred equivalent call
end

local AmpChain = {}

function AmpChain.Build(rig, parent, value)
	local v = {
		rig = rig,
		soundInstance = parent,
		gainEffect = nil,
		eqEffect = nil,
		currentMaster = rig.Amp and rig.Amp.Master or 1,
		nextPriority = value or 0
	}

	if not rig.Amp then
		return v
	end

	local priority = value or 0

	local ampGain = Instance.new("DistortionSoundEffect")
	ampGain.Name = "AmpGain"
	ampGain.Priority = priority
	ampGain.Enabled = true
	ampGain.Level = rig.Amp.Gain
	ampGain.Parent = parent
	local priority2 = priority + 1
	v.gainEffect = ampGain

	local ampEQ = Instance.new("EqualizerSoundEffect")
	ampEQ.Name = "AmpEQ"
	ampEQ.Priority = priority2
	ampEQ.Enabled = true
	local lowGain, midGain, highGain = computeEqValues(rig.Amp) -- inferred equivalent call
	ampEQ.LowGain = lowGain
	ampEQ.MidGain = midGain
	ampEQ.HighGain = highGain
	ampEQ.Parent = parent
	local nextPriority = priority2 + 1
	v.eqEffect = ampEQ

	v.nextPriority = nextPriority

	return v
end

function AmpChain:Update(p)
	if not (p and p.Amp) then
		return
	end

	local rig = self.rig

	if not rig.Amp then
		return
	end

	local set = {}

	for _, v in ipairs(p.Amp) do
		set[v] = true
	end

	if self.gainEffect and set.Gain then
		self.gainEffect.Level = rig.Amp.Gain
	end

	if self.eqEffect and (set.Bass or set.Middle or set.Treble or set.Presence) then
		local lowGain, midGain, highGain = computeEqValues(rig.Amp) -- inferred equivalent call
		self.eqEffect.LowGain = lowGain
		self.eqEffect.MidGain = midGain
		self.eqEffect.HighGain = highGain
	end

	if set.Master then
		self.currentMaster = rig.Amp.Master
	end
end

function AmpChain:Destroy()
	if self.gainEffect then
		self.gainEffect:Destroy()
	end

	if self.eqEffect then
		self.eqEffect:Destroy()
	end
end

return AmpChain