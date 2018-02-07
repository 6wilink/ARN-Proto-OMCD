-- by Qige <qigezhao@gmail.com>
-- 2017.10.20 v3.0-201017

--local DBG = print
local DBG = function(msg) end

local CCFF = require 'arn.utils.ccff'
local ARNMngr = require 'arn.device.mngr'

local isArray = CCFF.val.is_array
local tblFind = CCFF.val.in_list
local sfmt = string.format

local Tuner = {}
Tuner.Util = require 'arn.device.mngr'

function Tuner.Adjust(todoList)
    DBG('Tuner.Adjust()> ')
    if (Tuner.verifyToken(todoList)) then
        --[[
        -- old kv pairs
        local op
        _, op = Tuner.whatToDo(todoList)
        if (op == 'set') then
            DBG('Tuner.Adjust()> set by request')
            item, val = Tuner.findSetItem(todoList)
            if (item and val) then
                if (item == 'freq') then
                    print(sfmt('==== set frequency to %s ====', val))
                    ARNMngr.SAFE_SET('freq', val)
                elseif (item == 'chan') then
                    print(sfmt('==== set channel to %s ====', val))
                    ARNMngr.SAFE_SET('channel', val)
                elseif (item == 'rgn') then
                    print(sfmt('==== set region to %s ====', val))
                    ARNMngr.SAFE_SET('region', val)
                elseif (item == 'txpwr') then
                    print(sfmt('==== set txpower to %s ====', val))
                    ARNMngr.SAFE_SET('txpower', val)
                end
            end
        else
            DBG('nothing to do')
        end
        ]]--
        
        --[[for k,v in pairs(todoList) do
            print(k, v)
        end
        ]]--
            
        -- object
        local op = todoList['cmd']
        local val = todoList['val']
        DBG(sfmt('Tuner.Adjust()> %s=%s %s', op or '.', val or '.', #todoList))
        if (op and val) then
            if (op == 'mode') then
                print(sfmt('==== set mode to %s ====', val))
                ARNMngr.SAFE_SET('mode', val)
            elseif (op == 'channel') then
                print(sfmt('==== set channel to %s ====', val))
                ARNMngr.SAFE_SET('channel', val)
            elseif (op == 'txpower') then
                print(sfmt('==== set txpower to %s ====', val))
                ARNMngr.SAFE_SET('txpower', val)
            else
                DBG('* bad command, do nothing')
            end
        end
    else
       print('==== Bad TOKEN ====') 
    end
end

-- TODO: verify TOKEN, and return true|false
function Tuner.verifyToken(todoList)
    DBG('Tuner.verifyToken(todoList)> ')
    return (true and todoList)
end


--[[
-- old kv pairs
function Tuner.findSetItem(todoList)
    DBG('Tuner.findSetItem(todoList)> ')
    local keyArray = { 'freq', 'chan', 'rgn', 'txpwr' }
    return Tuner.findItemVal(todoList, keyArray)
end

function Tuner.whatToDo(todoList)
    DBG('Tuner.whatToDo(todoList)> ')
    return Tuner.findItemVal(todoList, { 'op' })
end

function Tuner.findItemVal(todoList, itemList)
    DBG('Tuner.findItemVal(todoList, itemList)> ')
    local key
    local val
    if isArray(todoList) and isArray(itemList) then
        todoListLen = #todoList or 0
        DBG('todoList len: ' .. todoListLen)
        local idx = 1
        local vidx = 2
        while(vidx <= todoListLen) do
            key = todoList[idx]
            val = todoList[vidx]
            local i
            local v
            local flagFound = false
            for i,v in pairs(itemList) do
                if (key == v) then
                    flagFound = true
                    break
                end
            end
            if (flagFound) then
                break
            end
            idx = idx + 2
            vidx = vidx + 2
        end
        DBG(sfmt('--> key = %s, val = %s', key or '-', val or '-'))
    end
    return key, val
end
]]--

return Tuner