local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local PStudioConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PrivateStudio"):WaitForChild("PStudioConfig"))
local PStudioToasts = require(ReplicatedStorage.Modules.PrivateStudio:WaitForChild("PStudioToasts"))
local PStudioState = require(ReplicatedStorage.Modules.PrivateStudio:WaitForChild("PStudioState"))
local UIPanelGate = require(ReplicatedStorage.Modules:WaitForChild("UIPanelGate"))
local ToastStyle = require(ReplicatedStorage.Modules.SongListUI:WaitForChild("ToastStyle"))
local child = ReplicatedStorage:WaitForChild(PStudioConfig.REMOTES_FOLDER)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local text = PStudioConfig.TEXT

local v = {}

for _, childName in ipairs({
	"Create",
	"Join",
	"Respond",
	"GetList",
	"Result",
	"JoinRequest",
	"RequestClosed",
	"StateUpdate",
	"Notice",
	"InviteRespond",
	"InviteReceived",
	"InviteClosed"
}) do
	v[childName] = child:WaitForChild(childName)
end

local pStudioToastGui = Instance.new("ScreenGui")
pStudioToastGui.Name = "PStudioToastGui"
pStudioToastGui.ResetOnSpawn = false
pStudioToastGui.DisplayOrder = 60
pStudioToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pStudioToastGui.Parent = PlayerGui
PStudioToasts.Init(pStudioToastGui)

local pStudioUI = Instance.new("ScreenGui")
pStudioUI.Name = "PStudioUI"
pStudioUI.ResetOnSpawn = false
pStudioUI.DisplayOrder = 40
pStudioUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pStudioUI.Parent = PlayerGui

local function new(className, items, parent) -- 3 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function esc(p)
	return PStudioToasts.Escape(p)
end

local function makeButton(parent, text2, backgroundColor, textColor, options)
	local button = new("TextButton", { -- inferred equivalent call
		BackgroundColor3 = backgroundColor,
		AutoButtonColor = true,
		BorderSizePixel = 0,
		Text = text2,
		TextColor3 = textColor,
		Font = Enum.Font.PermanentMarker,
		TextSize = 15,
		ZIndex = 12
	}, parent)

	for k, v2 in pairs(options or {}) do
		button[k] = v2
	end

	return button
end

local function makeLabel(parent, text2, options)
	local label = new("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Text = text2,
		TextColor3 = ToastStyle.INK,
		Font = Enum.Font.SpecialElite,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12,
		RichText = true
	}, parent)

	for k, v2 in pairs(options or {}) do
		label[k] = v2
	end

	return label
end

local function frame(parent, options)
	local result = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 11 }, parent) -- inferred equivalent call

	for k, v2 in pairs(options or {}) do
		result[k] = v2
	end

	return result
end

local PStudioSkin = require(ReplicatedStorage.Modules.PrivateStudio:WaitForChild("PStudioSkin"))
local v2 = PStudioSkin.Build(pStudioUI, text)
local panel = v2.Panel
local close = v2.Close
local tabList = v2.TabList
local tabCreate = v2.TabCreate
local listView = v2.ListView
local scroll = v2.Scroll
local empty = v2.Empty
local free = v2.Free
local refresh = v2.Refresh
local createView = v2.CreateView
local nameBox = v2.NameBox
local public = v2.Public
local private = v2.Private
local create = v2.Create
local hint = v2.Hint
local passBox = v2.PassBox
local prompt = v2.Prompt

local v3 = nil

local flag = true

local function paintSelectors() -- 3 equivalent calls inferred from this helper
	v2.PaintSelectors(flag)
end

paintSelectors() -- inferred equivalent call
public.MouseButton1Click:Connect(function()
	flag = true
	paintSelectors() -- inferred equivalent call
end)
private.MouseButton1Click:Connect(function()
	flag = false
	paintSelectors() -- inferred equivalent call
end)

nameBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text2 = nameBox.Text
	local v4 = utf8.len(text2)

	if v4 and PStudioConfig.NAME_MAX < v4 then
		nameBox.Text = string.sub(text2, 1, utf8.offset(text2, PStudioConfig.NAME_MAX + 1) - 1)
	end
end)

local function capLength(instance, PASSWORD_MAX) -- 2 equivalent calls inferred from this helper
	instance:GetPropertyChangedSignal("Text"):Connect(function()
		local text2 = instance.Text
		local v4 = utf8.len(text2)

		if v4 and PASSWORD_MAX < v4 then
			instance.Text = string.sub(text2, 1, utf8.offset(text2, PASSWORD_MAX + 1) - 1)
		end
	end)
end
capLength(passBox, PStudioConfig.PASSWORD_MAX) -- inferred equivalent call
capLength(prompt.Box, PStudioConfig.PASSWORD_MAX) -- inferred equivalent call

local v4 = "list"
local v5 = nil

