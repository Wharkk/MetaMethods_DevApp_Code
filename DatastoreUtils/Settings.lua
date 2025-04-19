local templates = script.Parent.Templates

local module = {
	DatastoreName = "dev", -- The datastore name, 
	--[[
	Options:
	- prod: when publishing the game for an official release
	- test: when hosting testing sessions with testers
	- dev: when doing local testing
	]]
	
	Template = require(templates.DevDataTemplate), -- The template to use for the current datastore
	KickMessage = { -- Kick messages when there is an error with the database
		DataNotFound = "There was an error while loading your data. If the issue persists, contact us through our community server.",
		DataLoadedElsewhere = "There was an error while loading your data. If the issue persists, contact us through our community server."
	},
	DefaultAccount = "Savings" -- The default account used when giving cash to a player if no accounts are specified
}

return module
