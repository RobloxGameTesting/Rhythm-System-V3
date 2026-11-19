local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BandCameraConfig = require(Modules:WaitForChild("BandCamera"):WaitForChild("BandCameraConfig"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))

local flag = false
local currentCamera = nil
local v = nil
local v2 = Vector3.new(0, 0, 0)
local v3 = 0
local v4 = 0
local fieldOfView = 70
local v5 = BandCameraConfig.Tuner.FlySpeed
local v6 = false
local v7 = nil
local v8 = {}
local connections = {}
local BandCameraFlyCam = {}

function BandCameraFlyCam.IsActive()
	return flag
end

function BandCameraFlyCam.OnStep(p)
	table.insert(v8, p)
end

function BandCameraFlyCam.SetDriver(p)
	v7 = p

	if not p and currentCamera then
		local cframe = currentCamera.CFrame
		v2 = cframe.Position
		v4, v3 = cframe:ToEulerAnglesYXZ()

		fieldOfView = currentCamera.FieldOfView
	end
end

function BandCameraFlyCam.HasDriver(): boolean
	return v7 ~= nil
end

local function setLooking(p) -- 2 equivalent calls inferred from this helper
	v6 = p
	UserInputService.MouseBehavior = p and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
end

local function step(p)
	if not (flag and currentCamera) then
		return
	end

	if v7 then
		local cframe, v9 = v7(p)

		if cframe then
			currentCamera.CFrame = cframe
			currentCamera.FieldOfView = v9 or currentCamera.FieldOfView
		end
	else
		if UserInputService:GetFocusedTextBox() == nil then
			local tuner = BandCameraConfig.Tuner
			local v9 = 1

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				v9 = tuner.FlyFastMultiplier
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				v9 = tuner.FlySlowMultiplier
			end

			local cframe = CFrame.fromEulerAnglesYXZ(v4, v3, 0)
			local v10 = Vector3.new(0, 0, 0)

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				v10 += cframe.LookVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				v10 -= cframe.LookVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				v10 += cframe.RightVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				v10 -= cframe.RightVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.E) then
				v10 += Vector3.new(0, 1, 0)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
				v10 -= Vector3.new(0, 1, 0)
			end

			if v10.Magnitude > 0 then
				v2 += v10.Unit * v5 * v9 * p
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Z) then
				fieldOfView = math.max(10, fieldOfView - tuner.FovPerSecond * p)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.X) then
				fieldOfView = math.min(110, fieldOfView + tuner.FovPerSecond * p)
			end
		end

		currentCamera.CFrame = CFrame.new(v2) * CFrame.fromEulerAnglesYXZ(v4, v3, 0)
		currentCamera.FieldOfView = fieldOfView
	end

	for _, callback in ipairs(v8) do
		local success, result = pcall(callback, p)

		if not success then
			warn("[BandCameraFlyCam] step callback error:", result)
		end
	end
end

function BandCameraFlyCam.Start()
	if flag then
		return
	end

	currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	v = {
		type = currentCamera.CameraType,
		subject = currentCamera.CameraSubject or humanoid,
		fov = currentCamera.FieldOfView
	}

	local cframe = currentCamera.CFrame
	v2 = cframe.Position
	v4, v3 = cframe:ToEulerAnglesYXZ()

	fieldOfView = currentCamera.FieldOfView
	v7 = nil

	flag = true
	SessionCameraSettings.SetIsCinematicActive(true)
	currentCamera.CameraType = Enum.CameraType.Scriptable

	ContextActionService:BindActionAtPriority("BandCameraFlySink", function()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.Space)

	connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 and not v7 then
			setLooking(true) -- inferred equivalent call
		end
	end)
	connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			v6 = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end)
	connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and v6 and not v7 then
			local lookSensitivity = BandCameraConfig.Tuner.LookSensitivity
			v3 -= input.Delta.X * lookSensitivity
			v4 = math.clamp(v4 - input.Delta.Y * lookSensitivity, -1.5533430342749532, 1.5533430342749532)
		elseif
			input.UserInputType == Enum.UserInputType.MouseWheel
			and not v7
			and UserInputService:GetFocusedTextBox() == nil
		then
			v5 = math.clamp(v5 * 1.15 ^ input.Position.Z, 2, 150)
		end
	end)

	RunService:BindToRenderStep("BandCameraFlyCam", Enum.RenderPriority.Last.Value, step)
end

function BandCameraFlyCam.Stop()
	if not flag then
		return
	end

	flag = false
	v7 = nil
	RunService:UnbindFromRenderStep("BandCameraFlyCam")
	ContextActionService:UnbindAction("BandCameraFlySink")

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
	setLooking(false) -- inferred equivalent call

	if currentCamera and v then
		local cameraType = v.type

		if cameraType == Enum.CameraType.Scriptable then
			cameraType = Enum.CameraType.Custom
		end

		if v.subject and v.subject.Parent then
			currentCamera.CameraSubject = v.subject
		end

		currentCamera.CameraType = cameraType
		currentCamera.FieldOfView = v.fov
	end

	SessionCameraSettings.SetIsCinematicActive(false)
	v = nil
end

return BandCameraFlyCam