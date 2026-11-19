game:GetService("TweenService")

local UIKit = {}

UIKit.Colors = {
	Bg = Color3.fromRGB(12, 13, 17),
	Surface = Color3.fromRGB(20, 21, 27),
	Surface2 = Color3.fromRGB(30, 31, 40),
	Surface3 = Color3.fromRGB(42, 44, 56),
	Border = Color3.fromRGB(48, 50, 63),
	Text = Color3.fromRGB(238, 239, 244),
	Muted = Color3.fromRGB(144, 148, 165),
	Accent = Color3.fromRGB(255, 149, 51),
	AccentDim = Color3.fromRGB(64, 45, 26),
	AccentText = Color3.fromRGB(255, 149, 51),
	Selected = Color3.fromRGB(42, 44, 56),
	Strip = Color3.fromRGB(42, 44, 56),
	Glow = Color3.fromRGB(255, 149, 51),
	Ok = Color3.fromRGB(88, 214, 141),
	Danger = Color3.fromRGB(255, 92, 92),
	DangerDim = Color3.fromRGB(70, 32, 36),
	Info = Color3.fromRGB(96, 165, 250),
	Warn = Color3.fromRGB(250, 204, 21),
	Purple = Color3.fromRGB(176, 140, 255)
}

local colors = UIKit.Colors

UIKit.FontRegular = Enum.Font.Highway
UIKit.FontMedium = Enum.Font.Highway
UIKit.FontBold = Enum.Font.Highway

local success, result = pcall(function()
	return require(script.Parent.Parent:WaitForChild("LaptopUI"):WaitForChild("Retro"))
end)

if not success then
	result = nil
end

local v = {
	Cancel = function() end,
	Play = function() end,
	Pause = function() end,
	Destroy = function() end,
	Completed = {
		Connect = function()
			return {
				Disconnect = function() end
			}
		end,
		Once = function()
			return {
				Disconnect = function() end
			}
		end,
		Wait = function() end
	}
}

function UIKit.new(className, items, parent)
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

function UIKit.corner(p, p2)
	return UIKit.new("UICorner", { CornerRadius = UDim.new(0, (math.min(p2, 3))) }, p)
end

function UIKit.stroke(p, p2, value, value2)
	return UIKit.new("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = p2 or colors.Border,
		Thickness = value2 or 1,
		Transparency = value or 0
	}, p)
end

function UIKit.padding(p, p2, p3, p4, p5)
	return UIKit.new(
		"UIPadding",
		{
			PaddingTop = UDim.new(0, p2),
			PaddingRight = UDim.new(0, p3),
			PaddingBottom = UDim.new(0, p4),
			PaddingLeft = UDim.new(0, p5)
		},
		p
	)
end

