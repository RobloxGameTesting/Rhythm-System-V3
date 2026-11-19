local v = {
	Global = { Tag = "ANNOUNCEMENT", Title = "Announcement", Scope = "Sent to ALL servers." },
	Server = {
		Tag = "SERVER MESSAGE",
		Title = "Server Message",
		Scope = "Sent to this server only."
	}
}

local function trim(text) -- 5 equivalent calls inferred from this helper
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors

		local v2 = data.IsTester and "Server" or "Global"

		kit.pageHeader(p, "Announcements", "Preview and confirm before anything is sent.", 1)

		local card = kit.card(p, { order = 2 })
		kit.label(card, "NEW ANNOUNCEMENT", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 1,
			textSize = 10
		})

		local updatePreview
		local frame = nil
		local v3 = nil
		local v4 = data.IsTester and {
			{ label = "This server only", value = "Server" }
		} or {
			{ label = "All servers", value = "Global" },
			{ label = "This server only", value = "Server" }
		}

		kit.chipGroup(card, v4, v2, function(p2)
			v2 = p2
			frame.Visible = false
			v3.Visible = true
			updatePreview()
		end, { order = 2 })

		local textbox = kit.textbox(card, "Title (optional)", { maxLength = 60, order = 3 })
		local textbox2 = kit.textbox(card, "Message (max 200 characters)", {
			height = 84,
			maxLength = 200,
			multiline = true,
			order = 4
		})
		local label = kit.label(card, v.Global.Scope, {
			autoY = true,
			color = colors.Muted,
			order = 5,
			regular = true,
			textSize = 11,
			wrap = true
		})

		kit.label(card, "PREVIEW (as players will see it)", {
			bold = true,
			color = colors.Muted,
			height = 16,
			order = 6,
			textSize = 10
		})
		local card2 = kit.card(card, { color = colors.Surface2, order = 7, gap = 4 })
		local label2 = kit.label(card2, "ANNOUNCEMENT", {
			bold = true,
			color = colors.Accent,
			height = 14,
			order = 1,
			textSize = 10
		})
		local label3 = kit.label(card2, "Announcement", {
			autoY = true,
			bold = true,
			order = 2,
			textSize = 14,
			wrap = true
		})
		local label4 = kit.label(card2, "Your message will appear here", {
			autoY = true,
			color = colors.Muted,
			order = 3,
			regular = true,
			textSize = 12,
			wrap = true
		})

		updatePreview = function()
			local v5 = v[v2]
			label2.Text = v5.Tag
			local text = trim(textbox.Text) -- inferred equivalent call

			if text == "" or not text then
				text = v5.Title
			end

			label3.Text = text
			local v6 = trim(textbox2.Text) -- inferred equivalent call
			label4.Text = (v6 == "" or not v6) and "Your message will appear here" or v6
			label4.TextColor3 = v6 ~= "" and colors.Text or colors.Muted
			label.Text = v5.Scope
		end
		textbox:GetPropertyChangedSignal("Text"):Connect(updatePreview)
		textbox2:GetPropertyChangedSignal("Text"):Connect(updatePreview)

		v3 = kit.button(card, "Review & Send", {
			base = colors.AccentDim,
			color = colors.Accent,
			height = 38,
			order = 8
		})
		frame = kit.new("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 9,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = false
		}, card)

		kit.list(frame, 8)
		local label5 = kit.label
		local v5 = frame
		label5(v5, "Check the preview above. Send now?", {
			autoY = true,
			bold = true,
			color = colors.Accent,
			order = 1,
			textSize = 12,
			wrap = true
		})
		local grid = kit.grid(frame, 2, 38, 8, 2)
		local button = kit.button(grid, "Confirm & Send", {
			base = colors.Accent,
			color = Color3.fromRGB(22, 22, 27),
			bold = true,
			height = 38,
			order = 1
		})
		local button2 = kit.button(grid, "Edit", { height = 38, order = 2 })

		v3.Activated:Connect(function()
			if #trim(textbox2.Text) < 1 then -- inferred equivalent call
				data.Toast("Write a message first", "error")
				return
			end

			v3.Visible = false
			frame.Visible = true
		end)
		button2.Activated:Connect(function()
			frame.Visible = false
			v3.Visible = true
		end)
		button.Activated:Connect(function()
			data.Act("Broadcast", v2, trim(textbox2.Text), trim(textbox.Text)) -- inferred equivalent call
			textbox2.Text = ""
			textbox.Text = ""
			frame.Visible = false
			v3.Visible = true
		end)

		updatePreview()
		return {}
	end
}