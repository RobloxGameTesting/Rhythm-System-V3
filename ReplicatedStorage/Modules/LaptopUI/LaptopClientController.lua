local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)

local Retro = require(script.Parent.Retro)
local Theme = require(ReplicatedStorage.Modules.LaptopUI.Theme)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ReleaseLaptop = RemoteEvents:WaitForChild("ReleaseLaptop")
local LaptopStateUpdate = RemoteEvents:WaitForChild("LaptopStateUpdate")

local LocalPlayer = Players.LocalPlayer

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local v = {}

local v2 = nil
local walkSpeed = nil

local v3 = false
local mouseBehavior = nil

local flag = false
local v4 = nil

local cframe = nil

local v5 = {}

local requestExit

local forceExitOnRespawn

local v6 = {}
local v7 = {}
local LaptopClientController = {}

function LaptopClientController.SetBackspaceBlocked(p)
	v3 = p == true
end

function LaptopClientController.OnEnter(p)
	table.insert(v6, p)
end

function LaptopClientController.OnExit(p)
	table.insert(v7, p)
end

local function fireEnter(p)
	for _, callback in ipairs(v6) do
		local success, result = pcall(callback, p)

		if not success then
			warn("[LaptopClientController] Error pada OnEnter listener:", result)
		end
	end
end

local function fireExit(p)
	for _, callback in ipairs(v7) do
		local success, result = pcall(callback, p)

		if not success then
			warn("[LaptopClientController] Error pada OnExit listener:", result)
		end
	end
end

function LaptopClientController.RegisterLaptop(p, part, p2)
	v[p] = {
		Part = part,
		Face = p2 or Enum.NormalId.Front
	}
end

local function resolveGui(p) -- 3 equivalent calls inferred from this helper
	local guiAnchor = p.Part:FindFirstChild("GuiAnchor")
	return guiAnchor and guiAnchor:FindFirstChild("LaptopScreen")
end

local function getOrCreateCloseButton(p, gui)
	local v8 = v5[p]

	if v8 then
		return v8
	end

	local laptopCloseButton_Local = Instance.new("TextButton")
	laptopCloseButton_Local.Name = "LaptopCloseButton_Local"

	laptopCloseButton_Local.AnchorPoint = Vector2.new(1, 0)

	laptopCloseButton_Local.Position = UDim2.new(1, -10, 0, 10)
	laptopCloseButton_Local.Size = UDim2.fromOffset(Theme.Sizes.IconButtonSize, Theme.Sizes.IconButtonSize)
	laptopCloseButton_Local.BackgroundColor3 = Color3.fromRGB(96, 99, 108)

	laptopCloseButton_Local.BackgroundTransparency = 0
	laptopCloseButton_Local.BorderSizePixel = 0
	laptopCloseButton_Local.Text = ""
	laptopCloseButton_Local.AutoButtonColor = false

	laptopCloseButton_Local.ZIndex = Theme.ZIndex.Modal
	laptopCloseButton_Local.Visible = false
	laptopCloseButton_Local.Parent = gui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Medium
	uiCorner.Parent = laptopCloseButton_Local

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.fromRGB(150, 153, 162)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = laptopCloseButton_Local
	Retro.AddGloss(laptopCloseButton_Local)

	local v9 = Theme.Sizes.IconButtonSize * 0.45

	local bar1 = Instance.new("Frame")
	bar1.Name = "Bar1"
	bar1.AnchorPoint = Vector2.new(0.5, 0.5)
	bar1.Position = UDim2.new(0.5, 0, 0.5, 0)
	bar1.Size = UDim2.new(0, v9, 0, 2)
	bar1.Rotation = 45
	bar1.BackgroundColor3 = Color3.new(1, 1, 1)
	bar1.BorderSizePixel = 0
	bar1.ZIndex = Theme.ZIndex.Modal
	bar1.Parent = laptopCloseButton_Local

	local bar2 = bar1:Clone()
	bar2.Name = "Bar2"
	bar2.Rotation = -45
	bar2.Parent = laptopCloseButton_Local

	laptopCloseButton_Local.Activated:Connect(function()
		requestExit()
	end)

	v5[p] = laptopCloseButton_Local
	return laptopCloseButton_Local
end

local function getPlayerControls()
	if v4 then
		return v4
	end

	local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
	local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")

	if not playerModule then
		return nil
	end

	local success, result = pcall(function()
		local module = require(playerModule)
		return module:GetControls()
	end)

	if success and result then
		v4 = result
		return result
	end

	return nil
end

local function lockMovementControls()
	if flag then
		return
	end

	local playerControls = getPlayerControls()

	if not playerControls then
		warn("[LaptopClientController] ControlModule tidak ditemukan -- input jalan TIDAK dimatikan (WalkSpeed=0 tetap jadi pengaman)")
		return
	end

	local success, result = pcall(function()
		playerControls:Disable()
	end)

	if success then
		flag = true
	else
		warn("[LaptopClientController] Gagal mematikan kontrol jalan:", result)
	end
