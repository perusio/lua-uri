local _G = _G
module("URI.mms")
_G.URI._subclass_of(_M, "URI.http")

function default_port () return 1755 end

-- vi:ts=4 sw=4 expandtab
