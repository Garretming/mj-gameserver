
local dispatcher = require "playerDispatcher"
local skynet = require "skynet"

dispatcher.register("REQUEST","enterRoom",
    function ( player,msg)
        if core.room ~= nil then
            return true,{error = "you are already in room"}
        end
        local roomMgr = skynet.uniqueservice("roomMgr")
        local room = skynet.call(roomMgr,'lua','fetch',msg.type,msg.id)
        if room then
            local ret = skynet.call(room,'lua','enter',skynet.self())
            if ret == true then
                core.room = room
            end
        end
        
        return true
    end)

dispatcher.register("REQUEST",leaveRoom,
    function ( player,msg)
        local room = core.room
        if room then
            local ret = skynet.call(room,'lua','leave',skynet.self())
            core.room = nil
        else
            return true,{error = "you are not in room"}
        end
        return true

    end)

