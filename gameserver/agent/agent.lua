local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local pbc = require "protobuf"

local CMD = {}
local client_fd
--other service
local WATCHDOG
local DB

local core = {}
local netActive = 0
local lastHeartbeat = 0

function core:send( name,t )
    local msg = pbc.encode(name,t)  
    local buf = string.pack(">I4",#name)..name..string.char(0)..string.pack(">I4",#msg)..msg
    local package = string.pack(">s2", buf)

    socket.write(client_fd, package)
end
function core:heartbeat( ... )
    netActive = os.time()
end

function load_proto( ... )
    local pbTable = {
    }
    for _,v in ipairs(pbTable) do
        pbc.register_file(v)
    end
end

skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function (msg, sz)
        msg = skynet.tostring(msg,sz)
        local name_size = string.unpack(">I4",msg)
        local name = string.sub(msg,5,name_size + 4)
        local isCompress = string.sub(msg,name_size+5,1)
        local msg_size = string.unpack(">I4",msg,name_size + 6)
        local msg = string.sub(msg,name_size+10) 
        return name,msg
    end,
    dispatch = function (_, _, name,msg)
        local msg = pbc.decode(name,msg)
        if not handlerT[name] then
            skynet.error("error cannot find message handlerT",name)
        else
            handlerT[name](msg,core)
        end
    end
}

function CMD.start(conf)
    local fd = conf.client
    client_fd = fd
    
    local gate = conf.gate
    WATCHDOG = conf.watchdog

    skynet.call(gate, "lua", "forward", fd)

    netActive = os.time()
    skynet.start(function()
        skynet.fork(_loop)
    end)

end
function CMD.send(name,t )
    core:send(name,t)
end

function CMD.disconnect()
    skynet.exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)

    load_proto()
    
end)
