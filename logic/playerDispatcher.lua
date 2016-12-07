local dispatcher = {}
local handlerT = {}
function dispatcher.register(name, func)

    if handlerT[name] ~= nil then
        print("dispatcher:register error ,has registered", name)
    end
    handlerT[name] = func
end

function dispatcher.process(player,name, msg)
    if not handlerT[name] then
        print("cann't find handler",name)
        return false;
    else
        return handlerT[name](player,msg)
    end
end


dispatcher.register("heartbeat",
    function (player)
        player:setAlive()
        return true;
    end)



return dispatcher