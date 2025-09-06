local ServerStorage = game:GetService("ServerStorage")

local Utils = ServerStorage.Utils

local PlayerDataUtils = Utils.PlayerDataUtils

local ProfileManager = require(PlayerDataUtils.ProfileManager)

return {
	
	--[[
		How to add functions:
	
		Copy the example below and paste it where it says "Add new functions here" 
		Edit the comment to your product name, the id (between []), the parameters and the function to your liking
		You're done!
	
		Example:
		
		-- +150 cash
		[1234567890] = function(player: Player, receiptInfo: { PurchaseId: number, PlayerId: number, ProductId: number, PlaceIdWherePurchased: number, CurrencySpent: number, CurrencyType: Enum.CurrencyType, ProductPurchaseChannel: Enum.ProductPurchaseChannel })
			ProfileManager:adjustCash(player, 150)
		end,
	
	]]
	
	-- Add new functions here
}
