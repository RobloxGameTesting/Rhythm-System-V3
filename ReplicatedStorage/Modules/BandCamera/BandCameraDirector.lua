local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BandCamera = Modules:WaitForChild("BandCamera")
local BandCameraConfig = require(BandCamera:WaitForChild("BandCameraConfig"))
local ChartActivity = require(BandCamera:WaitForChild("ChartActivity"))
local SongConfig = Modules:WaitForChild("SongConfig")

local ShotNames = BandCameraConfig.ShotNames
local shotNameSet = {}
local BandCameraDirector = {}

for _, shotName in ipairs(BandCameraConfig.ShotNames) do
	shotNameSet[shotName] = true
end

local v = { GuitarLead = true, GuitarRhythm = true, Bass = true }
local v2 = { Piano = true, Keyboard = true }
local v3 = { "Bass", "BVocal", "Drum", "GuitarLead", "GuitarRhythm", "Keyboard", "Piano" }

local v4 = {
	Drum = { "DrumCam", "Close" },
	GuitarLead = { "Headstock", "Close", "HeadCam" },
	GuitarRhythm = { "Headstock", "Close", "HeadCam" },
	Bass = { "Headstock", "Close", "HeadCam" },
	Keyboard = { "PianoCam", "Close", "HeadCam" },
	Piano = { "PianoCam", "Close", "HeadCam" },
	BVocal = { "Close", "Head" }
}

local function hashString(value) -- 2 equivalent calls inferred from this helper
	local v5 = 5381

	for i = 1, #value do
		v5 = (v5 * 33 + string.byte(value, i)) % 4294967296
	end

	return v5
end

local function getBpm(p) -- 2 equivalent calls inferred from this helper
	local success, result = pcall(require, SongConfig)

	if success and type(result) == "table" and result.Songs and result.Songs[p] then
		local bpm = result.Songs[p].BPM

		if type(bpm) == "number" and bpm >= 30 and bpm <= 300 then
			return bpm
		end
	end

	return 120
end

