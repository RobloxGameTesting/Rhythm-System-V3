local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local ToastStyle = require(ReplicatedStorage.Modules.SongListUI:WaitForChild("ToastStyle"))

local PStudioSkin = {}

local mk = ToastStyle.mk
local Quad = Enum.EasingStyle.Quad
local Back = Enum.EasingStyle.Back
local Out = Enum.EasingDirection.Out
local PermanentMarker = Enum.Font.PermanentMarker
local SpecialElite = Enum.Font.SpecialElite

local v = {
	SLATE = Color3.fromRGB(35, 41, 39),
	SLATE_DEEP = Color3.fromRGB(26, 31, 29),
	SLATE_LIGHT = Color3.fromRGB(46, 54, 51),
	CHALK = Color3.fromRGB(234, 232, 222),
	CHALK_DIM = Color3.fromRGB(160, 164, 156),
	CHALK_FAINT = Color3.fromRGB(94, 102, 97),
	GHOST = Color3.fromRGB(56, 64, 61),
	YELLOW = Color3.fromRGB(218, 198, 132),
	WOOD = Color3.fromRGB(78, 50, 40),
	WOOD_DARK = Color3.fromRGB(42, 26, 21),
	WOOD_LIGHT = Color3.fromRGB(120, 82, 64)
}

local function F(p, items)
	local v2 = { BorderSizePixel = 0 }

	for k, item in pairs(items) do
		v2[k] = item
	end

	return mk("Frame", v2, p)
end

local function round(p, p2) -- 6 equivalent calls inferred from this helper
	mk("UICorner", {
		CornerRadius = p2 or UDim.new(1, 0)
	}, p)
end

local function stroke(p, color, strokeTh) -- 17 equivalent calls inferred from this helper
	return mk("UIStroke", {
		Color = color,
		Thickness = strokeTh,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, p)
end

local function ink(instance) -- 5 equivalent calls inferred from this helper
	instance:SetAttribute("Ink", true)
	return instance
end

local function inkF(p, backgroundColor, p2) -- 12 equivalent calls inferred from this helper
	p2.BackgroundColor3 = backgroundColor
	return ink(F(p, p2)) -- inferred equivalent call
end

local function label(p, text, options)
	local v2 = {
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = v.CHALK,
		Font = SpecialElite,
		TextSize = 14,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4
	}

	for k, v3 in pairs(options or {}) do
		v2[k] = v3
	end

	return mk("TextLabel", v2, p)
end

local v2 = {}

local function newIcon(p, name, p2) -- 7 equivalent calls inferred from this helper
	return F(p, { Name = name, BackgroundTransparency = 1, Size = UDim2.fromOffset(p2, p2) })
end

local function gapF(p, backgroundColor, p2)
	p2.BackgroundColor3 = backgroundColor
	local v3 = F(p, p2)
	v3:SetAttribute("Gap", true)
	return v3
end

function v2.note(p, p2, backgroundColor)
	local icon = newIcon(p, "IconNote", p2) -- inferred equivalent call

	for _, v3 in ipairs({
		{ 0.25, 0.8 },
		{ 0.75, 0.7 }
	}) do
		local v4 = inkF(icon, backgroundColor, { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(v3[1], v3[2]),
			Size = UDim2.fromScale(0.34, 0.24),
			Rotation = -20
		})
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, v4)
	end

	inkF(icon, backgroundColor, { -- inferred equivalent call
		Position = UDim2.fromScale(0.36, 0.18),
		Size = UDim2.fromScale(0.09, 0.62)
	})
	inkF(icon, backgroundColor, { -- inferred equivalent call
		Position = UDim2.fromScale(0.86, 0.08),
		Size = UDim2.fromScale(0.09, 0.62)
	})
	inkF(icon, backgroundColor, { -- inferred equivalent call
		Position = UDim2.fromScale(0.36, 0.1),
		Size = UDim2.fromScale(0.6, 0.14),
		Rotation = -6
	})
	return icon
end

function v2.globe(p, p2, backgroundColor)
	local icon = newIcon(p, "IconGlobe", p2) -- inferred equivalent call
	local v3 = F(icon, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, v3)
	ink(stroke(v3, backgroundColor, 2)) -- inferred equivalent call
	local v4 = F(icon, {
		Position = UDim2.fromScale(0.28, 0),
		Size = UDim2.fromScale(0.44, 1),
		BackgroundTransparency = 1
	})
	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, v4)
	ink(stroke(v4, backgroundColor, 1.5)) -- inferred equivalent call
	inkF(icon, backgroundColor, { -- inferred equivalent call
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 2)
	})
	return icon
end

