local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local v = {
	Perfect = Color3.fromRGB(150, 190, 120),
	Great = Color3.fromRGB(100, 145, 170),
	Good = Color3.fromRGB(190, 165, 80),
	OK = Color3.fromRGB(175, 115, 60),
	Miss = Color3.fromRGB(150, 45, 40),
	Wrong = Color3.fromRGB(125, 60, 125)
}

local color = Color3.fromRGB(210, 200, 180)

local floatingJudgmentPool = nil
local v2 = {}
local entries = {}

local function createEntry()
	local floatingJudgment = Instance.new("BillboardGui")
	floatingJudgment.Name = "FloatingJudgment"
	floatingJudgment.Size = UDim2.new(0, 120, 0, 36)
	floatingJudgment.AlwaysOnTop = true
	floatingJudgment.Enabled = false
	floatingJudgment.Adornee = nil
	floatingJudgment.Parent = floatingJudgmentPool

	local judgmentLabel = Instance.new("TextLabel")
	judgmentLabel.Name = "JudgmentLabel"
	judgmentLabel.Size = UDim2.new(1, 0, 1, 0)
	judgmentLabel.BackgroundTransparency = 1
	judgmentLabel.Font = Enum.Font.GothamBlack
	judgmentLabel.TextSize = 20
	judgmentLabel.TextColor3 = color
	judgmentLabel.TextStrokeTransparency = 0.2
	judgmentLabel.TextStrokeColor3 = Color3.fromRGB(10, 9, 8)
	judgmentLabel.Text = ""
	judgmentLabel.Parent = floatingJudgment

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = judgmentLabel

	local entry = { Billboard = floatingJudgment, Label = judgmentLabel, Scale = uiScale }
	table.insert(entries, entry)
	return entry
end

local function ensurePool()
	if floatingJudgmentPool then
		return
	end

	floatingJudgmentPool = Instance.new("Folder")
	floatingJudgmentPool.Name = "FloatingJudgmentPool"
	floatingJudgmentPool.Parent = Workspace

	for _ = 1, 15 do
		table.insert(v2, createEntry())
	end
end

local function acquireEntry() -- 1 equivalent call inferred from this helper
	ensurePool()

	return table.remove(v2) or createEntry()
end

local function releaseEntry(p) -- 1 equivalent call inferred from this helper
	p.Billboard.Enabled = false
	p.Billboard.Adornee = nil
	table.insert(v2, p)
end

return {
	Spawn = function(instance, p, p2, p3)
		if not instance then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("Head")

		if not humanoidRootPart then
			return
		end

		local entry = acquireEntry() -- inferred equivalent call
		local billboard = entry.Billboard
		local label = entry.Label
		local scale = entry.Scale

		local vector3 = Vector3.new((math.random() * 2 - 1) * 1.2, 2.5, 0)
		local studsOffset = vector3 + Vector3.new(0, 1.4, 0)

		billboard.Adornee = humanoidRootPart
		billboard.StudsOffset = vector3
		billboard.Enabled = true

		label.Text = string.upper(p3 or p)
		label.TextColor3 = p2 or v[p] or color
		label.TextTransparency = 0
		label.TextStrokeTransparency = 0.2
		scale.Scale = 0.5

		TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1.25
		}):Play()

		task.delay(0.12, function()
			if billboard.Adornee ~= humanoidRootPart then
				return
			end

			TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
		end)

		TweenService:Create(billboard, TweenInfo.new(0.7, Enum.EasingStyle.Linear), {
			StudsOffset = studsOffset
		}):Play()

		TweenService:Create(
			label,
			TweenInfo.new(
				0.45499999999999996,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In,
				0,
				false,
				0.24499999999999997
			),
			{ TextTransparency = 1, TextStrokeTransparency = 1 }
		):Play()

		task.delay(0.75, function()
			releaseEntry(entry) -- inferred equivalent call
		end)
	end
}