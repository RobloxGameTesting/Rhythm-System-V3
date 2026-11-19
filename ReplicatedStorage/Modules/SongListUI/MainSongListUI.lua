local StyledTheme = require(script.Parent.StyledTheme)
local EventBus = require(script.Parent.EventBus)
local GlobalEventBus = require(script.Parent.GlobalEventBus)
local SearchBar = require(script.Parent.SearchBar)
local FilterBar = require(script.Parent.FilterBar)
local SongListContainer = require(script.Parent.SongListContainer)
local SongDetailPanel = require(script.Parent.SongDetailPanel)
local ToggleSwitch = require(script.Parent.ToggleSwitch)
local DifficultyFilter = require(script.Parent.DifficultyFilter)

local MainSongListUI = {}
MainSongListUI.__index = MainSongListUI

local function durationComparator(p, p2): boolean
	return (p.duration or 0) < (p2.duration or 0)
end

local function countAvailableInstruments(p) -- 3 equivalent calls inferred from this helper
	local count = 0

	for _, v in pairs(p.instrumentAvailability or {}) do
		if v then
			count += 1
		end
	end

	return count
end

function MainSongListUI.new(parent, options)
	local v = options or {}

	local UserInputService = game:GetService("UserInputService")
	local v2 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local v3 = v2 and 4 or StyledTheme.Spacing.M

	local bus = EventBus.new()

	local mainSongListUI = Instance.new("Frame")
	mainSongListUI.Name = "MainSongListUI"
	mainSongListUI.BackgroundTransparency = 1
	mainSongListUI.Size = v.size or UDim2.new(1, 0, 1, 0)
	mainSongListUI.Parent = parent

	local v4 = v2 and 28 or StyledTheme.Sizes.ControlHeightL
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, v4)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.Parent = mainSongListUI

	local v5 = StyledTheme.Sizes.IconButtonSize + StyledTheme.Spacing.M + 190 + (v.backingTrackButton and 104 + StyledTheme.Spacing.M or 0) + (v.newbieModeButton and 96 + StyledTheme.Spacing.M or 0)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(0, 130, 1, 0)
	title.Font = StyledTheme.Fonts.Bold
	title.TextSize = StyledTheme.TextSize.XXL
	title.TextColor3 = StyledTheme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Text = v.title or "Song List"
	title.Parent = header

	local sessionInfoRow = Instance.new("Frame")
	sessionInfoRow.Name = "SessionInfoRow"
	sessionInfoRow.BackgroundTransparency = 1
	sessionInfoRow.Position = UDim2.new(0, 130 + StyledTheme.Spacing.M, 0, 0)
	sessionInfoRow.Size = UDim2.new(1, -(130 + StyledTheme.Spacing.M + v5), 1, 0)
	sessionInfoRow.Parent = header

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, StyledTheme.Spacing.M)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = sessionInfoRow

	local sessionInfo = Instance.new("TextLabel")
	sessionInfo.Name = "SessionInfo"
	sessionInfo.BackgroundTransparency = 1
	sessionInfo.LayoutOrder = 1
	sessionInfo.Size = UDim2.new(0, 0, 1, 0)
	sessionInfo.AutomaticSize = Enum.AutomaticSize.X
	sessionInfo.Font = StyledTheme.Fonts.Regular
	sessionInfo.TextSize = StyledTheme.TextSize.S
	sessionInfo.TextColor3 = StyledTheme.Colors.TextSecondary
	sessionInfo.TextXAlignment = Enum.TextXAlignment.Left
	sessionInfo.TextYAlignment = Enum.TextYAlignment.Center
	sessionInfo.TextTruncate = Enum.TextTruncate.AtEnd
	sessionInfo.RichText = true
	sessionInfo.Text = ""
	sessionInfo.Visible = false
	sessionInfo.Parent = sessionInfoRow

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.Parent = sessionInfo

	local sessionJoinButton = Instance.new("TextButton")
	sessionJoinButton.Name = "SessionJoinButton"
	sessionJoinButton.BackgroundColor3 = StyledTheme.Colors.Accent
	sessionJoinButton.LayoutOrder = 2
	sessionJoinButton.AutomaticSize = Enum.AutomaticSize.X
	sessionJoinButton.Size = UDim2.new(0, 0, 0, 16)
	sessionJoinButton.AutoButtonColor = false
	sessionJoinButton.Font = StyledTheme.Fonts.Medium
	sessionJoinButton.TextSize = StyledTheme.TextSize.S
	sessionJoinButton.TextColor3 = StyledTheme.Colors.AccentText
	sessionJoinButton.Text = "Join"
	sessionJoinButton.Visible = false
	sessionJoinButton.Parent = sessionInfoRow

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, StyledTheme.Spacing.S)
	uiPadding.PaddingRight = UDim.new(0, StyledTheme.Spacing.S)
	uiPadding.Parent = sessionJoinButton

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Small
	uiCorner.Parent = sessionJoinButton

	local function updateSessionInfoMax() -- 1 equivalent call inferred from this helper
		local v6 = sessionJoinButton.Visible and sessionJoinButton.AbsoluteSize.X + StyledTheme.Spacing.M or 0
		uiSizeConstraint.MaxSize = Vector2.new(math.max(0, sessionInfoRow.AbsoluteSize.X - v6), 1e999)
	end

	updateSessionInfoMax() -- inferred equivalent call
	local headerControls = Instance.new("Frame")
	headerControls.Name = "HeaderControls"
	headerControls.BackgroundTransparency = 1
	headerControls.AnchorPoint = Vector2.new(1, 0.5)
	headerControls.Position = UDim2.new(1, -(StyledTheme.Sizes.IconButtonSize + StyledTheme.Spacing.M), 0.5, 0)
	headerControls.Size = UDim2.new(0, 0, 1, 0)
	headerControls.AutomaticSize = Enum.AutomaticSize.X
	headerControls.Parent = header

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout2.Padding = UDim.new(0, StyledTheme.Spacing.M)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Parent = headerControls
	local headerToggle

	if v.headerToggle then
		headerToggle = ToggleSwitch.new(headerControls, {
			prefixLabel = v.headerToggle.prefixLabel,
			offLabel = v.headerToggle.offLabel,
			onLabel = v.headerToggle.onLabel,
			initial = v.headerToggle.initial or false
		})

		headerToggle.Instance.LayoutOrder = 1
	end

	local backingTrackButton

	if v.backingTrackButton then
		backingTrackButton = Instance.new("TextButton")
		backingTrackButton.Name = "BackingTrackButton"
		backingTrackButton.BackgroundColor3 = StyledTheme.Colors.Surface
		backingTrackButton.Size = UDim2.new(0, 104, 0, StyledTheme.Sizes.IconButtonSize)
		backingTrackButton.LayoutOrder = 2
		backingTrackButton.AutoButtonColor = false
		backingTrackButton.Font = StyledTheme.Fonts.Medium
		backingTrackButton.TextSize = StyledTheme.TextSize.S
		backingTrackButton.TextColor3 = StyledTheme.Colors.TextSecondary
		backingTrackButton.TextTruncate = Enum.TextTruncate.AtEnd
		backingTrackButton.Text = v.backingTrackButton.label or "Backing Track"
		backingTrackButton.Parent = headerControls

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = StyledTheme.Radius.Pill
		uiCorner2.Parent = backingTrackButton
	end

	local newbieModeButton

	if v.newbieModeButton then
		newbieModeButton = Instance.new("TextButton")
		newbieModeButton.Name = "NewbieModeButton"
		newbieModeButton.BackgroundColor3 = StyledTheme.Colors.Surface
		newbieModeButton.Size = UDim2.new(0, 96, 0, StyledTheme.Sizes.IconButtonSize)
		newbieModeButton.LayoutOrder = 3
		newbieModeButton.AutoButtonColor = false
		newbieModeButton.Font = StyledTheme.Fonts.Medium
		newbieModeButton.TextSize = StyledTheme.TextSize.S
		newbieModeButton.TextColor3 = StyledTheme.Colors.TextSecondary
		newbieModeButton.TextTruncate = Enum.TextTruncate.AtEnd
		newbieModeButton.Text = v.newbieModeButton.label or "Difficulty"
		newbieModeButton.Parent = headerControls

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = StyledTheme.Radius.Pill
		uiCorner2.Parent = newbieModeButton
	end

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.BackgroundColor3 = StyledTheme.Colors.Surface
	closeButton.Size = UDim2.new(0, StyledTheme.Sizes.IconButtonSize, 0, StyledTheme.Sizes.IconButtonSize)
	closeButton.Position = UDim2.new(1, -StyledTheme.Sizes.IconButtonSize, 0.5, -(StyledTheme.Sizes.IconButtonSize / 2))
	closeButton.Text = ""
	closeButton.AutoButtonColor = false
	closeButton.Parent = header

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = StyledTheme.Radius.Pill
	uiCorner2.Parent = closeButton

	local v6 = StyledTheme.Sizes.IconButtonSize * 0.45

	local bar1 = Instance.new("Frame")
	bar1.Name = "Bar1"
	bar1.AnchorPoint = Vector2.new(0.5, 0.5)
	bar1.Position = UDim2.new(0.5, 0, 0.5, 0)
	bar1.Size = UDim2.new(0, v6, 0, 2)
	bar1.Rotation = 45
	bar1.BackgroundColor3 = StyledTheme.Colors.TextSecondary
	bar1.BorderSizePixel = 0
	bar1.Parent = closeButton

	local bar2 = bar1:Clone()
	bar2.Name = "Bar2"
	bar2.Rotation = -45
	bar2.Parent = closeButton

	local v7 = v2 and 16 or StyledTheme.Sizes.ControlHeightS
	local footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundTransparency = 1
	footer.Size = UDim2.new(1, 0, 0, v7)
	footer.Position = UDim2.new(0, 0, 1, -v7)
	footer.Parent = mainSongListUI

	local count = Instance.new("TextLabel")
	count.Name = "Count"
	count.BackgroundTransparency = 1
	count.Size = UDim2.new(1, 0, 1, 0)
	count.Font = StyledTheme.Fonts.Regular
	count.TextSize = StyledTheme.TextSize.S
	count.TextColor3 = StyledTheme.Colors.TextSecondary
	count.TextXAlignment = Enum.TextXAlignment.Left
	count.Text = ""
	count.Parent = footer

	local partyStatusGroup = Instance.new("Frame")
	partyStatusGroup.Name = "PartyStatusGroup"
	partyStatusGroup.AnchorPoint = Vector2.new(1, 0.5)
	partyStatusGroup.Position = UDim2.new(1, 0, 0.5, 0)
	partyStatusGroup.AutomaticSize = Enum.AutomaticSize.X
	partyStatusGroup.Size = UDim2.new(0, 0, 1, 0)
	partyStatusGroup.BackgroundTransparency = 1
	partyStatusGroup.Visible = false
	partyStatusGroup.Parent = footer

	local uiListLayout3 = Instance.new("UIListLayout")
	uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout3.Padding = UDim.new(0, StyledTheme.Spacing.S)
	uiListLayout3.Parent = partyStatusGroup

	local partyRoomLabel = Instance.new("TextLabel")
	partyRoomLabel.Name = "PartyRoomLabel"
	partyRoomLabel.AutomaticSize = Enum.AutomaticSize.X
	partyRoomLabel.Size = UDim2.new(0, 0, 1, 0)
	partyRoomLabel.BackgroundTransparency = 1
	partyRoomLabel.Font = StyledTheme.Fonts.Regular
	partyRoomLabel.TextSize = StyledTheme.TextSize.S
	partyRoomLabel.TextColor3 = StyledTheme.Colors.TextSecondary
	partyRoomLabel.LayoutOrder = 1
	partyRoomLabel.Text = ""
	partyRoomLabel.Parent = partyStatusGroup

	local partyExitButton = Instance.new("TextButton")
	partyExitButton.Name = "PartyExitButton"
	partyExitButton.AutomaticSize = Enum.AutomaticSize.X
	partyExitButton.Size = UDim2.new(0, 0, 0.8, 0)
	partyExitButton.BackgroundColor3 = StyledTheme.Colors.Danger
	partyExitButton.Font = StyledTheme.Fonts.Medium
	partyExitButton.TextSize = StyledTheme.TextSize.S
	partyExitButton.TextColor3 = Color3.fromRGB(20, 20, 22)
	partyExitButton.Text = "Exit"
	partyExitButton.LayoutOrder = 2
	partyExitButton.Parent = partyStatusGroup

	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.PaddingLeft = UDim.new(0, StyledTheme.Spacing.S)
	uiPadding2.PaddingRight = UDim.new(0, StyledTheme.Spacing.S)
	uiPadding2.Parent = partyExitButton

	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = StyledTheme.Radius.Small
	uiCorner3.Parent = partyExitButton

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = footer
	partyExitButton.MouseButton1Click:Connect(function()
		bindableEvent:Fire()
	end)

	local xl = StyledTheme.Spacing.XL
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 0, 0, v4 + v3)
	body.Size = UDim2.new(1, 0, 1, -(v4 + v7 + v3 * 2))

	body.ClipsDescendants = true
	body.Parent = mainSongListUI

	local leftColumn = Instance.new("Frame")
	leftColumn.Name = "LeftColumn"
	leftColumn.BackgroundTransparency = 1
	leftColumn.Size = UDim2.new(0.58, -(xl / 2), 1, 0)
	leftColumn.Position = UDim2.new(0, 0, 0, 0)

	leftColumn.ClipsDescendants = true
	leftColumn.Parent = body

	local rightColumn = Instance.new("Frame")
	rightColumn.Name = "RightColumn"
	rightColumn.BackgroundTransparency = 1
	rightColumn.Size = UDim2.new(0.42000000000000004, -(xl / 2), 1, 0)
	rightColumn.Position = UDim2.new(0.58, xl / 2, 0, 0)
	rightColumn.Parent = body

	local function updateColumnLayout()
		local x = body.AbsoluteSize.X
		local y = body.AbsoluteSize.Y

		if x > 0 and x < 500 and x < y then
			leftColumn.Size = UDim2.new(1, 0, 0.58, -(xl / 2))
			leftColumn.Position = UDim2.new(0, 0, 0, 0)
			rightColumn.Size = UDim2.new(1, 0, 0.42000000000000004, -(xl / 2))
			rightColumn.Position = UDim2.new(0, 0, 0.58, xl / 2)
		else
			leftColumn.Size = UDim2.new(0.58, -(xl / 2), 1, 0)
			leftColumn.Position = UDim2.new(0, 0, 0, 0)
			rightColumn.Size = UDim2.new(0.42000000000000004, -(xl / 2), 1, 0)
			rightColumn.Position = UDim2.new(0.58, xl / 2, 0, 0)
		end
	end
	updateColumnLayout()
	local absoluteSizeChangedConnection = body:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColumnLayout)

	local v8 = v2 and 28 or StyledTheme.Sizes.ControlHeightL
	local v9 = v2 and 22 or StyledTheme.Sizes.ControlHeightM
	local v10 = v2 and 4 or StyledTheme.Spacing.M

	local searchBar = SearchBar.new(leftColumn, {
		placeholder = "Search Song...",
		size = UDim2.new(1, 0, 0, v8)
	})

	searchBar.Instance.Position = UDim2.new(0, 0, 0, 0)

	local filterBar = FilterBar.new(leftColumn, {
		items = { "All" },
		size = UDim2.new(1, 0, 0, v9)
	})

	filterBar.Instance.Position = UDim2.new(0, 0, 0, v8 + v10)

	local v11 = v8 + v10 + v9 + v10
	local sortToggle = ToggleSwitch.new(leftColumn, {
		offLabel = "A-Z",
		onLabel = "Duration",
		initial = false
	})

	sortToggle.Instance.Position = UDim2.new(0, 0, 0, v11)

	local v12 = { 2, 3, 4, 5, 6 }
	local height = v2 and 22 or StyledTheme.Sizes.ControlHeightM

	local playerCountFilter = Instance.new("Frame")
	playerCountFilter.Name = "PlayerCountFilter"
	playerCountFilter.BackgroundTransparency = 1

	local rightFilters = Instance.new("Frame")
	rightFilters.Name = "RightFilters"
	rightFilters.BackgroundTransparency = 1
	rightFilters.AnchorPoint = Vector2.new(1, 0)
	rightFilters.Position = UDim2.new(1, 0, 0, v11)
	rightFilters.Size = UDim2.new(0, 0, 0, height)
	rightFilters.AutomaticSize = Enum.AutomaticSize.X
	rightFilters.Parent = leftColumn

	local uiListLayout4 = Instance.new("UIListLayout")
	uiListLayout4.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout4.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout4.Padding = UDim.new(0, StyledTheme.Spacing.L)
	uiListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout4.Parent = rightFilters

	local v13 = DifficultyFilter.new(rightFilters, { height = height, layoutOrder = 1 })

	playerCountFilter.LayoutOrder = 2
	playerCountFilter.Size = UDim2.new(0, 0, 0, height)
	playerCountFilter.AutomaticSize = Enum.AutomaticSize.X
	playerCountFilter.Parent = rightFilters

	local uiListLayout5 = Instance.new("UIListLayout")
	uiListLayout5.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout5.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout5.Padding = UDim.new(0, StyledTheme.Spacing.XS)
	uiListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout5.Parent = playerCountFilter

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = StyledTheme.Fonts.Medium
	label.TextSize = StyledTheme.TextSize.M
	label.TextColor3 = StyledTheme.Colors.TextSecondary
	label.Text = "Player: "
	label.LayoutOrder = 0
	label.Parent = playerCountFilter

	local v14 = {}

	local v15 = nil
	local v16 = nil
	local fn

	local function refreshPlayerCountBoxes(p)
		v16 = p

		for k, v17 in pairs(v14) do
			local v18 = p == k
			v17.BackgroundColor3 = v18 and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface
			v17.TextColor3 = v18 and StyledTheme.Colors.AccentText or StyledTheme.Colors.TextSecondary
			local uiStroke = v17:FindFirstChildOfClass("UIStroke")
			uiStroke.Color = v18 and StyledTheme.Colors.Accent or StyledTheme.Colors.Border
			uiStroke.Transparency = v18 and StyledTheme.Stroke.TransparencyActive
				or StyledTheme.Stroke.TransparencyDefault
		end

		if fn then
			fn()
		end
	end

	local v17 = v11 + (v2 and 22 or StyledTheme.Sizes.ControlHeightM) + v10

	for i, v18 in ipairs(v12) do
		local textButton = Instance.new("TextButton")
		textButton.Name = "PlayerCount_" .. v18
		textButton.Text = tostring(v18)
		textButton.AutoButtonColor = false
		textButton.AutomaticSize = Enum.AutomaticSize.X
		textButton.Size = UDim2.new(0, 0, 1, 0)
		textButton.LayoutOrder = i
		textButton.BackgroundColor3 = StyledTheme.Colors.Surface
		textButton.Font = StyledTheme.Fonts.Medium
		textButton.TextSize = StyledTheme.TextSize.M
		textButton.TextColor3 = StyledTheme.Colors.TextSecondary
		textButton.Parent = playerCountFilter

		local uiPadding3 = Instance.new("UIPadding")
		uiPadding3.PaddingLeft = UDim.new(0, StyledTheme.Spacing.M)
		uiPadding3.PaddingRight = UDim.new(0, StyledTheme.Spacing.M)
		uiPadding3.Parent = textButton

		local uiCorner4 = Instance.new("UICorner")
		uiCorner4.CornerRadius = StyledTheme.Radius.Pill
		uiCorner4.Parent = textButton

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = StyledTheme.Stroke.Thickness
		uiStroke.Color = StyledTheme.Colors.Border
		uiStroke.Transparency = StyledTheme.Stroke.TransparencyDefault
		uiStroke.Parent = textButton

		v14[v18] = textButton
	end

	local stageCountMarker = Instance.new("Frame")
	stageCountMarker.Name = "StageCountMarker"
	stageCountMarker.AnchorPoint = Vector2.new(0.5, 1)
	stageCountMarker.Position = UDim2.new(0.5, 0, 1, -3)
	stageCountMarker.Size = UDim2.new(0, 12, 0, 2)
	stageCountMarker.BorderSizePixel = 0
	stageCountMarker.BackgroundColor3 = StyledTheme.Colors.Accent
	stageCountMarker.Active = false
	stageCountMarker.Visible = false

	local uiCorner4 = Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(1, 0)
	uiCorner4.Parent = stageCountMarker

	fn = function()
		local parent2 = v15 and v14[v15] or nil

		if parent2 then
			local v18 = v16 == v15
			stageCountMarker.BackgroundColor3 = v18 and StyledTheme.Colors.AccentText or StyledTheme.Colors.Accent

			if not v18 then
				parent2.TextColor3 = StyledTheme.Colors.Accent
			end

			stageCountMarker.Parent = parent2
			stageCountMarker.Visible = true
		else
			stageCountMarker.Visible = false
			stageCountMarker.Parent = nil
		end
	end

	local function setStagePlayerCount(value)
		local v18

		if type(value) == "number" and v12[1] <= value then
			v18 = math.min(math.floor(value), v12[#v12])
		end

		v15 = v18

		refreshPlayerCountBoxes(v16)
	end

	local container = SongListContainer.new(leftColumn, {
		size = UDim2.new(1, 0, 1, -v17),
		rowGap = StyledTheme.Spacing.XS
	})

	container.Instance.Position = UDim2.new(0, 0, 0, v17)

	local detailPanel = SongDetailPanel.new(rightColumn, { size = UDim2.new(1, 0, 1, 0) })

	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Parent = mainSongListUI
	local bindableEvent3 = Instance.new("BindableEvent")
	bindableEvent3.Parent = mainSongListUI
	local bindableEvent4 = Instance.new("BindableEvent")
	bindableEvent4.Parent = mainSongListUI
	local bindableEvent5 = Instance.new("BindableEvent")
	bindableEvent5.Parent = mainSongListUI
	local bindableEvent6 = Instance.new("BindableEvent")
	bindableEvent6.Parent = mainSongListUI
	local bindableEvent7 = Instance.new("BindableEvent")
	bindableEvent7.Parent = mainSongListUI
	local bindableEvent8 = Instance.new("BindableEvent")
	bindableEvent8.Parent = mainSongListUI
	local bindableEvent9 = Instance.new("BindableEvent")
	bindableEvent9.Parent = mainSongListUI
	local bindableEvent10 = Instance.new("BindableEvent")
	bindableEvent10.Parent = mainSongListUI
	local bindableEvent11 = Instance.new("BindableEvent")
	bindableEvent11.Parent = mainSongListUI

	local object = setmetatable({
		Instance = mainSongListUI,
		Selected = bindableEvent2.Event,
		FavoriteToggled = bindableEvent3.Event,
		CloseRequested = bindableEvent4.Event,
		PlayRequested = bindableEvent5.Event,
		HeaderToggleChanged = bindableEvent6.Event,
		InviteRequested = bindableEvent7.Event,
		CancelInviteRequested = bindableEvent8.Event,
		KickRequested = bindableEvent9.Event,
		BackingTrackRequested = bindableEvent10.Event,
		NewbieModeRequested = bindableEvent11.Event,
		NewbieModeButtonInstance = newbieModeButton,
		_bus = bus,
		_searchBar = searchBar,
		_filterBar = filterBar,
		_container = container,
		_detailPanel = detailPanel,
		_countLabel = count,
		_partyStatusGroup = partyStatusGroup,
		_partyRoomLabel = partyRoomLabel,
		_partyExitButton = partyExitButton,
		_sessionInfoLabel = sessionInfo,
		_sessionInfoRow = sessionInfoRow,
		_sessionJoinButton = sessionJoinButton,
		_updateSessionInfoMax = updateSessionInfoMax,
		_sessionJoinSongId = nil,
		_sessionJoinLabel = nil,
		_headerToggle = headerToggle,
		_sortToggle = sortToggle,
		_selectedEvent = bindableEvent2,
		_favoriteToggledEvent = bindableEvent3,
		_closeRequestedEvent = bindableEvent4,
		_playRequestedEvent = bindableEvent5,
		_headerToggleChangedEvent = bindableEvent6,
		_inviteRequestedEvent = bindableEvent7,
		_cancelInviteRequestedEvent = bindableEvent8,
		_kickRequestedEvent = bindableEvent9,
		_backingTrackRequestedEvent = bindableEvent10,
		_newbieModeRequestedEvent = bindableEvent11,
		_partyExitRequestedEvent = bindableEvent,
		PartyExitRequested = bindableEvent.Event,
		_currentDetailSongId = nil,
		_connections = {},
		_busConnections = {}
	}, MainSongListUI)

	table.insert(object._connections, closeButton.MouseButton1Click:Connect(function()
		bindableEvent4:Fire()
	end))
	table.insert(object._connections, absoluteSizeChangedConnection)

	table.insert(object._connections, sessionJoinButton.MouseButton1Click:Connect(function()
		if object._sessionJoinSongId then
			bindableEvent5:Fire(object._sessionJoinSongId, false)
		end
	end))
	table.insert(
		object._connections,
		sessionInfoRow:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSessionInfoMax)
	)
	table.insert(
		object._connections,
		sessionJoinButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSessionInfoMax)
	)

	if backingTrackButton then
		table.insert(object._connections, backingTrackButton.MouseButton1Click:Connect(function()
			bindableEvent10:Fire()
		end))
	end

	if newbieModeButton then
		table.insert(object._connections, newbieModeButton.MouseButton1Click:Connect(function()
			bindableEvent11:Fire()
		end))
	end

	if headerToggle then
		table.insert(object._connections, headerToggle.Toggled:Connect(function(p)
			bindableEvent6:Fire(p)
		end))
	end

	object._currentTab = "All"
	object._sortMode = "alpha"
	object._selectedPlayerCount = nil
	object._refreshPlayerCountBoxes = refreshPlayerCountBoxes
	object._setStagePlayerCount = setStagePlayerCount
	object._selectedDifficulty = nil
	function object._refreshDifficultyChips(p)
		v13:SetSelected(p)
	end

	table.insert(object._connections, sortToggle.Toggled:Connect(function(p)
		object._sortMode = p and "duration" or "alpha"
		object:_applyFilters()
	end))

	for k, v18 in pairs(v14) do
		table.insert(object._connections, v18.MouseButton1Click:Connect(function()
			if object._selectedPlayerCount == k then
				object._selectedPlayerCount = nil
			else
				object._selectedPlayerCount = k
			end

			refreshPlayerCountBoxes(object._selectedPlayerCount)
			object:_applyFilters()
		end))
	end

	table.insert(object._connections, v13.Toggled:Connect(function(selectedDifficulty)
		if object._selectedDifficulty == selectedDifficulty then
			object._selectedDifficulty = nil
		else
			object._selectedDifficulty = selectedDifficulty
		end

		v13:SetSelected(object._selectedDifficulty)
		object:_applyFilters()
	end))

	object:_wire()

	return object
