local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local v = {}

local function collectEquipPrompts()
	local proximityPromptSet = {}

	for _, folder in ipairs(CollectionService:GetTagged("InstrumentStand")) do
		for _, proximityPrompt in ipairs(folder:GetDescendants()) do
			if proximityPrompt:IsA("ProximityPrompt") then
				proximityPromptSet[proximityPrompt] = true
			end
		end
	end

	return proximityPromptSet
end

local function refresh()
	local v2 = LocalPlayer:GetAttribute("EquippedInstrumentType") ~= nil
	local v3 = collectEquipPrompts()

	if v2 then
		for k in pairs(v3) do
			if v[k] == nil then
				v[k] = k.MaxActivationDistance
			end

			if k.MaxActivationDistance ~= 0 then
				k.MaxActivationDistance = 0
			end
		end
	else
		for k, maxActivationDistance in pairs(v) do
			if k.Parent then
				k.MaxActivationDistance = maxActivationDistance
			end

			v[k] = nil
		end
	end
end

LocalPlayer:GetAttributeChangedSignal("EquippedInstrumentType"):Connect(refresh)

task.spawn(function()
	while true do
		refresh()
		task.wait(1)
	end
end)