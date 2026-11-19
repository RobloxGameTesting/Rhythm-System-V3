local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local ToastStyle = require(script.Parent:WaitForChild("SongListUI"):WaitForChild("ToastStyle"))
local mk = ToastStyle.mk
local z = ToastStyle.Z

local v = { below = "▲", above = "▼", right = "◀", left = "▶" }

local TutorialSpotlight = {}
TutorialSpotlight.__index = TutorialSpotlight

local v2 = 0
function TutorialSpotlight.AnyShowing(): boolean
	return v2 > 0
end

local function esc(value)
	return (tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

TutorialSpotlight.Escape = esc

local function resolveTarget(target) -- 1 equivalent call inferred from this helper
	if typeof(target) ~= "function" then
		return target
	end

	local success, result = pcall(target)
	return success and result or nil
end

local function isShown(guiObject): boolean
	if typeof(guiObject) ~= "Instance" or not guiObject:IsA("GuiObject") then
		return false
	end

	local instance = guiObject

	while instance do
		if instance:IsA("GuiObject") and not instance.Visible then
			return false
		end

		if instance:IsA("LayerCollector") then
			return not not instance.Enabled and guiObject.AbsoluteSize.X > 1 and guiObject.AbsoluteSize.Y > 1
		end

		instance = instance.Parent
	end

	return false
end

TutorialSpotlight.IsShown = isShown

function TutorialSpotlight.new(p, value)
	local self = setmetatable({}, TutorialSpotlight)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = value or "TutorialSpotlightGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.DisplayOrder = 160
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = false
	screenGui.Parent = p or Players.LocalPlayer:WaitForChild("PlayerGui")

	local root = mk("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1
	}, screenGui)

	local screenGui2 = Instance.new("ScreenGui")
	screenGui2.Name = (value or "TutorialSpotlightGui") .. "Probe"
	screenGui2.ResetOnSpawn = false
	screenGui2.IgnoreGuiInset = true
	screenGui2.DisplayOrder = 0
	screenGui2.Parent = p or Players.LocalPlayer:WaitForChild("PlayerGui")
	local probe = mk(
		"Frame",
		{
			Name = "Probe",
			Size = UDim2.fromOffset(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		},
		screenGui2
	)

	local dims = {}

	for _, name in ipairs({ "DimTop", "DimBottom", "DimLeft", "DimRight" }) do
		dims[name] = mk("Frame", {
			Name = name,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.42,
			BorderSizePixel = 0,
			ZIndex = 1,
			Active = false,
			Visible = false
		}, root)
	end

	local ring = mk("Frame", {
		Name = "Ring",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Visible = false
	}, root)
	local ringStroke = mk("UIStroke", { Thickness = 3, Color = ToastStyle.AMBER, Transparency = 0 }, ring)
	mk("UICorner", { CornerRadius = UDim.new(0, 10) }, ring)
	ToastStyle.addTape(ring, UDim2.new(0, 10, 0, 1), Vector2.new(30, 10), -28)
	ToastStyle.addTape(ring, UDim2.new(1, -10, 1, -1), Vector2.new(30, 10), -28)
	local pulse = mk("Frame", {
		Name = "Pulse",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
		Visible = false
	}, root)
	local pulseStroke = mk("UIStroke", {
		Thickness = 2,
		Color = ToastStyle.AMBER,
		Transparency = 0.4
	}, pulse)
	mk("UICorner", { CornerRadius = UDim.new(0, 14) }, pulse)

	local arrow = mk("TextLabel", {
		Name = "Arrow",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(34, 34),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Font = Enum.Font.GothamBold,
		TextSize = 30,
		TextColor3 = ToastStyle.AMBER,
		Text = "▲",
		TextStrokeTransparency = 0.35,
		TextStrokeColor3 = ToastStyle.DARK,
		ZIndex = z + 10,
		Visible = false
	}, root)

	self._gui = screenGui
	self._probeGui = screenGui2
	self._probe = probe
	self._root = root
	self._dims = dims
	self._ring = ring
	self._ringStroke = ringStroke
	self._pulse = pulse
	self._pulseStroke = pulseStroke
	self._arrow = arrow
	self._opts = nil
	self._card = nil
	self._conn = nil
	self._lastKey = nil
	self._lostTimer = 0
	self._side = "below"
	self._cardSize = Vector2.new(360, 120)
	self._arrowBase = Vector2.zero
	return self
end

function TutorialSpotlight:IsShowing(): boolean
	return self._opts ~= nil
end

function TutorialSpotlight:GetCard()
	return self._card and self._card.Card or nil
end

function TutorialSpotlight:_clearCard()
	if self._card then
		self._card.Card:Destroy()
		self._card = nil
		self._bodyLabel = nil
	end
end

function TutorialSpotlight:_buildCard(data)
	local absoluteSize = self._gui.AbsoluteSize
	local v3 = absoluteSize.X < 560
	local width = v3 and math.clamp(absoluteSize.X - 24, 240, 340) or 360
	local v4 = width - 34
	local textSize = v3 and 19 or 22
	local textSize2 = v3 and 12 or 13
	local v5 = TextService:GetTextSize(data.title, textSize, Enum.Font.PermanentMarker, Vector2.new(v4, 1000)).Y + 4
	local v6 = TextService:GetTextSize(
		tostring(data.body or ""):gsub("<[^>]->", ""),
		textSize2,
		Enum.Font.SpecialElite,
		Vector2.new(v4, 1000)
	).Y + 4
	local v7 = data.buttons and #data.buttons > 0
	local height = 22 + v5 + 6 + v6 + (v7 and 34 or 0) + 14

	local accent = data.accent or ToastStyle.AMBER
	local card = ToastStyle.buildCard({
		name = "TutorialCard",
		width = width,
		height = height,
		rotation = -1.2,
		accent = accent,
		tape = "both",
		tag = data.tag,
		seed = 313,
		padL = 18,
		padR = 16,
		padT = 20,
		padB = 14,
		vertical = true,
		gap = 6,
		parent = self._root
	})

	local content = card.Content
	mk("TextLabel", {
		Name = "Title",
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, v5),
		Font = Enum.Font.PermanentMarker,
		TextSize = textSize,
		TextColor3 = accent,
		Text = data.title,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = z + 4
	}, content)

	self._bodyLabel = mk("TextLabel", {
		Name = "Body",
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, v6),
		Font = Enum.Font.SpecialElite,
		TextSize = textSize2,
		TextColor3 = ToastStyle.INK,
		Text = data.body or "",
		RichText = true,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = z + 4
	}, content)

	if v7 then
		local v8 = mk("Frame", {
			Name = "Buttons",
			LayoutOrder = 3,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			ZIndex = z + 3
		}, content)
		mk(
			"UIListLayout",
			{
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			},
			v8
		)

		for i, button in ipairs(data.buttons) do
			ToastStyle.makeButton(
				v8,
				button.text,
				nil,
				i,
				button.color or ToastStyle.PLATE_LIGHT,
				button.textColor or ToastStyle.INK,
				0,
				26
			).Activated:Connect(function()
				if button.onClick then
					button.onClick()
				end
			end)
		end
	end

	card.Card.Visible = false
	self._card = card
	self._cardSize = Vector2.new(width, height)
