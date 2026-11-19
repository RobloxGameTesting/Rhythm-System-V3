local RailHud3D = {}

local function rbx(p)
	return "rbxassetid://" .. p
end

local v = {
	Fill = "rbxassetid://128873361938637",
	Glass = "rbxassetid://79499188487053",
	Band = "rbxassetid://114006020867422",
	Ring = "rbxassetid://74454029550834",
	Digits = "rbxassetid://121555887807387"
}

local color = Color3.new(1, 1, 1)

local v2 = {
	TubeW = 0.5,
	TubeL = 15,
	ZNear = -0.2,
	TY = 0.3,
	Gap = 0.02,
	RingD = 2.3,
	Leds = 10,
	ZoneLow = 0.33,
	ZoneHigh = 0.66
}

local v3 = nil

local function mixc(color2, color3, value) -- 5 equivalent calls inferred from this helper
	return color2:Lerp(color3, (math.clamp(value, 0, 1)))
end

local color2 = Color3.fromRGB(226, 44, 32)
local color3 = Color3.fromRGB(238, 196, 28)
local color4 = Color3.fromRGB(70, 226, 72)

local function rockColor(p)
	if p < 0.29000000000000004 then
		return color2
	end

	if p < 0.37 then
		return mixc(color2, color3, (p - 0.29000000000000004) / 0.08)
	end

	if p < 0.62 then
		return color3
	end

	if p < 0.7000000000000001 then
		return mixc(color3, color4, (p - 0.62) / 0.08)
	end

	return color4
end

local function rockGrad(p)
	if p < 0.24000000000000002 then
		return color2
	end

	if p < 0.42000000000000004 then
		return mixc(color2, color3, (p - 0.24000000000000002) / 0.18)
	end

	if p < 0.5700000000000001 then
		return color3
	end

	if p < 0.75 then
		return mixc(color3, color4, (p - 0.5700000000000001) / 0.18)
	end

	return color4
end

local function skillColor(starSkill) -- 1 equivalent call inferred from this helper
	if starSkill < 0.5 then
		return mixc(color2, color3, starSkill / 0.5)
	end

	return mixc(color3, color4, (starSkill - 0.5) / 0.5)
end

function RailHud3D.IsBuilt(): boolean
	return v3 ~= nil
end

function RailHud3D.Destroy()
	if not v3 then
		return
	end

	for _, part in ipairs(v3.parts) do
		if part.Parent then
			part:Destroy()
		end
	end

	for _, label in ipairs(v3.labels) do
		if label.Parent then
			label:Destroy()
		end
	end

	v3 = nil
end

