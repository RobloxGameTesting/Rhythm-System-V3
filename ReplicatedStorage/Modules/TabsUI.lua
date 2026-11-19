local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local ModeManager = require(script.Parent.ModeManager)
local TabsSong = require(script.Parent.TabsSong)
local InputRouter = require(script.Parent.InputRouter)
local TabsPlayer = require(script.Parent.TabsPlayer)
local TabsEditor = require(script.Parent.TabsEditor)
local TabsSkin = require(script.Parent.TabsSkin)
local TabsStore = require(script.Parent.TabsStore)
local TabsKeyGuide = require(script.Parent.TabsKeyGuide)
local TabsBand = require(script.Parent.TabsBand)

local TabsUI = {}

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local pxb = v and 40 or 56
local v2 = v and 132 or 200
local v3 = v and 26 or 32
local v4 = v and 64 or 96
local v5 = pxb
local v6 = { 0.5, 0.7, 1, 1.4, 1.9 }
local v7 = 3
local v8 = {
	s = "/",
	h = "H",
	p = "P",
	m = "PM",
	b = "^",
	l = "LR",
	v = "~"
}
local v9 = true
local v10 = 0
local flag = false
local v11 = nil
local v12 = false

local v13 = nil

local v14 = nil
local FontLabel = TabsSkin.FontLabel
local FontBody = TabsSkin.FontBody
local FontNum = TabsSkin.FontNum

local function rgb(p, p2, p3) -- 3 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local Palettes = TabsSkin.Palettes
local v15 = "Dark"
local v16 = Palettes.Dark
local v17 = {}

local function T(p, p2, p3) -- 15 equivalent calls inferred from this helper
	v17[#v17 + 1] = { p, p2, p3 }
	p[p2] = v16[p3]
end

local v18 = {
	Guitar = { "e", "B", "G", "D", "A", "E" },
	Bass = { "G", "D", "A", "E" },
	Drum = {
		"CR",
		"RD",
		"HH",
		"T1",
		"T2",
		"SN",
		"T3",
		"BD",
		"CB"
	}
}

local v19 = {
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

local v20 = {
	HighCrash = { row = 1, text = "X" },
	MediumCrash = { row = 1, text = "x" },
	Splash = { row = 1, text = "s" },
	China = { row = 1, text = "c" },
	RideEdge = { row = 2, text = "x" },
	RideBell = { row = 2, text = "b" },
	FootHiHat = { row = 3, text = "x" },
	OpenHiHat = { row = 3, text = "o" },
	HighTom = { row = 4, dot = true },
	MidTom = { row = 5, dot = true },
	Snare = { row = 6, dot = true },
	SideStick = { row = 6, text = "x" },
	FloorTom = { row = 7, dot = true },
	BassDrum = { row = 8, dot = true },
	Cowbell = { row = 9, text = "k" }
}

local tabsGui = nil
local panel = nil
local v21 = {}
local viewport = nil
local content = nil
local frame = nil
local frame2 = nil
local frame3 = nil
local scrollingFrame = nil
local textLabel = nil
local v22 = nil
local message = nil
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = nil
local v28 = nil
local v29 = nil
local newUIDecorHolder = nil
local v30 = nil
local v31 = nil
local v32 = nil
local v34 = nil
local v35 = nil
local count = 0
local root = nil
local v36 = nil
local v37 = {}
local v38 = v and 172 or 320

local function setAreaTall(p) -- 4 equivalent calls inferred from this helper
	if v36 then
		v36.Size = UDim2.new(1, 0, 0, p and v38 or v2)
	end
end
local v39 = {}
local v40 = {}
local v41 = {}
local v42 = {}
local flag2 = false
local v43 = nil
local v44 = "Guitar"
local v45 = 6
local result = {}
local w0 = nil

local v47 = nil
local v48 = nil
local v49 = nil
local count2 = 0
local v50 = 0
local tabsClick = nil
local tabsClickAccent = nil

local function ensureClick()
	if tabsClick then
		return
	end

	local success, result2 = pcall(function()
		return require(script.Parent.FreePlaySoundAdapter)
	end)

	if not success then
		return
	end

	local success2, result3, v51 = pcall(result2.Resolve, { Pad = "SideStick" }, "Drum", false, nil)

	if not (success2 and result3) then
		return
	end

	local SoundService = game:GetService("SoundService")
	tabsClick = Instance.new("Sound")
	tabsClick.Name = "TabsClick"
	tabsClick.SoundId = result3
	tabsClick.PlaybackSpeed = v51 or 1
	tabsClick.Volume = 0.8
	tabsClick.Parent = SoundService
	tabsClickAccent = tabsClick:Clone()
	tabsClickAccent.Name = "TabsClickAccent"
	tabsClickAccent.PlaybackSpeed = (v51 or 1) * 1.35
	tabsClickAccent.Parent = SoundService
	task.spawn(function()
		pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync({ tabsClick, tabsClickAccent })
		end)
	end)
end

local function currentFamily()
	if TabsUI._familyOverride then
		return TabsUI._familyOverride
	end

	local success, result2 = pcall(function()
		return require(script.Parent.FreePlayController)
	end)

	if success and result2 and result2.GetCurrentInstrumentType then
		return TabsSong.InstrumentFamily(result2.GetCurrentInstrumentType())
	end

	return nil
end

local function beatsPerBar() -- 2 equivalent calls inferred from this helper
	return v43 and v43.BeatsPerBar or 4
end

local function barStartBeat(p) -- 7 equivalent calls inferred from this helper
	local barMap = v43 and v43.BarMap

	if barMap then
		return barMap.StartBeat(p + 1)
	end

	return p * beatsPerBar() -- inferred equivalent call
end

local function barIndexAtBeat(p) -- 8 equivalent calls inferred from this helper
	local barMap = v43 and v43.BarMap

	if barMap then
		return barMap.BarAtBeat(p) - 1
	end

	return (math.floor(p / beatsPerBar())) -- inferred equivalent call
end

local function lastBarIndex() -- 3 equivalent calls inferred from this helper
	if not v43 then
		return 0
	end

	return (math.max(0, barIndexAtBeat(v43.EndUnits / v43.Res - 0.001))) -- inferred equivalent call
end

local function showMessage(p, p2) -- 6 equivalent calls inferred from this helper
	if not message then
		return
	end

	count2 += 1
	local v51 = count2
	message.Text = "  " .. p
	message.Visible = p ~= ""
	message.TextColor3 = p2 and v16.Warn or v16.Text
	task.delay(3, function()
		if count2 == v51 and message then
			message.Text = ""
			message.Visible = false
		end
	end)
end

local function corner(parent, value) -- 6 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, value or 3)
	uiCorner.Parent = parent
end

local function iconSizeWithText(value): number -- 3 equivalent calls inferred from this helper
	if type(value) == "string" and string.sub(value, 1, 4) == "img:" then
		return if v then 17 else 19
	else
		return if v then 13 else 15
	end
end

local function setButtonIcon(instance, value)
	local tabsIcon = instance:FindFirstChild("TabsIcon")

	if tabsIcon then
		tabsIcon:Destroy()
	end

	if not value then
		return
	end

	local v51 = iconSizeWithText(value) -- inferred equivalent call

	if type(value) == "string" and string.sub(value, 1, 4) == "img:" and instance.Text == "" then
		v51 = math.max(v51, (math.floor(instance.Size.Y.Offset * 0.82)))
	end

	local tabsIcon2 = TabsSkin.icon(instance, value, v51, instance.TextColor3)

	if not tabsIcon2 then
		return
	end

	tabsIcon2.Name = "TabsIcon"
	tabsIcon2.AnchorPoint = Vector2.new(instance.Text == "" and 0.5 or 0, 0.5)
	local v52 = iconSizeWithText(value) + 8 -- inferred equivalent call

	tabsIcon2.Position = instance.Text == "" and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 6 - v52, 0.5, 0)
end

