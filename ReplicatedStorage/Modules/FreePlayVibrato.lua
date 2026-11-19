local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local FreePlayVibrato = {}
FreePlayVibrato.MIN_RATE = 4
FreePlayVibrato.MAX_RATE = 7
FreePlayVibrato.DEFAULT_RATE = 5.5
FreePlayVibrato.DIR_SYM = "Sym"
FreePlayVibrato.DIR_UP = "Up"
FreePlayVibrato.BEND_MAX = 100
local mode = "H"
local direction = FreePlayVibrato.DIR_SYM
local rate = FreePlayVibrato.DEFAULT_RATE
local v = false
local v2 = false
local mouseEnabled = true
local bendRaw = 0
local v3 = false
local v4 = 5.5
local v5 = 1
local v6 = nil
local v7 = {}
local v8 = {}

local function fireChanged() -- 9 equivalent calls inferred from this helper
	for _, callback in ipairs(v7) do
		pcall(callback)
	end
end

local context = "Rhythm"
local v9 = {
	FreePlay = {
		mode = "H",
		direction = FreePlayVibrato.DIR_SYM,
		rate = FreePlayVibrato.DEFAULT_RATE,
		mouseEnabled = false
	},
	Rhythm = {
		mode = "H",
		direction = FreePlayVibrato.DIR_SYM,
		rate = FreePlayVibrato.DEFAULT_RATE,
		mouseEnabled = true
	}
}

function FreePlayVibrato.GetContext()
	return context
end

function FreePlayVibrato.SetContext(p)
	if p == context or not v9[p] then
		return
	end

	local v10 = v9[context]
	local direction3 = direction
	local rate3 = rate
	local mouseEnabled3 = mouseEnabled
	v10.mode = mode
	v10.direction = direction3
	v10.rate = rate3
	v10.mouseEnabled = mouseEnabled3
	context = p
	local v11 = v9[p]
	local mode2 = v11.mode
	local direction2 = v11.direction
	local rate2 = v11.rate
	local mouseEnabled2 = v11.mouseEnabled
	mode = mode2
	direction = direction2
	rate = rate2
	mouseEnabled = mouseEnabled2
	v = false
	v2 = false
	bendRaw = 0
	v3 = false
	fireChanged() -- inferred equivalent call
end

function FreePlayVibrato.ToRate(value)
	if typeof(value) == "number" and value == value then
		return math.floor(math.clamp(value, FreePlayVibrato.MIN_RATE, FreePlayVibrato.MAX_RATE) * 10 + 0.5) / 10
	end

	return nil
end

function FreePlayVibrato.OnChanged(p)
	table.insert(v7, p)
end

function FreePlayVibrato.OnBend(p)
	table.insert(v8, p)
end

function FreePlayVibrato.SetGateProvider(p)
	v6 = p
end

local function gateOpen() -- 1 equivalent call inferred from this helper
	if not v6 then
		return true
	end

	local success, result = pcall(v6)
	return success and result == true
end

function FreePlayVibrato.IsActive()
	return if mode == "H" then v else v2
end

function FreePlayVibrato.IsEffective()
	local v10 = FreePlayVibrato.IsActive()

	if not v10 then
		return v10
	end

	if not v6 then
		return true
	end

	local success, result = pcall(v6)
	return success and result == true
end

function FreePlayVibrato.IsArmed()
	local _

	if context ~= "Rhythm" then
		_ = false
		return false
	end

	if not v6 then
		return true
	end

	local success, result = pcall(v6)
	return success and result == true
end

function FreePlayVibrato.GetMode()
	return mode
end

function FreePlayVibrato.SetMode(p)
	if context == "Rhythm" or p ~= "H" and p ~= "T" or p == mode then
		return
	end

	mode = p
	v = false
	v2 = false
	fireChanged() -- inferred equivalent call
end

function FreePlayVibrato.ToggleMode()
	FreePlayVibrato.SetMode(mode == "H" and "T" or "H")
	return mode
end

function FreePlayVibrato.GetDirection()
	return direction
end

function FreePlayVibrato.SetDirection(p)
	if context == "Rhythm" or p ~= FreePlayVibrato.DIR_SYM and p ~= FreePlayVibrato.DIR_UP then
		return
	end

	if p ~= direction then
		direction = p
		fireChanged() -- inferred equivalent call
	end
end

function FreePlayVibrato.GetRate()
	return rate
end

