local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local libraries = ServerStorage.Libraries
local datastoreUtils = ServerStorage.DatastoreUtils
local playerUtils = ReplicatedStorage.PlayerUtils

local ProfileService = require(libraries.ProfileService)

local datastoreSettings = require(datastoreUtils.Settings)
local profileManager = require(datastoreUtils.ProfileManager)

local playerBinds = require(playerUtils.PlayerBinds)

local ProfileStore = ProfileService.GetProfileStore(datastoreSettings.DatastoreName, datastoreSettings.Template)

local function onPlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile == nil then
		player:Kick(datastoreSettings.KickMessage.DataNotFound)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		profileManager:SetProfile(player, nil)
		player:Kick(datastoreSettings.KickMessage.DataLoadedElsewhere)
	end)

	if not player:IsDescendantOf(Players) then profile:Release() return end

	print(profile.Data)
	profileManager:SetProfile(player, profile)
end

local function onPlayerRemoving(player: Player)
	local profile = profileManager:GetProfile(player)
	if not profile then return end
	
	profileManager:SetProfile(player, profile)
	
	profile:Release()
end

playerBinds:BindFunctionToPlayer(onPlayerAdded)
playerBinds:BindFunctionToRemovingPlayer(onPlayerRemoving)
