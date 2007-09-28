local M = { _NAME = "uri.rtsp" }
local URI = require "uri"
URI._subclass_of(M, "uri.http")

function M.default_port () return 554 end

return M
-- vi:ts=4 sw=4 expandtab
