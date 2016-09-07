
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


]]



return proto_s2c