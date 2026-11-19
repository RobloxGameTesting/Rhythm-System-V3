local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DrumPresetMenu = {}
DrumPresetMenu.ROW_HEIGHT = 26
local v = {}
local function showToast(screenGui, text)
	if not screenGui then
		return
	end

	local drumPresetToast = screenGui:FindFirstChild("DrumPresetToast")

	if not drumPresetToast then
		drumPresetToast = Instance.new("TextLabel")
		drumPresetToast.Name = "DrumPresetToast"
		drumPresetToast.AnchorPoint = Vector2.new(0.5, 0)
		drumPresetToast.Position = UDim2.new(0.5, 0, 0, 70)
		drumPresetToast.Size = UDim2.new(0, 0, 0, 30)
		drumPresetToast.AutomaticSize = Enum.AutomaticSize.X
		drumPresetToast.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
		drumPresetToast.BackgroundTransparency = 0.05
		drumPresetToast.BorderSizePixel = 0
		drumPresetToast.Font = Enum.Font.GothamBold
		drumPresetToast.TextSize = 13
		drumPresetToast.TextColor3 = Color3.fromRGB(235, 235, 235)
		drumPresetToast.ZIndex = 600
		drumPresetToast.Visible = false
		drumPresetToast.Parent = screenGui
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = drumPresetToast
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 14)
		uiPadding.PaddingRight = UDim.new(0, 14)
		uiPadding.Parent = drumPresetToast
	end

	drumPresetToast.Text = text
	drumPresetToast.Visible = true
	local v2 = (v[screenGui] or 0) + 1
	v[screenGui] = v2
	task.delay(2.2, function()
		if v[screenGui] == v2 and drumPresetToast.Parent then
			drumPresetToast.Visible = false
		end
	end)
end

