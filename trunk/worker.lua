require("alua")

function start(msg)
	print("got ok to start from " .. msg.src)
	jobData	= msg.data
	alua.send_event(msg.src, "checkout")
end

function work(msg)
	print("got work on " .. msg.data.nextCell.x .. "," .. msg.data.nextCell.y)
	
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

