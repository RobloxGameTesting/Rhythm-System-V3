local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local BoardSwitch = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BoardSwitch"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local v = {
	"NoteBoardSurface",
	"SongCatalogSurface",
	"InfoBoardSurface",
	"HallOfFameBannerSurface"
}

local function attr(attributeName, p) -- 9 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return type(attribute) == "number" and attribute or p
end

local boardExtras = workspace:WaitForChild("Map"):WaitForChild("BoardExtras")
local boardViewAnchor = boardExtras:WaitForChild("BoardViewAnchor")
local boardLoadZone = boardExtras:WaitForChild("BoardLoadZone", 10)

local v2 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v3 = {}

local function insideZone(position, p, p2): boolean
	local halfSize = boardLoadZone.Size / 2
	local pointToObjectSpace = boardLoadZone.CFrame:PointToObjectSpace(position)
	local v4 = halfSize.X * p + p2
	local v5 = halfSize.Y + p2
	local v6 = halfSize.Z * p + p2
	return math.abs(pointToObjectSpace.X) <= v4
		and math.abs(pointToObjectSpace.Y) <= v5
		and math.abs(pointToObjectSpace.Z) <= v6
end

local function isInside(p, p2)
	local currentCamera = workspace.CurrentCamera
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v4

	if p2 then
		v4 = attr("Margin", 2) or 0 -- inferred equivalent call
	else
		v4 = 0
	end

	local v5

	if v2 then
		v5 = attr("TouchScale", 0.75) or 1 -- inferred equivalent call
	else
		v5 = 1
	end

	if p == "HallOfFameBannerSurface" then
		v5 *= attr("BannerScale", 1.4) -- inferred equivalent call
	end

	if boardLoadZone and boardLoadZone.Parent then
		if humanoidRootPart and insideZone(humanoidRootPart.Position, v5, v4) then
			return true
		end

		return currentCamera ~= nil and insideZone(currentCamera.CFrame.Position, v5, v4)
	else
		local v6 = attr("FallbackRadius", 20) * v5 + v4 -- inferred equivalent call

		if humanoidRootPart and (humanoidRootPart.Position - boardViewAnchor.Position).Magnitude <= v6 then
			return true
		end

		return currentCamera ~= nil and (currentCamera.CFrame.Position - boardViewAnchor.Position).Magnitude <= v6
	end
end

local function boardInView(p): boolean
	if BoardSwitch.GetCurrent() ~= nil then
		return true
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return true
	end

	local v4 = boardViewAnchor.Position - currentCamera.CFrame.Position
	local magnitude = v4.Magnitude

	if magnitude < 3 then
		return true
	end

	local v5 = math.deg((math.acos((math.clamp(currentCamera.CFrame.LookVector:Dot(v4 / magnitude), -1, 1)))))

	local viewportSize = currentCamera.ViewportSize
	local v6 = math.max(viewportSize.X / math.max(viewportSize.Y, 1), 0.5)
	local v7 = math.rad(currentCamera.FieldOfView) / 2
	local v8 = math.atan(math.tan(v7) * v6)
	local v9 = math.min(math.deg((math.sqrt(v8 * v8 + v7 * v7))), 85)
	local v10 = math.deg((math.atan(attr("BoardHalfExtent", 7) / magnitude))) -- inferred equivalent call
	local v11, facingMarginOn

	if p then
		v11 = attr("FacingMarginOff", 40) -- inferred equivalent call

		if not v11 then
			facingMarginOn = script:GetAttribute("FacingMarginOn")
			v11 = type(facingMarginOn) == "number" and facingMarginOn or 30
		end
	else
		facingMarginOn = script:GetAttribute("FacingMarginOn")
		v11 = type(facingMarginOn) == "number" and facingMarginOn or 30
	end

	return v5 <= v9 + v10 + v11
end

local v4 = {
	Catalog = "SongCatalogSurface",
	Notes = "NoteBoardSurface",
	Info = "InfoBoardSurface",
	Hall = "HallOfFameBannerSurface"
}

