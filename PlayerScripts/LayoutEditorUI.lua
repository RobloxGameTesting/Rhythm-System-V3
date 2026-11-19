local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local LayoutEditorUI = {}

local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local name = nil
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = setmetatable({}, { __mode = "k" })
local v14 = nil
local v15 = nil
local v16 = 5
local flag = false
local v17 = false
local v18 = false
local v19 = nil
local v20 = nil
local v21 = {}
local v22 = {}
local v23 = {}
local renderSteppedConnection = nil
local v24 = nil
local viewportSizeChangedConnection = nil

local function make(className, items, parent) -- 68 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function currentSkin()
	local isNew = SettingsState.GetUIStyle() == "NewUI"
	local name2 = isNew and "NewUI" or "Default"
	return {
		Name = name2,
		IsNew = isNew,
		Pal = StyledTheme.Styles[name2].Settings,
		Grunge = StyledTheme.Grunge,
		Body = isNew and Enum.Font.SpecialElite or Enum.Font.Gotham,
		Head = isNew and Enum.Font.Oswald or Enum.Font.GothamBold,
		Radius = UDim.new(0, isNew and 3 or 8)
	}
end

local function readAll()
	local all = {}

	for i = 1, 5 do
		all[i] = SettingsState.GetButtonPositionOffset(i)
	end

	return all
end

local function sameSnap(list, list2): boolean
	for i = 1, 5 do
		if (list[i] - list2[i]).Magnitude > 0.01 then
			return false
		end
	end

	return true
end

local function writeAll(list)
	local v25 = {}

	for i = 1, 5 do
		local item = list[i]

		if item and (item.X ~= 0 or item.Y ~= 0) then
			v25[tostring(i)] = { X = item.X, Y = item.Y }
		end
	end

	SettingsState.SetField("ButtonPositions", v25, true)
	v.RelayoutLive()
end

local function refreshHistoryButtons() -- 6 equivalent calls inferred from this helper
	if v14 then
		v14.TextTransparency = #v22 > 0 and 0 or 0.6
	end

	if v15 then
		v15.TextTransparency = #v23 > 0 and 0 or 0.6
	end
end

local function pushUndo(p) -- 2 equivalent calls inferred from this helper
	table.insert(v22, p)

	if #v22 > 30 then
		table.remove(v22, 1)
	end

	v23 = {}
	refreshHistoryButtons() -- inferred equivalent call
end

local function applyChange(fn) -- 4 equivalent calls inferred from this helper
	local v25 = readAll()
	local v26 = readAll()
	fn(v26)

	if sameSnap(v25, v26) then
		return
	end

	pushUndo(v25) -- inferred equivalent call
	writeAll(v26)
end

local function undo()
	local v25 = table.remove(v22)

	if not v25 then
		return
	end

	table.insert(v23, readAll())
	writeAll(v25)
	refreshHistoryButtons() -- inferred equivalent call
end

local function redo()
	local v25 = table.remove(v23)

	if not v25 then
		return
	end

	table.insert(v22, readAll())
	writeAll(v25)
	refreshHistoryButtons() -- inferred equivalent call
end

local function scaleOf(hitContainer) -- 3 equivalent calls inferred from this helper
	local offset = hitContainer.Size.X.Offset

	if offset > 0 and hitContainer.AbsoluteSize.X > 0 then
		return hitContainer.AbsoluteSize.X / offset
	end

	return 1
end

local function styleHandle(p)
	local v25 = v10[p]

	if not v25 then
		return
	end

	local pal = v9.Pal
	local visible = v19 == p
	v25.Stroke.Color = visible and pal.ACCENT or pal.TEXT
	v25.Stroke.Transparency = visible and 0 or 0.5
	v25.Stroke.Thickness = visible and 3 or 2
	v25.Frame.BackgroundColor3 = pal.ACCENT
	v25.Frame.BackgroundTransparency = visible and 0.86 or 1
	v25.Badge.BackgroundColor3 = visible and pal.ACCENT or v9.IsNew and v9.Grunge.Tape or pal.BG
	v25.Badge.TextColor3 = (visible or v9.IsNew) and pal.DARKTEXT or pal.TEXT
	v25.Coord.Visible = visible
end

local function selectLane(p) -- 2 equivalent calls inferred from this helper
	v19 = p

	styleHandle(1)
	styleHandle(2)
	styleHandle(3)
	styleHandle(4)
	styleHandle(5)
end

local function resetLane(p) -- 2 equivalent calls inferred from this helper
	local function fn(vector2s)
		vector2s[p] = Vector2.new(0, 0)
	end

	applyChange(fn) -- inferred equivalent call
end

