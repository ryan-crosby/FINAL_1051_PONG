WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

paddleHeight = 20
Class = require 'class'
push= require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    
    math.randomseed(os.time())
    love.window.setTitle('Pong')
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('04B_03__.TTF', 12)
    
    scoreFont = love.graphics.newFont('04B_03__.TTF', 32)
    
    victoryFont = love.graphics.newFont('04B_03__.TTF', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
    }

    push:setupScreen (VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
      fullscreen = false,
      vsync = true,
      reziable = true
    })

    player1Score = 0
    player2Score = 0

    servingPlayer= 1

    paddle1 = Paddle(10, 30, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball= Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)
  

    gameState = 'start' 
    PADDLE_SPEED = 200

    
end

function love.resize(w, h)
    push:resize(w, h)
end

--moves paddles
function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then


        if ball:collides(paddle1) then
            --deflect ball to the right
            ball.dx = -ball.dx * 1.1
            ball.x = paddle1.x + 5
            if paddle1.height >= 10 then
                paddle1.height = paddle1.height - 5
            else
                paddle1.height = 5
            end
            if ball.dy< 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']: play()
        end

        if ball:collides(paddle2) then
            --delfect ball to the left
            ball.dx = -ball.dx * 1.1
            ball.x = paddle2.x - 3
            if paddle2.height >= 10 then
                paddle2.height = paddle2.height + 5
            else
                paddle2.height = 5
            end
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']: play()
            
        end

        if ball.y <= 0 then 
            --deflect ball down
            ball.y = 0
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy 
            sounds['wall_hit']:play()       
        end


        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['point_scored']:play()

            if player2Score == 10 then
                winningPlayer = 1
                gameState = 'victory'

            else 
                gameState = 'serve'
                ball:reset()
                paddle1:reset(paddleHeight)
                paddle2:reset(paddleHeight)
            end
        end
    
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['point_scored']:play()
            
            if player1Score == 10 then
                winningPlayer = 2
                gameState = 'victory'
            else 
                gameState = 'serve'
                ball:reset()
                paddle1:reset(paddleHeight)
                paddle2:reset(paddleHeight)
            end       
        end
    end
    if love.keyboard.isDown('w') then
       paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end
       
    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end


    if gameState == 'play' then
        ball:update(dt)       
    end
    paddle1:updateAI(ball)
    --paddle1:update(dt)
    paddle2:update(dt)
    --paddle2:updateAI(ball)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end        
        end
    end
