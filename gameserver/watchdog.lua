local skynet = require "skynet"
local socket = require "socket"

local CMD = {}
local SOCKET = {}
local gate
local agent = {}
local checking = {}
local gamed

local function close_agent(fd)
    local a = agent[fd]
    agent[fd] = nil
    if a then
        skynet.call(gate, "lua", "kick", fd)
        -- disconnect never return
        skynet.send(a, "lua", "disconnect")
    end
end

function SOCKET.open(fd, addr)
	print("New client from : " .. addr,fd)
	skynet.call(gate,"lua","accept",fd)
	checking[fd] = true
end


function SOCKET.close(fd)
	skynet.logInfo("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	skynet.logError("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	skynet.logWarning("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
	if checking[fd] == true then
		checking[fd] = nil
		local ret,uid = skynet.call(gamed,"lua","auth",msg)
		socket.write(fd,ret..'\n')
		
	    if ret == "200" then
	        local agent_pool = skynet.uniqueservice("agentPool")
	        agent[fd] = skynet.call(agent_pool,"lua","fetch")
	        skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self(),user = uid })
	    end

	end
end

function CMD.start(conf)
	gamed = conf.gamed
	skynet.call(gate, "lua", "open" , conf)

	skynet.call(gamed,"lua","start",skynet.self())
end
function CMD.close(fd)
	close_agent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("gate")
end)
