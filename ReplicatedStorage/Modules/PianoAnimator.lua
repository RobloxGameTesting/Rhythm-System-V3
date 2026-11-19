local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local ChartLoader = require(ReplicatedStorage.Modules.ChartLoader)
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)

local PianoHandAnimator = require(ReplicatedStorage.Modules.PianoHandAnimator)
local PianoArmPoseAnimator = require(ReplicatedStorage.Modules.PianoArmPoseAnimator)

local LocalPlayer = Players.LocalPlayer

local PianoAnimator = {}

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local object3 = setmetatable({}, { __mode = "k" })
local object4 = setmetatable({}, { __mode = "k" })

local function resolveInstrumentStand(instance)
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
	local v = humanoid and humanoid.SeatPart

	if not v then
		return nil
	end

	while v do
		if CollectionService:HasTag(v, "InstrumentStand") then
			return v
		end

		v = v.Parent
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

local function resolvePianoModelFromStand(instrumentStand)
	local parent = instrumentStand and instrumentStand.Parent
	local displayModel

	while true do
		if not parent then
			displayModel = nil
			break
		end

		displayModel = parent:FindFirstChild("DisplayModel")

		if displayModel then
			break
		end

		parent = parent.Parent
	end

	if displayModel then
		return displayModel:FindFirstChild("Piano Akustik Optimized")
	end

	return nil
end

local function resolvePianoModel(p)
	local instrumentStand = resolveInstrumentStand(p)

	if instrumentStand then
		return resolvePianoModelFromStand(instrumentStand)
	end

	return nil
end

local function midiNoteToGroupKey(p)
	local v = p - 36

	if v < 0 or v > 60 then
		return nil
	end

	return math.floor(v / 12) + 1, v % 12 + 1
end

local function midiNoteToHand(p): string -- 3 equivalent calls inferred from this helper
	return if p < 66 then "Left" else "Right"
end

local v = {}
local cframesByChild = {}

local function getKeyPart(instance, p, p2)
	local v2 = v[instance]

	if not v2 then
		v2 = {}
		v[instance] = v2
	end

	local children = v2[p]

	if not children then
		children = {}
		v2[p] = children
	end

	local v3 = children[p2]

	if v3 and v3.Parent then
		return v3
	end

	local keys = instance:FindFirstChild("Keys")
	local child = keys and keys:FindFirstChild((tostring(p)))
	local child2 = child and child:FindFirstChild((tostring(p2)))

	if child2 then
		children[p2] = child2

		if not cframesByChild[child2] then
			cframesByChild[child2] = child2.CFrame
		end
	end

	return child2
end

local v2 = {}
local v3 = {}
local v4 = {}

local function getPressedCFrame(p) -- 1 equivalent call inferred from this helper
	return p * CFrame.new(0, -0.08, 0)
end

local function trackPressedKey(p, instance) -- 1 equivalent call inferred from this helper
	if not p then
		return
	end

	local v5 = v3[p]

	if not v5 then
		v5 = {}
		v3[p] = v5
	end

	v5[instance] = true
end

local function untrackPressedKey(p, instance) -- 1 equivalent call inferred from this helper
	local v5 = p and v3[p]

	if v5 then
		v5[instance] = nil
	end
end

local function pressKey(p, keyPart)
	local cframe = cframesByChild[keyPart]

	if not cframe then
		return
	end

	local v5 = v2[keyPart]

	if not v5 then
		v5 = { PressCount = 0 }
		v2[keyPart] = v5
	end

	v5.PressCount += 1
	trackPressedKey(p, keyPart) -- inferred equivalent call

	if v5.Tween then
		v5.Tween:Cancel()
		v5.Tween = nil
	end

	local Players2 = game:GetService("Players")
	local localPlayer = Players2.LocalPlayer

	if localPlayer and p == localPlayer.Character and localPlayer:GetAttribute("PianoKeysHidden") then
		keyPart.CFrame = cframe
		return
	end

	local pressedCFrame = getPressedCFrame(cframe) -- inferred equivalent call
	local tween = TweenService:Create(keyPart, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = pressedCFrame
	})

	v5.Tween = tween
	tween:Play()
end

local function releaseKey(p, keyPart)
	local v5 = v2[keyPart]

	if not v5 then
		return
	end

	v5.PressCount = math.max(0, v5.PressCount - 1)

	if v5.PressCount > 0 then
		return
	end

	untrackPressedKey(p, keyPart) -- inferred equivalent call
	local cframe = cframesByChild[keyPart]

	if not cframe then
		return
	end

	if v5.Tween then
		v5.Tween:Cancel()
		v5.Tween = nil
	end

	local tween = TweenService:Create(keyPart, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		CFrame = cframe
	})

	v5.Tween = tween
	tween:Play()
