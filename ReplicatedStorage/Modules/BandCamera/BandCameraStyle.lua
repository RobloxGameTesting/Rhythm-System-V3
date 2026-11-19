local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BandCameraConfig = require(script.Parent:WaitForChild("BandCameraConfig"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))
local Style = BandCameraConfig.Style

local modeSet = {}
local styleNameSet = {}
local styleNames = {}
local effectNameSet = {}
local BandCameraStyle = {}

for _, mode in ipairs(Style.Modes) do
	modeSet[mode] = true
end

for _, styleName in ipairs(Style.StyleNames) do
	styleNameSet[styleName] = true
	styleNames[styleName:lower()] = styleName
end

for _, effectName in ipairs(Style.EffectNames) do
	effectNameSet[effectName] = true
end

local v = { Mode = Style.DefaultMode, Style = "Auto", Effects = {}, Intensity = 0.15 }
BandCameraStyle.DefaultIntensity = 0.15

local function resetSettings() -- 1 equivalent call inferred from this helper
	v.Mode = Style.DefaultMode
	v.Style = "Auto"
	v.Intensity = 0.15

	for _, effectName in ipairs(Style.EffectNames) do
		v.Effects[effectName] = true
	end
end

v.Mode = Style.DefaultMode
v.Style = "Auto"
v.Intensity = 0.15
local v2 = {}

for _, effectName in ipairs(Style.EffectNames) do
	v.Effects[effectName] = true
end

local function changed()
	for _, callback in ipairs(v2) do
		local success, result = pcall(callback)

		if not success then
			warn("[BandCameraStyle] listener error:", result)
		end
	end
end

function BandCameraStyle.OnChanged(p)
	table.insert(v2, p)
end

function BandCameraStyle.GetSettings()
	return {
		Mode = v.Mode,
		Style = v.Style,
		Effects = table.clone(v.Effects),
		Intensity = v.Intensity
	}
end

function BandCameraStyle.SetIntensity(value)
	if type(value) ~= "number" or value ~= value then
		return
	end

	local intensity = math.floor(math.clamp(value, 0, 1) * 100 + 0.5) / 100

	if v.Intensity ~= intensity then
		v.Intensity = intensity
		changed()
	end
end

function BandCameraStyle.SetMode(mode)
	if modeSet[mode] and v.Mode ~= mode then
		v.Mode = mode
		changed()
	end
end

