local M = { _MODULE_NAME = "URI._login" }
local URI = require "URI"
URI._subclass_of(M, "URI._server")
M:_mix_in("URI._userpass")

-- Generic terminal logins.  This is used as a base class for 'telnet',
-- 'tn3270', and 'rlogin' URL schemes.

return M
-- vi:ts=4 sw=4 expandtab
