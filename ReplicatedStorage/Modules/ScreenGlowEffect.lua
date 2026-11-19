local RunService = game:GetService("RunService")

local v = {
	{ 460, 0.96 },
	{ 360, 0.93 },
	{ 270, 0.88 },
	{ 190, 0.8 },
	{ 110, 0.62 }
}

local object = setmetatable({}, { __mode = "k" })
local v2 = {}
local v3 = 0
local renderSteppedConnection = nil

local function newCircle(parent)
	local glowRing = Instance.new("Frame")
	glowRing.Name = "GlowRing"
	glowRing.AnchorPoint = Vector2.new(0.5, 0.5)
	glowRing.BackgroundTransparency = 1
	glowRing.BorderSizePixel = 0
	glowRing.ZIndex = 0
	glowRing.Visible = false
	glowRing.Parent = parent
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = glowRing
	return glowRing
end

local function newUnit(parent)
	local unit = {
		halos = {},
		targets = {},
		start = 0,
		k = 1,
		n = 0,
		pos = Vector2.zero,
		scale = 1,
		active = false
	}

	for i = 1, #v do
		unit.halos[i] = newCircle(parent)
	end

	unit.core = newCircle(parent)
	unit.ring = newCircle(parent)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Parent = unit.ring
	unit.stroke = uiStroke
	return unit
end

local function getPool(parent)
	local pool = object[parent]

	if pool and pool[1] and pool[1].halos[1].Parent ~= parent then
		pool = nil
	end

	if pool then
		return pool
	end

	pool = {}

	pool[1] = newUnit(parent)
	pool[2] = newUnit(parent)
	pool[3] = newUnit(parent)

	object[parent] = pool

	return pool
end

local function setVisible(data, visible) -- 2 equivalent calls inferred from this helper
	for _, halo in ipairs(data.halos) do
		halo.Visible = visible
	end

	data.core.Visible = visible and true
	data.ring.Visible = visible and false
end

local function deactivate(data) -- 1 equivalent call inferred from this helper
	if data.active then
		data.active = false
		v2[data] = nil
		v3 -= 1
	end

	setVisible(data, false) -- inferred equivalent call
end

local function applyPosition(data) -- 2 equivalent calls inferred from this helper
	local udim = UDim2.fromOffset(data.pos.X, data.pos.Y)

	for _, halo in ipairs(data.halos) do
		halo.Position = udim
	end

	data.core.Position = udim
	data.ring.Position = udim
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function stepUnit(data, now)
	local v4 = (now - data.start) / 0.38

	if v4 >= 1 then
		deactivate(data) -- inferred equivalent call
	else
		local v5

		if v4 < 0.25 then
			v5 = v4 / 0.25
		else
			local v6 = 1 - (v4 - 0.25) / 0.75
			v5 = v6 * v6
		end

		local v6 = data.k * v5

		for i, halo in ipairs(data.halos) do
			halo.BackgroundTransparency = 1 - (1 - data.targets[i]) * v6
		end

		local v7 = math.min((now - data.start) / 0.16, 1)

		if v7 >= 1 then
			data.core.Visible = false
		else
			local v8 = 52 * data.scale * (1 + 0.5 * v7)
			data.core.Size = UDim2.fromOffset(v8, v8)
			local core = data.core
			local v9 = 1 - math.min(data.k, 1) * 0.55
			local v10 = v7 * v7
			core.BackgroundTransparency = v9 + (1 - v9) * v10
		end

		math.min((now - data.start) / 0.32, 1)
	end
end

local function step()
	local now = os.clock()

	for k in pairs(v2) do
		stepUnit(k, now)
	end

	if v3 <= 0 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

return {
	Spawn = function(parent, pos, backgroundColor, value)
		if not parent then
			return
		end

		local now = os.clock()
		local pool = getPool(parent)
		local v4 = nil
		local flag = false

		for _, v5 in ipairs(pool) do
			if v5.active and now - v5.start < 0.06 then
				v4 = v5
				flag = true
				break
			end
		end

		if not v4 then
			for _, v5 in ipairs(pool) do
				if not v5.active then
					v4 = v5
					break
				end
			end
		end

		if not v4 then
			v4 = pool[1]

			for _, v5 in ipairs(pool) do
				if v5.start < v4.start then
					v4 = v5
				end
			end
		end

		local y = parent.AbsoluteSize.Y
		local scale = (y > 0 and math.clamp(y / 1080, 0.5, 1.3) or 1) * (value or 1) * 1

		if flag then
			v4.pos = (v4.pos * v4.n + pos) / (v4.n + 1)
			v4.n += 1
			v4.k = math.min(v4.k + 0.12, 1.35)
			applyPosition(v4) -- inferred equivalent call
		else
			v4.k = 1 / (math.max(v3, 0) * 0.3 + 1)
			v4.n = 1
			v4.pos = pos
			v4.scale = scale
			v4.start = now

			for i, v5 in ipairs(v) do
				local halo = v4.halos[i]
				local v6 = v5[1] * scale * 1.9
				halo.Size = UDim2.fromOffset(v6, v6)
				halo.BackgroundColor3 = backgroundColor
				halo.BackgroundTransparency = 1
				v4.targets[i] = v5[2]
			end

			v4.core.BackgroundColor3 = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.65)
			v4.core.BackgroundTransparency = 1
			v4.ring.BackgroundTransparency = 1
			v4.stroke.Color = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.35)
			applyPosition(v4) -- inferred equivalent call
			setVisible(v4, true) -- inferred equivalent call

			if not v4.active then
				v4.active = true
				v2[v4] = true
				v3 += 1
			end

			if not renderSteppedConnection then
				renderSteppedConnection = RunService.RenderStepped:Connect(step)
			end
		end
	end
}