function createMatrix(n)
	local matrix = {}
	for i = 1, n do
		matrix[i] = {}
	end
	
	return matrix
end

function listNetwork()
	for i, daemon in pairs(alua.getdaemons()) do
		print(i, daemon)
	end
end

function join(msg)
	print(msg.src .. " wants to work")
	table.insert(workers, msg.src)
end

function leave(msg)
	print(msg.src .. " wants to leave")
	table.remove(workers, msg.src)
	alua.send_event(msg.src, "release")
end

function checkout(msg)
	print(msg.src .. " requested work")
	if jobData.nextCell.y > jobData.n + 1 then
		alua.send_event(msg.src, "release")
	else
		alua.send_event(msg.src, "work", jobData.nextCell)
	end
	
	jobData.nextCell.x = jobData.nextCell.x + 1
	if jobData.nextCell.x > jobData.n + 1 then
		jobData.nextCell.x = 1
		jobData.nextCell.y = jobData.nextCell.y + 1
	end
end

function checkin(msg)
	print("got result " .. msg.data.x .. "," .. msg.data.y .. " from " .. msg.src)
	
	jobData.cost[msg.data.x][msg.data.y] = msg.data.nextCost
	jobData.root[msg.data.x][msg.data.y] = msg.data.nextRoot
	
	jobData.worksLeft = jobData.worksLeft - 1
	
	if jobData.worksLeft <= 0 then
		alua.send_event(master, "printResult", jobData)
		for i, worker in pairs(workers) do
			alua.send_event(worker, "release")
		end
		
		print("done, will run no more")
		alua.quit()
	end
end

function searchTree(msg)
	print("got searchTree command from " .. msg.src)
	master = msg.src
	
	jobData = {}
	
	jobData.n = msg.data.n
	jobData.p = msg.data.p	
	
	jobData.cost = createMatrix(msg.data.n + 1)
	jobData.root = createMatrix(msg.data.n + 1)
	
	jobData.nextCell = {x = 1, y = 1}
	jobData.worksLeft = (msg.data.n + 1) * (msg.data.n + 1)

	for i, worker in pairs(workers) do
		alua.send_event(worker, "start", jobData)
	end
end

print(alua.id .. " got code!")
listNetwork()

workers = {}

alua.reg_event("searchTree", searchTree)
alua.reg_event("join", join)
alua.reg_event("leave", leave)
alua.reg_event("checkout", checkout)
alua.reg_event("checkin", checkin)

