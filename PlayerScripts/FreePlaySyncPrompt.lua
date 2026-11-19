local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local FreePlaySyncState = require(Modules:WaitForChild("FreePlaySyncState"))
local FreePlaySyncStyle = require(Modules:WaitForChild("FreePlaySyncStyle"))
local ThemeSwitchToast = require(Modules:WaitForChild("ThemeSwitchToast"))

local Palette = FreePlaySyncStyle.Palette
local Make = FreePlaySyncStyle.Make

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Map = Workspace:WaitForChild("Map")
local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local v = false
local v2 = {}
local v3 = -1e999
local v4 = 0
local v5 = false

Workspace.DescendantAdded:Connect(function(sound)
	if
		not sound:IsA("Sound")
		or sound:GetAttribute("FPMirror")
		or typeof(sound:GetAttribute("FPPressTime")) ~= "number"
	then
		return
	end

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")

	if freePlayPresserUserId == nil or freePlayPresserUserId == LocalPlayer.UserId then
		return
	end

	while sound and sound.Parent ~= Map do
		sound = sound.Parent
	end

	if not sound then
		return
	end

	local nowsByFreePlayPresserUserId = v2[sound]

	if not nowsByFreePlayPresserUserId then
		nowsByFreePlayPresserUserId = {}
		v2[sound] = nowsByFreePlayPresserUserId
	end

	nowsByFreePlayPresserUserId[freePlayPresserUserId] = os.clock()
end)

local function getNearStage()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	for _, child in ipairs(Map:GetChildren()) do
		local stageZone = child:FindFirstChild("StageZone")

		if not (stageZone and stageZone:IsA("BasePart")) then
			continue
		end

		local pointToObjectSpace = stageZone.CFrame:PointToObjectSpace(humanoidRootPart.Position)
		local v6 = stageZone.Size * 0.5

		if
			math.abs(pointToObjectSpace.X) <= v6.X + 12
			and math.abs(pointToObjectSpace.Y) <= v6.Y + 12
			and math.abs(pointToObjectSpace.Z) <= v6.Z + 12
		then
			return child
		end
	end

	return nil
end

local function countActivePlayers(p)
	local v6 = v2[p]

	if not v6 then
		return 0
	end

	local now = os.clock()
	local count = 0

	for k, v7 in pairs(v6) do
		if now - v7 < 10 then
			count += 1
		else
			v6[k] = nil
		end
	end

	return count
end

local make = Make(
	"ScreenGui",
	{
		Name = "FreePlaySyncPromptGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 90
	},
	PlayerGui
)

local v6 = ThemeSwitchToast.new(make)

local function toggleSync() -- 2 equivalent calls inferred from this helper
	local v7 = not FreePlaySyncState.IsEnabled()
	FreePlaySyncState.SetEnabled(v7)
	v6:Show(v7 and "Sync ON - others delayed " .. FreePlaySyncState.GetDelayMs() .. " ms" or "Sync OFF")
end

local color = Color3.fromRGB(23, 23, 27)
local color2 = Color3.fromRGB(50, 50, 58)
local color3 = Color3.fromRGB(60, 60, 70)

local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local v7 = Color3.fromRGB(66, 200, 120)

local success, result = pcall(function()
	local StyledTheme = require(Modules.SongListUI.StyledTheme)
	return StyledTheme.Settings.ACCENT
end)

if success and typeof(result) == "Color3" then
	v7 = result
end

local make2 = Make("TextButton", {
	Name = "SyncHudButton",
	Text = "SYNC: OFF",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = Color3.fromRGB(245, 245, 247),
	AutoButtonColor = false,
	BackgroundColor3 = color,
	BackgroundTransparency = 0.25,
	AnchorPoint = Vector2.new(1, 0.5),
	Size = UDim2.new(0, 70, 0, 30),
	Visible = false,
	ZIndex = 20
}, make)

Make("UICorner", { CornerRadius = UDim.new(0, 8) }, make2)
local make3 = Make(
	"UIStroke",
	{
		Color = color3,
		Transparency = 1,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	},
	make2
)

local placeCard
local v8 = nil

