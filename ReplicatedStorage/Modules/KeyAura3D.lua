local KeyAura3D = {}
KeyAura3D.__index = KeyAura3D

local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(92, 84, 76)
local color3 = Color3.fromRGB(255, 244, 214)
local color4 = Color3.fromRGB(255, 150, 40)
local color5 = Color3.fromRGB(255, 242, 168)
local v = { Perfect = 1, Great = 0.8, Good = 0.55, OK = 0.4 }

local v2 = {
	Perfect = 1,
	Great = 0.85,
	Good = 0.6,
	OK = 0.45,
	Wrong = 0.3,
	Miss = 0
}

local random = Random.new()
local function rnd(p, p2) -- 7 equivalent calls inferred from this helper
	return random:NextNumber(p, p2)
end
local function r01() -- 2 equivalent calls inferred from this helper
	return random:NextNumber()
end
local function smooth(value) -- 3 equivalent calls inferred from this helper
	local v3 = math.clamp(value, 0, 1)
	return v3 * v3 * (3 - 2 * v3)
end

function KeyAura3D.new(env)
	local object = setmetatable({}, KeyAura3D)
	object.env = env
	local v3 = env.mobile and true or false
	object.cfg = {
		sparkRateMax = v3 and 5 or 9,
		maxSparks = v3 and 9 or 22,
		maxStreaks = v3 and 10 or 28,
		maxFlies = v3 and 9 or 22,
		flyRateMax = v3 and 1 or 1.5,
		streakBurst = v3 and 5 or 8,
		holdStreakRate = v3 and 5 or 10,
		starStreakRate = v3 and 3 or 6,
		holdSize = 1.9,
		laneSparks = v3 and 3 or 5,
		laneStreaks = v3 and 6 or 12,
		laneFlies = v3 and 3 or 5
	}

	object.pool = {}
	object.parts = {}
	object.lanes = {}
	object.fast = true
	object.hotA = color3
	object.hotB = color4
	object.flyCore = color5
	object.nSparks = 0
	object.nStreaks = 0
	object.nFlies = 0
	object.clock = 0
	object:Reset(true)
	return object
end

function KeyAura3D:_acquire(image, value)
	local layer = self.env.layer()

	if not layer then
		return nil
	end

	local v3 = table.remove(self.pool)

	if not v3 then
		v3 = Instance.new("ImageLabel")
		v3.BackgroundTransparency = 1
		v3.BorderSizePixel = 0
		v3.ScaleType = Enum.ScaleType.Stretch
		v3.Active = false
		v3.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	v3.Image = image
	v3.Rotation = 0
	v3.ZIndex = value or 4
	v3.Visible = true

	if pcall(function()
		v3.Parent = layer
	end) then
		return v3
	end

	return nil
end

function KeyAura3D:_release(p)
	local l = p.l

	if not l then
		return
	end

	l.Visible = false

	if #self.pool < 80 then
		table.insert(self.pool, l)
	else
		l:Destroy()
	end
end

function KeyAura3D:Clear()
	for _, part in ipairs(self.parts) do
		self:_release(part)
	end

	self.parts = {}
	self.nSparks = 0
	self.nStreaks = 0
	self.nFlies = 0
	self.lanes = {}
end

function KeyAura3D:Reset(p)
	self.formQuality = 0.9
	self.formCombo = 0
	self.formDisplay = 0.9
	self.vis = 1
	self.starMix = 0

	if p then
		self.kicks = nil
		self.kickIdx = 1
		self.lastKick = -1000000000
		self.lastFired = -1000000000
		self.songTime = nil
		self:Clear()
	end
end

function KeyAura3D:SetStyle(p)
	local bpm = p and tonumber(p.BPM) or 120
	local keyAuraStyle

	if p and type(p.KeyAuraStyle) == "string" then
		keyAuraStyle = string.lower(p.KeyAuraStyle) or nil
	end

	if keyAuraStyle == "warm" then
		self.fast = false
	elseif keyAuraStyle == "blade" then
		self.fast = true
	else
		self.fast = bpm >= 80
	end
