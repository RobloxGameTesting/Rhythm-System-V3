local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)

local Colors = Theme.Colors
local color = Color3.fromRGB(255, 252, 240)

local SegmentedSlider = {}
SegmentedSlider.__index = SegmentedSlider

local v = nil
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v = nil
	end
end)

function SegmentedSlider.new(parent, options)
	local v2 = options or {}
	local steps = math.max(2, v2.steps or 10)
	local gap = v2.gap or steps <= 12 and 2 or 1

	local segmentedSlider = Instance.new("Frame")
	segmentedSlider.Name = "SegmentedSlider"
	segmentedSlider.BackgroundTransparency = 1
	segmentedSlider.BorderSizePixel = 0
	segmentedSlider.Size = v2.size or UDim2.new(1, 0, 0, 16)
	segmentedSlider.Position = v2.position or UDim2.new(0, 0, 0, 0)
	segmentedSlider.AnchorPoint = v2.anchorPoint or Vector2.new(0, 0)
	segmentedSlider.Parent = parent

	local object = setmetatable({
		Instance = segmentedSlider,
		_steps = steps,
		_gap = gap,
		_cells = {},
		_fillFrom = v2.fillFrom,
		_onSelect = v2.onSelect,
		_index = nil
	}, SegmentedSlider)

	for i = 1, steps do
		local textButton = Instance.new("TextButton")
		textButton.Name = "Step" .. i
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Colors.SurfaceSelected
		textButton.AnchorPoint = Vector2.new(0, 0.5)
		textButton.Position = UDim2.new((i - 1) / steps, 0, 0.5, 0)
		textButton.Size = UDim2.new(1 / steps, -gap, 0.4, 0)
		textButton.Parent = segmentedSlider

		textButton.MouseButton1Down:Connect(function()
			v = object

			if object._onSelect then
				object._onSelect(i)
			end
		end)
		textButton.MouseEnter:Connect(function()
			if
				v == object
				and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
				and object._onSelect
			then
				object._onSelect(i)
			end
		end)
		object._cells[i] = textButton
	end

	return object
end

function SegmentedSlider:SetIndex(value)
	local v2 = math.clamp(math.floor(value or 1), 1, self._steps)
	self._index = v2
	local v3, v4

	if self._fillFrom then
		v3 = math.min(self._fillFrom, v2)
		v4 = math.max(self._fillFrom, v2)
	else
		v4 = v2
		v3 = 1
	end

	local v5 = 1 / self._steps

	for i, cell in ipairs(self._cells) do
		if i == v2 then
			cell.BackgroundColor3 = color
			cell.Size = UDim2.new(v5, -self._gap, 1, 0)
		elseif v3 <= i and i <= v4 then
			cell.BackgroundColor3 = Colors.Accent
			cell.Size = UDim2.new(v5, -self._gap, 0.6, 0)
		else
			cell.BackgroundColor3 = Colors.SurfaceSelected
			cell.Size = UDim2.new(v5, -self._gap, 0.4, 0)
		end
	end
end

function SegmentedSlider:GetIndex()
	return self._index
end

function SegmentedSlider.Throttle(callback, p)
	local nows = {}
	local v2 = {}
	local v3 = {}
	return function(p2, p3)
		local now = os.clock()
		local v4 = nows[p2] or 0

		if p <= now - v4 then
			nows[p2] = now
			v2[p2] = nil
			callback(p2, p3)
		else
			v2[p2] = p3

			if v3[p2] then
				return
			end

			v3[p2] = true
			task.delay(p - (now - v4), function()
				v3[p2] = false
				local v5 = v2[p2]
				v2[p2] = nil

				if v5 ~= nil then
					nows[p2] = os.clock()
					callback(p2, v5)
				end
			end)
		end
	end
end

return SegmentedSlider