local function beginDrag(lane, input)
	selectLane(lane) -- inferred equivalent call
	local now = os.clock()

	if v21[lane] and now - v21[lane] < 0.35 then
		v21[lane] = nil
		resetLane(lane) -- inferred equivalent call
	else
		v21[lane] = now
		v20 = {
			Lane = lane,
			StartMouse = Vector2.new(input.Position.X, input.Position.Y),
			StartOffset = SettingsState.GetButtonPositionOffset(lane),
			Before = readAll(),
			Moved = false
		}
	end
end

local function setGuideVisible(visible, p) -- 2 equivalent calls inferred from this helper
	if v5 then
		v5.Visible = visible
		v5.BackgroundTransparency = p and 0.05 or 0.55
	end

	if v6 then
		v6.Visible = visible
	end
end

local function updateDrag(input)
	if not v20 then
		return
	end

	local lane = v20.Lane
	local hitContainer = v.GetHitContainer(lane)

	if not hitContainer then
		return
	end

	local v25 = Vector2.new(input.Position.X, input.Position.Y) - v20.StartMouse

	if not v20.Moved then
		if v25.Magnitude < 3 then
			return
		end

		v20.Moved = true
		v21[lane] = nil
	end

	local v26 = scaleOf(hitContainer) -- inferred equivalent call
	local buttonPositionOffset = SettingsState.GetButtonPositionOffset(lane)
	local v27 = hitContainer.AbsolutePosition + hitContainer.AbsoluteSize / 2 - buttonPositionOffset * v26
	local v28 = v27 + (v20.StartOffset + v25 / v26) * v26

	local v29 = v4.AbsolutePosition.X + v4.AbsoluteSize.X / 2

	if v18 then
		local v30 = 10 * v26
		v28 = Vector2.new(v29 + math.round((v28.X - v29) / v30) * v30, v27.Y + math.round((v28.Y - v27.Y) / v30) * v30)
	end

	local v30

	if math.abs(v28.X - v29) <= 6 then
		v28 = Vector2.new(v29, v28.Y)
		v30 = true
	else
		v30 = false
	end

	local v31 = (v28 - v27) / v26
	local vector2 = Vector2.new(
		math.clamp(math.floor(v31.X + 0.5), -500, 500),
		(math.clamp(math.floor(v31.Y + 0.5), -400, 400))
	)

	SettingsState.SetButtonPositionOffset(lane, vector2)
	v.RelayoutLive()
	setGuideVisible(true, v30) -- inferred equivalent call
end

local function endDrag() -- 1 equivalent call inferred from this helper
	if not v20 then
		return
	end

	local v25 = v20
	v20 = nil
	setGuideVisible(false, false) -- inferred equivalent call

	if v25.Moved then
		local v26 = readAll()

		if not sameSnap(v25.Before, v26) then
			pushUndo(v25.Before) -- inferred equivalent call
		end

		SettingsState.FlushPending()
	end
end

local function buildHandle(lane)
	local pal = v9.Pal
	local grunge = v9.Grunge
	local frame = make("TextButton", { -- inferred equivalent call
		Name = "Handle" .. lane,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(60, 60),
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = pal.ACCENT,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20
	}, v4)

	make("UICorner", { CornerRadius = UDim.new(1, 0) }, frame) -- inferred equivalent call
	local stroke = make("UIStroke", { Thickness = 2, Color = pal.TEXT, Transparency = 0.5 }, frame) -- inferred equivalent call

	local badge = make("TextLabel", { -- inferred equivalent call
		Name = "Badge",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -6),
		Size = v9.IsNew and UDim2.fromOffset(26, 17) or UDim2.fromOffset(22, 18),
		BackgroundColor3 = v9.IsNew and grunge.Tape or pal.BG,
		BackgroundTransparency = v9.IsNew and 0.1 or 0.05,
		BorderSizePixel = 0,
		Rotation = v9.IsNew and (lane % 2 == 0 and 4 or -5) or 0,
		Font = v9.Head,
		TextSize = v9.IsNew and 14 or 11,
		TextColor3 = v9.IsNew and pal.DARKTEXT or pal.TEXT,
		Text = tostring(lane),
		ZIndex = 21
	}, frame)

	make("UICorner", { -- inferred equivalent call
		CornerRadius = v9.IsNew and UDim.new(0, 1) or UDim.new(1, 0)
	}, badge)

	local coord = make("TextLabel", { -- inferred equivalent call
		Name = "Coord",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 8),
		Size = UDim2.fromOffset(110, 18),
		BackgroundColor3 = pal.BG,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Font = v9.Body,
		TextSize = 12,
		TextColor3 = pal.ACCENT,
		Text = "",
		Visible = false,
		ZIndex = 21
	}, frame)

	make("UICorner", { CornerRadius = v9.Radius }, coord) -- inferred equivalent call
	make("UIStroke", { -- inferred equivalent call
		Color = v9.IsNew and grunge.WindowStroke or pal.BORDER,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, coord)

	frame.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			beginDrag(lane, input)
		end
	end)
	frame.MouseEnter:Connect(function()
		if v19 ~= lane then
			stroke.Transparency = 0.1
		end
	end)
	frame.MouseLeave:Connect(function()
		styleHandle(lane)
	end)

	v10[lane] = { Frame = frame, Stroke = stroke, Badge = badge, Coord = coord }
