local Players = game:GetService("Players")

local playerSettings = require(script.Parent.PlayerSettings)

local playerPfps = {}

function playerPfps:GetPlayerPfp(player: Player, thumbnailType: Enum.ThumbnailType?, thumbnailSize: Enum.ThumbnailSize?): string
	if playerPfps[player] then return playerPfps[player] end
	
	local userId = player.UserId
	
	thumbnailType = thumbnailType or Enum.ThumbnailType.HeadShot
	thumbnailSize = thumbnailSize or Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize)

	local currentTime = tick()
	repeat task.wait() until isReady or tick() - currentTime >= playerSettings.PfpReadyTimeout
	
	playerPfps[player] = content

	return content or playerSettings.PlaceholderImage
end

return playerPfps
