local Workspace = game:GetService("Workspace")

local function ensureListener() -- 1 equivalent call inferred from this helper
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera or currentCamera:FindFirstChild("LocalVoiceListener") then
		return
	end

	local localVoiceListener = Instance.new("AudioListener")
	localVoiceListener.Name = "LocalVoiceListener"
	localVoiceListener.Parent = currentCamera
end

ensureListener() -- inferred equivalent call
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(ensureListener)