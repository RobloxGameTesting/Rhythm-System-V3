local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HeadTrackingConfig = require(ReplicatedStorage.Modules.HeadTrackingSystem.HeadTrackingConfig)
local HeadTrackingApplier = require(ReplicatedStorage.Modules.HeadTrackingSystem.HeadTrackingApplier)
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)

local headRotationUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("HeadRotationUpdate")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local set = {
	[Enum.HumanoidStateType.Dead] = true,
	[Enum.HumanoidStateType.Physics] = true,
	[Enum.HumanoidStateType.Ragdoll] = true,
	[Enum.HumanoidStateType.Swimming] = true,
	[Enum.HumanoidStateType.Climbing] = true,
	[Enum.HumanoidStateType.FallingDown] = true
}

local v = nil
local humanoid = nil
local v2 = nil
local c0 = nil
local v3 = nil
local c0_2 = nil

local cframe = nil

local total = 0
local total2 = 0
local total3 = 0
local total4 = 0
local v4 = 0
local v5 = 0

local function findMotor(folder, childName)
	for _, childName2 in ipairs({ "Head", "UpperTorso", "LowerTorso", "Torso" }) do
		local child = folder:FindFirstChild(childName2)
		local motor6D = child and child:FindFirstChild(childName)

		if motor6D and motor6D:IsA("Motor6D") then
			return motor6D
		end
	end

	for _, motor6D in ipairs(folder:GetDescendants()) do
		if motor6D:IsA("Motor6D") and motor6D.Name == childName then
			return motor6D
		end
	end

	return nil
end

local function waitForMotor(instance, p, p2)
	local v6 = os.clock() + p2

	while os.clock() < v6 do
		local motor = findMotor(instance, p)

		if motor then
			return motor
		end

		task.wait(0.2)
	end

	return findMotor(instance, p)
end

local count = 0

local function onCharacterAdded(character)
	v = character
	humanoid = character:WaitForChild("Humanoid")
	v2 = nil
	c0 = nil
	v3 = nil
	c0_2 = nil
	total = 0
	total2 = 0
	total3 = 0
	cframe = nil

	count += 1
	local v6 = count

	task.spawn(function()
		local v7 = waitForMotor(character, "Neck", 5)

		if v6 ~= count then
			return
		end

		v2 = v7
		c0 = v2 and v2.C0
	end)

	task.spawn(function()
		local v7 = waitForMotor(character, "Waist", 5)

		if v6 ~= count then
			return
		end

		v3 = v7
		c0_2 = v3 and v3.C0
	end)
end

local function onCharacterRemoving()
	v = nil
	humanoid = nil
	v2 = nil
	c0 = nil
	v3 = nil
	c0_2 = nil
	cframe = nil
end

if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)

local function isThirdPerson(): boolean -- 1 equivalent call inferred from this helper
	local head = v and v:FindFirstChild("Head")

	if head then
		return (CurrentCamera.CFrame.Position - head.Position).Magnitude > HeadTrackingConfig.FIRST_PERSON_DISTANCE
	end

	return false
end

local function isSeated(): boolean -- 1 equivalent call inferred from this helper
	return humanoid ~= nil and humanoid:GetState() == Enum.HumanoidStateType.Seated
end

local function isStateValid(): boolean -- 1 equivalent call inferred from this helper
	if humanoid and not (humanoid.Health <= 0) then
		return not set[humanoid:GetState()]
	end

	return false
end

local function computeTargetAngles()
	local humanoidRootPart = v and v:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return 0, 0
	end

	local lookVector = humanoidRootPart.CFrame:ToObjectSpace(CurrentCamera.CFrame).LookVector

	local v6 = math.atan2(-lookVector.X, -lookVector.Z)
	local v7 = math.asin((math.clamp(lookVector.Y, -1, 1)))

	if math.abs(v6) > HeadTrackingConfig.LOOK_CUTOFF_YAW then
		return 0, 0
	end

	local v8 = HeadTrackingConfig.MAX_YAW * math.tanh(v6 / HeadTrackingConfig.MAX_YAW)
	local MAX_PITCH_UP = v7 >= 0 and HeadTrackingConfig.MAX_PITCH_UP or HeadTrackingConfig.MAX_PITCH_DOWN
	return v8, MAX_PITCH_UP * math.tanh(v7 / MAX_PITCH_UP)
