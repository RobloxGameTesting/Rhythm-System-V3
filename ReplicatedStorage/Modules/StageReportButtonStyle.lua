local TextService = game:GetService("TextService")

local color = Color3.fromRGB(18, 18, 20)
local color2 = Color3.fromRGB(180, 180, 185)
local color3 = Color3.fromRGB(190, 150, 80)
local color4 = Color3.fromRGB(120, 98, 60)
local color5 = Color3.fromRGB(176, 162, 124)
local color6 = Color3.fromRGB(60, 48, 32)

local function mk(className, items, parent) -- 10 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

return {
	Build = function(parent)
		local root = mk("Frame", { -- inferred equivalent call
			Name = "LastReportButton",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 16, 1, -16),
			Size = UDim2.fromOffset(90, 21),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false
		}, parent)

		mk("Frame", { -- inferred equivalent call
			Name = "Shadow",
			Position = UDim2.fromOffset(1, 2),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.65,
			BorderSizePixel = 0,
			Rotation = -0.8,
			ZIndex = 1
		}, root)

		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = "Paper",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Rotation = -0.8,
			ZIndex = 2
		}, root)

		mk("Frame", { -- inferred equivalent call
			Name = "Stain",
			Position = UDim2.new(0.78, 0, 0.5, 0),
			Size = UDim2.fromOffset(6, 4),
			BackgroundColor3 = color4,
			BackgroundTransparency = 0.75,
			BorderSizePixel = 0,
			ZIndex = 3
		}, parent2)

		local textLabel = mk("TextLabel", { -- inferred equivalent call
			Name = "Label",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextColor3 = color2,
			ZIndex = 5
		}, parent2)

		mk("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, textLabel) -- inferred equivalent call

		local function tape(name, p, p2, p3, p4, p5, p6, rotation, backgroundTransparency)
			local parent3 = mk("Frame", { -- inferred equivalent call
				Name = name,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(p, p2, p3, p4),
				Size = UDim2.fromOffset(p5, p6),
				Rotation = rotation,
				BackgroundColor3 = color5,
				BackgroundTransparency = backgroundTransparency,
				BorderSizePixel = 0,
				ZIndex = 6
			}, root)

			mk("Frame", { -- inferred equivalent call
				Position = UDim2.new(0, 2, 0.58, 0),
				Size = UDim2.new(0.6, 0, 0, 1),
				BackgroundColor3 = color6,
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				ZIndex = 7
			}, parent3)

			mk("Frame", { -- inferred equivalent call
				Position = UDim2.new(0.68, 0, 0.15, 0),
				Size = UDim2.fromOffset(4, 3),
				BackgroundColor3 = color6,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				ZIndex = 7
			}, parent3)

			return parent3
		end

		local button = mk("TextButton", { -- inferred equivalent call
			Name = "Click",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 12
		}, root)

		local v = false
		local v2 = false
		local function applyLook() -- 4 equivalent calls inferred from this helper
			if v then
				textLabel.TextColor3 = v2 and color3 or color2
				textLabel.TextTransparency = 0
			else
				textLabel.TextColor3 = color2
				textLabel.TextTransparency = 0.5
			end
		end
		button.MouseEnter:Connect(function()
			v2 = true
			applyLook() -- inferred equivalent call
		end)
		button.MouseLeave:Connect(function()
			v2 = false
			applyLook() -- inferred equivalent call
		end)

		local v3 = { Root = root, Button = button }
		function v3.SetState(value, p)
			textLabel.Text = string.upper(value)
			local success, result = pcall(function()
				return TextService:GetTextSize(
					textLabel.Text,
					textLabel.TextSize,
					textLabel.Font,
					Vector2.new(600, 100)
				)
			end)

			local x = success and math.ceil(result.X) or #textLabel.Text * 7
			root.Size = UDim2.fromOffset(x + 24 + 2, 21)
			v = p == true
			applyLook() -- inferred equivalent call
		end

		applyLook() -- inferred equivalent call
		return v3
	end
}