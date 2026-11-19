local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
local PlayerLoadingState = require(ReplicatedStorage.Modules.PlayerLoadingState)

local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local v = mobile and { high = 3, low = 1 } or { high = 6, low = 2 }
local v2 = { 1, 2, 4, 8, 10 }
local maxPinnedSongs = mobile and 6 or 14
local v3 = 20

local StemCache = {}

local v4 = {}
local v5 = {}
local v6 = { high = {}, low = {} }
local v7 = { high = 0, low = 0 }
local v8 = nil

local fn

local function getPoolFolder()
	if v8 and v8.Parent then
		return v8
	end

	local stemWarmPool = ReplicatedStorage:FindFirstChild("StemWarmPool")

	if not stemWarmPool then
		stemWarmPool = Instance.new("Folder")
		stemWarmPool.Name = "StemWarmPool"
		stemWarmPool.Parent = ReplicatedStorage
	end

	v8 = stemWarmPool
	return stemWarmPool
end

local function newWarmSound(soundId)
	local sound = Instance.new("Sound")
	sound.Name = "Warm_" .. (string.match(soundId, "%d+") or "x")
	sound.SoundId = soundId
	sound.Volume = 0
	sound.Looped = false
	local stemWarmPool

	if v8 and v8.Parent then
		stemWarmPool = v8
	else
		stemWarmPool = ReplicatedStorage:FindFirstChild("StemWarmPool")

		if not stemWarmPool then
			stemWarmPool = Instance.new("Folder")
			stemWarmPool.Name = "StemWarmPool"
			stemWarmPool.Parent = ReplicatedStorage
		end

		v8 = stemWarmPool
	end

	sound.Parent = stemWarmPool
	return sound
end

local function getEntry(item) -- 1 equivalent call inferred from this helper
	local entry = v4[item]

	if not entry then
		entry = {
			id = item,
			state = "idle",
			priority = "low",
			attempts = 0,
			failStreak = 0,
			refs = 0,
			notBefore = 0,
			lastStatus = nil,
			sound = nil,
			dead = false
		}

		v4[item] = entry
	end

	return entry
end

local function removeFromQueue(list, p)
	for i = #list, 1, -1 do
		if list[i] == p then
			table.remove(list, i)
			break
		end
	end
end

local function warnFailure(data) -- 1 equivalent call inferred from this helper
	local failStreak = data.failStreak

	if failStreak == 1 or failStreak == 3 or failStreak == 6 or failStreak % 10 == 0 then
		warn(("[StemCache] gagal memuat %s (percobaan ke-%d, status: %s) -- retry otomatis sampai berhasil"):format(
			data.id,
			data.attempts,
			(tostring(data.lastStatus))
		))
	end
end

local function onEntryReady(state)
	state.readyAt = os.clock()

	for _, v9 in pairs(v5) do
		if not v9.set[state.id] or v9.announced then
			continue
		end

		local flag = true

		for _, assetId in ipairs(v9.assetIds) do
			local v10 = v4[assetId]

			if not v10 or v10.state ~= "ready" then
				flag = false
				break
			end
		end

		if not flag then
			continue
		end

		v9.announced = true
		print(("[StemCache] '%s' siap (%d aset, %.1f dtk sejak diminta)"):format(
			v9.key,
			#v9.assetIds,
			os.clock() - v9.createdAt
		))
	end
end

local function attemptLoad(state): string
	state.attempts += 1

	local sound = state.sound

	if not (sound and sound.Parent) then
		local id = state.id
		sound = Instance.new("Sound")
		sound.Name = "Warm_" .. (string.match(id, "%d+") or "x")
		sound.SoundId = id
		sound.Volume = 0
		sound.Looped = false
		local stemWarmPool

		if v8 and v8.Parent then
			stemWarmPool = v8
		else
			stemWarmPool = ReplicatedStorage:FindFirstChild("StemWarmPool")

			if not stemWarmPool then
				stemWarmPool = Instance.new("Folder")
				stemWarmPool.Name = "StemWarmPool"
				stemWarmPool.Parent = ReplicatedStorage
			end

			v8 = stemWarmPool
		end

		sound.Parent = stemWarmPool

		state.sound = sound
	end

	local v9 = nil
	local success, result = pcall(function()
		ContentProvider:PreloadAsync({ sound }, function(_, p)
			v9 = p
		end)
	end)

	if state.dead then
		return "released"
	end

	local v10

	if success then
		if v9 == Enum.AssetFetchStatus.Success then
			v10 = true
		else
			v10 = v9 == nil and sound.IsLoaded
		end
	else
		v10 = success
	end

	if v10 then
		local lastTime = os.clock()

		while not sound.IsLoaded and os.clock() - lastTime < 1 and not state.dead do
			task.wait(0.05)
		end

		return if state.dead then "released" else "ready"
	end

	state.failStreak += 1
	state.lastStatus = success and tostring(v9) or "error: " .. tostring(result)
	warnFailure(state) -- inferred equivalent call

	if state.failStreak % 3 == 0 and state.sound then
		state.sound:Destroy()
		state.sound = nil
	end

	return "retry"
