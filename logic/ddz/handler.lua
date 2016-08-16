local dispatcher = require "agentDispatcher"
local skynet = require "skynet"

local forwardToRoom = function (msg,core)
    
end
dispatcher.register("ddz.c2s_ready",forwardToRoom)
dispatcher.register("ddz.c2s_landlordRequest",forwardToRoom)
dispatcher.register("ddz.c2s_play",forwardToRoom)
