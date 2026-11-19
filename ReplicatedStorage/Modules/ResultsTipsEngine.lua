local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ResultsTipsEngine = {}

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local v2 = { GuitarRhythm = true, GuitarLead = true, Bass = true }

local function round(p) -- 10 equivalent calls inferred from this helper
	return (math.floor(p + 0.5))
end

local function fmtTime(duration) -- 1 equivalent call inferred from this helper
	local v3 = math.max(0, (math.floor(duration)))
	return string.format("%d:%02d", v3 // 60, v3 % 60)
end

local function loadModule(childName) -- 3 equivalent calls inferred from this helper
	local success, result = pcall(function()
		local child = ReplicatedStorage:WaitForChild("Modules", 2):WaitForChild(childName, 2)
		return require(child)
	end)
	return if success then result else nil
end

local v3 = {}

local function wasRecent(id): boolean -- 1 equivalent call inferred from this helper
	for _, v4 in ipairs(v3) do
		if v4 == id then
			return true
		end
	end

	return false
end

local function markShown(id) -- 1 equivalent call inferred from this helper
	table.insert(v3, 1, id)

	while #v3 > 5 do
		table.remove(v3)
	end
end

local function analyze(data)
	local judgements = data.Judgements or {}
	local result = {}

	result.perfect = judgements.Perfect or 0
	result.great = judgements.Great or 0
	result.good = judgements.Good or 0
	result.ok = judgements.OK or 0
	result.miss = judgements.Miss or 0
	result.wrong = judgements.Wrong or data.Wrong or 0
	result.hits = result.perfect + result.great + result.good + result.ok
	result.judged = result.hits + result.miss
	result.accuracy = tonumber(data.Accuracy) or 0
	result.grade = data.Grade
	result.totalNotes = data.TotalNotes or 0
	result.maxCombo = data.MaxCombo or 0
	result.duration = tonumber(data.SongDuration) or 0
	result.instrument = data.Instrument
	result.lanes = tonumber(data.DifficultyLanes)
	result.nativeLanes = tonumber(data.NativeLanes)
	result.isNewPB = data.IsNewPersonalBest == true

	local difficultyTier = data.DifficultyTier
	local tierName = type(difficultyTier) == "string" and difficultyTier or nil
	local v4

	if tierName then
		v4 = tierName:lower() or nil
	end

	result.tierName = tierName
	local usedDifficulty

	if data.IsNewbieMode == true then
		usedDifficulty = true
	elseif v4 == nil or v4 == "" or v4 == "normal" then
		usedDifficulty = false
	else
		usedDifficulty = v4 ~= "natural"
	end

	result.usedDifficulty = usedDifficulty

	if v4 == "medium" then
		result.easier = "Easy"
	elseif v4 == "easy" then
		result.easier = "Baby"
	elseif v4 == "baby" then
		result.easier = nil
	else
		result.easier = "Medium"
	end

	result.hitRate = result.judged > 0 and result.hits / result.judged or 0
	result.perfectShare = result.hits > 0 and result.perfect / result.hits or 0
	result.sloppyShare = result.hits > 0 and (result.good + result.ok) / result.hits or 0
	result.comboFraction = result.totalNotes > 0 and result.maxCombo / result.totalNotes or 0
	result.notesPerSecond = result.duration > 0 and result.totalNotes / result.duration or 0

	result.chords = 0
	result.chordsMissed = 0
	result.singles = 0
	result.singlesMissed = 0
	result.maxMissRun = 0
	result.missRunStart = 0
	result.firstThird = nil
	result.lastThird = nil
	result.comeback = false
	result.stars = 0

	local timelineData = data.TimelineData

	if type(timelineData) ~= "table" then
		return result
	end

	if type(timelineData.Stars) == "table" then
		result.stars = #timelineData.Stars
	end

	local codes = timelineData.Codes
	local times = timelineData.Times

	if type(codes) ~= "string" or type(times) ~= "table" then
		return result
	end

	local v5 = {}

	for i = 1, math.min(#codes, #times) do
		local v6 = string.byte(codes, i) - 48
		local v7 = tonumber(times[i])

		if v7 and v6 >= 1 and v6 <= 5 then
			v5[#v5 + 1] = {
				t = v7,
				hit = v6 ~= 5
			}
		end
	end

	local count = #v5

	if count == 0 then
		return result
	end

	local v6 = 1

	while v6 <= count do
		local v7 = not v5[v6].hit
		local v8 = v6

		while v8 < count and v5[v8 + 1].t - v5[v8].t <= 5 do
			v8 += 1
			v7 = not v5[v8].hit or v7
		end

		if v8 - v6 + 1 >= 2 then
			result.chords += 1

			if v7 then
				result.chordsMissed += 1
			end
		else
			result.singles += 1

			if v7 then
				result.singlesMissed += 1
			end
		end

		v6 = v8 + 1
	end

	local count2 = 0
	local missRunStart = 0

	for i = 1, count do
		if v5[i].hit then
			if count2 >= 5 and i + 9 <= count then
				local count3 = 0

				for j = i, i + 9 do
					if v5[j].hit then
						count3 += 1
					end
				end

				if count3 >= 9 then
					result.comeback = true
				end
			end

			count2 = 0
		else
			if count2 == 0 then
				missRunStart = v5[i].t
			end

			count2 += 1

			if result.maxMissRun < count2 then
				result.maxMissRun = count2
				result.missRunStart = missRunStart
			end
		end
	end

	if not (count >= 60) then
		return result
	end

	local v7 = count // 3
	local count3 = 0
	local count4 = 0

	for i = 1, v7 do
		if v5[i].hit then
			count3 += 1
		end
	end

	for i = count - v7 + 1, count do
		if v5[i].hit then
			count4 += 1
		end
	end

	result.firstThird = count3 / v7
	result.lastThird = count4 / v7

	return result
end

local v4 = {
	"You can rebind your keys anytime in Settings > Controls.",
	"Too many keys at once? The Key dropdown on the HUD lets you play with fewer.",
	"The Difficulty dropdown on the HUD can thin out a chart even mid-song.",
	"Lower the HUD opacity in Settings if it blocks your view of the stage.",
	"Playing solo? Tick \"Fill empty instruments with backing track\" under the Play button in Song List.",
	"If hits feel early or late, run the Audio Offset calibration in Settings > Gameplay.",
	"Guitar and Bass can rebind the vibrato key in Settings > Controls.",
	"Change lane colors and note shape in Settings > Colors.",
	"Keybind Lock stops WASD from walking your character around while you play.",
	"On mobile, button size, spacing and layout live in Settings > Mobile.",
	"Your personal best is saved for every song - go beat it.",
	"Hover the Performance Timeline to inspect any moment of your run.",
	"The MVP buttons below show who led each stat in your band.",
	"Note Speed in Settings changes how fast notes fall toward you.",
	"Free Play lets you jam without a song - find it in the Song List."
}

function ResultsTipsEngine.PickGeneral()
	local v5 = {}

	for i, _ in ipairs(v4) do
		if i ~= ResultsTipsEngine._lastGeneral then
			table.insert(v5, i)
		end
	end

	local lastGeneral = v5[math.random(1, #v5)]
	ResultsTipsEngine._lastGeneral = lastGeneral
	return v4[lastGeneral]
end

function ResultsTipsEngine.Pick(p, options)
	if type(p) ~= "table" or p.IsAutoPlayed then
		return nil
	end

	local v5 = analyze(p)
	local v6 = v5.judged >= 25
	local result2 = loadModule("ResultsTipsTelemetry") -- inferred equivalent call
	local v7, v8

	if result2 and type(result2.GetLast) == "function" then
		v7 = result2.GetLast()
		v8 = result2.GetContext()
	end

	local result3 = loadModule("SettingsState") -- inferred equivalent call

	local function setting(p2, ...)
		if result3 and type(result3[p2]) == "function" then
			local success, result = pcall(result3[p2], ...)

			if success then
				return result
			end
		end

		return nil
	end

	local humans = v8 and v8.Humans or (options or {}).PlayerCount or 1
	local autos = v8 and v8.Autos or nil

	local v9 = setting("GetOpacity", "Hud")
	local v10 = setting("GetNoteSpeedMultiplier") or 1
	local v11 = setting("GetHasCalibratedAudioOffset") == true
	local v12 = setting("GetVibratoKeyLabel")
	local v13 = (type(v12) ~= "string" or v12 == "") and "the vibrato key" or v12
	local v14, v15

	if setting("IsControllerMode") == true then
		v13 = "the right stick"
		v14 = "wiggle"
		v15 = "Wiggle"
	else
		v14 = "hold"
		v15 = "Hold"
	end

	local lanes = v5.lanes or v5.nativeLanes
	local v16 = v2[v5.instrument] == true
	local v17 = nil

	if v16 then
		local v18 = lanes == 2 and setting("GetKeybindTwoKey") or setting("GetKeybindFiveKey")

		if type(v18) == "table" then
			v17 = false

			for _, v19 in ipairs(v18) do
				if v19 == "W" or v19 == "A" or v19 == "S" or v19 == "D" then
					v17 = true
				end
			end
		end
	end

	local v18 = false
	local result4 = loadModule("MovementLockState") -- inferred equivalent call

	if result4 and type(result4.IsEnabled) == "function" then
		local success, result = pcall(result4.IsEnabled)
		v18 = success and result == true
	end

	local v19 = {}
	local function add(tier, id, lines, options2)
		if #lines == 0 then
			return
		end

		local v20 = options2 or {}
		table.insert(v19, {
			Tier = tier,
			Id = id,
			Lines = lines,
			Weight = v20.Weight or 1,
			Soft = v20.Soft == true,
			Kind = v20.Kind or tier <= 2 and "tip" or "fun"
		})
	end

	if v6 and v5.chords >= 8 then
		local v20 = v5.chordsMissed / v5.chords
		local v21 = v5.singles > 0 and v5.singlesMissed / v5.singles or 0

		if v20 >= 0.35 and v21 * 1.6 + 0.05 <= v20 then
			local v22 = round(v20 * 100) -- inferred equivalent call
			local v23

			if v then
				v23 = {
					string.format(
						"Chords are costing you - %d%% of them had a miss. Bigger or better-spaced buttons help: Settings > Mobile.",
						v22
					),
					"Hitting several buttons at once on a touchscreen is tough. Try the Key dropdown on the HUD to play with fewer keys.",
					"Chords keep slipping through. The Difficulty dropdown on the HUD (Medium or Easy) thins them out."
				}
			else
				v23 = {
					string.format(
						"Pressing several keys at once seems to be the problem (%d%% of chords had a miss). Try fewer keys with the Key dropdown on the HUD.",
						v22
					),
					"Chords are slipping away. Move your keys closer together in Settings > Controls, or ease off with the Difficulty dropdown.",
					string.format(
						"%d%% of your chords had a miss. Single notes were fine - a lower Key count might suit your hands better.",
						v22
					)
				}
			end

			if v5.lanes and v5.nativeLanes and v5.lanes < v5.nativeLanes then
				table.insert(
					v23,
					"Even with fewer keys the chords are tough. The Difficulty dropdown (Medium or Easy) can thin them out."
				)
			end

			add(1, "chords", v23, { Weight = 3 })
		end
	end

	if v6 and (v5.grade == "D" or v5.grade == "F" or v5.accuracy < 65) then
		local lines = {}

		if v5.easier then
			table.insert(
				lines,
				string.format(
					"Tough chart! Try the Difficulty dropdown on the HUD and pick %s - you can switch it mid-song.",
					v5.easier
				)
			)
			table.insert(
				lines,
				string.format(
					"That one fought back. Dropping Difficulty to %s keeps the song and trims the note count.",
					v5.easier
				)
			)
		else
			table.insert(
				lines,
				"Even Baby difficulty was a handful - slow the notes down with Note Speed in Settings, or warm up in Free Play."
			)
		end

		if lanes and lanes >= 4 then
			table.insert(
				lines,
				"Fewer keys, fewer problems: the Key dropdown on the HUD lets you play with 2 or 3 keys."
			)
		end

		add(1, "lowerDifficulty", lines, { Weight = 3 })
	end

	if v6 and v10 >= 1.25 and v5.hitRate < 0.8 then
		add(1, "noteSpeedHigh", {
			string.format("Notes are falling at %.1fx speed. If it feels frantic, lower Note Speed in Settings.", v10),
			string.format(
				"Note Speed is cranked to %.1fx - ease it down in Settings and see if the misses calm down.",
				v10
			)
		})
	end

	if v6 and v5.maxMissRun >= 10 then
		local v20 = fmtTime(v5.missRunStart / 100) -- inferred equivalent call
		add(
			1,
			"missRun",
			{
				string.format(
					"You lost the thread around %s - %d misses in a row. Slow the notes or ease the Difficulty to find your footing.",
					v20,
					v5.maxMissRun
				),
				string.format(
					"A rough stretch near %s (%d misses in a row). Everyone drops the beat sometimes - the Difficulty dropdown can help you hang on.",
					v20,
					v5.maxMissRun
				)
			},
			{ Weight = 2 }
		)
	end

	if v6 and v5.firstThird and v5.lastThird and v5.firstThird - v5.lastThird >= 0.2 then
		add(1, "fatigue", {
			string.format(
				"Strong start, but the last stretch slipped (%d%% of notes hit early, %d%% at the end). Shake out your hands - or ease the Difficulty on long songs.",
				round(v5.firstThird * 100), -- inferred equivalent call
				round(v5.lastThird * 100) -- inferred equivalent call
			),
			"Your hands ran out of gas toward the end. A short stretch between songs works wonders."
		})
	end

	if v6 and v5.hits >= 40 and v5.sloppyShare >= 0.45 then
		if v11 then
			add(1, "nudgeOffset", {
				"Your timing is landing a little loose. Try nudging Audio Offset a few ms in Settings > Gameplay - Bluetooth audio adds delay."
			})
		else
			add(
				1,
				"calibrate",
				{
					"Lots of Good/OK hits - your audio might be offset. Run the Audio Offset calibration in Settings > Gameplay.",
					string.format(
						"%d%% of your hits landed as Good/OK. Calibrating Audio Offset in Settings > Gameplay often fixes that.",
						round(v5.sloppyShare * 100) -- inferred equivalent call
					)
				},
				{ Weight = 2 }
			)
		end
	end

	if v6 and v5.wrong >= 20 and v5.hits > 0 and v5.wrong / v5.hits >= 0.25 then
		local v20

		if v then
			v20 = { string.format(
					"%d taps had no note nearby. Space the buttons out with Button Spacing or Edit Layout in Settings > Mobile.",
					v5.wrong
				) }
		else
			v20 = {
				string.format(
					"%d keypresses had no note nearby. Check your keybinds fit your hand position in Settings > Controls, or try fewer keys.",
					v5.wrong
				),
				string.format(
					"Plenty of stray presses (%d with no note). Fewer keys or a more comfortable layout in Settings > Controls can calm the fingers.",
					v5.wrong
				)
			}
		end

		add(1, "strayPresses", v20, { Weight = 2 })
	end

	if v7 and not v18 and (v7.MoveSeconds >= 8 or v7.MoveDistance >= 25) and v17 ~= false then
		local v20 = round(v7.MoveDistance) -- inferred equivalent call
		local v21

		if v17 == true then
			v21 = {
				string.format(
					"Your character wandered about %d studs while you played - your keybinds include WASD. Turn on Keybind Lock (the switch while playing).",
					v20
				),
				string.format(
					"You drifted ~%d studs mid-song because WASD doubles as movement. Keybind Lock fixes that, or rebind in Settings > Controls.",
					v20
				)
			}
		else
			v21 = { string.format(
					"You covered ~%d studs mid-song. If your keybinds use WASD, turn on Keybind Lock (the switch while playing).",
					v20
				) }
		end

		add(1, "wander", v21, {
			Weight = 2,
			Soft = v17 ~= true
		})
	end

	if v7 and v6 and (v7.TypingSeconds >= 10 or v7.ChatMessages >= 4) and v5.hitRate < 0.9 then
		local v20 = round(v7.TypingSeconds) -- inferred equivalent call
		add(
			1,
			"typing",
			{
				string.format(
					"About %ds went into typing mid-song, and some notes slipped past. Chat after the song and your fingers stay on the keys.",
					v20
				),
				"Chat is fun, but notes don't wait for you to hit send. Save the typing for the results screen."
			},
			{ Soft = true }
		)
	end

	if autos == 0 and humans <= 3 then
		add(
			1,
			"fillBackingTrack",
			humans <= 1 and {
				"Playing solo? Tick \"Fill empty instruments with backing track\" under the Play button in Song List - the rest of the band joins in.",
				"Feels quiet up there? Under the Play button in Song List, \"Fill empty instruments with backing track\" brings the missing band members.",
				"A one-person band gets way more fun with \"Fill empty instruments with backing track\" (under Play in Song List)."
			} or {
				"Band not full yet? \"Fill empty instruments with backing track\" under the Play button in Song List covers the missing parts.",
				"Short on bandmates? Tick \"Fill empty instruments with backing track\" under Play in Song List and the empty slots get filled."
			},
			{ Weight = 3, Soft = true }
		)
	end

	if v9 and v9 >= 0.95 then
		add(
			2,
			"hudOpacity",
			{
				"HUD in your way? Lower the HUD opacity in Settings and the stage shines through.",
				"Want a clearer view of the stage? The HUD opacity sliders in Settings make the overlays see-through."
			},
			{
				Weight = v5.accuracy < 85 and 3 or 1
			}
		)
	elseif v9 and v9 <= 0.4 and v5.hitRate < 0.8 then
		add(2, "hudFaint", {
			"Your HUD is pretty faint. If notes or counters are hard to read, raise the HUD opacity in Settings."
		})
	end

	if not v11 and v5.accuracy < 92 and v6 then
		add(2, "calibrateGeneral", {
			"Never calibrated your Audio Offset? One quick run in Settings > Gameplay can tighten your timing."
		})
	end

	if v then
		add(
			2,
			"mobileLayout",
			{
				"Buttons too small or too close? Resize and move them in Settings > Mobile (Button Size, Spacing, Edit Layout).",
				"Tap targets feel off? Edit Layout in Settings > Mobile lets you drag every button where your thumbs like it."
			},
			{
				Weight = v5.accuracy < 90 and 3 or 1
			}
		)
	else
		add(
			2,
			"rebind",
			{
				"Keys feeling awkward? Rebind them anytime in Settings > Controls.",
				"Your keys, your rules - Settings > Controls lets you remap every lane."
			},
			{
				Weight = v5.accuracy < 90 and 2 or 1
			}
		)
	end

	if v6 and v5.accuracy < 85 then
		add(2, "colors", { "Notes blending together? Try different lane colors or note shapes in Settings > Colors." })
	end

	if v6 and v10 <= 0.8 and v5.accuracy >= 92 then
		add(2, "speedUp", {
			string.format("Comfortable at %.1fx? Raising Note Speed in Settings adds a fresh challenge.", v10)
		})
	end

	if v16 and v7 and v5.judged >= 40 then
		local vibratoPresses = v7.VibratoPresses

		if vibratoPresses == 0 then
			add(
				2,
				"noVibrato",
				{
					string.format("Your strings are begging for some vibration - %s %s on long notes.", v14, v13),
					string.format("Not one vibrato this song. %s %s on a sustained note and let it sing.", v15, v13),
					"Straight as a ruler - no vibrato at all. Long notes love a little shake."
				},
				{ Weight = 3, Kind = "tip" }
			)
		elseif vibratoPresses <= 4 then
			add(
				2,
				"littleVibrato",
				{ string.format(
						"Just a pinch of vibrato (%d). Let more long notes wobble with %s.",
						vibratoPresses,
						v13
					) },
				{ Kind = "tip" }
			)
		end
	end

	if v6 and v5.miss == 0 then
		add(
			3,
			"noMiss",
			{
				"Zero misses. Not a single one.",
				"Flawless - the notes never stood a chance.",
				"Not one miss all song. Are you even human?"
			},
			{ Weight = 3 }
		)
	end

	if v6 and v5.comboFraction >= 0.9 then
		add(
			3,
			"comboKing",
			{
				string.format("A %d-note combo out of %d. That's basically unbroken.", v5.maxCombo, v5.totalNotes),
				"Your combo barely blinked. Call it Combo Royalty."
			},
			{ Weight = 2 }
		)
	end

	if v6 and v5.accuracy >= 97 then
		add(3, "studioGrade", {
			string.format("%.1f%% accuracy - that's studio-grade timing.", v5.accuracy),
			"Timing so tight a metronome would ask for lessons."
		})
	end

	if v6 and v5.hits >= 40 and v5.perfectShare >= 0.7 then
		add(3, "perfectShare", {
			string.format("%d%% of your hits were Perfect. Metronome who?", round(v5.perfectShare * 100)), -- inferred equivalent call
			"Perfect after Perfect after Perfect. Smooth operator."
		})
	end

	if v6 and not v5.usedDifficulty and v5.accuracy >= 92 then
		add(3, "readyForMore", {
			"Natural difficulty and still this clean? Time to try a harder song from the Song List.",
			"You're cruising. Maybe pick something nastier next time?"
		})
	elseif v6 and v5.usedDifficulty and v5.accuracy >= 92 then
		add(3, "stepUp", {
			string.format("Clean run on %s! Ready to step the Difficulty up a notch?", v5.tierName or "an easier mode")
		})
	end

	if v5.comeback then
		add(
			3,
			"comeback",
			{
				"That comeback after the rough patch was real. Respect.",
				"You dropped a few, then picked it right back up. That's the stuff."
			},
			{ Weight = 2 }
		)
	end

	if v5.isNewPB then
		add(3, "newPB", {
			"A new personal best. The grind is paying off.",
			"New record - past you is officially in the rearview."
		})
	end

	if v5.stars >= 3 then
		add(3, "starPower", { string.format("Star Power fired %d times. You like it loud.", v5.stars) })
	end

	if v5.duration >= 300 then
		add(3, "marathon", { string.format("A %s marathon, and you saw it through.", fmtTime(v5.duration)) })
	end

	if v5.notesPerSecond >= 6 then
		add(3, "fastChart", {
			string.format("That chart threw about %.1f notes per second at you. Fingers okay?", v5.notesPerSecond)
		})
	end

	if v6 and v10 >= 1.5 and v5.accuracy >= 85 then
		add(3, "speedDemon", { string.format("Note Speed at %.1fx and still hitting? Speed demon.", v10) })
	end

	if autos and autos > 0 and humans <= 1 then
		add(3, "oneManBand", { "You and a backing track - a proper one-person band." })
	end

	if humans >= 3 then
		add(3, "fullBand", {
			"Full band energy out there tonight.",
			"A real band on stage. This is what it's all about."
		})
	end

	if v7 then
		if v16 and v7.Duration >= 30 then
			local v20 = v7.Duration > 0 and v7.VibratoHeldSeconds / v7.Duration or 0

			if v7.VibratoPresses >= 30 or v20 >= 0.2 then
				add(
					3,
					"vibratoLover",
					{
						string.format("%d vibrato presses - officially a Vibrato Virtuoso.", v7.VibratoPresses),
						string.format(
							"Your fret hand never stood still (%d vibratos). Wobble Wizard.",
							v7.VibratoPresses
						),
						string.format("Vibrato everywhere - %d presses. Your amp is blushing.", v7.VibratoPresses),
						"Lord of the Wobble, ruler of the sustained note."
					},
					{ Weight = 4 }
				)
			end
		end

		if v7.MoveSeconds >= 8 and (v18 or v17 == false) then
			add(3, "stagePerformer", {
				string.format(
					"You covered about %d studs while playing. A true stage performer.",
					round(v7.MoveDistance) -- inferred equivalent call
				),
				"Playing AND moving around the stage? Show-off."
			})
		end

		if v7.Jumps >= 8 then
			add(3, "jumper", {
				string.format("%d jumps mid-song. The stage floor filed a complaint.", v7.Jumps),
				string.format("Jumped %d times while playing - pure rock-and-roll energy.", v7.Jumps)
			})
		end

		if v7.TypingSeconds >= 8 and v5.hitRate >= 0.9 then
			add(3, "multitask", {
				string.format(
					"About %ds of typing mid-song and still this clean. Multitasking champion.",
					round(v7.TypingSeconds) -- inferred equivalent call
				)
			})
		end

		if v7.ChatMessages >= 3 and v5.hitRate >= 0.9 then
			add(3, "chatty", {
				string.format("%d chat messages mid-song. The crowd is lively tonight.", v7.ChatMessages)
			})
		end

		if v7.LongestIdle >= 30 then
			add(3, "longPause", {
				string.format(
					"You went about %ds without pressing a thing. Hope that was a solo break.",
					round(v7.LongestIdle) -- inferred equivalent call
				)
			})
		end

		if v7.Duration >= 120 and v7.MoveSeconds < 1 and v7.Jumps == 0 and v5.accuracy >= 70 then
			add(3, "statue", { "Rock solid - you barely moved a stud the whole song." }, {
				Weight = 0.5
			})
		end
	end

	if #v19 == 0 then
		return nil
	end

	local v20 = {}

	for _, v21 in ipairs(v19) do
		if not wasRecent(v21.Id) then -- inferred equivalent call
			table.insert(v20, v21)
		end
	end

	if #v20 > 0 then
		v19 = v20
	end

	local v21 = {}
	local v22 = {}

	for _, v23 in ipairs(v19) do
		if v23.Tier == 1 and not (v23.Soft and math.random() < 0.5) then
			table.insert(v22, v23)
		else
			table.insert(v21, v23)
		end
	end

	v22 = (not (#v22 > 0) or #v21 ~= 0 and not (math.random() < 0.85)) and #v21 > 0 and v21 or v22
	local total = 0

	for _, v23 in ipairs(v22) do
		total += v23.Weight * (v23.Tier == 2 and 1.5 or 1)
	end

	local v23 = math.random() * total
	local v24 = v22[#v22]

	for _, v25 in ipairs(v22) do
		v23 -= v25.Weight * (v25.Tier == 2 and 1.5 or 1)

		if v23 <= 0 then
			v24 = v25
			break
		end
	end

	markShown(v24.Id) -- inferred equivalent call
	return v24.Lines[math.random(1, #v24.Lines)], v24.Kind
end

return ResultsTipsEngine