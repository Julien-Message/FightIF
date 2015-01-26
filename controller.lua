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

function Controller:initialize(_punctualInputs, _continuousInputs)
    self.punctualInputs = _punctualInputs
    self.continuousInputs = _continuousInputs
    self.inputList = {}
end

-- Sets the character of the controller
function Controller:setCharacter(_character)
    self.character = _character
end

-- Applies punctual inputs on the character
function Controller:applyInput(keyPressed)
    if self.character then
        if self.punctualInputs[keyPressed] then
            self.character:applyAction(self.punctualInputs[keyPressed])
        end
    end
end

function Controller:update()
    self.inputList = {}
    for input,action in pairs(self.continuousInputs) do
        if love.keyboard.isDown(input) then
            self.inputList[action] = true
        end
    end
end   

function Controller:isDemanded(action)
    if self.inputList[action] then
        return true
    else
        return false
    end
end

return Controller 
