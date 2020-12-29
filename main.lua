local utils = require('utils')
local inventory = require('inventory')
local items = require('items')

inventory:init(50)

inventory:addItem(items.Apple, 65)

function love.update(dt)

end

function love.draw()
    inventory:draw()
end

function love.mousepressed(x, y, button)
    inventory:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    inventory:mousereleased(x, y, button)
end

function love.keypressed(key)
    print(key)
    if key == 'a' then
        inventory:addItem(items.Apple, 3)
    end
    if key == 'escape' then
        love.event.quit()
    end
end