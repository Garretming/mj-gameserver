
local proto_s2c =  [[
.package {
    type 0 : integer
    session 1 : integer
}

heartbeat 1 {}

loginFinish 2 {
    request {
        nickname 0 : string
        gold 1 : integer
        gem 2 : integer
        mobilephone 3 : string
    }
}

.Player {
    name 1 : string
    id 2 : integer
    posiont 3 : integer
}

roomInfo 3 {
    request {
        players 0 : *Player
    }
}

playerJoinRoom 4 {
    request {
        id 0 : integer
    }
}

playerLeaveRoom 5 {
    request {
        id 0 : integer
    }
}





]]



return proto_s2c