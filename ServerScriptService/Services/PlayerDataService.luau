local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local DevSettings = require(ServerStorage.DevSettings)

local Libraries = ServerStorage.Libraries
local Utils = ServerStorage.Utils

local PlayerDataUtils = Utils.PlayerDataUtils
local PhoneUtils = Utils.PhoneUtils

local PhoneStatusTracker = require(PhoneUtils.PhoneStatusTracker)
local ProfileManager = require(PlayerDataUtils.ProfileManager)
local Settings = require(PlayerDataUtils.Settings)

local ProfileStore = ProfileManager:getProfileStore()

local SharedUtils = ReplicatedStorage.SharedUtils
local PlayerUtils = SharedUtils.PlayerUtils

local PlayerBinds = require(PlayerUtils.PlayerBinds)
local PlayerPlatform = require(PlayerUtils.PlayerPlatform)

local Internals = {}
local PlayerData = {}

function PlayerData.OnStart()
	if DevSettings.DEV_DEBUG then
		warn("Debug mode is ON")
	end
	
	PlayerBinds:BindFunctionToPlayer(Internals.onPlayerAdded)
	PlayerBinds:BindFunctionToRemovingPlayer(Internals.onPlayerRemoving)
	
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(Internals.onPlayerAdded, player)
	end
end

function Internals.onPlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile == nil then
		player:Kick(Settings.KICK_MESSAGE.DATA_NOT_FOUND)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		ProfileManager:clearProfileReference(player)
		player:Kick(Settings.KICK_MESSAGE.DATA_LOADED_ELSEWHERE)
	end)

	if not player:IsDescendantOf(Players) then profile:Release() return end

	if DevSettings.DEV_DEBUG then
		print(script.Name, profile.Data)
	end
	
	PlayerPlatform:setPlayerPlatform(player)
	ProfileManager:SetProfile(player, profile)
	PhoneStatusTracker:Init(player)
end

function Internals.onPlayerRemoving(player: Player)
	local profile = ProfileManager:getProfile(player)
	if not profile then return end

	ProfileManager:SetProfile(player, profile)

	profile:Release()
	ProfileManager:clearProfileReference(player)
	PlayerPlatform:removePlayerPlatform(player)
end

return PlayerData