end

local function rebuildGrid()
	if not v7 then
		return
	end

	v7:ClearAllChildren()

	if not v17 then
		return
	end

	local hitContainer = v.GetHitContainer(1)

	if not hitContainer then
		return
	end

	local v25 = scaleOf(hitContainer) -- inferred equivalent call
	v24 = v25
	local v26 = 10 * v25 * 2
	local v27 = v26 < 8 and 8 or v26

	local absoluteSize = v4.AbsoluteSize
	local v28 = absoluteSize.X / 2
	local v29 = (hitContainer.AbsolutePosition + hitContainer.AbsoluteSize / 2 - v4.AbsolutePosition).Y - SettingsState.GetButtonPositionOffset(1).Y * v25
	local text = v9.Pal.TEXT
	local function line(p, p2, p3)
		make("Frame", { -- inferred equivalent call
			BorderSizePixel = 0,
			BackgroundColor3 = text,
			BackgroundTransparency = p3 and 0.78 or 0.9,
			ZIndex = 2,
			Size = p and UDim2.new(0, 1, 1, 0) or UDim2.new(1, 0, 0, 1),
			Position = p and UDim2.fromOffset(p2, 0) or UDim2.fromOffset(0, p2)
		}, v7)
	end

	local count = 0

	while v28 + count * v27 < absoluteSize.X + v27 or v28 - count * v27 > -v27 do
		line(true, v28 + count * v27, count % 5 == 0)

		if count > 0 then
			line(true, v28 - count * v27, count % 5 == 0)
		end

		count += 1

		if count > 200 then
			break
		end
	end

	local count2 = 0

	while v29 + count2 * v27 < absoluteSize.Y + v27 or v29 - count2 * v27 > -v27 do
		line(false, v29 + count2 * v27, count2 % 5 == 0)

		if count2 > 0 then
			line(false, v29 - count2 * v27, count2 % 5 == 0)
		end

		count2 += 1

		if count2 > 200 then
			break
		end
	end
end

local function setToggleLook(instance, p)
	local v25 = v13[instance]

	if not v25 then
		return
	end

	local pal = v9.Pal
	v25.Rest = p and pal.ACCENT or pal.BTN
	v25.Hover = p and pal.ACCENT:Lerp(Color3.new(1, 1, 1), 0.18) or pal.CARD_ACTIVE
	instance.TextColor3 = p and pal.DARKTEXT or pal.TEXT
	TweenService:Create(instance, TweenInfo.new(0.12), { BackgroundColor3 = v25.Rest }):Play()
end

local function refreshLaneButtons() -- 3 equivalent calls inferred from this helper
	for k, v25 in pairs(v11) do
		setToggleLook(v25, k == v16)
	end
end

local function setLaneCount(p) -- 1 equivalent call inferred from this helper
	v16 = p
	refreshLaneButtons() -- inferred equivalent call

	if v2.IsActive() then
		v2.SetLaneCount(p)
	end

	if v19 and p < v19 then
		selectLane(nil) -- inferred equivalent call
	end

	task.defer(rebuildGrid)
end

local function alignRow()
	local function fn(vector2s)
		local total = 0

		for i = 1, v16 do
			total += vector2s[i].Y
		end

		local v25 = math.floor(total / v16 + 0.5)

		for i = 1, v16 do
			vector2s[i] = Vector2.new(vector2s[i].X, v25)
		end
	end

	applyChange(fn) -- inferred equivalent call
end

local function evenSpacing()
	if v16 < 3 then
		return
	end

	local function fn(vector2s)
		local buttonGroupOffset = SettingsState.GetButtonGroupOffset()
		local v25 = {}
		local v26 = {}

		for i = 1, v16 do
			v25[i] = v.GetLaneRailXOffset(i) - buttonGroupOffset.X
			v26[i] = v25[i] - vector2s[i].X
		end

		for i = 2, v16 - 1 do
			local v27 = v25[1] + (v25[v16] - v25[1]) * (i - 1) / (v16 - 1)
			vector2s[i] = Vector2.new(math.clamp(math.floor(v27 - v26[i] + 0.5), -500, 500), vector2s[i].Y)
		end
	end

	applyChange(fn) -- inferred equivalent call
end