end

function MainSongListUI:_applyFilters()
	local currentTab = self._currentTab
	local selectedPlayerCount = self._selectedPlayerCount
	local selectedDifficulty = self._selectedDifficulty
	local v

	if self._sortMode == "duration" then
		v = durationComparator or nil
	end

	local function matchesPlayerCount(p): boolean -- 1 equivalent call inferred from this helper
		return not selectedPlayerCount or countAvailableInstruments(p) == selectedPlayerCount -- inferred equivalent call
	end

	local function matchesDifficulty(p): boolean
		if not selectedDifficulty then
			return true
		end

		local v2 = p.displayDifficulty

		if v2 == nil then
			v2 = p.difficulty
		end

		return type(v2) == "string" and string.upper(v2) == selectedDifficulty
	end

	local function matchesExtra(p)
		local v2 = matchesPlayerCount(p) -- inferred equivalent call

		if not v2 then
			return v2
		end

		if not selectedDifficulty then
			return true
		end

		local v3 = p.displayDifficulty

		if v3 == nil then
			v3 = p.difficulty
		end

		return type(v3) == "string" and string.upper(v3) == selectedDifficulty
	end

	local v2 = selectedPlayerCount ~= nil or selectedDifficulty ~= nil

	if currentTab == "Recently Played" then
		self._container:SetGenreFilter(nil)
		self._container:SetFilter(function(data)
			local v3

			if data.recentlyPlayedRank == nil then
				v3 = false
				return false
			end

			v3 = not selectedPlayerCount

			if not v3 then
				if countAvailableInstruments(data) == selectedPlayerCount then -- inferred equivalent call
					v3 = true
				else
					v3 = false
				end
			end

			if not v3 then
				return v3
			end

			if not selectedDifficulty then
				return true
			end

			local v4 = data.displayDifficulty

			if v4 == nil then
				v4 = data.difficulty
			end

			return type(v4) == "string" and string.upper(v4) == selectedDifficulty
		end)

		self._container:SetSort(function(p, p2): boolean
			return (p.recentlyPlayedRank or 1e999) < (p2.recentlyPlayedRank or 1e999)
		end)
	else
		if currentTab == "Favorite" then
			self._container:SetGenreFilter(nil)
			self._container:SetFilter(function(data)
				local v3

				if data.isFavorite ~= true then
					v3 = false
					return false
				end

				v3 = not selectedPlayerCount

				if not v3 then
					if countAvailableInstruments(data) == selectedPlayerCount then -- inferred equivalent call
						v3 = true
					else
						v3 = false
					end
				end

				if not v3 then
					return v3
				end

				if not selectedDifficulty then
					return true
				end

				local v4 = data.displayDifficulty

				if v4 == nil then
					v4 = data.difficulty
				end

				return type(v4) == "string" and string.upper(v4) == selectedDifficulty
			end)
		else
			self._container:SetGenreFilter(currentTab)
			self._container:SetFilter(v2 and matchesExtra or nil)
		end

		self._container:SetSort(v)
	end
