local handlerT = {}
handlerT["heartbeat"] = function ( msg,core )
    local heartbeat = {};
    heartbeat.timestamp = 0
    core:send("heartbeat", heartbeat)
end



return handlerT