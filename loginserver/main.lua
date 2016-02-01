local skynet = require "skynet"
skynet.start(function()
    local debug_port = skynet.getenv("debug_port")
    if debug_port ~= nil then
        skynet.newservice("debug_console",debug_port)
    end

    local loginserver = skynet.newservice("logind")
    local gate = skynet.newservice("gated", loginserver)

    skynet.call(gate, "lua", "open" , {
        port = 8888,
        maxclient = 64,
        servername = "sample",
    })

end)
