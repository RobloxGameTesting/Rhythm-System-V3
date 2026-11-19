local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FreePlayVibrato = require(ReplicatedStorage.Modules.FreePlayVibrato)

local v = false
local lastTime = 0
local RhythmVibratoFx = {}

function RhythmVibratoFx.ReportHold(p)
	v = p == true
	lastTime = os.clock()
end

function RhythmVibratoFx.IsHolding()
	return v and os.clock() - lastTime < 0.25
end

function RhythmVibratoFx.GetWave()
	local localWave, v2, v3, v4 = FreePlayVibrato.GetLocalWave()
	return localWave, v2, v3, (math.clamp(v4 / FreePlayVibrato.BEND_MAX, -1, 1))
end

function RhythmVibratoFx.IsWaving(p, p2): boolean
	return p > 0.01 or math.abs(p2) > 0.01
end

local function smoothstep(value) -- 1 equivalent call inferred from this helper
	local v2 = math.clamp(value, 0, 1)
	return v2 * v2 * (3 - 2 * v2)
end

function RhythmVibratoFx.Offset(value, p, p2, p3, p4)
	local v2 = smoothstep(value / 0.22) -- inferred equivalent call
	local now = os.clock()
	local v3 = math.noise(value * 1.6, now * 0.7, 0.37) * 2.4
	local v4 = math.clamp(0.95 + 0.9 * math.noise(value * 2.3 + 5.1, now * 1.1, 1.9), 0.4, 1.5)
	local v5 = p2 - value * 1.25 * 6.283185307179586 + v3
	local v6

	if p3 == FreePlayVibrato.DIR_UP then
		v6 = p * 0.5 * (1 - math.cos(v5)) * 1.1
	else
		v6 = p * math.sin(v5)
	end

	return (math.clamp(
		(v6 * v4 * 0.5 + p4 * math.sin(math.clamp(value, 0, 1) * 3.141592653589793 * 0.5) * 0.8) * v2,
		-1.2,
		1.2
	))
end

function RhythmVibratoFx.Pulse(p, p2)
	return p * (math.sin(p2) * 0.5 + 0.5)
end

return RhythmVibratoFx