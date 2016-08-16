
local dispatcher = require "agentDispatcher"
local skynet = require "skynet"

dispatcher.register("c2s_enterRoomRequest",
    function ( msg ,core)
        if core.room ~= nil then
            return false
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

dispatcher.register("c2s_leaveRoomRequest",
    function ( msg ,core)
        local room = core.room
        if room then
            local ret = skynet.call(room,'lua','leave',skynet.self())
            core.room = nil
        end
        return true

local dispatcher = require "agentDispatcher"
local skynet = require "skynet"

dispatcher.register("c2s_enterRoomRequest",
    function ( msg ,core)
        if core.room ~= nil then
            return false
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

dispatcher.register("c2s_leaveRoomRequest",
    function ( msg ,core)
        local room = core.room
        if room then
            local ret = skynet.call(room,'lua','leave',skynet.self())
            core.room = nil
        end
        return true

    end)