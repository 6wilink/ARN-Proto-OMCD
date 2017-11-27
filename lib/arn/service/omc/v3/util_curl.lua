-- by Qige <qigezhao@gmail.com>
-- 2017.09.04 ENV|POST_JSON|POST
-- 2017.10.20 Env|PostJson|Post v3.0-201017

local DBG = print
--local function DBG(msg) end

local CCFF = require 'arn.utils.ccff'
local exec = CCFF.execute
local fexists = CCFF.file.exists
local sfmt = string.format

local cURL = {}
cURL.binFile = '/usr/bin/curl'
cURL.postFmt = "curl -A 'OMC3Agent' -m 2 -d '%s' '%s' 2>/dev/null"
cURL.postJsonFmt = "curl -A 'OMC3Agent' -m 2 -X POST -d 'data=%s' '%s' 2>/dev/null"

function cURL.Env()
    local fileCurl = cURL.binFile
    return fexists(fileCurl)
end

function cURL.PostJson(url, data)
    local postJsonFmt = cURL.postJsonFmt
    local cmd = sfmt(postJsonFmt, data or '', url or 'localhost')
    DBG(cmd)
    local resp = exec(cmd)
    DBG(resp)
    return resp
end

function cURL.Post(url, data_array)
    local postFmt = cURL.postFmt
    local cmd = sfmt(postFmt, data or '', url or 'localhost')
    DBG(cmd)
    local resp = exec(cmd)
    DBG(resp)
    return resp
end

return cURL