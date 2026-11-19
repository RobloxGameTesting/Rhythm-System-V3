local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local v = require(ReplicatedStorage.Modules.SongListUI.MainSongListUI)
local SongConfigAdapter = require(ReplicatedStorage.Modules.SongConfigAdapter)
local ChartAvailabilityClient = require(ReplicatedStorage.Modules.ChartAvailabilityClient)
local roomHudGui = require(ReplicatedStorage.Modules.FavoriteSystem.FavoriteClient)
local v2 = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local UISkin = require(ReplicatedStorage.Modules.SongListUI.UISkin)
local ConfirmDialog = require(ReplicatedStorage.Modules.SongListUI.ConfirmDialog)
local ThemeState = require(ReplicatedStorage.Modules.ThemeState)
local InstrumentList = require(ReplicatedStorage.Modules.SongListUI.InstrumentList)
local v3 = require(ReplicatedStorage.Modules.SongListUI.InviteResponseBar)
local ReadyButtonUI = require(ReplicatedStorage.Modules.ReadyButtonUI)
local PlayerLoadingState = require(ReplicatedStorage.Modules.PlayerLoadingState)
local SongMoveToast = require(ReplicatedStorage.Modules.SongListUI.SongMoveToast)
local RoomHudIndicator = require(ReplicatedStorage.Modules.SongListUI.RoomHudIndicator)
require(ReplicatedStorage.Modules.ClientSongPreloader)
local SongPreloadSignal = require(ReplicatedStorage.Modules.SongPreloadSignal)
local ThemePreferenceClient = require(ReplicatedStorage.Modules.ThemeSystem.ThemePreferenceClient)
local RecentlyPlayedClient = require(ReplicatedStorage.Modules.RecentlyPlayedSystem.RecentlyPlayedClient)
local LoadingToast = require(ReplicatedStorage.Modules.SongListUI.LoadingToast)
local PreviewConfig = require(ReplicatedStorage.Modules.PreviewConfig)
local NowPlayingBar = require(ReplicatedStorage.Modules.SongListUI.NowPlayingBar)
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)

local LaptopClientController = require(ReplicatedStorage.Modules.LaptopUI.LaptopClientController)
local LaptopSongListController = require(ReplicatedStorage.Modules.LaptopUI.LaptopSongListController)
local laptopOpenFromSongList = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LaptopOpenFromSongList")

local NewbieModePanelUI = require(ReplicatedStorage.Modules.NewbieModePanelUI)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SelectSong = RemoteEvents:WaitForChild("SelectSong")
local SongSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate")
local StudioSessionUpdate = RemoteEvents:WaitForChild("StudioSessionUpdate")
local StudioLoadProgressUpdate = RemoteEvents:WaitForChild("StudioLoadProgressUpdate")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")
local GetSongElapsed = RemoteEvents:WaitForChild("GetSongElapsed")

local InvitePlayer = RemoteEvents:WaitForChild("InvitePlayer")
local RespondToInvite = RemoteEvents:WaitForChild("RespondToInvite")
local CloseRoom = RemoteEvents:WaitForChild("CloseRoom")
local CancelInvite = RemoteEvents:WaitForChild("CancelInvite")
local KickFromRoom = RemoteEvents:WaitForChild("KickFromRoom")
local SetReadyForInstrument = RemoteEvents:WaitForChild("SetReadyForInstrument")
local ReportLoadingComplete = RemoteEvents:WaitForChild("ReportLoadingComplete")
local InvitePartyUpdate = RemoteEvents:WaitForChild("InvitePartyUpdate")

local RoomStateUpdate = RemoteEvents:WaitForChild("RoomStateUpdate")
local RequestSongChange = RemoteEvents:WaitForChild("RequestSongChange")
local MoveRoom = RemoteEvents:WaitForChild("MoveRoom")
local SongMoveRequestNotify = RemoteEvents:WaitForChild("SongMoveRequestNotify")
local SongRequestBroadcast = RemoteEvents:WaitForChild("SongRequestBroadcast")
local StudioEquipUpdate = RemoteEvents:WaitForChild("StudioEquipUpdate")
local GetStudioEquipSnapshot = RemoteEvents:WaitForChild("GetStudioEquipSnapshot")

local OpenSongMenuRequest = script.Parent:WaitForChild("OpenSongMenuRequest")

local ClientSongPreloader = require(ReplicatedStorage.Modules.ClientSongPreloader)

roomHudGui.Init()

ThemePreferenceClient.Init()

RecentlyPlayedClient.Init()

local songListToastGui = Instance.new("ScreenGui")
songListToastGui.Name = "SongListToastGui"
songListToastGui.ResetOnSpawn = false
songListToastGui.DisplayOrder = 95
songListToastGui.Parent = PlayerGui

local v4 = LoadingToast.new(songListToastGui)
local v5 = NowPlayingBar.new(songListToastGui)

v5.Instance:SetAttribute("StackExempt", true)

local v6 = v3.new(songListToastGui)

local v7 = SongMoveToast.new(songListToastGui)

roomHudGui = Instance.new("ScreenGui")
roomHudGui.Name = "RoomHudGui"
roomHudGui.ResetOnSpawn = false
roomHudGui.DisplayOrder = 40
roomHudGui.Parent = PlayerGui
local v8 = RoomHudIndicator.new(roomHudGui)

local songListScreenGui = Instance.new("ScreenGui")
songListScreenGui.Name = "SongListScreenGui"
songListScreenGui.ResetOnSpawn = false

songListScreenGui.DisplayOrder = 90
songListScreenGui.Enabled = false
songListScreenGui.Parent = PlayerGui

local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.new(0.5, 0, 0.5, 0)

local UserInputService2 = game:GetService("UserInputService")
roomHudGui = UserInputService2.TouchEnabled

if roomHudGui then
	local UserInputService3 = game:GetService("UserInputService")
	roomHudGui = not UserInputService3.KeyboardEnabled
end

window.Size = UDim2.new(0.92, 0, roomHudGui and 0.94 or 0.85, 0)
window.BackgroundColor3 = v2.Colors.Background

window.BackgroundTransparency = 0.3

window.ClipsDescendants = true
window.Parent = songListScreenGui

v3 = Instance.new("UISizeConstraint")

v3.MaxSize = Vector2.new(900, 560)
v3.MinSize = Vector2.new(240, 200)
v3.Parent = window

v3 = Instance.new("UIStroke")
v3.Thickness = v2.Stroke.Thickness
v3.Color = Color3.new(0, 0, 0)
v3.Transparency = 0.2
v3.Parent = window

v3 = Instance.new("UICorner")
v3.CornerRadius = v2.Radius.Large
v3.Parent = window

v3 = Instance.new("UIPadding")
v3.PaddingLeft = UDim.new(0, roomHudGui and v2.Spacing.L or v2.Spacing.XL)
v3.PaddingRight = UDim.new(0, roomHudGui and v2.Spacing.L or v2.Spacing.XL)
v3.PaddingTop = UDim.new(0, roomHudGui and v2.Spacing.M or v2.Spacing.XL)
v3.PaddingBottom = UDim.new(0, roomHudGui and v2.Spacing.S or v2.Spacing.XL)
v3.Parent = window

