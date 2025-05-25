local Player = {}

function Player.new(world, x, y, width, height, color, jump_power)
    local self = {}

    self.width = width or 80
    self.height = height or 80
    self.jump_power = jump_power or 400
    self.onfloor = false
    self.color = color

    self.jumping = false
    self.right = false
    self.left = false
    self.move_speed = 300
    self.smooth_factor = 20

    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    function self.update(dt)
        local v_x, v_y = player.body:getLinearVelocity()

        local target_vx = 0
        if self.right then
            target_vx = self.move_speed
        elseif self.left then
            target_vx = -self.move_speed
        end

        -- Smooth transition to target velocity
        local new_vx = v_x + (target_vx - v_x) * self.smooth_factor * dt
        self.body:setLinearVelocity(new_vx, v_y)

        -- Free fall and spin
        if math.abs(v_y) < 0.1 then
            self.onfloor = true
        else
            self.onfloor = false
        end

        -- Jump Logic
        if self.jumping and self.onfloor then
            self.body:applyLinearImpulse(0, -self.jump_power)
        end

        -- Lock angle in between 0 and 2pi
        self.body:setAngle((self.body:getAngle() + math.pi * 2) % (math.pi * 2))
    end

    function self.draw()
        love.graphics.setColor(self.color[1] / 255, self.color[2] / 255, self.color[3] / 255)
        love.graphics.push()
        love.graphics.translate(self.body:getPosition())
        love.graphics.rotate(self.body:getAngle())
        love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height)
        love.graphics.pop()
    end

    return self
end

return Player
