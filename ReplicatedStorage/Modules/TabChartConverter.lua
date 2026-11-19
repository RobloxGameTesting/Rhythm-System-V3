local v = { 64, 59, 55, 50, 45, 40 }
local v2 = { 43, 38, 33, 28 }

local v3 = {
	Guitar = {
		lanes = 5,
		mode = "semis",
		winSec = 4,
		wa = 1,
		wt = 0.5,
		semis = 2,
		strumTwo = true
	},
	Bass = {
		lanes = 4,
		mode = "scaled",
		winSec = 2,
		wa = 0.5,
		wt = 1,
		semis = 2,
		strumTwo = false
	}
}

local function pitchOf(p, p2) -- 1 equivalent call inferred from this helper
	local v4 = (p2 - 1) // 13 + 1
	local v5 = (p2 - 1) % 13
	local v6 = p[v4]

	if v6 then
		return v6 + v5
	end

	return nil
end

local function buildOnsets(data, p)
	local n = data.N
	local t = data.T
	local d = data.D
	local l = data.L
	local v4 = table.create(n)

	for i = 1, n do
		local v5 = pitchOf(p, l[i]) -- inferred equivalent call

		if not v5 then
			return nil, "lane_di_luar_jangkauan"
		end

		v4[i] = v5
	end

	local v5 = table.create(n)

	for i = 1, n do
		v5[i] = i
	end

	table.sort(v5, function(a, b): boolean
		if t[a] ~= t[b] then
			return t[a] < t[b]
		end

		if d[a] ~= d[b] then
			return d[a] < d[b]
		end

		if v4[a] == v4[b] then
			return a < b
		end

		return v4[a] < v4[b]
	end)
	local v6 = nil
	local result = {}

	for _, v7 in ipairs(v5) do
		local v8 = t[v7]

		if v6 and v8 - v6.last <= 3 then
			v6.last = v8
			v6.size += 1

			if v4[v7] < v6.root then
				v6.root = v4[v7]
			end

			if d[v7] > v6.dur then
				v6.dur = d[v7]
			end

			table.insert(v6.src, l[v7])
		else
			v6 = {
				t0 = v8,
				last = v8,
				root = v4[v7],
				size = 1,
				dur = d[v7],
				src = { l[v7] }
			}
			table.insert(result, v6)
		end
	end

	return result
end

local function computeTargets(onsets, data, bpm, res)
	local lanes = data.lanes
	local count = #onsets
	local v4 = math.floor(data.winSec * bpm / 60 * res)
	local targets = table.create(count)
	local v5 = 1
	local v6 = 1

	for i = 1, count do
		local item = onsets[i]

		while v5 < i and onsets[v5].t0 < item.t0 - v4 do
			v5 += 1
		end

		if v6 < i then
			v6 = i
		end

		while v6 <= count and onsets[v6].t0 <= item.t0 + v4 do
			v6 += 1
		end

		local rootSet = {}
		local roots = {}

		for j = v5, v6 - 1 do
			local root = onsets[j].root

			if rootSet[root] then
				continue
			end

			rootSet[root] = true
			table.insert(roots, root)
		end

		table.sort(roots)
		local count2 = #roots
		local v7

		if count2 > 1 then
			if data.mode == "semis" then
				v7 = math.min(lanes - 1, (item.root - roots[1]) / data.semis)
			else
				v7 = (table.find(roots, item.root) - 1) * (lanes - 1) / (count2 - 1)
			end
		else
			v7 = false
		end

		targets[i] = v7
	end

	return targets
end

local function solveLanes(onsets, list, data)
	local lanes = data.lanes
	local wa = data.wa
	local wt = data.wt
	local count = #onsets
	local v4 = table.create(count)
	local v5 = table.create(count)
	local v6 = table.create(lanes)

	for i = 1, lanes do
		local v7 = i - 1
		local item = list[1]

		if item then
			v6[i] = wa * (v7 - item) ^ 2
		else
			v6[i] = wa * (0.5 * (v7 - (lanes - 1) / 2) ^ 2)
		end
	end

	v4[1] = v6
	v5[1] = table.create(lanes, 1)

	for i = 2, count do
		local v7 = onsets[i].root - onsets[i - 1].root
		local v8 = math.abs(v7)
		local v9 = math.min(v8 == 0 and 0 or v8 <= 4 and 1 or v8 <= 5 and 2 or 3, lanes - 1)
		local v10 = v7 > 0 and 1 or -1
		local v11 = table.create(lanes)
		local v12 = table.create(lanes)
		local v13 = v4[i - 1]

		for j = 1, lanes do
			local item = list[i]
			local v14 = item and wa * (j - 1 - item) ^ 2 or 0
			local v15 = 1e999
			local v16 = 1

			for k = 1, lanes do
				local v17 = j - k
				local v18

				if v7 == 0 then
					v18 = v17 == 0 and 0 or 1000
				elseif v17 * v10 < 0 then
					v18 = math.abs(v17) + 250
				else
					v18 = wt * (math.abs(v17) - v9) ^ 2
				end

				local v19 = v13[k] + v18

				if not (v19 < v15) then
					continue
				end

				v16 = k
				v15 = v19
			end

			v11[j] = v15 + v14
			v12[j] = v16
		end

		v4[i] = v11
		v5[i] = v12
	end

	local result = table.create(count)
	local v7 = 1e999
	local v8 = 1

	for i = 1, lanes do
		if not (v4[count][i] < v7) then
			continue
		end

		v7 = v4[count][i]
		v8 = i
	end

	for i = count, 1, -1 do
		result[i] = v8 - 1
		v8 = v5[i][v8]
	end

	return result
