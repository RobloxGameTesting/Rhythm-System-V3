local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local syncAdjustmentNotice = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SyncAdjustmentNotice")

local syncAdjustmentNoticeUI = Instance.new("ScreenGui")
syncAdjustmentNoticeUI.Name = "SyncAdjustmentNoticeUI"
syncAdjustmentNoticeUI.ResetOnSpawn = false
syncAdjustmentNoticeUI.IgnoreGuiInset = true
syncAdjustmentNoticeUI.DisplayOrder = 50
syncAdjustmentNoticeUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local notice = Instance.new("TextLabel")
notice.Name = "Notice"
notice.AnchorPoint = Vector2.new(0.5, 0)
notice.Position = UDim2.new(0.5, 0, 0.05, 0)
notice.Size = UDim2.new(0, 320, 0, 36)
notice.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
notice.BackgroundTransparency = 0.25
notice.TextColor3 = Color3.fromRGB(255, 255, 255)
notice.Font = Enum.Font.GothamMedium
notice.TextSize = 16
notice.Text = ""
notice.Visible = false
notice.ZIndex = 50

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = notice

notice.Parent = syncAdjustmentNoticeUI

local count = 0

local function playNotice(value)
	count += 1
	local v = count

	local v2 = math.max(1, (math.ceil(value or 1)))
	notice.Visible = true
	notice.BackgroundTransparency = 0.25
	notice.TextTransparency = 0

	for i = v2, 1, -1 do
		if v ~= count then
			return
		end

		notice.Text = ("Adjusting sync... (%ds)"):format(i)
		task.wait(1)
	end

	if v ~= count then
		return
	end

	notice.Text = "Tersinkron!"
	task.wait(0.6)

	if v ~= count then
		return
	end

	local tween = TweenService:Create(notice, TweenInfo.new(0.4), {
		BackgroundTransparency = 1,
		TextTransparency = 1
	})

	tween:Play()
	tween.Completed:Wait()

	if v == count then
		notice.Visible = false
	end
end

syncAdjustmentNotice.OnClientEvent:Connect(function(p)
	playNotice(p)
end)