function DrumPresetMenu.Create(data)
	local kind = data.Kind
	local popup = data.Popup
	local screenGui = data.ScreenGui
	local colors = data.Colors
	local drumPresetRequest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("DrumPresetRequest")

	local v2 = {}
	local flag = false
	local v3 = nil
	local count = 0
	local flag2 = false
	local v4 = nil

	local function toast(text) -- 9 equivalent calls inferred from this helper
		showToast(screenGui, text)
	end

	local function displayName(p) -- 6 equivalent calls inferred from this helper
		local v5 = v2[p]

		if v5 and type(v5.Name) == "string" and v5.Name ~= "" then
			return v5.Name
		end

		return "Preset " .. p
	end

	local function invoke(p, p2, p3)
		local success, result = pcall(function()
			return drumPresetRequest:InvokeServer(kind, p, p2, p3)
		end)

		if success and typeof(result) == "table" then
			return result
		end

		return { Ok = false, Reason = "Presets are unavailable right now." }
	end

	local function corner(parent, p) -- 2 equivalent calls inferred from this helper
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, p)
		uiCorner.Parent = parent
	end

	local function styleSmallButton(parent, text, parent2) -- 8 equivalent calls inferred from this helper
		parent.Text = text
		parent.Font = Enum.Font.GothamBold
		parent.TextSize = 11
		parent.AutoButtonColor = false
		parent.BackgroundColor3 = colors.Button
		parent.TextColor3 = colors.Text
		parent.BorderSizePixel = 0
		parent.Parent = parent2
		corner(parent, 6) -- inferred equivalent call
	end

	local presetButtonRow = Instance.new("Frame")
	presetButtonRow.Name = "PresetButtonRow"
	presetButtonRow.BackgroundTransparency = 1
	presetButtonRow.AnchorPoint = Vector2.new(0, 1)
	presetButtonRow.Position = UDim2.new(0, 0, 1, 0)
	presetButtonRow.Size = UDim2.new(1, 0, 0, DrumPresetMenu.ROW_HEIGHT)
	presetButtonRow.Parent = popup

	local savePresetButton = Instance.new("TextButton")
	savePresetButton.Name = "SavePresetButton"
	savePresetButton.Size = UDim2.new(0.5, -3, 1, 0)
	savePresetButton.Position = UDim2.new(0, 0, 0, 0)
	styleSmallButton(savePresetButton, "SAVE PRESET", presetButtonRow) -- inferred equivalent call
	local loadPresetButton = Instance.new("TextButton")
	loadPresetButton.Name = "LoadPresetButton"
	loadPresetButton.Size = UDim2.new(0.5, -3, 1, 0)
	loadPresetButton.Position = UDim2.new(0.5, 3, 0, 0)
	styleSmallButton(loadPresetButton, "LOAD PRESET", presetButtonRow) -- inferred equivalent call
	local presetMenu = Instance.new("Frame")
	presetMenu.Name = "PresetMenu"
	presetMenu.Position = UDim2.fromOffset(0, 32)
	presetMenu.Size = UDim2.new(1, 0, 1, -32)
	presetMenu.BackgroundColor3 = colors.Panel
	presetMenu.BackgroundTransparency = 0
	presetMenu.BorderSizePixel = 0
	presetMenu.Active = true
	presetMenu.Visible = false
	presetMenu.Parent = popup

	local function makePage(layoutOrder)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.BackgroundTransparency = 1
		frame.LayoutOrder = layoutOrder
		frame.Parent = presetMenu
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Padding = UDim.new(0, 4)
		uiListLayout.Parent = frame
		return frame
	end

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = presetMenu

	local page = makePage(1)
	local page2 = makePage(2)
	page2.Visible = false

	local function makeLabel(page3, layoutOrder, textSize, p)
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 0, p)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = textSize
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextColor3 = colors.Dim
		textLabel.LayoutOrder = layoutOrder
		textLabel.Parent = page3
		return textLabel
	end

	local label = makeLabel(page, 0, 11, 18)

	local label2 = makeLabel(page2, 0, 13, 24)
	label2.TextColor3 = colors.Text

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 26)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = 1
	frame.Parent = page2

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Padding = UDim.new(0, 6)
	uiListLayout2.Parent = frame

	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(0.5, -3, 1, 0)
	textButton.LayoutOrder = 1
	styleSmallButton(textButton, "OVERWRITE", frame) -- inferred equivalent call
	textButton.TextColor3 = colors.On

	local textButton2 = Instance.new("TextButton")
	textButton2.Size = UDim2.new(0.5, -3, 1, 0)
	textButton2.LayoutOrder = 2
	styleSmallButton(textButton2, "CANCEL", frame) -- inferred equivalent call
	local v5 = {}

	local function showListPage() -- 4 equivalent calls inferred from this helper
		v4 = nil
		page2.Visible = false
		page.Visible = true
	end

	local function renderMenu()
		local v6 = v3 == "load"
		label.Text = v6 and "LOAD PRESET" or "SAVE TO PRESET"

		for i = 1, 3 do
			local v7 = v5[i]
			local v8 = v2[i]
			local v9 = flag

			if v9 then
				if v8 == nil then
					v9 = false
				else
					v9 = v8.Empty == false
				end
			end

			local text

			if flag then
				if v9 then
					text = displayName(i) -- inferred equivalent call
				else
					text = "Preset " .. i .. " - Empty"
				end
			else
				text = "Loading..."
			end

			v7.Main.Text = text
			local active = flag and (not v6 or v9)
			v7.Main.Active = active
			v7.Main.TextColor3 = v9 and colors.Text or colors.Dim
			v7.Main.TextTransparency = active and 0 or 0.4
			v7.Rename.Visible = v9 and not v7.NameBox.Visible
			v7.Delete.Visible = v9 and not v7.NameBox.Visible
		end
	end

	local function fn()
		count += 1
		v3 = nil
		presetMenu.Visible = false
		showListPage() -- inferred equivalent call

		for i = 1, 2 do
			local item = v5[i]

			if not item then
				continue
			end

			item.NameBox.Visible = false
			item.Main.Visible = true
		end

		local v6 = v5[3]

		if v6 then
			v6.NameBox.Visible = false
			v6.Main.Visible = true
		end
	end

	local function doSave(p)
		if flag2 then
			return
		end

		flag2 = true
		local v6 = invoke("Save", p, data.Collect())
		flag2 = false

		if v6.Ok then
			v2 = v6.Slots or v2
			toast(displayName(p) .. " saved") -- inferred equivalent call
			fn()
		else
			toast(v6.Reason or "Couldn't save preset.") -- inferred equivalent call

			if presetMenu.Visible then
				showListPage() -- inferred equivalent call
			end
		end
	end

	local function doLoad(i)
		if flag2 then
			return
		end

		flag2 = true
		local v6 = invoke("Get", i)
		flag2 = false

		if not presetMenu.Visible then
			return
		end

		if v6.Ok and typeof(v6.Data) == "table" then
			data.Apply(v6.Data)
			toast(displayName(i) .. " loaded") -- inferred equivalent call
			fn()
		else
			toast(v6.Reason or "Couldn't load preset.") -- inferred equivalent call
		end
	end

	local function doDelete(slot)
		if flag2 then
			return
		end

		flag2 = true
		local v6 = displayName(slot) -- inferred equivalent call
		local v7 = invoke("Delete", slot)
		flag2 = false

		if v7.Ok then
			v2 = v7.Slots or v2
			toast(v6 .. " deleted") -- inferred equivalent call
		else
			toast(v7.Reason or "Couldn't delete preset.") -- inferred equivalent call
		end

		if presetMenu.Visible then
			showListPage() -- inferred equivalent call
			renderMenu()
		end
	end

	local function showConfirm(kind2, i) -- 2 equivalent calls inferred from this helper
		v4 = { Kind = kind2, Slot = i }

		if kind2 == "delete" then
			label2.Text = "Delete " .. displayName(i) .. "?" -- inferred equivalent call
			textButton.Text = "DELETE"
		else
			label2.Text = "Overwrite " .. displayName(i) .. "?" -- inferred equivalent call
			textButton.Text = "OVERWRITE"
		end

		page.Visible = false
		page2.Visible = true
	end

	local function beginRename(i) -- 1 equivalent call inferred from this helper
		local v6 = v5[i]
		local v7 = v2[i]
		v6.Main.Visible = false
		v6.Rename.Visible = false
		v6.Delete.Visible = false
		v6.NameBox.Text = v7 and v7.Name or ""
		v6.NameBox.Visible = true
		v6.NameBox:CaptureFocus()
	end

	local function finishRename(i, p)
		local v6 = v5[i]
		local text = v6.NameBox.Text
		v6.NameBox.Visible = false
		v6.Main.Visible = true
		renderMenu()

		local v7 = string.match(text, "^%s*(.-)%s*$") or ""

		if not p or v7 == "" or flag2 then
			return
		end

		flag2 = true
		local v8 = invoke("Rename", i, v7)
		flag2 = false

		if v8.Ok then
			v2 = v8.Slots or v2
			toast("Preset renamed") -- inferred equivalent call
		else
			toast(v8.Reason or "Couldn't rename preset.") -- inferred equivalent call
		end

		if presetMenu.Visible then
			renderMenu()
		end
	end

	for i = 1, 3 do
		local frame2 = Instance.new("Frame")
		frame2.Name = "PresetRow" .. i
		frame2.Size = UDim2.new(1, 0, 0, 26)
		frame2.BackgroundTransparency = 1
		frame2.LayoutOrder = i
		frame2.Parent = page

		local main = Instance.new("TextButton")
		main.Name = "Main"
		main.Size = UDim2.new(1, -116, 1, 0)
		styleSmallButton(main, "", frame2) -- inferred equivalent call
		main.TextXAlignment = Enum.TextXAlignment.Left
		main.TextTruncate = Enum.TextTruncate.AtEnd
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 8)
		uiPadding.PaddingRight = UDim.new(0, 8)
		uiPadding.Parent = main

		local rename = Instance.new("TextButton")
		rename.Name = "Rename"
		rename.AnchorPoint = Vector2.new(1, 0)
		rename.Position = UDim2.new(1, -56, 0, 0)
		rename.Size = UDim2.new(0, 56, 1, 0)
		styleSmallButton(rename, "RENAME", frame2) -- inferred equivalent call
		rename.TextSize = 10
		rename.Visible = false

		local delete = Instance.new("TextButton")
		delete.Name = "Delete"
		delete.AnchorPoint = Vector2.new(1, 0)
		delete.Position = UDim2.new(1, 0, 0, 0)
		delete.Size = UDim2.new(0, 52, 1, 0)
		styleSmallButton(delete, "DELETE", frame2) -- inferred equivalent call
		delete.TextSize = 10
		delete.Visible = false

		local nameBox = Instance.new("TextBox")
		nameBox.Name = "NameBox"
		nameBox.Size = UDim2.new(1, 0, 1, 0)
		nameBox.BackgroundColor3 = colors.Button
		nameBox.BackgroundTransparency = 0.05
		nameBox.Font = Enum.Font.GothamBold
		nameBox.TextSize = 12
		nameBox.TextColor3 = colors.Text
		nameBox.PlaceholderText = "Preset name"
		nameBox.PlaceholderColor3 = colors.Dim
		nameBox.TextXAlignment = Enum.TextXAlignment.Left
		nameBox.ClearTextOnFocus = false
		nameBox.Visible = false
		nameBox.Parent = frame2
		corner(nameBox, 6) -- inferred equivalent call
		local uiPadding2 = Instance.new("UIPadding")
		uiPadding2.PaddingLeft = UDim.new(0, 8)
		uiPadding2.PaddingRight = UDim.new(0, 8)
		uiPadding2.Parent = nameBox

		nameBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = nameBox.Text
			local v6 = utf8.len(text)

			if v6 and v6 > 20 then
				nameBox.Text = string.sub(text, 1, utf8.offset(text, 21) - 1)
			end
		end)

		v5[i] = {
			Row = frame2,
			Main = main,
			Rename = rename,
			Delete = delete,
			NameBox = nameBox
		}

		main.Activated:Connect(function()
			if flag2 or not flag then
				return
			end

			local v6 = v2[i]
			local v7

			if v6 == nil then
				v7 = false
			else
				v7 = v6.Empty == false
			end

			if v3 == "save" then
				if not v7 then
					doSave(i)
					return
				end

				showConfirm("overwrite", i) -- inferred equivalent call
			elseif v3 == "load" and v7 then
				doLoad(i)
			end
		end)
		rename.Activated:Connect(function()
			if not flag2 then
				beginRename(i) -- inferred equivalent call
			end
		end)
		delete.Activated:Connect(function()
			if not flag2 then
				showConfirm("delete", i) -- inferred equivalent call
			end
		end)
		nameBox.FocusLost:Connect(function(p)
			finishRename(i, p)
		end)
	end

	local backButton = Instance.new("TextButton")
	backButton.Name = "BackButton"
	backButton.Size = UDim2.new(1, 0, 0, 26)
	backButton.LayoutOrder = 4
	styleSmallButton(backButton, "< BACK", page) -- inferred equivalent call
	backButton.Activated:Connect(function()
		fn()
	end)

	textButton.Activated:Connect(function()
		local v6 = v4

		if not v6 then
			return
		end

		if v6.Kind == "delete" then
			doDelete(v6.Slot)
		else
			doSave(v6.Slot)
		end
	end)
	textButton2.Activated:Connect(showListPage)

	local function openMenu(p)
		if presetMenu.Visible and v3 == p then
			fn()
			return
		end

		v3 = p
		count += 1
		local v6 = count
		showListPage() -- inferred equivalent call
		flag = false
		presetMenu.Visible = true
		renderMenu()

		task.spawn(function()
			local v7 = invoke("List")

			if v6 ~= count or not presetMenu.Visible then
				return
			end

			if v7.Ok then
				v2 = v7.Slots or {}
				flag = true
				renderMenu()
			else
				toast(v7.Reason or "Presets are unavailable right now.") -- inferred equivalent call
				fn()
			end
		end)
	end

	savePresetButton.Activated:Connect(function()
		openMenu("save")
	end)
	loadPresetButton.Activated:Connect(function()
		openMenu("load")
	end)

	return {
		["Close"] = fn,
		IsOpen = function()
			return presetMenu.Visible
		end,
		ApplyZ = function()
			local function setZ(guiObject) -- 2 equivalent calls inferred from this helper
				if guiObject:IsA("GuiObject") then
					local v6 = guiObject
					local count2 = 0

					while v6 and v6 ~= presetMenu do
						count2 += 1
						v6 = v6.Parent
					end

					guiObject.ZIndex = count2 + 400
				end
			end

			setZ(presetMenu) -- inferred equivalent call

			for _, descendant in ipairs(presetMenu:GetDescendants()) do
				setZ(descendant) -- inferred equivalent call
			end
		end
	}
end

return DrumPresetMenu