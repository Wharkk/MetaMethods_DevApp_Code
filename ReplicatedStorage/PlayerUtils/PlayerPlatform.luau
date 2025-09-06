local UserInputService = game:GetService("UserInputService")

local PlayerBinds = require(script.Parent.PlayerBinds)

local platforms = {}

local Internals = {}
local PlayerPlatform = {}

function PlayerPlatform:GetPlayerPlatform(player: Player): string
	return platforms[player]
end

function PlayerPlatform:setPlayerPlatform(player: Player)
	if UserInputService.KeyboardEnabled then
		platforms[player] = "pc"

	elseif UserInputService.TouchEnabled then
		platforms[player] = "mobile"

	elseif UserInputService.GamepadEnabled then
		platforms[player] = "console"
	end
end

function PlayerPlatform:removePlayerPlatform(player: Player)
	platforms[player] = nil
end

return PlayerPlatform
