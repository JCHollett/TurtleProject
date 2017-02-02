local N, count, dir,move,run,getEnderChest,emptyInventory,hasfuel,pillar
move = function()
	if (not bot.dig(1)) or turtle.detectUp() or turtle.detectDown() then
        if dir then
            while turtle.detectUp() do
                if not bot.dig(1,1) then
                    break
                end
                count = count + 1
            end
            dir = false
        else
            while turtle.detectUp() do
                if not bot.dig(1,1) then
                    break
                end
                count = count + 1
            end
            while count ~= 0 do
                bot.dig(-1,1)
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
            bot.right()
            move()
            bot.right()
            turn = false
        else
            bot.left()
            move()
            bot.left()
            turn = true
        end
        --[[emptyInventory()]]--
        s = 1
    end
    if count ~= 0 then
        while count ~= 0 do
            bot.dig(-1,1)
            count = count - 1
        end
    end
end

getEnderChest = function()
    for i=1,16 do
        item = bot.getInfo(i)
        if item ~= nil then
            if item.name == "EnderStorage:enderChest" then
                return i
            end
        end
    end
    return -1
end

emptyInventory = function()
    bot.select(getEnderChest())
    bot.placeUp()
    for i=2,16 do
        bot.select(i)
        bot.dropUp()
    end
    bot.select(16)
    bot.dig(1,0)
    bot.select(1)
end

hasfuel = function()
	if bot.getFuel() <= 64 then
        bot.refuel(65)
        if bot.getFuel() > 64 then
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
    bot.select(1)
    if #arg == 1 then
        N = tonumber(arg[1])
    else
        print("Enter the square size of the Pillar: ")
        local N = tonumber(io.read())
    end
    count = 0
    if getEnderChest() > 0 or true then
        if N > 0 then
            run(N)
        else
            printError("Pillar too small")
        end
    else
        printError("Missing Enderchest")
    end
end

bot.pillar = pillar