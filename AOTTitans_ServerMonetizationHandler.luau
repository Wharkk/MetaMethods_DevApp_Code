local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local events = ReplicatedStorage.Events

local remotes = events.Remotes
local serverConfig = ServerStorage.ServerConfig
local modules = ReplicatedStorage.Modules

local showMessageRemote = remotes.ShowMessage
local monetizationConfig = require(serverConfig.MonetizationConfig)
local showMessage = require(modules.ShowMessage)

remotes.GetGamepasses.OnServerInvoke = function()
	return monetizationConfig.Gamepasses
end

local function findCurrency(player: Player, currencyName: string): NumberValue|IntValue
	for i, value in ipairs(player.DataStore:GetDescendants()) do
		if value:IsA("Folder") then continue end

		if value.Name == currencyName then 
			return value 
		end
	end
end

local function applyGamepassPerk(player, gamepassId)
	local gamepassInfo = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
	local gamepassName = gamepassInfo.Name

	if string.lower(gamepassName):find("vip") then
		player:SetAttribute("VIP", true)

	elseif string.lower(gamepassName):find("x2 xp") then
		player:SetAttribute("DoubleXP", true)

	elseif string.lower(gamepassName):find("x2 tokens") then
		player:SetAttribute("DoubleTokens", true)
	end
end

Players.PlayerAdded:Connect(function(player)
	for name, gamepassId in pairs(monetizationConfig.Gamepasses) do
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId) then
			applyGamepassPerk(player, gamepassId)
		end
	end
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(playerId, productId, isPurchased)
	local player = game.Players:GetPlayerByUserId(playerId)
	if isPurchased and player then
		local productInfo = MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
		local productName = productInfo.Name

		local rewardAmount, rewardType = string.match(productName, "[+-]?(%d+)%s*(%a+)")
		if rewardType and rewardAmount then
			local stat = findCurrency(player, rewardType)
			if stat then
				stat.Value += tonumber(rewardAmount)
				showMessageRemote:FireClient(player, true)
			else
				showMessageRemote:FireClient(player, false)
			end
		end
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	local player = game.Players:GetPlayerByUserId(player.UserId)
	if wasPurchased and player then
		applyGamepassPerk(player, gamePassId)
		showMessageRemote:FireClient(player)
	end
end)

remotes.BuyDeveloperProduct.OnServerEvent:Connect(function(player, productId)
	MarketplaceService:PromptProductPurchase(player, productId)
end)

remotes.BuyGamepass.OnServerEvent:Connect(function(player, productId)
	MarketplaceService:PromptGamePassPurchase(player, productId)
end)
