local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage.SharedEvents.Remotes
local SharedUtils = ReplicatedStorage.SharedUtils

local KeybindUtils = SharedUtils.KeybindUtils
local PlayerUtils = SharedUtils.PlayerUtils
local TweenUtils = SharedUtils.TweenUtils

local ControllerButtonBinds = require(KeybindUtils.ControllerButtonBinds)
local PlayerPlatform = require(PlayerUtils.PlayerPlatform)
local TweenSettings = require(TweenUtils.TweenSettings)
local Keybinds = require(KeybindUtils.Keybinds)

local PhoneGui = player.PlayerGui:WaitForChild("PhoneGui")
local Main = PhoneGui.Main

local Screen = Main.PhoneFrame.Screen
local Home = Screen.Home
local AppFolder = Screen.AppFolder

local Internals = {}
local PhoneController = {}

--[[ Showcase function: shows binding input actions and initializing phone UI ]]
function PhoneController.OnStart()	
	ContextActionService:BindAction("OpenPhone", Internals.handlePhoneEquip, true, Keybinds.Phone, ControllerButtonBinds.Phone)
	ContextActionService:SetPosition("OpenPhone", UDim2.fromScale(0.45, 0.3))
	ContextActionService:SetTitle("OpenPhone", "Phone")
	ContextActionService:SetDescription("OpenPhone", "Opens the phone")
	
	Internals.resetPhone()
	Internals.storeAppsOriginalPosition()
	Internals.InitMainApps()
	Internals.InitBottomApps()
	Internals.InitHomeButton()
	
	task.wait()
	Internals.InitPhonePosition()
end

--[[ CONFIDENTIAL LOGIC HIDDEN ]]
-- Internals.InitPhonePosition: Adjusts phone position for mobile players.
-- Internals.InitMainApps / InitBottomApps: Hooks up app buttons to open their respective frames.
-- Internals.InitHomeButton: Hooks up the home button to close the current app.
-- Internals.handlePhoneEquip: Handles opening/closing the phone with animation and debouncing.
-- Internals.storeAppsOriginalPosition: Stores the original UI positions of all apps.
-- Internals.tweenApp: Animates opening of an app.
-- Internals.DisableAppIcons / EnableAppIcons: Toggles app button interactivity.
-- Internals.resetPhone: Resets the phone to its initial position and size.
-- Internals.closeCurrentApp: Closes the currently active app and restores UI state.

return PhoneController
