Automate = class('Automate') -- class Automate

function Automate:initialize(states, state) -- Initalisation Automate
    self.states = states
    self.currentState = state
	self.nextState = state
    self.lastTimer = love.timer.getTime()
end

function Automate:applyEvent(event) --returns true if the state has changed
    local lastState = self.currentState
    if event then
        local newState = self.states[self.currentState][event]
        if newState then -- a nil newState means the transition doesn't exist so we assume that we have to stay in the same state
			if self.states[self.currentState]["timer"] then  -- Check if there is a minimum time to stay in that state.
				self.nextState = self.states[self.currentState]["timer"]
			else
				self.currentState = newState
			end
        end
    end

    if lastState == self.currentState then
        if self.states[self.currentState]["Timer"]
            and (love.timer.getTime() - self.lastTimer) > self.states[self.currentState]["Timer"] then
            self.currentState = self.states[self.currentState]["Time"]
            self.lastTimer = love.timer.getTime()
        end
		if self.states[self.currentState]["timer"]
			and (love.timer.getTime() - self.lastTimer) > self.states[self.currentState]["Timer"]
			and self.nextState ~= self.currentState then
			self.currentState = self.nextState
			self.lastTimer = love.timer.getTime()
			self.nextState = self.currentState
		end
        return false
    else
        self.lastTimer = love.timer.getTime()
        return true
    end
end
