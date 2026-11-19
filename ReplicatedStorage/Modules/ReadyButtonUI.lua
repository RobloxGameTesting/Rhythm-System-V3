local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local SessionCameraSettings = require(script.Parent.SessionCameraSettings)

local color = Color3.fromRGB(20, 20, 19)
local color2 = Color3.fromRGB(8, 8, 8)
Color3.fromRGB(54, 160, 92)
local color3 = Color3.fromRGB(96, 218, 136)
Color3.fromRGB(22, 56, 34)
local color4 = Color3.fromRGB(112, 152, 124)
local color5 = Color3.fromRGB(204, 162, 72)
local color6 = Color3.fromRGB(158, 130, 76)
Color3.fromRGB(240, 184, 64)
Color3.fromRGB(255, 228, 150)
Color3.fromRGB(72, 44, 8)

local color7 = Color3.fromRGB(210, 58, 58)
local color8 = Color3.fromRGB(255, 120, 112)
local color9 = Color3.fromRGB(255, 218, 212)
local color10 = Color3.fromRGB(66, 172, 56)
local color11 = Color3.fromRGB(226, 255, 218)
local color12 = Color3.fromRGB(255, 255, 255)
local color13 = Color3.fromRGB(250, 214, 84)
Color3.fromRGB(190, 140, 56)
local color14 = Color3.fromRGB(74, 42, 28)
Color3.fromRGB(10, 14, 10)
Color3.fromRGB(18, 52, 30)
local color15 = Color3.fromRGB(96, 130, 104)
local color16 = Color3.fromRGB(36, 36, 34)
local color17 = Color3.fromRGB(110, 110, 104)
local color18 = Color3.fromRGB(58, 142, 82)
local color19 = Color3.fromRGB(190, 200, 192)

local Oswald = Enum.Font.Oswald
local SpecialElite = Enum.Font.SpecialElite

local ReadyButtonUI = {}
ReadyButtonUI.__index = ReadyButtonUI

local function mk(className, items, parent) -- 37 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function buildStates(p)
	return {
		available = {
			face = color7,
			stroke = color8,
			strokeThickness = 3,
			text = "READY?",
			textColor = color12,
			caption = p and "NOT READY YET - TAP" or "NOT READY YET - CLICK / T",
			captionColor = color9,
			tape = color16,
			showKey = not p,
			pulse = true,
			hint = true
		},
		ready = {
			face = color10,
			stroke = color2,
			strokeThickness = 2,
			text = "READY ✓",
			textColor = color12,
			caption = p and "TAP TO CANCEL" or "CLICK TO CANCEL",
			captionColor = color11,
			tape = color18,
			showKey = false,
			pulse = false
		}
	}
end

local function buildGrime(parent)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Grime",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 5
	}, parent)

	mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
	local random = Random.new(23)

	local function vignette(name, position, size, rotation, p)
		local parent3 = mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size,
			ZIndex = 5
		}, parent2)

		mk("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
		}, parent3)
	end
	vignette("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 14), 90, 0.5)
	vignette("VigBottom", UDim2.new(0, 0, 1, -14), UDim2.new(1, 0, 0, 14), 270, 0.5)
	vignette("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 14, 1, 0), 0, 0.55)
	vignette("VigRight", UDim2.new(1, -14, 0, 0), UDim2.new(0, 14, 1, 0), 180, 0.55)

	for i = 1, 4 do
		local integer = random:NextInteger(26, 56)
		local parent3 = mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 2 == 0 and color14 or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.82 + random:NextNumber() * 0.08,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.7),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4)))),
			ZIndex = 5
		}, parent2)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
	end

	for i, v in ipairs({
		{ 0.08, 0.3, 56, 24 },
		{ 0.58, 0.46, 42, -31 },
		{ 0.28, 0.74, 70, 12 },
		{ 0.72, 0.18, 38, 40 }
	}) do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = color19,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(v[1], v[2]),
			Size = UDim2.new(0, v[3], 0, 1),
			Rotation = v[4],
			ZIndex = 5
		}, parent2)
	end

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Scuff" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, random:NextInteger(16, 38), 0, 1),
			Rotation = random:NextInteger(-60, 60),
			ZIndex = 5
		}, parent2)
	end

	for i = 1, 16 do
		local v = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 2)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v and color19 or Color3.new(0, 0, 0),
			BackgroundTransparency = v and 0.78 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, integer),
			ZIndex = 5
		}, parent2)
	end

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6),
		ZIndex = 5
	}, parent2)

	mk("UIStroke", { Color = color15, Thickness = 1.5, Transparency = 0.6 }, parent3) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent3) -- inferred equivalent call