function UIKit.list(p, value, items)
	local uiListLayout = UIKit.new("UIListLayout", {
		Padding = UDim.new(0, value or 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, p)

	if items then
		for k, item in pairs(items) do
			uiListLayout[k] = item
		end
	end

	return uiListLayout
end

function UIKit:tween(items, _)
	for k, item in pairs(items) do
		pcall(function()
			self[k] = item
		end)
	end

	return v
end

function UIKit.escape(p)
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function UIKit.clear(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA("UIListLayout") or child:IsA("UIGridLayout") or child:IsA("UIPadding") then
			continue
		end

		child:Destroy()
	end
end

function UIKit.duration(value)
	local v2 = math.max(0, (math.floor(value or 0)))
	local v3 = v2 // 3600
	local v4 = v2 % 3600 // 60
	local v5 = v2 % 60

	if v3 > 0 then
		return string.format("%dh %dm", v3, v4)
	end

	if v4 > 0 then
		return string.format("%dm %ds", v4, v5)
	end

	return string.format("%ds", v5)
end

function UIKit.clock(value)
	local v2 = math.max(0, (math.floor(value or 0)))
	return string.format("%d:%02d", v2 // 60, v2 % 60)
end

function UIKit.now()
	return (math.floor((workspace:GetServerTimeNow())))
end

function UIKit.timeAgo(p)
	local now = UIKit.now()
	local v2 = math.max(0, now - (p or now))

	if v2 < 10 then
		return "just now"
	end

	if v2 < 60 then
		return v2 .. "s ago"
	end

	if v2 < 3600 then
		return v2 // 60 .. "m ago"
	end

	if v2 < 86400 then
		return v2 // 3600 .. "h ago"
	end

	return v2 // 86400 .. "d ago"
end

function UIKit.dateTime(p)
	return os.date("%d %b %H:%M", p)
end

function UIKit.memory(value)
	value = value or 0

	if value >= 1024 then
		return string.format("%.1f GB", value / 1024)
	end

	return string.format("%d MB", value)
end

function UIKit.label(p, text, options)
	local v2 = options or {}
	local textLabel = UIKit.new("TextLabel", {
		BackgroundTransparency = 1,
		Font = v2.bold and UIKit.FontBold or v2.regular and UIKit.FontRegular or UIKit.FontMedium,
		LayoutOrder = v2.order or 0,
		RichText = v2.rich or false,
		Size = v2.sizeUDim or UDim2.new(1, 0, 0, v2.height or 18),
		Text = text,
		TextColor3 = v2.color or colors.Text,
		TextSize = (v2.textSize or 13) + 1,
		TextTruncate = v2.truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
		TextWrapped = v2.wrap or false,
		TextXAlignment = v2.align or Enum.TextXAlignment.Left,
		TextYAlignment = v2.valign or Enum.TextYAlignment.Center
	}, p)

	if v2.autoY then
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
		textLabel.Size = UDim2.new(1, 0, 0, 0)
	end

	return textLabel
end

function UIKit.setBase(instance, base)
	instance:SetAttribute("Base", base)
	UIKit.tween(instance, { BackgroundColor3 = base }, 0.12)
end

local function attachHover(textButton)
	textButton.MouseEnter:Connect(function()
		local base = textButton:GetAttribute("Base") or textButton.BackgroundColor3
		UIKit.tween(textButton, {
			BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.08)
		}, 0.1)
	end)
	textButton.MouseLeave:Connect(function()
		local base = textButton:GetAttribute("Base") or textButton.BackgroundColor3
		UIKit.tween(textButton, { BackgroundColor3 = base }, 0.1)
	end)
end

function UIKit.button(p, text, options)
	local v2 = options or {}
	local base = v2.base or colors.Surface2
	local textButton = UIKit.new("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = base,
		BorderSizePixel = 0,
		Font = v2.bold and UIKit.FontBold or UIKit.FontMedium,
		LayoutOrder = v2.order or 0,
		Size = v2.sizeUDim or UDim2.new(1, 0, 0, v2.height or 34),
		Text = text,
		TextColor3 = v2.color or colors.Text,
		TextSize = (v2.textSize or 12) + 1
	}, p)

	textButton:SetAttribute("Base", base)
	UIKit.corner(textButton, v2.radius or 2)

	if v2.stroke ~= false then
		UIKit.stroke(textButton, colors.Border, 0.5, 1)
	end

	attachHover(textButton)

	if v2.onClick then
		textButton.Activated:Connect(v2.onClick)
	end

	return textButton
end

function UIKit:armConfirm(text, text2, callback, callback2)
	local textColor3 = self.TextColor3
	local v2 = 0
	local count = 0

	local function disarm() -- 2 equivalent calls inferred from this helper
		v2 = 0
		self.Text = text
		self.TextColor3 = textColor3
	end

	self.Activated:Connect(function()
		if os.clock() < v2 then
			count += 1
			disarm() -- inferred equivalent call
			callback()
		else
			if callback2 and not callback2() then
				return
			end

			count += 1
			local v3 = count
			v2 = os.clock() + 3
			self.Text = text2
			self.TextColor3 = colors.Danger
			task.delay(3, function()
				if count == v3 and v2 ~= 0 then
					disarm() -- inferred equivalent call
				end
			end)
		end
	end)
end

function UIKit.card(p, options)
	local v2 = options or {}
	local frame = UIKit.new("Frame", {
		AutomaticSize = v2.height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
		BackgroundColor3 = v2.color or colors.Surface,
		BorderSizePixel = 0,
		LayoutOrder = v2.order or 0,
		Size = v2.sizeUDim or UDim2.new(1, 0, 0, v2.height or 0)
	}, p)

	UIKit.corner(frame, v2.radius or 2)
	UIKit.stroke(frame, colors.Border, 0.2, 1)
	local padding = v2.padding or 14
	UIKit.padding(frame, padding, padding, padding, padding)

	if not v2.noList then
		UIKit.list(frame, v2.gap or 8)
	end

	return frame
end

function UIKit.badge(p, text, p2, value)
	local v2 = p2 or colors.Muted
	local textLabel = UIKit.new("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = v2,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		Font = UIKit.FontBold,
		LayoutOrder = value or 0,
		Size = UDim2.fromOffset(0, 20),
		Text = text,
		TextColor3 = v2,
		TextSize = 11
	}, p)

	UIKit.corner(textLabel, 2)
	UIKit.padding(textLabel, 0, 9, 0, 9)
	return textLabel
end

function UIKit.dot(p, backgroundColor, value)
	local frame = UIKit.new("Frame", {
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(value or 8, value or 8)
	}, p)

	UIKit.corner(frame, (value or 8) / 2)
	return frame
end

function UIKit.monogram(p, text, p2, value)
	value = value or 34
	local frame = UIKit.new(
		"Frame",
		{
			BackgroundColor3 = p2,
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(value, value)
		},
		p
	)

	UIKit.corner(frame, (math.floor(value * 0.3)))
	UIKit.new("TextLabel", {
		BackgroundTransparency = 1,
		Font = UIKit.FontBold,
		Size = UDim2.fromScale(1, 1),
		Text = text,
		TextColor3 = p2,
		TextSize = math.floor(value * 0.48)
	}, frame)

	return frame
end

function UIKit.progress(p, value, p2, value2)
	local frame = UIKit.new("Frame", {
		BackgroundColor3 = colors.Surface3,
		BorderSizePixel = 0,
		LayoutOrder = value2 or 0,
		Size = UDim2.new(1, 0, 0, 5)
	}, p)

	UIKit.corner(frame, 3)
	local frame2 = UIKit.new("Frame", {
		BackgroundColor3 = p2 or colors.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(math.clamp(value or 0, 0, 1), 1)
	}, frame)

	UIKit.corner(frame2, 3)
	return frame, frame2
end

function UIKit.avatar(p, p2, value)
	local imageLabel = UIKit.new("ImageLabel", {
		BackgroundColor3 = colors.Surface3,
		BorderSizePixel = 0,
		Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", p2),
		Size = UDim2.fromOffset(value or 56, value or 56)
	}, p)

	UIKit.corner(imageLabel, (math.floor((value or 56) / 2)))
	return imageLabel
end

local function bar(frame, backgroundColor, p, p2, p3, p4, rotation)
	local frame2 = UIKit.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(p3, p4),
		Rotation = rotation,
		Size = UDim2.fromOffset(p, p2)
	}, frame)

	UIKit.corner(frame2, p / 2)
	return frame2
