
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

#第一次发牌(3张)
game_NN_card1 1000 {
    request {
        card 0 : integer
    }
}

#第二次发牌(剩余的2张)
game_NN_card2 1001 {
    request {
        card 0 : integer
    }
}

#确认谁是庄家
game_NN_banker 1002 {
    request {
        banker 0 : integer
        candidate 1 : *integer
    }
}



]]



return proto_s2c