local StaticBody = {}

function StaticBody.new(world, x, y, width, height, color)
    local self = {}

    self.width = width
    self.height = height
    self.x = x
    self.y = y
    self.color = color
    
    self.body = love.physics.newBody(world, self.x, self.y, "static")
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    function self.draw()
        local body_x, body_y = self.body:getPosition()

        love.graphics.setColor(self.color[1] / 255, self.color[2] / 255, self.color[3] / 255)
        love.graphics.rectangle("fill", body_x - self.width / 2, body_y - self.height / 2, self.width, self.height)
    end

    return self
end

return StaticBody