end

local v4 = {
	{ 5, "Crash" },
	{ 5, "Crash" },
	{ 5, "Crash" },
	{ 3, "HiHat" },
	{ 3, "HiHat" },
	{ 4, "HiTom" },
	{ 4, "HiTom" },
	{ 4, "MidTom" },
	{ 4, "MidTom" },
	{ 4, "Ride" },
	{ 4, "Ride" },
	{ 3, "HiHat" },
	{ 3, "HiHat" },
	{ 2, "Snare" },
	{ 2, "Snare" },
	{ 2, "Snare" },
	{ 1, "Kick" },
	{ 1, "Kick" },
	{ 4, "FloorTom" },
	{ 4, "FloorTom" },
	{ 5, "Crash" }
}

local function convertDrum(data)
	local v5 = 60 / (data.Bpm * data.Res)
	local notes = {}
	local count = 0

	for i = 1, data.N do
		local v6 = data.L[i]
		local v7 = v4[v6]

		if v7 then
			table.insert(notes, {
				Lane = v7[1],
				Time = data.T[i] * v5,
				Duration = 0.001,
				ReactionType = v7[2],
				Src = { v6 },
				_o = i
			})
		else
			count += 1
		end
	end

	table.sort(notes, function(a, b): boolean
		if a.Time ~= b.Time then
			return a.Time < b.Time
		end

		if a.Lane == b.Lane then
			return a._o < b._o
		end

		return a.Lane < b.Lane
	end)

	for _, v6 in ipairs(notes) do
		v6._o = nil
	end

	return { Notes = notes, LaneCount = 5, Skipped = count }
end

return {
	Convert = function(data)
		local instrument = data.Instrument

		if instrument == "Drum" then
			return convertDrum(data)
		end

		local v5 = v3[instrument]

		if not v5 then
			return nil, "instrumen_tidak_dikenal"
		end

		if (data.N or 0) == 0 then
			return { Notes = {}, LaneCount = v5.lanes, Onsets = {} }
		end

		local v6 = instrument == "Guitar" and v or v2
		local bpm = data.Bpm
		local res = data.Res
		local onsets, v7 = buildOnsets(data, v6)

		if not onsets then
			return nil, v7
		end

		local v8 = solveLanes(onsets, computeTargets(onsets, v5, bpm, res), v5)
		local lanes = v5.lanes
		local v9 = 60 / (bpm * res)
		local onsets2 = table.create(#onsets)
		local notes = {}

		for i, onset in ipairs(onsets) do
			local lanes2 = { v8[i] }

			if v5.strumTwo and onset.size >= 2 then
				table.insert(lanes2, v8[i] + 1 <= lanes - 1 and v8[i] + 1 or v8[i] - 1)
				table.sort(lanes2)
			end

			local sus = not (onset.dur >= 144) and 0
				or (onsets[i + 1] and onsets[i + 1].t0 or 1e999) - onset.t0 <= onset.dur + 6 and onset.dur - 48
				or onset.dur

			local time = onset.t0 * v9
			local duration = sus > 0 and sus * v9 or 0.001

			for j, v10 in ipairs(lanes2) do
				local v11 = {
					Lane = v10 + 1,
					Time = time,
					Duration = duration,
					Src = 0
				}
				local src

				if j == 1 then
					src = onset.src or nil
				end

				v11.Src = src
				table.insert(notes, v11)
			end

			onsets2[i] = { tick = onset.t0, lanes = lanes2, sus = sus }
		end

		return { Notes = notes, LaneCount = lanes, Onsets = onsets2 }
	end
}