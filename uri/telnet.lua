local M = { _NAME = "uri.telnet" }
local URI = require "uri"
URI._subclass_of(M, "uri._login")

function M.default_port () return 23 end

return M
-- vi:ts=4 sw=4 expandtab
