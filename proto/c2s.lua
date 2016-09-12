
local proto_c2s = [[
.package {
    type 0 : integer
    session 1 : integer
}

heartbeat 1 {}


enterRoom 2 {
    request {
        type 0 : string
        id 1 : integer
    }
    response {
        error 0 : string
    }
}


leaveRoom 3 {
    request {

    }
    response {
        error 0 : string
    }
}

#确认是否抢庄
game_NN_banker 1000 {
    request {
        check 0 : boolean
    }
    response {
        error 0 : string
    }
}



]]



return proto_c2s