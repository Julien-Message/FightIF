local class = require "middleclass"

local Automate = class('Automate') -- class Automate

Automate.static.punchLength = 32
Automate.static.kickLength = 48

Automate.static.states = {
    Idle = {move = "Moving", jump = "Jumping", fall = "Falling", guard = "Guarding", punch = "Punching", kick = "Kicking", takeAHit = "Idle", takeAStunningHit = "Stunned"},
    
    Moving = {stop="Idle", move = "Moving", jump = "Jumping", fall = "Falling", punch = "PunchingForward", kick = "KickingForward", guard = "Guarding", hit = "Idle", takeAStunningHit = "Stunned"},
    
    Jumping = {Time = "Falling", punch = "Uppercut", kick = "JumpingKick", MaxTime = 0.3},
    Falling = {move="Falling", hitTheGround = "Idle", punch = "Uppercut", kick = "JumpingKick", jump = "JumpingAgain"},
    FallingAfterPunch = {move = "FallingAfterPunch", hitTheGround = "Idle", jump = "JumpingAgain"},
    
    JumpingAgain = {Time = "FallingAgain", punch = "UppercutSecondJump", kick = "JumpingKick", MaxTime = 0.3},
    FallingAgain = {move = "FallingAgain", hitTheGround = "Idle", punch = "UppercutSecondJump", kick = "JumpingKick", hitTheGroundMoving = "Moving"},
    FallingAgainAfterPunch = {move = "FallingAgainAfterPunch", hitTheGround = "Idle"},
    
    Guarding = {stop = "Idle"},
    
    Punching = {punch = "Punching2", kick = "Kicking2", MinTime = 0.3, takeAHit = "Idle", takeAStunningHit = "Stunned", Time = "Idle", MaxTime = 0.3},
    Punching2 = {punch = "PunchingFinal", kick = "KickingFinal", MinTime = 0.3, takeAHit = "Idle", takeAStunningHit = "Stunned", Time = "Idle", MaxTime = 0.3},
    PunchingFinal = {hit = "Idle", takeAStunningHit = "Stunned", Time = "Idle", MaxTime = 0.5},
    
    Kicking = {kick = "Kicking2", punch = "Punching2", MinTime = 0.5, takeAHit = "Idle", takeAStunningHit = "Stunned", Time = "Idle", MaxTime = 0.5},
    Kicking2 = {kick = "KickingFinal", punch = "PunchingFinal", MinTime = 0.5, takeAHit = "Idle", takeAStunningHit = "Stunned", Time = "Idle", MaxTime = 0.5},
    KickingFinal = {hit = "Idle", takeAStunningHit = "Stunned", Time = "Idle", MaxTime = 0.7},
    
    PunchingForward = {Time = "Moving", takeAHit = "Idle", takeAStunningHit = "Stunned", MaxTime = 0.3},
    KickingForward = {Time = "Moving", takeAHit = "Idle", takeAStunningHit = "Stunned", MaxTime = 0.3},
    
    Uppercut = {Time = "FallingAfterPunch", MaxTime = 0.5, hitTheGround = "Idle", hitTheGroundMoving = "Moving"},
    UppercutSecondJump = {Time = "FallingAgainAfterPunch", MaxTime = 0.5, hitTheGround = "Idle", hitTheGroundMoving = "Moving"},
    
    JumpingKick = {hitTheGround = "Idle", hitTheGroundMoving = "Moving", Time = "Falling", MaxTime = 1, hitTheGround = "Idle", hitTheGroundMoving = "Moving"},
    
    Stunned = {Time = "Idle", MaxTime = 0.75}
}

Automate.static.events = {
    right = "move",
    left = "move",
    jump = "jump",
    guard = "guard",
    punch = "punch",
    kick = "kick",
    takeAHit = "takeAHit",
    takeAStunningHit = "takeAStunningHit",
    hitTheGround = "hitTheGround",
    hitTheGroundMoving = "hitTheGroundMoving",
    noInput = "stop",
    default = "default"
}

