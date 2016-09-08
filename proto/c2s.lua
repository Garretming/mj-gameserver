
local proto_c2s = [[
.package {
    type 0 : integer
    session 1 : integer
}

heartbeat 1 {}


enterRoom 2 {
    request {
        type : string
        id : integer
    }
}

]]



return proto_c2s