function v2.lock(p, p2, backgroundColor, backgroundColor2)
	local icon = newIcon(p, "IconLock", p2) -- inferred equivalent call
	local v3 = F(icon, {
		Position = UDim2.fromScale(0.26, 0.02),
		Size = UDim2.fromScale(0.48, 0.62),
		BackgroundTransparency = 1
	})
	mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, v3)
	ink(stroke(v3, backgroundColor, 2)) -- inferred equivalent call
	mk(
		"UICorner",
		{ CornerRadius = UDim.new(0, 2) },
		inkF(icon, backgroundColor, { -- inferred equivalent call
			Position = UDim2.fromScale(0.1, 0.42),
			Size = UDim2.fromScale(0.8, 0.54),
			ZIndex = 2
		})
	)
	local v4 = {
		Position = UDim2.fromScale(0.44, 0.58),
		Size = UDim2.fromScale(0.12, 0.22),
		ZIndex = 3
	}
	v4.BackgroundColor3 = backgroundColor2
	F(icon, v4):SetAttribute("Gap", true)

	return icon
end

function v2.plus(p, p2, backgroundColor)
	local icon = newIcon(p, "IconPlus", p2) -- inferred equivalent call
	inkF(icon, backgroundColor, { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 0, 0.26, 0)
	})
	inkF(icon, backgroundColor, { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.26, 0, 1, 0)
	})
	return icon
end

function v2.cross(p, p2, backgroundColor)
	local icon = newIcon(p, "IconCross", p2) -- inferred equivalent call

	for _, rotation in ipairs({ 45, -45 }) do
		inkF(icon, backgroundColor, { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1.25, 0, 0.2, 0),
			Rotation = rotation
		})
	end

	return icon
end

function v2.star(p, p2, backgroundColor)
	local icon = newIcon(p, "IconStar", p2) -- inferred equivalent call

	for _, rotation in ipairs({ 0, 45 }) do
		inkF(icon, backgroundColor, { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.68, 0.68),
			Rotation = rotation
		})
	end

	return icon
end

function v2.refresh(p, p2, backgroundColor, backgroundColor2)
	local icon = newIcon(p, "IconRefresh", p2) -- inferred equivalent call
	local v3 = F(icon, {
		Position = UDim2.fromScale(0.07, 0.1),
		Size = UDim2.fromScale(0.86, 0.86),
		BackgroundTransparency = 1
	})
	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, v3)
	ink(stroke(v3, backgroundColor, 2)) -- inferred equivalent call
	local v4 = { Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.5, 0.42), ZIndex = 2 }
	v4.BackgroundColor3 = backgroundColor2
	F(icon, v4):SetAttribute("Gap", true)

	inkF(icon, backgroundColor, { -- inferred equivalent call
		Position = UDim2.fromScale(0.58, 0.02),
		Size = UDim2.fromScale(0.4, 0.14),
		ZIndex = 3
	})
	inkF(icon, backgroundColor, { -- inferred equivalent call
		Position = UDim2.fromScale(0.84, 0.02),
		Size = UDim2.fromScale(0.14, 0.4),
		ZIndex = 3
	})
	return icon
end

local function paintIcon(folder, slate, chalk)
	if not folder then
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:GetAttribute("Ink") then
			if descendant:IsA("UIStroke") then
				descendant.Color = slate
			elseif descendant:IsA("TextLabel") then
				descendant.TextColor3 = slate
			else
				descendant.BackgroundColor3 = slate
			end
		elseif descendant:GetAttribute("Gap") and chalk then
			descendant.BackgroundColor3 = chalk
		end
	end
end

local function edgeShade(p, backgroundColor, p2, p3)
	local function edge(anchorPoint, position, size, rotation)
		local v3 = F(p, {
			AnchorPoint = anchorPoint,
			Position = position,
			Size = size,
			BackgroundColor3 = backgroundColor,
			ZIndex = 2
		})
		mk("UIGradient", {
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p2), NumberSequenceKeypoint.new(1, 1) })
		}, v3)
	end
	edge(Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.new(0, p3, 1, 0), 0)
	edge(Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.new(0, p3, 1, 0), 180)
	edge(Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.new(1, 0, 0, p3), 90)
	edge(Vector2.new(0, 1), UDim2.fromScale(0, 1), UDim2.new(1, 0, 0, p3), 270)
end

