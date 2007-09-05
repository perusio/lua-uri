module("URI.rtspu", package.seeall)
URI._subclass_of(_M, "URI.rtsp")

-- TODO - I think this can be removed, the one in URI.rtsp should suffice
function default_port () return 554 end

-- vi:ts=4 sw=4 expandtab
