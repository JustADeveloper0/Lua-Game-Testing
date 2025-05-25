local Button = {}

function Button.new(x, y, width, height, text, text_size, text_color, color, hover_color, transition_duration, on_click, border_radius, font_file)
    local self = {}

    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text or "Default"
    self.text_size = text_size
    self.text_color = {text_color[1] / 255, text_color[2] / 255, text_color[3] / 255} or {1, 1, 1}
    self.color = {color[1] / 255, color[2] / 255, color[3] / 255} or {1, 1, 1}
    self.hover_color = {hover_color[1] / 255, hover_color[2] / 255, hover_color[3] / 255} or color
    self.on_click = on_click or function() print("Default") end
    self.border_radius = border_radius or 0
    self.transition_duration = transition_duration
    self.transition_time = 0
    self.font_file = font_file or nil

    if self.font_file ~= nil then
        self.font = love.graphics.newFont(font_file, text_size)
    else
        self.font = love.graphics.newFont(text_size)
    end

    function self.hovered(mx, my)
        return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
    end

    function self.draw()
        local mx, my = love.mouse.getPosition()
        local hovered = self.hovered(mx, my)

        if hovered then
            self.transition_time = math.min(self.transition_time + love.timer.getDelta(), self.transition_duration)
        else
            self.transition_time = math.max(self.transition_time - love.timer.getDelta(), 0)
        end
    
        local t = self.transition_time / self.transition_duration
        local r = self.color[1] + t * (self.hover_color[1] - self.color[1])
        local g = self.color[2] + t * (self.hover_color[2] - self.color[2])
        local b = self.color[3] + t * (self.hover_color[3] - self.color[3])

        love.graphics.setColor(r, g, b)

        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.border_radius, self.border_radius)

        love.graphics.setColor(self.text_color)
        love.graphics.setFont(self.font)
        love.graphics.printf(self.text, self.x, self.y + self.height / 2 - ((text_size) / 2), self.width, "center")
    end

    function self.mousepressed(x, y, button)
        if button == 1 and self.hovered(x, y) then
            self.on_click()
        end
    end

    return self
end

return Button
