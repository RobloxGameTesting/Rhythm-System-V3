local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(240, 200, 70)
local color4 = Color3.fromRGB(235, 90, 90)

local function toHex(color5) -- 4 equivalent calls inferred from this helper
	return string.format(
		"%02X%02X%02X",
		math.floor(color5.R * 255 + 0.5),
		math.floor(color5.G * 255 + 0.5),
		(math.floor(color5.B * 255 + 0.5))
	)
end

local hex = toHex(color) -- inferred equivalent call
local hex2 = toHex(color2) -- inferred equivalent call
local hex3 = toHex(color3) -- inferred equivalent call
local hex4 = toHex(color4) -- inferred equivalent call

local function pingHex(p) -- 1 equivalent call inferred from this helper
	if p <= 100 then
		return hex2
	end

	return if p <= 200 then hex3 else hex4
end

local perfStatsHUD = Instance.new("ScreenGui")
perfStatsHUD.Name = "PerfStatsHUD"
perfStatsHUD.ResetOnSpawn = false
perfStatsHUD.DisplayOrder = 0
perfStatsHUD.Enabled = SettingsState.GetShowPerfStats()
perfStatsHUD.Parent = PlayerGui

SettingsState.OnChanged(function()
	perfStatsHUD.Enabled = SettingsState.GetShowPerfStats()
end)

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.AnchorPoint = Vector2.new(0, 1)
stats.Position = UDim2.new(0, 24, 1, -3)
stats.Size = UDim2.new(0, 320, 0, 9)
stats.BackgroundTransparency = 1
stats.Font = Enum.Font.GothamMedium
stats.TextSize = 9
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextYAlignment = Enum.TextYAlignment.Center
stats.TextTransparency = 0.6
stats.TextStrokeTransparency = 0.85
stats.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
stats.RichText = true
stats.Active = false
stats.Text = ""
stats.Parent = perfStatsHUD

local count = 0
local total = 0

local function currentPingMs()
	local success, result = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)

	if success and typeof(result) == "number" then
		return result * 1000
	end

	return nil
end

RunService.RenderStepped:Connect(function(dt)
	if perfStatsHUD.Enabled then
		count += 1
		total += dt

		if total < 0.5 then
			return
		end

		local v = math.floor(count / total + 0.5)
		count = 0
		total = 0
		local success, result = pcall(function()
			return LocalPlayer:GetNetworkPing()
		end)
		local v2

		if success and typeof(result) == "number" then
			v2 = result * 1000
		end

		local v3

		if v2 then
			v3 = string.format("<font color=\"#%s\">Ping: %d ms</font>", pingHex(v2), (math.floor(v2 + 0.5))) -- inferred equivalent call
		else
			v3 = "<font color=\"#B4B4B9\">Ping: --</font>"
		end

		local serverLocation = workspace:GetAttribute("ServerLocation")

		local v4 = (typeof(serverLocation) ~= "string" or serverLocation == "")
			and "<font color=\"#B4B4B9\">Server: --</font>"
			or string.format("<font color=\"#%s\">Server: %s</font>", hex, serverLocation)

		stats.Text = string.format("<font color=\"#%s\">FPS: %d</font>   %s   %s", hex, v, v3, v4)
	else
		count = 0
		total = 0
	end
end)