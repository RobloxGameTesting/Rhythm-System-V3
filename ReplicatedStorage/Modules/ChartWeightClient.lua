local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ChartWeightClient = {}

local v = {}
local v2 = nil

local function load()
	if v2 then
		return v2
	end

	local chartWeights = ReplicatedStorage:FindFirstChild("ChartWeights")

	if not (chartWeights and chartWeights:IsA("StringValue")) then
		return v
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, chartWeights.Value)

	if success and type(result) == "table" then
		v2 = result
		return result
	end

	warn("[ChartWeightClient] JSON bobot porsi tidak valid")
	return v
end

function ChartWeightClient.GetSong(p)
	local selected = p and load()[p]
	return if type(selected) == "table" then selected else v
end

function ChartWeightClient.GetPercent(p, p2)
	local v3 = ChartWeightClient.GetSong(p)[p2]
	return if type(v3) == "number" then v3 else nil
end

return ChartWeightClient