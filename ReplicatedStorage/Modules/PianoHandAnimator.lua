local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AvatarTypeVerify = require(ReplicatedStorage.Modules.AvatarTypeVerify)
local AvatarBundleDatabase = require(ReplicatedStorage.Modules.AvatarBundleDatabase)

local v = {
	ElbowPullInFraction = 0.2,
	PoleDownRatio = 0.5,
	PoleForwardRatio = 0.25,
	PoleInwardLeftRatio = 0.15,
	PoleInwardRightRatio = -0.15,
	MaxCorrectionRatio = 1
}

local function getPoseParams(character) -- 2 equivalent calls inferred from this helper
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local v2 = playerFromCharacter and AvatarTypeVerify.GetAvatarType(playerFromCharacter)
	return v2 and AvatarBundleDatabase.PianoPoseOverridesByCategory[v2]
		or AvatarBundleDatabase.PianoPoseOverridesByCategory.Masculine
		or v
end

local function updatePole(data, hrp, poleDownStuds, poleForwardStuds) -- 2 equivalent calls inferred from this helper
	local lookVector = hrp.CFrame.LookVector
	local rightVector = hrp.CFrame.RightVector
	data.Pole.Position = data.LowerArm.Position + Vector3.new(0, -poleDownStuds, 0) + lookVector * poleForwardStuds + rightVector * data.PoleInward
end

local function measureArmLength(p, p2, p3) -- 2 equivalent calls inferred from this helper
	return (p2.Position - p.Position).Magnitude + (p3.Position - p2.Position).Magnitude
end

local v2 = {}

local function makeTargetPart(name, cframe, parent) -- 4 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Massless = true
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.CFrame = cframe
	part.Parent = parent
	return part
end

local function makeIK(name, chainRoot, endEffector, targetPart, targetPart2, animator) -- 2 equivalent calls inferred from this helper
	local ikControl = Instance.new("IKControl")
	ikControl.Name = name
	ikControl.ChainRoot = chainRoot
	ikControl.EndEffector = endEffector
	ikControl.Type = Enum.IKControlType.Position
	ikControl.Target = targetPart
	ikControl.Pole = targetPart2
	ikControl.SmoothTime = 0
	ikControl.Weight = 1
	ikControl.Enabled = true
	ikControl.Parent = animator
	return ikControl
end

local PianoHandAnimator = {}

function PianoHandAnimator.Setup(instance, data)
	if not instance or v2[instance] then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local leftUpperArm = instance:FindFirstChild("LeftUpperArm")
	local leftLowerArm = instance:FindFirstChild("LeftLowerArm")
	local leftHand = instance:FindFirstChild("LeftHand")
	local rightUpperArm = instance:FindFirstChild("RightUpperArm")
	local rightLowerArm = instance:FindFirstChild("RightLowerArm")
	local rightHand = instance:FindFirstChild("RightHand")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (leftUpperArm and leftLowerArm and leftHand and rightUpperArm and rightLowerArm and rightHand and humanoidRootPart) then
		return
	end

	if not data then
		data = getPoseParams(instance) -- inferred equivalent call
	end

	local lookVector = humanoidRootPart.CFrame.LookVector
	local rightVector = humanoidRootPart.CFrame.RightVector
	local armLength = measureArmLength(leftUpperArm, leftLowerArm, leftHand) -- inferred equivalent call
	local armLength2 = measureArmLength(rightUpperArm, rightLowerArm, rightHand) -- inferred equivalent call
	local lerped = leftHand.Position:Lerp(leftUpperArm.Position, data.ElbowPullInFraction)
	local lerped2 = rightHand.Position:Lerp(rightUpperArm.Position, data.ElbowPullInFraction)

	local poleDownStuds = data.PoleDownRatio * armLength
	local poleForwardStuds = data.PoleForwardRatio * armLength
	local poleDownStuds2 = data.PoleDownRatio * armLength2
	local poleForwardStuds2 = data.PoleForwardRatio * armLength2

	local v3 = leftLowerArm.Position + Vector3.new(0, -poleDownStuds, 0) + lookVector * poleForwardStuds + rightVector * (data.PoleInwardLeftRatio * armLength)
	local v4 = rightLowerArm.Position + Vector3.new(0, -poleDownStuds2, 0) + lookVector * poleForwardStuds2 + rightVector * (data.PoleInwardRightRatio * armLength2)

	local targetPart = makeTargetPart("PianoHandTarget_Left", CFrame.new(lerped), instance) -- inferred equivalent call
	local targetPart2 = makeTargetPart("PianoHandTarget_Right", CFrame.new(lerped2), instance) -- inferred equivalent call
	local targetPart3 = makeTargetPart("PianoElbowPole_Left", CFrame.new(v3), instance) -- inferred equivalent call
	local targetPart4 = makeTargetPart("PianoElbowPole_Right", CFrame.new(v4), instance) -- inferred equivalent call
	local ik = makeIK("PianoHandIK_Left", leftUpperArm, leftHand, targetPart, targetPart3, animator) -- inferred equivalent call
	local ik2 = makeIK("PianoHandIK_Right", rightUpperArm, rightHand, targetPart2, targetPart4, animator) -- inferred equivalent call
	local v5 = {
		MaxCorrectionStuds = data.MaxCorrectionRatio * ((armLength + armLength2) / 2),
		HRP = humanoidRootPart,
		Left = {
			IK = ik,
			Target = targetPart,
			Pole = targetPart3,
			LowerArm = leftLowerArm,
			PoleInward = data.PoleInwardLeftRatio * armLength,
			PoleDownStuds = poleDownStuds,
			PoleForwardStuds = poleForwardStuds,
			NeutralPos = lerped,
			CurrentTargetPos = lerped,
			Tween = nil
		},
		Right = {
			IK = ik2,
			Target = targetPart2,
			Pole = targetPart4,
			LowerArm = rightLowerArm,
			PoleInward = data.PoleInwardRightRatio * armLength2,
			PoleDownStuds = poleDownStuds2,
			PoleForwardStuds = poleForwardStuds2,
			NeutralPos = lerped2,
			CurrentTargetPos = lerped2,
			Tween = nil
		}
	}

	v2[instance] = v5

	v5.Connection = RunService.Heartbeat:Connect(function()
		updatePole(v5.Left, v5.HRP, v5.Left.PoleDownStuds, v5.Left.PoleForwardStuds) -- inferred equivalent call
		updatePole(v5.Right, v5.HRP, v5.Right.PoleDownStuds, v5.Right.PoleForwardStuds) -- inferred equivalent call
	end)
