local v = {
	{ label = "Open", value = "Open" },
	{ label = "Resolved", value = "Resolved" },
	{ label = "Dismissed", value = "Dismissed" },
	{ label = "All", value = "All" }
}

local v2 = {
	{ label = "10 min", value = 10 },
	{ label = "1 hour", value = 60 },
	{ label = "24 hours", value = 1440 },
	{ label = "Until unmuted", value = 0 }
}

local v3 = {
	{ label = "1 day", value = 1 },
	{ label = "7 days", value = 7 },
	{ label = "30 days", value = 30 },
	{ label = "Permanent", value = 0 }
}

local function trim(text) -- 3 equivalent calls inferred from this helper
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors
		local v4 = {}

		local v5 = { Open = colors.Warn, Resolved = colors.Ok, Dismissed = colors.Muted }

		local v6 = {}
		local v7 = "Open"
		local v8 = ""
		local id = nil
		local total = 0
		local v9 = false
		local v10 = ""
		local count = 0
		local flag = false
		local textsById = {}
		local v11 = 60
		local v12 = 7

		local frame = kit.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48) }, p)
		local pageHeader = kit.pageHeader(frame, "Reports", "Player reports from all servers", 1)
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

		kit.chipGroup(frame2, v, "Open", function(p2)
			v7 = p2
			v10 = ""
			v4.Render()
		end)

		local textbox = kit.textbox(p, "Search player, reporter, reason, or note...", {
			maxLength = 40
		})
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

		local function visible(data2): boolean
			if v7 ~= "All" and data2.Status ~= v7 then
				return false
			end

			if v8 == "" then
				return true
			end

			return (tostring(data2.TargetName) .. " " .. tostring(data2.TargetDisplay) .. " " .. tostring(data2.ReporterName) .. " " .. tostring(data2.Category) .. " " .. tostring(data2.Note)):lower():find(
				v8,
				1,
				true
			) ~= nil
		end

		local function buildDetails(card, data2)
			kit.divider(card, 2)

			local frame3 = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					Size = UDim2.new(1, 0, 0, 0)
				},
				card
			)

			kit.list(frame3, 4)

			local count2 = 0
			local function nextOrder() -- 20 equivalent calls inferred from this helper
				count2 += 1
				return count2
			end

			kit.keyValue(frame3, "Category", tostring(data2.Category), nextOrder()) -- inferred equivalent call
			kit.keyValue(
				frame3,
				"Reported",
				kit.dateTime(data2.Time) .. "  (" .. kit.timeAgo(data2.Time) .. ")",
				nextOrder() -- inferred equivalent call
			)

			kit.keyValue(
				frame3,
				"Player",
				tostring(data2.TargetDisplay) .. "  (@" .. tostring(data2.TargetName) .. ")  ID " .. tostring(data2.TargetId),
				nextOrder() -- inferred equivalent call
			)

			if data2.AccountAge then
				kit.keyValue(frame3, "Account age", tostring(data2.AccountAge) .. " days", nextOrder()) -- inferred equivalent call
			end

			if typeof(data2.Instrument) == "string" and data2.Instrument ~= "" then
				kit.keyValue(frame3, "Instrument", data2.Instrument, nextOrder()) -- inferred equivalent call
			end

			kit.keyValue(frame3, "Server", tostring(data2.Server or "?"), nextOrder()) -- inferred equivalent call

			if data2.ResolvedBy then
				kit.keyValue(
					frame3,
					"Handled by",
					"@" .. tostring(data2.ResolvedBy) .. "  (" .. kit.timeAgo(data2.ResolvedAt) .. ")",
					nextOrder(), -- inferred equivalent call
					v5[data2.Status]
				)
			end

			if typeof(data2.Note) == "string" and data2.Note ~= "" then
				kit.sectionTitle(frame3, "NOTE FROM REPORTER", nextOrder()) -- inferred equivalent call
				kit.label(frame3, data2.Note, {
					autoY = true,
					order = nextOrder(), -- inferred equivalent call
					regular = true,
					textSize = 12,
					wrap = true
				})
			end

			if typeof(data2.Bio) == "string" and data2.Bio ~= "" then
				kit.sectionTitle(frame3, "BIO AT REPORT TIME", nextOrder()) -- inferred equivalent call
				kit.label(frame3, data2.Bio, {
					autoY = true,
					color = colors.Muted,
					order = nextOrder(), -- inferred equivalent call
					regular = true,
					textSize = 12,
					wrap = true
				})
			end

			local can = data.Can("Warn")
			local can2 = data.Can("Mute")
			local can3 = data.Can("Kick")
			local can4 = data.Can("Ban")

			if can or can2 or can3 or can4 then
				kit.sectionTitle(frame3, "QUICK ACTIONS", nextOrder()) -- inferred equivalent call

				local v13 = kit.textbox(frame3, "Reason (at least 3 letters)", {
					maxLength = 120,
					order = nextOrder(), -- inferred equivalent call
					text = textsById[data2.Id] or "Reported: " .. tostring(data2.Category)
				})

				v13:GetPropertyChangedSignal("Text"):Connect(function()
					textsById[data2.Id] = v13.Text
				end)

				if can2 then
					kit.label(frame3, "Mute duration", {
						color = colors.Muted,
						height = 16,
						order = nextOrder(), -- inferred equivalent call
						regular = true,
						textSize = 11
					})

					local chipGroup = kit.chipGroup
					local function fn(p2)
						v11 = p2
					end

					chipGroup(frame3, v2, v11, fn, { order = nextOrder() }) -- inferred equivalent call
				end

				if can4 then
					kit.label(frame3, "Ban duration", {
						color = colors.Muted,
						height = 16,
						order = nextOrder(), -- inferred equivalent call
						regular = true,
						textSize = 11
					})

					local chipGroup = kit.chipGroup
					local function fn(p2)
						v12 = p2
					end

					chipGroup(frame3, v3, v12, fn, { order = nextOrder() }) -- inferred equivalent call
				end

				local function reasonOrNil() -- 4 equivalent calls inferred from this helper
					local v14 = trim(v13.Text) -- inferred equivalent call

					if #v14 < 3 then
						data.Toast("Enter a reason first (at least 3 letters)", "error")
						return nil
					end

					return v14
				end

				local v14, v15 = kit.grid(frame3, 4, 34, 8, nextOrder()) -- inferred equivalent call

				if data.Compact() then
					v15(2)
				end

				local count3 = 0
				local function actionButton(p2, danger) -- 4 equivalent calls inferred from this helper
					count3 += 1
					return kit.button(v14, p2, {
						color = danger,
						height = 34,
						order = count3,
						textSize = 12
					})
				end

				if can then
					actionButton("Warn").Activated:Connect(function() -- inferred equivalent call
						local v16 = reasonOrNil() -- inferred equivalent call

						if v16 then
							data.Act("Warn", data2.TargetId, v16)
						end
					end)
				end

				if can2 then
					actionButton("Mute").Activated:Connect(function() -- inferred equivalent call
						local v16 = reasonOrNil() -- inferred equivalent call

						if v16 then
							data.Act("Mute", data2.TargetId, v16, v11)
						end
					end)
				end

				if can3 then
					local v16 = actionButton("Kick", colors.Danger) -- inferred equivalent call
					kit.armConfirm(v16, "Kick", "Confirm kick?", function()
						data.Act("Kick", data2.TargetId, trim(v13.Text)) -- inferred equivalent call
					end, function(): boolean
						return reasonOrNil() ~= nil -- inferred equivalent call
					end)
				end

				if can4 then
					local v16 = actionButton("Ban", colors.Danger) -- inferred equivalent call
					kit.armConfirm(v16, "Ban", "Confirm ban?", function()
						data.Act("Ban", data2.TargetId, trim(v13.Text), v12) -- inferred equivalent call
					end, function(): boolean
						return reasonOrNil() ~= nil -- inferred equivalent call
					end)
				end
			end

			if data.Can("ManageReports") then
				kit.sectionTitle(frame3, "REPORT STATUS", nextOrder()) -- inferred equivalent call

				local frame4 = kit.new(
					"Frame",
					{
						BackgroundTransparency = 1,
						LayoutOrder = nextOrder(), -- inferred equivalent call
						Size = UDim2.new(1, 0, 0, 34)
					},
					frame3
				)

				kit.list(frame4, 8, { FillDirection = Enum.FillDirection.Horizontal })

				if data2.Status == "Open" then
					kit.button(frame4, "Mark Resolved", {
						color = colors.Ok,
						order = 1,
						sizeUDim = UDim2.new(0.5, -4, 1, 0),
						textSize = 12,
						onClick = function()
							data.ReportAct("Resolve", data2.Id, data2.Day)
						end
					})

					kit.button(frame4, "Dismiss", {
						order = 2,
						sizeUDim = UDim2.new(0.5, -4, 1, 0),
						textSize = 12,
						onClick = function()
							data.ReportAct("Dismiss", data2.Id, data2.Day)
						end
					})
				else
					kit.button(frame4, "Reopen", {
						order = 1,
						sizeUDim = UDim2.new(1, 0, 1, 0),
						textSize = 12,
						onClick = function()
							data.ReportAct("Reopen", data2.Id, data2.Day)
						end
					})
				end
			end
		end

		local function buildRow(data2, i)
			local v13 = id == data2.Id

			local card = kit.card(scrollingFrame, {
				color = colors.Surface2,
				gap = 8,
				order = i,
				padding = 12
			})

			local textButton = kit.new("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 38),
				Text = ""
			}, card)

			kit.label(
				textButton,
				"<b>" .. kit.escape(data2.TargetName) .. "</b>  reported by  <b>" .. kit.escape(data2.ReporterName) .. "</b>",
				{
					rich = true,
					sizeUDim = UDim2.new(1, -100, 0, 18),
					textSize = 13,
					truncate = true
				}
			)

			local badge2 = kit.badge(textButton, tostring(data2.Status), v5[data2.Status] or colors.Muted)
			badge2.AnchorPoint = Vector2.new(1, 0)
			badge2.Position = UDim2.new(1, 0, 0, 0)

			local v14 = tostring(data2.Category) .. "  -  " .. kit.timeAgo(data2.Time)

			if typeof(data2.Note) == "string" and data2.Note ~= "" then
				v14 ..= "  -  " .. data2.Note
			end

			local label = kit.label(textButton, v14, {
				color = colors.Muted,
				regular = true,
				sizeUDim = UDim2.new(1, -24, 0, 16),
				textSize = 11,
				truncate = true
			})

			label.Position = UDim2.fromOffset(0, 21)

			local chevron = kit.chevron(textButton, colors.Muted)
			chevron.AnchorPoint = Vector2.new(1, 0)
			chevron.Position = UDim2.new(1, 0, 0, 23)
			chevron.Rotation = v13 and 180 or 0

			textButton.Activated:Connect(function()
				id = not v13 and data2.Id or nil
				v10 = ""
				v4.Render()
			end)

			if v13 then
				buildDetails(card, data2)
			end
		end

		function v4.Render()
			local v13 = { v7, v8, tostring(id), (tostring(v9)) }
			local v14 = {}

			for _, v15 in ipairs(v6) do
				if not visible(v15) then
					continue
				end

				table.insert(v14, v15)
				table.insert(v13, tostring(v15.Id) .. ":" .. tostring(v15.Status))
			end

			local joined = table.concat(v13, "|")

			if joined == v10 then
				return
			end

			v10 = joined

			kit.clear(scrollingFrame)

			if #v14 == 0 then
				kit.emptyState(scrollingFrame, v7 == "Open" and "No open reports" or "No matching reports", 1)
			else
				for i, v15 in ipairs(v14) do
					buildRow(v15, i)
				end
			end

			if v9 then
				kit.button(scrollingFrame, "Load older reports", {
					height = 34,
					order = 100000,
					textSize = 12,
					onClick = function()
						total += 7
						v4.Refresh()
					end
				})
			end
		end

		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			v8 = textbox.Text:lower()
			v4.Render()
		end)

		function v4.Refresh()
			count += 1
			local v13 = count
			task.spawn(function()
				local v14 = data.ReportQuery("List", { Extra = total })

				if typeof(v14) == "table" and v14.Throttled then
					task.wait(0.7)

					if v13 ~= count then
						return
					end

					v14 = data.ReportQuery("List", { Extra = total })
				end

				if v13 ~= count or typeof(v14) ~= "table" or v14.Throttled or not v14.Reports then
					return
				end

				v6 = v14.Reports
				v9 = v14.HasMore == true
				badge.Text = v14.Persistent and "Stored permanently" or "Server memory only"
				badge.TextColor3 = v14.Persistent and colors.Ok or colors.Warn
				badge.BackgroundColor3 = v14.Persistent and colors.Ok or colors.Warn

				if data.SetOpenReports and typeof(v14.OpenCount) == "number" then
					data.SetOpenReports(v14.OpenCount)
				end

				v4.Render()
			end)
		end

		function v4.OnLive()
			if flag then
				v4.Refresh()
			end
		end

		function v4.OnShow()
			flag = true
			v4.Refresh()
		end

		function v4.OnHide()
			flag = false
		end

		return v4
	end
}