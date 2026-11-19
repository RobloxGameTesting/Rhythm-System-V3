local StyledTheme = require(script.Parent.StyledTheme)
local InstrumentIcons = require(script.Parent.InstrumentIcons)
local UserInputService = game:GetService("UserInputService")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and 17 or 20

local v2 = { GuitarRhythm = true, GuitarLead = true, Bass = true }

local Order = InstrumentIcons.Order

local function visibleKeys(p, list)
	local result = {}

	for _, item in ipairs(list) do
		if p[item] and InstrumentIcons.Get(item) then
			table.insert(result, item)
		end
	end

	return result
end

local function gapBetween(p, item): number -- 1 equivalent call inferred from this helper
	return if v2[p] and v2[item] then -4 else 2
end

local function layoutKeys(list)
	local result = {}
	local total = 0

	for i, item in ipairs(list) do
		if i > 1 then
			total += gapBetween(list[i - 1], item) -- inferred equivalent call
		end

		result[item] = total
		total += InstrumentIcons.GetSize(item, v).X
	end

	return result, (math.max(total, 0))
end

local InstrumentIndicator = {}

function InstrumentIndicator.GetWidth(options, p)
	local v3 = visibleKeys(options or {}, p or Order)

	if #v3 == 0 then
		return 0
	end

	local _, v4 = layoutKeys(v3)
	return v4
end

local function render(parent, p, p2, p3)
	local v3 = visibleKeys(p, p2)
	local v4, v5 = layoutKeys(v3)
	local set = {}

	for i, childName in ipairs(v3) do
		local v6 = parent:FindFirstChild(childName)

		if not v6 then
			v6 = Instance.new("ImageLabel")
			v6.Name = childName
			v6.BackgroundTransparency = 1
			v6.BorderSizePixel = 0
			v6.AnchorPoint = Vector2.new(0, 0.5)
			v6.ScaleType = Enum.ScaleType.Crop
			v6.Image = InstrumentIcons.Get(childName)
			v6.Parent = parent
		end

		local size = InstrumentIcons.GetSize(childName, v)
		v6.Size = UDim2.fromOffset(size.X, size.Y)
		v6.Position = UDim2.new(0, v4[childName], 0.5, 0)
		v6.ZIndex = i

		v6.ImageColor3 = InstrumentIcons.GetStateColor(p3 and p3[childName])
		v6.Visible = true
		set[v6] = true
	end

	for _, image in ipairs(parent:GetChildren()) do
		if not image:IsA("ImageLabel") or set[image] then
			continue
		end

		image.Visible = false
	end

	parent.Size = UDim2.new(0, v5, 0, StyledTheme.Sizes.ControlHeightS)
end

function InstrumentIndicator.Create(parent, options, value, p, p2)
	local instrumentIndicator = Instance.new("Frame")
	instrumentIndicator.Name = "InstrumentIndicator"
	instrumentIndicator.BackgroundTransparency = 1
	instrumentIndicator.BorderSizePixel = 0
	instrumentIndicator.Size = UDim2.new(0, 0, 0, StyledTheme.Sizes.ControlHeightS)
	instrumentIndicator.LayoutOrder = value or 0
	instrumentIndicator.Parent = parent
	render(instrumentIndicator, options or {}, p or Order, p2)
	return instrumentIndicator
end

function InstrumentIndicator.Update(parent, options, p, p2)
	if not parent then
		return
	end

	render(parent, options or {}, p or Order, p2)
end

return InstrumentIndicator