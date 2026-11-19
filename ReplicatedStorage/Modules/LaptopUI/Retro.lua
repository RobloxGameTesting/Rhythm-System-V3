local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local TextService = game:GetService("TextService")
local Theme = require(script.Parent.Theme)

local Retro = {}

function Retro.HashString(value)
	local v = 5381

	for i = 1, #value do
		v = (v * 33 + value:byte(i)) % 2147483647
	end

	return v
end

local function newFrame(parent, items) -- 26 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Active = false

	for k, item in pairs(items) do
		frame[k] = item
	end

	frame.Parent = parent
	return frame
end

function Retro.AddScanlines(parent, options)
	local v = options or {}
	local lines = v.lines or 44
	local transparency = v.transparency or 0.92
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "Scanlines",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.ZIndex.Overlay
	})

	for i = 0, lines - 1 do
		newFrame(parent2, { -- inferred equivalent call
			Name = "Line",
			BackgroundColor3 = Theme.Colors.Scanline,
			BackgroundTransparency = transparency,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, i / lines, 0),
			ZIndex = Theme.ZIndex.Overlay
		})
	end

	return parent2
end

function Retro.AddCornerBrackets(parent, options)
	local v = options or {}
	local length = v.length or 8
	local inset = v.inset or 3
	local color = v.color or Theme.Colors.Accent
	local transparency = v.transparency or 0.35
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "CornerBrackets",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.ZIndex.Raised
	})

	local function piece(p, p2, p3, p4)
		newFrame(parent2, { -- inferred equivalent call
			BackgroundColor3 = color,
			BackgroundTransparency = transparency,
			AnchorPoint = Vector2.new(p, p2),
			Position = UDim2.new(p, p == 0 and inset or -inset, p2, p2 == 0 and inset or -inset),
			Size = UDim2.fromOffset(p3, p4),
			ZIndex = Theme.ZIndex.Raised
		})
	end

	for _, v2 in ipairs({ 0, 1 }) do
		for _, v3 in ipairs({ 0, 1 }) do
			piece(v2, v3, length, 1)
			piece(v2, v3, 1, length)
		end
	end

	return parent2
end

function Retro.AddTape(parent, options)
	local v = options or {}
	local size = v.size or UDim2.fromOffset(34, 10)
	local notchColor = v.notchColor or Theme.Colors.Surface
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "Tape",
		BackgroundColor3 = Theme.Colors.Tape,
		BackgroundTransparency = 0.12,
		Size = size,
		Position = v.position or UDim2.new(1, -20, 0, -6),
		AnchorPoint = v.anchor or Vector2.new(0, 0),
		ZIndex = Theme.ZIndex.Overlay + 1
	})

	newFrame(parent2, { -- inferred equivalent call
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.7,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = Theme.ZIndex.Overlay + 1
	})

	local offset = size.Y.Offset

	for _, v2 in ipairs({ 0, 1 }) do
		for i = 0, 2 do
			newFrame(parent2, { -- inferred equivalent call
				BackgroundColor3 = notchColor,
				AnchorPoint = Vector2.new(v2, 0),
				Position = UDim2.new(v2, 0, 0, math.floor(i * offset / 3) + i % 2),
				Size = UDim2.fromOffset(2, (math.max(2, (math.floor(offset / 4))))),
				ZIndex = Theme.ZIndex.Overlay + 2
			})
		end
	end

	return parent2
end

