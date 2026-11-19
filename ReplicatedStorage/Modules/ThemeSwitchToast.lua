local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Modules.SongListUI.StyledTheme)
local ToastStyle = require(game.ReplicatedStorage.Modules.SongListUI.ToastStyle)

local ThemeSwitchToast = {}
ThemeSwitchToast.__index = ThemeSwitchToast

function ThemeSwitchToast.new(parent)
	local themeSwitchToast = Instance.new("CanvasGroup")
	themeSwitchToast.Name = "ThemeSwitchToast"
	themeSwitchToast.AnchorPoint = Vector2.new(0, 0)
	themeSwitchToast.Position = UDim2.new(0.5, ToastStyle.ColumnX(), 0, ToastStyle.TopYFor(parent) - 2)
	themeSwitchToast.AutomaticSize = Enum.AutomaticSize.XY
	themeSwitchToast.Size = UDim2.new(0, 0, 0, 0)
	themeSwitchToast.BackgroundTransparency = 1
	themeSwitchToast.GroupTransparency = 0
	themeSwitchToast.Visible = false
	themeSwitchToast.ZIndex = ToastStyle.Z
	themeSwitchToast:SetAttribute("NoNewUISkin", true)
	themeSwitchToast.Parent = parent

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.PaddingTop = UDim.new(0, 7)
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.Parent = themeSwitchToast

	local card = ToastStyle.buildCard({
		name = "ToastCard",
		height = 30,
		rotation = -0.6,
		accent = ToastStyle.AMBER,
		tape = "tr",
		seed = 31,
		padL = 14,
		padR = 14,
		parent = themeSwitchToast
	})

	card.Icon = ToastStyle.makeIcon(card.Content, "!", ToastStyle.AMBER, 1)

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 14
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeColor3 = ToastStyle.DARK
	label.TextStrokeTransparency = 1
	label.RichText = true
	label.Text = ""
	label.LayoutOrder = 2
	label.ZIndex = ToastStyle.Z + 4
	label.Parent = card.Content
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(ToastStyle.LabelMax(70), 1e999)
	uiSizeConstraint.Parent = label

	card.Scribble = ToastStyle.makeScribble(label, ToastStyle.AMBER, 9)

	return (setmetatable({
		_card = themeSwitchToast,
		_label = label,
		_handle = card,
		_scale = card.Scale,
		_hideThread = nil
	}, ThemeSwitchToast))
end

function ThemeSwitchToast:Show(text, value)
	self._label.Text = text
	local v = ToastStyle.TopYFor(self._card) - 2
	local voteBottom = ToastStyle.VoteBottom()
	local card = self._card
	local columnX = ToastStyle.ColumnX()
	v = voteBottom > 0 and math.max(v, voteBottom + 7) or v
	card.Position = UDim2.new(0.5, columnX, 0, v)
	self._card.Visible = true
	self._card.GroupTransparency = 0
	self._card.Active = true

	ToastStyle.popIn(self._handle)
	self._handle.Flash()

	local hideThread = self._hideThread
	self._hideThread = nil

	if hideThread then
		task.cancel(hideThread)
	end

	self._hideThread = task.delay(value or 3, function()
		self._hideThread = nil
		self._card.Active = false
		local tween = TweenService:Create(
			self._card,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ GroupTransparency = 1 }
		)

		tween.Completed:Connect(function()
			self._card.Visible = false
		end)
		tween:Play()
	end)
end

function ThemeSwitchToast:Destroy()
	if self._hideThread then
		task.cancel(self._hideThread)
	end

	self._card:Destroy()
end

return ThemeSwitchToast