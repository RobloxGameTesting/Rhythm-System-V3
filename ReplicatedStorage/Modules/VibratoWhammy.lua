local VibratoWhammy = {}
VibratoWhammy.__index = VibratoWhammy

function VibratoWhammy.new()
	local self = setmetatable({}, VibratoWhammy)
	self:Reset()
	return self
end

function VibratoWhammy:Reset()
	self.xs = 0
	self.xl = 0
	self.slow = 0
	self.m2 = 0
	self.sign = 0
	self.lastRise = nil
	self.lastCross = nil
	self.rate = 5.5
	self.vibOn = false
	self.vibEnv = 0
	self.depth = 20
end

function VibratoWhammy:Step(value, p, p2)
	local v = math.clamp(value, 0.001, 0.1)

	self.xs += (p - self.xs) * (1 - math.exp(-v / 0.09))
	self.xl += (p - self.xl) * (1 - math.exp(-v / 0.03))
	self.slow += (self.xl - self.slow) * (1 - math.exp(-v / 0.32))
	local v2 = self.xl - self.slow

	self.m2 += (v2 * v2 - self.m2) * (1 - math.exp(-v / 0.22))

	local v3 = 1 / math.sqrt(1 + (6.283185307179586 * self.rate * 0.03) ^ 2)
	local v4 = math.sqrt(2 * self.m2) / v3

	local v5 = math.max(3, v4 * 0.3)

	if v5 < v2 and self.sign <= 0 then
		if self.lastRise then
			local v6 = p2 - self.lastRise

			if v6 >= 0.1 and v6 <= 0.55 then
				self.rate += (1 / v6 - self.rate) * 0.5
				self.lastCross = p2
			end
		end

		self.lastRise = p2
		self.sign = 1
	elseif v2 < -v5 and self.sign >= 0 then
		self.sign = -1
	end

	local v6

	if self.lastCross == nil then
		v6 = false
	else
		v6 = p2 - self.lastCross < 0.5
	end

	if self.vibOn then
		if v4 < 5 or not v6 then
			self.vibOn = false
		end
	elseif v4 > 9 and v6 then
		self.vibOn = true
	end

	self.vibEnv += ((self.vibOn and 1 or 0) - self.vibEnv) * (1 - math.exp(-v / 0.15))

	local v7 = self.xs + (self.slow - self.xs) * self.vibEnv

	local v8 = math.clamp(v4 * 1.6, 20, 78)
	self.depth += (v8 - self.depth) * (1 - math.exp(-v / 0.25))

	return v7, self.vibOn, self.rate, self.depth
end

return VibratoWhammy