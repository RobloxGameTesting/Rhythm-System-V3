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
local RhythmVibratoWave2D = {}

function RhythmVibratoWave2D.BeginFrame()
	v2, v3, v4, v5 = RhythmVibratoFx.GetWave()
	v6 = RhythmVibratoFx.IsWaving(v2, v5)
	local now = os.clock()
	v7 = math.min(now - v, 0.1)
	v = now
end

function RhythmVibratoWave2D.ReportHold(p)
	RhythmVibratoFx.ReportHold(p)
end

local function ensure(state, parent, _, p)
	if state.WaveSlices then
		return
	end

	local waveSlices = {}
	local waveGlows = {}

	for i = 1, 22 do
		local vibratoSlice = Instance.new("Frame")
		vibratoSlice.Name = "VibratoSlice"
		vibratoSlice.AnchorPoint = Vector2.new(0.5, 0)
		vibratoSlice.BorderSizePixel = 0
		vibratoSlice.BackgroundColor3 = p
		vibratoSlice.BackgroundTransparency = 0.05
		vibratoSlice.ZIndex = 1
		vibratoSlice.Visible = false
		vibratoSlice.Parent = parent
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 3)
		uiCorner.Parent = vibratoSlice
		local glow = Instance.new("UIStroke")
		glow.Name = "Glow"
		glow.Color = p
		glow.Thickness = 0
		glow.Transparency = 0.55
		glow.Parent = vibratoSlice
		waveSlices[i] = vibratoSlice
		waveGlows[i] = glow
	end

	local waveSparks = {}

	for i = 1, 8 do
		local vibratoSpark = Instance.new("Frame")
		vibratoSpark.Name = "VibratoSpark"
		vibratoSpark.AnchorPoint = Vector2.new(0.5, 0.5)
		vibratoSpark.Size = UDim2.new(0, 5, 0, 5)
		vibratoSpark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		vibratoSpark.BackgroundTransparency = 1
		vibratoSpark.BorderSizePixel = 0
		vibratoSpark.Visible = false
		vibratoSpark.ZIndex = 3
		vibratoSpark.Parent = parent
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = vibratoSpark
		waveSparks[i] = {
			Frame = vibratoSpark,
			Live = false,
			Age = 0,
			Life = 1,
			Rise = 0,
			Speed = 0,
			Jit = 0
		}
	end

	state.WaveSlices = waveSlices
	state.WaveGlows = waveGlows
	state.WaveSparks = waveSparks
	state.SparkAcc = 0
end

function RhythmVibratoWave2D:Hide()
	if not self.WaveOn then
		return
	end

	self.WaveOn = false

	for _, waveSlice in ipairs(self.WaveSlices) do
		waveSlice.Visible = false
	end

	for _, waveSpark in ipairs(self.WaveSparks) do
		waveSpark.Live = false
		waveSpark.Frame.Visible = false
	end
end

function RhythmVibratoWave2D:Destroy()
	if self.WaveSlices then
		for _, waveSlice in ipairs(self.WaveSlices) do
			waveSlice:Destroy()
		end
	end

	if self.WaveSparks then
		for _, waveSpark in ipairs(self.WaveSparks) do
			waveSpark.Frame:Destroy()
		end
	end

	self.WaveSlices = nil
	self.WaveGlows = nil
	self.WaveSparks = nil
	self.WaveOn = false
end

function RhythmVibratoWave2D:Draw(parent, p, p2, p3, p4, p5): boolean
	if not v6 then
		return false
	end

	ensure(self, parent, p4, p5)
	self.WaveOn = true

	local pulse = RhythmVibratoFx.Pulse(v2, v3)
	local v8 = math.max(v2, (math.abs(v5)))
	local v9 = p2 / 22
	local waveSlices = self.WaveSlices
	local waveGlows = self.WaveGlows

	for i = 1, 22 do
		local v10 = p + (i - 1) * v9
		local v11 = (p3 - (v10 + v9 * 0.5)) / p2
		local v12 = RhythmVibratoFx.Offset(v11, v2, v3, v4, v5) * 14
		local waveSlice = waveSlices[i]
		waveSlice.Visible = true
		waveSlice.Position = UDim2.new(0.5, v12, 0, v10)
		waveSlice.Size = UDim2.new(0, p4, 0, v9 + 2)
		waveGlows[i].Thickness = 0.5 + 2.5 * pulse
	end

	self.SparkAcc += v7 * v8 * 16
	local waveSparks = self.WaveSparks

	while self.SparkAcc >= 1 do
		self.SparkAcc -= 1

		for _, waveSpark in ipairs(waveSparks) do
			if not waveSpark.Live then
				waveSpark.Live = true
				waveSpark.Age = 0
				waveSpark.Life = random:NextNumber(0.45, 0.85)
				waveSpark.Rise = 0
				waveSpark.Speed = random:NextNumber(130, 230)
				waveSpark.Jit = random:NextNumber(-4, 4)
				waveSpark.Frame.BackgroundColor3 = self.AccentColor or p5
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

		if waveSpark.Age >= waveSpark.Life or p2 <= waveSpark.Rise then
			waveSpark.Live = false
			waveSpark.Frame.Visible = false
		else
			local v10 = waveSpark.Rise / p2
			local v11 = RhythmVibratoFx.Offset(v10, v2, v3, v4, v5) * 14 + waveSpark.Jit
			waveSpark.Frame.Visible = true
			waveSpark.Frame.Position = UDim2.new(0.5, v11, 0, p3 - waveSpark.Rise)
			waveSpark.Frame.BackgroundTransparency = 0.15 + 0.85 * (waveSpark.Age / waveSpark.Life)
		end
	end

	return true
end

return RhythmVibratoWave2D