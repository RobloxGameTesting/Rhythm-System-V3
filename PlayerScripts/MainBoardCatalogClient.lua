local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local CatalogBoardUI = require(Modules:WaitForChild("CatalogBoardUI"))
local SongConfigAdapter = require(Modules:WaitForChild("SongConfigAdapter"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))
local BoardSwitch = require(Modules:WaitForChild("BoardSwitch"))
local BoardZoom = require(Modules:WaitForChild("BoardZoom"))
local GlobalEventBus = require(Modules:WaitForChild("SongListUI"):WaitForChild("GlobalEventBus"))
local FavoriteClient = require(Modules:WaitForChild("FavoriteSystem"):WaitForChild("FavoriteClient"))

pcall(FavoriteClient.Init)

local v = 8

local v2 = 5
local v3 = 2.5

local v4 = 0.025

local v5 = 0.14
local v6 = 0.42

local inFocusRadius = 0.06
local v7 = 1
local v8 = 1

local function numberAttribute(attributeName, p) -- 10 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return if type(attribute) == "number" then attribute else p
end

local function refreshTunables()
	v5 = numberAttribute("LiftPaper", v5) -- inferred equivalent call
	v6 = numberAttribute("LiftDropdown", v6) -- inferred equivalent call
	inFocusRadius = numberAttribute("DofInFocusRadius", inFocusRadius) -- inferred equivalent call
	v7 = numberAttribute("DofFarIntensity", v7) -- inferred equivalent call
	v8 = numberAttribute("DofLayers", v8) -- inferred equivalent call
	v2 = numberAttribute("ParallaxYawDeg", v2) -- inferred equivalent call
	v3 = numberAttribute("ParallaxPitchDeg", v3) -- inferred equivalent call
	v4 = numberAttribute("ParallaxShift", v4) -- inferred equivalent call
	v = numberAttribute("TopClearancePx", v) -- inferred equivalent call
end

local songCatalogDropdownSfx = Instance.new("Sound")
songCatalogDropdownSfx.Name = "SongCatalogDropdownSfx"
songCatalogDropdownSfx.SoundId = "rbxassetid://82896519916504"
songCatalogDropdownSfx.Volume = 0
songCatalogDropdownSfx.Parent = SoundService
task.spawn(function()
	pcall(function()
		ContentProvider:PreloadAsync({ songCatalogDropdownSfx })
	end)
end)

local function playDropdownSfx(p)
	local volume = numberAttribute("SfxVolume", 0.5) -- inferred equivalent call

	if volume <= 0 then
		return
	end

	local clone = songCatalogDropdownSfx:Clone()
	clone.Volume = volume
	clone.PlaybackSpeed = (p and 1 or 0.85) * (0.97 + math.random() * 0.06)
	clone.Parent = SoundService
	clone:Play()
	Debris:AddItem(clone, math.max(clone.TimeLength, 3) / math.max(clone.PlaybackSpeed, 0.1) + 1)
end

local songCatalogBoard = workspace:WaitForChild("Map"):WaitForChild("SongCatalogBoard")
local paper = songCatalogBoard:WaitForChild("Paper")

local cframe = paper.CFrame
local pivot = songCatalogBoard:GetPivot()
local v9 = CatalogBoardUI.CanvasSize.X / paper.Size.X

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local songCatalogSurface = Instance.new("SurfaceGui")
songCatalogSurface.Name = "SongCatalogSurface"
songCatalogSurface.Adornee = paper
songCatalogSurface.Face = Enum.NormalId.Front
songCatalogSurface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
songCatalogSurface.CanvasSize = CatalogBoardUI.CanvasSize
songCatalogSurface.LightInfluence = 0.2
songCatalogSurface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
songCatalogSurface.ResetOnSpawn = false
songCatalogSurface.AlwaysOnTop = false
songCatalogSurface.MaxDistance = 90
songCatalogSurface.Active = false
songCatalogSurface.Parent = PlayerGui

