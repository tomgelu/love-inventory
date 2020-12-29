local utils = {}

function utils.dump(pTable, offset)
    offset = offset or 1
    local i = 1
    for key, value in pairs(pTable) do
        if type(value) == "table" then
            print(string.rep("| ", offset - 1) .. "|-" .. tostring(key))
            utils.dump(value, offset + 1)
        else
            local str = string.rep("| ", offset - 1)
            if i == #pTable then
                str = str .. ">-"
            else
                str = str .. "|-"
            end
            str = str .. tostring(key) .. "=" .. tostring(value)
            print(str)
            i = i + 1
        end
    end
end

function utils.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepcopy(orig_key)] = utils.deepcopy(orig_value)
        end
        setmetatable(copy, utils.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return utils
