local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HeadTrackingConfig = require(ReplicatedStorage.Modules.HeadTrackingSystem.HeadTrackingConfig)

local v = {}
local v2 = {}

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

local function newState(neck, waist, humanoid) -- 2 equivalent calls inferred from this helper
	return {
		Neck = neck,
		OriginalNeckC0 = neck.C0,
		Waist = waist,
		OriginalWaistC0 = waist and waist.C0,
		Humanoid = humanoid,
		CurrentYaw = 0,
		CurrentPitch = 0,
		LagYaw = 0,
		TargetYaw = 0,
		TargetPitch = 0,
		Active = false
	}
end

local function getOrCreateState(player)
	local v3 = v[player]

	if v3 then
		return v3
	end

	local character = player.Character

	if not character or v2[player] then
		return nil
	end

	local motor = findMotor(character, "Neck")

	if motor then
		local state = newState(motor, findMotor(character, "Waist"), character:FindFirstChildOfClass("Humanoid")) -- inferred equivalent call
		v[player] = state
		return state
	end

	v2[player] = true
	task.spawn(function()
		local v4 = os.clock() + 5
		local v5 = nil

		while os.clock() < v4 and character.Parent do
			v5 = findMotor(character, "Neck")

			if v5 then
				break
			end

			task.wait(0.2)
		end

		v2[player] = nil

		if v5 and character.Parent and not v[player] then
			v[player] = newState(v5, findMotor(character, "Waist"), character:FindFirstChildOfClass("Humanoid")) -- inferred equivalent call
		end
	end)
	return nil
end

RunService:BindToRenderStep("HeadTrackingApplier", Enum.RenderPriority.Character.Value + 1, function(p)
	local v3 = 1 - math.exp(-HeadTrackingConfig.SMOOTH_SPEED_ATTENTION * p)
	local v4 = 1 - math.exp(-HeadTrackingConfig.SMOOTH_SPEED_NECK * p)
	local v5 = 1 - math.exp(-HeadTrackingConfig.REMOTE_PITCH_SMOOTH_SPEED * p)

	for k, v6 in pairs(v) do
		if v6.Neck.Parent then
			v6.LagYaw += (v6.TargetYaw - v6.LagYaw) * v3
			v6.CurrentYaw += (v6.LagYaw - v6.CurrentYaw) * v4

			v6.CurrentPitch += (v6.TargetPitch - v6.CurrentPitch) * v5

			v6.Neck.C0 = v6.OriginalNeckC0 * CFrame.Angles(v6.CurrentPitch, v6.CurrentYaw, 0)

			local v7 = v6.Humanoid and v6.Humanoid:GetState() == Enum.HumanoidStateType.Seated

			if v6.Waist and v6.OriginalWaistC0 then
				if v7 then
					v6.Waist.C0 = v6.OriginalWaistC0
				else
					v6.Waist.C0 = v6.OriginalWaistC0 * CFrame.Angles(
						v6.CurrentPitch * HeadTrackingConfig.WAIST_VER_FACTOR,
						v6.CurrentYaw * HeadTrackingConfig.WAIST_HOR_FACTOR,
						0
					)
				end
			end
		else
			v[k] = nil
		end
	end
end)
local HeadTrackingApplier = {}

function HeadTrackingApplier.UpdateTarget(p, p2, p3, active)
	local state = getOrCreateState(p)

	if not state then
		return
	end

	state.TargetYaw = active and p2 or 0
	state.TargetPitch = active and p3 or 0
	state.Active = active
end

function HeadTrackingApplier.ReleasePlayer(p)
	v[p] = nil
end

return HeadTrackingApplier