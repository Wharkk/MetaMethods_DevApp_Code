local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage.Events

local remotes = events.Remotes
local characters = ReplicatedStorage.Characters

local changeCharacter = remotes.ChangeCharacter
local updateCamera = remotes.UpdateCamera

local playerMorphs = {}
local characterAddedConnections = {}

local function applyMorph(player, characterName)
	local character = player.Character
	if not character then return end

	local characterFolder = characters:FindFirstChild(characterName)
	if not characterFolder then return end

	local newCharacter = characterFolder.StarterCharacter:Clone()
	newCharacter.PrimaryPart = newCharacter:FindFirstChild("HumanoidRootPart")
	newCharacter:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)
	newCharacter.Name = player.Name
	newCharacter.Humanoid.Health = character:FindFirstChild("Humanoid") and character.Humanoid.Health or 100
	newCharacter.Humanoid.MaxHealth = character:FindFirstChild("Humanoid") and character.Humanoid.MaxHealth or 100
	player.Character = newCharacter
	newCharacter.Parent = workspace

	character:Destroy()

	updateCamera:FireClient(player)
end

local function setupCharacterAdded(player)
	if characterAddedConnections[player] then
		characterAddedConnections[player]:Disconnect()
	end

	characterAddedConnections[player] = player.CharacterAdded:Connect(function(character)
		local morph = playerMorphs[player]
		if not morph then return end
		if character and character:FindFirstChild("ManeuverEquipment") and character:FindFirstChild("Clothes") then return end
		
		task.wait(0.1)
		applyMorph(player, morph)
		player.PlayerGui.MainUI.Enabled = true
	end)
end

changeCharacter.OnServerEvent:Connect(function(player, characterName)
	playerMorphs[player] = characterName

	if characterAddedConnections[player] then
		characterAddedConnections[player]:Disconnect()
	end

	applyMorph(player, characterName)
	setupCharacterAdded(player)
end)

Players.PlayerAdded:Connect(setupCharacterAdded)

Players.PlayerRemoving:Connect(function(player)
	playerMorphs[player] = nil
	if not characterAddedConnections[player] then return end
	
	characterAddedConnections[player]:Disconnect()
	characterAddedConnections[player] = nil
end)