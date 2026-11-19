local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChartLoader = require(ReplicatedStorage.Modules.ChartLoader)
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local FreePlayVibrato = require(ReplicatedStorage.Modules.FreePlayVibrato)

local LocalPlayer = Players.LocalPlayer

local GuitarAnimator = {}

local v = { GuitarRhythm = true, GuitarLead = true, Bass = true }

local v2 = {
	laneCount = 5,
	fretRange = 0.3,
	pickCenter = 0.035,
	pickSpan = 0.05,
	fpStringCount = 6
}

local v3 = {
	Bass = {
		laneCount = 4,
		fretRange = 0.45,
		pickCenter = 0,
		pickSpan = 0.04,
		chordKind = "slap",
		fpStringCount = 4
	}
}

local function profileFor(p) -- 1 equivalent call inferred from this helper
	local v4 = v3[p]

	if not v4 then
		return v2
	end

	local clone = table.clone(v2)

	for k, v5 in pairs(v4) do
		clone[k] = v5
	end

	return clone
end

local v4 = {
	Mix = { down = 0.12, out = 0 }
}

local v5 = { __mode = "k" }
local object = setmetatable({}, v5)
local object2 = setmetatable({}, v5)
local object3 = setmetatable({}, v5)
local object4 = setmetatable({}, v5)
local object5 = setmetatable({}, v5)
local object6 = setmetatable({}, v5)

local function arcRotation(unit, unit2)
	local v6 = math.clamp(unit:Dot(unit2), -1, 1)

	if v6 > 0.999999 then
		return CFrame.new()
	end

	local cross = unit:Cross(unit2)

	if not (cross.Magnitude < 1e-6) then
		return CFrame.fromAxisAngle(cross.Unit, (math.acos(v6)))
	end

	local v7 = unit:Cross(Vector3.new(0, 1, 0))

	if v7.Magnitude < 0.001 then
		v7 = unit:Cross(Vector3.new(1, 0, 0))
	end

	return CFrame.fromAxisAngle(v7.Unit, 3.141592653589793)
end

local function evalKeyframes(list, now)
	local count = #list

	if count == 0 then
		return 0, 0, 0
	end

	if now <= list[1].t then
		return list[1].x, list[1].w, list[1].tw
	end

	if list[count].t <= now then
		return list[count].x, list[count].w, list[count].tw
	end

	local v6 = 1

	while v6 < count and list[v6 + 1].t <= now do
		v6 += 1
	end

	local item = list[v6]
	local item2 = list[v6 + 1]

	local function tangent(p, p2)
		if p <= 1 or count <= p then
			return 0
		end

		local v7 = list[p].t - list[p - 1].t
		local v8 = list[p + 1].t - list[p].t
		local v9 = (list[p][p2] - list[p - 1][p2]) / v7
		local v10 = (list[p + 1][p2] - list[p][p2]) / v8

		if v9 * v10 <= 0 then
			return 0
		end

		local v11 = 2 * v8 + v7
		local v12 = v8 + 2 * v7
		return (v11 + v12) / (v11 / v9 + v12 / v10)
	end

	local v7 = item2.t - item.t
	local v8 = (now - item.t) / v7
	local v9 = v8 * v8
	local v10 = v9 * v8
	local v11 = 2 * v10 - 3 * v9 + 1
	local v12 = v10 - 2 * v9 + v8
	local v13 = -2 * v10 + 3 * v9
	local v14 = v10 - v9
	local function channel(p) -- 3 equivalent calls inferred from this helper
		return v11 * item[p] + v12 * tangent(v6, p) * v7 + v13 * item2[p] + v14 * tangent(v6 + 1, p) * v7
	end
	return channel("x"), channel("w"), channel("tw") -- inferred equivalent call
end

local function stepSpring(state, p) -- 3 equivalent calls inferred from this helper
	state.v += (-260 * state.x - 16.1245154965971 * state.v) * p
	state.x += state.v * p
end

local function nearlyEqualCF(data, last): boolean -- 3 equivalent calls inferred from this helper
	return (data.Position - last.Position).Magnitude < 0.0001
		and data.RightVector:Dot(last.RightVector) > 0.99999
		and data.UpVector:Dot(last.UpVector) > 0.99999
end

local function applyAdditive(state, p, cframe) -- 2 equivalent calls inferred from this helper
	local base = p.C0

	if state.last and nearlyEqualCF(base, state.last) then -- inferred equivalent call
		base = state.base
	end

	state.base = base
	state.last = base * cframe
	p.C0 = state.last
end

local function releaseAdditive(state, p) -- 6 equivalent calls inferred from this helper
	if state.last then
		if nearlyEqualCF(p.C0, state.last) then -- inferred equivalent call
			p.C0 = state.base
		end

		state.last = nil
		state.base = nil
	end
end

local function applyAdditiveWorld(gripRec, grip, cframe) -- 1 equivalent call inferred from this helper
	local base = grip.C0

	if gripRec.last and nearlyEqualCF(base, gripRec.last) then -- inferred equivalent call
		base = gripRec.base
	end

	gripRec.base = base
	gripRec.last = cframe * base
	grip.C0 = gripRec.last
end

local function buildArm(instance, p)
	local child = instance:FindFirstChild(p .. "UpperArm")
	local child2 = instance:FindFirstChild(p .. "LowerArm")
	local child3 = instance:FindFirstChild(p .. "Hand")

	if not (child and child2 and child3) then
		return nil
	end

	local child4 = child:FindFirstChild(p .. "Shoulder")
	local child5 = child2:FindFirstChild(p .. "Elbow")
	local child6 = child3:FindFirstChild(p .. "Wrist")

	if child4 and child5 and child6 then
		return {
			shoulder = child4,
			elbow = child5,
			wrist = child6,
			C0s = child4.C0,
			C0e = child5.C0,
			C0w = child6.C0,
			modified = false
		}
	end

	return nil
