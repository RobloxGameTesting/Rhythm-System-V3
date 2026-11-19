local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local NoteBoardUI = require(Modules:WaitForChild("NoteBoardUI"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))
local BoardSwitch = require(Modules:WaitForChild("BoardSwitch"))
local BoardZoom = require(Modules:WaitForChild("BoardZoom"))

local v = 8

local v2 = 5
local v3 = 2.5

local v4 = 0.025

local v5 = 0.14

local inFocusRadius = 0.06
local v6 = 1
local v7 = 1

local function numberAttribute(attributeName, p) -- 8 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return if type(attribute) == "number" then attribute else p
end

local function refreshTunables()
	v5 = numberAttribute("LiftPaper", v5) -- inferred equivalent call
	inFocusRadius = numberAttribute("DofInFocusRadius", inFocusRadius) -- inferred equivalent call
	v6 = numberAttribute("DofFarIntensity", v6) -- inferred equivalent call
	v7 = numberAttribute("DofLayers", v7) -- inferred equivalent call
	v2 = numberAttribute("ParallaxYawDeg", v2) -- inferred equivalent call
	v3 = numberAttribute("ParallaxPitchDeg", v3) -- inferred equivalent call
	v4 = numberAttribute("ParallaxShift", v4) -- inferred equivalent call
	v = numberAttribute("TopClearancePx", v) -- inferred equivalent call
end

local noteBoard = workspace:WaitForChild("Map"):WaitForChild("NoteBoard")
local paper = noteBoard:WaitForChild("Paper")

local cframe = paper.CFrame
local pivot = noteBoard:GetPivot()
local v8 = NoteBoardUI.CanvasSize.X / paper.Size.X

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local noteBoardSurface = Instance.new("SurfaceGui")
noteBoardSurface.Name = "NoteBoardSurface"
noteBoardSurface.Adornee = paper
noteBoardSurface.Face = Enum.NormalId.Front
noteBoardSurface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
noteBoardSurface.CanvasSize = NoteBoardUI.CanvasSize
noteBoardSurface.LightInfluence = 0.2
noteBoardSurface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
noteBoardSurface.ResetOnSpawn = false
noteBoardSurface.AlwaysOnTop = false
noteBoardSurface.MaxDistance = 90
noteBoardSurface.Active = false
noteBoardSurface.Parent = PlayerGui

local NoteBoardRemotes = ReplicatedStorage:WaitForChild("NoteBoardRemotes")
local BoardNotesSync = NoteBoardRemotes:WaitForChild("BoardNotesSync")
local BoardNotesChanged = NoteBoardRemotes:WaitForChild("BoardNotesChanged")
local BoardNotesFocus = NoteBoardRemotes:WaitForChild("BoardNotesFocus")
local PostBoardNote = NoteBoardRemotes:WaitForChild("PostBoardNote")
local DeleteBoardNote = NoteBoardRemotes:WaitForChild("DeleteBoardNote")
local GetBoardReplies = NoteBoardRemotes:WaitForChild("GetBoardReplies")
local PostBoardReply = NoteBoardRemotes:WaitForChild("PostBoardReply")
local DeleteBoardReply = NoteBoardRemotes:WaitForChild("DeleteBoardReply")

local v9 = nil

local v10 = {}

local function applyEvent(p, p2, p3, p4)
	if p == "Sync" then
		v9:SetNotes(p2, p3)
	elseif p == "Added" then
		v9:AddNote(p2, true)
	elseif p == "Removed" then
		v9:RemoveNote(p2)
	elseif p == "ReplyAdded" then
		v9:ReplyAdded(p2, p3, p4)
	elseif p == "ReplyRemoved" then
		v9:ReplyRemoved(p2, p3, p4)
	end
end

BoardNotesChanged.OnClientEvent:Connect(function(value, p, p2, p3)
	if typeof(value) ~= "string" then
		return
	end

	if v9 then
		applyEvent(value, p, p2, p3)
	else
		table.insert(v10, { value, p, p2, p3 })
	end
end)

local function postReply(id, p)
	local success, result, v11 = pcall(function()
		return PostBoardReply:InvokeServer(id, p)
	end)

	if success then
		return result == true, v11
	end

	return false, "couldn't reach the board, try again"
end

