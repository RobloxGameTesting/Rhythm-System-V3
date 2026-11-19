local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StickClickNoteDisplay = require(ReplicatedStorage.Modules.StickClickNoteDisplay)
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local ChartLoader = require(ReplicatedStorage.Modules.ChartLoader)
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)

local success, result = pcall(function()
	return require(ReplicatedStorage.Modules.DrumStrokeSolver)
end)

if not success then
	warn("[DrumAnimator] DrumStrokeSolver gagal dimuat, memakai klip lama:", result)
	result = {
		IsProceduralType = function(): boolean
			return false
		end,
		Stroke = function(): boolean
			return false
		end,
		Grab = function(): boolean
			return false
		end,
		Release = function() end,
		Cleanup = function() end,
		BodyHit = function() end,
		Watch = function() end
	}
end

local DrumAnimator = {}

local v = { Perfect = 1, Great = 0.7, Good = 0.4, OK = 0.2 }

local v2 = { Perfect = 1, Great = 0.65, Good = 0.35, OK = 0.15 }

local v3 = {
	Kick = 0.3,
	Snare = 0.05,
	HiHat = 0,
	HiTom = 0.1,
	MidTom = 0.15,
	FloorTom = 0.2,
	Crash = 0.25,
	Ride = 0
}

local v4 = {
	Snare = {
		Hand = "Left",
		AnimationIds = {
			Left = "rbxassetid://92773856002824",
			Right = "rbxassetid://99209704777118"
		}
	},
	HiHat = {
		Hand = "Left",
		AnimationIds = {
			Left = "rbxassetid://89962030255448",
			Right = "rbxassetid://74114096306364"
		}
	},
	HiTom = {
		Hand = "Auto",
		AnimationIds = {
			Left = "rbxassetid://73139730975118",
			Right = "rbxassetid://93421844178756"
		}
	},
	MidTom = {
		Hand = "Right",
		AnimationIds = {
			Left = "rbxassetid://102847763685640",
			Right = "rbxassetid://137996029369408"
		}
	},
	FloorTom = {
		Hand = "Right",
		AnimationIds = {
			Left = "rbxassetid://86821900444639",
			Right = "rbxassetid://111271704470798"
		}
	},
	Crash = {
		Hand = "Left",
		AnimationIds = {
			Left = "rbxassetid://85189464902211",
			Right = "rbxassetid://72241499283270"
		}
	},
	Ride = {
		Hand = "Right",
		AnimationIds = {
			Left = "rbxassetid://121468212356255",
			Right = "rbxassetid://75845873827340"
		}
	}
}

local function resolveInstrumentStand(instance)
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
	local v5 = humanoid and humanoid.SeatPart

	if not v5 then
		return nil
	end

	while v5 do
		if CollectionService:HasTag(v5, "InstrumentStand") then
			return v5
		end

		v5 = v5.Parent
	end

	return nil
end

local function resolveDisplayModelFromStand(p)
	local parent = p and p.Parent

	while parent do
		local displayModel = parent:FindFirstChild("DisplayModel")

		if displayModel then
			return displayModel
		end

		parent = parent.Parent
	end

	return nil
end

function DrumAnimator.ResolveInstrumentInstance(player)
	local character = player and player.Character
	local instrumentStand = resolveInstrumentStand(character)

	if not instrumentStand then
		return nil
	end

	local parent = instrumentStand and instrumentStand.Parent

	while parent do
		local displayModel = parent:FindFirstChild("DisplayModel")

		if displayModel then
			return displayModel
		end

		parent = parent.Parent
	end

	return nil
end

local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}

local v12 = {}
local v13 = {}

local v14 = {}

local v15 = {
	Ride = { Left = 0.16, Right = 0.067 },
	HiHat = { Left = 0.067, Right = 0.05 },
	Crash = { Left = 0.05, Right = 0.05 },
	Snare = { Left = 0.044, Right = 0.05 },
	HiTom = { Left = 0.05, Right = 0.05 },
	MidTom = { Left = 0.05, Right = 0.08 },
	FloorTom = { Left = 0.05, Right = 0.05 }
}

local nowsByCharacter = {}

local v16 = {}
local v17 = {}
local v18 = {}
local v19 = {}
local v20 = nil
local function isLocalFreePlayMode()
	if v20 == nil then
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local modeManager = modules and modules:FindFirstChild("ModeManager")

		if not modeManager then
			return false
		end

		local success2, result2 = pcall(require, modeManager)
		v20 = success2 and result2 or false
	end

	if not v20 then
		return false
	end

	local success2, result2 = pcall(v20.IsFreePlay)
	return success2 and result2 == true
end

local function isFreePlayVisualMode(p) -- 16 equivalent calls inferred from this helper
	if p == nil then
		return false
	end

	if v16[p] then
		return true
	end

	return p == LocalPlayer.Character and isLocalFreePlayMode()
end

local v21 = nil
local function isReducedChartMode()
	if v21 == nil then
		local success2, result2 = pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			return require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("NewbieModeState", 5))
		end)

		v21 = success2 and result2 or false
	end

	if not v21 then
		return false
	end

	local success2, result2 = pcall(v21.IsEnabled)
	return success2 and result2 == true
end

