local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)
local Retro = require(script.Parent.Retro)
local ToggleSwitch = require(script.Parent.ToggleSwitch)
local SegmentedSlider = require(script.Parent.SegmentedSlider)
local LaptopClientController = require(script.Parent.LaptopClientController)
local StageLightConfig = require(ReplicatedStorage.Modules:WaitForChild("StageLightConfig"))
local stageLightSet = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StageLightSet")

local success, result = pcall(function()
	return require(script.Parent:WaitForChild("LaptopMetronomePanel", 10))
end)

if not success then
	warn("[LaptopStageLightPanel] Tab Metronome dinonaktifkan:", result)
	result = nil
end

local success2, result2 = pcall(function()
	return require(script.Parent:WaitForChild("LaptopSoundAdjustPanel", 10))
end)

if not success2 then
	warn("[LaptopStageLightPanel] Tab Sound dinonaktifkan:", result2)
	result2 = nil
end

local success3, result3 = pcall(function()
	return require(script.Parent:WaitForChild("LaptopStudioPanel", 10))
end)

if not success3 then
	warn("[LaptopStageLightPanel] Tab Studio dinonaktifkan:", result3)
	result3 = nil
end

local LaptopStageLightPanel = {}

local v = {}
local entries = {}
local v2 = nil

local v3 = { Song = "Song default" }
local v4 = { Beat = "Follow Beat", Static = "Static color", Breathe = "Breathe" }
local v5 = { all = "All", kick = "Kick", par1 = "Par1", ayrton = "Ayrton" }

function LaptopStageLightPanel.RegisterLaptop(p, p2)
	v[p] = p2
end

local function resolveGui(instance) -- 1 equivalent call inferred from this helper
	local guiAnchor = instance and instance:FindFirstChild("GuiAnchor")
	return guiAnchor and guiAnchor:FindFirstChild("LaptopScreen")
end

local function findStage(p)
	local map = Workspace:FindFirstChild("Map")

	if not map then
		return nil
	end

	for _, child in ipairs(map:GetChildren()) do
		if child:GetAttribute("StudioId") == p then
			return child
		end
	end

	return nil
end

local function corner(parent, p) -- 10 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = p or Theme.Radius.Small
	uiCorner.Parent = parent
	return uiCorner
end

local function newLabel(parent, text, options)
	local v6 = options or {}
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = v6.font or Theme.Fonts.Regular
	textLabel.TextSize = v6.size or Theme.TextSize.S
	textLabel.TextColor3 = v6.color or Theme.Colors.TextPrimary
	textLabel.TextXAlignment = v6.xAlign or Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Text = text
	textLabel.Size = v6.sizeUDim or UDim2.new(1, 0, 1, 0)
	textLabel.Parent = parent
	return textLabel
end

local function newButton(frame, text, options)
	local v6 = options or {}
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = v6.bg or Theme.Colors.Surface
	textButton.BorderSizePixel = 0
	textButton.Font = v6.font or Theme.Fonts.Medium
	textButton.TextSize = v6.size or Theme.TextSize.S
	textButton.TextColor3 = v6.color or Theme.Colors.TextPrimary
	textButton.Text = text
	textButton.Size = v6.sizeUDim or UDim2.new(0, 20, 0, 20)
	textButton.Parent = frame
	corner(textButton, v6.radius or Theme.Radius.Small) -- inferred equivalent call
	return textButton
end

local function refresh(data)
	local cfg = data.cfg

	for k, toggle in pairs(data.toggles) do
		local v6

		if k:sub(1, 6) == "group:" then
			v6 = cfg.groups[k:sub(7)]
		else
			v6 = cfg[k]
		end

		toggle:SetState(v6 == true, true)
	end

	for _, selector in pairs(data.selectors) do
		selector(cfg)
	end

	for k, swatch in pairs(data.swatches) do
		local color = cfg.colors[k]
		swatch.auto.BackgroundColor3 = color == nil and Theme.Colors.Accent or Theme.Colors.Surface
		swatch.auto.TextColor3 = color == nil and Theme.Colors.AccentText or Theme.Colors.TextSecondary

		for _, chip in ipairs(swatch.chips) do
			local v6 = color ~= nil and color[1] == chip.rgb[1] and color[2] == chip.rgb[2] and color[3] == chip.rgb[3]
			chip.stroke.Thickness = v6 and 2 or 0
		end
	end
end

local function send(p, p2, p3) -- 6 equivalent calls inferred from this helper
	StageLightConfig.Apply(p.cfg, p2, p3)
	refresh(p)
	stageLightSet:FireServer(p.studioId, p2, p3)
end

local function newRow(parent, layoutOrder) -- 4 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, -4, 0, 22)
	frame.LayoutOrder = layoutOrder
	frame.Parent = parent
	return frame
end

local function newSection(scrollingFrame, layoutOrder, text)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, -4, 0, 16)
	frame.LayoutOrder = layoutOrder
	frame.Parent = scrollingFrame
	newLabel(frame, text, {
		font = Theme.Fonts.Medium,
		size = Theme.TextSize.XS,
		color = Theme.Colors.Accent
	})
	return frame
end

local function addToggle(p, scrollingFrame, layoutOrder, p2, text)
	local parent = newRow(scrollingFrame, layoutOrder) -- inferred equivalent call
	newLabel(parent, text, { sizeUDim = UDim2.new(1, -52, 1, 0) })
	local v6 = ToggleSwitch.new(parent, { initial = false })
	v6.Instance.AnchorPoint = Vector2.new(1, 0.5)
	v6.Instance.Position = UDim2.new(1, 0, 0.5, 0)
	v6.Toggled:Connect(function(p3)
		send(p, p2, p3) -- inferred equivalent call
	end)
	p.toggles[p2] = v6
end

