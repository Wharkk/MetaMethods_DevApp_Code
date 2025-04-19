-- LinearRegression Module
local LinearRegression = {}

function LinearRegression.train(data, targets)
	local n = #data
	local sumX, sumY, sumXY, sumX2 = 0, 0, 0, 0

	for i = 1, n do
		local x = data[i]
		local y = targets[i]
		sumX = sumX + x
		sumY = sumY + y
		sumXY = sumXY + x * y
		sumX2 = sumX2 + x * x
	end

	local slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
	local intercept = (sumY - slope * sumX) / n

	return {slope = slope, intercept = intercept}
end

function LinearRegression.predict(model, x)
	return model.slope * x + model.intercept
end

return LinearRegression
