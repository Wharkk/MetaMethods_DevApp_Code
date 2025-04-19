local TweenService = game:GetService("TweenService")

local tweenUtils = {}

function tweenUtils:GetTween(instance: Instance, tweenInfo: TweenInfo, propertyTable: { [string]: any }): Tween
	propertyTable = propertyTable or {}
	return TweenService:Create(instance, tweenInfo, propertyTable)
end

return tweenUtils
