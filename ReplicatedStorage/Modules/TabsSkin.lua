local TabsSkin = {}
local TabsIcons = require(script.Parent.TabsIcons)

local function rgb(p, p2, p3) -- 28 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

TabsSkin.Palettes = {
	Dark = {
		Panel = rgb(20, 20, 19), -- inferred equivalent call
		Inset = rgb(12, 12, 11), -- inferred equivalent call
		Line = rgb(70, 68, 64), -- inferred equivalent call
		Text = rgb(222, 220, 214), -- inferred equivalent call
		Dim = rgb(158, 156, 150), -- inferred equivalent call
		Accent = rgb(204, 162, 72), -- inferred equivalent call
		Stroke = rgb(8, 8, 8), -- inferred equivalent call
		Button = rgb(32, 32, 30), -- inferred equivalent call
		ButtonHi = rgb(64, 62, 58), -- inferred equivalent call
		Warn = rgb(214, 96, 80), -- inferred equivalent call
		Border = rgb(86, 84, 80), -- inferred equivalent call
		Tape = rgb(206, 190, 150), -- inferred equivalent call
		Ink = rgb(14, 14, 13), -- inferred equivalent call
		Rust = rgb(74, 42, 28) -- inferred equivalent call
	},
	Light = {
		Panel = rgb(206, 196, 168), -- inferred equivalent call
		Inset = rgb(228, 220, 194), -- inferred equivalent call
		Line = rgb(148, 138, 114), -- inferred equivalent call
		Text = rgb(34, 30, 24), -- inferred equivalent call
		Dim = rgb(92, 84, 68), -- inferred equivalent call
		Accent = rgb(168, 98, 18), -- inferred equivalent call
		Stroke = rgb(40, 34, 28), -- inferred equivalent call
		Button = rgb(186, 174, 144), -- inferred equivalent call
		ButtonHi = rgb(164, 150, 118), -- inferred equivalent call
		Warn = rgb(162, 40, 30), -- inferred equivalent call
		Border = rgb(110, 100, 82), -- inferred equivalent call
		Tape = rgb(226, 212, 172), -- inferred equivalent call
		Ink = rgb(20, 18, 14), -- inferred equivalent call
		Rust = rgb(120, 70, 40) -- inferred equivalent call
	}
}

TabsSkin.FontLabel = Enum.Font.Oswald
TabsSkin.FontBody = Enum.Font.SpecialElite
TabsSkin.FontNum = Enum.Font.Oswald

local function mk(className, items, parent) -- 25 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
		instance.Active = false
	end

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function nameHash(value)
	local v = 0

	for i = 1, #value do
		v = (v * 31 + value:byte(i)) % 100003
	end

	return v
end

local function tape(parent, name, position, size, rotation, tape2, zIndex, p, text, ink)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = tape2,
		BackgroundTransparency = 0.04,
		AnchorPoint = p or Vector2.new(0, 0),
		Position = position,
		Size = size,
		Rotation = rotation,
		ZIndex = zIndex
	}, parent)

	mk("Frame", { -- inferred equivalent call
		Name = "Crease",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.72,
		Position = UDim2.new(0, 0, 0.3, 0),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = zIndex
	}, parent2)
	mk("Frame", { -- inferred equivalent call
		Name = "Shade",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.78,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		ZIndex = zIndex
	}, parent2)
	local random = Random.new(nameHash(name) + 17)

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Dirt" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7 + random:NextNumber() * 0.15,
			Position = UDim2.new(random:NextNumber() * 0.8, 0, random:NextNumber() * 0.6, 0),
			Size = UDim2.fromOffset(random:NextInteger(3, 9), random:NextInteger(2, 4)),
			ZIndex = zIndex
		}, parent2)
	end

	if text then
		local parent3 = mk("TextLabel", { -- inferred equivalent call
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = zIndex,
			Font = Enum.Font.PermanentMarker,
			TextScaled = true,
			Text = text,
			TextColor3 = ink
		}, parent2)

		mk("UITextSizeConstraint", { MinTextSize = 6, MaxTextSize = 22 }, parent3) -- inferred equivalent call
		mk( -- inferred equivalent call
			"UIPadding",
			{
				PaddingTop = UDim.new(0.08, 0),
				PaddingBottom = UDim.new(0.04, 0),
				PaddingLeft = UDim.new(0.06, 0),
				PaddingRight = UDim.new(0.06, 0)
			},
			parent3
		)
	end

	return parent2
