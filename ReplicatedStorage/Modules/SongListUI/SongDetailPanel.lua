local StyledTheme = require(script.Parent.StyledTheme)
require(script.Parent.DifficultyBadge)
local FavoriteButton = require(script.Parent.FavoriteButton)
local PrimaryButton = require(script.Parent.PrimaryButton)
local InstrumentList = require(script.Parent.InstrumentList)
local ChartWeightClient = require(script.Parent.Parent:WaitForChild("ChartWeightClient"))

local SongDetailPanel = {}
SongDetailPanel.__index = SongDetailPanel

local function formatDuration(p)
	if not p then
		return "--:--"
	end

	local v = math.floor(p / 60)
	local v2 = p % 60
	return string.format("%d:%02d", v, v2)
end

local function buildMetaLine(genre, bpm, duration)
	local v = {}

	if genre then
		table.insert(v, genre)
	end

	if bpm then
		table.insert(v, bpm .. " BPM")
	end

	table.insert(v, formatDuration(duration))
	return table.concat(v, "  •  ")
end

function SongDetailPanel.new(parent, options)
	local v = options or {}

	local songDetailPanel = Instance.new("Frame")
	songDetailPanel.Name = "SongDetailPanel"
	songDetailPanel.BackgroundColor3 = StyledTheme.Colors.Surface
	songDetailPanel.Size = v.size or UDim2.new(1, 0, 1, 0)
	songDetailPanel.LayoutOrder = v.layoutOrder or 0
	songDetailPanel.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Large
	uiCorner.Parent = songDetailPanel

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.PaddingRight = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.PaddingTop = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.PaddingBottom = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.Parent = songDetailPanel

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.BackgroundTransparency = 1
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = StyledTheme.Sizes.ScrollBarThickness
	scroll.ScrollBarImageColor3 = StyledTheme.Colors.TextSecondary
	scroll.Parent = songDetailPanel

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.Padding = UDim.new(0, StyledTheme.Spacing.L)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = scroll

	local emptyState = Instance.new("Frame")
	emptyState.Name = "EmptyState"
	emptyState.BackgroundTransparency = 1
	emptyState.Size = UDim2.new(1, 0, 1, 0)
	emptyState.Visible = true
	emptyState.Parent = songDetailPanel

	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Name = "EmptyLabel"
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightL)
	emptyLabel.Position = UDim2.new(0, 0, 0.5, -(StyledTheme.Sizes.ControlHeightL / 2))
	emptyLabel.Font = StyledTheme.Fonts.Medium
	emptyLabel.TextSize = StyledTheme.TextSize.L
	emptyLabel.TextColor3 = StyledTheme.Colors.TextSecondary
	emptyLabel.TextWrapped = true
	emptyLabel.Text = "Select a song to see details"
	emptyLabel.Parent = emptyState

	local titleRow = Instance.new("Frame")
	titleRow.Name = "TitleRow"
	titleRow.BackgroundTransparency = 1
	titleRow.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.IconButtonSize)
	titleRow.LayoutOrder = 1
	titleRow.Parent = scroll

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -(StyledTheme.Sizes.IconButtonSize + StyledTheme.Spacing.S), 1, 0)
	title.Font = StyledTheme.Fonts.Bold
	title.TextSize = StyledTheme.TextSize.XXL
	title.TextColor3 = StyledTheme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextWrapped = true
	title.Text = ""
	title.Parent = titleRow

	local favorite = FavoriteButton.new(titleRow)
	favorite.Instance.Position = UDim2.new(1, -StyledTheme.Sizes.IconButtonSize, 0, 0)

	local playButton = PrimaryButton.new(scroll, { text = "Play", icon = "▶", layoutOrder = 2 })

	local playNotice = Instance.new("TextLabel")
	playNotice.Name = "PlayNotice"
	playNotice.BackgroundTransparency = 1
	playNotice.AutomaticSize = Enum.AutomaticSize.Y
	playNotice.Size = UDim2.new(1, 0, 0, 0)
	playNotice.Font = StyledTheme.Fonts.Medium
	playNotice.TextSize = StyledTheme.TextSize.S
	playNotice.TextColor3 = StyledTheme.Colors.Accent
	playNotice.TextXAlignment = Enum.TextXAlignment.Left
	playNotice.TextWrapped = true
	playNotice.RichText = false
	playNotice.AutoLocalize = false
	playNotice.LayoutOrder = 3
	playNotice.Text = ""
	playNotice.Visible = false
	playNotice.Parent = scroll

	local meta = Instance.new("TextLabel")
	meta.Name = "Meta"
	meta.BackgroundTransparency = 1
	meta.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightS)
	meta.Font = StyledTheme.Fonts.Regular
	meta.TextSize = StyledTheme.TextSize.M
	meta.TextColor3 = StyledTheme.Colors.TextSecondary
	meta.TextXAlignment = Enum.TextXAlignment.Left
	meta.TextWrapped = true
	meta.LayoutOrder = 4
	meta.Text = ""
	meta.Parent = scroll

	local fillEmptyRow = Instance.new("Frame")
	fillEmptyRow.Name = "FillEmptyRow"
	fillEmptyRow.BackgroundTransparency = 1
	fillEmptyRow.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightS)
	fillEmptyRow.LayoutOrder = 5
	fillEmptyRow.Parent = scroll

	local group = Instance.new("Frame")
	group.Name = "Group"
	group.BackgroundTransparency = 1
	group.Size = UDim2.new(0, 0, 1, 0)
	group.AutomaticSize = Enum.AutomaticSize.X
	group.Parent = fillEmptyRow

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout2.Padding = UDim.new(0, StyledTheme.Spacing.S)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = group

	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.PaddingLeft = UDim.new(0, 4)
	uiPadding2.PaddingRight = UDim.new(0, 2)
	uiPadding2.Parent = group

	local fillEmptyToggle = Instance.new("TextButton")
	fillEmptyToggle.Name = "FillEmptyToggle"
	fillEmptyToggle.Size = UDim2.new(0, 13, 0, 13)
	fillEmptyToggle.LayoutOrder = 1
	fillEmptyToggle.AutoButtonColor = false
	fillEmptyToggle.Text = ""
	fillEmptyToggle.BackgroundColor3 = StyledTheme.Colors.Background
	fillEmptyToggle.BackgroundTransparency = 0.35
	fillEmptyToggle.Parent = group

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = StyledTheme.Radius.Small
	uiCorner2.Parent = fillEmptyToggle

	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.35
	uiStroke.Color = StyledTheme.Colors.Accent
	uiStroke.Parent = fillEmptyToggle

	local checkIcon = Instance.new("TextLabel")
	checkIcon.Name = "CheckIcon"
	checkIcon.BackgroundTransparency = 1
	checkIcon.Size = UDim2.new(1, 0, 1, 0)
	checkIcon.Font = StyledTheme.Fonts.Bold
	checkIcon.TextSize = StyledTheme.TextSize.S
	checkIcon.TextColor3 = StyledTheme.Colors.AccentText
	checkIcon.Text = StyledTheme.Icons.Check
	checkIcon.Visible = false
	checkIcon.Parent = fillEmptyToggle

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.LayoutOrder = 2
	label.Font = StyledTheme.Fonts.Medium
	label.TextSize = StyledTheme.TextSize.M
	label.TextColor3 = StyledTheme.Colors.TextPrimary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Text = "Fill empty instruments with backing track"
	label.Parent = group

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = fillEmptyRow
	local visible2 = false

	local v2 = false

	local text = label.Text

	local v3 = false
	local v4 = true
	local fn

	local function refreshFillEmptyVisual()
		if v2 then
			label.Text = "Band is full, nothing to fill"

			fillEmptyToggle.BackgroundColor3 = StyledTheme.Colors.Background
			fillEmptyToggle.BackgroundTransparency = 0.7
			uiStroke.Transparency = 0.7
			uiStroke.Color = StyledTheme.Colors.TextDisabled
			checkIcon.Visible = false
			label.TextColor3 = StyledTheme.Colors.TextDisabled
		else
			fillEmptyToggle.BackgroundColor3 = visible2 and StyledTheme.Colors.Accent or StyledTheme.Colors.Background
			fillEmptyToggle.BackgroundTransparency = visible2 and 0 or 0.35
			uiStroke.Transparency = visible2 and 0 or 0.35
			uiStroke.Color = StyledTheme.Colors.Accent
			checkIcon.Visible = visible2
			label.TextColor3 = StyledTheme.Colors.TextPrimary
			label.Text = text
		end

		if fn then
			fn()
		end
	end

	fillEmptyToggle.MouseButton1Click:Connect(function()
		if v2 then
			return
		end

		visible2 = not visible2
		refreshFillEmptyVisual()
		bindableEvent:Fire(visible2)
	end)

	local fillHintRing = Instance.new("Frame")
	fillHintRing.Name = "FillHintRing"
	fillHintRing.AnchorPoint = Vector2.new(0.5, 0.5)
	fillHintRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	fillHintRing.Size = UDim2.new(0, 15, 0, 15)
	fillHintRing.BackgroundTransparency = 1
	fillHintRing.Active = false
	fillHintRing.Visible = false
	fillHintRing.ZIndex = fillEmptyToggle.ZIndex + 2
	fillHintRing.Parent = fillEmptyToggle

	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 5)
	uiCorner3.Parent = fillHintRing

	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Thickness = 2.5
	uiStroke2.Color = StyledTheme.Colors.Accent
	uiStroke2.Transparency = 0.05
	uiStroke2.Parent = fillHintRing

	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(
		uiStroke2,
		TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Transparency = 0.75, Thickness = 1.5 }
	)

	fn = function()
		local visible = v3 and v4 and not (v2 or visible2) and fillEmptyRow.Visible and scroll.Visible

		if visible then
			label.TextColor3 = StyledTheme.Colors.Accent
		else
			label.TextColor3 = v2 and StyledTheme.Colors.TextDisabled or StyledTheme.Colors.TextPrimary
		end

		if visible == fillHintRing.Visible then
			return
		end

		fillHintRing.Visible = visible

		if not visible then
			tween:Cancel()

			return
		end

		uiStroke2.Transparency = 0.05
		uiStroke2.Thickness = 2.5
		tween:Play()
	end
	fillEmptyRow:GetPropertyChangedSignal("Visible"):Connect(fn)
	scroll:GetPropertyChangedSignal("Visible"):Connect(fn)

	local badgeSlot = Instance.new("Frame")
	badgeSlot.Name = "BadgeSlot"
	badgeSlot.BackgroundTransparency = 1
	badgeSlot.AutomaticSize = Enum.AutomaticSize.Y
	badgeSlot.Size = UDim2.new(1, 0, 0, 0)
	badgeSlot.LayoutOrder = 6
	badgeSlot.Parent = scroll

	local recommended = Instance.new("TextLabel")
	recommended.Name = "Recommended"
	recommended.BackgroundTransparency = 1
	recommended.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightS)
	recommended.Font = StyledTheme.Fonts.Medium
	recommended.TextSize = StyledTheme.TextSize.M
	recommended.TextColor3 = StyledTheme.Colors.Accent
	recommended.TextXAlignment = Enum.TextXAlignment.Left
	recommended.LayoutOrder = 7
	recommended.Text = ""
	recommended.Visible = false
	recommended.Parent = scroll

	local playCount = Instance.new("TextLabel")
	playCount.Name = "PlayCount"
	playCount.BackgroundTransparency = 1
	playCount.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightS)
	playCount.Font = StyledTheme.Fonts.Medium
	playCount.TextSize = StyledTheme.TextSize.S
	playCount.TextColor3 = StyledTheme.Colors.TextSecondary
	playCount.TextXAlignment = Enum.TextXAlignment.Left
	playCount.LayoutOrder = 8
	playCount.Text = ""
	playCount.Visible = false
	playCount.Parent = scroll

	local instrumentsSectionLabel = Instance.new("TextLabel")
	instrumentsSectionLabel.Name = "InstrumentsSectionLabel"
	instrumentsSectionLabel.BackgroundTransparency = 1
	instrumentsSectionLabel.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightS)
	instrumentsSectionLabel.Font = StyledTheme.Fonts.Medium
	instrumentsSectionLabel.TextSize = StyledTheme.TextSize.S
	instrumentsSectionLabel.TextColor3 = StyledTheme.Colors.TextSecondary
	instrumentsSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	instrumentsSectionLabel.LayoutOrder = 9
	instrumentsSectionLabel.Text = "INSTRUMENTS AVAILABLE"
	instrumentsSectionLabel.Parent = scroll

	local instrumentList = InstrumentList.new(scroll, { layoutOrder = 10 })

	local self = setmetatable({
		Instance = songDetailPanel,
		FavoriteToggled = favorite.Toggled,
		PlayRequested = playButton.Clicked,
		InviteRequested = instrumentList.InviteClicked,
		CancelInviteRequested = instrumentList.CancelClicked,
		KickRequested = instrumentList.KickClicked,
		FillEmptyToggled = bindableEvent.Event,
		_scroll = scroll,
		_fillEmptyRow = fillEmptyRow,
		_emptyState = emptyState,
		_title = title,
		_meta = meta,
		_badgeSlot = badgeSlot,
		_recommendedLabel = recommended,
		_playCountLabel = playCount,
		_playNotice = playNotice,
		_instrumentList = instrumentList,
		_favorite = favorite,
		_playButton = playButton,
		_currentBadge = nil,
		_isLoading = false,
		_isPartyBlocked = false,
		_getFillEmpty = function()
			return visible2 and not v2
		end,
		_setFillEmpty = function(p)
			visible2 = p and not v2
			refreshFillEmptyVisual()
		end,
		_isFillLocked = function()
			return v2
		end,
		_setFillRingAllowed = function(p)
			v3 = p and true or false
			fn()
		end,
		_setFillRingModeOk = function(p)
			v4 = p and true or false
			fn()
		end,
		_setFillLocked = function(p)
			v2 = p and true or false

			if v2 then
				visible2 = false
			end

			refreshFillEmptyVisual()
		end
	}, SongDetailPanel)

	self:ShowEmpty()

	return self
