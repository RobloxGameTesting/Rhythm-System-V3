local TweenService = game:GetService("TweenService")
local StyledTheme = require(script.Parent.StyledTheme)
local InstrumentIcons = require(script.Parent.InstrumentIcons)

local ToastStyle = {}

ToastStyle.PLATE = Color3.fromRGB(28, 26, 24)
ToastStyle.PLATE_LIGHT = Color3.fromRGB(52, 48, 43)
ToastStyle.INK = Color3.fromRGB(240, 234, 218)
ToastStyle.WHITE = Color3.fromRGB(255, 250, 236)
ToastStyle.AMBER = Color3.fromRGB(236, 180, 72)
ToastStyle.GREEN = Color3.fromRGB(104, 178, 112)
ToastStyle.RED = Color3.fromRGB(196, 72, 60)
ToastStyle.GRAY = Color3.fromRGB(168, 160, 140)
ToastStyle.TAPE = Color3.fromRGB(208, 192, 152)
ToastStyle.DARK = Color3.fromRGB(14, 13, 12)

ToastStyle.Z = StyledTheme.ZIndex.Toast
local z = ToastStyle.Z

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
function ToastStyle.TopYFor(screenGui)
	while screenGui and not screenGui:IsA("ScreenGui") do
		screenGui = screenGui.Parent
	end

	if screenGui and screenGui.IgnoreGuiInset then
		return 52
	end

	return (math.max(4, 52 - GuiService:GetGuiInset().Y))
end

function ToastStyle.VoteBottom()
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	local maxValue = 0

	for _, v in ipairs({
		{ "LaptopVoteToastGui", "VoteBar" },
		{ "VoteKickToastGui", "VoteKickBar" }
	}) do
		local child = playerGui and playerGui:FindFirstChild(v[1])
		local guiObject = child and child:FindFirstChild(v[2])

		if guiObject and guiObject:IsA("GuiObject") and guiObject.Visible then
			maxValue = math.max(maxValue, guiObject.Position.Y.Offset + guiObject.AbsoluteSize.Y - 5)
		end
	end

	return maxValue
end

function ToastStyle.MaxCardWidth()
	local currentCamera = workspace.CurrentCamera
	return (math.clamp((currentCamera and currentCamera.ViewportSize.X or 1152) - 180, 260, 580))
end

function ToastStyle.ColumnX()
	return -math.floor((math.min(270, ToastStyle.MaxCardWidth() / 2)))
end

function ToastStyle.LabelMax(p)
	return (math.max(90, ToastStyle.MaxCardWidth() - p))
end

local function mk(class, items, parent) -- 41 equivalent calls inferred from this helper
	local instance = Instance.new(class)

	for k, item in pairs(items) do
		instance[k] = item
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

ToastStyle.mk = mk

function ToastStyle.hex(data)
	return string.format(
		"#%02X%02X%02X",
		math.floor(data.R * 255 + 0.5),
		math.floor(data.G * 255 + 0.5),
		(math.floor(data.B * 255 + 0.5))
	)
end

function ToastStyle.tween(instance, duration, p, p2, goal)
	local tween = TweenService:Create(instance, TweenInfo.new(duration, p, p2), goal)
	tween:Play()
	return tween
end

function ToastStyle.addTape(parent, position, p, rotation, p2)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Tape",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position,
		Size = UDim2.fromOffset(p.X, p.Y),
		Rotation = rotation,
		BackgroundColor3 = p2 or ToastStyle.TAPE,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ZIndex = z + 8
	}, parent)

	mk("UIGradient", { -- inferred equivalent call
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0.22)
		})
	}, parent2)

	mk("Frame", { -- inferred equivalent call
		BackgroundColor3 = ToastStyle.DARK,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		ZIndex = z + 9,
		Position = UDim2.fromScale(0.12, 0.32),
		Size = UDim2.fromScale(0.5, 0.14)
	}, parent2)

	return parent2
end

local function addAccent(parent, accent, random)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Accent",
		Position = UDim2.new(0, -2, 0, -3),
		Size = UDim2.new(0, 5, 1, 6),
		Rotation = 1.6,
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		ZIndex = z + 1
	}, parent)

	for _ = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = ToastStyle.PLATE,
			BorderSizePixel = 0,
			ZIndex = z + 2,
			Position = UDim2.new(random:NextNumber() * 0.5, 0, random:NextNumber(), 0),
			Size = UDim2.fromOffset(random:NextInteger(2, 3), random:NextInteger(3, 7))
		}, parent2)
	end

	return parent2
