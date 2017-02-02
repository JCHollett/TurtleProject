EnderChest = setmetatable({type='ender_chest'}, Chest)
EnderChest.__index = EnderChest

local HexVert = {
	[0] = '0',
	[1] = '1',
	[2] = '2',
	[3] = '3',
	[4] = '4',
	[5] = '5',
	[6] = '6',
	[7] = '7',
	[8] = '8',
	[9] = '9',
	[10] = 'A',
	[11] = 'B',
	[12] = 'C',
	[13] = 'D',
	[14] = 'E',
	[15] = 'F' 
}

local CASES = {
	['setChannel']= {
		[0] = function(this)
			return false
		end,
		[1] = function(this, args)
			args[1] = tonumber(args[1])
			if type(args[1]) == 'number' then
				this.chestObj.setFrequency(args[1])
				this.frequency = args[1]
				return true	
			end
		end,
		[2] = function(this, args)
			return false
		end,
		[3] = function(this, args)
			local num = tonumber('0x' .. HexVert[args[1]] .. HexVert[args[2]] .. HexVert[args[3]] )
			if num then
				this.chestObj.setFrequency(num)
				this.frequency = num
				return true
			else
				return false
			end
		end
	}
}

function EnderChest.new(bot, wrapped, face)
	local Source = {chestObj = wrapped, obj = bot, frequency = wrapped.getFrequency() }
	local self = setmetatable(Chest.new(bot,wrapped,face), EnderChest)
	function self:setChannel(...)
		local pArgs = {...}
		return CASES.setChannel[#pArgs](Source, pArgs)
	end
	function self:getChannel()
		return Source.frequency
	end
	return self
end

