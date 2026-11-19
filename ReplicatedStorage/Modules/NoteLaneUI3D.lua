local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
require(ReplicatedStorage.Modules.ScreenGlowEffect)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local NewbieModeState = require(ReplicatedStorage.Modules.NewbieModeState)
local CountdownFx = require(ReplicatedStorage.Modules.CountdownFx)
local StarPowerVisualEffects = require(ReplicatedStorage.Modules.StarPowerVisualEffects)
local HighwaySkins = require(ReplicatedStorage.Modules.HighwaySkins)
local RockMeterConfig = require(ReplicatedStorage.Modules.RockMeterConfig)

local NoteLaneUI3D = {}

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui") or game:GetService("StarterGui")

local ENERGY_COLOR = StarPowerVisualEffects.ENERGY_COLOR
local TINT_TWEEN_INFO = StarPowerVisualEffects.TINT_TWEEN_INFO
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 0)

local function rbx(p)
	return "rbxassetid://" .. p
end
local tex = {
	Highway = "rbxassetid://120503858506623",
	Gem = "rbxassetid://73545599342254",
	Ring = "rbxassetid://120146867583223",
	Cap = "rbxassetid://90173701280210",
	Glow = "rbxassetid://135010222764315",
	Star = "rbxassetid://126162762258993",
	Shock = "rbxassetid://125762726757343",
	Streak = "rbxassetid://70407693932213",
	Lightning = "rbxassetid://108069074339451",
	Flame = "rbxassetid://140432912018111",
	GemGrime = "rbxassetid://119583417478019",
	GrungeOverlay = "rbxassetid://115233302080462",
	RailGrunge = "rbxassetid://96258178630571",
	EdgeGrunge = "rbxassetid://132579886744804"
}

local v = {
	LaneColors = {
		Color3.fromRGB(0, 255, 60),
		Color3.fromRGB(255, 35, 35),
		Color3.fromRGB(255, 215, 0),
		Color3.fromRGB(25, 150, 255),
		Color3.fromRGB(255, 120, 15)
	},
	JudgmentColors = {
		Perfect = Color3.fromRGB(180, 255, 255),
		Great = Color3.fromRGB(140, 255, 180),
		Good = Color3.fromRGB(255, 230, 80),
		OK = Color3.fromRGB(255, 180, 70),
		Miss = Color3.fromRGB(255, 25, 25),
		Wrong = Color3.fromRGB(200, 50, 255)
	},
	InstrumentNames = {
		GuitarLead = "GUITAR LEAD",
		GuitarRhythm = "GUITAR RHYTHM",
		Bass = "BASS",
		Drum = "DRUM",
		Keyboard = "KEYBOARD",
		Piano = "PIANO"
	},
	Highway = {
		LaneWidth = 2.6,
		Length = 58,
		TiltDegrees = 16,
		PlateColor = Color3.fromRGB(14, 14, 18),
		TexTint = color,
		TexTintStar = Color3.fromRGB(120, 205, 255),
		RailW = 0.5,
		RailH = 0.5,
		Extend = 16,
		FadeLen = 24,
		FadeSlices = 30,
		TexOffsetSign = 1,
		Frets = { -4.5, -13, -26 },
		RailColor = Color3.fromRGB(78, 80, 92),
		RailGlow = Color3.fromRGB(200, 210, 235),
		DividerTrans = 0.86,
		BeatLines = true,
		BeatMaxLines = 28
	},
	Receptor = {
		PadDiameter = 2.45,
		PadThickness = 0.22,
		PadRestY = 0.2,
		PressDepth = 0.12,
		IdleDarken = 0.25,
		LabelZ = 2.55,
		LabelW = 1.85,
		LabelD = 0.95,
		BoardMargin = 0.5,
		BoardThickness = 0.3
	},
	Note = {
		RimDiameter = 1.95,
		RimThickness = 0.07,
		MidDiameter = 1.7,
		MidThickness = 0.1,
		TopDiameter = 1.45,
		TopThickness = 0.14,
		DomeDiameter = 0.62,
		FarBoost = 0.35,
		SpawnFrac = 0.16,
		FadeFrac = 0.34,
		SpawnScale = 0.45,
		SpawnRise = 0.3
	},
	Hold = { BarWidth = 0.38, GlowWidth = 0.95, IdleTrans = 0.45 },
	Camera = {
		Elevation = 41,
		FOV = 55,
		Zoom = 0.62,
		HitNy = -0.63,
		Pos = Vector3.new(0, 10, 11.5),
		MarginDeg = 2
	},
	EffectScale = {
		Perfect = 1.25,
		Great = 1.05,
		Good = 0.9,
		OK = 0.8,
		Miss = 0,
		Wrong = 0
	}
}

local v2 = {
	High = {
		sparks = 16,
		embers = 5,
		cap = 170,
		lightning = true,
		star = true,
		flame = true,
		holdRate = 28,
		holdBolt = true
	},
	Low = {
		sparks = 6,
		embers = 1,
		cap = 48,
		lightning = false,
		star = false,
		flame = true,
		holdRate = 9,
		holdBolt = false
	}
}

local v3 = nil
local function getQ() -- 5 equivalent calls inferred from this helper
	local v4 = v3

	if not v4 and LocalPlayer then
		local noteLane3DFxQuality = LocalPlayer:GetAttribute("NoteLane3DFxQuality")

		if noteLane3DFxQuality == "High" or noteLane3DFxQuality == "Low" then
			v4 = noteLane3DFxQuality
		end
	end

	return v2[v4 or UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and "Low" or "High"]
		or v2.High
end

local noteLaneUI3D = nil
local highway3D = nil
local worldModel = nil
local camera = nil
local glowLayer = nil
local fxLayer = nil
local instLabel = nil
local judgmentLabel = nil
local uiScale = nil
local countdown = nil
local countdownCaption = nil
local v4 = nil
local count = 0
local v5 = nil
local v6 = false

local cframe = CFrame.Angles(math.rad(-v.Highway.TiltDegrees), 0, 0)
local cframe2 = CFrame.Angles(0, 0, 1.5707963267948966)

local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = nil
local v13 = {}
local v14 = nil
local v15 = 5

local v16 = {}
local v17 = {}

local v18 = nil
local v19 = "Diamond"
local v20 = nil

local v21 = { bpm = nil, offset = 0 }

local v22 = { rock = RockMeterConfig.Start, dt = 0.016, lastSync = os.clock() }
local v23 = {
	JudgeScale = { Perfect = 1, Great = 0.9, Good = 0.8, OK = 0.7 }
}

function v23.idleRing(p)
	return p:Lerp(color2, v.Receptor.IdleDarken):Lerp(Color3.fromRGB(78, 70, 62), 0.28)
end

function v23.gTex(parent, face, texture, studsPerTileU, studsPerTileV, p, p2)
	local texture2 = Instance.new("Texture")
	texture2.Texture = texture
	texture2.Face = face
	texture2.StudsPerTileU = studsPerTileU
	texture2.StudsPerTileV = studsPerTileV
	texture2.OffsetStudsV = v.Highway.TexOffsetSign * (v.Highway.Extend - p) % studsPerTileV
	texture2.Color3 = p2 or color
	texture2.Parent = parent
	return texture2
end

function v23.grungeDecal(parent, face, value, value2)
	if not tex.GrungeOverlay then
		return
	end

	local decal = Instance.new("Decal")
	decal.Texture = tex.GrungeOverlay
	decal.Face = face
	decal.ZIndex = value or 3
	decal.Transparency = value2 or 0.1
	decal.Parent = parent
end

v23.IntensityFloor = 0.4
function v23.intensity()
	local rock = v22.rock
	local v24

	if rock <= 0.15 then
		v24 = 0.1
	elseif rock <= 0.5 then
		v24 = 0.1 + (rock - 0.15) / 0.35 * 0.4
	else
		v24 = not (rock <= 0.85) and 1 or 0.5 + (rock - 0.5) / 0.35 * 0.5
	end

	local intensityFloor = v23.IntensityFloor
	return intensityFloor + (1 - intensityFloor) * (v24 - 0.1) / 0.9
end

local v24 = {
	Circle = "Dome",
	Rounded = "Ball",
	Pill = "Pill",
	Square = "Block",
	Hero = "BadgeBlock",
	Diamond = "Dome",
	Arrow = "Wedge"
}

local function getJudgmentColor3D(p) -- 2 equivalent calls inferred from this helper
	return SettingsState.GetRhythmJudgmentColor(p) or v.JudgmentColors[p]
end

