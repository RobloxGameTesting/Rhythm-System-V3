local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local FreePlaySoundAdapter = require(ReplicatedStorage.Modules.FreePlaySoundAdapter)
local FreePlayController = require(ReplicatedStorage.Modules.FreePlayController)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)
local LoadingToast = require(ReplicatedStorage.Modules.SongListUI.LoadingToast)
local ClientSongPreloader = require(ReplicatedStorage.Modules.ClientSongPreloader)
local PlayerLoadingState = require(ReplicatedStorage.Modules.PlayerLoadingState)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ReportFreePlayPreloadHistory = RemoteEvents:WaitForChild("ReportFreePlayPreloadHistory")
local GetFreePlayPreloadHistory = RemoteEvents:WaitForChild("GetFreePlayPreloadHistory")

local FreePlayAssetPreloader = {}

local set = {}

local set2 = {}

local function buildKey(p, value) -- 8 equivalent calls inferred from this helper
	return tostring(p) .. "::" .. tostring(value or "Default")
end

local toast = nil
local function ensureToast() -- 1 equivalent call inferred from this helper
	if toast then
		return toast
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local freePlayAssetLoadingToastGui = Instance.new("ScreenGui")
	freePlayAssetLoadingToastGui.Name = "FreePlayAssetLoadingToastGui"
	freePlayAssetLoadingToastGui.ResetOnSpawn = false
	freePlayAssetLoadingToastGui.DisplayOrder = 60
	freePlayAssetLoadingToastGui.Parent = playerGui
	toast = LoadingToast.new(freePlayAssetLoadingToastGui)
	return toast
end

local flag = false
local v = false
local function loadPersistedHistory()
	if flag then
		return
	end

	flag = true
	local success, result = pcall(function()
		return GetFreePlayPreloadHistory:InvokeServer()
	end)

	if success and type(result) == "table" then
		for _, v2 in ipairs(result) do
			if type(v2) == "string" then
				set[v2] = true
			end
		end
	end

	v = true
end
task.spawn(loadPersistedHistory)

function FreePlayAssetPreloader.IsPreloaded(p, value): boolean
	local key = buildKey(p, value) -- inferred equivalent call
	return set[key] == true or set2[key] == true
end

local v2 = {}

function FreePlayAssetPreloader.OnPreloadComplete(p)
	table.insert(v2, p)
end

local function fireCompletionListeners(p, value)
	for _, callback in ipairs(v2) do
		task.spawn(callback, p, value)
	end
end

local freePlayWarmSoundPool = nil
local function getWarmFolder() -- 1 equivalent call inferred from this helper
	if freePlayWarmSoundPool then
		return freePlayWarmSoundPool
	end

	freePlayWarmSoundPool = Instance.new("Folder")
	freePlayWarmSoundPool.Name = "FreePlayWarmSoundPool"

	local RunService = game:GetService("RunService")

	if RunService:IsRunning() then
		freePlayWarmSoundPool.Parent = ReplicatedStorage
	end

	return freePlayWarmSoundPool
end

local v3 = { 1, 2, 4, 8, 10 }

