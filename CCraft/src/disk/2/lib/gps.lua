GPS = { }
GPS.__index = GPS

function GPS.new(...)
	local self = setmetatable({x=0,y=0,z=0 }, GPS)
	local hasModem = false
	local sideModem = "none"
	function self.open()
		for n,side in pairs(rs.getSides()) do
			hasModem = false
			sideModem = "none"
			if peripheral.getType( side ) == "modem" then
				sideModem = side
				if not rednet.isOpen( sideModem ) then
					rednet.open( sideModem )
				end
				hasModem = true
				break;
			end
		end
		return hasModem
	end
	function self.isActive()
		if not rednet.isOpen(sideModem) then
			hasModem = false
			sideModem = "none"
		end
		return hasModem
	end
	function self.Host(...)
		local pArgs = {...}
		local sender, message, distance = 'none','none','none'
		if self.open() then
			if #pArgs >= 4 then
				x = tonumber(pArgs[2])
				y = tonumber(pArgs[3])
				z = tonumber(pArgs[4])
				if x == nil or y == nil or z == nil then
					print("Failed to Host")
					return
				end
			else
				self.x, self.y, self.z = gps.locate( 2, true )
				if self.x == nil then
					print("Failed to Host")
					return
				end
			end
			local function gpsThread()
				print( "GPS Hosting Enabled" )
				while true do
					sender,message,distance = rednet.receive()
					if message == "PING" then
						rednet.send(sender, textutils.serialize({x,y,z}))
					end
				end
				print("GPS Hosting Disabled")
			end
			gpsThread();
		else
			print("No modem or fail conditions")
		end
	end

	function self.Locate()
		if self.isActive() then
			gps.locate(2, true)
		end
	end

	return self
end




