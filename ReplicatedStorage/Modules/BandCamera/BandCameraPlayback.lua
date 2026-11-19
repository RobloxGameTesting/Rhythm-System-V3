local BandCameraPlayback = {}

local BandCameraTakes = require(script.Parent:WaitForChild("BandCameraTakes"))

local v = {}
local v2 = {}

local function notifyChanged()
	for _, callback in ipairs(v2) do
		local success, result = pcall(callback)

		if not success then
			warn("[BandCameraPlayback] listener error:", result)
		end
	end
end

function BandCameraPlayback.OnChanged(p)
	table.insert(v2, p)
end

function BandCameraPlayback.AddLiveTake(p, p2, p3)
	v[p] = v[p] or {}
	v[p][p2] = v[p][p2] or {}
	v[p][p2][p3.Name] = p3
	notifyChanged()
end

function BandCameraPlayback.RemoveLiveTake(p, p2, p3): boolean
	local v3 = v[p] and v[p][p2]

	if v3 and v3[p3] then
		v3[p3] = nil
		notifyChanged()
		return true
	end

	return false
end

function BandCameraPlayback.ListTakes(p, p2)
	local v3 = {}
	local v4 = BandCameraTakes[p] and BandCameraTakes[p][p2]

	if type(v4) == "table" then
		for _, take in ipairs(v4) do
			if not (type(take) == "table" and type(take.Keys) == "table" and #take.Keys > 0) then
				continue
			end

			v3[take.Name] = { take = take, isLive = false }
		end
	end

	local v5 = v[p] and v[p][p2]

	if v5 then
		for k, take in pairs(v5) do
			v3[k] = { take = take, isLive = true }
		end
	end

	local result = {}

	for _, v6 in pairs(v3) do
		result[#result + 1] = v6
	end

	table.sort(result, function(a, b): boolean
		if a.take.Start == b.take.Start then
			return a.take.Name < b.take.Name
		end

		return a.take.Start < b.take.Start
	end)

	return result
end

function BandCameraPlayback.GetClips(p, p2)
	local listTakes = BandCameraPlayback.ListTakes(p, p2)

	if #listTakes == 0 then
		return nil
	end

	local takes = {}

	for _, listTake in ipairs(listTakes) do
		takes[#takes + 1] = listTake.take
	end

	return takes
end

local function keyPos(key) -- 4 equivalent calls inferred from this helper
	return (Vector3.new(key[2], key[3], key[4]))
end

local function keyRot(key) -- 2 equivalent calls inferred from this helper
	return CFrame.new(0, 0, 0, key[5], key[6], key[7], key[8], key[9], key[10], key[11], key[12], key[13])
end

local function keyCF(list) -- 2 equivalent calls inferred from this helper
	return CFrame.new(
		list[2],
		list[3],
		list[4],
		list[5],
		list[6],
		list[7],
		list[8],
		list[9],
		list[10],
		list[11],
		list[12],
		list[13]
	)
end

local function catmullRom(p, p2, p3, p4, p5) -- 1 equivalent call inferred from this helper
	local v3 = p5 * p5
	local v4 = p5 * p5 * p5
	return 0.5 * (2 * p2 + (-p + p3) * p5 + (2 * p - 5 * p2 + 4 * p3 - p4) * v3 + (-p + 3 * p2 - 3 * p3 + p4) * v4)
end

function BandCameraPlayback.SampleClip(p, p2)
	local keys = p.Keys
	local count = #keys

	if count == 0 then
		return nil
	end

	if count == 1 or p2 <= keys[1][1] then
		return keyCF(keys[1]), keys[1][14] -- inferred equivalent call
	end

	if keys[count][1] <= p2 then
		return keyCF(keys[count]), keys[count][14] -- inferred equivalent call
	end

	local v3 = count - 1
	local v4 = 1

	while v4 < v3 do
		local v5 = (v4 + v3 + 1) // 2

		if keys[v5][1] <= p2 then
			v4 = v5
		else
			v3 = v5 - 1
		end
	end

	local key = keys[math.max(1, v4 - 1)]
	local key2 = keys[v4]
	local key3 = keys[v4 + 1]
	local key4 = keys[math.min(count, v4 + 2)]
	local v5 = key3[1] - key2[1]
	local v6 = v5 > 1e-6 and (p2 - key2[1]) / v5 or 0
	local v7 = catmullRom(keyPos(key), keyPos(key2), keyPos(key3), keyPos(key4), v6) -- inferred equivalent call
	local lerped = keyRot(key2):Lerp(keyRot(key3), v6) -- inferred equivalent call
	return CFrame.new(v7) * lerped, key2[14] + (key3[14] - key2[14]) * v6
end

function BandCameraPlayback.Pose(list, p, p2)
	local v3 = nil

	for i, item in ipairs(list) do
		if item.Start <= p then
			v3 = i
		else
			break
		end
	end

	local item = list[v3 or 1]
	local v4 = v3 and p - item.Start or 0
	local clip, v5 = BandCameraPlayback.SampleClip(item, v4)
	return p2 * clip, v5
end

function BandCameraPlayback.PoseIfActive(list, p, p2)
	for _, item in ipairs(list) do
		if not (item.Start <= p and p <= item.Start + item.Duration) then
			continue
		end

		local clip, v3 = BandCameraPlayback.SampleClip(item, p - item.Start)

		if clip then
			return p2 * clip, v3
		end
	end

	return nil
end

local function round(p, p2) -- 14 equivalent calls inferred from this helper
	local v3 = 10 ^ p2
	return math.floor(p * v3 + 0.5) / v3
end

local function toKey(p, cf, fov)
	local components, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13 = cf:GetComponents()
	return {
		round(p, 3), -- inferred equivalent call
		round(components, 3), -- inferred equivalent call
		round(v3, 3), -- inferred equivalent call
		round(v4, 3), -- inferred equivalent call
		round(v5, 4), -- inferred equivalent call
		round(v6, 4), -- inferred equivalent call
		round(v7, 4), -- inferred equivalent call
		round(v8, 4), -- inferred equivalent call
		round(v9, 4), -- inferred equivalent call
		round(v10, 4), -- inferred equivalent call
		round(v11, 4), -- inferred equivalent call
		round(v12, 4), -- inferred equivalent call
		round(v13, 4), -- inferred equivalent call
		round(fov, 2) -- inferred equivalent call
	}
end

function BandCameraPlayback.BuildKeys(list)
	local count = #list

	if count == 0 then
		return {}, 0
	end

	local t = list[1].t
	local v3 = list[count].t - t

	if count == 1 or v3 <= 0.0001 then
		return { toKey(0, list[1].cf, list[1].fov) }, 0
	end

	local v4 = math.max(1, (math.floor(v3 / 0.05 + 0.5)))
	local v5 = 1
	local v6 = {}

	for i = 0, v4 do
		local v7 = math.min(v3, i * 0.05)

		if i == v4 then
			v7 = v3
		end

		local v8 = t + v7

		while v5 < count - 1 and list[v5 + 1].t <= v8 do
			v5 += 1
		end

		local item = list[v5]
		local item2 = list[math.min(v5 + 1, count)]
		local v9 = item2.t - item.t
		local v10 = v9 > 1e-6 and math.clamp((v8 - item.t) / v9, 0, 1) or 0
		v6[#v6 + 1] = {
			t = v7,
			cf = item.cf:Lerp(item2.cf, v10),
			fov = item.fov + (item2.fov - item.fov) * v10
		}
	end

	local count2 = #v6
	local v7 = 1
	local v8 = { 1 }

	for i = 3, count2 do
		local v9 = v6[v7]
		local v10 = v6[i]

		local v11 = v10.t - v9.t
		local v12 = true

		for j = v7 + 1, i - 1 do
			local v13 = v6[j]
			local v14 = v11 > 1e-6 and (v13.t - v9.t) / v11 or 0
			local lerped = v9.cf:Lerp(v10.cf, v14)
			local _, v15 = (lerped.Rotation:Inverse() * v13.cf.Rotation):ToAxisAngle()

			if
				(lerped.Position - v13.cf.Position).Magnitude > 0.04
				or math.abs(v15) > 0.004363323129985824
				or math.abs(v9.fov + (v10.fov - v9.fov) * v14 - v13.fov) > 0.15
			then
				v12 = false
				break
			end
		end

		if v12 then
			continue
		end

		v8[#v8 + 1] = i - 1
		v7 = i - 1
	end

	if v8[#v8] ~= count2 then
		v8[#v8 + 1] = count2
	end

	local result = table.create(#v8)

	for _, v9 in ipairs(v8) do
		local v10 = v6[v9]
		result[#result + 1] = toKey(v10.t, v10.cf, v10.fov)
	end

	return result, v3
end

return BandCameraPlayback