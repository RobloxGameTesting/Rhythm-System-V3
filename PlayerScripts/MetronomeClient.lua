local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ContentProvider = game:GetService("ContentProvider")

local MetronomeConfig = require(ReplicatedStorage.Modules:WaitForChild("MetronomeConfig"))
local AudioSpatialMode = require(ReplicatedStorage.Modules:WaitForChild("AudioSpatialMode"))

local v = {
	down = { speed = 1.25, vol = 1 },
	group = { speed = 1.12, vol = 0.9 },
	beat = { speed = 1, vol = 0.8 },
	sub = { speed = 0.9, vol = 0.5 }
}

local Map = Workspace:WaitForChild("Map")
local v2 = {}

local function resolveAnchors(root)
	local anchors = {}
	local bVocalVirtualStand = root:FindFirstChild("BVocalVirtualStand")
	local function fromRef(childName) -- 2 equivalent calls inferred from this helper
		local objectValue = bVocalVirtualStand and bVocalVirtualStand:FindFirstChild(childName)
		local value = objectValue and objectValue:IsA("ObjectValue") and objectValue.Value
		return if value and value:IsA("BasePart") then value else nil
	end

	local value = fromRef("SoundAnchor") -- inferred equivalent call
	local value2 = fromRef("SecondarySoundAnchor") -- inferred equivalent call

	if not value then
		local decoration = root:FindFirstChild("Decoration")
		local prop = decoration and decoration:FindFirstChild("Prop")
		local speaker1 = prop and prop:FindFirstChild("Speaker 1")
		local speaker2 = prop and prop:FindFirstChild("Speaker 2")
		value = speaker1 and speaker1:FindFirstChild("BVocalSoundAnchor")
		value2 = value2 or speaker2 and speaker2:FindFirstChild("BVocalSoundAnchor")
	end

	if value then
		table.insert(anchors, value)

		if value2 and (value2.Position - value.Position).Magnitude > 2 then
			table.insert(anchors, value2)
		end
	end

	return anchors
end

local function destroyEmitters(state) -- 1 equivalent call inferred from this helper
	if state.emitters then
		for _, emitter in ipairs(state.emitters) do
			emitter.part:Destroy()
		end
	end

	state.emitters = nil
	state.soundId = nil
end

local function emittersValid(state): boolean -- 1 equivalent call inferred from this helper
	if not state.emitters or #state.emitters == 0 then
		return false
	end

	for _, emitter in ipairs(state.emitters) do
		if not emitter.part.Parent then
			return false
		end
	end

	return true
end

local function ensureEmitters(state, cfg): boolean
	if not emittersValid(state) then -- inferred equivalent call
		destroyEmitters(state) -- inferred equivalent call
		local anchors = resolveAnchors(state.root)

		if #anchors == 0 then
			return false
		end

		state.emitters = {}

		for _, anchor in ipairs(anchors) do
			local metronomeEmitter = Instance.new("Part")
			metronomeEmitter.Name = "MetronomeEmitter"
			metronomeEmitter.Transparency = 1
			metronomeEmitter.Anchored = true
			metronomeEmitter.CanCollide = false
			metronomeEmitter.CanQuery = false
			metronomeEmitter.CanTouch = false
			metronomeEmitter.Size = Vector3.new(0.5, 0.5, 0.5)
			metronomeEmitter.CFrame = anchor.CFrame
			local sounds = {}

			for _ = 1, 6 do
				local metronomeClick = Instance.new("Sound")
				metronomeClick.Name = "MetronomeClick"
				AudioSpatialMode.ApplyToSound(metronomeClick)
				metronomeClick.Parent = metronomeEmitter
				table.insert(sounds, metronomeClick)
			end

			metronomeEmitter.Parent = anchor.Parent or state.root
			table.insert(state.emitters, { part = metronomeEmitter, sounds = sounds, nextIdx = 0 })
		end
	end

	local v3 = MetronomeConfig.SOUNDS[cfg.snd] or MetronomeConfig.SOUNDS.click1

	if state.soundId == v3.assetId then
		return true
	end

	state.soundId = v3.assetId
	local sounds = {}

	for _, emitter in ipairs(state.emitters) do
		for _, sound in ipairs(emitter.sounds) do
			sound.SoundId = v3.assetId
			table.insert(sounds, sound)
		end
	end

	task.spawn(function()
		pcall(ContentProvider.PreloadAsync, ContentProvider, sounds)
	end)

	return true
end

local function click(state, cfg, p)
	local v3 = v[p]

	if not v3 then
		return
	end

	local volume = cfg.vol / 100 * v3.vol * MetronomeConfig.GAIN

	for _, emitter in ipairs(state.emitters) do
		emitter.nextIdx = emitter.nextIdx % 6 + 1
		local sound = emitter.sounds[emitter.nextIdx]
		local soundGroup = sound.SoundGroup

		if soundGroup and soundGroup.Volume <= 0.01 then
			continue
		end

		sound.Volume = volume
		sound.PlaybackSpeed = v3.speed
		sound.TimePosition = 0
		sound:Play()
	end
end

local function stepStage(state, serverTimeNow)
	local cfg = state.cfg

	if not ensureEmitters(state, cfg) then
		return
	end

	local v3 = 60 / cfg.bpm / cfg.sub
	local v4 = (serverTimeNow - cfg.t0) / v3
	local lastTick = math.floor(v4)

	if state.lastTick == nil then
		state.lastTick = math.max(lastTick, -1)
	elseif state.lastTick < lastTick then
		state.lastTick = lastTick

		local v5 = lastTick >= 0 and (v4 - lastTick) * v3 <= 0.15 and MetronomeConfig.TickInfo(cfg, lastTick)

		if v5 then
			click(state, cfg, v5)
		end
	end
end

local function watchStage(child)
	if v2[child] then
		return
	end

	local studioId = child:GetAttribute("StudioId")

	if type(studioId) ~= "string" then
		return
	end

	local v3 = {
		root = child,
		id = studioId,
		cfg = MetronomeConfig.Default(),
		lastTick = nil,
		emitters = nil,
		soundId = nil
	}
	v2[child] = v3

	local function pull()
		local decoded = MetronomeConfig.Decode(child:GetAttribute("MetronomeCfg"))
		local cfg = v3.cfg

		if
			cfg.on ~= decoded.on
			or cfg.t0 ~= decoded.t0
			or cfg.bpm ~= decoded.bpm
			or cfg.sub ~= decoded.sub
			or cfg.sig ~= decoded.sig
		then
			v3.lastTick = nil
		end

		v3.cfg = decoded
	end
	pull()
	child:GetAttributeChangedSignal("MetronomeCfg"):Connect(pull)
end

for _, child in ipairs(Map:GetChildren()) do
	watchStage(child)
end

Map.ChildAdded:Connect(watchStage)

AudioSpatialMode.OnChanged(function()
	for _, v3 in pairs(v2) do
		if not v3.emitters then
			continue
		end

		for _, emitter in ipairs(v3.emitters) do
			for _, sound in ipairs(emitter.sounds) do
				AudioSpatialMode.ApplyToSound(sound)
			end
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local serverTimeNow = Workspace:GetServerTimeNow()

	for _, v3 in pairs(v2) do
		if v3.cfg.on then
			stepStage(v3, serverTimeNow)
		else
			v3.lastTick = nil
		end
	end
end)