end

local function addTape(parent, p, position, size, rotation, color20, backgroundTransparency, p2)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Tape" .. p,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color20,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		Active = false,
		Position = position,
		Size = size,
		Rotation = rotation,
		ZIndex = 7
	}, parent)

	mk("UIStroke", { Color = color17, Thickness = 1, Transparency = 0.6 }, parent2) -- inferred equivalent call
	local random = Random.new(p2)

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Dirt" .. i,
			BackgroundColor3 = i % 2 == 0 and Color3.new(0, 0, 0) or color19,
			BackgroundTransparency = i % 2 == 0 and 0.55 or 0.82,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(0, random:NextInteger(1, 6), random:NextNumber() * 0.8, 0),
			Size = UDim2.new(
				0,
				random:NextInteger(math.floor(size.X.Offset * 0.3), (math.floor(size.X.Offset * 0.8))),
				0,
				1
			),
			ZIndex = 8
		}, parent2)
	end

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "Smudge",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(random:NextNumber() * 0.6, 0, 0.1, 0),
		Size = UDim2.new(0, math.floor(size.X.Offset * 0.3), 0, (math.floor(size.Y.Offset * 0.7))),
		ZIndex = 8
	}, parent2)

	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
	return parent2
end

function ReadyButtonUI.new(p, p2)
	if p2 == nil then
		p2 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	end

	local parent = p or Players.LocalPlayer:WaitForChild("PlayerGui")

	local states = buildStates(p2)
	local screenGui = Instance.new("ScreenGui")

	for k, v in pairs({ Name = "ReadyButtonUI", ResetOnSpawn = false, DisplayOrder = 2 }) do
		screenGui[k] = v
	end

	screenGui.Parent = parent

	local root = mk("Frame", { -- inferred equivalent call
		Name = "Root",
		AnchorPoint = p2 and Vector2.new(1, 1) or Vector2.new(0.5, 1),
		Position = p2 and UDim2.new(1, -16, 1, -262) or UDim2.new(0.5, 0, 1, -100),
		Size = UDim2.fromOffset(p2 and 174 or 250, p2 and 54 or 58),
		BackgroundTransparency = 1,
		Visible = false
	}, screenGui)

	local popScale = mk("UIScale", {}, root) -- inferred equivalent call

	local button = mk("TextButton", { -- inferred equivalent call
		Name = "Button",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 1
	}, root)

	local pressScale = mk("UIScale", {}, button) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 3) }, button) -- inferred equivalent call
	local stroke = mk( -- inferred equivalent call
		"UIStroke",
		{ Thickness = 2.5, Color = color3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border },
		button
	)

	mk( -- inferred equivalent call
		"UIGradient",
		{
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(205, 203, 198)),
			Rotation = 90
		},
		button
	)
	local v = p2 and 8 or 46
	local mainLabel = mk("TextLabel", { -- inferred equivalent call
		Name = "MainLabel",
		Position = UDim2.new(0, 12, 0, 4),
		Size = UDim2.new(1, -(12 + v), 0, p2 and 28 or 34),
		BackgroundTransparency = 1,
		Font = Oswald,
		TextSize = p2 and 26 or 32,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = color3,
		Text = "",
		ZIndex = 3
	}, button)

	local captionLabel = mk("TextLabel", { -- inferred equivalent call
		Name = "CaptionLabel",
		Position = UDim2.new(0, 12, 0, p2 and 32 or 38),
		Size = UDim2.new(1, -(12 + v), 0, 14),
		BackgroundTransparency = 1,
		Font = SpecialElite,
		TextSize = p2 and 11 or 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = color4,
		Text = "",
		ZIndex = 3
	}, button)

	local keyBadge = mk("TextLabel", { -- inferred equivalent call
		Name = "KeyBadge",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Color3.fromRGB(12, 12, 11),
		BorderSizePixel = 0,
		Font = Oswald,
		TextSize = 20,
		TextColor3 = color5,
		Text = "T",
		Rotation = -4,
		Visible = false,
		ZIndex = 4
	}, button)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, keyBadge) -- inferred equivalent call
	mk("UIStroke", { Color = color6, Thickness = 1.5 }, keyBadge) -- inferred equivalent call

	buildGrime(button)

	addTape(button, "TopLeft", UDim2.new(0, 8, 0, 3), UDim2.fromOffset(50, 12), -38, color16, 0.1, 11)
	local accentTape = addTape(
		button,
		"BottomRight",
		UDim2.new(1, p2 and -24 or -10, 1, -2),
		UDim2.fromOffset(40, 11),
		-38,
		color18,
		0.16,
		12
	)
	addTape(button, "TopRight", UDim2.new(1, -40, 0, 0), UDim2.fromOffset(26, 8), 7, color16, 0.18, 13)

	local ring = mk("Frame", { -- inferred equivalent call
		Name = "AttentionRing",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Visible = false,
		ZIndex = 0
	}, root)

	mk("UICorner", { CornerRadius = UDim.new(0, 6) }, ring) -- inferred equivalent call
	local ringStroke = mk("UIStroke", { Color = color8, Thickness = 3, Transparency = 0.2 }, ring) -- inferred equivalent call

	local hint = mk("Frame", { -- inferred equivalent call
		Name = "ReadyHint",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -16),
		Size = UDim2.fromOffset(40, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Visible = false,
		ZIndex = 10
	}, root)

	local function chevron(p3, p4)
		for _, v2 in ipairs({ -1, 1 }) do
			local parent2 = mk("Frame", { -- inferred equivalent call
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, v2 * 6.5, 0, p3),
				Size = UDim2.fromOffset(18, 5),
				Rotation = -v2 * 40,
				BackgroundColor3 = color13,
				BackgroundTransparency = p4,
				BorderSizePixel = 0,
				Active = false,
				ZIndex = 11
			}, hint)

			mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent2) -- inferred equivalent call
			mk("UIStroke", { Color = color2, Thickness = 1.5, Transparency = p4 }, parent2) -- inferred equivalent call
		end
	end
	chevron(9, 0)
	chevron(21, 0.45)

	local pressedEvent = mk("BindableEvent", {}, screenGui) -- inferred equivalent call

	local object = setmetatable({
		Pressed = pressedEvent.Event,
		_pressedEvent = pressedEvent,
		_screenGui = screenGui,
		_parent = parent,
		_root = root,
		_button = button,
		_popScale = popScale,
		_pressScale = pressScale,
		_stroke = stroke,
		_mainLabel = mainLabel,
		_captionLabel = captionLabel,
		_keyBadge = keyBadge,
		_accentTape = accentTape,
		_states = states,
		_state = nil,
		_baseThickness = 2.5,
		_wantVisible = false,
		_pulseTween = nil,
		_ring = ring,
		_ringStroke = ringStroke,
		_hint = hint,
		_attentionOn = false,
		_attentionTweens = {},
		_lastPress = 0,
		_connections = {}
	}, ReadyButtonUI)

	local function connect(object2, p3) -- 4 equivalent calls inferred from this helper
		table.insert(object._connections, object2:Connect(p3))
	end

	local activated = button.Activated
	table.insert(object._connections, activated:Connect(function()
		if not object._state then
			return
		end

		local now = os.clock()

		if now - object._lastPress < 0.35 then
			return
		end

		object._lastPress = now
		object._pressedEvent:Fire(object._state)
	end))

	local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local function fn()
		TweenService:Create(pressScale, tweenInfo, { Scale = 0.95 }):Play()
	end

	connect(button.MouseButton1Down, fn) -- inferred equivalent call

	local function releasePress() -- 1 equivalent call inferred from this helper
		TweenService:Create(pressScale, tweenInfo, { Scale = 1 }):Play()
	end
	connect(button.MouseButton1Up, releasePress) -- inferred equivalent call
	local function fn2()
		releasePress() -- inferred equivalent call
		TweenService:Create(stroke, tweenInfo, { Thickness = object._baseThickness }):Play()
	end

	connect(button.MouseLeave, fn2) -- inferred equivalent call

	local function fn3()
		TweenService:Create(stroke, tweenInfo, {
			Thickness = object._baseThickness + 1
		}):Play()
	end

	connect(button.MouseEnter, fn3) -- inferred equivalent call

	SessionCameraSettings.OnChanged(function()
		object:_refreshVisibility(false)
	end)
	local attributeChangedSignal = parent:GetAttributeChangedSignal("AmpPanelOpen")
	table.insert(object._connections, attributeChangedSignal:Connect(function()
		object:_refreshVisibility(false)
	end))

	return object
