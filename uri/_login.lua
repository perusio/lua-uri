local M = { _NAME = "uri._login" }
local URI = require "uri"
URI._subclass_of(M, "uri._server")
M:_mix_in("uri._userpass")

-- Generic terminal logins.  This is used as a base class for 'telnet',
-- 'tn3270', and 'rlogin' URL schemes.

return M
-- vi:ts=4 sw=4 expandtab
