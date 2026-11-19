local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function trim(text) -- 7 equivalent calls inferred from this helper
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

return {
	new = function(p, p2)
		local kit = p2.Kit
		local colors = kit.Colors
		local v = {}

		local infoBoardRemotes = ReplicatedStorage:FindFirstChild("InfoBoardRemotes")
		local infoMod = infoBoardRemotes and infoBoardRemotes:FindFirstChild("InfoMod")

		kit.pageHeader(p, "Server Board", "Controls the Backstage paper next to the Song Catalog on the main board.", 1)

		if not infoMod then
			kit.emptyState(p, "Server Board is not available right now (remote missing).", 2)
			return v
		end

		local function call(p3, ...)
			local v2 = table.pack(...)
			local success, result, v3 = pcall(function()
				return infoMod:InvokeServer(p3, table.unpack(v2, 1, v2.n))
			end)

			if success then
				return result == true, v3
			end

			return false, "couldn't reach the server"
		end

		local function report(p3, value) -- 5 equivalent calls inferred from this helper
			if typeof(value) == "string" and value ~= "" then
				p2.Toast(value, p3 and "success" or "error")
			end
		end

		local v2 = nil
		local fn

		local card = kit.card(p, { order = 2 })
		kit.label(card, "ANNOUNCEMENT", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 1,
			textSize = 10
		})
		local v3 = "Global"
		local v4 = nil
		local function renderAnnounceStatus() -- 2 equivalent calls inferred from this helper
			local announcement = v2 and (v3 == "Global" and v2.Announcement or v2.ServerAnnouncement)

			if announcement then
				local v5 = announcement.Title and announcement.Title ~= "" and announcement.Title .. ": " or ""
				v4.Text = "Showing now: " .. v5 .. announcement.Text
				v4.TextColor3 = colors.Text
			else
				v4.Text = "Nothing is posted for this scope."
				v4.TextColor3 = colors.Muted
			end
		end
		kit.chipGroup(card, {
			{ label = "All servers", value = "Global" },
			{ label = "This server only", value = "Server" }
		}, "Global", function(p3)
			v3 = p3
			renderAnnounceStatus() -- inferred equivalent call
		end, { order = 2 })
		local textbox = kit.textbox(card, "Title (optional, max 60)", { maxLength = 60, order = 3 })
		local textbox2 = kit.textbox(card, "Message (max 400 characters)", {
			height = 96,
			maxLength = 400,
			multiline = true,
			order = 4
		})
		v4 = kit.label(card, "", {
			autoY = true,
			color = colors.Muted,
			order = 5,
			regular = true,
			textSize = 11,
			wrap = true
		})
		local grid = kit.grid(card, 2, 36, 8, 6)
		local button = kit.button(grid, "Post to board", {
			base = colors.Accent,
			color = Color3.fromRGB(22, 22, 27),
			bold = true,
			height = 36,
			order = 1
		})
		local button2 = kit.button(grid, "Clear this scope", { height = 36, order = 2 })
		button.Activated:Connect(function()
			local v5 = trim(textbox2.Text) -- inferred equivalent call

			if #v5 < 1 then
				p2.Toast("Write a message first", "error")
				return
			end

			local v6, v7 = call("SetAnnouncement", v3, trim(textbox.Text), v5) -- inferred equivalent call
			report(v6, v7) -- inferred equivalent call

			if v6 then
				textbox2.Text = ""
				textbox.Text = ""
				fn()
			end
		end)
		kit.armConfirm(button2, "Clear this scope", "Tap again to clear", function()
			local v5, v6 = call("ClearAnnouncement", v3)
			report(v5, v6) -- inferred equivalent call
			fn()
		end)

		local card2 = kit.card(p, { order = 3 })
		kit.label(card2, "UPDATE LOG", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 1,
			textSize = 10
		})
		kit.label(
			card2,
			"[NEW SONG] lines are added automatically once every chart of a song is ready (NEW lasts 7 days). Add your own lines here, e.g. fix bug, add drum animation.",
			{
				autoY = true,
				color = colors.Muted,
				order = 2,
				regular = true,
				textSize = 11,
				wrap = true
			}
		)

		local v5 = "Global"
		kit.chipGroup(card2, {
			{ label = "All servers", value = "Global" },
			{ label = "This server only", value = "Server" }
		}, "Global", function(p3)
			v5 = p3
		end, { order = 3 })
		local textbox3 = kit.textbox(card2, "Log line (max 120), e.g. fix free play mode", {
			maxLength = 120,
			order = 4
		})
		local button3 = kit.button(card2, "Add log line", {
			base = colors.AccentDim,
			color = colors.Accent,
			height = 36,
			order = 5
		})
		kit.label(card2, "YOUR LOG LINES", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 6,
			textSize = 10
		})
		local frame = kit.new(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 7,
				Size = UDim2.new(1, 0, 0, 0)
			},
			card2
		)

		kit.list(frame, 6)

		local function renderLogList()
			kit.clear(frame)
			local log = v2 and v2.Log or {}

			if #log == 0 then
				kit.emptyState(frame, "No custom log lines yet", 1)
				return
			end

			for i, v6 in ipairs(log) do
				local frame2 = kit.new(
					"Frame",
					{
						BackgroundColor3 = colors.Surface2,
						BorderSizePixel = 0,
						LayoutOrder = i,
						Size = UDim2.new(1, 0, 0, 36)
					},
					frame
				)

				kit.corner(frame2, 8)
				local label = kit.label(
					frame2,
					string.format("[%s] %s", v6.Scope == "Server" and "server" or "all", v6.Text),
					{ sizeUDim = UDim2.new(1, -92, 1, 0), textSize = 12, truncate = true }
				)

				label.Position = UDim2.fromOffset(10, 0)
				local button4 = kit.button(frame2, "Remove", {
					color = colors.Danger,
					sizeUDim = UDim2.fromOffset(72, 26),
					textSize = 11
				})

				button4.AnchorPoint = Vector2.new(1, 0.5)
				button4.Position = UDim2.new(1, -6, 0.5, 0)
				kit.armConfirm(button4, "Remove", "Sure?", function()
					local v7, v8 = call("RemoveLog", v6.Id)
					report(v7, v8) -- inferred equivalent call
					fn()
				end)
			end
		end

		button3.Activated:Connect(function()
			local v6 = trim(textbox3.Text) -- inferred equivalent call

			if #v6 < 1 then
				p2.Toast("Write the log line first", "error")
				return
			end

			local v7, v8 = call("AddLog", v5, v6)
			report(v7, v8) -- inferred equivalent call

			if v7 then
				textbox3.Text = ""
				fn()
			end
		end)

		local card3 = kit.card(p, { order = 4 })
		kit.label(card3, "COMMUNITY GIG BOARD (all servers)", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 1,
			textSize = 10
		})
		kit.label(
			card3,
			"Event, weekly challenge and featured song. Leave the featured song empty to show the song with the most favorites.",
			{
				autoY = true,
				color = colors.Muted,
				order = 2,
				regular = true,
				textSize = 11,
				wrap = true
			}
		)

		local textbox4 = kit.textbox(card3, "Event title (max 60)", { maxLength = 60, order = 3 })
		local textbox5 = kit.textbox(card3, "Event details (max 300)", {
			height = 84,
			maxLength = 300,
			multiline = true,
			order = 4
		})
		local textbox6 = kit.textbox(card3, "Weekly challenge (max 200)", {
			height = 60,
			maxLength = 200,
			multiline = true,
			order = 5
		})
		local textbox7 = kit.textbox(card3, "Featured song title (empty = crowd favorite)", {
			maxLength = 80,
			order = 6
		})
		kit.button(card3, "Save gig board", {
			base = colors.Accent,
			color = Color3.fromRGB(22, 22, 27),
			bold = true,
			height = 38,
			order = 7
		}).Activated:Connect(function()
			local v6, v7 = call(
				"SetGig",
				trim(textbox4.Text), -- inferred equivalent call
				trim(textbox5.Text), -- inferred equivalent call
				trim(textbox6.Text), -- inferred equivalent call
				trim(textbox7.Text) -- inferred equivalent call
			)
			report(v6, v7) -- inferred equivalent call

			if v6 then
				fn()
			end
		end)

		local v6 = false
		fn = function()
			local v7, v8 = call("GetState")

			if not v7 or typeof(v8) ~= "table" then
				return
			end

			v2 = v8
			renderAnnounceStatus() -- inferred equivalent call
			renderLogList()

			if not (v6 and (textbox4:IsFocused() or textbox5:IsFocused() or textbox6:IsFocused() or textbox7:IsFocused())) then
				v6 = true
				local gig = v2.Gig or {}
				textbox4.Text = gig.EventTitle or ""
				textbox5.Text = gig.EventText or ""
				textbox6.Text = gig.Challenge or ""
				textbox7.Text = gig.FeaturedTitle or ""
			end
		end

		function v.OnShow()
			task.spawn(fn)
		end

		local announcement = v2 and (v3 == "Global" and v2.Announcement or v2.ServerAnnouncement)

		if announcement then
			v4.Text = "Showing now: " .. (announcement.Title and announcement.Title ~= "" and announcement.Title .. ": " or "") .. announcement.Text
			v4.TextColor3 = colors.Text
		else
			v4.Text = "Nothing is posted for this scope."
			v4.TextColor3 = colors.Muted
		end

		renderLogList()
		return v
	end
}