end

function MainSongListUI:_wire()
	local bus = self._bus

	local function connect(favoriteToggled, fn) -- 2 equivalent calls inferred from this helper
		table.insert(self._connections, favoriteToggled:Connect(fn))
	end

	local function subscribe(GlobalEventBus2, p, fn) -- 1 equivalent call inferred from this helper
		table.insert(self._busConnections, GlobalEventBus2:Subscribe(p, fn))
	end

	local changed = self._searchBar.Changed
	table.insert(self._connections, changed:Connect(function(p)
		bus:Publish("Search:Changed", p)
	end))
	table.insert(self._busConnections, bus:Subscribe("Search:Changed", function(p)
		self._container:SetSearchQuery(p)
	end))

	local selected = self._filterBar.Selected
	table.insert(self._connections, selected:Connect(function(p)
		bus:Publish("Filter:GenreChanged", p)
	end))
	table.insert(self._busConnections, bus:Subscribe("Filter:GenreChanged", function(currentTab)
		self._currentTab = currentTab
		self:_applyFilters()
	end))

	local selected2 = self._container.Selected
	table.insert(self._connections, selected2:Connect(function(p, p2)
		bus:Publish("Song:Selected", p, p2)
	end))
	table.insert(self._busConnections, bus:Subscribe("Song:Selected", function(currentDetailSongId, p)
		self._currentDetailSongId = currentDetailSongId

		if currentDetailSongId and p then
			self._detailPanel:ShowSong(p)

			self._detailPanel:SetInstrumentStates(self._container:GetInstrumentStates(currentDetailSongId))
		else
			self._detailPanel:ShowEmpty()
		end

		self._selectedEvent:Fire(currentDetailSongId, p)
	end))

	local playRequested = self._detailPanel.PlayRequested
	table.insert(self._connections, playRequested:Connect(function()
		if self._currentDetailSongId then
			self._playRequestedEvent:Fire(self._currentDetailSongId, self._detailPanel:GetFillEmptyBackingTrack())
		end
	end))

	local inviteRequested = self._detailPanel.InviteRequested
	table.insert(self._connections, inviteRequested:Connect(function(p)
		self._inviteRequestedEvent:Fire(p)
	end))

	local cancelInviteRequested = self._detailPanel.CancelInviteRequested
	table.insert(self._connections, cancelInviteRequested:Connect(function(p)
		self._cancelInviteRequestedEvent:Fire(p)
	end))
	local kickRequested = self._detailPanel.KickRequested
	table.insert(self._connections, kickRequested:Connect(function(p)
		self._kickRequestedEvent:Fire(p)
	end))

	local function fn(p)
		GlobalEventBus:Publish("Favorite:RequestToggle", p)
	end

	connect(self._container.FavoriteToggled, fn) -- inferred equivalent call

	local function fn2()
		if self._currentDetailSongId then
			GlobalEventBus:Publish("Favorite:RequestToggle", self._currentDetailSongId)
		end
	end

	connect(self._detailPanel.FavoriteToggled, fn2) -- inferred equivalent call
	table.insert(self._busConnections, GlobalEventBus:Subscribe("Favorite:Changed", function(p, p2)
		self._container:SetFavorite(p, p2)

		if self._currentDetailSongId == p then
			self._detailPanel:SetFavorite(p2)
		end

		self._favoriteToggledEvent:Fire(p, p2)
	end))

	local v = {}

	local function fn3(list)
		local v2 = {}

		for i, item in ipairs(list) do
			v2[item] = i
		end

		for k, v3 in pairs(v2) do
			self._container:SetField(k, "recentlyPlayedRank", v3)
		end

		for k in pairs(v) do
			if not v2[k] then
				self._container:SetField(k, "recentlyPlayedRank", nil)
			end
		end

		local set = {}

		for k in pairs(v2) do
			set[k] = true
		end

		v = set
	end

	subscribe(GlobalEventBus, "RecentlyPlayed:Changed", fn3) -- inferred equivalent call
	local visibleCountChanged = self._container.VisibleCountChanged
	table.insert(self._connections, visibleCountChanged:Connect(function(p, p2)
		bus:Publish("List:VisibleCountChanged", p, p2)
	end))
	table.insert(self._busConnections, bus:Subscribe("List:VisibleCountChanged", function(p, p2)
		if p == p2 then
			self._countLabel.Text = string.format("%d Songs", p2)
		else
			self._countLabel.Text = string.format("Showing %d / %d", p, p2)
		end
	end))