end

function TutorialSpotlight:_placeCard(data, p)
	local x = self._cardSize.X
	local y = self._cardSize.Y
	local function clampX(value) -- 3 equivalent calls inferred from this helper
		return (math.clamp(value, 8, (math.max(8, p.X - x - 8))))
	end
	local function clampY(value) -- 3 equivalent calls inferred from this helper
		return (math.clamp(value, 8, (math.max(8, p.Y - y - 8))))
	end
	local v3 = data.x + data.w / 2
	local v4 = data.y + data.h / 2
	local v5 = {
		below = function()
			local v5 = data.y + data.h + 44
			return v5 + y <= p.Y - 8 and Vector2.new(clampX(v3 - x / 2), v5) or nil -- inferred equivalent call
		end,
		above = function()
			local v5 = data.y - 44 - y
			return v5 >= 8 and Vector2.new(clampX(v3 - x / 2), v5) or nil -- inferred equivalent call
		end,
		right = function()
			local v5 = data.x + data.w + 44
			return v5 + x <= p.X - 8 and Vector2.new(v5, clampY(v4 - y / 2)) or nil -- inferred equivalent call
		end,
		left = function()
			local v5 = data.x - 44 - x
			return v5 >= 8 and Vector2.new(v5, clampY(v4 - y / 2)) or nil -- inferred equivalent call
		end
	}

	local side = self._opts.side or "auto"
	local v6 = { "below", "above", "right", "left" }

	if side ~= "auto" and v5[side] then
		table.insert(v6, 1, side)
	end

	local v7 = nil
	local side2 = nil

	for _, v8 in ipairs(v6) do
		v7 = v5[v8]()

		if v7 then
			side2 = v8
			break
		end
	end

	if not v7 then
		side2 = data.y + data.h / 2 < p.Y / 2 and "below" or "above"
		v7 = Vector2.new(clampX(v3 - x / 2), clampY(side2 == "below" and data.y + data.h + 44 or data.y - 44 - y)) -- inferred equivalent call
	end

	self._side = side2
	self._card.Card.Position = UDim2.fromOffset(v7.X, v7.Y)
	local v8, v9

	if side2 == "below" then
		v8 = math.clamp(v3, v7.X + 24, v7.X + x - 24)
		v9 = data.y + data.h + 22 - 2
	elseif side2 == "above" then
		v8 = math.clamp(v3, v7.X + 24, v7.X + x - 24)
		v9 = data.y - 22 + 2
	else
		if side2 == "right" then
			v8 = data.x + data.w + 22 - 2
		else
			v8 = data.x - 22 + 2
		end

		v9 = math.clamp(v4, v7.Y + 24, v7.Y + y - 24)
	end

	self._arrowBase = Vector2.new(v8, v9)
	self._arrow.Text = v[side2]