local v9 = v.new(window, {
	title = "Song List",
	headerToggle = {
		prefixLabel = "Highways :",
		offLabel = "2D",
		onLabel = "3D",
		initial = ThemeState.Get() == "3D"
	},
	backingTrackButton = { label = "Backing Track" },
	newbieModeButton = { label = "Difficulty" }
})

v = SongConfigAdapter.GetAllSongs()
local v10 = ChartAvailabilityClient.Get(5)

for _, v11 in ipairs(v) do
	v11.chartNotice = ChartAvailabilityClient.BuildNotice(v10[v11.songId])
end

v9:SetSongs(v)

local Players2 = game:GetService("Players")
local localPlayer = Players2.LocalPlayer
local function applyHeldInstrument() -- 1 equivalent call inferred from this helper
	v9:SetViewInstrument(localPlayer:GetAttribute("EquippedInstrumentType"))
end

applyHeldInstrument() -- inferred equivalent call
localPlayer:GetAttributeChangedSignal("EquippedInstrumentType"):Connect(applyHeldInstrument)

local HttpService = game:GetService("HttpService")
local Players3 = game:GetService("Players")
local localPlayer2 = Players3.LocalPlayer

local function readBestScores()
	local bestScores = {}
	local songBestScores = localPlayer2:GetAttribute("SongBestScores")

	if type(songBestScores) ~= "string" or songBestScores == "" then
		return bestScores
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(songBestScores)
	end)

	if success and type(result) == "table" then
		for k, v11 in pairs(result) do
			if type(v11) == "number" then
				bestScores[SongConfigAdapter.GetSongId(k)] = v11
			end
		end
	end

	return bestScores
end

local function applyBestScores() -- 1 equivalent call inferred from this helper
	v9:SetBestScores(readBestScores())
end

applyBestScores() -- inferred equivalent call
localPlayer2:GetAttributeChangedSignal("SongBestScores"):Connect(applyBestScores)

local function readSongStars()
	local songStars = {}
	local songBestStars = localPlayer2:GetAttribute("SongBestStars")

	if type(songBestStars) ~= "string" or songBestStars == "" then
		return songStars
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(songBestStars)
	end)

	if success and type(result) == "table" then
		for k, v11 in pairs(result) do
			if type(v11) == "number" then
				songStars[SongConfigAdapter.GetSongId(k)] = v11
			end
		end
	end

	return songStars
end

local function applySongStars() -- 1 equivalent call inferred from this helper
	v9:SetSongStars(readSongStars())
end

applySongStars() -- inferred equivalent call
localPlayer2:GetAttributeChangedSignal("SongBestStars"):Connect(applySongStars)

local function decodeAttribute(attributeName)
	local attribute = localPlayer2:GetAttribute(attributeName)

	if type(attribute) == "string" and attribute ~= "" then
		local success, result = pcall(function()
			return HttpService:JSONDecode(attribute)
		end)

		if success and type(result) == "table" then
			return result
		end
	end

	return {}
end

local function applyInstrumentStars()
	local v11 = {}

	for k, v12 in pairs(decodeAttribute("SongBestInstrumentStars")) do
		if type(v12) == "table" then
			v11[SongConfigAdapter.GetSongId(k)] = v12
		end
	end

	v9:SetInstrumentStars(v11)
end

applyInstrumentStars()
localPlayer2:GetAttributeChangedSignal("SongBestInstrumentStars"):Connect(applyInstrumentStars)

local function applyPlayCounts()
	local songPlayCounts = localPlayer2:GetAttribute("SongPlayCounts")

	if type(songPlayCounts) ~= "string" or songPlayCounts == "" then
		v9:SetPlayCounts(nil)
		return
	end

	local v11 = {}

	for k, v12 in pairs(decodeAttribute("SongPlayCounts")) do
		if type(v12) == "number" then
			v11[SongConfigAdapter.GetSongId(k)] = v12
		end
	end

	v9:SetPlayCounts(v11)
end

applyPlayCounts()
localPlayer2:GetAttributeChangedSignal("SongPlayCounts"):Connect(applyPlayCounts)

task.spawn(function()
	local ContentProvider2 = game:GetService("ContentProvider")
	local success, instrumentIcons = pcall(require, ReplicatedStorage.Modules.SongListUI.InstrumentIcons)

	if not success then
		return
	end

	local v11 = {}

	for _, image in ipairs(instrumentIcons.GetAll()) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = image
		table.insert(v11, imageLabel)
	end

	for i = 1, 4 do
		local set = {}
		ContentProvider2:PreloadAsync(v11, function(p, p2)
			if p2 ~= Enum.AssetFetchStatus.Success then
				set[p] = true
			end
		end)
		local v12 = {}

		for _, v13 in ipairs(v11) do
			if set[v13.Image] then
				table.insert(v12, v13)
			end
		end

		if #v12 == 0 then
			break
		end

		task.wait(i * 2)
		v11 = v12
	end
end)

local v11 = NewbieModePanelUI.new(v9.NewbieModeButtonInstance)
v9.NewbieModeRequested:Connect(function()
	v11:Toggle()
end)

v9.HeaderToggleChanged:Connect(function(p)
	ThemeState.Set(p and "3D" or "2D")
end)

ThemeState.OnChanged(function(p)
	v9:SetHeaderToggleState(p == "3D", true)
end)

local v12 = ConfirmDialog.new(songListScreenGui, { confirmText = "Switch", cancelText = "Cancel" })

local v13 = false

local mouseBehavior = nil

UISkin.Init({ songListScreenGui, songListToastGui, v11._panelScreenGui }, function()
	return songListScreenGui.Enabled
end)

v = UISkin.WatchPlayerGui
local Players4 = game:GetService("Players")
v(Players4.LocalPlayer:WaitForChild("PlayerGui"))

local function openMenu() -- 4 equivalent calls inferred from this helper
	UISkin.Refresh()
	songListScreenGui.Enabled = true
	SessionCameraSettings.SetMenuOpen(true)

	PlayerLoadingState.ReportSongListOpen(true)

	mouseBehavior = UserInputService.MouseBehavior
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
end

local function closeMenu() -- 6 equivalent calls inferred from this helper
	songListScreenGui.Enabled = false
	SessionCameraSettings.SetMenuOpen(false)
	PlayerLoadingState.ReportSongListOpen(false)

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	mouseBehavior = nil
end

local function toggleMenu()
	if songListScreenGui.Enabled then
		closeMenu() -- inferred equivalent call
	else
		openMenu() -- inferred equivalent call
	end
end

OpenSongMenuRequest.Event:Connect(toggleMenu)
v9.CloseRequested:Connect(closeMenu)

local flag = false
local v14 = false

local v15 = nil

local v16 = nil

local function revealSongAfterReopen(p) -- 1 equivalent call inferred from this helper
	task.spawn(function()
		RunService.RenderStepped:Wait()

		if not songListScreenGui.Enabled then
			return
		end

		if v9:GetSelectedSongId() ~= p then
			v16 = p
		end

		if not v9:RevealSong(p) then
			v16 = nil
		end
	end)
end

v9.BackingTrackRequested:Connect(function()
	if v14 or flag then
		return
	end

	v14 = true

	flag = true
	closeMenu() -- inferred equivalent call
	local success, result = pcall(function()
		return laptopOpenFromSongList:InvokeServer()
	end)

	v14 = false

	if not (success and result) then
		flag = false

		if not songListScreenGui.Enabled then
			openMenu() -- inferred equivalent call
		end
	end
end)

