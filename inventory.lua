local items = require('items')
local utils = require('utils')

local inventory = {
    grid = {},
    cellSize = 50,
    selectedCell = nil
}

inventory.init = function(self, cellSize)
    self.cellSize = cellSize or self.cellSize
    for y = 1, 10 do
        inventory.grid[y] = {}
        for x = 1, 10 do
            inventory.grid[y][x] = {
                item = nil,
                quantity = 0,
            }
        end
    end    
end

inventory.draw = function(self)
    love.graphics.setColor(1, 1, 1)
    for y = 1, #self.grid do
        for x = 1, #self.grid[y] do
            -- Grid
            love.graphics.rectangle('line', (x - 1) * self.cellSize, (y - 1) * self.cellSize, self.cellSize, self.cellSize)

            -- Items
            local cell = self.grid[y][x]
            if cell.item then
                local textOffset = 5
                love.graphics.print(cell.item.name, (x - 1) * self.cellSize + textOffset, (y - 1) * self.cellSize + textOffset)
                love.graphics.print(cell.quantity, (x - 1) * self.cellSize + textOffset, (y - 1) * self.cellSize + textOffset + 17)
            end
        end
    end
    if self.selectedCell then
        local mx, my = love.mouse.getPosition()
        love.graphics.rectangle('line', mx, my, self.cellSize, self.cellSize)
        local textOffset = 5
        love.graphics.print(self.selectedCell.cell.item.name, mx + textOffset, my + textOffset)
        love.graphics.print(self.selectedCell.cell.quantity, mx + textOffset, my + textOffset + 17)
        --[[
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle('line',  (self.selectedCell.x - 1) * self.cellSize, (self.selectedCell.y - 1) * self.cellSize, self.cellSize, self.cellSize)
        ]]
    end
end

inventory.lookupForAvailableStack = function(self, item)
    for y = 1, #self.grid do
        for x = 1, #self.grid[y] do
            local cell = self.grid[y][x]
            if cell.item and cell.item.name == item.name then
                local maxQuantity = items[item.name].max
                if cell.quantity < maxQuantity then
                    local leftQuantity = maxQuantity - cell.quantity
                    return true, x, y, leftQuantity
                end
            end
        end
    end
    return false
end

inventory.findNextEmptyCell = function(self)
    for y = 1, #self.grid do
        for x = 1, #self.grid[y] do
            local cell = self.grid[y][x]
            if cell.item == nil then
                return x, y
            end
        end
    end
end

inventory.addItemAtPosition = function(self, item, quantity, x, y)
    local desiredCell = self.grid[y][x]
    if desiredCell.item == nil then
        desiredCell.item = item
        desiredCell.quantity = quantity
    else
        if desiredCell.item.name == item.name then
            local leftQuantity = item.max - desiredCell.quantity
            if quantity <= leftQuantity then
                desiredCell.quantity = desiredCell.quantity + quantity
            else
                desiredCell.quantity = desiredCell.quantity + leftQuantity
                local newStackQuantity = quantity - leftQuantity
                self:addItem(item, newStackQuantity)
            end

        end
    end
end

inventory.addItem = function(self, item, quantity)
    local stackExists, x, y, leftQuantity = self:lookupForAvailableStack(item)
    if stackExists then
        local cell = self.grid[y][x]
        if quantity <= leftQuantity then
            cell.quantity = cell.quantity + quantity
        else
            cell.quantity = cell.quantity + leftQuantity
            local newStackQuantity = quantity - leftQuantity
            self:addItem(item, newStackQuantity)
        end
    else
        local x, y = self:findNextEmptyCell()
        self.grid[y][x].item = item
        if quantity > item.max then
            self.grid[y][x].quantity = item.max
            self:addItem(item, quantity - item.max)
        else
            self.grid[y][x].quantity = quantity
        end
    end
end

inventory.mousepressed = function(self, x, y, button)
    local gx = math.floor(x / self.cellSize) + 1
    local gy = math.floor(y / self.cellSize) + 1
    if gy > #self.grid or gx > #self.grid[1] then
        self.selectedCell = nil
        return
    end
    if self.selectedCell then
        print('Selected cell should not be existing')
    end
    self.selectedCell = {
        cell = utils.deepcopy(self.grid[gy][gx]),
        x = gx,
        y = gy,
    }
    self.grid[gy][gx] = {
        item = nil,
        quantity = 0
    }
end

inventory.mousereleased = function(self, x, y, button)
    if not self.selectedCell then
        print('Selected cell should be existing')
    end
    local gx = math.floor(x / self.cellSize) + 1
    local gy = math.floor(y / self.cellSize) + 1
    if gy > #self.grid or gx > #self.grid[1] then
        self.selectedCell = nil
        return
    end
    self:addItemAtPosition(self.selectedCell.cell.item, self.selectedCell.cell.quantity, gx, gy)
    self.selectedCell = nil
end

return inventory