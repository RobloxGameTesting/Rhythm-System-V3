local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bandCamera = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BandCamera")
local BandCameraController = require(bandCamera:WaitForChild("BandCameraController"))
local BandCameraUI = require(bandCamera:WaitForChild("BandCameraUI"))
local BandCameraTuner = require(bandCamera:WaitForChild("BandCameraTuner"))

BandCameraController.Init()
BandCameraUI.Init()
BandCameraTuner.Init()