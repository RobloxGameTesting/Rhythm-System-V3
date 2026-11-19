local v = { STAGE1 = "MAIN STAGE", STAGE2 = "BASEMENT", STAGE3 = "OPEN GARAGE", STAGE4 = "ROOFTOP" }
return {
	Display = function(value)
		local v2 = tostring(value or "")
		local v3 = string.upper((string.gsub(v2, "%s+", "")))

		if v[v3] then
			return v[v3]
		end

		return (string.gsub(v2, "^(%a+)(%d+)$", "%1 %2"))
	end
}