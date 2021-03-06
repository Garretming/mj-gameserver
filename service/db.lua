local skynet = require "skynet"
local mysql = require "mysql"
local sqlStr = require "sqlStr"

local db = nil
local CMD = {}

function CMD.query(key,...)
    local param = {...}
    sql = sqlStr[key]
    if not db or not sql then
        return nil
    end
    for k,v in pairs(param) do
        param[k] = mysql.quote_sql_str(v)
    end
    sql = string.format(sql,table.unpack(param))
    local res = db:query(sql)
    if not res then
        return nil
    end
    if res.badresult then
        skynet.logError(sql,"sql query error",res.err)
        return nil
    end
    return res
end


skynet.start(function()
    skynet.dispatch("lua", function (_,_,command,...)
        local f = assert(CMD[command])
        if f ~= nil then
            skynet.ret(skynet.pack(f(...)))
        end
    end)
    local host = skynet.getenv("mysql_host")
    local port = skynet.getenv("mysql_port")
    local database = skynet.getenv("mysql_database")
    local username = skynet.getenv("mysql_username")
    local pasword = skynet.getenv("mysql_password")

    db=mysql.connect({
        host=host,
        port=port,
        database=database,
        user=username,
        password=pasword,
        max_packet_size = 1024 * 1024,
        on_connect = on_connect
    })
    if not db then
        print("failed to connect db",host,port,database)
    end
end)


