local Players = game:GetService("Players")

local PlayerBinds = {}

type BindingFunction = (any) -> any

function PlayerBinds:BindFunctionToPlayer(playerFunction: BindingFunction)
	for _, player in Players:GetPlayers() do
		task.defer(playerFunction, player)
	end
	Players.PlayerAdded:Connect(playerFunction)
end

function PlayerBinds:BindFunctionToRemovingPlayer(playerFunction: BindingFunction)
	Players.PlayerRemoving:Connect(playerFunction)
end

function PlayerBinds:BindFunctionToCharacter(characterFunction: BindingFunction)
	PlayerBinds:BindFunctionToPlayer(function(player)
		if player.Character then
			task.defer(characterFunction, player.Character)
		end
		player.CharacterAdded:Connect(function(character)
			characterFunction(character)
		end)
	end)
end

function PlayerBinds:BindFunctionToRemovingCharacter(characterFunction: BindingFunction)
	PlayerBinds:BindFunctionToPlayer(function(player)
		player.CharacterRemoving:Connect(function(character)
			characterFunction(character)
		end)
	end)
end

return PlayerBinds
