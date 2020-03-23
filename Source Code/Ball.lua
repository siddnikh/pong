Ball = Class{}

function Ball: init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dx = math.random(2) == 1 and -200 or 200
    self.dy = math.random(-50, 50)
end

function Ball: reset()
    self.x = virtualWidth/2 - self.width
    self.y = virtualHeight/2 - self.height

    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)
end

function Ball: update(dt)
    if gameState == 'static' then
    if servingPlayer == 1 then
    self.x = self.x + math.abs(self.dx*dt)
    self.y = self.y + self.dy*dt
    else
        self.x = self.x - math.abs(self.dx*dt)
        self.y = self.y + self.dy*dt
    end
else
    self.x = self.x + self.dx*dt
    self.y = self.y + self.dy*dt
end
end

function Ball: render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball: collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false 
    end
    return true
end