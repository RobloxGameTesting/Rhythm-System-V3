local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)
local PedalboardRegistry = require(ReplicatedStorage.Modules.PedalboardRegistry)

local AudioRig = {}
AudioRig.CURRENT_VERSION = 1
local v = { GuitarLead = "Guitar", GuitarRhythm = "Guitar", Bass = "Bass" }

local v2 = {
	Version = 1,
	Gain = 0,
	Bass = 0.5,
	Middle = 0.5,
	Treble = 0.5,
	Presence = 0.5,
	Master = 0.7
}

local v3 = { Version = 1, Type = "Marshall1960", Speaker = "SM57", Distance = "1inch" }

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local object3 = setmetatable({}, { __mode = "k" })
local set = {}

local function warnOnce(p, p2) -- 1 equivalent call inferred from this helper
	if set[p] then
		return
	end

	set[p] = true
	warn(p2)
end

local function getOrCreateChanges(p) -- 4 equivalent calls inferred from this helper
	local changes = object2[p]

	if not changes then
		changes = {}
		object2[p] = changes
	end

	return changes
end

local function recordPedalChange(p, p2) -- 4 equivalent calls inferred from this helper
	local changes = getOrCreateChanges(p) -- inferred equivalent call
	changes.Pedals = changes.Pedals or {}
	changes.Pedals[p2] = true
end

local function recordAmpChange(p, p2) -- 3 equivalent calls inferred from this helper
	local changes = getOrCreateChanges(p) -- inferred equivalent call
	changes.Amp = changes.Amp or {}
	changes.Amp[p2] = true
end

local function recordCabinetChange(p, p2) -- 3 equivalent calls inferred from this helper
	local changes = getOrCreateChanges(p) -- inferred equivalent call
	changes.Cabinet = changes.Cabinet or {}
	changes.Cabinet[p2] = true
end

local function recordVolumeChange(p) -- 3 equivalent calls inferred from this helper
	local changes = getOrCreateChanges(p) -- inferred equivalent call
	changes.Volume = true
end

local function finalizeChanges(p)
	local v4 = object2[p]

	if not v4 then
		return nil
	end

	local v5 = {}

	if v4.Pedals then
		local pedals = {}

		for k in pairs(v4.Pedals) do
			table.insert(pedals, k)
		end

		v5.Pedals = pedals
	end

	if v4.Amp then
		local amp = {}

		for k in pairs(v4.Amp) do
			table.insert(amp, k)
		end

		v5.Amp = amp
	end

	if v4.Cabinet then
		local cabinet = {}

		for k in pairs(v4.Cabinet) do
			table.insert(cabinet, k)
		end

		v5.Cabinet = cabinet
	end

	if v4.Volume then
		v5.Volume = true
	end

	return v5
end

local function clamp(p, p2, p3) -- 8 equivalent calls inferred from this helper
	if p < p2 then
		return p2
	end

	return if p3 < p then p3 else p
end

local function clampAllParameters(state)
	if state.Amp then
		state.Amp.Gain = clamp(state.Amp.Gain, 0, 1) -- inferred equivalent call
		state.Amp.Bass = clamp(state.Amp.Bass, 0, 1) -- inferred equivalent call
		state.Amp.Middle = clamp(state.Amp.Middle, 0, 1) -- inferred equivalent call
		state.Amp.Treble = clamp(state.Amp.Treble, 0, 1) -- inferred equivalent call
		state.Amp.Presence = clamp(state.Amp.Presence, 0, 1) -- inferred equivalent call
		state.Amp.Master = clamp(state.Amp.Master, 0, 1) -- inferred equivalent call
	end

	state.Volume = clamp(state.Volume, 0, 1) -- inferred equivalent call

	if state.Pedals then
		for k, pedal in pairs(state.Pedals) do
			local v4 = PedalNodeTypeRegistry.Get(k)
			local parameterRanges = v4 and v4.ParameterRanges

			if not (parameterRanges and pedal.Parameters) then
				continue
			end

			for k2, parameterRange in pairs(parameterRanges) do
				local parameter = pedal.Parameters[k2]

				if parameter == nil then
					continue
				end

				local parameters = pedal.Parameters
				parameter = clamp(parameter, parameterRange[1], parameterRange[2]) -- inferred equivalent call
				parameters[k2] = parameter
			end
		end
	end
