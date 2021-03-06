local login = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"
local cluster = require "cluster"
local md5 = require "md5"
local mysql = require "mysql"
local sqlStr = require "sqlStr"

local server = {
    host = "0.0.0.0",
    port = skynet.getenv("server_port"),
    multilogin = false, -- disallow multilogin
    name = "login_master",
}

local server_list = {}
local user_online = {}
local user_login = {}

function server.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)
	local openid, server, _token = token:match("([^@]+)@([^:]+):(.+)")
	openid = crypt.base64decode(openid)
	server = crypt.base64decode(server)
	_token = crypt.base64decode(_token)

	print("login request")
	print("server==>",server)
	print("openid==>",openid)
	print("token==>",_token)
	--TODO
	--check token
	return server,openid
end

function server.login_handler(server, uid, secret)
	print(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	local gameserver = assert(server_list[server], "Unknown server")
	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	if last then
		cluster.call(last.server,last.address,"kick",uid,last.subid)
	end
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end

	local subid = tostring(cluster.call(server,gameserver, "login", uid, secret))
	user_online[uid] = { address = gameserver, subid = subid , server = server}
	return subid
end

local CMD = {}

function CMD.register_gate(server, address)
	server_list[server] = address
end

function CMD.logout(uid)
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s is logout", uid, u.server))
		user_online[uid] = nil
	end
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(server)
