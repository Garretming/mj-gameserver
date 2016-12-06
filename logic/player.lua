local socket = require "socket"
local skynet = require "skynet"
local dispatcher = require "playerDispatcher"
require "playerHandler"
local ALIVE_SECOND = 10

clsPlayer = class('clsplayer')

function clsPlayer:ctor(dbinfo,client_fd,sp_request)
    assert(self.dbinfo == nil)
    self.client_fd = client_fd
    self.dbinfo = dbinfo
    self.sp_request = sp_request
    self.session = 0
    self.session2map = {}
    -- async to client
    local msg = {}
    msg = {
        nickname = dbinfo.nickname,
        gold = dbinfo.gold,
        gem = dbinfo.gem,
        room = dbinfo.room,
        mobilephone = dbinfo.mobilephone
    }
    self:sendRequest("loginFinish",msg)

end

function clsPlayer:checklive()
    self.alive = os.time()
    while true do
        skynet.sleep(500)
        if not self:isAlive() then
            self:logout()
            return 
        end
        self:sendRequest("heartbeat")
    end
end

function clsPlayer:setAlive()
    self.alive = os.time()
end

function clsPlayer:isAlive()
    return os.time() - self.alive < ALIVE_SECOND
end

function clsPlayer:getID( ... )
    return self.dbinfo.id
end


function clsPlayer:sendRequest( name,t )
    self.session = self.session + 1
    self.session2map[self.session] = name

    local buf = self.sp_request(name,t,self.session)
    local package = string.pack(">s2", buf)
    local ret = socket.write(self.client_fd, package)

    return ret,self.session
end


function clsPlayer:logout()
    skynet.exit()
end

function clsPlayer:dispatchMsg(type,...)
    if type == "REQUEST" then
        local name,msg,response = ...
        local ok,ret  = dispatcher.process(self,type,name,msg)
        if ok and response and ret then
            local package = string.pack(">s2", response(ret))
            dump(ret)
            print("response",ret,#package)
            socket.write(self.client_fd, package)
        end
        return ok
    else
        assert(type == "RESPONSE")
        local seesion,t = ...
        return dispatcher.process(self,type,self.session2map[seesion],t)
    end
end