function FreePlayVibrato.SetRate(p)
	local rate2 = FreePlayVibrato.ToRate(p)

	if not rate2 then
		return false
	end

	if rate2 ~= rate then
		rate = rate2
		fireChanged() -- inferred equivalent call
	end

	return rate2
end

function FreePlayVibrato.CtrlDown()
	if mode == "H" then
		if not v then
			v = true
			fireChanged() -- inferred equivalent call
		end
	else
		v2 = not v2
		fireChanged() -- inferred equivalent call
	end
end

function FreePlayVibrato.CtrlUp()
	if mode == "H" and v then
		v = false
		fireChanged() -- inferred equivalent call
	end
end

function FreePlayVibrato.ResetActive()
	local v10 = bendRaw ~= 0
	bendRaw = 0
	v3 = false

	if v or v2 then
		v = false
		v2 = false
		fireChanged() -- inferred equivalent call
	elseif v10 then
		for _, callback in ipairs(v8) do
			pcall(callback)
		end
	end
end

function FreePlayVibrato.SetMouseEnabled(p)
	local v10 = p == true

	if context == "Rhythm" and not v10 or v10 == mouseEnabled then
		return
	end

	mouseEnabled = v10

	if not v10 then
		bendRaw = 0
	end

	fireChanged() -- inferred equivalent call
end

function FreePlayVibrato.GetMouseEnabled()
	return mouseEnabled
end

function FreePlayVibrato.SetBend(value)
	local v10 = math.clamp(value or 0, -FreePlayVibrato.BEND_MAX, FreePlayVibrato.BEND_MAX)

	if v10 ~= bendRaw then
		bendRaw = v10

		for _, callback in ipairs(v8) do
			pcall(callback)
		end
	end
end

function FreePlayVibrato.GetBendRaw()
	return bendRaw
end

function FreePlayVibrato.GetEffectiveBend()
	if bendRaw ~= 0 and gateOpen() then -- inferred equivalent call
		return bendRaw
	end

	return 0
end

function FreePlayVibrato.SetWhammy(p, p2, value)
	v3 = p == true

	if v3 then
		v4 = math.clamp(p2 or FreePlayVibrato.DEFAULT_RATE, FreePlayVibrato.MIN_RATE, FreePlayVibrato.MAX_RATE)
		v5 = math.clamp((value or 40) / 78, 0.2, 1.5)
	end
end

function FreePlayVibrato.IsWhammyActive()
	local v10 = v3

	if not v10 then
		return v10
	end

	if not v6 then
		return true
	end

	local success, result = pcall(v6)
	return success and result == true
end

function FreePlayVibrato.GetSendState()
	local isWhammyActive = FreePlayVibrato.IsWhammyActive()
	return
		FreePlayVibrato.IsEffective() or isWhammyActive,
		isWhammyActive and v4 or rate,
		isWhammyActive and FreePlayVibrato.DIR_SYM or direction,
		isWhammyActive and v5 or 1
end

local v10 = {}
local v11 = {}
local heartbeatConnection = nil
local v12 = false
local total = 0

local function getSource(p)
	local source = v11[p]

	if not source then
		source = {
			Env = 0,
			Rate = FreePlayVibrato.DEFAULT_RATE,
			Dir = FreePlayVibrato.DIR_SYM,
			Bend = 0,
			Phase = 0,
			DepthMul = 1,
			Player = nil
		}
		v11[p] = source
	end

	return source
end

