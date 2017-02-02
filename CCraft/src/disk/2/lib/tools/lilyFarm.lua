local tArgs = {...}
local X = 0
local Z = 0
local cache = -1

local function getCache()
    if cache ~= -1 then
        return cache
    end
    for i=1,16 do
        item = turtle.getInfo(i)
        if item ~= nil then
            if item.name == "ThermalExpansion:Cache" then
                cache = i
                return cache
            end
        end
    end
end

local function getFreeSlot()
    for i=1,16 do
        item = turtle.getInfo(i)
        if item == nil then
            return i
        end
    end
end
function hasPearl()
    for i=1,16 do
        item = turtle.getInfo(i)
        if item ~= nil then
            if item.name == "minecraft:ender_pearl" then
                turtle.select(i)
                return true
            end
        end
    end
    return false
end


local function hasSeed()
    for i=1,16 do
        item = turtle.getInfo(i)
        if item ~= nil then
            if item.name == "ExtraUtilities:plant/ender_lilly" then
                turtle.select(i)
                return true
            end
        end
    end
    return false
end

local function work()
	if not turtle.move() then
        turtle.dig()
        turtle.move()
	end
    result, item = turtle.inspectDown()
    if result then
        if item.metadata == 7 then
            turtle.select(1)
            turtle.dig(-1,0)
            turtle.placeDown()
        end
    else
        if hasSeed() then
            turtle.placeDown()
        end
    end
end

local function emptyInventory()
    local lastSlot = turtle.getSlot()
    if hasPearl() or hasSeed() then
        turtle.wrap("back")
        repeat
            turtle.push(turtle.getSlot())
        until not hasPearl() and not hasSeed()
    end
    turtle.select(lastSlot)
end

local function hasfuel()
	if turtle.getFuelLevel() <= 64 then
        turtle.refuel(65)
        if turtle.getFuelLevel() > 64 then
		    return true
        else
            return false
        end
	else
		return true
	end
end

local function time(T)
    seconds = T % 60
    minutes = math.floor(T / 60) % 60
    if math.floor(math.log10(seconds)+1) <= 1 then
        seconds = "0" .. seconds
    end
    if math.floor(math.log10(minutes)+1) <= 1 then
        minutes = "0" .. minutes
    end
    return tostring(minutes .. ":" .. seconds)
end

local function run()
    turtle.select(1)
    turn = "right"
    turtle.move(1,1)
    while true do
        turtle.refuel(X*Z + 10)
        work()
        for i=1,(X) do
            for j=1,(Z-1) do
                work()
            end
            if i ~= X then
                if turn == "right" then
                    turtle.right()
                    work()
                    turtle.right()
                    turn = "left"
                else
                    turtle.left()
                    work()
                    turtle.left()
                    turn = "right"
                end
            end
        end
        if turn == "left" then
            turtle.right()
            turtle.move(-1)
            local temp = X
            X = Z
            Z = temp
            turn = "right"
        else
            turtle.move(1)
            turtle.left(2)
        end
        H,K = term.getCursorPos()
        turtle.select(getFreeSlot())
        turtle.dig(-1,3)
        turtle.placeUp()
        emptyInventory()
        for x=300,1,-1 do
            term.clearLine()
            cprint("Sleeping for &1" .. time(x).."&0")
            term.setCursorPos(1,K)
            os.sleep(1)
        end
        for d=1,3 do
            turtle.dig(1,1)
            turtle.placeDown()
        end
    end
end



function lilyFarm()
    if #tArgs < 2 then
        print("Enter the relative X size: ")
        X = tonumber(io.read())
        print("Enter the relative Z size: ")
        Z = tonumber(io.read())
    end
    if X >= 3 and Z >= 3 then
        run()
    else
        print("Farm Too Small")
    end
end

if #tArgs == 2 then
    X = tonumber(tArgs[1])
    Z = tonumber(tArgs[2])
    enderLilies()
end
