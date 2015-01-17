Automate = class('Automate') -- class Automate

function Automate:initialize() -- Initalisation Automate
    self.tableEtat = {}
    self.currentState = nil
    self.lastTimer = love.timer.getTime()
end

function Automate:changeEtat(input) --returns true if the state has changed
    local lastState = self.currentState
    if input then
        self.currentState = self.tableEtat[self.currentState][input]
    end

    if (lastState == self.currentState) then
        local currentTime = love.timer.getTime()
        if (currentTime - self.lastTimer) > self.tableEtat[self.currentState]["TIME"] then
            self.currentState = self.tableEtat[self.currentState]["T"]
            self.lastTimer = love.timer.getTime()
        end
        return false
    else
        self.lastTimer = love.timer.getTime()
        return true
    end
end
