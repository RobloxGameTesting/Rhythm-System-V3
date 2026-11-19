local RunService = game:GetService("RunService")
local GuiFade = require(script.Parent:WaitForChild("GuiFade"))
local UserInputService = game:GetService("UserInputService")

local StreakNoticeFx = {}
StreakNoticeFx.__index = StreakNoticeFx

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local SpecialElite = Enum.Font.SpecialElite
local size2 = v and 30 or 46
local size3 = v and 18 or 28
local v2 = v and 60 or 170
local v3 = v and 10 or 24
local v4 = v and 0.6 or 1
local v5 = v and 0.7 or 1
local v6 = {
	Plate = Color3.fromRGB(20, 20, 19),
	Edge = Color3.fromRGB(122, 120, 114),
	Rust = Color3.fromRGB(74, 42, 28),
	Tape = Color3.fromRGB(206, 190, 150),
	TapeDark = Color3.fromRGB(96, 90, 80),
	Ink = Color3.fromRGB(14, 13, 12),
	Bone = Color3.fromRGB(222, 220, 214),
	TypeInk = Color3.fromRGB(28, 24, 20)
}

local color = Color3.new(1, 1, 1)

local function detectInputKind(): string
	local success, result = pcall(function()
		return UserInputService:GetLastInputType()
	end)

	if success and result then
		local name = result.Name

		if string.sub(name, 1, 7) == "Gamepad" then
			return "Gamepad"
		end

		if name == "Touch" then
			return "Touch"
		end

		if name == "Keyboard" or string.sub(name, 1, 5) == "Mouse" then
			return "Keyboard"
		end
	end

	if v then
		return "Touch"
	end

	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
		return "Gamepad"
	end

	return "Keyboard"
end

local function getHintLabel(inputKind) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function()
		local SettingsState = require(script.Parent.SettingsState)
		local starPowerBindingName = SettingsState.GetStarPowerBindingName()
		local v7 = string.sub(starPowerBindingName, 1, 6) == "Button"
			or string.sub(starPowerBindingName, 1, 4) == "DPad"

		if inputKind == "Gamepad" then
			return v7 and SettingsState.GetStarPowerKeyLabel() or "SELECT"
		end

		if v7 then
			return "H"
		end

		return SettingsState.GetStarPowerKeyLabel()
	end)

	if success and type(result) == "string" and result ~= "" then
		return result
	end

	return if inputKind == "Gamepad" then "SELECT" else "SPACE"
end

local palette2 = {
	Color3.fromRGB(206, 170, 62),
	Color3.fromRGB(190, 156, 56),
	Color3.fromRGB(220, 183, 78),
	Color3.fromRGB(176, 144, 52)
}

local palette3 = {
	Color3.fromRGB(205, 188, 150),
	Color3.fromRGB(190, 170, 130),
	Color3.fromRGB(176, 152, 112),
	Color3.fromRGB(214, 200, 164)
}

local palette4 = {
	Color3.fromRGB(120, 168, 196),
	Color3.fromRGB(104, 150, 182),
	Color3.fromRGB(140, 184, 208),
	Color3.fromRGB(92, 136, 168)
}

local v7 = {
	{
		Accent = Color3.fromRGB(232, 182, 72),
		Hot = Color3.fromRGB(255, 214, 120),
		Bolt = Color3.fromRGB(255, 238, 190),
		Caption = "WARMING UP",
		Hold = 1.5,
		Sparks = 16,
		Bolts = 3,
		Embers = 8,
		Crackle = 0.34
	},
	{
		Accent = Color3.fromRGB(240, 150, 50),
		Hot = Color3.fromRGB(255, 190, 90),
		Bolt = Color3.fromRGB(255, 230, 170),
		Caption = "ON FIRE",
		Hold = 1.7,
		Sparks = 24,
		Bolts = 5,
		Embers = 11,
		Crackle = 0.26
	},
	{
		Accent = Color3.fromRGB(236, 104, 40),
		Hot = Color3.fromRGB(255, 160, 80),
		Bolt = Color3.fromRGB(255, 222, 170),
		Caption = "UNSTOPPABLE",
		Hold = 1.9,
		Sparks = 34,
		Bolts = 7,
		Embers = 14,
		Crackle = 0.2
	},
	{
		Accent = Color3.fromRGB(232, 56, 44),
		Hot = Color3.fromRGB(255, 140, 90),
		Bolt = Color3.fromRGB(255, 240, 215),
		Caption = "LEGENDARY",
		Hold = 2.1,
		Sparks = 46,
		Bolts = 9,
		Embers = 18,
		Crackle = 0.15
	},
	StarPower = {
		Accent = Color3.fromRGB(96, 196, 255),
		Hot = Color3.fromRGB(170, 228, 255),
		Bolt = Color3.fromRGB(220, 244, 255),
		Caption = "OVERDRIVE",
		Hold = 2,
		Sparks = 32,
		Bolts = 7,
		Embers = 14,
		Crackle = 0.18
	},
	BandBonus = {
		Accent = Color3.fromRGB(255, 196, 64),
		Hot = Color3.fromRGB(255, 226, 130),
		Bolt = Color3.fromRGB(255, 246, 200),
		Caption = "TEAMWORK",
		Hold = 2.2,
		Sparks = 36,
		Bolts = 8,
		Embers = 16,
		Crackle = 0.16
	}
}

local function lerp(p, p2, p3) -- 2 equivalent calls inferred from this helper
	return p + (p2 - p) * p3
end

local function clamp01(value) -- 19 equivalent calls inferred from this helper
	return (math.clamp(value, 0, 1))
end

local function rnd(p, p2) -- 91 equivalent calls inferred from this helper
	return p + math.random() * (p2 - p)
end

local function tierForStreak(p): number -- 2 equivalent calls inferred from this helper
	if p >= 600 then
		return 4
	end

	if p >= 300 then
		return 3
	end

	return if p >= 100 then 2 else 1
end

