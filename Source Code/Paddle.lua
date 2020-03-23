Paddle = Class{}

function Paddle: init(x, y, width, height, paddleSpeed)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.paddleSpeed = 0
end

function Paddle: update(dt)
    if self.paddleSpeed < 0 then
        self.y = math.max(0, self.y + self.paddleSpeed*dt)
    else
        self.y = math.min(virtualHeight - self.height, self.y + self.paddleSpeed*dt)
    end
end

function Paddle: aiMovement()
    if gameState == 'play' then
        if(self.y > ball.y) then
            self.paddleSpeed = -paddleSpeed
        else
            self.paddleSpeed = math.abs(paddleSpeed)
        end
   end
end

function Paddle: render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end