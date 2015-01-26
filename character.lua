require "auto"

Character = class('Character')

Character.static.width = 64
Character.static.height = 128
Character.static.quad = love.graphics.newQuad(0, 0, Character.width, Character.height, Character.width, Character.height)
Character.static.movingStates = {"Idle", "Moving", "Falling", "FallingAgain"}
Character.static.jumpingStates = {"Idle", "Moving", "Falling"}

Character.static.states = {
    Idle = {move = "Moving", jump = "Jumping", fall = "Falling", guard = "Guarding", punch = "Punching", kick = "Kicking", stunningPunch = "Stunned"},
    Moving = {stop="Idle", jump = "Jumping", fall = "Falling", punch = "PunchingForward", kick = "KickingForward", guard = "Guarding", stunningPunch = "Stunned"},
    Jumping = {Time = "Falling", punch = "Upercut", kick = "JumpingKick", Timer = 0.3},
    Falling = {hitTheGround = "Idle", punch = "Upercut", kick = "JumpingKick", hitTheGroundMoving = "Moving", jump = "JumpingAgain"},
	FallingAfterPunch = {hitTheGround = "Idle", hitTheGroundMoving = "Moving", jump = "JumpingAgain"},
    JumpingAgain = {Time = "FallingAgain", punch = "UpercutSecondJump", kick = "JumpingKick", Timer = 0.3},
    FallingAgain = {hitTheGround = "Idle", punch = "UpercutSecondJump", kick = "JumpingKick", hitTheGroundMoving = "Moving"},
	FallingAgainAfterPunch = {hitTheGround = "Idle", hitTheGroundMoving = "Moving"},
	Guarding = {stop = "Idle", jump = "Jumping", move = "Moving", punch = "Punching" },
	Punching = {Time = "Idle", Timer = 0.3},
	Kicking = {Time = "Idle", Timer = 0.5},
	PunchingForward = {Time = "Moving", Timer = 0.3},
	KickingForward = {Time = "Moving", Timer = 0.3},
	Upercut = {Time = "FallingAfterPunch", Timer = 0.5},
	UpercutSecondJump = {Time = "FallingAgainAfterPunch", Timer = 0.5},
	JumpingKick = {hitTheGround = "Idle", hitTheGroundMoving = "Moving", Time = "Falling", Timer = 1},
	Stunned = {Time = "Idle", Timer = 0.75}
}

function Character:initialize(name, x, y)
    self.name = name

-- sets the physic
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newRectangleShape( Character.width, Character.height )
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.body:setFixedRotation(true)
    self.fixture:setFriction(0)

    self.speed = 100

    self.automate = Automate(Character.states, "Idle")

