local v = {
	Left = { Hover = "rbxassetid://128282907928551", Pressed = "rbxassetid://83353960618775" },
	Right = { Hover = "rbxassetid://123584453393161", Pressed = "rbxassetid://93049335489673" }
}

local Action2 = Enum.AnimationPriority.Action2

local v2 = nil
local function loadV2() -- 4 equivalent calls inferred from this helper
	if v2 == nil then
		local success, pianoHandAnimatorV2 = pcall(require, script.Parent.PianoHandAnimatorV2)
		v2 = success and pianoHandAnimatorV2 or false
	end

	return v2
end

local function seedMode() -- 6 equivalent calls inferred from this helper
	local v3 = loadV2() -- inferred equivalent call
	return v3 and v3.Enabled == true and true or false
end

local function forwardToV2(p, p2, p3) -- 2 equivalent calls inferred from this helper
	local v3 = loadV2() -- inferred equivalent call

	if v3 and v3[p] then
		v3[p](p2, p3)
	end
end

local v3 = { "Left", "Right" }

local v4 = {}
local v5 = {}

local function switchPose(state, currentPose) -- 2 equivalent calls inferred from this helper
	if state.CurrentPose == currentPose then
		return
	end

	local track = state.Tracks[currentPose]

	if not track then
		return
	end

	local currentPose2 = state.CurrentPose
	local v6 = currentPose2 and state.Tracks[currentPose2]
	state.CurrentPose = currentPose

	track:Play(0.08, 10, 1)

	if v6 then
		v6:Stop(0.08)
	end
end

local function loadSideTracks(animator, items)
	local sideTracks = {}

	for k, item in pairs(items) do
		if item == "" then
			continue
		end

		local v6 = loadV2() -- inferred equivalent call

		if not (not v6 or v6.Enabled ~= true or k == "Hover") then
			continue
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = item
		local success, result = pcall(function()
			return animator:LoadAnimation(animation)
		end)

		if success and result then
			result.Priority = seedMode() and Action2 or Enum.AnimationPriority.Core -- inferred equivalent call
			result.Looped = true
			sideTracks[k] = result
		else
			warn("[PianoArmPoseAnimator] Gagal load pose '" .. k .. "': " .. tostring(result))
		end
	end

	return sideTracks
end

local PianoArmPoseAnimator = {
	Setup = function(instance)
		if not instance or v4[instance] then
			return
		end

		if seedMode() then -- inferred equivalent call
			local v6 = loadV2() -- inferred equivalent call
			local v7 = v6 and v6.GetState and v6.GetState(instance)

			if not v7 or v7.Phase ~= "Ready" then
				return
			end
		end

		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if not animator then
			return
		end

		local v6 = {}
		local v7 = {}

		for _, v8 in ipairs(v3) do
			local tracks = loadSideTracks(animator, v[v8])

			if not tracks.Hover then
				continue
			end

			if seedMode() then -- inferred equivalent call
				v6[v8] = { Tracks = tracks, CurrentPose = "Hover", SeedPending = true }
			else
				tracks.Hover:Play(0.3, 10, 1)
				v6[v8] = { Tracks = tracks, CurrentPose = "Hover" }
			end

			v7[v8] = 0
		end

		if not next(v6) then
			return
		end

		v4[instance] = v6
		v5[instance] = v7

		for _, v8 in ipairs(v3) do
			local v9 = v6[v8]

			if not (v9 and v9.SeedPending) then
				continue
			end

			local hover = v9.Tracks.Hover
			task.spawn(function()
				local total = 0

				while hover.Length <= 0 and total < 8 do
					task.wait(0.05)
					total += 0.05
				end

				if v4[instance] ~= v6 then
					return
				end

				v9.SeedPending = false
				hover:Play(0.3, 1, 1)
			end)
		end
	end,
	IsSeedReady = function(p): boolean
		local v6 = p and v4[p]

		if not v6 then
			return false
		end

		local count = 0

		for _, v7 in pairs(v6) do
			for _, track in pairs(v7.Tracks) do
				count += 1

				if v7.SeedPending or track.Length <= 0 or not track.IsPlaying or track.WeightCurrent < 0.98 then
					return false
				end
			end
		end

		return count > 0
	end,
	NotePressed = function(p, p2)
		if seedMode() then -- inferred equivalent call
			forwardToV2("NotePressed", p, p2) -- inferred equivalent call
		else
			local v6 = p and v4[p]
			local v7 = v6 and v6[p2]

			if not v7 then
				return
			end

			local v8 = v5[p]
			v8[p2] = (v8[p2] or 0) + 1

			if v8[p2] == 1 then
				switchPose(v7, "Pressed") -- inferred equivalent call
			end
		end
	end,
	NoteReleased = function(p, p2)
		if seedMode() then -- inferred equivalent call
			forwardToV2("NoteReleased", p, p2) -- inferred equivalent call
		else
			local v6 = p and v4[p]
			local v7 = v6 and v6[p2]

			if not v7 then
				return
			end

			local v8 = v5[p]
			v8[p2] = math.max(0, (v8[p2] or 0) - 1)

			if v8[p2] == 0 then
				switchPose(v7, "Hover") -- inferred equivalent call
			end
		end
	end,
	Cleanup = function(p)
		local v6 = p and v4[p]

		if not v6 then
			return
		end

		v4[p] = nil
		v5[p] = nil
		local v7 = seedMode() and 0.5 or 0.3 -- inferred equivalent call

		for _, v8 in pairs(v6) do
			for _, track in pairs(v8.Tracks) do
				track:Stop(v7)
				local v9 = track
				task.delay(v7 + 0.1, function()
					v9:Destroy()
				end)
			end
		end
	end
}

local RunService = game:GetService("RunService")

if RunService:IsClient() then
	task.spawn(function()
		local v6 = {}

		for _, v7 in ipairs(v3) do
			local hover = v[v7] and v[v7].Hover

			if not (hover and hover ~= "") then
				continue
			end

			local animation = Instance.new("Animation")
			animation.AnimationId = hover
			table.insert(v6, animation)
		end

		pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync(v6)
		end)
	end)
end

return PianoArmPoseAnimator