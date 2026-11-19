local StageConfig = {}
StageConfig.SchemaVersion = 1
local function deepFreeze(list)
	for _, item in pairs(list) do
		if typeof(item) ~= "table" or table.isfrozen(item) then
			continue
		end

		deepFreeze(item)
	end

	return table.freeze(list)
end

StageConfig.Default = {
	PresenceRadius = 60,
	AudioRadius = 60,
	GracePeriod = 15,
	MaxPlayers = 8,
	LaptopDistance = 8,
	CountdownLength = 3,
	DefaultMixer = {}
}

StageConfig.Stages = {
	STAGE1 = { PresenceRadius = 20, AudioRadius = 65 },
	STAGE2 = { PresenceRadius = 22, AudioRadius = 60 },
	STAGE3 = { PresenceRadius = 22, AudioRadius = 60 },
	STAGE4 = { PresenceRadius = 28, AudioRadius = 65 }
}

local StudioSlotConfig = require(script.Parent.Parent.StudioSlotConfig)

for _, v in ipairs(StudioSlotConfig.AllStudioIds()) do
	StageConfig.Stages[v] = { PresenceRadius = 22, AudioRadius = 60 }
end

function StageConfig.Get(p)
	local v = {}

	for k, v2 in pairs(StageConfig.Default) do
		v[k] = v2
	end

	local stage = StageConfig.Stages[p]

	if stage then
		for k, v2 in pairs(stage) do
			v[k] = v2
		end
	end

	return deepFreeze(v)
end

return StageConfig