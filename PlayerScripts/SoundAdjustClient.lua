local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SoundAdjustConfig = require(ReplicatedStorage.Modules:WaitForChild("SoundAdjustConfig"))

local attr = SoundAdjustConfig.ATTR

local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Linear)

local Map = Workspace:WaitForChild("Map")

local v = {}

local function applyCfg(data)
	local decoded = SoundAdjustConfig.Decode(data.root:GetAttribute(attr))
	TweenService:Create(data.group, tweenInfo, {
		Volume = decoded.vol / 100
	}):Play()
	data.eq.LowGain = decoded.bass
	data.eq.Enabled = decoded.bass ~= 0
	data.reverb.WetLevel = SoundAdjustConfig.ReverbWetDb(decoded.rev)
	data.reverb.Enabled = decoded.rev > 0
end

local function getEntry(instance)
	local v2 = v[instance]

	if v2 then
		return v2
	end

	local studioId = instance:GetAttribute("StudioId")

	if typeof(studioId) ~= "string" then
		return nil
	end

	local soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "SoundAdjust_" .. studioId
	soundGroup.Volume = 1

	local bass = Instance.new("EqualizerSoundEffect")
	bass.Name = "Bass"
	bass.LowGain = 0
	bass.MidGain = 0
	bass.HighGain = 0
	bass.Enabled = false
	bass.Parent = soundGroup

	local reverb = Instance.new("ReverbSoundEffect")
	reverb.Name = "Reverb"
	reverb.DecayTime = SoundAdjustConfig.REVERB_DECAY
	reverb.Density = 1
	reverb.Diffusion = 1
	reverb.DryLevel = 0
	reverb.WetLevel = -80
	reverb.Enabled = false
	reverb.Parent = soundGroup

	local monoBoundaryMix = SoundService:FindFirstChild("MonoBoundaryMix")
	soundGroup.Parent = monoBoundaryMix or SoundService

	local v3 = {
		id = studioId,
		root = instance,
		group = soundGroup,
		eq = bass,
		reverb = reverb
	}
	v[instance] = v3

	task.spawn(function()
		local v4 = monoBoundaryMix or SoundService:WaitForChild("MonoBoundaryMix", 20)
		local child = v4 and v4:WaitForChild("StageMix_" .. studioId, 20)

		if child and soundGroup.Parent and soundGroup.Parent ~= child then
			soundGroup.Parent = child
		end
	end)

	instance:GetAttributeChangedSignal(attr):Connect(function()
		applyCfg(v3)
	end)
	applyCfg(v3)

	instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			v[instance] = nil
			soundGroup:Destroy()
		end
	end)

	return v3
end

local function stageEntryFor(p)
	local parent = p.Parent

	while parent and parent ~= Workspace do
		if parent.Parent == Map then
			return getEntry(parent)
		end

		parent = parent.Parent
	end

	return nil
end

local function isStem(sound) -- 2 equivalent calls inferred from this helper
	local v2 = sound:IsA("Sound")

	if v2 then
		if sound.Name == "SongEndEchoTail" then
			return false
		end

		return sound:GetAttribute("CanonicalElapsed") ~= nil
	end

	return v2
end

local function route(sound) -- 2 equivalent calls inferred from this helper
	local v2 = stageEntryFor(sound)

	if not v2 then
		return
	end

	local soundGroup = sound.SoundGroup

	if soundGroup == v2.group or soundGroup ~= nil and string.sub(soundGroup.Name, 1, 9) ~= "StageMix_" then
		return
	end

	sound.SoundGroup = v2.group
end

local function watch(sound)
	if not sound:IsA("Sound") or sound.Name == "SongEndEchoTail" then
		return
	end

	if isStem(sound) then -- inferred equivalent call
		route(sound) -- inferred equivalent call
	else
		local canonicalElapsedChangedConnection = nil
		canonicalElapsedChangedConnection = sound:GetAttributeChangedSignal("CanonicalElapsed"):Connect(function()
			if isStem(sound) then -- inferred equivalent call
				canonicalElapsedChangedConnection:Disconnect()
				route(sound) -- inferred equivalent call
			end
		end)
	end
end

for _, child in ipairs(Map:GetChildren()) do
	getEntry(child)
end

Map.ChildAdded:Connect(function(child)
	task.defer(getEntry, child)
end)

for _, descendant in ipairs(Map:GetDescendants()) do
	watch(descendant)
end

Map.DescendantAdded:Connect(watch)