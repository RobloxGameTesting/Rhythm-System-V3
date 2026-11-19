local ToastStyle = require(script.Parent:WaitForChild("SongListUI"):WaitForChild("ToastStyle"))

local BackingTrackNoticeUI = {}
BackingTrackNoticeUI.__index = BackingTrackNoticeUI

local function esc(value) -- 3 equivalent calls inferred from this helper
	return (tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function addLabel(card, layoutOrder, p)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 13
	label.TextColor3 = ToastStyle.INK
	label.RichText = true
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = ""
	label.LayoutOrder = layoutOrder
	label.ZIndex = ToastStyle.Z + 4
	label.Parent = card.Content

	local currentCamera = workspace.CurrentCamera
	local x = currentCamera and currentCamera.ViewportSize.X or 1152
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(math.clamp(x - 40 - p, 90, 560), 1e999)
	uiSizeConstraint.Parent = label
	return label
end

local function placeCard(card) -- 3 equivalent calls inferred from this helper
	card.AnchorPoint = Vector2.new(0.5, 1)
	card.Position = UDim2.new(0.5, 0, 1, -28)
	card.Visible = false
end

function BackingTrackNoticeUI.new(parent)
	local self = setmetatable({}, BackingTrackNoticeUI)

	local card = ToastStyle.buildCard({
		name = "StillPlayingCard",
		height = 36,
		rotation = -0.6,
		accent = ToastStyle.AMBER,
		tape = "tr",
		seed = 77,
		padL = 16,
		padR = 12,
		gap = 8
	})

	placeCard(card.Card) -- inferred equivalent call
	card.Card.Parent = parent
	card.Icon = ToastStyle.makeIcon(card.Content, "♪", ToastStyle.AMBER, 1)
	local stillLabel = addLabel(card, 2, 250)
	local stopButton = ToastStyle.makeButton(
		card.Content,
		"■ STOP SONG",
		nil,
		3,
		ToastStyle.RED,
		ToastStyle.WHITE,
		0,
		24
	)
	stopButton.Name = "StopButton"
	local dismissButton = ToastStyle.makeButton(
		card.Content,
		"Dismiss",
		nil,
		4,
		ToastStyle.PLATE_LIGHT,
		ToastStyle.INK,
		0,
		24
	)
	dismissButton.Name = "DismissButton"

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	stopButton.Activated:Connect(function()
		bindableEvent:Fire()
	end)
	dismissButton.Activated:Connect(function()
		bindableEvent2:Fire()
	end)

	local card2 = ToastStyle.buildCard({
		name = "PressPlayCard",
		height = 36,
		rotation = 0.6,
		accent = ToastStyle.GREEN,
		tape = "tr",
		seed = 91,
		padL = 16,
		padR = 14,
		gap = 8
	})

	placeCard(card2.Card) -- inferred equivalent call
	card2.Card.Parent = parent
	card2.Icon = ToastStyle.makeIcon(card2.Content, "♪", ToastStyle.GREEN, 1)
	local pressLabel = addLabel(card2, 2, 150)
	local joinButton = ToastStyle.makeButton(card2.Content, "JOIN", nil, 3, ToastStyle.GREEN, ToastStyle.DARK, 0, 24)
	joinButton.Name = "JoinButton"
	local bindableEvent3 = Instance.new("BindableEvent")
	joinButton.Activated:Connect(function()
		bindableEvent3:Fire()
	end)

	local card3 = ToastStyle.buildCard({
		name = "WrongSongCard",
		height = 36,
		rotation = -0.4,
		accent = ToastStyle.AMBER,
		tape = "tr",
		seed = 53,
		padL = 16,
		padR = 12,
		gap = 8
	})

	placeCard(card3.Card) -- inferred equivalent call
	card3.Card.Position = UDim2.new(0.5, 0, 1, -112)
	card3.Card.Parent = parent
	card3.Icon = ToastStyle.makeIcon(card3.Content, "♪", ToastStyle.AMBER, 1)
	local wrongLabel = addLabel(card3, 2, 260)
	local wrongJoinButton = ToastStyle.makeButton(
		card3.Content,
		"JOIN",
		nil,
		3,
		ToastStyle.GREEN,
		ToastStyle.DARK,
		0,
		24
	)
	wrongJoinButton.Name = "WrongJoinButton"
	local wrongDismissButton = ToastStyle.makeButton(
		card3.Content,
		"Dismiss",
		nil,
		4,
		ToastStyle.PLATE_LIGHT,
		ToastStyle.INK,
		0,
		24
	)
	wrongDismissButton.Name = "WrongDismissButton"
	local bindableEvent4 = Instance.new("BindableEvent")
	local bindableEvent5 = Instance.new("BindableEvent")
	wrongJoinButton.Activated:Connect(function()
		bindableEvent4:Fire()
	end)
	wrongDismissButton.Activated:Connect(function()
		bindableEvent5:Fire()
	end)

	self._still = card
	self._stillLabel = stillLabel
	self._press = card2
	self._pressLabel = pressLabel
	self._pressToken = 0
	self._wrong = card3
	self._wrongLabel = wrongLabel
	self._wrongToken = 0
	self._wrongJoinEvent = bindableEvent4
	self._wrongDismissEvent = bindableEvent5
	self.WrongJoinClicked = bindableEvent4.Event
	self.WrongDismissClicked = bindableEvent5.Event
	self._stopEvent = bindableEvent
	self._joinEvent = bindableEvent3
	self.JoinClicked = bindableEvent3.Event
	self._dismissEvent = bindableEvent2
	self.StopClicked = bindableEvent.Event
	self.DismissClicked = bindableEvent2.Event
	return self
end

function BackingTrackNoticeUI:ShowStillPlaying(value)
	self._stillLabel.Text = string.format(
		"<font color=\"%s\" face=\"PermanentMarker\">STILL PLAYING</font>  <b>%s</b>",
		ToastStyle.hex(ToastStyle.AMBER),
		esc(value) -- inferred equivalent call
	)

	local visible = self._still.Card.Visible
	self._still.Card.Visible = true

	if not visible then
		ToastStyle.popIn(self._still)
	end
end

function BackingTrackNoticeUI:HideStillPlaying()
	self._still.Card.Visible = false
end

function BackingTrackNoticeUI:IsStillPlayingVisible()
	return self._still.Card.Visible
end

function BackingTrackNoticeUI:ShowPressPlay(value)
	self._pressLabel.Text = string.format(
		"<font color=\"%s\" face=\"PermanentMarker\">NOT IN SONG YET</font>  Your <b>%s</b> is silent — not in the song yet",
		ToastStyle.hex(ToastStyle.GREEN),
		esc(value) -- inferred equivalent call
	)

	self._pressToken += 1
	local pressToken = self._pressToken
	local visible = self._press.Card.Visible
	self._press.Card.Visible = true

	if not visible then
		ToastStyle.popIn(self._press)
	end

	task.delay(12, function()
		if self._pressToken == pressToken then
			self._press.Card.Visible = false
		end
	end)
end

function BackingTrackNoticeUI:HidePressPlay()
	self._pressToken += 1
	self._press.Card.Visible = false
end

function BackingTrackNoticeUI:ShowWrongSong(value)
	self._wrongLabel.Text = string.format(
		"<font color=\"%s\" face=\"PermanentMarker\">DIFFERENT SONG</font>  The stage is playing <b>%s</b> — join to sync",
		ToastStyle.hex(ToastStyle.AMBER),
		esc(value) -- inferred equivalent call
	)

	self._wrongToken += 1
	local wrongToken = self._wrongToken
	local visible = self._wrong.Card.Visible
	self._wrong.Card.Visible = true

	if not visible then
		ToastStyle.popIn(self._wrong)
	end

	task.delay(20, function()
		if self._wrongToken == wrongToken then
			self._wrong.Card.Visible = false
		end
	end)
end

function BackingTrackNoticeUI:HideWrongSong()
	self._wrongToken += 1
	self._wrong.Card.Visible = false
end

function BackingTrackNoticeUI:Destroy()
	self._stopEvent:Destroy()
	self._dismissEvent:Destroy()
	self._joinEvent:Destroy()
	self._wrongJoinEvent:Destroy()
	self._wrongDismissEvent:Destroy()
	self._wrong.Card:Destroy()
	self._still.Card:Destroy()
	self._press.Card:Destroy()
end

return BackingTrackNoticeUI