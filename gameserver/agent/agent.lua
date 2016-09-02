local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local pbc = require "protobuf"
local dispatcher = require "agentDispatcher"

local mysql = require "mysql"
local sqlStr = require "sqlStr"

require "player"

local CMD = {}
local client_fd
--other service
local WATCHDOG
local DB
local player

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
        local ret = dispatcher.process(name,msg,player)
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

    local res = skynet.call(DB,"lua","query","Query_User_Info",user)
    if not res then
        return false
    end
    userinfo = res[1]
    player = clsPlayer.new(userinfo,client_fd)

    skynet.call(gate, "lua", "forward", fd)
    
    skynet.fork(function ( ... )
        player:checklive()
    end)
    return true

end
function CMD.send(name,t )
    player:send(name,t)
end

function CMD.disconnect()
    skynet.exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)

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
