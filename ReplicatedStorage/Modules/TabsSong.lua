local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TabsSong = {}

local v = {}

local function getLibrary() -- 2 equivalent calls inferred from this helper
	return ReplicatedStorage:FindFirstChild("TabsLibrary")
end

local function decode(value)
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local count = 0
	local total = 0
	local function push(value2)
		local v6, v7, v8, v9 = string.match(value2, "^([^,]+),([^,]+),([^,]+),?([^,]*)$")

		if not v6 then
			return
		end

		total += tonumber(v6, 36) or 0
		count += 1
		v2[count] = total
		v3[count] = math.max(1, tonumber(v7, 36) or 1)
		v4[count] = tonumber(v8, 36) or 0

		if v9 and v9 ~= "" then
			v5[count] = v9
		end
	end

	for k in string.gmatch(value, "[^;]+") do
		local v6, v7 = string.match(k, "^(%d+)%*(.+)$")

		if v6 then
			local v8 = string.split(v7, "|")

			for _ = 1, tonumber(v6) do
				for _, v9 in ipairs(v8) do
					push(v9)
				end
			end
		else
			push(k)
		end
	end

	return v2, v3, v4, count, v5
end

TabsSong.SECTION_CODES = {
	"i",
	"v",
	"p",
	"c",
	"b",
	"s",
	"r",
	"k",
	"o"
}
TabsSong.SECTION_NAMES = {
	i = "Intro",
	v = "Verse",
	p = "Pre-Chorus",
	c = "Chorus",
	b = "Bridge",
	s = "Solo",
	r = "Riff",
	k = "Break",
	o = "Outro"
}

function TabsSong.ParseSections(value)
	local result = {}
	local result2 = {}

	if type(value) ~= "string" then
		return result, result2
	end

	for k in string.gmatch(value, "[^;]+") do
		local v2, v3, v4 = string.match(k, "^(%d+):(%a)(%d?)$")
		local v5 = v3 and TabsSong.SECTION_NAMES[v3]

		if not (v2 and v5) then
			continue
		end

		local name = v5 .. ((v4 == nil or v4 == "") and "" or " " .. v4 or "")
		local bar = tonumber(v2)
		result[#result + 1] = {
			bar = bar,
			name = name,
			code = v3 .. (v4 or "")
		}
		result2[bar] = name
	end

	table.sort(result, function(a, b): boolean
		return a.bar < b.bar
	end)

	return result, result2
end

TabsSong.MIN_BEATS = 2
TabsSong.MAX_BEATS = 7
TabsSong.MIN_BPM = 30
TabsSong.MAX_BPM = 300

TabsSong.OCTAVE_LANE = 100

function TabsSong.SplitLane(p)
	if TabsSong.OCTAVE_LANE < p then
		return p - TabsSong.OCTAVE_LANE, true
	end

	return p, false
end

function TabsSong.LaneCode(p, p2, p3)
	if not p2 or p3 == "Drum" then
		return p
	end

	if (p - 1) % 13 == 0 then
		return p + 12
	end

	return p + TabsSong.OCTAVE_LANE
end

function TabsSong.LaneRowFret(p)
	local splitLane, v2 = TabsSong.SplitLane(p)
	return (splitLane - 1) // 13 + 1, (splitLane - 1) % 13 + (v2 and 12 or 0)
end

function TabsSong.CodeFromRowFret(p, p2)
	if p2 < 0 or p2 > 24 then
		return nil
	end

	if p2 <= 12 then
		return (p - 1) * 13 + p2 + 1
	end

	return (p - 1) * 13 + (p2 - 12) + 1 + TabsSong.OCTAVE_LANE
end

TabsSong.SIG_DENOMS = { 2, 4, 8, 16 }
TabsSong.MAX_SIG_NUM = 32

function TabsSong.MakeSig(value, value2)
	if type(value) ~= "number" or type(value2) ~= "number" then
		return nil
	end

	if value % 1 ~= 0 or value < 1 or TabsSong.MAX_SIG_NUM < value or not table.find(TabsSong.SIG_DENOMS, value2) then
		return nil
	end

	local beats = value * 4 / value2

	if beats < 0.75 or beats > 16 then
		return nil
	end

	return { n = value, d = value2, beats = beats }
end

function TabsSong.ParseChanges(value)
	local result = {}
	local result2 = {}

	if type(value) ~= "string" then
		return result, result2
	end

	for k in string.gmatch(value, "[^;]+") do
		local v2, v3, v4 = string.match(k, "^(%d+):([tb])([%d/]+)$")
		local v5 = tonumber(v2)

		if not (v5 and v5 >= 1) then
			continue
		end

		if v3 == "t" then
			local v6, v7 = string.match(v4, "^(%d+)/(%d+)$")

			if not v6 then
				v6 = string.match(v4, "^(%d+)$")
				v7 = "4"
			end

			local v8 = v6 and TabsSong.MakeSig(tonumber(v6), (tonumber(v7)))

			if v8 then
				result[v5] = v8
			end
		elseif v5 >= 2 then
			local v6 = tonumber(v4)

			if v6 and TabsSong.MIN_BPM <= v6 and v6 <= TabsSong.MAX_BPM then
				result2[v5] = v6
			end
		end
	end

	return result, result2
