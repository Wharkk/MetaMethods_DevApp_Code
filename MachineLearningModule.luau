-- MachineLearningModule Module
local LinearRegression = require(script.LinearRegression)
local DecisionTree = require(script.DecisionTree)
local NeuralNetwork = require(script.NeuralNetwork)

local MachineLearningModule = {}

-- Enum for model types
MachineLearningModule.ModelType = {
	LinearRegression = "LinearRegression",
	DecisionTree = "DecisionTree",
	NeuralNetwork = "NeuralNetwork"
}

function MachineLearningModule:new(modelType)
	local self = setmetatable({}, { __index = MachineLearningModule })
	self.modelType = modelType

	if modelType == MachineLearningModule.ModelType.NeuralNetwork then
		self.numInputs = nil
		self.numHidden = nil
		self.numOutputs = nil
		self.epochs = nil
		self.learningRate = nil
		self.debugMode = false
	end

	return self
end

function MachineLearningModule:train(data, targets, params)
	if self.modelType == MachineLearningModule.ModelType.LinearRegression then
		self.model = LinearRegression.train(data, targets)
	elseif self.modelType == MachineLearningModule.ModelType.DecisionTree then
		self.model = DecisionTree.buildTree(data, params.maxDepth, params.minSize)
	elseif self.modelType == MachineLearningModule.ModelType.NeuralNetwork then
		self.numInputs = params.numInputs
		self.numHidden = params.numHidden
		self.numOutputs = params.numOutputs
		self.epochs = params.epochs
		self.learningRate = params.learningRate
		self.debugMode = params.debugMode
		self.weightsInputHidden, self.weightsHiddenOutput = NeuralNetwork.train(
			data, targets, self.numInputs, self.numHidden, self.numOutputs, self.epochs, self.learningRate, self.debugMode
		)
	else
		error(`Invalid model type specified {self.modelType}`)
	end
end

function MachineLearningModule:predict(input)
	if self.modelType == MachineLearningModule.ModelType.LinearRegression then
		return LinearRegression.predict(self.model, input)
	elseif self.modelType == MachineLearningModule.ModelType.DecisionTree then
		return DecisionTree.predict(self.model, input)
	elseif self.modelType == MachineLearningModule.ModelType.NeuralNetwork then
		local prediction = NeuralNetwork.predict(self.weightsInputHidden, self.weightsHiddenOutput, input, self.numHidden, self.numOutputs)
		return prediction[1]
	else
		error("Invalid model type specified")
	end
end

return MachineLearningModule