local function makeButton(parent, text, p, value, value2, p2)
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Text = text
	textButton.Font = FontLabel
	textButton.TextSize = v and 14 or 16
	textButton.Size = UDim2.new(0, p, 0, v and 26 or 28)
	textButton.LayoutOrder = value or 0
	textButton.BorderSizePixel = 0
	textButton.Parent = parent

	if p2 == "danger" then
		textButton.BackgroundColor3 = rgb(160, 34, 30) -- inferred equivalent call
		textButton.TextColor3 = rgb(236, 230, 216) -- inferred equivalent call
	else
		T(textButton, "BackgroundColor3", "Button") -- inferred equivalent call
		T(textButton, "TextColor3", "Text") -- inferred equivalent call
	end

	corner(textButton, 2) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.3
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = textButton

	if p2 == "danger" then
		uiStroke.Color = rgb(60, 12, 10) -- inferred equivalent call
	else
		T(uiStroke, "Color", "Border") -- inferred equivalent call
	end

	if value2 then
		if text ~= "" then
			local uiPadding = Instance.new("UIPadding")
			uiPadding.PaddingLeft = UDim.new(0, iconSizeWithText(value2) + 8) -- inferred equivalent call
			uiPadding.Parent = textButton
		end

		setButtonIcon(textButton, value2)
	end

	textButton:GetPropertyChangedSignal("TextColor3"):Connect(function()
		TabsSkin.tint(textButton:FindFirstChild("TabsIcon"), textButton.TextColor3)
	end)
	return textButton
end

local function makeLabel(parent, text, p, value, p2)
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = text
	textLabel2.Font = FontLabel
	textLabel2.TextSize = v and 14 or 16
	textLabel2.TextXAlignment = p2 or Enum.TextXAlignment.Center
	textLabel2.Size = UDim2.new(0, p, 0, v and 26 or 28)
	textLabel2.LayoutOrder = value or 0
	textLabel2.Parent = parent
	T(textLabel2, "TextColor3", "Text") -- inferred equivalent call
	return textLabel2
end

