local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ModeratorBroadcast = RemoteEvents:WaitForChild("ModeratorBroadcast")
local ModeratorPollVote = RemoteEvents:WaitForChild("ModeratorPollVote")
local moderatorUI = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ModeratorUI")
local UIKit = require(moderatorUI:WaitForChild("UIKit"))
local NoticeStyle = require(moderatorUI:WaitForChild("NoticeStyle"))
local Kinds = NoticeStyle.Kinds

local moderatorBroadcastUI = Instance.new("ScreenGui")
moderatorBroadcastUI.Name = "ModeratorBroadcastUI"
moderatorBroadcastUI.DisplayOrder = 150
moderatorBroadcastUI.IgnoreGuiInset = true
moderatorBroadcastUI.ResetOnSpawn = false
moderatorBroadcastUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
moderatorBroadcastUI.Parent = PlayerGui

local stack = Instance.new("Frame")
stack.Name = "Stack"
stack.AutomaticSize = Enum.AutomaticSize.XY
stack.BackgroundTransparency = 1
stack.Size = UDim2.fromOffset(0, 0)
stack.Parent = moderatorBroadcastUI

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 0)
uiListLayout.Parent = stack

local function placeStack()
	if NoticeStyle.IsPlaying() then
		stack.AnchorPoint = Vector2.new(0, 0)
		stack.Position = UDim2.new(0, 6, 0.26, 0)
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	else
		local success, result = pcall(function()
			return GuiService:GetGuiInset()
		end)

		stack.AnchorPoint = Vector2.new(0.5, 0)
		stack.Position = UDim2.new(0.5, 0, 0, (success and result.Y or 58) + 6)
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end
end
placeStack()
NoticeStyle.OnPlayingChanged(placeStack)
GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(placeStack)

local count = 0

local function createBanner(kind, value, body, p)
	count += 1
	local v = Kinds[kind] or Kinds.Global
	local v2

	if value == "" then
		v2 = false
	else
		v2 = string.lower(value) ~= string.lower(v.Tag)
	end

	local createCard = NoticeStyle.createCard
	local v3 = {
		kind = kind,
		tag = v.Tag,
		title = v2 and value or nil,
		body = 0,
		richText = 0,
		order = 0
	}

	if body == "" or not body then
		body = nil
	end

	v3.body = body
	v3.richText = p == true
	v3.order = count
	local card = createCard(stack, v3)

	return { Time = card.Time, Close = card.Dismiss, Start = card.StartTimer }
end

local color = Color3.fromRGB(110, 200, 255)
local color2 = Color3.fromRGB(255, 150, 50)
local color3 = Color3.fromRGB(240, 70, 60)
local color4 = Color3.fromRGB(158, 156, 150)
local color5 = Color3.fromRGB(245, 205, 100)

local function escapeRich(p)
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;"))
end

local function colored(color6, p) -- 5 equivalent calls inferred from this helper
	return "<font color=\"#" .. color6:ToHex() .. "\">" .. escapeRich(p) .. "</font>"
end

local function buildRemovalText(kind, data)
	local v = data.Role == "Developer" and "Developer" or "Moderator"
	local v2 = colored(color, data.Target) .. " was " -- inferred equivalent call
	local removalText

	if kind == "Ban" then
		local v3 = v2 .. colored(color3, "banned") .. " by a " .. v -- inferred equivalent call

		if typeof(data.Days) == "number" and data.Days > 0 then
			removalText = v3 .. " for " .. data.Days .. (data.Days == 1 and " day." or " days.")
		else
			removalText = v3 .. " permanently."
		end
	else
		removalText = v2 .. colored(color2, "kicked") .. " by a " .. v .. "." -- inferred equivalent call
	end

	if typeof(data.Reason) == "string" and data.Reason ~= "" then
		removalText ..= " " .. colored(color4, "Reason:") .. " " .. colored(color5, data.Reason) -- inferred equivalent call
	end

	return removalText
end

local v = nil

local function closePoll(duration) -- 3 equivalent calls inferred from this helper
	local v2 = v

	if not v2 then
		return
	end

	v = nil

	if duration and duration > 0 then
		task.delay(duration, v2.Entry.Dismiss)
	else
		v2.Entry.Dismiss()
	end
end

