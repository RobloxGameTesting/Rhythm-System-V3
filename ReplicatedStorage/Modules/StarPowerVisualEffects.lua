local TweenService = game:GetService("TweenService")

local StarPowerVisualEffects = {}

StarPowerVisualEffects.ENERGY_COLOR = Color3.fromRGB(75, 200, 220)

StarPowerVisualEffects.TINT_TWEEN_INFO = TweenInfo.new(0.35, Enum.EasingStyle.Sine)

StarPowerVisualEffects.ATMOSPHERE_COLOR = Color3.fromRGB(60, 190, 210)
StarPowerVisualEffects.ATMOSPHERE_FLASH_TRANSPARENCY = 0.75
StarPowerVisualEffects.ATMOSPHERE_SETTLE_TRANSPARENCY = 0.93
StarPowerVisualEffects.ATMOSPHERE_SETTLE_DELAY = 0.05
StarPowerVisualEffects.ATMOSPHERE_SETTLE_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
StarPowerVisualEffects.ATMOSPHERE_FADE_OUT_TWEEN = TweenInfo.new(0.35, Enum.EasingStyle.Sine)

function StarPowerVisualEffects.BuildAtmosphere(parent)
	local starPowerAtmosphere = Instance.new("Frame")
	starPowerAtmosphere.Name = "StarPowerAtmosphere"
	starPowerAtmosphere.Size = UDim2.new(1, 0, 1, 0)
	starPowerAtmosphere.BackgroundColor3 = StarPowerVisualEffects.ATMOSPHERE_COLOR
	starPowerAtmosphere.BackgroundTransparency = 1
	starPowerAtmosphere.BorderSizePixel = 0
	starPowerAtmosphere.ZIndex = 0
	starPowerAtmosphere.Parent = parent

	local function setActive(p)
		if not p then
			TweenService:Create(starPowerAtmosphere, StarPowerVisualEffects.ATMOSPHERE_FADE_OUT_TWEEN, {
				BackgroundTransparency = 1
			}):Play()

			return
		end

		starPowerAtmosphere.BackgroundTransparency = StarPowerVisualEffects.ATMOSPHERE_FLASH_TRANSPARENCY
		task.delay(StarPowerVisualEffects.ATMOSPHERE_SETTLE_DELAY, function()
			if starPowerAtmosphere and starPowerAtmosphere.Parent then
				TweenService:Create(starPowerAtmosphere, StarPowerVisualEffects.ATMOSPHERE_SETTLE_TWEEN, {
					BackgroundTransparency = StarPowerVisualEffects.ATMOSPHERE_SETTLE_TRANSPARENCY
				}):Play()
			end
		end)
	end

	return setActive, starPowerAtmosphere
end

function StarPowerVisualEffects.TintProperty(instance, p, p2)
	if instance and p2 then
		TweenService:Create(instance, StarPowerVisualEffects.TINT_TWEEN_INFO, { [p] = p2 }):Play()
	end
end

return StarPowerVisualEffects