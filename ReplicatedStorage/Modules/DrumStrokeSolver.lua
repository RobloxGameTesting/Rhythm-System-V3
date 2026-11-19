local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function orthonormal(data) -- 6 equivalent calls inferred from this helper
	local unit = data.XVector.Unit
	local yVector = data.YVector
	local unit2 = (yVector - unit * yVector:Dot(unit)).Unit
	return CFrame.fromMatrix(data.Position, unit, unit2)
end

local function mirrorX(cframe) -- 1 equivalent call inferred from this helper
	local components, v, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = cframe:GetComponents()
	return CFrame.new(-components, v, v2, v3, -v4, -v5, -v6, v7, v8, -v9, v10, v11)
end

local v = {
	Snare = {
		Left = orthonormal(CFrame.new( -- inferred equivalent call
			-1.5719,
			2.0008,
			-0.5074,
			0.8367,
			0.0376,
			0.5464,
			-0.2406,
			0.9215,
			0.305,
			-0.492,
			-0.3867,
			0.78
		)),
		Right = orthonormal(CFrame.new( -- inferred equivalent call
			-0.2813,
			1.9428,
			-0.8108,
			0.8324,
			0.0943,
			0.5461,
			-0.3382,
			0.8671,
			0.3657,
			-0.4391,
			-0.4891,
			0.7537
		))
	},
	HiHat = {
		Left = orthonormal(CFrame.new( -- inferred equivalent call
			-1.9488,
			2.1322,
			-0.6806,
			0.8238,
			0.1421,
			0.5488,
			-0.0386,
			0.9799,
			-0.1958,
			-0.5656,
			0.1401,
			0.8127
		))
	},
	Crash = {
		Left = orthonormal(CFrame.new( -- inferred equivalent call
			-1.8133,
			2.5915,
			-1.7975,
			0.9183,
			0.2484,
			0.3084,
			0.0188,
			0.7506,
			-0.6605,
			-0.3955,
			0.6124,
			0.6845
		))
	}
}

local cframe = orthonormal(CFrame.new( -- inferred equivalent call
	1.8105,
	3.0935,
	-1.6292,
	0.8274,
	-0.2423,
	-0.5066,
	-0.0846,
	0.838,
	-0.5391,
	0.5551,
	0.4889,
	0.6729
))
local cframe2 = CFrame.new(
	1.6224,
	3.5288,
	-1.3424,
	0.8863,
	-0.3629,
	-0.2876,
	-0.1432,
	0.3757,
	-0.9156,
	0.4403,
	0.8527,
	0.281
)
local unit = cframe2.XVector.Unit
local yVector = cframe2.YVector
local unit2 = (yVector - unit * yVector:Dot(unit)).Unit
local objectSpace = cframe:ToObjectSpace((CFrame.fromMatrix(cframe2.Position, unit, unit2)))
local v2 = { Right = objectSpace, Left = mirrorX(objectSpace) } -- inferred equivalent call

v.Ride = { Right = cframe }

local function smooth(value) -- 7 equivalent calls inferred from this helper
	local v3 = math.clamp(value, 0, 1)
	return v3 * v3 * (3 - 2 * v3)
end

local function smoother(w) -- 1 equivalent call inferred from this helper
	local v3 = math.clamp(w, 0, 1)
	return v3 * v3 * v3 * (v3 * (6 * v3 - 15) + 10)
end

local function easeOut(value) -- 2 equivalent calls inferred from this helper
	local v3 = math.clamp(value, 0, 1)
	return 1 - (1 - v3) * (1 - v3)
end

local function attackFor(p) -- 1 equivalent call inferred from this helper
	return (math.clamp(0.26 * p, 0.06, 0.11))
end

local function reboundFor(p) -- 1 equivalent call inferred from this helper
	return (math.clamp(0.14 * p, 0.055, 0.085))
end

local function heightForGap(p) -- 1 equivalent call inferred from this helper
	return (math.clamp(0.3 + (p - 0.12) * (7 / 3), 0.3, 1))
end

local function gBetween(p, p2)
	local v3 = heightForGap(p2) -- inferred equivalent call
	local v4 = math.clamp(reboundFor(p2) / p2, 0.12, 0.45) -- inferred equivalent call
	local v5 = math.max(1 - math.min(attackFor(p2), 0.45 * p2) / p2, v4 + 0.05) -- inferred equivalent call

	if p < v4 then
		return v3 * 0.85 * easeOut(p / v4) -- inferred equivalent call
	elseif p < v5 then
		return v3 * (0.85 + 0.27000000000000013 * smooth((p - v4) / (v5 - v4))) -- inferred equivalent call
	else
		local v6 = math.clamp((p - v5) / (1 - v5), 0, 1)
		return v3 * 1.12 * (1 - v6 * v6)
	end
end

local function gRelease(p) -- 2 equivalent calls inferred from this helper
	if p < 0.07 then
		return 0.85 * easeOut(p / 0.07) -- inferred equivalent call
	end

	return 0.85 + 0.15 * smooth((p - 0.07) / 0.13) -- inferred equivalent call
end

local function gPre(p) -- 2 equivalent calls inferred from this helper
	if p >= 0.13 then
		return 1
	end

	if p >= 0.09 then
		return 1 + 0.12 * smooth((0.13 - p) / 0.04) -- inferred equivalent call
	end

	local v3 = 1 - p / 0.09
	return 1.12 * (1 - v3 * v3)
end

local function swing(p, p2)
	local unit3 = p.Unit
	local unit4 = p2.Unit
	local dot = unit3:Dot(unit4)

	if dot > 0.99999 then
		return CFrame.new()
	end

	if not (dot < -0.99999) then
		return CFrame.fromAxisAngle(unit3:Cross(unit4).Unit, (math.acos((math.clamp(dot, -1, 1)))))
	end

	local v3 = unit3:Cross(Vector3.new(1, 0, 0))

	if v3.Magnitude < 0.001 then
		v3 = unit3:Cross(Vector3.new(0, 1, 0))
	end

	return CFrame.fromAxisAngle(v3.Unit, 3.141592653589793)
end

local function finite(p): boolean -- 7 equivalent calls inferred from this helper
	local position = p.Position
	return position.X == position.X
		and position.Y == position.Y
		and position.Z == position.Z
		and math.abs(position.X) < 100000
		and math.abs(position.Y) < 100000
		and math.abs(position.Z) < 100000
end

local function getArmJoints(instance, side)
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
			ua = child,
			la = child2,
			hd = child3,
			sh = motor6D,
			el = motor6D2,
			wr = motor6D3,
			shC0 = motor6D.C0,
			elC0 = motor6D2.C0,
			wrC0 = motor6D3.C0
		}
	end

	return nil
end

local function jointsValid(j): boolean -- 4 equivalent calls inferred from this helper
	return j.waist.Parent == j.ut
		and j.sh.Parent == j.ua
		and j.el.Parent == j.la
		and j.wr.Parent == j.hd
		and j.ut.Parent ~= nil
end

local function solve(data, p, value, value2, p2, value3, p3)
	local cframe3 = data.lt.CFrame * data.waist.C0 * data.waist.Transform * data.waist.C1:Inverse()
	local transform = data.sh.Transform
	local transform2 = data.el.Transform
	local transform3 = data.wr.Transform
	local c1 = data.sh.C1
	local c1_2 = data.el.C1
	local c1_3 = data.wr.C1

	local v3 = data.elC0.Position - c1.Position
	local v4 = data.wrC0.Position - c1_2.Position
	local magnitude = v3.Magnitude
	local magnitude2 = v4.Magnitude

	local position = (cframe3 * data.shC0).Position
	local cframe4 = cframe3 * data.shC0 * c1:Inverse()

	local position2 = (p * c1_3).Position
	local v5 = position2 - position
	local magnitude3 = v5.Magnitude

	if magnitude3 < 0.0001 then
		return nil
	end

	if p2 and p2 > 0 then
		local v6 = magnitude3 - (magnitude + magnitude2) * 0.99

		if v6 > 0 then
			position += v5.Unit * math.min(v6, p2)
			v5 = position2 - position
			magnitude3 = v5.Magnitude

			if magnitude3 < 0.0001 then
				return nil
			end
		end
	end

	local v6 = math.clamp(magnitude3, math.abs(magnitude - magnitude2) + 0.001, (magnitude + magnitude2) * 0.99)
	local unit3 = v5.Unit

	local v7 = (magnitude * magnitude - magnitude2 * magnitude2 + v6 * v6) / (v6 * 2)
	local v8 = math.sqrt((math.max(magnitude * magnitude - v7 * v7, 0)))

	local v9 = 0.35 + (value or 0)
	v9 = data.side == "Left" and -v9 or v9
	local vector = cframe3:VectorToWorldSpace((Vector3.new(v9, -1 + (value3 or 0), 0.15 + (value2 or 0))))
	local v10 = vector - unit3 * vector:Dot(unit3)

	if v10.Magnitude < 0.001 then
		v10 = unit3:Cross(Vector3.new(0, 1, 0))

		if v10.Magnitude < 0.001 then
			v10 = unit3:Cross(Vector3.new(1, 0, 0))
		end
	end

	local unit4 = v10.Unit
	local v11 = p3 or position + unit3 * v7 + unit4 * v8

	local v12 = swing(cframe4:VectorToWorldSpace(v3), v11 - position)
	local cframe5 = CFrame.new(position) * (v12 * cframe4.Rotation) * CFrame.new(-c1.Position)
	local v13 = cframe3:Inverse() * cframe5 * c1 * transform:Inverse()

	local position3 = (cframe5 * data.elC0).Position
	local rotation = (cframe5 * data.elC0 * c1_2:Inverse()).Rotation
	local v14 = position + unit3 * v6
	local v15 = swing(rotation:VectorToWorldSpace(v4), v14 - position3)
	local cframe6 = CFrame.new(position3) * (v15 * rotation) * CFrame.new(-c1_2.Position)
	local v16 = cframe5:Inverse() * cframe6 * c1_2 * transform2:Inverse()

	local position4 = (cframe6 * data.wrC0).Position
	local v17 = CFrame.new(position4) * p.Rotation * CFrame.new(-c1_3.Position)
	local v18 = cframe6:Inverse() * v17 * c1_3 * transform3:Inverse()

	if finite(v13) and finite(v16) and finite(v18) then -- inferred equivalent call
		return v13, v16, v18
	end

	return nil
end

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local object3 = setmetatable({}, { __mode = "k" })

local function getState(p) -- 6 equivalent calls inferred from this helper
	local state = object[p]

	if not state then
		state = { arms = {} }
		object[p] = state
	end

	return state
end

