local Character = require "character"
local Controller = require "controller"

graphicsFolder = "graphics"
debug = true
windowLength = 1024
windowHeight = 768
local characters = {}

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit() -- quits the program
    elseif k == 'f2' then
        debug = not debug -- displays debug info or not
    elseif k == 'f1' then
        love.load()
    else
        for _,character in ipairs(characters) do
            character:applyInput(k)
        end
    end
end

function loadGround()
    local width = windowLength - 200 --try not falling !
    local height = 100
    ground = {}
    ground.body = love.physics.newBody(world, windowLength/2, windowHeight-height/2, "static") --remember, the shape anchors to the body from its center
    ground.shape = love.physics.newRectangleShape(width, height) --make a rectangle with a width of 650 and a height of 50
    ground.fixture = love.physics.newFixture(ground.body, ground.shape) --attach shape to body
end

function loadWorld()
    scale = 64 --pixels per meter
    love.physics.setMeter(scale)
    world = love.physics.newWorld(0, 15*scale, true) -- Unfortunately, we're not in space, so gravity
    loadGround()
end

function loadCharacters()
    --sets the inputs and their actions
    local punctualInputs = {
        z  = "jump",
        i = "punch",
        k = "kick"
    }

    local continuousInputs = {
        d = "right",
        q = "left",
        s = "guard"
    }
    local control1 = Controller(punctualInputs, continuousInputs)
    return {
        Character("Mouton", 100, 200, control1)
    }
    
end

function beginContact(fixture1, fixture2, contact)
    if fixture1 == ground.fixture then
        if fixture2 == characters[1].fixture then
            characters[1]:applyAction("hitTheGround")
        end
    elseif fixture2 == ground.fixture then
        if fixture1 == characters[1].fixture then
            characters[1]:applyAction("hitTheGround")
        end
    end
end

function love.load()
    frameTime = 0.5
    love.window.setMode(windowLength, windowHeight)
    love.window.setTitle("FightIF")
    loadWorld()
    characters = loadCharacters()
    world:setCallbacks(beginContact)
end

function love.update(dt)
    for _,character in ipairs(characters) do
        character:update(dt)
    end
    world:update(dt)
end

function love.draw()
    -- let's draw some ground
    love.graphics.setColor(72, 160, 14)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    for _,character in ipairs(characters) do
        if debug then
            character:drawDebug()
        end
        character:draw()
    end
end



