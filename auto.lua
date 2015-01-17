Automate = class('Automate') -- class Automate

function Automate:initialize(states, state) -- Initalisation Automate
    self.states = states
    self.currentState = state
    self.lastTimer = love.timer.getTime()
end

function Automate:applyEvent(input) --returns true if the state has changed
    local lastState = self.currentState
    if input then
        self.currentState = self.states[self.currentState][input]
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
