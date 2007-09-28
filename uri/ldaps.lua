local M = { _NAME = "uri.ldaps" }
local URI = require "uri"
URI._subclass_of(M, "uri.ldap")

function M.default_port () return 636 end

return M
-- vi:ts=4 sw=4 expandtab
