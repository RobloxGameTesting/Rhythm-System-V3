local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local InstrumentConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("InstrumentConfig"))
local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local LocalPlayer = Players.LocalPlayer
local Map = Workspace:WaitForChild("Map")

local normalWalkSpeed = InstrumentConfig.NormalWalkSpeed or 8
local farWalkSpeed = InstrumentConfig.FarWalkSpeed or 11
local zoneSlowdownDistance = InstrumentConfig.ZoneSlowdownDistance or 15

local v = false
local v2 = 5

instrumentHUDUpdate.OnClientEvent:Connect(function(p, value)
	v = p and true or false
	v2 = 5

	if v and typeof(value) == "string" then
		local v3 = InstrumentConfig.Instruments and InstrumentConfig.Instruments[value]

		if v3 and typeof(v3.EquippedWalkSpeed) == "number" then
			v2 = v3.EquippedWalkSpeed
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	v = false
	v2 = 5
end)

local parts = {}
local v3 = -1e999
local function refreshZones()
	table.clear(parts)

	for _, child in ipairs(Map:GetChildren()) do
		local part = child:FindFirstChild("WalkSpeedZone")

		if not (part and part:IsA("BasePart")) then
			part = child:FindFirstChild("StageZone")
		end

		if part and part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end
end

local function distanceToNearestZone(position)
	local v4 = 1e999

	for _, v5 in ipairs(parts) do
		if not v5.Parent then
			continue
		end

		local pointToObjectSpace = v5.CFrame:PointToObjectSpace(position)
		local v6 = v5.Size * 0.5
		local magnitude = Vector3.new(
			math.max(math.abs(pointToObjectSpace.X) - v6.X, 0),
			math.max(math.abs(pointToObjectSpace.Y) - v6.Y, 0),
			(math.max(math.abs(pointToObjectSpace.Z) - v6.Z, 0))
		).Magnitude

		if magnitude < v4 then
			v4 = magnitude
		end
	end

	return v4
end

local function targetSpeed(humanoidRootPart) -- 1 equivalent call inferred from this helper
	if v then
		return v2
	end

	local v4 = distanceToNearestZone(humanoidRootPart.Position)

	if v4 == 1e999 then
		return farWalkSpeed
	end

	local v5 = math.clamp(v4 / zoneSlowdownDistance, 0, 1)
	return normalWalkSpeed + (farWalkSpeed - normalWalkSpeed) * v5
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if now - v3 >= 1 then
		v3 = now
		refreshZones()
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return
	end

	if humanoid.WalkSpeed <= 0.01 or humanoid.Sit then
		return
	end

	local walkSpeed = targetSpeed(humanoidRootPart) -- inferred equivalent call

	if math.abs(humanoid.WalkSpeed - walkSpeed) > 0.01 then
		humanoid.WalkSpeed = walkSpeed
	end
end)