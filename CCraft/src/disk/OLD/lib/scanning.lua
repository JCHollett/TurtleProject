scantest = {
	start = function()
		bot.move(7)
		bot.move(1,2)
	end,
	stop = function()
		bot.move(-1,2)
		bot.move(-7)
	end
}

local Vector = vector.new

function vector.new(x,y,z)
	local self = Vector(x,y,z)
	self.type = 'vector'
	return self
end

map = {
	[-3] = {
		[0] = {
			[0] = 1
		}
	},
	[-2] = {
		[-2] = {
			[-1] = 2,
			[0] = 3,
			[1] = 4
		},
		[-1] = {
			[-2] = 5,
			[-1] = 6,
			[0] = 7,
			[1] = 8,
			[2] = 9
		},
		[0] = {
			[-2] = 10,
			[-1] = 11,
			[0] = 12,
			[1] = 13,
			[2] = 14
		},
		[1] = {
			[-2] = 15,
			[-1] = 16,
			[0] = 17,
			[1] = 18,
			[2] = 19
		},
		[2] = {
			[-1] = 20,
			[0] = 21,
			[1] = 22
		}
	},
	[-1] = {
		[-2] = {
			[-2] = 23,
			[-1] = 24,
			[0] = 25,
			[1] = 26,
			[2] = 27
		},
		[-1] = {
			[-2] = 28,
			[-1] = 29,
			[0] = 30,
			[1] = 31,
			[2] = 32
		},
		[0] = {
			[-2] = 33,
			[-1] = 34,
			[0] = 35,
			[1] = 36,
			[2] = 37
		},
		[1] = {
			[-2] = 38,
			[-1] = 39,
			[0] = 40,
			[1] = 41,
			[2] = 42
		},
		[2] = {
			[-2] = 43,
			[-1] = 44,
			[0] = 45,
			[1] = 46,
			[2] = 47
		}
	},
	[0] = {
		[-3] = {
			[0] = 48
		},
		[-2] = {
			[-2] = 49,
			[-1] = 50,
			[0] = 51,
			[1] = 52,
			[2] = 53
		},
		[-1] = {
			[-2] = 54,
			[-1] = 55,
			[0] = 56,
			[1] = 57,
			[2] = 58
		},
		[0] = {
			[-3] = 59,
			[-2] = 60,
			[-1] = 61,
			[1] = 62,
			[2] = 63,
			[3] = 64
		},
		[1] = {
			[-2] = 65,
			[-1] = 66,
			[0] = 67,
			[1] = 68,
			[2] = 69
		},
		[2] = {
			[-2] = 70,
			[-1] = 71,
			[0] = 72,
			[1] = 73,
			[2] = 74
		},
		[3] = {
			[0] = 75
		}
	},
	[1] = {
		[-2] = {
			[-2] = 76,
			[-1] = 77,
			[0] = 78,
			[1] = 79,
			[2] = 80
		},
		[-1] = {
			[-2] = 81,
			[-1] = 82,
			[0] = 83,
			[1] = 84,
			[2] = 85
		},
		[0] = {
			[-2] = 86,
			[-1] = 87,
			[0] = 88,
			[1] = 89,
			[2] = 90
		},
		[1] = {
			[-2] = 91,
			[-1] = 92,
			[0] = 93,
			[1] = 94,
			[2] = 95
		},
		[2] = {
			[-2] = 96,
			[-1] = 97,
			[0] = 98,
			[1] = 99,
			[2] = 100
		}
	},
	[2] = {
		[-2] = {
			[-1] = 101,
			[0] = 102,
			[1] = 103
		},
		[-1] = {
			[-2] = 104,
			[-1] = 105,
			[0] = 106,
			[1] = 107,
			[2] = 108
		},
		[0] = {
			[-2] = 109,
			[-1] = 110,
			[0] = 111,
			[1] = 112,
			[2] = 113
		},
		[1] = {
			[-2] = 114,
			[-1] = 115,
			[0] = 116,
			[1] = 117,
			[2] = 118
		},
		[2] = {
			[-1] = 119,
			[0] = 120,
			[1] = 121
		}
	},
	[3] = {
		[0] = {
			[0] = 122
		}
	}
}

Filter = {
	AIR = "AIR",
	SOLID = "SOLID",
	UNKNOWN = "UNKNOWN",
	LIQUID = "LIQUID"
}
Scanner = {}
Scanner.__index = Scanner

function Scanner.new(initWrapper)
	function Scanner:__index(key)
		if key.type == "vector" then
			if not self.Data then
				self.Data = self.Sensor.sonicScan()
				while not self.Data do end
			end
			local Key = Relative[cardinality[this._CARDINAL]](key)
			local S = self.Data[map[Key.x][Key.y][Key.z]]
			if self.type then
				return S.type == self.type
			end
			return S
		end
		return rawget(Scanner, key) or rawget(self, key)
	end
	function Scanner:__newindex(key, value)
		rawset(self, key, value)
	end

	function Scanner:reinit()
		self.Sensor = initWrapper.wrap('SENSOR')
	end

	local self = setmetatable({ Sensor = false, Data = nil, type = nil }, Scanner)
	self:reinit()
	return self
end


function Scanner:filter(type)
	if Filter[type] then
		self.type = type
	else
		self.type = nil
	end
end



