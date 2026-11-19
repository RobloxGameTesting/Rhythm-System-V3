local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Map = Workspace:WaitForChild("Map")

local stageMicZoneListener = nil

local function ensureListener()
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	if stageMicZoneListener and stageMicZoneListener.Parent == currentCamera then
		return stageMicZoneListener
	end

	if stageMicZoneListener then
		stageMicZoneListener:Destroy()
	end

	stageMicZoneListener = Instance.new("AudioListener")
	stageMicZoneListener.Name = "StageMicZoneListener"
	stageMicZoneListener.AudioInteractionGroup = "StageMic_None"
	stageMicZoneListener.Parent = currentCamera

	local stageMicZoneOutput = Instance.new("AudioDeviceOutput")
	stageMicZoneOutput.Name = "StageMicZoneOutput"
	stageMicZoneOutput.Parent = stageMicZoneListener

	local listenerToOutput = Instance.new("Wire")
	listenerToOutput.Name = "ListenerToOutput"
	listenerToOutput.SourceInstance = stageMicZoneListener
	listenerToOutput.TargetInstance = stageMicZoneOutput
	listenerToOutput.Parent = stageMicZoneListener

	return stageMicZoneListener
end

local function isInsideZone(audioZone, p): boolean
	local pointToObjectSpace = audioZone.CFrame:PointToObjectSpace(p)
	local v = audioZone.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v.X + 2
		and math.abs(pointToObjectSpace.Y) <= v.Y + 2
		and math.abs(pointToObjectSpace.Z) <= v.Z + 2
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

local function currentGroup()
	local v = listenerPosition() -- inferred equivalent call

	if not v then
		return "StageMic_None"
	end

	for _, child in ipairs(Map:GetChildren()) do
		local studioId = child:GetAttribute("StudioId")

		if typeof(studioId) ~= "string" then
			continue
		end

		local audioZone = child:FindFirstChild("AudioZone")

		if audioZone and audioZone:IsA("BasePart") and isInsideZone(audioZone, v) then
			return "StageMic_" .. studioId
		end
	end

	return "StageMic_None"
end

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0

	local listener = ensureListener()

	if not listener then
		return
	end

	local audioInteractionGroup = currentGroup()

	if listener.AudioInteractionGroup ~= audioInteractionGroup then
		listener.AudioInteractionGroup = audioInteractionGroup
	end
end)