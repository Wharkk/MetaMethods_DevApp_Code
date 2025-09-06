local TweenService = game:GetService("TweenService")

local ShowBlackScreen = {}

function ShowBlackScreen:Show(blackScreen: ScreenGui, duration: number, callback: boolean?): boolean?
	callback = callback or false
	
	local tween = TweenService:Create(blackScreen.Frame, TweenInfo.new(duration), {BackgroundTransparency = 0})
	tween:Play()
	tween.Completed:Wait()
	
	if callback then
		return true
	end
end

function ShowBlackScreen:Hide(blackScreen: ScreenGui, duration: number, callback: boolean?): boolean?
	callback = callback or false
	
	local tween = TweenService:Create(blackScreen.Frame, TweenInfo.new(duration), {BackgroundTransparency = 1})
	tween:Play()
	tween.Completed:Wait()
	
	if callback then
		return true
	end
end

return ShowBlackScreen
