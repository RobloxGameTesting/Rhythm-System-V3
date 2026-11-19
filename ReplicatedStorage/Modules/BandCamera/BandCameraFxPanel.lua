local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bandCamera = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BandCamera")
local BandCameraStyle = require(bandCamera:WaitForChild("BandCameraStyle"))
local BandCameraConfig = require(bandCamera:WaitForChild("BandCameraConfig"))
local Style = BandCameraConfig.Style

local color = Color3.fromRGB(245, 245, 247)
local color2 = Color3.fromRGB(160, 160, 170)
local color3 = Color3.fromRGB(88, 210, 150)
local color4 = Color3.fromRGB(60, 60, 70)
local color5 = Color3.fromRGB(23, 23, 27)
local color6 = Color3.fromRGB(24, 46, 38)
local color7 = Color3.fromRGB(16, 16, 20)
local color8 = Color3.fromRGB(240, 190, 90)

local v = { bg = 0.72, text = 0.45, stroke = 1 }
local v2 = { bg = 0.2, text = 0, stroke = 0.45 }
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function create(className, items, parent) -- 35 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

return {
	Create = function(self)
		local v3 = {
			Name = "FxButton",
			Text = "FX",
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = color,
			AutoButtonColor = false,
			BackgroundColor3 = color5,
			BackgroundTransparency = v.bg,
			TextTransparency = v.text,
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.new(0, 46, 0, 30),
			Visible = false,
			ZIndex = 20
		}
		local textButton = Instance.new("TextButton")
		local v4 = false
		local v5 = false
		local v6 = false
		local v7 = {}

		for k, v8 in pairs(v3) do
			textButton[k] = v8
		end

		textButton.Parent = self

		create("UICorner", { CornerRadius = UDim.new(0, 8) }, textButton) -- inferred equivalent call
		local uiStroke = create( -- inferred equivalent call
			"UIStroke",
			{
				Color = color4,
				Transparency = v.stroke,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			textButton
		)

		local function applyLook()
			local v8 = (v4 or v5) and v2 or v
			TweenService:Create(textButton, tweenInfo, {
				BackgroundTransparency = v8.bg,
				TextTransparency = v8.text
			}):Play()
			TweenService:Create(uiStroke, tweenInfo, { Transparency = v8.stroke }):Play()
			textButton.TextColor3 = v4 and color3 or color
		end
		textButton.MouseEnter:Connect(function()
			v5 = true
			applyLook()
		end)
		textButton.MouseLeave:Connect(function()
			v5 = false
			applyLook()
		end)

		local parent2 = self.Parent
		local bandCameraFxPanelGui = parent2 and parent2:FindFirstChild("BandCameraFxPanelGui")

		if bandCameraFxPanelGui then
			bandCameraFxPanelGui:Destroy()
		end

		local parent = create("ScreenGui", { -- inferred equivalent call
			Name = "BandCameraFxPanelGui",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 130,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, parent2)

		local folder = create("Frame", { -- inferred equivalent call
			Name = "FxPanel",
			BackgroundColor3 = color7,
			BackgroundTransparency = 0,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 262, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			Active = true,
			ZIndex = 10
		}, parent)

		create("UICorner", { CornerRadius = UDim.new(0, 10) }, folder) -- inferred equivalent call
		create("UIStroke", { -- inferred equivalent call
			Color = color4,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, folder)
		create( -- inferred equivalent call
			"UIPadding",
			{
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10)
			},
			folder
		)

		create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, folder) -- inferred equivalent call
		local uiScale = create("UIScale", { Scale = 1 }, folder) -- inferred equivalent call

		local function makeLabel(text, layoutOrder, p, value)
			return create("TextLabel", { -- inferred equivalent call
				Text = text,
				Font = Enum.Font.GothamBold,
				TextSize = value or 10,
				TextColor3 = p or color2,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 14),
				LayoutOrder = layoutOrder
			}, folder)
		end

		local function makeGrid(layoutOrder)
			local grid = create( -- inferred equivalent call
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = layoutOrder
				},
				folder
			)

			create( -- inferred equivalent call
				"UIGridLayout",
				{
					CellSize = UDim2.fromOffset(76, 26),
					CellPadding = UDim2.fromOffset(6, 6),
					SortOrder = Enum.SortOrder.LayoutOrder
				},
				grid
			)

			return grid
		end

		local function makeButton(parent3, text, value)
			local button = create("TextButton", { -- inferred equivalent call
				Text = text,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextColor3 = color,
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutoButtonColor = false,
				BackgroundColor3 = color5,
				BackgroundTransparency = 0.05,
				LayoutOrder = value or 0
			}, parent3)

			create("UICorner", { CornerRadius = UDim.new(0, 6) }, button) -- inferred equivalent call
			local stroke = create( -- inferred equivalent call
				"UIStroke",
				{ Color = color4, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border },
				button
			)
			return { button = button, stroke = stroke }
		end

		local function setActive(p, p2) -- 4 equivalent calls inferred from this helper
			p.button.BackgroundColor3 = p2 and color6 or color5
			p.button.TextColor3 = p2 and color3 or color
			p.stroke.Color = p2 and color3 or color4
		end

		local parent3 = create( -- inferred equivalent call
			"Frame",
			{ BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1 },
			folder
		)
		create("TextLabel", { -- inferred equivalent call
			Text = "DYNAMIC CAM FX",
			Font = Enum.Font.GothamBlack,
			TextSize = 12,
			TextColor3 = color,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -28, 1, 0)
		}, parent3)

		local button = makeButton(parent3, "X", 0)
		button.button.AnchorPoint = Vector2.new(1, 0)
		button.button.Position = UDim2.new(1, 0, 0, 0)
		button.button.Size = UDim2.fromOffset(22, 22)

		makeLabel("MODE", 2)
		local grid = makeGrid(3)
		local buttonsByMode = {}

		for i, mode in ipairs(Style.Modes) do
			local button2 = makeButton(grid, mode, i)
			buttonsByMode[mode] = button2
			button2.button.MouseButton1Click:Connect(function()
				BandCameraStyle.SetMode(mode)
			end)
		end

		makeLabel("STYLE", 4)
		local grid2 = makeGrid(5)

		local styleNames = { "Auto" }
		local buttons = {}

		for _, styleName in ipairs(Style.StyleNames) do
			styleNames[#styleNames + 1] = styleName
		end

		for i, v8 in ipairs(styleNames) do
			local button2 = makeButton(grid2, v8, i)
			buttons[v8] = button2
			button2.button.MouseButton1Click:Connect(function()
				BandCameraStyle.SetStyleOverride(v8)
			end)
		end

		makeLabel("EFFECTS (tap to toggle)", 6)
		local grid3 = makeGrid(7)
		local buttonsByEffectName = {}

		for i, effectName in ipairs(Style.EffectNames) do
			local button2 = makeButton(grid3, Style.EffectLabels[effectName] or effectName, i)
			buttonsByEffectName[effectName] = button2
			button2.button.MouseButton1Click:Connect(function()
				local settings = BandCameraStyle.GetSettings()
				BandCameraStyle.SetEffect(effectName, not settings.Effects[effectName])
			end)
		end

		local parent4 = create( -- inferred equivalent call
			"Frame",
			{ BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 8 },
			folder
		)
		local textLabel = create("TextLabel", { -- inferred equivalent call
			Text = "INTENSITY (effects)",
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = color2,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -44, 1, 0)
		}, parent4)

		local textLabel2 = create("TextLabel", { -- inferred equivalent call
			Text = "15%",
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = color3,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 44, 1, 0)
		}, parent4)

		local parent5 = create( -- inferred equivalent call
			"Frame",
			{ BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 9 },
			folder
		)
		local parent6 = create("Frame", { -- inferred equivalent call
			BackgroundColor3 = color4,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 7, 0.5, 0),
			Size = UDim2.new(1, -14, 0, 6)
		}, parent5)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent6) -- inferred equivalent call
		local parent7 = create( -- inferred equivalent call
			"Frame",
			{ BackgroundColor3 = color3, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0) },
			parent6
		)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent7) -- inferred equivalent call
		local parent8 = create("Frame", { -- inferred equivalent call
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(14, 14)
		}, parent6)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent8) -- inferred equivalent call
		create("UIStroke", { -- inferred equivalent call
			Color = color3,
			Thickness = 1.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, parent8)
		local textButton2 = create( -- inferred equivalent call
			"TextButton",
			{
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0)
			},
			parent5
		)

		local v8 = false
		local function setFromX(x) -- 2 equivalent calls inferred from this helper
			local x2 = parent6.AbsoluteSize.X

			if x2 <= 0 then
				return
			end

			BandCameraStyle.SetIntensity((math.clamp((x - parent6.AbsolutePosition.X) / x2, 0, 1)))
		end
		local function isPointer(input): boolean -- 2 equivalent calls inferred from this helper
			return input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
		end

		textButton2.InputBegan:Connect(function(input)
			if isPointer(input) then -- inferred equivalent call
				v8 = true
				setFromX(input.Position.X) -- inferred equivalent call
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if
				v8
				and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			then
				setFromX(input.Position.X) -- inferred equivalent call
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if isPointer(input) then -- inferred equivalent call
				v8 = false
			end
		end)

		local button2 = makeButton(folder, "PRESETS", 10)
		button2.button.TextXAlignment = Enum.TextXAlignment.Left
		button2.button.Size = UDim2.new(1, 0, 0, 26)
		create("UIPadding", { PaddingLeft = UDim.new(0, 10) }, button2.button) -- inferred equivalent call
		local textLabel3 = create("TextLabel", { -- inferred equivalent call
			Text = "v",
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = color,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(16, 16)
		}, button2.button)
		local parent9 = create("Frame", { -- inferred equivalent call
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			LayoutOrder = 11
		}, folder)

		create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, parent9) -- inferred equivalent call
		local visible2 = false
		button2.button.MouseButton1Click:Connect(function()
			visible2 = not visible2
			parent9.Visible = visible2
			textLabel3.Text = visible2 and "^" or "v"
			setActive(button2, visible2) -- inferred equivalent call
		end)

		local label = makeLabel("", 12, color2, 10)
		label.Visible = false
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.AutomaticSize = Enum.AutomaticSize.Y
		label.Size = UDim2.new(1, 0, 0, 14)

		local count = 0
		local function setStatus(value, color9, duration) -- 8 equivalent calls inferred from this helper
			count += 1
			local v9 = count
			label.Text = value or ""
			label.Visible = (value or "") ~= ""
			label.TextColor3 = color9 or color2

			if duration then
				task.delay(duration, function()
					if v9 == count then
						label.Text = ""
						label.Visible = false
					end
				end)
			end
		end

		local bandCameraFxPresetRequest = nil
		local function getRemote() -- 1 equivalent call inferred from this helper
			if bandCameraFxPresetRequest and bandCameraFxPresetRequest.Parent then
				return bandCameraFxPresetRequest
			end

			local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
			bandCameraFxPresetRequest = remoteEvents and remoteEvents:WaitForChild("BandCameraFxPresetRequest", 5)
				or nil
			return bandCameraFxPresetRequest
		end

		local function invoke(p, p2, p3)
			local remote = getRemote() -- inferred equivalent call

			if not remote then
				return { Ok = false, Reason = "Presets are unavailable right now." }
			end

			local success, result = pcall(function()
				return remote:InvokeServer(p, p2, p3)
			end)

			if success and type(result) == "table" then
				return result
			end

			return { Ok = false, Reason = "Presets are unavailable right now." }
		end

		local v9 = {}
		local v10 = {}
		local flag = false
		local v11 = nil

		local function renderPresets()
			for i = 1, 3 do
				local v12 = v10[i]
				local v13 = v9[i]
				local v14 = v13 == nil or v13.Empty ~= false
				v12.label.Text = ("Preset %d%s"):format(i, v14 and "  (empty)" or "")
				v12.label.TextColor3 = v14 and color2 or color
				v12.load.button.TextTransparency = v14 and 0.6 or 0
				v12.del.button.TextTransparency = v14 and 0.6 or 0
				local v15 = v11
				v12.save.button.Text = v15 and v15.slot == i and v15.action == "Save" and "SURE?" or "SAVE"
				v12.del.button.Text = v15 and v15.slot == i and v15.action == "Delete" and "SURE?" or "DEL"
			end
		end

		local function loadSlots() -- 1 equivalent call inferred from this helper
			task.spawn(function()
				local v12 = invoke("List")

				if v12.Ok and type(v12.Slots) == "table" then
					v9 = v12.Slots
					renderPresets()
				else
					setStatus(v12.Reason or "Presets are unavailable right now.", color8, 4) -- inferred equivalent call
				end
			end)
		end

		local function needsConfirm(i, action): boolean
			local v12 = v9[i]

			if v12 == nil or v12.Empty ~= false then
				return false
			end

			local v13 = v11

			if v13 and v13.slot == i and v13.action == action then
				v11 = nil
				renderPresets()
				return false
			else
				local token = (v13 and v13.token or 0) + 1
				v11 = { slot = i, action = action, token = token }
				renderPresets()
				task.delay(3, function()
					if v11 and v11.token == token then
						v11 = nil
						renderPresets()
					end
				end)
				return true
			end
		end

		local function runAction(i, p) -- 3 equivalent calls inferred from this helper
			if flag then
				return
			end

			flag = true
			task.spawn(function()
				if p == "Load" then
					local v12 = invoke("Get", i)

					if v12.Ok and BandCameraStyle.Import(v12.Fx) then
						setStatus(("Loaded Preset %d"):format(i), color3, 3) -- inferred equivalent call
					else
						setStatus(v12.Reason or "Couldn't load preset.", color8, 4) -- inferred equivalent call
					end
				elseif p == "Save" then
					local v12 = invoke("Save", i, BandCameraStyle.Export())

					if v12.Ok then
						v9 = v12.Slots or v9
						renderPresets()
						setStatus(("Saved to Preset %d"):format(i), color3, 3) -- inferred equivalent call
					else
						setStatus(v12.Reason or "Couldn't save preset.", color8, 4) -- inferred equivalent call
					end
				elseif p == "Delete" then
					local v12 = invoke("Delete", i)

					if v12.Ok then
						v9 = v12.Slots or v9
						renderPresets()
						setStatus(("Deleted Preset %d"):format(i), color2, 3) -- inferred equivalent call
					else
						setStatus(v12.Reason or "Couldn't delete preset.", color8, 4) -- inferred equivalent call
					end
				end

				flag = false
			end)
		end

		for i = 1, 3 do
			local parent10 = create( -- inferred equivalent call
				"Frame",
				{ BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = i },
				parent9
			)
			local label2 = create("TextLabel", { -- inferred equivalent call
				Text = "",
				Font = Enum.Font.GothamMedium,
				TextSize = 10,
				TextColor3 = color,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0, 86, 1, 0)
			}, parent10)

			local function rowButton(text, p)
				local button3 = makeButton(parent10, text, 0)
				button3.button.AnchorPoint = Vector2.new(1, 0)
				button3.button.Position = UDim2.new(1, p, 0, 0)
				button3.button.Size = UDim2.fromOffset(46, 26)
				return button3
			end

			local del = rowButton("DEL", 0)
			local save = rowButton("SAVE", -52)
			local load = rowButton("LOAD", -104)
			v10[i] = { label = label2, load = load, save = save, del = del }

			load.button.MouseButton1Click:Connect(function()
				v11 = nil
				renderPresets()
				local v12 = v9[i]

				if v12 == nil or v12.Empty ~= false then
					setStatus("This preset is empty.", color8, 3) -- inferred equivalent call
				else
					runAction(i, "Load") -- inferred equivalent call
				end
			end)
			save.button.MouseButton1Click:Connect(function()
				if needsConfirm(i, "Save") then
					return
				end

				runAction(i, "Save") -- inferred equivalent call
			end)
			del.button.MouseButton1Click:Connect(function()
				local v12 = v9[i]

				if v12 == nil or v12.Empty ~= false or needsConfirm(i, "Delete") then
					return
				end

				runAction(i, "Delete") -- inferred equivalent call
			end)
		end

		renderPresets()

		local label2 = makeLabel("", 13, color2, 10)

		local function refresh()
			local settings = BandCameraStyle.GetSettings()

			for k, v12 in pairs(buttonsByMode) do
				setActive(v12, settings.Mode == k) -- inferred equivalent call
			end

			for k, v12 in pairs(buttons) do
				setActive(v12, settings.Style == k) -- inferred equivalent call
			end

			for k, v12 in pairs(buttonsByEffectName) do
				setActive(v12, settings.Effects[k] == true) -- inferred equivalent call
				v12.button.TextTransparency = settings.Mode == "Off" and 0.6 or 0
			end

			local v12 = math.clamp(settings.Intensity or BandCameraStyle.DefaultIntensity, 0, 1)
			parent7.Size = UDim2.new(v12, 0, 1, 0)
			parent8.Position = UDim2.new(v12, 0, 0.5, 0)
			textLabel2.Text = ("%d%%"):format((math.floor(v12 * 100 + 0.5)))
			local v13 = settings.Mode == "Off"
			textLabel2.TextTransparency = v13 and 0.5 or 0
			textLabel.TextTransparency = v13 and 0.5 or 0
			parent7.BackgroundTransparency = v13 and 0.6 or 0
		end
		BandCameraStyle.OnChanged(refresh)
		refresh()

		local function updateNow() -- 1 equivalent call inferred from this helper
			local settings = BandCameraStyle.GetSettings()
			local currentStyleName = BandCameraStyle.GetCurrentStyleName()

			if settings.Mode == "Off" then
				label2.Text = "Effects are off"
			elseif currentStyleName then
				label2.Text = "Now showing: " .. currentStyleName
			else
				label2.Text = "Effects apply while Dynamic Cam is running"
			end
		end

		local function setOpen(p)
			if v4 == p then
				return
			end

			v4 = p
			v11 = nil
			v8 = false
			folder.Visible = v4 and v6
			applyLook()

			if v4 then
				refresh()
				renderPresets()
				loadSlots() -- inferred equivalent call
				task.spawn(function()
					while v4 do
						updateNow() -- inferred equivalent call
						task.wait(0.4)
					end
				end)
			end
		end

		textButton.MouseButton1Click:Connect(function()
			setOpen(not v4)
		end)
		button.button.MouseButton1Click:Connect(function()
			setOpen(false)
		end)

		function v7.Place(visible, p, p2, p3, p4)
			v6 = visible
			textButton.Visible = visible

			if visible then
				textButton.Position = UDim2.new(p.X.Scale, p.X.Offset - p2 - p3, p.Y.Scale, p.Y.Offset)
				folder.Position = UDim2.new(
					textButton.Position.X.Scale,
					textButton.Position.X.Offset,
					textButton.Position.Y.Scale,
					textButton.Position.Y.Offset + p4 / 2 + 8
				)
			elseif v4 then
				setOpen(false)
			end

			folder.Visible = v4 and visible

			if v4 and visible then
				local currentCamera = workspace.CurrentCamera
				local v12 = folder.AbsoluteSize.Y / math.max(uiScale.Scale, 0.01)

				if currentCamera and v12 > 0 then
					local v13 = currentCamera.ViewportSize.Y - (textButton.Position.Y.Offset + p4 / 2 + 8) - 8
					uiScale.Scale = math.clamp(v13 / v12, 0.55, 1)
				end
			end
		end

		for _, guiObject in ipairs(folder:GetDescendants()) do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 11
			end
		end

		return v7
	end
}