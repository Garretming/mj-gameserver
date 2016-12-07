local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local cluster = require "cluster"
local crypt = require "crypt"
local b64encode = crypt.base64encode
local b64decode = crypt.base64decode

local CMD = {}
local user_online = {}
local handshake = {}
local internal_id = 0

local logind = nil
local watchdog = nil


function CMD.login(uid,secret)
    print("CMD.login")
    user_online[uid] = true
    handshake[uid] = secret
    internal_id = internal_id + 1
    return internal_id
end

function CMD.kick(uid,subid)
    print("CMD.kick",user_online[uid],type(user_online[uid]))
    if type(user_online[uid]) == "number" then
        skynet.call(watchdog,"lua","close",user_online[uid])
        print("close_agent",user_online[uid])
    end
    user_online[uid] = false
    handshake[uid] = false

    cluster.call("login",logind,"logout",uid,subid)
end
function CMD.auth(msg)
    local ret = "200"
    local user,index,hmac = string.match(msg,"([^:]*):([^:]*):([^:]*)")
    local uid, servername, subid = user:match "([^@]*)@([^#]*)#(.*)"
    print("hamc===>",hmac)
    print("uid===>",uid)

    hmac = b64decode(hmac)
    uid = b64decode(uid)

    local secret = handshake[uid]
    local text = string.format("%s:%s", user, index)
    local v = crypt.hmac_hash(secret, text) 

    if v ~= hmac then
        ret =  "401 Unauthorized"
    end

    return ret,uid
end

function CMD.start(_watchdog)
    watchdog = _watchdog
end

function CMD.open( uid,fd )
    user_online[uid] = fd
end

skynet.start(function ( ... )
    skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(subcmd, ...)))
    end)

    --注册游戏服务器
    logind = cluster.query("login","logind")
    local nodename = skynet.getenv("nodename")

    cluster.call("login",logind,"register_gate",nodename,skynet.self())


end)