local function buildAvatarAnimationTracks(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	local result2 = {}

	for k, v22 in pairs(v4) do
		local tracks = {}

		for _, v23 in ipairs({ "Left", "Right" }) do
			local animation = Instance.new("Animation")
			animation.AnimationId = v22.AnimationIds[v23]
			local track = animator:LoadAnimation(animation)
			track.Looped = false
			tracks[v23] = track
		end

		result2[k] = tracks
	end

	return result2
end

local function getAvatarAnimationTracks(p)
	local v22 = v5[p]

	if v22 then
		return v22
	end

	local avatarAnimationTracks = buildAvatarAnimationTracks(p)

	if not avatarAnimationTracks then
		return nil
	end

	v5[p] = avatarAnimationTracks
	v6[p] = { Left = -1000000000, Right = -1000000000 }
	v7[p] = { Left = 0, Right = 0 }
	v9[p] = {}
	v8[p] = nil
	return avatarAnimationTracks
end

local function releaseCharacterCache(character) -- 1 equivalent call inferred from this helper
	v5[character] = nil
	result.Cleanup(character)
	v6[character] = nil
	v7[character] = nil
	v8[character] = nil
	v9[character] = nil
	v10[character] = nil
	v11[character] = nil
	v12[character] = nil
	v16[character] = nil
	v17[character] = nil
	v18[character] = nil
	v19[character] = nil
	v13[character] = nil
end

local function hookCharacterCleanup(p) -- 1 equivalent call inferred from this helper
	p.CharacterRemoving:Connect(function(character)
		v5[character] = nil
		result.Cleanup(character)
		v6[character] = nil
		v7[character] = nil
		v8[character] = nil
		v9[character] = nil
		v10[character] = nil
		v11[character] = nil
		v12[character] = nil
		v16[character] = nil
		v17[character] = nil
		v18[character] = nil
		v19[character] = nil
		v13[character] = nil
	end)
end

local v22 = {
	HiHat = -2.97,
	Crash = -2.26,
	Snare = -2.09,
	HiTom = -0.86,
	MidTom = 1.57,
	FloorTom = 2.57,
	Ride = 3
}
local v23 = { HiHat = "Left", Ride = "Right" }

local v24 = { Crash = true }

for _, v25 in ipairs(Players:GetPlayers()) do
	hookCharacterCleanup(v25) -- inferred equivalent call
end

Players.PlayerAdded:Connect(hookCharacterCleanup)
Players.PlayerRemoving:Connect(function(player)
	if player.Character then
		releaseCharacterCache(player.Character) -- inferred equivalent call
	end
end)

local v25 = {}

local function scanKitPositions(folder)
	local v26 = {}
	local v27 = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local reactionType = part:GetAttribute("ReactionType")

		if not reactionType then
			continue
		end

		local parent = part.Parent
		local v28 = false

		while parent and parent ~= folder do
			if parent.Name == "Stand" then
				v28 = true
				break
			end

			parent = parent.Parent
		end

		if v28 then
			continue
		end

		v26[reactionType] = (v26[reactionType] or Vector3.new(0, 0, 0)) + part.Position
		v27[reactionType] = (v27[reactionType] or 0) + 1
	end

	local result2 = {}

	for k, v28 in pairs(v26) do
		result2[k] = v28 / v27[k]
	end

	return result2
end

local function getKitContext(instance)
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart
	local v26 = seatPart and resolveInstrumentStand(instance)
	local v27

	if v26 then
		if v26 then
			v26 = v26.Parent
		end

		while true do
			if not v26 then
				v27 = nil
				break
			end

			v27 = v26:FindFirstChild("DisplayModel")

			if v27 then
				break
			end

			v26 = v26.Parent
		end
	else
		v27 = v26
	end

	if not v27 then
		return nil, nil
	end

	local v28 = v25[v27]

	if not v28 then
		v28 = scanKitPositions(v27)
		v25[v27] = v28
		v27.Destroying:Connect(function()
			v25[v27] = nil
		end)
	end

	return seatPart, v28
end

local function getReactionLateral(instance, p)
	local v26 = v22[p]
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart
	local v27 = seatPart and resolveInstrumentStand(instance)
	local v28

	if v27 then
		if v27 then
			v27 = v27.Parent
		end

		while true do
			if not v27 then
				v28 = nil
				break
			end

			v28 = v27:FindFirstChild("DisplayModel")

			if v28 then
				break
			end

			v27 = v27.Parent
		end
	else
		v28 = v27
	end

	if not v28 then
		return v26
	end

	local v29 = v25[v28]

	if not v29 then
		v29 = scanKitPositions(v28)
		v25[v28] = v29
		v28.Destroying:Connect(function()
			v25[v28] = nil
		end)
	end

	local v30 = v29[p]

	if v30 then
		return seatPart.CFrame:PointToObjectSpace(v30).X
	end

	return v26
end

local function oppositeHand(p): string -- 4 equivalent calls inferred from this helper
	return if p == "Left" then "Right" else "Left"
end

local function evaluateStream(p, p2): string
	if not p then
		return "Normal"
	end

	local v26 = p2 - p.Time

	if p.Mode == "VeryFast" then
		if v26 < 0.16 then
			return "VeryFast"
		end
	elseif v26 < 0.13 then
		return "VeryFast"
	end

	return if v26 < 0.3 then "Fast" else "Normal"
end

local function handPenalty(p, p2, p3, p4, p5, reactionLateral)
	local total = 0

	local v26 = v6[p]

	if v26 and p4 - v26[p2] < 0.15 then
		total += 2
	end

	local v27 = v7[p]

	if reactionLateral and v26 and v27 then
		if p2 == "Left" and p4 - v26.Right < 0.35 and v27.Right + 0.3 < reactionLateral then
			total += 3
		elseif p2 == "Right" and p4 - v26.Left < 0.35 and reactionLateral < v27.Left - 0.3 then
			total += 3
		end
	end

	if p5 then
		return total
	end

	local v28 = v9[p]

	if not v28 then
		return total
	end

	for k, v29 in pairs(v23) do
		if not (v29 == p2 and k ~= p3) then
			continue
		end

		local v30 = v28[k]

		if v30 and p4 - v30.Time < 1 then
			total += 1
			break
		end
	end

	for k in pairs(v24) do
		local v29 = v28[k]

		if k ~= p3 and v29 and (v29.LeadHand or v29.Hand) == p2 and (v29.Streak or 1) >= 2 and p4 - v29.Time < 0.7 then
			return total + 1.5
		end
	end

	return total
end

local function decideSingleHand(p, p2, p3, p4)
	local v26 = v9[p]
	local v27 = v26 and v26[p2]
	local v28 = v23[p2]

	if v28 then
		local v29

		if v27 then
			local v30 = p4 - v27.Time

			if v27.Mode == "VeryFast" then
				if v30 < 0.16 then
					v29 = "VeryFast"
				else
					v29 = v30 < 0.3 and "Fast" or "Normal"
				end
			elseif v30 < 0.13 then
				v29 = "VeryFast"
			else
				v29 = v30 < 0.3 and "Fast" or "Normal"
			end
		else
			v29 = "Normal"
		end

		if v29 == "Fast" then
			return v28
		elseif v29 == "VeryFast" then
			return v27 and (oppositeHand(v27.Hand) or v28) or v28 -- inferred equivalent call
		end
	end

	if v24[p2] and v27 and (v27.Streak or 1) >= 1 then
		local v29 = p4 - v27.Time

		if v29 < 0.55 and v29 >= 0.05 then
			return v27.LeadHand or v27.Hand
		end
	end

	local v29 = p3.Hand
	local v30

	if v28 or not (v27 and p4 - v27.Time <= 0.25) then
		v30 = false
	else
		v29 = oppositeHand(v27.Hand) -- inferred equivalent call
		v30 = p4 - v27.Time < 0.14
	end

	local reactionLateral = getReactionLateral(p, p2)
	local v31 = handPenalty(p, "Left", p2, p4, v30, reactionLateral)
	local v32 = handPenalty(p, "Right", p2, p4, v30, reactionLateral)

	if v29 == "Left" or v29 == "Right" then
		local v33 = v29 == "Left" and v31 or v32

		if (v29 == "Left" and v32 or v31) < v33 then
			return oppositeHand(v29) -- inferred equivalent call
		end

		return v29
	elseif v31 == v32 then
		local v33 = v6[p]

		if v33 and not (v33.Left <= v33.Right) then
			return "Right"
		end

		return "Left"
	else
		return if v31 < v32 then "Left" else "Right"
	end
end

local function decideChordHands(p, list, time)
	local set = {}
	local v26 = {}

	for _, item in ipairs(list) do
		if not v4[item] or set[item] then
			continue
		end

		set[item] = true
		table.insert(v26, item)
	end

	table.sort(v26)
	local joined = table.concat(v26, "+")

	local v27 = v8[p]

	if v27 and v27.Key == joined and time - v27.Time <= 0.06 then
		return v27.Hands
	end

	local v28 = v9[p]
	local result2 = {}
	local set2 = {}
	local v29 = {}

	for _, v30 in ipairs(v26) do
		local v31 = v23[v30]
		local v32 = nil

		if v31 then
			local v33 = v28 and v28[v30]
			local v34

			if v33 then
				local v35 = time - v33.Time

				if v33.Mode == "VeryFast" then
					if v35 < 0.16 then
						v34 = "VeryFast"
					else
						v34 = v35 < 0.3 and "Fast" or "Normal"
					end
				elseif v35 < 0.13 then
					v34 = "VeryFast"
				else
					v34 = v35 < 0.3 and "Fast" or "Normal"
				end
			else
				v34 = "Normal"
			end

			if v34 == "Fast" then
				v32 = v31
			elseif v34 == "VeryFast" then
				v32 = v33 and (oppositeHand(v33.Hand) or v31) or v31 -- inferred equivalent call
			end
		end

		if v32 then
			result2[v30] = v32
			set2[v32] = true
		else
			table.insert(v29, v30)
		end
	end

	if #v29 == 1 and not (set2.Left or set2.Right) then
		result2[v29[1]] = decideSingleHand(p, v29[1], v4[v29[1]], time)
	elseif #v29 >= 1 then
		local v30 = {}

		if not set2.Left then
			table.insert(v30, "Left")
		end

		if not set2.Right then
			table.insert(v30, "Right")
		end

		if #v30 == 2 then
			local v31 = {}

			for _, v32 in ipairs(v29) do
				v31[v32] = getReactionLateral(p, v32) or 0
			end

			table.sort(v29, function(a, b): boolean
				return v31[a] < v31[b]
			end)

			local v32 = v31[v29[1]]
			local v33 = v31[v29[#v29]]

			for i, v34 in ipairs(v29) do
				if i == 1 then
					result2[v34] = "Left"
				elseif i == #v29 then
					result2[v34] = "Right"
				else
					result2[v34] = v31[v34] - v32 <= v33 - v31[v34] and "Left" or "Right"
				end
			end
		elseif #v30 == 1 then
			for _, v31 in ipairs(v29) do
				result2[v31] = v30[1]
			end
		else
			for _, v31 in ipairs(v29) do
				result2[v31] = (getReactionLateral(p, v31) or 0) <= 0 and "Left" or "Right"
			end
		end
	end

	v8[p] = { Key = joined, Time = time, Hands = result2 }
	return result2
end

local function leftForbidden(p, p2) -- 2 equivalent calls inferred from this helper
	local success2, tune = pcall(result.GetTune, p)

	if success2 then
		if type(tune) == "table" then
			success2 = (tune["NoLeft_" .. p2] or 0) ~= 0
		else
			success2 = false
		end
	end

	return success2
end

local function decideHand(p, p2, p3, now, list)
	local v26

	if list and #list > 1 then
		v26 = decideChordHands(p, list, now)[p2]
	end

	local v27 = v26 or decideSingleHand(p, p2, p3, now)

	if v27 ~= "Left" then
		return v27
	end

	if leftForbidden(p, p2) then -- inferred equivalent call
		return "Right"
	end

	return v27
end

function DrumAnimator.ResolveHandForReaction(p, p2, p3)
	local v26 = v4[p2]

	if not v26 then
		return nil
	end

	if getAvatarAnimationTracks(p) then
		return decideHand(p, p2, v26, os.clock(), p3)
	end

	return nil
end

local function handleAvatarAnimation(p, p2, hand, value)
	local v26 = v4[p2]

	if not v26 then
		warn(("[DrumAnimator] Missing ReactionProfile for ReactionType '%s'. Avatar Animation skipped. Add an entry to ReactionProfile."):format((tostring(p2))))
		return
	end

	local avatarAnimationTracks = getAvatarAnimationTracks(p)

	if not avatarAnimationTracks then
		return
	end

	local avatarAnimationTrack = avatarAnimationTracks[p2]

	if not avatarAnimationTrack then
		return
	end

	local now = os.clock()

	if hand ~= "Left" and hand ~= "Right" then
		hand = nil or decideSingleHand(p, p2, v26, now)

		if hand == "Left" then
			hand = leftForbidden(p, p2) and "Right" or hand -- inferred equivalent call
		end
	end

	local v27 = avatarAnimationTrack[hand]

	if not v27 then
		return
	end

	if (p2 == "HiHat" or p2 == "Snare") and p == Players.LocalPlayer.Character then
		SessionCameraSettings.RequestDrumGlance(p2, value or 0)
	end

	local kitContext, v28 = getKitContext(p)
	local v29

	if result.IsProceduralType(p2) then
		v29 = result.Stroke(p, hand, p2, kitContext, v28, value)
	else
		v29 = false
	end

	if not v29 then
		local v30 = v15[p2]
		local v31 = v30 and v30[hand] or 0.05
		local v32 = value and value - v31 or 0

		local function startClip() -- 1 equivalent call inferred from this helper
			result.Release(p, hand)

			v27:Play()
		end

		if not (v32 < -0.1) then
			if v32 > 0.004 then
				task.delay(v32, function()
					if p.Parent then
						pcall(startClip)
					end
				end)
			else
				startClip() -- inferred equivalent call
			end
		end

		result.Watch(p, hand, kitContext, math.max(v32, 0) + 0.8, p2)

		result.BodyHit(p, p2, hand, value, kitContext, v28, true)
	end

	local nows = v6[p]

	if nows then
		nows[hand] = now
	end

	local v30 = v7[p]

	if v30 then
		v30[hand] = getReactionLateral(p, p2) or v30[hand]
	end

	local v31 = v9[p]

	if v31 then
		local v32 = {
			Time = now,
			Hand = hand,
			Mode = 0,
			LeadHand = 0,
			Streak = 0
		}

		local v33 = v31[p2]
		local mode

		if v33 then
			local v35 = now - v33.Time

			if v33.Mode == "VeryFast" then
				if v35 < 0.16 then
					mode = "VeryFast"
				else
					mode = v35 < 0.3 and "Fast" or "Normal"
				end
			elseif v35 < 0.13 then
				mode = "VeryFast"
			else
				mode = v35 < 0.3 and "Fast" or "Normal"
			end
		else
			mode = "Normal"
		end

		v32.Mode = mode
		v32.LeadHand = v31[p2] and now - v31[p2].Time < 0.05 and (v31[p2].LeadHand or v31[p2].Hand) or hand
		v32.Streak = v31[p2] and now - v31[p2].Time < 0.55 and (v31[p2].Streak or 1) + 1 or 1
		v31[p2] = v32
	end
end

function DrumAnimator.PreviewHit(p, p2, p3, value)
	if p ~= Players.LocalPlayer.Character then
		return
	end

	handleAvatarAnimation(p, p2, p3, value or 0.25)
end

local v26 = {}

local function scanReactionComponents(folder)
	local result2 = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local reactionType = part:GetAttribute("ReactionType")

		if not reactionType then
			continue
		end

		if not result2[reactionType] then
			result2[reactionType] = {}
		end

		table.insert(result2[reactionType], part)
	end

	return result2
end

local function buildReactionState(item)
	local cframe = item.CFrame

	local pushedPoses = {}

	for k, v27 in pairs(v) do
		pushedPoses[k] = cframe * CFrame.new(Vector3.new(0, 0, 0.08) * v27)
	end

	return {
		Part = item,
		InitialPose = cframe,
		PushedPoses = pushedPoses,
		ActiveTween = nil,
		PendingConnection = nil
	}
end

local function buildInstrumentReactionEntry(instance)
	local v27 = scanReactionComponents(instance)

	local reactions = {}

	for k, list in pairs(v27) do
		local v28 = table.create(#list)

		for i, item in ipairs(list) do
			v28[i] = buildReactionState(item)
		end

		reactions[k] = v28
	end

	return { Reactions = reactions }
end

local function getInstrumentReactionEntry(instance)
	local v27 = v26[instance]

	if v27 then
		return v27
	end

	local instrumentReactionEntry = buildInstrumentReactionEntry(instance)
	v26[instance] = instrumentReactionEntry

	instance.Destroying:Connect(function()
		v26[instance] = nil
	end)

	return instrumentReactionEntry
end

local function playReactionState(state, p)
	local pushedPos = state.PushedPoses[p]

	if not pushedPos then
		return
	end

	if state.PendingConnection then
		state.PendingConnection:Disconnect()
		state.PendingConnection = nil
	end

	if state.ActiveTween then
		state.ActiveTween:Cancel()
		state.ActiveTween = nil
	end

	local tween = TweenService:Create(
		state.Part,
		TweenInfo.new(0.03, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ CFrame = pushedPos }
	)

	tween:Play()
	state.ActiveTween = tween
	state.PendingConnection = tween.Completed:Once(function(p2)
		if p2 ~= Enum.PlaybackState.Completed then
			return
		end

		local tween2 = TweenService:Create(
			state.Part,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = state.InitialPose }
		)

		tween2:Play()
		state.ActiveTween = tween2
	end)
end

local v27 = { Crash = true, Ride = true, HiHat = true }

local v28 = {
	Crash = {
		MaxTiltDegrees = 14,
		AmplitudeDecayPerSec = 1.9,
		FrequencyStartHz = 8,
		FrequencyEndHz = 2,
		FrequencyDecayPerSec = 1.4,
		PrecessionDegreesPerSec = 100
	},
	Ride = {
		MaxTiltDegrees = 4.5,
		AmplitudeDecayPerSec = 2.7,
		FrequencyStartHz = 7,
		FrequencyEndHz = 1.8,
		FrequencyDecayPerSec = 2,
		PrecessionDegreesPerSec = 75
	},
	HiHat = {
		MaxTiltDegrees = 5.2,
		AmplitudeDecayPerSec = 12,
		FrequencyStartHz = 10,
		FrequencyEndHz = 3,
		FrequencyDecayPerSec = 3,
		PrecessionDegreesPerSec = 55
	}
}

local v29 = {}
local heartbeatConnection = nil

local v30 = {}

local function updateCymbalWobbles(p)
	local now = os.clock()
	local v31 = false

	for k, v32 in pairs(v29) do
		if k.Parent then
			local v33 = now - v32.StartClock
			local config = v32.Config
			local v34

			if v32.ChokeAt then
				local v35 = math.clamp((now - v32.ChokeAt) / 0.32, 0, 1)
				v34 = (1 - v35 * v35 * (3 - v35 * 2)) ^ 1.6
			else
				v34 = 1
			end

			local v35 = v32.MaxTiltDegrees * math.exp(-config.AmplitudeDecayPerSec * v33) * v34

			if v35 < 0.3 then
				k.CFrame = v32.InitialPose
				v29[k] = nil
			else
				v31 = true

				local v36 = config.FrequencyEndHz + (config.FrequencyStartHz - config.FrequencyEndHz) * math.exp(-config.FrequencyDecayPerSec * v33)
				v32.Phase += v36 * p * 6.283185307179586

				local v37 = v35 * math.cos(v32.Phase)

				v32.PlaneAngle += math.rad(config.PrecessionDegreesPerSec) * p

				local v38 = math.cos(v32.PlaneAngle)
				local vector3 = Vector3.new(-math.sin(v32.PlaneAngle), 0, v38)
				local lastVerticalOffset

				if v32.HasVerticalBounce then
					v32.VerticalBouncePhase += config.VerticalBounceFrequencyHz * p * 6.283185307179586
					lastVerticalOffset = v32.VerticalBounceAmplitudeStuds * math.exp(-config.VerticalBounceDecayPerSec * v33) * math.cos(v32.VerticalBouncePhase) * v34
				else
					lastVerticalOffset = 0
				end

				if v32.CollisionPushLeaderPart then
					local v40 = v29[v32.CollisionPushLeaderPart]

					if v40 and v40.LastVerticalOffset < 0 then
						lastVerticalOffset += v40.LastVerticalOffset * v32.CollisionPushFactor
					end
				end

				v32.LastVerticalOffset = lastVerticalOffset

				k.CFrame = v32.InitialPose * CFrame.new(0, lastVerticalOffset, 0) * CFrame.fromAxisAngle(vector3, (math.rad(v37)))
			end
		else
			v29[k] = nil
		end
	end

	for k, v32 in pairs(v30) do
		if k.Parent then
			local v33 = v29[v32.LeaderPart]

			if v33 then
				k.CFrame = v32.InitialPose * CFrame.new(0, v33.LastVerticalOffset, 0)
			else
				k.CFrame = v32.InitialPose
				v30[k] = nil
			end
		else
			v30[k] = nil
		end
	end

	if not v31 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function triggerCymbalWobble(part, reactionType, p, part2, part3)
	local config = v28[reactionType]
	local v31 = v[p]

	if not (config and v31) then
		return
	end

	local v32 = v29[part]
	local initialPose = v32 and v32.InitialPose or part.CFrame

	if v32 then
		part.CFrame = initialPose
	end

	local hasVerticalBounce

	if config.VerticalBounceAmplitudeStuds == nil then
		hasVerticalBounce = false
	else
		hasVerticalBounce = string.find(string.lower(part.Name), "atas", 1, true) ~= nil
	end

	local v35

	if config.CollisionPushFactor == nil or part3 == nil then
		v35 = false
	else
		v35 = string.find(string.lower(part.Name), "bawah", 1, true) ~= nil
	end

	v29[part] = {
		ReactionType = reactionType,
		InitialPose = initialPose,
		Config = config,
		MaxTiltDegrees = config.MaxTiltDegrees * v31,
		StartClock = os.clock(),
		Phase = 0,
		PlaneAngle = 0,
		HasVerticalBounce = hasVerticalBounce,
		VerticalBouncePhase = 0,
		VerticalBounceAmplitudeStuds = hasVerticalBounce and config.VerticalBounceAmplitudeStuds * v31 or 0,
		LastVerticalOffset = 0,
		CollisionPushLeaderPart = v35 and part3 or nil,
		CollisionPushFactor = v35 and config.CollisionPushFactor or nil
	}

	if hasVerticalBounce and part2 then
		local v36 = v30[part2]
		local initialPose2 = v36 and v36.InitialPose or part2.CFrame

		if v36 then
			part2.CFrame = initialPose2
		end

		v30[part2] = { LeaderPart = part, InitialPose = initialPose2 }
	end

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(updateCymbalWobbles)
	end
end

local function isUnderStandFolder(p): boolean
	local parent = p.Parent

	while parent do
		if parent.Name == "Stand" then
			return true
		end

		parent = parent.Parent
	end

	return false
end

local v31 = {
	Crash = { AmplitudeStuds = 0.12, DecayPerSec = 12, FrequencyHz = 14 },
	Ride = { AmplitudeStuds = 0.08, DecayPerSec = 14, FrequencyHz = 14 },
	HiHat = { AmplitudeStuds = 0.055, DecayPerSec = 16, FrequencyHz = 16 }
}

local v32 = {}
local heartbeatConnection2 = nil

local function updateStandShakes(p)
	local now = os.clock()
	local v33 = false

	for k, v34 in pairs(v32) do
		local v35 = now - v34.StartClock
		local v36 = v34.AmplitudeStuds * math.exp(-v34.Config.DecayPerSec * v35)

		if v36 < 0.001 then
			for _, part in ipairs(v34.Parts) do
				if part.Part.Parent then
					part.Part.CFrame = part.InitialPose
				end
			end

			v32[k] = nil
		else
			v34.Phase += v34.Config.FrequencyHz * p * 6.283185307179586
			local v37 = v34.Direction * (v36 * math.cos(v34.Phase))
			v33 = true

			for _, part in ipairs(v34.Parts) do
				if part.Part.Parent then
					part.Part.CFrame = part.InitialPose + v37
				end
			end
		end
	end

	if not v33 and heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
		heartbeatConnection2 = nil
	end
end

local function triggerStandShake(reaction, p, p2)
	local config = v31[p]
	local v34 = v[p2]

	if not (config and v34) then
		return
	end

	local v35 = v32[reaction]
	local parts

	if v35 then
		parts = v35.Parts

		for _, v37 in ipairs(parts) do
			if v37.Part.Parent then
				v37.Part.CFrame = v37.InitialPose
			end
		end
	else
		parts = {}

		for _, item in ipairs(reaction) do
			local parent = item.Part.Parent
			local flag

			while true do
				if not parent then
					flag = false
					break
				end

				if parent.Name == "Stand" then
					flag = true
					break
				end

				parent = parent.Parent
			end

			if flag then
				table.insert(parts, { Part = item.Part, InitialPose = item.Part.CFrame })
			end
		end
	end

	if #parts == 0 then
		return
	end

	local v37 = math.random() * 2 * 3.141592653589793
	local vector3 = Vector3.new(math.cos(v37), 0, (math.sin(v37)))

	v32[reaction] = {
		Parts = parts,
		Config = config,
		AmplitudeStuds = config.AmplitudeStuds * v34,
		StartClock = os.clock(),
		Phase = 0,
		Direction = vector3
	}

	if not heartbeatConnection2 then
		heartbeatConnection2 = RunService.Heartbeat:Connect(updateStandShakes)
	end
end

local function handleInstrumentReaction(instance, reactionType, p)
	if not (p and v[p]) then
		return
	end

	local v33 = v26[instance]

	if not v33 then
		v33 = buildInstrumentReactionEntry(instance)
		v26[instance] = v33

		instance.Destroying:Connect(function()
			v26[instance] = nil
		end)
	end

	local reaction = v33.Reactions[reactionType]

	if not reaction then
		return
	end

	if v27[reactionType] then
		triggerStandShake(reaction, reactionType, p)
		local part = nil

		for _, v35 in ipairs(reaction) do
			local parent = v35.Part.Parent
			local v36

			while true do
				if not parent then
					v36 = false
					break
				end

				if parent.Name == "Stand" then
					v36 = true
					break
				end

				parent = parent.Parent
			end

			if v36 and string.find(string.lower(v35.Part.Name), "atas", 1, true) then
				part = v35.Part
				break
			end
		end

		local part2 = nil

		for _, v36 in ipairs(reaction) do
			local parent = v36.Part.Parent
			local v37

			while true do
				if not parent then
					v37 = false
					break
				end

				if parent.Name == "Stand" then
					v37 = true
					break
				end

				parent = parent.Parent
			end

			if not v37 and string.find(string.lower(v36.Part.Name), "atas", 1, true) then
				part2 = v36.Part
				break
			end
		end

		for _, v36 in ipairs(reaction) do
			local parent = v36.Part.Parent
			local v37

			while true do
				if not parent then
					v37 = false
					break
				end

				if parent.Name == "Stand" then
					v37 = true
					break
				end

				parent = parent.Parent
			end

			if not v37 then
				triggerCymbalWobble(v36.Part, reactionType, p, part, part2)
			end
		end
	else
		for _, v34 in ipairs(reaction) do
			playReactionState(v34, p)
		end
	end
end

local v33 = 0
local renderSteppedConnection = nil

local function updateCameraShake()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	local isFirstPerson = SessionCameraSettings.GetIsFirstPerson()

	if v33 <= 0.001 or not humanoid then
		if humanoid and not isFirstPerson then
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end

		SessionCameraSettings.SetDrumCameraShakeOffset(Vector3.new(0, 0, 0))

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		v33 = 0
	else
		local vector3 = Vector3.new((math.random() - 0.5) * v33, (math.random() - 0.5) * v33, 0)

		if not isFirstPerson then
			humanoid.CameraOffset = vector3
		end

		SessionCameraSettings.SetDrumCameraShakeOffset(vector3)

		v33 *= 0.85
	end
end

local function triggerCameraShake(p) -- 1 equivalent call inferred from this helper
	if not SettingsState.GetShakeEnabled() then
		return
	end

	v33 = math.max(v33, p)

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(updateCameraShake)
	end
end

local function pointInZone(instance, p): boolean -- 2 equivalent calls inferred from this helper
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(p)
	local v34 = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v34.X
		and math.abs(pointToObjectSpace.Y) <= v34.Y
		and math.abs(pointToObjectSpace.Z) <= v34.Z
end

local function findStageZoneContaining(p)
	local map = Workspace:FindFirstChild("Map")

	if not map then
		return nil
	end

	for _, child in ipairs(map:GetChildren()) do
		local stageZone = child:FindFirstChild("StageZone")

		if stageZone and stageZone:IsA("BasePart") and pointInZone(stageZone, p) then -- inferred equivalent call
			return stageZone
		end
	end

	return nil
end

local function isEligibleForCameraShake(position) -- 1 equivalent call inferred from this helper
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	local stageZoneContaining = findStageZoneContaining(position)

	if not stageZoneContaining then
		return (currentCamera.CFrame.Position - position).Magnitude <= 35
	end

	return pointInZone(stageZoneContaining, currentCamera.CFrame.Position) -- inferred equivalent call
end

local function handleCameraFeedback(instance, p, p2)
	local v34 = v2[p2]

	if not v34 then
		return
	end

	local v35 = v3[p]

	if not v35 then
		return
	end

	local v36 = v26[instance]

	if not v36 then
		v36 = buildInstrumentReactionEntry(instance)
		v26[instance] = v36

		instance.Destroying:Connect(function()
			v26[instance] = nil
		end)
	end

	local reaction = v36.Reactions[p]

	if not (reaction and reaction[1]) then
		return
	end

	if isEligibleForCameraShake(reaction[1].Part.Position) then -- inferred equivalent call
		triggerCameraShake(v34 * 0.6 * v35) -- inferred equivalent call
	end
end

local function findAmpSoundForCharacter(instance, p) -- 3 equivalent calls inferred from this helper
	local instrumentStand = resolveInstrumentStand(instance)

	if not instrumentStand then
		return nil
	end

	local soundAnchor = instrumentStand:FindFirstChild("SoundAnchor")
	local value = soundAnchor and soundAnchor.Value

	if value then
		return value:FindFirstChild(p .. "_Drum")
	end

	return nil
end

local function computeExpectedSongElapsed(instance)
	local canonicalElapsed = instance:GetAttribute("CanonicalElapsed")
	local canonicalElapsedAt = instance:GetAttribute("CanonicalElapsedAt")

	if canonicalElapsed and canonicalElapsedAt then
		local parent = instance.Parent
		local segmentOffset = parent and parent:GetAttribute("SegmentOffset")
		return (type(segmentOffset) ~= "number" and 0 or segmentOffset) + canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
	end

	return nil
end

local function getVocalistVisualOffset(instance)
	if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
		return 0
	end

	local parent = instance.Parent
	local child = parent and parent:FindFirstChild(instance.Name .. "_VocalistMirror")
	local vocalistVisualOffset = child and child:GetAttribute("VocalistVisualOffset")

	if type(vocalistVisualOffset) == "number" then
		return vocalistVisualOffset
	end

	return 0
end

local function firstNoteIndexAfter(clone, p)
	local v34 = #clone + 1
	local v35 = 1

	while v35 < v34 do
		local v36 = (v35 + v34) // 2

		if p < clone[v36].Time then
			v34 = v36
		else
			v35 = v36 + 1
		end
	end

	return v35
end

local function getDrumSyncOffset(p) -- 2 equivalent calls inferred from this helper
	local song = SongConfig.Songs[p]

	if song then
		return (song.Offset or 0) + (song.InstrumentOffsets and song.InstrumentOffsets.Drum or 0)
	end

	return 0
end

local function collectChordTypes(clone, p)
	local time = clone[p].Time

	while p > 1 and time - clone[p - 1].Time <= 0.02 do
		p -= 1
	end

	local reactionTypes = {}

	while p <= #clone and clone[p].Time - time <= 0.02 do
		table.insert(reactionTypes, clone[p].ReactionType)
		p += 1
	end

	return reactionTypes
end

function DrumAnimator.SetChartSyncActive(instance, p, p2)
	v13[instance] = (v13[instance] or 0) + 1
	local v34 = v13[instance]
	v12[instance] = 0

	if not (p and p2 and instance) then
		return
	end

	local v35 = LocalPlayer.Character == instance

	local chart = ChartLoader.GetChart(p2, "Drum")

	if not chart or #chart == 0 then
		return
	end

	local clone = table.clone(chart)
	table.sort(clone, function(a, b): boolean
		if a.Time == b.Time then
			return (v23[a.ReactionType] and 0 or 1) < (v23[b.ReactionType] and 0 or 1)
		end

		return a.Time < b.Time
	end)
	local drumSyncOffset = getDrumSyncOffset(p2) -- inferred equivalent call
	task.spawn(function()
		local ampSoundForCharacter = findAmpSoundForCharacter(instance, p2) -- inferred equivalent call
		local total = 0

		while not ampSoundForCharacter and v13[instance] == v34 do
			if not instance:IsDescendantOf(game) then
				return
			end

			local v37 = total < 5 and 0.1 or 0.5
			task.wait(v37)
			total += v37
			ampSoundForCharacter = findAmpSoundForCharacter(instance, p2) -- inferred equivalent call
		end

		if not ampSoundForCharacter or v13[instance] ~= v34 then
			return
		end

		local v37 = 1
		local v38 = 1
		local flag = false
		local v39 = not v35 or true

		if v39 then
			v14[instance] = v34
		end

		local v40 = 0
		local v41 = nil
		local v42 = 0
		local v43 = nil

		while v13[instance] == v34 and v37 <= #clone do
			local v44, v45, parent, v46, vocalistVisualOffset, v47, now, v48, v49, v50, v51, v52, v53, v54, v55, success2, result2, success3, result3, v56, v57, v58, v59, v60, v61, v62, v63

			local function fn()
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				return require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("NewbieModeState", 5))
			end

			if ampSoundForCharacter.Parent then
				v44 = computeExpectedSongElapsed(ampSoundForCharacter)

				if v44 then
					if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
						v45 = 0
					else
						parent = ampSoundForCharacter.Parent
						v46 = parent and parent:FindFirstChild(ampSoundForCharacter.Name .. "_VocalistMirror")
						vocalistVisualOffset = v46 and v46:GetAttribute("VocalistVisualOffset")
						v45 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
					end

					if math.abs(v45 - v40) >= 0.15 then
						v37 = firstNoteIndexAfter(clone, v44 + drumSyncOffset + v45)
						v38 = v37
						v40 = v45
						v41 = nil
					else
						v47 = v44 + drumSyncOffset + v45

						now = os.clock()

						if v41 and math.abs(v47 - (v41 + (now - v42))) > 1 then
							v43 = v43 or now

							if now - v43 < 0.3 then
								task.wait(0.03)
							else
								v37 = firstNoteIndexAfter(clone, v47 - 0.05)
								v38 = firstNoteIndexAfter(clone, v47 - 0.1)

								if #clone < v37 then
									break
								end

								v43 = nil

								if flag then
									v48 = clone[v37]

									if v39 then
										v42 = now
										v41 = v47

										while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
											v49 = clone[v38]

											if v35 then
												v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
											else
												v50 = (v12[instance] or 0) <= 2
											end

											v51 = v49.Time - v47

											if v50 then
												v52 = instance
												v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

												if v53 then
													v50 = false
												end
											end

											if v50 and v51 > -0.1 then
												if v49.ReactionType == "Kick" then
													v54 = getKitContext(instance)
													result.BodyHit(instance, "Kick", nil, v51, v54)
												else
													v55 = DrumAnimator.ResolveHandForReaction(
														instance,
														v49.ReactionType,
														collectChordTypes(clone, v38)
													)
													handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
												end
											end

											v38 += 1
										end
									else
										v42 = now
										v41 = v47
									end

									if v48.Time <= v47 then
										v12[instance] = (v12[instance] or 0) + 1

										if v35 then
											if v21 == nil then
												success2, result2 = pcall(fn)

												v21 = success2 and result2 or false
											end

											if v21 then
												success3, result3 = pcall(v21.IsEnabled)
												v56 = success3 and result3 == true
											else
												v56 = false
											end

											v57 = v56 and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
										else
											v57 = (v12[instance] or 0) <= 2
										end

										if v57 then
											v58 = instance
											v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

											if v59 then
												v57 = false
											end
										end

										if v57 then
											v60 = resolveInstrumentStand(instance)

											if v60 then
												if v60 then
													v60 = v60.Parent
												end

												while true do
													if not v60 then
														v61 = nil
														break
													end

													v61 = v60:FindFirstChild("DisplayModel")

													if v61 then
														break
													end

													v60 = v60.Parent
												end
											else
												v61 = v60
											end

											if v61 then
												handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

												handleCameraFeedback(v61, v48.ReactionType, "Perfect")
											end

											if not v39 and v48.ReactionType ~= "Kick" then
												v62 = DrumAnimator.ResolveHandForReaction(
													instance,
													v48.ReactionType,
													collectChordTypes(clone, v37)
												)
												handleAvatarAnimation(instance, v48.ReactionType, v62)
											end
										end

										v37 += 1
									else
										v63 = v48.Time - v47

										if v39 and v38 <= #clone then
											v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
										end

										task.wait((math.clamp(v63, 0.003, 0.05)))
									end
								else
									v37 = firstNoteIndexAfter(clone, v47 - 0.05)
									v38 = firstNoteIndexAfter(clone, v47 - 0.1)

									if #clone < v37 then
										break
									end

									flag = true
									v48 = clone[v37]

									if v39 then
										v42 = now
										v41 = v47

										while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
											v49 = clone[v38]

											if v35 then
												v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
											else
												v50 = (v12[instance] or 0) <= 2
											end

											v51 = v49.Time - v47

											if v50 then
												v52 = instance
												v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

												if v53 then
													v50 = false
												end
											end

											if v50 and v51 > -0.1 then
												if v49.ReactionType == "Kick" then
													v54 = getKitContext(instance)
													result.BodyHit(instance, "Kick", nil, v51, v54)
												else
													v55 = DrumAnimator.ResolveHandForReaction(
														instance,
														v49.ReactionType,
														collectChordTypes(clone, v38)
													)
													handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
												end
											end

											v38 += 1
										end
									else
										v42 = now
										v41 = v47
									end

									if v48.Time <= v47 then
										v12[instance] = (v12[instance] or 0) + 1

										if v35 then
											if v21 == nil then
												success2, result2 = pcall(fn)

												v21 = success2 and result2 or false
											end

											if v21 then
												success3, result3 = pcall(v21.IsEnabled)
												v56 = success3 and result3 == true
											else
												v56 = false
											end

											v57 = v56 and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
										else
											v57 = (v12[instance] or 0) <= 2
										end

										if v57 then
											v58 = instance
											v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

											if v59 then
												v57 = false
											end
										end

										if v57 then
											v60 = resolveInstrumentStand(instance)

											if v60 then
												if v60 then
													v60 = v60.Parent
												end

												while true do
													if not v60 then
														v61 = nil
														break
													end

													v61 = v60:FindFirstChild("DisplayModel")

													if v61 then
														break
													end

													v60 = v60.Parent
												end
											else
												v61 = v60
											end

											if v61 then
												handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

												handleCameraFeedback(v61, v48.ReactionType, "Perfect")
											end

											if not v39 and v48.ReactionType ~= "Kick" then
												v62 = DrumAnimator.ResolveHandForReaction(
													instance,
													v48.ReactionType,
													collectChordTypes(clone, v37)
												)
												handleAvatarAnimation(instance, v48.ReactionType, v62)
											end
										end

										v37 += 1
									else
										v63 = v48.Time - v47

										if v39 and v38 <= #clone then
											v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
										end

										task.wait((math.clamp(v63, 0.003, 0.05)))
									end
								end
							end
						else
							v43 = nil

							if flag then
								v48 = clone[v37]

								if v39 then
									v42 = now
									v41 = v47

									while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
										v49 = clone[v38]

										if v35 then
											v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
										else
											v50 = (v12[instance] or 0) <= 2
										end

										v51 = v49.Time - v47

										if v50 then
											v52 = instance
											v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

											if v53 then
												v50 = false
											end
										end

										if v50 and v51 > -0.1 then
											if v49.ReactionType == "Kick" then
												v54 = getKitContext(instance)
												result.BodyHit(instance, "Kick", nil, v51, v54)
											else
												v55 = DrumAnimator.ResolveHandForReaction(
													instance,
													v49.ReactionType,
													collectChordTypes(clone, v38)
												)
												handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
											end
										end

										v38 += 1
									end
								else
									v42 = now
									v41 = v47
								end

								if v48.Time <= v47 then
									v12[instance] = (v12[instance] or 0) + 1

									if v35 then
										if v21 == nil then
											success2, result2 = pcall(fn)

											v21 = success2 and result2 or false
										end

										if v21 then
											success3, result3 = pcall(v21.IsEnabled)
											v56 = success3 and result3 == true
										else
											v56 = false
										end

										v57 = v56 and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
									else
										v57 = (v12[instance] or 0) <= 2
									end

									if v57 then
										v58 = instance
										v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

										if v59 then
											v57 = false
										end
									end

									if v57 then
										v60 = resolveInstrumentStand(instance)

										if v60 then
											if v60 then
												v60 = v60.Parent
											end

											while true do
												if not v60 then
													v61 = nil
													break
												end

												v61 = v60:FindFirstChild("DisplayModel")

												if v61 then
													break
												end

												v60 = v60.Parent
											end
										else
											v61 = v60
										end

										if v61 then
											handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

											handleCameraFeedback(v61, v48.ReactionType, "Perfect")
										end

										if not v39 and v48.ReactionType ~= "Kick" then
											v62 = DrumAnimator.ResolveHandForReaction(
												instance,
												v48.ReactionType,
												collectChordTypes(clone, v37)
											)
											handleAvatarAnimation(instance, v48.ReactionType, v62)
										end
									end

									v37 += 1
								else
									v63 = v48.Time - v47

									if v39 and v38 <= #clone then
										v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
									end

									task.wait((math.clamp(v63, 0.003, 0.05)))
								end
							else
								v37 = firstNoteIndexAfter(clone, v47 - 0.05)
								v38 = firstNoteIndexAfter(clone, v47 - 0.1)

								if #clone < v37 then
									break
								end

								flag = true
								v48 = clone[v37]

								if v39 then
									v42 = now
									v41 = v47

									while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
										v49 = clone[v38]

										if v35 then
											v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
										else
											v50 = (v12[instance] or 0) <= 2
										end

										v51 = v49.Time - v47

										if v50 then
											v52 = instance
											v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

											if v53 then
												v50 = false
											end
										end

										if v50 and v51 > -0.1 then
											if v49.ReactionType == "Kick" then
												v54 = getKitContext(instance)
												result.BodyHit(instance, "Kick", nil, v51, v54)
											else
												v55 = DrumAnimator.ResolveHandForReaction(
													instance,
													v49.ReactionType,
													collectChordTypes(clone, v38)
												)
												handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
											end
										end

										v38 += 1
									end
								else
									v42 = now
									v41 = v47
								end

								if v48.Time <= v47 then
									v12[instance] = (v12[instance] or 0) + 1

									if v35 then
										if v21 == nil then
											success2, result2 = pcall(fn)

											v21 = success2 and result2 or false
										end

										if v21 then
											success3, result3 = pcall(v21.IsEnabled)
											v56 = success3 and result3 == true
										else
											v56 = false
										end

										v57 = v56 and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
									else
										v57 = (v12[instance] or 0) <= 2
									end

									if v57 then
										v58 = instance
										v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

										if v59 then
											v57 = false
										end
									end

									if v57 then
										v60 = resolveInstrumentStand(instance)

										if v60 then
											if v60 then
												v60 = v60.Parent
											end

											while true do
												if not v60 then
													v61 = nil
													break
												end

												v61 = v60:FindFirstChild("DisplayModel")

												if v61 then
													break
												end

												v60 = v60.Parent
											end
										else
											v61 = v60
										end

										if v61 then
											handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

											handleCameraFeedback(v61, v48.ReactionType, "Perfect")
										end

										if not v39 and v48.ReactionType ~= "Kick" then
											v62 = DrumAnimator.ResolveHandForReaction(
												instance,
												v48.ReactionType,
												collectChordTypes(clone, v37)
											)
											handleAvatarAnimation(instance, v48.ReactionType, v62)
										end
									end

									v37 += 1
								else
									v63 = v48.Time - v47

									if v39 and v38 <= #clone then
										v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
									end

									task.wait((math.clamp(v63, 0.003, 0.05)))
								end
							end
						end
					end
				else
					task.wait(0.05)
				end
			else
				ampSoundForCharacter = findAmpSoundForCharacter(instance, p2) -- inferred equivalent call

				if ampSoundForCharacter then
					v44 = computeExpectedSongElapsed(ampSoundForCharacter)

					if v44 then
						if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
							v45 = 0
						else
							parent = ampSoundForCharacter.Parent
							v46 = parent and parent:FindFirstChild(ampSoundForCharacter.Name .. "_VocalistMirror")
							vocalistVisualOffset = v46 and v46:GetAttribute("VocalistVisualOffset")
							v45 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
						end

						if math.abs(v45 - v40) >= 0.15 then
							v37 = firstNoteIndexAfter(clone, v44 + drumSyncOffset + v45)
							v38 = v37
							v40 = v45
							v41 = nil
						else
							v47 = v44 + drumSyncOffset + v45

							now = os.clock()

							if v41 and math.abs(v47 - (v41 + (now - v42))) > 1 then
								v43 = v43 or now

								if now - v43 < 0.3 then
									task.wait(0.03)
								else
									v37 = firstNoteIndexAfter(clone, v47 - 0.05)
									v38 = firstNoteIndexAfter(clone, v47 - 0.1)

									if #clone < v37 then
										break
									end

									v43 = nil

									if flag then
										v48 = clone[v37]

										if v39 then
											v42 = now
											v41 = v47

											while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
												v49 = clone[v38]

												if v35 then
													v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
												else
													v50 = (v12[instance] or 0) <= 2
												end

												v51 = v49.Time - v47

												if v50 then
													v52 = instance
													v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

													if v53 then
														v50 = false
													end
												end

												if v50 and v51 > -0.1 then
													if v49.ReactionType == "Kick" then
														v54 = getKitContext(instance)
														result.BodyHit(instance, "Kick", nil, v51, v54)
													else
														v55 = DrumAnimator.ResolveHandForReaction(
															instance,
															v49.ReactionType,
															collectChordTypes(clone, v38)
														)
														handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
													end
												end

												v38 += 1
											end
										else
											v42 = now
											v41 = v47
										end

										if v48.Time <= v47 then
											v12[instance] = (v12[instance] or 0) + 1

											if v35 then
												if v21 == nil then
													success2, result2 = pcall(fn)

													v21 = success2 and result2 or false
												end

												if v21 then
													success3, result3 = pcall(v21.IsEnabled)
													v56 = success3 and result3 == true
												else
													v56 = false
												end

												v57 = v56
													and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
											else
												v57 = (v12[instance] or 0) <= 2
											end

											if v57 then
												v58 = instance
												v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

												if v59 then
													v57 = false
												end
											end

											if v57 then
												v60 = resolveInstrumentStand(instance)

												if v60 then
													if v60 then
														v60 = v60.Parent
													end

													while true do
														if not v60 then
															v61 = nil
															break
														end

														v61 = v60:FindFirstChild("DisplayModel")

														if v61 then
															break
														end

														v60 = v60.Parent
													end
												else
													v61 = v60
												end

												if v61 then
													handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

													handleCameraFeedback(v61, v48.ReactionType, "Perfect")
												end

												if not v39 and v48.ReactionType ~= "Kick" then
													v62 = DrumAnimator.ResolveHandForReaction(
														instance,
														v48.ReactionType,
														collectChordTypes(clone, v37)
													)
													handleAvatarAnimation(instance, v48.ReactionType, v62)
												end
											end

											v37 += 1
										else
											v63 = v48.Time - v47

											if v39 and v38 <= #clone then
												v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
											end

											task.wait((math.clamp(v63, 0.003, 0.05)))
										end
									else
										v37 = firstNoteIndexAfter(clone, v47 - 0.05)
										v38 = firstNoteIndexAfter(clone, v47 - 0.1)

										if #clone < v37 then
											break
										end

										flag = true
										v48 = clone[v37]

										if v39 then
											v42 = now
											v41 = v47

											while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
												v49 = clone[v38]

												if v35 then
													v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
												else
													v50 = (v12[instance] or 0) <= 2
												end

												v51 = v49.Time - v47

												if v50 then
													v52 = instance
													v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

													if v53 then
														v50 = false
													end
												end

												if v50 and v51 > -0.1 then
													if v49.ReactionType == "Kick" then
														v54 = getKitContext(instance)
														result.BodyHit(instance, "Kick", nil, v51, v54)
													else
														v55 = DrumAnimator.ResolveHandForReaction(
															instance,
															v49.ReactionType,
															collectChordTypes(clone, v38)
														)
														handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
													end
												end

												v38 += 1
											end
										else
											v42 = now
											v41 = v47
										end

										if v48.Time <= v47 then
											v12[instance] = (v12[instance] or 0) + 1

											if v35 then
												if v21 == nil then
													success2, result2 = pcall(fn)

													v21 = success2 and result2 or false
												end

												if v21 then
													success3, result3 = pcall(v21.IsEnabled)
													v56 = success3 and result3 == true
												else
													v56 = false
												end

												v57 = v56
													and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
											else
												v57 = (v12[instance] or 0) <= 2
											end

											if v57 then
												v58 = instance
												v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

												if v59 then
													v57 = false
												end
											end

											if v57 then
												v60 = resolveInstrumentStand(instance)

												if v60 then
													if v60 then
														v60 = v60.Parent
													end

													while true do
														if not v60 then
															v61 = nil
															break
														end

														v61 = v60:FindFirstChild("DisplayModel")

														if v61 then
															break
														end

														v60 = v60.Parent
													end
												else
													v61 = v60
												end

												if v61 then
													handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

													handleCameraFeedback(v61, v48.ReactionType, "Perfect")
												end

												if not v39 and v48.ReactionType ~= "Kick" then
													v62 = DrumAnimator.ResolveHandForReaction(
														instance,
														v48.ReactionType,
														collectChordTypes(clone, v37)
													)
													handleAvatarAnimation(instance, v48.ReactionType, v62)
												end
											end

											v37 += 1
										else
											v63 = v48.Time - v47

											if v39 and v38 <= #clone then
												v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
											end

											task.wait((math.clamp(v63, 0.003, 0.05)))
										end
									end
								end
							else
								v43 = nil

								if flag then
									v48 = clone[v37]

									if v39 then
										v42 = now
										v41 = v47

										while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
											v49 = clone[v38]

											if v35 then
												v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
											else
												v50 = (v12[instance] or 0) <= 2
											end

											v51 = v49.Time - v47

											if v50 then
												v52 = instance
												v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

												if v53 then
													v50 = false
												end
											end

											if v50 and v51 > -0.1 then
												if v49.ReactionType == "Kick" then
													v54 = getKitContext(instance)
													result.BodyHit(instance, "Kick", nil, v51, v54)
												else
													v55 = DrumAnimator.ResolveHandForReaction(
														instance,
														v49.ReactionType,
														collectChordTypes(clone, v38)
													)
													handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
												end
											end

											v38 += 1
										end
									else
										v42 = now
										v41 = v47
									end

									if v48.Time <= v47 then
										v12[instance] = (v12[instance] or 0) + 1

										if v35 then
											if v21 == nil then
												success2, result2 = pcall(fn)

												v21 = success2 and result2 or false
											end

											if v21 then
												success3, result3 = pcall(v21.IsEnabled)
												v56 = success3 and result3 == true
											else
												v56 = false
											end

											v57 = v56 and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
										else
											v57 = (v12[instance] or 0) <= 2
										end

										if v57 then
											v58 = instance
											v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

											if v59 then
												v57 = false
											end
										end

										if v57 then
											v60 = resolveInstrumentStand(instance)

											if v60 then
												if v60 then
													v60 = v60.Parent
												end

												while true do
													if not v60 then
														v61 = nil
														break
													end

													v61 = v60:FindFirstChild("DisplayModel")

													if v61 then
														break
													end

													v60 = v60.Parent
												end
											else
												v61 = v60
											end

											if v61 then
												handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

												handleCameraFeedback(v61, v48.ReactionType, "Perfect")
											end

											if not v39 and v48.ReactionType ~= "Kick" then
												v62 = DrumAnimator.ResolveHandForReaction(
													instance,
													v48.ReactionType,
													collectChordTypes(clone, v37)
												)
												handleAvatarAnimation(instance, v48.ReactionType, v62)
											end
										end

										v37 += 1
									else
										v63 = v48.Time - v47

										if v39 and v38 <= #clone then
											v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
										end

										task.wait((math.clamp(v63, 0.003, 0.05)))
									end
								else
									v37 = firstNoteIndexAfter(clone, v47 - 0.05)
									v38 = firstNoteIndexAfter(clone, v47 - 0.1)

									if #clone < v37 then
										break
									end

									flag = true
									v48 = clone[v37]

									if v39 then
										v42 = now
										v41 = v47

										while v38 <= #clone and clone[v38].Time - 0.6 <= v47 do
											v49 = clone[v38]

											if v35 then
												v50 = os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
											else
												v50 = (v12[instance] or 0) <= 2
											end

											v51 = v49.Time - v47

											if v50 then
												v52 = instance
												v53 = isFreePlayVisualMode(v52) -- inferred equivalent call

												if v53 then
													v50 = false
												end
											end

											if v50 and v51 > -0.1 then
												if v49.ReactionType == "Kick" then
													v54 = getKitContext(instance)
													result.BodyHit(instance, "Kick", nil, v51, v54)
												else
													v55 = DrumAnimator.ResolveHandForReaction(
														instance,
														v49.ReactionType,
														collectChordTypes(clone, v38)
													)
													handleAvatarAnimation(instance, v49.ReactionType, v55, v51)
												end
											end

											v38 += 1
										end
									else
										v42 = now
										v41 = v47
									end

									if v48.Time <= v47 then
										v12[instance] = (v12[instance] or 0) + 1

										if v35 then
											if v21 == nil then
												success2, result2 = pcall(fn)

												v21 = success2 and result2 or false
											end

											if v21 then
												success3, result3 = pcall(v21.IsEnabled)
												v56 = success3 and result3 == true
											else
												v56 = false
											end

											v57 = v56 and os.clock() - (nowsByCharacter[instance] or -1000000000) < 3
										else
											v57 = (v12[instance] or 0) <= 2
										end

										if v57 then
											v58 = instance
											v59 = isFreePlayVisualMode(v58) -- inferred equivalent call

											if v59 then
												v57 = false
											end
										end

										if v57 then
											v60 = resolveInstrumentStand(instance)

											if v60 then
												if v60 then
													v60 = v60.Parent
												end

												while true do
													if not v60 then
														v61 = nil
														break
													end

													v61 = v60:FindFirstChild("DisplayModel")

													if v61 then
														break
													end

													v60 = v60.Parent
												end
											else
												v61 = v60
											end

											if v61 then
												handleInstrumentReaction(v61, v48.ReactionType, "Perfect")

												handleCameraFeedback(v61, v48.ReactionType, "Perfect")
											end

											if not v39 and v48.ReactionType ~= "Kick" then
												v62 = DrumAnimator.ResolveHandForReaction(
													instance,
													v48.ReactionType,
													collectChordTypes(clone, v37)
												)
												handleAvatarAnimation(instance, v48.ReactionType, v62)
											end
										end

										v37 += 1
									else
										v63 = v48.Time - v47

										if v39 and v38 <= #clone then
											v63 = math.min(v63, clone[v38].Time - 0.6 - v47)
										end

										task.wait((math.clamp(v63, 0.003, 0.05)))
									end
								end
							end
						end
					else
						task.wait(0.05)
					end
				else
					task.wait(0.1)
				end
			end
		end

		if v14[instance] == v34 then
			v14[instance] = nil
		end
	end)
end

local v34 = {}

function DrumAnimator.SetAutoChartSyncActive(instance, p, p2)
	v34[instance] = (v34[instance] or 0) + 1
	local v35 = v34[instance]

	if not (p and p2 and instance) then
		return
	end

	local v36 = if instance then instance.Parent else instance
	local displayModel

	while true do
		if not v36 then
			displayModel = nil
			break
		end

		displayModel = v36:FindFirstChild("DisplayModel")

		if displayModel then
			break
		end

		v36 = v36.Parent
	end

	if not displayModel then
		return
	end

	local soundAnchor = instance:FindFirstChild("SoundAnchor")
	local value = soundAnchor and soundAnchor.Value

	if not value then
		return
	end

	local chart = ChartLoader.GetChart(p2, "Drum")

	if not chart or #chart == 0 then
		return
	end

	local clone = table.clone(chart)
	table.sort(clone, function(a, b): boolean
		return a.Time < b.Time
	end)
	local drumSyncOffset = getDrumSyncOffset(p2) -- inferred equivalent call
	local v37 = p2 .. "_Drum_Auto"

	task.spawn(function()
		local v38 = value:FindFirstChild(v37)
		local total = 0

		while not v38 and total < 5 and v34[instance] == v35 do
			task.wait(0.1)
			total += 0.1
			v38 = value:FindFirstChild(v37)
		end

		if not v38 or v34[instance] ~= v35 then
			return
		end

		local v39 = 1
		local v40 = 0
		local v41 = nil
		local v42 = 0
		local v43 = nil

		while v34[instance] == v35 and v39 <= #clone do
			local v44, v45, parent, v46, vocalistVisualOffset, v47, now, v48

			if v38.Parent then
				v44 = computeExpectedSongElapsed(v38)

				if v44 then
					if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
						v45 = 0
					else
						parent = v38.Parent
						v46 = parent and parent:FindFirstChild(v38.Name .. "_VocalistMirror")
						vocalistVisualOffset = v46 and v46:GetAttribute("VocalistVisualOffset")
						v45 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
					end

					if math.abs(v45 - v40) >= 0.15 then
						v39 = firstNoteIndexAfter(clone, v44 + drumSyncOffset + v45)
						v40 = v45
						v41 = nil
					else
						v47 = v44 + drumSyncOffset + v45

						now = os.clock()

						if v41 and math.abs(v47 - (v41 + (now - v42))) > 1 then
							v43 = v43 or now

							if now - v43 < 0.3 then
								task.wait(0.03)
								continue
							end

							v39 = firstNoteIndexAfter(clone, v47 - 0.05)

							if #clone < v39 then
								break
							end
						end

						v43 = nil

						v48 = clone[v39]

						if v48.Time <= v47 then
							handleInstrumentReaction(displayModel, v48.ReactionType, "Perfect")
							handleCameraFeedback(displayModel, v48.ReactionType, "Perfect")

							v39 += 1
						else
							task.wait((math.min(0.05, v48.Time - v47)))
						end

						v42 = now
						v41 = v47
					end
				else
					task.wait(0.05)
				end
			else
				v38 = value:FindFirstChild(v37)

				if v38 then
					v44 = computeExpectedSongElapsed(v38)

					if v44 then
						if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
							v45 = 0
						else
							parent = v38.Parent
							v46 = parent and parent:FindFirstChild(v38.Name .. "_VocalistMirror")
							vocalistVisualOffset = v46 and v46:GetAttribute("VocalistVisualOffset")
							v45 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
						end

						if math.abs(v45 - v40) >= 0.15 then
							v39 = firstNoteIndexAfter(clone, v44 + drumSyncOffset + v45)
							v40 = v45
							v41 = nil
						else
							v47 = v44 + drumSyncOffset + v45

							now = os.clock()

							if v41 and math.abs(v47 - (v41 + (now - v42))) > 1 then
								v43 = v43 or now

								if now - v43 < 0.3 then
									task.wait(0.03)
									continue
								end

								v39 = firstNoteIndexAfter(clone, v47 - 0.05)

								if #clone < v39 then
									break
								end
							end

							v43 = nil

							v48 = clone[v39]

							if v48.Time <= v47 then
								handleInstrumentReaction(displayModel, v48.ReactionType, "Perfect")
								handleCameraFeedback(displayModel, v48.ReactionType, "Perfect")

								v39 += 1
							else
								task.wait((math.min(0.05, v48.Time - v47)))
							end

							v42 = now
							v41 = v47
						end
					else
						task.wait(0.05)
					end
				else
					task.wait(0.1)
				end
			end
		end
	end)
end

function DrumAnimator.Handle(player, data)
	local eventType = data.EventType

	if eventType == "HoldEnd" or eventType ~= "Hit" and eventType ~= "HoldStart" then
		return
	end

	local noteData = data.NoteData
	local reactionType = noteData and noteData.ReactionType

	if not reactionType then
		return
	end

	local character = player and player.Character

	local v35 = character and nowsByCharacter[character]

	if character then
		v12[character] = 0
		nowsByCharacter[character] = os.clock()
	end

	local judgmentQuality = data.JudgmentQuality
	local instrumentInstance = DrumAnimator.ResolveInstrumentInstance(player)

	if player ~= LocalPlayer then
		return
	end

	if v21 == nil then
		local success2, result2 = pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			return require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("NewbieModeState", 5))
		end)

		v21 = success2 and result2 or false
	end

	local v36

	if v21 then
		local success2, result2 = pcall(v21.IsEnabled)
		v36 = success2 and result2 == true
	else
		v36 = false
	end

	if v36 then
		return
	end

	if instrumentInstance then
		handleCameraFeedback(instrumentInstance, reactionType, judgmentQuality)
	end

	if instrumentInstance then
		handleInstrumentReaction(instrumentInstance, reactionType, judgmentQuality)
	end

	local v37

	if character == nil or v14[character] == nil then
		v37 = false
	else
		v37 = v14[character] == v13[character]
	end

	local v38

	if v35 == nil then
		v38 = false
	else
		v38 = os.clock() - v35 < 3
	end

	if not (v37 and v38) and character then
		if reactionType == "Kick" then
			local kitContext = getKitContext(character)
			result.BodyHit(character, "Kick", nil, nil, kitContext)
		else
			handleAvatarAnimation(character, reactionType, noteData.ResolvedHand)
		end
	end
