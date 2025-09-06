local ServerStorage = game:GetService("ServerStorage")

local Utils = ServerStorage.Utils

local CompanyUtils = Utils.CompanyUtils

local CompanyManager = require(CompanyUtils.CompanyManager)

local Internals = {}
local CompaniesService = {}

function CompaniesService.OnStart()	
	CompanyManager:LoadCompanies()
	
	task.spawn(function()
		Internals.autosave()
	end)
	
	game:BindToClose(function()
		CompanyManager:SaveCompanies()
		task.wait(1)
	end)
end

function Internals.autosave()
	while task.wait(300) do
		CompanyManager:SaveCompanies()
	end
end

return CompaniesService
