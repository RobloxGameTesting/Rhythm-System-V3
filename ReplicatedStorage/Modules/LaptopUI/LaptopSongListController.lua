local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local parent = script.Parent

local SongConfigAdapter = require(ReplicatedStorage.Modules.SongConfigAdapter)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SongPreloadSignal = require(ReplicatedStorage2.Modules.SongPreloadSignal)
local PreviewConfig = require(ReplicatedStorage.Modules.PreviewConfig)

local Theme = require(parent.Theme)
local Retro = require(parent.Retro)
local LaptopSongListUI = require(parent.LaptopSongListUI)
local LaptopStemConfigPanel = require(parent.LaptopStemConfigPanel)
local LaptopClientController = require(parent.LaptopClientController)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LaptopStartBackingTrack = RemoteEvents:WaitForChild("LaptopStartBackingTrack")
local LaptopStopBackingTrack = RemoteEvents:WaitForChild("LaptopStopBackingTrack")
local LaptopRequestStartVote = RemoteEvents:WaitForChild("LaptopRequestStartVote")
local LaptopVoteTally = RemoteEvents:WaitForChild("LaptopVoteTally")
local LaptopVoteResult = RemoteEvents:WaitForChild("LaptopVoteResult")

local LaptopRequestInstrumentLockState = RemoteEvents:WaitForChild("LaptopRequestInstrumentLockState")
local LaptopInstrumentLockUpdate = RemoteEvents:WaitForChild("LaptopInstrumentLockUpdate")

local v = {}
local LaptopSongListController = {}

function LaptopSongListController.OnBackingTrackStartRequested(p)
	table.insert(v, p)
end

local v2 = {}

local v3 = {}

local v4 = {}

local allSongsBySongId = {}

local v5 = {}
local v6 = {}

local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}

local showNowPlaying
local showSongListScreen

local v11 = nil

local sounds = {}
local v12 = nil
local v13 = nil
local thread = nil
local count = 0
local FadeOut = PreviewConfig.Defaults.FadeOut
local v14 = nil

local function stopPreview()
	count += 1
	local v15 = v13 or v12
	v13 = nil

	if v15 and v14 then
		v14:SetPreviewLoading(v15, false)
	end

	local v16 = thread
	thread = nil

	if v16 and coroutine.running() ~= v16 then
		task.cancel(v16)
	end

	if v12 == nil then
		return
	end

	v12 = nil

	local v17 = sounds
	sounds = {}
	local v18 = FadeOut

	for _, instance in ipairs(v17) do
		TweenService:Create(instance, TweenInfo.new(v18), { Volume = 0 }):Play()
	end

	task.delay(v18, function()
		for _, v19 in ipairs(v17) do
			v19:Destroy()
		end
	end)
end

local function startPreview(p)
	if v12 == p or v13 == p then
		return
	end

	stopPreview()

	local rawKey = SongConfigAdapter.GetRawKey(p)

	if not rawKey then
		return
	end

	local previewStems = SongConfigAdapter.GetPreviewStems(p)

	if #previewStems == 0 then
		return
	end

	local v15 = PreviewConfig.Get(rawKey)

	v13 = p
	count += 1
	local v16 = count

	if v14 then
		v14:SetPreviewLoading(p, true)
	end

	local v17 = {}

	for _, previewStem in ipairs(previewStems) do
		local sound = Instance.new("Sound")
		sound.Name = "LaptopPreview_" .. previewStem.instrumentType
		sound.SoundId = previewStem.assetId
		sound.Volume = 0
		sound.Parent = SoundService
		table.insert(v17, { sound = sound, relativeVolume = previewStem.relativeVolume })
	end

	task.spawn(function()
		local sounds2 = {}

		for _, v18 in ipairs(v17) do
			table.insert(sounds2, v18.sound)
		end

		ContentProvider:PreloadAsync(sounds2)

		if v16 == count then
			if v14 then
				v14:SetPreviewLoading(p, false)
			end

			for _, v18 in ipairs(v17) do
				v18.sound.TimePosition = v15.StartOffset
			end

			for _, v18 in ipairs(v17) do
				v18.sound:Play()
			end

			for _, v18 in ipairs(v17) do
				TweenService:Create(v18.sound, TweenInfo.new(v15.FadeIn), {
					Volume = v15.Volume * v18.relativeVolume
				}):Play()
				table.insert(sounds, v18.sound)
			end

			v13 = nil
			v12 = p
			FadeOut = v15.FadeOut
			thread = task.delay(v15.Duration, stopPreview)
		else
			for _, v18 in ipairs(v17) do
				v18.sound:Destroy()
			end
		end
	end)
