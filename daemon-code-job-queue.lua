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
		alua.send_event(msg.src, "release")
	end
end

function checkin(msg)
	print("got result " .. msg.data.x .. "," .. msg.data.y .. " from " .. msg.src)
	
	jobData.cost[msg.data.x][msg.data.y] = msg.data.nextCost
	jobData.root[msg.data.x][msg.data.y] = msg.data.nextRoot
	
	jobData.worksLeft = jobData.worksLeft - 1
	
	if not jobData.nextCells[1] then
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

	for i = 1, jobData.n do
		jobData.cost[i][i] = 0
		jobData.root[i][i] = i
		
		jobData.cost[i][i + 1] = jobData.p[i]
		jobData.root[i][i + 1] = i
	end
	jobData.cost[jobData.n + 1][jobData.n + 1] = 0
	jobData.root[jobData.n + 1][jobData.n + 1] = jobData.n + 1
	
	-- rodar o loop e colocar as celulas em ordem de entrega
	jobData.nextCells = {}
	for i = 3, jobData.n + 1 do
		for j = i - 2, 1, -1 do
			table.insert(jobData.nextCells, {x = j, y = i})
		end
	end
	
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

