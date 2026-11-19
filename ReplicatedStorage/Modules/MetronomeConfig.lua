local HttpService = game:GetService("HttpService")

local MetronomeConfig = {}
MetronomeConfig.MIN_BPM = 30
MetronomeConfig.MAX_BPM = 300
MetronomeConfig.GAIN = 1.5
MetronomeConfig.START_LEAD = 0.6
MetronomeConfig.STOP_EMPTY_SECONDS = 30
MetronomeConfig.SOUNDS = {
	click1 = { name = "Click 1", assetId = "rbxassetid://126224146490525" },
	click2 = { name = "Click 2", assetId = "rbxassetid://7486469273" }
}

MetronomeConfig.SOUND_ORDER = { "click1", "click2" }

MetronomeConfig.SIGNATURES = { "2/4", "3/4", "4/4", "5/4", "6/8", "7/8" }

MetronomeConfig.SIG_INFO = {
	["2/4"] = {
		beats = 2,
		groups = { 1 }
	},
	["3/4"] = {
		beats = 3,
		groups = { 1 }
	},
	["4/4"] = {
		beats = 4,
		groups = { 1 }
	},
	["5/4"] = {
		beats = 5,
		groups = { 1, 4 }
	},
	["6/8"] = {
		beats = 6,
		groups = { 1, 4 }
	},
	["7/8"] = {
		beats = 7,
		groups = { 1, 3, 5 }
	}
}

MetronomeConfig.SUBDIVISIONS = { 1, 2, 3, 4 }
MetronomeConfig.SUB_NAMES = { "Off (beat)", "Eighth", "Triplet", "Sixteenth" }
MetronomeConfig.VOLUME_STEPS = {
	10,
	20,
	30,
	40,
	50,
	60,
	70,
	80,
	90,
	100
}
MetronomeConfig.COUNT_IN_STEPS = { 0, 1, 2 }

local v = { "bpm", "sig", "snd", "vol", "sub", "cin" }

function MetronomeConfig.Default()
	return {
		on = false,
		bpm = 100,
		sig = "4/4",
		snd = "click1",
		vol = 80,
		sub = 1,
		cin = 0,
		t0 = 0
	}
end

local function cleanNumber(p) -- 3 equivalent calls inferred from this helper
	local v2 = tonumber(p)

	if v2 == nil or v2 ~= v2 or v2 == 1e999 or v2 == -1e999 then
		return nil
	end

	return v2
end

function MetronomeConfig:Apply(p, value): boolean
	if p == "bpm" then
		local v2 = cleanNumber(value) -- inferred equivalent call

		if not v2 then
			return false
		end

		local bpm = math.clamp(math.floor(v2 + 0.5), MetronomeConfig.MIN_BPM, MetronomeConfig.MAX_BPM)

		if bpm == self.bpm then
			return false
		end

		self.bpm = bpm
		return true
	elseif p == "sig" then
		if type(value) ~= "string" or MetronomeConfig.SIG_INFO[value] == nil or value == self.sig then
			return false
		end

		self.sig = value
		return true
	elseif p == "snd" then
		if type(value) ~= "string" or MetronomeConfig.SOUNDS[value] == nil or value == self.snd then
			return false
		end

		self.snd = value
		return true
	elseif p == "vol" then
		local v2 = cleanNumber(value) -- inferred equivalent call

		if not v2 then
			return false
		end

		local vol = math.clamp(math.floor(v2 / 10 + 0.5) * 10, 10, 100)

		if vol == self.vol then
			return false
		end

		self.vol = vol
		return true
	else
		if p == "sub" then
			if table.find(MetronomeConfig.SUBDIVISIONS, value) == nil or value == self.sub then
				return false
			end

			self.sub = value
		else
			if p ~= "cin" or (table.find(MetronomeConfig.COUNT_IN_STEPS, value) == nil or value == self.cin) then
				return false
			end

			self.cin = value
		end

		return true
	end
end

function MetronomeConfig.Encode(p)
	local v2 = {
		on = p.on == true,
		t0 = string.format("%.4f", p.t0 or 0)
	}

	for _, v3 in ipairs(v) do
		v2[v3] = p[v3]
	end

	return HttpService:JSONEncode(v2)
end

function MetronomeConfig.Decode(value)
	local default = MetronomeConfig.Default()

	if type(value) ~= "string" or value == "" then
		return default
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, value)

	if not success or type(result) ~= "table" then
		return default
	end

	for _, v2 in ipairs(v) do
		if result[v2] ~= nil then
			MetronomeConfig.Apply(default, v2, result[v2])
		end
	end

	default.on = result.on == true
	local t0 = cleanNumber(result.t0) -- inferred equivalent call

	if t0 then
		default.t0 = t0
	end

	return default
end

function MetronomeConfig.TickInfo(data, p): nil | string
	local v2 = MetronomeConfig.SIG_INFO[data.sig] or MetronomeConfig.SIG_INFO["4/4"]
	local sub = data.sub
	local v3 = p // sub
	local v4 = p % sub
	local v5 = v3 // v2.beats
	local v6 = v3 % v2.beats + 1

	if v4 == 0 then
		if v6 == 1 then
			return "down"
		end

		return if table.find(v2.groups, v6) then "group" else "beat"
	else
		return if not (v5 < data.cin) then "sub" else nil
	end
end

return MetronomeConfig