end

function SongDetailPanel:ShowEmpty()
	self._emptyState.Visible = true
	self._scroll.Visible = false
end

function SongDetailPanel:ShowSong(options)
	options = options or {}

	self._emptyState.Visible = false
	self._scroll.Visible = true

	self:SetPlayButtonLoading(false)

	self:SetFillEmptyBackingTrack(false)

	self._title.AutoLocalize = false
	self._meta.AutoLocalize = false
	self._title.Text = options.displayName or options.songId or ""
	self._meta.Text = buildMetaLine(options.genre, options.bpm, options.duration)

	if self._currentBadge then
		self._currentBadge:Destroy()
		self._currentBadge = nil
	end

	if options.recommendedPlayers then
		self._recommendedLabel.AutoLocalize = false
		self._recommendedLabel.Text = string.format(
			"Best for %d player%s",
			options.recommendedPlayers,
			options.recommendedPlayers == 1 and "" or "s"
		)
		self._recommendedLabel.Visible = true
	else
		self._recommendedLabel.Visible = false
	end

	self:SetPlayCount(options.playCount)

	self._favorite:Set(options.isFavorite or false)

	self._instrumentList:Reset()
	local instrumentAvailability = options.instrumentAvailability or {}

	for k, v in pairs(instrumentAvailability) do
		self._instrumentList:SetAvailable(k, v)
	end

	local instrumentStars = options.instrumentStars or {}

	for k in pairs(instrumentAvailability) do
		self._instrumentList:SetStars(k, instrumentStars[k] or 0)
	end

	for k, v in pairs(ChartWeightClient.GetSong(options.songId)) do
		self._instrumentList:SetPartPercent(k, v)
	end

	self:_refreshFillLock()
