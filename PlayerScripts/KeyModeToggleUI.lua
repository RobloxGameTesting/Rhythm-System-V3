local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)
local NewbieModeState = require(ReplicatedStorage.Modules.NewbieModeState)
local NewbieModePanelUI = require(ReplicatedStorage.Modules.NewbieModePanelUI)
local DifficultyPlateColors = require(ReplicatedStorage.Modules.DifficultyPlateColors)
local DifficultyBadge = require(ReplicatedStorage.Modules.SongListUI.DifficultyBadge)
local TextService = game:GetService("TextService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SetKeyMode = RemoteEvents:WaitForChild("SetKeyMode")
local KeyModeUpdate = RemoteEvents:WaitForChild("KeyModeUpdate")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = 5
local v2 = nil

local color = Color3.fromRGB(23, 23, 27)
local color2 = Color3.fromRGB(245, 245, 247)
local color3 = Color3.fromRGB(60, 60, 70)
local color4 = Color3.fromRGB(38, 38, 44)
local color5 = Color3.fromRGB(255, 149, 51)

local function getTopbarInsetHeight()
	local success, result = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v3 = not (success and result) and 0 or result.Y

	return v3 <= 0 and 36 or v3
end

local function computeButtonX(): number
	return -246
end

local keyModeToggleUI = Instance.new("ScreenGui")
keyModeToggleUI.Name = "KeyModeToggleUI"
keyModeToggleUI.ResetOnSpawn = false
keyModeToggleUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyModeToggleUI.DisplayOrder = 100
keyModeToggleUI.IgnoreGuiInset = true
keyModeToggleUI.Enabled = false
keyModeToggleUI.Parent = PlayerGui

local keyModeButton = Instance.new("TextButton")
keyModeButton.Name = "KeyModeButton"
keyModeButton.AnchorPoint = Vector2.new(1, 0.5)

local function fn()
	return GuiService:GetGuiInset()
end

local success, result = pcall(fn)

local v3 = not (success and result) and 0 or result.Y

keyModeButton.Position = UDim2.new(1, -246, 0, (v3 <= 0 and 36 or v3) / 2)
keyModeButton.Size = UDim2.new(0, 70, 0, 30)
keyModeButton.BackgroundColor3 = color
keyModeButton.Text = ""
keyModeButton.AutoButtonColor = false
keyModeButton.ZIndex = 10
keyModeButton.Parent = keyModeToggleUI

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = keyModeButton

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = color3
uiStroke.Transparency = 0.5
uiStroke.Thickness = 1
uiStroke.Parent = keyModeButton

local label = Instance.new("TextLabel")
label.Name = "Label"
label.AnchorPoint = Vector2.new(0, 0.5)
label.Position = UDim2.new(0, 8, 0.5, 0)
label.Size = UDim2.new(1, -24, 1, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 10
label.TextColor3 = color2
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.Text = "5-Key"
label.ZIndex = 10
label.Parent = keyModeButton

local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
uiTextSizeConstraint.MaxTextSize = 10
uiTextSizeConstraint.MinTextSize = 7
uiTextSizeConstraint.Parent = label
label.TextScaled = true

local caret = Instance.new("TextLabel")
caret.Name = "Caret"
caret.AnchorPoint = Vector2.new(1, 0.5)
caret.Position = UDim2.new(1, -8, 0.5, 0)
caret.Size = UDim2.new(0, 12, 1, 0)
caret.BackgroundTransparency = 1
caret.Text = "v"
caret.Font = Enum.Font.GothamBold
caret.TextSize = 11
caret.TextColor3 = color2
caret.TextXAlignment = Enum.TextXAlignment.Center
caret.TextYAlignment = Enum.TextYAlignment.Center
caret.ZIndex = 10
caret.Parent = keyModeButton

local catcher = Instance.new("TextButton")
catcher.Name = "Catcher"
catcher.Size = UDim2.fromScale(1, 1)
catcher.BackgroundTransparency = 1
catcher.Text = ""
catcher.AutoButtonColor = false
catcher.ZIndex = 9
catcher.Visible = false
catcher.Parent = keyModeToggleUI

local dropdownPanel = Instance.new("Frame")
dropdownPanel.Name = "DropdownPanel"
dropdownPanel.Size = UDim2.new(0, 110, 0, 0)
dropdownPanel.AutomaticSize = Enum.AutomaticSize.Y
dropdownPanel.BackgroundColor3 = color
dropdownPanel.ZIndex = 10
dropdownPanel.Visible = false
dropdownPanel.Parent = keyModeToggleUI

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 8)
uiCorner2.Parent = dropdownPanel

local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Color = color3
uiStroke2.Transparency = 0.5
uiStroke2.Thickness = 1
uiStroke2.Parent = dropdownPanel

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = dropdownPanel

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 4)
uiPadding.PaddingBottom = UDim.new(0, 4)
uiPadding.Parent = dropdownPanel

