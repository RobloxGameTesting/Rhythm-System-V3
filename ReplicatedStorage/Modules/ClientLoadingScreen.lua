local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(20, 20, 22)
local color2 = Color3.fromRGB(240, 240, 242)
local color3 = Color3.fromRGB(150, 150, 155)
local color4 = Color3.fromRGB(240, 180, 70)

local clientLoadingScreen = nil
local backdrop = nil
local card = nil
local textLabel = nil
local textLabel2 = nil
local frame = nil
local frame2 = nil
local textLabel3 = nil

local function build()
	if clientLoadingScreen then
		return
	end

	clientLoadingScreen = Instance.new("ScreenGui")
	clientLoadingScreen.Name = "ClientLoadingScreen"
	clientLoadingScreen.ResetOnSpawn = false
	clientLoadingScreen.DisplayOrder = 50
	clientLoadingScreen.Enabled = false
	clientLoadingScreen.Parent = PlayerGui

	backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	backdrop.BackgroundTransparency = 0.5
	backdrop.Parent = clientLoadingScreen

	card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	card.Size = UDim2.new(0, 260, 0, 100)
	card.BackgroundColor3 = color
	card.Parent = clientLoadingScreen

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = card

	textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -20, 0, 20)
	textLabel.Position = UDim2.new(0, 10, 0, 12)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 14
	textLabel.TextColor3 = color2
	textLabel.Parent = card

	textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, -20, 0, 14)
	textLabel2.Position = UDim2.new(0, 10, 0, 34)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextSize = 11
	textLabel2.TextColor3 = color3
	textLabel2.Text = "Loading..."
	textLabel2.Parent = card

	frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 6)
	frame.Position = UDim2.new(0, 10, 0, 58)
	frame.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
	frame.Parent = card

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(1, 0)
	uiCorner2.Parent = frame

	frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(0, 0, 1, 0)
	frame2.BackgroundColor3 = color4
	frame2.BorderSizePixel = 0
	frame2.Parent = frame

	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(1, 0)
	uiCorner3.Parent = frame2

	textLabel3 = Instance.new("TextLabel")
	textLabel3.Size = UDim2.new(1, -20, 0, 14)
	textLabel3.Position = UDim2.new(0, 10, 0, 72)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = Enum.Font.Gotham
	textLabel3.TextSize = 11
	textLabel3.TextColor3 = color3
	textLabel3.TextXAlignment = Enum.TextXAlignment.Right
	textLabel3.Text = "0%"
	textLabel3.Parent = card
end

local ClientLoadingScreen = {}

function ClientLoadingScreen.Show(text)
	build()
	textLabel.Text = text
	textLabel2.Text = "Loading stems..."
	frame2.Size = UDim2.new(0, 0, 1, 0)
	textLabel3.Text = "0%"
	clientLoadingScreen.Enabled = true
end

function ClientLoadingScreen.SetProgress(value, text)
	if not clientLoadingScreen then
		return
	end

	frame2.Size = UDim2.new(math.clamp(value, 0, 1), 0, 1, 0)
	textLabel3.Text = math.floor(math.clamp(value, 0, 1) * 100) .. "%"

	if text then
		textLabel2.Text = text
	end
end

function ClientLoadingScreen.Hide()
	if clientLoadingScreen then
		clientLoadingScreen.Enabled = false
	end
end

return ClientLoadingScreen