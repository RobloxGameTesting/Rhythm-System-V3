local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local MicrophoneConfig = require(ReplicatedStorage.Modules.MicrophoneConfig)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MicStateUpdate = RemoteEvents:WaitForChild("MicStateUpdate")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")

local LocalPlayer = Players.LocalPlayer

local function isMuteVolume(volume): boolean -- 4 equivalent calls inferred from this helper
	return math.abs(volume - 0.001) < 0.0001
end

local function isStemSound(sound) -- 3 equivalent calls inferred from this helper
	return sound:IsA("Sound") and sound:GetAttribute("CanonicalElapsed") ~= nil
end

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

local function computeExpectedNow(instance) -- 4 equivalent calls inferred from this helper
	local canonicalElapsed = instance:GetAttribute("CanonicalElapsed")
	local canonicalElapsedAt = instance:GetAttribute("CanonicalElapsedAt")

	if canonicalElapsed and canonicalElapsedAt then
		return canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
	end

	return nil
end

local v = nil
local v2 = nil
local v3 = false
local v4 = nil

local v5 = nil
local v6 = false
local v7 = {}
local count = 0
local v8 = nil
local v9 = 0

local v10 = MicrophoneConfig.VOCALIST_SYNC_OVERHEAD_SECONDS

local function measurePingSeconds()
	local success, result = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)

	if success and typeof(result) == "number" and result >= 0 then
		return result
	end

	return nil
end

local function refreshOffset()
	local success, result = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)

	if not success or typeof(result) ~= "number" or not (result >= 0) then
		result = nil
	end

	local v11

	if v == nil then
		v11 = false
	else
		v11 = v == v5
	end

	local v12

	if v2 == nil then
		v12 = false
	else
		v12 = v2 == v5
	end

	local maxValue = 0
	local v13 = nil

	if v11 then
		local VOCALIST_SYNC_OVERHEAD_SECONDS = MicrophoneConfig.VOCALIST_SYNC_OVERHEAD_SECONDS

		if result then
			VOCALIST_SYNC_OVERHEAD_SECONDS += result / 2
		end

		maxValue = math.max(
			maxValue,
			(math.clamp(
				VOCALIST_SYNC_OVERHEAD_SECONDS,
				MicrophoneConfig.VOCALIST_SYNC_MIN_OFFSET_SECONDS,
				MicrophoneConfig.VOCALIST_SYNC_MAX_OFFSET_SECONDS
			))
		)
	end

	if v12 then
		v13 = math.clamp(0.04 + (result or 0), 0.05, 0.5)

		maxValue = math.max(maxValue, v13)
	end

	if v11 or v12 then
		v10 = maxValue
	end

	LocalPlayer:SetAttribute("VocalistSyncPingMs", result and math.floor(result * 1000 + 0.5) or nil)
	LocalPlayer:SetAttribute("VocalistSyncOffsetMs", (math.floor(v10 * 1000 + 0.5)))
	LocalPlayer:SetAttribute("FreePlaySyncOffsetMs", v13 and math.floor(v13 * 1000 + 0.5) or nil)
end

local function isRelevantStem(instance)
	local v11 = isStemSound(instance) -- inferred equivalent call

	if not v11 then
		return v11
	end

	local studioId

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

	return studioId == v5
end

local function mirrorTargetVolume(p) -- 4 equivalent calls inferred from this helper
	return if p.SavedVolume < 0.03 then 0 else p.SavedVolume
end

local function applyMirrorVolume(state) -- 1 equivalent call inferred from this helper
	local mirror = state.Mirror

	if not (mirror and mirror.Parent) then
		return
	end

	if state.FadeTween then
		state.FadeTween:Cancel()
		state.FadeTween = nil
	end

	mirror.Volume = mirrorTargetVolume(state) -- inferred equivalent call
end

local function connectVolumeHandler(instance, p)
	if p.Conn then
		p.Conn:Disconnect()
		p.Conn = nil
	end

	p.Conn = instance:GetPropertyChangedSignal("Volume"):Connect(function()
		local volume = instance.Volume

		if isMuteVolume(volume) then -- inferred equivalent call
			return
		end

		p.SavedVolume = volume
		instance.Volume = 0.001
		local v11 = p
		local mirror = v11.Mirror

		if mirror then
			if not mirror.Parent then
				return
			end

			if v11.FadeTween then
				v11.FadeTween:Cancel()
				v11.FadeTween = nil
			end

			mirror.Volume = mirrorTargetVolume(v11) -- inferred equivalent call
		end
	end)