local songCatalogDropdownPlane = Instance.new("Part")
songCatalogDropdownPlane.Name = "SongCatalogDropdownPlane"
songCatalogDropdownPlane.Anchored = true
songCatalogDropdownPlane.CanCollide = false
songCatalogDropdownPlane.CanTouch = false
songCatalogDropdownPlane.CanQuery = false
songCatalogDropdownPlane.CastShadow = false
songCatalogDropdownPlane.Transparency = 1
songCatalogDropdownPlane.Size = Vector3.new(CatalogBoardUI.Layout.WrapW / v9, CatalogBoardUI.Layout.WrapH / v9, 0.02)
songCatalogDropdownPlane.CFrame = cframe
songCatalogDropdownPlane.Parent = workspace

local songCatalogDropSurface = Instance.new("SurfaceGui")
songCatalogDropSurface.Name = "SongCatalogDropSurface"
songCatalogDropSurface.Adornee = songCatalogDropdownPlane
songCatalogDropSurface.Face = Enum.NormalId.Front
songCatalogDropSurface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
songCatalogDropSurface.CanvasSize = Vector2.new(CatalogBoardUI.Layout.WrapW, CatalogBoardUI.Layout.WrapH)
songCatalogDropSurface.LightInfluence = 0.2
songCatalogDropSurface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
songCatalogDropSurface.ResetOnSpawn = false
songCatalogDropSurface.AlwaysOnTop = false
songCatalogDropSurface.MaxDistance = 90
songCatalogDropSurface.Active = false
songCatalogDropSurface.Enabled = false
songCatalogDropSurface.Parent = PlayerGui

local v10 = nil
local v11 = nil
local v12 = {}

local fn
local fn2

local function applySnapshot(p) -- 2 equivalent calls inferred from this helper
	if typeof(p) ~= "table" then
		return
	end

	v10:SetStats(p)

	if typeof(p.MyFavorites) == "table" then
		v10:SetMyFavorites(p.MyFavorites)
	end
end

local CatalogRemotes = ReplicatedStorage:WaitForChild("CatalogRemotes")
local CatalogSnapshot = CatalogRemotes:WaitForChild("CatalogSnapshot")

local CatalogFocus = CatalogRemotes:WaitForChild("CatalogFocus")
local GetCatalogLeaderboard = CatalogRemotes:WaitForChild("GetCatalogLeaderboard")

CatalogSnapshot.OnClientEvent:Connect(function(p)
	if v10 then
		applySnapshot(p) -- inferred equivalent call
	else
		if typeof(p) == "table" and v11 and v11.MyFavorites and not p.MyFavorites then
			p.MyFavorites = v11.MyFavorites
		end

		v11 = p
	end
end)

GlobalEventBus:Subscribe("Favorite:Changed", function(p, p2)
	if v10 then
		v10:SetFavorite(p, p2)
	else
		v12[p] = p2 == true
	end
end)

task.spawn(function()
	local v13 = CatalogBoardUI.new(songCatalogSurface, {
		dropdownSurface = songCatalogDropSurface,
		onFavoriteClicked = function(p)
			GlobalEventBus:Publish("Favorite:RequestToggle", p)
		end,
		onRequestLeaderboard = function(p)
			local success, result = pcall(function()
				return GetCatalogLeaderboard:InvokeServer(p)
			end)
			return if success then result else nil
		end,
		onDropdownOpened = function(p)
			if fn then
				fn(p)
			end
		end,
		onDropdownClosed = function(p)
			if fn2 then
				fn2(p)
			end
		end
	})

	v13:SetSongs(SongConfigAdapter.GetAllSongs())

	v10 = v13

	if v11 then
		applySnapshot(v11) -- inferred equivalent call
		v11 = nil
	end

	for k, v14 in pairs(v12) do
		v10:SetFavorite(k, v14)
	end

	v12 = {}

	CatalogSnapshot:FireServer()
end)

local v13 = {}
local connections = {}

