local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	Fetch = function(p)
		local chartDataRequest = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ChartDataRequest")

		for i = 1, 14 do
			local success, result = pcall(chartDataRequest.InvokeServer, chartDataRequest, p)

			if success then
				if type(result) == "table" then
					return result
				end

				if result == false then
					error("[ChartRemoteClient] chart tidak ada di server: " .. tostring(p), 0)
				end
			end

			task.wait((math.min(i * 0.6, 2.5)))
		end

		error("[ChartRemoteClient] gagal mengambil chart: " .. tostring(p), 0)
	end
}