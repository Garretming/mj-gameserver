win32 : SKYNET_PATH = skynet-mingw
win32 :	SHAREDLDFLAGS = -llua53 -lplatform  -L$(SKYNET_PATH) 
win32 : PLATFORM_INC ?= $(SKYNET_PATH)/platform
win32 : CFLAGS = -g -O2 -Wall -I$(PLATFORM_INC) -I$(LUA_INC) 
win32 : SHARED = --shared

linux : SKYNET_PATH = skynet
linux : CFLAGS = -g -O2 -Wall -I$(LUA_INC) 
linux : SHARED = -fPIC --shared
LUA_CLIB_PATH ?= luaclib
LUA_INC ?= $(SKYNET_PATH)/3rd/lua



win32 : $(SKYNET_PATH)/skynet.exe \
	$(LUA_CLIB_PATH)/protobuf.so
		
linux : $(LUA_CLIB_PATH)/protobuf.so
	cd $(SKYNET_PATH) && $(MAKE) "linux"
		
$(SKYNET_PATH)/skynet.exe :
	cd $(SKYNET_PATH) && $(MAKE)
	
$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)	
	
$(LUA_CLIB_PATH)/protobuf.so : lualib-src/pbc/alloc.c lualib-src/pbc/array.c \
lualib-src/pbc/bootstrap.c lualib-src/pbc/context.c lualib-src/pbc/decode.c \
lualib-src/pbc/map.c lualib-src/pbc/pattern.c lualib-src/pbc/pbc-lua53.c \
lualib-src/pbc/stringpool.c lualib-src/pbc/varint.c lualib-src/pbc/wmessage.c \
lualib-src/pbc/proto.c lualib-src/pbc/register.c lualib-src/pbc/rmessage.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -Ilualib-src/pbc $^ -o $@ $(SHAREDLDFLAGS)

	
clean :
	cd skynet-mingw && $(MAKE) clean
	cd skynet && $(MAKE) clean
	rm -rf $(LUA_CLIB_PATH)