end

function KeyAura3D:SetKicks(kicks)
	if type(kicks) == "table" and #kicks > 0 then
		self.kicks = kicks
	else
		self.kicks = nil
	end

	self.kickIdx = 1
	self.lastKick = -1000000000
	self.lastFired = -1000000000
end

function KeyAura3D:SetSongTime(songTime)
	self.songTime = songTime
end
function KeyAura3D.GetStyleName(p): string
	return if p.fast then "Blade" else "Warm"
end
function KeyAura3D.GetForm(data)
	return data.formDisplay, data.formQuality, data.formCombo
end

function KeyAura3D:Feed(p, p2, p3)
	local v3 = p2 and 1 or v2[p]

	if v3 == nil then
		return
	end

	local v4 = self.formQuality < v3 and 0.35 or 0.13
	self.formQuality = math.clamp(self.formQuality + (v3 - self.formQuality) * v4, 0, 1)

	if p == "Miss" then
		self.formCombo = 0
	elseif p ~= "Wrong" then
		self.formCombo = p3 or self.formCombo + 1
	end
end

function KeyAura3D:_lane(p)
	local v3 = self.lanes[p]

	if not v3 then
		v3 = {
			Press = 0,
			Dip = 0,
			Hold = 0,
			SparkAcc = 0,
			FlyAcc = 0,
			HoldAcc = 0,
			BoltT = 0,
			StarAcc = 0,
			StarBoltT = 0,
			Tick = 0,
			kickBob = 0,
			lastBolt = -1,
			n = { sparks = 0, streaks = 0, flies = 0 },
			g = self.env.unit() * 0.75,
			GlowColor = color,
			CoreColor = color
		}

		self.lanes[p] = v3
	end

	return v3
end

function KeyAura3D:_cap(p)
	local v3 = (self.env.quality().cap or 170) >= 170 and 1 or 0.6
	return (math.floor(p * (1 + 0.7 * self.starMix) * v3 + 0.5))
end

function KeyAura3D:_spark(lane, data, p)
	local cfg = self.cfg

	if self.nSparks >= self:_cap(cfg.maxSparks) or data.n.sparks >= cfg.laneSparks then
		return
	end

	local v3 = self:_acquire(self.env.tex.Glow, 4)

	if not v3 then
		return
	end

	local g = data.g
	local hold = data.Hold
	local starMix = self.starMix
	local vis = self.vis
	local v4 = g / 60
	local v5 = {
		kind = "spark",
		lane = lane,
		d = data,
		l = v3,
		age = 0,
		max = (0.45 + 0.5 * vis) * (0.8 + 0.4 * random:NextNumber()) * (1 + 0.5 * hold),
		x0 = random:NextNumber(-0.42, 0.42) * g,
		y0 = -g * 0.6,
		rise = math.min(
			g * (0.45 + 0.95 * vis) * (0.7 + 0.6 * random:NextNumber()) * (p and 1.15 or 1) * (1 + 1.8 * hold) * (1 + 0.35 * starMix),
			g * 2.6
		),
		drift = random:NextNumber(-0.18, 0.18) * g,
		ph = random:NextNumber(0, 6.283185307179586)
	}
	v5.size = 3.5 * v4 * 2.4 * (0.7 + 0.8 * random:NextNumber()) * (0.55 + 0.45 * vis) * (1 + 0.4 * starMix)
	v3.Size = UDim2.fromOffset(v5.size, v5.size)
	v3.ImageColor3 = data.CoreColor
	v3.ImageTransparency = 0.1
	self.nSparks += 1
	data.n.sparks += 1
	table.insert(self.parts, v5)
end