local function preloadChunkUntilSuccess(list)
	local v4 = list
	local count = 0

	while #v4 > 0 do
		count += 1
		local v5 = {}
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(v4, function(p, p2)
				v5[p] = p2
			end)
		end)

		local v6 = {}

		for _, v7 in ipairs(v4) do
			if not v7.Parent then
				continue
			end

			local v8 = false

			if success then
				local v9 = v5[v7.SoundId]
				v8 = v9 == Enum.AssetFetchStatus.Success or (v9 == nil and v7.IsLoaded and true or false)
			end

			if not v8 then
				table.insert(v6, v7)
			end
		end

		if #v6 == 0 then
			break
		end

		if count == 1 or count % 6 == 0 then
			warn(("[FreePlayAssetPreloader] %d/%d asset belum berhasil dimuat (percobaan %d%s) -- retry otomatis sampai berhasil"):format(
				#v6,
				#list,
				count,
				success and "" or ", error: " .. tostring(result)
			))
		end

		v4 = v6
		task.wait(v3[math.min(count, #v3)])
	end
end

local RunService = game:GetService("RunService")
local v4 = nil
local count = 0
local v5 = {}
local v6 = {}

function FreePlayAssetPreloader.SetActiveKey(instrumentType, value)
	if not (instrumentType and RunService:IsRunning()) then
		return
	end

	local key = buildKey(instrumentType, value) -- inferred equivalent call

	if v4 and v4.key == key then
		return
	end

	local success, preloadAssetList = pcall(FreePlaySoundAdapter.GetPreloadAssetList, instrumentType, value)

	if not success or type(preloadAssetList) ~= "table" or #preloadAssetList == 0 then
		return
	end

	local v7 = v4

	if v7 and not v7.ready then
		v5[v7.folder] = nil
		v7.folder:Destroy()
	end

	count += 1
	local v8 = count
	local freePlayActiveHold = Instance.new("Folder")
	freePlayActiveHold.Name = "FreePlayActiveHold"
	freePlayActiveHold.Parent = ReplicatedStorage
	v5[freePlayActiveHold] = true
	local v9 = {
		key = key,
		instrumentType = instrumentType,
		toneName = value,
		folder = freePlayActiveHold,
		startedAt = os.clock(),
		ready = false
	}

	v4 = v9

	task.spawn(function()
		local count2 = #preloadAssetList
		local total = 1

		while total <= count2 do
			if count ~= v8 then
				return
			end

			for i = total, math.min(total + 6 - 1, count2) do
				local sound = Instance.new("Sound")
				sound.Name = "Hold_" .. tostring(i)
				sound.SoundId = preloadAssetList[i]
				sound.Volume = 0
				sound.Parent = freePlayActiveHold
			end

			total += 6
			task.wait()
		end

		local v10 = os.clock() + 20

		while count == v8 and os.clock() < v10 do
			local flag2 = true

			for _, child in ipairs(freePlayActiveHold:GetChildren()) do
				if not child.IsLoaded then
					flag2 = false
					break
				end
			end

			if flag2 then
				break
			end

			task.wait(0.1)
		end

		if count ~= v8 then
			return
		end

		v9.ready = true
		v6[instrumentType] = { tone = value }

		for k in pairs(v5) do
			if k == freePlayActiveHold then
				continue
			end

			v5[k] = nil
			k:Destroy()
		end
	end)
end

function FreePlayAssetPreloader.GetEffectiveTone(p, value)
	if not v4 or p == "Drum" or (v4.ready or v4.key ~= buildKey(p, value)) then -- inferred equivalent call
		return value
	end

	if os.clock() - v4.startedAt > 8 then
		return value
	end

	local v7 = v6[p]

	if v7 and buildKey(p, v7.tone) ~= v4.key then -- inferred equivalent call
		return v7.tone
	end

	return value
end

local function preloadRaw(p, value, fn)
	local preloadAssetList = FreePlaySoundAdapter.GetPreloadAssetList(p, value)
	local count2 = #preloadAssetList

	if count2 == 0 then
		if fn then
			fn(1)
		end
	else
		if fn then
			fn(0)
		end

		local warmFolder = getWarmFolder() -- inferred equivalent call
		local total = 0

		while total < count2 do
			local v7 = {}

			for i = total + 1, math.min(total + 12, count2) do
				local sound = Instance.new("Sound")
				sound.Name = "Warm_" .. tostring(i)
				sound.SoundId = preloadAssetList[i]
				sound.Volume = 0
				sound.Parent = warmFolder
				table.insert(v7, sound)
			end

			preloadChunkUntilSuccess(v7)

			if RunService:IsRunning() then
				local v8

				if v4 == nil then
					v8 = false
				else
					v8 = v4.key == buildKey(p, value) -- inferred equivalent call
				end

				if not v8 then
					for _, v9 in ipairs(v7) do
						v9:Destroy()
					end
				end
			end

			total += #v7

			if fn then
				fn(total / count2)
			end
		end
	end
end

local count2 = 0

local function setChatInputBarEnabled(enabled) -- 5 equivalent calls inferred from this helper
	local TextChatService = game:GetService("TextChatService")
	local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")

	if chatInputBarConfiguration then
		chatInputBarConfiguration.Enabled = enabled
	end
end

local function forceEnableChatDuringLoad()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		setChatInputBarEnabled(true) -- inferred equivalent call
	end)
end

local function restoreChatLockState()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		setChatInputBarEnabled(not ModeManager.IsFreePlay()) -- inferred equivalent call
	end)
end

local v7 = {}

local function runJob(p, value)
	local key = buildKey(p, value) -- inferred equivalent call
	local v8 = v7[key]

	if v8 then
		return v8
	end

	local v9 = { done = false, fraction = 0, listeners = {} }
	v7[key] = v9
	task.spawn(function()
		preloadRaw(p, value, function(fraction)
			v9.fraction = fraction

			for _, callback in ipairs(v9.listeners) do
				pcall(callback, fraction)
			end
		end)
		v9.done = true
		v7[key] = nil

		set[key] = true
		fireCompletionListeners(p, value)

		pcall(function()
			ReportFreePlayPreloadHistory:FireServer(key)
		end)
	end)
	return v9
end

function FreePlayAssetPreloader.EnsureLoaded(p, value, value2)
	if not p then
		return
	end

	FreePlayAssetPreloader.SetActiveKey(p, value)
	local key = buildKey(p, value) -- inferred equivalent call
	count2 += 1
	local v8 = count2

	if set[key] or set2[key] then
		local v9 = toast

		if v9 then
			v9:Hide()
		end

		FreePlayController.SetEnabled(true)
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			setChatInputBarEnabled(not ModeManager.IsFreePlay()) -- inferred equivalent call
		end)
	else
		local v9 = PlayerLoadingState.Begin("freeplay")

		FreePlayController.SetEnabled(false)
		local toast2 = ensureToast() -- inferred equivalent call

		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			setChatInputBarEnabled(true) -- inferred equivalent call
		end)

		toast2:Show(value2 or "Loading Free Play assets...")

		local v10 = runJob(p, value)
		local function onProgress(fraction) -- 1 equivalent call inferred from this helper
			if v8 ~= count2 then
				return
			end

			toast2:SetProgress(fraction)
		end
		table.insert(v10.listeners, onProgress)
		onProgress(v10.fraction) -- inferred equivalent call

		task.spawn(function()
			local v11 = os.clock() + 45

			while not v10.done and os.clock() < v11 do
				task.wait(0.1)
			end

			if v8 ~= count2 then
				PlayerLoadingState.End(v9)
				return
			end

			if not v10.done then
				set2[key] = true
				fireCompletionListeners(p, value)
				warn(("[FreePlayAssetPreloader] %s belum selesai penuh setelah %ds -- input dilepas, retry jalan di latar belakang."):format(
					key,
					45
				))

				ClientSongPreloader.ShowInfoToast(
					"Some Free Play sounds are still loading — you can play, retrying in the background",
					6
				)
			end

			toast2:Hide()
			FreePlayController.SetEnabled(true)
			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
				setChatInputBarEnabled(not ModeManager.IsFreePlay()) -- inferred equivalent call
			end)

			PlayerLoadingState.End(v9)
		end)
	end