end

local function fillMissingDefaults(p)
	if not p.Pedals then
		return
	end

	local v4 = v[p.Instrument]
	local v5 = v4 and PedalboardRegistry.Get(v4)

	if not v5 then
		return
	end

	local function ensurePedal(id)
		local v6 = PedalNodeTypeRegistry.Get(id)

		if not v6 then
			return
		end

		local pedal = p.Pedals[id]

		if not pedal then
			p.Pedals[id] = {
				Id = id,
				Enabled = false,
				Parameters = table.clone(v6.DefaultParameters),
				Version = v6.CurrentVersion
			}

			return
		end

		for k, defaultParameter in pairs(v6.DefaultParameters) do
			if pedal.Parameters[k] == nil then
				pedal.Parameters[k] = defaultParameter
			end
		end
	end

	for _, v6 in ipairs(v5.PreAmpOrder) do
		ensurePedal(v6)
	end

	for _, v6 in ipairs(v5.PostAmpOrder) do
		ensurePedal(v6)
	end
end

local function recomputeTone(state)
	local v4 = false

	if state.Pedals then
		local overdrive = state.Pedals.Overdrive
		local distortion = state.Pedals.Distortion
		local bassOverdrive = state.Pedals.BassOverdrive
		v4 = (overdrive and overdrive.Enabled or distortion and distortion.Enabled) and true
			or bassOverdrive and bassOverdrive.Enabled and true
			or false
	end

	state.Tone = (state.Amp and state.Amp.Gain > 0.6 and true or v4) and "Distortion" or "Clean"
end

local function repair(p) -- 2 equivalent calls inferred from this helper
	fillMissingDefaults(p)
	clampAllParameters(p)
	recomputeTone(p)
end

local function validate(p)
	if p.Pedals then
		for k, pedal in pairs(p.Pedals) do
			if not PedalNodeTypeRegistry.Get(k) then
				warn(string.format(
					"[AudioRig] Validate: rig milik %s punya pedal '%s' yang tidak terdaftar di PedalNodeTypeRegistry",
					tostring(p.OwnerUserId),
					k
				))
			end

			if pedal.Id ~= k then
				warn(string.format(
					"[AudioRig] Validate: rig milik %s - PedalInstance.Id ('%s') tidak cocok key tabel ('%s')",
					tostring(p.OwnerUserId),
					tostring(pedal.Id),
					k
				))
			end
		end
	end
end

local function normalize(p, timestamp) -- 1 equivalent call inferred from this helper
	repair(p) -- inferred equivalent call
	validate(p)
	p.Meta.Dirty = true
	p.Meta.UpdatedAt = timestamp or os.time()

	p.Meta.Revision = (p.Meta.Revision or 0) + 1
end

local function notify(p, p2)
	local v4 = object3[p]

	if not v4 then
		return
	end

	for _, callback in ipairs(v4) do
		local success, result = pcall(callback, p, p2)

		if not success then
			warn("[AudioRig] Error pada OnChanged listener:", result)
		end
	end
end

local function commit(p, options) -- 2 equivalent calls inferred from this helper
	normalize(p, (options or {}).Timestamp) -- inferred equivalent call
	local v4 = finalizeChanges(p)
	object2[p] = nil
	notify(p, v4)
end

local function maybeCommit(p, options) -- 5 equivalent calls inferred from this helper
	if (object[p] or 0) > 0 then
		return
	end

	commit(p, options) -- inferred equivalent call
end

function AudioRig.BeginUpdate(p)
	object[p] = (object[p] or 0) + 1
end

function AudioRig.EndUpdate(p, options)
	object[p] = math.max((object[p] or 1) - 1, 0)

	if object[p] == 0 then
		commit(p, options) -- inferred equivalent call
	end
end

function AudioRig.Transaction(p, callback, p2)
	AudioRig.BeginUpdate(p)
	local success, result = pcall(callback)
	AudioRig.EndUpdate(p, p2)

	if not success then
		error(result, 0)
	end
end

function AudioRig.OnChanged(p, p2)
	local v4 = object3[p]

	if not v4 then
		v4 = {}
		object3[p] = v4
	end

	table.insert(v4, p2)
end