local function updateSource(state, k, p)
	local v13 = nil
	local v14, v15, dir, v16, v17, v18

	if k == "Local" then
		local isWhammyActive = FreePlayVibrato.IsWhammyActive()
		v14 = FreePlayVibrato.IsEffective() or isWhammyActive
		v13 = FreePlayVibrato.IsArmed()
		v15 = isWhammyActive and v4 or rate
		dir = isWhammyActive and FreePlayVibrato.DIR_SYM or direction
		v16 = isWhammyActive and v5 or 1
		v17 = FreePlayVibrato.GetEffectiveBend()
		v18 = 30
	else
		v18 = 14
		local player = state.Player

		if not (player and player.Parent) then
			player = Players:GetPlayerByUserId(k)
			state.Player = player
		end

		if player then
			v14 = player:GetAttribute("FPVibActive") == true
			v13 = player:GetAttribute("FPVibArmed") == true
			local fpVibRate = player:GetAttribute("FPVibRate")
			v15 = typeof(fpVibRate) == "number" and fpVibRate or FreePlayVibrato.DEFAULT_RATE
			dir = player:GetAttribute("FPVibDir") == FreePlayVibrato.DIR_UP and FreePlayVibrato.DIR_UP
				or FreePlayVibrato.DIR_SYM
			local fpVibDepth = player:GetAttribute("FPVibDepth")
			v16 = typeof(fpVibDepth) == "number" and math.clamp(fpVibDepth, 0.2, 1.5) or 1
			local fpVibBend = player:GetAttribute("FPVibBend")
			v17 = typeof(fpVibBend) == "number"
				and math.clamp(fpVibBend, -FreePlayVibrato.BEND_MAX, FreePlayVibrato.BEND_MAX)
				or 0
		else
			v15 = FreePlayVibrato.DEFAULT_RATE
			dir = FreePlayVibrato.DIR_SYM
			v14 = false
			v16 = 1
			v17 = 0
		end
	end

	state.Active = v14 == true
	state.Armed = v13 == true

	if v14 then
		state.Env = math.min(1, state.Env + p / 0.25)
		state.Dir = dir
	else
		state.Env = math.max(0, state.Env - p / 0.18)
	end

	state.Rate += (v15 - state.Rate) * math.min(1, p * 8)
	state.Phase = (state.Phase + p * 6.283185307179586 * state.Rate) % 6.283185307179586
	state.DepthMul += ((v16 or 1) - state.DepthMul) * math.min(1, p * 6)

	if math.abs(v17) < math.abs(state.Bend) then
		v18 = 7
	end

	state.Bend += (v17 - state.Bend) * math.min(1, p * v18)

	if math.abs(state.Bend) < 0.01 and v17 == 0 then
		state.Bend = 0
	end
end

local function lfoCents(dir, phase, p) -- 2 equivalent calls inferred from this helper
	if dir == FreePlayVibrato.DIR_UP then
		return (1 - math.cos(phase)) * 24 * p
	end

	return math.sin(phase) * 30 * p
end

local function restoreVoice(k, state) -- 1 equivalent call inferred from this helper
	if state.IsEffect then
		k.Octave = 1
		k.Enabled = false
	else
		k.PlaybackSpeed = state.Base
	end

	state.Applied = false
end

local function stepEffectVoice(k, state, data, p, now)
	if (data.Active and 1 or 0) > state.Env then
		state.Env = math.min(1, state.Env + p / 0.55)
	else
		state.Env = math.max(0, state.Env - p / 0.45)
	end

	local v13 = state.Env * state.Env * (3 - 2 * state.Env)
	local v14 = lfoCents(data.Dir, data.Phase, v13 * 2.6 * data.DepthMul) + data.Bend -- inferred equivalent call

	if data.Armed or data.Active or state.Env > 0 or math.abs(data.Bend) > 0.01 then
		state.KeepUntil = now + 0.9
	end

	local v15 = now < state.KeepUntil

	if v15 then
		k.Octave = 2 ^ (v14 / 1200)
	end

	if k.Enabled ~= v15 then
		k.Enabled = v15

		if not v15 then
			k.Octave = 1
		end
	end

	state.Applied = v15
end

local function step(p)
	total += p

	if total >= 2 then
		total = 0
		local now = os.clock()

		for k, v13 in pairs(v10) do
			if k.Parent or not (now - v13.Born > 1) then
				continue
			end

			v10[k] = nil
		end
	end

	local v13 = false

	for k, v14 in pairs(v11) do
		updateSource(v14, k, p)

		if v14.Env > 0 or v14.Bend ~= 0 or v14.Armed then
			v13 = true
		end
	end

	if not (v13 or v12) then
		return
	end

	local now = os.clock()
	local v14 = false

	for k, v15 in pairs(v10) do
		v15.Age += p

		if k.Parent then
			local v16 = v11[v15.Source]

			if v16 then
				if v15.IsEffect then
					stepEffectVoice(k, v15, v16, p, now)

					if v15.Applied then
						v14 = true
					end
				elseif v16.Env > 0 or v16.Bend ~= 0 or v15.Applied then
					local v17

					if v16.Env > 0 then
						local v18 = v16.Env * v16.Env * (3 - 2 * v16.Env)
						local v19 = math.min(1, v15.Age / 0.15)
						local v20 = v19 * v19 * (3 - v19 * 2)
						v15.Phase = (v15.Phase + p * 6.283185307179586 * v16.Rate * v15.RateMul) % 6.283185307179586
						v15.Wobble = (v15.Wobble + p * 6.283185307179586 * 0.7) % 6.283185307179586
						local v21 = v18 * v20 * v15.DepthMul * v16.DepthMul * v15.PitchScale * (math.sin(v15.Wobble) * 0.1 + 1)
						v17 = lfoCents(v16.Dir, v15.Phase, v21) -- inferred equivalent call
					else
						v17 = 0
					end

					local v18 = v17 + v16.Bend

					if math.abs(v18) < 0.02 then
						if v15.Applied then
							restoreVoice(k, v15) -- inferred equivalent call
						end
					else
						k.PlaybackSpeed = v15.Base * 2 ^ (v18 / 1200)
						v15.Applied = true
					end

					if v15.Applied then
						v14 = true
					end
				end
			end
		elseif v15.Age > 0.5 then
			v10[k] = nil
		end
	end

	v12 = v14
