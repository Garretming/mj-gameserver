function tonum(v, base)
    return tonumber(v, base) or 0
end

function toint(v)
    return math.floor(tonum(v),1)
end

function tobool(v)
    return (v ~= nil and v ~= false)
end

function totable(v)
    if type(v) ~= "table" then v = {} end
    return vs
end

function isset(arr, key)
    local t = pritntype(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end

function isInTable(t,v)
    if type(t) ~= "table" then
        return false
    else
        for _,value in pairs(t) do
            if  v == value then 
                return true
            end
        end
        return false
    end
end


local setmetatableindex_
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then mt = {} end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
setmetatableindex = setmetatableindex_

function class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname));
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname));
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() end
    end
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end

    return cls
end

function clone(object,ignoreMetatable)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        if ignoreMetatable == true then
            return new_table
        else
            return setmetatable(new_table, getmetatable(object))
        end

    end
    return _copy(object)
end

function clamp(min,max,v )
    if v > max then
        return max
    elseif v < min then
        return min
    else
        return v
    end
end


function int2Mysqldatetime(time)
    return os.date("%Y-%m-%d %H:%M:%S",time);
end

function mysqldatetime2Int(time)
    if time == nil then
        return nil
    end

    local t = {}
    t.year,t.month,t.day,t.hour,t.min,t.sec = string.match(time
        ,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")

    return os.time(t)
end
local skynet = require "skynet"
function skynet.logInfo( ... )
	local t = {...}
	for i=1,#t do
		t[i] = tostring(t[i])
	end
	skynet.send(".logger","lua","info",table.concat(t," "))
end
function skynet.logWarning( ... )
	local t = {...}
	for i=1,#t do
		t[i] = tostring(t[i])
	end
	skynet.send(".logger","lua","warning",table.concat(t," "))
end
function skynet.logError( ... )
	local t = {...}
	for i=1,#t do
		t[i] = tostring(t[i])
	end
	skynet.send(".logger","lua","error",table.concat(t," "))
end