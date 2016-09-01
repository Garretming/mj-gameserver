local skynet = require "skynet"
require "skynet.manager"

local logfile = nil
function __log(prefix,address,service_desc,msg )
    msg = string.format("[%s](%s-%x-%.2f): %s"
        , os.date(),service_desc,address, skynet.time(), msg)
    msg = prefix .. msg
    print(msg)
    if logfile ~= nil then
        logfile:write(msg)
        logfile:write("\n")
        logfile:flush()
    end
end
local CMD = {}
function CMD.info(address,service_desc, msg )
    __log("[Info]",address,service_desc,msg)
end
function CMD.error(address,service_desc, msg )
    __log("[Error]",address,service_desc,msg)
end
function CMD.warning(address,service_desc, msg )
    __log("[Warning]",address,service_desc,msg)
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
        local service_desc = skynet.call(".launcher","lua","SERVICE_NAME",address)
        __log("[Info]",address,service_desc,msg)
    end
}

skynet.start(function()
    skynet.register ".logger"
    local filename = os.date("%Y-%m-%d-%H:%M.log",os.time())
    if skynet.getenv("nodename") ~= nil then
        filename = "["..skynet.getenv("nodename").."]"..filename
    end
    os.execute("mkdir log")
    logfile = io.open("log/"..filename,"w+") 
    if logfile == nil then
       print("can not open log file",filename)
    end
    skynet.dispatch("lua", function(session, address,command,service_desc, msg)
        local f = CMD[command]
        if f ~= nil then
            f(address,service_desc,msg)
        end
    end)
end)
