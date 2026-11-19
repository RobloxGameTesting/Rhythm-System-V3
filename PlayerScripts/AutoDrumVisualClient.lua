local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DrumAnimator = require(ReplicatedStorage.Modules.DrumAnimator)

local instanceSet = {}

local function applyAttribute(instance) -- 2 equivalent calls inferred from this helper
	local autoSongName = instance:GetAttribute("AutoSongName")

	if autoSongName and autoSongName ~= "" then
		DrumAnimator.SetAutoChartSyncActive(instance, true, autoSongName)
	else
		DrumAnimator.SetAutoChartSyncActive(instance, false)
	end
end

local function watchStand(instance)
	if instanceSet[instance] or instance:GetAttribute("InstrumentType") ~= "Drum" then
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