function RailHud3D.Build(ctx)
	RailHud3D.Destroy()
	v3 = {
		ctx = ctx,
		parts = {},
		labels = {},
		tubes = {},
		leds = {},
		t = 0,
		lastMult = 1,
		pop = 0,
		arcT = 0,
		arcs = {},
		ringZ = 0
	}
	local highwayCF = ctx.highwayCF
	local totalWidth = ctx.totalWidth
	local railW = ctx.railW or 0.5

	local function box(size, cframe, color5, p, value) -- 11 equivalent calls inferred from this helper
		local part = Instance.new("Part")
		part.Size = size
		part.CFrame = cframe
		part.Color = color5
		part.Material = p or Enum.Material.SmoothPlastic
		part.Transparency = value or 0
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Parent = ctx.worldModel
		table.insert(v3.parts, part)
		return part
	end

	local function disc(p, p2, p3, color5, p4, value)
		local part = box(Vector3.new(p2, p, p), p3 * CFrame.Angles(0, 0, 1.5707963267948966), color5, p4, value) -- inferred equivalent call
		part.Shape = Enum.PartType.Cylinder
		return part
	end

	local function texOn(parent, face, texture, studsPerTileU, studsPerTileV, p, value)
		local texture2 = Instance.new("Texture")
		texture2.Texture = texture
		texture2.Face = face
		texture2.StudsPerTileU = studsPerTileU
		texture2.StudsPerTileV = studsPerTileV
		texture2.Color3 = p or color
		texture2.Transparency = value or 0
		texture2.Parent = parent
		return texture2
	end

	local function label(image, value) -- 4 equivalent calls inferred from this helper
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.Image = image
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.ZIndex = value or 7
		imageLabel.Active = false
		imageLabel.Visible = false
		imageLabel.Parent = ctx.fxLayer
		table.insert(v3.labels, imageLabel)
		return imageLabel
	end

	local function cyl(p, p2, p3, color5, smoothPlastic, value) -- 1 equivalent call inferred from this helper
		local part = box( -- inferred equivalent call
			Vector3.new(p, p2, p2),
			p3 * CFrame.Angles(0, 1.5707963267948966, 0),
			color5,
			smoothPlastic,
			value
		)
		part.Shape = Enum.PartType.Cylinder
		return part
	end

	local function ball(p, cframe, color5, p2, value)
		local part = box(Vector3.new(p, p, p), cframe, color5, p2, value) -- inferred equivalent call
		part.Shape = Enum.PartType.Ball
		return part
	end

	local smoothPlastic = Enum.Material.SmoothPlastic
	local neon = Enum.Material.Neon
	local corrodedMetal = Enum.Material.CorrodedMetal
	local color5 = Color3.fromRGB(62, 52, 46)

	local function tube(p, kind)
		local xt = p * (totalWidth / 2 + railW + 0.02 + 0.25)
		local v4 = { kind = kind, xt = xt, disp = 0, segs = {} }
		local function at(p2, p3, p4) -- 13 equivalent calls inferred from this helper
			return highwayCF * CFrame.new(p2, p3, p4)
		end

		local parent = box( -- inferred equivalent call
			Vector3.new(0.7, 0.08, 16),
			at(xt, 0.05, -7.699999999999999), -- inferred equivalent call
			Color3.fromRGB(30, 27, 25),
			Enum.Material.Metal
		)

		if ctx.texRail then
			local top = Enum.NormalId.Top
			local texRail = ctx.texRail
			local texture = Instance.new("Texture")
			texture.Texture = texRail
			texture.Face = top
			texture.StudsPerTileU = 1.6
			texture.StudsPerTileV = 6
			texture.Color3 = color
			texture.Transparency = 0
			texture.Parent = parent
		end

		local v5 = at(xt, 0.3, -7.699999999999999) -- inferred equivalent call
		local color6 = Color3.fromRGB(150, 175, 185)
		local cframe = v5 * CFrame.Angles(0, 1.5707963267948966, 0)
		local part = Instance.new("Part")
		part.Size = Vector3.new(15, 0.5, 0.5)
		part.CFrame = cframe
		part.Color = color6
		part.Material = smoothPlastic or Enum.Material.SmoothPlastic
		part.Transparency = 0.72
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Parent = ctx.worldModel
		table.insert(v3.parts, part)

		part.Shape = Enum.PartType.Cylinder
		local cframe2 = at(xt - 0.15, 0.44999999999999996, -7.699999999999999) * CFrame.Angles(0, 1.5707963267948966, 0) -- inferred equivalent call
		local part2 = Instance.new("Part")
		part2.Size = Vector3.new(14.2, 0.07, 0.07)
		part2.CFrame = cframe2
		part2.Color = color
		part2.Material = neon or Enum.Material.SmoothPlastic
		part2.Transparency = 0.35
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Parent = ctx.worldModel
		table.insert(v3.parts, part2)

		part2.Shape = Enum.PartType.Cylinder
		local cframe3 = at(xt + 0.155, 0.19, -9.2) * CFrame.Angles(0, 1.5707963267948966, 0) -- inferred equivalent call
		local part3 = Instance.new("Part")
		part3.Size = Vector3.new(6.75, 0.05, 0.05)
		part3.CFrame = cframe3
		part3.Color = color
		part3.Material = neon or Enum.Material.SmoothPlastic
		part3.Transparency = 0.7
		part3.Anchored = true
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CanTouch = false
		part3.CastShadow = false
		part3.Parent = ctx.worldModel
		table.insert(v3.parts, part3)

		part3.Shape = Enum.PartType.Cylinder

		v4.tipR = 0.185
		local v6 = kind == "rock" and 12 or 1

		for i = 1, v6 do
			local f1 = (i - 1) / v6
			local f2 = i / v6
			local v7 = (f2 - f1) * 15
			local v8 = -0.2 - (f1 + f2) / 2 * 15
			local v9 = {
				f1 = f1,
				f2 = f2,
				dyn = kind ~= "rock"
			}
			local col2

			if kind == "rock" then
				local midpoint = (f1 + f2) / 2
				local zoneLow = v2.ZoneLow
				local zoneHigh = v2.ZoneHigh

				if midpoint < zoneLow - 0.09 then
					col2 = color2
				elseif midpoint < zoneLow + 0.09 then
					col2 = mixc(color2, color3, (midpoint - (zoneLow - 0.09)) / 0.18) -- inferred equivalent call
				elseif midpoint < zoneHigh - 0.09 then
					col2 = color3
				elseif midpoint < zoneHigh + 0.09 then
					col2 = mixc(color3, color4, (midpoint - (zoneHigh - 0.09)) / 0.18) -- inferred equivalent call
				else
					col2 = color4
				end

				if not col2 then
					col2 = color
				end
			else
				col2 = color
			end

			v9.col = col2
			local v10 = kind == "rock" and v9.col:Lerp(Color3.new(0, 0, 0), 0.74) or Color3.fromRGB(14, 40, 46)
			cyl(v7 + 0.03, 0.3478, at(xt, 0.3, v8), v10, smoothPlastic) -- inferred equivalent call
			local v11 = at(xt, 0.3, -0.2) -- inferred equivalent call
			local col = v9.col
			local cframe4 = v11 * CFrame.Angles(0, 1.5707963267948966, 0)
			local part4 = Instance.new("Part")
			part4.Size = Vector3.new(0.05, 0.37, 0.37)
			part4.CFrame = cframe4
			part4.Color = col
			part4.Material = smoothPlastic or Enum.Material.SmoothPlastic
			part4.Transparency = 1
			part4.Anchored = true
			part4.CanCollide = false
			part4.CanQuery = false
			part4.CanTouch = false
			part4.CastShadow = false
			part4.Parent = ctx.worldModel
			table.insert(v3.parts, part4)

			part4.Shape = Enum.PartType.Cylinder

			v9.fill = part4
			local cframe5 = at(xt, 0.3, -0.2) * CFrame.Angles(0, 1.5707963267948966, 0) -- inferred equivalent call
			local part5 = Instance.new("Part")
			part5.Size = Vector3.new(0.05, 0.2, 0.2)
			part5.CFrame = cframe5
			part5.Color = color
			part5.Material = neon or Enum.Material.SmoothPlastic
			part5.Transparency = 1
			part5.Anchored = true
			part5.CanCollide = false
			part5.CanQuery = false
			part5.CanTouch = false
			part5.CastShadow = false
			part5.Parent = ctx.worldModel
			table.insert(v3.parts, part5)

			part5.Shape = Enum.PartType.Cylinder

			v9.core = part5
			table.insert(v4.segs, v9)
		end

		local cframe4 = at(xt, 0.3, -0.2) -- inferred equivalent call
		local part4 = Instance.new("Part")
		part4.Size = Vector3.new(0.37, 0.37, 0.37)
		part4.CFrame = cframe4
		part4.Color = color
		part4.Material = smoothPlastic or Enum.Material.SmoothPlastic
		part4.Transparency = 1
		part4.Anchored = true
		part4.CanCollide = false
		part4.CanQuery = false
		part4.CanTouch = false
		part4.CastShadow = false
		part4.Parent = ctx.worldModel
		table.insert(v3.parts, part4)

		part4.Shape = Enum.PartType.Ball

		v4.tip = part4
		local cframe5 = at(xt, 0.3, -0.2) -- inferred equivalent call
		local part5 = Instance.new("Part")
		part5.Size = Vector3.new(0.2, 0.2, 0.2)
		part5.CFrame = cframe5
		part5.Color = color
		part5.Material = neon or Enum.Material.SmoothPlastic
		part5.Transparency = 1
		part5.Anchored = true
		part5.CanCollide = false
		part5.CanQuery = false
		part5.CanTouch = false
		part5.CastShadow = false
		part5.Parent = ctx.worldModel
		table.insert(v3.parts, part5)

		part5.Shape = Enum.PartType.Ball

		v4.tipCore = part5

		local v7 = kind == "rock" and { 0.33, 0.66 } or ctx.thresholds or { 0.33, 0.6, 0.9 }

		for _, v8 in ipairs(v7) do
			local v9 = at(xt, 0.3, -0.2 - v8 * 15) -- inferred equivalent call
			local color7 = Color3.fromRGB(190, 176, 150)
			local metal = Enum.Material.Metal
			local part6 = box( -- inferred equivalent call
				Vector3.new(0.07, 0.45, 0.45),
				v9 * CFrame.Angles(0, 1.5707963267948966, 0),
				color7,
				metal
			)
			part6.Shape = Enum.PartType.Cylinder
		end

		local v8 = at(xt, 0.3, -0.1) -- inferred equivalent call
		local metal = Enum.Material.Metal
		local part6 = box(Vector3.new(0.2, 0.56, 0.56), v8 * CFrame.Angles(0, 1.5707963267948966, 0), color5, metal) -- inferred equivalent call
		part6.Shape = Enum.PartType.Cylinder
		local v9 = at(xt, 0.3, -15.149999999999999) -- inferred equivalent call
		local metal2 = Enum.Material.Metal
		local part7 = box(Vector3.new(0.2, 0.56, 0.56), v9 * CFrame.Angles(0, 1.5707963267948966, 0), color5, metal2) -- inferred equivalent call
		part7.Shape = Enum.PartType.Cylinder

		for _, v10 in ipairs({}) do
			local part8 = box( -- inferred equivalent call
				Vector3.new(0.28, 0.56, 0.56),
				at(xt, 0.3, v10) * CFrame.Angles(0, 1.5707963267948966, 0), -- inferred equivalent call
				color5,
				corrodedMetal
			)
			part8.Shape = Enum.PartType.Cylinder
		end

		if ctx.texGlow then
			v4.glow = label(ctx.texGlow, 6) -- inferred equivalent call
		end

		return v4
	end

	v3.rock = tube(-1, "rock")
	v3.star = tube(1, "star")

	local xt = v3.star.xt

	local v4 = v3
	v3.ringX = xt
	v4.ringZ = 1.9000000000000001

	local v5 = v3
	local v6 = highwayCF * CFrame.new(xt, 0.4, 1.9000000000000001)
	local neon2 = Enum.Material.Neon
	local halo = box(Vector3.new(0.04, 2.484, 2.484), v6 * CFrame.Angles(0, 0, 1.5707963267948966), color, neon2, 0.7) -- inferred equivalent call
	halo.Shape = Enum.PartType.Cylinder

	v5.halo = halo
	local v7 = highwayCF * CFrame.new(xt, 0.44, 1.9000000000000001)
	local color6 = Color3.fromRGB(12, 12, 14)
	local smoothPlastic2 = Enum.Material.SmoothPlastic
	local parent = box(Vector3.new(0.1, 2.3, 2.3), v7 * CFrame.Angles(0, 0, 1.5707963267948966), color6, smoothPlastic2) -- inferred equivalent call
	parent.Shape = Enum.PartType.Cylinder

	local decal = Instance.new("Decal")
	decal.Texture = v.Ring
	decal.Face = Enum.NormalId.Right
	decal.Parent = parent

	for i = 1, 10 do
		local leds = v3.leds
		leds[i] = box( -- inferred equivalent call
			Vector3.new(0.2, 0.08, 0.4),
			highwayCF * CFrame.new(xt + 0.25 + 0.2, 0.12, -0.8999999999999999 - (i - 1) * 0.72),
			Color3.fromRGB(28, 26, 24),
			Enum.Material.SmoothPlastic
		)
	end

	v3.dMain = label(v.Digits, 8) -- inferred equivalent call
	v3.dMain.ImageRectSize = Vector2.new(168, 280)
	v3.dX = label(v.Digits, 8) -- inferred equivalent call
	v3.dX.ImageRectSize = Vector2.new(168, 280)
	v3.dX.ImageRectOffset = Vector2.new(672, 280)

	if ctx.texLightning then
		for i = 1, 2 do
			local arcs = v3.arcs
			arcs[i] = { l = label(ctx.texLightning), life = 0 } -- inferred equivalent call
		end
	end
