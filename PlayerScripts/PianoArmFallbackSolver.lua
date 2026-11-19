local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local v = { "Drop", "Forward", "Side", "PitchDeg", "YawDeg", "RollDeg", "LeanDeg", "SeatForward" }
local v2 = {
	Woman = {
		Drop = 0.05,
		Forward = 1.4,
		Side = 0,
		PitchDeg = 0,
		YawDeg = 0,
		RollDeg = 0,
		LeanDeg = 10
	},
	XBOX_M = {
		Drop = 0.01,
		Forward = -0.12,
		Side = 0,
		PitchDeg = 0,
		YawDeg = 90,
		RollDeg = 0,
		LeanDeg = 0,
		SeatForward = 0
	},
	BlushDoll = {
		Drop = 0.13,
		Forward = -0.03,
		Side = 0,
		PitchDeg = 3.26,
		YawDeg = 90,
		RollDeg = -15.65,
		LeanDeg = 0,
		SeatForward = 0.12
	},
	CoolGuy = {
		Drop = 0.01,
		Forward = -0.17,
		Side = 0,
		PitchDeg = 0,
		YawDeg = 90,
		RollDeg = 0,
		LeanDeg = 0,
		SeatForward = 0.22
	},
	MiniPlushie = {
		Drop = 0.13,
		Forward = 0.17,
		Side = 0,
		PitchDeg = 0,
		YawDeg = 0,
		RollDeg = 0,
		LeanDeg = 7.54,
		SeatForward = 0.7
	},
	Luna = {
		Drop = -0.59,
		Forward = 3,
		Side = 0.64,
		PitchDeg = -71.09,
		YawDeg = 90,
		RollDeg = -3.26,
		LeanDeg = 0,
		SeatForward = 0.35
	}
}

local AvatarTypeVerify = nil
pcall(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	AvatarTypeVerify = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("AvatarTypeVerify", 5))
end)
local v3 = {}
local object = setmetatable({}, { __mode = "k" })

local function getTune(character)
	local localPlayer = Players.LocalPlayer
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local v4 = object[character]

	if not v4 or os.clock() - v4.t > 3 then
		local name = "Masculine"
		local pianoTuneForceCategory = playerFromCharacter
			and playerFromCharacter:GetAttribute("PianoTuneForceCategory")

		if type(pianoTuneForceCategory) == "string" and pianoTuneForceCategory ~= "" then
			name = pianoTuneForceCategory
		elseif AvatarTypeVerify and playerFromCharacter then
			local success, avatarType = pcall(AvatarTypeVerify.GetAvatarType, playerFromCharacter)

			if success and avatarType then
				name = tostring(avatarType)
			end
		end

		v4 = { name = name, t = os.clock() }
		object[character] = v4
	end

	local v5 = v2[v4.name]

	if
		localPlayer
		and playerFromCharacter == localPlayer
		and localPlayer:GetAttribute("PianoTuneCategory") ~= v4.name
	then
		local pianoTuneCategory = localPlayer:GetAttribute("PianoTuneCategory")

		if type(pianoTuneCategory) == "string" then
			local attributes = {}

			for _, v6 in ipairs(v) do
				attributes[v6] = localPlayer:GetAttribute("PianoTune_" .. v6)
			end

			v3[pianoTuneCategory] = attributes
		end

		print("[PianoArmFallbackSolver] kategori avatar:", tostring(pianoTuneCategory), "->", v4.name)
		localPlayer:SetAttribute("PianoTuneCategory", v4.name)
		local v6 = v3[v4.name]

		for _, v7 in ipairs(v) do
			local v8 = v6 and v6[v7]
			local v9 = type(v8) ~= "number" and (v5 and v5[v7] or 0) or v8

			localPlayer:SetAttribute("PianoTune_" .. v7, v9)
		end
	end

	local tune = {}

	for _, v6 in ipairs(v) do
		local v7 = v5 and v5[v6] or 0

		if localPlayer and playerFromCharacter == localPlayer then
			local attribute = localPlayer:GetAttribute("PianoTune_" .. v6)

			if type(attribute) == "number" then
				v7 = attribute
			end
		end

		tune[v6] = v7
	end

	return tune