end

function ReadyButtonUI:_applyState(p)
	local state = self._states[p]
	self._button.BackgroundColor3 = state.face
	self._stroke.Color = state.stroke
	self._stroke.Thickness = state.strokeThickness
	self._baseThickness = state.strokeThickness
	self._mainLabel.Text = state.text
	self._mainLabel.TextColor3 = state.textColor
	self._captionLabel.Text = state.caption
	self._captionLabel.TextColor3 = state.captionColor
	self._keyBadge.Visible = state.showKey
	self._accentTape.BackgroundColor3 = state.tape

	if self._pulseTween then
		self._pulseTween:Cancel()
		self._pulseTween = nil
	end

	self._stroke.Transparency = 0

	if state.pulse then
		self._pulseTween = TweenService:Create(
			self._stroke,
			TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Transparency = 0.6 }
		)

		self._pulseTween:Play()
	end

	self:_setAttention(state.hint == true)
end

function ReadyButtonUI:_setAttention(p)
	if self._attentionOn == p then
		return
	end

	self._attentionOn = p

	for _, attentionTween in ipairs(self._attentionTweens) do
		attentionTween:Cancel()
	end

	self._attentionTweens = {}

	self._hint.Visible = p
	self._ring.Visible = p
	self._hint.Position = UDim2.new(0.5, 0, 0, -16)
	self._ring.Size = UDim2.fromScale(1, 1)
	self._ringStroke.Transparency = 0.2

	if not p then
		return
	end

	local tween = TweenService:Create(
		self._hint,
		TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = UDim2.new(0.5, 0, 0, -3) }
	)

	local tweenInfo = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false)
	self._attentionTweens = {
		tween,
		TweenService:Create(self._ring, tweenInfo, { Size = UDim2.new(1, 28, 1, 20) }),
		(TweenService:Create(self._ringStroke, tweenInfo, { Transparency = 1 }))
	}

	for _, attentionTween in ipairs(self._attentionTweens) do
		attentionTween:Play()
	end
end

function ReadyButtonUI:_refreshVisibility(p)
	local v = SessionCameraSettings.GetIsMenuOpen() or self._parent:GetAttribute("AmpPanelOpen") == true
	local visible2 = self._wantVisible and not v
	local visible = self._root.Visible
	self._root.Visible = visible2

	if visible2 and (p or not visible) then
		self._popScale.Scale = 0.8
		TweenService:Create(self._popScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end
end

function ReadyButtonUI:SetState(state)
	if state ~= nil and self._states[state] == nil then
		return
	end

	local _state = self._state
	self._state = state

	if state == nil then
		self._wantVisible = false
		self:_setAttention(false)

		if self._pulseTween then
			self._pulseTween:Cancel()
			self._pulseTween = nil
		end
	else
		self._wantVisible = true
		self:_applyState(state)
	end

	self:_refreshVisibility(_state == nil and state ~= nil)
end

function ReadyButtonUI:GetState()
	return self._state
end

function ReadyButtonUI:GetButton()
	return self._button
end

function ReadyButtonUI:Destroy()
	self:_setAttention(false)

	if self._pulseTween then
		self._pulseTween:Cancel()
	end

	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	self._screenGui:Destroy()
end

return ReadyButtonUI