--sets the inputs and their actions
    self.punctualInputs = {
        v  = "jump",
        b = "punch"
    }

    self.continuousInputs = {
        right = "right",
        left = "left",
        g = "guard"
    }

    self.actions = {
        right = function ()
            if self:canMove() then
                local _,y = self.body:getLinearVelocity()
                self.body:setLinearVelocity(self.speed, y)
                self.facingRight = true
                return self.automate:applyEvent("move")
            end
        end,

        left = function ()
            if self:canMove() then
                local _,y = self.body:getLinearVelocity()
                self.body:setLinearVelocity(-self.speed, y)
                self.facingRight = false
                return self.automate:applyEvent("move")
            end
        end,

        jump = function ()
            if self:canMove() and self:canJump() and self.automate:applyEvent("jump") then
                local x,y = self.body:getLinearVelocity()
                self.body:setLinearVelocity(x, -300)
                return true
            end
        end,

        guard = function ()
            return false
        end,

        punch = function ()
            return false
        end,

        stop = function ()
            self.body:setLinearVelocity(0,0)
            return self.automate:applyEvent("stop")
        end,

        hitTheGround = function ()
            local dx,_ = self.body:getLinearVelocity()
            if dx == 0 then
                return self.automate:applyEvent("hitTheGround")
            else
                return self.automate:applyEvent("hitTheGroundMoving")
            end
        end,

        noInput = function ()
            if self:getState() == "Moving" then
                return self:applyAction("stop")
            end
        end,

        default = function ()
            local x, y, dx, dy = self.body:getX(), self.body:getY(), self.body:getLinearVelocity()
            if self:getState() == "Falling" or self:getState() == "FallingAgain" then
                if dy == 0 then
                    return self:applyAction("hitTheGround")
                end
            elseif dy > 0 then
                    return self.automate:applyEvent("fall")
            end
            --check if a timer has finished
            self.automate:applyEvent()
        end
    }

    -- loads the sprites into a table for quick access
    self.sprites = {}
    for _,folder in ipairs(love.filesystem.getDirectoryItems(graphicsFolder .. "/" .. name)) do
        self.sprites[folder] = {}
        for _,picture in ipairs(love.filesystem.getDirectoryItems(graphicsFolder .. "/" .. name .. "/" .. folder)) do
            table.insert(self.sprites[folder],
                love.graphics.newImage(graphicsFolder .. "/" .. name .. "/" .. folder .. "/" .. picture))
        end
    end

    self.spritesFolders = {
        Idle = "idle",
        Moving = "move",
        Jumping = "jump",
        Falling = "jump",
        JumpingAgain = "jump",
        FallingAgain = "jump"
    }

    self.facingRight = true

    self.currentPic = 1
    self.pictureTimer = 0
    self.pictureDuration = 0.3
end

--looks which key is down and do the necessary things
function Character:update(dt)
    local actionDone = false

    for input, event in pairs(self.continuousInputs) do
        if love.keyboard.isDown(input) then
            actionDone = true
            self:applyAction(event)
        end
    end

    if not actionDone then
        self:applyAction("noInput")
    end
    self:applyAction("default")

    self:updatePicture(dt)
end

--apply an interrupting input
function Character:applyInput(keyPressed)
    if self.punctualInputs[keyPressed] then
        self:applyAction(self.punctualInputs[keyPressed])
    end
end

-- applies the action on the character
function Character:applyAction(action)
    if self.actions[action]() then --if the state has changed
        self:loadAnimation()
    end
end

function Character:getState()
    return self.automate.currentState
end

function Character:canMove()
    local currentState = self:getState()
    for _,state in ipairs(Character.movingStates) do
        if currentState == state then
            return true
        end
    end
    return false
end

function Character:canJump()
    local currentState = self:getState()
    for _,state in ipairs(Character.jumpingStates) do
        if currentState == state then
            return true
        end
    end
    return false
end

function Character:loadAnimation()
    -- change the animation
    self.pictureTimer = 0
    self.currentPic = 1
end

function Character:getCurrentPicture()
    currentState = self:getState()
    return self.sprites[self.spritesFolders[self:getState()]][self.currentPic]
end

--updates the picture to draw regarding the timer set for the current one
function Character:updatePicture(dt)
    self.pictureTimer = self.pictureTimer + dt
    if self.pictureTimer > self.pictureDuration then
        self.pictureTimer = 0
        self.currentPic = self.currentPic % table.getn(self.sprites[self.spritesFolders[self:getState()]]) + 1
    end
end

function Character:draw()
    love.graphics.setColor(255,255,255,255)
    local flipped
    if self.facingRight then flipped = 1 else flipped = -1 end
    love.graphics.draw(self:getCurrentPicture(), Character.quad,
        self.body:getX() - (flipped * Character.width/2), self.body:getY() - Character.height/2, rotation, flipped, 1)
end

--in case of debugging, display some useful informations
function Character:drawDebug()
    love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.print("X : " .. self.body:getX() .. ", Y = " .. self.body:getY() ..
        "\nPicture Timer : " .. self.pictureTimer ..
        "\nState is : " .. self:getState() ..
        "\nMass is : " .. self.body:getMass(),
        self.body:getX(), self.body:getY() - 150)
end
