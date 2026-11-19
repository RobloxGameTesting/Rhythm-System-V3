local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local FreePlayVibrato = require(script.Parent:WaitForChild("FreePlayVibrato"))

local object = setmetatable({}, { __mode = "k" })

local function safeTween(instance, tweenInfo, goal) -- 5 equivalent calls inferred from this helper
	if instance and instance.Parent then
		TweenService:Create(instance, tweenInfo, goal):Play()
	end
end

local function destroyAll(state)
	state.Dead = true

	for _, member in ipairs(state.Members) do
		pcall(function()
			member:Stop()
		end)
		member:Destroy()
	end

	table.clear(state.Members)
	local onFinished = state.OnFinished
	state.OnFinished = nil

	if onFinished then
		onFinished()
	end
end

local FreePlaySustainExtender = {}

function FreePlaySustainExtender.Start(instance, value, onFinished, value2)
	local v = {
		Members = { instance },
		Dead = false,
		OnFinished = onFinished
	}
	object[instance] = v

	task.delay(60, function()
		if not v.Dead then
			destroyAll(v)
		end
	end)

	task.spawn(function()
		local total = 0

		while not instance.IsLoaded and total < 2 and instance.Parent do
			total += task.wait()
		end

		if v.Dead then
			return
		end

		local timeLength = instance.TimeLength
		local v2 = math.max(FreePlayVibrato.GetBaseSpeed(instance), 0.05)
		local v3 = value or 0
		local v4 = timeLength - v3
		local v5 = v4 / v2

		if timeLength <= 0 or v5 < 2 then
			instance.Ended:Once(function()
				destroyAll(v)
			end)
			return
		end

		local timePosition = v3 + v4 * 0.45
		local v6 = (timeLength - timePosition) / v2
		local v7 = math.min(0.7, v6 * 0.4)
		local v8 = v6 - v7
		local v9 = v5 * (value2 or 3) - 1.5

		local tweenInfo = TweenInfo.new(v7, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local tweenInfo2 = TweenInfo.new(v7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		local lastTime = os.clock()
		local v10 = v5 - v7
		local v11 = instance

		while v10 < v9 do
			local v12 = v10 - (os.clock() - lastTime)

			if v12 > 0 then
				task.wait(v12)
			end

			if v.Dead or not instance.Parent then
				return
			end

			local volume = v11.Volume * 0.85
			local sound = Instance.new("Sound")
			sound.Name = instance.Name
			sound.SoundId = instance.SoundId
			sound.PlaybackSpeed = FreePlayVibrato.GetBaseSpeed(instance)
			sound.TimePosition = timePosition
			sound.Volume = 0
			sound.SoundGroup = instance.SoundGroup

			for k, v13 in pairs(instance:GetAttributes()) do
				sound:SetAttribute(k, v13)
			end

			sound.Parent = instance.Parent
			FreePlayVibrato.RegisterLike(sound, instance)
			sound:Play()
			Debris:AddItem(sound, 60)
			table.insert(v.Members, sound)

			safeTween(sound, tweenInfo2, { Volume = volume }) -- inferred equivalent call
			safeTween(v11, tweenInfo, { Volume = 0 }) -- inferred equivalent call
			local v13 = v11
			task.delay(v7 + 0.05, function()
				pcall(function()
					v13:Stop()
				end)

				if v13 ~= instance then
					local index = table.find(v.Members, v13)

					if index then
						table.remove(v.Members, index)
					end

					v13:Destroy()
				end
			end)

			v10 += v8
			v11 = sound
		end

		local v12 = v9 - (os.clock() - lastTime)

		if v12 > 0 then
			task.wait(v12)
		end

		if v.Dead then
			return
		end

		for _, member in ipairs(v.Members) do
			safeTween(member, TweenInfo.new(1.5, Enum.EasingStyle.Linear), { Volume = 0 }) -- inferred equivalent call
		end

		task.wait(1.6)
		destroyAll(v)
	end)
end

function FreePlaySustainExtender.Release(p, duration, p2, p3): boolean
	local v = object[p]

	if not v then
		return false
	end

	if v.Dead then
		return true
	end

	v.Dead = true
	local tweenInfo = TweenInfo.new(duration, p2 or Enum.EasingStyle.Linear, p3 or Enum.EasingDirection.Out)

	for _, member in ipairs(v.Members) do
		safeTween(member, tweenInfo, { Volume = 0 }) -- inferred equivalent call
	end

	task.delay(duration + 0.05, function()
		destroyAll(v)
	end)
	return true
end

function FreePlaySustainExtender.Demote(p, volume, duration): boolean
	local v = object[p]

	if not v then
		return false
	end

	if v.Dead then
		return true
	end

	safeTween(v.Members[#v.Members], TweenInfo.new(duration, Enum.EasingStyle.Linear), { -- inferred equivalent call
		Volume = volume
	})
	return true
end

return FreePlaySustainExtender