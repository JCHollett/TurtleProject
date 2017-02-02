Chest = {type = 'chest'}
Chest.__index = Chest

local CASES = {
	['insert'] = {
		[0] = function(this)
			return this.chestObj.pullItem(this.obj.geo:Out(this.side),this.obj.getSlot())
			--[[Inserts whatever is selected currently]]--
		end,
		[1] = function(this,args)
			return this.chestObj.pullItem(this.obj.geo:Out(this.side),args[1])
			--[[Inserts from a slot into the chest]]--
		end,
		[2] = function(this,args)
			return this.chestObj.pullItem(this.obj.geo:Out(this.side),args[1], args[2])
			--[[Inserts from a slot into the chest by a certain amount]]--
		end,
		[3] = function(this,args)
			return this.chestObj.pullItem(this.obj.geo:Out(this.side),args[1], args[2], args[3])
			--[[Inserts from a slot to a slot in the chest by some amount]]--
		end
	},
	['remove'] = {
		[0] = function(this)
			local ItemStack = this.chestObj.getAllStacks()
			local amnt = 0;
			for i=1,this.chestObj.getInventorySize() do
				
				if this.obj.getCapacity() == 0 then
					return amnt
				end
				if ItemStack[i] then
					amnt = amnt + this.chestObj.pushItem(this.obj.geo:Out(this.side), i, 64, this.obj.getSlot())
				end
			end
			return amnt
			--[[Removes the first item it can from the slot of the chest in order]]--
		end,
		[1] = function(this,args)
			return this.chestObj.pushItem(this.obj.geo:Out(this.side), args[1], 64, this.obj.getSlot())
			--[[Removes all of item from the slot of a chest]]--
		end,
		[2] = function(this,args)
			return this.chestObj.pushItem(this.obj.geo:Out(this.side), args[1], args[2], this.obj.getSlot())
			--[[Removes a certain amount of an item from the slot of the chest]]--
		end,
		[3] = function(this,args)
			return this.chestObj.pushItem(this.obj.geo:Out(this.side), args[1], args[2], args[3])
			--[[Removes a certain amount of an item from the slot of the chest into a slot of the turtle]]--
		end
	},
	['get'] = {
		[0] = function(this)
			--[[Get nothing lul]]--
		end,
		[1] = function(this,args)
			--[[Get all of an item z]]--
		end,
		[2] = function(this,args)
			--[[Get x amount of an item z]]--
		end,
		[3] = function(this,args)
			--[[Get x amount of an item z and insert it into a slot y]]--
		end
	},
	['find'] = {
		[0] = function(this)
			--[[Error: No args]]
			error("no args")
			return nil
		end,
		[1] = function(this,args)
			--[[Find an item z]]--
			local Item = false
			for k,v in pairs(this.chestObj.getAllStacks()) do
				Item = v.all()
			end
		end,
		[2] = function(this,args)
			--[[Find an item z starting from slot x]]--
		end,
		[3] = function(this,args)
			--[[Find an item z starting from slot x and ending at slot y]]--
		end
	}
}

function Chest.new(bot, wrapped, face)
	local Source = {chestObj = wrapped, obj = bot }
	local self = {side = face}
	function self:insert(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.insert[#pArgs](Source, pArgs)
		end			
	end
	
	function self:remove(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.remove[#pArgs](Source, pArgs)
		end
	end
	
	function self:get(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.get[#pArgs](Source, pArgs)
		end
	end
	
	function self:find(...)
		local pArgs = {...}
		if Source.chestObj then
			return CASES.find[#pArgs](Source, pArgs)
		end
	end
	function self:rewrap()
		if peripheral.getType(self.side) == self.type then
			Source.chestObj = peripheral.wrap(self.side)
		else
			Source.chestObj = nil
		end
	end
	return setmetatable(self, Chest)
end