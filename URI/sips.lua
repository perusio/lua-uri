local M = { _MODULE_NAME = "URI.sips" }
local URI = require "URI"
URI._subclass_of(M, "URI.sip")

function M.default_port () return 5061 end

return M
-- vi:ts=4 sw=4 expandtab