local function addSelector(p, scrollingFrame, layoutOrder, p2, text, list, fn, fn2)
	local parent = newRow(scrollingFrame, layoutOrder) -- inferred equivalent call
	newLabel(parent, text, { sizeUDim = UDim2.new(1, -132, 1, 0) })
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(1, 0.5)
	frame.Position = UDim2.new(1, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 128, 0, 20)
	frame.Parent = parent

	local parent2 = newButton(frame, "<", { sizeUDim = UDim2.new(0, 20, 1, 0) })
	local parent3 = newButton(frame, ">", { sizeUDim = UDim2.new(0, 20, 1, 0) })
	parent3.AnchorPoint = Vector2.new(1, 0)
	parent3.Position = UDim2.new(1, 0, 0, 0)
	local v6 = newLabel(frame, "", {
		xAlign = Enum.TextXAlignment.Center,
		color = Theme.Colors.TextPrimary,
		sizeUDim = UDim2.new(1, -48, 1, 0)
	})

	v6.Position = UDim2.new(0, 24, 0, 0)

	local function step(p3)
		local v7 = fn2(p.cfg)
		local v8 = 1

		for i, item in ipairs(list) do
			if item == v7 then
				v8 = i
				break
			end
		end

		send(p, p2, list[(v8 - 1 + p3) % #list + 1]) -- inferred equivalent call
	end
	parent2.Activated:Connect(function()
		step(-1)
	end)
	parent3.Activated:Connect(function()
		step(1)
	end)
	p.selectors[p2] = function(p3)
		v6.Text = fn((fn2(p3)))
	end
end

local function addSliderSelector(state, scrollingFrame, layoutOrder, p, text, BRIGHTNESS_STEPS, fn, fn2)
	local parent = newRow(scrollingFrame, layoutOrder) -- inferred equivalent call
	newLabel(parent, text, { sizeUDim = UDim2.new(1, -176, 1, 0) })
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(1, 0.5)
	frame.Position = UDim2.new(1, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 172, 0, 20)
	frame.Parent = parent

	local function indexOf(p2) -- 2 equivalent calls inferred from this helper
		for i, item in ipairs(BRIGHTNESS_STEPS) do
			if item == p2 then
				return i
			end
		end

		return 1
	end

	local function sendSlider(p2)
		StageLightConfig.Apply(state.cfg, p, p2)
		state.sliderAt = os.clock()
		refresh(state)

		if not state.sendSlider then
			state.sendSlider = SegmentedSlider.Throttle(function(p3, p4)
				stageLightSet:FireServer(state.studioId, p3, p4)
			end, 0.12)
		end

		state.sendSlider(p, p2)
	end

	local parent2 = newButton(frame, "-", { sizeUDim = UDim2.new(0, 18, 1, 0) })
	local parent3 = newButton(frame, "+", { sizeUDim = UDim2.new(0, 18, 1, 0) })
	parent3.AnchorPoint = Vector2.new(1, 0)
	parent3.Position = UDim2.new(1, 0, 0, 0)

	local v6 = SegmentedSlider.new(frame, {
		steps = #BRIGHTNESS_STEPS,
		size = UDim2.new(0, 88, 0, 14),
		anchorPoint = Vector2.new(0, 0.5),
		position = UDim2.new(0, 22, 0.5, 0),
		onSelect = function(p2)
			sendSlider(BRIGHTNESS_STEPS[p2])
		end
	})

	local v7 = newLabel(frame, "", {
		xAlign = Enum.TextXAlignment.Center,
		color = Theme.Colors.TextPrimary,
		sizeUDim = UDim2.new(0, 34, 1, 0)
	})

	v7.AnchorPoint = Vector2.new(1, 0)
	v7.Position = UDim2.new(1, -22, 0, 0)

	local function step(p2) -- 2 equivalent calls inferred from this helper
		sendSlider(BRIGHTNESS_STEPS[math.clamp(indexOf(fn2(state.cfg)) + p2, 1, #BRIGHTNESS_STEPS)]) -- inferred equivalent call
	end
	parent2.Activated:Connect(function()
		step(-1) -- inferred equivalent call
	end)
	parent3.Activated:Connect(function()
		step(1) -- inferred equivalent call
	end)

	state.selectors[p] = function(p2)
		local v8 = fn2(p2)
		v7.Text = fn(v8)
		v6:SetIndex(indexOf(v8)) -- inferred equivalent call
	end
end

local function addSwatchRow(p, scrollingFrame, layoutOrder, p2)
	local parent = newRow(scrollingFrame, layoutOrder) -- inferred equivalent call
	newLabel(parent, v5[p2], { sizeUDim = UDim2.new(0, 46, 1, 0) })
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(1, 0.5)
	frame.Position = UDim2.new(1, 0, 0.5, 0)
	frame.Size = UDim2.new(1, -48, 0, 18)
	frame.Parent = parent
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, 2)
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = frame

	local auto = newButton(frame, "Auto", {
		size = Theme.TextSize.XS,
		font = Theme.Fonts.Medium,
		sizeUDim = UDim2.new(0, 30, 0, 16),
		color = Theme.Colors.TextSecondary
	})

	auto.LayoutOrder = 0
	auto.Activated:Connect(function()
		send(p, "color:" .. p2, false) -- inferred equivalent call
	end)

	local chips = {}

	for i, swatch in ipairs(StageLightConfig.SWATCHES) do
		local textButton = Instance.new("TextButton")
		textButton.AutoButtonColor = false
		textButton.Text = ""
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Color3.fromRGB(swatch[2], swatch[3], swatch[4])
		textButton.Size = UDim2.new(0, 16, 0, 16)
		textButton.LayoutOrder = i
		textButton.Parent = frame
		corner(textButton, Theme.Radius.Small) -- inferred equivalent call
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.fromRGB(255, 255, 255)
		uiStroke.Thickness = 0
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = textButton
		local rgb = { swatch[2], swatch[3], swatch[4] }
		textButton.Activated:Connect(function()
			send(p, "color:" .. p2, rgb) -- inferred equivalent call
		end)
		chips[#chips + 1] = { rgb = rgb, stroke = uiStroke }
	end

	p.swatches[p2] = { auto = auto, chips = chips }
end

local color = Color3.fromRGB(60, 230, 110)
local color2 = Color3.fromRGB(240, 60, 70)
local color3 = Color3.fromRGB(58, 58, 66)
local v6 = {
	kick = Color3.fromRGB(255, 255, 255),
	par1 = Color3.fromRGB(88, 127, 255),
	ayr = Color3.fromRGB(88, 127, 255)
}

local v7 = { 0, 3, 4, 8, 10, 12 }
local v8 = { kick = "KICK", par1 = "PAR1", ayrton = "AYRTON" }

local v9 = nil
local function getSLC()
	if v9 == nil then
		local success4, result4 = pcall(function()
			return require(ReplicatedStorage.Modules:WaitForChild("StageLightingController", 5))
		end)

		v9 = success4 and result4 or false
	end

	return v9 or nil
end

local function previewProfile(p)
	if v9 == nil then
		local success4, result4 = pcall(function()
			return require(ReplicatedStorage.Modules:WaitForChild("StageLightingController", 5))
		end)

		v9 = success4 and result4 or false
	end

	local v10 = v9 or nil

	if not v10 then
		return nil
	end

	local style = p.cfg.style

	if style ~= "Song" then
		return v10.GetProfile(style)
	end

	local lightSong = p.stage and p.stage:GetAttribute("LightSong")
	return v10.GetProfileForSong(lightSong)
end

local function circle(parent, p, zIndex)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.fromOffset(p, p)
	frame.ZIndex = zIndex
	frame.Parent = parent
	corner(frame, UDim.new(0, 3)) -- inferred equivalent call
	return frame
end

local function newPreviewLamp(preview, kind, p, beamW, zone)
	local previewLamp = {
		kind = kind,
		x = p,
		zone = zone,
		flash = 0,
		flashColor = v6[kind],
		decay = 8,
		sway = 0,
		swayTarget = 0
	}
	local v10 = kind ~= "ayr"
	previewLamp.beam = Instance.new("Frame")
	previewLamp.beam.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	previewLamp.beam.BackgroundTransparency = 1
	previewLamp.beam.BorderSizePixel = 0
	previewLamp.beam.AnchorPoint = Vector2.new(0.5, 0)
	previewLamp.beam.Position = UDim2.fromOffset(p, 19)
	previewLamp.beam.Size = UDim2.fromOffset(beamW, 36)
	previewLamp.beam.ZIndex = 2
	previewLamp.beam.Parent = preview
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	uiGradient.Parent = previewLamp.beam

	previewLamp.pool = Instance.new("Frame")
	previewLamp.pool.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	previewLamp.pool.BackgroundTransparency = 1
	previewLamp.pool.BorderSizePixel = 0
	previewLamp.pool.AnchorPoint = Vector2.new(0.5, 0.5)
	previewLamp.pool.Position = UDim2.fromOffset(p, 54)
	previewLamp.pool.Size = UDim2.fromOffset(beamW * 1.9, 6)
	previewLamp.pool.ZIndex = 2
	previewLamp.pool.Parent = preview
	corner(previewLamp.pool, UDim.new(0, 3)) -- inferred equivalent call

	previewLamp.glows = {}

	for i, v11 in ipairs(v10 and { 18, 28, 40 } or { 8, 12, 16 }) do
		local parent = circle(preview, v11, 3)
		parent.Position = UDim2.fromOffset(p, 16)
		previewLamp.glows[i] = parent
	end

	previewLamp.body = Instance.new("Frame")
	previewLamp.body.BackgroundColor3 = color3
	previewLamp.body.BorderSizePixel = 0
	previewLamp.body.AnchorPoint = Vector2.new(0.5, 0)
	previewLamp.body.Position = UDim2.fromOffset(p, 14)
	previewLamp.body.Size = v10 and UDim2.fromOffset(10, 5) or UDim2.fromOffset(4, 4)
	previewLamp.body.ZIndex = 4
	previewLamp.body.Parent = preview
	corner(previewLamp.body, UDim.new(0, 2)) -- inferred equivalent call
	previewLamp.beamW = beamW
	return previewLamp
end

local function paintLamp(data, backgroundColor, value)
	value = math.clamp(value, 0, 1)
	data.beam.BackgroundColor3 = backgroundColor
	data.beam.BackgroundTransparency = 1 - value * 0.85
	data.pool.BackgroundColor3 = backgroundColor
	data.pool.BackgroundTransparency = 1 - value * 0.55
	local v10 = { 0.3, 0.15, 0.07 }

	for i, glow in ipairs(data.glows) do
		glow.BackgroundColor3 = backgroundColor
		glow.BackgroundTransparency = 1 - value * v10[i]
	end

	data.body.BackgroundColor3 = color3:Lerp(backgroundColor, value)

	local rotation = data.sway * 16
	data.beam.Rotation = rotation
	data.pool.Position = UDim2.fromOffset(data.x + math.sin((math.rad(rotation))) * 36, 54)
end

local function newEspBox(p, preview, group, p2, p3)
	local textButton = Instance.new("TextButton")
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = color2
	textButton.BackgroundTransparency = 1
	textButton.BorderSizePixel = 0
	textButton.Position = UDim2.fromOffset(p2, 2)
	textButton.Size = UDim2.fromOffset(p3 - p2, 24)
	textButton.ZIndex = 6
	textButton.Parent = preview
	corner(textButton, UDim.new(0, 3)) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = 1
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = textButton
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Theme.Fonts.Medium
	textLabel.TextSize = 9
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Position = UDim2.fromOffset(3, 1)
	textLabel.Size = UDim2.new(1, -4, 0, 10)
	textLabel.ZIndex = 7
	textLabel.Text = v8[group]
	textLabel.TextColor3 = color
	textLabel.Parent = textButton
	textButton.Activated:Connect(function()
		send(p, "group:" .. group, not p.cfg.groups[group]) -- inferred equivalent call
	end)
	return { btn = textButton, stroke = uiStroke, label = textLabel, group = group }
end

local function buildPreview(p, stageLightPanel_Local)
	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.BackgroundColor3 = Color3.fromRGB(9, 9, 13)
	preview.BorderSizePixel = 0
	preview.Position = UDim2.new(0, 0, 0, 26)
	preview.Size = UDim2.new(1, 0, 0, 66)
	preview.ClipsDescendants = true
	preview.Parent = stageLightPanel_Local
	corner(preview, Theme.Radius.Medium) -- inferred equivalent call

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	frame.BorderSizePixel = 0
	frame.Position = UDim2.fromOffset(0, 11)
	frame.Size = UDim2.new(1, 0, 0, 2)
	frame.ZIndex = 1
	frame.Parent = preview
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromOffset(0, 55)
	frame2.Size = UDim2.new(1, 0, 1, -55)
	frame2.ZIndex = 1
	frame2.Parent = preview

	local preview2 = {
		frame = preview,
		lamps = { kick = {}, par1 = {}, ayr = {} },
		boxes = {},
		t = 0,
		step = -1,
		seed = 7,
		flip = false,
		p1flip = false
	}

	preview2.lamps.kick[1] = newPreviewLamp(preview, "kick", 30, 18, nil)
	preview2.lamps.kick[2] = newPreviewLamp(preview, "kick", 284, 18, nil)
	preview2.lamps.par1[1] = newPreviewLamp(preview, "par1", 76, 14, nil)
	preview2.lamps.par1[2] = newPreviewLamp(preview, "par1", 238, 14, nil)
	local v10 = { 3, 3, 4, 3, 3 }
	local count = 0

	for i = 1, 5 do
		for _ = 1, v10[i] do
			count += 1
			local v11 = newPreviewLamp(preview, "ayr", (count - 1) * 6 + 112, 6, i)
			v11.index = count
			preview2.lamps.ayr[count] = v11
		end
	end

	preview2.boxes[#preview2.boxes + 1] = newEspBox(p, preview, "kick", 14, 46)
	preview2.boxes[#preview2.boxes + 1] = newEspBox(p, preview, "kick", 268, 300)
	preview2.boxes[#preview2.boxes + 1] = newEspBox(p, preview, "par1", 60, 92)
	preview2.boxes[#preview2.boxes + 1] = newEspBox(p, preview, "par1", 222, 254)
	preview2.boxes[#preview2.boxes + 1] = newEspBox(p, preview, "ayrton", 106, 208)

	preview2.info = Instance.new("TextLabel")
	preview2.info.BackgroundTransparency = 1
	preview2.info.Font = Theme.Fonts.Medium
	preview2.info.TextSize = 9
	preview2.info.TextColor3 = Color3.fromRGB(150, 150, 165)
	preview2.info.TextXAlignment = Enum.TextXAlignment.Right
	preview2.info.AnchorPoint = Vector2.new(1, 1)
	preview2.info.Position = UDim2.new(1, -6, 1, -2)
	preview2.info.Size = UDim2.new(0.7, 0, 0, 10)
	preview2.info.ZIndex = 8
	preview2.info.Text = ""
	preview2.info.Parent = preview

	preview2.offLabel = Instance.new("TextLabel")
	preview2.offLabel.BackgroundTransparency = 1
	preview2.offLabel.Font = Theme.Fonts.Medium
	preview2.offLabel.TextSize = 10
	preview2.offLabel.TextColor3 = color2
	preview2.offLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	preview2.offLabel.Position = UDim2.new(0.5, 0, 0, 38)
	preview2.offLabel.Size = UDim2.new(1, 0, 0, 12)
	preview2.offLabel.ZIndex = 8
	preview2.offLabel.Text = "STAGE LIGHTS OFF - normal house lights"
	preview2.offLabel.Visible = false
	preview2.offLabel.Parent = preview
	return preview2
end

local function pvRand(state) -- 2 equivalent calls inferred from this helper
	state.seed = (state.seed * 1103515245 + 12345) % 2147483648
	return state.seed / 2147483648
end

local function pvTrigger(p, flashColor, flash, decay) -- 5 equivalent calls inferred from this helper
	p.flashColor = flashColor

	if p.flash < flash then
		p.flash = flash
	end

	p.decay = decay
	p.sm = nil
end

local function pvTriggerSmooth(p, kickColor, peak, rise, fall)
	local flash = p.flash
	p.flashColor = kickColor

	if peak <= flash * 1.02 then
		p.sm = {
			from = flash,
			peak = flash,
			t = rise,
			rise = rise,
			fall = fall
		}
	else
		p.sm = {
			from = flash,
			peak = peak,
			t = 0,
			rise = rise,
			fall = fall
		}
	end
end

local function pvFireStep(pv, step, _, data)
	local v10 = step % 16

	for i, v11 in ipairs(v7) do
		if v11 ~= v10 then
			continue
		end

		local fall = math.clamp(((v7[i + 1] or v7[1] + 16) - v11) * 0.25, data.kickFallMin, data.kickFallMax)
		local rise = math.min(data.kickRise, fall * 0.4)
		pv.flip = not pv.flip
		local v12 = pv.lamps.kick[pv.flip and 1 or 2]
		local v13 = pv.lamps.kick[pv.flip and 2 or 1]
		pvTriggerSmooth(v12, data.kickColor, data.kickPeak, rise, fall)

		if v13.flash < data.kickOther then
			pvTriggerSmooth(v13, data.kickColor, data.kickOther, rise, fall)
		end

		v12.swayTarget = (pvRand(pv) < 0.7 and -1 or 1) * (0.25 + 0.75 * pvRand(pv)) * (v12.x < 157 and 1 or -1) -- inferred equivalent call
	end

	local guitarLead = data.par1.GuitarLead

	if v10 % 2 == 0 or v10 % 7 == 3 then
		local v11 = v10 * 3 % 5 + 1
		local color4 = guitarLead.colors[v11]
		pv.p1flip = not pv.p1flip

		if guitarLead.mode == "alt" then
			pvTrigger(pv.lamps.par1[pv.p1flip and 1 or 2], color4, guitarLead.peak, guitarLead.decay) -- inferred equivalent call
			local v12 = pv.lamps.par1[pv.p1flip and 2 or 1]

			if v12.flash < 0.3 then
				pvTrigger(v12, color4, 0.28, guitarLead.decay * 0.8) -- inferred equivalent call
			end
		else
			pvTrigger(pv.lamps.par1[1], color4, guitarLead.peak, guitarLead.decay) -- inferred equivalent call
			pvTrigger(pv.lamps.par1[2], color4, guitarLead.peak * 0.95, guitarLead.decay) -- inferred equivalent call
		end
	end

	if v10 % 4 ~= 0 then
		local v11 = v10 * 2 % 5 + 1
		local count = 0

		for _, v12 in ipairs(pv.lamps.ayr) do
			if v12.zone ~= v11 then
				continue
			end

			count += 1
			pvTrigger(v12, data.zone[v11], data.ayrPeak, data.ayrDecay + count * data.ayrStep) -- inferred equivalent call
		end
	end
end

local function updatePreview(entry, p)
	local pv = entry.pv
	local cfg = entry.cfg

	if v9 == nil then
		local success4, result4 = pcall(function()
			return require(ReplicatedStorage.Modules:WaitForChild("StageLightingController", 5))
		end)

		v9 = success4 and result4 or false
	end

	local v10 = v9 or nil
	local v11

	if v10 then
		local style = entry.cfg.style

		if style == "Song" then
			local lightSong = entry.stage and entry.stage:GetAttribute("LightSong")
			v11 = v10.GetProfileForSong(lightSong)
		else
			v11 = v10.GetProfile(style)
		end
	else
		v11 = nil
	end

	if not (pv and v11) then
		return
	end

	pv.t += p
	local v12 = math.floor(pv.t / 0.25)

	if pv.step < 0 then
		pv.step = v12 - 1
	end

	local count = 0

	while pv.step < v12 and count < 8 do
		pv.step += 1
		count += 1

		if cfg.show and cfg.mode == "Beat" then
			pvFireStep(pv, pv.step, cfg, v11)
		end
	end

	local v13 = cfg.brightness / 100
	local t = pv.t

	local function output(data, p2)
		if not cfg.show then
			return v6[data.kind], 0.7
		end

		if not cfg.groups[p2] then
			return color3, 0
		end

		local v14 = cfg.colors[p2] or cfg.colors.all
		local color4 = v14 and Color3.fromRGB(v14[1], v14[2], v14[3]) or nil
		local v15, v16

		if cfg.mode == "Static" then
			v15 = color4 or v11.soloColor
			v16 = 0.9
		elseif cfg.mode == "Breathe" then
			local v17 = data.kind == "ayr" and (data.index or 0) * 0.35 or data.x > 157 and 3.141592653589793 or 0
			v15 = color4 or v11.soloColor
			v16 = (math.sin(t * 1.1 + v17) * 0.5 + 0.5) * 0.6 + 0.3
		else
			local flash = data.flash
			local kickFloor = data.kind == "kick" and v11.kickFloor or data.kind == "par1" and v11.ember or 0
			v15 = kickFloor < flash and data.flashColor or data.kind == "kick" and v11.kickColor or v6[data.kind]
			v16 = math.max(flash, kickFloor)

			if color4 then
				v15 = color4
			end
		end

		return v15, v16 * v13
	end

	local v14 = 1 - math.exp(-p * v11.swaySpeed)

	for _, v15 in ipairs({ "kick", "par1", "ayr" }) do
		local v16 = v15 == "ayr" and "ayrton" or v15

		for _, v17 in ipairs(pv.lamps[v15]) do
			if v17.sm then
				local sm = v17.sm
				sm.t += p
				local flash

				if sm.t < sm.rise then
					local v18 = sm.t / sm.rise
					flash = sm.from + (sm.peak - sm.from) * (1 - (1 - v18) ^ 3)
				else
					local v18 = math.min(1, (sm.t - sm.rise) / sm.fall)
					local v19 = math.min(v11.kickFloor, sm.peak)
					flash = v19 + (sm.peak - v19) * (math.cos(3.141592653589793 * v18) * 0.5 + 0.5)

					if v18 >= 1 then
						v17.sm = nil
						flash = 0
					end
				end

				v17.flash = flash
			else
				v17.flash *= math.exp(-v17.decay * p)

				if v17.flash < 0.01 then
					v17.flash = 0
				end
			end

			if v17.kind == "kick" then
				local swayTarget = cfg.sway and cfg.show and cfg.mode == "Beat" and v17.swayTarget or 0
				v17.sway += (swayTarget - v17.sway) * v14
			end

			local backgroundColor, v18 = output(v17, v16)
			paintLamp(v17, backgroundColor, v18)
		end
	end

	for _, box in ipairs(pv.boxes) do
		local group = cfg.groups[box.group]
		local v15 = group and color or color2
		box.stroke.Color = v15
		box.stroke.Thickness = group and 1 or 1.5
		box.label.TextColor3 = v15
		box.label.Text = group and v8[box.group] or v8[box.group] .. " OFF"
		box.btn.BackgroundTransparency = group and 1 or 0.78
	end

	pv.offLabel.Visible = not cfg.show
	local v15 = cfg.style == "Song" and "Song:" .. v11.name or cfg.style
	pv.info.Text = string.format("%s  |  %s  |  %d%%", cfg.mode, v15, cfg.brightness)
end

local v10 = nil
local v11 = nil

local v12 = {}

local function refreshViewButtons()
	local viewAngle = v11 and v11.viewAngle or "front"

	for k, v13 in pairs(v12) do
		local v14 = k == viewAngle
		v13.BackgroundColor3 = v14 and Color3.fromRGB(52, 52, 60) or Color3.fromRGB(22, 22, 26)
		v13.TextColor3 = v14 and Theme.Colors.TextPrimary or Theme.Colors.TextSecondary
	end
end

local function ensureViewUI()
	if v10 and v10.Parent then
		return v10
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return nil
	end

	local stageLightViewUI = Instance.new("ScreenGui")
	stageLightViewUI.Name = "StageLightViewUI"
	stageLightViewUI.ResetOnSpawn = false
	stageLightViewUI.DisplayOrder = 50
	stageLightViewUI.IgnoreGuiInset = true
	stageLightViewUI.Enabled = false
	stageLightViewUI.Parent = localPlayer:WaitForChild("PlayerGui")

	local box = Instance.new("Frame")
	box.Name = "Box"
	box.AnchorPoint = Vector2.new(0.5, 1)
	box.Position = UDim2.new(0.5, 0, 1, -20)
	box.Size = UDim2.fromOffset(168, 58)
	box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	box.BackgroundTransparency = 0.1
	box.BorderSizePixel = 0
	box.Parent = stageLightViewUI
	corner(box, UDim.new(0, 6)) -- inferred equivalent call

	local backButton = Instance.new("TextButton")
	backButton.Name = "BackButton"
	backButton.BackgroundTransparency = 1
	backButton.AutoButtonColor = false
	backButton.Position = UDim2.fromOffset(0, 3)
	backButton.Size = UDim2.new(1, 0, 0, 22)
	backButton.Font = Theme.Fonts.Medium
	backButton.TextSize = 13
	backButton.TextColor3 = Theme.Colors.TextPrimary
	backButton.Text = "Back to Laptop"
	backButton.Parent = box
	backButton.MouseEnter:Connect(function()
		backButton.TextColor3 = Theme.Colors.Accent
	end)
	backButton.MouseLeave:Connect(function()
		backButton.TextColor3 = Theme.Colors.TextPrimary
	end)
	backButton.Activated:Connect(function()
		if v11 then
			LaptopStageLightPanel._exitView(v11, false)
		end
	end)

	local angles = Instance.new("Frame")
	angles.Name = "Angles"
	angles.BackgroundTransparency = 1
	angles.Position = UDim2.fromOffset(8, 30)
	angles.Size = UDim2.new(1, -16, 0, 20)
	angles.Parent = box
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = angles

	for i, v13 in ipairs({
		{ "left", "Left" },
		{ "front", "Front" },
		{ "right", "Right" }
	}) do
		local textButton = Instance.new("TextButton")
		textButton.Name = v13[2]
		textButton.LayoutOrder = i
		textButton.AutoButtonColor = false
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		textButton.Size = UDim2.new(1 / 3, -3, 1, 0)
		textButton.Font = Theme.Fonts.Medium
		textButton.TextSize = 11
		textButton.TextColor3 = Theme.Colors.TextSecondary
		textButton.Text = v13[2]
		textButton.Parent = angles
		corner(textButton, UDim.new(0, 4)) -- inferred equivalent call
		v12[v13[1]] = textButton
		textButton.Activated:Connect(function()
			if v11 then
				LaptopStageLightPanel._setViewAngle(v11, v13[1])
			end
		end)
	end

	local hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.BackgroundTransparency = 1
	hint.AnchorPoint = Vector2.new(0.5, 1)
	hint.Position = UDim2.new(0.5, 0, 0, -2)
	hint.Size = UDim2.new(1, 0, 0, 12)
	hint.Font = Theme.Fonts.Regular
	hint.TextSize = 10
	hint.TextColor3 = Color3.fromRGB(190, 190, 200)
	hint.TextStrokeTransparency = 0.7
	hint.Text = "or press Backspace"
	hint.Parent = box

	v10 = stageLightViewUI
	return stageLightViewUI
end

local function enterView(state)
	if state.viewing or not state.stage then
		return
	end

	if v9 == nil then
		local success4, result4 = pcall(function()
			return require(ReplicatedStorage.Modules:WaitForChild("StageLightingController", 5))
		end)

		v9 = success4 and result4 or false
	end

	local v13 = v9 or nil

	if not v13 then
		return
	end

	state.viewAngle = "front"
	local viewCFrame, fieldOfView = v13.GetViewCFrame(state.stage, state.viewAngle)

	if not viewCFrame then
		return
	end

	local currentCamera = Workspace.CurrentCamera
	state.viewSaved = { cf = currentCamera.CFrame, fov = currentCamera.FieldOfView }
	state.viewing = true
	v11 = state
	LaptopClientController.SetBackspaceBlocked(true)
	v13.SetDemo(state.stage, true)

	if state.viewTween then
		state.viewTween:Cancel()
	end

	state.viewTween = TweenService:Create(
		currentCamera,
		TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ CFrame = viewCFrame, FieldOfView = fieldOfView }
	)
	state.viewTween:Play()
	local viewUI = ensureViewUI()

	if viewUI then
		viewUI.Enabled = true
	end

	refreshViewButtons()
end

local function setViewAngle(state, viewAngle)
	if not state.viewing or state.viewAngle == viewAngle then
		return
	end

	if v9 == nil then
		local success4, result4 = pcall(function()
			return require(ReplicatedStorage.Modules:WaitForChild("StageLightingController", 5))
		end)

		v9 = success4 and result4 or false
	end

	local v13 = v9 or nil

	local cframe = v13 and v13.GetViewCFrame(state.stage, viewAngle)

	if not cframe then
		return
	end

	state.viewAngle = viewAngle
	local currentCamera = Workspace.CurrentCamera

	if state.viewTween then
		state.viewTween:Cancel()
	end

	state.viewTween = TweenService:Create(
		currentCamera,
		TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ CFrame = cframe, FieldOfView = nil }
	)
	state.viewTween:Play()
	refreshViewButtons()
end

local function exitView(state, p)
	if not state.viewing then
		return
	end

	state.viewing = false

	if v11 == state then
		v11 = nil
	end

	if v9 == nil then
		local success4, result4 = pcall(function()
			return require(ReplicatedStorage.Modules:WaitForChild("StageLightingController", 5))
		end)

		v9 = success4 and result4 or false
	end

	local v13 = v9 or nil

	if v13 and state.stage then
		v13.SetDemo(state.stage, false)
	end

	if v10 then
		v10.Enabled = false
	end

	local currentCamera = Workspace.CurrentCamera

	if state.viewTween then
		state.viewTween:Cancel()
		state.viewTween = nil
	end

	local viewSaved = state.viewSaved
	state.viewSaved = nil

	if viewSaved then
		if p then
			currentCamera.FieldOfView = viewSaved.fov
		else
			state.viewTween = TweenService:Create(
				currentCamera,
				TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ CFrame = viewSaved.cf, FieldOfView = viewSaved.fov }
			)
			state.viewTween:Play()
		end
	end

	task.delay(0.15, function()
		if not v11 then
			LaptopClientController.SetBackspaceBlocked(false)
		end
	end)
end

LaptopStageLightPanel._exitView = exitView
LaptopStageLightPanel._setViewAngle = setViewAngle

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not v11 then
		return
	end

	if input.KeyCode == Enum.KeyCode.Backspace then
		exitView(v11, false)
	end
end)

local function buildPanel(p, gui)
	local stageLightPanel_Local = Instance.new("Frame")
	stageLightPanel_Local.Name = "StageLightPanel_Local"
	stageLightPanel_Local.BackgroundColor3 = Theme.Colors.Background
	stageLightPanel_Local.BorderSizePixel = 0
	stageLightPanel_Local.Position = UDim2.new(0, 0, 0, 0)
	stageLightPanel_Local.Size = UDim2.new(1, 0, 1, 0)
	stageLightPanel_Local.ZIndex = 15
	stageLightPanel_Local.Active = true
	stageLightPanel_Local.ClipsDescendants = true
	stageLightPanel_Local.Visible = false
	stageLightPanel_Local.Parent = gui
	Retro.AttachScreenFrame(stageLightPanel_Local)

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 26)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = stageLightPanel_Local

	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, -38, 0, 22)
	frame.Parent = stageLightPanel_Local
	newLabel(frame, "Stage Light", {
		font = Theme.Fonts.Medium,
		size = Theme.TextSize.L,
		sizeUDim = UDim2.new(1, -120, 1, 0)
	})
	local parent = newButton(frame, "View", {
		size = Theme.TextSize.S,
		sizeUDim = UDim2.new(0, 46, 0, 20),
		bg = Theme.Colors.Accent,
		color = Theme.Colors.AccentText
	})

	parent.AnchorPoint = Vector2.new(1, 0.5)
	parent.Position = UDim2.new(1, -62, 0.5, 0)
	parent.Activated:Connect(function()
		enterView(p)
	end)
	local parent2 = newButton(frame, "Reset", {
		size = Theme.TextSize.XS,
		sizeUDim = UDim2.new(0, 56, 0, 20),
		color = Theme.Colors.TextSecondary
	})

	parent2.AnchorPoint = Vector2.new(1, 0.5)
	parent2.Position = UDim2.new(1, 0, 0.5, 0)
	parent2.Activated:Connect(function()
		send(p, "reset", true) -- inferred equivalent call
	end)

	p.pv = buildPreview(p, stageLightPanel_Local)

	local scrollTrack = Instance.new("Frame")
	scrollTrack.Name = "ScrollTrack"
	scrollTrack.BackgroundColor3 = Theme.Colors.Surface
	scrollTrack.BorderSizePixel = 0
	scrollTrack.AnchorPoint = Vector2.new(1, 0)
	scrollTrack.Position = UDim2.new(1, 0, 0, 96)
	scrollTrack.Size = UDim2.new(0, 6, 1, -96)
	scrollTrack.Parent = stageLightPanel_Local
	corner(scrollTrack, UDim.new(0, 2)) -- inferred equivalent call

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.new(0, 0, 0, 96)
	scrollingFrame.Size = UDim2.new(1, 0, 1, -96)
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.ScrollBarImageColor3 = Theme.Colors.TextSecondary
	scrollingFrame.ScrollBarImageTransparency = 0.15
	scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scrollingFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.Active = true
	scrollingFrame.Parent = stageLightPanel_Local
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = scrollingFrame

	local count = 0
	local function nextOrder() -- 15 equivalent calls inferred from this helper
		count += 1
		return count
	end

	addToggle(p, scrollingFrame, nextOrder(), "show", "Stage lights") -- inferred equivalent call
	addSelector(p, scrollingFrame, nextOrder(), "mode", "Mode", StageLightConfig.MODES, function(p2) -- inferred equivalent call
		return v4[p2] or p2
	end, function(p2)
		return p2.mode
	end)
	addSelector(p, scrollingFrame, nextOrder(), "style", "Style", StageLightConfig.STYLES, function(p2) -- inferred equivalent call
		return v3[p2] or p2
	end, function(p2)
		return p2.style
	end)
	addSliderSelector(
		p,
		scrollingFrame,
		nextOrder(), -- inferred equivalent call
		"brightness",
		"Brightness",
		StageLightConfig.BRIGHTNESS_STEPS,
		function(p2)
			return tostring(p2) .. "%"
		end,
		function(p2)
			return p2.brightness
		end
	)

	newSection(scrollingFrame, nextOrder(), "COLORS  (Auto = from style)") -- inferred equivalent call

	for _, v13 in ipairs(StageLightConfig.COLOR_GROUPS) do
		addSwatchRow(p, scrollingFrame, nextOrder(), v13) -- inferred equivalent call
	end

	newSection(scrollingFrame, nextOrder(), "LAMPS") -- inferred equivalent call
	addToggle(p, scrollingFrame, nextOrder(), "group:kick", "Kick lamps (white)") -- inferred equivalent call
	addToggle(p, scrollingFrame, nextOrder(), "group:par1", "Par1 lamps (center)") -- inferred equivalent call
	addToggle(p, scrollingFrame, nextOrder(), "group:ayrton", "Ayrton bar") -- inferred equivalent call

	newSection(scrollingFrame, nextOrder(), "EFFECTS") -- inferred equivalent call
	addToggle(p, scrollingFrame, nextOrder(), "blackout", "Venue dim on play") -- inferred equivalent call
	addToggle(p, scrollingFrame, nextOrder(), "sway", "Beam movement") -- inferred equivalent call
	addToggle(p, scrollingFrame, nextOrder(), "solo", "Solo moments") -- inferred equivalent call
	addToggle(p, scrollingFrame, nextOrder(), "spfx", "Star Power effect") -- inferred equivalent call

	for _, guiObject in ipairs(stageLightPanel_Local:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += 16
		end
	end

	return stageLightPanel_Local
end

local function setTab(state, tab)
	state.tab = tab

	if state.panel then
		state.panel.Visible = tab == (state.isStudio and "studio" or "light")
	end

	if state.metroPanel then
		if tab ~= "metro" and result then
			result.ReleaseFocus(state)
		end

		state.metroPanel.Visible = tab == "metro"
	end

	if state.soundPanel then
		if tab ~= "sound" and result2 then
			result2.ReleaseFocus(state)
		end

		state.soundPanel.Visible = tab == "sound"
	end

	for k, tabButton in pairs(state.tabButtons) do
		local enabled = k == tab
		local v13 = state.tabDecor and state.tabDecor[k]

		tabButton.BackgroundColor3 = enabled and Theme.Colors.Accent or Theme.Colors.SurfaceHover
		tabButton.TextColor3 = enabled and Theme.Colors.AccentText or Theme.Colors.TextPrimary

		if not v13 then
			continue
		end

		v13.stroke.Color = enabled and Theme.Colors.Accent or Theme.Colors.BorderHover
		v13.glow.Enabled = enabled
	end
end

local function buildTabBar(state, gui)
	local laptopTabBar_Local = Instance.new("Frame")
	laptopTabBar_Local.Name = "LaptopTabBar_Local"
	laptopTabBar_Local.BackgroundTransparency = 1
	laptopTabBar_Local.BorderSizePixel = 0
	laptopTabBar_Local.Position = UDim2.new(0, 0, 0, 0)
	laptopTabBar_Local.Size = UDim2.new(1, 0, 0, 26)
	laptopTabBar_Local.ZIndex = 19
	laptopTabBar_Local.Active = false
	laptopTabBar_Local.Parent = gui

	state.tabButtons = {}
	state.tabDecor = {}
	local v13 = result ~= nil
	local v14 = v13 and 62 or 80
	local v15 = {
		{ "songs", "Songs", v13 and 38 or 46 },
		{ "light", "Lights", v13 and 38 or 48 }
	}

	if v13 then
		table.insert(v15, { "metro", "Metro", 40 })
	end

	local v16 = v13 and result2 ~= nil
	local v17 = v16 and {
		{ "songs", "Songs", 28 },
		{ "light", "Lights", 30 },
		{ "metro", "Metro", 30 },
		{ "sound", "Sound", 30 }
	} or v15

	if state.isStudio then
		if v16 then
			v17 = {
				{ "songs", "Songs", 28 },
				{ "studio", "Studio", 34 },
				{ "metro", "Metro", 28 },
				{ "sound", "Sound", 28 }
			}
		else
			for _, v18 in ipairs(v17) do
				if v18[1] ~= "light" then
					continue
				end

				v18[1] = "studio"
				v18[2] = "Studio"
				v18[3] += 4
			end
		end
	end

	if state.noLights then
		local v18 = {}

		for _, v19 in ipairs(v17) do
			if v19[1] == "light" then
				continue
			end

			v19[3] = 38
			table.insert(v18, v19)
		end

		v17 = v18
	end

	for _, v18 in ipairs(v17) do
		local textButton = Instance.new("TextButton")
		textButton.Name = "Tab_" .. v18[1]
		textButton.AutoButtonColor = false
		textButton.BackgroundColor3 = Theme.Colors.SurfaceHover
		textButton.BorderSizePixel = 0
		textButton.Font = Theme.Fonts.Bold
		textButton.TextSize = v16 and not state.noLights and 8 or v13 and 10 or 11
		textButton.TextColor3 = Theme.Colors.TextPrimary
		textButton.Text = string.upper(v18[2])
		textButton.Size = UDim2.new(0, v18[3], 0, 16)
		textButton.Position = UDim2.new(0, v14, 0, 9)
		textButton.ZIndex = 21
		textButton.Parent = laptopTabBar_Local

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = Theme.Radius.Small
		uiCorner.Parent = textButton

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1
		uiStroke.Color = Theme.Colors.BorderHover
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = textButton

		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.Thickness = 1.5
		uiStroke2.Color = Theme.Colors.Glow
		uiStroke2.Transparency = 0.85
		uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		uiStroke2.Enabled = false
		uiStroke2.Parent = textButton

		textButton.MouseEnter:Connect(function()
			if state.tab ~= v18[1] then
				textButton.BackgroundColor3 = Theme.Colors.SurfaceSelected
				textButton.TextColor3 = Theme.Colors.Glow
			end
		end)
		textButton.MouseLeave:Connect(function()
			if state.tab ~= v18[1] then
				textButton.BackgroundColor3 = Theme.Colors.SurfaceHover
				textButton.TextColor3 = Theme.Colors.TextPrimary
			end
		end)
		textButton.Activated:Connect(function()
			setTab(state, v18[1])
		end)
		state.tabButtons[v18[1]] = textButton
		state.tabDecor[v18[1]] = { stroke = uiStroke, glow = uiStroke2 }
		v14 += v18[3] + 2
	end

	return laptopTabBar_Local
end

local function ensureEntry(studioId)
	local v13 = entries[studioId]

	if v13 then
		return v13
	end

	local gui = resolveGui(v[studioId]) -- inferred equivalent call

	if not gui then
		return nil
	end

	local stage = findStage(studioId)
	local isStudio

	if result3 == nil or stage == nil then
		isStudio = false
	else
		isStudio = stage:GetAttribute("IsStudioSlot") == true
	end

	local noLights = not (isStudio or StageLightConfig.HasLights(studioId))
	local v14 = {
		studioId = studioId,
		gui = gui,
		cfg = StageLightConfig.Default(),
		isStudio = isStudio,
		noLights = noLights,
		toggles = {},
		selectors = {},
		swatches = {},
		tab = "songs",
		connections = {}
	}

	if isStudio then
		v14.panel = result3.Build(v14, gui)
	elseif noLights then
		v14.panel = nil
	else
		v14.panel = buildPanel(v14, gui)
	end

	if result then
		local success4, result4 = pcall(result.Build, v14, gui)

		if success4 then
			v14.metroPanel = result4
		else
			warn("[LaptopStageLightPanel] Gagal membangun panel Metronome:", result4)
		end
	end

	if result2 then
		local success4, result4 = pcall(result2.Build, v14, gui)

		if success4 then
			v14.soundPanel = result4
		else
			warn("[LaptopStageLightPanel] Gagal membangun panel Sound:", result4)
		end
	end

	v14.strip = buildTabBar(v14, gui)
	v14.strip.Visible = false
	entries[studioId] = v14
	return v14
end

local function onEnter(studioId)
	local entry = ensureEntry(studioId)

	if not entry then
		return
	end

	v2 = studioId
	local gui = entry.gui

	local stage = findStage(studioId)
	entry.stage = stage
	local function fn()
		if entry.noLights then
			return
		end

		local brightness = os.clock() - (entry.sliderAt or 0) < 0.6 and entry.cfg.brightness or nil
		entry.cfg = StageLightConfig.Decode(stage and stage:GetAttribute("LightCfg"))

		if brightness then
			entry.cfg.brightness = brightness
			task.delay(0.65, fn)
		end

		refresh(entry)
	end

	if not entry.noLights then
		fn()

		if stage then
			table.insert(entry.connections, stage:GetAttributeChangedSignal("LightCfg"):Connect(fn))
		end
	end

	if result and entry.metroPanel then
		result.Enter(entry)
	end

	if result2 and entry.soundPanel then
		result2.Enter(entry)
	end

	if entry.isStudio and result3 then
		result3.Enter(entry)
	end

	local Players2 = game:GetService("Players")
	local localPlayer = Players2.LocalPlayer
	local laptopOpenTab = localPlayer:GetAttribute("LaptopOpenTab")
	localPlayer:SetAttribute("LaptopOpenTab", nil)

	if laptopOpenTab == "metro" and entry.metroPanel then
		setTab(entry, "metro")
	elseif laptopOpenTab == "studio" and entry.isStudio then
		setTab(entry, "studio")
	else
		setTab(entry, "songs")
	end

	entry.strip.Visible = true

	if not entry.noLights then
		local total = 0
		table.insert(entry.connections, RunService.Heartbeat:Connect(function(dt)
			if entry.tab ~= "light" then
				total = 0
				return
			end

			total += dt

			if total < 1 / 30 then
				return
			end

			local v13 = total
			total = 0
			updatePreview(entry, math.min(v13, 0.1))
		end))
	end

	local total = 0
	table.insert(entry.connections, RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.1 then
			return
		end

		total = 0
		local laptopStemConfigPanel = gui:FindFirstChild("LaptopStemConfigPanel")
		local v13

		if laptopStemConfigPanel == nil then
			v13 = false
		else
			v13 = laptopStemConfigPanel.Visible
		end

		entry.strip.Visible = not v13

		if v13 and entry.tab ~= "songs" then
			setTab(entry, "songs")
		end
	end))
end

local function onExit(p)
	local v13 = entries[p]

	if not v13 then
		return
	end

	if v2 == p then
		v2 = nil
	end

	if v13.isStudio then
		if result3 then
			result3.ReleaseFocus(v13)
		end
	else
		exitView(v13, true)
	end

	for _, connection in ipairs(v13.connections) do
		connection:Disconnect()
	end

	v13.connections = {}

	if v13.panel then
		v13.panel.Visible = false
	end

	if v13.metroPanel then
		if result then
			result.ReleaseFocus(v13)
		end

		v13.metroPanel.Visible = false
	end

	if v13.soundPanel then
		if result2 then
			result2.ReleaseFocus(v13)
		end

		v13.soundPanel.Visible = false
	end

	v13.strip.Visible = false
	v13.tab = "songs"
end

LaptopStageLightPanel._Test = {
	onEnter = onEnter,
	onExit = onExit,
	entries = entries,
	setTab = setTab,
	refresh = refresh,
	updatePreview = updatePreview,
	enterView = enterView,
	exitView = exitView,
	setViewAngle = setViewAngle
}

function LaptopStageLightPanel.Start()
	LaptopClientController.OnEnter(onEnter)
	LaptopClientController.OnExit(onExit)
end

return LaptopStageLightPanel