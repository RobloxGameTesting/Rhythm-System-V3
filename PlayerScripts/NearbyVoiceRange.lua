local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local v = { [0] = 1, [6] = 1, [15] = 0 }
local v2 = { [0] = 0, [15] = 0 }

local LocalPlayer = Players.LocalPlayer

local nearVoiceListenerAttachment = nil
local nearVoiceListener = nil

local function ensureListener()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	if
		nearVoiceListenerAttachment
		and nearVoiceListenerAttachment.Parent == humanoidRootPart
		and nearVoiceListener
		and nearVoiceListener.Parent == nearVoiceListenerAttachment
	then
		return nearVoiceListenerAttachment
	end

	if nearVoiceListenerAttachment then
		nearVoiceListenerAttachment:Destroy()
	end

	nearVoiceListenerAttachment = Instance.new("Attachment")
	nearVoiceListenerAttachment.Name = "NearVoiceListenerAttachment"
	nearVoiceListenerAttachment.Parent = humanoidRootPart

	nearVoiceListener = Instance.new("AudioListener")
	nearVoiceListener.Name = "NearVoiceListener"
	nearVoiceListener.AudioInteractionGroup = "NearVoice"
	nearVoiceListener.Parent = nearVoiceListenerAttachment

	local nearVoiceOutput = Instance.new("AudioDeviceOutput")
	nearVoiceOutput.Name = "NearVoiceOutput"
	nearVoiceOutput.Parent = nearVoiceListener

	local listenerToOutput = Instance.new("Wire")
	listenerToOutput.Name = "ListenerToOutput"
	listenerToOutput.SourceInstance = nearVoiceListener
	listenerToOutput.TargetInstance = nearVoiceOutput
	listenerToOutput.Parent = nearVoiceListener

	return nearVoiceListenerAttachment
end

RunService.RenderStepped:Connect(function()
	local listener = ensureListener()
	local currentCamera = Workspace.CurrentCamera

	if listener and currentCamera then
		local parent = listener.Parent
		listener.WorldCFrame = CFrame.new(parent.Position + Vector3.new(0, 1.5, 0)) * (currentCamera.CFrame - currentCamera.CFrame.Position)
	end
end)

local v3 = {}
local object = setmetatable({}, { __mode = "k" })

local function ownerOf(audioEmitter)
	local player = audioEmitter:FindFirstAncestorOfClass("Player")

	if player then
		return player
	end

	local parentModel = audioEmitter:FindFirstAncestorOfClass("Model")

	while parentModel do
		local playerFromCharacter = Players:GetPlayerFromCharacter(parentModel)

		if playerFromCharacter then
			return playerFromCharacter
		end

		local parent = parentModel.Parent
		parentModel = parent and parent:FindFirstAncestorOfClass("Model") or nil
	end

	return nil
end

local function register(audioEmitter)
	if not audioEmitter:IsA("AudioEmitter") or v3[audioEmitter] then
		return
	end

	local v4 = ownerOf(audioEmitter)

	if v4 and v4 ~= LocalPlayer then
		v3[audioEmitter] = v4
	end
end

for _, audioEmitter in ipairs(Workspace:GetDescendants()) do
	if not audioEmitter:IsA("AudioEmitter") or v3[audioEmitter] then
		continue
	end

	local v4 = ownerOf(audioEmitter)

	if v4 and v4 ~= LocalPlayer then
		v3[audioEmitter] = v4
	end
end

for _, audioEmitter in ipairs(Players:GetDescendants()) do
	if not audioEmitter:IsA("AudioEmitter") or v3[audioEmitter] then
		continue
	end

	local v4 = ownerOf(audioEmitter)

	if v4 and v4 ~= LocalPlayer then
		v3[audioEmitter] = v4
	end
end

Workspace.DescendantAdded:Connect(function(descendant)
	task.defer(register, descendant)
end)
Players.DescendantAdded:Connect(function(descendant)
	task.defer(register, descendant)
end)

local v4 = -1
local lastTime = 0

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0
	local count = 0

	for k, v5 in pairs(v3) do
		if k:IsDescendantOf(game) then
			local audioInteractionGroup = k.AudioInteractionGroup

			if audioInteractionGroup == "" or audioInteractionGroup == "NearVoice" then
				count += 1

				if audioInteractionGroup ~= "NearVoice" then
					k.AudioInteractionGroup = "NearVoice"
				end

				local v6 = v5:GetAttribute("StageMicSinging") and "mute" or "near"

				if object[k] ~= v6 then
					object[k] = v6
					k:SetDistanceAttenuation(v6 == "mute" and v2 or v)
				end
			end
		else
			v3[k] = nil
			object[k] = nil
		end
	end

	if count ~= v4 and os.clock() - lastTime > 5 then
		v4 = count
		lastTime = os.clock()
		print("[NearbyVoiceRange] emitter voice pemain lain yang dikontrol:", count)
	end
end)