local function showTab(p)
	v4 = p
	listView.Visible = p == "list"
	createView.Visible = p == "create"
	v2.SetTab(p)
end

v4 = "list"
listView.Visible = true
createView.Visible = false
v2.SetTab("list")

local function clearRows()
	for _, frame2 in ipairs(scroll:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end
end

local function renderList(result)
	local values = { (tostring(result.free)) }

	for _, studio in ipairs(result.studios) do
		values[#values + 1] = table.concat(
			{
				studio.studioId,
				studio.name,
				studio.count,
				studio.max,
				tostring(studio.isPublic),
				tostring(studio.hasPassword),
				tostring(studio.ownerId),
				studio.ownerName
			},
			"|"
		)
	end

	local joined = table.concat(values, ";")
	free.Text = result.free > 0 and string.format(text.SlotsFree, result.free, result.total) or text.NoSlots
	hint.Text = free.Text

	if joined == v5 then
		return
	end

	v5 = joined

	clearRows()
	empty.Visible = #result.studios == 0

	for i, studio in ipairs(result.studios) do
		v2.MakeRow(scroll, studio, i, function()
			if not studio.hasPassword then
				v.Join:FireServer(studio.studioId)

				return
			end

			v3 = { id = studio.studioId, name = studio.name }
			v2.ShowPrompt(studio.name)
		end)
	end
end

local function refresh2()
	local success, result = pcall(function()
		return v.GetList:InvokeServer()
	end)

	if success and type(result) == "table" and type(result.studios) == "table" then
		renderList(result)
	end
end

refresh.MouseButton1Click:Connect(function()
	v5 = nil
	refresh2()
end)

local function closePanel() -- 3 equivalent calls inferred from this helper
	v2.HidePrompt()
	v3 = nil
	panel.Visible = false
	UIPanelGate.Release("StudioHub")
end

local function openPanel()
	if PStudioState.Get() then
		PStudioToasts.Notice(PStudioConfig.RESULT_TEXT.already_in_studio, "error")
		return
	end

	if not UIPanelGate.Request("StudioHub") then
		return
	end

	panel.Visible = true
	v2.HidePrompt()
	v4 = "list"
	listView.Visible = true
	createView.Visible = false
	v2.SetTab("list")

	v5 = nil
	refresh2()
end

UIPanelGate.Register("StudioHub", {
	Close = closePanel,
	IsOpen = function()
		return panel.Visible
	end
})

tabList.MouseButton1Click:Connect(function()
	v4 = "list"
	listView.Visible = true
	createView.Visible = false
	v2.SetTab("list")

	v5 = nil
	refresh2()
end)
tabCreate.MouseButton1Click:Connect(function()
	v4 = "create"
	listView.Visible = false
	createView.Visible = true
	v2.SetTab("create")

	refresh2()
end)
close.MouseButton1Click:Connect(closePanel)

local flag2 = false
create.MouseButton1Click:Connect(function()
	if flag2 then
		return
	end

	local v6 = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

	if v6 == "" then
		PStudioToasts.Notice(PStudioConfig.RESULT_TEXT.bad_name, "error")
		return
	end

	flag2 = true
	local v7

	if not flag then
		v7 = passBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

		if v7 == "" then
			v7 = nil
		elseif (utf8.len(v7) or 0) < PStudioConfig.PASSWORD_MIN then
			flag2 = false
			PStudioToasts.Notice(PStudioConfig.RESULT_TEXT.bad_password, "error")
			return
		end
	end

	v.Create:FireServer(v6, flag, v7)
	task.delay(1.2, function()
		flag2 = false
	end)
end)

local function submitPassword()
	if not v3 then
		return
	end

	local v6 = prompt.Box.Text:gsub("^%s+", ""):gsub("%s+$", "")

	if v6 == "" then
		PStudioToasts.Notice(PStudioConfig.RESULT_TEXT.password_required, "error")
		return
	end

	v.Join:FireServer(v3.id, v6)
	v2.HidePrompt()
end
prompt.Join.MouseButton1Click:Connect(submitPassword)
prompt.Box.FocusLost:Connect(function(p)
	if p then
		submitPassword()
	end
end)
prompt.Cancel.MouseButton1Click:Connect(function()
	v2.HidePrompt()
	v3 = nil
end)

local parent = nil
ProximityPromptService.PromptTriggered:Connect(function(prompt2, player)
	if player == LocalPlayer and prompt2.Name == PStudioConfig.PROMPT_NAME then
		if prompt2.Parent and prompt2.Parent:IsA("BasePart") then
			parent = prompt2.Parent
		end

		if panel.Visible then
			closePanel() -- inferred equivalent call
		else
			openPanel()
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(PStudioConfig.LIST_REFRESH)

		if panel.Visible and v4 == "list" then
			refresh2()
		end
	end
end)

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.5 then
		return
	end

	total = 0

	if not panel.Visible then
		return
	end

	local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if
		humanoidRootPart
		and parent
		and parent:IsDescendantOf(workspace)
		and (humanoidRootPart.Position - parent.Position).Magnitude > PStudioConfig.PANEL_CLOSE_DISTANCE
	then
		closePanel() -- inferred equivalent call
	end
end)

