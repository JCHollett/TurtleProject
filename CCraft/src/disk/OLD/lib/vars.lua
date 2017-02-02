shell.run("/data/wrapping.lua")
shell.run("/data/dropping.lua")
shell.run("/data/scanning.lua")
shell.run("/data/sorting.lua")
shell.run("/data/reactors.lua")

local map = {
    detectDown    = turtle.detectDown,
    detectUp      = turtle.detectUp,
	detect        = turtle.detect,
	digDown       = turtle.digDown,
	digUp         = turtle.digUp,
	dig           = turtle.dig,
	placeDown     = turtle.placeDown,
	placeUp       = turtle.placeUp,
	place         = turtle.place,
	drop          = turtle.drop,
	dropUp        = turtle.dropUp,
	dropDown      = turtle.dropDown,
	down          = turtle.down,
	forward       = turtle.forward,
	up            = turtle.up,
	back          = turtle.back,
	turnLeft      = turtle.turnLeft,
	turnRight     = turtle.turnRight,
    getCount      = turtle.getCount,
    getItemSpace  = turtle.getItemSpace,
    getItemDetail = turtle.getItemDetail,
    select        = turtle.select,
    refuel        = turtle.refuel,
    getFuel       = turtle.getFuelLevel
}

local fuelSlot = -1
local fuelWeight = -1

local fuel = {
    ["coal_block"] = 720,
    ["coal"] = 80,
    ["planks"] = 15
}
Relative = {
    ["NORTH"] = function(v) return vector.new(v.x, v.y, -v.z) end,
    ["EAST"] = function(v) return vector.new(v.z, v.y, v.x) end,
    ["SOUTH"] = function(v) return vector.new(-v.x, v.y, v.z) end,
    ["WEST"] = function(v) return vector.new(-v.z, v.y, -v.x) end
}
cardinality = {
    [0] = "SOUTH",
    [1] = "WEST",
    [2] = "NORTH",
    [3] = "EAST"
}
local Direction = {
    ["SOUTH"] = 0,
    ["WEST"] = 1,
    ["NORTH"] = 2,
    ["EAST"] = 3
}
local turning = {
    [-1] = function() map.turnLeft() this._CARDINAL = (this._CARDINAL - 1) % 4 end,
    [0] = function() map.turnLeft() map.turnLeft() this._CARDINAL = (this._CARDINAL - 2) % 4 end,
    [1] = function() map.turnRight() this._CARDINAL = (this._CARDINAL + 1) % 4 end
}
local detecting = {
    [-1] = map.detectDown,
    [0] = map.detect,
    [1] = map.detectUp
}
local digging = {
    [-1] = function() if map.detectDown() then return map.digDown() else return false end end,
    [0] = function() if map.detect() then return map.dig() else return false end end,
    [1] = function() if map.detectUp() then return map.digUp() else return false end end
}
local placing = {
    [-1] = map.placeDown,
    [0] = map.place,
    [1] = map.placeUp
}
local dropping = {
    ['down'] = map.dropDown,
    ['front'] = map.drop,
    ['up'] = map.dropUp
}
local MoveResult = nil
local moving = {
    [-1] = function()
        this.scan.Data = nil
        return map.down()
    end,
    [0] = function()
        this.scan.Data = nil
        return map.forward()
    end,
    [1] = function()
        this.scan.Data = nil
        return map.up()
    end,
    ["back"] = function()
        this.scan.Data = nil
        return map.back()
    end
}
local Bot = {}
Bot.__index = Bot

function Bot.new()
    local self = setmetatable({
        _CARDINAL,
        left,
        right,
        move,
        dig,
        refuel,
        selectItem,
        getCount,
        getCapacity,
        getInfo,
        getSlot,
        getInfoPair,
        platformCircle,
        platformRCircle,
        digCircle,
        digRCircle,
        digShaft,
        tunnel,
        pull,
        push,
        find,
        get,
        getAE,
        wrap,
        drop,
        scan
    }, Bot)
    return self
end


this = Bot.new()
Wrap.new(this)

this.drop = Drop.new(dropping)
this.getAE = function(name)
    if not name then
        return 0
    else
        name = string.lower(name)
    end
    if this.wrap() and name then
        local Items = this.wrap().getAvailableItems()
        for i = 1, #Items do
            local FP = Items[i].fingerprint
            if string.find(string.lower(FP.id), name) then
                return this.wrap().exportItem(FP, _Out(this.wrap()))
            end
        end
        return 0
    else
        return 0
    end