local function chalkGrime(p, random)
	edgeShade(p, Color3.new(0, 0, 0), 0.45, 28)

	for _ = 1, 6 do
		local integer = random:NextInteger(90, 200)
		local v3, v4 = F(p, {
			Position = UDim2.fromScale(random:NextNumber() * 0.9, random:NextNumber() * 0.9),
			Size = UDim2.fromOffset(integer, integer * (0.45 + random:NextNumber() * 0.4)),
			BackgroundColor3 = v.CHALK,
			BackgroundTransparency = 0.965 + random:NextNumber() * 0.02,
			Rotation = random:NextInteger(-30, 30),
			ZIndex = 2
		})
		round(v3, v4) -- inferred equivalent call
	end

	for _ = 1, 4 do
		local v3, v4 = F(p, {
			Position = UDim2.fromScale(random:NextNumber() * 0.7, random:NextNumber() * 0.85),
			Size = UDim2.fromOffset(random:NextInteger(180, 320), random:NextInteger(14, 26)),
			BackgroundColor3 = v.CHALK,
			BackgroundTransparency = 0.968,
			Rotation = random:NextInteger(-22, 22),
			ZIndex = 2
		})
		round(v3, v4) -- inferred equivalent call
	end

	for _ = 1, 10 do
		F(p, {
			Position = UDim2.fromScale(random:NextNumber() * 0.9, random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(20, 90), 1),
			Rotation = random:NextInteger(-40, 40),
			BackgroundColor3 = v.CHALK,
			BackgroundTransparency = 0.88 + random:NextNumber() * 0.07,
			ZIndex = 2
		})
	end

	for _ = 1, 110 do
		F(p, {
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(1, 2), random:NextInteger(1, 2)),
			BackgroundColor3 = v.CHALK,
			BackgroundTransparency = 0.6 + random:NextNumber() * 0.28,
			ZIndex = 2
		})
	end

	local note = v2.note(p, 74, v.GHOST)
	note.Position = UDim2.new(1, -96, 1, -104)
	note.Rotation = 8
	note.ZIndex = 2
end

local function attachFx(data, p)
	local v3 = mk("UIScale", { Name = "Fx", Scale = 1 }, p)
	local v4 = false
	data.MouseEnter:Connect(function()
		v4 = true
		ToastStyle.tween(v3, 0.1, Quad, Out, { Scale = 1.04 })
	end)
	data.MouseLeave:Connect(function()
		v4 = false
		ToastStyle.tween(v3, 0.12, Quad, Out, { Scale = 1 })
	end)
	data.MouseButton1Down:Connect(function()
		ToastStyle.tween(v3, 0.06, Quad, Out, { Scale = 0.94 })
	end)
	data.MouseButton1Up:Connect(function()
		ToastStyle.tween(v3, 0.1, Back, Out, {
			Scale = v4 and 1.04 or 1
		})
	end)
	return v3
end

local function chalkButton(p, data)
	local btn = mk("TextButton", {
		Name = data.name,
		AutoButtonColor = false,
		Text = "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = data.size,
		Position = data.pos or UDim2.new(),
		AnchorPoint = data.anchor or Vector2.new(0, 0),
		ZIndex = data.z or 24
	}, p)

	local art = F(btn, {
		Name = "Art",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	})
	local bg = F(art, {
		Name = "Bg",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = data.color,
		Rotation = data.rot or 0,
		ZIndex = 2
	})
	local stroke2 = stroke(bg, data.strokeColor or v.CHALK, data.strokeTh or 2) -- inferred equivalent call
	local label2 = label(btn, data.text or "", {
		Name = "Label",
		Font = data.font or PermanentMarker,
		TextSize = data.textSize or 15,
		TextColor3 = data.textColor or v.CHALK,
		ZIndex = 4,
		TextScaled = data.scaled or false
	})

	if data.scaled then
		mk("UITextSizeConstraint", {
			MaxTextSize = data.textSize or 15,
			MinTextSize = 8
		}, label2)
	end

	if data.pad then
		mk("UIPadding", {
			PaddingLeft = UDim.new(0, data.pad),
			PaddingRight = UDim.new(0, data.padR or 6)
		}, label2)
	end

	local icon

	if data.icon then
		icon = v2[data.icon](btn, data.iconSize or 16, data.iconColor or v.CHALK, data.gap or data.color)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0, data.iconX or 16, 0.5, 0)
		icon.ZIndex = 3
	end

	if not data.static then
		attachFx(btn, art)
	end

	return {
		Btn = btn,
		Art = art,
		Bg = bg,
		Stroke = stroke2,
		Label = label2,
		Icon = icon
	}
end

local function setActive(data, p)
	ToastStyle.tween(data.Bg, 0.15, Quad, Out, {
		BackgroundColor3 = p and v.CHALK or v.SLATE_LIGHT
	})
	data.Stroke.Color = p and v.CHALK or v.CHALK_DIM
	data.Label.TextColor3 = p and v.SLATE or v.CHALK_DIM
	paintIcon(data.Icon, p and v.SLATE or v.CHALK_DIM, p and v.CHALK or v.SLATE_LIGHT)
end