local composer = NoteBoardUI.newComposer(PlayerGui, {
	onOpenChanged = function(p)
		if v9 then
			v9:SetInputBlocked(p)
		end
	end,
	onSubmit = function(p, p2)
		local success, result, v11 = pcall(function()
			return PostBoardNote:InvokeServer(p, p2)
		end)

		if not success then
			return false, "couldn't reach the board, try again"
		end

		if result and v9 then
			v9:ScrollToTop()
		end

		return result == true, v11
	end
})

local v11 = NoteBoardUI.new(noteBoardSurface, {
	localUserId = LocalPlayer.UserId,
	onWriteClicked = function()
		composer:Open()
	end,
	onDeleteClicked = function(p)
		task.spawn(function()
			pcall(function()
				DeleteBoardNote:InvokeServer(p)
			end)
		end)
	end,
	onRequestReplies = function(p)
		local success, result = pcall(function()
			return GetBoardReplies:InvokeServer(p)
		end)

		if success and typeof(result) == "table" then
			return result
		end

		return nil
	end,
	onReplyClicked = function(p)
		composer:Open({
			mode = "reply",
			subtitle = "to " .. tostring(p.Name),
			onSubmit = function(p2)
				return postReply(p.Id, p2)
			end
		})
	end,
	onDeleteReply = function(p, p2)
		task.spawn(function()
			pcall(function()
				DeleteBoardReply:InvokeServer(p, p2)
			end)
		end)
	end
})

v9 = v11

for _, v12 in ipairs(v10) do
	applyEvent(v12[1], v12[2], v12[3], v12[4])
end

v10 = {}

BoardNotesSync:FireServer()

task.spawn(function()
	while not v11._destroyed do
		task.wait(30)
		v11:RefreshTimes()
	end
end)

local v12 = {}
local connections = {}

local function hideInstance(instance)
	if instance:IsA("BasePart") then
		if not v12[instance] then
			v12[instance] = { canQuery = instance.CanQuery }
		end

		instance.LocalTransparencyModifier = 1

		instance.CanQuery = false
	elseif instance:IsA("Decal") then
		if not v12[instance] then
			v12[instance] = { transparency = instance.Transparency }
		end

		instance.Transparency = 1
	elseif
		instance:IsA("ParticleEmitter")
		or instance:IsA("Trail")
		or instance:IsA("Beam")
		or instance:IsA("Fire")
		or instance:IsA("Smoke")
		or instance:IsA("Sparkles")
		or instance:IsA("Highlight")
		or instance:IsA("BillboardGui")
		or instance:IsA("SurfaceGui")
	then
		if not v12[instance] then
			v12[instance] = { enabled = instance.Enabled }
		end

		instance.Enabled = false
	elseif instance:IsA("Humanoid") then
		if not v12[instance] then
			v12[instance] = { displayDistance = instance.DisplayDistanceType }
		end

		instance.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

local function hideCharacter(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		hideInstance(descendant)
	end

	table.insert(connections, folder.DescendantAdded:Connect(hideInstance))
end

local function watchPlayer(player)
	if player.Character then
		hideCharacter(player.Character)
	end

	table.insert(connections, player.CharacterAdded:Connect(function(character)
		task.defer(hideCharacter, character)
	end))
end

local function hideAllPlayers()
	for _, v13 in ipairs(Players:GetPlayers()) do
		if v13.Character then
			hideCharacter(v13.Character)
		end

		table.insert(connections, v13.CharacterAdded:Connect(function(character)
			task.defer(hideCharacter, character)
		end))
	end

	table.insert(connections, Players.PlayerAdded:Connect(watchPlayer))
end

local function stopWatchingPlayers()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}
end

local function restoreAllHidden()
	for k, v13 in pairs(v12) do
		if not k.Parent then
			continue
		end

		if v13.canQuery == nil then
			if v13.transparency == nil then
				if v13.enabled == nil then
					if v13.displayDistance ~= nil then
						k.DisplayDistanceType = v13.displayDistance
					end
				else
					k.Enabled = v13.enabled
				end
			else
				k.Transparency = v13.transparency
			end
		else
			k.LocalTransparencyModifier = 0
			k.CanQuery = v13.canQuery
		end
	end

	v12 = {}
end

local flag = false
local count = 0
local v13 = nil
local cameraType = nil
local v14 = nil
local fieldOfView = nil
local v15 = true
local menuFlag = false
local controls = nil
local diedConnection = nil
local renderSteppedConnection = nil
local viewportSizeChangedConnection = nil
local v16 = nil
local v17 = nil
local v18 = false

