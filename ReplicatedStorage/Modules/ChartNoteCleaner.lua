return {
	Clean = function(list, p)
		if not list or #list == 0 then
			return {}
		end

		local v = p == "Drum"
		local v2 = {}
		local result = {}

		for _, item in ipairs(list) do
			local v3

			if v then
				v3 = tostring(item.Lane) .. "|" .. tostring(item.Time)
			else
				v3 = tostring(item.Lane) .. "|" .. tostring(item.Time) .. "|" .. tostring(item.Duration)
			end

			local v4 = v2[v3]

			if v4 then
				if v then
					local v5 = result[v4]

					if item.RepresentedNotes then
						for _, representedNote in ipairs(item.RepresentedNotes) do
							table.insert(v5.RepresentedNotes, representedNote)
						end
					else
						table.insert(v5.RepresentedNotes, {
							ChartLane = item.Lane,
							ReactionType = item.ReactionType
						})
					end
				end
			else
				local v5 = {
					Lane = item.Lane,
					Time = item.Time,
					Duration = item.Duration,
					Note = item.Note,
					Velocity = item.Velocity
				}

				if v then
					v5.ReactionType = item.ReactionType
					local representedNotes = {}

					if item.RepresentedNotes then
						for _, representedNote in ipairs(item.RepresentedNotes) do
							table.insert(representedNotes, representedNote)
						end
					else
						table.insert(representedNotes, {
							ChartLane = item.Lane,
							ReactionType = item.ReactionType
						})
					end

					v5.RepresentedNotes = representedNotes
				end

				table.insert(result, v5)
				v2[v3] = #result
			end
		end

		table.sort(result, function(a, b): boolean
			return a.Time < b.Time
		end)
		return result
	end
}