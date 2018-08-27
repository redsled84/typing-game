function newActive(word, x, y)
    return {word=word, x=x, y=y}
end

function love.load()
    local nMinutes = 3
    endGameTimer = nMinutes * 60
    endTimer = endGameTimer
    love.window.setTitle(tostring(nMinutes).." Minutes or Less to Type 30 Words")

    love.graphics.setNewFont(32)
    -- array of typeable words
    words = {}
    -- file data
    fileName = "words.txt"
    fileMode = "r"
    local file = io.open(fileName, fileMode)
    -- import words into array
    for line in file:lines() do
        words[#words+1] = line
    end
    -- create list of select words we want to tract
    activeWords = {}
    math.randomseed(os.time())
    maxActiveWords = 13
    for i = 1, maxActiveWords do
        local n = math.random(1, #words)
        local x = math.random(-2*love.graphics.getWidth(), 0)
        local y = math.random(i * 25, love.graphics.getHeight()-25)
        activeWords[#activeWords + 1] = newActive(words[n], x, y)
    end
    -- winner, winner, chicken dinner
    maxGameScore = 30
    minGameScore = -10
    gameScore = 0
    userInput = "" 
    flag = "idle"
    maxFlagTimer = .6
    flagTimer = maxFlagTimer
    
    love.window.setMode(1280, 720)

    maxDeleteTimer = .5
    deleteTimer = maxDeleteTimer

end

function compareUserInput()
    flag = "wrong"
    for i = #activeWords, 1, -1 do
        local a = activeWords[i]
        if a.word == userInput then
            table.remove(activeWords, i)
            local n = math.random(1, #words)
            local x = math.random(-2*love.graphics.getWidth(), 0)
            local y = math.random(i * 25, love.graphics.getHeight()-25)
            activeWords[#activeWords + 1] = newActive(words[n], x, y)
            gameScore = gameScore + 1
            flag = "right"
            break
        end
    end
    userInput = ""
end

function love.update(dt)
    if endTimer > 0 then
        endTimer = endTimer - dt
    else
        gameScore = minGameScore
    end
    if gameScore >= maxGameScore or gameScore <= minGameScore then
        return
    end

    if flag ~= "idle" then
        flagTimer = flagTimer - dt
        if flagTimer <= 0 then
            flagTimer = maxFlagTimer
            flag = "idle"
        end
    end
    for i = #activeWords, 1, -1 do
        local a = activeWords[i]
        -- update the position of active words
        local wordSpeed = math.random(80, 130)
        a.x = a.x + wordSpeed * dt
        if a.x > love.graphics.getWidth() then
            table.remove(activeWords, i)
            local n = math.random(1, #words)
            local x = math.random(-2*love.graphics.getWidth(), 0)
            local y = math.random(i * 25, love.graphics.getHeight()-25)
            activeWords[#activeWords + 1] = newActive(words[n], x, y)
            gameScore = gameScore - 1
        end
    end

    if love.keyboard.isDown("backspace") then
        deleteTimer = deleteTimer - dt
        if deleteTimer <= 0 then
            userInput = userInput:sub(1, #userInput-1)
        end
    else
        deleteTimer = maxDeleteTimer
    end
end

function love.draw()
    if gameScore >= maxGameScore or gameScore <= minGameScore then
        local endStr = ""
        if gameScore >= maxGameScore then
            endStr = "YOU WON"
        else
            endStr = "YOU LOSE"
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, 0,
            love.graphics.getWidth(),
            love.graphics.getHeight())
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(endStr, love.graphics.getWidth()/2-60,
            love.graphics.getHeight()/2-15)
        return
    end

    if flag == "wrong" then
        love.graphics.setColor(.8, .1, .15)
    elseif flag == "right" then
        love.graphics.setColor(.15, .8, .1)
    end
    if flag ~= "idle" then
        love.graphics.rectangle("fill", 0, 0,
            love.graphics.getWidth(),
            love.graphics.getHeight())
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(math.floor(endTimer)), love.graphics.getWidth()/2, 15)
    love.graphics.print("Score: "..tostring(gameScore), 10, 10)
    love.graphics.print("Input: "..userInput, 10, 40)
    for i = 1, #activeWords do
        local a = activeWords[i]
        love.graphics.print(a.word, a.x, a.y)
    end
end
    
local upper = false
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
        return
    end
    if key == "return" then
        compareUserInput()
        return
    end
    if not key:match("%W") then
        if key == "backspace" then
            userInput = userInput:sub(1, #userInput-1)
        elseif key == "space" then
        elseif key == "lshift" or key == "rshift" then
            upper = true
        else
            if upper then
                userInput = userInput .. string.upper(key)
            else
                userInput = userInput .. key
            end
        end
    end
end

function love.keyreleased(key)
    if key == "lshift" or key == "rshift" then
        upper = false
    end
end