LaptopClientController.OnExit(function()
	if not flag then
		return
	end

	flag = false

	if not songListScreenGui.Enabled then
		openMenu() -- inferred equivalent call
	end

	local v17 = v15
	v15 = nil

	if v17 then
		revealSongAfterReopen(v17) -- inferred equivalent call
	end
end)

LaptopSongListController.OnBackingTrackStartRequested(function(_, p)
	if flag then
		v15 = p
	end
end)

RunService:BindToRenderStep("SongListMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
	if not songListScreenGui.Enabled or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		return
	end

	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	if not UserInputService.MouseIconEnabled then
		UserInputService.MouseIconEnabled = true
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or ModeManager.IsFreePlay() then
		return
	end

	if input.KeyCode == Enum.KeyCode.G and v13 then
		OpenSongMenuRequest:Fire()
	end

	if input.KeyCode == Enum.KeyCode.T then
		v6:TriggerJoin()
		v6:TriggerReady()
	elseif input.KeyCode == Enum.KeyCode.U then
		v6:TriggerDeny()
	end
end)

local v17 = nil

local v18 = "normal"

local v19 = {}

local syncDetailPanelOccupants

local fn

v9.Selected:Connect(function(p)
	v17 = p

	if p then
		syncDetailPanelOccupants(p)
	end

	fn()

	if not p then
		SongPreloadSignal.CancelSelected()

		return
	end

	local rawKey = SongConfigAdapter.GetRawKey(p)

	if rawKey then
		SongPreloadSignal.NotifySelected(rawKey)
	else
		SongPreloadSignal.CancelSelected()
	end
end)

songListScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if songListScreenGui.Enabled and v17 then
		syncDetailPanelOccupants(v17)
		fn()
	end
end)

local v20 = false
local v21 = nil
local v22 = nil

local v23 = nil

local v24 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and -78 or -120
local thread = nil

local function cancelNowPlayingAutoHide() -- 1 equivalent call inferred from this helper
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

local function refreshNowPlayingBar()
	cancelNowPlayingAutoHide() -- inferred equivalent call

	if not (v20 and v21) then
		v5:Hide()
		return
	end

	local song = SongConfigAdapter.GetSong(v21)
	local displayName = song and song.displayName or v21

	if songListScreenGui.Enabled then
		v5.Instance.Parent = window
		v5.Instance.AnchorPoint = Vector2.new(1, 1)
		v5.Instance.Position = UDim2.new(1, 0, 1, 0)
		v5:Show(displayName)
	else
		v5.Instance.Parent = songListToastGui

		v5.Instance.AnchorPoint = Vector2.new(0.5, 1)

		v5.Instance.Position = UDim2.new(0.5, 0, 1, v24)
		v5:Show(displayName)
		thread = task.delay(10, function()
			thread = nil
			v5:Hide()
		end)
	end
end

SongSessionStatusUpdate.OnClientEvent:Connect(function(p, p2)
	local v25 = v20
	v20 = p
	v21 = p and SongConfigAdapter.GetSongId(p2) or nil

	if p and not v25 and v21 then
		RecentlyPlayedClient.RecordPlayed(v21)
		closeMenu() -- inferred equivalent call
	end

	refreshNowPlayingBar()

	fn()
end)

songListScreenGui:GetPropertyChangedSignal("Enabled"):Connect(refreshNowPlayingBar)

v5.Instance.Active = false

local function attemptSelectSong(p, p2)
	local rawKey = SongConfigAdapter.GetRawKey(p)

	if not rawKey then
		warn("[SongListBootstrap] songId tidak dikenal SongConfig: " .. tostring(p))
		return
	end

	local song = SongConfigAdapter.GetSong(p)
	p = song and song.displayName or p
	v4:Show("Loading " .. p .. "...")

	SongPreloadSignal.NotifyCommit(rawKey)

	ClientSongPreloader.PreloadSongStems(rawKey, function(p3)
		p3 = p3 > 1 and p3 / 100 or p3
		v4:SetProgress(p3)

		if p3 >= 1 then
			v4:Hide()
		end
	end, {
		WarmChartInstrument = LocalPlayer:GetAttribute("EquippedInstrumentType")
	})

	SelectSong:FireServer(rawKey, p2 == true)
end

v12.Confirmed:Connect(function()
	if v22 then
		attemptSelectSong(v22, v23)
		closeMenu() -- inferred equivalent call
		v22 = nil
		v23 = nil
	end
end)

v12.Cancelled:Connect(function()
	v22 = nil
	v23 = nil
end)

local sounds = {}
local v25 = nil
local v26 = nil
local thread2 = nil
local count = 0
local FadeOut = PreviewConfig.Defaults.FadeOut

local v27 = {}

local flag2 = false

local applyDuck
local undoDuck

local function stopPreview(p)
	count += 1
	local v28 = v26 or v25
	v26 = nil
	v4:Hide()

	if v28 then
		v9:SetPreviewLoading(v28, false)
	end

	local v29 = thread2
	thread2 = nil

	if v29 and coroutine.running() ~= v29 then
		task.cancel(v29)
	end

	if v25 == nil then
		return
	end

	v25 = nil

	if not p then
		undoDuck()
	end

	local v30 = sounds
	sounds = {}
	local v31 = FadeOut

	if flag2 then
		flag2 = false

		for _, instance in ipairs(v30) do
			TweenService:Create(instance, TweenInfo.new(v31), { Volume = 0 }):Play()
		end
	else
		for _, instance in ipairs(v30) do
			TweenService:Create(instance, TweenInfo.new(v31), { Volume = 0 }):Play()
		end

		task.delay(v31, function()
			for _, v32 in ipairs(v30) do
				v32:Destroy()
			end
		end)
	end
end

