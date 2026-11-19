local v = {
	{ label = "10 min", value = 10 },
	{ label = "1 hour", value = 60 },
	{ label = "24 hours", value = 1440 },
	{ label = "Until unmuted", value = 0 }
}

local v2 = {
	{ label = "1 day", value = 1 },
	{ label = "7 days", value = 7 },
	{ label = "30 days", value = 30 },
	{ label = "Permanent", value = 0 }
}

local v3 = {
	{ label = "Spam", value = "Spam" },
	{ label = "Toxic / harassment", value = "Toxic / harassment" },
	{ label = "Cheating / exploit", value = "Cheating / exploit" },
	{ label = "Griefing", value = "Griefing" },
	{ label = "Disrupting song session", value = "Disrupting song session" }
}

local v4 = { 50, 100, 200, 300 }

local v5 = {
	Desktop = "Desktop (PC / Mac)",
	Mobile = "Mobile (phone / tablet)",
	Console = "Console",
	VR = "VR"
}

local function trim(text) -- 5 equivalent calls inferred from this helper
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors
		local v6 = {}

		local v7 = "Online"
		local v8 = {}
		local v9 = ""
		local v10 = ""
		local v11 = nil
		local visible = false
		local v12 = nil
		local count = 0
		local count2 = 0
		local count3 = 0

		local frame = kit.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48) }, p)
		local pageHeader = kit.pageHeader(frame, "Player Management", "Search, inspect, and act on players", 1)
		pageHeader.Size = UDim2.new(0.62, 0, 0, 0)

		local frame2 = kit.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 58),
				Size = UDim2.new(1, 0, 1, -58)
			},
			p
		)

		local frame3 = kit.new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, frame2)
		local scrollingFrame = kit.new("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ScrollBarImageColor3 = colors.Border,
			ScrollBarThickness = 3,
			Size = UDim2.fromScale(1, 1),
			Visible = false
		}, frame2)

		kit.list(scrollingFrame, 12)
		kit.padding(scrollingFrame, 0, 6, 0, 0)

		local frame4 = kit.new("Frame", { BackgroundTransparency = 1 }, frame3)
		local textbox = kit.textbox(frame4, "Search by name or User ID...", { maxLength = 40 })
		local scrollingFrame2 = kit.new("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = colors.Surface,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			Position = UDim2.fromOffset(0, 42),
			ScrollBarImageColor3 = colors.Border,
			ScrollBarThickness = 3,
			Size = UDim2.new(1, 0, 1, -42)
		}, frame4)

		kit.corner(scrollingFrame2, 12)
		kit.stroke(scrollingFrame2, colors.Border, 0.35, 1)
		kit.padding(scrollingFrame2, 6, 8, 6, 6)
		kit.list(scrollingFrame2, 4)

		local scrollingFrame3 = kit.new("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ScrollBarImageColor3 = colors.Border,
			ScrollBarThickness = 3
		}, frame3)

		kit.list(scrollingFrame3, 12)
		kit.padding(scrollingFrame3, 0, 6, 0, 0)

		local function applyLayout()
			local compact = data.Compact()

			if compact then
				frame4.Position = UDim2.fromOffset(0, 0)
				frame4.Size = UDim2.fromScale(1, 1)
				scrollingFrame3.Position = UDim2.fromOffset(0, 0)
				scrollingFrame3.Size = UDim2.fromScale(1, 1)
				frame4.Visible = not visible
				scrollingFrame3.Visible = visible
			else
				frame4.Position = UDim2.fromOffset(0, 0)
				frame4.Size = UDim2.new(0, 264, 1, 0)
				scrollingFrame3.Position = UDim2.fromOffset(276, 0)
				scrollingFrame3.Size = UDim2.new(1, -276, 1, 0)
				frame4.Visible = true
				scrollingFrame3.Visible = true
			end

			if v12 and v12.BackButton then
				v12.BackButton.Visible = compact
			end
		end
		data.LayoutChanged.Event:Connect(applyLayout)

		local function matches(player): boolean
			if v10 == "" then
				return true
			end

			return player.Name:lower():find(v10, 1, true) ~= nil
				or player.DisplayName:lower():find(v10, 1, true) ~= nil
				or tostring(player.UserId):find(v10, 1, true) ~= nil
		end

		local function signature()
			local v13 = { v10, (tostring(v11)) }

			for _, v14 in ipairs(v8) do
				table.insert(v13, v14.UserId .. ":" .. tostring(v14.Muted) .. ":" .. v14.Tier)
			end

			return table.concat(v13, "|")
		end

		local selectPlayer

		local function rebuildList()
			kit.clear(scrollingFrame2)
			local count4 = 0

			for i, v13 in ipairs(v8) do
				if not matches(v13) then
					continue
				end

				count4 += 1
				local v14 = v13.UserId == v11
				local button = kit.button(scrollingFrame2, "", {
					base = v14 and colors.AccentDim or colors.Surface,
					height = 46,
					order = i,
					radius = 8,
					stroke = false
				})

				local avatar = kit.avatar(button, v13.UserId, 32)
				avatar.Position = UDim2.fromOffset(8, 7)
				local label = kit.label(
					button,
					v13.DisplayName .. (v13.UserId == data.Player.UserId and " (you)" or ""),
					{ bold = true, textSize = 12, truncate = true }
				)

				label.Position = UDim2.fromOffset(48, 6)
				label.Size = UDim2.new(1, -112, 0, 16)
				local label2 = kit.label(button, "@" .. v13.Name, {
					color = colors.Muted,
					regular = true,
					textSize = 10,
					truncate = true
				})
				label2.Position = UDim2.fromOffset(48, 24)
				label2.Size = UDim2.new(1, -112, 0, 14)

				local v15 = nil
				local v16 = nil

				if v13.Muted then
					v16 = colors.Danger
					v15 = "MUTED"
				elseif v13.Tier >= 2 then
					v16 = colors.Accent
					v15 = "DEV"
				elseif v13.Tier == 1 then
					v16 = colors.Info
					v15 = "MOD"
				elseif v13.IsTester then
					v16 = colors.Muted
					v15 = "TESTER"
				end

				if v15 then
					local badge = kit.badge(button, v15, v16)
					badge.AnchorPoint = Vector2.new(1, 0.5)
					badge.Position = UDim2.new(1, -8, 0.5, 0)
				end

				button.Activated:Connect(function()
					selectPlayer(v13.UserId)
				end)
			end

			if count4 == 0 then
				kit.emptyState(scrollingFrame2, "No players match", 1)
			end
		end

		local function refreshList() -- 3 equivalent calls inferred from this helper
			count += 1
			local v13 = count
			task.spawn(function()
				local query = data.Query("Players")

				if v13 ~= count or typeof(query) ~= "table" or query.Throttled or not query.Players then
					return
				end

				v8 = query.Players
				local v14 = signature()

				if v14 ~= v9 then
					v9 = v14
					rebuildList()
				end
			end)
		end

		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			v10 = textbox.Text:lower()
			v9 = ""
			refreshList() -- inferred equivalent call
			v9 = signature()
			rebuildList()
		end)

		local function showEmptyDetail() -- 3 equivalent calls inferred from this helper
			kit.clear(scrollingFrame3)
			v12 = nil
			kit.emptyState(
				scrollingFrame3,
				"Select a player from the list to see their profile and moderation actions",
				1
			)
		end

		local function buildDetail(userId)
			kit.clear(scrollingFrame3)
			local v13 = { UserId = userId, Muted = false, Locked = false, Punitive = {} }
			v12 = v13
			local count4 = 0
			local function nextOrder() -- 4 equivalent calls inferred from this helper
				count4 += 1
				return count4
			end

			v13.BackButton = kit.button(scrollingFrame3, "< Back to list", {
				height = 30,
				order = nextOrder(), -- inferred equivalent call
				textSize = 11
			})
			v13.BackButton.Visible = data.Compact()
			v13.BackButton.Activated:Connect(function()
				visible = false
				applyLayout()
			end)

			local v14 = kit.card(scrollingFrame3, {
				height = 100,
				noList = true,
				order = nextOrder() -- inferred equivalent call
			})
			kit.avatar(v14, userId, 56)
			v13.Name = kit.label(v14, "...", { bold = true, textSize = 16, truncate = true })
			v13.Name.Position = UDim2.fromOffset(70, 2)
			v13.Name.Size = UDim2.new(1, -70, 0, 20)
			v13.Sub = kit.label(v14, "", {
				color = colors.Muted,
				regular = true,
				textSize = 12,
				truncate = true
			})
			v13.Sub.Position = UDim2.fromOffset(70, 24)
			v13.Sub.Size = UDim2.new(1, -70, 0, 16)
			v13.Tags = kit.new(
				"Frame",
				{
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(70, 46),
					Size = UDim2.new(1, -70, 0, 22)
				},
				v14
			)

			kit.list(v13.Tags, 6, { FillDirection = Enum.FillDirection.Horizontal })

			local v15 = kit.card(scrollingFrame3, { order = nextOrder() }) -- inferred equivalent call
			kit.label(v15, "Player information", {
				bold = true,
				height = 20,
				order = 1,
				textSize = 14
			})
			v13.Values = {}

			for i, v16 in ipairs({
				"Session",
				"Device",
				"Country",
				"Ping",
				"Band",
				"Current activity",
				"Moderation history",
				"Play time",
				"Account age"
			}) do
				local _, v17 = kit.keyValue(v15, v16, "-", i + 1)
				v13.Values[v16] = v17
			end

			local v16 = kit.card(scrollingFrame3, { order = nextOrder() }) -- inferred equivalent call
			local count5 = 0
			local function cardNext() -- 12 equivalent calls inferred from this helper
				count5 += 1
				return count5
			end

			kit.label(v16, "Actions", {
				bold = true,
				height = 20,
				order = cardNext(), -- inferred equivalent call
				textSize = 14
			})

			v13.ReasonBox = kit.textbox(v16, "Reason (required for Warn / Mute / Kick / Ban)", {
				maxLength = 100,
				order = cardNext() -- inferred equivalent call
			})
			local v17 = nil
			local chipGroup = kit.chipGroup
			local function fn(text)
				v13.ReasonBox.Text = text
				v17.Set(nil)
			end

			v17 = chipGroup(v16, v3, nil, fn, { order = cardNext() }) -- inferred equivalent call

			kit.label(v16, "Mute duration", {
				color = colors.Muted,
				height = 16,
				order = cardNext(), -- inferred equivalent call
				regular = true,
				textSize = 11
			})
			local v18 = kit.chipGroup(v16, v, 60, nil, { order = cardNext() }) -- inferred equivalent call
			local v19

			if data.Can("Ban") then
				kit.label(v16, "Ban duration", {
					color = colors.Muted,
					height = 16,
					order = cardNext(), -- inferred equivalent call
					regular = true,
					textSize = 11
				})
				v19 = kit.chipGroup(v16, v2, 7, nil, { order = cardNext() }) -- inferred equivalent call
			else
				v19 = nil
			end

			local function reasonOrNil() -- 4 equivalent calls inferred from this helper
				local v20 = trim(v13.ReasonBox.Text) -- inferred equivalent call

				if #v20 < 3 then
					data.Toast("Enter a reason first (at least 3 letters)", "error")
					return nil
				end

				return v20
			end

			local v20 = kit.grid(v16, 2, 36, 8, cardNext()) -- inferred equivalent call
			local count6 = 0
			local function actionButton(p2, danger) -- 9 equivalent calls inferred from this helper
				count6 += 1
				return kit.button(v20, p2, {
					color = danger,
					height = 36,
					order = count6,
					textSize = 12
				})
			end

			local v21 = actionButton("Warn") -- inferred equivalent call
			v21.Activated:Connect(function()
				local v22 = reasonOrNil() -- inferred equivalent call

				if v22 then
					data.Act("Warn", userId, v22)
				end
			end)

			v13.MuteButton = actionButton("Mute") -- inferred equivalent call
			v13.MuteButton.Activated:Connect(function()
				if v13.Muted then
					data.Act("Unmute", userId)
					return
				end

				local v22 = reasonOrNil() -- inferred equivalent call

				if v22 then
					data.Act("Mute", userId, v22, v18.Get())
				end
			end)

			local v22 = actionButton("Kick", colors.Danger) -- inferred equivalent call
			kit.armConfirm(v22, "Kick", "Confirm kick?", function()
				data.Act("Kick", userId, trim(v13.ReasonBox.Text)) -- inferred equivalent call
			end, function(): boolean
				return reasonOrNil() ~= nil -- inferred equivalent call
			end)
			local v23

			if data.Can("Ban") then
				v23 = actionButton("Ban", colors.Danger) -- inferred equivalent call
				kit.armConfirm(v23, "Ban", "Confirm ban?", function()
					data.Act("Ban", userId, trim(v13.ReasonBox.Text), v19.Get()) -- inferred equivalent call
				end, function(): boolean
					return reasonOrNil() ~= nil -- inferred equivalent call
				end)
			end

			actionButton("Teleport To").Activated:Connect(function() -- inferred equivalent call
				data.Act("Goto", userId)
			end)
			local v24 = actionButton("Bring") -- inferred equivalent call
			v24.Activated:Connect(function()
				data.Act("Bring", userId)
			end)
			local v25 = actionButton("Reset Character") -- inferred equivalent call
			kit.armConfirm(v25, "Reset Character", "Confirm reset?", function()
				data.Act("ResetChar", userId)
			end)
			actionButton("Teleport to Spawn").Activated:Connect(function() -- inferred equivalent call
				data.Act("ToSpawn", userId)
			end)

			v13.FreezeButton = actionButton("Freeze") -- inferred equivalent call
			v13.FreezeButton.Activated:Connect(function()
				data.Act("Freeze", userId)
			end)

			v13.Punitive = { v21, v13.MuteButton, v22, v23, v24, v13.FreezeButton }

			if data.Can("SetSize") then
				kit.label(v16, "Player size (10-500%)", {
					color = colors.Muted,
					height = 16,
					order = cardNext(), -- inferred equivalent call
					regular = true,
					textSize = 11
				})
				local function applySize(value) -- 2 equivalent calls inferred from this helper
					if value then
						data.Act("SetSize", userId, (math.clamp(value, 10, 500)))
					else
						data.Toast("Enter a number from 10 to 500", "error")
					end
				end
				local v26 = {}

				for _, v27 in ipairs(v4) do
					table.insert(v26, {
						label = v27 .. "%",
						value = v27
					})
				end

				local function fn2(value)
					if value then
						data.Act("SetSize", userId, (math.clamp(value, 10, 500)))
					else
						applySize() -- inferred equivalent call
					end
				end

				kit.chipGroup(v16, v26, nil, fn2, { order = cardNext() }) -- inferred equivalent call
				local frame5 = kit.new(
					"Frame",
					{
						BackgroundTransparency = 1,
						LayoutOrder = cardNext(), -- inferred equivalent call
						Size = UDim2.new(1, 0, 0, 34)
					},
					v16
				)
				local textbox2 = kit.textbox(frame5, "Custom value", { maxLength = 5 })
				textbox2.Size = UDim2.new(1, -70, 1, 0)
				local button = kit.button(frame5, "Set", { sizeUDim = UDim2.fromOffset(62, 34) })
				button.AnchorPoint = Vector2.new(1, 0)
				button.Position = UDim2.fromScale(1, 0)
				button.Activated:Connect(function()
					local v27 = tonumber((textbox2.Text:gsub("%%", "")))

					if v27 then
						data.Act("SetSize", userId, (math.clamp(v27, 10, 500)))
					else
						applySize() -- inferred equivalent call
					end
				end)
				kit.label(v16, "Set Size respawns the player in the same spot.", {
					color = colors.Muted,
					height = 14,
					order = cardNext(), -- inferred equivalent call
					regular = true,
					textSize = 10
				})
			end

			if data.IsTester then
				for _, guiObject in ipairs(v16:GetChildren()) do
					if not (guiObject:IsA("GuiObject") and guiObject ~= v20 and (not guiObject:IsA("TextLabel") or guiObject.Text ~= "Actions")) then
						continue
					end

					guiObject.Visible = false
				end

				for _, button in ipairs(v20:GetChildren()) do
					if button:IsA("GuiButton") and button.Text ~= "Teleport To" then
						button.Visible = false
					end
				end
			end

			applyLayout()
		end

		local function applyDetail(player)
			local v13 = v12

			if not v13 or v13.UserId ~= player.UserId then
				return
			end

			v13.Name.Text = player.DisplayName
			v13.Sub.Text = "@" .. player.Name .. "  -  " .. player.UserId

			kit.clear(v13.Tags)
			kit.badge(v13.Tags, "Online", colors.Ok, 1)
			kit.badge(
				v13.Tags,
				player.TierName,
				player.Tier >= 2 and colors.Accent or player.Tier == 1 and colors.Info or colors.Muted,
				2
			)

			if player.Muted then
				kit.badge(v13.Tags, "Muted", colors.Danger, 3)
			end

			if player.Frozen then
				kit.badge(v13.Tags, "Frozen", colors.Info, 4)
			end

			local history = player.History or {}
			v13.Values.Session.Text = "Current server (" .. tostring(player.JobId) .. ")"
			local v14 = v5[player.Device]
			v13.Values.Device.Text = v14 or "Unknown"
			v13.Values.Device.TextColor3 = v14 and colors.Text or colors.Muted
			local v15

			if typeof(player.CountryCode) == "string" then
				v15 = player.CountryName and player.CountryName .. " (" .. player.CountryCode .. ")"
					or player.CountryCode
			end

			v13.Values.Country.Text = v15 or "Unknown"
			v13.Values.Country.TextColor3 = v15 and colors.Text or colors.Muted

			if typeof(player.Ping) == "number" then
				v13.Values.Ping.Text = player.Ping .. " ms"
				v13.Values.Ping.TextColor3 = player.Ping < 100 and colors.Ok
					or player.Ping < 200 and colors.Warn
					or colors.Danger
			else
				v13.Values.Ping.Text = "-"
				v13.Values.Ping.TextColor3 = colors.Muted
			end

			v13.Values.Band.Text = player.Band or "None"

			if player.Instrument then
				v13.Values["Current activity"].Text = player.Instrument .. (player.Studio and " @ " .. player.Studio or "") .. (player.Song and " - " .. player.Song or "")
			else
				v13.Values["Current activity"].Text = "Idle"
			end

			v13.Values["Moderation history"].Text = string.format(
				"Warn %d / Mute %d / Kick %d / Ban %d",
				history.Warn or 0,
				history.Mute or 0,
				history.Kick or 0,
				history.Ban or 0
			)

			v13.Values["Play time"].Text = kit.duration(player.Seconds) .. " on this server"
			v13.Values["Account age"].Text = player.AccountAge .. " days"

			v13.Muted = player.Muted
			v13.MuteButton.Text = player.Muted and "Unmute" or "Mute"
			v13.FreezeButton.Text = player.Frozen and "Unfreeze" or "Freeze"

			local v16 = data.Tier <= player.Tier

			for _, v17 in ipairs(v13.Punitive) do
				v17.Active = not v16
				v17.TextTransparency = v16 and 0.6 or 0
			end
		end

		local function refreshDetail() -- 2 equivalent calls inferred from this helper
			if not v11 then
				return
			end

			count2 += 1
			local v13 = count2
			local v14 = v11
			task.spawn(function()
				local query = data.Query("PlayerDetail", v14)

				if v13 ~= count2 or v14 ~= v11 or typeof(query) ~= "table" or query.Throttled then
					return
				end

				if not query.Gone then
					applyDetail(query)
					return
				end

				data.Toast("The player has left the server", "info")
				v11 = nil
				visible = false
				showEmptyDetail() -- inferred equivalent call
				v9 = ""
				refreshList() -- inferred equivalent call
				applyLayout()
			end)
		end

		selectPlayer = function(userId)
			v11 = userId
			visible = true
			buildDetail(userId)
			v9 = signature()
			rebuildList()
			applyLayout()
			refreshDetail() -- inferred equivalent call
		end

		local frame5

		if data.Can("Ban") then
			local card = kit.card(scrollingFrame, { order = 1 })
			kit.label(card, "Ban by User ID", { bold = true, height = 20, order = 1, textSize = 14 })
			kit.label(card, "Works for offline players too. Bans are stored permanently and apply on all servers.", {
				autoY = true,
				color = colors.Muted,
				order = 2,
				regular = true,
				textSize = 11,
				wrap = true
			})

			local textbox2 = kit.textbox(card, "User ID", { maxLength = 14, order = 3 })
			local textbox3 = kit.textbox(card, "Reason (required)", { maxLength = 100, order = 4 })
			local chipGroup = kit.chipGroup(card, v2, 7, nil, { order = 5 })
			local button = kit.button(card, "Ban", { color = colors.Danger, height = 36, order = 6 })
			kit.armConfirm(button, "Ban", "Confirm ban?", function()
				data.Act("Ban", tonumber(textbox2.Text), trim(textbox3.Text), chipGroup.Get()) -- inferred equivalent call
				textbox2.Text = ""
				textbox3.Text = ""
				task.delay(1.2, function()
					v6.Refresh()
				end)
			end, function(): boolean
				if not tonumber(textbox2.Text) then
					data.Toast("User ID must be a number", "error")
					return false
				end

				if #trim(textbox3.Text) < 3 then -- inferred equivalent call
					data.Toast("Enter a reason first (at least 3 letters)", "error")
					return false
				end

				return true
			end)

			local card2 = kit.card(scrollingFrame, { order = 2 })
			kit.label(card2, "ACTIVE BANS", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 1,
				textSize = 10
			})
			frame5 = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 0)
				},
				card2
			)

			kit.list(frame5, 8)

			local chipGroup2 = kit.chipGroup(frame, {
				{ label = "Online", value = "Online" },
				{ label = "Banned", value = "Banned" }
			}, "Online", function(p2)
				v7 = p2
				frame3.Visible = p2 == "Online"
				scrollingFrame.Visible = p2 == "Banned"
				v6.Refresh()
			end)
			chipGroup2.Instance.AnchorPoint = Vector2.new(1, 0)
			chipGroup2.Instance.Position = UDim2.new(1, 0, 0, 8)
			chipGroup2.Instance.Size = UDim2.new(0.38, 0, 0, 0)
			local uiListLayout = chipGroup2.Instance:FindFirstChildOfClass("UIListLayout")
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		else
			frame5 = nil
		end

		local function refreshBans() -- 1 equivalent call inferred from this helper
			if not frame5 then
				return
			end

			count3 += 1
			local v13 = count3
			task.spawn(function()
				local query = data.Query("Bans")

				if v13 ~= count3 or typeof(query) ~= "table" or query.Throttled or not query.Bans then
					return
				end

				kit.clear(frame5)

				if #query.Bans == 0 then
					kit.emptyState(frame5, "No active bans", 1)
				end

				for i, ban in ipairs(query.Bans) do
					local frame6 = kit.new(
						"Frame",
						{
							BackgroundTransparency = 1,
							LayoutOrder = i,
							Size = UDim2.new(1, 0, 0, 52)
						},
						frame5
					)
					local label_2 = kit.label(frame6, tostring(ban.Name) .. "  -  " .. ban.UserId, {
						bold = true,
						textSize = 12,
						truncate = true
					})
					label_2.Size = UDim2.new(1, -90, 0, 18)
					local v14 = ban.ExpiresAt and "until " .. kit.dateTime(ban.ExpiresAt) or "permanent"
					local label = kit.label(
						frame6,
						tostring(ban.Reason) .. "  -  by " .. tostring(ban.ModName) .. "  -  " .. v14,
						{ color = colors.Muted, regular = true, textSize = 11, truncate = true }
					)

					label.Position = UDim2.fromOffset(0, 20)
					label.Size = UDim2.new(1, -90, 0, 16)
					local button = kit.button(frame6, "Unban", {
						sizeUDim = UDim2.fromOffset(78, 30),
						textSize = 11
					})
					button.AnchorPoint = Vector2.new(1, 0.5)
					button.Position = UDim2.fromScale(1, 0.5)
					kit.armConfirm(button, "Unban", "Confirm?", function()
						data.Act("Unban", ban.UserId)
						task.delay(1.2, function()
							v6.Refresh()
						end)
					end)
					kit.divider(frame5, i + 0.5)
				end
			end)
		end

		function v6.Refresh()
			if v7 == "Online" then
				refreshList() -- inferred equivalent call
				refreshDetail() -- inferred equivalent call
			else
				refreshBans() -- inferred equivalent call
			end
		end

		function v6.OnShow(p2)
			applyLayout()

			if not v12 then
				showEmptyDetail() -- inferred equivalent call
			end

			v6.Refresh()

			if p2 and p2.Focus == "Search" and v7 == "Online" then
				task.defer(function()
					textbox:CaptureFocus()
				end)
			end
		end

		showEmptyDetail() -- inferred equivalent call
		applyLayout()
		return v6
	end
}