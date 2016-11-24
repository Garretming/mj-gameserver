
local dispatcher = require "playerDispatcher"
local skynet = require "skynet"

dispatcher.register("REQUEST","createRoom",
    function (player,msg)
        local errorCode = 0
        if player.room ~= nil then
            return true,{errorCode = 10000}
        end
        local roomMgr = skynet.uniqueservice("roomMgr")
        local room = skynet.call(roomMgr,'lua','create',msg.type,msg.configs)   
        if room == nil then
            return true,{errorCode = 10001}
        else
            local ret = skynet.call(room,'lua','enter',skynet.self())
            if ret == true then
                player.room = room
            else
                return true,{errorCode = 10002}
            end
            return true,{errorCode = 0}
        end     
    end)

dispatcher.register("REQUEST","joinRoom",
    function ( player,msg)
        if player.room ~= nil then
            return true,{errorCode = 10003}
        end
        local roomMgr = skynet.uniqueservice("roomMgr")
        local room = skynet.call(roomMgr,'lua','fetch',msg.id)
        if room then
            local ret = skynet.call(room,'lua','enter',skynet.self())
            if ret == true then
                player.room = room
            else
                return true,{errorCode = 10004}
            end
        else
            return true,{errorCode = 10005}
        end
        
        return true,{errorCode = 0}
    end)


