local StyledTheme = require(script.Parent.StyledTheme)
local SongCard = require(script.Parent.SongCard)
local DifficultyBadge = require(script.Parent.DifficultyBadge)

local SongListContainer = {}
SongListContainer.__index = SongListContainer

local function defaultComparator(data, data2): boolean
	local displayName = string.lower(data.displayName or data.songId or "")
	local displayName2 = string.lower(data2.displayName or data2.songId or "")
	local v

	if data.artist and data.artist ~= "" then
		v = string.lower(data.artist) or displayName
	else
		v = displayName
	end

	local v2

	if data2.artist and data2.artist ~= "" then
		v2 = string.lower(data2.artist) or displayName2
	else
		v2 = displayName2
	end

	if v == v2 then
		return displayName < displayName2
	end

	return v < v2
end

local function mainGenreOf(genre) -- 2 equivalent calls inferred from this helper
	if type(genre) ~= "string" then
		return nil
	end

	local v = (genre:match("^(.-)%s+%-%s+") or genre):gsub("^%s+", ""):gsub("%s+$", "")
	return if v ~= "" then v else nil
end

local function buildSearchBlob(data)
	return string.lower(table.concat({
		data.displayName or "",
		data.artist or "",
		data.genre or "",
		data.mood or "",
		type(data.displayDifficulty) == "string" and data.displayDifficulty or ""
	}, " "))
end

local function refreshDerived(p, viewInstrument) -- 4 equivalent calls inferred from this helper
	p.displayDifficulty = DifficultyBadge.TierFor(p, viewInstrument) or false
	p._searchBlob = buildSearchBlob(p)
end

local function lowerBound(rowTops, p)
	local v = #rowTops + 1
	local v2 = 1

	while v2 < v do
		local v3 = (v2 + v) // 2

		if p <= rowTops[v3] then
			v = v3
		else
			v2 = v3 + 1
		end
	end

	return v2
end

function SongListContainer.new(parent, options)
	local v = options or {}

	local songListContainer = Instance.new("Frame")
	songListContainer.Name = "SongListContainer"
	songListContainer.BackgroundTransparency = 1
	songListContainer.Size = v.size or UDim2.new(1, 0, 1, 0)
	songListContainer.LayoutOrder = v.layoutOrder or 0

	songListContainer.ClipsDescendants = true
	songListContainer.Parent = parent

	local viewport = Instance.new("ScrollingFrame")
	viewport.Name = "Viewport"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.new(1, 0, 1, 0)
	viewport.CanvasSize = UDim2.new(0, 0, 0, 0)
	viewport.ScrollingDirection = Enum.ScrollingDirection.Y
	viewport.ScrollBarThickness = StyledTheme.Sizes.ScrollBarThickness
	viewport.ScrollBarImageColor3 = StyledTheme.Colors.TextSecondary

	viewport.ClipsDescendants = true
	viewport.Parent = songListContainer

	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Name = "EmptyLabel"
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightL)
	emptyLabel.Position = UDim2.new(0, 0, 0, StyledTheme.Spacing.XL)
	emptyLabel.Font = StyledTheme.Fonts.Medium
	emptyLabel.TextSize = StyledTheme.TextSize.L
	emptyLabel.TextColor3 = StyledTheme.Colors.TextSecondary
	emptyLabel.Text = "No songs found."
	emptyLabel.Visible = false
	emptyLabel.Parent = songListContainer

	local rowGap = v.rowGap or StyledTheme.Spacing.XS
	local sidePadding = v.sidePadding or 0

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = songListContainer
	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Parent = songListContainer
	local bindableEvent3 = Instance.new("BindableEvent")
	bindableEvent3.Parent = songListContainer

	local object = setmetatable({
		Instance = songListContainer,
		Selected = bindableEvent.Event,
		FavoriteToggled = bindableEvent2.Event,
		VisibleCountChanged = bindableEvent3.Event,
		_viewport = viewport,
		_emptyLabel = emptyLabel,
		_rowGap = rowGap,
		_sidePadding = sidePadding,
		_rowTops = {},
		_selectedEvent = bindableEvent,
		_favoriteToggledEvent = bindableEvent2,
		_visibleCountChangedEvent = bindableEvent3,
		_records = {},
		_baseOrder = {},
		_visibleOrder = {},
		_searchQuery = "",
		_searchTokens = {},
		_genreFilter = nil,
		_instrumentFilter = nil,
		_viewInstrument = nil,
		_favoriteOnly = false,
		_customPredicate = nil,
		_comparator = defaultComparator,
		_selectedSongId = nil,
		_pool = {},
		_viewportConnections = {}
	}, SongListContainer)

	table.insert(object._viewportConnections, viewport:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		object:_renderWindow()
	end))
	table.insert(object._viewportConnections, viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object:_renderWindow()
	end))

	return object
