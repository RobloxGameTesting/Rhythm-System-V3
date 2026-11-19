local v = {
	GuitarLead = "Lead Guitar",
	GuitarRhythm = "Rhythm Guitar",
	Bass = "Bass",
	Drum = "Drum",
	Piano = "Piano",
	Keyboard = "Keyboard"
}
return {
	new = function(p, data)
		local kit = data.Kit
		local colors = kit.Colors
		local v2 = {}

		local v3 = {}
		local count = 0

		kit.pageHeader(
			p,
			"Music & Studio",
			data.IsTester and "View only: song sessions and instrument positions in each studio" or "Song sessions and instrument positions in each studio",
			1
		)

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

		kit.list(frame, 12)

		local emptyState = kit.emptyState(frame, "Loading studio data...", 1)

		local function lockButton(button) -- 3 equivalent calls inferred from this helper
			button.Active = false
			button.TextColor3 = colors.Muted
			button.TextTransparency = 0.45
		end

		local function createView(id, i)
			local view = { Slots = {} }
			view.Card = kit.card(frame, {
				order = i + 1
			})

			local frame2 = kit.new(
				"Frame",
				{ BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 24) },
				view.Card
			)

			local label = kit.label
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local label_2 = label(frame2, require(ReplicatedStorage.Modules.StageNames).Display(id), {
				bold = true,
				height = 24,
				textSize = 15
			})
			label_2.Size = UDim2.new(0.4, 0, 1, 0)
			view.Badges = kit.new("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0, 2),
				Size = UDim2.fromOffset(0, 20)
			}, frame2)

			kit.list(view.Badges, 6, {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right
			})

			view.Sessions = kit.new(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 0)
				},
				view.Card
			)
			kit.list(view.Sessions, 8)

			kit.label(view.Card, "INSTRUMENT POSITIONS", {
				bold = true,
				color = colors.Muted,
				height = 16,
				order = 3,
				textSize = 10
			})
			local grid, setColumns = kit.grid(view.Card, 2, 42, 8, 4)
			view.SetColumns = setColumns

			for j, v4 in ipairs({
				"GuitarLead",
				"GuitarRhythm",
				"Bass",
				"Drum",
				"Piano",
				"Keyboard"
			}) do
				local frame3 = kit.new(
					"Frame",
					{ BackgroundColor3 = colors.Surface2, BorderSizePixel = 0, LayoutOrder = j },
					grid
				)
				kit.corner(frame3, 8)
				local label2 = kit.label(frame3, v[v4], {
					color = colors.Muted,
					height = 14,
					regular = true,
					textSize = 10
				})
				label2.Position = UDim2.fromOffset(10, 5)
				label2.Size = UDim2.new(1, -86, 0, 14)
				local label3 = kit.label(frame3, "-", {
					bold = true,
					height = 16,
					textSize = 12,
					truncate = true
				})
				label3.Position = UDim2.fromOffset(10, 20)
				label3.Size = UDim2.new(1, -86, 0, 16)
				local button = kit.button(frame3, "Release", {
					base = colors.Surface3,
					sizeUDim = UDim2.fromOffset(62, 26),
					textSize = 11
				})
				button.AnchorPoint = Vector2.new(1, 0.5)
				button.Position = UDim2.new(1, -8, 0.5, 0)
				button.Visible = false

				if not data.Can("ReleaseInstrument") then
					lockButton(button) -- inferred equivalent call
				end

				local v5 = { Name = label3, Release = button, UserId = nil }
				button.Activated:Connect(function()
					if v5.UserId then
						data.Act("ReleaseInstrument", v5.UserId)
					end
				end)
				view.Slots[v4] = v5
			end

			local grid2 = kit.grid(view.Card, 2, 36, 8, 5)
			local button = kit.button(grid2, "Stop Session", { order = 1, height = 36 })
			kit.armConfirm(button, "Stop Session", "Confirm stop?", function()
				data.Act("StopStudio", id)
			end)
			local button2 = kit.button(grid2, "Reset Studio", {
				color = colors.Danger,
				order = 2,
				height = 36
			})
			kit.armConfirm(button2, "Reset Studio", "Confirm reset?", function()
				data.Act("ResetStudio", id)
			end)

			if not data.Can("StopStudio") then
				lockButton(button) -- inferred equivalent call
			end

			if not data.Can("ResetStudio") then
				lockButton(button2) -- inferred equivalent call
			end

			return view
		end

		local function updateView(data2, studio)
			local flag = false

			for _, session in ipairs(studio.Sessions) do
				if session.Stuck then
					flag = true
				end
			end

			kit.clear(data2.Badges)

			if flag then
				kit.badge(data2.Badges, "STUCK", colors.Danger, 1)
			elseif #studio.Sessions > 0 then
				kit.badge(data2.Badges, "PLAYING", colors.Ok, 1)
			else
				kit.badge(data2.Badges, "IDLE", colors.Muted, 1)
			end

			if studio.Backing then
				kit.badge(data2.Badges, "BACKING TRACK", colors.Info, 2)
			end

			if studio.RoomHost then
				kit.badge(data2.Badges, "ROOM: " .. string.upper(studio.RoomHost), colors.Purple, 3)
			end

			kit.clear(data2.Sessions)

			if #studio.Sessions == 0 then
				kit.label(data2.Sessions, "No active song session", {
					color = colors.Muted,
					order = 1,
					regular = true,
					textSize = 12
				})
			end

			for i, session in ipairs(studio.Sessions) do
				local frame2 = kit.new(
					"Frame",
					{
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						LayoutOrder = i,
						Size = UDim2.new(1, 0, 0, 0)
					},
					data2.Sessions
				)
				kit.list(frame2, 4)
				kit.label(frame2, tostring(session.SongName or session.Song), {
					bold = true,
					height = 18,
					order = 1,
					textSize = 13,
					truncate = true
				})
				local v4 = math.max(0, session.Elapsed or 0)
				local v5 = session.Duration and session.Duration > 0 and v4 / session.Duration or 0
				kit.progress(frame2, v5, session.Stuck and colors.Danger or colors.Accent, 2)
				local v6 = session.Duration and kit.clock(v4) .. " / " .. kit.clock(session.Duration) or kit.clock(v4)

				if session.Stuck then
					v6 ..= "  -  past the song length, session may be stuck"
				end

				kit.label(frame2, v6, {
					color = session.Stuck and colors.Danger or colors.Muted,
					height = 14,
					order = 3,
					regular = true,
					textSize = 11
				})
			end

			for _, slot in ipairs(studio.Slots) do
				local slot2 = data2.Slots[slot.Type]

				if not slot2 then
					continue
				end

				slot2.UserId = slot.UserId

				if slot.Kind == "Player" then
					slot2.Name.Text = tostring(slot.Name)
					slot2.Name.TextColor3 = colors.Text
					slot2.Release.Visible = true
				else
					if slot.Kind == "Auto" then
						slot2.Name.Text = "Auto (bot)"
						slot2.Name.TextColor3 = colors.Info
					else
						slot2.Name.Text = "Empty"
						slot2.Name.TextColor3 = colors.Muted
					end

					slot2.Release.Visible = false
				end
			end
		end

		local function applyLayout()
			for _, v4 in pairs(v3) do
				v4.SetColumns(data.Compact() and 1 or 2)
			end
		end
		data.LayoutChanged.Event:Connect(applyLayout)

		function v2.Refresh()
			count += 1
			local v4 = count
			task.spawn(function()
				local query = data.Query("Studios")

				if v4 ~= count or typeof(query) ~= "table" or query.Throttled or not query.Studios then
					return
				end

				emptyState.Visible = #query.Studios == 0
				emptyState.Text = "No studios registered"

				local idSet = {}

				for i, studio in ipairs(query.Studios) do
					idSet[studio.Id] = true
					local v5 = v3[studio.Id]

					if not v5 then
						v5 = createView(studio.Id, i)
						v3[studio.Id] = v5
						v5.SetColumns(data.Compact() and 1 or 2)
					end

					updateView(v5, studio)
				end

				for k, v5 in pairs(v3) do
					if idSet[k] then
						continue
					end

					v5.Card:Destroy()
					v3[k] = nil
				end
			end)
		end

		function v2.OnShow()
			applyLayout()
			v2.Refresh()
		end

		return v2
	end
}