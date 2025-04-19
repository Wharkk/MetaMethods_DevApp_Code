local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage.Events

local remotes = events.Remotes

local datastoreSettings = require(script.Parent.Settings)

local profileManager = {}

local profiles = {}

local function generateTransactionID(transactions: {}): string
	local timestamp = os.time()
	local number = #transactions + 1
	
	return string.format("TX-%d-%d", timestamp, number)
end

local function getName(actor: Player | string)
	if typeof(actor) == "Instance" then 
		return actor.Name 
	end
	
	return actor
end

function profileManager:GetProfile(player: Player): {}
	return profiles[player]
end

function profileManager:SetProfile(player: Player, profile: {}?)
	profiles[player] = profile
end

function profileManager:AdjustCash(player: Player, amount: number, account: string?)
	local profile = self:GetProfile(player)
	if not profile then return end
	
	local account = profile.Data.Accounts[account] or profile.Data.Accounts[datastoreSettings.DefaultAccount]
	account.Balance += amount
end

function profileManager:RegisterTransaction(sender: Player | string, amount: number, recipient: Player | string, account: string, transactionName: string)
	local senderProfile = self:GetProfile(sender)
	local recipientProfile = self:GetProfile(recipient)
	if not senderProfile and not recipientProfile then return end
	
	local profile = senderProfile or recipientProfile
	
	local transactions = profile.Data.Accounts[account].Transactions
	local transaction = {
		id = generateTransactionID(transactions),
		name = transactionName,
		amount = amount,
		sender = getName(sender),
		recipient = getName(recipient)
	}
	
	table.insert(transactions, HttpService:JSONEncode(transaction))
	
	if senderProfile then
		profileManager:AdjustCash(sender, amount, account)
		return
	end
	
	profileManager:AdjustCash(recipient, amount, account)
end

function profileManager:GetPlayerRecentTransactions(player: Player, limit: number?): {}
	local profile = self:GetProfile(player)
	if not profile then return {} end
	
	local transactions = {}
	for i, account in ipairs(profile.Data.Accounts) do
		for i, transactionJSON in ipairs(account.Transactions) do
			local transaction = HttpService:JSONDecode(transactionJSON)
			if transaction and transaction.id then
				table.insert(transactions, transaction)
			end
		end
	end

	table.sort(transactions, function(a, b)
		local aTimestamp = tonumber(string.match(a.id, "TX%-(%d+)%-%d+")) or 0
		local bTimestamp = tonumber(string.match(b.id, "TX%-(%d+)%-%d+")) or 0
		return aTimestamp > bTimestamp
	end)
	
	if limit and limit > 0 then
		return table.move(transactions, 1, math.min(limit, #transactions), 1, {})
	end

	return transactions
end

function profileManager:GetPlayerTransactions(player: Player, accountName: string?): {}
	local profile = self:GetProfile(player)
	if not profile then return {} end
	
	local account = profile.Data.Accounts[accountName] or profile.Data.Accounts[datastoreSettings.DefaultAccount]
	local transactions = account.Transactions
	
	return transactions
end

function profileManager:GetPlayerAccounts(player: Player): {}
	local profile = self:GetProfile(player)
	if not profile then return {} end
	
	return profile.Data.Accounts
end

function profileManager:ClearTransactions(player: Player, all: boolean, clearCash: boolean?, account: string?)
	local profile = self:GetProfile(player)
	if not profile then return end
	
	clearCash = clearCash or false
	
	if all then
		local accounts = profile.Data.Accounts
		table.clear(accounts.Savings.Transactions)
		table.clear(accounts.Spending.Transactions)
		
		if not clearCash then print("[OK] Successfully cleared all transactions.") return end
		
		accounts.Savings.Balance = 0
		accounts.Spending.Balance = 0
		
		print("[OK] Successfully cleared all transactions and cash.")
		
		return
	end
	
	local account = profile.Data.Accounts[account] or profile.Data.Accounts[datastoreSettings.DefaultAccount]
	local transactions = account.Transactions
	table.clear(transactions)
	
	if not clearCash then print(`[OK] Successfully cleared transactions from the {account} account.`) return end
	
	local cash = account.Balance
	cash = 0
	
	print(`[OK] Successfully cleared cash and transactions from the {account} account.`)
end

remotes.GetPlayerAccounts.OnServerInvoke = function(player: Player): {}
	return profileManager:GetPlayerAccounts(player)
end

remotes.GetPlayerRecentTransactions.OnServerInvoke = function(player: Player, limit: number?): {}
	return profileManager:GetPlayerRecentTransactions(player, limit)
end

return profileManager