end

local v4 = { "Left", "Right" }

local object2 = setmetatable({}, { __mode = "k" })

local function getJoints(instance, side)
	local upperTorso = instance:FindFirstChild("UpperTorso")
	local lowerTorso = instance:FindFirstChild("LowerTorso")
	local child = instance:FindFirstChild(side .. "UpperArm")
	local child2 = instance:FindFirstChild(side .. "LowerArm")
	local child3 = instance:FindFirstChild(side .. "Hand")

	if not (upperTorso and lowerTorso and child and child2 and child3) then
		return nil
	end

	local waist = upperTorso:FindFirstChild("Waist")

	if not (waist and waist:IsA("Motor6D")) then
		return nil
	end

	local motor6D = child:FindFirstChild(side .. "Shoulder")
	local motor6D2 = child2:FindFirstChild(side .. "Elbow")
	local motor6D3 = child3:FindFirstChild(side .. "Wrist")

	if
		motor6D
		and motor6D2
		and motor6D3
		and motor6D:IsA("Motor6D")
		and motor6D2:IsA("Motor6D")
		and motor6D3:IsA("Motor6D")
	then
		return {
			side = side,
			ut = upperTorso,
			lt = lowerTorso,
			waist = waist,
			waistC0 = waist.C0,
			ua = child,
			la = child2,
			hd = child3,
			sh = motor6D,
			el = motor6D2,
			wr = motor6D3,
			root = lowerTorso:FindFirstChild("Root"),
			rootC0 = lowerTorso:FindFirstChild("Root") and lowerTorso.Root.C0,
			shC0 = motor6D.C0,
			elC0 = motor6D2.C0,
			wrC0 = motor6D3.C0
		}
	end

	return nil
end

local function jointsValid(data): boolean -- 2 equivalent calls inferred from this helper
	return data.waist.Parent == data.ut
		and data.sh.Parent == data.ua
		and data.el.Parent == data.la
		and data.wr.Parent == data.hd
		and data.ut.Parent ~= nil
end

local function swing(p, p2)
	local unit = p.Unit
	local unit2 = p2.Unit
	local dot = unit:Dot(unit2)

	if dot > 0.99999 then
		return CFrame.new()
	end

	if not (dot < -0.99999) then
		return CFrame.fromAxisAngle(unit:Cross(unit2).Unit, (math.acos((math.clamp(dot, -1, 1)))))
	end

	local v5 = unit:Cross(Vector3.new(1, 0, 0))

	if v5.Magnitude < 0.001 then
		v5 = unit:Cross(Vector3.new(0, 1, 0))
	end

	return CFrame.fromAxisAngle(v5.Unit, 3.141592653589793)
end

local function finite(p): boolean -- 3 equivalent calls inferred from this helper
	local position = p.Position
	return position.X == position.X
		and position.Y == position.Y
		and position.Z == position.Z
		and math.abs(position.X) < 100000
		and math.abs(position.Y) < 100000
		and math.abs(position.Z) < 100000
end

