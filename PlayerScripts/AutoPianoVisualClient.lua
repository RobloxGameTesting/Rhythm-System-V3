local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PianoAnimator = require(ReplicatedStorage.Modules.PianoAnimator)

local instanceSet = {}

local function applyAttribute(instance) -- 2 equivalent calls inferred from this helper
	local autoSongName = instance:GetAttribute("AutoSongName")

	if autoSongName and autoSongName ~= "" then
		PianoAnimator.SetAutoChartSyncActive(instance, true, autoSongName)
	else
		PianoAnimator.SetAutoChartSyncActive(instance, false)
	end
end

local function watchStand(instance)
	if instanceSet[instance] or instance:GetAttribute("InstrumentType") ~= "Piano" then
		return
	end

	instanceSet[instance] = true

	instance:GetAttributeChangedSignal("AutoSongName"):Connect(function()
		applyAttribute(instance) -- inferred equivalent call
	end)
	applyAttribute(instance) -- inferred equivalent call
end

for _, v in ipairs(CollectionService:GetTagged("InstrumentStand")) do
	watchStand(v)
end

CollectionService:GetInstanceAddedSignal("InstrumentStand"):Connect(watchStand)