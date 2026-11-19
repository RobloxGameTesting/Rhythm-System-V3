local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local StyledTheme = require(script.Parent.StyledTheme)

local UISkin = {}

local instances = {}
local v = "Default"
local function v2(): boolean
	return false
end
local flag = false

local Font = Enum.Font
local v3 = {
	[Font.Gotham] = Font.SpecialElite,
	[Font.GothamMedium] = Font.SpecialElite,
	[Font.GothamBold] = Font.Oswald
}
local v4 = { [Font.SpecialElite] = Font.Gotham, [Font.Oswald] = Font.GothamBold }
local v5 = { [Font.SpecialElite] = 1.08, [Font.Oswald] = 1.12 }
local v6 = { [Font.SpecialElite] = 12, [Font.Oswald] = 14 }
local v7 = { [17] = 16 }
local v8 = {
	[4] = 2,
	[5] = 2,
	[6] = 3,
	[7] = 3,
	[8] = 3,
	[10] = 3,
	[12] = 3
}
local v9 = { [2] = 4, [3] = 6 }

local Grunge = StyledTheme.Grunge
local Colors = StyledTheme.Styles.NewUI.Colors

local v10 = {}
local function mapFor(p, p2)
	while p do
		local v11 = v10[p]

		if v11 then
			return v11[p2]
		end

		p = p.Parent
	end

	return StyledTheme.Maps[p2]
end

local function makeCombined(p)
	local combined = {}

	for _, v11 in ipairs({ "NewUI", "Default" }) do
		combined[v11] = setmetatable({}, {
			__index = function(_, p2)
				return p[v11][p2] or StyledTheme.Maps[v11][p2]
			end
		})
	end

	return combined
end

local function isTextClass(instance) -- 6 equivalent calls inferred from this helper
	return instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")
end

local function remapProp(instance, p, p2) -- 2 equivalent calls inferred from this helper
	local v11 = p2[StyledTheme.ColorKey(instance[p])]

	if v11 then
		instance[p] = v11
	end
end

local function remapColors(instance, p)
	if instance:IsA("GuiObject") then
		remapProp(instance, "BackgroundColor3", p) -- inferred equivalent call
		remapProp(instance, "BorderColor3", p) -- inferred equivalent call
		local textColor = isTextClass(instance) and p[StyledTheme.ColorKey(instance.TextColor3)] -- inferred equivalent call

		if textColor then
			instance.TextColor3 = textColor
		end

		local placeholderColor = instance:IsA("TextBox") and p[StyledTheme.ColorKey(instance.PlaceholderColor3)]

		if placeholderColor then
			instance.PlaceholderColor3 = placeholderColor
		end

		local scrollBarImageColor = instance:IsA("ScrollingFrame")
			and p[StyledTheme.ColorKey(instance.ScrollBarImageColor3)]

		if scrollBarImageColor then
			instance.ScrollBarImageColor3 = scrollBarImageColor
		end
	else
		local color = instance:IsA("UIStroke") and p[StyledTheme.ColorKey(instance.Color)]

		if color then
			instance.Color = color
		end
	end
end

local function isInDecor(instance): boolean
	while instance do
		if instance.Name:sub(1, 10) == "NewUIDecor" then
			return true
		end

		if instance:GetAttribute("NoNewUISkin") then
			return true
		end

		instance = instance.Parent
	end

	return false
end

local function isWindow(frame)
	if
		(frame.Name == "ListPanel" or frame.Name == "CardPanel")
		and frame:IsA("Frame")
		and frame.Parent ~= nil
		and frame.Parent.Name == "Root"
	then
		return true
	end

	if
		frame.Name == "DropdownPanel"
		and frame:IsA("Frame")
		and frame.Parent ~= nil
		and frame.Parent.Name == "FavoriteGenresDropdownGui"
	then
		return true
	end

	if
		frame:IsA("Frame")
		and (frame.Name == "Panel" or frame.Name == "VocalistInfoBox")
		and frame.Parent ~= nil
		and frame.Parent:IsA("ScreenGui")
		and frame.Parent.Name == "MicSettingsUI"
	then
		return true
	end

	if
		frame:IsA("Frame")
		and frame.Name == "Panel"
		and frame.Parent ~= nil
		and frame.Parent.Name == "Overlay"
		and frame.Parent.Parent ~= nil
		and frame.Parent.Parent.Name == "ServerBrowserUI"
	then
		return true
	end

	local v11

	if frame.Name == "Window" or frame.Name == "NewbieModePanel" then
		v11 = frame:IsA("Frame")

		if v11 then
			if frame.Parent == nil then
				return false
			end

			return (frame.Parent:IsA("ScreenGui"))
		end
	else
		return false
	end

	return v11
end

local function mk(className, items, parent) -- 111 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function buildDecor(instance, p, value)
	local v11 = value or 1
	local uiPadding

	if not p then
		uiPadding = instance:FindFirstChildOfClass("UIPadding") or nil
	end

	local offset = uiPadding and uiPadding.PaddingLeft.Offset or 0
	local offset2 = uiPadding and uiPadding.PaddingTop.Offset or 0
	local offset3 = uiPadding and uiPadding.PaddingRight.Offset or 0
	local offset4 = uiPadding and uiPadding.PaddingBottom.Offset or 0

	local function layer(name, zIndex)
		if p then
			return mk("Frame", { -- inferred equivalent call
				Name = name,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Active = false,
				ZIndex = p.z,
				AnchorPoint = instance.AnchorPoint,
				Position = instance.Position,
				Size = instance.Size
			}, p.parent)
		end

		return mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = false,
			ZIndex = zIndex,
			Position = UDim2.new(0, -offset, 0, -offset2),
			Size = UDim2.new(1, offset + offset3, 1, offset2 + offset4)
		}, instance)
	end

	local folder = layer("NewUIDecorFront", 50)

	local content = instance.AutomaticSize ~= Enum.AutomaticSize.None and instance:FindFirstChild("Content")

	if content then
		local function sync() -- 1 equivalent call inferred from this helper
			folder.Size = UDim2.new(1, offset + offset3, 0, content.AbsoluteSize.Y + offset2 + offset4)
		end

		sync() -- inferred equivalent call
		local absoluteSizeChangedConnection = content:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
		folder.Destroying:Connect(function()
			absoluteSizeChangedConnection:Disconnect()
		end)
	end

	local random = Random.new(11)

	local function vignette(name, position, size, rotation, p2)
		local parent = mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size
		}, folder)
		mk("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p2), NumberSequenceKeypoint.new(1, 1) })
		}, parent)
	end
	vignette("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 46), 90, 0.5)
	vignette("VigBottom", UDim2.new(0, 0, 1, -46), UDim2.new(1, 0, 0, 46), 270, 0.5)
	vignette("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 46, 1, 0), 0, 0.55)
	vignette("VigRight", UDim2.new(1, -46, 0, 0), UDim2.new(0, 46, 1, 0), 180, 0.55)

	for i = 1, (math.floor)(10 * v11) do
		local integer = random:NextInteger(50, 140)
		local parent = mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 3 == 0 and Grunge.Rust or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.93 + random:NextNumber() * 0.04,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.8),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
		}, folder)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
	end

	for i = 1, (math.floor)(7 * v11) do
		local integer = random:NextInteger(50, 150)
		local parent = mk("Frame", { -- inferred equivalent call
			Name = "Grime" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.93 + random:NextNumber() * 0.04,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * 0.6)))
		}, folder)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
	end

	local x

	if instance.Name == "DropdownPanel" then
		x = instance.AbsoluteSize.X > 0 and instance.AbsoluteSize.X or instance.Size.X.Offset or nil
	end

	for i, v12 in ipairs({
		{ 0.1, 0.22, 150, 24 },
		{ 0.62, 0.4, 110, -31 },
		{ 0.3, 0.66, 190, 12 },
		{ 0.78, 0.8, 90, -20 },
		{ 0.05, 0.9, 130, 35 },
		{ 0.48, 0.12, 120, -14 },
		{ 0.88, 0.3, 80, 52 },
		{ 0.2, 0.5, 100, -40 },
		{ 0.7, 0.62, 160, 8 }
	}) do
		local v13 = v12[3]

		if x then
			v13 = math.max(20, (math.min(v13, (math.floor(x * (1 - v12[1]) * 0.8)))))
		end

		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = Colors.TextPrimary,
			BackgroundTransparency = 0.95,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(v12[1], v12[2]),
			Size = UDim2.new(0, v13, 0, 1),
			Rotation = v12[4]
		}, folder)
	end

	for i = 1, (math.floor)(4 * v11) do
		local v12 = random:NextInteger(40, 110)

		if x then
			v12 = math.floor(v12 * 0.4)
		end

		mk("Frame", { -- inferred equivalent call
			Name = "Scuff" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * (x and 0.7 or 1), random:NextNumber()),
			Size = UDim2.new(0, v12, 0, 1),
			Rotation = random:NextInteger(-60, 60)
		}, folder)
	end

	for i = 1, (math.floor)(55 * v11) do
		local v12 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 3)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v12 and Colors.TextPrimary or Color3.new(0, 0, 0),
			BackgroundTransparency = v12 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, integer)
		}, folder)
	end

	local parent = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6)
	}, folder)
	mk("UIStroke", { Color = Grunge.EdgeWear, Thickness = 1.5, Transparency = 0.55 }, parent) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent) -- inferred equivalent call

	local function tape(name, position, size, rotation, backgroundColor, backgroundTransparency) -- 3 equivalent calls inferred from this helper
		mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size,
			Rotation = rotation
		}, folder)
	end
	tape("TapeLeft", UDim2.new(0, -18, 0, 4), UDim2.new(0, 60, 0, 14), -40, Grunge.Tape, 0.12) -- inferred equivalent call
	local tapeLeft = instance.Name == "DropdownPanel" and folder:FindFirstChild("TapeLeft")

	if tapeLeft then
		tapeLeft.Position = UDim2.new(1, -34, 0, 0)
		tapeLeft.Rotation = 40
	end

	tape("TapeBottomRight", UDim2.new(1, -34, 1, -16), UDim2.new(0, 48, 0, 12), -40, Grunge.Tape, 0.18) -- inferred equivalent call
	tape("TapeBottomLeft", UDim2.new(0, -14, 1, -18), UDim2.new(0, 40, 0, 11), 36, Grunge.TapeDark, 0.15) -- inferred equivalent call

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = guiObject.Name:sub(1, 4) == "Tape" and 52 or 50
		end
	end
end

local function decorateWindow(instance, p, p2)
	if instance:GetAttribute("ui0_Win") then
		return
	end

	instance:SetAttribute("ui0_Win", true)
	instance:SetAttribute("ui0_BgT", instance.BackgroundTransparency)
	instance.BackgroundTransparency = p and 0.08 or 0.04

	if not p then
		instance:SetAttribute("ui0_Clip", instance.ClipsDescendants)
		instance.ClipsDescendants = false
	end

	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		instance:SetAttribute("ui0_StT", uiStroke.Thickness)
		instance:SetAttribute("ui0_StC", uiStroke.Color)
		uiStroke.Thickness = 2
		uiStroke.Color = Grunge.WindowStroke
	end

	local v11

	if p then
		v11 = p.parent or instance
	else
		v11 = instance
	end

	if not v11:FindFirstChild("NewUIDecorFront") then
		buildDecor(instance, p, p2)
	end
end

local function undecorateWindow(instance)
	for _, childName in ipairs({ "NewUIDecorBack", "NewUIDecorFront" }) do
		local child = instance:FindFirstChild(childName)

		if child then
			child:Destroy()
		end

		local child2 = instance.Parent and instance.Parent:FindFirstChild(childName)

		if child2 and instance.Parent:IsA("GuiObject") then
			child2:Destroy()
		end
	end

	if not instance:GetAttribute("ui0_Win") then
		return
	end

	local ui0_BgT = instance:GetAttribute("ui0_BgT")

	if ui0_BgT then
		instance.BackgroundTransparency = ui0_BgT
	end

	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		local ui0_StT = instance:GetAttribute("ui0_StT")
		local ui0_StC = instance:GetAttribute("ui0_StC")

		if ui0_StT then
			uiStroke.Thickness = ui0_StT
		end

		if ui0_StC then
			uiStroke.Color = ui0_StC
		end
	end

	local ui0_Clip = instance:GetAttribute("ui0_Clip")

	if ui0_Clip ~= nil then
		instance.ClipsDescendants = ui0_Clip
	end

	for _, v11 in ipairs({ "ui0_Win", "ui0_BgT", "ui0_StT", "ui0_StC", "ui0_Clip" }) do
		instance:SetAttribute(v11, nil)
	end
end

local function pathFind(instance, ...)
	for _, childName in ipairs({ ... }) do
		instance = instance and instance:FindFirstChild(childName)

		if not instance then
			return nil
		end
	end

	return instance
end

local function addBolt(bolts, p, p2, p3, p4, p5, accent)
	local v11 = {
		Vector2.new(0.8 * p3, 0),
		Vector2.new(0.18 * p3, 0.56 * p4),
		Vector2.new(0.8 * p3, 0.46 * p4),
		Vector2.new(0.2 * p3, p4)
	}

	for i = 1, 3 do
		local v12 = v11[i]
		local v13 = v11[i + 1]
		local v14 = v13 - v12
		local midpoint = (v12 + v13) / 2
		local parent = mk("Frame", { -- inferred equivalent call
			Name = "Seg" .. i,
			BackgroundColor3 = accent,
			BorderSizePixel = 0,
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(p + midpoint.X, p2 + midpoint.Y),
			Size = UDim2.fromOffset(v14.Magnitude + p5 * 0.5, p5),
			Rotation = math.deg((math.atan2(v14.Y, v14.X)))
		}, bolts)

		mk("UICorner", { -- inferred equivalent call
			CornerRadius = UDim.new(0, ((math.ceil)(p5 / 2)))
		}, parent)
	end
end

local function buildBolts(p)
	local v11 = math.floor(22 * p + 0.5)
	local bolts = mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorBolts",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.fromOffset(math.floor(30 * p + 0.5), v11)
	})

	local accent = Colors.Accent
	local v12 = 7 * p
	local v13 = 13 * p
	local v14 = 11 * p
	local v15 = 22 * p
	addBolt(bolts, 0, (v11 - v13) / 2, v12, v13, 2, accent)
	addBolt(bolts, 9 * p, (v11 - v15) / 2, v14, v15, 3, accent)
	addBolt(bolts, 22 * p, (v11 - v13) / 2, v12, v13, 2, accent)
	return bolts
end

local function addBoltsTo(parent, p, p2, value)
	if parent:GetAttribute("ui0_xP") then
		return
	end

	parent:SetAttribute("ui0_xP", true)
	mk("UIPadding", { Name = "NewUIDecorPad", PaddingLeft = UDim.new(0, p) }, parent) -- inferred equivalent call
	local bolts = buildBolts(p2)
	bolts.AnchorPoint = Vector2.new(0, 0.5)
	bolts.Position = UDim2.new(0, -(p - (value or 8)), 0.5, 0)
	bolts.Parent = parent
end

local function removeBoltsFrom(instance)
	if not (instance and instance:GetAttribute("ui0_xP")) then
		return
	end

	for _, childName in ipairs({ "NewUIDecorPad", "NewUIDecorBolts" }) do
		local child = instance:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	instance:SetAttribute("ui0_xP", nil)
end

local function skinClose(button)
	if not button or not button:IsA("TextButton") or button:GetAttribute("ui0_xB") ~= nil then
		return
	end

	button:SetAttribute("ui0_xB", button.BackgroundTransparency)
	button.BackgroundTransparency = 1
	mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorTape",
		BackgroundColor3 = Grunge.Tape,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = button.ZIndex,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 12, 0, 24),
		Rotation = -4
	}, button)

	for _, frame in ipairs(button:GetChildren()) do
		if not frame:IsA("Frame") or isInDecor(frame) then
			continue
		end

		frame:SetAttribute("ui0_xC", frame.BackgroundColor3)
		frame:SetAttribute("ui0_xSz", frame.Size)
		frame:SetAttribute("ui0_xZ", frame.ZIndex)
		frame.BackgroundColor3 = Color3.fromRGB(28, 24, 20)
		frame.Size = UDim2.new(0, 15, 0, 3)
		frame.ZIndex = button.ZIndex + 1
	end
end

