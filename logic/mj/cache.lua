local cache = {}

local function unpackInt(a)
    assert(#a == 4, #a)
    return string.unpack('>i4',a)
end

local f = io.open("etc/cache","rb")
local data = f:read("*a")
f:close()
local len = #data

for i=1,len,5 do  
    local index = string.sub(data,i,i+3)
    local value = string.sub(data,i+4,i+4)
    cache[unpackInt(index)] = value
end

return cache