end

function SongDetailPanel:_refreshFillLock()
	self._setFillLocked(self._instrumentList:IsFull())
end

function SongDetailPanel:SetInstrumentStates(p)
	self._instrumentList:SetStates(p)
end

function SongDetailPanel:SetPlayCount(value)
	local playCountLabel = self._playCountLabel

	if type(value) ~= "number" then
		playCountLabel.Visible = false
		return
	end

	playCountLabel.AutoLocalize = value <= 0

	if value <= 0 then
		playCountLabel.Text = "You haven't played this yet"
	else
		playCountLabel.Text = string.format("You played %dx", value)
	end

	playCountLabel.Visible = true
end

function SongDetailPanel:SetInstrumentStars(options)
	local v = options or {}

	for k in pairs(self._instrumentList.rows) do
		self._instrumentList:SetStars(k, v[k] or 0)
	end
end

function SongDetailPanel:SetInstrumentOccupant(p, p2, p3)
	self._instrumentList:SetOccupant(p, p2, p3)
	self:_refreshFillLock()
end

function SongDetailPanel:SetInstrumentIsMine(p, p2)
	self._instrumentList:SetIsMine(p, p2)
	self:_refreshFillLock()
end

function SongDetailPanel:SetInstrumentIsHost(p, p2)
	self._instrumentList:SetIsHost(p, p2)