end

function TutorialSpotlight:_layout(p, p2, p3)
	local padding = self._opts.padding or 8
	local pulseBase = {
		x = p.X - padding,
		y = p.Y - padding,
		w = p2.X + padding * 2,
		h = p2.Y + padding * 2
	}

	local dims = self._dims
	local v3 = pulseBase.y + pulseBase.h
	local v4 = pulseBase.x + pulseBase.w
	dims.DimTop.Position = UDim2.fromOffset(-400, -400)
	dims.DimTop.Size = UDim2.fromOffset(p3.X + 800, (math.max(0, pulseBase.y + 400)))
	dims.DimBottom.Position = UDim2.fromOffset(-400, v3)
	dims.DimBottom.Size = UDim2.fromOffset(p3.X + 800, (math.max(0, p3.Y - v3 + 400)))
	dims.DimLeft.Position = UDim2.fromOffset(-400, pulseBase.y)
	dims.DimLeft.Size = UDim2.fromOffset(math.max(0, pulseBase.x + 400), pulseBase.h)
	dims.DimRight.Position = UDim2.fromOffset(v4, pulseBase.y)
	dims.DimRight.Size = UDim2.fromOffset(math.max(0, p3.X - v4 + 400), pulseBase.h)

	self._ring.Position = UDim2.fromOffset(pulseBase.x, pulseBase.y)
	self._ring.Size = UDim2.fromOffset(pulseBase.w, pulseBase.h)
	self._pulseBase = pulseBase
	self:_placeCard(pulseBase, p3)
end

