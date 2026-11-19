local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
local StemCache = require(ReplicatedStorage.Modules.StemCache)

local stemLoadToastGui = nil
local v = nil

local function showInfoToast(p, p2) -- 2 equivalent calls inferred from this helper
	local success, result = pcall(function()
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return
		end

		if not (stemLoadToastGui and stemLoadToastGui.Parent) then
			stemLoadToastGui = Instance.new("ScreenGui")
			stemLoadToastGui.Name = "StemLoadToastGui"
			stemLoadToastGui.ResetOnSpawn = false
			stemLoadToastGui.IgnoreGuiInset = true
			stemLoadToastGui.DisplayOrder = 50
			stemLoadToastGui.Parent = playerGui
			local ThemeSwitchToast = require(ReplicatedStorage.Modules.ThemeSwitchToast)
			v = ThemeSwitchToast.new(stemLoadToastGui)
			v._card.Position = UDim2.new(0.5, 0, 0, 64)
		end

		v:Show(p, p2)
	end)

	if not success then
		warn("[ClientSongPreloader] toast gagal: " .. tostring(result))
	end
end

return {
	PreloadSongStems = function(p, onProgress, options): boolean
		local v2 = options or {}

		if SongConfig.Songs[p] then
			local maxWaitSeconds = v2.MaxWaitSeconds
			local maxWaitSeconds2 = maxWaitSeconds == nil and 45 or maxWaitSeconds

			if v2.WarmChart == false or v2.WarmChartInstrument == nil and v2.WarmChart ~= true then
				if v2.WarmChart ~= false then
					task.spawn(function()
						local success, chartLoader = pcall(require, ReplicatedStorage.Modules.ChartLoader)

						if success and chartLoader then
							chartLoader.Warm(p, nil)
						end
					end)
				end
			else
				StemCache.RequestSong(p, "high")

				if onProgress then
					pcall(onProgress, 0)
				end

				local success, chartLoader = pcall(require, ReplicatedStorage.Modules.ChartLoader)

				if success and chartLoader then
					chartLoader.Warm(p, v2.WarmChartInstrument)
				end
			end

			local v3, v4, v5 = StemCache.WaitForSong(p, {
				Priority = "high",
				MaxWaitSeconds = maxWaitSeconds2,
				OnProgress = onProgress
			})

			if v3 then
				return true
			end

			warn(("[ClientSongPreloader] '%s' belum siap penuh (%d/%d) setelah %ds -- lanjut, retry jalan di latar belakang"):format(
				p,
				v4,
				v5,
				maxWaitSeconds2
			))

			if onProgress then
				pcall(onProgress, 100)
			end

			if not v2.SuppressToast then
				showInfoToast("Some audio is still loading — continuing, retrying in the background", 6) -- inferred equivalent call
			end

			task.spawn(function()
				if StemCache.WaitForSong(p, { Priority = "high" }) and not v2.SuppressToast then
					showInfoToast("Audio finished loading", 3) -- inferred equivalent call
				end
			end)
			return false
		end

		warn("[ClientSongPreloader] Lagu tidak ditemukan di SongConfig:", p)

		if onProgress then
			onProgress(100)
		end

		return true
	end,
	ShowInfoToast = showInfoToast
}