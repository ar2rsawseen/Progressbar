local function bezier3(p1,p2,p3,mu)
   local mum1,mum12,mu2
   local p = {}
   mu2 = mu * mu
   mum1 = 1 - mu
   mum12 = mum1 * mum1
   p.x = p1.x * mum12 + 2 * p2.x * mum1 * mu + p3.x * mu2
   p.y = p1.y * mum12 + 2 * p2.y * mum1 * mu + p3.y * mu2
   return p
end

Progressbar = Core.class(Sprite)

function Progressbar:init(config)
	-- Settings
	self.conf = {
		width = 200,
		height = 20,
		minValue = 0,
		maxValue = 100,
		value = 100, 
		radius = 5,
		textFont = nil,
		textColor = 0xffffff,
		showValue = true,
		textBefore = "",
		textAfter = "",
		animIncrement = 1,
		animInterval = 10,
		easing = nil
	}
	
	if config then
		--copying configuration
		for key,value in pairs(config) do
			self.conf[key]= value
		end
	end
	
	self.stack = {}
	
	--store initial value
	self.value = self.conf.value
	
	--some properties
	self.bgFill = {Shape.SOLID, 0x0000ff}
	self.bgLine = {3, 0xffff00, 0.8}
	self.bg = Shape.new()
	self:drawBackground()
	self:addChild(self.bg)
	
	self.barFill = {Shape.SOLID, 0xff0000}
	self.barLine = {3, 0xffff00, 0.8}
	self.bar = Shape.new()
	self:drawBar()
	self:addChild(self.bar)
	
	--display value
	if self.conf.showValue then
		self.text = TextField.new(self.conf.textFont, self.conf.textBefore..self.value..self.conf.textAfter)
		self:positionText()
		self.text:setTextColor(self.conf.textColor)
		self:addChild(self.text)
	end
	
	self.onChange = Event.new("onValueChange")
end

function Progressbar:positionText()
	local x, y, w, h = self.text:getBounds(self)
	if not self.text.xOffset or not self.text.yOffset then
		self.text.xOffset = x 
		self.text.yOffset = y + 1
	end
	self.text:setPosition(math.floor((self:getWidth() - w)/2) - self.text.xOffset, math.floor((self:getHeight() - h)/2) - self.text.yOffset)
end

function Progressbar:drawBackground()
	self.bg:clear()
	if self.bgFill then
		Shape.setFillStyle(self.bg, unpack(self.bgFill))
	end
	if self.bgLine then
		Shape.setLineStyle(self.bg, unpack(self.bgLine))
	end
	self.bg:beginPath()
	if(self.conf.radius == 0)then
		self.bg:moveTo(0,0)
		self.bg:lineTo(self.conf.width,0)
		self.bg:lineTo(self.conf.width, self.conf.height)
		self.bg:lineTo(0, self.conf.height)
		self.bg:lineTo(0, 0)
	else
		self.bg:moveTo(0, self.conf.radius)
		self.bg:lineTo(0, self.conf.height - self.conf.radius)
		self:quadraticCurveTo(self.bg, 0, self.conf.height - self.conf.radius,
			0, self.conf.height, 
			self.conf.radius, self.conf.height)
		self.bg:lineTo(self.conf.width - self.conf.radius, self.conf.height)
		self:quadraticCurveTo(self.bg, self.conf.width - self.conf.radius, self.conf.height,
			self.conf.width, self.conf.height, 
			self.conf.width, self.conf.height - self.conf.radius)
		self.bg:lineTo(self.conf.width, self.conf.radius)
		self:quadraticCurveTo(self.bg, self.conf.width, self.conf.radius,
			self.conf.width, 0, 
			self.conf.width - self.conf.radius, 0)
		self.bg:lineTo(self.conf.radius, 0)
		self:quadraticCurveTo(self.bg, self.conf.radius, 0,
			0, 0, 
			0, self.conf.radius)
	end
	self.bg:endPath()
end

