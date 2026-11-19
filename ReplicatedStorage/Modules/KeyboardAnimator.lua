local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local ChartLoader = require(ReplicatedStorage.Modules.ChartLoader)
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)

local LocalPlayer = Players.LocalPlayer

local KeyboardAnimator = {}

local v = { -1.2, -0.6, 0, 0.6, 1.2 }

local v2 = { Left = -0.65, Right = 0.45 }

local v3 = {
	Drop = 0,
	Forward = 0,
	Side = 0,
	PitchDeg = 0,
	YawDeg = 0,
	RollDeg = 0,
	LeanDeg = 0,
	BodyForward = 0
}

local v4 = {}

local v5 = {
	Right = CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)),
	Left = CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, 1))
}

local v6 = {}
local v7 = {}
local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local v8 = {}

local function resolveStand(instance)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local v9 = nil
	local v10 = nil
	local v11 = nil

	for _, v12 in ipairs(CollectionService:GetTagged("InstrumentStand")) do
		if v12:GetAttribute("InstrumentType") ~= "Keyboard" then
			continue
		end

		local standPoint = v12:FindFirstChild("StandPoint", true)

		if not (standPoint and standPoint:IsA("Attachment")) then
			continue
		end

		local magnitude = (standPoint.WorldPosition - humanoidRootPart.Position).Magnitude

		if not (not v9 or magnitude < v9) then
			continue
		end

		v11 = standPoint
		v10 = v12
		v9 = magnitude
	end

	if v10 and v9 < 4 then
		return v10, v11
	end

	return nil
end

local function resolveKeyboardModel(stand)
	local parent = stand.Parent

	while parent do
		local displayModel = parent:FindFirstChild("DisplayModel")

		if displayModel then
			return displayModel:FindFirstChildWhichIsA("Model")
		end

		parent = parent.Parent
	end

	return nil
end

local function classifyKey(part): nil | string
	local size = part.Size
	local function near(p, p2): boolean -- 6 equivalent calls inferred from this helper
		return math.abs(p - p2) < 0.02
	end

	if near(size.X, 0.79) and near(size.Y, 0.04) and near(size.Z, 0.13) then -- inferred equivalent call
		return "white"
	end

	if near(size.X, 0.48) and near(size.Y, 0.09) and near(size.Z, 0.06) then -- inferred equivalent call
		return "black"
	end

	return nil
end

local function buildKeyMap(folder, worldCFrame)
	local keys = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local v9 = classifyKey(part)

		if not v9 then
			continue
		end

		local pointToObjectSpace = worldCFrame:PointToObjectSpace(part.Position)
		table.insert(keys, {
			part = part,
			black = v9 == "black",
			x = pointToObjectSpace.X,
			z = pointToObjectSpace.Z,
			topY = pointToObjectSpace.Y + part.Size.Y / 2,
			rest = part.CFrame
		})
	end

	table.sort(keys, function(a, b): boolean
		return a.x < b.x
	end)

	if #keys ~= 61 then
		warn(("[KeyboardAnimator] jumlah tuts %d (harusnya %d) pada %s"):format(#keys, 61, folder:GetFullName()))
	end

	local total = 0
	local total2 = 0
	local count = 0
	local total3 = 0
	local total4 = 0
	local count2 = 0

	for _, v9 in ipairs(keys) do
		if v9.black then
			total += v9.topY
			total2 += v9.z
			count += 1
		else
			total3 += v9.topY
			total4 += v9.z + 0.22
			count2 += 1
		end
	end

	return {
		keys = keys,
		standCF = worldCFrame,
		up = worldCFrame.UpVector,
		whiteTopY = count2 > 0 and total3 / count2 or -0.3,
		whiteTipZ = count2 > 0 and total4 / count2 or -1.55,
		blackTopY = count > 0 and total / count or -0.25,
		blackTipZ = count > 0 and total2 / count or -1.9
	}
end

local function nearestKeyIndex(keys, p)
	local v9 = 1e999
	local v10 = 1

	for i, item in ipairs(keys) do
		local v11 = math.abs(item.x - p)

		if not (v11 < v9) then
			continue
		end

		v10 = i
		v9 = v11
	end

	return v10
end

local function pressedCFrame(p, p2) -- 1 equivalent call inferred from this helper
	local v9 = p2.black and 0.028 or 0.022
	return CFrame.new(p2.rest.Position - p.map.up * v9) * p2.rest.Rotation
end

local function pressKey(p, key)
	local v9 = v8[key.part]

	if not v9 then
		v9 = { PressCount = 0 }
		v8[key.part] = v9
	end

	v9.PressCount += 1
	p.pressed[key] = true

	if v9.Tween then
		v9.Tween:Cancel()
	end

	local tween = TweenService:Create(key.part, TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = pressedCFrame(p, key) -- inferred equivalent call
	})
	v9.Tween = tween
	tween:Play()
end

local function releaseKey(p, key)
	local v9 = v8[key.part]

	if not v9 then
		return
	end

	v9.PressCount = math.max(0, v9.PressCount - 1)

	if v9.PressCount > 0 then
		return
	end

	p.pressed[key] = nil

	if v9.Tween then
		v9.Tween:Cancel()
	end

	local tween = TweenService:Create(key.part, TweenInfo.new(0.07, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		CFrame = key.rest
	})
	v9.Tween = tween
	tween:Play()
end

local function forceReleaseAll(state)
	for k in pairs(state.pressed) do
		local v9 = v8[k.part]

		if v9 then
			if v9.Tween then
				v9.Tween:Cancel()
			end

			v8[k.part] = nil
		end

		if k.part.Parent then
			k.part.CFrame = k.rest
		end
	end

	state.pressed = {}

	for _, v9 in ipairs({ "Left", "Right" }) do
		local v10 = state.hand[v9]
		v10.queue = {}
		v10.active = {}
		v10.cur = nil
	end
end

local v9 = { "Left", "Right" }

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
		local root = lowerTorso:FindFirstChild("Root")
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
			root = root,
			rootC0 = root and root.C0,
			shC0 = motor6D.C0,
			elC0 = motor6D2.C0,
			wrC0 = motor6D3.C0
		}
	end

	return nil
