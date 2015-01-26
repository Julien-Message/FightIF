local class = require 'middleclass'

--[[
Input refers to pushed buttons on keyboard and action refers to the demanded action from the character class view.

Possible actions are :
goRight
goLeft
jump
punch
kick
guard
--]]
local Controller = class('Controller')

function Controller:initialize(_possibleInputs)
    self.possibleInputs = _possibleInputs
    self.inputList = {}
end

function Controller:update()
    self.inputList = {}
    for input,action in pairs(self.possibleInputs) do
        if love.keyboard.isDown(input) then
            self.inputList[action] = true
        end
    end
end   

function isDemanded(action)
    if self.inputList[action] then
        return true
    else
        return false
    end
end
return Controller 