function PStudioSkin.Build(parent, data)
	local random = Random.new(2026)

	local panel = mk("Frame", {
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.62, 0.7),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10
	})

	panel:SetAttribute("NoNewUISkin", true)
	mk("UISizeConstraint", { MinSize = Vector2.new(320, 310), MaxSize = Vector2.new(560, 460) }, panel)
	local v3 = mk("UIScale", { Name = "PopScale", Scale = 1 }, panel)

	F(panel, {
		Name = "DropShadow",
		Position = UDim2.fromOffset(6, 9),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		ZIndex = 8
	})
	local v4 = F(panel, {
		Name = "Board",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = v.WOOD,
		ZIndex = 10
	})
	stroke(v4, v.WOOD_DARK, 2) -- inferred equivalent call
	local v5 = {}

	for i = 1, 14 do
		F(v4, {
			Position = UDim2.new(0, 0, i / 15, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = v.WOOD_DARK,
			BackgroundTransparency = 0.72 + random:NextNumber() * 0.15,
			ZIndex = 1
		})
	end

	F(v4, {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = v.WOOD_LIGHT,
		BackgroundTransparency = 0.4,
		ZIndex = 2
	})
	F(v4, {
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = v.WOOD_LIGHT,
		BackgroundTransparency = 0.5,
		ZIndex = 2
	})

	for _, position in ipairs({
		UDim2.fromOffset(4, 4),
		UDim2.new(1, -4, 0, 4),
		UDim2.new(0, 4, 1, -4),
		UDim2.new(1, -4, 1, -4)
	}) do
		local v6 = F(v4, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = UDim2.fromOffset(5, 5),
			BackgroundColor3 = v.WOOD_DARK,
			ZIndex = 3
		})
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, v6)
	end

	local v6 = F(panel, {
		Name = "Slate",
		Position = UDim2.fromOffset(9, 9),
		Size = UDim2.new(1, -18, 1, -18),
		BackgroundColor3 = v.SLATE,
		ClipsDescendants = true,
		ZIndex = 12
	})

	stroke(v6, v.WOOD_DARK, 2) -- inferred equivalent call
	chalkGrime(v6, random)

	F(panel, {
		Name = "LedgeShade",
		Position = UDim2.new(0, 9, 1, -29),
		Size = UDim2.new(1, -18, 0, 6),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		ZIndex = 13
	})
	local v7 = F(panel, {
		Name = "Ledge",
		Position = UDim2.new(0, 9, 1, -23),
		Size = UDim2.new(1, -18, 0, 14),
		BackgroundColor3 = v.WOOD,
		ZIndex = 14
	})
	stroke(v7, v.WOOD_DARK, 1.5) -- inferred equivalent call
	F(v7, {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = v.WOOD_LIGHT,
		BackgroundTransparency = 0.35,
		ZIndex = 2
	})

	for i, v8 in ipairs({
		{ 22, 24, 6, -4 },
		{ 52, 18, 6, 3 },
		{ 76, 9, 6, -8 }
	}) do
		round(F(panel, { -- inferred equivalent call
			Name = "Chalk" .. i,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 9 + v8[1], 1, -23),
			Size = UDim2.fromOffset(v8[2], v8[3]),
			BackgroundColor3 = v.CHALK,
			Rotation = v8[4],
			ZIndex = 15
		}), UDim.new(0, 2))
	end

	local v8 = F(panel, {
		Name = "Eraser",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -30, 1, -23),
		Size = UDim2.fromOffset(38, 12),
		BackgroundColor3 = Color3.fromRGB(126, 96, 72),
		ZIndex = 15
	})

	round(v8, UDim.new(0, 2)) -- inferred equivalent call
	stroke(v8, v.WOOD_DARK, 1) -- inferred equivalent call
	round( -- inferred equivalent call
		F(v8, {
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(34, 32, 30),
			ZIndex = 2
		}),
		UDim.new(0, 2)
	)
	local v9, v10 = F(panel, {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -33),
		Size = UDim2.fromOffset(46, 7),
		BackgroundColor3 = v.CHALK,
		BackgroundTransparency = 0.93,
		ZIndex = 14
	})
	round(v9, v10) -- inferred equivalent call
	local v11 = F(panel, {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(22, 22),
		Size = UDim2.new(1, -44, 1, -58),
		ZIndex = 20
	})

	local v12 = F(v11, {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 46),
		ZIndex = 22
	})
	local note = v2.note(v12, 22, v.CHALK)
	note.Position = UDim2.fromOffset(2, 6)
	note.ZIndex = 22
	label(v12, data.Title, {
		Name = "Title",
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -74, 0, 40),
		Font = PermanentMarker,
		TextSize = 30,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 22
	})

	local x = TextService:GetTextSize(data.Title, 30, PermanentMarker, Vector2.new(1000, 100)).X
	F(v12, {
		Name = "Underline1",
		Position = UDim2.fromOffset(34, 38),
		Size = UDim2.fromOffset(x, 2),
		Rotation = -0.5,
		BackgroundColor3 = v.CHALK,
		BackgroundTransparency = 0.12,
		ZIndex = 21
	})
	F(v12, {
		Name = "Underline2",
		Position = UDim2.fromOffset(34 + x * 0.08, 43),
		Size = UDim2.fromOffset(x * 0.62, 2),
		Rotation = 0.5,
		BackgroundColor3 = v.YELLOW,
		BackgroundTransparency = 0.25,
		ZIndex = 21
	})

	local v13 = chalkButton(v12, {
		name = "Close",
		size = UDim2.fromOffset(30, 30),
		anchor = Vector2.new(1, 0),
		pos = UDim2.new(1, 0, 0, 3),
		color = v.SLATE_LIGHT,
		rot = 2,
		icon = "cross",
		iconSize = 14,
		iconX = 15,
		iconColor = v.CHALK,
		z = 26
	})

	local v14 = F(v11, {
		Name = "Tabs",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 0, 36),
		ZIndex = 22
	})
	local v15 = chalkButton(v14, {
		name = "TabList",
		size = UDim2.new(0.5, -4, 1, 0),
		color = v.CHALK,
		rot = -0.4,
		text = data.TabList,
		textSize = 15,
		scaled = true,
		textColor = v.SLATE,
		icon = "note",
		iconSize = 18,
		iconX = 17,
		iconColor = v.SLATE,
		pad = 30,
		z = 24
	})

	local v16 = chalkButton(v14, {
		name = "TabCreate",
		size = UDim2.new(0.5, -4, 1, 0),
		anchor = Vector2.new(1, 0),
		pos = UDim2.fromScale(1, 0),
		color = v.SLATE_LIGHT,
		rot = 0.4,
		text = data.TabCreate:gsub("^%+%s*", ""),
		textSize = 15,
		scaled = true,
		textColor = v.CHALK_DIM,
		icon = "plus",
		iconSize = 15,
		iconX = 17,
		iconColor = v.CHALK_DIM,
		pad = 30,
		z = 24
	})

	function v5.SetTab(p)
		setActive(v15, p == "list")
		setActive(v16, p == "create")
	end

	local v17 = F(v11, {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 94),
		Size = UDim2.new(1, 0, 1, -94),
		ZIndex = 22
	})

	local listView = F(v17, {
		Name = "ListView",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	})
	local scroll = mk("ScrollingFrame", {
		Name = "List",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -36),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = v.CHALK_DIM,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ZIndex = 2
	}, listView)

	mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
	mk(
		"UIPadding",
		{
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 4)
		},
		scroll
	)

	local empty = F(listView, {
		Name = "Empty",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -36),
		Visible = false,
		ZIndex = 3
	})
	local note2 = v2.note(empty, 44, v.CHALK_DIM)
	note2.AnchorPoint = Vector2.new(0.5, 0.5)
	note2.Position = UDim2.new(0.5, 0, 0.5, -28)
	label(empty, data.Empty, {
		Position = UDim2.new(0, 0, 0.5, 4),
		Size = UDim2.new(1, 0, 0, 24),
		Font = PermanentMarker,
		TextSize = 18
	})
	label(empty, "// be the first. make some noise.", {
		Position = UDim2.new(0, 0, 0.5, 28),
		Size = UDim2.new(1, 0, 0, 16),
		TextSize = 12,
		TextColor3 = v.CHALK_DIM
	})

	local v18 = F(listView, {
		Name = "CutLine",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, -32),
		Size = UDim2.new(1, 0, 0, 2),
		ClipsDescendants = true,
		ZIndex = 3
	})

	for i = 0, 60 do
		F(v18, {
			Position = UDim2.fromOffset(i * 10, 0),
			Size = UDim2.fromOffset(6, 2),
			BackgroundColor3 = v.CHALK_FAINT,
			BackgroundTransparency = 0.2
		})
	end

	local free = label(listView, "", {
		Name = "Free",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, -112, 0, 26),
		TextSize = 12,
		TextColor3 = v.CHALK_DIM,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3
	})

	local v19 = chalkButton(listView, {
		name = "Refresh",
		size = UDim2.fromOffset(104, 27),
		anchor = Vector2.new(1, 1),
		pos = UDim2.fromScale(1, 1),
		color = v.SLATE_LIGHT,
		strokeColor = v.CHALK_DIM,
		strokeTh = 1.5,
		text = data.Refresh:upper(),
		textSize = 12,
		icon = "refresh",
		iconSize = 13,
		iconX = 15,
		iconColor = v.CHALK,
		gap = v.SLATE_LIGHT,
		pad = 26,
		z = 5
	})

	local createView = F(v17, {
		Name = "CreateView",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false
	})
	label(createView, "NAME YOUR STUDIO", {
		Position = UDim2.fromOffset(2, 0),
		Size = UDim2.fromOffset(160, 15),
		Font = PermanentMarker,
		TextSize = 12,
		TextColor3 = v.CHALK_DIM,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3
	})

	local hint = label(createView, "", {
		Name = "Hint",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -2, 0, 0),
		Size = UDim2.new(1, -170, 0, 15),
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = v.CHALK_FAINT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3
	})

	local nameBox = mk("TextBox", {
		Name = "NameBox",
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = v.SLATE_DEEP,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		PlaceholderText = data.NamePlaceholder,
		PlaceholderColor3 = v.CHALK_FAINT,
		Text = "",
		TextColor3 = v.CHALK,
		Font = SpecialElite,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2
	}, createView)

	mk("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, nameBox)
	local v20 = stroke(nameBox, v.CHALK_DIM, 2) -- inferred equivalent call
	nameBox.Focused:Connect(function()
		v20.Color = v.YELLOW
	end)
	nameBox.FocusLost:Connect(function()
		v20.Color = v.CHALK_DIM
	end)

	local v21 = F(createView, {
		Name = "VisRow",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 56),
		Size = UDim2.new(1, 0, 0, 34),
		ZIndex = 2
	})
	local v22 = chalkButton(v21, {
		name = "Public",
		size = UDim2.new(0.5, -4, 1, 0),
		color = v.CHALK,
		rot = -0.5,
		text = data.Public,
		textSize = 16,
		textColor = v.SLATE,
		icon = "globe",
		iconSize = 18,
		iconX = 20,
		iconColor = v.SLATE,
		pad = 36,
		z = 3
	})

	local v23 = chalkButton(v21, {
		name = "Private",
		size = UDim2.new(0.5, -4, 1, 0),
		anchor = Vector2.new(1, 0),
		pos = UDim2.fromScale(1, 0),
		color = v.SLATE_LIGHT,
		rot = 0.5,
		text = data.Private,
		textSize = 16,
		icon = "lock",
		iconSize = 18,
		iconX = 20,
		iconColor = v.CHALK_DIM,
		pad = 36,
		z = 3
	})

	local passRow = F(createView, {
		Name = "PassRow",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.new(1, 0, 0, 30),
		Visible = false,
		ZIndex = 2
	})
	local passBox = mk("TextBox", {
		Name = "PassBox",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = v.SLATE_DEEP,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		PlaceholderText = data.PasswordPlaceholder,
		PlaceholderColor3 = v.CHALK_FAINT,
		Text = "",
		TextColor3 = v.CHALK,
		Font = SpecialElite,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2
	}, passRow)

	mk("UIPadding", { PaddingLeft = UDim.new(0, 34), PaddingRight = UDim.new(0, 12) }, passBox)
	local v24 = stroke(passBox, v.CHALK_DIM, 2) -- inferred equivalent call
	passBox.Focused:Connect(function()
		v24.Color = v.YELLOW
	end)
	passBox.FocusLost:Connect(function()
		v24.Color = v.CHALK_DIM
	end)
	local v25 = v2.lock(passRow, 16, v.CHALK_DIM, v.SLATE_DEEP)
	v25.AnchorPoint = Vector2.new(0.5, 0.5)
	v25.Position = UDim2.new(0, 18, 0.5, 0)
	v25.ZIndex = 3

	local v26 = chalkButton(createView, {
		name = "Create",
		size = UDim2.new(1, 0, 0, 38),
		pos = UDim2.fromOffset(0, 100),
		color = v.CHALK,
		rot = -0.3,
		text = data.CreateButton,
		textSize = 24,
		textColor = v.SLATE,
		icon = "star",
		iconSize = 16,
		iconX = 24,
		iconColor = v.SLATE,
		z = 3
	})

	local star = v2.star(v26.Btn, 16, v.SLATE)
	star.AnchorPoint = Vector2.new(0.5, 0.5)
	star.Position = UDim2.new(1, -24, 0.5, 0)
	star.ZIndex = 3

	function v5.PaintSelectors(p)
		setActive(v22, p)
		setActive(v23, not p)
		passRow.Visible = not p
		v26.Btn.Position = UDim2.fromOffset(0, p and 100 or 132)
	end

	local frame = F(panel, {
		Name = "PasswordPrompt",
		Position = UDim2.fromOffset(9, 9),
		Size = UDim2.new(1, -18, 1, -18),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		Visible = false,
		Active = true,
		ZIndex = 40
	})

	local v27 = F(frame, {
		Name = "Card",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -48, 0, 150),
		BackgroundColor3 = v.SLATE,
		ZIndex = 41
	})

	mk("UISizeConstraint", { MaxSize = Vector2.new(330, 150) }, v27)
	stroke(v27, v.CHALK, 2) -- inferred equivalent call
	label(v27, data.PromptTitle, {
		Name = "Title",
		Position = UDim2.fromOffset(16, 10),
		Size = UDim2.new(1, -32, 0, 26),
		Font = PermanentMarker,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 42
	})

	local v28 = label(v27, "", {
		Name = "Sub",
		Position = UDim2.fromOffset(16, 37),
		Size = UDim2.new(1, -32, 0, 16),
		TextSize = 13,
		TextColor3 = v.CHALK_DIM,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 42
	})

	local box = mk("TextBox", {
		Name = "PromptBox",
		Position = UDim2.fromOffset(16, 60),
		Size = UDim2.new(1, -32, 0, 34),
		BackgroundColor3 = v.SLATE_DEEP,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		PlaceholderText = data.PromptPlaceholder,
		PlaceholderColor3 = v.CHALK_FAINT,
		Text = "",
		TextColor3 = v.CHALK,
		Font = SpecialElite,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 42
	}, v27)

	mk("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, box)
	local v29 = stroke(box, v.CHALK_DIM, 2) -- inferred equivalent call
	box.Focused:Connect(function()
		v29.Color = v.YELLOW
	end)
	box.FocusLost:Connect(function()
		v29.Color = v.CHALK_DIM
	end)
	local v30 = chalkButton(v27, {
		name = "Cancel",
		size = UDim2.new(0.5, -20, 0, 36),
		pos = UDim2.fromOffset(16, 102),
		color = v.SLATE_LIGHT,
		strokeColor = v.CHALK_DIM,
		rot = -0.4,
		text = data.PromptCancel,
		textSize = 15,
		textColor = v.CHALK_DIM,
		z = 43
	})

	v5.Prompt = {
		Frame = frame,
		Box = box,
		Join = chalkButton(v27, {
			name = "Join",
			size = UDim2.new(0.5, -20, 0, 36),
			anchor = Vector2.new(1, 0),
			pos = UDim2.new(1, -16, 0, 102),
			color = v.CHALK,
			rot = 0.4,
			text = data.PromptJoin,
			textSize = 16,
			textColor = v.SLATE,
			z = 43
		}).Btn,
		Cancel = v30.Btn
	}
	function v5.ShowPrompt(text)
		v28.Text = text
		box.Text = ""
		frame.Visible = true
		task.defer(function()
			if frame.Visible then
				box:CaptureFocus()
			end
		end)
	end
	function v5.HidePrompt()
		frame.Visible = false
		box.Text = ""
	end

	panel:GetPropertyChangedSignal("Visible"):Connect(function()
		if not panel.Visible then
			return
		end

		v3.Scale = 0.9
		ToastStyle.tween(v3, 0.34, Back, Out, { Scale = 1 })
	end)

	local btn = v13.Btn
	v5.Panel = panel
	v5.Close = btn
	local btn2 = v15.Btn
	local btn3 = v16.Btn
	v5.TabList = btn2
	v5.TabCreate = btn3
	local btn4 = v19.Btn
	v5.ListView = listView
	v5.Scroll = scroll
	v5.Empty = empty
	v5.Free = free
	v5.Refresh = btn4
	local btn5 = v22.Btn
	local btn6 = v23.Btn
	local btn7 = v26.Btn
	v5.CreateView = createView
	v5.NameBox = nameBox
	v5.Public = btn5
	v5.Private = btn6
	v5.Create = btn7
	v5.Hint = hint
	v5.PassRow = passRow
	v5.PassBox = passBox

	function v5.MakeRow(p, data2, layoutOrder, onMouseButton1Click)
		local static = data2.count >= data2.max
		local rotation = (layoutOrder * 37 % 5 - 2) * 0.25
		local row = F(p, {
			Name = "Row_" .. data2.studioId,
			Size = UDim2.new(1, -8, 0, 58),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			ZIndex = 11
		})
		local v31 = F(row, {
			Name = "Plate",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = v.SLATE_LIGHT,
			Rotation = rotation,
			ZIndex = 2
		})
		stroke(v31, v.CHALK_DIM, 1.5) -- inferred equivalent call
		local random2 = Random.new(layoutOrder * 97 + #data2.name)

		for _ = 1, 12 do
			F(v31, {
				Position = UDim2.fromScale(random2:NextNumber(), random2:NextNumber()),
				Size = UDim2.fromOffset(1, 1),
				BackgroundColor3 = v.CHALK,
				BackgroundTransparency = 0.7 + random2:NextNumber() * 0.2,
				ZIndex = 2
			})
		end

		local v32 = F(row, {
			Name = "Tile",
			Position = UDim2.fromOffset(9, 11),
			Size = UDim2.fromOffset(34, 34),
			BackgroundColor3 = v.SLATE_DEEP,
			Rotation = -3,
			ZIndex = 3
		})
		stroke(v32, v.CHALK, 2) -- inferred equivalent call
		local v47 = mk("ImageLabel", {
			Name = "OwnerAvatar",
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 1, -4),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Crop,
			Image = "",
			ZIndex = 4
		}, v32)

		local v48 = v2[data2.isPublic and "globe" or "lock"](row, 20, v.CHALK, v.SLATE_DEEP)
		v48.AnchorPoint = Vector2.new(0.5, 0.5)
		v48.Position = UDim2.fromOffset(26, 28)
		v48.ZIndex = 5

		if type(data2.ownerId) == "number" and data2.ownerId > 0 then
			local function showAvatar() -- 3 equivalent calls inferred from this helper
				if v48.Parent then
					v48.Visible = false
				end
			end
			v47.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", data2.ownerId)

			v47:GetPropertyChangedSignal("IsLoaded"):Connect(function()
				if v47.IsLoaded then
					showAvatar() -- inferred equivalent call
				end
			end)
			task.spawn(function()
				local ContentProvider = game:GetService("ContentProvider")
				pcall(ContentProvider.PreloadAsync, ContentProvider, { v47 })

				if v47.Parent and v47.IsLoaded then
					showAvatar() -- inferred equivalent call
				end
			end)

			if v47.IsLoaded then
				showAvatar() -- inferred equivalent call
			end
		end

		for i = 0, 5 do
			F(row, {
				Position = UDim2.fromOffset(50, i * 8 + 7),
				Size = UDim2.fromOffset(1, 4),
				BackgroundColor3 = v.CHALK_FAINT,
				ZIndex = 3
			})
		end

		label(row, data2.name, {
			Name = "Name",
			Position = UDim2.fromOffset(58, 4),
			Size = UDim2.new(1, -158, 0, 22),
			Font = PermanentMarker,
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 5
		})

		local v49 = F(row, {
			Name = "Sub",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(58, 27),
			Size = UDim2.new(1, -158, 0, 14),
			ZIndex = 5
		})
		mk(
			"UIListLayout",
			{
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			},
			v49
		)

		local v50 = label(v49, "@" .. data2.ownerName, {
			Name = "Owner",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 14),
			TextSize = 12,
			TextColor3 = v.CHALK_DIM,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 1,
			ZIndex = 5
		})

		mk("UISizeConstraint", { MaxSize = Vector2.new(96, 14) }, v50)
		local v51 = F(v49, {
			Name = "VisTag",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 13),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			ZIndex = 5
		})
		stroke(v51, v.CHALK_DIM, 1) -- inferred equivalent call
		local v52 = label(
			v51,
			data2.isPublic and data.Public or data2.hasPassword and data.PasswordTag or data.Private,
			{
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, 13),
				Font = PermanentMarker,
				TextSize = 10,
				TextColor3 = v.CHALK_DIM,
				ZIndex = 6
			}
		)

		mk("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) }, v52)

		if data2.max <= 10 then
			for i = 1, data2.max do
				stroke(F(row, { -- inferred equivalent call
					Name = "Pip" .. i,
					Position = UDim2.fromOffset((i - 1) * 13 + 58, 44),
					Size = UDim2.fromOffset(9, 9),
					BackgroundColor3 = v.CHALK,
					BackgroundTransparency = i <= data2.count and 0 or 1,
					Rotation = (i * 53 % 7 - 3) * 2,
					ZIndex = 5
				}), i <= data2.count and v.CHALK or v.CHALK_DIM, 1.5)
			end

			label(row, string.format("%d/%d", data2.count, data2.max), {
				Position = UDim2.fromOffset(58 + data2.max * 13 + 2, 41),
				Size = UDim2.fromOffset(40, 14),
				TextSize = 11,
				TextColor3 = v.CHALK_DIM,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5
			})
		else
			label(row, string.format("%d/%d", data2.count, data2.max), {
				Position = UDim2.fromOffset(58, 41),
				Size = UDim2.fromOffset(60, 14),
				TextSize = 11,
				TextColor3 = v.CHALK_DIM,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5
			})
		end

		local text = static and "FULL"
			or data2.isPublic and data.Join
			or data2.hasPassword and data.Unlock
			or data.Request
		local isPublic = not static and data2.isPublic
		local v54 = chalkButton(row, {
			name = "Action",
			size = UDim2.fromOffset(88, 34),
			anchor = Vector2.new(1, 0.5),
			pos = UDim2.new(1, -9, 0.5, 0),
			color = isPublic and v.CHALK or v.SLATE_LIGHT,
			strokeColor = static and v.CHALK_FAINT or v.CHALK,
			strokeTh = static and 1.5 or 2,
			rot = static and -1.5 or 1,
			text = text,
			textSize = 15,
			textColor = static and v.CHALK_FAINT or isPublic and v.SLATE or v.CHALK,
			static = static,
			z = 7
		})

		if not static then
			v54.Btn.MouseButton1Click:Connect(onMouseButton1Click)
		end

		return row
	end

	panel.Parent = parent
	return v5
end

return PStudioSkin