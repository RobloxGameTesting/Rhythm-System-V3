local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local _ = {
	catchUp = 1.2,
	release = 1.8,
	lightScale = 0.12,
	brightnessScale = 0.15,
	diffuseScale = 0.25,
	specularScale = 0.4,
	atmoDensityScale = 0.35,
	atmoHazeScale = 0.3,
	atmoGlareScale = 0.3,
	rescanInterval = 30
}

local v = {
	{
		minX = -108.5,
		maxX = -79.5,
		minZ = -94.5,
		maxZ = -67.5,
		minY = 0.5,
		maxY = 11.9,
		edge = 3,
		vEdge = 1
	},
	{
		minX = -112,
		maxX = -61,
		minZ = -92,
		maxZ = -69,
		minY = 12,
		maxY = 80,
		edge = 4,
		vEdge = 1
	}
}

local StudioSlotConfig = require(script.Parent.StudioSlotConfig)
local v2 = v[1]
local v3 = { ["STAGE 2"] = true, ["STAGE 3"] = true, ["STAGE 4"] = true }
local v4 = {
	minX = -103,
	maxX = -42,
	minZ = -101,
	maxZ = -39,
	edge = 6,
	yNone = 1.5,
	yFull = -4.5,
	smooth = 6
}

local lights = {}
local lastTime = -1000000000
local v5 = nil
local v6 = 0
local level = 0
local StageBlackout = {}

for i = 1, StudioSlotConfig.SlotCount do
	local offsetX = StudioSlotConfig.OffsetX(i)
	v3[StudioSlotConfig.FolderName(i)] = true
	v[#v + 1] = {
		minX = v2.minX + offsetX,
		maxX = v2.maxX + offsetX,
		minZ = v2.minZ,
		maxZ = v2.maxZ,
		minY = v2.minY,
		maxY = v2.maxY,
		edge = v2.edge,
		vEdge = v2.vEdge
	}
end

local function isUnderKit(light): boolean
	local parent = light.Parent

	while parent and parent ~= Workspace do
		if parent.Name == "Stage KIT" or v3[parent.Name] and parent:IsA("Folder") then
			return true
		end

		parent = parent.Parent
	end

	return false
end

local function computeBasementTarget()
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return 0
	end

	local position = currentCamera.CFrame.Position
	local v7 = v4

	local v8 = math.max(v7.minX - position.X, 0, position.X - v7.maxX)
	local v9 = math.max(v7.minZ - position.Z, 0, position.Z - v7.maxZ)
	local v10 = 1 - math.clamp(math.sqrt(v8 * v8 + v9 * v9) / v7.edge, 0, 1)
	local v11

	if v10 > 0 then
		local v12 = math.clamp((v7.yNone - position.Y) / (v7.yNone - v7.yFull), 0, 1)
		v11 = v10 * (v12 * v12 * (3 - v12 * 2))
	else
		v11 = 0
	end

	for _, v12 in ipairs(v) do
		local v13 = math.max(v12.minX - position.X, 0, position.X - v12.maxX)
		local v14 = math.max(v12.minZ - position.Z, 0, position.Z - v12.maxZ)
		local v15 = 1 - math.clamp(math.sqrt(v13 * v13 + v14 * v14) / v12.edge, 0, 1)

		if not (v15 > 0) then
			continue
		end

		local v16 = math.min(
			math.clamp((position.Y - v12.minY) / v12.vEdge, 0, 1),
			(math.clamp((v12.maxY - position.Y) / v12.vEdge, 0, 1))
		)
		v11 = math.max(v11, v15 * (v16 * v16 * (3 - v16 * 2)))
	end

	return v11
end

local function scanLights()
	lights = {}
	local map = Workspace:FindFirstChild("Map")

	if not map then
		return
	end

	for _, light in ipairs(map:GetDescendants()) do
		if
			not (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight"))
			or isUnderKit(light)
		then
			continue
		end

		lights[#lights + 1] = light
	end

	lastTime = os.clock()
end

local function capture()
	if os.clock() - lastTime > 30 then
		scanLights()
	end

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	v5 = {
		brightness = Lighting.Brightness,
		diffuse = Lighting.EnvironmentDiffuseScale,
		specular = Lighting.EnvironmentSpecularScale,
		atmo = atmosphere,
		density = atmosphere and atmosphere.Density or 0,
		haze = atmosphere and atmosphere.Haze or 0,
		glare = atmosphere and atmosphere.Glare or 0,
		lights = {}
	}

	for _, inst in ipairs(lights) do
		if inst.Parent then
			v5.lights[#v5.lights + 1] = { inst = inst, br = inst.Brightness }
		end
	end
end

local function lerpScale(p, p2, p3) -- 7 equivalent calls inferred from this helper
	return p * (1 - p3 * (1 - p2))
end

local function apply(p)
	local v7 = v5

	local v8 = p * (1 - v6)
	Lighting.Brightness = lerpScale(v7.brightness, 0.15, v8) -- inferred equivalent call
	Lighting.EnvironmentDiffuseScale = lerpScale(v7.diffuse, 0.25, v8) -- inferred equivalent call
	Lighting.EnvironmentSpecularScale = lerpScale(v7.specular, 0.4, v8) -- inferred equivalent call

	if v7.atmo and v7.atmo.Parent then
		v7.atmo.Density = lerpScale(v7.density, 0.35, v8) -- inferred equivalent call
		v7.atmo.Haze = lerpScale(v7.haze, 0.3, v8) -- inferred equivalent call
		v7.atmo.Glare = lerpScale(v7.glare, 0.3, v8) -- inferred equivalent call
	end

	for _, light in ipairs(v7.lights) do
		if light.inst.Parent then
			light.inst.Brightness = lerpScale(light.br, 0.12, p) -- inferred equivalent call
		end
	end
end

local function restore()
	local v7 = v5
	v5 = nil
	Lighting.Brightness = v7.brightness
	Lighting.EnvironmentDiffuseScale = v7.diffuse
	Lighting.EnvironmentSpecularScale = v7.specular

	if v7.atmo and v7.atmo.Parent then
		local atmo = v7.atmo
		local atmo2 = v7.atmo
		local atmo3 = v7.atmo
		local density = v7.density
		local haze = v7.haze
		local glare = v7.glare
		atmo.Density = density
		atmo2.Haze = haze
		atmo3.Glare = glare
	end

	for _, light in ipairs(v7.lights) do
		if light.inst.Parent then
			light.inst.Brightness = light.br
		end
	end
end

function StageBlackout.Update(p, value)
	local v7 = math.clamp(value or 0, 0, 1)

	if level < v7 then
		level = math.min(v7, level + p / 1.2)
	elseif v7 < level then
		level = math.max(v7, level - p / 1.8)
	end

	if level > 0 then
		if not v5 then
			capture()
			v6 = computeBasementTarget()
		end

		local v8 = computeBasementTarget()
		v6 += (v8 - v6) * (1 - math.exp(-p * v4.smooth))
		apply(level * level * (3 - level * 2))
	elseif v5 then
		restore()
	end
end

function StageBlackout.GetLevel()
	return level
end

return StageBlackout