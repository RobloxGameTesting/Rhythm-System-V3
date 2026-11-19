local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local function isTrackedEmitter(instance): boolean
	if
		instance.Name == "MicPASingerEmitter"
		or instance.Name == "CharacterVoiceEmitter"
		or instance.Name == "Emitter" and instance:FindFirstAncestor("DuetChains")
	then
		return true
	end

	return false
end

local v = {}

local function isOnMyCharacter(p) -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character

	if not character then
		return false
	end

	local parent = p.Parent
	local parent2 = parent and parent.Parent
	return parent2 ~= nil and parent2:IsDescendantOf(character)
end

local function apply(p) -- 3 equivalent calls inferred from this helper
	local audioInteractionGroup = v[p]

	if audioInteractionGroup == nil then
		return
	end

	if LocalPlayer:GetAttribute("MicListenSelf") ~= true then
		audioInteractionGroup = isOnMyCharacter(p) and "SelfVoiceMuted" or audioInteractionGroup -- inferred equivalent call
	end

	if p.AudioInteractionGroup ~= audioInteractionGroup then
		p.AudioInteractionGroup = audioInteractionGroup
	end
end

local function applyAll() -- 1 equivalent call inferred from this helper
	for k in pairs(v) do
		apply(k) -- inferred equivalent call
	end
end

local function register(audioEmitter)
	if
		audioEmitter:IsA("AudioEmitter")
		and not v[audioEmitter]
		and (audioEmitter.Name == "MicPASingerEmitter" or audioEmitter.Name == "CharacterVoiceEmitter" or audioEmitter.Name == "Emitter" and audioEmitter:FindFirstAncestor("DuetChains"))
	then
		v[audioEmitter] = audioEmitter.AudioInteractionGroup

		audioEmitter.AncestryChanged:Connect(function()
			apply(audioEmitter) -- inferred equivalent call
		end)
		apply(audioEmitter) -- inferred equivalent call
	end
end

local function unregister(p)
	v[p] = nil
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	register(descendant)
end

Workspace.DescendantAdded:Connect(register)
Workspace.DescendantRemoving:Connect(unregister)

LocalPlayer:GetAttributeChangedSignal("MicListenSelf"):Connect(applyAll)
LocalPlayer.CharacterAdded:Connect(applyAll)

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.25 then
		return
	end

	total = 0
	applyAll() -- inferred equivalent call
end)