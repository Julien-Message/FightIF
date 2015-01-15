local _M = {}

local class = require("middleclass")

_M.Automate = class('Automate') -- class Automate
function _M.Automate:init() -- Initalisation Automate
    self.tableEtat = {}
    self.sprites = {}
    self.Etat = nil
    self.lastTimer = nil
end

function _M.Automate:ChangeEtat(input)
    local lastEtat = self.Etat
    if input then
        self.Etat = self.tableEtat[self.Etat][input]
    end

    if (lastEtat == self.Etat) then
        local currentTime = love.timer.getTime()
        if (currentTime - self.lastTimer) > self.tableEtat[self.Etat]["TIME"] then
            self.Etat = self.tableEtat[self.Etat]["T"]
            self.lastTimer = love.timer.getTime()
        end
    else
        self.lastTimer = love.timer.getTime()
    end
    
end

function _M.Automate:DrawEtat()
    return self.sprites[self.Etat]
end 

return _M
