game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

UserSettings():GetService("UserGameSettings")

local CommonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(CommonUtils:WaitForChild("FlagUtil"))
local userFlag = FlagUtil.getUserFlag("UserAllowAbilityControls")
local AvatarAbilitiesInterface

if userFlag then
	AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
else
	AvatarAbilitiesInterface = nil
end

local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object
function object.new()
	local self = setmetatable(BaseCharacterController.new(), object)

	self.isFollowStick = false

	self.thumbstickFrame = nil
	self.moveTouchObject = nil
	self.onTouchMovedConn = nil
	self.onTouchEndedConn = nil
	self.screenPos = nil
	self.stickImage = nil
	self.thumbstickSize = nil

	return self
end

function object:Enable(flag: boolean?, p)
	if flag == nil then
		return false
	end

	local enabled = flag and true or false

	if self.enabled == enabled then
		return true
	end

	self.moveVector = Vector3.new(0, 0, 0)
	self.isJumping = false

	if enabled then
		if not self.thumbstickFrame then
			self:Create(p)
		end

		self.thumbstickFrame.Visible = true
	else
		self.thumbstickFrame.Visible = false
		self:OnInputEnded()
	end

	self.enabled = enabled
end
function object:OnInputEnded()
	self.thumbstickFrame.Position = self.screenPos
	self.stickImage.Position = UDim2.new(
		0,
		self.thumbstickFrame.Size.X.Offset / 2 - self.thumbstickSize / 4,
		0,
		self.thumbstickFrame.Size.Y.Offset / 2 - self.thumbstickSize / 4
	)

	self.moveVector = Vector3.new(0, 0, 0)
	self.isJumping = false
	self.thumbstickFrame.Position = self.screenPos
	self.moveTouchObject = nil
