local M = { _MODULE_NAME = "URI.rtspu" }
local URI = require "URI"
URI._subclass_of(M, "URI.rtsp")

-- TODO - I think this can be removed, the one in URI.rtsp should suffice
function M.default_port () return 554 end

return M
-- vi:ts=4 sw=4 expandtab
