local bar = Progressbar.new({
	width = 200,
	height = 20,
	minValue = 0,
	maxValue = 100,
	value = 100, 
	radius = 5,
	textFont = nil,
	textColor = 0xffffff,
	showValue = true,
	textBefore = "Life: ",
	textAfter = " %",
	animIncrement = 1,
	animInterval = 10
})
bar:setPosition(10, 10)
stage:addChild(bar)
bar:animateValue(20)
bar:animateValue(80)
bar:animateValue(10)
bar:animateValue(100)