local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local templates = script.Parent.Templates

local Enums = require(ReplicatedStorage.Enums)

local Settings = {}

-- [AUTO] The datastore name
Settings.DATASTORE_NAME = if RunService:IsStudio() then "dev" else "prod"
--[[
	Options:
	- prod: when publishing the game for any official release (game release or update)
	- dev: when doing developing or doing local testing
]]

-- [AUTO] The template to use for the current datastore
Settings.TEMPLATE = if RunService:IsStudio() then require(templates.DevDataTemplate) else require(templates.ProdDataTemplate)

-- Kick messages when there is an error with the datastore
Settings.KICK_MESSAGE = {
	DATA_NOT_FOUND = "There was an error while loading your data. If the issue persists, contact us through our community server.",
	DATA_LOADED_ELSEWHERE = "There was an error while loading your data. If the issue persists, contact us through our community server."
}

Settings.DEFAULT_ACCOUNT = Enums.BankAccountType.Spending

-- The max cache size for pending developer products
Settings.MAX_CACHE_SIZE = 100


return Settings
