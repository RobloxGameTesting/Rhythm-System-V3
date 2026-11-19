local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local TutorialSpotlight = require(Modules:WaitForChild("TutorialSpotlight"))
local ResultsTutorial = require(Modules:WaitForChild("ResultsTutorial"))
local TipState = require(Modules:WaitForChild("TipState"))
local v = TipState.ForLocalPlayer()

local ResultsScreenUI = PlayerGui:WaitForChild("ResultsScreenUI", 30)

if not ResultsScreenUI then
	warn("[ResultsTutorialClient] ResultsScreenUI tidak ditemukan; penjelasan layar hasil dinonaktifkan")
	return
end

local v2 = {
	grade = "CenterStats",
	judgements = "Judgements",
	timeline = "Timeline",
	close = "CloseButton"
}

local function findTarget(p)
	if p == "rank" then
		for _, guiObject in ipairs(ResultsScreenUI:GetDescendants()) do
			if
				guiObject.Name == "RankRow"
				and guiObject:IsA("GuiObject")
				and guiObject:GetAttribute("IsMe") == true
			then
				return guiObject
			end
		end

		local rankings = ResultsScreenUI:FindFirstChild("Rankings", true)

		if not (rankings and rankings:IsA("GuiObject") and rankings) then
			rankings = nil
		end

		return rankings
	else
		local guiObject = ResultsScreenUI:FindFirstChild(v2[p], true)

		if not (guiObject and guiObject:IsA("GuiObject") and guiObject) then
			guiObject = nil
		end

		return guiObject
	end
end

local v3 = {
	getTarget = findTarget,
	isTargetShown = function(p)
		local target = findTarget(p)
		return target ~= nil and TutorialSpotlight.IsShown(target)
	end,
	isOpen = function()
		return ResultsScreenUI.Enabled
	end,
	isMobile = function()
		return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	end,
	anyShowing = TutorialSpotlight.AnyShowing
}

local v4 = ResultsTutorial.new(TutorialSpotlight.new(nil, "ResultsTutorialSpotlightGui"), v3, v)

ResultsScreenUI:GetPropertyChangedSignal("Enabled"):Connect(function()
	if ResultsScreenUI.Enabled then
		v4:OnShown()
	else
		v4:OnClosed()
	end
end)

if ResultsScreenUI.Enabled then
	v4:OnShown()
end