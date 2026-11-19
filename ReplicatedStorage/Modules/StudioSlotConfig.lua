local StudioSlotConfig = {
	SlotCount = 8,
	SourceFolderName = "STUDIO 1",
	BaseOffsetX = 4000,
	StepOffsetX = 1500,
	StudioId = function(p)
		return "STUDIO" .. p
	end,
	FolderName = function(p)
		return "STUDIO " .. p
	end
}

function StudioSlotConfig.OffsetX(p)
	return StudioSlotConfig.BaseOffsetX + (p - 1) * StudioSlotConfig.StepOffsetX
end

function StudioSlotConfig.AllStudioIds()
	local result = {}

	for i = 1, StudioSlotConfig.SlotCount do
		result[#result + 1] = StudioSlotConfig.StudioId(i)
	end

	return result
end

return StudioSlotConfig