local function unskinClose(instance)
	if not instance or instance:GetAttribute("ui0_xB") == nil then
		return
	end

	instance.BackgroundTransparency = instance:GetAttribute("ui0_xB")
	local newUIDecorTape = instance:FindFirstChild("NewUIDecorTape")

	if newUIDecorTape then
		newUIDecorTape:Destroy()
	end

	for _, frame in ipairs(instance:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local ui0_xC = frame:GetAttribute("ui0_xC")
		local ui0_xSz = frame:GetAttribute("ui0_xSz")
		local ui0_xZ = frame:GetAttribute("ui0_xZ")

		if ui0_xC then
			frame.BackgroundColor3 = ui0_xC
		end

		if ui0_xSz then
			frame.Size = ui0_xSz
		end

		if ui0_xZ then
			frame.ZIndex = ui0_xZ
		end

		frame:SetAttribute("ui0_xC", nil)
		frame:SetAttribute("ui0_xSz", nil)
		frame:SetAttribute("ui0_xZ", nil)
	end

	instance:SetAttribute("ui0_xB", nil)
end

local function skinResultsClose(button)
	if not button or not button:IsA("TextButton") or button:GetAttribute("ui0_xR") then
		return
	end

	button:SetAttribute("ui0_xR", true)
	button:SetAttribute("ui0_xRbg", button.BackgroundColor3)
	button:SetAttribute("ui0_xRbt", button.BackgroundTransparency)
	button:SetAttribute("ui0_xRtc", button.TextColor3)
	button.BackgroundColor3 = Grunge.Tape
	button.BackgroundTransparency = 0.08
	button.TextColor3 = Color3.fromRGB(28, 24, 20)
	button.Rotation = -4
	local uiCorner = button:FindFirstChildOfClass("UICorner")

	if uiCorner then
		button:SetAttribute("ui0_xRc", uiCorner.CornerRadius)
		uiCorner.CornerRadius = UDim.new(0, 2)
	end
end

local function unskinResultsClose(instance)
	if not (instance and instance:GetAttribute("ui0_xR")) then
		return
	end

	instance.BackgroundColor3 = instance:GetAttribute("ui0_xRbg")
	instance.BackgroundTransparency = instance:GetAttribute("ui0_xRbt")
	instance.TextColor3 = instance:GetAttribute("ui0_xRtc")
	instance.Rotation = 0
	local uiCorner = instance:FindFirstChildOfClass("UICorner")
	local ui0_xRc = instance:GetAttribute("ui0_xRc")

	if uiCorner and ui0_xRc then
		uiCorner.CornerRadius = ui0_xRc
	end

	for _, v11 in ipairs({ "ui0_xR", "ui0_xRbg", "ui0_xRbt", "ui0_xRtc", "ui0_xRc" }) do
		instance:SetAttribute(v11, nil)
	end
end

local function resultsParts(instance)
	if instance.Name ~= "ResultsScreenUI" then
		return nil
	end

	local overlay = instance:FindFirstChild("Overlay")
	return overlay, overlay and overlay:FindFirstChild("Panel"), overlay and overlay:FindFirstChild("CloseButton")
end

local function applySettingsExtras(instance)
	local dropdown = instance:FindFirstChild("Dropdown")

	if dropdown and not dropdown:GetAttribute("ui0_Dd") then
		dropdown:SetAttribute("ui0_Dd", true)
		dropdown:SetAttribute("ui0_DdClip", dropdown.ClipsDescendants)
		dropdown.ClipsDescendants = false
		local glass = dropdown:FindFirstChild("Glass")

		if glass then
			glass:SetAttribute("ui0_GBg", glass.BackgroundColor3)
			glass:SetAttribute("ui0_GT", glass.BackgroundTransparency)
			glass.BackgroundColor3 = Colors.Background
			glass.BackgroundTransparency = 0.06
		end

		local uiStroke = dropdown:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			dropdown:SetAttribute("ui0_DdStT", uiStroke.Thickness)
			dropdown:SetAttribute("ui0_DdStC", uiStroke.Color)
			uiStroke.Thickness = 2
			uiStroke.Color = Grunge.WindowStroke
		end

		if not dropdown:FindFirstChild("NewUIDecorFront") then
			buildDecor(dropdown, nil, 0.8)
		end
	end
end

local function removeSettingsExtras(instance)
	local dropdown = instance:FindFirstChild("Dropdown")

	if dropdown and dropdown:GetAttribute("ui0_Dd") then
		local newUIDecorFront = dropdown:FindFirstChild("NewUIDecorFront")

		if newUIDecorFront then
			newUIDecorFront:Destroy()
		end

		local ui0_DdClip = dropdown:GetAttribute("ui0_DdClip")

		if ui0_DdClip ~= nil then
			dropdown.ClipsDescendants = ui0_DdClip
		end

		local glass = dropdown:FindFirstChild("Glass")

		if glass then
			local ui0_GBg = glass:GetAttribute("ui0_GBg")
			local ui0_GT = glass:GetAttribute("ui0_GT")

			if ui0_GBg then
				glass.BackgroundColor3 = ui0_GBg
			end

			if ui0_GT then
				glass.BackgroundTransparency = ui0_GT
			end

			glass:SetAttribute("ui0_GBg", nil)
			glass:SetAttribute("ui0_GT", nil)
		end

		local uiStroke = dropdown:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			local ui0_DdStT = dropdown:GetAttribute("ui0_DdStT")
			local ui0_DdStC = dropdown:GetAttribute("ui0_DdStC")

			if ui0_DdStT then
				uiStroke.Thickness = ui0_DdStT
			end

			if ui0_DdStC then
				uiStroke.Color = ui0_DdStC
			end
		end

		for _, v11 in ipairs({ "ui0_Dd", "ui0_DdClip", "ui0_DdStT", "ui0_DdStC" }) do
			dropdown:SetAttribute(v11, nil)
		end
	end
end

local backgroundTransparencyChangedConnection = nil
local function applyToastExtras(instance)
	if instance.Name == "SongListToastGui" then
		local inviteResponseBar = instance:FindFirstChild("InviteResponseBar")

		if inviteResponseBar and not inviteResponseBar:GetAttribute("NoNewUISkin") then
			local badge = inviteResponseBar:FindFirstChild("Badge")

			if badge and not badge:GetAttribute("ui0_xBd") then
				badge:SetAttribute("ui0_xBd", badge.BackgroundTransparency)
				badge.BackgroundTransparency = 1
				local icon = badge:FindFirstChild("Icon")

				if icon then
					icon:SetAttribute("ui0_xIc", icon.TextColor3)
					icon.TextColor3 = Colors.Accent
				end
			end

			for _, button in ipairs(inviteResponseBar:GetChildren()) do
				if not button:IsA("TextButton") or button:GetAttribute("ui0_xBt") then
					continue
				end

				local color = button.Name:find("Deny") and Color3.fromRGB(214, 96, 84) or Color3.fromRGB(100, 196, 130)
				button:SetAttribute("ui0_xBt", button.BackgroundTransparency)
				button:SetAttribute("ui0_xBc", button.TextColor3)
				button.BackgroundTransparency = 1
				button.TextColor3 = color
				mk("UIStroke", { -- inferred equivalent call
					Name = "NewUIDecorStroke",
					Color = color,
					Thickness = 1.5,
					Transparency = 0.35,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}, button)
			end
		end
	elseif instance.Name == "SyncAdjustmentNoticeUI" then
		local notice = instance:FindFirstChild("Notice")

		if notice and notice:IsA("TextLabel") and not notice:GetAttribute("ui0_xN") then
			notice:SetAttribute("ui0_xN", true)
			notice:SetAttribute("ui0_xNbg", notice.BackgroundTransparency)
			notice:SetAttribute("ui0_xNsT", notice.TextStrokeTransparency)
			notice:SetAttribute("ui0_xNsC", notice.TextStrokeColor3)
			notice.TextStrokeColor3 = Color3.new(0, 0, 0)
			notice.TextStrokeTransparency = 0.4
			notice.BackgroundTransparency = 1

			backgroundTransparencyChangedConnection = notice:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
				if v == "NewUI" and notice.BackgroundTransparency < 1 then
					notice.BackgroundTransparency = 1
				end
			end)
		end
	end
end

local function removeToastExtras(instance)
	if instance.Name == "SongListToastGui" then
		local inviteResponseBar = instance:FindFirstChild("InviteResponseBar")

		if inviteResponseBar then
			local badge = inviteResponseBar:FindFirstChild("Badge")

			if badge and badge:GetAttribute("ui0_xBd") ~= nil then
				badge.BackgroundTransparency = badge:GetAttribute("ui0_xBd")
				local icon = badge:FindFirstChild("Icon")
				local ui0_xIc = icon and icon:GetAttribute("ui0_xIc")

				if icon and ui0_xIc then
					icon.TextColor3 = ui0_xIc
					icon:SetAttribute("ui0_xIc", nil)
				end

				badge:SetAttribute("ui0_xBd", nil)
			end

			for _, button in ipairs(inviteResponseBar:GetChildren()) do
				if not (button:IsA("TextButton") and button:GetAttribute("ui0_xBt") ~= nil) then
					continue
				end

				button.BackgroundTransparency = button:GetAttribute("ui0_xBt")
				button.TextColor3 = button:GetAttribute("ui0_xBc")
				button:SetAttribute("ui0_xBt", nil)
				button:SetAttribute("ui0_xBc", nil)
			end
		end
	elseif instance.Name == "SyncAdjustmentNoticeUI" then
		local notice = instance:FindFirstChild("Notice")

		if backgroundTransparencyChangedConnection then
			backgroundTransparencyChangedConnection:Disconnect()
			backgroundTransparencyChangedConnection = nil
		end

		if notice and notice:GetAttribute("ui0_xN") then
			local ui0_xNsT = notice:GetAttribute("ui0_xNsT")
			local ui0_xNsC = notice:GetAttribute("ui0_xNsC")

			if ui0_xNsT ~= nil then
				notice.TextStrokeTransparency = ui0_xNsT
			end

			if ui0_xNsC then
				notice.TextStrokeColor3 = ui0_xNsC
			end

			local ui0_xNbg = notice:GetAttribute("ui0_xNbg")

			if ui0_xNbg ~= nil then
				notice.BackgroundTransparency = ui0_xNbg
			end

			for _, v11 in ipairs({ "ui0_xN", "ui0_xNbg", "ui0_xNsT", "ui0_xNsC" }) do
				notice:SetAttribute(v11, nil)
			end
		end
	end
end

local v11 = nil

local function setp(instance, p, p2) -- 30 equivalent calls inferred from this helper
	local v12 = "ui0_k_" .. p

	if instance:GetAttribute(v12) == nil then
		instance:SetAttribute(v12, instance[p])
	end

	instance[p] = p2
end

local function unkeepAll(folder)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, descendant in ipairs(descendants) do
		for k, v12 in pairs(descendant:GetAttributes()) do
			if k:sub(1, 6) ~= "ui0_k_" then
				continue
			end

			local v13 = k
			local v14 = v12
			pcall(function()
				descendant[v13:sub(7)] = v14
			end)
			descendant:SetAttribute(k, nil)
		end
	end
end

local color = Color3.fromRGB(150, 142, 122)

local function pcTape(parent, name, position, size, rotation, backgroundColor, backgroundTransparency)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position,
		Size = size,
		Rotation = rotation
	}, parent)

	mk("Frame", { -- inferred equivalent call
		Name = "Crease",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 0, 0.3, 0),
		Size = UDim2.new(1, 0, 0, 1)
	}, parent2)
	mk("Frame", { -- inferred equivalent call
		Name = "Edge",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2)
	}, parent2)
	local random = Random.new(#name * 7 + size.X.Offset)

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Dirt" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7 + random:NextNumber() * 0.15,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(random:NextNumber() * 0.8, 0, random:NextNumber() * 0.6, 0),
			Size = UDim2.fromOffset(random:NextInteger(3, 9), random:NextInteger(2, 4))
		}, parent2)
	end

	return parent2
end

local function buildPlayerCardDecor(parent)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Inner",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.fromOffset(26, 26),
		Size = UDim2.new(1, -52, 1, -52)
	}, parent)

	local random = Random.new(29)

	local function vig(name, position, size, rotation, p)
		local parent3 = mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size
		}, parent2)
		mk("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
		}, parent3)
	end
	vig("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 22), 90, 0.55)
	vig("VigBottom", UDim2.new(0, 0, 1, -22), UDim2.new(1, 0, 0, 22), 270, 0.55)
	vig("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 22, 1, 0), 0, 0.6)
	vig("VigRight", UDim2.new(1, -22, 0, 0), UDim2.new(0, 22, 1, 0), 180, 0.6)

	for i = 1, 8 do
		local integer = random:NextInteger(40, 110)
		local parent3 = mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 3 == 0 and Grunge.Rust or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.9 + random:NextNumber() * 0.05,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.8),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
		}, parent2)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
	end

	for i, v12 in ipairs({
		{ 0.1, 0.22, 120, 24 },
		{ 0.62, 0.4, 90, -31 },
		{ 0.3, 0.66, 150, 12 },
		{ 0.78, 0.8, 80, -20 },
		{ 0.05, 0.9, 100, 35 },
		{ 0.48, 0.12, 100, -14 },
		{ 0.86, 0.28, 70, 52 }
	}) do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = Colors.TextPrimary,
			BackgroundTransparency = 0.94,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(v12[1], v12[2]),
			Size = UDim2.new(0, v12[3], 0, 1),
			Rotation = v12[4]
		}, parent2)
	end

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Scuff" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, random:NextInteger(24, 60), 0, 1),
			Rotation = random:NextInteger(-40, 40)
		}, parent2)
	end

	for i = 1, 46 do
		local v12 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 3)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v12 and Colors.TextPrimary or Color3.new(0, 0, 0),
			BackgroundTransparency = v12 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, integer)
		}, parent2)
	end

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6)
	}, parent2)
	mk("UIStroke", { Color = Grunge.EdgeWear, Thickness = 1.5, Transparency = 0.55 }, parent3) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent3) -- inferred equivalent call

	pcTape(parent2, "TapeTL", UDim2.fromOffset(10, 9), UDim2.fromOffset(60, 14), -45, Grunge.Tape, 0.1)
	pcTape(parent2, "TapeTop", UDim2.new(0.7, 0, 0, 0), UDim2.fromOffset(74, 15), -2, color, 0.15)
	pcTape(parent2, "TapeBR", UDim2.new(1, -9, 1, -7), UDim2.fromOffset(56, 13), -45, Grunge.TapeDark, 0.12)
	pcTape(parent2, "TapeBL", UDim2.new(0.13, 0, 1, 0), UDim2.fromOffset(44, 12), 3, Color3.fromRGB(214, 170, 80), 0.18)
end

local function removePCFollower()
	if not v11 then
		return
	end

	for _, conn in ipairs(v11.conns) do
		conn:Disconnect()
	end

	if v11.layer then
		v11.layer:Destroy()
	end

	v11 = nil
end

local function makePCFollower(playerCard)
	local screenGui = playerCard:FindFirstAncestorOfClass("ScreenGui")

	if not screenGui or v11 then
		return
	end

	local layer = mk("CanvasGroup", { -- inferred equivalent call
		Name = "NewUIDecorFollowPC",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = playerCard.ZIndex + 10,
		Visible = false,
		GroupTransparency = 1
	}, screenGui)

	buildPlayerCardDecor(layer)
	local connections = {}
	v11 = { layer = layer, conns = connections }
	local function sync()
		if not (playerCard.Parent and layer.Parent) then
			return
		end

		local groupTransparency = playerCard.GroupTransparency
		local visible = playerCard.Visible

		if visible then
			if groupTransparency < 0.99 then
				visible = playerCard:IsDescendantOf(screenGui)
			else
				visible = false
			end
		end

		layer.Visible = visible
		local absolutePosition = playerCard.AbsolutePosition
		local absoluteSize = playerCard.AbsoluteSize
		local absolutePosition2 = screenGui.AbsolutePosition
		layer.Position = UDim2.fromOffset(
			absolutePosition.X - absolutePosition2.X - 26,
			absolutePosition.Y - absolutePosition2.Y - 26
		)
		layer.Size = UDim2.fromOffset(absoluteSize.X + 52, absoluteSize.Y + 52)
		layer.GroupTransparency = groupTransparency
	end

	for _, propertyName in ipairs({
		"AbsolutePosition",
		"AbsoluteSize",
		"Visible",
		"GroupTransparency"
	}) do
		table.insert(connections, playerCard:GetPropertyChangedSignal(propertyName):Connect(sync))
	end

	sync()
end

