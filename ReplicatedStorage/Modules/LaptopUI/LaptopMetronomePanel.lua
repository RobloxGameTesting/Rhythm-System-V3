local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(script.Parent.Theme)
local Retro = require(script.Parent.Retro)
local SegmentedSlider = require(script.Parent.SegmentedSlider)
local MetronomeConfig = require(ReplicatedStorage.Modules:WaitForChild("MetronomeConfig"))

local metronomeSet = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("MetronomeSet", 5)

local Colors = Theme.Colors
local v = { [0] = "Off", [1] = "1 bar", [2] = "2 bars" }
local v2 = { [0] = 32, [1] = 40, [2] = 44 }

local function addStroke(parent, p, value) -- 2 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = p or Colors.Border
	uiStroke.Transparency = value or 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = parent
	return uiStroke
end

local function newLabel(parent, text, options)
	local v3 = options or {}
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = v3.font or Theme.Fonts.Regular
	textLabel.TextSize = v3.size or 11
	textLabel.TextColor3 = v3.color or Colors.TextPrimary
	textLabel.TextXAlignment = v3.xAlign or Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Text = text
	textLabel.Size = v3.sizeUDim or UDim2.new(1, 0, 1, 0)
	textLabel.Parent = parent
	return textLabel
end

local function newButton(parent, text, options)
	local v3 = options or {}
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = v3.bg or Colors.SurfaceHover
	textButton.BorderSizePixel = 0
	textButton.Font = v3.font or Theme.Fonts.Label
	textButton.TextSize = v3.size or 11
	textButton.TextColor3 = v3.color or Colors.TextPrimary
	textButton.Text = text
	textButton.Size = v3.sizeUDim or UDim2.new(0, 22, 0, 22)
	textButton.Parent = parent

	if v3.stroke == false then
		return textButton
	end

	local border = Colors.Border
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = border or Colors.Border
	uiStroke.Transparency = 0.2
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = textButton

	return textButton
end

local function refresh(data)
	local cfg = data.cfg

	if not data.bpmBox:IsFocused() then
		data.bpmBox.Text = tostring(cfg.bpm)
	end

	local start = data.hints.start

	if cfg.on then
		start.setText("Stop")
		start.setVariant("danger")
		data.status.Text = "● PLAYING"
		data.status.TextColor3 = Colors.Success
	else
		start.setText("Start")
		start.setVariant("primary")
		data.status.Text = "STOPPED"
		data.status.TextColor3 = Colors.TextSecondary
	end

	for k, chip in pairs(data.chips) do
		local v3 = cfg.cin == k
		chip.BackgroundColor3 = v3 and Colors.Accent or Colors.Background
		chip.TextColor3 = v3 and Colors.AccentText or Colors.TextSecondary
	end

	for _, selector in pairs(data.selectors) do
		selector(cfg)
	end
end

local function fireRemote(p, p2, p3) -- 2 equivalent calls inferred from this helper
	if metronomeSet then
		metronomeSet:FireServer(p.studioId, p2, p3)
	end
end

local function send(p, p2, p3) -- 5 equivalent calls inferred from this helper
	local metro = p.metro

	if p2 ~= "toggle" then
		MetronomeConfig.Apply(metro.cfg, p2, p3)
		refresh(metro)
	end

	if p2 == "vol" then
		metro.volAt = os.clock()

		if not metro.sendVol then
			metro.sendVol = SegmentedSlider.Throttle(function(p4, p5)
				fireRemote(p, p4, p5) -- inferred equivalent call
			end, 0.12)
		end

		metro.sendVol("vol", p3)
	else
		fireRemote(p, p2, p3) -- inferred equivalent call
	end
end

local function makeRow(parent, p, value, p2)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Colors.Surface
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(0, 0, 0, p)
	frame.Size = UDim2.new(1, 0, 0, 18)
	frame.Parent = parent
	local v3 = newLabel(frame, string.upper(value), {
		font = Theme.Fonts.Label,
		size = 10,
		sizeUDim = UDim2.new(0, 130, 1, 0)
	})

	v3.Position = UDim2.new(0, 8, 0, 0)
	local v4 = { v3 }

	if p2 then
		return frame, v4
	end

	frame.MouseEnter:Connect(function()
		frame.BackgroundColor3 = Colors.Accent

		for _, v5 in ipairs(v4) do
			v5.TextColor3 = Colors.AccentText
		end
	end)
	frame.MouseLeave:Connect(function()
		frame.BackgroundColor3 = Colors.Surface

		for i, v5 in ipairs(v4) do
			v5.TextColor3 = i == 1 and Colors.TextPrimary or v5:GetAttribute("BaseColor") or Colors.TextPrimary
		end
	end)
	return frame, v4
