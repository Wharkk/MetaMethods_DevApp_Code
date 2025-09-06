local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local assets = ServerStorage.Assets

local Internals = {}
local AssetsLoadingService = {}

function AssetsLoadingService.OnStart()
	Internals.loadAssets()
end

function Internals.loadAssets()
	for _, asset in assets.MapAssets:GetChildren() do
		local workspaceFolder = CollectionService:GetTagged(asset.Name)[1]

		for _, holder in workspaceFolder:GetChildren() do
			local newAsset = asset:Clone()
			newAsset:PivotTo(holder:GetPivot())
			newAsset.Parent = workspaceFolder

			holder:Destroy()
		end
	end
end

return AssetsLoadingService
