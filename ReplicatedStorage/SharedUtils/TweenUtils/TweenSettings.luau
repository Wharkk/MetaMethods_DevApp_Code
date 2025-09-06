local TweenSettings = {}

TweenSettings.Phone = {
	Open = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
	Close = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
	NotificationTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),

	["Apps"] = {
		Open = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		Close = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
	}
}

return TweenSettings
