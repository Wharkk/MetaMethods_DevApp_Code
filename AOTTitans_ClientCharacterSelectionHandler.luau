type characterImages = {ImageLabel}

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

local events = ReplicatedStorage.Events

local remotes = events.Remotes
local modules = ReplicatedStorage.Modules

local changeCharacter = remotes.ChangeCharacter
local updateCamera = remotes.UpdateCamera

local showMessage = require(modules.ShowMessage)
local showBlackScreen = require(modules.ShowBlackScreen)

local menuBlur = Lighting:FindFirstChild("MenuBlur")
local menuTheme = SoundService:FindFirstChild("MenuTheme")

local blackScreen = player.PlayerGui.BlackScreen
local canvas = script.Parent.Parent.Canvas

local main = canvas.CharacterSelection
local characterSelection = canvas.CharacterSelection.Main
local carousel = characterSelection.CarouselImages
local leftButton = characterSelection.LeftButton
local rightButton = characterSelection.RightButton
local selectedCharacterName = characterSelection.SelectedCharacterName
local images = carousel:GetChildren()

local characterImages = {}

for i, image in ipairs(images) do
	if image:IsA("ImageLabel") then
		table.insert(characterImages, image)
	end
end

local totalCharacters = #characterImages
local currentIndex = 1
local radius = 0.32
local centerY = 0.5

local function exitMainMenu()
	local mainMenu = player.PlayerGui:FindFirstChild("MenuUI", true)
	if not mainMenu then showMessage:ShowErrorMessage() return end

	task.spawn(function()
		local decreasingVolumeTween = TweenService:Create(menuTheme, TweenInfo.new(3, Enum.EasingStyle.Linear), {Volume = 0})
		decreasingVolumeTween:Play()
		decreasingVolumeTween.Completed:Wait()
		menuTheme:Stop()
	end)

	local hidden = showBlackScreen:Show(blackScreen, 2, true)
	
	repeat task.wait() until hidden
	
	changeCharacter:FireServer(selectedCharacterName.TextLabel.Text)
	
	mainMenu.Canvas.Visible = false
	camera.CameraType = Enum.CameraType.Custom
	menuBlur.Enabled = false
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	player.PlayerGui.MainUI.Enabled = true
	
	showBlackScreen:Hide(blackScreen, 2)
end

local function getCircularPosition(index)
	local angle = math.rad((index - currentIndex) * (360 / totalCharacters))
	local offset = math.cos(angle)

	local xPos = 0.5 + radius * math.sin(angle)

	local baseY = centerY + radius * (1 - offset)
	baseY = baseY - 0.03 * math.pow(1 - offset, 2)

	local scale = 0.2 + 0.3 * offset
	local transparency = 1 - offset

	return UDim2.new(xPos, 0, baseY, 0), UDim2.new(scale, 0, scale * 1.2, 0), transparency
end

local function updateCarousel()
	for i, imageLabel in ipairs(images) do
		local pos, size, transparency = getCircularPosition(i)
		
		local image = characterImages[i]	
		imageLabel.Image = image.Image

		TweenService:Create(imageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Position = pos,
			Size = size,
			ImageTransparency = transparency
		}):Play()
	end
end

updateCarousel()

local image = characterImages[currentIndex]
selectedCharacterName.TextLabel.Text = image:GetAttribute("Name")

leftButton.Activated:Connect(function()
	SoundService:PlayLocalSound(SoundService.SoundEffects.Click)
	currentIndex = ((currentIndex - 2) % totalCharacters) + 1
	
	local image = characterImages[currentIndex]
	selectedCharacterName.TextLabel.Text = image:GetAttribute("Name")
	
	updateCarousel()
end)

rightButton.Activated:Connect(function()
	SoundService:PlayLocalSound(SoundService.SoundEffects.Click)
	currentIndex = (currentIndex % totalCharacters) + 1
	
	local image = characterImages[currentIndex]
	selectedCharacterName.TextLabel.Text = image:GetAttribute("Name")
	
	updateCarousel()
end)

main.DeployButton.Activated:Connect(function()
	SoundService:PlayLocalSound(SoundService.SoundEffects.Click)
	
	main.DeployButton.Active = false
	leftButton.Active = false
	rightButton.Active = false
	exitMainMenu()
end)

updateCamera.OnClientEvent:Connect(function()
	local camera = workspace.CurrentCamera
	camera.CameraSubject = player.Character.Humanoid
end)