end

local function jointsValid(data): boolean -- 3 equivalent calls inferred from this helper
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

	local v10 = unit:Cross(Vector3.new(1, 0, 0))

	if v10.Magnitude < 0.001 then
		v10 = unit:Cross(Vector3.new(0, 1, 0))
	end

	return CFrame.fromAxisAngle(v10.Unit, 3.141592653589793)
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

local function solve(data, p, drop, p2, pitchDeg, p3, p4)
	local cframe = data.lt.CFrame * data.waist.C0 * data.waist.Transform * data.waist.C1:Inverse()
	local transform = data.sh.Transform
	local transform2 = data.el.Transform
	local transform3 = data.wr.Transform
	local c1 = data.sh.C1
	local c1_2 = data.el.C1
	local c1_3 = data.wr.C1

	local v10 = data.elC0.Position - c1.Position
	local v11 = data.wrC0.Position - c1_2.Position
	local magnitude = v10.Magnitude
	local magnitude2 = v11.Magnitude

	local position = (cframe * data.shC0).Position
	local cframe2 = cframe * data.shC0 * c1:Inverse()

	local v12 = (p * c1_3).Position - Vector3.new(0, drop, 0) + p2 - position
	local magnitude3 = v12.Magnitude

	if magnitude3 < 0.0001 then
		return nil
	end

	local v13 = math.clamp(magnitude3, math.abs(magnitude - magnitude2) + 0.001, (magnitude + magnitude2) * 0.975)
	local unit = v12.Unit

	local v14 = (magnitude * magnitude - magnitude2 * magnitude2 + v13 * v13) / (v13 * 2)
	local v15 = math.sqrt((math.max(magnitude * magnitude - v14 * v14, 0)))
	local vector = cframe:VectorToWorldSpace((Vector3.new(data.side == "Left" and -0.35 or 0.35, -1, 0.15)))
	local v16 = vector - unit * vector:Dot(unit)

	if v16.Magnitude < 0.001 then
		v16 = unit:Cross(Vector3.new(0, 1, 0))

		if v16.Magnitude < 0.001 then
			v16 = unit:Cross(Vector3.new(1, 0, 0))
		end
	end

	local unit2 = v16.Unit
	local v17 = position + unit * v14 + unit2 * v15

	local v18 = swing(cframe2:VectorToWorldSpace(v10), v17 - position)
	local cframe3 = CFrame.new(position) * (v18 * cframe2.Rotation) * CFrame.new(-c1.Position)
	local v19 = cframe:Inverse() * cframe3 * c1 * transform:Inverse()

	local position2 = (cframe3 * data.elC0).Position
	local rotation = (cframe3 * data.elC0 * c1_2:Inverse()).Rotation
	local v20 = position + unit * v13
	local v21 = swing(rotation:VectorToWorldSpace(v11), v20 - position2)
	local cframe4 = CFrame.new(position2) * (v21 * rotation) * CFrame.new(-c1_2.Position)
	local v22 = cframe3:Inverse() * cframe4 * c1_2 * transform2:Inverse()

	local position3 = (cframe4 * data.wrC0).Position
	local v23 = CFrame.new(position3) * p.Rotation * CFrame.Angles(pitchDeg, p3, p4) * CFrame.new(-c1_3.Position)
	local v24 = cframe4:Inverse() * v23 * c1_3 * transform3:Inverse()

	if finite(v19) and finite(v22) and finite(v24) then -- inferred equivalent call
		return v19, v22, v24
	end

	return nil