end

local function createMirror(descendant)
	if v7[descendant] then
		return
	end

	local v11 = {
		SavedVolume = descendant.Volume,
		Mirror = nil,
		Conn = nil,
		FadeTween = nil,
		MeasuredOffset = nil,
		CreatedAt = os.clock(),
		UnhealthySince = nil,
		FailOpen = false,
		Rebuilds = 0,
		NextRebuildAt = 0
	}

	v7[descendant] = v11

	local sound = Instance.new("Sound")
	sound.Name = descendant.Name .. "_VocalistMirror"
	sound.SoundId = descendant.SoundId
	sound.Looped = false
	sound.Volume = 0
	sound.Parent = descendant.Parent
	local expectedNow = computeExpectedNow(descendant) -- inferred equivalent call

	if expectedNow then
		sound.TimePosition = math.max(0, expectedNow + v10)
	end

	sound:Play()
	v11.Mirror = sound
	Debris:AddItem(sound, 3600)
	local volume = mirrorTargetVolume(v11) -- inferred equivalent call

	if volume > 0 then
		v11.FadeTween = TweenService:Create(sound, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
			Volume = volume
		})
		v11.FadeTween:Play()
	end

	descendant.Volume = 0.001

	connectVolumeHandler(descendant, v11)
end

local function destroyMirror(p, state)
	if state.Conn then
		state.Conn:Disconnect()
		state.Conn = nil
	end

	if p and p.Parent then
		p.Volume = state.SavedVolume
	end

	local mirror = state.Mirror
	state.Mirror = nil

	if mirror then
		if state.FadeTween then
			state.FadeTween:Cancel()
			state.FadeTween = nil
		end

		if mirror.Parent then
			local tween = TweenService:Create(mirror, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
				Volume = 0
			})
			tween.Completed:Connect(function()
				pcall(function()
					mirror:Stop()
				end)
				mirror:Destroy()
			end)
			tween:Play()
			Debris:AddItem(mirror, 1)
		else
			mirror:Destroy()
		end
	end
end

local function mirrorShouldBeAudible(p, state) -- 1 equivalent call inferred from this helper
	return p.IsPlaying and state.SavedVolume >= 0.03
end

local function mirrorIsHealthy(instance, state): boolean -- 1 equivalent call inferred from this helper
	local mirror = state.Mirror

	if not (mirror and mirror.Parent) then
		return false
	end

	if mirror.IsPlaying then
		return mirror.TimeLength > 0
	end

	local expectedNow = computeExpectedNow(instance) -- inferred equivalent call

	if expectedNow and mirror.TimeLength > 0 and expectedNow + v10 >= mirror.TimeLength - 0.5 then
		return true
	end

	return false
end

local function rebuildMirror(instance, state, createdAt)
	local mirror = state.Mirror
	state.Mirror = nil

	if state.FadeTween then
		state.FadeTween:Cancel()
		state.FadeTween = nil
	end

	if mirror then
		pcall(function()
			mirror:Stop()
		end)
		mirror:Destroy()
	end

	local sound = Instance.new("Sound")
	sound.Name = instance.Name .. "_VocalistMirror"
	sound.SoundId = instance.SoundId
	sound.Looped = false
	sound.Volume = 0
	sound.Parent = instance.Parent
	local expectedNow = computeExpectedNow(instance) -- inferred equivalent call

	if expectedNow then
		sound.TimePosition = math.max(0, expectedNow + v10)
	end

	sound:Play()
	state.Mirror = sound
	state.CreatedAt = createdAt
	state.MeasuredOffset = nil
	Debris:AddItem(sound, 3600)
end