local v19 = nil
local v20 = 2
local cframe2 = nil
local v21 = 7.5
local flag2 = false
local v22 = false
local total = 0
local total2 = 0
local total3 = 0
local total4 = 0

local total5 = 0
local v23 = 0
local v24 = {}
local depthOfFieldEffect = nil
local enabled = nil
local total6 = 0
local v25 = 0
local focusDistance = 2

local function focusPaperCFrame() -- 2 equivalent calls inferred from this helper
	return cframe + cframe.LookVector * v5
end

local function computeFocusLayout(currentCamera)
	local canvasSize = NoteBoardUI.CanvasSize
	local layout = NoteBoardUI.Layout
	local viewportSize = currentCamera.ViewportSize
	local v26 = focusPaperCFrame() -- inferred equivalent call
	local v27 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and 0.78 or 0.6

	local v28 = viewportSize.Y * 0.88 / canvasSize.Y
	local v29 = viewportSize.X * 0.92 / canvasSize.X

	local v30 = math.min(math.max(v28, v27), v29)

	local v31 = viewportSize.Y / (v30 * v8)
	local distance = v31 / 2 / 0.7002075382097097

	local v32 = viewportSize.Y / v30
	local cropped = v28 + 0.001 < v30 or v32 < canvasSize.Y
	local v38 = { cropped = cropped, distance = distance }
	local v39

	if cropped then
		local v40 = v / (v30 * v8)
		v39 = paper.Size.Y / 2 + v40 - v31 / 2

		local visibleBottom = v32 - v / v30 - 12
		v38.visibleBottom = visibleBottom

		v38.scrollPadding = math.clamp(
			layout.ListY + layout.ListH - visibleBottom + 8,
			layout.DefaultScrollPadding,
			layout.ListH - layout.RowH
		)
	else
		v39 = 0
	end

	local v40 = v26.Position + v26.UpVector * v39
	local v41 = v40 + v26.LookVector * distance
	return CFrame.lookAt(v41, v40, Vector3.new(0, 1, 0)), v38
end

local function positionCloseButton(p)
	local v26 = v17

	if not v26 then
		return
	end

	local v27 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	v26.Text = v27 and "BACK" or "BACK  [Q]"

	if p then
		v26.AnchorPoint = Vector2.new(1, 1)
		v26.Position = UDim2.new(1, -16, 1, -16)
		v26.Size = UDim2.fromOffset(v27 and 124 or 170, 40)
	else
		v26.AnchorPoint = Vector2.new(0.5, 1)
		v26.Position = UDim2.new(0.5, 0, 1, -18)
		v26.Size = UDim2.fromOffset(210, 46)
	end
end

local function applyUiLayout(data) -- 2 equivalent calls inferred from this helper
	v18 = data.cropped

	if v9 then
		if data.cropped then
			v9:SetViewport(data.visibleBottom, data.scrollPadding)
		else
			v9:SetViewport(nil, nil)
		end
	end

	positionCloseButton(data.cropped)
end

local function updateLayers() -- 1 equivalent call inferred from this helper
	noteBoard:PivotTo(pivot + cframe.LookVector * total5)
end

local function ensureDofLayers(parent)
	local v26 = math.clamp(math.floor(v7 + 0.5), 1, 3)

	while #v24 < v26 do
		local noteBoardFocusDoF = Instance.new("DepthOfFieldEffect")
		noteBoardFocusDoF.Name = "NoteBoardFocusDoF"
		noteBoardFocusDoF.InFocusRadius = inFocusRadius
		noteBoardFocusDoF.NearIntensity = 0
		noteBoardFocusDoF.FarIntensity = 0
		noteBoardFocusDoF.FocusDistance = focusDistance
		noteBoardFocusDoF.Parent = parent
		table.insert(v24, noteBoardFocusDoF)
	end

	while v26 < #v24 do
		table.remove(v24):Destroy()
	end
end

local function startDof(currentCamera)
	depthOfFieldEffect = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")

	if depthOfFieldEffect then
		enabled = depthOfFieldEffect.Enabled
		depthOfFieldEffect.Enabled = false
	end

	total6 = 0
	v25 = 1
	local cframe3 = currentCamera.CFrame
	focusDistance = math.max((focusPaperCFrame().Position - cframe3.Position):Dot(cframe3.LookVector), 0.5) -- inferred equivalent call
	ensureDofLayers(currentCamera)