end

local function grime(parent, p, zIndex, p2, p3, p4, p5, p6)
	local random = Random.new(p)
	local v = p6 and 0.04 or 0

	for i = 1, p2 do
		local integer = random:NextInteger(40, 120)
		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 3 == 0 and p5.Rust or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.88 + random:NextNumber() * 0.06 + v,
			Position = UDim2.fromScale(random:NextNumber() * 0.85, random:NextNumber() * 0.8),
			Size = UDim2.fromOffset(integer, (math.floor(integer * (0.35 + random:NextNumber() * 0.4)))),
			ZIndex = zIndex
		}, parent)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	for i = 1, p3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = p5.Text,
			BackgroundTransparency = 0.9 + random:NextNumber() * 0.05,
			Position = UDim2.fromScale(random:NextNumber() * 0.9, random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(40, 140), 1),
			Rotation = random:NextInteger(-50, 50),
			ZIndex = zIndex
		}, parent)
	end

	for i = 1, (math.floor)(p3 / 2) do
		mk("Frame", { -- inferred equivalent call
			Name = "Scuff" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.84 + v,
			Position = UDim2.fromScale(random:NextNumber() * 0.9, random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(30, 90), 1),
			Rotation = random:NextInteger(-60, 60),
			ZIndex = zIndex
		}, parent)
	end

	for i = 1, p4 do
		local v2 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 3)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v2 and p5.Text or Color3.new(0, 0, 0),
			BackgroundTransparency = v2 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.fromOffset(integer, integer),
			ZIndex = zIndex
		}, parent)
	end
end

local function vignette(parent, name, position, size, rotation, p, zIndex)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		Position = position,
		Size = size,
		ZIndex = zIndex
	}, parent)
	mk("UIGradient", { -- inferred equivalent call
		Rotation = rotation,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
	}, parent2)
end

function TabsSkin.decorate(instance, p, p2)
	local newUIDecorFront = instance:FindFirstChild("NewUIDecorFront")

	if newUIDecorFront then
		newUIDecorFront:Destroy()
	end

	local v = TabsSkin.Palettes[p] or TabsSkin.Palettes.Dark
	local v2 = p == "Light"
	local parent = mk( -- inferred equivalent call
		"Frame",
		{
			Name = "NewUIDecorFront",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 50
		},
		instance
	)
	local v3 = v2 and 0.86 or 0.74
	vignette(parent, "NewUIDecorVigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 34), 90, v3, 50)
	vignette(parent, "NewUIDecorVigBottom", UDim2.new(0, 0, 1, -34), UDim2.new(1, 0, 0, 34), 270, v3, 50)
	vignette(parent, "NewUIDecorVigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 34, 1, 0), 0, v3 + 0.05, 50)
	vignette(parent, "NewUIDecorVigRight", UDim2.new(1, -34, 0, 0), UDim2.new(0, 34, 1, 0), 180, v3 + 0.05, 50)
	grime(parent, 11, 50, 5, 4, 18, v, v2)

	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorEdge",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -6, 1, -6),
		Position = UDim2.fromOffset(3, 3),
		ZIndex = 50
	}, parent)
	mk("UIStroke", { Color = v.Border, Thickness = 1, Transparency = 0.55 }, parent2) -- inferred equivalent call

	local v4 = p2 or { "TABS", "BLOXBAND" }

	tape(
		parent,
		"NewUIDecorTape1",
		UDim2.new(0, 14, 0, -15),
		UDim2.fromOffset(74, 20),
		-3,
		v.Tape,
		52,
		nil,
		v4[1],
		v.Ink
	)
	tape(
		parent,
		"NewUIDecorTape2",
		UDim2.new(1, -98, 0, -15),
		UDim2.fromOffset(84, 20),
		2,
		v.Tape,
		52,
		nil,
		v4[2],
		v.Ink
	)
	tape(parent, "NewUIDecorTape3", UDim2.new(0, 18, 1, -3), UDim2.fromOffset(50, 13), 2, v.Tape, 52, nil, nil, v.Ink)
	tape(parent, "NewUIDecorTape4", UDim2.new(1, -74, 1, -3), UDim2.fromOffset(56, 13), -3, v.Tape, 52, nil, nil, v.Ink)
	return parent
