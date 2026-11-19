local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstrumentConfig = require(ReplicatedStorage.Modules.InstrumentConfig)

local AvatarBundleDatabase = require(ReplicatedStorage.Modules.AvatarBundleDatabase)

local AvatarTypeVerify = {}

local v = {}

local function detectAvatarCategory(player)
	local character = player.Character

	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	local success, result = pcall(function()
		return humanoid:GetAppliedDescription()
	end)

	if not success or result == nil then
		warn(string.format(
			"[AvatarTypeVerify] Gagal mengambil HumanoidDescription untuk %s: %s",
			player.Name,
			(tostring(result))
		))

		return nil
	end

	local v2 = { result.Torso, result.LeftArm, result.RightArm, result.LeftLeg, result.RightLeg }

	local v3 = {}

	for k, bundleAssetId in pairs(AvatarBundleDatabase.BundleAssetIds) do
		for _, v4 in ipairs(v2) do
			if bundleAssetId[v4] then
				table.insert(v3, k)
				break
			end
		end
	end

	if #v3 > 1 then
		warn(string.format(
			"[AvatarTypeVerify] %s terdeteksi match lebih dari 1 kategori sekaligus (%s), memakai yang pertama.",
			player.Name,
			table.concat(v3, ", ")
		))
	end

	if #v3 > 0 then
		return v3[1]
	end

	local v4

	if result.Torso == 0 and result.LeftArm == 0 then
		v4 = result.RightArm == 0
	else
		v4 = false
	end

	return if not v4 then "BlushDoll" else nil
end

function AvatarTypeVerify.GetAvatarType(p)
	local v2 = v[p]

	if v2 then
		return v2
	end

	local v3 = detectAvatarCategory(p) or "Masculine"

	v[p] = v3
	return v3
end

function AvatarTypeVerify.RefreshAvatarType(p)
	v[p] = nil
	return AvatarTypeVerify.GetAvatarType(p)
end

Players.PlayerRemoving:Connect(function(player)
	v[player] = nil
end)

local function onPlayerAddedForRefresh(p) -- 1 equivalent call inferred from this helper
	p.CharacterAdded:Connect(function(_)
		task.wait(1.5)
		AvatarTypeVerify.RefreshAvatarType(p)
	end)
end

for _, v2 in ipairs(Players:GetPlayers()) do
	onPlayerAddedForRefresh(v2) -- inferred equivalent call
end

Players.PlayerAdded:Connect(onPlayerAddedForRefresh)

function AvatarTypeVerify.GetHoldingIdleAnimationId(p, p2: string)
	local instrument = InstrumentConfig.Instruments[p2]

	if not instrument then
		warn(string.format("[AvatarTypeVerify] Instrumen tidak dikenali di InstrumentConfig: %s", p2))
		return nil
	end

	local holdingIdleAnimationId = instrument.HoldingIdleAnimationId

	if holdingIdleAnimationId == nil then
		return nil
	end

	local avatarType = AvatarTypeVerify.GetAvatarType(p)

	local holdingIdleOverride = AvatarBundleDatabase.HoldingIdleOverridesByCategory[avatarType]

	local v2 = holdingIdleOverride and holdingIdleOverride[p2]

	if v2 then
		return v2
	end

	if avatarType == "Masculine" then
		return holdingIdleAnimationId
	end

	return nil
end

function AvatarTypeVerify.GetScaleGroup(p)
	local avatarType = AvatarTypeVerify.GetAvatarType(p)
	return AvatarBundleDatabase.CategoryToScaleGroup[avatarType] or "Male"
end

return AvatarTypeVerify