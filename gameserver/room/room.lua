
local skynet = require "skynet"
require("ddz.ddz")

local CMD = {}
local players = {}
local game = nil

function CMD.enter( agent )
    players[agent] = agent
    skynet.call(agent,"lua","send","s2c_enterRoomResponse",{})
    return true
end

function CMD.leave( agent )
    if players[agent] ~= nil then
        skynet.call(agent,"lua","send","s2c_leaveRoomResponse",{})
        players[agent] = nil
    end
end

function CMD.debugInfo( cmd )
    if cmd == "size" then
        return table.nums(players)
    end
end

function CMD.recv(agent,msg )
    
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
    
    game = clsDDZ.new()        
end)

local skynet = require "skynet"
require("ddz.ddz")

local CMD = {}
local players = {}
local game = nil

function CMD.enter( agent )
    players[agent] = agent
    skynet.call(agent,"lua","send","s2c_enterRoomResponse",{})
    return true
end

function CMD.leave( agent )
    if players[agent] ~= nil then
        skynet.call(agent,"lua","send","s2c_leaveRoomResponse",{})
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
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    
    game = clsDDZ.new()        
end)