local function pcStroke(instance, color2, thickness, transparency)
	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		setp(uiStroke, "Color", color2) -- inferred equivalent call
		setp(uiStroke, "Thickness", thickness) -- inferred equivalent call
		setp(uiStroke, "Transparency", transparency) -- inferred equivalent call
	else
		mk("UIStroke", { -- inferred equivalent call
			Name = "NewUIDecorStroke",
			Color = color2,
			Thickness = thickness,
			Transparency = transparency,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, instance)
	end
end

local function pcDashed(parent)
	if not parent then
		return
	end

	setp(parent, "BackgroundTransparency", 1) -- inferred equivalent call
	local random = Random.new(#parent.Name * 13)

	for i = 1, 30 do
		mk("Frame", { -- inferred equivalent call
			Name = "NewUIDecorDash" .. i,
			BackgroundColor3 = Colors.Border,
			BackgroundTransparency = 0.1 + random:NextNumber() * 0.3,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new((i - 1) / 30, 0, 0, random:NextInteger(-1, 0)),
			Size = UDim2.new(0.018 + random:NextNumber() * 0.014, 0, 0, 2)
		}, parent)
	end
end

local function applyPlayerCardExtras(instance)
	if instance.Name == "StatTooltipGui" then
		local tooltipBubble = instance:FindFirstChild("TooltipBubble")

		if tooltipBubble and not tooltipBubble:GetAttribute("ui0_pc") then
			tooltipBubble:SetAttribute("ui0_pc", true)
			setp(tooltipBubble, "BackgroundTransparency", 0.03) -- inferred equivalent call
			pcStroke(tooltipBubble, Grunge.WindowStroke, 2, 0)
			local uiCorner = tooltipBubble:FindFirstChildOfClass("UICorner")

			if uiCorner then
				setp(uiCorner, "CornerRadius", UDim.new(0, 2)) -- inferred equivalent call
			end
		end
	else
		local playerCard = instance:FindFirstChild("PlayerCard")

		if not playerCard or playerCard:GetAttribute("ui0_pc") then
			return
		end

		playerCard:SetAttribute("ui0_pc", true)

		local body = playerCard:FindFirstChild("Body") or playerCard
		setp(playerCard, "BackgroundTransparency", 0.02) -- inferred equivalent call
		local uiCorner = playerCard:FindFirstChildOfClass("UICorner")

		if uiCorner then
			setp(uiCorner, "CornerRadius", UDim.new(0, 2)) -- inferred equivalent call
		end

		local uiStroke = playerCard:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			setp(uiStroke, "Color", Grunge.WindowStroke) -- inferred equivalent call
			setp(uiStroke, "Thickness", 2) -- inferred equivalent call
			setp(uiStroke, "Transparency", 0) -- inferred equivalent call
			mk("UIGradient", { -- inferred equivalent call
				Name = "NewUIDecorWear",
				Rotation = 35,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.2, 0.15),
					NumberSequenceKeypoint.new(0.33, 0.85),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(0.72, 0.7),
					NumberSequenceKeypoint.new(0.88, 0.1),
					NumberSequenceKeypoint.new(1, 0)
				})
			}, uiStroke)
		end

		local header = playerCard:FindFirstChild("Header")

		if header then
			local avatarShell = header:FindFirstChild("AvatarShell")

			if avatarShell then
				setp(avatarShell, "BackgroundColor3", Color3.fromRGB(214, 206, 182)) -- inferred equivalent call
				setp(avatarShell, "Rotation", -3) -- inferred equivalent call
				local uiCorner2 = avatarShell:FindFirstChildOfClass("UICorner")

				if uiCorner2 then
					setp(uiCorner2, "CornerRadius", UDim.new(0, 2)) -- inferred equivalent call
				end

				pcStroke(avatarShell, Grunge.WindowStroke, 1.5, 0)
				local avatar = avatarShell:FindFirstChild("Avatar")

				if avatar then
					setp(avatar, "Size", UDim2.new(1, -8, 1, -8)) -- inferred equivalent call
					setp(avatar, "Position", UDim2.fromOffset(4, 4)) -- inferred equivalent call
					setp(avatar, "BackgroundColor3", Color3.fromRGB(32, 30, 27)) -- inferred equivalent call
					setp(avatar, "BackgroundTransparency", 0) -- inferred equivalent call
					local uiCorner3 = avatar:FindFirstChildOfClass("UICorner")

					if uiCorner3 then
						setp(uiCorner3, "CornerRadius", UDim.new(0, 1)) -- inferred equivalent call
					end
				end
			end

			local identity = header:FindFirstChild("Identity")
			local nameLabel = identity and identity:FindFirstChild("NameLabel")

			if nameLabel then
				setp(nameLabel, "TextSize", 24) -- inferred equivalent call
				mk("Frame", { -- inferred equivalent call
					Name = "NewUIDecorMarkA",
					BackgroundColor3 = Colors.Accent,
					BackgroundTransparency = 0.1,
					BorderSizePixel = 0,
					Active = false,
					Position = UDim2.new(0, 0, 1, -1),
					Size = UDim2.new(0.5, 0, 0, 2),
					Rotation = -1
				}, nameLabel)
				mk("Frame", { -- inferred equivalent call
					Name = "NewUIDecorMarkB",
					BackgroundColor3 = Colors.Accent,
					BackgroundTransparency = 0.45,
					BorderSizePixel = 0,
					Active = false,
					Position = UDim2.new(0.04, 0, 1, 2),
					Size = UDim2.new(0.34, 0, 0, 1),
					Rotation = 1
				}, nameLabel)

				if not nameLabel:GetAttribute("ui0_pcTxt") then
					nameLabel:SetAttribute("ui0_pcTxt", true)
					nameLabel:GetPropertyChangedSignal("Text"):Connect(function()
						if v ~= "NewUI" or not nameLabel:GetAttribute("ui0_k_TextSize") then
							return
						end

						nameLabel.TextSize = 24
						task.delay(0.05, function()
							if v == "NewUI" and nameLabel.Parent then
								local count = 0

								while
									nameLabel.TextBounds.X > nameLabel.AbsoluteSize.X - 2
									and nameLabel.TextSize > 12
									and count < 12
								do
									nameLabel.TextSize -= 1
									count += 1
								end
							end
						end)
					end)
				end
			end

			local subtitleLabel = identity and identity:FindFirstChild("SubtitleLabel")

			if subtitleLabel then
				setp(subtitleLabel, "TextSize", 13) -- inferred equivalent call
			end

			skinClose(header:FindFirstChild("CloseCardButton"))

			local joinSessionButton = header:FindFirstChild("JoinSessionButton")

			if joinSessionButton then
				setp(joinSessionButton, "Rotation", -2) -- inferred equivalent call
				pcStroke(joinSessionButton, Grunge.WindowStroke, 1.5, 0)
			end
		end

		pcDashed(playerCard:FindFirstChild("HeaderDivider"))
		pcDashed(body:FindFirstChild("FooterDivider"))

		local stats = body:FindFirstChild("Stats")

		if stats then
			for i, childName in ipairs({ "SongsStat", "GigsStat", "ScoreStat" }) do
				local child = stats:FindFirstChild(childName)

				if not child then
					continue
				end

				pcStroke(child, Grunge.WindowStroke, 1.5, 0)
				local value = child:FindFirstChild("Value")

				if value then
					setp(value, "TextColor3", Colors.Accent) -- inferred equivalent call
					setp(value, "TextSize", 19) -- inferred equivalent call
				end

				local caption = child:FindFirstChild("Caption")

				if caption then
					setp(caption, "TextColor3", Colors.TextSecondary) -- inferred equivalent call
				end

				if i == 1 then
					pcTape(
						child,
						"NewUIDecorTape",
						UDim2.fromOffset(12, 1),
						UDim2.fromOffset(30, 9),
						-12,
						Grunge.Tape,
						0.12
					)
				elseif i == 3 then
					pcTape(child, "NewUIDecorTape", UDim2.new(1, -12, 0, 1), UDim2.fromOffset(30, 9), 9, color, 0.12)
				end
			end
		end

		for _, v12 in ipairs({ "FavoriteGenres", "MostlyPlays", "Bio" }) do
			local parent = pathFind(body, v12, "SectionTitle")

			if not parent then
				continue
			end

			setp(parent, "TextColor3", Colors.TextSecondary) -- inferred equivalent call
			mk("Frame", { -- inferred equivalent call
				Name = "NewUIDecorMark",
				BackgroundColor3 = Colors.Accent,
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				Active = false,
				Position = UDim2.new(0, 0, 1, 2),
				Size = UDim2.fromOffset(22, 2),
				Rotation = -1.5
			}, parent)
		end

		local parent = pathFind(body, "FavoriteGenres", "Content", "ChangeGenresButton")

		if parent then
			setp(parent, "BackgroundTransparency", 1) -- inferred equivalent call
			pcStroke(parent, Colors.Accent, 1.5, 0.35)
		end

		local parent2 = pathFind(body, "Bio", "BioDisplayButton")

		if parent2 then
			setp(parent2, "BackgroundTransparency", 0.15) -- inferred equivalent call
			pcStroke(parent2, Colors.Border, 1, 0.2)

			pcTape(parent2, "NewUIDecorTape", UDim2.fromOffset(4, -6), UDim2.fromOffset(34, 9), -32, Grunge.Tape, 0.1)
		end

		local parent3 = pathFind(body, "Bio", "BioEditRow", "BioSaveButton")

		if parent3 then
			setp(parent3, "Rotation", -2) -- inferred equivalent call
			pcStroke(parent3, Grunge.WindowStroke, 1.5, 0)
		end

		local footerLabel = body:FindFirstChild("FooterLabel")

		if footerLabel then
			setp(footerLabel, "TextColor3", Colors.TextSecondary) -- inferred equivalent call
		end

		makePCFollower(playerCard)
	end
end

local function removePlayerCardExtras(instance)
	if instance.Name == "StatTooltipGui" then
		local tooltipBubble = instance:FindFirstChild("TooltipBubble")

		if tooltipBubble and tooltipBubble:GetAttribute("ui0_pc") then
			unkeepAll(tooltipBubble)
			tooltipBubble:SetAttribute("ui0_pc", nil)
		end
	else
		local playerCard = instance:FindFirstChild("PlayerCard")

		if not (playerCard and playerCard:GetAttribute("ui0_pc")) then
			return
		end

		unskinClose(pathFind(playerCard, "Header", "CloseCardButton"))
		removePCFollower()
		local descendants = {}

		for _, descendant in ipairs(playerCard:GetDescendants()) do
			if descendant.Name:sub(1, 10) == "NewUIDecor" then
				table.insert(descendants, descendant)
			end
		end

		for _, v12 in ipairs(descendants) do
			v12:Destroy()
		end

		unkeepAll(playerCard)
		playerCard:SetAttribute("ui0_pc", nil)
	end
end

local function micTitleMark(title, p)
	if not title or title:FindFirstChild("NewUIDecorMicMark") then
		return
	end

	local parent = mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorMicMark",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.fromScale(1, 1)
	}, title)
	mk("Frame", { -- inferred equivalent call
		Name = "L1",
		BackgroundColor3 = Colors.Accent,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 2, 1, -3),
		Size = UDim2.new(p, 0, 0, 2),
		Rotation = -0.8
	}, parent)
	mk("Frame", { -- inferred equivalent call
		Name = "L2",
		BackgroundColor3 = Colors.Accent,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 24, 1, 1),
		Size = UDim2.new(p * 0.65, 0, 0, 1),
		Rotation = 0.9
	}, parent)
end

local function micSkinHandle(frame)
	if frame:GetAttribute("ui0_mH") then
		return
	end

	frame:SetAttribute("ui0_mH", true)
	frame:SetAttribute("ui0_mHBg", frame.BackgroundColor3)
	frame:SetAttribute("ui0_mHSz", frame.Size)
	frame:SetAttribute("ui0_mHRot", frame.Rotation)
	frame.BackgroundColor3 = Grunge.Tape
	frame.Size = UDim2.fromOffset(11, 22)
	frame.Rotation = -8
	local uiCorner = frame:FindFirstChildOfClass("UICorner")

	if uiCorner then
		frame:SetAttribute("ui0_mHCr", uiCorner.CornerRadius)
		uiCorner.CornerRadius = UDim.new(0, 1)
	end

	if not frame:FindFirstChild("NewUIDecorStroke") then
		mk("UIStroke", { -- inferred equivalent call
			Name = "NewUIDecorStroke",
			Color = Color3.new(0, 0, 0),
			Thickness = 1.5,
			Transparency = 0.35,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, frame)
	end
end

local function applyMicExtras(folder)
	local panel = folder:FindFirstChild("Panel")

	if panel then
		micTitleMark(panel:FindFirstChild("Title"), 0.42)
		skinResultsClose(panel:FindFirstChild("CloseButton"))

		if not panel:FindFirstChild("NewUIDecorMicScrawl") then
			mk("TextLabel", { -- inferred equivalent call
				Name = "NewUIDecorMicScrawl",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Active = false,
				Position = UDim2.fromOffset(142, 9),
				Size = UDim2.fromOffset(112, 30),
				Rotation = -7,
				Font = Enum.Font.PermanentMarker,
				Text = "CHECK 1-2!",
				TextSize = 19,
				TextColor3 = Colors.Accent,
				TextTransparency = 0.25,
				TextXAlignment = Enum.TextXAlignment.Center
			}, panel)
		end

		local putBackButton = panel:FindFirstChild("PutBackButton")

		if putBackButton and putBackButton:GetAttribute("ui0_mPb") == nil then
			putBackButton:SetAttribute("ui0_mPb", putBackButton.BackgroundColor3)
			putBackButton.BackgroundColor3 = Color3.fromRGB(52, 22, 20)
			local v12 = putBackButton:FindFirstChild("NewUIDecorStroke")

			if not v12 then
				local v13 = {
					Name = "NewUIDecorStroke",
					Thickness = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}
				v12 = Instance.new("UIStroke")

				for k, v14 in pairs(v13) do
					v12[k] = v14
				end

				v12.Parent = putBackButton
			end

			v12.Color = Colors.Danger
			v12.Transparency = 0.1
		end
	end

	local vocalistInfoBox = folder:FindFirstChild("VocalistInfoBox")

	if vocalistInfoBox then
		micTitleMark(vocalistInfoBox:FindFirstChild("Title"), 0.5)
	end

	for _, frame in ipairs(folder:GetDescendants()) do
		if frame.Name == "SliderHandle" and frame:IsA("Frame") then
			micSkinHandle(frame)
		end
	end
end

local function removeMicExtras(folder)
	local panel = folder:FindFirstChild("Panel")

	if panel then
		unskinResultsClose(panel:FindFirstChild("CloseButton"))
		local putBackButton = panel:FindFirstChild("PutBackButton")

		if putBackButton and putBackButton:GetAttribute("ui0_mPb") ~= nil then
			putBackButton.BackgroundColor3 = putBackButton:GetAttribute("ui0_mPb")
			putBackButton:SetAttribute("ui0_mPb", nil)
		end
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not descendant:GetAttribute("ui0_mH") then
			continue
		end

		descendant.BackgroundColor3 = descendant:GetAttribute("ui0_mHBg")
		descendant.Size = descendant:GetAttribute("ui0_mHSz")
		descendant.Rotation = descendant:GetAttribute("ui0_mHRot")
		local uiCorner = descendant:FindFirstChildOfClass("UICorner")
		local ui0_mHCr = descendant:GetAttribute("ui0_mHCr")

		if uiCorner and ui0_mHCr then
			uiCorner.CornerRadius = ui0_mHCr
		end

		for _, v12 in ipairs({ "ui0_mH", "ui0_mHBg", "ui0_mHSz", "ui0_mHRot", "ui0_mHCr" }) do
			descendant:SetAttribute(v12, nil)
		end
	end

	local descendants = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name:sub(1, 13) == "NewUIDecorMic" then
			table.insert(descendants, descendant)
		end
	end

	for _, v12 in ipairs(descendants) do
		v12:Destroy()
	end
end

local function findDifficultyTitle(folder)
	for _, label in ipairs(folder:GetDescendants()) do
		if label:IsA("TextLabel") and label.Text == "DIFFICULTY" then
			return label
		end
	end
end

local fn
local fn2
local fn3
local fn4

local function applyServerBrowserExtras(instance)
	local v12 = pathFind(instance, "Overlay", "Panel")

	if not v12 then
		return
	end

	skinResultsClose(v12:FindFirstChild("Close"))
	local title = v12:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		if not title:GetAttribute("ui0_xT") then
			title:SetAttribute("ui0_xT", title.Text)
			title.Text = "SERVER BROWSER"
			title.TextSize = 20
		end

		addBoltsTo(title, 42, 1)
	end
end

local function removeServerBrowserExtras(instance)
	local v12 = pathFind(instance, "Overlay", "Panel")

	if not v12 then
		return
	end

	unskinResultsClose(v12:FindFirstChild("Close"))
	local title = v12:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		removeBoltsFrom(title)
		local ui0_xT = title:GetAttribute("ui0_xT")

		if ui0_xT then
			title.Text = ui0_xT
			title:SetAttribute("ui0_xT", nil)
		end
	end
end

local function applyExtras(folder)
	applyToastExtras(folder)

	if folder.Name == "AmpSettingsUI" and fn then
		fn(folder)
	end

	if folder.Name == "VirtualKeyboardUI" and fn3 then
		fn3(folder)
	end

	if folder.Name == "MicSettingsUI" then
		applyMicExtras(folder)
	end

	if folder.Name == "PlayerCardGui" or folder.Name == "StatTooltipGui" then
		applyPlayerCardExtras(folder)
	end

	if folder.Name == "SettingsMenuUI" then
		applySettingsExtras(folder)
	end

	if folder.Name == "ServerBrowserUI" then
		applyServerBrowserExtras(folder)
	end

	local window = folder:FindFirstChild("Window")

	if window then
		local label = pathFind(window, "MainSongListUI", "Header", "Title")

		if label and label:IsA("TextLabel") and not label:GetAttribute("ui0_xT") then
			label:SetAttribute("ui0_xT", label.Text)
			label:SetAttribute("ui0_xS", label.TextSize)
			label.Text = "SONG LIST"
			label.TextSize = 22
			mk("UIPadding", { Name = "NewUIDecorPad", PaddingLeft = UDim.new(0, 46) }, label) -- inferred equivalent call
			local parent = mk( -- inferred equivalent call
				"Frame",
				{
					Name = "NewUIDecorIcon",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -42, 0.5, -11),
					Size = UDim2.new(0, 32, 0, 22)
				},
				label
			)
			local parent2 = mk( -- inferred equivalent call
				"Frame",
				{
					Name = "Body",
					BackgroundColor3 = Grunge.Metal,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1)
				},
				parent
			)
			mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
			mk("UIStroke", { Color = Colors.TextPrimary, Thickness = 1.5 }, parent2) -- inferred equivalent call
			local parent3 = mk("Frame", { -- inferred equivalent call
				Name = "Label",
				BackgroundColor3 = Colors.TextPrimary,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Position = UDim2.new(0.12, 0, 0.14, 0),
				Size = UDim2.new(0.76, 0, 0.3, 0)
			}, parent2)
			mk("UICorner", { CornerRadius = UDim.new(0, 1) }, parent3) -- inferred equivalent call

			for i, v12 in ipairs({ 0.17, 0.56 }) do
				local parent4 = mk("Frame", { -- inferred equivalent call
					Name = "Reel" .. i,
					BackgroundColor3 = Colors.Background,
					BorderSizePixel = 0,
					Position = UDim2.new(v12, 0, 0.52, 0),
					Size = UDim2.new(0, 8, 0, 8)
				}, parent2)
				mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
				mk("UIStroke", { Color = Colors.TextPrimary, Thickness = 1 }, parent4) -- inferred equivalent call
			end
		end

		local label2 = pathFind(window, "MainSongListUI", "Body", "LeftColumn", "SearchBar", "Icon")

		if label2 and label2:IsA("TextLabel") and not label2:GetAttribute("ui0_xT") then
			label2:SetAttribute("ui0_xT", label2.Text)
			label2.Text = ""
			local parent = mk("Frame", { -- inferred equivalent call
				Name = "NewUIDecorMag",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(0, 16, 0, 16)
			}, label2)
			local parent2 = mk( -- inferred equivalent call
				"Frame",
				{
					Name = "Ring",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 11, 0, 11)
				},
				parent
			)
			mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
			mk("UIStroke", { Color = Colors.TextPrimary, Thickness = 2 }, parent2) -- inferred equivalent call
			mk("Frame", { -- inferred equivalent call
				Name = "Handle",
				BackgroundColor3 = Colors.TextPrimary,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 13, 0, 13),
				Size = UDim2.new(0, 7, 0, 2.5),
				Rotation = 45
			}, parent)
		end

		skinClose(pathFind(window, "MainSongListUI", "Header", "CloseButton"))

		local newbieModeButton = window:FindFirstChild("NewbieModeButton", true)

		if newbieModeButton and newbieModeButton:IsA("TextButton") then
			addBoltsTo(newbieModeButton, 26, 0.72, 5)

			if newbieModeButton:GetAttribute("ui0_xW") == nil then
				newbieModeButton:SetAttribute("ui0_xW", newbieModeButton.Size)
				newbieModeButton.Size = UDim2.new(
					newbieModeButton.Size.X.Scale,
					newbieModeButton.Size.X.Offset + 34,
					newbieModeButton.Size.Y.Scale,
					newbieModeButton.Size.Y.Offset
				)
			end
		end
	end

	local newbieModePanel = folder:FindFirstChild("NewbieModePanel")

	if newbieModePanel then
		skinClose(newbieModePanel:FindFirstChild("CloseButton"))
		local difficultyTitle = findDifficultyTitle(newbieModePanel)

		if difficultyTitle then
			addBoltsTo(difficultyTitle, 42, 1)
		end
	end
