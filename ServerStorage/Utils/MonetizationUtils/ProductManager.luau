local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local DevSettings = require(ServerStorage.DevSettings)

local Utils = ServerStorage.Utils

local PlayerDataUtils = Utils.PlayerDataUtils

local SharedEvents = ReplicatedStorage.SharedEvents

local Remotes = SharedEvents.Remotes

local ProfileManager = require(PlayerDataUtils.ProfileManager)
local ProfileStore = ProfileManager:getProfileStore()
local Settings = require(PlayerDataUtils.Settings)

local ProductFunctions = require(script.ProductFunctions)

local processingReceipts = {}
local developerProducts = {}

local Internals = {}
local ProductManager = {}

function ProductManager:HandleProductRequest(player: Player, productName: string)
	productName = string.gsub(productName, "\u{E002} ", "")
	if #developerProducts == 0 then
		Internals:fetchDeveloperProducts()
	end

	local productId
	for i, page in pairs(developerProducts) do
		for v, product in pairs(page) do
			if product.Name == productName then
				productId = product.ProductId
				break
			end
		end
	end

	Internals:ProductPurchaseRequested(player, productId)
end

function Internals:ProductPurchaseRequested(player: Player, productId: number): ()
	if ProductFunctions[productId] == nil then
		warn(`[{script.Name}]: Product purchase failed for the product: {productId} when {player.Name} ({player.UserId}) tried to purchase it.`)
		return	
	end
	
	Remotes.ProductPurchaseStatus:FireClient(player, "Begin")
	
	MarketplaceService:PromptProductPurchase(player, productId)
end

function Internals:fetchDeveloperProducts(): ()
	do
		local productPages = MarketplaceService:GetDeveloperProductsAsync()
		while true do
			table.insert(developerProducts, productPages:GetCurrentPage())
			if productPages.IsFinished then
				break
			end
			productPages:AdvanceToNextPageAsync()
		end
	end
end

function Internals.PromptProductPurchaseFinished(userId: number, productId: number, isPurchased: boolean)
	local player = Players:GetPlayerByUserId(userId)
	
	if isPurchased then
		Remotes.ProductPurchaseStatus:FireClient(player, "Success")
		return
	end
	
	Remotes.ProductPurchaseStatus:FireClient(player, "End")		
end

-- Waits until purchaseId has been stored in the Profile before confirming ProductPurchaseDecision
function Internals.checkPurchaseIdAsync(userId: number, profile, productId: number, purchaseId: number, grantProductFunction: () -> ()): Enum.ProductPurchaseDecision
	if not profile:IsActive() then return Enum.ProductPurchaseDecision.NotProcessedYet end
	
	local purchaseIdCache = profile.Data.PurchaseIdCache
	if purchaseIdCache == nil then
		purchaseIdCache = {}
		profile.Data.PurchaseIdCache = purchaseIdCache
	end

	local function isPurchaseSaved(profile, purchaseId): boolean
		for _, update in ipairs(profile.GlobalUpdates:GetActiveUpdates()) do
			if update.Data and update.Data.updateType == "Log" then
				return true
			end
		end
		return false
	end

	if isPurchaseSaved(profile, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Periodically check if the purchase Id is saved until it is or the session ends
	local attempts = 0
	while profile:IsActive() and attempts < 5 do
		profile:Save()

		if isPurchaseSaved(profile, purchaseId) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		attempts += 1
		task.wait(2)
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function Internals.ProcessReceipt(receiptInfo)
	local purchaseId = receiptInfo.PurchaseId
	if processingReceipts[purchaseId] then
		warn(`[{script.Name}]: ReceiptId {purchaseId} already being processed.`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	processingReceipts[purchaseId] = true
	
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if player == nil then
		processingReceipts[purchaseId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local profile = ProfileManager:getProfile(player)
	while profile == nil and player.Parent == Players do
		task.wait(1)
		profile = ProfileManager:getProfile(player)
	end

	if profile == nil then
		processingReceipts[purchaseId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if ProductFunctions[receiptInfo.ProductId] == nil then
		warn(`[{script.Name}]: Product purchase failed for the product: {receiptInfo.ProductId} when {player.Name} ({player.UserId}) tried to purchase it.`)
		processingReceipts[purchaseId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success, decision = pcall(Internals.checkPurchaseIdAsync,
		player.UserId,
		profile,
		receiptInfo.ProductId,
		purchaseId,
		function()
			ProductFunctions[receiptInfo.ProductId](receiptInfo, player, profile)
		end
	)

	processingReceipts[purchaseId] = nil
	return decision
end

MarketplaceService.PromptProductPurchaseFinished:Connect(Internals.PromptProductPurchaseFinished)
MarketplaceService.ProcessReceipt = Internals.ProcessReceipt

return ProductManager