local function buildGrungeDecor(parent)
	local grunge = v9.Grunge
	local pal = v9.Pal
	local random = Random.new(47)

	local parent2 = make("Frame", { -- inferred equivalent call
		Name = "DecorBack",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, parent)

	local function vignette(name2, position, size, rotation, p)
		local parent3 = make("Frame", { -- inferred equivalent call
			Name = name2,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size
		}, parent2)

		make("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
		}, parent3)
	end
	vignette("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 30), 90, 0.5)
	vignette("VigBottom", UDim2.new(0, 0, 1, -30), UDim2.new(1, 0, 0, 30), 270, 0.5)
	vignette("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 36, 1, 0), 0, 0.55)
	vignette("VigRight", UDim2.new(1, -36, 0, 0), UDim2.new(0, 36, 1, 0), 180, 0.55)

	for i = 1, 6 do
		local integer = random:NextInteger(40, 110)
		local parent3 = make("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 3 == 0 and grunge.Rust or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.9 + random:NextNumber() * 0.05,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.6),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
		}, parent2)

		make("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
	end

	local parent3 = make("Frame", { -- inferred equivalent call
		Name = "DecorMid",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4
	}, parent)

	for i = 1, 3 do
		local integer = random:NextInteger(50, 120)
		local parent4 = make("Frame", { -- inferred equivalent call
			Name = "Grime" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.93 + random:NextNumber() * 0.04,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * 0.6)))
		}, parent3)

		make("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
	end

	for i, v25 in ipairs({
		{ 0.08, 0.3, 90, 24 },
		{ 0.6, 0.55, 70, -31 },
		{ 0.28, 0.75, 110, 12 },
		{ 0.78, 0.2, 60, -20 },
		{ 0.05, 0.88, 80, 35 },
		{ 0.5, 0.1, 70, -14 },
		{ 0.88, 0.7, 50, 52 }
	}) do
		make("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = pal.TEXT,
			BackgroundTransparency = 0.95,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(v25[1], v25[2]),
			Size = UDim2.new(0, v25[3], 0, 1),
			Rotation = v25[4]
		}, parent3)
	end

	for i = 1, 3 do
		make("Frame", { -- inferred equivalent call
			Name = "Scuff" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, random:NextInteger(30, 80), 0, 1),
			Rotation = random:NextInteger(-60, 60)
		}, parent3)
	end

	for i = 1, 30 do
		local v25 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 3)
		make("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v25 and pal.TEXT or Color3.new(0, 0, 0),
			BackgroundTransparency = v25 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, integer)
		}, parent3)
	end

	local parent4 = make("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6)
	}, parent3)

	make("UIStroke", { Color = grunge.EdgeWear, Thickness = 1.5, Transparency = 0.55 }, parent4) -- inferred equivalent call
	make("UICorner", { CornerRadius = UDim.new(0, 2) }, parent4) -- inferred equivalent call

	local parent5 = make("Frame", { -- inferred equivalent call
		Name = "DecorTape",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 6
	}, parent)

	local function tape(name2, position, size, rotation, backgroundColor, backgroundTransparency) -- 3 equivalent calls inferred from this helper
		make("Frame", { -- inferred equivalent call
			Name = name2,
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size,
			Rotation = rotation
		}, parent5)
	end
	tape("TapeLeft", UDim2.new(0, -16, 0, 2), UDim2.new(0, 56, 0, 13), -38, grunge.Tape, 0.12) -- inferred equivalent call
	tape("TapeBottomRight", UDim2.new(1, -36, 1, -12), UDim2.new(0, 46, 0, 12), -38, grunge.Tape, 0.18) -- inferred equivalent call
	tape("TapeBottomLeft", UDim2.new(0, -12, 1, -14), UDim2.new(0, 38, 0, 11), 34, grunge.TapeDark, 0.15) -- inferred equivalent call
end

