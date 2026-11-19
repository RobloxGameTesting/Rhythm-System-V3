local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
game:GetService("TweenService")

local BoardZoom = require(script.Parent:WaitForChild("BoardZoom"))

local BoardSwitch = {}

local v = {}
local v2 = {}
local current = nil
local v3 = false

local bindableEvent = Instance.new("BindableEvent")
BoardSwitch.Changed = bindableEvent.Event

local LocalPlayer = Players.LocalPlayer

function BoardSwitch.Register(p, p2)
	v[p] = p2

	if p2.Part then
		v2[p2.Part] = p
	end
end

local fn

function BoardSwitch.SetCurrent(p)
	current = p
	BoardZoom.Reset()
	BoardZoom.SetActive(true)
	fn(p)
	bindableEvent:Fire(current)
end

function BoardSwitch.ClearCurrent(p)
	if current == p then
		current = nil
		BoardZoom.SetActive(false)
		BoardZoom.Reset()
		fn(nil)
		bindableEvent:Fire(nil)
	end
end

function BoardSwitch.GetCurrent()
	return current
end

function BoardSwitch.Request(p)
	if v3 or not current or current == p then
		return
	end

	local v4 = v[current]
	local v5 = v[p]

	if v4 and v5 then
		v3 = true
		task.spawn(function()
			local v6 = current
			local success, result = pcall(v4.ExitForHandoff)

			if success and typeof(result) == "table" then
				BoardSwitch.ClearCurrent(v6)
				local success2, result2 = pcall(v5.EnterWithHandoff, result)

				if not success2 then
					warn("[BoardSwitch] gagal pindah ke " .. tostring(p) .. ": " .. tostring(result2))
					pcall(v5.Exit)
				end
			elseif not success then
				warn("[BoardSwitch] gagal menutup " .. tostring(v6) .. ": " .. tostring(result))
			end

			v3 = false
		end)
	end
end

function BoardSwitch.Back()
	local v4 = current and v[current]

	if not v4 then
		return
	end

	if v4.Back then
		v4.Back()
	elseif v.Overview then
		BoardSwitch.Request("Overview")
	elseif v4.Exit then
		v4.Exit()
	end
end

local boardHints = nil
local textLabel = nil

local function hintText(p): string -- 1 equivalent call inferred from this helper
	local v4 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	if p == "Overview" then
		if v4 then
			return "TAP A PAPER TO ZOOM IN  -  PINCH TO ZOOM"
		end

		return "CLICK A PAPER TO ZOOM IN  -  SCROLL TO ZOOM  -  Q TO LEAVE"
	elseif v4 then
		return "TAP ANOTHER PAPER TO SWITCH  -  TAP EMPTY SPACE TO GO BACK"
	else
		return "CLICK ANOTHER PAPER TO SWITCH  -  CLICK EMPTY SPACE OR Q TO GO BACK"
	end
end

fn = function(p)
	if p then
		if not boardHints then
			local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
			boardHints = Instance.new("ScreenGui")
			boardHints.Name = "BoardHints"
			boardHints.ResetOnSpawn = false
			boardHints.DisplayOrder = 59
			boardHints.Enabled = false
			boardHints.Parent = playerGui

			local holder = Instance.new("Frame")
			holder.Name = "Holder"

			holder.AnchorPoint = Vector2.new(0.5, 1)
			holder.Position = UDim2.new(0.5, 0, 1, -72)
			holder.Size = UDim2.fromOffset(640, 20)

			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.Parent = boardHints

			textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.fromScale(1, 1)

			textLabel.Font = Enum.Font.SpecialElite
			textLabel.TextSize = 12
			textLabel.TextColor3 = Color3.fromRGB(244, 232, 200)
			textLabel.TextScaled = false

			textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			textLabel.TextStrokeTransparency = 0.35
			textLabel.Parent = holder
		end

		textLabel.Text = hintText(p) -- inferred equivalent call
		boardHints.Enabled = true
	elseif boardHints then
		boardHints.Enabled = false
	end
end

local function isBoardTarget(target): boolean
	if not target then
		return false
	end

	if v2[target] or (string.find(target.Name, "^Tape") or string.find(target.Name, "^BannerTape")) then
		return true
	end

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		for _, surfaceGui in ipairs(playerGui:GetChildren()) do
			if surfaceGui:IsA("SurfaceGui") and surfaceGui.Active and surfaceGui.Adornee == target then
				return true
			end
		end
	end

	return false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if
		gameProcessed
		or not current
		or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	local v4 = current
	local v5 = v[v4]

	if v5 and not v5.NoEmptyClickBack then
		task.delay(0.15, function()
			if current ~= v4 or v3 or isBoardTarget(LocalPlayer:GetMouse().Target) then
				return
			end

			BoardSwitch.Back()
		end)
	end
end)

return BoardSwitch