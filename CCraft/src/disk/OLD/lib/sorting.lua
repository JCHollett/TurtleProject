condense = function(min, max)
    max = max or this.wrap().getInventorySize()
    min = min or 1
    local stack = this.wrap().getAllStacks()
    local maxn = table.maxn(stack)
    if max > maxn then
        max = table.maxn(stack)
    end
    for i=min,max do
        local k = i

        if stack[k] == nil then
            for j=i+1,max do
                if stack[j] ~= nil then
                    k = j
                    break
                end
            end
        end
        this.getEmpty()
        this.pull(k,this.getSlot())
        for j=k+1,max do
            if this.getCapacity() == 0 then
                break
            end
            if stack[j] ~= nil then
                if equals(stack[k].basic().id,stack[j].basic().id) then
                    this.pull(j,this.getSlot())
                end
            end
        end
        this.push(this.getSlot(),i)

        stack = this.wrap().getAllStacks()
        maxn = table.maxn(stack)
        if i >= maxn then
            break
        end
        if max > maxn then
            max = maxn
        end
    end
end

sortAlpha = function(min, max)
    condense(min,max)
    local stack = this.wrap().getAllStacks()
    local min = min or 1
    local max = max or table.maxn(stack)
    local iMin = min
    for j=min,max-1 do
        iMin = j
        for i = j+1,max do
            if stack[i].basic().display_name < stack[iMin].basic().display_name then
                iMin = i
            end
        end
        if iMin ~= j then
            local temp = stack[j]
            stack[j] = stack[iMin]
            stack[iMin] = temp
            this.wrap().swapStacks(j,iMin)
        end
    end
end



sortQty = function(min, max)
    if this.wrap() == nil then return false end
    local stack, inventory
    inventory = this.wrap()
    stack = inventory.getAllStacks()
    if table.maxn(stack) == 0 then
        return false
    end
    if (min and max) == nil then
        inventory.condenseItems()
        min = 1
        stack = inventory.getAllStacks()
        max = table.maxn(stack)
    elseif max == nil then
        condense(min,inventory)
        stack = inventory.getAllStacks()
        max = table.maxn(stack)
    else
        condense(min,max)
        stack = inventory.getAllStacks()
        for i=max,min,-1 do
            if stack[i] == nil then
                max = max - 1
            end
        end
    end
    local iMin = min
    for j=min,max-1 do
        iMin = j
        for i = j+1,max do
            if stack[i].basic().qty > stack[iMin].basic().qty then
                iMin = i
            end
        end
        if iMin ~= j then
            local temp = stack[j]
            stack[j] = stack[iMin]
            stack[iMin] = temp
            inventory.swapStacks(j,iMin)
        end
    end
end