end

function UIKit.chevron(p, p2)
	local frame = UIKit.new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(12, 12) }, p)
	bar(frame, p2 or colors.Muted, 2, 6, 3.6, 5.2, -45)
	bar(frame, p2 or colors.Muted, 2, 6, 8.4, 5.2, 45)
	return frame
end

function UIKit.cross(p, p2)
	local frame = UIKit.new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 14) }, p)
	bar(frame, p2 or colors.Muted, 2, 16, 7, 7, 45)
	bar(frame, p2 or colors.Muted, 2, 16, 7, 7, -45)
	return frame
end

function UIKit.check(p, backgroundColor)
	local frame = UIKit.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false
	}, p)

	bar(frame, backgroundColor, 2.5, 5.5, 6.9, 11.6, -45)
	bar(frame, backgroundColor, 2.5, 10, 11.9, 9.9, 45)
	return frame
end

function UIKit.textbox(p, placeholderText, options)
	local v2 = options or {}
	local textBox = UIKit.new("TextBox", {
		BackgroundColor3 = colors.Bg,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = UIKit.FontMedium,
		LayoutOrder = v2.order or 0,
		MultiLine = v2.multiline or false,
		PlaceholderColor3 = colors.Muted,
		PlaceholderText = placeholderText,
		Size = v2.sizeUDim or UDim2.new(1, 0, 0, v2.height or 34),
		Text = v2.text or "",
		TextColor3 = colors.Text,
		TextSize = (v2.textSize or 12) + 1,
		TextWrapped = v2.multiline or false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = v2.multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
	}, p)

	UIKit.corner(textBox, 2)
	UIKit.padding(textBox, v2.multiline and 8 or 0, 10, v2.multiline and 8 or 0, 10)
	local stroke = UIKit.stroke(textBox, colors.Border, 0.35, 1)
	textBox.Focused:Connect(function()
		stroke.Color = colors.Accent
		stroke.Transparency = 0.15
	end)
	textBox.FocusLost:Connect(function()
		stroke.Color = colors.Border
		stroke.Transparency = 0.35
	end)

	if v2.maxLength then
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			if #textBox.Text > v2.maxLength then
				textBox.Text = string.sub(textBox.Text, 1, v2.maxLength)
			end
		end)
	end

	return textBox