end

local function stopDof()
	for _, v26 in ipairs(v24) do
		v26:Destroy()
	end

	v24 = {}

	if depthOfFieldEffect and enabled ~= nil then
		depthOfFieldEffect.Enabled = enabled
	end

	depthOfFieldEffect = nil
	enabled = nil
	total6 = 0
	v25 = 0
end

local function updateDof(p, currentCamera)
	if #v24 == 0 then
		return
	end

	ensureDofLayers(currentCamera)
	total6 += (v25 - total6) * (1 - math.exp(-p * 4))

	local v26 = cframe.Position + cframe.LookVector * total5
	local cframe3 = currentCamera.CFrame
	local v27 = math.max((v26 - cframe3.Position):Dot(cframe3.LookVector), 0.2)
	focusDistance += (v27 - focusDistance) * (1 - math.exp(-p * 8))

	for _, v28 in ipairs(v24) do
		v28.FocusDistance = focusDistance
		v28.InFocusRadius = inFocusRadius
		v28.NearIntensity = 0
		v28.FarIntensity = v6 * total6
	end
end

local function finalizeLayers() -- 2 equivalent calls inferred from this helper
	total5 = 0
	v23 = 0
	noteBoard:PivotTo(pivot)
	stopDof()
end

local function parallaxCurve(p) -- 2 equivalent calls inferred from this helper
	return math.sign(p) * math.abs(p) ^ 1.25
end

local function cameraStep(p)
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and v19 and cframe2) then
		return
	end

	local v26 = math.min(p, 0.1)

	refreshTunables()

	if flag then
		v23 = v5
	end

	cframe2 = cframe2:Lerp(v19, 1 - math.exp(-v26 * v21))

	total5 += (v23 - total5) * (1 - math.exp(-v26 * 6))
	updateLayers() -- inferred equivalent call
	total += ((v22 and 1 or 0) - total) * (1 - math.exp(-v26 * 3))
	local v27, v28

	if UserInputService.MouseEnabled then
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportSize = currentCamera.ViewportSize
		local v29 = math.clamp((mouseLocation.X - viewportSize.X / 2) / (viewportSize.X / 2), -1, 1)
		local v30 = math.clamp(-(mouseLocation.Y - viewportSize.Y / 2) / (viewportSize.Y / 2), -1, 1)
		v27 = parallaxCurve(v29) -- inferred equivalent call
		v28 = parallaxCurve(v30) -- inferred equivalent call
	else
		v27 = 0
		v28 = 0
	end

	local v29 = v9 and v9:IsInteractiveHovered()
		or composer and composer:IsOpen()
		or v9 and v9:IsNoteOpen()
		or v9 and v9:IsConfirmOpen()
		or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

	total4 += ((v29 and 1 or 0) - total4) * (1 - math.exp(-v26 * 12))
	local v30 = (1 - math.exp(-v26 * 5)) * (1 - total4)
	total2 += (v27 - total2) * v30
	total3 += (v28 - total3) * v30

	local now = os.clock()
	local v31 = math.sin(now * 0.7) * 0.1 + math.sin(now * 1.9) * 0.1 * 0.35
	local v32 = math.cos(now * 0.55) * 0.07
	local v36 = total
	local v37 = 1 - total4 * 0.9
	local v38 = (total2 + v31 * v37) * v36
	local v39 = (total3 + v32 * v37) * v36

	local v40 = -math.rad(v2) * v38
	local v41 = math.rad(v3) * v39
	local v42 = -v38 * 0.02
	local v43 = cframe2.RightVector * (v38 * v20 * v4) + cframe2.UpVector * (v39 * v20 * v4)
	currentCamera.CFrame = cframe2 * CFrame.Angles(v41, v40, v42) + v43

	updateDof(v26, currentCamera)
end

local function stopCameraStep() -- 2 equivalent calls inferred from this helper
	if flag2 then
		flag2 = false
		RunService:UnbindFromRenderStep("NoteBoardCamera")
	end
end

local function waitForCameraSettle(p)
	local lastTime = os.clock()

	while os.clock() - lastTime < p do
		RunService.RenderStepped:Wait()

		if
			cframe2
			and v19
			and (cframe2.Position - v19.Position).Magnitude < 0.02
			and total < 0.03
			and total5 < 0.01
		then
			break
		end
	end
end

