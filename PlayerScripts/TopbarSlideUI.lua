local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = {
	{ "SettingsMenuUI", "GearButton" },
	{ "AudioModeToggleButtonGui", "AudioModeButton" },
	{ "FPPToggleTopbarUI", "FPPToggleButton" },
	{ "KeyModeToggleUI", "KeyModeButton" },
	{ "KeyModeToggleUI", "DifficultyButton" },
	{ "ServerBrowserUI", "ServersButton" },
	{ "EquipmentUI", "EquipmentButton" }
}

local v2 = {
	{ "BandCameraUI", "CameraButton" },
	{ "BandCameraUI", "FxButton" }
}

local color = Color3.fromRGB(23, 23, 27)
local color2 = Color3.fromRGB(60, 60, 70)
local color3 = Color3.fromRGB(245, 245, 247)

local topbarSlideUI = Instance.new("ScreenGui")
topbarSlideUI.Name = "TopbarSlideUI"
topbarSlideUI:SetAttribute("NoNewUISkin", true)
topbarSlideUI.ResetOnSpawn = false
topbarSlideUI.IgnoreGuiInset = true
topbarSlideUI.DisplayOrder = 102
topbarSlideUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
topbarSlideUI.Parent = PlayerGui

local handle = Instance.new("CanvasGroup")
handle.Name = "Handle"
handle:SetAttribute("NoNewUISkin", true)
handle.BackgroundTransparency = 1
handle.GroupTransparency = 0.18
handle.Size = UDim2.fromOffset(20, 30)
handle.Visible = false
handle.Parent = topbarSlideUI

local body = Instance.new("Frame")
body.Name = "Body"
body.BackgroundColor3 = color
body.BorderSizePixel = 0
body.Size = UDim2.fromScale(1, 1)
body.Parent = handle

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = body
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = color2
uiStroke.Transparency = 0.5
uiStroke.Thickness = 1
uiStroke.Parent = body

local function makeBar(name, p)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, p)
	frame.Size = UDim2.fromOffset(9, 2.5)
	frame.BackgroundColor3 = color3
	frame.BorderSizePixel = 0
	frame.ZIndex = 3
	frame.Parent = body
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(1, 0)
	uiCorner2.Parent = frame
	return frame
end

local bar = makeBar("ChevTop", -3.2)
local bar2 = makeBar("ChevBottom", 3.2)

local hit = Instance.new("TextButton")
hit.Name = "Hit"
hit:SetAttribute("NoNewUISkin", true)
hit.Text = ""
hit.AutoButtonColor = false
hit.BackgroundTransparency = 1
hit.Size = UDim2.fromScale(1, 1)
hit.ZIndex = 6
hit.Parent = handle

local v3 = true
local from = 1
local v4 = nil
local v5 = false
local v6 = nil
local v7 = nil

PlayerGui:SetAttribute("TopbarHidden", false)

local function refreshFade()
	local groupTransparency = v5 and 0.02 or v3 and 0.18 or 0.1

	if groupTransparency == v7 then
		return
	end

	v7 = groupTransparency

	if v6 then
		v6:Cancel()
	end

	v6 = TweenService:Create(handle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = groupTransparency
	})
	v6:Play()
end

local function setOpen(p)
	if p == v3 then
		return
	end

	v3 = p
	PlayerGui:SetAttribute("TopbarHidden", not p)
	v4 = {
		from = from,
		to = p and 1 or 0,
		t0 = os.clock(),
		dur = p and 0.55 or 0.36,
		style = p and Enum.EasingStyle.Back or Enum.EasingStyle.Cubic,
		dir = p and Enum.EasingDirection.Out or Enum.EasingDirection.InOut
	}

	refreshFade()
end

hit.Activated:Connect(function()
	setOpen(not v3)
end)

PlayerGui:GetAttributeChangedSignal("TopbarHidden"):Connect(function()
	setOpen(PlayerGui:GetAttribute("TopbarHidden") ~= true)
end)
hit.MouseEnter:Connect(function()
	v5 = true
	refreshFade()
end)
hit.MouseLeave:Connect(function()
	v5 = false
	refreshFade()
end)

local v8 = {}
local v9 = 0

