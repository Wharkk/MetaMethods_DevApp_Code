local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local DevSettings = require(ServerStorage.DevSettings)

local CompaniesStore = DataStoreService:GetDataStore("CompaniesData")

local Settings = require(script.Parent.Settings)

local Internals = {}
local CompanyManager = {}
local companiesAccounts = {}

function CompanyManager:LoadCompanies()
	if DevSettings.DEV_DEBUG then
		print(`[{script.Name}]: Loading companies...`)
	end
	
	local success, data = pcall(function()
		return CompaniesStore:GetAsync("AllCompanies")
	end)

	if success and data then		
		local decoded = HttpService:JSONDecode(data)
		if typeof(decoded) == "table" then
			companiesAccounts = decoded
		end
		
		if DevSettings.DEV_DEBUG then
			print(`[{script.Name}]: Successfully loaded companies`)
			print(companiesAccounts)
		end
	else
		warn(`[{script.Name}] Failed to load companies`)
		
		for _, companyInfo in Settings.AvailableCompanies do
			if DevSettings.DEV_DEBUG then
				print(`[{script.Name}]: Loading default company`)
				print(companyInfo)
			end
			
			CompanyManager:SetUpActiveCompany(companyInfo)
		end
	end
end

function CompanyManager:SaveCompanies()
	if DevSettings.DEV_DEBUG then
		print(`[{script.Name}]: Saving companies...`)
		print(companiesAccounts)
	end
	
	local success, err = pcall(function()
		local jsonData = HttpService:JSONEncode(companiesAccounts)
		CompaniesStore:SetAsync("AllCompanies", jsonData)
	end)
	
	if success then
		if not DevSettings.DEV_DEBUG then return end
		print(`[{script.Name}]: Successfully saved companies`)
	else
		warn(`[{script.Name}]: Failed to save companies: {tostring(err)}`)
	end
end

function CompanyManager:SetUpActiveCompany(companyInfo: {Name: string, Holders: {number}})
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	-- Sets up a company's initial data structure in memory.
end

function CompanyManager:removeActiveCompany(companyName: string)
	companiesAccounts[companyName] = nil
end

function CompanyManager:getCompanyInfo(companyName: string): {}
	return companiesAccounts[companyName]
end

function CompanyManager:getcompanyAccounts(companyName: string): {}
	if companiesAccounts[companyName] == nil then
		return {}
	end
	
	return companiesAccounts[companyName].Data.Accounts
end

function CompanyManager:adjustCompanyEarnings(companyName: string, amount: number)
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	-- Adjusts monthly earnings and recalculates balance.
end

function CompanyManager:getCompanyEarnings(companyName: string): number
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	return 0
end

function CompanyManager:adjustCompanyExpenditure(companyName: string, amount: number)
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	-- Adjusts monthly expenditure and recalculates balance.
end

function CompanyManager:getCompanyExpenditure(companyName: string): number
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	return 0
end

function Internals:adjustCompanyBalance(companyName: string)
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
end

function CompanyManager:getCompanyBalance(companyName: string): number
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	return 0
end

function CompanyManager:registerTransaction(companyName: string, transaction: {id: string, name: string, amount: number, sender: string, recipient: string})
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
end

function CompanyManager:getRecentTransactions(companyName: string, limit: number?): {}
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	return {}
end

function CompanyManager:getTransactions(companyName: string): {}
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
	return {}
end

function CompanyManager:clearTransactions(companyName: string, clearBalance: boolean?)
	--[[ CONFIDENTIAL LOGIC HIDDEN ]]
end

function CompanyManager:validateCompanyName(companyName: string): boolean
	return companiesAccounts[companyName] ~= nil
end

return CompanyManager
