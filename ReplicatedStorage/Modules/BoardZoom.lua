local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local v = false
local v2 = 1
local v3 = 1
local v4 = 1
local BoardZoom = {
	SetActive = function(p)
		v = p == true
	end,
	Reset = function()
		v2 = 1
		v3 = 1
		v4 = 1
	end,
	Fov = function(p)
		return (math.deg(math.atan(math.tan(math.rad(p) / 2) / v3) * 2))
	end,
	Get = function()
		return v3
	end
}

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if v and not gameProcessed and input.UserInputType == Enum.UserInputType.MouseWheel then
		v2 = math.clamp(v2 + input.Position.Z * 0.06, 0.87, 1.25)
	end
end)

UserInputService.TouchPinch:Connect(function(_, p, _, p2, p3)
	if not v or p3 then
		return
	end

	if p2 == Enum.UserInputState.Begin then
		v4 = v2
	else
		v2 = math.clamp(v4 * p, 0.87, 1.25)
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if v3 ~= v2 then
		v3 += (v2 - v3) * (1 - math.exp(-math.min(dt, 0.1) * 10))

		if math.abs(v3 - v2) < 0.0005 then
			v3 = v2
		end
	end
end)

return BoardZoom