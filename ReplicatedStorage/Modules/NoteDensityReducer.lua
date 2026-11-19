local function copyNote(data) -- 1 equivalent call inferred from this helper
	return {
		Lane = data.Lane,
		Time = data.Time,
		Duration = data.Duration,
		ReactionType = data.ReactionType,
		RepresentedNotes = data.RepresentedNotes
	}
end

return {
	Reduce = function(list, p)
		local v = math.clamp(tonumber(p) or 10, 0, 10)

		if not list or #list == 0 then
			return {}
		end

		local v2 = v / 10 * 0.4

		local v3 = table.create(#list)

		for _, item in ipairs(list) do
			table.insert(v3, item)
		end

		table.sort(v3, function(a, b): boolean
			if a.Time == b.Time then
				return a.Lane < b.Lane
			end

			return a.Time < b.Time
		end)
		local time = nil
		local result = {}

		for _, v4 in ipairs(v3) do
			local v5

			if time == nil then
				v5 = true
			else
				local v6 = v4.Time - time

				v5 = v6 <= 0.02 or v2 - 0.0001 <= v6
			end

			if not v5 then
				continue
			end

			table.insert(result, copyNote(v4)) -- inferred equivalent call

			if time == nil or v4.Time - time > 0.02 then
				time = v4.Time
			end
		end

		return result
	end
}