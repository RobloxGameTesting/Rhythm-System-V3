local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CaptureService = game:GetService("CaptureService")

local GCamConfig = require(script.Parent.GCamConfig)
local GCamFx = require(script.Parent.GCamFx)

local GCamDevelop = {}

local LocalPlayer = Players.LocalPlayer
local flag = false
local v = {}

function GCamDevelop.PartKey(p, instance)
	local v2 = {}

	while instance and instance ~= p do
		table.insert(v2, 1, instance.Name)
		instance = instance.Parent
	end

	return table.concat(v2, "/")
end

function GCamDevelop.IsBusy()
	return flag
end

local function setCharactersHidden(p, localTransparencyModifiersByPart)
	for _, v2 in ipairs(Players:GetPlayers()) do
		local character = v2.Character

		if not character then
			continue
		end

		for _, part in ipairs(character:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			if p then
				if localTransparencyModifiersByPart[part] == nil then
					localTransparencyModifiersByPart[part] = part.LocalTransparencyModifier
				end

				part.LocalTransparencyModifier = 1
			elseif localTransparencyModifiersByPart[part] ~= nil then
				part.LocalTransparencyModifier = localTransparencyModifiersByPart[part]
			end
		end
	end
end

local function setNamesHidden(p, p2)
	for _, v2 in ipairs(Players:GetPlayers()) do
		local character = v2.Character

		if not character then
			continue
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			if p then
				if p2[humanoid] == nil then
					p2[humanoid] = humanoid.DisplayDistanceType
				end

				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			elseif p2[humanoid] ~= nil then
				humanoid.DisplayDistanceType = p2[humanoid]
			end
		end

		for _, billboardGui in ipairs(character:GetDescendants()) do
			if not billboardGui:IsA("BillboardGui") then
				continue
			end

			if p then
				if p2[billboardGui] == nil then
					p2[billboardGui] = billboardGui.Enabled
				end

				billboardGui.Enabled = false
			elseif p2[billboardGui] ~= nil then
				billboardGui.Enabled = p2[billboardGui]
			end
		end
	end
end

local function buildGhosts(data)
	local gCamGhosts = Instance.new("Folder")
	gCamGhosts.Name = "GCamGhosts"
	gCamGhosts.Parent = Workspace

	for _, v2 in ipairs(data.chars or {}) do
		local folder = nil
		local v3 = "user" .. tostring(v2.uid)
		local playerByUserId = Players:GetPlayerByUserId(v2.uid)
		local character = playerByUserId and playerByUserId.Character

		if character then
			v3 = playerByUserId.Name
			local archivable = character.Archivable
			character.Archivable = true
			local success, result = pcall(function()
				return character:Clone()
			end)

			character.Archivable = archivable

			if success then
				folder = result
			end
		else
			local success, result = pcall(function()
				local v4 = v[v2.uid]

				if not v4 then
					v4 = Players:GetHumanoidDescriptionFromUserId(v2.uid)
					v[v2.uid] = v4
				end

				return Players:CreateHumanoidModelFromDescription(v4, Enum.HumanoidRigType.R15)
			end)

			if success and result then
				folder = result
			end
		end

		if not folder then
			continue
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("BaseScript") or descendant:IsA("BillboardGui") then
				descendant:Destroy()
			end
		end

		local humanoid = folder:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			humanoid.PlatformStand = true
			humanoid.BreakJointsOnDeath = false
		end

		for _, part in ipairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.LocalTransparencyModifier = 0
			local v4 = v2.p[GCamDevelop.PartKey(folder, part)]

			if v4 then
				part.CFrame = CFrame.new(table.unpack(v4))
			end
		end

		folder.Name = "Ghost_" .. v3
		folder.Parent = gCamGhosts
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local gCamAssets = ReplicatedStorage:FindFirstChild("GCamAssets")
	local handle = gCamAssets and gCamAssets:FindFirstChild("Handle")

	if not handle then
		return gCamGhosts
	end

	for _, list in ipairs(data.cams or {}) do
		local success, result = pcall(function()
			return CFrame.new(table.unpack(list))
		end)

		if not success then
			continue
		end

		local clone = handle:Clone()
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CFrame = result
		clone.Parent = gCamGhosts
	end

	return gCamGhosts
end

function GCamDevelop.Run(data, callback)
	if flag then
		return nil
	end

	flag = true

	local currentCamera = Workspace.CurrentCamera
	local cframe = currentCamera.CFrame
	local fieldOfView = currentCamera.FieldOfView
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local success, result = pcall(function()
		return CFrame.new(table.unpack(data.cf))
	end)

	if not success then
		flag = false
		return nil
	end

	if Workspace.StreamingEnabled then
		pcall(function()
			LocalPlayer:RequestStreamAroundAsync(result.Position, 2.5)
		end)
	end

	local ghosts = buildGhosts(data)

	local v2 = {}

	setNamesHidden(true, v2)

	local gCamDevelopGui = Instance.new("ScreenGui")
	gCamDevelopGui.Name = "GCamDevelopGui"
	gCamDevelopGui.IgnoreGuiInset = true
	gCamDevelopGui.ResetOnSpawn = false
	gCamDevelopGui.DisplayOrder = 2000
	gCamDevelopGui.Parent = playerGui
	local screenGuiSet = {}
	local v3 = {}

	for _, screenGui in ipairs(playerGui:GetChildren()) do
		if not (screenGui:IsA("ScreenGui") and screenGui ~= gCamDevelopGui and screenGui.Enabled) then
			continue
		end

		screenGuiSet[screenGui] = true
		screenGui.Enabled = false
	end

	local v4 = GCamFx.new(gCamDevelopGui, {
		low = data.low == true
	})
	local filter = GCamConfig.GetFilterById(data.filter)
	v4:SetEnabled(true)
	v4:SetFilter(filter, true)

	if data.flash then
		v4:SetBoost(0.1)

		local gCamFlashLight = Instance.new("Part")
		gCamFlashLight.Name = "GCamFlashLight"
		gCamFlashLight.Size = Vector3.new(0.2, 0.2, 0.2)
		gCamFlashLight.Transparency = 1
		gCamFlashLight.Anchored = true
		gCamFlashLight.CanCollide = false
		gCamFlashLight.CanQuery = false
		gCamFlashLight.CanTouch = false
		gCamFlashLight.CFrame = result * CFrame.new(0.1, -0.1, -0.6)
		local spotLight = Instance.new("SpotLight")
		spotLight.Face = Enum.NormalId.Front
		spotLight.Angle = 115
		spotLight.Range = 70
		spotLight.Brightness = 6
		spotLight.Color = Color3.fromRGB(255, 244, 228)
		spotLight.Shadows = true
		spotLight.Parent = gCamFlashLight
		local pointLight = Instance.new("PointLight")
		pointLight.Range = 16
		pointLight.Brightness = 3
		pointLight.Color = Color3.fromRGB(255, 244, 228)
		pointLight.Parent = gCamFlashLight
		gCamFlashLight.Parent = ghosts
	end

	v4:SetFocus(data.focus or 40, true)
	v4:SetFilter(filter, true)
	v4:SetBoost(data.flash and 0.1 or 0)

	local function force()
		currentCamera.CFrame = result
		currentCamera.FieldOfView = data.fov or GCamConfig.BASE_FOV
		setCharactersHidden(true, v3)

		if callback then
			pcall(callback, true)
		end
	end
	RunService:BindToRenderStep("GCamDevelopForce", Enum.RenderPriority.Last.Value, force)

	for _ = 1, 4 do
		v4:Step(1 / 30, data.zoom or 1)
		RunService.RenderStepped:Wait()
	end

	local v5 = nil
	local v6 = false
	local v7 = pcall(function()
		CaptureService:CaptureScreenshot(function(p)
			v5 = p
			v6 = true
		end)
	end)
	local lastTime = os.clock()

	while v7 and not v6 and os.clock() - lastTime < 4 do
		RunService.RenderStepped:Wait()
	end

	RunService:UnbindFromRenderStep("GCamDevelopForce")
	currentCamera.CFrame = cframe
	currentCamera.FieldOfView = fieldOfView
	setCharactersHidden(false, v3)
	setNamesHidden(false, v2)

	if callback then
		pcall(callback, false)
	end

	v4:Destroy()
	gCamDevelopGui:Destroy()
	ghosts:Destroy()

	for k in pairs(screenGuiSet) do
		if k.Parent then
			k.Enabled = true
		end
	end

	flag = false
	return v5
end

return GCamDevelop