local function enterFailOpen(p, state)
	state.FailOpen = true

	if state.Conn then
		state.Conn:Disconnect()
		state.Conn = nil
	end

	if state.FadeTween then
		state.FadeTween:Cancel()
		state.FadeTween = nil
	end

	local mirror = state.Mirror

	if mirror and mirror.Parent then
		mirror.Volume = 0
	end

	p.Volume = state.SavedVolume

	local name = p.Name
	local v11

	if mirror == nil then
		v11 = false
	else
		v11 = mirror.Parent ~= nil
	end

	local v12 = tostring(v11)
	local v13 = not (mirror == nil) and mirror.IsPlaying
	local v14 = tostring(v13)
	local v15 = not (mirror == nil) and mirror.TimeLength
	warn(("[VocalistSyncClient] salinan '%s' tidak sehat (ada=%s memutar=%s panjang=%s) -> fail-open: stem asli dibunyikan, salinan dibangun ulang"):format(
		name,
		v12,
		v14,
		(tostring(v15))
	))
end

local function resumeNormal(state, state2)
	state2.FailOpen = false
	state2.Rebuilds = 0
	state2.NextRebuildAt = 0
	state2.UnhealthySince = nil

	if not isMuteVolume(state.Volume) then -- inferred equivalent call
		state2.SavedVolume = state.Volume
	end

	local mirror = state2.Mirror

	if mirror and mirror.Parent then
		mirror.Volume = mirrorTargetVolume(state2) -- inferred equivalent call
	end

	state.Volume = 0.001
	connectVolumeHandler(state, state2)
	print(("[VocalistSyncClient] salinan '%s' pulih, kembali ke mode normal"):format(state.Name))
end

local function checkMirrorHealth(k, state, now)
	if now - (state.CreatedAt or now) < 2.5 then
		return
	end

	if not (state.FailOpen or mirrorShouldBeAudible(k, state)) then -- inferred equivalent call
		state.UnhealthySince = nil
	elseif mirrorIsHealthy(k, state) then -- inferred equivalent call
		state.UnhealthySince = nil

		if state.FailOpen then
			resumeNormal(k, state)
		end
	else
		state.UnhealthySince = state.UnhealthySince or now

		if now - state.UnhealthySince < 0.75 then
			return
		end

		if not state.FailOpen then
			enterFailOpen(k, state)
		end

		if state.NextRebuildAt <= now then
			state.Rebuilds += 1
			state.NextRebuildAt = now + (state.Rebuilds > 3 and 5 or 2)
			rebuildMirror(k, state, now)
		end
	end
end

local function publishVisualOffset(mirror, p, measuredOffset, p2) -- 1 equivalent call inferred from this helper
	if not p2 and p.MeasuredOffset ~= nil then
		measuredOffset = p.MeasuredOffset + (measuredOffset - p.MeasuredOffset) * 0.4
	end

	p.MeasuredOffset = measuredOffset
	mirror:SetAttribute("VocalistVisualOffset", measuredOffset)
end

