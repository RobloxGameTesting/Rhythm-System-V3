local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardSwitch = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BoardSwitch"))

local boardViewAnchor = workspace:WaitForChild("Map"):WaitForChild("BoardExtras"):WaitForChild("BoardViewAnchor")

local function attr(attributeName, p) -- 3 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return type(attribute) == "number" and attribute or p
end

local v = {}
local v2 = nil

local object = setmetatable({}, { __mode = "k" })

local function trackLight(light) -- 1 equivalent call inferred from this helper
	if light:IsA("Light") then
		object[light] = true
	end
end

task.spawn(function()
	local count = 0

	for _, descendant in ipairs(workspace:GetDescendants()) do
		trackLight(descendant) -- inferred equivalent call
		count += 1

		if count % 3000 == 0 then
			task.wait()
		end
	end
end)
workspace.DescendantAdded:Connect(trackLight)

local function lightPosition(k) -- 1 equivalent call inferred from this helper
	local parent = k.Parent

	if parent and parent:IsA("BasePart") then
		return parent.Position
	end

	if parent and parent:IsA("Attachment") then
		return parent.WorldPosition
	end

	return nil
end

local function collectShadowLights()
	local position = boardViewAnchor.Position
	local v3 = attr("ScanRadius", 130) -- inferred equivalent call
	local shadowLights = {}

	for k in pairs(object) do
		if not (k.Parent and k.Enabled and k.Shadows) then
			continue
		end

		local v4 = lightPosition(k) -- inferred equivalent call

		if v4 and (v4 - position).Magnitude <= v3 then
			shadowLights[k] = v4
		end
	end

	return shadowLights
end

local function pickNearest(items)
	local position = boardViewAnchor.Position
	local v3 = 1e999
	local v4 = 1e999
	local v5 = nil
	local v6 = nil

	for light, item in pairs(items) do
		local magnitude = (item - position).Magnitude

		if magnitude < v3 then
			v6 = light
			v3 = magnitude
		end

		if not (light:IsA("SpotLight") and magnitude <= light.Range and magnitude < v4) then
			continue
		end

		v5 = light
		v4 = magnitude
	end

	return v5 or v6
end

local function restore() -- 2 equivalent calls inferred from this helper
	for k in pairs(v) do
		if k.Parent then
			k.Shadows = true
		end
	end

	v = {}
end

local function setMode(p)
	if p == v2 then
		return
	end

	local v3 = v2
	v2 = p

	if p == nil then
		restore() -- inferred equivalent call
	else
		if v3 == nil then
			v = collectShadowLights()
		end

		local v4 = nil

		if p == "overview" and attr("KeepNearestInOverview", 1) ~= 0 then -- inferred equivalent call
			v4 = pickNearest(v)
		end

		for k in pairs(v) do
			if k.Parent then
				k.Shadows = k == v4
			end
		end
	end
end

local function evaluate() -- 2 equivalent calls inferred from this helper
	local current = BoardSwitch.GetCurrent()

	if current == nil then
		if v2 == nil then
			return
		end

		v2 = nil
		restore() -- inferred equivalent call
	elseif current == "Overview" then
		if v2 == "overview" then
			return
		end

		local v3 = v2
		v2 = "overview"

		if v3 == nil then
			v = collectShadowLights()
		end

		local v4

		if attr("KeepNearestInOverview", 1) ~= 0 then -- inferred equivalent call
			v4 = pickNearest(v)
		end

		for k in pairs(v) do
			if k.Parent then
				k.Shadows = k == v4
			end
		end
	else
		if v2 == "focus" then
			return
		end

		local v3 = v2
		v2 = "focus"

		if v3 == nil then
			v = collectShadowLights()
		end

		local v4 = nil

		for k in pairs(v) do
			if k.Parent then
				k.Shadows = k == v4
			end
		end
	end
end

local flag = false
BoardSwitch.Changed:Connect(function()
	if flag then
		return
	end

	flag = true
	task.delay(0.1, function()
		flag = false
		evaluate() -- inferred equivalent call
	end)
end)

task.spawn(function()
	while true do
		task.wait(2)
		evaluate() -- inferred equivalent call
	end
end)