end

local function startAttempt(state, p) -- 1 equivalent call inferred from this helper
	state.state = "loading"
	v7[p] += 1

	task.defer(function()
		local success, result = pcall(attemptLoad, state)

		if not success then
			warn("[StemCache] error internal: " .. tostring(result))
			result = "retry"
		end

		v7[p] -= 1

		if result == "ready" then
			state.state = "ready"
			state.failStreak = 0
			onEntryReady(state)
		elseif result == "retry" and not state.dead then
			local v9 = v2[math.min(math.max(state.failStreak, 1), #v2)]
			state.state = "queued"
			state.notBefore = os.clock() + v9
			table.insert(v6[state.priority], state)
			task.delay(v9 + 0.05, fn)
		end

		fn()
	end)
end

fn = function()
	for _, v9 in ipairs({ "high", "low" }) do
		local v10 = v6[v9]
		local now = os.clock()
		local v11 = 1

		while v7[v9] < v[v9] and v11 <= #v10 do
			local v12 = v10[v11]

			if v12.dead then
				table.remove(v10, v11)
			elseif v12.notBefore <= now then
				table.remove(v10, v11)
				startAttempt(v12, v9) -- inferred equivalent call
			else
				v11 += 1
			end
		end
	end
end

local function ensureAsset(state, priority)
	if state.state == "ready" then
		return
	end

	if state.state == "idle" then
		state.state = "queued"
		state.priority = priority
		state.notBefore = 0
		table.insert(v6[priority], state)
	elseif state.state == "queued" then
		if priority == "high" and state.priority == "low" then
			removeFromQueue(v6.low, state)
			state.priority = "high"
			state.notBefore = math.min(state.notBefore, os.clock() + 1)
			table.insert(v6.high, state)
		end
	elseif state.state == "loading" and priority == "high" then
		state.priority = "high"
	end
end

local function retainGroup(p, list, p2)
	local v9 = v5[p]

	if v9 then
		return v9
	end

	local v10 = {
		key = p,
		assetIds = {},
		set = {},
		lastUsed = os.clock(),
		createdAt = os.clock(),
		permanent = p2 == true,
		waiters = 0,
		announced = false
	}

	for _, item in ipairs(list) do
		if type(item) ~= "string" or item == "" or v10.set[item] then
			continue
		end

		v10.set[item] = true
		table.insert(v10.assetIds, item)
		local entry = getEntry(item) -- inferred equivalent call
		entry.refs += 1
	end

	v5[p] = v10
	return v10
end

local function releaseGroup(p)
	v5[p.key] = nil

	for _, assetId in ipairs(p.assetIds) do
		local v9 = v4[assetId]

		if not v9 then
			continue
		end

		v9.refs -= 1

		if not (v9.refs <= 0) then
			continue
		end

		v9.dead = true
		removeFromQueue(v6.high, v9)
		removeFromQueue(v6.low, v9)

		if v9.sound then
			v9.sound:Destroy()
			v9.sound = nil
		end

		v4[assetId] = nil
	end
end

local function evictIfNeeded()
	local v9 = {}

	for _, v10 in pairs(v5) do
		if not v10.permanent then
			table.insert(v9, v10)
		end
	end

	local count = #v9

	if count <= maxPinnedSongs then
		return
	end

	table.sort(v9, function(a, b): boolean
		return a.lastUsed < b.lastUsed
	end)

	local now = os.clock()

	for _, v10 in ipairs(v9) do
		if count <= maxPinnedSongs then
			break
		end

		if v10.waiters ~= 0 then
			continue
		end

		local v11 = now - v10.lastUsed

		if not (v3 < v11) then
			continue
		end

		releaseGroup(v10)
		count -= 1
	end
end

local function groupReadyCount(p) -- 1 equivalent call inferred from this helper
	local count = 0

	for _, assetId in ipairs(p.assetIds) do
		local v9 = v4[assetId]

		if v9 and v9.state == "ready" then
			count += 1
		end
	end

	return count
end

local function waitForGroup(state, options)
	local v9 = options or {}
	state.waiters += 1

	local v10 = PlayerLoadingState.Begin("stem")

	local count = #state.assetIds
	local maxWaitSeconds = v9.MaxWaitSeconds
	local v11

	if maxWaitSeconds and maxWaitSeconds < 1e999 then
		v11 = os.clock() + maxWaitSeconds
	end

	local v12 = -1
	local v13 = false
	local count2

	while true do
		count2 = 0

		for _, assetId in ipairs(state.assetIds) do
			local v14 = v4[assetId]

			if v14 and v14.state == "ready" then
				count2 += 1
			end
		end

		local v14 = count == 0 and 100 or math.floor(count2 / count * 100)

		if v9.OnProgress and v14 ~= v12 then
			local success, result = pcall(v9.OnProgress, v14)

			if not success then
				warn("[StemCache] OnProgress error: " .. tostring(result))
			end

			v12 = v14
		end

		if count <= count2 then
			v13 = true
			break
		end

		if v11 and v11 <= os.clock() or v5[state.key] ~= state then
			break
		end

		task.wait(0.1)
	end

	state.waiters -= 1
	PlayerLoadingState.End(v10)
	return v13, count2, count
end

function StemCache.Configure(p)
	if type(p) ~= "table" then
		return
	end

	if type(p.MaxPinnedSongs) == "number" then
		maxPinnedSongs = math.max(1, (math.floor(p.MaxPinnedSongs)))
	end

	if type(p.MinAgeBeforeEvictSeconds) == "number" then
		v3 = math.max(0, p.MinAgeBeforeEvictSeconds)
	end
end

function StemCache.GetSongAssets(p)
	local song = SongConfig.Songs[p]

	if not song then
		return nil
	end

	local v9 = {}
	local set = {}
	local function add(value) -- 3 equivalent calls inferred from this helper
		if type(value) == "string" and value ~= "" and not set[value] then
			set[value] = true
			table.insert(v9, value)
		end
	end

	if type(song.Stems) == "table" then
		for _, stem in pairs(song.Stems) do
			add(stem) -- inferred equivalent call
		end
	end

	if type(song.Segments) == "table" then
		for _, segment in pairs(song.Segments) do
			if type(segment) ~= "table" then
				continue
			end

			add(segment.PartA) -- inferred equivalent call
			add(segment.PartB) -- inferred equivalent call
		end
	end

	table.sort(v9)
	return v9
end

function StemCache.RequestAssets(p, p2, p3, p4)
	local priority = p3 == "low" and "low" or "high"
	local assets = retainGroup(p, p2, p4)
	assets.lastUsed = os.clock()

	for _, assetId in ipairs(assets.assetIds) do
		local v9 = v4[assetId]

		if v9 then
			ensureAsset(v9, priority)
		end
	end

	evictIfNeeded()
	fn()
	return assets
end

function StemCache.RequestSong(p, p2)
	local songAssets = StemCache.GetSongAssets(p)

	if songAssets and #songAssets ~= 0 then
		return StemCache.RequestAssets(p, songAssets, p2, false)
	end

	return nil
end

function StemCache.WaitForAssets(p, p2, options)
	local v9 = options or {}
	return waitForGroup(StemCache.RequestAssets(p, p2, v9.Priority, v9.Permanent), v9)
end

function StemCache.WaitForSong(p, options)
	local v9 = options or {}
	local song = StemCache.RequestSong(p, v9.Priority)

	if song then
		return waitForGroup(song, v9)
	end

	if v9.OnProgress then
		pcall(v9.OnProgress, 100)
	end

	return true, 0, 0
end

function StemCache.IsSongReady(p): boolean
	local v9 = v5[p]

	if not v9 then
		return false
	end

	local count = groupReadyCount(v9) -- inferred equivalent call
	return #v9.assetIds <= count
end

function StemCache.Release(p)
	local v9 = v5[p]

	if v9 then
		releaseGroup(v9)
	end
end

function StemCache.Stats()
	local result = {
		assets = 0,
		ready = 0,
		loading = 0,
		queued = 0,
		groups = 0
	}

	for _, v9 in pairs(v4) do
		result.assets += 1

		if v9.state == "ready" then
			result.ready += 1
		elseif v9.state == "loading" then
			result.loading += 1
		elseif v9.state == "queued" then
			result.queued += 1
		end
	end

	for _ in pairs(v5) do
		result.groups += 1
	end

	result.maxPinnedSongs = maxPinnedSongs
	result.mobile = mobile
	return result
end

return StemCache