function TutorialSpotlight:_onScreen(p): boolean
	local absolutePosition = self._probe.AbsolutePosition
	local absoluteSize = self._probeGui.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return true
	end

	local absolutePosition2 = p.AbsolutePosition
	local absoluteSize2 = p.AbsoluteSize
	local v3 = math.min(absolutePosition2.X + absoluteSize2.X, absolutePosition.X + absoluteSize.X) - math.max(absolutePosition2.X, absolutePosition.X)
	local v4 = math.min(absolutePosition2.Y + absoluteSize2.Y, absolutePosition.Y + absoluteSize.Y) - math.max(absolutePosition2.Y, absolutePosition.Y)
	return not (v3 <= 0 or v4 <= 0) and v3 * v4 >= 0.4 * absoluteSize2.X * absoluteSize2.Y
end

local function scrollIntoView(target)
	local scrollingFrame = target:FindFirstAncestorWhichIsA("ScrollingFrame")

	if not scrollingFrame then
		return
	end

	local absolutePosition = target.AbsolutePosition
	local absoluteSize = target.AbsoluteSize
	local absolutePosition2 = scrollingFrame.AbsolutePosition
	local absoluteSize2 = scrollingFrame.AbsoluteSize

	local v3 = 0
	local v4 = 0

	if absolutePosition.Y < absolutePosition2.Y + 12 then
		v4 = absolutePosition.Y - absolutePosition2.Y - 12
	elseif absolutePosition.Y + absoluteSize.Y > absolutePosition2.Y + absoluteSize2.Y - 12 then
		v4 = absolutePosition.Y + absoluteSize.Y - (absolutePosition2.Y + absoluteSize2.Y) + 12
	end

	if absolutePosition.X < absolutePosition2.X + 12 then
		v3 = absolutePosition.X - absolutePosition2.X - 12
	elseif absolutePosition.X + absoluteSize.X > absolutePosition2.X + absoluteSize2.X - 12 then
		v3 = absolutePosition.X + absoluteSize.X - (absolutePosition2.X + absoluteSize2.X) + 12
	end

	if v3 ~= 0 or v4 ~= 0 then
		local canvasPosition = scrollingFrame.CanvasPosition
		scrollingFrame.CanvasPosition = Vector2.new(
			math.max(0, canvasPosition.X + v3),
			(math.max(0, canvasPosition.Y + v4))
		)
	end
end

function TutorialSpotlight:_stepFloating(p)
	local absoluteSize = self._gui.AbsoluteSize
	local lastKey = string.format("f%d,%d", absoluteSize.X, absoluteSize.Y)

	if lastKey == self._lastKey then
		return
	end

	self._lastKey = lastKey
	local x = self._cardSize.X
	local y = self._cardSize.Y
	local anchor = p.anchor or "bottom"
	local v3

	if anchor == "top" then
		v3 = 70
	elseif anchor == "center" then
		v3 = (absoluteSize.Y - y) / 2
	else
		v3 = absoluteSize.Y - y - 110
	end

	self._card.Card.Position = UDim2.fromOffset(math.max(8, (absoluteSize.X - x) / 2), (math.max(8, v3)))
	self._card.Card.Visible = true
end

