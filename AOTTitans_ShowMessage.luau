local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

local soundEffects = SoundService.SoundEffects

local ShowMessage = {}

function ShowMessage:ShowErrorMessage(message: string?)
	message = message or "An error has occurred, please try again later."
	StarterGui:SetCore("SendNotification", {
		Title = "Error",
		Text = message
	})
	
	SoundService:PlayLocalSound(soundEffects.Error)
end

function ShowMessage:ShowSuccessMessage(message: string?)
	message = message or "Thank you for your purchase!"
	StarterGui:SetCore("SendNotification", {
		Title = "Success",
		Text = message
	})
	SoundService:PlayLocalSound(soundEffects.Success)
end

return ShowMessage
