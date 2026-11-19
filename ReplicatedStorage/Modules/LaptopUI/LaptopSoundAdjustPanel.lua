local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(script.Parent.Theme)
local Retro = require(script.Parent.Retro)
local SegmentedSlider = require(script.Parent.SegmentedSlider)
local SoundAdjustConfig = require(ReplicatedStorage.Modules:WaitForChild("SoundAdjustConfig"))

local soundAdjustSet = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SoundAdjustSet", 5)

local Colors = Theme.Colors

local v = {
	{ key = "vol", title = "Volume" },
	{ key = "bass", title = "Bass" },
	{ key = "rev", title = "Reverb" }
}

local function addStroke(frame, border, value) -- 1 equivalent call inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = border or Colors.Border
	uiStroke.Transparency = value or 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = frame
	return uiStroke
end

local function newLabel(parent, text, options)
	local v2 = options or {}
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = v2.font or Theme.Fonts.Regular
	textLabel.TextSize = v2.size or 11
	textLabel.TextColor3 = v2.color or Colors.TextPrimary
	textLabel.TextXAlignment = v2.xAlign or Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Text = text
	textLabel.Size = v2.sizeUDim or UDim2.new(1, 0, 1, 0)
	textLabel.Parent = parent
	return textLabel
end

local function newButton(parent, text, options)
	local v2 = options or {}
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = v2.bg or Colors.SurfaceHover
	textButton.BorderSizePixel = 0
	textButton.Font = v2.font or Theme.Fonts.Label
	textButton.TextSize = v2.size or 11
	textButton.TextColor3 = v2.color or Colors.TextPrimary
	textButton.Text = text
	textButton.Size = v2.sizeUDim or UDim2.new(0, 22, 0, 22)
	textButton.Parent = parent

	if v2.stroke == false then
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

	for _, v2 in ipairs(v) do
		local key = v2.key
		local row = data.rows[key]
		local v3 = cfg[key]
		row.valueLabel.Text = SoundAdjustConfig.Format(key, v3)

		row.slider:SetIndex(SoundAdjustConfig.ToIndex(key, v3))
	end

	if data.presetButtons then
		local matchPreset = SoundAdjustConfig.MatchPreset(cfg)

		for _, presetButton in ipairs(data.presetButtons) do
			local v2

			if matchPreset == nil then
				v2 = false
			else
				v2 = matchPreset.id == presetButton.id
			end

			presetButton.button.BackgroundColor3 = v2 and Colors.Accent or Colors.SurfaceHover
			presetButton.button.TextColor3 = v2 and Colors.Background or Colors.TextPrimary
		end
	end

	if SoundAdjustConfig.IsDefault(cfg) then
		data.status.Text = "DEFAULT"
		data.status.TextColor3 = Colors.TextSecondary
	else
		data.status.Text = "● CUSTOM"
		data.status.TextColor3 = Colors.Accent
	end
end

local function sendToServer(p, p2, p3)
	local sndAdj = p.sndAdj

	if not soundAdjustSet then
		return
	end

	local now = os.clock()
	local v2 = sndAdj.lastSent[p2] or 0

	if now - v2 >= 0.07 then
		sndAdj.lastSent[p2] = now
		sndAdj.pending[p2] = nil
		soundAdjustSet:FireServer(p.studioId, p2, p3)
	else
		sndAdj.pending[p2] = p3

		if sndAdj.flushing[p2] then
			return
		end

		sndAdj.flushing[p2] = true
		task.delay(0.07 - (now - v2), function()
			sndAdj.flushing[p2] = false
			local v3 = sndAdj.pending[p2]
			sndAdj.pending[p2] = nil

			if v3 ~= nil then
				sndAdj.lastSent[p2] = os.clock()
				soundAdjustSet:FireServer(p.studioId, p2, v3)
			end
		end)
	end
end

local function setValue(p, key, p2) -- 3 equivalent calls inferred from this helper
	local sndAdj = p.sndAdj

	if SoundAdjustConfig.Apply(sndAdj.cfg, key, p2) then
		sndAdj.lastLocal = os.clock()
		refresh(sndAdj)
		sendToServer(p, key, sndAdj.cfg[key])
	end
