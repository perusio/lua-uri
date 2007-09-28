local M = { _NAME = "uri.mms" }
local Util = require "uri._util"
local Http = require "uri.http"
Util.subclass_of(M, Http)

function M.default_port () return 1755 end

return M
-- vi:ts=4 sw=4 expandtab
