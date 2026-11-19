local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChartData = ReplicatedStorage.Modules:WaitForChild("ChartData")
local ChartNoteCleaner = require(ReplicatedStorage.Modules.ChartNoteCleaner)

local ChartLoader = {}

local v = {}

local v2 = {}

local v3 = { PianoMIDI = true }

local function loadChart(childName)
	local v4 = v[childName]

	if v4 then
		return v4
	end

	local child = ChartData:FindFirstChild(childName)

	if not child then
		warn("[ChartLoader] Chart tidak ditemukan untuk lagu:", childName)
		return nil
	end

	local success, result = pcall(require, child)

	if success then
		v[childName] = result
		return result
	end

	warn("[ChartLoader] Gagal require chart:", childName, result)
	return nil
end

function ChartLoader.GetChart(p, p2)
	local v4 = loadChart(p)

	if not v4 then
		return {}
	end

	local v5 = v4[p2]

	if not v5 then
		return {}
	end

	if v3[p2] then
		return v5
	end

	v2[p] = v2[p] or {}
	local v6 = v2[p][p2]

	if v6 then
		return v6
	end

	local v7 = ChartNoteCleaner.Clean(v5, p2)
	v2[p][p2] = v7
	return v7
end

function ChartLoader.Warm(value, p)
	if type(value) ~= "string" then
		return false
	end

	local success, result = pcall(function()
		if p then
			ChartLoader.GetChart(value, p)
		else
			loadChart(value)
		end
	end)

	if not success then
		warn("[ChartLoader] Warm gagal:", value, p, result)
	end

	return success
end

return ChartLoader