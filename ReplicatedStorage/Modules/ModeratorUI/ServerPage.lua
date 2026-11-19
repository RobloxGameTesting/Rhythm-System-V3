local v = {
	{ label = "30 sec", value = 30 },
	{ label = "1 min", value = 60 },
	{ label = "2 min", value = 120 },
	{ label = "5 min", value = 300 }
}

local function trim(text) -- 1 equivalent call inferred from this helper
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors
		local v2 = {}
		local count = 0

		kit.pageHeader(p, "Server Control", "Control access to the server", 1)

		local order = 1
		local function nextOrder() -- 3 equivalent calls inferred from this helper
			order += 1
			return order
		end

		local count2 = 0

		local function titledRow(p2, p3, p4, layoutOrder)
			local frame = kit.new(
				"Frame",
				{
					BackgroundTransparency = 1,
					LayoutOrder = layoutOrder,
					Size = UDim2.new(1, 0, 0, 44)
				},
				p2
			)
			local label = kit.label(frame, p3, { bold = true, textSize = 13 })
			label.Position = UDim2.fromOffset(0, 4)
			label.Size = UDim2.new(1, -60, 0, 18)
			local label2 = kit.label(frame, p4, {
				color = colors.Muted,
				regular = true,
				textSize = 11,
				truncate = true
			})
			label2.Position = UDim2.fromOffset(0, 23)
			label2.Size = UDim2.new(1, -60, 0, 16)
			return frame
		end

		local v3, v4, v5

		if data.Can("SetMaintenance") then
			count2 += 1
			local v6 = kit.card(p, { order = nextOrder() }) -- inferred equivalent call
			kit.label(v6, "MAINTENANCE MODE", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 1,
				textSize = 10
			})
			v3 = kit.label(v6, "-", {
				autoY = true,
				order = 2,
				rich = true,
				textSize = 12,
				wrap = true
			})
			kit.label(
				v6,
				"While on: new non-moderator players are refused, and players already in the game get a countdown and are removed. Applies to all servers.",
				{
					autoY = true,
					color = colors.Muted,
					order = 3,
					regular = true,
					textSize = 11,
					wrap = true
				}
			)

			local textbox = kit.textbox(v6, "Maintenance message (optional)", {
				maxLength = 200,
				order = 4
			})
			kit.label(v6, "Countdown before players are removed", {
				color = colors.Muted,
				height = 16,
				order = 5,
				regular = true,
				textSize = 11
			})
			local chipGroup = kit.chipGroup(v6, v, 60, nil, { order = 6 })
			v4 = kit.button(v6, "Turn On Maintenance", {
				color = colors.Warn,
				height = 36,
				order = 7
			})
			kit.armConfirm(v4, "Turn On Maintenance", "Confirm?", function()
				data.Act("SetMaintenance", true, trim(textbox.Text), chipGroup.Get()) -- inferred equivalent call
				task.delay(1, function()
					v2.Refresh()
				end)
			end)
			v5 = kit.button(v6, "Turn Off Maintenance", {
				color = colors.Ok,
				height = 36,
				order = 8
			})
			v5.Visible = false
			v5.Activated:Connect(function()
				data.Act("SetMaintenance", false)
				task.delay(1, function()
					v2.Refresh()
				end)
			end)
		else
			v3 = nil
			v4 = nil
			v5 = nil
		end

		if data.Can("Restart") then
			count2 += 1
			local v6 = kit.card(p, { order = nextOrder() }) -- inferred equivalent call
			kit.label(v6, "SCHEDULED RESTART", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 1,
				textSize = 10
			})
			kit.label(
				v6,
				"Restarts ALL servers. Now = 10-second countdown. Press twice to confirm. Only works in the live game.",
				{
					autoY = true,
					color = colors.Muted,
					order = 2,
					regular = true,
					textSize = 11,
					wrap = true
				}
			)

			local grid, v7 = kit.grid(v6, 4, 30, 8, 3)
			local function chip(p2, p3, order2)
				local button = kit.button(grid, p2, { height = 30, order = order2, textSize = 11 })
				kit.armConfirm(button, p2, "Confirm?", function()
					data.Act("Restart", p3)
				end)
			end
			chip("Now", 0, 1)

			chip(1 .. "m", 1, 2)
			chip(2 .. "m", 2, 3)
			chip(3 .. "m", 3, 4)
			chip(4 .. "m", 4, 5)
			chip(5 .. "m", 5, 6)
			chip(6 .. "m", 6, 7)
			chip(7 .. "m", 7, 8)
			chip(8 .. "m", 8, 9)
			chip(9 .. "m", 9, 10)
			chip(10 .. "m", 10, 11)

			if data.Can("RestartCancel") then
				local button = kit.button(v6, "Cancel Restart", { height = 34, order = 4 })
				kit.armConfirm(button, "Cancel Restart", "Confirm cancel?", function()
					data.Act("RestartCancel")
				end)
			end

			data.LayoutChanged.Event:Connect(function()
				v7(data.Compact() and 3 or 4)
			end)
		end

		if count2 == 0 then
			local v6 = kit.card(p, { order = nextOrder() }) -- inferred equivalent call
			kit.label(v6, "LIMITED ACCESS", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 1,
				textSize = 10
			})
			kit.label(
				v6,
				"Your account has no server controls enabled. A Developer can change this in ModeratorConfig.",
				{
					autoY = true,
					order = 2,
					regular = true,
					textSize = 12,
					wrap = true
				}
			)
		end

		function v2.Refresh()
			if not v3 then
				return
			end

			count += 1
			local v6 = count
			task.spawn(function()
				local query = data.Query("ServerState")

				if v6 ~= count or typeof(query) ~= "table" or query.Throttled or not query.Maintenance then
					return
				end

				local maintenance = query.Maintenance

				if maintenance.Enabled then
					v3.Text = "<font color=\"#" .. colors.Warn:ToHex() .. "\"><b>ON</b></font>  by " .. kit.escape(maintenance.By or "?") .. ": " .. kit.escape(maintenance.Message or "")
				else
					v3.Text = "<font color=\"#" .. colors.Ok:ToHex() .. "\"><b>OFF</b></font>  The game is open to everyone."
				end

				v4.Visible = not maintenance.Enabled
				v5.Visible = maintenance.Enabled == true
			end)
		end

		function v2.OnShow()
			v2.Refresh()
		end

		return v2
	end
}