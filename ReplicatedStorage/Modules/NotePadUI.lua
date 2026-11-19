local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TabsSkin = require(script.Parent.TabsSkin)

local NotePadUI = {}

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v2 = v and 316 or 360
local v3 = v and 220 or 290
local v4 = { 12, 14, 16, 18, 20, 24, 28 }
local v5 = { 0, 0.35, 0.6 }

local Dark = TabsSkin.Palettes.Dark
local FontLabel = TabsSkin.FontLabel
local FontBody = TabsSkin.FontBody
local RobotoMono = Enum.Font.RobotoMono

local flag = false
local notePadGui = nil
local root = nil
local panel = nil
local body = nil
local title = nil
local pageRow = nil
local textArea = nil
local scroll = nil
local input = nil
local footer = nil
local status = nil
local count = nil
local clearButton = nil
local menuButton = nil
local v6 = nil
local grip = nil
local uiStroke = nil
local sub = nil
local subTitle = nil
local subMsg = nil
local subContent = nil
local backButton = nil
local refreshButton = nil
local v7 = {}

local pages = { "", "", "", "", "" }
local dirty = {}
local page = 1
local loadState = "idle"
local v8 = false
local flag2 = false
local count2 = 0
local v9 = false
local count3 = 0
local notePadRequest = nil
local v10 = 0
local v11 = v and 2 or 3
local v12 = 1
local vector2 = Vector2.new(v2, v3)
local flag3 = false
local fn

local subView = nil
local count4 = 0
local v13 = nil
local count5 = 0

local fn2

local function viewport() -- 3 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
end

local function corner(parent, p) -- 6 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = parent
end

local function trim(value) -- 2 equivalent calls inferred from this helper
	return string.match(value or "", "^%s*(.-)%s*$") or ""
end

local function relTime(t)
	if type(t) ~= "number" then
		return ""
	end

	local v14 = os.time() - t

	if v14 < 60 then
		return "just now"
	end

	if v14 < 3600 then
		return math.floor(v14 / 60) .. "m ago"
	end

	if v14 < 86400 then
		return math.floor(v14 / 3600) .. "h ago"
	end

	return math.floor(v14 / 86400) .. "d ago"
end

local function paintButton(instance)
	local on = instance:GetAttribute("On") == true
	local hover = instance:GetAttribute("Hover") == true

	if instance:GetAttribute("Danger") == true then
		instance.BackgroundColor3 = hover and Color3.fromRGB(196, 46, 40) or Color3.fromRGB(160, 34, 30)
		instance.TextColor3 = Color3.fromRGB(236, 230, 216)
	else
		instance.BackgroundColor3 = on and Dark.Accent or hover and Dark.ButtonHi or Dark.Button
		instance.TextColor3 = on and Dark.Stroke or Dark.Text
	end

	local noteIcon = instance:FindFirstChild("NoteIcon")

	if noteIcon then
		TabsSkin.tint(noteIcon, instance.TextColor3)
	end
end

local function mkButton(parent, text, p, p2, value, options)
	local v14 = options or {}
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Text = text
	textButton.Font = FontLabel
	textButton.TextSize = v and 14 or 16
	textButton.Size = UDim2.fromOffset(p, p2)
	textButton.LayoutOrder = value or 0
	textButton.BorderSizePixel = 0
	textButton.Parent = parent
	corner(textButton, 2) -- inferred equivalent call
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 1
	uiStroke2.Transparency = 0.3
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Color = v14.danger and Color3.fromRGB(60, 12, 10) or Dark.Border
	uiStroke2.Parent = textButton

	if v14.danger then
		textButton:SetAttribute("Danger", true)
	end

	local noteIcon = v14.icon and TabsSkin.icon(textButton, v14.icon, v and 13 or 15, Dark.Text)

	if noteIcon then
		noteIcon.Name = "NoteIcon"
		noteIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		noteIcon.Position = UDim2.fromScale(0.5, 0.5)
	end

	if UserInputService.MouseEnabled then
		textButton.MouseEnter:Connect(function()
			textButton:SetAttribute("Hover", true)
			paintButton(textButton)
		end)
		textButton.MouseLeave:Connect(function()
			textButton:SetAttribute("Hover", false)
			paintButton(textButton)
		end)
	end

	paintButton(textButton)
	return textButton
end

local function mkLabel(parent, text, textSize, textColor, p, p2) -- 8 equivalent calls inferred from this helper
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = p or FontBody
	textLabel.Text = text
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.TextXAlignment = p2 or Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = parent
	return textLabel
end

local function setStatus(text, p) -- 11 equivalent calls inferred from this helper
	if not status then
		return
	end

	status.Text = text
	status.TextColor3 = p and Dark.Warn or Dark.Dim
end

local function updateCount() -- 3 equivalent calls inferred from this helper
	if not count then
		return
	end

	local v14 = utf8.len(pages[page]) or #pages[page]
	count.Text = string.format("%d / %d", v14, 3000)
	count.TextColor3 = v14 >= 3000 and Dark.Warn or Dark.Dim
end

local function setText(text) -- 4 equivalent calls inferred from this helper
	flag2 = true
	input.Text = text
	flag2 = false
	updateCount() -- inferred equivalent call

	if fn then
		fn()
	end
end

local function updateEditable() -- 5 equivalent calls inferred from this helper
	if not input then
		return
	end

	local textEditable = loadState == "ready"
	input.TextEditable = textEditable

	if not textEditable and input:IsFocused() then
		input:ReleaseFocus()
	end

	input.PlaceholderText = textEditable and "Write your notes here...\nExample:  A S D F  |  Q W E R" or ""
end

local function firstEmptyPage()
	for i = 1, 5 do
		if pages[i] == "" and not dirty[i] then
			return i
		end
	end

	return nil
end