end

local function part(p, p2, p3, p4, p5, p6, options)
	local v = options or {}
	local parent = v.parent or p
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "IcPart",
		Position = UDim2.fromOffset(p3 * p2, p4 * p2),
		Size = UDim2.fromOffset(math.max(1, p5 * p2), (math.max(1, p6 * p2))),
		Rotation = v.rot or 0,
		ZIndex = 3
	}, parent)

	if v.hollow then
		parent2.BackgroundTransparency = 1
		mk("UIStroke", { -- inferred equivalent call
			Name = "IcStroke",
			Thickness = math.max(1, (v.t or 1.5) * p2)
		}, parent2)
	end

	if v.round then
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	return parent2
end

local function tri(parent, p, p2, p3, p4, p5)
	local v = p5 / 1.4142135623730951
	local v2, v3, v4

	if p2 == "right" then
		v2 = {
			p3,
			p4 - p5 / 2,
			p5 / 2,
			p5
		}
		v3 = -v / 2
		v4 = p5 / 2 - v / 2
	elseif p2 == "left" then
		v2 = {
			p3 - p5 / 2,
			p4 - p5 / 2,
			p5 / 2,
			p5
		}
		v3 = p5 / 2 - v / 2
		v4 = p5 / 2 - v / 2
	elseif p2 == "up" then
		v2 = {
			p3 - p5 / 2,
			p4 - p5 / 2,
			p5,
			p5 / 2
		}
		v3 = p5 / 2 - v / 2
		v4 = p5 / 2 - v / 2
	else
		v2 = {
			p3 - p5 / 2,
			p4,
			p5,
			p5 / 2
		}
		v3 = p5 / 2 - v / 2
		v4 = -v / 2
	end

	part(mk("Frame", { -- inferred equivalent call
		Name = "IcClip",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 3,
		Position = UDim2.fromOffset(v2[1] * p, v2[2] * p),
		Size = UDim2.fromOffset(v2[3] * p, v2[4] * p)
	}, parent), p, v3, v4, v, v, { rot = 45 })
end

local iconNames = {}

function iconNames.play(parent, p)
	tri(parent, p, "right", 4.5, 8, 11)
end
function iconNames.pause(p, p2)
	part(p, p2, 3.5, 3, 3, 10)
	part(p, p2, 9.5, 3, 3, 10)
end
function iconNames.stop(p, p2)
	part(p, p2, 3.5, 3.5, 9, 9)
end
function iconNames.minus(p, p2)
	part(p, p2, 3, 7, 10, 2)
end
function iconNames.plus(p, p2)
	part(p, p2, 3, 7, 10, 2)
	part(p, p2, 7, 3, 2, 10)
end
function iconNames.loop(parent, p)
	part(parent, p, 2.5, 2.5, 11, 11, { hollow = true, round = true, t = 1.8 })
	tri(parent, p, "right", 8.5, 2.5, 5)
end
function iconNames.metro(p, p2)
	part(p, p2, 4.5, 3, 7, 11, { hollow = true, t = 1.5 })
	part(p, p2, 7.6, 3.5, 1.2, 8, { rot = 22 })
	part(p, p2, 3, 13.5, 10, 1.6)
