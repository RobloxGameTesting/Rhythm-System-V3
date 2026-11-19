local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PianoArmPoseAnimator = require(script.Parent.PianoArmPoseAnimator)

local PianoHandAnimatorV2 = {}
PianoHandAnimatorV2.Enabled = true
PianoHandAnimatorV2.Tuning = {
	IKParent = "Humanoid",
	PoleMode = "Attachment",
	IKType = "Transform",
	SeedSettleSeconds = 0,
	BlendInSeconds = 0.2,
	StartDelaySeconds = 0.2,
	HalfLifeStart = 0.11,
	StartupSeconds = 0.7,
	PathRailDepth = 0.25,
	StartupGuardMax = 1.5,
	PathLiftBand = 0.03,
	PathForwardAllowance = 3,
	BlendOutSeconds = 0.5,
	RestInwardRatio = -0.15,
	RestHoverRatio = 0.2,
	PlayHoverRatio = 0.12,
	HandFloorClearance = 0.03,
	ContactInset = 0.4,
	FingerReachOverGrip = 0.9,
	MidiSpan = 24,
	TravelHalfRatio = 0.7,
	TravelGain = 1,
	AnchorBias = 0.65,
	MinHandGapRatio = 0.35,
	DeadzoneSemitones = 1,
	ReachMaxRatio = 0.97,
	ReachSoftStart = 0.85,
	YawFollow = 0.6,
	MaxYawDeg = 25,
	FingerPitchDeg = -5,
	RollDeg = 0,
	TwistRelaxGain = 40,
	MaxRollOffsetDeg = 80,
	PoleOutRatio = 1,
	PoleDownRatio = 1,
	PoleBackRatio = 0.8,
	HalfLifeMove = 0.12,
	HalfLifeRest = 0.3,
	HalfLifeRot = 0.08,
	RestDelay = 0.6
}

local v = {}
local v2 = {}

local v3 = { Left = -1, Right = 1 }
local v4 = { "Left", "Right" }

local function findKeysFolder(seat)
	local parent = seat.Parent

	while parent and parent ~= workspace do
		local displayModel = parent:FindFirstChild("DisplayModel")

		local keys = displayModel and displayModel:FindFirstChild("Keys", true)

		if keys then
			return keys
		end

		parent = parent.Parent
	end

	return nil
end

local function getKey(instance, p, p2) -- 3 equivalent calls inferred from this helper
	local child = instance:FindFirstChild((tostring(p)))
	return child and child:FindFirstChild((tostring(p2)))
end

local function measureKeyboard(seat, keysFolder)
	local cframe = seat.CFrame
	local key = getKey(keysFolder, 1, 1) -- inferred equivalent call
	local key2 = getKey(keysFolder, 6, 1) -- inferred equivalent call
	local key3 = getKey(keysFolder, 3, 1) -- inferred equivalent call

	if not (key and key2 and key3) then
		return nil
	end

	local pointToObjectSpace = cframe:PointToObjectSpace(key.Position)
	local pointToObjectSpace2 = cframe:PointToObjectSpace(key2.Position)
	local pointToObjectSpace3 = cframe:PointToObjectSpace(key3.Position)
	return {
		X36 = pointToObjectSpace.X,
		Slope = (pointToObjectSpace2.X - pointToObjectSpace.X) / 60,
		WhiteTopY = pointToObjectSpace3.Y + key3.Size.Y / 2,
		WhiteNearEdgeZ = pointToObjectSpace3.Z + key3.Size.Z / 2,
		KeyHeight = key3.Size.Y,
		MinX = math.min(pointToObjectSpace.X, pointToObjectSpace2.X),
		MaxX = math.max(pointToObjectSpace.X, pointToObjectSpace2.X)
	}
end

