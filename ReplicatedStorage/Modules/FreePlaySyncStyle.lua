local UserInputService = game:GetService("UserInputService")

local FreePlaySyncStyle = {}

FreePlaySyncStyle.Palette = {
	PAPER = Color3.fromRGB(186, 176, 152),
	PAPER_EDGE = Color3.fromRGB(122, 112, 94),
	INK = Color3.fromRGB(28, 25, 22),
	MARKER = Color3.fromRGB(176, 38, 34),
	AMBER = Color3.fromRGB(204, 162, 72),
	AMBER_TEXT = Color3.fromRGB(24, 22, 18),
	SURFACE = Color3.fromRGB(15, 15, 14),
	SELECTED = Color3.fromRGB(64, 62, 58),
	TEXT = Color3.fromRGB(222, 220, 214),
	TAPE = Color3.fromRGB(206, 190, 150),
	TAPE_DARK = Color3.fromRGB(96, 90, 80),
	TAPE_BLACK = Color3.fromRGB(20, 20, 19),
	WINDOW_STROKE = Color3.fromRGB(8, 8, 8),
	RUST = Color3.fromRGB(74, 42, 28)
}

local palette = FreePlaySyncStyle.Palette

FreePlaySyncStyle.FONT_HEAD = Enum.Font.Oswald
FreePlaySyncStyle.FONT_BODY = Enum.Font.SpecialElite

local function mk(className, items, parent) -- 32 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

FreePlaySyncStyle.Make = mk

function FreePlaySyncStyle.AddTape(parent, name, position, size, rotation, backgroundColor, backgroundTransparency, value)
	local zIndex = value or 30
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position,
		Size = size,
		Rotation = rotation,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		ZIndex = zIndex
	}, parent)

	mk("UIStroke", { Color = Color3.fromRGB(70, 62, 48), Thickness = 1, Transparency = 0.7 }, parent2) -- inferred equivalent call
	mk("Frame", { -- inferred equivalent call
		Name = "Streak",
		BackgroundColor3 = Color3.fromRGB(70, 56, 38),
		BackgroundTransparency = 0.68,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.1, 0, 0.62, 0),
		Size = UDim2.new(0.55, 0, 0, 2),
		ZIndex = zIndex + 1
	}, parent2)

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "Dirt",
		BackgroundColor3 = Color3.fromRGB(52, 40, 28),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Position = UDim2.new(0.68, 0, 0.2, 0),
		Size = UDim2.new(0, 5, 0, 4),
		ZIndex = zIndex + 1
	}, parent2)

	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
	return parent2
end

function FreePlaySyncStyle.AddPaperDecor(parent, value, value2, p)
	local zIndex = value2 or 20
	local random = Random.new(value or 7)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "PaperDecor",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = zIndex
	}, parent)

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "Grime",
		BackgroundColor3 = Color3.fromRGB(8, 6, 4),
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = zIndex
	}, parent2)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent3) -- inferred equivalent call
	mk("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.93),
			NumberSequenceKeypoint.new(0.6, 0.82),
			NumberSequenceKeypoint.new(1, 0.56)
		})
	}, parent3)

	for i = 1, 4 do
		local integer = random:NextInteger(24, 56)
		local parent4 = mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 2 == 0 and palette.RUST or Color3.fromRGB(40, 30, 20),
			BackgroundTransparency = 0.82 + random:NextNumber() * 0.08,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.7),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.4 + random:NextNumber() * 0.4)))),
			ZIndex = zIndex + 1
		}, parent2)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
	end

	for i = 1, 5 do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = Color3.fromRGB(14, 12, 10),
			BackgroundTransparency = 0.6 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.85, random:NextNumber() * 0.9),
			Size = UDim2.new(0, random:NextInteger(16, 44), 0, 1),
			Rotation = random:NextInteger(-55, 55),
			ZIndex = zIndex + 1
		}, parent2)
	end

	for i = 1, 16 do
		local integer = random:NextInteger(1, 2)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = Color3.fromRGB(20, 16, 12),
			BackgroundTransparency = 0.45 + random:NextNumber() * 0.3,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, integer),
			ZIndex = zIndex + 1
		}, parent2)
	end

	if p then
		mk("Frame", { -- inferred equivalent call
			Name = "Crease",
			BackgroundColor3 = Color3.fromRGB(40, 32, 22),
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = zIndex + 1
		}, parent2)
	end

	local parent4 = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6),
		ZIndex = zIndex + 1
	}, parent2)

	mk("UIStroke", { Color = palette.PAPER_EDGE, Thickness = 1.5, Transparency = 0.45 }, parent4) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent4) -- inferred equivalent call
	return parent2
end

function FreePlaySyncStyle.AddMarkerUnderline(parent, p, p2, p3, value)
	local zIndex = value or 6
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "MarkerLine1",
		BackgroundColor3 = palette.MARKER,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, p, 0, p2),
		Size = UDim2.new(0, p3, 0, 3),
		Rotation = -1.6,
		ZIndex = zIndex
	}, parent)

	mk("UICorner", { CornerRadius = UDim.new(0, 1) }, parent2) -- inferred equivalent call
	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "MarkerLine2",
		BackgroundColor3 = palette.MARKER,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, p + 10, 0, p2 + 5),
		Size = UDim2.new(0, math.floor(p3 * 0.7), 0, 2),
		Rotation = 1.2,
		ZIndex = zIndex
	}, parent)

	mk("UICorner", { CornerRadius = UDim.new(0, 1) }, parent3) -- inferred equivalent call