end

function LaptopSongListController.RegisterLaptop(p, p2)
	v2[p] = p2
end

local function getOrCreateUI(p, instance)
	if v3[p] then
		return v3[p]
	end

	local guiAnchor = instance:WaitForChild("GuiAnchor", 5)

	if not guiAnchor then
		warn("[LaptopSongListController] GuiAnchor tidak ditemukan untuk", p)
		return nil
	end

	local laptopScreen = guiAnchor:WaitForChild("LaptopScreen", 5)

	if not laptopScreen then
		warn("[LaptopSongListController] LaptopScreen SurfaceGui tidak ditemukan untuk", p)
		return nil
	end

	local v15 = LaptopSongListUI.new(laptopScreen)
	local allSongs = SongConfigAdapter.GetAllSongs()

	for _, allSong in ipairs(allSongs) do
		allSongsBySongId[allSong.songId] = allSong
	end

	v15:SetSongs(allSongs)

	local v16 = LaptopStemConfigPanel.new(laptopScreen)
	v4[p] = v16

	v15.PlayRequested:Connect(function(p2)
		stopPreview()

		local rawKey = SongConfigAdapter.GetRawKey(p2)

		if rawKey then
			SongPreloadSignal.NotifyCommit(rawKey, p)
		end

		if v10[p] then
			v10[p] = nil
			v15.Instance.Visible = false
			LaptopRequestStartVote:FireServer(p, p2)
			showNowPlaying(p)
		else
			local v17 = allSongsBySongId[p2]
			local rawKey2 = SongConfigAdapter.GetRawKey(p2)
			v15.Instance.Visible = false
			v16:ShowSong(p2, rawKey2, v17 and v17.displayName)

			LaptopRequestInstrumentLockState:FireServer(p)
		end
	end)

	v16.BackRequested:Connect(function()
		v16:Hide()
		v15.Instance.Visible = true
	end)

	v16.StartRequested:Connect(function(p2, p3)
		LaptopStartBackingTrack:FireServer(p, p2, p3)

		for _, callback in ipairs(v) do
			local success, result = pcall(callback, p, p2)

			if not success then
				warn("[LaptopSongListController] Error pada OnBackingTrackStartRequested listener:", result)
			end
		end
	end)

	v15.Selected:Connect(function(p2)
		if p2 then
			startPreview(p2)

			local rawKey = SongConfigAdapter.GetRawKey(p2)

			if rawKey then
				SongPreloadSignal.NotifySelected(rawKey, p)
			else
				SongPreloadSignal.CancelSelected()
			end
		else
			stopPreview()
			SongPreloadSignal.CancelSelected()
		end
	end)

	v3[p] = v15
	return v15
end

local function resolveBackground(p) -- 5 equivalent calls inferred from this helper
	local v15 = v2[p]
	local guiAnchor = v15 and v15:FindFirstChild("GuiAnchor")
	local laptopScreen = guiAnchor and guiAnchor:FindFirstChild("LaptopScreen")
	return laptopScreen and laptopScreen:FindFirstChild("Background")
end

local s = Theme.Spacing.S
local l = Theme.Spacing.L

