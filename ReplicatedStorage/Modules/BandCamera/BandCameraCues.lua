local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bandCamera = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BandCamera")
local BandCameraConfig = require(bandCamera:WaitForChild("BandCameraConfig"))
local BandCameraSongConfig = require(bandCamera:WaitForChild("BandCameraSongConfig"))

local shotNameSet = {}
local BandCameraCues = {}

for _, shotName in ipairs(BandCameraConfig.ShotNames) do
	shotNameSet[shotName] = true
end

local v = {
	GuitarLead = true,
	GuitarRhythm = true,
	Bass = true,
	Drum = true,
	Keyboard = true,
	Piano = true,
	BVocal = true
}

local v2 = {}
local v3 = 1
local v4 = {}

local function notifyChanged()
	for _, callback in ipairs(v4) do
		local success, result = pcall(callback)

		if not success then
			warn("[BandCameraCues] listener error:", result)
		end
	end
end

function BandCameraCues.OnChanged(p)
	table.insert(v4, p)
end

function BandCameraCues.ParseTime(value)
	if type(value) == "number" then
		return value
	end

	if type(value) ~= "string" then
		return nil
	end

	local v5 = value:gsub("%s+", "")

	if v5 == "" then
		return nil
	end

	local v6 = {}
	local v7 = 0

	for k in v5:gmatch("[^:]+") do
		local v8 = tonumber(k)

		if not v8 then
			return nil
		end

		v6[#v6 + 1] = v8
	end

	if #v6 == 0 or #v6 > 3 then
		return nil
	end

	for _, v8 in ipairs(v6) do
		v7 = v7 * 60 + v8
	end

	return v7
end

function BandCameraCues.FormatTime(p)
	local v5 = math.max(0, p)
	local v6 = math.floor(v5 / 60)
	local v7 = v5 - v6 * 60
	return string.format("%d:%04.1f", v6, v7)
end

local function normalizeOne(data)
	if type(data) ~= "table" then
		return nil, "bukan tabel"
	end

	local time = BandCameraCues.ParseTime(data.At ~= nil and data.At or data.From)

	if not time or time < 0 then
		return nil, "At/From tidak valid"
	end

	if not shotNameSet[data.Shot] then
		return nil, "Shot tidak dikenal: " .. tostring(data.Shot)
	end

	local to

	if data.To ~= nil then
		to = BandCameraCues.ParseTime(data.To)

		if not to or to <= time then
			return nil, "To tidak valid"
		end
	end

	if data.Target ~= nil and not v[data.Target] then
		return nil, "Target tidak dikenal: " .. tostring(data.Target)
	end

	local targets

	if type(data.Targets) == "table" then
		targets = {}

		for _, target in ipairs(data.Targets) do
			if v[target] then
				targets[#targets + 1] = target
			end
		end

		if #targets == 0 then
			targets = nil
		end
	end

	local dir = data.Dir == -1 and -1 or data.Dir == 1 and 1 or nil
	local variant

	if data.Variant == "foot" or data.Variant == "front" or data.Variant == "overhead" or data.Variant == "side" then
		variant = data.Variant
	end

	local shake

	if data.Shake == true or data.Shake == false then
		shake = data.Shake
	end

	local v5 = {
		From = time,
		To = to,
		Shot = data.Shot,
		Target = data.Target,
		Targets = targets,
		Dir = dir,
		Style = 0,
		Variant = 0,
		Shake = 0
	}
	local style

	if type(data.Style) == "string" then
		style = data.Style or nil
	end

	v5.Style = style
	v5.Variant = variant
	v5.Shake = shake
	return v5
end

function BandCameraCues.Get(p)
	local ones = {}
	local song = BandCameraSongConfig.Songs[p]

	if song and type(song.Cues) == "table" then
		for i, cue in ipairs(song.Cues) do
			local one, v5 = normalizeOne(cue)

			if one then
				ones[#ones + 1] = one
			else
				warn(("[BandCameraCues] Cue #%d lagu '%s' dilewati: %s"):format(i, tostring(p), (tostring(v5))))
			end
		end
	end

	for _, v5 in ipairs(v2[p] or {}) do
		local one = normalizeOne(v5.cue)

		if not one then
			continue
		end

		for i = #ones, 1, -1 do
			if math.abs(ones[i].From - one.From) < 0.05 then
				table.remove(ones, i)
			end
		end

		ones[#ones + 1] = one
	end

	table.sort(ones, function(a, b): boolean
		return a.From < b.From
	end)

	for i, v5 in ipairs(ones) do
		if not v5.To then
			v5.To = ones[i + 1] and ones[i + 1].From or v5.From + BandCameraConfig.CueDefaultSeconds
		end
	end

	return ones
end

function BandCameraCues.AddLive(p, cue)
	local one, v5 = normalizeOne(cue)

	if not one then
		return nil, v5
	end

	v2[p] = v2[p] or {}

	for i = #v2[p], 1, -1 do
		local one2 = normalizeOne(v2[p][i].cue)

		if one2 and math.abs(one2.From - one.From) < 0.05 then
			table.remove(v2[p], i)
		end
	end

	local id = v3
	v3 += 1
	table.insert(v2[p], { id = id, cue = cue })
	notifyChanged()
	return id
end

function BandCameraCues.RemoveLive(p, p2): boolean
	local v5 = v2[p]

	if not v5 then
		return false
	end

	for i, v6 in ipairs(v5) do
		if v6.id == p2 then
			table.remove(v5, i)
			notifyChanged()
			return true
		end
	end

	return false
end

function BandCameraCues.ListForUI(p)
	local v5 = BandCameraCues.Get(p)
	local v6 = {}
	local result = {}

	for _, v7 in ipairs(v2[p] or {}) do
		local one = normalizeOne(v7.cue)

		if one then
			v6[#v6 + 1] = { id = v7.id, from = one.From }
		end
	end

	for _, cue in ipairs(v5) do
		local id = nil

		for _, v7 in ipairs(v6) do
			if math.abs(v7.from - cue.From) < 0.05 then
				id = v7.id
			end
		end

		result[#result + 1] = { id = id, cue = cue }
	end

	return result
end

return BandCameraCues