end

function SongDetailPanel:SetInstrumentRawOccupant(p, p2)
	self._instrumentList:SetRawOccupant(p, p2)
	self:_refreshFillLock()
end

function SongDetailPanel:SetPartyStatus(p, p2)
	self._instrumentList:SetPartyStatus(p, p2)
end

function SongDetailPanel:SetHostControls(p)
	self._instrumentList:SetHostControls(p)
end

local function refreshPlayButtonState(data)
	if data._isLoading then
		data._playButton.Instance.BackgroundColor3 = StyledTheme.Colors.Accent
		data._playButton:SetDisabled(true)
		data._playButton:SetText("Loading...")
	else
		local playMode = data._playMode or "normal"

		if playMode == "instrument_locked" then
			data._playButton.Instance.BackgroundColor3 = StyledTheme.Colors.Accent
			data._playButton:SetDisabled(true)
			data._playButton:SetText("Song In Progress")
		elseif playMode == "locked" then
			data._playButton.Instance.BackgroundColor3 = StyledTheme.Colors.Accent
			data._playButton:SetDisabled(true)
			data._playButton:SetText(string.format("Only %s Can Play", data._playModeAdminName or "the admin"))
		elseif playMode == "move" then
			data._playButton.Instance.BackgroundColor3 = StyledTheme.Colors.Accent
			data._playButton:SetDisabled(false)
			data._playButton:SetText("Move Room Here")
		elseif playMode == "request" then
			data._playButton.Instance.BackgroundColor3 = StyledTheme.Colors.Accent
			data._playButton:SetDisabled(false)
			data._playButton:SetText(string.format("Request to %s", data._playModeAdminName or "the admin"))
		elseif playMode == "cooldown_move" or playMode == "cooldown_request" then
			data._playButton.Instance.BackgroundColor3 = StyledTheme.Colors.SurfaceHover
			data._playButton:SetDisabled(true)
			local v = playMode == "cooldown_move" and "Move Room Here"
				or string.format("Request to %s", data._playModeAdminName or "the admin")
			data._playButton:SetText(string.format("%s (%d)", v, data._playModeCooldown or 0))
		else
			data._playButton.Instance.BackgroundColor3 = StyledTheme.Colors.Accent

			if data._isPartyBlocked then
				data._playButton:SetDisabled(true)
				data._playButton:SetText("Waiting for party...")
			else
				data._playButton:SetDisabled(false)

				data._playButton:SetText(playMode == "rejoin" and "Rejoin" or playMode == "join" and "Join" or "Play")
			end
		end
	end
