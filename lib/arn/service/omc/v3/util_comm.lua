-- by Qige <qigezhao@gmail.com>
-- 2017.10.20 ARN iOMC v3.0-alpha-201017Q

local Comm = {}
Comm.Util = require 'arn.service.omc.v3.util_curl'

function Comm.Env()
    return Comm.Util.Env()
end

function Comm.Sync(url, data)
    return Comm.Util.PostJson(url, data)
end

return Comm