end

local function getIdleTrack(instance)
	local v35 = v10[instance]

	if v35 then
		return v35
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://119527411386630"
	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Movement
	track.Looped = true

	v10[instance] = track
	return track
end

local function applyIdle(p, p2, p3) -- 2 equivalent calls inferred from this helper
	local idleTrack = getIdleTrack(p)

	if not idleTrack then
		return
	end

	if p2 then
		pcall(result.EnsureGrip, p)

		if not idleTrack.IsPlaying then
			idleTrack:Play()
		end
	elseif idleTrack.IsPlaying then
		idleTrack:Stop(p3)
	end
end

function DrumAnimator.SetIdleActive(p, p2)
	if p == nil then
		return
	end

	v19[p] = p2 == true

	if v16[p] then
		return
	end

	applyIdle(p, p2)
end

local v35 = {
	BassDrum = { Type = "Kick" },
	Snare = { Type = "Snare" },
	SideStick = { Type = "Snare" },
	HighTom = { Type = "HiTom" },
	MidTom = { Type = "MidTom" },
	FloorTom = { Type = "FloorTom" },
	FootHiHat = { Type = "HiHat" },
	OpenHiHat = { Type = "HiHat" },
	HighCrash = { Type = "Crash" },
	MediumCrash = { Type = "Crash" },
	Splash = { Type = "Crash" },
	China = { Type = "Crash" },
	RideEdge = { Type = "Ride" },
	RideBell = { Type = "Ride" },
	Cowbell = { Type = "Ride", AvatarOnly = true }
}

