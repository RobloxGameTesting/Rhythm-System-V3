local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function isEnabled(): boolean -- 1 equivalent call inferred from this helper
	return Workspace:GetAttribute("SongEndEchoDisabled") ~= true
end

local function dbg(...)
	if Workspace:GetAttribute("SongEndEchoDebug") == true then
		print("[SongEndEcho]", ...)
	end
end

local function stageIdOf(instance)
	local map = Workspace:FindFirstChild("Map")

	if instance then
		instance = instance.Parent
	end

	while instance and instance ~= Workspace do
		if map and instance.Parent == map then
			local studioId = instance:GetAttribute("StudioId")
			return typeof(studioId) == "string" and studioId or nil
		end

		instance = instance.Parent
	end

	return nil
end

local function parentGroupFor(value) -- 1 equivalent call inferred from this helper
	local monoBoundaryMix = SoundService:FindFirstChild("MonoBoundaryMix", true)

	if not monoBoundaryMix then
		return SoundService
	end

	return value and monoBoundaryMix:FindFirstChild("StageMix_" .. value) or monoBoundaryMix
end

local v = {}

local function acquireGroup(stageId, p)
	local v2 = stageId or "_"
	local now = os.clock()
	local v3 = v[v2]

	if v3 and v3.group.Parent then
		v3.expiresAt = math.max(v3.expiresAt, now + p)
		return v3.group
	end

	local songEndEchoMix = Instance.new("SoundGroup")
	songEndEchoMix.Name = "SongEndEchoMix"
	songEndEchoMix.Volume = 1

	local endReverb = Instance.new("ReverbSoundEffect")
	endReverb.Name = "EndReverb"
	endReverb.DecayTime = 7
	endReverb.Density = 1
	endReverb.Diffusion = 1
	endReverb.DryLevel = -80
	endReverb.WetLevel = -9
	endReverb.Parent = songEndEchoMix
	songEndEchoMix.Parent = parentGroupFor(stageId) -- inferred equivalent call
	local v4 = {
		group = songEndEchoMix,
		expiresAt = now + p
	}
	v[v2] = v4
	task.spawn(function()
		while v4.group.Parent and os.clock() < v4.expiresAt do
			task.wait(0.25)
		end

		if v[v2] == v4 then
			v[v2] = nil
		end

		v4.group:Destroy()
	end)
	return songEndEchoMix
end

local function worldPositionOf(parent) -- 2 equivalent calls inferred from this helper
	if parent and parent:IsA("BasePart") then
		return parent.Position
	end

	if parent and parent:IsA("Attachment") then
		return parent.WorldPosition
	end

	return nil
end

local function emitterFor(state)
	local anchor = state.anchor

	if anchor and anchor.Parent and anchor:IsDescendantOf(Workspace) then
		return anchor, nil
	end

	local songEndEchoEmitter = Instance.new("Part")
	songEndEchoEmitter.Name = "SongEndEchoEmitter"
	songEndEchoEmitter.Anchored = true
	songEndEchoEmitter.CanCollide = false
	songEndEchoEmitter.CanQuery = false
	songEndEchoEmitter.CanTouch = false
	songEndEchoEmitter.Transparency = 1
	songEndEchoEmitter.Size = Vector3.new(0.2, 0.2, 0.2)
	songEndEchoEmitter.CFrame = CFrame.new(state.position or Vector3.new(0, 0, 0))
	songEndEchoEmitter.Parent = Workspace
	return songEndEchoEmitter, songEndEchoEmitter
end

local function startTail(state, p, p2, p3)
	if state.tailed or not isEnabled() or (state.volume < 0.02 or state.soundId == "") then -- inferred equivalent call
		return
	end

	state.tailed = true

	local v2 = state.isDrum and 0.5 or 1
	local v3 = p3 + 7 + 1.5

	task.spawn(function()
		local v4 = nil
		local songEndEchoTail = nil
		local success, result = pcall(function()
			local soundGroup = acquireGroup(state.stageId, v3)

			local parent, v5 = emitterFor(state)
			v4 = v5

			songEndEchoTail = Instance.new("Sound")
			songEndEchoTail.Name = "SongEndEchoTail"
			songEndEchoTail.SoundId = state.soundId
			local volume = state.volume * v2 * 0.65
			songEndEchoTail.Volume = 0
			songEndEchoTail.Looped = false
			songEndEchoTail.SoundGroup = soundGroup
			songEndEchoTail.Parent = parent

			local lastTime = os.clock()

			while not songEndEchoTail.IsLoaded and songEndEchoTail.Parent and os.clock() - lastTime < 1.5 do
				task.wait()
			end

			if not songEndEchoTail.Parent then
				return
			end

			local v6 = p2

			if v6 == nil then
				local sound = state.sound

				if sound and sound.Parent and sound.IsPlaying then
					v6 = sound.TimePosition
				else
					v6 = state.lastPos + (os.clock() - state.lastAt) * state.speed
				end
			end

			local timePosition = math.clamp(v6, 0, (math.max(0, songEndEchoTail.TimeLength - 0.05)))
			songEndEchoTail.TimePosition = timePosition
			songEndEchoTail:Play()
			local v7 = p2 == nil
			TweenService:Create(
				songEndEchoTail,
				TweenInfo.new(
					v7 and 1.6 or 0.12,
					v7 and Enum.EasingStyle.Sine or Enum.EasingStyle.Linear,
					Enum.EasingDirection.In
				),
				{ Volume = volume }
			):Play()

			if not v7 then
				task.delay(math.max(0, p3 - 0.35), function()
					if songEndEchoTail and songEndEchoTail.Parent then
						TweenService:Create(songEndEchoTail, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
							Volume = 0
						}):Play()
					end
				end)
			end

			dbg(("gema %s [%s] volume=%.2f mulai @%.2f feed=%.1fs"):format(state.name, p, volume, timePosition, p3))

			task.delay(p3 + 0.3, function()
				if songEndEchoTail and songEndEchoTail.Parent then
					songEndEchoTail:Stop()
				end
			end)
		end)

		if not success then
			warn("[SongEndEchoClient] gagal memulai gema:", result)
		end

		task.delay(v3, function()
			if songEndEchoTail then
				songEndEchoTail:Destroy()
			end

			if v4 then
				v4:Destroy()
			end
		end)
	end)