end

function MainSongListUI:SetViewInstrument(p)
	self._container:SetViewInstrument(p)
end

function MainSongListUI:SetSongs(p)
	self._container:SetSongs(p)

	local uniqueGenres = self._container:GetUniqueGenres()
	table.insert(uniqueGenres, 2, "Recently Played")
	table.insert(uniqueGenres, 3, "Favorite")
	self._filterBar:SetItems(uniqueGenres)
end

function MainSongListUI:UpdateSong(p, p2)
	self._container:UpdateSong(p, p2)
end

function MainSongListUI:SetBestScores(p)
	self._container:SetBestScores(p)
end

function MainSongListUI:SetSongStars(p)
	self._container:SetSongStars(p)
end

function MainSongListUI:SetInstrumentStars(p)
	self._container:SetInstrumentStars(p)
	local selectedSong = self._container:GetSelectedSong()

	local song = selectedSong and self._container:GetSong(selectedSong)

	if song then
		self._detailPanel:SetInstrumentStars(song.instrumentStars)
	end
end

function MainSongListUI:SetInstrumentStates(p, p2)
	self._container:SetInstrumentStates(p, p2)
	local currentDetailSongId = self._currentDetailSongId

	if currentDetailSongId then
		self._detailPanel:SetInstrumentStates(self._container:GetInstrumentStates(currentDetailSongId))
	end