local v8 = {
	A = {
		{ 0, 1, 0.5, 0 },
		{ 0.5, 0, 1, 1 },
		{ 0.2, 0.65, 0.8, 0.65 }
	},
	B = {
		{ 0, 0, 0, 1 },
		{ 0, 0, 0.85, 0 },
		{ 0.85, 0, 0.85, 0.5 },
		{ 0, 0.5, 0.85, 0.5 },
		{ 0.85, 0.5, 0.85, 1 },
		{ 0, 1, 0.85, 1 }
	},
	C = {
		{ 1, 0, 0, 0 },
		{ 0, 0, 0, 1 },
		{ 0, 1, 1, 1 }
	},
	D = {
		{ 0, 0, 0, 1 },
		{ 0, 0, 0.85, 0.25 },
		{ 0.85, 0.25, 0.85, 0.75 },
		{ 0.85, 0.75, 0, 1 }
	},
	E = {
		{ 0, 0, 0, 1 },
		{ 0, 0, 1, 0 },
		{ 0, 0.5, 0.8, 0.5 },
		{ 0, 1, 1, 1 }
	},
	F = {
		{ 0, 0, 0, 1 },
		{ 0, 0, 1, 0 },
		{ 0, 0.5, 0.8, 0.5 }
	},
	G = {
		{ 1, 0, 0, 0 },
		{ 0, 0, 0, 1 },
		{ 0, 1, 1, 1 },
		{ 1, 1, 1, 0.5 },
		{ 1, 0.5, 0.55, 0.5 }
	},
	H = {
		{ 0, 0, 0, 1 },
		{ 1, 0, 1, 1 },
		{ 0, 0.5, 1, 0.5 }
	},
	I = {
		{ 0, 0, 0, 1 }
	},
	J = {
		{ 1, 0, 1, 1 },
		{ 1, 1, 0.1, 1 }
	},
	K = {
		{ 0, 0, 0, 1 },
		{ 1, 0, 0, 0.55 },
		{ 0.25, 0.45, 1, 1 }
	},
	L = {
		{ 0, 0, 0, 1 },
		{ 0, 1, 1, 1 }
	},
	M = {
		{ 0, 1, 0, 0 },
		{ 0, 0, 0.5, 0.6 },
		{ 0.5, 0.6, 1, 0 },
		{ 1, 0, 1, 1 }
	},
	N = {
		{ 0, 1, 0, 0 },
		{ 0, 0, 1, 1 },
		{ 1, 1, 1, 0 }
	},
	O = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 1 },
		{ 1, 1, 0, 1 },
		{ 0, 1, 0, 0 }
	},
	P = {
		{ 0, 0, 0, 1 },
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 0.5 },
		{ 1, 0.5, 0, 0.5 }
	},
	Q = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 1 },
		{ 1, 1, 0, 1 },
		{ 0, 1, 0, 0 },
		{ 0.6, 0.7, 1.05, 1.1 }
	},
	R = {
		{ 0, 0, 0, 1 },
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 0.5 },
		{ 1, 0.5, 0, 0.5 },
		{ 0.4, 0.5, 1, 1 }
	},
	S = {
		{ 1, 0, 0, 0 },
		{ 0, 0, 0, 0.5 },
		{ 0, 0.5, 1, 0.5 },
		{ 1, 0.5, 1, 1 },
		{ 1, 1, 0, 1 }
	},
	T = {
		{ 0, 0, 1, 0 },
		{ 0.5, 0, 0.5, 1 }
	},
	U = {
		{ 0, 0, 0, 1 },
		{ 0, 1, 1, 1 },
		{ 1, 1, 1, 0 }
	},
	V = {
		{ 0, 0, 0.5, 1 },
		{ 0.5, 1, 1, 0 }
	},
	W = {
		{ 0, 0, 0.25, 1 },
		{ 0.25, 1, 0.5, 0.35 },
		{ 0.5, 0.35, 0.75, 1 },
		{ 0.75, 1, 1, 0 }
	},
	X = {
		{ 0, 0, 1, 1 },
		{ 1, 0, 0, 1 }
	},
	Y = {
		{ 0, 0, 0.5, 0.5 },
		{ 1, 0, 0.5, 0.5 },
		{ 0.5, 0.5, 0.5, 1 }
	},
	Z = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 0, 1 },
		{ 0, 1, 1, 1 }
	},
	["0"] = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 1 },
		{ 1, 1, 0, 1 },
		{ 0, 1, 0, 0 }
	},
	["1"] = {
		{ 1, 0, 1, 1 },
		{ 1, 0, 0, 0.3 }
	},
	["2"] = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 0.5 },
		{ 1, 0.5, 0, 0.5 },
		{ 0, 0.5, 0, 1 },
		{ 0, 1, 1, 1 }
	},
	["3"] = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 1 },
		{ 0, 0.5, 1, 0.5 },
		{ 0, 1, 1, 1 }
	},
	["4"] = {
		{ 0, 0, 0, 0.55 },
		{ 0, 0.55, 1, 0.55 },
		{ 0.8, 0, 0.8, 1 }
	},
	["5"] = {
		{ 1, 0, 0, 0 },
		{ 0, 0, 0, 0.5 },
		{ 0, 0.5, 1, 0.5 },
		{ 1, 0.5, 1, 1 },
		{ 1, 1, 0, 1 }
	},
	["6"] = {
		{ 1, 0, 0, 0 },
		{ 0, 0, 0, 1 },
		{ 0, 1, 1, 1 },
		{ 1, 1, 1, 0.5 },
		{ 1, 0.5, 0, 0.5 }
	},
	["7"] = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 0.35, 1 }
	},
	["8"] = {
		{ 0, 0, 1, 0 },
		{ 1, 0, 1, 1 },
		{ 1, 1, 0, 1 },
		{ 0, 1, 0, 0 },
		{ 0, 0.5, 1, 0.5 }
	},
	["9"] = {
		{ 0, 0, 1, 0 },
		{ 0, 0, 0, 0.5 },
		{ 0, 0.5, 1, 0.5 },
		{ 1, 0, 1, 1 },
		{ 1, 1, 0, 1 }
	},
	["!"] = {
		{ 0, 0, 0, 0.62 },
		{ 0, 0.86, 0, 1 }
	},
	["+"] = {
		{ 0.5, 0.15, 0.5, 0.85 },
		{ 0.1, 0.5, 0.9, 0.5 }
	},
	["%"] = {
		{ 1, 0, 0, 1 },
		{ 0, 0, 0.32, 0 },
		{ 0.32, 0, 0.32, 0.3 },
		{ 0.32, 0.3, 0, 0.3 },
		{ 0, 0.3, 0, 0 },
		{ 0.68, 0.7, 1, 0.7 },
		{ 1, 0.7, 1, 1 },
		{ 1, 1, 0.68, 1 },
		{ 0.68, 1, 0.68, 0.7 }
	}
}

local v9 = {
	I = 0,
	["!"] = 0,
	["1"] = 0.5,
	M = 1.3,
	W = 1.3
}

function StreakNoticeFx.Attach(track, options)
	local v10 = options or {}
	local self = setmetatable({}, StreakNoticeFx)
	self.Track = track
	self.CenterY = v10.CenterY or 130
	self.Scale = v10.Scale or 1
	self.PromptPlaceFn = v10.PromptPlaceFn
	self.StrikeTargetFn = v10.StrikeTargetFn
	self.HoldMul = v10.HoldMul or 1
	self.NoClamp = v10.NoClamp == true
	self.Plain = v10.Plain == true
	self.PlaceFn = v10.PlaceFn
	self.Parts = {}
	self.BoltCount = 0
	self.Conn = nil
	self.Current = nil
	self.Pending = nil
	self.Gen = 0
	return self
end

function StreakNoticeFx.MakeTopCenterPlace(p, callback)
	return function(p2, p3, value)
		value = value or 1
		local absolutePosition = p.AbsolutePosition
		local x = p.AbsoluteSize.X
		local v10 = v and 26 or 46
		local v11 = p3 * value
		local v12 = 1
		local v13 = v10 + v11 / 2
		local success, result = pcall(callback)

		if success and result then
			local v14 = result - absolutePosition.Y - 10 - v10

			if v11 <= v14 then
				v13 = v10 + v11 / 2 + (v14 - v11) * 0.3
			else
				v12 = math.clamp(v14 / v11, 0.55, 1)
				v13 = v10 + v11 * v12 / 2
			end
		end

		local v14 = p2 * value * v12
		return (x - v14) / 2, v13, v14
	end
end

function StreakNoticeFx:_ensureLayer()
	if self.Layer and self.Layer.Parent then
		return self.Layer
	end

	local streakNoticeLayer = Instance.new("Frame")
	streakNoticeLayer.Name = "StreakNoticeLayer"
	streakNoticeLayer.AnchorPoint = Vector2.new(0.5, 0.5)
	streakNoticeLayer.Position = UDim2.new(0.5, 0, 0, self.CenterY)
	streakNoticeLayer.Size = UDim2.fromOffset(0, 0)
	streakNoticeLayer.BackgroundTransparency = 1
	streakNoticeLayer.ClipsDescendants = false
	streakNoticeLayer.ZIndex = 40
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = self.Scale
	uiScale.Parent = streakNoticeLayer
	self.LayerScale = uiScale
	streakNoticeLayer.Parent = self.Track
	self.Layer = streakNoticeLayer
	return streakNoticeLayer
end

function StreakNoticeFx:_ensureDriver()
	if self.Conn then
		return
	end

	self.Conn = RunService.RenderStepped:Connect(function(dt)
		self:_step((math.min(dt, 0.05)))

		GuiFade.Refresh(self.Track)
	end)
end

function StreakNoticeFx:Reset()
	self.Gen += 1

	if self.Conn then
		self.Conn:Disconnect()
		self.Conn = nil
	end

	self.Parts = {}
	self.BoltCount = 0
	self.Current = nil
	self.Pending = nil
	self.PromptChargeLatest = nil

	if self.Layer then
		self.Layer:Destroy()
		self.Layer = nil
	end
end

function StreakNoticeFx.LifetimeFor(p, p2, value)
	local v10 = p2 == "BandBonus" and v7.BandBonus
		or (p2 == "StarPower" or p2 == "StarPowerPrompt") and v7.StarPower
		or v7[tierForStreak(value or 0)] -- inferred equivalent call

	return (p2 == "StarPowerPrompt" and 600 or v10.Hold) * p.HoldMul + 0.35 + 0.9
end

function StreakNoticeFx:Show(kind, p, p2)
	if not (self.Track and self.Track.Parent) then
		return
	end

	local pending = {
		Kind = kind,
		Value = p,
		Sparkle = not p2 or p2.Sparkle ~= false,
		InputKind = p2 and p2.InputKind
	}
	local current = self.Current

	if current and current.Note.Kind == "StarPowerPrompt" and not current.Shattered and current.Age < current.Hold then
		return
	end

	if current then
		if current.Age < 0.8 then
			if not self.Pending or self.Pending.Kind == "Streak" or kind ~= "Streak" then
				self.Pending = pending
			end

			return
		end

		self:_endCurrent(false)
	end

	self:_start(pending)
end

function StreakNoticeFx:Dismiss(p)
	local current = self.Current

	if current and current.Note.Kind == p and not current.Shattered and current.Age < current.Hold then
		current.Hold = current.Age
		current.Total = current.Age + 0.35
	end

	if self.Pending and self.Pending.Kind == p then
		self.Pending = nil
	end
end

function StreakNoticeFx:SetPromptCharge(p, p2)
	local v10 = clamp01(tonumber(p) or 0) -- inferred equivalent call
	self.PromptChargeLatest = v10
	self.PromptAutoLatest = p2 ~= false
	local current = self.Current

	if current and current.ChargeState then
		current.ChargeState.Target = v10
		current.ChargeState.Auto = self.PromptAutoLatest
	end
end

function StreakNoticeFx:_endCurrent(p)
	local current = self.Current
	self.Current = nil

	if current and current.Holder then
		current.Holder:Destroy()
	end

	if p ~= false and self.Pending then
		local pending = self.Pending
		self.Pending = nil
		self:_start(pending)
	end
end

local function newFrame(parent, zIndex) -- 9 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BorderSizePixel = 0
	frame.ZIndex = zIndex
	frame.Parent = parent
	return frame
