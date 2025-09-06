local Eastpac = {}
Eastpac.__index = Eastpac

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local DevSettings = require(ServerStorage.DevSettings)

local Events = ServerStorage.Events
local Utils = ServerStorage.Utils

local SharedEvents = ReplicatedStorage.SharedEvents
local SharedUtils = ReplicatedStorage.SharedUtils

local PhoneStatusTracker = require(script.Parent.Parent.PhoneStatusTracker)
local ProfileManager = require(Utils.PlayerDataUtils.ProfileManager)
local playerPfps = require(SharedUtils.PlayerUtils.PlayerPfps)

export type Eastpac = typeof(setmetatable(
	{} :: {
		player: Player,
		visual: Frame,
		accounts: {
			Savings: {
				Balance: number, 
				Transactions:{}
			}, 
			Spending: {
				Balance: number, 
				Transactions:{}
			}
		}
	},
	Eastpac
))

--[[ CONFIDENTIAL LOGIC HIDDEN ]]
-- normalizeCashAmount: Formats numbers to readable strings, handling negative values cleanly.
-- openTab: Handles tab switching in the phone app UI.
-- setupTransactions: Builds and populates a scrolling list of transactions from JSON data.
-- setupRecentTransactions: Loads and displays recent transactions on the home screen.
-- clearTransactions: Removes transaction UI elements from a given list.
-- setupAccountList: Dynamically builds the UI for all player accounts and their balances.
-- addListeners: Hooks up UI buttons for navigation between screens.
-- getAccountName: Finds the display name for a given account table.

function Eastpac.new(player: Player): Eastpac?
	local playerGui = player.PlayerGui
	local phoneGui = playerGui:WaitForChild("PhoneGui")

	local main = phoneGui.Main
	local appVisual
	for i, frame in main.PhoneFrame.Screen.AppFolder:GetChildren() do
		if not frame:IsA("Frame") or frame.Name ~= script.Name then continue end
		appVisual = frame
	end

	if appVisual == nil then 
		warn(`[Eastpac]: No app visual found.`) 
		return 
	end
	
	local accounts = ProfileManager:getPlayerAccounts(player)
	if accounts == {} then
		warn(`[Eastpac]: No accounts found for {player.Name}.`)
		return 
	end

	local self = {
		player = player,
		visual = appVisual,
		accounts = accounts
	}

	setmetatable(self, Eastpac)
	addListeners(self)
	
	if DevSettings.DEV_DEBUG then
		print(`[Eastpac]: Initializing for {player.Name}.`)
		print(self)
	end
	
	self:launch()

	return self
end

function Eastpac:launch(): ()	
	local tabs = self.visual.Tabs
	tabs.Home.ProfilePicture.Image = playerPfps:GetPlayerPfp(
		self.player, 
		Enum.ThumbnailType.HeadShot, 
		Enum.ThumbnailSize.Size420x420
	)
	tabs.Home.Greetings.Text = `Hi, {self.player.Name}`
	tabs.Home.SmartAccess.QuickBalance.Text = normalizeCashAmount(self.accounts.Spending.Balance) or 0
	tabs.Home.SmartAccess.AccountName.Text = getAccountName(self.accounts, self.accounts.Spending) or "Unavailable"

	setupRecentTransactions(self)
end

return Eastpac
