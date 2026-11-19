local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ServerRestartAlert = RemoteEvents:WaitForChild("ServerRestartAlert")
local GetServerRestartAlertState = RemoteEvents:WaitForChild("GetServerRestartAlertState")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(8, 8, 10)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(255, 96, 74)
local color4 = Color3.fromRGB(230, 222, 200)
local color5 = Color3.fromRGB(255, 255, 255)
local color6 = Color3.fromRGB(10, 10, 12)

local serverRestartAlertGui = nil
local serverRestartAlertBlur = nil
local backdrop = nil
local countdownLabel = nil
local waitingLabel = nil
local waitingSubLabel = nil
local preNoticePill = nil
local preNoticeLabel = nil
local toastPill = nil
local toastLabel = nil
local v2 = nil
local flag = false
local v3 = false
local v4 = false
local count = 0

local function formatMMSS(p) -- 1 equivalent call inferred from this helper
	local v5 = math.floor(p / 60)
	local v6 = p % 60
	return string.format("%d:%02d", v5, v6)
end

local function syncScreenGuiEnabled() -- 7 equivalent calls inferred from this helper
	serverRestartAlertGui.Enabled = flag or v3 or v4
end

local function build()
	if serverRestartAlertGui then
		return
	end

	serverRestartAlertGui = Instance.new("ScreenGui")
	serverRestartAlertGui.Name = "ServerRestartAlertGui"
	serverRestartAlertGui.ResetOnSpawn = false
	serverRestartAlertGui.IgnoreGuiInset = true
	serverRestartAlertGui.DisplayOrder = 500
	serverRestartAlertGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	serverRestartAlertGui.Enabled = false
	serverRestartAlertGui.Parent = PlayerGui

	serverRestartAlertBlur = Instance.new("BlurEffect")
	serverRestartAlertBlur.Name = "ServerRestartAlertBlur"
	serverRestartAlertBlur.Size = 0
	serverRestartAlertBlur.Parent = Lighting

	backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = color
	backdrop.BackgroundTransparency = 1
	backdrop.ZIndex = 1
	backdrop.Parent = serverRestartAlertGui

	countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	countdownLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	countdownLabel.Size = UDim2.new(v and 0.9 or 0.78, 0, 0, 0)
	countdownLabel.AutomaticSize = Enum.AutomaticSize.Y
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.Font = Enum.Font.GothamBlack
	countdownLabel.TextSize = v and 26 or 40
	countdownLabel.TextWrapped = true
	countdownLabel.TextColor3 = color2
	countdownLabel.TextTransparency = 1
	countdownLabel.Text = ""
	countdownLabel.Visible = false
	countdownLabel.ZIndex = 2
	countdownLabel.Parent = backdrop

	local punchScale = Instance.new("UIScale")
	punchScale.Name = "PunchScale"
	punchScale.Scale = 1
	punchScale.Parent = countdownLabel

	waitingLabel = Instance.new("TextLabel")
	waitingLabel.Name = "WaitingLabel"
	waitingLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	waitingLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	waitingLabel.Size = UDim2.new(0.7, 0, 0, v and 46 or 60)
	waitingLabel.BackgroundTransparency = 1
	waitingLabel.Font = Enum.Font.GothamBold
	waitingLabel.TextSize = v and 24 or 34
	waitingLabel.TextColor3 = color4
	waitingLabel.TextTransparency = 1
	waitingLabel.Text = "WAITING"
	waitingLabel.Visible = false
	waitingLabel.ZIndex = 2
	waitingLabel.Parent = backdrop

	local pulseScale = Instance.new("UIScale")
	pulseScale.Name = "PulseScale"
	pulseScale.Scale = 1
	pulseScale.Parent = waitingLabel

	waitingSubLabel = Instance.new("TextLabel")
	waitingSubLabel.Name = "WaitingSubLabel"
	waitingSubLabel.AnchorPoint = Vector2.new(0.5, 0)
	waitingSubLabel.Position = UDim2.new(0.5, 0, 0.5, v and 30 or 40)
	waitingSubLabel.Size = UDim2.new(0.8, 0, 0, 0)
	waitingSubLabel.AutomaticSize = Enum.AutomaticSize.Y
	waitingSubLabel.BackgroundTransparency = 1
	waitingSubLabel.Font = Enum.Font.GothamMedium
	waitingSubLabel.TextSize = v and 15 or 19
	waitingSubLabel.TextWrapped = true
	waitingSubLabel.TextColor3 = Color3.fromRGB(190, 184, 168)
	waitingSubLabel.TextTransparency = 1
	waitingSubLabel.Text = "Server is restarting. Hang tight, this only takes a moment!"
	waitingSubLabel.Visible = false
	waitingSubLabel.ZIndex = 2
	waitingSubLabel.Parent = backdrop

	preNoticePill = Instance.new("Frame")
	preNoticePill.Name = "PreNoticePill"
	preNoticePill.AnchorPoint = Vector2.new(0.5, 0)
	preNoticePill.Position = UDim2.new(0.5, 0, 0, 58)
	preNoticePill.Size = UDim2.new(0, v and 220 or 260, 0, v and 30 or 34)
	preNoticePill.BackgroundColor3 = color6
	preNoticePill.BackgroundTransparency = 0.25
	preNoticePill.Visible = false
	preNoticePill.ZIndex = 3
	preNoticePill.Parent = serverRestartAlertGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = preNoticePill

	preNoticeLabel = Instance.new("TextLabel")
	preNoticeLabel.Name = "PreNoticeLabel"
	preNoticeLabel.Size = UDim2.new(1, 0, 1, 0)
	preNoticeLabel.BackgroundTransparency = 1
	preNoticeLabel.Font = Enum.Font.GothamMedium
	preNoticeLabel.TextSize = v and 15 or 17
	preNoticeLabel.TextColor3 = color5
	preNoticeLabel.Text = ""
	preNoticeLabel.ZIndex = 4
	preNoticeLabel.Parent = preNoticePill

	toastPill = Instance.new("Frame")
	toastPill.Name = "ToastPill"
	toastPill.AnchorPoint = Vector2.new(0.5, 0)
	toastPill.Position = UDim2.new(0.5, 0, 0, 58)
	toastPill.Size = UDim2.new(0, v and 240 or 290, 0, v and 36 or 42)
	toastPill.BackgroundColor3 = color6
	toastPill.BackgroundTransparency = 1
	toastPill.Visible = false
	toastPill.ZIndex = 5
	toastPill.Parent = serverRestartAlertGui

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(1, 0)
	uiCorner2.Parent = toastPill

	toastLabel = Instance.new("TextLabel")
	toastLabel.Name = "ToastLabel"
	toastLabel.Size = UDim2.new(1, 0, 1, 0)
	toastLabel.BackgroundTransparency = 1
	toastLabel.Font = Enum.Font.GothamBold
	toastLabel.TextSize = v and 15 or 18
	toastLabel.TextColor3 = color5
	toastLabel.TextTransparency = 1
	toastLabel.Text = ""
	toastLabel.ZIndex = 6
	toastLabel.Parent = toastPill
