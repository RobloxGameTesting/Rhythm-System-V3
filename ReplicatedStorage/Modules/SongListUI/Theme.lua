return {
	Colors = {
		Background = Color3.fromRGB(18, 18, 20),
		Surface = Color3.fromRGB(28, 28, 31),
		SurfaceHover = Color3.fromRGB(36, 36, 40),
		SurfaceSelected = Color3.fromRGB(42, 39, 30),
		Border = Color3.fromRGB(50, 50, 55),
		BorderHover = Color3.fromRGB(70, 70, 76),
		TextPrimary = Color3.fromRGB(240, 240, 242),
		TextSecondary = Color3.fromRGB(150, 150, 155),
		TextDisabled = Color3.fromRGB(120, 120, 125),
		Accent = Color3.fromRGB(240, 180, 70),
		AccentText = Color3.fromRGB(25, 20, 10),
		Success = Color3.fromRGB(88, 210, 150),
		Danger = Color3.fromRGB(235, 90, 90)
	},
	Fonts = {
		Regular = Enum.Font.Gotham,
		Medium = Enum.Font.GothamMedium,
		Bold = Enum.Font.GothamBold
	},
	TextSize = {
		XS = 10,
		S = 11,
		M = 12,
		L = 13,
		XL = 14,
		XXL = 16
	},
	Radius = {
		Small = UDim.new(0, 4),
		Medium = UDim.new(0, 6),
		Large = UDim.new(0, 8),
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
		ScrollBarThickness = 3
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