Automate.static.actions = {
    right = function (character)
        local _,y = character.body:getLinearVelocity()
        character.body:setLinearVelocity(character.speed, y)
    end,

    left = function (character)
        local _,y = character.body:getLinearVelocity()
        character.body:setLinearVelocity(-character.speed, y)
    end,

    jump = function (character)
        local x,y = character.body:getLinearVelocity()
        character.body:setLinearVelocity(x, -character.jumpSpeed)
    end,

    guard = function (character)
        character.body:setLinearVelocity(0,0)
    end,

    punch = function (character)
        for _,opponent in ipairs(characters) do
            if opponent ~= character then
                if love.physics.getDistance(character.fixture, opponent.fixture) < Automate.punchLength then
                    if character:getState() == "PunchingFinal" then
                        local audio = love.audio.newSource("sounds/PowerPunch.mp3")
                        audio:play()
                        opponent:applyAction("takeAStunningHit")
                    else
                        local audio = love.audio.newSource("sounds/Punch.mp3")
                        audio:play()
                        opponent:applyAction("takeAHit")
                    end
                end
            end
        end
    end,

    kick = function (character)
        for _,opponent in ipairs(characters) do
            if opponent ~= character then
                if love.physics.getDistance(character.fixture, opponent.fixture) < Automate.kickLength then
                    if character:getState() == "KickingFinal" then
                        local audio = love.audio.newSource("sounds/PowerKick.mp3")
                        audio:play()
                        opponent:applyAction("takeAStunningHit")
                    else
                        local audio = love.audio.newSource("sounds/Kick.mp3")
                        audio:play()
                        opponent:applyAction("takeAHit")
                    end
                end
            end
        end
    end,

    takeAHit = function (character)
        if not character:getState() == "Guarding" then
            character:losePV(10)
        else
            character:losePV(2)
        end
    end,

    takeAStunningHit = function (character)
        if not character:getState() == "Guarding" then
            character:losePV(20)
        else
            character:losePV(6)
        end
    end,


    hitTheGround = function (character)
    end,

    noInput = function (character)
    end,

    default = function (character)
        local x, y, dx, dy = character.body:getX(), character.body:getY(), character.body:getLinearVelocity()
        local state = character:getState()

        if Automate.states[state]["fall"] and dy > 10 then
            character.automate:applyEvent("fall")
        end

        if state == "Idle" or state == "Stunned" or Automate.states[state]["hitTheGround"] or Automate.states[state]["punch"] then
            character.body:setLinearVelocity(dx * 0.8, dy)
        end
        --check if a timer has finished
        character.automate:checkTimer()
    end
}

function Automate:initialize(character) -- Initalisation Automate
    self.character = character
    self.lastTimer = love.timer.getTime()
    self.currentState = "Idle"
    self.nextAction = nil
end

function Automate:applyAction(action)
    if action then -- an action has been 
        event = Automate.events[action]
        local newState = Automate.states[self.currentState][event]
        if newState then -- we check if there is a state corresponding to the event
            if Automate.states[self.currentState]["MinTime"] then  -- Check if there is a minimum time to stay in that state.
                print(action, event)
                self.nextAction = event
            else  
                self.currentState = newState
                Automate.actions[action](self.character)
                if Automate.states[self.currentState]["MaxTime"] then
                    self.lastTimer = love.timer.getTime()
                end
                return true
            end
        end
    end
    return false
 end

 function Automate:applyEvent(event)
     self.currentState = Automate.states[self.currentState][event]
 end

function Automate:checkTimer()
    local result = false
    
    if Automate.states[self.currentState]["MinTime"]
        and (love.timer.getTime() - self.lastTimer) > Automate.states[self.currentState]["MinTime"]
        and self.nextAction then
        self:applyEvent(self.nextAction)
        --print(self.nextAction, self.character.name)
        Automate.actions[self.nextAction](self.character)
        self.nextAction = nil
        self.lastTimer = love.timer.getTime()
        result = true
    end

    if Automate.states[self.currentState]["MaxTime"]  -- we just check if a timer is finished
        and (love.timer.getTime() - self.lastTimer) > Automate.states[self.currentState]["MaxTime"] then
        self.currentState = Automate.states[self.currentState]["Time"]
        self.lastTimer = love.timer.getTime()
        result = true
    end

    return result
end

return Automate