end

function UIKit.switch(p, p2, callback, options)
	local v2 = options or {}
	local textButton = UIKit.new("TextButton", {
		AnchorPoint = v2.anchor,
		AutoButtonColor = false,
		BackgroundColor3 = colors.Surface3,
		BorderSizePixel = 0,
		LayoutOrder = v2.order or 0,
		Position = v2.position,
		Size = UDim2.fromOffset(40, 22),
		Text = ""
	}, p)

	UIKit.corner(textButton, 2)
	local frame = UIKit.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = colors.Text,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16)
	}, textButton)

	UIKit.corner(frame, 2)
	local v3 = p2 == true
	local v4 = v2.locked == true

	local function render()
		UIKit.tween(textButton, {
			BackgroundColor3 = v3 and colors.Accent or colors.Surface3
		}, 0.12)
		UIKit.tween(frame, {
			Position = v3 and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		}, 0.12)
		textButton.BackgroundTransparency = v4 and 0.5 or 0
	end
	render()

	textButton.Activated:Connect(function()
		if v4 then
			return
		end

		if callback then
			callback(not v3)
		end
	end)

	return {
		Instance = textButton,
		Get = function()
			return v3
		end,
		SetState = function(p3)
			v3 = p3 == true
			render()
		end,
		SetLocked = function(p3)
			v4 = p3 == true
			render()
		end
	}
end