local function remote() -- 1 equivalent call inferred from this helper
	if notePadRequest then
		return notePadRequest
	end

	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
		or ReplicatedStorage:WaitForChild("RemoteEvents", 5)
	notePadRequest = remoteEvents and remoteEvents:WaitForChild("NotePadRequest", 10) or nil
	return notePadRequest
end

local function invoke(...)
	local notePadRequest2 = remote() -- inferred equivalent call

	if not notePadRequest2 then
		return false, nil
	end

	local v14 = table.pack(...)
	return pcall(function()
		return notePadRequest2:InvokeServer(table.unpack(v14, 1, v14.n))
	end)
end

local function call(p, ...)
	local v14, v15 = invoke(p, ...)

	if v14 and type(v15) == "table" and v15.ok == false and v15.err == "Please wait a moment" then
		task.wait(0.7)
		v14, v15 = invoke(p, ...)
	end

	if not v14 or type(v15) ~= "table" then
		return nil, "Could not reach the server"
	end

	if v15.ok then
		return v15
	end

	return nil, (tostring(v15.err or "Something went wrong"))
end

local function loadPages() -- 2 equivalent calls inferred from this helper
	if loadState == "loading" then
		return
	end

	loadState = "loading"
	setStatus("Loading...", false) -- inferred equivalent call
	updateEditable() -- inferred equivalent call
	task.spawn(function()
		local v14, v15 = invoke("Get")

		if v14 and type(v15) == "table" and v15.ok and type(v15.pages) == "table" then
			for i = 1, 5 do
				pages[i] = type(v15.pages[i]) == "string" and v15.pages[i] or ""
			end

			dirty = {}
			loadState = "ready"
			setText(pages[page]) -- inferred equivalent call
			setStatus("Saved", false) -- inferred equivalent call
		else
			loadState = "offline"
			setStatus("Offline - tap here to retry", true) -- inferred equivalent call
		end

		updateEditable() -- inferred equivalent call
	end)
end

local function fn3()
	if v9 or loadState ~= "ready" or next(dirty) == nil then
		return
	end

	v9 = true
	task.spawn(function()
		while true do
			local v14 = loadState == "ready" and next(dirty)

			if not v14 then
				break
			end

			local v15 = pages[v14]
			local v16, v17 = invoke("Save", v14, v15)

			if v16 and type(v17) == "table" and v17.ok then
				count3 = 0

				if pages[v14] == v15 then
					dirty[v14] = nil
				end
			elseif (v16 and type(v17) == "table" and v17.err or nil) ~= "Please wait a moment" then
				count3 += 1

				if count3 >= 3 then
					count3 = 0

					if not status then
						break
					end

					status.Text = "Not saved - will retry on next edit"
					status.TextColor3 = Dark.Warn or Dark.Dim
					break
				end
			end

			task.wait(1.1)
		end

		v9 = false

		if next(dirty) == nil and loadState == "ready" then
			setStatus("Saved", false) -- inferred equivalent call
		end
	end)
end

local function scheduleSave() -- 2 equivalent calls inferred from this helper
	count2 += 1
	local v14 = count2
	setStatus("Editing...", false) -- inferred equivalent call
	task.delay(1.5, function()
		if v14 == count2 then
			fn3()
		end
	end)
end

local function fn4(p): boolean
	local lastTime = os.clock()
	fn3()

	while next(dirty) ~= nil and os.clock() - lastTime < p do
		if loadState ~= "ready" then
			return false
		end

		task.wait(0.2)
		fn3()
	end

	return next(dirty) == nil
end

local function fn5(text, p)
	count5 += 1
	local v14 = count5

	if subMsg then
		subMsg.Text = text
		subMsg.TextColor3 = p and Dark.Warn or Dark.Accent
	end

	setStatus(text, p) -- inferred equivalent call
	task.delay(4, function()
		if count5 ~= v14 then
			return
		end

		if subMsg then
			subMsg.Text = ""
		end

		if loadState == "ready" then
			setStatus(next(dirty) == nil and "Saved" or "Editing...", false) -- inferred equivalent call
		end
	end)
end

local function ensureCaretVisible() -- 2 equivalent calls inferred from this helper
	if flag3 then
		return
	end

	flag3 = true
	task.defer(function()
		task.wait()
		flag3 = false

		if not (input and scroll and input:IsFocused()) then
			return
		end

		local cursorPosition = input.CursorPosition

		if cursorPosition < 1 then
			return
		end

		local width = math.max(20, input.AbsoluteSize.X - 12)
		local success, result, v14 = pcall(function()
			local font = Font.fromEnum(RobotoMono)
			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = string.sub(input.Text, 1, cursorPosition - 1) .. "|"
			getTextBoundsParams.Font = font
			getTextBoundsParams.Size = input.TextSize
			getTextBoundsParams.Width = width
			local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)
			local getTextBoundsParams2 = Instance.new("GetTextBoundsParams")
			getTextBoundsParams2.Text = "|"
			getTextBoundsParams2.Font = font
			getTextBoundsParams2.Size = input.TextSize
			getTextBoundsParams2.Width = width
			return textBoundsAsync, TextService:GetTextBoundsAsync(getTextBoundsParams2).Y
		end)

		if not (success and result) then
			return
		end

		local y = scroll.AbsoluteSize.Y
		local y2 = scroll.CanvasPosition.Y
		local v15 = result.Y + 6
		local v16 = v15 - v14

		if y2 + y - 4 < v15 then
			scroll.CanvasPosition = Vector2.new(0, v15 - y + 8)
		elseif v16 < y2 + 2 then
			scroll.CanvasPosition = Vector2.new(0, (math.max(0, v16 - 6)))
		end
	end)
end

local function clampRoot()
	if not root then
		return
	end

	local v14 = viewport() -- inferred equivalent call
	local offset = root.Size.X.Offset
	local v15 = math.clamp(root.Position.X.Offset, 90 - offset, v14.X - 90)
	local v16 = math.clamp(root.Position.Y.Offset, 0, (math.max(0, v14.Y - 44)))
	root.Position = UDim2.fromOffset(v15, v16)
