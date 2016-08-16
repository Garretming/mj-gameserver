
local dispatcher = require "agentDispatcher"
local skynet = require "skynet"

clsDDZ = class('ddz')


function clsDDZ:registerHandler( ... )
    dispatcher.register("ddz.c2s_ready",function ( )
    
    end)

end

function clsDDZ:unregisterHandler( ... )

end

function clsDDZ:ctor( ... )

end

function clsDDZ:dtor( ... )
    -- body
end

function clsDDZ:ready( ... )

end

function clsDDZ:play( ... )

end




clsDDZ = class('ddz')

function clsDDZ:ctor( ... )

end

function clsDDZ:ready( ... )

end

function clsDDZ:play( ... )

end


