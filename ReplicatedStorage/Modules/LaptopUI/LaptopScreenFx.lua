local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Theme = require(script.Parent.Theme)

local v = {}

local function frame(parent, items) -- 9 equivalent calls inferred from this helper
	local frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.Active = false
	frame2.ZIndex = 60

	for k, item in pairs(items) do
		frame2[k] = item
	end

	frame2.Parent = parent
	return frame2
end

local function edge(parent, items, p, rotation)
	local parent2 = frame(parent, items) -- inferred equivalent call
	parent2.BackgroundColor3 = Color3.new(0, 0, 0)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = rotation
	uiGradient.Transparency = NumberSequence.new(p)
	uiGradient.Parent = parent2
	return parent2
end

return {
	Attach = function(instance)
		if v[instance] then
			return
		end

		v[instance] = true

		local parent = frame(instance, { -- inferred equivalent call
			Name = "ScreenFx_Local",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(1, -20, 1, -20)
		})

		local random = Random.new()

		for i = 0, 75 do
			frame(parent, { -- inferred equivalent call
				BackgroundColor3 = Theme.Colors.Scanline,
				BackgroundTransparency = 0.93,
				Position = UDim2.new(0, 0, i / 76, 0),
				Size = UDim2.new(1, 0, 0, 1)
			})
		end

		edge(
			parent,
			{ Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0.18, 0) },
			{ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) },
			90
		)
		edge(
			parent,
			{
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0.18, 0)
			},
			{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.3) },
			90
		)
		edge(
			parent,
			{ Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.1, 0, 1, 0) },
			{ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) },
			0
		)
		edge(
			parent,
			{
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0.1, 0, 1, 0)
			},
			{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.35) },
			0
		)

		local parent2 = frame(parent, { -- inferred equivalent call
			BackgroundColor3 = Theme.Colors.Glow,
			BackgroundTransparency = 0.9,
			Size = UDim2.new(1, 0, 0.45, 0)
		})

		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.9),
			NumberSequenceKeypoint.new(1, 1)
		})
		uiGradient.Parent = parent2

		local v2 = {}

		for i = 1, 70 do
			v2[i] = frame(parent, { -- inferred equivalent call
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.86,
				Size = UDim2.new(0, 1, 0, 1),
				Position = UDim2.fromScale(random:NextNumber(), random:NextNumber())
			})
		end

		local parent3 = frame(parent, { -- inferred equivalent call
			BackgroundColor3 = Theme.Colors.Glow,
			BackgroundTransparency = 0,
			Position = UDim2.new(0, 0, -0.2, 0),
			Size = UDim2.new(1, 0, 0, 26)
		})

		local uiGradient2 = Instance.new("UIGradient")
		uiGradient2.Rotation = 90
		uiGradient2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.93),
			NumberSequenceKeypoint.new(1, 1)
		})

		uiGradient2.Parent = parent3

		local parent4 = frame(parent, { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }) -- inferred equivalent call
		local v3 = { Theme.Colors.GhostCyan, Theme.Colors.GhostRed, Theme.Colors.Glow }
		local function glitch()
			for i = 1, random:NextInteger(3, 6) do
				local number = random:NextNumber(0.03, 0.97)
				local number2 = random:NextNumber(0, 0.5)
				local frame2 = frame(parent4, { -- inferred equivalent call
					BackgroundColor3 = v3[(i - 1) % #v3 + 1],
					BackgroundTransparency = random:NextNumber(0.4, 0.65),
					Position = UDim2.new(number2, 0, number, 0),
					Size = UDim2.new(random:NextNumber(0.15, 0.6), 0, 0, random:NextInteger(1, 3))
				})

				TweenService:Create(frame2, TweenInfo.new(random:NextNumber(0.1, 0.22), Enum.EasingStyle.Quad), {
					BackgroundTransparency = 1,
					Position = UDim2.new(number2 + random:NextNumber(-0.12, 0.12), 0, number, 0)
				}):Play()
				task.delay(0.3, function()
					frame2:Destroy()
				end)
			end

			local frame2 = frame(parent4, { -- inferred equivalent call
				BackgroundColor3 = Theme.Colors.Glow,
				BackgroundTransparency = 0.93,
				Size = UDim2.fromScale(1, 1)
			})

			TweenService:Create(frame2, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
			task.delay(0.2, function()
				frame2:Destroy()
			end)
		end

		local function startRoll()
			parent3.Position = UDim2.new(0, 0, -0.2, 0)
			TweenService:Create(parent3, TweenInfo.new(2.6, Enum.EasingStyle.Linear), {
				Position = UDim2.new(0, 0, 1.05, 0)
			}):Play()
		end

		local v4 = 0
		local v5 = os.clock() + random:NextNumber(2, 5)
		local v6 = os.clock() + random:NextNumber(3, 7)
		local v7 = 0
		local visible = false

		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if instance.Parent then
				local now = os.clock()

				if v7 <= now then
					v7 = now + 0.5
					local currentCamera = Workspace.CurrentCamera
					local adornee = instance.Adornee or instance.Parent
					visible = Workspace:GetAttribute("LaptopFxEnabled") ~= false
						and currentCamera ~= nil
						and adornee ~= nil
						and adornee:IsA("BasePart")
						and (currentCamera.CFrame.Position - adornee.Position).Magnitude <= 45
					parent.Visible = visible
				end

				if not visible then
					return
				end

				if v4 <= now then
					v4 = now + 0.12

					for _, v8 in ipairs(v2) do
						v8.Position = UDim2.fromScale(random:NextNumber(), random:NextNumber())
						v8.BackgroundTransparency = random:NextNumber(0.8, 0.93)
					end
				end

				if v5 <= now then
					v5 = now + random:NextNumber(3.5, 8)
					glitch()
				end

				if v6 <= now then
					v6 = now + random:NextNumber(7, 12)
					startRoll()
				end
			else
				heartbeatConnection:Disconnect()
				v[instance] = nil
			end
		end)
	end
}