end

local function forceReleaseAllForCharacter(instance)
	local v5 = v3[instance]

	if not v5 then
		return
	end

	for k in pairs(v5) do
		local v6 = v2[k]

		if v6 then
			if v6.Tween then
				v6.Tween:Cancel()
			end

			v2[k] = nil
		end

		local cframe = cframesByChild[k]

		if cframe and k.Parent then
			k.CFrame = cframe
		end
	end

	v3[instance] = {}
end

local function buildChordGroups(clone, p)
	local v5 = 1
	local chordGroups = {}

	while v5 <= #clone do
		local time = clone[v5].Time
		local v6 = {
			Time = time,
			Notes = { clone[v5] }
		}
		v5 += 1

		while v5 <= #clone and clone[v5].Time - time <= p do
			table.insert(v6.Notes, clone[v5])
			v5 += 1
		end

		table.insert(chordGroups, v6)
	end

	return chordGroups
end

local function computeExpectedSongElapsed(instance) -- 2 equivalent calls inferred from this helper
	local canonicalElapsed = instance:GetAttribute("CanonicalElapsed")
	local canonicalElapsedAt = instance:GetAttribute("CanonicalElapsedAt")

	if canonicalElapsed and canonicalElapsedAt then
		return canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
	end

	return nil
end

local function findAmpSoundForStand(instrumentStand, p)
	local soundAnchor = instrumentStand:FindFirstChild("SoundAnchor")
	local value = soundAnchor and soundAnchor.Value

	if value then
		return value:FindFirstChild(p .. "_Piano")
	end

	return nil
end

local function findPianoAmpSound(instance, p) -- 3 equivalent calls inferred from this helper
	local instrumentStand = resolveInstrumentStand(instance)

	if instrumentStand then
		return findAmpSoundForStand(instrumentStand, p)
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

local function getPianoSyncOffset(p) -- 2 equivalent calls inferred from this helper
	local song = SongConfig.Songs[p]

	if song then
		return (song.Offset or 0) + (song.InstrumentOffsets and song.InstrumentOffsets.PianoMIDI or 0)
	end

	return 0
end

local function beginAvatarPose(p) -- 2 equivalent calls inferred from this helper
	if v4[p] then
		return
	end

	v4[p] = true
	PianoArmPoseAnimator.Setup(p)
	task.delay(0.35, function()
		PianoHandAnimator.Setup(p)
	end)
end

local function triggerChordGroup(p, p2, p3, p4, p5)
	if object[p] then
		return
	end

	if not (p5 or v4[p]) then
		v4[p] = true
		PianoArmPoseAnimator.Setup(p)

		task.delay(0.35, function()
			PianoHandAnimator.Setup(p)
		end)
	end

	local v5 = {}

	for _, note in ipairs(p3.Notes) do
		local v6 = note.Note - 36
		local v7, v8

		if not (v6 < 0 or v6 > 60) then
			v7 = math.floor(v6 / 12) + 1
			v8 = v6 % 12 + 1
		end

		if not v7 then
			continue
		end

		local keyPart = getKeyPart(p2, v7, v8)

		if not keyPart then
			continue
		end

		pressKey(p, keyPart)
		local v9 = math.max(0, p4 and p4[note] or note.Duration)

		if p5 then
			task.delay(v9, function()
				releaseKey(p, keyPart)
			end)
		else
			local v10 = midiNoteToHand(note.Note) -- inferred equivalent call
			PianoArmPoseAnimator.NotePressed(p, v10)
			task.delay(v9, function()
				releaseKey(p, keyPart)
				PianoArmPoseAnimator.NoteReleased(p, v10)
			end)
		end

		if not p5 then
			table.insert(v5, {
				keyPart = keyPart,
				originalCFrame = cframesByChild[keyPart],
				note = note.Note,
				hand = midiNoteToHand(note.Note) -- inferred equivalent call
			})
		end
	end

	if #v5 > 0 then
		PianoHandAnimator.UpdateForChordGroup(p, v5)
	end
end