function BandCameraStyle.CycleMode()
	local index = table.find(Style.Modes, v.Mode) or 1
	BandCameraStyle.SetMode(Style.Modes[index % #Style.Modes + 1])
end

function BandCameraStyle.SetStyleOverride(style)
	if (style == "Auto" or styleNameSet[style]) and v.Style ~= style then
		v.Style = style
		changed()
	end
end

function BandCameraStyle.SetEffect(p, p2)
	if effectNameSet[p] and type(p2) == "boolean" and v.Effects[p] ~= p2 then
		v.Effects[p] = p2
		changed()
	end
end

function BandCameraStyle.Reset()
	resetSettings() -- inferred equivalent call
	changed()
end

function BandCameraStyle.Export()
	return BandCameraStyle.GetSettings()
end

function BandCameraStyle.Import(data): boolean
	if type(data) ~= "table" then
		return false
	end

	if modeSet[data.Mode] then
		v.Mode = data.Mode
	end

	if data.Style == "Auto" or styleNameSet[data.Style] then
		v.Style = data.Style
	end

	if type(data.Intensity) == "number" and data.Intensity == data.Intensity then
		v.Intensity = math.floor(math.clamp(data.Intensity, 0, 1) * 100 + 0.5) / 100
	else
		v.Intensity = 0.15
	end

	if type(data.Effects) == "table" then
		for k in pairs(effectNameSet) do
			if type(data.Effects[k]) == "boolean" then
				v.Effects[k] = data.Effects[k]
			end
		end
	end

	changed()
	return true
end

local v3 = false
local v4 = nil
local v5 = nil
local v6 = nil

local function genreStyleFor(p)
	local success, result = pcall(function()
		return require(Modules:WaitForChild("SongConfig", 5))
	end)

	if success then
		if type(result) == "table" then
			success = result.Songs and result.Songs[p]
		else
			success = false
		end
	end

	local genre = success and success.Genre

	if type(genre) ~= "string" then
		return nil
	end

	local lower = genre:lower()

	for _, v7 in ipairs(Style.GenreStyle) do
		if lower:find(v7[1], 1, true) then
			return v7[2]
		end
	end

	return nil
end

function BandCameraStyle.SetSong(p)
	v4 = p and genreStyleFor(p) or nil
end

local function resolveStyle(p)
	if v.Style ~= "Auto" and styleNameSet[v.Style] then
		return v.Style
	end

	if not p then
		return Style.DefaultStyle
	end

	if type(p.style) == "string" and styleNames[p.style:lower()] then
		return styleNames[p.style:lower()]
	end

	if v4 and Style.GenreOverridableShots[p.shot] then
		return v4
	end

	return Style.ShotStyle[p.shot] or Style.DefaultStyle
end

function BandCameraStyle.GetCurrentStyleName()
	return v3 and v6 or nil
end

local bandCameraFX = nil
local v7 = nil
local v8 = {}
local bandCameraFX_CC = nil
local bandCameraFX_Blur = nil
local v9 = {}
local v10 = {}
local total = 0
local v11 = 0
local v12 = 0

local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 0)

local function zeroCur()
	v9 = {
		grain = 0,
		scan = 0,
		vig = 0,
		dust = 0,
		glitch = 0,
		sat = 0,
		con = 0,
		blur = 0,
		tint = color
	}
	v10 = {}
	total = 0
	v11 = 0
	v12 = 0
end
zeroCur()

local function newFrame(parent, items) -- 7 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = color2

	for k, item in pairs(items) do
		frame[k] = item
	end

	frame.Parent = parent
	return frame
end

local function textureId(p) -- 4 equivalent calls inferred from this helper
	local selected = Style.Textures and Style.Textures[p]

	if type(selected) == "string" and selected ~= "" then
		return selected
	end

	return nil
end

local function newImage(parent, p, image)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = image
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ImageTransparency = 1
	local v13 = Style.TextureTile and Style.TextureTile[p]

	if v13 then
		imageLabel.ScaleType = Enum.ScaleType.Tile
		imageLabel.TileSize = UDim2.fromOffset(v13.X, v13.Y)
	else
		imageLabel.ScaleType = Enum.ScaleType.Stretch
	end

	imageLabel.Parent = parent
	return imageLabel
end

local function clearPost()
	if bandCameraFX_CC then
		bandCameraFX_CC:Destroy()
		bandCameraFX_CC = nil
	end

	if bandCameraFX_Blur then
		bandCameraFX_Blur:Destroy()
		bandCameraFX_Blur = nil
	end

	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		for _, child in ipairs(currentCamera:GetChildren()) do
			if child.Name == "BandCameraFX_CC" or child.Name == "BandCameraFX_Blur" then
				child:Destroy()
			end
		end
	end
end

local function teardown()
	if bandCameraFX then
		bandCameraFX:Destroy()
	end

	bandCameraFX = nil
	v7 = nil
	v8 = {}
	clearPost()
	v10 = {}
end

local function build(): boolean
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	local currentCamera = Workspace.CurrentCamera

	if not (playerGui and currentCamera) then
		return false
	end

	teardown()

	bandCameraFX = Instance.new("ScreenGui")
	bandCameraFX.Name = "BandCameraFX"
	bandCameraFX.ResetOnSpawn = false
	bandCameraFX.IgnoreGuiInset = true
	bandCameraFX.DisplayOrder = Style.DisplayOrder
	bandCameraFX.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	bandCameraFX.Enabled = false
	bandCameraFX.Parent = playerGui
	v7 = newFrame(bandCameraFX, { -- inferred equivalent call
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true
	})
	v8 = {}
	local image = textureId("Vignette") -- inferred equivalent call

	if image then
		v8.vigImage = newImage(v7, "Vignette", image)
	else
		v8.vigEdges = {}
		local v13 = {
			{
				anchor = Vector2.new(0, 0),
				pos = UDim2.fromScale(0, 0),
				size = UDim2.fromScale(1, 0.32),
				rot = 90
			},
			{
				anchor = Vector2.new(0, 1),
				pos = UDim2.fromScale(0, 1),
				size = UDim2.fromScale(1, 0.32),
				rot = 270
			},
			{
				anchor = Vector2.new(0, 0),
				pos = UDim2.fromScale(0, 0),
				size = UDim2.fromScale(0.22, 1),
				rot = 0
			},
			{
				anchor = Vector2.new(1, 0),
				pos = UDim2.fromScale(1, 0),
				size = UDim2.fromScale(0.22, 1),
				rot = 180
			}
		}

		for _, v14 in ipairs(v13) do
			local v15 = newFrame(v7, { -- inferred equivalent call
				AnchorPoint = v14.anchor,
				Position = v14.pos,
				Size = v14.size,
				Visible = false
			})
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Rotation = v14.rot
			uiGradient.Parent = v15
			table.insert(v8.vigEdges, { frame = v15, grad = uiGradient })
		end
	end

	local image2 = textureId("Scanlines") -- inferred equivalent call

	if image2 then
		v8.scanImage = newImage(v7, "Scanlines", image2)
	else
		v8.scanFrame = newFrame(v7, { -- inferred equivalent call
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false
		})
		v8.scanLines = {}
		local scanlineSpacing = Style.ScanlineSpacing or 5

		for i = 0, math.clamp(math.ceil(currentCamera.ViewportSize.Y / scanlineSpacing), 40, 320) - 1 do
			local scanLines = v8.scanLines
			local v13 = #v8.scanLines + 1
			scanLines[v13] = newFrame(v8.scanFrame, { -- inferred equivalent call
				Position = UDim2.fromOffset(0, i * scanlineSpacing),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundTransparency = 1
			})
		end
	end

	v8.band = newFrame(v7, { -- inferred equivalent call
		BackgroundColor3 = color,
		Size = UDim2.fromScale(1, 0.06),
		Visible = false
	})
	v8.bandGrad = Instance.new("UIGradient")
	v8.bandGrad.Rotation = 90
	v8.bandGrad.Parent = v8.band
	local image3 = textureId("Grain") -- inferred equivalent call

	if image3 then
		v8.grainImage = newImage(v7, "Grain", image3)
		v8.grainImage.Size = UDim2.fromScale(1.2, 1.2)
	else
		v8.grain = {}

		for i = 1, Style.GrainCount do
			local grain = v8.grain
			grain[i] = newFrame(v7, { -- inferred equivalent call
				BackgroundColor3 = i % 2 == 0 and color or color2,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(2, 2),
				Visible = false
			})
		end
	end

	local image4 = textureId("Dust") -- inferred equivalent call

	if image4 then
		v8.dustImage = newImage(v7, "Dust", image4)
	else
		local v13 = v8
		v8.specks = {}
		v13.scratches = {}

		for i = 1, Style.DustSpecks do
			local specks = v8.specks
			local parent = v7
			local v14 = {
				BackgroundColor3 = i % 3 == 0 and color or Color3.fromRGB(20, 20, 20),
				Visible = false
			}
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = color2

			local v15 = { f = 0, t = 0 }

			for k, v16 in pairs(v14) do
				frame[k] = v16
			end

			frame.Parent = parent

			v15.f = frame
			v15.t = math.random() * 0.3
			specks[i] = v15
		end

		for i = 1, Style.DustScratches do
			local scratches = v8.scratches
			local parent = v7
			local v14 = {
				BackgroundColor3 = color,
				Size = UDim2.new(0, 1, 0.3, 0),
				Visible = false
			}
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = color2

			local v15 = { f = 0, t = 0 }

			for k, v16 in pairs(v14) do
				frame[k] = v16
			end

			frame.Parent = parent

			v15.f = frame
			v15.t = math.random() * 0.3
			scratches[i] = v15
		end
	end

	v8.glitch = {}

	for i = 1, 4 do
		local glitch = v8.glitch
		glitch[i] = newFrame(v7, { -- inferred equivalent call
			BackgroundColor3 = color,
			Size = UDim2.fromScale(1, 0.02),
			Visible = false
		})
	end

	bandCameraFX_CC = Instance.new("ColorCorrectionEffect")
	bandCameraFX_CC.Name = "BandCameraFX_CC"
	bandCameraFX_CC.Enabled = false
	bandCameraFX_CC.Parent = currentCamera
	bandCameraFX_Blur = Instance.new("BlurEffect")
	bandCameraFX_Blur.Name = "BandCameraFX_Blur"
	bandCameraFX_Blur.Size = 0
	bandCameraFX_Blur.Enabled = false
	bandCameraFX_Blur.Parent = currentCamera
	return true
end

function BandCameraStyle.Begin()
	v3 = true
	v5 = nil
	zeroCur()
end

function BandCameraStyle.End()
	v3 = false
	v5 = nil
	v6 = nil
	teardown()
	zeroCur()
end

local function setVignette(vig)
	local v13 = math.clamp(vig, 0, 1) * 0.85

	if v8.vigImage then
		v8.vigImage.ImageTransparency = 1 - v13
		return
	end

	local numberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - v13),
		NumberSequenceKeypoint.new(0.5, 1 - v13 * 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})

	for _, vigEdge in ipairs(v8.vigEdges) do
		vigEdge.grad.Transparency = numberSequence
		vigEdge.frame.Visible = v13 > 0.01
	end