local function toggledOff(attributeName): boolean -- 6 equivalent calls inferred from this helper
	local localPlayer = Players.LocalPlayer
	return localPlayer ~= nil and localPlayer:GetAttribute(attributeName) == false
end

local tuneFields = {}
local tuneCombos = { "Snare_Left", "Snare_Right", "HiHat_Left", "Crash_Left", "Ride_Right" }

local v3 = {
	"X",
	"Y",
	"Z",
	"Pitch",
	"Yaw",
	"Roll",
	"PoleOut",
	"PoleFwd",
	"PoleUp"
}
local tuneDefaults = {
	Lift = 1,
	AssistPitch = 12,
	AssistYaw = 16,
	BodyMul = 1,
	LookMul = 1,
	SwayMul = 0,
	ProcRide = 0,
	ShoulderReach = 0,
	GripTilt = 0,
	LegHip = 0,
	LegKnee = 0,
	LegAnkle = 0,
	KickMul = 1,
	KickAnkle = 1,
	KickKnee = 1,
	TapAssist = 1,
	NoLeft_MidTom = 0,
	NoLeft_FloorTom = 0,
	CorrRise = 0,
	GripIdle = 1,
	GripOutX_Left = 0,
	GripOutY_Left = 0,
	GripOutZ_Left = 0,
	GripOutX_Right = 0,
	GripOutY_Right = 0,
	GripOutZ_Right = 0
}
local tuneTypes = { "Snare", "HiHat", "Crash", "Ride", "HiTom", "MidTom", "FloorTom" }
local v4 = { "Left", "Right" }

local tuneJointFields = {
	"ShoulderX",
	"ShoulderY",
	"ShoulderZ",
	"ElbowX",
	"ElbowY",
	"WristX",
	"WristY",
	"WristZ",
	"GripTilt",
	"ElbowLift"
}
local v5 = false
local v6 = {
	Snare = Vector3.new(-2.09, 1.01, -2.09),
	HiHat = Vector3.new(-2.97, 2.19, -2.74),
	Crash = Vector3.new(-2.26, 3.7, -4.1)
}
local v7 = { HiHat = true, Crash = true, Snare = true }

local v8 = {
	Ride = { Right = "ProcRide" }
}
local dynamicContactConfig = {
	Crash = {
		Right = {
			shoulder = 1.3,
			pitch = 14,
			yaw = 20,
			sink = 0.12,
			inset = 0.15,
			liftScale = 0.7,
			springW = 24,
			lead = 0.1
		}
	},
	HiHat = {
		Right = {
			shoulder = 1.2,
			pitch = 12,
			yaw = 18,
			sink = 0.12,
			inset = 0.3,
			liftScale = 0.7,
			springW = 24,
			lead = 0.1
		}
	},
	MidTom = {
		Left = {
			shoulder = 1.2,
			pitch = 12,
			yaw = 16,
			sink = 0.12,
			inset = 0.3,
			liftScale = 0.7,
			springW = 24,
			lead = 0.1
		}
	},
	FloorTom = {
		Left = {
			shoulder = 2.2,
			pitch = 14,
			yaw = 20,
			sink = 0.12,
			inset = 0.3,
			liftScale = 0.7,
			springW = 24,
			lead = 0.12
		},
		Right = {
			shoulder = 1.2,
			pitch = 12,
			yaw = 16,
			sink = 0.12,
			inset = 0.3,
			liftScale = 0.7,
			springW = 24,
			lead = 0.1,
			hand = 1.3,
			aimK = -0.55
		}
	}
}
local DrumStrokeSolver = {}

local v9 = {
	Ride = { Left = true }
}

for _, v10 in ipairs({
	"Lift",
	"AssistPitch",
	"AssistYaw",
	"BodyMul",
	"LookMul",
	"SwayMul",
	"ProcRide",
	"ShoulderReach",
	"GripTilt",
	"LegHip",
	"LegKnee",
	"LegAnkle",
	"KickMul",
	"KickAnkle",
	"KickKnee",
	"TapAssist",
	"NoLeft_MidTom",
	"NoLeft_FloorTom",
	"CorrRise",
	"GripIdle",
	"GripOutX_Left",
	"GripOutY_Left",
	"GripOutZ_Left",
	"GripOutX_Right",
	"GripOutY_Right",
	"GripOutZ_Right"
}) do
	table.insert(tuneFields, v10)
end

for _, v10 in ipairs(tuneCombos) do
	for _, v11 in ipairs(v3) do
		local v12 = v10 .. "_" .. v11
		table.insert(tuneFields, v12)
		tuneDefaults[v12] = 0
	end
end

for _, v10 in ipairs(tuneTypes) do
	for _, v11 in ipairs(v4) do
		for _, v12 in ipairs(tuneJointFields) do
			local v13 = v10 .. "_" .. v11 .. "_" .. v12
			table.insert(tuneFields, v13)
			tuneDefaults[v13] = 0
		end
	end
end

local v10 = {
	Woman = {
		ShoulderReach = 0.5,
		AssistPitch = 3,
		AssistYaw = 4,
		SwayMul = 1.5,
		ProcRide = 1,
		Ride_Right_X = 0.529,
		Ride_Right_Y = 0.05,
		Ride_Right_Z = 0.087,
		Ride_Right_Pitch = -6.164,
		Ride_Right_Yaw = 8.382,
		Ride_Right_Roll = 17.213,
		Ride_Right_PoleOut = 0.201,
		Ride_Right_PoleFwd = -0.097,
		Snare_Left_X = 0.207,
		Snare_Left_Y = -0.176,
		Snare_Left_Z = 0.232,
		Snare_Left_Pitch = 3.028,
		Snare_Left_Yaw = 0.79,
		Snare_Left_Roll = -9.383,
		Snare_Left_PoleOut = 0.336,
		Snare_Left_PoleFwd = -0.362,
		Snare_Right_X = -0.057,
		Snare_Right_Y = -0.405,
		Snare_Right_Z = -0.131,
		Snare_Right_Pitch = 26.146,
		Snare_Right_Yaw = 7.006,
		Snare_Right_Roll = 3.193,
		Snare_Right_PoleOut = -0.069,
		Snare_Right_PoleFwd = 0.207,
		HiHat_Left_X = 0.522,
		HiHat_Left_Y = -0.304,
		HiHat_Left_Z = -0.027,
		HiHat_Left_Pitch = 0.302,
		HiHat_Left_Yaw = 18.395,
		HiHat_Left_Roll = -31.371,
		HiHat_Left_PoleOut = 0.481,
		HiHat_Left_PoleFwd = -0.578,
		Crash_Left_Y = -0.03
	},
	XBOX_M = {
		GripTilt = 40,
		Snare_Left_GripTilt = 25,
		Snare_Right_GripTilt = 15,
		HiHat_Left_GripTilt = 5,
		Ride_Left_GripTilt = -10,
		Crash_Left_GripTilt = -20,
		HiTom_Left_GripTilt = -20,
		HiTom_Right_GripTilt = -40,
		MidTom_Left_GripTilt = 30,
		MidTom_Right_GripTilt = -40,
		FloorTom_Left_GripTilt = 10,
		FloorTom_Right_GripTilt = 45,
		Snare_Left_PoleUp = 0.8,
		HiHat_Left_PoleUp = 0.8,
		Snare_Right_PoleUp = 1,
		FloorTom_Right_ElbowLift = 45,
		MidTom_Left_ElbowLift = 35,
		FloorTom_Left_ElbowLift = 60
	},
	Mix = {
		GripTilt = 40,
		GripIdle = 0.9,
		GripOutY_Left = 0.12,
		GripOutZ_Left = 0.4,
		Snare_Left_GripTilt = 15,
		Snare_Right_GripTilt = 15,
		HiHat_Left_GripTilt = 15,
		HiHat_Right_GripTilt = 20,
		Ride_Left_GripTilt = 10,
		Crash_Left_GripTilt = 10,
		Crash_Right_GripTilt = 20,
		HiTom_Left_GripTilt = 15,
		HiTom_Right_GripTilt = -20,
		MidTom_Left_GripTilt = 30,
		MidTom_Right_GripTilt = -40,
		FloorTom_Left_GripTilt = 10,
		FloorTom_Right_GripTilt = 15,
		Snare_Left_PoleUp = 0.8,
		HiHat_Left_PoleUp = 0.8,
		Snare_Left_Pitch = 10,
		Snare_Left_Y = -0.2,
		Snare_Right_X = -0.057,
		Snare_Right_Y = -0.62,
		Snare_Right_Z = -0.4,
		Snare_Right_Pitch = 26.146,
		Snare_Right_Yaw = 7.006,
		Snare_Right_Roll = 3.193,
		Snare_Right_PoleOut = -0.069,
		Snare_Right_PoleFwd = 0.207,
		Snare_Right_PoleUp = 1.1,
		FloorTom_Right_ElbowLift = 45,
		MidTom_Left_ElbowLift = 35,
		FloorTom_Left_ElbowLift = 60,
		HiHat_Left_Y = -0.36,
		ShoulderReach = 0.9,
		TapAssist = 0,
		CorrRise = 360,
		NoLeft_FloorTom = 1,
		LegKnee = -18,
		KickMul = 3,
		KickKnee = -1,
		KickAnkle = 0.9
	}
}

local v11 = nil
local v12 = {}
local object4 = setmetatable({}, { __mode = "k" })
local object5 = setmetatable({}, { __mode = "k" })

local function getTune(character)
	local now = os.clock()
	local v13 = object5[character]

	if v13 and now - v13.t < 0.004 then
		return v13.v
	end

	local localPlayer = Players.LocalPlayer
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local v14

	if localPlayer == nil then
		v14 = false
	else
		v14 = playerFromCharacter == localPlayer
	end

	local v15 = object4[character]

	if not v15 or now - v15.t > 3 then
		local name = "Masculine"
		local drumTuneForceCategory = playerFromCharacter and playerFromCharacter:GetAttribute("DrumTuneForceCategory")

		if type(drumTuneForceCategory) == "string" and drumTuneForceCategory ~= "" then
			name = drumTuneForceCategory
		elseif playerFromCharacter then
			if v11 == nil then
				v11 = false
				pcall(function()
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					v11 = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("AvatarTypeVerify", 5))
				end)
			end

			if v11 then
				local success, avatarType = pcall(v11.GetAvatarType, playerFromCharacter)

				if success and avatarType then
					name = tostring(avatarType)
				end
			end
		end

		v15 = { name = name, t = now }
		object4[character] = v15
	end

	local v16 = v10[v15.name]

	if v14 and localPlayer:GetAttribute("DrumTuneCategory") ~= v15.name then
		local drumTuneCategory = localPlayer:GetAttribute("DrumTuneCategory")

		if type(drumTuneCategory) == "string" then
			local attributes = {}

			for _, v17 in ipairs(tuneFields) do
				attributes[v17] = localPlayer:GetAttribute("DrumTune_" .. v17)
			end

			v12[drumTuneCategory] = attributes
		end

		localPlayer:SetAttribute("DrumTuneCategory", v15.name)
		local v17 = v12[v15.name]

		for _, v18 in ipairs(tuneFields) do
			local v19 = v17 and v17[v18]

			if type(v19) ~= "number" then
				v19 = v16 and v16[v18]
			end

			if type(v19) ~= "number" then
				v19 = tuneDefaults[v18]
			end

			localPlayer:SetAttribute("DrumTune_" .. v18, v19)
		end
	end

	local result = {}

	for _, v17 in ipairs(tuneFields) do
		local v18 = v16 and v16[v17]

		if type(v18) ~= "number" then
			v18 = tuneDefaults[v17]
		end

		if v14 then
			local attribute = localPlayer:GetAttribute("DrumTune_" .. v17)

			if type(attribute) == "number" then
				v18 = attribute
			end
		end

		result[v17] = v18
	end

	object5[character] = { t = now, v = result }
	return result
