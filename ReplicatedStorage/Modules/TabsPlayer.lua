local RunService = game:GetService("RunService")

local TabsSong = require(script.Parent.TabsSong)
local InputRouter = require(script.Parent.InputRouter)

local TabsPlayer = {}

local controller = nil
local v = true

local track = nil
local v2 = nil
local state = "Stopped"
local v3 = 0
local v4 = 1
local speed = 1
local v5 = nil
local v6 = nil
local v7 = {}
local heartbeatConnection = nil
local v8 = {}
local metronome = false
local countIn = false
local v9 = false
local lastTime = 0
local v10 = nil
local v11 = {}
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil

local practice = false
local v16 = nil
local v17 = 1
local v18 = false
local set = {}
local nowsByLaneCode = {}

local function getController()
	if controller then
		return controller
	end

	local success, result = pcall(function()
		return require(script.Parent.FreePlayController)
	end)

	if success then
		controller = result
	end

	return controller
end

local function notify()
	for _, callback in pairs(v8) do
		task.spawn(callback, state)
	end
end

local function buildEvents(data)
	local set2 = {}
	local v19 = {}

	if data.K then
		local v20 = {}

		for i = 1, data.N do
			local v21 = data.L[i]
			v20[v21] = v20[v21] or {}
			table.insert(v20[v21], i)
		end

		for _, list in pairs(v20) do
			table.sort(list, function(a, b): boolean
				return data.T[a] < data.T[b]
			end)
			local v21 = nil

			for _, item in ipairs(list) do
				local v22 = v21 and (v19[v21] or data.T[v21] + data.D[v21])

				if data.K[item] == "t" and v21 and data.T[item] - v22 <= 96 then
					set2[item] = true
					v19[v21] = math.max(v22, data.T[item] + data.D[item])
				else
					v21 = item
				end
			end
		end
	end

	local v20 = table.create(data.N * 2)
	local barMap = data.BarMap

	if data.Tones and barMap then
		for _, tone in ipairs(data.Tones) do
			v20[#v20 + 1] = {
				math.floor(barMap.StartBeat(tone.bar) * data.Res + 0.5),
				2,
				0,
				tone.name
			}
		end
	end

	for i = 1, data.N do
		if set2[i] then
			continue
		end

		local v21 = data.K and data.K[i]
		v20[#v20 + 1] = { data.T[i], 1, data.L[i], v21 }

		if v21 ~= "x" then
			v20[#v20 + 1] = { v19[i] or data.T[i] + data.D[i], 0, data.L[i] }
		end
	end

	table.sort(v20, function(a, b): boolean
		if a[1] == b[1] then
			return (a[2] == 2 and -1 or a[2]) < (b[2] == 2 and -1 or b[2])
		end

		return a[1] < b[1]
	end)

	local events = {
		time = {},
		kind = {},
		lane = {},
		k = {},
		n = #v20
	}

	for i, v21 in ipairs(v20) do
		local time = events.time
		local kind = events.kind
		local lane = events.lane
		local k = events.k
		local v22 = v21[1]
		local v23 = v21[2]
		local v24 = v21[3]
		local v25 = v21[4]
		time[i] = v22
		kind[i] = v23
		lane[i] = v24
		k[i] = v25
	end

	return events
end

local function firstEventAtOrAfter(p)
	local v19 = v2.n + 1
	local v20 = 1

	while v20 < v19 do
		local v21 = (v20 + v19) // 2

		if v2.time[v21] < p then
			v20 = v21 + 1
		else
			v19 = v21
		end
	end

	return v20
end

local function buildGroups(data)
	local v19 = nil
	local groups = {}

	for i = 1, data.N do
		if not v19 or v19.t ~= data.T[i] then
			v19 = { t = data.T[i], lanes = {}, set = {} }
			groups[#groups + 1] = v19
		end

		v19.lanes[#v19.lanes + 1] = data.L[i]
		v19.set[data.L[i]] = true
	end

	return groups
end

local function firstGroupAtOrAfter(p)
	if not v16 then
		return 1
	end

	local v19 = #v16 + 1
	local v20 = 1

	while v20 < v19 do
		local v21 = (v20 + v19) // 2

		if v16[v21].t < p then
			v20 = v21 + 1
		else
			v19 = v21
		end
	end

	return v20
end

local function groupComplete(p): boolean -- 2 equivalent calls inferred from this helper
	for k in pairs(p.set) do
		if not set[k] then
			return false
		end
	end

	return true
end

local function releaseLane(p)
	if not v7[p] then
		return
	end

	v7[p] = nil

	if not controller then
		local success, result = pcall(function()
			return require(script.Parent.FreePlayController)
		end)

		if success then
			controller = result
		end
	end

	local v19 = controller

	if v19 then
		local splitLane, v20 = TabsSong.SplitLane(p)
		pcall(v19.Release, splitLane, v20)
	end
end

local function releaseAll()
	local v19 = {}

	for k in pairs(v7) do
		v19[#v19 + 1] = k
	end

	for _, v20 in ipairs(v19) do
		if not v7[v20] then
			continue
		end

		v7[v20] = nil

		if not controller then
			local success, result = pcall(function()
				return require(script.Parent.FreePlayController)
			end)

			if success then
				controller = result
			end
		end

		local v21 = controller

		if not v21 then
			continue
		end

		local splitLane, v22 = TabsSong.SplitLane(v20)
		pcall(v21.Release, splitLane, v22)
	end
end

local count = 0
local function pressLane(p)
	count += 1

	local function fn()
		return require(script.Parent.FreePlayController)
	end

	if v7[p] and v7[p] then
		v7[p] = nil

		if not controller then
			local success, result = pcall(fn)

			if success then
				controller = result
			end
		end

		local v19 = controller

		if v19 then
			local splitLane, v20 = TabsSong.SplitLane(p)
			pcall(v19.Release, splitLane, v20)
		end
	end

	if not controller then
		local success, result = pcall(fn)

		if success then
			controller = result
		end
	end

	local v19 = controller

	if v19 then
		local splitLane, v20 = TabsSong.SplitLane(p)
		pcall(v19.Press, splitLane, v20)
		v7[p] = true
	end
end

local function playDeadNote(p)
	count += 1

	local function fn()
		return require(script.Parent.FreePlayController)
	end

	if v7[p] and v7[p] then
		v7[p] = nil

		if not controller then
			local success, result = pcall(fn)

			if success then
				controller = result
			end
		end

		local v19 = controller

		if v19 then
			local splitLane, v20 = TabsSong.SplitLane(p)
			pcall(v19.Release, splitLane, v20)
		end
	end

	if not controller then
		local success, result = pcall(fn)

		if success then
			controller = result
		end
	end

	local v19 = controller

	if v19 then
		local splitLane, v20 = TabsSong.SplitLane(p)
		pcall(v19.Press, splitLane, v20)
		v7[p] = true
	end

	local v20 = count
	task.delay(0.04, function()
		local v21 = p

		local function fn2()
			return require(script.Parent.FreePlayController)
		end

		if v7[v21] then
			v7[v21] = nil

			if not controller then
				local success, result = pcall(fn2)

				if success then
					controller = result
				end
			end

			local v22 = controller

			if v22 then
				local splitLane, v23 = TabsSong.SplitLane(v21)
				pcall(v22.Release, splitLane, v23)
			end
		end

		if count == v20 then
			if not controller then
				local success, result = pcall(fn2)

				if success then
					controller = result
				end
			end

			local v22 = controller

			if v22 and v22.MuteAll then
				pcall(v22.MuteAll)
			end
		end
	end)
end

local function applyTone(value)
	if not controller then
		local success, result = pcall(function()
			return require(script.Parent.FreePlayController)
		end)

		if success then
			controller = result
		end
	end

	local v19 = controller

	if v19 and v19.SetTone and type(value) == "string" then
		if v15 == nil and v19.GetCurrentTone then
			v15 = v19.GetCurrentTone() or false
		end

		pcall(v19.SetTone, value)
	end
end

local function toneAtUnits(p)
	local tones = track and track.Tones
	local barMap = track and track.BarMap

	if not tones or #tones == 0 or not barMap then
		return nil
	end

	local name = nil

	for _, tone in ipairs(tones) do
		if barMap.StartBeat(tone.bar) * track.Res <= p then
			name = tone.name
		else
			break
		end
	end

	return name
end

local function restoreTone()
	local v19 = v15
	v15 = nil

	if v19 then
		if not controller then
			local success, result = pcall(function()
				return require(script.Parent.FreePlayController)
			end)

			if success then
				controller = result
			end
		end

		local v20 = controller

		if v20 and v20.SetTone then
			pcall(v20.SetTone, v19)
		end
	end
end

local function disconnectStep() -- 5 equivalent calls inferred from this helper
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function setState(p)
	if state ~= p then
		state = p

		pcall(function()
			if RunService:IsClient() then
				local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
				PlayerLoadingState.ReportTabsPlaying(p == "Playing" and not v9)
			end
		end)
		notify()
	end
end

local function currentBpm() -- 1 equivalent call inferred from this helper
	local barMap = track.BarMap
	return barMap and barMap.BpmAtBeat(v3 / track.Res) or track.Bpm
end

local function unitsPerSecond() -- 4 equivalent calls inferred from this helper
	return currentBpm() / 60 * track.Res * speed -- inferred equivalent call
end

local function nextClickAfter(p)
	local barMap = track and track.BarMap

	if not barMap or p < 0 then
		return math.floor(p + 1e-6) + 1
	end

	local barAtBeat = barMap.BarAtBeat(p + 1e-6)
	local v19 = barMap.StartBeat(barAtBeat)
	local v20 = v19 + math.floor(p + 1e-6 - v19) + 1
	local v21 = barMap.StartBeat(barAtBeat + 1)
	return if v21 - 1e-6 <= v20 then v21 else v20
end

function TabsPlayer.Step(p)
	if state ~= "Playing" or not track then
		return
	end

	local v19 = math.min(p, 0.25)
	local v20 = v3
	v3 = v20 + v19 * unitsPerSecond() -- inferred equivalent call
	lastTime = os.clock()

	if metronome then
		if v12 and v14 and v3 < v13 then
			while v12 + v14 * track.Res <= v3 do
				local v21 = v14
				v14 += 1

				for _, callback in pairs(v11) do
					task.spawn(callback, v21 == 0, v21)
				end
			end
		end

		local v21 = v3 / track.Res

		if v10 == nil then
			v10 = v21
		end

		local barMap = track.BarMap

		local v22 = nextClickAfter(v10)
		local count2 = 0

		while v22 <= v21 and count2 < 64 do
			count2 += 1
			v10 = v22
			local v23

			if barMap and v10 >= 0 then
				v23 = v10 - barMap.StartBeat(barMap.BarAtBeat(v10 + 1e-6))
			else
				local v24 = math.max(1, (math.floor((barMap and barMap.BeatsOfBar(1) or track.BeatsPerBar) + 0.5)))
				v23 = (math.floor(v10 + 1e-6) % v24 + v24) % v24
			end

			local v24 = v23 < 0.0001

			for _, callback in pairs(v11) do
				task.spawn(callback, v24, v23)
			end

			v22 = nextClickAfter(v10)
		end
	else
		v10 = nil
	end

	local v21, v22, success, result, v23, success2, result2, v24, v25, v26, success3, result3, v27, v28, v29, v30, success4, result4, v31, v32, v33, success5, result5, v34, v35, v36, success6, result6, v37, v38, v39, v40, v41, success7, result7, v42, v43, success8, result8, v44, v45

	local function fn()
		return require(script.Parent.FreePlayController)
	end

	if practice and v16 then
		local v46 = v16[v17]

		if v46 and v18 then
			if not groupComplete(v46) then -- inferred equivalent call
				v3 = v46.t
				return
			end

			v17 += 1
			v18 = false
			set = {}
			v46 = v16[v17]
		end

		if v46 and not v18 and v3 >= v46.t then
			local now = os.clock()
			set = {}

			for k in pairs(v46.set) do
				if nowsByLaneCode[k] and now - nowsByLaneCode[k] <= 0.3 then
					set[k] = true
				end
			end

			if groupComplete(v46) then -- inferred equivalent call
				v17 += 1
				set = {}

				while v4 <= v2.n and v2.time[v4] <= v3 do
					v21 = v2.lane[v4]

					if v2.kind[v4] == 2 then
						if not v9 then
							v22 = v2.k[v4]

							if not controller then
								success, result = pcall(fn)

								if success then
									controller = result
								end
							end

							v23 = controller

							if v23 and v23.SetTone and type(v22) == "string" then
								if v15 == nil and v23.GetCurrentTone then
									v15 = v23.GetCurrentTone() or false
								end

								pcall(v23.SetTone, v22)
							end
						end
					elseif not (v9 or practice) then
						if v2.kind[v4] == 1 then
							if v2.k[v4] == "x" then
								count += 1

								if v7[v21] and v7[v21] then
									v7[v21] = nil

									if not controller then
										success2, result2 = pcall(fn)

										if success2 then
											controller = result2
										end
									end

									v24 = controller

									if v24 then
										v25, v26 = TabsSong.SplitLane(v21)
										pcall(v24.Release, v25, v26)
									end
								end

								if not controller then
									success3, result3 = pcall(fn)

									if success3 then
										controller = result3
									end
								end

								v27 = controller

								if v27 then
									v28, v29 = TabsSong.SplitLane(v21)
									pcall(v27.Press, v28, v29)
									v7[v21] = true
								end

								v30 = count
								local v47 = v21
								local v48 = v30
								task.delay(0.04, function()
									local v49 = v47

									local function fn2()
										return require(script.Parent.FreePlayController)
									end

									if v7[v49] then
										v7[v49] = nil

										if not controller then
											local success9, result9 = pcall(fn2)

											if success9 then
												controller = result9
											end
										end

										local v50 = controller

										if v50 then
											local v51, v52 = TabsSong.SplitLane(v49)
											pcall(v50.Release, v51, v52)
										end
									end

									if count == v48 then
										if not controller then
											local success9, result9 = pcall(fn2)

											if success9 then
												controller = result9
											end
										end

										local v50 = controller

										if v50 and v50.MuteAll then
											pcall(v50.MuteAll)
										end
									end
								end)
							else
								count += 1

								if v7[v21] and v7[v21] then
									v7[v21] = nil

									if not controller then
										success4, result4 = pcall(fn)

										if success4 then
											controller = result4
										end
									end

									v31 = controller

									if v31 then
										v32, v33 = TabsSong.SplitLane(v21)
										pcall(v31.Release, v32, v33)
									end
								end

								if not controller then
									success5, result5 = pcall(fn)

									if success5 then
										controller = result5
									end
								end

								v34 = controller

								if v34 then
									v35, v36 = TabsSong.SplitLane(v21)
									pcall(v34.Press, v35, v36)
									v7[v21] = true
								end
							end
						elseif v7[v21] then
							v7[v21] = nil

							if not controller then
								success6, result6 = pcall(fn)

								if success6 then
									controller = result6
								end
							end

							v37 = controller

							if v37 then
								v38, v39 = TabsSong.SplitLane(v21)
								pcall(v37.Release, v38, v39)
							end
						end
					end

					v4 += 1

					if not (v6 and v2.time[v4]) then
						continue
					end

					v40 = v2.time[v4]

					if v6 <= v40 then
						break
					end
				end

				if v6 and v6 <= v3 then
					releaseAll()
					v3 = v5 or 0
					v4 = firstEventAtOrAfter(v3)
					v17 = firstGroupAtOrAfter(v3)
					v18 = false
					set = {}
					v10 = v3 / track.Res - 0.0001

					v41 = not v9 and toneAtUnits(v3)

					if v41 then
						if not controller then
							success7, result7 = pcall(fn)

							if success7 then
								controller = result7
							end
						end

						v42 = controller

						if v42 and v42.SetTone and type(v41) == "string" then
							if v15 == nil and v42.GetCurrentTone then
								v15 = v42.GetCurrentTone() or false
							end

							pcall(v42.SetTone, v41)
						end
					end
				elseif v9 and v3 >= track.EndUnits or not v9 and v4 > v2.n then
					releaseAll()
					disconnectStep() -- inferred equivalent call
					v3 = 0
					v4 = 1
					v10 = nil
					v43 = v15
					v15 = nil

					if v43 then
						if not controller then
							success8, result8 = pcall(fn)

							if success8 then
								controller = result8
							end
						end

						v44 = controller

						if v44 and v44.SetTone then
							pcall(v44.SetTone, v43)
						end
					end

					if state ~= "Stopped" then
						state = "Stopped"

						v45 = "Stopped"
						pcall(function()
							if RunService:IsClient() then
								local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
								PlayerLoadingState.ReportTabsPlaying(v45 == "Playing" and not v9)
							end
						end)
						notify()
					end
				end
			else
				v18 = true
				v3 = v46.t
			end
		else
			while v4 <= v2.n and v2.time[v4] <= v3 do
				v21 = v2.lane[v4]

				if v2.kind[v4] == 2 then
					if not v9 then
						v22 = v2.k[v4]

						if not controller then
							success, result = pcall(fn)

							if success then
								controller = result
							end
						end

						v23 = controller

						if v23 and v23.SetTone and type(v22) == "string" then
							if v15 == nil and v23.GetCurrentTone then
								v15 = v23.GetCurrentTone() or false
							end

							pcall(v23.SetTone, v22)
						end
					end
				elseif not (v9 or practice) then
					if v2.kind[v4] == 1 then
						if v2.k[v4] == "x" then
							count += 1

							if v7[v21] and v7[v21] then
								v7[v21] = nil

								if not controller then
									success2, result2 = pcall(fn)

									if success2 then
										controller = result2
									end
								end

								v24 = controller

								if v24 then
									v25, v26 = TabsSong.SplitLane(v21)
									pcall(v24.Release, v25, v26)
								end
							end

							if not controller then
								success3, result3 = pcall(fn)

								if success3 then
									controller = result3
								end
							end

							v27 = controller

							if v27 then
								v28, v29 = TabsSong.SplitLane(v21)
								pcall(v27.Press, v28, v29)
								v7[v21] = true
							end

							v30 = count
							local v47 = v21
							local v48 = v30
							task.delay(0.04, function()
								local v49 = v47

								local function fn2()
									return require(script.Parent.FreePlayController)
								end

								if v7[v49] then
									v7[v49] = nil

									if not controller then
										local success9, result9 = pcall(fn2)

										if success9 then
											controller = result9
										end
									end

									local v50 = controller

									if v50 then
										local v51, v52 = TabsSong.SplitLane(v49)
										pcall(v50.Release, v51, v52)
									end
								end

								if count == v48 then
									if not controller then
										local success9, result9 = pcall(fn2)

										if success9 then
											controller = result9
										end
									end

									local v50 = controller

									if v50 and v50.MuteAll then
										pcall(v50.MuteAll)
									end
								end
							end)
						else
							count += 1

							if v7[v21] and v7[v21] then
								v7[v21] = nil

								if not controller then
									success4, result4 = pcall(fn)

									if success4 then
										controller = result4
									end
								end

								v31 = controller

								if v31 then
									v32, v33 = TabsSong.SplitLane(v21)
									pcall(v31.Release, v32, v33)
								end
							end

							if not controller then
								success5, result5 = pcall(fn)

								if success5 then
									controller = result5
								end
							end

							v34 = controller

							if v34 then
								v35, v36 = TabsSong.SplitLane(v21)
								pcall(v34.Press, v35, v36)
								v7[v21] = true
							end
						end
					elseif v7[v21] then
						v7[v21] = nil

						if not controller then
							success6, result6 = pcall(fn)

							if success6 then
								controller = result6
							end
						end

						v37 = controller

						if v37 then
							v38, v39 = TabsSong.SplitLane(v21)
							pcall(v37.Release, v38, v39)
						end
					end
				end

				v4 += 1

				if not (v6 and v2.time[v4]) then
					continue
				end

				v40 = v2.time[v4]

				if v6 <= v40 then
					break
				end
			end

			if v6 and v6 <= v3 then
				releaseAll()
				v3 = v5 or 0
				v4 = firstEventAtOrAfter(v3)
				v17 = firstGroupAtOrAfter(v3)
				v18 = false
				set = {}
				v10 = v3 / track.Res - 0.0001

				v41 = not v9 and toneAtUnits(v3)

				if v41 then
					if not controller then
						success7, result7 = pcall(fn)

						if success7 then
							controller = result7
						end
					end

					v42 = controller

					if v42 and v42.SetTone and type(v41) == "string" then
						if v15 == nil and v42.GetCurrentTone then
							v15 = v42.GetCurrentTone() or false
						end

						pcall(v42.SetTone, v41)
					end
				end
			elseif v9 and v3 >= track.EndUnits or not v9 and v4 > v2.n then
				releaseAll()
				disconnectStep() -- inferred equivalent call
				v3 = 0
				v4 = 1
				v10 = nil
				v43 = v15
				v15 = nil

				if v43 then
					if not controller then
						success8, result8 = pcall(fn)

						if success8 then
							controller = result8
						end
					end

					v44 = controller

					if v44 and v44.SetTone then
						pcall(v44.SetTone, v43)
					end
				end

				if state ~= "Stopped" then
					state = "Stopped"

					v45 = "Stopped"
					pcall(function()
						if RunService:IsClient() then
							local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
							PlayerLoadingState.ReportTabsPlaying(v45 == "Playing" and not v9)
						end
					end)
					notify()
				end
			end
		end
	else
		while v4 <= v2.n and v2.time[v4] <= v3 do
			v21 = v2.lane[v4]

			if v2.kind[v4] == 2 then
				if not v9 then
					v22 = v2.k[v4]

					if not controller then
						success, result = pcall(fn)

						if success then
							controller = result
						end
					end

					v23 = controller

					if v23 and v23.SetTone and type(v22) == "string" then
						if v15 == nil and v23.GetCurrentTone then
							v15 = v23.GetCurrentTone() or false
						end

						pcall(v23.SetTone, v22)
					end
				end
			elseif not (v9 or practice) then
				if v2.kind[v4] == 1 then
					if v2.k[v4] == "x" then
						count += 1

						if v7[v21] and v7[v21] then
							v7[v21] = nil

							if not controller then
								success2, result2 = pcall(fn)

								if success2 then
									controller = result2
								end
							end

							v24 = controller

							if v24 then
								v25, v26 = TabsSong.SplitLane(v21)
								pcall(v24.Release, v25, v26)
							end
						end

						if not controller then
							success3, result3 = pcall(fn)

							if success3 then
								controller = result3
							end
						end

						v27 = controller

						if v27 then
							v28, v29 = TabsSong.SplitLane(v21)
							pcall(v27.Press, v28, v29)
							v7[v21] = true
						end

						v30 = count
						local v46 = v21
						local v47 = v30
						task.delay(0.04, function()
							local v49 = v46

							local function fn2()
								return require(script.Parent.FreePlayController)
							end

							if v7[v49] then
								v7[v49] = nil

								if not controller then
									local success9, result9 = pcall(fn2)

									if success9 then
										controller = result9
									end
								end

								local v50 = controller

								if v50 then
									local v51, v52 = TabsSong.SplitLane(v49)
									pcall(v50.Release, v51, v52)
								end
							end

							if count == v47 then
								if not controller then
									local success9, result9 = pcall(fn2)

									if success9 then
										controller = result9
									end
								end

								local v50 = controller

								if v50 and v50.MuteAll then
									pcall(v50.MuteAll)
								end
							end
						end)
					else
						count += 1

						if v7[v21] and v7[v21] then
							v7[v21] = nil

							if not controller then
								success4, result4 = pcall(fn)

								if success4 then
									controller = result4
								end
							end

							v31 = controller

							if v31 then
								v32, v33 = TabsSong.SplitLane(v21)
								pcall(v31.Release, v32, v33)
							end
						end

						if not controller then
							success5, result5 = pcall(fn)

							if success5 then
								controller = result5
							end
						end

						v34 = controller

						if v34 then
							v35, v36 = TabsSong.SplitLane(v21)
							pcall(v34.Press, v35, v36)
							v7[v21] = true
						end
					end
				elseif v7[v21] then
					v7[v21] = nil

					if not controller then
						success6, result6 = pcall(fn)

						if success6 then
							controller = result6
						end
					end

					v37 = controller

					if v37 then
						v38, v39 = TabsSong.SplitLane(v21)
						pcall(v37.Release, v38, v39)
					end
				end
			end

			v4 += 1

			if not (v6 and v2.time[v4]) then
				continue
			end

			v40 = v2.time[v4]

			if v6 <= v40 then
				break
			end
		end

		if v6 and v6 <= v3 then
			releaseAll()
			v3 = v5 or 0
			v4 = firstEventAtOrAfter(v3)
			v17 = firstGroupAtOrAfter(v3)
			v18 = false
			set = {}
			v10 = v3 / track.Res - 0.0001

			v41 = not v9 and toneAtUnits(v3)

			if v41 then
				if not controller then
					success7, result7 = pcall(fn)

					if success7 then
						controller = result7
					end
				end

				v42 = controller

				if v42 and v42.SetTone and type(v41) == "string" then
					if v15 == nil and v42.GetCurrentTone then
						v15 = v42.GetCurrentTone() or false
					end

					pcall(v42.SetTone, v41)
				end
			end
		elseif v9 and v3 >= track.EndUnits or not v9 and v4 > v2.n then
			releaseAll()
			disconnectStep() -- inferred equivalent call
			v3 = 0
			v4 = 1
			v10 = nil
			v43 = v15
			v15 = nil

			if v43 then
				if not controller then
					success8, result8 = pcall(fn)

					if success8 then
						controller = result8
					end
				end

				v44 = controller

				if v44 and v44.SetTone then
					pcall(v44.SetTone, v43)
				end
			end

			if state ~= "Stopped" then
				state = "Stopped"

				v45 = "Stopped"
				pcall(function()
					if RunService:IsClient() then
						local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
						PlayerLoadingState.ReportTabsPlaying(v45 == "Playing" and not v9)
					end
				end)
				notify()
			end
		end
	end
end

function TabsPlayer.CanPlay(p)
	local v19 = p or track

	if not v19 then
		return false, "No tab loaded"
	end

	if not controller then
		local success, result = pcall(function()
			return require(script.Parent.FreePlayController)
		end)

		if success then
			controller = result
		end
	end

	local v20 = controller

	if not (v20 and v20.GetCurrentInstrumentType) then
		return false, "Free Play is not ready"
	end

	local instrumentFamily = TabsSong.InstrumentFamily(v20.GetCurrentInstrumentType())

	if not instrumentFamily then
		return false, "Equip a Guitar, Bass or Drum"
	end

	if instrumentFamily == v19.Instrument then
		return true
	end

	return false, "This tab is for " .. tostring(v19.Instrument)
end

function TabsPlayer.Load(p)
	TabsPlayer.Stop()
	track = p
	local v19

	if p then
		v19 = buildEvents(p) or nil
	end

	v2 = v19
	v16 = p and buildGroups(p) or nil
	v17 = 1
	v18 = false
	set = {}
	v3 = 0
	v4 = 1
	v5 = nil
	v6 = nil
	notify()
end

function TabsPlayer.GetTrack()
	return track
end

function TabsPlayer.Play()
	if not track then
		return false, "No tab loaded"
	end

	local canPlay, v19 = TabsPlayer.CanPlay(track)

	if not canPlay then
		return false, v19
	end

	if state == "Playing" then
		return true
	end

	local v20 = v3
	v12 = nil
	v13 = nil

	local v21 = not v9 and toneAtUnits(v20)

	if v21 then
		if not controller then
			local success, result = pcall(function()
				return require(script.Parent.FreePlayController)
			end)

			if success then
				controller = result
			end
		end

		local v22 = controller

		if v22 and v22.SetTone and type(v21) == "string" then
			if v15 == nil and v22.GetCurrentTone then
				v15 = v22.GetCurrentTone() or false
			end

			pcall(v22.SetTone, v21)
		end
	end

	v4 = firstEventAtOrAfter(v20)
	v17 = firstGroupAtOrAfter(v20)
	v18 = false
	set = {}

	if countIn and state ~= "Paused" then
		local barMap = track.BarMap
		v3 = v20 - (barMap and barMap.BeatsOfBar(barMap.BarAtBeat(v20 / track.Res)) or track.BeatsPerBar) * track.Res
		v12 = v3
		v13 = v20
		v14 = 0

		v10 = v20 / track.Res - 0.0001
	else
		v10 = v3 / track.Res
	end

	if state ~= "Playing" then
		state = "Playing"

		local v22 = "Playing"
		pcall(function()
			if RunService:IsClient() then
				local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
				PlayerLoadingState.ReportTabsPlaying(v22 == "Playing" and not v9)
			end
		end)
		notify()
	end

	lastTime = os.clock()

	if v and not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(TabsPlayer.Step)
	end

	return true
end

function TabsPlayer.PlayAtServerTime(p, p2)
	if not track then
		return false, "No tab loaded"
	end

	local canPlay, v19 = TabsPlayer.CanPlay(track)

	if not canPlay then
		return false, v19
	end

	TabsPlayer.Stop()
	v12 = nil
	v13 = nil
	v3 = (p2 - p) * unitsPerSecond() -- inferred equivalent call

	local v20 = not v9 and toneAtUnits(math.max(0, v3))

	if v20 then
		if not controller then
			local success, result = pcall(function()
				return require(script.Parent.FreePlayController)
			end)

			if success then
				controller = result
			end
		end

		local v21 = controller

		if v21 and v21.SetTone and type(v20) == "string" then
			if v15 == nil and v21.GetCurrentTone then
				v15 = v21.GetCurrentTone() or false
			end

			pcall(v21.SetTone, v20)
		end
	end

	v4 = firstEventAtOrAfter(math.max(0, v3))
	v17 = firstGroupAtOrAfter(math.max(0, v3))
	v18 = false
	set = {}
	v10 = v3 / track.Res - 0.0001

	if state ~= "Playing" then
		state = "Playing"

		local v21 = "Playing"
		pcall(function()
			if RunService:IsClient() then
				local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
				PlayerLoadingState.ReportTabsPlaying(v21 == "Playing" and not v9)
			end
		end)
		notify()
	end

	lastTime = os.clock()

	if v and not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(TabsPlayer.Step)
	end

	return true
end

function TabsPlayer.Pause()
	if state ~= "Playing" then
		return
	end

	disconnectStep() -- inferred equivalent call
	releaseAll()

	if state ~= "Paused" then
		state = "Paused"

		local v19 = "Paused"
		pcall(function()
			if RunService:IsClient() then
				local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
				PlayerLoadingState.ReportTabsPlaying(v19 == "Playing" and not v9)
			end
		end)
		notify()
	end
end

function TabsPlayer.Stop()
	disconnectStep() -- inferred equivalent call
	releaseAll()
	local v19 = v15
	v15 = nil

	if v19 then
		if not controller then
			local success, result = pcall(function()
				return require(script.Parent.FreePlayController)
			end)

			if success then
				controller = result
			end
		end

		local v20 = controller

		if v20 and v20.SetTone then
			pcall(v20.SetTone, v19)
		end
	end

	v12 = nil
	v13 = nil
	v3 = 0
	v4 = 1
	v10 = nil
	v17 = 1
	v18 = false
	set = {}

	if state ~= "Stopped" then
		state = "Stopped"

		local v20 = "Stopped"
		pcall(function()
			if RunService:IsClient() then
				local PlayerLoadingState = require(script.Parent.PlayerLoadingState)
				PlayerLoadingState.ReportTabsPlaying(v20 == "Playing" and not v9)
			end
		end)
		notify()
	end
end

function TabsPlayer.Seek(p)
	if not track then
		return
	end

	releaseAll()
	v3 = math.clamp(math.floor(p * track.Res + 0.5), 0, track.EndUnits)
	v4 = firstEventAtOrAfter(v3)
	v17 = firstGroupAtOrAfter(v3)
	v18 = false
	set = {}
	v10 = nil
	notify()
end

function TabsPlayer.SetSpeed(p)
	speed = math.clamp(tonumber(p) or 1, 0.25, 1)
	notify()
end

function TabsPlayer.GetSpeed()
	return speed
end

function TabsPlayer.SetLoop(p, p2)
	if track and p ~= nil and p2 ~= nil and not (p2 <= p) then
		v5 = math.floor(p * track.Res + 0.5)
		v6 = math.floor(p2 * track.Res + 0.5)
	else
		v5 = nil
		v6 = nil
	end

	notify()
end

function TabsPlayer.GetLoopBeats()
	if track and v5 and v6 then
		return v5 / track.Res, v6 / track.Res
	end

	return nil, nil
end

function TabsPlayer.GetPositionBeats()
	if track then
		return v3 / track.Res
	end

	return 0
end

function TabsPlayer.GetState()
	return state
end

function TabsPlayer.OnChanged(p)
	local v19 = {}
	v8[v19] = p
	return {
		Disconnect = function()
			v8[v19] = nil
		end
	}
end

function TabsPlayer.SetSilent(p)
	v9 = p == true
end

function TabsPlayer.GetLiveUnits()
	if state ~= "Playing" or not track then
		return v3
	end

	return v3 + (os.clock() - lastTime) * unitsPerSecond() -- inferred equivalent call
end

function TabsPlayer.GetUnitsAt(value)
	if state ~= "Playing" or not track or type(value) ~= "number" then
		return v3
	end

	return v3 + (value - lastTime) * unitsPerSecond() -- inferred equivalent call
end

function TabsPlayer.SetMetronome(p)
	metronome = p == true

	if metronome and track then
		v10 = v3 / track.Res
	end

	notify()
end

function TabsPlayer.GetMetronome()
	return metronome
end

function TabsPlayer.SetCountIn(p)
	countIn = p == true
	notify()
end

function TabsPlayer.GetCountIn()
	return countIn
end

function TabsPlayer.OnBeat(p)
	local v19 = {}
	v11[v19] = p
	return {
		Disconnect = function()
			v11[v19] = nil
		end
	}
end

function TabsPlayer.SetPractice(p)
	practice = p == true
	releaseAll()
	v18 = false
	set = {}

	if track then
		v17 = firstGroupAtOrAfter(v3)
	end

	notify()
end

function TabsPlayer.GetPractice()
	return practice
end

function TabsPlayer.IsWaiting()
	return practice and v18
end

function TabsPlayer.GetGuideLanes(value)
	local result = {}
	local v19 = nil

	if not track or not v16 or state ~= "Playing" then
		return result, nil
	end

	local v20 = practice and v17 or firstGroupAtOrAfter(math.floor(v3))
	local v21 = v3 + (value or 1) * track.Res

	for i = v20, math.min(#v16, v20 + 3) do
		local v22 = v16[i]

		if v21 < v22.t and (not practice or not v18 or i ~= v17) then
			break
		end

		for k in pairs(v22.set) do
			if not (not set[k] or not practice or i ~= v17) then
				continue
			end

			local splitLane, v23 = TabsSong.SplitLane(k)
			result[splitLane] = i == v20 and 2 or math.max(result[splitLane] or 0, 1)

			if i == v20 and v19 == nil then
				v19 = v23
			end
		end
	end

	return result, v19
end

local function onPlayerLane(p, p2, _, p3)
	if not p2 then
		return
	end

	local laneCode = TabsSong.LaneCode(p, p3, track and track.Instrument)
	nowsByLaneCode[laneCode] = os.clock()

	if practice and v18 and v16 then
		local v19 = v16[v17]

		if v19 and v19.set[laneCode] then
			set[laneCode] = true
		end
	end
end

InputRouter.OnLaneEvent(onPlayerLane)
TabsPlayer._onLane = onPlayerLane

function TabsPlayer.SetController(p)
	controller = p
end

function TabsPlayer.SetAutoStep(p)
	v = p
end

return TabsPlayer