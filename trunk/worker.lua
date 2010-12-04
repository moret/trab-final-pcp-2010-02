require("alua")

function start(msg)
	print(msg.src .. " has work to me")
	jobData	= msg.data
	alua.send_event(msg.src, "checkout")
end

function work(msg)
	print(msg.src .. " wants me to work on " .. msg.data.nextNumber .. "... don't know how")
	msg.data.nextNumber = msg.data.nextNumber + 1
	alua.send_event(msg.src, "checkin", msg.data)
end

function release(msg)
	print("release from " .. msg.src .. " - bye then!")
	alua.quit()
end

function connectCB(reply)
	print("connected to " .. reply.id)
	
	alua.reg_event("start", start)
	alua.reg_event("work", start)
	alua.reg_event("release", release)
	
	alua.send_event(alua.daemonid, "join")
end

if not (#arg == 2) then
	error("Bad number of arguments. Syntax: lua worker.lua <daemons-ip> <daemons-port>")
end

jobData = {}

-- Connect to the informed daemon
local ip = arg[1]
local port = arg[2]
alua.connect(ip, port, connectCB)
alua.loop()
alua.quit()