function KeyAura3D:_streak(lane, p, p2, p3, p4, value)
	local cfg = self.cfg

	if self.nStreaks >= self:_cap(cfg.maxStreaks) or p.n.streaks >= cfg.laneStreaks then
		return
	end

	local v3 = self:_acquire(self.env.tex.Streak, 5)

	if not v3 then
		return
	end

	local g = p.g
	local starMix = self.starMix
	local v4 = value or 1
	local v5 = p2 + rnd(-p3, p3) -- inferred equivalent call
	local v6 = g * rnd(3.2, 6.2) * (0.6 + 0.4 * p4) * (1 + 0.25 * (v4 - 1)) * (1 + 0.3 * starMix) -- inferred equivalent call
	local v7 = {
		kind = "streak",
		lane = lane,
		d = p,
		l = v3,
		age = 0,
		max = rnd(0.2, 0.38) * (1 + 0.3 * (v4 - 1)), -- inferred equivalent call
		vx = math.cos(v5) * v6,
		vy = math.sin(v5) * v6,
		x = rnd(-0.15, 0.15) * g, -- inferred equivalent call
		y = g * 0.05,
		len = g * rnd(0.22, 0.5) * (0.6 + 0.4 * p4) * v4 * (1 + 0.5 * starMix), -- inferred equivalent call
		thick = 3.2 * (g / 60) * v4 ^ 0.7 * (1 + 0.4 * starMix)
	}

	v3.ImageColor3 = self.hotA
	v3.ImageTransparency = 0
	v3.Size = UDim2.fromOffset(v7.len, v7.thick)
	self.nStreaks += 1
	p.n.streaks += 1
	table.insert(self.parts, v7)
end

function KeyAura3D:_fly(lane, data)
	local cfg = self.cfg

	if self.nFlies >= self:_cap(cfg.maxFlies) or data.n.flies >= cfg.laneFlies then
		return
	end

	local v3 = self:_acquire(self.env.tex.Glow, 4)

	if not v3 then
		return
	end

	local g = data.g
	local hold = data.Hold
	local starMix = self.starMix
	local vis = self.vis
	local v4 = {
		kind = "fly",
		lane = lane,
		d = data,
		l = v3,
		age = 0,
		max = (2.6 + 1.6 * random:NextNumber()) * (0.75 + 0.25 * vis) * (1 + 0.4 * hold),
		x0 = random:NextNumber(-0.5, 0.5) * g,
		y0 = -g * 0.6,
		rise = math.min(
			g * (0.55 + 0.7 * vis) * (0.7 + 0.6 * random:NextNumber()) * (1 + 1.6 * hold) * (1 + 0.3 * starMix),
			g * 2.8
		),
		drift = random:NextNumber(0.18, 0.4) * g,
		ph = random:NextNumber(0, 6.283185307179586),
		blink = random:NextNumber(0.9, 1.8)
	}
	v4.size = 4 * (g / 60) * 3 * (0.8 + 0.5 * random:NextNumber()) * (0.65 + 0.35 * vis) * (1 + 0.35 * starMix)
	v3.Size = UDim2.fromOffset(v4.size, v4.size)
	v3.ImageColor3 = self.flyCore
	v3.ImageTransparency = 1
	self.nFlies += 1
	data.n.flies += 1
	table.insert(self.parts, v4)
end

function KeyAura3D:_bolt(p, p2, p3, value)
	if not self.env.quality().lightning then
		return
	end

	local now = os.clock()

	if now - p2.lastBolt < 0.07 then
		return
	end

	local v3 = self.env.frets()[p]

	if not v3 then
		return
	end

	p2.lastBolt = now
	self.env.bolt(v3, self.hotA, (math.clamp(0.5 * (0.6 + 0.4 * p3) * (value or 1), 0.3, 1.1)))
end

