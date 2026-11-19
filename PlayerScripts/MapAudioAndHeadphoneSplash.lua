local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local AudioSpatialMode = require(ReplicatedStorage.Modules:WaitForChild("AudioSpatialMode"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function onCharacterAdded() -- 1 equivalent call inferred from this helper
	AudioSpatialMode.SetMode(AudioSpatialMode.MODE_MONO)
end

local function onCharacterRemoving()
	AudioSpatialMode.SetMode(AudioSpatialMode.MODE_3D)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)

if LocalPlayer.Character then
	onCharacterAdded() -- inferred equivalent call
end

local color = Color3.fromRGB(22, 22, 26)
local color2 = Color3.fromRGB(245, 245, 247)

local flag = false

local function showHeadphoneSplash()
	if flag then
		return
	end

	flag = true

	local headphoneRecommendationSplash = Instance.new("ScreenGui")
	headphoneRecommendationSplash.Name = "HeadphoneRecommendationSplash"
	headphoneRecommendationSplash.ResetOnSpawn = false
	headphoneRecommendationSplash.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	headphoneRecommendationSplash.DisplayOrder = 200
	headphoneRecommendationSplash.IgnoreGuiInset = true
	headphoneRecommendationSplash.Parent = PlayerGui

	local headphoneSplashBlur = Instance.new("BlurEffect")
	headphoneSplashBlur.Name = "HeadphoneSplashBlur"
	headphoneSplashBlur.Size = 0
	headphoneSplashBlur.Parent = Lighting

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = color
	backdrop.BackgroundTransparency = 1
	backdrop.ZIndex = 1
	backdrop.Parent = headphoneRecommendationSplash

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.AnchorPoint = Vector2.new(0.5, 0.5)
	content.Position = UDim2.new(0.5, 0, 0.5, 0)
	content.Size = UDim2.new(0, 420, 0, 160)
	content.BackgroundTransparency = 1
	content.ZIndex = 2
	content.Parent = backdrop

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 18)
	uiListLayout.Parent = content

	local headsetIcon = Instance.new("ImageLabel")
	headsetIcon.Name = "HeadsetIcon"
	headsetIcon.BackgroundTransparency = 1
	headsetIcon.Size = UDim2.new(0, 84, 0, 84)
	headsetIcon.Image = "rbxassetid://85687320224063"
	headsetIcon.ImageColor3 = color2
	headsetIcon.ImageTransparency = 1
	headsetIcon.ZIndex = 2
	headsetIcon.LayoutOrder = 1
	headsetIcon.Parent = content

	local splashText = Instance.new("TextLabel")
	splashText.Name = "SplashText"
	splashText.BackgroundTransparency = 1
	splashText.Size = UDim2.new(1, 0, 0, 34)
	splashText.Font = Enum.Font.GothamMedium
	splashText.TextSize = 22
	splashText.TextColor3 = color2
	splashText.TextTransparency = 1
	splashText.Text = "We recommend using headphones"
	splashText.TextWrapped = true
	splashText.ZIndex = 2
	splashText.LayoutOrder = 2
	splashText.Parent = content

	local flag2 = false

	local function dismiss()
		if flag2 then
			return
		end

		flag2 = true

		TweenService:Create(backdrop, TweenInfo.new(0.45), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(headsetIcon, TweenInfo.new(0.45), { ImageTransparency = 1 }):Play()
		TweenService:Create(splashText, TweenInfo.new(0.45), { TextTransparency = 1 }):Play()
		TweenService:Create(headphoneSplashBlur, TweenInfo.new(0.45), { Size = 0 }):Play()

		task.delay(0.45, function()
			headphoneRecommendationSplash:Destroy()
			headphoneSplashBlur:Destroy()
		end)
	end

	backdrop.MouseButton1Click:Connect(dismiss)

	TweenService:Create(backdrop, TweenInfo.new(0.35), { BackgroundTransparency = 0.32 }):Play()
	TweenService:Create(headsetIcon, TweenInfo.new(0.35), { ImageTransparency = 0 }):Play()
	TweenService:Create(splashText, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
	TweenService:Create(headphoneSplashBlur, TweenInfo.new(0.35), { Size = 24 }):Play()

	task.delay(3.5500000000000003, dismiss)
end

if not LocalPlayer.Character then
	LocalPlayer.CharacterAdded:Wait()
end

showHeadphoneSplash()