end


this.get = function(name)
    if not name then
        return 0
    else
        name = string.lower(name)
    end
    if this.wrap() and name then
        for i = 1, this.wrap().getInventorySize() do
            local ItemStack = this.wrap().getStackInSlot(i)
            if ItemStack then
                if string.find(string.lower(ItemStack.display_name), name) then
                    return this.pull(i)
                end
            end
        end
        return 0
    else
        return 0
    end
end
this.select = map.select
this.placeAny = function(direction)
    if not direction or detecting[direction]() then
        return false
    end
    for i=1,16 do
        item = this.getInfo(i)
        if item then
            this.select(i)
            if placing[direction]() then
                return true
            end
        end
    end
    return false
end

this.pull = function(from, to)
    if this.wrap() and tonumber(from) then
        if tonumber(to) then
            return this.wrap().pushItem(_Out(this.wrap.last), from, 64, to)
        else
            return this.wrap().pushItem(_Out(this.wrap.last), from)
        end
    else
        printError("Turtle: Inventory Error")
    end
end

this.push = function(from, to)
    if this.wrap() and tonumber(from) then
        if tonumber(from) then
            return this.wrap().pullItem(_Out(this.wrap.last), from, 64, to)
        else
            return this.wrap().pullItem(_Out(this.wrap.last), from)
        end
    else
        printError("Turtle: Inventory Error")
    end
end

this.find = function(name)
    local name = string.lower(name)
    if this.wrap() and name then
        for i = 1, this.wrap().getInventorySize() do
            local ItemStack = this.wrap().getStackInSlot(i)
            if ItemStack then
                if string.find(string.lower(ItemStack.display_name), name) then
                    print(i .. ':' .. ItemStack.display_name)
                end
            end
        end
    else
        printError("Turtle: Inventory Error")
    end
end

cprint = function(...)
    local s = "&0"
    for k, v in ipairs(arg) do
        s = s .. v
    end
    s = s .. "&0"

    local fields = {}
    local lastcolor, lastpos = "0", 0
    for pos, clr in s:gmatch "()&(%x)" do
        table.insert(fields, {s:sub(lastpos + 2, pos - 1), lastcolor})
        lastcolor, lastpos = clr, pos
    end

    for i = 2, #fields do
        if term.isColor() then
            term.setTextColor(2 ^ (tonumber(fields[i][2], 16)))
        end
        io.write(fields[i][1])
    end
end

clear = function()
    term.clear()
    term.setCursorPos(1, 1)
end

reinit = function()
    clear()
    os.reboot()
end

init = function()
    clear()
    shell.run("vars")
end


this.move = function(y, x)
    local c = nil
    if not y then
        x = 1
        y = 0
    elseif not x then
        x = y
        y = 0
    end
    if x > 0 then
        for i = 1, x do if not moving[y]() then return false end end
        return true
    elseif x < 0 then
        for i = -1, x, -1 do if not moving.back() then return false end end
        return true
    else
        return true
    end
end



this.left = function(x)
    if not x then
        turning[-1]()
    elseif x == 0 then
        return
    elseif math.abs(x) > 2 then
        if x > 0 then
            this.left( x % -4 )
        else
            this.right( x % 4 )
        end
    elseif x % 2 == 0 then
        turning[0]()
    else
        turning[-x]()
    end
end

this.right = function(x)
    if not x then
        turning[1]()
    elseif x == 0 then
        return
    elseif math.abs(x) > 2 then
        if x > 0 then
            this.right( x % -4 )
        else
            this.left( x % 4 )
        end
    elseif x % 2 == 0 then
        turning[0]()
    else
        turning[x]()
    end
end

this.dig = function(v, u)
    local c = nil
    local work = false
    if not v then
        return digging[0]()
    else
        if not u then
            if v < 0 then
                v = v * -1
                turning[0]()
            end
            for i = 1, v do
                while digging[0]() do
                    work = true
                end
                work = moving[0]() and work
            end
        else
            if u == 0 then
                return digging[v]()
            elseif u < 0 then
                u = u * -1
                t[0]()
            end
            for i = 1, u do
                while digging[v]() do
                    work = true
                end
                work = moving[v]() and work
            end
        end
    end
    return work
end

this.getSlot = map.getSelectedSlot
this.getCount = function(x)
    if not tonumber(x) then
        return map.getCount()
    else
        return map.getCount(tonumber(x))
    end
end