end

local function tunedContact(instance, p, p2, p3)
	local tune = getTune(instance)
	local v13 = p .. "_" .. p2
	local v14 = tune[v13 .. "_X"]
	local v15 = tune[v13 .. "_Y"]
	local v16 = tune[v13 .. "_Z"]
	local v17 = tune[v13 .. "_Pitch"]
	local v18 = tune[v13 .. "_Yaw"] or 0
	local v19 = tune[v13 .. "_Roll"] or 0

	if v14 and (v14 ~= 0 or v15 ~= 0 or v16 ~= 0 or v17 ~= 0 or v18 ~= 0 or v19 ~= 0) then
		return CFrame.new(p3.Position + Vector3.new(v14, v15, v16)) * CFrame.Angles(math.rad(v17), math.rad(v18), (math.rad(v19))) * p3.Rotation
	end

	return p3
end

local v13 = {
	torsoPitch = { w = 13, z = 0.5 },
	torsoYaw = { w = 9, z = 0.7 },
	torsoRoll = { w = 9, z = 0.7 },
	headPitch = { w = 15, z = 0.45 },
	headYaw = { w = 9, z = 0.7 },
	headRoll = { w = 9, z = 0.7 },
	legPressR = { w = 28, z = 0.7 },
	legPressL = { w = 28, z = 0.7 },
	torsoLook = { w = 7, z = 1 },
	headLook = { w = 9, z = 0.9 },
	assistPitch = { w = 6, z = 1 },
	assistYaw = { w = 6, z = 1 },
	swayYaw = { w = 6, z = 1 },
	swayRoll = { w = 6, z = 1 },
	swayPitch = { w = 7, z = 1 },
	swayNod = { w = 8, z = 0.9 }
}

local v14 = {
	torsoPitch = 4.5,
	torsoYaw = 5,
	torsoRoll = 3.5,
	headPitch = 9,
	headYaw = 5,
	headRoll = 4,
	legPressR = 1.4,
	legPressL = 1.4,
	torsoLook = 12,
	headLook = 12,
	assistPitch = 24,
	assistYaw = 28,
	swayYaw = 6,
	swayRoll = 4,
	swayPitch = 4,
	swayNod = 5
}

local v15 = {
	Snare = { pitch = 1.8, yaw = 1.6, roll = 0.9, head = 4.6 },
	HiHat = { pitch = 0.5, yaw = 0.9, roll = 0.5, head = 0.8 },
	Ride = { pitch = 0.5, yaw = 0.9, roll = 0.5, head = 0.8 },
	Crash = { pitch = 2, yaw = 2.4, roll = 1.4, head = 2.4 },
	HiTom = { pitch = 1, yaw = 1.3, roll = 0.8, head = 1.4 },
	MidTom = { pitch = 1.2, yaw = 1.5, roll = 0.9, head = 1.6 },
	FloorTom = { pitch = 1.6, yaw = 1.8, roll = 1.2, head = 2 },
	Kick = {
		pitch = 0.9,
		yaw = 0,
		roll = 0.5,
		head = 1.6,
		leg = 1
	}
}

local v16 = {
	Snare = { yaw = 1, roll = 0.5, pitch = 0.5, nod = 1.6 },
	HiHat = { yaw = 0.6, roll = 0.3, pitch = 0.3, nod = 0.8 },
	Ride = { yaw = 0.6, roll = 0.3, pitch = 0.3, nod = 0.8 },
	Crash = { yaw = 1.6, roll = 0.9, pitch = 0.8, nod = 2 },
	HiTom = { yaw = 1, roll = 0.5, pitch = 0.5, nod = 1.2 },
	MidTom = { yaw = 1.1, roll = 0.6, pitch = 0.6, nod = 1.3 },
	FloorTom = { yaw = 1.3, roll = 0.8, pitch = 0.7, nod = 1.6 },
	Kick = { yaw = 0, roll = 0, pitch = 0.6, nod = 1 }
}

local _ = { yaw = 4, roll = 2.5, pitch = 2.5, nod = 3.5 }
local v17 = { yaw = 0.9, roll = 0.9, pitch = 0.5, nod = 0.35 }
local v18 = {
	HiHat = { Right = 0.1 }
}

local v19 = {
	HiHat = -2.97,
	Crash = -2.26,
	Snare = -2.09,
	HiTom = -0.86,
	MidTom = 1.57,
	FloorTom = 2.57,
	Ride = 3
}

local v20 = { Snare = 0.7, Ride = 0.6 }

local v21 = {
	0,
	3,
	6,
	9,
	12,
	15,
	18,
	21,
	24
}

local v22 = {
	-28,
	-24,
	-20,
	-16,
	-12,
	-8,
	-4,
	0,
	4,
	8,
	12,
	16,
	20,
	24,
	28
}

local function lateralOf(p, p2, p3) -- 1 equivalent call inferred from this helper
	local v23 = p2 and p2[p3]

	if v23 then
		return p.CFrame:PointToObjectSpace(v23).X
	end

	return v19[p3]
end

local function peakFactor(z) -- 1 equivalent call inferred from this helper
	local v23 = math.sqrt(1 - z * z)
	return (math.exp(-z / v23 * math.atan2(v23, z)))
end

local function nearlyEqual(data, data2): boolean -- 5 equivalent calls inferred from this helper
	return (data.Position - data2.Position).Magnitude < 0.0001
		and data.LookVector:Dot(data2.LookVector) > 0.999999
		and data.UpVector:Dot(data2.UpVector) > 0.999999
end

local function getBodyJoints(instance)
	local upperTorso = instance:FindFirstChild("UpperTorso")
	local head = instance:FindFirstChild("Head")
	local rightUpperLeg = instance:FindFirstChild("RightUpperLeg")
	local rightLowerLeg = instance:FindFirstChild("RightLowerLeg")
	local rightFoot = instance:FindFirstChild("RightFoot")
	local leftUpperLeg = instance:FindFirstChild("LeftUpperLeg")
	local leftLowerLeg = instance:FindFirstChild("LeftLowerLeg")
	local leftFoot = instance:FindFirstChild("LeftFoot")

	if not (upperTorso and head and rightUpperLeg and rightLowerLeg and rightFoot and leftUpperLeg and leftLowerLeg and leftFoot) then
		return nil
	end

	local v23 = {
		waist = upperTorso:FindFirstChild("Waist"),
		neck = head:FindFirstChild("Neck"),
		rHip = rightUpperLeg:FindFirstChild("RightHip"),
		rKnee = rightLowerLeg:FindFirstChild("RightKnee"),
		rAnkle = rightFoot:FindFirstChild("RightAnkle"),
		lHip = leftUpperLeg:FindFirstChild("LeftHip"),
		lKnee = leftLowerLeg:FindFirstChild("LeftKnee"),
		lAnkle = leftFoot:FindFirstChild("LeftAnkle")
	}

	for _, motor6D in pairs(v23) do
		if not (motor6D and motor6D:IsA("Motor6D")) then
			return nil
		end
	end

	return v23
end

local function newBody(char)
	local bodyJoints = getBodyJoints(char)

	if not bodyJoints then
		return nil
	end

	local springs = {}

	for k in pairs(v13) do
		springs[k] = { x = 0, v = 0 }
	end

	return {
		J = bodyJoints,
		char = char,
		springs = springs,
		pending = {},
		lastEvent = -1000000000,
		keepAlive = -1000000000,
		k = 0,
		written = {},
		bases = {},
		applied = false,
		damps = {},
		dampK = 0,
		dampFactor = 1,
		smW = CFrame.new(),
		smN = CFrame.new(),
		lastImpulseTc = -1000000000,
		lookTorso = 0,
		lookHead = 0,
		lookUntil = -1000000000,
		assistPitchTarget = 0,
		assistYawTarget = 0,
		swayT = { yaw = 0, roll = 0, pitch = 0, nod = 0 }
	}
end

local function kickSpring(state, p, p2) -- 8 equivalent calls inferred from this helper
	local v23 = v13[p]
	state.springs[p].v += p2 * (state.bodyMul or 1) * v23.w / peakFactor(v23.z) -- inferred equivalent call
end

local function applyImpulse(state, data)
	local v23 = v15[data.type]

	if not v23 or data.skip then
		return
	end

	local v24 = data.hand == "Right" and 1 or data.hand == "Left" and -1 or 0
	local v25 = 1
	local v26

	if data.type == "Kick" then
		local v27 = data.t - (state.lastKickT or -1000000000)
		local lastKickFoot

		if v27 >= 0.45 or v27 < 0 then
			lastKickFoot = "Right"
		else
			lastKickFoot = state.lastKickFoot == "Right" and "Left" or "Right"

			if v27 < 0.2 then
				v25 = 0.6
			end
		end

		state.lastKickT = data.t
		state.lastKickFoot = lastKickFoot
		v26 = lastKickFoot == "Right" and "legPressR" or "legPressL"
		v24 = lastKickFoot == "Right" and 1 or -1
	else
		v26 = "legPressR"
	end

	local v27 = v16[data.type]

	if state.swayMul and state.swayMul > 0 and v27 then
		local swayT = state.swayT
		local swayMul = state.swayMul
		swayT.yaw = math.clamp(swayT.yaw + v27.yaw * v24 * swayMul, -4 * swayMul, 4 * swayMul)
		swayT.roll = math.clamp(swayT.roll + v27.roll * v24 * swayMul, -2.5 * swayMul, 2.5 * swayMul)
		swayT.pitch = math.clamp(swayT.pitch + v27.pitch * swayMul, 0, 2.5 * swayMul)
		swayT.nod = math.clamp(swayT.nod + v27.nod * swayMul, 0, 3.5 * swayMul)

		if v23.leg then
			kickSpring(state, v26, v23.leg * v25) -- inferred equivalent call
		end
	else
		kickSpring(state, "torsoPitch", v23.pitch) -- inferred equivalent call
		kickSpring(state, "torsoYaw", v23.yaw * v24) -- inferred equivalent call
		kickSpring(state, "torsoRoll", v23.roll * v24) -- inferred equivalent call
		kickSpring(state, "headPitch", v23.head) -- inferred equivalent call
		kickSpring(state, "headYaw", v23.yaw * 0.5 * v24) -- inferred equivalent call
		kickSpring(state, "headRoll", -v23.roll * 0.5 * v24) -- inferred equivalent call

		if v23.leg then
			kickSpring(state, v26, v23.leg * v25) -- inferred equivalent call
		end
	end