end

function MainSongListUI:SetPlayCounts(p)
	self._container:SetPlayCounts(p)
	local selectedSong = self._container:GetSelectedSong()

	local song = selectedSong and self._container:GetSong(selectedSong)

	if song then
		self._detailPanel:SetPlayCount(song.playCount)
	end
end

function MainSongListUI:SetInstrumentFilter(p)
	self._container:SetInstrumentFilter(p)
end

function MainSongListUI:SelectSong(p)
	self._container:SelectSong(p)
end

function MainSongListUI:GetSelectedSongId()
	return (self._container:GetSelectedSong())
end

function MainSongListUI:RevealSong(p): boolean
	local container = self._container

	if not container:GetSong(p) then
		return false
	end

	if not container:IsSongVisible(p) then
		self._searchBar:SetText("")
		container:SetSearchQuery("")
		self._selectedPlayerCount = nil
		self._refreshPlayerCountBoxes(nil)
		self._selectedDifficulty = nil
		self._refreshDifficultyChips(nil)
		self._currentTab = "All"
		self._filterBar:SetSelected("All", true)
		self:_applyFilters()

		if not container:IsSongVisible(p) then
			return false
		end
	end

	container:SelectSong(p)
	container:ScrollToSong(p)
	return true
end

function MainSongListUI:SetInstrumentOccupant(p, p2, p3)
	self._detailPanel:SetInstrumentOccupant(p, p2, p3)
