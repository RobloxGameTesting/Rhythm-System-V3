local class = {}
class.__index = class

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")

script.Parent:WaitForChild("CommonUtils")

local Keyboard = require(script:WaitForChild("Keyboard"))
local Gamepad = require(script:WaitForChild("Gamepad"))
local DynamicThumbstick = require(script:WaitForChild("DynamicThumbstick"))

local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserDynamicThumbstickSafeAreaUpdate")
end)

local v = success and result

local TouchThumbstick = require(script:WaitForChild("TouchThumbstick"))

local ClickToMoveController = require(script:WaitForChild("ClickToMoveController"))
local TouchJump = require(script:WaitForChild("TouchJump"))

local VehicleController = require(script:WaitForChild("VehicleController"))

local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPlayerScriptsSupportMicroGamepad")
end)

local v2 = success2 and result2

local value = Enum.ContextActionPriority.Medium.Value

local v3 = {
	[Enum.TouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbstick] = TouchThumbstick,
	[Enum.DevTouchMovementMode.Thumbstick] = TouchThumbstick,
	[Enum.TouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.TouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevTouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.TouchMovementMode.Default] = DynamicThumbstick,
	[Enum.ComputerMovementMode.Default] = Keyboard,
	[Enum.ComputerMovementMode.KeyboardMouse] = Keyboard,
	[Enum.DevComputerMovementMode.KeyboardMouse] = Keyboard,
	[Enum.DevComputerMovementMode.Scriptable] = nil,
	[Enum.ComputerMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevComputerMovementMode.ClickToMove] = ClickToMoveController
}

function class.new()
	local object = setmetatable({}, class)

	object.controllers = {}

	object.activeControlModule = nil
	object.activeController = nil
	object.touchJumpController = nil
	object.moveFunction = Players.LocalPlayer.Move
	object.humanoid = nil
	object.controlsEnabled = true

	object.humanoidSeatedConn = nil
	object.vehicleController = nil

	object.touchControlFrame = nil
	object.currentTorsoAngle = 0

	object.inputMoveVector = Vector3.new(0, 0, 0)

	object.vehicleController = VehicleController.new(value)

	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		object:OnCharacterAdded(character)
	end)
	Players.LocalPlayer.CharacterRemoving:Connect(function(character)
		object:OnCharacterRemoving(character)
	end)

	if Players.LocalPlayer.Character then
		object:OnCharacterAdded(Players.LocalPlayer.Character)
	end

	RunService:BindToRenderStep("ControlScriptRenderstep", Enum.RenderPriority.Input.Value, function(p)
		object:OnRenderStepped(p)
	end)

	UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)

	UserGameSettings:GetPropertyChangedSignal("ComputerMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)

	object.playerGui = nil
	object.touchGui = nil
	object.playerGuiAddedConn = nil

	GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(function()
		object:UpdateMovementMode()
		object:UpdateActiveControlModuleEnabled()
	end)

	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		object:UpdateMovementMode()
	end)

	object.playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not object.playerGui then
		object.playerGuiAddedConn = Players.LocalPlayer.ChildAdded:Connect(function(playerGui)
			if playerGui:IsA("PlayerGui") then
				object.playerGui = playerGui
				object.playerGuiAddedConn:Disconnect()
				object.playerGuiAddedConn = nil
				object:UpdateMovementMode()
			end
		end)
	end

	object:UpdateMovementMode()

	return object
end

function class:GetMoveVector()
	if self.activeController then
		return self.activeController:GetMoveVector()
	end

	return Vector3.new(0, 0, 0)
end

local function NormalizeAngle(p) -- 4 equivalent calls inferred from this helper
	local angle = (p + 12.566370614359172) % 6.283185307179586

	if angle > 3.141592653589793 then
		angle -= 6.283185307179586
	end

	return angle
end

local function AverageAngle(p, p2) -- 1 equivalent call inferred from this helper
	return NormalizeAngle(p + NormalizeAngle(p2 - p) / 2) -- inferred equivalent call
end