end

local function ensureRunning() -- 1 equivalent call inferred from this helper
	if heartbeatConnection or not RunService:IsClient() then
		return
	end

	if not v11.Local then
		v11.Local = {
			Env = 0,
			Rate = FreePlayVibrato.DEFAULT_RATE,
			Dir = FreePlayVibrato.DIR_SYM,
			Bend = 0,
			Phase = 0,
			DepthMul = 1,
			Player = nil
		}
	end

	heartbeatConnection = RunService.Heartbeat:Connect(step)
end

local function newVoice(p, value, value2, p2)
	if p2 then
		value = 1
	elseif typeof(value) ~= "number" or value <= 0 then
		value = p.PlaybackSpeed
	end

	local base = math.max(value, 0.01)
	local voice = {
		Base = base,
		Source = value2 or "Local",
		IsEffect = p2 == true,
		Phase = math.random() * 6.283185307179586,
		Wobble = math.random() * 6.283185307179586,
		Age = 0,
		Born = os.clock(),
		RateMul = 0.97 + math.random() * 0.06,
		DepthMul = 0.9 + math.random() * 0.2,
		PitchScale = p2 and 1 or math.clamp(1.1 - math.log(base, 2) * 0.35, 0.85, 1.7),
		Applied = false,
		Env = 0,
		KeepUntil = 0
	}

	v10[p] = voice
	local source = voice.Source

	if not v11[source] then
		v11[source] = {
			Env = 0,
			Rate = FreePlayVibrato.DEFAULT_RATE,
			Dir = FreePlayVibrato.DIR_SYM,
			Bend = 0,
			Phase = 0,
			DepthMul = 1,
			Player = nil
		}
	end

	if heartbeatConnection or not RunService:IsClient() then
		return voice
	end

	if not v11.Local then
		v11.Local = {
			Env = 0,
			Rate = FreePlayVibrato.DEFAULT_RATE,
			Dir = FreePlayVibrato.DIR_SYM,
			Bend = 0,
			Phase = 0,
			DepthMul = 1,
			Player = nil
		}
	end

	heartbeatConnection = RunService.Heartbeat:Connect(step)

	return voice
end

function FreePlayVibrato.Register(p, p2, p3)
	if not p then
		return
	end

	newVoice(p, p2, p3, false)
end

function FreePlayVibrato:RegisterEffect(p)
	if not self or v10[self] then
		return
	end

	self.Octave = 1
	self.Enabled = false
	newVoice(self, 1, p, true)
end

function FreePlayVibrato.RegisterLike(p, p2)
	local v13 = v10[p2]

	if not v13 then
		return
	end

	local base = v13.Base
	local v14

	if v13.Source ~= "Local" then
		v14 = v13.Source or nil
	end

	local v15 = newVoice(p, base, v14, false)
	v15.Phase = v13.Phase
	v15.Wobble = v13.Wobble
	v15.Age = v13.Age
	v15.RateMul = v13.RateMul
	v15.DepthMul = v13.DepthMul
end

function FreePlayVibrato.GetBaseSpeed(p)
	local v13 = v10[p]

	return if v13 then v13.Base else p.PlaybackSpeed
end

function FreePlayVibrato.GetLocalWave()
	ensureRunning() -- inferred equivalent call
	local v13 = v11.Local

	if not v13 then
		return 0, 0, direction, 0
	end

	local env = v13.Env
	return env * env * (3 - 2 * env) * math.clamp(v13.DepthMul, 0.3, 1.2), v13.Phase, v13.Dir, v13.Bend
end

return FreePlayVibrato