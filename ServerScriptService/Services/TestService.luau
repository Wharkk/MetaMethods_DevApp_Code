local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DevSettings = require(ServerStorage.DevSettings)

local Utils = ServerStorage.Utils

local PlayerDataUtils = Utils.PlayerDataUtils
local CompanyUtils = Utils.CompanyUtils

local ProfileManager = require(PlayerDataUtils.ProfileManager)
local CompanyManager = require(CompanyUtils.CompanyManager)

local SharedUtils = ReplicatedStorage.SharedUtils
local PlayerUtils = SharedUtils.PlayerUtils

local PlayerBinds = require(PlayerUtils.PlayerBinds)
local Enums = require(ReplicatedStorage.Enums)

local Internals = {}
local TestService = {}

function TestService.OnStart()
	if not DevSettings.DEV_DEBUG then return end
	
	PlayerBinds:BindFunctionToPlayer(Internals.onPlayerAdded)
end

function Internals.onPlayerAdded(player: Player)
	task.wait(5)

	local profile = ProfileManager:getProfile(player)
	if not profile then return end

	ProfileManager:clearTransactions(player, true, true)

	task.wait(0.5)

	ProfileManager:adjustCash(player, 200, "Spending")
	warn(`[{script.Name}]: [OK] Added 200 cash to the Spending account.`)

	CompanyManager:clearTransactions("Ausverse Motorsport", true)
	CompanyManager:adjustCompanyEarnings("Ausverse Motorsport", 200)
	ProfileManager:registerTransaction(player, "Ausverse Motorsport", -150, Enums.BankAccountType.Spending, Enums.CompanyBankAccountTypeEnume.Spending, "Purchased a car")
	warn(`[{script.Name}]: [OK] Transaction registered.`)
	print(profile.Data.Accounts.Spending.Transactions[#profile.Data.Accounts.Spending.Transactions])
	print(CompanyManager:getTransactions("Ausverse Motorsport")[#CompanyManager:getTransactions("Ausverse Motorsport")])

	ProfileManager:registerTransaction("Ausverse Motorsport", player, 250, Enums.BankAccountType.Spending, Enums.CompanyBankAccountTypeEnume.Spending, "Paycheck")
	warn(`[{script.Name}]: [OK] Transaction registered.`)
	print(profile.Data.Accounts.Spending.Transactions[#profile.Data.Accounts.Spending.Transactions])
	print(CompanyManager:getTransactions("Ausverse Motorsport")[#CompanyManager:getTransactions("Ausverse Motorsport")])

	CompanyManager:clearTransactions("Ausverse Groceries", true)
	CompanyManager:adjustCompanyEarnings("Ausverse Groceries", 200)
	ProfileManager:registerTransaction(player, "Ausverse Groceries", -50, Enums.BankAccountType.Spending, Enums.CompanyBankAccountTypeEnume.Spending, "Purchased some groceries")
	warn(`[{script.Name}]: [OK] Transaction registered.`)
	print(profile.Data.Accounts.Spending.Transactions[#profile.Data.Accounts.Spending.Transactions])
	print(CompanyManager:getTransactions("Ausverse Groceries")[#CompanyManager:getTransactions("Ausverse Groceries")])
end

return TestService
