local dispatcher = {}
local handlerT = {}

function dispatcher.register(name,func)
    if handlerT[name] ~= nil then
        print("dispatcher:register error ,has registered",name)
    end
    handlerT[name] = func
end

function dispatcher.process( name,msg,core )
    if not handlerT[name] then
        print("cann't find handler",name)
        return false
    else
        return handlerT[name](msg,core)
    end

end

dispatcher.register("heartbeat",
    function ( msg ,core)
        local heartbeat = {};
        heartbeat.timestamp = 0
        core:send("heartbeat", heartbeat)
        return true;
    end)


return dispatcher