end

function SongListContainer:SetSongs(list)
	local clonesBySongId = {}
	local songIds = {}

	for _, item in ipairs(list) do
		local clone = table.clone(item)
		refreshDerived(clone, self._viewInstrument) -- inferred equivalent call
		clonesBySongId[clone.songId] = clone
		table.insert(songIds, clone.songId)
	end

	self._records = clonesBySongId
	self._baseOrder = songIds

	if self._selectedSongId and not clonesBySongId[self._selectedSongId] then
		self:ClearSelection()
	end

	self:_recomputeVisibleOrder()
end

function SongListContainer:SetFavorite(p, isFavorite)
	local record = self._records[p]

	if not record or record.isFavorite == isFavorite then
		return
	end

	record.isFavorite = isFavorite

	if self._favoriteOnly then
		self:_recomputeVisibleOrder()
		return
	end

	for _, v in ipairs(self._pool) do
		if v.boundSongId == p then
			v.card:SetFavorite(isFavorite)
			break
		end
	end
end

function SongListContainer:UpdateSong(p, items)
	local record = self._records[p]

	if not record then
		return
	end

	for k, item in pairs(items) do
		record[k] = item
	end

	refreshDerived(record, self._viewInstrument) -- inferred equivalent call

	for _, v in ipairs(self._pool) do
		if v.boundSongId == p then
			record.instrumentStates = self:GetInstrumentStates(p)
			v.card:SetData(record)
			break
		end
	end

	self:_recomputeVisibleOrder()
end

function SongListContainer:SetBestScores(options)
	local v = options or {}

	for k, record in pairs(self._records) do
		record.bestScore = v[k]
	end

	for _, v2 in ipairs(self._pool) do
		if not v2.boundSongId then
			continue
		end

		local record = self._records[v2.boundSongId]

		if record then
			v2.card:SetBestScore(record.bestScore)
		end
	end
end

function SongListContainer:SetSongStars(options)
	local v = options or {}

	for k, record in pairs(self._records) do
		record.stars = v[k]
	end

	for _, v2 in ipairs(self._pool) do
		if not v2.boundSongId then
			continue
		end

		local record = self._records[v2.boundSongId]

		if record then
			v2.card:SetStars(record.stars)
		end
	end
end

function SongListContainer:SetInstrumentStars(options)
	local v = options or {}

	for k, record in pairs(self._records) do
		record.instrumentStars = v[k]
	end
end

function SongListContainer:SetInstrumentStates(options, options2)
	self._playingStates = options or {}
	self._equippedStates = options2 or {}

	for _, v in ipairs(self._pool) do
		if v.boundSongId then
			v.card:SetInstrumentStates(self:GetInstrumentStates(v.boundSongId))
		end
	end
end

function SongListContainer:GetInstrumentStates(p)
	local instrumentStates = {}

	for k, v in pairs(self._equippedStates or {}) do
		instrumentStates[k] = v
	end

	local v = self._playingStates and self._playingStates[p]

	if v then
		for k, v2 in pairs(v) do
			instrumentStates[k] = v2
		end
	end

	return instrumentStates
end

function SongListContainer:SetPlayCounts(p)
	for k, record in pairs(self._records) do
		if p == nil then
			record.playCount = nil
		else
			record.playCount = p[k] or 0
		end
	end
end

function SongListContainer:SetField(p, p2, p3)
	local record = self._records[p]

	if not record then
		return
	end

	record[p2] = p3
	refreshDerived(record, self._viewInstrument) -- inferred equivalent call

	self:_recomputeVisibleOrder()
end

function SongListContainer:SetSearchQuery(value)
	self._searchQuery = string.lower(value or "")
	local searchTokens = {}

	for k in string.gmatch(self._searchQuery, "%S+") do
		table.insert(searchTokens, k)
	end

	self._searchTokens = searchTokens
	self:_recomputeVisibleOrder()
end

function SongListContainer:SetGenreFilter(genreFilter)
	self._genreFilter = genreFilter
	self:_recomputeVisibleOrder()
end

