local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function num(attributeName, p) -- 13 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return type(attribute) == "number" and attribute or p
end

local function vec(attributeName, p) -- 4 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return typeof(attribute) == "Vector3" and attribute or p
end

local function zones()
	return {
		stairMin = vec("StairMin", Vector3.new(-85, -14, -63)), -- inferred equivalent call
		stairMax = vec("StairMax", Vector3.new(-68, 14, -33)), -- inferred equivalent call
		baseMin = vec("BaseMin", Vector3.new(-104, -16, -102)), -- inferred equivalent call
		baseMax = vec("BaseMax", Vector3.new(-41, 6, -38)), -- inferred equivalent call
		deepY = num("DeepY", -9), -- inferred equivalent call
		backY = num("BackY", -7) -- inferred equivalent call
	}
end

local function inBox(data, data2, data3): boolean -- 3 equivalent calls inferred from this helper
	return data.X >= data2.X
		and data.X <= data3.X
		and data.Y >= data2.Y
		and data.Y <= data3.Y
		and data.Z >= data2.Z
		and data.Z <= data3.Z
end

local v = {
	ParticleEmitter = true,
	Beam = true,
	Trail = true,
	Fire = true,
	Smoke = true,
	Sparkles = true
}

local function newGroup(name)
	return {
		name = name,
		hidden = false,
		parts = {},
		decals = {},
		guis = {},
		lights = {},
		lightConns = {},
		fx = {},
		queueToken = 0
	}
end

local v2 = { Basement = newGroup("Basement"), Outside = newGroup("Outside") }

local function isCharacterModel(model): boolean
	while model and model ~= workspace do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			return true
		end

		model = model.Parent
	end

	return false
end

local childSet = {}
local v3 = { ["Tangga Basement"] = true, ["Langit-langit Tangga Suram"] = true }
local function groupOf(instance): nil | string
	local v4 = instance

	while v4 and v4 ~= workspace do
		if v3[v4.Name] then
			return nil
		end

		v4 = v4.Parent
	end

	local v5 = instance
	local v6 = nil

	while v5.Parent and v5.Parent ~= workspace do
		v6 = v5
		v5 = v5.Parent
	end

	if v5.Parent ~= workspace then
		return nil
	end

	if v5.Name == "Map" then
		if v6 and v6.Name == "STAGE 2" then
			return "Basement"
		end

		local _ = instance == v5

		if v6 and v6.Name == "STAGE 2" then
			return "Basement"
		end

		return "Outside"
	else
		return if childSet[v5] then "Outside" else nil
	end
end

local function setPartHidden(p, p2)
	if p.Parent then
		p.LocalTransparencyModifier = p2 and 1 or 0
	end
end

local flag = false

local function applyOne(data, p, p2, p3)
	if not p2.Parent then
		return
	end

	if p == "parts" then
		p2.LocalTransparencyModifier = p3 and 1 or 0
	elseif p == "decals" then
		p2.Transparency = p3 and 1 or data.decals[p2]
	elseif p == "guis" then
		p2.Enabled = data.guis[p2]
	elseif p == "lights" then
		flag = true
		p2.Enabled = data.lights[p2]
		flag = false
	elseif p == "fx" then
		p2.Enabled = data.fx[p2]
	end
end

local function register(descendant)
	local v4 = groupOf(descendant)

	if not v4 then
		return
	end

	if descendant:IsA("BasePart") then
		if isCharacterModel(descendant) then
			return
		end

		local v5 = v2[v4]
		v5.parts[descendant] = true

		if v5.hidden then
			descendant.LocalTransparencyModifier = 1
		end
	elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
		local v5 = v2[v4]

		if v5.decals[descendant] == nil then
			v5.decals[descendant] = descendant.Transparency
		end

		if v5.hidden then
			descendant.Transparency = 1
		end
	elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
		local v5 = v2[v4]

		if v5.guis[descendant] == nil then
			v5.guis[descendant] = descendant.Enabled
		end

		if v5.hidden then
			descendant.Enabled = false
		end
	elseif descendant:IsA("Light") then
		local v5 = v2[v4]

		if v5.lights[descendant] == nil then
			v5.lights[descendant] = descendant.Enabled

			v5.lightConns[descendant] = descendant:GetPropertyChangedSignal("Enabled"):Connect(function()
				if flag then
					return
				end

				v5.lights[descendant] = descendant.Enabled

				if v5.hidden and descendant.Enabled then
					flag = true
					descendant.Enabled = false
					flag = false
				end
			end)
		end

		if v5.hidden then
			flag = true
			descendant.Enabled = false
			flag = false
		end
	elseif v[descendant.ClassName] then
		local v5 = v2[v4]

		if v5.fx[descendant] == nil then
			v5.fx[descendant] = descendant.Enabled
		end

		if v5.hidden then
			descendant.Enabled = false
		end
	end
end

