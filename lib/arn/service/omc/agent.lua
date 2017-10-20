-- by Qige <qigezhao@gmail.com>
-- 2017.10.20 ARN iOMC3 v3.0.201017

-- DEBUG USE ONLY
local DBG = print
--local function DBG(msg) end

local CCFF = require 'arn.utils.ccff'
local V3Agent = require 'arn.service.omc.v3.agent'

local cget  = CCFF.conf.get
local fread = CCFF.file.read
local fwrite = CCFF.file.write

local ts    = os.time
local dt    = function() return os.date('%X %x') end
local sfmt  = string.format


local OMC = {}
OMC.VERSION = V3Agent.VERSION

OMC.conf = {}
OMC.conf._SIGNAL = '/tmp/.signal.omc3.tmp'
OMC.conf.server = cget('arn-proto','omc','server') or '192.168.1.2'
OMC.conf.port = cget('arn-proto','omc','port') or 80
OMC.conf.interval = cget('arn-proto','omc','interval') or 1
OMC.conf.reportInterval = cget('arn-proto','omc','report_interval') or 5
OMC.conf.protocol = cget('arn-proto','omc','protocol') or 'http'

function OMC.version()
    OMC.reply(sfmt('-> %s', OMC.VERSION))
end

function OMC.init()
    if (not CCFF) then
        return 'need packet ARN-Scripts'
    end
    if (not OMC.conf.server) or (not OMC.conf.port) then
        return 'unknown server or port'
    end
    return nil
end

function OMC.Run(conf, dbg)
    OMC.version()
    local err = OMC.init()
    if (err) then
        OMC.failed(err)
        return
    end
    
    -- get instant
    local daemon = V3Agent.New(
        OMC.conf.server, OMC.conf.port,
        OMC.conf.interval, OMC.conf.reportInterval,
        OMC.conf.protocol
    )
    if (not daemon) then
        OMC.failed('unable to get instant')
        return
    end
    
    -- mark instant ready
    local msg = sfmt("-> started (%s://%s:%s | intl %s/%s) +%s", 
        OMC.conf.protocol, OMC.conf.server, OMC.conf.port, 
        OMC.conf.interval, OMC.conf.reportInterval, 
        dt()
    )
    OMC.reply(msg)
    OMC.log(msg)
    
    -- do some preparation: check env, utils, etc.
    local waitTO = 0.2
    local msg = daemon:Prepare(waitTO)
    if (not msg) then
        -- ready to run, check quit signal, run task, do idle
        local i
        while true do
            if (OMC.QUIT_SIGNAL()) then
                break
            end
            daemon:Task('all')
            OMC.reply(sfmt("--> Agent-OMC synced +%s", dt()))
            daemon:Idle(OMC.conf.interval)
            --break --TODO: DEBUG USE ONLY
        end
        local s = sfmt("-> signal SIGTERM +%s", dt())
        OMC.reply(s)
    else
        OMC.failed(msg)
    end
    
    -- clean up instant
    daemon:Cleanup()

    -- mark quit
    local s = sfmt("-> stopped +%s", dt())
    OMC.reply(s)
    OMC.log(s)
end

function OMC.failed(msg)
    print('== Agent-OMC failed: ' .. msg)
end

function OMC.reply(msg)
    print(msg)
end

function OMC.log(msg)
    local sig_file = OMC.conf._SIGNAL
    fwrite(sig_file, msg .. '\n')
end

function OMC.QUIT_SIGNAL()
    local signal =  false
    local exit_array = {
        "exit","exit\n",
        "stop","stop\n",
        "quit","quit\n",
        "bye","byte\n",
        "down","down\n"
    }
    local sig_file = OMC.conf._SIGNAL
    local sig = fread(sig_file)
    for k,v in ipairs(exit_array) do
        if (sig == v) then
            signal = true
            break
        end
    end
    return signal
end

return OMC