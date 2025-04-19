local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

local events = ReplicatedStorage.Events
local tweenUtils = ReplicatedStorage.TweenUtils
local keybindUtils = ReplicatedStorage.KeybindUtils
local playerUtils = ReplicatedStorage.PlayerUtils

local tweenBinds = require(tweenUtils.TweenBinds)
local tweenInfoConfig = require(tweenUtils.TweenInfoConfig)
local keybinds = require(keybindUtils.Keybinds)
local controllerButtonBinds = require(keybindUtils.ControllerButtonBinds)
local playerPlatform = require(playerUtils.PlayerPlatform)

local remotes = events.Remotes

repeat task.wait() until player.Character

local playerPlatform = playerPlatform:GetPlayerPlatform(player)

local phoneUI = player.PlayerGui:WaitForChild("PhoneGUI"):FindFirstChild(playerPlatform)

local debounce = false

phoneUI.Visible = true
phoneUI.PhoneHandler.Enabled = true

local function openPhone(actionName: string, inputState: Enum.UserInputState, inputObject: any)
	if debounce then return end
	
	if inputState == Enum.UserInputState.Begin then
		debounce = true
		
		if phoneUI.Position.Y.Scale > 1 then
			remotes.OpenPhone:FireServer(false)
			local tween = tweenBinds:GetTween(phoneUI, tweenInfoConfig.Phone.Open, {Position = UDim2.fromScale(0.5, 0.5)})
			tween:Play()
			tween.Completed:Wait()
			
			debounce = false
			return
		end
		
		remotes.OpenPhone:FireServer(true)
		local tween = tweenBinds:GetTween(phoneUI, tweenInfoConfig.Phone.Close, {Position = UDim2.fromScale(0.5, 1.5)})
		tween:Play()
		tween.Completed:Wait()
		
		debounce = false
	end
end

ContextActionService:BindAction("OpenPhone", openPhone, true, keybinds.Phone, controllerButtonBinds.Phone)
ContextActionService:SetPosition("OpenPhone", UDim2.fromScale(0.45, 0.3))