end

local function resizeTo(value, value2)
	local v14 = viewport() -- inferred equivalent call
	local v15 = math.clamp(value, 316, (math.max(316, v14.X - 8)))
	local v16 = math.clamp(value2, 190, (math.max(190, v14.Y - 60)))
	vector2 = Vector2.new(v15, v16)
	root.Size = UDim2.fromOffset(v15, v8 and 42 or v16)
end

local function applyFont() -- 2 equivalent calls inferred from this helper
	input.TextSize = v4[v11]

	if fn then
		fn()
	end

	ensureCaretVisible() -- inferred equivalent call
end

local function applyGhost() -- 2 equivalent calls inferred from this helper
	local backgroundTransparency = v5[v12]
	panel.BackgroundTransparency = backgroundTransparency
	textArea.BackgroundTransparency = backgroundTransparency
end

local function fn6()
	local v14 = subView ~= nil
	pageRow.Visible = not (v8 or v14)
	textArea.Visible = not (v8 or v14)
	footer.Visible = not (v8 or v14)
	sub.Visible = not v8 and v14
	grip.Visible = not v8
end

local function applyMinimized() -- 1 equivalent call inferred from this helper
	root.Size = UDim2.fromOffset(vector2.X, v8 and 42 or vector2.Y)
	v6:SetAttribute("On", v8)
	paintButton(v6)
	fn6()
end

local function fn7(p)
	page = p
	setText(pages[p]) -- inferred equivalent call
	scroll.CanvasPosition = Vector2.zero

	for i, v14 in ipairs(v7) do
		v14:SetAttribute("On", i == page)
		paintButton(v14)
	end
end

local function fn8(i)
	if i == page then
		return
	end

	fn7(i)
end

local function fn9()
	if not subContent then
		return
	end

	for _, child in ipairs(subContent:GetChildren()) do
		child:Destroy()
	end
end

local function fn10(p, text)
	count4 += 1
	subView = p

	if input and input:IsFocused() then
		input:ReleaseFocus()
	end

	subTitle.Text = text
	refreshButton.Visible = p == "list"
	subMsg.Text = ""
	fn9()
	fn6()
end

local function fn11()
	count4 += 1
	subView = nil
	fn9()
	fn6()
end

local function mkInfo(text, p)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = FontBody
	textLabel.TextSize = 14
	textLabel.TextWrapped = true
	textLabel.TextColor3 = p and Dark.Warn or Dark.Dim
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Position = UDim2.fromOffset(8, 8)
	textLabel.Size = UDim2.new(1, -16, 0, 60)
	textLabel.Text = text
	textLabel.Parent = subContent
	return textLabel
end

local function mkScrollFrame(parent, p)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.BackgroundColor3 = Dark.Inset
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Size = UDim2.fromScale(1, 1)
	scrollingFrame.CanvasSize = UDim2.new()
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.ScrollBarImageColor3 = Dark.Border
	scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scrollingFrame.Parent = parent
	corner(scrollingFrame, 3) -- inferred equivalent call
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 4)
	local udim2 = UDim.new(0, 4)
	uiPadding.PaddingLeft = udim
	uiPadding.PaddingRight = udim2
	local udim3 = UDim.new(0, 4)
	local udim4 = UDim.new(0, 4)
	uiPadding.PaddingTop = udim3
	uiPadding.PaddingBottom = udim4
	uiPadding.Parent = scrollingFrame

	if not p then
		return scrollingFrame
	end

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.Parent = scrollingFrame

	return scrollingFrame
end

local function mkRow(parent, layoutOrder, text, text2, onActivated)
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Text = ""
	textButton.LayoutOrder = layoutOrder
	textButton.BackgroundColor3 = Dark.Button
	textButton.BorderSizePixel = 0
	textButton.Size = UDim2.new(1, 0, 0, 40)
	textButton.Parent = parent
	corner(textButton, 2) -- inferred equivalent call
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 1
	uiStroke2.Transparency = 0.3
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Color = Dark.Border
	uiStroke2.Parent = textButton
	local title2 = mkLabel(textButton, text, 16, Dark.Text, FontLabel) -- inferred equivalent call
	title2.Name = "Title"
	title2.Position = UDim2.fromOffset(8, 3)
	title2.Size = UDim2.new(1, -16, 0, 20)
	local meta = mkLabel(textButton, text2, 12, Dark.Dim, FontBody) -- inferred equivalent call
	meta.Name = "Meta"
	meta.Position = UDim2.fromOffset(8, 22)
	meta.Size = UDim2.new(1, -16, 0, 14)

	if UserInputService.MouseEnabled then
		textButton.MouseEnter:Connect(function()
			textButton.BackgroundColor3 = Dark.ButtonHi
		end)
		textButton.MouseLeave:Connect(function()
			textButton.BackgroundColor3 = Dark.Button
		end)
	end

	textButton.Activated:Connect(onActivated)
	return textButton
end

local function fn12(p)
	v13 = p
	fn10("list", p == "mine" and "MY PUBLISHED" or "COMMUNITY")
	local v14 = count4
	mkInfo("Loading...")
	task.spawn(function()
		local v15, text = call(p == "mine" and "PubMine" or "PubList")

		if v14 ~= count4 then
			return
		end

		fn9()

		if not v15 then
			mkInfo(text, true)
			return
		end

		local items = v15.items

		if type(items) ~= "table" or #items == 0 then
			mkInfo(p == "mine" and "You have not published any notes yet.\nUse MENU > PUBLISH PAGE." or "No community notes yet.\nBe the first: MENU > PUBLISH PAGE.")

			return
		end

		local parent = mkScrollFrame(subContent, true)

		for i, item in ipairs(items) do
			local v16 = "by " .. tostring(item.Author) .. "  -  " .. relTime(item.T)

			if item.Mine and p ~= "mine" then
				v16 ..= "  -  yours"
			end

			mkRow(parent, i, tostring(item.Title), v16, function()
				fn2(item.Id, p)
			end)
		end
	end)