end

local function resetAll(p)
	local sndAdj = p.sndAdj
	sndAdj.cfg = SoundAdjustConfig.Default()
	sndAdj.lastLocal = os.clock()
	table.clear(sndAdj.pending)
	refresh(sndAdj)

	if soundAdjustSet then
		soundAdjustSet:FireServer(p.studioId, "reset", true)
	end
end

local function applyPreset(p, data)
	local sndAdj = p.sndAdj
	sndAdj.cfg = { vol = data.vol, bass = data.bass, rev = data.rev }
	sndAdj.lastLocal = os.clock()
	table.clear(sndAdj.pending)
	refresh(sndAdj)

	if soundAdjustSet then
		soundAdjustSet:FireServer(p.studioId, "preset", data.id)
	end
end

local function buildRow(p, content, total, p2)
	local sndAdj = p.sndAdj
	local key = p2.key
	local steps = SoundAdjustConfig.StepCount(key)

	local frame = Instance.new("Frame")
	frame.Name = "Row_" .. key
	frame.BackgroundColor3 = Colors.Surface
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(0, 0, 0, total)
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.Parent = content
	addStroke(frame, Colors.Border, 0.4) -- inferred equivalent call

	local newLabel_2 = newLabel(frame, string.upper(p2.title), {
		font = Theme.Fonts.Label,
		size = 10,
		sizeUDim = UDim2.new(0, 110, 0, 14)
	})
	newLabel_2.Position = UDim2.new(0, 8, 0, 2)

	local valueLabel = newLabel(frame, "", {
		font = Theme.Fonts.Label,
		size = 11,
		color = Colors.TextPrimary,
		xAlign = Enum.TextXAlignment.Right,
		sizeUDim = UDim2.new(0, 90, 0, 14)
	})

	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -8, 0, 2)

	local v2 = newButton(frame, "-", { sizeUDim = UDim2.new(0, 18, 0, 15), size = 13 })
	v2.Position = UDim2.new(0, 8, 0, 16)
	local v3 = newButton(frame, "+", { sizeUDim = UDim2.new(0, 18, 0, 15), size = 13 })
	v3.AnchorPoint = Vector2.new(1, 0)
	v3.Position = UDim2.new(1, -8, 0, 16)

	local new = SegmentedSlider.new
	local v4 = {
		steps = steps,
		position = UDim2.new(0, 31, 0, 16),
		size = UDim2.new(1, -62, 0, 15),
		fillFrom = 0,
		onSelect = 0
	}
	local fillFrom

	if key == "bass" then
		fillFrom = SoundAdjustConfig.ToIndex("bass", 0) or nil
	end

	v4.fillFrom = fillFrom
	function v4.onSelect(p3)
		setValue(p, key, SoundAdjustConfig.FromIndex(key, p3)) -- inferred equivalent call
	end

	local slider = new(frame, v4)

	v2.Activated:Connect(function()
		setValue(p, key, sndAdj.cfg[key] - SoundAdjustConfig.Step(key)) -- inferred equivalent call
	end)
	v3.Activated:Connect(function()
		setValue(p, key, sndAdj.cfg[key] + SoundAdjustConfig.Step(key)) -- inferred equivalent call
	end)

	sndAdj.rows[key] = { frame = frame, valueLabel = valueLabel, slider = slider }
end

local LaptopSoundAdjustPanel = {}

