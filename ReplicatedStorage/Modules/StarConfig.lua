local StarConfig = {}
StarConfig.MaxStars = 5
StarConfig.GradeToStars = {
	S = 5,
	A = 4,
	B = 3,
	C = 2,
	D = 1,
	F = 0
}
StarConfig.EmptyTransparency = 0.65
local v = utf8.char(9733)

function StarConfig.FromGrade(p)
	return StarConfig.GradeToStars[p] or 0
end

function StarConfig.RichText(p, p2, p3)
	local v2 = math.clamp(math.floor(tonumber(p) or 0), 0, StarConfig.MaxStars)
	local v3 = {}

	if v2 > 0 then
		table.insert(v3, string.format("<font color=\"#%s\">%s</font>", p2, string.rep(v, v2)))
	end

	if v2 < StarConfig.MaxStars then
		table.insert(
			v3,
			string.format(
				"<font color=\"#%s\" transparency=\"%.2f\">%s</font>",
				p3,
				StarConfig.EmptyTransparency,
				string.rep(v, StarConfig.MaxStars - v2)
			)
		)
	end

	return table.concat(v3)
end

function StarConfig.PlainText()
	return string.rep(v, StarConfig.MaxStars)
end

return StarConfig