end

local function addGrime(parent, random)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Shade",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = z + 1,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(1, 0.5)
	}, parent)

	mk("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.7) })
	}, parent2)

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "Stain",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.86,
		BorderSizePixel = 0,
		ZIndex = z + 1,
		Position = UDim2.fromScale(0.1 + random:NextNumber() * 0.6, 0.1 + random:NextNumber() * 0.4),
		Size = UDim2.fromOffset(46, 24)
	}, parent)

	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BorderSizePixel = 0,
			ZIndex = z + 1,
			BackgroundColor3 = ToastStyle.INK,
			BackgroundTransparency = 0.88 + random:NextNumber() * 0.06,
			Rotation = random:NextInteger(-30, 30),
			Position = UDim2.fromScale(0.1 + random:NextNumber() * 0.75, 0.15 + random:NextNumber() * 0.7),
			Size = UDim2.fromOffset(random:NextInteger(18, 44), 1)
		}, parent)
	end

	for i = 1, 8 do
		local v = random:NextNumber() > 0.4
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BorderSizePixel = 0,
			ZIndex = z + 1,
			BackgroundColor3 = v and ToastStyle.INK or Color3.new(0, 0, 0),
			BackgroundTransparency = v and 0.84 + random:NextNumber() * 0.1 or 0.5 + random:NextNumber() * 0.25,
			Position = UDim2.fromScale(0.03 + random:NextNumber() * 0.94, 0.08 + random:NextNumber() * 0.84),
			Size = UDim2.fromOffset(1, 1)
		}, parent)
	end
end

function ToastStyle.makeTag(parent, text, backgroundColor, value)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "TagBox",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, value or 34, 0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		BackgroundTransparency = 1,
		ZIndex = z + 8
	}, parent)

	local frame = mk("Frame", { -- inferred equivalent call
		Name = "TagBg",
		Position = UDim2.fromOffset(-2, -1),
		Size = UDim2.new(1, 4, 1, 2),
		Rotation = -2.5,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		ZIndex = z + 8
	}, parent2)

	local parent3 = mk("TextLabel", { -- inferred equivalent call
		Name = "Tag",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.PermanentMarker,
		TextSize = 11,
		TextColor3 = ToastStyle.DARK,
		Text = text,
		ZIndex = z + 9
	}, parent2)

	mk("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }, parent3) -- inferred equivalent call
	return parent3, frame, parent2
end

function ToastStyle.makeIcon(parent, text, textColor, value)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "IconBox",
		Size = UDim2.fromOffset(20, 28),
		BackgroundTransparency = 1,
		LayoutOrder = value or 1,
		ZIndex = z + 3
	}, parent)
	return mk("TextLabel", { -- inferred equivalent call
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextColor3 = textColor,
		Text = text,
		TextStrokeTransparency = 1,
		ZIndex = z + 4
	}, parent2), parent2
end

function ToastStyle.makeScribble(parent, backgroundColor2, value)
	local v = { 0, 1, 0 }
	local v2 = { -1.6, 0.9, -0.6 }
	local segments = {}

	for i = 1, 3 do
		segments[i] = mk("Frame", { -- inferred equivalent call
			Name = "Scribble" .. i,
			BackgroundColor3 = backgroundColor2,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			ZIndex = z + 2,
			Position = UDim2.new((i - 1) / 3, 0, 0.5, (value or 13) + v[i]),
			Size = UDim2.new(1 / 3, 1, 0, 2),
			Rotation = v2[i]
		}, parent)
	end

	local scribble = { Segments = segments }
	function scribble.SetColor(backgroundColor)
		for _, v3 in ipairs(segments) do
			v3.BackgroundColor3 = backgroundColor
		end
	end
	function scribble.Play()
		for i, v3 in ipairs(segments) do
			v3.Size = UDim2.new(0, 0, 0, 2)
			task.delay(0.12 + (i - 1) * 0.1, function()
				if v3.Parent then
					ToastStyle.tween(v3, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
						Size = UDim2.new(1 / 3, 1, 0, 2)
					})
				end
			end)
		end
	end
	return scribble
end

