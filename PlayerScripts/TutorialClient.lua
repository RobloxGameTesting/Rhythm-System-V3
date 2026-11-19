local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local LiveStatsHUD = require(Modules:WaitForChild("LiveStatsHUD"))
local NewbieModeState = require(Modules:WaitForChild("NewbieModeState"))
local NewbieModePanelUI = require(Modules:WaitForChild("NewbieModePanelUI"))
local SettingsState = require(Modules:WaitForChild("SettingsState"))
local TutorialSpotlight = require(Modules:WaitForChild("TutorialSpotlight"))
local DifficultyTip = require(Modules:WaitForChild("DifficultyTip"))
local MobileKeyTip = require(Modules:WaitForChild("MobileKeyTip"))
local TipState = require(Modules:WaitForChild("TipState"))
local v = TipState.ForLocalPlayer()
local UserInputService = game:GetService("UserInputService")
local keyModeUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("KeyModeUpdate")

local flag = false

local function keyGui() -- 4 equivalent calls inferred from this helper
	return PlayerGui:FindFirstChild("KeyModeToggleUI")
end

local v2 = {
	isArmed = function(): boolean
		if flag then
			return false
		end

		return LocalPlayer:GetAttribute("TutorialFillDone") == true
			and LocalPlayer:GetAttribute("TutorialDifficultyDone") == false
	end,
	isNatural = function(): boolean
		return NewbieModeState.GetMatchingPresetName() == "Natural"
	end,
	getDifficultyButton = function()
		local v2 = keyGui() -- inferred equivalent call
		return v2 and v2:FindFirstChild("DifficultyButton", true) or nil
	end,
	getDifficultyPanel = function()
		local v2 = keyGui() -- inferred equivalent call
		return v2 and v2:FindFirstChild("DifficultyPanel", true) or nil
	end,
	isMorePanelOpen = function(): boolean
		local current = NewbieModePanelUI.Current
		return current ~= nil and current._panelScreenGui ~= nil and current._panelScreenGui.Enabled == true
	end,
	ensureHudVisible = function()
		if PlayerGui:GetAttribute("TopbarHidden") == true then
			PlayerGui:SetAttribute("TopbarHidden", false)
		end
	end,
	markDone = function()
		flag = true
		SettingsState.SetField("TutorialDifficultyDone", true, true)
	end,
	onDifficultyChanged = function(p)
		NewbieModeState.OnChanged(p)
	end
}

local v3 = nil
keyModeUpdate.OnClientEvent:Connect(function(p)
	v3 = p
end)

local function keyButton() -- 1 equivalent call inferred from this helper
	local v4 = keyGui() -- inferred equivalent call
	return v4 and v4:FindFirstChild("KeyModeButton", true) or nil
end

local v4 = {
	isMobile = function()
		return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	end,
	getKeyMode = function()
		if v3 ~= nil then
			return v3
		end

		local v4 = keyButton() -- inferred equivalent call
		return v4 and tonumber(v4.Text:match("(%d)%-Key")) or nil
	end,
	getKeyButton = keyButton,
	getKeyPanel = function()
		local v4 = keyGui() -- inferred equivalent call
		return v4 and v4:FindFirstChild("DropdownPanel", true) or nil
	end,
	anyShowing = TutorialSpotlight.AnyShowing
}

local v5 = MobileKeyTip.new(TutorialSpotlight.new(nil, "MobileKeyTipSpotlightGui"), v4, v)
function v2.onStruggle()
	return v5:Trigger()
end

local v6 = DifficultyTip.new(TutorialSpotlight.new(nil, "DifficultyTipSpotlightGui"), v2)

LiveStatsHUD.OnVisibilityChanged(function(p)
	v6:OnVisibility(p)
	v5:OnVisibility(p)
end)

LocalPlayer:GetAttributeChangedSignal("TutorialDifficultyDone"):Connect(function()
	if LocalPlayer:GetAttribute("TutorialDifficultyDone") == false then
		flag = false
		v6:Reset()
	end
end)

LocalPlayer:GetAttributeChangedSignal("TutorialResetNotice"):Connect(function()
	if LocalPlayer:GetAttribute("TutorialResetNotice") == nil then
		return
	end

	local success, result = pcall(function()
		local TextChatService = game:GetService("TextChatService")
		return TextChatService:WaitForChild("TextChannels", 5):WaitForChild("RBXGeneral", 5)
	end)

	if success and result then
		result:DisplaySystemMessage("Tutorial & tips reset. Press Play without Fill to see the tutorial again.")
	end
end)
LiveStatsHUD.OnJudgment(function(p, p2)
	v6:OnJudgment(p, p2)
end)