
local dispatcher = {}
local handlerT = {}

function dispatcher.register(name,func)
    if handlerT[name] ~= nil then
        print("dispatcher:register error ,has registered",name)
    end
    handlerT[name] = func
end

function dispatcher.unregister( name )
    handlerT[name] = nil
end

function dispatcher.process( name,msg,player )
    local _,_,package = string.find(name,"(.+)%.")

    if not handlerT[name] then
        print("cann't find handler",name)
        return false
    else
        return handlerT[name](msg,player)
    end

end

dispatcher.register("heartbeat",
    function ( msg ,player)
        player:setAlive()
        return true;
    end)



return dispatcher