end

function TabsSong.FormatChanges(items, items2)
	local set = {}
	local v2 = {}

	for k in pairs(items) do
		if set[k] then
			continue
		end

		set[k] = true
		v2[#v2 + 1] = k
	end

	for k in pairs(items2) do
		if set[k] then
			continue
		end

		set[k] = true
		v2[#v2 + 1] = k
	end

	table.sort(v2)
	local v3 = {}

	for _, v4 in ipairs(v2) do
		local item = items[v4]

		if item then
			v3[#v3 + 1] = item.d == 4 and v4 .. ":t" .. item.n or v4 .. ":t" .. item.n .. "/" .. item.d
		end

		if items2[v4] then
			v3[#v3 + 1] = v4 .. ":b" .. items2[v4]
		end
	end

	return #v3 > 0 and table.concat(v3, ";") or nil
end

function TabsSong.ParseTones(value)
	local tones = {}

	if type(value) == "string" then
		for k in string.gmatch(value, "[^;]+") do
			local v2, name = string.match(k, "^(%d+):([%w _%-]+)$")
			local bar = tonumber(v2)

			if bar and bar >= 1 and name and #name <= 24 then
				tones[#tones + 1] = { bar = bar, name = name }
			end
		end
	end

	table.sort(tones, function(a, b): boolean
		return a.bar < b.bar
	end)

	return tones
end

function TabsSong.FormatTones(list)
	table.sort(list, function(a, b): boolean
		return a.bar < b.bar
	end)

	local v2 = {}

	for _, item in ipairs(list) do
		v2[#v2 + 1] = item.bar .. ":" .. item.name
	end

	return #v2 > 0 and table.concat(v2, ";") or nil
end

function TabsSong.MakeBarMap(value, value2, value3, p)
	local startBpb = value or 4
	local changes, bpmChanges = TabsSong.ParseChanges(p)
	local bars = math.max(0, value2 or 0)
	local v2 = startBpb
	local v3 = {}
	local starts = { 0 }

	for i = 1, bars do
		if changes[i] then
			v2 = changes[i].beats
		end

		v3[i] = v2
		starts[i + 1] = starts[i] + v2
	end

	local lastBeats

	if bars > 0 then
		lastBeats = v3[bars] or startBpb
	else
		lastBeats = startBpb
	end

	local v4 = {}
	local tempoBeat = { 0 }
	local tempoBpm = { value3 or 120 }

	for k in pairs(bpmChanges) do
		if k <= bars then
			v4[#v4 + 1] = k
		end
	end

	table.sort(v4)

	for _, v5 in ipairs(v4) do
		tempoBeat[#tempoBeat + 1] = starts[v5]
		tempoBpm[#tempoBpm + 1] = bpmChanges[v5]
	end

	local barMap = {
		Bars = bars,
		Starts = starts,
		LastBeats = lastBeats,
		Sig = changes,
		BpmChanges = bpmChanges,
		TempoBeat = tempoBeat,
		TempoBpm = tempoBpm,
		TotalBeats = starts[bars + 1],
		StartBpb = startBpb,
		StartBpm = value3 or 120,
		HasChanges = next(changes) ~= nil or next(bpmChanges) ~= nil
	}

	function barMap.BeatsOfBar(p2)
		return v3[p2] or lastBeats
	end

	function barMap.StartBeat(p2)
		if p2 < 1 then
			return (p2 - 1) * (v3[1] or startBpb)
		end

		if p2 <= bars + 1 then
			return starts[p2]
		end

		return starts[bars + 1] + (p2 - bars - 1) * lastBeats
	end

	function barMap.BarAtBeat(p2)
		if p2 < 0 then
			return math.floor(p2 / (v3[1] or startBpb)) + 1
		end

		if starts[bars + 1] <= p2 then
			return bars + 1 + math.floor((p2 - starts[bars + 1]) / lastBeats)
		end

		local v5 = bars
		local v6 = 1

		while v6 < v5 do
			local v7 = (v6 + v5 + 1) // 2

			if starts[v7] <= p2 then
				v6 = v7
			else
				v5 = v7 - 1
			end
		end

		return v6
	end

	function barMap.BpmAtBeat(p2)
		local v5 = tempoBpm[1]

		for i = 2, #tempoBeat do
			if tempoBeat[i] <= p2 then
				v5 = tempoBpm[i]
			else
				break
			end
		end

		return v5
	end

	return barMap
end

function TabsSong.FormatSections(list)
	table.sort(list, function(a, b): boolean
		return a.bar < b.bar
	end)
	local v2 = {}

	for _, item in ipairs(list) do
		v2[#v2 + 1] = item.bar .. ":" .. item.code
	end

	return table.concat(v2, ";")
end

function TabsSong.InstrumentFamily(p)
	if p == "GuitarLead" or p == "GuitarRhythm" or p == "Guitar" then
		return "Guitar"
	end

	return if p == "Bass" or p == "Drum" then p else nil
end

function TabsSong.ListSongs()
	local result = {}
	local library = getLibrary() -- inferred equivalent call

	if not library then
		return result
	end

	for _, folder in ipairs(library:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		local tracks = {}

		for _, moduleScript in ipairs(folder:GetChildren()) do
			if moduleScript:IsA("ModuleScript") then
				table.insert(tracks, {
					Id = moduleScript.Name,
					Name = moduleScript:GetAttribute("Name") or moduleScript.Name,
					Instrument = moduleScript:GetAttribute("Instrument"),
					Verified = moduleScript:GetAttribute("Verified") == true,
					Order = moduleScript:GetAttribute("Order") or 99
				})
			end
		end

		table.sort(tracks, function(a, b): boolean
			if a.Order == b.Order then
				return a.Id < b.Id
			end

			return a.Order < b.Order
		end)

		table.insert(result, {
			Id = folder.Name,
			Title = folder:GetAttribute("Title") or folder.Name,
			Artist = folder:GetAttribute("Artist") or "",
			Bpm = folder:GetAttribute("Bpm") or 120,
			Tracks = tracks
		})
	end

	table.sort(result, function(a, b): boolean
		return a.Title < b.Title
	end)

	return result
end

function TabsSong.Load(childName, childName2)
	local library = getLibrary() -- inferred equivalent call
	local child = library and library:FindFirstChild(childName)
	local moduleScript = child and child:FindFirstChild(childName2)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		return nil, "Track not found"
	end

	if v[moduleScript] then
		return v[moduleScript]
	end

	local success, result = pcall(require, moduleScript)

	if not success or type(result) ~= "string" then
		return nil, "Track data invalid"
	end

	local v2, v3, v4, v5, v6 = decode(result)
	local maxValue = 0

	for i = 1, v5 do
		maxValue = math.max(maxValue, v2[i] + v3[i])
	end

	local sections, sectionAt = TabsSong.ParseSections(child:GetAttribute("Sections"))
	local beatsPerBar = child:GetAttribute("BeatsPerBar") or 4
	local bars = child:GetAttribute("Bars") or 0
	local bpm = child:GetAttribute("Bpm") or 120
	local barMap = TabsSong.MakeBarMap(beatsPerBar, bars, bpm, child:GetAttribute("Changes"))
	local v7 = {
		SongId = childName,
		TrackId = childName2,
		Name = moduleScript:GetAttribute("Name") or childName2,
		Instrument = moduleScript:GetAttribute("Instrument"),
		Verified = moduleScript:GetAttribute("Verified") == true,
		Title = child:GetAttribute("Title") or childName,
		Artist = child:GetAttribute("Artist") or "",
		Bpm = child:GetAttribute("Bpm") or 120,
		Res = child:GetAttribute("Res") or 96,
		BeatsPerBar = child:GetAttribute("BeatsPerBar") or 4,
		Bars = child:GetAttribute("Bars") or 0,
		T = v2,
		D = v3,
		L = v4,
		K = v6,
		N = v5,
		Sections = sections,
		SectionAt = sectionAt,
		BarMap = barMap,
		Changes = child:GetAttribute("Changes"),
		Tones = TabsSong.ParseTones(child:GetAttribute("Tones")),
		EndUnits = maxValue
	}

	v[moduleScript] = v7
	return v7
end

function TabsSong.BuildTrack(data, value)
	local v2, v3, v4, v5, v6 = decode(value or "")
	local sections, sectionAt = TabsSong.ParseSections(data.Sections)
	local maxValue = 0

	for i = 1, v5 do
		maxValue = math.max(maxValue, v2[i] + v3[i])
	end

	local beatsPerBar = data.BeatsPerBar or 4
	local bars = data.Bars or 0
	local barMap = TabsSong.MakeBarMap(beatsPerBar, bars, data.Bpm or 120, data.Changes)
	return {
		SongId = data.SongId or "MyTabs",
		TrackId = data.TrackId or "",
		Name = data.Name or "My Tab",
		Instrument = data.Instrument,
		Verified = true,
		IsUser = true,
		Title = data.Title or "My Tab",
		Artist = data.Artist or "",
		Author = data.Author,
		Bpm = data.Bpm or 120,
		Res = 96,
		BeatsPerBar = beatsPerBar,
		Bars = bars,
		T = v2,
		D = v3,
		L = v4,
		K = v6,
		N = v5,
		Sections = sections,
		SectionAt = sectionAt,
		BarMap = barMap,
		Changes = data.Changes,
		Tones = TabsSong.ParseTones(data.Tones),
		EndUnits = math.max(maxValue, barMap.TotalBeats * 96)
	}
end

TabsSong._decode = decode

return TabsSong