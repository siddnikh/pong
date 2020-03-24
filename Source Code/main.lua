windowHeight = 768
windowWidth = 1366
virtualWidth = 432
virtualHeight = 243

paddleSpeed = 200
AIPaddleSpeed = 170
servingPlayer = 1
winningPlayer = 0

push = require 'push' --acquiring the push library
Class = require 'Class'
require 'Paddle'
require 'Ball'

sounds = {
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav' , 'static'),
    ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
}

function love.load()
    love.window.setTitle("Pong: A 1972 game remake")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    player1Score = 0
    player2Score = 0

    --the Y axes of the paddles as they cannot move horizontally
    player = Paddle(10, 30, 5, 20, paddleSpeed)
    AI = Paddle(virtualWidth - 20, virtualHeight - 30, 5, 20, AIPaddleSpeed)

    ball = Ball(virtualWidth/2 - 2, virtualHeight/2 - 2, 4, 4)

    gameState = 'static' --creating a game state so as to manipulate elements of the game, accordingly.
    titleFont = love.graphics.newFont('font.ttf', 12)
  --[[  love.window.setMode(windowWidth, windowHeight, {
        fullscreen = false,
        resizable = false,
        vsync = true
    }) ]] -- we could have used this, but for our purpose we're going to use the push library which sets us up with a virtual width and height for our game. 

    push: setupScreen(virtualWidth, virtualHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.resize(w, h)
    push: resize(w,h)
end

function love.keypressed(key)
    if key == 'escape' then  
        love.event.quit() --quits game if escape is pressed
    end

    --we press enter to toggle the game-states from play to start or start to play.
    if key == 'enter' or key == 'return' then
        if gameState == 'static' then
            gameState = 'play'
            sounds['score']:play()
        elseif gameState == 'done' then
            gameState = 'static'

            ball: reset()
            player1Score = 0
            player2Score = 0 
        end
    end
end

function love.update(dt)
    
    --left paddle movement
    if love.keyboard.isDown('w') then
        --as we have to move it upwards, we decrease the value to make it go up in our coordinate system
        player.paddleSpeed = -paddleSpeed -- this way it never goes beyond 0 on the x-axis.
        player: update(dt)
    elseif love.keyboard.isDown('s') then
        --as we have to move it downwards, we increase the value of its y-coordinate
        player.paddleSpeed = paddleSpeed
        player: update(dt)
    end

    --right paddle movement
    --[[if love.keyboard.isDown('up') then
        AI.paddleSpeed = -paddleSpeed
        AI: update(dt)
    elseif love.keyboard.isDown('down') then
        AI.paddleSpeed = paddleSpeed
        AI: update(dt)
    end]]

    if gameState == 'play' then --for collisions
        ball: update(dt)
        AI: aiMovement()
        AI: update(dt)
        if ball:collides(player) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx*1.2 --changing vertical speed component
            ball.x = player.x + 5 --not letting the ball go deep into the paddle
            if ball.dy < 0 then
                ball.dy = -math.random(ball.dy*1.2, 200) --changing horizontal component of speed
            else
                ball.dy = math.random(ball.dy*1.2, 200) --changing horizontal component of speed
            end
        end
        if ball:collides(AI) then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx*1.2
            ball.x = AI.x - 4
            if ball.dy < 0 then
                ball.dy = -math.random(ball.dy*1.2, 200) --changing horizontal component of speed
            else
                ball.dy = math.random(ball.dy*1.2, 200) --changing horizontal component of speed
            end
        end
        
        --upper and lower wall collisions
        if ball.y <= 0 or ball.y + ball.height >= virtualHeight then
            ball.dy = -ball.dy --just reversing the vertical speed of the ball
            sounds['wall_hit']:play()
        end

        if ball.x < -ball.width then --if the ball hits the left end of the screen
            player2Score = player2Score + 1
            ball:reset()
            sounds['score']:play()
            servingPlayer = 2
            gameState = "static"
            if player2Score >= 10 then
                gameState = 'done'
                winningPlayer = 2
            end
        end
        if ball.x >= virtualWidth then --if the ball hits the right end of the screen
            player1Score = player1Score + 1
            ball: reset()
            sounds['score']:play()
            servingPlayer = 1
            gameState = "static"
            if player1Score >= 10 then 
                gameState = 'done'
                winningPlayer = 1
            end
        end
    end

end

function love.draw()

    push: apply('start')    
    
    love.graphics.setFont(titleFont)
    --welcome text
    if gameState == 'static' then
        love.graphics.clear(40/255, 45/255, 52/255, 1) -- the greyish background. I used the values divided by 255 because I'm using a newer version of love2d
        love.graphics.printf(
            "PONG", --text
            0,              --X coordinate
            20, -- Y coordinate 
            virtualWidth,    --the alignment of the text is in respect to the whole window width.
            'center'        --alignment
    )
    if servingPlayer == 1 then
        love.graphics.printf("Player 1, serve!", 0, 44, virtualWidth, 'center')
    else
        love.graphics.printf("Press Enter when ready", 0, 44, virtualWidth, 'center')
    end
        love.graphics.printf( "Press Enter to serve", --text
        0,              --X coordinate
        virtualHeight - 30, -- Y coordinate 
        virtualWidth,    --the alignment of the text is in respect to the whole window width.
        'center'        --alignment
        )
    else
        love.graphics.clear(128/255, 0, 0, 1)
        love.graphics.printf("The  Game  is  ON!", 0 , 20, virtualWidth, 'center')
    end

    if gameState == 'done' then
        love.graphics.setColor(1, 215/255, 0, 1)
        love.graphics.clear(40/255, 45/255, 52/255, 1)
        love.graphics.setFont(love.graphics.newFont('font.ttf', 30))
        love.graphics.printf("Player  "..tostring(winningPlayer) .." Wins!", 0, 10, virtualWidth,"center")
    end
    if gameState == 'static' or gameState == 'play' then
    --scores of both players on the centers of the 2 sides
    love.graphics.setFont(love.graphics.newFont('font.ttf',30))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(player1Score), virtualWidth/4 - 15, 46)
    love.graphics.print(tostring(player2Score), virtualWidth - virtualWidth/4 - 15, 46)
    end

    love.graphics.setColor(1, 1, 1, 1)
    AI: render()
    player:render()
    ball:render()
    love.graphics.setFont(love.graphics.newFont('font.ttf', 6))
    love.graphics.setDefaultFilter('linear', 'linear')
    push: apply('end')
end
