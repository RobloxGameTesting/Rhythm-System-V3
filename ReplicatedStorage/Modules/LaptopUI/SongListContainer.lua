local Theme = require(script.Parent.Theme)
local SongCard = require(script.Parent.SongCard)

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
		data.mood or ""
	}, " "))
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
	viewport.ScrollBarThickness = Theme.Sizes.ScrollBarThickness
	viewport.ScrollBarImageColor3 = Theme.Colors.TextSecondary
	viewport.ClipsDescendants = true
	viewport.Parent = songListContainer

	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Name = "EmptyLabel"
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Size = UDim2.new(1, 0, 0, Theme.Sizes.ControlHeightL)
	emptyLabel.Position = UDim2.new(0, 0, 0, Theme.Spacing.XL)
	emptyLabel.Font = Theme.Fonts.Medium
	emptyLabel.TextSize = Theme.TextSize.L
	emptyLabel.TextColor3 = Theme.Colors.TextSecondary
	emptyLabel.Text = "No songs found."
	emptyLabel.Visible = false
	emptyLabel.Parent = songListContainer

	local rowGap = v.rowGap or Theme.Spacing.XS
	local sidePadding = v.sidePadding or 0

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = songListContainer
	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Parent = songListContainer

	local object = setmetatable({
		Instance = songListContainer,
		Selected = bindableEvent.Event,
		VisibleCountChanged = bindableEvent2.Event,
		_viewport = viewport,
		_emptyLabel = emptyLabel,
		_rowGap = rowGap,
		_sidePadding = sidePadding,
		_rowTops = {},
		_selectedEvent = bindableEvent,
		_visibleCountChangedEvent = bindableEvent2,
		_records = {},
		_baseOrder = {},
		_visibleOrder = {},
		_searchQuery = "",
		_genreFilter = nil,
		_instrumentFilter = nil,
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

	local position = nil
	viewport.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			position = input.Position
		end
	end)
	viewport.InputEnded:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local v2 = position
		position = nil

		if not v2 or (input.Position - v2).Magnitude > 8 then
			return
		end

		local vector2 = Vector2.new(input.Position.X, input.Position.Y)

		for _, v3 in ipairs(object._pool) do
			local instance = v3.card.Instance

			if not (v3.boundSongId and instance.Visible) then
				continue
			end

			local absolutePosition = instance.AbsolutePosition
			local absoluteSize = instance.AbsoluteSize

			if
				vector2.X >= absolutePosition.X
				and vector2.X <= absolutePosition.X + absoluteSize.X
				and vector2.Y >= absolutePosition.Y
				and vector2.Y <= absolutePosition.Y + absoluteSize.Y
			then
				if object._selectedSongId == v3.boundSongId then
					object:ClearSelection()
				else
					object:SelectSong(v3.boundSongId)
				end

				break
			end
		end
	end)

	return object
end

function SongListContainer:SetSongs(list)
	local clonesBySongId = {}
	local songIds = {}

	for _, item in ipairs(list) do
		local clone = table.clone(item)
		clone._searchBlob = buildSearchBlob(clone)
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

function SongListContainer:UpdateSong(p, items)
	local record = self._records[p]

	if not record then
		return
	end

	for k, item in pairs(items) do
		record[k] = item
	end

	record._searchBlob = buildSearchBlob(record)

	for _, v in ipairs(self._pool) do
		if v.boundSongId == p then
			v.card:SetData(record)
			break
		end
	end

	self:_recomputeVisibleOrder()
end

function SongListContainer:SetField(p, p2, p3)
	local record = self._records[p]

	if not record then
		return
	end

	record[p2] = p3
	record._searchBlob = buildSearchBlob(record)

	self:_recomputeVisibleOrder()
end

function SongListContainer:SetSearchQuery(value)
	self._searchQuery = string.lower(value or "")
	self:_recomputeVisibleOrder()
end

function SongListContainer:SetGenreFilter(genreFilter)
	self._genreFilter = genreFilter
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

function SongListContainer:SetFilter(customPredicate)
	self._customPredicate = customPredicate
	self:_recomputeVisibleOrder()
end

function SongListContainer:SetSort(p)
	self._comparator = p or defaultComparator
	self:_recomputeVisibleOrder()
end

function SongListContainer:_passesFilters(data): boolean
	if self._genreFilter and self._genreFilter ~= "All" and mainGenreOf(data.genre) ~= self._genreFilter then -- inferred equivalent call
		return false
	end

	if self._instrumentFilter then
		local instrumentAvailability = data.instrumentAvailability

		if not (instrumentAvailability and instrumentAvailability[self._instrumentFilter]) then
			return false
		end
	end

	if self._searchQuery ~= "" and not string.find(data._searchBlob, self._searchQuery, 1, true) then
		return false
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
		return self._comparator(self._records[a], self._records[b])
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
		local v = {
			card = SongCard.new(self._viewport, {}),
			boundSongId = nil,
			connections = {}
		}
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
		local v4 = 1

		for i = v2, v3 do
			local boundSongId = self._visibleOrder[i]
			local record = self._records[boundSongId]
			local v5 = self._pool[v4]

			if v5.boundSongId ~= boundSongId then
				v5.card:SetData(record)
				v5.boundSongId = boundSongId
				v5.card:SetSelected(boundSongId == self._selectedSongId)
			end

			local instance = v5.card.Instance
			instance.Position = UDim2.new(0, self._sidePadding, 0, rowTops[i])
			instance.Size = UDim2.new(1, -(self._sidePadding * 2), 0, instance.Size.Y.Offset)
			instance.Visible = true

			v4 += 1
		end

		for i = v4, #self._pool do
			self._pool[i].card.Instance.Visible = false
			self._pool[i].boundSongId = nil
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