function ToastStyle.makeButton(parent, text, p, layoutOrder, backgroundColor, textColor, _, value)
	text = p and string.format("%s <font size=\"10\" face=\"SpecialElite\">(%s)</font>", text, p) or text
	local button = mk("TextButton", { -- inferred equivalent call
		BackgroundColor3 = backgroundColor,
		AutoButtonColor = true,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, value or 24),
		Font = Enum.Font.PermanentMarker,
		TextSize = 14,
		TextColor3 = textColor,
		RichText = true,
		Text = text,
		LayoutOrder = layoutOrder,
		BorderSizePixel = 0,
		ZIndex = z + 4
	}, parent)

	mk("UIPadding", { PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11) }, button) -- inferred equivalent call
	mk("UIGradient", { -- inferred equivalent call
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.12),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0.16)
		})
	}, button)

	return button
end

local RunService = game:GetService("RunService")
local userIdsByName = {}
local userIdsByDisplayName = {}

local function cachePlayer(player) -- 2 equivalent calls inferred from this helper
	userIdsByName[string.lower(player.Name)] = player.UserId

	if player.DisplayName ~= "" then
		userIdsByDisplayName[string.lower(player.DisplayName)] = player.UserId
	end
end

if RunService:IsClient() then
	for _, v in ipairs(Players:GetPlayers()) do
		cachePlayer(v) -- inferred equivalent call
	end

	Players.PlayerAdded:Connect(cachePlayer)
end

function ToastStyle.UserIdFor(value)
	if type(value) ~= "string" or value == "" then
		return nil
	end

	local v = string.lower(value)
	local v2 = userIdsByName[v] or userIdsByDisplayName[v]

	if not v2 then
		for _, v3 in ipairs(Players:GetPlayers()) do
			cachePlayer(v3) -- inferred equivalent call
		end

		return userIdsByName[v] or userIdsByDisplayName[v]
	end

	return v2
end

local v = {}
local v2 = {}

function ToastStyle.LoadHeadshot(p, callback)
	local v3 = v[p]

	if v3 then
		callback(v3)
		return
	end

	local callbacks = v2[p]

	if callbacks then
		table.insert(callbacks, callback)
		return
	end

	v2[p] = { callback }
	task.spawn(function()
		local v4 = nil

		for _ = 1, 3 do
			local success, userThumbnailAsync, v5 = pcall(
				Players.GetUserThumbnailAsync,
				Players,
				p,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)

			if success and type(userThumbnailAsync) == "string" and userThumbnailAsync ~= "" then
				if v5 then
					v4 = userThumbnailAsync
					break
				end

				v4 = userThumbnailAsync
			end

			task.wait(1)
		end

		local v5 = v2[p]
		v2[p] = nil

		if v4 then
			v[p] = v4

			for _, callback2 in ipairs(v5 or {}) do
				task.spawn(callback2, v4)
			end
		end
	end)
end

local color = Color3.fromRGB(104, 98, 88)

ToastStyle.InstrumentResolver = nil

ToastStyle.LastInstrument = {}