function SongListContainer:SetViewInstrument(viewInstrument)
	if type(viewInstrument) ~= "string" then
		viewInstrument = nil
	end

	if self._viewInstrument == viewInstrument then
		return
	end

	self._viewInstrument = viewInstrument

	for _, record in pairs(self._records) do
		refreshDerived(record, viewInstrument) -- inferred equivalent call
	end

	for _, v in ipairs(self._pool) do
		local boundSongId = v.boundSongId
		local v2 = boundSongId and self._records[boundSongId]

		if not v2 then
			continue
		end

		v2.instrumentStates = self:GetInstrumentStates(boundSongId)
		v.card:SetData(v2, true)
		v.card:SetSelected(boundSongId == self._selectedSongId, true)
	end

	self:_recomputeVisibleOrder()
end

function SongListContainer:SetInstrumentFilter(instrumentFilter)
	self._instrumentFilter = instrumentFilter
	self:_recomputeVisibleOrder()
end

function SongListContainer:SetPreviewLoading(p, isPreviewLoading)
	local record = self._records[p]

	if not record then
		return
	end

	record.isPreviewLoading = isPreviewLoading

	for _, v in ipairs(self._pool) do
		if v.boundSongId == p then
			v.card:SetPreviewLoading(isPreviewLoading)
			break
		end
	end
end

function SongListContainer:SetFavoriteOnly(favoriteOnly)
	self._favoriteOnly = favoriteOnly
	self:_recomputeVisibleOrder()
end

function SongListContainer:SetFilter(customPredicate)
	self._customPredicate = customPredicate
	self:_recomputeVisibleOrder()
end

function SongListContainer:SetSort(p)
	self._comparator = p or defaultComparator
	self:_recomputeVisibleOrder()
end

function SongListContainer:_passesFilters(data): boolean
	if
		self._favoriteOnly and not data.isFavorite
		or self._genreFilter and self._genreFilter ~= "All" and mainGenreOf(data.genre) ~= self._genreFilter -- inferred equivalent call
	then
		return false
	end

	if self._instrumentFilter then
		local instrumentAvailability = data.instrumentAvailability

		if not (instrumentAvailability and instrumentAvailability[self._instrumentFilter]) then
			return false
		end
	end

	local searchTokens = self._searchTokens

	if searchTokens and #searchTokens > 0 then
		local searchBlob = data._searchBlob

		for _, searchToken in ipairs(searchTokens) do
			if not string.find(searchBlob, searchToken, 1, true) then
				return false
			end
		end
	end

	return not (self._customPredicate and not self._customPredicate(data))
end