end

local function restore(p)
	for _, v10 in ipairs(v9) do
		local v11 = p.J[v10]

		if not (v11 and jointsValid(v11)) then -- inferred equivalent call
			continue
		end

		local sh = v11.sh
		local el = v11.el
		local wr = v11.wr
		local shC0 = v11.shC0
		local elC0 = v11.elC0
		local wrC0 = v11.wrC0
		sh.C0 = shC0
		el.C0 = elC0
		wr.C0 = wrC0
		v11.waist.C0 = v11.waistC0

		if v11.root and v11.rootC0 and v11.root.Parent == v11.lt then
			v11.root.C0 = v11.rootC0
		end
	end
end

local v10 = nil
pcall(function()
	local AvatarTypeVerify = require(ReplicatedStorage.Modules.AvatarTypeVerify)
	v10 = AvatarTypeVerify
end)

local object3 = setmetatable({}, { __mode = "k" })

local function computeTune(character)
	local clone = table.clone(v3)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if v10 and playerFromCharacter then
		local success, avatarType = pcall(v10.GetAvatarType, playerFromCharacter)
		local v11 = success and avatarType and v4[tostring(avatarType)]

		if v11 then
			for k, v12 in pairs(v11) do
				clone[k] = v12
			end
		end
	end

	if not LocalPlayer or character ~= LocalPlayer.Character then
		return clone
	end

	for k in pairs(v3) do
		local attribute = LocalPlayer:GetAttribute("KbTune_" .. k)

		if type(attribute) == "number" then
			clone[k] = attribute
		end
	end

	return clone
end

local function getTune(character)
	local now = os.clock()
	local v11 = object3[character]

	if not v11 or now - v11.t > 0.4 then
		v11 = { t = now, v = computeTune(character) }
		object3[character] = v11
	end

	return v11.v
end

local function newHand(side)
	return {
		side = side,
		x = v2[side],
		zk = 0,
		dip = 0,
		queue = {},
		active = {},
		cur = nil
	}
end

local function ensureState(character)
	local v11 = v6[character]

	if v11 then
		return v11
	end

	if not (character and character.Parent) then
		return nil
	end

	local stand, v12 = resolveStand(character)

	if not stand then
		return nil
	end

	local keyboardModel = resolveKeyboardModel(stand)

	if not keyboardModel then
		return nil
	end

	local map = object2[keyboardModel]

	if not map then
		map = buildKeyMap(keyboardModel, v12.WorldCFrame)
		object2[keyboardModel] = map
	end

	local v13 = { Left = getJoints(character, "Left"), Right = getJoints(character, "Right") }

	if v13.Left and v13.Right then
		local v14 = {
			character = character,
			stand = stand,
			map = map,
			J = v13,
			hand = { Left = newHand("Left"), Right = newHand("Right") },
			pressed = {},
			handHalf = {
				Left = character.LeftHand.Size / 2,
				Right = character.RightHand.Size / 2
			},
			vis = 0,
			bx = 0,
			activeUntil = 0,
			lastHit = nil,
			chartDriven = false
		}

		v6[character] = v14
		return v14
	end

	return nil
end

local function isGateOpen(p): boolean -- 5 equivalent calls inferred from this helper
	return p.lastHit ~= nil and os.clock() - p.lastHit < 3
end

local function keyIndexForLane(p, lane, seed) -- 1 equivalent call inferred from this helper
	local v11 = (seed * 7919 % 5 - 2) * 0.09
	return nearestKeyIndex(p.map.keys, v[lane] + v11)
