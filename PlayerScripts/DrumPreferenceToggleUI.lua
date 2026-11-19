local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SetDrumPreference = RemoteEvents:WaitForChild("SetDrumPreference")
local DrumPreferenceUpdate = RemoteEvents:WaitForChild("DrumPreferenceUpdate")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v2 = { DoublePedalEnabled = false, FlipEnabled = false }
local v3 = false

local color = Color3.fromRGB(18, 18, 20)
local color2 = Color3.fromRGB(180, 180, 185)
local color3 = Color3.fromRGB(190, 150, 80)
local color4 = Color3.fromRGB(30, 30, 34)

local color5 = Color3.fromRGB(35, 28, 15)

local udim = UDim.new(0, 6)

local drumPreferenceToggleUI = Instance.new("ScreenGui")
drumPreferenceToggleUI.Name = "DrumPreferenceToggleUI"
drumPreferenceToggleUI.ResetOnSpawn = false
drumPreferenceToggleUI.Enabled = false
drumPreferenceToggleUI.Parent = PlayerGui

local UserInputService2 = game:GetService("UserInputService")

local drumButton = Instance.new("TextButton")
drumButton.Name = "DrumButton"
drumButton.Size = UDim2.new(0, 84, 0, 24)
drumButton.AnchorPoint = Vector2.new(1, 1)
drumButton.Position = UDim2.new(1, -16, 1, -58)
drumButton.BackgroundColor3 = color
drumButton.BackgroundTransparency = 0.45
drumButton.AutoButtonColor = false
drumButton.TextColor3 = color2
drumButton.Font = Enum.Font.GothamMedium
drumButton.TextSize = v and 11 or 12
drumButton.Text = "Drum ▲"
drumButton.ZIndex = 6
drumButton.Parent = drumPreferenceToggleUI

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = udim
uiCorner.Parent = drumButton

local dropdown = Instance.new("Frame")
dropdown.Name = "Dropdown"
dropdown.AnchorPoint = Vector2.new(1, 1)
dropdown.Position = UDim2.new(1, -16, 1, -88)
dropdown.Size = UDim2.new(0, 150, 0, 0)
dropdown.BackgroundColor3 = color
dropdown.BackgroundTransparency = 0.45
dropdown.ClipsDescendants = true
dropdown.Visible = false
dropdown.ZIndex = 6
dropdown.Parent = drumPreferenceToggleUI

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = udim
uiCorner2.Parent = dropdown

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 6)
uiPadding.PaddingBottom = UDim.new(0, 6)
uiPadding.PaddingLeft = UDim.new(0, 6)
uiPadding.PaddingRight = UDim.new(0, 6)
uiPadding.Parent = dropdown

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = dropdown

local function makeRow(layoutOrder)
	local row = Instance.new("TextButton")
	row.Name = "Row"
	row.Size = UDim2.new(1, 0, 0, 26)
	row.BackgroundColor3 = color4
	row.AutoButtonColor = false
	row.TextColor3 = color2
	row.Font = Enum.Font.GothamMedium
	row.TextSize = v and 10 or 11
	row.LayoutOrder = layoutOrder
	row.ZIndex = 7
	row.Parent = dropdown

	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 5)
	uiCorner3.Parent = row

	return row
end

local row = makeRow(1)
local row2 = makeRow(2)

local function refreshRows() -- 1 equivalent call inferred from this helper
	row.Text = "Double Pedal: " .. (v2.DoublePedalEnabled and "ON" or "OFF")
	row.BackgroundColor3 = v2.DoublePedalEnabled and color3 or color4
	row.TextColor3 = v2.DoublePedalEnabled and color5 or color2

	row2.Text = "Flip (Left-Handed): " .. (v2.FlipEnabled and "ON" or "OFF")
	row2.BackgroundColor3 = v2.FlipEnabled and color3 or color4
	row2.TextColor3 = v2.FlipEnabled and color5 or color2
end

local function setDropdownOpen(p)
	v3 = p

	if p then
		dropdown.Visible = true
		drumButton.Text = "Drum ▼"
		TweenService:Create(dropdown, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 150, 0, 68)
		}):Play()
	else
		drumButton.Text = "Drum ▲"
		local tween = TweenService:Create(
			dropdown,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Size = UDim2.new(0, 150, 0, 0) }
		)

		tween.Completed:Connect(function()
			if not v3 then
				dropdown.Visible = false
			end
		end)
		tween:Play()
	end
end

drumButton.MouseButton1Click:Connect(function()
	setDropdownOpen(not v3)
end)

UserInputService2.InputBegan:Connect(function(input, gameProcessed)
	if not v3 or gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		setDropdownOpen(false)
	end
end)

row.MouseButton1Click:Connect(function()
	SetDrumPreference:FireServer("DoublePedal", not v2.DoublePedalEnabled)
end)

row2.MouseButton1Click:Connect(function()
	SetDrumPreference:FireServer("Flip", not v2.FlipEnabled)
end)

DrumPreferenceUpdate.OnClientEvent:Connect(function(p)
	v2 = p
	refreshRows() -- inferred equivalent call
end)

InstrumentHUDUpdate.OnClientEvent:Connect(function(p, p2)
	local enabled = p and p2 == "Drum"
	drumPreferenceToggleUI.Enabled = enabled

	if not enabled then
		setDropdownOpen(false)
	end
end)
row.Text = "Double Pedal: " .. (v2.DoublePedalEnabled and "ON" or "OFF")
row.BackgroundColor3 = v2.DoublePedalEnabled and color3 or color4
row.TextColor3 = v2.DoublePedalEnabled and color5 or color2

row2.Text = "Flip (Left-Handed): " .. (v2.FlipEnabled and "ON" or "OFF")
local backgroundColor

if v2.FlipEnabled then
	backgroundColor = color3 or color4
else
	backgroundColor = color4
end

row2.BackgroundColor3 = backgroundColor
local textColor

if v2.FlipEnabled then
	textColor = color5 or color2
else
	textColor = color2
end

row2.TextColor3 = textColor