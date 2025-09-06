local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DevSettings = require(ServerStorage.DevSettings)

local Utils = ServerStorage.Utils

local PlayerDataUtils = Utils.PlayerDataUtils

local SharedEvents = ReplicatedStorage.SharedEvents

local ProfileManager = require(PlayerDataUtils.ProfileManager)
local GamepassList = require(script.GamepassList)

local Remotes = SharedEvents.Remotes

local Internals = {}
local GamepassManager = {}

function GamepassManager:PromptPurchase(player: Player, name: string)	
	local profile = ProfileManager:getProfile(player)
	if not profile then return end
	
	local passId: string = GamepassList.GetGamepassId(name)
	if passId == nil then return end
	
	-- Check if player owns gamepass from profile (not using MarketplaceService to allow gifted gamepasses)
	local hasPass = profile.Data.Gamepasses[passId].owned
	
	if DevSettings.DEV_DEBUG then
		print(`[{script.Name}]: {player.Name} requested gamepass {name} | owned: {hasPass}`)
	end
	
	if not hasPass then
		local success, errorMessage = pcall(function()
			hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, tonumber(passId))
		end)
		
		if not success then
			warn(`[{script.Name}]: There was an error checking if {player.Name} owns the gamepass: {name}. Error message: {errorMessage}`)
			return	
		end
		
		if hasPass then return end
		
		Remotes.ProductPurchaseStatus:FireClient(player, "Begin")
		
		MarketplaceService:PromptGamePassPurchase(player, tonumber(passId))
	end
	
	-- Re-sync gamepass data
	GamepassManager:UpdateOwnershipData(player)
end

function GamepassManager:OnPromptPurchaseFinished(player: Player, gamepassId: number, wasPurchased: boolean)
	if not wasPurchased then
		Remotes.ProductPurchaseStatus:FireClient(player, "End")
		return 
	end
	
	gamepassId = tostring(gamepassId)
	Remotes.ProductPurchaseStatus:FireClient(player, "Success")
	
	local profile = ProfileManager:getProfile(player)
	if not profile then return end
	
	profile.Data.Gamepasses[gamepassId].owned = true
	
	local awardFunction = GamepassList.Functions[gamepassId]
	if awardFunction == nil then 
		warn(`[{script.Name}]: No awardFunction found for gamepass: {gamepassId}`) 
		return 
	end
	
	awardFunction(player)
	profile.Data.Gamepasses[gamepassId].awarded = true
end

function GamepassManager:UpdateOwnershipData(player: Player)
	local profile = ProfileManager:getProfile(player)
	if not profile then return end
	
	for passId: string, awardFunction in GamepassList.Functions do
		local hasPass = profile.Data.Gamepasses[passId].owned
		local hasPassBeenAwarded = profile.Data.Gamepasses[passId].awarded
		if hasPassBeenAwarded then continue end
		
		if not hasPass then
			local success, errorMessage = pcall(function()
				hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, tonumber(passId))
			end)
			
			if not success then
				warn(`[{script.Name}]: There was an error checking if {player.Name} owns the gamepass: {passId}. Error message: {errorMessage}`)
				continue
			end
			
			if not hasPass then
				continue
			end
		end
		
		profile.Data.Gamepasses[passId].owned = true
		awardFunction(player)
		profile.Data.Gamepasses[passId].awarded = true
	end
end

function GamepassManager:HasGamepass(player: Player, gamepassName: string): boolean
	local passId: string = GamepassList.GetGamepassId(gamepassName)
	if passId == nil then return false end

	local profile = ProfileManager:getProfile(player)
	if profile == nil then return false end

	local hasPass = profile.Data.Gamepasses[passId].owned
	if hasPass then return true end

	local success, errorMessage = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, tonumber(passId))
	end)

	if not success then
		warn(`[{script.Name}]: There was an error checking if {player.Name} owns the gamepass: {passId}. Error message: {errorMessage}`)
		return false
	end

	return hasPass
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(...)
	GamepassManager:OnPromptPurchaseFinished(...)
end)

return GamepassManager
