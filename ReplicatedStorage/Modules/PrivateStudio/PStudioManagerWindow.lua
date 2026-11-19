local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LaptopStudioPanel = require(ReplicatedStorage.Modules.LaptopUI.LaptopStudioPanel)
local PStudioState = require(script.Parent.PStudioState)

local PStudioManagerWindow = {}

local pStudioManagerGui = nil
local window = nil
local uiScale = nil
local v = nil
local v2 = nil

local function fitScale() -- 2 equivalent calls inferred from this helper
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	uiScale.Scale = math.clamp(math.min(viewportSize.X * 0.85 / 334, viewportSize.Y * 0.8 / 230), 0.8, 1.7)
end

local function ensure()
	if pStudioManagerGui then
		return
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	pStudioManagerGui = Instance.new("ScreenGui")
	pStudioManagerGui.Name = "PStudioManagerGui"
	pStudioManagerGui.ResetOnSpawn = false
	pStudioManagerGui.DisplayOrder = 45
	pStudioManagerGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	pStudioManagerGui.Parent = playerGui

	window = Instance.new("Frame")
	window.Name = "Window"
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.Size = UDim2.fromOffset(334, 230)
	window.BackgroundColor3 = Color3.new(0, 0, 0)
	window.BorderSizePixel = 0
	window.Visible = false
	window.Active = true
	window.ZIndex = 1
	window:SetAttribute("NoNewUISkin", true)
	window.Parent = pStudioManagerGui

	uiScale = Instance.new("UIScale")
	uiScale.Parent = window
	fitScale() -- inferred equivalent call
	v = { gui = window, studioId = nil, isStudioWindow = true }
	v2 = LaptopStudioPanel.Build(v, window, { windowMode = true })

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.AutoButtonColor = true
	close.BackgroundColor3 = Color3.fromRGB(170, 60, 55)
	close.BorderSizePixel = 0
	close.Text = "X"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 11
	close.TextColor3 = Color3.fromRGB(245, 245, 247)
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -4, 0, 4)
	close.Size = UDim2.fromOffset(20, 18)
	close.ZIndex = 100
	close.Parent = window
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 4)
	uiCorner.Parent = close
	close.Activated:Connect(function()
		PStudioManagerWindow.Close()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and window.Visible and input.KeyCode == Enum.KeyCode.Backspace then
			PStudioManagerWindow.Close()
		end
	end)

	PStudioState.Changed:Connect(function(p)
		if p == nil then
			PStudioManagerWindow.Close()
		end
	end)
end

function PStudioManagerWindow.IsOpen()
	return window ~= nil and window.Visible
end

function PStudioManagerWindow.Open(): boolean
	if not PStudioState.Get() then
		return false
	end

	ensure()
	fitScale() -- inferred equivalent call
	window.Visible = true
	v2.Visible = true
	LaptopStudioPanel.Enter(v)
	return true
end

function PStudioManagerWindow.Close()
	if not window then
		return
	end

	if window.Visible then
		LaptopStudioPanel.ReleaseFocus(v)
	end

	v2.Visible = false
	window.Visible = false
end

function PStudioManagerWindow.Toggle()
	if not PStudioManagerWindow.IsOpen() then
		return PStudioManagerWindow.Open()
	end

	PStudioManagerWindow.Close()
	return false
end

return PStudioManagerWindow