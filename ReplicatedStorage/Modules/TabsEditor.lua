local UserInputService = game:GetService("UserInputService")

local TabsSong = require(script.Parent.TabsSong)
local TabsStore = require(script.Parent.TabsStore)
local TabsPlayer = require(script.Parent.TabsPlayer)
local InputRouter = require(script.Parent.InputRouter)
local TabsSkin = require(script.Parent.TabsSkin)
local PlayerLoadingState = require(script.Parent.PlayerLoadingState)

local v = {
	{ "HighCrash", "MediumCrash", "Splash", "China" },
	{ "RideEdge", "RideBell" },
	{ "FootHiHat", "OpenHiHat" },
	{ "HighTom" },
	{ "MidTom" },
	{ "Snare", "SideStick" },
	{ "FloorTom" },
	{ "BassDrum" },
	{ "Cowbell" }
}

local v2 = {}
local v3 = {
	{ "=GRID", 0 },
	{ "1/16", 24 },
	{ "1/8", 48 },
	{ "1/4", 96 },
	{ "1/2", 192 },
	{ "1", 384 },
	{ "1/8T", 32 },
	{ "1/16T", 16 },
	{ "1/32", 12 }
}
local v4 = {
	{ "1/16", 24 },
	{ "1/8", 48 },
	{ "1/4", 96 },
	{ "1/8T", 32 },
	{ "1/16T", 16 },
	{ "1/32", 12 }
}

local v5 = {
	"HighCrash",
	"Splash",
	"MediumCrash",
	"FootHiHat",
	"FootHiHat",
	"HighTom",
	"HighTom",
	"MidTom",
	"MidTom",
	"RideEdge",
	"RideBell",
	"OpenHiHat",
	"OpenHiHat",
	"Snare",
	"Snare",
	"SideStick",
	"BassDrum",
	"BassDrum",
	"FloorTom",
	"FloorTom",
	"China",
	"Cowbell"
}
local v6 = {
	HighCrash = 1,
	Splash = 2,
	MediumCrash = 3,
	FootHiHat = 4,
	HighTom = 6,
	MidTom = 8,
	RideEdge = 10,
	RideBell = 11,
	OpenHiHat = 12,
	Snare = 14,
	SideStick = 16,
	BassDrum = 17,
	FloorTom = 19,
	China = 21,
	Cowbell = 22
}
local TabsEditor = {}

local v7 = {
	HighCrash = "Crash 1",
	MediumCrash = "Crash 2",
	Splash = "Splash",
	China = "China",
	RideEdge = "Ride",
	RideBell = "Bell",
	FootHiHat = "Closed",
	OpenHiHat = "Open",
	Snare = "Snare",
	SideStick = "Stick",
	HighTom = "Tom 1",
	MidTom = "Tom 2",
	FloorTom = "Tom 3",
	BassDrum = "Kick",
	Cowbell = "Cowbell"
}

for i, list in ipairs(v) do
	for _, item in ipairs(list) do
		v2[item] = i
	end
end

local v8 = nil
local v9 = false
local instrument = "Guitar"
local v10 = nil
local notes = {}
local v11 = {}
local v12 = false
local v13 = 1
local v14 = 1

local function curDur() -- 5 equivalent calls inferred from this helper
	local v15 = v3[v14][2]

	if v15 == 0 then
		return v4[v13][2]
	end

	return v15
end

local v15 = nil
local count = 0
local flag = false

local editorBar = nil
local v16 = nil
local editorHits = nil
local editorCursor = nil
local v17 = nil
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = nil
local buttons = {}
local buttons2 = {}
local v25 = nil
local v26 = nil
local v27 = true
local v28 = nil
local v29 = false
local v30 = nil
local flag2 = false
local v31 = {}
local v32 = {}
local v35 = nil
local putNote
local handleSelectClick
local v36 = false
local v37 = nil
local v38 = nil
local editorSelection = nil
local v39 = nil
local v40 = nil
local v41 = nil
local v42 = nil
local v43 = nil
local v44 = nil
local v45 = nil
local v46 = nil
local buttons3 = {}
local v47 = {}
local v48 = nil
local v49 = nil

local function noteRow(p) -- 6 equivalent calls inferred from this helper
	if instrument ~= "Drum" then
		return (TabsSong.LaneRowFret(p))
	end

	local v50 = v5[p]
	return v50 and v2[v50]
end

local v50 = nil
local v51 = nil
local function barMap()
	local joined = table.concat({
		v10.BeatsPerBar,
		v10.Bars,
		v10.Bpm,
		v10.Changes or ""
	}, ",")

	if joined ~= v50 then
		v50 = joined
		v51 = TabsSong.MakeBarMap(v10.BeatsPerBar, v10.Bars, v10.Bpm, v10.Changes)
	end

	return v51
end

local function maxUnits() -- 9 equivalent calls inferred from this helper
	return barMap().TotalBeats * 96
end

local function minBars()
	local maxValue = 0

	for _, v52 in ipairs(notes) do
		maxValue = math.max(maxValue, v52.t + v52.d)
	end

	if maxValue <= 0 then
		return 1
	end

	return (math.max(1, barMap().BarAtBeat((maxValue - 1) / 96)))
end