function Retro.AddSticker(parent, text, options)
	local v = options or {}
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "Sticker",
		BackgroundTransparency = 1,
		AnchorPoint = v.anchor or Vector2.new(1, 1),
		Position = v.position or UDim2.new(1, -2, 1, -2),
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		ZIndex = Theme.ZIndex.Raised
	})

	local frame = newFrame(parent2, { -- inferred equivalent call
		Name = "Shadow",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.ZIndex.Raised
	})

	local parent3 = newFrame(parent2, { -- inferred equivalent call
		Name = "Body",
		BackgroundColor3 = v.color or Theme.Colors.Sticker,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		ZIndex = Theme.ZIndex.Raised + 1
	})

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Theme.Colors.StickerText
	uiStroke.Transparency = 0.45
	uiStroke.Parent = parent3
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 5)
	uiPadding.PaddingRight = UDim.new(0, 5)
	uiPadding.PaddingTop = UDim.new(0, 2)
	uiPadding.PaddingBottom = UDim.new(0, 2)
	uiPadding.Parent = parent3
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.Size = UDim2.fromOffset(0, 0)
	textLabel.Font = Theme.Fonts.Display
	textLabel.TextSize = v.textSize or 10
	textLabel.TextColor3 = Theme.Colors.StickerText
	textLabel.Text = text
	textLabel.ZIndex = Theme.ZIndex.Raised + 2
	textLabel.Parent = parent3

	parent3:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		frame.Size = UDim2.fromOffset(parent3.AbsoluteSize.X, parent3.AbsoluteSize.Y)
	end)
	task.defer(function()
		if parent3.Parent then
			frame.Size = UDim2.fromOffset(parent3.AbsoluteSize.X, parent3.AbsoluteSize.Y)
		end
	end)
	return parent2
end

function Retro.AddScratches(parent, p, value)
	local random = Random.new(Retro.HashString((tostring(p))))

	local v = {
		Name = "Scratches",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.ZIndex.Overlay - 1
	}
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Active = false
	local v2 = value or 8

	for k, v3 in pairs(v) do
		frame[k] = v3
	end

	frame.Parent = parent

	for _ = 1, v2 do
		local v3 = random:NextNumber() < 0.7
		local integer = random:NextInteger(8, 34)
		newFrame(frame, { -- inferred equivalent call
			BackgroundColor3 = Theme.Colors.TextPrimary,
			BackgroundTransparency = random:NextNumber(0.84, 0.94),
			Position = UDim2.new(random:NextNumber(0, 0.9), 0, random:NextNumber(0, 0.96), 0),
			Size = v3 and UDim2.fromOffset(integer, 1) or UDim2.fromOffset(1, integer),
			ZIndex = Theme.ZIndex.Overlay - 1
		})
	end

	for _ = 1, math.floor(v2 * 0.8) do
		newFrame(frame, { -- inferred equivalent call
			BackgroundColor3 = Theme.Colors.TextPrimary,
			BackgroundTransparency = random:NextNumber(0.8, 0.92),
			Position = UDim2.new(random:NextNumber(), 0, random:NextNumber(), 0),
			Size = UDim2.fromOffset(1, 1),
			ZIndex = Theme.ZIndex.Overlay - 1
		})
	end

	return frame
end

function Retro.GlitchPulse(parent, options)
	local v = options or {}

	if not (parent and parent.Parent) then
		return
	end

	local z = v.z or 50
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "GlitchPulse",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = z
	})

	local random = Random.new()
	local v2 = { Theme.Colors.GhostCyan, Theme.Colors.GhostRed, Theme.Colors.Glow }

	for i = 1, v.bars or 6 do
		local number = random:NextNumber(0.03, 0.97)
		local number2 = random:NextNumber(0, 0.45)
		local number3 = random:NextNumber(0.2, 0.65)
		TweenService:Create(newFrame(parent2, { -- inferred equivalent call
			BackgroundColor3 = v2[(i - 1) % #v2 + 1],
			BackgroundTransparency = random:NextNumber(0.35, 0.6),
			Position = UDim2.new(number2, 0, number, 0),
			Size = UDim2.new(number3, 0, 0, random:NextInteger(1, 3)),
			ZIndex = z
		}), TweenInfo.new(0.16 + random:NextNumber(0, 0.1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
			Position = UDim2.new(number2 + random:NextNumber(-0.1, 0.1), 0, number, 0)
		}):Play()
	end

	Debris:AddItem(parent2, 0.45)
end

function Retro.AddGloss(_): nil
	return nil
end

function Retro.AddCaptionBar(parent, text, options)
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "CaptionBar",
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 0, (options or {}).height or 17),
		ZIndex = Theme.ZIndex.Raised
	})

	parent2.BackgroundColor3 = Theme.Colors.TitleBottom
	newFrame(parent2, { -- inferred equivalent call
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.78,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = Theme.ZIndex.Raised + 1
	})

	newFrame(parent2, { -- inferred equivalent call
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = Theme.ZIndex.Raised + 1
	})

	local parent3 = newFrame(parent2, { -- inferred equivalent call
		BackgroundColor3 = Theme.Colors.Accent,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.fromOffset(7, 7),
		ZIndex = Theme.ZIndex.Raised + 1
	})

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 2)
	uiCorner.Parent = parent3

	local caption = Instance.new("TextLabel")
	caption.Name = "Caption"
	caption.BackgroundTransparency = 1
	caption.Position = UDim2.new(0, 18, 0, 0)
	caption.Size = UDim2.new(1, -24, 1, 0)
	caption.Font = Theme.Fonts.Bold
	caption.TextSize = Theme.TextSize.S
	caption.TextColor3 = Theme.Colors.TextPrimary
	caption.TextXAlignment = Enum.TextXAlignment.Left
	caption.Text = text
	caption.ZIndex = Theme.ZIndex.Raised + 2
	caption.Parent = parent2
	return parent2, caption