end

local function applyPose(total5, total6, seated)
	if v2 and c0 then
		v2.C0 = c0 * CFrame.Angles(total6, total5, 0)
	end

	if v3 and c0_2 and not seated then
		v3.C0 = c0_2 * CFrame.Angles(
			total6 * HeadTrackingConfig.WAIST_VER_FACTOR,
			total5 * HeadTrackingConfig.WAIST_HOR_FACTOR,
			0
		)
	elseif v3 and c0_2 and seated then
		v3.C0 = c0_2
	end
end

local function sendToServer(p, p2, p3, p4) -- 1 equivalent call inferred from this helper
	total4 += p4
	local v6 = math.abs(p - v4) + math.abs(p2 - v5)

	if total4 >= HeadTrackingConfig.SEND_INTERVAL and (HeadTrackingConfig.MIN_DELTA_TO_SEND <= v6 or not p3) then
		headRotationUpdate:FireServer(p, p2, p3)
		v4 = p
		v5 = p2
		total4 = 0
	end
end

RunService:BindToRenderStep("HeadTrackingClient", Enum.RenderPriority.Character.Value + 1, function(p)
	if not v2 then
		return
	end

	local seated = isSeated() -- inferred equivalent call
	local isDrumFirstPersonGoPro = SessionCameraSettings.GetIsDrumFirstPersonGoPro()

	local v6 = not SessionCameraSettings.GetIsCinematicActive()

	if v6 then
		v6 = isStateValid() and (isThirdPerson() or seated) -- inferred equivalent call
	end

	local v7, v8

	if v6 then
		v7, v8 = computeTargetAngles()
	else
		v7 = 0
		v8 = 0
	end

	local v9 = 1 - math.exp(-HeadTrackingConfig.SMOOTH_SPEED_ATTENTION * p)
	total3 += (v7 - total3) * v9
	local v10 = 1 - math.exp(-HeadTrackingConfig.SMOOTH_SPEED_NECK * p)
	total += (total3 - total) * v10

	if v8 == 0 then
		total2 += (0 - total2) * v10
	else
		local v11 = 1 - math.exp(-HeadTrackingConfig.SMOOTH_SPEED_PITCH_ACTIVE * p)
		total2 += (v8 - total2) * v11
	end

	applyPose(total, total2, seated)
	sendToServer(v7, v8, v6, p) -- inferred equivalent call
	local upperTorso = v and v:FindFirstChild("UpperTorso")
	local lowerTorso = v and v:FindFirstChild("LowerTorso")
	local humanoidRootPart = v and v:FindFirstChild("HumanoidRootPart")

	if isDrumFirstPersonGoPro and v2 and v3 and upperTorso and lowerTorso and humanoidRootPart and c0 and c0_2 then
		local v11 = lowerTorso.CFrame * c0_2 * v3.Transform * v3.C1:Inverse() * c0 * v2.Transform * v2.C1:Inverse()
		local objectSpace = humanoidRootPart.CFrame:ToObjectSpace(v11)

		if not cframe then
			cframe = objectSpace
		end

		local v12 = cframe:Inverse() * objectSpace
		SessionCameraSettings.SetDrumGoProHeadDelta(v12)
	else
		cframe = nil
		SessionCameraSettings.SetDrumGoProHeadDelta(CFrame.new())
	end
end)

headRotationUpdate.OnClientEvent:Connect(function(p, value, value2, p2)
	if p == LocalPlayer or (typeof(value) ~= "number" or typeof(value2) ~= "number") then
		return
	end

	HeadTrackingApplier.UpdateTarget(p, value, value2, p2)
end)

Players.PlayerRemoving:Connect(function(player)
	HeadTrackingApplier.ReleasePlayer(player)
end)