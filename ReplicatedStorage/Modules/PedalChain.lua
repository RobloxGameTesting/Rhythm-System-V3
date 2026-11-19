local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)
local PedalboardRegistry = require(ReplicatedStorage.Modules.PedalboardRegistry)
require(ReplicatedStorage.Modules.AudioRig)

local v = { GuitarLead = "Guitar", GuitarRhythm = "Guitar", Bass = "Bass" }

local function createEffectForPedal(name, priority, parent)
	local v2 = PedalNodeTypeRegistry.Get(name)

	if not (v2 and v2.EffectClassName) then
		return nil
	end

	local success, result = pcall(Instance.new, v2.EffectClassName)

	if not (success and result) then
		warn(string.format(
			"[PedalChain] Gagal membuat SoundEffect '%s' untuk pedal '%s'",
			tostring(v2.EffectClassName),
			name
		))
		return nil
	end

	result.Name = name
	result.Priority = priority
	result.Parent = parent
	return result
end

local function applyPedalParameters(p, p2, p3)
	local v2 = PedalNodeTypeRegistry.Get(p)

	if not (v2 and v2.ApplyParameters) then
		return
	end

	local success, result = pcall(v2.ApplyParameters, p2, p3)

	if not success then
		warn(string.format("[PedalChain] ApplyParameters pedal '%s' error: %s", p, (tostring(result))))
	end
end

local function animateIntensity(p, p2, p3, p4, p5, p6, callback)
	local parameters = p.rig.Pedals[p2].Parameters

	p.animationToken[p2] = (p.animationToken[p2] or 0) + 1
	local v2 = p.animationToken[p2]

	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if p.animationToken[p2] ~= v2 then
			heartbeatConnection:Disconnect()
			return
		end

		total += dt
		local v3 = math.clamp(total / 0.15, 0, 1)
		local v4 = p5 + (p6 - p5) * v3

		local clone = table.clone(parameters)
		clone[p4] = v4
		applyPedalParameters(p2, p3, clone)

		if v3 >= 1 then
			heartbeatConnection:Disconnect()

			if callback then
				callback()
			end
		end
	end)
end

local function transitionPedalEnabled(data, pedal, enabled)
	local effect = data.effects[pedal]
	local v2 = PedalNodeTypeRegistry.Get(pedal)

	if not (effect and v2) then
		return
	end

	local pedal2 = data.rig.Pedals[pedal]
	local primaryIntensityParam = v2.PrimaryIntensityParam

	if primaryIntensityParam then
		local parameter = pedal2.Parameters[primaryIntensityParam]

		if enabled then
			effect.Enabled = true
			local parameters = data.rig.Pedals[pedal].Parameters

			data.animationToken[pedal] = (data.animationToken[pedal] or 0) + 1
			local v3 = data.animationToken[pedal]

			local total = 0
			local heartbeatConnection = nil
			local v4 = 0
			local v5 = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if data.animationToken[pedal] ~= v3 then
					heartbeatConnection:Disconnect()
					return
				end

				total += dt
				local v6 = math.clamp(total / 0.15, 0, 1)
				local v7 = v4 + (parameter - v4) * v6

				local clone = table.clone(parameters)
				clone[primaryIntensityParam] = v7
				applyPedalParameters(pedal, effect, clone)

				if v6 >= 1 then
					heartbeatConnection:Disconnect()

					if v5 then
						v5()
					end
				end
			end)
		else
			local function fn()
				effect.Enabled = false
			end

			local parameters = data.rig.Pedals[pedal].Parameters

			data.animationToken[pedal] = (data.animationToken[pedal] or 0) + 1
			local v3 = data.animationToken[pedal]

			local total = 0
			local heartbeatConnection = nil
			local v4 = 0
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if data.animationToken[pedal] ~= v3 then
					heartbeatConnection:Disconnect()
					return
				end

				total += dt
				local v5 = math.clamp(total / 0.15, 0, 1)
				local v6 = parameter + (v4 - parameter) * v5

				local clone = table.clone(parameters)
				clone[primaryIntensityParam] = v6
				applyPedalParameters(pedal, effect, clone)

				if v5 >= 1 then
					heartbeatConnection:Disconnect()

					if fn then
						fn()
					end
				end
			end)
		end
	else
		effect.Enabled = enabled
		applyPedalParameters(pedal, effect, pedal2.Parameters)
	end
end

local function buildChain(rig, soundInstance, value, p)
	local chain = {
		rig = rig,
		effects = {},
		animationToken = {},
		soundInstance = soundInstance,
		nextPriority = value or 0
	}

	if not rig.Pedals then
		return chain
	end

	local v2 = v[rig.Instrument]
	local v3 = v2 and PedalboardRegistry.Get(v2)

	if not v3 then
		return chain
	end

	local nextPriority = value or 0

	local function buildPedal(name) -- 1 equivalent call inferred from this helper
		local pedal = rig.Pedals[name]

		if not pedal then
			return
		end

		local effectForPedal = createEffectForPedal(name, nextPriority, soundInstance)
		nextPriority += 1

		if effectForPedal then
			effectForPedal.Enabled = pedal.Enabled
			applyPedalParameters(name, effectForPedal, pedal.Parameters)
			chain.effects[name] = effectForPedal
		end
	end

	for _, v4 in ipairs(v3[p]) do
		buildPedal(v4) -- inferred equivalent call
	end

	chain.nextPriority = nextPriority

	return chain
end

local PedalChain = {}

function PedalChain.BuildPreAmp(rig, soundInstance, p)
	return buildChain(rig, soundInstance, p, "PreAmpOrder")
end

function PedalChain.BuildPostAmp(rig, soundInstance, p)
	return buildChain(rig, soundInstance, p, "PostAmpOrder")
end

function PedalChain.Update(p, p2)
	if not (p2 and p2.Pedals) then
		return
	end

	for _, pedal in ipairs(p2.Pedals) do
		local effect = p.effects[pedal]
		local pedal2 = p.rig.Pedals[pedal]

		if not (effect and pedal2) then
			continue
		end

		local v2 = PedalNodeTypeRegistry.Get(pedal)
		local enabled = effect.Enabled

		if v2 and v2.PrimaryIntensityParam and enabled ~= pedal2.Enabled then
			transitionPedalEnabled(p, pedal, pedal2.Enabled)
		else
			effect.Enabled = pedal2.Enabled
			applyPedalParameters(pedal, effect, pedal2.Parameters)
		end
	end
end

function PedalChain:Destroy()
	for k in pairs(self.animationToken) do
		self.animationToken[k] = (self.animationToken[k] or 0) + 1
	end

	for _, effect in pairs(self.effects) do
		effect:Destroy()
	end

	self.effects = {}
end

return PedalChain