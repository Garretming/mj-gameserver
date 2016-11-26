
local skynet = require "skynet"

local CMD = {}
local players = {}
local game = nil
local size = 0
local configs =  nil


function CMD.join( agent )
    players[agent] = agent
    size = size + 1
    if configs.size == size then
        
    end
    return true
end

function CMD.leave( agent )
    if players[agent] ~= nil then
        players[agent] = nil
    end
end


function CMD.init( roomid,type,configs)
    configs = configs
    return true
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
    
    
end)