end

local function removeExtras(folder)
	removeToastExtras(folder)

	if folder.Name == "AmpSettingsUI" and fn2 then
		fn2(folder)
	end

	if folder.Name == "VirtualKeyboardUI" and fn4 then
		fn4(folder)
	end

	if folder.Name == "MicSettingsUI" then
		removeMicExtras(folder)
	end

	if folder.Name == "PlayerCardGui" or folder.Name == "StatTooltipGui" then
		removePlayerCardExtras(folder)
	end

	if folder.Name == "SettingsMenuUI" then
		removeSettingsExtras(folder)
	end

	if folder.Name == "ServerBrowserUI" then
		removeServerBrowserExtras(folder)
	end

	local window = folder:FindFirstChild("Window")

	if window then
		local v12 = pathFind(window, "MainSongListUI", "Header", "Title")

		if v12 and v12:GetAttribute("ui0_xT") then
			v12.Text = v12:GetAttribute("ui0_xT")
			local ui0_xS = v12:GetAttribute("ui0_xS")

			if ui0_xS then
				v12.TextSize = ui0_xS
			end

			for _, childName in ipairs({ "NewUIDecorPad", "NewUIDecorIcon" }) do
				local child = v12:FindFirstChild(childName)

				if child then
					child:Destroy()
				end
			end

			v12:SetAttribute("ui0_xT", nil)
			v12:SetAttribute("ui0_xS", nil)
		end

		local v13 = pathFind(window, "MainSongListUI", "Body", "LeftColumn", "SearchBar", "Icon")

		if v13 and v13:GetAttribute("ui0_xT") then
			v13.Text = v13:GetAttribute("ui0_xT")
			local newUIDecorMag = v13:FindFirstChild("NewUIDecorMag")

			if newUIDecorMag then
				newUIDecorMag:Destroy()
			end

			v13:SetAttribute("ui0_xT", nil)
		end

		unskinClose(pathFind(window, "MainSongListUI", "Header", "CloseButton"))
		local newbieModeButton = window:FindFirstChild("NewbieModeButton", true)

		if newbieModeButton and newbieModeButton:GetAttribute("ui0_xW") ~= nil then
			newbieModeButton.Size = newbieModeButton:GetAttribute("ui0_xW")
			newbieModeButton:SetAttribute("ui0_xW", nil)
		end

		removeBoltsFrom(window:FindFirstChild("NewbieModeButton", true))
	end

	local newbieModePanel = folder:FindFirstChild("NewbieModePanel")

	if newbieModePanel then
		unskinClose(newbieModePanel:FindFirstChild("CloseButton"))
		removeBoltsFrom(findDifficultyTitle(newbieModePanel))
	end
end

local function fitText(button)
	if not isTextClass(button) or button.TextScaled or button.TextWrapped or not button.Visible then -- inferred equivalent call
		return
	end

	if isInDecor(button) then
		return
	end

	local x = button.AbsoluteSize.X

	if x < 20 then
		return
	end

	if button:IsA("TextButton") and button.Font == Enum.Font.Oswald then
		local y = button.AbsoluteSize.Y

		if y >= 12 and y <= 36 then
			local textSize = math.max(math.min(15, (math.floor(y - 3))), (math.min(17, (math.floor(y * 0.55)))))

			if button.TextSize < textSize then
				button.TextSize = textSize
			end
		end
	end

	local count = 0

	while true do
		local x2 = button.TextBounds.X

		if not (x - 2 < x2 and button.TextSize > 10 and count < 6) then
			break
		end

		button.TextSize -= 1
		count += 1
	end
end

local function fitAll(folder)
	if v ~= "NewUI" then
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		fitText(descendant)
	end
end
local function parentWH(p)
	local parent = p.Parent

	if not (parent and parent:IsA("GuiObject")) then
		return
	end

	local v12 = parent.AbsoluteSize.X
	local v13 = parent.AbsoluteSize.Y

	if v12 == 0 or v13 == 0 then
		v12 = parent.Size.X.Offset
		v13 = parent.Size.Y.Offset
	end

	return parent, v12, v13
end

local v12 = {}

local function topGui(screenGui) -- 4 equivalent calls inferred from this helper
	while screenGui and not screenGui:IsA("ScreenGui") do
		screenGui = screenGui.Parent
	end

	return screenGui
end

local function isHeuristic(screenGui): boolean -- 2 equivalent calls inferred from this helper
	while screenGui and not screenGui:IsA("ScreenGui") do
		screenGui = screenGui.Parent
	end

	return screenGui ~= nil and v12[screenGui] == true
end

local v13 = {
	red = Color3.fromRGB(214, 96, 84),
	amber = Colors.Accent,
	green = Color3.fromRGB(100, 196, 130),
	slate = Color3.fromRGB(150, 164, 172)
}

local v14 = {
	red = Colors.Danger,
	amber = Colors.Accent,
	green = Colors.Success,
	slate = Color3.fromRGB(96, 108, 116)
}

local function kbColor(p, p2)
	local hsv, v15, v16 = p:ToHSV()

	if v15 > 0.3 and v16 > 0.28 then
		if hsv > 0.55 and hsv < 0.68 then
			return p2 == "text" and Color3.fromRGB(236, 150, 96) or Color3.fromRGB(176, 86, 40)
		end

		if hsv >= 0.68 and hsv <= 0.86 then
			return p2 == "text" and Color3.fromRGB(192, 164, 214) or Color3.fromRGB(80, 58, 94)
		end

		if hsv > 0.19 and hsv < 0.47 then
			return p2 == "text" and Colors.Accent or Colors.Accent
		end

		return nil
	elseif p2 == "text" then
		if v16 > 0.95 then
			return Color3.fromRGB(226, 224, 218)
		end

		if v16 > 0.88 then
			return Color3.fromRGB(212, 210, 204)
		end

		if v16 > 0.64 then
			return Color3.fromRGB(170, 168, 160)
		end

		if v16 > 0.56 then
			return Color3.fromRGB(150, 148, 140)
		end

		if v16 > 0.45 then
			return Color3.fromRGB(128, 126, 118)
		end

		return Color3.fromRGB(98, 96, 90)
	elseif p2 == "stroke" then
		if v16 > 0.45 then
			return Color3.fromRGB(96, 94, 88)
		end

		if v16 > 0.32 then
			return Color3.fromRGB(52, 50, 46)
		end

		return Color3.fromRGB(8, 8, 8)
	else
		if v16 > 0.88 then
			return Color3.fromRGB(212, 210, 204)
		end

		if v16 > 0.7 then
			return Color3.fromRGB(150, 148, 140)
		end

		if v16 > 0.45 then
			return Color3.fromRGB(104, 102, 95)
		end

		if v16 > 0.32 then
			return Color3.fromRGB(74, 72, 67)
		end

		if v16 > 0.21 then
			return Color3.fromRGB(54, 53, 49)
		end

		if v16 > 0.16 then
			return Color3.fromRGB(31, 31, 29)
		end

		if v16 > 0.13 then
			return Color3.fromRGB(20, 20, 19)
		end

		return Color3.fromRGB(14, 14, 13)
	end
end

local function heurColor(p, p2, name)
	local v15 = name == "VirtualKeyboardUI" and kbColor(p, p2)

	if v15 then
		return v15
	end

	local hsv, v16, v17 = p:ToHSV()

	if v16 > 0.3 and v17 > 0.28 then
		local v18

		if hsv < 0.045 or hsv > 0.93 then
			v18 = "red"
		elseif hsv < 0.19 then
			v18 = "amber"
		else
			v18 = if hsv < 0.47 then "green" else "slate"
		end

		if p2 == "text" then
			return v13[v18]
		end

		return v14[v18]
	elseif p2 == "text" then
		if v17 > 0.78 then
			return Colors.TextPrimary
		end

		if v17 > 0.42 then
			return Colors.TextSecondary
		end

		return Color3.fromRGB(28, 24, 20)
	elseif p2 == "stroke" then
		if v17 > 0.55 then
			return Colors.BorderHover
		end

		if v17 > 0.25 then
			return Colors.Border
		end

		return Grunge.WindowStroke
	else
		if v17 > 0.8 then
			return Colors.TextPrimary
		end

		if v17 > 0.52 then
			return Color3.fromRGB(150, 148, 140)
		end

		if v17 > 0.3 then
			return Color3.fromRGB(70, 68, 64)
		end

		if v17 > 0.17 then
			return Colors.SurfaceHover
		end

		if v17 > 0.09 then
			return Colors.Background
		end

		return Colors.Surface
	end
end

local function heurProp(instance, p, p2, p3)
	if p == "BackgroundColor3" and instance:GetAttribute("ui0_card") then
		return
	end

	local v15 = instance[p]
	local attribute = instance:GetAttribute("ui0_h_" .. p3 .. "m")

	if attribute ~= nil and v15 == attribute then
		return
	end

	instance:SetAttribute("ui0_h_" .. p3, v15)
	local v16 = topGui(instance) -- inferred equivalent call
	local v17 = heurColor(v15, p2, v16 and v16.Name)
	instance:SetAttribute("ui0_h_" .. p3 .. "m", v17)
	instance[p] = v17
end

local function heurRecolor(instance)
	if instance:IsA("GuiObject") then
		heurProp(instance, "BackgroundColor3", "bg", "bg")

		if isTextClass(instance) then -- inferred equivalent call
			local textColor3 = instance.TextColor3
			local ui0_h_txm = instance:GetAttribute("ui0_h_txm")

			if ui0_h_txm ~= nil and textColor3 == ui0_h_txm then
				return
			end

			instance:SetAttribute("ui0_h_tx", textColor3)
			local v15 = topGui(instance) -- inferred equivalent call
			local textColor = (v15 and v15.Name) == "VirtualKeyboardUI" and kbColor(textColor3, "text")

			if not textColor then
				local hsv, v16, v17 = textColor3:ToHSV()

				if v16 > 0.3 and v17 > 0.28 then
					textColor = v13[(hsv < 0.045 or hsv > 0.93) and "red" or hsv < 0.19 and "amber" or hsv < 0.47 and "green" or "slate"]
				elseif v17 > 0.78 then
					textColor = Colors.TextPrimary
				elseif v17 > 0.42 then
					textColor = Colors.TextSecondary
				else
					textColor = Color3.fromRGB(28, 24, 20)
				end
			end

			instance:SetAttribute("ui0_h_txm", textColor)
			instance.TextColor3 = textColor
		end
	elseif instance:IsA("UIStroke") then
		local color2 = instance.Color
		local ui0_h_stm = instance:GetAttribute("ui0_h_stm")

		if ui0_h_stm ~= nil and color2 == ui0_h_stm then
			return
		end

		instance:SetAttribute("ui0_h_st", color2)
		local v15 = topGui(instance) -- inferred equivalent call
		local color3 = (v15 and v15.Name) == "VirtualKeyboardUI" and kbColor(color2, "stroke")

		if not color3 then
			local hsv, v16, v17 = color2:ToHSV()

			if v16 > 0.3 and v17 > 0.28 then
				color3 = v14[(hsv < 0.045 or hsv > 0.93) and "red" or hsv < 0.19 and "amber" or hsv < 0.47 and "green" or "slate"]
			elseif v17 > 0.55 then
				color3 = Colors.BorderHover
			elseif v17 > 0.25 then
				color3 = Colors.Border
			else
				color3 = Grunge.WindowStroke
			end
		end

		instance:SetAttribute("ui0_h_stm", color3)
		instance.Color = color3
	end
end

local function heurRestore(attributes)
	for _, v15 in ipairs({
		{ "bg", "BackgroundColor3" },
		{ "tx", "TextColor3" },
		{ "st", "Color" }
	}) do
		local attribute = attributes:GetAttribute("ui0_h_" .. v15[1])

		if attribute == nil then
			continue
		end

		attributes[v15[2]] = attribute
		attributes:SetAttribute("ui0_h_" .. v15[1], nil)
		attributes:SetAttribute("ui0_h_" .. v15[1] .. "m", nil)
	end
end

local function hookHeur(instance)
	if instance:GetAttribute("ui0_hk") or not (instance:IsA("GuiObject") or instance:IsA("UIStroke")) then
		return
	end

	instance:SetAttribute("ui0_hk", true)
	local function again()
		if v == "NewUI" then
			heurRecolor(instance)
		end
	end

	if instance:IsA("GuiObject") then
		instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(again)

		if isTextClass(instance) then -- inferred equivalent call
			instance:GetPropertyChangedSignal("TextColor3"):Connect(again)
		end
	else
		instance:GetPropertyChangedSignal("Color"):Connect(again)
	end