end

local set3 = {}

function FreePlayAssetPreloader.PreloadInBackground(p, value)
	if not p then
		return
	end

	local key = buildKey(p, value) -- inferred equivalent call

	if set[key] or set3[key] then
		return
	end

	set3[key] = true

	runJob(p, value)
end

local v8 = {
	{ InstrumentType = "GuitarLead", ToneName = nil },
	{ InstrumentType = "GuitarLead", ToneName = "AcousticSteel" },
	{ InstrumentType = "GuitarLead", ToneName = "AkustikNylon" },
	{ InstrumentType = "GuitarLead", ToneName = "ElectricClean" },
	{ InstrumentType = "GuitarLead", ToneName = "ElectricJazz" },
	{ InstrumentType = "GuitarRhythm", ToneName = nil },
	{ InstrumentType = "GuitarRhythm", ToneName = "AcousticSteel" },
	{ InstrumentType = "GuitarRhythm", ToneName = "AkustikNylon" },
	{ InstrumentType = "GuitarRhythm", ToneName = "ElectricClean" },
	{ InstrumentType = "GuitarRhythm", ToneName = "ElectricJazz" },
	{ InstrumentType = "Bass", ToneName = "Finger" },
	{ InstrumentType = "Bass", ToneName = "Pick" },
	{ InstrumentType = "Bass", ToneName = "Fretless" },
	{ InstrumentType = "Bass", ToneName = "Slap" },
	{ InstrumentType = "Drum", ToneName = "Normal" },
	{ InstrumentType = "Piano", ToneName = "AccousticGrand" },
	{ InstrumentType = "Piano", ToneName = "HonkyTonk" },
	{ InstrumentType = "Piano", ToneName = "UprightPiano" }
}

local flag2 = false

function FreePlayAssetPreloader.StartEagerPreloadAtJoin()
	if flag2 then
		return
	end

	flag2 = true

	task.spawn(function()
		task.wait(8)
		local total = 0

		while not v and total < 5 do
			task.wait(0.2)
			total += 0.2
		end

		for _, v9 in ipairs(v8) do
			FreePlayAssetPreloader.PreloadInBackground(v9.InstrumentType, v9.ToneName)

			task.wait(0.5)
		end
	end)
end

FreePlayAssetPreloader.StartEagerPreloadAtJoin()

return FreePlayAssetPreloader