
local skynet = require "skynet"
local queue = require "skynet.queue"
local rooms = {}
local CMD = {}

local BEGIN_ID = 100000
local MAX_ID   = 999999
local MAX_RETRY = 10000

local roomID = BEGIN_ID
local cs 

function CMD.create(type,configs)
  print("CMD.create",type,configs)
  local room = skynet.newservice("room")
  cs(function()
        local retryCount = 0
        while rooms[roomID] ~= nil and retryCount < MAX_RETRY do
          roomID = roomID + 1
          if roomID > MAX_ID then
            roomID = BEGIN_ID
          end
          retryCount = retryCount + 1
        end
        if retryCount >= MAX_RETRY then
           return nil
        else
           rooms[roomID] = room
           return room
        end
     end)
end



function CMD.fetch( type,id )
    if rooms[id] == nil then
        rooms[id] = skynet.newservice("room")
    end
    return rooms[id]
end


skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    cs = queue()
end)