function ToastStyle.makeAvatar(parent, p, value)
	local box = mk("Frame", { -- inferred equivalent call
		Name = "AvatarBox",
		Size = UDim2.fromOffset(p - 4, p),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = value or 0,
		ZIndex = z + 3
	}, parent)

	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "AvatarFrame",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(p - 2, p - 2),
		Rotation = -3,
		BackgroundColor3 = ToastStyle.INK,
		BorderSizePixel = 0,
		ZIndex = z + 3
	}, box)

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "Photo",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = ToastStyle.PLATE_LIGHT,
		BorderSizePixel = 0,
		ZIndex = z + 4
	}, parent2)

	local frame = mk("Frame", { -- inferred equivalent call
		Name = "Silhouette",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = z + 4
	}, parent3)
	local parent4 = mk("Frame", { -- inferred equivalent call
		Name = "Head",
		Position = UDim2.fromScale(0.32, 0.16),
		Size = UDim2.fromScale(0.36, 0.36),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = z + 4
	}, frame)

	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
	local parent5 = mk("Frame", { -- inferred equivalent call
		Name = "Shoulders",
		Position = UDim2.fromScale(0.12, 0.54),
		Size = UDim2.fromScale(0.76, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = z + 4
	}, frame)

	mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, parent5) -- inferred equivalent call
	mk("Frame", { -- inferred equivalent call
		Name = "ShouldersFlat",
		Position = UDim2.fromScale(0.12, 0.79),
		Size = UDim2.fromScale(0.76, 0.21),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = z + 4
	}, frame)

	local imageLabel = mk("ImageLabel", { -- inferred equivalent call
		Name = "Headshot",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = z + 5
	}, parent3)

	ToastStyle.addTape(box, UDim2.fromOffset(math.floor(p * 0.24), 1), Vector2.new(12, 6), -32)

	local v3 = math.clamp(math.floor(p * 0.48), 14, 26)
	local parent6 = mk("Frame", { -- inferred equivalent call
		Name = "InstrumentBadge",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 4, 1, 3),
		Size = UDim2.fromOffset(v3, v3),
		BackgroundColor3 = ToastStyle.PLATE,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = z + 7
	}, box)

	mk("UICorner", { CornerRadius = UDim.new(0.3, 0) }, parent6) -- inferred equivalent call
	local imageLabel2 = mk("ImageLabel", { -- inferred equivalent call
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = z + 8
	}, parent6)

	local avatar = { Box = box }
	local count = 0

	function avatar.SetInstrument(p2)
		local image = p2 and InstrumentIcons.Get(p2)

		if not image then
			parent6.Visible = false
			return
		end

		local size = InstrumentIcons.GetSize(p2, v3 - 4)
		imageLabel2.Image = image
		imageLabel2.Size = UDim2.fromOffset(size.X, size.Y)
		parent6.Visible = true
	end

	function avatar.Set(value2)
		local v4 = nil

		if type(value2) == "number" then
			v4 = value2
		elseif type(value2) == "string" then
			v4 = ToastStyle.UserIdFor(value2)
		elseif type(value2) == "table" then
			v4 = value2.userId or ToastStyle.UserIdFor(value2.name)
		end

		local v5 = nil

		if ToastStyle.InstrumentResolver then
			local success, result = pcall(ToastStyle.InstrumentResolver, value2, v4)

			if success then
				v5 = result
			end
		end

		avatar.SetInstrument(v5)
		count += 1
		local v6 = count

		imageLabel.Image = ""
		imageLabel.ImageTransparency = 1
		frame.Visible = true

		if not v4 then
			return
		end

		ToastStyle.LoadHeadshot(v4, function(image)
			if v6 ~= count or not imageLabel.Parent then
				return
			end

			imageLabel.Image = image
			frame.Visible = false
			ToastStyle.tween(imageLabel, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				ImageTransparency = 0
			})
		end)
	end
	return avatar
end

function ToastStyle.AvatarCardHeight(p)
	return p + 8
end

function ToastStyle:attachAvatar(p, value, instance)
	local v3 = math.clamp((value or 36) + 4, 30, 66)
	local avatar = ToastStyle.makeAvatar(self.Content, v3, 0)
	local uiListLayout = self.Content:FindFirstChildOfClass("UIListLayout")

	if uiListLayout then
		uiListLayout.Padding = UDim.new(0, 6)
	end

	local iconBox = self.Content:FindFirstChild("IconBox")

	if iconBox then
		iconBox.Size = UDim2.fromOffset(16, iconBox.Size.Y.Offset)
	end

	local v4 = v3 - 4 + 6

	if self.TagBox then
		self.TagBox.Position = self.TagBox.Position + UDim2.fromOffset(v4, 0)
	end

	if instance then
		if ToastStyle.MaxCardWidth() < 580 then
			instance = self.Content:FindFirstChild("Label")
		else
			instance = false
		end
	end

	local uiSizeConstraint = instance and instance:FindFirstChildOfClass("UISizeConstraint")

	if uiSizeConstraint then
		uiSizeConstraint.MaxSize = Vector2.new(
			math.max(90, uiSizeConstraint.MaxSize.X - v4),
			uiSizeConstraint.MaxSize.Y
		)
	end

	avatar.Set(p)
	self.Avatar = avatar
	return avatar
end