function class:GetEstimatedVRTorsoFrame()
	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local _, v4, _ = userCFrame:ToEulerAnglesYXZ()
	local currentTorsoAngle = -v4

	if
		VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand)
		and VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
	then
		local userCFrame2 = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
		local userCFrame3 = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)

		local v5 = userCFrame.Position - userCFrame2.Position
		local v6 = userCFrame.Position - userCFrame3.Position
		local averageAngle = AverageAngle(-math.atan2(v5.X, v5.Z), -math.atan2(v6.X, v6.Z)) -- inferred equivalent call

		local angle = NormalizeAngle(currentTorsoAngle - self.currentTorsoAngle) -- inferred equivalent call
		local v7
		local angle2 = NormalizeAngle(averageAngle - self.currentTorsoAngle) -- inferred equivalent call

		if angle2 > -1.5707963267948966 then
			v7 = angle2 < 1.5707963267948966
		else
			v7 = false
		end

		if not v7 then
			angle2 = angle
		end

		local v8 = math.min(angle2, angle)
		local v9 = math.max(angle2, angle)

		local v10 = 0

		if v8 > 0 then
			v10 = v8
		elseif v9 < 0 then
			v10 = v9
		end

		self.currentTorsoAngle = v10 + self.currentTorsoAngle
	else
		self.currentTorsoAngle = currentTorsoAngle
	end

	return CFrame.new(userCFrame.Position) * CFrame.fromEulerAnglesYXZ(0, -self.currentTorsoAngle, 0)
end

function class.GetActiveController(p)
	return p.activeController
end

function class:UpdateActiveControlModuleEnabled()
	local function fn()
		if
			self.touchControlFrame
			and UserInputService.PreferredInput == Enum.PreferredInput.Touch
			and (self.activeControlModule == ClickToMoveController or self.activeControlModule == TouchThumbstick or self.activeControlModule == DynamicThumbstick)
		then
			if not self.controllers[TouchJump] then
				self.controllers[TouchJump] = TouchJump.new()
			end

			self.touchJumpController = self.controllers[TouchJump]
			self.touchJumpController:Enable(true, self.touchControlFrame)
		elseif self.touchJumpController then
			self.touchJumpController:Enable(false)
		end

		if self.activeControlModule == ClickToMoveController then
			self.activeController:Enable(
				true,
				Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice,
				self.touchJumpController
			)
		elseif self.touchControlFrame then
			self.activeController:Enable(true, self.touchControlFrame)
		else
			self.activeController:Enable(true)
		end
	end

	if not self.activeController then
		return
	end

	if
		self.controlsEnabled
		and (GuiService.TouchControlsEnabled or UserInputService.PreferredInput ~= Enum.PreferredInput.Touch or self.activeControlModule ~= ClickToMoveController and self.activeControlModule ~= TouchThumbstick and self.activeControlModule ~= DynamicThumbstick)
	then
		fn()
		return
	end

	local function fn2() -- 1 equivalent call inferred from this helper
		self.activeController:Enable(false)

		if self.touchJumpController then
			self.touchJumpController:Enable(false)
		end

		if self.moveFunction then
			self.moveFunction(Players.LocalPlayer, Vector3.new(0, 0, 0), true)
		end
	end

	fn2() -- inferred equivalent call
end

function class:Enable(flag: boolean?)
	local controlsEnabled = flag == nil or flag

	if self.controlsEnabled == controlsEnabled then
		return
	end

	self.controlsEnabled = controlsEnabled

	if not self.activeController then
		return
	end

	self:UpdateActiveControlModuleEnabled()
end

function class:Disable()
	self:Enable(false)
end