local function unregister(p)
	for _, v4 in pairs(v2) do
		v4.parts[p] = nil
		v4.decals[p] = nil
		v4.guis[p] = nil
		v4.fx[p] = nil

		if v4.lights[p] == nil then
			continue
		end

		v4.lights[p] = nil
		local lightConn = v4.lightConns[p]

		if not lightConn then
			continue
		end

		lightConn:Disconnect()
		v4.lightConns[p] = nil
	end
end

local function setGroupHidden(state, hidden)
	if state.hidden == hidden then
		return
	end

	state.hidden = hidden
	state.queueToken += 1
	local queueToken = state.queueToken
	task.spawn(function()
		local v4 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
		local count = 0

		for _, v5 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
			local v6 = {}

			for k in pairs(state[v5]) do
				v6[#v6 + 1] = k
			end

			for _, v7 in ipairs(v6) do
				if state.queueToken ~= queueToken then
					return
				end

				if state[v5][v7] ~= nil then
					applyOne(state, v5, v7, hidden)
				end

				count += 1

				if count % v4 == 0 then
					RunService.Heartbeat:Wait()
				end
			end
		end
	end)
end

local Map = workspace:WaitForChild("Map")

local v4 = {
	Terrain = true,
	Camera = true,
	Map = true,
	["Radio System"] = true,
	["Seat System"] = true
}

for _, child in ipairs(workspace:GetChildren()) do
	if not (child:IsA("Model") or child:IsA("Folder")) then
		continue
	end

	if v4[child.Name] or isCharacterModel(child) or Players:GetPlayerFromCharacter(child) then
		continue
	end

	childSet[child] = true
end

local function scanRoot(folder)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for i, descendant in ipairs(descendants) do
		register(descendant)

		if i % 1500 == 0 then
			RunService.Heartbeat:Wait()
		end
	end
end

workspace.DescendantAdded:Connect(register)
workspace.DescendantRemoving:Connect(unregister)

task.spawn(function()
	scanRoot(Map)

	for k in pairs(childSet) do
		scanRoot(k)
	end

	local basement = v2.Basement

	if basement.hidden == true then
		return
	end

	basement.hidden = true
	basement.queueToken += 1
	local queueToken = basement.queueToken
	local v5 = true
	task.spawn(function()
		local v6 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
		local count = 0

		for _, v7 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
			local v8 = {}

			for k in pairs(basement[v7]) do
				v8[#v8 + 1] = k
			end

			for _, v9 in ipairs(v8) do
				if basement.queueToken ~= queueToken then
					return
				end

				if basement[v7][v9] ~= nil then
					applyOne(basement, v7, v9, v5)
				end

				count += 1

				if count % v6 == 0 then
					RunService.Heartbeat:Wait()
				end
			end
		end
	end)
end)

local v5 = nil
local v6 = nil

local function evaluate()
	if script:GetAttribute("Enabled") == false then
		local basement = v2.Basement

		if basement.hidden ~= false then
			basement.hidden = false
			basement.queueToken += 1
			local queueToken = basement.queueToken
			local v7 = false
			task.spawn(function()
				local v8 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
				local count = 0

				for _, v9 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
					local v10 = {}

					for k in pairs(basement[v9]) do
						v10[#v10 + 1] = k
					end

					for _, v11 in ipairs(v10) do
						if basement.queueToken ~= queueToken then
							return
						end

						if basement[v9][v11] ~= nil then
							applyOne(basement, v9, v11, v7)
						end

						count += 1

						if count % v8 == 0 then
							RunService.Heartbeat:Wait()
						end
					end
				end
			end)
		end

		local outside = v2.Outside

		if outside.hidden == false then
			return
		end

		outside.hidden = false
		outside.queueToken += 1
		local queueToken = outside.queueToken
		local v7 = false
		task.spawn(function()
			local v8 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
			local count = 0

			for _, v9 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
				local v10 = {}

				for k in pairs(outside[v9]) do
					v10[#v10 + 1] = k
				end

				for _, v11 in ipairs(v10) do
					if outside.queueToken ~= queueToken then
						return
					end

					if outside[v9][v11] ~= nil then
						applyOne(outside, v9, v11, v7)
					end

					count += 1

					if count % v8 == 0 then
						RunService.Heartbeat:Wait()
					end
				end
			end
		end)
	else
		local character = LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local currentCamera = workspace.CurrentCamera

		if not (humanoidRootPart and currentCamera) then
			return
		end

		local v7 = zones()
		local position = humanoidRootPart.Position
		local position2 = currentCamera.CFrame.Position
		local now = os.clock()

		local function nearStairs(position3) -- 2 equivalent calls inferred from this helper
			return inBox(position3, v7.stairMin, v7.stairMax) -- inferred equivalent call
		end

		local function inBasement(position3) -- 3 equivalent calls inferred from this helper
			return inBox(position3, v7.baseMin, v7.baseMax) and position3.Y < 3 -- inferred equivalent call
		end

		local function deep(position3, hidden) -- 1 equivalent call inferred from this helper
			return inBox(position3, v7.baseMin, v7.baseMax) and position3.Y < (hidden and v7.backY or v7.deepY) -- inferred equivalent call
		end

		local v8 = nearStairs(position) -- inferred equivalent call

		if not v8 then
			v8 = inBasement(position) -- inferred equivalent call

			if not v8 then
				v8 = nearStairs(position2) or inBasement(position2) -- inferred equivalent call
			end
		end

		if v8 then
			v5 = nil
			local basement = v2.Basement

			if basement.hidden ~= false then
				basement.hidden = false
				basement.queueToken += 1
				local queueToken = basement.queueToken
				local v9 = false
				task.spawn(function()
					local v10 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
					local count = 0

					for _, v11 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
						local v12 = {}

						for k in pairs(basement[v11]) do
							v12[#v12 + 1] = k
						end

						for _, v13 in ipairs(v12) do
							if basement.queueToken ~= queueToken then
								return
							end

							if basement[v11][v13] ~= nil then
								applyOne(basement, v11, v13, v9)
							end

							count += 1

							if count % v10 == 0 then
								RunService.Heartbeat:Wait()
							end
						end
					end
				end)
			end
		else
			v5 = v5 or now
			local v9 = now - v5

			if num("HideDelayBasement", 3) <= v9 then -- inferred equivalent call
				local basement = v2.Basement

				if basement.hidden ~= true then
					basement.hidden = true
					basement.queueToken += 1
					local queueToken = basement.queueToken
					local v10 = true
					task.spawn(function()
						local v11 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
						local count = 0

						for _, v12 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
							local v13 = {}

							for k in pairs(basement[v12]) do
								v13[#v13 + 1] = k
							end

							for _, v14 in ipairs(v13) do
								if basement.queueToken ~= queueToken then
									return
								end

								if basement[v12][v14] ~= nil then
									applyOne(basement, v12, v14, v10)
								end

								count += 1

								if count % v11 == 0 then
									RunService.Heartbeat:Wait()
								end
							end
						end
					end)
				end
			end
		end

		if deep(position, v2.Outside.hidden) and inBasement(position2) then -- inferred equivalent call
			v6 = v6 or now
			local v9 = now - v6

			if num("HideDelayOutside", 0.4) <= v9 then -- inferred equivalent call
				local outside = v2.Outside

				if outside.hidden ~= true then
					outside.hidden = true
					outside.queueToken += 1
					local queueToken = outside.queueToken
					local v10 = true
					task.spawn(function()
						local v11 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
						local count = 0

						for _, v12 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
							local v13 = {}

							for k in pairs(outside[v12]) do
								v13[#v13 + 1] = k
							end

							for _, v14 in ipairs(v13) do
								if outside.queueToken ~= queueToken then
									return
								end

								if outside[v12][v14] ~= nil then
									applyOne(outside, v12, v14, v10)
								end

								count += 1

								if count % v11 == 0 then
									RunService.Heartbeat:Wait()
								end
							end
						end
					end)
				end

				local basement = v2.Basement

				if basement.hidden == false then
					return
				end

				basement.hidden = false
				basement.queueToken += 1
				local queueToken = basement.queueToken
				local v10 = false
				task.spawn(function()
					local v11 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
					local count = 0

					for _, v12 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
						local v13 = {}

						for k in pairs(basement[v12]) do
							v13[#v13 + 1] = k
						end

						for _, v14 in ipairs(v13) do
							if basement.queueToken ~= queueToken then
								return
							end

							if basement[v12][v14] ~= nil then
								applyOne(basement, v12, v14, v10)
							end

							count += 1

							if count % v11 == 0 then
								RunService.Heartbeat:Wait()
							end
						end
					end
				end)
			end
		else
			v6 = nil
			local outside = v2.Outside

			if outside.hidden == false then
				return
			end

			outside.hidden = false
			outside.queueToken += 1
			local queueToken = outside.queueToken
			local v9 = false
			task.spawn(function()
				local v10 = math.max(50, (math.floor(num("Chunk", 400)))) -- inferred equivalent call
				local count = 0

				for _, v11 in ipairs({ "lights", "fx", "guis", "decals", "parts" }) do
					local v12 = {}

					for k in pairs(outside[v11]) do
						v12[#v12 + 1] = k
					end

					for _, v13 in ipairs(v12) do
						if outside.queueToken ~= queueToken then
							return
						end

						if outside[v11][v13] ~= nil then
							applyOne(outside, v11, v13, v9)
						end

						count += 1

						if count % v10 == 0 then
							RunService.Heartbeat:Wait()
						end
					end
				end
			end)
		end
	end
end

task.spawn(function()
	while true do
		local success, result = pcall(evaluate)

		if not success and script:GetAttribute("Debug") then
			warn("[BasementVisibility] " .. tostring(result))
		end

		task.wait(0.25)
	end
end)