local v6 = { created = true, joined = true, accepted = true }
local v7 = { pending = true }

v.Result.OnClientEvent:Connect(function(p)
	local v8 = PStudioConfig.RESULT_TEXT[p] or tostring(p)
	local v9 = v6[p] and "ok" or v7[p] and "info" or "error"
	PStudioToasts.Notice(v8, v9)

	if p == "created" then
		passBox.Text = ""
	end

	if p == "wrong_password" and v3 and panel.Visible then
		v2.ShowPrompt(v3.name)
	end
end)

local v8 = {
	owner_transferred = "info",
	member_joined = "ok",
	member_left = "info",
	member_kicked = "error",
	owner_changed = "info",
	invite_declined = "info",
	invite_expired = "info"
}

local v9 = {
	member_joined = true,
	member_left = true,
	member_kicked = true,
	owner_changed = true,
	invite_declined = true,
	invite_expired = true
}

v.Notice.OnClientEvent:Connect(function(p, value)
	local v10 = PStudioConfig.NOTICE_TEXT[p] or tostring(p)

	if value ~= nil and v10:find("%%s") then
		v10 = string.format(v10, (tostring(value)))
	end

	local notice = PStudioToasts.Notice
	local v11 = v8[p] or "error"

	if not v9[p] or type(value) ~= "string" or not value then
		value = nil
	end

	notice(v10, v11, value)
end)

v.InviteReceived.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" or type(p.id) ~= "number" then
		return
	end

	PStudioToasts.ShowInvite(p, function()
		v.InviteRespond:FireServer(p.id, true)
		PStudioToasts.RemoveInvite(p.id)
	end, function()
		v.InviteRespond:FireServer(p.id, false)
		PStudioToasts.RemoveInvite(p.id)
	end)
end)

v.InviteClosed.OnClientEvent:Connect(function(p)
	PStudioToasts.RemoveInvite(p)
end)

v.JoinRequest.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" or type(p.id) ~= "number" then
		return
	end

	PStudioToasts.ShowRequest(p, function()
		v.Respond:FireServer(p.id, true)
		PStudioToasts.RemoveRequest(p.id)
	end, function()
		v.Respond:FireServer(p.id, false)
		PStudioToasts.RemoveRequest(p.id)
	end)
end)

v.RequestClosed.OnClientEvent:Connect(function(p)
	PStudioToasts.RemoveRequest(p)
end)

v.StateUpdate.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" then
		PStudioState.Set(nil)

		return
	end

	closePanel() -- inferred equivalent call
	PStudioState.Set(p)
end)

local CollectionService = game:GetService("CollectionService")

local v10 = {}

local function studioIdOf(instance)
	while instance do
		local studioId = instance:GetAttribute("StudioId")

		if studioId then
			return studioId
		end

		instance = instance.Parent
	end

	return nil
end

local function refreshLeavePrompt(p) -- 2 equivalent calls inferred from this helper
	local v11 = PStudioState.Get()
	local v12

	if v11 == nil then
		v12 = false
	else
		local studioId = v11.studioId
		local v13 = p
		local studioId2

		while true do
			if not v13 then
				studioId2 = nil
				break
			end

			studioId2 = v13:GetAttribute("StudioId")

			if studioId2 then
				break
			end

			v13 = v13.Parent
		end

		v12 = studioId == studioId2
	end

	p.Enabled = v12 and LocalPlayer:GetAttribute("EquippedInstrumentType") == nil
end

local function refreshAllLeavePrompts()
	for k in pairs(v10) do
		if k.Parent then
			refreshLeavePrompt(k) -- inferred equivalent call
		end
	end
end

local function trackLeavePrompt(proximityPrompt)
	if proximityPrompt:IsA("ProximityPrompt") and not v10[proximityPrompt] then
		v10[proximityPrompt] = true
		proximityPrompt.AncestryChanged:Connect(function(_, parent2)
			if not parent2 then
				v10[proximityPrompt] = nil
			end
		end)
		refreshLeavePrompt(proximityPrompt) -- inferred equivalent call
	end
end

for _, v11 in ipairs(CollectionService:GetTagged("PStudioLeavePrompt")) do
	trackLeavePrompt(v11)
end

CollectionService:GetInstanceAddedSignal("PStudioLeavePrompt"):Connect(trackLeavePrompt)
LocalPlayer:GetAttributeChangedSignal("EquippedInstrumentType"):Connect(refreshAllLeavePrompts)
PStudioState.Changed:Connect(refreshAllLeavePrompts)