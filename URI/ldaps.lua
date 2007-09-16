local M = { _MODULE_NAME = "URI.ldaps" }
local URI = require "URI"
URI._subclass_of(M, "URI.ldap")

function M.default_port () return 636 end

return M
-- vi:ts=4 sw=4 expandtab
