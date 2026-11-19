local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AfkActivityPing = RemoteEvents:WaitForChild("AfkActivityPing")
local AfkUnequipNotice = RemoteEvents:WaitForChild("AfkUnequipNotice")
local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)

local v = 0
local v2 = false

local function markActive() -- 3 equivalent calls inferred from this helper
	local now = os.clock()

	if not (now - v >= 5) then
		v2 = true

		return
	end

	v = now
	v2 = false
	AfkActivityPing:FireServer()
end

local function isActivityInput(input): boolean
	local userInputType = input.UserInputType

	if userInputType == Enum.UserInputType.Keyboard or userInputType == Enum.UserInputType.Touch then
		return true
	end

	if
		userInputType == Enum.UserInputType.MouseButton1
		or userInputType == Enum.UserInputType.MouseButton2
		or userInputType == Enum.UserInputType.MouseButton3
	then
		return true
	end

	return string.sub(userInputType.Name, 1, 7) == "Gamepad"
end

UserInputService.InputBegan:Connect(function(input)
	if isActivityInput(input) then
		markActive() -- inferred equivalent call
	end
end)

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.5 then
		return
	end

	total = 0
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.MoveDirection.Magnitude > 0 then
		markActive() -- inferred equivalent call
	elseif v2 and os.clock() - v >= 5 then
		markActive() -- inferred equivalent call
	end
end)

local v3 = nil

local function buildToast(value)
	local afkUnequipToastGui = Instance.new("ScreenGui")
	afkUnequipToastGui.Name = "AfkUnequipToastGui"
	afkUnequipToastGui.ResetOnSpawn = false
	afkUnequipToastGui.IgnoreGuiInset = true
	afkUnequipToastGui.DisplayOrder = 60
	afkUnequipToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local notice = Instance.new("CanvasGroup")
	notice.Name = "Notice"
	notice.AnchorPoint = Vector2.new(0.5, 1)
	notice.Position = UDim2.new(0.5, 0, 1, -110)
	notice.AutomaticSize = Enum.AutomaticSize.XY
	notice.Size = UDim2.fromOffset(0, 0)
	notice.BackgroundColor3 = StyledTheme.Colors.Surface
	notice.BackgroundTransparency = 0.15
	notice.BorderSizePixel = 0
	notice.GroupTransparency = 1
	notice.Active = false
	notice.Parent = afkUnequipToastGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = notice

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1.5
	uiStroke.Color = StyledTheme.Colors.Accent or StyledTheme.Colors.Danger
	uiStroke.Parent = notice

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 9)
	uiPadding.PaddingBottom = UDim.new(0, 9)
	uiPadding.PaddingLeft = UDim.new(0, 16)
	uiPadding.PaddingRight = UDim.new(0, 16)
	uiPadding.Parent = notice

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(460, 1e999)
	uiSizeConstraint.Parent = notice

	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.BackgroundTransparency = 1
	message.AutomaticSize = Enum.AutomaticSize.XY
	message.Size = UDim2.fromOffset(0, 0)
	message.Font = StyledTheme.Fonts.Regular
	message.TextSize = 17
	message.TextColor3 = StyledTheme.Colors.TextPrimary or Color3.new(1, 1, 1)
	message.TextWrapped = true
	message.Text = value or "Auto-unequipped due to no activity for 2 minutes."
	message.Active = false
	message.Parent = notice

	return afkUnequipToastGui, notice
end

local count = 0

local function showToast(p)
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	count += 1
	local v4 = count

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	local toast, parent = buildToast(p == "laptop" and "Laptop closed due to no activity for 2 minutes." or "Auto-unequipped due to no activity for 2 minutes.")
	v3 = toast
	toast.Parent = playerGui

	TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 0
	}):Play()
	task.delay(3.65, function()
		if v4 ~= count or not parent.Parent then
			return
		end

		local tween = TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1
		})
		tween:Play()
		tween.Completed:Wait()

		if v4 == count and toast.Parent then
			toast:Destroy()
			v3 = nil
		end
	end)
end

AfkUnequipNotice.OnClientEvent:Connect(showToast)