local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

local soundEffects = SoundService.SoundEffects

local events = ReplicatedStorage.Events

local remotes = events.Remotes
local config = ReplicatedStorage.Config
local modules = ReplicatedStorage.Modules

local showMessageRemote = remotes.ShowMessage
local tweenConfig = require(config.TweenConfig)
local showMessage = require(modules.ShowMessage)

local gamepasses = remotes.GetGamepasses:InvokeServer()
local developerProducts = MarketplaceService:GetDeveloperProductsAsync():GetCurrentPage()

local canvas = script.Parent.Canvas

local developerProductIds = {}
local debounce = false

local function setupShopProducts(productId: number, infoType: Enum.InfoType)
	local info = MarketplaceService:GetProductInfo(productId, infoType)	
	local icon = info.IconImageAssetId
	local template = script.Template:Clone()
	
	if infoType == Enum.InfoType.GamePass then
		template.LayoutOrder = -1
	else
		template.LayoutOrder = 0
	end
	
	template.Icon.Image = "rbxassetid://"..icon
	template.Name = string.gsub(info.Name, " ", "")
	template.BuyButton.Price.Text = info.PriceInRobux .. "\u{E002}"
	template.ProductName.Text = info.Name
	template.Parent = canvas.Background.Container.ScrollingFrame

	template.BuyButton.MouseButton1Click:Connect(function()
		if debounce then return end
		
		debounce = true
		
		SoundService:PlayLocalSound(SoundService.SoundEffects.Click)
		
		if infoType == Enum.InfoType.GamePass then
			remotes.BuyGamepass:FireServer(productId)
			
			debounce = false
			return
		end
		
		remotes.BuyDeveloperProduct:FireServer(productId)
		
		debounce = false
	end)
end

for name, gamepassId in pairs(gamepasses) do
	setupShopProducts(gamepassId, Enum.InfoType.GamePass)
end

for _, developerProduct in pairs(developerProducts) do
	table.insert(developerProductIds, developerProduct.ProductId)
end

for i, developerProductId in pairs(developerProductIds) do
	setupShopProducts(developerProductId, Enum.InfoType.Product)
end

for i, product in pairs(canvas.Background.Container.ScrollingFrame:GetChildren()) do
	if not product:IsA("Frame") then continue end
	
	if product.Name:match("Spins") then
		product:Destroy()
	end
end

canvas.Background.Exit.MouseButton1Click:Connect(function()
	SoundService:PlayLocalSound(soundEffects.Click)
	SoundService:PlayLocalSound(soundEffects.Swoosh)
	TweenService:Create(canvas.Background, tweenConfig.GamepassUI.closingTweenInfo, {Position = UDim2.new(-0.3, 0, 0.5, 0)}):Play()
end)

showMessageRemote.OnClientEvent:Connect(function(success: boolean)
	if success then
		showMessage:ShowSuccessMessage()
		return
	end
	
	showMessage:ShowErrorMessage()
end)
