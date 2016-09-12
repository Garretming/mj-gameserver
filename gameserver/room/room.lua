
local skynet = require "skynet"

local CMD = {}
local players = {}
local game = nil

function CMD.enter( agent )
    players[agent] = agent
    return true
end

function CMD.leave( agent )
    if players[agent] ~= nil then
        players[agent] = nil
    end
end

function CMD.debugInfo( cmd )
    if cmd == "size" then
        return table.nums(players)
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
    
    
end)

