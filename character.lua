local Automate = require "auto"
local class = require "middleclass"

local Character = class('Character')

Character.static.width = 64
Character.static.height = 128

Character.static.spritesFolders = {
    Idle = "idle",
    Moving = "move",

    Jumping = "jump",
    Falling = "jump",
    JumpingAgain = "jump",
    FallingAgain = "jump",
    FallingAfterPunch = "jump",
    FallingAgainAfterPunch = "jump",

    Guarding = "guard",

    Kicking = "kick",
    Kicking2 = "kick2",
    KickingFinal = "kick",
    KickingForward = "kick2",
    JumpingKick = "kick2",

    Punching = "punch",
    Punching2 = "punch2",
    PunchingFinal = "punch",
    PunchingForward = "punch2",
    Uppercut = "punch2",
    UppercutSecondJump = "punch2",

    Stunned = "stun"
}

function Character:initialize(name, x, y, _controller)
    self.name = name

-- sets the physic
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newPolygonShape(
        0, - Character.height / 2,
        Character.width / 2, Character.height / 4,
        0, Character.height / 2,
        - Character.width / 2, Character.height / 4)

    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setFixedRotation(true)
    self.fixture:setFriction(0)

    self.speed = 200
    self.jumpSpeed = 500

    self.automate = Automate(self)
    self.lastState = "Idle"

    -- loads the sprites into a table for quick access
    self.sprites = {}
    for _,folder in ipairs(love.filesystem.getDirectoryItems(graphicsFolder .. "/" .. name)) do
        self.sprites[folder] = {}
        for _,picture in ipairs(love.filesystem.getDirectoryItems(graphicsFolder .. "/" .. name .. "/" .. folder)) do
            table.insert(self.sprites[folder],
                love.graphics.newImage(graphicsFolder .. "/" .. name .. "/" .. folder .. "/" .. picture))
        end
    end
    
    self.continuousActions = {"right", "left", "guard"} 

    self.facingRight = true

    self.currentPic = 1
    self.pictureTimer = 0
    self.pictureDuration = 0.3

    self.controller = _controller
    self.controller:setCharacter(self)
end

--looks which key is down and do the necessary things
function Character:update(dt)
    self.controller:update()
    Automate.actions["default"](self)
    
    local actionDone = false
    for _,action in ipairs(self.continuousActions) do
        if self.controller:isDemanded(action) then
            actionDone = true
            self:applyAction(action)
        end
    end

    if not actionDone then
        self:applyAction("noInput")
    end

    self:updatePicture(dt)
end

-- Transfer the pressed key to the controller for interpretation
function Character:applyInput(keyPressed)
    self.controller:applyInput(keyPressed)
end

-- applies the action on the character
function Character:applyAction(action)
    if self.automate:applyAction(action) and self:getState() ~= self.lastState then --if the state has changed
        self.lastState = self:getState()
        self:loadAnimation()
    end
end

function Character:getState()
    return self.automate.currentState
end

function Character:loadAnimation()
    -- change the animation
    self.pictureTimer = 0
    self.currentPic = 1
end

function Character:getCurrentPicture()
    return self.sprites[Character.spritesFolders[self:getState()]][self.currentPic]
end

--updates the picture to draw regarding the timer set for the current one
function Character:updatePicture(dt)
    self.pictureTimer = self.pictureTimer + dt
    if self.pictureTimer > self.pictureDuration then
        self.pictureTimer = 0
        self.currentPic = self.currentPic % table.getn(self.sprites[Character.spritesFolders[self:getState()]]) + 1
    end
end

function Character:draw()
    love.graphics.setColor(255,255,255,255)
    local flipped
    if self.facingRight then flipped = 1 else flipped = -1 end
    love.graphics.draw(self:getCurrentPicture(), 
        self.body:getX() - (flipped * Character.width/2),
        self.body:getY() - Character.height/2,
        0, flipped, 1)
end

--in case of debugging, display some useful informations
function Character:drawDebug()
    love.graphics.setColor(0,255,0)
    love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))

    love.graphics.setColor(0,255,0)
    love.graphics.print("X : " .. self.body:getX() .. ", Y = " .. self.body:getY() ..
        "\nPicture Number : " .. self.currentPic ..
        "\nState is : " .. self:getState() ..
        "\nMass is : " .. self.body:getMass()..
        "\nAutoTimer = " .. self.automate.lastTimer,
        self.body:getX(), self.body:getY() - 150)
end

return Character
