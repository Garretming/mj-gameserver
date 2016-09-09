
linux : SKYNET_PATH = skynet
linux : CFLAGS = -g -O2 -Wall -I$(LUA_INC) 
linux : SHARED = -fPIC --shared
LUA_CLIB_PATH ?= luaclib
LUA_INC ?= $(SKYNET_PATH)/3rd/lua


linux :
	cd $(SKYNET_PATH) && $(MAKE) "linux"
		
	
$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)	
	

clean :
	cd skynet && $(MAKE) clean
	rm -rf $(LUA_CLIB_PATH)