end

local _ = {
	cream = Grunge.Tape,
	gray = Color3.fromRGB(150, 142, 122),
	dark = Grunge.TapeDark,
	red = Color3.fromRGB(178, 62, 54),
	amber = Color3.fromRGB(214, 170, 80),
	green = Color3.fromRGB(96, 150, 104)
}

local v15 = {
	LoadingToast = { v = 1, tape = "cream", plate = "paper" },
	InviteResponseBar = { v = 4, tape = "cream", stroke = Colors.Success, plate = "paper" },
	RoomHudIndicator = { v = 3, tape = "gray", plate = "metal" },
	ThemeSwitchToast = { v = 3, tape = "cream", plate = "paper" },
	HighPingToast = { v = 5, tape = "red", stroke = Colors.Danger, plate = "metal" },
	Notice = { v = 2, tape = "amber", stroke = Color3.fromRGB(214, 140, 48), plate = "metal" },
	VoteBar = { v = 4, tape = "amber", stroke = Colors.Accent, plate = "paper" },
	Pill = { v = 2, tape = "red", stroke = Colors.Danger, plate = "metal" }
}

local v16 = { "cream", "gray", "amber", "dark", "green" }

local function nameHash(value)
	local v17 = 0

	for i = 1, #value do
		v17 = (v17 * 31 + value:byte(i)) % 997
	end

	return v17
end

local function isOverlaySized(instance): boolean -- 1 equivalent call inferred from this helper
	local size = instance.Size
	return size.X.Scale >= 0.9 and size.Y.Scale >= 0.9
end

local v17 = {
	SongListToastGui = true,
	RoomHudGui = true,
	HighPingWarningToastGui = true,
	ThemeSwitchToastGui = true,
	JoinSessionToastGui = true,
	LaptopVoteToastGui = true,
	ChartUnavailableNotice = true,
	AmpNoticeUI = true,
	AfkUnequipToastGui = true,
	PutBackConfirmUI = true,
	ServerRestartAlertGui = true,
	SettingsMenuUI = { ThemeSwitchToast = true },
	EquipmentUI = { ThemeSwitchToast = true }
}

local function isCardCandidate(instance, instance2)
	local v18 = v17[instance2.Name]

	if not v18 or v18 ~= true and not v18[instance.Name] or (not instance:IsA("GuiObject") or isInDecor(instance)) then
		return false
	end

	if not (instance:IsA("Frame") or instance:IsA("CanvasGroup") or instance:IsA("TextLabel") or instance:IsA("TextButton")) then
		return false
	end

	if instance.BackgroundTransparency >= 0.95 then
		return false
	end

	if isOverlaySized(instance) then -- inferred equivalent call
		return false
	end

	local y = instance.Size.Y

	if y.Scale == 0 and y.Offset > 0 and y.Offset < 14 then
		return false
	end

	local parent = instance.Parent

	if parent == instance2 then
		return true
	end

	local v19

	if parent == nil then
		return false
	end

	v19 = parent:IsA("GuiObject")

	if v19 then
		if parent.BackgroundTransparency >= 0.95 then
			return parent.Parent == instance2
		end

		return false
	end

	return v19
end

local v18 = {}

local v19 = {
	metal = {
		bg = Color3.fromRGB(62, 60, 55),
		hi = Color3.fromRGB(128, 124, 114),
		rivet = Color3.fromRGB(122, 116, 104),
		corner = 1
	},
	paper = {
		bg = Color3.fromRGB(56, 50, 42),
		hi = Color3.fromRGB(140, 132, 114),
		rivet = Color3.fromRGB(110, 78, 48),
		corner = 0
	}
}

local function jitter(data, object, p)
	local integer = object:NextInteger(-p, p)
	return Color3.fromRGB(
		math.clamp(data.R * 255 + integer, 0, 255),
		math.clamp(data.G * 255 + integer, 0, 255),
		(math.clamp(data.B * 255 + integer, 0, 255))
	)
end

local function cardSizeGuess(canvasGroup) -- 1 equivalent call inferred from this helper
	local v20 = canvasGroup.AbsoluteSize.Y

	if v20 <= 0 then
		v20 = canvasGroup.Size.Y.Offset
	end

	local v21 = v20 <= 0 and 36 or v20
	local v22 = canvasGroup.AbsoluteSize.X

	if v22 <= 0 then
		v22 = canvasGroup.Size.X.Offset
	end

	return v22 <= 0 and 220 or v22, v21
end

local function buildFollowerContent(parent, p, p2, p3, p4)
	local random = Random.new(nameHash(p2) + 17)
	local v20 = v19[p.plate] or v19.metal
	local v21 = math.clamp(p4 / 56, 0.45, 1)
	local v22 = p4 < 40

	local function add(className, items, p5) -- 1 equivalent call inferred from this helper
		local guiObject = mk(className, items, p5 or parent) -- inferred equivalent call

		if guiObject:IsA("GuiObject") and items.BackgroundTransparency then
			guiObject:SetAttribute("ui0_bt", items.BackgroundTransparency)
		end

		return guiObject
	end

	local function rect(name, position, size, backgroundColor, backgroundTransparency, value, p5)
		return add("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size,
			Rotation = value or 0,
			AnchorPoint = p5 or Vector2.new(0, 0)
		})
	end

	local function edge(p5, udim, udim2, rotation, p6)
		local parent2 = rect(p5, udim, udim2, Color3.new(0, 0, 0), 0, 0)
		parent2:SetAttribute("ui0_bt", 0.5)
		mk("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p6), NumberSequenceKeypoint.new(1, 1) })
		}, parent2)
	end
	edge("EdgeT", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 8), 90, 0.45)
	edge("EdgeB", UDim2.new(0, 0, 1, -8), UDim2.new(1, 0, 0, 8), 270, 0.4)
	edge("EdgeL", UDim2.new(0, 0, 0, 0), UDim2.new(0, 8, 1, 0), 0, 0.5)
	edge("EdgeR", UDim2.new(1, -8, 0, 0), UDim2.new(0, 8, 1, 0), 180, 0.5)

	for i = 1, v22 and 1 or 3 do
		local v23 = math.floor(random:NextInteger(16, 44) * v21)
		local parent2 = rect(
			"Stain" .. i,
			UDim2.fromScale(random:NextNumber() * 0.85, random:NextNumber() * 0.6),
			UDim2.fromOffset(v23, (math.floor(v23 * 0.6))),
			i == 2 and p.plate == "metal" and Grunge.Rust or Color3.new(0, 0, 0),
			0.78 + random:NextNumber() * 0.08,
			0
		)
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	for i = 1, v22 and 1 or 3 do
		rect(
			"Scratch" .. i,
			UDim2.fromScale(random:NextNumber() * 0.7, random:NextNumber()),
			UDim2.fromOffset(math.floor(random:NextInteger(14, 42) * v21 + 6), 1),
			Colors.TextPrimary,
			0.8 + random:NextNumber() * 0.08,
			random:NextInteger(-35, 35)
		)
	end

	for i = 1, math.clamp(math.floor(p3 * p4 / 240), 6, 26) do
		local v23 = random:NextNumber() > 0.4
		local integer = random:NextInteger(1, 2)
		rect(
			"Speck" .. i,
			UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			UDim2.fromOffset(integer, integer),
			v23 and Colors.TextPrimary or Color3.new(0, 0, 0),
			v23 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			0
		)
	end

	if p.plate == "metal" then
		rect("BevelTop", UDim2.new(0, 2, 0, 1), UDim2.new(1, -4, 0, 1), v20.hi, 0.45, 0)
		rect("BevelBottom", UDim2.new(0, 2, 1, -2), UDim2.new(1, -4, 0, 1), Color3.new(0, 0, 0), 0.4, 0)

		for i = 1, 5 do
			rect(
				"Brush" .. i,
				UDim2.new(random:NextNumber() * 0.4, 0, random:NextNumber(), 0),
				UDim2.new(0.25 + random:NextNumber() * 0.4, 0, 0, 1),
				Colors.TextPrimary,
				0.93 + random:NextNumber() * 0.04,
				0
			)
		end
	else
		for i = 1, v22 and 4 or 8 do
			rect(
				"Fiber" .. i,
				UDim2.fromScale(random:NextNumber(), random:NextNumber()),
				UDim2.fromOffset(random:NextInteger(1, 2), random:NextInteger(3, 6)),
				v20.hi,
				0.82 + random:NextNumber() * 0.1,
				random:NextInteger(-60, 60)
			)
		end

		if not v22 then
			local v23 = math.floor(random:NextInteger(22, 36) * v21) + 8
			local parent2 = mk("Frame", { -- inferred equivalent call
				Name = "RingStain",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Active = false,
				Position = UDim2.fromScale(0.1 + random:NextNumber() * 0.6, 0.05 + random:NextNumber() * 0.4),
				Size = UDim2.fromOffset(v23, v23)
			}, parent)

			mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
			mk("UIStroke", { Color = v20.rivet, Thickness = 1.5, Transparency = 0.6 }, parent2) -- inferred equivalent call
			local v24 = math.floor(v21 * 16) + 6
			rect(
				"FoldShadow",
				UDim2.new(1, -v24 * 0.5 + 1, 1, -v24 * 0.5 + 1),
				UDim2.fromOffset(v24, v24),
				Color3.new(0, 0, 0),
				0.5,
				45,
				Vector2.new(0.5, 0.5)
			)
			rect(
				"Fold",
				UDim2.new(1, -v24 * 0.5, 1, -v24 * 0.5),
				UDim2.fromOffset(v24, v24),
				v20.hi,
				0.2,
				45,
				Vector2.new(0.5, 0.5)
			)

			for i = 1, math.clamp(math.floor(p3 / 9), 8, 34) do
				local integer = random:NextInteger(5, 11)
				rect(
					"TearB" .. i,
					UDim2.new(random:NextNumber(), 0, 1, random:NextInteger(-1, 2)),
					UDim2.fromOffset(integer, integer),
					v20.bg,
					0,
					random:NextInteger(20, 70),
					Vector2.new(0.5, 0.5)
				)

				if i % 3 == 0 then
					rect(
						"TearT" .. i,
						UDim2.new(random:NextNumber(), 0, 0, random:NextInteger(-1, 1)),
						UDim2.fromOffset(integer - 1, integer - 1),
						v20.bg,
						0,
						random:NextInteger(20, 70),
						Vector2.new(0.5, 0.5)
					)
				end
			end
		end
	end

	for i, v23 in ipairs(v22 and {
		{ 0, 0.5, 5, 0 },
		{ 1, 0.5, -5, 0 }
	} or {
		{ 0, 0, 6, 6 },
		{ 1, 0, -6, 6 },
		{ 0, 1, 6, -6 },
		{ 1, 1, -6, -6 }
	}) do
		local parent2 = rect(
			"Screw" .. i,
			UDim2.new(v23[1], v23[3], v23[2], v23[4]),
			UDim2.fromOffset(7, 7),
			v20.rivet,
			0,
			0,
			Vector2.new(0.5, 0.5)
		)
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
		mk("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5, Transparency = 0.2 }, parent2) -- inferred equivalent call
		rect(
			"ScrewSlot" .. i,
			UDim2.new(v23[1], v23[3], v23[2], v23[4]),
			UDim2.fromOffset(5, 1),
			Color3.new(0, 0, 0),
			0.15,
			random:NextInteger(-70, 70),
			Vector2.new(0.5, 0.5)
		)
		rect(
			"ScrewGlint" .. i,
			UDim2.new(v23[1], v23[3] - 1, v23[2], v23[4] - 2),
			UDim2.fromOffset(2, 1),
			Colors.TextPrimary,
			0.3,
			0,
			Vector2.new(0.5, 0.5)
		)
	end
end

local function removeFollower(p)
	local v20 = v18[p]

	if not v20 then
		return
	end

	for _, conn in ipairs(v20.conns) do
		conn:Disconnect()
	end

	if v20.layer then
		v20.layer:Destroy()
	end

	v18[p] = nil
end

local function makeFollower(canvasGroup, p)
	local parent = topGui(canvasGroup) -- inferred equivalent call

	if not parent then
		return
	end

	local v20, v21 = cardSizeGuess(canvasGroup) -- inferred equivalent call
	local folder = mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorFollow",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = canvasGroup.ZIndex + 10,
		Visible = false
	}, parent)
	buildFollowerContent(folder, p, canvasGroup.Name, v20, v21)
	local connections = {}
	v18[canvasGroup] = { layer = folder, conns = connections }
	local v22 = -1
	local function sync()
		if not (canvasGroup.Parent and folder.Parent) then
			return
		end

		local groupTransparency = canvasGroup:IsA("CanvasGroup") and canvasGroup.GroupTransparency or 0
		local visible = canvasGroup.Visible

		if visible then
			if groupTransparency < 0.99 then
				visible = canvasGroup:IsDescendantOf(parent)
			else
				visible = false
			end
		end

		folder.Visible = visible
		local absolutePosition = canvasGroup.AbsolutePosition
		local absoluteSize = canvasGroup.AbsoluteSize
		local absolutePosition2 = parent.AbsolutePosition
		folder.Position = UDim2.fromOffset(
			absolutePosition.X - absolutePosition2.X,
			absolutePosition.Y - absolutePosition2.Y
		)
		folder.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		folder.Rotation = canvasGroup.Rotation

		if groupTransparency ~= v22 then
			v22 = groupTransparency

			if groupTransparency > 0 then
				for _, guiObject in ipairs(folder:GetDescendants()) do
					local ui0_bt = guiObject:IsA("GuiObject") and guiObject:GetAttribute("ui0_bt")

					if ui0_bt then
						guiObject.BackgroundTransparency = 1 - (1 - ui0_bt) * (1 - groupTransparency)
					end
				end
			end
		end
	end

	for _, propertyName in ipairs({ "AbsolutePosition", "AbsoluteSize", "Visible", "Rotation" }) do
		table.insert(connections, canvasGroup:GetPropertyChangedSignal(propertyName):Connect(sync))
	end

	if canvasGroup:IsA("CanvasGroup") then
		table.insert(connections, canvasGroup:GetPropertyChangedSignal("GroupTransparency"):Connect(sync))
	end

	table.insert(connections, canvasGroup.AncestryChanged:Connect(function()
		if not canvasGroup:IsDescendantOf(parent) then
			removeFollower(canvasGroup)
		end
	end))
	sync()
end

local function decorateCard(folder)
	if folder:GetAttribute("ui0_card") then
		return
	end

	folder:SetAttribute("ui0_card", true)
	local v20 = nameHash(folder.Name)
	local v21 = v15[folder.Name] or {
		v = 1 + v20 % 5,
		tape = v16[1 + v20 % #v16]
	}
	local v22 = {
		v = v21.v,
		tape = v21.tape,
		stroke = v21.stroke,
		plate = v21.plate or v20 % 2 == 0 and "metal" or "paper"
	}

	local v23 = v19[v22.plate]
	local random = Random.new(v20 + 3)

	folder:SetAttribute("ui0_cBg", folder.BackgroundColor3)
	folder:SetAttribute("ui0_cT", folder.BackgroundTransparency)
	folder.BackgroundColor3 = v23.bg
	folder.BackgroundTransparency = math.min(folder.BackgroundTransparency, 0.02)
	mk("UIGradient", { -- inferred equivalent call
		Name = "NewUIDecorGrad",
		Rotation = random:NextInteger(0, 180),
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(215, 214, 208)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 158, 150))
		})
	}, folder)

	local v24 = folder:FindFirstChildOfClass("UIStroke")

	if v24 and v24.Name:sub(1, 10) ~= "NewUIDecor" then
		folder:SetAttribute("ui0_cStT", v24.Thickness)
		folder:SetAttribute("ui0_cStC", v24.Color)
	elseif not v24 then
		local v25 = { Name = "NewUIDecorStroke", ApplyStrokeMode = Enum.ApplyStrokeMode.Border }
		v24 = Instance.new("UIStroke")

		for k, v26 in pairs(v25) do
			v24[k] = v26
		end

		v24.Parent = folder
	end

	v24.Thickness = 2
	v24.Color = v22.stroke or Grunge.WindowStroke
	mk("UIGradient", { -- inferred equivalent call
		Name = "NewUIDecorWear",
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0.15),
			NumberSequenceKeypoint.new(0.33, 0.85),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.72, 0.7),
			NumberSequenceKeypoint.new(0.88, 0.1),
			NumberSequenceKeypoint.new(1, 0)
		}),
		Rotation = random:NextInteger(0, 90)
	}, v24)

	local uiCorner = folder:FindFirstChildOfClass("UICorner")

	if uiCorner then
		folder:SetAttribute("ui0_cCr", uiCorner.CornerRadius)
		uiCorner.CornerRadius = UDim.new(0, v23.corner)
	end

	if v22.plate == "paper" then
		folder:SetAttribute("ui0_cRot", folder.Rotation)
		folder.Rotation = (random:NextNumber() - 0.5) * 1.2
	end

	makeFollower(folder, v22)

	folder:GetPropertyChangedSignal("Visible"):Connect(function()
		if folder.Visible and v == "NewUI" then
			task.delay(0.15, function()
				if v ~= "NewUI" or not folder.Parent then
					return
				end

				fitText(folder)

				for _, descendant in ipairs(folder:GetDescendants()) do
					fitText(descendant)
				end
			end)
		end
	end)
