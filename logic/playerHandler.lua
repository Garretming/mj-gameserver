local handlerT = {}
handlerT["heartbeat"] = function ( msg,core )
    local heartbeat = {};
    heartbeat.timestamp = 0
    core:send("heartbeat", heartbeat)
end

handlerT["ddz.play"] = function ( msg,core )
    
end


return handlerT