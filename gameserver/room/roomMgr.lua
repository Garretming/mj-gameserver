local skynet = require "skynet"
local rooms = {}
local CMD = {}


function CMD.fetch( type,id )
    if rooms[id] == nil then
        rooms[id] = skynet.newservice("room")
    end
    return rooms[id]
end


skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    
end)
