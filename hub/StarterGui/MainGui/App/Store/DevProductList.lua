local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local assign = require(ReplicatedStorage.Core.assign)
local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local DevProductList = Roact.PureComponent:extend("DevProductList")
local ProductCard = Roact.PureComponent:extend("ProductCard")

local IMAGE_RECTANGLE = "rbxassetid://3792742614"
local ROTATE_RATE = 0.3
local TEXT_MAX_ROTATE = 8

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

function ProductCard:init()
	self.nameTextRef = Roact.createRef()
	self.uiScaleRef = Roact.createRef()

	local nameRotation, setNameRotation = Roact.createBinding(0)
	self.nameRotation = nameRotation

	local rotateConnection, resetConnection

	self.activated = function()
		self.tweens.buttonClick:Play()
		SoundService.SFX.Purchase:Play()
		MarketplaceService:PromptProductPurchase(LocalPlayer, self.props.product.Product)
	end

	self.hover = function()
		self.tweens.buttonHoverIn:Play()

		if rotateConnection then
			warn("rotateConnection not disconnected on hover")
			rotateConnection:Disconnect()
		end

		if resetConnection then
			resetConnection:Disconnect()
			resetConnection = nil
		end

		local total = 0

		rotateConnection = RunService.RenderStepped:connect(function(delta)
			total = total + (delta / ROTATE_RATE)
			setNameRotation(math.sin(total) * TEXT_MAX_ROTATE)
		end)
	end

	self.unhover = function()
		self.tweens.buttonHoverOut:Play()

		if rotateConnection then
			rotateConnection:Disconnect()
			rotateConnection = nil
		end

		local currentRotation = nameRotation:getValue() / TEXT_MAX_ROTATE
		local sign = math.sign(currentRotation)
		currentRotation = math.abs(currentRotation)

		resetConnection = RunService.RenderStepped:connect(function(delta)
			currentRotation = math.max(0, currentRotation - delta / ROTATE_RATE)
			setNameRotation(currentRotation * TEXT_MAX_ROTATE * sign)

			if currentRotation == 0 then
				resetConnection:Disconnect()
				resetConnection = nil
			end
		end)
	end

	self.tweens = {}
end

function ProductCard:didMount()
	self.tweens.buttonHoverIn = TweenService:Create(
		self.uiScaleRef:getValue(),
		TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Scale = 1 }
	)

	self.tweens.buttonHoverOut = TweenService:Create(
		self.uiScaleRef:getValue(),
		TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Scale = 0.9 }
	)

	self.tweens.buttonClick = TweenService:Create(
		self.uiScaleRef:getValue(),
		TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		{ Scale = 0.8 }
	)
end

function ProductCard:render()
	local props = self.props

	local children = assign({
		UIScale = e("UIScale", {
			Scale = 0.9,
			[Roact.Ref] = self.uiScaleRef,
		}),
	}, props.renderButton(props.product, self.nameRotation, self.nameTextRef))

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.product.Cost,
		Size = UDim2.fromScale(0.9, 0.23),
	}, {
		e(
			"ImageButton",
			assign({
				BackgroundTransparency = 1,
				Image = IMAGE_RECTANGLE,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 1),
				SliceCenter = Rect.new(30, 100, 50, 244),
				[Roact.Event.Activated] = self.activated,
				[Roact.Event.MouseEnter] = self.hover,
				[Roact.Event.MouseLeave] = self.unhover,
			}, props.imageButtonProps),
			children
		),
	})
end

function DevProductList:init()
	local products = {}

	for index, product in pairs(self.props.products) do
		Promise.promisify(function()
			local productInfo = MarketplaceService:GetProductInfo(product, Enum.InfoType.Product)

			return {
				Cost = productInfo.PriceInRobux,
				Product = product,
				Name = productInfo.Name,
			}
		end)():andThen(function(product)
			products = copy(products)
			products[index] = product
			self:setState({
				products = products,
			})
		end)
	end

	self:setState({
		products = products,
	})
end

function DevProductList:render()
	local children = copy(self.props[Roact.Children] or {})

	for index in pairs(self.props.products) do
		local product = self.state.products[index]
		if product then
			children["Product" .. index] = e(ProductCard, {
				product = product,
				renderButton = self.props.renderButton,
				imageButtonProps = self.props.imageButtonProps,
			})
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, children)
end

return DevProductList