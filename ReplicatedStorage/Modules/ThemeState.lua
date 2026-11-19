local v = "2D"
local v2 = {}
local ThemeState = {}

function ThemeState.Get()
	return v
end

function ThemeState.Set(p)
	if p ~= "2D" and p ~= "3D" or p == v then
		return
	end

	v = p

	for _, callback in ipairs(v2) do
		local success, result = pcall(callback, p)

		if not success then
			warn("[ThemeState] Error pada listener:", result)
		end
	end
end

function ThemeState.OnChanged(p)
	table.insert(v2, p)
end

return ThemeState