local function getOrCreateStopButton(p, parent2)
	local v15 = v5[p]

	if v15 then
		return v15
	end

	local laptopStopButton_Local = Instance.new("TextButton")
	laptopStopButton_Local.Name = "LaptopStopButton_Local"
	laptopStopButton_Local.Text = ""
	laptopStopButton_Local.AutoButtonColor = false

	laptopStopButton_Local.Size = UDim2.new(0.5, -(l + s / 2), 0, 26)
	laptopStopButton_Local.Position = UDim2.new(0.5, s / 2, 1, -(26 + l))
	laptopStopButton_Local.BackgroundColor3 = Theme.Colors.Danger
	laptopStopButton_Local.BorderSizePixel = 0

	laptopStopButton_Local.ZIndex = Theme.ZIndex.Raised
	laptopStopButton_Local.Visible = false
	laptopStopButton_Local.Parent = parent2

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Medium
	uiCorner.Parent = laptopStopButton_Local

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.fromRGB(96, 28, 22)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = laptopStopButton_Local
	Retro.AddGloss(laptopStopButton_Local)

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, Theme.Spacing.XS)
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Parent = laptopStopButton_Local

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.AutomaticSize = Enum.AutomaticSize.X
	icon.Size = UDim2.new(0, 0, 1, 0)
	icon.Font = Theme.Fonts.Bold
	icon.TextSize = Theme.TextSize.M
	icon.TextColor3 = Theme.Colors.TextPrimary
	icon.Text = "■"
	icon.ZIndex = Theme.ZIndex.Raised
	icon.LayoutOrder = 1
	icon.Parent = laptopStopButton_Local

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.AutomaticSize = Enum.AutomaticSize.X
	title.Size = UDim2.new(0, 0, 1, 0)
	title.Font = Theme.Fonts.Bold
	title.TextSize = Theme.TextSize.S
	title.TextColor3 = Theme.Colors.TextPrimary
	title.Text = "Stop"
	title.ZIndex = Theme.ZIndex.Raised
	title.LayoutOrder = 2
	title.Parent = laptopStopButton_Local

	laptopStopButton_Local.Activated:Connect(function()
		LaptopStopBackingTrack:FireServer(p)
	end)

	v5[p] = laptopStopButton_Local
	return laptopStopButton_Local
end

local function getOrCreateChangeSongButton(p, parent2)
	local v15 = v7[p]

	if v15 then
		return v15
	end

	local laptopChangeSongButton_Local = Instance.new("TextButton")
	laptopChangeSongButton_Local.Name = "LaptopChangeSongButton_Local"
	laptopChangeSongButton_Local.Text = ""
	laptopChangeSongButton_Local.AutoButtonColor = false

	laptopChangeSongButton_Local.Size = UDim2.new(0.5, -(l + s / 2), 0, 26)
	laptopChangeSongButton_Local.Position = UDim2.new(0, l, 1, -(26 + l))
	laptopChangeSongButton_Local.BackgroundColor3 = Theme.Colors.Accent
	laptopChangeSongButton_Local.BorderSizePixel = 0
	laptopChangeSongButton_Local.ZIndex = Theme.ZIndex.Raised
	laptopChangeSongButton_Local.Visible = false
	laptopChangeSongButton_Local.Parent = parent2

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Medium
	uiCorner.Parent = laptopChangeSongButton_Local

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.fromRGB(128, 84, 18)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = laptopChangeSongButton_Local
	Retro.AddGloss(laptopChangeSongButton_Local)

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, Theme.Spacing.XS)
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Parent = laptopChangeSongButton_Local

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.AutomaticSize = Enum.AutomaticSize.X
	icon.Size = UDim2.new(0, 0, 1, 0)
	icon.Font = Theme.Fonts.Bold
	icon.TextSize = Theme.TextSize.M
	icon.TextColor3 = Theme.Colors.AccentText
	icon.Text = "⇄"
	icon.ZIndex = Theme.ZIndex.Raised
	icon.LayoutOrder = 1
	icon.Parent = laptopChangeSongButton_Local

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.AutomaticSize = Enum.AutomaticSize.X
	title.Size = UDim2.new(0, 0, 1, 0)
	title.Font = Theme.Fonts.Bold
	title.TextSize = Theme.TextSize.S
	title.TextColor3 = Theme.Colors.AccentText
	title.Text = "Change Song"
	title.ZIndex = Theme.ZIndex.Raised
	title.LayoutOrder = 2
	title.Parent = laptopChangeSongButton_Local

	laptopChangeSongButton_Local.Activated:Connect(function()
		v10[p] = true
		showSongListScreen(p)
	end)

	v7[p] = laptopChangeSongButton_Local
	return laptopChangeSongButton_Local
