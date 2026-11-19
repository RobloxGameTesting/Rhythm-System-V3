local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)

local v = 0
local total = 0

local cframe = CFrame.identity
local v2 = false

local v3 = math.random() * 1000
local v4 = math.random() * 1000
local v5 = math.random() * 1000
local v6 = math.random() * 1000
local v7 = math.random() * 1000
local v8 = math.random() * 1000
local ScreenShake = {}

function ScreenShake.Add(p)
	if not SettingsState.GetShakeEnabled() then
		return
	end

	v = math.clamp(math.max(v, p), 0, 1)
end

RunService:BindToRenderStep("ScreenShake", Enum.RenderPriority.Camera.Value + 1, function(p)
	local currentCamera = Workspace.CurrentCamera

	if v <= 0 then
		if v2 and currentCamera then
			currentCamera.CFrame *= cframe:Inverse()
			cframe = CFrame.identity
			v2 = false
		end
	else
		if not currentCamera then
			return
		end

		total += p
		local v9 = v * v
		local v10 = total * 12

		local v11 = math.noise(v3, v10) * 0.6 * v9
		local v12 = math.noise(v4, v10) * 0.6 * v9
		local v13 = math.noise(v5, v10) * 0.6 * v9 * 0.5

		local v14 = math.noise(v6, v10) * 4 * v9
		local v15 = math.noise(v7, v10) * 4 * v9
		local v16 = math.noise(v8, v10) * 4 * v9

		local v17 = CFrame.new(v11, v12, v13) * CFrame.Angles(math.rad(v14), math.rad(v15), (math.rad(v16)))

		currentCamera.CFrame = (v2 and currentCamera.CFrame * cframe:Inverse() or currentCamera.CFrame) * v17
		cframe = v17
		v2 = true

		v = math.max(0, v - 1.6 * p)
	end
end)

ScreenShake.INTENSITY_LIGHT = 0.18
ScreenShake.INTENSITY_MEDIUM = 0.35

return ScreenShake