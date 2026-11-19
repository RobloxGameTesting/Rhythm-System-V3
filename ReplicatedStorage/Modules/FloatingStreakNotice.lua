local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local StreakNoticeFx = require(script.Parent.StreakNoticeFx)

local scale = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and 0.7 or 0.9

local floatingStreakNotices = nil
local v = {}
local v2 = 0

local function destroyEntry(state) -- 2 equivalent calls inferred from this helper
	if state.Dead then
		return
	end

	state.Dead = true
	v2 -= 1

	if v[state.Char] == state then
		v[state.Char] = nil
	end

	state.Fx:Reset()
	state.Billboard:Destroy()
end

return {
	Spawn = function(instance, p, p2, p3)
		if not (instance and instance.Parent) then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("Head")

		if not humanoidRootPart then
			return
		end

		if not floatingStreakNotices then
			floatingStreakNotices = Instance.new("Folder")
			floatingStreakNotices.Name = "FloatingStreakNotices"
			floatingStreakNotices.Parent = Workspace
		end

		local v3 = v[instance]

		if v3 then
			destroyEntry(v3) -- inferred equivalent call
		end

		if v2 >= 8 then
			return
		end

		local floatingStreakNotice = Instance.new("BillboardGui")
		floatingStreakNotice.Name = "FloatingStreakNotice"
		floatingStreakNotice.Size = UDim2.fromOffset(620, 280)
		floatingStreakNotice.AlwaysOnTop = true
		floatingStreakNotice.LightInfluence = 0
		floatingStreakNotice.MaxDistance = 150
		floatingStreakNotice.ClipsDescendants = false
		floatingStreakNotice.Adornee = humanoidRootPart
		floatingStreakNotice.StudsOffset = Vector3.new(0, 4.6, 0)
		floatingStreakNotice.Parent = floatingStreakNotices

		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 1)
		frame.ClipsDescendants = false
		frame.Parent = floatingStreakNotice

		local fx = StreakNoticeFx.Attach(frame, {
			CenterY = 140,
			Scale = scale,
			HoldMul = 1.7,
			NoClamp = true,
			Plain = true
		})
		local v4 = { Char = instance, Billboard = floatingStreakNotice, Fx = fx, Dead = false }
		v[instance] = v4
		v2 += 1

		fx:Show(p, p2, {
			Sparkle = p3 ~= false
		})

		local lifetimeFor = fx:LifetimeFor(p, p2)
		TweenService:Create(
			floatingStreakNotice,
			TweenInfo.new(lifetimeFor, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ StudsOffset = Vector3.new(0, 5.9, 0) }
		):Play()

		task.delay(lifetimeFor, function()
			destroyEntry(v4) -- inferred equivalent call
		end)
	end
}