local function startPreview(p)
	if v25 == p or v26 == p then
		return
	end

	stopPreview(true)

	local rawKey = SongConfigAdapter.GetRawKey(p)

	if not rawKey then
		return
	end

	applyDuck()

	local v28 = v27[p]

	if v28 and #v28.entries > 0 then
		local v29 = PreviewConfig.Get(rawKey)
		v25 = p
		flag2 = true
		FadeOut = v29.FadeOut
		sounds = {}

		for _, entry in ipairs(v28.entries) do
			TweenService:Create(entry.sound, TweenInfo.new(v29.FadeIn), {
				Volume = v29.Volume * entry.relativeVolume
			}):Play()
			table.insert(sounds, entry.sound)
		end

		thread2 = task.delay(v29.Duration, stopPreview)
	else
		local previewStems = SongConfigAdapter.GetPreviewStems(p)

		if #previewStems == 0 then
			return
		end

		local v29 = PreviewConfig.Get(rawKey)

		v26 = p
		count += 1
		local v30 = count

		local song = SongConfigAdapter.GetSong(p)
		local v31

		if song then
			v31 = song.displayName or p
		else
			v31 = p
		end

		v4:Show(v31 .. " (preview)...")
		v9:SetPreviewLoading(p, true)

		local v32 = {}

		for _, previewStem in ipairs(previewStems) do
			local sound = Instance.new("Sound")
			sound.Name = "SongPreview_" .. previewStem.instrumentType
			sound.SoundId = previewStem.assetId
			sound.Volume = 0
			sound.Parent = SoundService
			table.insert(v32, { sound = sound, relativeVolume = previewStem.relativeVolume })
		end

		task.spawn(function()
			local lastTime = os.clock()
			local v33 = nil
			local success, result = pcall(function()
				return GetSongElapsed:InvokeServer(rawKey)
			end)

			if success and typeof(result) == "number" then
				v33 = result
			end

			if v30 == count then
				local sounds2 = {}

				for _, v34 in ipairs(v32) do
					table.insert(sounds2, v34.sound)
				end

				ContentProvider:PreloadAsync(sounds2)

				if v30 == count then
					v4:Hide()
					v9:SetPreviewLoading(p, false)
					local timePosition = v33 or v29.StartOffset

					if v33 then
						timePosition = v33 + (os.clock() - lastTime)
					end

					for _, v35 in ipairs(v32) do
						v35.sound.TimePosition = timePosition
					end

					for _, v35 in ipairs(v32) do
						v35.sound:Play()
					end

					for _, v35 in ipairs(v32) do
						TweenService:Create(v35.sound, TweenInfo.new(v29.FadeIn), {
							Volume = v29.Volume * v35.relativeVolume
						}):Play()
						table.insert(sounds, v35.sound)
					end

					v26 = nil
					v25 = p
					FadeOut = v29.FadeOut
					thread2 = task.delay(v29.Duration, stopPreview)
					return
				end
			end

			v4:Hide()

			for _, v34 in ipairs(v32) do
				v34.sound:Destroy()
			end
		end)
	end
end

local function createLiveShadow(songId, k)
	if v27[songId] then
		return
	end

	local previewStems = SongConfigAdapter.GetPreviewStems(songId)

	if #previewStems == 0 then
		return
	end

	local v28 = { entries = {}, cancelled = false }
	v27[songId] = v28

	task.spawn(function()
		local lastTime = os.clock()
		local v29 = nil
		local success, result = pcall(function()
			return GetSongElapsed:InvokeServer(k)
		end)

		if success and typeof(result) == "number" then
			v29 = result
		end

		if v28.cancelled then
			return
		end

		local entries = {}

		for _, previewStem in ipairs(previewStems) do
			local sound = Instance.new("Sound")
			sound.Name = "SongPreviewShadow_" .. previewStem.instrumentType
			sound.SoundId = previewStem.assetId
			sound.Volume = 0
			sound.Parent = SoundService
			table.insert(entries, { sound = sound, relativeVolume = previewStem.relativeVolume })
		end

		local sounds2 = {}

		for _, v30 in ipairs(entries) do
			table.insert(sounds2, v30.sound)
		end

		ContentProvider:PreloadAsync(sounds2)

		if v28.cancelled then
			for _, v30 in ipairs(entries) do
				v30.sound:Destroy()
			end
		else
			local timePosition = not v29 and (v29 or 0) or v29 + (os.clock() - lastTime)

			for _, v30 in ipairs(entries) do
				v30.sound.TimePosition = timePosition
			end

			for _, v30 in ipairs(entries) do
				v30.sound:Play()
			end

			v28.entries = entries
		end
	end)
end

local function destroyLiveShadow(k)
	local v28 = v27[k]

	if not v28 then
		return
	end

	v27[k] = nil
	v28.cancelled = true

	for _, entry in ipairs(v28.entries) do
		entry.sound:Destroy()
	end

	if v25 == k and flag2 then
		v25 = nil
		flag2 = false
		sounds = {}
		local v29 = thread2
		thread2 = nil

		if v29 and coroutine.running() ~= v29 then
			task.cancel(v29)
		end

		undoDuck()
	end
end

v9.Selected:Connect(function(p)
	if p and p == v16 then
		v16 = nil
	elseif p then
		startPreview(p)
	else
		stopPreview()
	end
end)

songListScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not songListScreenGui.Enabled then
		stopPreview()
	end
end)

local fn2

local function proceedPlay(p, p2)
	if v20 and p ~= v21 then
		v22 = p
		v23 = p2
		local song = SongConfigAdapter.GetSong(v21)
		local displayName = song and song.displayName or v21 or "this song"
		v12:Show(
			"Switch Song?",
			string.format(
				"You are currently playing \"%s\". Switching songs will stop the current session.",
				displayName
			)
		)
	else
		stopPreview()
		attemptSelectSong(p, p2)
		closeMenu() -- inferred equivalent call
	end
end

v9.PlayRequested:Connect(function(p, p2)
	if v18 == "move" then
		local rawKey = SongConfigAdapter.GetRawKey(p)

		if rawKey and not (v19[rawKey] and v19[rawKey] > os.clock()) then
			MoveRoom:FireServer(rawKey)
			v19[rawKey] = os.clock() + 10
			fn()
		end
	elseif v18 == "request" then
		local rawKey = SongConfigAdapter.GetRawKey(p)

		if rawKey and not (v19[rawKey] and v19[rawKey] > os.clock()) then
			RequestSongChange:FireServer(rawKey)
			v19[rawKey] = os.clock() + 10
			fn()
		end
	else
		if v18 == "locked" or v18 == "instrument_locked" or fn2 and fn2(p, p2) then
			return
		end

		proceedPlay(p, p2)
	end
end)

local v28 = nil

local function findStudioId(instance)
	while instance do
		local studioId = instance:GetAttribute("StudioId")

		if studioId then
			return studioId
		end

		instance = instance.Parent
	end

	return nil
end

local v29 = nil

local v30 = {}

local v31 = nil

local count2 = 0

local v32 = {}

local function pushStagePlayerCount() -- 2 equivalent calls inferred from this helper
	local count3 = 0

	for _, v33 in pairs(v32) do
		if v33 then
			count3 += 1
		end
	end

	v9:SetStagePlayerCount(count3)
end

local fn3

local function applyRawOccupancy()
	pushStagePlayerCount() -- inferred equivalent call

	for _, v33 in ipairs(InstrumentList.DefaultOrder) do
		v9:SetInstrumentRawOccupant(v33, v32[v33])
	end

	if fn3 then
		fn3()
	end
end

local function applyPartyStatus() -- 1 equivalent call inferred from this helper
	for _, v33 in ipairs(InstrumentList.DefaultOrder) do
		v9:SetPartyStatus(v33, v30[v33])
	end
end

local function applyIsMine()
	for _, v33 in ipairs(InstrumentList.DefaultOrder) do
		v9:SetInstrumentIsMine(v33, v13 and v33 == v29)
	end
end

local function recomputePlayBlocked()
	for _, v33 in pairs(v30) do
		if v33 == "invited" or v33 == "loading" or v33 == "joined" then
			v9:SetPlayBlocked(true)
			return
		end
	end

	v9:SetPlayBlocked(false)
end

local v33 = nil

local v34 = nil

local function applyIsHost()
	for _, v35 in ipairs(InstrumentList.DefaultOrder) do
		v9:SetInstrumentIsHost(v35, v33 ~= nil and v32[v35] == v33)
	end
end

local v35 = {}

