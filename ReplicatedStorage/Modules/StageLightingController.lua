local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChartData = Modules:WaitForChild("ChartData")
local SettingsState = require(Modules:WaitForChild("SettingsState"))
local RhythmEngineConfig = require(Modules:WaitForChild("RhythmEngineConfig"))
local SongConfig = Modules:WaitForChild("SongConfig")
local StageLightConfig = require(Modules:WaitForChild("StageLightConfig"))
local StageBlackout = require(Modules:WaitForChild("StageBlackout"))

local StageLightingController = {}

local dark2 = 0.04

local ember2 = 0.05

local v = false

local v2 = 1

local kickRise2 = 0.06
local kickFall2 = 0.62
local kickFallMin2 = 0.15
local kickFallMax2 = 1.3
local doubleGap2 = 0.5
local doubleFall2 = 1

local v3 = Color3.fromRGB(105, 128, 232)
local soloStyle2 = { peak = 0.8, decay = 2.4, minGap = 0.1 }

local kickPeak2 = 1
local kickOther2 = 0.22
local kickBump2 = 0
local ayrPeak2 = 1
local ayrDecay2 = 5.5
local ayrStep2 = 0.9
local idleHue2 = 0.6
local idleSat2 = 0.6
local kickFloor2 = 0.2
local kickBoost2 = 2.2

local sway2 = 12
local forward2 = 48

local swaySpeed2 = 3.2

local v4 = { "GuitarLead", "GuitarRhythm", "Keyboard", "Bass", "Drum", "Piano" }
local v5 = { "GuitarLead", "GuitarRhythm", "Bass" }
local v6 = { "GuitarLead", "Keyboard", "GuitarRhythm", "Bass", "Drum", "Piano" }
local v7 = { 3, 2, 4, 1, 5 }

local zone2 = {
	Color3.fromRGB(70, 225, 120),
	Color3.fromRGB(235, 62, 72),
	Color3.fromRGB(250, 208, 85),
	Color3.fromRGB(72, 135, 245),
	Color3.fromRGB(245, 138, 52)
}

local colors2 = {
	Color3.fromRGB(110, 205, 255),
	Color3.fromRGB(75, 125, 255),
	Color3.fromRGB(150, 120, 255),
	Color3.fromRGB(215, 230, 255),
	Color3.fromRGB(80, 200, 205)
}

local colors3 = {
	Color3.fromRGB(255, 150, 55),
	Color3.fromRGB(255, 112, 45),
	Color3.fromRGB(255, 200, 105),
	Color3.fromRGB(232, 78, 62),
	Color3.fromRGB(255, 226, 180)
}

local colors4 = {
	Color3.fromRGB(40, 80, 210),
	Color3.fromRGB(78, 58, 195),
	Color3.fromRGB(30, 155, 185),
	Color3.fromRGB(50, 105, 225),
	Color3.fromRGB(95, 70, 175)
}

local kickColor2 = Color3.fromRGB(255, 250, 240)
local burst2 = Color3.fromRGB(225, 236, 255)
local spA2 = Color3.fromRGB(255, 172, 62)
local spB2 = Color3.fromRGB(255, 238, 205)
local color = Color3.fromRGB(18, 18, 24)

local par = {
	GuitarLead = {
		colors = colors2,
		peak = 1,
		decay = 7.5,
		minGap = 0,
		mode = "alt",
		short = "LEAD",
		num = "001"
	},
	GuitarRhythm = {
		colors = colors3,
		peak = 0.92,
		decay = 4.2,
		minGap = 0.07,
		mode = "both",
		short = "RHYTHM",
		num = "002"
	},
	Bass = {
		colors = colors4,
		peak = 0.85,
		decay = 2,
		minGap = 0.13,
		mode = "both",
		short = "BASS",
		num = "003"
	}
}

local function smoothstep(value) -- 3 equivalent calls inferred from this helper
	local v8 = math.clamp(value, 0, 1)
	return v8 * v8 * (3 - 2 * v8)
end

local function colorDiff(data, data2) -- 2 equivalent calls inferred from this helper
	return math.abs(data.R - data2.R) + math.abs(data.G - data2.G) + math.abs(data.B - data2.B)
end

local function mixColor(colors, lanes) -- 1 equivalent call inferred from this helper
	return colors[lanes[1]] or colors[1]
end

local function lowerBound(list, p)
	local v8 = #list + 1
	local v9 = 1

	while v9 < v8 do
		local v10 = (v9 + v8) // 2

		if list[v10].t < p then
			v9 = v10 + 1
		else
			v8 = v10
		end
	end

	return v9
end

local function segIndexFor(segs, p)
	local v8 = #segs
	local v9 = 1

	while v9 < v8 do
		local v10 = (v9 + v8 + 1) // 2

		if segs[v10].t0 <= p then
			v9 = v10
		else
			v8 = v10 - 1
		end
	end

	return v9
end

local v8 = {}
local v9 = {}

local function getChartShift(childName, p)
	local success, result = pcall(require, SongConfig)
	local v10

	if success and type(result) == "table" and result.Songs then
		v10 = result.Songs[childName] or nil
	end

	if not v10 then
		return 0
	end

	local offset = v10.Offset or 0

	if type(v10.InstrumentOffsets) == "table" then
		offset += v10.InstrumentOffsets[p] or 0
	end

	return if math.abs(offset) < 1 then 0 else offset
end

