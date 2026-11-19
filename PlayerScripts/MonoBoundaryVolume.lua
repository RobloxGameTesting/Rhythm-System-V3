local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local v = {
	Climbing = true,
	Running = true,
	Jumping = true,
	Landing = true,
	Splash = true,
	Swimming = true,
	FreeFalling = true,
	GettingUp = true
}

local MonoBoundaryMix = SoundService:FindFirstChild("MonoBoundaryMix")

if not MonoBoundaryMix then
	MonoBoundaryMix = Instance.new("SoundGroup")
	MonoBoundaryMix.Name = "MonoBoundaryMix"
	MonoBoundaryMix.Volume = 1
	MonoBoundaryMix.Parent = SoundService
end

local Map = Workspace:WaitForChild("Map")

local v2 = {}

local function getStageEntry(instance)
	local v3 = v2[instance]

	if v3 then
		return v3
	end

	local studioId = instance:GetAttribute("StudioId")

	if typeof(studioId) ~= "string" then
		return nil
	end

	local soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "StageMix_" .. studioId
	soundGroup.Volume = 1
	soundGroup.Parent = MonoBoundaryMix
	local v4 = { Id = studioId, Root = instance, Group = soundGroup, Snapped = false }
	v2[instance] = v4
	return v4
end

local function stageEntryFor(p)
	local parent = p.Parent

	while parent and parent ~= Workspace do
		if parent.Parent == Map then
			return getStageEntry(parent)
		end

		parent = parent.Parent
	end

	return nil
end

local function desiredGroup(sound) -- 2 equivalent calls inferred from this helper
	local v3 = stageEntryFor(sound)
	return v3 and v3.Group or MonoBoundaryMix
end

local function isOurGroup(soundGroup): boolean -- 1 equivalent call inferred from this helper
	if soundGroup == MonoBoundaryMix then
		return true
	elseif soundGroup == nil then
		return false
	else
		return soundGroup.Parent == MonoBoundaryMix
	end
end

local function routeSound(sound)
	if not sound:IsA("Sound") or v[sound.Name] or sound.SoundGroup then
		return
	end

	sound.SoundGroup = desiredGroup(sound) -- inferred equivalent call

	sound.AncestryChanged:Connect(function()
		if not sound.Parent then
			return
		end

		if isOurGroup(sound.SoundGroup) then -- inferred equivalent call
			local soundGroup = desiredGroup(sound) -- inferred equivalent call

			if sound.SoundGroup ~= soundGroup then
				sound.SoundGroup = soundGroup
			end
		end
	end)
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	routeSound(descendant)
end

Workspace.DescendantAdded:Connect(routeSound)

for _, child in ipairs(Map:GetChildren()) do
	getStageEntry(child)
end

Map.ChildAdded:Connect(function(child)
	task.defer(getStageEntry, child)
end)

local function normalizedDistanceOutsideZone(audioZone, p, p2, p3)
	local pointToObjectSpace = audioZone.CFrame:PointToObjectSpace(p)
	local v3 = audioZone.Size * 0.5
	local v4 = math.max(math.abs(pointToObjectSpace.X) - v3.X, 0) / p2
	local v5 = math.max(math.abs(pointToObjectSpace.Y) - v3.Y, 0) / p3
	local v6 = math.max(math.abs(pointToObjectSpace.Z) - v3.Z, 0) / p2
	return (math.sqrt(v4 * v4 + v5 * v5 + v6 * v6))
end

local function listenerPosition() -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return humanoidRootPart.Position
	end

	local currentCamera = Workspace.CurrentCamera
	return currentCamera and currentCamera.CFrame.Position or nil
end

RunService.Heartbeat:Connect(function(dt)
	local v3 = listenerPosition() -- inferred equivalent call
	local v4 = 1 - math.exp(-4 * dt)

	for k, v5 in pairs(v2) do
		if k.Parent then
			local audioZone = k:FindFirstChild("AudioZone")
			local volume

			if v3 and audioZone and audioZone:IsA("BasePart") then
				local fadeDistance = audioZone:GetAttribute("FadeDistance")
				local v6 = (typeof(fadeDistance) ~= "number" or fadeDistance <= 0) and 18 or fadeDistance

				local v7 = audioZone:GetAttribute("FadeDistanceY")

				if typeof(v7) ~= "number" or v7 <= 0 then
					v7 = v6
				end

				volume = math.clamp(1 - normalizedDistanceOutsideZone(audioZone, v3, v6, v7), 0, 1)
			else
				volume = 1
			end

			local group = v5.Group

			if v5.Snapped then
				local volume2 = group.Volume + (volume - group.Volume) * v4

				if math.abs(volume - volume2) < 0.002 then
					volume2 = volume
				end

				group.Volume = volume2
			else
				group.Volume = volume
				v5.Snapped = true
			end
		else
			v2[k] = nil
			v5.Group:Destroy()
		end
	end
end)