end

local function scheduleGroup(p, list, p2)
	local now = os.clock()
	local v11 = now + p2
	local v12 = { Left = {}, Right = {} }
	local v13 = {}

	for _, item in ipairs(list) do
		local lane = math.clamp(math.floor((item.Lane or 3) + 0.5), 1, 5)
		local v14 = {
			lane = lane,
			dur = item.Duration or 0,
			seed = math.floor((item.Time or now) * 100)
		}

		if lane <= 2 then
			table.insert(v12.Left, v14)
		elseif lane >= 4 then
			table.insert(v12.Right, v14)
		else
			table.insert(v13, v14)
		end
	end

	for _, v14 in ipairs(v13) do
		table.insert(
			v12[#v12.Left == 0 and #v12.Right > 0 and "Left" or #v12.Right == 0 and #v12.Left > 0 and "Right" or math.abs(p.hand.Left.x - v[3]) <= math.abs(p.hand.Right.x - v[3]) and "Left" or "Right"],
			v14
		)
	end

	for _, v14 in ipairs(v9) do
		local v15 = v12[v14]

		if not (#v15 > 0) then
			continue
		end

		table.sort(v15, function(a, b): boolean
			return a.lane < b.lane
		end)

		local lanes = {}
		local set = {}
		local keys = {}
		local total = 0
		local maxDur = 0
		local count = 0

		for _, v16 in ipairs(v15) do
			local v17 = keyIndexForLane(p, v16.lane, v16.seed) -- inferred equivalent call
			table.insert(lanes, v16.lane)

			if not set[v17] then
				set[v17] = true
				local key = p.map.keys[v17]
				table.insert(keys, key)
				total += key.x

				if key.black then
					count += 1
				end
			end

			maxDur = math.max(maxDur, v16.dur)
		end

		local joined = table.concat(lanes, ",")
		local v16 = p.hand[v14]
		local v17 = false

		for _, v18 in ipairs(v16.queue) do
			if v18.sig == joined and math.abs(v18.t - v11) < 0.12 then
				v17 = true
				break
			end
		end

		if v17 then
			continue
		end

		local v18 = {
			t = v11,
			rel = v11 + math.max(maxDur, 0.09),
			keys = keys,
			x = total / #keys,
			blackFrac = count / #keys,
			sig = joined
		}

		local queue = v16.queue
		local v19 = #queue + 1

		while v19 > 1 and queue[v19 - 1].t > v18.t do
			v19 -= 1
		end

		table.insert(queue, v19, v18)
	end
end

local function lerpN(p, p2, p3) -- 7 equivalent calls inferred from this helper
	return p + (p2 - p) * p3
end

local function updateHand(state, state2, p, p2)
	local queue = state2.queue

	for i = 1, #queue do
		local cur = queue[i]

		if p2 < cur.t then
			break
		end

		if cur.started then
			continue
		end

		cur.started = true

		for _, key in ipairs(cur.keys) do
			pressKey(state, key)
		end

		table.insert(state2.active, cur)
		state2.cur = cur
	end

	for i = #state2.active, 1, -1 do
		local v11 = state2.active[i]

		if not (v11.rel <= p2) then
			continue
		end

		for _, key in ipairs(v11.keys) do
			releaseKey(state, key)
		end

		v11.released = true
		table.remove(state2.active, i)
	end

	while queue[1] and queue[1].released do
		table.remove(queue, 1)
	end

	local v11 = nil

	for i = 1, #queue do
		if not queue[i].started then
			v11 = queue[i]
			break
		end
	end

	local v12, v13

	if v11 and v11.t - p2 <= 0.14 then
		v12 = v11.x
		v13 = v11.blackFrac
	elseif state2.cur and (#state2.active > 0 or p2 - state2.cur.rel < 1.5 or v11 and v11.t - p2 < 1) then
		v12 = state2.cur.x
		v13 = state2.cur.blackFrac
	else
		v12 = v2[state2.side]
		v13 = 0
	end

	state2.x = lerpN(state2.x, v12, 1 - math.exp(-14 * p)) -- inferred equivalent call
	state2.zk = lerpN(state2.zk, v13, 1 - math.exp(-10 * p)) -- inferred equivalent call
	local v14 = #state2.active > 0 and 1 or 0
	local v15 = state2.dip < v14 and 40 or 14
	state2.dip = lerpN(state2.dip, v14, 1 - math.exp(-v15 * p)) -- inferred equivalent call
end

local function updateState(state, p, p2): boolean
	local character = state.character
	local vis2 = object[character] and p2 < state.activeUntil and 1 or 0

	local v11 = state.vis < vis2 and 3 or 2.5
	state.vis = lerpN(state.vis, vis2, 1 - math.exp(-v11 * p)) -- inferred equivalent call

	if math.abs(state.vis - vis2) < 0.004 then
		state.vis = vis2
	end

	local vis = state.vis

	for _, v12 in ipairs(v9) do
		updateHand(state, state.hand[v12], p, p2)
	end

	if vis <= 0 and not object[character] then
		return true
	end

	local tune = getTune(character)
	local map = state.map
	local standCF = map.standCF

	local v12 = math.clamp(((state.hand.Left.x + state.hand.Right.x) / 2 - v[3]) * 0.1, -0.14, 0.14)
	state.bx = lerpN(state.bx, v12, 1 - math.exp(-4 * p)) -- inferred equivalent call
	local v13 = math.rad(22 + tune.LeanDeg) * vis
	local left = state.J.Left
	left.waist.C0 = left.waistC0 * CFrame.Angles(-v13, -state.bx * vis, 0)

	local vector3 = Vector3.new(standCF.LookVector.X, 0, standCF.LookVector.Z)
	local unit = vector3.Magnitude > 0.001 and vector3.Unit or Vector3.new(0, 0, -1)
	local cross = unit:Cross(Vector3.new(0, 1, 0))

	local v14 = { Left = state.hand.Left.x, Right = state.hand.Right.x }
	local v15 = v14.Right - v14.Left

	if v15 < 1.15 then
		local v16 = (1.15 - v15) / 2
		v14.Left -= v16
		v14.Right += v16
	end

	for _, v16 in ipairs(v9) do
		local v17 = state.J[v16]
		local v18 = state.hand[v16]
		local v19 = v16 == "Left" and -1 or 1
		local v20 = lerpN(map.whiteTopY, map.blackTopY, v18.zk) -- inferred equivalent call
		local v21 = lerpN(map.whiteTipZ, map.blackTipZ, v18.zk) -- inferred equivalent call
		local v22 = v20 + 0.3 - 0.13999999999999999 * v18.dip
		local pointToWorldSpace = standCF:PointToWorldSpace((Vector3.new(v14[v16], v22, v21 + -0.02)))
		local v23 = CFrame.new(pointToWorldSpace) * (standCF.Rotation * v5[v16])
		local v24 = unit * tune.Forward + cross * (tune.Side * v19)
		local v25, v26, v27 = solve(
			v17,
			v23,
			tune.Drop,
			v24,
			math.rad(tune.PitchDeg),
			math.rad(tune.YawDeg) * v19,
			math.rad(tune.RollDeg) * v19
		)

		if not v25 then
			continue
		end

		v17.sh.C0 = v17.shC0:Lerp(v25, vis)
		v17.el.C0 = v17.elC0:Lerp(v26, vis)
		v17.wr.C0 = v17.wrC0:Lerp(v27, vis)
	end

	return false
end

local function dropState(p) -- 4 equivalent calls inferred from this helper
	forceReleaseAll(p)
	restore(p)
	v6[p.character] = nil
end

local function onRenderStep(p)
	local now = os.clock()

	for k, v11 in pairs(v6) do
		local v12

		if k.Parent == nil then
			v12 = false
		else
			v12 = jointsValid(v11.J.Left) and jointsValid(v11.J.Right) -- inferred equivalent call
		end

		if v12 then
			local success, result = pcall(updateState, v11, p, now)

			if success then
				if result == true then
					dropState(v11) -- inferred equivalent call
				end
			else
				warn("[KeyboardAnimator] " .. tostring(result))
				dropState(v11) -- inferred equivalent call
			end
		else
			dropState(v11) -- inferred equivalent call
		end
	end
end

pcall(function()
	RunService:UnbindFromRenderStep("KeyboardAnimator")
end)
RunService:BindToRenderStep("KeyboardAnimator", Enum.RenderPriority.Character.Value + 3, onRenderStep)

local function computeExpectedSongElapsed(instance) -- 1 equivalent call inferred from this helper
	local canonicalElapsed = instance:GetAttribute("CanonicalElapsed")
	local canonicalElapsedAt = instance:GetAttribute("CanonicalElapsedAt")

	if canonicalElapsed and canonicalElapsedAt then
		return canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
	end

	return nil
end

local function computeChartElapsed(data, p)
	local v11

	if p then
		if not data.IsPlaying then
			return nil
		end

		v11 = data.TimePosition

		return (data.Parent and data.Parent:GetAttribute("SegmentOffset") or 0) + v11 + SettingsState.GetAudioOffsetMs() / 1000
	end

	v11 = computeExpectedSongElapsed(data) -- inferred equivalent call

	if v11 then
		return (data.Parent and data.Parent:GetAttribute("SegmentOffset") or 0) + v11 + SettingsState.GetAudioOffsetMs() / 1000
	end

	return nil
end

local function getVocalistVisualOffset(instance)
	if not LocalPlayer or LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
		return 0
	end

	local parent = instance.Parent
	local child = parent and parent:FindFirstChild(instance.Name .. "_VocalistMirror")
	local vocalistVisualOffset = child and child:GetAttribute("VocalistVisualOffset")

	if type(vocalistVisualOffset) == "number" then
		return vocalistVisualOffset
	end

	return 0
end

local function findAmpSound(stand, p) -- 1 equivalent call inferred from this helper
	local soundAnchor = stand:FindFirstChild("SoundAnchor")
	local value = soundAnchor and soundAnchor.Value
	return value and value:FindFirstChild(p .. "_Keyboard")
end

local function getSyncOffset(p) -- 1 equivalent call inferred from this helper
	local song = SongConfig.Songs[p]

	if song then
		return (song.Offset or 0) + (song.InstrumentOffsets and song.InstrumentOffsets.Keyboard or 0)
	end

	return 0
end

local function firstNoteIndexAfter(clone, p)
	local v11 = #clone + 1
	local v12 = 1

	while v12 < v11 do
		local v13 = (v12 + v11) // 2

		if p < clone[v13].Time then
			v11 = v13
		else
			v12 = v13 + 1
		end
	end

	return v12
end

function KeyboardAnimator.SetIdleActive(_, _) end

function KeyboardAnimator.SetChartSyncActive(instance, p, p2)
	v7[instance] = (v7[instance] or 0) + 1
	local v11 = v7[instance]
	object[instance] = p and p2 and instance and true or nil

	local v12 = v6[instance]

	if v12 then
		forceReleaseAll(v12)
		v12.lastHit = nil
		v12.activeUntil = 0
		v12.chartDriven = false
	end

	if not (p and p2 and instance) then
		return
	end

	local chart = ChartLoader.GetChart(p2, "Keyboard")

	if not chart or #chart == 0 then
		return
	end

	local clone = table.clone(chart)
	table.sort(clone, function(a, b): boolean
		if a.Time == b.Time then
			return (a.Lane or 0) < (b.Lane or 0)
		end

		return a.Time < b.Time
	end)
	local syncOffset = getSyncOffset(p2) -- inferred equivalent call
	task.spawn(function()
		local v13 = nil
		local total = 0

		while v7[instance] == v11 do
			if not instance:IsDescendantOf(game) then
				return
			end

			v13 = ensureState(instance)

			if v13 then
				break
			end

			local v14 = total < 5 and 0.1 or 0.5
			task.wait(v14)
			total += v14
		end

		if not v13 or v7[instance] ~= v11 then
			return
		end

		local soundAnchor = v13.stand:FindFirstChild("SoundAnchor")
		local v14 = soundAnchor and soundAnchor.Value

		if v14 then
			v14 = v14:FindFirstChild(p2 .. "_Keyboard")
		end

		while not v14 and v7[instance] == v11 do
			if not instance:IsDescendantOf(game) then
				return
			end

			task.wait(0.2)
			v14 = findAmpSound(v13.stand, p2) -- inferred equivalent call
		end

		if not v14 or v7[instance] ~= v11 then
			return
		end

		v13.chartDriven = true
		local v15 = Players:GetPlayerFromCharacter(instance) == LocalPlayer
		local v16 = 1
		local v17 = 0
		local v18 = false

		while v7[instance] == v11 and v16 <= #clone do
			local v19, parent, v20, vocalistVisualOffset, v21, v22, v23, v24, v25, v26, v27, stand, v28, soundAnchor2, value

			if v6[instance] == v13 then
				if v14.Parent then
					v19 = computeChartElapsed(v14, v15)

					if v19 then
						if LocalPlayer and LocalPlayer:GetAttribute("VocalistSyncOffsetMs") ~= nil then
							parent = v14.Parent
							v20 = parent and parent:FindFirstChild(v14.Name .. "_VocalistMirror")
							vocalistVisualOffset = v20 and v20:GetAttribute("VocalistVisualOffset")
							v21 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
						else
							v21 = 0
						end

						if math.abs(v21 - v17) >= 0.15 then
							v16 = firstNoteIndexAfter(clone, v19 + syncOffset + v21)
							v17 = v21
						else
							v22 = v19 + syncOffset + v21

							if not v18 and clone[1].Time - 4 <= v22 then
								v13.activeUntil = math.max(v13.activeUntil, os.clock() + 4 + 10)
								v18 = true
							end

							while v16 <= #clone and clone[v16].Time - 0.6 <= v22 do
								v23 = clone[v16]

								v24 = v16 + 1
								v25 = { v23 }

								while clone[v24] and clone[v24].Time - v23.Time <= 0.03 do
									table.insert(v25, clone[v24])
									v24 += 1
								end

								v26 = v23.Time - v22

								if not (v26 <= -0.12) then
									v27 = isGateOpen(v13) -- inferred equivalent call

									if not v27 then
										break
									end

									scheduleGroup(v13, v25, v26)
								end

								v16 = v24
							end

							task.wait(0.03)
						end
					else
						task.wait(0.05)
					end
				else
					stand = v13.stand
					v28 = p2
					soundAnchor2 = stand:FindFirstChild("SoundAnchor")
					value = soundAnchor2 and soundAnchor2.Value
					v14 = value and value:FindFirstChild(v28 .. "_Keyboard")

					if v14 then
						v19 = computeChartElapsed(v14, v15)

						if v19 then
							if LocalPlayer and LocalPlayer:GetAttribute("VocalistSyncOffsetMs") ~= nil then
								parent = v14.Parent
								v20 = parent and parent:FindFirstChild(v14.Name .. "_VocalistMirror")
								vocalistVisualOffset = v20 and v20:GetAttribute("VocalistVisualOffset")
								v21 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
							else
								v21 = 0
							end

							if math.abs(v21 - v17) >= 0.15 then
								v16 = firstNoteIndexAfter(clone, v19 + syncOffset + v21)
								v17 = v21
							else
								v22 = v19 + syncOffset + v21

								if not v18 and clone[1].Time - 4 <= v22 then
									v13.activeUntil = math.max(v13.activeUntil, os.clock() + 4 + 10)
									v18 = true
								end

								while v16 <= #clone and clone[v16].Time - 0.6 <= v22 do
									v23 = clone[v16]

									v24 = v16 + 1
									v25 = { v23 }

									while clone[v24] and clone[v24].Time - v23.Time <= 0.03 do
										table.insert(v25, clone[v24])
										v24 += 1
									end

									v26 = v23.Time - v22

									if not (v26 <= -0.12) then
										v27 = isGateOpen(v13) -- inferred equivalent call

										if not v27 then
											break
										end

										scheduleGroup(v13, v25, v26)
									end

									v16 = v24
								end

								task.wait(0.03)
							end
						else
							task.wait(0.05)
						end
					else
						task.wait(0.1)
					end
				end
			else
				v13 = ensureState(instance)

				if v13 then
					v13.chartDriven = true

					if v14.Parent then
						v19 = computeChartElapsed(v14, v15)

						if v19 then
							if LocalPlayer and LocalPlayer:GetAttribute("VocalistSyncOffsetMs") ~= nil then
								parent = v14.Parent
								v20 = parent and parent:FindFirstChild(v14.Name .. "_VocalistMirror")
								vocalistVisualOffset = v20 and v20:GetAttribute("VocalistVisualOffset")
								v21 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
							else
								v21 = 0
							end

							if math.abs(v21 - v17) >= 0.15 then
								v16 = firstNoteIndexAfter(clone, v19 + syncOffset + v21)
								v17 = v21
							else
								v22 = v19 + syncOffset + v21

								if not v18 and clone[1].Time - 4 <= v22 then
									v13.activeUntil = math.max(v13.activeUntil, os.clock() + 4 + 10)
									v18 = true
								end

								while v16 <= #clone and clone[v16].Time - 0.6 <= v22 do
									v23 = clone[v16]

									v24 = v16 + 1
									v25 = { v23 }

									while clone[v24] and clone[v24].Time - v23.Time <= 0.03 do
										table.insert(v25, clone[v24])
										v24 += 1
									end

									v26 = v23.Time - v22

									if not (v26 <= -0.12) then
										v27 = isGateOpen(v13) -- inferred equivalent call

										if not v27 then
											break
										end

										scheduleGroup(v13, v25, v26)
									end

									v16 = v24
								end

								task.wait(0.03)
							end
						else
							task.wait(0.05)
						end
					else
						stand = v13.stand
						v28 = p2
						soundAnchor2 = stand:FindFirstChild("SoundAnchor")
						value = soundAnchor2 and soundAnchor2.Value
						v14 = value and value:FindFirstChild(v28 .. "_Keyboard")

						if v14 then
							v19 = computeChartElapsed(v14, v15)

							if v19 then
								if LocalPlayer and LocalPlayer:GetAttribute("VocalistSyncOffsetMs") ~= nil then
									parent = v14.Parent
									v20 = parent and parent:FindFirstChild(v14.Name .. "_VocalistMirror")
									vocalistVisualOffset = v20 and v20:GetAttribute("VocalistVisualOffset")
									v21 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
								else
									v21 = 0
								end

								if math.abs(v21 - v17) >= 0.15 then
									v16 = firstNoteIndexAfter(clone, v19 + syncOffset + v21)
									v17 = v21
								else
									v22 = v19 + syncOffset + v21

									if not v18 and clone[1].Time - 4 <= v22 then
										v13.activeUntil = math.max(v13.activeUntil, os.clock() + 4 + 10)
										v18 = true
									end

									while v16 <= #clone and clone[v16].Time - 0.6 <= v22 do
										v23 = clone[v16]

										v24 = v16 + 1
										v25 = { v23 }

										while clone[v24] and clone[v24].Time - v23.Time <= 0.03 do
											table.insert(v25, clone[v24])
											v24 += 1
										end

										v26 = v23.Time - v22

										if not (v26 <= -0.12) then
											v27 = isGateOpen(v13) -- inferred equivalent call

											if not v27 then
												break
											end

											scheduleGroup(v13, v25, v26)
										end

										v16 = v24
									end

									task.wait(0.03)
								end
							else
								task.wait(0.05)
							end
						else
							task.wait(0.1)
						end
					end
				else
					task.wait(0.2)
				end
			end
		end
	end)
end

function KeyboardAnimator.Handle(player, p)
	local character = player and player.Character

	if not character or typeof(p) ~= "table" then
		return
	end

	local eventType = p.EventType

	if eventType ~= "Hit" and eventType ~= "HoldStart" or not object[character] then
		return
	end

	local state = ensureState(character)

	if not state then
		return
	end

	local now = os.clock()
	local gateOpen = isGateOpen(state) -- inferred equivalent call
	state.lastHit = now
	state.activeUntil = math.max(state.activeUntil, now + 10)

	if state.chartDriven and gateOpen then
		return
	end

	local noteData = p.NoteData
	local chartLane = noteData and noteData.ChartLane

	if type(chartLane) == "number" then
		scheduleGroup(state, {
			{ Lane = chartLane, Duration = 0, Time = now }
		}, 0.04)
	end
end

function KeyboardAnimator.DebugSchedule(character, list): boolean
	object[character] = true
	local state = ensureState(character)

	if not state then
		return false
	end

	local now = os.clock()
	state.lastHit = now

	local v11 = {}
	local maxValue = 0
	local v12 = {}

	for _, item in ipairs(list) do
		local v13 = string.format("%.3f", item.t)

		if not v11[v13] then
			v11[v13] = { t = item.t, list = {} }
			table.insert(v12, v11[v13])
		end

		table.insert(v11[v13].list, {
			Lane = item.lane,
			Duration = item.duration or 0,
			Time = item.t
		})
		maxValue = math.max(maxValue, item.t + (item.duration or 0))
	end

	state.activeUntil = now + maxValue + 3

	for _, v13 in ipairs(v12) do
		scheduleGroup(state, v13.list, v13.t)
	end

	return true
end

function KeyboardAnimator.DebugGetState(p)
	return v6[p] or nil
end

function KeyboardAnimator.Cleanup(p)
	v7[p] = (v7[p] or 0) + 1
	object[p] = nil
	local v11 = v6[p]

	if v11 then
		dropState(v11) -- inferred equivalent call
	end
end

return KeyboardAnimator