local ServerStorage = game:GetService("ServerStorage")

local Utils = ServerStorage.Utils

local PlayerDataUtils = Utils.PlayerDataUtils

local ProfileManager = require(PlayerDataUtils.ProfileManager)

local GamepassList = {}

GamepassList.Names = {
	--[[
		How to add new gamepasses
		
		1. Copy the template below and change "GamepassName" and "1234567890" to your gamepass name and id (Keep the quotes for the id!)
		2. Paste it where it says "Add new gamepasses here"
		3. Add the function to GamepassList.Functions
		
		GamepassName = "1234567890",
	]]
	
	-- Add new gamepasses here
}

function GamepassList.GetGamepassId(name: string): string
	return GamepassList.Names[name]
end

GamepassList.Functions = {
	--[[
		How to add new gamepass functions
		
		1. Copy the template below and change id in the [] to your gamepass id (Keep the quotes!)
		2. Change the function to your liking
		3. Paste it where it says "Add new gamepasse functions here"
		
		-- VIP
		["1234567890"] = function(player: Player)
			print("VIP gamepass awarded")
			ProfileManager:adjustCash(player, 500)
		end,
	]]

	-- Add new gamepasse functions here
}

return GamepassList
