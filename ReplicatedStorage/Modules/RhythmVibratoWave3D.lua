local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RhythmVibratoFx = require(ReplicatedStorage.Modules.RhythmVibratoFx)

local random = Random.new()

local v = os.clock()
local v2 = 0
local v3 = 0
local v4 = "Sym"
local v5 = 0
local v6 = false
local v7 = 0
local RhythmVibratoWave3D = {}

function RhythmVibratoWave3D.BeginFrame()
	v2, v3, v4, v5 = RhythmVibratoFx.GetWave()
	v6 = RhythmVibratoFx.IsWaving(v2, v5)
	local now = os.clock()
	v7 = math.min(now - v, 0.1)
	v = now
end

function RhythmVibratoWave3D.ReportHold(p)
	RhythmVibratoFx.ReportHold(p)
end

local function newPart(color, size, transparency) -- 3 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Transparency = transparency
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	return part
end

local function ensure(state, p, color)
	if state.WaveCore then
		return
	end

	local waveCore = {}
	local waveGlow = {}

	for i = 1, 20 do
		waveCore[i] = newPart(Color3.fromRGB(226, 218, 204), Vector3.new(p * 0.5, 0.07, 0.2), 0.12) -- inferred equivalent call
		waveGlow[i] = newPart(color, Vector3.new(p * 2.2, 0.03, 0.2), 0.6) -- inferred equivalent call
	end

	local waveSparks = {}

	for i = 1, 6 do
		waveSparks[i] = {
			Part = newPart(color, Vector3.new(0.14, 0.14, 0.14), 1), -- inferred equivalent call
			Live = false,
			Age = 0,
			Life = 1,
			Rise = 0,
			Speed = 0,
			Jit = 0
		}
	end

	state.WaveCore = waveCore
	state.WaveGlow = waveGlow
	state.WaveSparks = waveSparks
	state.SparkAcc = 0
end

function RhythmVibratoWave3D:Hide()
	if not self.WaveOn then
		return
	end

	self.WaveOn = false

	for i = 1, 20 do
		self.WaveCore[i].Parent = nil
		self.WaveGlow[i].Parent = nil
	end

	for _, waveSpark in ipairs(self.WaveSparks) do
		waveSpark.Live = false
		waveSpark.Part.Parent = nil
	end
end

function RhythmVibratoWave3D:Destroy()
	if self.WaveCore then
		for i = 1, 20 do
			self.WaveCore[i]:Destroy()
			self.WaveGlow[i]:Destroy()
		end

		for _, waveSpark in ipairs(self.WaveSparks) do
			waveSpark.Part:Destroy()
		end
	end

	self.WaveCore = nil
	self.WaveGlow = nil
	self.WaveSparks = nil
	self.WaveOn = false
end

function RhythmVibratoWave3D:Draw(parent, callback, p, p2, p3, p4, p5, color): boolean
	if not v6 then
		return false
	end

	local v8 = p4 - p3

	if v8 <= 0.3 then
		return false
	end

	ensure(self, p5, color)
	self.WaveOn = true

	local v9 = math.max(p5 * 1.6, 0.3)
	local pulse = RhythmVibratoFx.Pulse(v2, v3)
	local v10 = math.max(v2, (math.abs(v5)))
	local v11 = v8 / 20

	for i = 1, 20 do
		local v12 = p3 + (i - 0.5) * v11
		local v13 = (p4 - v12) / v8
		local v14 = RhythmVibratoFx.Offset(v13, v2, v3, v4, v5) * v9
		local cframe = CFrame.new(callback(p2 + v14, 0.27, v12)) * p
		local v15 = self.WaveCore[i]
		v15.Size = Vector3.new(p5 * 0.5, 0.07, v11 + 0.04)
		v15.CFrame = cframe
		v15.Parent = parent
		local v16 = self.WaveGlow[i]
		v16.Size = Vector3.new(p5 * (1.6 + 0.6 * pulse), 0.03, v11 + 0.04)
		v16.CFrame = CFrame.new(callback(p2 + v14, 0.12, v12)) * p
		v16.Transparency = 0.75 - 0.35 * pulse
		v16.Color = color
		v16.Parent = parent
	end

	self.SparkAcc += v7 * v10 * 14
	local waveSparks = self.WaveSparks

	while self.SparkAcc >= 1 do
		self.SparkAcc -= 1

		for _, waveSpark in ipairs(waveSparks) do
			if not waveSpark.Live then
				waveSpark.Live = true
				waveSpark.Age = 0
				waveSpark.Life = random:NextNumber(0.45, 0.85)
				waveSpark.Rise = 0
				waveSpark.Speed = random:NextNumber(v8 * 0.6, v8 * 1.2)
				waveSpark.Jit = random:NextNumber(-0.08, 0.08)
				waveSpark.Part.Color = color
				break
			end
		end
	end

	for _, waveSpark in ipairs(waveSparks) do
		if not waveSpark.Live then
			continue
		end

		waveSpark.Age += v7
		waveSpark.Rise += waveSpark.Speed * v7

		if waveSpark.Age >= waveSpark.Life or v8 <= waveSpark.Rise then
			waveSpark.Live = false
			waveSpark.Part.Parent = nil
		else
			local v12 = waveSpark.Rise / v8
			local v13 = RhythmVibratoFx.Offset(v12, v2, v3, v4, v5) * v9 + waveSpark.Jit
			waveSpark.Part.CFrame = CFrame.new(callback(p2 + v13, 0.36, p4 - waveSpark.Rise)) * p
			waveSpark.Part.Transparency = 0.15 + 0.85 * (waveSpark.Age / waveSpark.Life)
			waveSpark.Part.Parent = parent
		end
	end

	if self.HoldPart then
		self.HoldPart.Transparency = 1
	end

	if self.HoldStroke then
		self.HoldStroke.Transparency = 1
	end

	if self.HoldCenter then
		self.HoldCenter.Transparency = 1
	end

	if self.HoldGlow then
		self.HoldGlow.Transparency = 1
	end

	return true
end

return RhythmVibratoWave3D