local function collapse(list, chartShift)
	local result = {}
	local v10 = chartShift or 0

	for _, item in ipairs(list) do
		if not (type(item) == "table" and type(item.Time) == "number" and type(item.Lane) == "number") then
			continue
		end

		result[#result + 1] = item
	end

	table.sort(result, function(a, b): boolean
		return a.Time < b.Time
	end)
	local v11 = nil
	local v12 = {}

	for _, v13 in ipairs(result) do
		local duration = type(v13.Duration) == "number" and v13.Duration or 0
		local v14 = v13.Time - v10

		if v11 and v14 - v11.t <= 0.03 then
			local v15 = false

			for _, lane in ipairs(v11.lanes) do
				if lane == v13.Lane then
					v15 = true
					break
				end
			end

			if not v15 then
				v11.lanes[#v11.lanes + 1] = v13.Lane
			end

			if v11.dur < duration then
				v11.dur = duration
			end
		else
			v11 = {
				t = v14,
				lanes = { v13.Lane },
				dur = duration
			}
			v12[#v12 + 1] = v11
		end
	end

	local result2 = {}

	for _, v13 in ipairs(v12) do
		if v13.t >= 0 then
			result2[#result2 + 1] = v13
		end
	end

	return result2, result
end

local function computeWindow(p, p2)
	local v10 = 0

	for _, event in pairs(p.events) do
		local v11 = event[#event]

		if v11 and v10 < v11.t then
			v10 = v11.t
		end
	end

	local nW = math.max(1, (math.ceil((v10 + 0.001) / p2)))
	local counts = {}
	local avg = {}

	for k, list in pairs(p.events) do
		local v11 = table.create(nW, 0)

		for _, item in ipairs(list) do
			local v12 = math.clamp(math.floor(item.t / p2) + 1, 1, nW)
			v11[v12] += 1
		end

		counts[k] = v11
		avg[k] = math.max(0.5, #list / nW)
	end

	return { nW = nW, counts = counts, avg = avg }
end

local function computeDrops(data, p)
	local drops = {}
	local v10 = data.win[2]

	if not v10 or v10.nW < 6 then
		return drops
	end

	local v11 = table.create(v10.nW, 0)

	for k, count in pairs(v10.counts) do
		if not (p == nil or p[k]) then
			continue
		end

		for i = 1, v10.nW do
			v11[i] += count[i]
		end
	end

	local firstNote = data.firstNote or 0
	local v12 = -1000000000

	for i = 3, v10.nW - 1 do
		local midpoint = (v11[i] + v11[i + 1]) / 2
		local midpoint2 = (v11[i - 1] + v11[i - 2]) / 2
		local v13 = (i - 1) * 2

		if not (midpoint >= 10 and math.max(midpoint2, 1) * 1.8 <= midpoint and v11[i - 1] <= 0.6 * midpoint and v13 - v12 >= 14) then
			continue
		end

		if not (firstNote + 8 < v13) then
			continue
		end

		local t = nil

		for k, event in pairs(data.events) do
			local v14

			if p == nil or p[k] then
				v14 = event[lowerBound(event, v13 - 0.001)] or nil
			end

			if v14 and v14.t < v13 + 2 and (not t or v14.t < t) then
				t = v14.t
			end
		end

		if not t then
			continue
		end

		drops[#drops + 1] = { t = t }
		v12 = t
	end

	return drops
end

local function computeCues(p)
	local v10 = 0

	for _, event in pairs(p.events) do
		local v11 = event[#event]

		if v11 and v10 < v11.t then
			v10 = v11.t
		end
	end

	p.lastNote = v10 > 0 and v10 or nil
	p.drops = computeDrops(p, nil)
end

local function buildSongData(childName)
	local songData = { events = {}, kicks = {}, firstNote = nil, win = {} }
	local child = ChartData:FindFirstChild(childName)

	if child then
		local success, result = pcall(require, child)

		if success and type(result) == "table" then
			for _, v10 in ipairs(v4) do
				local v11 = result[v10]

				if type(v11) == "table" and #v11 > 0 then
					local chartShift = getChartShift(childName, v10)
					local v12, v13 = collapse(v11, chartShift)

					if #v12 > 0 then
						songData.events[v10] = v12

						if not songData.firstNote or v12[1].t < songData.firstNote then
							songData.firstNote = v12[1].t
						end

						if v10 == "Drum" then
							local v14 = -1

							for _, v15 in ipairs(v13) do
								local v16 = v15.Time - chartShift

								if not (v15.Lane == 1 and v16 >= 0 and v16 - v14 >= 0.045) then
									continue
								end

								songData.kicks[#songData.kicks + 1] = { t = v16 }
								v14 = v16
							end
						end
					end
				end

				task.wait()
			end
		end
	end

	songData.win[8] = computeWindow(songData, 8)
	songData.win[10] = computeWindow(songData, 10)
	songData.win[2] = computeWindow(songData, 2)
	computeCues(songData)
	return songData
end

local function getSongData(p, fn)
	local v10 = v8[p]

	if v10 then
		fn(v10)
		return
	end

	if v9[p] then
		task.spawn(function()
			while v9[p] do
				task.wait(0.1)
			end

			fn(v8[p])
		end)
		return
	end

	v9[p] = true
	task.spawn(function()
		local success, result = pcall(buildSongData, p)
		v9[p] = nil

		if not success then
			warn("[StageLighting] Gagal bangun data lagu:", p, result)

			return
		end

		v8[p] = result
		fn(result)
	end)
end

local v10 = { 0, 3, 4, 8, 10, 12 }
local v11 = nil

local function getDemoData()
	if v11 then
		return v11
	end

	local function add(list, p, p2) -- 4 equivalent calls inferred from this helper
		list[#list + 1] = {
			t = p,
			lanes = { p2 },
			dur = 0.1
		}
	end

	local guitarLead = {}
	local guitarRhythm = {}
	local bass = {}
	local v12 = { events = {}, kicks = {}, firstNote = 0, win = {} }
	local drum = {}

	for i = 0, 11 do
		local v13 = i % 3
		local v14 = i * 8
		local v15 = v13 == 0 and 0.125 or 1
		local v16 = v13 == 1 and 0.25 or 1
		local v17 = v13 == 2 and 0.25 or 1
		local v18 = v14

		while v18 < v14 + 8 - 1e-6 do
			add(guitarLead, v18, math.floor(v18 * 8) % 5 + 1) -- inferred equivalent call
			v18 += v15
		end

		local v19 = v14

		while v19 < v14 + 8 - 1e-6 do
			add(guitarRhythm, v19, math.floor(v19 * 4) % 5 + 1) -- inferred equivalent call
			v19 += v16
		end

		local v20 = v14

		while v20 < v14 + 8 - 1e-6 do
			add(bass, v20, math.floor(v20 * 2) % 4 + 1) -- inferred equivalent call
			v20 += v17
		end
	end

	for i = 0, 23 do
		for _, v13 in ipairs(v10) do
			local v14 = i * 4 + v13 * 0.25
			v12.kicks[#v12.kicks + 1] = { t = v14 }
			add(drum, v14, 1) -- inferred equivalent call
		end
	end

	v12.events = { GuitarLead = guitarLead, GuitarRhythm = guitarRhythm, Bass = bass, Drum = drum }
	v12.win[8] = computeWindow(v12, 8)
	v12.win[10] = computeWindow(v12, 10)
	v12.win[2] = computeWindow(v12, 2)
	computeCues(v12)
	v11 = v12
	return v12
end

local function buildSegments(data, p, list, p2, p3)
	local v12 = data.win[p]

	if not v12 then
		return {}
	end

	local v13 = 0
	local v14 = nil
	local result = {}

	for i = 1, v12.nW do
		local src = false

		if p3 == "dominant" then
			local v15 = 0
			local v16 = nil

			for _, item in ipairs(list) do
				if not (p2[item] and v12.counts[item]) then
					continue
				end

				local v17 = v12.counts[item][i] / v12.avg[item]

				if not (v12.counts[item][i] > 0 and v15 < v17) then
					continue
				end

				v16 = item
				v15 = v17
			end

			if v16 then
				if v14 and p2[v14] and v12.counts[v14] and v12.counts[v14][i] > 0 then
					local v17 = v12.counts[v14][i] / v12.avg[v14]

					if v15 * 0.8 <= v17 then
						v16 = v14
					end
				end

				src = v16
			end
		else
			local set = {}

			for _, item in ipairs(list) do
				if p2[item] and (v12.counts[item] and v12.counts[item][i] or 0) >= 2 then
					set[item] = true
				end
			end

			for j = 1, #list do
				local v15 = (v13 + j - 1) % #list + 1

				if set[list[v15]] then
					src = list[v15]
					v13 = v15
					break
				end
			end
		end

		v14 = src or v14
		local t0 = (i - 1) * p
		local t1 = i * p
		local v15 = result[#result]

		if v15 and v15.src == src then
			v15.t1 = t1
		else
			result[#result + 1] = { t0 = t0, t1 = t1, src = src }
		end
	end

	return result
end

local function newLamp(kind, p)
	return {
		kind = kind,
		spots = {},
		beams = {},
		lenses = {},
		labels = {},
		screen = nil,
		base = p or Color3.new(1, 1, 1),
		flashLevel = 0,
		flashColor = p or Color3.new(1, 1, 1),
		decay = 8,
		glow = 0,
		glowColor = p or Color3.new(1, 1, 1),
		hold = nil,
		holdLevel = 0,
		dispLevel = 1,
		dispColor = p or Color3.new(1, 1, 1),
		sway = 0,
		swayTarget = 0,
		swayF = 0,
		swayFTarget = 0,
		lastRollT = -1000000000,
		rest = true,
		lastLevel = nil,
		lastColor = nil,
		lastLite = nil
	}
end

local function collectInto(state, part, p)
	if p and part:IsA("BasePart") then
		state.lenses[#state.lenses + 1] = { inst = part, col = part.Color }
	end

	for _, descendant in ipairs(part:GetDescendants()) do
		if descendant:IsA("SpotLight") then
			state.spots[#state.spots + 1] = {
				inst = descendant,
				br = descendant.Brightness,
				col = descendant.Color,
				en = descendant.Enabled,
				range = descendant.Range,
				angle = descendant.Angle
			}
		elseif descendant:IsA("Beam") then
			local attachment0 = descendant.Attachment0
			state.beams[#state.beams + 1] = {
				inst = descendant,
				col = descendant.Color,
				tr = descendant.Transparency,
				en = descendant.Enabled,
				bright = descendant.Brightness,
				w0 = descendant.Width0,
				att0 = attachment0,
				base0 = attachment0 and attachment0.WorldPosition or nil
			}
		elseif descendant:IsA("BasePart") and descendant.Name == "Lens" then
			state.lenses[#state.lenses + 1] = { inst = descendant, col = descendant.Color }
		elseif descendant:IsA("BasePart") and descendant.Name == "Screen" then
			state.screen = { inst = descendant, col = descendant.Color }
		elseif descendant:IsA("TextLabel") then
			state.labels[#state.labels + 1] = { inst = descendant, text = descendant.Text }
		end
	end
end

local function applyLamp(state, data, value, lastLite)
	local lastLevel = math.clamp(value, 0, 1)

	if
		state.lastLevel
		and state.lastLite == lastLite
		and math.abs(lastLevel - state.lastLevel) < 0.01
		and colorDiff(data, state.lastColor) < 0.02 -- inferred equivalent call
		and state.lastSway == state.sway
		and state.lastSwayF == state.swayF
	then
		return
	end

	local sway = state.sway
	local swayF = state.swayF
	state.lastLevel = lastLevel
	state.lastColor = data
	state.lastLite = lastLite
	state.lastSway = sway
	state.lastSwayF = swayF
	state.rest = false
	local enabled = lastLevel > 0.02

	if lastLite and state.kind == "ayrton" then
		for _, spot in ipairs(state.spots) do
			spot.inst.Enabled = false
		end

		for _, beam in ipairs(state.beams) do
			beam.inst.Enabled = false
		end
	else
		local v12 = state.kind == "parfect"
		local v13 = lastLevel * lastLevel * (3 - 2 * lastLevel)
		local v14 = v and (kickBoost2 - 1) * 0.5 + 1 or kickBoost2
		local v15 = (v2 * 0.15 + 0.85) * 150

		for _, spot in ipairs(state.spots) do
			spot.inst.Color = data

			if v12 then
				spot.inst.Brightness = spot.br * v14 * v13
				spot.inst.Range = spot.range + (v15 - spot.range) * v13
				spot.inst.Angle = spot.angle + (105 - spot.angle) * v13
			else
				spot.inst.Brightness = spot.br * lastLevel
			end

			spot.inst.Enabled = enabled
		end

		local colorSequence = ColorSequence.new(data)
		local numberSequence = NumberSequence.new(1 - lastLevel)

		for _, beam in ipairs(state.beams) do
			beam.inst.Color = colorSequence
			beam.inst.Transparency = numberSequence
			beam.inst.Enabled = enabled

			if not v12 then
				continue
			end

			beam.inst.Brightness = beam.bright + (2.5 - beam.bright) * v13
			beam.inst.Width0 = beam.w0 * (1 + 0.35 * v13)

			if not (beam.att0 and beam.lateral) then
				continue
			end

			local swayF2 = state.swayF
			local v16 = math.max(swayF2, 0)
			beam.att0.WorldPosition = beam.base0 + beam.lateral * (state.sway * sway2 * (v16 * 0.6 + 1)) + beam.forward * (swayF2 * forward2) + Vector3.new(0, v16 * 5, 0)
		end
	end

	local lerped = color:Lerp(data, lastLevel)

	for _, lens in ipairs(state.lenses) do
		lens.inst.Color = lerped
	end

	if state.screen then
		state.screen.inst.Color = color:Lerp(data, 0.25 + 0.75 * lastLevel)
	end
end

local function restoreLamp(state)
	for _, spot in ipairs(state.spots) do
		spot.inst.Color = spot.col
		spot.inst.Brightness = spot.br
		spot.inst.Enabled = spot.en
		spot.inst.Range = spot.range
		spot.inst.Angle = spot.angle
	end

	for _, beam in ipairs(state.beams) do
		beam.inst.Color = beam.col
		beam.inst.Transparency = beam.tr
		beam.inst.Enabled = beam.en
		beam.inst.Brightness = beam.bright
		beam.inst.Width0 = beam.w0

		if beam.att0 and beam.base0 then
			beam.att0.WorldPosition = beam.base0
		end
	end

	for _, lens in ipairs(state.lenses) do
		lens.inst.Color = lens.col
	end

	if state.screen then
		state.screen.inst.Color = state.screen.col
	end

	for _, label in ipairs(state.labels) do
		label.inst.Text = label.text
	end

	state.rest = true
	state.sway = 0
	state.swayF = 0
	state.lastLevel = nil
	state.lastColor = nil
	state.lastSway = nil
	state.lastSwayF = nil
	local base = state.base
	state.dispLevel = 1
	state.dispColor = base
	state.flashLevel = 0
	state.hold = nil
	state.sm = nil
end

local function trigger(state, flashColor, flashLevel, decay)
	if v then
		local now = os.clock()

		if now - (state.lastTrig or -1) < 0.34 then
			return
		end

		state.lastTrig = now
		flashLevel = math.min(flashLevel, 0.6)
		decay = math.min(decay, 3)
	end

	if state.flashLevel * 0.7 <= flashLevel then
		state.flashColor = flashColor
	end

	if state.flashLevel < flashLevel then
		state.flashLevel = flashLevel
	end

	state.decay = decay
end

local function triggerSmooth(state, flashColor, peak, rise, fall)
	if v then
		local now = os.clock()

		if now - (state.lastTrig or -1) < 0.34 then
			return
		end

		state.lastTrig = now
		peak = math.min(peak, 0.6)
		rise = math.max(rise, 0.1)
		fall = math.max(fall, 0.4)
	end

	local flashLevel = state.flashLevel

	if flashLevel * 0.7 <= peak then
		state.flashColor = flashColor
	end

	if peak <= flashLevel * 1.02 then
		state.sm = {
			from = flashLevel,
			peak = flashLevel,
			t = rise,
			rise = rise,
			fall = fall
		}
	else
		state.sm = {
			from = flashLevel,
			peak = peak,
			t = 0,
			rise = rise,
			fall = fall
		}
	end
end

local function lampOutput(state, p, lastSongTime)
	local sm = state.sm
	local v12

	if sm then
		sm.t += p

		if sm.t < sm.rise then
			local v13 = sm.t / sm.rise
			v12 = sm.from + (sm.peak - sm.from) * (1 - (1 - v13) ^ 3)
		else
			local v13 = math.min(1, (sm.t - sm.rise) / sm.fall)

			local v14 = math.min(state.glow, sm.peak)
			v12 = v14 + (sm.peak - v14) * (math.cos(3.141592653589793 * v13) * 0.5 + 0.5)

			if v13 >= 1 then
				state.sm = nil
				v12 = 0
			end
		end
	else
		v12 = state.flashLevel * math.exp(-state.decay * p)

		if state.hold then
			if lastSongTime < state.hold then
				v12 = math.max(v12, state.holdLevel)
			else
				state.hold = nil
			end
		end
	end

	local flashLevel = v12 < 0.005 and 0 or v12

	state.flashLevel = flashLevel

	if state.glow < flashLevel then
		return state.flashColor, flashLevel
	end

	return state.glowColor, state.glow
end

local function findLampModel(stageKIT, list)
	for _, child in ipairs(stageKIT:GetChildren()) do
		local name = child.Name:lower()
		local flag = true

		for _, item in ipairs(list) do
			if not name:find(item:lower(), 1, true) then
				flag = false
				break
			end
		end

		if flag then
			return child
		end
	end

	return nil
end

local function pivotPosition(model) -- 4 equivalent calls inferred from this helper
	if model:IsA("Model") then
		return model:GetPivot().Position
	end

	return model.Position
end

local function buildRig(child)
	local stageKIT = child:FindFirstChild("Stage KIT", true)

	if not stageKIT then
		return nil
	end

	local lampModel = findLampModel(stageKIT, { "parfect", "kiri" })
	local lampModel2 = findLampModel(stageKIT, { "parfect", "kanan" })
	local lampModel3 = findLampModel(stageKIT, { "par1", "kiri" })
	local lampModel4 = findLampModel(stageKIT, { "par1", "kanan" })
	local lampModel5 = findLampModel(stageKIT, { "ayrton" })

	if not (lampModel and lampModel2 and lampModel3 and lampModel4 and lampModel5) then
		return nil
	end

	local lights = lampModel5:FindFirstChild("Lights", true)

	if not lights then
		return nil
	end

	local v12 = {
		parfect = {},
		par1 = {},
		ayr = {},
		ayrZones = { {}, {}, {}, {}, {} },
		all = {}
	}

	for i, v13 in ipairs({ lampModel, lampModel2 }) do
		local v14 = newLamp("parfect")
		collectInto(v14, v13, false)

		for _, beam in ipairs(v14.beams) do
			if not (beam.att0 and beam.inst.Attachment1) then
				continue
			end

			local v15 = (beam.base0 - beam.inst.Attachment1.WorldPosition) * Vector3.new(1, 0, 1)

			if not (v15.Magnitude > 0.01) then
				continue
			end

			local unit = v15.Unit
			beam.lateral = Vector3.new(-unit.Z, 0, unit.X)
			beam.forward = unit
		end

		v14.swayTarget = i == 1 and 0.001 or -0.001
		v14.base = v14.spots[1] and v14.spots[1].col or v14.base
		local base = v14.base
		local base2 = v14.base
		local base3 = v14.base
		v14.flashColor = base
		v14.glowColor = base2
		v14.dispColor = base3
		v12.parfect[i] = v14
		v12.all[#v12.all + 1] = v14
	end

	for i, v13 in ipairs({ lampModel3, lampModel4 }) do
		local v14 = newLamp("par1")
		collectInto(v14, v13, false)
		v14.base = v14.spots[1] and v14.spots[1].col or v14.base
		local base = v14.base
		local base2 = v14.base
		local base3 = v14.base
		v14.flashColor = base
		v14.glowColor = base2
		v14.dispColor = base3
		v12.par1[i] = v14
		v12.all[#v12.all + 1] = v14
	end

	local v13 = pivotPosition(lampModel4) - pivotPosition(lampModel3) -- inferred equivalent call

	local unit = v13.Magnitude > 0.001 and v13.Unit or Vector3.new(1, 0, 0)
	local parts = {}

	for _, part in ipairs(lights:GetChildren()) do
		if part:IsA("BasePart") and part.Name:match("^Light%d+$") then
			parts[#parts + 1] = part
		end
	end

	if #parts == 0 then
		return nil
	end

	table.sort(parts, function(a, b): boolean
		return a.Position:Dot(unit) < b.Position:Dot(unit)
	end)

	local count = #parts
	local v14 = { 0, 0, 0, 0, 0 }
	local v15 = count // 5

	v14[1] = v15
	v14[2] = v15
	v14[3] = v15
	v14[4] = v15
	v14[5] = v15

	for i = 1, count % 5 do
		local v16 = v7[i]
		v14[v16] += 1
	end

	local count2 = 0

	for i = 1, 5 do
		for _ = 1, v14[i] do
			count2 += 1
			local inst = parts[count2]

			if not inst then
				continue
			end

			local v16 = newLamp("ayrton")
			collectInto(v16, inst, true)
			v16.base = v16.spots[1] and v16.spots[1].col or inst.Color
			local base = v16.base
			local base2 = v16.base
			local base3 = v16.base
			v16.flashColor = base
			v16.glowColor = base2
			v16.dispColor = base3
			v16.zone = i
			v16.index = count2
			v12.ayr[#v12.ayr + 1] = v16
			table.insert(v12.ayrZones[i], v16)
			v12.all[#v12.all + 1] = v16
		end
	end

	v12.center = (pivotPosition(lampModel3) + pivotPosition(lampModel4)) / 2 -- inferred equivalent call
	return v12
end

local function C(p, p2, p3) -- 105 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local function par1Styles(colors, colors5, colors6, list, list2, list3)
	return {
		GuitarLead = {
			colors = colors,
			peak = list[1],
			decay = list[2],
			minGap = list[3],
			mode = list[4],
			short = "LEAD",
			num = "001"
		},
		GuitarRhythm = {
			colors = colors5,
			peak = list2[1],
			decay = list2[2],
			minGap = list2[3],
			mode = list2[4],
			short = "RHYTHM",
			num = "002"
		},
		Bass = {
			colors = colors6,
			peak = list3[1],
			decay = list3[2],
			minGap = list3[3],
			mode = list3[4],
			short = "BASS",
			num = "003"
		}
	}
end

local profiles = {}

profiles.Classic = {
	name = "Classic",
	zone = zone2,
	par1 = par,
	kickColor = kickColor2,
	burst = burst2,
	spA = spA2,
	spB = spB2,
	soloColor = v3,
	soloStyle = soloStyle2,
	ember = ember2,
	dark = dark2,
	kickRise = kickRise2,
	kickFall = kickFall2,
	kickFallMin = kickFallMin2,
	kickFallMax = kickFallMax2,
	kickFloor = kickFloor2,
	kickBoost = kickBoost2,
	kickPeak = kickPeak2,
	kickOther = kickOther2,
	kickBump = kickBump2,
	sway = sway2,
	swaySpeed = swaySpeed2,
	forward = forward2,
	doubleGap = doubleGap2,
	doubleFall = doubleFall2,
	ayrPeak = ayrPeak2,
	ayrDecay = ayrDecay2,
	ayrStep = ayrStep2,
	idleHue = idleHue2,
	idleSat = idleSat2
}

local function extend(items) -- 5 equivalent calls inferred from this helper
	local clone = table.clone(profiles.Classic)

	for k, item in pairs(items) do
		clone[k] = item
	end

	return clone
end

local v12 = { "Classic", "Punk", "Warm", "Ice", "Duotone", "Midnight" }

profiles.Punk = extend({ -- inferred equivalent call
	name = "Punk",
	zone = { C(225, 30, 45), C(255, 85, 35), C(255, 236, 214), C(255, 160, 50), C(170, 20, 35) }, -- inferred equivalent call
	par1 = par1Styles(
		{ C(255, 60, 50), C(255, 120, 45), C(255, 245, 225), C(255, 40, 70), C(255, 175, 70) }, -- inferred equivalent call
		{ C(235, 35, 45), C(255, 90, 40), C(255, 215, 160), C(200, 25, 40), C(255, 140, 60) }, -- inferred equivalent call
		{ C(170, 20, 35), C(210, 40, 40), C(255, 110, 40), C(140, 15, 30), C(230, 70, 45) }, -- inferred equivalent call
		{ 1, 11, 0, "alt" },
		{ 1, 9, 0.05, "both" },
		{ 0.95, 5, 0.1, "both" }
	),
	kickColor = C(255, 240, 225), -- inferred equivalent call
	burst = C(255, 236, 214), -- inferred equivalent call
	spA = C(255, 60, 45), -- inferred equivalent call
	spB = C(255, 240, 225), -- inferred equivalent call
	soloColor = C(205, 60, 55), -- inferred equivalent call
	soloStyle = { peak = 0.85, decay = 3.2, minGap = 0.08 },
	ember = 0.03,
	dark = 0.03,
	kickRise = 0.03,
	kickFall = 0.3,
	kickFallMin = 0.1,
	kickFallMax = 0.5,
	kickFloor = 0.1,
	kickBoost = 2.6,
	kickBump = 0.55,
	sway = 14,
	swaySpeed = 5.5,
	doubleGap = 0.7,
	doubleFall = 0.6,
	ayrDecay = 8,
	ayrStep = 1.2,
	idleHue = 0.02,
	idleSat = 0.85
})

profiles.Warm = extend({ -- inferred equivalent call
	name = "Warm",
	zone = { C(255, 170, 70), C(250, 130, 60), C(255, 205, 120), C(240, 120, 90), C(255, 230, 190) }, -- inferred equivalent call
	par1 = par1Styles(
		{ C(255, 175, 85), C(255, 210, 140), C(250, 145, 70), C(255, 235, 195), C(240, 120, 80) }, -- inferred equivalent call
		{ C(255, 150, 60), C(240, 115, 50), C(255, 195, 110), C(220, 95, 60), C(255, 225, 170) }, -- inferred equivalent call
		{ C(200, 90, 40), C(170, 70, 35), C(230, 120, 50), C(150, 60, 35), C(210, 100, 55) }, -- inferred equivalent call
		{ 0.8, 3, 0, "alt" },
		{ 0.75, 2, 0.12, "both" },
		{ 0.7, 1.2, 0.2, "both" }
	),
	kickColor = C(255, 225, 180), -- inferred equivalent call
	burst = C(255, 225, 185), -- inferred equivalent call
	spA = C(255, 180, 70), -- inferred equivalent call
	spB = C(255, 235, 200), -- inferred equivalent call
	soloColor = C(255, 170, 90), -- inferred equivalent call
	soloStyle = { peak = 0.75, decay = 1.6, minGap = 0.15 },
	ember = 0.1,
	dark = 0.08,
	kickRise = 0.12,
	kickFall = 0.9,
	kickFallMin = 0.5,
	kickFallMax = 2,
	kickFloor = 0.3,
	kickBoost = 1.6,
	sway = 8,
	swaySpeed = 1.6,
	doubleGap = 1.2,
	doubleFall = 1.6,
	ayrPeak = 0.85,
	ayrDecay = 3.2,
	ayrStep = 0.5,
	idleHue = 0.08,
	idleSat = 0.7
})

profiles.Ice = extend({ -- inferred equivalent call
	name = "Ice",
	zone = { C(90, 220, 255), C(45, 90, 235), C(215, 235, 255), C(60, 185, 200), C(110, 100, 240) }, -- inferred equivalent call
	par1 = par1Styles(
		{ C(150, 225, 255), C(70, 140, 255), C(230, 240, 255), C(100, 190, 230), C(130, 110, 255) }, -- inferred equivalent call
		{ C(60, 130, 255), C(90, 200, 240), C(190, 215, 255), C(40, 100, 220), C(120, 160, 255) }, -- inferred equivalent call
		{ C(25, 60, 190), C(50, 50, 175), C(20, 130, 170), C(40, 90, 200), C(70, 60, 160) }, -- inferred equivalent call
		{ 1, 9, 0, "alt" },
		{ 0.95, 6.5, 0.05, "both" },
		{ 0.85, 3, 0.1, "both" }
	),
	kickColor = C(225, 240, 255), -- inferred equivalent call
	burst = C(215, 235, 255), -- inferred equivalent call
	spA = C(140, 210, 255), -- inferred equivalent call
	spB = C(240, 248, 255), -- inferred equivalent call
	soloColor = C(120, 170, 245), -- inferred equivalent call
	soloStyle = { peak = 0.8, decay = 3, minGap = 0.1 },
	ember = 0.04,
	kickRise = 0.04,
	kickFall = 0.4,
	kickFallMin = 0.12,
	kickFallMax = 1,
	kickFloor = 0.14,
	kickBoost = 2.4,
	sway = 11,
	swaySpeed = 4.5,
	ayrDecay = 7,
	ayrStep = 1,
	idleHue = 0.58,
	idleSat = 0.55
})

profiles.Duotone = extend({ -- inferred equivalent call
	name = "Duotone",
	zone = { C(40, 210, 190), C(230, 60, 160), C(255, 225, 240), C(60, 170, 230), C(245, 100, 150) }, -- inferred equivalent call
	par1 = par1Styles(
		{ C(235, 70, 165), C(255, 120, 190), C(255, 220, 240), C(200, 50, 150), C(255, 90, 140) }, -- inferred equivalent call
		{ C(50, 215, 195), C(70, 180, 235), C(190, 245, 235), C(40, 160, 170), C(100, 225, 210) }, -- inferred equivalent call
		{ C(130, 60, 200), C(100, 50, 180), C(170, 70, 190), C(80, 60, 170), C(150, 80, 210) }, -- inferred equivalent call
		{ 1, 6, 0, "alt" },
		{ 0.95, 5, 0.06, "alt" },
		{ 0.85, 2.5, 0.12, "both" }
	),
	kickColor = C(255, 240, 250), -- inferred equivalent call
	burst = C(255, 230, 245), -- inferred equivalent call
	spA = C(255, 90, 190), -- inferred equivalent call
	spB = C(255, 235, 250), -- inferred equivalent call
	soloColor = C(190, 120, 225), -- inferred equivalent call
	soloStyle = { peak = 0.8, decay = 2.4, minGap = 0.1 },
	ember = 0.05,
	kickRise = 0.05,
	kickFall = 0.5,
	kickFallMin = 0.2,
	kickFallMax = 1.1,
	kickFloor = 0.2,
	kickBoost = 2,
	sway = 10,
	swaySpeed = 3.5,
	ayrDecay = 6,
	ayrStep = 0.8,
	idleHue = 0.85,
	idleSat = 0.55
})

profiles.Midnight = extend({ -- inferred equivalent call
	name = "Midnight",
	zone = { C(255, 175, 70), C(60, 60, 175), C(255, 230, 185), C(45, 120, 190), C(225, 110, 50) }, -- inferred equivalent call
	par1 = par1Styles(
		{ C(255, 185, 85), C(255, 215, 140), C(240, 150, 60), C(255, 235, 190), C(225, 120, 55) }, -- inferred equivalent call
		{ C(80, 80, 200), C(60, 100, 210), C(120, 110, 225), C(50, 70, 170), C(95, 130, 225) }, -- inferred equivalent call
		{ C(35, 45, 140), C(55, 45, 150), C(30, 85, 150), C(45, 60, 160), C(70, 55, 140) }, -- inferred equivalent call
		{ 0.9, 4, 0, "alt" },
		{ 0.85, 3, 0.08, "both" },
		{ 0.8, 1.8, 0.14, "both" }
	),
	kickColor = C(255, 235, 200), -- inferred equivalent call
	burst = C(255, 232, 195), -- inferred equivalent call
	spA = C(255, 190, 80), -- inferred equivalent call
	spB = C(255, 240, 210), -- inferred equivalent call
	soloColor = C(240, 170, 80), -- inferred equivalent call
	soloStyle = { peak = 0.8, decay = 2, minGap = 0.12 },
	ember = 0.07,
	kickRise = 0.08,
	kickFall = 0.7,
	kickFallMin = 0.3,
	kickFallMax = 1.6,
	kickFloor = 0.24,
	kickBoost = 1.8,
	sway = 9,
	swaySpeed = 2.2,
	ayrDecay = 4.5,
	ayrStep = 0.7,
	idleHue = 0.65,
	idleSat = 0.5
})

local v13 = profiles.Classic
local function applyProfile(data)
	if data == v13 then
		return
	end

	v13 = data
	local zone = data.zone
	local par1 = data.par1
	zone2 = zone
	par = par1
	local kickColor = data.kickColor
	local burst = data.burst
	local spA = data.spA
	local spB = data.spB
	kickColor2 = kickColor
	burst2 = burst
	spA2 = spA
	spB2 = spB
	local soloColor = data.soloColor
	local soloStyle = data.soloStyle
	local ember = data.ember
	local dark = data.dark
	v3 = soloColor
	soloStyle2 = soloStyle
	ember2 = ember
	dark2 = dark
	local kickRise = data.kickRise
	local kickFall = data.kickFall
	local kickFallMin = data.kickFallMin
	local kickFallMax = data.kickFallMax
	kickRise2 = kickRise
	kickFall2 = kickFall
	kickFallMin2 = kickFallMin
	kickFallMax2 = kickFallMax
	local kickFloor = data.kickFloor
	local kickBoost = data.kickBoost
	local kickPeak = data.kickPeak
	local kickOther = data.kickOther
	local kickBump = data.kickBump
	kickFloor2 = kickFloor
	kickBoost2 = kickBoost
	kickPeak2 = kickPeak
	kickOther2 = kickOther
	kickBump2 = kickBump
	local sway = data.sway
	local swaySpeed = data.swaySpeed
	local forward = data.forward
	sway2 = sway
	swaySpeed2 = swaySpeed
	forward2 = forward
	local doubleGap = data.doubleGap
	local doubleFall = data.doubleFall
	doubleGap2 = doubleGap
	doubleFall2 = doubleFall
	local ayrPeak = data.ayrPeak
	local ayrDecay = data.ayrDecay
	local ayrStep = data.ayrStep
	local idleHue = data.idleHue
	local idleSat = data.idleSat
	ayrPeak2 = ayrPeak
	ayrDecay2 = ayrDecay
	ayrStep2 = ayrStep
	idleHue2 = idleHue
	idleSat2 = idleSat
end

local set = {}
local function resolveProfile(p)
	local success, result = pcall(require, SongConfig)
	local v14

	if success and type(result) == "table" and result.Songs then
		v14 = result.Songs[p] or nil
	end

	local v15 = v14 and v14.LightStyle

	if v15 == nil then
		return profiles.Classic
	end

	if type(v15) == "string" then
		local lower = v15:lower()

		for _, v16 in ipairs(v12) do
			if v16:lower() == lower then
				return profiles[v16]
			end
		end

		v15 = tonumber(v15) or v15
	end

	if type(v15) == "number" and v12[v15] then
		return profiles[v12[v15]]
	end

	if not set[tostring(v15)] then
		set[tostring(v15)] = true
		warn("[StageLighting] LightStyle tidak dikenal:", v15, "(lagu:", p, ") -> pakai Classic")
	end

	return profiles.Classic
end

local stages = {}
local flag = false

local function newState(child, rig)
	return {
		inst = child,
		rig = rig,
		mode = nil,
		near = true,
		lodAt = 0,
		session = nil,
		song = nil,
		data = nil,
		segKey = nil,
		instruments = nil,
		instrStr = nil,
		playerInstr = {},
		alive = {},
		spUntil = 0,
		spLevel = 1,
		par1 = {},
		ayr = {},
		kick = {},
		needSeek = true,
		lastSongTime = nil,
		burstPending = false,
		labelSrc = nil,
		songSeed = 17,
		profile = profiles.Classic,
		energy = 1,
		cfg = StageLightConfig.Default(),
		cfgStr = nil
	}
end

local function resetTracks(p)
	p.par1 = {}
	p.ayr = {}
	p.kick = {}
	p.solo = nil
	p.soloKind = nil
	p.soloTr = {}
	p.segKey = nil
	p.lastSongTime = nil
	p.needSeek = true
	p.labelSrc = nil
	p.finaleDone = false
	p.lastDrop = nil
end

local function onSessionChanged(state, lightSession, lightSong)
	state.session = lightSession
	state.song = lightSong
	state.profile = lightSong and resolveProfile(lightSong) or profiles.Classic
	local songSeed = 17

	for i = 1, #(lightSong or "") do
		songSeed = (songSeed * 31 + string.byte(lightSong, i)) % 2147483647
	end

	state.songSeed = songSeed
	state.data = nil
	state.alive = {}
	state.spUntil = 0
	state.spPlayers = nil
	state.energy = 1
	resetTracks(state)

	if lightSong then
		getSongData(lightSong, function(p)
			if state.session == lightSession and p then
				state.data = p
				state.segKey = nil
			end
		end)
	end
end

local function decodeInstruments(state, lightInstruments)
	state.instrStr = lightInstruments
	state.instruments = nil
	state.playerInstr = {}

	if type(lightInstruments) == "string" and lightInstruments ~= "" then
		local success, result = pcall(function()
			return HttpService:JSONDecode(lightInstruments)
		end)

		if success and type(result) == "table" then
			state.instruments = {}

			for k, v14 in pairs(result) do
				state.instruments[k] = true
				local playerName

				if type(v14) == "table" then
					playerName = v14.PlayerName or nil
				end

				if type(playerName) == "string" and Players:FindFirstChild(playerName) then
					state.playerInstr[playerName] = k
				end
			end
		end
	end

	state.segKey = nil
end

local function refreshState(state)
	local inst = state.inst
	local lightSession = inst:GetAttribute("LightSession")
	local lightSong = inst:GetAttribute("LightSong")

	if lightSession ~= state.session or lightSong ~= state.song then
		onSessionChanged(state, lightSession, lightSong)
	end

	local lightInstruments = inst:GetAttribute("LightInstruments")

	if lightInstruments ~= state.instrStr then
		decodeInstruments(state, lightInstruments)
	end

	local lightCandidates = inst:GetAttribute("LightCandidates")

	if lightCandidates ~= state.candStr then
		state.candStr = lightCandidates

		if type(lightCandidates) == "string" and state.near and not SettingsState.GetStageLightingLite() then
			local success, result = pcall(function()
				return HttpService:JSONDecode(lightCandidates)
			end)

			if success and type(result) == "table" then
				for i, v14 in ipairs(result) do
					if not (i <= 3) or type(v14) ~= "string" or (v8[v14] or v9[v14]) then
						continue
					end

					getSongData(v14, function() end)
				end
			end
		end
	end

	local lightCfg = inst:GetAttribute("LightCfg")

	if lightCfg ~= state.cfgStr then
		state.cfgStr = lightCfg
		state.cfg = StageLightConfig.Decode(lightCfg)
		state.needSeek = true
	end
end

local function buildSoloSegments(data, items)
	local v14 = {}
	local soloSegments = {}

	for k in pairs(items) do
		if data.events[k] then
			v14[#v14 + 1] = k
		end
	end

	if #v14 < 2 then
		return soloSegments
	end

	local v15 = {}

	for _, instr in ipairs(v14) do
		v15[#v15 + 1] = { instr = instr, t = data.events[instr][1].t }
	end

	table.sort(v15, function(a, b): boolean
		return a.t < b.t
	end)
	local t1

	if v15[2].t - v15[1].t >= 2 then
		t1 = v15[2].t
		soloSegments[#soloSegments + 1] = { t0 = 0, t1 = t1, kind = "intro", src = v15[1].instr }
	else
		t1 = 0
	end

	local v16 = data.win[2]

	if not v16 then
		return soloSegments
	end

	local src = nil
	local t0 = nil
	local t1_2 = nil
	local function flush() -- 4 equivalent calls inferred from this helper
		if src and t1_2 - t0 >= 4 then
			soloSegments[#soloSegments + 1] = { t0 = t0, t1 = t1_2, kind = "solo", src = src }
		end

		src = nil
	end

	for i = 1, v16.nW do
		local v17 = (i - 1) * 2
		local v18 = i * 2

		if v18 <= t1 then
			flush() -- inferred equivalent call
		else
			local count = 0
			local v19 = nil

			for _, v20 in ipairs(v14) do
				local count2 = v16.counts[v20]

				if not (count2 and count2[i] > 0) then
					continue
				end

				count += 1
				v19 = v20
			end

			if count == 1 then
				if src ~= v19 then
					flush() -- inferred equivalent call
					src = v19
					t0 = math.max(v17, t1)
				end

				t1_2 = v18
			else
				flush() -- inferred equivalent call
			end
		end
	end

	flush() -- inferred equivalent call
	return soloSegments
end

local function candidateSet(state, list)
	local result = {}

	for _, item in ipairs(list) do
		if state.data.events[item] and (state.instruments == nil or state.instruments[item]) then
			result[item] = true
		end
	end

	return result
end

local function ensureSegments(state)
	local segKey = tostring(state.data) .. "|" .. tostring(state.instrStr)

	if state.segKey == segKey then
		return
	end

	state.segKey = segKey
	state.par1.segs = buildSegments(state.data, 8, v5, candidateSet(state, v5), "dominant")
	state.ayr.segs = buildSegments(state.data, 10, v6, candidateSet(state, v6), "rotate")
	local par1 = state.par1
	local ayr = state.ayr
	par1.segIdx = nil
	ayr.segIdx = nil
	state.solo = {
		segs = buildSoloSegments(state.data, candidateSet(state, v6))
	}
	state.drops = computeDrops(state.data, candidateSet(state, v6))
	state.needSeek = true
end

local function soloAt(state, lastSongTime) -- 1 equivalent call inferred from this helper
	local segs = state.solo and state.solo.segs

	if not segs or #segs == 0 then
		return nil
	end

	local seg = segs[segIndexFor(segs, lastSongTime)]

	if seg and seg.t0 <= lastSongTime and lastSongTime < seg.t1 then
		return seg
	end

	return nil
end

local function computeMode(state, p)
	if not state.song then
		return "normal"
	end

	local inst = state.inst
	local lightPlayAt = inst:GetAttribute("LightPlayAt")
	local lightStartAt = inst:GetAttribute("LightStartAt")
	local lightDuration = inst:GetAttribute("LightDuration")

	if type(lightPlayAt) ~= "number" or type(lightStartAt) ~= "number" then
		return "normal"
	end

	local lightPausedAt = inst:GetAttribute("LightPausedAt")
	local v14 = type(lightPausedAt) == "number" and lightPausedAt or p - lightStartAt

	if type(lightDuration) == "number" and lightDuration + 2 < v14 then
		return "normal"
	end

	local data = state.data

	if data then
		state.holdSince = nil

		if type(lightPausedAt) == "number" and (data.firstNote or 0) - 0.05 <= lightPausedAt then
			return "paused"
		end

		local v15 = lightPlayAt + 3
		local v16 = data.firstNote and lightStartAt + data.firstNote - 0.05 or v15 + 4

		if v16 - v15 < 1 then
			v15 = math.max(lightPlayAt, v16 - 1)
		end

		if p < v15 then
			return "normal"
		end

		if p < v16 then
			return "dark", (p - v15) / (v16 - v15)
		end

		return "song", v14
	end

	if state.mode == "song" then
		state.holdSince = state.holdSince or p

		if p - state.holdSince < 3 then
			return "hold"
		end
	end

	return "normal"
end

local function stepNormal(state, p, lastLite)
	for _, v14 in ipairs(state.rig.all) do
		if v14.rest then
			continue
		end

		local v15 = 1 - math.exp(-p * 3)
		v14.dispLevel += (1 - v14.dispLevel) * v15
		v14.dispColor = v14.dispColor:Lerp(v14.base, v15)
		v14.sway *= math.exp(-p * 3)
		v14.swayF *= math.exp(-p * 3)

		if 1 - v14.dispLevel < 0.02 and colorDiff(v14.dispColor, v14.base) < 0.03 then -- inferred equivalent call
			restoreLamp(v14)
			continue
		end

		applyLamp(v14, v14.dispColor, v14.dispLevel, lastLite)
	end
end

local function stepDark(state, value, lastLite)
	local dispLevel = 1 - (1 - dark2) * smoothstep(value) -- inferred equivalent call

	for _, v14 in ipairs(state.rig.all) do
		v14.flashLevel = 0
		v14.hold = nil
		v14.sm = nil
		local base = v14.base
		v14.dispLevel = dispLevel
		v14.dispColor = base
		applyLamp(v14, v14.base, dispLevel, lastLite)
	end
end

local function runTrack(state, events, lastSongTime, p, fn)
	local segs = state.segs

	if not segs or #segs == 0 then
		state.src = false
		return
	end

	if p or not state.segIdx then
		state.segIdx = segIndexFor(segs, lastSongTime)
		state.forceSwitch = true
	end

	while state.segIdx < #segs and segs[state.segIdx].t1 <= lastSongTime do
		state.segIdx += 1
	end

	local seg = segs[state.segIdx]

	if lastSongTime < seg.t0 or seg.t1 <= lastSongTime then
		state.src = false
		return
	end

	local src = seg.src

	if src ~= state.src or state.forceSwitch then
		state.forceSwitch = false
		state.src = src
		local evIdx

		if src then
			evIdx = lowerBound(events[src], lastSongTime) or nil
		end

		state.evIdx = evIdx
		state.t0 = seg.t0
	end

	if not src then
		return
	end

	local v14 = events[src]
	local evIdx = state.evIdx

	while evIdx <= #v14 and v14[evIdx].t <= lastSongTime do
		local v15 = v14[evIdx]

		if v15.t >= state.t0 and lastSongTime - v15.t < 0.25 then
			fn(src, v15)
		end

		evIdx += 1
	end

	state.evIdx = evIdx
end

local function setPar1Labels(rig, p)
	local v14 = p and par[p]
	local v15 = p == "solo"
	local v16 = p == "static" and "STATIC" or p == "breathe" and "BREATHE" or nil

	for _, v17 in ipairs(rig.par1) do
		for _, label in ipairs(v17.labels) do
			if label.text == "ADDRESS" then
				label.inst.Text = v16 or v15 and "SOLO" or v14 and v14.short or "IDLE"
			else
				label.inst.Text = v14 and v14.num or "000"
			end
		end
	end
end

local v14 = { parfect = "kick", par1 = "par1", ayrton = "ayrton" }

local function overrideColor(p, p2) -- 4 equivalent calls inferred from this helper
	local v15 = p.colors[p2] or p.colors.all
	return v15 and StageLightConfig.ToColor3(v15) or nil
end

local function adjustOutput(p, p2, p3, p4)
	local v15 = v14[p2.kind]

	if not p.groups[v15] then
		return p3, 0
	end

	return overrideColor(p, v15) or p3, p4 * (p.brightness / 100) -- inferred equivalent call
end

local function stepStatic(state, p, lastFire, lastLite, p2)
	local cfg = state.cfg
	local rig = state.rig
	local soloColor = v13.soloColor

	for _, v15 in ipairs(rig.all) do
		local v16 = v14[v15.kind]
		local dispColor = overrideColor(cfg, v16) or soloColor -- inferred equivalent call
		local dispLevel

		if cfg.groups[v16] then
			if p2 then
				local v17 = v15.kind == "ayrton" and (v15.index or 0) * 0.35
					or (v15 == rig.parfect[2] or v15 == rig.par1[2]) and 3.141592653589793
					or 0
				dispLevel = ((math.sin(lastFire * 1.1 + v17) * 0.5 + 0.5) * 0.6 + 0.3) * (cfg.brightness / 100)
			else
				dispLevel = 0.9 * (cfg.brightness / 100)
			end
		else
			dispLevel = 0
		end

		v15.flashLevel = 0
		v15.hold = nil
		v15.sm = nil
		v15.sway *= math.exp(-p * 3)
		v15.swayF *= math.exp(-p * 3)
		v15.dispLevel = dispLevel
		v15.dispColor = dispColor
		applyLamp(v15, dispColor, dispLevel, lastLite)
	end

	local labelSrc = p2 and "breathe" or "static"

	if state.labelSrc ~= labelSrc then
		state.labelSrc = labelSrc
		setPar1Labels(rig, labelSrc)
	end

	state.needSeek = true
	state.soloKind = nil
end

local function stepPause(state, p, lastLite)
	local cfg = state.cfg
	local v15 = 1 - math.exp(-p * 2.5)

	for _, v16 in ipairs(state.rig.all) do
		v16.flashLevel = 0
		v16.hold = nil
		v16.sm = nil
		v16.sway *= math.exp(-p * 2)
		v16.swayF *= math.exp(-p * 2)
		v16.dispLevel += (0.18 - v16.dispLevel) * v15
		local v17 = v16.dispColor
		local dispLevel = v16.dispLevel
		local v18 = v14[v16.kind]
		local v19

		if cfg.groups[v18] then
			local v20 = overrideColor(cfg, v18) -- inferred equivalent call
			v19 = dispLevel * (cfg.brightness / 100)
			v17 = v20 or v17
		else
			v19 = 0
		end

		applyLamp(v16, v17, v19, lastLite)
	end

	state.needSeek = true
	state.lastSongTime = nil
end

local function soloistPosition(state, src)
	for childName, v15 in pairs(state.playerInstr) do
		if v15 ~= src then
			continue
		end

		local child = Players:FindFirstChild(childName)
		local character = child and child.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			return humanoidRootPart.Position
		end
	end

	return nil
end

local function stepSong(state, p, lastSongTime, lastFire, lastLite)
	local rig = state.rig
	local data = state.data
	local cfg = state.cfg
	local needSeek = state.needSeek
	local lastSongTime2 = state.lastSongTime
	local v15 = lastSongTime2 and (lastSongTime - lastSongTime2 > 1 or lastSongTime < lastSongTime2 - 0.15) and true
		or needSeek

	state.lastSongTime = lastSongTime
	state.needSeek = false
	ensureSegments(state)
	local v16

	if lastFire < state.spUntil then
		v16 = cfg.spfx
	else
		v16 = false
	end

	local spLevel = state.spLevel or 1

	if cfg.mode ~= "Beat" then
		stepStatic(state, p, lastFire, lastLite, cfg.mode == "Breathe")
		return
	end

	local v17

	if cfg.solo then
		v17 = soloAt(state, lastSongTime) or nil -- inferred equivalent call
	end

	local kind

	if v17 then
		kind = v17.kind or nil
	else
		kind = nil
	end

	if kind ~= state.soloKind then
		local soloKind = state.soloKind
		state.soloKind = kind
		state.soloTr = {}
		v15 = true

		if kind == "solo" then
			for _, v18 in ipairs(rig.all) do
				v18.hold = nil
				v18.flashColor = v3
			end
		end

		if soloKind == "intro" then
			state.burstPending = false

			for _, v18 in ipairs(rig.all) do
				local flashColor = burst2
				local flashLevel = 1
				local decay = 2.6

				if v then
					local now = os.clock()

					if now - (v18.lastTrig or -1) < 0.34 then
						continue
					end

					v18.lastTrig = now
					flashLevel = math.min(flashLevel, 0.6)
					decay = math.min(decay, 3)
				end

				if v18.flashLevel * 0.7 <= flashLevel then
					v18.flashColor = flashColor
				end

				if v18.flashLevel < flashLevel then
					v18.flashLevel = flashLevel
				end

				v18.decay = decay
			end
		end
	end

	if kind == "intro" then
		state.burstPending = false

		for _, v18 in ipairs(rig.all) do
			v18.flashLevel = 0
			v18.hold = nil
			v18.sm = nil
			local dispLevel = dark2
			local base = v18.base
			v18.dispLevel = dispLevel
			v18.dispColor = base
			applyLamp(v18, v18.base, dark2, lastLite)
		end
	else
		local v18

		if kind == "solo" and not v16 then
			v18 = v3 or nil
		else
			v18 = nil
		end

		if state.burstPending and data.firstNote and data.firstNote <= lastSongTime then
			state.burstPending = false

			for _, v19 in ipairs(rig.all) do
				local flashColor = burst2
				local flashLevel = 1
				local decay = 2.6

				if v then
					local now = os.clock()

					if now - (v19.lastTrig or -1) < 0.34 then
						continue
					end

					v19.lastTrig = now
					flashLevel = math.min(flashLevel, 0.6)
					decay = math.min(decay, 3)
				end

				if v19.flashLevel * 0.7 <= flashLevel then
					v19.flashColor = flashColor
				end

				if v19.flashLevel < flashLevel then
					v19.flashLevel = flashLevel
				end

				v19.decay = decay
			end
		end

		local lightCinematic = state.inst:GetAttribute("LightCinematic") ~= false
		local v19 = 1
		local v20 = 1
		local drops = state.drops or data.drops

		if lightCinematic and drops and #drops > 0 and kind == nil then
			local drop = drops[lowerBound(drops, lastSongTime - 0.35)]

			if drop then
				local v21 = drop.t - lastSongTime

				if v21 > 0 and v21 <= 1.4 then
					v19 = 1 - 0.7 * smoothstep((1.4 - v21) / 1.4) -- inferred equivalent call
				elseif v21 <= 0 and state.lastDrop ~= drop.t then
					state.lastDrop = drop.t

					for _, v22 in ipairs(rig.all) do
						local flashColor = burst2
						local flashLevel = 1
						local decay = 2.2

						if v then
							local now = os.clock()

							if now - (v22.lastTrig or -1) < 0.34 then
								continue
							end

							v22.lastTrig = now
							flashLevel = math.min(flashLevel, 0.6)
							decay = math.min(decay, 3)
						end

						if v22.flashLevel * 0.7 <= flashLevel then
							v22.flashColor = flashColor
						end

						if v22.flashLevel < flashLevel then
							v22.flashLevel = flashLevel
						end

						v22.decay = decay
					end
				end
			end
		end

		local lastNote = data.lastNote

		if lightCinematic and lastNote and not state.demo then
			local lightDuration = state.inst:GetAttribute("LightDuration")
			local v21 = type(lightDuration) == "number" and lightDuration - lastNote or 0
			local v22 = lastSongTime - (lastNote + 0.05)

			if v22 < 0 then
				state.finaleDone = false
			elseif v21 < 45 then
				if not state.finaleDone and v22 < 1 then
					state.finaleDone = true

					for _, v23 in ipairs(rig.all) do
						local flashColor = burst2
						local flashLevel = 1
						local decay = 0.9

						if v then
							local now = os.clock()

							if now - (v23.lastTrig or -1) < 0.34 then
								continue
							end

							v23.lastTrig = now
							flashLevel = math.min(flashLevel, 0.6)
							decay = math.min(decay, 3)
						end

						if v23.flashLevel * 0.7 <= flashLevel then
							v23.flashColor = flashColor
						end

						if v23.flashLevel < flashLevel then
							v23.flashLevel = flashLevel
						end

						v23.decay = decay
					end

					if rig.parfect[1] and rig.parfect[2] then
						local v23 = rig.parfect[1]
						local v24 = rig.parfect[1]
						v23.swayTarget = 0.9
						v24.swayFTarget = 1
						local v25 = rig.parfect[2]
						local v26 = rig.parfect[2]
						v25.swayTarget = -0.9
						v26.swayFTarget = 1
					end
				end

				v20 = 1 - 0.65 * smoothstep(v22 / 5) -- inferred equivalent call
			end
		end

		local v21 = #data.kicks > 0

		for i, v22 in ipairs(rig.parfect) do
			local glow = kickFloor2
			local glowColor = v18 or v22.base
			v22.glow = glow
			v22.glowColor = glowColor

			if v16 then
				local glow2 = 0.18 + 0.06 * spLevel
				local glowColor2 = spB2
				v22.glow = glow2
				v22.glowColor = glowColor2
			elseif not v21 then
				v22.glow = math.max(0, (math.sin(lastFire * 1.9 + (i == 1 and 0 or 3.141592653589793)))) * 0.28 + 0.1
			end
		end

		if lightCinematic and kind == "solo" and cfg.sway and v17.src ~= "Drum" then
			local v22 = soloistPosition(state, v17.src)

			if v22 then
				for _, v23 in ipairs(rig.parfect) do
					local beam = v23.beams[1]

					if not (beam and beam.lateral and beam.forward and beam.base0) then
						continue
					end

					local vector = (v22 - beam.base0) * Vector3.new(1, 0, 1)
					local swayFTarget = math.clamp(vector:Dot(beam.forward) / forward2, -0.15, 1.15)
					local v24 = math.max(swayFTarget, 0)
					v23.swayTarget = math.clamp(vector:Dot(beam.lateral) / (sway2 * (v24 * 0.6 + 1)), -1.2, 1.2)
					v23.swayFTarget = swayFTarget
					v23.glow = math.max(v23.glow, 0.5)
					v23.glowColor = v18 or v23.base
				end
			end
		end

		local v22 = 1 - math.exp(-p * swaySpeed2)

		for _, v23 in ipairs(rig.parfect) do
			local swayTarget = cfg.sway and v23.swayTarget or 0
			local swayFTarget = cfg.sway and v23.swayFTarget or 0
			v23.sway += (swayTarget - v23.sway) * v22
			v23.swayF += (swayFTarget - v23.swayF) * v22
		end

		if v21 then
			local kick = state.kick

			if v15 or not kick.idx then
				kick.idx = lowerBound(data.kicks, lastSongTime)
			end

			while kick.idx <= #data.kicks and data.kicks[kick.idx].t <= lastSongTime do
				if lastSongTime - data.kicks[kick.idx].t < 0.25 then
					kick.flip = not kick.flip
					local v23 = kick.flip and rig.parfect[1] or rig.parfect[2]
					local v24 = kick.flip and rig.parfect[2] or rig.parfect[1]
					local flashColor = v16 and spB2:Lerp(spA2, 0.5) or v18 or kickColor2

					local kick2 = data.kicks[kick.idx + 1]
					local v25 = math.clamp(
						kick2 and kick2.t - data.kicks[kick.idx].t or kickFall2,
						kickFallMin2,
						kickFallMax2
					)
					local v26 = math.min(kickRise2, v25 * 0.4)
					local t = data.kicks[kick.idx].t

					if t - v23.lastRollT >= 0.3 then
						v23.lastRollT = t
						local random = Random.new(state.songSeed + kick.idx * 7919 + (kick.flip and 1 or 2) * 104729)
						local v27 = v23.swayTarget >= 0 and 1 or -1
						v27 = random:NextNumber() < 0.7 and -v27 or v27
						v23.swayTarget = v27 * random:NextNumber(0.25, 1)
						v23.swayFTarget = -0.15 + 1.15 * random:NextNumber() ^ 0.7
					end

					local kick3 = data.kicks[kick.idx - 1]
					local v27 = kick3 and data.kicks[kick.idx].t - kick3.t or 1e999
					local v28 = kick2 and kick2.t - data.kicks[kick.idx].t or 1e999

					if doubleGap2 <= v27 and doubleGap2 <= v28 then
						local v29 = math.max(v25, doubleFall2)
						triggerSmooth(v23, flashColor, kickPeak2, v26, v29)
						triggerSmooth(v24, flashColor, kickPeak2, v26, v29)

						v24.lastRollT = t
						v24.swayTarget = -v23.swayTarget
						v24.swayFTarget = v23.swayFTarget
					else
						triggerSmooth(v23, flashColor, kickPeak2, v26, v25)

						if v24.flashLevel < kickOther2 then
							triggerSmooth(v24, flashColor, kickOther2, v26, v25)
						end
					end

					if v16 and spLevel >= 2 then
						if not v then
							for _, v29 in ipairs(rig.par1) do
								local flashColor2 = spB2
								local flashLevel = 0.7
								local decay = 10

								if v then
									local now = os.clock()

									if now - (v29.lastTrig or -1) < 0.34 then
										continue
									end

									v29.lastTrig = now
									flashLevel = math.min(flashLevel, 0.6)
									decay = math.min(decay, 3)
								end

								if v29.flashLevel * 0.7 <= flashLevel then
									v29.flashColor = flashColor2
								end

								if v29.flashLevel < flashLevel then
									v29.flashLevel = flashLevel
								end

								v29.decay = decay
							end
						end
					elseif kickBump2 > 0 and not v18 then
						for _, v29 in ipairs(rig.par1) do
							local flashLevel = kickBump2
							local decay = 12

							if v then
								local now = os.clock()

								if now - (v29.lastTrig or -1) < 0.34 then
									continue
								end

								v29.lastTrig = now
								flashLevel = math.min(flashLevel, 0.6)
								decay = math.min(decay, 3)
							end

							if v29.flashLevel * 0.7 <= flashLevel then
								v29.flashColor = flashColor
							end

							if v29.flashLevel < flashLevel then
								v29.flashLevel = flashLevel
							end

							v29.decay = decay
						end
					end
				end

				kick.idx += 1
			end
		end

		local par1 = state.par1
		local function fn(src, p2)
			local v23 = kind == "solo" and soloStyle2 or par[src]

			if not v23 or v23.minGap > 0 and par1.lastFire and lastFire - par1.lastFire < v23.minGap then
				return
			end

			par1.lastFire = lastFire
			local flashColor

			if v16 then
				par1.spFlip = not par1.spFlip
				flashColor = par1.spFlip and spA2 or spB2
			elseif v18 then
				flashColor = v18
			else
				flashColor = mixColor(v23.colors, p2.lanes) -- inferred equivalent call
			end

			local v24 = rig.par1[1]
			local v25 = rig.par1[2]
			local v26 = {}

			if v23.mode == "alt" then
				par1.flip = not par1.flip
				local v27 = par1.flip and v24 or v25
				v24 = par1.flip and v25 or v24
				local peak = v23.peak
				local decay = v23.decay

				if v then
					local now = os.clock()

					if not (now - (v27.lastTrig or -1) < 0.34) then
						v27.lastTrig = now
						peak = math.min(peak, 0.6)
						decay = math.min(decay, 3)

						if v27.flashLevel * 0.7 <= peak then
							v27.flashColor = flashColor
						end

						if v27.flashLevel < peak then
							v27.flashLevel = peak
						end

						v27.decay = decay
					end
				else
					if v27.flashLevel * 0.7 <= peak then
						v27.flashColor = flashColor
					end

					if v27.flashLevel < peak then
						v27.flashLevel = peak
					end

					v27.decay = decay
				end

				v26[1] = v27

				if v24.flashLevel < 0.3 then
					local flashLevel = 0.28
					local decay2 = v23.decay * 0.8

					if v then
						local now = os.clock()

						if not (now - (v24.lastTrig or -1) < 0.34) then
							v24.lastTrig = now
							flashLevel = math.min(flashLevel, 0.6)
							decay2 = math.min(decay2, 3)

							if v24.flashLevel * 0.7 <= flashLevel then
								v24.flashColor = flashColor
							end

							if v24.flashLevel < flashLevel then
								v24.flashLevel = flashLevel
							end

							v24.decay = decay2
						end
					else
						if v24.flashLevel * 0.7 <= flashLevel then
							v24.flashColor = flashColor
						end

						if v24.flashLevel < flashLevel then
							v24.flashLevel = flashLevel
						end

						v24.decay = decay2
					end
				end
			else
				local peak = v23.peak
				local decay = v23.decay

				if v then
					local now = os.clock()

					if not (now - (v24.lastTrig or -1) < 0.34) then
						v24.lastTrig = now
						peak = math.min(peak, 0.6)
						decay = math.min(decay, 3)

						if v24.flashLevel * 0.7 <= peak then
							v24.flashColor = flashColor
						end

						if v24.flashLevel < peak then
							v24.flashLevel = peak
						end

						v24.decay = decay
					end
				else
					if v24.flashLevel * 0.7 <= peak then
						v24.flashColor = flashColor
					end

					if v24.flashLevel < peak then
						v24.flashLevel = peak
					end

					v24.decay = decay
				end

				local flashLevel = v23.peak * 0.95
				local decay2 = v23.decay

				if v then
					local now = os.clock()

					if not (now - (v25.lastTrig or -1) < 0.34) then
						v25.lastTrig = now
						flashLevel = math.min(flashLevel, 0.6)
						decay2 = math.min(decay2, 3)

						if v25.flashLevel * 0.7 <= flashLevel then
							v25.flashColor = flashColor
						end

						if v25.flashLevel < flashLevel then
							v25.flashLevel = flashLevel
						end

						v25.decay = decay2
					end
				else
					if v25.flashLevel * 0.7 <= flashLevel then
						v25.flashColor = flashColor
					end

					if v25.flashLevel < flashLevel then
						v25.flashLevel = flashLevel
					end

					v25.decay = decay2
				end

				v26[1] = v24
				v26[2] = v25
			end

			if p2.dur > 0.25 then
				for _, v27 in ipairs(v26) do
					local hold = lastSongTime + p2.dur
					local holdLevel = v23.peak * 0.55
					v27.hold = hold
					v27.holdLevel = holdLevel
				end
			end
		end

		if kind == "solo" then
			local event = data.events[v17.src]

			if event then
				local v23 = state.soloTr.p1

				if not v23 then
					v23 = {}
					state.soloTr.p1 = v23
				end

				if v15 or not v23.evIdx then
					v23.evIdx = lowerBound(event, lastSongTime)
				end

				local evIdx = v23.evIdx

				while evIdx <= #event and event[evIdx].t <= lastSongTime do
					if lastSongTime - event[evIdx].t < 0.25 then
						fn(v17.src, event[evIdx])
					end

					evIdx += 1
				end

				v23.evIdx = evIdx
			end
		else
			runTrack(par1, data.events, lastSongTime, v15, fn)
		end

		local labelSrc = kind == "solo" and "solo" or par1.src or false

		for i, v23 in ipairs(rig.par1) do
			if labelSrc then
				local glow = ember2
				local glowColor = v18 or v23.base
				v23.glow = glow
				v23.glowColor = glowColor
			else
				v23.glow = (math.sin(lastFire * 1.3 + (i == 1 and 0 or 3.141592653589793)) * 0.5 + 0.5) * 0.25 + 0.1
				v23.glowColor = Color3.fromHSV(idleHue2 + math.sin(lastFire * 0.3) * 0.025, idleSat2, 1)
			end

			if not v16 then
				continue
			end

			local glow = math.max(v23.glow, 0.3)
			local glowColor = spA2
			v23.glow = glow
			v23.glowColor = glowColor
		end

		if state.labelSrc ~= labelSrc then
			state.labelSrc = labelSrc
			setPar1Labels(rig, labelSrc)
		end

		local ayr = state.ayr
		local function fn2(src, p2)
			if state.alive[src] == false then
				return
			end

			for _, lane in ipairs(p2.lanes) do
				local ayrZone = rig.ayrZones[lane]

				if not ayrZone then
					continue
				end

				local flashColor = v18 or zone2[lane]

				for i, v23 in ipairs(ayrZone) do
					if v18 then
						local flashLevel = 0.85
						local decay = lastLite and 4 or 3 + i * 0.5

						if v then
							local now = os.clock()

							if not (now - (v23.lastTrig or -1) < 0.34) then
								v23.lastTrig = now
								flashLevel = math.min(flashLevel, 0.6)
								decay = math.min(decay, 3)

								if v23.flashLevel * 0.7 <= flashLevel then
									v23.flashColor = flashColor
								end

								if v23.flashLevel < flashLevel then
									v23.flashLevel = flashLevel
								end

								v23.decay = decay
							end
						else
							if v23.flashLevel * 0.7 <= flashLevel then
								v23.flashColor = flashColor
							end

							if v23.flashLevel < flashLevel then
								v23.flashLevel = flashLevel
							end

							v23.decay = decay
						end
					else
						local flashLevel = ayrPeak2
						local decay = lastLite and 7 or ayrDecay2 + i * ayrStep2

						if v then
							local now = os.clock()

							if not (now - (v23.lastTrig or -1) < 0.34) then
								v23.lastTrig = now
								flashLevel = math.min(flashLevel, 0.6)
								decay = math.min(decay, 3)

								if v23.flashLevel * 0.7 <= flashLevel then
									v23.flashColor = flashColor
								end

								if v23.flashLevel < flashLevel then
									v23.flashLevel = flashLevel
								end

								v23.decay = decay
							end
						else
							if v23.flashLevel * 0.7 <= flashLevel then
								v23.flashColor = flashColor
							end

							if v23.flashLevel < flashLevel then
								v23.flashLevel = flashLevel
							end

							v23.decay = decay
						end
					end

					if not (p2.dur > 0.18) then
						continue
					end

					v23.hold = lastSongTime + p2.dur
					v23.holdLevel = 0.8
				end
			end
		end

		if kind == "solo" then
			local event = data.events[v17.src]

			if event then
				local ay = state.soloTr.ay

				if not ay then
					ay = {}
					state.soloTr.ay = ay
				end

				if v15 or not ay.evIdx then
					ay.evIdx = lowerBound(event, lastSongTime)
				end

				local evIdx = ay.evIdx

				while evIdx <= #event and event[evIdx].t <= lastSongTime do
					if lastSongTime - event[evIdx].t < 0.25 then
						fn2(v17.src, event[evIdx])
					end

					evIdx += 1
				end

				ay.evIdx = evIdx
			end
		else
			runTrack(ayr, data.events, lastSongTime, v15, fn2)
		end

		local v23 = kind == "solo" or (ayr.src or false)
		local _ = #rig.ayr

		for _, v24 in ipairs(rig.ayr) do
			if v16 then
				local v25 = math.sin(lastFire * 1.6 - v24.index * 0.5) * 0.5 + 0.5

				if lastLite then
					local glowColor = spA2
					v24.glow = 0.35
					v24.glowColor = glowColor
				else
					v24.glow = v25 * 0.25 + 0.3
					v24.glowColor = spA2:Lerp(spB2, v25)
				end
			elseif v23 then
				local base = v24.base
				v24.glow = 0
				v24.glowColor = base
			else
				local glow = (math.sin(lastFire * 1.5 - v24.zone * 0.6) * 0.5 + 0.5) * 0.3 + 0.1
				local glowColor = zone2[v24.zone]
				v24.glow = glow
				v24.glowColor = glowColor
			end
		end

		local v24 = (0.82 + 0.18 * (state.energy or 1)) * v19 * v20

		for _, v25 in ipairs(rig.all) do
			local dispColor, v26 = lampOutput(v25, p, lastSongTime)
			local v27 = v14[v25.kind]
			local v28

			if cfg.groups[v27] then
				local v29 = overrideColor(cfg, v27) -- inferred equivalent call
				v28 = v26 * (cfg.brightness / 100)
				dispColor = v29 or dispColor
			else
				v28 = 0
			end

			local dispLevel = v28 * v24
			v25.dispLevel = dispLevel
			v25.dispColor = dispColor
			applyLamp(v25, dispColor, dispLevel, lastLite)
		end
	end
end

local function stepStage(state, p, p2, lastFire, lastLite)
	local cfg = state.cfg
	applyProfile(cfg.style ~= "Song" and profiles[cfg.style] or state.profile or profiles.Classic)
	local energy = state.energy or 1
	local energy2 = energy + (1 - energy) * math.min(1, p * 0.04)
	state.energy = energy2
	v2 = energy2
	local v15, v16 = computeMode(state, p2)

	if state.demo and not state.song then
		local demoData = getDemoData()

		if state.data ~= demoData then
			state.data = demoData
			resetTracks(state)
		end

		v16 = (lastFire - (state.demoT0 or lastFire)) % 96
		v15 = "song"
	end

	local mode = not cfg.show and "normal" or v15

	if mode == "hold" then
		return
	end

	if mode ~= state.mode then
		if mode == "song" then
			state.needSeek = true
			state.lastSongTime = nil
			local firstNote = state.data and state.data.firstNote
			state.burstPending = firstNote ~= nil and v16 < firstNote + 0.6
		elseif mode == "normal" then
			for _, v17 in ipairs(state.rig.all) do
				v17.flashLevel = 0
				v17.hold = nil
				v17.sm = nil
			end

			state.labelSrc = nil
		end

		state.mode = mode
	end

	if mode == "normal" then
		stepNormal(state, p, lastLite)
	elseif mode == "dark" then
		stepDark(state, v16, lastLite)
	elseif mode == "paused" then
		stepPause(state, p, lastLite)
	else
		stepSong(state, p, v16, lastFire, lastLite)
	end
end

local total = 0
local v15 = nil

local function blackoutTarget(p, p2)
	if not p.song then
		return 0
	end

	local inst = p.inst
	local lightPlayAt = inst:GetAttribute("LightPlayAt")
	local lightStartAt = inst:GetAttribute("LightStartAt")
	local lightDuration = inst:GetAttribute("LightDuration")

	if type(lightPlayAt) ~= "number" or type(lightStartAt) ~= "number" or p2 < lightPlayAt then
		return 0
	end

	local lightPausedAt = inst:GetAttribute("LightPausedAt")
	local v16 = type(lightPausedAt) == "number" and lightPausedAt or p2 - lightStartAt

	if type(lightDuration) == "number" and lightDuration + 2 < v16 then
		return 0
	end

	if type(lightPausedAt) == "number" then
		return 1
	end

	local v17 = math.max(lightPlayAt, lightStartAt - 5)
	local v18 = math.max(v17 + 1.5, lightStartAt - 2)
	return (math.clamp((p2 - v17) / (v18 - v17), 0, 1))
end

local function stepNear(p, p2, p3, lastFire, lastLite)
	stepStage(p, p2, p3, lastFire, lastLite)
	return p.cfg.blackout and blackoutTarget(p, p3) or 0
end

local function step(p)
	local stageLightingLite = SettingsState.GetStageLightingLite()
	v = SettingsState.GetStageLightingReduceFlash()
	total += p

	if stageLightingLite and total < 0.05 then
		return
	end

	local v16 = total
	total = 0
	local serverTimeNow = Workspace:GetServerTimeNow()
	local now = os.clock()
	local currentCamera = Workspace.CurrentCamera
	local v17 = 0

	for k, v18 in pairs(stages) do
		if k.Parent then
			local success, result = pcall(refreshState, v18)

			if not success and result ~= v15 then
				v15 = result
				warn("[StageLighting] refresh " .. k.Name .. ":", result)
			end

			if now - v18.lodAt > 0.5 then
				v18.lodAt = now
				local near

				if currentCamera == nil then
					near = false
				else
					near = (currentCamera.CFrame.Position - v18.rig.center).Magnitude < 350
				end

				if near and not v18.near then
					v18.needSeek = true
				end

				v18.near = near
			end

			if v18.near then
				local success2, result2 = pcall(stepNear, v18, v16, serverTimeNow, now, stageLightingLite)

				if not success2 then
					if result2 ~= v15 then
						v15 = result2
						warn("[StageLighting] stage " .. k.Name .. ":", result2)
					end

					result2 = 0
				end

				if v17 < result2 then
					v17 = result2
				end
			end
		else
			stages[k] = nil
		end
	end

	StageBlackout.Update(v16, v17)
end

local function scanStages()
	local map = Workspace:FindFirstChild("Map")

	if not map then
		return
	end

	for _, child in ipairs(map:GetChildren()) do
		local studioId = child:GetAttribute("StudioId")

		if studioId == nil or not StageLightConfig.HasLights(studioId) or stages[child] then
			continue
		end

		local rig = buildRig(child)

		if rig then
			stages[child] = newState(child, rig)
		end
	end
end

local function connectRemotes()
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 30)

	if not remoteEvents then
		return
	end

	local broadcastJudgmentText = remoteEvents:WaitForChild("BroadcastJudgmentText", 30)

	if broadcastJudgmentText then
		broadcastJudgmentText.OnClientEvent:Connect(function(instance, p)
			if typeof(instance) ~= "Instance" then
				return
			end

			for _, v16 in pairs(stages) do
				local v17 = v16.playerInstr[instance.Name]

				if not v17 then
					continue
				end

				local v18 = p == "Miss" and 0 or p == "Wrong" and 0.4 or 1
				local energy = v16.energy or 1
				v16.energy = energy + (v18 - energy) * 0.1

				if p == "Miss" then
					v16.alive[v17] = false
				elseif p ~= "Wrong" then
					v16.alive[v17] = true
				end
			end
		end)
	end

	local broadcastStarPowerActivation = remoteEvents:WaitForChild("BroadcastStarPowerActivation", 30)

	if broadcastStarPowerActivation then
		broadcastStarPowerActivation.OnClientEvent:Connect(function(instance, value, p)
			for _, v16 in pairs(stages) do
				if not (v16.song and v16.song == p) then
					continue
				end

				local v17

				if typeof(instance) == "Instance" then
					v17 = v16.playerInstr[instance.Name] or nil
				end

				if not (v17 or next(v16.playerInstr) == nil) then
					continue
				end

				v16.spPlayers = v16.spPlayers or {}

				if typeof(instance) == "Instance" then
					v16.spPlayers[instance.Name] = true
				end

				local count = 0

				for _ in pairs(v16.spPlayers) do
					count += 1
				end

				v16.spUntil = os.clock() + RhythmEngineConfig.StarPowerMaxActiveSeconds
				v16.spLevel = count >= 2 and 3 or type(value) == "number" and value or 1
			end
		end)
	end

	local broadcastStarPowerEnd = remoteEvents:WaitForChild("BroadcastStarPowerEnd", 30)

	if broadcastStarPowerEnd then
		broadcastStarPowerEnd.OnClientEvent:Connect(function(instance)
			if typeof(instance) ~= "Instance" then
				return
			end

			for _, v16 in pairs(stages) do
				if not (v16.spPlayers and v16.spPlayers[instance.Name]) then
					continue
				end

				v16.spPlayers[instance.Name] = nil

				if next(v16.spPlayers) == nil then
					v16.spUntil = 0
				end
			end
		end)
	end
end

function StageLightingController.Start()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while true do
			local success, result = pcall(scanStages)

			if not success then
				warn("[StageLighting] scan:", result)
			end

			task.wait(next(stages) and 10 or 2)
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		local success, result = pcall(step, dt)

		if not success and result ~= v15 then
			v15 = result
			warn("[StageLighting] step:", result)
		end
	end)
	task.spawn(connectRemotes)
end

function StageLightingController.GetProfile(p)
	return profiles[p] or profiles.Classic
end

function StageLightingController.GetProfileForSong(p)
	if p then
		return resolveProfile(p)
	end

	return profiles.Classic
end

function StageLightingController.GetViewCFrame(p, p2)
	local v16 = stages[p]

	if not (v16 and v16.rig) then
		return nil
	end

	local rig = v16.rig
	local v17 = rig.parfect[1] and rig.parfect[1].beams[1]
	local forward = v17 and v17.forward or Vector3.new(0, 0, -1)
	local center = rig.center

	local v18 = rig.par1[2]
		and rig.par1[1]
		and rig.par1[2].spots[1]
		and rig.par1[1].spots[1]
		and rig.par1[2].spots[1].inst.Parent.Position - rig.par1[1].spots[1].inst.Parent.Position
		or Vector3.new(1, 0, 0)
	local vector3 = Vector3.new(v18.X, 0, v18.Z)
	local unit = vector3.Magnitude > 0.01 and vector3.Unit or Vector3.new(1, 0, 0)

	if p2 == "left" or p2 == "right" then
		local v19 = center + unit * (34 * (p2 == "right" and -1 or 1)) + forward * 10 + Vector3.new(0, -12, 0)
		return CFrame.lookAt(v19, center + forward * 10 + Vector3.new(0, -11, 0), Vector3.new(0, 1, 0)), 65
	end

	local v19 = center + forward * 36 + Vector3.new(0, -17, 0)
	return CFrame.lookAt(v19, center + Vector3.new(0, -5, 0), Vector3.new(0, 1, 0)), 65
end

function StageLightingController.SetDemo(p, p2): boolean
	local v16 = stages[p]

	if not v16 then
		return false
	end

	if p2 then
		v16.demo = true
		v16.demoT0 = os.clock()
	else
		v16.demo = false

		if not v16.song then
			v16.data = nil
			resetTracks(v16)
		end
	end

	return true
end

StageLightingController._Test = {
	buildRig = buildRig,
	buildSongData = buildSongData,
	buildSegments = buildSegments,
	buildSoloSegments = buildSoloSegments,
	soloAt = soloAt,
	PROFILES = profiles,
	PROFILE_ORDER = v12,
	resolveProfile = resolveProfile,
	applyProfile = applyProfile,
	newState = newState,
	stepStage = stepStage,
	restoreLamp = restoreLamp,
	refreshState = refreshState,
	stages = stages,
	PAR1_ORDER = v5,
	AYR_ORDER = v6,
	PAR1_WINDOW = 8,
	AYR_WINDOW = 10,
	onSessionChanged = onSessionChanged
}

return StageLightingController