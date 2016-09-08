local dispatcher = {}
local handlerT = {}
function dispatcher.register(type,name, func)
    handlerT[type] = handlerT[type] or {}

    if handlerT[type][name] ~= nil then
        print("dispatcher:register error ,has registered", name)
    end
    handlerT[type][name] = func
end

function dispatcher.process(player,type,name, msg,response)
    handlerT[type] = handlerT[type] or {}

    if not handlerT[type][name] then
        print("cann't find handler",type,name)
        return false;
    else
        return handlerT[type][name](player,msg,response)
    end
end


dispatcher.register("REQUEST","heartbeat",
    function (player)
        player:setAlive()
        return true;
    end)



return dispatcher