local function measureSide(character, side, cframe)
	local child = character:FindFirstChild(side .. "UpperArm")
	local child2 = character:FindFirstChild(side .. "LowerArm")
	local child3 = character:FindFirstChild(side .. "Hand")

	if not (child and child2 and child3) then
		return nil
	end

	local child4 = child:FindFirstChild(side .. "ShoulderRigAttachment")
	local child5 = child:FindFirstChild(side .. "ElbowRigAttachment")
	local child6 = child2:FindFirstChild(side .. "ElbowRigAttachment")
	local child7 = child2:FindFirstChild(side .. "WristRigAttachment")
	local child8 = child3:FindFirstChild(side .. "WristRigAttachment")
	local child9 = child3:FindFirstChild(side .. "GripAttachment")

	if not (child4 and child5 and child7 and child8) then
		return nil
	end

	local worldCFrame = child9 and child9.WorldCFrame or child3.CFrame
	local objectSpace = child3.CFrame:ToObjectSpace(worldCFrame)
	local objectSpace2 = child3.CFrame:ToObjectSpace(child8.WorldCFrame)

	local magnitude = (child4.WorldPosition - child5.WorldPosition).Magnitude
	local magnitude2 = ((child6 and child6.WorldPosition or child5.WorldPosition) - child7.WorldPosition).Magnitude
	local magnitude3 = (child8.WorldPosition - worldCFrame.Position).Magnitude

	local pointToObjectSpace = cframe:PointToObjectSpace((character.UpperTorso and character.UpperTorso:FindFirstChild(side .. "ShoulderRigAttachment") or child4).WorldPosition)
	local objectSpace3 = cframe:ToObjectSpace(child3.CFrame)
	local pointToObjectSpace2 = cframe:PointToObjectSpace(worldCFrame.Position)

	return {
		Side = side,
		Upper = child,
		Lower = child2,
		Hand = child3,
		ShoulderAtt = child4,
		UpperLen = magnitude,
		LowerLen = magnitude2,
		HandLen = magnitude3,
		ArmLen = magnitude + magnitude2,
		GripLocal = objectSpace,
		WristLocal = objectSpace2,
		ShoulderSeat = pointToObjectSpace,
		SeedHandSeat = objectSpace3,
		SeedRot = objectSpace3.Rotation,
		SeedGripSeat = pointToObjectSpace2,
		HandSize = child3.Size,
		RestTheta = math.atan2(
			pointToObjectSpace2.X - pointToObjectSpace.X,
			pointToObjectSpace.Z - pointToObjectSpace2.Z
		)
	}
end

local function springVec(pos, vel, p, p2, p3) -- 1 equivalent call inferred from this helper
	local v5 = 2.77258872224 / (p2 + 0.00001) / 2
	local v6 = pos - p
	local v7 = vel + v6 * v5
	local v8 = math.exp(-v5 * p3)
	return v8 * (v6 + v7 * p3) + p, v8 * (vel - v7 * v5 * p3)
end

local function smoothstep(value) -- 3 equivalent calls inferred from this helper
	local v5 = math.clamp(value, 0, 1)
	return v5 * v5 * (3 - 2 * v5)
end

local function makePart(name, rig) -- 2 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Massless = true
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Parent = rig
	return part
end

local function buildIK(player, p, data)
	local tuning = PianoHandAnimatorV2.Tuning
	local part = makePart("PianoV2Target_" .. p, player.Rig) -- inferred equivalent call
	local part2 = makePart("PianoV2Pole_" .. p, player.Rig) -- inferred equivalent call
	local poleAttachment = Instance.new("Attachment")
	poleAttachment.Name = "PoleAttachment"
	poleAttachment.Parent = part2

	part.CFrame = player.SeatCF * data.SeedHandSeat
	part2.CFrame = part.CFrame

	local ikControl = Instance.new("IKControl")
	ikControl.Name = "PianoV2IK_" .. p
	ikControl.ChainRoot = data.Upper
	ikControl.EndEffector = data.Hand
	ikControl.Type = tuning.IKType == "Position" and Enum.IKControlType.Position or Enum.IKControlType.Transform
	ikControl.Target = part
	local poleIsAttachment

	if tuning.PoleMode == "Attachment" then
		pcall(function()
			ikControl.Pole = poleAttachment
		end)
		poleIsAttachment = ikControl.Pole == poleAttachment
	else
		poleIsAttachment = false
	end

	if not poleIsAttachment then
		ikControl.Pole = part2
	end

	ikControl.SmoothTime = 0
	ikControl.Weight = 0
	ikControl.Enabled = true

	local parent = player.Humanoid

	parent = tuning.IKParent == "Animator" and parent:FindFirstChildOfClass("Animator") or parent

	ikControl.Parent = parent

	return {
		IK = ikControl,
		Target = part,
		PoleAnchor = part2,
		PoleAtt = poleAttachment,
		PoleIsAttachment = poleIsAttachment,
		Pos = data.SeedHandSeat.Position,
		Vel = Vector3.new(0, 0, 0),
		Rot = data.SeedRot,
		Intent = nil,
		Count = 0,
		HoldUntil = 0
	}