end

local function undecorateCard(guiObject)
	if not guiObject:GetAttribute("ui0_card") then
		return
	end

	removeFollower(guiObject)
	local newUIDecorGrad = guiObject:FindFirstChild("NewUIDecorGrad")

	if newUIDecorGrad then
		newUIDecorGrad:Destroy()
	end

	local uiStroke = guiObject:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		local newUIDecorWear = uiStroke:FindFirstChild("NewUIDecorWear")

		if newUIDecorWear then
			newUIDecorWear:Destroy()
		end

		local ui0_cStT = guiObject:GetAttribute("ui0_cStT")
		local ui0_cStC = guiObject:GetAttribute("ui0_cStC")

		if ui0_cStT then
			uiStroke.Thickness = ui0_cStT
		end

		if ui0_cStC then
			uiStroke.Color = ui0_cStC
		end
	end

	local ui0_cBg = guiObject:GetAttribute("ui0_cBg")
	local ui0_cT = guiObject:GetAttribute("ui0_cT")

	if ui0_cBg then
		guiObject.BackgroundColor3 = ui0_cBg
	end

	if ui0_cT ~= nil then
		guiObject.BackgroundTransparency = ui0_cT
	end

	local uiCorner = guiObject:FindFirstChildOfClass("UICorner")
	local ui0_cCr = guiObject:GetAttribute("ui0_cCr")

	if uiCorner and ui0_cCr then
		uiCorner.CornerRadius = ui0_cCr
	end

	local ui0_cRot = guiObject:GetAttribute("ui0_cRot")

	if ui0_cRot ~= nil then
		guiObject.Rotation = ui0_cRot
	end

	for _, v20 in ipairs({
		"ui0_card",
		"ui0_cT",
		"ui0_cBg",
		"ui0_cStT",
		"ui0_cStC",
		"ui0_cCr",
		"ui0_cRot"
	}) do
		guiObject:SetAttribute(v20, nil)
	end
end

local function decorateCards(folder)
	for _, guiObject in ipairs(folder:GetChildren()) do
		if isCardCandidate(guiObject, folder) then
			decorateCard(guiObject)
		elseif guiObject:IsA("GuiObject") and guiObject.BackgroundTransparency >= 0.95 then
			for _, child in ipairs(guiObject:GetChildren()) do
				if isCardCandidate(child, folder) then
					decorateCard(child)
				end
			end
		end
	end
end

local function undecorateCards(folder)
	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("GuiObject") and guiObject:GetAttribute("ui0_card") then
			undecorateCard(guiObject)
		end
	end

	for _, child in ipairs(folder:GetChildren()) do
		if child.Name == "NewUIDecorFollow" then
			child:Destroy()
		end
	end
end

local v20 = nil

local function removeAmpFollower()
	if not v20 then
		return
	end

	for _, conn in ipairs(v20.conns) do
		conn:Disconnect()
	end

	if v20.layer then
		v20.layer:Destroy()
	end

	v20 = nil
end

local function ampStroke(parent, color2, thickness, value)
	local v21 = parent:FindFirstChild("NewUIDecorAmpStroke") or parent:FindFirstChild("NewUIDecorStroke")

	if not v21 then
		local v22 = { Name = "NewUIDecorAmpStroke", ApplyStrokeMode = Enum.ApplyStrokeMode.Border }
		v21 = Instance.new("UIStroke")

		for k, v23 in pairs(v22) do
			v21[k] = v23
		end

		v21.Parent = parent
	end

	v21.Color = color2
	v21.Thickness = thickness
	v21.Transparency = value or 0
	return v21
end

local function ampCorner(instance, p)
	local uiCorner = instance:FindFirstChildOfClass("UICorner")

	if not uiCorner then
		return
	end

	if uiCorner:GetAttribute("ui0_aCr") == nil then
		uiCorner:SetAttribute("ui0_aCr", uiCorner.CornerRadius)
	end

	uiCorner.CornerRadius = UDim.new(0, p)
end

local function buildAmpPanelDecor(parent, x, y, instance)
	buildFollowerContent(parent, { plate = "metal" }, "AmpSettingsPanel", x, y)
	local random = Random.new(4242)
	local function rect(name, position, size, backgroundColor, backgroundTransparency, value) -- 2 equivalent calls inferred from this helper
		local frame = Instance.new("Frame")

		for k, v21 in pairs({
			Name = name,
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size,
			Rotation = value or 0
		}) do
			frame[k] = v21
		end

		frame.Parent = parent
		return frame
	end

	for i = 1, 6 do
		local integer = random:NextInteger(60, 150)
		local name = "AmpStain" .. i
		local udim = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.8)
		local udim2 = UDim2.fromOffset(integer, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = i % 3 == 0 and Grunge.Rust or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.9 + random:NextNumber() * 0.05,
			BorderSizePixel = 0,
			Active = false,
			Position = udim,
			Size = udim2,
			Rotation = 0
		}, parent)
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	for i = 1, 5 do
		local name = "AmpScratch" .. i
		local udim = UDim2.fromScale(random:NextNumber() * 0.7, random:NextNumber())
		local udim2 = UDim2.fromOffset(random:NextInteger(60, 160), 1)
		mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = Colors.TextPrimary,
			BackgroundTransparency = 0.93 + random:NextNumber() * 0.03,
			BorderSizePixel = 0,
			Active = false,
			Position = udim,
			Size = udim2,
			Rotation = random:NextInteger(-35, 35) or 0
		}, parent)
	end

	for i = 1, 40 do
		local v21 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 3)
		rect( -- inferred equivalent call
			"AmpSpeck" .. i,
			UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			UDim2.fromOffset(integer, integer),
			v21 and Colors.TextPrimary or Color3.new(0, 0, 0),
			v21 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25
		)
	end

	local udim = UDim2.new(0, 3, 0, 3)
	local udim2 = UDim2.new(1, -6, 1, -6)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "AmpEdgeWear",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = udim,
		Size = udim2,
		Rotation = 0
	}, parent)
	mk("UIStroke", { Color = Grunge.EdgeWear, Thickness = 1.5, Transparency = 0.55 }, parent2) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent2) -- inferred equivalent call

	local function tape(name, position, size, value, backgroundColor, backgroundTransparency)
		local frame = rect(name, position, size, backgroundColor, backgroundTransparency, value) -- inferred equivalent call
		frame.ZIndex = 3
		return frame
	end

	local udim3 = UDim2.new(0, -20, 0, -4)
	local udim4 = UDim2.new(0, 52, 0, 12)
	local frame = mk("Frame", { -- inferred equivalent call
		Name = "AmpTapeTL",
		BackgroundColor3 = Grunge.Tape,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Active = false,
		Position = udim3,
		Size = udim4,
		Rotation = -40
	}, parent)
	frame.ZIndex = 3

	local udim5 = UDim2.new(1, -36, 1, -16)
	local udim6 = UDim2.new(0, 50, 0, 12)
	local frame2 = mk("Frame", { -- inferred equivalent call
		Name = "AmpTapeBR",
		BackgroundColor3 = Grunge.Tape,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Active = false,
		Position = udim5,
		Size = udim6,
		Rotation = -40
	}, parent)
	frame2.ZIndex = 3

	local udim7 = UDim2.new(0, -14, 1, -18)
	local udim8 = UDim2.new(0, 40, 0, 11)
	local frame3 = mk("Frame", { -- inferred equivalent call
		Name = "AmpTapeBL",
		BackgroundColor3 = Grunge.TapeDark,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Active = false,
		Position = udim7,
		Size = udim8,
		Rotation = 36
	}, parent)
	frame3.ZIndex = 3

	local mastervolumeSection = instance:FindFirstChild("MASTER VOLUMESection", true)

	if mastervolumeSection and mastervolumeSection.AbsoluteSize.X > 0 then
		local absolutePosition = instance.AbsolutePosition
		local v21 = mastervolumeSection.AbsolutePosition.X - absolutePosition.X - 18
		local v22 = absolutePosition.X + instance.AbsoluteSize.X - (mastervolumeSection.AbsolutePosition.X + mastervolumeSection.AbsoluteSize.X) - 18
		local v23 = mastervolumeSection.AbsolutePosition.Y - absolutePosition.Y
		local y2 = mastervolumeSection.AbsoluteSize.Y

		if v21 >= 110 then
			mk("TextLabel", { -- inferred equivalent call
				Name = "AmpScrawl",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(18 + v21 / 2, v23 + y2 * 0.5),
				Size = UDim2.fromOffset(v21 - 8, 60),
				Rotation = -8,
				Font = Enum.Font.PermanentMarker,
				Text = "TURN\nIT UP!",
				TextSize = 22,
				TextColor3 = StyledTheme.Amp.ACCENT,
				TextTransparency = 0.25,
				TextXAlignment = Enum.TextXAlignment.Center
			}, parent)
		end

		if v22 >= 90 then
			local parent3 = mk("Frame", { -- inferred equivalent call
				Name = "AmpTally",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(instance.AbsoluteSize.X - 18 - v22 / 2, v23 + y2 * 0.5),
				Size = UDim2.fromOffset(60, 44),
				Rotation = 6
			}, parent)

			for i = 0, 3 do
				mk("Frame", { -- inferred equivalent call
					Name = "Bar" .. i,
					BackgroundColor3 = Colors.TextPrimary,
					BackgroundTransparency = 0.45,
					BorderSizePixel = 0,
					Active = false,
					Position = UDim2.fromOffset(i * 12 + 8, 3 + random:NextInteger(-1, 1)),
					Size = UDim2.fromOffset(3, 38),
					Rotation = random:NextInteger(-3, 3)
				}, parent3)
			end

			mk("Frame", { -- inferred equivalent call
				Name = "Strike",
				BackgroundColor3 = Colors.TextPrimary,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(30, 22),
				Size = UDim2.fromOffset(66, 3),
				Rotation = -52
			}, parent3)
		end
	end
end

local function makeAmpFollower(instance, panel)
	removeAmpFollower()
	local layer = mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorFollow",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = panel.ZIndex + 10,
		Visible = false
	}, instance)
	local v21 = { layer = layer, conns = {}, built = false }
	v20 = v21
	local function sync()
		if not (panel.Parent and layer.Parent) then
			return
		end

		local absoluteSize = panel.AbsoluteSize
		local absolutePosition = panel.AbsolutePosition
		local absolutePosition2 = instance.AbsolutePosition
		layer.Visible = instance.Enabled and panel.Visible and absoluteSize.X > 0
		layer.Position = UDim2.fromOffset(
			absolutePosition.X - absolutePosition2.X,
			absolutePosition.Y - absolutePosition2.Y
		)
		layer.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)

		if layer.Visible and not v21.built and absoluteSize.X > 50 and absoluteSize.Y > 50 then
			v21.built = true
			task.delay(0.15, function()
				if v20 == v21 and layer.Parent and panel.AbsoluteSize.X > 50 then
					buildAmpPanelDecor(layer, panel.AbsoluteSize.X, panel.AbsoluteSize.Y, panel)
				end
			end)
		end
	end

	for _, propertyName in ipairs({ "AbsolutePosition", "AbsoluteSize", "Visible" }) do
		table.insert(v21.conns, panel:GetPropertyChangedSignal(propertyName):Connect(sync))
	end

	table.insert(v21.conns, instance:GetPropertyChangedSignal("Enabled"):Connect(sync))
	sync()
end

fn = function(instance)
	local panel = instance:FindFirstChild("Panel")

	if not panel then
		return
	end

	if not panel:GetAttribute("ui0_aPanel") then
		panel:SetAttribute("ui0_aPanel", true)
		panel:SetAttribute("ui0_aPBg", panel.BackgroundTransparency)
		panel:SetAttribute("ui0_aPClip", panel.ClipsDescendants)
		panel.BackgroundTransparency = 0.04
		panel.ClipsDescendants = false
		local uiStroke = panel:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			panel:SetAttribute("ui0_aPStT", uiStroke.Thickness)
			panel:SetAttribute("ui0_aPStC", uiStroke.Color)
			uiStroke.Thickness = 2
			uiStroke.Color = Grunge.WindowStroke
		end

		ampCorner(panel, 3)
	end

	local header = panel:FindFirstChild("Header")

	if header then
		if not header:FindFirstChild("NewUIDecorAmpScribble") then
			local parent = mk("Frame", { -- inferred equivalent call
				Name = "NewUIDecorAmpScribble",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Active = false,
				Size = UDim2.fromScale(1, 1)
			}, header)
			local accent = StyledTheme.Amp.ACCENT
			local function line(name, p, p2, p3, p4, rotation, backgroundTransparency)
				mk("Frame", { -- inferred equivalent call
					Name = name,
					BackgroundColor3 = accent,
					BackgroundTransparency = backgroundTransparency,
					BorderSizePixel = 0,
					Active = false,
					Position = UDim2.new(0, p, 0, p2),
					Size = UDim2.new(p3, 0, 0, p4),
					Rotation = rotation
				}, parent)
			end
			line("L1", 2, 27, 0.37, 2, -0.8, 0.3)
			line("L2", 36, 31, 0.26, 1.5, 0.9, 0.45)
		end

		skinResultsClose(header:FindFirstChild("CloseButton"))
		local swingToggle = header:FindFirstChild("SwingToggle")
		local track = swingToggle and swingToggle:FindFirstChild("Track")

		if track then
			ampStroke(track, Color3.new(0, 0, 0), 1.5, 0.2)
		end
	end

	local mastervolumeSection = panel:FindFirstChild("MASTER VOLUMESection", true)

	if mastervolumeSection then
		local track = mastervolumeSection:FindFirstChild("Track", true)

		if track then
			ampCorner(track, 2)
			ampStroke(track, Color3.new(0, 0, 0), 1, 0.4)
			local fill = track:FindFirstChild("Fill")

			if fill then
				ampCorner(fill, 2)
			end

			local thumb = track:FindFirstChild("Thumb")

			if thumb and thumb:GetAttribute("ui0_aT") == nil then
				thumb:SetAttribute("ui0_aT", true)
				thumb:SetAttribute("ui0_aTBg", thumb.BackgroundColor3)
				thumb:SetAttribute("ui0_aTSz", thumb.Size)
				thumb:SetAttribute("ui0_aTRot", thumb.Rotation)
				thumb.BackgroundColor3 = Grunge.Tape
				thumb.Size = UDim2.fromOffset(11, 24)
				thumb.Rotation = -8
				ampCorner(thumb, 1)
				ampStroke(thumb, Color3.new(0, 0, 0), 1.5, 0.35)
			end
		end

		for _, button in ipairs(mastervolumeSection:GetDescendants()) do
			if not button:IsA("TextButton") or not (button.Text == "-" or button.Text == "+") or isInDecor(button) then
				continue
			end

			ampCorner(button, 3)
			ampStroke(button, Colors.Border, 1, 0.25)
		end
	end

	for _, frame in ipairs(panel:GetDescendants()) do
		if
			not frame:IsA("Frame")
			or frame.Name:sub(-4) ~= "Chip"
			or (isInDecor(frame) or frame:FindFirstChild("NewUIDecorAmpTicks"))
		then
			continue
		end

		ampCorner(frame, 3)
		ampStroke(frame, Colors.Border, 1, 0.35)

		for _, label in ipairs(frame:GetChildren()) do
			if not label:IsA("TextLabel") or isInDecor(label) or not (label.TextSize > 12) then
				continue
			end

			label.TextSize = 12
		end

		local knobDial = frame:FindFirstChild("KnobDial")

		if knobDial then
			if knobDial:GetAttribute("ui0_aBg") == nil then
				knobDial:SetAttribute("ui0_aBg", knobDial.BackgroundColor3)
			end

			knobDial.BackgroundColor3 = Grunge.Metal
			ampStroke(knobDial, Grunge.EdgeWear, 1.5, 0.2)
			local parent = mk("Frame", { -- inferred equivalent call
				Name = "NewUIDecorAmpCap",
				BackgroundColor3 = Color3.fromRGB(16, 16, 15),
				BorderSizePixel = 0,
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(6, 6)
			}, knobDial)

			mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
		end

		local parent = mk("Frame", { -- inferred equivalent call
			Name = "NewUIDecorAmpTicks",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = false,
			Size = UDim2.fromScale(1, 1)
		}, frame)

		for i = 0, 6 do
			local v21 = math.rad(i * 45 + -135)
			mk("Frame", { -- inferred equivalent call
				Name = "Tick" .. i,
				BackgroundColor3 = Colors.TextSecondary,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, math.sin(v21) * 16, 0, 34 - math.cos(v21) * 16),
				Size = UDim2.fromOffset(2, 2)
			}, parent)
		end
	end

	for _, childName in ipairs({ "SavePresetButton", "LoadPresetButton", "ResetButton" }) do
		local child = panel:FindFirstChild(childName, true)

		if child then
			ampStroke(child, Colors.Border, 1, 0.2)
		end
	end

	local resetButton = panel:FindFirstChild("ResetButton", true)

	if resetButton and resetButton:GetAttribute("ui0_aRb") == nil then
		resetButton:SetAttribute("ui0_aRb", resetButton.BackgroundColor3)
		resetButton.BackgroundColor3 = Color3.fromRGB(52, 22, 20)
		ampStroke(resetButton, Colors.Danger, 1, 0.1)
	end

	makeAmpFollower(instance, panel)
