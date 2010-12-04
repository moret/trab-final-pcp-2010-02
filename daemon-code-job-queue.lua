function listNetwork()
	for i, daemon in pairs(alua.getdaemons()) do
		print(i, daemon)
	end
end

function join(msg)
	print("hey, " .. msg.src .. " wants to work")
	table.insert(workers, msg.src)
end

function leave(msg)
	print("hey, " .. msg.src .. " wants to leave")
	table.remove(workers, msg.src)
	alua.send_event(msg.src, "release")
end

function checkout(msg)
	print("hey, " .. msg.src .. " wants some work, the poor fella")
	alua.send_event(msg.src, "work", jobData)
end

function checkin(msg)
	print("hey, got " .. msg.data .. " from " .. msg.src)
	jobData.nextNumber = msg.data.nextNumber
	if msg.data.nextNumber > 10 then
		alua.send_event(master, "printResult", "done... doing... whatever...")
		for i, worker in pairs(workers) do
			alua.send_event(worker, "release")
		end
	end
end

function searchTree(msg)
	print("hey, " .. msg.src .. " wants us to search his tree 8)")
	master = msg.src

	for i, worker in pairs(workers) do
		alua.send_event(worker, "start", jobData)
	end
end

print(alua.id .. " got code!")
listNetwork()

workers = {}
jobData = {
	nextNumber = 1,
	p = {5, 6, 3, 7, 2, 7, 3, 9, 1, 4},
	cost = {}
}

alua.reg_event("searchTree", searchTree)
alua.reg_event("join", join)
alua.reg_event("leave", leave)
alua.reg_event("checkout", checkout)
alua.reg_event("checkin", checkin)

