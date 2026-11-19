local function copyNote(data)
	local representedNotes

	if data.RepresentedNotes then
		representedNotes = table.create(#data.RepresentedNotes)

		for i, representedNote in ipairs(data.RepresentedNotes) do
			representedNotes[i] = representedNote
		end
	end

	return {
		Lane = data.Lane,
		Time = data.Time,
		Duration = data.Duration,
		ReactionType = data.ReactionType,
		RepresentedNotes = representedNotes
	}
end

return {
	Simplify = function(list, p)
		local v = math.clamp(tonumber(p) or 10, 0, 10)

		if not list or #list == 0 then
			return {}
		end

		local v2 = math.max(v - 1, 0) / 9 * 0.12 + 0.03
		local v3 = 1 - v / 10

		local v4 = {}

		for _, item in ipairs(list) do
			table.insert(v4, item)
		end

		table.sort(v4, function(a, b): boolean
			return a.Time < b.Time
		end)

		local count = #v4
		local v5 = 1
		local result = {}

		while v5 <= count do
			local time = v4[v5].Time
			local v6 = { v4[v5] }
			v5 += 1

			while v5 <= count and v4[v5].Time - time < v2 do
				table.insert(v6, v4[v5])
				v5 += 1
			end

			if #v6 == 1 or v <= 0 then
				for _, v7 in ipairs(v6) do
					table.insert(result, copyNote(v7))
				end
			else
				table.sort(v6, function(a, b): boolean
					return a.Lane < b.Lane
				end)
				local v7 = math.max(1, (math.ceil(#v6 * v3)))

				local v8 = {}

				for i = 1, v7 do
					local v9 = copyNote(v6[i])
					v9.RepresentedNotes = v9.RepresentedNotes or {
						{ ChartLane = v6[i].Lane, ReactionType = v6[i].ReactionType }
					}
					v8[i] = v9
				end

				for i = v7 + 1, #v6 do
					local v9 = v6[i]
					local v10 = v8[1]

					if v9.RepresentedNotes then
						for _, representedNote in ipairs(v9.RepresentedNotes) do
							table.insert(v10.RepresentedNotes, representedNote)
						end
					else
						table.insert(v10.RepresentedNotes, {
							ChartLane = v9.Lane,
							ReactionType = v9.ReactionType
						})
					end
				end

				for _, v9 in ipairs(v8) do
					table.insert(result, v9)
				end
			end
		end

		table.sort(result, function(a, b): boolean
			return a.Time < b.Time
		end)
		return result
	end
}