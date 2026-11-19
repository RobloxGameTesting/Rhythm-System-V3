local v = {
	{ label = "30 sec", value = 30 },
	{ label = "1 min", value = 60 },
	{ label = "2 min", value = 120 },
	{ label = "5 min", value = 300 },
	{ label = "10 min", value = 600 },
	{ label = "Custom", value = "custom" }
}

local function trim(text) -- 4 equivalent calls inferred from this helper
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors
		local v2 = {}

		local count = 0
		local v3 = nil
		local v4 = {}
		local v5 = ""
		local v6 = nil
		local v7 = ""

		kit.pageHeader(p, "Polls", "Ask players a question and watch the answers come in", 1)

		local function percentText(p2, total) -- 2 equivalent calls inferred from this helper
			if total > 0 then
				return string.format("%d  (%d%%)", p2, (math.floor(p2 / total * 100 + 0.5)))
			end

			return "0"
		end

		local function resultRow(frame, i, option)
			local frame2 = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = i,
					Size = UDim2.new(1, 0, 0, 0)
				},
				frame
			)

			kit.list(frame2, 4)
			local frame3 = kit.new(
				"Frame",
				{ BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 18) },
				frame2
			)
			local label_2 = kit.label(frame3, option, { textSize = 12, truncate = true })
			label_2.Size = UDim2.new(1, -120, 1, 0)
			local label = kit.label(frame3, "0", {
				align = Enum.TextXAlignment.Right,
				color = colors.Muted,
				regular = true,
				textSize = 11
			})
			label.AnchorPoint = Vector2.new(1, 0)
			label.Position = UDim2.fromScale(1, 0)
			label.Size = UDim2.new(0, 110, 1, 0)
			local _, fill = kit.progress(frame2, 0, colors.Purple, 2)
			return { Count = label, Fill = fill }
		end

		local function voterLine(p2, i, voter, options)
			local v8 = options[voter.Option] or "?"
			kit.label(
				p2,
				"<b>" .. kit.escape(voter.DisplayName) .. "</b>  <font color=\"#" .. colors.Muted:ToHex() .. "\">@" .. kit.escape(voter.Name) .. "</font>   " .. "<font color=\"#" .. colors.Purple:ToHex() .. "\">" .. kit.escape(v8) .. "</font>",
				{
					height = 18,
					order = i,
					regular = true,
					rich = true,
					textSize = 12,
					truncate = true
				}
			)
		end

		local frame = kit.new(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0)
			},
			p
		)

		kit.list(frame, 0)

		local v8 = nil

		local function buildActive(data2)
			kit.clear(frame)
			v7 = ""
			local card = kit.card(frame, { order = 1 })

			local frame2 = kit.new(
				"Frame",
				{ BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 20) },
				card
			)
			kit.label(frame2, "ACTIVE POLL", {
				bold = true,
				color = colors.Purple,
				height = 20,
				textSize = 10
			})
			local badge = kit.badge(frame2, data2.Scope == "Global" and "ALL SERVERS" or "THIS SERVER", colors.Muted)
			badge.AnchorPoint = Vector2.new(1, 0.5)
			badge.Position = UDim2.new(1, 0, 0.5, 0)

			kit.label(card, data2.Question, {
				autoY = true,
				bold = true,
				order = 2,
				textSize = 16,
				wrap = true
			})
			local label = kit.label(card, "", {
				color = colors.Muted,
				height = 16,
				order = 3,
				regular = true,
				textSize = 12
			})
			local _, timeFill = kit.progress(card, 1, colors.Purple, 4)

			local frame3 = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 5,
					Size = UDim2.new(1, 0, 0, 0)
				},
				card
			)

			kit.list(frame3, 10)
			local rows = {}

			for i, option in ipairs(data2.Options) do
				rows[i] = resultRow(frame3, i, option)
			end

			local label2 = kit.label(card, "VOTES", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 6,
				textSize = 10
			})
			local scrollingFrame = kit.new("ScrollingFrame", {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = colors.Surface2,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(),
				LayoutOrder = 7,
				ScrollBarImageColor3 = colors.Border,
				ScrollBarThickness = 3,
				Size = UDim2.new(1, 0, 0, 150)
			}, card)

			kit.corner(scrollingFrame, 8)
			kit.padding(scrollingFrame, 8, 10, 8, 10)
			kit.list(scrollingFrame, 3)

			local button = kit.button(card, "End Poll Now", {
				color = colors.Danger,
				height = 36,
				order = 8
			})
			kit.armConfirm(button, "End Poll Now", "Confirm end?", function()
				data.Act("EndPoll")
			end)

			v6 = {
				Id = data2.Id,
				TimeLabel = label,
				TimeFill = timeFill,
				Rows = rows,
				VotersTitle = label2,
				VotersBody = scrollingFrame,
				EndButton = button
			}
		end

		local function updateActive()
			if v3 then
				v8.Visible = false

				if not v6 or v6.Id ~= v3.Id then
					buildActive(v3)
				end

				local v9 = v6

				for i, row in ipairs(v9.Rows) do
					local v10 = v3.Counts[i] or 0
					row.Count.Text = percentText(v10, v3.Total) -- inferred equivalent call
					kit.tween(row.Fill, {
						Size = UDim2.fromScale(v3.Total > 0 and v10 / v3.Total or 0, 1)
					}, 0.25)
				end

				v9.VotersTitle.Text = "VOTES (" .. v3.Total .. ")"
				local endButton = v9.EndButton
				local visible = not v3.Ended

				if visible then
					visible = not data.IsTester or v3.Scope == "Server"
				end

				endButton.Visible = visible

				local voter = v3.Voters[1]
				local v10 = #v3.Voters .. ":" .. (voter and voter.UserId .. "-" .. voter.Time or "")

				if v10 ~= v7 then
					v7 = v10
					kit.clear(v9.VotersBody)

					if #v3.Voters == 0 then
						kit.label(v9.VotersBody, "No votes yet", {
							color = colors.Muted,
							height = 18,
							order = 1,
							regular = true,
							textSize = 12
						})
					end

					for i, voter2 in ipairs(v3.Voters) do
						voterLine(v9.VotersBody, i, voter2, v3.Options)
					end
				end
			else
				kit.clear(frame)
				v6 = nil
				v8.Visible = true
			end
		end

		local function tickActive()
			local v9 = v6

			if not (v9 and v3) then
				return
			end

			if v3.Ended then
				v9.TimeLabel.Text = "Poll ended"
				v9.TimeFill.Size = UDim2.fromScale(0, 1)
			else
				local v10 = math.max(0, v3.EndsAt - kit.now())
				local v11 = math.max(1, v3.EndsAt - v3.StartedAt)
				v9.TimeLabel.Text = "Ends in " .. kit.duration(v10)
				v9.TimeFill.Size = UDim2.fromScale(math.clamp(v10 / v11, 0, 1), 1)
			end
		end
		task.spawn(function()
			while true do
				task.wait(0.5)
				tickActive()
			end
		end)

		v8 = kit.card(p, { order = 3 })
		local label = kit.label
		local v9 = v8
		label(v9, "NEW POLL", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 1,
			textSize = 10
		})

		local renderPreview
		local v10 = nil

		local textbox = kit.textbox(v8, "Question  (e.g. Which song should we play next?)", {
			height = 70,
			maxLength = 200,
			multiline = true,
			order = 2
		})

		local label2 = kit.label
		local v11 = v8
		label2(v11, "ANSWER OPTIONS  (" .. 2 .. "-" .. 6 .. ")", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 3,
			textSize = 10
		})
		local frame2 = kit.new(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 0)
			},
			v8
		)

		kit.list(frame2, 6)

		local v12 = {}
		local v13 = nil

		local function refreshOptionRows()
			for i, v14 in ipairs(v12) do
				v14.Frame.LayoutOrder = i
				v14.Box.PlaceholderText = "Option " .. i
				v14.Remove.Visible = #v12 > 2
			end

			if v13 then
				v13.Visible = #v12 < 6
			end
		end

		local function addOptionRow()
			local frame3 = kit.new("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = #v12 + 1,
				Size = UDim2.new(1, 0, 0, 34)
			}, frame2)
			local textbox2 = kit.textbox(frame3, "", { maxLength = 40 })
			textbox2.Size = UDim2.new(1, -42, 1, 0)
			local button = kit.button(frame3, "", {
				base = colors.Surface2,
				radius = 8,
				sizeUDim = UDim2.fromOffset(34, 34)
			})
			button.AnchorPoint = Vector2.new(1, 0)
			button.Position = UDim2.fromScale(1, 0)
			local cross = kit.cross(button, colors.Muted)
			cross.AnchorPoint = Vector2.new(0.5, 0.5)
			cross.Position = UDim2.fromScale(0.5, 0.5)
			cross.Size = UDim2.fromOffset(12, 12)

			local v14 = { Frame = frame3, Box = textbox2, Remove = button }
			table.insert(v12, v14)
			textbox2:GetPropertyChangedSignal("Text"):Connect(function()
				renderPreview()
			end)
			button.Activated:Connect(function()
				if #v12 <= 2 then
					return
				end

				local index = table.find(v12, v14)

				if index then
					table.remove(v12, index)
				end

				frame3:Destroy()
				refreshOptionRows()
				renderPreview()
			end)
			refreshOptionRows()

			if renderPreview then
				renderPreview()
			end
		end

		v13 = kit.button(v8, "+ Add option", { height = 32, order = 5, textSize = 12 })
		v13.Activated:Connect(addOptionRow)

		local label3 = kit.label
		local v14 = v8
		label3(v14, "DURATION", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 6,
			textSize = 10
		})
		local chipGroup = kit.chipGroup(v8, v, 60, function(p2)
			v10.Visible = p2 == "custom"
			renderPreview()
		end, { order = 7 })
		local textbox2 = kit.textbox
		local v15 = v8
		v10 = textbox2(v15, "Seconds  (" .. 10 .. "-" .. 3600 .. ")", { maxLength = 4, order = 8 })
		v10.Visible = false
		v10:GetPropertyChangedSignal("Text"):Connect(function()
			renderPreview()
		end)

		local label4 = kit.label
		local v16 = v8
		label4(v16, "SEND TO", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 9,
			textSize = 10
		})
		local v17 = data.IsTester and {
			{ label = "This server only", value = "Server" }
		} or {
			{ label = "All servers", value = "Global" },
			{ label = "This server only", value = "Server" }
		}

		local chipGroup2 = kit.chipGroup
		local v18 = v8
		local v19 = chipGroup2(v18, v17, data.IsTester and "Server" or "Global", function()
			renderPreview()
		end, { order = 10 })

		local label5 = kit.label
		local v20 = v8
		label5(v20, "PREVIEW  (as players will see it)", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 11,
			textSize = 10
		})
		local card = kit.card
		local v21 = v8
		local v22 = card(v21, { color = colors.Surface2, order = 12, gap = 8 })
		kit.label(v22, "POLL", {
			bold = true,
			color = colors.Purple,
			height = 14,
			order = 1,
			textSize = 10
		})
		local label6 = kit.label(v22, "", {
			autoY = true,
			bold = true,
			order = 2,
			textSize = 15,
			wrap = true
		})
		local frame3 = kit.new(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 0)
			},
			v22
		)

		kit.list(frame3, 6)
		local label7 = kit.label(v22, "", {
			color = colors.Muted,
			height = 16,
			order = 4,
			regular = true,
			textSize = 11
		})
		local label8 = kit.label
		local v23 = v8
		local v24 = label8(v23, "", {
			autoY = true,
			color = colors.Muted,
			order = 13,
			regular = true,
			textSize = 11,
			wrap = true
		})

		local function collectOptions()
			local options = {}

			for _, v25 in ipairs(v12) do
				local v26 = trim(v25.Box.Text) -- inferred equivalent call

				if #v26 > 0 then
					table.insert(options, v26)
				end
			end

			return options
		end

		local function getSeconds() -- 3 equivalent calls inferred from this helper
			local v25 = chipGroup.Get()

			if v25 == "custom" then
				return (tonumber(v10.Text))
			end

			return v25
		end

		renderPreview = function()
			local v25 = trim(textbox.Text) -- inferred equivalent call
			label6.Text = (v25 == "" or not v25) and "Your question appears here" or v25
			label6.TextColor3 = v25 ~= "" and colors.Text or colors.Muted

			kit.clear(frame3)
			local v26 = collectOptions()

			if #v26 == 0 then
				kit.label(frame3, "Your answer options appear here", {
					color = colors.Muted,
					height = 18,
					order = 1,
					regular = true,
					textSize = 12
				})
			end

			for i, text in ipairs(v26) do
				local textLabel = kit.new("TextLabel", {
					BackgroundColor3 = colors.Surface3,
					BorderSizePixel = 0,
					Font = kit.FontMedium,
					LayoutOrder = i,
					Size = UDim2.new(1, 0, 0, 34),
					Text = text,
					TextColor3 = colors.Text,
					TextSize = 13
				}, frame3)

				kit.corner(textLabel, 8)
			end

			local seconds = getSeconds() -- inferred equivalent call
			label7.Text = "Choose one answer  -  " .. (seconds and kit.duration(seconds) or "?") .. " left"
			v24.Text = v19.Get() == "Global"
				and "Shown to players on ALL servers. Results from every server are combined."
				or "Shown only to players on this server."
		end

		local button = kit.button
		local v25 = v8
		local v26 = button(v25, "Review & Start", {
			base = colors.AccentDim,
			color = colors.Accent,
			bold = true,
			height = 38,
			order = 14
		})
		local frame4 = kit.new("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 15,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = false
		}, v8)

		kit.list(frame4, 8)
		local label9 = kit.label(frame4, "", {
			autoY = true,
			bold = true,
			color = colors.Accent,
			order = 1,
			textSize = 12,
			wrap = true
		})
		local grid = kit.grid(frame4, 2, 38, 8, 2)
		local button2 = kit.button(grid, "Confirm & Start", {
			base = colors.Accent,
			bold = true,
			color = Color3.fromRGB(22, 22, 27),
			height = 38,
			order = 1
		})
		local button3 = kit.button(grid, "Edit", { height = 38, order = 2 })

		v26.Activated:Connect(function()
			if #trim(textbox.Text) < 3 then -- inferred equivalent call
				data.Toast("Write the question first (at least 3 letters)", "error")
				return
			end

			if #collectOptions() < 2 then
				data.Toast("Fill in at least " .. 2 .. " answer options", "error")
				return
			end

			local seconds = getSeconds() -- inferred equivalent call

			if not seconds or seconds < 10 or seconds > 3600 then
				data.Toast("Duration must be " .. 10 .. "-" .. 3600 .. " seconds", "error")
				return
			end

			label9.Text = "Start this poll now for " .. kit.duration(seconds) .. "?  (" .. (v19.Get() == "Global" and "all servers" or "this server only") .. ")"
			v26.Visible = false
			frame4.Visible = true
		end)
		button3.Activated:Connect(function()
			frame4.Visible = false
			v26.Visible = true
		end)
		button2.Activated:Connect(function()
			local act = data.Act
			local v27 = trim(textbox.Text) -- inferred equivalent call
			act("StartPoll", v27, collectOptions(), getSeconds(), v19.Get()) -- inferred equivalent call
			frame4.Visible = false
			v26.Visible = true
			task.delay(1.2, function()
				v2.Refresh()
			end)
		end)

		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			renderPreview()
		end)

		addOptionRow()
		addOptionRow()
		renderPreview()

		kit.sectionTitle(p, "HISTORY", 4)
		local frame5 = kit.new(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 5,
				Size = UDim2.new(1, 0, 0, 0)
			},
			p
		)

		kit.list(frame5, 12)

		local function renderHistory()
			kit.clear(frame5)

			if #v4 == 0 then
				kit.emptyState(frame5, "No polls yet. Finished polls and their votes are saved here.", 1)
				return
			end

			for i, v27 in ipairs(v4) do
				local card2 = kit.card(frame5, { order = i })
				kit.label(card2, v27.Question, {
					autoY = true,
					bold = true,
					order = 1,
					textSize = 14,
					wrap = true
				})
				kit.label(
					card2,
					kit.dateTime(v27.StartedAt) .. "  -  " .. (v27.Scope == "Global" and "all servers" or "one server") .. "  -  by @" .. tostring(v27.ByName) .. "  -  " .. v27.Total .. (v27.Total == 1 and " vote" or " votes"),
					{
						color = colors.Muted,
						height = 16,
						order = 2,
						regular = true,
						textSize = 11
					}
				)

				local frame6 = kit.new(
					"Frame",
					{
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						LayoutOrder = 3,
						Size = UDim2.new(1, 0, 0, 0)
					},
					card2
				)

				kit.list(frame6, 10)

				for j, option in ipairs(v27.Options) do
					local v28 = resultRow(frame6, j, option)
					local v29 = v27.Counts[j] or 0
					v28.Count.Text = percentText(v29, v27.Total) -- inferred equivalent call
					v28.Fill.Size = UDim2.fromScale(v27.Total > 0 and v29 / v27.Total or 0, 1)
				end

				if not (#v27.Voters > 0) then
					continue
				end

				local frame7 = kit.new("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = colors.Surface2,
					BorderSizePixel = 0,
					LayoutOrder = 5,
					Size = UDim2.new(1, 0, 0, 0),
					Visible = false
				}, card2)

				kit.corner(frame7, 8)
				kit.padding(frame7, 8, 10, 8, 10)
				kit.list(frame7, 3)

				for j, voter in ipairs(v27.Voters) do
					if j > 100 then
						kit.label(frame7, "+ " .. #v27.Voters - 100 .. " more", {
							color = colors.Muted,
							height = 16,
							order = j,
							regular = true,
							textSize = 11
						})
						break
					end

					voterLine(frame7, j, voter, v27.Options)
				end

				local button4 = kit.button(card2, "Show voters (" .. #v27.Voters .. ")", {
					height = 30,
					order = 4,
					textSize = 11
				})
				button4.Activated:Connect(function()
					frame7.Visible = not frame7.Visible
					button4.Text = frame7.Visible and "Hide voters" or "Show voters (" .. #v27.Voters .. ")"
				end)
			end
		end

		local function historySig(history)
			local ids = {}

			for _, item in ipairs(history) do
				table.insert(ids, item.Id)
			end

			return table.concat(ids, ",")
		end

		function v2.OnLive(p2)
			v3 = p2.Poll
			updateActive()
			tickActive()

			if v3 == nil then
				v2.Refresh()
			end
		end

		function v2.Refresh()
			count += 1
			local v27 = count
			task.spawn(function()
				local query = data.Query("Polls")

				if v27 ~= count or typeof(query) ~= "table" or query.Throttled or not query.History then
					return
				end

				v3 = query.Active
				updateActive()
				tickActive()
				local v28 = historySig(query.History)

				if v28 ~= v5 then
					v4 = query.History
					v5 = v28
					renderHistory()
				end
			end)
		end

		function v2.OnShow()
			v2.Refresh()
		end

		renderHistory()
		return v2
	end
}