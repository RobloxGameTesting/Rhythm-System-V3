local Players = game:GetService("Players")

local color = Color3.fromRGB(204, 162, 72)

local v = nil
local v2 = {}
local v3 = ""

local function rescan()
	v = {}
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	local function add(p, guiObject) -- 2 equivalent calls inferred from this helper
		v[p] = v[p] or {}
		table.insert(v[p], guiObject)
	end

	for _, guiObject in ipairs(playerGui:GetDescendants()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local tabsLane = guiObject:GetAttribute("TabsLane")

		if tabsLane then
			add(tabsLane, guiObject) -- inferred equivalent call
		end

		local tabsLanes = guiObject:GetAttribute("TabsLanes")

		if type(tabsLanes) ~= "string" then
			continue
		end

		for k in string.gmatch(tabsLanes, "%d+") do
			add(tonumber(k), guiObject) -- inferred equivalent call
		end
	end
end

local function stale(): boolean
	if not v then
		return true
	end

	for _, list in pairs(v) do
		for _, item in ipairs(list) do
			if not item.Parent then
				return true
			end
		end
	end

	return false
end

local function removeLane(k)
	local v4 = v2[k]

	if v4 then
		for _, v5 in ipairs(v4) do
			if v5.Parent then
				v5:Destroy()
			end
		end

		v2[k] = nil
	end
end

local function makeFrame(parent, item)
	local tabsGuide = Instance.new("Frame")
	tabsGuide.Name = "TabsGuide"
	tabsGuide.Active = false
	tabsGuide.BorderSizePixel = 0
	tabsGuide.BackgroundColor3 = color
	tabsGuide.BackgroundTransparency = item >= 2 and 0.5 or 0.8

	if parent:GetAttribute("TabsGuideSibling") and parent.Parent then
		tabsGuide.AnchorPoint = parent.AnchorPoint
		tabsGuide.Position = parent.Position
		tabsGuide.Size = parent.Size
		tabsGuide.ZIndex = 200
		tabsGuide.Parent = parent.Parent
	else
		tabsGuide.Size = UDim2.new(1, 0, 1, 0)
		tabsGuide.ZIndex = math.max(parent.ZIndex, 1) + 20
		tabsGuide.Parent = parent
	end

	local uiCorner = parent:FindFirstChildOfClass("UICorner")
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = uiCorner and uiCorner.CornerRadius
		or parent:GetAttribute("TabsGuideSibling") and UDim.new(0.5, 0)
		or UDim.new(0, 3)
	uiCorner2.Parent = tabsGuide
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = item >= 2 and 3 or 1.5
	uiStroke.Parent = tabsGuide
	return tabsGuide
end

local TabsKeyGuide = {}

function TabsKeyGuide.Set(items)
	local v4 = {}

	for k, item in pairs(items) do
		v4[#v4 + 1] = k .. ":" .. item
	end

	table.sort(v4)
	local joined = table.concat(v4, ",")

	if joined == v3 and v and not stale() then
		return
	end

	v3 = joined

	if stale() then
		for k in pairs(v2) do
			removeLane(k)
		end

		rescan()
	end

	for k in pairs(v2) do
		if not items[k] then
			removeLane(k)
		end
	end

	for k, item in pairs(items) do
		local v5 = v[k]

		if not v5 then
			continue
		end

		removeLane(k)
		v2[k] = {}

		for _, v6 in ipairs(v5) do
			if v6.Parent then
				table.insert(v2[k], makeFrame(v6, item))
			end
		end
	end
end

function TabsKeyGuide.Clear()
	for k in pairs(v2) do
		removeLane(k)
	end

	v3 = ""
end

return TabsKeyGuide