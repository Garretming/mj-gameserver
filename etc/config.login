skynetroot = "./skynet/"
--skynetroot = "./skynet-mingw/"

thread = 8
logpath = "."
logger = "userlog"
logservice = "snlua"
harbor = 0
start = "main"	-- main script
--daemon = "./skynet_login.pid"
bootstrap = "snlua bootstrap"	-- The service for bootstrap


lualoader = skynetroot.."lualib/loader.lua"

cpath = skynetroot.."cservice/?.so"

lua_path = "./gobal/?.lua;"..
           "./lualib/?.lua;"..
           skynetroot.."lualib/?.lua;"..
		   skynetroot.."lualib/?/init.lua;"


		   
lua_cpath = "./luaclib/?.so;"..
            skynetroot.."luaclib/?.so;"
			
   
luaservice = "service/?.lua;"..
             skynetroot.."service/?.lua;"..
			 skynetroot.."../loginserver/?.lua;"


preload = "./gobal/preload.lua"

cluster = "./etc/clustername.lua"
server_port = 7777
debug_port = 7000
nodename = "login"

httpserver_port = 7800


mysql_host = '139.129.33.151'
mysql_port = 3306
mysql_database = 'game'
mysql_username = 'root'
mysql_password = 'ciwo#i88kn_41.sd77*'