function TutorialSpotlight:_step(value)
	local opts = self._opts

	if not opts then
		return
	end

	if opts.target == nil then
		self:_stepFloating(opts)
		return
	end

	local target = resolveTarget(opts.target) -- inferred equivalent call

	if target and not self._scrolled and isShown(target) then
		self._scrolled = true
		scrollIntoView(target)
	end

	if target and isShown(target) and self:_onScreen(target) then
		self._lostTimer = 0

		local absolutePosition = target.AbsolutePosition
		local absoluteSize = target.AbsoluteSize
		local absoluteSize2 = self._gui.AbsoluteSize
		local lastKey = string.format(
			"%.1f,%.1f,%.1f,%.1f,%d,%d",
			absolutePosition.X,
			absolutePosition.Y,
			absoluteSize.X,
			absoluteSize.Y,
			absoluteSize2.X,
			absoluteSize2.Y
		)

		if lastKey ~= self._lastKey then
			self._lastKey = lastKey
			self:_layout(absolutePosition, absoluteSize, absoluteSize2)
			self._card.Card.Visible = true
			self._ring.Visible = true
			self._pulse.Visible = true
			self._arrow.Visible = true
		end

		local now = os.clock()
		local v3 = math.sin(now * 4.2) * 0.5 + 0.5
		local pulseBase = self._pulseBase

		if pulseBase then
			local v4 = v3 * 9 + 3
			self._pulse.Position = UDim2.fromOffset(pulseBase.x - v4, pulseBase.y - v4)
			self._pulse.Size = UDim2.fromOffset(pulseBase.w + v4 * 2, pulseBase.h + v4 * 2)
			self._pulseStroke.Transparency = v3 * 0.7 + 0.25
		end

		local v4 = math.sin(now * 5.5) * 4
		local arrowBase = self._arrowBase
		local side = self._side

		if side == "below" then
			self._arrow.Position = UDim2.fromOffset(arrowBase.X, arrowBase.Y + v4)
		elseif side == "above" then
			self._arrow.Position = UDim2.fromOffset(arrowBase.X, arrowBase.Y - v4)
		elseif side == "right" then
			self._arrow.Position = UDim2.fromOffset(arrowBase.X + v4, arrowBase.Y)
		else
			self._arrow.Position = UDim2.fromOffset(arrowBase.X - v4, arrowBase.Y)
		end
	else
		self._lostTimer += value or 1 / 60

		if self._lostTimer > 0.9 then
			local onTargetLost = opts.onTargetLost
			self:Hide()

			if onTargetLost then
				onTargetLost()
			end
		end
	end
end

function TutorialSpotlight:Show(opts)
	assert(opts and opts.title, "TutorialSpotlight:Show butuh title")
	self:_clearCard()

	if not self._opts then
		v2 += 1
	end

	self._opts = opts
	self._showToken = (self._showToken or 0) + 1
	local showToken = self._showToken
	self._lastKey = nil
	self._lostTimer = 0
	self._scrolled = false

	local accent = opts.accent or ToastStyle.AMBER
	self._ringStroke.Color = accent
	self._pulseStroke.Color = accent
	self._arrow.TextColor3 = accent
	local visible

	if opts.dim == false then
		visible = false
	else
		visible = opts.target ~= nil
	end

	local v3 = opts.block

	if v3 == nil then
		v3 = visible
	end

	for _, dim in pairs(self._dims) do
		dim.Visible = visible
		dim.Active = v3 and visible
	end

	self._ring.Visible = false
	self._pulse.Visible = false
	self._arrow.Visible = false

	self._gui.Enabled = true
	self:_buildCard(opts)

	if not self._conn then
		self._conn = RunService.Heartbeat:Connect(function(dt)
			self:_step(dt)
		end)
	end

	self:_step()

	if self._card and self._card.Card.Visible then
		ToastStyle.popIn(self._card)
	end

	if opts.autoHide then
		task.delay(opts.autoHide, function()
			if self._showToken == showToken and self._opts == opts then
				local onAutoHide = opts.onAutoHide
				self:Hide()

				if onAutoHide then
					onAutoHide()
				end
			end
		end)
	end
end

function TutorialSpotlight:SetBody(text)
	if self._bodyLabel then
		self._bodyLabel.Text = text
	end
end

function TutorialSpotlight:Hide()
	if self._opts then
		v2 = math.max(0, v2 - 1)
	end

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	self._opts = nil
	self._lastKey = nil

	for _, dim in pairs(self._dims) do
		dim.Visible = false
		dim.Active = false
	end

	self._ring.Visible = false
	self._pulse.Visible = false
	self._arrow.Visible = false
	self:_clearCard()
	self._gui.Enabled = false
end

function TutorialSpotlight:Destroy()
	self:Hide()
	self._gui:Destroy()
	self._probeGui:Destroy()
end

return TutorialSpotlight