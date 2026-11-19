local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Theme)

local FavoriteButton = {}
FavoriteButton.__index = FavoriteButton

function FavoriteButton.new(parent, options)
	local v = options or {}

	local favoriteButton = Instance.new("TextButton")
	favoriteButton.Name = "FavoriteButton"
	favoriteButton.BackgroundTransparency = 1
	favoriteButton.Size = v.size or UDim2.new(0, Theme.Sizes.IconButtonSize, 0, Theme.Sizes.IconButtonSize)
	favoriteButton.LayoutOrder = v.layoutOrder or 0
	favoriteButton.Font = Theme.Fonts.Bold
	favoriteButton.TextSize = Theme.TextSize.XXL
	favoriteButton.AutoButtonColor = false
	favoriteButton.Parent = parent

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = favoriteButton

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = favoriteButton

	local object = setmetatable({
		Instance = favoriteButton,
		Toggled = bindableEvent.Event,
		_toggledEvent = bindableEvent,
		_isFavorite = v.initial or false
	}, FavoriteButton)

	local function render() -- 1 equivalent call inferred from this helper
		favoriteButton.Text = object._isFavorite and Theme.Icons.FavoriteFilled or Theme.Icons.FavoriteEmpty
		favoriteButton.TextColor3 = object._isFavorite and Theme.Colors.Accent or Theme.Colors.TextSecondary
	end
	object._render = render
	render() -- inferred equivalent call
	favoriteButton.MouseButton1Click:Connect(function()
		uiScale.Scale = Theme.Animation.PressScale
		TweenService:Create(
			uiScale,
			TweenInfo.new(Theme.Animation.Normal, Theme.Animation.BounceStyle, Theme.Animation.BounceDirection),
			{ Scale = 1 }
		):Play()

		bindableEvent:Fire()
	end)

	return object
end

function FavoriteButton:Get()
	return self._isFavorite
end

function FavoriteButton:Set(isFavorite)
	if self._isFavorite == isFavorite then
		return
	end

	self._isFavorite = isFavorite
	self._render()
end

function FavoriteButton:Destroy()
	self.Instance:Destroy()
end

return FavoriteButton