local function makeEligible(items)
	local set = {}
	local names = {}

	if items == nil then
		for _, v5 in ipairs(v3) do
			set[v5] = true
			names[#names + 1] = v5
		end
	else
		for k, item in pairs(items) do
			if not item then
				continue
			end

			set[k] = true
			names[#names + 1] = k
		end

		table.sort(names)
	end

	return { names = names, set = set }
end

local function listHas(p, p2): boolean
	for _, name in ipairs(p.names) do
		if p2[name] then
			return true
		end
	end

	return false
end

local function shotAvailable(p, eligible): boolean
	if p == "DrumCam" then
		return eligible.set.Drum == true
	end

	if p == "Headstock" then
		for _, name in ipairs(eligible.names) do
			if v[name] then
				return true
			end
		end

		return false
	elseif p == "PianoCam" then
		for _, name in ipairs(eligible.names) do
			if v2[name] then
				return true
			end
		end

		return false
	else
		if p == "Close" or p == "Head" or p == "HeadCam" then
			return #eligible.names > 0
		end

		return p ~= "Medium" or #eligible.names > 0
	end
end

local function needsTargetShot(p): boolean -- 1 equivalent call inferred from this helper
	return p == "Close" or p == "Head" or p == "Headstock" or p == "HeadCam" or p == "DrumCam" or p == "PianoCam"
end

local object = setmetatable({}, { __mode = "k" })
local function getMeans(data)
	local v5 = object[data]

	if v5 then
		return v5
	end

	local result = {}

	for k, count in pairs(data.counts) do
		local total = 0
		local count2 = 0

		for i = 1, data.nW do
			if not ((count[i] or 0) > 0) then
				continue
			end

			total += count[i]
			count2 += 1
		end

		result[k] = count2 > 0 and total / count2 or 1
	end

	object[data] = result
	return result
end

local function pickFrom(object2, data, p, list, callback)
	if #list == 0 then
		return nil
	end

	if #list == 1 then
		return list[1]
	end

	if data and data.counts then
		local means = getMeans(data)
		local v5 = math.clamp(math.floor(p / data.window) + 1, 1, data.nW)
		local v6 = {}
		local total = 0

		for _, item in ipairs(list) do
			local count = data.counts[item]
			local score = 0.25

			if count then
				local total2 = 0

				for i = math.max(1, v5 - 1), math.min(data.nW, v5 + 1) do
					total2 += count[i] or 0
				end

				if total2 > 0 then
					score = (total2 / 3 / means[item]) ^ 1.5
				end
			end

			if callback then
				score *= callback(item)
			end

			v6[#v6 + 1] = { instr = item, score = score }
			total += score
		end

		local v7 = object2:NextNumber() * total

		for _, v8 in ipairs(v6) do
			v7 -= v8.score

			if v7 <= 0 then
				return v8.instr
			end
		end

		return v6[#v6].instr
	else
		if not callback then
			return list[object2:NextInteger(1, #list)]
		end

		local v5 = {}
		local total = 0

		for i, item in ipairs(list) do
			v5[i] = callback(item)
			total += v5[i]
		end

		local v6 = object2:NextNumber() * total

		for i, item in ipairs(list) do
			v6 -= v5[i]

			if v6 <= 0 then
				return item
			end
		end

		return list[#list]
	end
end

local function findSegment(list, p, soloOk)
	if not list then
		return nil
	end

	for _, item in ipairs(list) do
		if item.t0 <= p and p < item.t1 and (not soloOk or soloOk(item)) then
			return item
		end
	end

	return nil
end

local function classify(data, p, eligible)
	if not data then
		return "Normal", nil, nil, nil
	end

	local function soloOk(p2): boolean
		return eligible.set[p2.src] == true
	end

	local selected = findSegment(data.solos, p, soloOk) or findSegment(data.surges, p, soloOk)

	if selected then
		return "Solo", selected.src, nil, selected
	end

	local duos = data.duos
	local v5

	if duos then
		for _, duo in ipairs(duos) do
			if duo.t0 <= p and p < duo.t1 then
				v5 = duo
				break
			end
		end
	end

	if v5 then
		local targets = {}

		for _, target in ipairs(v5.targets) do
			if eligible.set[target] then
				targets[#targets + 1] = target
			end
		end

		if #targets == 2 then
			return "Duo", nil, targets, v5
		end

		if #targets == 1 then
			return "Solo", targets[1], nil, v5
		end
	end

	local fills = data.fills
	local v6

	if fills then
		for _, fill in ipairs(fills) do
			if fill.t0 <= p and p < fill.t1 then
				v6 = fill
				break
			end
		end
	end

	if v6 and eligible.set.Drum then
		return "Fill", "Drum", nil, v6
	end

	local intense = data.intense
	local v7

	if intense then
		for _, v8 in ipairs(intense) do
			if v8.t0 <= p and p < v8.t1 then
				v7 = v8
				break
			end
		end
	end

	if v7 then
		return "Intense", nil, nil, v7
	end

	local dominantInfo, v8, v9 = ChartActivity.DominantInfo(data, p, eligible.set)

	if dominantInfo and BandCameraConfig.DominantShare <= v8 and BandCameraConfig.DominantRatio <= v9 then
		return "Dominant", dominantInfo, nil, nil
	end

	return "Normal", nil, nil, nil
end

local function resolveTarget(p, p2, list, random, data, p3, eligible, p4, boost)
	local function pool(fn)
		local names = {}

		for _, name in ipairs(eligible.names) do
			if fn(name) and name ~= p4 then
				names[#names + 1] = name
			end
		end

		if #names == 0 then
			for _, name in ipairs(eligible.names) do
				if fn(name) then
					names[#names + 1] = name
				end
			end
		end

		return names
	end

	if p == "DrumCam" then
		return if eligible.set.Drum then "Drum" else nil
	elseif p == "Headstock" then
		if p2 and v[p2] and eligible.set[p2] and p2 ~= p4 then
			return p2
		end

		return pickFrom(random, data, p3, pool(function(p5): boolean
			return v[p5] == true
		end), boost)
	elseif p == "PianoCam" then
		if p2 and v2[p2] and eligible.set[p2] then
			return p2
		end

		return pickFrom(random, data, p3, pool(function(p5): boolean
			return v2[p5] == true
		end), boost)
	else
		if p2 and eligible.set[p2] and p2 ~= p4 then
			return p2
		end

		if list then
			local v5 = {}

			for _, item in ipairs(list) do
				if eligible.set[item] and item ~= p4 then
					v5[#v5 + 1] = item
				end
			end

			if #v5 > 0 then
				return pickFrom(random, data, p3, v5, boost)
			end
		end

		return pickFrom(random, data, p3, pool(function(): boolean
			return true
		end), boost)
	end
end

local function weightsFor(p, p2)
	local v5 = BandCameraConfig.Weights[p] or BandCameraConfig.Weights.Normal

	if not p2 or p ~= "Dominant" and p ~= "Solo" then
		return v5
	end

	local clone = table.clone(v5)
	local v6 = math.max(v5.Headstock or 0, 26)

	if v2[p2] then
		clone.PianoCam = math.max(clone.PianoCam or 0, v6)
		clone.Headstock = (clone.Headstock or 0) * 0.25
		clone.DrumCam = (clone.DrumCam or 0) * 0.4
	elseif v[p2] then
		clone.PianoCam = (clone.PianoCam or 0) * 0.3
		clone.DrumCam = (clone.DrumCam or 0) * 0.5
	elseif p2 == "Drum" then
		clone.DrumCam = math.max(clone.DrumCam or 0, v6)
		clone.Headstock = (clone.Headstock or 0) * 0.25
		clone.PianoCam = (clone.PianoCam or 0) * 0.3
	end

	return clone
end

local function activeNear(data, name, p): boolean
	if not (data and data.counts) then
		return true
	end

	local count = data.counts[name]

	if not count then
		return false
	end

	local v5 = math.clamp(math.floor(p / data.window) + 1, 1, data.nW)

	for i = math.max(1, v5 - 1), math.min(data.nW, v5 + 2) do
		if (count[i] or 0) > 0 then
			return true
		end
	end

	return false
end

local function weightedPick(random, list)
	local total = 0

	for _, item in ipairs(list) do
		total += item.w
	end

	if total <= 0 then
		return nil
	end

	local v5 = random:NextNumber() * total

	for _, item in ipairs(list) do
		v5 -= item.w

		if v5 <= 0 then
			return item.shot
		end
	end

	return list[#list].shot
end

local function slotIndexAt(list, p)
	local v5 = #list
	local v6 = 1
	local v7 = 1

	while v6 <= v5 do
		local v8 = (v6 + v5) // 2

		if list[v8].t0 <= p then
			v6 = v8 + 1
			v7 = v8
		else
			v5 = v8 - 1
		end
	end

	return v7
end

function BandCameraDirector.Build(song, value, p, data, list, p2)
	local duration = type(value) == "number" and value > 0 and value or 240
	local eligible = makeEligible(p2)
	local v5 = 240 / getBpm(song) -- inferred equivalent call

	local v6 = math.clamp(
		v5 * BandCameraConfig.Slot.BarsPerSlot,
		BandCameraConfig.Slot.MinSeconds,
		BandCameraConfig.Slot.MaxSeconds
	)
	local v7 = math.max(1, (math.ceil(BandCameraConfig.Slot.MinSeconds / v5)))
	local v8 = math.max(v7, (math.floor(BandCameraConfig.Slot.MaxSeconds / v5)))
	local v9 = math.clamp(math.floor(v6 / v5 + 0.5), v7, v8)
	local random = Random.new(hashString(tostring(p) .. "|" .. tostring(song))) -- inferred equivalent call

	local slots = {}
	local function add(t0, shot, target, targets, dir, p3, style, dirFixed)
		local number = random:NextNumber()

		local shake = random:NextNumber() < (BandCameraConfig.Shake.Chance[shot] or 0)
		slots[#slots + 1] = {
			t0 = t0,
			shot = shot,
			target = target,
			targets = targets,
			dir = dir,
			dirFixed = dirFixed,
			pick = number,
			shake = shake,
			cue = p3 or nil,
			style = style
		}
	end
	local function randomDir(p3) -- 2 equivalent calls inferred from this helper
		if random:NextNumber() < 0.7 then
			return -p3
		end

		return p3
	end

	local v10 = math.max(0, duration - BandCameraConfig.EndingWideSeconds)
	local firstNote = data and data.firstNote or 0
	local v11 = math.min(v6 <= firstNote and firstNote or firstNote + v9 * v5, v10)

	local v12 = random:NextNumber() < 0.5 and -1 or 1
	add(-3600, "Wide", nil, nil, v12)
	local v13 = v11
	local v14 = {}
	local v15 = "Wide"
	local v16 = {}
	local v17 = false
	local v18 = nil

	while v13 < v10 - 2 do
		local v19, v20, v21, v22 = classify(data, v13, eligible)
		local v23 = weightsFor(v19, v20)
		local function boost(p3)
			local fairness = BandCameraConfig.Fairness

			if fairness and fairness.Enabled then
				return math.clamp((v13 - (v14[p3] or firstNote)) / fairness.BoostSeconds, 0, 4) + 1
			end

			return 1
		end

		local v24 = {}

		for _, shotName in ipairs(ShotNames) do
			local v25 = v23[shotName]

			if not (v25 and v25 > 0 and shotAvailable(shotName, eligible)) then
				continue
			end

			local v26 = shotName ~= v15
			local shotCooldown = BandCameraConfig.ShotCooldowns[shotName]

			if shotCooldown and v16[shotName] and v13 - v16[shotName] < shotCooldown then
				v26 = false
			end

			if v26 then
				v24[#v24 + 1] = { shot = shotName, w = v25 }
			end
		end

		local v25 = nil

		local v26 = nil
		local fairness = BandCameraConfig.Fairness

		if fairness and fairness.Enabled and not v17 and #eligible.names >= 2 and v19 ~= "Fill" then
			local v27 = fairness.GapSeconds * (v19 == "Solo" and 2 or 1)
			local v28 = 0

			for _, name in ipairs(eligible.names) do
				if not (v4[name] and name ~= v20) then
					continue
				end

				local v29 = v13 - (v14[name] or firstNote)

				if not (v27 <= v29 and v28 < v29 and activeNear(data, name, v13)) then
					continue
				end

				v26 = name
				v28 = v29
			end
		end

		if v26 then
			local v27 = {}

			for _, v28 in ipairs(v4[v26]) do
				if v28 ~= v15 and shotAvailable(v28, eligible) then
					v27[#v27 + 1] = v28
				end
			end

			if #v27 > 0 then
				v25 = v27[random:NextInteger(1, #v27)]
			else
				v26 = nil
			end
		end

		v15 = v25 or weightedPick(random, v24) or "Wide"

		local v27 = nil
		local v28 = nil

		if v26 then
			v27 = v26
		elseif v15 == "Medium" then
			if v21 then
				v28 = v21
			elseif v20 and eligible.set[v20] then
				v27 = v20
			end
		elseif needsTargetShot(v15) then -- inferred equivalent call
			local v29 = nil

			if (v15 == "Close" or v15 == "Head" or v15 == "HeadCam") and #eligible.names > 1 then
				v29 = v18
			end

			v27 = resolveTarget(v15, v20, v21, random, data, v13, eligible, v29, boost)

			if not v27 then
				v15 = "Wide"
			end
		end

		local integer = random:NextInteger(1, 4)
		local v29

		if integer == 3 and v9 + 1 <= v8 then
			v29 = v9 + 1
		elseif integer == 4 then
			v29 = math.max(v7, v9 - 1)
		else
			v29 = v9
		end

		if v22 and (v19 == "Solo" or v19 == "Duo" or v19 == "Fill") then
			local v30 = math.ceil((v22.t1 - v13) / v5)

			if v7 <= v30 then
				v29 = math.clamp(v30, v7, v8 + 2)
			end
		end

		local v30 = v29 * v5

		if v10 < v13 + v30 then
			v30 = math.max(v5, v10 - v13)
		end

		v12 = randomDir(v12) -- inferred equivalent call
		add(v13, v15, v27, v28, v12)

		v16[v15] = v13

		if v27 then
			v14[v27] = v13
		end

		if v28 then
			for _, v31 in ipairs(v28) do
				v14[v31] = v13
			end
		end

		v17 = v26 ~= nil
		v13 += v30
		v18 = v27
	end

	local v19 = math.max(v13, v11)

	if v19 < duration then
		v12 = randomDir(v12) -- inferred equivalent call
		add(v19, "Wide", nil, nil, v12)
	end

	local function overlay(data2, p3)
		if
			type(data2) ~= "table"
			or not shotNameSet[data2.Shot]
			or type(data2.From) ~= "number"
			or type(data2.To) ~= "number"
			or not (data2.To > data2.From)
		then
			return
		end

		local v20 = slots[slotIndexAt(slots, data2.To)]
		local v21 = {
			t0 = data2.To,
			shot = v20.shot,
			target = v20.target,
			targets = v20.targets,
			dir = v20.dir,
			dirFixed = v20.dirFixed,
			pick = v20.pick,
			shake = v20.shake,
			cue = v20.cue,
			moment = v20.moment,
			sub = v20.sub,
			pad = v20.pad,
			padTrack = v20.padTrack,
			padDur = v20.padDur,
			angle = v20.angle,
			style = v20.style
		}

		local v22 = {}
		local v23 = false

		for _, v24 in ipairs(slots) do
			if v24.t0 >= data2.From and v24.t0 < data2.To then
				continue
			end

			v23 = v24.t0 == data2.To or v23

			v22[#v22 + 1] = v24
		end

		slots = v22
		local number = random:NextNumber()
		local shake = data2.Shake
		local number2 = random:NextNumber()

		if shake == nil then
			shake = number2 < (BandCameraConfig.Shake.Chance[data2.Shot] or 0)
		end

		slots[#slots + 1] = {
			t0 = data2.From,
			shot = data2.Shot,
			target = data2.Target,
			targets = data2.Targets,
			dir = data2.Dir or random:NextNumber() < 0.5 and -1 or 1,
			dirFixed = data2.Dir ~= nil or nil,
			pick = number,
			shake = shake,
			cue = p3 or nil,
			moment = not p3 or nil,
			sub = data2.Variant,
			pad = data2.Pad,
			padTrack = data2.PadTrack,
			padDur = data2.PadDur,
			angle = data2.Angle,
			style = data2.Style
		}

		if not v23 and data2.To < duration then
			slots[#slots + 1] = v21
		end

		table.sort(slots, function(a, b): boolean
			return a.t0 < b.t0
		end)
	end

	if data then
		local moments = BandCameraConfig.Moments
		local v20 = {}
		local function conflicts(p3, p4): boolean
			local v21 = p4 or moments.MinGap

			for _, v22 in ipairs(v20) do
				if p3.From < v22.To + v21 and v22.From < p3.To + v21 then
					return true
				end
			end

			return false
		end

		local function plan(p3) -- 1 equivalent call inferred from this helper
			if p3.From < v10 and p3.From >= 0 and not conflicts(p3) then
				v20[#v20 + 1] = p3
			end
		end

		local function selectBest(list2, p3, p4, list3, p5)
			local v21 = math.max(1, (math.floor(duration / 60 * p3 + 0.5)))

			for _, item in ipairs(list2) do
				item.score *= 0.85 + 0.3 * random:NextNumber()
			end

			table.sort(list2, function(a, b): boolean
				if a.score == b.score then
					return a.t0 < b.t0
				end

				return a.score > b.score
			end)

			local best = {}

			for _, item in ipairs(list2) do
				if v21 <= #best then
					break
				end

				local flag = true

				for _, v22 in ipairs(best) do
					if math.abs(item.t0 - v22.t0) < p4 then
						flag = false
						break
					end
				end

				if flag and list3 then
					for _, item2 in ipairs(list3) do
						if math.abs(item.t0 - item2.t0) < p5 then
							flag = false
							break
						end
					end
				end

				if flag then
					best[#best + 1] = item
				end
			end

			table.sort(best, function(a, b): boolean
				return a.t0 < b.t0
			end)

			return best
		end

		local v21

		if eligible.set.Drum then
			local v22 = {}

			for _, roll in ipairs(data.padRolls or {}) do
				v22[#v22 + 1] = {
					t0 = roll.t0,
					roll = roll,
					score = roll.count * (1 + (roll.t1 - roll.t0) / 4)
				}
			end

			v21 = selectBest(v22, moments.PadMomentsPerMinute, moments.PadMomentSpacing)

			for _, v23 in ipairs(v21) do
				local roll = v23.roll
				local v24 = roll.t1 + moments.PadTail
				local v25 = roll.t0 - moments.PadLead
				local count = 0

				while count < 2 and v25 < roll.t1 - 0.6 do
					local from = math.max(0, v25)
					local padDur = math.clamp(v24 - from, moments.PadMinSeconds, moments.PadMaxSeconds)
					local padTrack = {}

					for _, v26 in ipairs(roll.hits or {}) do
						if from <= v26.t and v26.t <= from + padDur then
							padTrack[#padTrack + 1] = {
								t = v26.t - from,
								pad = v26.pad
							}
						end
					end

					local v26 = {
						From = from,
						To = from + padDur,
						Shot = "DrumCam",
						Target = "Drum",
						Variant = "pad",
						Pad = roll.pad,
						PadTrack = padTrack,
						PadDur = padDur,
						Shake = false
					}

					local padMinGap = count == 0 and moments.PadMinGap or 1

					if from < v10 and #padTrack > 0 and not conflicts(v26, padMinGap) then
						v20[#v20 + 1] = v26
					end

					count += 1
					v25 = from + padDur + moments.PadResumeGap
				end
			end
		else
			v21 = {}
		end

		if eligible.set.Drum then
			local v22 = { "overhead", "front", "side" }
			local v23 = { "backlow", "backhigh", "sidehigh" }
			local v24 = {}
			local angle = nil
			local v25 = random:NextInteger(1, 3)
			local function nextAngle()
				if #v24 == 0 then
					v24 = table.clone(v23)

					for i = #v24, 2, -1 do
						local integer = random:NextInteger(1, i)
						local v26 = v24
						local v27 = v24
						local v28 = v24[integer]
						local v29 = v24[i]
						v26[i] = v28
						v27[integer] = v29
					end

					if angle and v24[#v24] == angle then
						local v26 = v24
						local v27 = v24
						local v28 = #v24
						local v29 = v24[#v24]
						local v30 = v24[1]
						v26[1] = v29
						v27[v28] = v30
					end
				end

				angle = table.remove(v24)
				return angle
			end

			local v26 = {}

			for _, burst in ipairs(data.kickBursts or {}) do
				v26[#v26 + 1] = {
					t0 = burst.t0,
					burst = burst,
					score = burst.count * (1 + (burst.t1 - burst.t0) / 3)
				}
			end

			local v27 = selectBest(
				v26,
				moments.KickMomentsPerMinute,
				moments.KickMomentSpacing,
				v21,
				moments.MomentCrossSpacing
			)

			for _, v28 in ipairs(v27) do
				local burst = v28.burst
				local from = math.max(0, burst.t0 - moments.KickLead)
				local v29 = math.clamp(burst.t1 + 0.5 - from, moments.KickMinSeconds, moments.KickChainMaxSeconds)
				local v30 = {
					From = from,
					To = from + v29
				}

				if not (from < v10) or conflicts(v30, moments.KickMinGap) then
					continue
				end

				local v31 = math.clamp(v29, math.min(moments.KickMinSeconds, v29), moments.KickMaxSeconds)
				v20[#v20 + 1] = {
					From = from,
					To = from + v31,
					Shot = "DrumCam",
					Target = "Drum",
					Variant = "foot",
					Angle = nextAngle(),
					Shake = true,
					Dir = random:NextNumber() < 0.5 and -1 or 1
				}

				local v32 = v29 - v31

				if not (v32 >= 1.5) then
					continue
				end

				v25 = v25 % #v22 + 1
				v20[#v20 + 1] = {
					From = from + v31,
					To = from + v31 + math.min(moments.KickChainSegmentSeconds, v32),
					Shot = "DrumCam",
					Target = "Drum",
					Variant = v22[v25],
					Shake = true,
					Dir = random:NextNumber() < 0.5 and -1 or 1
				}
			end
		end

		for _, v22 in ipairs(data.entries or {}) do
			if not eligible.set[v22.instr] then
				continue
			end

			local shot

			if v[v22.instr] then
				shot = random:NextNumber() < 0.5 and "Headstock" or "Close"
			elseif v22.instr == "Drum" then
				shot = "DrumCam"
			elseif v2[v22.instr] then
				shot = "PianoCam"
			elseif v22.instr == "BVocal" then
				shot = "Head"
			else
				shot = "Close"
			end

			local from = math.max(0, v22.t - 0.1)
			plan({ -- inferred equivalent call
				From = from,
				To = from + moments.EntrySeconds,
				Shot = shot,
				Target = v22.instr
			})
		end

		for _, v22 in ipairs(v20) do
			overlay(v22, false)
		end
	end

	if type(list) == "table" then
		for i = #list, 1, -1 do
			overlay(list[i], true)
		end
	end

	if #slots == 0 then
		add(-3600, "Wide", nil, nil, 1)
	end

	return { slots = slots, duration = duration, song = song }
end

local v5 = {
	Drum = { "DrumCam", "HeadCam", "Close" },
	GuitarLead = { "Headstock", "HeadCam", "Close" },
	GuitarRhythm = { "Headstock", "HeadCam", "Close" },
	Bass = { "Headstock", "HeadCam", "Close" },
	Keyboard = { "PianoCam", "HeadCam", "Close" },
	Piano = { "PianoCam", "HeadCam", "Close" },
	BVocal = { "Close", "Head" }
}

function BandCameraDirector.BuildFocus(song, value, p, p2, list, p3)
	if type(list) ~= "table" then
		return nil
	end

	local eligible = makeEligible(p3)
	local v6 = {}

	for _, item in ipairs(list) do
		if v5[item] and eligible.set[item] then
			v6[#v6 + 1] = item
		end
	end

	table.sort(v6)

	if #v6 == 0 then
		return nil
	end

	local duration = (type(value) ~= "number" or not (value > 0 and value)) and 240 or value
	local v7 = 240 / getBpm(song) -- inferred equivalent call

	local v8 = math.clamp(
		v7 * BandCameraConfig.Slot.BarsPerSlot,
		BandCameraConfig.Slot.MinSeconds,
		BandCameraConfig.Slot.MaxSeconds
	)
	local v9 = math.max(1, (math.ceil(BandCameraConfig.Slot.MinSeconds / v7)))
	local v10 = math.max(v9, (math.floor(BandCameraConfig.Slot.MaxSeconds / v7)))
	local v11 = math.clamp(math.floor(v8 / v7 + 0.5), v9, v10)
	local random = Random.new(hashString(tostring(p) .. "|" .. tostring(song) .. "|focus|" .. table.concat(v6, ","))) -- inferred equivalent call

	local slots = {}
	local v12 = {}
	local integer = random:NextInteger(0, #v6 - 1)
	local function add(t0)
		local target = v6[integer % #v6 + 1]
		integer += 1
		local v13 = {}

		for _, v14 in ipairs(v5[target]) do
			if v14 ~= v12[target] and shotNameSet[v14] then
				v13[#v13 + 1] = v14
			end
		end

		if #v13 == 0 then
			v13 = v5[target]
		end

		local shot = v13[random:NextInteger(1, #v13)]
		v12[target] = shot
		slots[#slots + 1] = {
			t0 = t0,
			shot = shot,
			target = target,
			dir = random:NextNumber() < 0.5 and -1 or 1,
			pick = random:NextNumber(),
			shake = random:NextNumber() < (BandCameraConfig.Shake.Chance[shot] or 0),
			focus = true
		}
	end

	local firstNote = p2 and p2.firstNote or 0
	local v13 = v8 <= firstNote and firstNote or firstNote + v11 * v7
	add(-3600)

	while v13 < duration - 1 do
		add(v13)

		local integer2 = random:NextInteger(1, 4)
		local v14

		if integer2 == 3 and v11 + 1 <= v10 then
			v14 = v11 + 1
		elseif integer2 == 4 then
			v14 = math.max(v9, v11 - 1)
		else
			v14 = v11
		end

		v13 += v14 * v7
	end

	return { slots = slots, duration = duration, song = song, focus = true }
end

function BandCameraDirector.GetSlot(p, p2)
	local slots = p.slots
	local v6 = slotIndexAt(slots, p2)
	local slot = slots[v6]
	local t0 = slots[v6 + 1] and slots[v6 + 1].t0 or p.duration + BandCameraConfig.EndHoldSeconds
	local v7 = slot.t0

	if slot.t0 <= -3600 then
		v7 = math.min(0, p2)
	end

	local v8 = math.max(0.01, t0 - v7)
	return slot, math.clamp((p2 - v7) / v8, 0, 1), v6
end

return BandCameraDirector