local function layoutRows()
	local v51 = v18[v44]
	v45 = #v51

	local v52 = (v2 - 22 - 10) / v45

	for i = 1, v45 do
		result[i] = math.floor(22 + v52 * (i - 0.5))
	end

	for i = 1, math.max(#v40, v45) do
		local v53 = v40[i]
		local v54 = v39[i]

		if i <= v45 then
			if not v53 then
				v53 = Instance.new("Frame")
				v53.BorderSizePixel = 0
				v53.Size = UDim2.new(1, 0, 0, 1)
				v53.ZIndex = 1
				v53.Parent = viewport
				T(v53, "BackgroundColor3", "Line") -- inferred equivalent call
				v40[i] = v53
			end

			v53.Position = UDim2.fromOffset(0, result[i])
			v53.Visible = true

			if not v54 then
				v54 = Instance.new("TextLabel")
				v54.BackgroundTransparency = 1
				v54.Font = FontLabel
				v54.TextSize = v and 13 or 15
				v54.Size = UDim2.fromOffset(v3, 16)
				v54.Parent = viewport.Parent
				T(v54, "TextColor3", "Dim") -- inferred equivalent call
				v39[i] = v54
			end

			v54.Text = v51[i]
			v54.Position = UDim2.fromOffset(0, result[i] - 8)
			v54.Visible = true
		else
			if v53 then
				v53.Visible = false
			end

			if v54 then
				v54.Visible = false
			end
		end
	end
end

local function getNoteSlot(count3)
	local v51 = v41[count3]

	if v51 then
		return v51
	end

	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Font = FontNum
	textLabel2.BorderSizePixel = 0
	textLabel2.ZIndex = 4
	textLabel2.Parent = content
	local frame4 = Instance.new("Frame")
	frame4.BorderSizePixel = 0
	frame4.Size = UDim2.fromOffset(v and 9 or 11, v and 9 or 11)
	frame4.ZIndex = 4
	frame4.Parent = content
	corner(frame4, 8) -- inferred equivalent call
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = FontBody
	textLabel3.TextSize = v and 9 or 11
	textLabel3.Size = UDim2.fromOffset(24, 10)
	textLabel3.ZIndex = 5
	textLabel3.Visible = false
	textLabel3.Parent = content
	local v52 = { lbl = textLabel2, dot = frame4, tech = textLabel3 }
	v41[count3] = v52
	return v52
end

local function getBarSlot(count3)
	local v51 = v42[count3]

	if v51 then
		return v51
	end

	local frame4 = Instance.new("Frame")
	frame4.BorderSizePixel = 0
	frame4.Size = UDim2.fromOffset(2, 10)
	frame4.ZIndex = 2
	frame4.Parent = content
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = FontLabel
	textLabel2.TextSize = v and 11 or 13
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Size = UDim2.fromOffset(150, 12)
	textLabel2.ZIndex = 2
	textLabel2.Parent = content
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.BorderSizePixel = 0
	textLabel3.Font = Enum.Font.PermanentMarker
	textLabel3.TextSize = v and 10 or 12
	textLabel3.TextXAlignment = Enum.TextXAlignment.Center
	textLabel3.Size = UDim2.fromOffset(78, v and 13 or 15)
	textLabel3.ZIndex = 6
	textLabel3.Visible = false
	textLabel3.Parent = content
	local v52 = { line = frame4, num = textLabel2, sec = textLabel3 }
	v42[count3] = v52
	return v52
end

local function lowerBound(t, n, p)
	local v51 = n + 1
	local v52 = 1

	while v52 < v51 do
		local v53 = (v52 + v51) // 2

		if t[v53] < p then
			v52 = v53 + 1
		else
			v51 = v53
		end
	end

	return v52
end

local function rebuildWindow(p)
	w0 = p

	local res = v43.Res
	local v51 = lowerBound(v43.T, v43.N, math.floor(w0 * res))
	local v52 = (w0 + 60) * res
	local v53 = v44 == "Drum"
	local count3 = 0

	for i = v51, v43.N do
		local v54 = v43.T[i]

		if v52 < v54 then
			break
		end

		local v55 = v43.L[i]
		local v56 = nil
		local v57 = nil
		local v58

		if v53 then
			local v59 = v19[v55]
			v56 = v59 and v20[v59]
			v58 = v56 and v56.row
		else
			v58, v57 = TabsSong.LaneRowFret(v55)

			if v45 < v58 then
				v58 = nil
			end
		end

		if not v58 then
			continue
		end

		count3 += 1
		local noteSlot = getNoteSlot(count3)
		noteSlot.tech.Visible = false
		local v59 = v43.K and v43.K[i]
		local v60 = (v54 / res - w0) * pxb
		local v61 = result[v58]

		if v56 and v56.dot then
			noteSlot.lbl.Visible = false
			noteSlot.dot.BackgroundColor3 = v16.Text
			noteSlot.dot.Position = UDim2.fromOffset(
				v60 - noteSlot.dot.Size.X.Offset / 2,
				v61 - noteSlot.dot.Size.Y.Offset / 2
			)
			noteSlot.dot.Visible = true
		else
			local text = v56 and v56.text or tostring(v57)

			if v59 == "x" and not v56 then
				text = "x"
			elseif v59 == "t" and not v56 then
				text = "(" .. tostring(v57) .. ")"
			end

			local v63 = #text >= 3 and 24 or #text >= 2 and 20 or 14
			noteSlot.dot.Visible = false
			noteSlot.lbl.Text = text
			noteSlot.lbl.TextSize = v and 13 or 15
			noteSlot.lbl.TextColor3 = v16.Text

			noteSlot.lbl.BackgroundTransparency = v56 and 1 or 0
			noteSlot.lbl.BackgroundColor3 = v16.Inset
			noteSlot.lbl.Size = UDim2.fromOffset(v63, 16)
			noteSlot.lbl.Position = UDim2.fromOffset(v60 - v63 / 2, v61 - 8)
			noteSlot.lbl.Visible = true

			if v59 and v59 ~= "x" and v8[v59] and not v56 then
				noteSlot.tech.Text = v8[v59]
				noteSlot.tech.TextColor3 = v16.Accent
				noteSlot.tech.Position = UDim2.fromOffset(v60 - 12, v61 - 18)
				noteSlot.tech.Visible = true
			end
		end
	end

	for i = count3 + 1, #v41 do
		v41[i].lbl.Visible = false
		v41[i].dot.Visible = false
		v41[i].tech.Visible = false
	end

	local v55 = math.max(0, barIndexAtBeat(w0)) -- inferred equivalent call
	local v56 = barIndexAtBeat(w0 + 60) + 1 -- inferred equivalent call
	local v57 = result[1] - 6
	local v58 = result[v45] + 6

	local barMap = v43.BarMap
	local count4 = 0

	for i = v55, v56 do
		count4 += 1
		local barSlot = getBarSlot(count4)
		local v59 = (barStartBeat(i) - w0) * pxb -- inferred equivalent call
		barSlot.line.BackgroundColor3 = v16.Line
		barSlot.line.Size = UDim2.fromOffset(2, v58 - v57)
		barSlot.line.Position = UDim2.fromOffset(v59 - 1, v57)
		barSlot.line.Visible = true
		local text = tostring(i + 1)

		if barMap then
			local v61 = barMap.Sig[i + 1]

			if v61 then
				text ..= "   " .. v61.n .. "/" .. v61.d
			end

			if i >= 1 and barMap.BpmChanges[i + 1] then
				text ..= "   " .. barMap.BpmChanges[i + 1] .. " BPM"
			end
		end

		barSlot.num.Text = text
		barSlot.num.TextColor3 = v16.Dim
		barSlot.num.Position = UDim2.fromOffset(v59 + 3, (math.max(0, v57 - 14)))
		barSlot.num.Visible = true
		local v61 = v43.SectionAt and v43.SectionAt[i + 1]

		if v61 then
			barSlot.sec.Text = string.upper(v61)
			barSlot.sec.BackgroundColor3 = v16.Tape
			barSlot.sec.TextColor3 = v16.Ink
			barSlot.sec.Position = UDim2.fromOffset(v59 + 22, 1)
			barSlot.sec.Visible = true
		else
			barSlot.sec.Visible = false
		end
	end

	for i = count4 + 1, #v42 do
		v42[i].line.Visible = false
		v42[i].num.Visible = false
		v42[i].sec.Visible = false
	end
end

local function selectionBeats()
	if not v47 or not v48 or v47 == v48 then
		return TabsPlayer.GetLoopBeats()
	end

	local v51 = math.min(v47, v48)
	local v52 = math.max(v47, v48)
	return barStartBeat(v51), barStartBeat(v52 + 1) -- inferred equivalent call
end

local function updateFrame()
	if v9 and flag2 and tabsGui and tabsGui.Enabled and v43 and TabsPlayer.GetState() == "Playing" then
		local now = os.clock()

		if now - v10 > 0.05 then
			v10 = now
			local guideLanes, v51 = TabsPlayer.GetGuideLanes(1)
			TabsKeyGuide.Set(guideLanes)

			if v51 ~= nil then
				if v13 == nil then
					v13 = InputRouter.IsOctaveUpEnabled()
				end

				if InputRouter.IsOctaveUpEnabled() ~= v51 then
					InputRouter.SetOctaveUp(v51)
				end
			end
		end

		flag = true
	elseif flag then
		flag = false
		TabsKeyGuide.Clear()

		if v13 ~= nil then
			InputRouter.SetOctaveUp(v13)
			v13 = nil
		end
	end

	if not (flag2 and tabsGui and tabsGui.Enabled and v43) then
		return
	end

	local positionBeats = TabsPlayer.GetPositionBeats()

	if not w0 or w0 + 20 < positionBeats or w0 > 0 and positionBeats < w0 + 3 then
		rebuildWindow(math.max(0, positionBeats - 6))
	end

	content.Position = UDim2.fromOffset(v4 - (positionBeats - w0) * pxb, 0)
	TabsEditor.OnFrame(w0, positionBeats)
	local v51, v52

	if v47 and v48 and v47 ~= v48 then
		local v53 = math.min(v47, v48)
		local v54 = math.max(v47, v48)
		v51 = barStartBeat(v53) -- inferred equivalent call
		v52 = barStartBeat(v54 + 1) -- inferred equivalent call
	else
		v51, v52 = TabsPlayer.GetLoopBeats()
	end

	if v51 and v52 then
		frame2.Visible = true
		frame2.Position = UDim2.fromOffset((v51 - w0) * pxb, 0)
		frame2.Size = UDim2.fromOffset((v52 - v51) * pxb, v2)
	else
		frame2.Visible = false
	end

	local now = os.clock()

	if now - v50 > 0.1 then
		v50 = now
		local v53 = barIndexAtBeat(positionBeats) + 1 -- inferred equivalent call

		local v54 = v43.Bars > 0 and v43.Bars or lastBarIndex() + 1 -- inferred equivalent call
		v22.Text = v53 < 1 and "COUNT-IN" or string.format("BAR %d/%d", math.min(v53, v54), v54)
	end
end

local function refreshControls()
	if not flag2 then
		return
	end

	v23.Text = TabsPlayer.GetState() == "Playing" and "PAUSE" or "PLAY"
	local v51 = TabsPlayer.GetState() == "Playing"

	if v23:GetAttribute("IconState") ~= v51 then
		v23:SetAttribute("IconState", v51)
		setButtonIcon(v23, v51 and "pause" or "play")
	end

	v25.Text = string.format("%d%%", (math.floor(TabsPlayer.GetSpeed() * 100 + 0.5)))
	local loopBeats, v52 = TabsPlayer.GetLoopBeats()

	if loopBeats and v52 then
		local _beatsPerBar = v43 and v43.BeatsPerBar

		v24.Text = string.format("LOOP %d-%d", barIndexAtBeat(loopBeats) + 1, barIndexAtBeat(v52 - 0.001) + 1) -- inferred equivalent call
		v24.BackgroundColor3 = v16.Accent
		v24.TextColor3 = v16.Stroke
	else
		v24.Text = "LOOP OFF"
		v24.BackgroundColor3 = v16.Button
		v24.TextColor3 = v16.Text
	end

	if v43 then
		textLabel.Text = string.upper(v43.Title) .. "  -  " .. v43.Name

		if v43.Author and v43.Author ~= "" then
			textLabel.Text ..= "   by " .. v43.Author
		end
	else
		textLabel.Text = "TABS"
	end

	v26.Text = string.upper(v15)
	v27.Text = TabsPlayer.GetMetronome() and "CLICK ON" or "CLICK OFF"
	v27.BackgroundColor3 = TabsPlayer.GetMetronome() and v16.Accent or v16.Button
	v27.TextColor3 = TabsPlayer.GetMetronome() and v16.Stroke or v16.Text
	v28.Text = TabsPlayer.GetCountIn() and "COUNT ON" or "COUNT OFF"
	v28.BackgroundColor3 = TabsPlayer.GetCountIn() and v16.Accent or v16.Button
	v28.TextColor3 = TabsPlayer.GetCountIn() and v16.Stroke or v16.Text
	v29.Visible = v43 ~= nil and v43.IsUser == true and not TabsEditor.IsActive()

	if v11 then
		local session = TabsBand.GetSession()
		v11.Text = session and "BAND ON" or "BAND"
		v11.BackgroundColor3 = session and v16.Accent or v16.Button
		v11.TextColor3 = session and v16.Stroke or v16.Text
	end

	if v30 then
		local practice = TabsPlayer.GetPractice()
		v30.Text = practice and "PRACTICE ON" or "PRACTICE OFF"
		v30.BackgroundColor3 = practice and v16.Accent or v16.Button
		v30.TextColor3 = practice and v16.Stroke or v16.Text
		v31.Text = v9 and "GUIDE ON" or "GUIDE OFF"
		v31.BackgroundColor3 = v9 and v16.Accent or v16.Button
		v31.TextColor3 = v9 and v16.Stroke or v16.Text
		v32.Text = string.format("ZOOM %d%%", (math.floor(v6[v7] * 100 + 0.5)))
	end
end

local function setTrack(loaded) -- 1 equivalent call inferred from this helper
	TabsPlayer.Load(loaded)
	v43 = loaded
	v44 = loaded.Instrument
	layoutRows()
	w0 = nil

	if tabsGui and tabsGui.Enabled then
		rebuildWindow(0)
	end

	refreshControls()
end

local function closeOverlay() -- 6 equivalent calls inferred from this helper
	v12 = false

	if frame3 then
		frame3.Visible = false
	end

	setAreaTall(false) -- inferred equivalent call
end

local function openOverlay()
	if not frame3 then
		return
	end

	v12 = false

	for _, uiListLayout in ipairs(scrollingFrame:GetChildren()) do
		if not uiListLayout:IsA("UIListLayout") then
			uiListLayout:Destroy()
		end
	end

	local v51 = currentFamily()
	local layoutOrder = 3
	local button = makeButton(scrollingFrame, "NEW TAB  (make your own)", 300, 0, "plus")
	button.Size = UDim2.new(1, -8, 0, v and 28 or 30)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Font = FontBody
	button.Activated:Connect(function()
		if v51 then
			TabsEditor.StartNew(v51)
			return
		end

		if not message then
			return
		end

		count2 += 1
		local v53 = count2
		message.Text = "  Equip a Guitar, Bass or Drum first"
		message.Visible = true
		message.TextColor3 = v16.Warn or v16.Text
		task.delay(3, function()
			if count2 == v53 and message then
				message.Text = ""
				message.Visible = false
			end
		end)
	end)
	local button2 = makeButton(scrollingFrame, "MY TABS  (saved slots)", 300, 1, "folder")
	button2.Size = UDim2.new(1, -8, 0, v and 28 or 30)
	button2.TextXAlignment = Enum.TextXAlignment.Left
	button2.Font = FontBody
	button2.Activated:Connect(function()
		if v51 then
			TabsEditor.OpenMyTabs(v51)
			return
		end

		if not message then
			return
		end

		count2 += 1
		local v53 = count2
		message.Text = "  Equip a Guitar, Bass or Drum first"
		message.Visible = true
		message.TextColor3 = v16.Warn or v16.Text
		task.delay(3, function()
			if count2 == v53 and message then
				message.Text = ""
				message.Visible = false
			end
		end)
	end)
	local button3 = makeButton(scrollingFrame, "COMMUNITY  (tabs published by players)", 300, 2, "people")
	button3.Size = UDim2.new(1, -8, 0, v and 28 or 30)
	button3.TextXAlignment = Enum.TextXAlignment.Left
	button3.Font = FontBody
	button3.Activated:Connect(function()
		if v51 then
			TabsEditor.OpenCommunity(v51)
			return
		end

		if not message then
			return
		end

		count2 += 1
		local v53 = count2
		message.Text = "  Equip a Guitar, Bass or Drum first"
		message.Visible = true
		message.TextColor3 = v16.Warn or v16.Text
		task.delay(3, function()
			if count2 == v53 and message then
				message.Text = ""
				message.Visible = false
			end
		end)
	end)

	task.spawn(function()
		if not v51 then
			return
		end

		local draftGet = TabsStore.DraftGet(v51)

		if draftGet.ok and draftGet.entry and frame3.Visible and button.Parent then
			local button4 = makeButton(
				scrollingFrame,
				"RESTORE DRAFT  (" .. tostring(draftGet.entry.Title) .. ")",
				300,
				-1,
				"undo"
			)
			button4.Size = UDim2.new(1, -8, 0, v and 28 or 30)
			button4.TextXAlignment = Enum.TextXAlignment.Left
			button4.Font = FontBody
			button4.ZIndex = 22

			for _, guiObject in ipairs(button4:GetDescendants()) do
				if guiObject:IsA("GuiObject") then
					guiObject.ZIndex = 23
				end
			end

			button4.Activated:Connect(function()
				TabsEditor.StartFromDraft(v51, draftGet.entry)
			end)
		end
	end)
	local listSongs = TabsSong.ListSongs()

	if #listSongs == 0 then
		local label = makeLabel(scrollingFrame, "No songs in the library yet.", 300, 1, Enum.TextXAlignment.Left)
		label.Size = UDim2.new(1, -8, 0, 28)
	end

	for _, listSong in ipairs(listSongs) do
		layoutOrder += 1

		local v53 = v37[listSong.Id] == true
		local count3 = #listSong.Tracks
		local v54 = string.upper(listSong.Title) .. "  -  " .. listSong.Artist .. "   " .. listSong.Bpm .. " BPM    (" .. count3 .. (count3 == 1 and " tab)" or " tabs)") .. (v53 and "   [-]" or "   [+]")
		local button4 = makeButton(scrollingFrame, v54, 300, layoutOrder, "folder")
		button4.Size = UDim2.new(1, -8, 0, v and 30 or 32)
		button4.TextXAlignment = Enum.TextXAlignment.Left
		button4.Font = FontBody
		button4.Activated:Connect(function()
			v37[listSong.Id] = not v53
			local canvasPosition = scrollingFrame.CanvasPosition
			openOverlay()
			task.defer(function()
				scrollingFrame.CanvasPosition = canvasPosition
			end)
		end)

		if not v53 then
			continue
		end

		for _, track in ipairs(listSong.Tracks) do
			layoutOrder += 1
			local v55

			if v51 == nil then
				v55 = false
			else
				v55 = track.Instrument == v51
			end

			local v56 = track.Name .. "   [" .. tostring(track.Instrument) .. "]"
			local frame4 = Instance.new("Frame")
			frame4.BackgroundTransparency = 1
			frame4.BorderSizePixel = 0
			frame4.LayoutOrder = layoutOrder
			frame4.Size = UDim2.new(1, -8, 0, v and 28 or 30)
			frame4.Parent = scrollingFrame
			local button5 = makeButton(frame4, v56, 300, 1, "note")
			button5.Position = UDim2.fromOffset(24, 0)
			button5.Size = UDim2.new(1, -24, 1, 0)
			button5.TextXAlignment = Enum.TextXAlignment.Left
			button5.Font = FontBody
			button5.TextTransparency = v55 and 0 or 0.55
			local v58 = track
			button5.Activated:Connect(function()
				if v55 then
					local loaded, v59 = TabsSong.Load(listSong.Id, v58.Id)

					if loaded then
						TabsEditor.Stop()
						setTrack(loaded) -- inferred equivalent call
						closeOverlay() -- inferred equivalent call
					else
						showMessage(tostring(v59), true) -- inferred equivalent call
					end
				else
					showMessage("Equip a " .. tostring(v58.Instrument) .. " to play this tab", true) -- inferred equivalent call
				end
			end)
		end
	end

	for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 22
		end
	end

	for _, label in ipairs(scrollingFrame:GetChildren()) do
		if label:IsA("TextLabel") and label.Font == FontLabel then
			label.Font = FontBody
		end
	end

	setAreaTall(true) -- inferred equivalent call
	frame3.Visible = true
end

local function bandItem(p, p2, p3, onActivated)
	local button = makeButton(scrollingFrame, p, 300, p2, p3)
	button.Size = UDim2.new(1, -8, 0, v and 28 or 30)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Font = FontBody

	if onActivated then
		button.Activated:Connect(onActivated)
	end

	return button
end

local function bandLabel(text, p) -- 6 equivalent calls inferred from this helper
	local label = makeLabel(scrollingFrame, text, 300, p, Enum.TextXAlignment.Left)
	label.Size = UDim2.new(1, -8, 0, 24)
	label.Font = FontBody
	label.TextTruncate = Enum.TextTruncate.AtEnd
	return label
end

local function fn()
	if not frame3 then
		return
	end

	v12 = true

	for _, uiListLayout in ipairs(scrollingFrame:GetChildren()) do
		if not uiListLayout:IsA("UIListLayout") then
			uiListLayout:Destroy()
		end
	end

	local session = TabsBand.GetSession()
	local v51 = 1
	bandItem("BACK TO SONGS", v51, "left", function()
		v12 = false
		openOverlay()
	end)

	if session then
		local v52 = v51 + 1
		bandLabel( -- inferred equivalent call
			"BAND:  " .. session.Title .. "   -   host " .. session.HostName .. "   (" .. session.Bpm .. " BPM)",
			v52
		)

		for _, v53 in ipairs(session.Members or {}) do
			v52 += 1
			bandLabel("      " .. v53.Name .. "   -   " .. v53.Instrument .. (v53.IsHost and "   (host)" or ""), v52) -- inferred equivalent call
		end

		local v53 = v52 + 1

		if session.IsHost then
			bandItem("START FOR EVERYONE  (5 second countdown)", v53, "play", function()
				TabsBand.Start()
			end)
			v53 += 1
			bandItem("STOP EVERYONE", v53, "stop", function()
				TabsBand.StopAll()
			end)
		else
			bandLabel("Waiting for the host to start. Keep your own tab of this song loaded.", v53) -- inferred equivalent call
		end

		bandItem("LEAVE BAND", v53 + 1, "img:leave", function()
			TabsBand.Leave()
		end)
	else
		local v52 = v51 + 1
		bandLabel("Everyone plays the SAME song, each with their own tab (Guitar / Bass / Drum).", v52) -- inferred equivalent call
		local v53 = v52 + 1

		if v43 then
			bandItem("HOST A BAND:  play \"" .. v43.Title .. "\" together", v53, "img:band", function()
				TabsBand.Host(v43)
			end)
		else
			bandLabel("To host a band: load your tab first (SONGS).", v53) -- inferred equivalent call
		end

		local invites = TabsBand.GetInvites()
		local v54 = v53 + 1

		if #invites == 0 then
			bandLabel("No invitations right now. When a player hosts a band you will see it here.", v54) -- inferred equivalent call
		end

		for _, invite in ipairs(invites) do
			v54 += 1
			bandItem(
				"JOIN  " .. invite.HostName .. "  -  " .. invite.Title .. "  (" .. invite.Instrument .. ")",
				v54,
				"img:join",
				function()
					if v43 and TabsBand.TitleKey(v43.Title) == TabsBand.TitleKey(invite.Title) then
						TabsBand.Join(invite.Id, v43)
						return
					end

					showMessage( -- inferred equivalent call
						"Load your own tab of \"" .. invite.Title .. "\" first (SONGS) - a Lead, Rhythm, Bass or Drum version of the same song is fine - then press JOIN",
						true
					)
				end
			)
		end
	end

	for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 22
		end
	end

	setAreaTall(true) -- inferred equivalent call
	frame3.Visible = true
end

local function barAtX(x) -- 2 equivalent calls inferred from this helper
	local v51 = TabsPlayer.GetPositionBeats() + (x - viewport.AbsolutePosition.X - v4) / pxb
	local v52 = lastBarIndex() -- inferred equivalent call
	return (math.clamp(barIndexAtBeat(v51), 0, v52)) -- inferred equivalent call
end

local function finishDrag()
	if not v47 then
		return
	end

	local v51 = v47
	local v52 = v48 or v47
	v47 = nil
	v48 = nil
	v49 = nil

	if v51 == v52 then
		local loopBeats, v53 = TabsPlayer.GetLoopBeats()
		local v54 = barStartBeat(v51) -- inferred equivalent call

		if loopBeats and v53 and (v54 < loopBeats or v53 <= v54) then
			TabsPlayer.SetLoop(nil, nil)
		end

		TabsPlayer.Seek(v54)
		w0 = nil
	else
		local v53 = math.min(v51, v52)
		local v54 = math.max(v51, v52)
		TabsPlayer.SetLoop(barStartBeat(v53), barStartBeat(v54 + 1)) -- inferred equivalent call
		TabsPlayer.Seek(barStartBeat(v53))
		w0 = nil
	end

	refreshControls()
end

local function applyZoom() -- 1 equivalent call inferred from this helper
	pxb = v5 * v6[v7]

	if content then
		content.Size = UDim2.fromOffset(60 * pxb + 400, v2)
	end

	if v14 then
		v14.PXB = pxb
	end

	w0 = nil
	refreshControls()
end

local function openSectionsMenu()
	if v43 then
		local parent = v14.beginOverlay()
		local label = makeLabel(parent, "SECTIONS", 300, 1, Enum.TextXAlignment.Left)
		label.Size = UDim2.new(1, -8, 0, 26)
		label.Font = FontBody
		label.TextColor3 = v16.Accent
		local button = makeButton(parent, "BACK", 300, 2, "left")
		button.Size = UDim2.new(1, -8, 0, v and 28 or 30)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Font = FontBody
		button.Activated:Connect(closeOverlay)
		local sections = v43.Sections or {}

		if #sections == 0 then
			local label2 = makeLabel(parent, "This tab has no sections yet.", 300, 3, Enum.TextXAlignment.Left)
			label2.Size = UDim2.new(1, -8, 0, 26)
			label2.Font = FontBody
		end

		for i, section in ipairs(sections) do
			local button2 = makeButton(parent, "Bar " .. section.bar .. "    " .. section.name, 300, 2 + i, "flag")
			button2.Size = UDim2.new(1, -8, 0, v and 28 or 30)
			button2.TextXAlignment = Enum.TextXAlignment.Left
			button2.Font = FontBody
			button2.Activated:Connect(function()
				TabsPlayer.Seek(barStartBeat(section.bar - 1))
				w0 = nil
				closeOverlay() -- inferred equivalent call
			end)
		end

		v14.endOverlay()
	else
		if not message then
			return
		end

		count2 += 1
		local v51 = count2
		message.Text = "  Open a tab first"
		message.Visible = true
		message.TextColor3 = v16.Warn or v16.Text
		task.delay(3, function()
			if count2 == v51 and message then
				message.Text = ""
				message.Visible = false
			end
		end)
	end
end

local function cellOf(p, p2)
	if not p2 then
		local laneRowFret, v51 = TabsSong.LaneRowFret(p)
		return laneRowFret, nil, v51
	end

	local v51 = v19[p]
	local v52 = v51 and v20[v51]
	return v52 and v52.row, v52, nil
end

local function openPrintView()
	if v43 then
		local button = makeButton(v14.beginOverlay(), "BACK   (click a bar to jump there)", 300, 1, "left")
		button.Size = UDim2.new(1, -8, 0, v and 28 or 30)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Font = FontBody
		button.Activated:Connect(function()
			count += 1
			closeOverlay() -- inferred equivalent call
		end)
		v14.endOverlay()
		count += 1
		local v52 = count
		local v53 = v43
		task.spawn(function()
			local beatsPerBar2 = v53.BeatsPerBar or 4
			local res = v53.Res
			local barMap = v53.BarMap
			local v54 = math.max(1, v53.Bars > 0 and v53.Bars or math.ceil(v53.EndUnits / res / beatsPerBar2))
			local v55

			if barMap then
				v55 = beatsPerBar2

				for i = 1, v54 do
					v55 = math.max(v55, barMap.BeatsOfBar(i))
				end
			else
				v55 = beatsPerBar2
			end

			local function pStart(p) -- 5 equivalent calls inferred from this helper
				return barMap and barMap.StartBeat(p + 1) or p * beatsPerBar2
			end

			local function pBeats(p)
				return barMap and barMap.BeatsOfBar(p + 1) or beatsPerBar2
			end

			local v56 = v53.Instrument == "Drum"
			local v57 = v18[v53.Instrument] or v18.Guitar
			local count3 = #v57
			local v58 = math.max(320, scrollingFrame.AbsoluteSize.X - 28)

			local v59 = (v58 - 24) / v55 > 150 and 4 or 2
			local v60 = (v58 - 24) / (v59 * v55)
			local v61 = v and 13 or 16
			local v62 = count3 * v61 + 22 + 8

			for i = 1, math.ceil(v54 / v59) do
				if count ~= v52 then
					break
				end

				local v63 = (i - 1) * v59
				local frame4 = Instance.new("Frame")
				frame4.BorderSizePixel = 0
				frame4.BackgroundColor3 = v16.Inset
				frame4.Size = UDim2.new(1, -8, 0, v62)
				frame4.LayoutOrder = i + 10
				frame4.ZIndex = 22
				frame4.Parent = scrollingFrame
				corner(frame4, 2) -- inferred equivalent call

				for j = 1, count3 do
					local v64 = 22 + (j - 0.5) * v61
					local frame5 = Instance.new("Frame")
					frame5.BorderSizePixel = 0
					frame5.BackgroundColor3 = v16.Line
					frame5.Position = UDim2.fromOffset(24, v64)
					frame5.Size = UDim2.new(1, -26, 0, 1)
					frame5.ZIndex = 1
					frame5.Parent = frame4
					local textLabel2 = Instance.new("TextLabel")
					textLabel2.BackgroundTransparency = 1
					textLabel2.Font = FontLabel
					textLabel2.TextSize = v and 10 or 12
					textLabel2.TextColor3 = v16.Dim
					textLabel2.Text = v57[j]
					textLabel2.Position = UDim2.fromOffset(0, v64 - 7)
					textLabel2.Size = UDim2.fromOffset(22, 14)
					textLabel2.ZIndex = 2
					textLabel2.Parent = frame4
				end

				for j = 0, v59 - 1 do
					local v64 = v63 + j

					if v54 <= v64 then
						break
					end

					local v65 = 24 + (pStart(v64) - pStart(v63)) * v60 -- inferred equivalent call

					local frame5 = Instance.new("Frame")
					frame5.BorderSizePixel = 0
					frame5.BackgroundColor3 = v16.Line
					frame5.Position = UDim2.fromOffset(v65, 22)
					frame5.Size = UDim2.fromOffset(2, count3 * v61)
					frame5.ZIndex = 2
					frame5.Parent = frame4
					local textLabel2 = Instance.new("TextLabel")
					textLabel2.BackgroundTransparency = 1
					textLabel2.Font = FontLabel
					textLabel2.TextSize = v and 10 or 12
					textLabel2.TextColor3 = v16.Dim
					textLabel2.TextXAlignment = Enum.TextXAlignment.Left
					textLabel2.Text = tostring(v64 + 1)
					textLabel2.Position = UDim2.fromOffset(v65 + 3, 4)
					textLabel2.Size = UDim2.fromOffset(30, 13)
					textLabel2.ZIndex = 2
					textLabel2.Parent = frame4
					local v66 = v53.SectionAt and v53.SectionAt[v64 + 1]

					if v66 then
						local textLabel3 = Instance.new("TextLabel")
						textLabel3.BorderSizePixel = 0
						textLabel3.BackgroundColor3 = v16.Tape
						textLabel3.TextColor3 = v16.Ink
						textLabel3.Font = Enum.Font.PermanentMarker
						textLabel3.TextSize = v and 10 or 12
						textLabel3.Text = string.upper(v66)
						textLabel3.Position = UDim2.fromOffset(v65 + 26, 3)
						textLabel3.Size = UDim2.fromOffset(78, 14)
						textLabel3.ZIndex = 3
						textLabel3.Parent = frame4
					end

					local textButton = Instance.new("TextButton")
					textButton.Text = ""
					textButton.AutoButtonColor = false
					textButton.BackgroundTransparency = 1
					textButton.Position = UDim2.fromOffset(v65, 0)
					local v67

					if barMap then
						v67 = barMap.BeatsOfBar(v64 + 1) or beatsPerBar2
					else
						v67 = beatsPerBar2
					end

					textButton.Size = UDim2.fromOffset(v67 * v60, v62)
					textButton.ZIndex = 4
					textButton.Parent = frame4
					textButton.Activated:Connect(function()
						count += 1
						TabsPlayer.Seek(pStart(v64)) -- inferred equivalent call
						w0 = nil
						closeOverlay() -- inferred equivalent call
					end)
				end

				local v64 = pStart(v63) * res -- inferred equivalent call
				local v65 = pStart(v63 + v59) * res -- inferred equivalent call

				for j = lowerBound(v53.T, v53.N, v64), v53.N do
					local v66 = v53.T[j]

					if v65 <= v66 then
						break
					end

					local v67 = v53.L[j]
					local v68, v69, v70

					if v56 then
						local v71 = v19[v67]
						v68 = v71 and v20[v71]
						v69 = v68 and v68.row
					else
						v69, v70 = TabsSong.LaneRowFret(v67)
					end

					if not (v69 and v69 <= count3) then
						continue
					end

					local v71 = 24 + (v66 - v64) / res * v60
					local v72 = 22 + (v69 - 0.5) * v61
					local v73 = v53.K and v53.K[j]

					if v68 and v68.dot then
						local frame5 = Instance.new("Frame")
						frame5.BorderSizePixel = 0
						frame5.BackgroundColor3 = v16.Text
						frame5.Position = UDim2.fromOffset(v71 - 4, v72 - 4)
						frame5.Size = UDim2.fromOffset(8, 8)
						frame5.ZIndex = 3
						frame5.Parent = frame4
						corner(frame5, 8) -- inferred equivalent call
					else
						local text = v68 and v68.text
							or v73 == "x" and "x"
							or v73 == "t" and "(" .. tostring(v70) .. ")"
							or tostring(v70)
						local textLabel2 = Instance.new("TextLabel")
						textLabel2.BorderSizePixel = 0
						textLabel2.BackgroundColor3 = v16.Inset
						textLabel2.BackgroundTransparency = v68 and 1 or 0
						textLabel2.Font = FontNum
						textLabel2.TextSize = v and 11 or 13
						textLabel2.TextColor3 = v16.Text
						textLabel2.Text = text
						local v74 = #text >= 3 and 20 or #text >= 2 and 16 or 11
						textLabel2.Position = UDim2.fromOffset(v71 - v74 / 2, v72 - 7)
						textLabel2.Size = UDim2.fromOffset(v74, 14)
						textLabel2.ZIndex = 3
						textLabel2.Parent = frame4

						if v73 and v73 ~= "x" and v8[v73] and not v68 then
							local textLabel3 = Instance.new("TextLabel")
							textLabel3.BackgroundTransparency = 1
							textLabel3.Font = FontBody
							textLabel3.TextSize = 9
							textLabel3.TextColor3 = v16.Accent
							textLabel3.Text = v8[v73]
							textLabel3.Position = UDim2.fromOffset(v71 - 10, v72 - 15)
							textLabel3.Size = UDim2.fromOffset(20, 9)
							textLabel3.ZIndex = 3
							textLabel3.Parent = frame4
						end
					end
				end

				if i % 3 == 0 then
					task.wait()
				end
			end
		end)
	else
		if not message then
			return
		end

		count2 += 1
		local v51 = count2
		message.Text = "  Open a tab first"
		message.Visible = true
		message.TextColor3 = v16.Warn or v16.Text
		task.delay(3, function()
			if count2 == v51 and message then
				message.Text = ""
				message.Visible = false
			end
		end)
	end
end

local function build()
	if flag2 then
		return
	end

	flag2 = true
	local localPlayer = Players.LocalPlayer
	tabsGui = Instance.new("ScreenGui")
	tabsGui.Name = "TabsGui"
	tabsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	tabsGui.ResetOnSpawn = false
	tabsGui.DisplayOrder = 40
	tabsGui.IgnoreGuiInset = true
	tabsGui.Enabled = false
	tabsGui.Parent = localPlayer:WaitForChild("PlayerGui")

	local currentCamera = Workspace.CurrentCamera
	local v51 = math.clamp(
		(currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)).X - 16,
		320,
		v and 640 or 900
	)

	root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.AnchorPoint = Vector2.new(0.5, 0)
	root.Position = UDim2.new(0.5, 0, 0, v and 8 or 46)
	root.Size = UDim2.fromOffset(v51, 40)
	root.Parent = tabsGui

	panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(1, 0, 0, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BorderSizePixel = 0
	panel.Parent = root

	local function syncRoot()
		root.Size = UDim2.fromOffset(v51, panel.AbsoluteSize.Y)
	end
	panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncRoot)
	TabsUI._syncRoot = syncRoot

	local success, result2 = pcall(function()
		return require(script.Parent.FreePlayScrollGuard)
	end)

	if success and result2 and result2.Attach then
		result2.Attach(tabsGui, function()
			return { panel }
		end)
	end

	T(panel, "BackgroundColor3", "Panel") -- inferred equivalent call
	corner(panel) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Parent = panel
	T(uiStroke, "Color", "Stroke") -- inferred equivalent call
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 6)
	local udim2 = UDim.new(0, 8)
	uiPadding.PaddingTop = udim
	uiPadding.PaddingBottom = udim2
	local udim3 = UDim.new(0, 8)
	local udim4 = UDim.new(0, 8)
	uiPadding.PaddingLeft = udim3
	uiPadding.PaddingRight = udim4
	uiPadding.Parent = panel
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.Parent = panel

	newUIDecorHolder = Instance.new("Frame")
	newUIDecorHolder.Name = "NewUIDecorHolder"
	newUIDecorHolder.BackgroundTransparency = 1
	newUIDecorHolder.BorderSizePixel = 0
	newUIDecorHolder.Active = false
	newUIDecorHolder.ZIndex = 50
	newUIDecorHolder.Position = UDim2.fromOffset(0, 0)
	newUIDecorHolder.Size = UDim2.new(1, 0, 1, 0)
	newUIDecorHolder.Parent = root
	TabsSkin.decorate(newUIDecorHolder, v15)

	local frame4 = Instance.new("Frame")
	frame4.BackgroundTransparency = 1
	frame4.Size = UDim2.new(1, 0, 0, 28)
	frame4.LayoutOrder = 1
	frame4.Parent = panel
	textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = FontLabel
	textLabel.TextSize = v and 15 or 18
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Text = "TABS"
	textLabel.Size = UDim2.new(1, -160, 1, 0)
	textLabel.Parent = frame4
	T(textLabel, "TextColor3", "Text") -- inferred equivalent call
	local frame5 = Instance.new("Frame")
	frame5.BackgroundTransparency = 1
	frame5.AnchorPoint = Vector2.new(1, 0.5)
	frame5.Position = UDim2.new(1, 0, 0.5, 0)
	frame5.Size = UDim2.fromOffset(150, 26)
	frame5.Parent = frame4
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout2.Padding = UDim.new(0, 4)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = frame5
	v26 = makeButton(frame5, "DARK", 74, 1, "theme")
	local button = makeButton(frame5, "", 30, 2, "minimize")
	local button2 = makeButton(frame5, "", 30, 3, "close", "danger")

	local frame6 = Instance.new("Frame")
	frame6.BackgroundTransparency = 1
	frame6.Size = UDim2.new(1, 0, 0, v and 26 or 28)
	frame6.AutomaticSize = Enum.AutomaticSize.Y
	frame6.LayoutOrder = 2
	frame6.Parent = panel
	v21[#v21 + 1] = frame6
	local uiListLayout3 = Instance.new("UIListLayout")
	uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout3.Padding = UDim.new(0, 5)
	uiListLayout3.Wraps = true
	uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout3.Parent = frame6

	local button3 = makeButton(frame6, "SONGS", v and 72 or 82, 1, "note")
	v23 = makeButton(frame6, "PLAY", v and 70 or 82, 2, "play")
	local button4 = makeButton(frame6, "STOP", v and 62 or 72, 3, "stop")
	local button5 = makeButton(frame6, "", 28, 4, "minus")
	v25 = makeLabel(frame6, "100%", v and 40 or 46, 5)
	local button6 = makeButton(frame6, "", 28, 6, "plus")
	v24 = makeButton(frame6, "LOOP OFF", v and 92 or 106, 7, "loop")
	v27 = makeButton(frame6, "CLICK OFF", v and 92 or 104, 8, "metro")
	v28 = makeButton(frame6, "COUNT OFF", v and 96 or 108, 9, "count")
	v29 = makeButton(frame6, "EDIT", 70, 10, "edit")
	v29.Visible = false
	v30 = makeButton(frame6, "PRACTICE OFF", v and 120 or 134, 11, "target")
	v31 = makeButton(frame6, "GUIDE ON", v and 92 or 102, 12, "keys")
	v32 = makeButton(frame6, "ZOOM 100%", v and 100 or 112, 13, "zoom")
	v34 = makeButton(frame6, "SECTIONS", v and 96 or 108, 14, "flag")
	v35 = makeButton(frame6, "PRINT", v and 76 or 84, 15, "print")
	v11 = makeButton(frame6, "BAND", v and 78 or 90, 16, "img:band")
	v22 = makeLabel(frame6, "BAR 1/1", v and 70 or 84, 20)

	local area = Instance.new("Frame")
	area.Name = "Area"
	area.Size = UDim2.new(1, 0, 0, v2)
	area.LayoutOrder = 3
	area.BorderSizePixel = 0
	area.ClipsDescendants = true
	area.Parent = panel
	v36 = area
	v21[#v21 + 1] = area
	T(area, "BackgroundColor3", "Inset") -- inferred equivalent call
	corner(area) -- inferred equivalent call
	message = Instance.new("TextLabel")
	message.Name = "Message"
	message.BackgroundTransparency = 0.25
	message.BorderSizePixel = 0
	message.Font = FontLabel
	message.TextSize = v and 12 or 14
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextTruncate = Enum.TextTruncate.AtEnd
	message.Text = ""
	message.Visible = false
	message.AnchorPoint = Vector2.new(0, 1)
	message.Position = UDim2.new(0, v3 + 6, 1, -4)
	message.Size = UDim2.new(1, -(v3 + 12), 0, 20)
	message.ZIndex = 30
	message.Parent = area
	T(message, "BackgroundColor3", "Panel") -- inferred equivalent call
	T(message, "TextColor3", "Dim") -- inferred equivalent call
	viewport = Instance.new("Frame")
	viewport.Name = "Viewport"
	viewport.BackgroundTransparency = 1
	viewport.Position = UDim2.fromOffset(v3, 0)
	viewport.Size = UDim2.new(1, -v3, 1, 0)
	viewport.ClipsDescendants = true
	viewport.Active = true
	viewport.Parent = area

	frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.BackgroundTransparency = 0.82
	frame2.ZIndex = 1
	frame2.Visible = false
	frame2.Parent = nil

	content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.fromOffset(60 * pxb + 400, v2)
	content.Parent = viewport
	frame2.Parent = content
	T(frame2, "BackgroundColor3", "Accent") -- inferred equivalent call
	frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(0, 2, 1, 0)
	frame.Position = UDim2.fromOffset(v4 - 1, 0)
	frame.ZIndex = 6
	frame.Parent = viewport
	T(frame, "BackgroundColor3", "Accent") -- inferred equivalent call
	frame3 = Instance.new("Frame")
	frame3.BorderSizePixel = 0
	frame3.Size = UDim2.new(1, 0, 1, 0)
	frame3.ZIndex = 20
	frame3.Active = true
	frame3.Visible = false
	frame3.Parent = area
	T(frame3, "BackgroundColor3", "Panel") -- inferred equivalent call
	scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Size = UDim2.new(1, -8, 1, -8)
	scrollingFrame.Position = UDim2.fromOffset(4, 4)
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.CanvasSize = UDim2.new()
	scrollingFrame.ZIndex = 21
	scrollingFrame.Parent = frame3
	local uiListLayout4 = Instance.new("UIListLayout")
	uiListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout4.Padding = UDim.new(0, 4)
	uiListLayout4.Parent = scrollingFrame

	button3.Activated:Connect(function()
		if frame3.Visible then
			closeOverlay() -- inferred equivalent call
		else
			openOverlay()
		end
	end)
	v11.Activated:Connect(function()
		if frame3.Visible and v12 then
			closeOverlay() -- inferred equivalent call
		else
			fn()
		end
	end)
	v23.Activated:Connect(function()
		if not v43 then
			openOverlay()
			return
		end

		if TabsPlayer.GetState() == "Playing" then
			TabsPlayer.Pause()
		else
			local v52, v53 = TabsPlayer.Play()

			if not v52 then
				showMessage(tostring(v53), true) -- inferred equivalent call
			end
		end

		refreshControls()
	end)
	button4.Activated:Connect(function()
		TabsPlayer.Stop()
		w0 = nil
		refreshControls()
	end)
	button5.Activated:Connect(function()
		TabsPlayer.SetSpeed(math.floor((TabsPlayer.GetSpeed() - 0.1) * 10 + 0.5) / 10)
		refreshControls()
	end)
	button6.Activated:Connect(function()
		TabsPlayer.SetSpeed(math.floor((TabsPlayer.GetSpeed() + 0.1) * 10 + 0.5) / 10)
		refreshControls()
	end)
	v24.Activated:Connect(function()
		local loopBeats, v52 = TabsPlayer.GetLoopBeats()

		if loopBeats and v52 then
			TabsPlayer.SetLoop(nil, nil)

			if message then
				count2 += 1
				local v53 = count2
				message.Text = "  Loop off"
				message.Visible = true
				message.TextColor3 = v16.Text
				task.delay(3, function()
					if count2 == v53 and message then
						message.Text = ""
						message.Visible = false
					end
				end)
			end
		elseif v43 then
			local v53 = lastBarIndex() + 1 -- inferred equivalent call

			local v54 = math.clamp(barIndexAtBeat(TabsPlayer.GetPositionBeats()), 0, v53 - 1) -- inferred equivalent call

			local sections = v43.Sections or {}
			local v55 = nil
			local v56 = nil

			for i, section in ipairs(sections) do
				local v58 = section.bar - 1
				local v59

				if sections[i + 1] then
					v59 = sections[i + 1].bar - 1 or v53
				else
					v59 = v53
				end

				if v58 <= v54 and v54 < v59 then
					v56 = v59 - 1
					v55 = v58
					break
				end
			end

			if not v55 then
				v55 = v54 - v54 % 4
				v56 = math.min(v53 - 1, v55 + 3)
			end

			TabsPlayer.SetLoop(barStartBeat(v55), barStartBeat(v56 + 1)) -- inferred equivalent call
			TabsPlayer.Seek(barStartBeat(v55))
			w0 = nil
			showMessage( -- inferred equivalent call
				string.format("Loop ON: bars %d-%d  (drag across bars to pick your own range)", v55 + 1, v56 + 1),
				false
			)
		elseif message then
			count2 += 1
			local v53 = count2
			message.Text = "  Open a tab first"
			message.Visible = true
			message.TextColor3 = v16.Warn or v16.Text
			task.delay(3, function()
				if count2 == v53 and message then
					message.Text = ""
					message.Visible = false
				end
			end)
		end

		refreshControls()
	end)
	v27.Activated:Connect(function()
		TabsPlayer.SetMetronome(not TabsPlayer.GetMetronome())

		if TabsPlayer.GetMetronome() then
			ensureClick()
		end

		refreshControls()
	end)
	v28.Activated:Connect(function()
		TabsPlayer.SetCountIn(not TabsPlayer.GetCountIn())
		refreshControls()
	end)
	v29.Activated:Connect(function()
		if v43 and v43.IsUser then
			TabsEditor.StartFromTrack(v43, (tonumber(v43.TrackId)))
		end
	end)
	v30.Activated:Connect(function()
		TabsPlayer.SetPractice(not TabsPlayer.GetPractice())
		local v52 = TabsPlayer.GetPractice() and "Practice: the tab waits for the keys you press (press PLAY)"
			or "Practice off"

		if message then
			count2 += 1
			local v53 = count2
			message.Text = "  " .. v52
			message.Visible = v52 ~= ""
			message.TextColor3 = v16.Text
			task.delay(3, function()
				if count2 == v53 and message then
					message.Text = ""
					message.Visible = false
				end
			end)
		end

		refreshControls()
	end)
	v31.Activated:Connect(function()
		v9 = not v9

		if not v9 then
			TabsKeyGuide.Clear()
		end

		refreshControls()
	end)
	v32.Activated:Connect(function()
		v7 = v7 % #v6 + 1
		applyZoom() -- inferred equivalent call
	end)
	v34.Activated:Connect(openSectionsMenu)
	v35.Activated:Connect(openPrintView)

	v14 = {
		panel = panel,
		viewport = viewport,
		content = content,
		PXB = pxb,
		PLAYHEAD_X = v4,
		AREA_H = v2,
		IS_MOBILE = v,
		T = T,
		corner = corner,
		makeButton = makeButton,
		makeLabel = makeLabel,
		theme = function()
			return v16
		end,
		getRows = function()
			return result, v45
		end,
		setTrack = setTrack,
		invalidate = function()
			w0 = nil
		end,
		showMessage = showMessage,
		beginOverlay = function()
			for _, uiListLayout5 in ipairs(scrollingFrame:GetChildren()) do
				if not uiListLayout5:IsA("UIListLayout") then
					uiListLayout5:Destroy()
				end
			end

			return scrollingFrame
		end,
		endOverlay = function()
			for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				guiObject.ZIndex = 22

				for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
					if guiObject2:IsA("GuiObject") then
						guiObject2.ZIndex = 23
					end
				end
			end

			setAreaTall(true) -- inferred equivalent call
			frame3.Visible = true
		end,
		closeOverlay = closeOverlay,
		reopenSongs = openOverlay,
		refreshControls = refreshControls
	}

	TabsEditor.Init(v14)
	TabsPlayer.OnBeat(function(p)
		ensureClick()
		local v52 = p and tabsClickAccent or tabsClick

		if v52 then
			v52:Play()
		end
	end)
	v26.Activated:Connect(function()
		v15 = v15 == "Dark" and "Light" or "Dark"
		v16 = Palettes[v15]
		TabsSkin.decorate(newUIDecorHolder, v15)
		local v52 = {}

		for _, v53 in ipairs(v17) do
			if not v53[1].Parent then
				continue
			end

			v53[1][v53[2]] = v16[v53[3]]
			v52[#v52 + 1] = v53
		end

		v17 = v52
		w0 = nil
		refreshControls()

		if frame3.Visible then
			openOverlay()
		end
	end)
	button.Activated:Connect(function()
		local visible = not frame6.Visible

		for _, v53 in ipairs(v21) do
			v53.Visible = visible
		end
	end)
	button2.Activated:Connect(function()
		TabsUI.Close()
	end)

	local v52 = false
	local v53 = nil
	local v54 = nil
	frame4.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local position = input.Position
			local position2 = root.Position
			v52 = true
			v53 = position
			v54 = position2
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					v52 = false
				end
			end)
		end
	end)

	viewport.InputBegan:Connect(function(input)
		if TabsEditor.IsActive() or (not v43 or frame3.Visible) then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v49 = input
			v47 = barAtX(input.Position.X) -- inferred equivalent call
			v48 = v47
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if
			v52
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			local v55 = input.Position - v53
			root.Position = UDim2.new(v54.X.Scale, v54.X.Offset + v55.X, v54.Y.Scale, v54.Y.Offset + v55.Y)
		end

		if v47 and v43 and (input.UserInputType == Enum.UserInputType.MouseMovement or input == v49) then
			v48 = barAtX(input.Position.X) -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if v47 and (input == v49 or input.UserInputType == Enum.UserInputType.MouseButton1) then
			finishDrag()
		end
	end)

	RunService.RenderStepped:Connect(updateFrame)

	TabsPlayer.OnChanged(function()
		refreshControls()
	end)

	task.spawn(function()
		while true do
			task.wait(0.5)

			if not tabsGui.Enabled then
				continue
			end

			local v55 = currentFamily()

			if (TabsUI._familyOverride or ModeManager.IsFreePlay()) and v55 ~= nil then
				if v43 and v43.Instrument ~= v55 then
					TabsEditor.Stop()
					TabsPlayer.Stop()
					v43 = nil
					w0 = nil
					TabsPlayer.Load(nil)
					textLabel.Text = "TABS"

					for _, v56 in ipairs(v41) do
						v56.lbl.Visible = false
						v56.dot.Visible = false
					end

					for _, v56 in ipairs(v42) do
						v56.line.Visible = false
						v56.num.Visible = false
					end

					v44 = v55
					layoutRows()
					openOverlay()
					showMessage("Instrument changed - pick a tab for " .. v55, true) -- inferred equivalent call
					refreshControls()
				end
			else
				TabsUI.Close()
			end
		end
	end)

	layoutRows()
	refreshControls()
end

function TabsUI.IsOpen()
	return tabsGui ~= nil and tabsGui.Enabled
end

function TabsUI.Open(): boolean
	local v51 = currentFamily()

	if not (v51 and (TabsUI._familyOverride or ModeManager.IsFreePlay())) then
		return false
	end

	local TabsIcons = require(script.Parent.TabsIcons)
	TabsIcons.preload()
	build()
	tabsGui.Enabled = true

	if TabsUI._syncRoot then
		TabsUI._syncRoot()
	end

	if v43 then
		w0 = nil
	else
		v44 = v51
		layoutRows()
		openOverlay()
	end

	refreshControls()
	return true
end

function TabsUI.Close()
	if tabsGui and tabsGui.Enabled then
		TabsPlayer.Pause()
		v47 = nil
		v48 = nil
		v49 = nil
		tabsGui.Enabled = false
	end
end

function TabsUI.Toggle()
	if TabsUI.IsOpen() then
		TabsUI.Close()
	else
		TabsUI.Open()
	end
end

function TabsUI._debug()
	return {
		gui = tabsGui,
		notes = #v41,
		bars = #v42,
		w0 = w0
	}
end

TabsBand.OnMessage(function(p, p2)
	showMessage(p, p2)
end)
TabsBand.OnChanged(function()
	refreshControls()

	if v12 and frame3 and frame3.Visible then
		fn()
	end
end)
TabsBand.SetOpenHandler(function()
	if not TabsUI.IsOpen() then
		TabsUI.Open()
	end

	task.defer(function()
		if fn then
			fn()
		end
	end)
end)
TabsBand.Init()

return TabsUI