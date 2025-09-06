local ServerStorage = game:GetService("ServerStorage")

local DevSettings = require(ServerStorage.DevSettings)

local PhoneStatusTracker = {}

--[[ Showcase function: shows how you initialize player state ]]
function PhoneStatusTracker:Init(player: Player): ()
	PhoneStatusTracker[player] = {
		homeActive = true,
		notificationActive = false,
		selectedApp = "Home",
	}
end

--[[ CONFIDENTIAL LOGIC HIDDEN ]]
-- clear: Resets tracking data for a player.
-- setHomeActive: Marks whether the home screen is currently active for the player.
-- isHomeActive: Returns whether the home screen is active (defaults to true if uninitialized).
-- setNotificationActive: Marks whether notifications are currently active for the player.
-- isNotificationActive: Returns whether notifications are active for the player.
-- setSelectedApp: Updates which app the player currently has selected.
-- getSelectedApp: Returns the currently selected app for the player.

return PhoneStatusTracker
