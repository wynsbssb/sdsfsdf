--// DataToCode Loader（用来序列化数据，可选）
local DataToCode do
    local DataToCode_request, DataToCode_source = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/78n/Roblox/refs/heads/main/Lua/Libraries/DataToCode/DataToCode.luau")
    end)
    assert(DataToCode_request, "An error occured when retrieving the DataToCode source (try saving as a plugin): "..DataToCode_source)

    local CompiledDataToCode = loadstring(DataToCode_source, "DataToCode")
    DataToCode = CompiledDataToCode()
end

--// Dump 输出函数（常量表）
local Location = game:GetService("HttpService"):GenerateGUID(false)
shared[Location] = DataToCode

function DataToCode.output(tbl)
    shared[Location] = nil
    local Serialized = DataToCode.Convert(tbl, true)
    local DisplayScript = Instance.new("LocalScript", game)
    DisplayScript.Name = "Dumped_"..math.floor(os.clock())
    writefile("dump_constants.txt", Serialized)
end

--// Hook 环境
local setfenv, error, loadstring, type, info = setfenv, error, loadstring, type, debug.info
local CClosures = {}

local function newcclosure(func)
    CClosures[func] = "C"
    return func
end

local function islclosure(func)
    return info(func, "l") ~= -1
end

local env = getfenv()

env.setfenv = newcclosure(function(func, ...)
    if type(func) == "function" then
        error("'setfenv' cannot change environment of given object")
    end
    return setfenv(func, ...)
end)

env.debug = (function()
    local newdebug = table.clone(debug)
    newdebug.getinfo = newcclosure(function(func)
        return {
            what = CClosures[func] or islclosure(func) and "Lua" or "C"
        }
    end)
    return newdebug
end)()

--// ⭐ 改进后的 loadstring hook（带时间戳）
env.loadstring = newcclosure(function(code : string, chunkname : string, ...)
    if type(code) == "string" then
        local date = os.date("*t")
        local filename = string.format("dump_%04d-%02d-%02d_%02d-%02d-%02d.txt",
            date.year, date.month, date.day, date.hour, date.min, date.sec)

        writefile(filename, "-- Decompiled by dumper\n\n"..code)
        rconsoleprint("[DUMPER] 已保存到: "..filename.."\n")
    end
    return loadstring(code, chunkname, ...)
end)

--// 在这下面粘贴 MoonSec V3 加密的脚本
-- MoonSecV3ScriptHere()
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