local function resolveScanRoots(p)
	local scanRoots = {}
	local map = Workspace:FindFirstChild("Map")

	if map then
		for _, child in ipairs(map:GetChildren()) do
			if child:GetAttribute("StudioId") == p then
				scanRoots[#scanRoots + 1] = child
			end
		end
	end

	if #scanRoots == 0 then
		scanRoots[1] = Workspace
	end

	return scanRoots
end

local function scanAndSync()
	local now = os.clock()

	if not v8 or now - v9 >= 5 then
		v8 = resolveScanRoots(v5)
		v9 = now
	end

	local v11 = v2 == v5 and v ~= v5 and 0.01 or 0.05

	for _, folder in ipairs(v8) do
		if not folder.Parent then
			continue
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			local v12 = isStemSound(descendant) -- inferred equivalent call

			if v12 then
				local v13 = descendant
				local studioId

				while true do
					if not v13 then
						studioId = nil
						break
					end

					studioId = v13:GetAttribute("StudioId")

					if studioId then
						break
					end

					v13 = v13.Parent
				end

				v12 = studioId == v5
			end

			if not v12 or v7[descendant] then
				continue
			end

			createMirror(descendant)
		end
	end

	for k, v12 in pairs(v7) do
		if k.Parent then
			local v13 = isStemSound(k) -- inferred equivalent call

			if v13 then
				local v14 = k
				local studioId

				while true do
					if not v14 then
						studioId = nil
						break
					end

					studioId = v14:GetAttribute("StudioId")

					if studioId then
						break
					end

					v14 = v14.Parent
				end

				v13 = studioId == v5
			end

			if v13 then
				local mirror = v12.Mirror
				local expectedNow = computeExpectedNow(k) -- inferred equivalent call

				if not (mirror and mirror.Parent) then
					expectedNow = nil
				end

				if expectedNow and mirror.IsPlaying and mirror.TimeLength > 0 then
					local v14 = math.max(0, expectedNow + v10) - mirror.TimePosition

					if math.abs(v14) < v11 then
						if mirror.PlaybackSpeed ~= 1 then
							mirror.PlaybackSpeed = 1
						end
					else
						mirror.PlaybackSpeed = math.clamp(v14 / 2, -0.08, 0.08) + 1
					end

					publishVisualOffset(mirror, v12, mirror.TimePosition - expectedNow, false) -- inferred equivalent call
				end

				if v12.FailOpen then
					if not isMuteVolume(k.Volume) then -- inferred equivalent call
						v12.SavedVolume = k.Volume
					end
				elseif not isMuteVolume(k.Volume) then -- inferred equivalent call
					v12.SavedVolume = k.Volume
					k.Volume = 0.001
					applyMirrorVolume(v12) -- inferred equivalent call
				end

				checkMirrorHealth(k, v12, now)
				continue
			end
		end

		destroyMirror(k.Parent and k or nil, v12)
		v7[k] = nil
	end
end

local function stopAll()
	for k, v11 in pairs(v7) do
		destroyMirror(k.Parent and k or nil, v11)
	end

	v7 = {}
end

local function startFor(p) -- 1 equivalent call inferred from this helper
	if v6 and v5 == p then
		return
	end

	stopAll()
	v5 = p
	v6 = true
	v8 = nil
	count += 1
	local v11 = count

	task.spawn(function()
		local success, result = pcall(refreshOffset)

		if not success then
			warn("[VocalistSyncClient] refreshOffset gagal:", result)
		end

		local lastTime = os.clock()

		while v6 and count == v11 do
			if os.clock() - lastTime >= MicrophoneConfig.VOCALIST_SYNC_PING_POLL_INTERVAL_SECONDS then
				lastTime = os.clock()
				local success2, result2 = pcall(refreshOffset)

				if not success2 then
					warn("[VocalistSyncClient] refreshOffset gagal:", result2)
				end
			end

			local success2, result2 = pcall(scanAndSync)

			if not success2 then
				warn("[VocalistSyncClient] scanAndSync gagal:", result2)
			end

			task.wait(0.25)
		end
	end)
end

local function stop() -- 2 equivalent calls inferred from this helper
	if not v6 then
		return
	end

	v6 = false
	v5 = nil
	v8 = nil
	count += 1
	stopAll()

	LocalPlayer:SetAttribute("VocalistSyncPingMs", nil)
	LocalPlayer:SetAttribute("VocalistSyncOffsetMs", nil)
	LocalPlayer:SetAttribute("FreePlaySyncOffsetMs", nil)
end

local function applyDesired() -- 3 equivalent calls inferred from this helper
	local v11 = v or v2

	if v11 == nil then
		stop() -- inferred equivalent call
	else
		if v6 and v5 == v11 then
			pcall(refreshOffset)
			return
		end

		startFor(v11) -- inferred equivalent call
	end
end

local function recomputeFreeplay() -- 1 equivalent call inferred from this helper
	local v11

	if v3 and v4 and ModeManager.IsFreePlay() then
		v11 = v4
	end

	if v11 ~= v2 then
		v2 = v11
		applyDesired() -- inferred equivalent call
	end
end

MicStateUpdate.OnClientEvent:Connect(function(p, p2)
	if p2.VocalistUserId == LocalPlayer.UserId then
		if v ~= p then
			v = p
			applyDesired() -- inferred equivalent call
		end
	elseif v == p then
		v = nil
		applyDesired() -- inferred equivalent call
	end
end)

InstrumentHUDUpdate.OnClientEvent:Connect(function(p, _, instance)
	v3 = p == true
	v4 = nil

	if v3 and typeof(instance) == "Instance" then
		local studioId

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

		v4 = studioId
	end

	task.defer(recomputeFreeplay)
end)

ModeManager.OnChanged(function()
	recomputeFreeplay() -- inferred equivalent call
end)

Players.PlayerRemoving:Connect(function(player)
	if player == LocalPlayer then
		v = nil
		v2 = nil
		stop() -- inferred equivalent call
	end
end)