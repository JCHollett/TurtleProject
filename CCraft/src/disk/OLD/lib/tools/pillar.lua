local N, count, dir,move,run,getEnderChest,emptyInventory,hasfuel,pillar
move = function()
	if (not turtle.dig(1)) or turtle.detectUp() or turtle.detectDown() then
        if dir then
            while turtle.detectUp() do
                if not turtle.dig(1,1) then
                    break
                end
                count = count + 1                
            end
            dir = false
        else
            while turtle.detectUp() do
                if not turtle.dig(1,1) then
                    break
                end
                count = count + 1
            end
            while count ~= 0 do
                turtle.dig(-1,1)
                count = count - 1
            end
            dir = true    
        end
	end
end

run = function(size)
    turn = true
    local s = 0
	for i=1,(size) do 
        for j=1,(size-s) do
            if hasfuel() then
                move()
            else
                print("Insufficient Fuel ... Shutting down in 5 seconds")
                os.sleep(5)
                os.shutdown()
            end
        end
        if turn then
            turtle.right()
            move()
            turtle.right()
            turn = false
        else
            turtle.left()
            move()
            turtle.left()
            turn = true
        end
        emptyInventory()
        s = 1
    end
    if count ~= 0 then 
        while count ~= 0 do
            turtle.dig(-1,1)
            count = count - 1
        end
    end
end

getEnderChest = function() 
    for i=1,16 do
        item = turtle.getInfo(i)
        if item ~= nil then
            if item.name == "EnderStorage:enderChest" then 
                return i
            end
        end
    end
    return -1
end

emptyInventory = function() 
    turtle.select(getEnderChest())
    turtle.placeUp()
    for i=2,16 do
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(16)
    turtle.dig(1,0)
    turtle.select(1)
end

hasfuel = function() 
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

pillar = function(...)
    dir = true
    turtle.select(1)
    if #arg == 1 then
        N = tonumber(arg[1])
    else
        print("Enter the square size of the Pillar: ")
        local N = tonumber(io.read())
    end
    count = 0
    if getEnderChest() > 0 then
        if N > 0 then
            run(N)
        else 
            printError("Pillar too small")
        end
    else
        printError("Missing Enderchest")
    end
end

turtle.pillar = pillar