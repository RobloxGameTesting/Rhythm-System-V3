local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ThemeState = require(Modules:WaitForChild("ThemeState"))
local NoteLaneUI = require(Modules:WaitForChild("NoteLaneUI"))
local NoteLaneUI3D = require(Modules:WaitForChild("NoteLaneUI3D"))
local BandCameraController = require(Modules:WaitForChild("BandCamera"):WaitForChild("BandCameraController"))

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = { "RockMeterUI", "ScoreDisplayUI", "RhythmVibratoHUD" }

local v2 = { "Plate", "Fx" }

local udim = UDim2.new(0, 6, 0.62, 0)

local udim2 = UDim2.fromOffset(74, 18)
local SourceSans = Enum.Font.SourceSans

local color = Color3.fromRGB(190, 188, 182)
local color2 = Color3.fromRGB(204, 162, 72)

local hudToggleUI = Instance.new("ScreenGui")
hudToggleUI.Name = "HudToggleUI"
hudToggleUI.ResetOnSpawn = false
hudToggleUI.DisplayOrder = 125
hudToggleUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hudToggleUI.Parent = PlayerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundTransparency = 1
root.BorderSizePixel = 0
root.Active = false
root.Parent = hudToggleUI

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.AnchorPoint = Vector2.new(0, 0.5)
toggle.Position = udim
toggle.Size = udim2
toggle.BackgroundTransparency = 1
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = false
toggle.Font = SourceSans
toggle.TextSize = 14
toggle.Text = "STATS: SHOW"
toggle.TextXAlignment = Enum.TextXAlignment.Left
toggle.TextColor3 = color2
toggle.TextTransparency = 0.5
toggle.TextStrokeColor3 = Color3.new(0, 0, 0)
toggle.TextStrokeTransparency = 0.85
toggle.Visible = false
toggle.Parent = root

local v3 = false
local v4 = {}
local v5 = false
local v6 = 0
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function refreshLook()
	toggle.Text = v3 and "STATS: HIDE" or "STATS: SHOW"
	toggle.TextColor3 = v3 and color or color2

	local v7 = v5 or os.clock() < v6
	TweenService:Create(toggle, tweenInfo, {
		TextTransparency = v7 and 0 or 0.5,
		TextStrokeTransparency = v7 and 0.5 or 0.85
	}):Play()
end

local function setHidden(hudHidden) -- 1 equivalent call inferred from this helper
	local v7 = hudHidden == true

	if v3 == v7 then
		return
	end

	v3 = v7
	refreshLook()
end

toggle.MouseEnter:Connect(function()
	v5 = true
	refreshLook()
end)
toggle.MouseLeave:Connect(function()
	v5 = false
	refreshLook()
end)
toggle.Activated:Connect(function()
	v6 = os.clock() + 1.2
	task.delay(1.25, refreshLook)
	PlayerGui:SetAttribute("HudHidden", not v3)
end)
PlayerGui:GetAttributeChangedSignal("HudHidden"):Connect(function()
	setHidden(PlayerGui:GetAttribute("HudHidden")) -- inferred equivalent call
end)
v3 = PlayerGui:GetAttribute("HudHidden") == true
refreshLook()

local dynamicCamToggle = Instance.new("TextButton")
dynamicCamToggle.Name = "DynamicCamToggle"
dynamicCamToggle.AnchorPoint = Vector2.new(0, 0)
dynamicCamToggle.Size = udim2
dynamicCamToggle.BackgroundTransparency = 1
dynamicCamToggle.BorderSizePixel = 0
dynamicCamToggle.AutoButtonColor = false
dynamicCamToggle.Font = SourceSans
dynamicCamToggle.TextSize = 14
dynamicCamToggle.Text = "CAM: OFF"
dynamicCamToggle.TextXAlignment = Enum.TextXAlignment.Left
dynamicCamToggle.TextColor3 = color
dynamicCamToggle.TextTransparency = 0.5
dynamicCamToggle.TextStrokeColor3 = Color3.new(0, 0, 0)
dynamicCamToggle.TextStrokeTransparency = 0.85
dynamicCamToggle.Visible = false
dynamicCamToggle.Parent = root

