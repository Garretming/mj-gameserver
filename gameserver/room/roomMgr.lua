
local skynet = require "skynet"
local queue = require "skynet.queue"
local rooms = {}
local CMD = {}

local MIN_ID = 100000
local MAX_ID   = 999999
local MAX_RETRY = 1000

local roomID = math.random(MIN_ID,MAX_ID)
local cs 

function CMD.create(agent,type,configs)
  return cs(function()
        local retryCount = 0
        while rooms[roomID] ~= nil and retryCount < MAX_RETRY do
          roomID = math.random(MIN_ID,MAX_ID)
          retryCount = retryCount + 1
        end
        if retryCount >= MAX_RETRY then
           return nil
        else
           local room = skynet.newservice("room")
           rooms[roomID] = room
           if not skynet.call(room,"lua","init",agent,roomID,type,configs) then
              return nil
           end
           return room
        end
     end)
end

function CMD.get(id )
  return rooms[id]
end


function CMD.del(id)
  cs(function ( ... )
      if rooms[id] ~= nil then
        local room = rooms[id]
        skynet.call(room,"lua","destory")
        rooms[id] = nil
      end
  end)
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        print("roomMgr ===>",command,...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    cs = queue()
end)

