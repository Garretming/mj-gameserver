local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local pbc = require "protobuf"
local dispatcher = require "agentDispatcher"

local mysql = require "mysql"
local sqlStr = require "sqlStr"



local CMD = {}
local client_fd
--other service
local WATCHDOG
local DB
local player
local userinfo
local dbDirty = false
local clientDirty = false

local core = {}
local netActive = 0
local lastHeartbeat = 0

local sendByte = 0
function core:send( name,t )
    local msg = pbc.encode(name,t)  
    local buf = string.pack(">I2",#name)..name..string.char(0)..string.pack(">I2",#msg)..msg
    local package = string.pack(">s2", buf)
    local ret = socket.write(client_fd, package)
    sendByte = sendByte + #package
end
function core:heartbeat( ... )
    netActive = os.time()
end


function mainloop()
    while(true) do
        if dbDirty then
            --save to db
            dbDirty = false
        end
        if clientDirty then
            --asyn to client
            clientDirty = false
        end
        skynet.sleep(5)
    end
end


skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function (msg, sz)
        msg = skynet.tostring(msg,sz)
        local name_size = string.unpack(">I2",msg)
        local name = string.sub(msg,3,name_size + 2)
        local isCompress = string.sub(msg,name_size+3,1)
        local msg_size = string.unpack(">I2",msg,name_size + 4)
        local msg = string.sub(msg,name_size+6) 
        return name,msg
    end,
    dispatch = function (_, _, name,msg)
        local msg = pbc.decode(name,msg)
        local ret = dispatcher.process(name,msg,core)
        if not ret then
            print("error in agentDispatcher",name)
            skynet.exit()
        end
    end
}


function CMD.start(conf)
    local fd = conf.client
    client_fd = fd
    
    local gate = conf.gate
    WATCHDOG = conf.watchdog
    user = conf.user
    DB = skynet.uniqueservice("db")

    local sql = string.format(sqlStr["Query_User_Info"],user)
    local res = skynet.call(DB,"lua","query",sql)
    if not res then
        return false
    end
    userinfo = res[1]
    dump(userinfo)
    skynet.call(gate, "lua", "forward", fd)
    netActive = os.time()

    return true

end
function CMD.send(name,t )
    core:send(name,t)
end

function CMD.disconnect()
    skynet.exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)


    skynet.fork(mainloop)


    --register proto
    local pbTable = {
        "proto/heartbeat.proto.pb",
        "proto/ddz.proto.pb",
        "proto/room.proto.pb"
    }
    for _,v in ipairs(pbTable) do
        pbc.register_file(v)
    end
    
    --register handler
    require("roomHandler")
    require("ddz.handler")


end)