end

function Retro:Typewrite(text)
	self.Text = text
	local v = (self:GetAttribute("TypeToken") or 0) + 1
	self:SetAttribute("TypeToken", v)
	local v2 = utf8.len(text) or #text

	if v2 <= 1 then
		self.MaxVisibleGraphemes = -1
		return
	end

	self.MaxVisibleGraphemes = 0
	local v3 = math.min(0.03, 0.5 / v2)
	task.spawn(function()
		for i = 1, v2 do
			if self:GetAttribute("TypeToken") ~= v or not self.Parent then
				return
			end

			self.MaxVisibleGraphemes = i
			task.wait(v3)
		end

		if self:GetAttribute("TypeToken") == v then
			self.MaxVisibleGraphemes = -1
		end
	end)
end

function Retro.AttachScreenFrame(instance, options)
	local v = options or {}
	local parent = instance.Parent

	if not parent then
		return nil
	end

	local frame = Instance.new("Frame")
	frame.Name = (instance.Name or "Panel") .. "_RetroFrame"
	frame.BackgroundTransparency = 1
	frame.Active = false
	frame.BorderSizePixel = 0
	frame.Size = instance.Size
	frame.Position = instance.Position
	frame.ZIndex = (instance.ZIndex or 1) + 1
	frame.Visible = instance.Visible
	frame.ClipsDescendants = true
	frame.Parent = parent

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, v.inset or 10)
	uiPadding.PaddingRight = UDim.new(0, v.inset or 10)
	uiPadding.PaddingTop = UDim.new(0, v.inset or 10)
	uiPadding.PaddingBottom = UDim.new(0, v.inset or 10)
	uiPadding.Parent = frame

	instance:GetPropertyChangedSignal("Visible"):Connect(function()
		frame.Visible = instance.Visible

		if instance.Visible and not v.noGlitch then
			Retro.GlitchPulse(frame)
		end
	end)
	instance:GetPropertyChangedSignal("Size"):Connect(function()
		frame.Size = instance.Size
	end)
	instance:GetPropertyChangedSignal("Position"):Connect(function()
		frame.Position = instance.Position
	end)
	instance.Destroying:Connect(function()
		frame:Destroy()
	end)
	return frame
end

