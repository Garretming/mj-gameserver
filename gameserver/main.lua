local skynet = require "skynet"

skynet.start(function()
    local debug_port = skynet.getenv("debug_port")
    if debug_port ~= nil then
        skynet.newservice("debug_console",debug_port)
    end

    local watchdog = skynet.newservice("watchdog")
    skynet.call(watchdog, "lua", "start", {
        port = skynet.getenv("server_port"),
        maxclient = max_client,
        nodelay = true,
    })
    
    skynet.logInfo("Watchdog listen on ", skynet.getenv("server_port"))

end)
