local empty

equals = function(x,y)
    if x == nil or y == nil then return false end
    if x == y then return true end
    local xType = type(x)
    local yType = type(y)
    if xType ~= yType then return false end
    if xType ~= 'table' then return false end

    local KeySet = {}

    for k1,v1 in pairs(x) do
        local v2 = y[k1]
        if v2 == nil or equals(v1,v2) == false then
            return false
        end
        KeySet[k1] = true
    end

    for k2, _ in pairs(y) do
        if not KeySet[k2] then return false end
    end
    return true
end

empty = function(dir)
    if dir == 'd' then
        if peripheral.call("down","getInventorySize") ~= nil then
            turtle.dropDown()
        end
    elseif dir == 'u' then
        if peripheral.call("up","getInventorySize") ~= nil then
            turtle.dropUp()
        end
    elseif dir == 'f' then
        if peripheral.call("front","getInventorySize") ~= nil then
            turtle.drop()
        end
    else
        print("No idea where to put this")
    end
end

dropInv = function(...)
    local dir = 'f'
    local min = 1
    if tonumber(arg[1]) == nil then
        min = 2
        dir = arg[1]
    end
    if peripheral.call("front","getInventorySize") ~= nil then
        for i=min,#arg do
            item = turtle.getInfo(i)
            if item ~= nil then
                turtle.select(tonumber(arg[i]))
                empty(dir)
            end
        end
    else
        print("Bad Parameters")
    end
end

turtle.empty = empty