local function showPoll(data)
	if v and v.Id == data.Id then
		return
	end

	if
		typeof(data.Id) ~= "string"
		or typeof(data.Question) ~= "string"
		or typeof(data.Options) ~= "table"
		or typeof(data.EndsAt) ~= "number"
		or #data.Options < 2
	then
		return
	end

	local total = data.EndsAt - workspace:GetServerTimeNow()

	if total <= 0.5 then
		return
	end

	closePoll() -- inferred equivalent call
	local card = NoticeStyle.createCard(stack, {
		kind = "Poll",
		tag = Kinds.Poll.Tag,
		title = data.Question,
		order = 0,
		minWidth = 320
	})

	local v2 = {
		Id = data.Id,
		Entry = card,
		EndsAt = data.EndsAt,
		Total = total,
		Buttons = {},
		Options = data.Options,
		Voted = false
	}

	for i, option in ipairs(data.Options) do
		local button = NoticeStyle.MakeButton(card.Content, tostring(option), 10 + i)
		v2.Buttons[i] = button
		button.Activated:Connect(function()
			if v2.Voted or v ~= v2 then
				return
			end

			v2.Voted = true

			for j, button2 in ipairs(v2.Buttons) do
				button2.Active = false

				if j == i then
					NoticeStyle.SetButtonState(button2, "selected")
				else
					NoticeStyle.SetButtonState(button2, "dim")
				end
			end

			v2.Footer.Text = "Sending your vote..."
			ModeratorPollVote:FireServer(v2.Id, i)
		end)
	end

	v2.Footer = NoticeStyle.MakeFooter(card.Content, 30)
	local _, fill = NoticeStyle.MakeProgress(card.Content, Kinds.Poll.Accent, 31)
	v2.Fill = fill

	card.OnCompact(function(p)
		for _, button in ipairs(v2.Buttons) do
			NoticeStyle.SizeButton(button, p)
		end
	end)
	v = v2
end

local v2 = nil
local endsAt = nil

task.spawn(function()
	while true do
		task.wait(0.25)
		local serverTimeNow = workspace:GetServerTimeNow()

		if v2 and endsAt then
			local v3 = math.max(0, (math.floor(endsAt - serverTimeNow)))
			v2.Time.Visible = true
			v2.Time.Text = "In " .. UIKit.duration(v3)

			if v3 <= 0 then
				v2.Close()
				v2 = nil
				endsAt = nil
			end
		end

		local v3 = v

		if not v3 then
			continue
		end

		local v4 = v3.EndsAt - serverTimeNow

		if v4 <= 0 then
			closePoll() -- inferred equivalent call
		else
			v3.Fill.Size = UDim2.fromScale(math.clamp(v4 / v3.Total, 0, 1), 1)

			if not v3.Voted then
				v3.Footer.Text = "Choose one answer  -  " .. UIKit.duration((math.ceil(v4))) .. " left"
			end
		end
	end
end)

ModeratorBroadcast.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" or typeof(data.Kind) ~= "string" then
		return
	end

	local kind = data.Kind
	local title = typeof(data.Title) == "string" and data.Title or ""
	local text = typeof(data.Text) == "string" and data.Text or ""

	if kind == "Poll" then
		showPoll(data)
	elseif kind == "PollVoted" then
		local v3 = v

		if v3 and v3.Id == data.Id then
			v3.Voted = true
			local option = v3.Options[data.Option]

			for i, button in ipairs(v3.Buttons) do
				button.Active = false

				if i == data.Option then
					NoticeStyle.SetButtonState(button, "selected")
				else
					NoticeStyle.SetButtonState(button, "dim")
				end
			end

			v3.Footer.Text = "Thanks! You voted: " .. tostring(option or "?")
			local v4 = v

			if not v4 then
				return
			end

			v = nil

			task.delay(2.2, v4.Entry.Dismiss)
		end
	elseif kind == "PollEnd" then
		if v and v.Id == data.Id then
			closePoll() -- inferred equivalent call
		end
	elseif kind == "Countdown" and typeof(data.EndsAt) == "number" then
		if v2 then
			v2.Close()
		end

		v2 = createBanner("Countdown", title, text)
		endsAt = data.EndsAt
	elseif (kind == "Kick" or kind == "Ban") and typeof(data.Target) == "string" then
		createBanner(kind, "", buildRemovalText(kind, data), true).Start(NoticeStyle.IsPlaying() and 7 or 10)
	elseif Kinds[kind] and Kinds[kind].Tag and kind ~= "Countdown" and kind ~= "Poll" then
		local banner = createBanner(kind, title, text)
		local v3 = kind == "Warn" and 10 or 8
		local v4 = NoticeStyle.IsPlaying() and (kind == "Warn" and 7 or 5) or v3

		banner.Start(v4)
	end
end)