local v7 = false
local v8 = 0
local v9 = {}

local function textWidth(text) -- 2 equivalent calls inferred from this helper
	local v10 = v9[text]

	if not v10 then
		v10 = TextService:GetTextSize(text, 14, SourceSans, Vector2.new(1000, 100)).X
		v9[text] = v10
	end

	return v10
end

local function refreshCamLook()
	local playerOn = BandCameraController.GetUIState().playerOn == true
	dynamicCamToggle.Text = playerOn and "CAM: ON" or "CAM: OFF"
	dynamicCamToggle.TextColor3 = playerOn and color2 or color

	local v10 = v7 or os.clock() < v8
	TweenService:Create(dynamicCamToggle, tweenInfo, {
		TextTransparency = v10 and 0 or 0.5,
		TextStrokeTransparency = v10 and 0.5 or 0.85
	}):Play()
end

dynamicCamToggle.MouseEnter:Connect(function()
	v7 = true
	refreshCamLook()
end)
dynamicCamToggle.MouseLeave:Connect(function()
	v7 = false
	refreshCamLook()
end)
dynamicCamToggle.Activated:Connect(function()
	v8 = os.clock() + 1.2
	task.delay(1.25, refreshCamLook)
	local uiState = BandCameraController.GetUIState()
	BandCameraController.SetPlayerEnabled(not uiState.playerOn)
	refreshCamLook()
end)
BandCameraController.OnChanged(refreshCamLook)
refreshCamLook()

local function updateCamButton(noteLaneVisible)
	local uiState = BandCameraController.GetUIState()

	if noteLaneVisible then
		if uiState.inSession == true then
			noteLaneVisible = uiState.inZone == true
		else
			noteLaneVisible = false
		end
	end

	if dynamicCamToggle.Visible ~= noteLaneVisible then
		dynamicCamToggle.Visible = noteLaneVisible
	end

	if not noteLaneVisible then
		return
	end

	local offset = udim2.X.Offset
	local v10 = textWidth(toggle.Text) -- inferred equivalent call
	local absolutePosition = root.AbsolutePosition
	local v11 = toggle.AbsolutePosition - absolutePosition
	local x = v11.X

	if toggle.TextXAlignment == Enum.TextXAlignment.Center then
		x += (offset - v10) / 2
	end

	local v12 = math.ceil(textWidth(dynamicCamToggle.Text)) + 6 -- inferred equivalent call
	dynamicCamToggle.Size = UDim2.fromOffset(v12, udim2.Y.Offset)
	dynamicCamToggle.Position = UDim2.fromOffset(math.floor(x + v10 + 14 + 0.5), (math.floor(v11.Y + 0.5)))
end

local function isNoteLaneVisible() -- 1 equivalent call inferred from this helper
	return (ThemeState.Get() == "3D" and NoteLaneUI3D or NoteLaneUI).IsVisible()
end

local function getHintBarAnchor()
	local instrumentHUD = PlayerGui:FindFirstChild("InstrumentHUD")

	if not (instrumentHUD and instrumentHUD:IsA("ScreenGui") and instrumentHUD.Enabled) then
		return nil
	end

	local container = instrumentHUD:FindFirstChild("Container")

	if container and container:IsA("GuiObject") and container.Visible and not (container.AbsoluteSize.X <= 0) then
		return container.AbsolutePosition.X, container.AbsolutePosition.Y
	end

	return nil
end

local function getGreenHitAnchor()
	if ThemeState.Get() == "3D" then
		return nil
	end

	local hitContainer = NoteLaneUI.GetHitContainer(1)

	if not hitContainer or not hitContainer.Parent or hitContainer.AbsoluteSize.X <= 0 then
		return nil
	end

	local v10 = hitContainer.AbsolutePosition.Y + hitContainer.AbsoluteSize.Y
	local laneNameLabel = hitContainer:FindFirstChild("LaneNameLabel")

	if
		laneNameLabel
		and laneNameLabel:IsA("GuiObject")
		and laneNameLabel.Visible
		and laneNameLabel.AbsoluteSize.Y > 0
		and (not (laneNameLabel:IsA("TextLabel") or laneNameLabel:IsA("TextButton")) or laneNameLabel.Text ~= "" and laneNameLabel.TextTransparency < 1)
	then
		v10 = math.max(v10, laneNameLabel.AbsolutePosition.Y + laneNameLabel.AbsoluteSize.Y)
	end

	return hitContainer.AbsolutePosition.X + hitContainer.AbsoluteSize.X / 2, v10
