local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local privateStudio = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PrivateStudio")
local PStudioConfig = require(privateStudio:WaitForChild("PStudioConfig"))
local PStudioState = require(privateStudio:WaitForChild("PStudioState"))
local PStudioToasts = require(privateStudio:WaitForChild("PStudioToasts"))
local laptopOpenFromSongList = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LaptopOpenFromSongList")
local openManager = ReplicatedStorage:WaitForChild(PStudioConfig.REMOTES_FOLDER):WaitForChild("OpenManager")
local PStudioManagerWindow = require(privateStudio:WaitForChild("PStudioManagerWindow"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(23, 23, 27)
local color2 = Color3.fromRGB(50, 50, 58)
local color3 = Color3.fromRGB(60, 60, 70)

local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local StudioManager = PStudioConfig.TEXT.StudioManager
local v = math.ceil(TextService:GetTextSize(StudioManager, 11, Enum.Font.GothamBold, Vector2.new(1000, 30)).X) + 24

local studioManagerGui = Instance.new("ScreenGui")
studioManagerGui.Name = "StudioManagerGui"
studioManagerGui.ResetOnSpawn = false
studioManagerGui.IgnoreGuiInset = true
studioManagerGui.DisplayOrder = 98
studioManagerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
studioManagerGui.Parent = PlayerGui

local studioManagerButton = Instance.new("TextButton")
studioManagerButton.Name = "StudioManagerButton"
studioManagerButton.Text = StudioManager
studioManagerButton.Font = Enum.Font.GothamBold
studioManagerButton.TextSize = 11
studioManagerButton.TextColor3 = Color3.fromRGB(245, 245, 247)
studioManagerButton.AutoButtonColor = false
studioManagerButton.BackgroundColor3 = color
studioManagerButton.BackgroundTransparency = 0.25
studioManagerButton.AnchorPoint = Vector2.new(1, 0.5)
studioManagerButton.Size = UDim2.new(0, v, 0, 30)
studioManagerButton.Visible = false
studioManagerButton.ZIndex = 20
studioManagerButton:SetAttribute("NoNewUISkin", true)
studioManagerButton.Parent = studioManagerGui
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = studioManagerButton
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = color3
uiStroke.Transparency = 1
uiStroke.Thickness = 1
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = studioManagerButton

local v2 = nil

local v3 = nil
local function bandOffset() -- 2 equivalent calls inferred from this helper
	if v3 and v3.Visible then
		return v3.Size.X.Offset + 6
	end

	return 0
end

local function place()
	if v2 then
		local position = v2.Position
		local x = v2.AbsoluteSize.X
		studioManagerButton.AnchorPoint = v2.AnchorPoint
		studioManagerButton.Size = UDim2.new(0, v, 0, v2.Size.Y.Offset)
		studioManagerButton.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset - x - 6 - bandOffset(), -- inferred equivalent call
			position.Y.Scale,
			position.Y.Offset
		)
	else
		local y = GuiService:GetGuiInset().Y
		studioManagerButton.Size = UDim2.fromOffset(v, 30)
		studioManagerButton.Position = UDim2.new(1, -(88 + bandOffset()), 0, y / 2 + 30 + 6) -- inferred equivalent call
	end
end
place()

task.spawn(function()
	local bandGui = PlayerGui:WaitForChild("BandGui", 20)
	local bandToggle = bandGui and bandGui:WaitForChild("BandToggle", 5)

	if bandToggle then
		v3 = bandToggle
		bandToggle:GetPropertyChangedSignal("Visible"):Connect(place)
		bandToggle:GetPropertyChangedSignal("Size"):Connect(place)
		place()
	end
end)

local function refresh() -- 2 equivalent calls inferred from this helper
	local v4 = PStudioState.Get()
	local v5

	if v4 == nil then
		v5 = false
	else
		v5 = v4.ownerId == LocalPlayer.UserId
	end

	local v6 = v2 == nil or v2.Visible
	studioManagerButton.Visible = v5 and v6
end

task.spawn(function()
	local equipmentUI = PlayerGui:WaitForChild("EquipmentUI", 15)
	local equipmentButton = equipmentUI and equipmentUI:WaitForChild("EquipmentButton", 5)

	if equipmentButton then
		v2 = equipmentButton
		equipmentButton:GetPropertyChangedSignal("Position"):Connect(place)
		equipmentButton:GetPropertyChangedSignal("Size"):Connect(place)
		equipmentButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
		equipmentButton:GetPropertyChangedSignal("Visible"):Connect(refresh)
		place()
		refresh() -- inferred equivalent call
	end
end)

PStudioState.Changed:Connect(refresh)
refresh() -- inferred equivalent call
local v4 = false
local function paint() -- 2 equivalent calls inferred from this helper
	TweenService:Create(studioManagerButton, tweenInfo, {
		BackgroundColor3 = v4 and color2 or color
	}):Play()
	uiStroke.Transparency = v4 and 0.5 or 1
end
studioManagerButton.MouseEnter:Connect(function()
	v4 = true
	paint() -- inferred equivalent call
end)
studioManagerButton.MouseLeave:Connect(function()
	v4 = false
	paint() -- inferred equivalent call
end)

local flag = false
studioManagerButton.Activated:Connect(function()
	if flag then
		return
	end

	flag = true
	task.delay(0.8, function()
		flag = false
	end)

	if PStudioManagerWindow.IsOpen() then
		PStudioManagerWindow.Close()
		return
	end

	local success, result = pcall(function()
		return openManager:InvokeServer()
	end)

	if not success or result ~= "laptop" and result ~= "window" then
		PStudioToasts.Notice(PStudioConfig.RESULT_TEXT.laptop_unavailable, "error")
		return
	end

	if result == "window" then
		PStudioManagerWindow.Open()
		return
	end

	LocalPlayer:SetAttribute("LaptopOpenTab", "studio")
	local success2, result2 = pcall(function()
		return laptopOpenFromSongList:InvokeServer()
	end)

	if success2 and result2 == true then
		task.delay(3, function()
			if LocalPlayer:GetAttribute("LaptopOpenTab") == "studio" then
				LocalPlayer:SetAttribute("LaptopOpenTab", nil)
			end
		end)

		return
	end

	LocalPlayer:SetAttribute("LaptopOpenTab", nil)
	PStudioManagerWindow.Open()
end)