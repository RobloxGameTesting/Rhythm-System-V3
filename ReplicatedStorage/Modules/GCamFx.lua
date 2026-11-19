local AssetService = game:GetService("AssetService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GCamConfig = require(script.Parent.GCamConfig)

local GCamFx = {}
GCamFx.__index = GCamFx

local random = Random.new()
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function makeEditable(p, p2, fn)
	local success, result = pcall(function()
		return AssetService:CreateEditableImage({ Size = Vector2.new(p, p2) })
	end)

	if not (success and result) then
		return nil
	end

	local buf = buffer.create(p * p2 * 4)
	fn(buf, p, p2)

	if pcall(function()
		result:WritePixelsBuffer(Vector2.zero, Vector2.new(p, p2), buf)
	end) then
		return result
	end

	pcall(function()
		result:Destroy()
	end)
	return nil
end

local function setImage(p, editable) -- 3 equivalent calls inferred from this helper
	return (pcall(function()
		p.ImageContent = Content.fromObject(editable)
	end))
end

local function newFrame(parent, name, value) -- 5 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = value or 1
	frame.Parent = parent
	return frame
end

local function newImage(parent, name, value) -- 3 equivalent calls inferred from this helper
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ZIndex = value or 1
	imageLabel.Active = false
	imageLabel.Parent = parent
	return imageLabel
end

function GCamFx.new(gui, p)
	local self = setmetatable({}, GCamFx)
	self.low = p ~= nil and p.low == true
	self.gui = gui
	self.camera = Workspace.CurrentCamera
	self.filter = GCamConfig.Filters[1]
	self.grain = 0
	self.scan = 0
	self.vignette = 0
	self.glitch = 0
	self.grainClock = 0
	self.rollY = 0
	self.glitchTimer = 0
	self.focus = 40
	self.enabled = false
	self.boost = 0
	local v = newFrame(gui, "FxRoot") -- inferred equivalent call
	v.Visible = false
	self.root = v

	self.tint = newFrame(v, "Tint") -- inferred equivalent call
	self.tint.BackgroundTransparency = 1

	local editable = makeEditable(128, 128, function(buf, p2, p3)
		for i = 0, p2 * p3 - 1 do
			local integer = random:NextInteger(0, 255)
			buffer.writeu8(buf, i * 4, integer)
			buffer.writeu8(buf, i * 4 + 1, integer)
			buffer.writeu8(buf, i * 4 + 2, integer)
			buffer.writeu8(buf, i * 4 + 3, (random:NextInteger(50, 255)))
		end
	end)
	self.grainLabel = nil

	if editable then
		local grainLabel = newImage(v, "Grain", 2) -- inferred equivalent call
		grainLabel.Size = UDim2.new(1, 256, 1, 256)
		grainLabel.ScaleType = Enum.ScaleType.Tile
		grainLabel.TileSize = UDim2.fromOffset(128, 128)
		grainLabel.ImageTransparency = 1

		if setImage(grainLabel, editable) then -- inferred equivalent call
			self.grainLabel = grainLabel
			self.grainImg = editable
		else
			grainLabel:Destroy()
		end
	end

	if not self.grainLabel then
		self.dots = {}
		local parent = newFrame(v, "GrainDots", 2) -- inferred equivalent call

		for _ = 1, 150 do
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromOffset(2, 2)
			frame.BackgroundTransparency = 1
			frame.Parent = parent
			table.insert(self.dots, frame)
		end
	end

	local editable2 = makeEditable(4, 4, function(buf, p2, p3)
		for i = 0, p3 - 1 do
			for j = 0, p2 - 1 do
				local v2 = (i * p2 + j) * 4
				buffer.writeu8(buf, v2, 0)
				buffer.writeu8(buf, v2 + 1, 0)
				buffer.writeu8(buf, v2 + 2, 0)
				buffer.writeu8(buf, v2 + 3, (i == 0 or i == 1) and 170 or 0)
			end
		end
	end)
	self.scanLabel = nil

	if editable2 then
		local scanLabel = newImage(v, "Scan", 3) -- inferred equivalent call
		scanLabel.Size = UDim2.new(1, 0, 1, 8)
		scanLabel.ScaleType = Enum.ScaleType.Tile
		scanLabel.TileSize = UDim2.fromOffset(4, 4)
		scanLabel.ImageTransparency = 1

		if setImage(scanLabel, editable2) then -- inferred equivalent call
			self.scanLabel = scanLabel
			self.scanImg = editable2
		else
			scanLabel:Destroy()
		end
	end

	local editable3 = makeEditable(128, 128, function(buf, p2, p3)
		for i = 0, p3 - 1 do
			for j = 0, p2 - 1 do
				local v2 = (j + 0.5) / p2 * 2 - 1
				local v3 = (i + 0.5) / p3 * 2 - 1
				local v4 = math.clamp((math.sqrt(v2 * v2 + v3 * v3) - 0.4) / 0.8, 0, 1) ^ 1.7
				local v5 = (i * p2 + j) * 4
				buffer.writeu8(buf, v5, 0)
				buffer.writeu8(buf, v5 + 1, 0)
				buffer.writeu8(buf, v5 + 2, 0)
				buffer.writeu8(buf, v5 + 3, (math.floor(v4 * 255)))
			end
		end
	end)
	self.vigLabel = nil

	if editable3 then
		local vigLabel = newImage(v, "Vignette", 4) -- inferred equivalent call
		vigLabel.ImageTransparency = 1

		if setImage(vigLabel, editable3) then -- inferred equivalent call
			self.vigLabel = vigLabel
			self.vigImg = editable3
		else
			vigLabel:Destroy()
		end
	end

	if not self.vigLabel then
		self.vigEdges = {}
		local v2 = {
			{ UDim2.new(1, 0, 0.3, 0), UDim2.fromScale(0, 0), 90 },
			{ UDim2.new(1, 0, 0.3, 0), UDim2.fromScale(0, 0.7), 270 },
			{ UDim2.new(0.25, 0, 1, 0), UDim2.fromScale(0, 0), 0 },
			{ UDim2.new(0.25, 0, 1, 0), UDim2.fromScale(0.75, 0), 180 }
		}

		for _, v3 in ipairs(v2) do
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.Size = v3[1]
			frame.Position = v3[2]
			frame.ZIndex = 4
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Rotation = v3[3]
			uiGradient.Transparency = NumberSequence.new(0, 1)
			uiGradient.Parent = frame
			frame.BackgroundTransparency = 1
			frame.Parent = v
			table.insert(self.vigEdges, frame)
		end
	end

	self.bandHolder = newFrame(v, "Bands", 5) -- inferred equivalent call
	self.bands = {}

	for _ = 1, 3 do
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 0, 10)
		frame.ZIndex = 5
		frame.Parent = self.bandHolder
		table.insert(self.bands, {
			frame = frame,
			active = false,
			y = 0,
			speed = 0,
			life = 0
		})
	end

	self.roll = Instance.new("Frame")
	self.roll.BorderSizePixel = 0
	self.roll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	self.roll.BackgroundTransparency = 1
	self.roll.Size = UDim2.new(1, 0, 0, 140)
	self.roll.ZIndex = 5
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = self.roll
	self.roll.Parent = self.bandHolder

	self.flashFrame = newFrame(v, "Flash", 20) -- inferred equivalent call
	self.flashFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	self.flashFrame.BackgroundTransparency = 1

	local camera = self.camera
	self.cc = Instance.new("ColorCorrectionEffect")
	self.cc.Name = "GCamCC"
	self.cc.Enabled = false
	self.cc.Parent = camera
	self.bloom = Instance.new("BloomEffect")
	self.bloom.Name = "GCamBloom"
	self.bloom.Enabled = false
	self.bloom.Intensity = 0
	self.bloom.Parent = camera
	self.blur = Instance.new("BlurEffect")
	self.blur.Name = "GCamBlur"
	self.blur.Enabled = false
	self.blur.Size = 0
	self.blur.Parent = camera
	self.dof = Instance.new("DepthOfFieldEffect")
	self.dof.Name = "GCamDOF"
	self.dof.Enabled = false
	self.dof.Parent = camera

	return self
