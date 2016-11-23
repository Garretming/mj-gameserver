
local proto_c2s = [[
.package {
    type 0 : integer
    session 1 : integer
}

heartbeat 1 {}

.config {
    type 0 : string
    value 1 : integer
}

createRoom 2 {
    request {
        majorType 0 : string
        configs 1 : *config   
    }
}

joinRoom 3 {
    request {
        roomid 0 : string
    }
}

delRoom 4 {
    request {

    }   
}
]]



return proto_c2s