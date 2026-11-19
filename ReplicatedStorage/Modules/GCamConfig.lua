local GCamConfig = {
	PICKUP_PROMPT_NAME = "GCamPickup",
	PERMANENT_SLOTS = 3,
	MAX_PHOTOS = 36,
	SHUTTER_COOLDOWN = 0.9,
	SHARE_COOLDOWN = 2,
	SHARE_RANGE = 60,
	HOLSTER_HOLD_TIME = 0.6,
	BASE_FOV = 66,
	ZOOM_MIN = 1,
	ZOOM_MAX = 5,
	ZOOM_STEP = 0.3,
	SHARE_MAX_CHARACTERS = 6,
	SHARE_MAX_PARTS = 48,
	SHARE_RADIUS = 90,
	Colors = {
		Ink = Color3.fromRGB(16, 16, 16),
		Paper = Color3.fromRGB(233, 229, 216),
		Red = Color3.fromRGB(214, 40, 44),
		Dim = Color3.fromRGB(140, 136, 126),
		Osd = Color3.fromRGB(240, 236, 222)
	},
	Keys = {
		Flash = Enum.KeyCode.F,
		PrevFilter = Enum.KeyCode.Q,
		NextFilter = Enum.KeyCode.E,
		Holster = Enum.KeyCode.Backspace,
		Keep = Enum.KeyCode.K,
		Discard = Enum.KeyCode.X,
		Share = Enum.KeyCode.T,
		HideHud = Enum.KeyCode.G
	},
	Pad = {
		Aim = Enum.KeyCode.ButtonL2,
		Shutter = Enum.KeyCode.ButtonR2,
		Flash = Enum.KeyCode.ButtonY,
		PrevFilter = Enum.KeyCode.ButtonL1,
		NextFilter = Enum.KeyCode.ButtonR1,
		HideHud = Enum.KeyCode.ButtonR3,
		Holster = Enum.KeyCode.ButtonB,
		ZoomIn = Enum.KeyCode.DPadUp,
		ZoomOut = Enum.KeyCode.DPadDown,
		Keep = Enum.KeyCode.ButtonA,
		Share = Enum.KeyCode.ButtonX,
		Discard = Enum.KeyCode.ButtonB
	},
	["HOLD_GRIP"] = CFrame.new(-0.42, -0.3, -0.45),
	AIM_OFFSET = CFrame.new(0.1, -0.12, -1.1),
	POSE = {
		Right = { 40.3, 55.4, 22.5, 99.5 },
		Left = { 65.1, -4.5, 50, 46 }
	}
}

local function C(p, p2, p3) -- 23 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

