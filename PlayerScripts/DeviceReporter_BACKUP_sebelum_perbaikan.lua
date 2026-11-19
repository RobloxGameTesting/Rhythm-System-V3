local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.RemoteEvents.ReportDevice:FireServer(UserInputService.VREnabled and "VR" or UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and "Mobile" or UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled and "Console" or "Desktop")