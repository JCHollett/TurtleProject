Reactor = { }
Reactor.__index = Reactor

function Reactor.new(init)
	local self = setmetatable({}, Reactor)

	return self
end