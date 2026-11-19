local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MicrophoneConfig = require(ReplicatedStorage.Modules.MicrophoneConfig)

local LocalPlayer = Players.LocalPlayer

local function findMicPrompt(name)
	local map = Workspace:FindFirstChild("Map")
	local child = map and map:FindFirstChild(name)
	local child2 = child and child:FindFirstChild(MicrophoneConfig.MICROPHONE_FOLDER_NAME)
	local child3 = child2 and child2:FindFirstChild(MicrophoneConfig.MICROPHONE_MODEL_NAME)
	local promptAnchor = child3 and child3:FindFirstChild("PromptAnchor")
	return promptAnchor and promptAnchor:FindFirstChildOfClass("ProximityPrompt")
end

local function refreshPromptVisibility()
	local equippedInstrumentType = LocalPlayer:GetAttribute("EquippedInstrumentType")
	local v

	if equippedInstrumentType == nil then
		v = false
	else
		v = MicrophoneConfig.BLOCKED_INSTRUMENT_TYPES[equippedInstrumentType] == true
	end

	for _, v2 in ipairs(MicrophoneConfig.STAGE_STUDIO_IDS) do
		local map = Workspace:FindFirstChild("Map")

		if not map then
			continue
		end

		for _, child in ipairs(map:GetChildren()) do
			if child:GetAttribute("StudioId") ~= v2 then
				continue
			end

			local micPrompt = findMicPrompt(child.Name)

			if micPrompt then
				micPrompt.Enabled = not v
			end
		end
	end
end

LocalPlayer:GetAttributeChangedSignal("EquippedInstrumentType"):Connect(refreshPromptVisibility)

task.spawn(function()
	for _ = 1, 10 do
		refreshPromptVisibility()
		task.wait(1)
	end
end)