local function resyncGroupCursor(chordGroups, p, instance, pianoAkustikOptimized, p2)
	local v5 = 1

	while v5 <= #chordGroups do
		local item = chordGroups[v5]

		if p < item.Time then
			break
		end

		local flag = false

		for _, note in ipairs(item.Notes) do
			if p < note.Time + note.Duration then
				flag = true
				break
			end
		end

		if flag then
			local v6 = {}

			for _, note in ipairs(item.Notes) do
				v6[note] = math.max(0, note.Time + note.Duration - p)
			end

			triggerChordGroup(instance, pianoAkustikOptimized, item, v6, p2)
		end

		v5 += 1
	end

	return v5
end

local v5 = {}

function PianoAnimator.SetChartSyncActive(instance, p, p2)
	v5[instance] = (v5[instance] or 0) + 1
	local v6 = v5[instance]
	object4[instance] = p and p2 and instance and true or nil

	forceReleaseAllForCharacter(instance)

	PianoHandAnimator.Cleanup(instance)
	PianoArmPoseAnimator.Cleanup(instance)
	v4[instance] = nil

	if not (p and p2 and instance) then
		return
	end

	local v7 = resolveInstrumentStand(instance)
	local pianoAkustikOptimized

	if v7 then
		if v7 then
			v7 = v7.Parent
		end

		local displayModel

		while true do
			if not v7 then
				displayModel = nil
				break
			end

			displayModel = v7:FindFirstChild("DisplayModel")

			if displayModel then
				break
			end

			v7 = v7.Parent
		end

		if displayModel then
			pianoAkustikOptimized = displayModel:FindFirstChild("Piano Akustik Optimized")
		else
			pianoAkustikOptimized = nil
		end
	else
		pianoAkustikOptimized = nil
	end

	if not pianoAkustikOptimized then
		warn("[PianoAnimator] Model Piano (Piano Akustik Optimized) tidak ditemukan utk character ini -- chart-sync dibatalkan")
		return
	end

	local chart = ChartLoader.GetChart(p2, "PianoMIDI")

	if not chart or #chart == 0 then
		return
	end

	local clone = table.clone(chart)
	table.sort(clone, function(a, b): boolean
		return a.Time < b.Time
	end)

	local chordGroups = buildChordGroups(clone, 0.02)
	local pianoSyncOffset = getPianoSyncOffset(p2) -- inferred equivalent call
	task.spawn(function()
		local pianoAmpSound = findPianoAmpSound(instance, p2) -- inferred equivalent call
		local total = 0

		while not pianoAmpSound and v5[instance] == v6 do
			if not instance:IsDescendantOf(game) then
				return
			end

			local v8 = total < 5 and 0.1 or 0.5
			task.wait(v8)
			total += v8
			pianoAmpSound = findPianoAmpSound(instance, p2) -- inferred equivalent call
		end

		if not pianoAmpSound or v5[instance] ~= v6 then
			return
		end

		local v8 = 1
		local expectedSongElapsed = computeExpectedSongElapsed(pianoAmpSound) -- inferred equivalent call

		if expectedSongElapsed then
			local v9 = expectedSongElapsed + pianoSyncOffset

			while v8 <= #chordGroups do
				local chordGroup = chordGroups[v8]

				if v9 < chordGroup.Time then
					break
				end

				local flag = false

				for _, note in ipairs(chordGroup.Notes) do
					if v9 < note.Time + note.Duration then
						flag = true
						break
					end
				end

				if flag then
					local v10 = {}

					for _, note in ipairs(chordGroup.Notes) do
						v10[note] = math.max(0, note.Time + note.Duration - v9)
					end

					triggerChordGroup(instance, pianoAkustikOptimized, chordGroup, v10)
				end

				v8 += 1
			end
		end

		local v9 = 0

		while v5[instance] == v6 and v8 <= #chordGroups do
			local canonicalElapsed, canonicalElapsedAt, v10, v11, parent, v12, vocalistVisualOffset, v13, v14, v15

			if pianoAmpSound.Parent then
				canonicalElapsed = pianoAmpSound:GetAttribute("CanonicalElapsed")
				canonicalElapsedAt = pianoAmpSound:GetAttribute("CanonicalElapsedAt")

				if canonicalElapsed and canonicalElapsedAt then
					v10 = canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
				end

				if v10 then
					if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
						v11 = 0
					else
						parent = pianoAmpSound.Parent
						v12 = parent and parent:FindFirstChild(pianoAmpSound.Name .. "_VocalistMirror")
						vocalistVisualOffset = v12 and v12:GetAttribute("VocalistVisualOffset")
						v11 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
					end

					if math.abs(v11 - v9) >= 0.15 then
						v8 = resyncGroupCursor(
							chordGroups,
							v10 + pianoSyncOffset + v11,
							instance,
							pianoAkustikOptimized,
							false
						)
						v9 = v11
					else
						v13 = v10 + pianoSyncOffset + v11
						v14 = chordGroups[v8]

						if not v4[instance] and not object[instance] and chordGroups[1].Time - 5.2 <= v13 then
							v15 = instance
							beginAvatarPose(v15) -- inferred equivalent call
						end

						if v14.Time <= v13 then
							triggerChordGroup(instance, pianoAkustikOptimized, v14, nil)
							v8 += 1
						else
							task.wait((math.min(0.05, v14.Time - v13)))
						end
					end
				else
					task.wait(0.05)
				end
			else
				pianoAmpSound = findPianoAmpSound(instance, p2) -- inferred equivalent call

				if pianoAmpSound then
					canonicalElapsed = pianoAmpSound:GetAttribute("CanonicalElapsed")
					canonicalElapsedAt = pianoAmpSound:GetAttribute("CanonicalElapsedAt")

					if canonicalElapsed and canonicalElapsedAt then
						v10 = canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
					end

					if v10 then
						if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
							v11 = 0
						else
							parent = pianoAmpSound.Parent
							v12 = parent and parent:FindFirstChild(pianoAmpSound.Name .. "_VocalistMirror")
							vocalistVisualOffset = v12 and v12:GetAttribute("VocalistVisualOffset")
							v11 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
						end

						if math.abs(v11 - v9) >= 0.15 then
							v8 = resyncGroupCursor(
								chordGroups,
								v10 + pianoSyncOffset + v11,
								instance,
								pianoAkustikOptimized,
								false
							)
							v9 = v11
						else
							v13 = v10 + pianoSyncOffset + v11
							v14 = chordGroups[v8]

							if not v4[instance] and not object[instance] and chordGroups[1].Time - 5.2 <= v13 then
								v15 = instance
								beginAvatarPose(v15) -- inferred equivalent call
							end

							if v14.Time <= v13 then
								triggerChordGroup(instance, pianoAkustikOptimized, v14, nil)
								v8 += 1
							else
								task.wait((math.min(0.05, v14.Time - v13)))
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
	end)
