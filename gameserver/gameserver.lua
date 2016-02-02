local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local cluster = require "cluster"

local CMD = {}
local user_online = {}
local handshake = {}
local connection = {}

local logind = nil

function CMD.login(uid,secret)
    user_online[uid] = true
    handshake[uid] = true
    print("CMD.login")
end

function CMD.kick(uid,subid)
    print("CMD.kick")
    user_online[uid] = false
    handshake[uid] = false
    connection[uid] = false
    
    cluster.call("login",logind,"logout",uid,subid)
end

function CMD.auth(uid,secret)
    
end


skynet.start(function ( ... )
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    logind = cluster.query("login","logind")
    cluster.call("login",logind,"register_gate","game",skynet.self())

end)