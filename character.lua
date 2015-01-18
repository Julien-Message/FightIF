require "auto"

Character = class('Character')

function Character:initialize(name, x, y)
	self.name = name

	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.shape = love.physics.newRectangleShape( 64, 128 )
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.speed = 100

	local states = {
		Idle = {R = "Right", L = "Left", N="Idle",T = "Idle", TIME = frameTime},
		Right = {R = "Right", L = "Left",N="Idle", T = "Right", TIME = frameTime},
		Left = {R = "Right", L = "Left", T = "Left", N="Idle", TIME = frameTime}
	}
	self.automate = Automate(states, "Idle")

	-- loads the sprites into a table for quick access
	self.sprites = {}
	for stateName, unused in pairs(self.automate.states) do
		self.sprites[stateName] = {}
		for i,picture in ipairs(love.filesystem.getDirectoryItems(graphicsFolder .. "/" .. name .. "/" .. stateName)) do
			table.insert(self.sprites[stateName],
				love.graphics.newImage(graphicsFolder .. "/" .. name .. "/" .. stateName .. "/" .. picture))
		end 
	end

	self.currentPic = 1
	self.pictureTimer = 0 
	self.pictureDuration = 0.5
end

function Character:getState()
	return self.automate.currentState
end

function Character:getCurrentPicture()
	return self.sprites[self:getState()][self.currentPic]
end

-- applies the event in the automata
function Character:apply(event)
	if self.automate:applyEvent(event) then --if the state has changed
		self.pictureTimer = 0
		self.currentPic = 1
	end
end

function Character:move() -- TODO change the function's name and content
	local state = self:getState()
	if state == "Right" then
		local _,y = self.body:getLinearVelocity()
		self.body:setLinearVelocity(self.speed, y)
	elseif state == "Left" then
		local _,y = self.body:getLinearVelocity()
		self.body:setLinearVelocity(-self.speed, y)
	elseif state == "Idle" then
		local _,y = self.body:getLinearVelocity()
		self.body:setLinearVelocity(0, y)
	end
end

--updates the picture to draw regarding the timer set for the current one
function Character:updatePicture(dt)
	self.pictureTimer = self.pictureTimer + dt
	if self.pictureTimer > self.pictureDuration then
		self.pictureTimer = 0
		self.currentPic = self.currentPic % table.getn(self.sprites[self.automate.currentState]) + 1
	end
end

--looks which key is down and do the necessary things
function Character:update(dt)
	if love.keyboard.isDown("left") then
        self:apply("L")
    elseif love.keyboard.isDown("right") then
        self:apply("R")
    --elseif love.keyboard.isDown(" ") then
    --    self:apply("S")
    else
        self:apply("N")
    end
	self:move()
	self:updatePicture(dt)
end

function Character:draw()
	love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self:getCurrentPicture(), self.body:getX() - 64/2, self.body:getY() - 128/2)
end

--in case of debugging, display some useful informations
function Character:drawDebug()
	love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
	love.graphics.print("X : " .. self.body:getX() .. ", Y = " .. self.body:getY() ..
		"\nBody is " .. self.body:getType() ..
		"\nState is : " .. self:getState() ..
		"\nMass is : " .. self.body:getMass(),
		self.body:getX(), self.body:getY() - 150)
end