local flag = false

local function v4() end

local function fn2() end

local function hideMorePanel() -- 5 equivalent calls inferred from this helper
	local current = NewbieModePanelUI.Current

	if current then
		current:Hide()
	end
end

local function showMorePanel(difficultyButton) -- 1 equivalent call inferred from this helper
	local current = NewbieModePanelUI.Current

	if current then
		current:Show(difficultyButton)
	else
		warn("[KeyModeToggleUI] Panel Difficulty (Song List) belum siap")
	end
end

local function closeDropdown() -- 4 equivalent calls inferred from this helper
	flag = false
	dropdownPanel.Visible = false
	catcher.Visible = false
end

local function repositionDropdown()
	local success2, result2 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v5 = not (success2 and result2) and 0 or result2.Y

	dropdownPanel.Position = UDim2.new(1, -246, 0, (v5 <= 0 and 36 or v5) / 2 + 15 + 4)
	dropdownPanel.AnchorPoint = Vector2.new(1, 0)
end

local function openDropdown()
	v4()
	hideMorePanel() -- inferred equivalent call
	flag = true
	local success2, result2 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v5 = not (success2 and result2) and 0 or result2.Y

	dropdownPanel.Position = UDim2.new(1, -246, 0, (v5 <= 0 and 36 or v5) / 2 + 15 + 4)
	dropdownPanel.AnchorPoint = Vector2.new(1, 0)

	dropdownPanel.Visible = true
	catcher.Visible = true
end

catcher.MouseButton1Click:Connect(closeDropdown)

local function fullLaneCount() -- 2 equivalent calls inferred from this helper
	return v2 and RhythmEngineConfig.LaneCount[v2] or 5
end

local function effectiveKeyMode() -- 2 equivalent calls inferred from this helper
	return (math.min(v, fullLaneCount())) -- inferred equivalent call
end

local function refreshButtonText() -- 3 equivalent calls inferred from this helper
	if ModeManager.IsFreePlay() then
		label.Text = "FREE PLAY"
	else
		label.Text = effectiveKeyMode() .. "-Key" -- inferred equivalent call
	end
end