end

function MainSongListUI:SetInstrumentIsMine(p, p2)
	self._detailPanel:SetInstrumentIsMine(p, p2)
end

function MainSongListUI:SetInstrumentIsHost(p, p2)
	self._detailPanel:SetInstrumentIsHost(p, p2)
end

function MainSongListUI:SetInstrumentRawOccupant(p, p2)
	self._detailPanel:SetInstrumentRawOccupant(p, p2)
end

function MainSongListUI:SetPartyStatus(p, p2)
	self._detailPanel:SetPartyStatus(p, p2)
end

function MainSongListUI:SetHostControls(p)
	self._detailPanel:SetHostControls(p)
end

function MainSongListUI:SetPlayBlocked(p)
	self._detailPanel:SetPlayBlocked(p)
end

function MainSongListUI:SetPlayMode(p, p2, p3)
	self._detailPanel:SetPlayMode(p, p2, p3)
end

function MainSongListUI:SetPlayNotice(p)
	self._detailPanel:SetPlayNotice(p)
end

function MainSongListUI:SetStagePlayerCount(p)
	self._setStagePlayerCount(p)
end

function MainSongListUI:SetFillHintAllowed(p)
	self._detailPanel:SetFillHintAllowed(p)
end

function MainSongListUI:SetFillOptionVisible(p)
	self._detailPanel:SetFillOptionVisible(p)