end

fn2 = function(folder)
	removeAmpFollower()

	for _, child in ipairs(folder:GetChildren()) do
		if child.Name == "NewUIDecorFollow" then
			child:Destroy()
		end
	end

	local panel = folder:FindFirstChild("Panel")

	if not panel then
		return
	end

	local header = panel:FindFirstChild("Header")

	if header then
		unskinResultsClose(header:FindFirstChild("CloseButton"))
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name:sub(1, 13) == "NewUIDecorAmp" then
			descendant:Destroy()
		end
	end

	for _, uiCorner in ipairs(folder:GetDescendants()) do
		if uiCorner:IsA("UICorner") then
			local ui0_aCr = uiCorner:GetAttribute("ui0_aCr")

			if ui0_aCr ~= nil then
				uiCorner.CornerRadius = ui0_aCr
				uiCorner:SetAttribute("ui0_aCr", nil)
			end
		end

		local ui0_aBg = uiCorner:GetAttribute("ui0_aBg")

		if ui0_aBg ~= nil then
			uiCorner.BackgroundColor3 = ui0_aBg
			uiCorner:SetAttribute("ui0_aBg", nil)
		end

		local ui0_aRb = uiCorner:GetAttribute("ui0_aRb")

		if ui0_aRb ~= nil then
			uiCorner.BackgroundColor3 = ui0_aRb
			uiCorner:SetAttribute("ui0_aRb", nil)
		end

		if not uiCorner:GetAttribute("ui0_aT") then
			continue
		end

		uiCorner.BackgroundColor3 = uiCorner:GetAttribute("ui0_aTBg")
		uiCorner.Size = uiCorner:GetAttribute("ui0_aTSz")
		uiCorner.Rotation = uiCorner:GetAttribute("ui0_aTRot")

		for _, v21 in ipairs({ "ui0_aT", "ui0_aTBg", "ui0_aTSz", "ui0_aTRot" }) do
			uiCorner:SetAttribute(v21, nil)
		end
	end

	if panel:GetAttribute("ui0_aPanel") then
		local ui0_aPBg = panel:GetAttribute("ui0_aPBg")

		if ui0_aPBg ~= nil then
			panel.BackgroundTransparency = ui0_aPBg
		end

		local ui0_aPClip = panel:GetAttribute("ui0_aPClip")

		if ui0_aPClip ~= nil then
			panel.ClipsDescendants = ui0_aPClip
		end

		local uiStroke = panel:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			local ui0_aPStT = panel:GetAttribute("ui0_aPStT")
			local ui0_aPStC = panel:GetAttribute("ui0_aPStC")

			if ui0_aPStT then
				uiStroke.Thickness = ui0_aPStT
			end

			if ui0_aPStC then
				uiStroke.Color = ui0_aPStC
			end
		end

		for _, v21 in ipairs({ "ui0_aPanel", "ui0_aPBg", "ui0_aPClip", "ui0_aPStT", "ui0_aPStC" }) do
			panel:SetAttribute(v21, nil)
		end
	end
end

local connections = {}
local v21 = nil
local v22 = false

local function kbOpacity() -- 3 equivalent calls inferred from this helper
	local success, freePlayOpacity = pcall(SettingsState.GetFreePlayOpacity)

	if success and typeof(freePlayOpacity) == "number" then
		return freePlayOpacity
	end

	return 0.58
end

local function kbCategory(instance): nil | string -- 2 equivalent calls inferred from this helper
	if instance.Name:sub(1, 5) == "Note_" then
		return "note"
	end

	local parent = instance.Parent

	if parent and (parent.Name == "ChromeRow" or parent.Name == "LeftModifierColumn" or parent.Name == "BottomRow") then
		return "pad"
	end

	return nil
end

local function kbRefreshPress(instance)
	local newUIDecorKbPress = instance:FindFirstChild("NewUIDecorKbPress")

	if not newUIDecorKbPress then
		return
	end

	local ui0_h_bg = instance:GetAttribute("ui0_h_bg")
	local v23

	if typeof(ui0_h_bg) == "Color3" then
		v23 = select(3, ui0_h_bg:ToHSV()) > 0.3
	else
		v23 = false
	end

	newUIDecorKbPress.BackgroundTransparency = v23 and 0.12 or 1
	local uiStroke = newUIDecorKbPress:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Transparency = v23 and 0.15 or 1
	end
end

local function kbDecorButton(button)
	if isInDecor(button) or button:GetAttribute("ui0_kDone") then
		return
	end

	local v23 = kbCategory(button) -- inferred equivalent call

	if not v23 then
		return
	end

	button:SetAttribute("ui0_kDone", true)
	local uiStroke = button:FindFirstChildOfClass("UIStroke")
	button:SetAttribute("ui0_kBT", button.BackgroundTransparency)

	if v23 == "note" then
		button.BackgroundTransparency = 1

		if uiStroke then
			uiStroke:SetAttribute("ui0_kSE", uiStroke.Enabled)
			uiStroke.Enabled = false
		end

		button:SetAttribute("ui0_kXA", button.TextXAlignment.Name)
		button:SetAttribute("ui0_kYA", button.TextYAlignment.Name)
		button:SetAttribute("ui0_kTT", button.TextTransparency)
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.TextYAlignment = Enum.TextYAlignment.Bottom
		button:SetAttribute("ui0_kTS", button.TextStrokeTransparency)
		button:SetAttribute("ui0_kSC", button.TextStrokeColor3)
		button.TextTransparency = 0
		button.TextStrokeColor3 = Color3.new(0, 0, 0)
		button.TextStrokeTransparency = 0.2
		button.TextSize = 19
		mk( -- inferred equivalent call
			"UIPadding",
			{
				Name = "NewUIDecorKbPadding",
				PaddingLeft = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 4)
			},
			button
		)
		local parent = mk("Frame", { -- inferred equivalent call
			Name = "NewUIDecorKbPress",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, -4, 0.5, 2),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = Colors.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = false
		}, button)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
		mk("UIStroke", { Color = Color3.fromRGB(240, 200, 120), Thickness = 1.5, Transparency = 1 }, parent) -- inferred equivalent call
		button:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
			kbRefreshPress(button)
		end)
		kbRefreshPress(button)
	else
		button.BackgroundTransparency = 1 - math.min(1, kbOpacity() + 0.02) -- inferred equivalent call

		if uiStroke then
			uiStroke:SetAttribute("ui0_kST", uiStroke.Thickness)
			uiStroke:SetAttribute("ui0_kSTr", uiStroke.Transparency)
			uiStroke.Thickness = 1.5
			uiStroke.Transparency = 0.3
		end
	end
end