local function setControlsEnabled(p) -- 2 equivalent calls inferred from this helper
	return (pcall(function()
		if not controls then
			local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
			controls = PlayerModule:GetControls()
		end

		if p then
			controls:Enable()
		else
			controls:Disable()
		end
	end))
end

local function lockZoomTemporarily(p)
	LocalPlayer.CameraMinZoomDistance = p
	LocalPlayer.CameraMaxZoomDistance = p
	task.delay(0.35, function()
		LocalPlayer.CameraMinZoomDistance = 0.5
		LocalPlayer.CameraMaxZoomDistance = 20
	end)
end

local function releaseMenuFlag() -- 1 equivalent call inferred from this helper
	if menuFlag then
		menuFlag = false
		SessionCameraSettings.SetMenuOpen(false)
	end
end

local fn

local function createFocusGui()
	if v16 then
		return v16
	end

	local noteBoardFocusUI = Instance.new("ScreenGui")
	noteBoardFocusUI.Name = "NoteBoardFocusUI"
	noteBoardFocusUI.ResetOnSpawn = false
	noteBoardFocusUI.DisplayOrder = 60
	noteBoardFocusUI.IgnoreGuiInset = false
	noteBoardFocusUI.Enabled = false
	noteBoardFocusUI.Parent = PlayerGui

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.AnchorPoint = Vector2.new(0.5, 1)
	closeButton.Position = UDim2.new(0.5, 0, 1, -18)
	closeButton.Size = UDim2.fromOffset(210, 46)
	closeButton.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
	closeButton.AutoButtonColor = true
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "BACK  [Q]"
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.fromRGB(244, 232, 200)
	closeButton.Rotation = -1.5
	closeButton.Parent = noteBoardFocusUI
	v17 = closeButton

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	require(ReplicatedStorage2.Modules:WaitForChild("BoardBackButton")).Style(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		BoardSwitch.Back()
	end)

	v16 = noteBoardFocusUI
	return noteBoardFocusUI
end

local function enterFocus(data)
	if flag then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not currentCamera or not humanoid or humanoid.Health <= 0 then
		return
	end

	flag = true
	count += 1
	local v26 = count
	v13 = character

	refreshTunables()

	if data then
		cameraType = data.CameraType
		v14 = data.CameraCFrame
		fieldOfView = data.FieldOfView
	else
		cameraType = currentCamera.CameraType
		v14 = currentCamera.CFrame
		fieldOfView = currentCamera.FieldOfView
	end

	if data then
		menuFlag = data.MenuFlag == true
	elseif not menuFlag then
		menuFlag = true
		SessionCameraSettings.SetMenuOpen(true)
	end

	if not data then
		RunService.RenderStepped:Wait()

		if not flag or count ~= v26 then
			return
		end
	end

	setControlsEnabled(false) -- inferred equivalent call

	if data then
		v15 = data.PromptServiceEnabled
	else
		v15 = ProximityPromptService.Enabled
	end

	ProximityPromptService.Enabled = false

	hideAllPlayers()
	task.spawn(function()
		while flag and count == v26 do
			for _, v27 in ipairs(Players:GetPlayers()) do
				local character2 = v27.Character

				if not character2 then
					continue
				end

				for _, part in ipairs(character2:GetDescendants()) do
					if part:IsA("BasePart") and (part.LocalTransparencyModifier ~= 1 or part.CanQuery) then
						hideInstance(part)
					end
				end
			end

			task.wait(0.25)
		end
	end)

	noteBoardSurface.Active = true

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 70

	total5 = 0
	v23 = v5
	startDof(currentCamera)

	local v27, v28 = computeFocusLayout(currentCamera)
	applyUiLayout(v28) -- inferred equivalent call
	local distance = v28.distance
	v19 = v27
	v20 = distance
	cframe2 = currentCamera.CFrame
	v21 = 7.5
	v22 = false
	total = 0
	total2 = 0
	total3 = 0
	total4 = 0

	RunService:BindToRenderStep("NoteBoardCamera", Enum.RenderPriority.Camera.Value + 1, cameraStep)
	flag2 = true
	task.delay(0.45, function()
		if flag and count == v26 then
			v22 = true
		end
	end)

	viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if not flag then
			return
		end

		local v29, v30 = computeFocusLayout(currentCamera)
		local distance2 = v30.distance
		v19 = v29
		v20 = distance2
		applyUiLayout(v30) -- inferred equivalent call
	end)

	local focusGui = createFocusGui()
	focusGui.Enabled = true
	positionCloseButton(v18)

	if data then
		task.delay(0.45, function()
			if flag and count == v26 then
				BoardNotesFocus:FireServer(true)
			end
		end)
	else
		BoardNotesFocus:FireServer(true)
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true

		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			task.spawn(fn)
			return
		end

		local fov = BoardZoom.Fov(70)

		if math.abs(currentCamera.FieldOfView - fov) > 0.01 then
			currentCamera.FieldOfView = fov
		end
	end)

	ContextActionService:BindActionAtPriority("NoteBoardExit", function(_, p)
		if UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		if p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Sink
		end

		if composer and composer:IsOpen() then
			composer:Close()
		elseif v9 and v9:IsConfirmOpen() then
			v9:CloseConfirm()
		elseif v9 and v9:IsNoteOpen() then
			v9:CloseNote()
		else
			BoardSwitch.Back()
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Q, Enum.KeyCode.Backspace, Enum.KeyCode.ButtonB)

	diedConnection = humanoid.Died:Connect(function()
		fn()
	end)

	BoardSwitch.SetCurrent("Notes")
