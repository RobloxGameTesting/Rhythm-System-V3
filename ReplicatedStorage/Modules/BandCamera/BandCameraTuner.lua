local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bandCamera = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BandCamera")
local BandCameraConfig = require(bandCamera:WaitForChild("BandCameraConfig"))
local BandCameraPlayback = require(bandCamera:WaitForChild("BandCameraPlayback"))
local BandCameraFlyCam = require(bandCamera:WaitForChild("BandCameraFlyCam"))
local BandCameraController = require(bandCamera:WaitForChild("BandCameraController"))
local BandCameraCues = require(bandCamera:WaitForChild("BandCameraCues"))

local BandCameraTuner = {}

local LocalPlayer = Players.LocalPlayer

local color = Color3.fromRGB(22, 22, 26)
local color2 = Color3.fromRGB(34, 34, 40)
local color3 = Color3.fromRGB(245, 245, 247)
local color4 = Color3.fromRGB(160, 160, 170)
local color5 = Color3.fromRGB(88, 210, 150)
local color6 = Color3.fromRGB(235, 80, 80)
local color7 = Color3.fromRGB(60, 60, 70)

local v = false
local enabled = false
local flag = false
local v2 = {}
local v3 = 0
local v4 = 0
local v5 = nil
local songTime = nil
local v6 = nil
local flag2 = false
local count = 0
local v7 = nil
local v8 = nil
local v9 = { "Auto", "GuitarLead", "GuitarRhythm", "Bass", "Drum", "Keyboard", "Piano", "BVocal" }
local v10 = 1
local v11 = 0
local v12 = nil
local fn
local bandCameraDevCommand = nil
local flag3 = false
local fn2
local v13 = { Close = true, Head = true, Headstock = true, HeadCam = true }

local v14 = {}

local function isDeveloper(): boolean -- 2 equivalent calls inferred from this helper
	if RunService:IsStudio() then
		return true
	end

	local userId = LocalPlayer.UserId

	if game.CreatorType == Enum.CreatorType.User and game.CreatorId == userId then
		return true
	end

	return table.find(BandCameraConfig.Tuner.AllowedUserIds, userId) ~= nil
end

function BandCameraTuner.IsAvailable()
	return isDeveloper() -- inferred equivalent call
end

local function round(p, p2) -- 4 equivalent calls inferred from this helper
	local v15 = 10 ^ p2
	return math.floor(p * v15 + 0.5) / v15
end

local function create(className, items, parent) -- 35 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function styleButton(button, p)
	button.AutoButtonColor = true
	button.BackgroundColor3 = p or color2
	button.TextColor3 = color3
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, button) -- inferred equivalent call
	create("UIStroke", { -- inferred equivalent call
		Color = color7,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, button)
end

local function makeLabel(parent, text, p, p2, p3, p4, value, p5)
	return create("TextLabel", { -- inferred equivalent call
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = value or 12,
		TextColor3 = p5 or color3,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4)
	}, parent)
end

local function makeButton(parent, text, p, p2, p3, p4, p5, onMouseButton1Click)
	local button = create( -- inferred equivalent call
		"TextButton",
		{ Text = text, Position = UDim2.fromOffset(p, p2), Size = UDim2.fromOffset(p3, p4) },
		parent
	)

	styleButton(button, p5)
	button.MouseButton1Click:Connect(onMouseButton1Click)
	return button
end