local function kbRebuildFret(noteGrid)
	for _, child in ipairs(noteGrid:GetChildren()) do
		if child.Name == "NewUIDecorKbFret" or child.Name == "NewUIDecorKbFretTape" then
			child:Destroy()
		end
	end

	local maxValue = 0
	local maxValue2 = 0
	local v23 = nil
	local v24 = nil
	local v25 = nil

	for _, child in ipairs(noteGrid:GetChildren()) do
		local match, v26 = child.Name:match("^Note_%a+_S(%d+)_F(%d+)_Lane%d+$")

		if not match then
			continue
		end

		local v27 = tonumber(match)
		local v28 = tonumber(v26)
		maxValue = math.max(maxValue, v27)
		maxValue2 = math.max(maxValue2, v28 + 1)

		if v27 == 1 and v28 == 0 then
			v23 = child
		elseif v27 == 1 and v28 == 1 then
			v24 = child
		elseif v27 == 2 and v28 == 0 then
			v25 = child
		end
	end

	if maxValue == 0 or not (v23 and v24) then
		return
	end

	local offset = v23.Size.X.Offset
	local offset2 = v23.Size.Y.Offset
	local v26 = v24.Position.X.Offset - v23.Position.X.Offset
	local v27 = v25 and v25.Position.Y.Offset - v23.Position.Y.Offset or offset2 + 4
	local v28 = v26 - offset
	local v29 = v27 - offset2
	local v30 = (maxValue2 - 1) * v26 + offset
	local v31 = (maxValue - 1) * v27 + offset2

	local random = Random.new(8128)

	local folder = mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorKbFret",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 0,
		Position = UDim2.fromOffset(-12, -10),
		Size = UDim2.fromOffset(v30 + 24, v31 + 20)
	}, noteGrid)

	local function box(p, p2, p3, p4, backgroundColor, backgroundTransparency, value)
		return mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromOffset(p, p2),
			Size = UDim2.fromOffset(p3, p4),
			Rotation = value or 0
		}, folder)
	end

	local parent = mk("Frame", { -- inferred equivalent call
		Name = "Board",
		BackgroundColor3 = Color3.fromRGB(40, 28, 19),
		BackgroundTransparency = 1 - kbOpacity(), -- inferred equivalent call
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.fromScale(1, 1)
	}, folder)

	mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent) -- inferred equivalent call
	mk( -- inferred equivalent call
		"UIStroke",
		{
			Color = Grunge.WindowStroke,
			Thickness = 2,
			Transparency = 0.15,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent
	)

	for _ = 1, 38 do
		box(
			random:NextInteger(0, v30),
			random:NextInteger(2, v31 + 20 - 2),
			random:NextInteger(60, 420),
			1,
			Color3.fromRGB(96, 70, 46),
			0.78 + random:NextNumber() * 0.12,
			random:NextNumber() * 2 - 1
		)
	end

	for i = 1, 3 do
		local parent2 = box(
			12 + v26 * (i * 0.7 + 0.4),
			10 + v31 * (i * 0.2 + 0.2),
			i * 30 + 150,
			46,
			Color3.fromRGB(200, 188, 164),
			0.94,
			0
		)
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	for i = 1, 5 do
		local integer = random:NextInteger(70, 190)
		local parent2 = box(
			random:NextInteger(0, v30),
			random:NextInteger(0, v31),
			integer,
			math.floor(integer * 0.4),
			i % 2 == 0 and Grunge.Rust or Color3.new(0, 0, 0),
			0.84 + random:NextNumber() * 0.06,
			0
		)
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	local function dot(p, p2)
		if maxValue2 - 1 < p then
			return
		end

		local v32 = 12 + p * v26 + offset / 2
		local v34 = 10 + p2 * v27 - v29 / 2
		local parent2 = box(v32 - 7.5, v34 - 7.5, 15, 15, Color3.fromRGB(214, 200, 160), 0.3, 0)
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
		mk("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.5 }, parent2) -- inferred equivalent call
	end
	local halfMaxValue = maxValue / 2

	for _, v32 in ipairs({ 3, 5, 7, 9 }) do
		dot(v32, halfMaxValue)
	end

	dot(12, halfMaxValue - 1)
	dot(12, halfMaxValue + 1)

	for i = 0, maxValue2 - 2 do
		local v32 = 12 + i * v26 + offset + v28 / 2

		if i == 0 then
			box(v32 - 3, 7, 6, v31 + 6, Color3.fromRGB(214, 200, 160), 0.3, 0)
		else
			box(v32 - 1, 8, 3, v31 + 4, Color3.new(0, 0, 0), 0.6, 0)
			box(v32 - 1.5, 8, 2.5, v31 + 4, Color3.fromRGB(198, 196, 188), 0.3, 0)
		end
	end

	for i = 1, maxValue do
		local v32 = maxValue - i + 1
		local v35

		if maxValue <= 4 then
			v35 = 4.2 - (v32 - 1) * (1.8 / math.max(maxValue - 1, 1))
		else
			v35 = 3.4 - (v32 - 1) * (2.4 / math.max(maxValue - 1, 1))
		end

		local v36 = 10 + (i - 1) * v27 + offset2 / 2
		box(8, v36 - v35 / 2 + 2, v30 + 8, v35, Color3.new(0, 0, 0), 0.65, 0)
		box(
			8,
			v36 - v35 / 2,
			v30 + 8,
			v35,
			v35 >= 2 and Color3.fromRGB(178, 136, 80) or Color3.fromRGB(206, 204, 197),
			0.12,
			0
		)
	end

	for _ = 1, 60 do
		local v32 = random:NextNumber() > 0.4
		local integer = random:NextInteger(1, 3)
		box(
			random:NextInteger(0, v30 + 24),
			random:NextInteger(0, v31 + 20),
			integer,
			integer,
			v32 and Colors.TextPrimary or Color3.new(0, 0, 0),
			v32 and 0.8 + random:NextNumber() * 0.12 or 0.4 + random:NextNumber() * 0.25,
			0
		)
	end

	for _ = 1, 8 do
		box(
			random:NextInteger(0, v30),
			random:NextInteger(0, v31),
			random:NextInteger(80, 240),
			1,
			Colors.TextPrimary,
			0.9 + random:NextNumber() * 0.05,
			random:NextInteger(-20, 20)
		)
	end

	local folder2 = mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecorKbFretTape",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 40,
		Position = UDim2.fromOffset(-12, -10),
		Size = UDim2.fromOffset(v30 + 24, v31 + 20)
	}, noteGrid)

	mk("Frame", { -- inferred equivalent call
		Name = "TL",
		BackgroundColor3 = Grunge.Tape,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, -14, 0, -6),
		Size = UDim2.fromOffset(72, 16),
		Rotation = -36
	}, folder2)
	mk("Frame", { -- inferred equivalent call
		Name = "BR",
		BackgroundColor3 = Grunge.TapeDark,
		BackgroundTransparency = 0.14,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(1, -58, 1, -12),
		Size = UDim2.fromOffset(72, 16),
		Rotation = -36
	}, folder2)

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 0
		end
	end

	for _, guiObject in ipairs(folder2:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 40
		end
	end
end

local function kbApplyOpacity()
	local v23 = v21

	if not v23 or v ~= "NewUI" then
		return
	end

	local keyboardCanvas = v23:FindFirstChild("KeyboardCanvas")

	if not keyboardCanvas then
		return
	end

	local v24 = kbOpacity() -- inferred equivalent call
	local noteGrid = keyboardCanvas:FindFirstChild("NoteGrid")
	local newUIDecorKbFret = noteGrid and noteGrid:FindFirstChild("NewUIDecorKbFret")
	local board = newUIDecorKbFret and newUIDecorKbFret:FindFirstChild("Board")

	if board then
		board.BackgroundTransparency = 1 - v24
	end

	local backgroundTransparency = 1 - math.min(1, v24 + 0.02)

	for _, button in ipairs(keyboardCanvas:GetDescendants()) do
		if not (button:IsA("TextButton") and button:GetAttribute("ui0_kDone") and kbCategory(button) == "pad") then -- inferred equivalent call
			continue
		end

		button.BackgroundTransparency = backgroundTransparency
	end
end

fn3 = function(instance)
	local keyboardCanvas = instance:FindFirstChild("KeyboardCanvas")

	if not keyboardCanvas then
		return
	end

	v21 = instance

	if not v22 then
		v22 = true
		SettingsState.OnChanged(function()
			kbApplyOpacity()
		end)
	end

	for _, button in ipairs(keyboardCanvas:GetDescendants()) do
		if button:IsA("TextButton") then
			kbDecorButton(button)
		end
	end

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
	local noteGrid = keyboardCanvas:FindFirstChild("NoteGrid")

	if noteGrid then
		kbRebuildFret(noteGrid)
		local flag2 = false
		local function schedule() -- 2 equivalent calls inferred from this helper
			if flag2 then
				return
			end

			flag2 = true
			task.delay(0.1, function()
				flag2 = false

				if v == "NewUI" and noteGrid.Parent then
					kbRebuildFret(noteGrid)
				end
			end)
		end
		table.insert(connections, noteGrid.ChildAdded:Connect(function(child)
			if child.Name:sub(1, 5) == "Note_" then
				schedule() -- inferred equivalent call
			end
		end))
		table.insert(connections, noteGrid.ChildRemoved:Connect(function(child)
			if child.Name:sub(1, 5) == "Note_" then
				schedule() -- inferred equivalent call
			end
		end))
	end

	table.insert(connections, keyboardCanvas.DescendantAdded:Connect(function(button)
		if button:IsA("TextButton") then
			task.defer(function()
				if v == "NewUI" and button.Parent then
					kbDecorButton(button)
				end
			end)
		end
	end))
end

fn4 = function(instance)
	v21 = nil

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
	local keyboardCanvas = instance:FindFirstChild("KeyboardCanvas")

	if not keyboardCanvas then
		return
	end

	for _, descendant in ipairs(keyboardCanvas:GetDescendants()) do
		if descendant.Name:sub(1, 12) == "NewUIDecorKb" then
			descendant:Destroy()
		end
	end

	for _, guiObject in ipairs(keyboardCanvas:GetDescendants()) do
		if not (guiObject:IsA("GuiObject") and guiObject:GetAttribute("ui0_kDone")) then
			continue
		end

		local ui0_kBT = guiObject:GetAttribute("ui0_kBT")

		if ui0_kBT ~= nil then
			guiObject.BackgroundTransparency = ui0_kBT
		end

		local ui0_kTT = guiObject:GetAttribute("ui0_kTT")

		if ui0_kTT ~= nil then
			guiObject.TextTransparency = ui0_kTT
		end

		local ui0_kTS = guiObject:GetAttribute("ui0_kTS")

		if ui0_kTS ~= nil then
			guiObject.TextStrokeTransparency = ui0_kTS
		end

		local ui0_kSC = guiObject:GetAttribute("ui0_kSC")

		if ui0_kSC ~= nil then
			guiObject.TextStrokeColor3 = ui0_kSC
		end

		local ui0_kXA = guiObject:GetAttribute("ui0_kXA")

		if ui0_kXA ~= nil then
			guiObject.TextXAlignment = Enum.TextXAlignment[ui0_kXA]
		end

		local ui0_kYA = guiObject:GetAttribute("ui0_kYA")

		if ui0_kYA ~= nil then
			guiObject.TextYAlignment = Enum.TextYAlignment[ui0_kYA]
		end

		local uiStroke = guiObject:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			local ui0_kSE = uiStroke:GetAttribute("ui0_kSE")

			if ui0_kSE ~= nil then
				uiStroke.Enabled = ui0_kSE
				uiStroke:SetAttribute("ui0_kSE", nil)
			end

			local ui0_kST = uiStroke:GetAttribute("ui0_kST")

			if ui0_kST ~= nil then
				uiStroke.Thickness = ui0_kST
				uiStroke:SetAttribute("ui0_kST", nil)
			end

			local ui0_kSTr = uiStroke:GetAttribute("ui0_kSTr")

			if ui0_kSTr ~= nil then
				uiStroke.Transparency = ui0_kSTr
				uiStroke:SetAttribute("ui0_kSTr", nil)
			end
		end

		for _, v23 in ipairs({
			"ui0_kDone",
			"ui0_kBT",
			"ui0_kTT",
			"ui0_kXA",
			"ui0_kYA",
			"ui0_kTS",
			"ui0_kSC"
		}) do
			guiObject:SetAttribute(v23, nil)
		end
	end
end

local function isGear(instance): boolean
	while instance and instance.Parent do
		if
			(instance.Name == "GearButton" or instance.Name == "EquipmentButton")
			and instance.Parent:IsA("ScreenGui")
		then
			return true
		end

		instance = instance.Parent
	end

	return false
end

local function toNew(descendant)
	if isGear(descendant) then
		return
	end

	if isHeuristic(descendant) then -- inferred equivalent call
		heurRecolor(descendant)
		hookHeur(descendant)
	else
		local v23 = descendant
		local newUI

		while true do
			if not v23 then
				newUI = StyledTheme.Maps.NewUI
				break
			end

			local v24 = v10[v23]

			if v24 then
				newUI = v24.NewUI
				break
			end

			v23 = v23.Parent
		end

		remapColors(descendant, newUI)
	end

	if isTextClass(descendant) then -- inferred equivalent call
		local font = v3[descendant.Font]

		if not font and descendant.Font == Font.GothamBlack then
			local screenGui = descendant:FindFirstAncestorOfClass("ScreenGui")

			if screenGui and screenGui.Name == "AmpSettingsUI" then
				font = Font.Oswald
			end
		end

		if not font and v4[descendant.Font] and descendant:GetAttribute("ui0_Font") == nil then
			descendant:SetAttribute("ui0_Born", true)
		end

		if font then
			if descendant:GetAttribute("ui0_Font") == nil then
				descendant:SetAttribute("ui0_Font", descendant.Font.Name)
				descendant:SetAttribute("ui0_TextSize", descendant.TextSize)
			end

			local ui0_TextSize = descendant:GetAttribute("ui0_TextSize")
			descendant.Font = font

			if not descendant.TextScaled then
				local textSize = math.max(v6[font], (math.floor(ui0_TextSize * v5[font] + 0.5)))

				if ui0_TextSize <= 9 then
					textSize = math.max(textSize, 14)
				end

				if
					descendant:IsA("TextButton")
					and descendant.Size.Y.Scale == 0
					and descendant.Size.Y.Offset > 0
					and descendant.Size.Y.Offset <= 20
				then
					textSize = math.max(textSize, (math.min(15, descendant.Size.Y.Offset - 3)))
				end

				descendant.TextSize = textSize
			end
		end
	elseif descendant:IsA("UICorner") then
		local cornerRadius = descendant.CornerRadius
		local udim = nil

		if cornerRadius.Scale == 0 and v8[cornerRadius.Offset] then
			udim = UDim.new(0, v8[cornerRadius.Offset])
		else
			local parent = descendant.Parent

			if parent and parent:IsA("GuiObject") and parent.Name ~= "Track" then
				local v23 = parent.AbsoluteSize.X
				local v24 = parent.AbsoluteSize.Y

				if v23 <= 0 or v24 <= 0 then
					v23 = parent.Size.X.Offset
					v24 = parent.Size.Y.Offset
				end

				local v25

				if v23 > 0 and v24 > 0 then
					if v24 * 1.3 < v23 then
						if cornerRadius.Scale >= 0.4 then
							v25 = true
						else
							local offset = cornerRadius.Offset
							v25 = v24 / 2 - 1 <= offset
						end
					else
						v25 = false
					end
				else
					v25 = cornerRadius.Scale >= 0.4 or cornerRadius.Offset >= 9
				end

				if v25 then
					udim = UDim.new(0, 3)
				end
			end
		end

		if udim then
			if descendant:GetAttribute("ui0_CornerU") == nil then
				descendant:SetAttribute("ui0_CornerU", cornerRadius)
			end

			descendant.CornerRadius = udim
		end
	end

	if
		(descendant:IsA("TextButton") or descendant:IsA("Frame"))
		and descendant.Name ~= "Track"
		and descendant.Name ~= "Window"
		and descendant.BackgroundTransparency < 0.9
		and not descendant:FindFirstChildOfClass("UIStroke")
		and StyledTheme.ColorKey(descendant.BackgroundColor3) == StyledTheme.ColorKey(Colors.Surface)
	then
		mk("UIStroke", { -- inferred equivalent call
			Name = "NewUIDecorStroke",
			Color = Colors.Border,
			Thickness = 1,
			Transparency = 0.25,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, descendant)
	end
end

local function toDefault(uiCorner)
	if isGear(uiCorner) then
		return
	end

	if isHeuristic(uiCorner) then -- inferred equivalent call
		heurRestore(uiCorner)
	else
		local v23 = uiCorner
		local default

		while true do
			if not v23 then
				default = StyledTheme.Maps.Default
				break
			end

			local v24 = v10[v23]

			if v24 then
				default = v24.Default
				break
			end

			v23 = v23.Parent
		end

		remapColors(uiCorner, default)
	end

	local ui0_Born = uiCorner:GetAttribute("ui0_Born") == true

	if isTextClass(uiCorner) then -- inferred equivalent call
		local ui0_Font = uiCorner:GetAttribute("ui0_Font")

		if ui0_Font then
			uiCorner.Font = Enum.Font[ui0_Font]
			local ui0_TextSize = uiCorner:GetAttribute("ui0_TextSize")

			if ui0_TextSize then
				uiCorner.TextSize = ui0_TextSize
			end

			uiCorner:SetAttribute("ui0_Font", nil)
			uiCorner:SetAttribute("ui0_TextSize", nil)
		else
			local font = ui0_Born and v4[uiCorner.Font]

			if font then
				uiCorner.Font = font
				local textSize = v7[uiCorner.TextSize]

				if textSize then
					uiCorner.TextSize = textSize
				end
			end
		end
	elseif uiCorner:IsA("UICorner") then
		local ui0_CornerU = uiCorner:GetAttribute("ui0_CornerU")

		if ui0_CornerU then
			uiCorner.CornerRadius = ui0_CornerU
			uiCorner:SetAttribute("ui0_CornerU", nil)
		elseif ui0_Born and uiCorner.CornerRadius.Scale == 0 and v9[uiCorner.CornerRadius.Offset] then
			uiCorner.CornerRadius = UDim.new(0, v9[uiCorner.CornerRadius.Offset])
		end
	end

	if ui0_Born then
		uiCorner:SetAttribute("ui0_Born", nil)
	end
end

local function restyleRoot(folder, p)
	if p == "NewUI" then
		for _, descendant in ipairs(folder:GetDescendants()) do
			if isWindow(descendant) then
				decorateWindow(descendant)
			end
		end

		local overlay, panel, v23

		if folder.Name == "ResultsScreenUI" then
			overlay = folder:FindFirstChild("Overlay")
			panel = overlay and overlay:FindFirstChild("Panel")

			if overlay then
				v23 = overlay:FindFirstChild("CloseButton")
			else
				v23 = overlay
			end
		end

		if panel then
			decorateWindow(panel, {
				parent = overlay,
				z = panel.ZIndex + 1
			}, 2)
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			if not isInDecor(descendant) then
				toNew(descendant)
			end
		end

		applyExtras(folder)
		skinResultsClose(v23)
		decorateCards(folder)
	else
		removeExtras(folder)
		undecorateCards(folder)
		local overlay, panel

		if folder.Name == "ResultsScreenUI" then
			overlay = folder:FindFirstChild("Overlay")
			panel = overlay and overlay:FindFirstChild("Panel")

			if overlay then
				overlay = overlay:FindFirstChild("CloseButton")
			end
		end

		unskinResultsClose(overlay)

		if panel then
			undecorateWindow(panel)
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant.Name == "NewUIDecorStroke" then
				descendant:Destroy()
			end
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			if isWindow(descendant) then
				undecorateWindow(descendant)
			end
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			toDefault(descendant)
		end
	end
end

function UISkin.Applied()
	return v
end

function UISkin.Refresh()
	local uiStyle = SettingsState.GetUIStyle()

	if uiStyle == v then
		return
	end

	StyledTheme.Apply(uiStyle)
	v = uiStyle

	for _, v23 in ipairs(instances) do
		local success, result = pcall(restyleRoot, v23, uiStyle)

		if not success then
			warn("[UISkin] gagal menerapkan gaya " .. uiStyle .. ": " .. tostring(result))
		end
	end
end

local instanceSet = {}

local function hookRoot(instance)
	if instanceSet[instance] then
		return
	end

	instanceSet[instance] = true

	instance.DescendantAdded:Connect(function(descendant)
		if v ~= "NewUI" or isInDecor(descendant) then
			return
		end

		if descendant:GetAttribute("ui0_Born") == nil then
			descendant:SetAttribute("ui0_Born", true)
		end

		task.defer(function()
			if v == "NewUI" and descendant.Parent then
				toNew(descendant)

				if isCardCandidate(descendant, instance) then
					decorateCard(descendant)
				end
			end

			task.delay(0.2, function()
				if v == "NewUI" and descendant.Parent then
					fitText(descendant)
				end
			end)
		end)
	end)

	instance:GetPropertyChangedSignal("Enabled"):Connect(function()
		if instance.Enabled and v == "NewUI" then
			task.delay(0.2, fitAll, instance)
		end
	end)

	local playerCard = instance.Name == "PlayerCardGui" and instance:FindFirstChild("PlayerCard")

	if playerCard then
		playerCard:GetPropertyChangedSignal("Visible"):Connect(function()
			if v == "NewUI" and playerCard.Visible then
				task.delay(0.25, fitAll, instance)
			end
		end)
	end

	if instance.Name == "EquipmentUI" then
		local root = instance:FindFirstChild("Root")

		if root then
			local function soonE()
				if v == "NewUI" then
					task.delay(0.3, fitAll, instance)
				end
			end
			root:GetPropertyChangedSignal("Visible"):Connect(soonE)

			for _, childName in ipairs({ "ListPanel", "CardPanel" }) do
				local child = root:FindFirstChild(childName)

				if child then
					child:GetPropertyChangedSignal("Visible"):Connect(soonE)
				end
			end

			local grid = root:FindFirstChild("ListPanel") and root.ListPanel:FindFirstChild("Grid")

			if grid then
				grid.ChildAdded:Connect(soonE)
			end
		end
	end

	local instanceRoot = instance.Name == "BandGui" and instance:FindFirstChild("Root")

	if instanceRoot then
		instanceRoot:GetPropertyChangedSignal("Visible"):Connect(function()
			if v == "NewUI" and instanceRoot.Visible then
				task.delay(0.3, fitAll, instance)
			end
		end)
	end

	local dropdown = instance.Name == "SettingsMenuUI" and instance:FindFirstChild("Dropdown")

	if dropdown then
		local function soon()
			if v == "NewUI" then
				task.delay(0.25, fitAll, instance)
			end
		end
		dropdown:GetPropertyChangedSignal("Visible"):Connect(soon)
		local content = dropdown:FindFirstChild("Content")

		if content then
			for _, guiObject in ipairs(content:GetChildren()) do
				if guiObject:IsA("GuiObject") then
					guiObject:GetPropertyChangedSignal("Visible"):Connect(soon)
				end
			end
		end
	end
end

function UISkin.AddRoot(instance, p)
	for _, v23 in ipairs(instances) do
		if v23 == instance then
			return
		end
	end

	table.insert(instances, instance)

	if p and p.heuristic then
		v12[instance] = true
	end

	instance.Destroying:Connect(function()
		for i, v23 in ipairs(instances) do
			if v23 == instance then
				table.remove(instances, i)
				break
			end
		end

		v12[instance] = nil
		v10[instance] = nil
	end)

	if
		instance.Name == "SettingsMenuUI"
		or instance.Name == "EquipmentUI"
		or instance.Name == "ServerBrowserUI"
		or instance.Name == "BandGui"
	then
		v10[instance] = makeCombined(StyledTheme.SettingsMaps)
	end

	if instance.Name == "AmpSettingsUI" then
		v10[instance] = makeCombined(StyledTheme.AmpMaps)
	end

	hookRoot(instance)

	if v == "NewUI" then
		local success, result = pcall(restyleRoot, instance, "NewUI")

		if not success then
			warn("[UISkin] gagal menerapkan NewUI ke " .. instance.Name .. ": " .. tostring(result))
		end
	end
end

local v23 = {
	RoomHudGui = true,
	HighPingWarningToastGui = true,
	ThemeSwitchToastGui = true,
	JoinSessionToastGui = true,
	LaptopVoteToastGui = true,
	ChartUnavailableNotice = true,
	AfkUnequipToastGui = true
}
local v24 = {
	SyncAdjustmentNoticeUI = true,
	AmpNoticeUI = true,
	PutBackConfirmUI = true,
	ServerRestartAlertGui = true,
	VirtualKeyboardUI = true
}

function UISkin.WatchPlayerGui(instance)
	local function consider(screenGui)
		if not screenGui:IsA("ScreenGui") then
			return
		end

		if v23[screenGui.Name] then
			UISkin.AddRoot(screenGui)
		elseif v24[screenGui.Name] then
			UISkin.AddRoot(screenGui, { heuristic = true })
		end
	end

	for _, child in ipairs(instance:GetChildren()) do
		consider(child)
	end

	instance.ChildAdded:Connect(consider)
end

function UISkin.Init(list, p)
	if flag then
		return
	end

	flag = true

	if p then
		v2 = p
	end

	for _, item in ipairs(list) do
		UISkin.AddRoot(item)
	end

	SettingsState.OnChanged(function()
		if not v2() then
			UISkin.Refresh()
		end
	end)

	UISkin.Refresh()
end

return UISkin