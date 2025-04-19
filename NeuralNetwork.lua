-- NeuralNetwork Module

local NeuralNetwork = {}

local function sigmoid(x)
	return 1 / (1 + math.exp(-x))
end

local function sigmoidDerivative(x)
	return x * (1 - x)
end

local function initializeWeights(numInputs, numHidden, numOutputs)
	local weightsInputHidden = {}
	local weightsHiddenOutput = {}

	math.randomseed(os.time())

	for i = 1, numInputs do
		weightsInputHidden[i] = {}
		for j = 1, numHidden do
			weightsInputHidden[i][j] = math.random() * 0.02 - 0.01
		end
	end

	for j = 1, numHidden do
		weightsHiddenOutput[j] = {}
		for k = 1, numOutputs do
			weightsHiddenOutput[j][k] = math.random() * 0.02 - 0.01
		end
	end

	return weightsInputHidden, weightsHiddenOutput
end
function NeuralNetwork.train(data, targets, numInputs, numHidden, numOutputs, epochs, learningRate, debugMode)
	local weightsInputHidden, weightsHiddenOutput = initializeWeights(numInputs, numHidden, numOutputs)

	for epoch = 1, epochs do
		local totalError = 0

		for i = 1, #data do
			local inputs = data[i]
			local target = targets[i]

			-- Forward pass
			local hiddenInputs = {}
			for j = 1, numHidden do
				hiddenInputs[j] = 0
				for k = 1, numInputs do
					hiddenInputs[j] = hiddenInputs[j] + inputs[k] * weightsInputHidden[k][j]
				end
				hiddenInputs[j] = sigmoid(hiddenInputs[j])
			end

			local finalOutputs = {}
			for k = 1, numOutputs do
				finalOutputs[k] = 0
				for j = 1, numHidden do
					finalOutputs[k] = finalOutputs[k] + hiddenInputs[j] * weightsHiddenOutput[j][k]
				end
				finalOutputs[k] = sigmoid(finalOutputs[k])
			end

			-- Calculate output errors
			local outputErrors = {}
			for k = 1, numOutputs do
				outputErrors[k] = target[k] - finalOutputs[k]
				totalError = totalError + outputErrors[k]^2  -- Mean Squared Error
			end

			-- Backward pass
			local hiddenErrors = {}
			for j = 1, numHidden do
				hiddenErrors[j] = 0
				for k = 1, numOutputs do
					hiddenErrors[j] = hiddenErrors[j] + outputErrors[k] * weightsHiddenOutput[j][k]
				end
				hiddenErrors[j] = hiddenErrors[j] * sigmoidDerivative(hiddenInputs[j])
			end

			-- Update weights
			for j = 1, numHidden do
				for k = 1, numOutputs do
					weightsHiddenOutput[j][k] = weightsHiddenOutput[j][k] + learningRate * outputErrors[k] * hiddenInputs[j]
				end
			end

			for k = 1, numInputs do
				for j = 1, numHidden do
					weightsInputHidden[k][j] = weightsInputHidden[k][j] + learningRate * hiddenErrors[j] * inputs[k]
				end
			end
		end

		if debugMode then
			-- Print the error at intervals
			if epoch % 1000 == 0 then
				print("Epoch " .. epoch .. " - Error: " .. totalError)
			end
		end
	end

	return weightsInputHidden, weightsHiddenOutput
end

function NeuralNetwork.predict(weightsInputHidden, weightsHiddenOutput, inputs, numHidden, numOutputs)
	local hiddenInputs = {}
	for j = 1, numHidden do
		hiddenInputs[j] = 0
		for k = 1, #inputs do
			hiddenInputs[j] = hiddenInputs[j] + inputs[k] * weightsInputHidden[k][j]
		end
		hiddenInputs[j] = sigmoid(hiddenInputs[j])
	end

	local finalOutputs = {}
	for k = 1, numOutputs do
		finalOutputs[k] = 0
		for j = 1, numHidden do
			finalOutputs[k] = finalOutputs[k] + hiddenInputs[j] * weightsHiddenOutput[j][k]
		end
		finalOutputs[k] = sigmoid(finalOutputs[k])
	end

	-- Apply a threshold to the output
	for k = 1, numOutputs do
		finalOutputs[k] = finalOutputs[k] > 0.5 and 1 or 0
	end

	return finalOutputs
end

return NeuralNetwork