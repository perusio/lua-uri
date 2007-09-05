-- http://rsync.samba.org/
local _G = _G
module("URI.rsync", package.seeall)
URI._subclass_of(_M, "URI._server")
_M:_mix_in("URI._userpass")

-- rsync://[USER@]HOST[:PORT]/SRC

function default_port () return 873 end

-- vi:ts=4 sw=4 expandtab
