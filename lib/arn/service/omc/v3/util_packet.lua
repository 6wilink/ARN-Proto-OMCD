-- by Qige <qigezhao@gmail.com>
-- 2017.09.06 Encode

--local DBG = print
local DBG = function(msg) end

local JSON = require 'arn.utils.json'
local CCFF = require 'arn.utils.ccff'
local Split = CCFF.split
local tblPush = table.insert
local sfmt = string.format

local Packet = {}

-- Return JSON format
function Packet.Encode(data)
    return JSON.Encode(data)
end

--[[
Tasks:

TODO:
    1. Check if "error 404: file not found";
    2. Parse message into table in pairs.
]]--
function Packet.Decode(msg)
    local result
    if (msg) then
        result = {}
        DBG('msg = [' .. msg .. ']')
        local items = Split(msg, '&')
        local i, v
        for i,v in pairs(items) do
            local kv = Split(v, '=')
            DBG(sfmt('key, val = [%s], [%s]', kv[1] or '-', kv[2] or '-'))
            tblPush(result, kv[1])
            tblPush(result, kv[2])
        end
        DBG('result len: ' .. #result)
    end
    return result
end

return Packet