end

fn2 = function(id, p)
	v13 = p
	fn10("view", "NOTE")
	local v14 = count4
	mkInfo("Loading...")
	task.spawn(function()
		local v15, v16 = call("PubGet", id)

		if v14 ~= count4 then
			return
		end

		fn9()

		if not v15 or type(v15.note) ~= "table" then
			mkInfo(v16 or "This note is no longer available", true)
			return
		end

		local note = v15.note
		local textLabel2 = mkLabel(subContent, tostring(note.Title), 18, Dark.Accent, FontLabel) -- inferred equivalent call
		textLabel2.Position = UDim2.fromOffset(2, 0)
		textLabel2.Size = UDim2.new(1, -4, 0, 22)
		local textLabel3 = mkLabel( -- inferred equivalent call
			subContent,
			"by " .. tostring(note.Author) .. "  -  " .. relTime(note.T),
			13,
			Dark.Dim,
			FontBody
		)
		textLabel3.Position = UDim2.fromOffset(2, 22)
		textLabel3.Size = UDim2.new(1, -4, 0, 16)

		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Position = UDim2.fromOffset(0, 42)
		frame.Size = UDim2.new(1, 0, 1, -74)
		frame.Parent = subContent
		local parent = mkScrollFrame(frame, false)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Font = RobotoMono
		textLabel.TextSize = v4[v11]
		textLabel.TextColor3 = Dark.Text
		textLabel.TextWrapped = true
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Top
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
		textLabel.Size = UDim2.new(1, 0, 0, 20)
		textLabel.Text = tostring(note.Text)
		textLabel.Parent = parent
		local uiPadding = Instance.new("UIPadding")
		local udim = UDim.new(0, 2)
		local udim2 = UDim.new(0, 2)
		uiPadding.PaddingLeft = udim
		uiPadding.PaddingRight = udim2
		uiPadding.Parent = textLabel

		local frame2 = Instance.new("Frame")
		frame2.BackgroundTransparency = 1
		frame2.AnchorPoint = Vector2.new(0, 1)
		frame2.Position = UDim2.new(0, 0, 1, 0)
		frame2.Size = UDim2.new(1, 0, 0, 28)
		frame2.Parent = subContent
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 6)
		uiListLayout.Parent = frame2

		mkButton(frame2, "COPY TO MY NOTES", 150, 26, 1).Activated:Connect(function()
			if loadState ~= "ready" then
				fn5("Your notes are not loaded yet", true)
				return
			end

			local v17 = firstEmptyPage()

			if not v17 then
				fn5("No empty page. Clear a page first.", true)
				return
			end

			pages[v17] = tostring(note.Text)
			dirty[v17] = true
			fn11()
			fn7(v17)
			fn3()
			fn5("Copied to page " .. v17)
		end)

		local flag4 = false
		local flag5 = false
		local text = note.Mine and "UNPUBLISH" or "REPORT"
		local v17 = mkButton(frame2, text, note.Mine and 100 or 84, 26, 2)
		v17.Activated:Connect(function()
			if flag5 then
				return
			end

			if flag4 then
				flag5 = true
				v17.Text = "..."
				task.spawn(function()
					local v18, text2 = call(note.Mine and "Unpublish" or "Report", id)
					flag5 = false
					flag4 = false

					if v18 then
						if note.Mine then
							if v14 == count4 then
								fn12("mine")
							end

							fn5("Note unpublished")
						else
							v17.Text = "REPORTED"
							fn5("Report sent. Thank you!")
						end
					else
						v17.Text = text
						fn5(text2, true)
					end
				end)
			else
				flag4 = true
				v17.Text = "SURE? " .. text
				task.delay(2.5, function()
					if flag4 and not flag5 then
						flag4 = false
						v17.Text = text
					end
				end)
			end
		end)
	end)
end

