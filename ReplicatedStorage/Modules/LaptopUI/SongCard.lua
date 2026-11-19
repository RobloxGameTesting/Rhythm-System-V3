local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Theme)

local SongCard = {}
SongCard.__index = SongCard

local s = Theme.Spacing.S

local xs = Theme.Spacing.XS

local v = Theme.Sizes.ScrollBarThickness + 2

local function formatDuration(duration) -- 1 equivalent call inferred from this helper
	if not duration then
		return "--:--"
	end

	local v2 = math.floor(duration / 60)
	local v3 = duration % 60
	return string.format("%d:%02d", v2, v3)
end

function SongCard.GetHeightFor(_): number
	return 22
end

local function applyData(object, options)
	local v2 = options or {}

	local isInSession = v2.isInSession or false

	object.Instance.Name = v2.songId or "SongCard"
	object._title.AutoLocalize = false
	object._duration.AutoLocalize = false
	object._title.Text = v2.displayName or v2.songId or ""
	object._durationText = formatDuration(v2.duration) -- inferred equivalent call

	if not object._isLoading then
		object._duration.Text = object._durationText
	end

	object:SetPreviewLoading(v2.isPreviewLoading or false)

	object._setInSession(isInSession)
	object._resetInteraction()
end

function SongCard.new(parent, options)
	local v2 = options or {}

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Theme.Colors.Surface
	frame.Size = UDim2.new(1, 0, 0, 22)
	frame.LayoutOrder = v2.layoutOrder or 0
	frame.ClipsDescendants = true

	frame.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Small
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = Theme.Stroke.Thickness
	uiStroke.Color = Theme.Colors.Accent
	uiStroke.Transparency = 1
	uiStroke.Parent = frame

	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.BackgroundColor3 = Theme.Colors.Success
	accentBar.BorderSizePixel = 0
	accentBar.Size = UDim2.new(0, 3, 1, 0)
	accentBar.BackgroundTransparency = 1
	accentBar.ZIndex = Theme.ZIndex.Content
	accentBar.Parent = frame

	local duration = Instance.new("TextLabel")
	duration.Name = "Duration"
	duration.BackgroundTransparency = 1
	duration.AnchorPoint = Vector2.new(1, 0.5)
	duration.Position = UDim2.new(1, -(s + v), 0.5, 0)
	duration.Size = UDim2.new(0, 30, 1, 0)

	duration.Font = Theme.Fonts.Medium
	duration.TextSize = Theme.TextSize.XS
	duration.TextColor3 = Theme.Colors.TextSecondary
	duration.TextXAlignment = Enum.TextXAlignment.Right
	duration.Text = ""
	duration.Parent = frame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, s + 3 + xs, 0, 0)
	title.Size = UDim2.new(1, -(s * 2 + 3 + xs + 30 + xs + v), 1, 0)
	title.Font = Theme.Fonts.Medium
	title.TextSize = Theme.TextSize.S
	title.TextColor3 = Theme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = frame

	local v3 = false
	local flag = false
	local v4 = false

	local function refreshVisual()
		local backgroundColor = Theme.Colors.Surface
		local transparency = 1

		local backgroundColor2 = Theme.Colors.Accent
		local fast = Theme.Animation.Fast
		local backgroundTransparency

		if v4 then
			backgroundColor2 = Theme.Colors.Success
			backgroundTransparency = Theme.Stroke.TransparencyActive
		else
			backgroundTransparency = 1
		end

		if v3 then
			backgroundColor = Theme.Colors.SurfaceSelected
			transparency = Theme.Stroke.TransparencyActive
		elseif flag then
			backgroundColor = Theme.Colors.SurfaceHover
		end

		local tweenInfo = TweenInfo.new(fast, Theme.Animation.EasingStyle, Theme.Animation.EasingDirection)
		TweenService:Create(frame, tweenInfo, { BackgroundColor3 = backgroundColor }):Play()
		TweenService:Create(uiStroke, tweenInfo, { Transparency = transparency }):Play()
		TweenService:Create(accentBar, tweenInfo, {
			BackgroundTransparency = backgroundTransparency,
			BackgroundColor3 = backgroundColor2
		}):Play()
	end

	frame.MouseEnter:Connect(function()
		flag = true
		refreshVisual()
	end)
	frame.MouseLeave:Connect(function()
		flag = false
		refreshVisual()
	end)

	local self = setmetatable({
		Instance = frame,
		_title = title,
		_duration = duration,
		_durationText = "",
		_isLoading = false,
		_setSelected = function(p)
			v3 = p
			refreshVisual()
		end,
		_setInSession = function(p)
			v4 = p
			refreshVisual()
		end,
		_resetInteraction = function()
			v3 = false
			flag = false
			refreshVisual()
		end
	}, SongCard)

	applyData(self, v2)

	return self
end

function SongCard.SetData(p, p2)
	applyData(p, p2)
end

function SongCard:SetSelected(p)
	self._setSelected(p)
end

function SongCard:SetPreviewLoading(isLoading)
	self._isLoading = isLoading
	self._duration.Text = isLoading and "..." or self._durationText
end

function SongCard:Destroy()
	self.Instance:Destroy()
end

return SongCard