function AudioRig.New(data)
	assert(data, "[AudioRig] New: context wajib diisi")
	assert(data.OwnerUserId, "[AudioRig] New: context.OwnerUserId wajib diisi")
	assert(data.Instrument, "[AudioRig] New: context.Instrument wajib diisi")

	local family = data.Family or v[data.Instrument]
	local v4 = family and PedalboardRegistry.Get(family)

	local v5 = {
		Version = data.Version or AudioRig.CURRENT_VERSION,
		OwnerUserId = data.OwnerUserId,
		Instrument = data.Instrument,
		Tone = "Clean",
		Pedals = nil,
		Amp = nil,
		Cabinet = nil,
		Volume = 1,
		Meta = { Dirty = false, UpdatedAt = os.time(), Revision = 0 }
	}

	if v4 then
		v5.Pedals = {}

		local function addPedal(id)
			local v6 = PedalNodeTypeRegistry.Get(id)

			if v6 then
				v5.Pedals[id] = {
					Id = id,
					Enabled = false,
					Parameters = table.clone(v6.DefaultParameters),
					Version = v6.CurrentVersion
				}

				return
			end

			warnOnce( -- inferred equivalent call
				"missing-nodetype:" .. id,
				string.format(
					"[AudioRig] New: pedal '%s' direferensikan PedalboardDefinition Family '%s' tapi belum terdaftar di PedalNodeTypeRegistry",
					id,
					family
				)
			)
		end

		for _, v6 in ipairs(v4.PreAmpOrder) do
			addPedal(v6)
		end

		for _, v6 in ipairs(v4.PostAmpOrder) do
			addPedal(v6)
		end

		v5.Amp = table.clone(v2)
		v5.Cabinet = table.clone(v3)
	end

	recomputeTone(v5)

	return v5
end

function AudioRig.SetPedalEnabled(data, p, enabled, p2)
	local v4 = data.Pedals and data.Pedals[p]

	if not v4 then
		warn(string.format(
			"[AudioRig] SetPedalEnabled: pedal '%s' tidak ada di rig milik %s (instrumen %s)",
			tostring(p),
			tostring(data.OwnerUserId),
			(tostring(data.Instrument))
		))
		return
	end

	v4.Enabled = enabled
	recordPedalChange(data, p) -- inferred equivalent call
	maybeCommit(data, p2) -- inferred equivalent call
end

function AudioRig.SetPedalParameter(p, p2, p3, p4, p5)
	local v4 = p.Pedals and p.Pedals[p2]

	if not v4 then
		warn(string.format(
			"[AudioRig] SetPedalParameter: pedal '%s' tidak ada di rig milik %s",
			tostring(p2),
			(tostring(p.OwnerUserId))
		))
		return
	end

	if v4.Parameters[p3] == nil then
		warn(string.format(
			"[AudioRig] SetPedalParameter: parameter '%s' tidak dikenal untuk pedal '%s'",
			tostring(p3),
			p2
		))
		return
	end

	v4.Parameters[p3] = p4
	recordPedalChange(p, p2) -- inferred equivalent call
	maybeCommit(p, p5) -- inferred equivalent call
end

function AudioRig.SetAmpParameter(data, p, p2, p3)
	if not data.Amp then
		warn(string.format(
			"[AudioRig] SetAmpParameter: rig milik %s (instrumen %s) tidak punya Amp",
			tostring(data.OwnerUserId),
			(tostring(data.Instrument))
		))
		return
	end

	if data.Amp[p] == nil or p == "Version" then
		warn(string.format("[AudioRig] SetAmpParameter: field '%s' tidak valid di Amp", (tostring(p))))
		return
	end

	data.Amp[p] = p2
	recordAmpChange(data, p) -- inferred equivalent call
	maybeCommit(data, p3) -- inferred equivalent call
end

function AudioRig.SetCabinetField(data, p, p2, p3)
	if not data.Cabinet then
		warn(string.format(
			"[AudioRig] SetCabinetField: rig milik %s (instrumen %s) tidak punya Cabinet",
			tostring(data.OwnerUserId),
			(tostring(data.Instrument))
		))
		return
	end

	if data.Cabinet[p] == nil or p == "Version" then
		warn(string.format("[AudioRig] SetCabinetField: field '%s' tidak valid di Cabinet", (tostring(p))))
		return
	end

	data.Cabinet[p] = p2
	recordCabinetChange(data, p) -- inferred equivalent call
	maybeCommit(data, p3) -- inferred equivalent call