local function getInstrumentLockInfo()
	if not v28 or not v29 or v29 == "BVocal" then
		return nil
	end

	local v36 = v35[v28]

	if not v36 then
		return nil
	end

	for k, v37 in pairs(v36) do
		local song = SongConfigAdapter.GetSong(SongConfigAdapter.GetSongId(k))
		local instrumentAvailability = song and song.instrumentAvailability

		if not instrumentAvailability or instrumentAvailability[v29] then
			continue
		end

		local count3 = 0

		for k2, v38 in pairs(v37) do
			if k2 ~= "BVocal" and v38.PlayerName ~= "Admin" then
				count3 += 1
			end
		end

		if count3 >= 2 then
			local instrumentNames = {}

			for _, v39 in ipairs(InstrumentList.DefaultOrder) do
				if instrumentAvailability[v39] and v39 ~= "BVocal" then
					table.insert(instrumentNames, InstrumentList.DefaultNames[v39] or v39)
				end
			end

			return {
				songDisplayName = song.displayName or k,
				humans = count3,
				instrumentNames = instrumentNames
			}
		end
	end

	return nil
end

local function getCooldownRemaining(rawKey) -- 1 equivalent call inferred from this helper
	if not rawKey then
		return 0
	end

	local v36 = v19[rawKey]

	if not v36 then
		return 0
	end

	local v37 = math.ceil(v36 - os.clock())

	if v37 <= 0 then
		v19[rawKey] = nil
		return 0
	end

	return v37
end

local flag3 = false

local function ensureCooldownTicker() -- 1 equivalent call inferred from this helper
	if flag3 then
		return
	end

	flag3 = true
	task.spawn(function()
		repeat
			task.wait(1)
			local v36 = v17
			local v37 = v36 and SongConfigAdapter.GetRawKey(v36)

			if v37 and v19[v37] then
				fn()
			end

			local v38 = false

			for _, v40 in pairs(v19) do
				if os.clock() < v40 then
					v38 = true
					break
				end
			end
		until not v38

		flag3 = false
	end)
end

local flag4 = false

fn = function()
	v8:SetAdminName(v33)

	if v33 == nil or v33 ~= LocalPlayer.Name then
		if flag4 then
			flag4 = false
			v9:SetHostControls(false)
			v9:SetPartyRoomStatus(nil)
		end
	else
		if not flag4 then
			flag4 = true
			v9:SetHostControls(true)
		end

		v9:SetPartyRoomStatus(LocalPlayer.Name, true)
	end

	v9:SetFillOptionVisible(v33 == nil or v33 == LocalPlayer.Name)

	v9:SetFillHintAllowed(v13 and not v20)

	local instrumentLockInfo = getInstrumentLockInfo()

	if instrumentLockInfo then
		v9:SetSessionJoin(nil, nil)
		v18 = "instrument_locked"
		v9:SetPlayMode("instrument_locked")
		v9:SetPlayNotice((string.format(
			"\"%s\" is being played by %d players. Your instrument isn't in this song. Switch to %s to join, or wait until it ends.",
			instrumentLockInfo.songDisplayName,
			instrumentLockInfo.humans,
			table.concat(instrumentLockInfo.instrumentNames, ", ")
		)))
	else
		v9:SetPlayNotice(nil)

		local v37 = nil
		local v38 = nil

		if v33 == nil then
			local v39 = v28 and v35[v28] or nil
			local v40 = nil
			local count3 = 0

			if v39 then
				for k in pairs(v39) do
					count3 += 1
					v40 = k
				end
			end

			if count3 == 1 then
				v37 = SongConfigAdapter.GetSongId(v40)
				v38 = v20 and v21 == v37 and "Rejoin" or "Join"
			end
		end

		v9:SetSessionJoin(v37, v38)

		local v39 = v17

		local v40 = "normal"

		if v39 then
			local rawKey = SongConfigAdapter.GetRawKey(v39)
			local v41 = v28 and v35[v28] or nil
			v40 = rawKey and v41 and v41[rawKey] ~= nil and (v20 and v21 == v39 and "rejoin" or "join") or v40
		end

		if v39 and v34 then
			local rawKey = SongConfigAdapter.GetRawKey(v39)
			local v41 = rawKey == v34
			local v42 = v33 == LocalPlayer.Name
			local v43 = v42 and (v41 and "normal" or "move") or v41 and "locked" or "request"

			if v43 == "move" or v43 == "request" then
				local cooldownRemaining = getCooldownRemaining(rawKey) -- inferred equivalent call

				if cooldownRemaining > 0 then
					v18 = v43
					v9:SetPlayMode("cooldown_" .. v43, v33, cooldownRemaining)
					ensureCooldownTicker() -- inferred equivalent call
					return
				end
			end

			v18 = v43

			if v42 then
				v9:SetPlayMode(v43 == "normal" and v40 or v18)
			else
				v9:SetPlayMode(v18, v33)
			end
		else
			v18 = "normal"
			v9:SetPlayMode(v40)
		end
	end
end

v = ReplicatedStorage:WaitForChild("BackingTrackJoinRequest", 10)

if v then
	v.Event:Connect(function(value)
		if typeof(value) ~= "string" then
			return
		end

		local v36 = v28 and v35[v28] or nil

		if not v36 or v36[value] == nil or getInstrumentLockInfo() then
			return
		end

		local songId = SongConfigAdapter.GetSongId(value)

		if not songId or v20 and v21 == songId then
			return
		end

		attemptSelectSong(songId, false)
	end)
end

v = ReplicatedStorage:WaitForChild("Modules")
roomHudGui = require(v:WaitForChild("FillTutorial"))
v2 = require(v:WaitForChild("TutorialSpotlight"))
local SettingsState = require(v:WaitForChild("SettingsState"))
local GetFillTutorialContext = RemoteEvents:WaitForChild("GetFillTutorialContext")
local detailPanel = v9._detailPanel
local flag5 = false

local function rowFor(p) -- 2 equivalent calls inferred from this helper
	local instrumentList = detailPanel._instrumentList
	return instrumentList and instrumentList.rows and instrumentList.rows[p] or nil
end

local v36 = {
	getFlag = function()
		if flag5 then
			return true
		end

		return LocalPlayer:GetAttribute("TutorialFillDone")
	end,
	markFillDone = function()
		if flag5 then
			return
		end

		flag5 = true
		SettingsState.SetField("TutorialFillDone", true, true)
	end,
	isFreshPlay = function(p): boolean
		if v18 ~= "normal" or not v13 or v20 then
			return false
		end

		local rawKey = SongConfigAdapter.GetRawKey(p)
		local v37 = v28 and v35[v28] or nil
		return not (v37 and rawKey) or v37[rawKey] == nil
	end,
	inRoom = function(): boolean
		return v33 ~= nil
	end,
	partyFormed = function(): boolean
		for _, v37 in pairs(v30) do
			if v37 == "loading" or v37 == "joined" or v37 == "ready" then
				return true
			end
		end

		return false
	end,
	queryContext = function()
		local context = nil
		local v37 = false
		task.spawn(function()
			local success, result = pcall(function()
				return GetFillTutorialContext:InvokeServer()
			end)

			context = success and result or nil
			v37 = true
		end)
		local lastTime = os.clock()

		while not v37 and os.clock() - lastTime < 3 do
			task.wait(0.05)
		end

		return context
	end,
	proceed = function(p, p2)
		proceedPlay(p, p2)
	end,
	isMenuOpen = function()
		return songListScreenGui.Enabled
	end,
	isEquipped = function()
		return v13
	end,
	getSelectedSongId = function()
		return v9:GetSelectedSongId()
	end,
	getFillRow = function()
		return detailPanel._fillEmptyRow
	end,
	getPlayButton = function()
		return detailPanel._playButton and detailPanel._playButton.Instance or nil
	end,
	getInviteButton = function(p)
		local v37 = rowFor(p) -- inferred equivalent call
		return v37 and v37.button and v37.button.Instance or nil
	end,
	isRowAvailable = function(p): boolean
		local v37 = rowFor(p) -- inferred equivalent call
		return v37 ~= nil and v37.available == true
	end,
	getInstrumentName = function(p)
		return InstrumentList.DefaultNames and InstrumentList.DefaultNames[p] or p
	end,
	isFillOn = function()
		return detailPanel:GetFillEmptyBackingTrack()
	end,
	isFillLocked = function()
		return detailPanel._isFillLocked()
	end,
	getPartyStatus = function(p)
		return v30[p]
	end,
	cancelInvite = function(p)
		CancelInvite:FireServer(p)
	end,
	onFillToggled = function(onFillEmptyToggled)
		detailPanel.FillEmptyToggled:Connect(onFillEmptyToggled)
	end
}

