local v = {}
local v2 = nil
local UIPanelGate = {}

function UIPanelGate.Register(p, p2)
	v[p] = p2
end

function UIPanelGate.Current()
	return v2
end

function UIPanelGate.Request(p): boolean
	if v2 and v2 ~= p then
		local v3 = v[v2]

		if v3 and v3.IsOpen and not v3.IsOpen() then
			v2 = nil
		elseif v3 then
			if v3.CanClose and not v3.CanClose() then
				return false
			end

			local success, result = pcall(v3.Close)

			if not success then
				warn("[UIPanelGate] gagal menutup '" .. tostring(v2) .. "': " .. tostring(result))
			end
		end

		v2 = nil
	end

	v2 = p
	return true
end

function UIPanelGate.Release(p)
	if v2 == p then
		v2 = nil
	end
end

return UIPanelGate