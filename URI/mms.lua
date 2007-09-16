local M = { _MODULE_NAME = "URI.mms" }
local URI = require "URI"
URI._subclass_of(M, "URI.http")

function M.default_port () return 1755 end

return M
-- vi:ts=4 sw=4 expandtab
