local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Theme = require(ReplicatedStorage.Modules.SongListUI.Theme)

local v = { "GuitarRhythm", "GuitarLead", "Bass", "Drum", "Keyboard", "Piano" }
local v2 = {
	GuitarRhythm = "Rhythm Guitar",
	GuitarLead = "Lead Guitar",
	Bass = "Bass",
	Drum = "Drum",
	Keyboard = "Keyboard",
	Piano = "Piano"
}

local v3 = nil
local ChartAvailabilityClient = {
	["Get"] = nil,
	Get = function(value)
		if v3 then
			return v3
		end

		local chartAvailability = ReplicatedStorage:WaitForChild("ChartAvailability", value or 15)

		if not chartAvailability then
			return {}
		end

		local success, result = pcall(HttpService.JSONDecode, HttpService, chartAvailability.Value)

		if success and type(result) == "table" then
			v3 = result
			return result
		end

		warn("[ChartAvailabilityClient] JSON manifest tidak valid")
		return {}
	end
}

local Danger = Theme.Colors.Danger
local color = Color3.fromRGB(255, 60, 60)
local Success = Theme.Colors.Success

local function orderedNames(options)
	local result = {}

	for _, v4 in ipairs(v) do
		for _, v5 in ipairs(options or {}) do
			if v5 == v4 then
				table.insert(result, v2[v4])
				break
			end
		end
	end

	return result
end

function ChartAvailabilityClient.BuildNotice(p)
	if p == true then
		return {
			segments = {
				{
					text = "⚠ Sorry, chartdata is not yet available;( please check back later.",
					color = Danger
				}
			}
		}
	end

	if type(p) ~= "table" then
		return nil
	end

	local v4 = orderedNames(p.missing)

	if #v4 == 0 then
		return nil
	end

	local segments = {
		{ text = "⚠ Sorry, chartdata for the ", color = Danger },
		{ text = table.concat(v4, ", "), color = color },
		{ text = " is not yet available;( please check back later.", color = Danger }
	}

	local v5 = orderedNames(p.ready)

	if #v5 > 0 then
		table.insert(segments, {
			text = "  instrument ready: " .. table.concat(v5, ", "),
			color = Success
		})
	end

	return { segments = segments }
end

return ChartAvailabilityClient