local function makeButton(row, text, p, layoutOrder, p2, onMouseButton1Click)
	local pal = v9.Pal
	local grunge = v9.Grunge
	local v25 = p2 == "primary"
	local accent = v25 and pal.ACCENT or p2 == "danger" and pal.DANGER or pal.BTN
	local hover = v25 and pal.ACCENT:Lerp(Color3.new(1, 1, 1), 0.18)
		or p2 == "danger" and pal.DANGER:Lerp(Color3.new(1, 1, 1), 0.15)
		or pal.CARD_ACTIVE
	local v26 = {
		Name = text:gsub("%s", "") .. "Btn",
		LayoutOrder = layoutOrder,
		Size = UDim2.new(0, p, 0, 32),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		BackgroundColor3 = accent,
		Font = v9.Head,
		TextSize = v9.IsNew and 16 or 12,
		TextColor3 = v25 and pal.DARKTEXT or pal.TEXT,
		Text = 0
	}
	text = v9.IsNew and string.upper(text) or text
	v26.Text = text
	local button = make("TextButton", v26, row) -- inferred equivalent call
	make("UICorner", { CornerRadius = v9.Radius }, button) -- inferred equivalent call
	make("UIStroke", { -- inferred equivalent call
		Color = v25 and (v9.IsNew and grunge.WindowStroke or pal.ACCENT) or p2 == "danger" and grunge.WindowStroke or pal.BORDER,
		Thickness = v25 and v9.IsNew and 2 or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, button)

	local uiScale = make("UIScale", { Scale = 1 }, button) -- inferred equivalent call
	local v27 = { Rest = accent, Hover = hover }
	v13[button] = v27

	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local function toRest()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = v27.Rest }):Play()
		TweenService:Create(uiScale, tweenInfo, { Scale = 1 }):Play()
	end
	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = v27.Hover }):Play()
	end)
	button.MouseLeave:Connect(toRest)
	button.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			TweenService:Create(uiScale, tweenInfo, { Scale = 0.96 }):Play()
		end
	end)
	button.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			TweenService:Create(uiScale, tweenInfo, { Scale = 1 }):Play()
		end
	end)

	if onMouseButton1Click then
		button.MouseButton1Click:Connect(onMouseButton1Click)
	end

	return button
end

local function buildCloseButton(parent)
	local pal = v9.Pal
	local grunge = v9.Grunge
	local isNew = v9.IsNew

	local closeButton = make("TextButton", { -- inferred equivalent call
		Name = "CloseBtn",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -16, 0, isNew and 2 or 6),
		Size = UDim2.new(0, 44, 0, 34),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 8
	}, parent)

	local tape = isNew and grunge.Tape or pal.BTN
	local color = isNew and Color3.fromRGB(232, 218, 176) or Color3.fromRGB(196, 64, 64)
	local color2 = isNew and Color3.fromRGB(28, 24, 20) or Color3.fromRGB(200, 195, 185)
	local danger = isNew and pal.DANGER or Color3.fromRGB(255, 255, 255)

	local parent2 = make("Frame", { -- inferred equivalent call
		Name = "Visual",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = isNew and UDim2.new(0, 38, 0, 22) or UDim2.new(0, 22, 0, 22),
		BackgroundColor3 = tape,
		BackgroundTransparency = isNew and 0.08 or 0,
		BorderSizePixel = 0,
		Rotation = isNew and -5 or 0,
		ZIndex = 8
	}, closeButton)

	if isNew then
		make("UICorner", { CornerRadius = UDim.new(0, 1) }, parent2) -- inferred equivalent call
	else
		make("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
		make("UIStroke", { -- inferred equivalent call
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.85,
			Thickness = 1
		}, parent2)
	end

	local uiScale = make("UIScale", { Scale = 1 }, parent2) -- inferred equivalent call

	local v25 = {}

	for _, rotation in ipairs({ 45, -45 }) do
		local parent3 = make("Frame", { -- inferred equivalent call
			Name = "Bar",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = isNew and UDim2.new(0, 15, 0, 3) or UDim2.new(0, 11, 0, 2),
			Rotation = rotation,
			BackgroundColor3 = color2,
			BorderSizePixel = 0,
			ZIndex = 9
		}, parent2)

		make("UICorner", { -- inferred equivalent call
			CornerRadius = isNew and UDim.new(0, 1) or UDim.new(1, 0)
		}, parent3)
		table.insert(v25, parent3)
	end

	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local function setHover(p)
		TweenService:Create(parent2, tweenInfo, {
			BackgroundColor3 = p and color or tape
		}):Play()

		for _, instance in ipairs(v25) do
			TweenService:Create(instance, tweenInfo, {
				BackgroundColor3 = p and danger or color2
			}):Play()
		end
	end
	local function setPressed(p) -- 4 equivalent calls inferred from this helper
		TweenService:Create(uiScale, tweenInfo, {
			Scale = p and 0.9 or 1
		}):Play()
	end
	closeButton.MouseEnter:Connect(function()
		setHover(true)
	end)
	closeButton.MouseLeave:Connect(function()
		setHover(false)
		setPressed(false) -- inferred equivalent call
	end)
	closeButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			setPressed(true) -- inferred equivalent call
		end
	end)
	closeButton.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			setPressed(false) -- inferred equivalent call
		end
	end)
	closeButton.MouseButton1Click:Connect(function()
		setHover(false)
		setPressed(false) -- inferred equivalent call
		LayoutEditorUI.Hide()
	end)
	return closeButton
end

local function makeRow(parent, layoutOrder, value)
	local row = make("Frame", { -- inferred equivalent call
		Name = "Row" .. layoutOrder,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, value or 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, parent)

	make("UIListLayout", { -- inferred equivalent call
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8)
	}, row)

	return row
