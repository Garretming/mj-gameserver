local skynet = require "skynet"
skynet.start(function()
    local debug_port = skynet.getenv("debug_port")
    if debug_port ~= nil then
        skynet.newservice("debug_console",debug_port)
    end
    skynet.uniqueservice("logind")

end)