end

local function restoreArm(state) -- 4 equivalent calls inferred from this helper
	if state and state.modified then
		state.shoulder.C0 = state.C0s
		state.elbow.C0 = state.C0e
		state.wrist.C0 = state.C0w
		state.modified = false
	end
end

local function solveArm(state, p, p2, p3, p4)
	local shoulder = state.shoulder
	local elbow = state.elbow
	local wrist = state.wrist
	local v6 = state.C0s * shoulder.Transform * shoulder.C1:Inverse()
	local v7 = v6 * state.C0e * elbow.Transform * elbow.C1:Inverse()
	local v8 = v7 * state.C0w * wrist.Transform * wrist.C1:Inverse()

	local position = state.C0s.Position
	local position2 = (v6 * state.C0e).Position
	local position3 = (v7 * state.C0w).Position
	local magnitude = (position2 - position).Magnitude
	local magnitude2 = (position3 - position2).Magnitude

	local v9 = position3 + p
	local v10 = v9 - position
	local v11 = v10.Magnitude
	local v12 = (magnitude + magnitude2) * 0.995
	local v13 = math.abs(magnitude - magnitude2) + 0.05

	if v12 < v11 then
		v9 = position + v10.Unit * v12
		v11 = v12
	elseif v11 < v13 then
		v9 = position + v10.Unit * v13
		v11 = v13
	end

	local v14 = (v9 - position) / v11
	local v15 = (magnitude * magnitude - magnitude2 * magnitude2 + v11 * v11) / (2 * v11)
	local v16 = math.sqrt((math.max(magnitude * magnitude - v15 * v15, 0)))
	local v17 = position2 - position - v14 * (position2 - position):Dot(v14)
	local v18 = v17.Magnitude < 0.0001 and Vector3.new(0, -1, 0) or v17.Unit

	local v19 = position + v14 * v15 + v18 * v16

	local v20 = arcRotation((position2 - position).Unit, (v19 - position).Unit)
	local v21 = CFrame.new(position) * v20 * CFrame.new(-position)
	local cframe = v21 * v6
	local v22 = v21 * v7
	local v23 = arcRotation((v21 * position3 - v19).Unit, (v9 - v19).Unit)
	local cframe2 = CFrame.new(v19) * v23 * CFrame.new(-v19) * v22

	local v24 = CFrame.new(v9 - position3) * v8

	if p2 and p2 ~= 0 and p3 then
		v24 = CFrame.new(v9) * CFrame.fromAxisAngle(p3, p2) * CFrame.new(-v9) * v24
	end

	if p4 and p4 ~= 0 then
		local v25 = v9 - v19

		if v25.Magnitude > 0.001 then
			local v26 = CFrame.new(v19) * CFrame.fromAxisAngle(v25.Unit, p4) * CFrame.new(-v19)
			cframe2 = v26 * cframe2
			v24 = v26 * v24
		end
	end

	shoulder.C0 = cframe * shoulder.C1 * shoulder.Transform:Inverse()
	elbow.C0 = cframe:Inverse() * cframe2 * elbow.C1 * elbow.Transform:Inverse()
	wrist.C0 = cframe2:Inverse() * v24 * wrist.C1 * wrist.Transform:Inverse()
	state.modified = true

	return position3, v8.Position
end

local function armBaselineWrist(data)
	local shoulder = data.shoulder
	local elbow = data.elbow
	local v6 = data.C0s * shoulder.Transform * shoulder.C1:Inverse() * data.C0e * elbow.Transform * elbow.C1:Inverse()
	return data.C0s.Position, (v6 * data.C0w).Position
end

local function getHeld(instance)
	for k in pairs(v) do
		local child = instance:FindFirstChild(k .. "_Held")

		if child then
			return child, k
		end
	end

	return nil, nil
end

local function computeNeckFrame(state): boolean
	local ut = state.ut
	local held = state.held
	local primaryPart = held.PrimaryPart or held:FindFirstChild("Root")

	if not primaryPart then
		return false
	end

	local inverse = ut.CFrame:Inverse()
	local position = (inverse * primaryPart.CFrame).Position

	local headstock = held:FindFirstChild("Headstock")
	local v6

	if headstock and headstock:IsA("BasePart") then
		v6 = (inverse * headstock.CFrame).Position - position
	end

	if not v6 or v6.Magnitude < 0.1 then
		v6 = (inverse * primaryPart.CFrame).UpVector
	end

	local unit = v6.Unit
	local vector = Vector3.new(0, 0, -1)
	local v7 = vector - unit * vector:Dot(unit)

	if v7.Magnitude < 0.2 then
		v7 = Vector3.new(0, 1, 0) - unit * unit.Y
	end

	local unit2 = v7.Unit
	local unit3 = unit:Cross(unit2).Unit

	if unit3.Y > 0 then
		unit3 = -unit3
	end

	local unit4 = (unit3 * 0.6 + Vector3.new(0, -0.4, 0)).Unit
	state.neckDir = unit
	state.strumDir = unit4
	state.neckNormal = unit2
	local minValue = 1e999
	local pivotAlong = -2.3

	for _, part in ipairs(held:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local v8 = inverse * part.CFrame
		local midpoint = (math.abs((v8.RightVector:Dot(unit))) * part.Size.X + math.abs((v8.UpVector:Dot(unit))) * part.Size.Y + math.abs((v8.LookVector:Dot(unit))) * part.Size.Z) / 2
		minValue = math.min(minValue, (v8.Position - position):Dot(unit) - midpoint)
	end

	if minValue < 1e999 then
		pivotAlong = minValue + 0.15
	end

	state.pivotAlong = pivotAlong
	state.pivot = position + unit * pivotAlong
	local left = state.left
	local shoulder = left.shoulder
	local elbow = left.elbow
	local v8 = left.C0s * shoulder.Transform * shoulder.C1:Inverse() * left.C0e * elbow.Transform * elbow.C1:Inverse()
	local _position = left.C0s.Position
	state.swayR = math.max(0.8, ((v8 * left.C0w).Position - state.pivot):Dot(unit))
	state.frameAt = os.clock()
	return true
end

local v6 = nil
local function leftHandOffsetFor(character)
	local Players2 = game:GetService("Players")
	local playerFromCharacter = Players2:GetPlayerFromCharacter(character)

	if not playerFromCharacter then
		return nil
	end

	if v6 == nil then
		v6 = false
		pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			v6 = require(ReplicatedStorage2:WaitForChild("Modules", 5):WaitForChild("AvatarTypeVerify", 5))
		end)
	end

	if not v6 then
		return nil
	end

	local success, avatarType = pcall(v6.GetAvatarType, playerFromCharacter)
	return success and v4[avatarType] or nil