local function getNoteOuterColorForLane3D(p) -- 3 equivalent calls inferred from this helper
	local v25 = v18 and v18[p]

	if v25 and v25.NoteOuter then
		return v25.NoteOuter
	end

	if v20 and v20[p] then
		return v20[p]
	end

	return v.LaneColors[(p - 1) % #v.LaneColors + 1]
end

local function getNoteInnerColorForLane3D(lane) -- 1 equivalent call inferred from this helper
	local v25 = v18 and v18[lane]
	return v25 and v25.NoteInner or nil
end

local function getReceptorRingColorForLane3D(p) -- 2 equivalent calls inferred from this helper
	local v25 = v18 and v18[p]
	local v26 = v25 and v25.ReceptorRing

	if v26 then
		return v26
	end

	local v27 = v18 and v18[p]

	if v27 and v27.NoteOuter then
		return v27.NoteOuter
	end

	if v20 and v20[p] then
		return v20[p]
	end

	return v.LaneColors[(p - 1) % #v.LaneColors + 1]
end

local function getReceptorPressColorForLane3D(p) -- 2 equivalent calls inferred from this helper
	local v25 = v18 and v18[p]
	local v26 = v25 and v25.ReceptorPress

	if v26 then
		return v26
	end

	local v27 = v18 and v18[p]

	if v27 and v27.NoteOuter then
		return v27.NoteOuter
	end

	if v20 and v20[p] then
		return v20[p]
	end

	return v.LaneColors[(p - 1) % #v.LaneColors + 1]
end

local function capKindToPartType(p) -- 2 equivalent calls inferred from this helper
	if p == "Ball" or p == "Dome" or p == "Pill" then
		return Enum.PartType.Ball
	end

	if p == "Block" or p == "BadgeBlock" then
		return Enum.PartType.Block
	end

	if p == "Wedge" then
		return Enum.PartType.Wedge
	end

	return Enum.PartType.Cylinder
end

function NoteLaneUI3D.OnLanePressed(p)
	table.insert(v16, p)
end
function NoteLaneUI3D.OnLaneReleased(p)
	table.insert(v17, p)
end

local function laneLocalX(p, p2) -- 8 equivalent calls inferred from this helper
	return (p - (p2 + 1) / 2) * v.Highway.LaneWidth
end

local function toWorld(p, p2, p3) -- 14 equivalent calls inferred from this helper
	return (cframe * CFrame.new(p, p2, p3)).Position
end

local function lerp(p, p2, p3) -- 5 equivalent calls inferred from this helper
	return p + (p2 - p) * p3
end

local function computeLookAt()
	local camera2 = v.Camera
	local elevation = math.rad(camera2.Elevation)
	local v25 = math.tan(math.rad(camera2.FOV) / 2)
	local v26 = math.atan(math.abs(camera2.HitNy) * v25)

	local v27 = 5 * v.Highway.LaneWidth / (2 * camera2.Zoom * v25 * (4 / 3) * math.cos(v26))
	camera2.Pos = Vector3.new(0, v27 * math.sin(elevation), v27 * math.cos(elevation))
	local v28 = elevation - v26
	return camera2.Pos + Vector3.new(0, -math.sin(v28), -math.cos(v28)) * 40
end

function v23.applyCameraSettings()
	local camera2 = v.Camera
	pcall(function()
		camera2.Elevation = math.clamp(SettingsState.GetHighwayCamElevation(), 18, 50)
		camera2.FOV = math.clamp(SettingsState.GetHighwayCamFov(), 25, 60)
		camera2.Zoom = math.clamp(SettingsState.GetHighwayCamZoom(), 0.5, 0.88)
		camera2.HitNy = -math.clamp(SettingsState.GetHighwayCamHitY(), 0.2, 0.7)
		v.Highway.Length = math.clamp(SettingsState.GetHighwayCamLength(), 30, 60)
	end)
	local camSig = camera2.Elevation .. "|" .. camera2.FOV .. "|" .. camera2.Zoom .. "|" .. camera2.HitNy .. "|" .. v.Highway.Length

	if v22.camSig == camSig then
		return
	end

	v22.camSig = camSig
	local v25 = computeLookAt()

	if camera then
		camera.FieldOfView = camera2.FOV
		camera.CFrame = CFrame.lookAt(
			toWorld(camera2.Pos.X, camera2.Pos.Y, camera2.Pos.Z), -- inferred equivalent call
			toWorld(v25.X, v25.Y, v25.Z) -- inferred equivalent call
		)

		if v23.afterCamera then
			v23.afterCamera()
		end
	end

	if v22.builtLength and math.abs(v.Highway.Length - v22.builtLength) > 0.01 and v23.scheduleRebuild then
		v23.scheduleRebuild()
	end
end

local function distAlongHighway(p, p2) -- 2 equivalent calls inferred from this helper
	local v25 = math.clamp(1 - p / p2, -0.3, 1.3)
	return -v.Highway.Length * (1 - v25), v25
end

local v25 = {
	BaseW = 720,
	BaseH = 540,
	MaxHeightFrac = 0.85,
	MaxWidthFrac = 0.98,
	Scale = 1,
	W = 720,
	H = 540,
	ScreenW = 1280,
	ScreenH = 720,
	ScreenOverride = nil,
	InputGui = nil,
	InputContainer = nil,
	TouchButtons = {},
	TouchHeld = {},
	FxUnit = 90
}

function v25.getScreenSize()
	if v25.ScreenOverride then
		return v25.ScreenOverride
	end

	if noteLaneUI3D then
		local absoluteSize = noteLaneUI3D.AbsoluteSize

		if absoluteSize.X > 0 and absoluteSize.Y > 0 then
			return absoluteSize
		end
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local GuiService = game:GetService("GuiService")
		local guiInset, v26 = GuiService:GetGuiInset()
		local v27 = currentCamera.ViewportSize - guiInset - v26

		if v27.X > 0 and v27.Y > 0 then
			return v27
		end
	end

	return Vector2.new(1280, 720)
end

function v25.computeFrame(p, p2)
	local v26 = math.min(v25.BaseH * 1.3, p2 * v25.MaxHeightFrac)
	local v27 = v26 * (v25.BaseW / v25.BaseH)
	local v28 = p * v25.MaxWidthFrac

	if v28 < v27 then
		v26 = v28 * (v25.BaseH / v25.BaseW)
		v27 = v28
	end

	local v29 = math.max(math.floor(v27), 1)
	local v30 = math.max(math.floor(v26), 1)
	return v29, v30, v30 / v25.BaseH
end

function v25.project(p)
	if not camera then
		return nil
	end

	local pointToObjectSpace = camera.CFrame:PointToObjectSpace(p)

	if pointToObjectSpace.Z >= -0.05 then
		return nil
	end

	local v26 = math.tan(math.rad(camera.FieldOfView) / 2)
	local v27 = pointToObjectSpace.X / -pointToObjectSpace.Z / (v26 * (v25.W / v25.H))
	local v28 = pointToObjectSpace.Y / -pointToObjectSpace.Z / v26
	local v29 = (v25.ScreenW - v25.W) / 2
	local v30 = v25.ScreenH - v25.H
	return Vector2.new(v29 + (0.5 + v27 / 2) * v25.W, v30 + (0.5 - v28 / 2) * v25.H)
end

function v23.afterCamera()
	if v25.apply then
		pcall(v25.apply)
	end
end

function v25.touchPress(p)
	if v25.TouchHeld[p] then
		return
	end

	v25.TouchHeld[p] = true

	for _, callback in ipairs(v16) do
		local success, result = pcall(callback, p)

		if not success then
			warn("[NoteLaneUI3D] lane pressed listener:", result)
		end
	end
end

function v25.touchRelease(p)
	if not v25.TouchHeld[p] then
		return
	end

	v25.TouchHeld[p] = nil

	for _, callback in ipairs(v17) do
		local success, result = pcall(callback, p)

		if not success then
			warn("[NoteLaneUI3D] lane released listener:", result)
		end
	end
end

function v25.releaseAllTouch()
	for k in pairs(v25.TouchHeld) do
		v25.touchRelease(k)
	end
end

function v25.buildTouch(p)
	if not (v25.InputContainer and #v25.TouchButtons ~= p) then
		return
	end

	v25.releaseAllTouch()

	for _, touchButton in ipairs(v25.TouchButtons) do
		touchButton:Destroy()
	end

	v25.TouchButtons = {}

	for i = 1, p do
		local textButton = Instance.new("TextButton")
		textButton.Name = "Lane" .. i .. "Touch"
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BackgroundTransparency = 1
		textButton.BorderSizePixel = 0
		textButton.Active = true
		textButton.ZIndex = 3
		textButton.Parent = v25.InputContainer

		textButton.MouseButton1Down:Connect(function()
			v25.touchPress(i)
		end)
		textButton.MouseButton1Up:Connect(function()
			v25.touchRelease(i)
		end)
		textButton.MouseLeave:Connect(function()
			v25.touchRelease(i)
		end)
		v25.TouchButtons[i] = textButton
	end
end

function v25.layoutTouch()
	if #v25.TouchButtons == 0 or not camera then
		return
	end

	local v26 = v15
	local padRestY = v.Receptor.PadRestY
	local laneWidth = v.Highway.LaneWidth
	local v27 = {}

	for i = 0, v26 do
		local v28 = v25.project(toWorld((i - v26 / 2) * laneWidth, padRestY, 0)) -- inferred equivalent call
		v27[i] = v28 and math.floor(v28.X + 0.5) or nil
	end

	for i, touchButton in ipairs(v25.TouchButtons) do
		local v28 = v25.project(toWorld((i - 0.5 - v26 / 2) * laneWidth, padRestY, 0)) -- inferred equivalent call
		local v29 = v27[i - 1]
		local v30 = v27[i]

		if v29 and v30 and v28 then
			local v31 = math.floor(math.max(v28.Y - v25.H * 0.3, 0) + 0.5)
			local v32 = math.floor(v25.ScreenH + 0.5)
			touchButton.Position = UDim2.fromOffset(v29, v31)
			touchButton.Size = UDim2.fromOffset(math.max(v30 - v29, 1), (math.max(v32 - v31, 1)))
			touchButton.Visible = true
		else
			touchButton.Visible = false
		end
	end
end

local fn

function v25.apply()
	if not highway3D then
		return
	end

	local screenSize = v25.getScreenSize()
	local frame, v26, scale = v25.computeFrame(screenSize.X, screenSize.Y)
	local x = screenSize.X
	local y = screenSize.Y
	v25.ScreenW = x
	v25.ScreenH = y
	v25.W = frame
	v25.H = v26
	v25.Scale = scale
	highway3D.Size = UDim2.fromOffset(frame, v26)

	local function px(p, p2) -- 16 equivalent calls inferred from this helper
		return (math.max(p2, (math.floor(p * scale + 0.5))))
	end
	local v27 = v25.ScreenH - v26
	local v28 = px(28, 12) -- inferred equivalent call
	local v29 = math.floor(v27 + 0.045 * v26 + 0.5)

	if instLabel then
		instLabel.Size = UDim2.fromOffset(px(360, 80), v28) -- inferred equivalent call
		instLabel.TextSize = px(19, 9) -- inferred equivalent call
		instLabel.Position = UDim2.new(0.5, 0, 0, v29)
	end

	if judgmentLabel then
		judgmentLabel.Size = UDim2.fromOffset(px(340, 80), px(52, 16)) -- inferred equivalent call
		judgmentLabel.TextSize = px(36, 12) -- inferred equivalent call
		judgmentLabel.Position = UDim2.new(0.5, 0, 0, v29 - v28 - px(4, 2)) -- inferred equivalent call
	end

	if countdown then
		countdown.Size = UDim2.fromOffset(px(100, 44), px(100, 44)) -- inferred equivalent call
		countdown.Position = UDim2.new(0.5, 0, 1, -px(330, 60)) -- inferred equivalent call
		local uiTextSizeConstraint = countdown:FindFirstChildOfClass("UITextSizeConstraint")

		if uiTextSizeConstraint then
			uiTextSizeConstraint.MaxTextSize = px(38, 12) -- inferred equivalent call
			uiTextSizeConstraint.MinTextSize = math.min(px(16, 8), uiTextSizeConstraint.MaxTextSize) -- inferred equivalent call
		end
	end

	if countdownCaption then
		countdownCaption.Size = UDim2.fromOffset(px(240, 100), px(22, 10)) -- inferred equivalent call
		countdownCaption.TextSize = px(15, 9) -- inferred equivalent call
		countdownCaption.Position = UDim2.new(0.5, 0, 1, px(8, 3)) -- inferred equivalent call
	end

	v25.layoutTouch()

	if fn then
		fn()
	end

	if v23.onLayout then
		v23.onLayout()
	end
end

local v26 = {
	sprites = {},
	sparks = {},
	flames = {},
	pool = {},
	conn = nil
}

local function acquire(value, value2)
	local selected = table.remove(v26.pool)

	if not selected then
		selected = Instance.new("ImageLabel")
		selected.BackgroundTransparency = 1
		selected.BorderSizePixel = 0
		selected.ScaleType = Enum.ScaleType.Stretch
		selected.Active = false
	end

	selected.AnchorPoint = Vector2.new(0.5, value2 or 0.5)
	selected.ZIndex = value or 1
	selected.Rotation = 0
	selected.Visible = true
	selected.Parent = fxLayer
	return selected
end

local function release(l) -- 6 equivalent calls inferred from this helper
	l.Visible = false
	l.ImageRectSize = Vector2.zero
	l.ImageRectOffset = Vector2.zero
	table.insert(v26.pool, l)
end

local function addSprite(image, pos, w0, h0, w1, h1, imageColor, imageTransparency, life, value, p, value2, value3)
	if #v26.sprites >= 70 then
		return
	end

	local v27 = acquire(value2 or 2)
	v27.Image = image
	v27.ImageColor3 = imageColor
	v27.ImageTransparency = imageTransparency
	v27.Position = UDim2.fromOffset(pos.X, pos.Y)
	v27.Size = UDim2.fromOffset(w0, h0)
	v27.Rotation = value or 0
	table.insert(v26.sprites, {
		l = v27,
		t = 0,
		life = life,
		pos = pos,
		w0 = w0,
		h0 = h0,
		w1 = w1,
		h1 = h1,
		a0 = imageTransparency,
		rot0 = value or 0,
		rot1 = p or value or 0,
		fade = value3 or 1.6
	})
end

local function addFlame(screenPos, p, imageColor, life)
	if #v26.flames >= 24 then
		return
	end

	local v27 = acquire(3, 0.9)
	v27.Image = tex.Flame
	v27.ImageColor3 = imageColor
	v27.ImageTransparency = 0.05
	v27.ImageRectSize = Vector2.new(256, 256)
	v27.ImageRectOffset = Vector2.zero
	v27.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
	v27.Size = UDim2.fromOffset(p, p * 1.15)
	table.insert(v26.flames, { l = v27, t = 0, life = life })
end

local function addSpark(kind, pos, vel, life, size, p, imageColor, value, value2)
	local v27 = #v26.sparks

	if getQ().cap <= v27 then -- inferred equivalent call
		return
	end

	local v28 = acquire(6)
	v28.Image = kind == "streak" and tex.Streak or tex.Glow
	v28.ImageColor3 = imageColor
	v28.ImageTransparency = 0
	v28.Position = UDim2.fromOffset(pos.X, pos.Y)
	table.insert(v26.sparks, {
		l = v28,
		kind = kind,
		pos = pos,
		vel = vel,
		t = 0,
		life = life,
		size = size,
		len = p or size,
		g = value or 0,
		drag = value2 or 0,
		wob = 6 + math.random() * 6,
		wa = (math.random() - 0.5) * 70,
		a0 = 0
	})
end

local function fxColor(p) -- 9 equivalent calls inferred from this helper
	return v6 and ENERGY_COLOR or p.AccentColor
end

local function spawnLightning(p, p2, p3)
	local screenPos = p.ScreenPos
	local fxUnit = v25.FxUnit

	if not screenPos then
		return
	end

	local h0 = fxUnit * 1.7 * p3
	local w0 = h0 * 0.62

	for i = 1, p3 >= 1.2 and 2 or 1 do
		local v27 = 180 + (math.random() - 0.5) * 36
		local pos = screenPos + Vector2.new((math.random() - 0.5) * fxUnit * 0.4 * p3, -h0 * 0.42)
		addSprite(
			tex.Lightning,
			pos,
			w0,
			h0,
			w0 * 1.05,
			h0 * 1.08,
			p2:Lerp(color, 0.55),
			0.02,
			i * 0.03 + 0.09,
			v27,
			v27 + (math.random() - 0.5) * 8,
			5,
			1.2
		)
	end
end

local function spawnBurst(p, p2, p3, p4)
	local screenPos = p.ScreenPos
	local fxUnit = v25.FxUnit

	if not screenPos then
		return
	end

	local v27 = fxUnit / 90

	for _ = 1, p3 do
		local v28 = math.rad((math.random() - 0.5) * 150)
		local v29 = (260 + math.random() * 420) * v27 * p4
		local vel = Vector2.new(math.sin(v28), -math.cos(v28)) * v29

		if math.random() < 0.6 then
			addSpark(
				"streak",
				screenPos,
				vel,
				0.32 + math.random() * 0.3,
				fxUnit * 0.1,
				fxUnit * (0.45 + math.random() * 0.5),
				p2:Lerp(color, 0.3),
				900 * v27,
				1.2
			)
		else
			addSpark(
				"dot",
				screenPos,
				vel * 0.8,
				0.3 + math.random() * 0.35,
				fxUnit * (0.16 + math.random() * 0.14),
				nil,
				p2:Lerp(color, 0.45),
				700 * v27,
				1.5
			)
		end
	end
end

local function spawnEmbers(p, p2, p3)
	local screenPos = p.ScreenPos
	local fxUnit = v25.FxUnit

	if not screenPos then
		return
	end

	local v27 = fxUnit / 90

	for _ = 1, p3 do
		local vector2 = Vector2.new((math.random() - 0.5) * 60 * v27, -(50 + math.random() * 90) * v27)
		addSpark(
			"ember",
			screenPos + Vector2.new((math.random() - 0.5) * fxUnit * 0.7, 0),
			vector2,
			0.9 + math.random() * 0.7,
			fxUnit * (0.1 + math.random() * 0.1),
			nil,
			p2:Lerp(color, 0.25),
			-30 * v27,
			0.4
		)
	end
end

local function stepFx(p)
	if not (noteLaneUI3D and fxLayer) then
		return
	end

	local v27 = math.min(p, 0.1)
	local _fxUnit = v25.FxUnit
	local v28 = 1

	while v28 <= #v26.sprites do
		local sprite = v26.sprites[v28]
		sprite.t += v27
		local v29 = sprite.t / sprite.life

		if v29 >= 1 then
			release(sprite.l) -- inferred equivalent call
			v26.sprites[v28] = v26.sprites[#v26.sprites]
			v26.sprites[#v26.sprites] = nil
		else
			local v30 = 1 - (1 - v29) * (1 - v29)
			local l = sprite.l
			l.Size = UDim2.fromOffset(lerp(sprite.w0, sprite.w1, v30), lerp(sprite.h0, sprite.h1, v30)) -- inferred equivalent call
			sprite.l.Rotation = lerp(sprite.rot0, sprite.rot1, v30) -- inferred equivalent call
			sprite.l.ImageTransparency = lerp(sprite.a0, 1, v29 ^ sprite.fade) -- inferred equivalent call
			v28 += 1
		end
	end

	local v29 = 1

	while v29 <= #v26.flames do
		local flame = v26.flames[v29]
		flame.t += v27
		local v30 = flame.t / flame.life

		if v30 >= 1 then
			release(flame.l) -- inferred equivalent call
			v26.flames[v29] = v26.flames[#v26.flames]
			v26.flames[#v26.flames] = nil
		else
			local v31 = math.min(15, (math.floor(v30 * 16)))
			flame.l.ImageRectOffset = Vector2.new(v31 % 4 * 256, math.floor(v31 / 4) * 256)
			v29 += 1
		end
	end

	local v30 = 1

	while v30 <= #v26.sparks do
		local spark = v26.sparks[v30]
		spark.t += v27
		local v31 = spark.t / spark.life

		if v31 >= 1 then
			release(spark.l) -- inferred equivalent call
			v26.sparks[v30] = v26.sparks[#v26.sparks]
			v26.sparks[#v26.sparks] = nil
		else
			spark.vel = Vector2.new(
				spark.vel.X * (1 - spark.drag * v27),
				spark.vel.Y * (1 - spark.drag * v27) + spark.g * v27
			)
			local vel = spark.vel

			if spark.kind == "ember" then
				vel += Vector2.new(math.sin(spark.t * spark.wob) * spark.wa, 0)
			end

			spark.pos += vel * v27
			local l = spark.l
			l.Position = UDim2.fromOffset(spark.pos.X, spark.pos.Y)

			if spark.kind == "streak" then
				l.Rotation = math.deg((math.atan2(spark.vel.Y, spark.vel.X))) + 180
				local v32 = math.clamp(spark.vel.Magnitude * 0.07, spark.size * 2, spark.len) * (1 - v31 * 0.5)
				l.Size = UDim2.fromOffset(v32, spark.size)
			else
				local v32 = spark.size * (spark.kind == "ember" and 1 - v31 * 0.4 or 1 - v31 * 0.65)
				l.Size = UDim2.fromOffset(v32, v32)
			end

			l.ImageTransparency = lerp(spark.kind == "ember" and 0.2 or 0, 1, v31 ^ 1.8) -- inferred equivalent call
			v30 += 1
		end
	end

	local now = os.clock()
	local q = getQ() -- inferred equivalent call

	for _, v31 in pairs(v7) do
		local v32 = now < v31.HoldUntil
		local targetGlow = v31.TargetGlow

		if v32 then
			targetGlow = math.max(targetGlow, 0.85)
		end

		v31.GlowLevel += (targetGlow - v31.GlowLevel) * math.min(1, v27 * (v31.GlowLevel < targetGlow and 30 or 9))
		local glowLabel = v31.GlowLabel

		if glowLabel then
			glowLabel.Visible = v31.GlowLevel > 0.02
			glowLabel.ImageTransparency = 1 - v31.GlowLevel * 0.5
			glowLabel.ImageColor3 = fxColor(v31) -- inferred equivalent call
		end

		if v32 then
			v31.HoldFade = math.min(1, v31.HoldFade + v27 * 8)
			v31.HoldAcc += v27 * q.holdRate * v23.intensity() * (v6 and 1.5 or 1)

			while v31.HoldAcc >= 1 do
				v31.HoldAcc -= 1
				spawnBurst(v31, fxColor(v31), 1, 0.7) -- inferred equivalent call
			end

			v31.EmberAcc += v27 * (q.embers * 2.2) * v23.intensity()

			while v31.EmberAcc >= 1 do
				v31.EmberAcc -= 1
				spawnEmbers(v31, fxColor(v31), 1) -- inferred equivalent call
			end

			v31.BoltAcc += v27

			if q.holdBolt and v31.BoltAcc > 0.16 then
				v31.BoltAcc = 0

				if v6 or math.random() < 0.6 * v23.intensity() then
					spawnLightning(v31, fxColor(v31), v6 and 1.1 or 0.5 + 0.4 * v23.intensity()) -- inferred equivalent call
				end
			end
		else
			v31.HoldFade = math.max(0, v31.HoldFade - v27 * 6)
		end

		local holdFlame = v31.HoldFlame

		if not holdFlame then
			continue
		end

		local visible = v31.HoldFade > 0.02 and q.flame
		holdFlame.Visible = visible

		if not visible then
			continue
		end

		local v35 = math.floor(now * 16) % 7 + 5
		holdFlame.ImageRectOffset = Vector2.new(v35 % 4 * 256, math.floor(v35 / 4) * 256)
		holdFlame.ImageTransparency = 1 - v31.HoldFade * 0.9
		holdFlame.ImageColor3 = fxColor(v31) -- inferred equivalent call
	end
end

local function clearFx()
	for _, sprite in ipairs(v26.sprites) do
		release(sprite.l) -- inferred equivalent call
	end

	for _, flame in ipairs(v26.flames) do
		release(flame.l) -- inferred equivalent call
	end

	for _, spark in ipairs(v26.sparks) do
		release(spark.l) -- inferred equivalent call
	end

	v26.sprites = {}
	v26.flames = {}
	v26.sparks = {}
end

function NoteLaneUI3D._DebugStep(p)
	stepFx(p)
end

local function destroyVisual(data)
	if data.Base then
		data.Base:Destroy()
	end

	if data.Mid then
		data.Mid:Destroy()
	end

	if data.Body then
		data.Body:Destroy()
	end

	if data.Cap then
		data.Cap:Destroy()
	end

	if data.Tail then
		for _, list in ipairs(data.Tail.Layers) do
			for _, item in ipairs(list) do
				item:Destroy()
			end
		end
	end

	return (pcall(function()
		local RhythmVibratoWave3D = require(ReplicatedStorage.Modules.RhythmVibratoWave3D)
		RhythmVibratoWave3D.Destroy(data)
	end))
end

local function clearAll()
	v23.railRelease()

	for _, v27 in pairs(v8) do
		destroyVisual(v27)
	end

	v8 = {}

	for _, v27 in pairs(v7) do
		if v27.Pad then
			v27.Pad:Destroy()
		end

		if v27.GlowLabel then
			v27.GlowLabel:Destroy()
		end

		if v27.HoldFlame then
			v27.HoldFlame:Destroy()
		end

		if v27.KeyLabel then
			v27.KeyLabel:Destroy()
		end
	end

	v7 = {}

	for _, v27 in ipairs(v9) do
		v27:Destroy()
	end

	for _, v27 in ipairs(v11) do
		v27:Destroy()
	end

	if worldModel then
		for _, child in ipairs(worldModel:GetChildren()) do
			if child.Name == "BeatLine3D" then
				child:Destroy()
			end
		end
	end

	v9 = {}
	v10 = {}
	v11 = {}
	v13 = {}
	v12 = nil
	clearFx()
end

local function makeDisc(p, p2, color3) -- 6 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(p2, p, p)
	part.Color = color3
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	return part
end

local function addDecal(disc, texture, color3, value) -- 3 equivalent calls inferred from this helper
	local decal = Instance.new("Decal")
	decal.Texture = texture
	decal.Face = Enum.NormalId.Right
	decal.Color3 = color3
	decal.ZIndex = value or 1
	decal.Parent = disc
	return decal
end

local function makeBox(size, cframe3, color3, p, value, p2)
	local part = Instance.new("Part")
	part.Size = size
	part.CFrame = cframe3
	part.Color = color3
	part.Material = p or Enum.Material.SmoothPlastic
	part.Transparency = value or 0
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Parent = p2 or worldModel
	return part
end

local function gemBodyColor(p) -- 7 equivalent calls inferred from this helper
	return p:Lerp(Color3.fromRGB(66, 66, 72), 0.3):Lerp(color2, 0.1)
end

local function gemDecalColor(p) -- 3 equivalent calls inferred from this helper
	return p:Lerp(color, 0.28)
end

local function buildGem(originalAccentColor, noteInner, p)
	local note = v.Note
	local capShapeKind = v24[p] or "Dome"
	local v27 = noteInner or originalAccentColor:Lerp(color, 0.72)

	local disc = makeDisc(note.RimDiameter, note.RimThickness, Color3.fromRGB(36, 36, 42)) -- inferred equivalent call
	disc.Material = Enum.Material.Metal
	disc.Parent = worldModel
	local disc2 = makeDisc(note.MidDiameter, note.MidThickness, gemBodyColor(originalAccentColor):Lerp(color2, 0.25)) -- inferred equivalent call
	disc2.Parent = worldModel
	local disc3 = makeDisc(note.TopDiameter, note.TopThickness, gemBodyColor(originalAccentColor)) -- inferred equivalent call
	disc3.Parent = worldModel
	local gemDecal = addDecal(disc3, tex.GemGrime or tex.Gem, gemDecalColor(originalAccentColor), nil) -- inferred equivalent call

	local part = Instance.new("Part")
	part.Shape = capKindToPartType(capShapeKind) -- inferred equivalent call
	part.Size = Vector3.new(0.3, note.DomeDiameter, note.DomeDiameter)
	part.Color = v27
	part.Material = Enum.Material.Neon
	part.Transparency = 0.14
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Parent = worldModel

	return {
		Base = disc,
		Mid = disc2,
		Body = disc3,
		Cap = part,
		GemDecal = gemDecal,
		AccentColor = originalAccentColor,
		CapColor = v27,
		CapShapeKind = capShapeKind,
		Spin = math.random() * 3.141592653589793 * 2
	}
end

local function applyGemStarPowerTint(data, p)
	local v27 = p and ENERGY_COLOR or data.AccentColor
	local color3 = p and ENERGY_COLOR:Lerp(color, 0.75) or data.CapColor
	TweenService:Create(data.Body, TINT_TWEEN_INFO, { Color = gemBodyColor(v27) }):Play() -- inferred equivalent call
	TweenService:Create(data.Mid, TINT_TWEEN_INFO, {
		Color = gemBodyColor(v27):Lerp(color2, 0.25) -- inferred equivalent call
	}):Play()
	TweenService:Create(data.GemDecal, TINT_TWEEN_INFO, { Color3 = gemDecalColor(v27) }):Play() -- inferred equivalent call
	TweenService:Create(data.Cap, TINT_TWEEN_INFO, { Color = color3 }):Play()
end

local function placeGem(data, p, p2)
	local note = v.Note
	local cframe3 = CFrame.Angles(data.Spin or 0, 0, 0)
	local v27 = note.RimThickness * p2
	local v28 = note.MidThickness * p2
	local v29 = note.TopThickness * p2

	data.Base.CFrame = p * cframe3
	data.Base.Size = Vector3.new(v27, note.RimDiameter * p2, note.RimDiameter * p2)
	data.Mid.Size = Vector3.new(v28, note.MidDiameter * p2, note.MidDiameter * p2)
	data.Mid.CFrame = p * CFrame.new(v27 / 2 + v28 / 2 - 0.01 * p2, 0, 0) * cframe3
	data.Body.Size = Vector3.new(v29, note.TopDiameter * p2, note.TopDiameter * p2)
	data.Body.CFrame = p * CFrame.new(v27 / 2 + v28 + v29 / 2 - 0.02 * p2, 0, 0) * cframe3

	local v30 = note.DomeDiameter * p2
	local v31 = v27 / 2 + v28 + v29 - 0.03 * p2
	local cframe4 = p * CFrame.new(v31, 0, 0)
	local cap = data.Cap
	local capShapeKind = data.CapShapeKind

	if capShapeKind == "Block" then
		cap.CFrame = cframe4 * CFrame.new(v30 * 0.08, 0, 0)
		cap.Size = Vector3.new(v30 * 0.2, v30 * 0.8, v30 * 0.8)
	elseif capShapeKind == "BadgeBlock" then
		cap.CFrame = cframe4 * CFrame.new(v30 * 0.08, 0, 0) * CFrame.Angles(0.7853981633974483, 0, 0)
		cap.Size = Vector3.new(v30 * 0.2, v30 * 0.7, v30 * 0.7)
	elseif capShapeKind == "Wedge" then
		cap.CFrame = CFrame.new(p.Position) * cframe.Rotation * CFrame.new(0, v27 / 2 + v28 + v29, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		cap.Size = Vector3.new(v30 * 0.8, v30 * 0.3, v30 * 0.95)
	elseif capShapeKind == "Pill" then
		cap.CFrame = cframe4
		cap.Size = Vector3.new(v30 * 0.5, v30 * 0.7, v30 * 1.35)
	elseif capShapeKind == "Ball" then
		cap.CFrame = cframe4
		cap.Size = Vector3.new(v30 * 0.8, v30 * 0.85, v30 * 0.85)
	else
		cap.CFrame = cframe4
		cap.Size = Vector3.new(v30 * 0.5, v30, v30)
	end
end

v23.TailSegs = {
	{ 0, -20, 0 },
	{ -20, -28, 0.08 },
	{ -28, -36, 0.18 },
	{ -36, -44, 0.3 },
	{ -44, -51, 0.45 },
	{ -51, -58, 0.62 }
}
v23.TailLayers = {
	{
		w = 0.62,
		th = 0.03,
		y = 0.12,
		idle = 0.92,
		act = 0.74,
		white = 0,
		mute = 0.35,
		trans = true,
		maxSeg = 3,
		mat = "Neon"
	},
	{
		w = 0.38,
		th = 0.06,
		y = 0.19,
		white = 0,
		mute = 0.5,
		dim = 0.32,
		mat = "SmoothPlastic"
	},
	{
		w = 0.11,
		th = 0.05,
		y = 0.26,
		white = 0.45,
		mute = 0.35,
		dim = 0.25,
		mat = "Neon"
	}
}

v23.TailMute = Color3.fromRGB(100, 96, 92)

function v23.buildTail(p)
	local tail = { Layers = {}, Act = 0 }

	for i, tailLayer in ipairs(v23.TailLayers) do
		local v27 = {}

		for j = 1, #v23.TailSegs do
			local vector3 = Vector3.new(tailLayer.w, tailLayer.th, 1)
			local cframe3 = CFrame.new()
			local lerped = p:Lerp(color, tailLayer.white)
			local v28 = Enum.Material[tailLayer.mat or "Neon"]
			local part = Instance.new("Part")
			part.Size = vector3
			part.CFrame = cframe3
			part.Color = lerped
			part.Material = v28 or Enum.Material.SmoothPlastic
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Parent = worldModel

			part.Parent = nil
			v27[j] = part
		end

		tail.Layers[i] = v27
	end

	return tail
end

function v23.updateTail(p, p2, p3, p4, p5, p6, p7)
	local tail = p.Tail

	for i, tailLayer in ipairs(v23.TailLayers) do
		for j, tailSeg in ipairs(v23.TailSegs) do
			local v27 = tail.Layers[i][j]
			local v28 = math.min(p3, tailSeg[1])
			local v29 = math.max(p4, tailSeg[2])

			if v28 - v29 > 0.03 and (not tailLayer.maxSeg or j <= tailLayer.maxSeg) then
				local midpoint = (v28 + v29) / 2

				local v30 = math.clamp(-midpoint / v.Highway.Length, 0, 1) * 0.5 + 1
				v27.Size = Vector3.new(tailLayer.w * v30, tailLayer.th, v28 - v29)
				v27.CFrame = CFrame.new(toWorld(p2, tailLayer.y, midpoint)) * cframe.Rotation -- inferred equivalent call
				local lerped = p7:Lerp(v23.TailMute, tailLayer.mute or 0):Lerp(color, tailLayer.white)

				if tailLayer.trans then
					v27.Color = lerped
					local v31 = tailLayer.idle + (tailLayer.act - tailLayer.idle) * p5
					local v32 = v31 + (1 - v31) * tailSeg[3]
					v27.Transparency = v32 + (1 - v32) * (1 - p6)
				else
					v27.Color = lerped:Lerp(color2, (math.clamp(tailLayer.dim * (1 - p5) + tailSeg[3] * 0.6, 0, 0.9)))
					v27.Transparency = 1 - p6
				end

				if v27.Parent ~= worldModel then
					v27.Parent = worldModel
				end
			elseif v27.Parent then
				v27.Parent = nil
			end
		end
	end
end

function v23.suppressTail(p)
	for _, list in ipairs(p.Tail.Layers) do
		for _, item in ipairs(list) do
			if item.Parent then
				item.Transparency = 1
			end
		end
	end
end

local function getSkin()
	local v27 = nil
	pcall(function()
		if SettingsState.GetHighwaySkin then
			v27 = SettingsState.GetHighwaySkin()
		end
	end)

	if not v27 and LocalPlayer then
		v27 = LocalPlayer:GetAttribute("HighwaySkin")
	end

	if not HighwaySkins.Get(v27).IsRandom then
		return HighwaySkins.Resolve(v27)
	end

	if not v22.randomSkin then
		local resolve = HighwaySkins.Resolve
		local v28 = v27
		v22.randomSkin = resolve(v28, v22.lastRandomId, v22.loaded)
	end

	return v22.randomSkin
end

v22.scroll = 0
v22.scrollElapsed = nil
v23.ScrollDir = 1

function v23.updateScroll(scrollElapsed, p)
	if v.Highway.ScrollTexture == false then
		return
	end

	local scrollElapsed2 = v22.scrollElapsed
	v22.scrollElapsed = scrollElapsed

	if scrollElapsed2 then
		local v27 = scrollElapsed - scrollElapsed2

		if v27 > 0 and v27 < 0.5 then
			v22.scroll += v27 * (v.Highway.Length / p)
		end
	end

	for _, v27 in ipairs(v13) do
		if not v27.Parent then
			continue
		end

		local scrollTile = v27:GetAttribute("ScrollTile")

		if scrollTile and scrollTile > 0 then
			v27.OffsetStudsV = ((v27:GetAttribute("BaseOff") or 0) + v23.ScrollDir * v22.scroll) % scrollTile
		end
	end
end

local function applySkinTexture(instance, data, studsPerTileU, studsPerTileV)
	local zA = instance:GetAttribute("zA") or v.Highway.Extend
	local v27 = v.Highway.Extend - zA
	instance.Texture = data.Image
	instance.Transparency = instance:GetAttribute("FadeTr") or 0

	if data.Mode == "Stretch" then
		instance.StudsPerTileU = studsPerTileU
		instance.StudsPerTileV = studsPerTileV
		instance.OffsetStudsV = v.Highway.TexOffsetSign * v27 % studsPerTileV
		instance:SetAttribute("ScrollTile", 0)
	else
		local studsPerTileU2 = studsPerTileU * (data.TileScale or 1)
		local studsPerTileV2 = studsPerTileU2 * (data.TileAspect or 1)
		instance.StudsPerTileU = studsPerTileU2
		instance.StudsPerTileV = studsPerTileV2
		local v28 = v.Highway.TexOffsetSign * v27
		instance:SetAttribute("BaseOff", v28)
		instance:SetAttribute("ScrollTile", studsPerTileV2)
		instance.OffsetStudsV = (v28 + v23.ScrollDir * v22.scroll) % studsPerTileV2
	end
end

local function tapeColor(noteOuterColorForLane3D) -- 2 equivalent calls inferred from this helper
	return gemBodyColor(noteOuterColorForLane3D):Lerp(Color3.fromRGB(120, 114, 100), 0.45) -- inferred equivalent call
end

local function buildReceptor(_, p, noteOuterColorForLane3D, name, p2, p3)
	local receptor = v.Receptor
	local padRestY = receptor.PadRestY
	local idleRing = v23.idleRing(p2)

	local disc = makeDisc(receptor.PadDiameter + 0.28, 0.12, Color3.fromRGB(50, 46, 44)) -- inferred equivalent call
	disc.Material = Enum.Material.Metal
	disc.CFrame = cframe * CFrame.new(p, padRestY - 0.14, 0) * cframe2
	disc.Parent = worldModel
	table.insert(v9, disc)

	local disc2 = makeDisc(receptor.PadDiameter, receptor.PadThickness, Color3.fromRGB(10, 10, 12)) -- inferred equivalent call
	local v27 = cframe * CFrame.new(p, padRestY, 0) * cframe2
	local pressedCF = cframe * CFrame.new(p, padRestY - receptor.PressDepth, 0) * cframe2
	disc2.CFrame = v27
	disc2.Parent = worldModel
	table.insert(v9, disc2)

	local capDecal = addDecal(disc2, tex.Cap, color) -- inferred equivalent call
	local ringDecal = addDecal(disc2, tex.Ring, idleRing, 2) -- inferred equivalent call
	v23.grungeDecal(disc2, Enum.NormalId.Right, 3, 0.05)

	local disc3 = makeDisc(receptor.PadDiameter * 0.6, 0.03, color) -- inferred equivalent call
	disc3.Material = Enum.Material.Neon
	disc3.Transparency = 1
	local cframe3 = CFrame.new(receptor.PadThickness / 2 + 0.02, 0, 0)
	disc3.CFrame = v27 * cframe3
	disc3.Parent = worldModel
	table.insert(v9, disc3)

	return {
		Pad = disc2,
		Part = disc2,
		CapDecal = capDecal,
		RingDecal = ringDecal,
		Lamp = disc3,
		LampOff = cframe3,
		AccentColor = noteOuterColorForLane3D,
		IdleColor = idleRing,
		RingColor = p2,
		PressColor = p3,
		OriginalAccentColor = noteOuterColorForLane3D,
		OriginalIdleColor = idleRing,
		OriginalRingColor = p2,
		OriginalPressColor = p3,
		Housing = disc,
		RestCF = v27,
		PressedCF = pressedCF,
		IsPressed = false,
		PressTween = nil,
		RingTween = nil,
		LampTween = nil,
		KeyText = name,
		ScreenPos = Vector2.new(640, 600),
		HoldUntil = 0,
		HoldFade = 0,
		HoldAcc = 0,
		EmberAcc = 0,
		BoltAcc = 0,
		GlowLevel = 0,
		TargetGlow = 0
	}
end

local function setRingResting(data) -- 3 equivalent calls inferred from this helper
	if data.RingTween then
		data.RingTween:Cancel()
	end

	local color3

	if data.IsPressed then
		color3 = (v6 and ENERGY_COLOR or data.PressColor):Lerp(color, 0.28)
	else
		color3 = data.IdleColor
	end

	data.RingDecal.Color3 = color3
end

local function applyFretStarPowerTint(state, p)
	if p then
		state.AccentColor = ENERGY_COLOR
		state.IdleColor = v23.idleRing(ENERGY_COLOR)
		state.PressColor = ENERGY_COLOR
	else
		state.AccentColor = state.OriginalAccentColor
		state.IdleColor = state.OriginalIdleColor
		state.PressColor = state.OriginalPressColor
	end

	TweenService:Create(state.RingDecal, TINT_TWEEN_INFO, {
		Color3 = state.IsPressed and state.PressColor:Lerp(color, 0.28) or state.IdleColor
	}):Play()
end

local function buildHighway(p, p2, p3, p4, p5)
	clearAll()
	v22.buildArgs = table.pack(p, p2, p3, p4, p5)
	v22.builtLength = v.Highway.Length

	local v27 = p2 or RhythmEngineConfig.LaneCount[p]

	if not v27 then
		warn("[NoteLaneUI3D] No LaneCount for instrument:", p)
		return
	end

	v18 = SettingsState.GetRhythmLaneColors(v27)
	v19 = SettingsState.GetRhythmShape()
	v20 = p5

	local v28 = p3 or RhythmEngineConfig.KeyBindings[p] or {}

	instLabel.Text = v.InstrumentNames[p] or p
	instLabel.Visible = true

	local highway = v.Highway
	local studsPerTileU = v27 * highway.LaneWidth
	v15 = v27

	local extend = highway.Extend
	local fadeLen = highway.FadeLen
	local zB = -(highway.Length - fadeLen)

	local fadeSlices = highway.FadeSlices
	local v29 = {
		{ zA = extend, zB = zB, tr = 0 }
	}

	for i = 1, fadeSlices do
		local v30 = (i - 0.5) / fadeSlices
		table.insert(v29, {
			zA = zB - (i - 1) * fadeLen / fadeSlices,
			zB = zB - i * fadeLen / fadeSlices,
			tr = math.clamp(0.99 * v30 ^ 1.5, 0, 0.99)
		})
	end

	local function mixT(p6, p7)
		return p6 + (1 - p6) * p7
	end

	v14 = getSkin()
	local starTint = v6 and (v14.StarTint or highway.TexTintStar) or v14.Tint or highway.TexTint
	local color5 = v6 and ENERGY_COLOR or highway.RailGlow
	local v30 = {}
	local v31 = {}
	local v32 = {}

	for i = 1, v27 do
		local v37 = v27 > 1 and (i - 1) / (v27 - 1) or 0
		v30[i] = {}
		v31[i] = 0.17 + -0.085 * v37
		v32[i] = Color3.fromRGB(138, 120, 96):Lerp(Color3.fromRGB(196, 200, 212), v37)
	end

	for i, v37 in ipairs(v29) do
		local v38 = i < #v29 and 0.05 or 0
		local v39 = v37.zA - v37.zB + v38
		local v40 = (v37.zA + v37.zB) / 2 - v38 / 2
		local v41 = #v9 + 1

		local vector3 = Vector3.new(studsPerTileU, 0.25, v39)
		local cframe3 = cframe * CFrame.new(0, -0.12, v40)
		local plateColor = v14.PlateColor or highway.PlateColor
		local smoothPlastic = Enum.Material.SmoothPlastic
		local tr = v37.tr
		local part = Instance.new("Part")
		part.Size = vector3
		part.CFrame = cframe3
		part.Color = plateColor
		part.Material = smoothPlastic or Enum.Material.SmoothPlastic
		part.Transparency = tr or 0
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Parent = worldModel

		table.insert(v9, part)
		local texture = Instance.new("Texture")
		texture.Face = Enum.NormalId.Top
		texture:SetAttribute("zA", v37.zA)
		texture:SetAttribute("FadeTr", v37.tr)
		applySkinTexture(texture, v14, studsPerTileU, highway.Length + extend)
		texture.Color3 = starTint
		texture.Parent = part
		table.insert(v13, texture)
		v12 = v12 or texture

		for _, v43 in ipairs({ -1, 1 }) do
			local v44 = v43 * (studsPerTileU / 2 + highway.RailW / 2)
			local vector3_2 = Vector3.new(highway.RailW, highway.RailH, v39)
			local cframe4 = cframe * CFrame.new(v44, highway.RailH / 2 - 0.2, v40)
			local railColor = highway.RailColor
			local metal = Enum.Material.Metal
			local tr2 = v37.tr
			local part2 = Instance.new("Part")
			part2.Size = vector3_2
			part2.CFrame = cframe4
			part2.Color = railColor
			part2.Material = metal or Enum.Material.SmoothPlastic
			part2.Transparency = tr2 or 0
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanQuery = false
			part2.CanTouch = false
			part2.CastShadow = false
			part2.Parent = worldModel

			table.insert(v9, part2)

			if tex.RailGrunge then
				v23.gTex(part2, Enum.NormalId.Top, tex.RailGrunge, 1.6, 6, v37.zA)
				v23.gTex(part2, v43 < 0 and Enum.NormalId.Right or Enum.NormalId.Left, tex.RailGrunge, 6, 1.6, v37.zA)
			end

			if tex.EdgeGrunge then
				local vector3_3 = Vector3.new(0.9, 0.02, v39)
				local cframe5 = cframe * CFrame.new(v43 * (studsPerTileU / 2 - 0.45), 0.02, v40)
				local color3 = Color3.fromRGB(30, 30, 34)
				local smoothPlastic2 = Enum.Material.SmoothPlastic
				local tr3 = v37.tr
				local part3 = Instance.new("Part")
				part3.Size = vector3_3
				part3.CFrame = cframe5
				part3.Color = color3
				part3.Material = smoothPlastic2 or Enum.Material.SmoothPlastic
				part3.Transparency = tr3 or 0
				part3.Anchored = true
				part3.CanCollide = false
				part3.CanQuery = false
				part3.CanTouch = false
				part3.CastShadow = false
				part3.Parent = worldModel

				table.insert(v9, part3)
				v23.gTex(part3, Enum.NormalId.Top, tex.EdgeGrunge, 1.8, 3.6, v37.zA)
			end

			local v46 = v9
			local vector3_3 = Vector3.new(highway.RailW * 0.45, 0.06, v39)
			local cframe5 = cframe * CFrame.new(v44 + v43 * highway.RailW * 0.12, highway.RailH - 0.18, v40)
			local color3 = Color3.fromRGB(160, 163, 176)
			local metal2 = Enum.Material.Metal
			local tr3 = v37.tr
			local part3 = Instance.new("Part")
			part3.Size = vector3_3
			part3.CFrame = cframe5
			part3.Color = color3
			part3.Material = metal2 or Enum.Material.SmoothPlastic
			part3.Transparency = tr3 or 0
			part3.Anchored = true
			part3.CanCollide = false
			part3.CanQuery = false
			part3.CanTouch = false
			part3.CastShadow = false
			part3.Parent = worldModel

			table.insert(v46, part3)
			local vector3_4 = Vector3.new(0.07, 0.05, v39)
			local cframe6 = cframe * CFrame.new(v43 * (studsPerTileU / 2 + 0.03), 0.06, v40)
			local neon = Enum.Material.Neon
			local v49 = 0.2 + 0.8 * v37.tr
			local part4 = Instance.new("Part")
			part4.Size = vector3_4
			part4.CFrame = cframe6
			part4.Color = color5
			part4.Material = neon or Enum.Material.SmoothPlastic
			part4.Transparency = v49 or 0
			part4.Anchored = true
			part4.CanCollide = false
			part4.CanQuery = false
			part4.CanTouch = false
			part4.CastShadow = false
			part4.Parent = worldModel

			table.insert(v9, part4)
			table.insert(v10, part4)
		end

		if v37.tr > 0 then
			for j = v41, #v9 do
				for _, child in ipairs(v9[j]:GetChildren()) do
					if not ((child:IsA("Texture") or child:IsA("Decal")) and child.Transparency < v37.tr) then
						continue
					end

					child.Transparency = v37.tr
				end
			end
		end

		local v43 = math.min(v37.zA, 0)

		if not (v37.zB < v43) then
			continue
		end

		local v44 = v43 - v37.zB + v38
		local v45 = (v43 + v37.zB) / 2 - v38 / 2

		for j = 1, v27 do
			local part2 = Instance.new("Part")
			part2.Shape = Enum.PartType.Cylinder
			part2.Size = Vector3.new(v44, v31[j], v31[j])
			part2.CFrame = cframe * CFrame.new(laneLocalX(j, v27), 0.09, v45) * CFrame.Angles(0, 1.5707963267948966, 0) -- inferred equivalent call
			part2.Color = v32[j]
			part2.Material = Enum.Material.Metal
			part2.Transparency = v37.tr
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanQuery = false
			part2.CanTouch = false
			part2.CastShadow = false
			part2.Parent = worldModel
			table.insert(v9, part2)
			table.insert(v30[j], part2)
		end
	end

	local _receptor = v.Receptor
	local v37 = v9
	local vector3 = Vector3.new(studsPerTileU, 0.08, 0.14)
	local cframe3 = cframe * CFrame.new(0, 0.06, -0.05)
	local color3 = Color3.fromRGB(210, 213, 225)
	local metal = Enum.Material.Metal
	local part = Instance.new("Part")
	part.Size = vector3
	part.CFrame = cframe3
	part.Color = color3
	part.Material = metal or Enum.Material.SmoothPlastic
	part.Transparency = 0
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Parent = worldModel

	table.insert(v37, part)

	for i = 1, v27 do
		local noteOuterColorForLane3D = getNoteOuterColorForLane3D(i) -- inferred equivalent call
		local name = v28[i] and v28[i].Name or "?"
		v7[i] = buildReceptor(
			i,
			laneLocalX(i, v27), -- inferred equivalent call
			noteOuterColorForLane3D,
			name,
			getReceptorRingColorForLane3D(i), -- inferred equivalent call
			getReceptorPressColorForLane3D(i) -- inferred equivalent call
		)

		local receptor = v.Receptor
		local v40 = laneLocalX(i, v27) -- inferred equivalent call
		local labelYaw = math.rad(i * 37 % 9 - 4)
		local vector3_2 = Vector3.new(receptor.LabelW + 0.12, 0.03, receptor.LabelD + 0.12)
		local cframe4 = cframe * CFrame.new(v40, 0.03, receptor.LabelZ) * CFrame.Angles(0, labelYaw, 0)
		local color4 = Color3.fromRGB(18, 18, 20)
		local smoothPlastic = Enum.Material.SmoothPlastic
		local part2 = Instance.new("Part")
		part2.Size = vector3_2
		part2.CFrame = cframe4
		part2.Color = color4
		part2.Material = smoothPlastic or Enum.Material.SmoothPlastic
		part2.Transparency = 0
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.CastShadow = false
		part2.Parent = worldModel

		local vector3_3 = Vector3.new(receptor.LabelW, 0.04, receptor.LabelD)
		local cframe5 = cframe * CFrame.new(v40, 0.05, receptor.LabelZ) * CFrame.Angles(0, labelYaw, 0)
		local color6 = tapeColor(noteOuterColorForLane3D) -- inferred equivalent call
		local smoothPlastic2 = Enum.Material.SmoothPlastic
		local part3 = Instance.new("Part")
		part3.Size = vector3_3
		part3.CFrame = cframe5
		part3.Color = color6
		part3.Material = smoothPlastic2 or Enum.Material.SmoothPlastic
		part3.Transparency = 0
		part3.Anchored = true
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CanTouch = false
		part3.CastShadow = false
		part3.Parent = worldModel

		table.insert(v9, part2)
		table.insert(v9, part3)
		v23.grungeDecal(part3, Enum.NormalId.Top, 1, 0.2)
		v7[i].Tape = part3
		v7[i].LabelYaw = labelYaw

		v7[i].Strings = v30[i]
		v7[i].StringColor = v30[i][1].Color
	end

	highway3D.Visible = true
end

local function reapplySkin()
	if #v13 == 0 then
		return
	end

	local skin = getSkin()
	v14 = skin
	local studsPerTileU = v15 * v.Highway.LaneWidth
	local studsPerTileV = v.Highway.Length + v.Highway.Extend

	for _, v27 in ipairs(v13) do
		if not v27.Parent then
			continue
		end

		applySkinTexture(v27, skin, studsPerTileU, studsPerTileV)
		v27.Color3 = v6 and (skin.StarTint or v.Highway.TexTintStar) or skin.Tint or v.Highway.TexTint
		v27.Parent.Color = skin.PlateColor or v.Highway.PlateColor
	end
end

v22.loaded = {}
function v23.preloadSkins()
	if v22.skinPreloadStarted then
		return
	end

	v22.skinPreloadStarted = true
	task.spawn(function()
		for _, v27 in ipairs(HighwaySkins.GetAll()) do
			if v27.IsRandom or not v27.Image then
				continue
			end

			local decal = Instance.new("Decal")
			decal.Texture = v27.Image
			pcall(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync({ decal })
			end)
			decal:Destroy()
			v22.loaded[v27.Id] = true
		end
	end)
end
task.defer(v23.preloadSkins)

function v23.rerollSkin()
	local skin = getSkin()

	if skin and skin.Image then
		task.spawn(function()
			pcall(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync({ skin.Image })
			end)
		end)
	end

	reapplySkin()
end

local function refreshRhythmCustomization3D()
	reapplySkin()
	v23.railRefresh()

	if not v15 then
		return
	end

	v18 = SettingsState.GetRhythmLaneColors(v15)
	v19 = SettingsState.GetRhythmShape()

	for k, v27 in pairs(v7) do
		local noteOuterColorForLane3D = getNoteOuterColorForLane3D(k) -- inferred equivalent call
		local receptorRingColorForLane3D = getReceptorRingColorForLane3D(k) -- inferred equivalent call
		local receptorPressColorForLane3D = getReceptorPressColorForLane3D(k) -- inferred equivalent call
		v27.OriginalAccentColor = noteOuterColorForLane3D
		v27.OriginalRingColor = receptorRingColorForLane3D
		v27.OriginalPressColor = receptorPressColorForLane3D
		v27.OriginalIdleColor = v23.idleRing(receptorRingColorForLane3D)

		if v27.Tape then
			v27.Tape.Color = tapeColor(noteOuterColorForLane3D) -- inferred equivalent call
		end

		if v6 then
			continue
		end

		v27.AccentColor = noteOuterColorForLane3D
		v27.RingColor = receptorRingColorForLane3D
		v27.PressColor = receptorPressColorForLane3D
		v27.IdleColor = v27.OriginalIdleColor
		setRingResting(v27) -- inferred equivalent call
	end

	for _, v27 in pairs(v8) do
		if not v27.Lane or v27.Dismissed then
			continue
		end

		local capShapeKind = v24[v19] or "Disc"

		if capShapeKind ~= v27.CapShapeKind then
			v27.CapShapeKind = capShapeKind
			local cap = v27.Cap
			cap.Shape = capKindToPartType(capShapeKind) -- inferred equivalent call
		end

		local noteOuterColorForLane3D = getNoteOuterColorForLane3D(v27.Lane) -- inferred equivalent call
		local noteInnerColorForLane3D = getNoteInnerColorForLane3D(v27.Lane) -- inferred equivalent call
		v27.AccentColor = noteOuterColorForLane3D

		if not v6 then
			v27.CapColor = noteInnerColorForLane3D or noteOuterColorForLane3D:Lerp(color, 0.82)
			v27.Cap.Color = v27.CapColor
			v27.Body.Color = gemBodyColor(noteOuterColorForLane3D) -- inferred equivalent call
			v27.Mid.Color = gemBodyColor(noteOuterColorForLane3D):Lerp(color2, 0.25) -- inferred equivalent call
			v27.GemDecal.Color3 = gemDecalColor(noteOuterColorForLane3D) -- inferred equivalent call
		end

		if v27.HoldGlow then
			v27.HoldGlow.Color = noteOuterColorForLane3D
		end
	end
end

SettingsState.OnChanged(refreshRhythmCustomization3D)
SettingsState.OnChanged(function()
	v23.applyCameraSettings()
end)

local function buildUI()
	if noteLaneUI3D then
		return
	end

	noteLaneUI3D = Instance.new("ScreenGui")
	noteLaneUI3D.Name = "NoteLaneUI3D"
	noteLaneUI3D.ResetOnSpawn = false
	noteLaneUI3D.Enabled = false
	noteLaneUI3D.DisplayOrder = -1
	noteLaneUI3D.Parent = playerGui

	glowLayer = Instance.new("Frame")
	glowLayer.Name = "GlowLayer"
	glowLayer.Size = UDim2.new(1, 0, 1, 0)
	glowLayer.BackgroundTransparency = 1
	glowLayer.ClipsDescendants = false
	glowLayer.ZIndex = 0
	glowLayer.Parent = noteLaneUI3D

	v5 = StarPowerVisualEffects.BuildAtmosphere(noteLaneUI3D)

	highway3D = Instance.new("ViewportFrame")
	highway3D.Name = "Highway3D"
	highway3D.AnchorPoint = Vector2.new(0.5, 1)
	highway3D.Position = UDim2.new(0.5, 0, 1, 0)
	highway3D.Size = UDim2.new(0, 720, 0, 540)
	highway3D.BackgroundTransparency = 1
	highway3D.Ambient = Color3.fromRGB(118, 118, 130)
	highway3D.LightColor = Color3.fromRGB(225, 225, 235)
	highway3D.LightDirection = Vector3.new(-0.35, -1, -0.65)
	highway3D.Visible = false
	highway3D.ZIndex = 2
	highway3D.Parent = noteLaneUI3D

	worldModel = Instance.new("WorldModel")
	worldModel.Parent = highway3D

	camera = Instance.new("Camera")
	camera.CameraType = Enum.CameraType.Scriptable
	pcall(function()
		v.Camera.Elevation = math.clamp(SettingsState.GetHighwayCamElevation(), 18, 50)
		v.Camera.FOV = math.clamp(SettingsState.GetHighwayCamFov(), 25, 60)
		v.Camera.Zoom = math.clamp(SettingsState.GetHighwayCamZoom(), 0.5, 0.88)
		v.Camera.HitNy = -math.clamp(SettingsState.GetHighwayCamHitY(), 0.2, 0.7)
		v.Highway.Length = math.clamp(SettingsState.GetHighwayCamLength(), 30, 60)
	end)
	camera.FieldOfView = v.Camera.FOV
	local v27 = computeLookAt()
	camera.CFrame = CFrame.lookAt(toWorld(v.Camera.Pos.X, v.Camera.Pos.Y, v.Camera.Pos.Z), toWorld(v27.X, v27.Y, v27.Z)) -- inferred equivalent call
	camera.Parent = highway3D
	highway3D.CurrentCamera = camera

	fxLayer = Instance.new("Frame")
	fxLayer.Name = "FxLayer"
	fxLayer.Size = UDim2.new(1, 0, 1, 0)
	fxLayer.BackgroundTransparency = 1
	fxLayer.ClipsDescendants = false
	fxLayer.Active = false
	fxLayer.ZIndex = 4
	fxLayer.Parent = noteLaneUI3D

	instLabel = Instance.new("TextLabel")
	instLabel.Name = "InstLabel"
	instLabel.AnchorPoint = Vector2.new(0.5, 1)
	instLabel.Position = UDim2.new(0.5, 0, 1, -520)
	instLabel.Size = UDim2.new(0, 360, 0, 28)
	instLabel.BackgroundTransparency = 1
	instLabel.Font = Enum.Font.GothamBlack
	instLabel.TextSize = 19
	instLabel.TextColor3 = Color3.fromRGB(210, 210, 225)
	instLabel.TextStrokeTransparency = 0.12
	instLabel.Text = ""
	instLabel.Visible = false
	instLabel.ZIndex = 5
	instLabel.Parent = noteLaneUI3D

	judgmentLabel = Instance.new("TextLabel")
	judgmentLabel.Name = "JudgmentLabel"
	judgmentLabel.AnchorPoint = Vector2.new(0.5, 1)
	judgmentLabel.Position = UDim2.new(0.5, 0, 1, -360)
	judgmentLabel.Size = UDim2.new(0, 340, 0, 52)
	judgmentLabel.BackgroundTransparency = 1
	judgmentLabel.Font = Enum.Font.GothamBlack
	judgmentLabel.TextSize = 36
	judgmentLabel.TextTransparency = 1
	judgmentLabel.TextStrokeTransparency = 0.2
	judgmentLabel.Text = ""
	judgmentLabel.ZIndex = 6
	judgmentLabel.Parent = noteLaneUI3D

	uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = judgmentLabel

	countdown = Instance.new("TextLabel")
	countdown.Name = "Countdown"
	countdown.AnchorPoint = Vector2.new(0.5, 0.5)
	countdown.Position = UDim2.new(0.5, 0, 1, -330)
	countdown.Size = UDim2.new(0, 100, 0, 100)
	countdown.BackgroundColor3 = color
	countdown.BackgroundTransparency = 0.92
	countdown.Font = Enum.Font.GothamBlack
	countdown.TextSize = 38
	countdown.TextColor3 = Color3.fromRGB(235, 235, 245)
	countdown.Text = ""
	countdown.Visible = false
	countdown.ZIndex = 6
	countdown.Parent = noteLaneUI3D

	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = 38
	uiTextSizeConstraint.MinTextSize = 16
	uiTextSizeConstraint.Parent = countdown
	countdown.TextScaled = true

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = countdown

	countdownCaption = Instance.new("TextLabel")
	countdownCaption.Name = "CountdownCaption"
	countdownCaption.AnchorPoint = Vector2.new(0.5, 0)
	countdownCaption.Position = UDim2.new(0.5, 0, 1, 8)
	countdownCaption.Size = UDim2.new(0, 240, 0, 22)
	countdownCaption.BackgroundTransparency = 1
	countdownCaption.Font = Enum.Font.GothamBold
	countdownCaption.TextSize = 15
	countdownCaption.TextColor3 = Color3.fromRGB(200, 200, 215)
	countdownCaption.TextStrokeTransparency = 0.3
	countdownCaption.Text = "Bersiap..."
	countdownCaption.Visible = false
	countdownCaption.ZIndex = 6
	countdownCaption.Parent = countdown

	v4 = CountdownFx.Attach(countdown, countdownCaption)

	v25.InputGui = Instance.new("ScreenGui")
	v25.InputGui.Name = "NoteLaneUI3DInput"
	v25.InputGui.ResetOnSpawn = false
	v25.InputGui.Enabled = false
	v25.InputGui.Parent = playerGui

	v25.InputContainer = Instance.new("Frame")
	v25.InputContainer.Name = "Lanes"
	v25.InputContainer.Size = UDim2.new(1, 0, 1, 0)
	v25.InputContainer.BackgroundTransparency = 1
	v25.InputContainer.BorderSizePixel = 0
	v25.InputContainer.Active = false
	v25.InputContainer.Parent = v25.InputGui

	noteLaneUI3D:GetPropertyChangedSignal("AbsoluteSize"):Connect(v25.apply)

	if LocalPlayer then
		LocalPlayer:GetAttributeChangedSignal("HighwaySkin"):Connect(reapplySkin)
	end

	v25.apply()
end

fn = function()
	if not (camera and fxLayer) then
		return
	end

	local v27 = v15
	local v28 = v.Receptor.PadRestY + 0.12
	local v29 = v25.project(toWorld(laneLocalX(1, v27), v28, 0)) -- inferred equivalent call
	local v30

	if v27 > 1 then
		v30 = v25.project(toWorld(laneLocalX(2, v27), v28, 0)) or nil -- inferred equivalent call
	end

	v25.FxUnit = v29 and v30 and math.max((v30 - v29).Magnitude, 24) or 90 * v25.Scale
	local fxUnit = v25.FxUnit

	for k, v31 in pairs(v7) do
		local screenPos2 = v25.project(toWorld(laneLocalX(k, v27), v28, 0)) -- inferred equivalent call

		if screenPos2 then
			v31.ScreenPos = screenPos2
		end

		local screenPos = v31.ScreenPos
		local v32 = v25.project(toWorld(laneLocalX(k, v27), 0.08, v.Receptor.LabelZ)) -- inferred equivalent call
			or screenPos + Vector2.new(0, fxUnit * 0.95)

		if not v31.GlowLabel then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "PressGlow" .. k
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = tex.Glow
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.ZIndex = 1
			imageLabel.Visible = false
			imageLabel.Active = false
			imageLabel.Parent = fxLayer
			v31.GlowLabel = imageLabel
		end

		v31.GlowLabel.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
		v31.GlowLabel.Size = UDim2.fromOffset(fxUnit * 1.8, fxUnit * 1.8)

		if not v31.HoldFlame then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "HoldFlame" .. k
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = tex.Flame
			imageLabel.ImageRectSize = Vector2.new(256, 256)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.9)
			imageLabel.ZIndex = 3
			imageLabel.Visible = false
			imageLabel.Active = false
			imageLabel.Parent = fxLayer
			v31.HoldFlame = imageLabel
		end

		v31.HoldFlame.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
		v31.HoldFlame.Size = UDim2.fromOffset(fxUnit * 1.1, fxUnit * 1.3)

		if v31.KeyLabel then
			v31.KeyLabel:Destroy()
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Key" .. k
		textLabel.BackgroundTransparency = 1
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromOffset(v32.X, v32.Y)
		textLabel.Rotation = -math.deg(v31.LabelYaw or 0)
		textLabel.Size = UDim2.fromOffset(fxUnit * 0.8, fxUnit * 0.8)
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.TextSize = math.max(10, (math.floor(fxUnit * 0.34)))
		textLabel.TextColor3 = Color3.fromRGB(20, 20, 22)
		textLabel.TextStrokeColor3 = Color3.fromRGB(215, 210, 195)
		textLabel.TextStrokeTransparency = 0.62
		textLabel.Text = v31.KeyText

		pcall(function()
			local ControllerGlyphs = require(script.Parent.ControllerGlyphs)
			local labelFromName = ControllerGlyphs.LabelFromName(v31.KeyText)

			if labelFromName then
				textLabel.Text = labelFromName
				textLabel.TextSize = math.max(9, (math.floor(fxUnit * 0.28)))
			end
		end)
		textLabel.ZIndex = 8
		textLabel.Parent = fxLayer
		v31.KeyLabel = textLabel
		pcall(function()
			local KeyArrowIcon = require(script.Parent.KeyArrowIcon)
			local rotation = KeyArrowIcon.GetRotation(v31.KeyText)

			if rotation then
				textLabel.Text = ""
				KeyArrowIcon.Create(
					textLabel,
					rotation,
					math.floor(fxUnit * 0.42),
					Color3.fromRGB(22, 22, 24),
					Color3.fromRGB(215, 210, 195),
					0.6
				)
			end

			local KeySpaceCap = require(script.Parent.KeySpaceCap)

			if KeySpaceCap.IsSpace(v31.KeyText) then
				textLabel.Text = ""
				KeySpaceCap.Create(
					textLabel,
					math.floor(fxUnit * 0.62),
					math.floor(fxUnit * 0.2),
					Color3.fromRGB(22, 22, 24),
					Color3.fromRGB(215, 210, 195),
					0.6,
					0.5
				)
			end
		end)
	end
end

local function pressReceptor(state)
	if state.PressTween then
		state.PressTween:Cancel()
	end

	if state.LampTween then
		state.LampTween:Cancel()
	end

	state.PressTween = TweenService:Create(
		state.Pad,
		TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = state.PressedCF }
	)
	state.PressTween:Play()
	state.Lamp.CFrame = state.PressedCF * state.LampOff
	state.Lamp.Color = fxColor(state):Lerp(color, 0.35) -- inferred equivalent call
	state.Lamp.Transparency = 0.3
	state.TargetGlow = 0.5

	if state.Strings then
		local lerped = state.StringColor:Lerp(fxColor(state), 0.4) -- inferred equivalent call

		for _, str in ipairs(state.Strings) do
			str.Color = lerped
		end
	end

	setRingResting(state) -- inferred equivalent call
end

local function releaseReceptor(state)
	if state.PressTween then
		state.PressTween:Cancel()
	end

	if state.LampTween then
		state.LampTween:Cancel()
	end

	state.PressTween = TweenService:Create(
		state.Pad,
		TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ CFrame = state.RestCF }
	)
	state.PressTween:Play()
	state.Lamp.CFrame = state.RestCF * state.LampOff
	state.LampTween = TweenService:Create(state.Lamp, TweenInfo.new(0.18), { Transparency = 1 })
	state.LampTween:Play()
	state.TargetGlow = 0

	if state.Strings then
		for _, str in ipairs(state.Strings) do
			str.Color = state.StringColor
		end
	end

	setRingResting(state) -- inferred equivalent call
end

local function dismissNoteAt(p)
	local v27 = v7[p]

	if not v27 then
		return
	end

	local v28 = 1e999
	local v29 = nil

	for _, v30 in pairs(v8) do
		if v30.Lane ~= p or v30.Dismissed then
			continue
		end

		local magnitude = (v30.Base.Position - v27.Pad.Position).Magnitude

		if not (magnitude < v28) then
			continue
		end

		v29 = v30
		v28 = magnitude
	end

	if not v29 or v29.HoldPart then
		return
	end

	v29.Dismissed = true
	local tweenInfo = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(v29.Base, tweenInfo, { Size = Vector3.new(0.02, 0.02, 0.02) }):Play()
	TweenService:Create(v29.Cap, tweenInfo, { Size = Vector3.new(0.02, 0.02, 0.02) }):Play()
	TweenService:Create(v29.Body, tweenInfo, { Size = Vector3.new(0.02, 0.02, 0.02) }):Play()
	TweenService:Create(v29.Mid, tweenInfo, { Size = Vector3.new(0.02, 0.02, 0.02) }):Play()
	task.delay(tweenInfo.Time, function()
		if v29.Base and v29.Base.Parent then
			v29.Base:Destroy()
		end

		if v29.Cap and v29.Cap.Parent then
			v29.Cap:Destroy()
		end

		if v29.Body and v29.Body.Parent then
			v29.Body:Destroy()
		end

		if v29.Mid and v29.Mid.Parent then
			v29.Mid:Destroy()
		end
	end)
end

local function shakeBoard(p)
	local v27 = p and v7[p]

	if not v27 then
		return
	end

	if v27.RingTween then
		v27.RingTween:Cancel()
	end

	v27.RingDecal.Color3 = Color3.fromRGB(255, 40, 40)
	v27.RingTween = TweenService:Create(
		v27.RingDecal,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Color3 = v27.IsPressed and v27.PressColor or v27.IdleColor
		}
	)

	v27.RingTween:Play()
	spawnBurst(v27, Color3.fromRGB(170, 170, 185), getQ().sparks > 8 and 4 or 2, 0.5) -- inferred equivalent call
end

local function starPowerCameraPunch(value)
	if not camera then
		return
	end

	local fov = v.Camera.FOV
	TweenService:Create(camera, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = fov - 6 * (value or 1)
	}):Play()
	task.delay(0.08, function()
		if camera and camera.Parent then
			TweenService:Create(camera, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = fov
			}):Play()
		end
	end)
end

local function playHitEffect(p, value)
	dismissNoteAt(p)
	local v27 = v7[p]

	if not v27 then
		return
	end

	local q = getQ() -- inferred equivalent call
	local intensity = v23.intensity()
	local v28 = v6 and 1.5 or 1
	local v29 = v23.JudgeScale[value] or 0.8
	local v30 = intensity * v29 * v28
	local imageColor = fxColor(v27) -- inferred equivalent call
	local imageColor2 = getJudgmentColor3D(value) or imageColor -- inferred equivalent call

	local screenPos = v27.ScreenPos
	local fxUnit = v25.FxUnit

	if v27.RingTween then
		v27.RingTween:Cancel()
	end

	v27.RingDecal.Color3 = imageColor:Lerp(color, 0.6)
	v27.RingTween = TweenService:Create(
		v27.RingDecal,
		TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Color3 = v27.IsPressed and v27.PressColor:Lerp(color, 0.28) or v27.IdleColor
		}
	)

	v27.RingTween:Play()

	if q.flame then
		addFlame(screenPos, fxUnit * 1 * v30, imageColor, 0.5)
	end

	addSprite(
		tex.Glow,
		screenPos,
		fxUnit * 0.5,
		fxUnit * 0.5,
		fxUnit * (0.8 + 0.7 * intensity) * v29 * v28,
		fxUnit * (0.8 + 0.7 * intensity) * v29 * v28,
		imageColor,
		0.5,
		0.2,
		0,
		0,
		1,
		1.4
	)
	addSprite(
		tex.Shock,
		screenPos,
		fxUnit * 0.6,
		fxUnit * 0.6,
		fxUnit * (1.1 + 0.5 * intensity) * v29,
		fxUnit * (1.1 + 0.5 * intensity) * v29,
		imageColor2,
		0.3,
		0.3,
		0,
		0,
		2,
		1.2
	)

	if q.lightning or value == "Perfect" then
		if v6 then
			spawnLightning(v27, imageColor, 1.3)
		elseif math.random() < intensity ^ 1.5 then
			spawnLightning(v27, imageColor, 0.45 + 0.55 * intensity)
		end
	end

	spawnBurst(v27, imageColor, math.max(1, (math.floor(q.sparks * v30))), 0.55 + 0.45 * intensity)

	if q.embers > 0 and (intensity > 0.35 or v6) then
		spawnEmbers(v27, imageColor, math.max(1, (math.floor(q.embers * v30))))
	end

	if v27.Lamp then
		if v27.LampTween then
			v27.LampTween:Cancel()
		end

		v27.Lamp.CFrame = (v27.IsPressed and v27.PressedCF or v27.RestCF) * v27.LampOff
		v27.Lamp.Color = imageColor:Lerp(color, 0.55)
		v27.Lamp.Transparency = 0.05
		v27.LampTween = TweenService:Create(v27.Lamp, TweenInfo.new(0.2), {
			Transparency = v27.IsPressed and 0.3 or 1
		})
		v27.LampTween:Play()
	end
end

local flag = false
local function preloadAssets()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local v27 = {}

		for _, texture in pairs(tex) do
			local decal = Instance.new("Decal")
			decal.Texture = texture
			table.insert(v27, decal)
		end

		local skin = getSkin()

		if skin and skin.Image then
			local decal = Instance.new("Decal")
			decal.Texture = skin.Image
			table.insert(v27, decal)
		end

		pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync(v27)
		end)

		for _, v28 in ipairs(v27) do
			v28:Destroy()
		end
	end)
end

function v23.scheduleRebuild()
	v22.rebuildToken = (v22.rebuildToken or 0) + 1
	local rebuildToken = v22.rebuildToken
	task.delay(0.3, function()
		if not (rebuildToken == v22.rebuildToken and (highway3D and highway3D.Visible and v22.buildArgs)) then
			return
		end

		buildHighway(table.unpack(v22.buildArgs, 1, v22.buildArgs.n))

		if v23.afterCamera then
			v23.afterCamera()
		end
	end)
end

function v23.hud(childName)
	v22.hudMods = v22.hudMods or {}
	local v27 = v22.hudMods[childName]

	if v27 ~= nil then
		return v27 or nil
	end

	local success, result = pcall(function()
		return require(script.Parent:WaitForChild(childName, 5))
	end)
	v27 = success and result or false
	v22.hudMods[childName] = v27

	if not success then
		warn("[NoteLaneUI3D] " .. childName .. " gagal dimuat:", result)
	end

	return v27 or nil
end

function v23.onLayout()
	if v22.relayoutPending then
		return
	end

	v22.relayoutPending = true
	task.defer(function()
		v22.relayoutPending = false

		if not (highway3D and noteLaneUI3D and noteLaneUI3D.Enabled) then
			return
		end

		local hud = v23.hud("StarPowerUI")

		if hud and hud.Reposition then
			hud.Reposition(
				v25.W,
				v25.H,
				highway3D.AbsolutePosition.X + highway3D.AbsoluteSize.X,
				highway3D.AbsolutePosition.Y + highway3D.AbsoluteSize.Y / 2
			)
		end
	end)
end

function v23.railOn(): boolean
	local success, result = pcall(function()
		return SettingsState.GetRailHud3D and SettingsState.GetRailHud3D()
	end)
	return not success or result ~= false
end

function v23.railHide2D(rail2DHidden)
	local hud = v23.hud("GuiFade")

	if not (hud and hud.SetHidden) then
		return
	end

	local rockMeterUI = playerGui:FindFirstChild("RockMeterUI")
	local rockMeterUIContainer = rockMeterUI and rockMeterUI:FindFirstChild("Container")

	if rockMeterUIContainer then
		hud.SetHidden(rockMeterUIContainer, rail2DHidden)
	end

	local starPowerUI = playerGui:FindFirstChild("StarPowerUI")
	local meterContainer = starPowerUI and starPowerUI:FindFirstChild("MeterContainer", true)

	if meterContainer then
		hud.SetHidden(meterContainer, rail2DHidden)
	end

	v22.rail2DHidden = rail2DHidden
end

function v23.railRelease()
	local hud = v23.hud("RailHud3D")

	if hud and hud.IsBuilt() then
		hud.Destroy()
	end

	v22.railBuilt = false

	if v22.rail2DHidden then
		v23.railHide2D(false)
	end
end

function v23.railState()
	if v22.railTest then
		return v22.railTest
	end

	local hud = v23.hud("StarPowerUI")

	if hud and hud.GetRailState then
		local success, railState = pcall(hud.GetRailState)

		if success and railState then
			return railState
		end
	end

	return {}
end

function v23.railBuild()
	local hud = v23.hud("RailHud3D")

	if not (hud and worldModel and fxLayer and v15) then
		return
	end

	local railState = v23.railState()
	hud.Build({
		worldModel = worldModel,
		highwayCF = cframe,
		toWorld = toWorld,
		project = v25.project,
		fxLayer = fxLayer,
		totalWidth = v15 * v.Highway.LaneWidth,
		railW = v.Highway.RailW or 0.5,
		texRail = tex.RailGrunge,
		texGlow = tex.Glow,
		texLightning = tex.Lightning,
		thresholds = railState.thresholds,
		starColor = ENERGY_COLOR
	})

	v22.railBuilt = true
	v22.railHideT = 0
	v23.railHide2D(true)
end

function v23.railRefresh()
	if highway3D and highway3D.Visible and not v23.railOn() and v22.railBuilt then
		v23.railRelease()
	end
end

function v23.railUpdate(p)
	if not v23.railOn() then
		return
	end

	if not v22.railBuilt then
		if next(v7) == nil then
			return
		end

		v23.railBuild()

		if not v22.railBuilt then
			return
		end
	end

	local hud = v23.hud("RailHud3D")

	if not hud then
		return
	end

	local railState = v23.railState()
	local combo = v22.combo or 0
	local v27 = RhythmEngineConfig.GetComboMultiplier and RhythmEngineConfig.GetComboMultiplier(combo) or 1
	local comboMaxMultiplier = RhythmEngineConfig.ComboMaxMultiplier or 4
	local comboNotesPerLevel = RhythmEngineConfig.ComboNotesPerLevel or 10
	local starPowerScoreMultiplier = railState.active and (RhythmEngineConfig.StarPowerScoreMultiplier or 2) or 1
	hud.Update(p, {
		rock = v22.rock,
		mult = v27 * starPowerScoreMultiplier,
		maxMult = comboMaxMultiplier * starPowerScoreMultiplier,
		ledLit = comboMaxMultiplier <= v27 and 10 or math.floor(combo % comboNotesPerLevel / comboNotesPerLevel * 10),
		starMeter = railState.meter,
		starResource = railState.resource,
		starActive = railState.active,
		starSkill = railState.skill,
		low = not getQ().lightning -- inferred equivalent call
	})

	v22.railHideT = (v22.railHideT or 0) + p

	if v22.railHideT > 1 then
		v22.railHideT = 0
		v23.railHide2D(true)
	end
end

function NoteLaneUI3D._SetRailTest(railTest)
	v22.railTest = railTest
end

function NoteLaneUI3D.SetScoreState(p, p2)
	v22.combo = tonumber(p2) or 0
	local hud = v23.hud("ScoreDisplayUI")

	if hud then
		hud.SetState(p, p2)
	end
end

function NoteLaneUI3D:Show(p, p2, p3, p4, p5)
	if not flag then
		flag = true
		task.spawn(function()
			local v27 = {}

			for _, texture in pairs(tex) do
				local decal = Instance.new("Decal")
				decal.Texture = texture
				table.insert(v27, decal)
			end

			local skin = getSkin()

			if skin and skin.Image then
				local decal = Instance.new("Decal")
				decal.Texture = skin.Image
				table.insert(v27, decal)
			end

			pcall(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync(v27)
			end)

			for _, v28 in ipairs(v27) do
				v28:Destroy()
			end
		end)
	end

	v23.hud("RockMeterUI")
	v23.hud("ScoreDisplayUI")
	v22.rock = RockMeterConfig.Start
	buildUI()
	buildHighway(self, p, p2, p3, p4)
	v25.buildTouch(v15)
	v25.apply()
	v25.InputGui.Enabled = true
	noteLaneUI3D.Enabled = true
	v23.healView()

	if p5 then
		pcall(v23.recBegin, p5)
		local aura = v23.aura()

		if aura then
			aura:Reset(false)
		end
	end

	if not v26.conn then
		v26.conn = RunService.RenderStepped:Connect(function(dt)
			if not NoteLaneUI3D._Frozen then
				stepFx(dt)
				pcall(v23.feelStep, dt)
				pcall(v23.recStep, dt)
				pcall(v23.auraStep, dt)
			end
		end)
	end
end

function NoteLaneUI3D.Hide()
	if not noteLaneUI3D then
		return
	end

	v25.releaseAllTouch()
	v25.InputGui.Enabled = false
	noteLaneUI3D.Enabled = false
	clearAll()
	v18 = nil
	v22.rock = RockMeterConfig.Start

	if v22.aura then
		v22.aura:Reset(true)
	end

	v23.recReset()

	if v26.conn then
		v26.conn:Disconnect()
		v26.conn = nil
	end

	if highway3D then
		highway3D.Visible = false
	end

	if instLabel then
		instLabel.Visible = false
	end

	if v5 then
		v5(false)
	end

	v6 = false

	if NoteLaneUI3D._streakFx then
		NoteLaneUI3D._streakFx:Reset()
	end

	if v4 then
		v4:Reset()
	else
		NoteLaneUI3D.HideCountdown()
	end
end

function NoteLaneUI3D.SetStarPowerAtmosphere(p)
	if v5 then
		v5(p)
	end
end

function NoteLaneUI3D.SetStarPowerVisual(p)
	v6 = p

	for _, v27 in ipairs({ "RockMeterUI", "ScoreDisplayUI", "BandScoreUI" }) do
		local hud = v23.hud(v27)

		if hud and hud.SetStarPowerActive then
			pcall(hud.SetStarPowerActive, p)
		end
	end

	for _, v27 in pairs(v7) do
		applyFretStarPowerTint(v27, p)
	end

	for _, v27 in pairs(v8) do
		applyGemStarPowerTint(v27, p)
	end

	for _, instance in ipairs(v13) do
		local v27 = v14
		TweenService:Create(instance, TINT_TWEEN_INFO, {
			Color3 = p and (v27 and v27.StarTint or v.Highway.TexTintStar) or v27 and v27.Tint or v.Highway.TexTint
		}):Play()
	end

	for _, instance in ipairs(v10) do
		TweenService:Create(instance, TINT_TWEEN_INFO, {
			Color = p and ENERGY_COLOR or v.Highway.RailGlow
		}):Play()
	end
end

function NoteLaneUI3D.GetHitLineRect()
	if not (fxLayer and noteLaneUI3D and noteLaneUI3D.Enabled) then
		return nil
	end

	local minX = 1e999
	local maxX = -1e999
	local total = 0
	local count2 = 0

	for _, v27 in pairs(v7) do
		local screenPos = v27.ScreenPos

		if not screenPos then
			continue
		end

		minX = math.min(minX, screenPos.X)
		maxX = math.max(maxX, screenPos.X)
		total += screenPos.Y
		count2 += 1
	end

	if count2 == 0 then
		return nil
	end

	local fxUnit = v25.FxUnit or 90
	local absolutePosition = fxLayer.AbsolutePosition
	return absolutePosition.X + minX - fxUnit * 0.7, absolutePosition.Y + total / count2, maxX - minX + fxUnit * 1.4
end

function NoteLaneUI3D.GetReceptorPoints()
	if not (fxLayer and noteLaneUI3D and noteLaneUI3D.Enabled) then
		return nil
	end

	local absolutePosition = fxLayer.AbsolutePosition
	local fxUnit = v25.FxUnit or 90
	local result = {}

	for _, v27 in pairs(v7) do
		local screenPos = v27.ScreenPos

		if screenPos then
			result[#result + 1] = {
				X = absolutePosition.X + screenPos.X,
				Y = absolutePosition.Y + screenPos.Y,
				R = fxUnit * 0.48
			}
		end
	end

	return result
end

function NoteLaneUI3D.ShatterStreakNotice(p)
	local v27 = NoteLaneUI3D.ShowStreakNotice("__EnsureOnly")

	if v27 then
		v27:Shatter(p, SettingsState.GetHitSparkleEnabled())
	end
end

function NoteLaneUI3D.SetStarPowerPromptCharge(p, p2)
	if NoteLaneUI3D._streakFx then
		NoteLaneUI3D._streakFx:SetPromptCharge(p, p2)
	end
end

function NoteLaneUI3D.DismissStreakNotice(p)
	if NoteLaneUI3D._streakFx then
		NoteLaneUI3D._streakFx:Dismiss(p)
	end
end

function NoteLaneUI3D.ShowStreakNotice(p, p2)
	if not (noteLaneUI3D and noteLaneUI3D.Enabled) then
		return
	end

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local streakNoticeGui3D = NoteLaneUI3D._streakGui

	if not (streakNoticeGui3D and streakNoticeGui3D.Parent) then
		streakNoticeGui3D = Instance.new("ScreenGui")
		streakNoticeGui3D.Name = "StreakNoticeGui3D"
		streakNoticeGui3D.ResetOnSpawn = false
		streakNoticeGui3D.DisplayOrder = 20
		streakNoticeGui3D.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local container = Instance.new("Frame")
		container.Name = "Container"
		local GuiFade = require(ReplicatedStorage2.Modules.GuiFade)
		GuiFade.Attach(container, "StreakNotice", nil, GuiFade.Presets.TextContent)
		container.BackgroundTransparency = 1
		container.BorderSizePixel = 0
		container.Size = UDim2.fromScale(1, 1)
		container.Parent = streakNoticeGui3D
		local Players2 = game:GetService("Players")
		streakNoticeGui3D.Parent = Players2.LocalPlayer:WaitForChild("PlayerGui")
		NoteLaneUI3D._streakGui = streakNoticeGui3D

		if NoteLaneUI3D._streakFx then
			NoteLaneUI3D._streakFx:Reset()
			NoteLaneUI3D._streakFx = nil
		end
	end

	local container = streakNoticeGui3D.Container
	local streakFx = NoteLaneUI3D._streakFx

	if not streakFx or streakFx.Track ~= container then
		if streakFx then
			streakFx:Reset()
		end

		local StreakNoticeFx = require(ReplicatedStorage2.Modules.StreakNoticeFx)
		local attach = StreakNoticeFx.Attach

		local StreakNoticeFx2 = require(ReplicatedStorage2.Modules.StreakNoticeFx)
		streakFx = attach(container, {
			CenterY = 140,
			PromptPlaceFn = StreakNoticeFx2.MakeTopCenterPlace(container, function()
				return highway3D and highway3D.Visible and highway3D.AbsolutePosition.Y - 34 or nil
			end),
			StrikeTargetFn = function()
				return NoteLaneUI3D.GetHitLineRect()
			end,
			PlaceFn = function(p3, p4)
				local success, result = pcall(function()
					return require(ReplicatedStorage2.Modules.BandScoreUI)
				end)

				if success and result and result.GetNoticeSlot then
					local noticeSlot, v27, v28 = result.GetNoticeSlot()

					if noticeSlot then
						local absolutePosition = container.AbsolutePosition

						local v29 = not (v28 and v28 > 0) and 1 or math.clamp(v28 / p3, 0.5, 1)

						return noticeSlot - absolutePosition.X, v27 - p4 * v29 / 2 - absolutePosition.Y, v28
					end
				end

				return nil
			end
		})

		NoteLaneUI3D._streakFx = streakFx
	end

	if p == "__EnsureOnly" then
		return streakFx
	end

	streakFx:Show(p, p2, {
		Sparkle = SettingsState.GetHitSparkleEnabled()
	})
end

function NoteLaneUI3D.PlayStarPowerShake()
	starPowerCameraPunch(0.35)
end
function NoteLaneUI3D.PlayStarPowerEndShake()
	starPowerCameraPunch(0.4)
end

function NoteLaneUI3D.SetSongProfile(data)
	local aura = v23.aura()

	if aura then
		aura:SetStyle(data)
	end

	if v22.randomSkin then
		v22.lastRandomId = v22.randomSkin.Id
	end

	v22.randomSkin = nil
	pcall(v23.rerollSkin)
	local bpm = data and tonumber(data.BPM)

	if bpm and bpm >= 40 and bpm <= 300 then
		v21.bpm = bpm
	else
		v21.bpm = nil
	end

	v21.offset = data and tonumber(data.BeatOffset or data.Offset) or 0
end

function NoteLaneUI3D.PreviewCamera(value, value2, value3)
	local camera2 = v.Camera

	if value then
		camera2.Elevation = math.clamp(value, 18, 50)
	end

	if value2 then
		camera2.FOV = math.clamp(value2, 25, 60)
	end

	if value3 then
		camera2.Zoom = math.clamp(value3, 0.5, 0.88)
	end

	local v27 = computeLookAt()

	if camera then
		camera.FieldOfView = camera2.FOV
		camera.CFrame = CFrame.lookAt(
			toWorld(camera2.Pos.X, camera2.Pos.Y, camera2.Pos.Z), -- inferred equivalent call
			toWorld(v27.X, v27.Y, v27.Z) -- inferred equivalent call
		)

		if v23.afterCamera then
			v23.afterCamera()
		end
	end
end

function NoteLaneUI3D.SetHighwaySkin(highwaySkin)
	if LocalPlayer then
		LocalPlayer:SetAttribute("HighwaySkin", highwaySkin)
	else
		reapplySkin()
	end
end

function NoteLaneUI3D.SetEffectsQuality(p)
	local v27

	if p == "High" or p == "Low" then
		v27 = p or nil
	end

	v3 = v27
end

local function setGemHeadHidden(state, headHidden) -- 1 equivalent call inferred from this helper
	if (state.HeadHidden == true) == headHidden then
		return
	end

	state.HeadHidden = headHidden
	local parent = worldModel

	if headHidden then
		parent = nil
	end

	if state.Base then
		state.Base.Parent = parent
	end

	if state.Cap then
		state.Cap.Parent = parent
	end

	if state.Mid then
		state.Mid.Parent = parent
	end

	if state.Body then
		state.Body.Parent = parent
	end
end

local function setHoldBarHidden(state, holdBarHidden)
	if (state.HoldBarHidden == true) == holdBarHidden then
		return
	end

	state.HoldBarHidden = holdBarHidden
	local parent = worldModel

	if holdBarHidden then
		parent = nil
	end

	if state.HoldPart then
		state.HoldPart.Parent = parent
	end

	if state.HoldStroke then
		state.HoldStroke.Parent = parent
	end

	if state.HoldCenter then
		state.HoldCenter.Parent = parent
	end

	if state.HoldGlow then
		state.HoldGlow.Parent = parent
	end
end

local function drawBeatLines(smoothTime, p)
	local v27 = 0

	if v.Highway.BeatLines and v21.bpm and v15 then
		local v28 = 60 / v21.bpm

		if v28 < 0.24 then
			v28 *= 2
		end

		local v29 = v15 * v.Highway.LaneWidth
		local v30 = math.max(0, (math.ceil((smoothTime - 0.03 - v21.offset) / v28)))
		local v31 = math.floor((smoothTime + p - v21.offset) / v28)
		local color3 = v6 and ENERGY_COLOR or color

		for i = v30, v31 do
			v27 += 1

			if v.Highway.BeatMaxLines < v27 then
				v27 -= 1
				break
			end

			local v32 = i % 4 == 0
			local v35, v36 = distAlongHighway(v21.offset + i * v28 - smoothTime, p) -- inferred equivalent call
			local beatLine3D = v11[v27]

			if not beatLine3D then
				local vector3 = Vector3.new(v29, 0.02, 0.05)
				local cframe3 = CFrame.new()
				local neon = Enum.Material.Neon
				beatLine3D = Instance.new("Part")
				beatLine3D.Size = vector3
				beatLine3D.CFrame = cframe3
				beatLine3D.Color = color
				beatLine3D.Material = neon or Enum.Material.SmoothPlastic
				beatLine3D.Transparency = 0.8
				beatLine3D.Anchored = true
				beatLine3D.CanCollide = false
				beatLine3D.CanQuery = false
				beatLine3D.CanTouch = false
				beatLine3D.CastShadow = false
				beatLine3D.Parent = worldModel

				beatLine3D.Name = "BeatLine3D"
				v11[v27] = beatLine3D
			end

			beatLine3D.Size = Vector3.new(v29, 0.03, v32 and 0.14 or 0.07)
			beatLine3D.CFrame = cframe * CFrame.new(0, 0.02, v35)
			beatLine3D.Color = color3
			local v37 = math.clamp(v36, 0, 1) ^ 1.5
			beatLine3D.Transparency = 0.97 + ((v32 and 0.1 or 0.4) - 0.97) * v37

			if beatLine3D.Parent ~= worldModel then
				beatLine3D.Parent = worldModel
			end
		end
	end

	for i = v27 + 1, #v11 do
		if v11[i].Parent then
			v11[i].Parent = nil
		end
	end
end

v22.visT = nil

function v23.smoothTime(visT, p)
	local visT2 = v22.visT

	if not visT2 or p <= 0 or math.abs(visT - visT2) > 0.2 then
		v22.visT = visT
		return visT
	end

	visT2 += p
	local visT3 = visT2 + (visT - visT2) * math.min(1, p * 10)
	v22.visT = visT3
	return visT3
end

v22.feel = {
	p = 0,
	v = 0,
	r = 0,
	rv = 0,
	x = 0,
	xv = 0,
	t = 0
}
v23.FeelAmt = {
	Perfect = 0.55,
	Great = 0.45,
	Good = 0.35,
	OK = 0.25,
	Miss = -0.7,
	Wrong = -0.35
}

function v23.feelScale()
	local noteLane3DCamFeel = LocalPlayer and LocalPlayer:GetAttribute("NoteLane3DCamFeel")
	return noteLane3DCamFeel == nil and 1 or noteLane3DCamFeel
end

function v23.feelHit(p, p2)
	local v27 = v23.FeelAmt[p2]

	if not v27 then
		return
	end

	local feelScale = v23.feelScale()

	if feelScale <= 0 then
		return
	end

	local feel = v22.feel
	local v28 = v15 or 5
	local v29 = (p - (v28 + 1) / 2) / math.max(1, (v28 - 1) / 2)
	local v30 = math.abs(v27) / 0.55
	feel.v = math.clamp(feel.v + v27 * 5 * feelScale, -4, 4)
	feel.rv = math.clamp(feel.rv - v29 * 0.25 * v30 * feelScale, -0.6, 0.6)
	feel.xv = math.clamp(feel.xv + v29 * 1.2 * v30 * feelScale, -2, 2)
end

function v23.feelStep(p)
	if not (camera and highway3D and highway3D.Visible) then
		return
	end

	local feel = v22.feel
	local feelScale = v23.feelScale()

	if camera.CFrame ~= feel.applied then
		feel.base = camera.CFrame
	end

	if not feel.base then
		return
	end

	if feelScale <= 0 then
		if feel.applied then
			camera.CFrame = feel.base
			feel.applied = nil
		end
	else
		local v27 = math.min(p, 1 / 30)
		feel.t += v27

		feel.v += (-220 * feel.p - 16 * feel.v) * v27
		feel.p += feel.v * v27
		feel.rv += (-220 * feel.r - 16 * feel.rv) * v27
		feel.r += feel.rv * v27
		feel.xv += (-220 * feel.x - 16 * feel.xv) * v27
		feel.x += feel.xv * v27
		local v28 = math.sin(feel.t * 0.45) * 0.0035 * feelScale
		local v29 = math.sin(feel.t * 0.31 + 1.3) * 0.04 * feelScale
		local v30 = feel.base * CFrame.new(feel.x + v29, 0, -feel.p) * CFrame.Angles(0, 0, feel.r + v28)
		camera.CFrame = v30
		feel.applied = v30
	end
end

v22.rec = { vis = 1, target = true, entrance = nil }
v22.recShown = true

function v23.aura()
	if v22.aura ~= nil then
		return v22.aura or nil
	end

	local success, result = pcall(function()
		return require(ReplicatedStorage.Modules:WaitForChild("KeyAura3D", 5))
	end)

	if success and result then
		v22.aura = result.new({
			layer = function()
				return fxLayer
			end,
			frets = function()
				return v7
			end,
			unit = function()
				return v25.FxUnit
			end,
			isStar = function()
				return v6
			end,
			active = function(): boolean
				return v22.recShown ~= false
			end,
			quality = getQ,
			tex = tex,
			energy = ENERGY_COLOR,
			mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
			bolt = function(p, p2, p3)
				spawnLightning(p, p2, p3)
			end
		})
	else
		v22.aura = false
		warn("[NoteLaneUI3D] KeyAura3D gagal dimuat:", result)
	end

	return v22.aura or nil
end

function v23.auraStep(p)
	if not (noteLaneUI3D and noteLaneUI3D.Enabled and fxLayer) then
		return
	end

	local aura = v23.aura()

	if aura then
		aura:Step(p)
	end
end

function v23.auraJudge(p, p2, p3, p4)
	local aura = v23.aura()

	if not aura then
		return
	end

	aura:Feed(p2, p3, p4)
	aura:Pulse(p, p2, p3)
end

function NoteLaneUI3D.SetKickBeats(p)
	local aura = v23.aura()

	if aura then
		aura:SetKicks(p)
	end
end

function NoteLaneUI3D.GetKeyAuraStyle()
	local aura = v23.aura()
	return aura and aura:GetStyleName() or "Blade"
end

function NoteLaneUI3D.GetPerformanceForm()
	local aura = v23.aura()

	if aura then
		return aura:GetForm()
	end

	return 0.9, 0.9, 0
end

function NoteLaneUI3D.SetReceptorsVisible(p)
	local rec = v22.rec
	local target = p and true or false

	if rec.target == target then
		return
	end

	rec.target = target
end

function NoteLaneUI3D.GetReceptorAppearDuration(): number
	return 0.9
end

function v23.healView()
	v22.camSig = nil
	pcall(v23.applyCameraSettings)
	local function again()
		if noteLaneUI3D and noteLaneUI3D.Enabled then
			pcall(v25.apply)
		end
	end
	task.delay(0.15, again)
	task.delay(0.7, again)
end

function v23.recBegin(value)
	local rec = v22.rec
	rec.vis = 1
	rec.target = true
	rec.entrance = {
		t0 = os.clock() + (type(value) == "number" and math.max(0, value) or 0)
	}
end

function v23.recReset()
	local rec = v22.rec
	rec.vis = 1
	rec.target = true
	rec.entrance = nil
	v22.recShown = true
end

function v23:recApply(last, lastPop)
	local pad = self.Pad

	if not (pad and pad.Parent) then
		return
	end

	local housing = self.Housing
	local lamp = self.Lamp
	local recBase = self.RecBase

	if not recBase then
		recBase = {
			padSize = pad.Size,
			houseSize = housing and housing.Size,
			padT = pad.Transparency,
			houseT = housing and housing.Transparency or 0,
			decals = {},
			last = 1,
			lastPop = 1
		}

		for _, descendant in ipairs(pad:GetDescendants()) do
			if descendant:IsA("Decal") or descendant:IsA("Texture") then
				table.insert(recBase.decals, { descendant, descendant.Transparency })
			end
		end

		self.RecBase = recBase
	end

	if last >= 0.999 and lastPop == 1 and recBase.last >= 0.999 and recBase.lastPop == 1 then
		return
	end

	recBase.last = last
	recBase.lastPop = lastPop

	if last <= 0.01 then
		pad.Transparency = 1

		for _, decal in ipairs(recBase.decals) do
			if decal[1].Parent then
				decal[1].Transparency = 1
			end
		end

		if housing then
			housing.Transparency = 1
		end

		if lamp then
			lamp.Transparency = 1
		end
	else
		pad.Transparency = 1 - (1 - recBase.padT) * last

		for _, decal in ipairs(recBase.decals) do
			if decal[1].Parent then
				decal[1].Transparency = 1 - (1 - decal[2]) * last
			end
		end

		if housing then
			housing.Transparency = 1 - (1 - recBase.houseT) * last
		end

		if lamp and last < 0.999 then
			lamp.Transparency = math.max(lamp.Transparency, 1 - last)
		end
	end

	pad.Size = Vector3.new(recBase.padSize.X, recBase.padSize.Y * lastPop, recBase.padSize.Z * lastPop)

	if housing and recBase.houseSize then
		housing.Size = Vector3.new(recBase.houseSize.X, recBase.houseSize.Y * lastPop, recBase.houseSize.Z * lastPop)
	end
end

function v23.recStep(p)
	local rec = v22.rec
	local now = os.clock()

	if rec.target then
		rec.vis = math.min(1, rec.vis + p / 0.9)
	else
		rec.vis = math.max(0, rec.vis - p / 0.7)
	end

	local entrance = rec.entrance
	local count2 = 0
	local v27 = false

	for k, v28 in pairs(v7) do
		count2 += 1
		local v29 = rec.vis
		local v30

		if entrance then
			local v31 = math.clamp((now - entrance.t0 - (k - 1) * 0.07) / 0.5, 0, 1)
			local v32 = v31 - 1
			local v34 = v32 * 2.70158 * v32 * v32 + 1 + v32 * 1.70158 * v32
			v29 = v31 * rec.vis
			v30 = v34 * 0.45 + 0.55
		else
			v30 = 1
		end

		v23.recApply(v28, v29, v30)

		if v29 > 0.02 then
			v27 = true
		end
	end

	if entrance and entrance.t0 + count2 * 0.07 + 0.55 < now then
		rec.entrance = nil
	end

	v22.recShown = v27 or count2 == 0
end

function NoteLaneUI3D._FeelStep(p)
	v23.feelStep(p)
	v23.recStep(p)
	v23.auraStep(p)
end
function NoteLaneUI3D._FeelHit(p, p2)
	v23.feelHit(p, p2)
end

function NoteLaneUI3D.SyncNotes(list, p)
	if not (highway3D and highway3D.Visible) then
		return
	end

	if v15 then
		v18 = SettingsState.GetRhythmLaneColors(v15)
		v19 = SettingsState.GetRhythmShape()
	end

	local v27 = RhythmEngineConfig.NoteApproachTime / (NewbieModeState.GetNoteSpeedOverride() or SettingsState.GetNoteSpeedMultiplier())
	local set = {}
	local now = os.clock()
	v22.dt = math.min(now - v22.lastSync, 0.1)
	v22.lastSync = now
	local smoothTime = v23.smoothTime(p, v22.dt)

	if v22.aura then
		v22.aura:SetSongTime(smoothTime)
	end

	drawBeatLines(smoothTime, v27)
	v23.updateScroll(smoothTime, v27)

	local RhythmVibratoWave3D = require(ReplicatedStorage.Modules.RhythmVibratoWave3D)
	RhythmVibratoWave3D.BeginFrame()

	local note = v.Note
	local v28 = false

	for _, item in ipairs(list) do
		local v29 = item.Time + (item.Duration or 0)
		local v30 = not (item._judged or item._hidden)

		if v30 then
			if item.Time - smoothTime <= v27 then
				v30 = smoothTime <= v29 + RhythmEngineConfig.MissWindow
			else
				v30 = false
			end
		end

		if not v30 then
			continue
		end

		local v31 = v7[item.Lane]

		if not v31 then
			continue
		end

		set[item] = true
		local v32 = v8[item]

		if not v32 then
			local originalAccentColor = v31.OriginalAccentColor or v31.AccentColor
			local v34 = v18 and v18[item.Lane]
			v32 = buildGem(originalAccentColor, v34 and v34.NoteInner or nil, v19)

			if v6 then
				applyGemStarPowerTint(v32, true)
			end

			if item.Duration and item.Duration > 0 then
				v32.Tail = v23.buildTail(originalAccentColor)
				v32.HoldGlow = v32.Tail.Layers[1][1]
				v32.HoldPart = v32.Tail.Layers[2][1]
				v32.HoldCenter = v32.Tail.Layers[3][1]
			end

			v32.Lane = item.Lane
			v32.NoteRef = item
			v8[item] = v32
		end

		if v32.Dismissed then
			continue
		end

		local v34

		if v32.HoldPart == nil then
			v34 = false
		else
			v34 = item._holding == true
		end

		setGemHeadHidden(v32, v34) -- inferred equivalent call
		v28 = v34 and true or v28
		local v35 = laneLocalX(item.Lane, v15 or 5) -- inferred equivalent call
		local v36, v37 = distAlongHighway(item.Time - smoothTime, v27) -- inferred equivalent call
		local v38 = 1 + (1 - math.clamp(v37, 0, 1)) * note.FarBoost
		local v39 = math.clamp(v37 / note.SpawnFrac, 0, 1)
		local v40 = v39 * v39 * (3 - v39 * 2)
		local v41 = v38 * (note.SpawnScale + (1 - note.SpawnScale) * v40) * (1 - math.clamp((v37 - 1) / 0.12, 0, 1) * 0.35)

		placeGem(
			v32,
			CFrame.new(toWorld( -- inferred equivalent call
				v35,
				v.Receptor.PadRestY + v.Receptor.PadThickness / 2 + 0.03 + note.RimThickness * v41 / 2 - (1 - v40) * note.SpawnRise - math.clamp((v37 - 1) / 0.12, 0, 1) * 0.3,
				v36
			)) * cframe.Rotation * cframe2,
			v41
		)

		local v43 = math.clamp((v37 - 1) / 0.12, 0, 1)
		local v44 = math.clamp(v37 / note.FadeFrac, 0, 1)
		local v45 = math.max(1 - v44 * v44 * (3 - v44 * 2), v43)

		if v32.LastTr ~= v45 then
			v32.LastTr = v45
			v32.Base.Transparency = v45
			v32.Mid.Transparency = v45
			v32.Body.Transparency = v45
			v32.Cap.Transparency = 1 - (1 - v45) * 0.86
		end

		if not v32.Tail then
			continue
		end

		local v46 = math.clamp(1 - (v29 - smoothTime) / v27, -0.3, 1.3)
		local v47 = math.min(math.max(-v.Highway.Length * (1 - v46), -v.Highway.Length), -0.15)
		local v48 = math.min(v36, -0.15)
		local v49 = item._holding == true or v31.IsPressed and v36 >= -0.05
		local tail = v32.Tail
		tail.Act += ((v49 and 1 or 0) - tail.Act) * math.min(1, v22.dt * 12)
		v23.updateTail(v32, v35, v48, v47, tail.Act, v40, fxColor(v31)) -- inferred equivalent call

		if v49 then
			v31.HoldUntil = now + 0.15
		end

		if
			v34
			and RhythmVibratoWave3D.Draw(
				v32,
				worldModel,
				toWorld,
				cframe.Rotation,
				v35,
				v47,
				v48,
				v.Hold.BarWidth,
				v31.AccentColor
			)
		then
			v23.suppressTail(v32)
		else
			RhythmVibratoWave3D.Hide(v32)
		end
	end

	RhythmVibratoWave3D.ReportHold(v28)
	v23.railUpdate(v22.dt)

	for k, v29 in pairs(v8) do
		if set[k] then
			continue
		end

		destroyVisual(v29)
		v8[k] = nil
	end
end

function NoteLaneUI3D.ShowJudgment(p, value, p2, p3, p4)
	if not p4 then
		v23.feelHit(p, value)
		pcall(v23.auraJudge, p, value, p2, p3)
	end

	local v27 = not p4 and v23.hud("RockMeterUI")

	if v27 then
		v27.OnJudgment(value, p2)
	end

	local v28 = not (p2 or p4) and RockMeterConfig.Step[value]

	if v28 then
		v22.rock = math.clamp(v22.rock + v28, 0, 1)
	end

	if value == "Miss" or value == "Wrong" then
		if value == "Wrong" then
			shakeBoard(p)
		end
	else
		playHitEffect(p, value)
	end

	if not judgmentLabel then
		return
	end

	count += 1
	local v29 = count

	judgmentLabel.Text = p2 and "AUTO" or string.upper(value)
	judgmentLabel.TextColor3 = p2 and Color3.fromRGB(224, 212, 180)
		or getJudgmentColor3D(value) -- inferred equivalent call
		or Color3.fromRGB(235, 235, 240)
	judgmentLabel.TextTransparency = 0
	judgmentLabel.TextStrokeTransparency = 0.18
	uiScale.Scale = 1.45

	if SettingsState.GetJudgmentPopEnabled() then
		TweenService:Create(uiScale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	else
		uiScale.Scale = 1
	end

	task.delay(0.5, function()
		if v29 ~= count then
			return
		end

		TweenService:Create(judgmentLabel, TweenInfo.new(0.35), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
	end)
end

function NoteLaneUI3D.ShowCountdown(p, p2, p3, p4, p5)
	if v4 then
		v4:Show(p, p2, p3, p4, p5)
		return
	end

	if not countdown then
		return
	end

	countdown.Visible = true
	countdownCaption.Visible = true
	countdown.Text = tostring((math.max(1, (math.ceil(p)))))
end

function NoteLaneUI3D.HideCountdown()
	if v4 then
		v4:Hide()
		return
	end

	if countdown then
		countdown.Visible = false
	end

	if countdownCaption then
		countdownCaption.Visible = false
	end
end

function NoteLaneUI3D.SetLanePressed(p, isPressed)
	local v27 = v7[p]

	if not v27 then
		return
	end

	v27.IsPressed = isPressed

	if isPressed then
		pressReceptor(v27)
	else
		releaseReceptor(v27)
	end
end

function NoteLaneUI3D.GetTrackWidth(_)
	return v25.W
end
function NoteLaneUI3D.GetTrackHeight()
	return v25.H
end

function NoteLaneUI3D.SetLayoutScreenOverride(screenOverride)
	v25.ScreenOverride = screenOverride
	v25.apply()
end

function NoteLaneUI3D.GetTrackRightEdgeX()
	if highway3D then
		return highway3D.AbsolutePosition.X + highway3D.AbsoluteSize.X
	end

	return nil
end

function NoteLaneUI3D.GetTrackCenterY()
	if highway3D then
		return highway3D.AbsolutePosition.Y + highway3D.AbsoluteSize.Y / 2
	end

	return nil
end

function NoteLaneUI3D.IsVisible()
	return noteLaneUI3D ~= nil and noteLaneUI3D.Enabled
end

return NoteLaneUI3D