end

local function unlockMovementControls()
	if not flag then
		return
	end

	flag = false
	local playerControls = getPlayerControls()

	if not playerControls then
		return
	end

	local success, result = pcall(function()
		playerControls:Enable()
	end)

	if not success then
		warn("[LaptopClientController] Gagal menyalakan kembali kontrol jalan:", result)
	end
end

local diedConnection = nil

local function disconnectDeathWatch() -- 4 equivalent calls inferred from this helper
	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end
end

local function enterLaptopMode(studioId)
	local v8 = v[studioId]

	if not v8 then
		warn("[LaptopClientController] Tidak ada Screen part terdaftar untuk", studioId)
		return
	end

	v2 = studioId

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		walkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 0
		disconnectDeathWatch() -- inferred equivalent call
		diedConnection = humanoid.Died:Connect(function()
			disconnectDeathWatch() -- inferred equivalent call
			forceExitOnRespawn()
		end)
	end

	lockMovementControls()

	SessionCameraSettings.SetMenuOpen(true)

	local currentCamera = Workspace.CurrentCamera

	cframe = currentCamera.CFrame

	mouseBehavior = UserInputService.MouseBehavior
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

	currentCamera.CameraType = Enum.CameraType.Scriptable

	local vectorToWorldSpace = v8.Part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(v8.Face))

	TweenService:Create(currentCamera, tweenInfo, {
		CFrame = CFrame.lookAt(v8.Part.Position + vectorToWorldSpace * 1.2, v8.Part.Position, Vector3.new(0, 1, 0))
	}):Play()
	local gui = resolveGui(v8) -- inferred equivalent call

	if gui then
		local closeButton = getOrCreateCloseButton(studioId, gui)
		closeButton.Visible = true
	end

	fireEnter(studioId)
end

local function exitLaptopMode()
	v3 = false

	if not v2 then
		return
	end

	local v8 = v2
	v2 = nil
	disconnectDeathWatch() -- inferred equivalent call
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and walkSpeed then
		humanoid.WalkSpeed = walkSpeed
	end

	walkSpeed = nil

	unlockMovementControls()

	SessionCameraSettings.SetMenuOpen(false)

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	mouseBehavior = nil

	local currentCamera = Workspace.CurrentCamera

	if cframe then
		currentCamera.CFrame = cframe

		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local v9 = math.clamp((cframe.Position - humanoidRootPart.Position).Magnitude, 0.5, 20)
			LocalPlayer.CameraMinZoomDistance = v9
			LocalPlayer.CameraMaxZoomDistance = v9
			task.delay(0.35, function()
				LocalPlayer.CameraMinZoomDistance = 0.5
				LocalPlayer.CameraMaxZoomDistance = 20
			end)
		end
	end

	cframe = nil
	currentCamera.CameraType = Enum.CameraType.Custom

	local v9 = v[v8]

	if v9 then
		v9 = resolveGui(v9) -- inferred equivalent call
	end

	local v10 = v9 and v5[v8]

	if v10 then
		v10.Visible = false
	end

	fireExit(v8)
end

forceExitOnRespawn = function()
	if not v2 then
		return
	end

	local v8 = v2
	v2 = nil
	disconnectDeathWatch() -- inferred equivalent call
	walkSpeed = nil
	cframe = nil

	unlockMovementControls()
	SessionCameraSettings.SetMenuOpen(false)

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	mouseBehavior = nil

	Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	local v9 = v[v8]

	if v9 then
		v9 = resolveGui(v9) -- inferred equivalent call
	end

	local v10 = v9 and v5[v8]

	if v10 then
		v10.Visible = false
	end

	fireExit(v8)

	ReleaseLaptop:FireServer(v8)
end

requestExit = function()
	if not v2 then
		return
	end

	local v8 = v2
	exitLaptopMode()
	ReleaseLaptop:FireServer(v8)
end

function LaptopClientController.Start()
	RunService:BindToRenderStep("LaptopMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
		if not v2 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			return
		end

		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end

		if not UserInputService.MouseIconEnabled then
			UserInputService.MouseIconEnabled = true
		end
	end)

	LaptopStateUpdate.OnClientEvent:Connect(function(p)
		if p.OperatorUserId == LocalPlayer.UserId then
			enterLaptopMode(p.StudioId)
		elseif v2 == p.StudioId then
			exitLaptopMode()
		end
	end)

	LocalPlayer.CharacterRemoving:Connect(forceExitOnRespawn)
	LocalPlayer.CharacterAdded:Connect(forceExitOnRespawn)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not v2 then
			return
		end

		if input.KeyCode == Enum.KeyCode.Backspace and not v3 then
			requestExit()
		end
	end)
end

return LaptopClientController