function UIKit.chipGroup(p, list, p2, callback, options)
	local frame = UIKit.new("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = (options or {}).order or 0,
		Size = UDim2.new(1, 0, 0, 0)
	}, p)

	UIKit.new(
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = true
		},
		frame
	)

	local v2 = {}
	local v3 = p2

	local function render()
		for _, v4 in ipairs(v2) do
			local v5 = v4.value == v3
			UIKit.setBase(v4.button, v5 and colors.AccentDim or colors.Surface2)
			v4.button.TextColor3 = v5 and colors.Accent or colors.Text
			v4.stroke.Color = v5 and colors.Accent or colors.Border
			v4.stroke.Transparency = v5 and 0.2 or 0.5
		end
	end

	for i, item in ipairs(list) do
		local button = UIKit.button(frame, item.label, {
			order = i,
			radius = 2,
			sizeUDim = UDim2.fromOffset(0, 28),
			stroke = false,
			textSize = 11
		})

		button.AutomaticSize = Enum.AutomaticSize.X
		UIKit.padding(button, 0, 12, 0, 12)
		table.insert(v2, {
			button = button,
			stroke = UIKit.stroke(button, colors.Border, 0.5, 1),
			value = item.value
		})
		button.Activated:Connect(function()
			v3 = item.value
			render()

			if callback then
				callback(v3)
			end
		end)
	end

	render()

	return {
		Instance = frame,
		Get = function()
			return v3
		end,
		Set = function(p3)
			v3 = p3
			render()
		end
	}
end

function UIKit.pageHeader(p, value, p2, value2)
	local frame = UIKit.new("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = value2 or 0,
		Size = UDim2.new(1, 0, 0, 0)
	}, p)

	UIKit.list(frame, 4)

	if result then
		local addTitle = result.AddTitle(frame, string.upper(value), { size = 20, z = 2 })
		addTitle.LayoutOrder = 1
	else
		UIKit.label(frame, value, { bold = true, height = 24, order = 1, textSize = 19 })
	end

	if p2 then
		UIKit.label(frame, p2, {
			color = colors.Muted,
			height = 16,
			order = 2,
			regular = true,
			textSize = 12
		})
	end

	return frame
end

function UIKit.sectionTitle(p, value, value2)
	local label = UIKit.label(p, string.upper(value), {
		bold = true,
		color = colors.Text,
		height = 18,
		order = value2 or 0,
		textSize = 9
	})
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.BackgroundColor3 = colors.Strip
	label.BackgroundTransparency = 0
	UIKit.padding(label, 0, 6, 0, 8)
	return label
end

function UIKit.emptyState(p, p2, value)
	return UIKit.label(p, p2, {
		align = Enum.TextXAlignment.Center,
		color = colors.Muted,
		height = 40,
		order = value or 0,
		regular = true,
		textSize = 12
	})
end

function UIKit.keyValue(p, p2, p3, value, p4)
	local frame = UIKit.new("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = value or 0,
		Size = UDim2.new(1, 0, 0, 22)
	}, p)

	UIKit.label(frame, p2, {
		color = colors.Muted,
		regular = true,
		sizeUDim = UDim2.new(0.4, 0, 1, 0),
		textSize = 12
	})
	local label = UIKit.label(frame, p3, {
		align = Enum.TextXAlignment.Right,
		color = p4 or colors.Text,
		sizeUDim = UDim2.new(0.6, 0, 1, 0),
		textSize = 12,
		truncate = true
	})

	label.Position = UDim2.fromScale(0.4, 0)
	return frame, label
end

function UIKit.grid(p, p2, p3, p4, value)
	local frame = UIKit.new("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = value or 0,
		Size = UDim2.new(1, 0, 0, 0)
	}, p)

	local uiGridLayout = UIKit.new(
		"UIGridLayout",
		{ CellPadding = UDim2.fromOffset(p4, p4), SortOrder = Enum.SortOrder.LayoutOrder },
		frame
	)

	local function setColumns(p5) -- 1 equivalent call inferred from this helper
		uiGridLayout.CellSize = UDim2.new(1 / p5, -(math.ceil(p4 * (p5 - 1) / p5) + 1), 0, p3)
	end

	setColumns(p2) -- inferred equivalent call
	return frame, setColumns
end

function UIKit.divider(p, value)
	return UIKit.new("Frame", {
		BackgroundColor3 = colors.Border,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		LayoutOrder = value or 0,
		Size = UDim2.new(1, 0, 0, 1)
	}, p)
end

return UIKit