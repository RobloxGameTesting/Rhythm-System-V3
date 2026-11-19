local v = {}
local FreePlayProfileRegistry = {}

function FreePlayProfileRegistry.Register(p, p2)
	if v[p] then
		warn("[FreePlayProfileRegistry] Overwrite profile untuk instrumen:", p)
	end

	v[p] = p2
end

function FreePlayProfileRegistry.Get(p)
	return v[p]
end

return FreePlayProfileRegistry