end

local function leftHandCorrection(data)
	local leftOffset = data.leftOffset
	local v7 = leftOffset and leftOffset.down or 0
	local v8 = leftOffset and leftOffset.out or 0

	if LocalPlayer then
		local guitarLeftDown = LocalPlayer:GetAttribute("GuitarLeftDown")
		local guitarLeftOut = LocalPlayer:GetAttribute("GuitarLeftOut")

		if type(guitarLeftDown) == "number" then
			v7 = guitarLeftDown
		end

		if type(guitarLeftOut) == "number" then
			v8 = guitarLeftOut
		end
	end

	local total = Vector3.new(0, 0, 0)

	if v7 ~= 0 and data.strumDir then
		total += data.strumDir * v7
	end

	if v8 ~= 0 and data.neckNormal then
		total += data.neckNormal * v8
	end

	return total
end

local function ensureState(instance)
	local v7 = object[instance]

	if v7 then
		return v7
	end

	local instrumentType = nil
	local flag = true
	local child

	for k in pairs(v) do
		child = instance:FindFirstChild(k .. "_Held")

		if child then
			instrumentType = k
			flag = false
			break
		end
	end

	if flag then
		child = nil
	end

	if not child then
		return nil
	end

	local upperTorso = instance:FindFirstChild("UpperTorso")

	if not upperTorso then
		return nil
	end

	local arm = buildArm(instance, "Right")
	local arm2 = buildArm(instance, "Left")

	if not (arm and arm2) then
		return nil
	end

	local head = instance:FindFirstChild("Head")
	local instrumentGrip = instance:FindFirstChild("InstrumentGrip", true)

	if instrumentGrip and (not instrumentGrip:IsA("Motor6D") or instrumentGrip.Part0 ~= upperTorso) then
		instrumentGrip = nil
	end

	local v8 = {
		character = instance,
		grip = instrumentGrip,
		gripRec = {},
		root = child.PrimaryPart or child:FindFirstChild("Root"),
		neckPosed = false,
		neck = head and head:FindFirstChild("Neck"),
		waist = upperTorso:FindFirstChild("Waist"),
		neckRec = {},
		waistRec = {},
		headP = { x = 0, v = 0 },
		torsoP = { x = 0, v = 0 },
		torsoR = { x = 0, v = 0 },
		held = child,
		leftOffset = leftHandOffsetFor(instance),
		instrumentType = instrumentType,
		profile = profileFor(instrumentType), -- inferred equivalent call
		ut = upperTorso,
		right = arm,
		left = arm2,
		strokes = {},
		kf = {},
		dirty = false,
		frets = {},
		fretTarget = 0,
		fretPos = 0,
		strumX = 0,
		strumV = 0,
		wristA = 0,
		lookBlend = 0,
		lastPickT = -1000000000,
		offX = 0,
		offW = 0,
		offTw = 0,
		twistA = 0,
		holds = {},
		vibEnv = 0,
		vibWave = 0,
		vibRoll = 0,
		remoteEnv = 0,
		remotePhase = 0,
		isLocal = Players:GetPlayerFromCharacter(instance) == LocalPlayer,
		lastHoldT = -1000000000,
		lastStrokeT = -1000000000
	}

	if not computeNeckFrame(v8) then
		return nil
	end

	object[instance] = v8
	return v8
end

local function restoreState(data)
	restoreArm(data.right) -- inferred equivalent call
	restoreArm(data.left) -- inferred equivalent call

	if data.neck then
		releaseAdditive(data.neckRec, data.neck) -- inferred equivalent call
	end

	if data.waist then
		releaseAdditive(data.waistRec, data.waist) -- inferred equivalent call
	end

	if data.grip then
		releaseAdditive(data.gripRec, data.grip) -- inferred equivalent call
	end
end

local function ampForGap(p) -- 1 equivalent call inferred from this helper
	return math.clamp(p / 0.35, 0.45, 1) * 0.14
end

local function ampFor(kind, p) -- 3 equivalent calls inferred from this helper
	if kind == "pick" then
		return math.clamp(p / 0.25, 0.6, 1) * 0.008
	end

	return ampForGap(p) -- inferred equivalent call
end