end

local function writeJoint(state, p, p2, p3) -- 8 equivalent calls inferred from this helper
	local v23 = p2.C0
	local v24 = state.written[p]

	if v24 and nearlyEqual(v23, v24) then -- inferred equivalent call
		v23 = state.bases[p]
	end

	state.bases[p] = v23
	local c0 = v23 * p3
	p2.C0 = c0
	state.written[p] = c0
end

local function restoreJoint(p, p2, p3)
	local v23 = p.written[p2]

	if v23 and nearlyEqual(p3.C0, v23) and p.bases[p2] then -- inferred equivalent call
		p3.C0 = p.bases[p2]
	end

	p.written[p2] = nil
	p.bases[p2] = nil
end

local function restoreBody(state)
	for k, v23 in pairs(state.J) do
		pcall(restoreJoint, state, k, v23)
	end

	state.applied = false
end

local function stepBody(state, p, p2, p3)
	local j = state.J

	if j.waist.Parent == nil or j.neck.Parent == nil then
		state.dead = true
		return
	end

	local tune = getTune(state.char)
	local bodyMul = tune.BodyMul
	local lookMul = tune.LookMul
	state.bodyMul = bodyMul
	state.lookMul = lookMul
	state.swayMul = tune.SwayMul
	state.kickMul = tune.KickMul or 1
	state.kickAnkle = tune.KickAnkle or 1
	state.kickKnee = tune.KickKnee or 1
	local v23 = { tune.LegHip or 0, tune.LegKnee or 0, tune.LegAnkle or 0 }
	local v24

	if v23[1] == 0 and v23[2] == 0 then
		v24 = not (v23[3] == 0)
	else
		v24 = true
	end

	while state.pending[1] and state.pending[1].t <= p2 do
		local v25 = table.remove(state.pending, 1)

		if p and p.SeatPart then
			applyImpulse(state, v25)
		end
	end

	local v25

	if p == nil or p.SeatPart == nil then
		v25 = false
	else
		v25 = not toggledOff("DrumBodyMotion") -- inferred equivalent call
	end

	local v26 = math.max(state.lastEvent, state.keepAlive)
	local v27 = v25 and (p2 - v26 < 1.8 or #state.pending > 0)

	local legStatic = state.legStatic

	if not legStatic then
		legStatic = { 0, 0, 0 }
		state.legStatic = legStatic
	end

	local v28 = math.min(1, p3 * 6)

	for i = 1, 3 do
		legStatic[i] += ((v24 and v25 and v23[i] or 0) - legStatic[i]) * v28
	end

	local v29 = v24 and v25 or math.abs(legStatic[1]) + math.abs(legStatic[2]) + math.abs(legStatic[3]) > 0.01

	if v27 then
		state.k = math.min(1, state.k + p3 / 0.03)
	else
		state.k = math.max(0, state.k - p3 / 0.6)
	end

	local v30 = math.min(p3, 1 / 30)

	local swayT = state.swayT
	local v31 = 0

	for k, v32 in pairs(v17) do
		swayT[k] *= math.exp(-v30 / v32)
	end

	for k, spring in pairs(state.springs) do
		local v32 = v13[k]
		local v43 = v32.w

		if state.assistSpringW and (k == "assistPitch" or k == "assistYaw") then
			v43 = state.assistSpringW
		end

		local v44 = 0

		if k == "torsoLook" then
			v44 = p2 < state.lookUntil and state.lookTorso * (state.lookMul or 1) or 0
		elseif k == "headLook" then
			v44 = p2 < state.lookUntil and state.lookHead * (state.lookMul or 1) or 0
		elseif k == "assistPitch" then
			v44 = state.assistPitchTarget
		elseif k == "assistYaw" then
			v44 = state.assistYawTarget
		elseif k == "swayYaw" then
			v44 = swayT.yaw
		elseif k == "swayRoll" then
			v44 = swayT.roll
		elseif k == "swayPitch" then
			v44 = swayT.pitch
		elseif k == "swayNod" then
			v44 = swayT.nod
		end

		spring.v += (-v43 * v43 * (spring.x - v44) - 2 * v32.z * v43 * spring.v) * v30
		spring.x += spring.v * v30
		local v45 = v14[k]
		spring.x = math.clamp(spring.x, -v45, v45)
		v31 = math.max(v31, math.abs(spring.x), math.abs(spring.v) * 0.05)
	end

	if state.k <= 0.001 and v31 < 0.005 and #state.pending == 0 and not v29 then
		if state.applied then
			restoreBody(state)

			for _, spring in pairs(state.springs) do
				spring.x = 0
				spring.v = 0
			end
		end
	else
		local v32 = 0

		for i = #state.damps, 1, -1 do
			local damp = state.damps[i]

			if damp.b < p2 then
				table.remove(state.damps, i)
			elseif damp.a <= p2 then
				v32 = 1
			end
		end

		state.dampK += (v32 - state.dampK) * math.min(1, p3 * (state.dampK < v32 and 25 or 5))
		local v43 = CFrame.new()
		local v44 = CFrame.new()

		if state.dampK > 0.001 then
			local v45 = 1 - state.dampK * (1 - state.dampFactor)
			local v46 = 1 - math.exp(-3 * p3)
			local transform = j.waist.Transform
			local transform2 = j.neck.Transform
			state.smW = state.smW:Lerp(CFrame.new():Lerp(transform, v45), v46)
			state.smN = state.smN:Lerp(CFrame.new():Lerp(transform2, v45), v46)
			v43 = state.smW * transform:Inverse()
			v44 = state.smN * transform2:Inverse()
		else
			local transform = j.waist.Transform
			local transform2 = j.neck.Transform
			state.smW = transform
			state.smN = transform2
		end

		local v45 = state.k * state.k * (3 - 2 * state.k)
		local springs = state.springs

		local rad = math.rad
		local x = springs.assistPitch.x
		local x2 = springs.assistYaw.x
		writeJoint( -- inferred equivalent call
			state,
			"waist",
			j.waist,
			CFrame.Angles(
				-rad(springs.torsoPitch.x + x + springs.swayPitch.x) * v45,
				-rad(springs.torsoYaw.x + springs.torsoLook.x + x2 + springs.swayYaw.x) * v45,
				-rad(springs.torsoRoll.x + springs.swayRoll.x) * v45
			) * v43
		)

		writeJoint( -- inferred equivalent call
			state,
			"neck",
			j.neck,
			CFrame.Angles(
				-rad(springs.headPitch.x - 0.6 * x + springs.swayNod.x - 0.5 * springs.swayPitch.x) * v45,
				-rad(springs.headYaw.x + springs.headLook.x - 0.4 * x2 - 0.35 * springs.swayYaw.x) * v45,
				-rad(springs.headRoll.x - 0.6 * springs.swayRoll.x) * v45
			) * v44
		)
		local kickMul = state.kickMul or 1
		local kickAnkle = state.kickAnkle or 1
		local kickKnee = state.kickKnee or 1
		local v46 = springs.legPressR.x * v45 * kickMul
		writeJoint(state, "rHip", j.rHip, CFrame.Angles(rad(6 * v46 + legStatic[1]), 0, 0)) -- inferred equivalent call
		writeJoint(state, "rKnee", j.rKnee, CFrame.Angles(rad(8 * v46 * kickKnee + legStatic[2]), 0, 0)) -- inferred equivalent call
		writeJoint(state, "rAnkle", j.rAnkle, CFrame.Angles(rad(-22 * v46 * kickAnkle + legStatic[3]), 0, 0)) -- inferred equivalent call
		local v47 = springs.legPressL.x * v45 * kickMul
		writeJoint(state, "lHip", j.lHip, CFrame.Angles(rad(6 * v47 + legStatic[1]), 0, 0)) -- inferred equivalent call
		writeJoint(state, "lKnee", j.lKnee, CFrame.Angles(rad(8 * v47 * kickKnee + legStatic[2]), 0, 0)) -- inferred equivalent call
		writeJoint(state, "lAnkle", j.lAnkle, CFrame.Angles(rad(-22 * v47 * kickAnkle + legStatic[3]), 0, 0)) -- inferred equivalent call
		state.applied = true
	end
end

local function newArm(armJoints, hand)
	return {
		J = armJoints,
		hand = hand,
		lift = v2[hand],
		watchUntil = 0,
		lastDepth = 0,
		stickPts = nil,
		overlap = nil,
		rayParams = nil,
		armLength = (armJoints.elC0.Position - armJoints.sh.C1.Position).Magnitude + (armJoints.wrC0.Position - armJoints.el.C1.Position).Magnitude,
		w = 0,
		queue = {},
		prev = nil,
		lastGap = nil,
		lastBase = nil,
		forceRelease = false,
		targetW = nil,
		applied = false
	}
end

local function restoreArm(state) -- 4 equivalent calls inferred from this helper
	local j = state.J

	if jointsValid(j) then -- inferred equivalent call
		local sh = j.sh
		local el = j.el
		local wr = j.wr
		local shC0 = j.shC0
		local elC0 = j.elC0
		local wrC0 = j.wrC0
		sh.C0 = shC0
		el.C0 = elC0
		wr.C0 = wrC0
	end

	state.applied = false
	state.targetW = nil
end

local object6 = setmetatable({}, { __mode = "k" })

local function findDisplayModel(p)
	local v23 = object6[p]

	if v23 ~= nil then
		return v23 or nil
	end

	local parent = p.Parent
	local v24 = nil

	while parent do
		local displayModel = parent:FindFirstChild("DisplayModel")

		if displayModel then
			v24 = displayModel
			break
		end

		parent = parent.Parent
	end

	object6[p] = v24 or false
	return v24
end

local function setupCollision(state, instance, p)
	local displayModel = findDisplayModel(p)
	local part = instance:FindFirstChild(state.hand .. "Drumstick", true)

	if not (displayModel and part and part:IsA("BasePart")) then
		return
	end

	local size = part.Size
	local v23 = size.X >= size.Y and size.X >= size.Z and Vector3.new(1, 0, 0)
		or size.Y >= size.Z and Vector3.new(0, 1, 0)
		or Vector3.new(0, 0, 1)
	local v24 = math.max(size.X, size.Y, size.Z) / 2
	local objectSpace2 = state.J.hd.CFrame:ToObjectSpace(part.CFrame)

	if state.gripApplied and state.gripG and state.gripApplied ~= 0 then
		local rotation = state.J.wr.C1.Rotation
		objectSpace2 = CFrame.new(state.gripG) * (rotation * CFrame.Angles(math.rad(state.gripApplied), 0, 0) * rotation:Inverse()) * CFrame.new(-state.gripG) * objectSpace2
	end

	local v25 = objectSpace2 * (v23 * v24)
	local v26 = objectSpace2 * (v23 * -v24)

	if not (v25.Magnitude < v26.Magnitude) then
		v26, v25 = v25, v26
	end

	local stickPts = {}

	for i = 0, 4 do
		stickPts[#stickPts + 1] = v26:Lerp(v25, i / 6)
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { displayModel }
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { displayModel }
	state.stickPts = stickPts
	state.overlap = overlapParams
	state.rayParams = raycastParams
end

local function penetration(data, p)
	local maxValue = 0

	if data.gripShiftInv then
		p *= data.gripShiftInv
	end

	for _, stickPt in ipairs(data.stickPts) do
		local v23 = p * stickPt

		if not (#workspace:GetPartBoundsInRadius(v23, 0.04, data.overlap) > 0) then
			continue
		end

		local raycastResult = workspace:Raycast(v23 + Vector3.new(0, 0.6, 0), Vector3.new(0, -1.2, 0), data.rayParams)
		maxValue = math.max(
			maxValue,
			raycastResult and raycastResult.Position.Y > v23.Y and raycastResult.Position.Y - v23.Y or 0.02
		)
	end

	return maxValue
end

local function surfaceClearance(state, p) -- 2 equivalent calls inferred from this helper
	local raycastResult = workspace:Raycast(p + Vector3.new(0, 2.5, 0), Vector3.new(0, -6, 0), state.rayParams)

	if raycastResult then
		return p.Y - raycastResult.Position.Y
	end

	return nil
end

local object7 = setmetatable({}, { __mode = "k" })

local function plateDims(instance)
	local size = instance.Size
	local cframe3 = instance.CFrame
	local v23 = { size.X, size.Y, size.Z }
	local v24 = { cframe3.RightVector, cframe3.UpVector, cframe3.LookVector }
	local v25 = 1

	local v26 = v23[2] < v23[v25] and 2 or v25
	local v27 = v23[3] < v23[v26] and 3 or v26

	local v28 = v23[v27]
	local maxValue = 0

	if v27 ~= 1 then
		maxValue = math.max(maxValue, v23[1])
	end

	if v27 ~= 2 then
		maxValue = math.max(maxValue, v23[2])
	end

	if v27 ~= 3 then
		maxValue = math.max(maxValue, v23[3])
	end

	return v28, maxValue, v28 <= 0.25 and v28 <= maxValue * 0.3 and math.abs(v24[v27].Y) >= 0.8
end

local function findPlate(p, p2)
	local v23 = object7[p]

	if not v23 then
		v23 = {}
		object7[p] = v23
	end

	local v24 = v23[p2]

	if v24 ~= nil then
		return v24 or nil, v23[p2 .. "#set"]
	end

	local displayModel = findDisplayModel(p)
	local part = nil
	local v25 = 0
	local v26 = {}

	if displayModel then
		for _, part2 in ipairs(displayModel:GetDescendants()) do
			if not (part2:IsA("BasePart") and part2:GetAttribute("ReactionType") == p2) then
				continue
			end

			local parent = part2.Parent
			local v27 = false

			while parent and parent ~= displayModel do
				if parent.Name == "Stand" then
					v27 = true
					break
				end

				parent = parent.Parent
			end

			if v27 then
				continue
			end

			local thick, v28, flat = plateDims(part2)
			v26[#v26 + 1] = {
				part = part2,
				thick = thick,
				area = v28 * v28,
				flat = flat
			}
		end
	end

	local v27 = false

	for _, v28 in ipairs(v26) do
		if v28.flat then
			v27 = true
			break
		end
	end

	local v28 = {}

	for _, v29 in ipairs(v26) do
		if not (v29.flat or not v27) then
			continue
		end

		v28[#v28 + 1] = v29

		if not (v25 < v29.area) then
			continue
		end

		part = v29.part
		v25 = v29.area
	end

	local parts = {}

	if part then
		local v29 = part.Position.Y + plateDims(part) / 2

		for _, v30 in ipairs(v28) do
			local area = v30.area

			if not (v25 * 0.7 <= area) then
				continue
			end

			parts[#parts + 1] = v30.part
			local v31 = v30.part.Position.Y + v30.thick / 2

			if not (v29 < v31) then
				continue
			end

			part = v30.part
			v29 = v31
		end
	end

	v23[p2] = part or false
	v23[p2 .. "#set"] = parts
	return part, parts
end

local function buildDynamicContact(state, p, p2, data)
	local dynCache = state.dynCache

	if not dynCache then
		dynCache = {}
		state.dynCache = dynCache
	end

	if dynCache[p2] then
		return dynCache[p2]
	end

	local stickPts = state.stickPts
	local plate, v23 = findPlate(p, p2)

	if not (stickPts and plate) then
		return nil
	end

	local v24, v25 = plateDims(plate)
	local j = state.J
	local position = (j.lt.CFrame * j.waist.C0 * j.waist.C1:Inverse() * j.shC0).Position
	local inverse = p.CFrame:Inverse()
	local v26 = inverse * position

	local position2 = plate.Position
	local v27 = v25 / 2
	local vector3 = Vector3.new(position.X - position2.X, 0, position.Z - position2.Z)
	local v28 = position2 + (vector3.Magnitude > 0.001 and vector3.Unit or Vector3.new(1, 0, 0)) * (data.aimK and data.aimK * v27 or math.max(v27 - data.inset, 0.2))
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = not (v23 and #v23 > 0 and v23) and { plate } or v23
	local raycastResult = workspace:Raycast(v28 + Vector3.new(0, 1.5, 0), Vector3.new(0, -3, 0), raycastParams)
	local v29 = inverse * ((raycastResult and raycastResult.Position or Vector3.new(v28.X, position2.Y + v24 / 2, v28.Z)) - Vector3.new(0, data.sink or 0, 0))

	local stickPt = stickPts[1]
	local v30 = stickPts[1] - stickPts[5]
	local v31 = v29 - v26

	if v30.Magnitude < 0.001 or v31.Magnitude < 0.001 then
		return nil
	end

	local magnitude = v31.Magnitude
	local unit3 = v30.Unit
	local unit4 = v31.Unit

	local magnitude2 = stickPt.Magnitude

	if data.hand and magnitude2 > 0.1 and magnitude - magnitude2 < data.hand then
		local hand = data.hand
		local v32 = (magnitude * magnitude + hand * hand - magnitude2 * magnitude2) / (2 * magnitude)
		local v43 = hand * hand - v32 * v32
		local v44 = Vector3.new(0, 1, 0) - unit4 * unit4.Y

		if v43 > 0 and v44.Magnitude > 0.001 then
			unit4 = (v29 - (v26 + unit4 * v32 + v44.Unit * math.sqrt(v43))).Unit
		end
	end

	local rotation = cframe.Rotation
	local v32 = swing(rotation * unit3, unit4) * rotation
	local v43 = v29 - v32 * stickPt
	local v44 = orthonormal(CFrame.new(v43) * v32) -- inferred equivalent call

	if not finite(v44) then -- inferred equivalent call
		return nil
	end

	dynCache[p2] = v44
	return v44
end

local function rigidAbout(position, cframe3, p) -- 4 equivalent calls inferred from this helper
	return CFrame.new(position) * cframe3 * CFrame.new(-position) * p
end

local function tapAssist(state, p): boolean
	local j = state.J
	local cframe3 = j.lt.CFrame * j.waist.C0 * j.waist.Transform * j.waist.C1:Inverse()
	local v23 = cframe3 * j.shC0 * j.sh.Transform * j.sh.C1:Inverse()
	local v24 = v23 * j.elC0 * j.el.Transform * j.el.C1:Inverse()
	local v25 = v24 * j.wrC0 * j.wr.Transform * j.wr.C1:Inverse()

	local v26 = v25 * state.stickPts[1]
	local v27 = surfaceClearance(state, v26) -- inferred equivalent call
	local v28 = not (v27 and v27 < 0.45) and 0 or math.clamp(0.45 - v27, 0, 1.2)

	local tapLift = state.tapLift or 0
	local v29

	if tapLift < v28 then
		v29 = v28
	else
		v29 = tapLift + (v28 - tapLift) * math.min(1, p * 30)
	end

	local tapLift2 = v29 < 0.002 and v28 == 0 and 0 or v29

	state.tapLift = tapLift2

	if tapLift2 == 0 and not (v27 and v27 < 0.45) then
		if state.applied then
			restoreArm(state) -- inferred equivalent call
		end

		return true
	else
		local position = (cframe3 * j.shC0).Position
		local vector = v26 - position
		local magnitude = Vector3.new(vector.X, 0, vector.Z).Magnitude
		local v30 = vector:Cross(Vector3.new(0, 1, 0))
		local v31 = v30.Magnitude > 0.001

		if v31 then
			v30 = v30.Unit
		end

		local v32 = v27 and math.max(v27, 0) + 0.012 or nil

		local function build(p2)
			local v43 = v23
			local v44 = v24
			local v45 = v25

			if p2 > 0 and v31 then
				local cframe4 = CFrame.fromAxisAngle(v30, (math.min(p2 / math.max(magnitude, 0.5), 0.6)))
				v43 = rigidAbout(position, cframe4, v23) -- inferred equivalent call
				v44 = rigidAbout(position, cframe4, v24) -- inferred equivalent call
				v45 = rigidAbout(position, cframe4, v25) -- inferred equivalent call
			end

			local v46

			if v32 then
				local position2 = (v45 * j.wr.C1).Position
				local v47 = v45 * state.stickPts[1] - position2
				local magnitude2 = v47.Magnitude
				local cross = v47.Unit:Cross(Vector3.new(0, 1, 0))

				if magnitude2 > 0.1 and cross.Magnitude > 0.001 then
					local unit3 = cross.Unit
					v46 = v45
					local v48 = 0

					for _ = 1, 2 do
						local v49 = surfaceClearance(state, v46 * state.stickPts[1]) -- inferred equivalent call

						if not v49 then
							break
						end

						v48 = math.clamp(
							v48 + math.asin((math.clamp((v49 - v32) / magnitude2, -0.95, 0.95))),
							-0.6108652381980153,
							0.9599310885968813
						)
						v46 = rigidAbout(position2, CFrame.fromAxisAngle(unit3, -v48), v45) -- inferred equivalent call
					end
				else
					v46 = v45
				end
			else
				v46 = v45
			end

			return v43, v44, v46
		end

		local v43, cframe4, v44 = build(tapLift2)

		local v45 = penetration(state, v44)
		local total = 0

		for _ = 1, 3 do
			if v45 <= 0.03 then
				break
			end

			total += v45 + 0.01
			v43, cframe4, v44 = build(tapLift2 + total)
			v45 = penetration(state, v44)
		end

		local c0 = cframe3:Inverse() * v43 * j.sh.C1 * j.sh.Transform:Inverse()
		local c0_2 = cframe4:Inverse() * v44 * j.wr.C1 * j.wr.Transform:Inverse()

		if not finite(c0) then -- inferred equivalent call
			return true
		end

		if not finite(c0_2) then -- inferred equivalent call
			return true
		end

		local sh = j.sh
		local el = j.el
		local wr = j.wr
		local elC0 = j.elC0
		sh.C0 = c0
		el.C0 = elC0
		wr.C0 = c0_2
		state.applied = true

		return true
	end
end

local function collisionOnly(state, value)
	local localPlayer = Players.LocalPlayer

	local parent = state.J.sh and state.J.sh.Parent and state.J.sh.Parent.Parent

	local v23 = not parent or (getTune(parent).TapAssist or 1) ~= 0

	if
		state.tap
		and v23
		and localPlayer
		and localPlayer:GetAttribute("DrumTapAssist") ~= false
		and tapAssist(state, value or 1 / 60)
	then
		return
	end

	local j = state.J
	local cframe3 = j.lt.CFrame * j.waist.C0 * j.waist.Transform * j.waist.C1:Inverse() * j.shC0 * j.sh.Transform * j.sh.C1:Inverse() * j.elC0 * j.el.Transform * j.el.C1:Inverse()
	local v24 = cframe3 * j.wrC0 * j.wr.Transform * j.wr.C1:Inverse()
	local lastDepth2 = penetration(state, v24)

	local lastDepth = state.lastDepth or 0
	state.lastDepth = lastDepth2
	local v25 = lastDepth2 + math.max(0, lastDepth2 - lastDepth) * 1.2

	local position = (v24 * j.wr.C1).Position
	local v26 = v24 * state.stickPts[1] - position
	local magnitude = v26.Magnitude
	local v27

	if magnitude > 0.1 and v25 > 0.004 then
		v27 = math.min(v25 / magnitude, 0.5235987755982988) * smooth(v25 / 0.03) -- inferred equivalent call
	else
		v27 = 0
	end

	local corrRise = parent and getTune(parent).CorrRise or 0

	if corrRise > 0 then
		v27 = math.min(v27, (state.corrTheta or 0) + math.rad(corrRise) * (value or 1 / 60))
	end

	local corrTheta = math.max(v27, (state.corrTheta or 0) * 0.78)
	state.corrTheta = corrTheta

	if corrTheta < 0.002617993877991494 then
		state.corrTheta = 0

		if state.applied then
			restoreArm(state) -- inferred equivalent call
		end
	else
		local cross = v26.Unit:Cross(Vector3.new(0, 1, 0))

		if cross.Magnitude < 0.001 then
			return
		end

		local v28 = nil

		for _ = 1, 4 do
			local cframe4 = CFrame.fromAxisAngle(cross.Unit, corrTheta)
			v28 = CFrame.new(position) * cframe4 * CFrame.new(-position) * v24

			if penetration(state, v28) <= lastDepth2 + 0.01 then
				break
			end

			corrTheta *= 0.5

			if corrTheta < 0.002617993877991494 then
				corrTheta = 0
				break
			end
		end

		state.corrTheta = corrTheta

		if corrTheta == 0 then
			if state.applied then
				restoreArm(state) -- inferred equivalent call
			end
		else
			local c0 = cframe3:Inverse() * v28 * j.wr.C1 * j.wr.Transform:Inverse()

			if finite(c0) then -- inferred equivalent call
				local sh = j.sh
				local el = j.el
				local shC0 = j.shC0
				local elC0 = j.elC0
				sh.C0 = shC0
				el.C0 = elC0
				j.wr.C0 = c0
				state.applied = true
			end
		end
	end
end

local function computeStroke(data, p)
	local prev = data.prev
	local v23 = data.queue[1]
	local v24 = 1
	local v25 = data.lastBase

	if prev and prev.hold and not v23 and p < prev.Tc + prev.hold then
		return 0, prev.base, prev.scale or 1
	end

	if prev and v23 then
		local v26 = v23.Tc - prev.Tc
		local v27 = v23.Tc - p

		if v26 > 0.6 then
			if v27 > 0.13 then
				v24 = gRelease(p - prev.Tc) -- inferred equivalent call
			else
				v24 = gPre(v27) -- inferred equivalent call
			end

			v25 = prev.base:Lerp(v23.base, smooth((0.55 - v27) / 0.38)) -- inferred equivalent call
		else
			local v28 = math.max(v26, 0.06)
			local v29 = math.clamp(p - prev.Tc, 0, v28)
			v24 = gBetween(v29 / v28, v28)
			v25 = prev.base:Lerp(v23.base, smooth((v29 / v28 - 0.15) / 0.6)) -- inferred equivalent call
		end
	elseif prev then
		v24 = gRelease(p - prev.Tc - (prev.hold or 0)) -- inferred equivalent call
		v25 = prev.base
	elseif v23 then
		v24 = gPre(v23.Tc - p) -- inferred equivalent call
		v25 = v23.base
	end

	if prev and not prev.hold then
		local v26 = p - prev.Tc

		if v26 < 0.08 then
			v24 += math.sin(150.79644737231007 * v26) * 0.035 * math.exp(-v26 / 0.02)
		end
	end

	return math.clamp(v24, 0, 1.3), v25, v23 and v23.scale or prev and prev.scale or 1
end

local function gripRot(p, p2) -- 4 equivalent calls inferred from this helper
	local rotation = p.wr.C1.Rotation
	return rotation * CFrame.Angles(math.rad(p2) * 1, 0, 0) * rotation:Inverse()
end

local function gripMotors(p)
	local motor6Ds = {}

	for _, motor6D in ipairs(p.J.hd:GetChildren()) do
		if motor6D.Name == "InstrumentGrip" and motor6D:IsA("Motor6D") and motor6D.Part1 ~= nil then
			motor6Ds[#motor6Ds + 1] = motor6D
		end
	end

	return motor6Ds
end

local function gripOffset(p)
	local parent = p.J.hd and p.J.hd.Parent

	if parent and p.hand then
		local tune = getTune(parent)
		return (Vector3.new(
			tune["GripOutX_" .. p.hand] or 0,
			tune["GripOutY_" .. p.hand] or 0,
			tune["GripOutZ_" .. p.hand] or 0
		))
	end

	return Vector3.new(0, 0, 0)
end

local function syncGrip(state, gripApplied)
	local v23 = gripMotors(state)

	if #v23 == 0 then
		state.gripMotor = nil
		state.gripG = nil
		state.gripApplied = nil
		state.gripShiftInv = nil
		return 0
	elseif gripApplied == 0 then
		for _, v24 in ipairs(v23) do
			local drumGripOrigC0 = v24:GetAttribute("DrumGripOrigC0")

			if not drumGripOrigC0 then
				continue
			end

			v24.C0 = drumGripOrigC0
			v24:SetAttribute("DrumGripOrigC0", nil)
		end

		state.gripMotor = nil
		state.gripG = nil
		state.gripApplied = nil
		state.gripShiftInv = nil
		return 0
	else
		local gripG = nil

		for _, v24 in ipairs(v23) do
			local v25 = v24:GetAttribute("DrumGripOrigC0")

			if not v25 then
				v25 = v24.C0
				v24:SetAttribute("DrumGripOrigC0", v25)
			end

			local position = v25.Position
			v24.C0 = CFrame.new((gripOffset(state))) * CFrame.new(position) * gripRot(state.J, -gripApplied) * CFrame.new(-position) * v25 -- inferred equivalent call
			gripG = gripG or position
		end

		state.gripOff = gripOffset(state)
		state.gripApplied = gripApplied
		state.gripMotor = v23[1]
		state.gripG = gripG
		local v24 = gripG - state.J.wr.C1.Position
		state.gripShiftInv = CFrame.new(gripRot(state.J, gripApplied):VectorToWorldSpace(v24) - v24) -- inferred equivalent call
		return gripApplied
	end
end

local function gripShift(data, gripCur)
	local gripG = data.gripG

	if not gripG or gripCur == 0 then
		return CFrame.identity
	end

	local v23 = gripG - data.J.wr.C1.Position
	return CFrame.new(-(gripRot(data.J, gripCur):VectorToWorldSpace(v23) - v23) - (data.gripOff or Vector3.new(0, 0, 0))) -- inferred equivalent call
end

local function gripWristDelta(j, p) -- 1 equivalent call inferred from this helper
	local transform = j.wr.Transform
	return transform * gripRot(j, p) * transform:Inverse() -- inferred equivalent call
end

local function restoreGrip(p)
	if p.J.hd then
		for _, motor6D in ipairs(p.J.hd:GetChildren()) do
			if not (motor6D.Name == "InstrumentGrip" and motor6D:IsA("Motor6D")) then
				continue
			end

			local drumGripOrigC0 = motor6D:GetAttribute("DrumGripOrigC0")

			if not drumGripOrigC0 then
				continue
			end

			motor6D.C0 = drumGripOrigC0
			motor6D:SetAttribute("DrumGripOrigC0", nil)
		end
	end

	p.gripApplied = nil
end

local function stepArmCore(state, p, p2, p3)
	local j = state.J

	if not jointsValid(j) then -- inferred equivalent call
		state.dead = true
		return
	end

	if p then
		p = p.SeatPart
	end

	while state.queue[1] and state.queue[1].Tc <= p2 do
		local prev = table.remove(state.queue, 1)

		if state.prev then
			state.lastGap = math.clamp(prev.Tc - state.prev.Tc, 0.1, 1.5)
		end

		state.prev = prev
	end

	if state.prev and p2 - state.prev.Tc > 6 then
		state.prev = nil
	end

	local lastGap = state.lastGap or 0.4
	local v23 = math.clamp(3 * lastGap, 0.9, 2.5)
	local v24 = state.forceRelease and 0.1 or math.clamp(2 * lastGap, 0.7, 1.3)
	local v25 = state.queue[1]
	local v26

	if v25 == nil then
		if state.prev == nil then
			v26 = false
		else
			v26 = p2 - state.prev.Tc < v23
		end
	else
		v26 = true
	end

	local v27

	if p == nil then
		v27 = false
	else
		v27 = v26 and not state.forceRelease
	end

	if v27 then
		local maxValue = 2.5

		if v25 and state.w < 1 then
			local v28 = math.max(v25.Tc - p2 - 0.1, 0.05)
			maxValue = math.max(maxValue, (1 - state.w) / v28)
		end

		state.w = math.min(1, state.w + p3 * maxValue)
	else
		state.w = math.max(0, state.w - p3 / v24)
	end

	if state.w <= 0.0005 and not v27 then
		if p and state.stickPts and p2 < state.watchUntil then
			collisionOnly(state, p3)
		elseif state.applied then
			restoreArm(state) -- inferred equivalent call
		end
	else
		if not p then
			return
		end

		local v28, lastBase, v29 = computeStroke(state, p2)

		if not lastBase then
			return
		end

		state.lastBase = lastBase
		local v30 = state.queue[1] or state.prev
		state.curReach = v30 and v30.reach or nil

		local lerped = lastBase:Lerp(lastBase * state.lift, v28 * v29 * getTune(j.lt.Parent).Lift)
		local v31 = p.CFrame * lerped

		if (state.gripCur or 0) ~= 0 then
			v31 *= gripShift(state, state.gripCur)
		end

		state.targetW = (v31 * j.wr.C1).Position

		local v32 = j.lt.CFrame * j.waist.C0 * j.waist.Transform * j.waist.C1:Inverse() * j.shC0 * j.sh.Transform * j.sh.C1:Inverse() * j.elC0 * j.el.Transform * j.el.C1:Inverse() * j.wrC0 * j.wr.Transform * j.wr.C1:Inverse()
		local v43 = smoother(state.w) -- inferred equivalent call
		local lerped2 = v32:Lerp(v31, v43)

		if state.stickPts and state.w > 0.02 then
			local v44 = penetration(state, lerped2)

			if v44 > 0.004 then
				lerped2 = CFrame.new(0, math.min(v44, 0.9) + 0.01, 0) * lerped2
			end
		end

		local kind = state.queue[1] and state.queue[1].type or state.prev and state.prev.type
		local tune = getTune(j.lt.Parent)
		local v44 = kind and tune[kind .. "_" .. state.hand .. "_PoleOut"] or 0
		local v45 = kind and tune[kind .. "_" .. state.hand .. "_PoleFwd"] or 0
		local v46 = kind and tune[kind .. "_" .. state.hand .. "_PoleUp"] or 0
		local v47 = tune.ShoulderReach

		if state.curReach then
			v47 = math.max(v47 or 0, state.curReach.shoulder or 0)
		end

		local v48, v49, v50 = solve(j, lerped2, v44, v45, v47, v46)

		if v48 then
			local v51 = smooth(v43 / 0.25) -- inferred equivalent call
			j.sh.C0 = j.shC0:Lerp(v48, v51)
			j.el.C0 = j.elC0:Lerp(v49, v51)
			j.wr.C0 = j.wrC0:Lerp(v50, v51)
			state.applied = true
		end
	end
end

local function liftElbow(j, elbowLift)
	local v23 = j.lt.CFrame * j.waist.C0 * j.waist.Transform * j.waist.C1:Inverse()
	local v24 = v23 * j.sh.C0 * j.sh.Transform * j.sh.C1:Inverse()
	local v25 = v24 * j.el.C0 * j.el.Transform * j.el.C1:Inverse()
	local v26 = v25 * j.wr.C0 * j.wr.Transform * j.wr.C1:Inverse()
	local position = (v23 * j.shC0).Position
	local position2 = (v24 * j.el.C0).Position
	local v27 = (v25 * j.wr.C0).Position - position

	if v27.Magnitude < 0.001 then
		return nil
	end

	local unit3 = v27.Unit
	local vector = position2 - position
	local v28 = unit3 * vector:Dot(unit3)
	local v29 = vector - v28

	if v29.Magnitude < 0.001 then
		return nil
	end

	local v30 = math.abs(elbowLift)
	local v31 = position + v28 + CFrame.fromAxisAngle(unit3, (math.rad(v30))):VectorToWorldSpace(v29)
	local v32 = position + v28 + CFrame.fromAxisAngle(unit3, -math.rad(v30)):VectorToWorldSpace(v29)

	if not (v32.Y > v31.Y) then
		v31, v32 = v32, v31
	end

	v31 = elbowLift >= 0 and v32 or v31
	local v42, v43, v44 = solve(j, v26, 0, 0, 0, 0, v31)

	if v42 then
		return { v42, v43, v44 }
	end

	return nil
end

local function stepArm(state, p, p2, p3)
	local j = state.J
	local tuneApplied = state.tuneApplied

	if tuneApplied and jointsValid(j) then -- inferred equivalent call
		if nearlyEqual(j.sh.C0, tuneApplied.sh) then -- inferred equivalent call
			j.sh.C0 = tuneApplied.preSh
		end

		if nearlyEqual(j.el.C0, tuneApplied.el) then -- inferred equivalent call
			j.el.C0 = tuneApplied.preEl
		end

		if nearlyEqual(j.wr.C0, tuneApplied.wr) then -- inferred equivalent call
			j.wr.C0 = tuneApplied.preWr
		end
	end

	state.tuneApplied = nil

	stepArmCore(state, p, p2, p3)

	if not state.dead and jointsValid(j) then -- inferred equivalent call
		local tune = getTune(j.lt.Parent)
		local tuneType = nil

		if p2 < state.watchUntil and state.clipType then
			tuneType = state.clipType
		elseif state.queue[1] or state.w > 0.0005 then
			local v23 = state.queue[1] or state.prev
			tuneType = v23 and v23.type or state.tuneType
		end

		if tuneType then
			state.tuneType = tuneType
		end

		local tuneCur = state.tuneCur

		if not tuneCur then
			tuneCur = {}
			state.tuneCur = tuneCur
		end

		local v23 = (tuneType or "") .. "_" .. state.hand .. "_"
		local v24 = math.min(1, p3 * 8)
		local v25 = false

		for _, v26 in ipairs(tuneJointFields) do
			local v27 = tuneType and tune[v23 .. v26] or 0
			local v28 = tuneCur[v26] or 0
			local v29

			if v26 == "GripTilt" then
				v29 = math.min(1, p3 * 18)
			elseif v26 == "ElbowLift" then
				v29 = math.min(1, p3 * 14)
			else
				v29 = v24
			end

			local v30 = v28 + (v27 - v28) * v29
			local v31 = v27 == 0 and math.abs(v30) < 0.02 and 0 or v30

			tuneCur[v26] = v31

			if v31 ~= 0 then
				v25 = true
			end
		end

		local gripCur = syncGrip(state, (tune.GripTilt or 0) + (tuneCur.GripTilt or 0))
		state.gripCur = gripCur

		if not v25 and gripCur == 0 then
			return
		end

		local function rot(value, value2, value3) -- 2 equivalent calls inferred from this helper
			return CFrame.Angles(math.rad(value or 0), math.rad(value2 or 0), (math.rad(value3 or 0)))
		end

		local c0 = j.sh.C0
		local c0_2 = j.el.C0
		local c0_3 = j.wr.C0
		local v26 = (tuneCur.ElbowLift or 0) ~= 0 and liftElbow(j, tuneCur.ElbowLift)

		if v26 then
			local sh = j.sh
			local el = j.el
			local wr = j.wr
			local c0_4 = v26[1]
			local c0_5 = v26[2]
			local c0_6 = v26[3]
			sh.C0 = c0_4
			el.C0 = c0_5
			wr.C0 = c0_6
		end

		local sh = j.sh
		sh.C0 = j.sh.C0 * rot(tuneCur.ShoulderX, tuneCur.ShoulderY, tuneCur.ShoulderZ) -- inferred equivalent call
		local el = j.el
		local c0_4 = j.el.C0
		local elbowX = tuneCur.ElbowX
		local elbowY = tuneCur.ElbowY
		el.C0 = c0_4 * CFrame.Angles(math.rad(elbowX or 0), math.rad(elbowY or 0), 0)
		local wr = j.wr
		wr.C0 = j.wr.C0 * rot(tuneCur.WristX, tuneCur.WristY, tuneCur.WristZ) -- inferred equivalent call

		if gripCur ~= 0 then
			local gripIdle = tune.GripIdle or 1
			local v27 = (state.w > 0.0005 or state.queue[1] ~= nil or p2 < state.watchUntil) and 1 or gripIdle

			local gripW = state.gripW or v27
			local gripW2 = gripW + (v27 - gripW) * math.min(1, p3 * (gripW < v27 and 30 or 6))
			state.gripW = gripW2
			local wr2 = j.wr
			wr2.C0 = j.wr.C0 * gripWristDelta(j, gripCur * gripW2) -- inferred equivalent call
		end

		state.tuneApplied = {
			sh = j.sh.C0,
			el = j.el.C0,
			wr = j.wr.C0,
			preSh = c0,
			preEl = c0_2,
			preWr = c0_3
		}
	end
end

local function computeAssist(p, p2, keepAlive)
	local body = p.body

	if not (body and body.bases.waist) then
		return
	end

	local arms = {}

	for _, arm in pairs(p.arms) do
		if arm.targetW and arm.w > 0.02 then
			table.insert(arms, arm)
		end
	end

	if #arms == 0 then
		body.assistPitchTarget = 0
		body.assistYawTarget = 0
		body.assistSpringW = nil
	else
		body.keepAlive = keepAlive
		body.assistSpringW = nil

		for _, v23 in ipairs(arms) do
			if v23.curReach and v23.curReach.springW then
				body.assistSpringW = math.max(body.assistSpringW or 0, v23.curReach.springW)
			end
		end

		local cframe3 = p2.LowerTorso.CFrame
		local waist = body.J.waist
		local v23 = cframe3 * body.bases.waist
		local v24 = {}

		for i, v25 in ipairs(arms) do
			v24[i] = waist.Transform * waist.C1:Inverse() * v25.J.shC0.Position
		end

		local tune = getTune(p2)
		local assistPitch = tune.AssistPitch
		local assistYaw = tune.AssistYaw

		for _, v25 in ipairs(arms) do
			local curReach = v25.curReach

			if not curReach then
				continue
			end

			assistPitch = math.max(assistPitch, curReach.pitch or 0)
			assistYaw = math.max(assistYaw, curReach.yaw or 0)
		end

		local v25 = 1e999
		local assistPitchTarget = 0
		local assistYawTarget = 0

		for _, v26 in ipairs(v21) do
			for _, v27 in ipairs(v22) do
				if assistPitch + 0.001 < v26 then
					continue
				end

				local v28 = math.abs(v27)

				if assistYaw + 0.001 < v28 then
					continue
				end

				local v29 = v23 * CFrame.Angles(-math.rad(v26), -math.rad(v27), 0)
				local total = 0

				for i, v30 in ipairs(arms) do
					local v31 = v29 * v24[i]
					local v32 = v30.curReach and (v30.curReach.shoulder or 0) * 0.85 or 0
					local v44 = ((v30.targetW - v31).Magnitude - v32) / v30.armLength - 0.95

					if v44 > 0 then
						total += 60 * v44 * v30.w
					end
				end

				local v30 = total + 0.25 * v26 + math.abs(v27) * 0.15

				if not (v30 < v25) then
					continue
				end

				assistYawTarget = v27
				assistPitchTarget = v26
				v25 = v30
			end
		end

		body.assistPitchTarget = assistPitchTarget
		body.assistYawTarget = assistYawTarget
	end
end

local function onRenderStep(p)
	local now = os.clock()

	for k, v23 in pairs(object) do
		if k.Parent then
			local humanoid = k:FindFirstChildOfClass("Humanoid")

			if v23.body then
				local success, result = pcall(stepBody, v23.body, humanoid, now, p)

				if success then
					if v23.body.dead then
						v23.body = nil
					end
				else
					warn("[DrumStrokeSolver] body: " .. tostring(result))
					pcall(restoreBody, v23.body)
					v23.body = false
				end
			end

			for _, v24 in ipairs({ "Left", "Right" }) do
				local arm = v23.arms[v24]

				if not arm then
					continue
				end

				local success, result = pcall(stepArm, arm, humanoid, now, p)

				if not success then
					warn("[DrumStrokeSolver] " .. tostring(result))
					pcall(restoreArm, arm)
					arm.queue = {}
					arm.prev = nil
					arm.w = 0
				end

				if arm.dead then
					v23.arms[v24] = nil
				end
			end

			if v23.body then
				local success, result = pcall(computeAssist, v23, k, now)

				if not success then
					warn("[DrumStrokeSolver] assist: " .. tostring(result))
				end
			end
		else
			object[k] = nil
		end
	end
end

local function ensureConnection() -- 5 equivalent calls inferred from this helper
	if not v5 then
		v5 = true

		RunService:BindToRenderStep("DrumStrokeSolver", Enum.RenderPriority.Character.Value + 2, onRenderStep)
	end
end

local function isMasculine(_): boolean
	return true
end

local function kitMatches(p, p2)
	if not p2 then
		return false
	end

	local v23 = object3[p]

	if v23 ~= nil then
		return v23
	end

	local v24 = true

	for k, v25 in pairs(v6) do
		local v26 = p2[k]

		if not v26 or (p.CFrame:PointToObjectSpace(v26) - v25).Magnitude > 0.45 then
			v24 = false
			break
		end
	end

	object3[p] = v24
	return v24
end

local function insertSorted(list, p)
	local v23 = #list + 1

	while v23 > 1 and list[v23 - 1].Tc > p.Tc do
		v23 -= 1
	end

	table.insert(list, v23, p)
end

function DrumStrokeSolver.IsProceduralType(p): boolean
	return v7[p] == true or v8[p] ~= nil or dynamicContactConfig[p] ~= nil
end

function DrumStrokeSolver.BodyHit(instance, p, hand, value, p2, p3, p4)
	if v15[p] and p2 and not toggledOff("DrumBodyMotion") then -- inferred equivalent call
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.SeatPart ~= p2 then
			return
		end

		local now = os.clock()
		local v23 = now + (value or 0)

		if v23 < now - 0.1 then
			return
		end

		local state = getState(instance) -- inferred equivalent call

		if state.body == nil then
			state.body = newBody(instance) or false
		end

		local body = state.body

		if not body then
			return
		end

		local lateral

		if p ~= "Kick" then
			lateral = lateralOf(p2, p3, p) -- inferred equivalent call
		end

		if lateral then
			body.lookHead = math.clamp(lateral * 2.5, -8, 8)
			body.lookTorso = math.clamp(lateral * 1.8, -5.5, 5.5)
			body.lookUntil = math.max(body.lookUntil, v23 + 1)
		end

		local v24 = not toggledOff("DrumBodyCalm") -- inferred equivalent call

		local skip = false
		local v25 = (getTune(instance).SwayMul or 0) > 0

		if v24 and p ~= "Kick" and not v25 then
			if v23 - body.lastImpulseTc < 2 and body.lastImpulseTc <= v23 then
				skip = true
			else
				body.lastImpulseTc = v23
			end
		end

		local v26 = v18[p]
		local v27 = v26 and hand and v26[hand]
		local dampFactor = p4 and v24 and not v27 and 0.2 or v27

		if dampFactor then
			body.dampFactor = dampFactor
			table.insert(body.damps, {
				a = v23 - 0.15,
				b = v23 + 0.35
			})
		end

		insertSorted(body.pending, {
			Tc = v23,
			t = v23,
			type = p,
			hand = hand,
			lateral = lateral,
			skip = skip
		})
		body.lastEvent = math.max(body.lastEvent, v23)
		ensureConnection() -- inferred equivalent call
	end
end

function DrumStrokeSolver.Stroke(instance, p, p2, p3, p4, p5, hold): boolean
	if not (v7[p2] or hold) then
		local v23 = v8[p2] and v8[p2][p]

		if
			not (dynamicContactConfig[p2] and dynamicContactConfig[p2][p])
			and (not v23 or (getTune(instance)[v23] or 0) <= 0)
		then
			return false
		end
	end

	local v23 = v[p2]
	local v24 = v23 and v23[p]
	local reach = dynamicContactConfig[p2] and dynamicContactConfig[p2][p]

	if reach and toggledOff("DrumCrossReach") then -- inferred equivalent call
		reach = nil
	end

	if not (v24 or reach) then
		return false
	end

	if not (not toggledOff("DrumStrokeProcedural") and p3) then -- inferred equivalent call
		return false
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.SeatPart ~= p3 or not kitMatches(p3, p4) then
		return false
	end

	local state = getState(instance) -- inferred equivalent call
	local v25 = state.arms[p]

	if not v25 then
		local armJoints = getArmJoints(instance, p)

		if not armJoints then
			return false
		end

		v25 = newArm(armJoints, p)
		state.arms[p] = v25
	end

	if not v25.stickPts then
		setupCollision(v25, instance, p3)
	end

	if v24 then
		reach = nil
	else
		v24 = buildDynamicContact(v25, p3, p2, reach)

		if not v24 then
			return false
		end
	end

	local now = os.clock()

	local tc = now + (p5 or reach and reach.lead or 0.05)

	if tc < now - 0.1 then
		return true
	end

	insertSorted(v25.queue, {
		Tc = tc,
		base = tunedContact(instance, p2, p, v24),
		type = p2,
		scale = reach and reach.liftScale or v20[p2] or 1,
		reach = reach,
		hold = hold
	})
	v25.forceRelease = false
	ensureConnection() -- inferred equivalent call

	if not hold then
		DrumStrokeSolver.BodyHit(instance, p2, p, p5, p3, p4)
	end

	return true
end

function DrumStrokeSolver.Grab(p, p2, p3, p4, p5, value)
	return DrumStrokeSolver.Stroke(p, p2, p3, p4, p5, 0.12, value or 0.3)
end

DrumStrokeSolver.DynamicContactConfig = dynamicContactConfig
function DrumStrokeSolver.ResetDynamicCache(p)
	local state = getState(p) -- inferred equivalent call

	for _, arm in pairs(state.arms) do
		arm.dynCache = nil
	end
end

function DrumStrokeSolver.Watch(instance, p, p2, p3, clipType)
	if p2 and not toggledOff("DrumStrokeProcedural") then -- inferred equivalent call
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.SeatPart ~= p2 then
			return
		end

		local state = getState(instance) -- inferred equivalent call
		local v23 = state.arms[p]

		if not v23 then
			local armJoints = getArmJoints(instance, p)

			if not armJoints then
				return
			end

			v23 = newArm(armJoints, p)
			state.arms[p] = v23
		end

		if not v23.stickPts then
			setupCollision(v23, instance, p2)
		end

		v23.watchUntil = math.max(v23.watchUntil, os.clock() + p3)
		v23.clipType = clipType
		local v24 = clipType and v9[clipType]
		v23.tap = (v24 and v24[p]) == true
		ensureConnection() -- inferred equivalent call
	end
end

function DrumStrokeSolver.Release(p, p2)
	local v23 = object[p]
	local v24 = v23 and v23.arms[p2]

	if v24 then
		v24.forceRelease = true
		v24.queue = {}
	end
end

function DrumStrokeSolver.Cleanup(p)
	local v23 = object[p]

	if v23 then
		for _, arm in pairs(v23.arms) do
			pcall(restoreArm, arm)
			pcall(restoreGrip, arm)
		end

		if v23.body then
			pcall(restoreBody, v23.body)
		end

		object[p] = nil
	end

	object2[p] = nil
end

function DrumStrokeSolver.EnsureGrip(char)
	local tune = getTune(char)

	if (tune.LegHip or 0) ~= 0 or (tune.LegKnee or 0) ~= 0 or (tune.LegAnkle or 0) ~= 0 then
		local state = getState(char) -- inferred equivalent call

		if state.body == nil then
			state.body = newBody(char) or false
		end

		ensureConnection() -- inferred equivalent call
	end

	if (tune.GripTilt or 0) == 0 then
		return
	end

	local state = getState(char) -- inferred equivalent call

	for _, v23 in ipairs({ "Left", "Right" }) do
		if state.arms[v23] then
			continue
		end

		local armJoints = getArmJoints(char, v23)

		if armJoints then
			state.arms[v23] = newArm(armJoints, v23)
		end
	end

	ensureConnection() -- inferred equivalent call
end

function DrumStrokeSolver.PublishTune(p)
	getTune(p)
end

DrumStrokeSolver.GetTune = getTune

DrumStrokeSolver.TuneFields = tuneFields
DrumStrokeSolver.TuneDefaults = tuneDefaults
DrumStrokeSolver.TuneCombos = tuneCombos
DrumStrokeSolver.TuneTypes = tuneTypes
DrumStrokeSolver.TuneJointFields = tuneJointFields

return DrumStrokeSolver