end

local function getOrCreateVoteStatusLabel(p, parent2)
	local v15 = v8[p]

	if v15 then
		return v15
	end

	local laptopVoteStatusLabel_Local = Instance.new("TextLabel")
	laptopVoteStatusLabel_Local.Name = "LaptopVoteStatusLabel_Local"
	laptopVoteStatusLabel_Local.Size = UDim2.new(1, -(l * 2), 0, 44)
	laptopVoteStatusLabel_Local.Position = UDim2.new(0, l, 1, -(44 + l))
	laptopVoteStatusLabel_Local.BackgroundColor3 = Theme.Colors.Surface
	laptopVoteStatusLabel_Local.BorderSizePixel = 0

	laptopVoteStatusLabel_Local.Font = Theme.Fonts.Medium
	laptopVoteStatusLabel_Local.TextSize = Theme.TextSize.S
	laptopVoteStatusLabel_Local.TextColor3 = Theme.Colors.TextPrimary
	laptopVoteStatusLabel_Local.TextWrapped = true
	laptopVoteStatusLabel_Local.TextYAlignment = Enum.TextYAlignment.Center
	laptopVoteStatusLabel_Local.ZIndex = Theme.ZIndex.Raised
	laptopVoteStatusLabel_Local.Visible = false
	laptopVoteStatusLabel_Local.Parent = parent2

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Medium
	uiCorner.Parent = laptopVoteStatusLabel_Local

	v8[p] = laptopVoteStatusLabel_Local
	return laptopVoteStatusLabel_Local
end

local offsets = {}

local function getInstrumentScroll(instance) -- 2 equivalent calls inferred from this helper
	local sessionPanel = instance and instance:FindFirstChild("SessionPanel")

	local contentColumn = sessionPanel and sessionPanel:FindFirstChild("ContentColumn")
	return contentColumn and contentColumn:FindFirstChild("InstrumentScroll")
end

local function applyInstrumentScrollOverride(p, instance, p2)
	local instrumentScroll = getInstrumentScroll(instance) -- inferred equivalent call

	if not instrumentScroll then
		return
	end

	if offsets[p] == nil then
		offsets[p] = instrumentScroll.Size.Y.Offset
	end

	instrumentScroll.Active = true
	instrumentScroll.ScrollingEnabled = true
	local v15 = math.max(0, offsets[p] - p2)
	instrumentScroll.Size = UDim2.new(1, 0, 0, v15)
end

local function resetInstrumentScrollOverride(p, background) -- 2 equivalent calls inferred from this helper
	local instrumentScroll = getInstrumentScroll(background) -- inferred equivalent call

	if not instrumentScroll then
		return
	end

	instrumentScroll.Active = false
	instrumentScroll.ScrollingEnabled = false
	local v15 = offsets[p]

	if v15 then
		instrumentScroll.Size = UDim2.new(1, 0, 0, v15)
	end
end

local function refreshNowPlayingControls(p, p2)
	if not p2 then
		p2 = resolveBackground(p) -- inferred equivalent call
	end

	if not p2 then
		return
	end

	local stopButton = getOrCreateStopButton(p, p2)
	local changeSongButton = getOrCreateChangeSongButton(p, p2)
	local voteStatusLabel = getOrCreateVoteStatusLabel(p, p2)
	local v15

	if v9[p] then
		stopButton.Visible = false
		changeSongButton.Visible = false
		voteStatusLabel.Visible = true
		v15 = 44 + Theme.Spacing.XS
	else
		stopButton.Visible = true
		changeSongButton.Visible = true
		voteStatusLabel.Visible = false
		v15 = 26 + Theme.Spacing.XS
	end

	applyInstrumentScrollOverride(p, p2, v15)