GCamConfig.Filters = {
	{
		id = "vhs",
		name = "VHS '95",
		cc = { Brightness = 0.02, Contrast = 0.18, Saturation = -0.28, Tint = C(255, 236, 216) }, -- inferred equivalent call
		bloom = { Intensity = 0.4, Size = 22, Threshold = 0.88 },
		blur = 0,
		grain = 0.5,
		scan = 0.55,
		vignette = 0.45,
		glitch = 0.5,
		accent = C(235, 60, 55) -- inferred equivalent call
	},
	{
		id = "monochrome",
		name = "MONOCHROME",
		cc = { Brightness = -0.04, Contrast = 0.6, Saturation = -1, Tint = C(255, 255, 255) }, -- inferred equivalent call
		bloom = nil,
		blur = 0,
		grain = 0.95,
		scan = 0.15,
		vignette = 0.85,
		glitch = 0.15,
		accent = C(240, 240, 240) -- inferred equivalent call
	},
	{
		id = "nightvision",
		name = "NIGHT VISION",
		cc = { Brightness = 0.14, Contrast = 0.35, Saturation = -0.3, Tint = C(120, 255, 140) }, -- inferred equivalent call
		bloom = { Intensity = 0.9, Size = 30, Threshold = 0.7 },
		blur = 0,
		grain = 0.85,
		scan = 0.35,
		vignette = 0.8,
		round = true,
		glitch = 0.2,
		overlay = { C(40, 255, 90), 0.93 }, -- inferred equivalent call
		accent = C(110, 255, 130) -- inferred equivalent call
	},
	{
		id = "darkroom",
		name = "DARK ROOM",
		cc = { Brightness = -0.22, Contrast = 0.3, Saturation = -0.35, Tint = C(170, 190, 255) }, -- inferred equivalent call
		bloom = { Intensity = 0.25, Size = 20, Threshold = 0.9 },
		blur = 0,
		grain = 0.55,
		scan = 0.25,
		vignette = 0.8,
		glitch = 0.1,
		accent = C(150, 175, 255) -- inferred equivalent call
	},
	{
		id = "overexposed",
		name = "OVEREXPOSED",
		cc = { Brightness = 0.28, Contrast = -0.05, Saturation = -0.15, Tint = C(255, 240, 220) }, -- inferred equivalent call
		bloom = { Intensity = 1.2, Size = 36, Threshold = 0.6 },
		blur = 0,
		grain = 0.3,
		scan = 0.2,
		vignette = 0.15,
		glitch = 0.1,
		accent = C(255, 235, 200) -- inferred equivalent call
	},
	{
		id = "punkzine",
		name = "PUNK ZINE",
		cc = { Brightness = 0.05, Contrast = 0.7, Saturation = -1, Tint = C(255, 205, 205) }, -- inferred equivalent call
		bloom = nil,
		blur = 0,
		grain = 1,
		scan = 0,
		vignette = 0.5,
		glitch = 0.35,
		overlay = { C(255, 40, 40), 0.9 }, -- inferred equivalent call
		accent = C(255, 70, 70) -- inferred equivalent call
	},
	{
		id = "sepia",
		name = "SEPIA '78",
		cc = { Brightness = 0.02, Contrast = 0.12, Saturation = -0.6, Tint = C(255, 214, 170) }, -- inferred equivalent call
		bloom = { Intensity = 0.3, Size = 18, Threshold = 0.9 },
		blur = 0,
		grain = 0.5,
		scan = 0.1,
		vignette = 0.6,
		glitch = 0.05,
		accent = C(255, 205, 150) -- inferred equivalent call
	},
	{
		id = "neon",
		name = "NEON RIOT",
		cc = { Brightness = 0, Contrast = 0.25, Saturation = 0.5, Tint = C(255, 170, 255) }, -- inferred equivalent call
		bloom = { Intensity = 1, Size = 28, Threshold = 0.65 },
		blur = 0,
		grain = 0.35,
		scan = 0.3,
		vignette = 0.35,
		glitch = 0.6,
		overlay = { C(0, 230, 255), 0.93 }, -- inferred equivalent call
		accent = C(255, 90, 255) -- inferred equivalent call
	},
	{
		id = "toxic",
		name = "TOXIC WASTE",
		cc = { Brightness = -0.05, Contrast = 0.3, Saturation = 0.1, Tint = C(200, 255, 120) }, -- inferred equivalent call
		bloom = { Intensity = 0.5, Size = 24, Threshold = 0.8 },
		blur = 0,
		grain = 0.6,
		scan = 0.4,
		vignette = 0.6,
		glitch = 0.4,
		accent = C(190, 255, 70) -- inferred equivalent call
	},
	{
		id = "blood",
		name = "BLOOD MOON",
		cc = { Brightness = -0.1, Contrast = 0.4, Saturation = -0.1, Tint = C(255, 120, 110) }, -- inferred equivalent call
		bloom = { Intensity = 0.4, Size = 22, Threshold = 0.85 },
		blur = 0,
		grain = 0.6,
		scan = 0.3,
		vignette = 0.7,
		glitch = 0.25,
		accent = C(255, 70, 60) -- inferred equivalent call
	}
}

function GCamConfig.GetFilterById(p)
	for i, filter in ipairs(GCamConfig.Filters) do
		if filter.id == p then
			return filter, i
		end
	end

	return GCamConfig.Filters[1], 1
end

return GCamConfig