end
function object:Create(parent)
	if self.thumbstickFrame then
		self.thumbstickFrame:Destroy()
		self.thumbstickFrame = nil

		if self.onTouchMovedConn then
			self.onTouchMovedConn:Disconnect()
			self.onTouchMovedConn = nil
		end

		if self.onTouchEndedConn then
			self.onTouchEndedConn:Disconnect()
			self.onTouchEndedConn = nil
		end

		if self.absoluteSizeChangedConn then
			self.absoluteSizeChangedConn:Disconnect()
			self.absoluteSizeChangedConn = nil
		end

		if userFlag and self.avatarAbilitiesEnabledChangedConn then
			self.avatarAbilitiesEnabledChangedConn:Disconnect()
			self.avatarAbilitiesEnabledChangedConn = nil
		end
	end

	self.thumbstickFrame = Instance.new("Frame")
	self.thumbstickFrame.Name = "ThumbstickFrame"
	self.thumbstickFrame.Active = true
	self.thumbstickFrame.Visible = false
	self.thumbstickFrame.BackgroundTransparency = 1

	local outerImage = Instance.new("ImageLabel")
	outerImage.Name = "OuterImage"
	outerImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	outerImage.ImageRectOffset = Vector2.new()
	outerImage.ImageRectSize = Vector2.new(220, 220)
	outerImage.BackgroundTransparency = 1
	outerImage.Position = UDim2.new(0, 0, 0, 0)

	self.stickImage = Instance.new("ImageLabel")
	self.stickImage.Name = "StickImage"
	self.stickImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
	self.stickImage.ImageRectOffset = Vector2.new(220, 0)
	self.stickImage.ImageRectSize = Vector2.new(111, 111)
	self.stickImage.BackgroundTransparency = 1
	self.stickImage.ZIndex = 2

	local function ResizeThumbstick()
		local v = math.min(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) <= 500

		if userFlag and AvatarAbilitiesInterface.isEnabled() then
			self.thumbstickSize = v and 72 or 120
			self.screenPos = UDim2.new(0, v and 64 or 100, 1, -self.thumbstickSize - (v and 64 or 112))
		else
			self.thumbstickSize = v and 70 or 120
			self.screenPos = v and UDim2.new(0, self.thumbstickSize / 2 - 10, 1, -self.thumbstickSize - 20)
				or UDim2.new(0, self.thumbstickSize / 2, 1, -self.thumbstickSize * 1.75)
		end

		self.thumbstickFrame.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.thumbstickFrame.Position = self.screenPos
		outerImage.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.stickImage.Size = UDim2.new(0, self.thumbstickSize / 2, 0, self.thumbstickSize / 2)
		self.stickImage.Position = UDim2.new(
			0,
			self.thumbstickSize / 2 - self.thumbstickSize / 4,
			0,
			self.thumbstickSize / 2 - self.thumbstickSize / 4
		)
	end

	ResizeThumbstick()
	self.absoluteSizeChangedConn = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeThumbstick)

	if userFlag then
		self.avatarAbilitiesEnabledChangedConn = AvatarAbilitiesInterface.GetEnabledChangedSignal():Connect(ResizeThumbstick)
	end

	outerImage.Parent = self.thumbstickFrame
	self.stickImage.Parent = self.thumbstickFrame

	local vector2 = nil

	local function DoMove(vector2_2: Vector2) -- 1 equivalent call inferred from this helper
		local v = vector2_2 / (self.thumbstickSize / 2)

		local magnitude = v.magnitude
		local vector3

		if magnitude < 0.05 then
			vector3 = Vector3.new()
		else
			local v2 = v.unit * math.min(1, (magnitude - 0.05) / 0.95)

			vector3 = Vector3.new(v2.X, 0, v2.Y)
		end

		self.moveVector = vector3
	end

	local function MoveStick(position: Vector3)
		local v = Vector2.new(position.X - vector2.X, position.Y - vector2.Y)
		local magnitude = v.magnitude
		local v2 = self.thumbstickFrame.AbsoluteSize.X / 2

		if self.isFollowStick and v2 < magnitude then
			local v3 = v.unit * v2
			self.thumbstickFrame.Position = UDim2.new(
				0,
				position.X - self.thumbstickFrame.AbsoluteSize.X / 2 - v3.X,
				0,
				position.Y - self.thumbstickFrame.AbsoluteSize.Y / 2 - v3.Y
			)
		else
			local v3 = math.min(magnitude, v2)
			v = v.unit * v3
		end

		self.stickImage.Position = UDim2.new(
			0,
			v.X + self.stickImage.AbsoluteSize.X / 2,
			0,
			v.Y + self.stickImage.AbsoluteSize.Y / 2
		)
	end

	self.thumbstickFrame.InputBegan:Connect(function(input)
		if
			self.moveTouchObject
			or input.UserInputType ~= Enum.UserInputType.Touch
			or input.UserInputState ~= Enum.UserInputState.Begin
		then
			return
		end

		self.moveTouchObject = input
		self.thumbstickFrame.Position = UDim2.new(
			0,
			input.Position.X - self.thumbstickFrame.Size.X.Offset / 2,
			0,
			input.Position.Y - self.thumbstickFrame.Size.Y.Offset / 2
		)
		vector2 = Vector2.new(
			self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
			self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
		)
		Vector2.new(input.Position.X - vector2.X, input.Position.Y - vector2.Y)
	end)

	self.onTouchMovedConn = UserInputService.TouchMoved:Connect(function(p, _: boolean)
		if p == self.moveTouchObject then
			vector2 = Vector2.new(
				self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2,
				self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2
			)
			DoMove(Vector2.new(p.Position.X - vector2.X, p.Position.Y - vector2.Y)) -- inferred equivalent call

			MoveStick(p.Position)
		end
	end)

	self.onTouchEndedConn = UserInputService.TouchEnded:Connect(function(otherPart, _)
		if otherPart == self.moveTouchObject then
			self:OnInputEnded()
		end
	end)

	GuiService.MenuOpened:Connect(function()
		if self.moveTouchObject then
			self:OnInputEnded()
		end
	end)

	self.thumbstickFrame.Parent = parent
end
return object