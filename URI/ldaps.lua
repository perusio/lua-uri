module("URI.ldaps", package.seeall)
URI._subclass_of(_M, "URI.ldap")

function default_port () return 636 end

-- vi:ts=4 sw=4 expandtab
