require "auto"

Character = class('Character')

Character.static.width = 64
Character.static.height = 128

Character.static.states = {
    Idle = {move = "Moving", jump = "Jumping", fall = "Falling", guard = "Guarding", punch = "Punching", kick = "Kicking", stunningPunch = "Stunned"},
    
    Moving = {stop="Idle", jump = "Jumping", fall = "Falling", punch = "PunchingForward", kick = "KickingForward", guard = "Guarding", stunningPunch = "Stunned"},
    
    Jumping = {Time = "Falling", punch = "Uppercut", kick = "JumpingKick", Timer = 0.3},
    Falling = {move="Falling", hitTheGround = "Idle", punch = "Uppercut", kick = "JumpingKick", hitTheGroundMoving = "Moving", jump = "JumpingAgain"},
    FallingAfterPunch = {move = "FallingAfterPunch", hitTheGround = "Idle", hitTheGroundMoving = "Moving", jump = "JumpingAgain"},
    
    JumpingAgain = {Time = "FallingAgain", punch = "UppercutSecondJump", kick = "JumpingKick", Timer = 0.3},
    FallingAgain = {move = "FallingAgain", hitTheGround = "Idle", punch = "UppercutSecondJump", kick = "JumpingKick", hitTheGroundMoving = "Moving"},
    FallingAgainAfterPunch = {move = "FallingAgainAfterPunch", hitTheGround = "Idle", hitTheGroundMoving = "Moving"},
    
    Guarding = {stop = "Idle"},
    
    Punching = {punch = "Punching2", kick = "Kicking2", timer = 10, Time = "Idle", Timer = 0.3},
    Punching2 = {punch = "PunchingFinal", kick = "KickingFinal", timer = 0.3, Time = "Idle", Timer = 0.3},
    PunchingFinal = {Time = "Idle", Timer = 0.5},
    
    Kicking = {kick = "Kicking2", punch = "Punching2", timer = 0.5, Time = "Idle", Timer = 0.5},
    Kicking2 = {kick = "KickingFinal", punch = "PunchingFinal", timer = 0.5, Time = "Idle", Timer = 0.5},
    KickingFinal = {Time = "Idle", Timer = 0.7},
    
    PunchingForward = {Time = "Moving", Timer = 0.3},
    KickingForward = {Time = "Moving", Timer = 0.3},
    
    Uppercut = {Time = "FallingAfterPunch", Timer = 0.5},
    UppercutSecondJump = {Time = "FallingAgainAfterPunch", Timer = 0.5},
    
    JumpingKick = {hitTheGround = "Idle", hitTheGroundMoving = "Moving", Time = "Falling", Timer = 1},
    
    Stunned = {Time = "Idle", Timer = 0.75}
}

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
    Kicking2 = "kick",
    KickingFinal = "kick",
    KickingForward = "kick",
    JumpingKick = "kick",

    Punching = "punch",
    Punching2 = "punch",
    PunchingFinal = "punch",
    PunchingForward = "punch",
    Uppercut = "punch",
    UppercutSecondJump = "punch",

    Stunned = "stun"
}

Character.static.actions = {
    right = function (character)
        if character.automate:applyEvent("move") then
            local _,y = character.body:getLinearVelocity()
            character.body:setLinearVelocity(character.speed, y)
            character.facingRight = true
            return true
        else
            return false
        end
    end,

    left = function (character)
        if character.automate:applyEvent("move") then
            local _,y = character.body:getLinearVelocity()
            character.body:setLinearVelocity(-character.speed, y)
            character.facingRight = false
            return true
        else
            return false
        end
    end,

    jump = function (character)
        if character.automate:applyEvent("jump") then
            local x,y = character.body:getLinearVelocity()
            character.body:setLinearVelocity(x, -character.jumpSpeed)
            return true
        end
    end,

    guard = function (character)
        if character.automate:applyEvent("guard") then
            character.body:setLinearVelocity(0,0)
            return true
        else
            return false
        end
    end,

    punch = function (character)
        if character.automate:applyEvent("punch") then
            return true
        else
            return false
        end
    end,

    kick = function (character)
        if character.automate:applyEvent("kick") then
            return true
        else
            return false
        end
    end,

    stop = function (character)
        if character.automate:applyEvent("stop") then
            character.body:setLinearVelocity(0,0)
            return true
        else
            return false
        end
    end,

    hitTheGround = function (character)
        local dx,_ = character.body:getLinearVelocity()
        if dx == 0 then
            return character.automate:applyEvent("hitTheGround")
        else
            return character.automate:applyEvent("hitTheGroundMoving")
        end
    end,

    noInput = function (character)
        if character:getState() == "Moving" or character:getState() == "Guarding" then
            return character:applyAction("stop")
        end
    end,

    default = function (character)
        local x, y, dx, dy = character.body:getX(), character.body:getY(), character.body:getLinearVelocity()
        local state = character:getState()
        local result = false
        if Character.states[state]["hitTheGround"]  then
            if dy == 0 then
                result = result or character:applyAction("hitTheGround")
            end
        elseif dy > 0 then
            result = result or character.automate:applyEvent("fall")
        end
        --check if a timer has finished
        result = result or character.automate:checkTimer()
        return result
    end
}

function Character:initialize(name, x, y)
    self.name = name

-- sets the physic
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newRectangleShape( Character.width, Character.height )
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.body:setFixedRotation(true)
    self.fixture:setFriction(0)

    self.speed = 200
    self.jumpSpeed = 500

    self.automate = Automate(Character.states, "Idle")
    self.lastState = "Idle"

--sets the inputs and their actions
    self.punctualInputs = {
        z  = "jump",
        i = "punch",
        k = "kick"
    }

    self.continuousInputs = {
        d = "right",
        q = "left",
        s = "guard"
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
    if Character.actions[action](self) and self:getState() ~= self.lastState then --if the state has changed
        self.lastState = self:getState()
        self:loadAnimation()
    end
end

function Character:getState()
    return self.automate.currentState
end


function Character:getNextState()
    return self.automate.nextState
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
    love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.print("X : " .. self.body:getX() .. ", Y = " .. self.body:getY() ..
        "\nPicture Number : " .. self.currentPic ..
        "\nState is : " .. self:getState() ..
        "\nMass is : " .. self.body:getMass()..
        "\nAutoTimer = " .. self.automate.lastTimer ..
        "\nnextState is :" .. self:getNextState(),
        self.body:getX(), self.body:getY() - 150)
end