function KeyAura3D:Pulse(p, p2, p3)
	if p3 then
		return
	end

	local lane = self:_lane(p)

	if p2 == "Miss" then
		lane.Dip = 1
		return
	elseif p2 == "Wrong" then
		lane.Dip = math.max(lane.Dip, 0.5)
		return
	end

	local v3 = v[p2] or 0.45
	local v4 = 0.35 + 0.65 * self.vis
	local starMix = self.starMix

	if self.fast then
		for _ = 1, math.floor((v3 >= 0.8 and 3 or 2) * (0.4 + 0.6 * self.vis) * (1 + 0.5 * starMix) + 0.5) do
			self:_spark(p, lane, true)
		end

		for _ = 1, math.floor(self.cfg.streakBurst * (v3 >= 0.8 and 1 or 0.6) * (0.15 + 0.85 * self.vis) * (1 + 1.2 * starMix) + 0.5) do
			self:_streak(p, lane, -1.5707963267948966, 1.7, v3 * v4, 1 + 0.4 * starMix)
		end

		if v3 >= 0.55 and self.vis > 0.2 then
			self:_bolt(p, lane, v3 * v4, 1 + 0.4 * starMix)

			if starMix > 0.5 then
				self:_bolt(p, lane, v3 * v4, 1.2)
			end
		end
	else
		for _ = 1, math.floor((v3 >= 0.8 and 3 or 2) * (0.4 + 0.6 * self.vis) * (1 + starMix) + 0.5) do
			self:_fly(p, lane)
		end
	end
end

