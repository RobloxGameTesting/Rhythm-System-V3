local v = {}
local PedalNodeTypeRegistry = {}

function PedalNodeTypeRegistry.Register(p, p2)
	if v[p] then
		warn("[PedalNodeTypeRegistry] Overwrite pedal type:", p)
	end

	v[p] = p2
end

function PedalNodeTypeRegistry.Get(p)
	return v[p]
end

return PedalNodeTypeRegistry