local function hideInstance(instance)
	if instance:IsA("BasePart") then
		if not v13[instance] then
			v13[instance] = { canQuery = instance.CanQuery }
		end

		instance.LocalTransparencyModifier = 1

		instance.CanQuery = false
	elseif instance:IsA("Decal") then
		if not v13[instance] then
			v13[instance] = { transparency = instance.Transparency }
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
		if not v13[instance] then
			v13[instance] = { enabled = instance.Enabled }
		end

		instance.Enabled = false
	elseif instance:IsA("Humanoid") then
		if not v13[instance] then
			v13[instance] = { displayDistance = instance.DisplayDistanceType }
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
	for _, v14 in ipairs(Players:GetPlayers()) do
		if v14.Character then
			hideCharacter(v14.Character)
		end

		table.insert(connections, v14.CharacterAdded:Connect(function(character)
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
	for k, v14 in pairs(v13) do
		if not k.Parent then
			continue
		end

		if v14.canQuery == nil then
			if v14.transparency == nil then
				if v14.enabled == nil then
					if v14.displayDistance ~= nil then
						k.DisplayDistanceType = v14.displayDistance
					end
				else
					k.Enabled = v14.enabled
				end
			else
				k.Transparency = v14.transparency
			end
		else
			k.LocalTransparencyModifier = 0
			k.CanQuery = v14.canQuery
		end
	end

	v13 = {}
end

local flag = false
local count = 0
local v14 = nil
local cameraType = nil
local v15 = nil
local fieldOfView = nil
local v16 = true
local menuFlag = false
local controls = nil
local diedConnection = nil
local renderSteppedConnection = nil
local viewportSizeChangedConnection = nil
local v17 = nil
local v18 = nil
local v19 = false

local v20 = "paper"
local v21 = nil
local v22 = nil

local v23 = nil
local v24 = 2
local cframe2 = nil
local v25 = 7.5
local flag2 = false
local v26 = false
local total = 0
local total2 = 0
local total3 = 0
local total4 = 0

local total5 = 0
local v27 = 0
local total6 = 0
local v28 = 0
local v29 = {}
local depthOfFieldEffect = nil
local enabled = nil
local total7 = 0
local v30 = 0
local focusDistance = 2

local function focusPaperCFrame() -- 3 equivalent calls inferred from this helper
	return cframe + cframe.LookVector * v5
end

local function canvasToWorld(cframe3, p, p2) -- 2 equivalent calls inferred from this helper
	return cframe3:PointToWorldSpace((Vector3.new(paper.Size.X / 2 - p / v9, paper.Size.Y / 2 - p2 / v9, 0)))
end

local function computeFocusLayout(p)
	local canvasSize = CatalogBoardUI.CanvasSize
	local layout = CatalogBoardUI.Layout
	local viewportSize = p.ViewportSize
	local v31 = focusPaperCFrame() -- inferred equivalent call
	local v32 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and 0.78 or 0.6

	local v36 = viewportSize.Y * 0.88 / canvasSize.Y
	local v37 = viewportSize.X * 0.92 / canvasSize.X

	local v38 = math.min(math.max(v36, v32), v37)

	local v39 = viewportSize.Y / (v38 * v9)
	local distance = v39 / 2 / 0.7002075382097097

	local v41 = viewportSize.Y / v38
	local cropped = v36 + 0.001 < v38 or v41 < canvasSize.Y
	local v43 = { cropped = cropped, distance = distance }
	local v44

	if cropped then
		local v45 = v / (v38 * v9)
		v44 = paper.Size.Y / 2 + v45 - v39 / 2

		local visibleBottom = v41 - v / v38 - 12
		v43.visibleBottom = visibleBottom

		v43.scrollPadding = math.clamp(
			layout.ListY + layout.ListH - visibleBottom + 8,
			layout.DefaultScrollPadding,
			layout.ListH - layout.RowH
		)
	else
		v44 = 0
	end

	local v45 = v31.Position + v31.UpVector * v44
	local v46 = v45 + v31.LookVector * distance
	return CFrame.lookAt(v46, v45, Vector3.new(0, 1, 0)), v43
end

local function computeDropdownGoal(p, data)
	local viewportSize = p.ViewportSize

	local v31 = data.W + 60
	local v32 = data.H + 60
	local v36 = math.min(viewportSize.X * 0.9 / v31, viewportSize.Y * 0.9 / v32, 1.7)
	local distance = viewportSize.Y / (v36 * v9) / 2 / 0.7002075382097097

	local v38 = focusPaperCFrame() + cframe.LookVector * v6 -- inferred equivalent call
	local v39 = canvasToWorld(v38, data.X + data.W / 2, data.Y + data.H / 2) -- inferred equivalent call
	local v40 = v39 + v38.LookVector * distance
	return CFrame.lookAt(v40, v39, Vector3.new(0, 1, 0)), { distance = distance }
end

local function computeGoal(p)
	if v20 == "dropdown" and v21 then
		return computeDropdownGoal(p, v21)
	end

	return computeFocusLayout(p)
end

local function setGoalFromMode() -- 2 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v31, v32

	if v20 == "dropdown" and v21 then
		v31, v32 = computeDropdownGoal(currentCamera, v21)
	else
		v31, v32 = computeFocusLayout(currentCamera)
	end

	local distance = v32.distance
	v23 = v31
	v24 = distance
end

local function positionCloseButton(p)
	local v31 = v18

	if not v31 then
		return
	end

	local v32 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	v31.Text = v32 and "BACK" or "BACK  [Q]"

	if p then
		v31.AnchorPoint = Vector2.new(1, 1)
		v31.Position = UDim2.new(1, -16, 1, -16)
		v31.Size = UDim2.fromOffset(v32 and 124 or 170, 40)
	else
		v31.AnchorPoint = Vector2.new(0.5, 1)
		v31.Position = UDim2.new(0.5, 0, 1, -18)
		v31.Size = UDim2.fromOffset(210, 46)
	end
end

local function applyUiLayout(data) -- 2 equivalent calls inferred from this helper
	v19 = data.cropped

	if v10 then
		if data.cropped then
			v10:SetViewport(data.visibleBottom, data.scrollPadding)
		else
			v10:SetViewport(nil, nil)
		end
	end

	positionCloseButton(data.cropped)
end

local function updateLayers()
	local lookVector = cframe.LookVector
	songCatalogBoard:PivotTo(pivot + lookVector * total5)

	local v31 = v22

	if v31 then
		local v32 = cframe + lookVector * total5
		local v36 = canvasToWorld(v32, v31.WrapX + v31.WrapW / 2, v31.WrapY + v31.WrapH / 2) + lookVector * total6 -- inferred equivalent call
		songCatalogDropdownPlane.CFrame = CFrame.new(v36) * v32.Rotation
	end
end

local function ensureDofLayers(parent)
	local v31 = math.clamp(math.floor(v8 + 0.5), 1, 3)

	while #v29 < v31 do
		local songCatalogFocusDoF = Instance.new("DepthOfFieldEffect")
		songCatalogFocusDoF.Name = "SongCatalogFocusDoF"
		songCatalogFocusDoF.InFocusRadius = inFocusRadius
		songCatalogFocusDoF.NearIntensity = 0
		songCatalogFocusDoF.FarIntensity = 0
		songCatalogFocusDoF.FocusDistance = focusDistance
		songCatalogFocusDoF.Parent = parent
		table.insert(v29, songCatalogFocusDoF)
	end

	while v31 < #v29 do
		table.remove(v29):Destroy()
	end
end

local function startDof(currentCamera)
	depthOfFieldEffect = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")

	if depthOfFieldEffect then
		enabled = depthOfFieldEffect.Enabled
		depthOfFieldEffect.Enabled = false
	end

	total7 = 0
	v30 = 1
	local cframe3 = currentCamera.CFrame
	focusDistance = math.max((focusPaperCFrame().Position - cframe3.Position):Dot(cframe3.LookVector), 0.5) -- inferred equivalent call
	ensureDofLayers(currentCamera)
end

local function stopDof()
	for _, v31 in ipairs(v29) do
		v31:Destroy()
	end

	v29 = {}

	if depthOfFieldEffect and enabled ~= nil then
		depthOfFieldEffect.Enabled = enabled
	end

	depthOfFieldEffect = nil
	enabled = nil
	total7 = 0
	v30 = 0
end

local function updateDof(p, currentCamera)
	if #v29 == 0 then
		return
	end

	ensureDofLayers(currentCamera)
	total7 += (v30 - total7) * (1 - math.exp(-p * 4))
	local v31

	if v28 > 0 and v22 then
		v31 = songCatalogDropdownPlane.Position
	else
		v31 = cframe.Position + cframe.LookVector * total5
	end

	local cframe3 = currentCamera.CFrame
	local v32 = math.max((v31 - cframe3.Position):Dot(cframe3.LookVector), 0.2)
	focusDistance += (v32 - focusDistance) * (1 - math.exp(-p * 8))

	for _, v36 in ipairs(v29) do
		v36.FocusDistance = focusDistance
		v36.InFocusRadius = inFocusRadius
		v36.NearIntensity = 0
		v36.FarIntensity = v7 * total7
	end
end

local function finalizeLayers() -- 2 equivalent calls inferred from this helper
	total5 = 0
	v27 = 0
	total6 = 0
	v28 = 0
	v22 = nil
	songCatalogBoard:PivotTo(pivot)
	songCatalogDropSurface.Enabled = false
	songCatalogDropSurface.Active = false
	songCatalogDropdownPlane.CanQuery = false
	stopDof()
end

local function parallaxCurve(p) -- 2 equivalent calls inferred from this helper
	return math.sign(p) * math.abs(p) ^ 1.25
end

local function cameraStep(p)
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and v23 and cframe2) then
		return
	end

	local v31 = math.min(p, 0.1)

	refreshTunables()

	if flag then
		v27 = v5

		if v28 > 0 then
			v28 = v6
		end
	end

	cframe2 = cframe2:Lerp(v23, 1 - math.exp(-v31 * v25))

	total5 += (v27 - total5) * (1 - math.exp(-v31 * 6))
	total6 += (v28 - total6) * (1 - math.exp(-v31 * 6))
	updateLayers()

	if v22 and v28 == 0 and total6 < 0.01 then
		v22 = nil
		songCatalogDropSurface.Enabled = false
		songCatalogDropdownPlane.CanQuery = false
	end

	total += ((v26 and 1 or 0) - total) * (1 - math.exp(-v31 * 3))
	local v32, v36

	if UserInputService.MouseEnabled then
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportSize = currentCamera.ViewportSize
		local v37 = math.clamp((mouseLocation.X - viewportSize.X / 2) / (viewportSize.X / 2), -1, 1)
		local v38 = math.clamp(-(mouseLocation.Y - viewportSize.Y / 2) / (viewportSize.Y / 2), -1, 1)
		v32 = parallaxCurve(v37) -- inferred equivalent call
		v36 = parallaxCurve(v38) -- inferred equivalent call
	else
		v32 = 0
		v36 = 0
	end

	local v37 = v10 and v10:IsInteractiveHovered() and 1
		or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and 1
		or 0
	total4 += (v37 - total4) * (1 - math.exp(-v31 * 12))
	local v38 = (1 - math.exp(-v31 * 5)) * (1 - total4)
	total2 += (v32 - total2) * v38
	total3 += (v36 - total3) * v38

	local now = os.clock()
	local v39 = math.sin(now * 0.7) * 0.1 + math.sin(now * 1.9) * 0.1 * 0.35
	local v40 = math.cos(now * 0.55) * 0.07
	local v41 = total * (v20 == "dropdown" and 0.55 or 1)
	local v42 = 1 - total4 * 0.9
	local v43 = (total2 + v39 * v42) * v41
	local v44 = (total3 + v40 * v42) * v41

	local v45 = -math.rad(v2) * v43
	local v46 = math.rad(v3) * v44
	local v47 = -v43 * 0.02
	local v48 = cframe2.RightVector * (v43 * v24 * v4) + cframe2.UpVector * (v44 * v24 * v4)
	currentCamera.CFrame = cframe2 * CFrame.Angles(v46, v45, v47) + v48

	updateDof(v31, currentCamera)
end

local function stopCameraStep() -- 2 equivalent calls inferred from this helper
	if flag2 then
		flag2 = false
		RunService:UnbindFromRenderStep("SongCatalogCamera")
	end
end

local function waitForCameraSettle(p)
	local lastTime = os.clock()

	while os.clock() - lastTime < p do
		RunService.RenderStepped:Wait()

		if
			cframe2
			and v23
			and (cframe2.Position - v23.Position).Magnitude < 0.02
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

local fn3

local function createFocusGui()
	if v17 then
		return v17
	end

	local songCatalogFocusUI = Instance.new("ScreenGui")
	songCatalogFocusUI.Name = "SongCatalogFocusUI"
	songCatalogFocusUI.ResetOnSpawn = false
	songCatalogFocusUI.DisplayOrder = 60
	songCatalogFocusUI.IgnoreGuiInset = false
	songCatalogFocusUI.Enabled = false
	songCatalogFocusUI.Parent = PlayerGui

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
	closeButton.Parent = songCatalogFocusUI
	v18 = closeButton

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	require(ReplicatedStorage2.Modules:WaitForChild("BoardBackButton")).Style(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		BoardSwitch.Back()
	end)

	v17 = songCatalogFocusUI
	return songCatalogFocusUI
end

fn = function(p)
	if not flag then
		return
	end

	playDropdownSfx(true)
	v20 = "dropdown"
	v21 = p
	v22 = p
	v28 = v6

	if total6 < 0.03 then
		total6 = 0.03
	end

	updateLayers()
	songCatalogDropdownPlane.CanQuery = true
	songCatalogDropSurface.Active = true
	songCatalogDropSurface.Enabled = true
	setGoalFromMode() -- inferred equivalent call

	if v17 then
		v17.Enabled = false
	end
end

fn2 = function(p)
	if not flag then
		return
	end

	if not p then
		playDropdownSfx(false)
	end

	v20 = "paper"
	v21 = nil
	v28 = 0
	setGoalFromMode() -- inferred equivalent call

	if v17 then
		v17.Enabled = true
	end
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
	local v31 = count
	v14 = character

	refreshTunables()

	if data then
		cameraType = data.CameraType
		v15 = data.CameraCFrame
		fieldOfView = data.FieldOfView
	else
		cameraType = currentCamera.CameraType
		v15 = currentCamera.CFrame
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

		if not flag or count ~= v31 then
			return
		end
	end

	setControlsEnabled(false) -- inferred equivalent call

	if data then
		v16 = data.PromptServiceEnabled
	else
		v16 = ProximityPromptService.Enabled
	end

	ProximityPromptService.Enabled = false

	hideAllPlayers()
	task.spawn(function()
		while flag and count == v31 do
			for _, v32 in ipairs(Players:GetPlayers()) do
				local character2 = v32.Character

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

	songCatalogSurface.Active = true

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 70

	v20 = "paper"
	v21 = nil
	v22 = nil
	total5 = 0
	v27 = v5
	total6 = 0
	v28 = 0
	startDof(currentCamera)

	local v32, v37 = computeFocusLayout(currentCamera)
	applyUiLayout(v37) -- inferred equivalent call
	local distance = v37.distance
	v23 = v32
	v24 = distance
	cframe2 = currentCamera.CFrame
	v25 = 7.5
	v26 = false
	total = 0
	total2 = 0
	total3 = 0
	total4 = 0

	RunService:BindToRenderStep("SongCatalogCamera", Enum.RenderPriority.Camera.Value + 1, cameraStep)
	flag2 = true
	task.delay(0.45, function()
		if flag and count == v31 then
			v26 = true
		end
	end)

	viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if not flag then
			return
		end

		v20 = "paper"
		v21 = nil
		local v38, v39 = computeFocusLayout(currentCamera)
		local distance2 = v39.distance
		v23 = v38
		v24 = distance2
		applyUiLayout(v39) -- inferred equivalent call
	end)

	local focusGui = createFocusGui()
	focusGui.Enabled = true
	positionCloseButton(v19)

	if data then
		task.delay(0.45, function()
			if flag and count == v31 then
				CatalogFocus:FireServer(true)
			end
		end)
	else
		CatalogFocus:FireServer(true)
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true

		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			task.spawn(fn3)
			return
		end

		local fov = BoardZoom.Fov(70)

		if math.abs(currentCamera.FieldOfView - fov) > 0.01 then
			currentCamera.FieldOfView = fov
		end
	end)

	ContextActionService:BindActionAtPriority("CatalogBoardExit", function(_, p)
		if p == Enum.UserInputState.Begin then
			if v10 and v10:IsDropdownOpen() then
				v10:CloseDropdown()
			else
				BoardSwitch.Back()
			end
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Q, Enum.KeyCode.Backspace, Enum.KeyCode.ButtonB)

	diedConnection = humanoid.Died:Connect(function()
		fn3()
	end)

	BoardSwitch.SetCurrent("Catalog")
