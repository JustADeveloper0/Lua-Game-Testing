local Player = require("player")
local StaticBody = require("static_body")
local Button = require("button")

local json = require("libs.json")

local in_menu = true

function love.load()
    WIDTH = 1200
    HEIGHT = 800
    GRID_SIZE = 80

    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Puzzle Cube")

    world = love.physics.newWorld(0, 750, true)

    -- Game
    player = Player.new(world, GRID_SIZE * 5 - 37.5, HEIGHT - 75, 75, 75, {0, 255, 0}, 4000)
    floor = StaticBody.new(world, WIDTH / 2, HEIGHT - 40, WIDTH, 80, {0, 0, 255})

    -- Menu
    button = Button.new(WIDTH / 2 - 150, HEIGHT / 2 - 75, 300, 150, "Play!", 40, {255, 255, 255}, {22, 102, 150}, {28, 125, 183}, 0.2, function() in_menu = false end, 5, "fonts/PressStart2P-Regular.ttf")

    font_size = 12
    stats_font = love.graphics.newFont(font_size)

    GRID = false

    local level_data = LoadLevelData("levels.json")
    local level = level_data.level_1

    TILES = {}

    for row = 1, level.height do
        local current_row = {}
        for col = 1, level.width do
            local tile = level.grid[row][col]

            if tile == 1 then
                local tile_x = (((col - 1) * GRID_SIZE) + GRID_SIZE / 2) + 0--WIDTH
                local tile_y = (row - 1) * GRID_SIZE + GRID_SIZE / 2
                table.insert(current_row, StaticBody.new(world, tile_x, tile_y, GRID_SIZE, GRID_SIZE, {255, 0, 0}))
            end
        end
        table.insert(TILES, current_row)
    end

    parallaxSpeeds = {
        sky = 0.1,
        clouds_bg = 0.3,
        clouds_mg_3 = 0.5,
        clouds_mg_2 = 0.7,
        clouds_mg_1 = 0.9,
        glacial_mountains = 1.1,
        cloud_lonely = 1.5
    }

    parallaxMulitplier = 2500

    backgrounds = {
        sky = love.graphics.newImage("assets/background/sky.png"),
        clouds_bg = love.graphics.newImage("assets/background/clouds_bg.png"),
        clouds_mg_3 = love.graphics.newImage("assets/background/clouds_mg_3.png"),
        clouds_mg_2 = love.graphics.newImage("assets/background/clouds_mg_2.png"),
        clouds_mg_1 = love.graphics.newImage("assets/background/clouds_mg_1.png"),
        glacial_mountains = love.graphics.newImage("assets/background/glacial_mountains.png"),
        cloud_lonely = love.graphics.newImage("assets/background/cloud_lonely.png"),
    }

    parallaxPositions = {}
    for key, _ in pairs(backgrounds) do
        parallaxPositions[key] = 0
    end

    drawOrder = {
        "sky",
        "clouds_bg",
        "glacial_mountains",
        "cloud_lonely",
        "clouds_mg_3",
        "clouds_mg_2",
        "clouds_mg_1"
    }
end

function LoadLevelData(filename)
    local file = love.filesystem.read(filename)
    local level_data = json.decode(file)
    return level_data
end

function love.update(dt)
    if in_menu then
        for name, speed in pairs(parallaxSpeeds) do
            parallaxPositions[name] = parallaxPositions[name] - (parallaxMulitplier * (speed / 100) * dt)
    
            local img = backgrounds[name]
            local imgWidth = img:getWidth()
    
            if parallaxPositions[name] <= -imgWidth then
                parallaxPositions[name] = parallaxPositions[name] + imgWidth
            end
        end
    else
        world:update(dt)
        player.update(dt)
    end
end

function love.draw()
    if in_menu then
        love.graphics.setColor(1, 1, 1)

        for _, background in ipairs(drawOrder) do
            love.graphics.draw(backgrounds[background], parallaxPositions[background], 0)
            love.graphics.draw(backgrounds[background], parallaxPositions[background] + backgrounds[background]:getWidth(), 0)
        end

        button.draw()

        -- Stats
        local mx, my = love.mouse.getPosition()

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(stats_font)
        love.graphics.print("Mouse Position: (" .. mx .. ", " .. my .. ")", 0, 0)
    else
        player.draw()
        floor.draw()
    
        -- Stats
        local x, y = player.body:getPosition()
        local vx, vy = player.body:getLinearVelocity()
    
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(stats_font)
        love.graphics.print("Jumping: " .. tostring(player.jumping), 0, 0)
        love.graphics.print("On Floor: " .. tostring(player.onfloor), 0, font_size)
        love.graphics.print("Position: (" .. x .. ", " .. y .. ")", 0, font_size * 2)
        love.graphics.print("Velocity: (" .. vx .. ", " .. vy .. ")", 0, font_size * 3)
        love.graphics.print("Angle: " .. tostring((player.body:getAngle() / math.pi) * 180), 0, font_size * 4)
        love.graphics.print("Grid: " .. tostring(GRID), 0, font_size * 5)
    
        -- Draw Grid
        if GRID then
            for i = 0, WIDTH, GRID_SIZE do
                for j = 0, HEIGHT - floor.height - 1, GRID_SIZE do
                    love.graphics.rectangle("line", i, j, GRID_SIZE, GRID_SIZE)
                end
            end
        end
    
        -- Draw Level
        for i, row in ipairs(TILES) do
            for j, tile in ipairs(row) do
                tile.draw()
            end
        end
    end
end

function love.mousepressed(x, y, mousebtn)
    button.mousepressed(x, y, mousebtn)
end

function love.keypressed(key)
    if in_menu then
        
    else
        if key == "space" then
            player.jumping = true
        end
    
        if key == "d" then
            player.right = true
        end
    
        if key == "a" then
            player.left = true
        end
    
        if key == "g" then
            GRID = not GRID
        end
    end
end

function love.keyreleased(key)
    if in_menu then
        
    else
        if key == "space" then
            player.jumping = false
        end
    
        if key == "d" then
            player.right = false
        end
    
        if key == "a" then
            player.left = false
        end
    end

end
