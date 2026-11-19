local v = { "Kick", "Snare", "Hi-Hat", "Perc", "Cymbal" }
local v2 = {
	Color3.fromRGB(75, 95, 60),
	Color3.fromRGB(120, 40, 35),
	Color3.fromRGB(150, 125, 45),
	Color3.fromRGB(55, 80, 95),
	Color3.fromRGB(150, 85, 30)
}

local v3 = { Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B, Enum.KeyCode.N }
return {
	Build = function(list, p, p2, data, p3)
		local v4 = p3 or v3
		local notes = table.create(#list)

		for i, item in ipairs(list) do
			local representedNotes = item.RepresentedNotes

			if not representedNotes then
				if item.ReactionType == nil then
					error(string.format(
						"[DrumLayoutBuilder] Drum note tanpa ReactionType (Lane=%s, Time=%s). ReactionType wajib ada di setiap note Drum dari chart - tidak ada fallback/inference dari ChartLane.",
						tostring(item.Lane),
						(tostring(item.Time))
					))
				end

				representedNotes = {
					{ ChartLane = item.Lane, ReactionType = item.ReactionType }
				}
			end

			notes[i] = {
				Lane = item.Lane,
				Time = item.Time,
				Duration = item.Duration,
				RepresentedNotes = representedNotes
			}
		end

		if p then
			local v5 = {}

			for i, v6 in ipairs(notes) do
				if v6.Lane == 1 then
					table.insert(v5, i)
				end
			end

			table.sort(v5, function(a, b): boolean
				return notes[a].Time < notes[b].Time
			end)
			local time = nil
			local v6 = false

			for _, v7 in ipairs(v5) do
				local v8 = notes[v7]

				if time and v8.Time - time < data.DoublePedalMinGapSeconds then
					v6 = not v6

					if v6 then
						v8.Lane = 0
					end
				else
					v6 = false
				end

				time = v8.Time
			end
		end

		local v5 = p and not p2 and 1 or 0
		local v6 = {}
		local keyBindings = {}
		local laneNames = {}
		local laneColors = {}

		for i, v7 in ipairs(p2 and { 5, 4, 3, 2, 1 } or { 1, 2, 3, 4, 5 }) do
			local v8 = i + v5
			v6[v7] = v8
			keyBindings[v8] = v4[i]
			laneNames[v8] = v[v7]
			laneColors[v8] = v2[v7]
		end

		for _, v7 in ipairs(notes) do
			if v7.Lane >= 1 and v7.Lane <= 5 then
				v7.Lane = v6[v7.Lane]
			end
		end

		local laneCount

		if p then
			local lane = p2 and 6 or 1
			keyBindings[lane] = p2 and data.DoublePedalKeyFlipped or data.DoublePedalKeyNormal
			laneNames[lane] = data.DoublePedalLaneName
			laneColors[lane] = data.DoublePedalColor
			laneCount = 6

			for _, v7 in ipairs(notes) do
				if v7.Lane == 0 then
					v7.Lane = lane
				end
			end
		else
			laneCount = 5
		end

		return {
			Notes = notes,
			LaneCount = laneCount,
			KeyBindings = keyBindings,
			LaneNames = laneNames,
			LaneColors = laneColors
		}
	end
}