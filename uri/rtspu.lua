local M = { _NAME = "uri.rtspu" }
local URI = require "uri"
URI._subclass_of(M, "uri.rtsp")

-- TODO - I think this can be removed, the one in uri.rtsp should suffice
function M.default_port () return 554 end

return M
-- vi:ts=4 sw=4 expandtab