end

function MainSongListUI:SetPreviewLoading(p, p2)
	self._container:SetPreviewLoading(p, p2)

	if p == self._currentDetailSongId then
		self._detailPanel:SetPlayButtonLoading(p2)
	end
end

function MainSongListUI:SetSessionInfo(text)
	if text and text ~= "" then
		self._sessionInfoLabel.Text = text
		self._sessionInfoLabel.Visible = true
	else
		self._sessionInfoLabel.Text = ""
		self._sessionInfoLabel.Visible = false
	end

	self:_refreshSessionJoin()
end

function MainSongListUI:SetSessionJoin(sessionJoinSongId, sessionJoinLabel)
	self._sessionJoinSongId = sessionJoinSongId
	self._sessionJoinLabel = sessionJoinLabel
	self:_refreshSessionJoin()
end

function MainSongListUI:_refreshSessionJoin()
	local sessionJoinButton = self._sessionJoinButton

	if not sessionJoinButton then
		return
	end

	local v

	if self._sessionJoinSongId == nil then
		v = false
	else
		v = self._sessionInfoLabel.Visible
	end

	sessionJoinButton.Visible = v and true or false

	if v then
		sessionJoinButton.Text = self._sessionJoinLabel or "Join"
	end

	self._updateSessionInfoMax()
