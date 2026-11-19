local TweenService = game:GetService("TweenService")
local StyledTheme = require(script.Parent.StyledTheme)
local ToastStyle = require(script.Parent.ToastStyle)

local hex = ToastStyle.hex(ToastStyle.AMBER)

local NowPlayingBar = {}
NowPlayingBar.__index = NowPlayingBar

function NowPlayingBar.new(parent)
	local card = ToastStyle.buildCard({
		name = "NowPlayingBar",
		height = 28,
		rotation = -0.8,
		accent = ToastStyle.GREEN,
		tape = "tr",
		seed = 55,
		padL = 16,
		padR = 14,
		gap = 6
	})

	local card2 = card.Card
	card2.AnchorPoint = Vector2.new(0, 1)
	card2.Position = UDim2.new(0, StyledTheme.Spacing.XL, 1, -StyledTheme.Spacing.XL)
	card2.Visible = false
	card2.Parent = parent
	local BottomLeftStack = require(script.Parent.Parent.BottomLeftStack)
	BottomLeftStack.Register(card2, 1)

	local icon, iconBox = ToastStyle.makeIcon(card.Content, "♪", ToastStyle.GREEN, 1)
	card.Icon = icon

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 13
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeColor3 = ToastStyle.DARK
	label.TextStrokeTransparency = 1
	label.RichText = true
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = ""
	label.LayoutOrder = 2
	label.ZIndex = ToastStyle.Z + 4
	label.Parent = card.Content
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(math.min(300, ToastStyle.LabelMax(60)), 1e999)
	uiSizeConstraint.Parent = label

	card.Scribble = ToastStyle.makeScribble(label, ToastStyle.GREEN, 8)

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = card2

	return (setmetatable({
		Instance = card2,
		Clicked = bindableEvent.Event,
		_handle = card,
		_label = label,
		_icon = icon,
		_iconBox = iconBox,
		_bobTween = nil
	}, NowPlayingBar))
end

function NowPlayingBar:Show(value)
	self._label.Text = string.format(
		"<font color=\"%s\" face=\"PermanentMarker\">NOW PLAYING</font>  <b>%s</b>",
		hex,
		value or ""
	)
	local visible = self.Instance.Visible
	self.Instance.Visible = true

	if not visible then
		ToastStyle.popIn(self._handle)
	end

	if not self._bobTween then
		self._icon.Position = UDim2.fromOffset(0, -2)
		self._bobTween = TweenService:Create(
			self._icon,
			TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Position = UDim2.fromOffset(0, 2) }
		)

		self._bobTween:Play()
	end
end

function NowPlayingBar:Hide()
	self.Instance.Visible = false

	if self._bobTween then
		self._bobTween:Cancel()
		self._bobTween = nil
	end
end

function NowPlayingBar:Destroy()
	if self._bobTween then
		self._bobTween:Cancel()
	end

	self.Instance:Destroy()
end

return NowPlayingBar