--skynetroot = "./skynet/"
skynetroot = "./skynet-mingw/"

thread = 8
logpath = "."
harbor = 0
start = "main"	-- main script
--daemon = "./skynet.pid"
bootstrap = "snlua bootstrap"	-- The service for bootstrap


lualoader = skynetroot.."lualib/loader.lua"

cpath = skynetroot.."cservice/?.so"

lua_path = skynetroot.."lualib/?.lua;"..
		   skynetroot.."lualib/?/init.lua;"..
		   "./lualib/?.lua;"

		   
lua_cpath = skynetroot.."luaclib/?.so;"..
			"./luaclib/?.so;"

		   
luaservice = skynetroot.."service/?.lua;"..
			 skynetroot.."../loginserver/?.lua;"


server_port = 7777
debug_port = 7000