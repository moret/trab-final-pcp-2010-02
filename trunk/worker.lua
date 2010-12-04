require("alua")

function start(msg)
	print("got ok to start from " .. msg.src)
	jobData	= msg.data
	alua.send_event(msg.src, "checkout")
end

function work(msg)
	print("got work on " .. msg.data.x .. "," .. msg.data.y)
	
	local workData = {
		nextCost = msg.data.x + msg.data.y,
		nextRoot = msg.data.x * msg.data.y,
		x = msg.data.x,
		y = msg.data.y
	}
	
	alua.send_event(msg.src, "checkin", workData)
	alua.send_event(msg.src, "checkout")
end

function release(msg)
	print("release event from " .. msg.src .. " - bye!")
	alua.quit()
end

function connectCB(reply)
	print("connected to " .. reply.id)
	
	alua.reg_event("start", start)
	alua.reg_event("work", work)
	alua.reg_event("release", release)
	
	alua.send_event(alua.daemonid, "join")
end

if not (#arg == 2) then
	error("Bad number of arguments. Syntax: lua worker.lua <daemons-ip> <daemons-port>")
end

jobData = {}

-- Connect to the informed daemon
ip = arg[1]
port = arg[2]
alua.connect(ip, port, connectCB)
alua.loop()
alua.quit()