local function solve(data, p, _, value, p2, value2, value3, value4)
	local cframe = data.lt.CFrame * data.waist.C0 * data.waist.Transform * data.waist.C1:Inverse()
	local transform = data.sh.Transform
	local transform2 = data.el.Transform
	local transform3 = data.wr.Transform
	local c1 = data.sh.C1
	local c1_2 = data.el.C1
	local c1_3 = data.wr.C1

	local v5 = data.elC0.Position - c1.Position
	local v6 = data.wrC0.Position - c1_2.Position
	local magnitude = v5.Magnitude
	local magnitude2 = v6.Magnitude

	local position = (cframe * data.shC0).Position

	local cframe2 = cframe * data.shC0 * c1:Inverse()

	local v7 = (p * c1_3).Position - Vector3.new(0, 0.1 + (value or 0), 0) + (p2 or Vector3.new(0, 0, 0)) - position
	local magnitude3 = v7.Magnitude

	if magnitude3 < 0.0001 then
		return nil
	end

	local v8 = math.clamp(magnitude3, math.abs(magnitude - magnitude2) + 0.001, (magnitude + magnitude2) * 0.975)
	local unit = v7.Unit

	local v9 = (magnitude * magnitude - magnitude2 * magnitude2 + v8 * v8) / (v8 * 2)
	local v10 = math.sqrt((math.max(magnitude * magnitude - v9 * v9, 0)))

	local vector = cframe:VectorToWorldSpace((Vector3.new(data.side == "Left" and -0.35 or 0.35, -1, 0.15)))
	local v11 = vector - unit * vector:Dot(unit)

	if v11.Magnitude < 0.001 then
		v11 = unit:Cross(Vector3.new(0, 1, 0))

		if v11.Magnitude < 0.001 then
			v11 = unit:Cross(Vector3.new(1, 0, 0))
		end
	end

	local unit2 = v11.Unit
	local v12 = position + unit * v9 + unit2 * v10

	local v13 = swing(cframe2:VectorToWorldSpace(v5), v12 - position)
	local cframe3 = CFrame.new(position) * (v13 * cframe2.Rotation) * CFrame.new(-c1.Position)
	local v14 = cframe:Inverse() * cframe3 * c1 * transform:Inverse()

	local position2 = (cframe3 * data.elC0).Position
	local rotation = (cframe3 * data.elC0 * c1_2:Inverse()).Rotation
	local v15 = position + unit * v8
	local v16 = swing(rotation:VectorToWorldSpace(v6), v15 - position2)
	local cframe4 = CFrame.new(position2) * (v16 * rotation) * CFrame.new(-c1_2.Position)
	local v17 = cframe3:Inverse() * cframe4 * c1_2 * transform2:Inverse()

	local position3 = (cframe4 * data.wrC0).Position
	local v18 = CFrame.new(position3) * p.Rotation * CFrame.Angles(value2 or 0, value3 or 0, value4 or 0) * CFrame.new(-c1_3.Position)
	local v19 = cframe4:Inverse() * v18 * c1_3 * transform3:Inverse()

	if finite(v14) and finite(v17) and finite(v19) then -- inferred equivalent call
		return v14, v17, v19
	end

	return nil
end

local set = {
	[Enum.KeyCode.X] = true,
	[Enum.KeyCode.C] = true,
	[Enum.KeyCode.V] = true,
	[Enum.KeyCode.B] = true,
	[Enum.KeyCode.N] = true
}

local v5 = {}
local v6 = nil
UserInputService.InputBegan:Connect(function(input)
	if set[input.KeyCode] then
		v5[input.KeyCode] = true
		v6 = os.clock()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if set[input.KeyCode] then
		v5[input.KeyCode] = nil
		v6 = os.clock()
	end
end)

local v7 = {
	frozen = {},
	keysHidden = false,
	f = 1,
	applied = 1,
	rigSince = nil,
	peak = 0,
	sound = nil,
	nextFind = 0,
	last = nil
}

local function resetVisibility() -- 1 equivalent call inferred from this helper
	v7.f = 1
	v7.applied = 1
	v7.rigSince = nil
	v7.peak = 0
	v7.sound = nil
	v7.nextFind = 0
	v7.last = nil
	v7.keysHidden = false
	v7.frozen = {}
end

local function findPianoSound(position)
	local v8 = nil
	local pianoSound = nil

	for _, sound in ipairs(workspace:GetDescendants()) do
		if not (sound:IsA("Sound") and sound.Name:match("_Piano$") and sound:GetAttribute("CanonicalElapsed") ~= nil) then
			continue
		end

		local position2 = sound.Parent and sound.Parent:IsA("BasePart") and sound.Parent.Position
		local magnitude = position2 and (position2 - position).Magnitude or 1000000000

		if not (not v8 or magnitude < v8) then
			continue
		end

		pianoSound = sound
		v8 = magnitude
	end

	return pianoSound
end