function Retro.AddTitle(parent, text, options)
	local v = options or {}
	local z = v.z or 2
	local size = v.size or 18
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "RetroTitle",
		BackgroundTransparency = 1,
		Position = v.position or UDim2.new(0, 0, 0, 0),
		Size = v.sizeUDim or UDim2.new(1, 0, 0, size + 10),
		ZIndex = z
	})

	local function makeLabel(name, textColor, textTransparency, p, p2, zIndex)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = name
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.new(0, p, 0, p2)
		textLabel.Size = UDim2.new(1, 0, 0, size + 4)
		textLabel.Font = Theme.Fonts.Title
		textLabel.TextSize = size
		textLabel.TextColor3 = textColor
		textLabel.TextTransparency = textTransparency
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.Text = text
		textLabel.ZIndex = zIndex
		textLabel.Parent = parent2
		return textLabel
	end

	makeLabel("GhostCyan", Theme.Colors.GhostCyan, 0.5, -1.5, 0, z)
	makeLabel("GhostRed", Theme.Colors.GhostRed, 0.6, 1.5, 0.5, z)
	local label = makeLabel("Main", Color3.fromRGB(255, 252, 240), 0, 0, 0, z + 1)
	local glow = Instance.new("UIStroke")
	glow.Name = "Glow"
	glow.Thickness = 2.5
	glow.Color = Theme.Colors.Glow
	glow.Transparency = 0.8
	glow.Parent = label

	local v2 = size + 5
	newFrame(parent2, { -- inferred equivalent call
		Name = "BarHalo",
		BackgroundColor3 = Theme.Colors.Glow,
		BackgroundTransparency = 0.84,
		Position = UDim2.new(0.15, 0, 0, v2 - 1),
		Size = UDim2.new(0.85, 0, 0, 4),
		ZIndex = z
	})

	newFrame(parent2, { -- inferred equivalent call
		Name = "Bar",
		BackgroundColor3 = Color3.fromRGB(255, 252, 240),
		Position = UDim2.new(0.15, 0, 0, v2),
		Size = UDim2.new(0.85, 0, 0, 2),
		ZIndex = z + 1
	})

	newFrame(parent2, { -- inferred equivalent call
		Name = "BarCut",
		BackgroundColor3 = Color3.fromRGB(255, 252, 240),
		BackgroundTransparency = 0.15,
		Position = UDim2.new(0, 0, 0, v2 + 2),
		Size = UDim2.new(0.14, 0, 0, 2),
		ZIndex = z + 1
	})

	return parent2
end

function Retro.AddHeaderStrip(parent, p, options)
	local v = options or {}
	local z = v.z or 2
	local parent2 = newFrame(parent, { -- inferred equivalent call
		Name = "HeaderStrip",
		BackgroundColor3 = Theme.Colors.TitleBottom,
		Position = v.position or UDim2.new(0, 0, 0, 0),
		Size = v.sizeUDim or UDim2.new(1, 0, 0, 14),
		ZIndex = z
	})

	newFrame(parent2, { -- inferred equivalent call
		BackgroundColor3 = Theme.Colors.Glow,
		BackgroundTransparency = 0.82,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = z + 1
	})

	local function makeLabel(textXAlignment, value, textColor)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, -12, 1, 0)
		textLabel.Position = UDim2.new(0, 6, 0, 0)
		textLabel.Font = Theme.Fonts.Label
		textLabel.TextSize = 9
		textLabel.TextColor3 = textColor
		textLabel.TextXAlignment = textXAlignment
		textLabel.Text = string.upper(value or "")
		textLabel.ZIndex = z + 1
		textLabel.Parent = parent2
		return textLabel
	end

	return
		parent2,
		makeLabel(Enum.TextXAlignment.Left, p, Theme.Colors.TextPrimary),
		makeLabel(Enum.TextXAlignment.Right, v.rightText, Theme.Colors.TextSecondary)
end

