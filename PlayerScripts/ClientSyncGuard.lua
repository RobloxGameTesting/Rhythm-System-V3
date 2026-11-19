local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadingIndicatorClient = require(ReplicatedStorage.Modules.LoadingIndicatorClient)
local ClientSongPreloader = require(ReplicatedStorage.Modules.ClientSongPreloader)
local StemCache = require(ReplicatedStorage.Modules.StemCache)

local v = { 2, 5, 10 }

local v2 = {}
local v3 = {}
local queueForBatch
local count = 0

local function isStemSound(sound) -- 2 equivalent calls inferred from this helper
	return sound:IsA("Sound") and sound:GetAttribute("CanonicalElapsed") ~= nil
end

local function nextRetryTime(p)
	return v[p] or v[#v] + (p - #v) * 10
end

local function requestStemCacheFetch(p) -- 2 equivalent calls inferred from this helper
	local soundId = p.SoundId

	if soundId == "" then
		return
	end

	local success, result = pcall(function()
		StemCache.RequestAssets("live:" .. soundId, { soundId }, "high", false)
	end)

	if not success then
		warn("[ClientSyncGuard] StemCache.RequestAssets gagal: " .. tostring(result))
	end
end

local function retryUntilLoaded(instance) -- 1 equivalent call inferred from this helper
	task.spawn(function()
		local soundId = instance.SoundId

		while instance.Parent and not instance.IsLoaded do
			task.wait(10)

			if not instance.Parent or instance.IsLoaded then
				break
			end

			requestStemCacheFetch(instance) -- inferred equivalent call
			local soundId2 = instance.SoundId
			instance.SoundId = ""
			instance.SoundId = soundId2
		end

		if instance.Parent and instance.IsLoaded then
			pcall(StemCache.Release, "live:" .. soundId)
			print(("[ClientSyncGuard] %s akhirnya ter-load -- dijaga ulang (sinkron ke posisi kanonik)."):format(instance.Name))
			ClientSongPreloader.ShowInfoToast("Audio finished loading", 3)
			queueForBatch(instance)
		end
	end)
end

local function startOngoingDriftWatch(instance) -- 1 equivalent call inferred from this helper
	task.spawn(function()
		while instance.Parent do
			task.wait(1)

			if not (instance.Parent and instance.IsPlaying) then
				continue
			end

			local canonicalElapsed = instance:GetAttribute("CanonicalElapsed")
			local canonicalElapsedAt = instance:GetAttribute("CanonicalElapsedAt")

			if not (canonicalElapsed and canonicalElapsedAt) then
				continue
			end

			local v4 = canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt) - instance.TimePosition

			if math.abs(v4) < 0.05 then
				continue
			end

			instance.PlaybackSpeed = math.clamp(v4 / 2, -0.08, 0.08) + 1

			task.delay(2, function()
				if instance.Parent then
					instance.PlaybackSpeed = 1
				end
			end)
		end
	end)
end

local function guardBatch(list)
	if #list == 0 then
		return
	end

	local set = {}

	for _, item in ipairs(list) do
		if item.Parent then
			set[item] = true
		end
	end

	local count2 = 0

	for _ in pairs(set) do
		count2 += 1
	end

	print(("[ClientSyncGuard] Batch dimulai -- %d Sound (tidak dibisukan, terdengar apa adanya)."):format(count2))
	LoadingIndicatorClient.Show(("Preparing audio... 0/%d"):format(count2))

	task.spawn(function()
		local lastTime = os.clock()

		local nows = {}
		local v4 = {}

		while true do
			local count3 = 0
			local flag = false
			local flag2 = true

			for k in pairs(set) do
				if not k.Parent then
					continue
				end

				flag = true
				local v5 = os.clock() - lastTime

				if k.IsLoaded then
					local canonicalElapsed = k:GetAttribute("CanonicalElapsed")
					local canonicalElapsedAt = k:GetAttribute("CanonicalElapsedAt")

					if canonicalElapsed and canonicalElapsedAt then
						local timePosition = canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
						local v6 = math.abs(k.TimePosition - timePosition)

						if v6 >= 0.15 then
							k.TimePosition = timePosition
							nows[k] = os.clock()
						end

						local v7 = os.clock() - (nows[k] or -1e999) >= 0.25
						local v8 = k.IsPlaying

						if v8 then
							v8 = v6 < 0.15 and v7
						end

						if v8 then
							count3 += 1
						else
							flag2 = false
						end
					else
						flag2 = false
					end
				else
					v4[k] = v4[k] or 1
					local v6 = v4[k]
					local v7 = v[v6] or v[#v] + (v6 - #v) * 10

					if v7 and v7 <= v5 then
						requestStemCacheFetch(k) -- inferred equivalent call
						local soundId = k.SoundId
						k.SoundId = ""
						k.SoundId = soundId
						v4[k] += 1
					end

					flag2 = false
				end
			end

			if flag then
				if flag2 then
					break
				end

				LoadingIndicatorClient.Update(("Preparing audio... %d/%d"):format(count3, count2))

				if os.clock() - lastTime > 20 then
					break
				end

				task.wait(0.1)
			else
				for k in pairs(set) do
					v2[k] = nil
				end

				LoadingIndicatorClient.Hide()
				return
			end
		end

		local v5 = os.clock() - lastTime

		if v5 < 0.6 then
			task.wait(0.6 - v5)
		end

		local flag = false

		for k in pairs(set) do
			if k.Parent then
				if k.IsLoaded then
					startOngoingDriftWatch(k) -- inferred equivalent call
				else
					retryUntilLoaded(k) -- inferred equivalent call
					flag = true
				end
			end

			v2[k] = nil
		end

		if flag then
			ClientSongPreloader.ShowInfoToast("Some audio is still loading — retrying in the background", 6)
		end

		print("[ClientSyncGuard] Batch selesai -- semua Sound terkonfirmasi sinkron.")
		LoadingIndicatorClient.Hide()
	end)
end

queueForBatch = function(p)
	if v2[p] then
		return
	end

	v2[p] = true
	table.insert(v3, p)

	count += 1
	local v4 = count
	task.delay(0.5, function()
		if v4 ~= count then
			return
		end

		local v5 = v3
		v3 = {}
		guardBatch(v5)
	end)
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	if isStemSound(descendant) then -- inferred equivalent call
		queueForBatch(descendant)
	end
end

Workspace.DescendantAdded:Connect(function(sound)
	if not sound:IsA("Sound") or v2[sound] then
		return
	end

	task.spawn(function()
		local total = 0

		while total < 6 and sound.Parent and not v2[sound] do
			if isStemSound(sound) then -- inferred equivalent call
				queueForBatch(sound)
				break
			end

			task.wait(0.15)
			total += 0.15
		end
	end)
end)