end

local v6 = {}

function PianoAnimator.SetAutoChartSyncActive(instance, p, p2)
	v6[instance] = (v6[instance] or 0) + 1
	local v7 = v6[instance]

	forceReleaseAllForCharacter(instance)

	if not (p and p2 and instance) then
		return
	end

	local v8 = if instance then instance.Parent else instance
	local displayModel

	while true do
		if not v8 then
			displayModel = nil
			break
		end

		displayModel = v8:FindFirstChild("DisplayModel")

		if displayModel then
			break
		end

		v8 = v8.Parent
	end

	local pianoAkustikOptimized

	if displayModel then
		pianoAkustikOptimized = displayModel:FindFirstChild("Piano Akustik Optimized")
	else
		pianoAkustikOptimized = nil
	end

	if not pianoAkustikOptimized then
		return
	end

	local chart = ChartLoader.GetChart(p2, "PianoMIDI")

	if not chart or #chart == 0 then
		return
	end

	local clone = table.clone(chart)
	table.sort(clone, function(a, b): boolean
		return a.Time < b.Time
	end)

	local chordGroups = buildChordGroups(clone, 0.02)
	local pianoSyncOffset = getPianoSyncOffset(p2) -- inferred equivalent call
	local v9 = p2 .. "_Piano_Auto"

	local function findAutoAmpSound() -- 3 equivalent calls inferred from this helper
		local soundAnchor = instance:FindFirstChild("SoundAnchor")
		local value = soundAnchor and soundAnchor.Value
		return value and value:FindFirstChild(v9)
	end

	task.spawn(function()
		local autoAmpSound = findAutoAmpSound() -- inferred equivalent call
		local total = 0

		while not autoAmpSound and total < 5 and v6[instance] == v7 do
			task.wait(0.1)
			total += 0.1
			autoAmpSound = findAutoAmpSound() -- inferred equivalent call
		end

		if not autoAmpSound or v6[instance] ~= v7 then
			return
		end

		local v10 = 1
		local expectedSongElapsed = computeExpectedSongElapsed(autoAmpSound) -- inferred equivalent call

		if expectedSongElapsed then
			local v11 = expectedSongElapsed + pianoSyncOffset

			while v10 <= #chordGroups do
				local chordGroup = chordGroups[v10]

				if v11 < chordGroup.Time then
					break
				end

				local flag = false

				for _, note in ipairs(chordGroup.Notes) do
					if v11 < note.Time + note.Duration then
						flag = true
						break
					end
				end

				if flag then
					local v12 = {}

					for _, note in ipairs(chordGroup.Notes) do
						v12[note] = math.max(0, note.Time + note.Duration - v11)
					end

					triggerChordGroup(instance, pianoAkustikOptimized, chordGroup, v12, true)
				end

				v10 += 1
			end
		end

		local v11 = 0

		while v6[instance] == v7 and v10 <= #chordGroups do
			local canonicalElapsed, canonicalElapsedAt, v12, v13, parent, v14, vocalistVisualOffset, v15, v16

			if autoAmpSound.Parent then
				canonicalElapsed = autoAmpSound:GetAttribute("CanonicalElapsed")
				canonicalElapsedAt = autoAmpSound:GetAttribute("CanonicalElapsedAt")

				if canonicalElapsed and canonicalElapsedAt then
					v12 = canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
				end

				if v12 then
					if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
						v13 = 0
					else
						parent = autoAmpSound.Parent
						v14 = parent and parent:FindFirstChild(autoAmpSound.Name .. "_VocalistMirror")
						vocalistVisualOffset = v14 and v14:GetAttribute("VocalistVisualOffset")
						v13 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
					end

					if math.abs(v13 - v11) >= 0.15 then
						v10 = resyncGroupCursor(
							chordGroups,
							v12 + pianoSyncOffset + v13,
							instance,
							pianoAkustikOptimized,
							true
						)
						v11 = v13
					else
						v15 = v12 + pianoSyncOffset + v13
						v16 = chordGroups[v10]

						if v16.Time <= v15 then
							triggerChordGroup(instance, pianoAkustikOptimized, v16, nil, true)
							v10 += 1
						else
							task.wait((math.min(0.05, v16.Time - v15)))
						end
					end
				else
					task.wait(0.05)
				end
			else
				autoAmpSound = findAutoAmpSound() -- inferred equivalent call

				if autoAmpSound then
					canonicalElapsed = autoAmpSound:GetAttribute("CanonicalElapsed")
					canonicalElapsedAt = autoAmpSound:GetAttribute("CanonicalElapsedAt")

					if canonicalElapsed and canonicalElapsedAt then
						v12 = canonicalElapsed + (Workspace:GetServerTimeNow() - canonicalElapsedAt)
					end

					if v12 then
						if LocalPlayer:GetAttribute("VocalistSyncOffsetMs") == nil then
							v13 = 0
						else
							parent = autoAmpSound.Parent
							v14 = parent and parent:FindFirstChild(autoAmpSound.Name .. "_VocalistMirror")
							vocalistVisualOffset = v14 and v14:GetAttribute("VocalistVisualOffset")
							v13 = type(vocalistVisualOffset) ~= "number" and 0 or vocalistVisualOffset
						end

						if math.abs(v13 - v11) >= 0.15 then
							v10 = resyncGroupCursor(
								chordGroups,
								v12 + pianoSyncOffset + v13,
								instance,
								pianoAkustikOptimized,
								true
							)
							v11 = v13
						else
							v15 = v12 + pianoSyncOffset + v13
							v16 = chordGroups[v10]

							if v16.Time <= v15 then
								triggerChordGroup(instance, pianoAkustikOptimized, v16, nil, true)
								v10 += 1
							else
								task.wait((math.min(0.05, v16.Time - v15)))
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
	end)