end

function GCamFx:SetEnabled(p)
	self.enabled = p
	self.root.Visible = p
	self.cc.Enabled = p
	self.bloom.Enabled = p
	self.blur.Enabled = p
	self.dof.Enabled = p and not self.low

	if not p then
		self.boost = 0
	end
end

function GCamFx:SetFilter(filter, p)
	self.filter = filter
	local tweenInfo2 = p and TweenInfo.new(0) or tweenInfo
	local cc = filter.cc
	TweenService:Create(self.cc, tweenInfo2, {
		Brightness = cc.Brightness + self.boost,
		Contrast = cc.Contrast,
		Saturation = cc.Saturation,
		TintColor = cc.Tint
	}):Play()
	local bloom = filter.bloom
	TweenService:Create(self.bloom, tweenInfo2, {
		Intensity = bloom and bloom.Intensity or 0,
		Size = bloom and bloom.Size or 24,
		Threshold = bloom and bloom.Threshold or 1
	}):Play()
	TweenService:Create(self.blur, tweenInfo2, {
		Size = filter.blur or 0
	}):Play()

	if filter.overlay then
		self.tint.BackgroundColor3 = filter.overlay[1]
		TweenService:Create(self.tint, tweenInfo2, { BackgroundTransparency = filter.overlay[2] }):Play()
	else
		TweenService:Create(self.tint, tweenInfo2, { BackgroundTransparency = 1 }):Play()
	end

	local grain = filter.grain or 0
	local scan = filter.scan or 0
	self.targetGrain = grain
	self.targetScan = scan
	local vignette = filter.vignette or 0
	local glitch = filter.glitch or 0
	self.targetVig = vignette
	self.targetGlitch = glitch

	if p then
		local targetGrain = self.targetGrain
		local targetScan = self.targetScan
		self.grain = targetGrain
		self.scan = targetScan
		local targetVig = self.targetVig
		local targetGlitch = self.targetGlitch
		self.vignette = targetVig
		self.glitch = targetGlitch
	end
