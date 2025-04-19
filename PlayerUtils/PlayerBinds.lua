local Players = game:GetService("Players")

local playerBinds = {}

type Callback = (any) -> any

function playerBinds:BindFunctionToPlayer(playerFunction: Callback)
	for _, player in Players:GetPlayers() do
		task.defer(playerFunction, player)
	end
	Players.PlayerAdded:Connect(playerFunction)
end

function playerBinds:BindFunctionToRemovingPlayer(playerFunction: Callback)
	Players.PlayerRemoving:Connect(playerFunction)
end

function playerBinds:BindFunctionToCharacter(characterFunction: Callback)
	playerBinds:BindFunctionToPlayer(function(player)
		if player.Character then
			task.defer(characterFunction, player.Character)
		end
		player.CharacterAdded:Connect(function(character)
			characterFunction(character)
		end)
	end)
end

function playerBinds:BindFunctionToRemovingCharacter(characterFunction: Callback)
	playerBinds:BindFunctionToPlayer(function(player)
		player.CharacterRemoving:Connect(function(character)
			characterFunction(character)
		end)
	end)
end

return playerBinds
