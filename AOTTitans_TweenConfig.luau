local TweenConfig = {
	--[[
	
	Here, you can change how will the tween used in UIs looks, 
	everything is categorized so you can see what you are editing better.
	
	Guide:
	
	A tween info is made of: 
	- a duration in seconds: 
	TweenInfo.new(1,
	
	- an EasingStyle, defined by an Enum (basically a list): 
	Enum.EasingStyle.Quad, <-- Here we use Quad, but there are plenty of style you can use.
							For more information you can either just let autocompletion do its magic and you'll see every choices appearing,
							or you can go to: https://create.roblox.com/docs/reference/engine/enums/EasingStyle for a visual representation.
							
	- an EasingDirection, defined by an Enum as well: 
	Enum.EasingDirection.In, <-- Here we use In, but you can use Out or InOut too.
							For more information on this go to: https://create.roblox.com/docs/reference/engine/enums/EasingDirection and check the summary of the one you're interested in.
							
	- a repeat count (It isn't added in any of tweenInfo here because it's not necessary):
	0, <-- Here we set it to 0 because we don't want any repetition, however you can set it to any number you would like.
	
	- a boolean, called "reverse", it is basically used to tell the tween to go in reverse too:
	false, <-- Here we set it to false because we don't want our tween to be go in reverse too, you can set it to true if you want it to go in reverse.
	
	- a delayTime in seconds:
	0) <-- Here we set it to 0 because we want it to play directly when we call it, however you can set it to any number you would like.
	
	And here's the tween info you made!
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
	
	Congrats!
	
	Now, the last 3 values are optional and you can remove them from the tween info if you don't need them.
	So to make it more readable, your final tween info would look like:
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	
	Of course if you're more comfortable with the full version feel free to stick with it!
	
	I hope it helps!
	]]
	
	["LoadingScreen"] = {
		closingTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		loadingDotTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut),
	},
	["Menu"] = {
		openingTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
		closeErrorTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	},
	["Settings"] = {
		closingTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		selectedChoiceTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	},
	["GamepassUI"] = {
		closingTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	},
	["ClanSpin"] = {
		closingClanTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		clanNameTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		notificationTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
		closeNotifTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	},
	["Main"] = {
		-- This one is a little bit different, as the speed will be the difference between the player's health and the max health.
		-- However, despite the speed not being editable, you can still choose the easing style and the easing direction of this tween!
		healthBarTweenInfo = {
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In
		},
		xpBarTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		levelUpTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		levelUpFadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)	
	},
	["Blacksmith"] = {
		openingTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		closingTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	}
}

return TweenConfig