end

local function restXFor(data, p) -- 1 equivalent call inferred from this helper
	local tuning = PianoHandAnimatorV2.Tuning
	local mea = data.Meas[p]
	local v5 = p == "Left" and 1 or -1
	return mea.ShoulderSeat.X + v5 * tuning.RestInwardRatio * mea.ArmLen
end

local function midiFromX(keyboard, p) -- 1 equivalent call inferred from this helper
	return 36 + (p - keyboard.X36) / keyboard.Slope
end

local function desiredGrip(player, p, now)
	local tuning = PianoHandAnimatorV2.Tuning
	local mea = player.Meas[p]
	local keyboard = player.Keyboard
	local hand = player.Hands[p]
	local intent = hand.Intent
	local v5

	if intent == nil then
		v5 = false
	else
		v5 = hand.Count > 0 or now < hand.HoldUntil
	end

	local v6 = restXFor(player, p) -- inferred equivalent call
	local v7 = midiFromX(keyboard, v6) -- inferred equivalent call
	local v8, v9, v10, v11

	if v5 then
		v8 = intent.AnchorMidi
		v9 = intent.TopY
		v10 = intent.ContactZ
		v11 = tuning.PlayHoverRatio
	else
		v9 = keyboard.WhiteTopY
		v10 = keyboard.WhiteNearEdgeZ - tuning.ContactInset
		v11 = tuning.RestHoverRatio
		v8 = v7
	end

	local v12 = math.max(tuning.TravelGain, 0.001)
	local v13 = (v8 - v7) / tuning.MidiSpan
	return
		Vector3.new(
			v6 + tuning.TravelHalfRatio * mea.ArmLen * math.tanh(v13 * v12) / math.tanh(v12),
			v9 + v11 * mea.ArmLen,
			v10 + tuning.FingerReachOverGrip * mea.HandLen
		),
		v5
end

local function handBasis(fingerPitchDeg, p) -- 1 equivalent call inferred from this helper
	local v5 = math.sin(fingerPitchDeg)
	local v6 = math.cos(fingerPitchDeg)
	return CFrame.fromMatrix(
		Vector3.new(0, 0, 0),
		Vector3.new(1, 0, 0),
		Vector3.new(0, v5, v6),
		(Vector3.new(0, -v6, v5))
	) * CFrame.Angles(0, p, 0)
end

local function finalizeHand(player, p, total, cframe, rollOffset)
	local tuning = PianoHandAnimatorV2.Tuning
	local mea = player.Meas[p]
	local keyboard = player.Keyboard

	local pointToObjectSpace = cframe:PointToObjectSpace(mea.ShoulderAtt.WorldPosition)

	local v5 = math.atan2(total.X - pointToObjectSpace.X, pointToObjectSpace.Z - total.Z)
	local maxYawDeg = math.rad(tuning.MaxYawDeg)
	local v6 = math.clamp(v5 * tuning.YawFollow, -maxYawDeg, maxYawDeg)
	local cframe2 = CFrame.Angles(0, -v6, 0) * handBasis( -- inferred equivalent call
		math.rad(tuning.FingerPitchDeg),
		math.rad(tuning.RollDeg) + (rollOffset or 0)
	)

	local position = mea.GripLocal.Position
	local position2 = mea.WristLocal.Position
	local v7 = total - cframe2:VectorToWorldSpace(position)

	local v8 = v7 + cframe2:VectorToWorldSpace(position2) - pointToObjectSpace
	local magnitude = v8.Magnitude
	local v9 = tuning.ReachMaxRatio * (mea.UpperLen + mea.LowerLen)
	local v10 = tuning.ReachSoftStart * v9
	local v11 = magnitude / math.max(v9, 0.0001)

	if v10 < magnitude and magnitude > 0.0001 then
		local v12 = math.max(v9 - v10, 0.0001)
		local v13 = v10 + v12 * math.tanh((magnitude - v10) / v12)
		local v14 = v8.Unit * (v13 - magnitude)
		v7 += v14
		total += v14
	end

	local handSize = mea.HandSize
	local midpoint = (math.abs(cframe2.XVector.Y) * handSize.X + math.abs(cframe2.YVector.Y) * handSize.Y + math.abs(cframe2.ZVector.Y) * handSize.Z) / 2
	local v12 = keyboard.WhiteTopY + midpoint + tuning.HandFloorClearance

	if v7.Y < v12 then
		local v13 = v12 - v7.Y
		v7 += Vector3.new(0, v13, 0)
		total += Vector3.new(0, v13, 0)
	end

	return v7, cframe2, v11
