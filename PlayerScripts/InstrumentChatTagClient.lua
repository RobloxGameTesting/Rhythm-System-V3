local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstrumentTitleConfig = require(ReplicatedStorage.Modules.InstrumentTitleConfig)

local function formatTag(p)
	return string.format("<font color=\"#%s\">[%s]</font>", p.Color, p.Title)
end

TextChatService.OnIncomingMessage = function(data)
	local textChatMessageProperties = Instance.new("TextChatMessageProperties")

	if typeof(data.Text) == "string" and data.Text ~= "" then
		textChatMessageProperties.Text = string.format(
			"<font face=\"%s\" size=\"%d\">%s</font>",
			"FredokaOne",
			16,
			data.Text
		)
	end

	local textSource = data.TextSource

	if not textSource then
		return textChatMessageProperties
	end

	local playerByUserId = Players:GetPlayerByUserId(textSource.UserId)

	if not playerByUserId then
		return textChatMessageProperties
	end

	local v = {}

	local equippedInstrumentType = playerByUserId:GetAttribute("EquippedInstrumentType")
	local v2 = equippedInstrumentType and InstrumentTitleConfig.GetRole(equippedInstrumentType)

	if v2 then
		table.insert(v, formatTag(v2))
	end

	if playerByUserId:GetAttribute("IsVocalist") == true then
		table.insert(v, formatTag(InstrumentTitleConfig.VocalistRole))
	end

	if #v > 0 then
		textChatMessageProperties.PrefixText = table.concat(v, " ") .. " " .. data.PrefixText
	end

	return textChatMessageProperties
end