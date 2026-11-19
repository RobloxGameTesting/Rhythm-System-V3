local TweenService = game:GetService("TweenService")
local StarConfig = require(script.Parent.Parent:WaitForChild("StarConfig"))
local StyledTheme = require(script.Parent.StyledTheme)
local DifficultyBadge = require(script.Parent.DifficultyBadge)
local FavoriteButton = require(script.Parent.FavoriteButton)
local InstrumentIndicator = require(script.Parent.InstrumentIndicator)

local SongCard = {}
SongCard.__index = SongCard

local UserInputService = game:GetService("UserInputService")
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v2 = v and 20 or StyledTheme.Sizes.IconButtonSize
local v3 = v and 15 or StyledTheme.Sizes.ControlHeightS
local ControlHeightS = StyledTheme.Sizes.ControlHeightS

local controlHeightS = StyledTheme.Sizes.ControlHeightS

local v4 = v and 1 or StyledTheme.Spacing.XS
local v5 = v and 4 or StyledTheme.Spacing.M
local l = StyledTheme.Spacing.L
local v6 = StyledTheme.Stroke.Thickness * 2
local ControlHeightL = StyledTheme.Sizes.ControlHeightL

local function formatDuration(p)
	if not p then
		return "--:--"
	end

	local v7 = math.floor(p / 60)
	local v8 = p % 60
	return string.format("%d:%02d", v7, v8)
end

local function buildInfoLine(genre, bpm, duration)
	local v7 = {}

	if genre then
		table.insert(v7, genre)
	end

	if bpm then
		table.insert(v7, bpm .. " BPM")
	end

	table.insert(v7, formatDuration(duration))
	return table.concat(v7, "  •  ")
end

local function createSessionText(textButton)
	local sessionText = Instance.new("TextLabel")
	sessionText.Name = "SessionText"
	sessionText.BackgroundTransparency = 1
	sessionText.Size = UDim2.new(1, 0, 0, controlHeightS)
	sessionText.Font = StyledTheme.Fonts.Regular
	sessionText.TextSize = StyledTheme.TextSize.S
	sessionText.TextColor3 = StyledTheme.Colors.Success
	sessionText.TextXAlignment = Enum.TextXAlignment.Left
	sessionText.TextYAlignment = Enum.TextYAlignment.Center
	sessionText.TextTruncate = Enum.TextTruncate.AtEnd
	sessionText.Parent = textButton
	return sessionText
end

local function escapeRich(text) -- 1 equivalent call inferred from this helper
	return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function buildNoticeText(chartNotice)
	local v7 = {}

	for _, v8 in ipairs(chartNotice.segments or {}) do
		local v9 = escapeRich(v8.text or "") -- inferred equivalent call

		if v8.bold then
			v9 = "<b>" .. v9 .. "</b>"
		end

		table.insert(v7, string.format("<font color=\"#%s\">%s</font>", v8.color:ToHex(), v9))
	end

	return table.concat(v7)
end

local function difficultyOf(p) -- 4 equivalent calls inferred from this helper
	local displayDifficulty = p.displayDifficulty

	if displayDifficulty == nil then
		return p.difficulty
	end

	return displayDifficulty
end

local function computeHeight(p) -- 1 equivalent call inferred from this helper
	local v7 = DifficultyBadge.WillRender(difficultyOf(p)) -- inferred equivalent call

	local isInSession = p.isInSession or false

	local selected = p.chartNotice ~= nil

	local v8 = v2 + v4 + v3

	if selected then
		v8 += v4 + 36
	end

	if isInSession then
		v8 += v4 + controlHeightS
	end

	return v8 + v5 * 2, v7, false, isInSession, selected
end

function SongCard.GetHeightFor(options)
	local v7 = options or {}
	DifficultyBadge.WillRender(difficultyOf(v7)) -- inferred equivalent call

	local isInSession = v7.isInSession or false

	local v8 = v7.chartNotice ~= nil

	local v9 = v2 + v4 + v3

	if v8 then
		v9 += v4 + 36
	end

	if isInSession then
		v9 += v4 + controlHeightS
	end

	return v9 + v5 * 2
end

