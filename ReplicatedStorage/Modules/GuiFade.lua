local RunService = game:GetService("RunService")

local HudOpacity = require(script.Parent:WaitForChild("HudOpacity"))

local function nameMatches(name, p, list): boolean
	if p[name] then
		return true
	end

	for _, item in ipairs(list) do
		if name:sub(1, #item) == item then
			return true
		end
	end

	return false
end

local GuiFade = {}

function GuiFade.MakeClassifier(data)
	local decor = data.Decor or {}
	local decorPrefix = data.DecorPrefix or {}
	local decorSubtree = data.DecorSubtree or {}
	local decorSubtreePrefix = data.DecorSubtreePrefix or {}
	return function(p, p2)
		if p2 then
			p2 = p2.Parent
		end

		local v = p

		while v and v ~= p2 do
			if nameMatches(v.Name, decorSubtree, decorSubtreePrefix) then
				return true
			end

			v = v.Parent
		end

		return nameMatches(p.Name, decor, decorPrefix)
	end
end

local function set(list)
	local result = {}

	for _, item in ipairs(list) do
		result[item] = true
	end

	return result
end

local makeClassifier = GuiFade.MakeClassifier
local set2 = {}

local v = { Decor = 0, DecorSubtree = 0, DecorSubtreePrefix = 0 }
local v2 = {
	"DecorFront",
	"Rivet",
	"RustDrip",
	"Grime",
	"Scratch",
	"BoltSeg",
	"TapeA",
	"TapeB",
	"TapeTopRight",
	"TapeBottomLeft"
}

local presets = {
	RockMeter = 0,
	Score = 0,
	Vibrato = 0,
	StarPower = 0,
	BandScore = 0,
	TextContent = 0
}
local v3 = {}

for _, v4 in ipairs({
	"Container",
	"Plate",
	"Shadow",
	"Body",
	"LampSlot",
	"Gloss",
	"DialClip",
	"Bezel",
	"Face",
	"Glare",
	"Shelf",
	"Hub",
	"TitleLine",
	"Title",
	"RockText"
}) do
	set2[v4] = true
end

v.Decor = set2
local set3 = {}

for _, v4 in ipairs(v2) do
	set3[v4] = true
end

v.DecorSubtree = set3
v.DecorSubtreePrefix = { "NeedleShadow", "Hub" }
presets.RockMeter = makeClassifier(v)

local makeClassifier2 = GuiFade.MakeClassifier
local set4 = {}

local v4 = { Decor = 0, DecorSubtree = 0 }

for _, v5 in ipairs({
	"Container",
	"Plate",
	"Shadow",
	"Body",
	"Piping",
	"Lcd",
	"Cell",
	"Glass",
	"RingOuter",
	"RingPipe",
	"Face",
	"Glare",
	"LampSlot",
	"StreakBox"
}) do
	set4[v5] = true
end

v4.Decor = set4
local set5 = {}

for _, v5 in ipairs(v2) do
	set5[v5] = true
end

v4.DecorSubtree = set5
presets.Score = makeClassifier2(v4)

local makeClassifier3 = GuiFade.MakeClassifier
local set6 = {}

local v5 = { Decor = 0, DecorSubtree = 0 }

for _, v6 in ipairs({ "Container", "Panel", "Title", "TitleLine" }) do
	set6[v6] = true
end

v5.Decor = set6
local set7 = {}

for _, v6 in ipairs(v2) do
	set7[v6] = true
end

v5.DecorSubtree = set7
presets.Vibrato = makeClassifier3(v5)

local makeClassifier4 = GuiFade.MakeClassifier
local set8 = {}

local v6 = { Decor = 0, DecorSubtree = 0 }

for _, v7 in ipairs({
	"MeterContainer",
	"Well",
	"Sheen",
	"NeonL",
	"NeonR",
	"Scratch",
	"Crease",
	"Fray"
}) do
	set8[v7] = true
end

v6.Decor = set8
local set9 = {}

for _, v7 in ipairs(v2) do
	set9[v7] = true
end

v6.DecorSubtree = set9
presets.StarPower = makeClassifier4(v6)

local makeClassifier5 = GuiFade.MakeClassifier
local set10 = {}

local v7 = { Decor = 0, DecorSubtree = 0 }

for _, v8 in ipairs({ "Container", "Plate", "Shadow", "Body", "Title", "HeaderLine", "HeatBar" }) do
	set10[v8] = true
end

v7.Decor = set10
local set11 = {}

for _, v8 in ipairs(v2) do
	set11[v8] = true
end

v7.DecorSubtree = set11
presets.BandScore = makeClassifier5(v7)

function presets.TextContent(instance): boolean
	return not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox"))
end

GuiFade.Presets = presets

local function propsFor(instance)
	if instance:IsA("UIStroke") then
		return { "Transparency" }
	end

	if not instance:IsA("GuiObject") then
		return nil
	end

	local v8 = { "BackgroundTransparency" }

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		v8[#v8 + 1] = "TextTransparency"
		v8[#v8 + 1] = "TextStrokeTransparency"
	elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") or instance:IsA("ViewportFrame") then
		v8[#v8 + 1] = "ImageTransparency"
	end

	return v8
end

local function groupParentOf(data, instance)
	local root = data.Root
	local parent = instance.Parent

	while parent and parent ~= root.Parent do
		local v8 = data.Index[parent]

		if v8 and (v8.IsGroup or v8.IsRoot) then
			return v8
		end

		if parent == root then
			return data.RootItem
		end

		parent = parent.Parent
	end

	return data.RootItem
end

local function newItem(data, instance, p)
	local props = propsFor(instance)

	if not props then
		return nil
	end

	local v8 = {
		Inst = instance,
		Props = props,
		Logical = {},
		Applied = {},
		IsRoot = p or false,
		IsGroup = instance:IsA("CanvasGroup"),
		GLogical = 0,
		Cum = 1,
		CumC = 1,
		Decor = true,
		Dead = false,
		Parent = nil
	}

	local classifier = data.Classifier

	if classifier then
		local v9

		if instance:IsA("UIStroke") and instance.Parent then
			v9 = instance.Parent
		else
			v9 = instance
		end

		v8.Decor = classifier(v9, data.Root) and true or false
	end

	if not p then
		v8.Parent = groupParentOf(data, instance)
	end

	data.Index[instance] = v8
	data.Items[#data.Items + 1] = v8
	return v8
end

local function compact(data)
	local items = {}

	for _, item in ipairs(data.Items) do
		if not item.Dead then
			items[#items + 1] = item
		end
	end

	data.Items = items
end

local function stepRoot(data)
	local root = data.Root

	if not root.Parent or root:IsA("GuiObject") and not root.Visible then
		return
	end

	local v8 = HudOpacity.Get(data.Kind)
	local v9 = HudOpacity.GetContent(data.Kind)
	local extra = data.Extra or 0

	if extra > 0 then
		v8 *= 1 - extra
		v9 *= 1 - extra * 0.5
	end

	if data.Hidden then
		v8 = 0
		v9 = 0
	end

	local items = data.Items
	local count = 0

	for i = 1, #items do
		local item = items[i]

		if item.Dead then
			count += 1
		else
			local inst = item.Inst
			local cumC, cum

			if item.IsRoot then
				cumC = v9
				cum = v8
			else
				local parent = item.Parent

				if parent then
					cum = parent.Cum
					cumC = parent.CumC
				else
					cumC = v9
					cum = v8
				end
			end

			if item.IsGroup then
				local groupTransparency = inst.GroupTransparency

				if math.abs(groupTransparency - 0.0001) > 0.00015 then
					item.GLogical = groupTransparency
					inst.GroupTransparency = 0.0001
				end

				local v10 = item.GLogical

				if item.IsRoot and data.DimLimit > 0 then
					v10 = v10 <= data.DimLimit and 0 or (v10 - data.DimLimit) / (1 - data.DimLimit)
				end

				cum *= 1 - v10
				cumC *= 1 - v10
			end

			item.Cum = cum
			item.CumC = cumC
			cumC = item.Decor and cum or cumC

			local props = item.Props
			local logical = item.Logical
			local applied = item.Applied

			for j = 1, #props do
				local v10 = props[j]
				local v11 = inst[v10]
				local v12 = applied[j]
				local v13 = logical[j]

				if v12 == nil or math.abs(v11 - v12) > 0.0003 then
					logical[j] = v11
					v13 = v11
				end

				local v14 = 1 - (1 - v13) * cumC

				if math.abs(v14 - v11) > 1e-6 then
					inst[v10] = v14
				end

				applied[j] = v14
			end
		end
	end

	if count > 24 then
		compact(data)
	end
end

function GuiFade.Attach(folder, kind, value, classifier)
	if v3[folder] then
		v3[folder].Kind = kind
		v3[folder].DimLimit = value or 0
	else
		local v8 = {
			Root = folder,
			Kind = kind,
			DimLimit = value or 0,
			Classifier = classifier,
			Items = {},
			Index = {},
			Conns = {}
		}

		v3[folder] = v8
		v8.RootItem = newItem(v8, folder, true)

		if not v8.RootItem then
			v3[folder] = nil
			return
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			newItem(v8, descendant, false)
		end

		v8.Conns[1] = folder.DescendantAdded:Connect(function(descendant)
			if not v8.Index[descendant] then
				newItem(v8, descendant, false)
			end
		end)
		v8.Conns[2] = folder.DescendantRemoving:Connect(function(descendant)
			local v9 = v8.Index[descendant]

			if v9 then
				v9.Dead = true
				v8.Index[descendant] = nil
			end
		end)
		v8.Conns[3] = folder.Destroying:Connect(function()
			for _, conn in ipairs(v8.Conns) do
				conn:Disconnect()
			end

			v3[folder] = nil
		end)
	end
end

function GuiFade.SetExtra(p, p2)
	local v8 = v3[p]

	if v8 then
		v8.Extra = math.clamp(tonumber(p2) or 0, 0, 1)
	end
end

function GuiFade.SetHidden(p, p2)
	local v8 = v3[p]

	if v8 then
		v8.Hidden = p2 == true
	end
end

function GuiFade.Step()
	for _, v8 in pairs(v3) do
		stepRoot(v8)
	end
end

function GuiFade.Refresh(p)
	local v8 = v3[p]

	if v8 then
		stepRoot(v8)
	end
end

function GuiFade.Stats()
	local count = 0
	local count2 = 0
	local count3 = 0

	for _, v8 in pairs(v3) do
		count += 1

		for _, item in ipairs(v8.Items) do
			if item.Dead then
				continue
			end

			count2 += 1

			if not item.Decor then
				count3 += 1
			end
		end
	end

	return count, count2, count3
end

if RunService:IsClient() then
	RunService:BindToRenderStep("GuiFadeStep", Enum.RenderPriority.Last.Value, GuiFade.Step)
end

return GuiFade