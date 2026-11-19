local function trim(text) -- 3 equivalent calls inferred from this helper
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function excerpt(value, p)
	local v = value:gsub("%s+", " ")

	if p < #v then
		return string.sub(v, 1, p) .. "..."
	end

	return v
end

local function chatStamp(time)
	local now = os.time()
	local v = os.date("%H:%M", time)

	if os.date("%Y%j", time) == os.date("%Y%j", now) then
		return v
	end

	local v2 = now - time

	if v2 < 604800 then
		return os.date("%a", time) .. " " .. v
	end

	if v2 < 31536000 then
		return os.date("%d %b", time) .. " " .. v
	end

	return os.date("%d %b %Y", time) .. " " .. v
end

return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors
		local v = {}

		local v2 = "Chat"
		local entries = {}
		local v3 = {}
		local v4 = ""
		local v5 = ""
		local v6 = false
		local count = 0
		local id = nil
		local v7 = nil

		local function linkButton(frame, text, textColor, layoutOrder)
			local textButton = kit.new("TextButton", {
				AutoButtonColor = false,
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Font = kit.FontMedium,
				LayoutOrder = layoutOrder,
				Size = UDim2.fromOffset(0, 16),
				Text = text,
				TextColor3 = textColor,
				TextSize = 11
			}, frame)

			textButton.MouseEnter:Connect(function()
				textButton.TextColor3 = colors.Text
			end)
			textButton.MouseLeave:Connect(function()
				textButton.TextColor3 = textColor
			end)
			return textButton
		end

		local frame = kit.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48) }, p)
		local pageHeader = kit.pageHeader(frame, "Discussion", "Group chat and a shared note board for moderators", 1)
		pageHeader.Size = UDim2.new(0.6, 0, 0, 0)

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

		local scrollingFrame2 = kit.new("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = colors.Surface,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ScrollBarImageColor3 = colors.Border,
			ScrollBarThickness = 3,
			Size = UDim2.new(1, 0, 1, -50)
		}, frame3)

		kit.corner(scrollingFrame2, 12)
		kit.stroke(scrollingFrame2, colors.Border, 0.35, 1)
		kit.padding(scrollingFrame2, 10, 14, 10, 12)
		kit.list(scrollingFrame2, 12)

		local frame4 = kit.new("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = colors.Surface2,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -46),
			Size = UDim2.new(1, 0, 0, 28),
			Visible = false
		}, frame3)

		kit.corner(frame4, 8)
		local label = kit.label(frame4, "", {
			color = colors.Muted,
			regular = true,
			rich = true,
			textSize = 11,
			truncate = true
		})
		label.Position = UDim2.fromOffset(12, 0)
		label.Size = UDim2.new(1, -44, 1, 0)
		local button = kit.button(frame4, "", {
			base = colors.Surface3,
			radius = 6,
			sizeUDim = UDim2.fromOffset(22, 22),
			stroke = false
		})
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -6, 0.5, 0)
		local cross = kit.cross(button, colors.Muted)
		cross.AnchorPoint = Vector2.new(0.5, 0.5)
		cross.Position = UDim2.fromScale(0.5, 0.5)
		cross.Size = UDim2.fromOffset(10, 10)

		local frame5 = kit.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 40)
			},
			frame3
		)

		local textbox = kit.textbox(frame5, "Message the other moderators...  (Enter to send)", {
			maxLength = 200
		})
		textbox.Size = UDim2.new(1, -80, 1, 0)
		local button2 = kit.button(frame5, "Send", {
			base = colors.AccentDim,
			bold = true,
			color = colors.Accent,
			sizeUDim = UDim2.fromOffset(72, 40)
		})

		button2.AnchorPoint = Vector2.new(1, 0)
		button2.Position = UDim2.fromScale(1, 0)

		local function findChat(id2) -- 2 equivalent calls inferred from this helper
			for _, v8 in ipairs(entries) do
				if v8.Id == id2 then
					return v8
				end
			end

			return nil
		end

		local function clearReply() -- 2 equivalent calls inferred from this helper
			v7 = nil
			frame4.Visible = false
			scrollingFrame2.Size = UDim2.new(1, 0, 1, -50)
		end

		local function setReply(player)
			v7 = { Id = player.Id, Name = player.Name }
			local escaped = kit.escape(player.Name)
			local escape = kit.escape
			local v8 = player.Text:gsub("%s+", " ")

			if #v8 > 70 then
				v8 = string.sub(v8, 1, 70) .. "..."
			end

			label.Text = "Replying to <b>@" .. escaped .. "</b>:  " .. escape(v8)
			frame4.Visible = true
			scrollingFrame2.Size = UDim2.new(1, 0, 1, -82)
			textbox:CaptureFocus()
		end
		button.Activated:Connect(clearReply)

		local function atBottom(): boolean -- 2 equivalent calls inferred from this helper
			return scrollingFrame2.AbsoluteCanvasSize.Y - scrollingFrame2.AbsoluteWindowSize.Y - scrollingFrame2.CanvasPosition.Y < 40
		end

		local function scrollChatToBottom() -- 4 equivalent calls inferred from this helper
			task.defer(function()
				task.wait(0.05)
				scrollingFrame2.CanvasPosition = Vector2.new(
					0,
					(math.max(0, scrollingFrame2.AbsoluteCanvasSize.Y - scrollingFrame2.AbsoluteWindowSize.Y))
				)
			end)
		end

		local function addChatRow(player, layoutOrder)
			local frame6 = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = layoutOrder,
					Size = UDim2.new(1, 0, 0, 0)
				},
				scrollingFrame2
			)

			kit.list(frame6, 3)

			local v8 = player.UserId == data.Player.UserId
			local accent = v8 and colors.Accent or colors.Text

			local role = player.Role or (player.Tier or 0) >= 2 and "Developer" or "Moderator"
			local v9 = role == "Moderator" and "Mods" or role
			local muted = role == "Tester" and colors.Muted or role == "Developer" and colors.Accent or colors.Danger
			local v10 = "<b><font color=\"#" .. accent:ToHex() .. "\">" .. kit.escape(player.DisplayName) .. "</font></b>  " .. "<font color=\"#" .. colors.Muted:ToHex() .. "\">@" .. kit.escape(player.Name) .. "</font>" .. "<font color=\"#" .. muted:ToHex() .. "\"> - " .. v9 .. "</font>" .. "<font color=\"#" .. colors.Muted:ToHex() .. "\">  ·  " .. chatStamp(player.Time) .. "</font>"

			local frame7 = kit.new(
				"Frame",
				{ BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 16) },
				frame6
			)
			local label = kit.label(frame7, v10, {
				height = 16,
				rich = true,
				textSize = 12,
				truncate = true
			})
			label.Size = UDim2.new(1, -130, 1, 0)
			local frame8 = kit.new("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, 0, 1, 0)
			}, frame7)

			kit.list(frame8, 12, {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right
			})
			linkButton(frame8, "Reply", colors.Muted, 1).Activated:Connect(function()
				setReply(player)
			end)

			if v8 or data.IsDeveloper then
				linkButton(frame8, "Unsend", Color3.fromRGB(190, 110, 110), 2).Activated:Connect(function()
					data.Act("UnsendChat", player.Id)
				end)
			end

			if player.ReplyTo then
				local frame9 = kit.new(
					"Frame",
					{
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						Size = UDim2.new(1, 0, 0, 0)
					},
					frame6
				)

				kit.padding(frame9, 1, 0, 1, 10)
				local frame10 = kit.new(
					"Frame",
					{
						BackgroundColor3 = colors.Border,
						BorderSizePixel = 0,
						Size = UDim2.new(0, 2, 1, 0)
					},
					frame9
				)
				kit.corner(frame10, 1)
				local chat = findChat(player.ReplyTo.Id) -- inferred equivalent call
				local v11

				if chat then
					local escaped = kit.escape(chat.Name)
					local escape = kit.escape
					local v12 = chat.Text:gsub("%s+", " ")

					if #v12 > 80 then
						v12 = string.sub(v12, 1, 80) .. "..."
					end

					v11 = "<b>@" .. escaped .. "</b>  " .. escape(v12)
				else
					v11 = "<b>@" .. kit.escape(player.ReplyTo.Name) .. "</b>  <i>original message is no longer available</i>"
				end

				kit.label(frame9, v11, {
					autoY = true,
					color = colors.Muted,
					regular = true,
					rich = true,
					textSize = 11,
					wrap = true
				})
			end

			kit.label(frame6, player.Text, {
				autoY = true,
				order = 3,
				regular = true,
				textSize = 13,
				wrap = true
			})
		end

		local function rebuildChat()
			kit.clear(scrollingFrame2)

			if #entries == 0 then
				kit.emptyState(scrollingFrame2, "No messages yet. Say hi to the other moderators!", 1)
				return
			end

			for i, v8 in ipairs(entries) do
				addChatRow(v8, i)
			end
		end

		local function sendChat() -- 1 equivalent call inferred from this helper
			local v8 = trim(textbox.Text) -- inferred equivalent call

			if #v8 < 1 then
				return
			end

			data.Act("SendChat", v8, v7 and v7.Id or nil)
			textbox.Text = ""
			clearReply() -- inferred equivalent call
		end
		textbox.FocusLost:Connect(function(p2)
			if p2 then
				sendChat() -- inferred equivalent call
				task.defer(function()
					textbox:CaptureFocus()
				end)
			end
		end)
		button2.Activated:Connect(sendChat)

		local card = kit.card(scrollingFrame, { order = 1 })
		kit.label(card, "LEAVE A NOTE", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 1,
			textSize = 10
		})
		local textbox2 = kit.textbox(card, "Write a note for the other moderators...", {
			height = 72,
			maxLength = 300,
			multiline = true,
			order = 2
		})
		kit.button(card, "Post Note", {
			base = colors.AccentDim,
			color = colors.Accent,
			bold = true,
			height = 36,
			order = 3
		}).Activated:Connect(function()
			local v8 = trim(textbox2.Text) -- inferred equivalent call

			if #v8 < 1 then
				data.Toast("Write a note first", "error")
				return
			end

			data.Act("PostNote", v8)
			textbox2.Text = ""
		end)

		local grid, v8 = kit.grid(scrollingFrame, 4, 160, 10, 2)
		local emptyState = kit.emptyState(scrollingFrame, "No notes yet. Leave one for the other moderators.", 3)

		local function applyColumns() -- 2 equivalent calls inferred from this helper
			v8(data.Compact() and 2 or 4)
		end
		data.LayoutChanged.Event:Connect(applyColumns)
		applyColumns() -- inferred equivalent call

		local function split()
			local result = {}
			local result2 = {}

			for _, v9 in ipairs(v3) do
				if v9.ReplyTo then
					local v10 = result[v9.ReplyTo.Id]

					if not v10 then
						v10 = {}
						result[v9.ReplyTo.Id] = v10
					end

					table.insert(v10, v9)
				else
					table.insert(result2, v9)
				end
			end

			table.sort(result2, function(a, b)
				local pinned = a.Pinned == true

				if pinned ~= (b.Pinned == true) then
					return pinned
				end

				if a.Time == b.Time then
					return tostring(a.Id) > tostring(b.Id)
				end

				return a.Time > b.Time
			end)

			for _, list in pairs(result) do
				table.sort(list, function(a, b): boolean
					if a.Time == b.Time then
						return tostring(a.Id) < tostring(b.Id)
					end

					return a.Time < b.Time
				end)
			end

			return result2, result
		end

		local function findNote(id2) -- 3 equivalent calls inferred from this helper
			for _, v9 in ipairs(v3) do
				if v9.Id == id2 then
					return v9
				end
			end

			return nil
		end

		local textButton = kit.new("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			Visible = false,
			ZIndex = 10
		}, frame2)

		kit.corner(textButton, 12)

		local textButton2 = kit.new("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = colors.Surface,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -40, 0, 0),
			Text = "",
			ZIndex = 11
		}, textButton)

		kit.new("UISizeConstraint", { MaxSize = Vector2.new(460, 1e999) }, textButton2)
		kit.corner(textButton2, 14)
		kit.stroke(textButton2, colors.Border, 0.2, 1)
		kit.padding(textButton2, 16, 16, 16, 16)
		kit.list(textButton2, 8)

		local label2 = kit.label(textButton2, "", {
			autoY = true,
			order = 1,
			rich = true,
			textSize = 13,
			wrap = true
		})
		local label3 = kit.label(textButton2, "", {
			autoY = true,
			order = 2,
			regular = true,
			textSize = 14,
			wrap = true
		})
		local label4 = kit.label(textButton2, "", {
			color = colors.Muted,
			height = 16,
			order = 3,
			regular = true,
			textSize = 11
		})
		local label5 = kit.label(textButton2, "", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 4,
			textSize = 10
		})
		local frame6 = kit.new(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 5,
				Size = UDim2.new(1, 0, 0, 0)
			},
			textButton2
		)

		kit.list(frame6, 8)

		local frame7 = kit.new("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 6,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = false
		}, textButton2)

		kit.list(frame7, 6)
		local textbox3 = kit.textbox(frame7, "Write your reply...", {
			height = 64,
			maxLength = 300,
			multiline = true,
			order = 1
		})
		local button3 = kit.button(frame7, "Send Reply", {
			base = colors.AccentDim,
			color = colors.Accent,
			bold = true,
			height = 34,
			order = 2
		})

		local grid2 = kit.grid(textButton2, 4, 36, 8, 7)
		local button4 = kit.button(grid2, "Reply", { height = 36, order = 1 })
		local button5 = kit.button(grid2, "Pin", { height = 36, order = 2 })
		local button6 = kit.button(grid2, "Delete", {
			color = colors.Danger,
			height = 36,
			order = 3
		})
		local button7 = kit.button(grid2, "Close", { height = 36, order = 4 })

		local function refreshOverlay()
			if not id then
				textButton.Visible = false
				return
			end

			local note = findNote(id) -- inferred equivalent call

			if note then
				label2.Text = "<font color=\"#" .. colors.Accent:ToHex() .. "\"><b>Note from @" .. kit.escape(note.Name) .. " :</b></font>"
				label3.Text = note.Text
				label4.Text = kit.dateTime(note.Time) .. "  (" .. kit.timeAgo(note.Time) .. ")" .. (note.Pinned and "  -  pinned" or "")
				local visible = note.UserId == data.Player.UserId or data.IsDeveloper
				button5.Visible = visible and data.Can("PinNote")
				button6.Visible = visible
				button5.Text = note.Pinned and "Unpin" or "Pin"

				local _, v9 = split()
				local v10 = v9[id] or {}
				kit.clear(frame6)
				label5.Visible = #v10 > 0
				label5.Text = "REPLIES (" .. #v10 .. ")"
				local v11 = math.max(1, #v10 - 4 + 1)

				if v11 > 1 then
					kit.label(frame6, "+ " .. v11 - 1 .. " earlier replies not shown", {
						color = colors.Muted,
						height = 14,
						order = 0,
						regular = true,
						textSize = 10
					})
				end

				for i = v11, #v10 do
					local v12 = v10[i]
					local frame8 = kit.new(
						"Frame",
						{
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							LayoutOrder = i,
							Size = UDim2.new(1, 0, 0, 0)
						},
						frame6
					)

					kit.padding(frame8, 0, 0, 0, 10)

					local frame9 = kit.new("Frame", {
						BackgroundColor3 = colors.Accent,
						BackgroundTransparency = 0.5,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(-10, 0),
						Size = UDim2.new(0, 2, 1, 0)
					}, frame8)
					kit.corner(frame9, 1)
					local frame10 = kit.new(
						"Frame",
						{
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0)
						},
						frame8
					)
					kit.list(frame10, 2)
					kit.label(frame10, "<b>@" .. kit.escape(v12.Name) .. "</b>  " .. kit.escape(v12.Text), {
						autoY = true,
						order = 1,
						regular = true,
						rich = true,
						textSize = 12,
						wrap = true
					})
					local frame11 = kit.new(
						"Frame",
						{
							BackgroundTransparency = 1,
							LayoutOrder = 2,
							Size = UDim2.new(1, 0, 0, 14)
						},
						frame10
					)
					kit.list(frame11, 10, { FillDirection = Enum.FillDirection.Horizontal })
					kit.label(frame11, kit.timeAgo(v12.Time), {
						color = colors.Muted,
						regular = true,
						sizeUDim = UDim2.fromOffset(70, 14),
						textSize = 10
					})

					if v12.UserId == data.Player.UserId or data.IsDeveloper then
						linkButton(frame11, "Delete", Color3.fromRGB(190, 110, 110), 2).Activated:Connect(function()
							data.Act("DeleteNote", v12.Id)
						end)
					end
				end
			else
				id = nil
				textButton.Visible = false
			end
		end

		local function closeOverlay() -- 3 equivalent calls inferred from this helper
			id = nil
			textButton.Visible = false
			frame7.Visible = false
			textbox3.Text = ""
		end

		textButton.Activated:Connect(closeOverlay)
		button7.Activated:Connect(closeOverlay)
		button4.Activated:Connect(function()
			frame7.Visible = not frame7.Visible

			if frame7.Visible then
				textbox3:CaptureFocus()
			end
		end)
		button3.Activated:Connect(function()
			local v9 = trim(textbox3.Text) -- inferred equivalent call

			if #v9 < 1 then
				data.Toast("Write a reply first", "error")
				return
			end

			if id then
				data.Act("PostNote", v9, id)
			end

			textbox3.Text = ""
			frame7.Visible = false
		end)
		button5.Activated:Connect(function()
			local v9 = id
			local v10

			if v9 then
				local v11 = id

				for _, v12 in ipairs(v3) do
					if v12.Id == v11 then
						v10 = v12
						break
					end
				end
			else
				v10 = v9
			end

			if v10 then
				data.Act("PinNote", v10.Id, v10.Pinned ~= true)
			end
		end)
		kit.armConfirm(button6, "Delete", "Confirm?", function()
			if id then
				data.Act("DeleteNote", id)
				closeOverlay() -- inferred equivalent call
			end
		end)

		local function renderNotes()
			kit.clear(grid)
			local v9, v10 = split()
			emptyState.Visible = #v9 == 0

			for i, v11 in ipairs(v9) do
				local pinned = v11.Pinned == true
				local v12 = v10[v11.Id] and #v10[v11.Id] or 0
				local button8 = kit.button(grid, "", {
					base = pinned and colors.AccentDim or colors.Surface,
					height = 160,
					order = i,
					radius = 12,
					stroke = false
				})

				kit.stroke(button8, pinned and colors.Accent or colors.Border, pinned and 0.15 or 0.35, 1)
				kit.padding(button8, 12, 12, 10, 12)

				local label = kit.label(
					button8,
					"<font color=\"#" .. colors.Accent:ToHex() .. "\"><b>Note from @" .. kit.escape(v11.Name) .. " :</b></font>",
					{ height = 16, rich = true, textSize = 11, truncate = true }
				)

				label.Size = UDim2.new(1, 0, 0, 16)

				local label6 = kit.label(button8, v11.Text, {
					regular = true,
					textSize = 12,
					truncate = true,
					valign = Enum.TextYAlignment.Top,
					wrap = true
				})

				label6.Position = UDim2.fromOffset(0, 22)
				label6.Size = UDim2.new(1, 0, 1, -48)

				local frame8 = kit.new(
					"Frame",
					{
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.new(1, 0, 0, 20)
					},
					button8
				)

				local v13 = kit.timeAgo(v11.Time)

				if v12 > 0 then
					v13 = v12 .. (v12 == 1 and " reply" or " replies")
				end

				local label_2 = kit.label(frame8, v13, {
					color = v12 > 0 and colors.Accent or colors.Muted,
					regular = true,
					textSize = 10,
					truncate = true
				})

				label_2.Size = UDim2.new(0.6, 0, 1, 0)

				if pinned then
					local badge = kit.badge(frame8, "PINNED", colors.Accent)
					badge.AnchorPoint = Vector2.new(1, 0.5)
					badge.Position = UDim2.new(1, 0, 0.5, 0)
				end

				button8.Activated:Connect(function()
					id = v11.Id
					textButton.Visible = true
					frame7.Visible = false
					refreshOverlay()
				end)
			end

			refreshOverlay()
		end

		local chipGroup = kit.chipGroup(frame, {
			{ label = "Group Chat", value = "Chat" },
			{ label = "Note Board", value = "Notes" }
		}, "Chat", function(p2)
			v2 = p2
			frame3.Visible = p2 == "Chat"
			scrollingFrame.Visible = p2 == "Notes"

			if p2 ~= "Notes" then
				closeOverlay() -- inferred equivalent call
			end

			if p2 == "Chat" then
				scrollChatToBottom() -- inferred equivalent call
			end
		end)
		chipGroup.Instance.AnchorPoint = Vector2.new(1, 0)
		chipGroup.Instance.Position = UDim2.new(1, 0, 0, 8)
		chipGroup.Instance.Size = UDim2.new(0.4, 0, 0, 0)
		local uiListLayout = chipGroup.Instance:FindFirstChildOfClass("UIListLayout")
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

		local function chatSig(list)
			local ids = {}

			for _, item in ipairs(list) do
				table.insert(ids, item.Id)
			end

			return table.concat(ids, ",")
		end

		local function notesSig(list)
			local v9 = {}

			for _, item in ipairs(list) do
				table.insert(v9, item.Id .. (item.Pinned and "*" or ""))
			end

			return table.concat(v9, ",")
		end

		local function removeNotes(ids)
			local set = {}

			for _, item in ipairs(ids) do
				set[item] = true
			end

			for i = #v3, 1, -1 do
				if set[v3[i].Id] then
					table.remove(v3, i)
				end
			end
		end

		function v.OnLive(data2)
			local entry = data2.Entry

			if data2.Kind == "Chat" and entry then
				if findChat(entry.Id) then -- inferred equivalent call
					return
				end

				local v9 = atBottom() or entry.UserId == data.Player.UserId -- inferred equivalent call
				table.insert(entries, entry)

				if #entries == 1 then
					rebuildChat()
				else
					addChatRow(entry, #entries)
				end

				v4 = chatSig(entries)

				if not v9 then
					return
				end

				scrollChatToBottom() -- inferred equivalent call
			elseif data2.Kind == "ChatDeleted" and data2.Id then
				for i, v9 in ipairs(entries) do
					if v9.Id == data2.Id then
						table.remove(entries, i)
						break
					end
				end

				if v7 and v7.Id == data2.Id then
					clearReply() -- inferred equivalent call
				end

				v4 = chatSig(entries)
				rebuildChat()
			elseif data2.Kind == "Note" and entry then
				if findNote(entry.Id) then -- inferred equivalent call
					return
				end

				table.insert(v3, 1, entry)
				v5 = notesSig(v3)
				renderNotes()
			elseif data2.Kind == "NoteDeleted" then
				removeNotes(data2.Ids or { data2.Id })
				v5 = notesSig(v3)
				renderNotes()
			elseif data2.Kind == "NotePinned" and data2.Id then
				local note = findNote(data2.Id) -- inferred equivalent call

				if note then
					note.Pinned = data2.Pinned == true or nil
					v5 = notesSig(v3)
					renderNotes()
				end
			end
		end

		function v.Refresh()
			count += 1
			local v9 = count
			task.spawn(function()
				local query = data.Query("Notes")

				if v9 ~= count or typeof(query) ~= "table" or query.Throttled or not query.Chat then
					return
				end

				local v10 = chatSig(query.Chat)

				if v10 ~= v4 then
					local v11 = not v6 or atBottom() -- inferred equivalent call
					entries = query.Chat
					v4 = v10
					rebuildChat()

					if v11 then
						scrollChatToBottom() -- inferred equivalent call
					end
				end

				local v11 = notesSig(query.Notes or {})

				if v11 ~= v5 then
					v3 = query.Notes or {}
					v5 = v11
					renderNotes()
				end

				v6 = true
			end)
		end

		function v.OnShow()
			applyColumns() -- inferred equivalent call
			v.Refresh()

			if v2 == "Chat" then
				scrollChatToBottom() -- inferred equivalent call
			end
		end

		function v.OnHide()
			closeOverlay() -- inferred equivalent call
		end

		rebuildChat()
		renderNotes()
		return v
	end
}