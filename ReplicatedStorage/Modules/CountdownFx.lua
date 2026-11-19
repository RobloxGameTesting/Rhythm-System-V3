local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.SongListUI.Theme)

local CountdownFx = {}
CountdownFx.__index = CountdownFx

local color = Color3.fromRGB(0, 0, 0)

local Accent = Theme.Colors.Accent
local color2 = Color3.fromRGB(255, 250, 240)

local v = { PreRoll = "GET READY", Intro = "INTRO", Break = "BREAK" }

local function lowerBound(kicks, p)
	local v2 = #kicks + 1
	local v3 = 1

	while v3 < v2 do
		local v4 = (v3 + v2) // 2

		if kicks[v4] < p then
			v3 = v4 + 1
		else
			v2 = v4
		end
	end

	return v3
end

local function makeCircle(frame) -- 2 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame
end

function CountdownFx:Attach(caption)
	local object = setmetatable({}, CountdownFx)
	object._label = self
	object._caption = caption
	object._active = false
	object._kind = nil
	object._lastNumber = nil
	object._scaleTween = nil
	object._glowTween = nil
	object._kicks = nil
	object._kickIdx = nil
	object._lastPulseSongTime = nil
	object._random = Random.new()

	self.BackgroundTransparency = 1
	self.TextColor3 = color2
	self.TextStrokeTransparency = 1

	local stroke = self:FindFirstChildOfClass("UIStroke")

	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Parent = self
	end

	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Transparency = 0.4
	object._stroke = stroke

	local countdownScale = Instance.new("UIScale")
	countdownScale.Name = "CountdownScale"
	countdownScale.Scale = 1.4
	countdownScale.Parent = self
	object._scale = countdownScale

	object._ripples = {}
	object._rippleIdx = 0

	for i = 1, 4 do
		local frame = Instance.new("Frame")
		frame.Name = "BeatRipple" .. i
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.Size = UDim2.new(0.45, 0, 0.45, 0)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Visible = false
		frame.ZIndex = self.ZIndex + 1
		frame.Parent = self
		makeCircle(frame) -- inferred equivalent call
		local uiStroke = Instance.new("UIStroke")
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Color = Accent
		uiStroke.Thickness = 1.5
		uiStroke.Transparency = 1
		uiStroke.Parent = frame

		object._ripples[i] = { Frame = frame, Stroke = uiStroke, Tweens = {} }
	end

	object._sparks = {}
	object._sparkIdx = 0

	for i = 1, 12 do
		local frame = Instance.new("Frame")
		frame.Name = "BeatSpark" .. i
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Size = UDim2.new(0, 3, 0, 3)
		frame.BackgroundColor3 = Accent
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Visible = false
		frame.ZIndex = self.ZIndex + 2
		frame.Parent = self
		makeCircle(frame) -- inferred equivalent call
		object._sparks[i] = { Frame = frame, Tween = nil }
	end

	caption.Text = "GET READY"
	caption.TextColor3 = Theme.Colors.TextPrimary
	caption.TextTransparency = 0.25

	return object
end

function CountdownFx:_animateScale(p, duration)
	if self._scaleTween then
		self._scaleTween:Cancel()
	end

	self._scale.Scale = p * 1.4
	local tween = TweenService:Create(
		self._scale,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = 1.4 }
	)

	self._scaleTween = tween
	tween:Play()
end

function CountdownFx:_flashGlow()
	if self._glowTween then
		self._glowTween:Cancel()
	end

	local stroke = self._stroke
	stroke.Color = Accent
	stroke.Thickness = 3.5
	stroke.Transparency = 0.1
	local tween = TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Color = color,
		Thickness = 2,
		Transparency = 0.4
	})

	self._glowTween = tween
	tween:Play()
end

function CountdownFx:_emitRipple()
	self._rippleIdx = self._rippleIdx % 4 + 1
	local ripple = self._ripples[self._rippleIdx]

	for _, tween in ipairs(ripple.Tweens) do
		tween:Cancel()
	end

	table.clear(ripple.Tweens)

	ripple.Frame.Size = UDim2.new(0.45, 0, 0.45, 0)
	ripple.Frame.Visible = true
	ripple.Stroke.Transparency = 0.2
	ripple.Stroke.Thickness = 1.5

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(ripple.Frame, tweenInfo, { Size = UDim2.new(1.7, 0, 1.7, 0) })
	local tween2 = TweenService:Create(ripple.Stroke, tweenInfo, {
		Transparency = 1,
		Thickness = 0.5
	})
	ripple.Tweens[1] = tween
	ripple.Tweens[2] = tween2
	tween.Completed:Connect(function(p)
		if p == Enum.PlaybackState.Completed then
			ripple.Frame.Visible = false
		end
	end)
	tween:Play()
	tween2:Play()
end