function class:SelectComputerMovementModule()
	if not (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
		return nil, false
	end

	local v4 = nil
	local devComputerMovementMode = Players.LocalPlayer.DevComputerMovementMode

	if devComputerMovementMode == Enum.DevComputerMovementMode.UserChoice then
		local v5 = false

		if v2 then
			pcall(function()
				v5 = UserInputService.PreferredInput == Enum.PreferredInput.MicroGamepad
			end)
		end

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad or v5 then
			v4 = Gamepad
		elseif UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
			v4 = Keyboard
		end

		if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove and v4 == Keyboard then
			v4 = ClickToMoveController
		end
	else
		v4 = v3[devComputerMovementMode]

		if not v4 and devComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
			warn("No character control module is associated with DevComputerMovementMode ", devComputerMovementMode)
		end
	end

	if v4 then
		return v4, true
	end

	if devComputerMovementMode == Enum.DevComputerMovementMode.Scriptable then
		return nil, true
	end

	return nil, false
end

function class:SelectTouchModule()
	local devTouchMovementMode = Players.LocalPlayer.DevTouchMovementMode
	local v4

	if devTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		v4 = v3[UserGameSettings.TouchMovementMode]

		return v4, true
	end

	if devTouchMovementMode == Enum.DevTouchMovementMode.Scriptable then
		return nil, true
	end

	v4 = v3[devTouchMovementMode]

	return v4, true
end

local function getGamepadRightThumbstickPosition()
	local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

	for _, v4 in pairs(gamepadState) do
		if v4.KeyCode == Enum.KeyCode.Thumbstick2 then
			return v4.Position
		end
	end

	return Vector3.new(0, 0, 0)
end

function class:calculateRawMoveVector(object, vector3: Vector3)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return vector3
	end

	local cframe = currentCamera.CFrame

	if VRService.VREnabled and object.RootPart then
		VRService:GetUserCFrame(Enum.UserCFrame.Head)

		local estimatedVRTorsoFrame = self:GetEstimatedVRTorsoFrame()

		if (currentCamera.Focus.Position - cframe.Position).Magnitude < 3 then
			cframe *= estimatedVRTorsoFrame
		else
			cframe = currentCamera.CFrame * (estimatedVRTorsoFrame.Rotation + estimatedVRTorsoFrame.Position * currentCamera.HeadScale)
		end
	end

	if object:GetState() == Enum.HumanoidStateType.Swimming then
		if not VRService.VREnabled then
			return cframe:VectorToWorldSpace(vector3)
		end

		local vector3_2 = Vector3.new(vector3.X, 0, vector3.Z)

		if vector3_2.Magnitude < 0.01 then
			return Vector3.new(0, 0, 0)
		end

		local v4 = -getGamepadRightThumbstickPosition().Y * 1.3962634015954636
		local v5 = math.atan2(-vector3_2.X, -vector3_2.Z)
		local _, v6, _ = cframe:ToEulerAnglesYXZ()
		local v7 = v5 + v6
		return CFrame.fromEulerAnglesYXZ(v4, v7, 0).LookVector
	else
		local _, _, _, v4, v5, v6, _, _, v7, _, _, v8 = cframe:GetComponents()

		if v7 < 1 and v7 > -1 then
			v4 = v8
		else
			v6 = -v5 * math.sign(v7)
		end

		local v9 = math.sqrt(v4 * v4 + v6 * v6)
		return (Vector3.new((v4 * vector3.X + v6 * vector3.Z) / v9, 0, (v4 * vector3.Z - v6 * vector3.X) / v9))
	end
end

function class:OnRenderStepped(p)
	if self.activeController and self.activeController.enabled and self.humanoid then
		local moveVector = self.activeController:GetMoveVector()
		local v4 = self.activeController:IsMoveVectorCameraRelative()

		local clickToMoveController = self:GetClickToMoveController()

		if self.activeController == clickToMoveController then
			clickToMoveController:OnRenderStepped(p)
		elseif moveVector.magnitude > 0 then
			clickToMoveController:CleanupPath()
		else
			clickToMoveController:OnRenderStepped(p)
			moveVector = clickToMoveController:GetMoveVector()
			v4 = clickToMoveController:IsMoveVectorCameraRelative()
		end

		if self.vehicleController then
			local _
			moveVector, _ = self.vehicleController:Update(moveVector, v4, self.activeControlModule == Gamepad)
		end

		if v4 then
			moveVector = self:calculateRawMoveVector(self.humanoid, moveVector)
		end

		self.inputMoveVector = moveVector

		if VRService.VREnabled then
			moveVector = self:updateVRMoveVector(moveVector)
		end

		self.moveFunction(Players.LocalPlayer, moveVector, false)

		self.humanoid.Jump = self.activeController:GetIsJumping()
			or self.touchJumpController and self.touchJumpController:GetIsJumping()
	end
end

function class:updateVRMoveVector(p)
	local currentCamera = workspace.CurrentCamera

	local v4 = (currentCamera.Focus.Position - currentCamera.CFrame.Position).Magnitude < 5

	if p.Magnitude ~= 0 or not v4 or not VRService.AvatarGestures or not self.humanoid or self.humanoid.Sit then
		return p
	end

	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local v5 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale

	local v6 = -0.7 * self.humanoid.RootPart.Size.Y / 2
	local v7 = (currentCamera.CFrame * v5 * CFrame.new(0, v6, 0)).Position - self.humanoid.RootPart.CFrame.Position
	return (Vector3.new(v7.x, 0, v7.z))
end

function class:OnHumanoidSeated(flag: boolean, vehicleSeat)
	if flag then
		if vehicleSeat and vehicleSeat:IsA("VehicleSeat") then
			if not self.vehicleController then
				self.vehicleController = self.vehicleController.new(value)
			end

			self.vehicleController:Enable(true, vehicleSeat)
		end
	elseif self.vehicleController then
		self.vehicleController:Enable(false, vehicleSeat)
	end
end

function class:OnCharacterAdded(instance)
	self.humanoid = instance:FindFirstChildOfClass("Humanoid")

	while not self.humanoid do
		instance.ChildAdded:wait()
		self.humanoid = instance:FindFirstChildOfClass("Humanoid")
	end

	if self.humanoidSeatedConn then
		self.humanoidSeatedConn:Disconnect()
		self.humanoidSeatedConn = nil
	end

	self.humanoidSeatedConn = self.humanoid.Seated:Connect(function(p, p2)
		self:OnHumanoidSeated(p, p2)
	end)

	self:UpdateMovementMode()
end

function class:OnCharacterRemoving(_)
	self.humanoid = nil

	self:UpdateMovementMode()
end

function class:UpdateTouchGuiVisibility()
	local v4 = self.humanoid
		and GuiService.TouchControlsEnabled
		and UserInputService.PreferredInput == Enum.PreferredInput.Touch

	if v4 and not self.touchGui then
		self:CreateTouchGuiContainer()
	end

	if self.touchGui then
		self.touchGui.Enabled = v4 and true or false
	end
end

function class:SwitchToController(activeControlModule)
	if activeControlModule then
		if not self.controllers[activeControlModule] then
			self.controllers[activeControlModule] = activeControlModule.new(value)
		end

		if self.activeController ~= self.controllers[activeControlModule] then
			if self.activeController then
				self.activeController:Enable(false)
			end

			self.activeController = self.controllers[activeControlModule]
			self.activeControlModule = activeControlModule

			self:UpdateActiveControlModuleEnabled()
		end
	else
		if self.activeController then
			self.activeController:Enable(false)
		end

		self.activeController = nil
		self.activeControlModule = nil
	end
end

function class:UpdateMovementMode()
	self:UpdateTouchGuiVisibility()

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		local touchModule, v4 = self:SelectTouchModule()

		if v4 and self.touchControlFrame then
			self:SwitchToController(touchModule)
		end
	else
		self:SwitchToController((self:SelectComputerMovementModule()))
	end
end

function class:CreateTouchGuiContainer()
	if not self.playerGui then
		return
	end

	if self.touchGui then
		self.touchGui:Destroy()
	end

	self.touchGui = Instance.new("ScreenGui")
	self.touchGui.Name = "TouchGui"
	self.touchGui.ResetOnSpawn = false
	self.touchGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	if v then
		self.touchGui.ClipToDeviceSafeArea = false
	end

	self.touchControlFrame = Instance.new("Frame")
	self.touchControlFrame.Name = "TouchControlFrame"
	self.touchControlFrame.Size = UDim2.new(1, 0, 1, 0)
	self.touchControlFrame.BackgroundTransparency = 1
	self.touchControlFrame.Parent = self.touchGui

	self.touchGui.Parent = self.playerGui
end

function class:GetClickToMoveController()
	if not self.controllers[ClickToMoveController] then
		self.controllers[ClickToMoveController] = ClickToMoveController.new(value)
	end

	return self.controllers[ClickToMoveController]
end

return class.new()