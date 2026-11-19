return {
	Colors = {
		Background = Color3.fromRGB(18, 18, 20),
		Surface = Color3.fromRGB(32, 33, 36),
		SurfaceHover = Color3.fromRGB(44, 45, 49),
		SurfaceSelected = Color3.fromRGB(58, 60, 66),
		Border = Color3.fromRGB(66, 68, 74),
		BorderHover = Color3.fromRGB(104, 107, 115),
		TextPrimary = Color3.fromRGB(238, 238, 236),
		TextSecondary = Color3.fromRGB(164, 166, 170),
		TextDisabled = Color3.fromRGB(104, 106, 110),
		Accent = Color3.fromRGB(232, 168, 52),
		AccentText = Color3.fromRGB(34, 22, 6),
		Success = Color3.fromRGB(118, 176, 110),
		Danger = Color3.fromRGB(196, 72, 60),
		TitleTop = Color3.fromRGB(70, 72, 79),
		TitleBottom = Color3.fromRGB(38, 39, 43),
		Tape = Color3.fromRGB(198, 180, 130),
		Sticker = Color3.fromRGB(150, 54, 42),
		StickerText = Color3.fromRGB(236, 224, 196),
		Scanline = Color3.fromRGB(0, 0, 0),
		Glow = Color3.fromRGB(255, 236, 190),
		GhostCyan = Color3.fromRGB(70, 220, 255),
		GhostRed = Color3.fromRGB(255, 64, 100)
	},
	Fonts = {
		Regular = Enum.Font.Highway,
		Medium = Enum.Font.Highway,
		Bold = Enum.Font.Highway,
		Display = Enum.Font.GothamBlack,
		Mono = Enum.Font.Highway,
		Title = Enum.Font.GothamBlack,
		Label = Enum.Font.GothamBold
	},
	TextSize = {
		XS = 11,
		S = 12,
		M = 13,
		L = 14,
		XL = 15,
		XXL = 17
	},
	Radius = {
		Small = UDim.new(0, 2),
		Medium = UDim.new(0, 3),
		Large = UDim.new(0, 4),
		Pill = UDim.new(1, 0)
	},
	Stroke = {
		Thickness = 1,
		TransparencyDefault = 0.3,
		TransparencyMuted = 0.55,
		TransparencyActive = 0
	},
	Sizes = {
		ControlHeightS = 18,
		ControlHeightM = 26,
		ControlHeightL = 34,
		IconButtonSize = 24,
		ScrollBarThickness = 8
	},
	Spacing = {
		XS = 4,
		S = 6,
		M = 8,
		L = 12,
		XL = 16,
		XXL = 24
	},
	Animation = {
		Fast = 0.1,
		Normal = 0.15,
		Slow = 0.25,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
		BounceStyle = Enum.EasingStyle.Back,
		BounceDirection = Enum.EasingDirection.Out,
		PressScale = 0.75
	},
	ZIndex = {
		Base = 1,
		Content = 2,
		Raised = 5,
		Overlay = 10,
		Modal = 20,
		Toast = 30
	},
	Icons = {
		Search = "🔍",
		Clear = "✕",
		FavoriteFilled = "★",
		FavoriteEmpty = "☆",
		Check = "✓",
		Dash = "—"
	}
}