local function snapshot(p)
	local v52 = table.create(#notes)

	for i, v53 in ipairs(notes) do
		v52[i] = { t = v53.t, d = v53.d, lane = v53.lane, k = v53.k }
	end

	if p then
		v52.Meta = { Changes = v10.Changes, BeatsPerBar = v10.BeatsPerBar, Bpm = v10.Bpm }
	end

	table.insert(v11, v52)

	if #v11 > 30 then
		table.remove(v11, 1)
	end

	v12 = true
end

local function currentNoteIndex()
	if not v15 then
		return nil
	end

	for i, v52 in ipairs(notes) do
		if v52.t == v15.t and noteRow(v52.lane) == v15.row then -- inferred equivalent call
			return i
		end
	end

	return nil
end

local function targetNote() -- 3 equivalent calls inferred from this helper
	local v52 = currentNoteIndex()

	if v52 then
		return notes[v52]
	end

	if v49 and v15 and table.find(notes, v49) then
		local v53 = v15.t - v49.t

		if v53 == 0 or v53 == v4[v13][2] then
			return v49
		end
	end

	return nil
end

local function findNear(p, p2)
	local v52 = math.max(9 / v8.PXB * 96, 6)
	local v53 = nil
	local near = nil

	for i, v54 in ipairs(notes) do
		if noteRow(v54.lane) ~= p then -- inferred equivalent call
			continue
		end

		local v55 = math.abs(v54.t - p2)

		if not (v55 <= v52 and (not v53 or v55 < v53)) then
			continue
		end

		near = i
		v53 = v55
	end

	return near
end

local function refreshFields()
	if not editorBar then
		return
	end

	PlayerLoadingState.ReportTabsEdit(v9 and (flag2 and "Recording" or "Creating") or nil)
	v17.Text = "GRID " .. v4[v13][1]
	v18.Text = "LEN " .. v3[v14][1]
	local v52 = barMap().Sig[1]
	v19.Text = v52 and v52.n .. "/" .. v52.d or v10.BeatsPerBar .. "/4"
	v20.Text = v10.Bars .. " BARS"

	if not v21:IsFocused() then
		v21.Text = tostring(v10.Bpm)
	end

	if not v22:IsFocused() then
		v22.Text = v10.Title
	end

	v23.Text = flag and "DISCARD?" or "EXIT"

	if v28 then
		v28.Text = v27 and "KEYS ON" or "KEYS OFF"
		v28.BackgroundColor3 = v27 and v8.theme().Accent or v8.theme().Button
		v28.TextColor3 = v27 and v8.theme().Stroke or v8.theme().Text
	end

	if v30 then
		v30.Text = v29 and "SNAP ON" or "SNAP OFF"
		v30.BackgroundColor3 = v29 and v8.theme().Accent or v8.theme().Button
		v30.TextColor3 = v29 and v8.theme().Stroke or v8.theme().Text
	end

	v26.Text = flag2 and "STOP REC" or "REC"
	v26.BackgroundColor3 = flag2 and v8.theme().Warn or v8.theme().Button
	v26.TextColor3 = flag2 and Color3.new(1, 1, 1) or v8.theme().Text
	local visible = v15 ~= nil
	v16.Visible = visible

	if instrument == "Drum" then
		for _, v54 in ipairs(buttons) do
			v54.Visible = false
		end

		for k, v54 in pairs(buttons2) do
			local visible2

			if visible then
				if v15 == nil then
					visible2 = false
				else
					visible2 = v2[k] == v15.row
				end
			else
				visible2 = visible
			end

			v54.Visible = visible2
		end
	else
		for _, v54 in pairs(buttons2) do
			v54.Visible = false
		end

		local v54 = currentNoteIndex()
		local v55

		if v54 then
			local _
			_, v55 = TabsSong.LaneRowFret(notes[v54].lane)
		end

		local v56

		if instrument == "Drum" then
			v56 = false
		else
			v56 = InputRouter.IsOctaveUpEnabled()
		end

		for i, v57 in ipairs(buttons) do
			local visible2

			if visible then
				visible2 = not v56 or i ~= 1
			else
				visible2 = visible
			end

			v57.Visible = visible2
			v57.Text = tostring(v56 and i - 1 + 12 or i - 1)
			local v59 = v55 == (v56 and i - 1 + 12 or i - 1)
			v57.BackgroundColor3 = v59 and v8.theme().Accent or v8.theme().Button
			v57.TextColor3 = v59 and v8.theme().Stroke or v8.theme().Text
		end
	end

	if v48 then
		v25.Visible = true
		v48.Visible = visible and currentNoteIndex() ~= nil
	else
		v25.Visible = visible and currentNoteIndex() ~= nil
	end

	local v54 = targetNote() -- inferred equivalent call

	for k, v55 in pairs(buttons3) do
		local v56 = v47[k]

		if v56 then
			v56.Visible = visible and instrument ~= "Drum"
			v55.Visible = true
		else
			v55.Visible = visible and instrument ~= "Drum"
		end

		local v57

		if v54 == nil then
			v57 = false
		else
			v57 = v54.k == k
		end

		v55.BackgroundColor3 = v57 and v8.theme().Accent or v8.theme().Button
		v55.TextColor3 = v57 and v8.theme().Stroke or v8.theme().Text
	end

	if v40 then
		v40.BackgroundColor3 = v36 and v8.theme().Accent or v8.theme().Button
		v40.TextColor3 = v36 and v8.theme().Stroke or v8.theme().Text
		v40.Text = v36 and "SELECT ON" or "SELECT"
		local v55 = v39
		local visible2 = v36

		if visible2 then
			if v37 == nil then
				visible2 = false
			else
				visible2 = v38 ~= nil
			end
		end

		v55.Visible = visible2
	end
end

local function sanitizeSections()
	if v10.Changes then
		local changes, v52 = TabsSong.ParseChanges(v10.Changes)

		for k in pairs(changes) do
			if v10.Bars < k then
				changes[k] = nil
			end
		end

		for k in pairs(v52) do
			if v10.Bars < k then
				v52[k] = nil
			end
		end

		v10.Changes = TabsSong.FormatChanges(changes, v52)
	end

	if v10.Tones then
		local v52 = {}

		for _, v53 in ipairs(TabsSong.ParseTones(v10.Tones)) do
			if v53.bar <= v10.Bars then
				v52[#v52 + 1] = v53
			end
		end

		v10.Tones = TabsSong.FormatTones(v52)
	end

	if not v10.Sections or v10.Sections == "" then
		v10.Sections = nil
		return
	end

	local sections = TabsSong.ParseSections(v10.Sections)
	local v52 = {}

	for _, section in ipairs(sections) do
		if section.bar <= v10.Bars then
			v52[#v52 + 1] = { bar = section.bar, code = section.code }
		end
	end

	v10.Sections = #v52 > 0 and TabsSong.FormatSections(v52) or nil
end

local function apply()
	sanitizeSections()
	TabsPlayer.Pause()
	local positionBeats = TabsPlayer.GetPositionBeats()
	local track = TabsSong.BuildTrack({
		SongId = "MyTabs",
		TrackId = tostring(v10.Slot or 0),
		Name = v10.Title,
		Title = v10.Title,
		Instrument = instrument,
		Bpm = v10.Bpm,
		BeatsPerBar = v10.BeatsPerBar,
		Bars = v10.Bars,
		Sections = v10.Sections,
		Changes = v10.Changes,
		Tones = v10.Tones
	}, TabsStore.Encode(notes))
	v8.setTrack(track)
	TabsPlayer.Seek(positionBeats)
	v8.invalidate()
	refreshFields()
end

local function finishRecording(p)
	if not flag2 then
		return
	end

	flag2 = false
	local liveUnits = TabsPlayer.GetLiveUnits()

	for k, v52 in pairs(v31) do
		table.insert(v32, { lane = k, s = v52, e = liveUnits })
	end

	v31 = {}
	TabsPlayer.SetSilent(false)

	if v35 then
		TabsPlayer.SetMetronome(v35.metro)
		TabsPlayer.SetCountIn(v35.count)
		v35 = nil
	end

	TabsPlayer.Stop()

	if p then
		table.remove(v11)
		v32 = {}
		refreshFields()
	else
		local v52 = v4[v13][2]
		local count2 = 0

		for _, v53 in ipairs(v32) do
			local v54 = noteRow(v53.lane) -- inferred equivalent call
			local v55

			if v29 then
				v55 = math.floor(v53.s / v52 + 0.5) * v52
			else
				v55 = math.floor(v53.s + 0.5)
			end

			if not (v54 and v55 >= 0 and v55 < maxUnits()) then -- inferred equivalent call
				continue
			end

			local v56

			if instrument == "Drum" then
				v56 = v3[v14][2]

				if v56 == 0 then
					v56 = v4[v13][2]
				end
			elseif v29 then
				v56 = math.max(v52, math.floor((v53.e - v53.s) / v52 + 0.5) * v52)
			else
				v56 = math.max(1, (math.floor(v53.e - v53.s + 0.5)))
			end

			local v57 = v53.lane

			if instrument == "Drum" then
				v57 = v6[v5[v53.lane]] or v53.lane
			end

			if putNote(v55, v54, v57, v56) then
				count2 += 1
			end
		end

		v32 = {}

		if count2 == 0 then
			table.remove(v11)
		else
			v12 = true
		end

		apply()
		v8.showMessage(count2 > 0 and "Recorded " .. count2 .. " notes" or "No notes recorded", count2 == 0)
	end
end

local function startRecording()
	if not v9 or flag2 then
		return
	end

	local canPlay, v52 = TabsPlayer.CanPlay()

	if not canPlay then
		v8.showMessage(v52 or "Cannot record now", true)
		return
	end

	TabsPlayer.Stop()
	local v53 = barMap()
	local v54 = math.max(0, TabsPlayer.GetPositionBeats())
	TabsPlayer.Seek(v53.StartBeat(v53.BarAtBeat(v54)))
	v35 = { metro = TabsPlayer.GetMetronome(), count = TabsPlayer.GetCountIn() }
	TabsPlayer.SetMetronome(true)
	TabsPlayer.SetCountIn(true)
	TabsPlayer.SetSilent(true)
	v31 = {}
	v32 = {}
	snapshot()
	v15 = nil

	if TabsPlayer.Play() then
		flag2 = true
		v8.showMessage("Recording after the count-in - play your notes", false)
		refreshFields()
	else
		flag2 = false
		TabsPlayer.SetSilent(false)
		TabsPlayer.SetMetronome(v35.metro)
		TabsPlayer.SetCountIn(v35.count)
		v35 = nil
		table.remove(v11)
	end
end

local function onRecordLane(p, p2, p3, p4)
	if not flag2 then
		return
	end

	local laneCode = TabsSong.LaneCode(p, p4, instrument)

	local v52 = p3 and TabsPlayer.GetUnitsAt(p3) or TabsPlayer.GetLiveUnits()

	if p2 then
		if v52 >= 0 and v31[laneCode] == nil then
			v31[laneCode] = v52
		end
	else
		local v53 = v31[laneCode]
		v31[laneCode] = nil

		if v53 then
			table.insert(v32, { lane = laneCode, s = v53, e = v52 })
		end
	end
end

local function mkBox(parent, p, layoutOrder, value)
	local textBox = Instance.new("TextBox")
	textBox.Font = Enum.Font.Oswald
	textBox.TextSize = v8.IS_MOBILE and 14 or 16
	textBox.Size = UDim2.new(0, p, 0, v8.IS_MOBILE and 26 or 28)
	textBox.LayoutOrder = layoutOrder
	textBox.ClearTextOnFocus = false
	textBox.PlaceholderText = value or ""
	textBox.BorderSizePixel = 0
	textBox.Parent = parent
	v8.T(textBox, "BackgroundColor3", "Button")
	v8.T(textBox, "TextColor3", "Text")
	v8.corner(textBox, 3)
	return textBox
end

local function mkRow(layoutOrder)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, v8.IS_MOBILE and 26 or 28)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.LayoutOrder = layoutOrder
	frame.Parent = editorBar
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Wraps = true
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame
	return frame
end

putNote = function(p, p2, lane, p3, p4)
	local v52 = math.min(p3, maxUnits() - p) -- inferred equivalent call

	if v52 < 1 then
		return false
	end

	for i = #notes, 1, -1 do
		local v53 = notes[i]

		if v53.t ~= p then
			continue
		end

		if instrument == "Drum" then
			if v53.lane == lane then
				table.remove(notes, i)
			end
		elseif noteRow(v53.lane) == p2 then -- inferred equivalent call
			table.remove(notes, i)
		end
	end

	local v53 = { t = p, d = v52, lane = lane, k = p4 }
	table.insert(notes, v53)
	v49 = v53
	return v53
end

local function pickFret(i)
	if not v15 or instrument == "Drum" then
		return
	end

	local isOctaveUpEnabled = InputRouter.IsOctaveUpEnabled()

	if isOctaveUpEnabled and i == 0 then
		return
	end

	local codeFromRowFret = TabsSong.CodeFromRowFret
	local row = v15.row
	i = isOctaveUpEnabled and i + 12 or i
	local v52 = codeFromRowFret(row, i)

	if not v52 then
		return
	end

	local v53 = currentNoteIndex()
	local v54 = v53 and notes[v53].d

	if not v54 then
		v54 = v3[v14][2]

		if v54 == 0 then
			v54 = v4[v13][2]
		end
	end

	snapshot()

	if putNote(v15.t, v15.row, v52, v54, v53 and notes[v53].k or nil) then
		apply()
	else
		table.remove(v11)
	end
end

local function pickPad(p)
	if not v15 or instrument ~= "Drum" then
		return
	end

	snapshot()

	local v52 = currentNoteIndex()

	if v52 and notes[v52].lane ~= v6[p] then
		table.remove(notes, v52)
	end

	if putNote(v15.t, v15.row, v6[p], curDur()) then -- inferred equivalent call
		apply()
	else
		table.remove(v11)
	end
end

local function deleteCurrent()
	local v52 = currentNoteIndex()

	if not v52 then
		return
	end

	snapshot()
	table.remove(notes, v52)
	apply()
end

local function onCell(i, x)
	if not (v9 and v10) then
		return
	end

	local v52 = (TabsPlayer.GetPositionBeats() + (x - v8.viewport.AbsolutePosition.X - v8.PLAYHEAD_X) / v8.PXB) * 96
	local v53 = v4[v13][2]
	local v54 = math.clamp(math.floor(v52 / v53 + 0.5) * v53, 0, (math.max(0, maxUnits() - v53))) -- inferred equivalent call

	if v36 then
		handleSelectClick(v54, v53)
		return
	end

	local near = findNear(i, v52)

	if near then
		v54 = notes[near].t
	end

	v15 = { t = v54, row = i }

	if instrument ~= "Drum" or #v[i] ~= 1 then
		refreshFields()
		return
	end

	snapshot()

	if near then
		table.remove(notes, near)
		v15 = nil
	else
		putNote(v54, i, v6[v[i][1]], curDur()) -- inferred equivalent call
	end

	apply()
end

local v52 = {}
local v53 = false
local v54 = nil

local function stepUnits() -- 12 equivalent calls inferred from this helper
	return v4[v13][2]
end

local function ensureCursor()
	if not v15 then
		local v55 = stepUnits() -- inferred equivalent call
		v15 = {
			t = math.clamp(
				math.floor(math.max(0, TabsPlayer.GetPositionBeats()) * 96 / v55 + 0.5) * v55,
				0,
				(math.max(0, maxUnits() - v55)) -- inferred equivalent call
			),
			row = 1
		}
	end
end

local function goCursor() -- 5 equivalent calls inferred from this helper
	TabsPlayer.Seek(v15.t / 96)
	v8.invalidate()
	refreshFields()
end

local function growIfNeeded(p, p2)
	local v55 = false

	while p + p2 > maxUnits() and v10.Bars < 300 do -- inferred equivalent call
		v10.Bars += 1
		v55 = true
	end

	return v55
end

local function removeRange(p, p2)
	local count2 = 0

	for i = #notes, 1, -1 do
		if not (p <= notes[i].t and notes[i].t < p + p2) then
			continue
		end

		table.remove(notes, i)
		count2 += 1
	end

	return count2
end

local function onStepLane(p, p2, _, p3)
	if not v9 or not v27 or flag2 or not v10 then
		return
	end

	local v55 = TabsSong.LaneCode(p, p3, instrument)
	v55 = instrument == "Drum" and v6[v5[v55]] or v55

	if UserInputService:GetFocusedTextBox() then
		return
	end

	local now = os.clock()

	if p2 then
		local row = noteRow(v55) -- inferred equivalent call

		if not row then
			return
		end

		for k, v57 in pairs(v52) do
			if now - v57 > 3 then
				v52[k] = nil
			end
		end

		ensureCursor()
		local v57 = next(v52) == nil

		if v57 then
			snapshot()
		end

		growIfNeeded(v15.t, stepUnits()) -- inferred equivalent call

		if putNote(v15.t, row, v55, curDur(), nil) then -- inferred equivalent call
			v15.row = row
			v52[v55] = now
			v53 = true
			apply()
		elseif v57 then
			table.remove(v11)
		end
	elseif v52[v55] then
		v52[v55] = nil

		if next(v52) == nil and v53 then
			v53 = false
			v15.t += stepUnits() -- inferred equivalent call

			if growIfNeeded(v15.t, stepUnits()) then -- inferred equivalent call
				apply()
			end

			goCursor() -- inferred equivalent call
		end
	end
end

local function onStepKey(p)
	if not v9 or not v27 or flag2 or not v10 then
		return
	end

	if UserInputService:GetFocusedTextBox() then
		return
	end

	local keyCode = p.KeyCode

	if keyCode == Enum.KeyCode.Space or keyCode == Enum.KeyCode.Right then
		ensureCursor()
		v15.t += stepUnits() -- inferred equivalent call

		if growIfNeeded(v15.t, stepUnits()) then -- inferred equivalent call
			apply()
		end

		goCursor() -- inferred equivalent call
	elseif keyCode == Enum.KeyCode.Left then
		ensureCursor()
		v15.t = math.max(0, v15.t - stepUnits()) -- inferred equivalent call
		goCursor() -- inferred equivalent call
	elseif keyCode == Enum.KeyCode.Backspace or keyCode == Enum.KeyCode.Delete then
		ensureCursor()

		if keyCode == Enum.KeyCode.Backspace then
			v15.t = math.max(0, v15.t - stepUnits()) -- inferred equivalent call
		end

		snapshot()

		if removeRange(v15.t, stepUnits()) > 0 then -- inferred equivalent call
			apply()
		else
			table.remove(v11)
		end

		goCursor() -- inferred equivalent call
	end
end

local function barRange() -- 3 equivalent calls inferred from this helper
	ensureCursor()
	local v55 = barMap()
	local barAtBeat = v55.BarAtBeat(v15.t / 96)
	return v55.StartBeat(barAtBeat) * 96, v55.BeatsOfBar(barAtBeat) * 96, barAtBeat
end

local function copyBar()
	local v55, len, barAtBeat = barRange() -- inferred equivalent call
	local notes2 = {}

	for _, v59 in ipairs(notes) do
		if v55 <= v59.t and v59.t < v55 + len then
			table.insert(notes2, {
				t = v59.t - v55,
				d = v59.d,
				lane = v59.lane,
				k = v59.k
			})
		end
	end

	v54 = { len = len, notes = notes2, kind = "bar" }
	v8.showMessage("Copied bar " .. barAtBeat .. " (" .. #notes2 .. " notes)", false)
end

local function pasteBar()
	if not v54 then
		v8.showMessage("Copy a bar first", true)
		return
	end

	local v55, len, barAtBeat = barRange() -- inferred equivalent call

	if v54.kind == "sel" then
		ensureCursor()
		v55 = v15.t
		len = v54.len
		snapshot()
	else
		snapshot()
		removeRange(v55, len)
	end

	growIfNeeded(v55, len)

	for _, note in ipairs(v54.notes) do
		if not (note.t < len) then
			continue
		end

		local v57 = v55 + note.t
		local v58 = math.min(note.d, maxUnits() - v57) -- inferred equivalent call

		if v58 >= 1 then
			table.insert(notes, { t = v57, d = v58, lane = note.lane, k = note.k })
		end
	end

	v15.t = v55 + len
	growIfNeeded(v15.t, stepUnits()) -- inferred equivalent call
	apply()
	goCursor() -- inferred equivalent call
	v8.showMessage(v54.kind == "sel" and "Pasted selection" or "Pasted into bar " .. barAtBeat, false)
end

local function clearBar()
	local v55, v56, barAtBeat = barRange() -- inferred equivalent call
	snapshot()

	if removeRange(v55, v56) > 0 then
		apply()
		v8.showMessage("Cleared bar " .. barAtBeat, false)
	else
		table.remove(v11)
	end
end

local v55 = {
	{ "s", "/" },
	{ "h", "H" },
	{ "p", "P" },
	{ "m", "PM" },
	{ "b", "^" },
	{ "l", "LR" },
	{ "v", "~" },
	{ "x", "x" }
}

local function countSel()
	if not (v37 and v38) then
		return 0
	end

	local count2 = 0

	for _, v56 in ipairs(notes) do
		local t = v56.t

		if v37 <= t and v56.t < v38 then
			count2 += 1
		end
	end

	return count2
end

handleSelectClick = function(p, p2)
	if v37 and not v38 then
		local v56 = math.min(p, v37)
		local v57 = math.max(p, v37) + p2
		v37 = v56
		v38 = v57
		v8.showMessage("Selected " .. countSel() .. " notes - use the buttons below", false)
	else
		v37 = p
		v38 = nil
		v8.showMessage("Now click the END of the selection", false)
	end

	refreshFields()
end

local function clearSel() -- 1 equivalent call inferred from this helper
	v37 = nil
	v38 = nil
	refreshFields()
end

local function deleteSel()
	if not (v37 and v38) then
		return
	end

	snapshot()
	local v56 = removeRange(v37, v38 - v37)
	v37 = nil
	v38 = nil
	apply()
	v8.showMessage("Deleted " .. v56 .. " notes", false)
end

local function moveSel(p)
	if not (v37 and v38) then
		return
	end

	local v56 = p * stepUnits() -- inferred equivalent call

	for _, v57 in ipairs(notes) do
		local t = v57.t

		if v37 <= t and v57.t < v38 and (v57.t + v56 < 0 or v57.t + v56 + v57.d > maxUnits()) then -- inferred equivalent call
			v8.showMessage("No room to move that way", true)
			return
		end
	end

	snapshot()

	for _, v57 in ipairs(notes) do
		local t = v57.t

		if v37 <= t and v57.t < v38 then
			v57.t += v56
		end
	end

	v37 += v56
	v38 += v56
	apply()
end

local function transposeSel(p)
	if not (v37 and v38) then
		return
	end

	if instrument == "Drum" then
		v8.showMessage("Drum notes cannot be transposed", true)
		return
	end

	snapshot()
	local count2 = 0

	for _, v56 in ipairs(notes) do
		local t = v56.t

		if not (v37 <= t and v56.t < v38) then
			continue
		end

		local laneRowFret, v57 = TabsSong.LaneRowFret(v56.lane)
		local codeFromRowFret = TabsSong.CodeFromRowFret(laneRowFret, v57 + p)

		if not codeFromRowFret then
			continue
		end

		v56.lane = codeFromRowFret
		count2 += 1
	end

	if count2 ~= 0 then
		apply()

		return
	end

	table.remove(v11)
	v8.showMessage("Nothing could move that way (frets stay 0-12)", true)
end

local function copySel()
	if not (v37 and v38) then
		return
	end

	local notes2 = {}

	for _, v57 in ipairs(notes) do
		local t = v57.t

		if v37 <= t and v57.t < v38 then
			table.insert(notes2, {
				t = v57.t - v37,
				d = v57.d,
				lane = v57.lane,
				k = v57.k
			})
		end
	end

	v54 = {
		len = v38 - v37,
		notes = notes2,
		kind = "sel"
	}
	v8.showMessage("Copied " .. #notes2 .. " notes - move the cursor and press PASTE", false)
end

local function applyTech(p) -- 1 equivalent call inferred from this helper
	local v56 = targetNote() -- inferred equivalent call

	if not v56 then
		v8.showMessage("Type or select a note first, then pick a technique", true)

		return
	end

	snapshot()
	local _ = v56.k == p
	v56.k = p
	apply()
end

local function applyTie()
	local v56 = targetNote() -- inferred equivalent call

	if not v56 then
		v8.showMessage("Type or select a note first, then press TIE", true)
	elseif v56.k == "t" then
		snapshot()
		v56.k = nil
		apply()
	else
		local v57 = v56.t + v56.d

		for i, v58 in ipairs(notes) do
			if v58.lane == v56.lane and v58.t == v57 and v58.k == "t" then
				snapshot()
				table.remove(notes, i)
				apply()
				return
			end
		end

		if maxUnits() <= v57 then -- inferred equivalent call
			v8.showMessage("No room after this note", true)
			return
		end

		snapshot()
		local v58 = putNote
		local v59 = noteRow(v56.lane) -- inferred equivalent call

		if not v58(v57, v59, v56.lane, curDur(), "t") then -- inferred equivalent call
			table.remove(v11)

			return
		end

		apply()
		v8.showMessage("Tied to the next beat", false)
	end
end

local function setSection(barAtBeat, code)
	local sections = TabsSong.ParseSections(v10.Sections or "")
	local v56 = {}
	local count2 = 0

	for _, section in ipairs(sections) do
		if section.bar == barAtBeat then
			continue
		end

		v56[#v56 + 1] = { bar = section.bar, code = section.code }

		if string.sub(section.code, 1, 1) == code then
			count2 += 1
		end
	end

	if count2 >= 1 then
		for _, v57 in ipairs(v56) do
			if v57.code == code then
				v57.code = code .. "1"
			end
		end

		code ..= tostring((math.min(9, count2 + 1)))
	end

	v56[#v56 + 1] = { bar = barAtBeat, code = code }
	v10.Sections = TabsSong.FormatSections(v56)
	v12 = true
	apply()
end

local function removeSection(barAtBeat)
	local sections = TabsSong.ParseSections(v10.Sections or "")
	local v56 = {}

	for _, section in ipairs(sections) do
		if section.bar ~= barAtBeat then
			v56[#v56 + 1] = { bar = section.bar, code = section.code }
		end
	end

	v10.Sections = #v56 > 0 and TabsSong.FormatSections(v56) or nil
	v12 = true
	apply()
end

local function openSectionsEditor()
	ensureCursor()
	local barAtBeat = barMap().BarAtBeat(v15.t / 96)
	local v56 = v8.beginOverlay()
	local label = v8.makeLabel(v56, "SECTION AT BAR " .. barAtBeat, 300, 1, Enum.TextXAlignment.Left)
	label.Size = UDim2.new(1, -8, 0, 26)
	label.Font = TabsSkin.FontBody
	label.TextColor3 = v8.theme().Accent
	local button = v8.makeButton(v56, "BACK", 300, 2, "left")
	button.Size = UDim2.new(1, -8, 0, v8.IS_MOBILE and 28 or 30)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Font = TabsSkin.FontBody
	button.Activated:Connect(v8.closeOverlay)

	for i, v57 in ipairs(TabsSong.SECTION_CODES) do
		local button2 = v8.makeButton(v56, TabsSong.SECTION_NAMES[v57], 300, 2 + i, "flag")
		button2.Size = UDim2.new(1, -8, 0, v8.IS_MOBILE and 28 or 30)
		button2.TextXAlignment = Enum.TextXAlignment.Left
		button2.Font = TabsSkin.FontBody
		button2.Activated:Connect(function()
			setSection(barAtBeat, v57)
			v8.closeOverlay()
			v8.showMessage(TabsSong.SECTION_NAMES[v57] .. " set at bar " .. barAtBeat, false)
		end)
	end

	local button2 = v8.makeButton(v56, "REMOVE SECTION AT THIS BAR", 300, 20, "trash")
	button2.Size = UDim2.new(1, -8, 0, v8.IS_MOBILE and 28 or 30)
	button2.TextXAlignment = Enum.TextXAlignment.Left
	button2.Font = TabsSkin.FontBody
	button2.Activated:Connect(function()
		removeSection(barAtBeat)
		v8.closeOverlay()
	end)
	v8.endOverlay()
end

local function setChange(p, p2, p3): boolean
	local changes, v56 = TabsSong.ParseChanges(v10.Changes)
	local bpm = v10.Bpm

	if p2 == "t" then
		changes[p] = p3
	elseif p <= 1 then
		bpm = p3 or bpm
	else
		v56[p] = p3
	end

	local formatChanges = TabsSong.FormatChanges(changes, v56)
	local maxValue = 0
	local maxValue2 = 1

	for _, v58 in ipairs(notes) do
		maxValue = math.max(maxValue, v58.t + v58.d)
	end

	for k in pairs(changes) do
		maxValue2 = math.max(maxValue2, k)
	end

	for k in pairs(v56) do
		maxValue2 = math.max(maxValue2, k)
	end

	local barMap2 = TabsSong.MakeBarMap(v10.BeatsPerBar, math.max(v10.Bars, maxValue2), bpm, formatChanges)
	local v58 = maxValue > 0 and barMap2.BarAtBeat((maxValue - 1) / 96) or 1

	if v58 > 300 then
		v8.showMessage("That would need " .. v58 .. " bars (the maximum is " .. 300 .. "). Nothing was changed.", true)
		return false
	end

	snapshot(true)
	v10.Changes = formatChanges
	v10.Bpm = bpm
	v10.Bars = math.min(300, (math.max(v10.Bars, v58)))
	v12 = true
	v15 = nil
	apply()
	return true
end

local function prettyTone(value) -- 3 equivalent calls inferred from this helper
	return (string.gsub(value, "(%l)(%u)", "%1 %2"))
end

local function availableTones()
	local success, freePlayController = pcall(require, script.Parent.FreePlayController)
	local success2, freePlaySoundAdapter = pcall(require, script.Parent.FreePlaySoundAdapter)
	local v56 = success
		and success2
		and freePlayController.GetCurrentInstrumentType
		and freePlayController.GetCurrentInstrumentType()

	if v56 then
		local availableTones2 = freePlaySoundAdapter.GetAvailableTones(v56)

		if availableTones2 and #availableTones2 > 0 then
			return availableTones2
		end
	end

	return nil
end

local function setToneAt(barAtBeat, name)
	local v56 = {}

	for _, v57 in ipairs(TabsSong.ParseTones(v10.Tones)) do
		if v57.bar ~= barAtBeat then
			v56[#v56 + 1] = v57
		end
	end

	if name then
		v56[#v56 + 1] = { bar = barAtBeat, name = name }
	end

	v10.Tones = TabsSong.FormatTones(v56)
	v12 = true
	apply()
end

local function overlayItem(p, p2, p3, p4) -- 9 equivalent calls inferred from this helper
	local button = v8.makeButton(p, p2, 300, p3, p4)
	button.Size = UDim2.new(1, -8, 0, v8.IS_MOBILE and 28 or 30)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Font = TabsSkin.FontBody
	return button
end

local function overlayTitle(p, p2, p3, p4) -- 7 equivalent calls inferred from this helper
	local label = v8.makeLabel(p, p2, 300, p3, Enum.TextXAlignment.Left)
	label.Size = UDim2.new(1, -8, 0, 26)
	label.Font = TabsSkin.FontBody
	label.TextColor3 = p4 and v8.theme().Accent or v8.theme().Dim
	return label
end

local v56 = {
	{ 2, 4 },
	{ 3, 4 },
	{ 4, 4 },
	{ 5, 4 },
	{ 6, 4 },
	{ 7, 4 },
	{ 3, 8 },
	{ 5, 8 },
	{ 6, 8 },
	{ 7, 8 },
	{ 9, 8 },
	{ 12, 8 },
	{ 2, 2 },
	{ 3, 2 },
	{ 5, 16 },
	{ 7, 16 }
}

local function sigNote(p, p2) -- 1 equivalent call inferred from this helper
	local v57 = p * 4 / p2
	return v57 % 1 == 0 and v57 .. " beats" or string.format("%.2f", v57):gsub("0+$", "") .. " beats"
end

local function effectiveSig(p, p2)
	for i = math.min(p2, p.Bars + 1), 1, -1 do
		if p.Sig[i] then
			return p.Sig[i].n, p.Sig[i].d
		end
	end

	return v10.BeatsPerBar, 4
end

local function openBarChangeEditor(p)
	if not p then
		ensureCursor()
	end

	local v57 = barMap()
	local v58 = p or v57.BarAtBeat(v15.t / 96)
	local v59, v60 = effectiveSig(v57, v58)
	local bpmAtBeat = v57.BpmAtBeat(v57.StartBeat(v58))
	local parent = v8.beginOverlay()
	overlayTitle(parent, v58 == 1 and "SONG START" or "CHANGE FROM BAR " .. v58 .. " ON", 1, true)
	overlayTitle(parent, string.format("Now: %d/%d  at  %d BPM", v59, v60, bpmAtBeat), 2, false) -- inferred equivalent call

	overlayItem(parent, "BACK", 3, "left").Activated:Connect(v8.closeOverlay) -- inferred equivalent call
	overlayTitle(parent, "Time signature (top / bottom):", 4, false) -- inferred equivalent call

	local function applySig(p2, p3): boolean
		local sig = TabsSong.MakeSig(p2, p3)

		if not sig then
			v8.showMessage(
				"Top: a whole number 1-" .. TabsSong.MAX_SIG_NUM .. ".  Bottom: 2, 4, 8 or 16  (for example 6/8)",
				true
			)
			return false
		end

		v8.closeOverlay()

		if (p2 ~= v59 or p3 ~= v60) and setChange(v58, "t", sig) then
			v8.showMessage(
				(v58 == 1 and "The song now uses " or "From bar " .. v58 .. " on: ") .. p2 .. "/" .. p3 .. "  -  your notes stay in place, only the bar lines moved",
				false
			)
		end

		return true
	end

	for i, v62 in ipairs(v56) do
		local v63 = v62[1]
		local v64 = v62[2]
		overlayItem( -- inferred equivalent call
			parent,
			v63 .. "/" .. v64 .. "   (" .. sigNote(v63, v64) .. ")" .. (v63 == v59 and v64 == v60 and "   <- now" or ""), -- inferred equivalent call
			4 + i
		).Activated:Connect(function()
			applySig(v63, v64)
		end)
	end

	overlayTitle(parent, "Or type your own, e.g. 7/8 or 12/8  (bottom = 2, 4, 8 or 16):", 40, false) -- inferred equivalent call
	local v62 = mkBox(parent, 120, 41, "6/8")
	v62.Text = v59 .. "/" .. v60

	overlayItem(parent, "SET TIME SIGNATURE", 42).Activated:Connect(function() -- inferred equivalent call
		local v63, v64 = string.match(v62.Text, "^%s*(%d+)%s*/%s*(%d+)%s*$")

		if v63 then
			applySig(tonumber(v63), tonumber(v64))
		else
			v8.showMessage("Type it like 6/8  (top / bottom)", true)
		end
	end)
	overlayTitle(parent, "Tempo (BPM) from this bar on:", 50, false) -- inferred equivalent call
	local v63 = mkBox(parent, 120, 51, "BPM")
	v63.Text = tostring(bpmAtBeat)

	overlayItem(parent, "SET TEMPO", 52).Activated:Connect(function() -- inferred equivalent call
		local text = tonumber(v63.Text)

		if not text then
			v8.showMessage("Type a number between " .. TabsSong.MIN_BPM .. " and " .. TabsSong.MAX_BPM, true)
			return
		end

		local v64 = math.clamp(math.floor(text + 0.5), TabsSong.MIN_BPM, TabsSong.MAX_BPM)
		v8.closeOverlay()
		setChange(v58, "b", v64)
		v8.showMessage("Tempo " .. v64 .. " BPM from bar " .. v58, false)
	end)
	local changes, v64 = TabsSong.ParseChanges(v10.Changes)

	if changes[v58] then
		overlayItem( -- inferred equivalent call
			parent,
			v58 == 1 and "BACK TO THE DEFAULT (" .. v10.BeatsPerBar .. "/4)" or "REMOVE BEATS CHANGE AT BAR " .. v58,
			60,
			"trash"
		).Activated:Connect(function()
			v8.closeOverlay()
			setChange(v58, "t", nil)
		end)
	end

	if v58 > 1 and v64[v58] then
		overlayItem(parent, "REMOVE TEMPO CHANGE AT BAR " .. v58, 61, "trash").Activated:Connect(function() -- inferred equivalent call
			v8.closeOverlay()
			setChange(v58, "b", nil)
		end)
	end

	v8.endOverlay()
end

local function openToneEditor()
	ensureCursor()
	local barAtBeat = barMap().BarAtBeat(v15.t / 96)
	local tones = TabsSong.ParseTones(v10.Tones)
	local name = nil
	local name2 = nil

	for _, tone in ipairs(tones) do
		if tone.bar == barAtBeat then
			name2 = tone.name
		end

		if tone.bar <= barAtBeat then
			name = tone.name
		end
	end

	local v57 = v8.beginOverlay()
	overlayTitle(v57, "SOUND FROM BAR " .. barAtBeat .. " ON", 1, true) -- inferred equivalent call
	overlayTitle(v57, name and "Now: " .. prettyTone(name) or "Now: the sound you picked yourself", 2, false) -- inferred equivalent call

	overlayItem(v57, "BACK", 3, "left").Activated:Connect(v8.closeOverlay) -- inferred equivalent call
	local v58 = availableTones()

	if v58 then
		for i, v59 in ipairs(v58) do
			overlayItem(v57, prettyTone(v59) .. (v59 == name and "   <- now" or ""), 3 + i, "flag").Activated:Connect(function() -- inferred equivalent call
				v8.closeOverlay()
				setToneAt(barAtBeat, v59)
				v8.showMessage(
					prettyTone(v59) .. " from bar " .. barAtBeat .. " (changes by itself when the tab plays)", -- inferred equivalent call
					false
				)
			end)
		end
	else
		overlayTitle(v57, "Hold a Guitar, Bass or Drum to see its sounds.", 4, false) -- inferred equivalent call
	end

	if name2 then
		overlayItem(v57, "REMOVE SOUND CHANGE AT BAR " .. barAtBeat, 30, "trash").Activated:Connect(function() -- inferred equivalent call
			v8.closeOverlay()
			setToneAt(barAtBeat, nil)
		end)
	end

	v8.endOverlay()
end

local function cycleGrid()
	v13 = v13 % #v4 + 1
	refreshFields()
end

local function cycleDur()
	v14 = v14 % #v3 + 1
	local v57 = currentNoteIndex()

	if not v57 then
		refreshFields()

		return
	end

	snapshot()
	local v58 = notes[v57]
	v58.d = math.max(1, (math.min(curDur(), maxUnits() - notes[v57].t))) -- inferred equivalent call
	apply()
end

local function undo()
	local v57 = table.remove(v11)

	if not v57 then
		v8.showMessage("Nothing to undo", false)
		return
	end

	notes = v57
	v49 = nil

	if v57.Meta then
		v10.Changes = v57.Meta.Changes
		v10.BeatsPerBar = v57.Meta.BeatsPerBar
		v10.Bpm = v57.Meta.Bpm
		v57.Meta = nil
	end

	v12 = #v11 > 0
	v10.Bars = math.max(v10.Bars, minBars())
	v15 = nil
	apply()
end

local function scrollBars(p)
	local positionBeats = TabsPlayer.GetPositionBeats()
	local v57 = v10 and v10.BeatsPerBar or 4

	if v10 then
		local v58 = barMap()
		v57 = v58.BeatsOfBar(v58.BarAtBeat((math.max(0, positionBeats))))
	end

	TabsPlayer.Seek((math.max(0, positionBeats + p * v57)))
	v8.invalidate()
end

local function buildHits()
	if editorHits then
		editorHits:Destroy()
	end

	editorHits = Instance.new("Frame")
	editorHits.Name = "EditorHits"
	editorHits.BackgroundTransparency = 1
	editorHits.Size = UDim2.new(1, 0, 1, 0)
	editorHits.ZIndex = 3
	editorHits.Parent = v8.viewport

	local rows, v57 = v8.getRows()
	local v58 = v8.AREA_H / (v57 + 1)

	local function wire(textButton)
		textButton.MouseWheelForward:Connect(function()
			scrollBars(-0.25)
		end)
		textButton.MouseWheelBackward:Connect(function()
			scrollBars(0.25)
		end)
	end

	local textButton = Instance.new("TextButton")
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundTransparency = 1
	textButton.Size = UDim2.new(1, 0, 0, 16)
	textButton.ZIndex = 3
	textButton.Parent = editorHits
	textButton.InputBegan:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local v59 = TabsPlayer.GetPositionBeats() + (input.Position.X - v8.viewport.AbsolutePosition.X - v8.PLAYHEAD_X) / v8.PXB
		local v60 = barMap()
		TabsPlayer.Seek(v60.StartBeat(v60.BarAtBeat((math.max(0, v59)))))
		v8.invalidate()
	end)
	wire(textButton)

	for i = 1, v57 do
		local textButton2 = Instance.new("TextButton")
		textButton2.Text = ""
		textButton2.AutoButtonColor = false
		textButton2.BackgroundTransparency = 1
		textButton2.Size = UDim2.new(1, 0, 0, (math.floor(v58)))
		textButton2.Position = UDim2.fromOffset(0, (math.floor(rows[i] - v58 / 2)))
		textButton2.ZIndex = 3
		textButton2.Parent = editorHits
		textButton2.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				onCell(i, input.Position.X)
			end
		end)
		wire(textButton2)
	end
end

local function overlayRow(p, p2, p3, onActivated) -- 14 equivalent calls inferred from this helper
	local button = v8.makeButton(p, p2, 300, p3)
	button.Size = UDim2.new(1, -8, 0, v8.IS_MOBILE and 28 or 30)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Font = TabsSkin.FontBody
	button.Text = "  " .. p2

	if onActivated then
		button.Activated:Connect(onActivated)
	end

	return button
end

local function openSaveMenu()
	count += 1
	local v57 = count
	overlayRow(v8.beginOverlay(), "SAVE TO SLOT - loading...", 1) -- inferred equivalent call

	v8.endOverlay()
	local list = TabsStore.List(instrument)

	if v57 ~= count then
		return
	end

	local v58 = v8.beginOverlay()

	if list.ok then
		local button = overlayRow(v58, "SAVE TO SLOT", 1) -- inferred equivalent call
		button.TextColor3 = v8.theme().Accent
		overlayRow(v58, "BACK", 2, function()
			v8.closeOverlay()
		end)
		local v60 = nil

		for i = 1, TabsStore.MAX_SLOTS do
			local slot = list.slots[i]

			local v62 = nil
			v62 = overlayRow(v58, i .. ".  " .. (slot and slot.Title or "- empty -"), i + 2, function()
				if slot and v60 ~= i then
					v60 = i
					v62.Text = "  " .. i .. ".  OVERWRITE " .. slot.Title .. "?  tap again"
					v62.TextColor3 = v8.theme().Warn
				else
					local v63 = TabsStore.Save(instrument, i, {
						Title = v10.Title,
						Bpm = v10.Bpm,
						BeatsPerBar = v10.BeatsPerBar,
						Bars = v10.Bars,
						Notes = notes,
						Sections = v10.Sections,
						Changes = v10.Changes,
						Tones = v10.Tones
					})

					if not v63.ok then
						v8.showMessage(v63.err or "Could not save", true)

						return
					end

					v10.Slot = i
					v10.Title = v63.title
					v12 = false
					v8.showMessage("Saved to slot " .. i, false)
					task.spawn(TabsStore.DraftClear, instrument)
					v8.closeOverlay()
					apply()
				end
			end)
		end

		v8.endOverlay()
	else
		overlayRow(v58, list.err or "Could not load slots", 1) -- inferred equivalent call
		overlayRow(v58, "BACK", 2, function()
			v8.closeOverlay()
		end)
		v8.endOverlay()
	end
end

local function openSendMenu(p, i, title)
	count += 1
	local v57 = v8.beginOverlay()
	local button = overlayRow(v57, "SEND  \"" .. title .. "\"  TO", 1) -- inferred equivalent call
	button.TextColor3 = v8.theme().Accent
	overlayRow(v57, "BACK", 2, function()
		TabsEditor.OpenMyTabs(p)
	end)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local isStudio = RunService:IsStudio()
	local count2 = 0

	for _, v59 in ipairs(Players:GetPlayers()) do
		local v60 = v59 == Players.LocalPlayer

		if not (not v60 or isStudio) then
			continue
		end

		count2 += 1
		overlayRow(v57, v59.DisplayName .. (v60 and "  (you - Studio test)" or ""), count2 + 2, function()
			local shareSend = TabsStore.ShareSend(p, i, v59.UserId)

			if not shareSend.ok then
				v8.showMessage(shareSend.err or "Could not send", true)

				return
			end

			v8.showMessage("Sent to " .. (shareSend.to or v59.DisplayName), false)
			TabsEditor.OpenMyTabs(p)
		end)
	end

	if count2 == 0 then
		overlayRow(v57, "No other players in this server", 3) -- inferred equivalent call
	end

	v8.endOverlay()
end

local v57 = {
	{ Id = "Guitar", Soon = false },
	{ Id = "Bass", Soon = false },
	{ Id = "Drum", Soon = false },
	{ Id = "Piano", Soon = true },
	{ Id = "Keyboard", Soon = true }
}

function TabsEditor.OpenCommunity(p)
	local v58 = p or instrument
	count += 1
	local v59 = v8.beginOverlay()
	local button = overlayRow(v59, "COMMUNITY  -  choose an instrument", 1) -- inferred equivalent call
	button.TextColor3 = v8.theme().Accent
	overlayRow(v59, "BACK", 2, function()
		v8.reopenSongs()
	end)

	for i, v61 in ipairs(v57) do
		local v62 = v61.Id == v58
		local id = string.upper(v61.Id)
		local v63

		if v62 then
			v63 = id .. "   (your instrument - playable)"
		elseif v61.Soon then
			v63 = id .. "   (coming soon)"
		else
			v63 = id .. "   (view only)"
		end

		local v64 = overlayRow(v59, v63, 2 + i, function()
			if v61.Soon then
				v8.showMessage(v61.Id .. " tabs are coming soon", false)
			else
				TabsEditor.OpenCommunityList(v61.Id, v58)
			end
		end)

		if v62 then
			v64.TextColor3 = v8.theme().Accent
		elseif v61.Soon then
			v64.TextTransparency = 0.55
		end
	end

	v8.endOverlay()
end

function TabsEditor.OpenCommunityList(value, p)
	local v58 = p or instrument
	local v59 = value == v58
	count += 1
	local v60 = count
	overlayRow(v8.beginOverlay(), "COMMUNITY - loading...", 1) -- inferred equivalent call

	v8.endOverlay()
	local pubList = TabsStore.PubList(value)

	if v60 ~= count then
		return
	end

	local parent = v8.beginOverlay()
	local button4 = overlayRow( -- inferred equivalent call
		parent,
		"COMMUNITY  -  " .. string.upper(value) .. (v59 and "" or "   (view only: equip a " .. value .. " to play)"),
		1
	)
	button4.TextColor3 = v8.theme().Accent
	overlayRow(parent, "BACK", 2, function()
		TabsEditor.OpenCommunity(v58)
	end)

	if pubList.ok then
		if #pubList.items == 0 then
			overlayRow(parent, "No " .. value .. " tabs yet. Publish yours from MY TABS!", 3) -- inferred equivalent call
		end

		for i, item in ipairs(pubList.items) do
			local frame = Instance.new("Frame")
			frame.BackgroundTransparency = 1
			frame.Size = UDim2.new(1, -8, 0, v8.IS_MOBILE and 28 or 30)
			frame.LayoutOrder = 2 + i
			frame.Parent = parent

			local button = v8.makeButton(frame, "", 300, 1)
			button.Size = UDim2.new(1, -178, 1, 0)
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.TextTruncate = Enum.TextTruncate.AtEnd
			button.Font = TabsSkin.FontBody
			button.Text = "  " .. item.Title .. "   by " .. tostring(item.Author) .. "   (" .. item.Bpm .. " BPM, " .. item.Bars .. " bars)"
			button.TextTransparency = v59 and 0 or 0.45
			local button2 = v8.makeButton(frame, "COPY", 76, 2, "copy")
			button2.AnchorPoint = Vector2.new(1, 0)
			button2.Position = UDim2.new(1, 0, 0, 0)
			button2.Size = UDim2.new(0, 76, 1, 0)
			button.Activated:Connect(function()
				if not v59 then
					v8.showMessage("Equip a " .. value .. " to play this tab", true)
					return
				end

				local pubGet = TabsStore.PubGet(value, item.Id)

				if not pubGet.ok then
					v8.showMessage(pubGet.err or "Could not load", true)

					return
				end

				TabsEditor.Stop()
				v8.setTrack(TabsStore.PubToTrack(pubGet.entry, value, item.Id))
				v8.closeOverlay()
			end)
			button2.Activated:Connect(function()
				local pubCopy = TabsStore.PubCopy(value, item.Id)

				if pubCopy.ok then
					v8.showMessage("Copied to your " .. (v59 and "" or value .. " ") .. "slot " .. pubCopy.slot, false)
				else
					v8.showMessage(pubCopy.err or "Could not copy", true)
				end
			end)

			if item.Mine then
				local button3 = v8.makeButton(frame, "UNPUB", 88, 3, "publish")
				button3.AnchorPoint = Vector2.new(1, 0)
				button3.Position = UDim2.new(1, -80, 0, 0)
				button3.Size = UDim2.new(0, 88, 1, 0)
				local flag3 = false
				local flag4 = false
				button3.Activated:Connect(function()
					if flag4 then
						return
					end

					if flag3 then
						flag4 = true
						button3.Text = "..."
						local unpublish = TabsStore.Unpublish(value, item.Id)
						flag4 = false

						if unpublish.ok then
							v8.showMessage("Removed from the community list", false)
							TabsEditor.OpenCommunityList(value, v58)
						else
							flag3 = false
							button3.Text = "UNPUB"
							v8.showMessage(unpublish.err or "Could not unpublish", true)
						end
					else
						flag3 = true
						button3.Text = "SURE?"
					end
				end)
			else
				local button3 = v8.makeButton(frame, "REPORT", 88, 3, "flag")
				button3.AnchorPoint = Vector2.new(1, 0)
				button3.Position = UDim2.new(1, -80, 0, 0)
				button3.Size = UDim2.new(0, 88, 1, 0)
				local flag3 = false
				button3.Activated:Connect(function()
					if flag3 then
						local report = TabsStore.Report(value, item.Id)

						if not report.ok then
							v8.showMessage(report.err or "Could not report", true)

							return
						end

						v8.showMessage("Report sent, thank you", false)
						button3.Text = "SENT"
					else
						flag3 = true
						button3.Text = "SURE?"
					end
				end)
			end
		end
	else
		overlayRow(parent, pubList.err or "Could not load the community list", 3) -- inferred equivalent call
	end

	v8.endOverlay()
end

function TabsEditor.OpenMyTabs(p)
	local v58 = p or instrument
	count += 1
	local v59 = count
	overlayRow(v8.beginOverlay(), "MY TABS - loading...", 1) -- inferred equivalent call

	v8.endOverlay()
	local list = TabsStore.List(v58)

	if v59 ~= count then
		return
	end

	local parent = v8.beginOverlay()
	local button5 = overlayRow(parent, "MY TABS  [" .. v58 .. "]", 1) -- inferred equivalent call
	button5.TextColor3 = v8.theme().Accent
	overlayRow(parent, "BACK", 2, function()
		v8.reopenSongs()
	end)

	if list.ok then
		for i = 1, TabsStore.MAX_SLOTS do
			local slot = list.slots[i]

			if not slot then
				continue
			end

			local frame = Instance.new("Frame")
			frame.BackgroundTransparency = 1
			frame.Size = UDim2.new(1, -8, 0, v8.IS_MOBILE and 28 or 30)
			frame.LayoutOrder = i + 2
			frame.Parent = parent
			local button = v8.makeButton(frame, "", 300, 1)
			button.Size = UDim2.new(1, -228, 1, 0)
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.Text = "  " .. i .. ".  " .. slot.Title .. (slot.Author and slot.Author ~= "" and "   by " .. slot.Author or "") .. "   (" .. slot.Bpm .. " BPM, " .. slot.Bars .. " bars)"
			button.TextTruncate = Enum.TextTruncate.AtEnd
			local button2 = v8.makeButton(frame, "", 44, 2, "trash")
			button2.AnchorPoint = Vector2.new(1, 0)
			button2.Position = UDim2.new(1, 0, 0, 0)
			button2.Size = UDim2.new(0, 44, 1, 0)
			local button3 = v8.makeButton(frame, slot.PubId and "UNPUB" or "PUBLISH", 92, 3, "publish")
			button3.AnchorPoint = Vector2.new(1, 0)
			button3.Position = UDim2.new(1, -48, 0, 0)
			button3.Size = UDim2.new(0, 92, 1, 0)
			local button4 = v8.makeButton(frame, "SEND", 76, 4, "send")
			button4.AnchorPoint = Vector2.new(1, 0)
			button4.Position = UDim2.new(1, -144, 0, 0)
			button4.Size = UDim2.new(0, 76, 1, 0)
			button4.Activated:Connect(function()
				openSendMenu(v58, i, slot.Title)
			end)
			local flag3 = false
			local flag4 = false
			button3.Activated:Connect(function()
				if flag4 then
					return
				end

				if slot.PubId then
					flag4 = true
					button3.Text = "..."
					local unpublish = TabsStore.Unpublish(v58, slot.PubId)
					flag4 = false

					if unpublish.ok then
						v8.showMessage("Removed from the community list", false)
						TabsEditor.OpenMyTabs(v58)
					else
						button3.Text = "UNPUB"
						v8.showMessage(unpublish.err or "Could not unpublish", true)
					end
				elseif flag3 then
					flag4 = true
					button3.Text = "PUBLISHING..."
					local v62 = TabsStore.Publish(v58, i)
					flag4 = false

					if v62.ok then
						v8.showMessage("Published! Everyone can find it in COMMUNITY", false)
						TabsEditor.OpenMyTabs(v58)
					else
						flag3 = false
						button3.Text = "PUBLISH"
						v8.showMessage(v62.err or "Could not publish", true)
					end
				else
					flag3 = true
					button3.Text = "SURE?"
				end
			end)
			button.Activated:Connect(function()
				local v62 = TabsStore.Get(v58, i)

				if not v62.ok then
					v8.showMessage(v62.err or "Could not load", true)

					return
				end

				TabsEditor.Stop()
				v8.setTrack(TabsStore.ToTrack(v62.entry, v58, i))
				v8.closeOverlay()
			end)
			local flag5 = false
			button2.Activated:Connect(function()
				if flag5 then
					local v62 = TabsStore.Delete(v58, i)

					if not v62.ok then
						v8.showMessage(v62.err or "Could not delete", true)

						return
					end

					v8.showMessage("Deleted slot " .. i, false)
					TabsEditor.OpenMyTabs(v58)
				else
					flag5 = true
					button2.Text = "DEL?"
				end
			end)
		end

		if #parent:GetChildren() <= 3 then
			overlayRow(parent, "No saved tabs yet. Use + NEW TAB to make one.", 3) -- inferred equivalent call
		end
	else
		overlayRow(parent, list.err or "Could not load slots", 3) -- inferred equivalent call
	end

	v8.endOverlay()
end

local function buildBar()
	editorBar = Instance.new("Frame")
	editorBar.Name = "EditorBar"
	editorBar.BackgroundTransparency = 1
	editorBar.Size = UDim2.new(1, 0, 0, 0)
	editorBar.AutomaticSize = Enum.AutomaticSize.Y
	editorBar.LayoutOrder = 4
	editorBar.Visible = false
	editorBar.Parent = v8.panel
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.Parent = editorBar

	local parent = mkRow(1)
	v17 = v8.makeButton(parent, "GRID 1/16", v8.IS_MOBILE and 92 or 104, 1, "img:step_size")
	v18 = v8.makeButton(parent, "LEN 1/16", v8.IS_MOBILE and 88 or 98, 2, "img:note_length")
	v8.makeLabel(parent, "BPM", 34, 3)
	v21 = mkBox(parent, 48, 4, "120")
	v19 = v8.makeButton(parent, "4/4", 44, 5)
	local button = v8.makeButton(parent, "", 28, 6, "minus")
	v20 = v8.makeLabel(parent, "16 BARS", v8.IS_MOBILE and 56 or 64, 7)
	local button2 = v8.makeButton(parent, "", 28, 8, "plus")
	local button3 = v8.makeButton(parent, "UNDO", 74, 9, "img:undo")
	local button4 = v8.makeButton(parent, "", 30, 10, "left")
	local button5 = v8.makeButton(parent, "", 30, 11, "right")

	local parent2 = mkRow(2)
	v22 = mkBox(parent2, v8.IS_MOBILE and 130 or 200, 1, "Title")
	v24 = v8.makeButton(parent2, "SAVE", 76, 2, "img:save")
	local button6 = v8.makeButton(parent2, "MY TABS", 92, 3, "img:saved_tabs")
	v23 = v8.makeButton(parent2, "EXIT", 78, 4, "img:close_editor")
	v26 = v8.makeButton(parent2, "REC", 76, 5, "img:record")
	v28 = v8.makeButton(parent2, "KEYS ON", 96, 6, "img:type_keys")
	local button7 = v8.makeButton(parent2, "COPY BAR", 104, 7, "img:copy_bar")
	local button8 = v8.makeButton(parent2, "PASTE BAR", 108, 8, "img:paste_bar")
	local button9 = v8.makeButton(parent2, "CLEAR BAR", 108, 9, "img:empty_bar")
	v28.Activated:Connect(function()
		v27 = not v27
		v52 = {}
		refreshFields()
		v8.showMessage(v27 and "Keyboard entry ON: press keys to type notes" or "Keyboard entry OFF", false)
	end)
	button7.Activated:Connect(copyBar)
	button8.Activated:Connect(pasteBar)
	button9.Activated:Connect(clearBar)
	v30 = v8.makeButton(parent2, "SNAP OFF", 100, 10, "img:rec_timing")
	v30.Activated:Connect(function()
		v29 = not v29
		refreshFields()
		v8.showMessage(v29 and "Recording snaps to the GRID" or "Recording keeps your exact timing", false)
	end)
	v40 = v8.makeButton(parent2, "SELECT", 100, 11, "img:pick_notes")
	v40.Activated:Connect(function()
		v36 = not v36
		v37 = nil
		v38 = nil
		refreshFields()
		v8.showMessage(v36 and "Select mode: click the START, then the END on the tab" or "Select mode off", false)
	end)
	v41 = v8.makeButton(parent2, "SECTION", 100, 12, "img:section")
	v41.Activated:Connect(openSectionsEditor)
	v42 = v8.makeButton(parent2, "BEATS/BPM", 100, 13, "img:tempo_change")
	v42.Activated:Connect(function()
		openBarChangeEditor()
	end)
	v43 = v8.makeButton(parent2, "SOUND", 76, 14, "img:sound_change")
	v43.Activated:Connect(openToneEditor)
	v26.Activated:Connect(function()
		if flag2 then
			finishRecording(false)
		else
			startRecording()
		end

		refreshFields()
	end)

	v16 = mkRow(3)

	for i = 0, 12 do
		local button10 = v8.makeButton(v16, tostring(i), v8.IS_MOBILE and 28 or 36, i + 1)
		button10.Activated:Connect(function()
			pickFret(i)
		end)
		buttons[i + 1] = button10
	end

	v44 = v8.makeButton(v16, "13-24", v8.IS_MOBILE and 52 or 60, 14, "img:frets_13_24")
	v44.Activated:Connect(function()
		InputRouter.SetOctaveUp(not InputRouter.IsOctaveUpEnabled())
		refreshFields()
	end)

	for i, list in ipairs(v) do
		for j, item in ipairs(list) do
			local button10 = v8.makeButton(v16, v7[item], v8.IS_MOBILE and 62 or 72, 20 + i * 10 + j)
			button10.Visible = false
			local v60 = item
			button10.Activated:Connect(function()
				pickPad(v60)
			end)
			buttons2[item] = button10
		end
	end

	v25 = v8.makeButton(v16, "DEL", 62, 200, "img:delete_note")
	local v60 = {
		s = "slide",
		h = "hammer_on",
		p = "pull_off",
		m = "palm_mute",
		b = "bend",
		l = "let_ring",
		v = "vibrato",
		x = "dead_note"
	}

	for i, v61 in ipairs(v55) do
		local button10 = v8.makeButton(v16, "", 34, 300 + i, "img:" .. v60[v61[1]])
		button10.Visible = false
		button10.Activated:Connect(function()
			applyTech(v61[1]) -- inferred equivalent call
		end)
		buttons3[v61[1]] = button10
	end

	local button10 = v8.makeButton(v16, "", 46, 320, "img:tie")
	button10.Visible = false
	button10.Activated:Connect(applyTie)
	buttons3.t = button10
	v16.Visible = false

	local function captionize(instance, text, p)
		local v61 = p or math.max(instance.Size.X.Offset, (math.ceil)(#text * 5.4) + 6)

		if p then
			instance.Size = UDim2.new(0, p, instance.Size.Y.Scale, instance.Size.Y.Offset)
		end

		local frame = Instance.new("Frame")
		frame.Name = "Cap_" .. text
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(0, v61, 0, 0)
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.LayoutOrder = instance.LayoutOrder
		local uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiListLayout2.Padding = UDim.new(0, 1)
		uiListLayout2.Parent = frame
		frame.Parent = instance.Parent
		instance.LayoutOrder = 1
		instance.Parent = frame
		local caption = Instance.new("TextLabel")
		caption.Name = "Caption"
		caption.BackgroundTransparency = 1
		caption.Font = Enum.Font.Oswald
		caption.TextSize = v8.IS_MOBILE and 10 or 11
		caption.Text = text
		caption.Size = UDim2.new(0, v61, 0, 12)
		caption.LayoutOrder = 2
		caption.TextTransparency = 0.3
		caption.Parent = frame
		v8.T(caption, "TextColor3", "Text")
		return frame
	end

	captionize(v17, "Step size")
	captionize(v18, "Note length")
	captionize(v19, "Beats per bar")
	captionize(button3, "Undo last")
	captionize(v24, "Save tab")
	captionize(button6, "Saved tabs")
	captionize(v23, "Close editor")
	captionize(v26, "Record live")
	captionize(v28, "Type with keys")
	captionize(button7, "Copy this bar")
	captionize(button8, "Paste bar")
	captionize(button9, "Empty this bar")
	captionize(v30, "Rec timing")
	captionize(v40, "Pick notes")
	captionize(v41, "Name a part")
	captionize(v42, "Change beats / tempo")
	captionize(v43, "Change sound")
	v45 = captionize(v44, "CapsLock = 13-24", v8.IS_MOBILE and 84 or 92)
	v48 = captionize(v25, "Delete note")

	local v61 = v8.IS_MOBILE and 56 or 64
	local v62 = {
		s = "Slide",
		h = "Hammer-on",
		p = "Pull-off",
		m = "Palm mute",
		b = "Bend",
		l = "Let ring",
		v = "Vibrato",
		x = "Dead note",
		t = "Tie to next beat"
	}

	for k, v63 in pairs(buttons3) do
		local text = v62[k] or k
		local v65

		if k == "t" then
			v65 = v61 + 36 or v61
		else
			v65 = v61
		end

		v47[k] = captionize(v63, text, v65)
	end

	v39 = mkRow(4)
	v39.Visible = false
	local function selBtn(p, p2, p3, p4, onActivated)
		local button11 = v8.makeButton(v39, p, p2, p3, p4)
		button11.Activated:Connect(onActivated)
		return button11
	end

	v8.makeButton(v39, "DELETE", 96, 1, "trash").Activated:Connect(deleteSel)

	local function onActivated()
		moveSel(-1)
	end

	v8.makeButton(v39, "", 34, 2, "left").Activated:Connect(onActivated)

	local function onActivated2()
		moveSel(1)
	end

	v8.makeButton(v39, "", 34, 3, "right").Activated:Connect(onActivated2)

	local function onActivated3()
		transposeSel(1)
	end

	v8.makeButton(v39, "FRET +1", 98, 4, "up").Activated:Connect(onActivated3)

	local function onActivated4()
		transposeSel(-1)
	end

	v8.makeButton(v39, "FRET -1", 98, 5, "down").Activated:Connect(onActivated4)
	v8.makeButton(v39, "COPY", 82, 6, "copy").Activated:Connect(copySel)

	local function onActivated5()
		v36 = false
		clearSel() -- inferred equivalent call
	end

	v8.makeButton(v39, "DONE", 82, 7, "close").Activated:Connect(onActivated5)

	editorSelection = Instance.new("Frame")
	editorSelection.Name = "EditorSelection"
	editorSelection.BorderSizePixel = 0
	editorSelection.BackgroundTransparency = 0.8
	editorSelection.ZIndex = 2
	editorSelection.Visible = false
	editorSelection.Parent = v8.content
	v8.T(editorSelection, "BackgroundColor3", "Accent")
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Parent = editorSelection
	v8.T(uiStroke, "Color", "Accent")

	v17.Activated:Connect(cycleGrid)
	v18.Activated:Connect(cycleDur)
	button3.Activated:Connect(undo)
	v25.Activated:Connect(deleteCurrent)
	button4.Activated:Connect(function()
		scrollBars(-1)
	end)
	button5.Activated:Connect(function()
		scrollBars(1)
	end)
	button.Activated:Connect(function()
		local bars = math.max(minBars(), v10.Bars - 1)

		if bars ~= v10.Bars then
			v10.Bars = bars
			v12 = true
			apply()
		end
	end)
	button2.Activated:Connect(function()
		if v10.Bars < 300 then
			v10.Bars += 1
			v12 = true
			apply()
		end
	end)
	v19.Activated:Connect(function()
		openBarChangeEditor(1)
	end)
	v21.FocusLost:Connect(function()
		local text = tonumber(v21.Text)

		if not text then
			refreshFields()

			return
		end

		v10.Bpm = math.clamp(math.floor(text + 0.5), 30, 300)
		v12 = true
		apply()
	end)
	v22.FocusLost:Connect(function()
		local v63 = string.match(v22.Text, "^%s*(.-)%s*$") or ""

		if not (#v63 > 0) then
			refreshFields()

			return
		end

		v10.Title = string.sub(v63, 1, TabsStore.MAX_TITLE)
		v12 = true
		apply()
	end)
	v24.Activated:Connect(function()
		if #notes == 0 then
			v8.showMessage("Add some notes first", true)
		else
			openSaveMenu()
		end
	end)
	button6.Activated:Connect(function()
		TabsEditor.OpenMyTabs(instrument)
	end)
	v23.Activated:Connect(function()
		if v12 and not flag then
			flag = true
			refreshFields()
			task.delay(3, function()
				if flag then
					flag = false
					refreshFields()
				end
			end)
		else
			if v12 then
				task.spawn(TabsStore.DraftClear, instrument)
			end

			TabsEditor.Stop()
		end
	end)

	editorCursor = Instance.new("Frame")
	editorCursor.Name = "EditorCursor"
	editorCursor.BackgroundTransparency = 1
	editorCursor.BorderSizePixel = 0
	editorCursor.Size = UDim2.fromOffset(26, 22)
	editorCursor.ZIndex = 5
	editorCursor.Visible = false
	editorCursor.Parent = v8.content
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 2
	uiStroke2.Parent = editorCursor
	v8.T(uiStroke2, "Color", "Accent")
	v8.corner(editorCursor, 4)
end

function TabsEditor.Init(p)
	v8 = p
	buildBar()
	InputRouter.OnLaneEvent(onRecordLane)
	InputRouter.OnLaneEvent(onStepLane)
	UserInputService.InputBegan:Connect(onStepKey)
	TabsPlayer.OnChanged(function()
		if flag2 and TabsPlayer.GetState() ~= "Playing" then
			finishRecording(false)
			refreshFields()
		end
	end)

	task.spawn(function()
		while true do
			task.wait(20)

			if not v9 or not v12 or not v10 or flag2 then
				continue
			end

			if not (#notes > 0) then
				continue
			end

			pcall(function()
				TabsStore.DraftSave(instrument, {
					Title = v10.Title,
					Bpm = v10.Bpm,
					BeatsPerBar = v10.BeatsPerBar,
					Bars = v10.Bars,
					Sections = v10.Sections,
					Changes = v10.Changes,
					Tones = v10.Tones,
					Notes = notes
				})
			end)
		end
	end)
end

function TabsEditor.IsActive()
	return v9
end

local function begin(p, p2, p3)
	v9 = true
	instrument = p
	v10 = p2
	notes = p3
	v49 = nil
	v11 = {}
	v12 = false
	v15 = nil
	flag = false
	editorBar.Visible = true
	apply()
	buildHits()
	refreshFields()
end

function TabsEditor.StartFromDraft(p, data)
	TabsPlayer.Stop()
	begin(p, {
		Title = data.Title,
		Bpm = data.Bpm,
		BeatsPerBar = data.BeatsPerBar,
		Bars = math.max(1, data.Bars),
		Sections = data.Sections,
		Changes = data.Changes,
		Tones = data.Tones,
		Slot = nil
	}, TabsStore.Decode(data.Raw))
	v12 = true
	v8.closeOverlay()
	v8.showMessage("Draft restored", false)
end

function TabsEditor.StartNew(p)
	TabsPlayer.Stop()
	begin(p, {
		Title = "My Tab",
		Bpm = 120,
		BeatsPerBar = 4,
		Bars = 16,
		Slot = nil
	}, {})
	v8.closeOverlay()
	v8.showMessage("Press keys (virtual or real keyboard) to type notes. Space = rest, Backspace = delete", false)
end

function TabsEditor.StartFromTrack(data, slot)
	if not (data and data.IsUser) then
		return
	end

	TabsPlayer.Stop()
	local v58 = table.create(data.N)

	for i = 1, data.N do
		local v59 = { t = data.T[i], d = data.D[i], lane = data.L[i], k = 0 }
		local v60

		if data.K then
			v60 = data.K[i] or nil
		end

		v59.k = v60
		v58[i] = v59
	end

	local sections

	if data.Sections and #data.Sections > 0 then
		local v60 = {}

		for _, section in ipairs(data.Sections) do
			v60[#v60 + 1] = { bar = section.bar, code = section.code }
		end

		sections = TabsSong.FormatSections(v60)
	end

	begin(data.Instrument, {
		Title = data.Title,
		Bpm = data.Bpm,
		BeatsPerBar = data.BeatsPerBar,
		Bars = math.max(1, data.Bars),
		Slot = slot,
		Sections = sections,
		Changes = data.Changes,
		Tones = data.Tones and #data.Tones > 0 and TabsSong.FormatTones(table.clone(data.Tones)) or nil
	}, v58)

	v8.closeOverlay()
end

function TabsEditor.Stop()
	if not v9 then
		return
	end

	finishRecording(true)
	v9 = false
	v15 = nil
	v36 = false
	v37 = nil
	v38 = nil
	v49 = nil
	flag = false

	if editorBar then
		editorBar.Visible = false
	end

	if editorHits then
		editorHits:Destroy()
		editorHits = nil
	end

	if editorCursor then
		editorCursor.Visible = false
	end

	count += 1
	PlayerLoadingState.ReportTabsEdit(nil)

	if v8.refreshControls then
		v8.refreshControls()
	end
end

function TabsEditor.OnFrame(p, _)
	if v44 and v9 then
		local isOctaveUpEnabled = InputRouter.IsOctaveUpEnabled()
		v45.Visible = instrument ~= "Drum"

		if isOctaveUpEnabled ~= v46 then
			v46 = isOctaveUpEnabled
			v44.BackgroundColor3 = isOctaveUpEnabled and v8.theme().Accent or v8.theme().Button
			v44.TextColor3 = isOctaveUpEnabled and v8.theme().Stroke or v8.theme().Text
			refreshFields()
		end
	end

	if editorSelection then
		if v9 and v37 and p then
			local v58 = v38 or v37 + stepUnits() -- inferred equivalent call

			editorSelection.Visible = true
			editorSelection.Position = UDim2.fromOffset((v37 / 96 - p) * v8.PXB, 0)
			editorSelection.Size = UDim2.fromOffset(math.max(2, (v58 - v37) / 96 * v8.PXB), v8.AREA_H)
		else
			editorSelection.Visible = false
		end
	end

	if not (v9 and editorCursor) then
		return
	end

	local v58 = v15 and p and v8.getRows()[v15.row]

	if not v58 then
		editorCursor.Visible = false
		return
	end

	editorCursor.Visible = true
	editorCursor.Position = UDim2.fromOffset((v15.t / 96 - p) * v8.PXB - 13, v58 - 11)
end

return TabsEditor