end
function iconNames.count(p, p2)
	part(p, p2, 7.2, 2.5, 2.2, 11)
	part(p, p2, 4.8, 4.2, 2.6, 2.2)
	part(p, p2, 5, 12.5, 6, 1.6)
end
function iconNames.edit(p, p2)
	part(p, p2, 2.5, 7.2, 11, 3, { rot = -45 })
	part(p, p2, 1.6, 12, 3.2, 1.6)
end
function iconNames.rec(p, p2)
	part(p, p2, 3, 3, 10, 10, { round = true })
end
function iconNames.save(p, p2)
	part(p, p2, 2.5, 2.5, 11, 11, { hollow = true, t = 1.5 })
	part(p, p2, 5, 2.5, 6, 4)
	part(p, p2, 5.5, 9, 5, 4.5)
end
function iconNames.folder(p, p2)
	part(p, p2, 1.5, 4.5, 13, 9)
	part(p, p2, 1.5, 2.5, 5.5, 3)
end
function iconNames.people(p, p2)
	part(p, p2, 2.5, 3, 4.5, 4.5, { round = true })
	part(p, p2, 9, 3, 4.5, 4.5, { round = true })
	part(p, p2, 1.5, 9, 6.5, 4.5)
	part(p, p2, 8, 9, 6.5, 4.5)
end
function iconNames.send(parent, p)
	part(parent, p, 2, 7, 8, 2)
	tri(parent, p, "right", 9, 8, 8)
end
function iconNames.publish(parent, p)
	part(parent, p, 7, 6, 2, 7.5)
	tri(parent, p, "up", 8, 5.5, 8)
	part(parent, p, 3, 13.5, 10, 1.6)
end
function iconNames.copy(p, p2)
	part(p, p2, 2, 2, 8, 8, { hollow = true, t = 1.4 })
	part(p, p2, 6, 6, 8, 8)
end
function iconNames.paste(p, p2)
	part(p, p2, 3, 3, 10, 11, { hollow = true, t = 1.5 })
	part(p, p2, 5.5, 1.5, 5, 3.2)
end
function iconNames.clear(p, p2)
	part(p, p2, 1.5, 7, 13, 2, { rot = 45 })
	part(p, p2, 1.5, 7, 13, 2, { rot = -45 })
end
iconNames.close = iconNames.clear
function iconNames.undo(parent, p)
	part(parent, p, 5, 7, 8, 2)
	tri(parent, p, "left", 8, 8, 8)
end
function iconNames.note(p, p2)
	part(p, p2, 2.5, 9.5, 5.5, 4, { round = true })
	part(p, p2, 7, 2.5, 1.6, 9.5)
	part(p, p2, 7, 2.5, 6, 2.2)
end
function iconNames.keys(p, p2)
	part(p, p2, 1, 4, 14, 9, { hollow = true, t = 1.4 })
	part(p, p2, 3.5, 6.3, 2, 2)
	part(p, p2, 7, 6.3, 2, 2)
	part(p, p2, 10.5, 6.3, 2, 2)
	part(p, p2, 4.5, 9.8, 7, 1.8)
end
function iconNames.zoom(p, p2)
	part(p, p2, 2, 2, 9, 9, { hollow = true, round = true, t = 1.8 })
	part(p, p2, 9.2, 12, 6, 2, { rot = 45 })
end
function iconNames.theme(parent, p)
	part(parent, p, 3, 3, 10, 10, { hollow = true, round = true, t = 1.6 })
	part(mk("Frame", { -- inferred equivalent call
		Name = "IcClip",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 3,
		Position = UDim2.fromOffset(3 * p, 3 * p),
		Size = UDim2.fromOffset(5 * p, 10 * p)
	}, parent), p, 0, 0, 10, 10, { round = true })
end
function iconNames.minimize(p, p2)
	part(p, p2, 3, 11, 10, 2)
end
function iconNames.grid(p, p2)
	part(p, p2, 2, 2, 12, 12, { hollow = true, t = 1.3 })
	part(p, p2, 5.7, 2, 1, 12)
	part(p, p2, 9.3, 2, 1, 12)
	part(p, p2, 2, 5.7, 12, 1)
	part(p, p2, 2, 9.3, 12, 1)
