-- by Qige <qigezhao@gmail.com>
-- 2017.08.14 basic App
-- 2017.10.20 add support of ARN iOMC3 v3.0

local CCFF  = require 'arn.utils.ccff'

local Agent = {}
Agent.COM = nil

function Agent.Run(com, conf, dbg)
    if (com == 'ec54s') then
        Agent.COM = require 'arn.service.ec54s.agent'
    elseif (com == 'tpc') then
        Agent.COM = require 'arn.service.tpc.agent'
    else
        Agent.COM = require 'arn.service.omc.agent'
    end
    
    print('> Agent started')
    Agent.COM.Run(conf, dbg)
end

return Agent