end

function MainSongListUI:SetPartyRoomStatus(p, p2)
	if p2 then
		self._partyRoomLabel.Text = "your room"
		self._partyExitButton.Text = "Close Room"
		self._partyStatusGroup.Visible = true
	elseif p and p ~= "" then
		self._partyRoomLabel.Text = string.format("in \"%s\"'s room", p)
		self._partyExitButton.Text = "Exit"
		self._partyStatusGroup.Visible = true
	else
		self._partyRoomLabel.Text = ""
		self._partyExitButton.Text = "Exit"
		self._partyStatusGroup.Visible = false
	end
end

function MainSongListUI:SetHeaderToggleState(p, p2)
	if not self._headerToggle then
		return
	end

	self._headerToggle:SetState(p, p2)
end

function MainSongListUI:Destroy()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	self._connections = {}

	for _, busConnection in ipairs(self._busConnections) do
		busConnection.Disconnect()
	end

	self._busConnections = {}

	self._bus:Destroy()

	self._searchBar:Destroy()
	self._filterBar:Destroy()
	self._container:Destroy()
	self._detailPanel:Destroy()

	self.Instance:Destroy()

	self._bus = nil
	self._searchBar = nil
	self._filterBar = nil
	self._container = nil
	self._detailPanel = nil
	self._countLabel = nil
	self._sessionInfoLabel = nil
	self._sessionInfoRow = nil
	self._sessionJoinButton = nil
	self._updateSessionInfoMax = nil
	self._headerToggle = nil
	self._sortToggle = nil
	self._currentDetailSongId = nil
end

return MainSongListUI