end

fn3 = function(p)
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

	ContextActionService:UnbindAction("CatalogBoardExit")

	CatalogFocus:FireServer(false)

	if v10 then
		v10:SetViewport(nil, nil)
		v10:ResetHover()
	end

	songCatalogSurface.Active = false
	songCatalogDropSurface.Active = false

	if v17 then
		v17.Enabled = false
	end

	if p then
		stopCameraStep() -- inferred equivalent call
		finalizeLayers() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		local v31 = {
			CameraType = cameraType,
			CameraCFrame = v15,
			FieldOfView = fieldOfView,
			PromptServiceEnabled = v16,
			MenuFlag = menuFlag
		}

		menuFlag = false
		v20 = "paper"
		v21 = nil
		v15 = nil
		v14 = nil
		BoardSwitch.ClearCurrent("Catalog")
		return v31
	else
		local currentCamera = workspace.CurrentCamera
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v31

		if currentCamera == nil or v15 == nil or character ~= v14 or humanoid == nil or not (humanoid.Health > 0) then
			v31 = false
		else
			v31 = humanoidRootPart ~= nil
		end

		v27 = 0
		v28 = 0
		v30 = 0
		v26 = false

		stopWatchingPlayers()
		restoreAllHidden()

		if v31 then
			v23 = v15
			v25 = 9
			waitForCameraSettle(0.9)
		end

		stopCameraStep() -- inferred equivalent call
		finalizeLayers() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		ProximityPromptService.Enabled = v16
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		if currentCamera then
			local cameraType2 = cameraType or Enum.CameraType.Custom

			if cameraType2 == Enum.CameraType.Scriptable then
				cameraType2 = Enum.CameraType.Custom
			end

			if v31 then
				currentCamera.CFrame = v15
				local v32 = math.clamp((v15.Position - humanoidRootPart.Position).Magnitude, 0.5, 20)
				LocalPlayer.CameraMinZoomDistance = v32
				LocalPlayer.CameraMaxZoomDistance = v32
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
		v20 = "paper"
		v21 = nil
		v15 = nil
		v14 = nil
		BoardSwitch.ClearCurrent("Catalog")
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	if flag then
		task.spawn(fn3)
	end
end)

BoardSwitch.Register("Catalog", {
	Part = paper,
	ExitForHandoff = function()
		return fn3(true)
	end,
	EnterWithHandoff = function(p)
		enterFocus(p)
	end,
	Exit = function()
		fn3()
	end
})

task.spawn(function()
	local switchClick = paper:WaitForChild("SwitchClick", 15)

	if switchClick then
		switchClick.MouseClick:Connect(function(p)
			if p == LocalPlayer then
				BoardSwitch.Request("Catalog")
			end
		end)
	end
end)