local function clearDropdownRows()
	for _, button in ipairs(dropdownPanel:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

local function createDropdownRow(text, layoutOrder, p, fn3)
	local textButton = Instance.new("TextButton")
	textButton.Name = "Row_" .. layoutOrder
	textButton.LayoutOrder = layoutOrder
	textButton.Size = UDim2.new(1, 0, 0, 30)
	textButton.BackgroundColor3 = color4
	textButton.BackgroundTransparency = 1
	textButton.Text = text
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 12
	textButton.TextColor3 = p and color5 or color2
	textButton.AutoButtonColor = false
	textButton.ZIndex = 10
	textButton.Parent = dropdownPanel

	textButton.MouseEnter:Connect(function()
		textButton.BackgroundTransparency = 0
	end)
	textButton.MouseLeave:Connect(function()
		textButton.BackgroundTransparency = 1
	end)
	textButton.MouseButton1Click:Connect(function()
		closeDropdown() -- inferred equivalent call
		fn3()
	end)

	return textButton
end

local function rebuildDropdownRows()
	clearDropdownRows()

	local isFreePlay = ModeManager.IsFreePlay()
	local v5 = v2 and RhythmEngineConfig.NewbieLaneCountOptions[v2] or { 2, fullLaneCount() } -- inferred equivalent call
	local count = 0

	for _, v6 in ipairs(v5) do
		count += 1
		createDropdownRow(v6 .. "-Key", count, not isFreePlay and effectiveKeyMode() == v6, function() -- inferred equivalent call
			if ModeManager.IsFreePlay() then
				ModeManager.SetRhythm()
			end

			SetKeyMode:FireServer(v6)
		end)
	end

	createDropdownRow("Free Play", count + 1, isFreePlay, function()
		ModeManager.SetFreePlay()
	end)
end

keyModeButton.MouseButton1Click:Connect(function()
	if flag then
		closeDropdown() -- inferred equivalent call
	else
		rebuildDropdownRows()
		v4()
		hideMorePanel() -- inferred equivalent call
		flag = true
		local success2, result2 = pcall(function()
			return GuiService:GetGuiInset()
		end)

		local v5 = not (success2 and result2) and 0 or result2.Y

		dropdownPanel.Position = UDim2.new(1, -246, 0, (v5 <= 0 and 36 or v5) / 2 + 15 + 4)
		dropdownPanel.AnchorPoint = Vector2.new(1, 0)

		dropdownPanel.Visible = true
		catcher.Visible = true
	end
end)

KeyModeUpdate.OnClientEvent:Connect(function(p)
	v = p
	refreshButtonText() -- inferred equivalent call
end)

ModeManager.OnChanged(function()
	refreshButtonText() -- inferred equivalent call
	fn2()
end)

local v5 = { Natural = "Normal", Medium = "Medium", Easy = "Easy", Baby = "Baby" }
local v6 = { Natural = 1, Medium = 2, Easy = 3, Baby = 4 }

local color6 = Color3.fromRGB(240, 180, 70)

local function computeDifficultyButtonX(): number
	return -246 - 70 - 8
end

local difficultyButton = Instance.new("TextButton")
difficultyButton.Name = "DifficultyButton"
difficultyButton.AnchorPoint = Vector2.new(1, 0.5)
local success2, result2 = pcall(fn)

local v7 = not (success2 and result2) and 0 or result2.Y

difficultyButton.Position = UDim2.new(1, -246 - 70 - 8, 0, (v7 <= 0 and 36 or v7) / 2)
difficultyButton.Size = UDim2.new(0, 84, 0, 30)
difficultyButton.BackgroundColor3 = color
difficultyButton.Text = ""
difficultyButton.AutoButtonColor = false
difficultyButton.ZIndex = 10
difficultyButton.Parent = keyModeToggleUI

local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(0, 8)
uiCorner3.Parent = difficultyButton

local uiStroke3 = Instance.new("UIStroke")
uiStroke3.Color = color3
uiStroke3.Transparency = 0.5
uiStroke3.Thickness = 1
uiStroke3.Parent = difficultyButton

local label2 = Instance.new("TextLabel")
label2.Name = "Label"
label2.AnchorPoint = Vector2.new(0, 0.5)
label2.Position = UDim2.new(0, 8, 0.5, 0)
label2.Size = UDim2.new(1, -24, 1, 0)
label2.BackgroundTransparency = 1
label2.Font = Enum.Font.GothamBold
label2.TextSize = 10
label2.TextColor3 = color2
label2.TextXAlignment = Enum.TextXAlignment.Left
label2.TextYAlignment = Enum.TextYAlignment.Center
label2.Text = "Difficulty"
label2.ZIndex = 10
label2.Parent = difficultyButton

local uiTextSizeConstraint2 = Instance.new("UITextSizeConstraint")
uiTextSizeConstraint2.MaxTextSize = 10
uiTextSizeConstraint2.MinTextSize = 7
uiTextSizeConstraint2.Parent = label2
label2.TextScaled = true

local caret2 = Instance.new("TextLabel")
caret2.Name = "Caret"
caret2.AnchorPoint = Vector2.new(1, 0.5)
caret2.Position = UDim2.new(1, -8, 0.5, 0)
caret2.Size = UDim2.new(0, 12, 1, 0)
caret2.BackgroundTransparency = 1
caret2.Text = "v"
caret2.Font = Enum.Font.GothamBold
caret2.TextSize = 11
caret2.TextColor3 = color2
caret2.TextXAlignment = Enum.TextXAlignment.Center
caret2.TextYAlignment = Enum.TextYAlignment.Center
caret2.ZIndex = 10
caret2.Parent = difficultyButton

local difficultyCatcher = Instance.new("TextButton")
difficultyCatcher.Name = "DifficultyCatcher"
difficultyCatcher.Size = UDim2.fromScale(1, 1)
difficultyCatcher.BackgroundTransparency = 1
difficultyCatcher.Text = ""
difficultyCatcher.AutoButtonColor = false
difficultyCatcher.ZIndex = 9
difficultyCatcher.Visible = false
difficultyCatcher.Parent = keyModeToggleUI

local difficultyPanel = Instance.new("Frame")
difficultyPanel.Name = "DifficultyPanel"
difficultyPanel.Size = UDim2.new(0, 110, 0, 0)
difficultyPanel.AutomaticSize = Enum.AutomaticSize.Y
difficultyPanel.BackgroundColor3 = color
difficultyPanel.ZIndex = 10
difficultyPanel.Visible = false
difficultyPanel.Parent = keyModeToggleUI

local uiCorner4 = Instance.new("UICorner")
uiCorner4.CornerRadius = UDim.new(0, 8)
uiCorner4.Parent = difficultyPanel

local uiStroke4 = Instance.new("UIStroke")
uiStroke4.Color = color3
uiStroke4.Transparency = 0.5
uiStroke4.Thickness = 1
uiStroke4.Parent = difficultyPanel

local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.FillDirection = Enum.FillDirection.Vertical
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.Parent = difficultyPanel

local uiPadding2 = Instance.new("UIPadding")
uiPadding2.PaddingTop = UDim.new(0, 4)
uiPadding2.PaddingBottom = UDim.new(0, 4)
uiPadding2.Parent = difficultyPanel

local flag2 = false
local v8 = 0

local function closeDifficulty() -- 3 equivalent calls inferred from this helper
	flag2 = false
	difficultyPanel.Visible = false
	difficultyCatcher.Visible = false
end
v4 = closeDifficulty

fn2 = function()
	local isFreePlay = ModeManager.IsFreePlay()
	difficultyButton.Visible = not isFreePlay

	if isFreePlay then
		closeDifficulty() -- inferred equivalent call
		hideMorePanel() -- inferred equivalent call
	end
end
fn2()

local function repositionDifficultyPanel()
	difficultyPanel.AnchorPoint = Vector2.new(1, 0)
	local success3, result3 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v9 = not (success3 and result3) and 0 or result3.Y

	difficultyPanel.Position = UDim2.new(1, -246 - 70 - 8, 0, (v9 <= 0 and 36 or v9) / 2 + 15 + 4)
end

local function fn3()
	local function fn4()
		return GuiService:GetGuiInset()
	end

	local success3, result3 = pcall(fn4)

	local v9 = not (success3 and result3) and 0 or result3.Y

	difficultyButton.Position = UDim2.new(1, -246 - 70 - 8, 0, (v9 <= 0 and 36 or v9) / 2)

	if flag2 then
		difficultyPanel.AnchorPoint = Vector2.new(1, 0)
		local success4, result4 = pcall(fn4)

		local v10 = not (success4 and result4) and 0 or result4.Y

		difficultyPanel.Position = UDim2.new(1, -246 - 70 - 8, 0, (v10 <= 0 and 36 or v10) / 2 + 15 + 4)
	end
end

difficultyCatcher.MouseButton1Click:Connect(closeDifficulty)

local function createDifficultyRow(text, layoutOrder, p, callback)
	local textButton = Instance.new("TextButton")
	textButton.Name = "Row_" .. layoutOrder
	textButton.LayoutOrder = layoutOrder
	textButton.Size = UDim2.new(1, 0, 0, 30)
	textButton.BackgroundColor3 = color4
	textButton.BackgroundTransparency = 1
	textButton.Text = text
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 12
	textButton.TextColor3 = p and color6 or color2
	textButton.AutoButtonColor = false
	textButton.ZIndex = 10
	textButton.Parent = difficultyPanel

	local v9 = v5[text]

	if v9 and DifficultyPlateColors[v9] then
		local x = TextService:GetTextSize(text, textButton.TextSize, textButton.Font, Vector2.new(1000, 30)).X
		local colored = DifficultyBadge.CreateColored(textButton, DifficultyPlateColors[v9], 0, 10, v6[text])

		colored.AnchorPoint = Vector2.new(0, 0.5)
		colored.Position = UDim2.new(0.5, -(x / 2) - 6 - 10, 0.5, 0)
	end

	textButton.MouseEnter:Connect(function()
		textButton.BackgroundTransparency = 0
	end)
	textButton.MouseLeave:Connect(function()
		textButton.BackgroundTransparency = 1
	end)
	textButton.MouseButton1Click:Connect(function()
		closeDifficulty() -- inferred equivalent call

		if callback then
			callback()
		elseif NewbieModeState.GetMatchingPresetName() ~= text then
			NewbieModeState.ApplyPresetByName(text)
		end
	end)

	return textButton
end

local function rebuildDifficultyRows()
	for _, button in ipairs(difficultyPanel:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end

	local matchingPresetName = NewbieModeState.GetMatchingPresetName()
	local labels = { "Natural" }

	for _, preset in ipairs(NewbieModeState.Presets) do
		table.insert(labels, preset.Label)
	end

	for i, v9 in ipairs(labels) do
		createDifficultyRow(v9, i, v9 == matchingPresetName)
	end

	createDifficultyRow("More", #labels + 1, false, function()
		showMorePanel(difficultyButton) -- inferred equivalent call
	end)
end

difficultyButton.MouseButton1Click:Connect(function()
	local now = os.clock()

	if now - v8 < 0.25 then
		return
	end

	v8 = now

	if flag2 then
		closeDifficulty() -- inferred equivalent call
	else
		closeDropdown() -- inferred equivalent call
		hideMorePanel() -- inferred equivalent call
		rebuildDifficultyRows()
		flag2 = true
		difficultyPanel.AnchorPoint = Vector2.new(1, 0)
		local success3, result3 = pcall(function()
			return GuiService:GetGuiInset()
		end)

		local v9 = not (success3 and result3) and 0 or result3.Y

		difficultyPanel.Position = UDim2.new(1, -246 - 70 - 8, 0, (v9 <= 0 and 36 or v9) / 2 + 15 + 4)

		difficultyPanel.Visible = true
		difficultyCatcher.Visible = true
	end
end)

local function refreshDifficultyLabel() -- 2 equivalent calls inferred from this helper
	local matchingPresetName = NewbieModeState.GetMatchingPresetName()

	if matchingPresetName and matchingPresetName ~= "Natural" then
		label2.Text = matchingPresetName
	else
		label2.Text = "Difficulty"
	end
end

refreshDifficultyLabel() -- inferred equivalent call
NewbieModeState.OnChanged(function()
	refreshDifficultyLabel() -- inferred equivalent call

	if flag2 then
		rebuildDifficultyRows()
	end
end)

InstrumentHUDUpdate.OnClientEvent:Connect(function(p, p2)
	v2 = p2
	local v9 = p2 and RhythmEngineConfig.TwoKeyEligible[p2]
	keyModeToggleUI.Enabled = p and v9 == true

	if not p then
		closeDropdown() -- inferred equivalent call
		v4()
		hideMorePanel() -- inferred equivalent call
	end

	refreshButtonText() -- inferred equivalent call
end)

local function onViewportChanged()
	local function fn4()
		return GuiService:GetGuiInset()
	end

	local success3, result3 = pcall(fn4)

	local v9 = not (success3 and result3) and 0 or result3.Y

	local v10 = v9 <= 0 and 36 or v9

	keyModeButton.Position = UDim2.new(1, -246, 0, v10 / 2)
	fn3()

	if flag then
		local success4, result4 = pcall(fn4)

		local v11 = not (success4 and result4) and 0 or result4.Y

		dropdownPanel.Position = UDim2.new(1, -246, 0, (v11 <= 0 and 36 or v11) / 2 + 15 + 4)
		dropdownPanel.AnchorPoint = Vector2.new(1, 0)
	end
end

local function connectViewportListener() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged)
	end
end

connectViewportListener() -- inferred equivalent call
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectViewportListener)

if ModeManager.IsFreePlay() then
	label.Text = "FREE PLAY"
else
	local v9 = v2 and RhythmEngineConfig.LaneCount[v2] or 5

	label.Text = math.min(v, v9) .. "-Key"
end