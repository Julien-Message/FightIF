local class = require "middleclass"

local Automate = class('Automate') -- class Automate

function Automate:initialize(states, state) -- Initalisation Automate
    self.states = states
    self.currentState = state
    self.nextState = state
    self.lastTimer = love.timer.getTime()
end

function Automate:applyEvent(event) --returns true if the state has changed
    if event then -- an event has been 
        local newState = self.states[self.currentState][event]
        if newState then -- we check if there is a state corresponding to the event
            if self.states[self.currentState]["MinTime"] then  -- Check if there is a minimum time to stay in that state.
                self.nextState = newState
            else
                self.currentState = newState
                self.nextState = newState
                if self.states[self.currentState]["MaxTime"] then
                    self.lastTimer = love.timer.getTime()
                end
            end
            return true
        end
    end
    return false
end

function Automate:checkTimer()
    if self.states[self.currentState]["MaxTime"]  -- we just check if a timer is finished
        and (love.timer.getTime() - self.lastTimer) > self.states[self.currentState]["MaxTime"]
        and self.nextState == self.currentState then
        self.currentState = self.states[self.currentState]["Time"]
        self.lastTimer = love.timer.getTime()
        self.nextState = self.currentState
        return true
    else
        if self.states[self.currentState]["MinTime"]
            and (love.timer.getTime() - self.lastTimer) > self.states[self.currentState]["MinTime"]
            and self.nextState ~= self.currentState then
            self.currentState = self.nextState
            self.lastTimer = love.timer.getTime()
            self.nextState = self.currentState
            return true
        else
            return false
        end
    end
end

return Automate
