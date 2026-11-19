local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local StreakTierColors = require(ReplicatedStorage.Modules.StreakTierColors)

local function colorForStreak(value) -- 1 equivalent call inferred from this helper
	return StreakTierColors.GetHex(value) or "#FFFFFF"
end

local v = { [1000] = "LEGENDARY", [2000] = "MYTHICAL", [5000] = "GODLIKE" }

local function escapeRichText(value) -- 5 equivalent calls inferred from this helper
	return (tostring(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local v2 = { [3] = "HAT-TRICK", [5] = "UNSTOPPABLE", [10] = "FLAWLESS LEGEND" }

local v3 = { [3] = "ON A ROLL", [5] = "UNTOUCHABLE", [10] = "FLAWLESS LEGEND" }

local function colorForChain(value): string -- 2 equivalent calls inferred from this helper
	if value >= 10 then
		return "#FF5E5E"
	end

	if value >= 5 then
		return "#FF9F43"
	end

	if value >= 4 then
		return "#FFD966"
	end

	return if value >= 3 then "#7CFFB2" else "#8FD3FF"
end

ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BroadcastStreakChat").OnClientEvent:Connect(function(value, value2, value3, p)
	if typeof(value) ~= "string" or typeof(value2) ~= "number" then
		return
	end

	if p == "FullComboSongs" then
		local v4 = v3[value2]
		local v5 = v4 and " <b>" .. v4 .. "</b>" or ""
		local v6 = string.format(
			"<font color=\"%s\">🔥 <b>%s</b> full combo'd <b>%d songs</b> in a row — no Miss, no Wrong!%s</font>",
			colorForChain(value2), -- inferred equivalent call
			escapeRichText(value), -- inferred equivalent call
			value2,
			v5
		)

		local textChannels = TextChatService:FindFirstChild("TextChannels")
		local rbxSystem = textChannels and textChannels:FindFirstChild("RBXSystem")

		if rbxSystem then
			pcall(function()
				rbxSystem:DisplaySystemMessage(v6)
			end)
		end
	elseif p == "FullComboChain" then
		local v4 = typeof(value3) == "string" and value3 ~= "" and "<b>" .. escapeRichText(value3) .. "</b>" -- inferred equivalent call
			or "the same song"
		local v5 = v2[value2]
		local v6 = v5 and " <b>" .. v5 .. "</b>" or ""
		local v7 = string.format(
			"<font color=\"%s\">✨ <b>%s</b> full combo'd %s <b>%dx</b> in a row — no Miss, no Wrong!%s</font>",
			colorForChain(value2), -- inferred equivalent call
			escapeRichText(value), -- inferred equivalent call
			v4,
			value2,
			v6
		)

		local textChannels = TextChatService:FindFirstChild("TextChannels")
		local rbxSystem = textChannels and textChannels:FindFirstChild("RBXSystem")

		if rbxSystem then
			pcall(function()
				rbxSystem:DisplaySystemMessage(v7)
			end)
		end
	else
		local v4 = (typeof(value3) ~= "string" or value3 == "") and "" or " on <b>" .. escapeRichText(value3) .. "</b>" -- inferred equivalent call

		local v5 = v[value2]
		local v6 = v5 and " <b>" .. v5 .. "</b>" or ""

		local v7 = string.format(
			"<font color=\"%s\">🔥 <b>%s</b> reached a <b>%d</b> note streak%s!%s</font>",
			colorForStreak(value2), -- inferred equivalent call
			escapeRichText(value), -- inferred equivalent call
			value2,
			v4,
			v6
		)

		local textChannels = TextChatService:FindFirstChild("TextChannels")
		local rbxSystem = textChannels and textChannels:FindFirstChild("RBXSystem")

		if not rbxSystem then
			return
		end

		pcall(function()
			rbxSystem:DisplaySystemMessage(v7)
		end)
	end
end)