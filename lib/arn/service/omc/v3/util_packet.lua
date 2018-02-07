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
    local result = nil
    if (msg) then
        result = {}
        DBG('msg = [' .. msg .. ']')
        local items = Split(msg, '&')
        local i, v
        for i,v in pairs(items) do
            local kv = Split(v, '=')
            local key = kv[1]
            local val = kv[2]
            if (key and val) then
                result[key] = val
                DBG(sfmt('result.%s = %s', key, val))
            end
        end
    end
    return result
end

return Packet