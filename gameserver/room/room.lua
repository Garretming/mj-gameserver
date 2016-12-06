
local skynet = require "skynet"

local CMD = {}
local players = {}
local game = nil
local size = 0
local config =  nil
local id = nil

function CMD.join( agent )
    if configs.size == size then
        return false
    else
        players[agent] = agent
        size = size + 1
        assert(config.size >= size)
        return true
    end
    return true
end

function CMD.leave( agent )
    if players[agent] ~= nil then
        players[agent] = nil
        size = size - 1
        assert(size >= 0)
    end
end

function CMD.getID()
    return id

end
function CMD.destory()
    for k,v in pairs(players) do
        skynet.call(v,"lua","leaveRoom")
    end
    players  = {}
    size = 0;

    skynet.exit()
end


function CMD.init(agent,mroomid,type,config)
    if game ~= nil or id ~= nil then
        return false
    end
    print("room:init",roomid,type,config)

    if type == 'qzmj' then
        players[agent] = agent
        size = size + 1

        id = roomid
        config = config
        require "mj.qzmj"
        game = clsQZMJ.new()
        local ret = game:init(config) 
        print("game==>",game,ret)
        return ret
    end

    return false
end

function CMD.startGame()
    if game ~= nil then
        game:start()
        return true
    else
        return false
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
    
    
end)

