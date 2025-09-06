-- DecisionTree Module
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DecisionTree = {}

-- Function to calculate Gini impurity
local function giniImpurity(groups, classes)
	local n_instances = 0
	for _, group in pairs(groups) do
		n_instances = n_instances + #group
	end

	local gini = 0
	for _, group in pairs(groups) do
		local size = #group
		if size == 0 then
			continue
		end

		local score = 0
		local class_counts = {}
		for _, row in ipairs(group) do
			local class = row[#row]
			if not class_counts[class] then
				class_counts[class] = 0
			end
			class_counts[class] = class_counts[class] + 1
		end

		for _, count in pairs(class_counts) do
			local proportion = count / size
			score = score + proportion * proportion
		end

		gini = gini + (1.0 - score) * (size / n_instances)
		continue
	end

	return gini
end

-- Function to split the dataset
local function testSplit(index, value, dataset)
	local left, right = {}, {}
	for _, row in ipairs(dataset) do
		if row[index] < value then
			table.insert(left, row)
		else
			table.insert(right, row)
		end
	end
	return left, right
end

-- Function to find the best split point
local function getSplit(dataset)
	local class_values = {}
	for _, row in ipairs(dataset) do
		class_values[row[#row]] = true
	end

	local b_index, b_value, b_score, b_groups = 999, 999, 999, nil
	for index = 1, #dataset[1] - 1 do
		for _, row in ipairs(dataset) do
			local groups = {testSplit(index, row[index], dataset)}
			local gini = giniImpurity(groups, class_values)
			if gini < b_score then
				b_index, b_value, b_score, b_groups = index, row[index], gini, groups
			end
		end
	end
	return {index = b_index, value = b_value, groups = b_groups}
end

-- Function to create a terminal node
local function toTerminal(group)
	local outcomes = {}
	for _, row in ipairs(group) do
		local outcome = row[#row]
		if not outcomes[outcome] then
			outcomes[outcome] = 0
		end
		outcomes[outcome] = outcomes[outcome] + 1
	end

	local max_count = 0
	local max_class = nil
	for class, count in pairs(outcomes) do
		if count > max_count then
			max_count = count
			max_class = class
		end
	end
	return max_class
end

-- Recursive function to create child splits for a node or make terminal
local function split(node, max_depth, min_size, depth)
	local left, right = table.unpack(node.groups)
	node.groups = nil
	if not left or not right then
		node.left = toTerminal(left or right)
		node.right = node.left
		return
	end
	if depth >= max_depth then
		node.left = toTerminal(left)
		node.right = toTerminal(right)
		return
	end
	if #left <= min_size then
		node.left = toTerminal(left)
	else
		node.left = getSplit(left)
		split(node.left, max_depth, min_size, depth + 1)
	end
	if #right <= min_size then
		node.right = toTerminal(right)
	else
		node.right = getSplit(right)
		split(node.right, max_depth, min_size, depth + 1)
	end
end

-- Build a decision tree
function DecisionTree:buildTree(train, max_depth, min_size)
	local root = getSplit(train)
	split(root, max_depth, min_size, 1)
	return root
end

-- Make a prediction with a decision tree
function DecisionTree:predict(node, row)
	if row[node.index] < node.value then
		if type(node.left) == "table" then
			return DecisionTree:predict(node.left, row)
		else
			return node.left
		end
	else
		if type(node.right) == "table" then
			return DecisionTree:predict(node.right, row)
		else
			return node.right
		end
	end
end

function DecisionTree:save(model: {}, moduleScriptName: string, location: Instance?)
	location = location or ReplicatedStorage

	local newSave = Instance.new("ModuleScript")
	newSave.Name = moduleScriptName
	newSave.Parent = location

	local serializedData = game:GetService("HttpService"):JSONEncode(model)
	newSave.Source = serializedData
end 

return DecisionTree
