local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local FreePlaySyncState = require(ReplicatedStorage.Modules:WaitForChild("FreePlaySyncState"))

local LocalPlayer = Players.LocalPlayer

local v = { "RollOffMode", "RollOffMinDistance", "RollOffMaxDistance", "EmitterSize" }

local v2 = {}
local object = setmetatable({}, { __mode = "k" })

local v3 = {}
local v4 = {}

local function recordLatency(sound)
	if sound:GetAttribute("FPMirror") then
		return
	end

	local fpPressTime = sound:GetAttribute("FPPressTime")

	if typeof(fpPressTime) ~= "number" then
		return
	end

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")

	if freePlayPresserUserId == nil or freePlayPresserUserId == LocalPlayer.UserId then
		return
	end

	local v5 = tostring(freePlayPresserUserId) .. ":" .. string.format("%.4f", fpPressTime)

	if v4[v5] then
		return
	end

	v4[v5] = os.clock()
	local latency = Workspace:GetServerTimeNow() - fpPressTime

	if latency >= 0 and latency <= 1.5 then
		v3[#v3 + 1] = { At = os.clock(), Latency = latency }
	end
end

local function measurePingSeconds()
	local success, result = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)

	if success and typeof(result) == "number" and result >= 0 then
		return result
	end

	return nil
end

local function computeTargetDelay()
	local now = os.clock()
	local v5 = {}

	for _, v6 in ipairs(v3) do
		if now - v6.At <= 20 then
			v5[#v5 + 1] = v6
		end
	end

	v3 = v5
	local success, result = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)

	if not success or typeof(result) ~= "number" or not (result >= 0) then
		result = nil
	end

	if not (#v5 >= 3) then
		return (result or 0.05) + 0.04, #v5, result
	end

	local latencies = table.create(#v5)

	for i, v6 in ipairs(v5) do
		latencies[i] = v6.Latency
	end

	table.sort(latencies)
	return latencies[math.max(1, (math.ceil(#latencies * 0.9)))] + 0.025, #v5, result
end

task.spawn(function()
	while true do
		local v5, v6, v7 = computeTargetDelay()
		local delaySeconds = FreePlaySyncState.GetDelaySeconds()
		local v8 = v5 - delaySeconds

		if math.abs(v8) >= 0.015 then
			FreePlaySyncState.SetDelayMs((delaySeconds + math.clamp(v8, -0.03, 0.03)) * 1000)
		end

		LocalPlayer:SetAttribute("FreePlaySyncPingMs", v7 and math.floor(v7 * 1000 + 0.5) or nil)
		LocalPlayer:SetAttribute("FreePlaySyncDelayMs", FreePlaySyncState.GetDelayMs())
		LocalPlayer:SetAttribute("FreePlaySyncSamples", v6)
		task.wait(1)
	end
end)

local function shiftFor(freePlayPresserUserId, fpPressTime)
	local v5 = tostring(freePlayPresserUserId) .. ":" .. string.format("%.4f", fpPressTime)
	local v6 = v2[v5]

	if v6 then
		return v6.Shift
	end

	local delaySeconds = FreePlaySyncState.GetDelaySeconds()

	local shift = math.clamp(fpPressTime + delaySeconds - Workspace:GetServerTimeNow(), 0, delaySeconds + 0.25)
	v2[v5] = { Shift = shift, At = os.clock() }
	return shift
end

local function mirrorSound(sound)
	if object[sound] or sound:GetAttribute("FPMirror") then
		return
	end

	local fpPressTime = sound:GetAttribute("FPPressTime")

	if typeof(fpPressTime) ~= "number" then
		return
	end

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")

	if not (freePlayPresserUserId ~= LocalPlayer.UserId and FreePlaySyncState.IsEnabled()) then
		return
	end

	object[sound] = true

	local v5 = shiftFor(freePlayPresserUserId, fpPressTime)
	local timePosition = sound.TimePosition
	local volume2 = sound.Volume

	local sound2 = Instance.new("Sound")
	sound2.Name = sound.Name
	sound2.SoundId = sound.SoundId
	sound2.PlaybackSpeed = sound.PlaybackSpeed
	sound2.TimePosition = timePosition
	sound2.Looped = false
	sound2.Volume = 0
	local v6 = false
	local v7 = false
	local flag = false

	for _, v8 in ipairs(v) do
		pcall(function()
			sound2[v8] = sound[v8]
		end)
	end

	if sound.SoundGroup then
		sound2.SoundGroup = sound.SoundGroup
	end

	for k, v8 in pairs(sound:GetAttributes()) do
		sound2:SetAttribute(k, v8)
	end

	sound2:SetAttribute("FPPressTime", nil)
	sound2:SetAttribute("FPMirror", true)
	sound2.Parent = sound.Parent
	Debris:AddItem(sound2, 75)
	sound2.Ended:Connect(function()
		sound2:Destroy()
	end)

	sound.Volume = 0

	local function later(fn) -- 4 equivalent calls inferred from this helper
		if v5 <= 0.001 then
			task.defer(fn)
		else
			task.delay(v5, fn)
		end
	end

	local function fn()
		if v6 or not sound2.Parent then
			return
		end

		v7 = true
		local soundGroup = sound.SoundGroup

		if soundGroup and sound2.SoundGroup ~= soundGroup then
			sound2.SoundGroup = soundGroup
		end

		if timePosition > 0 then
			sound2.TimePosition = timePosition
		end

		sound2.Volume = volume2
		sound2:Play()
	end

	later(fn) -- inferred equivalent call
	local volumeChangedConnection = sound:GetPropertyChangedSignal("Volume"):Connect(function()
		local volume = sound.Volume

		if volume == 0 then
			return
		end

		sound.Volume = 0
		local function fn2()
			volume2 = volume

			if v7 and sound2.Parent then
				sound2.Volume = volume
			end
		end

		later(fn2) -- inferred equivalent call
	end)

	local soundGroupChangedConnection = sound:GetPropertyChangedSignal("SoundGroup"):Connect(function()
		if sound.SoundGroup and sound2.Parent then
			sound2.SoundGroup = sound.SoundGroup
		end
	end)

	local playingChangedConnection = sound:GetPropertyChangedSignal("Playing"):Connect(function()
		if sound.Playing then
			return
		end

		local function fn2()
			if sound2.Parent then
				pcall(function()
					sound2:Stop()
				end)
			end
		end

		later(fn2) -- inferred equivalent call
	end)

	local function release()
		if flag then
			return
		end

		flag = true
		object[sound] = nil
		volumeChangedConnection:Disconnect()
		soundGroupChangedConnection:Disconnect()
		playingChangedConnection:Disconnect()
		local function fn2()
			v6 = true

			if sound2.Parent then
				pcall(function()
					sound2:Stop()
				end)
				sound2:Destroy()
			end
		end

		later(fn2) -- inferred equivalent call
	end

	sound.Destroying:Connect(release)
	sound.AncestryChanged:Connect(function()
		if not sound:IsDescendantOf(Workspace) then
			release()
		end
	end)
end

Workspace.DescendantAdded:Connect(function(sound)
	if sound:IsA("Sound") then
		recordLatency(sound)
		mirrorSound(sound)
	end
end)

task.spawn(function()
	while true do
		task.wait(15)
		local now = os.clock()

		for k, v5 in pairs(v2) do
			if now - v5.At > 60 then
				v2[k] = nil
			end
		end

		for k, v5 in pairs(v4) do
			if now - v5 > 60 then
				v4[k] = nil
			end
		end
	end
end)