end

local function stopPulse() -- 3 equivalent calls inferred from this helper
	if v2 then
		v2:Cancel()
		v2 = nil
	end
end

local function hideToastNow() -- 3 equivalent calls inferred from this helper
	if not v4 then
		return
	end

	count += 1
	v4 = false
	toastPill.Visible = false
	syncScreenGuiEnabled() -- inferred equivalent call
end

local function hidePreNotice() -- 3 equivalent calls inferred from this helper
	if not v3 then
		return
	end

	v3 = false

	if preNoticePill then
		preNoticePill.Visible = false
	end

	syncScreenGuiEnabled() -- inferred equivalent call
end

local function showPreNotice(seconds) -- 1 equivalent call inferred from this helper
	build()
	hideToastNow() -- inferred equivalent call
	v3 = true
	syncScreenGuiEnabled() -- inferred equivalent call
	preNoticePill.Visible = true
	preNoticeLabel.Text = "SERVER RESTART IN: " .. formatMMSS(seconds) -- inferred equivalent call
end

local function showBackdrop()
	if flag then
		return
	end

	flag = true
	syncScreenGuiEnabled() -- inferred equivalent call
	TweenService:Create(backdrop, TweenInfo.new(0.35), { BackgroundTransparency = 0.25 }):Play()
	TweenService:Create(serverRestartAlertBlur, TweenInfo.new(0.35), { Size = 28 }):Play()
end

