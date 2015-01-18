class = require 'middleclass'
require "character"

graphicsFolder = "graphics"

function loadWorld()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
end

function loadCharacters()
    return {
        Character("Mouton", 300, 300)
    }
end

function love.load()
    frameTime = 0.5
    loadWorld()
    characters = loadCharacters()
    love.window.setTitle("FightIF")
end

function love.update(dt)
    for i,character in ipairs(characters) do
        if love.keyboard.isDown("left") then
                character:press("L")
        elseif love.keyboard.isDown("right") then
                character:press("R")
        elseif love.keyboard.isDown(" ") then
                character:press("S")
        else
                character:press("N")
        end
        character:update(dt)
    end
end

function love.draw()
    -- let's draw some ground
    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle("fill", 0,465,800,150)
    
    for i,character in ipairs(characters) do
        character:draw()
    end
end



