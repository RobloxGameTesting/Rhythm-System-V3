local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local loadingIndicatorUI = Instance.new("ScreenGui")
loadingIndicatorUI.Name = "LoadingIndicatorUI"
loadingIndicatorUI.ResetOnSpawn = false
loadingIndicatorUI.IgnoreGuiInset = true
loadingIndicatorUI.DisplayOrder = 150
loadingIndicatorUI.Parent = PlayerGui

local indicator = Instance.new("TextLabel")
indicator.Name = "Indicator"
indicator.AnchorPoint = Vector2.new(0, 1)
indicator.Position = UDim2.new(0, 10, 1, -10)
indicator.Size = UDim2.new(0, 260, 0, 16)
indicator.BackgroundTransparency = 1
indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
indicator.TextTransparency = 0.55
indicator.TextStrokeTransparency = 0.75
indicator.Font = Enum.Font.Gotham
indicator.TextSize = 12
indicator.TextXAlignment = Enum.TextXAlignment.Left
indicator.Text = ""
indicator.Visible = false
indicator.ZIndex = 40
indicator.Parent = loadingIndicatorUI

local v = 0
local LoadingIndicatorClient = {}

function LoadingIndicatorClient.Show(value)
	v += 1
	indicator.Text = value or "Preparing audio..."
	indicator.Visible = true
end

function LoadingIndicatorClient.Update(p)
	if v > 0 then
		indicator.Text = p or indicator.Text
	end
end

function LoadingIndicatorClient.Hide()
	v = math.max(0, v - 1)

	if v == 0 then
		indicator.Visible = false
	end
end

return LoadingIndicatorClient