local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local character = script.Parent

local torso = script.Parent:WaitForChild("LowerTorso")
local offset = CFrame.new(0, 0, 5)

local UpdateDuckCFrame = ReplicatedStorage:WaitForChild("UpdateDuckCFrame")

local duckStates = {} -- [duckInstance] = { currentCFrame, velocity, targetCFrame }

local smoothTime = 0.5
local maxSpeed = nil
local offsetDistance = 5

ReplicatedStorage.SetupDucks.OnClientEvent:Wait()

local function setupDucks()
	local torso = character:WaitForChild("LowerTorso")

	local duckModels = {}
	for _, duck in ipairs(character:GetChildren()) do
		if duck:IsA("Model") and duck.Name:find("Duck") then
			table.insert(duckModels, duck)
		end
	end

	duckStates = {}

	for i, duck in ipairs(duckModels) do
		if duckStates[duck] ~= nil then continue end
		
		local targetCFrame = torso.CFrame * CFrame.new(0, 0, 5 * i)
		duckStates[duck] = {
			currentCFrame = targetCFrame,
			velocity = Vector3.zero,
			targetCFrame = targetCFrame
		}
	end
end

setupDucks()
character.ChildAdded:Connect(setupDucks)
character.ChildRemoved:Connect(setupDucks)

local firstY = torso.Position.Y

RunService.RenderStepped:Connect(function(dt)
	local previousDuckCFrame = torso.CFrame
	for _, duck in ipairs(character:GetChildren()) do
		local state = duckStates[duck]
		if state then
			local forward = previousDuckCFrame.LookVector
			local targetPosition = previousDuckCFrame.Position - forward * offsetDistance

			-- Lock Y to first duck
			targetPosition = Vector3.new(targetPosition.X, torso.Position.Y, targetPosition.Z)

			local targetCFrame = CFrame.new(targetPosition, previousDuckCFrame.Position)
			state.targetCFrame = targetCFrame
			state.currentCFrame, state.velocity = TweenService:SmoothDamp(
				state.currentCFrame,
				state.targetCFrame,
				state.velocity,
				smoothTime,
				nil,
				dt
			)
			duck:PivotTo(state.currentCFrame)
			
			task.delay(0.1, function()
				UpdateDuckCFrame:FireServer({
					Name = duck.Name,
					CurrentCFrame = state.currentCFrame
				})
			end)
			
			previousDuckCFrame = state.currentCFrame
		end
	end
end)

UpdateDuckCFrame.OnClientEvent:Connect(function(duckInfo)
	if duckInfo.Player == Players.LocalPlayer then return end

	local char = duckInfo.Player.Character
	if not char then return end

	local otherDuck = char:FindFirstChild(duckInfo.Name)
	if not otherDuck then return end

	if not duckStates[otherDuck] then
		duckStates[otherDuck] = {
			currentCFrame = duckInfo.CurrentCFrame,
			velocity = Vector3.zero,
			targetCFrame = duckInfo.CurrentCFrame,
		}
	end

	duckStates[otherDuck].targetCFrame = duckInfo.CurrentCFrame
end)

RunService.RenderStepped:Connect(function(dt)
	for duckInstance, state in pairs(duckStates) do
		if duckInstance and duckInstance.Parent then
			state.currentCFrame, state.velocity = TweenService:SmoothDamp(
				state.currentCFrame,
				state.targetCFrame,
				state.velocity,
				smoothTime,
				maxSpeed,
				dt
			)
			duckInstance:PivotTo(state.currentCFrame)
		else
			duckStates[duckInstance] = nil
		end
	end
end)
