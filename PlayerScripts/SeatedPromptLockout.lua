local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer

local v = { Drum = true, Piano = true, Keyboard = true }

local flag = false

local function isLocked(): boolean -- 1 equivalent call inferred from this helper
	local equippedInstrumentType = LocalPlayer:GetAttribute("EquippedInstrumentType")
	return equippedInstrumentType ~= nil and v[equippedInstrumentType] == true
end

local function apply() -- 1 equivalent call inferred from this helper
	if isLocked() then -- inferred equivalent call
		flag = true

		if ProximityPromptService.Enabled then
			ProximityPromptService.Enabled = false
		end
	elseif flag then
		flag = false
		ProximityPromptService.Enabled = true
	end
end

LocalPlayer:GetAttributeChangedSignal("EquippedInstrumentType"):Connect(apply)

RunService.Heartbeat:Connect(apply)
apply() -- inferred equivalent call