function DrumAnimator.SetFreePlayDrumMode(p, p2)
	if p == nil then
		return
	end

	local v36 = p2 == true

	if (v16[p] == true) == v36 then
		return
	end

	v16[p] = v36 or nil
	v17[p] = (v17[p] or 0) + 1

	if v36 then
		local idleTrack = getIdleTrack(p)

		if not idleTrack then
			return
		end

		pcall(result.EnsureGrip, p)

		if not idleTrack.IsPlaying then
			idleTrack:Play()
		end
	else
		v18[p] = nil
		applyIdle(p, v19[p] == true)
	end
end

function DrumAnimator.HoldContactPose(p, p2, p3, p4)
	local kitContext, v36 = getKitContext(p)

	if kitContext then
		return result.Grab(p, p3, p2, kitContext, v36, p4)
	end

	return false
end

local v36 = { Crash = "Left", Ride = "Right" }

function DrumAnimator.ChokeCymbals(player)
	local instrumentInstance = DrumAnimator.ResolveInstrumentInstance(player)

	if not instrumentInstance then
		return 0
	end

	local now = os.clock()
	local count = 0
	local v37 = -1
	local reactionType = nil

	for k, v38 in pairs(v29) do
		if v38.ChokeAt or not k:IsDescendantOf(instrumentInstance) then
			continue
		end

		v38.ChokeAt = now
		count += 1

		if not (v36[v38.ReactionType] and v37 < v38.StartClock) then
			continue
		end

		reactionType = v38.ReactionType
		v37 = v38.StartClock
	end

	local character = player and player.Character

	if not (reactionType and character and character.Parent) then
		return count
	end

	local kitContext, v38 = getKitContext(character)

	if not kitContext then
		return count
	end

	v17[character] = (v17[character] or 0) + 1

	if v16[character] then
		local v39 = v17[character]
		applyIdle(character, false, 0.2) -- inferred equivalent call
		task.delay(5, function()
			if v17[character] == v39 and v16[character] and character.Parent then
				local v40 = character
				local idleTrack = getIdleTrack(v40)

				if not idleTrack then
					return
				end

				pcall(result.EnsureGrip, v40)

				if not idleTrack.IsPlaying then
					idleTrack:Play()
				end
			end
		end)
	end

	local success2, result2 = pcall(result.Grab, character, v36[reactionType], reactionType, kitContext, v38, 0.32)

	if not success2 then
		warn("[DrumAnimator] Grab choke gagal:", result2)
	end

	return count