local function computeVisibility(instance)
	local now = os.clock()
	local v8 = math.clamp(now - (v7.last or now), 0, 0.1)
	v7.last = now
	v7.rigSince = v7.rigSince or now

	local localPlayer = Players.LocalPlayer
	local pianoFreePlayAt = localPlayer and localPlayer:GetAttribute("PianoFreePlayAt")

	if type(pianoFreePlayAt) == "number" and (v6 == nil or v6 < pianoFreePlayAt) then
		v6 = pianoFreePlayAt
	end

	local v9 = math.max(v6 or -1000000000, v7.rigSince + 4)
	local v10

	if next(v5) == nil then
		if localPlayer == nil then
			v10 = false
		else
			v10 = localPlayer:GetAttribute("PianoFreePlayHeld") == true
		end
	else
		v10 = true
	end

	local pianoInBreak = Players.LocalPlayer:GetAttribute("PianoInBreak") == true

	if v7.wasBreak and not pianoInBreak then
		v6 = now
		v9 = now
	end

	v7.wasBreak = pianoInBreak
	local v11

	if v10 or now - v9 < 10 then
		v11 = not pianoInBreak
	else
		v11 = false
	end

	local v12

	if v10 or now - v9 < 1.5 then
		v12 = not pianoInBreak
	else
		v12 = false
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and (v7.nextFind <= now or v7.sound and not v7.sound.Parent) then
		v7.nextFind = now + 1
		v7.sound = findPianoSound(humanoidRootPart.Position)
	end

	local sound = v7.sound
	local v13

	if sound and sound.Parent and sound.Playing then
		if sound.Volume > 0.02 then
			v7.peak = math.max(v7.peak, sound.Volume)
		end

		if v7.peak > 0 then
			v13 = sound.Volume < v7.peak * 0.02
		else
			v13 = false
		end
	else
		v13 = false
	end

	v7.keysHidden = (not v12 or v13) and true or false
	local v14 = v11 and 1 or 0
	local v15 = v7.f < v14 and 14 or 8
	v7.f += (v14 - v7.f) * (1 - math.exp(-v15 * v8))

	if math.abs(v7.f - v14) < 0.003 then
		v7.f = v14
	end

	pcall(function()
		local Players2 = game:GetService("Players")
		Players2.LocalPlayer:SetAttribute("PianoKeysHidden", v7.keysHidden)
	end)
	return v7.f
end

local function applySeedWeight(instance, applied)
	if math.abs(applied - v7.applied) <= 0.004 then
		return
	end

	v7.applied = applied
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	for _, v8 in ipairs(animator:GetPlayingAnimationTracks()) do
		if v8.Priority == Enum.AnimationPriority.Action2 then
			v8:AdjustWeight(math.max(applied, 0.001), 0)
		end
	end
end

local object3 = setmetatable({}, { __mode = "k" })

local function buildKeys(position)
	local v8 = nil
	local folder = nil

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if not (descendant.Name == "Keys" and (descendant:IsA("Model") or descendant:IsA("Folder"))) then
			continue
		end

		local v9 = nil

		for _, part in ipairs(descendant:GetDescendants()) do
			if part:IsA("BasePart") then
				v9 = part
				break
			end
		end

		if not v9 then
			continue
		end

		local magnitude = (v9.Position - position).Magnitude

		if not (not v8 or magnitude < v8) then
			continue
		end

		folder = descendant
		v8 = magnitude
	end

	local keys = {}

	if not folder then
		return keys
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and tonumber(part.Parent.Name)) then
			continue
		end

		table.insert(keys, { part = part, rest = part.Position, restCF = part.CFrame })
	end

	return keys
end

local function restore(p)
	for _, v8 in ipairs(v4) do
		local v9 = p[v8]

		if not (v9 and jointsValid(v9)) then -- inferred equivalent call
			continue
		end

		local sh = v9.sh
		local el = v9.el
		local wr = v9.wr
		local shC0 = v9.shC0
		local elC0 = v9.elC0
		local wrC0 = v9.wrC0
		sh.C0 = shC0
		el.C0 = elC0
		wr.C0 = wrC0
		v9.waist.C0 = v9.waistC0

		if v9.root and v9.rootC0 and v9.root.Parent == v9.lt then
			v9.root.C0 = v9.rootC0
		end
	end
end

