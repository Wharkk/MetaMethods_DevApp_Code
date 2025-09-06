local Players = game:GetService("Players")

local PlayerSettings = require(script.Parent.PlayerSettings)

local playerAvatarCache = {}
local PlayerPfps = {}

function PlayerPfps:GetPlayerPfp(player: Player, thumbnailType: Enum.ThumbnailType?, thumbnailSize: Enum.ThumbnailSize?): string
	if playerAvatarCache[player.UserId] then return playerAvatarCache[player.UserId] end
	
	local userId = player.UserId
	
	thumbnailType = thumbnailType or Enum.ThumbnailType.HeadShot
	thumbnailSize = thumbnailSize or Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize)

	local startingTime = tick()
	repeat task.wait() until isReady or tick() - startingTime >= PlayerSettings.AVATAR_READY_TIMEOUT
	
	playerAvatarCache[player.UserId] = if isReady then content else PlayerSettings.PLACEHOLDER_IMAGE

	return if isReady then content else PlayerSettings.PLACEHOLDER_IMAGE
end

return PlayerPfps
