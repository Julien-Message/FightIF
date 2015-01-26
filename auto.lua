Automate = class('Automate') -- class Automate

function Automate:initialize(states, state) -- Initalisation Automate
    self.states = states
    self.currentState = state
	self.nextState = state
    self.lastTimer = love.timer.getTime()
end

function Automate:applyEvent(event) --returns true if the state has changed
    local lastState = self.currentState
    if event then -- an event has been 
        local newState = self.states[self.currentState][event]
        if newState then -- we check if there is a state corresponding to the event
			self.currentState = newState
            if self.states[self.currentState]["Timer"] then
                self.lastTimer = love.timer.getTime()
            end
            return true
        end
    end
    return false
end

function Automate:checkTimer()
    if self.states[self.currentState]["Timer"]  -- we just check if a timer is finished
        and (love.timer.getTime() - self.lastTimer) > self.states[self.currentState]["Timer"] then
        self.currentState = self.states[self.currentState]["Time"]
        self.lastTimer = love.timer.getTime()
        return true
    else
        return false
    end
end