end

local function setDigit(dMain, p) -- 1 equivalent call inferred from this helper
	dMain.ImageRectOffset = Vector2.new(p % 6 * 168, math.floor(p / 6) * 280)
end

local function tubePoint(p, p2, value)
	local ctx = v3.ctx
	local project = ctx.project(ctx.toWorld(p.xt, value or 0.3, p2))

	if not project then
		return nil, 0
	end

	local project2 = ctx.project(ctx.toWorld(p.xt - 0.25, value or 0.3, p2))
	local project3 = ctx.project(ctx.toWorld(p.xt + 0.25, value or 0.3, p2))
	return project, project2 and project3 and (project3 - project2).Magnitude or 0
end

local function updateTube(state, p, p2, p3, p4)
	local ctx = v3.ctx
	state.disp += (p2 - state.disp) * (1 - math.exp(-8 * p))
	local v4 = math.clamp(state.disp, 0, 1) * 15
	local v5 = math.max(v4 - state.tipR, 0)
	local v6 = v4 >= 0.06
	local v7 = p3
	local transparency = p4 and 0.6 or 0.15

	for _, seg in ipairs(state.segs) do
		local v8 = seg.f1 * 15
		local v9 = math.clamp(v5, v8, seg.f2 * 15) - v8

		if v6 and v9 > 0.015 then
			v7 = seg.dyn and p3 or seg.col

			seg.fill.Size = Vector3.new(v9, seg.fill.Size.Y, seg.fill.Size.Z)
			seg.fill.CFrame = ctx.highwayCF * CFrame.new(state.xt, 0.3, -0.2 - v8 - v9 / 2) * CFrame.Angles(0, 1.5707963267948966, 0)
			seg.fill.Color = v7
			seg.fill.Transparency = transparency
			seg.core.Size = Vector3.new(v9, seg.core.Size.Y, seg.core.Size.Z)
			seg.core.CFrame = seg.fill.CFrame
			seg.core.Color = v7:Lerp(color, 0.45)
			seg.core.Transparency = p4 and 0.8 or 0.2
		else
			seg.fill.Transparency = 1
			seg.core.Transparency = 1
		end
	end

	if v6 then
		local cframe = ctx.highwayCF * CFrame.new(state.xt, 0.3, -0.2 - v5)
		state.tip.CFrame = cframe
		state.tipCore.CFrame = cframe
		state.tip.Color = v7
		state.tip.Transparency = transparency
		state.tipCore.Color = v7:Lerp(color, 0.45)
		state.tipCore.Transparency = p4 and 0.8 or 0.2

		if state.glow then
			local v8, v9 = tubePoint(state, -0.2 - v4, 0.3)

			if v8 and v9 > 0 then
				local v10 = v9 * 3.4
				state.glow.Visible = true
				state.glow.Position = UDim2.fromOffset(v8.X, v8.Y)
				state.glow.Size = UDim2.fromOffset(v10, v10)
				state.glow.ImageColor3 = v7
				state.glow.ImageTransparency = p4 and 0.85 or 0.5 - math.sin(v3.t * 6) * 0.15
			else
				state.glow.Visible = false
			end
		end
	else
		state.tip.Transparency = 1
		state.tipCore.Transparency = 1

		if state.glow then
			state.glow.Visible = false
		end
	end