this.getCapacity = function(x)
    if not tonumber(x) then
        return map.getItemSpace()
    else
        return map.getItemSpace(tonumber(x))
    end
end

this.getInfo = function(x)
    if not tonumber(x) then
        return map.getItemDetail()
    else
        return map.getItemDetail(tonumber(x))
    end
end


this.getEmpty = function()
    for i = 1, 16 do
        item = this.getInfo(i)
        if not item then
            map.select(i)
            return true
        end
    end
    return false
end

this.platformCircle = function(N, Item)
    if N == 0 then
        return false
    end
    if N % 2 == 0 then
        N = N + 1
    end
    if this.selectItem(Item) then map.placeDown() else return false end
    for i = 1, N - 1 do
        this.move(1)
        if this.selectItem(Item) then map.placeDown() else return false end
    end
    while N > 1 do
        this.right()
        for j = N - 1, 1, -1 do
            this.move(1)
            if this.selectItem(Item) then map.placeDown() else return false end
        end
        this.right()
        for j = N - 1, 1, -1 do
            this.move(1)
            if this.selectItem(Item) then map.placeDown() else return false end
        end
        N = N - 1
    end
    return true
end

this.platformRCircle = function(N, Item)
    if N == 0 then
        return false
    end
    if N % 2 == 0 then
        N = N + 1
    end
    if this.selectItem(Item) then map.placeDown() else return false end
    for i = 1, N - 1 do
        for j = 1, i do
            this.move(1)
            if this.selectItem(Item) then map.placeDown() else return false end
        end
        this.right()
        for j = 1, i do
            this.move(1)
            if this.selectItem(Item) then map.placeDown() else return false end
        end
        this.right()
    end

    for i = 1, N - 1 do
        this.move(1)
        if this.selectItem(Item) then map.placeDown() else return false end
    end
    this.right()
    return true
end

this.digCircle = function(N)
    if N % 2 == 0 then
        N = N + 1
    end
    for i = 1, N - 1 do
        this.dig(-1, 0)
        this.dig(1, 0)
        this.dig(1)
    end
    while N > 1 do
        this.right()
        for j = N - 1, 1, -1 do
            this.dig(-1, 0)
            this.dig(1, 0)
            this.dig(1)
        end
        this.right()
        for j = N - 1, 1, -1 do
            this.dig(-1, 0)
            this.dig(1, 0)
            this.dig(1)
        end
        N = N - 1
    end
    this.dig(-1, 0)
    this.dig(1, 0)
end


this.digRCircle = function(N)
    if N % 2 == 0 then
        N = N + 1
    end
    this.dig(1, 0)
    this.dig(-1, 0)
    for i = 1, N - 1 do
        for j = 1, i do
            this.dig(-1, 0)
            this.dig(1, 0)
            this.dig(1)
        end
        this.right()
        for j = 1, i do
            this.dig(-1, 0)
            this.dig(1, 0)
            this.dig(1)
        end
        this.right()
    end

    for i = 1, N - 1 do
        this.dig(-1, 0)
        this.dig(1, 0)
        this.dig(1)
    end
    this.dig(-1, 0)
    this.dig(1, 0)
    this.right()
end

this.digShaft = function(W, D)
    if not (W and D) then
        return false
    end
    if W % 2 == 0 then
        W = W + 1
    end
    local C = 0
    local R = true
    local d = 2
    if not this.refuel(W ^ 2 * (D/3)) then
        return false
    end
    while D > 0 do
        if D >= 3 then
            this.dig(-1, d)
            D = D - 3
            C = C + d
            d = 3
        elseif D == 2 then
            this.dig(-1, (d - 1))
            D = D - 2
            C = C + (d - 1)
        else
            this.move(-1, (d - 2))
            D = D - 1
            C = C + (d - 2)
        end
        if R then
            this.digRCircle(W)
            R = false
        else
            this.digCircle(W)
            R = true
        end
    end
    if R then
        this.move(1, C)
    else
        this.move(math.floor(W / 2))
        this.right()
        this.move(math.floor(W / 2))
        this.move(1, C)
    end
    return true
end

this.adjust = function(heading, height)
    if heading then
        local res = (this._CARDINAL - Direction[heading])
        if res < 0 then
            this.right(math.abs(res))
        else
            this.left(res)
        end
    end
    if height then
        this.move(math.abs(height)/height, math.abs(height))
    end
end

