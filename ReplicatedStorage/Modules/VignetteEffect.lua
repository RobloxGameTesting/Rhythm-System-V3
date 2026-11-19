local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local vignetteEffect = nil
local v = {}
local count = 0

local function makeStrip(name, size, position, rotation)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 50
	frame.Parent = vignetteEffect

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = rotation
	uiGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

	uiGradient.Parent = frame

	return frame
end

local function build()
	if vignetteEffect then
		return
	end

	vignetteEffect = Instance.new("ScreenGui")
	vignetteEffect.Name = "VignetteEffect"
	vignetteEffect.ResetOnSpawn = false
	vignetteEffect.IgnoreGuiInset = true

	local UserInputService = game:GetService("UserInputService")

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		pcall(function()
			vignetteEffect.ScreenInsets = Enum.ScreenInsets.None
		end)
	end

	vignetteEffect.DisplayOrder = 90
	vignetteEffect.Parent = PlayerGui

	v.Top = makeStrip("Top", UDim2.new(1, 0, 0.18, 0), UDim2.new(0, 0, 0, 0), 90)
	v.Bottom = makeStrip("Bottom", UDim2.new(1, 0, 0.18, 0), UDim2.new(0, 0, 0.8200000000000001, 0), -90)
	v.Left = makeStrip("Left", UDim2.new(0.12, 0, 1, 0), UDim2.new(0, 0, 0, 0), 0)
	v.Right = makeStrip("Right", UDim2.new(0.12, 0, 1, 0), UDim2.new(0.88, 0, 0, 0), 180)
end

return {
	Flash = function(backgroundColor)
		build()

		count += 1
		local v2 = count

		for _, v3 in pairs(v) do
			v3.BackgroundColor3 = backgroundColor
		end

		for _, instance in pairs(v) do
			TweenService:Create(instance, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.25
			}):Play()
		end

		task.delay(0.14, function()
			if v2 ~= count then
				return
			end

			for _, instance in pairs(v) do
				TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					BackgroundTransparency = 1
				}):Play()
			end
		end)
	end
}