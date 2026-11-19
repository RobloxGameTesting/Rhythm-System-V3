local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BandCamera = Modules:WaitForChild("BandCamera")
local BandCameraConfig = require(BandCamera:WaitForChild("BandCameraConfig"))
require(BandCamera:WaitForChild("BandCameraSongConfig"))
local ChartActivity = require(BandCamera:WaitForChild("ChartActivity"))
local BandCameraDirector = require(BandCamera:WaitForChild("BandCameraDirector"))
local BandCameraRig = require(BandCamera:WaitForChild("BandCameraRig"))
local BandCameraPlayback = require(BandCamera:WaitForChild("BandCameraPlayback"))
local BandCameraCues = require(BandCamera:WaitForChild("BandCameraCues"))
local BandCameraStyle = require(BandCamera:WaitForChild("BandCameraStyle"))
local BandCameraFocus = require(BandCamera:WaitForChild("BandCameraFocus"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local WatchingBandState = RemoteEvents:WaitForChild("WatchingBandState")

local LocalPlayer = Players.LocalPlayer

local v = { t0 = 0, shot = "Wide", dir = 1, pick = 0.5 }
local v2 = LocalPlayer.UserId % 997 / 10

local BandCameraController = {}

local flag = false
local currentCamera = nil

local v3 = {}
local v4 = nil
local v5 = false

local playerOn = false
local inZone = false
local flag2 = false
local v6 = false
local v7 = {}
local v8 = nil
local flag3 = false
local flag4 = false
local v9 = false
local v10 = os.clock()
local v11 = nil
local v12 = nil
local intensity = BandCameraConfig.DefaultIntensity

local v13 = false
local v14 = false
local v15 = false
local v16 = false

local flag5 = false
local v17 = nil
local v18 = 0
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = nil
local v28 = nil
local v29 = nil

local v30 = {}
local flag6 = false

local fn

BandCameraFocus.OnChanged(function()
	if fn then
		fn()
	end
end)

local v31 = false
local function reportWatchState() -- 4 equivalent calls inferred from this helper
	local v32 = flag3 and flag5 and v17 ~= "out"

	if v32 ~= v31 then
		v31 = v32
		WatchingBandState:FireServer(v32)
	end
end

local function notify()
	reportWatchState() -- inferred equivalent call

	for _, callback in ipairs(v30) do
		local success, result = pcall(callback)

		if not success then
			warn("[BandCameraController] listener error:", result)
		end
	end
end

function BandCameraController.OnChanged(p)
	table.insert(v30, p)
end

function BandCameraController.OnAutoStarted(p)
	table.insert(v7, p)
end

local function fireAutoStarted(p)
	for _, callback in ipairs(v7) do
		local success, result = pcall(callback, p)

		if not success then
			warn("[BandCameraController] auto listener error:", result)
		end
	end
end

local function getHumanoid() -- 4 equivalent calls inferred from this helper
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot() -- 7 equivalent calls inferred from this helper
	local character = LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function decodeTarget(camTarget)
	if type(camTarget) ~= "string" or camTarget == "" then
		return nil
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, camTarget)

	if not success or type(result) ~= "table" then
		return nil
	end

	if
		type(result.session) == "string"
		and type(result.song) == "string"
		and type(result.startAt) == "number"
		and type(result.duration) == "number"
		and type(result.roster) == "table"
	then
		return result
	end

	return nil
end

local function anyTarget(): boolean -- 1 equivalent call inferred from this helper
	for _, v32 in pairs(v3) do
		if v32.target then
			return true
		end
	end

	return false
end

local function inSession(): boolean -- 8 equivalent calls inferred from this helper
	if not (v5 and v4) then
		return false
	end

	local v32 = v3[v4]
	return v32 ~= nil and v32.folder:GetAttribute("LightSession") ~= nil
end

local function desiredStage()
	local v32 = nil

	if flag3 then
		v32 = v11
	elseif playerOn and inSession() and inZone then -- inferred equivalent call
		v32 = v4
	end

	if not v32 then
		return nil
	end

	local v35 = v3[v32]

	if v35 and v35.target then
		return v32, v35
	end

	return nil
end

local function isSuspended(): boolean -- 1 equivalent call inferred from this helper
	if v14 or v13 or v16 or SessionCameraSettings.GetIsMenuOpen() then
		return true
	end

	local humanoid = getHumanoid() -- inferred equivalent call
	return not humanoid or humanoid.Health <= 0
end

local function eligibleOf(roster)
	local result = {}
	local v32 = {}

	for k, item in pairs(roster) do
		if not (type(item) == "string" and item ~= "Admin") then
			continue
		end

		result[k] = true
		v32[#v32 + 1] = k
	end

	table.sort(v32)
	return result, table.concat(v32, ",")
end

local function focusList(p)
	if not flag3 then
		return nil
	end

	local v32 = {}

	for _, v35 in ipairs(BandCameraFocus.GetInstruments()) do
		if p.eligible and p.eligible[v35] then
			v32[#v32 + 1] = v35
		end
	end

	return #v32 > 0 and v32 or nil
end

local function rebuildTimeline(state)
	if state and state.analysisReady then
		local v32 = focusList(state)
		state.focusKey = v32 and table.concat(v32, ",") or ""
		local v35

		if v32 then
			v35 = BandCameraDirector.BuildFocus(
				state.target.song,
				state.target.duration,
				state.sessionId,
				state.analysis,
				v32,
				state.eligible
			)
		end

		state.timeline = v35
			or BandCameraDirector.Build(
				state.target.song,
				state.target.duration,
				state.sessionId,
				state.analysis,
				BandCameraCues.Get(state.target.song),
				state.eligible
			)
	end
end

local function syncFocus(p) -- 1 equivalent call inferred from this helper
	if not (p and p.analysisReady) then
		return
	end

	local v32 = focusList(p)

	if (v32 and table.concat(v32, ",") or "") ~= p.focusKey then
		rebuildTimeline(p)
		v25 = nil
	end
end

local function setContext(stageId, state)
	if not state.rig then
		state.rig = BandCameraRig.new(state.folder)
	end

	local v32 = {
		stageId = stageId,
		sessionId = state.target.session,
		target = state.target,
		rig = state.rig,
		timeline = nil,
		analysisReady = false
	}

	local eligible, eligibleKey = eligibleOf(state.target.roster)
	v32.eligible = eligible
	v32.eligibleKey = eligibleKey
	local studioCenter = state.folder:FindFirstChild("StudioCenter")
	v32.ref = studioCenter and studioCenter:IsA("Attachment") and studioCenter.WorldCFrame or CFrame.new()
	v32.clips = BandCameraPlayback.GetClips(state.target.song, stageId)
	v19 = v32
	BandCameraStyle.SetSong(v32.target.song)
	ChartActivity.Request(v32.target.song, function(analysis)
		if v19 ~= v32 then
			return
		end

		v32.analysis = analysis
		v32.kicks = analysis.kicks
		v32.analysisReady = true
		rebuildTimeline(v32)
	end)
end

local fn2

local v32 = {
	Hat = true,
	Hair = true,
	Face = true,
	Eyebrow = true,
	Eyelash = true
}
local v35 = { char = nil, saved = {}, scanAt = 0, lastApply = 0 }

local function isHeadAccessory(accessory, head)
	if not accessory:IsA("Accessory") then
		return false
	end

	local handle = accessory:FindFirstChild("Handle")

	if handle and head then
		for _, child in ipairs(handle:GetChildren()) do
			if
				(child:IsA("JointInstance") or child:IsA("WeldConstraint"))
				and (child.Part0 == head or child.Part1 == head)
			then
				return true
			end
		end
	end

	local success, result = pcall(function()
		return accessory.AccessoryType.Name
	end)

	return success and v32[result] == true
end

local function restoreHeadHide()
	for k, localTransparencyModifier in pairs(v35.saved) do
		if k.Parent then
			k.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	v35.saved = {}
	v35.char = nil
end

local function setHeadHide(char) -- 3 equivalent calls inferred from this helper
	if v35.char ~= char then
		restoreHeadHide()
		v35.char = char
		v35.scanAt = 0
	end

	if not char then
		return
	end

	local now = os.clock()
	v35.lastApply = now

	if v35.scanAt <= now then
		v35.scanAt = now + 0.25
		local head = char:FindFirstChild("Head")

		for _, folder in ipairs(char:GetChildren()) do
			if not isHeadAccessory(folder, head) then
				continue
			end

			for _, part in ipairs(folder:GetDescendants()) do
				if part:IsA("BasePart") and v35.saved[part] == nil then
					v35.saved[part] = part.LocalTransparencyModifier
				end
			end
		end
	end

	for k in pairs(v35.saved) do
		if k.Parent and k.LocalTransparencyModifier ~= 1 then
			k.LocalTransparencyModifier = 1
		end
	end
end

local v36 = {
	"LeftHand",
	"LeftLowerArm",
	"LeftUpperArm",
	"RightHand",
	"RightLowerArm",
	"RightUpperArm",
	"Left Arm",
	"Right Arm"
}
local v37 = {
	char = nil,
	saved = {},
	sticks = {},
	glows = {},
	scanAt = 0,
	lastApply = 0
}

local function restoreHandFade()
	for k, localTransparencyModifier in pairs(v37.saved) do
		if k.Parent then
			k.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	for _, glow in ipairs(v37.glows) do
		glow:Destroy()
	end

	v37.saved = {}
	v37.sticks = {}
	v37.glows = {}
	v37.char = nil
end

local function setHandFade(char) -- 3 equivalent calls inferred from this helper
	if v37.char ~= char then
		restoreHandFade()
		v37.char = char
		v37.scanAt = 0
	end

	if not char then
		return
	end

	local drumCam = BandCameraConfig.Shots.DrumCam
	local now = os.clock()
	v37.lastApply = now

	if v37.scanAt <= now then
		v37.scanAt = now + 0.25

		for _, childName in ipairs(v36) do
			local part = char:FindFirstChild(childName)

			if part and part:IsA("BasePart") and v37.saved[part] == nil then
				v37.saved[part] = part.LocalTransparencyModifier
			end
		end

		for _, v38 in ipairs({ "Left", "Right" }) do
			local part = char:FindFirstChild(v38 .. "Drumstick", true)

			if not part then
				continue
			end

			local parts

			if part:IsA("BasePart") then
				parts = { part } or {}
			else
				parts = {}
			end

			if not part:IsA("BasePart") then
				for _, part2 in ipairs(part:GetDescendants()) do
					if part2:IsA("BasePart") then
						parts[#parts + 1] = part2
					end
				end
			end

			for _, v39 in ipairs(parts) do
				if v37.saved[v39] ~= nil then
					continue
				end

				v37.saved[v39] = v39.LocalTransparencyModifier
				v37.sticks[v39] = true

				if not drumCam.PadPovStickOutline then
					continue
				end

				local drumStickGlow = Instance.new("Highlight")
				drumStickGlow.Name = "DrumStickGlow"
				drumStickGlow.Adornee = v39
				drumStickGlow.FillTransparency = 1
				drumStickGlow.OutlineColor = Color3.fromRGB(255, 255, 255)
				drumStickGlow.OutlineTransparency = drumCam.PadPovStickOutlineTransparency
				drumStickGlow.DepthMode = Enum.HighlightDepthMode.Occluded
				drumStickGlow.Parent = v39
				v37.glows[#v37.glows + 1] = drumStickGlow
			end
		end
	end

	for k in pairs(v37.saved) do
		if not k.Parent then
			continue
		end

		local localTransparencyModifier = v37.sticks[k] and 0 or drumCam.PadPovHandAlpha

		if k.LocalTransparencyModifier ~= localTransparencyModifier then
			k.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

local v38 = { hum = nil, prev = nil }
local function setBodyLock(p) -- 4 equivalent calls inferred from this helper
	if p then
		local humanoid = getHumanoid() -- inferred equivalent call

		if humanoid and v38.hum ~= humanoid then
			if v38.hum and v38.hum.Parent and v38.prev ~= nil then
				v38.hum.AutoRotate = v38.prev
			end

			local autoRotate = humanoid.AutoRotate
			v38.hum = humanoid
			v38.prev = autoRotate
		end

		if v38.hum and v38.hum.AutoRotate then
			v38.hum.AutoRotate = false
		end
	elseif v38.hum then
		if v38.hum.Parent and v38.prev ~= nil then
			v38.hum.AutoRotate = v38.prev
		end

		v38.hum = nil
		v38.prev = nil
	end
end

RunService.Heartbeat:Connect(function()
	if v35.char and os.clock() - v35.lastApply > 0.2 then
		restoreHeadHide()
	end

	if v37.char and os.clock() - v37.lastApply > 0.2 then
		restoreHandFade()
	end
end)

local function finalize(p)
	if not flag5 then
		return
	end

	flag5 = false
	v17 = nil
	setHeadHide(nil) -- inferred equivalent call
	setHandFade(nil) -- inferred equivalent call
	setBodyLock(false) -- inferred equivalent call
	RunService:UnbindFromRenderStep("BandCameraController")

	local v39 = v20

	if
		p
		and currentCamera
		and v39
		and (v24 == nil or (currentCamera.CFrame.Position - v24.Position).Magnitude < 0.5)
	then
		local cameraType = v39.type

		if cameraType == Enum.CameraType.Scriptable then
			cameraType = Enum.CameraType.Custom
		end

		local cameraSubject = v39.subject

		if not (cameraSubject and cameraSubject.Parent) then
			cameraSubject = getHumanoid() -- inferred equivalent call
		end

		if cameraSubject then
			currentCamera.CameraSubject = cameraSubject
		end

		local root = getRoot() -- inferred equivalent call
		local cframe = root and v39.rel and root.CFrame * v39.rel or v39.cf

		if cframe then
			currentCamera.CFrame = cframe
		end

		currentCamera.CameraType = cameraType
		currentCamera.FieldOfView = v39.fov
	end

	SessionCameraSettings.SetIsCinematicActive(false)
	BandCameraStyle.End()
	reportWatchState() -- inferred equivalent call
	v19 = nil
	v20 = nil
	v21 = nil
	v22 = nil
	v23 = nil
	v24 = nil
	v25 = nil
end

local function activate(stageId, p)
	currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local root = getRoot() -- inferred equivalent call
	v20 = {
		type = currentCamera.CameraType,
		subject = currentCamera.CameraSubject,
		fov = currentCamera.FieldOfView,
		cf = currentCamera.CFrame,
		rel = root and root.CFrame:ToObjectSpace(currentCamera.CFrame) or nil
	}

	setContext(stageId, p)

	flag5 = true
	v17 = "in"
	v18 = os.clock()
	local cframe = currentCamera.CFrame
	local fieldOfView = currentCamera.FieldOfView
	v26 = cframe
	v27 = fieldOfView
	v21 = nil
	v22 = nil
	v23 = nil
	v24 = currentCamera.CFrame

	SessionCameraSettings.SetIsCinematicActive(true)
	BandCameraStyle.Begin()
	currentCamera.CameraType = Enum.CameraType.Scriptable
	RunService:BindToRenderStep("BandCameraController", Enum.RenderPriority.Last.Value, fn2)

	if v6 and (flag4 or flag2) then
		v6 = false
		fireAutoStarted(flag4 and "watch" or "player")
	end
end

local function release(p) -- 2 equivalent calls inferred from this helper
	if not flag5 then
		return
	end

	if p and currentCamera then
		if v17 ~= "out" then
			v17 = "out"
			v18 = os.clock()
			local cframe = currentCamera.CFrame
			local fieldOfView = currentCamera.FieldOfView
			v28 = cframe
			v29 = fieldOfView
		end
	else
		finalize(true)
	end
end

fn = function()
	if flag3 then
		local v39 = v11 and v3[v11]

		if inSession() or not (v39 and v39.target) then -- inferred equivalent call
			flag3 = false
			v11 = nil
			flag4 = false
		end
	end

	if not flag3 then
		BandCameraFocus.Reset()
	end

	local lightSession = nil

	if inSession() then -- inferred equivalent call
		lightSession = v3[v4].folder:GetAttribute("LightSession")
	end

	if lightSession ~= v8 then
		v8 = lightSession
		playerOn = false
		flag2 = false
		v6 = false
		v10 = os.clock() - 1000000
	end

	local v39 = nil

	if flag3 then
		v39 = v11
	elseif playerOn and inSession() and inZone then -- inferred equivalent call
		v39 = v4
	end

	local v40

	if v39 then
		v40 = v3[v39]

		if not (v40 and v40.target) then
			v39 = nil
			v40 = nil
		end
	else
		v39 = nil
	end

	local v41 = v39 ~= nil
	local v42

	if v41 then
		v42 = isSuspended() -- inferred equivalent call
	else
		v42 = v41
	end

	if v41 and not v42 then
		if flag5 then
			if v17 == "out" and currentCamera then
				v17 = "in"
				v18 = os.clock()
				local cframe = currentCamera.CFrame
				local fieldOfView = currentCamera.FieldOfView
				v26 = cframe
				v27 = fieldOfView
			end

			if v19 and (v19.stageId ~= v39 or v19.sessionId ~= v40.target.session) then
				setContext(v39, v40)
			elseif v19 then
				v19.target = v40.target
				local eligible, eligibleKey = eligibleOf(v40.target.roster)

				if eligibleKey == v19.eligibleKey then
					syncFocus(v19) -- inferred equivalent call
				else
					local v45 = v19
					v19.eligible = eligible
					v45.eligibleKey = eligibleKey
					rebuildTimeline(v19)
				end
			end
		else
			activate(v39, v40)
		end
	elseif flag5 then
		release(not (v42 or v15)) -- inferred equivalent call
	end

	notify()
end

local function fn3()
	if not currentCamera then
		return
	end

	if flag5 then
		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			if flag5 then
				flag5 = false
				v17 = nil
				setHeadHide(nil) -- inferred equivalent call
				setHandFade(nil) -- inferred equivalent call
				setBodyLock(false) -- inferred equivalent call
				RunService:UnbindFromRenderStep("BandCameraController")

				SessionCameraSettings.SetIsCinematicActive(false)
				BandCameraStyle.End()
				reportWatchState() -- inferred equivalent call
				v19 = nil
				v20 = nil
				v21 = nil
				v22 = nil
				v23 = nil
				v24 = nil
				v25 = nil
			end

			if currentCamera.CameraType == Enum.CameraType.Custom then
				task.defer(fn)
				return
			end

			v14 = true
			notify()
		end
	elseif v14 and currentCamera.CameraType == Enum.CameraType.Custom then
		v14 = false
		fn()
	end
end

local function kickShake(pausedAt, kicks)
	if not kicks or #kicks == 0 then
		return nil
	end

	local shake = BandCameraConfig.Shake
	local v39 = #kicks
	local v40 = 1
	local v41 = 0

	while v40 <= v39 do
		local v42 = (v40 + v39) // 2

		if kicks[v42] <= pausedAt then
			v40 = v42 + 1
			v41 = v42
		else
			v39 = v42 - 1
		end
	end

	if v41 == 0 or pausedAt - kicks[v41] >= shake.Decay then
		return nil
	end

	local v42 = 6.283185307179586 * shake.Frequency
	local rotAmp = math.rad(shake.RotAmp)
	local v43 = 0
	local v44 = 0
	local v45 = 0
	local v46 = 0
	local v47 = 0

	while v41 >= 1 do
		local v48 = pausedAt - kicks[v41]

		if shake.Decay <= v48 then
			break
		end

		local v49 = math.exp(-v48 / shake.Tau) * (1 - math.exp(-v48 / shake.Attack)) * math.sin(v42 * v48)
		local v50 = v41 * 2.399963
		local v51 = math.cos(v50)
		local v52 = math.sin(v50)
		v44 -= v49 * shake.PosAmp
		v43 += v51 * 0.45 * v49 * shake.PosAmp
		v45 += v49 * rotAmp * 0.8
		v46 += v51 * 0.5 * v49 * rotAmp
		v47 += v52 * 0.35 * v49 * rotAmp
		v41 -= 1
	end

	local v48 = math.max(math.abs(v43), (math.abs(v44))) / shake.PosAmp

	if shake.MaxScale < v48 then
		local v49 = shake.MaxScale / v48
		v43 *= v49
		v44 *= v49
		v45 *= v49
		v46 *= v49
		v47 *= v49
	end

	return CFrame.new(v43, v44, 0) * CFrame.Angles(v45, v46, v47)
end

local function easeOutCubic(p) -- 1 equivalent call inferred from this helper
	local v39 = 1 - p
	return 1 - v39 * v39 * v39
end

local function smootherstep(p) -- 2 equivalent calls inferred from this helper
	return p * p * p * (p * (p * 6 - 15) + 10)
end

local function blendInPose(p, p2, p3, p4, p5, rig)
	local blendInArc = BandCameraConfig.BlendInArc
	local v39 = smootherstep(p) -- inferred equivalent call
	local v40 = smootherstep(math.min(p * 1.18, 1)) -- inferred equivalent call
	local position = p2.Position
	local position2 = p3.Position
	local vector = position2 - position
	local magnitude = vector.Magnitude
	local v41

	if blendInArc and magnitude > 0.5 then
		local cross = vector:Cross(Vector3.new(0, 1, 0))
		local unit = cross.Magnitude > 0.001 and cross.Unit or Vector3.new(0, 0, 0)
		local v42 = (position + position2) / 2 + Vector3.new(0, 1, 0) * math.min(magnitude * blendInArc.Lift, blendInArc.Max) + unit * math.min(magnitude * blendInArc.Side, blendInArc.Max)

		if rig and rig.boundsPart then
			v42 = rig:_clampToBounds(v42)
		end

		local v43 = 1 - v39
		v41 = position * (v43 * v43) + v42 * (2 * v43 * v39) + position2 * (v39 * v39)
	else
		v41 = position:Lerp(position2, v39)
	end

	local lerped = p2.Rotation:Lerp(p3.Rotation, v40)
	local v42 = p4 + (p5 - p4) * v39 + math.sin(3.141592653589793 * v39) * (blendInArc and blendInArc.FovPunch or 0)
	return CFrame.new(v41) * lerped, v42
end

fn2 = function(p)
	if not (flag5 and currentCamera and v19) then
		return
	end

	setBodyLock(true) -- inferred equivalent call
	local now = os.clock()
	local target = v19.target
	local pausedAt = target.pausedAt or Workspace:GetServerTimeNow() - target.startAt

	if v17 ~= "out" and target.duration + BandCameraConfig.EndHoldSeconds < pausedAt then
		release(true) -- inferred equivalent call
	end

	if v17 == "out" then
		local v39 = math.clamp((now - v18) / BandCameraConfig.BlendOutSeconds, 0, 1)
		local root = getRoot() -- inferred equivalent call
		local v40 = v20.cf

		if root and v20.rel then
			v40 = root.CFrame * v20.rel
		end

		local v41 = easeOutCubic(v39) -- inferred equivalent call
		local lerped = v28:Lerp(v40, v41)
		local fieldOfView = v29 + (v20.fov - v29) * v41
		BandCameraStyle.Update(p, nil, false, true)
		currentCamera.CFrame = lerped
		currentCamera.FieldOfView = fieldOfView
		v24 = lerped

		if v39 >= 1 then
			finalize(true)
			notify()
		end
	else
		local v39 = false
		local v40 = nil
		local v41 = false
		local cframe, v43

		if v19.clips then
			cframe, v43 = BandCameraPlayback.PoseIfActive(v19.clips, pausedAt, v19.ref)
		end

		if cframe then
			v21 = nil
			v22 = nil
			v23 = nil
			v25 = nil
		else
			local normal = BandCameraConfig.Intensity.Normal
			local viewportSize = currentCamera.ViewportSize
			local v44 = viewportSize.X / math.max(1, viewportSize.Y)

			v40 = v
			local v45, v46

			if v19.timeline then
				v40, v45, v46 = BandCameraDirector.GetSlot(v19.timeline, pausedAt)
			else
				v46 = 0
				v45 = 0
			end

			if v25 == nil then
				v41 = false
			else
				v41 = v46 ~= v25
			end

			if BandCameraConfig.Transition.Mode == "Cut" and v46 ~= v25 then
				v21 = nil
				v22 = nil
				v23 = nil
			end

			v25 = v46

			v39 = v40.shake == true

			local rig = v19.rig

			local subjects = rig:GetSubjects(target.roster, not v40.cue)

			if #subjects == 0 then
				subjects = rig:GetSubjects(target.roster, false)
			end

			local solve = rig:Solve(v40, subjects, v45, v44, normal)
			local v47

			if solve then
				v47 = solve.hideChar or nil
			end

			setHeadHide(v47)
			local v48

			if solve then
				v48 = solve.fadeHands or nil
			end

			setHandFade(v48)

			if solve and solve.direct then
				v21 = nil
				v22 = nil
				v23 = nil
				cframe, v43 = rig:StabilizeDirect(solve)
			else
				if solve then
					if v21 then
						local v49 = 1 - math.exp(-normal.Follow * p)
						v21.focus = v21.focus:Lerp(solve.focus, v49)
						v21.yaw += (solve.yaw - v21.yaw) * v49
						v21.elev += (solve.elev - v21.elev) * v49
						v21.dist += (solve.dist - v21.dist) * v49
						v21.fov += (solve.fov - v21.fov) * v49
					else
						v21 = {
							focus = solve.focus,
							yaw = solve.yaw,
							elev = solve.elev,
							dist = solve.dist,
							fov = solve.fov
						}
					end
				end

				if not v21 then
					return
				end

				local positionFor = rig:PositionFor(v21)
				local collision, v49 = rig:ResolveCollision(v21.focus, positionFor, v21.fov)
				local avoidClutter = rig:AvoidClutter(collision, subjects)
				local stabilize, v50 = rig:Stabilize(v21.focus, avoidClutter, v49, subjects)
				local v51 = 1 - math.exp(-12 * p)

				if v22 then
					v22 = v22:Lerp(stabilize, v51)
					v23 += (v50 - v23) * v51
				else
					v22 = stabilize
					v23 = v50
				end

				local v52 = now * BandCameraConfig.SwaySpeed
				local v53 = math.noise(v52, v2, 11.3) * 2
				local v54 = math.noise(v52 * 1.3, v2, 27.7) * 2
				local v55 = math.noise(v52 * 0.8, v2, 53.1) * 2
				local v56 = rig.right * (v53 * normal.SwayPos)
				local v57 = Vector3.new(0, 1, 0) * (v54 * normal.SwayPos)

				local v58 = v22 + v56 + v57
				cframe = CFrame.lookAt(v58, v21.focus) * CFrame.Angles(0, 0, (math.rad(v55 * normal.SwayRoll)))
				v43 = v23
			end
		end

		if v39 and v19.kicks then
			local v44 = kickShake(pausedAt, v19.kicks)

			if v44 then
				cframe *= v44
			end
		end

		BandCameraStyle.Update(p, v40, v41, false)
		local fieldOfView = BandCameraStyle.AdjustFov(v43)

		if v17 == "in" then
			local v45 = math.clamp((now - v18) / BandCameraConfig.BlendInSeconds, 0, 1)
			cframe, fieldOfView = blendInPose(v45, v26, cframe, v27, fieldOfView, v19 and v19.rig)

			if v45 >= 1 then
				v17 = "on"
			end
		end

		currentCamera.CFrame = cframe
		currentCamera.FieldOfView = fieldOfView
		v24 = cframe
	end
end

local function computeNearStage()
	local root = getRoot() -- inferred equivalent call

	if not root then
		return nil
	end

	for k, v39 in pairs(v3) do
		if not v39.target then
			continue
		end

		local watchMargin = BandCameraConfig.WatchMargin

		if flag3 and k == v11 then
			watchMargin += BandCameraConfig.WatchLeaveExtra
		end

		if BandCameraRig.PointInStageZone(v39.folder, root.Position, watchMargin) then
			return k
		end
	end

	return nil
end

local function isMoving(): boolean
	local humanoid = getHumanoid() -- inferred equivalent call
	local root = getRoot() -- inferred equivalent call

	if not (humanoid and root) then
		return false
	end

	if humanoid.MoveDirection.Magnitude > 0.05 or humanoid.Jump then
		return true
	end

	local assemblyLinearVelocity = root.AssemblyLinearVelocity
	return Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude > 1.5
		or math.abs(assemblyLinearVelocity.Y) > 3
end

local function stopAutoWatch() -- 2 equivalent calls inferred from this helper
	if flag4 then
		flag4 = false
		flag3 = false
		v11 = nil
		v15 = true
		fn()
		v15 = false
	end
end

local function stopAutoPlayer() -- 2 equivalent calls inferred from this helper
	if flag2 then
		flag2 = false
		playerOn = false
		v15 = true
		fn()
		v15 = false
	end
end

local function autoCamAllowed(p): boolean -- 4 equivalent calls inferred from this helper
	local v39 = p and v3[p]
	return not v39 or v39.folder:GetAttribute("DynamicCamAuto") ~= false
end

local function onMoved() -- 4 equivalent calls inferred from this helper
	v10 = os.clock()
	v6 = false

	if flag4 then
		stopAutoWatch() -- inferred equivalent call
	end

	if flag2 then
		stopAutoPlayer() -- inferred equivalent call
	end
end

local function proximityTick()
	local v39 = computeNearStage()

	if v39 ~= v12 then
		v12 = v39
		notify()
	end

	if flag3 and v39 ~= v11 then
		flag3 = false
		v11 = nil
		flag4 = false
		fn()
	end

	local v40 = v4 and v3[v4] or nil
	local v41

	if v40 then
		local root = getRoot() -- inferred equivalent call

		if root == nil then
			v41 = false
		else
			v41 = BandCameraRig.PointInStageZone(v40.folder, root.Position, 0)
		end
	else
		v41 = false
	end

	if v41 ~= inZone then
		inZone = v41
		fn()
	end

	local autoWatch = BandCameraConfig.AutoWatch

	if autoWatch and autoWatch.Enabled then
		if isMoving() then
			onMoved() -- inferred equivalent call
		elseif not (v9 or v16 or v13 or SessionCameraSettings.GetIsMenuOpen()) then
			local v42 = os.clock() - v10

			if inSession() then -- inferred equivalent call
				if
					not playerOn
					and inZone
					and v40
					and v40.target
					and autoCamAllowed(v4) -- inferred equivalent call
					and (autoWatch.SessionIdleSeconds or autoWatch.IdleSeconds) <= v42
				then
					playerOn = true
					flag2 = true
					v6 = true
					fn()
				end
			elseif v39 and not flag3 and autoCamAllowed(v39) and autoWatch.IdleSeconds <= v42 then -- inferred equivalent call
				flag4 = true
				flag3 = true
				v11 = v39
				v6 = true
				fn()
			end
		end
	end
end

local function ensureProximityLoop() -- 3 equivalent calls inferred from this helper
	if flag6 then
		return
	end

	flag6 = true
	task.spawn(function()
		while true do
			if anyTarget() or flag3 then -- inferred equivalent call
				proximityTick()
				task.wait(BandCameraConfig.WatchPollSeconds)
			else
				break
			end
		end

		flag6 = false

		if inZone then
			inZone = false
			fn()
		end

		if v12 ~= nil then
			v12 = nil
			notify()
		end
	end)
end

local function registerStage(child)
	local studioId = child:GetAttribute("StudioId")

	if type(studioId) ~= "string" or v3[studioId] then
		return
	end

	local v39 = {
		folder = child,
		target = decodeTarget(child:GetAttribute("CamTarget")),
		rig = nil
	}
	v3[studioId] = v39
	child:GetAttributeChangedSignal("CamTarget"):Connect(function()
		v39.target = decodeTarget(child:GetAttribute("CamTarget"))

		if v39.target then
			ensureProximityLoop() -- inferred equivalent call
		end

		fn()
	end)
	child:GetAttributeChangedSignal("LightSession"):Connect(fn)
	child:GetAttributeChangedSignal("DynamicCamAuto"):Connect(function()
		if child:GetAttribute("DynamicCamAuto") == false then
			if flag2 and v4 == studioId then
				flag2 = false
				playerOn = false
			end

			if flag4 and v11 == studioId then
				flag4 = false
				flag3 = false
				v11 = nil
			end

			v6 = false
		end

		fn()
	end)

	if v39.target then
		ensureProximityLoop() -- inferred equivalent call
	end
end

function BandCameraController.GetAutoCountdown()
	local autoWatch = BandCameraConfig.AutoWatch

	if
		not autoWatch
		or not autoWatch.Enabled
		or v9
		or v16
		or v13
		or v14
		or SessionCameraSettings.GetIsMenuOpen()
		or isMoving()
	then
		return nil
	end

	local v39 = os.clock() - v10
	local v40 = inSession() -- inferred equivalent call
	local v41

	if v40 then
		local v42 = v4 and v3[v4] or nil

		if not playerOn and inZone and v42 and v42.target and autoCamAllowed(v4) then -- inferred equivalent call
			v41 = (autoWatch.SessionIdleSeconds or autoWatch.IdleSeconds) - v39

			if v41 <= 0 or (autoWatch.CountdownSeconds or 5) < v41 then
				return nil
			end

			return (math.ceil(v41))
		end

		return nil
	end

	if not flag3 and v12 and autoCamAllowed(v12) then -- inferred equivalent call
		v41 = autoWatch.IdleSeconds - v39

		if v41 <= 0 or (autoWatch.CountdownSeconds or 5) < v41 then
			return nil
		end

		return (math.ceil(v41))
	end

	return nil
end

function BandCameraController.GetUIState()
	local inSession2 = inSession() -- inferred equivalent call
	local target = inSession2 and v3[v4] and v3[v4].target or nil
	local uiState = {
		inSession = inSession2,
		inZone = inZone,
		playerOn = playerOn,
		running = flag5,
		eligible = target ~= nil,
		canWatch = nil,
		watching = nil,
		intensity = nil,
		autoIn = 0
	}

	local canWatch = not inSession2

	if canWatch then
		if v12 == nil then
			canWatch = false
		else
			canWatch = not flag3
		end
	end

	uiState.canWatch = canWatch
	uiState.watching = flag3
	uiState.intensity = intensity
	uiState.autoIn = BandCameraController.GetAutoCountdown()
	return uiState
end

function BandCameraController.SetPlayerEnabled(p)
	local v39 = p == true
	v9 = not v39
	flag2 = false
	v6 = false
	playerOn = v39
	fn()
end

function BandCameraController.StartWatch()
	if not flag3 and not inSession() and v12 then -- inferred equivalent call
		flag4 = false
		v9 = false
		flag3 = true
		v11 = v12
		ensureProximityLoop() -- inferred equivalent call
		fn()
	end
end

function BandCameraController.StopWatch()
	if not flag3 then
		return
	end

	v9 = true
	flag4 = false
	flag3 = false
	v11 = nil
	fn()
end

function BandCameraController.GetWatchStageId()
	return flag3 and v11 or nil
end

function BandCameraController.CycleIntensity()
	local intensityOrder = BandCameraConfig.IntensityOrder
	intensity = intensityOrder[(table.find(intensityOrder, intensity) or 1) % #intensityOrder + 1]
	notify()
end

function BandCameraController.GetIntensity()
	return intensity
end

function BandCameraController.GetTunerContext()
	local stageId = v4 and v3[v4] and v4 or nil

	if not stageId then
		local root = getRoot() -- inferred equivalent call

		if root then
			for k, v41 in pairs(v3) do
				if BandCameraRig.PointInStageZone(v41.folder, root.Position, BandCameraConfig.TunerMargin or 12) then
					stageId = k
					break
				end
			end
		end
	end

	if not stageId then
		return nil
	end

	local v40 = v3[stageId]
	local studioCenter = v40.folder:FindFirstChild("StudioCenter")
	local lightSong = v40.folder:GetAttribute("LightSong")

	local songTime = nil
	local paused = false
	local d = nil
	local camClock = v40.folder:GetAttribute("CamClock")

	if type(camClock) == "string" then
		local success, result = pcall(HttpService.JSONDecode, HttpService, camClock)

		if success and type(result) == "table" and type(result.s) == "number" then
			paused = type(result.p) == "number"
			songTime = paused and result.p or Workspace:GetServerTimeNow() - result.s

			if type(result.d) == "number" then
				d = result.d or nil
			end
		end
	end

	if songTime == nil then
		local lightStartAt = v40.folder:GetAttribute("LightStartAt")

		if type(lightStartAt) == "number" then
			songTime = Workspace:GetServerTimeNow() - lightStartAt
		end
	end

	return {
		stageId = stageId,
		folder = v40.folder,
		ref = studioCenter and studioCenter:IsA("Attachment") and studioCenter.WorldCFrame or CFrame.new(),
		hasRef = studioCenter ~= nil,
		song = type(lightSong) == "string" and lightSong or nil,
		songTime = songTime,
		paused = paused,
		duration = d,
		simActive = v40.folder:GetAttribute("CamSim") == true
	}
end

function BandCameraController.SetTunerHold(p)
	v16 = p == true
	fn()
end

function BandCameraController.RefreshTakes()
	if v19 then
		v19.clips = BandCameraPlayback.GetClips(v19.target.song, v19.stageId)
		rebuildTimeline(v19)
	end
end

function BandCameraController.Init()
	if flag then
		return
	end

	flag = true
	currentCamera = Workspace.CurrentCamera
	local cameraTypeChangedConnection = nil
	local function bindCamera() -- 2 equivalent calls inferred from this helper
		if cameraTypeChangedConnection then
			cameraTypeChangedConnection:Disconnect()
		end

		currentCamera = Workspace.CurrentCamera

		if currentCamera then
			cameraTypeChangedConnection = currentCamera:GetPropertyChangedSignal("CameraType"):Connect(fn3)
		end
	end

	bindCamera() -- inferred equivalent call
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		if flag5 then
			flag5 = false
			v17 = nil
			setHeadHide(nil) -- inferred equivalent call
			setHandFade(nil) -- inferred equivalent call
			setBodyLock(false) -- inferred equivalent call
			RunService:UnbindFromRenderStep("BandCameraController")

			SessionCameraSettings.SetIsCinematicActive(false)
			BandCameraStyle.End()
			reportWatchState() -- inferred equivalent call
			v19 = nil
			v20 = nil
			v21 = nil
			v22 = nil
			v23 = nil
			v24 = nil
			v25 = nil
		end

		bindCamera() -- inferred equivalent call
		fn()
	end)

	RemoteEvents:WaitForChild("SongSessionStatusUpdate").OnClientEvent:Connect(function(p)
		v5 = p == true
		fn()
	end)
	RemoteEvents:WaitForChild("MyStudioIdUpdate").OnClientEvent:Connect(function(value)
		v4 = type(value) == "string" and value or nil

		if not v4 then
			v5 = false
		end

		fn()
	end)

	SessionCameraSettings.OnChanged(function()
		fn()
	end)
	BandCameraPlayback.OnChanged(BandCameraController.RefreshTakes)
	BandCameraCues.OnChanged(BandCameraController.RefreshTakes)

	local success, result = pcall(function()
		return require(Modules:WaitForChild("LaptopUI"):WaitForChild("LaptopClientController"))
	end)

	if success and result then
		result.OnEnter(function()
			v13 = true
			fn()
		end)
		result.OnExit(function()
			v13 = false
			fn()
		end)
	else
		warn("[BandCameraController] LaptopClientController tidak bisa di-require, deteksi Laptop dilewati")
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local v39

		if v5 and v4 then
			local v40 = v3[v4]

			if v40 == nil then
				v39 = false
			else
				v39 = v40.folder:GetAttribute("LightSession") ~= nil
			end
		else
			v39 = false
		end

		if v39 then
			return
		end

		local name = input.UserInputType.Name

		if name == "Keyboard" or name:sub(1, 7) == "Gamepad" then
			onMoved() -- inferred equivalent call
		elseif (name == "Touch" or name:sub(1, 11) == "MouseButton") and not gameProcessed then
			onMoved() -- inferred equivalent call
		end
	end)
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		local v39

		if v5 and v4 then
			local v40 = v3[v4]

			if v40 == nil then
				v39 = false
			else
				v39 = v40.folder:GetAttribute("LightSession") ~= nil
			end
		else
			v39 = false
		end

		if not v39 and input.UserInputType == Enum.UserInputType.MouseWheel and not gameProcessed then
			onMoved() -- inferred equivalent call
		end
	end)

	local function bindMovement(instance)
		local humanoid = instance:WaitForChild("Humanoid", 5)

		if humanoid then
			humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
				if humanoid.MoveDirection.Magnitude > 0.05 then
					v10 = os.clock()
					v6 = false

					if flag4 then
						stopAutoWatch() -- inferred equivalent call
					end

					if flag2 then
						stopAutoPlayer() -- inferred equivalent call
					end
				end
			end)
			humanoid.Jumping:Connect(onMoved)
		end
	end

	if LocalPlayer.Character then
		task.spawn(bindMovement, LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		task.spawn(bindMovement, character)
		fn()
	end)
	LocalPlayer.CharacterRemoving:Connect(function()
		task.defer(fn)
	end)

	task.spawn(function()
		local map = Workspace:WaitForChild("Map", 30)

		if not map then
			warn("[BandCameraController] Workspace.Map tidak ditemukan")
			return
		end

		for _, child in ipairs(map:GetChildren()) do
			registerStage(child)
		end

		map.ChildAdded:Connect(registerStage)
		fn()
	end)
end

return BandCameraController