local HapticService = game:GetService("HapticService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local v = {
	Wrong = {
		{ 0.11, 0.9, 0.5 }
	},
	Invite = {
		{ 0.08, 0, 0.6 },
		{ 0.07, 0, 0 },
		{ 0.08, 0, 0.6 }
	},
	Countdown = {
		{ 0.16, 0.55, 0.35 }
	}
}

local v2 = {
	Enum.UserInputType.Gamepad1,
	Enum.UserInputType.Gamepad2,
	Enum.UserInputType.Gamepad3,
	Enum.UserInputType.Gamepad4
}

local count = 0
local nows = {}
local v3 = { Wrong = 0.12, Invite = 0.5, Countdown = 1 }

local function vibrationEnabled()
	local success, result = pcall(function()
		return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SettingsState", 2))
	end)

	if success and result and result.IsVibrationEnabled then
		return result.IsVibrationEnabled()
	end

	return true
end

local function activePad() -- 2 equivalent calls inferred from this helper
	local lastInputType = UserInputService:GetLastInputType()

	for _, v4 in ipairs(v2) do
		if lastInputType == v4 then
			return v4
		end
	end

	return UserInputService:GetConnectedGamepads()[1]
end

local HapticFx = {}

function HapticFx.IsAvailable()
	local v4 = activePad() -- inferred equivalent call

	if not v4 then
		return false
	end

	local success, result = pcall(function()
		return HapticService:IsVibrationSupported(v4)
	end)

	return success and result == true
end

local function setMotors(p, p2, p3)
	if p2 ~= nil and HapticService:IsMotorSupported(p, Enum.VibrationMotor.Large) then
		pcall(HapticService.SetMotor, HapticService, p, Enum.VibrationMotor.Large, p2)
	end

	if p3 ~= nil and HapticService:IsMotorSupported(p, Enum.VibrationMotor.Small) then
		pcall(HapticService.SetMotor, HapticService, p, Enum.VibrationMotor.Small, p3)
	end
end

function HapticFx.Play(p)
	local v4 = v[p]

	if v4 then
		local success, result = pcall(function()
			return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SettingsState", 2))
		end)

		if not (success and result and result.IsVibrationEnabled) or result.IsVibrationEnabled() then
			local now = os.clock()

			if nows[p] and now - nows[p] < (v3[p] or 0.1) then
				return
			end

			local v5 = activePad() -- inferred equivalent call

			if not v5 then
				return
			end

			local success2, result2 = pcall(function()
				return HapticService:IsVibrationSupported(v5)
			end)

			if not (success2 and result2) then
				return
			end

			nows[p] = now
			count += 1
			local v6 = count
			task.spawn(function()
				for _, v7 in ipairs(v4) do
					if v6 ~= count then
						return
					end

					setMotors(v5, v7[2], v7[3])
					task.wait(v7[1])
				end

				if v6 == count then
					setMotors(v5, 0, 0)
				end
			end)
		end
	end
end

return HapticFx