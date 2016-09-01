local pbc = require "protobuf"
local socket = require "socket"

clsPlayer = class('player')

function clsPlayer:ctor(dbinfo,client_fd)
    dump(dbinfo)
    self.client_fd = client_fd
end

function clsPlayer:send( name,t )
    local msg = pbc.encode(name,t)  
    local buf = string.pack(">I2",#name)..name..string.char(0)..string.pack(">I2",#msg)..msg
    local package = string.pack(">s2", buf)
    local ret = socket.write(self.client_fd, package)

    return ret
end

function clsPlayer:heartbeat( ... )
    -- body
end