end

local function addSelectorRow(p, content, p2, p3, p4, list, fn, fn2)
	local metro = p.metro
	local row, v3 = makeRow(content, p2, p4)

	local v4 = newButton(row, ">", {
		sizeUDim = UDim2.new(0, 16, 0, 14),
		stroke = false,
		bg = Colors.Background
	})
	v4.AnchorPoint = Vector2.new(1, 0.5)
	v4.Position = UDim2.new(1, -6, 0.5, 0)
	local v5 = newLabel(row, "", {
		font = Theme.Fonts.Regular,
		size = 11,
		color = Colors.TextPrimary,
		xAlign = Enum.TextXAlignment.Center,
		sizeUDim = UDim2.new(0, 84, 1, 0)
	})

	v5.AnchorPoint = Vector2.new(1, 0)
	v5.Position = UDim2.new(1, -24, 0, 0)
	v5:SetAttribute("BaseColor", Colors.TextPrimary)
	table.insert(v3, v5)
	local v6 = newButton(row, "<", {
		sizeUDim = UDim2.new(0, 16, 0, 14),
		stroke = false,
		bg = Colors.Background
	})
	v6.AnchorPoint = Vector2.new(1, 0.5)
	v6.Position = UDim2.new(1, -110, 0.5, 0)

	local function step(p5)
		local v7 = fn2(metro.cfg)
		local v8 = 1

		for i, item in ipairs(list) do
			if item == v7 then
				v8 = i
				break
			end
		end

		send(p, p3, list[(v8 - 1 + p5) % #list + 1])
	end
	v6.Activated:Connect(function()
		step(-1)
	end)
	v4.Activated:Connect(function()
		step(1)
	end)
	metro.selectors[p3] = function(p5)
		v5.Text = string.upper(fn(fn2(p5)))
	end
end

local function addSliderRow(p, content, p2, p3, p4, VOLUME_STEPS, fn, fn2)
	local metro = p.metro
	local row = makeRow(content, p2, p4, true)

	local function indexOf(p5) -- 2 equivalent calls inferred from this helper
		for i, item in ipairs(VOLUME_STEPS) do
			if item == p5 then
				return i
			end
		end

		return 1
	end

	local v3 = newButton(row, "+", {
		sizeUDim = UDim2.new(0, 16, 0, 14),
		stroke = false,
		bg = Colors.Background
	})
	v3.AnchorPoint = Vector2.new(1, 0.5)
	v3.Position = UDim2.new(1, -6, 0.5, 0)

	local v4 = newLabel(row, "", {
		font = Theme.Fonts.Regular,
		size = 11,
		color = Colors.TextPrimary,
		xAlign = Enum.TextXAlignment.Center,
		sizeUDim = UDim2.new(0, 34, 1, 0)
	})

	v4.AnchorPoint = Vector2.new(1, 0)
	v4.Position = UDim2.new(1, -24, 0, 0)

	local v5 = SegmentedSlider.new(row, {
		steps = #VOLUME_STEPS,
		size = UDim2.new(0, 96, 0, 12),
		anchorPoint = Vector2.new(1, 0.5),
		position = UDim2.new(1, -60, 0.5, 0),
		onSelect = function(p5)
			send(p, p3, VOLUME_STEPS[p5])
		end
	})

	local v6 = newButton(row, "-", {
		sizeUDim = UDim2.new(0, 16, 0, 14),
		stroke = false,
		bg = Colors.Background
	})
	v6.AnchorPoint = Vector2.new(1, 0.5)
	v6.Position = UDim2.new(1, -158, 0.5, 0)

	local function step(p5) -- 2 equivalent calls inferred from this helper
		send(p, p3, VOLUME_STEPS[math.clamp(indexOf(fn2(metro.cfg)) + p5, 1, #VOLUME_STEPS)]) -- inferred equivalent call
	end
	v6.Activated:Connect(function()
		step(-1) -- inferred equivalent call
	end)
	v3.Activated:Connect(function()
		step(1) -- inferred equivalent call
	end)

	metro.selectors[p3] = function(p5)
		local v7 = fn2(p5)
		v4.Text = fn(v7)
		v5:SetIndex(indexOf(v7)) -- inferred equivalent call
	end
end

local LaptopMetronomePanel = {}

function LaptopMetronomePanel:Build(parent)
	local metro = {
		cfg = MetronomeConfig.Default(),
		selectors = {},
		chips = {},
		taps = {},
		hints = {}
	}
	self.metro = metro

	local metronomePanel_Local = Instance.new("Frame")
	metronomePanel_Local.Name = "MetronomePanel_Local"
	metronomePanel_Local.BackgroundColor3 = Colors.Background
	metronomePanel_Local.BorderSizePixel = 0
	metronomePanel_Local.Position = UDim2.new(0, 0, 0, 0)
	metronomePanel_Local.Size = UDim2.new(1, 0, 1, 0)
	metronomePanel_Local.ZIndex = 15
	metronomePanel_Local.Active = true
	metronomePanel_Local.ClipsDescendants = true
	metronomePanel_Local.Visible = false
	metronomePanel_Local.Parent = parent
	Retro.AttachScreenFrame(metronomePanel_Local)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, 0, 1, 0)
	content.Parent = metronomePanel_Local
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 26)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = content

	Retro.AddTitle(content, "METRONOME", { size = 15, sizeUDim = UDim2.new(1, -38, 0, 25), z = 2 })
	metro.status = newLabel(content, "STOPPED", {
		font = Theme.Fonts.Label,
		size = 9,
		color = Colors.TextSecondary,
		xAlign = Enum.TextXAlignment.Right,
		sizeUDim = UDim2.new(0, 90, 0, 14)
	})

	metro.status.AnchorPoint = Vector2.new(1, 0)
	metro.status.Position = UDim2.new(1, -40, 0, 3)

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Colors.Surface
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(0, 0, 0, 27)
	frame.Size = UDim2.new(1, 0, 0, 38)
	frame.Parent = content
	addStroke(frame, Colors.Border, 0.4) -- inferred equivalent call

	local function bpmButton(text, p, p2)
		local v3 = newButton(frame, text, { sizeUDim = UDim2.new(0, 26, 0, 24) })
		v3.Position = UDim2.new(0, p, 0, 7)
		v3.Activated:Connect(function()
			send(self, "bpm", metro.cfg.bpm + p2) -- inferred equivalent call
		end)
		return v3
	end

	bpmButton("-5", 8, -5)
	bpmButton("-1", 38, -1)
	bpmButton("+1", 180, 1)
	bpmButton("+5", 210, 5)

	local bpmInput = Instance.new("TextBox")
	bpmInput.Name = "BpmInput"
	bpmInput.BackgroundColor3 = Colors.Background
	bpmInput.BorderSizePixel = 0
	bpmInput.Position = UDim2.new(0, 70, 0, 4)
	bpmInput.Size = UDim2.new(0, 106, 0, 30)
	bpmInput.Font = Theme.Fonts.Title
	bpmInput.TextSize = 22
	bpmInput.TextColor3 = Color3.fromRGB(255, 252, 240)
	bpmInput.PlaceholderText = "BPM"
	bpmInput.PlaceholderColor3 = Colors.TextSecondary
	bpmInput.Text = "100"
	bpmInput.ClearTextOnFocus = true
	bpmInput.TextXAlignment = Enum.TextXAlignment.Center
	bpmInput.Parent = frame
	local uiStroke2 = addStroke(bpmInput, Colors.BorderHover, 0.35) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Colors.Glow
	uiStroke.Transparency = 0.82
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uiStroke.Parent = bpmInput
	metro.bpmBox = bpmInput
	local newLabel_2 = newLabel(frame, "BPM", {
		font = Theme.Fonts.Label,
		size = 8,
		color = Colors.TextSecondary,
		xAlign = Enum.TextXAlignment.Right,
		sizeUDim = UDim2.new(0, 24, 0, 10)
	})
	newLabel_2.Position = UDim2.new(0, 148, 0, 22)

	bpmInput:GetPropertyChangedSignal("Text"):Connect(function()
		local text = bpmInput.Text:gsub("%D", ""):sub(1, 3)

		if text ~= bpmInput.Text then
			bpmInput.Text = text
		end
	end)
	bpmInput.Focused:Connect(function()
		uiStroke2.Color = Colors.Accent
		uiStroke2.Transparency = 0
	end)
	bpmInput.FocusLost:Connect(function()
		uiStroke2.Color = Colors.BorderHover
		uiStroke2.Transparency = 0.35
		local text = tonumber(bpmInput.Text)

		if text then
			send(self, "bpm", text) -- inferred equivalent call
		end

		refresh(metro)
	end)

	local v3 = newButton(frame, "TAP", {
		sizeUDim = UDim2.new(0, 62, 0, 24),
		bg = Colors.Accent,
		color = Colors.AccentText,
		stroke = false
	})

	v3.Position = UDim2.new(0, 242, 0, 7)
	v3.Activated:Connect(function()
		local now = os.clock()
		local taps = metro.taps

		if #taps > 0 and now - taps[#taps] > 2 then
			table.clear(taps)
		end

		table.insert(taps, now)

		while #taps > 5 do
			table.remove(taps, 1)
		end

		if #taps >= 2 then
			send(self, "bpm", 60 / ((taps[#taps] - taps[1]) / (#taps - 1))) -- inferred equivalent call
		end
	end)

	local v4 = 69
	addSelectorRow(self, content, v4, "sig", "Time signature", MetronomeConfig.SIGNATURES, function(p)
		return p
	end, function(p)
		return p.sig
	end)
	local v5 = v4 + 20
	addSelectorRow(self, content, v5, "snd", "Sound", MetronomeConfig.SOUND_ORDER, function(p)
		return (MetronomeConfig.SOUNDS[p] or MetronomeConfig.SOUNDS.click1).name
	end, function(p)
		return p.snd
	end)
	local v6 = v5 + 20
	addSliderRow(self, content, v6, "vol", "Volume", MetronomeConfig.VOLUME_STEPS, function(p)
		return tostring(p) .. "%"
	end, function(p)
		return p.vol
	end)
	local v7 = v6 + 20
	addSelectorRow(self, content, v7, "sub", "Subdivision", MetronomeConfig.SUBDIVISIONS, function(p)
		return MetronomeConfig.SUB_NAMES[p] or tostring(p)
	end, function(p)
		return p.sub
	end)
	local row, _ = makeRow(content, v7 + 20, "Count-in")

	local v8 = {}
	local total = 6

	for _, v9 in ipairs(MetronomeConfig.COUNT_IN_STEPS) do
		table.insert(v8, v9)
	end

	for i = #v8, 1, -1 do
		local v9 = v8[i]
		local v10 = v2[v9] or 40
		local v11 = newButton(row, string.upper(v[v9] or tostring(v9)), {
			size = 9,
			sizeUDim = UDim2.new(0, v10, 0, 14),
			stroke = false,
			bg = Colors.Background
		})

		v11.AnchorPoint = Vector2.new(1, 0.5)
		v11.Position = UDim2.new(1, -total, 0.5, 0)
		v11.Activated:Connect(function()
			send(self, "cin", v9) -- inferred equivalent call
		end)
		metro.chips[v9] = v11
		total += v10 + 3
	end

	local _, hints = Retro.AddHintBar(content, {
		{
			name = "start",
			text = "Start",
			alt = "Stop",
			variant = "primary",
			side = "left",
			onClick = function()
				send(self, "toggle", true) -- inferred equivalent call
			end
		},
		{ name = "exit", keycap = "Backspace", text = "Exit", side = "right" }
	}, { z = 2 })
	metro.hints = hints

	for _, guiObject in ipairs(metronomePanel_Local:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += 16
		end
	end

	refresh(metro)
	return metronomePanel_Local
end

function LaptopMetronomePanel.Enter(data)
	local metro = data.metro

	if not metro then
		return
	end

	local stage = data.stage
	local function fn()
		local vol = os.clock() - (metro.volAt or 0) < 0.6 and metro.cfg.vol or nil
		metro.cfg = MetronomeConfig.Decode(stage and stage:GetAttribute("MetronomeCfg"))

		if vol then
			metro.cfg.vol = vol
			task.delay(0.65, fn)
		end

		refresh(metro)
	end
	fn()
	table.clear(metro.taps)

	if stage then
		table.insert(data.connections, stage:GetAttributeChangedSignal("MetronomeCfg"):Connect(fn))
	end
end

function LaptopMetronomePanel:ReleaseFocus()
	local metro = self.metro

	if metro and metro.bpmBox and metro.bpmBox:IsFocused() then
		metro.bpmBox:ReleaseFocus()
	end
end

return LaptopMetronomePanel