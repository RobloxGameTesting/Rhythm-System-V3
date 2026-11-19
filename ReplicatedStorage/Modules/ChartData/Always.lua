local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	local ChartRemoteClient = require(script.Parent.Parent:WaitForChild("ChartRemoteClient"))
	return ChartRemoteClient.Fetch(script.Name)
end

local ServerStorage = game:GetService("ServerStorage")
return require(ServerStorage:WaitForChild("ChartDataStore"):WaitForChild(script.Name))