function SongListContainer:_recomputeVisibleOrder()
	local visibleOrder = {}

	for _, v in ipairs(self._baseOrder) do
		if self:_passesFilters(self._records[v]) then
			table.insert(visibleOrder, v)
		end
	end

	table.sort(visibleOrder, function(a, b)
		local record = self._records[a]
		local record2 = self._records[b]
		local isInSession = record.isInSession == true

		if isInSession == (record2.isInSession == true) then
			return self._comparator(record, record2)
		end

		return isInSession
	end)

	self._visibleOrder = visibleOrder

	local rowTops = {}
	local total = 0

	for i, v in ipairs(visibleOrder) do
		rowTops[i] = total
		total += SongCard.GetHeightFor(self._records[v]) + self._rowGap
	end

	self._rowTops = rowTops

	local v = #visibleOrder > 0 and math.max(0, total - self._rowGap) or 0
	self._viewport.CanvasSize = UDim2.new(0, 0, 0, v)

	self._emptyLabel.Visible = #visibleOrder == 0
	self._visibleCountChangedEvent:Fire(#visibleOrder, #self._baseOrder)
	self:_renderWindow()
end

function SongListContainer:SelectSong(selectedSongId)
	if self._selectedSongId == selectedSongId then
		return
	end

	self._selectedSongId = selectedSongId

	for _, v in ipairs(self._pool) do
		if v.boundSongId then
			v.card:SetSelected(v.boundSongId == selectedSongId)
		end
	end

	self._selectedEvent:Fire(selectedSongId, self._records[selectedSongId])
end

function SongListContainer:ClearSelection()
	if self._selectedSongId == nil then
		return
	end

	self._selectedSongId = nil

	for _, v in ipairs(self._pool) do
		if v.boundSongId then
			v.card:SetSelected(false)
		end
	end

	self._selectedEvent:Fire(nil, nil)
end

function SongListContainer:GetSelectedSong()
	return self._selectedSongId, self._records[self._selectedSongId]
end

function SongListContainer:IsSongVisible(p): boolean
	return table.find(self._visibleOrder, p) ~= nil
end

function SongListContainer:ScrollToSong(p): boolean
	local index = table.find(self._visibleOrder, p)

	if not index then
		return false
	end

	local rowTop = self._rowTops[index]
	local heightFor = SongCard.GetHeightFor(self._records[p])
	local y = self._viewport.AbsoluteWindowSize.Y
	local v = math.max(0, self._viewport.CanvasSize.Y.Offset - y)
	local v2 = math.clamp(rowTop - (y - heightFor) / 2, 0, v)

	self._viewport.CanvasPosition = Vector2.new(0, v2)
	self:_renderWindow()
	return true
end

function SongListContainer:GetSong(p)
	return self._records[p]
end

function SongListContainer:GetUniqueGenres()
	local set = {}
	local uniqueGenres = { "All" }

	for _, v in ipairs(self._baseOrder) do
		local v2 = mainGenreOf(self._records[v].genre) -- inferred equivalent call

		if not v2 or set[v2] then
			continue
		end

		set[v2] = true
		table.insert(uniqueGenres, v2)
	end

	table.sort(uniqueGenres, function(a, b): boolean
		return a == "All" or b ~= "All" and a < b
	end)

	return uniqueGenres
end

function SongListContainer:GetVisibleCount()
	return #self._visibleOrder
end

function SongListContainer:GetTotalCount()
	return #self._baseOrder
end

function SongListContainer:_ensurePoolSize(p)
	while #self._pool < p do
		local card = SongCard.new(self._viewport, {})
		local v = { card = card, boundSongId = nil, connections = {} }

		table.insert(v.connections, card.Clicked:Connect(function()
			if v.boundSongId then
				if self._selectedSongId == v.boundSongId then
					self:ClearSelection()
				else
					self:SelectSong(v.boundSongId)
				end
			end
		end))

		table.insert(v.connections, card.FavoriteToggled:Connect(function()
			if v.boundSongId then
				self._favoriteToggledEvent:Fire(v.boundSongId)
			end
		end))

		table.insert(self._pool, v)
	end
end

function SongListContainer:_renderWindow()
	local count = #self._visibleOrder

	if count == 0 then
		for _, v in ipairs(self._pool) do
			v.card.Instance.Visible = false
			v.boundSongId = nil
		end
	else
		local y = self._viewport.AbsoluteSize.Y
		local v = y <= 0 and 400 or y

		local y2 = self._viewport.CanvasPosition.Y
		local rowTops = self._rowTops

		local v2 = math.max(1, lowerBound(rowTops, y2) - 3 - 1)

		local v3 = math.min(count, lowerBound(rowTops, y2 + v) + 3)

		self:_ensurePoolSize(v3 - v2 + 1)

		local set = {}

		for i = v2, v3 do
			set[self._visibleOrder[i]] = true
		end

		local v4 = {}
		local v5 = {}

		for _, v6 in ipairs(self._pool) do
			local boundSongId = v6.boundSongId

			if boundSongId and set[boundSongId] and not v4[boundSongId] then
				v4[boundSongId] = v6
			else
				table.insert(v5, v6)
			end
		end

		local v6 = 1

		for i = v2, v3 do
			local boundSongId = self._visibleOrder[i]
			local record = self._records[boundSongId]
			local v7 = v4[boundSongId]

			if not v7 then
				v7 = v5[v6]
				v6 += 1

				record.instrumentStates = self:GetInstrumentStates(boundSongId)
				v7.card:SetData(record, true)
				v7.boundSongId = boundSongId
				v7.card:SetSelected(boundSongId == self._selectedSongId, true)
			end

			local instance = v7.card.Instance
			instance.Position = UDim2.new(0, self._sidePadding, 0, rowTops[i])
			instance.Size = UDim2.new(1, -(self._sidePadding * 2), 0, instance.Size.Y.Offset)
			instance.Visible = true
		end

		for i = v6, #v5 do
			local v7 = v5[i]
			v7.card.Instance.Visible = false
			v7.boundSongId = nil
		end
	end
end

function SongListContainer:Destroy()
	for _, viewportConnection in ipairs(self._viewportConnections) do
		viewportConnection:Disconnect()
	end

	self._viewportConnections = {}

	for _, v in ipairs(self._pool) do
		for _, connection in ipairs(v.connections) do
			connection:Disconnect()
		end

		v.card:Destroy()
	end

	self._pool = {}

	self._records = {}
	self._baseOrder = {}
	self._visibleOrder = {}
	self._rowTops = {}

	self.Instance:Destroy()
end

return SongListContainer