local function rebuildKeyframes(state)
	local now = os.clock()
	local v7, v8, v9 = evalKeyframes(state.kf, now)
	local kf = {}
	local function push(p, p2, p3, tw)
		tw = tw or 0
		local v10 = kf[#kf]

		if v10 and p <= v10.t + 0.001 then
			if math.abs(p2 - v10.x) < 0.001 and math.abs(p3 - v10.w) < 0.05 and math.abs(tw - v10.tw) < 0.05 then
				return
			end

			p = v10.t + 0.001
		end

		table.insert(kf, { t = p, x = p2, w = p3, tw = tw })
	end

	local strokes = state.strokes

	for i = 1, #strokes do
		local stroke = strokes[i]
		local stroke2 = strokes[i - 1]
		local stroke3 = strokes[i + 1]
		local v10 = stroke2 and stroke.t - stroke2.t or 1e999

		if stroke.kind == "slap" then
			local v11 = math.min(0.06, v10 * 0.4)

			if v10 >= 0.9 then
				push(stroke.t - v11 - 0.3, 0, 0, 0)
			elseif stroke2 and stroke2.kind ~= "slap" then
				local v12 = stroke2.kind == "pick" and 0.035 or 0.055
				local v13 = math.min(math.clamp(v10 * 0.3, 0.015, v12), v10 * 0.45)
				push(
					stroke2.t + v13,
					stroke2.xc + stroke2.dir * ampFor(stroke2.kind, v10), -- inferred equivalent call
					stroke2.dir * stroke2.wrist,
					0
				)
			end

			push(stroke.t - v11, stroke.xc - 0.03, -6, -22)
			push(stroke.t, stroke.xc, 0, 6)
			local v12 = stroke3 and stroke3.t - stroke.t or 1e999
			local v13 = math.min(0.035, v12 * 0.2)
			local v14 = math.min(0.085, v12 * 0.45)
			push(stroke.t + v13, stroke.xc + 0.012, 8, 16)
			push(stroke.t + v14, stroke.xc - 0.02, -3, -4)

			if v12 >= 0.9 then
				push(stroke.t + v14 + 0.3, 0, 0, 0)
			end
		else
			local v11 = stroke.kind == "pick" and 0.035 or 0.055

			if not (stroke.link and stroke2) then
				if v10 >= 0.9 then
					push(stroke.t - v11 - 0.3, 0, 0)
					push(
						stroke.t - v11,
						stroke.xc - stroke.dir * (stroke.kind == "pick" and 0.008 or 0.14),
						-stroke.dir * stroke.wrist
					)
				else
					local v12 = math.min(math.clamp(v10 * 0.3, 0.015, v11), v10 * 0.45)

					if not stroke2 or stroke2.kind ~= "slap" then
						push(
							stroke2.t + v12,
							stroke2.xc + stroke2.dir * ampFor(stroke2.kind, v10), -- inferred equivalent call
							stroke2.dir * stroke2.wrist
						)
					end

					push(stroke.t - v12, stroke.xc - stroke.dir * ampFor(stroke.kind, v10), -stroke.dir * stroke.wrist) -- inferred equivalent call
				end
			end

			push(stroke.t, stroke.xc, 0)

			if not (stroke3 and stroke3.link) and (not stroke3 or stroke3.t - stroke.t >= 0.9) then
				push(
					stroke.t + v11,
					stroke.xc + stroke.dir * (stroke.kind == "pick" and 0.008 or 0.14),
					stroke.dir * stroke.wrist
				)
				push(stroke.t + v11 + 0.3, 0, 0)
			end
		end
	end

	state.kf = kf
	state.dirty = false

	local v10, v11, v12 = evalKeyframes(kf, now)
	state.offX += v7 - v10
	state.offW += v8 - v11
	state.offTw += v9 - v12
end

local function laneCountOf(p) -- 2 equivalent calls inferred from this helper
	local v7 = object[p]
	return v7 and v7.profile.laneCount or 5
end

local function fretFractionFor(p, p2) -- 1 equivalent call inferred from this helper
	if not p2 then
		return 0
	end

	if not object5[p] then
		return (math.clamp((p2 - 1) % 13 / 12, 0, 1))
	end

	local v7 = p2 - 1
	return (math.clamp(v7 / (laneCountOf(p) - 1), 0, 1)) -- inferred equivalent call
end

local function stringPosition(p, p2) -- 1 equivalent call inferred from this helper
	if p2 and object5[p] then
		local v7 = p2 - 1
		return (math.clamp(v7 / (laneCountOf(p) - 1), 0, 1)) -- inferred equivalent call
	end

	return 0.5
end

local function scheduleStroke(character, lane, p, p2, p3, p4, p5)
	local state = ensureState(character)

	if not state then
		return
	end

	local now = os.clock()
	local from = now + p
	local strokes = state.strokes
	local stroke = strokes[#strokes]

	if p3 == "chart" and stroke and stroke.reactive and math.abs(from - stroke.t) < 0.14 then
		return
	end

	if stroke and from <= stroke.t + 0.025 then
		if stroke.kind == "pick" then
			stroke.kind = state.profile.chordKind or "strum"

			if stroke.kind == "strum" then
				stroke.xc = -0.08
				stroke.wrist = 14
			else
				stroke.wrist = 0
			end

			stroke.link = false
			state.dirty = true
		end
	else
		local chordKind = p2 and p2 >= 2 and (state.profile.chordKind or "strum") or "pick"

		if chordKind == "strum" or chordKind == "slap" then
			local v7 = from - 0.05

			if now < v7 and (not stroke or stroke.t + 0.03 < v7) then
				from = v7
			end
		end

		local v7 = stroke and from - stroke.t or 1e999

		local dir = not (stroke and v7 < 0.9) and 1 or -stroke.dir

		local link = false

		if
			chordKind == "pick"
			and stroke
			and stroke.kind == "pick"
			and v7 < 0.2
			and lane
			and stroke.lane
			and lane ~= stroke.lane
			and (object5[character] or p5 ~= nil)
		then
			local dir2 = stroke.lane < lane and 1 or -1

			if stroke.link then
				if stroke.dir == dir2 then
					dir = dir2
					link = true
				end
			else
				local t = stroke.t

				if now + 0.005 < t then
					stroke.dir = dir2
					dir = dir2
					link = true
				end
			end
		end

		local v8 = p5 and p5.stringPos or stringPosition(character, lane) -- inferred equivalent call
		local xc, wrist, frac

		if chordKind == "slap" then
			xc = state.profile.pickCenter + (v8 - 0.5) * state.profile.pickSpan

			state.lastPickT = math.max(state.lastPickT, from)
			wrist = 0
			frac = 0.8
		elseif chordKind == "pick" then
			xc = state.profile.pickCenter + (v8 - 0.5) * state.profile.pickSpan

			frac = math.clamp(v7 / 0.25, 0.6, 1) * 0.08
			state.lastPickT = math.max(state.lastPickT, from)
			wrist = 4
		else
			frac = math.clamp(v7 / 0.35, 0.45, 1)
			xc = -0.08
			wrist = 14
		end

		table.insert(strokes, {
			t = from,
			dir = dir,
			kind = chordKind,
			lane = lane,
			xc = xc,
			wrist = wrist,
			link = link,
			frac = frac,
			fired = false,
			reactive = p3 ~= "chart"
		})

		state.dirty = true
		local frets = state.frets
		local v9 = {
			t = from - 0.06,
			frac = p5 and p5.fretFrac or fretFractionFor(character, lane) -- inferred equivalent call
		}
		table.insert(frets, v9)

		if p4 and p4 >= 0.3 then
			table.insert(state.holds, {
				from = from,
				to = from + p4
			})
		end
	end
end

local function readVibrato(state, p)
	if state.isLocal then
		local localWave, v7 = FreePlayVibrato.GetLocalWave()
		return localWave, v7
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(state.character)
	local v7

	if playerFromCharacter == nil then
		v7 = false
	else
		v7 = playerFromCharacter:GetAttribute("FPVibActive") == true
	end

	local v8 = playerFromCharacter and playerFromCharacter:GetAttribute("FPVibRate")

	if typeof(v8) ~= "number" then
		v8 = FreePlayVibrato.DEFAULT_RATE
	end

	local fpVibDepth = playerFromCharacter and playerFromCharacter:GetAttribute("FPVibDepth")
	local v9 = typeof(fpVibDepth) == "number" and math.clamp(fpVibDepth, 0.3, 1.2) or 1

	if v7 then
		state.remoteEnv = math.min(1, state.remoteEnv + p / 0.25)
	else
		state.remoteEnv = math.max(0, state.remoteEnv - p / 0.18)
	end

	state.remotePhase = (state.remotePhase + p * 2 * 3.141592653589793 * v8) % 6.283185307179586
	local remoteEnv = state.remoteEnv
	return remoteEnv * remoteEnv * (3 - 2 * remoteEnv) * v9, state.remotePhase
end

local function updateState(state, p)
	local now = os.clock()

	if now - state.frameAt > 1 and not state.neckPosed then
		computeNeckFrame(state)
	end

	local strokes = state.strokes

	while #strokes > 0 and strokes[1].t < now - 1.5 do
		table.remove(strokes, 1)
		state.dirty = true
	end

	if #strokes > 0 then
		state.lastStrokeT = strokes[#strokes].t
	end

	if state.dirty then
		rebuildKeyframes(state)
	end

	local frets = state.frets

	while #frets > 0 and frets[1].t <= now do
		state.fretTarget = frets[1].frac * state.profile.fretRange
		table.remove(frets, 1)
	end

	local holds = state.holds
	local from = nil

	for i = #holds, 1, -1 do
		local hold = holds[i]

		if hold.to < now - 0.5 then
			table.remove(holds, i)
		elseif hold.from <= now and now < hold.to then
			from = hold.from
		end
	end

	if from then
		state.lastHoldT = now
	end

	if now - state.lastStrokeT > 0.9 and now - state.lastHoldT > 0.25 and #frets == 0 then
		state.fretTarget = 0
	end

	local v7 = now - state.lastPickT < 0.5 and 20 or 9
	state.fretPos += (state.fretTarget - state.fretPos) * (1 - math.exp(-p * v7))
	local v8, v9

	if LocalPlayer and LocalPlayer:GetAttribute("GuitarVibrato") == false then
		v8 = 0
		v9 = 0
	else
		v8, v9 = readVibrato(state, p)
	end

	local vibEnv = v8 < 0.001 and 0 or v8

	state.vibEnv = vibEnv
	state.vibWave = vibEnv * math.sin(v9)
	state.vibRoll = vibEnv * math.sin(v9 + 0.6)

	local v10, v11, v12 = evalKeyframes(state.kf, now)
	local v13 = v10 + state.offX
	local v14 = v11 + state.offW
	local v15 = v12 + state.offTw
	local v16 = math.exp(-p * 14)
	state.offX *= v16
	state.offW *= v16
	state.offTw *= v16
	local strumX = state.strumX
	local v17 = 1 - math.exp(-p * 90)
	state.strumX += (v13 - state.strumX) * v17
	state.wristA += (v14 - state.wristA) * v17
	state.twistA += (v15 - state.twistA) * v17
	local v18 = p > 0 and (state.strumX - strumX) / p or 0
	state.strumV += (v18 - state.strumV) * (1 - math.exp(-p * 30))

	local v19 = not LocalPlayer or LocalPlayer:GetAttribute("GuitarBodyMotion") ~= false

	for _, stroke in ipairs(strokes) do
		local v20 = stroke.t - ((stroke.kind == "strum" or stroke.kind == "slap") and 0.01 or 0)

		if stroke.fired or not (v20 <= now) then
			continue
		end

		stroke.fired = true

		if not v19 then
			continue
		end

		local v21 = 27.411676344215067 * stroke.frac
		state.headP.v -= 0.041887902047863905 * v21
		state.torsoP.v -= 0.024434609527920613 * v21
		state.torsoR.v += stroke.dir * 0.013962634015954637 * v21
	end

	local v20 = math.min(p, 1 / 30)
	stepSpring(state.headP, v20) -- inferred equivalent call
	stepSpring(state.torsoP, v20) -- inferred equivalent call
	stepSpring(state.torsoR, v20) -- inferred equivalent call
	local v21 = math.abs(state.headP.x) + math.abs(state.torsoP.x) + math.abs(state.torsoR.x) + (math.abs(state.headP.v) + math.abs(state.torsoP.v) + math.abs(state.torsoR.v)) * 0.05

	local v22 = now - state.lastPickT < 0.7 and 1 or 0
	state.lookBlend += (v22 - state.lookBlend) * (1 - math.exp(-p * 5))

	if v19 and (v21 > 0.0002 or state.lookBlend > 0.001) then
		if state.neck then
			local lookBlend = state.lookBlend

			applyAdditive( -- inferred equivalent call
				state.neckRec,
				state.neck,
				CFrame.Angles(state.headP.x - 0.03490658503988659 * lookBlend, -0.026179938779914945 * lookBlend, 0)
			)
		end

		if state.waist then
			applyAdditive(state.waistRec, state.waist, CFrame.Angles(state.torsoP.x, 0, state.torsoR.x)) -- inferred equivalent call
		end
	else
		if state.neck then
			releaseAdditive(state.neckRec, state.neck) -- inferred equivalent call
		end

		if state.waist then
			releaseAdditive(state.waistRec, state.waist) -- inferred equivalent call
		end
	end

	local v23 = LocalPlayer and LocalPlayer:GetAttribute("GuitarSway") == false
	state.swayHandDelta = Vector3.new(0, 0, 0)

	if v23 or not (state.vibEnv > 0.001 and state.grip) then
		if state.neckPosed then
			if state.grip then
				releaseAdditive(state.gripRec, state.grip) -- inferred equivalent call
			end

			state.neckPosed = false
		end
	else
		local cross = state.neckDir:Cross(state.strumDir)

		if cross.Magnitude > 0.001 then
			local unit = cross.Unit

			local v24 = math.clamp(1 * (0.03 * state.vibWave) / state.swayR, -0.06981317007977318, 0.06981317007977318)

			local v25 = math.clamp(
				0.45 * (0.03 * state.vibRoll) / state.swayR,
				-0.06981317007977318,
				0.06981317007977318
			)
			local cframe = CFrame.new(state.pivot) * CFrame.fromAxisAngle(unit, v24) * CFrame.fromAxisAngle(state.strumDir, v25) * CFrame.new(-state.pivot)
			applyAdditiveWorld(state.gripRec, state.grip, cframe) -- inferred equivalent call
			state.neckPosed = true
			local left = state.left
			local shoulder = left.shoulder
			local elbow = left.elbow
			local v26 = left.C0s * shoulder.Transform * shoulder.C1:Inverse() * left.C0e * elbow.Transform * elbow.C1:Inverse()
			local _position = left.C0s.Position
			local v27 = (v26 * left.C0w).Position - state.neckDir * state.fretPos
			state.swayHandDelta = cframe:PointToWorldSpace(v27) - v27
		end
	end

	local v24

	if #strokes == 0 and math.abs(state.strumX) < 0.001 and state.fretPos < 0.001 and state.vibEnv < 0.001 then
		v24 = math.abs(state.twistA) < 0.05
	else
		v24 = false
	end

	if v24 then
		restoreArm(state.right) -- inferred equivalent call
		local v25 = leftHandCorrection(state)

		if v25.Magnitude > 0.00001 then
			solveArm(state.left, v25, 0, state.neckDir)
			return
		end

		restoreArm(state.left) -- inferred equivalent call
	else
		local wristA = math.rad(state.wristA)
		local v25 = state.strumDir * state.strumX
		local v26, v27 = solveArm(state.right, v25, 0, nil, math.rad(state.twistA))

		if math.abs(wristA) > 0.0001 and v26 then
			local v28 = v27 - v26

			if v28.Magnitude > 0.001 then
				local cross = v28.Unit:Cross(state.strumDir)

				if cross.Magnitude > 0.001 then
					local unit = cross.Unit

					local v29 = v28 * 2
					local vector = CFrame.fromAxisAngle(unit, wristA):VectorToWorldSpace(v29) - v29
					local v30 = vector - state.strumDir * vector:Dot(state.strumDir)
					solveArm(state.right, v25 - v30, wristA, unit, math.rad(state.twistA))
				end
			end
		end

		local v28 = -state.neckDir * state.fretPos
		local v29

		if state.vibEnv > 0.001 then
			if state.neckPosed then
				v28 += state.swayHandDelta
			else
				v28 += state.strumDir * (0.03 * state.vibWave)
			end

			v29 = 0.03490658503988659 * state.vibRoll
		else
			v29 = 0
		end

		local v30 = v28 + leftHandCorrection(state)
		solveArm(state.left, v30, v29, state.neckDir)
	end
end

local flag = false
local function onRenderStep(p)
	local v7 = LocalPlayer and LocalPlayer:GetAttribute("GuitarProcedural") == false

	for k, v8 in pairs(object) do
		if v7 or not (k.Parent and v8.held.Parent and v8.ut.Parent) then
			restoreState(v8)
			object[k] = nil
		else
			updateState(v8, p)
		end
	end
end

local function connectStep()
	if flag then
		return
	end

	flag = true

	pcall(function()
		RunService:UnbindFromRenderStep("GuitarAnimator")
	end)
	RunService:BindToRenderStep("GuitarAnimator", Enum.RenderPriority.Character.Value + 2, onRenderStep)
end

if not flag then
	flag = true

	pcall(function()
		RunService:UnbindFromRenderStep("GuitarAnimator")
	end)
	RunService:BindToRenderStep("GuitarAnimator", Enum.RenderPriority.Character.Value + 2, onRenderStep)
end

local function computeExpectedSongElapsed(instance) -- 1 equivalent call inferred from this helper
	local canonicalElapsed = instance:GetAttribute("CanonicalElapsed")
	local canonicalElapsedAt = instance:GetAttribute("CanonicalElapsedAt")

	if canonicalElapsed and canonicalElapsedAt then
		return canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
	end

	return nil
end

local function computeChartElapsed(data, p)
	local v7

	if p then
		if not data.IsPlaying then
			return nil
		end

		v7 = data.TimePosition

		return (data.Parent and data.Parent:GetAttribute("SegmentOffset") or 0) + v7 + SettingsState.GetAudioOffsetMs() / 1000
	end

	v7 = computeExpectedSongElapsed(data) -- inferred equivalent call

	if v7 then
		return (data.Parent and data.Parent:GetAttribute("SegmentOffset") or 0) + v7 + SettingsState.GetAudioOffsetMs() / 1000
	end

	return nil
end

local function getVocalistVisualOffset(instance)
	if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
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

local function findAmpSound(instance, p, p2)
	local child = instance:FindFirstChild(p2 .. "_Held")
	local primaryPart = child and (child.PrimaryPart or child:FindFirstChild("Root"))
	local instrumentCableVisual = primaryPart and primaryPart:FindFirstChild("InstrumentCableVisual")
	local attachment0 = instrumentCableVisual and instrumentCableVisual.Attachment0
	local parent = attachment0 and attachment0.Parent and attachment0.Parent.Parent
	local partSoundAnchor = parent and parent:FindFirstChild("PartSoundAnchor")
	return partSoundAnchor and partSoundAnchor:FindFirstChild(p .. "_" .. p2)
end

local function getSyncOffset(p, p2) -- 1 equivalent call inferred from this helper
	local song = SongConfig.Songs[p]

	if song then
		return (song.Offset or 0) + (song.InstrumentOffsets and song.InstrumentOffsets[p2] or 0)
	end

	return 0
end

local function firstNoteIndexAfter(clone, p)
	local v7 = #clone + 1
	local v8 = 1

	while v8 < v7 do
		local v9 = (v8 + v7) // 2

		if p < clone[v9].Time then
			v7 = v9
		else
			v8 = v9 + 1
		end
	end

	return v8
end

local function isGateOpen(p): boolean -- 3 equivalent calls inferred from this helper
	return os.clock() - (object4[p] or -1000000000) < 3
end

function GuitarAnimator.SetIdleActive(character, p)
	if p and character then
		ensureState(character)
	end
end

function GuitarAnimator.SetChartSyncActive(instance, p, p2)
	object2[instance] = (object2[instance] or 0) + 1
	local v7 = object2[instance]
	object3[instance] = nil
	object5[instance] = p and true or nil
	object4[instance] = nil

	local v8 = object[instance]

	if v8 then
		v8.strokes = {}
		v8.frets = {}
		v8.dirty = true
	end

	if not (p and p2 and instance) then
		return
	end

	local flag2 = true
	local child, v9

	for k in pairs(v) do
		child = instance:FindFirstChild(k .. "_Held")

		if child then
			v9 = k
			flag2 = false
			break
		end
	end

	if flag2 then
		child = nil
	end

	if not child then
		return
	end

	local chart = ChartLoader.GetChart(p2, v9)

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
	local syncOffset = getSyncOffset(p2, v9) -- inferred equivalent call
	task.spawn(function()
		local v10 = findAmpSound(instance, p2, v9)
		local total = 0

		while not v10 and total < 5 and object2[instance] == v7 do
			task.wait(0.1)
			total += 0.1
			v10 = findAmpSound(instance, p2, v9)
		end

		if not v10 or object2[instance] ~= v7 then
			return
		end

		object3[instance] = v7
		local v11 = Players:GetPlayerFromCharacter(instance) == LocalPlayer
		local v12 = 1
		local v13 = 0

		while object2[instance] == v7 and v12 <= #clone do
			local v14, v15, parent, v16, vocalistVisualOffset, v17, v18, v19, v20, v21, v22

			if v10.Parent then
				v14 = computeChartElapsed(v10, v11)

				if v14 then
					if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
						v15 = 0
					else
						parent = v10.Parent
						v16 = parent and parent:FindFirstChild(v10.Name .. "_VocalistMirror")
						vocalistVisualOffset = v16 and v16:GetAttribute("VocalistVisualOffset")
						v15 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
					end

					if math.abs(v15 - v13) >= 0.15 then
						v12 = firstNoteIndexAfter(clone, v14 + syncOffset + v15)
						v13 = v15
					else
						v17 = v14 + syncOffset + v15

						while v12 <= #clone and clone[v12].Time - 1.2 <= v17 do
							v18 = clone[v12]

							v19 = v12 + 1
							v20 = 1

							while clone[v19] and clone[v19].Time - v18.Time <= 0.025 do
								v20 += 1
								v19 += 1
							end

							v21 = v18.Time - v17

							if v21 <= -0.12 or object6[instance] then
								v12 = v19
							else
								v22 = instance

								if isGateOpen(v22) then -- inferred equivalent call
									scheduleStroke(instance, v18.Lane, v21, v20, "chart", v18.Duration)
									v12 = v19
								else
									break
								end
							end
						end

						task.wait(0.03)
					end
				else
					task.wait(0.05)
				end
			else
				v10 = findAmpSound(instance, p2, v9)

				if v10 then
					v14 = computeChartElapsed(v10, v11)

					if v14 then
						if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
							v15 = 0
						else
							parent = v10.Parent
							v16 = parent and parent:FindFirstChild(v10.Name .. "_VocalistMirror")
							vocalistVisualOffset = v16 and v16:GetAttribute("VocalistVisualOffset")
							v15 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
						end

						if math.abs(v15 - v13) >= 0.15 then
							v12 = firstNoteIndexAfter(clone, v14 + syncOffset + v15)
							v13 = v15
						else
							v17 = v14 + syncOffset + v15

							while v12 <= #clone and clone[v12].Time - 1.2 <= v17 do
								v18 = clone[v12]

								v19 = v12 + 1
								v20 = 1

								while clone[v19] and clone[v19].Time - v18.Time <= 0.025 do
									v20 += 1
									v19 += 1
								end

								v21 = v18.Time - v17

								if v21 <= -0.12 or object6[instance] then
									v12 = v19
								else
									v22 = instance

									if isGateOpen(v22) then -- inferred equivalent call
										scheduleStroke(instance, v18.Lane, v21, v20, "chart", v18.Duration)
										v12 = v19
									else
										break
									end
								end
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
		end
	end)
end

function GuitarAnimator.Handle(player, p)
	local character = player and player.Character

	if not character or typeof(p) ~= "table" or object6[character] then
		return
	end

	local eventType = p.EventType

	if eventType == "HoldEnd" then
		local v7 = object[character]

		if v7 then
			local now = os.clock()

			for _, hold in ipairs(v7.holds) do
				if hold.from <= now and now < hold.to then
					hold.to = now
				end
			end
		end
	else
		if eventType ~= "Hit" and eventType ~= "HoldStart" then
			return
		end

		local v7 = eventType == "HoldStart"
			and (object3[character] == nil or object3[character] ~= object2[character])
			and ensureState(character)

		if v7 then
			local now = os.clock()
			table.insert(v7.holds, {
				from = now,
				to = now + 20
			})
		end

		local gateOpen = isGateOpen(character) -- inferred equivalent call
		object4[character] = os.clock()

		if object3[character] ~= nil and object3[character] == object2[character] and gateOpen then
			return
		end

		local noteData = p.NoteData
		local chartLane = noteData and noteData.ChartLane
		scheduleStroke(character, chartLane, 0.02)
	end
end

local function endHoldsByKey(p, p2, now)
	for _, hold in ipairs(p.holds) do
		if hold.key == p2 and now < hold.to then
			hold.to = now
		end
	end
end

function GuitarAnimator.PlayFreePlayNote(player, value, value2, p, p2)
	local character = player and player.Character

	if not character or type(value) ~= "number" or type(value2) ~= "number" then
		return
	end

	local state = ensureState(character)

	if not state then
		return
	end

	local fpStringCount = state.profile.fpStringCount or 6
	local lane = math.clamp(fpStringCount - math.floor(value + 0.5) + 1, 1, fpStringCount)
	scheduleStroke(character, lane, 0.02, 1, "freeplay", nil, {
		stringPos = (lane - 1) / math.max(fpStringCount - 1, 1),
		fretFrac = math.clamp(value2 / 12, 0, 1)
	})
	local now = os.clock()

	if p == nil then
		if p2 and p2 > 0 then
			table.insert(state.holds, {
				from = now,
				to = now + p2
			})
		end
	else
		endHoldsByKey(state, p, now)
		table.insert(state.holds, {
			from = now,
			to = now + 20,
			key = p
		})
	end
end

function GuitarAnimator.ReleaseFreePlayNote(player, p)
	local character = player and player.Character
	local v7 = character and object[character]

	if v7 and p ~= nil then
		endHoldsByKey(v7, p, os.clock())
	end
end

function GuitarAnimator.SetFreePlayMode(character, p)
	if not character then
		return
	end

	local v7 = p == true

	if (object6[character] == true) == v7 then
		return
	end

	object6[character] = v7 or nil
	local v8 = object[character]

	if v8 then
		v8.strokes = {}
		v8.frets = {}
		v8.holds = {}
		v8.dirty = true
	end

	if v7 then
		ensureState(character)
	end
end

function GuitarAnimator.DebugSchedule(p, list)
	object5[p] = true

	for _, item in ipairs(list) do
		scheduleStroke(p, item.lane, item.t, item.chord or 1, "chart", item.duration)
	end
end

function GuitarAnimator.DebugSetRemote(character, p)
	local state = ensureState(character)

	if state then
		state.isLocal = not p
	end
end

function GuitarAnimator.Cleanup(p)
	local v7 = object[p]

	if v7 then
		restoreState(v7)
		object[p] = nil
	end
end

return GuitarAnimator