
local skynet = require "skynet"
local queue = require "skynet.queue"
local rooms = {}
local CMD = {}
local roomID = 100000
local cs 
function CMD.fetch(id )
    return return rooms[id]
end

function CMD.create(type,configs)
    local room = skynet.newservice("room")
    cs(function()
      local retryCount = 0
      while rooms[roomID] ~= nil and retryCount < 10000 then
        roomID = roomID + 1
        if roomID > 999999 then
          roomID = 100000
        end
        retryCount = retryCount + 1
      end
      if retryCount >= 10000 then
         return nil
      else
         rooms[roomID] = room
         return room
      end
    )
end


skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
    cs = queue()
end)

local skynet = require "skynet"
local rooms = {}
local CMD = {}


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
    
end)