end

local function destroyState(player)
	if player.Connection then
		player.Connection:Disconnect()
		player.Connection = nil
	end

	if player.AncestryConn then
		player.AncestryConn:Disconnect()
		player.AncestryConn = nil
	end

	for _, v5 in ipairs(v4) do
		local v6 = player.Hands and player.Hands[v5]

		if v6 and v6.IK then
			v6.IK:Destroy()
		end
	end

	if player.Rig then
		player.Rig:Destroy()
	end

	player.Phase = "Dead"
end

local function stepState(player, dt)
	if player.Phase == "Dead" then
		return
	end

	local tuning = PianoHandAnimatorV2.Tuning
	local now = os.clock()
	local seat = player.Seat

	if player.Character.Parent and seat.Parent then
		local cframe = seat.CFrame
		player.SeatCF = cframe
		local v5

		if player.Phase == "Ending" then
			local v6 = (now - player.EndStart) / math.max(tuning.BlendOutSeconds, 0.001)
			v5 = player.EndWeight0 * (1 - smoothstep(v6)) -- inferred equivalent call

			if v6 >= 1 then
				destroyState(player)
				return
			end
		else
			v5 = smoothstep((now - player.ReadyAt) / math.max(tuning.BlendInSeconds, 0.001)) -- inferred equivalent call
		end

		player.CurrentWeight = v5

		local v6 = {}
		local v7 = {}

		for _, v8 in ipairs(v4) do
			local v9, v10 = desiredGrip(player, v8, now)
			v6[v8] = v9
			v7[v8] = v10
		end

		local v8 = tuning.MinHandGapRatio * (player.Meas.Left.ArmLen + player.Meas.Right.ArmLen) / 2

		if v6.Left.X > v6.Right.X - v8 then
			local midpointX = (v6.Left.X + v6.Right.X) / 2
			v6.Left = Vector3.new(midpointX - v8 / 2, v6.Left.Y, v6.Left.Z)
			v6.Right = Vector3.new(midpointX + v8 / 2, v6.Right.Y, v6.Right.Z)
		end

		for _, v9 in ipairs(v4) do
			local mea = player.Meas[v9]
			local hand = player.Hands[v9]

			local objectSpace = mea.Lower.CFrame:ToObjectSpace(mea.Hand.CFrame)
			local twist = math.atan2(objectSpace.ZVector.X, objectSpace.ZVector.Z)
			local maxRollOffsetDeg = math.rad(tuning.MaxRollOffsetDeg)
			hand.RollOffset = math.clamp(
				(hand.RollOffset or 0) - twist * math.min(tuning.TwistRelaxGain * dt, 0.6),
				-maxRollOffsetDeg,
				maxRollOffsetDeg
			)
			hand.Twist = twist

			local goal, v10, reachRatio = finalizeHand(player, v9, v6[v9], cframe, hand.RollOffset)

			if now - player.ReadyAt < tuning.StartDelaySeconds then
				goal = hand.Pos
				v10 = hand.Rot
			end

			local v11 = v7[v9] and tuning.HalfLifeMove or tuning.HalfLifeRest

			if now - player.ReadyAt < tuning.StartupSeconds then
				v11 = tuning.HalfLifeStart
			end

			local pos, vel = springVec(hand.Pos, hand.Vel, goal, v11, dt) -- inferred equivalent call
			hand.Pos = pos
			hand.Vel = vel
			local v12 = 1 - math.exp(-dt * 0.69314718056 / math.max(tuning.HalfLifeRot, 0.001))
			hand.Rot = hand.Rot:Lerp(v10, v12)

			local handSize = mea.HandSize
			local xVector = hand.Rot.XVector
			local yVector = hand.Rot.YVector
			local zVector = hand.Rot.ZVector
			local midpoint = (math.abs(xVector.Y) * handSize.X + math.abs(yVector.Y) * handSize.Y + math.abs(zVector.Y) * handSize.Z) / 2
			local midpoint2 = (math.abs(xVector.Z) * handSize.X + math.abs(yVector.Z) * handSize.Y + math.abs(zVector.Z) * handSize.Z) / 2
			local v13 = player.Keyboard.WhiteTopY + midpoint + tuning.HandFloorClearance

			local pathLiftBand = tuning.PathLiftBand

			local v14 = smoothstep((hand.Pos.Y - (v13 - pathLiftBand)) / pathLiftBand) -- inferred equivalent call

			if not hand.GuardDone and (v14 >= 0.999 or now - player.ReadyAt > tuning.StartupGuardMax) then
				hand.GuardDone = true
			end

			local v15 = hand.GuardDone and 1 or v14

			local v16 = player.Keyboard.WhiteNearEdgeZ + tuning.PathRailDepth + midpoint2 + tuning.HandFloorClearance - tuning.PathForwardAllowance * v15

			if hand.Pos.Z < v16 then
				hand.Pos = Vector3.new(hand.Pos.X, hand.Pos.Y, v16)

				if hand.Vel.Z < 0 then
					hand.Vel = Vector3.new(hand.Vel.X, hand.Vel.Y, 0)
				end
			end

			if hand.GuardDone and hand.Pos.Y < v13 then
				hand.Pos = Vector3.new(hand.Pos.X, v13, hand.Pos.Z)

				if hand.Vel.Y < 0 then
					hand.Vel = Vector3.new(hand.Vel.X, 0, hand.Vel.Z)
				end
			end

			local cframe2 = cframe * (CFrame.new(hand.Pos) * hand.Rot)
			hand.Target.CFrame = cframe2

			local v17 = cframe2 * mea.GripLocal.Position
			local position = Vector3.new(v3[v9] * tuning.PoleOutRatio, -tuning.PoleDownRatio, tuning.PoleBackRatio) * mea.ArmLen
			local rotation = cframe.Rotation

			if hand.PoleIsAttachment then
				hand.PoleAnchor.CFrame = CFrame.new(v17) * rotation
				hand.PoleAtt.Position = position
			else
				hand.PoleAnchor.CFrame = CFrame.new(v17 + rotation:VectorToWorldSpace(position))
			end

			hand.IK.Weight = v5
			hand.Debug = { Goal = goal, ReachRatio = reachRatio, Active = v7[v9], Grip = v6[v9] }
		end
	else
		destroyState(player)

		if v[player.Character] == player then
			v[player.Character] = nil
		end
	end
