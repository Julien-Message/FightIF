auto = require 'auto'

function love.load()
    local frameTime = 0.5
    moutonObj = auto.Automate:new()
    moutonObj.tableEtat = {Nothing = {R = "Right1", L = "Left1", N="Nothing",T = "Nothing", TIME = frameTime}, Right1 = {R = "Right1", L = "Left1",N="Nothing", T = "Right2", TIME = frameTime},Left1 = {R = "Right1", L = "Left1", T = "Left2", N="Nothing", TIME = frameTime}, Right2 = {R = "Right2", L="Left1",N="Nothing", T = "Right1", TIME = frameTime}, Left2={R="Right1", L="Left2",N="Nothing", T="Left1", TIME=frameTime}}
    
    moutonObj.sprites = {Nothing = "sheep.png", Right1="sheepright1.png", Right2 = "sheepright2.png", Left1 = "sheepleft1.png", Left2 = "sheepleft2.png"}

    moutonObj.Etat = "Nothing"
    moutonObj.lastTimer = love.timer.getTime()
    
    mouton = {} -- new table for the mouton
    mouton.x = 300    -- x,y coordinates of the mouton
    mouton.y = 300
    mouton.speed = 100
    love.window.setTitle("Le Mouton")
end

function love.update(dt)
    if love.keyboard.isDown("left") then
            moutonObj:ChangeEtat("L")
            mouton.x = mouton.x - mouton.speed*dt
    elseif love.keyboard.isDown("right") then
            moutonObj:ChangeEtat("R")
            mouton.x = mouton.x + mouton.speed*dt
    else
            moutonObj:ChangeEtat("N")
    end
end

function love.draw()
    -- let's draw some ground
    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle("fill", 0,465,800,150)

    -- let's draw our mouton
    love.graphics.setColor(255,255,255,255)
    hr = love.graphics.newImage(moutonObj:DrawEtat())
    love.graphics.draw(hr, mouton.x, mouton.y)
end