end

function StreakNoticeFx:_spark(p, total, total2, p2, p3, p4, p5, p6)
	if v2 <= #self.Parts then
		return
	end

	local frame = newFrame(self.Layer, 12) -- inferred equivalent call
	local v10 = math.cos(p2) * p3
	local v11 = math.sin(p2) * p3
	local total3 = 0
	local v12 = p6 and color or p.Hot
	local accent = p.Accent
	self.Parts[#self.Parts + 1] = function(p7): boolean
		total3 += p7

		if p4 <= total3 then
			frame:Destroy()
			return false
		end

		local v13 = math.exp(-2.6 * p7)
		v10 *= v13
		v11 = v11 * v13 + 340 * v5 * p7
		total += v10 * p7
		total2 += v11 * p7
		local v14 = total3 / p4
		local v15 = math.sqrt(v10 * v10 + v11 * v11)
		frame.Position = UDim2.fromOffset(total, total2)
		frame.Rotation = math.deg((math.atan2(v11, v10)))
		frame.Size = UDim2.fromOffset(math.clamp(v15 * 0.04, 4, 24), (math.max(1.5, p5 * (1 - v14 * 0.5))))
		frame.BackgroundColor3 = v12:Lerp(accent, clamp01(v14 * 1.6)) -- inferred equivalent call
		frame.BackgroundTransparency = v14 * v14 * 0.95
		return true
	end
end

function StreakNoticeFx:_ember(p, total, total2)
	if v2 <= #self.Parts then
		return
	end

	local frame = newFrame(self.Layer, 11) -- inferred equivalent call
	local v10 = rnd(2.5, v and 4 or 5) -- inferred equivalent call
	frame.Size = UDim2.fromOffset(v10, v10)
	frame.Rotation = rnd(0, 90) -- inferred equivalent call
	frame.BackgroundColor3 = p.Hot:Lerp(p.Accent, rnd(0, 1)) -- inferred equivalent call
	local v11 = -rnd(40, 110) * v5 -- inferred equivalent call
	local v12 = rnd(-26, 26) * v5 -- inferred equivalent call
	local v13 = rnd(0.8, 1.5) -- inferred equivalent call
	local total3 = 0
	local v14 = rnd(0, 6.28) -- inferred equivalent call

	self.Parts[#self.Parts + 1] = function(p2): boolean
		total3 += p2

		if v13 <= total3 then
			frame:Destroy()
			return false
		end

		total += (v12 + math.sin(total3 * 6 + v14) * 24 * v5) * p2
		total2 += v11 * p2
		local v15 = total3 / v13
		frame.Position = UDim2.fromOffset(total, total2)
		frame.BackgroundTransparency = clamp01(v15 * v15 + (math.random() < 0.15 and 0.4 or 0)) -- inferred equivalent call
		return true
	end
end

function StreakNoticeFx:_grit(p, p2, p3, p4)
	if v2 <= #self.Parts then
		return
	end

	local v10 = {}

	for i = 1, p3 do
		local frame = newFrame(self.Layer, 12) -- inferred equivalent call
		frame.Size = UDim2.fromOffset(rnd(1, 3), rnd(1, 2)) -- inferred equivalent call
		frame.BackgroundColor3 = v6.Bone
		v10[i] = frame
	end

	local total = 0
	local total2 = 1
	self.Parts[#self.Parts + 1] = function(p5): boolean
		total += p5
		total2 += p5

		if p4 <= total then
			for i = 1, p3 do
				v10[i]:Destroy()
			end

			return false
		else
			if total2 >= 0.04 then
				total2 = 0

				for i = 1, p3 do
					local v11 = v10[i]
					v11.Position = UDim2.fromOffset(rnd(-p * 0.55, p * 0.55), rnd(-p2 * 0.65, p2 * 0.65)) -- inferred equivalent call
				end
			end

			local v11 = total / p4

			for i = 1, p3 do
				v10[i].BackgroundTransparency = clamp01(0.3 + v11 * 0.7 + rnd(0, 0.3)) -- inferred equivalent call
			end

			return true
		end
	end
end

function StreakNoticeFx:_bolt(p, p2, p3, p4, p5, p6, p7, p8, value)
	if not (v3 <= self.BoltCount) and not (v2 <= #self.Parts) then
		self.BoltCount += 1
		local v10 = v and 2 or 3
		local v11 = {}
		local v12 = {}

		for i = 1, p7 do
			local frame = newFrame(self.Layer, 8) -- inferred equivalent call
			frame.BackgroundColor3 = p.Accent
			v11[i] = frame
			local frame2 = newFrame(self.Layer, 10) -- inferred equivalent call
			frame2.BackgroundColor3 = p.Bolt
			v12[i] = frame2
		end

		local v13 = math.cos(p4)
		local v14 = math.sin(p4)
		local v15 = -v14
		local v16 = p5 * (value or 0.17)
		local function relayout()
			local v17 = {}
			local v18 = {}

			for i = 0, p7 do
				local v19 = i / p7
				local v20

				if i == 0 or i == p7 then
					v20 = 0
				else
					v20 = rnd(-v16, v16) * (1 - v19 * 0.3) -- inferred equivalent call
				end

				v17[i] = p2 + v13 * p5 * v19 + v15 * v20
				v18[i] = p3 + v14 * p5 * v19 + v13 * v20
			end

			for i = 1, p7 do
				local v19 = v17[i - 1]
				local v20 = v18[i - 1]
				local v21 = v17[i]
				local v22 = v18[i]
				local midpoint = (v19 + v21) / 2
				local midpoint2 = (v20 + v22) / 2
				local v23 = math.sqrt((v21 - v19) ^ 2 + (v22 - v20) ^ 2)
				local rotation = math.deg((math.atan2(v22 - v20, v21 - v19)))
				local v24 = v11[i]
				local v25 = v12[i]
				v24.Position = UDim2.fromOffset(midpoint, midpoint2)
				v24.Size = UDim2.fromOffset(v23 + 4, v10 * 3.4)
				v24.Rotation = rotation
				v25.Position = UDim2.fromOffset(midpoint, midpoint2)
				v25.Size = UDim2.fromOffset(v23 + 2, v10)
				v25.Rotation = rotation
			end
		end
		relayout()

		if p8 and p5 > 100 then
			local v17 = rnd(0.35, 0.6) -- inferred equivalent call
			local v18 = math.random() < 0.5 and -1 or 1
			self:_bolt(
				p,
				p2 + v13 * p5 * v17,
				p3 + v14 * p5 * v17,
				p4 + v18 * rnd(0.6, 1), -- inferred equivalent call
				p5 * 0.5,
				p6 * 0.85,
				math.max(4, p7 - 3),
				false,
				value
			)
		end

		local total = 0
		local total2 = 0
		self.Parts[#self.Parts + 1] = function(p9): boolean
			total += p9
			total2 += p9

			if p6 <= total then
				for i = 1, p7 do
					v11[i]:Destroy()
					v12[i]:Destroy()
				end

				self.BoltCount -= 1
				return false
			else
				if total2 >= 0.045 then
					total2 = 0
					relayout()
				end

				local v17 = total / p6
				local v18 = math.random() < 0.28 and 0.4 or 0
				local backgroundTransparency = clamp01(v17 * v17 * 0.9 + v18) -- inferred equivalent call
				local backgroundTransparency2 = clamp01(0.68 + v17 * 0.32 + v18 * 0.3) -- inferred equivalent call

				for i = 1, p7 do
					v12[i].BackgroundTransparency = backgroundTransparency
					v11[i].BackgroundTransparency = backgroundTransparency2
				end

				return true
			end
		end
	end
end

function StreakNoticeFx:_layerOrigin()
	local layer = self.Layer
	local track = self.Track
	local position = layer.Position
	return track.AbsolutePosition + Vector2.new(
		position.X.Offset + position.X.Scale * track.AbsoluteSize.X,
		position.Y.Offset + position.Y.Scale * track.AbsoluteSize.Y
	)
end

function StreakNoticeFx:_topCenterAbs()
	local track = self.Track

	if not self.PromptPlaceFn then
		return track.AbsolutePosition.X + track.AbsoluteSize.X / 2, track.AbsolutePosition.Y + 90
	end

	local success, result, v10, v11 = pcall(self.PromptPlaceFn, 260, 110, self.Scale)

	if success and result and v10 and v11 then
		return track.AbsolutePosition.X + result + v11 / 2, track.AbsolutePosition.Y + v10
	end

	return track.AbsolutePosition.X + track.AbsoluteSize.X / 2, track.AbsolutePosition.Y + 90
end

function StreakNoticeFx:_after(p, callback)
	local total = 0
	self.Parts[#self.Parts + 1] = function(p2): boolean
		total += p2

		if p <= total then
			callback()
			return false
		end

		return true
	end
end

function StreakNoticeFx:_ring(p, p2, p3, p4, p5, color2, thickness)
	local parent = newFrame(self.Layer, 13) -- inferred equivalent call
	parent.BackgroundTransparency = 1
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = parent
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color2
	uiStroke.Thickness = thickness
	uiStroke.Parent = parent
	parent.Position = UDim2.fromOffset(p, p2)
	parent.Size = UDim2.fromOffset(p3 * 2, p3 * 2)
	local total = 0
	self.Parts[#self.Parts + 1] = function(p6): boolean
		total += p6

		if p5 <= total then
			parent:Destroy()
			return false
		end

		local v10 = total / p5
		local v11 = 1 - (1 - v10) * (1 - v10)
		local v12 = (p3 + (p4 - p3) * v11) * 2
		parent.Size = UDim2.fromOffset(v12, v12)
		uiStroke.Transparency = clamp01(v10 * v10) -- inferred equivalent call
		uiStroke.Thickness = thickness * (1 - v10 * 0.6)
		return true
	end
end

function StreakNoticeFx:_glowRect(p, p2, p3, p4, p5, p6, backgroundColor, backgroundTransparency)
	local parent = newFrame(self.Layer, 11) -- inferred equivalent call
	parent.BackgroundColor3 = backgroundColor
	parent.Position = UDim2.fromOffset(p, p2)
	parent.Size = UDim2.fromOffset(p3, p5)
	parent.BackgroundTransparency = backgroundTransparency

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = parent
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Parent = parent
	local total = 0
	self.Parts[#self.Parts + 1] = function(p7): boolean
		total += p7

		if p6 <= total then
			parent:Destroy()
			return false
		end

		local v10 = total / p6
		local v11 = 1 - (1 - v10) * (1 - v10)
		parent.Size = UDim2.fromOffset(lerp(p3, p4, v11), p5 * (1 - 0.5 * v10)) -- inferred equivalent call
		parent.BackgroundTransparency = lerp(backgroundTransparency, 1, v10 * v10) -- inferred equivalent call
		return true
	end
end

function StreakNoticeFx:_strikeImpact(p, p2, p3)
	for i = 1, math.max(4, (math.floor(8 * v4 + 0.5))) do
		self:_spark(
			p,
			p2,
			p3,
			rnd(-2.9845130209103035, -0.1570796326794897), -- inferred equivalent call
			rnd(280, 720) * v5, -- inferred equivalent call
			rnd(0.25, 0.6), -- inferred equivalent call
			v and 2 or 3,
			i % 3 == 0
		)
	end
end

function StreakNoticeFx:_strikeLane(p, p2, p3)
	if not self.StrikeTargetFn then
		return
	end

	local success, result, v10, v11 = pcall(self.StrikeTargetFn)

	if not (success and result and v10 and v11 and v11 > 10) then
		return
	end

	local layerOrigin = self:_layerOrigin()
	local scale = self.LayerScale and self.LayerScale.Scale or 1
	local function toLocal(p4, p5) -- 2 equivalent calls inferred from this helper
		return (p4 - layerOrigin.X) / scale, (p5 - layerOrigin.Y) / scale
	end

	local v12, v13 = toLocal(result + v11 / 2, v10) -- inferred equivalent call
	local v14 = v11 / scale
	local v15 = v and 3 or 5

	local function wave(p4, p5)
		for i = 1, p4 do
			local v16, v17 = toLocal(result + v11 * (0.1 + 0.8 * ((i - 0.5) / p4) + rnd(-0.05, 0.05)), v10) -- inferred equivalent call
			local v18 = v16 - p2
			local v19 = v17 - p3
			local v20 = math.sqrt(v18 * v18 + v19 * v19)

			if not (v20 > 30) then
				continue
			end

			self:_bolt(
				p,
				p2,
				p3,
				math.atan2(v19, v18),
				v20,
				rnd(0.32, 0.46) * p5, -- inferred equivalent call
				math.clamp(math.floor(v20 / 34), 8, 24),
				true,
				0.06
			)
			self:_strikeImpact(p, v16, v17)
		end
	end

	wave(v15, 1)

	self:_ring(v12, v13, 20, v14 * 0.5, 0.45, p.Hot, 3)
	self:_after(0.14, function()
		wave(math.max(2, v15 - 2), 0.8)
	end)
end

function StreakNoticeFx:_shatterBurst(p, p2, p3)
	local v10 = { v6.Plate, v6.Plate, v6.Rust, v6.Edge, v6.Tape, p.Hot, p.Accent }

	for _ = 1, math.max(10, (math.floor(22 * v4 + 0.5))) do
		local v11 = rnd(-p2 * 0.45, p2 * 0.45) -- inferred equivalent call
		local v12 = rnd(-p3 * 0.42, p3 * 0.42) -- inferred equivalent call
		local parent = newFrame(self.Layer, 14) -- inferred equivalent call
		parent.Size = UDim2.fromOffset(rnd(22, 70), rnd(12, 38)) -- inferred equivalent call
		parent.BackgroundColor3 = v10[math.random(#v10)]
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = v6.Edge
		uiStroke.Thickness = 1.2
		uiStroke.Transparency = 0.2
		uiStroke.Parent = parent
		local v13 = v11
		local v14 = v12 - 10
		local v15 = math.sqrt(v13 * v13 + v14 * v14) + 1
		local v16 = rnd(320, 820) * v5 -- inferred equivalent call
		local v17 = v13 / v15 * v16 + rnd(-60, 60) -- inferred equivalent call
		local v18 = -math.abs(v14 / v15 * v16) - rnd(40, 200) * v5 -- inferred equivalent call
		local v19 = v12
		local rotation = rnd(-30, 30) -- inferred equivalent call
		local v20 = rnd(-620, 620) -- inferred equivalent call
		local v21 = rnd(0.7, 1.05) -- inferred equivalent call
		local total = 0
		self.Parts[#self.Parts + 1] = function(p4): boolean
			total += p4

			if v21 <= total then
				parent:Destroy()
				return false
			end

			v17 *= math.exp(-1.6 * p4)
			v18 *= math.exp(-1.6 * p4)
			v11 += v17 * p4
			v12 = math.min(v12 + v18 * p4, v19)
			rotation += v20 * p4
			local backgroundTransparency = clamp01((total / v21 - 0.55) / 0.45) -- inferred equivalent call
			parent.Position = UDim2.fromOffset(v11, v12)
			parent.Rotation = rotation
			parent.BackgroundTransparency = backgroundTransparency
			uiStroke.Transparency = 0.2 + 0.8 * backgroundTransparency
			return true
		end
	end

	for i = 1, math.max(10, (math.floor(34 * v4 + 0.5))) do
		self:_spark(
			p,
			rnd(-p2 * 0.3, p2 * 0.3), -- inferred equivalent call
			rnd(-p3 * 0.25, p3 * 0.25), -- inferred equivalent call
			rnd(-3.0473448739820994, -0.0942477796076937), -- inferred equivalent call
			rnd(380, 1000) * v5, -- inferred equivalent call
			rnd(0.3, 0.8), -- inferred equivalent call
			v and 2 or 3,
			i % 3 == 0
		)
	end

	self:_ring(0, 0, 30, 420 * v5, 0.4, p.Hot, 4)
	self:_ring(0, 0, 10, 260 * v5, 0.3, color, 3)
	self:_glowRect(0, 0, p2 * 0.8, p2 * 1.25, p3 * 1.1, 0.3, color, 0.35)
end

function StreakNoticeFx:Shatter(p, p2): boolean
	if not (self.Track and self.Track.Parent) then
		return false
	end

	local current = self.Current
	local v10

	if current == nil or current.Note.Kind ~= p then
		v10 = false
	else
		v10 = not current.Shattered

		if v10 then
			if current.Age < current.Hold then
				v10 = current.Age >= 0.1
			else
				v10 = false
			end
		end
	end

	if p2 == false then
		self:Dismiss(p)
		return false
	end

	if self.Pending and self.Pending.Kind == p then
		self.Pending = nil
	end

	self:_ensureLayer()
	self:_ensureDriver()

	if v10 then
		current.Shattered = true
		current.Hold = 1e999
		current.Total = current.Age + 0.85
		current.Holder.Visible = false
		self:_shatterBurst(current.Theme, current.W, current.H)
		self:_strikeLane(current.Theme, 0, 0)
		return true
	else
		if current and current.Note.Kind == p then
			self:Dismiss(p)
		end

		local starPower = v7.StarPower
		local layerOrigin = self:_layerOrigin()
		local scale = self.LayerScale and self.LayerScale.Scale or 1
		local topCenterAbs, v11 = self:_topCenterAbs()
		local v12 = (topCenterAbs - layerOrigin.X) / scale
		local v13 = (v11 - layerOrigin.Y) / scale
		self:_ring(v12, v13, 12, 170 * v5, 0.32, starPower.Hot, 3)

		for i = 1, math.max(6, (math.floor(12 * v4 + 0.5))) do
			self:_spark(
				starPower,
				v12,
				v13,
				rnd(-3.0473448739820994, -0.0942477796076937), -- inferred equivalent call
				rnd(280, 760) * v5, -- inferred equivalent call
				rnd(0.25, 0.6), -- inferred equivalent call
				v and 2 or 3,
				i % 3 == 0
			)
		end

		self:_strikeLane(starPower, v12, v13)
		return false
	end
end

local function perimeter(w, h)
	local v10 = math.random(1, 4)
	local v11, v12

	if v10 == 1 then
		v11 = rnd(-w / 2, w / 2) -- inferred equivalent call
		v12 = -h / 2
	elseif v10 == 2 then
		v11 = rnd(-w / 2, w / 2) -- inferred equivalent call
		v12 = h / 2
	else
		if v10 == 3 then
			v11 = -w / 2
		else
			v11 = w / 2
		end

		v12 = rnd(-h / 2, h / 2) -- inferred equivalent call
	end

	return v11, v12, (math.atan2(v12 * 1.6, v11))
end

local function applyList(list, p)
	for _, item in ipairs(list) do
		item[1][item[2]] = 1 - (1 - item[3]) * p
	end
end

function StreakNoticeFx:_start(note)
	local layer = self:_ensureLayer()

	if not self.NoClamp then
		local v10 = self.Track.AbsolutePosition.Y + self.CenterY
		layer.Position = UDim2.new(0.5, 0, 0, self.CenterY + math.max(0, (v and 90 or 130) - v10))
	end

	local kind = note.Kind
	local isSP = kind == "StarPower" or kind == "StarPowerPrompt" or kind == "BandBonus"
	local tier

	if isSP then
		tier = 0
	else
		tier = tierForStreak(note.Value or 0) -- inferred equivalent call
	end

	local bandBonus = kind == "BandBonus" and v7.BandBonus or isSP and v7.StarPower or v7[tier]
	local v10

	if kind == "BandBonus" then
		v10 = {
			{ text = "BAND BONUS", size = size3, palette = palette3 },
			{
				text = "+" .. tostring(note.Value or 0) .. "%",
				size = size2,
				palette = palette2
			}
		}
	elseif kind == "StarPowerPrompt" then
		v10 = {
			{ text = "STAR POWER", size = size3, palette = palette3 },
			{ text = "PRESS!", size = size2, palette = palette4 }
		}
	elseif isSP then
		v10 = {
			{ text = "STAR POWER", size = size3, palette = palette3 },
			{ text = "READY", size = size2, palette = palette4 }
		}
	else
		v10 = {
			{
				text = tostring(note.Value or 0),
				size = size2,
				palette = palette2
			},
			{ text = "NOTE STREAK!", size = size3, palette = palette3 }
		}
	end

	local maxWidth = 0
	local total = 0

	for _, v11 in ipairs(v10) do
		v11.th = v11.size * 1.15
		v11.gh = v11.th * 0.9
		v11.gw = v11.gh * 0.62
		v11.sw = v11.gh * 0.2
		v11.gap = v11.sw * 0.85
		local total2 = 0

		for i = 1, #v11.text do
			local v12 = v11.text:sub(i, i)

			if v12 == " " then
				total2 += v11.gw * 0.7
			else
				total2 += v11.gw * (v9[v12] or 1) + v11.sw + v11.gap
			end
		end

		v11.width = total2 - v11.gap
		maxWidth = math.max(maxWidth, v11.width)
		total += v11.th
	end

	local v11 = total + (#v10 - 1) * 2

	local v12 = kind == "StarPowerPrompt" and (v and 28 or 38) or 0
	local v13 = kind == "StarPowerPrompt" and (v and 16 or 22) or 0
	local v14 = maxWidth + 40
	local v15 = v11 + 24 + v12 + v13

	self.LayerScale.Scale = self.Scale
	local promptPlaceFn = kind == "StarPowerPrompt" and self.PromptPlaceFn or self.PlaceFn

	if promptPlaceFn then
		local success, result, v16, v17 = pcall(promptPlaceFn, v14, v15, self.Scale)

		if success and result and v16 then
			local v18 = not (v17 and v17 > 0) and 1 or math.clamp(v17 / (v14 * self.Scale), 0.5, 1)

			self.LayerScale.Scale = self.Scale * v18
			layer.Position = UDim2.fromOffset(result + v14 * self.Scale * v18 / 2, v16)
		end
	end

	local reg = {}
	local function register(p, p2, backgroundTransparency) -- 1 equivalent call inferred from this helper
		reg[#reg + 1] = { p, p2, backgroundTransparency }
	end

	local v16 = newFrame(layer, 5) -- inferred equivalent call
	v16.Size = UDim2.fromOffset(v14, v15)
	v16.BackgroundTransparency = 1
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = v16

	local function sub(className, zIndex, p) -- 13 equivalent calls inferred from this helper
		local instance = Instance.new(className)

		if instance:IsA("GuiObject") then
			instance.BorderSizePixel = 0
			instance.ZIndex = zIndex
		end

		instance.Parent = p or v16
		return instance
	end

	local function corner(parent, p) -- 9 equivalent calls inferred from this helper
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, p)
		uiCorner.Parent = parent
	end

	local frame

	if not self.Plain then
		frame = Instance.new("Frame")

		if frame:IsA("GuiObject") then
			frame.BorderSizePixel = 0
			frame.ZIndex = 1
		end

		frame.Parent = v16

		frame.AnchorPoint = Vector2.new(0, 0.5)
		frame.Position = UDim2.new(0, 0, 0.5, 0)
		frame.Size = UDim2.fromOffset(0, v15)
		frame.BackgroundTransparency = 1
		frame.ClipsDescendants = true
		local parent = sub("Frame", 1, frame) -- inferred equivalent call
		parent.Size = UDim2.fromOffset(v14, v15)
		parent.BackgroundColor3 = v6.Plate
		parent.BackgroundTransparency = 0.08
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = v6.Ink
		uiStroke.Thickness = v and 2 or 3
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = parent
		reg[#reg + 1] = { parent, "BackgroundTransparency", 0.08 }
		reg[#reg + 1] = { uiStroke, "Transparency", 0 }
		local parent2 = sub("Frame", 2, parent) -- inferred equivalent call
		parent2.BackgroundTransparency = 1
		parent2.Position = UDim2.fromOffset(3, 3)
		parent2.Size = UDim2.new(1, -6, 1, -6)
		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.Color = v6.Edge
		uiStroke2.Thickness = 1.5
		uiStroke2.Transparency = 0.6
		uiStroke2.Parent = parent2
		reg[#reg + 1] = { uiStroke2, "Transparency", 0.6 }

		for i = 1, 4 do
			local parent3 = sub("Frame", 2, parent) -- inferred equivalent call
			parent3.Size = UDim2.fromOffset(rnd(30, 90), rnd(14, 34)) -- inferred equivalent call
			parent3.Position = UDim2.fromScale(rnd(0.05, 0.85), rnd(0.05, 0.8)) -- inferred equivalent call
			parent3.BackgroundColor3 = i % 3 == 0 and v6.Rust or v6.Ink
			parent3.BackgroundTransparency = 0.8 + math.random() * 0.08
			corner(parent3, 12) -- inferred equivalent call
			local v17 = { parent3, "BackgroundTransparency", parent3.BackgroundTransparency }
			reg[#reg + 1] = v17
		end

		for _ = 1, 4 do
			local frame2 = sub("Frame", 2, parent) -- inferred equivalent call
			frame2.Size = UDim2.fromOffset(rnd(40, 110), 1) -- inferred equivalent call
			frame2.Position = UDim2.fromScale(math.random(), math.random())
			frame2.Rotation = rnd(-50, 50) -- inferred equivalent call
			frame2.BackgroundColor3 = v6.Bone
			frame2.BackgroundTransparency = 0.9 + math.random() * 0.05
			local v17 = { frame2, "BackgroundTransparency", frame2.BackgroundTransparency }
			reg[#reg + 1] = v17
		end

		for _ = 1, 14 do
			local v17 = math.random() > 0.35
			local v18 = math.random(1, 3)
			local frame2 = sub("Frame", 2, parent) -- inferred equivalent call
			frame2.Size = UDim2.fromOffset(v18, v18)
			frame2.Position = UDim2.fromScale(math.random(), math.random())
			frame2.BackgroundColor3 = v17 and v6.Bone or v6.Ink
			frame2.BackgroundTransparency = v17 and 0.78 + math.random() * 0.12 or 0.45 + math.random() * 0.25
			local v19 = { frame2, "BackgroundTransparency", frame2.BackgroundTransparency }
			reg[#reg + 1] = v19
		end
	end

	local strips = {}

	local function addStrip(p, p2, p3, p4, sw, palette)
		local v17 = p3 - p
		local v18 = p4 - p2
		local v19 = math.sqrt(v17 * v17 + v18 * v18)
		local rot = math.deg((math.atan2(v18, v17))) + rnd(-2.5, 2.5) -- inferred equivalent call
		local v20 = v19 + sw * 0.55 + rnd(-1.5, 3) -- inferred equivalent call
		local cx = (p + p3) / 2 + rnd(-1.2, 1.2) -- inferred equivalent call
		local cy = (p2 + p4) / 2 + rnd(-1.2, 1.2) -- inferred equivalent call
		local lerped = palette[math.random(1, #palette)]:Lerp(v6.Ink, rnd(0, 0.12)) -- inferred equivalent call
		local v21 = sub("Frame", 3) -- inferred equivalent call
		v21.AnchorPoint = Vector2.new(0.5, 0.5)
		v21.Size = UDim2.fromOffset(v20, sw)
		v21.BackgroundColor3 = v6.Ink
		v21.BackgroundTransparency = 0.55
		v21.Visible = false
		local uiScale2 = Instance.new("UIScale")
		uiScale2.Scale = 0.01
		uiScale2.Parent = v21
		local v22 = sub("Frame", 5) -- inferred equivalent call
		v22.AnchorPoint = Vector2.new(0.5, 0.5)
		v22.Size = UDim2.fromOffset(v20, sw)
		v22.BackgroundColor3 = lerped
		v22.BackgroundTransparency = 0.03
		v22.Visible = false
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = v6.Ink
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.45
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = v22
		local uiScale3 = Instance.new("UIScale")
		uiScale3.Scale = 0.01
		uiScale3.Parent = v22

		local reg2 = {
			{ v22, "BackgroundTransparency", 0.03 },
			{ uiStroke, "Transparency", 0.45 },
			{ v21, "BackgroundTransparency", 0.55 }
		}

		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.AnchorPoint = Vector2.new(0.5, 0)
		frame2.Position = UDim2.new(0.5, 0, 0, (math.max(1, sw * 0.18)))
		frame2.Size = UDim2.new(1, -8, 0, 1)
		frame2.BackgroundColor3 = color
		frame2.BackgroundTransparency = 0.8
		frame2.ZIndex = 6
		frame2.Parent = v22
		reg2[#reg2 + 1] = { frame2, "BackgroundTransparency", 0.8 }

		for i = 1, 2 do
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.AnchorPoint = Vector2.new(0.5, 0.5)
			frame3.Position = UDim2.fromScale(rnd(0.15, 0.85), 0.5) -- inferred equivalent call
			frame3.Size = UDim2.fromOffset(1, sw * rnd(0.8, 1.15)) -- inferred equivalent call
			frame3.Rotation = rnd(-35, 35) -- inferred equivalent call
			frame3.BackgroundColor3 = i == 1 and v6.Ink or v6.Bone
			local backgroundTransparency = i == 1 and 0.72 or 0.85
			frame3.BackgroundTransparency = backgroundTransparency
			frame3.ZIndex = 6
			frame3.Parent = v22
			reg2[#reg2 + 1] = { frame3, "BackgroundTransparency", backgroundTransparency }
		end

		for _, v23 in ipairs({ 0, 1 }) do
			local frame3 = Instance.new("Frame")
			frame3.BorderSizePixel = 0
			frame3.AnchorPoint = Vector2.new(0.5, 0.5)
			frame3.Size = UDim2.fromOffset(rnd(2, 3.5), rnd(2, 3.5)) -- inferred equivalent call
			frame3.Position = UDim2.fromScale(v23, rnd(0.12, 0.88)) -- inferred equivalent call
			frame3.Rotation = 45
			frame3.BackgroundColor3 = v6.Plate
			frame3.ZIndex = 7
			frame3.Parent = v22
			reg2[#reg2 + 1] = { frame3, "BackgroundTransparency", 0 }
		end

		local v23 = rnd(0, 6.2832) -- inferred equivalent call
		strips[#strips + 1] = {
			Piece = v22,
			PScale = uiScale3,
			Shadow = v21,
			SScale = uiScale2,
			Reg = reg2,
			CX = cx,
			CY = cy,
			Rot = rot,
			EntX = math.cos(v23),
			EntY = math.sin(v23),
			EntRot = (math.random() < 0.5 and -1 or 1) * rnd(12, 26), -- inferred equivalent call
			Delay = 0,
			Full = false
		}
	end

	local v17 = -(v11 + v13 + v12) / 2

	for _, v18 in ipairs(v10) do
		local v19 = -v18.width / 2
		local v20 = v17 + (v18.th - v18.gh) / 2

		for i = 1, #v18.text do
			local v21 = v18.text:sub(i, i)

			if v21 == " " then
				v19 += v18.gw * 0.7
			else
				local v22 = v9[v21] or 1
				local v23 = v18.gw * v22
				local v24 = v19 + v18.sw / 2
				local v25 = rnd(-2, 2) -- inferred equivalent call
				local v26 = math.rad(rnd(-3, 3)) -- inferred equivalent call
				local v27 = math.cos(v26)
				local v28 = math.sin(v26)
				local v29 = v24 + v23 / 2
				local v30 = v20 + v25 + v18.gh / 2
				local v31 = v8[v21] or v8.I

				for _, v32 in ipairs(v31) do
					local v42 = v24 + v32[1] * v23 - v29
					local v43 = v20 + v25 + v18.sw / 2 + v32[2] * (v18.gh - v18.sw) - v30
					local v44 = v24 + v32[3] * v23 - v29
					local v45 = v20 + v25 + v18.sw / 2 + v32[4] * (v18.gh - v18.sw) - v30
					addStrip(
						v29 + v42 * v27 - v43 * v28,
						v30 + v42 * v28 + v43 * v27,
						v29 + v44 * v27 - v45 * v28,
						v30 + v44 * v28 + v45 * v27,
						v18.sw,
						v18.palette
					)
				end

				v19 += v23 + v18.sw + v18.gap
			end
		end

		v17 += v18.th + 2
	end

	local v18 = math.min(0.014, 0.5 / math.max(1, #strips))

	for i, v19 in ipairs(strips) do
		v19.Delay = (i - 1) * v18
	end

	local delay = strips[#strips] and strips[#strips].Delay or 0
	local frame2

	if not self.Plain then
		local v19 = #bandBonus.Caption * (v and 6.4 or 8.4) + 20
		local parent = sub("Frame", 9) -- inferred equivalent call
		parent.AnchorPoint = Vector2.new(0, 0.5)
		parent.Position = UDim2.new(0, 10, 0, -3)
		parent.Size = UDim2.fromOffset(v19, v and 15 or 19)
		parent.Rotation = -3
		parent.BackgroundColor3 = v6.Tape
		parent.BackgroundTransparency = 0.06
		reg[#reg + 1] = { parent, "BackgroundTransparency", 0.06 }

		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Font = SpecialElite
		textLabel.TextSize = v and 11 or 13
		textLabel.TextColor3 = v6.TypeInk
		textLabel.Text = bandBonus.Caption
		textLabel.ZIndex = 10
		textLabel.Parent = parent
		reg[#reg + 1] = { textLabel, "TextTransparency", 0 }

		local function tape(position, size, rotation, backgroundColor, backgroundTransparency) -- 3 equivalent calls inferred from this helper
			local frame3 = sub("Frame", 9) -- inferred equivalent call
			frame3.AnchorPoint = Vector2.new(0.5, 0.5)
			frame3.Position = position
			frame3.Size = size
			frame3.Rotation = rotation
			frame3.BackgroundColor3 = backgroundColor
			frame3.BackgroundTransparency = backgroundTransparency
			register(frame3, "BackgroundTransparency", backgroundTransparency) -- inferred equivalent call
		end
		tape(UDim2.new(1, -4, 0, 4), UDim2.fromOffset(46, 12), 38, v6.TapeDark, 0.15) -- inferred equivalent call
		tape(UDim2.new(0, 2, 1, -3), UDim2.fromOffset(50, 12), 36, v6.TapeDark, 0.15) -- inferred equivalent call
		tape(UDim2.new(1, -26, 1, -3), UDim2.fromOffset(44, 11), -40, v6.Tape, 0.18) -- inferred equivalent call
		frame2 = Instance.new("Frame")

		if frame2:IsA("GuiObject") then
			frame2.BorderSizePixel = 0
			frame2.ZIndex = 11
		end

		frame2.Parent = v16

		frame2.Size = UDim2.fromScale(1, 1)
		frame2.BackgroundColor3 = color
		frame2.BackgroundTransparency = 1
	end

	local v19 = kind == "StarPowerPrompt" and 600 or bandBonus.Hold
	local chargeState, fn

	if v12 > 0 then
		local inputKind = note.InputKind or detectInputKind()
		local v20 = v15 / 2 + (v11 + v13) / 2
		local v21 = {}
		local function hr(p, p2, backgroundTransparency) -- 4 equivalent calls inferred from this helper
			v21[#v21 + 1] = { p, p2, backgroundTransparency }
		end
		local function inkStroke(parent, thickness) -- 2 equivalent calls inferred from this helper
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = v6.Ink
			uiStroke.Thickness = thickness
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Parent = parent
			hr(uiStroke, "Transparency", 0) -- inferred equivalent call
			return uiStroke
		end

		local function ringStrokeOf(parent) -- 2 equivalent calls inferred from this helper
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = bandBonus.Hot
			uiStroke.Thickness = 2
			uiStroke.Transparency = 1
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Parent = parent
			return uiStroke
		end

		local function solid(p, zIndex, backgroundColor, backgroundTransparency) -- 7 equivalent calls inferred from this helper
			local frame3 = sub("Frame", zIndex, p) -- inferred equivalent call
			frame3.BackgroundColor3 = backgroundColor
			frame3.BackgroundTransparency = backgroundTransparency
			hr(frame3, "BackgroundTransparency", backgroundTransparency) -- inferred equivalent call
			return frame3
		end

		local function typed(parent, zIndex, text, textSize, textColor, p)
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.fromScale(1, 1)
			textLabel.Font = SpecialElite
			textLabel.TextSize = textSize
			textLabel.TextColor3 = textColor
			textLabel.Text = text
			textLabel.TextXAlignment = p or Enum.TextXAlignment.Center
			textLabel.ZIndex = zIndex
			textLabel.Parent = parent
			hr(textLabel, "TextTransparency", 0) -- inferred equivalent call
			return textLabel
		end

		local v22 = v and 22 or 30
		local v23 = delay + 0.12
		local parent = sub("Frame", 8) -- inferred equivalent call
		parent.AnchorPoint = Vector2.new(0.5, 0.5)
		parent.Position = UDim2.fromOffset(v14 / 2, v20)
		parent.BackgroundTransparency = 1

		local function phaseOf(p) -- 2 equivalent calls inferred from this helper
			local v24 = (p - v23) % 1.3 / 1.3
			local v25 = 0

			if v24 >= 0.5 and v24 < 0.6 then
				v25 = (v24 - 0.5) / 0.1
			elseif v24 >= 0.6 and v24 < 0.8 then
				v25 = 1 - (v24 - 0.6) / 0.2
			end

			return v25, (v24 - 0.5) / 0.4
		end

		local fn2

		if inputKind == "Touch" then
			local v24 = v and 20 or 26
			local v25 = 7 * (v and 8 or 10.5)
			local v26 = v12 / 2
			parent.Size = UDim2.fromOffset(v24 + 10 + v25, v12)
			local parent2 = sub("Frame", 8, parent) -- inferred equivalent call
			parent2.AnchorPoint = Vector2.new(0.5, 0.5)
			parent2.Position = UDim2.fromOffset(v24 / 2, v26)
			parent2.Size = UDim2.fromOffset(v24, v24)
			parent2.BackgroundTransparency = 1
			corner(parent2, 100) -- inferred equivalent call
			local uiStroke = ringStrokeOf(parent2) -- inferred equivalent call
			local parent3 = solid(parent, 9, v6.Bone, 0.02) -- inferred equivalent call
			parent3.AnchorPoint = Vector2.new(0.5, 0.5)
			parent3.Position = UDim2.fromOffset(v24 / 2, v26)
			parent3.Size = UDim2.fromOffset(v24, v24)
			corner(parent3, 100) -- inferred equivalent call
			inkStroke(parent3, 1.5) -- inferred equivalent call
			local parent4 = solid(parent3, 10, bandBonus.Accent, 0.1) -- inferred equivalent call
			parent4.AnchorPoint = Vector2.new(0.5, 0.5)
			parent4.Position = UDim2.fromScale(0.5, 0.5)
			parent4.Size = UDim2.fromScale(0.34, 0.34)
			corner(parent4, 100) -- inferred equivalent call
			local v27 = typed(parent, 9, "TAP BAR", v and 13 or 17, v6.Bone, Enum.TextXAlignment.Left)
			v27.Position = UDim2.fromOffset(v24 + 10, 0)
			v27.Size = UDim2.fromOffset(v25, v12)

			fn2 = function(p, p2)
				local v28 = p2 * clamp01((p - v23) / 0.25) -- inferred equivalent call
				applyList(v21, v28)
				local v29, v30 = phaseOf(p) -- inferred equivalent call
				local v31 = v24 * (1 - 0.22 * v29)
				parent3.Size = UDim2.fromOffset(v31, v31)
				parent3.Position = UDim2.fromOffset(v24 / 2, v26 + 2 * v29)

				if not (v30 > 0 and v30 < 1) then
					uiStroke.Transparency = 1

					return
				end

				local v32 = v24 + 26 * v30
				parent2.Size = UDim2.fromOffset(v32, v32)
				uiStroke.Transparency = 1 - (1 - v30) * 0.85 * v28
			end
		else
			local v24 = inputKind == "Gamepad"
			local hintLabel = getHintLabel(inputKind) -- inferred equivalent call
			local v25 = v24 and 100 or 6
			local v26 = math.max(v22 * 1.6, #hintLabel * (v and 9 or 12) + 24)
			parent.Size = UDim2.fromOffset(v26 + 40, v12)
			local parent2 = sub("Frame", 8, parent) -- inferred equivalent call
			parent2.AnchorPoint = Vector2.new(0.5, 0.5)
			parent2.Position = UDim2.fromScale(0.5, 0.5)
			parent2.Size = UDim2.fromOffset(v26, v22)
			parent2.BackgroundTransparency = 1
			corner(parent2, v25 + 6) -- inferred equivalent call
			local uiStroke = ringStrokeOf(parent2) -- inferred equivalent call
			local parent3 = solid(parent, 8, v6.Ink, 0) -- inferred equivalent call
			parent3.AnchorPoint = Vector2.new(0.5, 0.5)
			parent3.Position = UDim2.new(0.5, 0, 0.5, 3)
			parent3.Size = UDim2.fromOffset(v26, v22)
			corner(parent3, v25) -- inferred equivalent call
			local parent4 = solid(parent, 9, v6.Tape, 0.02) -- inferred equivalent call
			parent4.AnchorPoint = Vector2.new(0.5, 0.5)
			parent4.Position = UDim2.new(0.5, 0, 0.5, -1)
			parent4.Size = UDim2.fromOffset(v26, v22)
			corner(parent4, v25) -- inferred equivalent call
			inkStroke(parent4, 1.5) -- inferred equivalent call
			typed(parent4, 10, hintLabel, v and 13 or 17, v6.TypeInk)

			fn2 = function(p, p2)
				local v27 = p2 * clamp01((p - v23) / 0.25) -- inferred equivalent call
				applyList(v21, v27)
				local v28, v29 = phaseOf(p) -- inferred equivalent call
				parent4.Position = UDim2.new(0.5, 0, 0.5, -1 + 3 * v28)
				parent4.BackgroundColor3 = v6.Tape:Lerp(bandBonus.Hot, v28 * 0.75)

				if v29 > 0 and v29 < 1 then
					parent2.Size = UDim2.fromOffset(v26 + 30 * v29, v22 + 22 * v29)
					uiStroke.Transparency = 1 - (1 - v29) * 0.85 * v27
				else
					uiStroke.Transparency = 1
				end
			end
		end

		chargeState = {
			Target = clamp01(self.PromptChargeLatest or 0), -- inferred equivalent call
			Shown = clamp01(self.PromptChargeLatest or 0), -- inferred equivalent call
			Auto = self.PromptAutoLatest ~= false
		}

		local v24 = math.min(v14 - 70, v and 150 or 250)

		local v25 = v15 / 2 + (v11 - v12) / 2
		local parent2 = solid(nil, 8, v6.Ink, 0.05) -- inferred equivalent call
		parent2.AnchorPoint = Vector2.new(0.5, 0.5)
		parent2.Position = UDim2.fromOffset(v14 / 2, v25)
		parent2.Size = UDim2.fromOffset(v24, v and 8 or 11)
		corner(parent2, 3) -- inferred equivalent call
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = v6.Edge
		uiStroke.Thickness = 1.2
		uiStroke.Parent = parent2
		hr(uiStroke, "Transparency", 0) -- inferred equivalent call
		local parent3 = solid(parent2, 9, bandBonus.Accent, 0) -- inferred equivalent call
		parent3.AnchorPoint = Vector2.new(0, 0.5)
		parent3.Position = UDim2.new(0, 0, 0.5, 0)
		parent3.Size = UDim2.fromScale(0, 1)
		corner(parent3, 3) -- inferred equivalent call
		local v26 = chargeState

		for i = 1, 9 do
			local v27 = solid(parent2, 10, v6.Ink, 0.2) -- inferred equivalent call
			v27.Position = UDim2.fromScale(i / 10, 0)
			v27.Size = UDim2.new(0, 1, 1, 0)
		end

		local v27 = os.clock()

		fn = function(p, p2)
			fn2(p, p2)
			local now = os.clock()
			local v28 = math.min(now - v27, 0.1)
			v27 = now
			local v29 = v26.Target - v26.Shown
			v26.Shown = clamp01(v26.Shown + v29 * math.min(1, v28 * (v29 > 0 and 7 or 11))) -- inferred equivalent call
			local shown = v26.Shown
			parent3.Size = UDim2.fromScale(shown, 1)
			local v30 = clamp01((shown - 0.6) / 0.4) -- inferred equivalent call
			parent3.BackgroundColor3 = bandBonus.Accent:Lerp(bandBonus.Hot, clamp01(shown * 1.4)):Lerp( -- inferred equivalent call
				color,
				v30 * (math.sin(p * (10 + 18 * v30)) * 0.35 + 0.35)
			)
		end

		fn(0, 0)
	end

	local current = {
		Note = note,
		HintFn = fn,
		ChargeState = chargeState,
		Theme = bandBonus,
		Tier = tier,
		IsSP = isSP,
		Age = 0,
		Hold = v19 * self.HoldMul + delay,
		Total = v19 * self.HoldMul + delay + 0.35,
		W = v14,
		H = v15,
		Holder = v16,
		Scale = uiScale,
		Wipe = frame,
		Flash = frame2,
		Strips = strips,
		Reg = reg,
		Impacted = false,
		ImpactAt = 0.1,
		FinalAt = delay + 0.12,
		FinalDone = false,
		FlashAt = 0.1,
		Micro = 0,
		AmbBolt = bandBonus.Crackle * rnd(0.6, 1.2), -- inferred equivalent call
		AmbSpark = 0,
		AmbEmber = 0
	}

	self.Current = current
	self:_applyAlpha(current, 0)
	self:_ensureDriver()
end

function StreakNoticeFx:_applyAlpha(p, p2)
	applyList(p.Reg, p2)
end

function StreakNoticeFx:_impact(state, p)
	local theme = state.Theme
	local w = state.W
	local h = state.H
	state.Micro = 1
	state.FlashAt = state.Age

	if not state.Note.Sparkle then
		return
	end

	local v10 = (p and 1 or 0.55) * (self.Plain and 0.6 or 1)

	self:_grit(w, h, math.max(5, (math.floor(12 * v4 + 0.5))), 0.35)

	for i = 1, math.max(4, (math.floor(theme.Sparks * v4 * v10 + 0.5))) do
		local v11 = v and 2 or 3

		if i % 2 == 0 then
			local v12, v13, v14 = perimeter(w, h)
			self:_spark(theme, v12, v13, v14 + rnd(-0.6, 0.6), rnd(300, 900) * v5, rnd(0.3, 0.75), v11, i % 4 == 0) -- inferred equivalent call
		else
			self:_spark(
				theme,
				rnd(-w * 0.3, w * 0.3), -- inferred equivalent call
				rnd(-h * 0.2, h * 0.2), -- inferred equivalent call
				rnd(0, 6.2832), -- inferred equivalent call
				rnd(260, 760) * v5, -- inferred equivalent call
				rnd(0.3, 0.7), -- inferred equivalent call
				v11,
				i % 5 == 0
			)
		end
	end

	for _ = 1, math.max(2, (math.floor(theme.Bolts * (v and 0.6 or 1) * v10 + 0.5))) do
		local v11, v12, v13 = perimeter(w, h)
		self:_bolt(theme, v11, v12, v13 + rnd(-0.5, 0.5), rnd(110, 230) * v5, rnd(0.28, 0.42), 9, true) -- inferred equivalent call
	end

	for _ = 1, math.max(3, (math.floor(theme.Embers * v4 * v10 + 0.5))) do
		self:_ember(theme, rnd(-w * 0.45, w * 0.45), rnd(-h * 0.2, h * 0.5)) -- inferred equivalent call
	end
end

function StreakNoticeFx:_step(p)
	local current = self.Current

	if current then
		current.Age += p
		local age = current.Age
		local theme = current.Theme

		if not current.Impacted and current.ImpactAt <= age then
			current.Impacted = true
			self:_impact(current, true)
		end

		if not current.FinalDone and current.FinalAt <= age then
			current.FinalDone = true
			self:_impact(current, false)
		end

		local total = 0
		local v10 = 0

		if current.Micro > 0 then
			total += rnd(-3, 3) * current.Micro * v5 -- inferred equivalent call
			v10 += rnd(-3, 3) * current.Micro * v5 -- inferred equivalent call
			current.Micro = math.max(0, current.Micro - p * 9)
		end

		local total2 = -2
		local scale = 1

		if current.FinalAt < age then
			total2 += math.sin(age * 6) * 0.8
			scale *= math.sin(age * 8) * 0.01 + 1

			local chargeState = current.ChargeState

			if chargeState then
				local v11 = chargeState.Shown * chargeState.Shown
				local v12 = (0.25 + 5.5 * v11) * v5
				total += rnd(-1, 1) * v12 -- inferred equivalent call
				v10 += rnd(-1, 1) * v12 * 0.8 -- inferred equivalent call

				total2 += rnd(-1, 1) * (0.15 + 2 * v11) -- inferred equivalent call
				scale *= 1 + 0.025 * v11 * math.sin(age * 38)
			end
		end

		local v11

		if current.Hold < age then
			local v12 = clamp01((age - current.Hold) / 0.35) -- inferred equivalent call
			local v13 = 1 - (1 - v12) * (1 - v12)
			scale *= 1 + 0.10000000000000009 * v13

			v10 -= 20 * v5 * v13
			total2 += 3 * v13
			v11 = 1 - v12
		else
			v11 = 1
		end

		current.Scale.Scale = scale
		current.Holder.Rotation = total2
		current.Holder.Position = UDim2.fromOffset(total, v10)

		local v12 = clamp01(age / 0.2) -- inferred equivalent call

		if current.Wipe then
			current.Wipe.Size = UDim2.fromOffset(current.W * (1 - (1 - v12) ^ 3), current.H)
		end

		self:_applyAlpha(current, v11 * clamp01(age / 0.05)) -- inferred equivalent call

		if current.HintFn then
			current.HintFn(age, v11)
		end

		for _, strip in ipairs(current.Strips) do
			local v13 = age - strip.Delay

			if v13 < 0 then
				strip.Piece.Visible = false
				strip.Shadow.Visible = false
			else
				strip.Piece.Visible = true
				strip.Shadow.Visible = true
				local scale2 = math.max(0.01, 1 - math.exp(-9 * v13) * math.cos(20 * v13))
				local v14 = -26 * v5 * math.exp(-8 * v13) * math.cos(18 * v13)
				local v15 = strip.EntX * v14
				local v16 = strip.EntY * v14
				local rotation = strip.Rot + strip.EntRot * math.exp(-7 * v13) * math.cos(15 * v13)
				local v17, v18

				if current.Micro > 0 then
					v17 = rnd(-1.2, 1.2) * current.Micro -- inferred equivalent call
					v18 = rnd(-1.2, 1.2) * current.Micro -- inferred equivalent call
				else
					v17 = 0
					v18 = 0
				end

				strip.PScale.Scale = scale2
				strip.SScale.Scale = scale2
				strip.Piece.Rotation = rotation
				strip.Shadow.Rotation = rotation
				strip.Piece.Position = UDim2.new(0.5, strip.CX + v15 + v17, 0.5, strip.CY + v16 + v18)
				strip.Shadow.Position = UDim2.new(0.5, strip.CX + v15 + v17 + 1.5, 0.5, strip.CY + v16 + v18 + 2.5)
				local v19 = v11 * clamp01(v13 / 0.05) -- inferred equivalent call

				if v19 < 0.999 then
					applyList(strip.Reg, v19)
					strip.Full = false
				elseif not strip.Full then
					applyList(strip.Reg, 1)
					strip.Full = true
				end
			end
		end

		if current.Flash then
			current.Flash.BackgroundTransparency = 1 - math.exp(math.max(0, age - current.FlashAt) * -13) * 0.5 * v11 * (current.Impacted and 1 or 0)
		end

		if current.Note.Sparkle and current.FinalDone and age < current.Hold and not current.Shattered then
			local w = current.W
			local h = current.H
			current.AmbBolt -= p

			if current.AmbBolt <= 0 then
				current.AmbBolt = theme.Crackle * rnd(0.8, 1.4) * (1 - 0.65 * (current.ChargeState and current.ChargeState.Shown or 0)) -- inferred equivalent call
				current.Micro = 1
				local v13, v14, v15 = perimeter(w, h)
				self:_bolt(theme, v13, v14, v15 + rnd(-0.6, 0.6), rnd(70, 150) * v5, rnd(0.16, 0.26), 7, false) -- inferred equivalent call
			end

			current.AmbSpark += p * ((current.Tier >= 2 or current.IsSP) and 9 or 5) * v4 * (1 + 2.5 * (current.ChargeState and current.ChargeState.Shown or 0))

			while current.AmbSpark >= 1 do
				current.AmbSpark -= 1
				local v13, v14, v15 = perimeter(w, h)
				self:_spark(
					theme,
					v13,
					v14,
					v15 + rnd(-0.7, 0.7), -- inferred equivalent call
					rnd(200, 520) * v5, -- inferred equivalent call
					rnd(0.25, 0.5), -- inferred equivalent call
					v and 2 or 3,
					false
				)
			end

			current.AmbEmber += p * (6 + current.Tier * 2) * v4

			while current.AmbEmber >= 1 do
				current.AmbEmber -= 1
				self:_ember(theme, rnd(-w * 0.45, w * 0.45), h * 0.45) -- inferred equivalent call
			end
		end

		if current.Total <= age then
			self:_endCurrent(true)
		end
	end

	local parts = self.Parts
	local v10 = 1

	while v10 <= #parts do
		if parts[v10](p) then
			v10 += 1
		else
			table.remove(parts, v10)
		end
	end

	if not self.Current and #self.Parts == 0 and self.Conn then
		self.Conn:Disconnect()
		self.Conn = nil
	end
end

return StreakNoticeFx