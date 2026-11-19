local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local offsets = { Vector3.new(-75, 15, 10), Vector3.new(60, 15, -70), Vector3.new(10, 15, 95) }
local v = {
	{
		name = "Main",
		center = Vector3.new(-100, 15, -25),
		offsets = { Vector3.new(-210, 30, 20), Vector3.new(170, 30, -120), Vector3.new(-40, 30, 190) }
	}
}
local v2 = { 35, 100 }

for i = 1, 8 do
	table.insert(v, {
		name = "STUDIO " .. i,
		center = Vector3.new((i - 1) * 1500 + 3903, 10, -80),
		offsets = offsets
	})
end

local LocalPlayer = Players.LocalPlayer
local random = Random.new()

local function makeSound(name, p) -- 2 equivalent calls inferred from this helper
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. p
	sound.Looped = true
	sound.Volume = 0
	return sound
end

local sound = makeSound("AmbienIndoor", 9112874053) -- inferred equivalent call
sound.Parent = SoundService

local function muffle(sound2) -- 1 equivalent call inferred from this helper
	local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
	equalizerSoundEffect.LowGain = 0
	equalizerSoundEffect.MidGain = -5
	equalizerSoundEffect.HighGain = -18
	equalizerSoundEffect.Parent = sound2
end

local v3 = {}

for i, v4 in ipairs({ 140698715847574, 139202211032348, 137320570572871 }) do
	local attachment = Instance.new("Attachment")
	attachment.Name = "AmbienKonstruksiEmitter" .. i
	attachment.Parent = workspace.Terrain
	local sound2 = makeSound("SfxKonstruksi" .. i, v4) -- inferred equivalent call
	sound2.Looped = false
	sound2:SetAttribute("AlwaysSpatial3D", true)
	sound2.RollOffMode = Enum.RollOffMode.InverseTapered
	sound2.RollOffMaxDistance = 700
	sound2.EmitterSize = 150
	muffle(sound2) -- inferred equivalent call
	sound2.Parent = attachment
	table.insert(v3, { sound = sound2, att = attachment })
end

task.spawn(function()
	local sounds = { sound }

	for _, v4 in ipairs(v3) do
		table.insert(sounds, v4.sound)
	end

	pcall(function()
		ContentProvider:PreloadAsync(sounds)
	end)

	for _, v4 in ipairs(sounds) do
		if v4.TimeLength == 0 then
			warn("[GameAmbience] audio " .. v4.Name .. " tidak termuat (mungkin privat / tidak boleh dipakai di game ini)")
		end
	end
end)

sound:Play()
TweenService:Create(sound, TweenInfo.new(2.5, Enum.EasingStyle.Sine), { Volume = 0.22 }):Play()

local function playerPosition() -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return humanoidRootPart.Position
	end

	local currentCamera = workspace.CurrentCamera
	return currentCamera and currentCamera.CFrame.Position or Vector3.new(0, 0, 0)
end

local function nearestArea(p)
	local v4 = v[1]
	local v5 = 1e999

	for _, v6 in ipairs(v) do
		local magnitude = (Vector3.new(v6.center.X, 0, v6.center.Z) - Vector3.new(p.X, 0, p.Z)).Magnitude

		if not (magnitude < v5) then
			continue
		end

		v4 = v6
		v5 = magnitude
	end

	return v4
end

local function playFaded(sound2, volume)
	local v4 = sound2.TimeLength / sound2.PlaybackSpeed
	local v5 = math.min(0.8, v4 * 0.25)
	local v6 = math.min(2.5, v4 * 0.45)
	sound2.Volume = 0
	sound2:Play()
	TweenService:Create(sound2, TweenInfo.new(v5, Enum.EasingStyle.Sine), { Volume = volume }):Play()
	task.delay(math.max(v4 - v6, v5), function()
		TweenService:Create(sound2, TweenInfo.new(v6, Enum.EasingStyle.Sine), { Volume = 0 }):Play()
	end)
end

task.wait(random:NextNumber(5, 15))

while true do
	task.wait(random:NextNumber(v2[1], v2[2]))
	local integer = random:NextInteger(1, #v3)
	local v4 = v3[integer]

	if not (v4.sound.TimeLength > 0) or v4.sound.IsPlaying then
		continue
	end

	local v5 = nearestArea(playerPosition()) -- inferred equivalent call
	v4.att.WorldPosition = v5.center + v5.offsets[integer]
	v4.sound.PlaybackSpeed = random:NextNumber(0.95, 1.05)
	playFaded(v4.sound, 0.13 * random:NextNumber(0.7, 1))
end