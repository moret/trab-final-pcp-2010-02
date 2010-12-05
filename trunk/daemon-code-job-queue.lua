function log(s)
	if __debug then print(s) end
end

function createMatrix(n)
	local matrix = {}
	for i = 1, n do
		matrix[i] = {}
		for j = 1, n do
			matrix[i][j] = 0
		end
	end
	
	return matrix
end

function listNetwork()
	for i, daemon in pairs(alua.getdaemons()) do
		log(i, daemon)
	end
end

function join(msg)
	print(msg.src .. " joined")
	table.insert(workers, msg.src)
end

function leave(msg)
	print(msg.src .. " left")
	table.remove(workers, msg.src)
	alua.send_event(msg.src, "release")
end

function checkout(msg)
	log(msg.src .. " requested work")
	
	if jobData.nextCells[1] then
		local nextCell = jobData.nextCells[1]
		table.remove(jobData.nextCells, 1)
		
		local workData = {
			nextCell = nextCell,
			cost = jobData.cost,
			root = jobData.root
		}
		-- sending the whole table - improve that!
		alua.send_event(msg.src, "work", workData)
	else
		alua.send_event(msg.src, "later")
	end
end

function checkin(msg)
	log("got result " .. msg.data.x .. "," .. msg.data.y .. " from " .. msg.src)
	
	jobData.cost[msg.data.x][msg.data.y] = msg.data.nextCost
	jobData.root[msg.data.x][msg.data.y] = msg.data.nextRoot
	
	jobData.controlTable[msg.data.x][msg.data.y] = true
	jobData.controlCheckin = jobData.controlCheckin - 1
	
	-- insert new cells on the queue if freed
	-- if the left-above cell is in, put the above cell in the queue
	if (msg.data.x - 1 >= 1) and (msg.data.y - 1 >= 1) then
		if jobData.controlTable[msg.data.x - 1][msg.data.y - 1] then
			log("adding work to the queue on " .. msg.data.x - 1 .. "," .. msg.data.y)
			table.insert(jobData.nextCells, {x = msg.data.x - 1, y = msg.data.y})
		end
	end

	-- if the right-down cell is in, put the right cell in the queue
	if (msg.data.x + 1 <= jobData.n + 1) and (msg.data.y + 1 <= jobData.n + 1) then
		if jobData.controlTable[msg.data.x + 1][msg.data.y + 1] then
			log("adding work to the queue on " .. msg.data.x .. "," .. msg.data.y + 1)
			table.insert(jobData.nextCells, {x = msg.data.x, y = msg.data.y + 1})
		end
	end
	
	if jobData.controlCheckin < 1 then
		alua.send_event(master, "printResult", jobData)
		for i, worker in pairs(workers) do
			alua.send_event(worker, "done")
		end
		
		--[[
		log("done, will run no more")
		alua.quit()
		]]--
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

	for i = 1, jobData.n do
		jobData.cost[i][i] = 0
		jobData.root[i][i] = i
		
		jobData.cost[i][i + 1] = jobData.p[i]
		jobData.root[i][i + 1] = i
	end
	jobData.cost[jobData.n + 1][jobData.n + 1] = 0
	jobData.root[jobData.n + 1][jobData.n + 1] = jobData.n + 1
	
	-- fill the initial queue
	jobData.nextCells = {}
	for i = 1, jobData.n - 1 do
		log("adding work to the queue on " .. i .. "," .. i + 2)
		table.insert(jobData.nextCells, {x = i, y = i + 2})
	end

	-- create control table
	jobData.controlCheckin = 0
	jobData.controlTable = {}
	for i = 1, jobData.n - 1 do
		jobData.controlTable[i] = {}
		for j = i + 2, jobData.n + 1 do
			jobData.controlTable[i][j] = false
			jobData.controlCheckin = jobData.controlCheckin + 1
		end
	end
	
	for i, worker in pairs(workers) do
		alua.send_event(worker, "start", jobData)
	end
end

log(alua.id .. " got code!")
listNetwork()

workers = {}

alua.reg_event("searchTree", searchTree)
alua.reg_event("join", join)
alua.reg_event("leave", leave)
alua.reg_event("checkout", checkout)
alua.reg_event("checkin", checkin)