local v9 = nil
local v10 = nil
local function studioManagerOffset() -- 2 equivalent calls inferred from this helper
	local total = 0

	if v10 and v10.Visible then
		total += v10.Size.X.Offset + 6
	end

	if v9 and v9.Visible then
		total += v9.AbsoluteSize.X + 6
	end

	return total
end

local function placeHudButton()
	if v8 then
		local position = v8.Position
		local x = v8.AbsoluteSize.X
		make2.AnchorPoint = v8.AnchorPoint
		make2.Size = v8.Size
		make2.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset - x - 6 - studioManagerOffset(), -- inferred equivalent call
			position.Y.Scale,
			position.Y.Offset
		)
	else
		local y = GuiService:GetGuiInset().Y
		make2.Size = UDim2.fromOffset(70, 30)
		make2.Position = UDim2.new(1, -(88 + studioManagerOffset()), 0, y / 2 + 30 + 6) -- inferred equivalent call
	end

	if placeCard then
		placeCard()
	end
end
placeHudButton()

task.spawn(function()
	local equipmentUI = PlayerGui:WaitForChild("EquipmentUI", 15)
	local equipmentButton = equipmentUI and equipmentUI:WaitForChild("EquipmentButton", 5)

	if equipmentButton then
		v8 = equipmentButton
		equipmentButton:GetPropertyChangedSignal("Position"):Connect(placeHudButton)
		equipmentButton:GetPropertyChangedSignal("Size"):Connect(placeHudButton)
		equipmentButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeHudButton)
		placeHudButton()
	end
end)

task.spawn(function()
	local studioManagerGui = PlayerGui:WaitForChild("StudioManagerGui", 15)
	local studioManagerButton = studioManagerGui and studioManagerGui:WaitForChild("StudioManagerButton", 5)

	if studioManagerButton then
		v9 = studioManagerButton
		studioManagerButton:GetPropertyChangedSignal("Visible"):Connect(placeHudButton)
		studioManagerButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeHudButton)
		placeHudButton()
	end
end)

task.spawn(function()
	local bandGui = PlayerGui:WaitForChild("BandGui", 20)
	local bandToggle = bandGui and bandGui:WaitForChild("BandToggle", 5)

	if bandToggle then
		v10 = bandToggle
		bandToggle:GetPropertyChangedSignal("Visible"):Connect(placeHudButton)
		bandToggle:GetPropertyChangedSignal("Size"):Connect(placeHudButton)
		placeHudButton()
	end
end)

local v11 = false
local function refreshHudButton()
	local isEnabled = FreePlaySyncState.IsEnabled()
	make2.Text = isEnabled and "SYNC: ON" or "SYNC: OFF"

	TweenService:Create(make2, tweenInfo, {
		BackgroundColor3 = (isEnabled or v11) and color2 or color
	}):Play()
	make3.Color = isEnabled and v7 or color3
	make3.Transparency = isEnabled and 0.5 or 1
end

make2.MouseEnter:Connect(function()
	v11 = true
	refreshHudButton()
end)
make2.MouseLeave:Connect(function()
	v11 = false
	refreshHudButton()
end)
make2.Activated:Connect(function()
	toggleSync() -- inferred equivalent call
end)
FreePlaySyncState.OnChanged(refreshHudButton)
refreshHudButton()

local make4 = Make("CanvasGroup", {
	Name = "SyncCard",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -70, 0, 66),
	Size = UDim2.new(0, 236, 0, 88),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false
}, make)

local make5 = Make("UIScale", { Scale = 1 }, make4)

placeCard = function()
	local position = make2.Position
	local size = make2.Size
	make4.Position = UDim2.new(
		position.X.Scale,
		position.X.Offset + 18,
		position.Y.Scale,
		position.Y.Offset + size.Y.Offset / 2 + 4 - 18
	)
end
placeCard()

local make6 = Make("Frame", {
	Name = "Shadow",
	Position = UDim2.new(0, 21, 0, 22),
	Size = UDim2.new(0, 200, 0, 52),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	Rotation = -1.2,
	ZIndex = 1
}, make4)

Make("UICorner", { CornerRadius = UDim.new(0, 2) }, make6)