end
function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45/ 255, 52/ 255, 245/ 255)
    love.graphics.setFont(smallFont)
    displayScore()
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Cultured Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play!', 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Have Fun Deciphering These Messages!', 0, 50, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player' .. tostring(servingPlayer) .. "'s turn!" , 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Serve!', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then

    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf('Player' .. tostring(winningPlayer) .. " wins!" , 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to Restart!', 0, 42, VIRTUAL_WIDTH, 'center')
    end

    -- first paddle render
    paddle1:render()
    --second paddle render
    paddle2:render()

    -- ball render
    ball.render()
    --ball.color()
    -- First paddle (left side)
        
    -- second paddle (right side)
    
    displayFPS()

    push:apply('end')


end

function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
    
    -- Print out my Messages at a specific score
    if player1Score == 1 and player2Score == 0 then
        love.graphics.setFont(smallFont)
        love.graphics.print(" 9, 8, 7, 6, 5, 4, 3, 2, 1 ", VIRTUAL_WIDTH / 2 + 50,
        VIRTUAL_HEIGHT / 3 + 7)
        love.graphics.print(" HAPPY NEW YEAR! ", VIRTUAL_WIDTH / 2 + 80,
        VIRTUAL_HEIGHT / 3 + 20)
    
    elseif player1Score == 0 and player2Score == 1 then
        love.graphics.print("N", VIRTUAL_WIDTH / 2 - 75,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(smallFont)
        love.graphics.print(" Asked for this ", VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3 + 10)
        -- No 1 asked for this

    elseif player1Score == 1 and player2Score == 1 then
        love.graphics.setFont(scoreFont)
        love.graphics.print(" :11 ", VIRTUAL_WIDTH / 2 + 40,
        VIRTUAL_HEIGHT / 3 + 1)
        love.graphics.setFont(smallFont)
        love.graphics.print(" Make a Wish ", VIRTUAL_WIDTH / 2 + 100,
        VIRTUAL_HEIGHT / 3 + 10)
    elseif player1Score == 2 and player2Score == 0 then
        love.graphics.setFont(scoreFont)
        love.graphics.print('20 Sucks', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)
    elseif player1Score == 2 and player2Score == 1 then
        love.graphics.setFont(smallFont)
        love.graphics.print("What's 9 + 10?", VIRTUAL_WIDTH / 2 - 165,
        VIRTUAL_HEIGHT / 3 + 10)

    elseif player1Score == 1 and player2Score == 3 then
        love.graphics.print("ABC", VIRTUAL_WIDTH / 2 - 130,
        VIRTUAL_HEIGHT / 3)
        love.graphics.printf('2', 0, 82, VIRTUAL_WIDTH, 'center')

    elseif player1Score == 2 and player2Score == 3 then
        love.graphics.setFont(scoreFont)
        love.graphics.printf('Jordan', 0, 55, VIRTUAL_WIDTH, 'center')
        -- Michael Jordan
    elseif player1Score == 4 and player2Score == 0 then
        love.graphics.print("Error", VIRTUAL_WIDTH / 2 - 140,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(scoreFont)
        love.graphics.print('4 ', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(smallFont)
        love.graphics.print('Not Found', VIRTUAL_WIDTH / 2 + 80,
        VIRTUAL_HEIGHT / 3 + 15)

       -- 404 not found

    elseif player1Score == 2 and player2Score == 4 then
        love.graphics.setFont(scoreFont)
        love.graphics.print("/7 ", VIRTUAL_WIDTH / 2 + 45,
        VIRTUAL_HEIGHT / 3 + 1)
        -- 24 / 7 
    elseif player1Score == 4 and player2Score == 2 then
        love.graphics.print('0 BlazeIt', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)
       -- 420
    elseif player1Score == 3 and player2Score == 4 then
        love.graphics.printf('.1', 0, 82, VIRTUAL_WIDTH, 'center')
       -- pi  3.14


    elseif player1Score == 2 and player2Score == 5 then 
        love.graphics.print("Dec", VIRTUAL_WIDTH / 2 - 130,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(smallFont)
        love.graphics.print('Merry Christmas', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)
  
      --  Dec     merry christmas 

    elseif player1Score == 1 and player2Score == 5 then
        love.graphics.setFont(scoreFont)
        love.graphics.print("2", VIRTUAL_WIDTH / 2 - 105,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(smallFont)
        love.graphics.print('Is the Best Area Code', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)
    elseif player1Score == 3 and player2Score == 6 then
        love.graphics.print("Austin", VIRTUAL_WIDTH / 2 - 170,
        VIRTUAL_HEIGHT / 3)
        love.graphics.printf(':1', 0, 82, VIRTUAL_WIDTH, 'center')
        --  austin 3: 16    put :1 in the middle


    elseif player1Score == 7 and player2Score == 6 then
        love.graphics.setFont(smallFont)
        love.graphics.print("Philadelphia", VIRTUAL_WIDTH / 2 - 165,
        VIRTUAL_HEIGHT / 3 + 10)
        love.graphics.setFont(scoreFont)
        love.graphics.print('ers', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)

       -- philadelphia 76ers

    elseif player1Score == 7 and player2Score == 0 then
        love.graphics.print('7 LOL', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)

       -- 707 LOL (707 is lol upside down)

    elseif player1Score == 0 and player2Score == 7 then
        love.graphics.print("7", VIRTUAL_WIDTH / 2 - 95,
        VIRTUAL_HEIGHT / 3)
        love.graphics.print('LOL', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)

        -- 707 LOL 

    elseif player1Score == 4 and player2Score == 5 then
        love.graphics.setFont(smallFont)
        love.graphics.print("41  42  43  44  ", VIRTUAL_WIDTH / 2 - 155,
        VIRTUAL_HEIGHT / 3 + 10)
        love.graphics.print('46  47  48 ', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3 + 10)
        love.graphics.setFont(scoreFont)
        love.graphics.print('49', VIRTUAL_WIDTH / 2 + 150,
        VIRTUAL_HEIGHT / 3)

      --  41 42 43 44 45
      -- its a meme song


    elseif player1Score == 7 and player2Score == 7 then
        love.graphics.print("7", VIRTUAL_WIDTH / 2 - 95,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(smallFont)
        love.graphics.print('This number is ', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3 + 10)
        love.graphics.print('apparently Holy', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3 + 20)

       -- 777 this number is apparently Holy

    elseif player1Score == 6 and player2Score == 6 then
        love.graphics.printf('6', 0, 82, VIRTUAL_WIDTH, 'center')
        
        -- 666

    elseif player1Score == 6 and player2Score == 7 then
        love.graphics.setFont(smallFont)
        love.graphics.print("ft", VIRTUAL_WIDTH / 2 - 40,
        VIRTUAL_HEIGHT / 3)
        love.graphics.print('ft', VIRTUAL_WIDTH / 2 + 50,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(scoreFont)
        love.graphics.print('8', VIRTUAL_WIDTH / 2 + 90,
        VIRTUAL_HEIGHT / 3)
        love.graphics.setFont(smallFont)
        love.graphics.print('ft', VIRTUAL_WIDTH / 2 + 110,
        VIRTUAL_HEIGHT / 3)

        -- 6 ft 7 ft 8 ft
    
    elseif player1Score == 6 and player2Score == 9 then
        love.graphics.print('Nice', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)

        --69 nice

    elseif player1Score == 9 and player2Score == 6 then
        love.graphics.print("eciN", VIRTUAL_WIDTH / 2 - 125,
        VIRTUAL_HEIGHT / 3)


    
    elseif player1Score == 7 and player2Score == 4 then
        love.graphics.print("81 Mil to", VIRTUAL_WIDTH / 2 - 200,
        VIRTUAL_HEIGHT / 3)
        love.graphics.print('Mil', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)

        --81 mil to 74 mil


    elseif player1Score == 4 and player2Score == 9 then
        love.graphics.print("San Fran", VIRTUAL_WIDTH / 2 - 200,
        VIRTUAL_HEIGHT / 3)
        love.graphics.print('ers', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3)         
        
        --San fran 49 ers


    elseif player1Score == 8 and player2Score == 2 then
        love.graphics.print("I'd", VIRTUAL_WIDTH / 2 - 105,
        VIRTUAL_HEIGHT / 3)
        love.graphics.print('be you', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3) 

        --Id 8 2 be you


    elseif player1Score == 7 and player2Score == 9 then
        love.graphics.print("Cause", VIRTUAL_WIDTH / 2 - 165,
        VIRTUAL_HEIGHT / 3)
        love.graphics.printf('8', 0, 82, VIRTUAL_WIDTH, 'center')

        --cause 7 8 9

    elseif player1Score == 8 and player2Score == 8 then
        love.graphics.print("Some 1 - ", VIRTUAL_WIDTH / 2 - 205,
        VIRTUAL_HEIGHT / 3)
        love.graphics.printf('8', 0, 82, VIRTUAL_WIDTH, 'center')
        love.graphics.print('Number', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3) 

        --some 1-888 number
    
    elseif player1Score == 8 and player2Score == 9 then
        love.graphics.print("7", VIRTUAL_WIDTH / 2 - 100,
        VIRTUAL_HEIGHT / 3)
        love.graphics.print('Again', VIRTUAL_WIDTH / 2 + 60,
        VIRTUAL_HEIGHT / 3) 

        --7  8 9 again


    elseif player1Score == 9 and player2Score == 5 then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Dolly Parton', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Working', 0, 70, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('to', 0, 95, VIRTUAL_WIDTH, 'center')

        -- Dolly parton's song 9 to 5

    elseif player1Score == 9 and player2Score == 9 then
        love.graphics.print("Nein", VIRTUAL_WIDTH / 2 - 140,
        VIRTUAL_HEIGHT / 3)

        --nien 9 9
    end
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end