local function step(instance)
	local pianoIKRigV2 = instance:FindFirstChild("PianoIKRigV2")
	local v8 = object2[instance]

	if pianoIKRigV2 then
		if v8 then
			for _, v9 in ipairs(v4) do
				if v8[v9] and jointsValid(v8[v9]) then -- inferred equivalent call
					continue
				end

				object2[instance] = nil
				v8 = nil
				break
			end
		end

		if not v8 then
			v8 = {}

			for _, v9 in ipairs(v4) do
				v8[v9] = getJoints(instance, v9)
			end

			if v8.Left and v8.Right then
				object2[instance] = v8
			else
				return
			end
		end

		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		local v9 = object3[instance]
		local v10 = {
			Left = pianoIKRigV2:FindFirstChild("PianoV2Target_Left"),
			Right = pianoIKRigV2:FindFirstChild("PianoV2Target_Right")
		}

		if v10.Left and v10.Right then
			if not v9 then
				v9 = {
					list = buildKeys(v10.Left.Position),
					dip = { Left = 0, Right = 0 },
					fwd = { Left = 0, Right = 0 }
				}
				object3[instance] = v9
			end

			local v11 = { Left = 0, Right = 0 }
			local v12 = { Left = 0, Right = 0 }

			for _, item in ipairs(v9.list) do
				local part = item.part

				if not (part.Parent and (part.Position - item.rest).Magnitude > 0.01) then
					continue
				end

				local v13 = nil
				local v14 = nil

				for _, v15 in ipairs(v4) do
					local position = v10[v15].Position
					local magnitude = Vector3.new(part.Position.X - position.X, 0, part.Position.Z - position.Z).Magnitude

					if not (magnitude < 1 and (not v13 or magnitude < v13)) then
						continue
					end

					v14 = v15
					v13 = magnitude
				end

				if v14 then
					v11[v14] = 0.07
				end
			end

			local now = os.clock()
			local v13 = math.clamp(now - (v9.last or now), 0, 0.1)
			v9.last = now

			for _, v14 in ipairs(v4) do
				local v15 = v11[v14] > v9.dip[v14] and 45 or 14
				v9.dip[v14] += (v11[v14] - v9.dip[v14]) * (1 - math.exp(-v15 * v13))
				local v16 = v12[v14] > v9.fwd[v14] and 9 or 6
				v9.fwd[v14] += (v12[v14] - v9.fwd[v14]) * (1 - math.exp(-v16 * v13))
			end
		end

		local v11 = 1
		local v12

		if Players.LocalPlayer == nil then
			v12 = false
		else
			v12 = instance == Players.LocalPlayer.Character
		end

		if v12 then
			v11 = computeVisibility(instance)
			applySeedWeight(instance, v11)
		end

		local maxValue = 0

		for _, v13 in ipairs(v4) do
			local ikControl = humanoid and humanoid:FindFirstChild("PianoV2IK_" .. v13)
			maxValue = math.max(
				maxValue,
				ikControl and ikControl:IsA("IKControl") and math.clamp(ikControl.Weight, 0, 1) or 1
			)
		end

		local _ = v9 and v9.fwd and math.max(v9.fwd.Left, v9.fwd.Right)
		local v13 = (math.rad(getTune(instance).LeanDeg) + 0.20943951023931956 + 0) * maxValue * v11
		v8.Left.waist.C0 = v8.Left.waistC0 * CFrame.Angles(-v13, 0, 0)
		local root = v8.Left.root

		if root and v8.Left.rootC0 and root.Parent == v8.Left.lt then
			root.C0 = v8.Left.rootC0 * CFrame.new(0, 0, -getTune(instance).SeatForward * v11)
		end

		for _, v14 in ipairs(v4) do
			local v15 = v8[v14]
			local part = pianoIKRigV2:FindFirstChild("PianoV2Target_" .. v14)

			if not (v15 and part and part:IsA("BasePart")) then
				continue
			end

			local part2 = pianoIKRigV2:FindFirstChild("PianoV2Pole_" .. v14)
			local position = part2 and part2:IsA("BasePart") and part2.Position or v15.la.Position
			local ikControl = humanoid and humanoid:FindFirstChild("PianoV2IK_" .. v14)
			local v16 = ikControl and ikControl:IsA("IKControl") and math.clamp(ikControl.Weight, 0, 1) or 1

			if ikControl and ikControl:IsA("IKControl") and ikControl.Enabled then
				ikControl.Enabled = false
			end

			local v17 = Vector3.new(0, 0, 0)

			if v9 and v9.fwd then
				local lookVector = v15.lt.CFrame.LookVector
				local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

				if vector3.Magnitude > 0.001 then
					v17 = vector3.Unit * v9.fwd[v14]
				end
			end

			local v18 = 0

			if v9 then
				local _fwd = v9.fwd
			end

			local v19 = part.CFrame
			local v20 = v9 and v9.dip[v14] or 0

			if v12 then
				if v7.keysHidden and v7.frozen[v14] then
					v19 = v7.frozen[v14]
					v20 = 0
					v17 = Vector3.new(0, 0, 0)
					v18 = 0
				else
					v7.frozen[v14] = v19
				end
			end

			local tune = getTune(instance)
			local v21 = v14 == "Left" and -1 or 1
			local v22 = v20 + tune.Drop
			local lookVector = v15.lt.CFrame.LookVector
			local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

			if vector3.Magnitude > 0.001 then
				local unit = vector3.Unit
				v17 = v17 + unit * tune.Forward + unit:Cross(Vector3.new(0, 1, 0)) * (tune.Side * v21)
			end

			local v23, v24, v25 = solve(
				v15,
				v19,
				position,
				v22,
				v17,
				v18 + math.rad(tune.PitchDeg),
				math.rad(tune.YawDeg) * v21,
				math.rad(tune.RollDeg) * v21
			)
			local v26 = v16 * v11

			if not v23 then
				continue
			end

			v15.sh.C0 = v15.shC0:Lerp(v23, v26)
			v15.el.C0 = v15.elC0:Lerp(v24, v26)
			v15.wr.C0 = v15.wrC0:Lerp(v25, v26)
		end
	else
		object3[instance] = nil

		if Players.LocalPlayer and instance == Players.LocalPlayer.Character then
			resetVisibility() -- inferred equivalent call
		end

		if v8 then
			restore(v8)
			object2[instance] = nil
		end
	end