end

local function buildRig(player): boolean
	local character = player.Character
	local seat = player.Seat
	local cframe = seat.CFrame
	player.SeatCF = cframe

	local keysFolder = findKeysFolder(seat)
	local keyboard = keysFolder and measureKeyboard(seat, keysFolder)

	if not keyboard then
		warn("[PianoHandAnimatorV2] keyboard tidak ditemukan dari seat -- V2 dibatalkan")
		return false
	end

	player.Keyboard = keyboard

	local meas = {}

	for _, v5 in ipairs(v4) do
		meas[v5] = measureSide(character, v5, cframe)

		if not meas[v5] then
			warn("[PianoHandAnimatorV2] rig " .. v5 .. " tidak lengkap -- V2 dibatalkan")
			return false
		end
	end

	player.Meas = meas

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	player.SeatedHeight = humanoidRootPart and cframe:PointToObjectSpace(humanoidRootPart.Position).Y or nil

	local pianoIKRigV2 = Instance.new("Folder")
	pianoIKRigV2.Name = "PianoIKRigV2"
	pianoIKRigV2.Parent = character
	player.Rig = pianoIKRigV2

	player.Hands = {}

	for _, v5 in ipairs(v4) do
		player.Hands[v5] = buildIK(player, v5, meas[v5])
	end

	if player.Pending then
		for k, intent in pairs(player.Pending.Intents) do
			player.Hands[k].Intent = intent
			player.Hands[k].HoldUntil = player.Pending.HoldUntil[k] or 0
		end

		for k, count in pairs(player.Pending.Counts) do
			player.Hands[k].Count = count
		end

		player.Pending = nil
	end

	player.ReadyAt = os.clock()
	player.Phase = "Ready"

	task.delay(PianoHandAnimatorV2.Tuning.BlendInSeconds + 0.05, function()
		if v[character] == player and player.Phase == "Ready" then
			PianoArmPoseAnimator.Setup(character)
		end
	end)
	player.Connection = RunService.PreAnimation:Connect(function(dt)
		stepState(player, dt)
	end)
	player.AncestryConn = character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			destroyState(player)

			if v[character] == player then
				v[character] = nil
			end
		end
	end)
	return true
