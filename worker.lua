require("alua")
require("socket")

function log(s)
	if __debug then print(s) end
end

function sleep(sec)
	log("going to sleep for a while...")
	socket.select(nil, nil, sec)
end

function start(msg)
	print("new job size " .. msg.data.n)
	jobData	= msg.data
	jobAvailable = true
	alua.send_event(msg.src, "checkout")
end

function work(msg)
	log("got work on " .. msg.data.nextCell.x .. "," .. msg.data.nextCell.y)
	
	jobData.cost = msg.data.cost
	jobData.root = msg.data.root
	
	local x = msg.data.nextCell.x
	local y = msg.data.nextCell.y
	
	local bestcost = 10000000000
	local tempCost = 0
	
	for i = x, y - 1 do
		tempCost = tempCost + jobData.p[i]
	end
	
	for i = x, y - 1 do
		local rcost = tempCost + jobData.cost[x][i] + jobData.cost[i + 1][y]
		
		if rcost < bestcost then
			bestcost = rcost
			bestroot = i
		end
	end
	
	jobData.cost[x][y] = bestcost
	jobData.root[x][y] = bestroot

	local workData = {
		nextCost = bestcost,
		nextRoot = bestroot,
		x = x,
		y = y
	}
	
	alua.send_event(msg.src, "checkin", workData)
	alua.send_event(msg.src, "checkout")
end

function later(msg)
	-- nothing to work on yet, come back later
	sleep(1)
	if jobAvailable then
		alua.send_event(msg.src, "checkout")
	end
end

function done(msg)
	jobAvailable = false
end

function release(msg)
	log("release event from " .. msg.src .. " - bye!")
	alua.quit()
end

function connectCB(reply)
	log("connected to " .. reply.id)
	
	alua.reg_event("start", start)
	alua.reg_event("work", work)
	alua.reg_event("later", later)
	alua.reg_event("done", done)
	alua.reg_event("release", release)
	
	alua.send_event(alua.daemonid, "join")
end

if not (#arg == 2) then
	error("Bad number of arguments. Syntax: lua worker.lua <daemons-ip> <daemons-port>")
end

jobData = {}
jobAvailable = false

-- Connect to the informed daemon
ip = arg[1]
port = arg[2]
alua.connect(ip, port, connectCB)
alua.loop()
alua.quit()

