function listNetwork()
	for i, daemon in pairs(alua.getdaemons()) do
		print(i, daemon)
	end
end

function shareCode(code)
	for i, daemon in pairs(alua.getdaemons()) do
		if not (daemon == alua.id) then
			alua.send(daemon, code)
		end
	end
end

function printMatrix(n, m, matrix, matrixName)
	io.write(matrixName)
	for j = 1, n do
		io.write(string.format("%5d  ", j))
	end
	print()
	for i = 1, n do
		io.write(i .. ":  ")
		for j = 1, m do
			io.write(string.format("%5d, ", matrix[i][j]))
		end
		print()
	end
end

function treeOutput(root, low, high)
	print("tree: " .. low .. " - " .. high .. "; root: " .. root[low][high + 1] .. "\n")
	if low < root[low][high + 1] - 1 then
		treeOutput(root, low, root[low][high + 1] - 1)
	end
	if root[low][high + 1] < high - 1 then
		treeOutput(root, root[low][high + 1] + 1, high)
	end
end

function searchTree(msg)
	local n = msg.data.n
	local p = msg.data.p

	local cost = {}
	local root = {}

	for i = 1, n + 1 do
		cost[i] = {}
		root[i] = {}
		for j = 1, n + 1 do
			cost[i][j] = 0
			root[i][j] = 0
		end
	end
	
	for i = 1, n do
		cost[i][i] = 0;
		root[i][i] = i;
		
		cost[i][i + 1] = p[i];
		root[i][i + 1] = i;
	end
	cost[n + 1][n + 1] = 0;
	root[n + 1][n + 1] = n + 1;
	
	local daemons = alua.getdaemons()
	for i, daemon in pairs(daemons) do
		local leftIndex = (i + #daemons - 2) % #daemons + 1
		local rightIndex = i % #daemons + 1
		local daemonData = {
			pid = i,
			n = n,
			p = p,
			cost = cost,
			root = root,
			leftDaemon = daemons[leftIndex],
			rightDaemon = daemons[rightIndex]
		}
		alua.send_event(daemon, "searchTreeDaemon", daemonData)
	end
end

function searchTreeDaemon(msg)
	pid = msg.data.pid
	n = msg.data.n
	p = msg.data.p
	cost = msg.data.cost
	root = msg.data.root
	leftDaemon = msg.data.leftDaemon
	rightDaemon = msg.data.rightDaemon
	np = #(alua.getdaemons())
	
	--print("my left daemon is " .. leftDaemon)
	--print("my right daemon is " .. rightDaemon)
	--printMatrix(n + 1, n + 1, cost, "cost")
	--printMatrix(n + 1, n + 1, root, "root")
	
	local partData = {
		costRow = cost[pid - 2],
		rootRow = root[pid - 2],
		x = pid - 2,
		y = pid
	}
	
	alua.send_event(alua.id, "searchTreePart", partData)
end

function searchTreePart(msg)
	local costRow = msg.data.costRow
	local rootRow = msg.data.rootRow
	local x = msg.data.x
	local y = msg.data.y
	
	if costRow then
		cost[x] = costRow
		root[x] = rootRow
	end

	-- The algorithm itself
	local bestcost = 10000000000
	local tempCost = 0
	
	for i = x, y - 1 do
		tempCost = tempCost + p[i]
	end
	
	for i = x, y - 1 do
		local rcost = tempCost + cost[x][i] + cost[i + 1][y]
		
		if rcost < bestcost then
			bestcost = rcost
			bestroot = i
		end
	end
	
	cost[x][y] = bestcost
	root[x][y] = bestroot
	
	local leftDaemonData = {
	}
	
	alua.send_event(rightDaemon, "searchTreePart", )
end

print(alua.id .. " got code!")
listNetwork()

alua.reg_event("searchTree", searchTree)
alua.reg_event("searchTreeDaemon", searchTreeDaemon)
alua.reg_event("searchTreePart", searchTreePart)

