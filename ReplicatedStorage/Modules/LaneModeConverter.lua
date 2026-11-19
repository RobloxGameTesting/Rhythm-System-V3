local LaneModeConverter = {}

local v = {
	[5] = {
		[2] = { 1, 1, 1, 2, 2 },
		[3] = { 1, 1, 2, 3, 3 },
		[4] = { 1, 1, 2, 3, 4 }
	},
	[4] = {
		[2] = { 1, 1, 2, 2 },
		[3] = { 1, 1, 2, 3 }
	}
}

local function fallbackLane(lane, p, p2) -- 1 equivalent call inferred from this helper
	return (math.min(p2, (math.max(1, (math.ceil(lane * p2 / p))))))
end

function LaneModeConverter.ConvertToN(list, p, p2, p3)
	local v2 = p3 == "Drum"
	local v3 = v[p] and v[p][p2]

	if not v3 then
		warn(string.format(
			"[LaneModeConverter] Tidak ada mapping eksplisit utk %d->%d lane, pakai fallback proporsional.",
			p,
			p2
		))
	end

	local result = table.create(#list)

	for i, item in ipairs(list) do
		if v2 and item.ReactionType == nil then
			error(string.format(
				"[LaneModeConverter] Drum note tanpa ReactionType (Lane=%s, Time=%s). ReactionType wajib ada di setiap note Drum dari chart - tidak ada fallback/inference dari ChartLane.",
				tostring(item.Lane),
				(tostring(item.Time))
			))
		end

		local lane = v3 and v3[item.Lane] or fallbackLane(item.Lane, p, p2) -- inferred equivalent call
		local representedNotes

		if item.RepresentedNotes then
			representedNotes = table.create(#item.RepresentedNotes)

			for j, representedNote in ipairs(item.RepresentedNotes) do
				representedNotes[j] = representedNote
			end
		else
			representedNotes = {
				{ ChartLane = item.Lane, ReactionType = item.ReactionType }
			}
		end

		result[i] = {
			Lane = lane,
			Time = item.Time,
			Duration = item.Duration,
			RepresentedNotes = representedNotes
		}
	end

	return result
end

function LaneModeConverter.ConvertToTwo(p, p2, p3)
	return LaneModeConverter.ConvertToN(p, p2, 2, p3)
end

function LaneModeConverter.DedupeOverlaps(list, p, value)
	local v2 = {}

	for i = 1, value or 2 do
		v2[i] = {}
	end

	for _, item in ipairs(list) do
		if not v2[item.Lane] then
			v2[item.Lane] = {}
		end

		table.insert(v2[item.Lane], item)
	end

	local result = {}

	for _, list2 in pairs(v2) do
		table.sort(list2, function(a, b): boolean
			return a.Time < b.Time
		end)
		local v3 = nil

		for _, item in ipairs(list2) do
			if v3 and not (p <= item.Time - v3.Time) then
				if v3.RepresentedNotes and item.RepresentedNotes then
					for _, representedNote in ipairs(item.RepresentedNotes) do
						table.insert(v3.RepresentedNotes, representedNote)
					end
				end
			else
				table.insert(result, item)
				v3 = item
			end
		end
	end

	table.sort(result, function(a, b): boolean
		return a.Time < b.Time
	end)
	return result
end

return LaneModeConverter