end

function GCamFx:SetBoost(boost)
	self.boost = boost
	self.cc.Brightness = self.filter.cc.Brightness + boost
end

function GCamFx.Flash(p, value)
	p.flashFrame.BackgroundTransparency = 1 - math.clamp(value, 0, 1)
	TweenService:Create(p.flashFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
end

function GCamFx.Glitch(p)
	for _, band in ipairs(p.bands) do
		band.active = true
		band.y = random:NextNumber(0, 0.9)
		band.speed = random:NextNumber(0.9, 2)
		band.life = random:NextNumber(0.15, 0.35)
		band.frame.Size = UDim2.new(1, 0, 0, random:NextInteger(8, 46))
	end
end

function GCamFx:SetFocus(value, p)
	self.focusTarget = math.clamp(value, 4, 300)

	if p then
		self.focus = self.focusTarget
	end
end

function GCamFx:Step(p, value)
	if not self.enabled then
		return
	end

	local v = math.clamp(p * 6, 0, 1)
	self.grain += (self.targetGrain - self.grain) * v
	self.scan += (self.targetScan - self.scan) * v
	self.vignette += (self.targetVig - self.vignette) * v
	self.glitch += (self.targetGlitch - self.glitch) * v

	local v2 = 1 - math.clamp(self.vignette, 0, 1)

	if self.vigLabel then
		self.vigLabel.ImageTransparency = v2 * 0.9
	elseif self.vigEdges then
		for _, vigEdge in ipairs(self.vigEdges) do
			vigEdge.BackgroundTransparency = v2 * 0.95
		end
	end

	self.grainClock += p

	if self.grainClock >= 1 / (self.low and 12 or 24) then
		self.grainClock = 0
		local v3 = math.clamp(self.grain, 0, 1)

		if self.grainLabel then
			self.grainLabel.Position = UDim2.fromOffset(-random:NextInteger(0, 128), -random:NextInteger(0, 128))
			self.grainLabel.ImageTransparency = 1 - v3 * 0.34 * random:NextNumber(0.85, 1.15)
		elseif self.dots then
			local viewportSize = self.camera.ViewportSize

			for _, dot in ipairs(self.dots) do
				dot.Position = UDim2.fromOffset(
					random:NextInteger(0, viewportSize.X),
					random:NextInteger(0, viewportSize.Y)
				)
				dot.BackgroundColor3 = random:NextInteger(0, 1) == 0 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
				dot.BackgroundTransparency = 1 - v3 * 0.55
			end
		end
	end

	self.rollY = (self.rollY + p * 22) % 4

	if self.scanLabel then
		self.scanLabel.Position = UDim2.fromOffset(0, -4 + self.rollY)
		self.scanLabel.ImageTransparency = 1 - math.clamp(self.scan, 0, 1) * 0.55
	end

	local viewportSize = self.camera.ViewportSize
	local v3 = os.clock() % 8 / 8
	self.roll.Position = UDim2.fromOffset(0, -140 + (viewportSize.Y + 140) * v3)
	self.roll.BackgroundTransparency = 1
	local uiGradient = self.roll:FindFirstChildOfClass("UIGradient")

	if uiGradient then
		local v4 = 1 - math.clamp(self.scan, 0, 1) * 0.07
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, v4),
			NumberSequenceKeypoint.new(1, 1)
		})

		self.roll.BackgroundTransparency = 0
	end

	self.glitchTimer -= p

	if self.glitchTimer <= 0 then
		self.glitchTimer = random:NextNumber(0.4, 2.2) / math.max(self.glitch, 0.05)

		if self.glitch > 0.05 then
			local band = self.bands[random:NextInteger(1, #self.bands)]

			if not band.active then
				band.active = true
				band.y = random:NextNumber(0, 0.95)
				band.speed = random:NextNumber(0.3, 1.2)
				band.life = random:NextNumber(0.08, 0.3)
				band.frame.Size = UDim2.new(1, 0, 0, random:NextInteger(4, 28))
			end
		end
	end

	for _, band in ipairs(self.bands) do
		if not band.active then
			continue
		end

		band.life -= p
		band.y += band.speed * p
		band.frame.Position = UDim2.fromScale(0, band.y % 1)
		band.frame.BackgroundTransparency = 0.82 + random:NextNumber(0, 0.12)

		if not (band.life <= 0) then
			continue
		end

		band.active = false
		band.frame.BackgroundTransparency = 1
	end

	if self.focusTarget and not self.low then
		self.focus += (self.focusTarget - self.focus) * math.clamp(p * 5, 0, 1)
		local v4 = value or 1
		self.dof.FocusDistance = self.focus
		self.dof.InFocusRadius = math.max(8, self.focus * 0.55 / v4)
		self.dof.NearIntensity = math.clamp(0.12 + 0.1 * v4, 0, 0.6)
		self.dof.FarIntensity = math.clamp(0.1 + 0.12 * v4, 0, 0.7)
	end
end

function GCamFx:Destroy()
	self.enabled = false

	for _, v in ipairs({ self.cc, self.bloom, self.blur, self.dof, self.root }) do
		pcall(function()
			v:Destroy()
		end)
	end

	for _, v in ipairs({ self.grainImg, self.scanImg, self.vigImg }) do
		pcall(function()
			v:Destroy()
		end)
	end
end

return GCamFx