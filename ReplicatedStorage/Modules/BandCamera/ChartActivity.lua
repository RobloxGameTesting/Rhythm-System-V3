local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChartData = Modules:WaitForChild("ChartData")
local SongConfig = Modules:WaitForChild("SongConfig")
local BandCameraConfig = require(Modules:WaitForChild("BandCamera"):WaitForChild("BandCameraConfig"))

local v = { "GuitarLead", "GuitarRhythm", "Bass", "Drum", "Keyboard", "Piano" }

local v2 = { HiTom = true, MidTom = true, FloorTom = true }

local v3 = {
	Snare = true,
	HiHat = true,
	Ride = true,
	HiTom = true,
	MidTom = true,
	FloorTom = true
}
local v4 = {
	{ "Snare", "HiTom", "MidTom", "FloorTom" },
	{ "HiHat" },
	{ "Ride" }
}

local v5 = {}
local v6 = {}

local function getShift(p, p2) -- 1 equivalent call inferred from this helper
	if not p then
		return 0
	end

	local offset = p.Offset or 0

	if type(p.InstrumentOffsets) == "table" then
		offset += p.InstrumentOffsets[p2] or 0
	end

	return if math.abs(offset) < 1 then 0 else offset
end

local function collapse(list, p, p2)
	local v7 = {}

	for _, item in ipairs(list) do
		if not (type(item) == "table" and type(item.Time) == "number") then
			continue
		end

		v7[#v7 + 1] = item
	end

	table.sort(v7, function(a, b): boolean
		return a.Time < b.Time
	end)
	local v8 = nil
	local result = {}
	local result2 = {}
	local result3 = {}
	local v9 = nil
	local result4 = {}

	for _, v10 in ipairs(v7) do
		local v11 = v10.Time - p

		if not (v11 >= 0) then
			continue
		end

		if not v8 or v11 - v8 > 0.03 then
			result[#result + 1] = v11
			v8 = v11
		end

		if p2 and v3[v10.ReactionType] then
			local v12 = result2[v10.ReactionType]

			if not v12 then
				v12 = {}
				result2[v10.ReactionType] = v12
			end

			v12[#v12 + 1] = v11
		end

		if p2 and v2[v10.ReactionType] then
			result3[#result3 + 1] = v11
		end

		if not (p2 and v10.ReactionType == "Kick" and (not v9 or v11 - v9 > 0.03)) then
			continue
		end

		result4[#result4 + 1] = v11
		v9 = v11
	end

	return result, result3, result4, result2
end

local function buildData(childName)
	local success, result = pcall(require, SongConfig)
	local v7

	if success and type(result) == "table" and result.Songs then
		v7 = result.Songs[childName]
	end

	local data = {
		events = {},
		firstNote = nil,
		lastNote = 0,
		counts = {},
		nW = 1,
		window = 2,
		solos = {},
		duos = {},
		fills = {},
		intense = {},
		surges = {},
		kicks = {},
		kickBursts = {},
		padRolls = {},
		entries = {}
	}

	local child = ChartData:FindFirstChild(childName)

	if not child then
		return data
	end

	local success2, result2 = pcall(require, child)

	if not success2 or type(result2) ~= "table" then
		return data
	end

	local v8 = {}
	local kicks = {}
	local v9 = {}

	for _, v10 in ipairs(v) do
		local v11 = result2[v10]

		if type(v11) == "table" and #v11 > 0 then
			local v12, v13, v14, v15 = collapse(v11, getShift(v7, v10), v10 == "Drum") -- inferred equivalent call

			if #v12 > 0 then
				data.events[v10] = v12

				if not data.firstNote or v12[1] < data.firstNote then
					data.firstNote = v12[1]
				end

				if v12[#v12] > data.lastNote then
					data.lastNote = v12[#v12]
				end
			end

			if v10 == "Drum" then
				v9 = v15
				kicks = v14
				v8 = v13
			end
		end

		task.wait()
	end

	local nW = math.max(1, (math.ceil((data.lastNote + 0.001) / 2)))
	data.nW = nW
	local v10 = {}

	for k, list in pairs(data.events) do
		v10[#v10 + 1] = k
		local v11 = table.create(nW, 0)

		for _, item in ipairs(list) do
			local v12 = math.clamp(math.floor(item / 2) + 1, 1, nW)
			v11[v12] += 1
		end

		data.counts[k] = v11
	end

	if #v10 >= 2 then
		local v11 = {}

		for _, v12 in ipairs(v10) do
			v11[#v11 + 1] = data.events[v12][1]
		end

		table.sort(v11)

		local v12 = not (v11[2] - v11[1] >= 4) and 0 or v11[2]

		local src = nil
		local t0 = nil
		local t1 = nil
		local function flush() -- 4 equivalent calls inferred from this helper
			if src and t1 - t0 >= 6 then
				data.solos[#data.solos + 1] = { t0 = t0, t1 = t1, src = src }
			end

			src = nil
		end

		for i = 1, nW do
			local v13 = (i - 1) * 2
			local v14 = i * 2

			if v14 <= v12 then
				flush() -- inferred equivalent call
			else
				local count = 0
				local v15 = nil

				for _, v16 in ipairs(v10) do
					if not (data.counts[v16][i] > 0) then
						continue
					end

					count += 1
					v15 = v16
				end

				if count == 1 then
					if src ~= v15 then
						flush() -- inferred equivalent call
						src = v15
						t0 = math.max(v13, v12)
					end

					t1 = v14
				else
					flush() -- inferred equivalent call
				end
			end
		end

		flush() -- inferred equivalent call
		local v13 = nil
		local t0_2 = nil
		local t1_2 = nil
		local targets = nil
		local function flushDuo() -- 4 equivalent calls inferred from this helper
			if v13 and t1_2 - t0_2 >= 6 then
				data.duos[#data.duos + 1] = { t0 = t0_2, t1 = t1_2, targets = targets }
			end

			v13 = nil
		end

		for i = 1, nW do
			local v14 = (i - 1) * 2
			local v15 = i * 2

			if v15 <= v12 then
				flushDuo() -- inferred equivalent call
			else
				local v16 = {}

				for _, v17 in ipairs(v10) do
					if data.counts[v17][i] > 0 then
						v16[#v16 + 1] = v17
					end
				end

				if #v16 == 2 then
					table.sort(v16)
					local v17 = v16[1] .. "+" .. v16[2]

					if v13 == v17 then
						t1_2 = v15
					else
						flushDuo() -- inferred equivalent call
						v13 = v17
						t0_2 = math.max(v14, v12)
						t1_2 = v15
						targets = { v16[1], v16[2] }
					end
				else
					flushDuo() -- inferred equivalent call
				end
			end
		end

		flushDuo() -- inferred equivalent call
	end

	local v11 = 1

	while v11 <= #v8 do
		local v12 = v11

		while v12 < #v8 and v8[v12 + 1] - v8[v12] <= 0.65 do
			v12 += 1
		end

		local v13 = v12 - v11 + 1
		local v14 = v8[v12] - v8[v11]

		if v13 >= 4 and v14 <= 6 then
			data.fills[#data.fills + 1] = {
				t0 = math.max(0, v8[v11] - 0.3),
				t1 = v8[v12] + 0.6,
				src = "Drum"
			}
		end

		v11 = v12 + 1
	end

	data.kicks = kicks
	local v12 = 1
	local kickBursts = {}

	while v12 <= #kicks do
		local v13 = v12

		while v13 < #kicks and kicks[v13 + 1] - kicks[v13] <= 0.26 do
			v13 += 1
		end

		if v13 - v12 + 1 >= 5 and kicks[v13] - kicks[v12] >= 0.6 then
			local v14 = kickBursts[#kickBursts]

			if v14 and kicks[v12] - v14.t1 <= 0.8 then
				v14.t1 = kicks[v13]
				v14.count += v13 - v12 + 1
			else
				kickBursts[#kickBursts + 1] = {
					t0 = kicks[v12],
					t1 = kicks[v13],
					count = v13 - v12 + 1
				}
			end
		end

		v12 = v13 + 1
	end

	data.kickBursts = kickBursts

	local v13 = {}

	for _, list in ipairs(v4) do
		local v14 = {}

		for _, item in ipairs(list) do
			for _, v15 in ipairs(v9[item] or {}) do
				v14[#v14 + 1] = { t = v15, pad = item }
			end
		end

		table.sort(v14, function(a, b): boolean
			if a.t == b.t then
				return a.pad < b.pad
			end

			return a.t < b.t
		end)

		local count = #v14
		local v15 = {}

		for i = 2, count do
			local v16 = v14[i].t - v14[i - 1].t

			if v16 > 0.005 then
				v15[#v15 + 1] = v16
			end
		end

		table.sort(v15)
		local v16 = math.min(0.16, (v15[math.ceil(#v15 / 2)] or 0) * 0.6)
		local v17 = {}

		for i = 1, count do
			local v18 = i > 1 and v14[i].t - v14[i - 1].t or 1e999
			local v19 = i < count and v14[i + 1].t - v14[i].t or 1e999
			local v20

			if v18 > 0.005 and v18 <= v16 then
				v20 = true
			elseif v19 > 0.005 then
				v20 = v19 <= v16
			else
				v20 = false
			end

			v17[i] = v20
		end

		local v18 = 1

		while v18 <= count do
			if v17[v18] then
				local v19 = v18 + 1
				local v20 = v18
				local v21 = 1

				while v19 <= count and v14[v19].t - v14[v20].t <= 0.3 do
					if v17[v19] then
						v21 += 1
						v20 = v19
					end

					v19 += 1
				end

				if v21 >= 6 and v14[v20].t - v14[v18].t >= 0.45 then
					local hits = {}

					for i = v18, v20 do
						hits[#hits + 1] = v14[i]
					end

					v13[#v13 + 1] = { t0 = v14[v18].t, t1 = v14[v20].t, hits = hits }
				end

				v18 = v20 + 1
			else
				v18 += 1
			end
		end
	end

	table.sort(v13, function(a, b): boolean
		return a.t0 < b.t0
	end)

	local v14 = {}

	for _, v15 in ipairs(v13) do
		local v16 = v14[#v14]

		if v16 and v15.t0 - v16.t1 <= 0.45 then
			v16.t1 = math.max(v16.t1, v15.t1)

			for _, hit in ipairs(v15.hits) do
				v16.hits[#v16.hits + 1] = hit
			end
		else
			v14[#v14 + 1] = v15
		end
	end

	local padRolls = {}

	for _, v15 in ipairs(v14) do
		table.sort(v15.hits, function(a, b): boolean
			if a.t == b.t then
				return a.pad < b.pad
			end

			return a.t < b.t
		end)

		local v16 = {}
		local v17 = 0
		local pad = nil

		for _, hit in ipairs(v15.hits) do
			v16[hit.pad] = (v16[hit.pad] or 0) + 1

			if not (v17 < v16[hit.pad] or v16[hit.pad] == v17 and pad and hit.pad < pad) then
				continue
			end

			v17 = v16[hit.pad]
			pad = hit.pad
		end

		padRolls[#padRolls + 1] = {
			pad = pad,
			t0 = v15.t0,
			t1 = v15.t1,
			count = #v15.hits,
			hits = v15.hits
		}
	end

	data.padRolls = padRolls

	local entryGapSeconds = BandCameraConfig.Moments.EntryGapSeconds
	local entries = {}

	for k, event in pairs(data.events) do
		local v15 = 0

		for i = 1, #event do
			local v16 = event[i]

			if entryGapSeconds <= v16 - v15 then
				local count = 0

				for j = i, #event do
					if event[j] - v16 > 4 then
						break
					end

					count += 1
				end

				if count >= 4 then
					entries[#entries + 1] = {
						t = v16,
						instr = k,
						gap = v16 - v15
					}
				end
			end

			v15 = v16
		end
	end

	table.sort(entries, function(a, b): boolean
		if a.t == b.t then
			return a.instr < b.instr
		end

		return a.t < b.t
	end)

	data.entries = entries

	local v15 = math.max(1, (math.ceil((data.lastNote + 0.001) / 4)))
	local v16 = table.create(v15, 0)
	local count = 0
	local count2 = 0

	for _, list in pairs(data.events) do
		for _, item in ipairs(list) do
			local v17 = math.clamp(math.floor(item / 4) + 1, 1, v15)
			v16[v17] += 1
			count += 1
		end
	end

	for i = 1, v15 do
		if v16[i] > 0 then
			count2 += 1
		end
	end

	local v17 = count2 > 0 and count / count2 or 0

	if v17 > 0 then
		local v18 = nil
		local function flushIntense(p) -- 2 equivalent calls inferred from this helper
			if v18 then
				local t0 = (v18 - 1) * 4
				local t1 = p * 4

				if t1 - t0 >= 8 then
					data.intense[#data.intense + 1] = { t0 = t0, t1 = t1 }
				end

				v18 = nil
			end
		end

		for i = 1, v15 do
			local v19 = v16[i]

			if v17 * 1.3 <= v19 then
				v18 = v18 or i
			else
				flushIntense(i - 1) -- inferred equivalent call
			end
		end

		flushIntense(v15) -- inferred equivalent call
	end

	local v18 = math.max(1, (math.ceil((data.lastNote + 0.001) / 4)))
	local v19 = {}
	local v20 = {}
	local v21 = {}

	for k, list in pairs(data.events) do
		local v22 = table.create(v18, 0)

		for _, item in ipairs(list) do
			local v23 = math.clamp(math.floor(item / 4) + 1, 1, v18)
			v22[v23] += 1
		end

		local total = 0
		local count3 = 0

		for i = 1, v18 do
			if not (v22[i] > 0) then
				continue
			end

			total += v22[i]
			count3 += 1
		end

		if not (count3 > 0) then
			continue
		end

		v19[k] = v22
		v20[k] = total / count3
		v21[#v21 + 1] = k
	end

	table.sort(v21)

	if not (#v21 >= 2) then
		return data
	end

	for _, src in ipairs(v21) do
		if src == "Drum" then
			continue
		end

		local v22 = nil

		for i = 1, v18 + 1 do
			local flag = false

			if i <= v18 then
				local v23 = v19[src][i] / v20[src]

				if v23 >= 1.8 then
					local total = 0
					local count3 = 0

					for _, v24 in ipairs(v21) do
						if v24 == src then
							continue
						end

						total += v19[v24][i] / v20[v24]
						count3 += 1
					end

					flag = v23 - total / count3 >= 0.7
				end
			end

			if flag then
				v22 = v22 or i
			elseif v22 then
				local t0 = (v22 - 1) * 4
				local t1 = (i - 1) * 4

				if t1 - t0 >= 8 then
					data.surges[#data.surges + 1] = { t0 = t0, t1 = t1, src = src }
				end

				v22 = nil
			end
		end
	end

	table.sort(data.surges, function(a, b): boolean
		if a.t0 == b.t0 then
			return a.src < b.src
		end

		return a.t0 < b.t0
	end)

	return data
end

local ChartActivity = {}

function ChartActivity.Request(p, callback)
	local v7 = v5[p]

	if v7 then
		callback(v7)
		return
	end

	if v6[p] then
		table.insert(v6[p], callback)
		return
	end

	v6[p] = { callback }
	task.spawn(function()
		local success, result = pcall(buildData, p)

		if not success then
			warn("[ChartActivity] Gagal menganalisis chart:", p, result)
			result = nil
		end

		local v8 = result or {
			events = {},
			firstNote = nil,
			lastNote = 0,
			counts = {},
			nW = 1,
			window = 2,
			solos = {},
			duos = {},
			fills = {},
			intense = {},
			surges = {},
			kicks = {},
			kickBursts = {},
			padRolls = {},
			entries = {}
		}

		v5[p] = v8
		local v9 = v6[p]
		v6[p] = nil

		for _, callback2 in ipairs(v9) do
			local success2, result2 = pcall(callback2, v8)

			if not success2 then
				warn("[ChartActivity] Error callback:", result2)
			end
		end
	end)
end

function ChartActivity.DominantAt(data, p)
	if not (data and data.counts) then
		return nil
	end

	local v7 = math.clamp(math.floor(p / data.window) + 1, 1, data.nW)
	local v8 = 0
	local v9 = nil

	for k, count in pairs(data.counts) do
		local v10 = count[v7] or 0

		if not (v8 < v10 or v10 == v8 and v9 and k < v9) then
			continue
		end

		v9 = k
		v8 = v10
	end

	return if not (v8 <= 0) then v9 else nil
end

function ChartActivity.DominantInfo(data, p, p2)
	if not (data and data.counts) then
		return nil
	end

	local v7 = math.clamp(math.floor(p / data.window) + 1, 1, data.nW)
	local v8 = {}
	local total = 0

	for k, count in pairs(data.counts) do
		local total2 = 0

		for i = math.max(1, v7 - 2), math.min(data.nW, v7 + 2) do
			total2 += count[i] or 0
		end

		if not (total2 > 0 and (p2 == nil or p2[k])) then
			continue
		end

		v8[k] = total2
		total += total2
	end

	local v9 = 0
	local v10 = nil
	local v11 = 0

	for k, v12 in pairs(v8) do
		if v9 < v12 or v12 == v9 and v10 and k < v10 then
			v11 = v9
			v9 = v12
			v10 = k
		elseif v11 < v12 then
			v11 = v12
		end
	end

	if v10 and not (total <= 0) then
		return v10, v9 / total, v11 > 0 and v9 / v11 or 1e999
	end

	return nil
end

return ChartActivity