local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local v = {
	HighCrash = true,
	Splash = true,
	MediumCrash = true,
	FootHiHat = true,
	RideEdge = true,
	RideBell = true,
	OpenHiHat = true,
	China = true
}

local v2 = -1e999
local count = 0

local function report(p, sound, fpPad, isLoaded, timePosition, p2)
	local now = os.clock()

	if now - v2 < 3 then
		count += 1
		return
	end

	v2 = now

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")
	warn(("[FreePlayDrumListenDiag] %s | pad=%s | pemukul=%s%s | IsLoaded(tiba)=%s | TimePosition(tiba)=%.3f | latensi=%s | %d kejadian serupa ditahan"):format(
		p,
		tostring(fpPad),
		tostring(freePlayPresserUserId),
		freePlayPresserUserId == LocalPlayer.UserId and " (SAYA)" or "",
		tostring(isLoaded),
		timePosition,
		p2 and ("%.3f"):format(p2) or "n/a",
		count
	))

	count = 0
end

local function inspectDrumSound(sound)
	if not sound:IsA("Sound") then
		return
	end

	local fpPad = sound:GetAttribute("FPPad")

	if fpPad == nil then
		return
	end

	local lastTime = os.clock()
	local isLoaded = sound.IsLoaded
	local timePosition = sound.TimePosition
	local fpPressTime = sound:GetAttribute("FPPressTime")
	local v3

	if type(fpPressTime) == "number" then
		v3 = Workspace:GetServerTimeNow() - fpPressTime or nil
	else
		v3 = nil
	end

	local flag = false
	local function flag2(p) -- 5 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true
		report(p, sound, fpPad, isLoaded, timePosition, v3)
	end

	if timePosition > 0.12 then
		flag2("Sound tiba dgn TimePosition sudah jauh (mulai terlambat -> hanya ekor/tik)") -- inferred equivalent call
	end

	if v3 and v3 > 0.4 then
		flag2("latensi tekan->tiba sangat besar") -- inferred equivalent call
	end

	if not v[fpPad] then
		sound.Destroying:Once(function()
			if os.clock() - lastTime < 0.1 then
				flag2("Sound drum dihancurkan < 0.1 dtk setelah tiba (hanya sempat jadi 'tik')") -- inferred equivalent call
			end
		end)
	end

	task.delay(0.12, function()
		if not sound.Parent then
			return
		end

		if sound.IsLoaded then
			if not sound.IsPlaying then
				flag2("Sound tidak IsPlaying 0.12 dtk setelah tiba") -- inferred equivalent call
			end
		else
			flag2("asset belum IsLoaded 0.12 dtk setelah tiba") -- inferred equivalent call
		end
	end)
end

Workspace.DescendantAdded:Connect(inspectDrumSound)