
local proto_c2s = [[
.package {
    type 0 : integer
    session 1 : integer
}

kick 100 {
    
}
heartbeat 1 {}

.config {
    type 0 : string
    value 1 : integer
}

createRoom 2 {
    request {
        type 0 : string
        configs 1 : *config   
    }
    response {
        errorCode 0 : integer
    }
}

joinRoom 3 {
    request {
        roomid 0 : integer
    }
    response {
        errorCode 0 : integer
    }
}

delRoom 4 {
    request {

    }   
    response {
        errorCode 0 : integer
    }
}

leaveRoom 5 {
    request {

    }
    response {
        errorCode 0 : integer
    }
}

discard 6 {
    request {
        index 0 : integer
    }
    response {
        errorCode 1 : integer
    }
}

peng 7 {
    request {

    }
}

chi 8 {
    
}

hu 9 {
    
}



]]



return proto_c2s