local function makeTextBox(parent, text, p, p2, p3, p4)
	local textBox = create("TextBox", { -- inferred equivalent call
		Text = text,
		PlaceholderText = "",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = color3,
		BackgroundColor3 = color2,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4)
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 6) }, textBox) -- inferred equivalent call
	create("UIPadding", { PaddingLeft = UDim.new(0, 6) }, textBox) -- inferred equivalent call
	create("UIStroke", { -- inferred equivalent call
		Color = color7,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, textBox)
	return textBox
end

local function setStatus(text, color8) -- 23 equivalent calls inferred from this helper
	if v14.status then
		v14.status.Text = text
		v14.status.TextColor3 = color8 or color4
	end
end

local function stopPreview() -- 4 equivalent calls inferred from this helper
	if flag2 then
		flag2 = false

		if BandCameraFlyCam.IsActive() then
			BandCameraFlyCam.SetDriver(nil)
		end
	end
end

local function setFly(p) -- 2 equivalent calls inferred from this helper
	if p then
		if not BandCameraFlyCam.IsActive() then
			BandCameraController.SetTunerHold(true)
			BandCameraFlyCam.Start()
		end
	else
		if flag then
			BandCameraTuner.StopRecording()
		end

		stopPreview() -- inferred equivalent call

		if BandCameraFlyCam.IsActive() then
			BandCameraFlyCam.Stop()
			BandCameraController.SetTunerHold(false)
		end
	end

	BandCameraTuner.Refresh()
end

function BandCameraTuner.StartRecording()
	if flag then
		return
	end

	local tunerContext = BandCameraController.GetTunerContext()

	if tunerContext then
		if tunerContext.song and tunerContext.songTime then
			stopPreview() -- inferred equivalent call
			setFly(true) -- inferred equivalent call
			flag = true
			v2 = {}
			v5 = tunerContext
			songTime = tunerContext.songTime
			v4 = os.clock()
			v3 = -1
			v6 = nil
			setStatus("MEREKAM...", color6) -- inferred equivalent call
			BandCameraTuner.Refresh()
		else
			setStatus("Belum ada lagu berjalan di stage ini. Mulai lagu dulu.", color6) -- inferred equivalent call
		end
	else
		setStatus("Dekati stage dulu (masuk StageZone) lalu mulai lagu.", color6) -- inferred equivalent call
	end
end

function BandCameraTuner.StopRecording()
	if not flag then
		return
	end

	flag = false

	if #v2 >= 2 then
		local keys, v15 = BandCameraPlayback.BuildKeys(v2)
		v6 = {
			Song = v5.song,
			Stage = v5.stageId,
			Start = math.max(0, round(songTime, 2)), -- inferred equivalent call
			Duration = round(v15, 2), -- inferred equivalent call
			Keys = keys
		}

		count += 1

		if v14.nameBox and (v14.nameBox.Text == "" or v14.nameBox.Text:match("^Take %d+$")) then
			v14.nameBox.Text = "Take " .. count
		end

		if v14.startBox then
			v14.startBox.Text = tostring(v6.Start)
		end

		setStatus(("Rekaman selesai: %.1f dtk, %d key. Isi nama lalu Save."):format(v6.Duration, #keys), color5) -- inferred equivalent call
	else
		setStatus("Rekaman terlalu pendek, dibuang.", color4) -- inferred equivalent call
	end

	v2 = {}
	BandCameraTuner.Refresh()
end

local function onFlyStep()
	if not flag or flag2 then
		return
	end

	local now = os.clock()

	if now - v3 < 1 / BandCameraConfig.Tuner.SampleHz then
		return
	end

	v3 = now
	local currentCamera = Workspace.CurrentCamera
	v2[#v2 + 1] = {
		t = now - v4,
		cf = v5.ref:ToObjectSpace(currentCamera.CFrame),
		fov = currentCamera.FieldOfView
	}
end

local function previewTake(p, ref)
	if flag then
		return
	end

	setFly(true) -- inferred equivalent call
	local total = 0
	flag2 = true
	BandCameraFlyCam.SetDriver(function(p2)
		total += p2

		if total > p.Duration + 0.6 then
			task.defer(function()
				if flag2 then
					flag2 = false

					if BandCameraFlyCam.IsActive() then
						BandCameraFlyCam.SetDriver(nil)
					end
				end

				BandCameraTuner.Refresh()
			end)
		end

		local clip, v15 = BandCameraPlayback.SampleClip(p, (math.min(total, p.Duration)))
		return ref * clip, v15
	end)
	setStatus("Preview...", color5) -- inferred equivalent call
	BandCameraTuner.Refresh()
end

local function writeDraft(song, stage, data)
	if not v7 then
		return
	end

	local name = song .. "|" .. stage .. "|" .. data.Name
	local v15 = v7:FindFirstChild(name)

	if not v15 then
		local parent = v7
		v15 = Instance.new("StringValue")

		for k, v16 in pairs({ Name = name }) do
			v15[k] = v16
		end

		v15.Parent = parent
	end

	v15.Value = HttpService:JSONEncode({
		Song = song,
		Stage = stage,
		Name = data.Name,
		Start = data.Start,
		Duration = data.Duration,
		Keys = data.Keys
	})
end

local function removeDraft(song, stageId, name) -- 1 equivalent call inferred from this helper
	local child = v7 and v7:FindFirstChild(song .. "|" .. stageId .. "|" .. name)

	if child then
		child:Destroy()
	end
end

function BandCameraTuner.Save()
	if v6 then
		local name = (v14.nameBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")

		if name == "" or #name > 40 or name:find("|", 1, true) then
			setStatus("Nama wajib diisi (maks 40 huruf, tanpa tanda |).", color6) -- inferred equivalent call
		else
			local text = tonumber(v14.startBox.Text)

			if text and not (text < 0) then
				local v15 = {
					Name = name,
					Start = round(text, 2), -- inferred equivalent call
					Duration = v6.Duration,
					Keys = v6.Keys
				}
				writeDraft(v6.Song, v6.Stage, v15)
				BandCameraPlayback.AddLiveTake(v6.Song, v6.Stage, v15)
				setStatus( -- inferred equivalent call
					("Tersimpan: %s (mulai %.1f dtk). Aktif sebagai Dynamic Cam."):format(name, v15.Start),
					color5
				)
				v6 = nil
				BandCameraTuner.Refresh()
			else
				setStatus("Start harus angka >= 0 (detik lagu).", color6) -- inferred equivalent call
			end
		end
	else
		setStatus("Belum ada rekaman untuk disimpan.", color6) -- inferred equivalent call
	end
end

function BandCameraTuner.Discard()
	stopPreview() -- inferred equivalent call
	v6 = nil
	setStatus("Rekaman dibuang.", color4) -- inferred equivalent call
	BandCameraTuner.Refresh()
end

local v15 = nil

local function rebuildList(tunerContext)
	for _, frame in ipairs(v14.list:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	if not (tunerContext and tunerContext.song) then
		v14.listHeader.Text = "Take lagu & stage ini: -"
		return
	end

	local listTakes = BandCameraPlayback.ListTakes(tunerContext.song, tunerContext.stageId)
	v14.listHeader.Text = ("Take lagu & stage ini: %d"):format(#listTakes)

	for i, listTake in ipairs(listTakes) do
		local take = listTake.take
		local parent = create( -- inferred equivalent call
			"Frame",
			{ BackgroundColor3 = color2, Size = UDim2.new(1, -6, 0, 26), LayoutOrder = i },
			v14.list
		)
		create("UICorner", { CornerRadius = UDim.new(0, 6) }, parent) -- inferred equivalent call
		makeLabel(
			parent,
			("%s%s  @%.1fs  %.1fs"):format(listTake.isLive and "" or "[modul] ", take.Name, take.Start, take.Duration),
			6,
			5,
			170,
			18,
			11
		)
		makeButton(parent, "Play", 178, 2, 44, 22, nil, function()
			previewTake(take, tunerContext.ref)
		end)

		if listTake.isLive then
			makeButton(parent, "X", 226, 2, 30, 22, color6, function()
				BandCameraPlayback.RemoveLiveTake(tunerContext.song, tunerContext.stageId, take.Name)
				removeDraft(tunerContext.song, tunerContext.stageId, take.Name) -- inferred equivalent call
				v15 = nil
				BandCameraTuner.Refresh()
			end)
		end
	end
end

function BandCameraTuner.Refresh()
	if not v14.panel then
		return
	end

	local tunerContext = BandCameraController.GetTunerContext()
	local isActive = BandCameraFlyCam.IsActive()

	if tunerContext then
		v14.context.Text = ("Stage: %s\nLagu: %s"):format(
			tunerContext.stageId,
			tunerContext.song or "(tidak ada lagu berjalan)"
		)

		if not tunerContext.hasRef then
			v14.context.Text ..= "\n! Attachment StudioCenter tidak ada: take disimpan dalam koordinat dunia"
		end
	else
		v14.context.Text = "Stage: -\nDekati stage (masuk StageZone) untuk merekam."
	end

	local v16 = flag and "MEREKAM" or flag2 and "PREVIEW" or isActive and "Free Cam" or "Idle"
	local v17 = tunerContext and tunerContext.songTime and ("%.1fs"):format(tunerContext.songTime) or "-"
	v14.timeLabel.Text = ("Waktu lagu: %s   |   %s"):format(v17, v16)
	v14.timeLabel.TextColor3 = flag and color6 or color3

	v14.flyButton.Text = isActive and "Free Cam: ON  (F10)" or "Free Cam: OFF  (F10)"
	v14.flyButton.BackgroundColor3 = isActive and color5 or color2
	v14.flyButton.TextColor3 = isActive and color or color3

	v14.recButton.BackgroundColor3 = flag and color6 or color2

	if v6 then
		v14.pending.Text = ("Belum disimpan: %.1f dtk, mulai @%.1fs (lagu: %s)"):format(v6.Duration, v6.Start, v6.Song)
		v14.pending.TextColor3 = color5
	else
		v14.pending.Text = "Belum ada rekaman baru."
		v14.pending.TextColor3 = color4
	end

	fn2(tunerContext)

	if fn then
		fn(tunerContext)
	end

	local v18 = tunerContext and (tunerContext.song or "-") .. "|" .. tunerContext.stageId or "-"

	if v18 ~= v15 then
		v15 = v18
		rebuildList(tunerContext)
	end
end

local function cueDraftKey(p, p2) -- 2 equivalent calls inferred from this helper
	return p .. "|" .. string.format("%.1f", p2)
end

local function writeCueDraft(song, data)
	if not v8 then
		return
	end

	local name = cueDraftKey(song, data.At) -- inferred equivalent call
	local v16 = v8:FindFirstChild(name)

	if not v16 then
		local parent = v8
		v16 = Instance.new("StringValue")

		for k, v17 in pairs({ Name = name }) do
			v16[k] = v17
		end

		v16.Parent = parent
	end

	v16.Value = HttpService:JSONEncode({
		Song = song,
		At = data.At,
		Shot = data.Shot,
		Target = data.Target,
		Dir = data.Dir
	})
end

local function removeCueDraft(song, from) -- 1 equivalent call inferred from this helper
	local child = v8 and v8:FindFirstChild(cueDraftKey(song, from)) -- inferred equivalent call

	if child then
		child:Destroy()
	end
end

local function addBoardCue(shotName)
	local tunerContext = BandCameraController.GetTunerContext()

	if tunerContext and tunerContext.song and tunerContext.songTime then
		local target = v9[v10]

		if target == "Auto" then
			target = nil
		end

		if v13[shotName] and not target then
			setStatus(shotName .. " butuh Target. Pilih target dulu (tombol Target).", color6) -- inferred equivalent call
		else
			local v16 = {
				At = math.max(0, round(tunerContext.songTime, 1)), -- inferred equivalent call
				Shot = shotName,
				Target = target,
				Dir = 0
			}
			local dir

			if v11 ~= 0 then
				dir = v11 or nil
			end

			v16.Dir = dir

			local v17, v18 = BandCameraCues.AddLive(tunerContext.song, v16)

			if v17 then
				writeCueDraft(tunerContext.song, v16)
				setStatus( -- inferred equivalent call
					("Cue: %s %s%s"):format(
						BandCameraCues.FormatTime(v16.At),
						shotName,
						target and " -> " .. target or ""
					),
					color5
				)
			else
				setStatus("Cue ditolak: " .. tostring(v18), color6) -- inferred equivalent call
			end
		end
	else
		setStatus("Papan sutradara: mulai lagu di stage ini dulu.", color6) -- inferred equivalent call
	end
end

local function rebuildCueList(p)
	for _, frame in ipairs(v14.cueList:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	if not (p and p.song) then
		v14.cueHeader.Text = "Cue lagu ini: -"
		return
	end

	local listForUI = BandCameraCues.ListForUI(p.song)
	v14.cueHeader.Text = ("Cue lagu ini: %d  (sampai cue berikutnya / %ds)"):format(
		#listForUI,
		BandCameraConfig.CueDefaultSeconds
	)

	for i, v16 in ipairs(listForUI) do
		local cue = v16.cue
		local parent = create( -- inferred equivalent call
			"Frame",
			{ BackgroundColor3 = color2, Size = UDim2.new(1, -6, 0, 24), LayoutOrder = i },
			v14.cueList
		)
		create("UICorner", { CornerRadius = UDim.new(0, 6) }, parent) -- inferred equivalent call
		makeLabel(
			parent,
			("%s  %s%s%s"):format(
				BandCameraCues.FormatTime(cue.From),
				cue.Shot,
				cue.Target and " > " .. cue.Target or "",
				v16.id and "" or "  [file]"
			),
			6,
			4,
			220,
			18,
			11
		)

		if v16.id then
			makeButton(parent, "X", 250, 1, 28, 22, color6, function()
				BandCameraCues.RemoveLive(p.song, v16.id)
				removeCueDraft(p.song, cue.From) -- inferred equivalent call
				v12 = nil
				BandCameraTuner.Refresh()
			end)
		end
	end
end

fn2 = function(tunerContext)
	if not v14.board then
		return
	end

	local song = tunerContext and tunerContext.song
	v14.boardContext.Text = song and ("Lagu: %s"):format(song) or "Lagu: (belum ada lagu berjalan)"
	v14.boardTime.Text = tunerContext
		and tunerContext.songTime
		and ("Waktu lagu: %s"):format(BandCameraCues.FormatTime(tunerContext.songTime))
		or "Waktu lagu: -"
	v14.targetButton.Text = "Target: " .. v9[v10] .. (v10 == 1 and " (otomatis)" or "")
	v14.dirButton.Text = "Sisi kamera: " .. (v11 == 0 and "otomatis" or v11 == 1 and "kiri/+1" or "kanan/-1")
	local v16 = (song or "-") .. "|" .. #BandCameraCues.Get(song or "")

	if v16 ~= v12 then
		v12 = v16
		rebuildCueList(tunerContext)
	end
end

local function buildBoard(parent)
	local board = create("Frame", { -- inferred equivalent call
		BackgroundColor3 = color,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 324, 0.5, 0),
		Size = UDim2.fromOffset(300, 500)
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 10) }, board) -- inferred equivalent call
	create("UIStroke", { -- inferred equivalent call
		Color = color7,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, board)
	v14.board = board

	create("TextLabel", { -- inferred equivalent call
		Text = "Papan Sutradara (cue per lagu)",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = color3,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.fromOffset(280, 20)
	}, board)

	v14.boardContext = makeLabel(board, "", 10, 32, 280, 32, 12, color4)
	v14.boardTime = makeLabel(board, "", 10, 66, 280, 18, 12)

	v14.targetButton = makeButton(board, "", 10, 90, 280, 26, nil, function()
		v10 = v10 % #v9 + 1
		BandCameraTuner.Refresh()
	end)
	v14.dirButton = makeButton(board, "", 10, 120, 280, 26, nil, function()
		v11 = v11 == 0 and 1 or v11 == 1 and -1 or 0
		BandCameraTuner.Refresh()
	end)

	makeLabel(board, "Klik shot = cue pada waktu lagu SEKARANG:", 10, 152, 280, 16, 11, color4)
	local shotNames = BandCameraConfig.ShotNames

	for i, shotName in ipairs(shotNames) do
		local v16 = (i - 1) % 3
		local v17 = (i - 1) // 3
		makeButton(board, shotName, 10 + v16 * 95, 172 + v17 * 32, 90, 28, nil, function()
			addBoardCue(shotName)
		end)
	end

	v14.cueHeader = makeLabel(board, "Cue lagu ini: -", 10, 304, 280, 16, 12, color4)
	v14.cueList = create("ScrollingFrame", { -- inferred equivalent call
		BackgroundColor3 = color,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 322),
		Size = UDim2.fromOffset(280, 168),
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	}, board)

	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, v14.cueList) -- inferred equivalent call
end

local function sendDev(cmd, p)
	if bandCameraDevCommand then
		local tunerContext = BandCameraController.GetTunerContext()

		if tunerContext then
			if flag3 then
				return
			end

			flag3 = true
			task.spawn(function()
				local success, result = pcall(function()
					return bandCameraDevCommand:InvokeServer({
						cmd = cmd,
						stageId = tunerContext.stageId,
						value = p
					})
				end)

				flag3 = false

				if success then
					if type(result) == "table" and result.ok == false then
						setStatus("Ditolak: " .. tostring(result.msg), color6) -- inferred equivalent call
					elseif type(result) == "table" and result.msg then
						setStatus(tostring(result.msg), color5) -- inferred equivalent call
					end
				else
					setStatus("Perintah gagal: " .. tostring(result), color6) -- inferred equivalent call
				end
			end)
		else
			setStatus("Dekati stage dulu (masuk StageZone).", color6) -- inferred equivalent call
		end
	else
		setStatus("Server dev tidak tersedia (BandCameraDevCommand).", color6) -- inferred equivalent call
	end
end

local function skip(p) -- 5 equivalent calls inferred from this helper
	sendDev("Skip", p)
end

local function togglePause() -- 1 equivalent call inferred from this helper
	local tunerContext = BandCameraController.GetTunerContext()
	sendDev(tunerContext and tunerContext.paused and "Resume" or "Pause")
end

local function buildTransport(parent)
	local transport = create("Frame", { -- inferred equivalent call
		BackgroundColor3 = color,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 70),
		Size = UDim2.fromOffset(600, 66)
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 10) }, transport) -- inferred equivalent call
	create("UIStroke", { -- inferred equivalent call
		Color = color7,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, transport)
	v14.transport = transport

	local skipSeconds = BandCameraConfig.Tuner.SkipSeconds
	local skipSecondsBig = BandCameraConfig.Tuner.SkipSecondsBig
	local total = 8
	local function btn(text, p, p2, p3)
		local button = makeButton(transport, text, total, 6, p, 26, p2, p3)
		total += p + 4
		return button
	end

	makeButton(transport, "|<", total, 6, 36, 26, nil, function()
		sendDev("Restart")
	end)
	total += 40
	makeButton(transport, "-" .. skipSecondsBig, total, 6, 42, 26, nil, function()
		skip(-skipSecondsBig) -- inferred equivalent call
	end)
	total += 46
	makeButton(transport, "-" .. skipSeconds, total, 6, 42, 26, nil, function()
		skip(-skipSeconds) -- inferred equivalent call
	end)
	total += 46
	local button = makeButton(transport, "Pause (F6)", total, 6, 84, 26, nil, togglePause)
	total += 88

	v14.pauseButton = button
	makeButton(transport, "+" .. skipSeconds, total, 6, 42, 26, nil, function()
		skip(skipSeconds) -- inferred equivalent call
	end)
	total += 46
	makeButton(transport, "+" .. skipSecondsBig, total, 6, 42, 26, nil, function()
		skip(skipSecondsBig) -- inferred equivalent call
	end)
	total += 46

	v14.seekBox = makeTextBox(transport, "", total, 6, 64, 26)
	v14.seekBox.PlaceholderText = "m:ss"
	total += 68
	makeButton(transport, "Go", total, 6, 34, 26, nil, function()
		local time = BandCameraCues.ParseTime(v14.seekBox.Text)

		if time then
			sendDev("Seek", time)
			return
		end

		setStatus("Waktu tidak valid. Contoh: 1:35", color6) -- inferred equivalent call
	end)
	total += 38
	local button2 = makeButton(transport, "Sim: OFF", total, 6, 92, 26, nil, function()
		local tunerContext = BandCameraController.GetTunerContext()
		sendDev(tunerContext and tunerContext.simActive and "SimStop" or "SimStart")
	end)
	total += 96

	v14.simButton = button2
	local button3 = makeButton(transport, "HUD: ON", total, 6, 66, 26, nil, function()
		local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			playerGui:SetAttribute("BandSimHudOff", playerGui:GetAttribute("BandSimHudOff") ~= true or nil)
		end
	end)
	total += 70

	v14.hudButton = button3

	local parent2 = create("TextButton", { -- inferred equivalent call
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = color2,
		Position = UDim2.fromOffset(8, 40),
		Size = UDim2.fromOffset(584, 18)
	}, transport)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, parent2) -- inferred equivalent call
	v14.progressFill = create( -- inferred equivalent call
		"Frame",
		{
			BackgroundColor3 = color5,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0, 1)
		},
		parent2
	)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, v14.progressFill) -- inferred equivalent call
	v14.progressLabel = create("TextLabel", { -- inferred equivalent call
		Text = "-",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = color3,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, parent2)

	parent2.MouseButton1Click:Connect(function()
		local tunerContext = BandCameraController.GetTunerContext()

		if tunerContext and tunerContext.duration then
			sendDev(
				"Seek",
				math.clamp(
					(UserInputService:GetMouseLocation().X - parent2.AbsolutePosition.X) / math.max(1, parent2.AbsoluteSize.X),
					0,
					1
				) * tunerContext.duration
			)
		else
			setStatus("Durasi lagu belum diketahui.", color6) -- inferred equivalent call
		end
	end)
end

fn = function(tunerContext)
	if not v14.transport then
		return
	end

	local v16 = tunerContext and tunerContext.songTime and BandCameraCues.FormatTime(tunerContext.songTime) or "-"
	local v17 = tunerContext and tunerContext.duration and BandCameraCues.FormatTime(tunerContext.duration) or "-"
	v14.progressLabel.Text = v16 .. "  /  " .. v17 .. (tunerContext and tunerContext.paused and "   [PAUSE]" or "")
	local v18 = tunerContext
		and tunerContext.songTime
		and tunerContext.duration
		and tunerContext.duration > 0
		and math.clamp(tunerContext.songTime / tunerContext.duration, 0, 1)
		or 0
	v14.progressFill.Size = UDim2.fromScale(v18, 1)
	v14.pauseButton.Text = tunerContext and tunerContext.paused and "Lanjut (F6)" or "Pause (F6)"
	v14.pauseButton.BackgroundColor3 = tunerContext and tunerContext.paused and color5 or color2
	v14.pauseButton.TextColor3 = tunerContext and tunerContext.paused and color or color3
	local simActive = tunerContext and tunerContext.simActive
	v14.simButton.Text = simActive and "Sim: ON" or "Sim: OFF"
	v14.simButton.BackgroundColor3 = simActive and color5 or color2
	v14.simButton.TextColor3 = simActive and color or color3
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local v19 = not playerGui or playerGui:GetAttribute("BandSimHudOff") ~= true
	v14.hudButton.Text = v19 and "HUD: ON" or "HUD: OFF"
	v14.hudButton.BackgroundColor3 = v19 and color5 or color2
	v14.hudButton.TextColor3 = v19 and color or color3
end

local function buildPanel(playerGui)
	local gui = create("ScreenGui", { -- inferred equivalent call
		Name = "BandCameraTuner",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 200,
		Enabled = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, playerGui)

	local panel = create("Frame", { -- inferred equivalent call
		BackgroundColor3 = color,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(300, 500)
	}, gui)

	create("UICorner", { CornerRadius = UDim.new(0, 10) }, panel) -- inferred equivalent call
	create("UIStroke", { -- inferred equivalent call
		Color = color7,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, panel)

	v14.gui = gui
	v14.panel = panel

	create("TextLabel", { -- inferred equivalent call
		Text = "Dynamic Cam Tuner",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = color3,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.fromOffset(240, 20)
	}, panel)

	makeButton(panel, "X", 266, 8, 24, 22, nil, function()
		BandCameraTuner.SetPanelOpen(false)
	end)

	v14.context = makeLabel(panel, "", 10, 34, 280, 44, 12, color4)
	v14.timeLabel = makeLabel(panel, "", 10, 82, 280, 18, 12)
	v14.flyButton = makeButton(panel, "", 10, 104, 280, 28, nil, function()
		setFly(not BandCameraFlyCam.IsActive())
	end)

	makeLabel(panel, "Name", 10, 142, 50, 20, 12, color4)
	v14.nameBox = makeTextBox(panel, "", 66, 138, 224, 24)
	makeLabel(panel, "Start (dtk)", 10, 172, 60, 20, 12, color4)
	v14.startBox = makeTextBox(panel, "0", 66, 168, 224, 24)

	v14.recButton = makeButton(panel, "Rec (F9)", 10, 202, 90, 28, nil, function()
		BandCameraTuner.StartRecording()
	end)
	v14.stopButton = makeButton(panel, "Stop", 105, 202, 90, 28, nil, function()
		if flag then
			BandCameraTuner.StopRecording()
			return
		end

		stopPreview() -- inferred equivalent call
		BandCameraTuner.Refresh()
	end)
	v14.playButton = makeButton(panel, "Play", 200, 202, 90, 28, nil, function()
		local tunerContext = BandCameraController.GetTunerContext()

		if v6 and tunerContext then
			previewTake({ Keys = v6.Keys, Duration = v6.Duration }, tunerContext.ref)
			return
		end

		setStatus("Tidak ada rekaman baru. Pakai Play di daftar take.", color4) -- inferred equivalent call
	end)
	v14.saveButton = makeButton(panel, "Save", 10, 236, 138, 28, color5, function()
		BandCameraTuner.Save()
	end)
	v14.saveButton.TextColor3 = color
	v14.discardButton = makeButton(panel, "Discard", 152, 236, 138, 28, nil, function()
		BandCameraTuner.Discard()
	end)

	v14.pending = makeLabel(panel, "", 10, 272, 280, 32, 12)
	v14.status = makeLabel(panel, "", 10, 306, 280, 32, 12, color4)

	v14.listHeader = makeLabel(panel, "Take lagu & stage ini: -", 10, 342, 280, 16, 12, color4)
	v14.list = create("ScrollingFrame", { -- inferred equivalent call
		BackgroundColor3 = color,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 360),
		Size = UDim2.fromOffset(280, 100),
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	}, panel)

	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, v14.list) -- inferred equivalent call

	makeLabel(
		panel,
		"Klik kanan+mouse: lihat | WASD gerak | Q/E turun/naik | Z/X FOV | Shift cepat, Ctrl pelan | Roda: kecepatan",
		10,
		466,
		280,
		30,
		10,
		color4
	)
	buildBoard(gui)
	buildTransport(gui)
end

local function syncBandScoreOffset() -- 2 equivalent calls inferred from this helper
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		playerGui:SetAttribute("BandTunerPanelW", enabled and (v14.board and v14.board.Visible and 624 or 312) or nil)
	end
end

function BandCameraTuner.SetPanelOpen(p)
	enabled = p == true
	syncBandScoreOffset() -- inferred equivalent call

	if v14.gui then
		v14.gui.Enabled = enabled
	end

	if enabled then
		v15 = nil
		BandCameraTuner.Refresh()
		task.spawn(function()
			while enabled do
				BandCameraTuner.Refresh()
				syncBandScoreOffset() -- inferred equivalent call
				task.wait(0.1)
			end
		end)
	end
end

function BandCameraTuner.Init()
	if not v and isDeveloper() then -- inferred equivalent call
		v = true
		local playerGui = LocalPlayer:WaitForChild("PlayerGui")

		v7 = create("Folder", { Name = "BandCameraTakesDraft" }, playerGui) -- inferred equivalent call
		v8 = create("Folder", { Name = "BandCameraCuesDraft" }, playerGui) -- inferred equivalent call
		bandCameraDevCommand = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BandCameraDevCommand", 10)
		buildPanel(playerGui)
		BandCameraFlyCam.OnStep(onFlyStep)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or UserInputService:GetFocusedTextBox() then
				return
			end

			local tuner = BandCameraConfig.Tuner

			if input.KeyCode == tuner.ToggleKey then
				BandCameraTuner.SetPanelOpen(not enabled)
			elseif input.KeyCode == tuner.FlyKey then
				setFly(not BandCameraFlyCam.IsActive())
			elseif input.KeyCode == tuner.RecordKey then
				if flag then
					BandCameraTuner.StopRecording()
				else
					BandCameraTuner.StartRecording()
				end
			elseif input.KeyCode == tuner.PauseKey then
				togglePause() -- inferred equivalent call
			elseif input.KeyCode == tuner.BackKey or input.KeyCode == tuner.ForwardKey then
				local v16 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and tuner.SkipSecondsBig
					or tuner.SkipSeconds
				v16 = input.KeyCode == tuner.BackKey and -v16 or v16
				skip(v16) -- inferred equivalent call
			end
		end)

		print(("[BandCamera] Cam Tuner aktif: %s = panel, %s = Free Cam, %s = Rec/Stop"):format(
			BandCameraConfig.Tuner.ToggleKey.Name,
			BandCameraConfig.Tuner.FlyKey.Name,
			BandCameraConfig.Tuner.RecordKey.Name
		))
	end
end

return BandCameraTuner