end

local v8 = {
	"LeftHand",
	"LeftLowerArm",
	"LeftUpperArm",
	"RightHand",
	"RightLowerArm",
	"RightUpperArm"
}
local flag = false

local function setArmTransparency(character, localTransparencyModifier)
	for _, childName in ipairs(v8) do
		local part = character:FindFirstChild(childName)

		if part and part:IsA("BasePart") then
			part.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

local function keyHideStep()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local v9 = character and object3[character]

	if not (v9 and v7.keysHidden) then
		return
	end

	for _, item in ipairs(v9.list) do
		if item.part.Parent and (item.part.Position - item.rest).Magnitude > 0.001 then
			item.part.CFrame = item.restCF
		end
	end
end

local function fppTransparencyStep()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	local currentCamera = workspace.CurrentCamera
	local v9

	if head and currentCamera and character:FindFirstChild("PianoIKRigV2") then
		v9 = (currentCamera.CFrame.Position - head.Position).Magnitude < 1.8
	else
		v9 = false
	end

	if v9 then
		setArmTransparency(character, 0.6)
		flag = true
	elseif flag then
		setArmTransparency(character, 0)
		flag = false
	end
end

RunService:BindToRenderStep("PianoArmFPPTransparency", Enum.RenderPriority.Last.Value, function()
	pcall(fppTransparencyStep)
	pcall(keyHideStep)
end)
RunService.RenderStepped:Connect(function()
	for _, v9 in ipairs(Players:GetPlayers()) do
		local character = v9.Character

		if not character then
			continue
		end

		local success, result = pcall(step, character)

		if success then
			continue
		end

		warn("[PianoArmFallbackSolver] " .. tostring(result))
		local v10 = object2[character]

		if v10 then
			pcall(restore, v10)
		end

		object2[character] = nil
	end
end)