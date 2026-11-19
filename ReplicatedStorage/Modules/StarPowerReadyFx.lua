local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")

local color = Color3.fromRGB(96, 196, 255)
local color2 = Color3.fromRGB(170, 228, 255)
local color3 = Color3.new(1, 1, 1)
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v2 = v and 90 or 200
local starPowerReadyGui = nil
local root = nil
local v3 = {}
local renderSteppedConnection = nil
local v4 = false
local total = 0
local v5 = 0
local v6 = nil
local v7 = {}
local v8 = {}
local v9 = 0
local v10 = { arc = {}, spark = {}, bridge = {} }
local v11 = true

local function refreshSparkleSetting()
	local success, result = pcall(function()
		return require(script.Parent.SettingsState)
	end)

	if success and result and result.GetHitSparkleEnabled then
		local success2, hitSparkleEnabled = pcall(result.GetHitSparkleEnabled)
		v11 = not success2 or hitSparkleEnabled ~= false
	else
		v11 = true
	end
end

local function acquire()
	if v2 <= v9 then
		return nil
	end

	local v12 = table.remove(v8)

	if not (v12 and v12.Parent) then
		v12 = Instance.new("Frame")
		v12.AnchorPoint = Vector2.new(0.5, 0.5)
		v12.BorderSizePixel = 0
		v12.Active = false
	end

	v12.Visible = true
	v12.Parent = root
	v9 += 1
	return v12
end

