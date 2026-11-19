local ContentProvider = game:GetService("ContentProvider")

local function tryPreload(sound) -- 1 equivalent call inferred from this helper
	task.spawn(function()
		local count = 0

		while sound.Parent do
			count += 1
			local v = nil
			local success, result = pcall(function()
				ContentProvider:PreloadAsync({ sound }, function(_, p)
					v = p
				end)
			end)

			if success and v == Enum.AssetFetchStatus.Success then
				break
			end

			if count <= 15 or count % 6 == 0 then
				warn(("[SegmentedStemPreloader] preload %s percobaan %d belum sukses (status=%s%s) -- retry otomatis sampai berhasil"):format(
					sound:GetFullName(),
					count,
					tostring(v),
					success and "" or " pcallErr=" .. tostring(result)
				))
			end

			task.wait(count < 15 and 2 or 10)
		end
	end)
end

local function onDescendantAdded(sound) -- 1 equivalent call inferred from this helper
	if sound:IsA("Sound") and sound.Name:sub(-8) == "_Pending" then
		tryPreload(sound) -- inferred equivalent call
	end
end

workspace.DescendantAdded:Connect(onDescendantAdded)

for _, descendant in ipairs(workspace:GetDescendants()) do
	onDescendantAdded(descendant) -- inferred equivalent call
end