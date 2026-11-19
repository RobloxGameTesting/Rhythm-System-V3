local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(255, 70, 70)
local color2 = Color3.fromRGB(0, 0, 0)

local function getTopbarInsetHeight()
	local success, result = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v = not (success and result) and 0 or result.Y

	return v <= 0 and 36 or v
end

local highPingWarningToastGui = Instance.new("ScreenGui")
highPingWarningToastGui.Name = "HighPingWarningToastGui"
highPingWarningToastGui.ResetOnSpawn = false
highPingWarningToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
highPingWarningToastGui.DisplayOrder = 100
highPingWarningToastGui.IgnoreGuiInset = true
highPingWarningToastGui.Parent = PlayerGui

local highPingToast = Instance.new("CanvasGroup")
highPingToast.Name = "HighPingToast"
highPingToast.AnchorPoint = Vector2.new(0.5, 0.5)
local success, result = pcall(function()
	return GuiService:GetGuiInset()
end)

local v = not (success and result) and 0 or result.Y

highPingToast.Position = UDim2.new(0.5, 0, 0, (v <= 0 and 36 or v) / 2)
highPingToast.AutomaticSize = Enum.AutomaticSize.X
highPingToast.Size = UDim2.new(0, 0, 0, 24)
highPingToast.BackgroundTransparency = 1
highPingToast.BorderSizePixel = 0
highPingToast.GroupTransparency = 1
highPingToast.Visible = false
highPingToast.ZIndex = StyledTheme.ZIndex.Toast
highPingToast.Parent = highPingWarningToastGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = highPingToast

local label = Instance.new("TextLabel")
label.Name = "Label"
label.BackgroundTransparency = 1
label.AutomaticSize = Enum.AutomaticSize.X
label.Size = UDim2.new(0, 0, 1, 0)
label.Font = StyledTheme.Fonts.Bold
label.TextSize = 15
label.TextColor3 = color
label.TextStrokeColor3 = color2
label.TextStrokeTransparency = 0.75
label.TextTransparency = 0.5
label.Text = ""
label.ZIndex = StyledTheme.ZIndex.Toast + 1
label.Parent = highPingToast

task.spawn(function()
	task.wait(1)
	local success2, result2 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v2 = not (success2 and result2) and 0 or result2.Y

	highPingToast.Position = UDim2.new(0.5, 0, 0, (v2 <= 0 and 36 or v2) / 2)
end)

local flag = false

local function formatPingText(p) -- 2 equivalent calls inferred from this helper
	return string.format("High ping : %dms", (math.floor(p)))
end

local function showToast(p)
	label.Text = formatPingText(p) -- inferred equivalent call

	if flag then
		return
	end

	flag = true
	highPingToast.Visible = true
	highPingToast.GroupTransparency = 0
	uiScale.Scale = 0.75
	TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function hideToast()
	if not flag then
		return
	end

	flag = false
	local tween = TweenService:Create(
		highPingToast,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ GroupTransparency = 1 }
	)

	tween.Completed:Connect(function()
		if not flag then
			highPingToast.Visible = false
		end
	end)
	tween:Play()
end

task.spawn(function()
	while true do
		local success2, result2 = pcall(function()
			return LocalPlayer:GetNetworkPing()
		end)

		if success2 and typeof(result2) == "number" then
			local v2 = result2 * 1000

			if v2 >= 300 then
				showToast(v2)
			elseif v2 <= 220 then
				hideToast()
			elseif flag then
				label.Text = formatPingText(v2) -- inferred equivalent call
			end
		end

		task.wait(1)
	end
end)