local function release(p) -- 2 equivalent calls inferred from this helper
	p.Visible = false
	v8[#v8 + 1] = p
	v9 -= 1
end

local function build()
	if starPowerReadyGui and starPowerReadyGui.Parent then
		return
	end

	v3 = {}
	v8 = {}
	v7 = {}
	v9 = 0
	starPowerReadyGui = Instance.new("ScreenGui")
	starPowerReadyGui.Name = "StarPowerReadyGui"
	starPowerReadyGui.ResetOnSpawn = false
	starPowerReadyGui.IgnoreGuiInset = true

	if v then
		pcall(function()
			starPowerReadyGui.ScreenInsets = Enum.ScreenInsets.None
		end)
	end

	starPowerReadyGui.DisplayOrder = 14
	starPowerReadyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	root.Active = false
	root.Parent = starPowerReadyGui

	local function edge(name, position, size, anchorPoint, rotation)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.AnchorPoint = anchorPoint
		frame.Position = position
		frame.Size = size
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Active = false
		frame.Parent = root
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = rotation
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		uiGradient.Parent = frame
		v3[#v3 + 1] = frame
	end

	local v12 = v and 0.12 or 0.14
	edge("Top", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.2), Vector2.new(0, 0), 90)
	edge("Bottom", UDim2.fromScale(0, 1), UDim2.fromScale(1, 0.2), Vector2.new(0, 1), 270)
	edge("Left", UDim2.fromScale(0, 0), UDim2.fromScale(v12, 1), Vector2.new(0, 0), 0)
	edge("Right", UDim2.fromScale(1, 0), UDim2.fromScale(v12, 1), Vector2.new(1, 0), 180)

	starPowerReadyGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function clearParts()
	for i = #v7, 1, -1 do
		pcall(v7[i], 1000000)
	end

	v7 = {}
end

local function stop() -- 2 equivalent calls inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	clearParts()

	if root then
		root.Visible = false
	end
end

local function spawnArc(p, p2, p3, p4, p5, p6, p7)
	local v12 = math.random(4, 5)
	local v13 = math.cos(p3)
	local v14 = math.sin(p3)
	local v15 = -v14
	local vector2s = {}

	for i = 0, v12 do
		local v16 = i / v12
		local v17 = (i == 0 or i == v12) and 0 or (math.random() * 2 - 1) * p7
		vector2s[#vector2s + 1] = Vector2.new(p + v13 * p4 * v16 + v15 * v17, p2 + v14 * p4 * v16 + v13 * v17)
	end

	local v16 = {}

	for i = 1, v12 do
		local v17 = acquire()

		if not v17 then
			break
		end

		local v18 = vector2s[i]
		local v19 = vector2s[i + 1]
		local v20 = v19 - v18
		v17.BackgroundColor3 = i % 2 == 0 and color3 or color2
		v17.Size = UDim2.fromOffset(v20.Magnitude + 1.5, p5)
		v17.Position = UDim2.fromOffset((v18.X + v19.X) / 2, (v18.Y + v19.Y) / 2)
		v17.Rotation = math.deg((math.atan2(v20.Y, v20.X)))
		v17.ZIndex = 3
		v16[#v16 + 1] = v17
	end

	if #v16 == 0 then
		return
	end

	local total2 = 0
	v7[#v7 + 1] = function(p8): boolean
		total2 += p8

		if p6 <= total2 then
			for _, v17 in ipairs(v16) do
				release(v17) -- inferred equivalent call
			end

			return false
		else
			local v17 = total2 / p6

			for _, v18 in ipairs(v16) do
				v18.BackgroundTransparency = 1 - total * (1 - v17 * v17) * (0.5 + 0.5 * math.random())
			end

			return true
		end
	end
end

local function spawnSpark(total2, total3, p, total4, p2, p3)
	local v12 = acquire()

	if not v12 then
		return
	end

	v12.BackgroundColor3 = math.random() < 0.45 and color3 or color2
	v12.ZIndex = 4
	local total5 = 0
	local v13 = 420 * p3
	v7[#v7 + 1] = function(p4): boolean
		total5 += p4

		if p2 <= total5 then
			release(v12) -- inferred equivalent call
			return false
		else
			total2 += p * p4
			total3 += total4 * p4
			total4 += v13 * p4
			local v14 = math.sqrt(p * p + total4 * total4)
			v12.Size = UDim2.fromOffset(math.clamp(v14 * 0.045, 3, 11 * p3), (math.max(1.5, 2 * p3)))
			v12.Position = UDim2.fromOffset(total2, total3)
			v12.Rotation = math.deg((math.atan2(total4, p)))
			local v15 = total5 / p2
			v12.BackgroundTransparency = 1 - total * (v15 < 0.55 and 1 or 1 - (v15 - 0.55) / 0.45)
			return true
		end
	end
end

local function fn(p, p2) -- 8 equivalent calls inferred from this helper
	return p + math.random() * (p2 - p)
end

local function step(p)
	total += ((v4 and 1 or 0) - total) * math.min(1, p * (v4 and 6 or 5))

	if v4 or not (total < 0.01) then
		if not (starPowerReadyGui and starPowerReadyGui.Parent) then
			return
		end

		root.Visible = true

		local v12 = math.sin(os.clock() * 3.141592653589793 * 2 * 1.4) * 0.5 + 0.5
		local backgroundTransparency = 1 - total * (v12 * 0.24 + 0.2)

		for _, v13 in ipairs(v3) do
			v13.BackgroundTransparency = backgroundTransparency
		end

		local v13 = 1

		while v13 <= #v7 do
			if v7[v13](p) then
				v13 += 1
			else
				table.remove(v7, v13)
			end
		end

		if not v11 or total < 0.05 then
			return
		end

		local v14 = nil

		if v6 then
			local success, result = pcall(v6)

			if success and type(result) == "table" then
				v14 = result
			end
		end

		if not v14 then
			return
		end

		local absolutePosition = root.AbsolutePosition
		local v15 = (v5 * 1.2 + 0.45) * total

		for i, v16 in ipairs(v14) do
			local v17 = v16.X - absolutePosition.X
			local v18 = v16.Y - absolutePosition.Y
			local r = v16.R
			local v19 = r / 30

			v10.arc[i] = (v10.arc[i] or math.random()) + p * 2.4 * v15

			if v10.arc[i] >= 1 then
				v10.arc[i] -= 1
				local v20 = fn(0, 6.283185307179586) -- inferred equivalent call
				spawnArc(
					v17 + math.cos(v20) * r * 0.92,
					v18 + math.sin(v20) * r * 0.92,
					v20 + fn(-0.5, 0.5), -- inferred equivalent call
					r * fn(0.8, 1.5), -- inferred equivalent call
					2.5,
					fn(0.12, 0.24), -- inferred equivalent call
					r * 0.22
				)
			end

			v10.spark[i] = (v10.spark[i] or math.random()) + p * 7 * v15

			while v10.spark[i] >= 1 do
				v10.spark[i] -= 1
				local v20 = -1.5707963267948966 + fn(-1.15, 1.15) -- inferred equivalent call
				local v21 = fn(110, 300) * v19 -- inferred equivalent call

				spawnSpark(
					v17 + math.cos(v20) * r * 0.8,
					v18 + math.sin(v20) * r * 0.8,
					math.cos(v20) * v21,
					math.sin(v20) * v21,
					fn(0.32, 0.6), -- inferred equivalent call
					v19
				)
			end

			local v20 = v14[i + 1]

			if not v20 then
				continue
			end

			v10.bridge[i] = (v10.bridge[i] or math.random()) + p * 0.9 * v15

			if not (v10.bridge[i] >= 1) then
				continue
			end

			v10.bridge[i] -= 1
			local v21 = v20.X - absolutePosition.X
			local v22 = v20.Y - absolutePosition.Y
			local v23 = v21 - v17
			local v24 = v22 - v18
			local v25 = math.sqrt(v23 * v23 + v24 * v24)

			if not (r * 2.2 < v25) then
				continue
			end

			local v26 = math.atan2(v24, v23)
			spawnArc(
				v17 + math.cos(v26) * r,
				v18 + math.sin(v26) * r,
				v26,
				v25 - r - v20.R,
				3,
				fn(0.14, 0.26), -- inferred equivalent call
				r * 0.38
			)
		end
	else
		total = 0
		stop() -- inferred equivalent call
	end
end

local function rumble(p, duration, p2) -- 2 equivalent calls inferred from this helper
	pcall(function()
		local lastInputType = UserInputService:GetLastInputType()

		if not (string.sub(lastInputType.Name, 1, 7) == "Gamepad" and HapticService:IsVibrationSupported(lastInputType)) then
			return
		end

		local v12 = {}

		for _, v13 in ipairs({ Enum.VibrationMotor.Large, Enum.VibrationMotor.Small }) do
			if HapticService:IsMotorSupported(lastInputType, v13) then
				v12[#v12 + 1] = v13
			end
		end

		local function setAll(p3)
			for _, v13 in ipairs(v12) do
				pcall(HapticService.SetMotor, HapticService, lastInputType, v13, p3)
			end
		end
		setAll(p)
		task.delay(duration, function()
			setAll(0)

			if p2 then
				task.delay(0.09, function()
					setAll(p)
					task.delay(duration, function()
						setAll(0)
					end)
				end)
			end
		end)
	end)
end

local StarPowerReadyFx = {}

function StarPowerReadyFx.SetZone(p, p2)
	local v12 = p == true
	v6 = p2

	if v12 == v4 then
		return
	end

	v4 = v12

	if v12 then
		refreshSparkleSetting()
		build()
		rumble(0.55, 0.12, true) -- inferred equivalent call

		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(step)
		end
	end
end

function StarPowerReadyFx.SetIntensity(p)
	v5 = math.clamp(tonumber(p) or 0, 0, 1)
end

function StarPowerReadyFx.ActivationRumble()
	rumble(0.9, 0.22, false) -- inferred equivalent call
end

function StarPowerReadyFx.Destroy()
	v4 = false
	total = 0
	stop() -- inferred equivalent call

	if starPowerReadyGui then
		starPowerReadyGui:Destroy()
		starPowerReadyGui = nil
	end
end

return StarPowerReadyFx