end

local function collectFreePlayChord(character, kind, now)
	local v37 = v18[character]

	if not v37 then
		v37 = {}
		v18[character] = v37
	end

	for i = #v37, 1, -1 do
		if now - v37[i].Time > 0.035 then
			table.remove(v37, i)
		end
	end

	table.insert(v37, { Time = now, Type = kind })
	local typeSet = {}
	local types = {}

	for _, v38 in ipairs(v37) do
		if typeSet[v38.Type] then
			continue
		end

		typeSet[v38.Type] = true
		table.insert(types, v38.Type)
	end

	return types
end

function DrumAnimator.PlayFreePlayHit(player, p, p2)
	local v37 = v35[p]

	if not v37 then
		return nil
	end

	local character = player and player.Character

	if not (character and character.Parent) then
		return nil
	end

	local instrumentInstance = DrumAnimator.ResolveInstrumentInstance(player)

	if not instrumentInstance then
		return nil
	end

	local kind = v37.Type

	v17[character] = (v17[character] or 0) + 1

	if v16[character] then
		local v38 = v17[character]
		applyIdle(character, false, 0.2) -- inferred equivalent call
		task.delay(5, function()
			if v17[character] == v38 and v16[character] and character.Parent then
				local v39 = character
				local idleTrack = getIdleTrack(v39)

				if not idleTrack then
					return
				end

				pcall(result.EnsureGrip, v39)

				if not idleTrack.IsPlaying then
					idleTrack:Play()
				end
			end
		end)
	end

	if not v37.AvatarOnly then
		handleCameraFeedback(instrumentInstance, kind, "Perfect")
		handleInstrumentReaction(instrumentInstance, kind, "Perfect")
	end

	if kind == "Kick" then
		local kitContext = getKitContext(character)
		result.BodyHit(character, "Kick", nil, nil, kitContext)
		return nil
	end

	if p2 == "Left" or p2 == "Right" then
		collectFreePlayChord(character, kind, os.clock())
	else
		p2 = DrumAnimator.ResolveHandForReaction(character, kind, collectFreePlayChord(character, kind, os.clock()))
	end

	handleAvatarAnimation(character, kind, p2, nil)
	return p2