end

local function build()
	if v3 then
		return
	end

	v9 = currentSkin()
	name = v9.Name
	local pal = v9.Pal
	local grunge = v9.Grunge
	local isNew = v9.IsNew
	v10 = {}
	v11 = {}
	v12 = {}

	v3 = make("ScreenGui", { -- inferred equivalent call
		Name = "LayoutEditorUI",
		ResetOnSpawn = false,
		Enabled = false,
		DisplayOrder = 85,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, PlayerGui)

	v4 = make("Frame", { -- inferred equivalent call
		Name = "Root",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(8, 8, 9),
		BackgroundTransparency = isNew and 0.55 or 0.62,
		Active = true,
		ZIndex = 1
	}, v3)

	if isNew then
		local function edgeShade(name2, position, size, rotation)
			local parent = make("Frame", { -- inferred equivalent call
				Name = name2,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Active = false,
				Position = position,
				Size = size,
				ZIndex = 1
			}, v4)

			make("UIGradient", { -- inferred equivalent call
				Rotation = rotation,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.35),
					NumberSequenceKeypoint.new(1, 1)
				})
			}, parent)
		end
		edgeShade("ShadeTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 90), 90)
		edgeShade("ShadeBottom", UDim2.new(0, 0, 1, -90), UDim2.new(1, 0, 0, 90), 270)
		edgeShade("ShadeLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 90, 1, 0), 0)
		edgeShade("ShadeRight", UDim2.new(1, -90, 0, 0), UDim2.new(0, 90, 1, 0), 180)
	end

	v7 = make("Frame", { -- inferred equivalent call
		Name = "Grid",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Active = false,
		ZIndex = 2
	}, v4)

	v5 = make("Frame", { -- inferred equivalent call
		Name = "CenterGuideV",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundColor3 = pal.ACCENT,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Visible = false,
		Active = false,
		ZIndex = 3
	}, v4)

	v6 = make("Frame", { -- inferred equivalent call
		Name = "RowGuideH",
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = pal.TEXT_DIM,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		Visible = false,
		Active = false,
		ZIndex = 3
	}, v4)

	buildHandle(1)
	buildHandle(2)
	buildHandle(3)
	buildHandle(4)
	buildHandle(5)

	local parent = make("Frame", { -- inferred equivalent call
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Size = UDim2.new(0.92, 0, 0, 170),
		BackgroundColor3 = pal.BG,
		BackgroundTransparency = isNew and 0.04 or 0.02,
		BorderSizePixel = 0,
		ZIndex = 30
	}, v4)

	make("UISizeConstraint", { MaxSize = Vector2.new(480, 1e999) }, parent) -- inferred equivalent call
	make("UICorner", { CornerRadius = v9.Radius }, parent) -- inferred equivalent call
	make("UIStroke", { -- inferred equivalent call
		Color = isNew and grunge.WindowStroke or pal.BORDER,
		Thickness = isNew and 2 or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, parent)

	local uiScale = make("UIScale", { Scale = 1 }, parent) -- inferred equivalent call

	if isNew then
		buildGrungeDecor(parent)
	end

	local parent2 = make("Frame", { -- inferred equivalent call
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 2
	}, parent)

	make( -- inferred equivalent call
		"UIPadding",
		{
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16)
		},
		parent2
	)

	make( -- inferred equivalent call
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8)
		},
		parent2
	)

	make("TextLabel", { -- inferred equivalent call
		Name = "Title",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Font = v9.Head,
		TextSize = isNew and 22 or 15,
		TextColor3 = pal.ACCENT,
		Text = isNew and "EDIT LAYOUT" or "Edit Layout"
	}, parent2)

	make("Frame", { -- inferred equivalent call
		Name = "Divider",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = pal.BORDER,
		BackgroundTransparency = 0.35
	}, parent2)

	local row = makeRow(parent2, 3)
	make("TextLabel", { -- inferred equivalent call
		Name = "LanesLabel",
		LayoutOrder = 0,
		Size = UDim2.fromOffset(52, 32),
		BackgroundTransparency = 1,
		Font = v9.Body,
		TextSize = isNew and 14 or 11,
		TextColor3 = pal.TEXT_DIM,
		Text = isNew and "LANES" or "Lanes"
	}, row)

	for i, v25 in ipairs({ 2, 3, 4, 5 }) do
		v11[v25] = makeButton(row, tostring(v25), 38, i, nil, function()
			setLaneCount(v25) -- inferred equivalent call
		end)
	end

	v14 = makeButton(row, "Undo", 66, 10, nil, undo)
	v15 = makeButton(row, "Redo", 66, 11, nil, redo)

	local row2 = makeRow(parent2, 4)
	v12.Grid = makeButton(row2, "Grid", 70, 1, nil, function()
		v17 = not v17
		setToggleLook(v12.Grid, v17)
		rebuildGrid()
	end)
	v12.Snap = makeButton(row2, "Snap", 70, 2, nil, function()
		v18 = not v18
		setToggleLook(v12.Snap, v18)
	end)
	makeButton(row2, "Align Row", 100, 3, nil, alignRow)
	makeButton(row2, "Even Spacing", 118, 4, nil, evenSpacing)

	local row3 = makeRow(parent2, 5)
	makeButton(row3, "Reset Selected", 126, 1, nil, function()
		if v19 then
			resetLane(v19) -- inferred equivalent call
		end
	end)
	makeButton(row3, "Reset All", 98, 2, "danger", function()
		local v25 = readAll()
		local v26 = readAll();
		(function(vector2s)
			for i = 1, 5 do
				vector2s[i] = Vector2.new(0, 0)
			end
		end)(v26)

		if sameSnap(v25, v26) then
			return
		end

		table.insert(v22, v25)

		if #v22 > 30 then
			table.remove(v22, 1)
		end

		v23 = {}
		refreshHistoryButtons() -- inferred equivalent call
		writeAll(v26)
	end)
	makeButton(row3, "Done", 110, 3, "primary", function()
		LayoutEditorUI.Hide()
	end)

	buildCloseButton(parent)

	local function fitScale() -- 1 equivalent call inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local viewportSize = currentCamera.ViewportSize
		uiScale.Scale = math.clamp(math.min(viewportSize.Y / 420, viewportSize.X / 500), 0.62, 1)
	end

	local function syncPanelHeight() -- 1 equivalent call inferred from this helper
		local v25 = math.ceil(parent2.AbsoluteSize.Y / math.max(uiScale.Scale, 0.01))

		if v25 > 0 and parent.Size.Y.Offset ~= v25 then
			parent.Size = UDim2.new(0.92, 0, 0, v25)
		end
	end
	parent2:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncPanelHeight)
	uiScale:GetPropertyChangedSignal("Scale"):Connect(syncPanelHeight)
	fitScale() -- inferred equivalent call
	syncPanelHeight() -- inferred equivalent call

	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
	end

	local function hookCamera() -- 1 equivalent call inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale)
		end
	end

	hookCamera() -- inferred equivalent call
	local parent3 = make("Frame", { -- inferred equivalent call
		Name = "InfoBar",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -14),
		Size = UDim2.new(0.92, 0, 0, 34),
		BackgroundColor3 = pal.BG,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		ZIndex = 30
	}, v4)

	make("UISizeConstraint", { MaxSize = Vector2.new(680, 1e999) }, parent3) -- inferred equivalent call
	make("UICorner", { CornerRadius = v9.Radius }, parent3) -- inferred equivalent call
	make("UIStroke", { -- inferred equivalent call
		Color = isNew and grunge.WindowStroke or pal.BORDER,
		Thickness = isNew and 2 or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, parent3)

	if isNew then
		make("Frame", { -- inferred equivalent call
			Name = "TapeInfo",
			Position = UDim2.new(0, -10, 0, -4),
			Size = UDim2.fromOffset(34, 11),
			BackgroundColor3 = grunge.Tape,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Rotation = -32,
			Active = false,
			ZIndex = 32
		}, parent3)
	end

	v8 = make("TextLabel", { -- inferred equivalent call
		Name = "Info",
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Font = v9.Body,
		TextSize = isNew and 14 or 12,
		TextColor3 = pal.TEXT,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 31
	}, parent3)
	refreshLaneButtons() -- inferred equivalent call
	setToggleLook(v12.Grid, v17)
	setToggleLook(v12.Snap, v18)
	refreshHistoryButtons() -- inferred equivalent call
end

local function step()
	if not flag then
		return
	end

	local absolutePosition = v4.AbsolutePosition

	for i = 1, 5 do
		local v25 = v10[i]
		local v26

		if i <= v16 then
			v26 = v.GetHitContainer(i) or nil
		end

		if v26 and v26.Parent then
			local absoluteSize = v26.AbsoluteSize
			local v27 = v26.AbsolutePosition + absoluteSize / 2 - absolutePosition
			v25.Frame.Visible = true
			v25.Frame.Size = UDim2.fromOffset(math.max(24, absoluteSize.X - 8), (math.max(24, absoluteSize.Y - 8)))
			v25.Frame.Position = UDim2.fromOffset(v27.X, v27.Y)

			if v19 == i then
				local buttonPositionOffset = SettingsState.GetButtonPositionOffset(i)
				v25.Coord.Text = string.format("X %+d   Y %+d", buttonPositionOffset.X, buttonPositionOffset.Y)
			end
		else
			v25.Frame.Visible = false
		end
	end

	if v19 then
		v8.Text = string.format(
			"Lane %d selected - drag to move, double-tap to reset, arrow keys nudge (Shift = 10)",
			v19
		)
	else
		v8.Text = "Drag a button to move it. Tap one to select it, double-tap to reset it."
	end

	local hitContainer = v.GetHitContainer(1)

	if hitContainer then
		local v25 = scaleOf(hitContainer) -- inferred equivalent call
		local v26 = hitContainer.AbsolutePosition.Y + hitContainer.AbsoluteSize.Y / 2 - absolutePosition.Y - SettingsState.GetButtonPositionOffset(1).Y * v25
		v6.Position = UDim2.fromOffset(0, v26 - 1)

		if v17 and v24 and math.abs(v24 - v25) > 0.001 then
			rebuildGrid()
		end
	end

	if not v20 then
		v5.Visible = true
		v5.BackgroundTransparency = 0.8
		v6.Visible = true
	end
end

UserInputService.InputChanged:Connect(function(input)
	if
		v20
		and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
	then
		updateDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		endDrag() -- inferred equivalent call
	end
end)

local vector2s = {
	[Enum.KeyCode.Left] = Vector2.new(-1, 0),
	[Enum.KeyCode.Right] = Vector2.new(1, 0),
	[Enum.KeyCode.Up] = Vector2.new(0, -1),
	[Enum.KeyCode.Down] = Vector2.new(0, 1)
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not flag or gameProcessed or not v19 then
		return
	end

	local v25 = vector2s[input.KeyCode]

	if not v25 then
		return
	end

	local v26 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 10 or 1
	local v27 = v19
	local function fn(vector2s2)
		local v28 = vector2s2[v27] + v25 * v26
		vector2s2[v27] = Vector2.new(math.clamp(v28.X, -500, 500), (math.clamp(v28.Y, -400, 400)))
	end

	applyChange(fn) -- inferred equivalent call
end)

local function showNotice(text)
	local v25 = currentSkin()
	local pal = v25.Pal
	local grunge = v25.Grunge
	local parent = make( -- inferred equivalent call
		"ScreenGui",
		{
			Name = "LayoutEditorNotice",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 90
		},
		PlayerGui
	)

	local parent2 = make("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 60),
		Size = UDim2.fromOffset(340, 38),
		BackgroundColor3 = pal.BG,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0
	}, parent)

	make("UICorner", { CornerRadius = v25.Radius }, parent2) -- inferred equivalent call
	make("UIStroke", { -- inferred equivalent call
		Color = v25.IsNew and grunge.WindowStroke or pal.BORDER,
		Thickness = v25.IsNew and 2 or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, parent2)

	make("TextLabel", { -- inferred equivalent call
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Font = v25.Body,
		TextSize = v25.IsNew and 14 or 12,
		TextColor3 = pal.TEXT,
		TextWrapped = true,
		Text = text
	}, parent2)

	Debris:AddItem(parent, 2.5)
end

function LayoutEditorUI.IsOpen()
	return flag
end

function LayoutEditorUI.Show()
	if flag then
		return
	end

	v = v or require(ReplicatedStorage.Modules.NoteLaneUI)
	v2 = v2 or require(ReplicatedStorage.Modules.ColorsPreview)

	if v3 and name ~= currentSkin().Name then
		v3:Destroy()
		v3 = nil
		v13 = setmetatable({}, { __mode = "k" })
	end

	build()

	if v2.IsActive() then
		v2.Stop()
	end

	if not v2.CanStart() then
		showNotice("Layout can't be edited while a song is playing")
		return
	end

	if not v2.Start(v16, v) then
		showNotice("Layout editor is unavailable right now")
		return
	end

	v22 = {}
	v23 = {}
	refreshHistoryButtons() -- inferred equivalent call
	v20 = nil
	v19 = nil

	styleHandle(1)
	styleHandle(2)
	styleHandle(3)
	styleHandle(4)
	styleHandle(5)

	flag = true
	v3.Enabled = true
	refreshLaneButtons() -- inferred equivalent call
	rebuildGrid()
	renderSteppedConnection = RunService.RenderStepped:Connect(step)
end

function LayoutEditorUI.Hide()
	if not flag then
		return
	end

	flag = false
	v20 = nil

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v2 then
		v2.Stop()
	end

	if v3 then
		v3.Enabled = false
	end

	SettingsState.FlushPending()
end

task.defer(function()
	v2 = v2 or require(ReplicatedStorage.Modules.ColorsPreview)
	v2.OnStopped(function()
		if flag then
			LayoutEditorUI.Hide()
		end
	end)
end)

return LayoutEditorUI