end

local v2 = {}

local function isStem(sound) -- 3 equivalent calls inferred from this helper
	local v3 = sound:IsA("Sound")

	if v3 then
		if sound.Name == "SongEndEchoTail" then
			return false
		end

		return sound:GetAttribute("CanonicalElapsed") ~= nil
	end

	return v3
end

local function hasReplacement(data): boolean
	local anchor = data.anchor

	if not (anchor and anchor.Parent) then
		return false
	end

	for _, sound in ipairs(anchor:GetChildren()) do
		if sound ~= data.sound and sound:IsA("Sound") and sound.Name == data.name then
			return true
		end
	end

	return false
end

local function isSegmentPartA(p): boolean -- 1 equivalent call inferred from this helper
	local anchor = p.anchor

	if anchor and anchor.Parent then
		return anchor:FindFirstChild(p.name .. "_Pending") ~= nil
	end

	return false
end

local function onRemoved(state)
	v2[state.sound] = nil

	if state.tailed or state.removedHandled then
		return
	end

	state.removedHandled = true

	local now = os.clock()

	if now - state.lastPlayingAt > 0.45 or state.volume < 0.02 or state.length <= 0 then
		return
	end

	local v3 = state.lastPos + (now - state.lastAt) * state.speed
	task.delay(0.15, function()
		if hasReplacement(state) then
			dbg(("lewati %s: diganti Sound baru bernama sama"):format(state.name))
		else
			startTail(state, "dihentikan", math.max(0, v3 - 0.6), 0.6)
		end
	end)
end

local function track(sound)
	if not v2[sound] and isStem(sound) then -- inferred equivalent call
		local now = os.clock()
		local v3 = {
			sound = sound,
			name = sound.Name,
			isDrum = sound.Name:find("_Drum", 1, true) ~= nil,
			soundId = sound.SoundId,
			anchor = sound.Parent,
			position = worldPositionOf(sound.Parent), -- inferred equivalent call
			stageId = stageIdOf(sound),
			volume = sound.Volume,
			speed = math.max(sound.PlaybackSpeed, 0.25),
			length = sound.TimeLength,
			lastPos = sound.TimePosition,
			lastAt = now,
			lastPlayingAt = sound.IsPlaying and now or -1e999,
			tailed = false,
			removedHandled = false
		}

		v2[sound] = v3
		sound.AncestryChanged:Connect(function()
			if sound.Parent == nil then
				onRemoved(v3)
			end
		end)
	end
end

local function watch(sound)
	if not sound:IsA("Sound") or sound.Name == "SongEndEchoTail" then
		return
	end

	if isStem(sound) then -- inferred equivalent call
		track(sound)
		return
	end

	local canonicalElapsedChangedConnection = nil
	canonicalElapsedChangedConnection = sound:GetAttributeChangedSignal("CanonicalElapsed"):Connect(function()
		if isStem(sound) then -- inferred equivalent call
			canonicalElapsedChangedConnection:Disconnect()
			track(sound)
		end
	end)
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	watch(descendant)
end

Workspace.DescendantAdded:Connect(watch)

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0

	local now = os.clock()

	for k, v3 in pairs(v2) do
		if k.Parent == nil or not k:IsDescendantOf(Workspace) then
			if k.Parent ~= nil then
				v2[k] = nil
			end
		else
			v3.name = k.Name
			v3.isDrum = v3.name:find("_Drum", 1, true) ~= nil
			v3.anchor = k.Parent
			v3.position = worldPositionOf(k.Parent) or v3.position -- inferred equivalent call
			v3.soundId = k.SoundId
			v3.volume = k.Volume

			if k.IsPlaying then
				v3.speed = math.max(k.PlaybackSpeed, 0.25)
				v3.length = k.TimeLength
				v3.lastPos = k.TimePosition
				v3.lastAt = now
				v3.lastPlayingAt = now

				if
					not v3.tailed
					and v3.length > 0
					and (v3.length - v3.lastPos) / v3.speed <= 2.2
					and not isSegmentPartA(v3) -- inferred equivalent call
				then
					startTail(v3, "habis", nil, 2.2)
				end
			end
		end
	end
end)