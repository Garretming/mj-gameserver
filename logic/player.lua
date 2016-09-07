local socket = require "socket"
local skynet = require "skynet"

clsPlayer = class('player')

function clsPlayer:ctor(dbinfo,client_fd,sp_request)
    dump(dbinfo)
    assert(self.dbinfo == nil)
    self.client_fd = client_fd
    self.dbinfo = dbinfo
    self.session = 0
    self.sp_request = sp_request
    -- async to client
    local msg = {}
    msg = {
        nickname = dbinfo.nickname,
        gold = dbinfo.gold,
        gem = dbinfo.gem,
        mobilephone = dbinfo.mobilephone
    }
    self:send("loginFinish",msg)

end

function clsPlayer:send( name,t )
    local buf = self.sp_request(name,t)
    local package = string.pack(">s2", buf)
    local ret = socket.write(self.client_fd, package)

    return ret
end

function clsPlayer:checklive()
    self.alive = os.time()
    while true do
        skynet.sleep(500)
        if not self:isAlive() then
            self:logout()
            return 
        end
        self:send("heartbeat")
    end
end

function clsPlayer:setAlive()
    self.alive = os.time()
end

function clsPlayer:isAlive( ... )
    return os.time() - self.alive < 10
end

function clsPlayer:logout( ... )
    skynet.exit()
end