require "auto"

Character = class('Character')

function Character:initialize(name, x, y)
	self.name = name

	self.x = x
	self.y = y
	self.speed = 100

	local states = {
		Idle = {R = "Right", L = "Left", N="Idle",T = "Idle", TIME = frameTime},
		Right = {R = "Right", L = "Left",N="Idle", T = "Right", TIME = frameTime},
		Left = {R = "Right", L = "Left", T = "Left", N="Idle", TIME = frameTime}
	}
	self.automate = Automate(states, "Idle")

	self.sprites = {}
	for stateName, unused in pairs(self.automate.states) do
		self.sprites[stateName] = {}
		for i,picture in ipairs(love.filesystem.getDirectoryItems(graphicsFolder.."/"..name.."/"..stateName)) do
			table.insert(self.sprites[stateName], love.graphics.newImage(graphicsFolder.."/"..name.."/"..stateName.."/"..picture))
		end 
	end

	self.currentPic = 1
	self.pictureTimer = 0 
	self.pictureDuration = 30 -- number of frames a picture should be displayed
end

function Character:getState()
	return self.automate.currentState
end

function Character:getCurrentPicture()
	return self.sprites[self:getState()][self.currentPic]
end

function Character:press(input)
	if self.automate:applyEvent(input) then
		self.pictureTimer = 0
		self.currentPic = 1
	end
end

function Character:move(dt)
	local state = self:getState()
	if state == "Right" then
		self.x = self.x + self.speed * dt
	elseif state == "Left" then
		self.x = self.x - self.speed * dt
	end
end

function Character:updatePicture()
	self.pictureTimer = self.pictureTimer + 1
	if self.pictureTimer > self.pictureDuration then
		self.pictureTimer = 0
		self.currentPic = self.currentPic % table.getn(self.sprites[self.automate.currentState]) + 1
	end
end

function Character:update(dt)
	self:move(dt)
	self:updatePicture()
end

function Character:draw()
	love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self:getCurrentPicture(), mouton.x, mouton.y)
end