local v37 = roomHudGui.new(v2.new(nil, "FillTutorialSpotlightGui"), v36)

LocalPlayer:GetAttributeChangedSignal("TutorialFillDone"):Connect(function()
	if LocalPlayer:GetAttribute("TutorialFillDone") == false then
		flag5 = false
	end
end)
fn2 = function(p, p2): boolean
	local success, result = pcall(v37.OnPlayRequested, v37, p, p2)

	if success then
		return result == true
	end

	warn("[FillTutorial] error, Play dilanjutkan normal:", result)
	return false
end

local function getSongDisplayNameFromRawKey(p) -- 3 equivalent calls inferred from this helper
	local songId = SongConfigAdapter.GetSongId(p)
	local v38 = songId and SongConfigAdapter.GetSong(songId)
	return v38 and v38.displayName or p
end

ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LaptopBackingTrackStarted").OnClientEvent:Connect(function(_, value, value2)
	if typeof(value) ~= "string" or typeof(value2) ~= "string" then
		return
	end

	local songId = SongConfigAdapter.GetSongId(value)
	local v38 = songId and SongConfigAdapter.GetSong(songId)
	value = v38 and v38.displayName or value

	if v38 and v38.artist and v38.artist ~= "" then
		value = v38.artist .. " - " .. value
	end

	v7:ShowBackingTrackStarted(value2, value)
end)

RoomStateUpdate.OnClientEvent:Connect(function(p, p2, p3)
	if p ~= v28 then
		return
	end

	local v38 = v34
	v33 = p2
	v34 = p3
	fn()
	applyIsHost()

	if p3 and v38 and p3 ~= v38 then
		p3 = getSongDisplayNameFromRawKey(p3) -- inferred equivalent call
		v7:ShowSwitch(p3)
	elseif not p3 then
		v7:Hide()
	end
end)

SongMoveRequestNotify.OnClientEvent:Connect(function(p, p2)
	local songId = SongConfigAdapter.GetSongId(p2)
	local v38 = songId and SongConfigAdapter.GetSong(songId)
	local v39

	if v38 then
		v39 = v38.displayName or p2
	else
		v39 = p2
	end

	v7:ShowRequest(p, v39, function()
		if v19[p2] and v19[p2] > os.clock() then
			return
		end

		MoveRoom:FireServer(p2)
		v19[p2] = os.clock() + 10
		openMenu() -- inferred equivalent call
		local songId2 = SongConfigAdapter.GetSongId(p2)

		if songId2 then
			v9:SelectSong(songId2)
		end

		fn()
	end)
end)

SongRequestBroadcast.OnClientEvent:Connect(function(p, p2)
	p2 = getSongDisplayNameFromRawKey(p2) -- inferred equivalent call
	v7:ShowSongRequested(p, p2)
end)

local volumesBySound = {}

undoDuck = function()
	for instance, volume in pairs(volumesBySound) do
		if instance.Parent then
			TweenService:Create(instance, TweenInfo.new(0.4), { Volume = volume }):Play()
		end
	end

	volumesBySound = {}
end

applyDuck = function()
	if not v28 then
		return
	end

	for _, sound in ipairs(workspace:GetDescendants()) do
		if not sound:IsA("Sound") then
			continue
		end

		local v38 = sound
		local studioId

		while true do
			if not v38 then
				studioId = nil
				break
			end

			studioId = v38:GetAttribute("StudioId")

			if studioId then
				break
			end

			v38 = v38.Parent
		end

		if not (studioId == v28 and volumesBySound[sound] == nil) then
			continue
		end

		volumesBySound[sound] = sound.Volume
		TweenService:Create(sound, TweenInfo.new(0.4), {
			Volume = sound.Volume * 0.15
		}):Play()
	end
end

local v38 = {}

local function buildSessionCardText(p)
	local v39 = {}

	for _, v40 in ipairs(InstrumentList.DefaultOrder) do
		local v41 = p[v40]

		if not v41 then
			continue
		end

		local v42 = InstrumentList.DefaultNames[v40] or v40

		if v41.PlayerName == "Admin" then
			table.insert(v39, string.format("@auto : %s", v42))
		else
			table.insert(v39, string.format("@%s - %s", v41.PlayerName, v42))
		end
	end

	if #v39 == 0 then
		return nil
	end

	return "In Session: " .. table.concat(v39, "  ")
end

syncDetailPanelOccupants = function(p)
	local rawKey = SongConfigAdapter.GetRawKey(p)
	local v39 = rawKey and v28 and v35[v28] and v35[v28][rawKey] or nil

	for _, v40 in ipairs(InstrumentList.DefaultOrder) do
		local v41 = v39 and v39[v40]

		if v41 then
			v9:SetInstrumentOccupant(v40, v41.PlayerName == "Admin" and "auto" or v41.PlayerName)
		else
			v9:SetInstrumentOccupant(v40, nil)
		end
	end
end

fn3 = function()
	local v39 = {}
	local v40 = v28 and v35[v28] or nil

	if v40 then
		for k, v41 in pairs(v40) do
			local v42 = {}

			for k2, v43 in pairs(v41) do
				v42[k2] = v43.PlayerName == "Admin" and "auto" or "playing"
			end

			v39[SongConfigAdapter.GetSongId(k)] = v42
		end
	end

	local v41 = {}

	for k, v42 in pairs(v32) do
		if v42 then
			v41[k] = "equipped"
		end
	end

	v9:SetInstrumentStates(v39, v41)

	local success, toastStyle = pcall(require, ReplicatedStorage.Modules.SongListUI.ToastStyle)

	if success then
		for k, v42 in pairs(v32) do
			if v42 then
				toastStyle.LastInstrument[string.lower((tostring(v42)))] = k
			end
		end
	end
end

local success, toastStyle = pcall(require, ReplicatedStorage.Modules.SongListUI.ToastStyle)