end

function AudioRig:SetVolume(volume, p)
	self.Volume = volume
	recordVolumeChange(self) -- inferred equivalent call
	maybeCommit(self, p) -- inferred equivalent call
end

function AudioRig:ApplyPreset(data, p)
	AudioRig.Transaction(self, function()
		if data.Pedals then
			for k, pedal in pairs(data.Pedals) do
				local v4 = self.Pedals and self.Pedals[k]

				if v4 then
					if pedal.Enabled ~= nil then
						v4.Enabled = pedal.Enabled
					end

					if pedal.Parameters then
						for k2, parameter in pairs(pedal.Parameters) do
							if v4.Parameters[k2] ~= nil then
								v4.Parameters[k2] = parameter
							end
						end
					end

					recordPedalChange(self, k) -- inferred equivalent call
				else
					warn(string.format("[AudioRig] ApplyPreset: pedal '%s' di delta tidak ada di rig ini (dilewati)", k))
				end
			end
		end

		if data.Amp and self.Amp then
			for k, v4 in pairs(data.Amp) do
				if not (self.Amp[k] ~= nil and k ~= "Version") then
					continue
				end

				self.Amp[k] = v4
				recordAmpChange(self, k) -- inferred equivalent call
			end
		end

		if data.Cabinet and self.Cabinet then
			for k, v4 in pairs(data.Cabinet) do
				if not (self.Cabinet[k] ~= nil and k ~= "Version") then
					continue
				end

				self.Cabinet[k] = v4
				recordCabinetChange(self, k) -- inferred equivalent call
			end
		end

		if data.Volume ~= nil then
			self.Volume = data.Volume
			recordVolumeChange(self) -- inferred equivalent call
		end
	end, p)
end

function AudioRig:Reset(p)
	AudioRig.Transaction(self, function()
		local v4 = v[self.Instrument]
		local v5 = v4 and PedalboardRegistry.Get(v4)

		if v5 and self.Pedals then
			local function resetPedal(id)
				local v6 = PedalNodeTypeRegistry.Get(id)

				if not v6 then
					return
				end

				local version = self.Pedals[id] and self.Pedals[id].Version
				self.Pedals[id] = {
					Id = id,
					Enabled = false,
					Parameters = table.clone(v6.DefaultParameters),
					Version = version or v6.CurrentVersion
				}
				recordPedalChange(self, id) -- inferred equivalent call
			end

			for _, v6 in ipairs(v5.PreAmpOrder) do
				resetPedal(v6)
			end

			for _, v6 in ipairs(v5.PostAmpOrder) do
				resetPedal(v6)
			end
		end

		if self.Amp then
			local version = self.Amp.Version
			self.Amp = table.clone(v2)
			self.Amp.Version = version

			for k in pairs(v2) do
				recordAmpChange(self, k) -- inferred equivalent call
			end
		end

		if self.Cabinet then
			local version = self.Cabinet.Version
			self.Cabinet = table.clone(v3)
			self.Cabinet.Version = version

			for k in pairs(v3) do
				recordCabinetChange(self, k) -- inferred equivalent call
			end
		end

		self.Volume = 1
		recordVolumeChange(self) -- inferred equivalent call
	end, p)
end

function AudioRig.GetDefaultAmp()
	local clone = table.clone(v2)
	clone.Version = nil
	return clone
end

function AudioRig:Upgrade(p)
	if self.Version < AudioRig.CURRENT_VERSION then
		self.Version = AudioRig.CURRENT_VERSION
	end

	AudioRig.Transaction(self, function() end, p)
end

function AudioRig.MarkSaved(p)
	if p and p.Meta then
		p.Meta.Dirty = false
	else
		warn("[AudioRig] MarkSaved: rig atau rig.Meta tidak valid")
	end
end

function AudioRig.RepairLoadedSnapshot(p)
	if not p then
		warn("[AudioRig] RepairLoadedSnapshot: rig tidak valid")
		return p
	end

	repair(p) -- inferred equivalent call
	validate(p)
	return p
end

return AudioRig