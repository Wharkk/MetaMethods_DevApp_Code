local UserInputService = game:GetService("UserInputService")

local playerBinds = require(script.Parent.PlayerBinds)

local playerPlatform = {}

local platforms = {}

function playerPlatform:GetPlayerPlatform(player: Player): string
	return platforms[player]
end

local function setPlayerPlatform(player: Player)
	if UserInputService.KeyboardEnabled then
		platforms[player] = "pc"

	elseif UserInputService.TouchEnabled then
		platforms[player] = "mobile"

	elseif UserInputService.GamepadEnabled then
		platforms[player] = "console"
	end
end

local function removingPlayerPlatform(player: Player)
	platforms[player] = nil
end

playerBinds:BindFunctionToPlayer(setPlayerPlatform)
playerBinds:BindFunctionToRemovingPlayer(removingPlayerPlatform)

return playerPlatform