this.tunnel = function(length)
    this.scan:filter(Filter.SOLID)
    local Heading = this._CARDINAL
    local u
    local v
    local y
    local scans = {}
    local Check = {
        ['LEFT'] = function()
            scans = {}
            digging[1]()
            this.dig(-1,0)
            if detecting[1]() then
                while digging[1]() do
                    os.sleep(0.75)
                end
            end
            y = 0
            u = vector.new(0,-2,0)
            v = vector.new(-1,-1,0)
            scans[1] = this.scan[u]
            scans[2] = this.scan[v]
            v.y = v.y + 1
            scans[3] = this.scan[v]
            v.y = v.y + 1
            scans[4] = this.scan[v]
            u.y = -u.y
            scans[5] = this.scan[u]
            if #scans == 0 then
                return
            end
            if not scans[1] then
                this.dig(-1,1)
                this.placeAny(-1)
                os.sleep(0.25)
                y = -1
            end
            if not scans[2] then
                if y == 0 then
                    this.dig(-1,1)
                    y = -1
                end
                this.left()
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[3] then
                if y < 0 then
                    y = 0
                    this.dig(1,1)
                end
                if scans[2] then
                    this.left()
                end
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[4] then
                if y < 1 then
                    this.dig(1,math.abs(y)+1)
                    y = 1
                end
                if scans[2] and scans[3] then
                    this.left()
                end
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[5] then
                if y < 1 then
                    this.dig(1,math.abs(y)+1)
                    y = 1
                end
                this.placeAny(1)
                os.sleep(0.25)
            end
        end,
        ['CENTER'] = function()
            scans = {}
            this.dig(-1,0)
            digging[1]()
            this.dig(-1,0)
            if detecting[1]() then
                while digging[1]() do
                    os.sleep(0.75)
                end
            end
            y = 0
            u = vector.new(0,-2,0)
            scans[1] = this.scan[u]
            u.y = -u.y
            scans[2] = this.scan[u]
            if #scans == 0 then
                return
            end
            if not scans[1] then
                this.dig(-1,1)
                this.placeAny(-1)
                os.sleep(0.25)
                y = -1
            end
            if not scans[2] then
                this.dig(1,math.abs(y)+1)
                y = 1
                this.placeAny(1)
                os.sleep(0.25)
            end
            this.adjust(nil, -y)
        end,
        ['FRONT'] = function()
            scans = {}
            y = 0
            u = vector.new(0,-2,0)
            v = vector.new(0,-1,1)
            scans[1] = this.scan[u]
            scans[2] = this.scan[v]
            v.y = v.y + 1
            scans[3] = this.scan[v]
            v.y = v.y + 1
            scans[4] = this.scan[v]
            u.y = -u.y
            scans[5] = this.scan[u]
            if #scans == 0 then
                return
            end
            if not scans[1] then
                this.dig(-1,1)
                this.placeAny(-1)
                os.sleep(0.25)
                y = -1
            end
            if not scans[2] then
                if y == 0 then
                    this.dig(-1,1)
                    y = -1
                end
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[3] then
                if y < 0 then
                    y = 0
                    this.dig(1,1)
                end
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[4] then
                if y < 1 then
                    this.dig(1,math.abs(y)+1)
                    y = 1
                end
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[5] then
                if y < 1 then
                    this.dig(1,math.abs(y)+1)
                    y = 1
                end
                this.placeAny(1)
                os.sleep(0.25)
            end
            this.adjust(nil, -y)
        end,
        ['RIGHT'] = function()
            scans = {}
            digging[1]()
            this.dig(-1,0)
            if detecting[1]() then
                while digging[1]() do
                    os.sleep(0.75)
                end
            end
            y = 0
            u = vector.new(0,-2,0)
            v = vector.new(1,-1,0)
            scans[1] = this.scan[u]
            scans[2] = this.scan[v]
            v.y = v.y + 1
            scans[3] = this.scan[v]
            v.y = v.y + 1
            scans[4] = this.scan[v]
            u.y = -u.y
            scans[5] = this.scan[u]
            if #scans == 0 then
                return
            end
            if not scans[1] then
                this.dig(-1,1)
                this.placeAny(-1)
                os.sleep(0.25)
                y = -1
            end
            if not scans[2] then
                if y == 0 then
                    this.dig(-1,1)
                    y = -1
                end
                this.right()
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[3] then
                if y < 0 then
                    y = 0
                    this.dig(1,1)
                end
                if scans[2] then
                    this.right()
                end
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[4] then
                if y < 1 then
                    this.dig(1,math.abs(y)+1)
                    y = 1
                end
                if scans[2] and scans[3] then
                    this.right()
                end
                this.placeAny(0)
                os.sleep(0.25)
            end
            if not scans[5] then
                if y < 1 then
                    this.dig(1,math.abs(y)+1)
                    y = 1
                end
                this.placeAny(1)
                os.sleep(0.25)
            end
        end
    }
    local function dig(x, halt)
        if not halt then
            while not this.move() do
                digging[0]()
            end
        end
        Check[x]()
    end
    if length > 0 then
        this.dig(0)
        this.dig(1, 0)
        this.dig(-1, 0)
        for i = 1, length do
            dig('LEFT')
            this.adjust(cardinality[Heading], -y)
        end
        os.sleep(0.5)
        dig('FRONT', true)
        this.right()
        dig('LEFT')
        this.adjust(nil, -y)
        if this._CARDINAL == Heading then
            this.right()
        end
        this.right()
        for i = 1, length do
            dig('CENTER')
        end
        this.left()
        this.dig(1)
        this.left()
        for i = 1, length do
            dig('RIGHT')
            this.adjust(cardinality[Heading], -y)
        end
        os.sleep(0.5)
        dig('FRONT', true)
        this.left()
        this.move()
        this.left()
        for i=0,length-1 do
            if i % 8 == 0 then
                this.selectItem("torch")
                placing[-1]()
            end
            this.move()
        end
        placing[-1]()
    else
        return false
    end