end

local function resolveFreePlayPianoModel(character)
	local instrumentStand = resolveInstrumentStand(character)

	if not instrumentStand then
		return nil
	end

	local v7

	if instrumentStand then
		v7 = instrumentStand.Parent
	else
		v7 = instrumentStand
	end

	local displayModel

	while true do
		if not v7 then
			displayModel = nil
			break
		end

		displayModel = v7:FindFirstChild("DisplayModel")

		if displayModel then
			break
		end

		v7 = v7.Parent
	end

	local pianoAkustikOptimized

	if displayModel then
		pianoAkustikOptimized = displayModel:FindFirstChild("Piano Akustik Optimized")
	end

	if pianoAkustikOptimized and pianoAkustikOptimized:FindFirstChild("Keys") then
		return pianoAkustikOptimized
	end

	local parent = instrumentStand and instrumentStand.Parent
	local displayModel2

	while true do
		if not parent then
			displayModel2 = nil
			break
		end

		displayModel2 = parent:FindFirstChild("DisplayModel")

		if displayModel2 then
			break
		end

		parent = parent.Parent
	end

	if displayModel2 then
		for _, model in ipairs(displayModel2:GetChildren()) do
			if model:IsA("Model") and model:FindFirstChild("Keys") then
				return model
			end
		end
	end

	return nil