end

function FreePlaySyncStyle:StylePaperButton(p, value)
	self.BackgroundColor3 = palette.PAPER
	self.BorderSizePixel = 0
	self.AutoButtonColor = false
	self.Font = FreePlaySyncStyle.FONT_HEAD
	self.TextSize = 20
	self.TextColor3 = palette.INK
	local v = { CornerRadius = UDim.new(0, 2) }
	local uiCorner = Instance.new("UICorner")
	local v2 = value or 0

	for k, v3 in pairs(v) do
		uiCorner[k] = v3
	end

	uiCorner.Parent = self

	mk("UIStroke", { -- inferred equivalent call
		Color = palette.INK,
		Thickness = 1.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, self)
	FreePlaySyncStyle.AddPaperDecor(self, p, v2 + 20, false)
	FreePlaySyncStyle.AddTape(
		self,
		"TapeTopLeft",
		UDim2.new(0, 8, 0, 2),
		UDim2.new(0, 32, 0, 9),
		-34,
		palette.TAPE,
		0.14,
		v2 + 30
	)
	FreePlaySyncStyle.AddTape(
		self,
		"TapeBottomRight",
		UDim2.new(1, -10, 1, -2),
		UDim2.new(0, 26, 0, 8),
		-30,
		palette.TAPE_DARK,
		0.18,
		v2 + 30
	)
end

function FreePlaySyncStyle:SetPaperButtonActive(p)
	self.BackgroundColor3 = p and palette.AMBER or palette.PAPER
	self.TextColor3 = p and palette.AMBER_TEXT or palette.INK
end

function FreePlaySyncStyle:StyleTapeButton(p)
	self.BackgroundColor3 = p or palette.TAPE_BLACK
	self.BorderSizePixel = 0
	self.AutoButtonColor = true
	self.Font = FreePlaySyncStyle.FONT_HEAD
	self.TextSize = 22
	self.TextColor3 = palette.TAPE
	mk("UICorner", { CornerRadius = UDim.new(0, 1) }, self) -- inferred equivalent call
	mk( -- inferred equivalent call
		"UIStroke",
		{
			Color = palette.WINDOW_STROKE,
			Thickness = 1.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		self
	)
	local zIndex = self.ZIndex + 1
	mk("Frame", { -- inferred equivalent call
		Name = "Streak",
		BackgroundColor3 = Color3.fromRGB(70, 56, 38),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Active = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.06, 0, 0.86, 0),
		Size = UDim2.new(0.5, 0, 0, 2),
		ZIndex = zIndex
	}, self)

	local parent = mk("Frame", { -- inferred equivalent call
		Name = "Dirt",
		BackgroundColor3 = Color3.fromRGB(52, 40, 28),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0.8, 0, 0.12, 0),
		Size = UDim2.new(0, 5, 0, 4),
		ZIndex = zIndex
	}, self)

	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
end

function FreePlaySyncStyle.CreateSlider(parent, data)
	local zIndex = data.ZIndex or 6
	local v = mk("TextButton", { -- inferred equivalent call
		Name = data.Name or "Slider",
		Position = data.Position,
		Size = data.Size,
		BackgroundColor3 = palette.SURFACE,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		ClipsDescendants = true,
		ZIndex = zIndex
	}, parent)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, v) -- inferred equivalent call
	mk("UIStroke", { -- inferred equivalent call
		Color = palette.INK,
		Thickness = 1.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, v)
	local frame = mk("Frame", { -- inferred equivalent call
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = palette.SELECTED,
		BorderSizePixel = 0,
		ZIndex = zIndex + 1
	}, v)
	local frame2 = mk("Frame", { -- inferred equivalent call
		Name = "Knob",
		Size = UDim2.new(0, 4, 1, -4),
		BackgroundColor3 = palette.TAPE,
		BorderSizePixel = 0,
		ZIndex = zIndex + 3
	}, v)
	local v2 = {
		Name = "Label",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Font = FreePlaySyncStyle.FONT_BODY,
		TextSize = 13,
		TextColor3 = palette.TEXT,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.45,
		Text = "",
		ZIndex = zIndex + 2
	}
	local textLabel = Instance.new("TextLabel")

	for k, v3 in pairs(v2) do
		textLabel[k] = v3
	end

	textLabel.Parent = v

	local v3 = nil
	local function setFromX(x) -- 2 equivalent calls inferred from this helper
		local x2 = v.AbsoluteSize.X

		if x2 <= 0 then
			return
		end

		data.OnAlpha((math.clamp((x - v.AbsolutePosition.X) / x2, 0, 1)))
	end
	v.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v3 = input
			setFromX(input.Position.X) -- inferred equivalent call
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not v3 then
			return
		end

		if
			input == v3
			or v3.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseMovement
		then
			setFromX(input.Position.X) -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if
			v3
			and (input == v3 or v3.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)
		then
			v3 = nil
		end
	end)

	local slider = { Track = v }
	function slider.Update(p, text, p2)
		frame.Size = UDim2.new(p, 0, 1, 0)
		frame.BackgroundColor3 = p2 and palette.AMBER or palette.SELECTED
		frame2.AnchorPoint = Vector2.new(p, 0.5)
		frame2.Position = UDim2.new(p, 0, 0.5, 0)
		textLabel.Text = text
	end
	return slider
end

return FreePlaySyncStyle