function Progressbar:drawBar()
	if self.value > 0 then
	local width = ((self.value-self.conf.minValue)/(self.conf.maxValue-self.conf.minValue))*self.conf.width
		self.bar:clear()
		if self.barFill then
			Shape.setFillStyle(self.bar, unpack(self.barFill))
		end
		if self.barLine then
			Shape.setLineStyle(self.bar, unpack(self.barLine))
		end
		self.bar:beginPath()
		if(self.conf.radius == 0)then
			self.bar:moveTo(0,0)
			self.bar:lineTo(width,0)
			self.bar:lineTo(width, self.conf.height)
			self.bar:lineTo(0, self.conf.height)
			self.bar:lineTo(0, 0)
		else
			self.bar:moveTo(0, self.conf.radius)
			self.bar:lineTo(0, self.conf.height - self.conf.radius)
			self:quadraticCurveTo(self.bar, 0, self.conf.height - self.conf.radius,
				0, self.conf.height, 
				self.conf.radius, self.conf.height)
			self.bar:lineTo(width - self.conf.radius, self.conf.height)
			self:quadraticCurveTo(self.bar, width - self.conf.radius, self.conf.height,
				width, self.conf.height, 
				width, self.conf.height - self.conf.radius)
			self.bar:lineTo(width, self.conf.radius)
			self:quadraticCurveTo(self.bar, width, self.conf.radius,
				width, 0, 
				width - self.conf.radius, 0)
			self.bar:lineTo(self.conf.radius, 0)
			self:quadraticCurveTo(self.bar, self.conf.radius, 0,
				0, 0, 
				0, self.conf.radius)
		end
		self.bar:endPath()
	else
		self.bar:clear()
	end
end

function Progressbar:quadraticCurveTo(shape, lastX, lastY, cpx, cpy, x, y, mu)
	local inc = mu or 0.1 -- need a better default
	for i = 0,1,inc do
	local p = bezier3(
		{ x=lastX, y=lastY },
		{ x=cpx, y=cpy },
		{ x=x, y=y },
		i)
	shape:lineTo(p.x,p.y)
	end
end

function Progressbar:set(param, value)
	if param == "bar" then
		self:setValue(math.floor(value))
	else
		Sprite.set(self, param, value)
	end
end

function Progressbar:get(param)
	if param == "bar" then
		return self.value
	else
		return Sprite.get(self, param)
	end
end

--External API methods

function Progressbar:setBgFillStyle(...)
	self.bgFill = arg
	self:drawBackground()
end

function Progressbar:setBgLineStyle(...)
	self.bgLine = arg
	self:drawBackground()
end

function Progressbar:setBarFillStyle(...)
	self.barFill = arg
	self:drawBar()
end

function Progressbar:setBarLineStyle(...)
	self.barLine = arg
	self:drawBar()
end

function Progressbar:setValue(value, relative)
	if relative then
		value = self.value + value
	end
	if value < self.conf.minValue then
		value = self.conf.minValue
	end
	if value > self.conf.maxValue then
		value = self.conf.maxValue
	end
	if self.value ~= value then
		self.value = value
		self.onChange.value = self.value
		self:dispatchEvent(self.onChange)
		self:drawBar()
		self.text:setText(self.conf.textBefore..self.value..self.conf.textAfter)
		--self:positionText()
	end
end

function Progressbar:getValue()
	return self.value
end

function Progressbar:setTextColor(color)
	self.text:setTextColor(color)
end

function Progressbar:getTextColor()
	self.text:getTextColor()
end

function Progressbar:setLetterSpacing(value)
	self.text:setLetterSpacing(value)
end

function Progressbar:getLetterSpacing()
	self.text:getLetterSpacing()
end

function Progressbar:animateValue(value, animTime)
	animTime = animTime or 1
	local properties = {}
	properties.delay = 0
	properties.ease = self.conf.easing
	properties.dispatchEvents = true
	if not self.tween then
		self.tween = GTween.new(self, animTime, {bar = value}, properties)
		self.tween:addEventListener("complete", function()
			self.tween = nil
			if(self.stack[1])then
				local value = self.stack[1]
				table.remove(self.stack, 1)
				self:animateValue(value)
			end
		end)
	else
		self.stack[#self.stack+1] = value
	end
end

function Progressbar:resetAnimation()
	if self.tween then
		self.tween:setPosition(0)
	end
end
