local card = nil
local ResultHistoryBridge = {}

function ResultHistoryBridge.RegisterCard(p)
	card = p
end

function ResultHistoryBridge.GetCard()
	return card
end

return ResultHistoryBridge