local function hideBackdrop()
	hidePreNotice() -- inferred equivalent call

	if not flag then
		return
	end

	flag = false
	stopPulse() -- inferred equivalent call
	TweenService:Create(backdrop, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(serverRestartAlertBlur, TweenInfo.new(0.35), { Size = 0 }):Play()
	TweenService:Create(countdownLabel, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
	TweenService:Create(waitingLabel, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
	TweenService:Create(waitingSubLabel, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()

	task.delay(0.35, function()
		if not flag then
			syncScreenGuiEnabled() -- inferred equivalent call
			countdownLabel.Visible = false
			waitingLabel.Visible = false
			waitingSubLabel.Visible = false
		end
	end)
end

local function showCountdown(seconds, adminName)
	build()
	stopPulse() -- inferred equivalent call
	hidePreNotice() -- inferred equivalent call
	hideToastNow() -- inferred equivalent call
	showBackdrop()

	waitingLabel.Visible = false
	waitingLabel.TextTransparency = 1
	waitingSubLabel.Visible = false
	waitingSubLabel.TextTransparency = 1

	countdownLabel.Visible = true
	countdownLabel.Text = string.format("SERVER RESTARTING BY @%s IN: %d", adminName or "Developer", seconds)

	TweenService:Create(countdownLabel, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()

	local textColor = seconds <= 3 and color3 or color2
	TweenService:Create(countdownLabel, TweenInfo.new(0.35), { TextColor3 = textColor }):Play()

	local punchScale = countdownLabel:FindFirstChild("PunchScale")
	punchScale.Scale = 1
	local tween = TweenService:Create(
		punchScale,
		TweenInfo.new(0.077, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = 1.15 }
	)
	tween.Completed:Connect(function(p)
		if p == Enum.PlaybackState.Completed then
			TweenService:Create(
				punchScale,
				TweenInfo.new(0.14300000000000002, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Scale = 1 }
			):Play()
		end
	end)
	tween:Play()
end

local function showWaiting()
	build()
	hidePreNotice() -- inferred equivalent call
	hideToastNow() -- inferred equivalent call
	showBackdrop()

	countdownLabel.Visible = false
	countdownLabel.TextTransparency = 1

	waitingLabel.Visible = true
	waitingSubLabel.Visible = true
	TweenService:Create(waitingSubLabel, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
	TweenService:Create(waitingLabel, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()

	local pulseScale = waitingLabel:FindFirstChild("PulseScale")
	pulseScale.Scale = 1
	stopPulse() -- inferred equivalent call
	v2 = TweenService:Create(
		pulseScale,
		TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Scale = 1.06 }
	)
	v2:Play()
end

local function showToast(text)
	build()
	count += 1
	local v5 = count

	v4 = true
	syncScreenGuiEnabled() -- inferred equivalent call
	local udim = UDim2.new(0.5, 0, 0, 58)
	local udim2 = UDim2.new(0.5, 0, 0, 46)

	toastLabel.Text = text
	toastPill.Visible = true
	toastPill.Position = udim2
	toastPill.BackgroundTransparency = 1
	toastLabel.TextTransparency = 1

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(toastPill, tweenInfo, { Position = udim, BackgroundTransparency = 0.15 }):Play()
	TweenService:Create(toastLabel, tweenInfo, { TextTransparency = 0 }):Play()

	task.delay(3, function()
		if v5 ~= count then
			return
		end

		local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(toastPill, tweenInfo2, { Position = udim2, BackgroundTransparency = 1 }):Play()
		TweenService:Create(toastLabel, tweenInfo2, { TextTransparency = 1 }):Play()

		task.delay(0.35, function()
			if v5 ~= count then
				return
			end

			v4 = false
			toastPill.Visible = false
			syncScreenGuiEnabled() -- inferred equivalent call
		end)
	end)
end

local function onAlert(result)
	if typeof(result) ~= "table" then
		return
	end

	if result.State == "PreNotice" and typeof(result.Seconds) == "number" then
		showPreNotice(result.Seconds) -- inferred equivalent call
	elseif result.State == "Countdown" and typeof(result.Seconds) == "number" then
		showCountdown(result.Seconds, result.AdminName)
	elseif result.State == "Waiting" then
		showWaiting()
	elseif result.State == "RestartCancelled" then
		hideBackdrop()
		showToast("Restart server cancelled")
	elseif result.State == "Cancelled" then
		hideBackdrop()
	end
end

ServerRestartAlert.OnClientEvent:Connect(onAlert)

task.spawn(function()
	local success, result = pcall(function()
		return GetServerRestartAlertState:InvokeServer()
	end)

	if success and typeof(result) == "table" then
		onAlert(result)
	end
end)