end

showNowPlaying = function(p)
	local background = resolveBackground(p) -- inferred equivalent call

	if not background then
		return
	end

	local v15 = v3[p]

	if v15 then
		v15.Instance.Visible = false
	end

	local v16 = v4[p]

	if v16 then
		v16:Hide()
	end

	if not background.Visible then
		Retro.GlitchPulse(background)
	end

	background.Visible = true
	refreshNowPlayingControls(p, background)
end

showSongListScreen = function(p)
	local background = resolveBackground(p) -- inferred equivalent call
	local v15 = v5[p]

	if v15 then
		v15.Visible = false
	end

	local v16 = v7[p]

	if v16 then
		v16.Visible = false
	end

	local v17 = v8[p]

	if v17 then
		v17.Visible = false
	end

	if background then
		resetInstrumentScrollOverride(p, background) -- inferred equivalent call
		background.Visible = false
	end

	local ui = getOrCreateUI(p, v2[p])

	if not ui then
		return
	end

	v14 = ui
	ui.Instance.Visible = true
end

function LaptopSongListController.Start()
	LaptopClientController.OnEnter(function(p)
		v11 = p

		if not v2[p] then
			warn("[LaptopSongListController] Tidak ada Screen terdaftar untuk", p)
			return
		end

		local background = resolveBackground(p) -- inferred equivalent call
		local sessionPanel = background and background:FindFirstChild("SessionPanel")

		if sessionPanel and sessionPanel.Visible then
			showNowPlaying(p)
		else
			showSongListScreen(p)
		end

		if sessionPanel then
			v6[p] = sessionPanel:GetPropertyChangedSignal("Visible"):Connect(function()
				if sessionPanel.Visible then
					showNowPlaying(p)
				else
					showSongListScreen(p)
				end
			end)
		end
	end)

	LaptopClientController.OnExit(function(p)
		stopPreview()

		local connection = v6[p]

		if connection then
			connection:Disconnect()
			v6[p] = nil
		end

		local v15 = v3[p]

		if v15 then
			v15.Instance.Visible = false
			v15:ClearSelection()
		end

		local v16 = v4[p]

		if v16 then
			v16:Hide()
		end

		local v17 = v5[p]

		if v17 then
			v17.Visible = false
		end

		local v18 = v7[p]

		if v18 then
			v18.Visible = false
		end

		local v19 = v8[p]

		if v19 then
			v19.Visible = false
		end

		v10[p] = nil
		local background = resolveBackground(p) -- inferred equivalent call

		if background then
			resetInstrumentScrollOverride(p, background) -- inferred equivalent call
			background.Visible = true
		end

		if v14 == v15 then
			v14 = nil
		end

		if v11 == p then
			v11 = nil
		end
	end)
end

LaptopVoteTally.OnClientEvent:Connect(function(p, data)
	v9[p] = true

	if p == v11 then
		refreshNowPlayingControls(p)
		local v15 = v8[p]

		if v15 then
			v15.Text = ("Change to \"%s\"?\n%d Yes | %d No (of %d)"):format(
				data.SongDisplayName,
				data.Yes,
				data.No,
				data.Total
			)
		end
	end
end)

LaptopVoteResult.OnClientEvent:Connect(function(p, _)
	v9[p] = nil

	if p == v11 then
		refreshNowPlayingControls(p)
	end
end)

LaptopInstrumentLockUpdate.OnClientEvent:Connect(function(p, p2)
	local v15 = v4[p]

	if v15 then
		v15:SetLockedInstruments(p2)
	end
end)

return LaptopSongListController