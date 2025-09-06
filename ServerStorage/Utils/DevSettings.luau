local RunService = game:GetService("RunService")

local Dev = {}

Dev.DEV_DEBUG = false

-- [Auto] Sets the debug mode to false if the game is not in studio
if not RunService:IsStudio() then
	Dev.DEV_DEBUG = false
end

return Dev
