local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Utils = ServerStorage.Utils
local MonetizationUtils = Utils.MonetizationUtils

local GamepassManager = require(MonetizationUtils.GamepassManager)
local ProductManager = require(MonetizationUtils.ProductManager)

local SharedEvents = ReplicatedStorage.SharedEvents

local Remotes = SharedEvents.Remotes

local Internals = {}
local MonetizationService = {}

function MonetizationService.OnStart()
	Remotes.RequestGamepass.OnServerEvent:Connect(Internals.RequestGamepass)
	Remotes.RequestProduct.OnServerEvent:Connect()
	
	Remotes.HasGamepass.OnServerInvoke = Internals.HasGamepass
end

function Internals.RequestGamepass(player: Player, gamepassName: string)
	GamepassManager:PromptPurchase(player, gamepassName)
end

function Internals.RequestProduct(player: Player, productName: string)
	ProductManager:HandleProductRequest(player, productName)
end

function Internals.HasGamepass(player: Player, gamepassName: string): boolean
	return GamepassManager:HasGamepass(player, gamepassName)
end

return MonetizationService