function Retro.AddHintBar(parent, list, options)
	local v = options or {}
	local z = v.z or 2

	local parent3 = newFrame(parent, { -- inferred equivalent call
		Name = "HintBar",
		BackgroundColor3 = Color3.fromRGB(6, 6, 6),
		BackgroundTransparency = 0.05,
		Position = v.position or UDim2.new(0, 0, 1, -22),
		Size = v.sizeUDim or UDim2.new(1, 0, 0, 22),
		ZIndex = z
	})

	newFrame(parent3, { -- inferred equivalent call
		BackgroundColor3 = Theme.Colors.Glow,
		BackgroundTransparency = 0.88,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = z + 1
	})

	local function measure(value) -- 3 equivalent calls inferred from this helper
		return TextService:GetTextSize(string.upper(value), 10, Theme.Fonts.Label, Vector2.new(400, 20)).X
	end

	local function variantColors(p) -- 2 equivalent calls inferred from this helper
		if p == "primary" then
			return Theme.Colors.Accent, Theme.Colors.AccentText, Theme.Colors.Glow
		elseif p == "danger" then
			return Theme.Colors.Danger, Theme.Colors.TextPrimary, Theme.Colors.TextPrimary
		end

		return Theme.Colors.SurfaceHover, Theme.Colors.TextPrimary, Theme.Colors.BorderHover
	end

	local function addCorner(parent2) -- 2 equivalent calls inferred from this helper
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = Theme.Radius.Small
		uiCorner.Parent = parent2
	end
	local function addStroke(parent2, color) -- 2 equivalent calls inferred from this helper
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1
		uiStroke.Color = color
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = parent2
		return uiStroke
	end

	local result = {}
	local total = 6
	local total2 = 6

	for _, item in ipairs(list) do
		local v2, v3

		if item.keycap then
			local v4 = measure(item.keycap) + 12 -- inferred equivalent call
			local v5 = measure(item.text) + 4 -- inferred equivalent call
			v2 = v4 + 6 + v5
			v3 = Instance.new("Frame")
			v3.BackgroundTransparency = 1
			v3.BorderSizePixel = 0
			v3.Size = UDim2.new(0, v2, 0, 18)
			local keycap = Instance.new("TextLabel")
			keycap.Name = "Keycap"
			keycap.BackgroundColor3 = Theme.Colors.SurfaceHover
			keycap.BorderSizePixel = 0
			keycap.Size = UDim2.new(0, v4, 1, 0)
			keycap.Font = Theme.Fonts.Label
			keycap.TextSize = 10
			keycap.TextColor3 = Theme.Colors.TextPrimary
			keycap.Text = string.upper(item.keycap)
			keycap.ZIndex = z + 2
			keycap.Parent = v3
			addCorner(keycap) -- inferred equivalent call
			addStroke(keycap, Theme.Colors.BorderHover) -- inferred equivalent call
			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.BackgroundTransparency = 1
			label.Position = UDim2.new(0, v4 + 6, 0, 0)
			label.Size = UDim2.new(0, v5, 1, 0)
			label.Font = Theme.Fonts.Label
			label.TextSize = 10
			label.TextColor3 = Theme.Colors.TextSecondary
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Text = string.upper(item.text)
			label.ZIndex = z + 2
			label.Parent = v3
			result[item.name] = {
				button = v3,
				label = label,
				setText = function(value)
					label.Text = string.upper(value)
				end,
				setVariant = function() end
			}
		else
			local v4 = string.upper(item.text)

			if item.alt and #item.alt > #item.text then
				v4 = string.upper(item.alt)
			end

			v2 = measure(v4) + 22 -- inferred equivalent call

			local backgroundColor, textColor, color = variantColors(item.variant or "ghost") -- inferred equivalent call
			local v5

			if item.onClick then
				v5 = Instance.new("TextButton")
				v5.AutoButtonColor = false
			else
				v5 = Instance.new("TextLabel")
			end

			v5.BackgroundColor3 = backgroundColor
			v5.BorderSizePixel = 0
			v5.Size = UDim2.new(0, v2, 0, 18)
			v5.Font = Theme.Fonts.Label
			v5.TextSize = 10
			v5.TextColor3 = textColor
			v5.Text = string.upper(item.text)
			v5.ZIndex = z + 2
			v3 = v5
			addCorner(v5) -- inferred equivalent call
			local uiStroke = addStroke(v5, color) -- inferred equivalent call
			local backgroundColor2 = backgroundColor
			local function setVariant(p)
				local backgroundColor3, textColor2, color2 = variantColors(p) -- inferred equivalent call
				backgroundColor2 = backgroundColor3
				v5.BackgroundColor3 = backgroundColor3
				v5.TextColor3 = textColor2
				uiStroke.Color = color2
			end

			if item.onClick then
				v5.Activated:Connect(item.onClick)
				v5.MouseEnter:Connect(function()
					v5.BackgroundColor3 = backgroundColor2:Lerp(Color3.new(1, 1, 1), 0.2)
				end)
				v5.MouseLeave:Connect(function()
					v5.BackgroundColor3 = backgroundColor2
				end)
			end

			result[item.name] = {
				button = v5,
				label = v5,
				setText = function(value)
					v5.Text = string.upper(value)
				end,
				setVariant = setVariant
			}
		end

		v3.Name = "Hint_" .. item.name
		v3.ZIndex = z + 1

		if item.side == "right" then
			v3.AnchorPoint = Vector2.new(1, 0.5)
			v3.Position = UDim2.new(1, -total2, 0.5, 0)
			total2 += v2 + 6
		else
			v3.AnchorPoint = Vector2.new(0, 0.5)
			v3.Position = UDim2.new(0, total, 0.5, 0)
			total += v2 + 6
		end

		v3.Parent = parent3
	end

	return parent3, result
end

return Retro