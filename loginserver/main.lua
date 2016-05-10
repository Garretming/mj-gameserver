local skynet = require "skynet"
local cluster = require "cluster"

skynet.start(function()
    local debug_port = skynet.getenv("debug_port")
    if debug_port ~= nil then
        skynet.newservice("debug_console",debug_port)
    end

    local logind = skynet.newservice("logind")
    cluster.register("logind", logind)

    cluster.open(skynet.getenv("nodename"))
end)
