local TweenService = game:GetService("TweenService")
local StyledTheme = require(script.Parent.StyledTheme)
local ToastStyle = require(script.Parent.ToastStyle)

local LoadingToast = {}
LoadingToast.__index = LoadingToast

function LoadingToast.new(parent)
	local card = ToastStyle.buildCard({
		name = "LoadingToast",
		width = 240,
		height = 52,
		rotation = -0.7,
		accent = ToastStyle.AMBER,
		tape = "tr",
		tag = "LOADING",
		tagX = 24,
		seed = 77,
		padL = 18,
		padR = 14,
		padT = 10,
		padB = 5,
		vertical = true,
		gap = 5
	})

	local card2 = card.Card
	card2.AnchorPoint = Vector2.new(0, 0)
	card2.Position = UDim2.new(0.5, ToastStyle.ColumnX() + 10, 0, ToastStyle.TopYFor(parent) + 7)
	card2.Visible = false
	card2.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 18)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 14
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeColor3 = ToastStyle.DARK
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.RichText = true
	label.Text = ""
	label.LayoutOrder = 1
	label.ZIndex = ToastStyle.Z + 4
	label.Parent = card.Content

	local barBackground = Instance.new("Frame")
	barBackground.Name = "BarBackground"
	barBackground.Size = UDim2.new(1, 0, 0, 7)
	barBackground.BackgroundColor3 = ToastStyle.DARK
	barBackground.BackgroundTransparency = 0.1
	barBackground.BorderSizePixel = 0
	barBackground.Rotation = -0.5
	barBackground.LayoutOrder = 2
	barBackground.ZIndex = ToastStyle.Z + 3
	barBackground.Parent = card.Content

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = ToastStyle.AMBER
	fill.BorderSizePixel = 0
	fill.ZIndex = ToastStyle.Z + 4
	fill.Parent = barBackground

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(190, 134, 44)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 218, 130)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 134, 44))
	})

	uiGradient.Offset = Vector2.new(-1, 0)
	uiGradient.Parent = fill

	local tip = Instance.new("Frame")
	tip.Name = "Tip"
	tip.AnchorPoint = Vector2.new(0.5, 0.5)
	tip.Position = UDim2.new(1, 0, 0.5, 0)
	tip.Size = UDim2.fromOffset(3, 11)
	tip.Rotation = 12
	tip.BackgroundColor3 = ToastStyle.WHITE
	tip.BorderSizePixel = 0
	tip.ZIndex = ToastStyle.Z + 5
	tip.Parent = fill

	return (setmetatable({
		Instance = card2,
		_handle = card,
		_label = label,
		_barFill = fill,
		_shimmerGradient = uiGradient,
		_shimmerTween = nil
	}, LoadingToast))
end

function LoadingToast:_startShimmer()
	if self._shimmerTween then
		self._shimmerTween:Cancel()
	end

	self._shimmerGradient.Offset = Vector2.new(-1, 0)
	self._shimmerTween = TweenService:Create(
		self._shimmerGradient,
		TweenInfo.new(1.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{ Offset = Vector2.new(1, 0) }
	)

	self._shimmerTween:Play()
end

function LoadingToast:_stopShimmer()
	if self._shimmerTween then
		self._shimmerTween:Cancel()
		self._shimmerTween = nil
	end
end

function LoadingToast:Show(value)
	self._label.Text = value or ""
	self._barFill.Size = UDim2.new(0, 0, 1, 0)
	local v = ToastStyle.TopYFor(self.Instance) + 7
	local voteBottom = ToastStyle.VoteBottom()
	local instance = self.Instance
	local v2 = ToastStyle.ColumnX() + 10
	v = voteBottom > 0 and math.max(v, voteBottom + 14) or v
	instance.Position = UDim2.new(0.5, v2, 0, v)
	self.Instance.Visible = true
	self._shownAt = os.clock()
	ToastStyle.popIn(self._handle)
	self:_startShimmer()

	task.defer(function()
		self.Instance.Visible = false
		self.Instance.Visible = true
	end)
end

function LoadingToast:SetProgress(value)
	local v = math.clamp(value, 0, 1)
	TweenService:Create(self._barFill, TweenInfo.new(StyledTheme.Animation.Fast), {
		Size = UDim2.new(v, 0, 1, 0)
	}):Play()
end

function LoadingToast:Hide()
	local v = 0.4 - (self._shownAt and os.clock() - self._shownAt or 0.4)

	if v > 0 then
		task.delay(v, function()
			if self.Instance and self.Instance.Parent then
				self.Instance.Visible = false
				self:_stopShimmer()
			end
		end)
		return
	end

	self.Instance.Visible = false
	self:_stopShimmer()
end

function LoadingToast:Destroy()
	self:_stopShimmer()
	self.Instance:Destroy()
end

return LoadingToast