end

fn = function(p)
	if not flag then
		return
	end

	flag = false
	count += 1

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
		viewportSizeChangedConnection = nil
	end

	ContextActionService:UnbindAction("NoteBoardExit")

	BoardNotesFocus:FireServer(false)

	if composer then
		composer:Close(true)
	end

	if v9 then
		v9:CloseConfirm(true)
		v9:CloseNote(true)
		v9:SetViewport(nil, nil)
		v9:ResetHover()
	end

	noteBoardSurface.Active = false

	if v16 then
		v16.Enabled = false
	end

	if p then
		stopCameraStep() -- inferred equivalent call
		finalizeLayers() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		local v26 = {
			CameraType = cameraType,
			CameraCFrame = v14,
			FieldOfView = fieldOfView,
			PromptServiceEnabled = v15,
			MenuFlag = menuFlag
		}

		menuFlag = false
		v14 = nil
		v13 = nil
		BoardSwitch.ClearCurrent("Notes")
		return v26
	else
		local currentCamera = workspace.CurrentCamera
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v26

		if currentCamera == nil or v14 == nil or character ~= v13 or humanoid == nil or not (humanoid.Health > 0) then
			v26 = false
		else
			v26 = humanoidRootPart ~= nil
		end

		v23 = 0
		v25 = 0
		v22 = false

		stopWatchingPlayers()
		restoreAllHidden()

		if v26 then
			v19 = v14
			v21 = 9
			waitForCameraSettle(0.9)
		end

		stopCameraStep() -- inferred equivalent call
		finalizeLayers() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		ProximityPromptService.Enabled = v15
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		if currentCamera then
			local cameraType2 = cameraType or Enum.CameraType.Custom

			if cameraType2 == Enum.CameraType.Scriptable then
				cameraType2 = Enum.CameraType.Custom
			end

			if v26 then
				currentCamera.CFrame = v14
				local v27 = math.clamp((v14.Position - humanoidRootPart.Position).Magnitude, 0.5, 20)
				LocalPlayer.CameraMinZoomDistance = v27
				LocalPlayer.CameraMaxZoomDistance = v27
				task.delay(0.35, function()
					LocalPlayer.CameraMinZoomDistance = 0.5
					LocalPlayer.CameraMaxZoomDistance = 20
				end)
			end

			currentCamera.CameraType = cameraType2

			if fieldOfView then
				currentCamera.FieldOfView = fieldOfView
			end
		end

		setControlsEnabled(true) -- inferred equivalent call
		releaseMenuFlag() -- inferred equivalent call
		v14 = nil
		v13 = nil
		BoardSwitch.ClearCurrent("Notes")
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	if flag then
		task.spawn(fn)
	end
end)

BoardSwitch.Register("Notes", {
	Part = paper,
	ExitForHandoff = function()
		return fn(true)
	end,
	EnterWithHandoff = function(p)
		enterFocus(p)
	end,
	Exit = function()
		fn()
	end
})

task.spawn(function()
	local switchClick = paper:WaitForChild("SwitchClick", 15)

	if switchClick then
		switchClick.MouseClick:Connect(function(p)
			if p == LocalPlayer then
				BoardSwitch.Request("Notes")
			end
		end)
	end
end)