if success then
	function toastStyle.InstrumentResolver(value, p)
		local set = {}
		local function addName(value2) -- 4 equivalent calls inferred from this helper
			if type(value2) == "string" and value2 ~= "" then
				set[string.lower(value2)] = true
			end
		end

		if type(value) == "string" then
			addName(value) -- inferred equivalent call
		elseif type(value) == "table" then
			addName(value.name) -- inferred equivalent call
		end

		local playerByUserId = p and Players:GetPlayerByUserId(p)

		if playerByUserId then
			addName(playerByUserId.Name) -- inferred equivalent call
			addName(playerByUserId.DisplayName) -- inferred equivalent call
		end

		for k, v39 in pairs(v32) do
			if v39 and set[string.lower((tostring(v39)))] then
				return k
			end
		end

		for k in pairs(set) do
			local v39 = toastStyle.LastInstrument[k]

			if v39 then
				return v39
			end
		end

		return nil
	end
end

local function refreshSessionInfoDisplay()
	fn3()
	local v39 = v28 and v35[v28] or nil

	local songIdSet = {}

	if v39 then
		for k, v40 in pairs(v39) do
			local songId = SongConfigAdapter.GetSongId(k)
			songIdSet[songId] = true
			v9:UpdateSong(songId, { isInSession = true, sessionText = buildSessionCardText(v40) })

			createLiveShadow(songId, k)
		end
	end

	for k in pairs(v38) do
		if songIdSet[k] then
			continue
		end

		v9:UpdateSong(k, { isInSession = false, sessionText = nil })

		destroyLiveShadow(k)
	end

	v38 = songIdSet

	if not v39 or next(v39) == nil then
		v9:SetSessionInfo(nil)
		return
	end

	local v40 = {}

	for displayName, _ in pairs(v39) do
		local songId = SongConfigAdapter.GetSongId(displayName)
		local song = SongConfigAdapter.GetSong(songId)
		displayName = song and song.displayName or displayName

		table.insert(v40, string.format("<font color=\"#F0B446\">%s</font>", displayName))
	end

	table.sort(v40)

	v9:SetSessionInfo("<font color=\"#58D296\">Song In Session: </font>" .. table.concat(v40, "  •  "))
end

InstrumentHUDUpdate.OnClientEvent:Connect(function(p, p2, instance)
	v13 = p
	local studioId

	if p and instance then
		while true do
			if not instance then
				studioId = nil
				break
			end

			studioId = instance:GetAttribute("StudioId")

			if studioId then
				break
			end

			instance = instance.Parent
		end

		if not studioId then
			studioId = nil
		end
	end

	v28 = studioId
	v29 = p and p2 or nil
	applyIsMine()
	refreshSessionInfoDisplay()

	if p then
		task.spawn(function()
			local v39 = v28
			local success2, result = pcall(function()
				return GetStudioEquipSnapshot:InvokeServer(v39)
			end)

			if success2 and typeof(result) == "table" and v28 == v39 then
				v32 = result
				applyRawOccupancy()
				applyIsHost()
			end
		end)
	else
		table.clear(v30)
		applyPartyStatus() -- inferred equivalent call
		v9:SetPlayBlocked(false)
		v6:Hide()
		v9:SetPartyRoomStatus(nil)
		v31 = nil
		count2 += 1
		table.clear(v32)
		applyRawOccupancy()
		applyIsHost()

		v33 = nil
		v34 = nil
		fn()
	end

	if v17 then
		syncDetailPanelOccupants(v17)
	end

	fn()

	v9:SetInstrumentFilter(p and p2 or nil)

	if not p then
		closeMenu() -- inferred equivalent call
	end
end)

v9.InviteRequested:Connect(function(p)
	InvitePlayer:FireServer(p, (SongConfigAdapter.GetRawKey(v17)))
end)

v9.PartyExitRequested:Connect(function()
	if v33 ~= nil and v33 == LocalPlayer.Name then
		CloseRoom:FireServer()
	elseif v31 then
		RespondToInvite:FireServer(v31, false)
	end
end)

v9.CancelInviteRequested:Connect(function(p)
	CancelInvite:FireServer(p)
end)

v9.KickRequested:Connect(function(p)
	KickFromRoom:FireServer(p)
end)

StudioEquipUpdate.OnClientEvent:Connect(function(p, p2, p3)
	if p ~= v28 then
		return
	end

	v32[p2] = p3
	pushStagePlayerCount() -- inferred equivalent call
	v9:SetInstrumentRawOccupant(p2, p3)

	if fn3 then
		fn3()
	end

	applyIsHost()
end)

v6.JoinPressed:Connect(function()
	if v31 then
		RespondToInvite:FireServer(v31, true)
	end
end)

v6.DenyPressed:Connect(function()
	if v31 then
		RespondToInvite:FireServer(v31, false)
	end
end)

local v39 = ReadyButtonUI.new()

v39.Pressed:Connect(function()
	if v31 then
		SetReadyForInstrument:FireServer(v31)
	end
end)

local function refreshReadyButton()
	local v40 = v31 and v30[v31] or nil
	local v41

	if v28 ~= nil then
		v41 = v35[v28] or nil
	end

	local v42

	if v41 == nil or v34 == nil then
		v42 = false
	else
		v42 = v41[v34] ~= nil
	end

	if v40 == "joined" then
		v39:SetState("available")
	elseif v40 == "ready" and not v42 then
		v39:SetState("ready")
	else
		v39:SetState(nil)
	end
end

InvitePartyUpdate.OnClientEvent:Connect(function()
	task.defer(refreshReadyButton)
end)
StudioSessionUpdate.OnClientEvent:Connect(function()
	task.defer(refreshReadyButton)
end)
RoomStateUpdate.OnClientEvent:Connect(function()
	task.defer(refreshReadyButton)
end)

v6.ReadyPressed:Connect(function()
	if v31 then
		SetReadyForInstrument:FireServer(v31)
	end
end)

v = ReplicatedStorage:WaitForChild("Modules")
local TutorialSpotlight = require(v:WaitForChild("TutorialSpotlight"))
local TipState = require(v:WaitForChild("TipState"))
local v40 = TipState.ForLocalPlayer()
local BackingTrackJoinRequest = ReplicatedStorage:WaitForChild("BackingTrackJoinRequest", 10)

local color = Color3.fromRGB(104, 178, 112)
local color2 = Color3.fromRGB(236, 180, 72)
local color3 = Color3.fromRGB(14, 13, 12)

local v41 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local Escape = TutorialSpotlight.Escape

local v42 = TutorialSpotlight.new(nil, "LiveSongHintSpotlightGui")
local v43 = nil
local v44 = nil
local v45 = nil

local function liveSongHere()
	local v46 = v28 and v35[v28] or nil

	if not v46 then
		return nil
	end

	local v47 = {}

	for k in pairs(v46) do
		table.insert(v47, k)
	end

	table.sort(v47)
	return v47[1]
end

local function liveHintWanted()
	if not v13 or v20 or v28 == nil or LocalPlayer:GetAttribute("TutorialFillDone") ~= false then
		return nil
	end

	if v33 == nil and v31 == nil then
		return liveSongHere()
	end

	return nil
end

local function hideLiveHint() -- 2 equivalent calls inferred from this helper
	if v44 then
		v44 = nil
		v42:Hide()
	end
end

