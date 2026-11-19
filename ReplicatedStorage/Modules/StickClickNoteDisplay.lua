local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NoteLaneUI = require(ReplicatedStorage.Modules.NoteLaneUI)

local color = Color3.fromRGB(150, 125, 45)
local color2 = Color3.fromRGB(255, 255, 255)

local function makeClickGem(stickClickOverlay, number)
	local clickGem = Instance.new("Frame")
	clickGem.Name = "ClickGem"
	clickGem.AnchorPoint = Vector2.new(0.5, 0.5)
	clickGem.Size = UDim2.new(0, 40, 0, 40)
	clickGem.Rotation = 45
	clickGem.BackgroundColor3 = color
	clickGem.BorderSizePixel = 0
	clickGem.ZIndex = 5
	clickGem.Parent = stickClickOverlay

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = clickGem

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color2
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.2
	uiStroke.Parent = clickGem

	local number2 = Instance.new("TextLabel")
	number2.Name = "Number"
	number2.AnchorPoint = Vector2.new(0.5, 0.5)
	number2.Position = UDim2.new(0.5, 0, 0.5, 0)
	number2.Size = UDim2.new(1, 0, 1, 0)
	number2.Rotation = -45
	number2.BackgroundTransparency = 1
	number2.Text = tostring(number)
	number2.TextColor3 = Color3.new(1, 1, 1)
	number2.TextScaled = true
	number2.Font = Enum.Font.GothamBold
	number2.ZIndex = 6
	number2.Parent = clickGem

	return clickGem
end

local function playSuccessFlourish(gem)
	local number = gem:FindFirstChild("Number")
	TweenService:Create(gem, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 64, 0, 64),
		BackgroundTransparency = 1
	}):Play()

	if number then
		TweenService:Create(number, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
	end

	local uiStroke = gem:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		TweenService:Create(uiStroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
	end

	task.delay(0.25, function()
		if gem then
			gem:Destroy()
		end
	end)
end

local function fadeOutQuiet(gem)
	local number = gem:FindFirstChild("Number")
	TweenService:Create(gem, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()

	if number then
		TweenService:Create(number, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
	end

	local uiStroke = gem:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		TweenService:Create(uiStroke, TweenInfo.new(0.15), { Transparency = 1 }):Play()
	end

	task.delay(0.2, function()
		if gem then
			gem:Destroy()
		end
	end)
end

return {
	Show = function(list, value)
		local trackFrame = NoteLaneUI.GetTrackFrame()
		local laneRailXOffset = NoteLaneUI.GetLaneRailXOffset(3)
		local hitLineY = NoteLaneUI.GetHitLineY()

		if not (trackFrame and laneRailXOffset and hitLineY) then
			return
		end

		local stickClickOverlay = Instance.new("Frame")
		stickClickOverlay.Name = "StickClickOverlay"
		stickClickOverlay.BackgroundTransparency = 1
		stickClickOverlay.Size = UDim2.new(1, 0, 1, 0)
		stickClickOverlay.ZIndex = 5
		stickClickOverlay.Parent = trackFrame

		local v = {}
		local v2 = value or 1.2

		for i, item in ipairs(list) do
			v[i] = {
				offset = item,
				number = 5 - i,
				gem = nil,
				resolved = false
			}
		end

		local lastTime = os.clock()

		local function resolveNote(state, p)
			if state.resolved or not state.gem then
				return
			end

			state.resolved = true

			if p then
				playSuccessFlourish(state.gem)
			else
				fadeOutQuiet(state.gem)
			end
		end

		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or input.KeyCode ~= Enum.KeyCode.V then
				return
			end

			local v3 = os.clock() - lastTime

			for _, v4 in ipairs(v) do
				if not v4.resolved and math.abs(v3 - v4.offset) <= 0.15 then
					if v4.resolved or not v4.gem then
						break
					end

					v4.resolved = true

					playSuccessFlourish(v4.gem)
					break
				end
			end
		end)

		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v3 = os.clock() - lastTime
			local flag = true

			for _, v4 in ipairs(v) do
				local v5 = v4.offset - v3

				if v4.resolved then
					continue
				end

				if v2 < v5 then
					flag = false
				elseif v5 < -0.3 then
					if not v4.resolved and v4.gem then
						v4.resolved = true

						fadeOutQuiet(v4.gem)
					end
				else
					flag = false

					if not v4.gem then
						v4.gem = makeClickGem(stickClickOverlay, v4.number)
					end

					local v6 = math.clamp(1 - v5 / v2, 0, 1) * hitLineY
					v4.gem.Position = UDim2.new(0, laneRailXOffset, 0, v6)
				end
			end

			if flag then
				heartbeatConnection:Disconnect()

				if inputBeganConnection then
					inputBeganConnection:Disconnect()
				end

				task.delay(0.5, function()
					stickClickOverlay:Destroy()
				end)
			end
		end)
	end
}