end

function PianoHandAnimatorV2.BeginSession(instance)
	if not PianoHandAnimatorV2.Enabled or not instance or v[instance] then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		return
	end

	local v5 = {
		Character = instance,
		Humanoid = humanoid,
		Phase = "Starting",
		Pending = {
			Intents = {},
			HoldUntil = {},
			Counts = { Left = 0, Right = 0 }
		}
	}

	v[instance] = v5

	task.spawn(function()
		local total = 0

		while v[instance] == v5 and not humanoid.SeatPart and total < 3 do
			task.wait(0.1)
			total += 0.1
		end

		if v[instance] ~= v5 then
			return
		end

		local seatPart = humanoid.SeatPart

		if seatPart then
			v5.Seat = seatPart

			if not buildRig(v5) then
				v[instance] = nil
				PianoArmPoseAnimator.Cleanup(instance)
			end
		else
			warn("[PianoHandAnimatorV2] karakter tidak duduk -- V2 dibatalkan")
			v[instance] = nil
			PianoArmPoseAnimator.Cleanup(instance)
		end
	end)
end

function PianoHandAnimatorV2.EndSession(p)
	local v5 = p and v[p]

	if not v5 then
		return
	end

	v[p] = nil
	PianoArmPoseAnimator.Cleanup(p)

	if v5.Phase ~= "Ready" then
		v5.Phase = "Dead"

		return
	end

	v5.Phase = "Ending"
	v5.EndStart = os.clock()
	v5.EndWeight0 = v5.CurrentWeight or 1
end

local function intentFromEntries(_, list, p, cframe)
	local tuning = PianoHandAnimatorV2.Tuning
	local minValue = 1e999
	local maxValue = -1e999
	local total = 0
	local total2 = 0
	local count = 0

	for _, item in ipairs(list) do
		if item.hand ~= p then
			continue
		end

		local note = item.note
		minValue = math.min(minValue, note)
		maxValue = math.max(maxValue, note)
		local pointToObjectSpace = cframe:PointToObjectSpace((item.originalCFrame or item.keyPart.CFrame).Position)
		local size = item.keyPart.Size
		local v5 = size.Z < 1
		total += pointToObjectSpace.Y + size.Y / 2
		total2 += v5 and pointToObjectSpace.Z or pointToObjectSpace.Z + size.Z / 2 - tuning.ContactInset
		count += 1
	end

	if count == 0 then
		return nil
	end

	local anchorBias = tuning.AnchorBias
	local anchorMidi

	if p == "Right" then
		anchorMidi = maxValue * anchorBias + minValue * (1 - anchorBias)
	else
		anchorMidi = minValue * anchorBias + maxValue * (1 - anchorBias)
	end

	return {
		AnchorMidi = anchorMidi,
		TopY = total / count,
		ContactZ = total2 / count,
		Span = maxValue - minValue
	}
end

