local M = { _MODULE_NAME = "uri.https" }
local Util = require "URI._util"
local Http = require "URI.http"
Util.subclass_of(M, Http)

function M.default_port () return 443 end

return M
-- vi:ts=4 sw=4 expandtab
