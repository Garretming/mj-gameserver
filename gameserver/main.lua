local skynet = require "skynet"
local cluster = require "cluster"

skynet.start(function()
    local debug_port = skynet.getenv("debug_port")
    if debug_port ~= nil then
        skynet.newservice("debug_console",debug_port)
    end

    cluster.open(skynet.getenv("nodename"))

    local gamed = skynet.newservice("gamed")

    skynet.uniqueservice("roomMgr")
    local watchdog = skynet.newservice("watchdog")
    skynet.call(watchdog, "lua", "start", {
        port = skynet.getenv("server_port"),
        maxclient = 10240,
        nodelay = true,
        gamed = gamed
    })
    
    skynet.logInfo("Watchdog listen on ", skynet.getenv("server_port"))

end)