function ToastStyle.buildCard(data)
	local random = Random.new(data.seed or 4242)

	local card2 = mk(data.class or "Frame", { -- inferred equivalent call
		Name = data.name or "ToastCard",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = z,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(0, data.width or 0, 0, data.height or 36)
	})

	if data.class == "TextButton" then
		card2.AutoButtonColor = false
		card2.Text = ""
	end

	card2:SetAttribute("NoNewUISkin", true)

	local scale2 = mk("UIScale", { Name = "PopScale", Scale = 1 }, card2) -- inferred equivalent call

	local parent = mk("Frame", { -- inferred equivalent call
		Name = "PlateHolder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = z
	}, card2)

	local plate = mk("Frame", { -- inferred equivalent call
		Name = "Plate",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = ToastStyle.PLATE,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Rotation = data.rotation or 0,
		ZIndex = z
	}, parent)

	addGrime(plate, random)
	local accent = addAccent(plate, data.accent or ToastStyle.AMBER, random)

	local content = mk("Frame", { -- inferred equivalent call
		Name = "Content",
		BackgroundTransparency = 1,
		ZIndex = z + 2,
		AutomaticSize = data.width and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
		Size = data.width and UDim2.fromScale(1, 1) or UDim2.new(0, 0, 1, 0)
	}, card2)

	mk("UIPadding", { -- inferred equivalent call
		PaddingLeft = UDim.new(0, data.padL or 16),
		PaddingRight = UDim.new(0, data.padR or 14),
		PaddingTop = UDim.new(0, data.padT or 0),
		PaddingBottom = UDim.new(0, data.padB or 0)
	}, content)

	mk("UIListLayout", { -- inferred equivalent call
		FillDirection = data.vertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, data.gap or 8)
	}, content)

	if not data.width then
		local function syncWidth() -- 1 equivalent call inferred from this helper
			local scale = scale2.Scale
			local v3 = scale < 0.05 and 1 or scale

			card2.Size = UDim2.fromOffset(
				math.max(math.ceil(content.AbsoluteSize.X / v3 - 0.01), data.minWidth or 0),
				data.height or 36
			)
		end
		content:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncWidth)
		syncWidth() -- inferred equivalent call
	end

	local tapes = {}

	if data.tape == "tr" or data.tape == "both" then
		table.insert(tapes, ToastStyle.addTape(card2, UDim2.new(1, -6, 0, 3), Vector2.new(24, 9), 24))
	end

	if data.tape == "both" then
		table.insert(tapes, ToastStyle.addTape(card2, UDim2.new(0, 10, 1, -1), Vector2.new(20, 8), -18))
	end

	local card = {
		Card = card2,
		Plate = plate,
		Content = content,
		Accent = accent,
		Scale = scale2,
		Tapes = tapes,
		BaseRotation = data.rotation or 0,
		Color = data.accent or ToastStyle.AMBER,
		Gap = data.gap or 8
	}

	if data.tag then
		local tag, tagBg, tagBox = ToastStyle.makeTag(card2, data.tag, card.Color, data.tagX)
		card.Tag = tag
		card.TagBg = tagBg
		card.TagBox = tagBox
	end

	function card.SetAccent(p)
		card.Color = p
		accent.BackgroundColor3 = p

		if card.TagBg then
			card.TagBg.BackgroundColor3 = p
		end

		if card.Icon then
			card.Icon.TextColor3 = p
		end

		if card.Scribble then
			card.Scribble.SetColor(p)
		end
	end

	function card.Flash()
		accent.BackgroundColor3 = Color3.new(1, 1, 1)
		ToastStyle.tween(accent, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundColor3 = card.Color
		})

		if card.TagBg then
			card.TagBg.BackgroundColor3 = Color3.new(1, 1, 1)
			ToastStyle.tween(card.TagBg, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				BackgroundColor3 = card.Color
			})
		end
	end

	if data.parent then
		card2.Parent = data.parent
	end

	return card
end

function ToastStyle.popIn(data)
	data.Scale.Scale = 0.8
	ToastStyle.tween(data.Scale, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
		Scale = 1
	})
	data.Plate.Rotation = data.BaseRotation - 4
	ToastStyle.tween(data.Plate, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
		Rotation = data.BaseRotation
	})

	for i, tape in ipairs(data.Tapes) do
		local rotation = tape.Rotation
		tape.Rotation = rotation + (i % 2 == 0 and -34 or 34)
		ToastStyle.tween(tape, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			Rotation = rotation
		})
	end

	if data.TagBg then
		local rotation = data.TagBg.Rotation
		data.TagBg.Rotation = rotation - 14
		ToastStyle.tween(data.TagBg, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			Rotation = rotation
		})
	end

	if data.Scribble then
		data.Scribble.Play()
	end
end

return ToastStyle