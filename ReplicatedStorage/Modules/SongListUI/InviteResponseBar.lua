local StyledTheme = require(script.Parent.StyledTheme)
local ToastStyle = require(script.Parent.ToastStyle)

local hex = ToastStyle.hex(ToastStyle.AMBER)
local hex2 = ToastStyle.hex(ToastStyle.GREEN)
local hex3 = ToastStyle.hex(ToastStyle.WHITE)

local avatarCardHeight = ToastStyle.AvatarCardHeight(42)

local InviteResponseBar = {}
InviteResponseBar.__index = InviteResponseBar

function InviteResponseBar.new(parent)
	local card = ToastStyle.buildCard({
		name = "InviteResponseBar",
		height = avatarCardHeight,
		rotation = -0.6,
		accent = ToastStyle.AMBER,
		tape = "both",
		tag = "INCOMING INVITE",
		tagX = 40,
		minWidth = 380,
		seed = 9113,
		padL = 16,
		padR = 14,
		gap = 8
	})

	local card2 = card.Card
	card2.AnchorPoint = Vector2.new(0, 0)
	card2.Position = UDim2.new(0.5, ToastStyle.ColumnX() + 10, 0, ToastStyle.TopYFor(parent) + 6)
	card2.Visible = false

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MinSize = Vector2.new(300, avatarCardHeight)
	uiSizeConstraint.Parent = card2

	local icon = ToastStyle.makeIcon(card.Content, "♪", ToastStyle.AMBER, 1)
	card.Icon = icon

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.RichText = true
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 14
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Text = ""
	label.LayoutOrder = 2
	label.ZIndex = ToastStyle.Z + 4
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = card.Content
	local uiSizeConstraint2 = Instance.new("UISizeConstraint")
	uiSizeConstraint2.MaxSize = Vector2.new(ToastStyle.LabelMax(190), 1e999)
	uiSizeConstraint2.Parent = label
	card.Scribble = ToastStyle.makeScribble(label, ToastStyle.AMBER, 10)
	ToastStyle.attachAvatar(card, nil, avatarCardHeight, true)

	local joinButton = ToastStyle.makeButton(card.Content, "JOIN", "T", 3, ToastStyle.GREEN, ToastStyle.DARK, 0, 24)
	joinButton.Name = "JoinButton"
	local denyButton = ToastStyle.makeButton(card.Content, "DENY", "U", 4, ToastStyle.RED, ToastStyle.WHITE, 0, 24)
	denyButton.Name = "DenyButton"
	local readyButton = ToastStyle.makeButton(card.Content, "READY", "T", 5, ToastStyle.GREEN, ToastStyle.DARK, 0, 24)
	readyButton.Name = "ReadyButton"
	readyButton.Visible = false

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = card2
	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Parent = card2
	local bindableEvent3 = Instance.new("BindableEvent")
	bindableEvent3.Parent = card2

	joinButton.MouseButton1Click:Connect(function()
		bindableEvent:Fire()
	end)
	denyButton.MouseButton1Click:Connect(function()
		bindableEvent2:Fire()
	end)
	readyButton.MouseButton1Click:Connect(function()
		bindableEvent3:Fire()
	end)

	card2.Parent = parent

	return (setmetatable({
		Instance = card2,
		JoinPressed = bindableEvent.Event,
		DenyPressed = bindableEvent2.Event,
		ReadyPressed = bindableEvent3.Event,
		_joinPressedEvent = bindableEvent,
		_denyPressedEvent = bindableEvent2,
		_readyPressedEvent = bindableEvent3,
		_handle = card,
		_label = label,
		_badgeIcon = icon,
		_joinButton = joinButton,
		_denyButton = denyButton,
		_readyButton = readyButton,
		_state = nil
	}, InviteResponseBar))
end

local function setLabel(p, text, text2) -- 5 equivalent calls inferred from this helper
	p._handle.Tag.Text = text
	p._label.Text = text2
end

function InviteResponseBar:ShowInvite(p, p2)
	pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage.Modules.HapticFx).Play("Invite")
	end)
	self._state = "invited"

	if self._handle.Avatar then
		self._handle.Avatar.Set(p)
	end

	self._joinButton.Visible = true
	self._denyButton.Visible = true
	self._readyButton.Visible = false
	self._badgeIcon.Text = "♪"
	self._handle.SetAccent(ToastStyle.AMBER)

	if p2 then
		setLabel( -- inferred equivalent call
			self,
			"INCOMING INVITE",
			string.format(
				"<font color=\"%s\"><b>%s</b></font> invites you to play <font color=\"%s\"><b>\"%s\"</b></font>!",
				hex,
				p,
				hex3,
				p2
			)
		)
	else
		setLabel( -- inferred equivalent call
			self,
			"INCOMING INVITE",
			string.format("<font color=\"%s\"><b>%s</b></font> invites you to join!", hex, p)
		)
	end

	local v = ToastStyle.TopYFor(self.Instance) + 6
	local voteBottom = ToastStyle.VoteBottom()
	local instance = self.Instance
	local v2 = ToastStyle.ColumnX() + 10
	v = voteBottom > 0 and math.max(v, voteBottom + 14) or v
	instance.Position = UDim2.new(0.5, v2, 0, v)
	self.Instance.Visible = true
	ToastStyle.popIn(self._handle)
	self._handle.Flash()
end

function InviteResponseBar:ShowLoading(value)
	self._state = "loading"
	self._joinButton.Visible = false
	self._denyButton.Visible = false
	self._readyButton.Visible = false
	self._badgeIcon.Text = "♪"
	self._handle.SetAccent(ToastStyle.AMBER)
	setLabel( -- inferred equivalent call
		self,
		"LOADING",
		string.format("Loading song stems... <font color=\"%s\"><b>(%d%%)</b></font>", hex, value or 0)
	)
	self.Instance.Visible = true
end

function InviteResponseBar:UpdateLoadingPercent(p)
	if self._state ~= "loading" then
		return
	end

	setLabel(self, "LOADING", string.format("Loading song stems... <font color=\"%s\"><b>(%d%%)</b></font>", hex, p)) -- inferred equivalent call
end

function InviteResponseBar:ShowJoinedWaitingReady()
	self._state = "joined"
	self._joinButton.Visible = false
	self._denyButton.Visible = false

	self._readyButton.Visible = false
	self._badgeIcon.Text = StyledTheme.Icons.Check
	self._handle.SetAccent(ToastStyle.GREEN)
	setLabel( -- inferred equivalent call
		self,
		"YOU'RE IN",
		string.format("<font color=\"%s\"><b>Joined!</b></font> Press Ready when you're set.", hex2)
	)
	self.Instance.Visible = true
end

function InviteResponseBar:Hide()
	self._state = nil
	self.Instance.Visible = false
end

function InviteResponseBar:GetState()
	return self._state
end

function InviteResponseBar:TriggerJoin()
	if self._state == "invited" then
		self._joinPressedEvent:Fire()
	end
end

function InviteResponseBar:TriggerDeny()
	if self._state == "invited" then
		self._denyPressedEvent:Fire()
	end
end

function InviteResponseBar:TriggerReady()
	if self._state == "joined" then
		self._readyPressedEvent:Fire()
	end
end

function InviteResponseBar:Destroy()
	self.Instance:Destroy()
end

return InviteResponseBar