local function fn13()
	if loadState ~= "ready" then
		fn5("Your notes are not loaded yet", true)
		return
	end

	local v14 = page
	fn10("form", "PUBLISH PAGE " .. v14)
	local v15 = pages[v14]

	if not string.match(v15, "%S") then
		mkInfo("This page is empty. Write something first.", true)
		return
	end

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Size = UDim2.fromScale(1, 1)
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, 176)
	scrollingFrame.ScrollBarThickness = 5
	scrollingFrame.ScrollBarImageColor3 = Dark.Border
	scrollingFrame.Parent = subContent
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = FontBody
	textLabel.TextSize = 13
	textLabel.TextWrapped = true
	textLabel.TextColor3 = Dark.Dim
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Position = UDim2.fromOffset(2, 0)
	textLabel.Size = UDim2.new(1, -8, 0, 56)
	textLabel.Text = "Everyone can read and copy this page. Reported notes get hidden. You can unpublish it any time from MENU > MY PUBLISHED."
	textLabel.Parent = scrollingFrame
	local textLabel2 = mkLabel(scrollingFrame, "Title", 14, Dark.Text, FontLabel) -- inferred equivalent call
	textLabel2.Position = UDim2.fromOffset(2, 62)
	textLabel2.Size = UDim2.new(1, -8, 0, 18)
	local textBox = Instance.new("TextBox")
	textBox.BackgroundColor3 = Dark.Inset
	textBox.BorderSizePixel = 0
	textBox.ClearTextOnFocus = false
	textBox.Font = RobotoMono
	textBox.TextSize = 15
	textBox.TextColor3 = Dark.Text
	textBox.PlaceholderText = "Give your note a title"
	textBox.PlaceholderColor3 = Dark.Dim
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Position = UDim2.fromOffset(2, 82)
	textBox.Size = UDim2.new(1, -8, 0, 28)
	textBox.Parent = scrollingFrame
	corner(textBox, 2) -- inferred equivalent call
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 1
	uiStroke2.Color = Dark.Border
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Parent = textBox
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 6)
	local udim2 = UDim.new(0, 6)
	uiPadding.PaddingLeft = udim
	uiPadding.PaddingRight = udim2
	uiPadding.Parent = textBox
	local v16 = ""

	for k in string.gmatch(v15, "[^\n]+") do
		local v17 = trim(k) -- inferred equivalent call

		if v17 ~= "" then
			v16 = v17
			break
		end
	end

	local text2 = string.gsub(v16, "%c", "")

	if (utf8.len(text2) or 0) > 24 then
		text2 = string.sub(text2, 1, (utf8.offset(text2, 25) or #text2 + 1) - 1)
	end

	textBox.Text = text2
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = textBox.Text
		local v17 = utf8.len(text)

		if v17 and v17 > 24 then
			textBox.Text = string.sub(text, 1, utf8.offset(text, 25) - 1)
		end
	end)

	local v17 = mkButton(scrollingFrame, "PUBLISH", 110, 28, 1)
	v17.Position = UDim2.fromOffset(2, 122)
	local v18 = mkButton(scrollingFrame, "CANCEL", 90, 28, 2)
	v18.Position = UDim2.fromOffset(120, 122)
	v18.Activated:Connect(function()
		fn11()
	end)
	local flag4 = false
	local v19 = count4
	v17.Activated:Connect(function()
		if flag4 then
			return
		end

		local v20 = trim(textBox.Text) -- inferred equivalent call

		if v20 == "" then
			fn5("Enter a title first", true)
			return
		end

		flag4 = true
		v17.Text = "..."
		task.spawn(function()
			if fn4(8) then
				local v21, text = call("Publish", v14, v20)
				flag4 = false
				v17.Text = "PUBLISH"

				if not v21 then
					fn5(text, true)
					return
				end

				if v19 == count4 then
					fn12("mine")
				end

				fn5("Published to the community!")
			else
				flag4 = false
				v17.Text = "PUBLISH"
				fn5("Could not save your notes yet. Try again.", true)
			end
		end)
	end)
end

local function renderShare(p)
	if subView ~= "share" then
		return
	end

	fn9()
	local v14 = {}

	for _, v15 in ipairs(Players:GetPlayers()) do
		if v15 ~= Players.LocalPlayer or RunService:IsStudio() then
			v14[#v14 + 1] = v15
		end
	end

	table.sort(v14, function(a, b): boolean
		return string.lower(a.DisplayName) < string.lower(b.DisplayName)
	end)

	if #v14 == 0 then
		mkInfo("No other players in this server.")
		return
	end

	local parent = mkScrollFrame(subContent, true)
	local flag4 = false

	for i, v15 in ipairs(v14) do
		local v16 = nil
		v16 = mkRow(parent, i, v15.DisplayName, "@" .. v15.Name .. "  -  tap to send", function()
			if flag4 then
				return
			end

			flag4 = true
			v16.Meta.Text = "Sending..."
			task.spawn(function()
				local v17, v18

				if fn4(8) then
					v17, v18 = call("ShareSend", p, v15.UserId)
				else
					v18 = "Could not save your notes yet. Try again."
				end

				flag4 = false

				if v17 then
					v16.Meta.Text = "Sent!"
					fn5("Sent to " .. v15.DisplayName)
				else
					v16.Meta.Text = "@" .. v15.Name .. "  -  tap to send"
					fn5(v18, true)
				end
			end)
		end)
	end
end

local function fn14()
	if loadState ~= "ready" then
		fn5("Your notes are not loaded yet", true)
		return
	end

	local v14 = page
	fn10("share", "SHARE PAGE " .. v14)

	if string.match(pages[v14], "%S") then
		renderShare(v14)
	else
		mkInfo("This page is empty. Write something first.", true)
	end
end

local function menuItems()
	return {
		{
			Id = "COMMUNITY",
			Text = "COMMUNITY",
			Icon = "people",
			Run = function()
				fn12("community")
			end
		},
		{
			Id = "PUBLISH",
			Text = "PUBLISH PAGE",
			Icon = "publish",
			Run = function()
				fn13()
			end
		},
		{
			Id = "SHARE",
			Text = "SHARE PAGE",
			Icon = "send",
			Run = function()
				fn14()
			end
		},
		{
			Id = "MINE",
			Text = "MY PUBLISHED",
			Icon = "folder",
			Run = function()
				fn12("mine")
			end
		}
	}
end

local function build()
	if flag then
		return
	end

	flag = true

	notePadGui = Instance.new("ScreenGui")
	notePadGui.Name = "NotePadGui"
	notePadGui.ResetOnSpawn = false
	notePadGui.IgnoreGuiInset = true
	notePadGui.DisplayOrder = 39
	notePadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	notePadGui.Enabled = false
	notePadGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	local v14 = viewport() -- inferred equivalent call
	local v15 = math.min(v2, v14.X - 16)
	local v16 = math.min(v3, v14.Y - 90)
	vector2 = Vector2.new(v15, v16)

	root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Size = UDim2.fromOffset(v15, v16)
	root.Position = UDim2.fromOffset(math.max(8, v14.X - v15 - 16), v and 44 or 72)
	root.Parent = notePadGui

	panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.fromScale(1, 1)
	panel.BackgroundColor3 = Dark.Panel
	panel.BorderSizePixel = 0
	panel.Parent = root
	corner(panel, 3) -- inferred equivalent call
	uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Dark.Stroke
	uiStroke.Parent = panel

	local newUIDecorHolder = Instance.new("Frame")
	newUIDecorHolder.Name = "NewUIDecorHolder"
	newUIDecorHolder.BackgroundTransparency = 1
	newUIDecorHolder.BorderSizePixel = 0
	newUIDecorHolder.Active = false
	newUIDecorHolder.Size = UDim2.fromScale(1, 1)
	newUIDecorHolder.ZIndex = 50
	newUIDecorHolder.Parent = root
	pcall(TabsSkin.decorate, newUIDecorHolder, "Dark", { "NOTE", "BLOXBAND" })

	body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.new(0, 8, 0, 6)
	body.Size = UDim2.new(1, -16, 1, -14)
	body.Parent = panel

	title = Instance.new("Frame")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 28)
	title.Parent = body

	local right = Instance.new("Frame")
	right.Name = "Right"
	right.BackgroundTransparency = 1
	right.AnchorPoint = Vector2.new(1, 0.5)
	right.Position = UDim2.new(1, 0, 0.5, 0)
	right.Size = UDim2.fromOffset(234, 26)
	right.Parent = title
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.Parent = right

	local titleLabel = mkLabel(title, "NOTE", 18, Dark.Text, FontLabel) -- inferred equivalent call
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -240, 1, 0)

	menuButton = mkButton(right, "MENU", 74, 26, 1)
	menuButton.Name = "MenuButton"
	local v17 = mkButton(right, "A-", 28, 26, 2)
	local v18 = mkButton(right, "A+", 28, 26, 3)
	local v19 = mkButton(right, "", 28, 26, 4, { icon = "theme" })
	v6 = mkButton(right, "", 28, 26, 5, { icon = "minimize" })
	local v20 = mkButton(right, "", 28, 26, 6, { icon = "close", danger = true })

	pageRow = Instance.new("Frame")
	pageRow.Name = "PageRow"
	pageRow.BackgroundTransparency = 1
	pageRow.Position = UDim2.new(0, 0, 0, 34)
	pageRow.Size = UDim2.new(1, 0, 0, 26)
	pageRow.Parent = body
	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Padding = UDim.new(0, 4)
	uiListLayout2.Parent = pageRow

	for i = 1, 5 do
		local v21 = mkButton(pageRow, tostring(i), 32, 24, i)
		v21:SetAttribute("On", i == page)
		paintButton(v21)
		v7[i] = v21
		v21.Activated:Connect(function()
			fn8(i)
		end)
	end

	status = Instance.new("TextButton")
	status.Name = "Status"
	status.AutoButtonColor = false
	status.BackgroundTransparency = 1
	status.Font = FontBody
	status.TextSize = 13
	status.Text = ""
	status.TextColor3 = Dark.Dim
	status.TextXAlignment = Enum.TextXAlignment.Right
	status.TextTruncate = Enum.TextTruncate.AtEnd
	status.AnchorPoint = Vector2.new(1, 0)
	status.Position = UDim2.new(1, 0, 0, 0)
	status.Size = UDim2.new(1, -186, 1, 0)
	status.Parent = pageRow
	status.Activated:Connect(function()
		if loadState == "offline" then
			if loadState == "loading" then
				return
			end

			loadState = "loading"
			setStatus("Loading...", false) -- inferred equivalent call
			updateEditable() -- inferred equivalent call
			task.spawn(function()
				local v21, v22 = invoke("Get")

				if v21 and type(v22) == "table" and v22.ok and type(v22.pages) == "table" then
					for i = 1, 5 do
						pages[i] = type(v22.pages[i]) == "string" and v22.pages[i] or ""
					end

					dirty = {}
					loadState = "ready"
					setText(pages[page]) -- inferred equivalent call
					setStatus("Saved", false) -- inferred equivalent call
				else
					loadState = "offline"
					setStatus("Offline - tap here to retry", true) -- inferred equivalent call
				end

				updateEditable() -- inferred equivalent call
			end)
		end
	end)

	textArea = Instance.new("Frame")
	textArea.Name = "TextArea"
	textArea.BackgroundColor3 = Dark.Inset
	textArea.BorderSizePixel = 0
	textArea.ClipsDescendants = true
	textArea.Position = UDim2.new(0, 0, 0, 66)
	textArea.Size = UDim2.new(1, 0, 1, -92)
	textArea.Parent = body
	corner(textArea, 3) -- inferred equivalent call
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 1
	uiStroke2.Color = Dark.Border
	uiStroke2.Transparency = 0.4
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Parent = textArea

	scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Dark.Border
	scroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scroll.Parent = textArea

	input = Instance.new("TextBox")
	input.Name = "Input"
	input.BackgroundTransparency = 1
	input.BorderSizePixel = 0
	input.MultiLine = true
	input.TextWrapped = true
	input.ClearTextOnFocus = false
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.TextYAlignment = Enum.TextYAlignment.Top
	input.Font = RobotoMono
	input.TextSize = v4[v11]
	input.TextColor3 = Dark.Text
	input.PlaceholderColor3 = Dark.Dim
	input.Text = ""
	input.Size = UDim2.new(1, 0, 0, 40)
	input.TextEditable = false
	input.Parent = scroll
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 6)
	uiPadding.PaddingRight = UDim.new(0, 6)
	uiPadding.PaddingTop = UDim.new(0, 6)
	uiPadding.PaddingBottom = UDim.new(0, 6)
	uiPadding.Parent = input

	fn = function()
		if not (input and scroll) then
			return
		end

		local y = scroll.AbsoluteSize.Y
		local width = math.max(20, input.AbsoluteSize.X - 12)

		local success, result = pcall(function()
			local font = Font.fromEnum(RobotoMono)
			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = input.Text .. "|"
			getTextBoundsParams.Font = font
			getTextBoundsParams.Size = input.TextSize
			getTextBoundsParams.Width = width
			local y2 = TextService:GetTextBoundsAsync(getTextBoundsParams).Y
			local getTextBoundsParams2 = Instance.new("GetTextBoundsParams")
			getTextBoundsParams2.Text = "|"
			getTextBoundsParams2.Font = font
			getTextBoundsParams2.Size = input.TextSize
			getTextBoundsParams2.Width = width
			return y2 + TextService:GetTextBoundsAsync(getTextBoundsParams2).Y
		end)

		local v21 = not (success and result) and 0 or result + 12

		input.Size = UDim2.new(1, 0, 0, (math.max(y, (math.ceil(v21)))))
	end
	scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn)
	task.defer(fn)

	footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundTransparency = 1
	footer.AnchorPoint = Vector2.new(0, 1)
	footer.Position = UDim2.new(0, 0, 1, 0)
	footer.Size = UDim2.new(1, -26, 0, 22)
	footer.Parent = body
	local parent = footer
	local dim = Dark.Dim
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = FontBody or FontBody
	textLabel.Text = "0 / " .. 3000
	textLabel.TextSize = 13
	textLabel.TextColor3 = dim
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = parent

	count = textLabel
	count.Name = "Count"
	count.Size = UDim2.new(0.5, 0, 1, 0)
	clearButton = mkButton(footer, "CLEAR PAGE", 98, 20, 1)
	clearButton.Name = "ClearButton"
	clearButton.AnchorPoint = Vector2.new(1, 0.5)
	clearButton.Position = UDim2.new(1, 0, 0.5, 0)
	clearButton.TextSize = v and 13 or 14

	sub = Instance.new("Frame")
	sub.Name = "Sub"
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0, 0, 0, 34)
	sub.Size = UDim2.new(1, 0, 1, -34)
	sub.Visible = false
	sub.Parent = body
	backButton = mkButton(sub, "BACK", 60, 24, 1)
	backButton.Name = "BackButton"
	refreshButton = mkButton(sub, "REFRESH", 74, 24, 2)
	refreshButton.Name = "RefreshButton"
	refreshButton.AnchorPoint = Vector2.new(1, 0)
	refreshButton.Position = UDim2.new(1, 0, 0, 0)
	refreshButton.Visible = false
	subTitle = mkLabel(sub, "", 16, Dark.Accent, FontLabel) -- inferred equivalent call
	subTitle.Name = "SubTitle"
	subTitle.Position = UDim2.fromOffset(66, 0)
	subTitle.Size = UDim2.new(1, -146, 0, 24)
	subMsg = mkLabel(sub, "", 13, Dark.Accent, FontBody) -- inferred equivalent call
	subMsg.Name = "SubMsg"
	subMsg.Position = UDim2.fromOffset(0, 28)
	subMsg.Size = UDim2.new(1, 0, 0, 16)
	subContent = Instance.new("Frame")
	subContent.Name = "SubContent"
	subContent.BackgroundTransparency = 1
	subContent.ClipsDescendants = true
	subContent.Position = UDim2.fromOffset(0, 48)
	subContent.Size = UDim2.new(1, 0, 1, -48)
	subContent.Parent = sub

	grip = Instance.new("TextButton")
	grip.Name = "Grip"
	grip.AutoButtonColor = false
	grip.Text = ""
	grip.BackgroundTransparency = 1
	grip.AnchorPoint = Vector2.new(1, 1)
	grip.Position = UDim2.new(1, -3, 1, -3)
	grip.Size = UDim2.fromOffset(22, 22)
	grip.ZIndex = 5
	grip.Parent = panel

	for i = 0, 2 do
		for j = 0, 2 - i do
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Dark.Dim
			frame.BorderSizePixel = 0
			frame.Active = false
			frame.Size = UDim2.fromOffset(2, 2)
			frame.Position = UDim2.fromOffset(17 - j * 5, 17 - i * 5)
			frame.ZIndex = 6
			frame.Parent = grip
		end
	end

	input:GetPropertyChangedSignal("Text"):Connect(function()
		if flag2 then
			return
		end

		local text = input.Text

		if text == pages[page] then
			return
		end

		local v21 = utf8.len(text)

		if v21 and v21 > 3000 then
			text = string.sub(text, 1, utf8.offset(text, 3001) - 1)
			flag2 = true
			input.Text = text
			flag2 = false
			input.CursorPosition = #text + 1
			setStatus("Limit reached (" .. 3000 .. ")", true) -- inferred equivalent call
		end

		pages[page] = text
		dirty[page] = true
		updateCount() -- inferred equivalent call
		fn()

		if loadState == "ready" then
			scheduleSave() -- inferred equivalent call
		end

		ensureCaretVisible() -- inferred equivalent call
	end)
	input:GetPropertyChangedSignal("CursorPosition"):Connect(ensureCaretVisible)
	input.Focused:Connect(ensureCaretVisible)
	input.FocusLost:Connect(function()
		fn3()
	end)

	menuButton.Activated:Connect(function()
		local success, result = pcall(function()
			return require(script.Parent:WaitForChild("TabsMenu", 5))
		end)

		if success and result then
			result.Toggle(menuButton, menuItems())
		else
			warn("[NOTE] gagal memuat TabsMenu:", result)
		end
	end)
	v17.Activated:Connect(function()
		v11 = math.max(1, v11 - 1)
		applyFont() -- inferred equivalent call
	end)
	v18.Activated:Connect(function()
		v11 = math.min(#v4, v11 + 1)
		applyFont() -- inferred equivalent call
	end)
	v19.Activated:Connect(function()
		v12 = v12 % #v5 + 1
		applyGhost() -- inferred equivalent call
	end)
	v6.Activated:Connect(function()
		v8 = not v8
		applyMinimized() -- inferred equivalent call
	end)
	v20.Activated:Connect(function()
		NotePadUI.Close()
	end)
	backButton.Activated:Connect(function()
		if subView == "view" and v13 then
			fn12(v13)
		else
			fn11()
		end
	end)
	refreshButton.Activated:Connect(function()
		if subView == "list" and v13 then
			fn12(v13)
		end
	end)
	clearButton.Activated:Connect(function()
		if loadState ~= "ready" then
			return
		end

		if v10 == 0 then
			v10 = os.clock()
			local v21 = v10
			clearButton.Text = "SURE? CLEAR"
			task.delay(2.5, function()
				if v10 == v21 then
					v10 = 0
					clearButton.Text = "CLEAR PAGE"
				end
			end)
		else
			v10 = 0
			clearButton.Text = "CLEAR PAGE"
			setText("") -- inferred equivalent call
			pages[page] = ""
			dirty[page] = true
			scheduleSave() -- inferred equivalent call
			fn3()
		end
	end)

	Players.PlayerAdded:Connect(function()
		if subView == "share" then
			renderShare(page)
		end
	end)
	Players.PlayerRemoving:Connect(function()
		if subView == "share" then
			task.defer(renderShare, page)
		end
	end)

	local v21 = nil
	local v22 = nil
	local v23 = nil
	title.InputBegan:Connect(function(input2)
		if
			input2.UserInputType == Enum.UserInputType.MouseButton1
			or input2.UserInputType == Enum.UserInputType.Touch
		then
			local position = input2.Position
			local vector2_2 = Vector2.new(root.Position.X.Offset, root.Position.Y.Offset)
			v21 = input2
			v22 = position
			v23 = vector2_2
		end
	end)
	local v24 = nil
	local v25 = nil
	local v26 = nil
	grip.InputBegan:Connect(function(input2)
		if
			input2.UserInputType == Enum.UserInputType.MouseButton1
			or input2.UserInputType == Enum.UserInputType.Touch
		then
			local position = input2.Position
			v24 = input2
			v25 = position
			v26 = vector2
		end
	end)
	local function tracks(p, input2): boolean -- 2 equivalent calls inferred from this helper
		if not p then
			return false
		end

		if p.UserInputType == Enum.UserInputType.Touch then
			return input2 == p
		end

		return input2.UserInputType == Enum.UserInputType.MouseMovement
	end

	UserInputService.InputChanged:Connect(function(input2)
		if v21 and tracks(v21, input2) then -- inferred equivalent call
			local v27 = input2.Position - v22
			root.Position = UDim2.fromOffset(v23.X + v27.X, v23.Y + v27.Y)
			clampRoot()
		elseif v24 and tracks(v24, input2) then -- inferred equivalent call
			local v27 = input2.Position - v25
			resizeTo(v26.X + v27.X, v26.Y + v27.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input2)
		if
			v21
			and (input2 == v21 or v21.UserInputType == Enum.UserInputType.MouseButton1 and input2.UserInputType == Enum.UserInputType.MouseButton1)
		then
			v21 = nil
		end

		if
			v24
			and (input2 == v24 or v24.UserInputType == Enum.UserInputType.MouseButton1 and input2.UserInputType == Enum.UserInputType.MouseButton1)
		then
			v24 = nil
		end
	end)

	UserInputService.InputBegan:Connect(function(input2, gameProcessed)
		if gameProcessed or not input then
			return
		end

		if
			(input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch)
			and input:IsFocused()
		then
			input:ReleaseFocus()
		end
	end)

	local success, result = pcall(function()
		return require(script.Parent.FreePlayScrollGuard)
	end)

	if success and result and result.Attach then
		result.Attach(notePadGui, function()
			return { root }
		end)
	end

	notePadGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampRoot)
	updateEditable() -- inferred equivalent call
	applyGhost() -- inferred equivalent call
	updateCount() -- inferred equivalent call