end

local v10 = nil

local function applyMode(p) -- 3 equivalent calls inferred from this helper
	if v10 == p then
		return
	end

	v10 = p

	if p == "hint" then
		toggle.AnchorPoint = Vector2.new(0, 1)
		toggle.TextXAlignment = Enum.TextXAlignment.Left
	elseif p == "hit" then
		toggle.AnchorPoint = Vector2.new(0.5, 0)
		toggle.TextXAlignment = Enum.TextXAlignment.Center
	else
		toggle.AnchorPoint = Vector2.new(0, 0.5)
		toggle.Position = udim
		toggle.TextXAlignment = Enum.TextXAlignment.Left
	end
end

local function updatePosition()
	local absolutePosition = root.AbsolutePosition
	local absoluteSize = root.AbsoluteSize
	local offset = udim2.X.Offset
	local offset2 = udim2.Y.Offset

	local hintBarAnchor, v11 = getHintBarAnchor()

	if hintBarAnchor then
		applyMode("hint") -- inferred equivalent call
		local v12 = math.clamp(hintBarAnchor - absolutePosition.X, 0, (math.max(0, absoluteSize.X - offset)))
		local v13 = math.clamp(v11 - absolutePosition.Y - 4, offset2, (math.max(offset2, absoluteSize.Y)))
		toggle.Position = UDim2.fromOffset(math.floor(v12 + 0.5), (math.floor(v13 + 0.5)))
	else
		local greenHitAnchor, v12 = getGreenHitAnchor()

		if greenHitAnchor then
			applyMode("hit") -- inferred equivalent call
			local v13 = math.clamp(
				greenHitAnchor - absolutePosition.X,
				offset / 2,
				(math.max(offset / 2, absoluteSize.X - offset / 2))
			)
			local v14 = math.clamp(v12 - absolutePosition.Y + 4, 0, (math.max(0, absoluteSize.Y - offset2)))
			toggle.Position = UDim2.fromOffset(math.floor(v13 + 0.5), (math.floor(v14 + 0.5)))
		else
			applyMode("fallback") -- inferred equivalent call
		end
	end
end

local function hideInstance(p, p2) -- 2 equivalent calls inferred from this helper
	if p[p2] then
		p[p2] = false
	end

	v4[p] = p2
end

RunService.RenderStepped:Connect(function()
	local noteLaneVisible = isNoteLaneVisible() -- inferred equivalent call

	if toggle.Visible ~= noteLaneVisible then
		toggle.Visible = noteLaneVisible
	end

	updatePosition()
	updateCamButton(noteLaneVisible)

	if v3 then
		for _, childName in ipairs(v) do
			local screenGui = PlayerGui:FindFirstChild(childName)

			if screenGui and screenGui:IsA("ScreenGui") then
				hideInstance(screenGui, "Enabled") -- inferred equivalent call
			end
		end

		local bandScoreUI = PlayerGui:FindFirstChild("BandScoreUI")
		local bandScoreUIContainer = bandScoreUI and bandScoreUI:FindFirstChild("Container")

		if bandScoreUIContainer then
			for _, childName in ipairs(v2) do
				local guiObject = bandScoreUIContainer:FindFirstChild(childName)

				if guiObject and guiObject:IsA("GuiObject") then
					hideInstance(guiObject, "Visible") -- inferred equivalent call
				end
			end
		end
	elseif next(v4) ~= nil then
		for k, v11 in pairs(v4) do
			if k.Parent then
				k[v11] = true
			end
		end

		v4 = {}
	end
end)