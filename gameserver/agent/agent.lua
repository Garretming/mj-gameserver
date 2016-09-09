local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"

local sprotoloader = require "sprotoloader"

require "player"
local sp_host
local sp_request

local CMD = {}
local client_fd
local WATCHDOG
local DB
local player

skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function (msg, sz)
        return sp_host:dispatch(msg, sz)
    end,
    dispatch = function (_, _, type,...)
        local ret = player:dispatchMsg(type,...)
        if not ret then
            print("error in dispatchMsg",type,...)
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
    player = clsPlayer.new(userinfo,client_fd,sp_request)

    skynet.call(gate, "lua", "forward", fd)
    
    skynet.fork(function ( ... )
        player:checklive()
    end)
    return true

end
function CMD.sendRequest(name,t )
    return player:sendRequest(name,t)
end

function CMD.disconnect()
    skynet.exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
    sp_host = sprotoloader.load(1):host "package"
    sp_request = sp_host:attach(sprotoloader.load(2))
    
end)