local TextService = game:GetService("TextService")
local s = StyledTheme.TextSize.S

local function formatScore(lastScore) -- 1 equivalent call inferred from this helper
	return (tostring((math.floor((lastScore or 0) + 0.5))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function applyBestScore(state, lastScore, lastStars)
	state._lastScore = lastScore
	state._lastStars = lastStars
	local best = state._best
	local v7 = type(lastStars) == "number" and math.clamp(math.floor(lastStars), 0, StarConfig.MaxStars) or 0
	local richText = StarConfig.RichText(
		v7,
		StyledTheme.Colors.Accent:ToHex(),
		StyledTheme.Colors.TextSecondary:ToHex()
	)
	local v8

	if type(lastScore) == "number" then
		v8 = lastScore > 0
	else
		v8 = false
	end

	local v9 = v8 and formatScore(lastScore) or "--" -- inferred equivalent call
	local accent = v8 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextSecondary
	best.Text = string.format(
		"%s  <font color=\"#%s\">YOUR BEST</font>  <font color=\"#%s\"><b>%s</b></font>",
		richText,
		StyledTheme.Colors.TextSecondary:ToHex(),
		accent:ToHex(),
		v9
	)

	local v10 = TextService:GetTextSize(
		StarConfig.PlainText() .. "  YOUR BEST  " .. v9,
		s,
		StyledTheme.Fonts.Regular,
		Vector2.new(1000, 40)
	).X + 6
	best.Size = UDim2.new(0, v10, 0, v3)
	local indicatorWidth = state._indicatorWidth or ControlHeightL
	local s2 = indicatorWidth > 0 and StyledTheme.Spacing.S or 0

	best.Position = UDim2.new(1, -(l + indicatorWidth + s2), 0, v5 + v2 + v4 + v3 / 2)
	state._info.Size = UDim2.new(1, -(l * 2 + indicatorWidth + s2 + StyledTheme.Spacing.S + v10), 0, v3)
end

local function applyData(object, options, p)
	local v7 = options or {}
	local height, v8, visible, visible2, visible3 = computeHeight(v7) -- inferred equivalent call
	local isInSession = v7.isInSession or false

	local instance = object.Instance
	instance.Name = v7.songId or "SongCard"
	instance.Size = UDim2.new(1, 0, 0, height)

	local text = v7.displayName or v7.songId or ""

	if v7.artist and v7.artist ~= "" then
		text = v7.artist .. " - " .. text
	end

	object._title.AutoLocalize = false
	object._info.AutoLocalize = false
	object._best.AutoLocalize = false
	object._sessionText.AutoLocalize = false
	object._title.Text = text

	local v9 = v5 + v2 + v4
	object._info.Text = buildInfoLine(v7.genre, v7.bpm, v7.duration)

	if v7.instrumentAvailability then
		object._indicatorWidth = InstrumentIndicator.GetWidth(v7.instrumentAvailability, v7.instrumentOrder)
	else
		object._indicatorWidth = 0
	end

	applyBestScore(object, v7.bestScore, v7.stars)

	object._lastAvailability = v7.instrumentAvailability
	object._lastOrder = v7.instrumentOrder
	object._instrumentStates = v7.instrumentStates

	if v7.instrumentAvailability then
		if object._indicator then
			InstrumentIndicator.Update(
				object._indicator,
				v7.instrumentAvailability,
				v7.instrumentOrder,
				v7.instrumentStates
			)
		else
			local indicator = InstrumentIndicator.Create(
				instance,
				v7.instrumentAvailability,
				2,
				v7.instrumentOrder,
				v7.instrumentStates
			)
			indicator.AnchorPoint = Vector2.new(1, 0.5)
			indicator.Position = UDim2.new(1, -l, 0, v9 + v3 / 2)
			object._indicator = indicator
		end
	elseif object._indicator then
		object._indicator:Destroy()
		object._indicator = nil
	end

	local v10 = v9 + v3 + v4
	object._notice.Visible = visible3

	if visible3 then
		object._notice.Position = UDim2.new(0, l, 0, v10)
		object._notice.Text = buildNoticeText(v7.chartNotice)
		v10 += 36 + v4
	end

	object._badgeRow.Position = UDim2.new(0, l, 0, v10)
	object._badgeRow.Visible = visible

	local v11 = v8 and DifficultyBadge.DotSize + StyledTheme.Spacing.S or 0
	object._title.Position = UDim2.new(0, l + v11, 0, v5)
	object._title.Size = UDim2.new(1, -(l * 2 + StyledTheme.Sizes.IconButtonSize + StyledTheme.Spacing.S + v11), 0, v2)

	if v8 then
		if object._badge then
			DifficultyBadge.Update(object._badge, difficultyOf(v7)) -- inferred equivalent call
		else
			object._badge = DifficultyBadge.Create(instance, difficultyOf(v7), 0) -- inferred equivalent call
			object._badge.AnchorPoint = Vector2.new(0, 0.5)
		end

		object._badge.Position = UDim2.new(0, l, 0, v5 + v2 / 2)
	elseif object._badge then
		object._badge:Destroy()
		object._badge = nil
	end

	object._sessionText.Visible = visible2

	if visible2 then
		if visible then
			v10 += ControlHeightS + v4
		end

		object._sessionText.Position = UDim2.new(0, l, 0, v10)
		object._sessionText.Text = v7.sessionText or ""
	end

	object._favorite:Set(v7.isFavorite or false)

	object:SetPreviewLoading(v7.isPreviewLoading or false)

	object._setInSession(isInSession, p)

	object._resetInteraction(p)
end

function SongCard.new(parent, options)
	local v7 = options or {}

	local textButton = Instance.new("TextButton")
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = StyledTheme.Colors.Surface
	textButton.Size = UDim2.new(1, 0, 0, SongCard.GetHeightFor(v7))
	textButton.LayoutOrder = v7.layoutOrder or 0
	textButton.ClipsDescendants = true
	textButton.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Large
	uiCorner.Parent = textButton

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = StyledTheme.Stroke.Thickness
	uiStroke.Color = StyledTheme.Colors.Accent
	uiStroke.Transparency = 1
	uiStroke.Parent = textButton

	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.BackgroundColor3 = StyledTheme.Colors.Accent
	accentBar.BorderSizePixel = 0
	accentBar.Size = UDim2.new(0, v6, 1, 0)
	accentBar.Position = UDim2.new(0, 0, 0, 0)
	accentBar.BackgroundTransparency = 1
	accentBar.ZIndex = StyledTheme.ZIndex.Content
	accentBar.Parent = textButton

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, l, 0, v5)

	title.Size = UDim2.new(1, -(l * 2 + StyledTheme.Sizes.IconButtonSize + StyledTheme.Spacing.S), 0, v2)
	title.Font = StyledTheme.Fonts.Bold
	title.TextSize = v and 13 or StyledTheme.TextSize.XXL
	title.TextColor3 = StyledTheme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = textButton

	local favorite = FavoriteButton.new(textButton, {
		initial = v7.isFavorite or false
	})

	favorite.Instance.Position = UDim2.new(
		1,
		-(l + StyledTheme.Sizes.IconButtonSize),
		0,
		v5 + (v2 - StyledTheme.Sizes.IconButtonSize) / 2
	)
	favorite.Instance.ZIndex = StyledTheme.ZIndex.Raised

	local previewLoadingIcon = Instance.new("TextLabel")
	previewLoadingIcon.Name = "PreviewLoadingIcon"
	previewLoadingIcon.BackgroundTransparency = 1
	previewLoadingIcon.AnchorPoint = Vector2.new(1, 0.5)
	previewLoadingIcon.AutomaticSize = Enum.AutomaticSize.X
	previewLoadingIcon.Size = UDim2.new(0, 0, 0, 14)
	previewLoadingIcon.Position = UDim2.new(1, -46, 0.5, 0)
	previewLoadingIcon.Font = StyledTheme.Fonts.Medium
	previewLoadingIcon.TextSize = StyledTheme.TextSize.S
	previewLoadingIcon.TextColor3 = StyledTheme.Colors.Accent
	previewLoadingIcon.TextXAlignment = Enum.TextXAlignment.Right
	previewLoadingIcon.Text = "Loading..."
	previewLoadingIcon.Visible = false
	previewLoadingIcon.ZIndex = StyledTheme.ZIndex.Raised
	previewLoadingIcon.Parent = textButton

	local count = 0

	local v8 = v5 + v2 + v4
	local info = Instance.new("TextLabel")
	info.Name = "Info"
	info.BackgroundTransparency = 1
	info.Position = UDim2.new(0, l, 0, v8)
	info.Size = UDim2.new(1, -(l * 2 + ControlHeightL + StyledTheme.Spacing.S), 0, v3)
	info.Font = StyledTheme.Fonts.Regular
	info.TextSize = v and 10 or StyledTheme.TextSize.M
	info.TextColor3 = StyledTheme.Colors.TextSecondary
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextTruncate = Enum.TextTruncate.AtEnd
	info.Parent = textButton

	local v9 = v8 + v3 + v4
	local badgeRow = Instance.new("Frame")
	badgeRow.Name = "BadgeRow"
	badgeRow.BackgroundTransparency = 1
	badgeRow.Position = UDim2.new(0, l, 0, v9)
	badgeRow.Size = UDim2.new(1, -(l * 2), 0, ControlHeightS)
	badgeRow.Visible = false
	badgeRow.Parent = textButton

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, StyledTheme.Spacing.XS)
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = badgeRow

	local sessionText = createSessionText(textButton)
	sessionText.Position = UDim2.new(0, l, 0, v9)
	sessionText.Size = UDim2.new(1, -(l * 2), 0, controlHeightS)
	sessionText.Visible = false

	local chartNotice = Instance.new("TextLabel")
	chartNotice.Name = "ChartNotice"
	chartNotice.BackgroundTransparency = 1
	chartNotice.Position = UDim2.new(0, l, 0, v9)
	chartNotice.Size = UDim2.new(1, -(l * 2), 0, 36)
	chartNotice.Font = StyledTheme.Fonts.Regular
	chartNotice.TextSize = StyledTheme.TextSize.S
	chartNotice.TextColor3 = StyledTheme.Colors.TextSecondary
	chartNotice.TextXAlignment = Enum.TextXAlignment.Left
	chartNotice.TextYAlignment = Enum.TextYAlignment.Top
	chartNotice.TextWrapped = true
	chartNotice.TextTruncate = Enum.TextTruncate.AtEnd
	chartNotice.RichText = true
	chartNotice.Visible = false
	chartNotice.Parent = textButton

	local bestScore = Instance.new("TextLabel")
	bestScore.Name = "BestScore"
	bestScore.BackgroundTransparency = 1
	bestScore.AnchorPoint = Vector2.new(1, 0.5)
	bestScore.Position = UDim2.new(1, -(l + ControlHeightL + StyledTheme.Spacing.S), 0, v8 + v3 / 2)
	bestScore.Size = UDim2.new(0, 120, 0, v3)
	bestScore.Font = StyledTheme.Fonts.Regular
	bestScore.TextSize = s
	bestScore.TextColor3 = StyledTheme.Colors.TextSecondary
	bestScore.TextXAlignment = Enum.TextXAlignment.Right
	bestScore.RichText = true
	bestScore.Text = ""
	bestScore.Parent = textButton

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = textButton
	local v10 = false
	local flag = false
	local v11 = false

	local v12 = {}
	local function cancelTweens() -- 1 equivalent call inferred from this helper
		for _, v13 in ipairs(v12) do
			v13:Cancel()
		end

		table.clear(v12)
	end

	local function refreshVisual(p)
		local backgroundColor = StyledTheme.Colors.Surface
		local transparency = 1
		local color = StyledTheme.Colors.Accent

		local backgroundColor2 = StyledTheme.Colors.Accent

		local v13 = StyledTheme.Animation.Normal
		local backgroundTransparency

		if v11 then
			backgroundColor2 = StyledTheme.Colors.Success
			backgroundTransparency = StyledTheme.Stroke.TransparencyActive
		else
			backgroundTransparency = 1
		end

		if v10 then
			backgroundColor = StyledTheme.Colors.SurfaceSelected
			transparency = StyledTheme.Stroke.TransparencyActive
			color = v11 and StyledTheme.Colors.Success or StyledTheme.Colors.Accent
		elseif flag then
			backgroundColor = StyledTheme.Colors.SurfaceHover

			transparency = StyledTheme.Stroke.TransparencyActive

			if not v11 then
				backgroundTransparency = StyledTheme.Stroke.TransparencyActive
			end

			v13 = StyledTheme.Animation.Fast
		end

		cancelTweens() -- inferred equivalent call

		if p then
			textButton.BackgroundColor3 = backgroundColor
			uiStroke.Transparency = transparency
			uiStroke.Color = color
			accentBar.BackgroundTransparency = backgroundTransparency
			accentBar.BackgroundColor3 = backgroundColor2
		else
			local tweenInfo = TweenInfo.new(
				v13,
				StyledTheme.Animation.EasingStyle,
				StyledTheme.Animation.EasingDirection
			)

			v12[1] = TweenService:Create(textButton, tweenInfo, {
				BackgroundColor3 = backgroundColor
			})
			v12[2] = TweenService:Create(uiStroke, tweenInfo, {
				Transparency = transparency,
				Color = color
			})
			v12[3] = TweenService:Create(accentBar, tweenInfo, {
				BackgroundTransparency = backgroundTransparency,
				BackgroundColor3 = backgroundColor2
			})

			for _, v14 in ipairs(v12) do
				v14:Play()
			end
		end
	end

	textButton.MouseEnter:Connect(function()
		flag = true
		refreshVisual()
	end)

	textButton.MouseLeave:Connect(function()
		flag = false
		refreshVisual()
	end)

	textButton.MouseButton1Click:Connect(function()
		bindableEvent:Fire()
	end)
	local self = setmetatable({
		Instance = textButton,
		Clicked = bindableEvent.Event,
		FavoriteToggled = favorite.Toggled,
		_favorite = favorite,
		_loadingIcon = previewLoadingIcon,
		_loadingDotFrames = { "Loading", "Loading.", "Loading..", "Loading..." },
		_getLoadingGeneration = function()
			return count
		end,
		_bumpLoadingGeneration = function()
			count += 1
			return count
		end,
		_title = title,
		_info = info,
		_badgeRow = badgeRow,
		_badge = nil,
		_indicator = nil,
		_sessionText = sessionText,
		_notice = chartNotice,
		_best = bestScore,
		_setSelected = function(p, p2)
			v10 = p
			refreshVisual(p2)
		end,
		_setInSession = function(p, p2)
			v11 = p
			refreshVisual(p2)
		end,
		_resetInteraction = function(p)
			v10 = false
			flag = false
			refreshVisual(p)
		end
	}, SongCard)

	applyData(self, v7)

	return self
