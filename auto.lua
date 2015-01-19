Automate = class('Automate') -- class Automate

function Automate:initialize(states, state) -- Initalisation Automate
    self.states = states
    self.currentState = state
    self.lastTimer = love.timer.getTime()
end

function Automate:applyEvent(event) --returns true if the state has changed
    local lastState = self.currentState
    if event then
        local newState = self.states[self.currentState][event]
        if newState then -- a nil newState means the transition doesn't exist so we assume that we have to stay in the same state
            self.currentState = newState
        end
    end

    if lastState == self.currentState then
        local currentTime = love.timer.getTime()
        if (currentTime - self.lastTimer) > self.states[self.currentState]["TIME"] then
            self.currentState = self.states[self.currentState]["T"]
            self.lastTimer = love.timer.getTime()
        end
        return false
    else
        self.lastTimer = love.timer.getTime()
        return true
    end
end