end

function NotePadUI.IsOpen()
	local v14 = flag

	if v14 then
		return not (notePadGui == nil) and notePadGui.Enabled
	end

	return v14
end

function NotePadUI.Open(): boolean
	build()
	notePadGui.Enabled = true
	clampRoot()

	if loadState == "idle" or loadState == "offline" then
		loadPages() -- inferred equivalent call
	end

	return true
end

function NotePadUI.Close()
	if not (notePadGui and notePadGui.Enabled) then
		return
	end

	if input and input:IsFocused() then
		input:ReleaseFocus()
	end

	if subView then
		fn11()
	end

	fn3()
	notePadGui.Enabled = false
end

function NotePadUI.Toggle()
	if NotePadUI.IsOpen() then
		NotePadUI.Close()
	else
		NotePadUI.Open()
	end
end

function NotePadUI.Flash()
	if flag and uiStroke then
		uiStroke.Color = Dark.Accent
		TweenService:Create(uiStroke, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
			Color = Dark.Stroke
		}):Play()
	end
end

function NotePadUI.AcceptOffer(p)
	if type(p) ~= "table" or type(p.Id) ~= "string" then
		return false, "Invalid offer"
	end

	build()

	if loadState ~= "ready" then
		if loadState ~= "loading" then
			loadPages() -- inferred equivalent call
		end

		local lastTime = os.clock()

		while loadState == "loading" and os.clock() - lastTime < 10 do
			task.wait(0.2)
		end

		if loadState ~= "ready" then
			return false, "Your notes could not be loaded. Try again in a moment."
		end
	end

	local v14 = firstEmptyPage()

	if not v14 then
		return false, "No empty page. Open NOTE and clear a page first."
	end

	local v15, v16 = call("ShareAccept", p.Id)

	if not v15 then
		return false, v16
	end

	pages[v14] = tostring(v15.text or "")
	dirty[v14] = true
	NotePadUI.Open()

	if subView then
		fn11()
	end

	fn7(v14)
	fn3()
	return true, v14, (tostring(v15.title or ""))
end

function NotePadUI.DeclineOffer(p)
	if type(p) == "table" and type(p.Id) == "string" then
		task.spawn(invoke, "ShareDecline", p.Id)
	end
end

function NotePadUI._debug()
	return {
		gui = notePadGui,
		root = root,
		textBox = input,
		scroll = scroll,
		loadState = loadState,
		page = page,
		pages = pages,
		dirty = dirty,
		subView = subView,
		subContent = subContent,
		menuButton = menuButton
	}
end

return NotePadUI