local function writeShift(p, p2, p3)
	local base = p2.base

	if p3 == 0 then
		p2.last = nil

		if p.Position ~= base then
			p.Position = base
		end
	else
		local udim = UDim2.new(base.X.Scale, base.X.Offset + p3, base.Y.Scale, base.Y.Offset)
		p2.last = udim

		if p.Position ~= udim then
			p.Position = udim
		end
	end
end

local function track(guiObject)
	local v10 = { base = guiObject.Position, last = nil }
	v10.conn = guiObject:GetPropertyChangedSignal("Position"):Connect(function()
		local position = guiObject.Position

		if v10.last ~= nil and position == v10.last or v10.last == nil and position == v10.base then
			return
		end

		v10.base = position

		if v9 ~= 0 then
			writeShift(guiObject, v10, v9)
		end
	end)

	if v9 ~= 0 then
		writeShift(guiObject, v10, v9)
	end

	return v10
end

local function resolve(list, root)
	for _, item in ipairs(list) do
		local v10 = item[1] .. "/" .. item[2]
		local v11 = v8[v10]

		if v11 and not v11.btn:IsDescendantOf(game) then
			if v11.rec and v11.rec.conn then
				v11.rec.conn:Disconnect()
			end

			v8[v10] = nil
			v11 = nil
		end

		if v11 then
			continue
		end

		local child = PlayerGui:FindFirstChild(item[1])
		local guiObject = child and child:FindFirstChild(item[2])

		if guiObject and guiObject:IsA("GuiObject") then
			v8[v10] = {
				btn = guiObject,
				root = root,
				rec = root and track(guiObject) or nil
			}
		end
	end
end

local function isShown(btn): boolean -- 1 equivalent call inferred from this helper
	if not btn.Visible then
		return false
	end

	local screenGui = btn:FindFirstAncestorOfClass("ScreenGui")
	return not (screenGui and not screenGui.Enabled) and btn.AbsoluteSize.X > 0
end

local v10 = nil
local v11 = 30
local v12 = 18

local function step()
	resolve(v, true)
	resolve(v2, false)

	if v4 then
		local v13 = math.clamp((os.clock() - v4.t0) / v4.dur, 0, 1)
		local value = TweenService:GetValue(v13, v4.style, v4.dir)
		from = v4.from + (v4.to - v4.from) * value

		if v13 >= 1 then
			from = v4.to
			v4 = nil
		end
	end

	local v13 = nil
	local y = nil
	local v14 = nil

	for _, v15 in pairs(v8) do
		local btn = v15.btn

		if not isShown(btn) then -- inferred equivalent call
			continue
		end

		local v16 = btn.AbsolutePosition.X - v9

		if not (v13 == nil or v16 < v13) then
			continue
		end

		y = btn.AbsoluteSize.Y

		local y2 = btn.Position.Y
		v14 = y2.Offset + y2.Scale * topbarSlideUI.AbsoluteSize.Y + (0.5 - btn.AnchorPoint.Y) * btn.AbsoluteSize.Y
		v13 = v16
	end

	if v13 then
		local v15 = math.max(y, 24)
		v10 = v13
		v11 = v15
		v12 = v14
	end

	local x = topbarSlideUI.AbsoluteSize.X

	if x <= 0 then
		return
	end

	local v15 = v10 and x - v10 + 2 or 0
	local v16 = math.floor((1 - from) * v15 + 0.5)

	if v16 ~= v9 then
		v9 = v16

		for _, v17 in pairs(v8) do
			if v17.rec then
				writeShift(v17.btn, v17.rec, v16)
			end
		end
	end

	local visible = v13 ~= nil
	handle.Visible = visible

	if visible then
		handle.Size = UDim2.fromOffset(20, v11)
		handle.Position = UDim2.fromOffset(math.floor(v10 + v9 - 8 - 20), (math.floor(v12 - v11 / 2)))
	end

	local v17 = math.clamp(from, 0, 1)
	bar.Rotation = 45 - (1 - v17) * 90
	bar2.Rotation = (1 - v17) * 90 + -45
end

RunService:BindToRenderStep("TopbarSlideUI", Enum.RenderPriority.Last.Value, step)