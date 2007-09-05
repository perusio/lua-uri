module("URI._login", package.seeall)

URI._subclass_of(_M, "URI._server")
_M:_mix_in("URI._userpass")

-- Generic terminal logins.  This is used as a base class for 'telnet',
-- 'tn3270', and 'rlogin' URL schemes.

-- vi:ts=4 sw=4 expandtab
