local HttpService = game:GetService("HttpService")

local StageLightConfig = {}

StageLightConfig.STYLES = { "Song", "Classic", "Punk", "Warm", "Ice", "Duotone", "Midnight" }
StageLightConfig.MODES = { "Beat", "Static", "Breathe" }
StageLightConfig.COLOR_GROUPS = { "all", "kick", "par1", "ayrton" }
StageLightConfig.LAMP_GROUPS = { "kick", "par1", "ayrton" }
StageLightConfig.BRIGHTNESS_STEPS = { 25, 50, 75, 100 }
StageLightConfig.BOOL_KEYS = { "show", "blackout", "sway", "solo", "spfx" }

StageLightConfig.SWATCHES = {
	{ "White", 255, 255, 255 },
	{ "Warm White", 255, 226, 180 },
	{ "Red", 235, 50, 60 },
	{ "Orange", 255, 130, 40 },
	{ "Amber", 255, 185, 60 },
	{ "Yellow", 255, 225, 70 },
	{ "Green", 60, 220, 110 },
	{ "Teal", 40, 210, 190 },
	{ "Cyan", 90, 210, 255 },
	{ "Blue", 60, 110, 245 },
	{ "Violet", 140, 90, 245 },
	{ "Magenta", 235, 60, 165 }
}

StageLightConfig.STAGES_WITH_LIGHTS = { STAGE1 = true }

function StageLightConfig.HasLights(p): boolean
	return StageLightConfig.STAGES_WITH_LIGHTS[p] == true
end

local function contains(list, p): boolean -- 7 equivalent calls inferred from this helper
	for _, item in ipairs(list) do
		if item == p then
			return true
		end
	end

	return false
end

function StageLightConfig.Default()
	return {
		show = true,
		mode = "Beat",
		style = "Song",
		brightness = 100,
		colors = {},
		groups = { kick = true, par1 = true, ayrton = true },
		blackout = true,
		sway = true,
		solo = true,
		spfx = true
	}
end

local function validColor(p)
	if type(p) ~= "table" then
		return nil
	end

	local v = tonumber(p[1] or p.r)
	local v2 = tonumber(p[2] or p.g)
	local v3 = tonumber(p[3] or p.b)

	if v and v2 and v3 then
		return {
			math.clamp(math.floor(v + 0.5), 0, 255),
			math.clamp(math.floor(v2 + 0.5), 0, 255),
			(math.clamp(math.floor(v3 + 0.5), 0, 255))
		}
	end

	return nil
end

local function snapBrightness(p)
	local v = tonumber(p)

	if not v then
		return nil
	end

	local v2 = 1e999
	local v3 = nil

	for _, v4 in ipairs(StageLightConfig.BRIGHTNESS_STEPS) do
		local v5 = math.abs(v4 - v)

		if not (v5 < v2) then
			continue
		end

		v3 = v4
		v2 = v5
	end

	return v3
end

function StageLightConfig:Apply(value, p)
	if value == "reset" then
		local default = StageLightConfig.Default()

		for k in pairs(self) do
			self[k] = nil
		end

		for k, v in pairs(default) do
			self[k] = v
		end

		return true
	elseif contains(StageLightConfig.BOOL_KEYS, value) then -- inferred equivalent call
		if type(p) ~= "boolean" then
			return false
		end

		local v = self[value] ~= p
		self[value] = p
		return v
	elseif value == "mode" then
		if not contains(StageLightConfig.MODES, p) then -- inferred equivalent call
			return false
		end

		local v = self.mode ~= p
		self.mode = p
		return v
	elseif value == "style" then
		if not contains(StageLightConfig.STYLES, p) then -- inferred equivalent call
			return false
		end

		local v = self.style ~= p
		self.style = p
		return v
	elseif value == "brightness" then
		local brightness = snapBrightness(p)

		if not brightness then
			return false
		end

		local v = self.brightness ~= brightness
		self.brightness = brightness
		return v
	else
		local v

		if type(value) == "string" then
			v = value:match("^group:(%w+)$")
		else
			v = false
		end

		if v then
			if not contains(StageLightConfig.LAMP_GROUPS, v) or type(p) ~= "boolean" then -- inferred equivalent call
				return false
			end

			local v2 = self.groups[v] ~= p
			self.groups[v] = p
			return v2
		else
			local v2

			if type(value) == "string" then
				v2 = value:match("^color:(%w+)$")
			else
				v2 = false
			end

			if not (v2 and contains(StageLightConfig.COLOR_GROUPS, v2)) then -- inferred equivalent call
				return false
			end

			if p == false then
				local v3 = self.colors[v2] ~= nil
				self.colors[v2] = nil
				return v3
			else
				local v3 = validColor(p)

				if not v3 then
					return false
				end

				self.colors[v2] = v3
				return true
			end
		end
	end
end

function StageLightConfig.Decode(json)
	local result = StageLightConfig.Default()

	if type(json) ~= "string" or json == "" then
		return result
	end

	local success, result2 = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if not success or type(result2) ~= "table" then
		return result
	end

	for _, v in ipairs(StageLightConfig.BOOL_KEYS) do
		if type(result2[v]) == "boolean" then
			result[v] = result2[v]
		end
	end

	if contains(StageLightConfig.MODES, result2.mode) then -- inferred equivalent call
		result.mode = result2.mode
	end

	if contains(StageLightConfig.STYLES, result2.style) then -- inferred equivalent call
		result.style = result2.style
	end

	result.brightness = snapBrightness(result2.brightness) or result.brightness

	if type(result2.groups) == "table" then
		for _, v in ipairs(StageLightConfig.LAMP_GROUPS) do
			if type(result2.groups[v]) == "boolean" then
				result.groups[v] = result2.groups[v]
			end
		end
	end

	if type(result2.colors) ~= "table" then
		return result
	end

	for _, v in ipairs(StageLightConfig.COLOR_GROUPS) do
		local v2 = validColor(result2.colors[v])

		if v2 then
			result.colors[v] = v2
		end
	end

	return result
end

function StageLightConfig.Encode(p)
	return HttpService:JSONEncode(p)
end

function StageLightConfig.ToColor3(list)
	return Color3.fromRGB(list[1], list[2], list[3])
end

return StageLightConfig