end

local isFuel = function(x)
    if fuel[x] then
        return true
    else
        return false
    end
end

this.getFuel = map.getFuel
refuelSlot = function()
    if fuelSlot == -1 then
        for i = 1, 16 do
            item = this.getInfo(i)
            if item then
                local name = string.sub(item.name, string.find(item.name, ":") + 1)
                if isFuel(name) then
                    fuelWeight = fuel[name]
                    fuelSlot = i
                    return fuelSlot
                elseif name == "material" and item.damage == 6 then
                    fuelWeight = 160
                    fuelSlot = i
                    return fuelSlot
                end
            end
        end
        return fuelSlot
    else
        item = this.getInfo(fuelSlot)
        if item then
            name = string.sub(item.name, string.find(item.name, ":") + 1)
            if isFuel(name) then
                return fuelSlot
            elseif name == "material" and item.damage == 6 then
                return fuelSlot
            else
                fuelSlot = -1
                fuelWeight = -1
                return refuelSlot()
            end
        else
            fuelSlot = -1
            fuelWeight = -1
            return refuelSlot()
        end
    end
end

this.refuel = function(x)
    local originalSlot = this.getSlot()
    if not x then
        if refuelSlot() > 0 then
            map.select(fuelSlot)
            map.refuel(1)
            map.select(originalSlot)
            return true
        else
            return false
        end
    else
        local fuelLevel = map.getFuel()
        if refuelSlot() > 0 then
            map.select(fuelSlot)
            while fuelLevel < tonumber(x) do
                if refuelSlot() > 0 then
                    map.refuel(1)
                    fuelLevel = map.getFuel()
                else
                    return false
                end
            end
            map.select(originalSlot)
            return true
        else
            return false
        end
    end
end

this.selectItem = function(Item)
    local item = map.getInfo()
    if item and string.find(item.name, Item) then
        return true
    else
        for i = 1, 16 do
            item = map.getInfo(i)
            if item and string.find(item.name, Item) then
                map.select(i)
                return true
            end
        end
    end
    return false
end

_CARDINAL_SETUP = function()
    cprint("Set the &1cardinal&0 direction... &9\n")
    for i = 0, 3, 1 do
        cprint("&0[&e" .. i .. "&0] &8" .. cardinality[i] .. "\n")
    end
    local str
    while not str do
        str = tonumber(io.read())
    end
    this._CARDINAL = str % 4
    cprint("You picked [&5" .. cardinality[this._CARDINAL] .. "&0]\n")
    cprint("Is turtle okay [&dy&0/&en&0]?  &9")
    str = io.read():lower()
    if str == "y" then
        clear()
        cprint("&1" .. os.getComputerLabel() .. " ready . . .\n&0")
    elseif str == "n" then
        cprint("&1" .. os.getComputerLabel() .. " not ready rebooting...\n&0")
        os.sleep(3)
        os.reboot()
    else
        cprint("&eBad Input: Please reboot or set manually")
    end
end

cprint("&1Loaded default variables and settings &0\n")

bot = this
bot.native = map