local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local DevSettings = require(ServerStorage.DevSettings)

local Assets = ServerStorage.Assets
local Utils = ServerStorage.Utils

local InteractionAssets = Assets.InteractionAssets

local SharedEvents = ReplicatedStorage.SharedEvents
local SharedUtils = ReplicatedStorage.SharedUtils

local PhoneUtils = Utils.PhoneUtils
local PlayerUtils = SharedUtils.PlayerUtils

local PhoneStatusTracker = require(PhoneUtils.PhoneStatusTracker)
local SoundsSettings = require(InteractionAssets.SoundsSettings)
local PlayerBinds = require(PlayerUtils.PlayerBinds)

local Remotes = SharedEvents.Remotes

local holdingAnimation = {}
local currentApps = {}
local debounce = {}

local Internals = {}
local PhoneService = {}

function PhoneService.OnStart()
	PlayerBinds:BindFunctionToRemovingPlayer(Internals.onPlayerRemoving)
	
	Remotes.OpenPhone.OnServerEvent:Connect(Internals.handlePhoneEquip)
	Remotes.LaunchApp.OnServerEvent:Connect(Internals.launchApp)
	Remotes.CloseApp.OnServerEvent:Connect(Internals.closeApp)
end

function Internals.onPlayerRemoving(player: Player)
	currentApps[player] = nil
	PhoneStatusTracker:clear(player)
end

function Internals.handlePhoneEquip(player: Player, isOpened: boolean)
	local character = player.Character or player.CharacterAdded:Wait()
	local animator = character.Humanoid:FindFirstChildOfClass("Animator")

	if holdingAnimation[player.Name] == nil then
		holdingAnimation[player.Name] = animator:LoadAnimation(InteractionAssets.Animations.HoldingPhone)
	end

	if not isOpened then
		local newPhone = InteractionAssets.Objects.Phone:Clone()

		local motor6D = Instance.new("Motor6D")
		motor6D.Name = "PhoneMotor6D"
		motor6D.Parent = character.RightHand
		motor6D.Part0 = character.RightHand
		motor6D.Part1 = newPhone

		newPhone.Parent = player.Character
		SoundsSettings.Phone.PhoneOut:Play()
		holdingAnimation[player.Name]:Play()

		debounce[player.Name] = false
		return
	end

	holdingAnimation[player.Name]:Stop()
	SoundsSettings.Phone.PhoneIn:Play()
	character:FindFirstChild("Phone"):Destroy()
	character.RightHand:FindFirstChild("PhoneMotor6D"):Destroy()

	debounce[player.Name] = false
end

function Internals.launchApp(player: Player, appName: string)
	if not PhoneStatusTracker:isHomeActive(player) then
		warn(`[{script.Name}]: An app is already open`)
		return
	end

	local app = PhoneUtils.Apps:FindFirstChild(appName)
	if not app or not app:IsA("ModuleScript") then
		warn(`[{script.Name}]: Could not find matching module for app {appName}]`)
		return
	end

	local appModule = require(app)
	local appInstance = appModule.new(player)
	if not appInstance then
		warn(`[{script.Name}]: Failed to instantiate app {appName}`)
		return
	end

	currentApps[player] = appInstance
	PhoneStatusTracker:setHomeActive(player, false)
	
	if DevSettings.DEV_DEBUG then
		print(`[{script.Name}]: Home status: {PhoneStatusTracker:isHomeActive(player) and "active" or "inactive"}`)
		print(`[{script.Name}]: Current app: {currentApps[player]}`)
	end
end

function Internals.closeApp(player: Player)
	PhoneStatusTracker:setHomeActive(player, true)
end

return PhoneService
