local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local Libraries = ServerStorage.Libraries
local Utils = ServerStorage.Utils
local Events = ServerStorage.Events

local CompanyUtils = Utils.CompanyUtils

local SharedEvents = ReplicatedStorage.SharedEvents

local ProfileService = require(Libraries.ProfileService)

local CompanyManager = require(CompanyUtils.CompanyManager)
local Settings = require(script.Parent.Settings)

local Enums = require(ReplicatedStorage.Enums)

local PROFILE_STORE = ProfileService.GetProfileStore(Settings.DATASTORE_NAME, Settings.TEMPLATE)
local profiles = {}

local Internals = {}
local ProfileManager = {}

--[[ Basic profile management ]]
function ProfileManager:SetProfile(player: Player, profile: {})
	profiles[player] = profile
end

function ProfileManager:getProfile(player: Player): {}
	return profiles[player]
end

function ProfileManager:clearProfileReference(player: Player)
	profiles[player] = nil
end

function ProfileManager:getProfileStore()
	return PROFILE_STORE
end

--[[ Showcase function: shows handling of player/company cash adjustments ]]
function ProfileManager:adjustCash(recipient: Player | string, amount: number, account: string?)
	if type(recipient) == "string" then
		local isValidCompany = CompanyManager:validateCompanyName(recipient)
		if not isValidCompany then return end
		
		CompanyManager:adjustCompanyEarnings(recipient, amount)
		return
	end
	
	local profile = self:getProfile(recipient)
	if not profile then return end
	
	local account = profile.Data.Accounts[account] or profile.Data.Accounts[Settings.DEFAULT_ACCOUNT]
	account.Balance += amount
end

--[[ Showcase function: shows transaction creation and company/player integration ]]
function ProfileManager:registerTransaction(sender: Player | string, recipient: Player | string, amount: number, senderAccountName: Enums.CompanyBankAccountTypeEnum | Enums.BankAccountTypeEnum, recipientAccountName: Enums.CompanyBankAccountTypeEnum | Enums.BankAccountTypeEnum, transactionName: string)
	local senderProfile, senderType, senderName = Internals:resolveActor(sender)
	local recipientProfile, recipientType, recipientName = Internals:resolveActor(recipient)
	
	if not senderProfile and not recipientProfile then return end
	local senderTransactions = senderProfile.Data.Accounts[senderAccountName].Transactions
	local recipientTransactions = recipientProfile.Data.Accounts[recipientAccountName].Transactions

	local isNegative = amount < 0
	local senderAmount = isNegative and amount or -amount
	local recipientAmount = isNegative and math.abs(amount) or amount
	
	table.insert(senderTransactions, Internals:makeTransaction(senderTransactions, 
		{
			name = transactionName, 
			amount = senderAmount, 
			sender = senderName, 
			recipient = recipientName
		})
	)
	table.insert(recipientTransactions, Internals:makeTransaction(recipientTransactions, 
		{
			name = transactionName, 
			amount = recipientAmount, 
			sender = senderName, 
			recipient = recipientName
		})
	)
	
	if senderType == "company" then
		CompanyManager:adjustCompanyExpenditure(sender, math.abs(amount))
	else
		self:adjustCash(sender, senderAmount, senderAccountName)
	end

	if recipientType == "company" then
		CompanyManager:adjustCompanyEarnings(recipient, math.abs(amount))
	else
		self:adjustCash(recipient, recipientAmount, recipientAccountName)
	end
end

--[[ CONFIDENTIAL LOGIC HIDDEN ]]
-- getPlayerRecentTransactions: Retrieves and sorts a player’s recent transactions (limit default 15).
-- getPlayerTransactions: Retrieves all transactions for a specific account.
-- getPlayerAccounts: Returns all accounts and balances for a player.
-- clearTransactions: Clears transactions and optionally resets balances for one or all accounts.
-- Internals:generateTransactionID: Creates unique transaction IDs.
-- Internals:getName: Returns the display name for a player or company.
-- Internals:resolveActor: Determines if the actor is a player or company and fetches profile info.
-- Internals:makeTransaction: Encodes transaction data as JSON.

return ProfileManager
