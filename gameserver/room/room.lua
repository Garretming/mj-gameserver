local skynet = require "skynet"

local CMD = {}
local players = {}

function CMD.enter( id )

end

function CMD.leave( id )

end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    
end)
