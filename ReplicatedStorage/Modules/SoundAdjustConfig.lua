local HttpService = game:GetService("HttpService")

local SoundAdjustConfig = {}
SoundAdjustConfig.ATTR = "SoundAdjustCfg"
SoundAdjustConfig.EMPTY_RESET_SECONDS = 3
SoundAdjustConfig.REVERB_DECAY = 2.5
SoundAdjustConfig.KEYS = { "vol", "bass", "rev" }

local ranges = {
	vol = { 0, 200, 10 },
	bass = { -10, 10, 1 },
	rev = { 0, 100, 5 }
}

SoundAdjustConfig.RANGES = ranges

function SoundAdjustConfig.Default()
	return { vol = 100, bass = 0, rev = 0 }
end

local function cleanNumber(p) -- 1 equivalent call inferred from this helper
	local v = tonumber(p)

	if v == nil or v ~= v or v == 1e999 or v == -1e999 then
		return nil
	end

	return v
end

function SoundAdjustConfig.Quantize(p, p2)
	local v = ranges[p]

	if not v then
		return nil
	end

	local v2 = cleanNumber(p2) -- inferred equivalent call

	if v2 == nil then
		return nil
	end

	return (math.clamp(v[1] + math.floor((v2 - v[1]) / v[3] + 0.5) * v[3], v[1], v[2]))
end

function SoundAdjustConfig:Apply(p, p2): boolean
	local quantize = SoundAdjustConfig.Quantize(p, p2)

	if quantize == nil or self[p] == quantize then
		return false
	end

	self[p] = quantize
	return true
end

function SoundAdjustConfig.IsDefault(p): boolean
	local default = SoundAdjustConfig.Default()

	for _, v in ipairs(SoundAdjustConfig.KEYS) do
		if p[v] ~= default[v] then
			return false
		end
	end

	return true
end

function SoundAdjustConfig.Encode(p)
	local v = {}

	for _, v2 in ipairs(SoundAdjustConfig.KEYS) do
		v[v2] = p[v2]
	end

	return HttpService:JSONEncode(v)
end

function SoundAdjustConfig.Decode(value)
	local default = SoundAdjustConfig.Default()

	if type(value) ~= "string" or value == "" then
		return default
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, value)

	if not success or type(result) ~= "table" then
		return default
	end

	for _, v in ipairs(SoundAdjustConfig.KEYS) do
		if result[v] ~= nil then
			SoundAdjustConfig.Apply(default, v, result[v])
		end
	end

	return default
end

function SoundAdjustConfig.StepCount(p)
	local v = ranges[p]
	return (v[2] - v[1]) / v[3] + 1
end

function SoundAdjustConfig.ToIndex(p, p2)
	local v = ranges[p]
	return math.floor((p2 - v[1]) / v[3] + 0.5) + 1
end

function SoundAdjustConfig.FromIndex(p, p2)
	local v = ranges[p]
	return v[1] + (p2 - 1) * v[3]
end

function SoundAdjustConfig.Step(p)
	return ranges[p][3]
end

function SoundAdjustConfig.Format(p, p2)
	if p ~= "bass" then
		return string.format("%d%%", p2)
	end

	if p2 > 0 then
		return string.format("+%d dB", p2)
	end

	return string.format("%d dB", p2)
end

function SoundAdjustConfig.ReverbWetDb(p)
	if p <= 0 then
		return -80
	end

	return -40 + 36 * (p / 100)
end

SoundAdjustConfig.PRESETS = {
	{
		id = "flat",
		name = "Flat",
		vol = 100,
		bass = 0,
		rev = 0
	},
	{
		id = "bass",
		name = "Bass Boost",
		vol = 100,
		bass = 6,
		rev = 0
	},
	{
		id = "hall",
		name = "Live Hall",
		vol = 100,
		bass = 2,
		rev = 60
	},
	{
		id = "studio",
		name = "Studio",
		vol = 100,
		bass = 2,
		rev = 0
	}
}

function SoundAdjustConfig.FindPreset(value)
	if type(value) ~= "string" then
		return nil
	end

	for _, v in ipairs(SoundAdjustConfig.PRESETS) do
		if v.id == value then
			return v
		end
	end

	return nil
end

function SoundAdjustConfig.MatchPreset(data)
	for _, v in ipairs(SoundAdjustConfig.PRESETS) do
		if data.vol == v.vol and data.bass == v.bass and data.rev == v.rev then
			return v
		end
	end

	return nil
end

return SoundAdjustConfig