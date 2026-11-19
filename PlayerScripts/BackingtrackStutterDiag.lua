local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })

local function track(sound) -- 1 equivalent call inferred from this helper
	if sound:IsA("Sound") then
		object[sound] = true
	end
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	track(descendant) -- inferred equivalent call
end

Workspace.DescendantAdded:Connect(track)

local function isStem(instance): boolean -- 2 equivalent calls inferred from this helper
	return instance.Parent ~= nil
		and instance.Name ~= "SongEndEchoTail"
		and instance:GetAttribute("CanonicalElapsed") ~= nil
end

local function stateFor(k) -- 3 equivalent calls inferred from this helper
	local v = object2[k]

	if not v then
		v = { WasPlaying = false, ZeroFrames = 0, LastWarn = {} }
		object2[k] = v
	end

	return v
end

local function warnLimited(p, p2, p3) -- 4 equivalent calls inferred from this helper
	local now = os.clock()

	if now - (p.LastWarn[p2] or -1e999) < 0.5 then
		return
	end

	p.LastWarn[p2] = now
	warn("[StutterDiag] " .. p3)
end

local function pingMs()
	local success, result = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)

	if success and typeof(result) == "number" then
		return result * 1000
	end

	return -1
end

local function expectedPosition(instance) -- 1 equivalent call inferred from this helper
	local canonicalElapsed = instance:GetAttribute("CanonicalElapsed")
	local canonicalElapsedAt = instance:GetAttribute("CanonicalElapsedAt")

	if typeof(canonicalElapsed) == "number" and typeof(canonicalElapsedAt) == "number" then
		return canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
	end

	return nil
end

local v = 0
local v2 = 0
local total = 0
local total2 = 0
local count = 0

local function countPlaying() -- 2 equivalent calls inferred from this helper
	local count2 = 0

	for k in pairs(object) do
		if k.Parent and k.IsPlaying then
			count2 += 1
		end
	end

	return count2
end

RunService.Heartbeat:Connect(function(dt)
	if v < dt then
		v = dt
	end

	local function fn()
		return LocalPlayer:GetNetworkPing()
	end

	if dt > 0.1 then
		count += 1
		local v3 = dt * 1000
		local success, result = pcall(fn)

		warn(("[StutterDiag] frame lambat %.0f ms | ping=%.0f ms | Sound berbunyi=%d"):format(
			v3,
			(not success or typeof(result) ~= "number") and -1 or result * 1000,
			countPlaying() -- inferred equivalent call
		))
	end

	for k in pairs(object) do
		if not isStem(k) then -- inferred equivalent call
			continue
		end

		local v3 = stateFor(k) -- inferred equivalent call
		local isPlaying = k.IsPlaying

		if v3.WasPlaying and not isPlaying then
			local timeLength = k.TimeLength

			if timeLength <= 0 or k.TimePosition < timeLength - 0.5 then
				local name = k.Name
				local timePosition = k.TimePosition
				local volume = k.Volume
				local success, result = pcall(fn)

				warnLimited( -- inferred equivalent call
					v3,
					"stopped",
					("stem BERHENTI: %s | pos=%.2f/%.2f | Volume=%.2f | ping=%.0f ms"):format(
						name,
						timePosition,
						timeLength,
						volume,
						(not success or typeof(result) ~= "number") and -1 or result * 1000
					)
				)
			end
		end

		v3.WasPlaying = isPlaying

		if isPlaying and k.Volume > 0.01 and k.PlaybackLoudness == 0 then
			v3.ZeroFrames += 1

			if v3.ZeroFrames == 20 then
				local name = k.Name
				local volume = k.Volume
				local playbackSpeed = k.PlaybackSpeed
				local success, result = pcall(fn)

				warnLimited( -- inferred equivalent call
					v3,
					"zeroloud",
					("loudness 0 beruntun %d frame: %s | Volume=%.2f | speed=%.4f | ping=%.0f ms"):format(
						20,
						name,
						volume,
						playbackSpeed,
						(not success or typeof(result) ~= "number") and -1 or result * 1000
					)
				)
			end
		else
			v3.ZeroFrames = 0
		end
	end

	total += dt

	if total >= 0.25 then
		total = 0
		local count2 = countPlaying() -- inferred equivalent call

		if v2 < count2 then
			v2 = count2
		end

		if count2 >= 40 then
			local success, result = pcall(fn)

			warn(("[StutterDiag] Sound berbunyi tinggi: %d | ping=%.0f ms"):format(
				count2,
				(not success or typeof(result) ~= "number") and -1 or result * 1000
			))
		end
	end

	total2 += dt

	if total2 < 2 then
		return
	end

	total2 = 0
	local count2 = 0
	local count3 = 0
	local v3 = 0
	local v4 = 0
	local v5 = "-"

	for k in pairs(object) do
		if not isStem(k) then -- inferred equivalent call
			continue
		end

		count2 += 1

		if not k.IsPlaying then
			continue
		end

		count3 += 1
		local v6 = expectedPosition(k) -- inferred equivalent call

		if v6 then
			local v7 = v6 - k.TimePosition

			if math.abs(v7) > math.abs(v3) then
				v5 = k.Name
				v3 = v7
			end

			local v8 = stateFor(k) -- inferred equivalent call

			if math.abs(v7) >= 0.05 then
				local name = k.Name
				local playbackSpeed = k.PlaybackSpeed
				local success, result = pcall(fn)

				warnLimited( -- inferred equivalent call
					v8,
					"drift",
					("drift stem: %s | drift=%+.3f dtk | speed=%.4f | ping=%.0f ms"):format(
						name,
						v7,
						playbackSpeed,
						(not success or typeof(result) ~= "number") and -1 or result * 1000
					)
				)
			end
		end

		local v7 = math.abs(k.PlaybackSpeed - 1)

		if v4 < v7 then
			v4 = v7
		end

		if not (v7 >= 0.002) then
			continue
		end

		local v8 = stateFor(k) -- inferred equivalent call
		local name = k.Name
		local playbackSpeed = k.PlaybackSpeed
		local success, result = pcall(fn)

		warnLimited( -- inferred equivalent call
			v8,
			"speed",
			("PlaybackSpeed bergeser: %s | speed=%.4f | ping=%.0f ms"):format(
				name,
				playbackSpeed,
				(not success or typeof(result) ~= "number") and -1 or result * 1000
			)
		)
	end

	if count2 > 0 then
		local v6 = v2
		local v7 = v * 1000
		local success, result = pcall(fn)

		print(("[StutterDiag] stem=%d berbunyi=%d | drift terburuk=%+.3f (%s) | speed maks dev=%.4f | Sound berbunyi puncak=%d | frame terlama=%.0f ms | ping=%.0f ms"):format(
			count2,
			count3,
			v3,
			v5,
			v4,
			v6,
			v7,
			(not success or typeof(result) ~= "number") and -1 or result * 1000
		))
	end

	v = 0
	v2 = 0
	count = 0
end)