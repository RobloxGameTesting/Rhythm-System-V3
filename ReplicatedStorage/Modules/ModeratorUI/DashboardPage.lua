local v = {
	{
		Letter = "F",
		ColorKey = "Info",
		Title = "Find Player",
		Sub = "Search and inspect players",
		Page = "Players",
		Params = { Focus = "Search" },
		ForTester = true
	},
	{
		Letter = "A",
		ColorKey = "Accent",
		Title = "Announcement",
		Sub = "Send a global announcement",
		TesterSub = "Send a message to this server",
		Page = "Announce",
		ForTester = true
	},
	{
		Letter = "R",
		ColorKey = "Danger",
		Title = "Reset Studio",
		Sub = "Recover a stuck session",
		Page = "Studio"
	},
	{
		Letter = "I",
		ColorKey = "Ok",
		Title = "Release Instrument",
		Sub = "Free a stuck instrument",
		Page = "Studio"
	},
	{
		Letter = "S",
		ColorKey = "Warn",
		Title = "Server Control",
		Sub = "Maintenance and restart",
		Page = "Server"
	},
	{
		Letter = "M",
		ColorKey = "Purple",
		Title = "Moderation",
		Sub = "Take action on players",
		Page = "Players"
	}
}
return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors

		kit.pageHeader(p, "Dashboard", "Quick overview of the server", 1)

		local grid, v2 = kit.grid(p, 4, 88, 10, 2)

		local function statCard(p2, order)
			local card = kit.card(grid, { height = 88, noList = true, order = order, padding = 12 })
			kit.label(card, p2, { bold = true, color = colors.Muted, height = 14, textSize = 10 })
			local label = kit.label(card, "-", { bold = true, height = 30, textSize = 22 })
			label.Position = UDim2.fromOffset(0, 20)
			local label2 = kit.label(card, "", {
				color = colors.Muted,
				height = 14,
				regular = true,
				textSize = 11,
				truncate = true
			})
			label2.Position = UDim2.fromOffset(0, 54)
			return { Value = label, Sub = label2 }
		end

		local v3 = statCard("PLAYERS ONLINE", 1)
		local v4 = statCard("SERVER UPTIME", 2)
		local v5 = statCard("SERVER HEALTH", 3)
		local v6 = statCard("SERVER STATUS", 4)

		local card = kit.card(p, { height = 96, noList = true, order = 3, padding = 12 })
		kit.label(card, "SERVER LOCATION", {
			bold = true,
			color = colors.Muted,
			height = 14,
			textSize = 10
		})

		local monogram = kit.monogram(card, "..", colors.Muted, 46)
		monogram.Position = UDim2.fromOffset(0, 24)
		local textLabel = monogram:FindFirstChildOfClass("TextLabel")
		textLabel.TextSize = 16

		local label = kit.label(card, "Detecting location...", {
			bold = true,
			height = 20,
			textSize = 16,
			truncate = true
		})
		label.Position = UDim2.fromOffset(58, 22)
		local label2 = kit.label(card, "", {
			color = colors.Muted,
			height = 14,
			regular = true,
			textSize = 11,
			truncate = true
		})
		label2.Position = UDim2.fromOffset(58, 43)
		local label3 = kit.label(card, "", {
			color = colors.Muted,
			height = 14,
			regular = true,
			textSize = 11,
			truncate = true
		})
		label3.Position = UDim2.fromOffset(58, 58)

		local frame = kit.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0, 4),
				Size = UDim2.fromOffset(200, 66)
			},
			card
		)

		kit.list(frame, 0)
		local _, v7 = kit.keyValue(frame, "Ping", "-", 1)
		local _, v8 = kit.keyValue(frame, "Server ID", "-", 2)
		local _, v9 = kit.keyValue(frame, "Version", "-", 3)

		local function setLocationBadge(countryCode, p2) -- 3 equivalent calls inferred from this helper
			monogram.BackgroundColor3 = p2
			textLabel.Text = countryCode
			textLabel.TextColor3 = p2
		end

		local function renderLocation(location)
			if typeof(location) ~= "table" then
				return
			end

			v8.Text = location.ServerId or "-"
			v9.Text = location.PlaceVersion and tostring(location.PlaceVersion) or "-"

			if location.Ping then
				v7.Text = location.Ping .. " ms" .. (location.AvgPing and "  (avg " .. location.AvgPing .. ")" or "")
				v7.TextColor3 = location.Ping < 100 and colors.Ok
					or location.Ping < 200 and colors.Warn
					or colors.Danger
			else
				v7.Text = "-"
				v7.TextColor3 = colors.Text
			end

			if location.Status == "ok" then
				local city = location.City
				local text = location.Country or location.CountryCode or "Unknown"
				text = city and city ~= text and city .. ", " .. text or text
				label.Text = text
				label.TextColor3 = colors.Text
				setLocationBadge(location.CountryCode or "?", colors.Info) -- inferred equivalent call

				local v10 = {}

				if location.Region and location.Region ~= city then
					table.insert(v10, location.Region)
				end

				if location.Timezone then
					table.insert(v10, location.Timezone)
				end

				label2.Text = #v10 > 0 and table.concat(v10, "  -  ") or ""

				if location.IsStudio then
					label3.Text = "Studio test: this is your own computer's location"
					label3.TextColor3 = colors.Warn
				else
					label3.Text = location.Provider or ""
					label3.TextColor3 = colors.Muted
				end
			elseif location.Status == "failed" then
				label.Text = "Location unavailable"
				label.TextColor3 = colors.Warn
				setLocationBadge("?", colors.Warn) -- inferred equivalent call
				label2.Text = location.HttpDisabled and "HTTP requests are disabled for this experience"
					or "Could not detect this server's location"
				label3.Text = "Retrying in the background"
				label3.TextColor3 = colors.Muted
			else
				label.Text = "Detecting location..."
				label.TextColor3 = colors.Muted
				setLocationBadge("..", colors.Muted) -- inferred equivalent call
				label2.Text = ""
				label3.Text = ""
			end
		end

		kit.sectionTitle(p, "QUICK ACTIONS", 4)
		local grid2, v10 = kit.grid(p, 3, 86, 10, 5)
		local count = 0
		local v11 = false
		local v12 = {}

		for i, v13 in ipairs(v) do
			if not (not data.IsTester or v13.ForTester) then
				continue
			end

			local color = colors[v13.ColorKey]
			local button = kit.button(grid2, "", {
				base = colors.Surface,
				height = 86,
				order = i,
				radius = 12
			})
			local monogram_2 = kit.monogram(button, v13.Letter, color, 30)
			monogram_2.Position = UDim2.fromOffset(14, 12)
			local label4 = kit.label(button, v13.Title, {
				bold = true,
				height = 16,
				textSize = 13,
				truncate = true
			})
			label4.Size = UDim2.new(1, -28, 0, 16)
			label4.Position = UDim2.fromOffset(14, 48)
			local label5 = kit.label(button, data.IsTester and v13.TesterSub or v13.Sub, {
				color = colors.Muted,
				height = 14,
				regular = true,
				textSize = 11,
				truncate = true
			})
			label5.Size = UDim2.new(1, -28, 0, 14)
			label5.Position = UDim2.fromOffset(14, 65)
			button.Activated:Connect(function()
				data.Go(v13.Page, v13.Params)
			end)
		end

		local can = data.Can("AutoPlayToggle")
		local can2 = data.Can("AdminTools")

		if can or can2 then
			local player = data.Player
			local card2 = kit.card(p, { order = 6 })
			kit.label(card2, "TOOLS", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 1,
				textSize = 10
			})

			local function toolRow(p2, p3, layoutOrder)
				local frame2 = kit.new(
					"Frame",
					{
						BackgroundTransparency = 1,
						LayoutOrder = layoutOrder,
						Size = UDim2.new(1, 0, 0, 44)
					},
					card2
				)
				local label4 = kit.label(frame2, p2, { bold = true, textSize = 13 })
				label4.Position = UDim2.fromOffset(0, 4)
				label4.Size = UDim2.new(1, -60, 0, 18)
				local label5 = kit.label(frame2, p3, {
					color = colors.Muted,
					regular = true,
					textSize = 11,
					truncate = true
				})
				label5.Position = UDim2.fromOffset(0, 23)
				label5.Size = UDim2.new(1, -60, 0, 16)
				return frame2
			end

			if can2 then
				local v13 = toolRow("Moderator Mode", "Free access in Amp Settings", 2)
				local switch = kit.switch(v13, player:GetAttribute("AmpAdminMode") == true, function(p2)
					data.Remotes.AmpAdminModeSet:FireServer(p2)
				end, { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, 0, 0.5, 0) })
				player:GetAttributeChangedSignal("AmpAdminMode"):Connect(function()
					switch.SetState(player:GetAttribute("AmpAdminMode") == true)
				end)
			end

			if can then
				local v13 = toolRow("Autoplay", "Auto-hit while you are in a song session", 3)
				local switch = kit.switch(v13, player:GetAttribute("AdminAutoPlay") == true, function()
					data.Act("AutoPlayToggle")
				end, { anchor = Vector2.new(1, 0.5), position = UDim2.new(1, 0, 0.5, 0) })
				player:GetAttributeChangedSignal("AdminAutoPlay"):Connect(function()
					switch.SetState(player:GetAttribute("AdminAutoPlay") == true)
				end)
			end
		end

		local v13 = {}

		for _, v14 in ipairs({
			{
				Cmd = "/play",
				Args = "<stage> <song title> [instruments]",
				Perm = "AdminTools",
				Desc = "Start a backing track on a stage, e.g. /play STAGE1 song title. Optional digits at the end pick the instruments: 1 Lead Guitar, 2 Rhythm Guitar, 3 Bass, 4 Drum, 5 Keyboard, 6 Piano. Leave them out to play every instrument."
			},
			{
				Cmd = "/stop",
				Args = "<stage>",
				Perm = "AdminTools",
				Desc = "Stop the backing track that is playing on a stage."
			},
			{
				Cmd = "/autoplay",
				Perm = "AutoPlayToggle",
				Desc = "Turn your autoplay on or off. Same as the Autoplay switch in the MODS menu."
			},
			{
				Cmd = "/setplayersize",
				Args = "<name> <size>",
				Perm = "SetSize",
				Desc = "Resize a player's avatar. 100 is normal, allowed range 10 to 500. The name can be a short start of the username or display name. The size resets when the player leaves the server."
			},
			{
				Cmd = "/restartserver",
				Perm = "Restart",
				Desc = "Restart ALL servers after a 1 minute countdown."
			},
			{
				Cmd = "/restartserverin1 ... /restartserverin10",
				Perm = "Restart",
				Desc = "Restart ALL servers after a countdown of 1 to 10 minutes. Example: /restartserverin5 restarts in 5 minutes."
			},
			{
				Cmd = "/nowrestartserver",
				Perm = "Restart",
				Desc = "Restart ALL servers right away with a 10 second countdown."
			},
			{
				Cmd = "/cancelrestartserver",
				Perm = "RestartCancel",
				Desc = "Cancel a restart countdown that is running."
			},
			{
				Cmd = "/rejoin",
				Desc = "Rejoin the server you are in right now. Useful when something gets stuck. Works for everyone."
			}
		}) do
			if not v14.Perm or data.Can(v14.Perm) then
				table.insert(v13, v14)
			end
		end

		if #v13 > 0 then
			local card2 = kit.card(p, { order = 8 })
			kit.label(card2, "COMMANDS", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 1,
				textSize = 10
			})
			kit.label(card2, "Type these in the game chat.", {
				color = colors.Muted,
				height = 14,
				order = 2,
				regular = true,
				textSize = 11
			})
			local layoutOrder = 3

			for _, v14 in ipairs(v13) do
				kit.divider(card2, layoutOrder)
				layoutOrder += 1
				local frame2 = kit.new(
					"Frame",
					{
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						LayoutOrder = layoutOrder,
						Size = UDim2.new(1, 0, 0, 0)
					},
					card2
				)

				layoutOrder += 1
				kit.list(frame2, 3)
				local v15 = "<b><font color=\"#" .. colors.Accent:ToHex() .. "\">" .. kit.escape(v14.Cmd) .. "</font></b>"

				if v14.Args then
					v15 ..= "  <font color=\"#" .. colors.Muted:ToHex() .. "\">" .. kit.escape(v14.Args) .. "</font>"
				end

				kit.label(frame2, v15, {
					autoY = true,
					order = 1,
					rich = true,
					textSize = 13,
					wrap = true
				})
				kit.label(frame2, v14.Desc, {
					autoY = true,
					color = colors.Muted,
					order = 2,
					regular = true,
					textSize = 11,
					wrap = true
				})
			end
		end

		local frame2 = kit.new(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 7,
				Size = UDim2.new(1, 0, 0, 0)
			},
			p
		)

		local list = kit.list(frame2, 12, { FillDirection = Enum.FillDirection.Horizontal })

		local function column(layoutOrder)
			local frame3 = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = layoutOrder,
					Size = UDim2.new(0.5, -6, 0, 0)
				},
				frame2
			)

			kit.list(frame3, 12)
			return frame3
		end

		local v14 = column(1)
		local v15 = column(2)

		local function listCard(p2, p3, order)
			local card2 = kit.card(p2, { order = order })
			kit.label(card2, p3, {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 1,
				textSize = 10
			})
			local frame3 = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 0)
				},
				card2
			)

			kit.list(frame3, 8)
			return frame3
		end

		local v16 = listCard(v14, "NOW PLAYING", 1)
		local v17 = listCard(v14, "PLAYERS ON INSTRUMENTS", 2)
		local v18 = listCard(v15, "MODERATORS ON SERVER", 1)
		local v19 = listCard(v15, "RECENT MODERATOR ACTIVITY", 2)

		local card2 = kit.card(v14, { order = 3 })
		kit.label(card2, "MODERATOR LIST", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 1,
			textSize = 10
		})
		local grid3, v20 = kit.grid(card2, 2, 30, 6, 2)

		kit.divider(card2, 3)
		kit.label(card2, "TESTER LIST", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 4,
			textSize = 10
		})
		local grid4, v21 = kit.grid(card2, 2, 30, 6, 5)
		local emptyState = kit.emptyState(card2, "No testers yet", 6)

		local function applyLayout()
			local compact = data.Compact()
			v2(compact and 2 or 4)
			v10(compact and 2 or 3)
			v20(compact and 1 or 2)
			v21(compact and 1 or 2)
			frame.Visible = not compact
			local v22 = 58 + (compact and 0 or 210)

			for _, v23 in ipairs({ label, label2, label3 }) do
				v23.Size = UDim2.new(1, -v22, 0, v23.Size.Y.Offset)
			end

			list.FillDirection = compact and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
			local udim = compact and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -6, 0, 0)
			v14.Size = udim
			v15.Size = udim
		end
		data.LayoutChanged.Event:Connect(applyLayout)
		applyLayout()

		local function simpleRow(p2, i, p3, p4, p5, p6)
			local frame3 = kit.new(
				"Frame",
				{ BackgroundTransparency = 1, LayoutOrder = i, Size = UDim2.new(1, 0, 0, 22) },
				p2
			)
			local v22

			if p6 then
				local dot = kit.dot(frame3, p6, 8)
				dot.AnchorPoint = Vector2.new(0, 0.5)
				dot.Position = UDim2.new(0, 0, 0.5, 0)
				v22 = 16
			else
				v22 = 0
			end

			local label4 = kit.label(frame3, p3, { height = 22, textSize = 12, truncate = true })
			label4.Size = UDim2.new(0.62, -v22, 1, 0)
			label4.Position = UDim2.fromOffset(v22, 0)

			if not p4 then
				return frame3
			end

			local label5 = kit.label(frame3, p4, {
				align = Enum.TextXAlignment.Right,
				color = p5 or colors.Muted,
				height = 22,
				regular = true,
				textSize = 11,
				truncate = true
			})

			label5.AnchorPoint = Vector2.new(1, 0)
			label5.Position = UDim2.fromScale(1, 0)
			label5.Size = UDim2.new(0.38, 0, 1, 0)

			return frame3
		end

		local function fillRoster(grid5, list2)
			kit.clear(grid5)

			for i, item in ipairs(list2) do
				local frame3 = kit.new(
					"Frame",
					{ BackgroundColor3 = colors.Surface2, BorderSizePixel = 0, LayoutOrder = i },
					grid5
				)

				kit.corner(frame3, 8)

				local avatar = kit.avatar(frame3, item.UserId, 22)
				avatar.AnchorPoint = Vector2.new(0, 0.5)
				avatar.Position = UDim2.new(0, 6, 0.5, 0)
				avatar.ImageTransparency = item.Online and 0 or 0.55

				local label4 = kit.label(frame3, item.Name, {
					color = item.Online and colors.Text or colors.Muted,
					height = 30,
					textSize = 12,
					truncate = true
				})

				label4.Position = UDim2.fromOffset(34, 0)
				label4.Size = UDim2.new(1, -50, 1, 0)

				local dot = kit.dot(frame3, item.Online and colors.Ok or colors.Muted, 7)
				dot.AnchorPoint = Vector2.new(1, 0.5)
				dot.Position = UDim2.new(1, -8, 0.5, 0)
			end
		end

		local function render(data2)
			v3.Value.Text = data2.Online .. "/" .. data2.Max
			v3.Sub.Text = #data2.Playing .. " playing"
			v4.Value.Text = kit.duration(data2.Uptime)
			v4.Sub.Text = #data2.Moderators .. (#data2.Moderators == 1 and " moderator online" or " moderators online")

			local v22 = math.floor(data2.Fps + 0.5)
			local ok = v22 >= 45 and colors.Ok or v22 >= 30 and colors.Warn or colors.Danger
			v5.Value.Text = v22 .. " FPS"
			v5.Value.TextColor3 = ok
			v5.Sub.Text = "Memory " .. kit.memory(data2.MemoryMb)

			v6.Value.Text = data2.Maintenance and "Maintenance" or "Online"
			v6.Value.TextColor3 = data2.Maintenance and colors.Warn or colors.Ok
			v6.Sub.Text = data2.Persistent and "Permanent storage on" or "Storage: memory only"

			renderLocation(data2.Location)

			kit.clear(v16)

			if #data2.Songs == 0 then
				kit.emptyState(v16, "No song is playing", 1)
			end

			for i, song in ipairs(data2.Songs) do
				local frame3 = kit.new(
					"Frame",
					{
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						LayoutOrder = i,
						Size = UDim2.new(1, 0, 0, 0)
					},
					v16
				)

				kit.list(frame3, 4)
				kit.label(frame3, tostring(song.Song), {
					bold = true,
					height = 18,
					order = 1,
					textSize = 13,
					truncate = true
				})
				kit.label(frame3, song.Studio .. "  -  " .. song.Source, {
					color = colors.Muted,
					height = 14,
					order = 2,
					regular = true,
					textSize = 11
				})
				local v23 = math.max(0, song.Elapsed or 0)
				local v24 = song.Duration and song.Duration > 0 and v23 / song.Duration or 0
				kit.progress(frame3, v24, colors.Accent, 3)
				local v25 = song.Duration and kit.clock(v23) .. " / " .. kit.clock(song.Duration) or kit.clock(v23)
				kit.label(frame3, v25, {
					color = colors.Muted,
					height = 14,
					order = 4,
					regular = true,
					textSize = 11
				})
			end

			kit.clear(v17)

			if #data2.Playing == 0 then
				kit.emptyState(v17, "Nobody is holding an instrument", 1)
			end

			for i, v23 in ipairs(data2.Playing) do
				simpleRow(
					v17,
					i,
					v23.Name,
					v23.Instrument .. (v23.Studio and "  -  " .. v23.Studio or ""),
					colors.Accent,
					nil
				)
			end

			kit.clear(v18)

			for i, moderator in ipairs(data2.Moderators) do
				simpleRow(
					v18,
					i,
					moderator.Name,
					moderator.TierName,
					moderator.Tier >= 2 and colors.Accent or colors.Info,
					colors.Ok
				)
			end

			fillRoster(grid3, data2.Roster or {})
			local testerRoster = data2.TesterRoster or {}
			fillRoster(grid4, testerRoster)
			emptyState.Visible = #testerRoster == 0

			kit.clear(v19)

			if #data2.Recent == 0 then
				kit.emptyState(v19, "No moderator activity yet", 1)
			end

			for i, v23 in ipairs(data2.Recent) do
				simpleRow(
					v19,
					i,
					v23.ModName .. "  " .. v23.Action .. (v23.TargetName and "  >  " .. v23.TargetName or ""),
					kit.timeAgo(v23.Time),
					colors.Muted,
					nil
				)
			end
		end

		function v12.Refresh()
			count += 1
			local v22 = count
			task.spawn(function()
				local query = data.Query("Dashboard")

				if v22 ~= count or typeof(query) ~= "table" or query.Throttled then
					return
				end

				if query.Error then
					if not v11 then
						v11 = true
						data.Toast("Failed to load dashboard: " .. tostring(query.Error), "error")
					end
				else
					v11 = false
					render(query)
				end
			end)
		end

		function v12.OnShow()
			applyLayout()
			v12.Refresh()
		end

		return v12
	end
}