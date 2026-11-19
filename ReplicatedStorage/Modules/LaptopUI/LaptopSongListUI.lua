local parent = script.Parent

local Theme = require(parent.Theme)
local Retro = require(parent.Retro)
local SearchBar = require(parent.SearchBar)
local FilterBar = require(parent.FilterBar)
local SongListContainer = require(parent.SongListContainer)
local LaptopSongDetailCompact = require(parent.LaptopSongDetailCompact)

local LaptopSongListUI = {}
LaptopSongListUI.__index = LaptopSongListUI

local s = Theme.Spacing.S

function LaptopSongListUI.new(parent2)
	local laptopSongListUI = Instance.new("Frame")
	laptopSongListUI.Name = "LaptopSongListUI"
	laptopSongListUI.BackgroundTransparency = 1
	laptopSongListUI.Size = UDim2.new(1, 0, 1, 0)
	laptopSongListUI.ClipsDescendants = true
	laptopSongListUI.Parent = parent2
	Retro.AttachScreenFrame(laptopSongListUI)

	local uiPadding = Instance.new("UIPadding")

	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.PaddingTop = UDim.new(0, 10)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = laptopSongListUI

	local leftColumn = Instance.new("Frame")
	leftColumn.Name = "LeftColumn"
	leftColumn.BackgroundTransparency = 1
	leftColumn.Size = UDim2.new(0.56, -(s / 2), 1, 0)
	leftColumn.Position = UDim2.new(0, 0, 0, 0)
	leftColumn.ClipsDescendants = true
	leftColumn.Parent = laptopSongListUI

	local rightColumn = Instance.new("Frame")
	rightColumn.Name = "RightColumn"
	rightColumn.BackgroundTransparency = 1
	rightColumn.Size = UDim2.new(0.43999999999999995, -(s / 2), 1, 0)
	rightColumn.Position = UDim2.new(0.56, s / 2, 0, 0)
	rightColumn.Parent = laptopSongListUI

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.Padding = UDim.new(0, Theme.Spacing.XS)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = leftColumn

	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 16)
	header.Font = Theme.Fonts.Bold
	header.TextSize = Theme.TextSize.L
	header.TextColor3 = Theme.Colors.TextPrimary
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextYAlignment = Enum.TextYAlignment.Center
	header.Text = "Song List"
	header.LayoutOrder = 1
	header.Parent = leftColumn

	local searchBar = SearchBar.new(leftColumn, {
		placeholder = "Search...",
		size = UDim2.new(1, 0, 0, Theme.Sizes.ControlHeightM),
		layoutOrder = 2
	})

	local filterBar = FilterBar.new(leftColumn, {
		items = { "All" },
		chipHeight = 18,
		layoutOrder = 3
	})

	local listWrapper = Instance.new("Frame")
	listWrapper.Name = "ListWrapper"
	listWrapper.BackgroundTransparency = 1
	listWrapper.Size = UDim2.new(1, 0, 1, 0)
	listWrapper.ClipsDescendants = true
	listWrapper.LayoutOrder = 4
	listWrapper.Parent = leftColumn

	local container = SongListContainer.new(listWrapper, { rowGap = Theme.Spacing.XS })

	local detailPanel = LaptopSongDetailCompact.new(rightColumn)
	detailPanel.Instance.Size = UDim2.new(1, 0, 1, 0)

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = laptopSongListUI
	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Parent = laptopSongListUI

	local object = setmetatable({
		Instance = laptopSongListUI,
		Selected = bindableEvent.Event,
		PlayRequested = bindableEvent2.Event,
		_searchBar = searchBar,
		_filterBar = filterBar,
		_listWrapper = listWrapper,
		_container = container,
		_detailPanel = detailPanel,
		_selectedEvent = bindableEvent,
		_playRequestedEvent = bindableEvent2,
		_currentTab = "All",
		_currentSongId = nil,
		_connections = {}
	}, LaptopSongListUI)

	local function relayout()
		local v = header.AbsoluteSize.Y + searchBar.Instance.AbsoluteSize.Y + filterBar.Instance.AbsoluteSize.Y + Theme.Spacing.XS * 3
		local v2 = math.max(0, leftColumn.AbsoluteSize.Y - v)
		listWrapper.Size = UDim2.new(1, 0, 0, v2)
	end

	table.insert(object._connections, leftColumn:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout))
	relayout()

	table.insert(object._connections, searchBar.Changed:Connect(function(p)
		container:SetSearchQuery(p)
	end))

	table.insert(object._connections, filterBar.Selected:Connect(function(currentTab)
		object._currentTab = currentTab
		container:SetGenreFilter(currentTab)
	end))

	table.insert(object._connections, container.Selected:Connect(function(currentSongId, p)
		object._currentSongId = currentSongId

		if currentSongId and p then
			detailPanel:ShowSong(p)
		else
			detailPanel:Hide()
		end

		bindableEvent:Fire(currentSongId, p)
	end))

	table.insert(object._connections, detailPanel.PlayRequested:Connect(function()
		if object._currentSongId then
			bindableEvent2:Fire(object._currentSongId)
		end
	end))

	return object
end

function LaptopSongListUI:SetSongs(p)
	self._container:SetSongs(p)
	local uniqueGenres = self._container:GetUniqueGenres()
	self._filterBar:SetItems(uniqueGenres)
end

function LaptopSongListUI:SetPreviewLoading(p, p2)
	self._container:SetPreviewLoading(p, p2)
end

function LaptopSongListUI:ClearSelection()
	self._container:ClearSelection()
end

function LaptopSongListUI:Destroy()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	self._connections = {}

	self._searchBar:Destroy()
	self._filterBar:Destroy()
	self._container:Destroy()
	self._detailPanel:Destroy()

	self.Instance:Destroy()
end

return LaptopSongListUI