local getMarker,placeAny,placeMarker,dismantleQuarry,markQuarry,run

getMarker = function() 
    for i=1,16 do
        item = turtle.getInfo(i)
        if item ~= nil then
            if item.name == "ExtraUtilities:endMarker" then
                return i 
            end
        end
    end
    return -1
end

function placeAny()
    for i=1,16 do
        item = turtle.getInfo(i)
        if item ~= nil and item.name ~= "ExtraUtilities:endMarker" then
            turtle.select(i)
            if turtle.placeDown() then
                return true 
            end
        end
    end
    return false
end

placeMarker = function()
    turtle.dig(-1,1)
    turtle.dig(-1,0)
    placeAny()
    turtle.move(1,1)
    turtle.select(getMarker())
    turtle.placeDown()
end

run = function(N)
    if N ~= nil then
        turtle.dig(1)
        turtle.dig(1,1)
        for i=1,4 do
            turtle.dig(N-1)
            turtle.right()
            placeMarker()
        end
        turtle.move(-1)
        turtle.move(-1,1)
    end
end

dismantleQuarry = function(N)
    if N ~= nil then
        turtle.dig(1)
        for i=1,4 do
            turtle.dig(N-1)
            turtle.right()
            turtle.dig(-1,0)
        end
        turtle.move(-1)
    end
end

markQuarry = function(N)
    if(turtle.getFuelLevel() < (N * 4)+16) then
        print("Looking for Fuel...")
        refuel((N * 4)+16)
        if (turtle.getFuelLevel() < (N * 4)+16) then
            print("Not enough fuel.. Add more.")
            os.exit()
        end
    end
    if N >= tonumber(4) then
        print("Marking... ".. N .. " x " .. N)
        run(N)
    else 
        print("Quarry Too Small")
    end
end

turtle.dismantleQuarry = dismantleQuarry
turtle.markQuarry = markQuarry