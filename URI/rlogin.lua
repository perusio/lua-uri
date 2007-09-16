local M = { _MODULE_NAME = "URI.rlogin" }
local URI = require "URI"
URI._subclass_of(M, "URI._login")

function M.default_port () return 513 end

return M
-- vi:ts=4 sw=4 expandtab
