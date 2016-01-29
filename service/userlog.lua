local skynet = require "skynet"
require "skynet.manager"

local logfile = nil
function __log( address,msg )
    msg = string.format("[%s](%x-%.2f): %s", os.date(),address, skynet.time(), msg)
    print(msg)
    if logfile ~= nil then
        logfile:write(msg)
	    logfile:write("\n")
        logfile:flush()
    end
end
local CMD = {}
function CMD.info(address, msg )
    __log(address,"[Info]"..msg)
end
function CMD.error(address, msg )
    __log(address,"[Error]"..msg)
end
function CMD.warning(address, msg )
    __log(address,"[Warning]"..msg)
end

function CMD.exit( ... )
    if logfile ~= nil then
        io.close(logfile)
    end
end

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
        __log(address,msg)
	end
}

skynet.start(function()
	skynet.register ".logger"
	local filename = os.date("%Y-%m-%d-%H:%M.log",os.time())
    logfile = io.open(filename,"w+") 
    if logfile == nil then
	   print("can not open log file",filename)
end
    skynet.dispatch("lua", function(session, address,command, msg)
        local f = CMD[command]
        if f ~= nil then
            f(address,msg)
        end
    end)
end)
