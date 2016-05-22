--agent池管理 利用空闲时间生成 agent

local skynet = require "skynet"
local CMD = {}
local AGENT_IDLE_COUNT = 1
local agent_pool = {}
function CMD.fetch()
    if #agent_pool == 0 then
        return skynet.newservice("agent")
    end
    return table.remove(agent_pool)
end

function mainloop()
    while(true) do
        while #agent_pool < AGENT_IDLE_COUNT do
            local agent = skynet.newservice("agent")
            agent_pool[#agent_pool + 1] = agent
            skynet.sleep(0)
        end
        skynet.sleep(5)
    end
end
skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    skynet.fork(mainloop)
end)
