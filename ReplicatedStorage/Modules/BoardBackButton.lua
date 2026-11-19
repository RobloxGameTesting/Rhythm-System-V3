local TweenService = game:GetService("TweenService")

local color = Color3.fromRGB(29, 29, 32)
local color2 = Color3.fromRGB(46, 46, 50)
local color3 = Color3.fromRGB(232, 222, 196)
local color4 = Color3.fromRGB(176, 34, 28)
local color5 = Color3.fromRGB(122, 124, 130)

local function pickFont()
	return pcall(function()
		return Enum.Font.SpecialElite
	end) and Enum.Font.SpecialElite or Enum.Font.GothamBlack
end

local function frame(parent, items) -- 12 equivalent calls inferred from this helper
	local frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.Active = false

	for k, item in pairs(items) do
		frame2[k] = item
	end

	frame2.Parent = parent
	return frame2
end

return {
	Style = function(self)
		if self:GetAttribute("TapeStyled") then
			return
		end

		self:SetAttribute("TapeStyled", true)

		for _, child in ipairs(self:GetChildren()) do
			if child:IsA("UICorner") or child:IsA("UIStroke") then
				child:Destroy()
			end
		end

		self.BackgroundTransparency = 1
		self.AutoButtonColor = false
		self.TextTransparency = 1
		self.TextStrokeTransparency = 1

		local random = Random.new(4242)

		local parent = frame(self, { -- inferred equivalent call
			Name = "TapeSkin",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 1
		})

		local parent2 = frame(parent, { -- inferred equivalent call
			Name = "Base",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 1
		})
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Color = ColorSequence.new(color2, color)
		uiGradient.Parent = parent2

		local v = { 0.1, 0.3, 0.5, 0.72, 0.9 }

		for i = 0, 1 do
			for _, v2 in ipairs(v) do
				local integer = random:NextInteger(7, 12)
				frame(parent, { -- inferred equivalent call
					Name = "Tooth",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(i, random:NextInteger(-2, 2), v2 + random:NextNumber(-0.05, 0.05), 0),
					Size = UDim2.fromOffset(integer, integer),
					Rotation = 45 + random:NextInteger(-10, 10),
					BackgroundColor3 = color,
					ZIndex = 1
				})
			end
		end

		frame(parent, { -- inferred equivalent call
			Name = "Edge",
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.86,
			ZIndex = 2
		})
		frame(parent, { -- inferred equivalent call
			Name = "Edge",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.3,
			ZIndex = 2
		})

		for _ = 1, 7 do
			frame(parent, { -- inferred equivalent call
				Name = "Scuff",
				Position = UDim2.new(random:NextNumber(0.03, 0.8), 0, random:NextNumber(0.05, 0.9), 0),
				Size = UDim2.fromOffset(random:NextInteger(12, 40), random:NextInteger(1, 2)),
				Rotation = random:NextInteger(-6, 6),
				BackgroundColor3 = Color3.fromRGB(190, 190, 184),
				BackgroundTransparency = random:NextNumber(0.72, 0.88),
				ZIndex = 2
			})
		end

		for _ = 1, 9 do
			local integer = random:NextInteger(2, 4)
			local parent3 = frame(parent, { -- inferred equivalent call
				Name = "Speck",
				Position = UDim2.new(random:NextNumber(0.05, 0.92), 0, random:NextNumber(0.1, 0.85), 0),
				Size = UDim2.fromOffset(integer, integer),
				BackgroundColor3 = Color3.fromRGB(170, 165, 150),
				BackgroundTransparency = random:NextNumber(0.6, 0.8),
				ZIndex = 2
			})

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0.5, 0)
			uiCorner.Parent = parent3
		end

		frame(frame(parent, { -- inferred equivalent call
			Name = "RedPiece",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.03, 0, 0.06, 0),
			Size = UDim2.fromOffset(40, 12),
			Rotation = -34,
			BackgroundColor3 = color4,
			ZIndex = 3
		}), {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.6,
			ZIndex = 3
		})
		frame(frame(parent, { -- inferred equivalent call
			Name = "GreyPiece",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.97, 0, 0.94, 0),
			Size = UDim2.fromOffset(32, 11),
			Rotation = 30,
			BackgroundColor3 = color5,
			ZIndex = 3
		}), {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.6,
			ZIndex = 3
		})

		local frame2 = frame(parent, { -- inferred equivalent call
			Name = "Hover",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = color3,
			BackgroundTransparency = 1,
			ZIndex = 4
		})

		local face = Instance.new("TextLabel")
		face.Name = "Face"
		face.BackgroundTransparency = 1
		face.Active = false
		face.Size = UDim2.fromScale(1, 1)
		face.Font = pcall(function()
			return Enum.Font.SpecialElite
		end) and Enum.Font.SpecialElite or Enum.Font.GothamBlack
		face.RichText = true
		face.TextColor3 = color3
		face.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		face.TextStrokeTransparency = 0.55
		face.ZIndex = 6
		face.Parent = self

		local function sync()
			local text = self.Text
			local text2, v2 = string.match(text, "^(.-)%s*(%[.-%])%s*$")

			if not text2 then
				text2 = text
				v2 = nil
			end

			local textSize = math.clamp(math.floor(self.AbsoluteSize.Y * 0.5), 15, 26)
			face.TextSize = textSize

			if v2 then
				face.Text = string.format(
					"%s  <font size=\"%d\" color=\"rgb(206,64,54)\">%s</font>",
					text2,
					math.max(11, (math.floor(textSize * 0.72))),
					v2
				)
			else
				face.Text = text2
			end
		end
		sync()
		self:GetPropertyChangedSignal("Text"):Connect(sync)
		self:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)

		local uiScale = Instance.new("UIScale")
		uiScale.Parent = self
		local rotation = self.Rotation
		local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		self.MouseEnter:Connect(function()
			TweenService:Create(frame2, tweenInfo, { BackgroundTransparency = 0.9 }):Play()
			TweenService:Create(self, tweenInfo, { Rotation = 0 }):Play()
		end)
		self.MouseLeave:Connect(function()
			TweenService:Create(frame2, tweenInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(self, tweenInfo, { Rotation = rotation }):Play()
			TweenService:Create(uiScale, tweenInfo, { Scale = 1 }):Play()
		end)
		self.MouseButton1Down:Connect(function()
			TweenService:Create(uiScale, tweenInfo, { Scale = 0.96 }):Play()
		end)
		self.MouseButton1Up:Connect(function()
			TweenService:Create(uiScale, tweenInfo, { Scale = 1 }):Play()
		end)
	end
}