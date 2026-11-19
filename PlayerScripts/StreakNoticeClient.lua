game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FloatingStreakNotice = require(ReplicatedStorage.Modules.FloatingStreakNotice)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)

ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BroadcastStreakNotice").OnClientEvent:Connect(function(player, p, value)
	if typeof(player) ~= "Instance" or not player:IsA("Player") or p ~= "Streak" or typeof(value) ~= "number" then
		return
	end

	if SettingsState.GetHideAllJudgmentText() or player:GetAttribute("HideOwnJudgmentText") then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	FloatingStreakNotice.Spawn(character, p, value, SettingsState.GetHitSparkleEnabled())
end)