function LaptopSoundAdjustPanel:Build(parent)
	local sndAdj = {
		cfg = SoundAdjustConfig.Default(),
		rows = {},
		hints = {},
		lastSent = {},
		pending = {},
		flushing = {},
		lastLocal = 0
	}

	self.sndAdj = sndAdj

	local soundAdjustPanel_Local = Instance.new("Frame")
	soundAdjustPanel_Local.Name = "SoundAdjustPanel_Local"
	soundAdjustPanel_Local.BackgroundColor3 = Colors.Background
	soundAdjustPanel_Local.BorderSizePixel = 0
	soundAdjustPanel_Local.Position = UDim2.new(0, 0, 0, 0)
	soundAdjustPanel_Local.Size = UDim2.new(1, 0, 1, 0)
	soundAdjustPanel_Local.ZIndex = 15
	soundAdjustPanel_Local.Active = true
	soundAdjustPanel_Local.ClipsDescendants = true
	soundAdjustPanel_Local.Visible = false
	soundAdjustPanel_Local.Parent = parent
	Retro.AttachScreenFrame(soundAdjustPanel_Local)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, 0, 1, 0)
	content.Parent = soundAdjustPanel_Local
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 26)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = content

	Retro.AddTitle(content, "SOUND ADJUST", {
		size = 15,
		sizeUDim = UDim2.new(1, -38, 0, 25),
		z = 2
	})
	sndAdj.status = newLabel(content, "DEFAULT", {
		font = Theme.Fonts.Label,
		size = 9,
		color = Colors.TextSecondary,
		xAlign = Enum.TextXAlignment.Right,
		sizeUDim = UDim2.new(0, 90, 0, 14)
	})

	sndAdj.status.AnchorPoint = Vector2.new(1, 0)
	sndAdj.status.Position = UDim2.new(1, -40, 0, 3)
	local total = 30

	for _, v2 in ipairs(v) do
		buildRow(self, content, total, v2)
		total += 37
	end

	local presets = Instance.new("Frame")
	presets.Name = "Presets"
	presets.BackgroundTransparency = 1
	presets.Position = UDim2.new(0, 0, 0, total)
	presets.Size = UDim2.new(1, 0, 0, 20)
	presets.Parent = content
	sndAdj.presetButtons = {}
	local count = #SoundAdjustConfig.PRESETS

	for i, v2 in ipairs(SoundAdjustConfig.PRESETS) do
		local button = newButton(presets, v2.name, {
			font = Theme.Fonts.Label,
			size = 10,
			sizeUDim = UDim2.new(1 / count, i == count and 0 or -4, 1, 0)
		})

		button.Position = UDim2.new((i - 1) / count, 0, 0, 0)
		button.Activated:Connect(function()
			applyPreset(self, v2)
		end)
		sndAdj.presetButtons[i] = { id = v2.id, button = button }
	end

	local v2 = total + 22

	local newLabel_2 = newLabel(content, "Applies to all stems on this stage. Resets when the stage is empty.", {
		font = Theme.Fonts.Regular,
		size = 8,
		color = Colors.TextSecondary,
		sizeUDim = UDim2.new(1, 0, 0, 10)
	})

	newLabel_2.Position = UDim2.new(0, 2, 0, v2)

	local _, hints = Retro.AddHintBar(content, {
		{
			name = "reset",
			text = "Reset",
			variant = "primary",
			side = "left",
			onClick = function()
				resetAll(self)
			end
		},
		{ name = "exit", keycap = "Backspace", text = "Exit", side = "right" }
	}, { z = 2 })
	sndAdj.hints = hints

	for _, guiObject in ipairs(soundAdjustPanel_Local:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += 16
		end
	end

	refresh(sndAdj)
	return soundAdjustPanel_Local
end

function LaptopSoundAdjustPanel.Enter(data)
	local sndAdj = data.sndAdj

	if not sndAdj then
		return
	end

	local stage = data.stage
	local function pull()
		if os.clock() - sndAdj.lastLocal < 0.5 then
			task.delay(0.5, function()
				if data.sndAdj == sndAdj and os.clock() - sndAdj.lastLocal >= 0.5 then
					sndAdj.cfg = SoundAdjustConfig.Decode(stage and stage:GetAttribute(SoundAdjustConfig.ATTR))
					refresh(sndAdj)
				end
			end)
			return
		end

		sndAdj.cfg = SoundAdjustConfig.Decode(stage and stage:GetAttribute(SoundAdjustConfig.ATTR))
		refresh(sndAdj)
	end
	sndAdj.cfg = SoundAdjustConfig.Decode(stage and stage:GetAttribute(SoundAdjustConfig.ATTR))
	refresh(sndAdj)

	if stage then
		table.insert(data.connections, stage:GetAttributeChangedSignal(SoundAdjustConfig.ATTR):Connect(pull))
	end
end

function LaptopSoundAdjustPanel.ReleaseFocus(_) end

return LaptopSoundAdjustPanel