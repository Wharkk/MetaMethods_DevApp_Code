local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local events = ReplicatedStorage.Events

local bindables = events.Bindables
local config = ReplicatedStorage.Config
local modules = ReplicatedStorage.Modules

local tweenConfig = require(config.TweenConfig)
local menuConfig = require(config.MenuConfig)
local showMessage = require(modules.ShowMessage)
local showBlackScreen = require(modules.ShowBlackScreen)

local camera = workspace.CurrentCamera
local cameraPosition = workspace:WaitForChild("CameraPosition")

local menuBlur = Lighting:FindFirstChild("MenuBlur")

local menuTheme = SoundService:FindFirstChild("MenuTheme")

local blackScreen = player.PlayerGui.BlackScreen

local canvas = script.Parent.Parent.Canvas

local buttonsContainer = canvas.Container

local debounce = false
local angle = 0

local center = cameraPosition.Position
local connection

local function setUpMenu()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	
	player.PlayerGui.MainUI.Enabled = false
	
	canvas.Visible = true
	
	for i, frame in ipairs(canvas:GetChildren()) do
		if not frame:IsA("Frame") then continue end
		
		frame.Visible = false
	end
	
	for i, button in ipairs(buttonsContainer:GetChildren()) do
		if not button:IsA("ImageButton") then continue end
		
		button.Active = true
		button.Interactable = true
	end
	
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cameraPosition.CFrame

	cameraPosition.Changed:Connect(function()
		camera.CFrame = cameraPosition.CFrame
	end)

	connection = RunService.RenderStepped:Connect(function(deltaTime)
		angle = angle + menuConfig.speed * deltaTime

		local x = center.X + math.cos(angle) * menuConfig.radius
		local z = center.Z + math.sin(angle) * menuConfig.radius
		local position = Vector3.new(x, center.Y, z)

		cameraPosition.CFrame = CFrame.new(position, center)
	end)

	menuTheme:Play()
	menuTheme.Looped = true
	TweenService:Create(menuTheme, TweenInfo.new(3, Enum.EasingStyle.Linear), {Volume = 1}):Play()

	menuBlur.Enabled = true
	buttonsContainer.Visible = true
end

local function tweenPage(frame: Frame|ImageLabel, position: UDim2, isOpen: boolean, isSettings: boolean)
	local tweenInfo

	if isOpen then
		tweenInfo = tweenConfig.Menu.openingTweenInfo
	elseif isSettings then
		tweenInfo = tweenConfig.Settings.closingTweenInfo
	else
		tweenInfo = tweenConfig.GamepassUI.closingTweenInfo
	end

	SoundService:PlayLocalSound(SoundService.SoundEffects.Swoosh)
	TweenService:Create(frame, tweenInfo, {Position = position}):Play()
end

for i, button in buttonsContainer:GetChildren() do
	if not button:IsA("ImageButton") then continue end

	if button.Name == "PlayButton" then
		button.Activated:Connect(function()
			showBlackScreen:Show(blackScreen, 1)

			for i, button in buttonsContainer:GetChildren() do
				if not button:IsA("ImageButton") then continue end

				button.Interactable = false
			end

			canvas.CharacterSelection.Visible = true
			buttonsContainer.Visible = false
			connection:Disconnect()

			showBlackScreen:Hide(blackScreen, 1)
		end)
		continue
	end

	button.Activated:Connect(function()
		if debounce then return end

		debounce = true

		SoundService:PlayLocalSound(SoundService.SoundEffects.Click)

		local relatedUIName = button:WaitForChild("RelatedUI").Value
		local relatedUI = player.PlayerGui:FindFirstChild(relatedUIName, true)

		if not relatedUI then
			warn("UI: '" .. relatedUIName .. "' could not be found.")
			debounce = false
			showMessage:ShowErrorMessage()
			return 
		end

		if string.find(string.lower(relatedUIName), "clan") then
			for i, button in buttonsContainer:GetChildren() do
				if not button:IsA("ImageButton") then continue end

				button.Interactable = false
			end

			SoundService:PlayLocalSound(SoundService.SoundEffects.Swoosh)
			TweenService:Create(relatedUI.Canvas.Background, tweenConfig.Menu.openingTweenInfo, {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

			debounce = false
			return
		end

		local isSettingsUI = string.find(string.lower(relatedUIName), "settings")
		if isSettingsUI then
			local currentPosition = relatedUI.Canvas.Background.Position
			local isOpen = currentPosition.X.Scale < 1
			local targetPosition = isOpen and UDim2.new(1.3, 0, 0.534, 0) or UDim2.new(0.86, 0, 0.534, 0)

			tweenPage(relatedUI.Canvas.Background, targetPosition, isOpen, isSettingsUI)
			debounce = false
			return
		end

		local currentPosition = relatedUI.Canvas.Background.Position
		local isOpen = currentPosition.X.Scale > 0
		local targetPosition = isOpen and UDim2.new(-0.3, 0, 0.5, 0) or UDim2.new(0.148, 0, 0.5, 0)

		tweenPage(relatedUI.Canvas.Background, targetPosition, isOpen, isSettingsUI)
		debounce = false
	end)
end

setUpMenu()

bindables.ShowMenu.Event:Connect(setUpMenu)