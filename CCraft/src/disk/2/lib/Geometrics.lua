local Cardinality = {
	[0] = "SOUTH",
	[1] = "WEST",
	[2] = "NORTH",
	[3] = "EAST",
	["SOUTH"] = 0,
	["WEST"] = 1,
	["NORTH"] = 2,
	["EAST"] = 3
}
local fromDir = {
	["UP"]  = 1,
	["DOWN"] = 2,
	["SOUTH"] = 3,
	["NORTH"] = 4,
	["EAST"] = 5,
	["WEST"] = 6
}
local Direction = {
	[2] = 1,
	[1] = 2,
	[4] = 3,
	[3] = 4,
	[6] = 5,
	[5] = 6
}
local toDir = {
	["DOWN"] = 1,
	["UP"] = 2,
	["NORTH"] = 3,
	["SOUTH"] = 4,
	["WEST"] = 5,
	["EAST"] = 6
}
local Surface = {
	["back"] = 2,
	["left"] = -1,
	["front"] = 0,
	["right"] = 1,
	[2] = "back",
	[-1] = "left",
	[0] = "front",
	[1] = "right",
	["top"] = "UP",
	["bottom"] = "DOWN"
}
local Turning = {
	['left'] = {
		['back'] = 'left',
		['left'] = 'front',
		['front'] = 'right',
		['right'] = 'back'
	}, 
	['right'] = {
		['back'] = 'right',
		['left'] = 'back',
		['front'] = 'left',
		['right'] = 'front'
	},
	['back'] = {
		['back'] = 'front',
		['left'] = 'right',
		['right'] = 'left',
		['front'] = 'back'
	}
}

Geometrics = {Cardinality = Cardinality, Surface = Surface, Turning = Turning}
Geometrics.__index = Geometrics
function Geometrics.new(this)
	local Source = this
	local self = {}
	local parse = function(Face)
		Face = (type(Face) == 'string' and string.lower(Face)) or Face 
		return (type(Face) == 'number' and Surface[Face] ) or (type(Surface[Face]) == 'number' and Face) or Surface[Face] 
	end
	local translate = function(x)
		--[[Assumptions: Is a valid Geometric string or number]]--
		if not x then 
			return nil
		else 
			return (not Surface[x] and x) or Geometrics.Cardinality[ (Surface[x] + Source._CARDINAL) % 4]
		end
	end
	local __In = function(x)
		return toDir[translate(x)]
	end
	
	local __Out = function(x)
		return fromDir[translate(x)]
	end
	function self:Out(face)
		return __Out(parse(face or 0))
	end
	function self:In(face)
		return __In(parse(face or 0))
	end
	return setmetatable(self, Geometrics)
end