local function guiOnScreen(p, p2): boolean
	local adornee = p.Adornee
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and adornee and adornee:IsA("BasePart")) then
		return true
	end

	local viewportSize = currentCamera.ViewportSize
	local current = BoardSwitch.GetCurrent()
	local v5

	if current == nil or current == "Overview" then
		local screenMarginOn

		if p2 then
			v5 = attr("ScreenMarginOff", 0.6) -- inferred equivalent call

			if not v5 then
				screenMarginOn = script:GetAttribute("ScreenMarginOn")
				v5 = type(screenMarginOn) == "number" and screenMarginOn or 0.4
			end
		else
			screenMarginOn = script:GetAttribute("ScreenMarginOn")
			v5 = type(screenMarginOn) == "number" and screenMarginOn or 0.4
		end
	else
		local focusScreenMarginOn

		if p2 then
			v5 = attr("FocusScreenMarginOff", 0.1) -- inferred equivalent call

			if not v5 then
				focusScreenMarginOn = script:GetAttribute("FocusScreenMarginOn")
				v5 = type(focusScreenMarginOn) == "number" and focusScreenMarginOn or 0.06
			end
		else
			focusScreenMarginOn = script:GetAttribute("FocusScreenMarginOn")
			v5 = type(focusScreenMarginOn) == "number" and focusScreenMarginOn or 0.06
		end
	end

	local v6 = -viewportSize.X * v5
	local v7 = -viewportSize.Y * v5
	local v8 = viewportSize.X * (1 + v5)
	local v9 = viewportSize.Y * (1 + v5)

	local cframe = adornee.CFrame
	local halfSize = adornee.Size / 2
	local minX = 1e999
	local minY = 1e999
	local maxX = -1e999
	local maxY = -1e999
	local v10 = false
	local flag = true

	for _, v11 in ipairs({ -1, 1 }) do
		for _, v12 in ipairs({ -1, 1 }) do
			local worldToViewportPoint = currentCamera:WorldToViewportPoint((cframe:PointToWorldSpace((Vector3.new(halfSize.X * v11, halfSize.Y * v12, 0)))))

			if worldToViewportPoint.Z > 0 then
				minX = math.min(minX, worldToViewportPoint.X)
				minY = math.min(minY, worldToViewportPoint.Y)
				maxX = math.max(maxX, worldToViewportPoint.X)
				maxY = math.max(maxY, worldToViewportPoint.Y)
				v10 = true
			else
				flag = false
			end
		end
	end

	return not not v10 and (not flag or not (maxX < v6 or v8 < minX or maxY < v7 or v9 < minY))
end

local function shouldShow(childName, surfaceGui, p)
	if not (isInside(childName, p) and boardInView(p)) then
		return false
	end

	local current = BoardSwitch.GetCurrent()

	if current ~= nil then
		if v4[current] == childName then
			return true
		end

		if current ~= "Overview" and attr("HideNeighborsInFocus", 0) == 1 then -- inferred equivalent call
			return false
		end
	end

	return guiOnScreen(surfaceGui, p)
end

local function step()
	for _, childName in ipairs(v) do
		local surfaceGui = PlayerGui:FindFirstChild(childName)

		if not (surfaceGui and surfaceGui:IsA("SurfaceGui")) then
			continue
		end

		if v3[surfaceGui] then
			if shouldShow(childName, surfaceGui, false) then
				v3[surfaceGui] = nil
				surfaceGui.Enabled = true
			end
		elseif surfaceGui.Enabled and not shouldShow(childName, surfaceGui, true) then
			v3[surfaceGui] = true
			surfaceGui.Enabled = false
		end
	end
end

BoardSwitch.Changed:Connect(function()
	task.defer(step)
end)

task.spawn(function()
	while true do
		step()

		if BoardSwitch.GetCurrent() == nil then
			task.wait(0.2)
		else
			task.wait()
		end
	end
end)