end
function iconNames.len(p, p2)
	part(p, p2, 1.5, 6, 13, 4, { hollow = true, t = 1.3 })
	part(p, p2, 4.5, 6, 1, 2.5)
	part(p, p2, 8, 6, 1, 2.5)
	part(p, p2, 11.5, 6, 1, 2.5)
end
function iconNames.lines(p, p2)
	part(p, p2, 2, 3, 12, 2)
	part(p, p2, 2, 7, 12, 2)
	part(p, p2, 2, 11, 12, 2)
end
function iconNames.target(p, p2)
	part(p, p2, 2.5, 2.5, 11, 11, { hollow = true, round = true, t = 1.5 })
	part(p, p2, 6, 6, 4, 4, { round = true })
end
function iconNames.select(parent, p)
	part(parent, p, 2, 2, 11, 11, { hollow = true, t = 1.3 })
	tri(parent, p, "right", 8, 9, 6)
end
function iconNames.flag(p, p2)
	part(p, p2, 3, 2, 1.8, 12)
	part(p, p2, 4.5, 2.5, 8, 5.5)
end
function iconNames.trash(p, p2)
	part(p, p2, 4, 5.5, 8, 8.5)
	part(p, p2, 2.5, 3, 11, 1.8)
	part(p, p2, 6, 1.5, 4, 1.8)
end
function iconNames.up(parent, p)
	tri(parent, p, "up", 8, 8, 10)
end
function iconNames.down(parent, p)
	tri(parent, p, "down", 8, 8, 10)
end
function iconNames.left(parent, p)
	tri(parent, p, "left", 9, 8, 10)
end
function iconNames.right(parent, p)
	tri(parent, p, "right", 7, 8, 10)
end
function iconNames.tech(p, p2)
	part(p, p2, 1.5, 9, 4, 2, { rot = -35 })
	part(p, p2, 5, 7.5, 4, 2, { rot = 35 })
	part(p, p2, 8.5, 9, 4, 2, { rot = -35 })
	part(p, p2, 11, 7.5, 3.5, 2, { rot = 35 })
end
function iconNames.print(p, p2)
	part(p, p2, 2, 2, 12, 12, { hollow = true, t = 1.3 })
	part(p, p2, 4, 5, 8, 1.2)
	part(p, p2, 4, 8, 8, 1.2)
	part(p, p2, 4, 11, 5, 1.2)
end

TabsSkin.IconNames = iconNames

function TabsSkin.icon(parent, value, p, p2)
	local v

	if type(value) == "string" then
		v = string.match(value, "^img:(.+)$")
	else
		v = false
	end

	if v then
		local image = TabsIcons.image(v)

		if not image then
			return nil
		end

		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = "Icon_" .. value,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(p, p),
			ZIndex = 3
		}, parent)

		mk("ImageLabel", { -- inferred equivalent call
			Name = "IcImage",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = image,
			ImageColor3 = p2 or Color3.new(1, 1, 1),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 3
		}, parent2)

		return parent2
	else
		local v2 = iconNames[value]

		if not v2 then
			return nil
		end

		local frame = mk("Frame", { -- inferred equivalent call
			Name = "Icon_" .. value,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(p, p),
			ZIndex = 3
		}, parent)

		v2(frame, p / 16)
		TabsSkin.tint(frame, p2)
		return frame
	end
end

function TabsSkin.tint(folder, p)
	if not (folder and p) then
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name == "IcPart" and descendant:IsA("Frame") then
			if descendant.BackgroundTransparency < 1 then
				descendant.BackgroundColor3 = p
			end
		elseif descendant.Name == "IcStroke" and descendant:IsA("UIStroke") then
			descendant.Color = p
		elseif descendant.Name == "IcImage" and descendant:IsA("ImageLabel") then
			descendant.ImageColor3 = p
		end
	end
end

TabsSkin.tape = tape

return TabsSkin