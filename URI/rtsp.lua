module("URI.rtsp", package.seeall)
URI._subclass_of(_M, "URI.http")

function default_port () return 554 end

-- vi:ts=4 sw=4 expandtab
