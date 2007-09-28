-- http://rsync.samba.org/
local M = { _NAME = "uri.rsync" }
local URI = require "uri"
URI._subclass_of(M, "uri._server")
M:_mix_in("uri._userpass")

-- rsync://[USER@]HOST[:PORT]/SRC

function M.default_port () return 873 end

return M
-- vi:ts=4 sw=4 expandtab
