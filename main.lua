local Character = require "character"
local Controller = require "controller"

graphicsFolder = "graphics"
debug = true
local windowLength = 1024
local windowHeight = 768

local barLength = 400
local barWidth = 60

local victory = 0

characters = {}

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
    local width = windowLength
    local height = 120
    arenaGround = love.graphics.newImage(graphicsFolder.."/Arena/battleground.png")
    ground = {}
    ground.body = love.physics.newBody(world, windowLength/2, windowHeight-height/2, "static") --remember, the shape anchors to the body from its center
    ground.shape = love.physics.newRectangleShape(width, height) --make a rectangle with a width of 650 and a height of 50
    ground.fixture = love.physics.newFixture(ground.body, ground.shape) --attach shape to body
    ground.fixture:setFriction(5)

    edgeLeft = {}
    edgeLeft.body = love.physics.newBody(world, 0, 0, "static")
    edgeLeft.shape = love.physics.newEdgeShape(0, 0, 0, windowHeight)
    edgeLeft.fixture = love.physics.newFixture(edgeLeft.body, edgeLeft.shape)

    edgeRight = {}
    edgeRight.body = love.physics.newBody(world, windowLength, 0, "static")
    edgeRight.shape = love.physics.newEdgeShape(0, 0, 0, windowHeight)
    edgeRight.fixture = love.physics.newFixture(edgeRight.body, edgeRight.shape)

end

function loadWorld()
    local scale = 64 --pixels per meter
    worldBG = love.graphics.newImage(graphicsFolder.."/Arena/fond.jpg")
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
    
    local punctualInputs2 = {
        up = "jump",
        f6 = "punch",
        f7 = "kick"    
    }

    local continuousInputs2 = {
        right = "right",
        left = "left",
        down = "guard"
    }

    local control2 = Controller(punctualInputs2, continuousInputs2)

    return {
        Character("Mouton", 200, 100, control1),
        Character("Bird", 600, 100, control2)
    }
    
end

function beginContact(fixture1, fixture2, contact)
    if fixture1 == ground.fixture or fixture2 == ground.fixture then
        local characterFixture
        if fixture1 == ground.fixture then
            characterFixture = fixture2
        else
            characterFixture = fixture2
        end

        for _,character in ipairs(characters) do
            if characterFixture == character.fixture then
                character:applyAction("hitTheGround")
            end
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
    if characters[1].isDead then
        victory = 2
    elseif characters[2].isDead then
        victory = 1
    else
        for _,character in ipairs(characters) do
            character:update(dt)
        end
    end
    world:update(dt)
end

function love.draw()
    -- let's draw some ground
    love.graphics.setColor(255,255,255,255)

    love.graphics.draw(worldBG, 0, 0)
    love.graphics.draw(arenaGround,0, windowHeight - 180 )

    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", 49, 49, barLength + 2, barWidth + 2)
    love.graphics.rectangle("line", windowLength - 50 - barLength - 1, 49, barLength + 2, barWidth + 2)

    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle("fill", 50, 50, barLength, barWidth)
    love.graphics.rectangle("fill", windowLength - 50 - barLength, 50, barLength, barWidth)

    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", 50, 50, barLength * characters[1]:getPV() / Character.maxPV, barWidth)
    love.graphics.rectangle("fill", windowLength - 50 - barLength * characters[2]:getPV() / Character.maxPV, 50, barLength * characters[2]:getPV() / Character.maxPV, barWidth)    


    if characters[1].body:getX() < characters[2].body:getX() then
        characters[1].facingRight = true
        characters[2].facingRight = false
    else
        characters[1].facingRight = false
        characters[2].facingRight = true
    end

    for _,character in ipairs(characters) do
        if debug then
            character:drawDebug()
        end
        character:draw()
    end

    if victory ~= 0 then
        love.graphics.setColor(255,0,0)
        love.graphics.print("Player " .. victory .. " wins !\nPress F1 to start again", 200, 300, 0, 5)
    end
end



