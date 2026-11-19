local CommonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(CommonUtils:WaitForChild("FlagUtil"))

local userFlag = FlagUtil.getUserFlag("UserRaycastUpdateAPI2")

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local PathDisplay = {}
PathDisplay.spacing = 8
PathDisplay.image = "rbxasset://textures/Cursors/Gamepad/Pointer.png"
PathDisplay.imageSize = Vector2.new(2, 2)

local pathDisplayPoints = Instance.new("Model")
pathDisplayPoints.Name = "PathDisplayPoints"

local pathDisplayAdornee = Instance.new("Part")
pathDisplayAdornee.Anchored = true
pathDisplayAdornee.CanCollide = false
pathDisplayAdornee.Transparency = 1
pathDisplayAdornee.Name = "PathDisplayAdornee"
pathDisplayAdornee.CFrame = CFrame.new(0, 0, 0)
pathDisplayAdornee.Parent = pathDisplayPoints

local v = 30
local v2 = {}
local v3 = {}
local v4 = {}

for i = 1, v do
	local imageHandleAdornment = Instance.new("ImageHandleAdornment")
	imageHandleAdornment.Archivable = false
	imageHandleAdornment.Adornee = pathDisplayAdornee
	imageHandleAdornment.Image = PathDisplay.image
	imageHandleAdornment.Size = PathDisplay.imageSize
	v2[i] = imageHandleAdornment
end

local function retrieveFromPool() -- 1 equivalent call inferred from this helper
	local v5 = v2[1]

	if not v5 then
		return nil
	end

	local v6 = v
	v2[1] = v2[v]
	v2[v6] = nil
	v -= 1
	return v5
end

local function returnToPool(p) -- 1 equivalent call inferred from this helper
	v += 1
	v2[v] = p
end

local function renderPoint(vector3: Vector3, _)
	if v == 0 then
		return nil
	end

	local selected = retrieveFromPool() -- inferred equivalent call

	if userFlag then
		raycastParams.FilterDescendantsInstances = { game.Players.LocalPlayer.Character, workspace.CurrentCamera }
		local raycastResult = workspace:Raycast(vector3 + Vector3.new(0, 2, 0), Vector3.new(0, -8, 0), raycastParams)

		if not raycastResult then
			return nil
		end

		selected.CFrame = CFrame.lookAlong(raycastResult.Position, raycastResult.Normal)
		selected.Parent = pathDisplayPoints
		return selected
	else
		local ray = Ray.new(vector3 + Vector3.new(0, 2, 0), Vector3.new(0, -8, 0))
		local part, v5, v6 = workspace:FindPartOnRayWithIgnoreList(ray, {
			game.Players.LocalPlayer.Character,
			workspace.CurrentCamera
		})

		if not part then
			return nil
		end

		selected.CFrame = CFrame.new(v5, v5 + v6)
		selected.Parent = pathDisplayPoints

		return selected
	end
end

function PathDisplay.setCurrentPoints(p)
	if typeof(p) == "table" then
		v3 = p
	else
		v3 = {}
	end
end

function PathDisplay.clearRenderedPath()
	for _, v5 in ipairs(v4) do
		v5.Parent = nil
		returnToPool(v5) -- inferred equivalent call
	end

	v4 = {}
	pathDisplayPoints.Parent = nil
end

function PathDisplay.renderPath()
	PathDisplay.clearRenderedPath()

	if not v3 or #v3 == 0 then
		return
	end

	local count = #v3
	local v5 = v3[count]

	v4[1] = renderPoint(v5, true)

	if not v4[1] then
		return
	end

	local v6 = 0

	while true do
		local v7 = v3[count]
		local v8 = v3[count - 1]

		if count < 2 then
			break
		end

		local v9 = v8 - v7
		local magnitude = v9.magnitude

		if magnitude < v6 then
			v6 -= magnitude
			count -= 1
		else
			local v10 = renderPoint(v7 + v9.unit * v6, false)

			if v10 then
				v4[#v4 + 1] = v10
			end

			v6 += PathDisplay.spacing
		end
	end

	pathDisplayPoints.Parent = workspace.CurrentCamera
end

return PathDisplay