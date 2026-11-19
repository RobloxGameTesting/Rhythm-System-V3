local v = {
	Warn = "warned",
	Kick = "kicked",
	Ban = "banned",
	Unban = "unbanned",
	Mute = "muted",
	Unmute = "unmuted",
	Freeze = "froze",
	Unfreeze = "unfroze",
	Bring = "brought",
	Goto = "teleported to",
	ResetChar = "reset the character of",
	ToSpawn = "sent to spawn:",
	SetSize = "changed the size of",
	ReleaseInstrument = "released the instrument of",
	StartPoll = "started a poll",
	EndPoll = "ended a poll early",
	StopStudio = "stopped a studio session",
	ResetStudio = "reset a studio",
	MaintenanceOn = "turned maintenance on",
	MaintenanceOff = "turned maintenance off",
	Restart = "restarted the servers",
	RestartCancel = "cancelled the restart",
	AutoPlayToggle = "toggled autoplay",
	AutoClickerDetected = "flagged an auto clicker:",
	VoteKick = "vote kick:",
	["Broadcast:Global"] = "sent an announcement to all servers",
	["Broadcast:Server"] = "sent a server message"
}

local v2 = {
	Warn = "Moderation",
	Kick = "Moderation",
	Ban = "Moderation",
	Unban = "Moderation",
	Mute = "Moderation",
	Unmute = "Moderation",
	Freeze = "Moderation",
	Unfreeze = "Moderation",
	Bring = "Moderation",
	Goto = "Moderation",
	ResetChar = "Moderation",
	ToSpawn = "Moderation",
	SetSize = "Moderation",
	AutoClickerDetected = "Moderation",
	VoteKick = "Moderation",
	ReleaseInstrument = "Studio",
	StopStudio = "Studio",
	ResetStudio = "Studio",
	StartPoll = "Broadcast",
	EndPoll = "Broadcast"
}

local v3 = {
	{ label = "All", value = "All" },
	{ label = "Moderation", value = "Moderation" },
	{ label = "Studio", value = "Studio" },
	{ label = "Server", value = "Server" },
	{ label = "Announcements", value = "Broadcast" }
}

local function categoryOf(action) -- 2 equivalent calls inferred from this helper
	if string.sub(action, 1, 10) == "Broadcast:" then
		return "Broadcast"
	end

	return v2[action] or "Server"
end

return {
	new = function(p, p2)
		local kit = p2.Kit
		local colors = kit.Colors
		local v4 = {}

		local v5 = {
			Moderation = colors.Accent,
			Studio = colors.Purple,
			Server = colors.Info,
			Broadcast = colors.Ok
		}

		local v6 = {}
		local v7 = "All"
		local v8 = ""
		local v9 = ""
		local v10 = true
		local count = 0

		local frame = kit.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48) }, p)
		local pageHeader = kit.pageHeader(frame, "Mod Logs", "Who did what, when, to whom, and why", 1)
		pageHeader.Size = UDim2.new(0.7, 0, 0, 0)
		local badge = kit.badge(frame, "Loading...", colors.Muted)
		badge.AnchorPoint = Vector2.new(1, 0)
		badge.Position = UDim2.new(1, 0, 0, 6)

		local frame2 = kit.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 54),
				Size = UDim2.new(1, 0, 0, 30)
			},
			p
		)

		kit.chipGroup(frame2, v3, "All", function(p3)
			v7 = p3
			v9 = ""
			v4.Render()
		end)

		local textbox = kit.textbox(p, "Search moderator, target, or reason...", { maxLength = 40 })
		textbox.Position = UDim2.fromOffset(0, 92)

		local scrollingFrame = kit.new("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = colors.Surface,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			Position = UDim2.fromOffset(0, 134),
			ScrollBarImageColor3 = colors.Border,
			ScrollBarThickness = 3,
			Size = UDim2.new(1, 0, 1, -134)
		}, p)

		kit.corner(scrollingFrame, 12)
		kit.stroke(scrollingFrame, colors.Border, 0.35, 1)
		kit.padding(scrollingFrame, 10, 14, 10, 14)
		kit.list(scrollingFrame, 10)

		local function visible(data): boolean
			if v7 ~= "All" and categoryOf(data.Action) ~= v7 then -- inferred equivalent call
				return false
			end

			if v8 == "" then
				return true
			end

			return (tostring(data.ModName) .. " " .. tostring(data.TargetName) .. " " .. tostring(data.Reason) .. " " .. tostring(data.Detail)):lower():find(
				v8,
				1,
				true
			) ~= nil
		end

		function v4.Render()
			local ids = { v7, v8 }
			local v11 = {}

			for _, v12 in ipairs(v6) do
				if not visible(v12) then
					continue
				end

				table.insert(v11, v12)
				table.insert(ids, v12.Id)
			end

			local joined = table.concat(ids, "|")

			if joined == v9 then
				return
			end

			v9 = joined

			kit.clear(scrollingFrame)

			if #v11 == 0 then
				kit.emptyState(scrollingFrame, "No matching entries", 1)
				return
			end

			for i, v12 in ipairs(v11) do
				local v13 = v5[categoryOf(v12.Action)] or colors.Muted -- inferred equivalent call
				local frame3 = kit.new("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = i * 2,
					Size = UDim2.new(1, 0, 0, 0)
				}, scrollingFrame)

				kit.list(frame3, 3)

				local v14 = v[v12.Action] or v12.Action
				local v15 = "<b>" .. kit.escape(v12.ModName) .. "</b>  " .. kit.escape(v14)

				if v12.TargetName then
					v15 ..= "  <b>" .. kit.escape(v12.TargetName) .. "</b>"
				end

				local label = kit.label(frame3, v15, {
					height = 18,
					order = 1,
					rich = true,
					textSize = 13,
					truncate = true
				})
				label.Text = "<font color=\"#" .. v13:ToHex() .. "\">|</font>  " .. v15

				local v16 = kit.dateTime(v12.Time) .. "  (" .. kit.timeAgo(v12.Time) .. ")"

				if v12.Reason then
					v16 ..= "  -  Reason: " .. tostring(v12.Reason)
				end

				if v12.Detail then
					v16 ..= "  -  " .. tostring(v12.Detail)
				end

				kit.label(frame3, v16, {
					autoY = true,
					color = colors.Muted,
					order = 2,
					regular = true,
					textSize = 11,
					wrap = true
				})
				kit.divider(scrollingFrame, i * 2 + 1)
			end
		end

		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			v8 = textbox.Text:lower()
			v4.Render()
		end)

		function v4.Refresh()
			count += 1
			local v11 = count
			task.spawn(function()
				local query = p2.Query("Logs")

				if v11 ~= count or typeof(query) ~= "table" or query.Throttled or not query.Logs then
					return
				end

				v6 = query.Logs
				v10 = query.Persistent
				badge.Text = v10 and "Stored permanently" or "Server memory only"
				badge.TextColor3 = v10 and colors.Ok or colors.Warn
				badge.BackgroundColor3 = v10 and colors.Ok or colors.Warn
				v4.Render()
			end)
		end

		function v4.OnShow()
			v4.Refresh()
		end

		return v4
	end
}