end

local function publishLocalActivity(p)
	if not LocalPlayer or p ~= LocalPlayer.Character then
		return
	end

	local v7 = object2[p]
	LocalPlayer:SetAttribute("PianoFreePlayAt", os.clock())
	LocalPlayer:SetAttribute("PianoFreePlayHeld", v7 ~= nil and next(v7) ~= nil)
end

local function releaseFreePlayHold(p, p2) -- 4 equivalent calls inferred from this helper
	local v7 = object2[p]
	local v8 = v7 and v7[p2]

	if not v8 then
		return
	end

	v7[p2] = nil
	PianoArmPoseAnimator.NoteReleased(p, v8.Hand)
end

local function ensureFreePlayAvatar(instance) -- 2 equivalent calls inferred from this helper
	if instance:FindFirstChild("PianoIKRigV2") then
		return
	end

	local v2_2 = PianoHandAnimator.V2

	if v2_2 and v2_2.GetState and v2_2.GetState(instance) then
		return
	end

	object3[instance] = true
	PianoHandAnimator.Setup(instance)
end

function PianoAnimator.SetFreePlayMode(instance, p)
	if not instance then
		return
	end

	if p == true and not resolveInstrumentStand(instance) then
		p = false
	end

	if p == true then
		if not object[instance] then
			forceReleaseAllForCharacter(instance)
		end

		object[instance] = true
		local v7 = object2[instance]

		if v7 then
			local now = os.clock()

			for k, v8 in pairs(table.clone(v7)) do
				if now - v8.At > 20 then
					releaseFreePlayHold(instance, k) -- inferred equivalent call
				end
			end
		end

		ensureFreePlayAvatar(instance) -- inferred equivalent call
	elseif object[instance] then
		object[instance] = nil
		local v7 = object2[instance]

		if v7 then
			for k in pairs(table.clone(v7)) do
				releaseFreePlayHold(instance, k) -- inferred equivalent call
			end
		end

		publishLocalActivity(instance)

		if object3[instance] and not object4[instance] then
			PianoHandAnimator.Cleanup(instance)
		end

		object3[instance] = nil
	end
end

function PianoAnimator.PlayFreePlayKey(player, value, p)
	local character = player and player.Character

	if not character or type(value) ~= "number" then
		return
	end

	local freePlayPianoModel = resolveFreePlayPianoModel(character)

	if not freePlayPianoModel then
		return
	end

	local note = 36 + (value - 1)
	local v7 = note - 36
	local v8, v9

	if not (v7 < 0 or v7 > 60) then
		v8 = math.floor(v7 / 12) + 1
		v9 = v7 % 12 + 1
	end

	if not v8 then
		return
	end

	local keyPart = getKeyPart(freePlayPianoModel, v8, v9)

	if not (keyPart and cframesByChild[keyPart]) then
		return
	end

	if not object[character] then
		PianoAnimator.SetFreePlayMode(character, true)

		if not object[character] then
			return
		end
	end

	local v10 = p or value
	local v11 = object2[character]

	if not v11 then
		v11 = {}
		object2[character] = v11
	end

	if v11[v10] then
		releaseFreePlayHold(character, v10) -- inferred equivalent call
	end

	local hand = midiNoteToHand(note) -- inferred equivalent call
	v11[v10] = { Hand = hand, KeyPart = keyPart, Note = note, At = os.clock() }
	ensureFreePlayAvatar(character) -- inferred equivalent call
	PianoArmPoseAnimator.NotePressed(character, hand)

	local v12 = {}

	for _, v13 in pairs(v11) do
		if v13.Hand == hand then
			table.insert(v12, {
				keyPart = v13.KeyPart,
				originalCFrame = cframesByChild[v13.KeyPart],
				note = v13.Note,
				hand = v13.Hand
			})
		end
	end

	PianoHandAnimator.UpdateForChordGroup(character, v12)
	publishLocalActivity(character)
end

function PianoAnimator.ReleaseFreePlayKey(player, p)
	local character = player and player.Character

	if not character or p == nil then
		return
	end

	releaseFreePlayHold(character, p) -- inferred equivalent call
	publishLocalActivity(character)
end

function PianoAnimator.Handle(_, _) end

return PianoAnimator