end

function RailHud3D.Update(p, data)
	if not v3 then
		return
	end

	v3.t += p
	local ctx = v3.ctx

	local v4 = math.clamp(data.rock or 0.5, 0, 1)
	local rock = v3.rock
	local zoneLow = v2.ZoneLow
	local zoneHigh = v2.ZoneHigh
	local v5

	if v4 < zoneLow - 0.04 then
		v5 = color2
	elseif v4 < zoneLow + 0.04 then
		v5 = mixc(color2, color3, (v4 - (zoneLow - 0.04)) / 0.08) -- inferred equivalent call
	elseif v4 < zoneHigh - 0.04 then
		v5 = color3
	elseif v4 < zoneHigh + 0.04 then
		v5 = mixc(color3, color4, (v4 - (zoneHigh - 0.04)) / 0.08) -- inferred equivalent call
	else
		v5 = color4
	end

	updateTube(rock, p, v4, v5, v4 < 0.18 and math.floor(v3.t * 8) % 2 == 0)

	local starActive = data.starActive == true
	local v6

	if starActive then
		v6 = data.starResource or 0
	else
		v6 = data.starMeter or 0
	end

	local v7

	if starActive then
		v7 = ctx.starColor or Color3.fromRGB(80, 220, 255)
	else
		v7 = skillColor(data.starSkill or 0.5) -- inferred equivalent call

		if (ctx.thresholds and ctx.thresholds[1] or 0.33) <= (data.starMeter or 0) then
			v7 = mixc(v7, color, math.sin(v3.t * 7) * 0.12 + 0.12) -- inferred equivalent call
		end
	end

	updateTube(v3.star, p, v6, v7, false)

	v3.arcT -= p

	for _, arc in ipairs(v3.arcs) do
		if not (arc.life > 0) then
			continue
		end

		arc.life -= p

		if arc.life <= 0 then
			arc.l.Visible = false
		end
	end

	if starActive and not data.low and #v3.arcs > 0 and v3.arcT <= 0 then
		v3.arcT = 0.1 + math.random() * 0.1
		local arc = v3.arcs[math.random(1, #v3.arcs)]
		local v8 = math.clamp(v3.star.disp, 0, 1) * 15

		if v8 > 0.5 then
			local v9 = -0.2 - math.random() * v8
			local v10, v11 = tubePoint(v3.star, v9, 0.3)

			if v10 and v11 > 0 then
				local v12 = v11 * 5
				arc.l.Position = UDim2.fromOffset(v10.X, v10.Y)
				arc.l.Size = UDim2.fromOffset(v12 * 0.62, v12)
				arc.l.Rotation = (math.random() - 0.5) * 40
				arc.l.ImageColor3 = v7:Lerp(color, 0.5)
				arc.l.ImageTransparency = 0.05
				arc.l.Visible = true
				arc.life = 0.07
			end
		end
	end

	local lastMult = math.max(1, (math.floor(data.mult or 1)))

	if v3.lastMult < lastMult then
		v3.pop = 1
	end

	v3.lastMult = lastMult
	v3.pop = math.max(0, v3.pop - p * 3.5)
	local v8 = (data.maxMult or 4) <= lastMult
	local color5 = starActive and Color3.fromRGB(140, 228, 255)
		or v8 and Color3.fromRGB(255, 184, 60)
		or Color3.fromRGB(236, 228, 212)
	v3.halo.Color = color5
	v3.halo.Transparency = (lastMult > 1 and 0.55 or 0.8) - 0.3 * v3.pop

	local ringX = v3.ringX
	local ringZ = v3.ringZ
	local project = ctx.project(ctx.toWorld(ringX, 0.46, ringZ))
	local project2 = ctx.project(ctx.toWorld(ringX + 0.7244999999999999, 0.46, ringZ))

	if project and project2 then
		local v9 = (project2 - project).Magnitude * 1.1
		local v10 = v9 * 0.6
		local v11 = 1 + 0.3 * v3.pop
		setDigit(v3.dMain, math.min(lastMult, 9)) -- inferred equivalent call
		v3.dMain.Size = UDim2.fromOffset(v10 * v11, v9 * v11)
		v3.dMain.Position = UDim2.fromOffset(project.X + v10 * 0.28, project.Y)
		v3.dMain.ImageColor3 = color5
		v3.dMain.Visible = true
		v3.dX.Size = UDim2.fromOffset(v10 * 0.62, v9 * 0.62)
		v3.dX.Position = UDim2.fromOffset(project.X - v10 * 0.5, project.Y + v9 * 0.12)
		v3.dX.ImageColor3 = color5
		v3.dX.Visible = true
	else
		v3.dMain.Visible = false
		v3.dX.Visible = false
	end

	local v9 = math.clamp(math.floor(data.ledLit or 0), 0, 10)
	local color6 = starActive and Color3.fromRGB(110, 225, 255) or Color3.fromRGB(110, 232, 70)

	for i, led in ipairs(v3.leds) do
		if i <= v9 then
			led.Color = color6
			led.Material = Enum.Material.Neon
		else
			led.Color = Color3.fromRGB(28, 26, 24)
			led.Material = Enum.Material.SmoothPlastic
		end
	end
end

return RailHud3D