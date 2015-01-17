require "auto"

Character = class('Character')

function Character:initialize(name, x, y)
	self.name = name

	self.x = x
	self.y = y
	self.speed = 100

	self.graphicsFolder = mainGraphicsFolder.."/"..name
	self.automate = Automate:new()
	self.automate.tableEtat = {
		Idle = {R = "Right", L = "Left", N="Idle",T = "Idle", TIME = frameTime},
		Right = {R = "Right", L = "Left",N="Idle", T = "Right", TIME = frameTime},
		Left = {R = "Right", L = "Left", T = "Left", N="Idle", TIME = frameTime}
	}

	self.sprites = {}
	for stateName, unused in pairs(self.automate.tableEtat) do
		self.sprites[stateName] = love.filesystem.getDirectoryItems(mainGraphicsFolder.."/"..name.."/"..stateName)
	end

	self.automate.currentState = "Idle"
	self.currentPic = 1
	self.pictureTimer = 0 
	self.pictureDuration = 30 -- number of frames a picture should be displayed
end

function Character:press(input)
	if self.automate:changeEtat(input) then
		self.pictureTimer = 0
		self.currentPic = 1
	end
end

function Character:update(dt)
	if self.automate.currentState == "Right" then
		self.x = self.x + self.speed * dt
	elseif self.automate.currentState == "Left" then
		self.x = self.x - self.speed * dt
	end

	self.pictureTimer = self.pictureTimer + 1
	if self.pictureTimer > self.pictureDuration then
		self.pictureTimer = 0
		self.currentPic = self.currentPic % table.getn(self.sprites[self.automate.currentState]) + 1
	end
end

function Character:draw()
	love.graphics.setColor(255,255,255,255)
	local picture = love.graphics.newImage(mainGraphicsFolder.."/"..self.name.."/"..
											self.automate.currentState.."/"..
											self.sprites[self.automate.currentState][self.currentPic])
    love.graphics.draw(picture, mouton.x, mouton.y)
end