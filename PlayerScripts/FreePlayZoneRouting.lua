local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local v = "AudioRig_" .. tostring(LocalPlayer.UserId)

local Map = Workspace:WaitForChild("Map")

local MonoBoundaryMix = SoundService:FindFirstChild("MonoBoundaryMix", true)

while not MonoBoundaryMix do
	task.wait(0.25)
	MonoBoundaryMix = SoundService:FindFirstChild("MonoBoundaryMix", true)
end

local function stageGroupForRoot(instance) -- 2 equivalent calls inferred from this helper
	local studioId = instance and instance:GetAttribute("StudioId")

	if typeof(studioId) == "string" then
		return MonoBoundaryMix:FindFirstChild("StageMix_" .. studioId)
	end

	return nil
end

local function stageRootOf(p)
	local parent = p.Parent

	while parent and parent ~= Workspace do
		if parent.Parent == Map then
			return parent
		end

		parent = parent.Parent
	end

	return nil
end

local function nest(soundGroup, parent) -- 2 equivalent calls inferred from this helper
	if soundGroup.Parent == parent then
		return
	end

	local success, result = pcall(function()
		soundGroup.Parent = parent
	end)

	if not success then
		warn("[FreePlayZoneRouting] gagal nest", soundGroup.Name, result)
	end
end

local function routeRemote(instance)
	if not (instance:GetAttribute("FreePlayPresserUserId") ~= nil and instance:GetAttribute("FreePlayPresserUserId") ~= LocalPlayer.UserId) then
		return
	end

	local soundGroup = instance.SoundGroup
	local count = 0

	while not soundGroup and count < 20 and instance.Parent do
		task.wait(0.05)
		count += 1
		soundGroup = instance.SoundGroup
	end

	if not soundGroup or string.sub(soundGroup.Name, 1, 22) ~= "FreePlayReplicatedAmp_" then
		return
	end

	local parent = instance.Parent

	while true do
		if not parent or parent == Workspace then
			parent = nil
			break
		end

		if parent.Parent == Map then
			break
		end

		parent = parent.Parent
	end

	local parent2 = stageGroupForRoot(parent) -- inferred equivalent call

	if parent2 then
		nest(soundGroup, parent2) -- inferred equivalent call
	end
end

for _, sound in ipairs(Workspace:GetDescendants()) do
	if sound:IsA("Sound") then
		task.spawn(routeRemote, sound)
	end
end

Workspace.DescendantAdded:Connect(function(sound)
	if sound:IsA("Sound") then
		task.spawn(routeRemote, sound)
	end
end)

local function listenerPosition() -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position or nil
end

local function nearestStageGroup(p)
	local v2 = 1e999
	local v3 = nil

	for _, child in ipairs(Map:GetChildren()) do
		local audioZone = child:FindFirstChild("AudioZone")

		if not (audioZone and audioZone:IsA("BasePart")) then
			continue
		end

		local v4 = stageGroupForRoot(child) -- inferred equivalent call

		if not v4 then
			continue
		end

		local pointToObjectSpace = audioZone.CFrame:PointToObjectSpace(p)
		local v5 = audioZone.Size * 0.5
		local v6 = math.max(math.abs(pointToObjectSpace.X) - v5.X, 0)
		local v7 = math.max(math.abs(pointToObjectSpace.Y) - v5.Y, 0)
		local v8 = math.max(math.abs(pointToObjectSpace.Z) - v5.Z, 0)
		local v9 = math.sqrt(v6 * v6 + v7 * v7 + v8 * v8) * 1000 + (audioZone.Position - p).Magnitude

		if not (v9 < v2) then
			continue
		end

		v3 = v4
		v2 = v9
	end

	return v3
end

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.2 then
		return
	end

	total = 0

	local soundGroup = SoundService:FindFirstChild(v, true)

	if not (soundGroup and soundGroup:IsA("SoundGroup")) then
		return
	end

	local v2 = listenerPosition() -- inferred equivalent call

	if not v2 then
		return
	end

	local parent = nearestStageGroup(v2)

	if parent then
		nest(soundGroup, parent) -- inferred equivalent call
	end
end)