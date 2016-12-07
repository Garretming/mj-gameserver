
local dispatcher = require "playerDispatcher"
local skynet = require "skynet"

dispatcher.register("createRoom",
    function (player,msg)
        local errorCode = 0
        if player.room ~= nil then
            return true,{errorCode = 10000}
        end
        local roomMgr = skynet.uniqueservice("roomMgr")
        local room = skynet.call(roomMgr,'lua','create',skynet.self(),msg.type,msg.configs)   
        if room == nil then
            return true,{errorCode = 10001}
        else
            player.room = room
            return true,{errorCode = 0}
        end     
    end)

dispatcher.register("joinRoom",
    function ( player,msg)
        if player.room ~= nil then
            return true,{errorCode = 10000}
        end
        local roomMgr = skynet.uniqueservice("roomMgr")
        local room = skynet.call(roomMgr,'lua','get',msg.roomid)
        if room then
            local ret = skynet.call(room,'lua','join',skynet.self())
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


dispatcher.register("leaveRoom",
    function (player,msg)
        if player.room == nil then
            return true,{errorCode = 10006}
        end
        local room = player.room
        skynet.call(room,'lua','leave',skynet.self())
        player.room = nil
        return true,{errorCode = 0}
    end)

dispatcher.register("delRoom",
    function (player,msg)
        if player.room == nil then
            return true,{errorCode = 10006}
        end
        local id = skynet.call(player.room,"lua","getID")
        local roomMgr = skynet.uniqueservice("roomMgr")
        skynet.call(roomMgr,'lua','del',id)

        assert(player.room == nil)


        return true,{errorCode = 0}
    end)