end

local function getStickClickTrack(character)
	local v37 = v11[character]

	if v37 then
		return v37
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://88055003815825"
	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false

	v11[character] = track
	return track
end

function DrumAnimator.PlayCountInClicks(player, p, p2, p3, value)
	if not p or p <= 0 or not (p2 and p3) then
		return
	end

	local instrumentInstance = DrumAnimator.ResolveInstrumentInstance(player)

	if not instrumentInstance then
		return
	end

	local character = player.Character

	local basePart = instrumentInstance:FindFirstChildWhichIsA("BasePart", true)

	if not basePart then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://91725271068764"
	sound.Volume = value or 1
	sound.Parent = basePart

	task.spawn(function()
		pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync({ sound })
		end)
	end)

	local v37 = 60 / p
	local v38 = p3 + p2
	local maxValue = 0
	local v39 = {}

	for i = 1, 4 do
		local v40 = v38 - (5 - i) * v37

		if not (v40 >= 0) then
			continue
		end

		maxValue = math.max(maxValue, v40)
		table.insert(v39, v40)
		task.delay(v40, function()
			if sound.Parent then
				sound.TimePosition = 0
				sound:Play()
			end

			local v41 = character and character.Parent and getStickClickTrack(character)

			if v41 then
				v41:Play()
			end
		end)
	end

	if player == LocalPlayer and #v39 > 0 then
		StickClickNoteDisplay.Show(v39, v37 * 1.3)
	end

	task.delay(maxValue + 1, function()
		if sound then
			sound:Destroy()
		end
	end)
end

function DrumAnimator.PlayManualStickClick(player)
	local instrumentInstance = DrumAnimator.ResolveInstrumentInstance(player)

	if not instrumentInstance then
		return
	end

	local basePart = instrumentInstance:FindFirstChildWhichIsA("BasePart", true)

	if not basePart then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://91725271068764"
	sound.Volume = 1
	sound.Parent = basePart
	sound:Play()

	local character = player.Character
	local v37 = character and character.Parent and getStickClickTrack(character)

	if v37 then
		v37:Play()
	end

	task.delay(2, function()
		if sound then
			sound:Destroy()
		end
	end)
end

return DrumAnimator