skynetroot = "./skynet/"
--skynetroot = "./skynet-mingw/"

thread = 8
logpath = "."
harbor = 0
start = "main"	-- main script
daemon = "./skynet_login.pid"
bootstrap = "snlua bootstrap"	-- The service for bootstrap


lualoader = skynetroot.."lualib/loader.lua"

cpath = skynetroot.."cservice/?.so"

lua_path = skynetroot.."lualib/?.lua;"..
		   skynetroot.."lualib/?/init.lua;"..
           "./gobal/?.lua;"..
		   "./lualib/?.lua;"

		   
lua_cpath = skynetroot.."luaclib/?.so;"..
			"./luaclib/?.so;"

		   
luaservice = skynetroot.."service/?.lua;"..
			 skynetroot.."../loginserver/?.lua;"


preload = "./gobal/preload.lua"

cluster = "./etc/clustername.lua"
server_port = 7777
debug_port = 7000
nodename = "login"

httpserver_port = 7800


mysql_host = '127.0.0.1'
mysql_port = 3306
mysql_database = 'game'
mysql_username = 'ciwo#i88kn_41.sd77*'
mysql_password = '123'
