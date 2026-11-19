local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StarPowerSongConfig = require(ReplicatedStorage.Modules.StarPowerSongConfig)

local v = {}

local function resolvePoseName(p, p2) -- 1 equivalent call inferred from this helper
	local v2 = p and StarPowerSongConfig.Songs[p]
	return v2 and v2.Poses and v2.Poses[p2] or StarPowerSongConfig.DefaultPoseByLevel[p2]
end

local function getAnimationForPose(p) -- 1 equivalent call inferred from this helper
	if not p then
		return nil
	end

	if v[p] ~= nil then
		return v[p] or nil
	end

	local animationId = StarPowerSongConfig.PoseLibrary[p]

	if not animationId or animationId == "" then
		v[p] = false
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	v[p] = animation
	return animation
end

local function playPoseFor(player, p, value)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local animationForPose = getAnimationForPose(resolvePoseName(value, p)) -- inferred equivalent call

	if not animationForPose then
		return
	end

	local success, result = pcall(function()
		return animator:LoadAnimation(animationForPose)
	end)

	if success and result then
		result:Play()
	end
end

ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BroadcastStarPowerActivation").OnClientEvent:Connect(function(player, value, value2)
	if typeof(player) ~= "Instance" or not player:IsA("Player") or typeof(value) ~= "number" then
		return
	end

	if value2 ~= nil and typeof(value2) ~= "string" then
		value2 = nil
	end

	playPoseFor(player, math.floor(value), value2)
end)