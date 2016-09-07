local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local proto_c2s = require "proto.c2s"
local proto_s2c = require "proto.s2c"

skynet.start(function()
    sprotoloader.save(sprotoparser.parse(proto_c2s), 1)
    sprotoloader.save(sprotoparser.parse(proto_s2c), 2)
    -- don't call skynet.exit() , because sproto.core may unload and the global slot become invalid
end)
