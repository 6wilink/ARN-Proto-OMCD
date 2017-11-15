-- by Qige <qigezhao@gmail.com>
-- 2017.10.20 ARN iOMC v3.0-alpha-201017Q

--local DBG = print
local DBG = function(msg) end

--local DBG_COMM = print
local DBG_COMM = function(msg) end


local CCFF      = require 'arn.utils.ccff'
local ARNMngr   = require 'arn.device.mngr'
local DBGChar   = require 'arn.utils.debug'
local CURL      = require 'arn.service.omc.v3.util_curl'
local TOKEN     = require 'arn.service.omc.v3.util_token'

local exec  = CCFF.execute
local sfmt  = string.format
local schar = string.char
local sbyte = string.byte
local ssub  = string.sub
local ts    = os.time
local dt    = function() return os.date('%X %x') end


local OMC3 = {}
OMC3.VERSION = 'ARN-Agent-OMC v3.0-alpha-201017Q'

OMC3.Tuner = require 'arn.service.omc.v3.util_tuner'
OMC3.Packet = require 'arn.service.omc.v3.util_packet'
OMC3.Comm = require 'arn.service.omc.v3.util_comm'

OMC3.conf = {}
OMC3.conf.fmtHttpReq = '%s://%s:%s/iomc3/dmngr.php?a=%s&z=%s'
OMC3.conf.fmtTokenKey = "6Harmonics+ARN+%s"

OMC3.instant = {}
OMC3.instant.__index = OMC3.instant -- OOP liked(1/2)

function OMC3.New(
    server, port, 
    interval, reportInterval, protocol
)
    local instant = {}
    setmetatable(instant, OMC3.instant) -- OOP liked(2/2)
    
    instant.VERSION = OMC3.VERSION
    instant.conf = {}
    instant.conf.protocol = protocol or 'http'
    instant.conf.server = server or 'localhost'
    instant.conf.port = port or 80
    instant.conf.interval = interval or 2
    instant.conf.reportInterval = reportInterval or 10
    
    -- Resource
    instant.res = {}
    
    instant.cache = {}
    instant.cache.startTs = ts()

    return (instant)
end

function OMC3.instant:Prepare(timeout)
    DBG(sfmt("Agent.instant:Prepare(%s)", timeout or '-'))
    if (not OMC3.Comm.Env()) then
        return 'error: need packet cUrl'
    end
    if (not OMC3.Tuner) then
        return 'error: bad Tuner/Utilities'
    end
    if (not OMC3.Packet) then
        return 'error: bad OMC3 Packet'
    end
    if (not ARNMngr) then
        return 'error: need packet ARN-Scripts'
    end
    
    -- init TOKEN
    self.res.TOKEN = self:tokenGenerate()
    self.res.ts = ts()
    return nil
end

function OMC3.instant:Task(com)
    DBG(sfmt("OMC3.instant:Task(com)"))
    local data = self:DoSingleComm()
    if (data) then
        local todoList = OMC3.Packet.Decode(data)
        DBG_COMM(sfmt('ARN Agent OMC3> response parsed +%s', dt()))
        --DBGChar.dump_dec(todoList)
        --DBGChar.dump_hex(todoList)
        if (todoList) then
            DBG_COMM(sfmt('ARN Agent OMC3> adjust by response +%s', dt()))
            OMC3.Tuner.Adjust(todoList)
        end
    else
        DBG_COMM(sfmt('ARN Agent OMC3> invalid response +%s', dt()))
    end
end

function OMC3.instant:Cleanup()
end

function OMC3.instant:Idle(sec)
    exec('sleep ' .. sec or 1)
end

function OMC3.instant:tokenGenerate()
    local arn_safe = ARNMngr.SAFE_GET()
    local devWmac = arn_safe.abb_safe.wmac or '-'

    local fmtTokenKey = OMC3.conf.fmtTokenKey
    local tokenKey = sfmt(fmtTokenKey, devWmac)

    return TOKEN.OMCUp(tokenKey)
end

--[[
TODO:
    1. Check result every {interval};
    2. Send data every {report_interval};
    3. Handle cURL TIMEOUT;
    4. Compare with {timestamp}.
]]--
function OMC3.instant:DoSingleComm()
    DBG(sfmt("OMC3.instant:DoSingleComm()"))
    local dataRaw = {}
    local dataJson = '{}'
    
    local lastReportTs = self.cache.lastReportTs or 0
    local nowTs = ts()
    local reportInterval = tonumber(self.conf.reportInterval)
    if (nowTs - lastReportTs >= reportInterval) then
        dataRaw.ops = 'update'
        dataRaw.data = ARNMngr.SAFE_GET()
        self.cache.lastReportTs = ts()
    else
        dataRaw.ops = 'sync'
    end
    dataRaw.ts = ts()
    dataJson = OMC3.Packet.Encode(dataRaw)

    DBG_COMM(sfmt('ARN iOMC3 Agent> request sent +%s', dt()))
    DBG_COMM(dataJson)
    
    local buffer = self:reportToServer(dataJson)
    --DBGChar.dump_dec(buffer)
    --DBGChar.dump_hex(buffer)
    if (buffer and buffer ~='') then
        DBG_COMM(sfmt('ARN iOMC3 Agent> got response +%s', dt()))
    else
        DBG_COMM(sfmt('ARN iOMC3 Agent> empty response +%s', dt()))
    end
    return buffer
end


function OMC3.instant:reportToServer(dataJson)
    DBG(sfmt("Agent.instant:comm_cURL()"))
    -- OMC3.conf.fmtHttpReq: '%s://%s:%s/iomc3/dmngr.php?%a=%s&z=%s'
    local url = sfmt(OMC3.conf.fmtHttpReq,
                    self.conf.protocol, 
                    self.conf.server, self.conf.port,
                    'update',
                    self.res.TOKEN)
    DBG_COMM(url)
    local result = OMC3.Comm.Sync(url, dataJson)
    DBG_COMM('Response: [' .. result .. ']')
    return result
end

return OMC3