end

local function setBand(p)
	v8.bandGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 1 - p),
		NumberSequenceKeypoint.new(1, 1)
	})
end

local function changedBy(p, p2, p3): boolean
	if v10[p] ~= nil and not (p3 < math.abs(v10[p] - p2)) then
		return false
	end

	v10[p] = p2
	return true
end

function BandCameraStyle.Update(value, p, p2, p3)
	if not v3 then
		return
	end

	local v13 = math.clamp(value or 0.016, 0, 0.1)

	if p then
		v5 = p
	else
		p = v5
	end

	local style = resolveStyle(p)
	v6 = style
	local v14 = Style.Styles[style] or Style.Styles[Style.DefaultStyle]
	local effects = v.Effects
	local mode = v.Mode
	local v15 = (mode == "Full" and 1 or mode == "Light" and Style.LightScale or 0) * (Style.Strength or 1)
	local v16 = math.clamp(v.Intensity or 0.15, 0, 1)
	local v17 = v15 * v16
	local v18 = p3 and 0 or v17
	local v19

	if mode == "Full" then
		v19 = not p3
	else
		v19 = false
	end

	local v20 = effects.Grain and v14.Grain * v18 or 0
	local v21 = effects.Scanlines and v19 and v14.Scanlines * v16 or 0
	local v22 = effects.Vignette and v14.Vignette * v18 or 0
	local v23 = effects.Dust and v14.Dust * v18 or 0
	local v24 = effects.Glitch and v19 and v14.Glitch * v16 or 0
	local v25 = effects.Grade and v14.Saturation * v18 or 0
	local v26 = effects.Grade and v14.Contrast * v18 or 0
	local v27 = effects.Grade and v14.Blur * v18 * 2 or 0
	local v28 = effects.Grade and color:Lerp(v14.Tint, v18) or color

	local v29 = 1 - math.exp(-Style.FadeSpeed * v13)
	v9.grain += (v20 - v9.grain) * v29
	v9.scan += (v21 - v9.scan) * v29
	v9.vig += (v22 - v9.vig) * v29
	v9.dust += (v23 - v9.dust) * v29
	v9.glitch += (v24 - v9.glitch) * v29
	v9.sat += (v25 - v9.sat) * v29
	v9.con += (v26 - v9.con) * v29
	v9.blur += (v27 - v9.blur) * v29
	v9.tint = v9.tint:Lerp(v28, v29)

	if v16 <= 0.02 then
		v12 = 0
	end

	if v19 and effects.Glitch and v14.Glitch > 0 and v16 > 0.02 then
		if p2 and v14.Glitch > 0.2 then
			v12 = Style.GlitchSeconds * (0.6 + v14.Glitch)
		elseif v12 <= 0 and math.random() < v14.Glitch * v16 * Style.GlitchRandomRate * v13 then
			v12 = Style.GlitchSeconds * 0.8
		end
	end

	if
		v9.grain > 0.01
		or v9.scan > 0.01
		or v9.vig > 0.01
		or v9.dust > 0.01
		or v9.glitch > 0.01
		or math.abs(v9.sat) > 0.01
		or math.abs(v9.con) > 0.01
		or v9.blur > 0.05
		or v12 > 0
	then
		if not (bandCameraFX and bandCameraFX.Parent or build()) then
			return
		end

		bandCameraFX.Enabled = true

		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			if bandCameraFX_CC and bandCameraFX_CC.Parent ~= currentCamera then
				bandCameraFX_CC.Parent = currentCamera
			end

			if bandCameraFX_Blur and bandCameraFX_Blur.Parent ~= currentCamera then
				bandCameraFX_Blur.Parent = currentCamera
			end
		end

		local vig = v9.vig
		local flag

		if v10.vig == nil or math.abs(v10.vig - vig) > 0.01 then
			v10.vig = vig
			flag = true
		else
			flag = false
		end

		if flag then
			setVignette(v9.vig)
		end

		if v8.scanImage then
			v8.scanImage.ImageTransparency = 1 - math.clamp(v9.scan, 0, 1) * 0.6
		elseif v8.scanFrame then
			v8.scanFrame.Visible = v9.scan > 0.01
			local scan = v9.scan
			local flag2

			if v10.scan == nil or math.abs(v10.scan - scan) > 0.02 then
				v10.scan = scan
				flag2 = true
			else
				flag2 = false
			end

			if flag2 then
				local backgroundTransparency = 1 - math.clamp(v9.scan, 0, 1) * 0.45

				for _, scanLine in ipairs(v8.scanLines) do
					scanLine.BackgroundTransparency = backgroundTransparency
				end
			end
		end

		local band = math.clamp(v9.glitch, 0, 1) * 0.14
		v8.band.Visible = band > 0.004

		if v8.band.Visible then
			v11 = (v11 + v13 * 0.09) % 1.15
			v8.band.Position = UDim2.fromScale(0, v11 - 0.06)
			local flag2

			if v10.band == nil or math.abs(v10.band - band) > 0.004 then
				v10.band = band
				flag2 = true
			else
				flag2 = false
			end

			if flag2 then
				setBand(band)
			end
		end

		total += v13

		if (mode == "Light" and 0.125 or 1 / 14) <= total then
			total = 0

			if v8.grain then
				local v30 = math.floor(#v8.grain * math.clamp(v9.grain, 0, 1) + 0.5)

				for i, v31 in ipairs(v8.grain) do
					if i <= v30 then
						local v32 = math.random(1, 3)
						v31.Size = UDim2.fromOffset(v32, v32)
						v31.Position = UDim2.fromScale(math.random(), math.random())
						v31.BackgroundTransparency = 1 - (0.1 + 0.3 * v9.grain * (0.4 + 0.6 * math.random()))
						v31.Visible = true
					else
						v31.Visible = false
					end
				end
			elseif v8.grainImage then
				v8.grainImage.Position = UDim2.fromScale(-0.1 * math.random(), -0.1 * math.random())
				v8.grainImage.ImageTransparency = 1 - math.clamp(v9.grain, 0, 1) * 0.5
			end

			if v8.dustImage then
				v8.dustImage.Position = UDim2.fromScale(-0.05 * math.random(), -0.05 * math.random())
				v8.dustImage.ImageTransparency = 1 - math.clamp(v9.dust, 0, 1) * 0.5 * (0.6 + 0.4 * math.random())
			end
		end

		if v8.specks then
			for _, speck in ipairs(v8.specks) do
				speck.t -= v13

				if not (speck.t <= 0) then
					continue
				end

				if math.random() < v9.dust then
					speck.f.Size = UDim2.fromOffset(math.random(2, 5), math.random(2, 4))
					speck.f.Position = UDim2.fromScale(math.random(), math.random())
					speck.f.BackgroundTransparency = 0.35 + math.random() * 0.4
					speck.f.Visible = true
					speck.t = 0.06 + math.random() * 0.3
				else
					speck.f.Visible = false
					speck.t = 0.15 + math.random() * 0.3
				end
			end

			for _, scratch in ipairs(v8.scratches) do
				scratch.t -= v13

				if not (scratch.t <= 0) then
					continue
				end

				if math.random() < v9.dust * 0.5 then
					scratch.f.Size = UDim2.new(0, 1, 0.12 + math.random() * 0.4, 0)
					scratch.f.Position = UDim2.fromScale(math.random(), math.random() * 0.6)
					scratch.f.BackgroundTransparency = 0.7 + math.random() * 0.2
					scratch.f.Visible = true
					scratch.t = 0.05 + math.random() * 0.15
				else
					scratch.f.Visible = false
					scratch.t = 0.2 + math.random() * 0.5
				end
			end
		end

		local brightness

		if v12 > 0 then
			v12 -= v13
			local visible = v12 > 0

			for i, v30 in ipairs(v8.glitch) do
				v30.Visible = visible

				if not visible then
					continue
				end

				v30.Position = UDim2.fromScale((math.random() - 0.5) * 0.08, math.random())
				v30.Size = UDim2.fromScale(1, 0.006 + math.random() * 0.05)
				v30.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(255, 60, 80) or Color3.fromRGB(60, 230, 255)
				v30.BackgroundTransparency = 1 - (1 - (0.55 + math.random() * 0.25)) * v16
			end

			brightness = visible and v16 * 0.05 or 0
		else
			brightness = 0
		end

		if bandCameraFX_CC then
			bandCameraFX_CC.Enabled = true
			bandCameraFX_CC.Saturation = v9.sat
			bandCameraFX_CC.Contrast = v9.con
			bandCameraFX_CC.TintColor = v9.tint
			bandCameraFX_CC.Brightness = brightness
		end

		if bandCameraFX_Blur then
			bandCameraFX_Blur.Enabled = v9.blur > 0.05
			bandCameraFX_Blur.Size = v9.blur
		end
	elseif bandCameraFX then
		bandCameraFX.Enabled = false

		if bandCameraFX_CC then
			bandCameraFX_CC.Enabled = false
		end

		if bandCameraFX_Blur then
			bandCameraFX_Blur.Enabled = false
		end
	end
end

function BandCameraStyle.AdjustFov(p)
	if not v3 or v.Mode == "Off" or not v.Effects.Fisheye then
		return p
	end

	if v6 == "GoPro" then
		return (math.min(math.max(p, SessionCameraSettings.GetFirstPersonFOV()), Style.MaxFov))
	end

	return p
end

return BandCameraStyle