function PianoHandAnimatorV2.UpdateForChordGroup(p, list)
	local v5 = p and v[p]

	if not v5 or not list or #list == 0 or not v5.Seat then
		return
	end

	local tuning = PianoHandAnimatorV2.Tuning
	local cframe = v5.Seat.CFrame
	local now = os.clock()

	for _, v6 in ipairs(v4) do
		local intent2 = intentFromEntries(v5, list, v6, cframe)

		if not intent2 then
			continue
		end

		if v5.Phase == "Ready" then
			local hand = v5.Hands[v6]
			local intent = hand.Intent

			if
				intent
				and (hand.Count > 0 or now < hand.HoldUntil)
				and math.abs(intent.AnchorMidi - intent2.AnchorMidi) < tuning.DeadzoneSemitones
			then
				intent2.AnchorMidi = intent.AnchorMidi
			end

			hand.Intent = intent2
			hand.HoldUntil = math.max(hand.HoldUntil, now + tuning.RestDelay)
		elseif v5.Pending then
			v5.Pending.Intents[v6] = intent2
			v5.Pending.HoldUntil[v6] = now + tuning.RestDelay
		end
	end
end

function PianoHandAnimatorV2.NotePressed(p, p2)
	local v5 = p and v[p]

	if not v5 then
		return
	end

	if v5.Phase == "Ready" and v5.Hands[p2] then
		v5.Hands[p2].Count += 1
	elseif v5.Pending then
		v5.Pending.Counts[p2] = (v5.Pending.Counts[p2] or 0) + 1
	end
end

function PianoHandAnimatorV2.NoteReleased(p, p2)
	local v5 = p and v[p]

	if not v5 then
		return
	end

	if v5.Phase == "Ready" and v5.Hands[p2] then
		local hand = v5.Hands[p2]
		hand.Count = math.max(0, hand.Count - 1)
		hand.HoldUntil = math.max(hand.HoldUntil, os.clock() + PianoHandAnimatorV2.Tuning.RestDelay)
	elseif v5.Pending then
		v5.Pending.Counts[p2] = math.max(0, (v5.Pending.Counts[p2] or 0) - 1)
	end
end

function PianoHandAnimatorV2.GetState(p)
	return p and v[p]
end

function PianoHandAnimatorV2.GetMeasurements(p)
	local v5 = p and v[p]

	if not (v5 and v5.Meas) then
		return nil
	end

	local result = { SeatedHeight = v5.SeatedHeight, Keyboard = v5.Keyboard }

	for _, v6 in ipairs(v4) do
		local mea = v5.Meas[v6]
		result[v6] = {
			ShoulderSeat = mea.ShoulderSeat,
			UpperLen = mea.UpperLen,
			LowerLen = mea.LowerLen,
			HandLen = mea.HandLen,
			ArmLen = mea.ArmLen,
			HandSize = mea.HandSize,
			SeedGripSeat = mea.SeedGripSeat,
			ShoulderToKeyboardForward = (v5.Keyboard.WhiteNearEdgeZ - mea.ShoulderSeat.Z) * -1,
			ShoulderHeightAboveKeys = mea.ShoulderSeat.Y - v5.Keyboard.WhiteTopY
		}
	end

	return result
end

local function onLifecycle(localPlayer, p)
	if not PianoHandAnimatorV2.Enabled or type(p) ~= "table" or p.InstrumentType ~= "Piano" then
		return
	end

	local character = localPlayer and localPlayer.Character

	if not character then
		return
	end

	v2[character] = (v2[character] or 0) + 1
	local v5 = v2[character]

	if p.Lifecycle == "SessionStart" then
		task.delay(0.1, function()
			if v2[character] == v5 then
				PianoHandAnimatorV2.BeginSession(character)
			end
		end)
	elseif p.Lifecycle == "SessionEnd" then
		PianoHandAnimatorV2.EndSession(character)
	end
end

if RunService:IsClient() then
	task.spawn(function()
		local InstrumentLifecycleSignal = require(ReplicatedStorage.Modules.InstrumentLifecycleSignal)
		InstrumentLifecycleSignal.Event:Connect(function(p)
			onLifecycle(Players.LocalPlayer, p)
		end)
		local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
		local instrumentLifecycleEvent = remotes and remotes:WaitForChild("InstrumentLifecycleEvent", 30)

		if instrumentLifecycleEvent then
			instrumentLifecycleEvent.OnClientEvent:Connect(onLifecycle)
		end
	end)
end

return PianoHandAnimatorV2