end

function SongCard.SetData(p, p2, p3)
	applyData(p, p2, p3)
end

function SongCard:SetSelected(p, p2)
	self._setSelected(p, p2)
end

function SongCard:GetFavorite()
	return self._favorite:Get()
end

function SongCard:SetFavorite(p)
	self._favorite:Set(p)
end

function SongCard:SetBestScore(lastScore)
	applyBestScore(self, lastScore, self._lastStars)
end

function SongCard:SetStars(lastStars)
	applyBestScore(self, self._lastScore, lastStars)
end

function SongCard:SetInstrumentStates(instrumentStates)
	self._instrumentStates = instrumentStates

	if self._indicator and self._lastAvailability then
		InstrumentIndicator.Update(self._indicator, self._lastAvailability, self._lastOrder, instrumentStates)
	end
end

function SongCard:SetPreviewLoading(visible)
	self._loadingIcon.Visible = visible
	local v7 = self._bumpLoadingGeneration()

	if visible then
		local loadingIcon = self._loadingIcon
		local loadingDotFrames = self._loadingDotFrames
		local getLoadingGeneration = self._getLoadingGeneration
		task.spawn(function()
			local v8 = 1

			while getLoadingGeneration() == v7 do
				loadingIcon.Text = loadingDotFrames[v8]
				v8 = v8 % #loadingDotFrames + 1
				task.wait(0.35)
			end
		end)
	end
end

function SongCard:Destroy()
	self.Instance:Destroy()
end

return SongCard