local function showLiveHint(p)
	local songId = SongConfigAdapter.GetSongId(p)
	local v46 = songId and SongConfigAdapter.GetSong(songId)
	local v47

	if v46 then
		v47 = v46.displayName or p
	else
		v47 = p
	end

	if v46 and v46.artist and v46.artist ~= "" then
		v47 = v46.artist .. " - " .. v47
	end

	local v48 = InstrumentList.DefaultNames and InstrumentList.DefaultNames[v29] or tostring(v29)
	v44 = p
	v42:Show({
		title = "The band is playing!",
		body = string.format(
			"<b>%s</b> is live, and your <b>%s</b> is silent. Press <b>JOIN</b> to jump in, or wait for the song to end.",
			Escape(v47),
			Escape(v48)
		),
		tag = "TUTORIAL",
		accent = color,
		anchor = "bottom",
		autoHide = 20,
		buttons = {
			{
				text = "JOIN",
				color = color,
				textColor = color3,
				onClick = function()
					hideLiveHint() -- inferred equivalent call

					if BackingTrackJoinRequest then
						BackingTrackJoinRequest:Fire(p)
					end
				end
			},
			{
				text = "LATER",
				onClick = function()
					if v44 then
						v44 = nil
						v42:Hide()
					end
				end
			}
		},
		onAutoHide = function()
			v44 = nil
		end
	})
end

local function liveHintTick()
	if v13 then
		v45 = v45 or os.clock()
	else
		v45 = nil
	end

	if (v13 and liveSongHere() or nil) == nil then
		v43 = nil
	end

	local v46

	if
		v13
		and not v20
		and v28 ~= nil
		and LocalPlayer:GetAttribute("TutorialFillDone") == false
		and v33 == nil
		and v31 == nil
	then
		v46 = liveSongHere()
	end

	if v44 then
		if v46 ~= v44 then
			hideLiveHint() -- inferred equivalent call
		end
	else
		if not v46 or v46 == v43 or (not v45 or os.clock() - v45 < 1.5) then
			return
		end

		if songListScreenGui.Enabled or TutorialSpotlight.AnyShowing() then
			return
		end

		v43 = v46
		showLiveHint(v46)
	end
end

local v46 = TutorialSpotlight.new(nil, "ReadyTipSpotlightGui")
local count3 = 0

local function readyTipTick()
	local v47 = v31 and v30[v31] or nil

	if v47 ~= "joined" and v47 ~= "ready" then
		count3 = 0
	end

	if v46:IsShowing() then
		if v47 == "ready" then
			v46:Hide()
			v40:MarkSeen("ready_invite")
		elseif v47 ~= "joined" then
			v46:Hide()
		end
	else
		if v40:IsSeen("ready_invite") ~= false then
			return
		end

		if v47 == "ready" then
			v40:MarkSeen("ready_invite")
			return
		end

		if v47 ~= "joined" or count3 >= 3 or TutorialSpotlight.AnyShowing() then
			return
		end

		local button = v39:GetButton()

		if not TutorialSpotlight.IsShown(button) then
			return
		end

		count3 += 1
		v40:NoteShown()
		v46:Show({
			target = button,
			title = "You're in! Now press READY",
			body = v41 and "Tap <b>READY</b> to lock in. The host can only start the song once everyone is ready." or "Click <b>READY</b> (or press <b>T</b>) to lock in. The host can only start the song once everyone is ready.",
			tag = "TUTORIAL",
			accent = color2,
			padding = 8,
			side = "above",
			dim = true,
			block = false,
			onTargetLost = function() end
		})
	end
end

task.spawn(function()
	while true do
		task.wait(0.5)
		local success2, result = pcall(function()
			liveHintTick()
			readyTipTick()
		end)

		if not success2 then
			warn("[PlayerHints] tick error:", result)
		end
	end
end)

InvitePartyUpdate.OnClientEvent:Connect(function(p, warmChartInstrument, p2, p3, value, value2, p4, p5)
	if p ~= v28 then
		return
	end

	local v47 = v30[warmChartInstrument]

	if p2 then
		v30[warmChartInstrument] = p2
	else
		v30[warmChartInstrument] = nil
	end

	v9:SetPartyStatus(warmChartInstrument, p2)
	recomputePlayBlocked()

	if p3 and p3 ~= LocalPlayer.Name then
		if p2 == "joined" then
			if v47 ~= "ready" then
				v7:ShowPlayerJoined(p3)
			end
		elseif p2 == "ready" then
			v7:ShowPlayerReady(p3)
		elseif p2 == nil and not p4 and (v47 == "loading" or v47 == "joined" or v47 == "ready") then
			if p5 == "kick" then
				v7:ShowPlayerKicked(p3)
			else
				v7:ShowPlayerLeft(p3)
			end
		end
	end

	if p3 == LocalPlayer.Name then
		if p2 then
			v33 = value
			v34 = value2
			fn()
			applyIsHost()
		end

		if p2 == "invited" then
			v31 = warmChartInstrument
			local v48

			if typeof(value2) == "string" then
				value2 = getSongDisplayNameFromRawKey(value2) -- inferred equivalent call
				v48 = value2 or nil
			end

			v6:ShowInvite(value or "Someone", v48)
		elseif p2 == "loading" then
			v31 = warmChartInstrument

			v9:SetPartyRoomStatus(value)

			count2 += 1
			local v48 = count2
			v6:ShowLoading(0)

			task.spawn(function()
				if typeof(value2) == "string" then
					ClientSongPreloader.PreloadSongStems(value2, function(p6)
						if v48 == count2 and v31 == warmChartInstrument then
							v6:UpdateLoadingPercent(p6)
						end
					end, { WarmChartInstrument = warmChartInstrument })
				else
					warn("[SongListBootstrap] Invite tanpa songName valid -- skip preload, langsung lapor selesai.")
				end

				if v48 == count2 and v31 == warmChartInstrument then
					ReportLoadingComplete:FireServer(warmChartInstrument)
				end
			end)
		elseif p2 == "joined" and v31 == warmChartInstrument then
			v6:ShowJoinedWaitingReady()
		elseif p2 == "ready" and v31 == warmChartInstrument then
			count2 += 1
			v6:Hide()
			v9:SetPartyRoomStatus(value)
		elseif p2 == nil and v31 == warmChartInstrument then
			count2 += 1
			v6:Hide()
			v9:SetPartyRoomStatus(nil)
			v31 = nil

			if p4 and p4 ~= LocalPlayer.Name then
				v7:ShowRoomClosed(p4)
			elseif p5 == "kick" then
				v7:ShowKicked(value or "Host")
			elseif p5 == "cancel" then
				v7:ShowInviteCancelled(value or "Host")
			end

			v33 = nil
			v34 = nil
			fn()
			applyIsHost()
		end
	end
end)

StudioSessionUpdate.OnClientEvent:Connect(function(p, p2, options)
	local v47 = options or {}
	v35[p] = v35[p] or {}

	if next(v47) == nil then
		v35[p][p2] = nil
	else
		v35[p][p2] = v47
	end

	refreshSessionInfoDisplay()

	local songId = SongConfigAdapter.GetSongId(p2)

	if songId == v17 then
		syncDetailPanelOccupants(songId)
	end

	fn()
end)

StudioLoadProgressUpdate.OnClientEvent:Connect(function(_, p, p2, p3, p4)
	if SongConfigAdapter.GetSongId(p) ~= v17 then
		return
	end

	v9:SetInstrumentOccupant(p2, p3, p4)
end)