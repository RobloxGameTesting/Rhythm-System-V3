game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FloatingJudgmentPool = require(ReplicatedStorage.Modules.FloatingJudgmentPool)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)

ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BroadcastJudgmentText").OnClientEvent:Connect(function(player, value, value2)
	if
		not player
		or typeof(value) ~= "string"
		or SettingsState.GetHideAllJudgmentText()
		or player:GetAttribute("HideOwnJudgmentText")
	then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local attribute = player:GetAttribute("RhythmJudgment_" .. value)

	FloatingJudgmentPool.Spawn(character, value, attribute, typeof(value2) == "string" and value2 or nil)
end)