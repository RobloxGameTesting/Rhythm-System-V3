local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BandCameraController = require(Modules:WaitForChild("BandCamera"):WaitForChild("BandCameraController"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))
local BandCameraConfig = require(Modules:WaitForChild("BandCamera"):WaitForChild("BandCameraConfig"))
local BandCameraFxPanel = require(Modules:WaitForChild("BandCamera"):WaitForChild("BandCameraFxPanel"))

local BandCameraUI = {}

local color = Color3.fromRGB(245, 245, 247)
local color2 = Color3.fromRGB(160, 160, 170)
local color3 = Color3.fromRGB(88, 210, 150)
local color4 = Color3.fromRGB(60, 60, 70)
local color5 = Color3.fromRGB(23, 23, 27)

local v = { bg = 0.72, text = 0.45, stroke = 1 }
local v2 = { bg = 0.2, text = 0, stroke = 0.45 }

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function create(className, items, parent) -- 12 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

function BandCameraUI.Init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local parent = create("ScreenGui", { -- inferred equivalent call
		Name = "BandCameraUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 98,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, playerGui)

	local parent2 = create("TextButton", { -- inferred equivalent call
		Name = "CameraButton",
		Text = "",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = color,
		AutoButtonColor = false,
		BackgroundColor3 = color5,
		BackgroundTransparency = v.bg,
		TextTransparency = v.text,
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0, 176, 0, 30),
		Visible = false,
		ZIndex = 20
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 8) }, parent2) -- inferred equivalent call
	parent2.TextXAlignment = Enum.TextXAlignment.Left
	local uiPadding = create("UIPadding", { PaddingLeft = UDim.new(0, 26) }, parent2) -- inferred equivalent call

	local parent3 = create("Frame", { -- inferred equivalent call
		Name = "CamIcon",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -21, 0.5, 0),
		Size = UDim2.fromOffset(15, 9),
		ZIndex = 21
	}, parent2)

	local parent4 = create("Frame", { -- inferred equivalent call
		Name = "Body",
		BackgroundColor3 = color,
		BackgroundTransparency = v.text + 0.25,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(9, 9),
		ZIndex = 21
	}, parent3)

	create("UICorner", { CornerRadius = UDim.new(0, 2) }, parent4) -- inferred equivalent call
	local parent5 = create("Frame", { -- inferred equivalent call
		Name = "WedgeClip",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(5, 9),
		ZIndex = 21
	}, parent3)

	local frame = create("Frame", { -- inferred equivalent call
		Name = "Wedge",
		BackgroundColor3 = color,
		BackgroundTransparency = v.text + 0.25,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(6.363961030678928, 6.363961030678928),
		Rotation = 45,
		ZIndex = 21
	}, parent5)

	local v3 = {
		Color = color4,
		Transparency = v.stroke,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}
	local uiStroke = Instance.new("UIStroke")

	local v4 = { parent4, frame }

	for k, v5 in pairs(v3) do
		uiStroke[k] = v5
	end

	uiStroke.Parent = parent2

	local textLabel = create("TextLabel", { -- inferred equivalent call
		Name = "CameraHint",
		Text = ("needs %d+ players"):format(BandCameraConfig.MinRealPlayers),
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = color2,
		TextTransparency = 0.45,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 176, 0, 14),
		Visible = false,
		ZIndex = 20
	}, parent)

	local v5 = BandCameraFxPanel.Create(parent)

	local textLabel2 = create("TextLabel", { -- inferred equivalent call
		Name = "AutoCamToast",
		Text = "",
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = color,
		BackgroundColor3 = color5,
		BackgroundTransparency = 1,
		TextTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 24),
		Visible = false,
		ZIndex = 30
	}, parent)

	create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, textLabel2) -- inferred equivalent call

	local count = 0
	local function toastY() -- 1 equivalent call inferred from this helper
		return math.max(GuiService:GetGuiInset().Y, 36) + 6
	end

	local function showToast(text)
		count += 1
		local v6 = count
		local v7 = toastY() -- inferred equivalent call
		textLabel2.Text = text
		textLabel2.Position = UDim2.new(0.5, 0, 0, v7 - 8)
		textLabel2.TextTransparency = 1
		textLabel2.Visible = true
		TweenService:Create(textLabel2, tweenInfo2, {
			Position = UDim2.new(0.5, 0, 0, v7),
			TextTransparency = 0.05
		}):Play()
		task.delay(3.5, function()
			if v6 ~= count then
				return
			end

			local tween = TweenService:Create(textLabel2, tweenInfo3, {
				Position = UDim2.new(0.5, 0, 0, v7 - 8),
				TextTransparency = 1
			})

			tween.Completed:Connect(function()
				if v6 == count then
					textLabel2.Visible = false
				end
			end)
			tween:Play()
		end)
	end
	BandCameraController.OnAutoStarted(function(p)
		if p == "player" then
			return
		end

		showToast("Auto Dynamic Cam On")
	end)

	local keyModeToggleUI = nil
	local fppToggleButton = nil
	local difficultyButton = nil
	local keyModeButton = nil
	local serversButton = nil
	local connections = {}
	local function bindReferences()
		keyModeToggleUI = playerGui:FindFirstChild("KeyModeToggleUI")
		difficultyButton = keyModeToggleUI and keyModeToggleUI:FindFirstChild("DifficultyButton")
		keyModeButton = keyModeToggleUI and keyModeToggleUI:FindFirstChild("KeyModeButton")
		local fppToggleTopbarUI = playerGui:FindFirstChild("FPPToggleTopbarUI")
		fppToggleButton = fppToggleTopbarUI and fppToggleTopbarUI:FindFirstChild("FPPToggleButton")
		local serverBrowserUI = playerGui:FindFirstChild("ServerBrowserUI")
		serversButton = serverBrowserUI and serverBrowserUI:FindFirstChild("ServersButton")

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
		local function watch(instance, list)
			if instance then
				for _, propertyName in ipairs(list) do
					connections[#connections + 1] = instance:GetPropertyChangedSignal(propertyName):Connect(function()
						BandCameraUI.Refresh()
					end)
				end
			end
		end
		watch(keyModeToggleUI, { "Enabled" })
		watch(difficultyButton, { "Position", "Size" })
		watch(fppToggleButton, { "Position", "Size" })
		watch(keyModeButton, { "Position", "Size" })
		watch(serversButton, { "Position", "Size", "Visible" })
	end

	local function rowY() -- 1 equivalent call inferred from this helper
		return math.max(GuiService:GetGuiInset().Y, 36) / 2
	end

	local function computePosition()
		local v6

		if keyModeToggleUI == nil then
			v6 = false
		else
			v6 = keyModeToggleUI.Enabled and difficultyButton ~= nil
		end

		local v7 = { fppToggleButton }

		if keyModeToggleUI ~= nil and keyModeToggleUI.Enabled then
			v7[#v7 + 1] = keyModeButton
			v7[#v7 + 1] = difficultyButton
		end

		if serversButton and serversButton.Visible then
			v7[#v7 + 1] = serversButton
		end

		local v8 = nil
		local v9 = nil

		for _, v10 in ipairs(v7) do
			if not (v10 and v10.AnchorPoint == Vector2.new(1, 0.5)) then
				continue
			end

			local v11 = v10.Position.X.Offset - v10.Size.X.Offset

			if not (v8 == nil or v11 < v8) then
				continue
			end

			v9 = v10
			v8 = v11
		end

		if v9 then
			return UDim2.new(v9.Position.X.Scale, v8 - 8, v9.Position.Y.Scale, v9.Position.Y.Offset)
		end

		return UDim2.new(1, v6 and -416 or -324, 0, rowY()) -- inferred equivalent call
	end

	local v6 = false
	local count2 = 0
	local v7 = nil
	local function applyLook(data)
		if v7 == data then
			return
		end

		v7 = data
		TweenService:Create(parent2, tweenInfo, {
			BackgroundTransparency = data.bg,
			TextTransparency = data.text
		}):Play()

		for _, instance in ipairs(v4) do
			TweenService:Create(instance, tweenInfo, {
				BackgroundTransparency = math.min(1, data.text + 0.25)
			}):Play()
		end

		TweenService:Create(uiStroke, tweenInfo, { Transparency = data.stroke }):Play()
		TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = data == v2 and 0.1 or 0.45
		}):Play()
	end
	local function wake(value) -- 4 equivalent calls inferred from this helper
		count2 += 1
		local v8 = count2
		applyLook(v2)
		task.delay(value or 2.5, function()
			if v8 == count2 and not v6 then
				applyLook(v)
			end
		end)
	end
	parent2.MouseEnter:Connect(function()
		v6 = true
		count2 += 1
		applyLook(v2)
	end)
	parent2.MouseLeave:Connect(function()
		v6 = false
		wake(0.6) -- inferred equivalent call
	end)

	local v8 = nil
	local v9 = nil
	function BandCameraUI.Refresh()
		local uiState = BandCameraController.GetUIState()
		local isMenuOpen = SessionCameraSettings.GetIsMenuOpen()

		local visible = false
		local v10 = ""
		local v11 = color
		local v12 = false

		if uiState.inSession then
			visible = uiState.inZone == true

			if uiState.playerOn then
				if uiState.running then
					v11 = color3
				else
					v11 = color2
					v12 = not uiState.eligible
				end

				v10 = "Dynamic Cam: ON"
			else
				v11 = color
				v10 = "Dynamic Cam: OFF"
			end
		elseif uiState.watching then
			v11 = color3
			visible = not isMenuOpen
			v10 = "Exit Dynamic Cam"
		elseif uiState.canWatch then
			v11 = color
			visible = not isMenuOpen
			v10 = "Watch Dynamic Cam"
		end

		parent2.Position = computePosition()
		parent2.Visible = visible

		local autoIn = visible and uiState.autoIn or nil
		local text

		if autoIn and v10 ~= "" then
			text = ("%s (%ds)"):format(v10, autoIn)
		else
			text = v10
		end

		parent2.Text = text
		parent2.TextColor3 = v11

		for _, v13 in ipairs(v4) do
			v13.BackgroundColor3 = v11
		end

		if text ~= "" then
			local v13 = math.max(
				6,
				(math.floor((176 - (21 + TextService:GetTextSize(
					text,
					parent2.TextSize,
					parent2.Font,
					Vector2.new(1000, 30)
				).X)) / 2))
			)
			uiPadding.PaddingLeft = UDim.new(0, v13 + 15 + 6)
		end

		uiStroke.Color = v11 == color3 and color3 or color4

		local position = parent2.Position
		textLabel.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset,
			position.Y.Scale,
			position.Y.Offset + 15 + 2
		)
		textLabel.Visible = visible and v12
		v5.Place(visible, parent2.Position, 176, 8, 30)

		if visible and v10 ~= v8 then
			wake() -- inferred equivalent call
		end

		v8 = visible and v10 or nil

		if autoIn and autoIn ~= v9 and (v9 == nil or autoIn <= 3) then
			wake(1.2) -- inferred equivalent call
		end

		v9 = autoIn
	end

	parent2.MouseButton1Click:Connect(function()
		local uiState = BandCameraController.GetUIState()

		if uiState.inSession then
			if uiState.inZone then
				BandCameraController.SetPlayerEnabled(not uiState.playerOn)
			end
		elseif uiState.watching then
			BandCameraController.StopWatch()
		elseif uiState.canWatch then
			BandCameraController.StartWatch()
		end

		wake() -- inferred equivalent call
		BandCameraUI.Refresh()
	end)

	bindReferences()
	playerGui.ChildAdded:Connect(function(child)
		if child.Name == "KeyModeToggleUI" or child.Name == "FPPToggleTopbarUI" or child.Name == "ServerBrowserUI" then
			task.defer(function()
				bindReferences()
				BandCameraUI.Refresh()
			end)
		end
	end)
	BandCameraController.OnChanged(BandCameraUI.Refresh)

	local v10 = nil
	local total = 0
	RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.2 then
			return
		end

		total = 0
		local autoCountdown = BandCameraController.GetAutoCountdown()

		if autoCountdown ~= v10 then
			v10 = autoCountdown
			BandCameraUI.Refresh()
		end
	end)
	SessionCameraSettings.OnChanged(BandCameraUI.Refresh)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(BandCameraUI.Refresh)
	end

	BandCameraUI.Refresh()
end

return BandCameraUI