function CountdownFx:_emitSparks(p)
	for _ = 1, p do
		self._sparkIdx = self._sparkIdx % 12 + 1
		local spark = self._sparks[self._sparkIdx]

		if spark.Tween then
			spark.Tween:Cancel()
		end

		local number = self._random:NextNumber(0, 6.283185307179586)

		local v2 = 0.2 + self._random:NextNumber(0.16, 0.34)
		spark.Frame.Position = UDim2.new(math.cos(number) * 0.2 + 0.5, 0, math.sin(number) * 0.2 + 0.5, 0)
		spark.Frame.BackgroundTransparency = 0.1
		spark.Frame.Visible = true

		local tween = TweenService:Create(
			spark.Frame,
			TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0.5 + math.cos(number) * v2, 0, 0.5 + math.sin(number) * v2, 0),
				BackgroundTransparency = 1
			}
		)

		spark.Tween = tween
		tween.Completed:Connect(function(p2)
			if p2 == Enum.PlaybackState.Completed then
				spark.Frame.Visible = false
			end
		end)
		tween:Play()
	end
end

function CountdownFx:_clearEffects()
	for _, ripple in ipairs(self._ripples) do
		for _, tween in ipairs(ripple.Tweens) do
			tween:Cancel()
		end

		table.clear(ripple.Tweens)
		ripple.Frame.Visible = false
	end

	for _, spark in ipairs(self._sparks) do
		if spark.Tween then
			spark.Tween:Cancel()
			spark.Tween = nil
		end

		spark.Frame.Visible = false
	end

	if self._glowTween then
		self._glowTween:Cancel()
		self._glowTween = nil
	end

	if self._scaleTween then
		self._scaleTween:Cancel()
		self._scaleTween = nil
	end

	self._stroke.Color = color
	self._stroke.Thickness = 2
	self._stroke.Transparency = 0.4
	self._scale.Scale = 1.4
end

function CountdownFx:_pulse(lastPulseSongTime): boolean
	local _lastPulseSongTime = self._lastPulseSongTime

	if
		_lastPulseSongTime
		and _lastPulseSongTime <= lastPulseSongTime
		and lastPulseSongTime - _lastPulseSongTime < 0.22
	then
		return false
	end

	self._lastPulseSongTime = lastPulseSongTime
	self:_emitRipple()
	self:_emitSparks(3)
	self:_flashGlow()
	self:_animateScale(1.12, 0.16)
	return true
end

function CountdownFx:_beginBeats(value, p)
	self._kickIdx = nil
	self._lastPulseSongTime = nil

	if typeof(value) ~= "number" or value < 0 then
		return
	end

	local kicks = self._kicks

	if typeof(kicks) ~= "table" or #kicks == 0 then
		return
	end

	local kickIdx = lowerBound(kicks, value - 0.12)
	local kick = kicks[kickIdx]

	if kick and kick < value + p then
		self._kickIdx = kickIdx
	end
end

function CountdownFx:_tickBeats(value)
	local kickIdx = self._kickIdx

	if not kickIdx or typeof(value) ~= "number" then
		return
	end

	local kicks = self._kicks
	local v2 = false

	while kicks[kickIdx] and kicks[kickIdx] <= value do
		if not v2 and value - kicks[kickIdx] <= 0.12 then
			v2 = self:_pulse(value)
		end

		kickIdx += 1
	end

	self._kickIdx = kickIdx
end

function CountdownFx:Show(p, p2, _, p3, p4)
	local label = self._label
	local kind = v[p2] and p2 or "PreRoll"
	self._kicks = p4 and p4.Kicks or nil

	if self._active then
		if not label.Visible then
			label.Visible = true
			self._caption.Visible = true
		end
	else
		self._active = true
		self._lastNumber = nil
		self._kind = nil
		label.Text = ""
		label.TextColor3 = color2
		label.Visible = true
		self._caption.Visible = true
		self:_beginBeats(p3, p)
	end

	if kind ~= self._kind then
		self._kind = kind
		self._caption.Text = v[kind]
	end

	local lastNumber = math.max(1, (math.ceil(p)))

	if lastNumber ~= self._lastNumber then
		label.Text = tostring(lastNumber)
		self._lastNumber = lastNumber
	end

	self:_tickBeats(p3)
end

function CountdownFx:Hide()
	if self._active then
		self._active = false
		self._kickIdx = nil
		self:_clearEffects()
	end

	if self._label.Visible then
		self._label.Visible = false
	end

	if self._caption.Visible then
		self._caption.Visible = false
	end
end

function CountdownFx:Reset()
	self._active = false
	self._kickIdx = nil
	self._lastNumber = nil
	self._kind = nil
	self._lastPulseSongTime = nil
	self:_clearEffects()
	self._label.Visible = false
	self._caption.Visible = false
end

return CountdownFx