local make7 = Make("Frame", {
	Name = "Paper",
	Position = UDim2.new(0, 18, 0, 18),
	Size = UDim2.new(0, 200, 0, 52),
	BackgroundColor3 = Palette.PAPER,
	BorderSizePixel = 0,
	Rotation = -1.2,
	ZIndex = 2
}, make4)

Make("UICorner", { CornerRadius = UDim.new(0, 2) }, make7)
Make("UIStroke", {
	Color = Palette.INK,
	Thickness = 1.5,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border
}, make7)

Make("TextLabel", {
	Name = "Title",
	Position = UDim2.new(0, 10, 0, 3),
	Size = UDim2.new(0, 110, 0, 24),
	BackgroundTransparency = 1,
	Font = FreePlaySyncStyle.FONT_HEAD,
	TextSize = 22,
	TextColor3 = Palette.MARKER,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "DELAY?",
	ZIndex = 6
}, make7)

FreePlaySyncStyle.AddMarkerUnderline(make7, 10, 25, 58, 6)
Make("TextLabel", {
	Name = "Sub",
	Position = UDim2.new(0, 10, 0, 33),
	Size = UDim2.new(0, 124, 0, 16),
	BackgroundTransparency = 1,
	Font = FreePlaySyncStyle.FONT_BODY,
	TextSize = 12,
	TextColor3 = Palette.INK,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "press to sync them",
	ZIndex = 6
}, make7)

local make8 = Make("TextButton", {
	Name = "SyncButton",
	Position = UDim2.new(0, 128, 0, 11),
	Size = UDim2.new(0, 62, 0, 30),
	Rotation = 2.5,
	Text = "SYNC",
	ZIndex = 25
}, make7)

FreePlaySyncStyle.StyleTapeButton(make8, Palette.TAPE_BLACK)
make8.TextSize = 17

FreePlaySyncStyle.AddPaperDecor(make7, 41, 20, true)
FreePlaySyncStyle.AddTape(
	make7,
	"TapeTopLeft",
	UDim2.new(0, 12, 0, 1),
	UDim2.new(0, 38, 0, 10),
	-36,
	Palette.TAPE,
	0.12,
	30
)
FreePlaySyncStyle.AddTape(
	make7,
	"TapeTopRight",
	UDim2.new(1, -12, 0, 1),
	UDim2.new(0, 30, 0, 9),
	22,
	Palette.TAPE_DARK,
	0.16,
	30
)

local count = 0
local v12 = nil
local function setCardVisible(p)
	if v5 == p then
		return
	end

	v5 = p
	count += 1
	local v13 = count

	if p then
		v4 = os.clock()
		v3 = v4

		if v12 then
			v12:Cancel()
			v12 = nil
		end

		make4.Visible = true
		make4.GroupTransparency = 0
		make5.Scale = 0.75
		TweenService:Create(make5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	else
		v12 = TweenService:Create(make4, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1
		})
		v12.Completed:Connect(function()
			if v13 == count and not v5 then
				make4.Visible = false
			end
		end)
		v12:Play()
	end
end

local evaluate

make8.Activated:Connect(function()
	toggleSync() -- inferred equivalent call
	evaluate()
end)

evaluate = function()
	local v13

	if not v then
		v13 = getNearStage()
	end

	local now = os.clock()
	local isEnabled = FreePlaySyncState.IsEnabled()
	local v14

	if v13 == nil then
		v14 = false
	else
		v14 = countActivePlayers(v13) >= 2
	end

	local v15 = v8 == nil or v8.Visible
	local visible

	if v13 == nil then
		visible = false
	else
		visible = v15 and (isEnabled or v14)
	end

	make2.Visible = visible
	local v16

	if v5 then
		v16 = visible and not isEnabled and now - v4 <= 12
	else
		v16 = visible and not isEnabled and v14 and now - v3 > 90
	end

	setCardVisible(v16)
end

make2.Activated:Connect(function()
	evaluate()
end)

instrumentHUDUpdate.OnClientEvent:Connect(function(p)
	v = p == true
	evaluate()
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		evaluate()
	end
end)