
rednet.open('left')
local modem = peripheral.wrap('left')
local network
local heartbeat
local Send = {}
local Foreman = {
	['initForeman'] = function(SenderID, data)
		Send[SenderID] = data
		rednet.send(SenderID, os.getComputerLabel(),'Foreman')
	end
}
local Quarry = {

}

if os.getComputerLabel() == 'Foreman_13' then
	network = function()
		while true do
			local SenderID, data, protocol = rednet.receive()
			if Foreman[protocol] then
				Foreman[protocol](SenderID, data)
			else
				if Send[SenderID] then
					print(Send[SenderID] .. ':' .. data)
				end
			end
		end
	end
	print('Foreman Running...')
	os.startThread(network)
else
	rednet.broadcast(os.getComputerLabel(),'initForeman')
	local SenderID, data, protocol = rednet.receive('Foreman')
	if protocol == 'Foreman' then
		Send = SenderID
	else
		print('Error')
		os.reboot()
	end
	network = function()
		while true do
			local SenderID, data, protocol = rednet.receive('Foreman')
		end
	end
	heartbeat = function()
		while true do
			rednet.send(Send,'HeartBeat')
			os.sleep(5)
		end
	end
	os.startThread(network)
	os.startThread(heartbeat)
	print('Quarry running...')
end