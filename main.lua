class = require 'middleclass'
require "character"

mainGraphicsFolder = "graphics"

function love.load()
    frameTime = 0.5
    mouton = Character("Mouton", 300, 300)
    love.window.setTitle("Le Mouton")
end

function love.update(dt)
    if love.keyboard.isDown("left") then
            mouton:press("L")
    elseif love.keyboard.isDown("right") then
            mouton:press("R")
    else
            mouton:press("N")
    end
    mouton:update(dt)
end

function love.draw()
    -- let's draw some ground
    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle("fill", 0,465,800,150)

    -- let's draw our mouton
    mouton:draw()
end