end

function SongDetailPanel:SetPlayMode(playMode, playModeAdminName, playModeCooldown)
	self._playMode = playMode
	self._playModeAdminName = playModeAdminName
	self._playModeCooldown = playModeCooldown

	self._setFillRingModeOk(playMode == nil or playMode == "normal")
	refreshPlayButtonState(self)
end

function SongDetailPanel:SetFillHintAllowed(p)
	self._setFillRingAllowed(p)
end

function SongDetailPanel:SetPlayNotice(text)
	local playNotice = self._playNotice

	if type(text) == "string" and text ~= "" then
		playNotice.Text = text
		playNotice.Visible = true
	else
		playNotice.Text = ""
		playNotice.Visible = false
	end
end

function SongDetailPanel:SetPlayBlocked(isPartyBlocked)
	self._isPartyBlocked = isPartyBlocked
	refreshPlayButtonState(self)
end

function SongDetailPanel:SetPlayButtonLoading(isLoading)
	self._isLoading = isLoading
	refreshPlayButtonState(self)
end

function SongDetailPanel:GetFavorite()
	return self._favorite:Get()
end

function SongDetailPanel:SetFavorite(p)
	self._favorite:Set(p)
end

function SongDetailPanel:GetFillEmptyBackingTrack()
	return self._getFillEmpty()
end

function SongDetailPanel:SetFillEmptyBackingTrack(p)
	self._setFillEmpty(p and true or false)
end

function SongDetailPanel:SetFillOptionVisible(p)
	if not p then
		self._setFillEmpty(false)
	end

	self._fillEmptyRow.Visible = p and true or false
end

function SongDetailPanel:Destroy()
	self.Instance:Destroy()
end

return SongDetailPanel