function KeyAura3D:Step(p)
	local env = self.env
	local v3 = math.min(p, 0.1)

	if v3 <= 0 then
		return
	end

	local frets = env.frets()
	local v4 = env.unit() * 0.75
	local quality = env.quality()
	local cfg = self.cfg
	local active = env.active()
	self.clock += v3
	local clock = self.clock
	local star = env.isStar()

	local v5 = math.min(1, self.formQuality + math.min(self.formCombo / 30, 1) * 0.12)

	if star then
		v5 = math.max(v5, 0.8)
	end

	local v6 = self.formDisplay < v5 and 6 or 0.8
	self.formDisplay += (v5 - self.formDisplay) * (1 - math.exp(-v6 * v3))
	self.starMix += ((star and 1 or 0) - self.starMix) * (1 - math.exp(-5 * v3))
	local starMix = self.starMix
	local vis = 0.4 + 0.6 * smooth((self.formDisplay - 0.15) / 0.7) -- inferred equivalent call
	self.vis = vis
	local v7 = math.clamp((0.75 - self.formDisplay) / 0.75, 0, 1) * 0.55 * (1 - starMix)
	local v8 = (0.3 + (cfg.sparkRateMax - 0.3) * vis ^ 1.5) * (self.kicks and 0.35 or 1)
	local v9 = (0.4 + (cfg.flyRateMax - 0.4) * vis ^ 1.3) * (self.kicks and 0.6 or 1)

	local v10 = false
	local kicks = self.kicks
	local songTime = self.songTime
	local v11

	if kicks and songTime then
		local count = #kicks
		local kickIdx = self.kickIdx

		if kickIdx > 1 then
			local kick = kicks[kickIdx - 1]

			if songTime + 0.05 < kick then
				local v12 = count + 1
				kickIdx = 1

				while kickIdx < v12 do
					local v13 = (kickIdx + v12) // 2

					if kicks[v13] <= songTime then
						kickIdx = v13 + 1
					else
						v12 = v13
					end
				end

				self.lastKick = kickIdx > 1 and kicks[kickIdx - 1] or -1000000000
			end
		end

		while kickIdx <= count and kicks[kickIdx] <= songTime do
			local kick = kicks[kickIdx]
			kickIdx += 1

			if songTime - kick < 0.12 and kick - self.lastFired >= 0.09 then
				self.lastFired = kick
				v10 = true
			end

			self.lastKick = kick
		end

		self.kickIdx = kickIdx
		v11 = math.exp(-math.max(0, songTime - self.lastKick) * 7)
	else
		v11 = 0
	end

	local v12 = color3
	local v13 = color4
	local v14 = color5

	if starMix > 0.01 then
		local energy = env.energy
		v12 = v12:Lerp(energy, 0.7 * starMix):Lerp(color, 0.3 * starMix)
		v13 = v13:Lerp(energy, 0.8 * starMix)
		v14 = v14:Lerp(energy, 0.55 * starMix)
	end

	local lerped = v12:Lerp(color2, v7)
	local lerped2 = v13:Lerp(color2, v7)
	local lerped3 = v14:Lerp(color2, v7)
	self.hotA = lerped
	self.hotB = lerped2
	self.flyCore = lerped3
	local hotA = self.hotA
	local hotB = self.hotB

	local now = os.clock()

	for k, fret in pairs(frets) do
		local lane = self:_lane(k)
		lane.g = v4
		lane.Tick += 1
		lane.kickBob = v11 * v4 * 0.2 * (0.35 + 0.65 * vis)
		lane.Press += ((fret.IsPressed and 1 or 0) - lane.Press) * (1 - math.exp(-14 * v3))
		lane.Dip = math.max(0, lane.Dip - v3 * 2.2)
		local v15 = now < (fret.HoldUntil or 0)

		if v15 then
			lane.Hold = math.min(1, lane.Hold + v3 * 0.9)
		else
			lane.Hold = math.max(0, lane.Hold - v3 * 4)
		end

		if lane.Tick <= 2 or lane.Tick % 3 == 0 then
			local lerped4 = (fret.AccentColor or color):Lerp(color, 0.2)

			if starMix > 0.01 then
				lerped4 = lerped4:Lerp(env.energy, 0.75 * starMix)
			end

			local lerped5 = lerped4:Lerp(color2, v7)
			lane.GlowColor = lerped5
			lane.CoreColor = lerped5:Lerp(color, 0.45 * (1 - v7))
		end

		if not active then
			continue
		end

		if v10 and vis > 0.1 then
			if self.fast then
				self:_spark(k, lane, false)

				if starMix > 0.3 then
					self:_streak(k, lane, -1.5707963267948966, 1.5, 0.6, 1.2)
					self:_streak(k, lane, -1.5707963267948966, 1.5, 0.6, 1.2)

					if r01() < 0.3 then -- inferred equivalent call
						self:_bolt(k, lane, 0.7, 1.1)
					end
				end
			elseif r01() < 0.5 then -- inferred equivalent call
				self:_fly(k, lane)
			end
		end

		if v15 and vis > 0.05 and self.fast then
			lane.HoldAcc = math.min(lane.HoldAcc + cfg.holdStreakRate * (0.2 + 0.8 * vis) * (1 + 0.6 * starMix) * v3, 4)

			while lane.HoldAcc >= 1 do
				lane.HoldAcc -= 1
				self:_streak(k, lane, -1.5707963267948966, 1.3, 0.75 * (0.35 + 0.65 * vis), cfg.holdSize)
			end
		else
			lane.HoldAcc = 0
		end

		if starMix > 0.3 and vis > 0.1 and quality.star ~= false then
			lane.StarBoltT -= v3

			if self.fast then
				lane.StarAcc = math.min(lane.StarAcc + cfg.starStreakRate * starMix * v3, 3)

				while lane.StarAcc >= 1 do
					lane.StarAcc -= 1
					self:_streak(k, lane, -1.5707963267948966, 1.7, 0.6, 1.2)
				end

				if lane.StarBoltT <= 0 then
					self:_bolt(k, lane, 0.7, 1)
					lane.StarBoltT = rnd(0.5, 1.2) -- inferred equivalent call
				end
			elseif lane.StarBoltT <= 0 then
				lane.StarBoltT = rnd(1, 1.8) -- inferred equivalent call
			end
		end

		if self.fast then
			local v16 = v8 * (1 + 0.8 * lane.Press) * (1 + 1.2 * starMix) * (1 - 0.8 * lane.Dip) * (1 + 1 * lane.Hold)
			lane.SparkAcc = math.min(lane.SparkAcc + v16 * v3, 3)

			while lane.SparkAcc >= 1 do
				lane.SparkAcc -= 1
				self:_spark(k, lane, false)
			end
		else
			local v16 = v9 * (1 + 0.8 * lane.Press) * (1 + 1.2 * starMix) * (1 - 0.8 * lane.Dip) * (1 + 1.2 * lane.Hold)
			lane.FlyAcc = math.min(lane.FlyAcc + v16 * v3, 3)

			while lane.FlyAcc >= 1 do
				lane.FlyAcc -= 1
				self:_fly(k, lane)
			end
		end
	end

	local parts = self.parts
	local v15 = 1

	while v15 <= #parts do
		local part = parts[v15]
		local fret = frets[part.lane]
		part.age += v3
		local v16 = part.age / part.max

		if v16 >= 1 or not (fret and fret.ScreenPos and part.l.Parent) then
			if part.kind == "spark" then
				self.nSparks = math.max(0, self.nSparks - 1)
				part.d.n.sparks = math.max(0, part.d.n.sparks - 1)
			elseif part.kind == "streak" then
				self.nStreaks = math.max(0, self.nStreaks - 1)
				part.d.n.streaks = math.max(0, part.d.n.streaks - 1)
			else
				self.nFlies = math.max(0, self.nFlies - 1)
				part.d.n.flies = math.max(0, part.d.n.flies - 1)
			end

			self:_release(part)
			parts[v15] = parts[#parts]
			parts[#parts] = nil
		else
			local screenPos = fret.ScreenPos
			local l = part.l
			local d = part.d

			if part.kind == "spark" then
				local v17 = 1 - (1 - v16) * (1 - v16)
				local v18 = part.x0 + math.sin(v16 * 5 + part.ph) * part.drift
				local v19 = part.y0 - part.rise * v17 - d.kickBob
				l.Position = UDim2.fromOffset(screenPos.X + v18, screenPos.Y + v19)
				l.ImageTransparency = 1 - (1 - (0.08 + 0.92 * v16 * v16)) * (0.4 + 0.6 * vis)
			elseif part.kind == "streak" then
				part.vy += d.g * 10 * v3
				local v17 = math.exp(-1.6 * v3)
				part.vx *= v17
				part.vy *= v17
				part.x += part.vx * v3
				part.y += part.vy * v3
				l.Position = UDim2.fromOffset(screenPos.X + part.x, screenPos.Y + part.y)
				l.Rotation = math.deg((math.atan2(part.vy, part.vx))) + 180
				l.Size = UDim2.fromOffset(part.len * (1 - 0.55 * v16), part.thick)
				l.ImageColor3 = hotA:Lerp(hotB, v16)
				l.ImageTransparency = 1 - (1 - (v16 < 0.35 and 0 or ((v16 - 0.35) / 0.65) ^ 1.5)) * (0.3 + 0.7 * vis)
			else
				local ph = part.ph
				local v17 = part.x0 + (math.sin(v16 * 2.1 * 3.141592653589793 + ph) * 0.6 + math.sin(v16 * 3.7 * 3.141592653589793 + ph * 1.7) * 0.4) * part.drift
				local v18 = part.y0 - part.rise * v16 + math.sin(v16 * 5 + ph) * d.g * 0.04 - d.kickBob * 0.25
				l.Position = UDim2.fromOffset(screenPos.X + v17, screenPos.Y + v18)
				local v19 = math.sin(clock * part.blink * 3.141592653589793 + ph) * 0.3 + 0.7
				l.ImageTransparency = 1 - math.clamp(
					smooth(v16 / 0.25) * smooth((1 - v16) / 0.3) * v19 * (0.4 + 0.6 * vis) * (v11 * 0.3 + 1), -- inferred equivalent call
					0,
					1
				) * 0.8
				local v20 = part.size * (math.sin(clock * 1.3 + ph) * 0.15 + 0.9)
				l.Size = UDim2.fromOffset(v20, v20)
			end

			v15 += 1
		end
	end
end

return KeyAura3D