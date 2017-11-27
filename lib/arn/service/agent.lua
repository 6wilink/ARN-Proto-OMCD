-- by Qige <qigezhao@gmail.com>
-- 2017.08.14 basic App
-- 2017.10.20 add support of ARN iOMC3 v3.0

local CCFF = require 'arn.utils.ccff'
local sfmt = string.format

local Agent = {}
Agent.COM = nil

function Agent.Run(com, conf, dbg)
    if (com == 'ec54s') then
        Agent.COM = require 'arn.service.ec54s.ec54s_daemon'
    elseif (com == 'lcd') then
        Agent.COM = require 'arn.service.lcdctrl.lcdctrl_daemon'
    elseif (com == 'cgi') then
        Agent.COM = require 'arn.service.cgi.cgi_daemon'
    elseif (com == 'tpc') then
        Agent.COM = require 'arn.service.tpc.tpc_daemon'
    -- default 'omc'
    elseif (comm == 'omc') then
        Agent.COM = require 'arn.service.omc.omc_daemon'
    end
    
	if (Agent.COM) then
    		print(sfmt('> Agent (%s) started', com or 'omc'))
    		Agent.COM.Run(conf, dbg)
	end
end

return Agent