end

function PianoHandAnimator.Cleanup(p)
	local v3 = p and v2[p]

	if not v3 then
		return
	end

	v2[p] = nil

	if v3.Connection then
		v3.Connection:Disconnect()
	end

	for _, v4 in pairs(v3) do
		if type(v4) ~= "table" then
			continue
		end

		if v4.Tween then
			v4.Tween:Cancel()
		end

		if v4.IK then
			v4.IK:Destroy()
		end

		if v4.Target then
			v4.Target:Destroy()
		end

		if v4.Pole then
			v4.Pole:Destroy()
		end
	end
end

local function computeHoverPosition(list)
	local total = Vector3.new(0, 0, 0)

	for _, item in ipairs(list) do
		total += (item.originalCFrame * CFrame.new(0, 0.15, 0)).Position
	end

	return total / #list
end

local function moveSideTarget(state, currentTargetPos, maxCorrectionStuds)
	local neutralPos = state.NeutralPos
	local v3 = currentTargetPos - neutralPos
	local magnitude = v3.Magnitude

	if maxCorrectionStuds < magnitude and magnitude > 0 then
		currentTargetPos = neutralPos + v3.Unit * maxCorrectionStuds
	end

	if (currentTargetPos - state.CurrentTargetPos).Magnitude < 0.3 then
		return
	end

	if state.Tween then
		state.Tween:Cancel()
	end

	local tween = TweenService:Create(
		state.Target,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Position = currentTargetPos }
	)

	state.Tween = tween
	tween:Play()
	state.CurrentTargetPos = currentTargetPos
end

function PianoHandAnimator.UpdateForChordGroup(p, list)
	local v3 = p and v2[p]

	if not v3 or not list or #list == 0 then
		return
	end

	local v4 = {}
	local v5 = {}

	for _, item in ipairs(list) do
		if item.hand == "Left" then
			table.insert(v5, item)
		else
			table.insert(v4, item)
		end
	end

	if #v5 > 0 then
		moveSideTarget(v3.Left, computeHoverPosition(v5), v3.MaxCorrectionStuds)
	end

	if #v4 > 0 then
		moveSideTarget(v3.Right, computeHoverPosition(v4), v3.MaxCorrectionStuds)
	end
end

function PianoHandAnimator.GetPoseParams(character)
	return getPoseParams(character) -- inferred equivalent call
end

local success, pianoHandAnimatorV2 = pcall(require, script.Parent.PianoHandAnimatorV2)

if not (success and pianoHandAnimatorV2) then
	warn("[PianoHandAnimator] PianoHandAnimatorV2 gagal dimuat, memakai implementasi lama: " .. tostring(pianoHandAnimatorV2))

	return PianoHandAnimator
end

local setup = PianoHandAnimator.Setup
local cleanup = PianoHandAnimator.Cleanup
local updateForChordGroup = PianoHandAnimator.UpdateForChordGroup

function PianoHandAnimator.Setup(p, p2)
	if pianoHandAnimatorV2.Enabled then
		pianoHandAnimatorV2.BeginSession(p)
	else
		setup(p, p2)
	end
end
function PianoHandAnimator.Cleanup(p)
	if pianoHandAnimatorV2.Enabled then
		pianoHandAnimatorV2.EndSession(p)
	else
		cleanup(p)
	end
end
function PianoHandAnimator.UpdateForChordGroup(p, p2)
	if pianoHandAnimatorV2.Enabled then
		pianoHandAnimatorV2.UpdateForChordGroup(p, p2)
	else
		updateForChordGroup(p, p2)
	end
end
PianoHandAnimator.V2 = pianoHandAnimatorV2
return PianoHandAnimator